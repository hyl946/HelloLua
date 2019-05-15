-- Copyright C2009-2015 www.happyelements.com, all rights reserved.
-- Create Date:	2015年10月26日 10:27:57
-- Author:	Reast.Li
-- Email:	reast.li@happyelements.com
---------------------------------------------------
--[[
					MissionPanelLogic

	
	MissionPanelLogic为任务系统视图层的入口类。

	
	任务系统分为三层：
		视图层 - 位于zoo.mission.panels包下，纯视图逻辑，包括UI和动画，
				 入口类为【MissionPanelLogic】
		业务层 - 位于zoo.mission.missionCreator包下，负责封装后端接口，维护本地持久化数据，并根据后端配置执行创建任务的逻辑，
				 入口类为【MissionLogic】
		框架层 - 位于zoo.mission.commonMissionFrame包下，负责将一个业务层的“任务”解析为一组通用的“条件”队列，
				 并在恰当的游戏操作后检测该“条件”的进度是否变更，是否达成。
				 框架层只负责检测任务的进度变更和状态变更（未完成-->已完成）
				 入口类为【MissionManager】

	Wiki地址：http://wiki.happyelements.net/pages/viewpage.action?pageId=20262811

]]
---------------------------------------------------

require "zoo.mission.commonMissionFrame.managers.MissionManager"
require "zoo.mission.panels.MissionMangaPanel"

MissionPanelLogic = {}


function MissionPanelLogic:getMissionBtn()

	if not self.missionBtn then
		self.missionBtn = MissionButton:create()
	end
	
	return self.missionBtn
end

function MissionPanelLogic:onMissionStateChanged(data)
	local position = math.floor(data.missionId / 100000)
	self.missionStateMap[position] = data.newState
end

function MissionPanelLogic:checkAllMissionRewarded(mustBeToday)

	local rewardedNum = 0

	for i = 1 , 4 do
		local missionData = MissionLogic:getInstance():getMissionData(i)
		if missionData then
			if missionData.state == MissionState.kRewarded then
				if mustBeToday then
					local fintime = missionData.finishTime

					if fintime then
						if fintime > 9999999999 then
							fintime = math.floor( fintime / 1000 )
						end

						local nowDate = os.date("%x", Localhost:timeInSec())
						local finishDate = os.date("%x", fintime)
						
						if nowDate == finishDate then
							rewardedNum = rewardedNum + 1
						end
					end
				else
					rewardedNum = rewardedNum + 1
				end
			elseif i == 4 then
				local specialMissionDuration = math.floor( MissionLogic:getInstance():getSpecialMissionDuration() / 1000 )
				local specialMissionCreateTime = missionData.createTime
				if specialMissionCreateTime and specialMissionCreateTime > 0 then
					if specialMissionCreateTime > 9999999999 then
						specialMissionCreateTime = math.floor( specialMissionCreateTime / 1000 )
					end
					if specialMissionCreateTime + specialMissionDuration < Localhost:timeInSec() then
						rewardedNum = rewardedNum + 1
					end
				end
			end
		end
	end
	
	if rewardedNum >= 4 then
		return true
	end

	return false
end

