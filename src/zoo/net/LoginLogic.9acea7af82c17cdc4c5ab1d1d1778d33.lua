require "hecore.EventDispatcher"
require "hecore.EmergencySystem"

require "zoo.data.UserManager"
require "zoo.data.JumpLevelManager"
require "zoo.net.Http"
require "zoo.net.OnlineSetterHttp"
require "zoo.net.OnlineGetterHttp"
require "zoo.net.OfflineHttp"
require "zoo.net.Localhost"
require "zoo.net.UserService"
require "zoo.gamePlay.ReplayDataManager"
require "zoo.net.UserBanLogic"
require "zoo.net.SyncExceptionLogic"

assert(not LoginLogic)

local __hasSuccessLogin = false
local __lastSuccessLoginUid = nil


LoginLogic = class(EventDispatcher)
kUserDataStatus = {kOnlineServerData=1, kOnlineLocalData=2, kOfflineOldData=3, kOfflineNewData=4}
function LoginLogic:execute(userId, sessionKey, platform, timeout)
	self.timeout = timeout or 10 --todo: change default timeout.
	if userId == nil then self:onLoadingError()
	else self:connect(userId, sessionKey, platform) end
end

function LoginLogic:logout()
	__hasSuccessLogin = false
	__lastSuccessLoginUid = nil


	UserManager.getInstance().uid = nil
	UserManager.getInstance().sessionKey = nil
	Localhost.getInstance():setLastLoginUserConfig(0, nil, UserManager.getInstance().platform) 
end

function LoginLogic:connect(userId, sessionKey, platform)
	if _G.isLocalDevelopMode then printx(0, "starting login: userId:", userId, sessionKey, platform) end

	UserManager.getInstance().uid = userId
	UserManager.getInstance().sessionKey = sessionKey
	UserManager.getInstance().platform = platform

	if __IOS then
		GspEnvironment:getInstance():setGameUserId(tostring(userId))
	elseif __ANDROID then 
		GspProxy:setGameUserId(tostring(userId)) 
	end
	HeGameDefault:setUserId(tostring(userId))

	Localhost.getInstance():setLastLoginUserConfig(userId, sessionKey, platform)
	ConnectionManager:reset(userId, sessionKey)
	--login to our game server
	self:login()
end

--about login:
--IF LOGIN to server suceed, which means online, then get new user information from server, override the low level data.
--ELSE if failed, whick means offline or server down, just enter the offline mode.

--WHEN IT IS OFFLINE mode, if there is no local cached user data, create a new user.
--ELSE use the cached local data.

