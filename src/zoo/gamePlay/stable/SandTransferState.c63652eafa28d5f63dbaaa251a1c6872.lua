SandTransferState = class(BaseStableState)

function SandTransferState:dispose()
	self.mainLogic = nil
	self.boardView = nil
	self.context = nil
end

function SandTransferState:create(context)
	local v = SandTransferState.new()
	v.context = context
	v.mainLogic = context.mainLogic
	v.boardView = v.mainLogic.boardView
	return v
end

function SandTransferState:onEnter()
	BaseStableState.onEnter(self)
	local context = self

    if(not self.mainLogic._fieldLogicPossibility[_FIELD_LOGIC_ID.sand]) then
        printx(0, '!skip')
		self.nextState = self:getNextState()
        return 0
    end


	local function transferCallback()
		context:handleFurballTransferInStepComplete()
	end

	self.nextState = nil
	self.counterSandTransferToHandle = 0
	self.totalSandTransferToHandle = GameExtandPlayLogic:checkSandToTransfer(self.mainLogic, transferCallback)
	if self.totalSandTransferToHandle == 0 then
		self.nextState = self:getNextState()
	end
end

function SandTransferState:onExit()
	BaseStableState.onExit(self)
	self.nextState = nil
	self.totalSandTransferToHandle = 0
	self.counterSandTransferToHandle = 0
end

function SandTransferState:handleFurballTransferInStepComplete()
	self.counterSandTransferToHandle = self.counterSandTransferToHandle + 1
	if self.counterSandTransferToHandle >= self.totalSandTransferToHandle then
		if _G.isLocalDevelopMode then printx(0, "-----------------------------sand transfer complete") end
		self.nextState = self:getNextState()
		self.context:onEnter()
	end
end

function SandTransferState:getNextState()
	return self.context.magicLampCastingStateInSwapFirst
end

function SandTransferState:checkTransition()
	return self.nextState
end

function SandTransferState:getClassName()
	return "SandTransferState"
end