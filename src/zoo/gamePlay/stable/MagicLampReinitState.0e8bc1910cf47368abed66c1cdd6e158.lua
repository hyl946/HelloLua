MagicLampReinitState = class(BaseStableState)

function MagicLampReinitState:create(context)
    local v = MagicLampReinitState.new()
    v.context = context
    v.mainLogic = context.mainLogic
    v.boardView = v.mainLogic.boardView
    return v
end

function MagicLampReinitState:dispose()
    self.mainLogic = nil
    self.boardView = nil
    self.context = nil
end

function MagicLampReinitState:update(dt)
    
end

function MagicLampReinitState:onEnter()
    BaseStableState.onEnter(self)
    self.nextState = nil
    self.hasItemToHandle = false

    if(not self.mainLogic._fieldLogicPossibility[_FIELD_LOGIC_ID[GameItemType.kMagicLamp]]) then
        printx(0, '!skip')
        self:onActionComplete()
        return
    end

    self:tryHandleReinit()
end

function MagicLampReinitState:tryHandleReinit()
    local mainLogic = self.mainLogic
    local gameItemMap = mainLogic.gameItemMap
    local backItemMap = mainLogic.backItemMap

    -- bonus time
    if mainLogic.isBonusTime then
        self:onActionComplete()
        return
    end

    -- get the lamps
    local lamps = {}
    local banColors = {}

    local function addColorToBanlist(itemColorType)
        local color = AnimalTypeConfig.getOriginColorValue(itemColorType)
        if color ~= AnimalTypeConfig.kNone then
            if banColors[color] == nil then banColors[color] = 0 end
            banColors[color] = banColors[color] + 1
        end    
    end

    for r = 1, #gameItemMap do
        for c = 1, #gameItemMap[r] do
            local item = gameItemMap[r][c]
            if item and item.ItemType == GameItemType.kMagicLamp then
                if item.lampLevel == 0 and item:isAvailable() then -- 只有available的才能初始化
                    table.insert(lamps, item)
                end

                -- 所有的神灯都参与颜色统计
                addColorToBanlist(item._encrypt.ItemColorType)
            end

            local backItem = nil
            if backItemMap and backItemMap[r] then backItem = backItemMap[r][c] end

            if backItem and backItem.ItemType == GameItemType.kMagicLamp then
                addColorToBanlist(backItem._encrypt.ItemColorType)
            end
        end
    end

    -- 挖地模式下，计算颜色时要考虑到剩下的配置里面的神灯颜色，否则会
    -- 造成滚屏后可能出现3个同色神灯
    if mainLogic.theGamePlayType == GameModeTypeId.DIG_MOVE_ID 
        or mainLogic.theGamePlayType == GameModeTypeId.DIG_TIME_ID 
        or mainLogic.theGamePlayType == GameModeTypeId.DIG_MOVE_ENDLESS_ID
        or mainLogic.theGamePlayType == GameModeTypeId.MAYDAY_ENDLESS_ID
        or mainLogic.theGamePlayType == GameModeTypeId.HALLOWEEN_ID
        or mainLogic.theGamePlayType == GameModeTypeId.HEDGEHOG_DIG_ENDLESS_ID
        or mainLogic.theGamePlayType == GameModeTypeId.MOLE_WEEKLY_RACE_ID
        then
        local passedRow = mainLogic.passedRow
        local totalConfigRow = #mainLogic.digItemMap
        for r = passedRow + 1, totalConfigRow do 
            for c = 1, #mainLogic.digItemMap[r] do
                local item = mainLogic.digItemMap[r][c]
                if item and item.ItemType == GameItemType.kMagicLamp then
                    if item.lampLevel == 0 and item:isAvailable() then
                        table.insert(lamps, item)
                    end
                    addColorToBanlist(item._encrypt.ItemColorType)
                end
            end
        end
    end


    if #lamps == 0 then
        self:onActionComplete()
        return
    end

    local function isColorBanned(color)
        local originColor = AnimalTypeConfig.getOriginColorValue(color)
        return banColors[originColor] ~= nil and banColors[originColor] >= 2
    end


    local count = 0
    local function actionCallback()
        count = count + 1
        if count >= #lamps then
            self.hasItemToHandle = true
            self:onActionComplete()
        end
    end

    local function getTargetColors(possibleColors, specifyColors)
        local targetColors = {}
        if specifyColors then
            for i,color in ipairs(possibleColors) do
                if not isColorBanned(color) then
                    table.insert(targetColors, color)
                end
            end
        else
            for i, color in ipairs(mainLogic.mapColorList) do
                if table.exist(possibleColors, color) and not isColorBanned(color) then
                    table.insert(targetColors, color)
                end
            end
        end
        return targetColors
    end

    for k, item in pairs(lamps) do
        local shouldReinit = true
        local possibleColors, specifyColors = GameMapInitialLogic:getPossibleColorsForItem(mainLogic, item.y, item.x, item.blocker83Colors, false)
        local targetColors = getTargetColors(possibleColors, specifyColors)

        if #targetColors == 0 then
            --上一次筛选可随机颜色 考虑三消 没筛选到 触发第二次不考虑三消的筛选 
            possibleColors, specifyColors = GameMapInitialLogic:getPossibleColorsForItem(mainLogic, item.y, item.x, item.blocker83Colors, true)
            targetColors = getTargetColors(possibleColors, specifyColors)
            if #targetColors == 0 then
                --第二次不考虑三消还没筛选到 不再筛选 大眼仔一直置灰
                shouldReinit = false
            else
                --第二次筛选到了 循环多走一次
                self.context.needLoopCheck = true 
                self.needCheckMatch = true
            end
        end

        if shouldReinit then 
            local newColor = targetColors[mainLogic.randFactory:rand(1, #targetColors)]
            local originColor = AnimalTypeConfig.getOriginColorValue(newColor)
            if banColors[originColor] == nil then banColors[originColor] = 0 end
            banColors[originColor] = banColors[originColor] + 1

            item._encrypt.ItemColorType = newColor

            local reinitAction = GameBoardActionDataSet:createAs(
                            GameActionTargetType.kGameItemAction,
                            GameItemActionType.kItem_Magic_Lamp_Reinit,
                            IntCoord:create(item.y, item.x),
                            nil,
                            GamePlayConfig_MaxAction_time
                        )
            reinitAction.completeCallback = actionCallback
            reinitAction.color = newColor
            self.mainLogic:addGameAction(reinitAction)
        else
            actionCallback()
        end
    end
end

function MagicLampReinitState:getClassName()
    return "MagicLampReinitState"
end

function MagicLampReinitState:checkTransition()
    return self.nextState
end

function MagicLampReinitState:onActionComplete()
    if self.needCheckMatch then
        local result = ItemHalfStableCheckLogic:checkAllMapWithNoMove(self.mainLogic)
        self.nextState = self:getNextState()
        if result then
            self.mainLogic:setNeedCheckFalling()
        else
            self.context:onEnter()
        end
    else

        self.nextState = self:getNextState()
        if self.hasItemToHandle then
            self.context:onEnter()
        end
    end
end

function MagicLampReinitState:getNextState()
    return self.context.pacmanEatState
    --return self.context.dripCastingStateInLast_B
end

function MagicLampReinitState:onExit()
    BaseStableState.onExit(self)
    self.hasItemToHandle = nil
    self.nextState = nil
    self.needCheckMatch = nil
end

