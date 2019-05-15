HedgehogDigEndlessMode = class(MoveMode)

local ground_upgrade_interval       = 2     -- upgrade ground per 2 rows
local add_max_jewel_interval        = 6     -- max_jewel adds 1 per 6 rows
local generate_hedgehog_box_interval    = 7     -- generate 1 hedgehog_box per 2(halloween)|5(dragonboat) rows
local max_jewel_limit               = 8    -- max jewel limit is 15
local initial_max_jewel             = 6
local max_generate_row              = 2
local generate_boss_interval        = 4
local generate_jewel_interval       = 2

local hedgehog_crazy_tip_show_interval = 3

local dig_jewel_energe_total = {25, 45, 55, 65, 65}

DigJewelEnergeCount = class(DataRef)

function DigJewelEnergeCount:ctor()
    self:setValue(0)
end
function DigJewelEnergeCount:setValue(value)
    local key = "DigJewelEnergeCount.digJewelEnergeCount"..tostring(self)
    encrypt_integer(key, value)
end
function DigJewelEnergeCount:getValue()
    local key = "DigJewelEnergeCount.digJewelEnergeCount"..tostring(self)
    return decrypt_integer(key)
end

local GroundGenerator = class()

function GroundGenerator:create(mainLogic)
    local ret = GroundGenerator.new()
    ret:init(mainLogic)
    return ret
end

function GroundGenerator:init(mainLogic)
    self.mainLogic = mainLogic
    self.level1 = 13
    self.level2 = 5
    self.level3 = 0
    self.curIndex = 0
    self.genCount = 0
    self.groundPool = self:genNewGroundPool()
end

function GroundGenerator:genGround()
    if self.curIndex >= #self.groundPool then
        self.groundPool = self:genNewGroundPool()
        self.curIndex = 0
    end
    self.curIndex = self.curIndex + 1
    return self.groundPool[self.curIndex]
end

function GroundGenerator:genNewGroundPool()
    if self.genCount > 0 and self.genCount % ground_upgrade_interval == 0 then
        if self.level2 < 10 and self.level3 < 3 then
            if self.level2 < 1 or self.mainLogic.randFactory:rand(1, 100) > 50 then -- 1 -> 2
                self.level1 = self.level1 - 1
                self.level2 = self.level2 + 1
            else -- 2 -> 3
                self.level2 = self.level2 - 1
                self.level3 = self.level3 + 1
            end
        elseif self.level2 < 10 then
            self.level1 = self.level1 - 1
            self.level2 = self.level2 + 1
        elseif self.level3 < 3 then
            self.level2 = self.level2 - 1
            self.level3 = self.level3 + 1
        end
    end
    self.groundPool = {}
    for i = 1, self.level1 do table.insert(self.groundPool, 1) end
    for i = 1, self.level2 do table.insert(self.groundPool, 2) end
    for i = 1, self.level3 do table.insert(self.groundPool, 3) end

    local length = self.level1 + self.level2 + self.level3
    -- 打乱次序
    for i =1 , length do 
        local selector = self.mainLogic.randFactory:rand(1, length)
        self.groundPool[1], self.groundPool[selector] = self.groundPool[selector], self.groundPool[1]
    end
    self.genCount = self.genCount + 1
    -- if _G.isLocalDevelopMode then printx(0, "GroundGenerator:genNewGroundPool:", table.tostring(self.groundPool)) end
    return self.groundPool
end

function HedgehogDigEndlessMode:initModeSpecial( config )
	-- body
	self.mainLogic.digJewelCount = DigJewelCount.new()
    self.mainLogic.maydayBossCount = 0
	self.rowCountSinceLastGroundUpgrade = 0
    self.maxJewel = initial_max_jewel
    self.generatedRowCount = 0
    self.digExtendRouteData = config.digExtendRouteData
    self.currentGeneratRow = 0

    self.rowCountSinceLastHedgehogBox = 0

    self.digJewelEnergeCount = DigJewelEnergeCount.new()
    self.digJewelEnergeLevel = 1
    self.hedgehogCrazyStep = 0

    self.generateItemPool = {}
    self.generateBoardPool = {}
    self.generateCounter = 0
    self.totalGenRowNum = 0
    self.mainLogic.passedRow = 0
