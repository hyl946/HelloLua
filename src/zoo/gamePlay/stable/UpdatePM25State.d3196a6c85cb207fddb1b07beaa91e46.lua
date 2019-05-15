UpdatePM25State = class(BaseStableState)
function UpdatePM25State:create( context )
	-- body
	local v = UpdatePM25State.new()
	v.context = context
	v.mainLogic = context.mainLogic  --gameboardlogic
	v.boardView = v.mainLogic.boardView
	return v
end

function UpdatePM25State:update( ... )
	-- body
end

function UpdatePM25State:onEnter()
	BaseStableState.onEnter(self)
	self.nextState = nil
	local function callback( ... )
		-- body
		self:handleComplete();
	end

	self.hasItemToHandle = false
	self.complete = 0
	self.total = GameExtandPlayLogic:checkPM25(self.mainLogic, callback)
	if self.total == 0 then
		self:handleComplete()
	else
		self.hasItemToHandle = true
	end
end

function UpdatePM25State:handleComplete( ... )
	-- body
	self.complete = self.complete + 1 
	if self.complete >= self.total then 
		self.nextState = self.context.endCycleStateEnter
		if self.hasItemToHandle then
			self.mainLogic:setNeedCheckFalling();
		end
	end
end

function UpdatePM25State:onExit()
	BaseStableState.onExit(self)
	self.nextState = nil
	self.complete = 0
	self.total = 0
	self.hasItemToHandle = false
end

function UpdatePM25State:checkTransition()
	return self.nextState
end

function UpdatePM25State:getClassName()
	return "UpdatePM25State"
end