GameOverState = class(BaseStableState)

function GameOverState:dispose()
	self.mainLogic = nil
	self.boardView = nil
	self.context = nil
end

function GameOverState:create(context)
	local v = GameOverState.new()
	v.context = context
	v.mainLogic = context.mainLogic
	v.boardView = v.mainLogic.boardView
	return v
end

function GameOverState:update(dt)
	self.timeCount = self.timeCount + 1
	if self.timeCount > 30 then
		self.context:onExit()
		self.mainLogic:setGamePlayStatus(GamePlayStatus.kAferBonus)
	end
end

function GameOverState:onEnter()
	if _G.isLocalDevelopMode then printx(0, "---->>>> game over state enter") end

	self.nextState = nil
	self.timeCount = 0
end

function GameOverState:onExit()
	if _G.isLocalDevelopMode then printx(0, "----<<<< game over state exit") end
	
	self.nextState = nil
end

function GameOverState:checkTransition()
	return self.nextState
end
