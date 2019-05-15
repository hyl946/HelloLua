FirecrackerBlastState = class(BaseStableState)

function FirecrackerBlastState:dispose()
    self.mainLogic = nil
    self.boardView = nil
    self.context = nil
end

function FirecrackerBlastState:create(context)
    local v = FirecrackerBlastState.new()
    v.context = context
    v.mainLogic = context.mainLogic
    v.boardView = v.mainLogic.boardView
    return v
end

function FirecrackerBlastState:getNextState()
    -- return self.context.dripCastingStateInLast_B
    return self.context.dripCastingStateInSwap
end

function FirecrackerBlastState:checkTransition()
    return self.nextState
end

function FirecrackerBlastState:getClassName()
    return "FirecrackerBlastState"
end

function FirecrackerBlastState:onExit()
    BaseStableState.onExit(self)
    self.nextState = nil
    self.hasItemToHandle = false

    self.blastCount = 0
    self.mainLogic.missileHasHitPoint = {}
end

function FirecrackerBlastState:onEnter()
    BaseStableState.onEnter(self)
    self.nextState = nil
    self.hasItemToHandle = false

    self.shotPerItem = 3	--3个击打目标
    self.blastCount = 0
    self.mainLogic.missileHasHitPoint = {}		--完全沿用冰封导弹击打优先级，反正两个state不会交叉，先借用下啦~
    
    if FirecrackerLogic:hasGeneratedFirecracker() then
    	local allFirecracker = FirecrackerLogic:getAllToBlastFirecrackerOnBoard(self.mainLogic)
		if #allFirecracker > 0 then
			self.hasItemToHandle = true
			self:onBlastFirecracker(allFirecracker)
		end
    end

    if not self.hasItemToHandle then
    	self:onActionComplete()
    end
end

function FirecrackerBlastState:onBlastFirecracker(allFirecracker)
	self.blastCount = #allFirecracker

    local function actionCallback()
        self:onOneBlastComplete()
    end

    for _, firecracker in ipairs(allFirecracker) do
		local targetPositions = GameExtandPlayLogic:findMissileTarget(self.mainLogic, firecracker, self.shotPerItem)

		local action = GameBoardActionDataSet:createAs(
	        GameActionTargetType.kGameItemAction,
	        GameItemActionType.kItem_Firecracker_Blast, 
	        nil,
	        nil,
	        GamePlayConfig_MaxAction_time
	        )
		action.targetFirecracker = firecracker
	    action.targetPositions = targetPositions
	    action.completeCallback = actionCallback
	    self.mainLogic:addGlobalCoreAction(action)
	end

    self.context.needLoopCheck = true
end

function FirecrackerBlastState:onOneBlastComplete()
	self.blastCount = self.blastCount - 1
	if self.blastCount == 0 then
		self:onActionComplete()
	end
end

function FirecrackerBlastState:onActionComplete()
	if self.hasItemToHandle then
		FallingItemLogic:preUpdateHelpMap(self.mainLogic)
		self.mainLogic:setNeedCheckFalling()
	end

    self.nextState = self:getNextState()
    -- if needEnter then
    -- 	self.context:onEnter()
    -- end
end

-------------------------------------------------
FirecrackerBlastStateInLoop = class(FirecrackerBlastState)

function FirecrackerBlastStateInLoop:create(context)
	local v = FirecrackerBlastStateInLoop.new()
	v.context = context
	v.mainLogic = context.mainLogic
	v.boardView = v.mainLogic.boardView
	return v
end

function FirecrackerBlastStateInLoop:getNextState()
	return self.context.magicLampCastingStateInLoop
end

function FirecrackerBlastStateInLoop:getClassName()
	return "FirecrackerBlastStateInLoop"
end