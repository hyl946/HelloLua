SquidRunState = class(BaseStableState)

function SquidRunState:dispose()
	self.mainLogic = nil
	self.boardView = nil
	self.context = nil
end

function SquidRunState:create(context)
	local v = SquidRunState.new()
	v.context = context
	v.mainLogic = context.mainLogic
	v.boardView = v.mainLogic.boardView
	return v
end

function SquidRunState:getNextState()
	return self.context.dripCastingStateInLast_B
end

function SquidRunState:checkTransition()
	return self.nextState
end

function SquidRunState:getClassName()
	return "SquidRunState"
end

function SquidRunState:onExit()
	BaseStableState.onExit(self)
	self.nextState = nil

	self.allSquidFinishedRunning = false
	self.allFullSquid = nil
	self.pickedPosition = {}
end

function SquidRunState:onEnter()
	BaseStableState.onEnter(self)
	local context = self

    if not self.mainLogic._fieldLogicPossibility[_FIELD_LOGIC_ID.squidRun] then
    	printx(0, '!skip')
		self:changeToNextState()
        return
    end

	self.nextState = nil

	self.allSquidFinishedRunning = false	--该走的都走了吗？
	self.allFullSquid = nil					--所有可以走的
	self.pickedPosition = {}				--已经被其他人吃过的格子. Key: "col,row"
	
	self:startRunningCheck()
end

function SquidRunState:changeToNextState()
	self.nextState = self:getNextState()
end

function SquidRunState:checkIfAllProcedureEnded()
	-- printx(11, "=======END")
	if self.allSquidFinishedRunning then
		-- printx(11, "========changeToNextState")
		FallingItemLogic:preUpdateHelpMap(self.mainLogic)
		self.mainLogic:setNeedCheckFalling()

		self:changeToNextState()
	end
end

--------------- 检测所有可以开跑的
function SquidRunState:startRunningCheck()
	self.allFullSquid = SquidLogic:pickAllFullSquid(self.mainLogic)
	-- printx(11, "...", #self.allFullSquid)
	if #self.allFullSquid == 0 then
		self:changeToNextState()
		return
	end

	self:startRunning()
end

function SquidRunState:startRunning(isFirstRound)
	self.squidInRunningAmount = 0

	for _, squid in pairs(self.allFullSquid) do
		local targetGrids = SquidLogic:getSquidRunGrids(self.mainLogic, squid)
		-- printx(11, "squid startRunning", #targetGrids)
		self:onSquidStartRun(squid, targetGrids)
	end

	self.context.needLoopCheck = true
	self.mainLogic:setNeedCheckFalling()
end

function SquidRunState:onSquidStartRun(squid, targetGrids)
	self.squidInRunningAmount = self.squidInRunningAmount + 1

	local function actionCallback()
        self:onOneSquidFinishedRunning()
    end

	local squidAction = GameBoardActionDataSet:createAs(
							 		GameActionTargetType.kGameItemAction,
							 		GameItemActionType.kItem_Squid_Run,
							 		IntCoord:create(squid.x, squid.y),
							 		nil,
							 		GamePlayConfig_MaxAction_time)
	-- printx(11, "squid run. squid, target:".."("..squid.y..","..squid.x..") , ("..targetItem.y..","..targetItem.x..")")
	squidAction.targetSquid = squid
	squidAction.targetGrids = targetGrids
	squidAction.gridAmount = #targetGrids
	squidAction.completeCallback = actionCallback
	self.mainLogic:addDestroyAction(squidAction)
	-- self.mainLogic:addGlobalCoreAction(squidAction)
end

function SquidRunState:onOneSquidFinishedRunning()
	self.squidInRunningAmount = self.squidInRunningAmount - 1
	if self.squidInRunningAmount == 0 then
		self.allSquidFinishedRunning = true

		self:checkIfAllProcedureEnded()
	end
end
