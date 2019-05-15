MimosaState = class(BaseStableState)
function MimosaState:create( context )
	-- body
	local v = MimosaState.new()
	v.context = context
	v.mainLogic = context.mainLogic  --gameboardlogic
	v.boardView = v.mainLogic.boardView
	return v
end

function MimosaState:update( ... )
	-- body
end

function MimosaState:onEnter()
	BaseStableState.onEnter(self)
	self.nextState = nil


    if(not self.mainLogic._fieldLogicPossibility[_FIELD_LOGIC_ID[GameItemType.kMimosa]]) then
        printx(0, '!skip')
		self.complete = 0
		self.total = 0
		self:handleComplete()
        return
    end
	
	local function callback( ... )
		-- body
		self:handleComplete();
	end

	self.hasItemToHandle = false
	self.complete = 0
	self.total = GameExtandPlayLogic:checkMimosa(GameItemType.kMimosa, self.mainLogic, callback)
	if self.total == 0 then
		self:handleComplete()
	else
		self.hasItemToHandle = true
	end
end

function MimosaState:handleComplete( ... )
	-- body
	self.complete = self.complete + 1 
	if self.complete >= self.total then 
		self.nextState = self.context.kindMimosaState
		if self.hasItemToHandle then
			self.mainLogic:setNeedCheckFalling();
		end
	end
end

function MimosaState:onExit()
	BaseStableState.onExit(self)
	self.nextState = nil
	self.complete = 0
	self.total = 0
	self.hasItemToHandle = false
end

function MimosaState:checkTransition()
	return self.nextState
end

function MimosaState:getClassName()
	return "MimosaState"
end