function MissionPanelLogic:tryToUpdateMissionButton()
	printx( 1 , "  MissionPanelLogic:tryToUpdateMissionButton  111")
	if not MaintenanceManager:getInstance():isEnabled("DaliyMission") then
		return
	end


	local missionData = nil
	printx( 1 , "  MissionPanelLogic:tryToUpdateMissionButton  222")
	if self.missionBtn then
		missionData = MissionLogic:getInstance():getMissionData(4)
		printx( 1 , "  MissionPanelLogic:tryToUpdateMissionButton  333")
		if missionData then
			printx( 1 , "  MissionPanelLogic:tryToUpdateMissionButton  444")
			if missionData.state == MissionState.kStart or missionData.state == MissionState.kInProgress then
				self.missionBtn:tryShowTime( MissionLogic:getInstance():getExpireTime(4) )
			else
				self.missionBtn:hideTime()
			end

			if self:checkHasFinishedMission() then
				self.missionBtn:showTip(2)
			else
				self.missionBtn:hideTip()
			end
		end
	end

	if self:checkAllMissionRewarded(false) then
		printx( 1 , "  MissionPanelLogic:tryToUpdateMissionButton  555")
		if self.missionBtn then
			printx( 1 , "  MissionPanelLogic:tryToUpdateMissionButton  666")
			HomeSceneButtonsManager.getInstance():flyToBtnGroupBar( HomeSceneButtonType.kMission , self.missionBtn , 
			function () 
				HomeScene:sharedInstance().leftRegionLayoutBar:removeItem(self.missionBtn)

				if HomeScene:sharedInstance().leftRegionLayoutBar:containsItem(self.missionBtn) then 
					HomeScene:sharedInstance().leftRegionLayoutBar:removeItem(self.missionBtn)
				end
				self.missionBtn:removeAllEventListeners()
				self.missionBtn:dispose()
				self.missionBtn = nil

				HomeScene:sharedInstance().missionBtn = nil
			end , 

			function () 
				--if _G.isLocalDevelopMode then printx(0, table.tostring( HomeSceneButtonsManager.getInstance():getBtnTypeInfoTable() )) end
				HomeSceneButtonsManager.getInstance():setButtonShowPosState(HomeSceneButtonType.kMission, true)
			end )

		else
			printx( 1 , "  MissionPanelLogic:tryToUpdateMissionButton  777")
			HomeSceneButtonsManager.getInstance():setButtonShowPosState(HomeSceneButtonType.kMission, true)
		end

	else
		printx( 1 , "  MissionPanelLogic:tryToUpdateMissionButton  888")
		HomeSceneButtonsManager.getInstance():setButtonShowPosState(HomeSceneButtonType.kMission, false)
		if not self.missionBtn then
			printx( 1 , "  MissionPanelLogic:tryToUpdateMissionButton  999")
			HomeScene:sharedInstance():createMissionButton()
		end
	end
end

function MissionPanelLogic:tryCreateMission( onSuccessCallback , onFailCallback , autoOpenPanel )

	if autoOpenPanel ~= true then autoOpenPanel = false end

	if not MaintenanceManager:getInstance():isEnabled("DaliyMission") then
		return
	end

	local function successCallback()
		if onSuccessCallback then onSuccessCallback() end

		if autoOpenPanel then
			MissionPanelLogic:openPanel()
		end
	end

	local function failCallback()
		if onFailCallback then onFailCallback() end
		--CommonTip:showTip(Localization:getInstance():getText("dis.connect.warning.tips"))
	end

	local function onCallFuncWithLogged()
		MissionLogic:getInstance():iconTapped( successCallback , failCallback , autoOpenPanel )
	end

	RequireNetworkAlert:callFuncWithLogged(
		onCallFuncWithLogged, 
		onCallFuncWithLogged, 
		kRequireNetworkAlertAnimation.kDefault,
		kRequireNetworkAlertTipType.kNoTip
		)
end

function MissionPanelLogic:openPanel(closeCallback)

	if not MaintenanceManager:getInstance():isEnabled("DaliyMission") then
		return
	end

	if self.panel then
		self.panel:onCloseBtnTapped()
		self.panel = nil
	end

	local function onReward(bubblePosition)
		self:onMissionReward(bubblePosition)
	end

	local function onDoMission(bubblePosition)
		self:onDoMission(bubblePosition)
	end

	local function onClose(needShowMange)
		self.panel = nil
		self:tryToUpdateMissionButton()
		local scene = HomeScene:sharedInstance()
		if scene then
			scene:checkDataChange()
			if scene.starButton then scene.starButton:updateView() end
			if scene.energyButton then scene.energyButton:updateView() end
			if scene.coinButton then scene.coinButton:updateView() end
			if scene.goldButton then scene.goldButton:updateView() end
		end

		if needShowMange then
			local mange = MissionMangaPanel:create()
			mange:popout()
		end

		if closeCallback then
			closeCallback()
		end
	end

	local panel = MissionPanel:create(onReward , onDoMission , onClose)
	self.panel = panel

	----[[
	for i = 1 , 4 do
		self:updateMissionByMissionLogicData(i)
	end
	--]]
	local waterLevel = MissionLogic:getInstance().countTotal - MissionLogic:getInstance().countCurrent 
	--if _G.isLocalDevelopMode then printx(0, "WTF FFFFFFFFFFFFFFFFFF     MissionPanelLogic:openPanel     " , waterLevel , MissionLogic:getInstance().countTotal , MissionLogic:getInstance().countCurrent  ) end
	self.panel:setBottleWaveLevel( waterLevel + 1 , true)

	if MissionLogic:getInstance().specialReward then
		local bottleRewards = {}
		for k1,v1 in pairs(MissionLogic:getInstance().specialReward) do
			table.insert( bottleRewards , v1 )
		end
		self.panel:setBottleReward( bottleRewards )
	end
	

	self.panel:popout()

	DcUtil:missionIconTapped()
