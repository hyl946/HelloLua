MoleWeeklyBossState = class(BaseStableState)

function MoleWeeklyBossState:dispose()
    self.mainLogic = nil
    self.boardView = nil
    self.context = nil
end

function MoleWeeklyBossState:create(context)
    local v = MoleWeeklyBossState.new()
    v.context = context
    v.mainLogic = context.mainLogic
    v.boardView = v.mainLogic.boardView
    return v
end

function MoleWeeklyBossState:onEnter()
    self.hasItemToHandle = false

    BaseStableState.onEnter(self)

    if not self.mainLogic.gameMode:is(MoleWeeklyRaceMode) then
        self:handleComplete()
        return
    end

    local function dieCallback()
        -- GameGuide:sharedInstance():onHalloweenBossDie()
        self.mainLogic.firstBossDie = true
        self.hasItemToHandle = true
        self:handleComplete()
    end

    local boss = self.mainLogic:getMoleWeeklyBossData()
    if boss then
        if boss.hit >= boss.totalBlood then
            local action = GameBoardActionDataSet:createAs(
                    GameActionTargetType.kGameItemAction,
                    GameItemActionType.kItem_MoleWeekly_Boss_Die,
                    nil,
                    nil,
                    GamePlayConfig_MaxAction_time
                )
            action.completeCallback = dieCallback
            -- self.mainLogic:addGameAction(action)
            self.mainLogic:addGlobalCoreAction(action)
        else
            self:handleComplete()
        end
    else
        self:handleComplete()
    end
end

function MoleWeeklyBossState:handleComplete()
    self.nextState = self:getNextState()
    if self.hasItemToHandle then
        self.context.needLoopCheck = true
        self.mainLogic:setNeedCheckFalling()
    end
end

function MoleWeeklyBossState:getNextState()
    return nil
end

function MoleWeeklyBossState:onExit()
    BaseStableState.onExit(self)
    self.nextState = nil
    self.bossHandled = false
    self.hasItemToHandle = false
end

function MoleWeeklyBossState:checkTransition()
    return self.nextState
end

function MoleWeeklyBossState:getClassName()
    return "MoleWeeklyBossState"
end

--------------------------------------------------------------------------
MoleWeeklyBossStateInLoop = class(MoleWeeklyBossState)
function MoleWeeklyBossStateInLoop:create(context)
    local v = MoleWeeklyBossStateInLoop.new()
    v.context = context
    v.mainLogic = context.mainLogic
    v.boardView = v.mainLogic.boardView
    v.inBonus = false
    return v
end

function MoleWeeklyBossStateInLoop:getClassName()
    return "MoleWeeklyBossStateInLoop"
end

function MoleWeeklyBossStateInLoop:getNextState()
    --return self.context.cleanDigGroundStateInLoop
    -- return self.context.wukongReinitState
    return self.context.moleWeeklySeedSkillSettleState
end

--------------------------------------------------------------------------
MoleWeeklyBossStateInBonus = class(MoleWeeklyBossState)
function MoleWeeklyBossStateInBonus:create( context )
    -- body
    local v = MoleWeeklyBossStateInBonus.new()
    v.context = context
    v.mainLogic = context.mainLogic
    v.boardView = v.mainLogic.boardView
    v.inBonus = true
    return v
end

function MoleWeeklyBossStateInBonus:getClassName()
    return "MoleWeeklyBossStateInBonus"
end

function MoleWeeklyBossStateInBonus:getNextState()
    return self.context.elephantBossState
end


--------------------------------------------------------------------------
--                                释放技能
--------------------------------------------------------------------------
MoleWeeklyBossCastSkillState = class(BaseStableState)
function MoleWeeklyBossCastSkillState:create(context)
    local v = MoleWeeklyBossCastSkillState.new()
    v.context = context
    v.mainLogic = context.mainLogic
    v.boardView = v.mainLogic.boardView
    return v
end

