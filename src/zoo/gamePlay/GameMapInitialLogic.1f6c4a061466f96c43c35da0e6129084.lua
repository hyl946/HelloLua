require "zoo.config.BaseTransmission"

GameMapInitialLogic = class()

function GameMapInitialLogic:init(mainLogic, config)
	local _tileMap = config.tileMap
	self:initTileData(mainLogic, config)	
	self:initSnailRoadData(mainLogic, config)

	local defaultColors = self:initDefaultColors(config.defaultColorCfg)
	self:initColorAndSpecialData(mainLogic, config)	
	self:initColorType(mainLogic, config.numberOfColors, defaultColors)

	if not mainLogic.replayMode or mainLogic.replayMode == ReplayMode.kNone then
		local checkResult , resultData ,  resultPosList = GameInitDiffChangeLogic:tryChangeBoardByVirtualSeed() --尝试是否要启用虚拟种子
		if checkResult then
			--resultData.modeIndex
			if resultData then
				mainLogic.initAdjustData = resultData
			end
		end
	else
		if mainLogic.initAdjustData then
			GameInitDiffChangeLogic:doChangeBoardByVirtualSeed( mainLogic.initAdjustData )
		end
	end

	self:initDropBuff(mainLogic)
	self:initDigTileMap(mainLogic, config)

	self:initPortal(mainLogic, config.portals)
	self:initMagicLamp(mainLogic)  -- 在计算随机颜色前就初始化神灯
	self:initBottleBlocker(mainLogic)
	self:initWukong(mainLogic)
	self:initCrystalStone(mainLogic)
	self:calculateItemColors(mainLogic, config) --随机小动物
	self:checkItemBlock(mainLogic)
	self:initIngredientProducer(mainLogic)

	self:initTransmission(mainLogic, config)
	self:initDrip(mainLogic)
	self:initGift(mainLogic,config) 
	self:initSquid(mainLogic,config)
    
	self:initRandomProps(mainLogic,config)

	self:initBackSideTileMap(mainLogic, config)

	self:initBlockerCoverMaterialTotalNum(mainLogic)

	self:initLockBoxRopView(mainLogic)
	
    self:initWanSheng(mainLogic,config)
end

function GameMapInitialLogic:initLockBoxRopView(mainLogic)

	local currGroupKey , nextGroupKey = GameExtandPlayLogic:getBlocker206GroupIds(mainLogic)

	for r = 1, #mainLogic.gameItemMap do 
		for c = 1, #mainLogic.gameItemMap[r] do 

			local item = mainLogic.gameItemMap[r][c]

			local function getitem( ar , ac , group)
				if mainLogic.gameItemMap[ar] and mainLogic.gameItemMap[ar][ac] then
					local aitem = mainLogic.gameItemMap[ar][ac]
					if aitem:hasBlocker206() and aitem.lockLevel == group then
						return true
					end
				end
				return false
			end
			--local board = mainLogic.boardmap[r][c]
			if item:hasBlocker206() then 
				
				item.lockBoxRopeRight = getitem(r , c + 1 , item.lockLevel)
				item.lockBoxRopeLeft = getitem(r , c - 1 , item.lockLevel)
				item.lockBoxRopeDown = getitem(r + 1 , c , item.lockLevel)
				item.lockBoxRopeUp = getitem(r - 1 , c , item.lockLevel)

				if item.lockHead then
					item.needKeys = mainLogic.blocker206Cfg[item.lockLevel]
				end

				if item.lockLevel == currGroupKey then
					item.lockBoxActive = true
				end
			end
		end
	end

	--printx( 1 , "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@  blocker206Cfg = " , table.tostring(mainLogic.blocker206Cfg) )

end

function GameMapInitialLogic:initBlockerCoverMaterialTotalNum(mainLogic)
	mainLogic.blockerCoverMaterialTotalNum = 0

	for r = 1, #mainLogic.boardmap do 
		for c = 1, #mainLogic.boardmap[r] do
			local board = mainLogic.boardmap[r][c]
			if board and board.blockerCoverMaterialLevel and board.blockerCoverMaterialLevel > 0 then
				mainLogic.blockerCoverMaterialTotalNum = mainLogic.blockerCoverMaterialTotalNum + 1
			end
		end
	end

	for i= 1,9 do
		if mainLogic.backBoardMap[i] then
			for j=1,9 do
				local board = mainLogic.backBoardMap[i][j]
				if board and board.blockerCoverMaterialLevel and board.blockerCoverMaterialLevel > 0 then
					mainLogic.blockerCoverMaterialTotalNum = mainLogic.blockerCoverMaterialTotalNum + 1
				end
			end
		end
	end
end

function GameMapInitialLogic:initBackSideTileMap(mainLogic, config)
	local backSideTileMap = config.backSideTileMap

	if backSideTileMap then
		for r = 1, 9 do
            if backSideTileMap[r] then
                for c = 1, 9 do
                    local data = backSideTileMap[r][c]
                    if data then

                    	local tileDef = data.tileData
						local gameMode = config.gameMode
						local tileMoveCfg = config.tileMoveCfg

						local backItemData = GameItemData:create()
						local backBoardData = GameBoardData:create()

						self:__initTileData( mainLogic ,  backItemData , backBoardData , tileDef , gameMode , tileMoveCfg )

						backBoardData:initLightUp(tileDef)  

						local animalDef = data.animalData
						backItemData:initByAnimalDef(animalDef)
                    	
						mainLogic.backItemMap[r][c] = backItemData
						mainLogic.backBoardMap[r][c] = backBoardData

						--self:initColorAndSpecialData(mainLogic, config)
						self:__initCrystalStone(backItemData , mainLogic)
						self:__initDrip(backItemData)
						
						if mainLogic.gameItemMap[r][c] ~= nil then
							if backItemData:isColorful() then 			--可以随机颜色的物体
								if backItemData._encrypt.ItemColorType == AnimalTypeConfig.kRandom 			--随机类型
									and backItemData.ItemSpecialType ~= AnimalTypeConfig.kColor then	
										--self:randomSetColor(mainLogic, r, c)
										local color = self:randomColorForPosition(mainLogic, r, c)
										if color and AnimalTypeConfig.isColorTypeValid(color) then
											backItemData._encrypt.ItemColorType = color
										else
											backItemData._encrypt.ItemColorType = AnimalTypeConfig.kBlue
										end
								end
							end
						end

						


                    end
                end
            end
        end
	end
