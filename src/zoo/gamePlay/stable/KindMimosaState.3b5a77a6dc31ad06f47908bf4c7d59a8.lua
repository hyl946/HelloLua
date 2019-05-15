KindMimosaState = class(BaseStableState)
function KindMimosaState:create( context )
	-- body
	local v = KindMimosaState.new()
	v.context = context
	v.mainLogic = context.mainLogic  --gameboardlogic
	v.boardView = v.mainLogic.boardView
	return v
end

function KindMimosaState:update( ... )
	-- body
end

function KindMimosaState:onEnter()
	BaseStableState.onEnter(self)
	self.nextState = nil

    if(not self.mainLogic._fieldLogicPossibility[_FIELD_LOGIC_ID[GameItemType.kKindMimosa]]) then
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
	self.total = GameExtandPlayLogic:checkMimosa(GameItemType.kKindMimosa, self.mainLogic, callback)
	if self.total == 0 then
		self:handleComplete()
	else
		self.hasItemToHandle = true
	end
end

function KindMimosaState:handleComplete( ... )
	-- body
	self.complete = self.complete + 1 
	if self.complete >= self.total then 
		self.nextState = self.context.updatePM25State
		if self.hasItemToHandle then
			self.mainLogic:setNeedCheckFalling();
		end
	end
end

function KindMimosaState:onExit()
	BaseStableState.onExit(self)
	self.nextState = nil
	self.complete = 0
	self.total = 0
	self.hasItemToHandle = false
end

function KindMimosaState:checkTransition()
	return self.nextState
end

function KindMimosaState:getClassName()
	return "KindMimosaState"
end