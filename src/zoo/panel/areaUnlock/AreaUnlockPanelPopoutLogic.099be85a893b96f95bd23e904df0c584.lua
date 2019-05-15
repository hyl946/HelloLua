AreaUnlockPanelPopoutLogic = class()
require "zoo.panel.areaUnlock.AreaUnlockPanel"
require "zoo.panel.areaUnlock.FriendUnlockPanel"


function AreaUnlockPanelPopoutLogic:checkPopoutPanel(curCloud, unlockFinishCallback, failCallback)
	-- printx(4, "aaaaa--------------------------0")
	local function onSuccessCallback()
	-- printx(4, "aaaaa--------------------------2")
		local function onOpeningAnimFinished()
			local runningScene = HomeScene:sharedInstance()
			runningScene:checkDataChange()
			runningScene.starButton:updateView()
			runningScene.goldButton:updateView()
			runningScene.worldScene:onAreaUnlocked(curCloud.id)
			HomeScene:sharedInstance():updateModuleNoticeBtn()
			if unlockFinishCallback then
				unlockFinishCallback()
			end
		end
		curCloud:removeAllEventListeners()
		curCloud:changeState(LockedCloudState.OPENING, onOpeningAnimFinished)
		local lockedCloudCacheDatas = HomeScene:sharedInstance().worldScene.lockedCloudCacheDatas
		if lockedCloudCacheDatas then
			table.remove( lockedCloudCacheDatas , 1 )
		end
		HomeScene:sharedInstance().worldScene:checkAndUpdateUnlockTipView()
		Notify:dispatch("AutoPopoutEventAwakenAction", AreaUnlockPanelPopoutAction)
	end

	local function onFailCallback(errorCode)
	-- printx(4, "aaaaa--------------------------3")
		CommonTip:showTip(Localization:getInstance():getText("unlock.cloud.help.text7"), "negative")
		if failCallback then
			failCallback()
		end
		Notify:dispatch("AutoPopoutEventAwakenAction", AreaUnlockPanelPopoutAction)
	end

	local function onHasNotEnoughStarCallback(userTotalStar, neededStar)
	-- printx(4, "aaaaa--------------------------4")
		AreaUnlockPanelPopoutLogic:__checkPopoutPanel(curCloud, onSuccessCallback, onFailCallback, userTotalStar, neededStar)
	end

	Notify:dispatch("AutoPopoutEventWaitAction", AreaUnlockPanelPopoutAction)

	-- printx(4, "aaaaa--------------------------1")
	local unlockLevelAreaLogic = UnlockLevelAreaLogic:create(curCloud.id)
	unlockLevelAreaLogic:setOnSuccessCallback(onSuccessCallback)
	unlockLevelAreaLogic:setOnFailCallback(onFailCallback)
	unlockLevelAreaLogic:setOnHasNotEnoughStarCallback(onHasNotEnoughStarCallback)
	unlockLevelAreaLogic:start(UnlockLevelAreaLogicUnlockType.USE_STAR, {})	-- Dafult Show COmmunicating Tip And Block The Input
	HomeScene:sharedInstance().worldScene:removeUnlockCloudTipHand()
end

function AreaUnlockPanelPopoutLogic:__checkPopoutPanel(curCloud, onSuccessCallback, onFailCallback, userTotalStar, neededStar)
	local function closeBtnCallback()
		HomeScene:sharedInstance().worldScene:checkAndUpdateUnlockTipView()
	end

	local function onHttpFinished()
		local inUnlockLogic = AreaUnlockPanelPopoutLogic:checkUnlockByFriend(curCloud, onSuccessCallback, onFailCallback)
		if not inUnlockLogic then
			inUnlockLogic = AreaUnlockPanelPopoutLogic:checkUnlockByTime(curCloud, onSuccessCallback, onFailCallback)
		end
		if not inUnlockLogic then
			inUnlockLogic = AreaUnlockPanelPopoutLogic:checkUnlockByBindSNS(curCloud, onSuccessCallback, onFailCallback)
		end
		if not inUnlockLogic then
			-- AreaUnlockPanel:create(curCloud.id, userTotalStar, neededStar, onSuccessCallback , closeBtnCallback , closeBtnCallback)
			Notify:dispatch("QuitNextLevelModeEvent")
			
			local para = {
				cloudId = curCloud.id,
				star = userTotalStar,
				neededStar = neededStar,
				onSuccess = onSuccessCallback,
				closeCb = closeBtnCallback,
			}
			Notify:dispatch("AutoPopoutEventAwakenAction", AreaUnlockPanelPopoutAction, para)
		else
			Notify:dispatch("AutoPopoutEventAwakenAction", AreaUnlockPanelPopoutAction)
		end
	end

	onHttpFinished()
	local http = GetUnlockFriendHttp.new()
	http:addEventListener(Events.kComplete, function () end) --不再等回调，永远用就数据，本次更新的数据，下次打开面板生效
	http:load()
	HomeScene:sharedInstance():updateFriends()
	HomeScene:sharedInstance().worldScene:checkAndUpdateUnlockTipView()
