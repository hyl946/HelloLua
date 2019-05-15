MoleWeeklySeedSkillSettleState = class(BaseStableState)
--周赛Boss结算Heal技能

function MoleWeeklySeedSkillSettleState:dispose()
    self.mainLogic = nil
    self.boardView = nil
    self.context = nil
end

function MoleWeeklySeedSkillSettleState:create(context)
    local v = MoleWeeklySeedSkillSettleState.new()
    v.context = context
    v.mainLogic = context.mainLogic
    v.boardView = v.mainLogic.boardView
    return v
end

function MoleWeeklySeedSkillSettleState:onEnter()
    self.hasItemToHandle = false
    self.hasBrokenSeed = false
    BaseStableState.onEnter(self)
	self.nextState = nil

    if not self.mainLogic.gameMode:is(MoleWeeklyRaceMode) then
        self:handleComplete()
        return
    end

    if self.mainLogic.gameMode.firstLaySeedStep < 0 then
        self:handleComplete()
        return
    end

    local skillHDuration = self.mainLogic.realCostMoveWithoutBackProp - self.mainLogic.gameMode.firstLaySeedStep
    if skillHDuration >= MoleWeeklyRaceParam.HEAL_SETTLE_ROUND then
        self.mainLogic.gameMode.firstLaySeedStep = -1
    end

    self:_checkSeedsOnBoard()
end

function MoleWeeklySeedSkillSettleState:handleComplete()
    self.nextState = self:getNextState()
    if self.hasItemToHandle then
        self.mainLogic:setNeedCheckFalling()
        FallingItemLogic:preUpdateHelpMap(self.mainLogic)
        if self.hasBrokenSeed then
            self.context.needLoopCheck = true   --种子袋变出的特效可能造成消除
        end
    end
end

function MoleWeeklySeedSkillSettleState:onExit()
    BaseStableState.onExit(self)
    self.nextState = nil
    self.hasItemToHandle = false
    self.hasBrokenSeed = false
end

function MoleWeeklySeedSkillSettleState:getClassName()
    return "MoleWeeklySeedSkillSettleState"
end

function MoleWeeklySeedSkillSettleState:getNextState()
    -- return self.context.wukongReinitState
    return self.context.magicTileResetState
end

function MoleWeeklySeedSkillSettleState:checkTransition()
    return self.nextState
end

function MoleWeeklySeedSkillSettleState:_checkSeedsOnBoard()
	local function completeCallback()
    	self.handleAmount = self.handleAmount - 1
    	if self.handleAmount <= 0 then
    		self.hasItemToHandle = true
        	self:handleComplete()
    	end
    end

    self.handleAmount = 0

	local brokenSeeds, intactSeeds = MoleWeeklyRaceLogic:getAllSeedsOnBoard(self.mainLogic)
	if #brokenSeeds > 0 then
		-- local targetGrids = MoleWeeklyRaceLogic:pickSeedToSpecialGrids(self.mainLogic, #brokenSeeds)

		local skillAction = GameBoardActionDataSet:createAs(
            GameActionTargetType.kGameItemAction,
            GameItemActionType.kItem_MoleWeekly_Boss_Skill,
            IntCoord:create(1, 1),
            nil,
            GamePlayConfig_MaxAction_time)
        skillAction.targetList = brokenSeeds
        skillAction.skillType = MoleWeeklyBossSkillType.SUB_ADD_SPECIAL
        skillAction.completeCallback = completeCallback
        -- self.mainLogic:addGameAction(skillAction)
        self.mainLogic:addGlobalCoreAction(skillAction)

        self.handleAmount = self.handleAmount + 1
        self.hasBrokenSeed = true
	end
    
	if #intactSeeds > 0 and (self.mainLogic.gameMode.lastSeedCountdownStep ~= self.mainLogic.realCostMoveWithoutBackProp) then
        local changeToGrass = false
        if self.mainLogic.gameMode.firstLaySeedStep <= 0 then
            changeToGrass = true
        end

        -- 最终点回合结算完好的种子
        -- 普通回合播放种子削减计数动画
        local skillAction = GameBoardActionDataSet:createAs(
            GameActionTargetType.kGameItemAction,
            GameItemActionType.kItem_MoleWeekly_Boss_Skill,
            IntCoord:create(1, 1),
            nil,
            GamePlayConfig_MaxAction_time)
        skillAction.skillType = MoleWeeklyBossSkillType.SUB_SEED_COUNT_DOWN
        skillAction.changeToGrass = changeToGrass
        skillAction.targetList = intactSeeds
        skillAction.completeCallback = completeCallback
        -- self.mainLogic:addGameAction(skillAction)
        self.mainLogic:addGlobalCoreAction(skillAction)

        self.handleAmount = self.handleAmount + 1

        self.mainLogic.gameMode.lastSeedCountdownStep = self.mainLogic.realCostMoveWithoutBackProp
	end

	if self.handleAmount == 0 then
		self:handleComplete()
	end
end
