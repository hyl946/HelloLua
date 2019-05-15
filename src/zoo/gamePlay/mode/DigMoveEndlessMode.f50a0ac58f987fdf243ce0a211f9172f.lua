DigMoveEndlessMode = class(MoveMode)

local ground_upgrade_interval 		= 4 	-- upgrade ground per 4 rows
local add_max_jewel_interval 		= 6 	-- max_jewel adds 1 per 6 rows
local generate_add_move_interval 	= 2 	-- generate 1 add_move per 2 rows
local max_jewel_limit 				= 15 	-- max jewel limit is 15
local initial_max_jewel 			= 1
local max_generate_row 				= 2


function DigMoveEndlessMode:initModeSpecial(config)
	self.mainLogic.digJewelCount = DigJewelCount.new()
	self.mainLogic.passedRow = 0

	-- initialize ground pool
	self.groundPool = {}
	for i=1, 9*max_generate_row do
		self.groundPool[i] = 1 -- level 1 ground
	end
	self.rowCountSinceLastGroundUpgrade = 0
	self.rowCountSinceLastAddMove = 0
	self.rowCountSinceLastJewelUpgrade = 0
	self.maxJewel = 1
	
end

function DigMoveEndlessMode:afterFail()
	if _G.isLocalDevelopMode then printx(0, 'DigMoveEndlessMode:afterFail') end
	local mainLogic = self.mainLogic
	local function tryAgainWhenFailed(isTryAgain, propId, deltaStep)	----确认加5步之后，修改数据
	    if isTryAgain then
	      	self:getAddSteps(deltaStep or 5)
	     	mainLogic:setGamePlayStatus(GamePlayStatus.kNormal)
	      	mainLogic.fsm:changeState(mainLogic.fsm.waitingState)
	    else
	    	if MoveMode.reachEndCondition(self) then
	    		self.leftMoveToWin = self.theCurMoves
	    		mainLogic:setGamePlayStatus(GamePlayStatus.kBonus)
	    	else
		      	mainLogic:setGamePlayStatus(GamePlayStatus.kFailed)
		    end
	    end
  	end 
  	if mainLogic.PlayUIDelegate then
    	mainLogic.PlayUIDelegate:addStep(mainLogic.level, mainLogic.totalScore, self:getScoreStarLevel(mainLogic), self:reachTarget(), tryAgainWhenFailed)
  	end
end

