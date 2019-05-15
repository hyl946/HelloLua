require "zoo.data.UserManager"
require "zoo.net.UserBanLogic"

-------------------------------------------------------------------------
--  Class include: ReachabilityUtil
-------------------------------------------------------------------------

--
-- SyncManager ---------------------------------------------------------
--
local kMinDisplayTime = 3
local instance = nil

SyncFinishReason = {
	kSuccess = 1,
	kLoginError = 2,
	kNoNetwork = 3,
	kRestoreData = 4,
	kNoLocalServer = 5,
	kNoDataToUpload = 6,
}

SyncErrorReason = {
	kNoNet = 1,
	kNoLogin = 2,
	kSyncFail = 3,
	kCancel = 4, 
}

SyncManager = {}

function SyncManager.getInstance()
	if not instance then 
		instance = SyncManager 
	end
	return instance
end

--[[
将本地缓存的请求合并到一个http请求里，发送给后端，并在最后缀上一个sync的请求
]]
function SyncManager:sync(onCurrentSyncFinish, onCurrentSyncError, animationType)
	-- local function onUserLogin()
	-- 	self:flush(onCurrentSyncFinish, onCurrentSyncError, animationType)
	-- end
	-- local function onUserNotLogin()
	-- 	if onCurrentSyncError then onCurrentSyncError() end
	-- 	GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(kGlobalEvents.kSyncFinished, SyncFinishReason.kLoginError))
	-- end

	-- animationType = animationType or kRequireNetworkAlertAnimation.kSync
	-- RequireNetworkAlert:callFuncWithLogged(onUserLogin, onUserNotLogin, animationType)

	self:syncLite(onCurrentSyncFinish, onCurrentSyncError, animationType)
end

--[[
检查syncLiteList列表，取出第一个（如果有），将其作为参数调用flush方法
]]
function SyncManager:__doSyncLiteNow()
	if not self.syncLiteList then
		self.syncLiteList = {}
	end

	if #self.syncLiteList > 0 then
		local currE = table.remove(self.syncLiteList, 1) 
		self:flush( currE.onCurrentSyncFinish , currE.onCurrentSyncError , currE.animationType )
	end
end

--[[
延迟一帧之后调用__doSyncLiteNow
]]
function SyncManager:__doSyncLiteNexFrame()
	if not self.syncLiteScheduleId then 
		local function callback()
			if self.syncLiteScheduleId then 
				CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.syncLiteScheduleId)
				self.syncLiteScheduleId = nil
				self:__doSyncLiteNow()
			end
		end
		self.syncLiteScheduleId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(callback, 0, false)
	end
end

local containerCircle = nil
local container = nil
local touchLayer = nil
local timeoutID = nil
local syncCanceled = false
local beginTime = nil
local function removeContainer()
	if container then 
		container:removeFromParentAndCleanup(true)
		container = nil
	end
	if touchLayer then 
		touchLayer:removeFromParentAndCleanup(true)
		touchLayer = nil
	end
end	
local function getNormalLoading(closeCb, tipKey)
	return CountDownAnimation:createNetworkAnimation(Director:sharedDirector():getRunningScene(), closeCb, localize(tipKey))
end
local function removeLoading(animationType, isCancel)
	if animationType == kRequireNetworkAlertAnimation.kSync then
		if beginTime then 
			local delayTime = 0
			local deltaTime = os.clock() - beginTime
			if deltaTime < kMinDisplayTime then delayTime = kMinDisplayTime - deltaTime end
			if containerCircle then containerCircle:hide(delayTime) end
			beginTime = nil
		end
	elseif animationType == kRequireNetworkAlertAnimation.kSyncLoad then
		syncCanceled = isCancel
		if timeoutID ~= nil then 
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(timeoutID) 
			timeoutID = nil
		end
		removeContainer()
	elseif animationType == kRequireNetworkAlertAnimation.kDefault then
		syncCanceled = isCancel
		removeContainer()
	end
