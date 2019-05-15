PrePropsGenerateState = class(BaseStableState)

function PrePropsGenerateState:create(context)
    local v = PrePropsGenerateState.new()
    v.context = context
    v.mainLogic = context.mainLogic
    v.boardView = v.mainLogic.boardView
    return v
end

function PrePropsGenerateState:dispose()
    self.mainLogic = nil
    self.boardView = nil
    self.context = nil
end

function PrePropsGenerateState:update(dt)
    
end

function PrePropsGenerateState:onEnter()
    BaseStableState.onEnter(self)
    self.nextState = nil
    self.hasItemToHandle = false
    
    -- 由前置道具生成
    if self:tryCreatePrePropsByPassedPlanList() then
        self.hasItemToHandle = true
    elseif GameInitBuffLogic:hasBuffOfTypeInLevel(InitBuffType.FIRECRACKER, {InitBuffCreateType.PRE_PROP, InitBuffCreateType.REMIND_PRE_PROP}) then    -- 由后续每轮生成
        if self:tryCreateNewFirecracker() then
            self.hasItemToHandle = true
        end
    end

    if not self.hasItemToHandle then
    	self:onActionComplete()
    end
end

function PrePropsGenerateState:tryCreatePrePropsByPassedPlanList()
    local resultList = GameInitBuffLogic:tryCreatePrePropPositionsByPassedPlanList()
    if resultList and #resultList > 0 then
        self:createAddPrePropAction(resultList)
        return true
    end
    return false
end

function PrePropsGenerateState:tryCreateNewFirecracker()
    -- printx(11, "= = = PrePropsGenerateState:tryCreateNewFirecracker = = =")
    local maxAmount = 2 -- 初始第一个走的是前置道具的逻辑，不在此列考虑
    local firecrackerGeneratedByStep = math.max(self.mainLogic.generateFirecrackerTimes - 1, 0)
    if firecrackerGeneratedByStep >= maxAmount then
        return false
    end
    local realCostMove = self.mainLogic.realCostMoveWithoutBackProp
    local unlockAmount = math.floor(realCostMove / 10)
    local toGenerateAmount = math.min(unlockAmount - firecrackerGeneratedByStep, maxAmount - firecrackerGeneratedByStep)

    if toGenerateAmount >= 1 then
        local resultList = GameInitBuffLogic:tryCreateNewFirecrackerAndReturnPositon(toGenerateAmount, ItemType.PRE_FIRECRACKER)
        if resultList and #resultList > 0 then
            self:createAddPrePropAction(resultList)
            return true
        end
    end

    return false
end

function PrePropsGenerateState:createAddPrePropAction(resultList)
    local function completeCallback()
        self.prePropsToCreate = self.prePropsToCreate - 1
        if self.prePropsToCreate <= 0 then
            self:onActionComplete()
        end
    end

    local visibleOrigin = Director:sharedDirector():getVisibleOrigin()
    local visibleSize = CCDirector:sharedDirector():getVisibleSize()
    local destYInWorldSpace = visibleOrigin.y + visibleSize.height / 2 + 100
    local centerPosX = visibleOrigin.x + visibleSize.width / 2
    local totalSelected = #resultList
    local itemPadding = 190 - 10 * totalSelected

    self.prePropsToCreate = 0
    local itemIndex = 0

    for _, data in ipairs(resultList) do
        -- printx(11, "data.propId, buffType:", data.propId, data.buffType, data.tarItemType)
        self.prePropsToCreate = self.prePropsToCreate + 1
        itemIndex = itemIndex + 1

        local itemData = {}
        itemData.id = ItemType:getRealIdByTimePropId(data.propId)
        itemData.destXInWorldSpace = centerPosX + (itemIndex - (totalSelected + 1) / 2) * itemPadding
        itemData.destYInWorldSpace = destYInWorldSpace

        local action = GameBoardActionDataSet:createAs(
            GameActionTargetType.kPropsAction,
            GameItemActionType.kAddBuffSpecialAnimal,
            nil,
            nil,
            GamePlayConfig_MaxAction_time)
        action.pos = {r = data.r, c = data.c}
        if data.buffType == InitBuffType.RANDOM_BIRD then
            action.tarItemColorType = 0
        else
            action.tarItemColorType = data.item._encrypt.ItemColorType
        end
        action.tarItemSpecialType = data.tarItemSpecialType

        if data.buffType == InitBuffType.LINE_WRAP then
            action.pos2 = {r = data.r2, c = data.c2}
            action.tarItemColorType2 = data.item2._encrypt.ItemColorType
            action.tarItemSpecialType2 = data.tarItemSpecialType2
        end
        self.mainLogic:preGameProp(itemData.id)  -- mainly add log here

        action.fromGuide = (data.createType == InitBuffCreateType.REMIND_PRE_PROP)
        action.buffType = data.buffType
        action.tarItemType = data.tarItemType

        action.data = itemData
        action.completeCallback = completeCallback
        self.mainLogic:addGlobalCoreAction(action)
        SnapshotManager:stop()
    end
end

function PrePropsGenerateState:getClassName()
    return "PrePropsGenerateState"
end

function PrePropsGenerateState:checkTransition()
    return self.nextState
end

function PrePropsGenerateState:onActionComplete(needEnter)
    self.nextState = self:getNextState()
    if needEnter then
    	self.context:onEnter()
    end
end

function PrePropsGenerateState:getNextState()
    return self.context.buffBoomGenerateState
end

function PrePropsGenerateState:onExit()
    BaseStableState.onExit(self)
end