
DigScrollGroundState = class(BaseStableState)

function DigScrollGroundState:dispose()
	self.mainLogic = nil
	self.boardView = nil
	self.context = nil
end

function DigScrollGroundState:create(context)
	local v = DigScrollGroundState.new()
	v.context = context
	v.mainLogic = context.mainLogic
	v.boardView = v.mainLogic.boardView
	return v
end

function DigScrollGroundState:onEnter()
	BaseStableState.onEnter(self)
	self.nextState = nil
	local function scrollComplete()
		self.nextState = self:getNextState()
		-- 刷新棋盘上block状态，重新计算掉落
		for r = 1, #self.mainLogic.gameItemMap do
			for c = 1, #self.mainLogic.gameItemMap[r] do
				self.mainLogic:checkItemBlock(r,c)       -- @TBD 不知道为什么check后道具云块就变成blocker了
			end
		end
		-- 地形发生了变化 checkItemBlock可能只改变了board的isBlock属性，
		-- 而没有更新mainLogic的isBlockChange属性，导致不重新计算掉落列。
		-- 因此再设置一个值让preUpdateHelpMap逻辑执行
		self.mainLogic:setTileMoved() 
		self.mainLogic:updateFallingAndBlockStatus()
		self.mainLogic:setNeedCheckFalling()
	end
	
	if self.mainLogic.theGamePlayType == GameModeTypeId.DIG_MOVE_ID
	or self.mainLogic.theGamePlayType == GameModeTypeId.DIG_MOVE_ENDLESS_ID 
	or self.mainLogic.theGamePlayType == GameModeTypeId.MAYDAY_ENDLESS_ID
    or self.mainLogic.theGamePlayType == GameModeTypeId.HALLOWEEN_ID
    or self.mainLogic.theGamePlayType == GameModeTypeId.WUKONG_DIG_ENDLESS_ID
    or self.mainLogic.theGamePlayType == GameModeTypeId.OLYMPIC_HORIZONTAL_ENDLESS_ID
    or self.mainLogic.theGamePlayType == GameModeTypeId.HEDGEHOG_DIG_ENDLESS_ID 
    or self.mainLogic.theGamePlayType == GameModeTypeId.SPRING_HORIZONTAL_ENDLESS_ID
    or self.mainLogic.theGamePlayType == GameModeTypeId.MOLE_WEEKLY_RACE_ID
     then
		local digNeedScroll = self.mainLogic.gameMode:checkScrollDigGround(scrollComplete)
		if not digNeedScroll then
			self.nextState = self:getNextState()
		else
			self.context.needLoopCheck = true
		end
	else
		self.nextState = self:getNextState()
	end
end

function DigScrollGroundState:getNextState()
	return nil
end

function DigScrollGroundState:onExit()
	BaseStableState.onExit(self)
	self.nextState = nil
end

function DigScrollGroundState:checkTransition()
	return self.nextState
end

function DigScrollGroundState:getClassName()
	return "DigScrollGroundState"
end

DigScrollGroundStateInLoop = class(DigScrollGroundState)
function DigScrollGroundStateInLoop:create(context)
    local v = DigScrollGroundStateInLoop.new()
    v.context = context
    v.mainLogic = context.mainLogic
    v.boardView = v.mainLogic.boardView
    return v
end

function DigScrollGroundStateInLoop:getClassName()
	return "DigScrollGroundStateInLoop"
end

function DigScrollGroundStateInLoop:getNextState()
	-- return self.context.checkNeedLoopState
	return self.context.maydayBossCastingState
end