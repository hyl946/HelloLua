---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2016-07-11 17:37:18
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   dan.liang
-- @Last Modified time: 2019-01-21 11:29:21
---------------------------------------------------------------------------------------
HorizontalEndlessMode = class(GameMode)

local ScrollWaitCfg = class()

function ScrollWaitCfg:create(config)
	local cfg = ScrollWaitCfg.new()
	cfg:init(config)
	return cfg
end

function ScrollWaitCfg:init(config)
	local sortedCols = {}
	local stepsByCol = {}
	if config and table.size(config) > 0 then
		for k, v in pairs(config) do
			local col = tonumber(k)
			stepsByCol[col] = tonumber(v)
			table.insert(sortedCols, col)
		end
		table.sort(sortedCols)
	end
	self.sortedCols = sortedCols
	self.stepsByCol = stepsByCol
end

function ScrollWaitCfg:getWaitStepsByCol(col)
	assert(col)
	local size = #self.sortedCols
	if size > 0 then
		if col < self.sortedCols[1] then return 0 end
		if col >= self.sortedCols[size] then return self.stepsByCol[self.sortedCols[size]] end
		for i = 1, size - 1 do
			if self.sortedCols[i] <= col and col < self.sortedCols[i+1] then
				return self.stepsByCol[self.sortedCols[i]]
			end
		end
	end
	return 0
end

function ScrollWaitCfg:setWaitStepsByCol(col , step)
	assert(col)

	self.stepsByCol[col] = step

	local sortedCols = {}
	for k, v in pairs(self.stepsByCol) do
		table.insert(sortedCols, tonumber(k))
	end
	table.sort(sortedCols)
	self.sortedCols = sortedCols
end

function HorizontalEndlessMode:update(dt)
  if self.mainLogic.isGamePaused == false then 
  	local t = HeTimeUtil:getCurrentTimeMillis() / 1000
    if not self._dt then self._dt = t end
    local passTime = t - self._dt
    self.mainLogic.timeTotalUsed = self.mainLogic.timeTotalUsed + passTime
    self._dt = t
  end
end

function HorizontalEndlessMode:initModeSpecial(config)
	GameMode.initModeSpecial(self)
	self.levelConfig = config
	self.totalAdditionColCount = GameExtandPlayLogic:clacBoardColCount(self.mainLogic.digBoardMap)
	self.scrollWaitCfg = ScrollWaitCfg:create(config.hScrollWaitCfg)
	self.isFailByRefresh = false
	self.mainLogic.passedCol = 0
end

function HorizontalEndlessMode:reachEndCondition()
	assert(false, "need impl")
  return false
end

function HorizontalEndlessMode:failByRefresh()
	self.isFailByRefresh = true
	return false
end

function HorizontalEndlessMode:afterFail()
	self.mainLogic:setGamePlayStatus(GamePlayStatus.kFailed)
end

function HorizontalEndlessMode:onGameStart()
	self.mainLogic:setGamePlayStatus(GamePlayStatus.kNormal)
	self.mainLogic.boardView:showItemViewLayer()
	self.mainLogic.boardView:removeDigScrollView()
	self.mainLogic.boardView.isPaused = false
	self.mainLogic.fsm:initState()

	self:onStartGame()
end

function HorizontalEndlessMode:onGameInit()
	local context = self
	local function setGameStart()
		self:onGameStart()
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
		context.mainLogic.boardView:startHorizontalScrollInitView(playPrePropAnimation)
	end
	local col = GameExtandPlayLogic:clacBoardColCount(context.mainLogic.digBoardMap)
	if col > 17 then col = 17 end
	local extraItemMap, extraBoardMap = context:getExtraMap(0, col)
	self.mainLogic.boardView:initHorizontalScrollView(extraItemMap, extraBoardMap)
	self.mainLogic.boardView:hideItemViewLayer()
	

	if self.mainLogic.PlayUIDelegate then
		-- self.mainLogic.PlayUIDelegate.moveOrTimeCounter:setVisible(false)
		self.mainLogic.PlayUIDelegate:playLevelTargetPanelAnim(playDigScrollAnimation)
	else
		playDigScrollAnimation()
	end
	self.mainLogic:stopWaitingOperation()
