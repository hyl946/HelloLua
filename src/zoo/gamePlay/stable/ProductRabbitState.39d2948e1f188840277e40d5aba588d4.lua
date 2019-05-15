ProductRabbitState = class(BaseStableState)

function ProductRabbitState:create( context )
    -- body
    local v = ProductRabbitState.new()
    v.context = context
    v.mainLogic = context.mainLogic  --gameboardlogic
    v.boardView = v.mainLogic.boardView
    return v
end

function ProductRabbitState:update( ... )
    -- body
end

function ProductRabbitState:onEnter()
    BaseStableState.onEnter(self)
    self.nextState = nil
    local function callback( ... )
        -- if _G.isLocalDevelopMode then printx(0, 'ProductRabbitState:onEnter() callback') end
        self:handleComplete();
    end

    if self.mainLogic.gameMode:is(RabbitWeeklyMode) then
        GameExtandPlayLogic:resetRabbitItemState(self.mainLogic)
        self.hasItemToHandle = false
        local genCount = self.mainLogic.gameMode:getGenerateCount(self.mainLogic.realCostMove)

        self.complete = 0
        self.total = ProductItemLogic:productRabbit( self.mainLogic, genCount, callback ) -- todo
        if self.total == 0 then
            self:handleComplete()
        else
            self.hasItemToHandle = true
        end
    else
        self.nextState = self:getNextState()
    end
end

function ProductRabbitState:handleComplete( ... )
    self.complete = self.complete + 1 
    if self.complete >= self.total then
        self.nextState = self:getNextState()
        if self.hasItemToHandle then
            self.mainLogic:setNeedCheckFalling()
        end
    end
end

function ProductRabbitState:getNextState()
    return self.context.ufoUpdateState
end

function ProductRabbitState:onExit()
    BaseStableState.onExit(self)
    self.nextState = nil
    self.complete = 0
    self.total = 0
    self.hasItemToHandle = false
end

function ProductRabbitState:checkTransition()
    return self.nextState
end

function ProductRabbitState:getClassName()
    return "ProductRabbitState"
end