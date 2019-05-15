HoneyBottleState = class(BaseStableState)

function HoneyBottleState:create( context )
	-- body
	local v = HoneyBottleState.new()
	v.context = context
	v.mainLogic = context.mainLogic  --gameboardlogic
	v.boardView = v.mainLogic.boardView
	return v
end

function HoneyBottleState:onEnter()
	BaseStableState.onEnter(self)
	self.nextState = nil

    if(not self.mainLogic._fieldLogicPossibility[_FIELD_LOGIC_ID.honeyBottle]) then
        printx(0, '!skip')
		self.completeItem = 0
		self.total = 0
		self:handleComplete()
        return
    end


	local function callback( ... )
		-- body
		self:handleComplete();
	end

	self.hasItemToHandle = false
	self.completeItem = 0
	self.total = GameExtandPlayLogic:checkHoneyBottleBroken(self.mainLogic, callback)
	if self.total == 0 then
		self:handleComplete()
	else
		self.context.needLoopCheck = true
		self.hasItemToHandle = true
	end
end

function HoneyBottleState:handleComplete( ... )
	self.completeItem = self.completeItem + 1 
	if self.completeItem >= self.total then 
		self.nextState = self:getNextState()
		if self.hasItemToHandle then
			self.mainLogic:setNeedCheckFalling()
		end
	end
end

function HoneyBottleState:onExit()
	BaseStableState.onExit(self)
	self.nextState = nil
	self.completeItem = 0
	self.total = 0
	self.hasItemToHandle = false
end

function HoneyBottleState:checkTransition()
	return self.nextState
end

function HoneyBottleState:getClassName()
	return "HoneyBottleState"
end

function HoneyBottleState:getNextState( ... )
	-- body
end

HoneyBottleStateInLoop = class(HoneyBottleState)
function HoneyBottleStateInLoop:create(context)
	local v = HoneyBottleStateInLoop.new()
	v.context = context
	v.mainLogic = context.mainLogic  --gameboardlogic
	v.boardView = v.mainLogic.boardView
	return v
end

function HoneyBottleStateInLoop:getClassName()
	return "HoneyBottleStateInLoop"
end

function HoneyBottleStateInLoop:getNextState()
	return self.context.addBiscuitState 
end