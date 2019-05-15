
BonusAutoBombState = class(BaseStableState)

function BonusAutoBombState:dispose()
	self.mainLogic = nil
	self.boardView = nil
	self.context = nil
end

function BonusAutoBombState:create(context)
	local v = BonusAutoBombState.new()
	v.context = context
	v.mainLogic = context.mainLogic
	v.boardView = v.mainLogic.boardView
	return v
end

function BonusAutoBombState:onEnter()
	BaseStableState.onEnter(self)
	self.timeCount = 0
	self.nextState = nil
	self.waitCount = 0
	self.hasItemToHandle = BombItemLogic:BonusTime_RandomBombOne(self.mainLogic, false)
end

function BonusAutoBombState:onExit()
	BaseStableState.onExit(self)
	self.timeCount = 0
	self.waitCount = 0
	self.nextState = nil
end

function BonusAutoBombState:update(dt)
	if self.isUpdateStopped then return end
	
	self.timeCount = self.timeCount + 1
	if self.timeCount >= GamePlayConfig_BonusTime_RandomBomb_CD then
		self.timeCount = 0
		local result = BombItemLogic:BonusTime_RandomBombOne(self.mainLogic, true)
		if not result then
			self.nextState = self:getNextState()
			if self.mainLogic.isFallingStable and self.mainLogic.isFallingStablePreFrame then
				self.context:onEnter()
			end
		end
	end
end

function BonusAutoBombState:checkTransition()
	return self.nextState
end

function BonusAutoBombState:getClassName( ... )
	return "BonusAutoBombState"
end

function BonusAutoBombState:getNextState( ... )
	return self.context.roostReplaceStateInBonusFirst
end