end

function MissionPanelLogic:createMissionDataByMissionLogicData(positionIndex)
	if not positionIndex or positionIndex < 1 or positionIndex > 4 then
		positionIndex = 1
	end

	local missionData = MissionLogic:getInstance():getMissionData(positionIndex)

	if missionData then

		local rewards = {}

		for k1,v1 in pairs(missionData.extraRewards) do
			table.insert( rewards , {propId=v1.itemId , num=v1.num} )
		end

		for k1,v1 in pairs(missionData.rewards) do
			table.insert( rewards , {propId=v1.itemId , num=v1.num} )
		end

		local dataInfo = {}

		dataInfo.rewards = rewards
		dataInfo.expireTime = MissionLogic:getInstance():getExpireTime(positionIndex)
		dataInfo.finishTime = missionData.finishTime
		dataInfo.createTime = missionData.createTime

		dataInfo.showDoButton = false
		if missionData.doActions and #missionData.doActions > 0 then
			dataInfo.showDoButton = true
		end

		if missionData.progressInfo and missionData.progressInfo[1] then

			dataInfo.currValue = missionData.progressInfo[1].current
			dataInfo.targetValue = missionData.progressInfo[1].total
			dataInfo.des = self:getMissionDes(missionData)
			
		else
			dataInfo.currValue = -1 --小于0将不显示进度条
			dataInfo.targetValue = 0
			dataInfo.des = ""
		end

		return dataInfo
	end

	return nil
end


function MissionPanelLogic:updateMissionByMissionLogicData(positionIndex)

	if not positionIndex or positionIndex < 1 or positionIndex > 4 then
		positionIndex = 1
	end

	local missionData = MissionLogic:getInstance():getMissionData(positionIndex)

	if missionData and self.panel then

		local state = self:getMissionBubbleItemStateByMissionState( missionData.state )

		local dataInfo = self:createMissionDataByMissionLogicData(positionIndex)

		local showAdditionalReward = true

		----[[
		if MissionLogic:getInstance():getExtraRewardFlag(positionIndex) then 
			showAdditionalReward = false 
			MissionLogic:getInstance():setExtraRewardFlag(positionIndex , false)
		end
		--]]

		self.panel:buildMissionItem(
			positionIndex,
			state,
			dataInfo, 
			showAdditionalReward
		)

		if showAdditionalReward == false then 
			
			if missionData.extraRewards and #missionData.extraRewards > 0 then
				local propId = missionData.extraRewards[1].itemId
				self.panel:playAddRewardAnimation(positionIndex , propId , function() end )
			end
			
		end
	end
end

function MissionPanelLogic:getMissionDes(missionData)
	local des = "cannot find text"

	if missionData.progressInfo then

		local textObj = {}
		for k,v in pairs(missionData.progressInfo) do

			textObj["index_" .. k .. "_current"] = tostring(v.current)
			textObj["index_" .. k .. "_total"] = tostring(v.total)

			if v.parameters then
				for k2,v2 in pairs(v.parameters) do
					textObj["index_" .. k .. "_parameters_" .. k2] = tostring(v2)
				end
			end
		end
		des = Localization:getInstance():getText( "mission.missionPanel.item.des_" .. missionData.type , textObj)
		
	else
		des = ""
	end

	return des
end

function MissionPanelLogic:getMissionBubbleItemStateByMissionState(missionState)
	if missionState == MissionState.kWaitForRefresh or missionState == MissionState.kRewarded then
		return MissionBubbleItemState.kRewarded
	elseif missionState == MissionState.kStart or missionState == MissionState.kInProgress then
		return MissionBubbleItemState.kInProgress
	elseif missionState == MissionState.kFinished then
		return MissionBubbleItemState.kDone
	end