end

function HorizontalEndlessMode:checkScrollDigGround(scrollComplete)
	return false
end

function HorizontalEndlessMode:getWaitStepsByCol(col)
	return self.scrollWaitCfg:getWaitStepsByCol(col)
end

function HorizontalEndlessMode:doScrollDigGround(moveUpCol, stableScrollCallback)
	local extraItemMap, extraBoardMap = self:getExtraMap(self.mainLogic.passedCol, moveUpCol)
	local mainLogic = self.mainLogic
	local context = self
	local function scrollCallback()
		local newItemMap = {}
		local newBoardMap = {}
		for r = 1, 9 do
			local row = r
			newItemMap[r] = {}
			newBoardMap[r] = {}
			for c = 1, 9 do
                local emptyTile = TileMetaData.new()
                emptyTile:addTileData(TileConst.kEmpty)
				local col = c + moveUpCol

				local item = extraItemMap[row][col]
				local mimosaHoldGrid = item.mimosaHoldGrid
				item.mimosaHoldGrid = {}
				for _, v in pairs(mimosaHoldGrid) do 
					v.y = v.y - moveUpCol
					if v.y >= mainLogic.boardView.startColIndex then
						table.insert(item.mimosaHoldGrid, v)
					end
				end

                if c < mainLogic.boardView.startColIndex then 
                    item = GameItemData:create() 
                    item:initByConfig(emptyTile)
                end
				item.x = c
				item.y = r

				local board = extraBoardMap[row][col]
                if c < mainLogic.boardView.startColIndex then 
                    board = GameBoardData:create() 
                    board:initByConfig(emptyTile)
                end
                if board:hasEnterPortal() then
                	board.passExitPoint_y = c
                end
                if board:hasExitPortal() then
                	board.passEnterPoint_y = c
                end
				board.y = r
				board.x = c
				-- board.isProducer = mainLogic.boardmap[r][col].isProducer
				-- board.theGameBoardFallType = table.clone(mainLogic.boardmap[r][col].theGameBoardFallType)
				newItemMap[r][c] = item
				newBoardMap[r][c] = board
				mainLogic:addNeedCheckMatchPoint(r, c)
			end
		end
		mainLogic.gameItemMap = nil
		mainLogic.gameItemMap = newItemMap
		mainLogic.boardmap = nil
		mainLogic.boardmap = newBoardMap
		mainLogic.boardView:reInitByGameBoardLogic()
		mainLogic.boardView:showItemViewLayer()
		mainLogic.boardView:removeDigScrollView()

		if stableScrollCallback and type(stableScrollCallback) == "function" then
			stableScrollCallback()
		end
	end

	self.mainLogic.passedCol = self.mainLogic.passedCol + moveUpCol
	self.mainLogic.boardView:hideItemViewLayer()
	local time, extraCol = self.mainLogic.boardView:horizontalScrollMoreDigView(extraItemMap, extraBoardMap, scrollCallback)
	self:onScrollBoardView(time, extraCol)
end

function HorizontalEndlessMode:onScrollBoardView(time, moveDistance)

end

