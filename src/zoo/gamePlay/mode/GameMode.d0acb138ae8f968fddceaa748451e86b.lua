GameMode=class()

function GameMode:ctor(mainLogic)
  self.mainLogic = mainLogic
end

function GameMode:initModeSpecial(config)
end

function GameMode:update(dt)
end

-- 这些全都是为了检测豆荚收集的………………………………
-- function GameMode:afterSwap(r, c)
-- end

-- function GameMode:afterStable(r, c)
-- end

-- function GameMode:afterChainBreaked(r,c)
-- end

-- function GameMode:afterColorFilterBBreaked(r, c)
-- end

function GameMode:checkDropDownCollect(r, c)
end

function GameMode:afterFail()
  self.mainLogic:setGamePlayStatus(GamePlayStatus.kFailed)
end

function GameMode:useMove()
end

function GameMode:getScoreStarLevel()
  local mainLogic = self.mainLogic
	local starlevel = 0;
	if mainLogic then
		if mainLogic.scoreTargets then
			for i = 1, #mainLogic.scoreTargets do
				if mainLogic.totalScore >= mainLogic.scoreTargets[i] then
					starlevel = i;
				else
					break;
				end
			end
		end
	end
	return starlevel;
end

function GameMode:reachEndCondition()
  return false
end

function GameMode:reachTarget()
	return self:getScoreStarLevel() > 0
end

function GameMode:canChangeMoveToStripe()
	return true
end

function GameMode:failByRefresh()
	return not self:reachTarget()
end

function GameMode:saveDataForRevert(saveRevertData)
end

function GameMode:revertDataFromBackProp()
	local mainLogic = self.mainLogic
	mainLogic.gameItemMap = mainLogic.saveRevertData.gameItemMap
	mainLogic.boardmap = mainLogic.saveRevertData.boardmap
	mainLogic.backItemMap = mainLogic.saveRevertData.backItemMap
	mainLogic.backBoardMap = mainLogic.saveRevertData.backBoardMap
	mainLogic.totalScore = mainLogic.saveRevertData.totalScore
	mainLogic.oringinTotalScore = mainLogic.saveRevertData.oringinTotalScore or -999999999
	mainLogic.theCurMoves = mainLogic.saveRevertData.theCurMoves
	-- mainLogic.blockProductRules = mainLogic.saveRevertData.blockProductRules
	if mainLogic.saveRevertData.productRuleGroup and #mainLogic.saveRevertData.productRuleGroup > 0 then
		mainLogic.productRuleGroup = mainLogic.saveRevertData.productRuleGroup

		if mainLogic.defaultProductRuleGroupId then
			mainLogic.defaultProductRule = mainLogic.productRuleGroup[ mainLogic.defaultProductRuleGroupId ]
		end
	end
	-- mainLogic.cachePool = mainLogic.saveRevertData.cachePool
	if mainLogic.saveRevertData.cachePoolV2 and #mainLogic.saveRevertData.cachePoolV2 > 0 then
		-- printx( 1 , "GameMode:revertDataFromBackProp  --------" , table.tostring( mainLogic.saveRevertData.cachePoolV2 ) )
		mainLogic.cachePoolV2 = mainLogic.saveRevertData.cachePoolV2
	end
	mainLogic.pm25count = mainLogic.saveRevertData.pm25count
	mainLogic.snailCount = mainLogic.saveRevertData.snailCount
	mainLogic.snailMoveCount = mainLogic.saveRevertData.snailMoveCount
	mainLogic.questionMarkFirstBomb = mainLogic.saveRevertData.questionMarkFirstBomb
	mainLogic.bigMonsterMark = mainLogic.saveRevertData.bigMonsterMark
	mainLogic.chestSquareMark = mainLogic.saveRevertData.chestSquareMark
	mainLogic.UFOSleepCD = mainLogic.saveRevertData.UFOSleepCD
	mainLogic.oldUFOSleepCD = mainLogic.saveRevertData.oldUFOSleepCD
	mainLogic.blockerCoverMaterialTotalNum = mainLogic.saveRevertData.blockerCoverMaterialTotalNum
	mainLogic.blocker207DestroyNum = mainLogic.saveRevertData.blocker207DestroyNum
	mainLogic.realCostMoveWithoutBackProp = mainLogic.saveRevertData.realCostMoveWithoutBackProp
	mainLogic.staticLevelMoves = mainLogic.saveRevertData.staticLevelMoves
	mainLogic.lastCreateBuffBoomMoveSteps = mainLogic.saveRevertData.lastCreateBuffBoomMoveSteps
	mainLogic.blocker206Cfg = mainLogic.saveRevertData.blocker206Cfg
	mainLogic.pacmanGeneratedByStep = mainLogic.saveRevertData.pacmanGeneratedByStep or 0
	mainLogic.pacmanGeneratedByBoardMin = mainLogic.saveRevertData.pacmanGeneratedByBoardMin or 0
	mainLogic.actCollectionNum = mainLogic.saveRevertData.actCollectionNum
	mainLogic.destroyLotusNum = mainLogic.saveRevertData.destroyLotusNum
	mainLogic.coinDestroyNum = mainLogic.saveRevertData.coinDestroyNum
	mainLogic.ghostGeneratedByStep = mainLogic.saveRevertData.ghostGeneratedByStep or 0
	mainLogic.ghostGeneratedByBoardMin = mainLogic.saveRevertData.ghostGeneratedByBoardMin or 0

	mainLogic.generatedScoreBuffBottle = mainLogic.saveRevertData.generatedScoreBuffBottle or 0
	mainLogic.destroyedScoreBuffBottle = mainLogic.saveRevertData.destroyedScoreBuffBottle or 0
	mainLogic.scoreBuffBottleLeftSpecialTypes = mainLogic.saveRevertData.scoreBuffBottleLeftSpecialTypes
	-- mainLogic.scoreBuffBottleInitAmount = mainLogic.saveRevertData.scoreBuffBottleInitAmount		--为了replay，存储在replayData的ctx中
	mainLogic.sunflowersAppetite = mainLogic.saveRevertData.sunflowersAppetite or 0
	mainLogic.sunflowerEnergy = mainLogic.saveRevertData.sunflowerEnergy or 0
	mainLogic.generateFirecrackerTimes = mainLogic.saveRevertData.generateFirecrackerTimes or 0
	mainLogic.generateFirecrackerTimesForPreBuff = mainLogic.saveRevertData.generateFirecrackerTimesForPreBuff or 0

	mainLogic.squidOnBoard = nil	-- 重新从棋盘获取一遍鱿鱼数据

	--mainLogic.lotusEliminationNum =  mainLogic.saveRevertData.lotusEliminationNum
	--mainLogic.lotusPrevStepEliminationNum =  mainLogic.saveRevertData.lotusPrevStepEliminationNum

	ActCollectionLogic:setByRevertData( mainLogic.saveRevertData.actCollDatas )
	GameInitBuffLogic:setInitBuffPassedPlanList( mainLogic.saveRevertData.buffPassedPlanList )
	GameInitBuffLogic:setPrePropsPassedPlanList( mainLogic.saveRevertData.prePropsPassedPlanList )
	GameInitBuffLogic:setAddBuffAnimeType( mainLogic.saveRevertData.buffAnimeType , mainLogic.saveRevertData.buffAnimeTypeParameter )
	
	GamePlayContext:getInstance():setRevertData(mainLogic.saveRevertData.gamePlayCxt)
    
    SpringFestival2019Manager:getInstance():setByRevertData( mainLogic.saveRevertData.springFestival2019Data )
    TurnTable2019Manager:getInstance():setByRevertData( mainLogic.saveRevertData.TurnTable2019Data )

	mainLogic.saveRevertData = nil

	FallingItemLogic:updateHelpMapByDeleteBlock(mainLogic)
	Blocker206Logic:init(mainLogic)
