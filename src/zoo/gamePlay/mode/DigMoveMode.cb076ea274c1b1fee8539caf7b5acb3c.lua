DigMoveMode = class(MoveMode)

function DigMoveMode:initModeSpecial(config)
	self.mainLogic.digJewelLeftCount = tonumber(config.clearTargetLayers)
	self.mainLogic.digJewelTotalCount = tonumber(config.clearTargetLayers)
	self.mainLogic.passedRow = 0
end

function DigMoveMode:onGameInit()
	local context = self
	local isAct5003Effective = CollectStarsYEMgr.getInstance():isBuffIngameEffective()
	CollectStarsYEMgr.getInstance():setIngameFlag(false)
	
	local function setGameStart()
		context.mainLogic:setGamePlayStatus(GamePlayStatus.kNormal)
		context.mainLogic.boardView:showItemViewLayer()
		context.mainLogic.boardView:removeDigScrollView()
		context.mainLogic.boardView.isPaused = false
		context.mainLogic.fsm:initState()

		self:onStartGame()		
	end

	local function handleGameTopPartAni()
		if isAct5003Effective then
			CollectStarsYEMgr.getInstance():playBuffAnim(context.mainLogic, setGameStart)
		else
			setGameStart()
		end
	end

	local function playInitBuffAnimation()
		if GameInitBuffLogic:hasAnyInitBuffIncludedReplay() then

			GameInitBuffLogic:tryFindBuffPos()

			if GameInitBuffLogic:hasAnyInitBuff() then
				GameInitBuffLogic:doChangeBoardByGameInitBuff( function () handleGameTopPartAni() end )
			else
				handleGameTopPartAni()
			end
		else
			handleGameTopPartAni()
		end
	end

	local function playPrePropAnimation()
		if context.mainLogic.PlayUIDelegate then
			context.mainLogic.PlayUIDelegate:playPrePropAnimation(playInitBuffAnimation)	
		else
			handleGameTopPartAni()
		end
	end

	local function playDigScrollAnimation()
		context.mainLogic.boardView:startScrollInitDigView(playPrePropAnimation)
	end
	
	local extraItemMap = context:getExtraItemMap(0, #context.mainLogic.digItemMap)
	local extraBoardMap = context:getExtraBoardMap(0, #context.mainLogic.digBoardMap)
	self.mainLogic.boardView:initDigScrollView(extraItemMap, extraBoardMap)
	self.mainLogic.boardView:hideItemViewLayer()
	

	if self.mainLogic.PlayUIDelegate then
		self.mainLogic.PlayUIDelegate:playLevelTargetPanelAnim(playDigScrollAnimation)
	else
		playDigScrollAnimation()
	end
	self.mainLogic:stopWaitingOperation()
end

function DigMoveMode:reachEndCondition()
	return MoveMode.reachEndCondition(self) or self:isJewelEnough()
end

function DigMoveMode:reachTarget()
	return self:isJewelEnough()
end

function DigMoveMode:isJewelEnough()
	return self.mainLogic.digJewelLeftCount <= 0
end

--获取包含当前屏幕在内的挖地扩展屏内的itemMap数据 
--passedRow		已滚动过的行数
--additionRow	向下扩展的行数
function DigMoveMode:getExtraItemMap(passedRow, additionRow)
	local result = {}
	local normalRowCount = #self.mainLogic.gameItemMap
	for row = 1, normalRowCount do
		table.insert(result, self.mainLogic.gameItemMap[row])
	end
	for r = 1, additionRow do
		local row = r + passedRow
		table.insert(result, self.mainLogic.digItemMap[row])
		for c = 1, #self.mainLogic.digItemMap[row] do
			self.mainLogic.digItemMap[row][c].y = r + normalRowCount
		end
	end
	return result
end

function DigMoveMode:getExtraBoardMap(passedRow, additionRow)
	local result = {}
	local normalRowCount = #self.mainLogic.boardmap
	for row = 1, normalRowCount do
		table.insert(result, self.mainLogic.boardmap[row])
	end
	for r = 1, additionRow do
		local row = r + passedRow
		table.insert(result, self.mainLogic.digBoardMap[row])
		for c = 1, #self.mainLogic.digBoardMap[row] do
			self.mainLogic.digBoardMap[row][c].y = r + normalRowCount
		end
	end
	return result
end

function DigMoveMode:checkScrollDigGround(stableScrollCallback)
	local maxDigGroundRow = self:getDigGroundMaxRow()
	local availableRow = self:getNumAvailableDigGroundRow()
	local SCROLL_GROUND_MIN_LIMIT = 2
	local SCROLL_GROUND_MAX_LIMIT = 4

	if (not self:reachTarget() and maxDigGroundRow <= SCROLL_GROUND_MIN_LIMIT and availableRow > 0) 
		or (self:reachTarget() and maxDigGroundRow < SCROLL_GROUND_MAX_LIMIT and availableRow > 0)
		then
		local moveUpRow = 0
		local deltaRow = SCROLL_GROUND_MAX_LIMIT - maxDigGroundRow
		if availableRow < deltaRow then
			moveUpRow = availableRow
		else
			moveUpRow = deltaRow
		end
		self:doScrollDigGround(moveUpRow, stableScrollCallback)
		return true
	end
	return false
end

function DigMoveMode:doScrollDigGround(moveUpRow, stableScrollCallback)
	local extraItemMap = self:getExtraItemMap(self.mainLogic.passedRow, moveUpRow)
	local extraBoardMap = self:getExtraBoardMap(self.mainLogic.passedRow, moveUpRow)

	local mainLogic = self.mainLogic
	local context = self
	local function scrollCallback()
		local newItemMap = {}
		local newBoardMap = {}
		for r = 1, 9 do
			local row = r + moveUpRow
			newItemMap[r] = {}
			newBoardMap[r] = {}
			for c = 1, 9 do
				local item = extraItemMap[row][c]:copy()
				local mimosaHoldGrid = item.mimosaHoldGrid
				item.mimosaHoldGrid = {}
				for k, v in pairs(mimosaHoldGrid) do 
					v.x = v.x - moveUpRow
					if v.x > 0 then
						table.insert(item.mimosaHoldGrid, v)
					end
				end

				item.y = r
				local board = extraBoardMap[row][c]:copy()
				board.y = r
				newItemMap[r][c] = item
				newBoardMap[r][c] = board
				mainLogic:addNeedCheckMatchPoint(r, c)
			end
		end
		mainLogic.gameItemMap = nil
		mainLogic.gameItemMap = newItemMap
		mainLogic.boardmap = nil
		mainLogic.boardmap = newBoardMap
		mainLogic:updateScrollCannon()
		FallingItemLogic:preUpdateHelpMap(mainLogic)
		mainLogic.boardView:reInitByGameBoardLogic()
		mainLogic.boardView:showItemViewLayer()
		mainLogic.boardView:removeDigScrollView()

		if stableScrollCallback and type(stableScrollCallback) == "function" then
			stableScrollCallback()
		end
	end

	self.mainLogic.passedRow = self.mainLogic.passedRow + moveUpRow
	self.mainLogic.boardView:hideItemViewLayer()
	self.mainLogic.boardView:scrollMoreDigView(extraItemMap, extraBoardMap, scrollCallback)
end

function DigMoveMode:getNumAvailableDigGroundRow()
	return #self.mainLogic.digItemMap - self.mainLogic.passedRow
end

--获得从含有挖地云块的第一层到最下一层的层数
function DigMoveMode:getDigGroundMaxRow()
	local gameItemMap = self.mainLogic.gameItemMap
	for r = 1, #gameItemMap do
		for c = 1, #gameItemMap[r] do
			if gameItemMap[r][c].ItemType == GameItemType.kDigGround
				or gameItemMap[r][c].ItemType == GameItemType.kDigJewel
				then
				return 10 - r
			end
		end
	end
	return 0
end

function DigMoveMode:saveDataForRevert(saveRevertData)
	local mainLogic = self.mainLogic
	saveRevertData.passedRow = mainLogic.passedRow
	saveRevertData.digJewelLeftCount = mainLogic.digJewelLeftCount
	MoveMode.saveDataForRevert(self,saveRevertData)
end

function DigMoveMode:revertDataFromBackProp()
	local mainLogic = self.mainLogic
	mainLogic.passedRow = mainLogic.saveRevertData.passedRow
	mainLogic.digJewelLeftCount = mainLogic.saveRevertData.digJewelLeftCount
	MoveMode.revertDataFromBackProp(self)
end

function DigMoveMode:revertUIFromBackProp()
	local mainLogic = self.mainLogic
	if mainLogic.PlayUIDelegate then
		mainLogic.PlayUIDelegate:revertTargetNumber(0, 0, mainLogic.digJewelLeftCount)
	end
	MoveMode.revertUIFromBackProp(self)
end