function HorizontalEndlessMode:getExtraMap(passedCol, additionCol)
	local itemMap = {}
	local boardMap = {}

	local colCountUsingConfig = 0
	local colCountUsingGenerator = 0

	local totalAdditionColCount = GameExtandPlayLogic:clacBoardColCount(self.mainLogic.digBoardMap)

	if passedCol + additionCol <= totalAdditionColCount then -- all rows from config
		colCountUsingConfig = additionCol
		colCountUsingGenerator = 0
	elseif passedCol >= totalAdditionColCount then -- all rows from generator
		colCountUsingConfig = 0
		colCountUsingGenerator = additionCol 
	else
		colCountUsingConfig = totalAdditionColCount - passedCol
		colCountUsingGenerator = additionCol - colCountUsingConfig
	end

	if _G.isLocalDevelopMode then printx(0, passedCol,additionCol,colCountUsingConfig,colCountUsingGenerator) end

	-- init row 1 to row 9
	local normalColCount = GameExtandPlayLogic:clacBoardColCount(self.mainLogic.boardmap)
	for r = 1, #self.mainLogic.gameItemMap do
		itemMap[r] = {}
		boardMap[r] = {}
		for c = 1, #self.mainLogic.gameItemMap[r] do
			itemMap[r][c] = self.mainLogic.gameItemMap[r][c]
			boardMap[r][c] = self.mainLogic.boardmap[r][c]
		end
	end

	-- read config rows if available
	if colCountUsingConfig > 0 then
		for i = 1, colCountUsingConfig do 
			for r = 1, #itemMap do
				local configColIndex = passedCol + i
				self.mainLogic.digItemMap[r][configColIndex].x = i + normalColCount
				self.mainLogic.digBoardMap[r][configColIndex].x = i + normalColCount
				table.insert(itemMap[r], self.mainLogic.digItemMap[r][configColIndex]:copy())
				table.insert(boardMap[r], self.mainLogic.digBoardMap[r][configColIndex]:copy())
			end
		end
	end

	if colCountUsingGenerator > 0 then
		local newItemMap, newBoardMap = self:generateAdditionMap(passedCol, colCountUsingGenerator)
		local genColStartIndex = additionCol + normalColCount - colCountUsingGenerator

		for r = 1, #newItemMap do
			for c = 1, #newItemMap[r] do
				local item = newItemMap[r][c]
				local board = newBoardMap[r][c]
				item.x = genColStartIndex + c
				board.x = genColStartIndex + c
				itemMap[r][genColStartIndex + c] = item
				boardMap[r][genColStartIndex + c] = board
			end
		end
	end

	return itemMap, boardMap
end

function HorizontalEndlessMode:generateAdditionMap(passedCol, addCol)
	local mainLogic = self.mainLogic
	local animalMap = self.levelConfig.animalMap

	local newItemMap, newBoardMap = {}, {}
	 local totalAdditionColCount = self.totalAdditionColCount
	 for i = 1, addCol do

	 	local realPassedCol = passedCol - totalAdditionColCount + (i-1)
	 	local loopStart = 26
	 	local loopEnd = 40
	 	local loopCount = loopEnd - loopStart + 1

	 	local realCol = ( realPassedCol % loopCount ) + (loopStart - 9)
	 	--local realCol = (passedCol + i) % totalAdditionColCount + 1

	 	for r = 1, #self.mainLogic.digItemMap do
	 		newItemMap[r] = newItemMap[r] or {}
	 		newBoardMap[r] = newBoardMap[r] or {}
	 		local itemData = self.mainLogic.digItemMap[r][realCol]:copy()
	 		newItemMap[r][i] = itemData
	 		
	 		local animalDef = animalMap[r][realCol+9]
	 		if animalDef then
		 		itemData:initByAnimalDef(animalDef)
		 	end

			if itemData:isColorful() then 			--可以随机颜色的物体
				if itemData._encrypt.ItemColorType == AnimalTypeConfig.kRandom 			--随机类型
					and itemData.ItemSpecialType ~= AnimalTypeConfig.kColor then	
						itemData._encrypt.ItemColorType = mainLogic:randomColor()
				end
			end

	 		newBoardMap[r][i] = self.mainLogic.digBoardMap[r][realCol]:copy()
	 	end
	 end
	 return newItemMap, newBoardMap
end

function HorizontalEndlessMode:useMove()
	GameMode.useMove(self)
end

function HorizontalEndlessMode:saveDataForRevert(saveRevertData)
	local mainLogic = self.mainLogic
	saveRevertData.passedCol = mainLogic.passedCol
	GameMode.saveDataForRevert(self, saveRevertData)
end

function HorizontalEndlessMode:revertDataFromBackProp()
	local mainLogic = self.mainLogic
	mainLogic.passedCol = mainLogic.saveRevertData.passedCol
	GameMode.revertDataFromBackProp(self)
end

function HorizontalEndlessMode:revertUIFromBackProp()
	GameMode.revertUIFromBackProp(self)
end