function MoleWeeklyBossCastSkillState:onEnter()
    self.hasItemToHandle = false
    BaseStableState.onEnter(self)

    if not self.mainLogic.gameMode:is(MoleWeeklyRaceMode) then
        self:handleComplete()
        return
    end

    local function completeCallback()
        self.hasItemToHandle = true
        self:handleComplete()
    end

    local boss = self.mainLogic:getMoleWeeklyBossData()
    if boss then
        -- pick skill
        if not boss.bossSkillType then
            local needForbidSkillS = false
            --[[    --由于预先几轮随机，所以不判断棋盘状态了
            local pickedGrid, subPickedGrid
            if MoleWeeklyRaceConfig:hasMagicTileSkill(boss.bossGroupID) then
                pickedGrid, subPickedGrid = MoleWeeklyRaceLogic:getAvailableMagicTileGrid(self.mainLogic)
                if #pickedGrid == 0 and #subPickedGrid == 0 then
                    needForbidSkillS = true    --没有目标地格，屏蔽此技能
                end
            end
            ]]

            boss.bossSkillType, boss.bossSkillParam = MoleWeeklyRaceConfig:genNewSkill(self.mainLogic, boss, needForbidSkillS)
        end

        ---------  判断施放
        local bossController
        local needReleaseSkill = false        --需要释放boss技能了

        local releaseCountDown = MoleWeeklyRaceLogic:getReleaseSkillCountDown(self.mainLogic, boss)
        if releaseCountDown >= 1 then
            bossController = self.mainLogic.boardView.PlayUIDelegate
            if bossController then
                 bossController.BossSkillController:SelectSkill(boss.bossSkillType, releaseCountDown)    --小鼹鼠顶出技能球动画
            end
        elseif releaseCountDown == 0 then
            needReleaseSkill = true
            boss.bossLastReleaseSkillStep = self.mainLogic.realCostMove
        end

        ---------  施放
        if needReleaseSkill and boss.bossSkillType and boss.bossSkillParam > 0 then
            local skillType = boss.bossSkillType
            local targetList
            local param2

            if skillType == MoleWeeklyBossSkillType.THICK_HONEY then
                targetList = MoleWeeklyRaceLogic:pickThickHoneyTarget(self.mainLogic, boss.bossSkillParam)
            elseif skillType == MoleWeeklyBossSkillType.FRAGILE_BLACK_CUTEBALL then
                targetList = MoleWeeklyRaceLogic:pickFragileCuteBallTargetTile(self.mainLogic, boss.bossSkillParam)
            elseif skillType == MoleWeeklyBossSkillType.DEAVTIVATE_MAGIC_TILE then
                local pickedGridByPriority = MoleWeeklyRaceLogic:getAvailableMagicTileGrid(self.mainLogic)
                targetList = MoleWeeklyRaceLogic:pickTargetMagicTile(self.mainLogic, pickedGridByPriority, boss.bossSkillParam)
                param2 = 3 + 1  --格子失效回合：3, 因为在之后的MagicTileResetState中会立即削减一个回合数，所以+1（失效设定已废弃）
            elseif skillType == MoleWeeklyBossSkillType.SEED then
                targetList = MoleWeeklyRaceLogic:pickLaySeedGrids(self.mainLogic, boss.bossSkillParam)
            elseif skillType == MoleWeeklyBossSkillType.BIG_CLOUD_BLOCK then
                targetList = MoleWeeklyRaceLogic:pickPositionForBigCloud(self.mainLogic, boss.bossSkillParam)
            elseif skillType == MoleWeeklyBossSkillType.SMALL_CLOUD_BLOCK_1 
                or skillType == MoleWeeklyBossSkillType.SMALL_CLOUD_BLOCK_2 then
                targetList = MoleWeeklyRaceLogic:pickSmallCloudBlockTargets(self.mainLogic, boss.bossSkillParam)
            end

            -- printx(11, "= = = = = Boss skill target:", table.tostring(targetList))

            if targetList and #targetList > 0 then
                local skillAction = GameBoardActionDataSet:createAs(
                    GameActionTargetType.kGameItemAction,
                    GameItemActionType.kItem_MoleWeekly_Boss_Skill,
                    IntCoord:create(1,1),
                    nil,
                    GamePlayConfig_MaxAction_time)
                skillAction.targetList = targetList
                skillAction.skillType = skillType
                skillAction.param2 = param2
                skillAction.completeCallback = completeCallback
                -- self.mainLogic:addGameAction(skillAction)
                self.mainLogic:addGlobalCoreAction(skillAction)

                boss.bossFirstSkillReleased = true
                boss.lastSkillName = skillType
                if skillType == MoleWeeklyBossSkillType.SEED then
                    self.mainLogic.gameMode.firstLaySeedStep = self.mainLogic.realCostMoveWithoutBackProp
                    self.mainLogic.gameMode.lastSeedCountdownStep = self.mainLogic.gameMode.firstLaySeedStep
                end
            else
                bossController = self.mainLogic.boardView.PlayUIDelegate
                if bossController then
                    bossController.BossSkillController:PlayAttack(skillType)    --空放技能动画
                end

                boss.lastSkillName = nil
                self:handleComplete()
            end

            boss.bossSkillType = nil
            boss.bossSkillParam = 0
        else
            self:handleComplete()
        end
    else
        self:handleComplete()
    end
end

function MoleWeeklyBossCastSkillState:handleComplete()
    self.nextState = self:getNextState()
    if self.hasItemToHandle then
        self.mainLogic:setNeedCheckFalling()
    end
end

function MoleWeeklyBossCastSkillState:onExit()
    BaseStableState.onExit(self)
    self.nextState = nil
    self.hasItemToHandle = false
end

function MoleWeeklyBossCastSkillState:getClassName()
    return "MoleWeeklyBossCastSkillState"
end

function MoleWeeklyBossCastSkillState:getNextState()
    return self.context.productSnailState
end

function MoleWeeklyBossCastSkillState:checkTransition()
    return self.nextState
end