local _loginStackHistory = {}
function LoginLogic:login()
	local context = self
	local isNotTimeout = true
	local timeoutID = nil

	if(false) then
		local stackback = debug.traceback()
		_loginStackHistory[#_loginStackHistory + 1] = stackback
	end

	local function stopTimeout()
		if timeoutID ~= nil then CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(timeoutID) end
		if _G.isLocalDevelopMode then printx(0, "stop timeout check") end
		timeoutID = nil
	end 
	local function onLoginError( evt )
		evt.target:removeAllEventListeners()
		stopTimeout()
		if isNotTimeout then context:onLoadingError()			
		else if _G.isLocalDevelopMode then printx(0, "onLoginError callback after timeout") end end
	end
	local function onLoginFinish( evt )

		if(__hasSuccessLogin and 
			UserManager.getInstance().uid == __lastSuccessLoginUid) then
			if(#_loginStackHistory > 0) then
				local msg = "duplicate login behavior, uid: " .. tostring(__lastSuccessLoginUid) .. ", stack:\n"
				for i=1,#_loginStackHistory do
					msg = msg .. "#" .. tostring(i) .. ": " .. _loginStackHistory[i] .. "\n"
				end
				he_log_error(msg);
			end
		end
		__hasSuccessLogin = true
		__lastSuccessLoginUid = UserManager.getInstance().uid

		if isNotTimeout then
			DcUtil:up(140)
			_G.kUserLogin = true
			if type(evt.data) == "table" and type(evt.data.lastSeq) == "number" then
				UserService:getInstance():setSyncSerial(evt.data.lastSeq)
			end
		end
		evt.target:removeAllEventListeners()
		stopTimeout()
		if isNotTimeout then context:getUserInfo() 
		else if _G.isLocalDevelopMode then printx(0, "onLoginFinish callback after timeout") end end
	end 

	local timeConfig = Localhost:getDefaultConfig()
  	_G.__g_utcDiffSeconds = timeConfig.td or 0
	
	local http = LoginHttp.new()
	http:addEventListener(Events.kComplete, onLoginFinish)
	http:addEventListener(Events.kError, onLoginError)
	http:load()

	local function onLoginTimeout()
		if _G.isLocalDevelopMode then printx(0, "timeout @ LoginLogic:login " .. " time: (s)" .. self.timeout) end
		stopTimeout()
		isNotTimeout = false
		http:removeAllEventListeners()
		context:onLoadingError()
	end
	timeoutID = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onLoginTimeout,self.timeout,false)
end

--sync 
local function onCachedHttpDataResponse(endpoint, resp, err)
	if err then 
		if not table.exist(ExceptionErrorCodeIgnore, err) then 
			LoginExceptionManager:getInstance():setErrorCodeCache(err)
		end
		he_log_warning("LoginLogic::onCachedHttpDataResponse data fail, err: " .. err)
	else 
		he_log_warning("LoginLogic::onCachedHttpDataResponse data success") 
	end
end

function LoginLogic:readUserSyncDataFromLocal()
	-- cached data from local file is always update data as UserService saved, it's slower, but have the same effect as UserService did.
	-- thus we have a common way to deal with Login and Post Login logic.
	local list = {}
	local cachedLocalUserData = Localhost.getInstance():readCurrentUserData()
	if (cachedLocalUserData and cachedLocalUserData.user == nil) or cachedLocalUserData == nil then
		--as user registered, we have their real user id now, so delete the data use device id as user id 
		cachedLocalUserData = Localhost.getInstance():readUserDataByUserID(_G.kDeviceID)
		if cachedLocalUserData and cachedLocalUserData.user then 
			cachedLocalUserData.user.user.uid = UserManager.getInstance().uid
			Localhost.getInstance():deleteUserDataByUserID(_G.kDeviceID) 
		end
	end
	if cachedLocalUserData and cachedLocalUserData.user and cachedLocalUserData.user.user then
		local httpData = cachedLocalUserData.user.httpData or {}
		local ingameHttpData = cachedLocalUserData.user.ingameHttpData or {}
		local syncSerial = UserService:getInstance():getSyncSerial()
		if __WP8 then
			for i, element in ipairs(ingameHttpData) do
				if element then table.insert(list, element) end
			end
		end
		for i,element in ipairs(httpData) do
			if element then
				if type(element.body) == "table" then
					local ss = element.body.seq
					if type(ss) == "number" then
						if type(syncSerial) ~= "number" then
							syncSerial = ss
						elseif element.body.seq > syncSerial then syncSerial = element.body.seq end
					else
						if type(syncSerial) == "number" then
							syncSerial = syncSerial + 1
							element.body.seq = syncSerial
						end
					end
				end
				UserService:getInstance():setSyncSerial(syncSerial)
				table.insert(list, element)
			end
		end
		Localhost:flushSelectedUserData( cachedLocalUserData )
	else if _G.isLocalDevelopMode then printx(0, "sync: new user, no local data found") end end
	return cachedLocalUserData, list
end

function LoginLogic:sync()
	local context = self
	local isNotTimeout = true
	local timeoutID = nil
	local function stopTimeout()
		if timeoutID ~= nil then CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(timeoutID) end
		if _G.isLocalDevelopMode then printx(0, "stop timeout check") end
		timeoutID = nil
	end 

	local cachedLocalUserData, list = LoginLogic:readUserSyncDataFromLocal()

	if cachedLocalUserData and cachedLocalUserData.user then
		SyncDataHelper:initCacheData()
		SyncDataHelper:cacheUserData(cachedLocalUserData.user)
	end

	local function onUserCallback( endpoint, resp, err )
		stopTimeout()

		EmergencySystem.getInstance()

		--if _G.isLocalDevelopMode then printx(0, "onUserCallback", table.tostring(resp)) end
		if err then he_log_info("onUserCallback fail, err: " .. err)
	    else he_log_info("onUserCallback success") end
		
		if isNotTimeout then
			if err then 
				if _G.isLocalDevelopMode then printx(0, "sync err"..tostring(err)) end
				local errorCode = tonumber(err) or -1
				local function onUseLocalFunc()
					if _G.isLocalDevelopMode then printx(0, "player choose local data (wrong data)") end
					SyncDataHelper:clearCacheData()
					context:onLoadingError()
				end
				local function onUseServerFunc(data)
					if _G.isLocalDevelopMode then printx(0, "player clear local data and retry") end
					UserManager.getInstance():updateUserData(data)
					UserService.getInstance():updateUserData(data)
					UserService.getInstance():clearUsedHttpCache(list)
					-- UserService:getInstance():syncLocal()
					Localhost.getInstance():flushCurrentUserData()

					if SyncDataHelper:checkUserDeviceChanged(data) then
						SyncDataHelper:dcWithServerUserData(data)
					end
					SyncDataHelper:clearCacheData()

					context:sync()
				end
				local logic = SyncExceptionLogic:create(errorCode)
				logic:start(onUseLocalFunc, onUseServerFunc)
			else
				local lastLoginData = Localhost.getInstance():getLastLoginUserConfig()
				if lastLoginData and lastLoginData.uid then
					-- 记录已经发过udidOrIDFA
					Cookie.getInstance():write("hasSendUdidOrIDFA",lastLoginData.uid)
				end

				if _G.isLocalDevelopMode then printx(0, "override local data with server data") end
				local status = kUserDataStatus.kOnlineServerData
				UserManager.getInstance():initFromLua(resp) --init data
				UserService.getInstance():initialize()
				-- LevelDifficultyAdjustManager:loadAndInitConfig()
				UserService.getInstance():clearUsedHttpCache(list)
				-- UserService:getInstance():syncLocal()
				Localhost.getInstance():flushCurrentUserData()

				if SyncDataHelper:checkUserDeviceChanged(resp) then
					SyncDataHelper:dcWithServerUserData(resp)
				end
				SyncDataHelper:clearCacheData()

				if __ANDROID then AndroidPayment.getInstance():changeSMSPaymentDecisionScript(resp.smsPay) end
				
				--finish login logic
				context:dispatchEvent(Event.new(Events.kComplete, status, context))
				GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(kGlobalEvents.kUserLogin))

				local userId = UserManager:getInstance().user.uid
				if __IOS then
					GspEnvironment:getInstance():setGameUserId(tostring(userId))
				elseif __ANDROID then 
					GspProxy:setGameUserId(tostring(userId)) 
				end
				HeGameDefault:setUserId(tostring(userId))
				DcUtil:dailyUser()
				DcUtil:logLocation()
				DcUtil:logInGame()
		        DcUtil:appInfo()
		        DcUtil:runningApp()

				ReplayDataManager:checkForceToUploadReplay()
			end
		end	

 		if _G.isLocalDevelopMode or UserManager.getInstance().userType == 1 then -- 白名单用户
		    if(__ANDROID) then
		    	local function startLogCatch()
	                local disp = luajava.bindClass("com.happyelements.AndroidAnimal.MainAppWrapper")
	                if(disp) then
	                	disp:startLogCatch()
	                end
		    	end
		    	he_log_info('startLogCatch')
	            pcall(startLogCatch)
		    end
 		end

	end
	ConnectionManager:block()
	for i,element in ipairs(list) do 
		ConnectionManager:sendRequest( element.endpoint, element.body, onCachedHttpDataResponse ) 
		SyncDataHelper:addHttpData(element)
	end
	local userbody = {
		curMd5 = ResourceLoader.getCurVersion(),
		pName = _G.packageName 
	}
	if StartupConfig:getInstance():getSmallRes() then 
		userbody.mini = 1
	else
		userbody.mini = 0
	end
	userbody.deviceOS = "unknown"

	local udidOrIDFAStr = ""

	if __IOS then
		userbody.deviceOS = "ios"
		udidOrIDFAStr = AppController:getAdvertisingIdentifier() or ""
		userbody.idfa = udidOrIDFAStr -- 消2推广活动必要字段
		userbody.cloverInstalled = UIApplication:sharedApplication():canOpenURL(NSURL:URLWithString('happyclover3://'))
	elseif __ANDROID then
		userbody.deviceOS = "android"
		udidOrIDFAStr = MetaInfo:getInstance():getUdid()

		require 'zoo.util.CloverUtil'
		userbody.cloverInstalled = CloverUtil:isAppInstall()
	elseif __WP8 then
		userbody.deviceOS = "wp"
		udidOrIDFAStr = MetaInfo:getInstance():getUdid()
	elseif __WIN32 then
		userbody.idfa = '12345'
		userbody.cloverInstalled = false
	end

	-- 如果没给服务器发过，发udidOrIDFA
	local lastLoginData = Localhost.getInstance():getLastLoginUserConfig()
	local recordUid = Cookie.getInstance():read("hasSendUdidOrIDFA")

	if not recordUid or not lastLoginData or recordUid ~= lastLoginData.uid then
		userbody.udidOrIDFA = udidOrIDFAStr
	end

	--IOS后端推送所需 在AppController.mm里获取然后写入
	userbody.deviceToken = ""
	if __IOS then
		userbody.deviceToken = CCUserDefault:sharedUserDefault():getStringForKey("animal_ios_deviceToken") or ""
	end

	--推送召回 前端向后端发送流失状态
	userbody.lostType = RecallManager.getInstance():getRecallRewardState()
	-- 
	userbody.deviceUdid = MetaInfo:getInstance():getUdid()
	if _G.inSyncUserDataByChangeAccount then
		userbody.snsPlatform = PlatformConfig:getLastPlatformAuthName()
		userbody.loginType = PlatformConfig:getLastPlatformAuthType()
	else
		if _G.tryLoginType ~= nil then
			local snsAuthDetail = PlatformConfig:getPlatformAuthDetail(_G.tryLoginType)
			if snsAuthDetail ~= nil then userbody.snsPlatform = snsAuthDetail.name end
			userbody.loginType = _G.tryLoginType
		else
			userbody.snsPlatform = PlatformConfig:getLastPlatformAuthName()
			userbody.loginType = PlatformConfig:getLastPlatformAuthType()
		end
	end

	if _G.isPrePackage then 
		userbody.pre = 1
	else
		userbody.pre = 0
	end

	userbody.clientType = MetaInfo:getInstance():getDeviceModel()

	userbody.osVersion = MetaInfo:getInstance():getOsVersion()
	userbody.networkType = NetworkUtil:getNetworkStatus()
	
	userbody.province = Cookie.getInstance():read(CookieKey.kLocationProvince)

	userbody.provinceIpId = RealNameManager:getLocationInfoCached()

	userbody.needKeys = _G.USER_NEED_KEYS
	userbody.imsi = MetaInfo:getInstance():getImsi()
	-- 后端用，用于判断一些随着动更需要启用的逻辑。使用时只可以递增。
	userbody.dynamicUpdateVersion = 1

	if __launch_para and __launch_para.recall_code then
		local para = {caller = tonumber(__launch_para.recall_code)}
		userbody.schemaParams = table.serialize(para)
		__launch_para = nil
	end

	local scoreVersion = 0
	if cachedLocalUserData and cachedLocalUserData.user and #(UserManager:getInstance():getScoreRef() or {}) > 0 then
		scoreVersion = cachedLocalUserData.user.scoreVersion or 0
	end
	userbody.scoreVersion = scoreVersion

	-- 拉取关卡调整配置
    local levelConfigUpdateProcessor = require("zoo.loader.LevelConfigUpdateProcessor").new()
    levelConfigUpdateProcessor:start()  

	ConnectionManager:sendRequest( "user", userbody, onUserCallback )
	ConnectionManager:flush()
	--as user data may changed, flush cached data
	if cachedLocalUserData then Localhost:flushSelectedUserData( cachedLocalUserData ) end

	local function onUserInfoTimeout()
		if _G.isLocalDevelopMode then printx(0, "timeout @ LoginLogic:sync " .. " time: (s)" .. self.timeout) end
		stopTimeout()
		isNotTimeout = false
		SyncDataHelper:clearCacheData()
		context:onLoadingError()
	end
	timeoutID = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onUserInfoTimeout,self.timeout,false)
