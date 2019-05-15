MagicLampCastingState = class(BaseStableState)

function MagicLampCastingState:create(context)
    local v = MagicLampCastingState.new()
    v.context = context
    v.mainLogic = context.mainLogic
    v.boardView = v.mainLogic.boardView
    return v
end

function MagicLampCastingState:dispose()
    self.mainLogic = nil
    self.boardView = nil
    self.context = nil
end

function MagicLampCastingState:update(dt)
    
end

function MagicLampCastingState:onEnter()
    BaseStableState.onEnter(self)
    self.nextState = nil

    if(not self.mainLogic._fieldLogicPossibility[_FIELD_LOGIC_ID[GameItemType.kMagicLamp]]) then
        printx(0, '!skip')
        self:onActionComplete()
        return
    end

    self:tryHandleCasting()
end

function MagicLampCastingState:tryHandleCasting()
    local mainLogic = self.mainLogic
    local gameItemMap = mainLogic.gameItemMap

    -- bonus time
    if mainLogic.isBonusTime then
        self:onActionComplete()
        return
    end

    -- get the lamps
    local lamps = {}
    local hasRoost = false
    for r = 1, #gameItemMap do
        for c = 1, #gameItemMap[r] do
            local item = gameItemMap[r][c]
            if item then
                if item.ItemType == GameItemType.kMagicLamp and item:isAvailable() and item.lampLevel >= 5 then
                    table.insert(lamps, item)
                end
                
                if item.ItemType == GameItemType.kRoost then
                    hasRoost = true
                end
            end
        end
    end

    if #lamps == 0 then
        self:onActionComplete()
        return
    end

    local count = 0

    local function actionCallback()
        count = count + 1
        if count >= #lamps then
            self:onActionComplete(true)
        end
    end

    local function isNormal(item)
        if (item.ItemType == GameItemType.kAnimal or item.ItemType == GameItemType.kCrystal)
        and item.ItemSpecialType == 0 -- not special
        and item:isAvailable()
        and not item:hasLock() 
        and not item:hasFurball()
        and item.ItemType ~= GameItemType.kBlocker199
        then
            return true
        end
        return false
    end

    local availablePosAllColor = {}
    for k,v in pairs(lamps) do
        availablePosAllColor[v:getColorIndex()] = {}
    end

    -- 对应颜色插入对应的数组
    for r = 1, #gameItemMap do 
        for c = 1, #gameItemMap[r] do
            local item = gameItemMap[r][c]
            if item ~= nil and isNormal(item) and availablePosAllColor[item:getColorIndex()] ~= nil then
                table.insert(availablePosAllColor[item:getColorIndex()], {r = r, c = c})
            end
        end
    end

    for k, v in pairs(lamps) do
        local speicalItemPos = {}
        local genCount = 3
        local availablePos = availablePosAllColor[v:getColorIndex()]
        if not availablePos then 
            availablePos = {}
        end
        if #availablePos < genCount then
            speicalItemPos = availablePos
            availablePosAllColor[v:getColorIndex()] = {}
        else
            for i = 1, genCount do
                local idx = self.mainLogic.randFactory:rand(1, #availablePos)
                table.insert(speicalItemPos, availablePos[idx])
                table.remove(availablePos, idx)
            end
        end

        local action = GameBoardActionDataSet:createAs(
                        GameActionTargetType.kGameItemAction,
                        GameItemActionType.kItem_Magic_Lamp_Casting,
                        IntCoord:create(v.y, v.x),
                        nil,
                        GamePlayConfig_MaxAction_time
                    )
        action.completeCallback = actionCallback
        action.speicalItemPos = speicalItemPos
        self.mainLogic:addGameAction(action)
    end
end

function MagicLampCastingState:onExit()
    BaseStableState.onExit(self)
end

function MagicLampCastingState:checkTransition()
    return self.nextState
end

function MagicLampCastingState:onActionComplete(bomb)
    if bomb then
        self.context.needLoopCheck = true
        self.mainLogic:setNeedCheckFalling()
        self.nextState = self
    else
        self.nextState = self:getNextState()
    end
end

function MagicLampCastingState:getNextState( ... )
    -- body
    return nil
end

function MagicLampCastingState:getClassName( ... )
    -- body
    return "MagicLampCastingState"
end

MagicLampCastingStateInSwapFirst = class(MagicLampCastingState)
function MagicLampCastingStateInSwapFirst:create(context)
    local v = MagicLampCastingStateInSwapFirst.new()
    v.context = context
    v.mainLogic = context.mainLogic
    v.boardView = v.mainLogic.boardView
    return v 
end
function MagicLampCastingStateInSwapFirst:getClassName()
    return "MagicLampCastingStateInSwapFirst"
end

function MagicLampCastingStateInSwapFirst:getNextState()
    return self.context.wukongJumpStateInSwapFirst
end

MagicLampCastingStateInLoop = class(MagicLampCastingState)
function MagicLampCastingStateInLoop:create(context)
    local v = MagicLampCastingStateInLoop.new()
    v.context = context
    v.mainLogic = context.mainLogic
    v.boardView = v.mainLogic.boardView
    return v
end

function MagicLampCastingStateInLoop:getClassName()
    return "MagicLampCastingStateInLoop"
end

function MagicLampCastingStateInLoop:getNextState()
    --return self.context.balloonCheckStateInLoop
    return self.context.wukongGiftInLoop
end
