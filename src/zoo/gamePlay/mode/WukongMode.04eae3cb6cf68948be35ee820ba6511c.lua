WukongMode = class(MoveMode)
require "zoo.config.LevelDropPropConfig"


local ground_upgrade_interval       = 2     -- upgrade ground per 2 rows
local add_max_jewel_interval        = 6     -- max_jewel adds 1 per 6 rows
local generate_add_move_interval    = 5     -- generate 1 add_move per 2(halloween)|5(dragonboat) rows
local max_jewel_limit               = 8    -- max jewel limit is 15
local initial_max_jewel             = 6
local max_generate_row              = 2
local generate_boss_interval        = 4
local generate_jewel_interval       = 2


local GroundGenerator = class()

baseWukongChargingTotalValue  = {
	[1] = 25 ,
	[2] = 25 ,
	[3] = 25 ,
	[4] = 40 ,
	[5] = 50 ,
}
--baseWukongChargingTotalValue = baseWukongChargingTotalValueList[1]
baseWukongChargingValue       = 0
wukongCastingCount = 0
wukongLastGuideCastingCount = -1

function getBaseWukongChargingTotalValue()
	if wukongCastingCount < 4 then
		return baseWukongChargingTotalValue[wukongCastingCount + 1]
	else
		return baseWukongChargingTotalValue[5]
	end
end

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

function WukongMode:ctor(mainLogic)
	self.mainLogic = mainLogic
	wukongCastingCount = 0 
    wukongLastGuideCastingCount = -1
end

function WukongMode:initModeSpecial(config)
    self.mainLogic.digJewelCount = DigJewelCount.new()
    self.mainLogic.maydayBossCount = 0
   

    -- initialize ground pool
    self.rowCountSinceLastGroundUpgrade = 0
    self.generatedRowCount = 0
    self.rowCountSinceLastAddMove = 0
    self.bossGenRowCountDown = 1

    self.lastGenBossTimes = 0
    self.lastGenJewelTimes = 0
    -- 魔法地格的数据结构  保存地格的id和击中的次数
    self.mainLogic.magicTileStruct = {}
    self.mainLogic:updateAllMagicTiles()

    self.mainLogic.wukongPropConfig = LevelDropPropConfig:create(config.monkeyChestConfig)
end

function WukongMode:afterFail()
    if _G.isLocalDevelopMode then printx(0, 'WukongMode:afterFail') end
    local mainLogic = self.mainLogic
    local function tryAgainWhenFailed(isTryAgain, propId, deltaStep)   ----确认加5步之后，修改数据
        if isTryAgain then
            self:getAddSteps(deltaStep or 5)
            mainLogic:setGamePlayStatus(GamePlayStatus.kNormal)
            mainLogic.fsm:changeState(mainLogic.fsm.waitingState)
        else
            if MoveMode.reachEndCondition(self) then
                self.leftMoveToWin = 0
                mainLogic:setGamePlayStatus(GamePlayStatus.kBonus)
                wukongLastGuideCastingCount = -1
            else
            	self.leftMoveToWin = 0
                mainLogic:setGamePlayStatus(GamePlayStatus.kBonus)
                --mainLogic:setGamePlayStatus(GamePlayStatus.kFailed)
                wukongLastGuideCastingCount = -1
            end
        end
    end 
    if mainLogic.PlayUIDelegate then
        mainLogic.PlayUIDelegate:addStep(mainLogic.level, mainLogic.totalScore, self:getScoreStarLevel(mainLogic), self:reachTarget(), tryAgainWhenFailed)
    end
end

