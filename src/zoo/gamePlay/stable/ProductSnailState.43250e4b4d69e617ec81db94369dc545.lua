ProductSnailState = class(BaseStableState)
function ProductSnailState:create( context )
	-- body
	local v = ProductSnailState.new()
	v.context = context
	v.mainLogic = context.mainLogic  --gameboardlogic
	v.boardView = v.mainLogic.boardView
	return v
end

function ProductSnailState:update( ... )
	-- body
end

function ProductSnailState:onEnter()
	BaseStableState.onEnter(self)
	self.nextState = nil
	local function callback( ... )
		-- body
		self:handleComplete();
	end

	self.hasItemToHandle = false
	self.complete = 0
	self.total = ProductItemLogic:productSnail( self.mainLogic, callback )
	if self.total == 0 then
		self:handleComplete()
	else
		self.hasItemToHandle = true
	end
end

function ProductSnailState:handleComplete( ... )
	-- body
	self.complete = self.complete + 1 
	if self.complete >= self.total then 
		self.nextState = self:getNextState()
		if self.hasItemToHandle then
			self.mainLogic:setNeedCheckFalling();
		end
	end
end

function ProductSnailState:onExit()
	BaseStableState.onExit(self)
	self.nextState = nil
	self.complete = 0
	self.total = 0
	self.hasItemToHandle = false
end

function ProductSnailState:checkTransition()
	return self.nextState
end

function ProductSnailState:getClassName( ... )
	-- body
	return "ProductSnailState"
end

function ProductSnailState:getNextState( ... )
	-- body
	-- return self.context.magicTileResetState
	-- return self.context.buffBoomGenerateState
	return self.context.prePropsGenerateState
end

