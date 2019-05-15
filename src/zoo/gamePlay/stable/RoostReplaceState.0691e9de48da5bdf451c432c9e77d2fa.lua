
RoostReplaceState = class(BaseStableState)

function RoostReplaceState:dispose()
	self.mainLogic = nil
	self.boardView = nil
	self.context = nil
end

function RoostReplaceState:create(context)
	local v = RoostReplaceState.new()
	v.context = context
	v.mainLogic = context.mainLogic
	v.boardView = v.mainLogic.boardView
	return v
end

function RoostReplaceState:onEnter()
	BaseStableState.onEnter(self)
	local context =self
	local function replaceComplete()
		context:roostReplaceComplete()
	end

	self.nextState = nil


    if(not self.mainLogic._fieldLogicPossibility[_FIELD_LOGIC_ID[GameItemType.kRoost]]) then
        printx(0, '!skip')
		self.nextState = self:getNextState()
        return
    end

	
	self.counterRoostReplaceToHandle = 0
	self.totalRoostReplaceToHandle = GameExtandPlayLogic:checkRoostReplace(self.mainLogic, replaceComplete)
	if self.totalRoostReplaceToHandle == 0 then
		self.nextState = self:getNextState()
	else
		self.context.needLoopCheck = true
	end
end

function RoostReplaceState:roostReplaceComplete()
	self.counterRoostReplaceToHandle = self.counterRoostReplaceToHandle + 1
	if self.counterRoostReplaceToHandle >= self.totalRoostReplaceToHandle then
		local result = ItemHalfStableCheckLogic:checkAllMapWithNoMove(self.mainLogic)
		if result then
			self.mainLogic:setNeedCheckFalling()
			self.nextState = self
		else
			self.nextState = self:getNextState()
			self.mainLogic:setNeedCheckFalling()
			-- self.context:onEnter()
		end
	end
end

function RoostReplaceState:onExit()
	BaseStableState.onExit(self)
	self.nextState = nil
	self._nextState = nil
	self.counterRoostReplaceToHandle = 0
	self.totalRoostReplaceToHandle = 0
end

function RoostReplaceState:checkTransition()
	return self.nextState
end

function RoostReplaceState:getNextState()
	return nil
end

RoostReplaceStateInSwapFirst = class(RoostReplaceState)

function RoostReplaceStateInSwapFirst:create(context)
	local v = RoostReplaceStateInSwapFirst.new()
	v.context = context
	v.mainLogic = context.mainLogic
	v.boardView = v.mainLogic.boardView
	return v
end

function RoostReplaceStateInSwapFirst:getNextState()
	return self.context.inactiveBlockerState
end

function RoostReplaceStateInSwapFirst:getClassName()
	return "RoostReplaceStateInSwapFirst"
end

RoostReplaceStateInLoop = class(RoostReplaceState)
function RoostReplaceStateInLoop:create(context)
	local v = RoostReplaceStateInLoop.new()
	v.context = context
	v.mainLogic = context.mainLogic
	v.boardView = v.mainLogic.boardView
	return v
end

function RoostReplaceStateInLoop:getClassName()
	return "RoostReplaceStateInLoop"
end

function RoostReplaceStateInLoop:getNextState()
	return self.context.colorFilterAState
end

RoostReplaceStateInBonusFirst = class(RoostReplaceState)
function RoostReplaceStateInBonusFirst:create( context )
	-- body
	local v = RoostReplaceStateInBonusFirst.new()
	v.context = context
	v.mainLogic = context.mainLogic
	v.boardView = v.mainLogic.boardView
	return v
end

function RoostReplaceStateInBonusFirst:getNextState( ... )
	-- body
	return self.context.bonusStepToLineState
end

function RoostReplaceStateInBonusFirst:getClassName( ... )
	-- body
	return "RoostReplaceStateInBonusFirst"
end

RoostReplaceStateInBonusSecond = class(RoostReplaceState)
function RoostReplaceStateInBonusSecond:create( context )
	-- body
	local v = RoostReplaceStateInBonusSecond.new()
	v.context = context
	v.mainLogic = context.mainLogic
	v.boardView = v.mainLogic.boardView
	return v
end

function RoostReplaceStateInBonusSecond:getNextState( ... )
	-- body
	-- return self.context.gameOverState
	return self.context.moleWeeklyBossStateInBonus
end

function RoostReplaceStateInBonusSecond:getClassName( ... )
	-- body
	return "RoostReplaceStateInBonusSecond"
end