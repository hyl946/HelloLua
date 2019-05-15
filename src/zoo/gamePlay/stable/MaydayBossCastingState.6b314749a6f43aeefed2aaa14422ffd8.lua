MaydayBossCastingState = class(BaseStableState)

function MaydayBossCastingState:create( context )
    -- body
    local v = MaydayBossCastingState.new()
    v.context = context
    v.mainLogic = context.mainLogic  --gameboardlogic
    v.boardView = v.mainLogic.boardView
    return v
end

function MaydayBossCastingState:onEnter()
    BaseStableState.onEnter(self)
    self.nextState = nil

    if(not self.mainLogic._fieldLogicPossibility[_FIELD_LOGIC_ID[GameItemType.kBoss]]) then
        printx(0, '!skip')
        self:handleComplete(false)
        return 0
    end


    local total = 0

    local count = 0
    local function callback()
        count = count + 1
        if count >= total then
            self:handleComplete(true)
        end
    end
    total = GameExtandPlayLogic:checkBossCasting(self.mainLogic, callback)
    -- if _G.isLocalDevelopMode then printx(0, 'MaydayBossCastingState total=', total) end

    if total == 0 then
        self:handleComplete(false)
    end

end

function MaydayBossCastingState:handleComplete(hasHandledItem)
    -- self.nextState = self.context.chickenMotherState
    self.nextState = self.context.magicLampReinitState
    if hasHandledItem then
        self.context:onEnter()
    end
end

function MaydayBossCastingState:onExit()
    BaseStableState.onExit(self)
    self.nextState = nil

end

function MaydayBossCastingState:checkTransition()
    return self.nextState
end

function MaydayBossCastingState:getClassName()
    return "MaydayBossCastingState"
end