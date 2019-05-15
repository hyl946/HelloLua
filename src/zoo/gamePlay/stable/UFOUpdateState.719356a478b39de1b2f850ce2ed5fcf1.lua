UFOUpdateState = class(BaseStableState)

function UFOUpdateState:create( context )
	-- body
	local v = UFOUpdateState.new()
	v.context = context
	v.mainLogic = context.mainLogic  --gameboardlogic
	v.boardView = v.mainLogic.boardView
	return v
end

function UFOUpdateState:update( ... )
	-- body
end

function UFOUpdateState:onEnter()
	BaseStableState.onEnter(self)
	self.nextState = nil
	self.hasItemToHandle = false
	self.complete = 0
	self.total =  0
	self.isTop = false

	if self.mainLogic.UFOSleepCD > 0 then
		-- 飞碟恢复
		GameExtandPlayLogic:recoverUFO(self.mainLogic)
	else
		self.mainLogic.oldUFOSleepCD = 0
		local function callback( ... )
			self:handleItemComplete()
		end
		self.total, self.isTop = GameExtandPlayLogic:checkUFOItemUpdate(self.mainLogic, callback)
	end

	if self.total == 0 then
		self:handleItemComplete()
	else
		self.hasItemToHandle = true
	end
end

function UFOUpdateState:handleItemComplete( ... )
	-- body
	self.complete = self.complete + 1 
	if self.complete >= self.total then 
		self.nextState = self.context.changePeriodState
		
		if self.hasItemToHandle then
			if self.isTop then
				self.mainLogic:setGamePlayStatus(GamePlayStatus.kEnd)
			else
				self.mainLogic:setNeedCheckFalling()
			end

		end
	end
end

function UFOUpdateState:onExit()
	BaseStableState.onExit(self)
	self.nextState = nil
	self.total = 0
	self.complete = 0
	self.hasItemToHandle = false
end

function UFOUpdateState:checkTransition()
	return self.nextState
end

function UFOUpdateState:getClassName()
	return "UFOUpdateState"
end