local LevelConfigCheckLogic = {}

function LevelConfigCheckLogic:getLevelCfg( levelId )
	local levelConfig = LevelDataManager.sharedLevelData():getLevelConfigByID( levelId , true )
	return levelConfig
end

function LevelConfigCheckLogic:getMaxColorNum( levelCfg )
	return levelCfg.numberOfColors
end

function LevelConfigCheckLogic:getKnownColorList( levelCfg )
	-- body
	local tileMap = levelCfg.tileMap
	local animalMap = levelCfg.animalMap

	local colorSet = {}

	for r = 1, #tileMap do
		for c = 1, #tileMap[r] do
			local tileDef = tileMap[r][c]
			if tileDef:hasProperty(TileConst.kAnimal) then
				local colorType = AnimalTypeConfig.getType(animalMap[r][c])
				local colorIndex = AnimalTypeConfig.convertColorTypeToIndex(colorType)
				table.insertIfNotExist(colorSet, colorIndex)
			end
		end
	end

	colorSet = table.filter(colorSet, function ( v )
		return v ~= 0
	end)

	return colorSet
end

function LevelConfigCheckLogic:getPossibleColorList( levelCfg )

	local knownColorList = self:getKnownColorList(levelCfg)
	local maxColorNum = self:getMaxColorNum(levelCfg)
	local fixedColorList = GameMapInitialLogic:initDefaultColors(levelCfg.defaultColorCfg)
	fixedColorList = table.filter(fixedColorList, AnimalTypeConfig.convertColorTypeToIndex)
	table.append(fixedColorList, knownColorList)
	fixedColorList = table.headn(fixedColorList, maxColorNum)
	local restNum = maxColorNum - #fixedColorList
	if restNum > 0 then
		return {1,2,3,4,5,6}
	else
		return table.unique(table.union(fixedColorList, knownColorList))
	end
end

local function table_and( t1, t2 )
	return table.filter(t1, function ( item )
		return table.indexOf(t2, item) ~= nil
	end)
end

local function math_random_choice( t )
	if #t > 0 then
		return t[math.random(1, #t)]
	end
end

function LevelConfigCheckLogic:randQuestColor( ... )
	local localMaxLevel = NewAreaOpenMgr.getInstance():getLocalTopLevel()

	local topLevel = UserManager:getInstance().user:getTopLevelId()
	local minLevel = topLevel
	if UserManager:getInstance():hasPassedLevelEx(minLevel) then
		minLevel = minLevel + 1
	end

	local maxLevel = minLevel + 1

	local levels = {}
	for i = minLevel, maxLevel do
		if i <= localMaxLevel then
			table.insert(levels, i)
		end
	end

	if #levels > 0 then
		local possibleAnimalList = {1, 2, 3, 4, 5, 6}
		for _, levelId in ipairs(levels) do
			local cfg = self:getLevelCfg(levelId)
			local colorList = self:getPossibleColorList(cfg)
			possibleAnimalList = table_and(possibleAnimalList, colorList)
		end

		if #possibleAnimalList > 0 then
			return math_random_choice(possibleAnimalList)
		end
	end

	return math.random(1, 6)

end


return LevelConfigCheckLogic