CheckHedgehogCrazyState = class(BaseStableState)

function CheckHedgehogCrazyState:create( context )
    -- body
    local v = CheckHedgehogCrazyState.new()
    v.context = context
    v.mainLogic = context.mainLogic  --gameboardlogic
    v.boardView = v.mainLogic.boardView
    return v
end

function CheckHedgehogCrazyState:onEnter()
    BaseStableState.onEnter(self)
    self.nextState = nil
    local function _complete( ... )
        -- body
        self:handleComplete()
    end
    local count = GameExtandPlayLogic:checkIsReleaseEnery( self.mainLogic, _complete )
    if count > 0 then
        self.hasItemToHandle = true
    else
        _complete()
    end
end

function CheckHedgehogCrazyState:handleComplete()
    --self.nextState = self.context.needRefreshState
    self.nextState = self.context.wukongCheckJumpState
    if self.hasItemToHandle then
        local r, c = self.mainLogic.gameMode:findHedgehogRC()
        if r and c then 
            local pos = {r = r, c = c}
            GameGuide:sharedInstance():onHedgehogCrazy(pos)
        end
        self.mainLogic.isHedgehogCrazy = true
        self.context:onEnter()
    end
end

function CheckHedgehogCrazyState:onExit()
    BaseStableState.onExit(self)
    self.nextState = nil
    self.hasItemToHandle = false
end

function CheckHedgehogCrazyState:checkTransition()
    return self.nextState
end

function CheckHedgehogCrazyState:getClassName()
    return "CheckHedgehogCrazyState"
end