end

function AreaUnlockPanelPopoutLogic:checkUnlockByFriend(curCloud, onSuccessCallback, onFailCallback)--三个好友直接解锁
	local friendList = UserManager:getInstance():getUnlockFriendUidsWithNPC(curCloud.id)
	if #friendList >= 3 then

		local function onPanelFinish()
			local logic = UnlockLevelAreaLogic:create(curCloud.id)
			logic:setOnSuccessCallback(onSuccessCallback)
			logic:setOnFailCallback(onFailCallback)
			local fixIds = {}
			for i = 1 , #friendList do
				if tostring(friendList[i]) ~= "-1" then
					table.insert( fixIds , tonumber(friendList[i]) )
				end
			end
			if #fixIds < 3 then
				local datas = {}
				datas.npc = UserManager:getInstance():getUnlockNPCFriendNumber(curCloud.id)
				logic:start(UnlockLevelAreaLogicUnlockType.USE_SIM_FRIEND, fixIds , nil , datas )
			else
				logic:start(UnlockLevelAreaLogicUnlockType.USE_FRIEND, fixIds)
			end
		end
		FriendUnlockPanel:create(curCloud.id, onPanelFinish):popout()

		return true
	end 

	return false
end

function AreaUnlockPanelPopoutLogic:checkUnlockByTime(curCloud, onSuccessCallback, onFailCallback)--倒计时够直接解锁
	if UserManager:getInstance():canUnlockAreaByTime(curCloud.id) then 
		local logic = UnlockLevelAreaLogic:create(curCloud.id)
		logic:setOnSuccessCallback(onSuccessCallback)
		RequireNetworkAlert:callFuncWithLogged(function( ... )
				logic:setOnFailCallback(onFailCallback)
			end,
			function( ... )
			end,
			function( ... )
			end)
		logic:start(UnlockLevelAreaLogicUnlockType.TIME_UNLOCK, {})
		return true
	end

	return false
end

function AreaUnlockPanelPopoutLogic:checkUnlockByBindSNS(curCloud, onSuccessCallback, onFailCallback)--根据绑定账号解锁，上次绑定重启游戏 缓存到本地的数据
	local topLevel = UserManager:getInstance().user:getTopLevelId()
	local currAreaId = MetaManager.getInstance():getLevelAreaRefByLevelId(topLevel).id
	local localData = Localhost:readUnlockLocalInfo()
	local unlockByBindSNSLogic = require "zoo.panel.areaUnlock.CompBindSNS"
	local singleAuth = unlockByBindSNSLogic:getSNSAuth()
	local profile = UserManager:getInstance().profile
	if localData then --已成功绑定帐号直接解锁
		if tonumber(localData.lastBindAreaId) == tonumber(curCloud.id) then
			local bound = false
			if localData.lastBindSnsType == PlatformAuthEnum.kQQ and profile and profile:isQQBound() then
				bound = true
			end
			if localData.lastBindSnsType == PlatformAuthEnum.kPhone and profile and profile:isPhoneBound() then
				bound = true
			end
			if bound then
				local logic = UnlockLevelAreaLogic:create(curCloud.id)
				logic:setOnSuccessCallback(onSuccessCallback)
				logic:setOnFailCallback(onFailCallback)
				local authDetail = PlatformAuthDetail[localData.lastBindSnsType]
				localData.lastBindSnsType = 0
				localData.lastBindAreaId = 0
				Localhost:saveUnlockLocalInfo( localData )
				if authDetail and authDetail.name then
					local datas = {}
					datas.auth = authDetail.name
					logic:start(UnlockLevelAreaLogicUnlockType.USE_SNS, nil , nil , datas)
				end
				return  true--已成功绑定帐号直接解锁
			end
		end
	end

	return false
end

function AreaUnlockPanelPopoutLogic:localDataCorrect()
	local topLevel = UserManager:getInstance().user:getTopLevelId()
	if topLevel ~= nil and topLevel > 0 then
		local curAreaData =  MetaManager.getInstance():getLevelAreaRefByLevelId(topLevel)
		if not UserManager:getInstance():hasPassedLevel(curAreaData.maxLevel)--当前区域最高关卡没有通过
		   		and UserManager:getInstance():getUserJumpLevelRef(curAreaData.maxLevel) == nil  then--当前区域最高关卡没有跳关
		   	if Localhost:readDataByFileNameAndKey(AreaUnlockPanel.LOCAL_DATA_FILE, "area_" .. curAreaData.id .. "_unlock_time", 0) > 0 then
				Localhost:writeDataByFileNameAndKey(AreaUnlockPanel.LOCAL_DATA_FILE, "area_" .. curAreaData.id .. "_unlock_time", 0)
				Localhost:writeDataByFileNameAndKey(AreaUnlockPanel.LOCAL_DATA_FILE, "area_" .. curAreaData.id .. "_time_cycle", nil)
			end
	    end
	end
end