end

function HedgehogDigEndlessMode:addEnergeCount( value )
    -- body
    self.digJewelEnergeCount:setValue(self.digJewelEnergeCount:getValue() + value)
end

function HedgehogDigEndlessMode:getPercentEnerge( ... )
    -- body
    local total = dig_jewel_energe_total[self.digJewelEnergeLevel]
    return self.digJewelEnergeCount:getValue() / total
end

function HedgehogDigEndlessMode:releaseEnerge( ... )
    -- body
    self.digJewelEnergeCount:setValue(self.digJewelEnergeCount:getValue() - dig_jewel_energe_total[self.digJewelEnergeLevel])
    self.digJewelEnergeLevel = self.digJewelEnergeLevel + 1
    if self.digJewelEnergeLevel > #dig_jewel_energe_total then
        self.digJewelEnergeLevel = #dig_jewel_energe_total
    end
    local deleget = self.mainLogic.PlayUIDelegate
    if deleget then
        deleget:updateFillTarget(self:getPercentEnerge())
    end
end

function HedgehogDigEndlessMode:afterFail()
    if _G.isLocalDevelopMode then printx(0, 'HedgehogDigEndlessMode:afterFail') end
    local mainLogic = self.mainLogic
    local function tryAgainWhenFailed(isTryAgain, propId, deltaStep)   ----确认加5步之后，修改数据
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

function HedgehogDigEndlessMode:initSpecialHedgeBoxCfg( ... )
    -- body
    local mainLogic = self.mainLogic
    local dragonBoatData = mainLogic.dragonBoatData
    if not dragonBoatData then return end
    local hedgehogBoxCfg = mainLogic.hedgehogBoxCfg
    hedgehogBoxCfg:changPercent(dragonBoatData.dropPropsPercent)
end