end

function GameMode:revertUIFromBackProp()
	local mainLogic = self.mainLogic
	if mainLogic.PlayUIDelegate then
		mainLogic.PlayUIDelegate:setMoveOrTimeCountCallback(mainLogic.theCurMoves, false)
		mainLogic.PlayUIDelegate.scoreProgressBar:revertScoreTo(mainLogic.totalScore)
		GameExtandPlayLogic:revertUFOToPreStatus(mainLogic)
	end
end


function GameMode:onStartGame()
	if not self.mainLogic:isReplayMode() then

		if GameGuide then
			GameGuide:sharedInstance():onGameAnimOver()
		end
	end
	
	if HomeScene:hasInited() then
		BroadcastManager:getInstance():onEnterScene(self.mainLogic.PlayUIDelegate) --未进入游戏，不运行
	end
end

function GameMode:onGameInit()
	local context = self
	local isAct5003Effective = CollectStarsYEMgr.getInstance():isBuffIngameEffective()
	CollectStarsYEMgr.getInstance():setIngameFlag(false)

	local function setGameStart()
		context.mainLogic:setGamePlayStatus(GamePlayStatus.kNormal)
		context.mainLogic.fsm:initState()
		context.mainLogic.boardView.isPaused = false
		self:onStartGame()		
	end

	local function handleGameTopPartAni()
		if isAct5003Effective then
			CollectStarsYEMgr.getInstance():playBuffAnim(context.mainLogic, setGameStart)
		else
			setGameStart()
		end
	end

	local function playUFOFlyIntoAnimation()
		context.mainLogic.PlayUIDelegate:playUFOFlyIntoAnimation(handleGameTopPartAni)
	end

	local function playTargetAnimation()
        local DragonBuffInfo = DragonBuffManager:getInstance():getCurBuffLevelInGame()

		if context.mainLogic.hasDropDownUFO then
			context.mainLogic.PlayUIDelegate:playLevelTargetPanelAnim(playUFOFlyIntoAnimation) 
		else
			context.mainLogic.PlayUIDelegate:playLevelTargetPanelAnim(handleGameTopPartAni)
		end
	end

	local function playInitBuffAnimation()
		if GameInitBuffLogic:hasAnyInitBuffIncludedReplay() then

			GameInitBuffLogic:tryFindBuffPos() --尝试根据plan计算buff释放位置

			if GameInitBuffLogic:hasAnyInitBuff() then
				GameInitBuffLogic:doChangeBoardByGameInitBuff( function () playTargetAnimation() end )
			else
				playTargetAnimation()
			end
		else
			playTargetAnimation()
		end
	end
	
	if self.mainLogic.PlayUIDelegate then
		self.mainLogic.PlayUIDelegate:playPrePropAnimation(playInitBuffAnimation)

		--[[
		if self.mainLogic.PlayUIDelegate.onResumeReplayStart and type(self.mainLogic.PlayUIDelegate.onResumeReplayStart) == "function" then
			self.mainLogic.PlayUIDelegate:onResumeReplayStart()
		end
		]]
	else
		setGameStart()
	end
	self.mainLogic.boardView:animalStartTimeScale()
	self.mainLogic:stopWaitingOperation()
end

function GameMode:getFailReason()
	return self.failReason
end

function GameMode:setFailReason(failReason)
	self.failReason = failReason
end

function GameMode:getStageIndex()
    return 0
end

function GameMode:getStageMoveLimit()
	return 0
end