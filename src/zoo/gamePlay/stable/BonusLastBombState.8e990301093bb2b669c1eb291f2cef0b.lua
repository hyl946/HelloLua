
BonusLastBombState = class(BaseStableState)

function BonusLastBombState:dispose()
	self.mainLogic = nil
	self.boardView = nil
	self.context = nil
end

function BonusLastBombState:create(context)
	local v = BonusLastBombState.new()
	v.context = context
	v.mainLogic = context.mainLogic
	v.boardView = v.mainLogic.boardView
	return v
end

function BonusLastBombState:onEnter()
	BaseStableState.onEnter(self)

	self.timeCount = 0
	self.nextState = nil
end

function BonusLastBombState:onExit()
	BaseStableState.onExit(self)
	self.timeCount = 0
	self.nextState = nil
end

function BonusLastBombState:update(dt)
	if self.isUpdateStopped then return end
	self.timeCount = self.timeCount + 1
	if self.timeCount > GamePlayConfig_BonusTime_ItemBomb_CD then
		local bombRet = BombItemLogic:BonusTime_RandomBombOne(self.mainLogic, true)
		if not bombRet then
			self.nextState = self:getNextState()
			if self.mainLogic.isFallingStable and self.mainLogic.isFallingStablePreFrame and self.mainLogic.isRealFallingStable then
				self.context:onEnter()
			end
		end
	end
end

function BonusLastBombState:checkTransition()
	return self.nextState
end

function BonusLastBombState:getClassName( ... )
	return "BonusLastBombState"
end

function BonusLastBombState:getNextState( ... )
	return self.context.roostReplaceStateInBonusSecond
end
