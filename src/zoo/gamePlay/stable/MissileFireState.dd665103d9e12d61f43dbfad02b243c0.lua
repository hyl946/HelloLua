MissileFireState = class(BaseStableState)

function MissileFireState:create(context)
    local v = MissileFireState.new()
    v.context = context
    v.mainLogic = context.mainLogic
    v.boardView = v.mainLogic.boardView
    return v
end

function MissileFireState:dispose()
    self.mainLogic = nil
    self.boardView = nil
    self.context = nil
end

function MissileFireState:update(dt)
end

function MissileFireState:onEnter()
    BaseStableState.onEnter(self)
    self.nextState = nil
    self.hasItemToHandle = false
    self.mainLogic.missileHasHitPoint = {}

    if(not self.mainLogic._fieldLogicPossibility[_FIELD_LOGIC_ID[GameItemType.kMissile]]) then
        printx(0, '!skip')
        self:setNextState()
        return
    end

    self:tryHandleFire()
end


function MissileFireState:tryHandleFire()
    
    local function handleComplete()
        
        -- 存在掉落连消
        -- local remainMissiles = GameExtandPlayLogic:checkMissile(self.mainLogic)
        -- if ( #remainMissiles> 0) then
        --      GameExtandPlayLogic:fireMissiles(self.mainLogic,remainMissiles,handleComplete)
        -- else
        --     self:setNextState()
        --     if _G.isLocalDevelopMode then printx(0, "------------- missile to next state -------------------") end
        -- end

        -- if self.hasItemToHandle then
        --     self.mainLogic:setNeedCheckFalling();
        -- end

        self:setNextState()
    end

    local mainLogic = self.mainLogic
    local findMissiles = GameExtandPlayLogic:checkMissile(mainLogic)
    

    if (#findMissiles >0) then
        self.hasItemToHandle = true
        self.context.needLoopCheck = true
    else
        self.hasItemToHandle = false
    end

    -- if _G.isLocalDevelopMode then printx(0, "has missile will fire ? " , self.hasItemToHandle) end
    -- debug.debug()
    if (not self.hasItemToHandle) then
        handleComplete()
    else
        GameExtandPlayLogic:fireMissiles(mainLogic,findMissiles,handleComplete)
    end
end


function MissileFireState:getClassName()
    return "MissileFireState"
end

function MissileFireState:checkTransition()
    return self.nextState
end

function MissileFireState:onActionComplete()

end

function MissileFireState:setNextState()
    -- self.nextState =  self.context.magicLampReinitState
end

function MissileFireState:onExit()
    BaseStableState.onExit(self)
    self.mainLogic.missileHasHitPoint = {}
    self.hasItemToHandle = nil
    self.nextState = nil
end





-- ============================================




MissileFireFirstState = class(MissileFireState)
function MissileFireFirstState:create(context)
    local v = MissileFireFirstState.new()
    v.context = context
    v.mainLogic = context.mainLogic
    v.boardView = v.mainLogic.boardView
    return v 
end
function MissileFireFirstState:getClassName()
    return "MissileFireFirstState"
end

function MissileFireFirstState:setNextState()
    self.nextState =  self.context.buffBoomCastingStateInSwapFirst 
    -- self.nextState =  self.context.transmissionState 
end

MissileFireInLoopState = class(MissileFireState)
function MissileFireInLoopState:create(context)
    local v = MissileFireInLoopState.new()
    v.context = context
    v.mainLogic = context.mainLogic
    v.boardView = v.mainLogic.boardView
    return v
end

function MissileFireInLoopState:getClassName()
    return "MissileFireInLoopState"
end

function MissileFireInLoopState:setNextState()
    --self.nextState =  self.context.magicLampCastingStateInLoop
    self.nextState =  self.context.buffBoomCastingStateInLoop
end