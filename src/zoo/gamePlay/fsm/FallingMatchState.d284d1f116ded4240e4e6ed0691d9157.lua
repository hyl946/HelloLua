require "zoo.gamePlay.fsm.GameState"
require "zoo.gamePlay.stable.StableStateMachine"


FallingMatchState = class(GameState)

function FallingMatchState:create(context)
	local v = FallingMatchState.new()
	v.context = context
	v.mainLogic = context.mainLogic
	v.boardView = context.mainLogic.boardView

	local stableFSM = StableStateMachine:create(v)
	v.stableFSM = stableFSM
	return v
end

function FallingMatchState:dispose()
	v.mainLogic = nil
	v.boardView = nil
	v.context = nil

	v.stableFSM:dispose()
	v.stableFSM = nil
end

function FallingMatchState:update(dt)
	self.mainLogic:fallingMatchUpdate(dt)
	self.stableFSM:update(dt)
end

function FallingMatchState:onEnter()
	if _G.isLocalDevelopMode then printx( -1 , ">>>>>>>>>>>>>>>>>falling state enter") end
	self.nextState = nil

	TimelyHammerGuideMgr.getInstance():hideGuide()

    -- if(forceGcMemory) then forceGcMemory() end

	-- require("hecore/profiler"):resume()

	-- local OnlinePerformanceLog = require("hecore.debug.OnlinePerformanceLog")
	-- if(OnlinePerformanceLog:enabled()) then
	-- 	self._performanceLog = OnlinePerformanceLog:new('FallingMatchState:onEnter')
	-- end

end

function FallingMatchState:onExit()
	if _G.isLocalDevelopMode then printx( -1 , "<<<<<<<<<<<<<<<<<falling state exit") end
	self.nextState = nil

	-- require("hecore/profiler"):pause()
	-- if(self._performanceLog) then
	-- 	self._performanceLog:free()
	-- 	self._performanceLog = nil
	-- end
end

function FallingMatchState:afterRefreshStable(isEnterWaiting)
	if isEnterWaiting then
		self.nextState = self.context.waitingState
	end
	self.stableFSM:onExit()
end

function FallingMatchState:boardStableHandler()
	self.stableFSM:onEnter()
end

function FallingMatchState:checkTransition()
	return self.nextState
end