SeaOrderMode = class(OrderMode)

SeaAnimalType = 
{
	kPenguin 	= 1,
	kPenguin_H 	= 2,
	kSeal 		= 3,
	kSeal_V 	= 4,
	kSeaBear 	= 5,

	kMistletoe = 6,	--[2016圣诞活动] 槲寄生 这是一种植物 1x1
	kScarf_H = 7, 		--[2016圣诞活动] 围巾   这是一种日常用品 3x1
	kScarf_V = 8, 		--[2016圣诞活动] 围巾   这是一种日常用品
	kElk = 9, 		--[2016圣诞活动] 麋鹿 	这是一种动物 2x2
	kSea_3_3 = 10,

	penguin_flag = 1,
	seal_flag = 2,
	bear_flag = 3,
	mistletoe_flag = 4,
	scarf_flag = 5,
	elk_flag = 6,
	sea_3_3_flag = 7,
}

SeaAnimalFlag2Types = {
	[SeaAnimalType.penguin_flag]	= {SeaAnimalType.kPenguin, SeaAnimalType.kPenguin_H},
	[SeaAnimalType.seal_flag]		= {SeaAnimalType.kSeal, SeaAnimalType.kSeal_V},
	[SeaAnimalType.bear_flag]		= {SeaAnimalType.kSeaBear},
	[SeaAnimalType.mistletoe_flag]	= {SeaAnimalType.kMistletoe},
	[SeaAnimalType.scarf_flag]		= {SeaAnimalType.kScarf_H, SeaAnimalType.kScarf_V},
	[SeaAnimalType.elk_flag]		= {SeaAnimalType.kElk},
	[SeaAnimalType.sea_3_3_flag]	= {SeaAnimalType.kSea_3_3},
}

SeaAnimalConfig = {
	[SeaAnimalType.kPenguin]    = {area = {2, 1}},
    [SeaAnimalType.kPenguin_H]  = {area = {1, 2}},
    [SeaAnimalType.kSeal]       = {area = {2, 3}},
    [SeaAnimalType.kSeal_V]     = {area = {3, 2}},
    [SeaAnimalType.kSeaBear]   	= {area = {3, 3}},
    [SeaAnimalType.kMistletoe]  = {area = {1, 1}},
    [SeaAnimalType.kScarf_H]    = {area = {1, 2}},
    [SeaAnimalType.kScarf_V]    = {area = {2, 1}},
    [SeaAnimalType.kElk]        = {area = {2, 2}},
    [SeaAnimalType.kSea_3_3]    = {area = {3, 3}},
}

local function isFlagBitSet(flag, bitIndex)
    if bitIndex < 1 then bitIndex = 1 end
    local mask = math.pow(2, bitIndex - 1) -- e.g.: mask: 0010

    local bit = require("bit")
    return mask == bit.band(flag, mask)
end


