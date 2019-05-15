Blocker211State = class(BaseStableState)

function Blocker211State:create(context)
    local v = Blocker211State.new()
    v.context = context
    v.mainLogic = context.mainLogic
    v.boardView = v.mainLogic.boardView
    return v
end

function Blocker211State:dispose()
    self.mainLogic = nil
    self.boardView = nil
    self.context = nil
end

function Blocker211State:update(dt)
    
end

function Blocker211State:onEnter()
    -- printx(5, 'Blocker211State:onEnter()')
    BaseStableState.onEnter(self)
    self.nextState = nil
    self.hasItemToHandle = false

    if(not self.mainLogic._fieldLogicPossibility[_FIELD_LOGIC_ID[GameItemType.kBlocker211]]) then
        self:onActionComplete()
        return
    end

    if self.mainLogic.isBonusTime then
        self:onActionComplete()
        return
    end

    self:tryChangeFlag()
end

function Blocker211State:tryChangeFlag()
    -- printx(5, 'Blocker211State:tryChangeFlag')
    local mainLogic = self.mainLogic
    local gameItemMap = mainLogic.gameItemMap

    for r = 1, #gameItemMap do
        for c = 1, #gameItemMap[r] do
            local item = gameItemMap[r][c]
            local itemView = mainLogic.boardView.baseMap[r][c] 
            if item and item.ItemType == GameItemType.kBlocker211 and item.flag then
                item.flag = false
                itemView:renewBlocker211IdleAnimation(item)
            end
        end
    end

    self:onActionComplete()
    return
end

function Blocker211State:getClassName()
    return "Blocker211State"
end

function Blocker211State:checkTransition()
    return self.nextState
end

function Blocker211State:onActionComplete()
    self.nextState = self:getNextState()
end

function Blocker211State:getNextState()
    return self.context.ghostAppearState
    -- return self.context.needRefreshState
    --return self.context.wukongReinitState
end

function Blocker211State:onExit()
    BaseStableState.onExit(self)
    self.hasItemToHandle = nil
    self.nextState = nil
    self.needCheckMatch = nil
end