end

function GameMapInitialLogic:__initTileData( mainLogic , itemData , boardData , tileDef , gameMode , tileMoveCfg)

	if boardData then
		boardData:initByConfig(tileDef)
		boardData:setGameModeId(mainLogic.theGamePlayType)
		if boardData.isMoveTile then
			boardData:initTileMoveByConfig(tileMoveCfg)
		end
	end
	
	if itemData then
		itemData:initByConfig(tileDef)
		itemData:initBalloonConfig(mainLogic.balloonFrom)
		itemData:initAddMoveConfig(mainLogic.addMoveBase)
		itemData:initAddTimeConfig(mainLogic.addTime)
	end

	if gameMode == GameModeType.TASK_UNLOCK_DROP_DOWN then 
		if itemData then
			itemData:initUnlockAreaDropDownModeInfo()
		end

		if boardData then
			boardData:initUnlockAreaDropDownModeInfo()
		end
	end
end

--生成地图基础信息
function GameMapInitialLogic:initTileData(mainLogic, config)
	local initScrollCannonData = {}

	local tileMap = config.tileMap
	for r = 1, #tileMap do
		if mainLogic.boardmap[r] == nil then mainLogic.boardmap[r] = {} end
		if mainLogic.gameItemMap[r] == nil then mainLogic.gameItemMap[r] = {} end
		for c = 1, #tileMap[r] do
			local tileDef = tileMap[r][c]
			local gameMode = config.gameMode
			local tileMoveCfg = config.tileMoveCfg
			self:__initTileData( mainLogic , mainLogic.gameItemMap[r][c] , mainLogic.boardmap[r][c] , tileDef , gameMode , tileMoveCfg )

			if mainLogic.boardmap[r][c].isProducer then 
				if not initScrollCannonData[c] then 
					initScrollCannonData[c] = mainLogic.boardmap[r][c].theGameBoardFallType
				end
			end
		end
	end
	mainLogic:setInitScrollCannon(initScrollCannonData)
end

function GameMapInitialLogic:initDropBuff(mainLogic)
	if mainLogic.dropBuffLogic and mainLogic.dropBuffLogic.canBeTriggered then
		mainLogic.dropBuffLogic:onGameInit(mainLogic.realCostMove)
	end
end

function GameMapInitialLogic:initSnailRoadData( mainLogic, config )
	-- body
	local tileMap = config.routeRawData
	if not tileMap then  return end
	local initSnailNum = config.snailInitNum
	local roadType = TileRoadShowType.kSnail
	if config.gameMode == GameModeType.HEDGEHOG_DIG_ENDLESS then
		roadType = TileRoadShowType.kHedgehog
	end
	
	for r = 1, #tileMap do 
		if tileMap[r] then
			for c = 1, #tileMap[r] do
				local tileDef = tileMap[r][c]
				if tileDef then
					local item, board = mainLogic.gameItemMap[r][c], mainLogic.boardmap[r][c]
					board:initSnailRoadDataByConfig(tileDef, roadType)
					item:initSnailRoadType(mainLogic.boardmap[r][c])
					if item.isSnail then 
						mainLogic.snailCount = mainLogic.snailCount + 1
					end
					mainLogic.snailMark = true
				end
			end
		end
	end

	for r = 1, #mainLogic.boardmap do 
		for c = 1, #mainLogic.boardmap[r] do 
			self:setPreSnailRoads(mainLogic, r, c)
			local item = mainLogic.gameItemMap[r][c]
			local board = mainLogic.boardmap[r][c]
			if mainLogic.snailCount < initSnailNum 
				and board
				and board.isSnailProducer 
				and item
				and not item.isSnail 
				and not (item.ItemType == GameItemType.kSquid or item.ItemType == GameItemType.kSquidEmpty)
				then 
				item:changeToSnail(board.snailRoadType)
				mainLogic.snailCount = mainLogic.snailCount + 1
			end
		end
	end
end

function GameMapInitialLogic:setPreSnailRoads( mainLogic , r, c)
	-- body
	local board = mainLogic.boardmap[r][c]
	if board and board:isHasPreSnailRoad() then
		if r - 1 > 0 and mainLogic.boardmap[r-1][c] and mainLogic.boardmap[r-1][c].snailRoadType == RouteConst.kDown then
			board:setPreSnailRoad( RouteConst.kDown, r-1, c)
		elseif mainLogic.boardmap[r+1] and mainLogic.boardmap[r+1][c] and mainLogic.boardmap[r+1][c].snailRoadType == RouteConst.kUp then
			board:setPreSnailRoad( RouteConst.kUp, r+ 1, c)
		elseif c - 1 > 0 and mainLogic.boardmap[r][c -1] and mainLogic.boardmap[r][c -1].snailRoadType == RouteConst.kRight then
			board:setPreSnailRoad(RouteConst.kRight, r, c-1)
		elseif mainLogic.boardmap[r][c+1] and mainLogic.boardmap[r][c+1].snailRoadType == RouteConst.kLeft then
			board:setPreSnailRoad(RouteConst.kLeft, r, c+1)
		else
			board:setPreSnailRoad()
		end

	end
end

function GameMapInitialLogic:__initColorAndSpecialData(mainLogic, config)

end

function GameMapInitialLogic:initDefaultColors(defaultColorConfig)
	local defaultColors = {}
	if defaultColorConfig <= 0 or defaultColorConfig > 63 then 
		return defaultColors
	end

	for i = 0, 5 do
        if 1 == bit.band(bit.rshift(defaultColorConfig, i), 0x01) then 
            local colorType = i + 1
    		table.insert(defaultColors, AnimalTypeConfig.convertIndexToColorType(colorType))
        end
    end
    return defaultColors
end