end
local function showLoading(animationType)
	if animationType == kRequireNetworkAlertAnimation.kSync then
		if containerCircle then return end
		beginTime = os.clock()
		containerCircle = CountDownAnimation:createSyncAnimation()
	elseif animationType == kRequireNetworkAlertAnimation.kSyncLoad then 
		if container or touchLayer then return end
		local wSize = Director:sharedDirector():getWinSize()
		local scene = Director:sharedDirector():getRunningScene()
		touchLayer = LayerColor:create()
		touchLayer:changeWidthAndHeight(wSize.width, wSize.height)
		touchLayer:setTouchEnabled(true, 0, true)
		-- touchLayer:setColor(ccc3(255, 0, 0))
		touchLayer:setOpacity(0)
		if scene then scene:addChild(touchLayer, SceneLayerShowKey.POP_OUT_LAYER) end
		
		timeoutID = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function ()
			if timeoutID ~= nil then 
				CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(timeoutID) 
				timeoutID = nil
			end

			container = getNormalLoading(function ()
					removeLoading(animationType, true)
			end, "dis.connect.connecting.date.tips")
		end, 1, false)
	elseif animationType == kRequireNetworkAlertAnimation.kDefault then
		if container or touchLayer then return end

		container = getNormalLoading(function ()
				removeLoading(animationType, true)
		end, "loading.upload.data")
	end
end

--[[
和sync的功能一样，不同点在于：
当多次调用syncLite时，并不会每次都将本地缓存的http请求重新发送一次（而sync方法会），而是等前一次sync，以及sfterSync请求都成功返回后，再运行下一次
]]
function SyncManager:syncLite(onCurrentSyncFinish, onCurrentSyncError, animationType)
	if not self.syncLiteList then
		self.syncLiteList = {}
	end

	local function onUserLogin()
		local element = {}
		element.onCurrentSyncFinish = onCurrentSyncFinish
		element.onCurrentSyncError = onCurrentSyncError
		element.animationType = animationType

		table.insert( self.syncLiteList , element )

		if not self.isSyncing and not self.isAfterSyncing then
			self:__doSyncLiteNow()
		else
			showLoading(animationType)
		end
	end
	local function onUserNotLogin()
		if onCurrentSyncError then onCurrentSyncError(nil, SyncErrorReason.kNoLogin) end
		GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(kGlobalEvents.kSyncFinished, SyncFinishReason.kLoginError))
	end

	animationType = animationType or kRequireNetworkAlertAnimation.kSync
	RequireNetworkAlert:callFuncWithLogged(onUserLogin, onUserNotLogin, animationType)

end

local function onCachedHttpDataResponse(endpoint, resp, err)
	if err then 	
		if not table.exist(ExceptionErrorCodeIgnore, err) then 
			LoginExceptionManager:getInstance():setErrorCodeCache(err)
		end
		he_log_warning("SyncManager::onCachedHttpDataResponse data fail, err: " .. err)
	else 
		he_log_warning("SyncManager::onCachedHttpDataResponse data success") 
	end
end

