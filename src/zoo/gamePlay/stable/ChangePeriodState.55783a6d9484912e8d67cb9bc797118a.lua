ChangePeriodState = class(BaseStableState)
function ChangePeriodState:create( context )
	-- body
	local v = ChangePeriodState.new()
	v.context = context
	v.mainLogic = context.mainLogic  --gameboardlogic
	v.boardView = v.mainLogic.boardView
	return v
end

function ChangePeriodState:update( ... )
	-- body
end

function ChangePeriodState:onEnter()
	BaseStableState.onEnter(self)
	self.nextState = nil
	self.isNeedChangeState = false
	local function animationCallback()
		self:handleComplete()
	end
	
	if self.mainLogic.gameMode:is(RabbitWeeklyMode) and self.mainLogic.gameMode:isNeedChangeState(animationCallback, true) then
		self.isNeedChangeState = true
	else
		animationCallback()
	end
end

function ChangePeriodState:handleComplete( ... )
	-- body
	if self.isNeedChangeState then
		BombItemLogic:bombAllColorItem(self.mainLogic)
		self.mainLogic:setNeedCheckFalling()
	end
	self.nextState = self.context.mimosaState
end

function ChangePeriodState:onExit()
	BaseStableState.onExit(self)
	self.nextState = nil
end

function ChangePeriodState:checkTransition()
	return self.nextState
end

function ChangePeriodState:getClassName()
	return "ChangePeriodState"
end