--为动物添加颜色、特效信息
function GameMapInitialLogic:initColorAndSpecialData(mainLogic, config)
	-- 限定了掉落染色宝宝的颜色
	mainLogic.dropCrystalStoneColors = config.dropCrystalStoneTypes

	local animalMap = config.animalMap
	local numberOfColors = config.numberOfColors

	for r = 1, #mainLogic.gameItemMap do
		if mainLogic.gameItemMap[r] == nil then
			mainLogic.gameItemMap[r] = {}
		end
		for c = 1, #mainLogic.gameItemMap[r] do
			local animalDef = animalMap[r][c]
			local item = mainLogic.gameItemMap[r][c]
			item:initByAnimalDef(animalDef)
			if item.ItemType == GameItemType.kAnimal 
				or item.ItemType == GameItemType.kCrystalStone 
				or item.ItemType == GameItemType.kTotems 
				or (item.ItemType == GameItemType.kBottleBlocker and item._encrypt.ItemColorType ~= AnimalTypeConfig.kRandom)
				or (item.ItemType == GameItemType.kMagicLamp and item._encrypt.ItemColorType ~= AnimalTypeConfig.kRandom)
				or item.ItemType == GameItemType.kRocket then
				local originColor = AnimalTypeConfig.getOriginColorValue(item._encrypt.ItemColorType)
				if mainLogic.colortypes[originColor] == nil then			--辅助统计颜色
					-- 当统计到的物体颜色数量超过了指定颜色数量后，其他的指定颜色不再被统计，并且不会自动生成其他颜色的物体
					if item._encrypt.ItemColorType ~= 0 and table.size(mainLogic.colortypes) < numberOfColors then
						mainLogic.colortypes[originColor] = true
					end
				end
			end
		end
	end
end

local PortalColorMax = 8
--生成传送门信息
function GameMapInitialLogic:initPortal(mainLogic, portals)
	local portalColorId = math.random(1, PortalColorMax)
	if portals then
		for k, portPairs in pairs(portals) do
			if portPairs then
				local x1 = 0
				local y1 = 0
				local x2 = 0
				local y2 = 0
				for k,v in pairs(portPairs) do
					if k == 1 then
						x1 = v[1] + 1
						y1 = v[2] + 1
					else
						x2 = v[1] + 1
						y2 = v[2] + 1
					end
				end
	
				mainLogic.boardmap[y1][x1]:addPassEnterInfo(y2, x2)
				mainLogic.boardmap[y1][x1]:setPassEnterColor(portalColorId)

				mainLogic.boardmap[y2][x2]:addPassExitInfo(y1, x1)
				mainLogic.boardmap[y2][x2]:setPassExitColor(portalColorId)

				portalColorId = portalColorId % PortalColorMax + 1
			end
		end
	end
end

