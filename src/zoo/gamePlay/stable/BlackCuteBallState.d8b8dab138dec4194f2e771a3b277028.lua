BlackCuteBallState = class(BaseStableState)

function BlackCuteBallState:create( context )
	-- body
	local v = BlackCuteBallState.new()
	v.context = context
	v.mainLogic = context.mainLogic  --gameboardlogic
	v.boardView = v.mainLogic.boardView
	return v
end

function BlackCuteBallState:update( ... )
	-- body
end

function BlackCuteBallState:onEnter()
	BaseStableState.onEnter(self)
	self.nextState = nil

    if(not self.mainLogic._fieldLogicPossibility[_FIELD_LOGIC_ID[GameItemType.kBlackCuteBall]]) then
        printx(0, '!skip')
		self.completeItem = 0
		self.totalItem = 0
		self:handleBlackCuteBallComplete();
        return
    end


	local function callback( ... )
		-- body
		self:handleBlackCuteBallComplete();
	end

	self.hasItemToHandle = false
	self.completeItem = 0
	self.totalItem = GameExtandPlayLogic:checkBlackCuteBallList(self.mainLogic, callback)
	if self.totalItem == 0 then
		self:handleBlackCuteBallComplete()
	else
		self.hasItemToHandle = true
	end
end

function BlackCuteBallState:handleBlackCuteBallComplete( ... )
	-- body
	self.completeItem = self.completeItem + 1 
	if self.completeItem >= self.totalItem then 
		
		self.nextState = self.context.furballTransferState
		
		if self.hasItemToHandle then
			self.mainLogic:setNeedCheckFalling();
		end
	end
end

function BlackCuteBallState:onExit()
	BaseStableState.onExit(self)
	self.nextState = nil
	self.completeItem = 0
	self.totalItem = 0
	self.hasItemToHandle = false
end

function BlackCuteBallState:checkTransition()
	-- if _G.isLocalDevelopMode then printx(0, "------------------------- black cute ball update state checkTransition") end
	return self.nextState
end

function BlackCuteBallState:getClassName( ... )
	-- body
	return "BlackCuteBallState"
end