function SyncManager:flush(onCurrentSyncFinish, onCurrentSyncError, animationType)
	if __IOS and not ReachabilityUtil.getInstance():isNetworkAvailable() then
		if _G.isLocalDevelopMode then printx(0, "Network disabled on iOS? ignore sync this time.") end
		GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(kGlobalEvents.kSyncFinished, SyncFinishReason.kNoNetwork))
		if onCurrentSyncError ~= nil then onCurrentSyncError(nil, SyncErrorReason.kNoNet) end
		return
	end
	if not NetworkConfig.useLocalServer then 
		GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(kGlobalEvents.kSyncFinished, SyncFinishReason.kNoLocalServer))
		if onCurrentSyncFinish ~= nil then onCurrentSyncFinish() end
		return 
	end

	local function handleCancelSync()
		if animationType == kRequireNetworkAlertAnimation.kSyncLoad then
			if onCurrentSyncError ~= nil then onCurrentSyncError(nil, SyncErrorReason.kCancel) end
		end
		syncCanceled = false 
		self.syncLiteList = {}
		self.afterSyncHttpCachedList = {}
		self.isAfterSyncing = false
		ConnectionManager:resetSyncLock()
	end

	local list = self:getSyncHttpList()
	if list and #list > 0 then
		--animation
		showLoading(animationType)

		--http 
		ConnectionManager:block()
		for i,element in ipairs(list) do
			ConnectionManager:sendRequest( element.endpoint, element.body, onCachedHttpDataResponse )
		end
		
		local function onSyncCallback( endpoint, resp, err )
			self.isSyncing = false

			if syncCanceled then
				handleCancelSync()
				return 
			end

			--hide animation
			removeLoading(animationType, false)

			if err then 
				ConnectionManager:syncFlush()

				he_log_warning("sync data fail, err: " .. err)
				local errorCode = tonumber(err) or -1
				local function onUseLocalFunc(errCode) 
					if _G.isLocalDevelopMode then printx(0, "player choose local data (wrong data)") end 
					if errCode then
						_G.kUserLogin = false
					end
					if onCurrentSyncError ~= nil then onCurrentSyncError(errCode, SyncErrorReason.kSyncFail) end
					self:flushAfterSyncHttp()
				end
				local function onUseServerFunc(data)
					if _G.isLocalDevelopMode then printx(0, "player clear local data") end
					UserManager.getInstance():updateUserData(data)
					UserService.getInstance():updateUserData(data)
					UserService:getInstance():clearCachedHttp()

					if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
					else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end

					if onCurrentSyncFinish ~= nil then onCurrentSyncFinish() end
					GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(kGlobalEvents.kSyncFinished, SyncFinishReason.kSuccess))
					self:flushAfterSyncHttp()
				end
				local logic = SyncExceptionLogic:create(errorCode)
				logic:start(onUseLocalFunc, onUseServerFunc)
		    else 
		    	he_log_info("sync data success")
				-- UserManager.getInstance():updateUserData(resp)
				-- UserService.getInstance():updateUserData(resp)
				UserService.getInstance():clearUsedHttpCache(list)
				-- UserService:getInstance():syncLocal()

				if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
				else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end

				if onCurrentSyncFinish ~= nil then onCurrentSyncFinish() end

				GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(kGlobalEvents.kSyncFinished, SyncFinishReason.kSuccess))
				ConnectionManager:syncFlush()
				self:flushAfterSyncHttp()
			end
		end
		ConnectionManager:sendRequest( "syncEnd", {}, onSyncCallback )
		ConnectionManager:flush()
		ConnectionManager:syncBlock()

		self.isSyncing = true
	else 
		self.isSyncing = false
		if syncCanceled then
			handleCancelSync()
			return 
		end
		--hide animation
		removeLoading(animationType, false)
		self:flushAfterSyncHttp()

		GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(kGlobalEvents.kSyncFinished, SyncFinishReason.kNoDataToUpload)) 
		if onCurrentSyncFinish ~= nil then onCurrentSyncFinish() end
	end
end

--[[
用于标识afterSyncHttp的唯一id
]]
function SyncManager:getAfterSyncHttpId()
	if not self.afterSyncHttpId then
		self.afterSyncHttpId = 0
	end

	self.afterSyncHttpId = self.afterSyncHttpId + 1
	return self.afterSyncHttpId
end

