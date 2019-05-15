
EndCycleStateEnter = class(BaseStableState)

function EndCycleStateEnter:dispose()
	self.mainLogic = nil
	self.boardView = nil
	self.context = nil
end

function EndCycleStateEnter:create(context)
	local v = EndCycleStateEnter.new()
	v.context = context
	v.mainLogic = context.mainLogic
	v.boardView = v.mainLogic.boardView
	return v
end

function EndCycleStateEnter:onEnter()
	BaseStableState.onEnter(self)
	self.context.balloonCheckStateInLoop:resetExcuteNum()
	self.context.tileBlockerStateInLoop:resetExcuteNum()
	self.nextState =self:getNextState()
end

function EndCycleStateEnter:onExit()
	BaseStableState.onExit(self)
	self.nextState = nil
	self.hasItemToHandle = false

	self.totalFurballSplitToHandle = 0
	self.counterFurballSplitToHandle = 0
end

function EndCycleStateEnter:getNextState()
	return self.context.dripCastingStateInLoop
end

function EndCycleStateEnter:checkTransition()
	return self.nextState
end

function EndCycleStateEnter:getClassName()
	return "EndCycleStateEnter"
end