--统计存在的颜色类型
function GameMapInitialLogic:initColorType(mainLogic, numColorsFromConfig, defaultColors)
	defaultColors = defaultColors or {}
	local colorTypeList = AnimalTypeConfig.colorTypeList

	if numColorsFromConfig then
		mainLogic.numberOfColors = numColorsFromConfig
	end

	if mainLogic.numberOfColors > 6 then mainLogic.numberOfColors = 6 end

	local finalColors = {}
	local colorsize = 0
	for i,v in ipairs(defaultColors) do
		if colorsize < mainLogic.numberOfColors then
			colorsize = colorsize + 1
			finalColors[v] = true
		end
	end
	for k,v in pairs(mainLogic.colortypes) do
		if not table.includes(defaultColors, k) and colorsize < mainLogic.numberOfColors then
			colorsize = colorsize + 1
			finalColors[k] = true
		end
	end
	-----------补足颜色------
	--printx( 1 , "    ---补足颜色---  colorsize = " , colorsize , "   mainLogic.numberOfColors = " , mainLogic.numberOfColors)
	if colorsize < mainLogic.numberOfColors then	--颜色数量不够，进行补充
		local ts = mainLogic.numberOfColors - colorsize
		repeat
			local tryIndex = mainLogic.randFactory:rand(1, #colorTypeList)
			local trycolor = colorTypeList[tryIndex]
			if finalColors[trycolor] == nil then
				finalColors[trycolor] = true
				ts = ts - 1
			end
		until ts <= 0
	end

	-- 需要按照colorIndex顺序存储，避免pairs(table)迭代器访问造成顺序不稳定
	for i, v in ipairs(colorTypeList) do
		if finalColors[v] then
			table.insert(mainLogic.mapColorList, v)
		end
	end
end

function GameMapInitialLogic:initItemTile(mainLogic, tileDef, animalDef)
	local item = GameItemData:create()
	item:initByConfig(tileDef)
	item:initByAnimalDef(animalDef)
	item:initBalloonConfig(mainLogic.balloonFrom)
	item:initAddMoveConfig(mainLogic.addMoveBase)
	item:initAddTimeConfig(mainLogic.addTime)
	return item
end

function GameMapInitialLogic:initBoardTile(mainLogic, tileDef)
	local board = GameBoardData:create()
	board:initByConfig(tileDef)
	board:setGameModeId(mainLogic.theGamePlayType)
	return board
end

function GameMapInitialLogic:initDigTileMap(mainLogic, config)
	printx( 1 , "  ===========  GameMapInitialLogic:initDigTileMap  ===========   " , mainLogic.theGamePlayType)
	if mainLogic.theGamePlayType == GameModeTypeId.DIG_MOVE_ID 
		or mainLogic.theGamePlayType == GameModeTypeId.DIG_TIME_ID 
		or mainLogic.theGamePlayType == GameModeTypeId.DIG_MOVE_ENDLESS_ID
		or mainLogic.theGamePlayType == GameModeTypeId.MAYDAY_ENDLESS_ID
		or mainLogic.theGamePlayType == GameModeTypeId.HALLOWEEN_ID
		or mainLogic.theGamePlayType == GameModeTypeId.WUKONG_DIG_ENDLESS_ID
		or mainLogic.theGamePlayType == GameModeTypeId.HEDGEHOG_DIG_ENDLESS_ID
		or mainLogic.theGamePlayType == GameModeTypeId.MOLE_WEEKLY_RACE_ID
		then
		local roadType = TileRoadShowType.kSnail
		if mainLogic.theGamePlayType == GameModeTypeId.HEDGEHOG_DIG_ENDLESS_ID then
			roadType = TileRoadShowType.kHedgehog
		end
		local tileMap = config.digExtendRouteData
		mainLogic.digItemMap = {}
		mainLogic.digBoardMap = {}
		local animalMap = config.animalMap
		local normalTileRow = 9
		for r = 1, #config.digTileMap do
			local realR = r + normalTileRow
			if mainLogic.gameItemMap[realR] == nil then mainLogic.gameItemMap[realR] = {} end
			if mainLogic.boardmap[realR] == nil then mainLogic.boardmap[realR] = {} end
			if mainLogic.digItemMap[r] == nil then mainLogic.digItemMap[r] = {} end
			if mainLogic.digBoardMap[r] == nil then mainLogic.digBoardMap[r] = {} end


			for c = 1, #config.digTileMap[r] do
				local tileDef = config.digTileMap[r][c]
				local animalDef = animalMap[realR][c]
				local item = GameMapInitialLogic:initItemTile(mainLogic, tileDef, animalDef)
				mainLogic.gameItemMap[realR][c] = item
				mainLogic.digItemMap[r][c] = item

				local board = GameMapInitialLogic:initBoardTile(mainLogic, tileDef)
				if board.isMoveTile then
					board:initScrollTileMoveByConfig(config.tileMoveCfg, normalTileRow)
				end
				mainLogic.boardmap[realR][c] = board
				mainLogic.digBoardMap[r][c] = board

				if tileMap and tileMap[r] and tileMap[r][c] then
					local tileDef = tileMap[r][c]
					board:initSnailRoadDataByConfig(tileDef, roadType)
					item:initSnailRoadType(board)
				end
			end
		end
	elseif mainLogic.theGamePlayType == GameModeTypeId.OLYMPIC_HORIZONTAL_ENDLESS_ID or
		mainLogic.theGamePlayType == GameModeTypeId.SPRING_HORIZONTAL_ENDLESS_ID then
		mainLogic.digItemMap = {}
		mainLogic.digBoardMap = {}
		local animalMap = config.animalMap
		local normalTileCol = 9
		for r = 1, #config.digTileMap do
			if mainLogic.gameItemMap[r] == nil then mainLogic.gameItemMap[r] = {} end
			if mainLogic.boardmap[r] == nil then mainLogic.boardmap[r] = {} end
			if mainLogic.digItemMap[r] == nil then mainLogic.digItemMap[r] = {} end
			if mainLogic.digBoardMap[r] == nil then mainLogic.digBoardMap[r] = {} end

			for c = 1, #config.digTileMap[r] do
				local realC = c + normalTileCol
				local tileDef = config.digTileMap[r][c]
				local animalDef = animalMap[r][realC]
				local item = GameMapInitialLogic:initItemTile(mainLogic, tileDef, animalDef)
				mainLogic.gameItemMap[r][realC] = item
				mainLogic.digItemMap[r][c] = item

				local board = GameMapInitialLogic:initBoardTile(mainLogic, tileDef)
				mainLogic.boardmap[r][realC] = board
				mainLogic.digBoardMap[r][c] = board
			end
		end
	end
end

--开始随机生成颜色
function GameMapInitialLogic:calculateItemColors(mainLogic, config)
	--挖地模式下，需要将屏幕之外的地格也计算在内
	if mainLogic.theGamePlayType == GameModeTypeId.DIG_MOVE_ID 
		or mainLogic.theGamePlayType == GameModeTypeId.DIG_TIME_ID 
		or mainLogic.theGamePlayType == GameModeTypeId.DIG_MOVE_ENDLESS_ID
		or mainLogic.theGamePlayType == GameModeTypeId.MAYDAY_ENDLESS_ID
		or mainLogic.theGamePlayType == GameModeTypeId.HALLOWEEN_ID
		or mainLogic.theGamePlayType == GameModeTypeId.WUKONG_DIG_ENDLESS_ID
		or mainLogic.theGamePlayType == GameModeTypeId.HEDGEHOG_DIG_ENDLESS_ID
		or mainLogic.theGamePlayType == GameModeTypeId.MOLE_WEEKLY_RACE_ID
		then
		local normalTileRow = 9
		self:_calculateItemColors(mainLogic, config.animalMap, normalTileRow)

		for r = 1, #mainLogic.gameItemMap do
			if r > normalTileRow then
				mainLogic.gameItemMap[r] = nil
				mainLogic.boardmap[r] = nil
			end
		end
		mainLogic.swapHelpMap = nil
	elseif mainLogic.theGamePlayType == GameModeTypeId.OLYMPIC_HORIZONTAL_ENDLESS_ID or 
		mainLogic.theGamePlayType == GameModeTypeId.SPRING_HORIZONTAL_ENDLESS_ID then
		local normalTileCol = 9
		self:_calculateItemColors(mainLogic, config.animalMap, nil, normalTileCol)
		for r = 1, #mainLogic.gameItemMap do
			for c = 1, #mainLogic.gameItemMap[r] do
				if c > normalTileCol then
					mainLogic.gameItemMap[r][c] = nil
					mainLogic.boardmap[r][c] = nil
				end
			end
		end
		mainLogic.swapHelpMap = nil
	else
		self:_calculateItemColors(mainLogic, config.animalMap)
	end
end

function GameMapInitialLogic:_calculateItemColors(mainLogic, animalMap, possibleMoveRowLimit, possibleMoveColLimit)
	local function resetColors()
		for r = 1, #mainLogic.gameItemMap do
			for c = 1, #mainLogic.gameItemMap[r] do
				if mainLogic.gameItemMap[r][c]:isColorful() 
					and not mainLogic.gameItemMap[r][c].isLockColorOnInit
					and mainLogic.gameItemMap[r][c].ItemType ~= GameItemType.kMagicLamp
					and mainLogic.gameItemMap[r][c].ItemType ~= GameItemType.kWukong
					and mainLogic.gameItemMap[r][c].ItemType ~= GameItemType.kDrip
					and mainLogic.gameItemMap[r][c].ItemType ~= GameItemType.kBottleBlocker then
					mainLogic.gameItemMap[r][c]._encrypt.ItemColorType = AnimalTypeConfig.getType(animalMap[r][c])
				end
			end
		end
	end

	local function randomSetColors()
		for r = 1, #mainLogic.gameItemMap do
			for c = 1, #mainLogic.gameItemMap[r] do
				local success = self:randomSetColor(mainLogic, r, c)
				if not success then
					return false
				end 
			end
		end
		return true
	end

	resetColors()
	local needRandomItemNum = 0
	for r = 1, #mainLogic.gameItemMap do
		for c = 1, #mainLogic.gameItemMap[r] do
			if self:isItemNeedRandomColor(mainLogic, r, c) then
				needRandomItemNum = needRandomItemNum + 1
			end
		end
	end

	if needRandomItemNum > 0 then
		for i = 1, 10000 do
			-- ensure no match
			resetColors()	
			local success = randomSetColors()
			-- ensure possbile moves generating match 
			if success and not RefreshItemLogic:checkNeedRefresh(mainLogic, possibleMoveRowLimit, possibleMoveColLimit) then
				break
			end
		end
	end
end

--判断item的block状态
function GameMapInitialLogic:checkItemBlock(mainLogic)
	for r = 1, #mainLogic.gameItemMap do
		for c = 1, #mainLogic.gameItemMap[r] do
			mainLogic:checkItemBlock(r,c)
		end
	end
	mainLogic:updateFallingAndBlockStatus()
end

--记录金豆荚生成口
function GameMapInitialLogic:initIngredientProducer(mainLogic)
	mainLogic.ingredientsProductDropList = {}
	for r = 1, #mainLogic.boardmap do
		for c = 1, #mainLogic.boardmap[r] do
			if mainLogic.boardmap[r][c].isProducer == true then
				if table.exist(mainLogic.boardmap[r][c].theGameBoardFallType, TileConst.kCannon)
					or table.exist(mainLogic.boardmap[r][c].theGameBoardFallType, TileConst.kCannonIngredient) 
					then
					table.insert(mainLogic.ingredientsProductDropList, mainLogic.boardmap[r][c])
				end
			end
		end
	end
end

function GameMapInitialLogic:randomColorForPosition(mainLogic, r, c)
	local color = 0
	local counter = 0
	while true do 
		color = mainLogic:randomColor()
		local ret1 = mainLogic:checkMatchQuick(r, c, color)
		local ret2 = ColorFilterLogic:checkColorMatch(r, c, color)
		if not ret1 and not ret2 then break end
		color = 0 -- reset value
		counter = counter + 1
		if counter > 100 then break end
	end
	return color
end

function GameMapInitialLogic:isItemNeedRandomColor(mainLogic, r, c)
	if mainLogic.gameItemMap[r][c] ~= nil then
		if mainLogic.gameItemMap[r][c]:isColorful() and not mainLogic.gameItemMap[r][c].isLockColorOnInit then 			--可以随机颜色的物体
			if mainLogic.gameItemMap[r][c]._encrypt.ItemColorType == AnimalTypeConfig.kRandom 			--随机类型
				and mainLogic.gameItemMap[r][c].ItemSpecialType ~= AnimalTypeConfig.kColor then	
					return true
			end
		end
	end
	return false
end

--尝试为一个物体随机一个颜色
function GameMapInitialLogic:randomSetColor(mainLogic, r, c)
	local success = true
	if self:isItemNeedRandomColor(mainLogic, r, c) then
		local color = self:randomColorForPosition(mainLogic, r, c)
		if color and AnimalTypeConfig.isColorTypeValid(color) then
			mainLogic.gameItemMap[r][c]._encrypt.ItemColorType = color
		else
			success = false
		end
	end
	return success
end

function GameMapInitialLogic:getPossibleColorsForItem(mainLogic, r, c, initColors, notCareQuickMacth)
	local specifyColors = false 
	local result = {}
	local colors = mainLogic.mapColorList
	if initColors and #initColors > 0 then
		colors = initColors
		specifyColors = true
	end
	if notCareQuickMacth then
	 	for k, v in pairs(colors) do 
			if not ColorFilterLogic:checkColorMatch(r, c, v) then
				table.insert(result, v)
			end
		end
	else
		for k, v in pairs(colors) do 
			if not mainLogic:checkMatchQuick(r, c, v) and not ColorFilterLogic:checkColorMatch(r, c, v) then
				table.insert(result, v)
			end
		end
	end
	return result, specifyColors
end

local _magicLampColorPool = {}
local function initMagicLampColorPool(mainLogic)
	local tmp = {}
	_magicLampColorPool = {}
	for k, v in pairs(mainLogic.mapColorList) do 
		table.insert(tmp, v)
	end
	local tmp2 = {}
	while #tmp > 0 do
		local selector = mainLogic.randFactory:rand(1, #tmp)
		table.insert(tmp2, tmp[selector])
		table.remove(tmp, selector)
	end
	for i=1, 2 do
		for k, v in pairs(tmp2) do
			table.insert(_magicLampColorPool, v)
		end
	end
end
function GameMapInitialLogic:getColorForMagicLamp(mainLogic)
	if #_magicLampColorPool == 0 then
		initMagicLampColorPool(mainLogic)
	end

	local size = #_magicLampColorPool
	local color = _magicLampColorPool[size]
	_magicLampColorPool[size] = nil
	return color
end

function GameMapInitialLogic:initMagicLamp(mainLogic)
	local localMagicLampItems = {}

	local function randomizeTable(table)
		local size = #table
		local function swapInTable(table, i, j)
			local t = table[i]
			table[i] = table[j]
			table[j] = t
		end
		for i = 1, size do
			swapInTable(table, 1, mainLogic.randFactory:rand(1, size))
		end
	end

	for r = 1, #mainLogic.gameItemMap do 
		for c = 1, #mainLogic.gameItemMap[r] do
			local item = mainLogic.gameItemMap[r][c]
			if item then
				if item.ItemType == GameItemType.kMagicLamp and item._encrypt.ItemColorType == AnimalTypeConfig.kRandom then
					local possibleColors = GameMapInitialLogic:getPossibleColorsForItem(mainLogic, r, c)
					randomizeTable(possibleColors)
					local queueItem = {item = item, possibleColors = possibleColors, currentIndex = 1, r = r, c = c}
					table.insert(localMagicLampItems, queueItem)
				end
			end
		end
	end

	if #localMagicLampItems > #mainLogic.mapColorList * 2 then
		assert(false, 'magic lamp config error')
		return
	end

	if #localMagicLampItems == 0 then
		return 
	end

	local function sort(v1, v2)
		return #v1.possibleColors < #v2.possibleColors
	end

	-- possibleColor越少，处理优先级越高
	table.sort(localMagicLampItems, sort)

	local counter = 0
	local maxTimes = 1
	for k, v in pairs(localMagicLampItems) do
		maxTimes = maxTimes * #v.possibleColors
	end

	local function getNextCombination()
		
		counter = counter + 1
		if counter > maxTimes then
			return nil
		end

		local index = 1
		local combination = {}
		for k, v in pairs(localMagicLampItems) do
			table.insert(combination, v.possibleColors[v.currentIndex])
		end
		localMagicLampItems[index].currentIndex = localMagicLampItems[index].currentIndex + 1 -- current item++
		while localMagicLampItems[index].currentIndex > #localMagicLampItems[index].possibleColors do -- indent
			local next = localMagicLampItems[index + 1]
			if next then
				next.currentIndex = next.currentIndex + 1
				localMagicLampItems[index].currentIndex = 1
				index = index + 1
			else
				localMagicLampItems[index].currentIndex = localMagicLampItems[index].currentIndex - 1 --恢复
			end
		end
		return combination
	end

	local function isLegal(combination)
		local colorStats = {}
		for k, v in pairs(combination) do 
			if not colorStats[v] then
				colorStats[v] = 0
			end
			colorStats[v] = colorStats[v] + 1
		end
		for k, v in pairs(colorStats) do 
			if v > 2 then 
				return false
			end
		end
		return true
	end

	local function hasMatch(combination)
		local hasMatch = false
		for i = 1, #combination do
			localMagicLampItems[i].item._encrypt.ItemColorType = combination[i]
		end
		local hasMatch = false
		for k, v in pairs(localMagicLampItems) do
			if mainLogic:checkMatchQuick(v.r, v.c, v.item._encrypt.ItemColorType) or 
				ColorFilterLogic:checkColorMatch(v.r, v.c, v.item._encrypt.ItemColorType) then
				hasMatch = true
				break
			end
		end
		return hasMatch
	end

	local result = getNextCombination()
	while result do
		if not isLegal(result) or hasMatch(result) then
			result = getNextCombination()
		else
			break
		end
	end
end

-------------------------------------------------

function GameMapInitialLogic:initWukong(mainLogic)
	for r = 1, #mainLogic.gameItemMap do 
		for c = 1, #mainLogic.gameItemMap[r] do
			local item = mainLogic.gameItemMap[r][c]
			if item then
				if item.ItemType == GameItemType.kWukong then
					--item._encrypt.ItemColorType = AnimalTypeConfig.kBlue
					item._encrypt.ItemColorType = GameExtandPlayLogic:getRandomColorByDefaultLogic(mainLogic , r , c)
				end
			end
		end
	end
end

function GameMapInitialLogic:__initDrip(item)
	if item then
		if item.ItemType == GameItemType.kDrip then
			item._encrypt.ItemColorType = AnimalTypeConfig.kDrip
			--hasDrip = true
		end
	end
end

function GameMapInitialLogic:initDrip(mainLogic)
	local hasDrip = false

	for r = 1, #mainLogic.gameItemMap do 
		for c = 1, #mainLogic.gameItemMap[r] do
			local item = mainLogic.gameItemMap[r][c]
			self:__initDrip(item)
		end
	end

	--[[
	local num = tonumber( mainLogic.level ) % 2
	if num == 0 then
		_G.test_DripMode = 2
	else
		_G.test_DripMode = 2
	end

	]]

	if MaintenanceManager:getInstance():isEnabled("UseOldDripLogic") then
		_G.test_DripMode = 1
	else
		_G.test_DripMode = 2
	end

end


function GameMapInitialLogic:initBottleBlocker(mainLogic)
	for r = 1, #mainLogic.gameItemMap do 
		for c = 1, #mainLogic.gameItemMap[r] do
			local item = mainLogic.gameItemMap[r][c]
			if item then
				if item.ItemType == GameItemType.kBottleBlocker then
					if item._encrypt.ItemColorType == AnimalTypeConfig.kRandom then
						local color = GameExtandPlayLogic:randomBottleBlockerColor(mainLogic, r, c)

						if not color then
							color = AnimalTypeConfig.convertIndexToColorType( mainLogic.randFactory:rand(1,6) )
						end
						
						item._encrypt.ItemColorType = color
					end
				end
			end
		end
	end
end

function GameMapInitialLogic:__initCrystalStone(item , mainLogic)
	if item and item.ItemType == GameItemType.kCrystalStone then
		local hasColor = AnimalTypeConfig.isColorTypeValid(item._encrypt.ItemColorType)
		if not hasColor then
			item._encrypt.ItemColorType = mainLogic:randomColor()
		end
	end
end

function GameMapInitialLogic:initCrystalStone(mainLogic)
	for r = 1, #mainLogic.gameItemMap do 
		for c = 1, #mainLogic.gameItemMap[r] do
			local item = mainLogic.gameItemMap[r][c]
			self:__initCrystalStone(item , mainLogic)
		end
	end
end

----------------------------------
--初始化传送带
----------------------------------
function GameMapInitialLogic:initTransmission(mainLogic, config)
	if not config.trans or #config.trans == 0 then return end 
	for k, v in pairs(config.trans) do 


		local transItem = BaseTransmission:create(tostring(v), config.transType):getHeadTrans()
		while (transItem ~= nil) do
			local start = transItem:getStart()
			local length = transItem:getTransLength()
			local direction = transItem:getDirection()

			local dx, dy = 0, 0
			if direction == TransmissionDirection.kLeft then
				dy = -1
			elseif direction == TransmissionDirection.kRight then 
				dy = 1
			elseif direction == TransmissionDirection.kUp then
				dx = -1
			else
				dx = 1
			end 
			if length == 1 then 
				local type_trans = transItem:getTransTypeByIndex(1)
				local link = transItem:getLinkPositionByIndex(1)
				local color = {}
				color.startColor = transItem:getStartType()
				color.endColor = transItem:getEndType()
				if start.x <= 9 then 
					mainLogic.boardmap[start.x][start.y]:setTransmissionConfig(type_trans, direction, color, link)
				else
					mainLogic.digBoardMap[start.x-9][start.y]:setTransmissionConfig(type_trans, direction, color, link)
				end
			else
				for k = 1, length do 
					local type_trans = transItem:getTransTypeByIndex(k)
					local link = transItem:getLinkPositionByIndex(k)
					local color = 0				
					if not transItem:hasCercle() then
						if transItem:isHeadTrans() and k == 1 then
							color = transItem:getStartType()
						elseif transItem:isEndTrans() and k == length then
							color = transItem:getHeadTrans():getEndType()
						end
					end
					if _G.isLocalDevelopMode then printx(0, 'setting:', 'X', start.x + dx * (k-1), 'Y', start.y + dy * (k-1),'TYPE', type_trans, 'DIRECTION', direction, 'COLOR', color, 'LINK', link.x, link.y) end
					if start.x <=9 then 
						mainLogic.boardmap[start.x + dx * (k-1)][start.y + dy * (k-1)]:setTransmissionConfig(type_trans, direction, color, link)
					else
						mainLogic.digBoardMap[start.x-9 + dx * (k-1)][start.y + dy * (k-1)]:setTransmissionConfig(type_trans, direction, color, link)
					end
				end
			end
			transItem = transItem:getNextTrans()
		end
	end
end

----------------------------------
--初始化礼包
----------------------------------
function GameMapInitialLogic:initGift(mainLogic, config)
	if (config.gift) then
		for k,v in pairs(config.gift) do
			local as3key = splite(k,"_")
			local row = tonumber(as3key[1])  + 1
			local col = tonumber(as3key[2])  + 1

			local gameItem
			if row <= 9 then 
				gameItem = mainLogic.gameItemMap[row][col] 
			else
				gameItem = mainLogic.digItemMap[row - 9][col] 
			end
			if (gameItem and gameItem.ItemType == GameItemType.kNewGift) then
				gameItem.dropProps = tostring(v)
			end
		end
	end
end

----------------------------------
-- 初始化鱿鱼
-- "squidConfig":{"2_6":"87_2","6_5":"100001_3","3_2":"201_36","7_2":"7_48"}
----------------------------------
function GameMapInitialLogic:initSquid(mainLogic, config)
	if (config.squidConfig) then
		for k, v in pairs(config.squidConfig) do
			local as3key = splite(k, "_")
			local row = tonumber(as3key[1]) + 1
			local col = tonumber(as3key[2]) + 1

			local gameItem
			if row <= 9 then 
				gameItem = mainLogic.gameItemMap[row][col] 
			else
				gameItem = mainLogic.digItemMap[row - 9][col] 
			end
			if (gameItem and gameItem.ItemType == GameItemType.kSquid) then
				local targetData = splite(v, "_")
				local targetType = tonumber(targetData[1])
				local targetAmount = tonumber(targetData[2])
				if targetType < 100000 then targetType = targetType + 1 end
				gameItem.squidTargetType = targetType
				gameItem.squidTargetNeeded = targetAmount
			end
		end
	end
end

----------------------------------
-- 初始化万生
-- "wanShengNormalConfig":{"num":1,"attr":"","mType":2}
-- "wanShengConfig":{"5_5":{"num":1,"attr":"","mType":2}
-- "wanShengDropConfig":{"5_5":{"num":1,"attr":"","mType":2}
----------------------------------
function GameMapInitialLogic:initWanSheng(mainLogic, config)
    local PosList = {}
    local digPosList = {}
    local backPosList = {}

    if mainLogic.gameItemMap then
        for r = 1, #mainLogic.gameItemMap do
 		    for c = 1, #mainLogic.gameItemMap[r] do
 			    local checkItem = mainLogic.gameItemMap[r][c]
 			    if checkItem and checkItem.ItemType == GameItemType.kWanSheng then
 				    table.insert( PosList, r.."_"..c )
 			    end
 		    end
 	    end
    end

    if mainLogic.digItemMap then
        for r = 1, #mainLogic.digItemMap do
 		    for c = 1, #mainLogic.digItemMap[r] do
 			    local checkItem = mainLogic.digItemMap[r][c]
 			    if checkItem and checkItem.ItemType == GameItemType.kWanSheng then
 				    table.insert( digPosList, r.."_"..c )
 			    end
 		    end
 	    end
    end

    if mainLogic.backItemMap then
        for r = 1, #mainLogic.backItemMap do
 		    for i, v in pairs(mainLogic.backItemMap[r]) do
 			    local checkItem = mainLogic.backItemMap[r][i]
 			    if checkItem and checkItem.ItemType == GameItemType.kWanSheng then
 				    table.insert( backPosList, r.."_"..i )
 			    end
 		    end
 	    end
    end


    local function InitConfig( PosList, ItemMap, bDigMap )
        if #PosList == 0 then return end

        if bDigMap == nil then bDigMap = false end

        for i,v in ipairs(PosList) do
            local as3key = splite(v, "_")
		    local row = tonumber(as3key[1])
		    local col = tonumber(as3key[2])
            local gameItem = ItemMap[row][col] 

            local newKey = (row-1).."_"..(col-1)
            if bDigMap then
                newKey = (row+9-1).."_"..(col-1)
            end

            if config.wanShengConfig and config.wanShengConfig[newKey] 
                and config.wanShengConfig[newKey].num ~= 0 
                and config.wanShengConfig[newKey].mType ~= 0 then
                gameItem.wanShengConfig = config.wanShengConfig[newKey]
            else
                gameItem.wanShengConfig = config.wanShengNormalConfig

                if _G.isLocalDevelopMode then
                    if config.wanShengNormalConfig.num == 0 
                        or config.wanShengNormalConfig.mType == 0 then 
                        CommonTip:showTip("此关 万生默认配置出错~ ")
                    end
                end
            end
        end
    end

    InitConfig( PosList, mainLogic.gameItemMap )
    InitConfig( digPosList, mainLogic.digItemMap, true )
    InitConfig( backPosList, mainLogic.backItemMap )
end

----------------------------------
-- 道具云块
----------------------------------
function GameMapInitialLogic:initRandomProps(mainLogic, config)
	if config.gameMode ~= GameModeType.MAYDAY_ENDLESS then
		return 
	end

	local tempDailyDropPropCout = 0
	local tempDailyDropPropCout2 = 0
	-- 找到地图中全部可能的道具云块位置
	-- if _G.isLocalDevelopMode then printx(0, "gameItemMap",#mainLogic.gameItemMap,#mainLogic.digItemMap) end
	-- if _G.isLocalDevelopMode then printx(0, "boardmap",#mainLogic.boardmap,#mainLogic.digBoardMap) end
	local gameItemMap = mainLogic.gameItemMap
	local digItemMap = mainLogic.digItemMap
	local randomProp1MaybePosition = {}
	local randomProp2MaybePosition = {}

	local function createItem(position, propId, needGuide)
		-- 判断该道具是否超过今日上限
		local canDrop = false
		-- if _G.isLocalDevelopMode then printx(0, "?????????????",propId,GamePlayContext:getInstance().weeklyData.dailyDropPropCount2,tempDailyDropPropCout2,SeasonWeeklyRaceConfig:getInstance().maxDailyDropPropsCountJingLiPing) end
		if (tostring(propId) == "10012") then
			if _G.editorMode 
				or (GamePlayContext:getInstance().weeklyData.dailyDropPropCount2 + tempDailyDropPropCout2) < SeasonWeeklyRaceConfig:getInstance().maxDailyDropPropsCountJingLiPing then
				canDrop = true
				tempDailyDropPropCout2 = tempDailyDropPropCout2 + 1
			end
		else
			if _G.editorMode
				or (GamePlayContext:getInstance().weeklyData.dailyDropPropCount + tempDailyDropPropCout) < SeasonWeeklyRaceConfig:getInstance().maxDailyDropPropsCount then
				canDrop = true
				tempDailyDropPropCout = tempDailyDropPropCout + 1
			end
		end

		if (canDrop and position) then
			local item = nil 
			local board = nil
			if (position.x <= 9 ) then
				item = mainLogic.gameItemMap[position.x][position.y]
				board = mainLogic.boardmap[position.x][position.y]
			else
				item = mainLogic.digItemMap[position.x - 9][position.y]
				board = mainLogic.digBoardMap[position.x - 9][position.y]
			end
			-- 先清空原有属性
			item:cleanAnimalLikeData()
			-- board:resetDatas()

			item.ItemType = GameItemType.kRandomProp
			item.isEmpty = false
			item.randomPropDropId = tonumber(propId)
			item.randomPropLevel = 1
			if needGuide then 
				item.randomPropGuide = true
			end
			if (position.x <= 9 ) then
				mainLogic:checkItemBlock(position.x,position.y)
			end
		end
	end

	local function findMaybePositions(itemMap,offsetRow)
		if itemMap then 
			for r=1,#itemMap do
				for c=1,9 do
					if (itemMap[r][c].randomPropType == RandomPropType.kRandomProp1) then 
						-- if _G.isLocalDevelopMode then printx(0, "randomProp1 ",r,c) end
						table.insert(randomProp1MaybePosition,ccp(r + offsetRow,c))
					elseif(itemMap[r][c].randomPropType == RandomPropType.kRandomProp2) then 
						-- if _G.isLocalDevelopMode then printx(0, "randomProp2 ",r,c) end
						table.insert(randomProp2MaybePosition,ccp(r + offsetRow,c))
					end
				end
			end
		end
	end

	findMaybePositions(gameItemMap,0)
	findMaybePositions(digItemMap,9)
	
	-- "randomPropData":{"185":[{"k":"901","v":2}],"1860":[],"1850":[],"186":[{"k":"902","v":1}]},
	if _G.isLocalDevelopMode then printx(0, "initRandomProps",table.tostring(config.randomPropData)) end
	local randomProp1Props = {}
	local randomProp2Props = {}
	if (config.randomPropData) then
		for propTileConstStringForm,dropPropAndCountTable in pairs(config.randomPropData) do
			-- if _G.isLocalDevelopMode then printx(0, propTileConstStringForm,dropPropAndCountTable) end

			if (tonumber(propTileConstStringForm)+1 == TileConst.kRandomProp1) then
				for _,keyAndCount in ipairs(dropPropAndCountTable) do
					-- if _G.isLocalDevelopMode then printx(0, ".... ",_,table.tostring(keyAndCount)) end
					for i=1,keyAndCount["v"] do
						table.insert(randomProp1Props,keyAndCount["k"])
					end
				end
			elseif (tonumber(propTileConstStringForm)+1 == TileConst.kRandomProp2) then
				for _,keyAndCount in ipairs(dropPropAndCountTable) do
					-- if _G.isLocalDevelopMode then printx(0, ".... ",_,table.tostring(keyAndCount)) end
					for i=1,keyAndCount["v"] do
						table.insert(randomProp2Props,keyAndCount["k"])
					end
				end
			end
		end
	end

	-- if _G.isLocalDevelopMode then printx(0, "final1 ",table.tostring(randomProp1Props)) end
	-- if _G.isLocalDevelopMode then printx(0, "final2 ",table.tostring(randomProp2Props)) end


	randomProp1MaybePosition = table.randomOrder(randomProp1MaybePosition,mainLogic)
	randomProp2MaybePosition = table.randomOrder(randomProp2MaybePosition,mainLogic)
	-- 从可能的道具数目中填充到随机位置
	for i,propId in ipairs(randomProp1Props) do
		createItem(randomProp1MaybePosition[i], randomProp1Props[i])
	end

	for i,propId in ipairs(randomProp2Props) do
		createItem(randomProp2MaybePosition[i], randomProp2Props[i], true)
	end

	FallingItemLogic:preUpdateHelpMap(mainLogic)
	-- debug.debug()
end

