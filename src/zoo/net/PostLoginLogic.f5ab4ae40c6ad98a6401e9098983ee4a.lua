require "zoo.net.UserBanLogic"
require "zoo.net.SyncExceptionLogic"

PostLoginLogic = class(EventDispatcher)

PostLoginLogicEvents = table.const {
	kComplete  	= "PostLoginLogic.complete",
	kError		= "PostLoginLogic.error",
	kException	= "PostLoginLogic.exception",
}

function PostLoginLogic:ctor()
	self.syncTimes = 0
end
function PostLoginLogic:onError(err)
	_G.kUserLogin = false
	self:dispatchEvent(Event.new(PostLoginLogicEvents.kError, err, self))
end
function PostLoginLogic:onFinish()
	_G.kUserLogin = true
	self:dispatchEvent(Event.new(PostLoginLogicEvents.kComplete, nil, self))
	GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(kGlobalEvents.kUserLogin))
end
function PostLoginLogic:onException()
	self:dispatchEvent(Event.new(PostLoginLogicEvents.kException, nil, self))
end
function PostLoginLogic:stopTimeout()
	if self.timeoutID ~= nil then CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.timeoutID) end
	if _G.isLocalDevelopMode then printx(0, "PostLoginLogic:: stop timeout check") end
end

function PostLoginLogic:load(timeout)
	timeout = timeout or 10
	local function onTimeout()
		self.isNotTimeout = false
		self:stopTimeout()
		SyncDataHelper:clearCacheData()
		self:onError(-2)
		-- if _G.isLocalDevelopMode then printx(0, "timeout @ PostLoginLogic") end
	end
	self.isNotTimeout = true
	self.timeoutID = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onTimeout, timeout,false)

    local localUserConfig = Localhost.getInstance():getLastLoginUserConfig()
    if localUserConfig and localUserConfig.uid ~= 0 and localUserConfig.uid ~= localUserConfig.sk then
		local platform = kDefaultSocialPlatform
    	self:login(localUserConfig.uid, localUserConfig.sk, platform)
    else
    	self:registerAndLogin()
    end
end

function PostLoginLogic:registerAndLogin()
	local function onRegisterError( evt )
		if evt then evt.target:removeAllEventListeners() end
		if _G.isLocalDevelopMode then printx(0, "register error") end
		if self.isNotTimeout then self:onError(evt.data) end
	end
	local function onRegisterFinish( evt )
		evt.target:removeAllEventListeners()
		if self.isNotTimeout and kTransformedUserID ~= nil and kDeviceID ~= nil then
			local userId = kTransformedUserID
			local sessionKey = kDeviceID
			local platform = kDefaultSocialPlatform
			self:login(userId, sessionKey, platform)
		else self:onError(-2) end
	end 
	--begin with register
	local register = RegisterHTTP.new()
	register:addEventListener(Events.kComplete, onRegisterFinish)
	register:addEventListener(Events.kError, onRegisterError)
	register:load()
end

function PostLoginLogic:setUserDefault( userId )
	if __IOS then
		GspEnvironment:getInstance():setGameUserId(tostring(userId))
	elseif __ANDROID then 
		GspProxy:setGameUserId(tostring(userId)) 
	end
	HeGameDefault:setUserId(tostring(userId))
	DcUtil:dailyUser()
	if not __ANDROID then
		DcUtil:logLocation()
	end
end

function PostLoginLogic:login( userId, sessionKey, platform )
	PostLoginLogic:setUserDefault( userId )
	UserManager.getInstance().uid = userId
	UserManager.getInstance().sessionKey = sessionKey
	UserManager.getInstance().platform = platform
	Localhost.getInstance():setLastLoginUserConfig(userId, sessionKey, platform)
	ConnectionManager:reset(userId, sessionKey)
	
	local function onLoginError( evt )
		evt.target:removeAllEventListeners()
		_G.kUserLogin = false
		if self.isNotTimeout then self:onError(evt.data) end
	end
	local function onLoginFinish( evt )
		evt.target:removeAllEventListeners()
		if self.isNotTimeout then
			_G.kUserLogin = true
			if type(evt.data) == "table" and type(evt.data.lastSeq) == "number" then
				UserService:getInstance():setSyncSerial(evt.data.lastSeq)
			end
			self:sync()
		end
	end 
	local http = LoginHttp.new()
	http:addEventListener(Events.kComplete, onLoginFinish)
	http:addEventListener(Events.kError, onLoginError)
	http:load()
end

