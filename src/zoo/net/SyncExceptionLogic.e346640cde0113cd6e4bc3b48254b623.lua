---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2016-08-10 10:26:04
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   dan.liang
-- @Last Modified time: 2019-03-04 19:17:12
---------------------------------------------------------------------------------------
require "zoo.net.UserBanLogic"

SyncExceptionLogic = class()

local kMinDisplayTime = 3

function SyncExceptionLogic:ctor( ... )
	self.errorCode = -1
end

function SyncExceptionLogic:create(errorCode)
	local logic = SyncExceptionLogic.new()
	logic.errorCode = tonumber(errorCode) or -1
	return logic
end

function SyncExceptionLogic:start( useLocalCallback, useServerCallback, animationType, isNoClose )
	local function onUseLocalFunc()
		if self.errorCode == 109 then
			if __ANDROID then
				require "zoo.platform.VivoPlatform"
				VivoPlatform:onEnd()
			end
			CCDirector:sharedDirector():endToLua()
			return
		end
		if useLocalCallback then useLocalCallback() end
	end

	local function onUseServerFunc()

		
		self:uploadLocalLevelInfo()


		local function syncDataSuccess(data)
			if useServerCallback then useServerCallback(data) end
			-- 关卡内出错选择修复直接退出关卡
			local runningScene = Director.sharedDirector():getRunningScene()
			if runningScene and type(runningScene.forceQuitPlay) == "function" then
				runningScene:forceQuitPlay()
			else
				if GamePlayContext then
					GamePlayContext:getInstance().syncExceptionOccur = true
				end
			end
		end

		local function syncDataError(errorCode)
			if useLocalCallback then useLocalCallback(errorCode) end
		end
		self:syncDataWithRetry(syncDataSuccess, syncDataError, animationType)
	end

	local function checkBanCallback( result , datas )
		if result and datas then
			local panel = UserBanPanel:create( UserBanLogic.onCloseGame , UserBanLogic.onContact , datas )
			if panel then panel:popout() end
		else
			if self.errorCode > 10 then
				local panel = ExceptionPanel:create(self.errorCode, onUseLocalFunc, onUseServerFunc, isNoClose)
				panel:setAlertEnable(false, true)
				if panel then panel:popout() end 
				-- require "zoo.gamePlay.ReplayDataManager"
				-- ReplayDataManager:deletLastCrashReplay()
			else
				if useLocalCallback then useLocalCallback() end
			end
		end
	end

	require "zoo.gamePlay.ReplayDataManager"
	ReplayDataManager:deletLastCrashReplay()

	UserBanLogic:checkBan(self.errorCode, checkBanCallback)
end

function SyncExceptionLogic:syncDataWithRetry( onSyncDataFinish, onSyncDataError, animationType, retryTimes )
	retryTimes = retryTimes or 1
	retryTimes = retryTimes - 1
	local function finishCallback(data)
		if onSyncDataFinish then onSyncDataFinish(data) end
		CommonTip:showTip(localize("exception.panel.commit.tips"), 'positive', nil, 2)
	end

	local function errorCallback(errorCode)
		if retryTimes > 0 then
			local function onUseLocalFunc()
				if onSyncDataError then onSyncDataError() end
			end
			local function onUseServerFunc()

				self:uploadLocalLevelInfo()


				self:syncDataWithRetry(onSyncDataFinish, onSyncDataError, animationType, retryTimes)
			end
			local panel = ExceptionPanel:create(errorCode, onUseLocalFunc, onUseServerFunc)
			panel:setAlertEnable(true, true)
			if panel then panel:popout() end
			CommonTip:showTip(localize("error.tip.synchronize.1"), 'negative', nil, 2)
		else
			if onSyncDataError then onSyncDataError(errorCode) end
			CommonTip:showTip(localize("error.tip.synchronize.2"), 'negative', nil, 2)
		end
	end
	self:syncData(finishCallback, errorCallback, animationType)
end

function SyncExceptionLogic:syncData(onCurrentSyncFinish, onCurrentSyncError, animationType)
	local container
	local syncCanceled = false

	if animationType ~= kRequireNetworkAlertAnimation.kNoAnimation then
		if animationType == kRequireNetworkAlertAnimation.kSync then
			container = CountDownAnimation:createSyncAnimation()
		else
			container = CountDownAnimation:createNetworkAnimation(
								Director:sharedDirector():getRunningScene(),
								function() 
									syncCanceled = true
									container:removeFromParentAndCleanup(true)
								end,
								"正在为您同步关卡数据，请稍候"
						)
		end

		if self.container then self.container:removeFromParentAndCleanup(true) end
		self.container = container
	end
	local beginTime = os.clock()

	local function onSyncCallback( endpoint, resp, err )
		if syncCanceled then
			return
		end

	 	local delayTime = 0
		local deltaTime = os.clock() - beginTime
		if deltaTime < kMinDisplayTime then delayTime = kMinDisplayTime - deltaTime end
		if container then
			if container.hide then
				container:hide(delayTime)
			else
				container:removeFromParentAndCleanup(true)
			end
		end
		self.container = nil

		if err then 
			he_log_warning("sync data fail again, err: " .. err)
			local errorCode = tonumber(err) or -1
			if onCurrentSyncError then onCurrentSyncError(errorCode) end
	    else 
			if onCurrentSyncFinish then onCurrentSyncFinish(resp) end
		end
	end
	ConnectionManager:sendRequest( "syncData", {}, onSyncCallback )
end

function SyncExceptionLogic:uploadLocalLevelInfo( ... )

		
	local httpDataFromStorage = {}
	local scoresDataFromStorage = {}

	local cachedLocalUserData = Localhost.getInstance():readCurrentUserData()
	if (cachedLocalUserData and cachedLocalUserData.user == nil) or cachedLocalUserData == nil then
		cachedLocalUserData = Localhost.getInstance():readUserDataByUserID(_G.kDeviceID)
	end
	if cachedLocalUserData and cachedLocalUserData.user and cachedLocalUserData.user.user then
		httpDataFromStorage = cachedLocalUserData.user.httpData or {}
		scoresDataFromStorage = cachedLocalUserData.user.scores or {}
	end	


    local cachedPassLevelHttps = table.filter(httpDataFromStorage, function ( v )
    	return v.endpoint == kHttpEndPoints.passLevel
    end) or {}

    local exceptionalLevelIds = table.map(function ( v )
    	if v and v.body then
    		return tostring(v.body.levelId)
    	end
    end, cachedPassLevelHttps) or {}

    exceptionalLevelIds = table.unique(exceptionalLevelIds)

    local exceptionalScores = table.filter(scoresDataFromStorage, function ( v )
		return table.exist(exceptionalLevelIds, tostring(v.levelId))
	end) or {}

    local levelInfo = table.map(function ( v )
		return {
			levelId = v.levelId,
			star = v.star,
			score = v.score,
		}
	end, exceptionalScores) or {}

    if #levelInfo > 0 then
		HttpBase:post('levelAbnormal', {
			levelInfo = levelInfo,
		})
	end
end