function DigMoveEndlessMode:onGameInit()
	local context = self
	local function setGameStart()
		context.mainLogic:setGamePlayStatus(GamePlayStatus.kNormal)
		context.mainLogic.boardView:showItemViewLayer()
		context.mainLogic.boardView:removeDigScrollView()
		context.mainLogic.boardView.isPaused = false
		context.mainLogic.fsm:initState()

		self:onStartGame()		
	end

	local function playInitBuffAnimation()

		if GameInitBuffLogic:hasAnyInitBuffIncludedReplay() then

			GameInitBuffLogic:tryFindBuffPos()

			if GameInitBuffLogic:hasAnyInitBuff() then
				GameInitBuffLogic:doChangeBoardByGameInitBuff( function () setGameStart() end )
			else
				setGameStart()
			end
		else
			setGameStart()
		end
	end


	local function playPrePropAnimation()

		if context.mainLogic.PlayUIDelegate then
			context.mainLogic.PlayUIDelegate:playPrePropAnimation(playInitBuffAnimation)	
		else
			setGameStart()
		end
	end

	local function playDigScrollAnimation()
		context.mainLogic.boardView:startScrollInitDigView(playPrePropAnimation)
	end

	local extraItemMap, extraBoardMap = context:getExtraMap(0, #context.mainLogic.digBoardMap)
	self.mainLogic.boardView:initDigScrollView(extraItemMap, extraBoardMap)
	self.mainLogic.boardView:hideItemViewLayer()
	--self.mainLogic.passedRow = 0

	if self.mainLogic.PlayUIDelegate then
		self.mainLogic.PlayUIDelegate:playLevelTargetPanelAnim(playDigScrollAnimation)
	else
		playDigScrollAnimation()
	end
	self.mainLogic:stopWaitingOperation()
end

function DigMoveEndlessMode:reachEndCondition()
	return MoveMode.reachEndCondition(self)
end

function DigMoveEndlessMode:reachTarget()
	return false
end

function DigMoveEndlessMode:getExtraMap(passedRow, additionRow)
	local itemMap = {}
	local boardMap = {}

	local rowCountUsingConfig = 0
	local rowCountUsingGenerator = 0

	local totalAvailableConfigRowCount = #self.mainLogic.digItemMap

	if passedRow + additionRow <= totalAvailableConfigRowCount then -- all rows from config
		rowCountUsingConfig = additionRow
		rowCountUsingGenerator = 0
	elseif passedRow >= totalAvailableConfigRowCount then -- all rows from generator
		rowCountUsingConfig = 0
		rowCountUsingGenerator = additionRow 
	else
		rowCountUsingConfig = totalAvailableConfigRowCount - passedRow
		rowCountUsingGenerator = additionRow - rowCountUsingConfig
	end

	-- init row 1 to row 9
	local normalRowCount = #self.mainLogic.gameItemMap
	for row = 1, normalRowCount do
		table.insert(itemMap, self.mainLogic.gameItemMap[row])
		table.insert(boardMap, self.mainLogic.boardmap[row])
	end

	-- read config rows if available
	if rowCountUsingConfig > 0 then
		for i = 1, rowCountUsingConfig do 
			local configRowIndex = passedRow + i
			table.insert(itemMap, self.mainLogic.digItemMap[configRowIndex])
			table.insert(boardMap, self.mainLogic.digBoardMap[configRowIndex])
			for c = 1, #self.mainLogic.digItemMap[configRowIndex] do 
				self.mainLogic.digItemMap[configRowIndex][c].y = i + normalRowCount
			end
			for c = 1, #self.mainLogic.digBoardMap[configRowIndex] do
				self.mainLogic.digBoardMap[configRowIndex][c].y = i + normalRowCount
			end
		end
	end

	if rowCountUsingGenerator > 0 then
		local generatedItems = self:generateGroundRow(rowCountUsingGenerator)
		local newItemRows = {}
		local newBoardRows = {}
		for i=1, rowCountUsingGenerator do 
			newItemRows[i] = {}
			newBoardRows[i] = {}
		end

		for k, v in pairs(generatedItems) do 
			local item = GameItemData:create()
			item:initByConfig(v)
			local r = self.mainLogic:randomColor()
			local colorIndex = AnimalTypeConfig.convertColorTypeToIndex(r)
			item:initByAnimalDef(math.pow(2, colorIndex))
			item:initBalloonConfig(self.mainLogic.balloonFrom)
			item:initAddMoveConfig(self.mainLogic.addMoveBase)

			local board = GameBoardData:create()
			board:initByConfig(v)

			local rowIndex = math.ceil(k / 9)
			local colIndex = k - (rowIndex - 1) * 9 
			newItemRows[rowIndex][colIndex] = item
			newBoardRows[rowIndex][colIndex] = board
		end


		local genRowStartIndex = additionRow + normalRowCount - rowCountUsingGenerator

		for k1, itemRow in pairs(newItemRows) do 
			table.insert(itemMap, itemRow)
			for k2, col in pairs(itemRow) do 
				col.x = k2
				col.y = k1 + genRowStartIndex
			end
		end

		for k1, boardRow in pairs(newBoardRows) do 
			table.insert(boardMap, boardRow)
			for k2, col in pairs(boardRow) do 
				col.x = k2
				col.y = k1 + genRowStartIndex
			end
		end
	end

    if _G.isLocalDevelopMode then printx(0, 'itemMap, boardMap', #itemMap, #boardMap) end
	return itemMap, boardMap
end

function DigMoveEndlessMode:checkScrollDigGround(stableScrollCallback)
	local maxDigGroundRow = self:getDigGroundMaxRow()
	local SCROLL_GROUND_MIN_LIMIT = 2
	local SCROLL_GROUND_MAX_LIMIT = 4

	if maxDigGroundRow <= SCROLL_GROUND_MIN_LIMIT then
		local moveUpRow = SCROLL_GROUND_MAX_LIMIT - maxDigGroundRow
		self:doScrollDigGround(moveUpRow, stableScrollCallback)
		return true
	end
	return false
end

function DigMoveEndlessMode:doScrollDigGround(moveUpRow, stableScrollCallback)
	local extraItemMap, extraBoardMap = self:getExtraMap(self.mainLogic.passedRow, moveUpRow)
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

--获得从含有挖地云块的第一层到最下一层的层数
function DigMoveEndlessMode:getDigGroundMaxRow()
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

function DigMoveEndlessMode:saveDataForRevert(saveRevertData)
	local mainLogic = self.mainLogic
	saveRevertData.passedRow = mainLogic.passedRow
	saveRevertData.digJewelCount = mainLogic.digJewelCount:getValue()
	MoveMode.saveDataForRevert(self,saveRevertData)
end

function DigMoveEndlessMode:revertDataFromBackProp()
	local mainLogic = self.mainLogic
	mainLogic.passedRow = mainLogic.saveRevertData.passedRow
	mainLogic.digJewelCount:setValue(mainLogic.saveRevertData.digJewelCount)
	MoveMode.revertDataFromBackProp(self)
end

function DigMoveEndlessMode:revertUIFromBackProp()
	local mainLogic = self.mainLogic
	if mainLogic.PlayUIDelegate then
		mainLogic.PlayUIDelegate:revertTargetNumber(0, 0, mainLogic.digJewelCount:getValue())
	end
	MoveMode.revertUIFromBackProp(self)
end

function DigMoveEndlessMode:generateGroundRow(rowCount)

	local result = {}

	if rowCount <= 0 then return result end

	self.rowCountSinceLastGroundUpgrade = self.rowCountSinceLastGroundUpgrade + rowCount
	self.rowCountSinceLastAddMove = self.rowCountSinceLastAddMove + rowCount
	self.rowCountSinceLastJewelUpgrade = self.rowCountSinceLastJewelUpgrade + rowCount

	self:upgradeMaxJewel()
	self:upgradeGround()
	local shouldAddMove = self:shouldAddMove()

	if _G.isLocalDevelopMode then printx(0, 'rowCount', rowCount) end
	if _G.isLocalDevelopMode then printx(0, 'shouldAddMove', shouldAddMove) end
	if _G.isLocalDevelopMode then printx(0, 'self.rowCountSinceLastGroundUpgrade', self.rowCountSinceLastGroundUpgrade) end
	if _G.isLocalDevelopMode then printx(0, 'self.rowCountSinceLastAddMove', self.rowCountSinceLastAddMove) end
	if _G.isLocalDevelopMode then printx(0, 'self.rowCountSinceLastJewelUpgrade', self.rowCountSinceLastJewelUpgrade) end



	local length = 9 * rowCount
	local usedIndex = {}

	-- generate add_move

	if shouldAddMove then
		if _G.isLocalDevelopMode then printx(0, 'GEN Add Move', self.rowCountSinceLastAddMove) end
		local selector = self.mainLogic.randFactory:rand(1, length)
		usedIndex[selector] = true
		result[selector] = self:getAddMoveTileDef()
	end

	-- generate jewel
		if _G.isLocalDevelopMode then printx(0, 'GEN jewel', self.maxJewel) end
	for i=1, self.maxJewel do 
		local selector = self.mainLogic.randFactory:rand(1, length)
		while usedIndex[selector] == true and #usedIndex < length do
			selector = self.mainLogic.randFactory:rand(1, length)
		end
		usedIndex[selector] = true
		result[selector] = self:getJewelTileDef(selector)
	end

	for i=1, length do 
		if result[i] == nil then 
			result[i] = self:getGroundTileDef(i)
		end
	end


	return result

end

function DigMoveEndlessMode:upgradeMaxJewel()
	if self.rowCountSinceLastJewelUpgrade >= add_max_jewel_interval and self.maxJewel < max_jewel_limit then
		self.maxJewel = self.maxJewel + 1
		self.rowCountSinceLastJewelUpgrade = self.rowCountSinceLastJewelUpgrade - add_max_jewel_interval -- reset
	end
end

function DigMoveEndlessMode:upgradeGround()
	if self.rowCountSinceLastGroundUpgrade >= ground_upgrade_interval then

		local counter  = 0
		local length = 9 * max_generate_row
		while counter <= length do
			counter = counter + 1
			local selector = self.mainLogic.randFactory:rand(1, length)
			if self.groundPool[selector] and self.groundPool[selector] < 3 then
				self.groundPool[selector] = self.groundPool[selector] + 1
				break
			end
		end
		self.rowCountSinceLastGroundUpgrade = self.rowCountSinceLastGroundUpgrade - ground_upgrade_interval
	end
end

function DigMoveEndlessMode:shouldAddMove()
	if self.rowCountSinceLastAddMove >= generate_add_move_interval then
		self.rowCountSinceLastAddMove = self.rowCountSinceLastAddMove - generate_add_move_interval
		return true
	else 
		return false
	end
end

function DigMoveEndlessMode:getAddMoveTileDef()
	-- add_move + animal
	local tileDef = TileMetaData.new()
	tileDef:addTileData(TileConst.kAddMove)
	tileDef:addTileData(TileConst.kAnimal)
	return tileDef
end

function DigMoveEndlessMode:getGroundTileDef(index)
	local level = self.groundPool[index] or 1
	local tileDef = TileMetaData.new()
	tileDef:addTileData(TileConst.kDigGround)
	tileDef:addTileData(TileConst.kBlocker)
	if level == 1 then
		tileDef:addTileData(TileConst.kDigGround_1)
	elseif level == 2 then
		tileDef:addTileData(TileConst.kDigGround_2)
	elseif level == 3 then
		tileDef:addTileData(TileConst.kDigGround_3)
	end
	return tileDef
end

function DigMoveEndlessMode:getJewelTileDef(index)
	local level = self.groundPool[index] or 1
	local tileDef = TileMetaData.new()
	if _G.isLocalDevelopMode then printx(0, 'level', level) end
	tileDef:addTileData(TileConst.kBlocker)
	if level == 1 then
		tileDef:addTileData(TileConst.kDigJewel_1)
	elseif level == 2 then
		tileDef:addTileData(TileConst.kDigJewel_2)
	elseif level == 3 then
		tileDef:addTileData(TileConst.kDigJewel_3)
	end
	return tileDef
end