WukongReinitState = class(BaseStableState)

function WukongReinitState:create(context)
    local v = WukongReinitState.new()
    v.context = context
    v.mainLogic = context.mainLogic
    v.boardView = v.mainLogic.boardView
    return v
end

function WukongReinitState:dispose()
    self.mainLogic = nil
    self.boardView = nil
    self.context = nil
end

function WukongReinitState:update(dt)
    
end

function WukongReinitState:onEnter()
    BaseStableState.onEnter(self)
    self.nextState = nil
    self.hasItemToHandle = false

    if(not self.mainLogic._fieldLogicPossibility[_FIELD_LOGIC_ID[GameItemType.kWukong]]) then
        printx(0, '!skip')
        self:onActionComplete()
        return
    end

    self:tryHandleReinit()
    --self.nextState = self:getNextState()
end

function WukongReinitState:tryHandleReinit()
    local mainLogic = self.mainLogic
    local gameItemMap = mainLogic.gameItemMap
    local boardmap = mainLogic.boardmap

    -- bonus time
    if mainLogic.isBonusTime then
        self:onActionComplete()
        return
    end

    -- get the wukongs
    local wukongs = {}
    for r = 1, #gameItemMap do
        for c = 1, #gameItemMap[r] do
            local item = gameItemMap[r][c]
            if item and item.ItemType == GameItemType.kWukong then
                if item:isAvailable() and item.wukongState == TileWukongState.kReadyToChangeColor then
                    table.insert(wukongs, item)
                end
            end
        end
    end

    local wukongTargets = {}
    local wukongTargetsPosition = {}

    for r = 1, #boardmap do
        for c = 1, #boardmap[r] do
            local board = boardmap[r][c]
            if board and board.isWukongTarget then
                table.insert( wukongTargets, board )
                table.insert( wukongTargetsPosition, IntCoord:create(r, c) )
            end
        end
    end

    local count = 0
    local function actionCallback ()
        count = count + 1
        if count >= #wukongs then
            self.hasItemToHandle = true
            self:onActionComplete()
        end
    end

    if #wukongs == 0 then
        self:onActionComplete()
        return
    end

    for k, item in pairs(wukongs) do
        local newColor = GameExtandPlayLogic:getRandomColorByDefaultLogic( mainLogic, item.y, item.x )

        local reinitAction = GameBoardActionDataSet:createAs(
                        GameActionTargetType.kGameItemAction,
                        GameItemActionType.kItem_Wukong_Reinit,
                        IntCoord:create(item.y, item.x),
                        nil,
                        GamePlayConfig_MaxAction_time
                    )
        reinitAction.completeCallback = actionCallback
        reinitAction.color = newColor
        reinitAction.wukongTargetsPosition = wukongTargetsPosition
        
        self.mainLogic:addGameAction(reinitAction)
    end
end

function WukongReinitState:getClassName()
    return "WukongReinitState"
end

function WukongReinitState:checkTransition()
    return self.nextState
end

function WukongReinitState:onActionComplete()

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

function WukongReinitState:getNextState()
    return self.context.cleanDigGroundStateInLoop
end

function WukongReinitState:onExit()
    BaseStableState.onExit(self)
    self.hasItemToHandle = nil
    self.nextState = nil
    self.needCheckMatch = nil
end