TileBlockerState = class(BaseStableState)
function TileBlockerState:create( context )
	-- body
	local v = TileBlockerState.new()
	v.context = context
	v.mainLogic = context.mainLogic  --gameboardlogic
	v.boardView = v.mainLogic.boardView
	return v
end

function TileBlockerState:update( ... )
	-- body
end

function TileBlockerState:onEnter()
	BaseStableState.onEnter(self)


    if(not self.mainLogic._fieldLogicPossibility[_FIELD_LOGIC_ID.rotationTileBlock]) then
        printx(0, '!skip')
		self.nextState = self:getNextState()
        return
    end
	
	if self.mainLogic.isInStep and self.excuteNum == 0 then
		self.nextState = nil
		self.excuteNum = self.excuteNum + 1
		local function callback( ... )
			-- body
			self:handleComplete();
		end

		self.hasItemToHandle = false
		self.complete = 0
		self.total = GameExtandPlayLogic:CheckTileBlockerList(self.mainLogic, callback)
		if self.total == 0 then
			self:handleComplete()
		else
			self.hasItemToHandle = true
		end
	else --略过
		self.nextState = self:getNextState()
	end
end

function TileBlockerState:resetExcuteNum( ... )
	-- body
	self.excuteNum = 0
end


function TileBlockerState:handleComplete( ... )
	-- body
	self.complete = self.complete + 1 
	if self.complete >= self.total then 
		self.nextState = self:getNextState()
		if self.hasItemToHandle then
			self.mainLogic:tryBombSuperTotems()
			self.mainLogic:setNeedCheckFalling();
		end
		self.context.needLoopCheck = true
	end
end

function TileBlockerState:onExit()
	BaseStableState.onExit(self)
	self.nextState = nil
	self.complete = 0
	self.total = 0
	self.hasItemToHandle = false
end

function TileBlockerState:checkTransition()
	return self.nextState
end

function TileBlockerState:getClassName()
	return "TileBlockerState"
end

TileBlockerStateInLoop = class(TileBlockerState)
function TileBlockerStateInLoop:create( context )
	-- body
	local  v = TileBlockerStateInLoop.new()
	v.context = context
	v.mainLogic = context.mainLogic
	v.boardView = v.mainLogic.boardView
	return v
end

function TileBlockerStateInLoop:getClassName( ... )
	-- body
	return "TileBlockerStateInLoop"
end

function TileBlockerStateInLoop:getNextState( ... )
	-- body
	return self.context.furballSplitStateInLoop
end