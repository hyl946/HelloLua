require 'zoo.config.RabbitWeeklyConfig'

RabbitWeeklyMode = class(GameMode)



function RabbitWeeklyMode:ctor(mainLogic)
  self.mainLogic = mainLogic
  self.mainLogic.rabbitCount = RabbitCount.new()
end

function RabbitWeeklyMode:initModeSpecial(config)
    -- if _G.isLocalDevelopMode then printx(0, 'RabbitWeeklyMode RabbitWeeklyMode RabbitWeeklyMode initModeSpecial') end
    self.stage = 0
    self.mainLogic.theCurMoves = self:getStageRemainingMove()
    ProductItemLogic:productRabbit(self.mainLogic, config.rabbitInitNum, nil, true)
end

function RabbitWeeklyMode:isNeedChangeState(callback, doChangeState)
    local stageChanged = false
    local remainingStageMove = self:getStageRemainingMove()

    if type(remainingStageMove) == 'number' and remainingStageMove <= 0 then
        stageChanged = true
        -- 只是检查，并不真的change state
        if not doChangeState then 
            return stageChanged
        end
        self:enterNextStage()
        remainingStageMove = self:getStageRemainingMove()
        if self.mainLogic.PlayUIDelegate then
            self.mainLogic.PlayUIDelegate:playChangePeriodAnimation(self.stage, callback)
        end
    end

    if self:shouldGenMoreColor() then
        self:genMoreColor()
    end

    if self.mainLogic.PlayUIDelegate then
        if remainingStageMove == 'infinite'then --------调用UI界面函数显示移动步数
            self.mainLogic.PlayUIDelegate:setInfiniteMoveCallback()
        else
            self.mainLogic.PlayUIDelegate:setMoveOrTimeCountCallback(self:getStageRemainingMove(), false, true)
        end
    end
    
    return stageChanged
end
function RabbitWeeklyMode:update(dt)
end

-- function RabbitWeeklyMode:afterSwap(r, c)
-- end

-- function RabbitWeeklyMode:afterStable(r, c)
-- end

function RabbitWeeklyMode:afterFail()
    -- TODO
    -- popout revive panel
    --FUUUManager:update(self)
    GameExtandPlayLogic:showUFOReveivePanel(self, true)
end

function RabbitWeeklyMode:useMove()

end

function RabbitWeeklyMode:genMoreColor()
    local allColors = {1,2,3,4,5,6}
    for k, v in pairs(allColors) do 
        if not table.exist(self.mainLogic.mapColorList, v) then
            table.insert(self.mainLogic.mapColorList, v)
            self.hasGenMoreColor = true
            return 
        end
    end
end

function RabbitWeeklyMode:shouldGenMoreColor()
    local beginMove = RabbitWeeklyConfig.genMoreColorMove
    if self.mainLogic.realCostMove >= beginMove and #self.mainLogic.mapColorList < 6 and not self.hasGenMoreColor then
        return true
    end 
    return false
end

function RabbitWeeklyMode:isDoubleRabbitStage()
    return self.stage >= 2
end

function RabbitWeeklyMode:getStageRemainingMove()
    -- local realCostMove = self.mainLogic.realCostMove
    -- if self.stage == 0 then
    --     return RabbitWeeklyConfig.stageInitEnd - realCostMove
    -- elseif self.stage == 1 then
    --     return RabbitWeeklyConfig.stageOneEnd - realCostMove
    -- elseif self.stage == 2 then
    --     return RabbitWeeklyConfig.stageTwoEnd - realCostMove
    -- elseif self.stage == 3 then
    --     return RabbitWeeklyConfig.stageThreeEnd - realCostMove
    -- elseif self.stage == 4 then
    --     return 'infinite'
    -- end

    local realCostMove = self.mainLogic.realCostMove
    if self.stage == 0 then
        return RabbitWeeklyConfig.stageInitEnd - realCostMove
    elseif self.stage == 1 then
        return RabbitWeeklyConfig.stageOneEnd - realCostMove
    elseif self.stage == 2 then
        return RabbitWeeklyConfig.stageTwoEnd - realCostMove
    elseif self.stage == 3 then
        return 'infinite'
    end
