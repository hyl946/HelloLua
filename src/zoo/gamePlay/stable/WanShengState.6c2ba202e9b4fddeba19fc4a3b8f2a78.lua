WanShengState = class(BaseStableState)

function WanShengState:create( context )
	-- body
	local v = WanShengState.new()
	v.context = context
	v.mainLogic = context.mainLogic  --gameboardlogic
	v.boardView = v.mainLogic.boardView
	return v
end

function WanShengState:onEnter()
	BaseStableState.onEnter(self)
	self.nextState = nil

    if(not self.mainLogic._fieldLogicPossibility[_FIELD_LOGIC_ID.wanSheng]) then
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
	self.total = WanShengLogic:checkWanShengBroken(self.mainLogic, callback)

	if self.total == 0 then
		self:handleComplete()
	else
		self.context.needLoopCheck = true
		self.hasItemToHandle = true
	end
end

function WanShengState:handleComplete( ... )
	self.completeItem = self.completeItem + 1 
	if self.completeItem >= self.total then 
		self.nextState = self:getNextState()
		if self.hasItemToHandle then
			self.mainLogic:setNeedCheckFalling()
		end
	end
end

function WanShengState:onExit()
	BaseStableState.onExit(self)
	self.nextState = nil
	self.completeItem = 0
	self.total = 0
	self.hasItemToHandle = false
end

function WanShengState:checkTransition()
	return self.nextState
end

function WanShengState:getClassName()
	return "WanShengState"
end

function WanShengState:getNextState( ... )
	-- body
end

WanShengStateInLoop = class(WanShengState)
function WanShengStateInLoop:create(context)
	local v = WanShengStateInLoop.new()
	v.context = context
	v.mainLogic = context.mainLogic  --gameboardlogic
	v.boardView = v.mainLogic.boardView
	return v
end

function WanShengStateInLoop:getClassName()
	return "WanShengStateInLoop"
end

function WanShengStateInLoop:getNextState()
	return self.context.honeyBottleStateInLoop
end