end

function MissionPanelLogic:onMissionReward(bubblePosition)
	printx( 1 , "  MissionPanelLogic:onMissionReward  " , bubblePosition)

	local function successCallback()
		
	end	

	local function failCallback()
		CommonTip:showTip(Localization:getInstance():getText("mission.missionPanel.getReward.failed1"), "negative")
	end

	local function cancelCallback()

	end

	MissionLogic:getInstance():getReward({[1]=bubblePosition}, successCallback, failCallback, cancelCallback)
end

function MissionPanelLogic:onDoMission(bubblePosition)
	printx( 1 , "  MissionPanelLogic:onDoMission  " , bubblePosition)

	local missionData = MissionLogic:getInstance():getMissionData(bubblePosition)

	if self.panel then
		self.panel:onCloseBtnTapped()
		self.panel = nil
	end

	if missionData.doActions and #missionData.doActions > 0 then
		--printx( 1 , "  TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT " , table.tostring( missionData.doActions ) )
		MissionActionExecutor:getInstance():doActionByList(missionData.doActions)
	end
end

function MissionPanelLogic:onUpdateMission(positionIndex , oldMissionState)
	printx( 1 , "   MissionPanelLogic:onUpdateMission   " , positionIndex , oldMissionState )

	if not positionIndex then
		return
	end

	local missionData = MissionLogic:getInstance():getMissionData(positionIndex)

	if positionIndex ~= 4 and missionData.state == MissionState.kStart and 
		( oldMissionState == MissionState.kStart or oldMissionState == MissionState.kInProgress ) then
		if self.panel then
			--self.panel:playChangeMissionAnimation(index , newData , callback)
			local newData = self:createMissionDataByMissionLogicData(positionIndex)

			--self:updateMissionByMissionLogicData(positionIndex)
			self.panel:playChangeMissionAnimation(positionIndex , newData , function () end)
		end
	else
		self:updateMissionByMissionLogicData(positionIndex)
	end
end

function MissionPanelLogic:onMissionProgressChanged(data)
	--{position = math.floor(data.missionId / 100000),id = mission.id, index = data.extendInfo, current = data.newValue, total = data.targetValue}
	printx( 1 , "   MissionPanelLogic:onMissionProgressChanged   " , data.position , data.current , data.total )
	if data and self.panel then
		self.panel:updateProgress( data.position , data.current , data.total )
	end
end

function MissionPanelLogic:onMissionRewardEvent(positionIndex , newBottleReward , bottleCurr , bottleTotal )
	printx( 1 , "   MissionPanelLogic:onMissionRewardEvent   " , positionIndex , newBottleReward , bottleCurr , bottleTotal )
	if self.panel then
		local dataInfo = self:createMissionDataByMissionLogicData(positionIndex)
		self.panel:playGetMissionRewardAnimation(positionIndex , dataInfo , newBottleReward , bottleCurr , bottleTotal , function () end)
	end
end

function MissionPanelLogic:onTankProgress(waterLevel)
	printx( 1 , "   MissionPanelLogic:onTankProgress   " , waterLevel )
	if self.panel then
		self.panel:playBottleAnimation(waterLevel , function () end)
	end
end