end

function RabbitWeeklyMode:getScoreStarLevel()
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

function RabbitWeeklyMode:reachEndCondition()
    return false
end

function RabbitWeeklyMode:reachTarget()
    return false
end

function RabbitWeeklyMode:canChangeMoveToStripe()
    return true
end

function RabbitWeeklyMode:saveDataForRevert(saveRevertData)
    local mainLogic = self.mainLogic
    saveRevertData.rabbitCount = mainLogic.rabbitCount:getValue()
    saveRevertData.stage = self.stage
    saveRevertData.hasGenMoreColor = self.hasGenMoreColor
    saveRevertData.realCostMove = mainLogic.realCostMove
    MoveMode.saveDataForRevert(self, saveRevertData)
end

function RabbitWeeklyMode:revertDataFromBackProp()
    self.mainLogic.realCostMove = self.mainLogic.saveRevertData.realCostMove
    self.mainLogic.rabbitCount:setValue(self.mainLogic.saveRevertData.rabbitCount)
    self.stage = self.mainLogic.saveRevertData.stage
    self.hasGenMoreColor = self.mainLogic.saveRevertData.hasGenMoreColor
    MoveMode.revertDataFromBackProp(self)
end

function RabbitWeeklyMode:revertUIFromBackProp()
    local mainLogic = self.mainLogic
    if mainLogic.PlayUIDelegate then
        local remainingMoves = self:getStageRemainingMove()
        if remainingMoves == 'infinite' then
            self.mainLogic.PlayUIDelegate:setInfiniteMoveCallback()
        else
            mainLogic.PlayUIDelegate:setMoveOrTimeCountCallback(self:getStageRemainingMove(), false, true)
        end
        mainLogic.PlayUIDelegate.scoreProgressBar:revertScoreTo(mainLogic.totalScore)
        mainLogic.PlayUIDelegate:revertTargetNumber(0, 0, mainLogic.rabbitCount:getValue())
    end
end

function RabbitWeeklyMode:onGameInit()
    local context = self
    local function setGameStart()
        context.mainLogic:setGamePlayStatus(GamePlayStatus.kNormal)
        context.mainLogic.fsm:initState()
        context.mainLogic.boardView.isPasued = false

        self:onStartGame()
    end

    local function playUFOFlyIntoAnimation(  )
        -- body
        context.mainLogic.PlayUIDelegate:playUFOFlyIntoAnimation(setGameStart, UFOType.kRabbit)
    end

    local function playTargetAnimation()
         context.mainLogic.PlayUIDelegate:playLevelTargetPanelAnim(playUFOFlyIntoAnimation) 
    end
    
    if self.mainLogic.PlayUIDelegate then
        self.mainLogic.PlayUIDelegate:playPrePropAnimation(playTargetAnimation) 
    else
        setGameStart()
    end

    
    self.mainLogic.boardView:animalStartTimeScale()
    self.mainLogic:stopWaitingOperation()
end

function RabbitWeeklyMode:enterNextStage()
    -- if self.stage == 0 then
    --     self.stage = 1
    -- elseif self.stage == 1 then
    --     self.stage = 2
    -- elseif self.stage == 2 then
    --     self.stage = 3
    -- elseif self.stage == 3 then
    --     self.stage = 4
    -- end
    if self.stage == 0 then
        self.stage = 1
    elseif self.stage == 1 then
        self.stage = 2
    elseif self.stage == 2 then
        self.stage = 3
    end
    if self.mainLogic.PlayUIDelegate then 
        self.mainLogic.PlayUIDelegate:setMoveOrTimeStage(self.stage + 1) 
    end
    -- if _G.isLocalDevelopMode then printx(0, 'RabbitWeeklyMode:enterNextStage', self.stage) end
end