function WukongMode:onGameInit()
    local context = self
    local function setGameStart()
        context.mainLogic:setGamePlayStatus(GamePlayStatus.kNormal)
        context.mainLogic.boardView:showItemViewLayer()
        context.mainLogic.boardView:removeDigScrollView()
        context.mainLogic.boardView.isPaused = false
        context.mainLogic.fsm:initState()

        self.generatedRowCount = 0
        self.rowCountSinceLastAddMove = 0
        self.lastGenJewelTimes = 0
        self.lastGenBossTimes  = 0

        context.mainLogic.boardView:updateWukongTargetBoard()
        --context.mainLogic.theCurMoves = 10

        self:onStartGame()
    end

    local function playPrePropAnimation()
        if context.mainLogic.PlayUIDelegate then
            context.mainLogic.PlayUIDelegate:playPrePropAnimation(setGameStart) 
        else
            setGameStart()
        end
    end

    local function playDigScrollAnimation()
        context.mainLogic.boardView:startScrollInitDigView(playPrePropAnimation)
    end

    self.groundGenerator = GroundGenerator:create(self.mainLogic)
    local extraItemMap, extraBoardMap = context:getExtraMap(0, #context.mainLogic.digBoardMap)

    --self.mainLogic:updateAllMagicTiles(extraBoardMap)
    
    -- if _G.isLocalDevelopMode then printx(0, 'extraItemMap', #extraItemMap, 'extraBoardMap', #extraBoardMap) end
    self.mainLogic.boardView:initDigScrollView(extraItemMap, extraBoardMap, true)
    self.mainLogic.boardView:hideItemViewLayer()
    self.mainLogic.passedRow = 0

    wukongLastGuideCastingCount = -1
    self.useWukongJump = false

    self.wukongDropProp = false

    if self.mainLogic.PlayUIDelegate then
        self.mainLogic.PlayUIDelegate:playLevelTargetPanelAnim(playDigScrollAnimation)
    else
        playDigScrollAnimation()
    end
    self.mainLogic:stopWaitingOperation()
end

function WukongMode:reachEndCondition()
    return MoveMode.reachEndCondition(self)
end

function WukongMode:reachTarget()
    return false
end

function WukongMode:onBossDie()
    local leftGroundRow = self:getDigGroundMaxRow()
    self.bossGenRowCountDown = 5 - leftGroundRow
    if _G.isLocalDevelopMode then printx(0, "WukongMode:onBossDie, bossGenRowCountDown=", self.bossGenRowCountDown) end
end

function WukongMode:getExtraMap(passedRow, additionRow)
    -- debug.debug()
    local itemMap = {}
    local boardMap = {}

    local rowCountUsingConfig = 0
    local rowCountUsingGenerator = 0

    local totalAvailableConfigRowCount = 0
    if self.mainLogic.digItemMap and #self.mainLogic.digItemMap > 0 then
    	totalAvailableConfigRowCount = #self.mainLogic.digItemMap
    end
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

    -- if _G.isLocalDevelopMode then printx(0, 'itemMap, boardMap', #itemMap, #boardMap) end
    return itemMap, boardMap
end

function WukongMode:checkScrollDigGround(stableScrollCallback)

	local needScroll = true
	for r = 1, #self.mainLogic.boardmap do
        for c = 1, #self.mainLogic.boardmap[r] do
            local board = self.mainLogic.boardmap[r][c]
            if board.isWukongTarget then
                needScroll = false                      
            end
        end
    end

    if needScroll then

    	local function localCallback()

            stableScrollCallback()
        end

        --local maxDigGroundRow = self:getDigGroundMaxRow()
        local wukongRow = self:getWukongRow()
	    local SCROLL_GROUND_MIN_LIMIT = 2
	    local SCROLL_GROUND_MAX_LIMIT = 3
        local moveUpRow = wukongRow - SCROLL_GROUND_MAX_LIMIT

        if moveUpRow > 0 then
        	 self:doScrollDigGround(moveUpRow, localCallback)
        	 return true
        end
    end
	
    return false
end

--获取最靠上的悟空的Row（如果有多个悟空）
function WukongMode:getWukongRow()

	local minRow = 9

	for r = 1, #self.mainLogic.gameItemMap do
        for c = 1, #self.mainLogic.gameItemMap[r] do
            local item = self.mainLogic.gameItemMap[r][c]
            if item.ItemType == GameItemType.kWukong then
                if item.y < minRow then
                	minRow = item.y
                end
            end
        end
    end

    return minRow
end

function WukongMode:doScrollDigGround(moveUpRow, stableScrollCallback)
    -- if _G.isLocalDevelopMode then printx(0, 'moveUpRow', moveUpRow) end debug.debug()
    local extraItemMap, extraBoardMap = self:getExtraMap(self.mainLogic.passedRow, moveUpRow)
    local mainLogic = self.mainLogic
    local context = self

    local selector = nil
    local function scrollCallback()

        local newItemMap = {}
        local newBoardMap = {}
        for r = 1, 9 do
            local row = r + moveUpRow
            newItemMap[r] = {}
            newBoardMap[r] = {}
            for c = 1, 9 do
                local item = extraItemMap[row][c]:copy()
                local tileDef = TileMetaData.new()
                tileDef:addTileData(TileConst.kEmpty)
                if r < mainLogic.boardView.startRowIndex then 
                    item = GameItemData:create() 
                    item:initByConfig(tileDef)
                end
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
                if r < mainLogic.boardView.startRowIndex and item.magicTileId ~= nil then 
                    board = GameBoardData:create() 
                    board:initByConfig(tileDef)
                end
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

        FallingItemLogic:preUpdateHelpMap(mainLogic)
        mainLogic.boardView:reInitByGameBoardLogic()
        mainLogic.boardView:showItemViewLayer()
        mainLogic.boardView:removeDigScrollView()

		mainLogic:setNeedCheckFalling()
		mainLogic.boardView:updateWukongTargetBoard()
        if stableScrollCallback and type(stableScrollCallback) == "function" then
            stableScrollCallback()
        end
    end

    self.mainLogic.passedRow = self.mainLogic.passedRow + moveUpRow
    self.mainLogic.boardView:hideItemViewLayer()
    self.mainLogic.boardView:scrollMoreDigView(extraItemMap, extraBoardMap, scrollCallback, true)
end

--获得从含有挖地云块的第一层到最下一层的层数
function WukongMode:getDigGroundMaxRow()
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

function WukongMode:hasBossOnMap()
    return false
end

function WukongMode:saveDataForRevert(saveRevertData)
    local mainLogic = self.mainLogic
    saveRevertData.passedRow = mainLogic.passedRow
    saveRevertData.digJewelCount = mainLogic.digJewelCount:getValue()
    saveRevertData.maydayBossCount = mainLogic.maydayBossCount
    MoveMode.saveDataForRevert(self,saveRevertData)
end

function WukongMode:revertDataFromBackProp()
    local mainLogic = self.mainLogic
    mainLogic.passedRow = mainLogic.saveRevertData.passedRow
    mainLogic.digJewelCount:setValue(mainLogic.saveRevertData.digJewelCount)
    mainLogic.maydayBossCount = mainLogic.saveRevertData.maydayBossCount
    MoveMode.revertDataFromBackProp(self)
end

function WukongMode:revertUIFromBackProp()
    local mainLogic = self.mainLogic
    if mainLogic.PlayUIDelegate then
        mainLogic.PlayUIDelegate:revertTargetNumber(0, 0, mainLogic.digJewelCount:getValue())
        mainLogic.PlayUIDelegate:revertTargetNumber(0, 2, mainLogic.maydayBossCount)
    end
    MoveMode.revertUIFromBackProp(self)
end

function WukongMode:generateGroundRow(rowCount)

    local result = {}

    if rowCount <= 0 then return result end

	self.generatedRowCount = self.generatedRowCount + rowCount
    self.rowCountSinceLastAddMove = self.rowCountSinceLastAddMove + rowCount
    local genJewelCount = self:getGenJewelCount(rowCount)

    local length = 9 * rowCount
    local usedIndex = {}

    -- generate jewel
    for i = 1, genJewelCount do
        local selector = self.mainLogic.randFactory:rand(1, length)

        while usedIndex[selector] == true and #usedIndex < length do
            selector = self.mainLogic.randFactory:rand(1, length)
        end
        usedIndex[selector] = true
        result[selector] = self:getJewelTileDef()
    end

    local shouldAddMove = self:shouldAddMove()
    if shouldAddMove then
        local selector = self.mainLogic.randFactory:rand(1, length)
        while usedIndex[selector] == true and #usedIndex < length do
            selector = self.mainLogic.randFactory:rand(1, length)
        end
        usedIndex[selector] = true
        result[selector] = self:getAddMoveTileDef()
    end

    for i=1, length do 
        if not result[i] then 
            result[i] = self:getGroundTileDef()
        end
    end

    --[[
    for k, v in pairs(magicTileIndex) do
        result[v]:addTileData(TileConst.kMagicTile)
    end
    ]]
    ----[[
    if rowCount > 1 then
    	local wumongTargetMinRow = rowCount - 2
    	local wumongTargetMaxRow = rowCount - 1
    	local targetStartRow = 1
    	local targetEndRow = 1
    	
    	if wumongTargetMinRow < 1 then wumongTargetMinRow = wumongTargetMaxRow end

    	if self.mainLogic.randFactory:rand(1, 2) == 1 then
    		targetStartRow = wumongTargetMinRow

    		if targetStartRow + 1 <= wumongTargetMaxRow then
    			targetEndRow = targetStartRow + 1
    		else
    			targetEndRow = targetStartRow
    		end
    	else
    		targetStartRow = wumongTargetMaxRow

    		if targetStartRow - 1 >= wumongTargetMinRow then
    			targetEndRow = targetStartRow - 1
    		else
    			targetEndRow = targetStartRow
    		end
    	end

    	local startRowStartCol = self.mainLogic.randFactory:rand(1, 9)
    	local startRowLeftColCount = 9 - startRowStartCol + 1
    	local startRowMaxColCount = math.min( 4 , startRowLeftColCount )
    	local startRowColCount = self.mainLogic.randFactory:rand(1, startRowMaxColCount)

    	local endRowColCount = 4 - startRowColCount
    	local endRowStartColMin = math.max( startRowStartCol - endRowColCount + 1 , 1 )
    	local endRowStartColMax = math.min( startRowStartCol + endRowColCount - 1 , 9 - endRowColCount + 1 )
    	local endRowStartCol = self.mainLogic.randFactory:rand(endRowStartColMin , endRowStartColMax )
    	
    	local ia = 9 * (targetStartRow - 1) + startRowStartCol
    	for i = ia , ia + startRowColCount - 1 do
    		result[i]:addTileData(TileConst.kWukongTarget)
    	end

    	if endRowColCount > 0 then
    		ia = 9 * (targetEndRow - 1) + endRowStartCol
    		for i = ia , ia + endRowColCount - 1 do
	    		result[i]:addTileData(TileConst.kWukongTarget)
	    	end
   		end


    end

    --]]

    return result
end

function WukongMode:chargeByDigJewel(position)
	----[[
	for r = 1, #self.mainLogic.gameItemMap do
        for c = 1, #self.mainLogic.gameItemMap[r] do
            local item = self.mainLogic.gameItemMap[r][c]
            if item.ItemType == GameItemType.kWukong 
            	and item.wukongProgressCurr < item.wukongProgressTotal 
    			and ( item.wukongState == TileWukongState.kNormal or item.wukongState == TileWukongState.kOnHit )
    			and not self.mainLogic.isBonusTime
            	then

	            local action = GameBoardActionDataSet:createAs(
	                    GameActionTargetType.kGameItemAction,
	                    GameItemActionType.kItem_Wukong_Charging,
	                    IntCoord:create(r, c),
	                    nil,
	                    GamePlayConfig_MaxAction_time
	                )
				action.count = 3
				action.fromPosition = {}
				table.insert( action.fromPosition , position )
				
			    self.mainLogic:addDestroyAction(action)
            end
        end
    end
   --]]
end


function WukongMode:testGen()
    for i = 1, 30 do
        local str = ""
        for j = 1, 18 do
            local ground = self.groundGenerator:genGround()
            str = str .. ground
        end
        if _G.isLocalDevelopMode then printx(0, str) end
    end
end

function WukongMode:getGenBossCount()
    return 0
end

function WukongMode:getMaxJewelPerTwoRows()
    local maxJewel = initial_max_jewel + math.floor(self.generatedRowCount / add_max_jewel_interval)
    return math.min(maxJewel, max_jewel_limit)
end

function WukongMode:getGenJewelCount(rowCount)
    --local genJewelTimes = math.floor(self.generatedRowCount / generate_jewel_interval)
    local result = math.floor(self:getMaxJewelPerTwoRows() / ground_upgrade_interval * rowCount)
    return result
end


function WukongMode:shouldAddMove(rowCount)
    if self.rowCountSinceLastAddMove >= generate_add_move_interval then
        self.rowCountSinceLastAddMove = self.rowCountSinceLastAddMove - generate_add_move_interval
        return true
    else 
        return false
    end
end

function WukongMode:getAddMoveTileDef()
    -- add_move + animal
    local tileDef = TileMetaData.new()
    tileDef:addTileData(TileConst.kAddMove)
    tileDef:addTileData(TileConst.kAnimal)
    return tileDef
end

function WukongMode:getGroundTileDef()
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

function WukongMode:getJewelTileDef()
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

function WukongMode:getBossTileDef()
end

function WukongMode:getBossEmptyTileDef()
end

function WukongMode:initBossBlood()
end

function WukongMode:getGuideTilePos()
    local boardmap = self.mainLogic.boardmap
    for r = 1, #boardmap do
        if boardmap[r] then
            for c = 1, #boardmap[r] do
                local item = boardmap[r][c]
                if item and item.isMagicTileAnchor then
                    local pos = {r = r, c = c}
                    return pos
                end
            end
        end
    end
end