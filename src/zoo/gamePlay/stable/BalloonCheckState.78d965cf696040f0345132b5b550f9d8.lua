BalloonCheckState = class(BaseStableState)

function BalloonCheckState:create( context )
	-- body
	local v = BalloonCheckState.new()
	v.context = context
	v.mainLogic = context.mainLogic  --gameboardlogic
	v.boardView = v.mainLogic.boardView
	return v
end

function BalloonCheckState:onEnter()
	BaseStableState.onEnter(self)
	
    if(not self.mainLogic._fieldLogicPossibility[_FIELD_LOGIC_ID[GameItemType.kBalloon]]) then
        printx(0, '!skip')
		self.nextState = self:getNextState()
        return
    end
	
	if self.mainLogic.isInStep and self.excuteNum == 0 then
		self.nextState = nil
		self.excuteNum = self.excuteNum + 1
		local function callback( ... )
			-- body
			self:handleBalloonComplete();
		end

		self.hasItemToHandle = false
		self.completeBalloon = 0
		self.totalBalloon = GameExtandPlayLogic:CheckBalloonList(self.mainLogic, callback)
		if self.totalBalloon == 0 then
			self:handleBalloonComplete()
		else
			self.hasItemToHandle = true
		end
	else
		self.nextState = self:getNextState()
	end

	
end

function BalloonCheckState:resetExcuteNum( ... )
	-- body
	self.excuteNum = 0
end

function BalloonCheckState:handleBalloonComplete( ... )
	self.completeBalloon = self.completeBalloon + 1 
	if self.completeBalloon >= self.totalBalloon then 
		
		self.nextState = self:getNextState()
		
		if self.hasItemToHandle then
			self.mainLogic:setNeedCheckFalling()
			self.context.needLoopCheck = true
		end
	end
end

function BalloonCheckState:onExit()
	BaseStableState.onExit(self)
	self.nextState = nil
	self.completeBalloon = 0
	self.totalBalloon = 0
	self.hasItemToHandle = false
end

function BalloonCheckState:checkTransition()
	return self.nextState
end

function BalloonCheckState:getClassName()
	return "BalloonCheckState"
end

BalloonCheckStateInLoop = class(BalloonCheckState)
function BalloonCheckStateInLoop:create( context )
	-- body
	local v = BalloonCheckStateInLoop.new()
	v.context = context
	v.mainLogic = context.mainLogic
	v.boardView = v.mainLogic.boardView
	return v
end

function BalloonCheckStateInLoop:getClassName( ... )
	-- body
	return "BalloonCheckStateInLoop"
end

function BalloonCheckStateInLoop:getNextState( ... )
	-- body
	-- return self.context.honeyBottleStateInLoop
	return self.context.ghostMoveStateInLoop
end