--[[
检查afterSyncHttpCachedList，
如果里面有缓存的请求，则合并发送给后端
]]
function SyncManager:flushAfterSyncHttp()
	printx( 1 , "SyncManager:flushAfterSyncHttp  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~" )
	local list = self.afterSyncHttpCachedList
	if list and #list > 0 then

		local repeatedMap = {}

		for i,element in ipairs(list) do
			if element.allowMergers then
				if not repeatedMap[element.endpoint] then
					repeatedMap[element.endpoint] = {}
				end

				table.insert( repeatedMap[element.endpoint] , element )
			end
		end

		for k,v in pairs(repeatedMap) do
			if v and #v > 0 then
				local element = v[#v]
				element.lastMergersHttp = true
			end
		end

		ConnectionManager:block()

		--local syncSerial = UserService:getInstance():getSyncSerial()

		local requestNum = 0

		for i,element in ipairs(list) do
			local function syncCallback( endpoint, resp, err )
				requestNum = requestNum - 1
				if err then 
					self:clearAllAfterSyncHttp()
					if element.callback and type(element.callback) == "function" then
						element.callback(false , err)
					end
			    else
			    	self:deleteAfterSyncHttp(element)
			    	if element.callback and type(element.callback) == "function" then
			    		element.callback(true , resp)
			    	end
			    	
				end

				if requestNum == 0 then
					-- all Requests calback done
					self.isAfterSyncing = false
					self:__doSyncLiteNexFrame()
				end
			end

			local function sendRequest()
				if type(element.body) == "table" then

					--[[
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
					]]

					if not element.body.cid then
						element.body.cid = self:getAfterSyncHttpId()
					end
				end
				--UserService:getInstance():setSyncSerial(syncSerial)

				ConnectionManager:sendRequest( element.endpoint, element.body, syncCallback )
				requestNum = requestNum + 1
			end

			if element.allowMergers then
				if element.lastMergersHttp then
					sendRequest()
				else
					element.waitingForDelete = true
				end
			else
				sendRequest()
			end
		end
		ConnectionManager:flush()

		self.isAfterSyncing = true
	else
		self.isAfterSyncing = false
		self:__doSyncLiteNexFrame()
	end
end

function SyncManager:clearAllAfterSyncHttp()
	self.afterSyncHttpCachedList = {}
end

function SyncManager:deleteAfterSyncHttp( element )
	local list = self.afterSyncHttpCachedList
	local newlist = {}

	for k,v in ipairs(list) do

		if not v.waitingForDelete then

			if v.endpoint ~= element.endpoint then
				table.insert( newlist , v ) 
			elseif v.body and element.body and v.body.cid ~= element.body.cid then
				table.insert( newlist , v ) 
			end
		end
	end

	self.afterSyncHttpCachedList = newlist
end

--[[
增加一个待发送的请求到afterSyncHttpCachedList的缓存队列里，
afterSyncHttpCachedList缓存队列会在每次sync结束后尝试推送一次
]]
function SyncManager:addAfterSyncHttp( endpoint , body , callback , datas )
	if not datas then datas = {} end
	if not self.afterSyncHttpCachedList then
		self.afterSyncHttpCachedList = {}
	end

	local cacheHttp = {}
	cacheHttp.endpoint = endpoint
	cacheHttp.body = body
	cacheHttp.callback = callback
	cacheHttp.allowMergers = datas.allowMergers or false

	table.insert( self.afterSyncHttpCachedList , cacheHttp )
end

function SyncManager:getSyncHttpList()
	local originList = UserService.getInstance():getCachedHttpData()
	local list = {}
	local syncSerial = UserService:getInstance():getSyncSerial()
	for k, v in ipairs(originList) do
		if type(v.body) == "table" then
			local ss = v.body.seq
			if type(ss) == "number" then
				if type(syncSerial) ~= "number" then
					syncSerial = ss
				elseif v.body.seq > syncSerial then syncSerial = v.body.seq end
			else
				if type(syncSerial) == "number" then
					syncSerial = syncSerial + 1
					v.body.seq = syncSerial
				end
			end
		end
		UserService:getInstance():setSyncSerial(syncSerial)
		table.insert(list, v)
	end
	if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
	else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end
	return list
end

--deprecated
function SyncManager:flushCachedHttp()
	local list = self:getSyncHttpList()
	if list and #list > 0 then
		for i,element in ipairs(list) do
			local function syncCallback( endpoint, resp, err )
				if err then 
					he_log_warning("sync data fail, err: " .. err)
					local errorCode = tonumber(err) or -1
					local function onUseLocalFunc(errCode)
						if errCode then
							_G.kUserLogin = false
						end
					end
					local function onUseServerFunc(data)
						UserManager.getInstance():updateUserData(data)
						UserService.getInstance():updateUserData(data)
						UserService:getInstance():clearCachedHttp()

						if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
						else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end

						GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(kGlobalEvents.kSyncFinished, SyncFinishReason.kSuccess))
					end
					local logic = SyncExceptionLogic:create(errorCode)
					logic:start(onUseLocalFunc, onUseServerFunc)
			    else 
			    	he_log_info("onCachedHttpDataResponse data success")
					UserService.getInstance():clearUsedHttpCache({element})
					if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
					else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end
					if onCurrentSyncFinish ~= nil then onCurrentSyncFinish() end
				end
			end
			ConnectionManager:sendRequest( element.endpoint, element.body, syncCallback )
		end
	end
end
