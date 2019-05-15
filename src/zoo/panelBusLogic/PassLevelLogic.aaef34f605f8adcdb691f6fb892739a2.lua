
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年11月13日 11:39:38
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

require "zoo.panelBusLogic.AdvanceTopLevelLogic"
require "zoo.panelBusLogic.UpdateLevelScoreLogic"

---------------------------------------------------
-------------- PassLevelLogic
---------------------------------------------------

assert(not PassLevelLogic)
PassLevelLogic = class()

function PassLevelLogic:init(levelId, score, star, stageTime, coin, targetCount, opLog, levelType, costMove, extraData, onSuccessCallback, safeFlag, levelSeed, strategy, senderUid, initAdjustData, strategyInfo, guideLevel, DataEx, ...)
	assert(type(levelId)		== "number")
	assert(type(score)		== "number")
	assert(type(star)		== "number")
	assert(type(stageTime)		== "number")
	assert(type(coin)		== "number")
	assert(type(costMove)		== "number")
	-- assert(type(onSuccessCallback)	== "function")
	assert(#{...} == 0)

	self.levelId	= levelId
	self.score	= score
	self.star	= star
	self.stageTime	= stageTime
	self.coin	= coin
	self.targetCount = targetCount
	self.opLog = opLog
	self.costMove = costMove
	self.extraData = extraData
	self.safeFlag = safeFlag

	self.levelType = levelType

	self.onSuccessCallback	= onSuccessCallback

	self.levelSeed = levelSeed
	self.strategy = strategy

	self.senderUid = senderUid		-- 代打的Uid
	self.initAdjustData = initAdjustData
	self.strategyInfo = strategyInfo
	self.extraRewards = {}

	if self.levelType == GameLevelType.kSummerWeekly then
		if self.targetCount > 0 then 
			if SeasonWeeklyRaceManager:getInstance().lottery and SeasonWeeklyRaceManager:getInstance().lottery.boxRewards then
				local boxRewards = SeasonWeeklyRaceManager:getInstance().lottery.boxRewards
				if boxRewards then
					for _, v in pairs(boxRewards) do
						table.insert(self.extraRewards , {itemId = v.id ,num = v.num}) 
					end
				end
			end
		end
	end

	self.guideLevel = guideLevel
    self.DataEx = DataEx
end

function PassLevelLogic:start(...)
	assert(#{...} == 0)

	local topLevelOld = UserManager:getInstance().user:getTopLevelId()
    local TopPassLevelOldId = UserManager:getInstance():getTopPassedMainLevelId()

	local function onSendMsgSuccess(rewardItems, buffUpgrade)

		-- Record Passed Level
		UserManager:getInstance().lastPassedLevel = self.levelId


		-----------------------
		-- Update Level Score
		-- ---------------------
		local updateLevelScoreLogic = UpdateLevelScoreLogic:create(self.levelId, self.levelType, self.score, self.star)
		updateLevelScoreLogic:start()

		-- ------------------------------------
		-- Check If It's A New Completed Level
		-- ----------------------------------
		local levelAreaOpenedId = UserManager:getInstance().levelAreaOpenedId

		local advanceTopLevelLogic = AdvanceTopLevelLogic:create(self.levelId)
		advanceTopLevelLogic:start()

		local topLevelNew = UserManager:getInstance().user:getTopLevelId()
		UserManager:getInstance().justPassedTopLevel = topLevelNew>topLevelOld or levelAreaOpenedId ~= UserManager:getInstance().levelAreaOpenedId

        --add by zhigang.niu
        --首次通关最高关卡
        local TopPassLevelId = UserManager:getInstance():getTopPassedMainLevelId()
        local configTopLevel, topAdjustY = NewAreaOpenMgr.getInstance():getCanPlayTopLevel()
        if TopPassLevelOldId~=TopPassLevelId and TopPassLevelId == configTopLevel and self.star < 3 then
            UserManager:getInstance().justPassedRealTopLevelAndNotFullStar = true
        end

		if self.levelType == GameLevelType.kSummerWeekly then
			SeasonWeeklyRaceManager:getInstance():onPassLevel(self.levelId, self.targetCount)
		elseif self.levelType == GameLevelType.kMoleWeekly then

			local tc0, tc1 = string.match(self.targetCount, '(%d+),(%d+)')
			tc0 = tonumber(tc0) or 0
			tc1 = tonumber(tc1) or 0

			RankRaceMgr:getInstance():onPassLevel(self.levelId, self.star, tc0, tc1)
		end

		--------------
		-- Callback 
		-- -----------
		if self.onSuccessCallback then
			self.onSuccessCallback(self.levelId, self.score, rewardItems, buffUpgrade)
		end

		SyncManager:getInstance():sync()
		UserTagManager:refreshDifficultyTag( self.levelId , nil , UserTagDCSource.kPassLevel )

		--触发通过版本最高关卡
		if self.levelId == MetaManager:getInstance():getMaxNormalLevelByLevelArea()
		and UserManager:getInstance().user:getTopLevelId() >= 60 then
			GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(MessageCenterPushEvents.kPassMaxNormalLevel))
		end
		-- test
		-- if __WIN32 then
		local levelMeta = LevelMapManager:getMeta(self.levelId)
		local nation_score_config = {levelMeta.score3, levelMeta.score3*1.2, levelMeta.score3*1.5, levelMeta.score3*2}
		local nation_level_config = {60, 180, 300, 420}

		if self.levelType == GameLevelType.kMoleWeekly then
			local tc0, tc1 = string.match(self.targetCount, '(%d+),(%d+)')
			tc0 = tonumber(tc0) or 0
			tc1 = tonumber(tc1) or 0
			if tc0 > 0 then
				ShareManager:onPassLevel(self.levelId, self.score, self.levelType, self.star, nation_level_config, nation_score_config)
				InciteManager:onPassLevel()
			end
		elseif self.levelType ~= GameLevelType.kSummerWeekly or (tonumber(self.targetCount) or 0) > 0 then
			ShareManager:onPassLevel(self.levelId, self.score, self.levelType, self.star, nation_level_config, nation_score_config)
			InciteManager:onPassLevel()
		end

		LocalNotificationManager.getInstance():setPassLevelFlag(self.levelId, self.star, self.score)
	end

	self:sendPassLevelMessage(onSendMsgSuccess)
	ProductItemDiffChangeLogic:endLevel()
	GameInitDiffChangeLogic:endLevel()
	GameInitBuffLogic:endLevel()
end

function PassLevelLogic:sendPassLevelMessage(onSuccessCallback, ...)
	assert(type(onSuccessCallback) == "function")
	assert(#{...} == 0)

	local levelId	= self.levelId
	local score	= self.score
	local star	= self.star
	local stageTime	= self.stageTime
	local coin	= self.coin
	local targetCount = self.targetCount
	local opLog = self.opLog
	local costMove = self.costMove or 0

	local function onPassLevelMsgSuccess(event)
		assert(event)
		assert(event.name == Events.kComplete)
		assert(event.data)
		--重置推送召回活动关卡卡最高关卡状态 这个调用  一定要在onSuccessCallback之前 否则最高关卡会变动 导致流失状态无法重置
		if RecallManager.getInstance():getRecallLevelState(levelId) then
			RecallManager.getInstance():resetRecallRewardState()
		end

		local buffUpgrade = PreBuffLogic:onPassLevel(levelId, star, self.guideLevel , true)

		local rewardItems = event.data

		CollectStarsManager.getInstance():onPassLevelMsgSuccess( levelId ,star)
		
		-- Call Callback
		onSuccessCallback(rewardItems, buffUpgrade)
	end

	local function onPassLevelMsgFailed()
		assert(false)
	end

	local initAdjustStr = GameInitDiffChangeLogic:createVirtualSeedDataStr( self.initAdjustData )

    local isGiveUp = false

	local http = PassLevelHttp.new()
	http:addEventListener(Events.kComplete, onPassLevelMsgSuccess)
	http:addEventListener(Events.kError, onPassLevelMsgFailed)

	local levelMeta = LevelMapManager.getInstance():getMeta( levelId )
	local staticStep = -1
	if levelMeta and levelMeta.gameData and levelMeta.gameData.moveLimit then
		staticStep = tonumber( levelMeta.gameData.moveLimit )
	end

	if star < 1 and staticStep and staticStep > 0 and (staticStep - costMove) / staticStep < 0.2 then
		http.logicalFail = true
	end

	http:load(levelId, score, star, stageTime, coin, targetCount, opLog, self.levelType, costMove, self.extraData, self.safeFlag , self.levelSeed , self.strategy , initAdjustStr, self.strategyInfo, self.extraRewards, self.guideLevel, isGiveUp, self.DataEx )
end

function PassLevelLogic:create(levelId, score, star, stageTime, coin, targetCount, opLog, levelType, costMove, extraData, onSuccessCallback, safeFlag, levelSeed, strategy, senderUid, initAdjustData, strategyInfo, guideLevel, DataEx,...)
	assert(type(levelId)	== "number")
	assert(type(score)	== "number")
	assert(type(star)	== "number")
	assert(type(stageTime)	== "number")
	assert(type(coin)	== "number")
	assert(type(costMove)	== "number")
	-- assert(type(onSuccessCallback)	== "function")
	assert(#{...} == 0)

	local newPassLevelLogic = PassLevelLogic.new()
	newPassLevelLogic:init(levelId, score, star, stageTime, coin, targetCount, opLog, levelType, costMove, extraData, onSuccessCallback, safeFlag, levelSeed, strategy, senderUid , initAdjustData, strategyInfo, guideLevel, DataEx )
	return newPassLevelLogic
end

function PassLevelLogic:sendPassLevelMessageOnly(levelId, levelType, stageTime, costMove, extraData , seed , strategy , initAdjustData, guideLevel, isGiveUp)
	local http = PassLevelHttp.new()
	local function onPassLevelMsgSuccess(event)
		SyncManager:getInstance():sync()
		UserTagManager:refreshDifficultyTag( levelId , nil , UserTagDCSource.kPassLevel )
		PreBuffLogic:onPassLevel(levelId, 0, guideLevel , false , "quit")

		local updateLevelScoreLogic = UpdateLevelScoreLogic:create(levelId, levelType, 0, 0)
		updateLevelScoreLogic:start()
	end
	local function onPassLevelMsgFailed(event)
	end
	http:addEventListener(Events.kComplete, onPassLevelMsgSuccess)
	http:addEventListener(Events.kError, onPassLevelMsgFailed)

	local initAdjustStr = GameInitDiffChangeLogic:createVirtualSeedDataStr( initAdjustData )

	local levelMeta = LevelMapManager.getInstance():getMeta( levelId )
	local staticStep = -1
	if levelMeta and levelMeta.gameData and levelMeta.gameData.moveLimit then
		staticStep = tonumber( levelMeta.gameData.moveLimit )
	end

	if staticStep and staticStep > 0 and (staticStep - costMove) / staticStep < 0.2 then
		http.logicalFail = true
	end

	http:load(levelId, 0, 0, stageTime, 0, 0, nil, levelType, costMove, extraData , nil , seed , strategy , initAdjustStr, nil, nil, guideLevel, isGiveUp)
	InciteManager:onPassLevel()

	ProductItemDiffChangeLogic:endLevel()
	GameInitDiffChangeLogic:endLevel()
	GameInitBuffLogic:endLevel()
end

----------------------------------------------------------------------------------------------------
function PassLevelLogic:startAFH(...)
	assert(#{...} == 0)
    local needShowOff = false

	local function onSendMsgSuccess(rewardItems)

		if self.levelType == GameLevelType.kSummerWeekly then
			SeasonWeeklyRaceManager:getInstance():onPassLevel(self.levelId, self.targetCount)
		elseif self.levelType == GameLevelType.kMoleWeekly then
			local tc0, tc1 = string.match(self.targetCount, '(%d+),(%d+)')
			tc0 = tonumber(tc0) or 0
			tc1 = tonumber(tc1) or 0
			RankRaceMgr:getInstance():onPassLevel(self.levelId, self.star, tc0, tc1)
		end

		if self.onSuccessCallback then
			self.onSuccessCallback(self.levelId, self.score, rewardItems)
		end

		SyncManager:getInstance():sync()

		local asfMgr = AskForHelpManager:getInstance()
		local doneeUid = asfMgr:getDoneeUId()
		asfMgr:onHelpOtherFinished(doneeUid, true)

		if needShowOff then
			-- add a headframe
			local mgrInst = AskForHelpManager:getInstance()
			mgrInst:incHelpedSuccessCount()
			if mgrInst:hasNewHeadFrame() then
				rewardItems[1] = 1
				local delta = mgrInst:getHeadFrameDur() 
				local profile = UserManager.getInstance().profile
				local headframe = profile.headFrame or 0

				HeadFrameType:setProfileContext(nil):addHeadFrame(HeadFrameType.kASF, delta * 1000)
			end

			-- showoff
			local function onShareFinished()
				AskForHelpManager:getInstance():leaveMode()
				Director:sharedDirector():popScene()

			    HeadFrameType:checkShowHeadFrameGotPanel()
			end
			local PassLevelShowOff = require('zoo.panel.askForHelp.views.PassLevelShowOff')
			PassLevelShowOff:create(doneeUid, self.levelId, rewardItems, onShareFinished):popout()
		else
			AskForHelpManager:getInstance():leaveMode()
			Director:sharedDirector():popScene()
		end

		-- record
		AskForHelpManager:getInstance():addRecentHelpOtherRecords(doneeUid, self.levelId, true)
	end

	local function onNetCheckSuccess()
        needShowOff = true
		self:sendAFHPassLevelMessage(onSendMsgSuccess)
		GamePlayContext:getInstance():endLevel()
	end

	local function onNetCheckFail()
		local function onFinished(ret)
            needShowOff = ret
			self:sendAFHPassLevelMessage(onSendMsgSuccess)
			GamePlayContext:getInstance():endLevel()
		end

		local AFHNetWorkAlter = require 'zoo.panel.askForHelp.views.AFHNetWorkAlter'
		panel = AFHNetWorkAlter:create(onFinished):popout()
	end

	PaymentNetworkCheck:getInstance():check(onNetCheckSuccess, onNetCheckFail)
end

function PassLevelLogic:sendAFHPassLevelMessage(onSuccessCallback, ...)
	assert(type(onSuccessCallback) == "function")
	assert(#{...} == 0)

	local levelId = self.levelId
	local score	= self.score
	local star	= self.star
	local stageTime	= self.stageTime
	local coin	= self.coin
	local targetCount = self.targetCount
	local opLog = self.opLog
	local costMove = self.costMove or 0

	local function onPassLevelMsgSuccess(event)
		assert(event)
		assert(event.name == Events.kComplete)
		assert(event.data)

		local rewardItems = event.data

		onSuccessCallback(rewardItems)
	end

	local function onPassLevelMsgFailed()
		assert(false)
	end

    local http = AFHPassLevelHttp.new()
	http:addEventListener(Events.kComplete, onPassLevelMsgSuccess)
	http:addEventListener(Events.kError, onPassLevelMsgFailed)
	http:load(levelId, score, star, stageTime, coin, targetCount, opLog, self.levelType, costMove, self.extraData, self.safeFlag, self.senderUid, false)
end

function PassLevelLogic:sendAFHPassLevelMessageOnly(levelId, levelType, stageTime, costMove, extraData, seed, strategy, senderUid)
	local http = AFHPassLevelHttp.new()
	local function onPassLevelMsgSuccess(event)
	end
	local function onPassLevelMsgFailed(event)
	end
	http:addEventListener(Events.kComplete, onPassLevelMsgSuccess)
	http:addEventListener(Events.kError, onPassLevelMsgFailed)
	http:load(levelId, 0, 0, stageTime, 0, 0, nil, levelType, costMove, extraData, self.safeFlag, senderUid, true)
	
	InciteManager:onPassLevel()
	ProductItemDiffChangeLogic:endLevel()
	GameInitDiffChangeLogic:endLevel()
	GameInitBuffLogic:endLevel()
end
