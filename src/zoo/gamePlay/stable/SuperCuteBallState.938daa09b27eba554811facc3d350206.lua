SuperCuteBallState = class(BaseStableState)

function SuperCuteBallState:create(context)
	local v = SuperCuteBallState.new()
	v.context = context
	v.mainLogic = context.mainLogic
	v.boardView = v.mainLogic.boardView
	return v
end

function SuperCuteBallState:update(dt)
	
end

function SuperCuteBallState:onEnter()
	BaseStableState.onEnter(self)
    self.nextState = nil
	self.hasItemToHandle = false
	self.complete = 0
	self.total =  0


    if(not self.mainLogic._fieldLogicPossibility[_FIELD_LOGIC_ID.superCute]) then
        printx(0, '!skip')
		self:handleItemComplete()
        return 0
    end

    local actionCompleteCallback = function()
    	self:handleItemComplete()
	end

	local needTransfer = GameExtandPlayLogic:checkSuperCuteBallTransfer(self.mainLogic, actionCompleteCallback)
	local needRecover = GameExtandPlayLogic:checkSuperCuteBallRecover(self.mainLogic, actionCompleteCallback)

    self.total = self.total + needTransfer
    self.total = self.total + needRecover

	if self.total == 0 then
		self:handleItemComplete()
    else
    	self.hasItemToHandle = true
    end
end

function SuperCuteBallState:handleItemComplete( ... )
	-- body
	self.complete = self.complete + 1 
	if self.complete >= self.total then 
		self.nextState = self:getNextState()
		if self.hasItemToHandle then
			self.mainLogic:setNeedCheckFalling()
			self.mainLogic:tryBombSuperTotems()
		end
	end
end

function SuperCuteBallState:onExit()
    BaseStableState.onExit(self)
    self.nextState = nil
end

function SuperCuteBallState:getClassName( ... )
	return "SuperCuteBallState"
end

function SuperCuteBallState:checkTransition()
	return self.nextState
end

function SuperCuteBallState:getNextState()
	return self.context.productRabbitState
end