function MissionPanelLogic:init(missionLogic)
	self.missionLogic = missionLogic


	local function onMissionStartEvent(evt)
		if evt.data then
			self:onUpdateMission(evt.data.index , evt.data.oldMissionState)
		end

		self:tryToUpdateMissionButton()
	end

	local function onMissionProgressEvent(evt)
		self:onMissionProgressChanged(evt.data)
	end

	local function onMissionStateEvent(evt)
		if evt.data then
			self:onUpdateMission(evt.data.position , -1)

			if evt.data.state == MissionState.kFinished then
				if self.missionBtn then
					--self.missionBtn:showTip()
					IconButtonManager:getInstance():clearShowTime(self.missionBtn)
					self.missionBtn:showTip(2)
				end
				
				if evt.data.position == 4 then

					if self.panel then
						
					end

					if self.missionBtn then
						self.missionBtn:hideTime()
					end
				end
			end
		end
	end

	local function onMissionExpiredEvent(evt)
		if evt.data then
			setTimeOut( function () 
				self:onUpdateMission(evt.data.index , -1) 
				if MissionManager then
					local triggerContext = TriggerContext:create(TriggerContextPlace.ANY_WHERE)
					MissionManager:getInstance():checkAll(triggerContext)
				end
				end , 0.1)
		end
	end

	local function onMissionRewardEvent(evt)
		--to do  
		--处理多次连续领奖，使用evt.data.extraTankRewards判断
		if evt.data then
			self:onMissionRewardEvent(
				evt.data.index , 
				evt.data.tankNextTankRewards , 
				evt.data.tankCurrent , 
				evt.data.tankTotal)
		end
	end

	local function onTankStartEvent()
		
	end

	local function onTankProgressEvent(evt)
		--self:onTankProgress()
	end

	local function onTankRewardEvent()
		
	end

	local function onMissionRefreshEvent()
		self:tryToUpdateMissionButton()
	end

	local function onMissionCreateFailEvent(evt)

		if evt and evt.data and self.panel then

			local list = evt.data.missionPositions

			for k,v in pairs(list) do
				if evt.data.errorId == 1 then
					self.panel:setMissionItemDoneDes(v,3) -- 没有网络
				elseif evt.data.errorId == 2 then
					self.panel:setMissionItemDoneDes(v,6)--后端校验失败
				elseif evt.data.errorId == 3 then
					self.panel:setMissionItemDoneDes(v,5)--前端创建失败
				end
			end
			
		end
	end

	local function onMissionRewardFailEvent(evt)
		if evt and evt.data and self.panel then

			local list = evt.data.missionPositions

			if list then
				for k,v in pairs(list) do
					CommonTip:showTip(Localization:getInstance():getText("mission.missionPanel.getReward.failed"), "negative")
				end
			end
			
		end
	end

	self.missionLogic:addEventListener(
		MissionLogicEvents.kMissionStart, onMissionStartEvent, self.missionLogic)

	self.missionLogic:addEventListener(
		MissionLogicEvents.kMissionProgress, onMissionProgressEvent, self.missionLogic)

	self.missionLogic:addEventListener(
		MissionLogicEvents.kMissionState, onMissionStateEvent, self.missionLogic)

	self.missionLogic:addEventListener(
		MissionLogicEvents.kMissionExpired, onMissionExpiredEvent, self.missionLogic)

	self.missionLogic:addEventListener(
		MissionLogicEvents.kMissionReward, onMissionRewardEvent, self.missionLogic)

	self.missionLogic:addEventListener(
		MissionLogicEvents.kTankStart, onTankStartEvent, self.missionLogic)

	self.missionLogic:addEventListener(
		MissionLogicEvents.kTankProgress, onTankProgressEvent, self.missionLogic)

	self.missionLogic:addEventListener(
		MissionLogicEvents.kTankReward, onTankRewardEvent, self.missionLogic)

	self.missionLogic:addEventListener(
		MissionLogicEvents.kMissionRefresh, onMissionRefreshEvent, self.missionLogic)

	self.missionLogic:addEventListener(
		MissionLogicEvents.kMssionCreateFail, onMissionCreateFailEvent, self.missionLogic)

	self.missionLogic:addEventListener(
		MissionLogicEvents.kMssionRewardFail, onMissionRewardFailEvent, self.missionLogic)
	

end

function MissionPanelLogic:checkManga()

	if UserManager.getInstance().user:getTopLevelId() < MissionLogic:getInstance():getMissionUserNeedLevel() then
		return false
	end

	local userDefault = CCUserDefault:sharedUserDefault()
	local configKey = "mission.userconfig.showManga"
	
	if not userDefault:getBoolForKey(configKey) then

		userDefault:setBoolForKey(configKey, true) 
		userDefault:flush()

		local mange = MissionMangaPanel:create()

		--PopoutManager:sharedInstance():add(mange, true, false , HomeScene:sharedInstance())
		mange:popout()
		return true
	end

	return false
end

function MissionPanelLogic:checkHasFinishedMission()
	for i = 1 , 4 do
		local missionData = MissionLogic:getInstance():getMissionData(i)

		if missionData.state == MissionState.kFinished then
			return true
		end
	end

	return false
end