function RabbitWeeklyMode:getGenerateCount_backup(realCostMove)
    local shouldGenerateCount = 1

    local maxCount = self:getMaxRabbitCount(realCostMove)
    local curRabbitCount = self:getRabbitCount()
    local maxGenCount = maxCount - curRabbitCount

    if realCostMove >= RabbitWeeklyConfig.firstAddGenCountMove then
        shouldGenerateCount = shouldGenerateCount + 1
        realCostMove = realCostMove - RabbitWeeklyConfig.firstAddGenCountMove

        while realCostMove >= RabbitWeeklyConfig.addGenCountInterval do
            shouldGenerateCount = shouldGenerateCount + 1
            realCostMove = realCostMove - RabbitWeeklyConfig.addGenCountInterval
        end
    end

    -- if _G.isLocalDevelopMode then printx(0, 'maxCount', maxCount) end
    -- if _G.isLocalDevelopMode then printx(0, 'curRabbitCount', curRabbitCount) end
    -- if _G.isLocalDevelopMode then printx(0, 'maxGenCount', maxGenCount) end
    -- if _G.isLocalDevelopMode then printx(0, 'shouldGenerateCount', shouldGenerateCount) end
    return math.min(shouldGenerateCount, maxGenCount)
end

function RabbitWeeklyMode:getGenerateCount(realCostMove)
    local shouldGenerateCount = 1

    local maxCount = self:getMaxRabbitCount(realCostMove)
    local curRabbitCount = self:getRabbitCount()
    local maxGenCount = maxCount - curRabbitCount

    if realCostMove <= RabbitWeeklyConfig.firstPeriodMove then
        shouldGenerateCount = shouldGenerateCount + math.floor(realCostMove / RabbitWeeklyConfig.firstPeriodInterval) * 1
    else
        shouldGenerateCount = shouldGenerateCount + RabbitWeeklyConfig.firstPeriodMove / RabbitWeeklyConfig.firstPeriodInterval
        realCostMove = realCostMove - RabbitWeeklyConfig.firstPeriodMove
        shouldGenerateCount = shouldGenerateCount + math.floor(realCostMove / RabbitWeeklyConfig.addGenCountInterval) * 1
    end

    if _G.isLocalDevelopMode then printx(0, 'maxCount', maxCount) end
    if _G.isLocalDevelopMode then printx(0, 'curRabbitCount', curRabbitCount) end
    if _G.isLocalDevelopMode then printx(0, 'maxGenCount', maxGenCount) end
    if _G.isLocalDevelopMode then printx(0, 'shouldGenerateCount', shouldGenerateCount) end
    return math.min(shouldGenerateCount, maxGenCount)
end

function RabbitWeeklyMode:getMaxRabbitCount(realCostMove)
    local maxCount = RabbitWeeklyConfig.initMaxCount

    while realCostMove >= RabbitWeeklyConfig.addMaxCountInterval do
        maxCount = maxCount + 5
        realCostMove = realCostMove - RabbitWeeklyConfig.addMaxCountInterval
    end
    return maxCount
end

function RabbitWeeklyMode:getRabbitCount()
    local count = 0
    local gameItemMap = self.mainLogic.gameItemMap
    for r = 1, #gameItemMap do 
        for c = 1, #gameItemMap[r] do
            local item = gameItemMap[r][c]
            if item and item.ItemType == GameItemType.kRabbit then
                count = count + 1
            end
        end
    end
    return count
end

function RabbitWeeklyMode:getStageIndex()
    return self.stage
end

function RabbitWeeklyMode:getStageMoveLimit()
    if self.stage == 0 then
        return RabbitWeeklyConfig.stageInitEnd
    elseif self.stage == 1 then
        return RabbitWeeklyConfig.stageOneEnd - RabbitWeeklyConfig.stageInitEnd
    elseif self.stage == 2 then
        return RabbitWeeklyConfig.stageTwoEnd - RabbitWeeklyConfig.stageOneEnd
    elseif self.stage == 3 then
        return 0
    end
end