function SeaOrderMode:selectAndInsertAnimaByRandom(possiblePosList , seaAnimalType , occupiedList)
	if #possiblePosList > 0 then
		local index = self.mainLogic.randFactory:rand(1, #possiblePosList)
		local data = self:creatSeaAnimalStaticData( seaAnimalType , possiblePosList[index].y , possiblePosList[index].x )
		table.insert(occupiedList, data)
	end
end

function SeaOrderMode:creatSeaAnimalStaticData(seaAnimalType , r , c)
	local data = {}
	data.x = c
	data.y = r
	data.type = seaAnimalType

	local config = SeaAnimalConfig[seaAnimalType]
	if config then
		data.xEnd = data.x + config.area[2] - 1
		data.yEnd = data.y + config.area[1] - 1
	end
	return data
end

function SeaOrderMode:initModeSpecial(config)
	
	self.config = config
	--self.allSeaAnimals = {}
	OrderMode.initModeSpecial(self, config)
	local _tileMap = config.tileMap
	  for r = 1, #_tileMap do
	    if self.mainLogic.boardmap[r] == nil then self.mainLogic.boardmap[r] = {} end        --地形
	    for c = 1, #_tileMap[r] do
	      local tileDef = _tileMap[r][c]
	      self.mainLogic.boardmap[r][c]:initLightUp(tileDef)              
	    end
	  end

	local allSeaAnimals = self:buildSeaAnimalMap(
						config.seaAnimalMap , config.seaFlagMap , self.mainLogic.boardmap ,
						config.backSeaAnimalMap , config.backSeaFlagMap , self.mainLogic.backBoardMap)
	self.allSeaAnimals = allSeaAnimals
	--四周年
    local seaOrder = nil
    for _, v in pairs(self.mainLogic.theOrderList) do
        if v.key1 == 6 and v.key2 == 4 then
            seaOrder = v
            break
        end
    end 
    for i = #self.mainLogic.theOrderList, 1, -1 do
        local order = self.mainLogic.theOrderList[i]
        if order.key1 == 6 and (order.key2 == 5 or order.key2 == 6 or order.key2 == 7 or order.key2 == 8 or order.key2 == 9 ) then
            if seaOrder then 
                if order.key2 == 7 then
                    seaOrder.v1 = seaOrder.v1 + order.v1 * self.mainLogic.SunmerFish3x3GetNum
                else
            	    seaOrder.v1 = seaOrder.v1 + order.v1
                end
            	table.remove(self.mainLogic.theOrderList, i)
            else
            	order.key2 = 4
            	seaOrder = order 
            end 
        end
    end
end

function SeaOrderMode:saveDataForRevert(saveRevertData)
	saveRevertData.allSeaAnimals = table.clone(self.allSeaAnimals)
	--saveRevertData.allSeaAnimals_back = table.clone(self.allSeaAnimals_back)
	OrderMode.saveDataForRevert(self, saveRevertData)
end

function SeaOrderMode:revertDataFromBackProp()
	self.allSeaAnimals = self.mainLogic.saveRevertData.allSeaAnimals
	--self.allSeaAnimals_back = self.mainLogic.saveRevertData.allSeaAnimals_back
	--if _G.isLocalDevelopMode then printx(0, 'self.allSeaAnimals', table.tostring(self.allSeaAnimals)) end
	OrderMode.revertDataFromBackProp(self)
end

function SeaOrderMode:revertUIFromBackProp()
	OrderMode.revertUIFromBackProp(self)
end

function SeaOrderMode:checkAllLightCount()
  local mainLogic = self.mainLogic
	local countsum = 0
	for r = 1, #mainLogic.gameItemMap do
		for c = 1, #mainLogic.gameItemMap[r] do
			local board1 = mainLogic.boardmap[r][c]
			if board1.isUsed == true then
				countsum = countsum + board1.iceLevel
			end
		end
	end

	if mainLogic.backBoardMap then
	    for r = 1, 9 do
		    for c = 1, 9 do
		        if mainLogic.backBoardMap[r] then
			        local board2 = mainLogic.backBoardMap[r][c]
			        if board2 and board2.isUsed == true then
			            countsum = countsum + board2.iceLevel
			        end
		        end
		    end
	    end
	end
	--if _G.isLocalDevelopMode then printx(0, "checkAllIngredientCount", countsum) end
	--debug.debug()
	return countsum;
end

function SeaOrderMode:countConfigged(mapdata)
	local ret = {}
	for k, v in pairs(SeaAnimalFlag2Types) do
		ret[k] = 0
	end
	for rowIndex, row in pairs(mapdata) do 
		for colIndex, value in pairs(row) do
			for flag, seaAnimalTypes in pairs(SeaAnimalFlag2Types) do
				for k, seaAnimalType in pairs(seaAnimalTypes) do
					if value == seaAnimalType then
						ret[flag] = ret[flag] + 1
					end
				end
			end
		end
	end
	return ret
end

function SeaOrderMode:buildBySeaAnimalMap(mapdata , isBackSide)
	local animals = {}
	for rowIndex, row in pairs(mapdata) do 
		for colIndex, value in pairs(row) do
			local animal = self:creatSeaAnimalStaticData(value,rowIndex,colIndex)
			table.insert(animals,animal)
		end
	end
	return animals
end

function SeaOrderMode:addDataByTwoDirection( nPosList , vPosList , nType , vType , occupiedTable)
	if #nPosList > 0 or #vPosList > 0 then
		if #nPosList > 0 and #vPosList > 0 then
			if self.mainLogic.randFactory:rand(0, 1) > 0 then
				self:selectAndInsertAnimaByRandom( nPosList , nType , occupiedTable)
			else
				self:selectAndInsertAnimaByRandom( vPosList , vType , occupiedTable)
			end
		elseif #nPosList > 0 then
			self:selectAndInsertAnimaByRandom( nPosList , nType , occupiedTable)
		elseif #vPosList > 0 then
			self:selectAndInsertAnimaByRandom( vPosList , vType , occupiedTable)
		end
	end
end

function SeaOrderMode:genCreatures(seaFlag, genCount, seaFlagMap, configgedCreatures, occupiedData, backSeaFlagMap, configgedCreatures_back, occupiedBackData)
	local seaAnimalTypes = SeaAnimalFlag2Types[seaFlag]
	if not seaAnimalTypes then
		assert(false, "invalid seaFlag: " .. tostring(seaFlag))
		return true
	end
	local seaAnimalType1 = seaAnimalTypes[1]
	local area1 = SeaAnimalConfig[seaAnimalType1].area
	local seaAnimalType2 = seaAnimalTypes[2]
	local area2 = nil
	if seaAnimalType2 then
		area2 = SeaAnimalConfig[seaAnimalType2].area
	end

	local occupied = occupiedData[seaFlag]
	local occupied_back = occupiedBackData[seaFlag]
	while (#occupied + #occupied_back < genCount) do 
		local possiblePos1 = self:getSeaAnimalPos(seaFlagMap , seaFlag, area1[2]-1, area1[1]-1, configgedCreatures, occupiedData)
		local possiblePos2 = {}
		if seaAnimalType2 then
			possiblePos2 = self:getSeaAnimalPos(seaFlagMap , seaFlag, area2[2]-1, area2[1]-1, configgedCreatures, occupiedData)
		end
		local possiblePos1_back = self:getSeaAnimalPos(backSeaFlagMap , seaFlag, area1[2]-1, area1[1]-1, configgedCreatures_back, occupiedBackData)
		local possiblePos2_back = {}
		if seaAnimalType2 then
			possiblePos2_back = self:getSeaAnimalPos(backSeaFlagMap , seaFlag, area2[2]-1, area2[1]-1, configgedCreatures_back, occupiedBackData)
		end
		if #possiblePos1 <=0 and #possiblePos2 <= 0 and #possiblePos1_back <=0 and #possiblePos2_back <= 0 then
			return false
		end
		self:addDataByTwoDirection( possiblePos1 , possiblePos2 , seaAnimalType1 , seaAnimalType2 , occupied)
		self:addDataByTwoDirection( possiblePos1_back , possiblePos2_back , seaAnimalType1 , seaAnimalType2, occupied_back)
	end
	return true
end

function SeaOrderMode:buildSeaAnimalMap(seaAnimalMap , seaFlagMap , boardmap , backSeaAnimalMap , backSeaFlagMap , backBoardMap)
	local allSeaAnimals = {}
	local allSeaAnimals_back = {}
	local allSeaAnimals_backCheckList = {}
	local mainLogic = self.mainLogic

	-- printx( 0 , "  ######################################  SeaOrderMode:buildSeaAnimalMap 111 " , allSeaAnimals , allSeaAnimals_backCheckList)

	-- printx( 0 , "   SeaOrderMode:buildSeaAnimalMap ====================  " , backSeaAnimalMap , backSeaFlagMap , backBoardMap)
	if not backSeaAnimalMap then backSeaAnimalMap = {} end
	if not backSeaFlagMap then backSeaFlagMap = {} end

	local targetCountData = {}
	for k, v in pairs(mainLogic.theOrderList) do 
		if v.key1 == GameItemOrderType.kSeaAnimal then
			targetCountData[v.key2] = v.v1
		end
	end
	-- if _G.isLocalDevelopMode then printx(0, "targetCountData:", table.tostring(targetCountData)) end

	local configgedCountData = self:countConfigged(seaAnimalMap)
	local configgedCountBackData = self:countConfigged(backSeaAnimalMap)

	-- if _G.isLocalDevelopMode then printx(0, "configgedCountData:", table.tostring(configgedCountData)) end
	-- if _G.isLocalDevelopMode then printx(0, "configgedCountBackData:", table.tostring(configgedCountBackData)) end

	-- 初始化配置死的动物
	local configgedCreatures = self:buildBySeaAnimalMap(seaAnimalMap)
	local configgedCreatures_back = self:buildBySeaAnimalMap(backSeaAnimalMap)

	local function getNeedGenCount(seaFlag)
		local targetCount 	= targetCountData[seaFlag] or 0
		local configgedCount = configgedCountData[seaFlag] or 0
		local configgedCount_back = configgedCountBackData[seaFlag] or 0
		return targetCount - configgedCount - configgedCount_back
	end
	
	-- 反复尝试生成一个海洋动物的生成方案，直到成功为止
	-- printx( 0 , "  ######################################  SeaOrderMode:buildSeaAnimalMap 666 " , allSeaAnimals , allSeaAnimals_backCheckList)
	local count = 0
	
	local occupiedData = {}
	local occupiedBackData = {}
	local occupiedPriority = {
		SeaAnimalType.bear_flag,
		SeaAnimalType.seal_flag,
		SeaAnimalType.penguin_flag,
		SeaAnimalType.scarf_flag,
		SeaAnimalType.elk_flag,
		SeaAnimalType.mistletoe_flag,
		SeaAnimalType.sea_3_3_flag,
	}

	local function genRandomSeaAnimal(seaFlag)
		local genCount = getNeedGenCount(seaFlag)
		if not self:genCreatures(seaFlag, genCount, seaFlagMap, configgedCreatures, occupiedData, 
				backSeaFlagMap, configgedCreatures_back, occupiedBackData) then
			return false
		end
		return true
	end

	while true do 
		count = count + 1
		if count == 1000 then 
			-- printx( 0 , "  ######################################  SeaOrderMode:buildSeaAnimalMap 999 " , allSeaAnimals , allSeaAnimals_backCheckList)
			return allSeaAnimals , allSeaAnimals_backCheckList
		end
		for i, seaFlag in ipairs(occupiedPriority) do
			occupiedData[seaFlag] = {}
			occupiedBackData[seaFlag] = {}
		end
		--if _G.isLocalDevelopMode then printx(0, 'bearOk', bearOk, 'sealOk', sealOk, 'penguinOk', penguinOk) end

		local success = true
		for i, seaFlag in ipairs(occupiedPriority) do
			if not genRandomSeaAnimal(seaFlag) then
				success = false
				break
			end
		end

		if success then
			table.append(allSeaAnimals,configgedCreatures)
			for i, seaFlag in ipairs(occupiedPriority) do
				table.append(allSeaAnimals,occupiedData[seaFlag])
			end

			table.append(allSeaAnimals_back,configgedCreatures_back)
			for i, seaFlag in ipairs(occupiedPriority) do
				table.append(allSeaAnimals_back,occupiedBackData[seaFlag])
			end
			break
		end
	end
	-- printx( 0 , "  ######################################  SeaOrderMode:buildSeaAnimalMap 777 " , table.tostring(allSeaAnimals) , allSeaAnimals_backCheckList)
	for k, v in pairs(allSeaAnimals) do
		local item = nil
		if boardmap[v.y] and boardmap[v.y][v.x] then
			item = boardmap[v.y][v.x]
		end
		if item then 
			item:initSeaAnimal(v.type)
		end
	end

	for k, v in pairs(allSeaAnimals_back) do
		local item = nil
		if backBoardMap[v.y] and backBoardMap[v.y][v.x] then
			item = backBoardMap[v.y][v.x]
		end
		if item then 
			item:initSeaAnimal(v.type)
		end
	end

	-- printx( 0 , "  ######################################  SeaOrderMode:buildSeaAnimalMap 888 " , table.tostring(allSeaAnimals) , allSeaAnimals_backCheckList)
	return allSeaAnimals
end

function SeaOrderMode:getSeaAnimalPos(seaFlagMap , flag, xAdd, yAdd, configgedCreatures, occupiedData, ... )

	local result = {}
	local gameItemMap = self.mainLogic.gameItemMap
	local flagMap = seaFlagMap

	for r = 1, #gameItemMap do
		for c = 1, #gameItemMap[r] do
			if flagMap[r] and flagMap[r][c] then
				local canPutFlag = self.mainLogic:isItemInTile(r, c) and not self.mainLogic:areaDevidedByRope(c, r, c + xAdd, r + yAdd)
				if canPutFlag then
					for yIndex = r, r + yAdd do
						for xIndex =c, c + xAdd do
							if xIndex > 9 or yIndex > 9 then
								canPutFlag = false
								break
							end

							if flagMap[yIndex] and flagMap[yIndex][xIndex] then
								-- if flag == SeaAnimalType.seal_flag then
								-- 	if _G.isLocalDevelopMode then printx(0, 'isFlagBitSet', flagMap[r][c], isFlagBitSet(flagMap[r][c], flag)) end
								-- end
								if isFlagBitSet(flagMap[yIndex][xIndex], flag) then
									if self:hasGridOccupied(xIndex, yIndex, configgedCreatures) then
										canPutFlag = false
										break
									end
									for k, arg in pairs(occupiedData) do
										if self:hasGridOccupied(xIndex, yIndex, arg) then
											canPutFlag = false
											break
										end
									end
								else
									canPutFlag = false
									break
								end
							else
								canPutFlag = false
								break
							end
							if not canPutFlag then break end
						end
						if not canPutFlag then break end
					end
				end
				if canPutFlag then
					table.insert(result, {x = c, y = r})
				end
			end
		end

	end
	return result
end

function SeaOrderMode:hasGridOccupied(x, y, occupiedAnimal)
	for k, v in pairs(occupiedAnimal) do
		if x >= v.x and x <= v.xEnd and y >= v.y and y <= v.yEnd then
			return true
		end
	end
	return false
end
