PacmanEatState = class(BaseStableState)

function PacmanEatState:dispose()
	self.mainLogic = nil
	self.boardView = nil
	self.context = nil
end

function PacmanEatState:create(context)
	local v = PacmanEatState.new()
	v.context = context
	v.mainLogic = context.mainLogic
	v.boardView = v.mainLogic.boardView
	return v
end

function PacmanEatState:getNextState()
	return self.context.pacmanBlowState
end

function PacmanEatState:checkTransition()
	return self.nextState
end

function PacmanEatState:getClassName()
	return "PacmanEatState"
end

function PacmanEatState:onExit()
	BaseStableState.onExit(self)
	self.nextState = nil

	self.allPacmanFinishedEating = false
	self.allHungryPacman = nil
	self.pickedPosition = {}
end

function PacmanEatState:onEnter()
	BaseStableState.onEnter(self)
	local context = self

    if not self.mainLogic._fieldLogicPossibility[_FIELD_LOGIC_ID.pacmanEat] then
    	printx(0, '!skip')
		self:changeToNextState()
        return
    end

	self.nextState = nil

	self.allPacmanFinishedEating = false	--大家都吃完了吗？
	self.allHungryPacman = nil				--所有还饿着的吃豆人
	self.pickedPosition = {}				--已经被其他人吃过的格子. Key: "col,row"
	
	self:letsDigIn()
end

function PacmanEatState:changeToNextState()
	self.nextState = self:getNextState()
end

function PacmanEatState:checkIfAllProcedureEnded()
	if self.allPacmanFinishedEating then
		FallingItemLogic:preUpdateHelpMap(self.mainLogic)
		self.mainLogic:setNeedCheckFalling()

		self:changeToNextState()
	end
end

--------------------------------------------------------------------------------------------
--										民以食为天
--------------------------------------------------------------------------------------------
--------- 开饭啦
function PacmanEatState:letsDigIn()
	self.allHungryPacman = PacmanLogic:pickAllHungryPacman(self.mainLogic)
	if #self.allHungryPacman == 0 then
		self:changeToNextState()
		return
	end

	self:startOneEatingRound(true)

	if not self.allPacmanFinishedEating then
		--增加大循环轮循次数
		self.context.needLoopCheck = true
	end
end

--------- 有饿着的，大家开吃
function PacmanEatState:startOneEatingRound(isFirstRound)
	self.pacmanInEatingAmount = 0

	if #self.allHungryPacman > 0 then
		local index = #self.allHungryPacman
		while index > 0 do
			local pacman = self.allHungryPacman[index]
			if PacmanLogic:pacmanIsFull(self.mainLogic, pacman) then
				table.remove(self.allHungryPacman, index)
			else
				local eatableTarget = PacmanLogic:pickTargetForCertainPacman(self.mainLogic, pacman, self.pickedPosition)
				if eatableTarget then
					--开吃吧！！
					self:onPacmanStartEat(pacman, eatableTarget)
				else
					--没的可吃了
					table.remove(self.allHungryPacman, index)
				end
			end
			index = index - 1
		end
	end

	if #self.allHungryPacman == 0 then
		self.allPacmanFinishedEating = true
		if isFirstRound then
			--- 没有逻辑执行的情况下设置 setNeedCheckFalling 可能会导致进入end state后卡死的问题，
			--- 所以直接切换 state
			self:changeToNextState()
		else
			PacmanLogic:cleanBoardDataAfterAllFinishedEating(self.mainLogic, self.pickedPosition)	-- 进餐完毕，收拾桌面
			self:checkIfAllProcedureEnded()
		end
	end
end

--------- 每个人的餐桌
function PacmanEatState:onPacmanStartEat(pacman, targetItem)
	self.pacmanInEatingAmount = self.pacmanInEatingAmount + 1

	local function actionCallback()
        self:onOnePacmanFinishedEating()
    end

	local pacmanEatAction = GameBoardActionDataSet:createAs(
							 		GameActionTargetType.kGameItemAction,
							 		GameItemActionType.kItem_pacman_eatTarget,
							 		IntCoord:create(pacman.x, pacman.y),
							 		IntCoord:create(targetItem.x, targetItem.y),
							 		GamePlayConfig_MaxAction_time)
	-- printx(11, "pacman eat. pacman, target:".."("..pacman.y..","..pacman.x..") , ("..targetItem.y..","..targetItem.x..")")
	pacmanEatAction.targetPacman = pacman
	pacmanEatAction.targetItem = targetItem
	pacmanEatAction.pacmanCollection = self.allHungryPacman
	pacmanEatAction.completeCallback = actionCallback
	-- self.mainLogic:addGameAction(pacmanEatAction)
	
	self.mainLogic:addDestroyAction(pacmanEatAction)
	self.mainLogic:setNeedCheckFalling()
end

function PacmanEatState:onOnePacmanFinishedEating()
	self.pacmanInEatingAmount = self.pacmanInEatingAmount - 1

	if self.pacmanInEatingAmount == 0 then
		--本轮结束，开始下一轮
		self:startOneEatingRound()
	end
end
