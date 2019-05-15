GhostAppearState = class(BaseStableState)

function GhostAppearState:dispose()
	self.mainLogic = nil
	self.boardView = nil
	self.context = nil
end

function GhostAppearState:create(context)
	local v = GhostAppearState.new()
	v.context = context
	v.mainLogic = context.mainLogic
	v.boardView = v.mainLogic.boardView
	return v
end

function GhostAppearState:getNextState()
	return self.context.needRefreshState
end

function GhostAppearState:checkTransition()
	-- printx(11, "GhostAppearState, checkTransition")
	return self.nextState
end

function GhostAppearState:getClassName()
	return "GhostAppearState"
end

function GhostAppearState:onExit()
	-- printx(11, "GhostAppearState onExit", debug.traceback())
	BaseStableState.onExit(self)

	self.nextState = nil
end

function GhostAppearState:onEnter()
	BaseStableState.onEnter(self)
	local context = self

    if not self.mainLogic._fieldLogicPossibility[_FIELD_LOGIC_ID.ghostAppear] then
    	printx(0, '!skip')
		self.nextState = self:getNextState()
        return
    end

	self.nextState = nil
	
	self:_tryGenerateGhosts()
end

--------------------------------------------------------------------------------------------
--										出去走走
--------------------------------------------------------------------------------------------
function GhostAppearState:_tryGenerateGhosts()
	local pickedTargets = {}
	local generateNumByBoardMin, generateNumByStep

	local allAppearPoint = GhostLogic:getAllGhostsAppearPoint(self.mainLogic)
	if #allAppearPoint > 0 then
		generateNumByBoardMin, generateNumByStep = GhostLogic:getGenerateGhostAmountIfNeeded(self.mainLogic)
		-- printx(11, "_tryGenerateGhosts generateNumByBoardMin, generateNumByStep", generateNumByBoardMin, generateNumByStep)
		local sumGenerateAmount = generateNumByBoardMin + generateNumByStep
	    if sumGenerateAmount > 0 then
	    	pickedTargets = GhostLogic:pickGenerateTargets(self.mainLogic, sumGenerateAmount)
	    end
	end

    -- printx(11, "_tryGenerateGhosts #pickedTargets", #pickedTargets)
    if #pickedTargets > 0 then
		-- self.context.needLoopCheck = true	--生成出来后，要检测
    	self:_generateGhosts(pickedTargets, generateNumByBoardMin, generateNumByStep)
    else
    	self.nextState = self:getNextState()
	end
end

function GhostAppearState:_generateGhosts(pickedTargets, generateNumByBoardMin, generateNumByStep)
	local function actionCallback()
		-- FallingItemLogic:preUpdateHelpMap(self.mainLogic)
    	self.nextState = self:getNextState()
    	self.context:onEnter()		--没有falling，强制调用来轮转state
		-- printx(11, "GhostAppearState, action callBack. nextState:", self.nextState)
	end

	local action = GameBoardActionDataSet:createAs(
	        GameActionTargetType.kGameItemAction,
	        GameItemActionType.kItem_ghost_generate, 
	        nil,
	        nil,
	        GamePlayConfig_MaxAction_time
	        )
    action.pickedTargets = pickedTargets
    action.generateNumByBoardMin = generateNumByBoardMin
    action.generateNumByStep = generateNumByStep
    action.completeCallback = actionCallback
    -- self.mainLogic:addDestroyAction(action)
    self.mainLogic:addGlobalCoreAction(action)
	self.mainLogic:setNeedCheckFalling()
end

