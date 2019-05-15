PacmanBlowState = class(BaseStableState)

function PacmanBlowState:dispose()
	self.mainLogic = nil
	self.boardView = nil
	self.context = nil
end

function PacmanBlowState:create(context)
	local v = PacmanBlowState.new()
	v.context = context
	v.mainLogic = context.mainLogic
	v.boardView = v.mainLogic.boardView
	return v
end

function PacmanBlowState:getNextState()
	return self.context.pacmanGenerateState
end

function PacmanBlowState:checkTransition()
	return self.nextState
end

function PacmanBlowState:getClassName()
	return "PacmanBlowState"
end

function PacmanBlowState:onExit()
	BaseStableState.onExit(self)

	self.nextState = nil
	self.pacmanToBlow = 0
	self.mainLogic.missileHasHitPoint = {}

	-- self.allFullPacmanDemolished = false
end

function PacmanBlowState:onEnter()
	BaseStableState.onEnter(self)
	local context = self

    if not self.mainLogic._fieldLogicPossibility[_FIELD_LOGIC_ID.pacmanBlow] then
    	printx(0, '!skip')
		self.nextState = self:getNextState()
        return
    end

	self.nextState = nil
    self.shotPerItem = 3	--3个击打目标
    self.pacmanToBlow = 0
    self.mainLogic.missileHasHitPoint = {}		--完全沿用冰封导弹击打优先级，反正两个state不会交叉，先借用下啦~
	
	self:tryBlowPacman()
end

--------------------------------------------------------------------------------------------
--									吃饱喝足，回馈社会
--------------------------------------------------------------------------------------------
function PacmanBlowState:tryBlowPacman()
    local allFullPacman = PacmanLogic:pickAllFullPacman(self.mainLogic)
    if #allFullPacman > 0 then
        self.context.needLoopCheck = true
        self:blowAllFullPacman(allFullPacman)
    else
    	self.nextState = self:getNextState()
    end
end

function PacmanBlowState:blowAllFullPacman(allFullPacman)
	self.pacmanToBlow = #allFullPacman

	local function actionCallback()
		self:onOneBlowComplete()
	end

	for _, pacman in ipairs(allFullPacman) do
		local targetPositions = GameExtandPlayLogic:findMissileTarget(self.mainLogic, pacman, self.shotPerItem)	--完全沿用冰封导弹击打优先级

		local action = GameBoardActionDataSet:createAs(
	        GameActionTargetType.kGameItemAction,
	        GameItemActionType.kItem_pacman_blow, 
	        nil,
	        nil,
	        GamePlayConfig_MaxAction_time
	        )
		action.targetPacman = pacman
	    action.targetPositions = targetPositions
	    action.completeCallback = actionCallback
	    self.mainLogic:addDestroyAction(action)
	end

	self.mainLogic:setNeedCheckFalling()
end

function PacmanBlowState:onOneBlowComplete()
	self.pacmanToBlow = self.pacmanToBlow - 1

	if self.pacmanToBlow == 0 then
		FallingItemLogic:preUpdateHelpMap(self.mainLogic)
		self.mainLogic:setNeedCheckFalling()
		
    	self.nextState = self:getNextState()
	end
end
