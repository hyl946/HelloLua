require "zoo.gamePlay.fsm.WaitingState"
require "zoo.gamePlay.fsm.FallingMatchState"
require "zoo.gamePlay.fsm.SwapState"
require "zoo.gamePlay.fsm.UsePropState"

StateMachine = class()

function StateMachine:ctor()
	self.currentState = nil
end

function StateMachine:dispose()
	self.mainLogic = nil
	self.currentState = nil

	self.waitingState = nil
	self.fallingMatchState = nil
	self.swapState = nil
	self.usePropState = nil
end

function StateMachine:create(mainLogic)
	local v = StateMachine.new()
	v.mainLogic = mainLogic
	v:initStates()
	return v
end

function StateMachine:initStates()
	local waitingState = WaitingState:create(self)
	local fallingMatchState = FallingMatchState:create(self)
	local swapState = SwapState:create(self)
	local usePropState = UsePropState:create(self)

	self.waitingState = waitingState
	self.fallingMatchState = fallingMatchState
	self.swapState = swapState
	self.usePropState = usePropState
end

function StateMachine:initState()
	self:changeState(self.fallingMatchState)
end

function StateMachine:update(dt)
	self.mainLogic:updateGlobalCoreAction(dt)
	if self.currentState then
		self:changeState(self.currentState:checkTransition())
		self.currentState:update(dt)
	end
end

function StateMachine:changeState(target)
	if target ~= nil then
		if self.currentState then
			self.currentState:onExit()
		end
		self.currentState = target
		self.currentState:onEnter()
	end
end

function StateMachine:afterRefreshStable(isEnterWaiting)
	if self.currentState then
		self.currentState:afterRefreshStable(isEnterWaiting)
	end
end

function StateMachine:boardStableHandler()
	if self.currentState then
		self.currentState:boardStableHandler()
	end
end

function StateMachine:onStartSwap()
	if self.currentState == self.waitingState then
		self.currentState:startSwapHandler()
	end
end