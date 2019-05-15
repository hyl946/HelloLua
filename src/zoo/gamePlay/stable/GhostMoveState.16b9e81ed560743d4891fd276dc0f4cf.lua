GhostMoveState = class(BaseStableState)

function GhostMoveState:dispose()
	self.mainLogic = nil
	self.boardView = nil
	self.context = nil
end

function GhostMoveState:create(context)
	local v = GhostMoveState.new()
	v.context = context
	v.mainLogic = context.mainLogic
	v.boardView = v.mainLogic.boardView
	return v
end

function GhostMoveState:getNextState()
	-- return self.context.blackCuteBallState
	return self.context.tileTransferState
end

function GhostMoveState:checkTransition()
	return self.nextState
end

function GhostMoveState:getClassName()
	return "GhostMoveState"
end

function GhostMoveState:onExit()
	BaseStableState.onExit(self)
	self.nextState = nil

	self.allGhostFinishedClimbing = false
	self.allActiveGhost = nil
	self.needToCollectGhost = false
end

function GhostMoveState:onEnter()
	BaseStableState.onEnter(self)
	local context = self

    if not self.mainLogic._fieldLogicPossibility[_FIELD_LOGIC_ID.ghostMove] then
    	printx(0, '!skip')
		self:changeToNextState()
        return
    end

	self.nextState = nil

	self.allGhostFinishedClimbing = false	--大家都移动完了吗？
	self.allActiveGhost = nil				--所有可以移动的幽灵
	self.needToCollectGhost = false
	
	self:_checkMovingAndCollecting()
end

function GhostMoveState:changeToNextState()
	self.nextState = self:getNextState()
end

--------------------------------------------------------------------------------------------
--									读万卷书  行万里路
--------------------------------------------------------------------------------------------
--------- 一 起 升 天
function GhostMoveState:_checkMovingAndCollecting()
	self.allActiveGhost = GhostLogic:pickAllActiveGhostsByOrder(self.mainLogic)
	local toCollectGhosts
	if #self.allActiveGhost == 0 then
		toCollectGhosts = GhostLogic:pickAllToCollectGhosts(self.mainLogic)
		if #toCollectGhosts > 0 then
			self.needToCollectGhost = true
		else
			self:changeToNextState()
			return
		end
	end

	self:_startMoving(toCollectGhosts)

	if not self.allGhostFinishedClimbing or self.needToCollectGhost then
		--增加大循环轮循次数
		self.context.needLoopCheck = true
	end
end

function GhostMoveState:_startMoving(toCollectGhosts)
	local hasRealMovingGhosts = false

	local function actionCallback()
		self.allGhostFinishedClimbing = true
        self:_onAllMovingEnded()
    end

	if #self.allActiveGhost > 0 then
		hasRealMovingGhosts = GhostLogic:arrangeAllMovementsCausedByGhosts(self.mainLogic, self.allActiveGhost)

		if hasRealMovingGhosts then
			local moveAction = GameBoardActionDataSet:createAs(
							 		GameActionTargetType.kGameItemAction,
							 		GameItemActionType.kItem_ghost_move,
							 		nil,
							 		nil,
							 		GamePlayConfig_MaxAction_time)
			-- printx(11, "Ghost, need to move!")
			moveAction.completeCallback = actionCallback
			self.mainLogic:addDestroyAction(moveAction)
			self.mainLogic:setNeedCheckFalling()
		end
	end

	if not hasRealMovingGhosts then 	-- 不巧，都移动不了
		--把幽灵切换视图切回普通状态
		if self.allActiveGhost then
			for _, item in pairs(self.allActiveGhost) do
				if item.ghostPaceLength > 0 then
        			GhostLogic:switchStatusBackToNormalWithoutMoving(self.mainLogic, item)
        		end
			end
		end

		if not toCollectGhosts then
			toCollectGhosts = GhostLogic:pickAllToCollectGhosts(self.mainLogic)
		end
		if #toCollectGhosts > 0 then
			self:_checkCollect(toCollectGhosts)
		else
			self.allGhostFinishedClimbing = true
			self:changeToNextState()
		end
	end
end

--------------------------------------------------------------------------------
function GhostMoveState:_onAllMovingEnded()
	if self.allGhostFinishedClimbing then
		self:_checkCollect()
	end
end

function GhostMoveState:_checkCollect(allToCollectGhosts)
	local toCollectGhosts = allToCollectGhosts
	if not toCollectGhosts then
		toCollectGhosts = GhostLogic:pickAllToCollectGhosts(self.mainLogic)
	end
	
	if #toCollectGhosts > 0 then
		self:_startCollect(toCollectGhosts)
	else
		self:_onAllCollectEnded()
	end
end

function GhostMoveState:_startCollect(toCollectGhosts)
	self.needToCollectGhost = true

	local function actionCallback()
        self:_onAllCollectEnded()
    end

	local action = GameBoardActionDataSet:createAs(
					 		GameActionTargetType.kGameItemAction,
					 		GameItemActionType.kItem_ghost_collect,
					 		nil,
					 		nil,
					 		GamePlayConfig_MaxAction_time)
	-- printx(11, "Ghost, need to collect !")
	action.targetList = toCollectGhosts
	action.completeCallback = actionCallback
	self.mainLogic:addDestroyAction(action)
	self.mainLogic:setNeedCheckFalling()
end

function GhostMoveState:_onAllCollectEnded()
	GhostLogic:refreshBlockStateAfterGhostMove(self.mainLogic)
	FallingItemLogic:preUpdateHelpMap(self.mainLogic)
	self.mainLogic:setNeedCheckFalling()

	self:changeToNextState()
end


--------------------------------------------------------------------------
GhostMoveStateInLoop = class(GhostMoveState)
function GhostMoveStateInLoop:create(context)
    local v = GhostMoveStateInLoop.new()
    v.context = context
    v.mainLogic = context.mainLogic
    v.boardView = v.mainLogic.boardView
    v.inBonus = false
    return v
end

function GhostMoveStateInLoop:getClassName()
    return "GhostMoveStateInLoop"
end

function GhostMoveStateInLoop:getNextState()
    return self.context.WanShengStateInLoop
end
