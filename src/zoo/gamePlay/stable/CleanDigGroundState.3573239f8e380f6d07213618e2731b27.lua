CleanDigGroundState = class(BaseStableState)

function CleanDigGroundState:dispose()
	self.mainLogic = nil
	self.boardView = nil
	self.context = nil
end

function CleanDigGroundState:create(context)
	local v = CleanDigGroundState.new()
	v.context = context
	v.mainLogic = context.mainLogic
	v.boardView = v.mainLogic.boardView
	return v
end

function CleanDigGroundState:onEnter()
	BaseStableState.onEnter(self)
	self.nextState = nil

    if(not self.mainLogic._fieldLogicPossibility[_FIELD_LOGIC_ID.dig]) then
        printx(0, '!skip')
		self.nextState = self:getNextState()
        return
    end

	local function callback( ... )
		-- body
		self.nextState = self
		self.context.needLoopCheck = true
	end

	if self.mainLogic.theGamePlayType == GameModeTypeId.HEDGEHOG_DIG_ENDLESS_ID then
		self.total = self.mainLogic.gameMode:checkNeedBombDigGround(callback)
		if self.total ==0 then
			self.nextState = self:getNextState()
		end

		-- self.mainLogic:setNeedCheckFalling()
	else
		self.nextState = self:getNextState()
	end
end

function CleanDigGroundState:getNextState()
	return nil
end

function CleanDigGroundState:onExit()
	BaseStableState.onExit(self)
	self.nextState = nil
	self.total = 0 

end

function CleanDigGroundState:checkTransition()
	return self.nextState
end

function CleanDigGroundState:getClassName()
	return "CleanDigGroundState"
end

CleanDigGroundStateInLoop = class(CleanDigGroundState)
function CleanDigGroundStateInLoop:create(context)
    local v = CleanDigGroundStateInLoop.new()
    v.context = context
    v.mainLogic = context.mainLogic
    v.boardView = v.mainLogic.boardView
    return v
end

function CleanDigGroundStateInLoop:getClassName()
	return "CleanDigGroundStateInLoop"
end

function CleanDigGroundStateInLoop:getNextState()
	-- return self.context.checkNeedLoopState
	return self.context.dripCastingStateInLast
end