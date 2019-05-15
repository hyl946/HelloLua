PacmanGenerateState = class(BaseStableState)

function PacmanGenerateState:dispose()
	self.mainLogic = nil
	self.boardView = nil
	self.context = nil
end

function PacmanGenerateState:create(context)
	local v = PacmanGenerateState.new()
	v.context = context
	v.mainLogic = context.mainLogic
	v.boardView = v.mainLogic.boardView
	return v
end

function PacmanGenerateState:getNextState()
	return self.context.blocker199State
end

function PacmanGenerateState:checkTransition()
	-- printx(11, "PacmanGenerateState, checkTransition")
	return self.nextState
end

function PacmanGenerateState:getClassName()
	return "PacmanGenerateState"
end

function PacmanGenerateState:onExit()
	-- printx(11, "PacmanGenerateState onExit")
	BaseStableState.onExit(self)

	self.nextState = nil
end

function PacmanGenerateState:onEnter()
	BaseStableState.onEnter(self)
	local context = self

    if not self.mainLogic._fieldLogicPossibility[_FIELD_LOGIC_ID.pacmanGenerate] then
    	printx(0, '!skip')
		self.nextState = self:getNextState()
        return
    end

	self.nextState = nil
	
	self:tryGeneratePacman()
end

--------------------------------------------------------------------------------------------
--										出去走走
--------------------------------------------------------------------------------------------
function PacmanGenerateState:tryGeneratePacman()
	local pickedTargets = {}
	local generateNumByBoardMin, generateNumByStep = PacmanLogic:getGeneratePacmanAmountIfNeeded(self.mainLogic)
	-- printx(11, "tryGeneratePacman generateNumByBoardMin, generateNumByStep", generateNumByBoardMin, generateNumByStep)
	local sumGenerateAmount = generateNumByBoardMin + generateNumByStep
    if sumGenerateAmount > 0 then
    	pickedTargets = PacmanLogic:pickGenerateTargets(self.mainLogic, sumGenerateAmount)
    end

    -- printx(11, "tryGeneratePacman #pickedTargets", #pickedTargets)
    if #pickedTargets > 0 then
		self.context.needLoopCheck = true	--生成出来后，要检测吃
    	self:generatePacman(pickedTargets, generateNumByBoardMin, generateNumByStep)
    else
    	self.nextState = self:getNextState()
	end
end

function PacmanGenerateState:generatePacman(pickedTargets, generateNumByBoardMin, generateNumByStep)
	local function actionCallback()
		FallingItemLogic:preUpdateHelpMap(self.mainLogic)
		PacmanLogic:updateDenProgressDisplay(self.mainLogic)
    	self.nextState = self:getNextState()
		-- printx(11, "PacmanGenerateState, action callBack. nextState:", self.nextState)
	end

	local action = GameBoardActionDataSet:createAs(
	        GameActionTargetType.kGameItemAction,
	        GameItemActionType.kItem_pacmansDen_generate, 
	        nil,
	        nil,
	        GamePlayConfig_MaxAction_time
	        )
    action.pickedTargets = pickedTargets
    action.generateNumByBoardMin = generateNumByBoardMin
    action.generateNumByStep = generateNumByStep
    action.completeCallback = actionCallback
    self.mainLogic:addDestroyAction(action)
	self.mainLogic:setNeedCheckFalling()
end

