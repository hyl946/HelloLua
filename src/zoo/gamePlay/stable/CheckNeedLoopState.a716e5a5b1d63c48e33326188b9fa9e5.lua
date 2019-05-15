
CheckNeedLoopState = class(BaseStableState)

function CheckNeedLoopState:dispose()
	self.mainLogic = nil
	self.boardView = nil
	self.context = nil
end

function CheckNeedLoopState:create(context)
	local v = CheckNeedLoopState.new()
	v.context = context
	v.mainLogic = context.mainLogic
	v.boardView = v.mainLogic.boardView
	return v
end

function CheckNeedLoopState:onEnter()
	BaseStableState.onEnter(self)

	if self.context.needLoopCheck then
		self.context.needLoopCheck = false
		self.nextState = self.context.dripCastingStateInLoop
		if _G.isLocalDevelopMode then printx(0, "----------------------------- need loop once, skip refresh check") end
	else
		self.nextState = self.context.moleWeeklyBossCastSkillState
	end
end

function CheckNeedLoopState:onExit()
	BaseStableState.onExit(self)

	self.nextState = nil
end

function CheckNeedLoopState:checkTransition()
	return self.nextState
end

function CheckNeedLoopState:getClassName()
	return "CheckNeedLoopState"
end

