HedgehogCrazyState = class(BaseStableState)

function HedgehogCrazyState:create( context )
	-- body
	local v = HedgehogCrazyState.new()
	v.context = context
	v.mainLogic = context.mainLogic  --gameboardlogic
	v.boardView = v.mainLogic.boardView
	v.step = 0
	return v
end

function HedgehogCrazyState:onEnter()
	BaseStableState.onEnter(self)
	if self.mainLogic.hedgehogCrazyBuff  then
		self.nextState = nil
		local function callback( ... )
			-- body
			self:handleComplete();
		end
		if self.step == 0 then    --爆炸云层
			local total = self.mainLogic.gameMode:checkNeedBombDigGround(callback, true)
			if total == 0 then
				callback()
			end
		elseif self.step == 1 then --云层向上滚
			local digNeedScroll = self.mainLogic.gameMode:checkScrollDigGround(callback, true)
			if not digNeedScroll then
				callback()
			end
		elseif self.step == 2 then  --刺猬移动
			local hedgeCount = HedgehogLogic:checkHedgehogCrazyList( self.mainLogic, callback )
			if hedgeCount == 0 then
				callback()
			end
		end
	else
		self.nextState = self:getNextState()
		self.step = 0
	end
end

function HedgehogCrazyState:handleComplete( ... )
	if self.step < 2 then
		self.step = self.step + 1
		self.nextState = self
	else
		self.mainLogic.hedgehogCrazyBuff = false
		self.nextState = self:getNextState()
		self.step = 0
	end
	self.mainLogic:setNeedCheckFalling()
end

function HedgehogCrazyState:getNextState( ... )
	-- body
end

function HedgehogCrazyState:onExit()
	BaseStableState.onExit(self)
	self.nextState = nil
end

function HedgehogCrazyState:checkTransition()
	return self.nextState
end

function HedgehogCrazyState:getClassName()
	return "HedgehogCrazyState"
end

HedgehogCrazyInProp = class(HedgehogCrazyState)
function HedgehogCrazyInProp:create( context )
	-- body
	local v = HedgehogCrazyInProp.new()
	v.context = context
	v.mainLogic = context.mainLogic
	v.boardView = v.mainLogic.boardView
	v.step = 0
	return v
end

function HedgehogCrazyInProp:getClassName( ... )
	-- body
	return "HedgehogCrazyInProp"
end

function HedgehogCrazyInProp:getNextState( ... )
	-- body
	return self.context.furballSplitStateInPropFirst
end

HedgehogCrazyInBonus = class(HedgehogCrazyState)
function HedgehogCrazyInBonus:create( context )
	-- body
	local v = HedgehogCrazyInBonus.new()
	v.context = context
	v.mainLogic = context.mainLogic
	v.boardView = v.mainLogic.boardView
	v.step = 0
	return v
end

function HedgehogCrazyInBonus:getClassName( ... )
	-- body
	return "HedgehogCrazyInBonus"
end

function HedgehogCrazyInBonus:getNextState( ... )
	-- body
	return self.context.gameOverState
end

function HedgehogCrazyInBonus:onEnter()
	BaseStableState.onEnter(self)
	if self.step == 0 then
		self.mainLogic.hedgehogCrazyBuff = self.mainLogic:isHedgehogCrazyBuffInBonusTime()
	end

	if self.mainLogic.hedgehogCrazyBuff  then
		self.nextState = nil
		local function callback( ... )
			-- body
			self:handleComplete();
		end
		if self.step == 0 then    --爆炸云层
			local total = self.mainLogic.gameMode:checkNeedBombDigGround(callback, true)
			if total == 0 then
				callback()
			end
		elseif self.step == 1 then --云层向上滚
			local digNeedScroll = self.mainLogic.gameMode:checkScrollDigGround(callback, true)
			if not digNeedScroll then
				callback()
			end
		elseif self.step == 2 then  --刺猬移动
			local dc_data = {
				game_type = "stage",
				game_name = "2016_children_day",
				category = "other",
				sub_category = "children_day_crazy_click",
				t1 = 0,
			}
			DcUtil:activity(dc_data)
				
			local hedgeCount = HedgehogLogic:checkHedgehogCrazyList( self.mainLogic, callback )
			if hedgeCount == 0 then
				callback()
			end
		end
	else
		self.nextState = self:getNextState()
		self.step = 0
	end
end