
ColorFilterAState = class(BaseStableState)

function ColorFilterAState:create(context)
    local v = ColorFilterAState.new()
    v.context = context
    v.mainLogic = context.mainLogic
    v.boardView = v.mainLogic.boardView
    return v
end

function ColorFilterAState:dispose()
    self.mainLogic = nil
    self.boardView = nil
    self.context = nil
end

function ColorFilterAState:update(dt)
end

function ColorFilterAState:onEnter()
    BaseStableState.onEnter(self)
    self.nextState = nil
    self.hasItemToHandle = false

    if(not self.mainLogic._fieldLogicPossibility[_FIELD_LOGIC_ID.colorFilter]) then
        printx(0, '!skip')
		self:onActionComplete()
        return
    end

    self:tryFilter() 
end

function ColorFilterAState:tryFilter()
	local mainLogic = self.mainLogic
    local gameItemMap = mainLogic.gameItemMap
    local gameBoardMap = mainLogic.boardmap

    local shouldFilter = false
    for r = 1, #gameItemMap do 
        for c = 1, #gameItemMap[r] do
	        if not shouldFilter then 
	        	shouldFilter = ColorFilterLogic:handleFilter(r, c, function ()
	      			self:onActionComplete()
	        	end)
	        else
				ColorFilterLogic:handleFilter(r, c, function ()
	      			self:onActionComplete()
	        	end)
	        end
        end
    end

    if shouldFilter then 
		self.context.needLoopCheck = true
	else
		self:onActionComplete()
    end
end

function ColorFilterAState:getClassName()
    return "ColorFilterAState"
end

function ColorFilterAState:checkTransition()
    return self.nextState
end

function ColorFilterAState:onActionComplete()
    self.nextState = self:getNextState()	
end

function ColorFilterAState:getNextState()
    -- return self.context.dripCastingStateInLoop
    return self.context.missileFireInLoopState
end

function ColorFilterAState:onExit()
    BaseStableState.onExit(self)
    self.hasItemToHandle = nil
    self.nextState = nil
end