function HedgehogDigEndlessMode:onGameInit()
    local context = self
    local function setGameStart()
        context:initSpecialHedgeBoxCfg()
        context.mainLogic:setGamePlayStatus(GamePlayStatus.kNormal)

        context.mainLogic.boardView.isPaused = false
        context.mainLogic.fsm:initState()

        self.generatedRowCount = 0
        self.lastGenJewelTimes = 0
        self.lastGenBossTimes  = 0
        self.rowCountSinceLastHedgehogBox = 0
        context.mainLogic.isHedgehogCrazy = false        ---标示蜗牛是否在sonic状态
        self.groundGenerator = GroundGenerator:create(self.mainLogic)

        self:onStartGame()
    end

    local function playHedgehogOut( ... )
        -- body
        context.mainLogic.boardView:showItemViewLayer()
        context.mainLogic.boardView:removeDigScrollView()
        local r,c = context:findHedgehogRC()
        local item_view = context.mainLogic.boardView.baseMap[r][c]
        item_view:playHedgehogOut(setGameStart)

        local item_data = context.mainLogic.gameItemMap[r][c]
        item_data.hedge_before = false
    end

    local function playPrePropAnimation()
        if context.mainLogic.PlayUIDelegate then
            context.mainLogic.PlayUIDelegate:playPrePropAnimation(playHedgehogOut) 
        else
            playHedgehogOut()
        end
    end

    local function playDigScrollAnimation()
        context.mainLogic.boardView:startScrollInitDigView(playPrePropAnimation)
    end

    local extraItemMap, extraBoardMap = context:getExtraMap(0, #context.mainLogic.digBoardMap)
    -- self.mainLogic:updateAllMagicTiles(extraBoardMap)
    -- if _G.isLocalDevelopMode then printx(0, 'extraItemMap', #extraItemMap, 'extraBoardMap', #extraBoardMap) end
    self.mainLogic.boardView:initDigScrollView(extraItemMap, extraBoardMap, true)
    self.mainLogic.boardView:hideItemViewLayer()
    

    if self.mainLogic.PlayUIDelegate then
        self.mainLogic.PlayUIDelegate:playLevelTargetPanelAnim(playDigScrollAnimation)
    else
        playDigScrollAnimation()
    end
    self.mainLogic:stopWaitingOperation()
end

function HedgehogDigEndlessMode:reachEndCondition()
    return MoveMode.reachEndCondition(self)
end

function HedgehogDigEndlessMode:reachTarget()
    return false
end


function HedgehogDigEndlessMode:checkScrollDigGround( stableScrollCallback , isHedgehogCrazy)
	-- body
	local maxDigGroundRow = self:getDigGroundMaxRow()
	local SCROLL_GROUND_MIN_LIMIT = isHedgehogCrazy and 4 or 2
	local SCROLL_GROUND_MAX_LIMIT = 5

	if maxDigGroundRow <= SCROLL_GROUND_MIN_LIMIT then
        -- 检查棋盘上的路径
        local reachableRoads = self:checkReachableRoads()
        local maxMoveUpLimit = 9
        if reachableRoads and #reachableRoads > 0 then
            local reachableMinRow = 9
            for _, v in pairs(reachableRoads) do
                if reachableMinRow > v.x then
                    reachableMinRow = v.x
                end
            end
            maxMoveUpLimit = reachableMinRow - 1
        end
		
        local moveUpRow = math.min(SCROLL_GROUND_MAX_LIMIT - maxDigGroundRow, maxMoveUpLimit)

		self:doScrollDigGround(moveUpRow, stableScrollCallback)
		return true
	end
	return false
end

function HedgehogDigEndlessMode:checkReachableRoads()
    local ret = {}
    local itemMap = self.mainLogic.gameItemMap
    local boardmap = self.mainLogic.boardmap
    local r,c = self:findHedgehogRC()
    local nextPos = boardmap[r][c]:getNextSnailRoad()
    while nextPos do
        if self.mainLogic:isPosValid(nextPos.x, nextPos.y) then
            table.insert(ret, IntCoord:create(nextPos.x, nextPos.y))
            nextPos = boardmap[nextPos.x][nextPos.y]:getNextSnailRoad()
        else
            nextPos = nil
        end
    end
    -- if _G.isLocalDevelopMode then printx(0, ">>>>> checkReachableRoads:", table.tostring(ret)) end
    return ret
end

function HedgehogDigEndlessMode:getDigGroundMaxRow( ... )
	-- body
	local gameItemMap = self.mainLogic.gameItemMap
	for r = 1, #gameItemMap do
		for c = 1, #gameItemMap[r] do
			if gameItemMap[r][c]:isHedgehog() then
				return 10 - r
			end
		end
	end
	return 0
end

function HedgehogDigEndlessMode:doScrollDigGround(moveUpRow, stableScrollCallback)
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
				board.isProducer = mainLogic.boardmap[r][c].isProducer
				board.theGameBoardFallType = table.clone(mainLogic.boardmap[r][c].theGameBoardFallType)
				newItemMap[r][c] = item
				newBoardMap[r][c] = board
				mainLogic:addNeedCheckMatchPoint(r, c)
			end
		end
		mainLogic.gameItemMap = nil
		mainLogic.gameItemMap = newItemMap
		mainLogic.boardmap = nil
		mainLogic.boardmap = newBoardMap
		HedgehogLogic:resetPreSnailRoads( mainLogic.boardmap )
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

function HedgehogDigEndlessMode:getExtraMap(passedRow, additionRow)
    local itemMap = {}
    local boardMap = {}

    local rowCountUsingConfig = 0
    local rowCountUsingGenerator = 0

    local totalAvailableConfigRowCount = #self.mainLogic.digItemMap
    -- if _G.isLocalDevelopMode then printx(0, ">>>>>>totalAvailableConfigRowCount", totalAvailableConfigRowCount) end
    ---------------------- TEST -----------------------
    -- local totalAvailableConfigRowCount = 0 -- TEST
    ---------------------------------------------------

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
    -- if _G.isLocalDevelopMode then printx(0, 'normalRowCount', normalRowCount) end
    for row = 1, normalRowCount do
        table.insert(itemMap, self.mainLogic.gameItemMap[row])
        table.insert(boardMap, self.mainLogic.boardmap[row])
    end

    -- read config rows if available
    if rowCountUsingConfig > 0 then
        -- if _G.isLocalDevelopMode then printx(0, 'using config') end
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
        local newItemRows, newBoardRows = self:genNewMap(rowCountUsingGenerator)

        self.currentGeneratRow = self.currentGeneratRow + rowCountUsingGenerator
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

    -- if _G.isLocalDevelopMode then printx(0, 'itemMap, boardMap', #itemMap, #boardMap) end
    HedgehogLogic:resetPreSnailRoads( boardMap )
    return itemMap, boardMap
end

function HedgehogDigEndlessMode:genNewMap(rowCountUsingGenerator)
    local newItemRows = {}
    local newBoardRows = {}
    for i = 1, rowCountUsingGenerator do
        local itemRow, boardRow = self:genNextRow()
        table.insert(newItemRows, itemRow)
        table.insert(newBoardRows, boardRow)
    end
    return newItemRows, newBoardRows
end

function HedgehogDigEndlessMode:genNewMapOld(rowCountUsingGenerator)
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

        local tileIndex = (rowIndex + self.currentGeneratRow) % #self.digExtendRouteData
        if tileIndex == 0 then tileIndex = #self.digExtendRouteData end
        board:initSnailRoadDataByConfig(self.digExtendRouteData[tileIndex][colIndex])
        item:initSnailRoadType(board)
    end

    -----------生成宝箱
    for r = 1, #newItemRows do
        local index = (self.currentGeneratRow + r) % generate_hedgehog_box_interval
        if index == 0  then
            local _selectList = {}
            for c = 1, #newItemRows[r] do
                local item = newItemRows[r][c]
                local board = newBoardRows[r][c]
                if board.snailRoadType > 0  then
                    table.insert(_selectList, item)
                end
            end

            local max = #_selectList
            if max > 0 then 
                local item_luck = _selectList[self.mainLogic.randFactory:rand(1, #_selectList)]
                item_luck:changeToHedgehogBox()
            end
        end
    end
    return newItemRows, newBoardRows
end

function HedgehogDigEndlessMode:generateGroundRow(rowCount)
	local result = {}
    if rowCount <= 0 then return result end
    self.generatedRowCount = self.generatedRowCount + rowCount
    self.rowCountSinceLastHedgehogBox = self.rowCountSinceLastHedgehogBox + rowCount
    local genJewelCount = self:getGenJewelCount(rowCount)
    local length = 9 * rowCount
    local usedIndex = {}
    for i = 1, genJewelCount do
        local selector = self.mainLogic.randFactory:rand(1, length)

        while usedIndex[selector] == true and #usedIndex < length do
            selector = self.mainLogic.randFactory:rand(1, length)
        end
        usedIndex[selector] = true
        result[selector] = self:getJewelTileDef()
    end

    for i=1, length do 
        if not result[i] then 
            result[i] = self:getGroundTileDef()
        end
    end
    return result
end

function HedgehogDigEndlessMode:genNextRow()
    if #self.generateItemPool < 1 then
        self:genNewMapDatas(4)
    end
    local itemRow = table.remove(self.generateItemPool, 1)
    local boardRow = table.remove(self.generateBoardPool, 1)
    return itemRow, boardRow
end

function HedgehogDigEndlessMode:genNewMapDatas(cacheRowCount)
    cacheRowCount = cacheRowCount or 4

    local startRepeatRowIndex = 1 
    local totalRowCount = #self.mainLogic.digItemMap
    local copyRowCount = totalRowCount - startRepeatRowIndex + 1

    for i = 1, cacheRowCount do
        local rowIndex = startRepeatRowIndex + self.totalGenRowNum % copyRowCount

        local itemRow = {}
        local boardRow = {}
        for c = 1, #self.mainLogic.digItemMap[rowIndex] do
            table.insert(itemRow, self.mainLogic.digItemMap[rowIndex][c]:copy())
            table.insert(boardRow, self.mainLogic.digBoardMap[rowIndex][c]:copy())
        end
        table.insert(self.generateItemPool, itemRow)
        table.insert(self.generateBoardPool, boardRow)

        self.totalGenRowNum = self.totalGenRowNum + 1
    end
    self.generateCounter = self.generateCounter + 1
    -- 随机生成一定障碍
    self:genBlock(self.generateItemPool, self.generateBoardPool)
    self:changeCloudToJewel(self.generateItemPool, 4)
    self:incrCloudLevel(self.generateItemPool, self.mainLogic.randFactory:rand(2, 4))
    self:genAddFive(self.generateItemPool, 0)
end

function HedgehogDigEndlessMode:changeCloudToJewel(itemRows, num)
    if num <= 0 then return end
    local cloudItems = {}
    for _, row in pairs(itemRows) do
        for _, item in pairs(row) do
            if item.ItemType == GameItemType.kDigGround then
                table.insert(cloudItems, item)
            end
        end
    end
    local changeItems = {}
    if #cloudItems > 0 then
        if #cloudItems <= num then
            changeItems = cloudItems
        else
            for i = 1, num do
                local index = self.mainLogic.randFactory:rand(1, #cloudItems)
                local item = table.remove(cloudItems, index)
                table.insert(changeItems, item)
            end
        end
        for i, item in pairs(changeItems) do
            item.ItemType = GameItemType.kDigJewel
            item.digJewelLevel = item.digGroundLevel
            item.digGroundLevel = 0
            -- if _G.isLocalDevelopMode then printx(0, ">>>>>>>> changeCloudToJewel", i.."/"..num) end
        end
    end
end

function HedgehogDigEndlessMode:incrCloudLevel(itemRows, num)
    if num <= 0 then return end

    local cloudItems = {}
    for _, row in pairs(itemRows) do
        for _, item in pairs(row) do
            if (item.ItemType == GameItemType.kDigGround and item.digGroundLevel < 3)
                or (item.ItemType == GameItemType.kDigJewel and item.digJewelLevel < 3)
                then
                table.insert(cloudItems, item)
            end
        end
    end

    local changeItems = {}
    if #cloudItems > 0 then
        if #cloudItems <= num then
            changeItems = cloudItems
        else
            for i = 1, num do
                local index = self.mainLogic.randFactory:rand(1, #cloudItems)
                local item = table.remove(cloudItems, index)
                table.insert(changeItems, item)
            end
        end
        for i, item in pairs(changeItems) do
            if item.ItemType == GameItemType.kDigGround then
                item.digGroundLevel = item.digGroundLevel + 1
            elseif item.ItemType == GameItemType.kDigJewel then
                item.digJewelLevel = item.digJewelLevel + 1
            end
            -- if _G.isLocalDevelopMode then printx(0, ">>>>>>>> incrCloudLevel", i.."/"..num) end
        end
    end
end

function HedgehogDigEndlessMode:genAddFive(itemRows, num)
    if num <= 0 then return end

    local animalItems = {}
    for _, row in pairs(itemRows) do
        for _, item in pairs(row) do
            if item.ItemType == GameItemType.kAnimal and not AnimalTypeConfig.isSpecialTypeValid(item.ItemSpecialType)
                then
                table.insert(animalItems, item)
            end
        end
    end

    local changeItems = {}
    if #animalItems > 0 then
        for i = 1, num do
            local index = self.mainLogic.randFactory:rand(1, #animalItems)
            local item = table.remove(animalItems, index)
            table.insert(changeItems, item)
        end
        for i, item in pairs(changeItems) do
            item.ItemType = GameItemType.kAddMove
            item.numAddMove = 5
            -- if _G.isLocalDevelopMode then printx(0, ">>>>>>>> genAddFive", i.."/"..num) end
        end
    end
end

local BlockTypes = {
    kGrayFurball    = 1,
    kBrownFurball   = 2,
    kCage           = 3,
    kVenom          = 4,
    kCoin           = 5,
    kPoisonBottle   = 6,
}
local RandomBlockCfg = {  
    {blockType= BlockTypes.kGrayFurball,     weight = 100, min = 3, max = 4}, 
    {blockType= BlockTypes.kBrownFurball,    weight = 100, min = 1, max = 2}, 
    {blockType= BlockTypes.kCage,            weight = 100, min = 3, max = 4}, 
    {blockType= BlockTypes.kVenom,           weight = 100, min = 2, max = 3}, 
    {blockType= BlockTypes.kCoin,            weight = 100, min = 3, max = 4}, 
    {blockType= BlockTypes.kPoisonBottle,    weight = 100, min = 1, max = 1}, 
}
local kTotalWeight = 0
for _, v in pairs(RandomBlockCfg) do
    kTotalWeight = kTotalWeight + v.weight
end

function HedgehogDigEndlessMode:genBlock(itemRows, boardRows)
    local randomNum = self.mainLogic.randFactory:rand(1, kTotalWeight)
    local num = 0
    local randBlock = nil
    -- if _G.isLocalDevelopMode then printx(0, ">>>>>>>>>>>>genBlock randomNum", randomNum.."/"..kTotalWeight) end
    for _, v in pairs(RandomBlockCfg) do
        num = num + v.weight
        if randomNum <= num then
            randBlock = v
            break
        end
    end

    if randBlock then
        -- 普通动物和云块
        local changeNum = self.mainLogic.randFactory:rand(randBlock.min, randBlock.max)

        local itemsPrior1 = {}
        local itemsPrior2 = {}
        for r, row in pairs(itemRows) do
            for c, item in pairs(row) do
                if (item.ItemType == GameItemType.kAnimal and not AnimalTypeConfig.isSpecialTypeValid(item.ItemSpecialType))
                    or item.ItemType == GameItemType.kCrystal
                    or item.ItemType == GameItemType.kDigGround
                    or item.ItemType == GameItemType.kDigJewel
                    then
                    local board = boardRows[r][c]
                    if randBlock.blockType == BlockTypes.kPoisonBottle and board:getSnailRoadViewType() then
                        -- 章鱼不可生成在boss路径上
                    else
                        if (item.ItemType == GameItemType.kDigGround and item.digGroundLevel > 1)
                                or item.ItemType == GameItemType.kDigJewel then
                            table.insert(itemsPrior2, item)
                        else
                            table.insert(itemsPrior1, item)
                        end
                    end
                end
            end
        end
        if #itemsPrior1 > 0 or #itemsPrior2 > 0 then
            for i = 1, changeNum do
                local canChangeItems = #itemsPrior1 > 0 and itemsPrior1 or itemsPrior2
                if #canChangeItems <= 0 then break end

                local randIndex = self.mainLogic.randFactory:rand(1, #canChangeItems)
                local randItem = table.remove(canChangeItems, randIndex)
                randItem:cleanAnimalLikeData()

                local tileDef = TileMetaData.new()
                if randBlock.blockType == BlockTypes.kGrayFurball then
                    tileDef:addTileData(TileConst.kAnimal)
                    tileDef:addTileData(TileConst.kGreyCute)
                elseif randBlock.blockType == BlockTypes.kBrownFurball then
                    tileDef:addTileData(TileConst.kAnimal)
                    tileDef:addTileData(TileConst.kBrownCute)
                elseif randBlock.blockType == BlockTypes.kCage then
                    tileDef:addTileData(TileConst.kAnimal)
                    tileDef:addTileData(TileConst.kLock)
                elseif randBlock.blockType == BlockTypes.kVenom then
                    tileDef:addTileData(TileConst.kPoison)
                elseif randBlock.blockType == BlockTypes.kCoin then
                    tileDef:addTileData(TileConst.kCoin)
                elseif randBlock.blockType == BlockTypes.kPoisonBottle then
                    tileDef:addTileData(TileConst.kPoisonBottle)
                end
                randItem:initByConfig(tileDef)
                if randItem:isColorful() and randItem.ItemType ~= GameItemType.kDrip then
                    randItem._encrypt.ItemColorType = self.mainLogic:randomColor()
                end

                -- mylog(">>>>>>>>>>> genBlock", randBlock.blockType, i.."/"..changeNum)
                -- mylog(">>>>>>>>>>> genBlock", #itemsPrior1, "||",#itemsPrior2 )
            end
        end
    end
end

function HedgehogDigEndlessMode:shouldHedgehogBox()
    if self.rowCountSinceLastHedgehogBox >= generate_hedgehog_box_interval then
        self.rowCountSinceLastHedgehogBox = self.rowCountSinceLastHedgehogBox - generate_hedgehog_box_interval
        return true
    end
    return false
end

function HedgehogDigEndlessMode:getMaxJewelPerTwoRows()
    local maxJewel = initial_max_jewel + math.floor(self.generatedRowCount / add_max_jewel_interval)
    return math.min(maxJewel, max_jewel_limit)
end

function HedgehogDigEndlessMode:getGenJewelCount(rowCount)
    local genJewelTimes = math.floor(self.generatedRowCount / generate_jewel_interval)
    local result = math.floor(self:getMaxJewelPerTwoRows() / 2 * rowCount)
    return result
end

function HedgehogDigEndlessMode:getGroundTileDef()
    local level = self.groundGenerator:genGround()
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

function HedgehogDigEndlessMode:getJewelTileDef()
    local level = self.groundGenerator:genGround()
    local tileDef = TileMetaData.new()
    -- if _G.isLocalDevelopMode then printx(0, 'level', level) end
    tileDef:addTileData(TileConst.kBlocker)
    if level == 1 then
        tileDef:addTileData(TileConst.kDigJewel_1_blue)
    elseif level == 2 then
        tileDef:addTileData(TileConst.kDigJewel_2_blue)
    elseif level == 3 then
        tileDef:addTileData(TileConst.kDigJewel_3_blue)
    end
    return tileDef
end

function HedgehogDigEndlessMode:findHedgehogRC( ... )
    -- body
     for r = 1, #self.mainLogic.gameItemMap do
        for c = 1, #self.mainLogic.gameItemMap[r] do 
            if self.mainLogic.gameItemMap[r][c]:isHedgehog() then
                return r, c
            end
        end 
    end

    return 0, 0
end

function HedgehogDigEndlessMode:checkNeedBombDigGround( callback , isCrazy)
    -- body
    local maxR, maxC = self:findHedgehogRC()
    local limitR = isCrazy and 6 or 8
    if maxR < limitR then 
        return 0 
    end
    local count = 0
    local itemlist = {}
    local mainLogic = self.mainLogic
    for r = 1, maxR - 1 do 
        for c = 1, #mainLogic.gameItemMap[r] do 
            local item = mainLogic.gameItemMap[r][c]
            if item.digGroundLevel > 0 then
                table.insert(itemlist, {r = r, c = c})
                count = count + 1
            elseif item.digJewelLevel > 0 then
                count = count + 1
                table.insert(itemlist, {r = r, c = c})
            end
        end
    end

    if count > 0 then
        local action = GameBoardActionDataSet:createAs(
                        GameActionTargetType.kGameItemAction,
                        GameItemActionType.kItem_Hedgehog_Clean_Dig_Groud,
                        IntCoord:create(maxR, maxC),   
                        IntCoord:create(5, 5),    
                        GamePlayConfig_MaxAction_time)
                    action.completeCallback = callback
                    action.itemlist = itemlist
                   mainLogic:addGameAction(action)
    end
    return count
end

function HedgehogDigEndlessMode:checkEnergyIsFill()
    -- body
    local total = dig_jewel_energe_total[self.digJewelEnergeLevel]
    return self.digJewelEnergeCount:getValue() >= total
end

function HedgehogDigEndlessMode:checkHedgehogIsCrazy( r, c )
    -- body
    local item = self.mainLogic.gameItemMap[r][c]
    if item.hedgehogLevel > 1 then 
        return true
    else
        return false
    end
end

function HedgehogDigEndlessMode:checkIsShowTipToCrazy( r, c )
    -- body
    if self:checkHedgehogIsCrazy(r, c) and self.hedgehogCrazyStep >= hedgehog_crazy_tip_show_interval then
        self.hedgehogCrazyStep = 0
        return true
    end
    return false
end

function HedgehogDigEndlessMode:checkIsReleaseEnery( r, c )
    -- body
    if self:checkEnergyIsFill() and not self:checkHedgehogIsCrazy( r, c ) then
        return true
    end
    return false
end

function HedgehogDigEndlessMode:useMove( )
    -- body
    MoveMode.useMove(self)
    local r, c = self:findHedgehogRC()
    if self:checkHedgehogIsCrazy(r,c) then
        self.hedgehogCrazyStep = self.hedgehogCrazyStep + 1
    end
end

function HedgehogDigEndlessMode:canAddEnerge( ... )
    -- body
    if self.mainLogic.isHedgehogCrazy then
        return not self:checkEnergyIsFill()
    else
        local total = dig_jewel_energe_total[self.digJewelEnergeLevel]
        if self.digJewelEnergeLevel >= #dig_jewel_energe_total then
            total = total * 2
        else
            total = total + dig_jewel_energe_total[self.digJewelEnergeLevel + 1]
        end
        return self.digJewelEnergeCount:getValue() < total
    end
end
