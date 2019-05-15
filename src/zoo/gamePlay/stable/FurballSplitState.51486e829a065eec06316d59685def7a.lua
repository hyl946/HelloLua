
FurballSplitState = class(BaseStableState)

function FurballSplitState:dispose()
	self.mainLogic = nil
	self.boardView = nil
	self.context = nil
end

function FurballSplitState:create(context)
	local v = FurballSplitState.new()
	v.context = context
	v.mainLogic = context.mainLogic
	v.boardView = v.mainLogic.boardView
	return v
end

function FurballSplitState:onEnter()
	BaseStableState.onEnter(self)
	self.nextState = nil
	self.hasItemToHandle = false

	self.totalFurballSplitToHandle = 0
	self.counterFurballSplitToHandle = 0

    if(not self.mainLogic._fieldLogicPossibility[_FIELD_LOGIC_ID.GameItemFurballType_kBrown]) then
        printx(0, '!skip')
		self:handleFurballSplitComplete()
        return
    end


	self:tryHandleFurballSplit()
end

function FurballSplitState:tryHandleFurballSplit()
	local context = self
	local function splitComplete()
		context:handleFurballSplitComplete()
	end

	self.totalFurballSplitToHandle = GameExtandPlayLogic:checkFurballSplit(self.mainLogic, splitComplete)
	if self.totalFurballSplitToHandle == 0 then
		self:handleFurballSplitComplete()
	else
		self.hasItemToHandle = true
	end
end
	
function FurballSplitState:handleFurballSplitComplete()
	self.counterFurballSplitToHandle = self.counterFurballSplitToHandle + 1
	if self.counterFurballSplitToHandle >= self.totalFurballSplitToHandle then
		self.nextState = self:getNextState()
		if self.hasItemToHandle then
			self.context:onEnter()
		end
	end
end

function FurballSplitState:onExit()
	BaseStableState.onExit(self)
	self.nextState = nil
	self.hasItemToHandle = false

	self.totalFurballSplitToHandle = 0
	self.counterFurballSplitToHandle = 0
end

function FurballSplitState:getNextState()
	return self.context.digScrollGroundState
end

function FurballSplitState:checkTransition()
	return self.nextState
end

function FurballSplitState:getClassName()
	return "FurballSplitState"
end

FurballSplitStateInPropFirst = class(FurballSplitState)
function FurballSplitStateInPropFirst:create( context )
	-- body
	local v = FurballSplitStateInPropFirst.new()
	v.context = context
	v.mainLogic = context.mainLogic
	v.boardView = v.mainLogic.boardView
	return v
end

function FurballSplitStateInPropFirst:getNextState()
	return self.context.endCycleStateEnter
end

function FurballSplitStateInPropFirst:getClassName( ... )
	-- body
	return "FurballSplitStateInPropFirst"
end

FurballSplitStateInSwapFirst = class(FurballSplitState)

function FurballSplitStateInSwapFirst:create(context)
	local v = FurballSplitStateInSwapFirst.new()
	v.context = context
	v.mainLogic = context.mainLogic
	v.boardView = v.mainLogic.boardView
	return v
end

function FurballSplitStateInSwapFirst:getClassName()
	return "FurballSplitStateInSwapFirst"
end

function FurballSplitStateInSwapFirst:getNextState()
	return self.context.generateBlockerCoverStateInSwapFirst
end

FurballSplitStateInLoop = class(FurballSplitState)
function FurballSplitStateInLoop:create(context)
	local v = FurballSplitStateInLoop.new()
	v.context = context
	v.mainLogic = context.mainLogic
	v.boardView = v.mainLogic.boardView
	return v
end

function FurballSplitStateInLoop:getClassName()
	return "FurballSplitStateInLoop"
end

function FurballSplitStateInLoop:getNextState()
	return self.context.moleWeeklyBossStateInLoop
end