--sync 
local function onCachedHttpDataResponse(endpoint, resp, err)
	if err then 
		if not table.exist(ExceptionErrorCodeIgnore, err) then  
			LoginExceptionManager:getInstance():setErrorCodeCache(err)
		end
		he_log_warning("PostLoginLogic::onCachedHttpDataResponse data fail, err: " .. err)
	else 
		he_log_warning("PostLoginLogic::onCachedHttpDataResponse data success") 
	end
end

function PostLoginLogic:sync()
	-- local cachedLocalUserData, list = LoginLogic:readUserSyncDataFromLocal()
	local list = SyncManager.getInstance():getSyncHttpList()
	local function onUserCallback( endpoint, resp, err )
		self:stopTimeout()

		if err then he_log_warning("post onUserCallback fail, err: " .. err)
	    else he_log_info("post onUserCallback success") end
		
		if self.isNotTimeout then
			if err then 
				if _G.isLocalDevelopMode then printx(0, "sync err"..tostring(err)) end
				local errorCode = tonumber(err) or -1
				local function onUseLocalFunc()
					if _G.isLocalDevelopMode then printx(0, "player choose local data (wrong data)") end
					SyncDataHelper:clearCacheData()
					self:onError(err)
				end
				local function onUseServerFunc(data)
					if _G.isLocalDevelopMode then printx(0, "player clear local data and retry") end
					UserManager.getInstance():updateUserData(data)
					UserService.getInstance():updateUserData(data)
					UserService.getInstance():clearUsedHttpCache(list)

					UserService:getInstance():syncLocal()
					Localhost.getInstance():flushCurrentUserData()

					if SyncDataHelper:checkUserDeviceChanged(data) then
						SyncDataHelper:dcWithServerUserData(data)
					end
					SyncDataHelper:clearCacheData()

					self:sync()
				end
				local logic = SyncExceptionLogic:create(errorCode)
				logic:start(onUseLocalFunc, onUseServerFunc)
				self:onException()
			else
				if _G.isLocalDevelopMode then printx(0, "override local data with server data") end
				UserManager.getInstance():initFromLua(resp) --init data
				UserService.getInstance():initialize()
				LevelDifficultyAdjustManager:loadAndInitConfig()
				
				UserService.getInstance():clearUsedHttpCache(list)
				UserService:getInstance():syncLocal()
				Localhost.getInstance():flushCurrentUserData()

				if SyncDataHelper:checkUserDeviceChanged(data) then
					SyncDataHelper:dcWithServerUserData(data)
				end
				SyncDataHelper:clearCacheData()
				
				if __ANDROID then AndroidPayment.getInstance():changeSMSPaymentDecisionScript(resp.smsPay) end

				GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(kGlobalEvents.kSyncFinished, SyncFinishReason.kRestoreData))
				
				--finish login logic
				self:onFinish()
			end
			Notify:dispatch("AchiEventUserDataUpdate")
		end
	end

	SyncDataHelper:initCacheData()
	_G.skipHttpSpeedLitmit = true
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
	if __IOS then
		userbody.deviceOS = "ios"
	elseif __ANDROID then
		userbody.deviceOS = "android"
	elseif __WP8 then
		userbody.deviceOS = "wp"
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

	require "zoo.util.Cookie"
	userbody.clientType = MetaInfo:getInstance():getDeviceModel()

	userbody.osVersion = MetaInfo:getInstance():getOsVersion()
	userbody.networkType = NetworkUtil:getNetworkStatus()
	
	userbody.province = Cookie.getInstance():read(CookieKey.kLocationProvince)

	userbody.provinceIpId = RealNameManager:getLocationInfoCached()

	userbody.needKeys = _G.USER_NEED_KEYS
	userbody.imsi = MetaInfo:getInstance():getImsi()
	-- 后端用，用于判断一些随着动更需要启用的逻辑。使用时只可以递增。
	userbody.dynamicUpdateVersion = 1


	local cachedLocalUserData = Localhost.getInstance():readCurrentUserData()
	local scoreVersion = 0
	if cachedLocalUserData and cachedLocalUserData.user and #(UserManager:getInstance():getScoreRef() or {}) > 0 then
		scoreVersion = cachedLocalUserData.user.scoreVersion or 0
	end
	if cachedLocalUserData and cachedLocalUserData.user then
		SyncDataHelper:cacheUserData(cachedLocalUserData.user)
	end
	
	userbody.scoreVersion = scoreVersion

	ConnectionManager:sendRequest( "user", userbody, onUserCallback )
	ConnectionManager:flush()
	_G.skipHttpSpeedLitmit = nil
	--as user data meight changed, flush cached data
	-- if cachedLocalUserData then Localhost:flushSelectedUserData( cachedLocalUserData ) end
end