
GameState = class()

function GameState:ctor()
	
end

function GameState:dispose()
	self.mainLogic = nil
end

function GameState:create(context)
	local v = GameState.new()
	v.context = context
	v.mainLogic = context.mainLogic
	v.boardView = v.mainLogic.boardView
	return v
end

function GameState:update(dt)
	
end

function GameState:onEnter()
	
end

function GameState:onExit()
	
end

function GameState:checkTransition()
	
end

function GameState:afterRefreshStable(isEnterWaiting)
	
end

function GameState:boardStableHandler()
	
end

function GameState:startSwapHandler()
	
end