end

function LoginLogic:getUserInfo()
	self:sync()
end

function LoginLogic:onLoadingError(err)
	if _G.isLocalDevelopMode then printx(0, "net err, error code: ", tostring(err), "; enter local host mode") end
	_G.kUserLogin = false
	--if we can not login or get user data from server, enter local server mode.
	--load data from device
	local status = 0
	local cachedLocalUserData = Localhost.getInstance():readLastLoginUserData()
  	if cachedLocalUserData and cachedLocalUserData.user then
  		local timeConfig = Localhost:getDefaultConfig()
  		_G.__g_utcDiffSeconds = timeConfig.td or 0

  		UserManager.getInstance():decode(cachedLocalUserData.user)

  		local user = UserManager.getInstance().user
  		local savedConfig = Localhost.getInstance():getLastLoginUserConfig()
  		if tostring(savedConfig.uid) == tostring(user.uid) then
	  		UserManager.getInstance().uid = tostring(savedConfig.uid)
			UserManager.getInstance().sessionKey = _G.kDeviceID
			UserManager.getInstance().platform = savedConfig.p
		else 
			if _G.isLocalDevelopMode then printx(0, "savedConfig uid is different from local saved uid") end 
		end
  		
  		if _G.isLocalDevelopMode then printx(0, "read last login user data: ", user.uid, " ", user:getTopLevelId(), " ", user:getCoin(), " td:"..__g_utcDiffSeconds) end
  		status = kUserDataStatus.kOfflineOldData
  		UserService.getInstance():decodeLocalStorageData(cachedLocalUserData.user)
  	else
	  	_G.__g_utcDiffSeconds = 0
  		if _G.isLocalDevelopMode then printx(0, "old user data not found, create a temp new user by local service.", " td:"..__g_utcDiffSeconds) end
  		UserManager.getInstance():createNewUser()
  		status = kUserDataStatus.kOfflineNewData
		
  		Localhost.getInstance():setLastLoginUserConfig(UserManager.getInstance().uid, UserManager.getInstance().sessionKey, UserManager.getInstance().platform)
  	end

  	--start local host. copy data from UserManager.
	UserService.getInstance():initialize()

	--refresh data. after some time, when player come back to game, we need to refresh energy, etc.
	local refreshedUserData = LoginLocalLogic:refresh()
	if refreshedUserData then
		UserManager.getInstance():syncUserData(refreshedUserData)
		if NetworkConfig.writeLocalDataStorage then Localhost.getInstance():flushCurrentUserData()
		else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end
	end

	-- LevelDifficultyAdjustManager:loadAndInitConfig()
	
	--updateinfo
	NewVersionUtil:readCacheUpdateInfo()
	local userId = UserManager:getInstance().user.uid
	if __IOS then
		GspEnvironment:getInstance():setGameUserId(tostring(userId))
	elseif __ANDROID then 
		GspProxy:setGameUserId(tostring(userId)) 
	end
	HeGameDefault:setUserId(tostring(userId))
	DcUtil:dailyUser()
	DcUtil:logLocation()
	DcUtil:logInGame()
    DcUtil:appInfo()
    DcUtil:runningApp()

	self:dispatchEvent(Event.new(Events.kError, nil, self))

	ReplayDataManager:checkForceToUploadReplay()
end
