GameExtandPlayLogic = class{}

function GameExtandPlayLogic:checkMissile(mainLogic)
    local gameItemMap = mainLogic.gameItemMap

    local missiles = {}
    for r = 1, #gameItemMap do
        for c = 1, #gameItemMap[r] do
            local item = gameItemMap[r][c]
            if item and item.ItemType == GameItemType.kMissile and item:isAvailable() then
                if item.missileLevel == 0 then
                    table.insert(missiles, item)
                end
            end
        end
    end
    -- 有可以发射的冰封导弹
    return missiles
end

function GameExtandPlayLogic:fireMissiles(mainLogic,missiles,allCompleteCallback)
-- 有可以发射的冰封导弹
    if (missiles and #missiles > 0) then
	    -- 播放完导弹发射动画
	    local callback = function()
	        for i,missileItemData in ipairs(missiles) do
	            if missileItemData then 
	            	-- line 150
	            	--printx( 1 , "GameExtandPlayLogic:fireMissiles  callback " , missileItemData.x, missileItemData.y )

	            	local uid = UserManager:getInstance().uid or 12345
	            	--printx( 1 , "uid = " , uid ,MaintenanceManager:getInstance():isEnabledInGroup("MissileBugFix" , "B1" , uid) )
					if not MaintenanceManager:getInstance():isEnabledInGroup("MissileBugFix" , "B1" , uid) then
	            		GameExtandPlayLogic:itemDestroyHandler( mainLogic, missileItemData.x, missileItemData.y )
	            	end

	                missileItemData:cleanAnimalLikeData()
	                SnailLogic:SpecialCoverSnailRoadAtPos( mainLogic, missileItemData.y, missileItemData.x )
	                -- mainLogic:setNeedCheckFalling()
	                ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_Missile, ObstacleFootprintAction.k_Eliminate, 1)
	            end
	        end
	        allCompleteCallback()
	        if _G.isLocalDevelopMode then printx(0, "missile action callback") end
	    end

	    -- 获得视图层
	    local missileViews = {}

	    --printx( 1 , "GameExtandPlayLogic:fireMissiles  ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
	    for i,itemData in ipairs(missiles) do
	    	--printx("r =" , itemData.y , " c =" , itemData.x)
	        local itemView = mainLogic.boardView.baseMap[itemData.y][itemData.x]
	        table.insert(missileViews,itemView)
	    end

	    if _G.isLocalDevelopMode then printx(0, "missile prepare to fight") end
	    -- 冰封导弹发射
	    local action = GameBoardActionDataSet:createAs(
	        GameActionTargetType.kGameItemAction,
	        GameItemActionType.kMissileFire, 
	        nil,
	        nil,
	        GamePlayConfig_MaxAction_time
	        )
	    action.missileViews = missileViews
	    action.missiles = missiles
	    action.completeCallback = callback
	    mainLogic:addDestroyAction(action)
	    mainLogic:setNeedCheckFalling()
    end
end

local function tryWarp( source , count )
	local mainLogic = GameBoardLogic:getCurrentLogic()
	local datas = {}
	datas.t = "useProps"
	datas.uid = UserManager:getInstance():getUID()

	local pid = 0
	if source == GameItemType.kBalloon then
		pid = ItemType.ADD_FIVE_STEP_BY_BALLOON
	elseif source == GameItemType.kAddMove then
		pid = ItemType.ADD_FIVE_STEP_BY_ANIMAL
		datas.addMovesCount = count
	end

	datas.itemList = {}
	table.insert( datas.itemList , pid )

	if mainLogic then
		datas.levelId = mainLogic.level or 0
	else
		datas.levelId = 0
	end
	
	Localhost:warpEngine( datas )
end

-- 找到该导弹根据优先级的射击目标,共mainLogic.missileLevel
function GameExtandPlayLogic:findMissileTarget(mainLogic,missile, pickAmount)

	local initWeightArray = {}
	local gameItemMap = mainLogic.gameItemMap
	for r = 1, #gameItemMap do 
		for c = 1, #gameItemMap[r] do 
			local w = {}
			w.row = r 
			w.col = c 
			-- w.weight = self:getMissileTargetPrior(missile,mainLogic,r, c)
			w.weight = CommonMultipleHittingPriorityLogic:getTargetGridPrior(mainLogic, r, c, missile, mainLogic.missileHasHitPoint)
			table.insert(initWeightArray,w)
		end
	end

	local unOrderWeightArray = table.randomOrder(initWeightArray,mainLogic)
	-- if _G.isLocalDevelopMode then printx(0, "unOrderWeightArray...",table.tostring(unOrderWeightArray)) end
	-- order by weight
	local function sortFunc(a, b)
		return a.weight > b.weight
	end
	table.sort(unOrderWeightArray, sortFunc)
	-- if _G.isLocalDevelopMode then printx(0, "order unOrderWeightArray...",table.tostring(unOrderWeightArray)) end

	-- for i,v in ipairs(unOrderWeightArray) do
		-- if _G.isLocalDevelopMode then printx(0, "missile hit",v.weight,v.row,v.col) end
	-- end
	-- debug.debug()

	local ret={}
	for i=1, pickAmount do
		if (unOrderWeightArray[i].weight > 0) then 
			table.insert(mainLogic.missileHasHitPoint,{row = unOrderWeightArray[i].row,col = unOrderWeightArray[i].col})
			table.insert(ret,IntCoord:create(unOrderWeightArray[i].col,unOrderWeightArray[i].row))
		end
		-- if _G.isLocalDevelopMode then printx(0, "missile hit",unOrderWeightArray[i].weight,unOrderWeightArray[i].row,unOrderWeightArray[i].col) end
	end
	if (#ret == 0) then if _G.isLocalDevelopMode then printx(0, "!!! missile find no target !!!") end end
	-- if _G.isLocalDevelopMode then printx(0, ".............find ret ...",table.tostring(ret)) end
	return ret
	-- return {IntCoord:create(1, 5),IntCoord:create(1, 6),IntCoord:create(1, 7)}
end

-- MissileTargetWeidhtPriority1 = 100
-- MissileTargetWeidhtPriority2 = 90
-- MissileTargetWeidhtPriority3 = 80
-- MissileTargetWeidhtPriority4 = 70
-- MissileTargetWeidhtPriority5 = 60
-- MissileTargetWeidhtPriority6 = 50
-- MissileTargetWeidhtInvalid = -1
-- function GameExtandPlayLogic:getMissileTargetPrior(missile,mainLogic, r, c )
-- 	local ret = 0
-- 	local itemData = mainLogic.gameItemMap[r][c]
-- 	local boradData = mainLogic.boardmap[r][c]

-- 	local isSeaAnimal = false
-- 	if (boradData.iceLevel > 0 and  mainLogic.gameMode.allSeaAnimals) then
-- 		for k, v in pairs(mainLogic.gameMode.allSeaAnimals) do
-- 			for row = v.y, v.yEnd do 
-- 				for col = v.x, v.xEnd do
-- 					if mainLogic.boardmap[row][col].iceLevel and mainLogic.boardmap[row][col].iceLevel > 0 or
-- 						(mainLogic.boardmap[row][col].tileBlockType == 1 and mainLogic.boardmap[row][col].isReverseSide) then
-- 						if ( r == row and c == col) then 
-- 							if (itemData.ItemType ~= GameItemType.kNone) then
-- 								isSeaAnimal = true
-- 								break
-- 							end
-- 						end
-- 					end
-- 				end
-- 			end
-- 		end
-- 	end

-- 	if (missile.y == r and missile.x == c) then
-- 		ret =  -999
-- 	elseif itemData.isReverseSide == true then -- 单面翻转地块反面
-- 		ret = 0 
-- 	elseif isSeaAnimal or itemData:isMissileTargetPrior1() or boradData:isMissileTargetPrior1() then
-- 		ret = MissileTargetWeidhtPriority1
-- 	elseif itemData:isMissileTargetPrior2(boradData) or boradData:isMissileTargetPrior2(itemData) then 
-- 		ret = MissileTargetWeidhtPriority2
-- 	elseif itemData:isMissileTargetPrior3(boradData) or boradData:isMissileTargetPrior3(itemData) then 
-- 		ret = MissileTargetWeidhtPriority3
-- 	elseif itemData:isMissileTargetPrior4() or boradData:isMissileTargetPrior4() then 
-- 		ret = MissileTargetWeidhtPriority4
-- 	elseif itemData:isMissileTargetPrior5() or boradData:isMissileTargetPrior5() then 
-- 		ret = MissileTargetWeidhtPriority5
-- 	elseif itemData:isMissileTargetPrior6() or boradData:isMissileTargetPrior6() then 
-- 		ret = MissileTargetWeidhtPriority6
-- 	else
-- 		ret = 0
-- 	end

-- 	if itemData:isMissileTargetInvalid() or boradData:isMissileTargetInvalid() then -- 优先不打的
-- 		ret = MissileTargetWeidhtInvalid
-- 	end

-- 	-- if _G.isLocalDevelopMode then printx(0, "r c weight",r,c,ret) end
-- 	for _,v in ipairs(mainLogic.missileHasHitPoint) do
-- 		if (v.row == r and v.col == c) then
-- 			ret = 0
-- 		end
-- 	end

-- 	-- 在豆荚列的优先消除 只打豆荚下面
-- 	local colHasFuge = false
-- 	-- for r = 1, #mainLogic.gameItemMap do 
-- 	for cr = 1,r do 
-- 		if (mainLogic.gameItemMap[cr][c].ItemType == GameItemType.kIngredient ) then
-- 			colHasFuge = true
-- 		end
-- 	end

-- 	if (colHasFuge and mainLogic.theGamePlayType == GameModeTypeId.DROP_DOWN_ID) then
-- 		ret = ret * 10
-- 	end
-- 	-- if _G.isLocalDevelopMode then printx(0, "============r c weight",r,c,ret) end
-- 	return ret
-- end

function GameExtandPlayLogic:hitMissile(mainLogic, item, r, c, noScore, hitAll)
	if (mainLogic.isBonusTime) then
		return 
	end

	-- if _G.isLocalDevelopMode then printx(0, "hist missile ",r,c,noScore,item) end
	if item.missileLevel > 0 then 
		local hitTimes = 1
		if hitAll then
			hitTimes = item.missileLevel
		end

		item.missileLevel = item.missileLevel - hitTimes
		if item.missileLevel <= 0 then 
			item.missileLevel = 0
			mainLogic:setNeedCheckFalling()

			-- item:AddItemStatus(GameItemStatusType.kDestroy)
		end

		if (not noScore) then
			local addScore = GamePlayConfigScore.MatchAt_Missile
			mainLogic:addScoreToTotal(r, c, addScore)
		end
		-- --add todo
		-- local duringTime = 1
		-- if item.blackCuteStrength == 0 then 
		-- 	duringTime = GamePlayConfig_BlackCuteBall_Destroy
		-- end
		local missileAction = GameBoardActionDataSet:createAs(
			GameActionTargetType.kGameItemAction,
			GameItemActionType.kMissileHit,  
			IntCoord:create(r, c),
			nil,
			GamePlayConfig_MaxAction_time)
		missileAction.missileLevel = item.missileLevel
		mainLogic:addDestroyAction(missileAction)
	end
end

-----返回true，成功发起颜色变化
function GameExtandPlayLogic:checkCrystalChangeColor(mainLogic, completeCallback)
	local ret = 0
	local crystalBalls = self:filterItemByConditions(mainLogic, { gameItemTypeList = { GameItemType.kCrystal } , lotusLevelLess = 2 })
	if #crystalBalls == 0 then
		return 0
	end

	local colorList = mainLogic.mapColorList
	local originColorMatrix = {}
	local failColorMatrix = {}
	for r = 1, #mainLogic.gameItemMap do
		originColorMatrix[r] = {}
		failColorMatrix[r] = {}
		for c = 1, #mainLogic.gameItemMap[r] do
			originColorMatrix[r][c] = mainLogic.gameItemMap[r][c]._encrypt.ItemColorType
			failColorMatrix[r][c] = mainLogic.gameItemMap[r][c]._encrypt.ItemColorType
		end
	end
	
	local function getPossibleChangeColor(item)
		local banColorTable = {}
		local oriColor = originColorMatrix[item.y][item.x]
		table.insert(banColorTable, oriColor)
		local colorFilterColor = ColorFilterLogic:getFilterColor(item.y, item.x)
		if colorFilterColor and colorFilterColor ~= oriColor then 
			table.insert(banColorTable, colorFilterColor)
		end

		local result = {}
		for i,v in ipairs(colorList) do
			if not table.includes(banColorTable, v) then 
				table.insert(result, v)
			end
		end
		return result
	end

	local function checkHasMatchQuick()
		for i, item in ipairs(crystalBalls) do
			if mainLogic:checkMatchQuick(item.y, item.x, item._encrypt.ItemColorType) then
				return true
			end
		end
		return false
	end

	local retryTimes = 0
	local cloneFlag = false
	local success = false 
	local hasCrystalItemInSwapArea = nil
	local possibleComposition = {}
	local numTotalPosssibleComposition = nil

	local function getTotalPossibleComposition()
		if not numTotalPosssibleComposition then
			numTotalPosssibleComposition = 1
			for i, item in ipairs(crystalBalls) do
				local possibleColor = getPossibleChangeColor(item)
				numTotalPosssibleComposition = numTotalPosssibleComposition * (#possibleColor > 0 and #possibleColor or 1)
			end
		end
		return numTotalPosssibleComposition
	end

	local function isCompositionEqual(compA, compB)
		if #compA ~= #compB then return false end
		for i, c in ipairs(compA) do
			if c ~= compB[i] then return false end
		end
		return true
	end

	local function isCompositionDuplicate(composition)
		for _, compoEle in ipairs(possibleComposition) do
			if isCompositionEqual(compoEle, composition) then
				return true
			end
		end
		table.insert(possibleComposition, composition)
		return false
	end

	while retryTimes < 500 do
		if #possibleComposition >= getTotalPossibleComposition() then
			success = false
			break
		end
		retryTimes = retryTimes + 1

		-- 对选择的颜色结果进行查重，重复的组合不再重复计算
		repeat
			local composition = {}
			for i, item in ipairs(crystalBalls) do
				local possibleColor = getPossibleChangeColor(item)
				
				if #possibleColor > 0 then
					local index = mainLogic.randFactory:rand(1, #possibleColor)
					item._encrypt.ItemColorType = possibleColor[index]
				end
				table.insert(composition, item._encrypt.ItemColorType)
			end
		until not isCompositionDuplicate(composition)
		
		if not checkHasMatchQuick() then
			if not cloneFlag then
				cloneFlag = true
				for r = 1, #mainLogic.gameItemMap do
					for c = 1, #mainLogic.gameItemMap[r] do
						failColorMatrix[r][c] = mainLogic.gameItemMap[r][c]._encrypt.ItemColorType
					end
				end
			end
			
			if not RefreshItemLogic:checkNeedRefresh(mainLogic) then
				success = true
				break
			elseif hasCrystalItemInSwapArea == nil then -- 对于无法参与匹配计算的水晶球，无需强求组成possibleSwap
				hasCrystalItemInSwapArea = false
				for i, item in ipairs(crystalBalls) do
					local isSwapAreaValid = RefreshItemLogic.isItemSwapAreaValid(mainLogic, item.y, item.x)
					if isSwapAreaValid then hasCrystalItemInSwapArea = true end
				end
				-- if _G.isLocalDevelopMode then printx(0, hasCrystalItemInSwapArea) end
				if not hasCrystalItemInSwapArea then
					success = true
					break
				end
			end
		end
	end
	-- if _G.isLocalDevelopMode then printx(0, "success : ", success, "retryTimes : ", retryTimes) end

	for i, item in ipairs(crystalBalls) do

		local theAction = GameBoardActionDataSet:createAs(
			GameActionTargetType.kGameItemAction,				--动作发起主体	
			GameItemActionType.kItem_Crystal_Change,			--动作类型	    
			IntCoord:create(item.y, item.x),								--动作物体1		
			nil,												--动作物体2		
			GamePlayConfig_CrystalChange_time)					--动作持续时间	
		local targetColor = nil
		if success then
			targetColor = item._encrypt.ItemColorType
		else
			targetColor = failColorMatrix[item.y][item.x]
		end
		theAction.addInt = targetColor
		theAction.callback = completeCallback
		mainLogic:addGameAction(theAction)

		item._encrypt.ItemColorType = originColorMatrix[item.y][item.x]
		ret = ret + 1
	end

	return ret
end

function GameExtandPlayLogic:checkVenomSpread(mainLogic, completeCallback)
	local aroundDirections = {
		{ x = -1, y = 0 }, 
		{ x = 1, y = 0 }, 
		{ x = 0, y = -1 }, 
		{ x = 0, y = 1 }
	}

	local function getItemAt(r, c)
		if mainLogic.gameItemMap[r] then
			return mainLogic.gameItemMap[r][c]
		end
		return nil
	end

	local function getBoardAt(r, c)
		if mainLogic.boardmap[r] then
			return mainLogic.boardmap[r][c]
		end
		return nil
	end

	local function calculateItemAroundVenom(venom, positionMap , poisonPassSelectActive)
		local item = nil
		local board = nil
		
		for k, v in ipairs(aroundDirections) do
			item = getItemAt(v.y + venom.y, v.x + venom.x)
			board = getBoardAt(v.y + venom.y, v.x + venom.x)
			if item and (not item:hasLock()) and not item:hasFurball() 
				and ( not poisonPassSelectActive or not board.poisonPassSelect )
				and (item.ItemType == GameItemType.kAnimal
					or item.ItemType == GameItemType.kAddTime
					--or item.ItemType == GameItemType.kGift 
					or item.ItemType == GameItemType.kCrystal) 
				and not mainLogic:hasChainInNeighbors(venom.y, venom.x, v.y + venom.y, v.x + venom.x)
				and board.blockerCoverMaterialLevel ~= -1
				then

				if not positionMap[item.x .. "_" .. item.y] then
					positionMap[item.x .. "_" .. item.y] = { venom = venom, item = item, dir = v }
				end
			end
		end
	end

	local function poisonedPrioritySorter(pre, next)
		if pre.item.y == next.item.y then
			return pre.item.x < next.item.x
		else
			return pre.item.y < next.item.y
		end
	end

	local POISONED_ITEM_PRIORITY_NORMAL = 1
	local POISONED_ITEM_PRIORITY_SPECIAL = 2
	local POISONED_ITEM_PRIORITY_LIST = { POISONED_ITEM_PRIORITY_SPECIAL, POISONED_ITEM_PRIORITY_NORMAL }

	local function calculatePossiblePoisonedPairs()
		local positionItemMap = {}
		local possiblePoisonedItemGroup = {}
		local item = nil
		
		local function buildPositionItemMap( poisonPassSelectActive )
			for r = 1, #mainLogic.gameItemMap do
				for c = 1, #mainLogic.gameItemMap[r] do
					item = getItemAt(r, c)
					if item:isAvailable() and not item:hasActiveSuperCuteBall() then
						if item.ItemType == GameItemType.kVenom 
								or (item.ItemType == GameItemType.kPoisonBottle and item.forbiddenLevel <= 0) then
							calculateItemAroundVenom(item, positionItemMap , poisonPassSelectActive)
						end
					end 
				end
			end
		end
		
		buildPositionItemMap(true)
		local resultNum = 0
		for k, v in pairs(positionItemMap) do
			resultNum = resultNum + 1
		end
		if resultNum == 0 then
			buildPositionItemMap(false)
		end

		for k, v in ipairs(POISONED_ITEM_PRIORITY_LIST) do
			possiblePoisonedItemGroup[v] = {}
		end
		
		for k, v in pairs(positionItemMap) do
			if v.item:isAvailable() then
				if v.item.ItemType == GameItemType.kAnimal 
					and AnimalTypeConfig.isSpecialTypeValid(v.item.ItemSpecialType)
					then
					table.insert(possiblePoisonedItemGroup[POISONED_ITEM_PRIORITY_SPECIAL], v)
				elseif v.item.ItemType == GameItemType.kAnimal 
					or v.item.ItemType == GameItemType.kCrystal
					--or v.item.ItemType == GameItemType.kGift 
					then
					table.insert(possiblePoisonedItemGroup[POISONED_ITEM_PRIORITY_NORMAL], v)
				elseif v.item.ItemType == GameItemType.kAddTime then
					table.insert(possiblePoisonedItemGroup[POISONED_ITEM_PRIORITY_SPECIAL], v)
				end 
			end
			
		end
		
		for k, v in ipairs(possiblePoisonedItemGroup) do
			table.sort(v, poisonedPrioritySorter)
		end

		return possiblePoisonedItemGroup;
	end

	local ret = false

	local possiblePoisonedPairs = calculatePossiblePoisonedPairs()
	local targetPoisonPair = nil
	local groupUnit = nil

	for k, v in ipairs(possiblePoisonedPairs) do 
		groupUnit = v
		if #groupUnit > 0 then
			local targetIndex = mainLogic.randFactory:rand(1, #groupUnit)
			targetPoisonPair = groupUnit[targetIndex]
			break
		end
	end
	
	if targetPoisonPair then
		local theAction = GameBoardActionDataSet:createAs(
			GameActionTargetType.kGameItemAction,
			GameItemActionType.kItem_Venom_Spread,
			IntCoord:create(targetPoisonPair.venom.y, targetPoisonPair.venom.x),
			IntCoord:create(targetPoisonPair.item.y, targetPoisonPair.item.x),
			GamePlayConfig_VenomSpread_time)
		theAction.callback = completeCallback
		theAction.itemType = targetPoisonPair.venom.ItemType
		mainLogic:addGameAction(theAction)

		local targetItem = mainLogic.gameItemMap[targetPoisonPair.item.y][targetPoisonPair.item.x]
		targetItem.isBlock = true

		ret = true
	end

	return ret
end

function GameExtandPlayLogic:checkFurballTransfer(mainLogic, completeCallback)
	local cuteballMoveHandleTotal = 0
	
	local itemsWithGreyCuteBall = GameExtandPlayLogic:filterItemByConditions(mainLogic, {furballTypeList = { GameItemFurballType.kGrey }})
	table.sort(itemsWithGreyCuteBall, GameExtandPlayLogic.itemPositionSorter)

	for i, item in ipairs(itemsWithGreyCuteBall) do
		local validAroundItems = GameExtandPlayLogic:getFurballValidAroundItems(mainLogic, item)
		local targetItem = nil
		if #validAroundItems > 0 then
			cuteballMoveHandleTotal = cuteballMoveHandleTotal + 1
			targetItem = validAroundItems[mainLogic.randFactory:rand(1, #validAroundItems)]

			targetItem:addFurball(item.furballType)
			item.furballLevel = 0
			item.furballType = GameItemFurballType.kNone

			local TransferAction = GameBoardActionDataSet:createAs(
				GameActionTargetType.kGameItemAction,
				GameItemActionType.kItem_Furball_Transfer,
				IntCoord:create(item.y, item.x),
				IntCoord:create(targetItem.y, targetItem.x),
				GamePlayConfig_Furball_Transfer)
			TransferAction.addInt = targetItem.furballType
			TransferAction.callback = completeCallback
			mainLogic:addGameAction(TransferAction)
		end
	end

	local itemsWithBrownCuteBall = GameExtandPlayLogic:filterItemByConditions(mainLogic, {furballTypeList = { GameItemFurballType.kBrown }})
	table.sort(itemsWithBrownCuteBall, GameExtandPlayLogic.itemPositionSorter)

	for i, item in ipairs(itemsWithBrownCuteBall) do
		if not item.isBrownFurballUnstable then
			local validAroundItems = GameExtandPlayLogic:getFurballValidAroundItems(mainLogic, item)
			local targetItem = nil
			if #validAroundItems > 0 then
				cuteballMoveHandleTotal = cuteballMoveHandleTotal + 1
				targetItem = validAroundItems[mainLogic.randFactory:rand(1, #validAroundItems)]

				targetItem:addFurball(item.furballType)
				item:removeFurball()

				local TransferAction = GameBoardActionDataSet:createAs(
					GameActionTargetType.kGameItemAction,
					GameItemActionType.kItem_Furball_Transfer,
					IntCoord:create(item.y, item.x),
					IntCoord:create(targetItem.y, targetItem.x),
					GamePlayConfig_Furball_Transfer)
				TransferAction.addInt = targetItem.furballType
				TransferAction.callback = completeCallback
				mainLogic:addGameAction(TransferAction)
			end
		end
	end

	return cuteballMoveHandleTotal
end

function GameExtandPlayLogic:filterItemByConditions(mainLogic, conditions)
	local function isGameItemType(item, itemTypeList)
		if not itemTypeList or #itemTypeList == 0 then
			return true
		end

		for i,v in ipairs(itemTypeList) do
			if item.ItemType == v then
				return true
			end
		end

		return false
	end

	local function isGameItemFurballType(item, furballTypeList)
		if not furballTypeList or #furballTypeList == 0 then
			return true
		end

		for i,v in ipairs(furballTypeList) do
			if item.furballLevel > 0 and item.furballType == v then
				return true
			end
		end
		return false
	end

	local function checkLotusLevelLess(item , lotusLevel)
		if not lotusLevel or not item.lotusLevel then
			return true
		end

		return item.lotusLevel <= lotusLevel
	end
	
	local ret = {}
	for r = 1, #mainLogic.gameItemMap do
		for c = 1, #mainLogic.gameItemMap[r] do
			local item = mainLogic.gameItemMap[r][c]
			if isGameItemType(item, conditions.gameItemTypeList) 
				and isGameItemFurballType(item, conditions.furballTypeList)
				and checkLotusLevelLess(item, conditions.lotusLevelLess)
				and item:isAvailable()
				then
				table.insert(ret, item)
			end
		end
	end

	return ret
end

function GameExtandPlayLogic.itemPositionSorter(pre, next)
	if pre.y == next.y then
		return pre.x < next.x
	else
		return pre.y < next.y
	end
end

function GameExtandPlayLogic:getFurballValidAroundItems(mainLogic, centerItem)
	local aroundDirections = {
		{ x = -1, y = 0 }, 
		{ x = 1, y = 0 }, 
		{ x = 0, y = -1 }, 
		{ x = 0, y = 1 }
	}

	local function getItemAt(r, c)
		if mainLogic.gameItemMap[r] then
			return mainLogic.gameItemMap[r][c]
		end
		return nil
	end

	local function getBoardAt(r, c)
		if mainLogic.boardmap[r] then
			return mainLogic.boardmap[r][c]
		end
		return nil
	end

	local cx = centerItem.x
	local cy = centerItem.y

	local result = {}
	local tempItem = nil
	local tempBoard = nil
	for i, coord in ipairs(aroundDirections) do 
		tempItem = getItemAt(cy + coord.y, cx + coord.x);
		tempBoard = getBoardAt(cy + coord.y, cx + coord.x)
		if tempItem 
			and (tempItem.ItemType == GameItemType.kAnimal 
				or tempItem.ItemType == GameItemType.kGift 
				or tempItem.ItemType == GameItemType.kNewGift
				or tempItem.ItemType == GameItemType.kAddTime
				or tempItem.ItemType == GameItemType.kCrystal
				or tempItem.ItemType == GameItemType.kQuestionMark
				or tempItem.ItemType == GameItemType.kScoreBuffBottle
				or tempItem.ItemType == GameItemType.kFirecracker
				)
			and not tempItem:hasFurball()
			and not tempItem.isBlock 
			and tempItem:canBeCoverByMatch()
			and not tempBoard:hasSuperCuteBall() 
			and tempBoard.blockerCoverMaterialLevel ~= -1
			and not mainLogic:hasChainInNeighbors(cy, cx, cy + coord.y, cx + coord.x) then
			table.insert(result, tempItem)
		end
	end

	return result
end

function GameExtandPlayLogic:checkFurballSplit(mainLogic, completeCallback)
	local cuteballSplitHandleTotal = 0
	local validAroundItems = {}
	local itemsWithBrownCuteBall = GameExtandPlayLogic:filterItemByConditions(mainLogic, {furballTypeList = { GameItemFurballType.kBrown }})
	table.sort(itemsWithBrownCuteBall, GameExtandPlayLogic.itemPositionSorter)
	for i, item in ipairs(itemsWithBrownCuteBall) do
		validAroundItems = GameExtandPlayLogic:getFurballValidAroundItems(mainLogic, item)
		if item.isBrownFurballUnstable then
			local targetItem = nil
			local targetPos = nil
			if #validAroundItems > 0 then
				targetItem = validAroundItems[mainLogic.randFactory:rand(1, #validAroundItems)]
				targetItem:addFurball(GameItemFurballType.kGrey)
				targetPos = IntCoord:create(targetItem.y, targetItem.x)
				ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_BrownFurball, ObstacleFootprintAction.k_GenerateSubItem, 1)
			end
			item:removeFurball()
			item:addFurball(GameItemFurballType.kGrey)
			ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_BrownFurball, ObstacleFootprintAction.k_GenerateSubItem, 1)
			local SplitAction = GameBoardActionDataSet:createAs(
				GameActionTargetType.kGameItemAction,
				GameItemActionType.kItem_Furball_Split,
				IntCoord:create(item.y, item.x),
				targetPos,
				GamePlayConfig_Furball_Split)
			SplitAction.callback = completeCallback
			mainLogic:addGameAction(SplitAction)

			cuteballSplitHandleTotal = cuteballSplitHandleTotal + 1
		end
	end
	
	return cuteballSplitHandleTotal
end

function GameExtandPlayLogic:checkRoostReplace(mainLogic, completeCallback)
	local function getPossbileReplaceItemList()
		local result = {}		
		for r = 1, #mainLogic.gameItemMap do
			for c = 1, #mainLogic.gameItemMap[r] do
				local item = mainLogic.gameItemMap[r][c]
				if (item.ItemType == GameItemType.kAnimal  ) --or item.ItemType == GameItemType.kNewGift
					and item.ItemSpecialType == 0
					and item._encrypt.ItemColorType ~= AnimalTypeConfig.kYellow
					and not item:hasLock() 
					and not item:hasFurball()
					and item:isAvailable()
					then
					table.insert(result, item)
				end
			end
		end
		return result
	end

	local totalNum = 0
	local roostList = GameExtandPlayLogic:filterItemByConditions(mainLogic, { gameItemTypeList = { GameItemType.kRoost } })
	table.sort(roostList, GameExtandPlayLogic.itemPositionSorter)
	local possibleItemList = getPossbileReplaceItemList()
	local maxReplaceNumFromConfig = mainLogic.replaceColorMaxNum
	local roostReplaceMap = {}

	-- if _G.isLocalDevelopMode then printx(0, "*************************************possibleItemList",#possibleItemList,maxReplaceNumFromConfig) end
	for i, roost in ipairs(roostList) do
		if roost.roostLevel == 4 then
			local replaceList = {}
			local from = IntCoord:create(roost.y, roost.x)
			if #possibleItemList > 0 then

				local needNum = maxReplaceNumFromConfig
				if #possibleItemList < maxReplaceNumFromConfig then
					needNum = #possibleItemList
				end

				for counter = 1, needNum do
					local idx = mainLogic.randFactory:rand(1, #possibleItemList)
					local item = possibleItemList[idx]
					local to = IntCoord:create(item.y, item.x)
					table.insert(replaceList, to)
					table.remove(possibleItemList, idx)
					-- item.ItemType = GameItemType.kAnimal
					item._encrypt.ItemColorType = AnimalTypeConfig.kYellow
				end
				ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_Roost, ObstacleFootprintAction.k_GenerateSubItem, needNum)
			end
			roostReplaceMap[from] = replaceList
			if #replaceList > 0 then --实际放出了鸡
				roost.roostCastCount = roost.roostCastCount + 1
			end
			roost:roostReset()
				
			totalNum = totalNum + 1
		end
	end
	
	if totalNum > 0 then
		for from, replaceItemList in pairs(roostReplaceMap) do
			local ReplaceAction = GameBoardActionDataSet:createAs(
				GameActionTargetType.kGameItemAction,
				GameItemActionType.kItem_Roost_Replace,
				from,
				nil,
				GamePlayConfig_Roost_Replace
			)
			ReplaceAction.itemList = replaceItemList
			ReplaceAction.callback = completeCallback
			mainLogic:addGameAction(ReplaceAction)
		end
	end
			
	return totalNum
end

function GameExtandPlayLogic:onMagicTileHit(mainLogic, r, c)
	local gameItem = mainLogic.gameItemMap[r][c]
	local boardItem = mainLogic.boardmap[r][c]

	if not mainLogic:getMoleWeeklyBossData() then
		--削减地格承受攻击次数
		if boardItem then
			local id = boardItem.magicTileId
			for r = 1, #mainLogic.boardmap do
				for c = 1, #mainLogic.boardmap[r] do
					local item2 = mainLogic.boardmap[r][c]
					if item2 and item2.isMagicTileAnchor == true and item2.magicTileId == id then
						item2.isHitThisRound = true
					end
				end
			end
		end
	else
		local action = GameBoardActionDataSet:createAs(
			GameActionTargetType.kGameItemAction,
			GameItemActionType.kItem_Magic_Tile_Hit,
			IntCoord:create(r,c),
			nil,
			GamePlayConfig_MaxAction_time
		)

		if AnimalTypeConfig.isSpecialTypeValid(gameItem.ItemSpecialType) then
			action.count = mainLogic:getMoleWeeklyBossData().specialHit
		else
			action.count = mainLogic:getMoleWeeklyBossData().normalHit
		end

		action.magicTileId = boardItem.magicTileId
		action.magicTileIndex = boardItem.magicTileIndex
		mainLogic:addGameAction(action)
	end
end

function GameExtandPlayLogic:chargeCrystalStone(mainLogic, fr, fc, colortype)
	if mainLogic.theGamePlayStatus ~= GamePlayStatus.kNormal then
		return
	end

	for r = 1, #mainLogic.gameItemMap do
		for c = 1, #mainLogic.gameItemMap[r] do
			local item = mainLogic.gameItemMap[r][c]
			if item and item.ItemType == GameItemType.kCrystalStone 
				and item._encrypt.ItemColorType == colortype and item:canCrystalStoneBeCharged() then
				item:chargeCrystalStoneEnergy(GamePlayConfig_CrystalEnergy_Normal)
				-- item.isNeedUpdate = true

				local theAction = GameBoardActionDataSet:createAs(
					GameActionTargetType.kGameItemAction,
					GameItemActionType.kItemSpecial_CrystalStone_Charge,
					IntCoord:create(fr,fc), 			
					IntCoord:create(r,c),				
					GamePlayConfig_MaxAction_time
					)
				theAction.addInt1 = item._encrypt.ItemColorType
				theAction.addInt2 = item:getCrystalStoneEnergy()
				mainLogic:addDestructionPlanAction(theAction)
				GameBoardLogic:setNeedCheckFalling()
			end
		end
	end
end

function GameExtandPlayLogic:doAllBlocker195Collect(mainLogic, pr, pc, collectType)--同类星星瓶收集
	if mainLogic.theGamePlayStatus ~= GamePlayStatus.kNormal then
		return
	end

	for r = 1, #mainLogic.gameItemMap do
		for c = 1, #mainLogic.gameItemMap[r] do
			local item = mainLogic.gameItemMap[r][c]
			GameExtandPlayLogic:doABlocker195Collect(mainLogic, item, pr, pc, r, c, collectType, 1, 1)
		end
	end
end

function GameExtandPlayLogic:doABlocker195Collect(mainLogic, item, pr, pc, r, c, collectType, increment, playFlying, forceCharge)--单个星星瓶收集
	--if _G.isLocalDevelopMode then printx(0, 'hjh', 'GameExtandPlayLogic:doABlocker195Collect', collectType) end
	if item and item:candoBlocker195Collect(collectType, forceCharge) and not item.isBlocker195Lock then
		-- printx(11, "=== doABlocker195Collect", pr, pc, r, c, collectType, increment, playFlying, forceCharge)
		if forceCharge then
			collectType = item.subtype
			increment = mainLogic.blocker195Nums[collectType]
		end

		item.level = item.level + increment
		local percent = item.level / mainLogic.blocker195Nums[collectType]
		if percent >= 1 then 
			item.isActive = true
			ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_Blocker195, ObstacleFootprintAction.k_Active, 1)
		end

		local theAction = GameBoardActionDataSet:createAs(
			GameActionTargetType.kGameItemAction,
			GameItemActionType.kItem_Blocker195_Collect,
			IntCoord:create(pr,pc), 			
			IntCoord:create(r,c),				
			GamePlayConfig_MaxAction_time)
		theAction.addInt1 = percent
		theAction.addInt2 = playFlying
		theAction.collectType = collectType
		mainLogic:addDestructionPlanAction(theAction)
	end
end

function GameExtandPlayLogic:itemDestroyHandler(mainLogic, r, c)
	local gameItem = mainLogic.gameItemMap[r][c]

	if mainLogic.gameMode:is(MoleWeeklyRaceMode) then 	--去掉需要有boss的限制
		local boardItem = mainLogic.boardmap[r][c]
		if boardItem and boardItem.magicTileId ~= nil and boardItem.magicTileDisabledRound <= 0 then
			if gameItem.ItemType == GameItemType.kAnimal 
				or gameItem.ItemType == GameItemType.kAddMove
				or gameItem.ItemType == GameItemType.kAddTime
				or gameItem.ItemType == GameItemType.kGift
				or gameItem.ItemType == GameItemType.kNewGift
				or gameItem.ItemType == GameItemType.kCrystal
				or gameItem.ItemType == GameItemType.kBalloon then
					-- printx(11, "===== ======= ======= Hit magicTile at: r, c: ("..r..","..c..")")
					-- printx(11, "boardItem.magicTileDisabledRound:", boardItem.magicTileDisabledRound)
					GameExtandPlayLogic:onMagicTileHit(mainLogic, r, c)
			end
		end
	end

	if gameItem.ItemType == GameItemType.kGift or gameItem.ItemType == GameItemType.kNewGift then
		GameExtandPlayLogic:bombGiftBlocker(mainLogic, r, c , gameItem )
		mainLogic.hasDestroyGift = true
	elseif gameItem.ItemType == GameItemType.kCoin then
		if not _G.IS_PLAY_NATIONDAY2017_LEVEL then
			GamePlayMusicPlayer:playEffect(GameMusicType.kPlayCoinCollect)
		end
		mainLogic.coinDestroyNum = mainLogic.coinDestroyNum + 1
		
		mainLogic:tryDoOrderList(r,c,GameItemOrderType.kSpecialTarget, GameItemOrderType_ST.kCoin, 1)
		SnailLogic:SpecialCoverSnailRoadAtPos( mainLogic, r, c )
		GameExtandPlayLogic:doAllBlocker195Collect(mainLogic, r, c, Blocker195CollectType.kCoin)
		SquidLogic:checkSquidCollectItem(mainLogic, r, c, TileConst.kCoin)
		ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_Coin, ObstacleFootprintAction.k_Eliminate, 1)
	elseif gameItem.ItemType == GameItemType.kBlocker207 then
		SnailLogic:SpecialCoverSnailRoadAtPos( mainLogic, r, c)
		GameExtandPlayLogic:destroyBlocker207(mainLogic , r , c)
	elseif gameItem.ItemType  == GameItemType.kBalloon then
		if mainLogic.theGamePlayStatus == GamePlayStatus.kNormal  then           ----只在bonus前作用有效果
			mainLogic.theCurMoves = mainLogic.theCurMoves + 5
			mainLogic.hasAddMoveStep = { source = "Balloon" , steps = 5 }
			ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_Balloon, ObstacleFootprintAction.k_AddStep, 5)
			if mainLogic.PlayUIDelegate then
				local function callback( ... )
					mainLogic.PlayUIDelegate:setMoveOrTimeCountCallback(mainLogic.theCurMoves, false)
				end
				local pos = mainLogic:getGameItemPosInView_ForPreProp(r,c)
				local icon = Sprite:createWithSpriteFrameName("add_move_icon.png")
				local scene = Director:sharedDirector():getRunningScene()
				local animation= PrefixPropAnimation:createAddMoveAnimation(icon, 0, callback, nil, ccp(pos.x, pos.y + 100))
				scene:addChild(animation)
			end
			tryWarp( GameItemType.kBalloon , 5 )
		end
	elseif gameItem.ItemType == GameItemType.kDigJewel then
		if mainLogic.theGamePlayType == GameModeTypeId.DIG_MOVE_ID then
			mainLogic.digJewelLeftCount = mainLogic.digJewelLeftCount - 1
			if mainLogic.PlayUIDelegate then
				local position = mainLogic:getGameItemPosInView(r, c)
				mainLogic.PlayUIDelegate:setTargetNumber(0, 0, mainLogic.digJewelLeftCount, position)
			end
		elseif mainLogic.theGamePlayType == GameModeTypeId.DIG_MOVE_ENDLESS_ID 
			or mainLogic.theGamePlayType == GameModeTypeId.MAYDAY_ENDLESS_ID 
			or mainLogic.theGamePlayType == GameModeTypeId.HALLOWEEN_ID
			or mainLogic.theGamePlayType == GameModeTypeId.WUKONG_DIG_ENDLESS_ID
			or mainLogic.theGamePlayType == GameModeTypeId.MOLE_WEEKLY_RACE_ID
			then
			mainLogic.digJewelCount:setValue(mainLogic.digJewelCount:getValue() + 1)
			if mainLogic.PlayUIDelegate then
				local position = mainLogic:getGameItemPosInView(r, c)
				mainLogic.PlayUIDelegate:setTargetNumber(0, 0, mainLogic.digJewelCount:getValue(), position)
			end

			if mainLogic.theGamePlayType == GameModeTypeId.WUKONG_DIG_ENDLESS_ID then
				mainLogic.gameMode:chargeByDigJewel(position)
			end
		elseif mainLogic.theGamePlayType == GameModeTypeId.HEDGEHOG_DIG_ENDLESS_ID then
			mainLogic.digJewelCount:setValue(mainLogic.digJewelCount:getValue() + 1)
			if mainLogic.gameMode:canAddEnerge() then
				mainLogic.gameMode:addEnergeCount(1)
			end
			if mainLogic.PlayUIDelegate then
				local position = mainLogic:getGameItemPosInView(r, c)
				mainLogic.PlayUIDelegate:setTargetNumber(0, 1, mainLogic.digJewelCount:getValue(), position, nil, nil, mainLogic.gameMode:getPercentEnerge())
			end
		end
	elseif gameItem.ItemType == GameItemType.kAddMove then
		if mainLogic.theGamePlayStatus == GamePlayStatus.kNormal then           ----只在bonus前作用有效果
			mainLogic.theCurMoves = mainLogic.theCurMoves + gameItem.numAddMove
			mainLogic.hasAddMoveStep = { source = "AddMoveItem" , steps = gameItem.numAddMove }
			
			if mainLogic.gameMode:is(SpringHorizontalEndlessMode) then
				mainLogic.gameMode:logAddStep(gameItem.numAddMove)
			end

			if mainLogic.PlayUIDelegate then
				local function callback( ... )
					mainLogic.PlayUIDelegate:setMoveOrTimeCountCallback(mainLogic.theCurMoves, false)
				end
				local pos = mainLogic:getGameItemPosInView_ForPreProp(r, c)
				local icon = TileAddMove:createAddStepIcon(gameItem.numAddMove)
				local scene = Director:sharedDirector():getRunningScene()
				local endPosDelta
				if mainLogic.levelType == GameLevelType.kSummerWeekly then 
					endPosDelta = {0, 50}
				end
				local animation = PrefixPropAnimation:createAddMoveAnimation(icon, 0, callback, nil, ccp(pos.x, pos.y + 90), nil, endPosDelta)
				scene:addChild(animation)
			end
			tryWarp( GameItemType.kAddMove , gameItem.numAddMove )
		end
	elseif gameItem.ItemType == GameItemType.kBlackCuteBall then 
		mainLogic:tryDoOrderList(r,c,GameItemOrderType.kOthers, GameItemOrderType_Others.kBlackCuteBall, 1)
	elseif gameItem.ItemType == GameItemType.kBoss then
		local count = gameItem.drop_sapphire
		mainLogic.digJewelCount:setValue(mainLogic.digJewelCount:getValue() + count)
		mainLogic.maydayBossCount = mainLogic.maydayBossCount + 1
		if mainLogic.PlayUIDelegate then
			local position = mainLogic:getGameItemPosInView(r, c)
			for k = 1, count do 
				mainLogic.PlayUIDelegate:setTargetNumber(0, 1, mainLogic.digJewelCount:getValue(), position)
			end
			mainLogic.PlayUIDelegate:setTargetNumber(0, 2, mainLogic.maydayBossCount, position)
		end
	elseif gameItem.ItemType == GameItemType.kWeeklyBoss then
		local count = gameItem.drop_sapphire
		mainLogic.digJewelCount:setValue(mainLogic.digJewelCount:getValue() + count)
		-- mainLogic.maydayBossCount = mainLogic.maydayBossCount + 1
		if mainLogic.PlayUIDelegate then
			local position = mainLogic:getGameItemPosInView(r, c)
			for k = 1, count do 
				mainLogic.PlayUIDelegate:setTargetNumber(0, 1, mainLogic.digJewelCount:getValue(), position)
			end
			mainLogic.PlayUIDelegate:setTargetNumber(0, 2, mainLogic.maydayBossCount, position)
		end
	elseif gameItem.ItemType == GameItemType.kMoleBossCloud then
		local count = gameItem.drop_sapphire
		mainLogic.digJewelCount:setValue(mainLogic.digJewelCount:getValue() + count)
		if mainLogic.PlayUIDelegate then
			local position = mainLogic:getGameItemPosInView(r, c)
			for k = 1, count do 
				mainLogic.PlayUIDelegate:setTargetNumber(0, 1, mainLogic.digJewelCount:getValue(), position)
			end
			mainLogic.PlayUIDelegate:setTargetNumber(0, 2, mainLogic.maydayBossCount, position)
		end
	elseif gameItem.ItemType == GameItemType.kChestSquare then
		local count = gameItem.drop_sapphire
		mainLogic.digJewelCount:setValue(mainLogic.digJewelCount:getValue() + count)
		if mainLogic.PlayUIDelegate then
			local position = mainLogic:getGameItemPosInView(r, c)
			for k = 1, count do 
				mainLogic.PlayUIDelegate:setTargetNumber(0, 1, mainLogic.digJewelCount:getValue(), ccp(position.x + 40,position.y - 55))
			end
			mainLogic.PlayUIDelegate:setTargetNumber(0, 2, mainLogic.maydayBossCount, position)
		end
	elseif gameItem.ItemType == GameItemType.kRabbit and gameItem.rabbitState ~= GameItemRabbitState.kNoTarget then
		mainLogic.rabbitCount:setValue(mainLogic.rabbitCount:getValue() + gameItem.rabbitLevel)
		if mainLogic.PlayUIDelegate  then
			local position = mainLogic:getGameItemPosInView(r, c)
			mainLogic.PlayUIDelegate:setTargetNumber(0, 0, mainLogic.rabbitCount:getValue(), position)
		end
	elseif gameItem.ItemType == GameItemType.kAddTime then
		if mainLogic.theGamePlayStatus == GamePlayStatus.kNormal then           ----只在bonus前作用有效果
			if mainLogic.PlayUIDelegate then
				local addTime = gameItem.addTime
				mainLogic.flyingAddTime = mainLogic.flyingAddTime + 1
				local function callback( ... )
					if __WIN32 and _G.launchCmds and _G.launchCmds.ingame then
						addTime = addTime / 10
					end
					mainLogic:addExtraTime(addTime)
					mainLogic.flyingAddTime = mainLogic.flyingAddTime - 1

					local timeLeft = mainLogic:getTotalLimitTime() - mainLogic.timeTotalUsed
					timeLeft = math.ceil(timeLeft)
					if timeLeft <= 0 then timeLeft = 0 end
					mainLogic.PlayUIDelegate:setMoveOrTimeCountCallback(timeLeft, false)

					ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_AddTime, ObstacleFootprintAction.k_Eliminate, 1)
				end
				local pos = mainLogic:getGameItemPosInView_ForPreProp(r, c)
				local icon = TileAddTime:createAddTimeIcon(addTime)
				local scene = Director:sharedDirector():getRunningScene()
				local animation = PrefixPropAnimation:createAddTimeAnimation(icon, 0, callback, nil, ccp(pos.x, pos.y + 90))
				scene:addChild(animation)
			end
		end
	elseif gameItem.ItemType == GameItemType.kRocket and mainLogic.hasDropDownUFO then
		GameExtandPlayLogic:fireRocket(mainLogic, r, c, gameItem._encrypt.ItemColorType)
    elseif gameItem.ItemType == GameItemType.kYellowDiamondGrass then
        --黄宝石收集
        mainLogic.yellowDiamondCount:setValue(mainLogic.yellowDiamondCount:getValue() + 1)

        local position = mainLogic:getGameItemPosInView(r, c)
        mainLogic.PlayUIDelegate:YellowDiamondFly( 1,position )
	end

	if gameItem.hasActCollection then 
		gameItem.hasActCollection = false 	--防止重复收集 比如魔力鸟和直线交换 将带收集物的小动物变为特效
		mainLogic.actCollectionNum = mainLogic.actCollectionNum + 1

        if CountdownPartyManager.getInstance():isActivitySupport() or 
            DragonBuffManager.getInstance():isActivitySupport() then

		    ActCollectionLogic:playGetFlyAni(r, c)
        end

--        if Qixi2018CollectManager.getInstance():isActivitySupport()
--            or Qixi2018CollectManager.getInstance():isActivityOppoRankSupport() then
--            --七夕收集不飞到宝箱。单独制作
--            ActCollectionLogic:playGetFlyAniExForQixi(r, c)
--        end

        if Thanksgiving2018CollectManager.getInstance():isActivitySupport() then
            --收集不飞到宝箱。单独制作
            ActCollectionLogic:playGetFlyAniExForQixi(r, c)
        end
	end
end

-- 销毁礼包，获得道具
function GameExtandPlayLogic:bombGiftBlocker(mainLogic, r, c , gameItem)
	if mainLogic.PlayUIDelegate then
		-- 新礼盒逻辑
		if (gameItem.dropProps) then
			local props = gameItem.dropProps
			local propsArray = splite(props,",")

			-- 根据权重掉落,如果配置的权重是很大的数字，可能会造成效率低下。。。
			local weightArray = {}

			for i,v in ipairs(propsArray) do
				local propItem = splite(v,"_")
				local propId = tonumber(propItem[1])
				local propWeight = tonumber(propItem[2])

				for j=1,tonumber(propWeight) do
					table.insert(weightArray,propId)
				end
			end
			local randId = mainLogic.randFactory:rand(1,#weightArray)
			local giftItemId = weightArray[randId]
			local pos = mainLogic:getGameItemPosInView(r, c)
			mainLogic.PlayUIDelegate:addTemporaryItem(giftItemId, 1, pos)
			ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_Gift, ObstacleFootprintAction.k_List, 1, giftItemId)

			-- 记录打开礼盒获得的ItemId，用于使用回退道具回滚
			mainLogic:setRevertGiftInfo(giftItemId,gameItem.key)
		-- -- 老礼盒逻辑
		else
			local giftBlockerMeta = MetaManager.getInstance():getGiftBlockerByLevelId(mainLogic.level)
			if giftBlockerMeta then
				local giftItemIdList = giftBlockerMeta.prop_id
				local giftItemId = giftItemIdList[mainLogic.randFactory:rand(1, #giftItemIdList)]
				local pos = mainLogic:getGameItemPosInView(r, c)
				mainLogic.PlayUIDelegate:addTemporaryItem(giftItemId, 1, pos)
				ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_Gift, ObstacleFootprintAction.k_List, 1, giftItemId)

				-- 记录打开礼盒获得的ItemId，用于使用回退道具回滚
				mainLogic:setRevertGiftInfo(giftItemId,gameItem.key)
			else
				mainLogic.randFactory:rand(1, 10)
			end
		end
	else
		mainLogic.randFactory:rand(1, 10)
	end
end

function GameExtandPlayLogic:CheckBalloonList( mainLogic, completeCallback )
	-- body
	local balloonList = {}
	local balloonTotal = 0
	for r = 1, #mainLogic.gameItemMap do 
		for c = 1, #mainLogic.gameItemMap[r] do
			local itemdata = mainLogic.gameItemMap[r][c]
			if itemdata:isAvailable() and itemdata.ItemType == GameItemType.kBalloon
			and itemdata.beEffectByMimosa == 0 then
				if itemdata.isFromProductBalloon then
					itemdata.isFromProductBalloon = false
				else
					balloonTotal = balloonTotal + 1
					itemdata.balloonFrom = itemdata.balloonFrom - 1
					if itemdata.balloonFrom > 0 then
						GameExtandPlayLogic:updateBalloonStepNumber(mainLogic, r, c, completeCallback)
					else
						GameExtandPlayLogic:runAwayAllBalloon(mainLogic, r, c, completeCallback)
					end
				end
			end
		end
	end
	return balloonTotal
end

----更新气球的剩余步数
function GameExtandPlayLogic:updateBalloonStepNumber( mainLogic, r, c, completeCallback)
	-- body
	
	local balloonUpdateNumberAction = GameBoardActionDataSet:createAs(
				GameActionTargetType.kGameItemAction,
				GameItemActionType.kItem_Balloon_update,
				IntCoord:create(r,c),
				nil,
				GamePlayConfig_Balloon_Update_time
			)

	balloonUpdateNumberAction.numberShow = mainLogic.gameItemMap[r][c].balloonFrom
	balloonUpdateNumberAction.completeCallback = completeCallback
	mainLogic:addGameAction(balloonUpdateNumberAction)
end


--气球飞走
function GameExtandPlayLogic:runAwayAllBalloon( mainLogic, r, c, completeCallback )
	-- body
	local balloonRunAwayAction = GameBoardActionDataSet:createAs(
		GameActionTargetType.kGameItemAction,
		GameItemActionType.kItem_balloon_runAway,
		IntCoord:create(r, c),
		nil,
		GamePlayConfig_Balloon_Runaway_time)
	
	balloonRunAwayAction.completeCallback = completeCallback
	mainLogic:addGameAction(balloonRunAwayAction)
	
end
---------------
--地块削减一层
---------------
function GameExtandPlayLogic:decreaseDigGround( mainLogic, r, c, scoreScale, noScore )
	-- body
	scoreScale = scoreScale or 1
	local item = mainLogic.gameItemMap[r][c]
	item.digGroundLevel = item.digGroundLevel - 1
	ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_DigGround, ObstacleFootprintAction.k_Hit, 1)

	if item.digGroundLevel == 0 then
		SnailLogic:SpecialCoverSnailRoadAtPos( mainLogic, r, c )
		item:AddItemStatus(GameItemStatusType.kDestroy)
	end

	if not noScore then
		local addScore = GamePlayConfigScore.MatchAtDigGround * scoreScale
		mainLogic:addScoreToTotal(r, c, addScore)
	end

	 local digGroudDecAction = GameBoardActionDataSet:createAs(
	 		GameActionTargetType.kGameItemAction,
	 		GameItemActionType.kItem_DigGroundDec,
	 		IntCoord:create(r,c),
	 		nil,
	 		GamePlayConfig_GameItemDigGroundDeleteAction_CD)
	 digGroudDecAction.cleanItem = item.digGroundLevel == 0 and true or false
	 mainLogic:addDestroyAction(digGroudDecAction)
end

--------------------
--宝石块削减一层
--------------------
function GameExtandPlayLogic:decreaseDigJewel( mainLogic, r, c, scoreScale, noScore, isFromSpringBomb )
	-- body
	scoreScale = scoreScale or 1
	local item = mainLogic.gameItemMap[r][c]
	item.digJewelLevel = item.digJewelLevel -1
	ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_DigGround, ObstacleFootprintAction.k_Hit, 1)

	if item.digJewelLevel == 0 then
		if mainLogic.theGamePlayType == 12 and not isFromSpringBomb then
			mainLogic:chargeFirework(1, r, c)
		end
		SnailLogic:SpecialCoverSnailRoadAtPos( mainLogic, r, c )
		item:AddItemStatus(GameItemStatusType.kDestroy)
	end

	if not noScore then
		local baseScore = GamePlayConfigScore.MatchAt_DigJewel
		if mainLogic.levelType == GameLevelType.kMoleWeekly then
			baseScore = MoleWeeklyRaceParam.JEWEL_CLOUD_SCORE
		end
		local addScore = baseScore * scoreScale
		mainLogic:addScoreToTotal(r, c, addScore)
	end
	
	local digJewelDecAction = GameBoardActionDataSet:createAs(
	 		GameActionTargetType.kGameItemAction,
	 		GameItemActionType.kItem_DigJewleDec,
	 		IntCoord:create(r,c),
	 		nil,
	 		GamePlayConfig_GameItemDigJewelDeleteAction_CD)
	digJewelDecAction.cleanItem = item.digJewelLevel == 0 and true or false
	mainLogic:addDestroyAction(digJewelDecAction)
end

--------------------
--黄宝石块削减一层
--------------------
function GameExtandPlayLogic:decreaseYellowDiamond( mainLogic, r, c, scoreScale, noScore, isFromSpringBomb )
	-- body
	scoreScale = scoreScale or 1
	local item = mainLogic.gameItemMap[r][c]
	item.yellowDiamondLevel = item.yellowDiamondLevel -1

	if item.yellowDiamondLevel == 0 then
		if mainLogic.theGamePlayType == 12 and not isFromSpringBomb then
			mainLogic:chargeFirework(1, r, c)
		end
		SnailLogic:SpecialCoverSnailRoadAtPos( mainLogic, r, c )
		item:AddItemStatus(GameItemStatusType.kDestroy)
	end

	if not noScore then
		local baseScore = GamePlayConfigScore.MatchAt_YellowDiamond
		if mainLogic.levelType == GameLevelType.kMoleWeekly then
			baseScore = MoleWeeklyRaceParam.JEWEL_CLOUD_SCORE
		end
		local addScore = baseScore * scoreScale
		mainLogic:addScoreToTotal(r, c, addScore)
	end
	
	local YellowDiamondDecAction = GameBoardActionDataSet:createAs(
	 		GameActionTargetType.kGameItemAction,
	 		GameItemActionType.kItem_YellowDiamondDec,
	 		IntCoord:create(r,c),
	 		nil,
	 		GamePlayConfig_GameItemYellowDiamondDeleteAction_CD)
	YellowDiamondDecAction.cleanItem = item.yellowDiamondLevel == 0 and true or false
	mainLogic:addDestroyAction(YellowDiamondDecAction)
end

--function GameExtandPlayLogic:dripCasting( mainLogic, r, c, isLeader, leaderPos )
function GameExtandPlayLogic:dripCasting( mainLogic, dripList , callback )
	printx( 1 , "   GameExtandPlayLogic:dripCasting  !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
	if mainLogic and dripList and #dripList > 0 then

		local countCallback = 0
		local totalCallback = 0

		local function onActivityComplete()

			countCallback = countCallback + 1
			--printx( 1 , "   GameExtandPlayLogic:dripCasting   onActivityComplete    " , countCallback , "   totalCallback " , totalCallback)
			if countCallback >= totalCallback then
				if callback then callback() end
			end
		end
		for i = 1 , #dripList do

			local item = dripList[i]

			--printx( 1 , "   RRR   GameExtandPlayLogic:dripCasting    dripList " , i , item.startDripCastingAction)
			if not item.startDripCastingAction then
				GameExtandPlayLogic:__dripCasting( mainLogic, item.y , item.x , onActivityComplete )
				totalCallback = totalCallback + 1
			end
			
			--[[
			local dripCastingAction = GameBoardActionDataSet:createAs(
		 		GameActionTargetType.kGameItemAction,
		 		GameItemActionType.kItem_Drip_Casting,
		 		IntCoord:create( item.y , item.x ),
		 		nil,
		 		GamePlayConfig_MaxAction_time)

			dripCastingAction.completeCallback = onActivityComplete
			
			mainLogic:addDestructionPlanAction(dripCastingAction)
			mainLogic:setNeedCheckFalling()	
			]]
		end

		

	end
end

function GameExtandPlayLogic:__dripCasting(  mainLogic, r, c , callback )
	
	local item = mainLogic.gameItemMap[r][c]
	printx( 1 , "    GameExtandPlayLogic:__dripCasting   " , r, c , item.startDripCastingAction )
	if item.startDripCastingAction == true then
		--return
	end

	item.startDripCastingAction = true

	local dripCastingAction = GameBoardActionDataSet:createAs(
 		GameActionTargetType.kGameItemAction,
 		GameItemActionType.kItem_Drip_Casting,
 		IntCoord:create( item.y , item.x ),
 		nil,
 		GamePlayConfig_MaxAction_time)

	dripCastingAction.completeCallback = function () if callback then callback() end end
	
	if _G.test_DripMode == 2 then
		--mainLogic:addGameAction(dripCastingAction)
		mainLogic:addDestructionPlanAction(dripCastingAction)
	else
		mainLogic:addDestructionPlanAction(dripCastingAction)
	end
	
	mainLogic:setNeedCheckFalling()	

end

function GameExtandPlayLogic:decreaseLotus(mainLogic, r, c, scoreScale, noScore)
	local item = mainLogic.gameItemMap[r][c]
	local board = mainLogic.boardmap[r][c]

	if board.lotusLevel > 0 and not board.isJustEffectByFilter then
		if (item.ItemType == GameItemType.kTotems and item.totemsState == GameItemTotemsState.kActive) 
			or (item.ItemType == GameItemType.kPuffer and item.pufferState == PufferState.kNormal)
			or item.ItemType == GameItemType.kChameleon
			or item.ItemType == GameItemType.kPacman
			then
			return
		end

		local lotusDecAction = GameBoardActionDataSet:createAs(
		 		GameActionTargetType.kGameItemAction,
		 		GameItemActionType.kItem_Decrease_Lotus,
		 		IntCoord:create(r,c),
		 		nil,
		 		GamePlayConfig_MaxAction_time)
		lotusDecAction.originLotusLevel = board.lotusLevel

		mainLogic:addDestroyAction(lotusDecAction)
	end
end

function GameExtandPlayLogic:decreasePuffer( mainLogic, r, c , scoreScale , noScore)
	--crash.crash()
	local item = mainLogic.gameItemMap[r][c]

	if item.ItemType == GameItemType.kPuffer 
		and ( item.ItemStatus == GameItemStatusType.kItemHalfStable or item.ItemStatus == GameItemStatusType.kNone or item.ItemStatus == GameItemStatusType.kJustArrived )
		and ( item.pufferState == PufferState.kNormal or item.pufferState == PufferState.kActivated ) then
		--printx( 1 , "   GameExtandPlayLogic:decreasePuffer  " , r, c , "  item.pufferState = " , item.pufferState)
		if item.pufferState == PufferState.kNormal then

			item.pufferState = PufferState.kGrow
			mainLogic:checkItemBlock(r,c)
			--item.isNeedUpdate = true

			local pufferActiveAction = GameBoardActionDataSet:createAs(
			 		GameActionTargetType.kGameItemAction,
			 		GameItemActionType.kItem_Puffer_Active,
			 		IntCoord:create(r,c),
			 		nil,
			 		GamePlayConfig_MaxAction_time)
			--printx( 1 , "   item.pufferState == PufferState.kNormal")
			mainLogic:addDestructionPlanAction(pufferActiveAction)

		elseif item.pufferState == PufferState.kActivated then

			item.pufferState = PufferState.kExplode
			mainLogic:checkItemBlock(r,c)
			item.isNeedUpdate = true
			
			local pufferExplodeAction = GameBoardActionDataSet:createAs(
			 		GameActionTargetType.kGameItemAction,
			 		GameItemActionType.kItem_Puffer_Explode,
			 		IntCoord:create(r,c),
			 		nil,
			 		GamePlayConfig_MaxAction_time)
			--printx( 1 , "   item.pufferState == PufferState.kActivated")
			mainLogic:addDestructionPlanAction(pufferExplodeAction)

			mainLogic:tryDoOrderList(r, c, GameItemOrderType.kOthers, GameItemOrderType_Others.kBoomPuffer, 1)
			ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_Puffer, ObstacleFootprintAction.k_Eliminate, 1)
		end
		mainLogic:setNeedCheckFalling()	
	end
end

function GameExtandPlayLogic:decreaseBottleBlocker( mainLogic, r, c , scoreScale , noScore, decreaseAll)
	local item = mainLogic.gameItemMap[r][c]
	
	if item.bottleLevel == 0 then
		return
	end

	local decreaseVal = 1
	if decreaseAll then
		decreaseVal = item.bottleLevel
	end

	item.bottleLevel = item.bottleLevel - decreaseVal
	ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_BottleBlocker, ObstacleFootprintAction.k_Hit, 1)

	if item.bottleLevel == 0 then
		item.bottleState = BottleBlockerState.ReleaseSpirit
		ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_BottleBlocker, ObstacleFootprintAction.k_Eliminate, decreaseVal)
		mainLogic:tryDoOrderList(r, c, GameItemOrderType.kSpecialTarget, GameItemOrderType_ST.kBottleBlocker, 1)
	else
		item.bottleState = BottleBlockerState.HitAndChanging
	end

	if not noScore then
		scoreScale = scoreScale or 1
		local addScore = scoreScale * GamePlayConfigScore.MatchBySnow
		mainLogic:addScoreToTotal(r, c, addScore, item._encrypt.ItemColorType)
	end

	local bottleBlockerDecAction = GameBoardActionDataSet:createAs(
	 		GameActionTargetType.kGameItemAction,
	 		GameItemActionType.kItem_Bottle_Blocker_Explode,
	 		IntCoord:create(r,c),
	 		nil,
	 		GamePlayConfig_MaxAction_time)
	bottleBlockerDecAction.oldColor = item._encrypt.ItemColorType
	bottleBlockerDecAction.oldState = item.bottleState
	bottleBlockerDecAction.newBottleLevel = item.bottleLevel

	mainLogic:addDestroyAction(bottleBlockerDecAction)
end

--随机一个可用的颜色。规则：关卡内有的颜色且尽量不造成三消且和当前位于r，c的Item的ItemColorType不一致
function GameExtandPlayLogic:getRandomColorByDefaultLogic( mainLogic, r, c )

	local resultColor = AnimalTypeConfig.kBlue

	local item = mainLogic.gameItemMap[r][c]

	if item then

		local levelColors = {}
		for i = 1, #mainLogic.mapColorList do 
			table.insert( levelColors , mainLogic.mapColorList[i] )
		end

		if levelColors and #levelColors > 0 then
			local size = #levelColors
			local selfColorIndex = 0
			for i = 1, size do
				if item._encrypt.ItemColorType == levelColors[i] then
					selfColorIndex = i
				end
			end

			if selfColorIndex > 0 then
				table.remove( levelColors , selfColorIndex )
			end

			local possibleColors = {}
			local k,v
			for k, v in pairs(levelColors) do 
				if not mainLogic:checkMatchQuick(r, c, v) and not ColorFilterLogic:checkColorMatch(r, c, v) then
					table.insert(possibleColors, v)
				end
			end

			if #possibleColors > 0 then
				resultColor = possibleColors[ mainLogic.randFactory:rand(1, #possibleColors) ]
			else
				resultColor = levelColors[ mainLogic.randFactory:rand(1, #levelColors) ]
			end
		end
	end

	return resultColor
end

--随机妖精瓶子的颜色。规则：关卡内有的颜色且尽量不造成三消且和当前的ItemColorType不一致
function GameExtandPlayLogic:randomBottleBlockerColor( mainLogic, r, c )

	local item = mainLogic.gameItemMap[r][c]

	if item and item.ItemType == GameItemType.kBottleBlocker then
		return GameExtandPlayLogic:getRandomColorByDefaultLogic(mainLogic, r, c)
	end

	return AnimalTypeConfig.kBlue
end

function GameExtandPlayLogic:updateItemsEffectedByUFO(mainLogic)
	if mainLogic.hasDropDownUFO then
		local itemMap = mainLogic.gameItemMap
		local baseMap = mainLogic.boardView.baseMap
		for r = 1, #itemMap do
			for c = 1 ,#itemMap[r] do 
				local itemdata = itemMap[r][c]
				if itemdata and itemdata:canBeEffectByUFO() then
					local isDangerours = GameExtandPlayLogic:isItemInDanger(mainLogic, r, c)
					baseMap[r][c]:updateDangerousStatus(isDangerours)
				end
			end
		end
	end
end

--获取ufo的位置
function GameExtandPlayLogic:getUFOPosition( mainLogic )
	-- body
	local r_ufo = 10
	local c_ufo = 1
	local itemMap = mainLogic.gameItemMap
	for r = 1, #itemMap do
		for c = 1 ,#itemMap[r] do 
			local itemdata = itemMap[r][c]
			if itemdata:canBeEffectByUFO() then 
				if r < r_ufo then 
					r_ufo = r c_ufo = c 
				elseif r == r_ufo then 
					local r_up = GameExtandPlayLogic:upstairsItemsByUfo(mainLogic, itemMap, r, c )
					local r_ufo_up = GameExtandPlayLogic:upstairsItemsByUfo(mainLogic, itemMap, r_ufo, c_ufo )
					if r_ufo_up < 0 then
						if r_up > 0 then r_ufo = r c_ufo = c end
					elseif r_up < r_ufo_up and r_up > 0 then 
						r_ufo = r c_ufo = c
					end
				end
			end
		end
	end
	local oldPos = mainLogic:getGameItemPosInView(1, c_ufo)
	return ccp(oldPos.x, oldPos.y + 20), IntCoord:create(1, c_ufo) -- y+20为飞碟提供坠落空间
end

function GameExtandPlayLogic:getSquirrelPosYinBoard( mainLogic, old_c )
	-- body
	local r_squirrel = 1
	local c_squirrel = 10
	local itemMap = mainLogic.gameItemMap
	for r = 1, #itemMap do 
		for c = 1, #itemMap[r] do 
			local itemData = itemMap[r][c]
			if itemData:canBeEffectByUFO() then 
				if  r_squirrel <= r then 
					r_squirrel = r c_squirrel = c
				end
			end
		end
	end

	local isDangerours = true
	if r_squirrel <= 3 then 
		isDangerours  = false
	end
	return c_squirrel, isDangerours
end


function GameExtandPlayLogic:resetRabbitItemState(mainLogic)
	for r = 1, #mainLogic.gameItemMap do
		for c = 1, #mainLogic.gameItemMap do 
			local item = mainLogic.gameItemMap[r][c]
			if item and item.rabbitState == GameItemRabbitState.kSpawn then 
				item:changeRabbitState(GameItemRabbitState.kNone)
			end
		end
	end
end

function GameExtandPlayLogic:recoverUFO(mainLogic)
	if mainLogic.hasDropDownUFO and not mainLogic.isUFOWin then -- 飞碟被击晕
		if mainLogic.UFOSleepCD > 0 then
			if mainLogic.UFOSleepCD < 3 then
				mainLogic.PlayUIDelegate:playUFORecoverAnimation()
			end
			mainLogic.oldUFOSleepCD = mainLogic.UFOSleepCD
			mainLogic.UFOSleepCD = mainLogic.UFOSleepCD - 1
		end
	end
end

function GameExtandPlayLogic:revertUFOToPreStatus(mainLogic)
	if mainLogic.hasDropDownUFO then
		-- 根据
		local oldStatus = UFOStatus.kNormal
		if mainLogic.oldUFOSleepCD == 2 then
			oldStatus = UFOStatus.kWakeUp
		elseif mainLogic.oldUFOSleepCD > 2 then
			oldStatus = UFOStatus.kStun
		end
		mainLogic.PlayUIDelegate:forceUpdateUFOStatus(oldStatus)
	end
end

-------------------
--check item can be effect by ufo
--------------------
function GameExtandPlayLogic:checkUFOItemUpdate( mainLogic, completeCallback )
	-- body
	local item_count = 0
	local item_top = false
	if mainLogic.gameMode:reachEndCondition() then ---产品的需求，如果达到胜利条件则 不再判断, 直接返回
		return item_count, item_top
	end
	if mainLogic.gameMode:is(RabbitWeeklyMode) and mainLogic.gameMode:isNeedChangeState(nil, false) then 
		return item_count, item_top
	end

	if mainLogic.UFOSleepCD > 0 then -- 飞碟被击晕
		return item_count, item_top
	end

	if mainLogic.hasDropDownUFO and not mainLogic.isUFOWin and mainLogic.theCurMoves > 0 then 
		local itemList = mainLogic.gameItemMap

		local itemList_copy = {}
		for r = 1, #itemList do 
			if not itemList_copy[r] then itemList_copy[r] = {} end
			for c = 1, #itemList[r] do 
				itemList_copy[r][c] = itemList[r][c]:copy()
			end
		end

		local hasTopItem = false
		for r = 1, #itemList_copy do 
			for c = 1, #itemList_copy[r] do 
				local item = itemList_copy[r][c]
				if item:canBeEffectByUFO() 
					and not item:hasLock()
					and item:isAvailable() and item.rabbitState ~= GameItemRabbitState.kSpawn then

					local r_up, isTop, isShowDangerous = GameExtandPlayLogic:upstairsItemsByUfo(mainLogic, itemList_copy, r, c )
					item.isTop = isTop
					if isTop then hasTopItem = true end
					item.isShowDangerous = isShowDangerous
					if r_up > 0 and not isTop then 
						itemList_copy[r][c] = itemList_copy[r_up][c]
						itemList_copy[r_up][c] = item
					end
				end
			end
		end

		for r = 1, #itemList_copy do 
			for c = 1,#itemList_copy[r] do
				local itemdata = itemList_copy[r][c]
				local canSendAction = false
				if hasTopItem then
					if itemdata.isTop then canSendAction = true  item_top = true end
				else
					if itemdata.y ~= r then canSendAction = true end
				end

				if canSendAction then 
					item_count = item_count + 1
					local intcoord2 = itemdata.isTop and IntCoord:create(1, c) or IntCoord:create(r, c)
					local itemForceToMoveAction = GameBoardActionDataSet:createAs(
							GameActionTargetType.kGameItemAction,
							GameItemActionType.kItem_ItemForceToMove,
							IntCoord:create(itemdata.y, c),
							intcoord2,
							GamePlayConfig_MaxAction_time
						)
					itemForceToMoveAction.completeCallback = completeCallback
					itemForceToMoveAction.isTop = itemdata.isTop
					itemForceToMoveAction.isShowDangerous = itemdata.isShowDangerous
					itemForceToMoveAction.isUfoLikeItem = itemdata:canBeEffectByUFO()
					mainLogic:addGameAction(itemForceToMoveAction)
				end 
			end
		end

		if item_count > 0 then 
			if mainLogic.PlayUIDelegate then
				mainLogic.PlayUIDelegate:playUFOPullAnimation(true)
			end
		else
			if mainLogic.PlayUIDelegate then
				mainLogic.PlayUIDelegate:playUFOPullAnimation(false)
			end
		end
	end
	return item_count, item_top

end

function GameExtandPlayLogic:isItemInDanger(mainLogic, r, c)
	local itemMap = mainLogic.gameItemMap
	local top_num = 1
	for k = 1, 9 do 
		if itemMap[k][c].isUsed then 
			top_num = k
			break
		end
	end
	if r - top_num < 2 then 
		return true 
	else 
		return false 
	end	
end
--------------------
--get upstairs r c  by ufo
--------------------
function GameExtandPlayLogic:upstairsItemsByUfo(mainLogic, itemList_copy, r, c )
	-- body
	local item = itemList_copy[r][c]
	local tempGoUpstairOneStep = r > 1 and itemList_copy[r-1][c]
	local tempGoUpstairTwoStep = r > 2 and itemList_copy[r-2][c]

	local function checkItemAvailable(item)
		if not item or not item.isUsed then return false end

		if item:hasLock()
			or item:hasFurball()
			or item:canBeEffectByUFO()
			or item.isBlock
			or item.ItemType == GameItemType.kNone then 
			return false
		else
			return true
		end
	end
	local canGoUpstairOneStep = false
	local canGoUpstairTwoStep = false
	if checkItemAvailable(tempGoUpstairOneStep) 
		and not mainLogic:hasChainInNeighbors(r, c, r-1, c) then
		canGoUpstairOneStep = true
	end
	if checkItemAvailable(tempGoUpstairTwoStep)
		and not mainLogic:hasChainInNeighbors(r, c, r-1, c)
		and not mainLogic:hasChainInNeighbors(r-1, c, r-2, c) then
		canGoUpstairTwoStep = true
	end
	
	local isTop = false
	local top_num = 1
	for k = 1, 9 do 
		if itemList_copy[k][c].isUsed then 
			top_num = k
			break
		end
	end
	if r == top_num then 
		isTop = true
	end

	local tempItem = nil
	local isShowDangerous = false
	if item.rabbitLevel > 1 and r >= 7 then
		if canGoUpstairTwoStep then
			if r-2 - top_num < 2 then isShowDangerous = true end
			return r - 2, false, isShowDangerous
		elseif canGoUpstairOneStep then 
			if r-1 - top_num < 2 then isShowDangerous = true end
			return r - 1, false, isShowDangerous
		elseif isTop then 
			return 1, true, isShowDangerous
		else
			return -1, false, isShowDangerous
		end
	else
		if canGoUpstairOneStep then 
			if r-1 - top_num < 2 then isShowDangerous = true end
			return r - 1, false, isShowDangerous
		elseif canGoUpstairTwoStep then
			if r-2 - top_num < 2 then isShowDangerous = true end
			return r - 2, false, isShowDangerous
		elseif isTop then 
			return 1, true, isShowDangerous
		else
			return -1, false, isShowDangerous
		end
	end

	
end

function GameExtandPlayLogic:choseItemToIngredient( mainLogic, r, c )
	-- body
	local min = 10
	local max = 0
	local item
	for k = 1, 9 do 
		item = mainLogic.gameItemMap[k][c]
		if item.isUsed then 
			if min > k then min = k end
			if max < k then max = k end
		end
	end

	for k = max - math.floor((max - min)/2), min, -1 do 
		item = mainLogic.gameItemMap[k][c]
		if item and (not item:hasLock()) and not item:hasFurball() and 
			(item.ItemType == GameItemType.kAnimal
			or item.ItemType == GameItemType.kCrystal
			or item.ItemType == GameItemType.kCoin) then
			return k, c
		end
	end
end

function GameExtandPlayLogic:reviveGame( mainLogic, callback)
	-- body
	local isRabbitWeeklyScene = LevelMapManager:getInstance():isRabbitWeeklyLevel(mainLogic.level)

	for k, v in pairs(mainLogic.UFOCollection) do 
		if isRabbitWeeklyScene then 
			local count = v.level > 1 and 2 or 1
			mainLogic.rabbitCount:setValue(mainLogic.rabbitCount:getValue() + count)
			if mainLogic.PlayUIDelegate then
				local position = mainLogic:getGameItemPosInView(v.r, v.c)
				mainLogic.PlayUIDelegate:setTargetNumber(0, 0, mainLogic.rabbitCount:getValue(), position)
			end
			if callback then callback() end
		else
			local r, c = GameExtandPlayLogic:choseItemToIngredient( mainLogic, v.r, v.c )
			if r and c then 
				local changeToIngredientAction = GameBoardActionDataSet:createAs(
					GameActionTargetType.kGameItemAction,
					GameItemActionType.kItem_ItemChangeToIngredient,
					IntCoord:create(r, c),
					IntCoord:create(v.r, v.c),
					GamePlayConfig_MaxAction_time
				)

				changeToIngredientAction.completeCallback = callback
				mainLogic:addGameAction(changeToIngredientAction)
			else
				if callback then callback() end
			end
		end
		
	end

	mainLogic.UFOCollection = {}

end

function GameExtandPlayLogic:CheckTileBlockerList(mainLogic, callback)
	-- body
	local count = 0
	local needPlaySound = false

	for r = 1, #mainLogic.boardmap do 
		for c = 1, #mainLogic.boardmap[r] do
			local boardData = mainLogic.boardmap[r][c]
			local itemData = mainLogic.gameItemMap[r][c]
			if itemData and not itemData:hasBlocker206() and not itemData:hasSquidLock() then --锁是第一个能干扰翻转地格的障碍
				if boardData:isRotationTileBlock() then 
					if boardData.reverseCount <= 0 then boardData.reverseCount = gTileBlockDefaultCount end
					boardData.reverseCount = boardData.reverseCount - 1
					if boardData.reverseCount == 0 then needPlaySound = true end
					count = count + 1

					local action = GameBoardActionDataSet:createAs(
									GameActionTargetType.kGameItemAction,
									GameItemActionType.kItem_TileBlocker_Update,
									IntCoord:create(r, c),
									nil,
									GamePlayConfig_MaxAction_time
								)

					action.completeCallback = callback
					action.coutDown = boardData.reverseCount
					action.isReverseSide = boardData.isReverseSide
					action.isRotationTileBlock = true
					mainLogic:addGameAction(action)
				end

				if boardData:isDoubleSideTileBlock() then 
					if boardData.reverseCount <= 0 then boardData.reverseCount = gTileBlockDefaultCount end
					boardData.reverseCount = boardData.reverseCount - 1
					count = count + 1

					local oldSide = boardData.side
					if boardData.reverseCount == 0 then
						if boardData.side == 1 then
							boardData.side = 2
						else
							boardData.side = 1
						end
						needPlaySound = true
					end

					local action = GameBoardActionDataSet:createAs(
										GameActionTargetType.kGameItemAction,
										GameItemActionType.kItem_DoubleSideTileBlocker_Update,
										IntCoord:create(r, c),
										nil,
										GamePlayConfig_MaxAction_time
									)

					action.completeCallback = callback
					action.coutDown = boardData.reverseCount
					action.oldSide = oldSide					
					action.newSide = boardData.side
					action.isDoubleSideTileBlock = true
					mainLogic:addGameAction(action)
				end
			end
		end 
	end

	if needPlaySound then
		GamePlayMusicPlayer:playEffect(GameMusicType.kTileBlockerTurn)
	end

	return count
end

function GameExtandPlayLogic:checkPM25(mainLogic, callback)
	local count = 0
	if mainLogic.pm25 > 0 then 
		mainLogic.pm25count = mainLogic.pm25count + 1
		if mainLogic.pm25count % mainLogic.pm25 == 0 then 
			--get all normal animals
			local itemList = {}
			for r = 1, #mainLogic.gameItemMap do 
				for c = 1, #mainLogic.gameItemMap[r] do 
					local item = mainLogic.gameItemMap[r][c]
					if (item.ItemType == GameItemType.kAnimal or item.ItemType == GameItemType.kCrystal)
						and item:isAvailable()
						and not item:hasLock() 
						and not item:hasFurball() 
						and item.ItemSpecialType == 0 then 
						table.insert(itemList, {r = r, c = c})
					end
				end
			end

			--random item
			for k = 1, GamePlayConfig_PM25_ChangeItem_Max_Count do 
				if #itemList > 0 then 
					local selected = table.remove(itemList, mainLogic.randFactory:rand(1, #itemList))
					local action = GameBoardActionDataSet:createAs(
						GameActionTargetType.kGameItemAction,
						GameItemActionType.kItem_PM25_Update,
						IntCoord:create(selected.r, selected.c),
						nil,
						GamePlayConfig_MaxAction_time
					)

					count = count + 1
					action.completeCallback = callback
					mainLogic:addGameAction(action)
				end
			end

		end
	end

	return count
end

-------------------------
--随机获取优先级为 普通动物，水晶球， 特效动物列表
--maxNum 获取的数量
-------------------------
function GameExtandPlayLogic:getRandomColorItems( mainLogic, maxNum )
	-- body
	local animal_normal_list = {}
	local crystal_list = {}
	local animal_special_list = {}
	for r = 1, #mainLogic.gameItemMap do 
		for c = 1, #mainLogic.gameItemMap[r] do 
			local item = mainLogic.gameItemMap[r][c]
			local board = mainLogic.boardmap[r][c]
			if item:isAvailable() and not item:hasLock() and not item:hasFurball() and not board:hasSuperCuteBall() then
				if item.ItemType == GameItemType.kAnimal then
					if item.ItemSpecialType == 0 then
						table.insert(animal_normal_list, {r=r, c=c})
					else
						table.insert(animal_special_list, {r=r, c=c})
					end
				elseif item.ItemType == GameItemType.kCrystal then
					table.insert(crystal_list, {r=r, c=c})
				end
			end
		end
	end

	local result = {}
	for k = 1, maxNum do 
		local item = table.remove(animal_normal_list, mainLogic.randFactory:rand(1, #animal_normal_list))
		if not item then 
			item = table.remove(crystal_list, mainLogic.randFactory:rand(1, #crystal_list))
		end

		if not item then
			item = table.remove(animal_special_list, mainLogic.randFactory:rand(1, #animal_special_list))
		end

		if item then 
			result[k] = item
		end
	end
	return result
end

function GameExtandPlayLogic:checkBlackCuteBallList( mainLogic, callback )
	-- body
	local count = 0
	local needReplaceItem = {}
	for r = 1, #mainLogic.gameItemMap do 
		for c = 1, #mainLogic.gameItemMap[r] do 
			local item = mainLogic.gameItemMap[r][c]
			if item.ItemType == GameItemType.kBlackCuteBall and item:isAvailable() then
				
				if item.blackCuteStrength == 2 or item.blackCuteStrength == item.blackCuteMaxStrength then 
					table.insert(needReplaceItem, {r=r, c=c})
					count = count + 1
				elseif item.blackCuteStrength == 1 then
					if item.lastInjuredStep ~= mainLogic.realCostMove then
						count = count + 1
						local action = GameBoardActionDataSet:createAs(
							GameActionTargetType.kGameItemAction,
							GameItemActionType.kItem_Black_Cute_Ball_Update,
							IntCoord:create(r, c),
							nil,
							GamePlayConfig_MaxAction_time
						)
						action.completeCallback = callback
						mainLogic:addGameAction(action)
					end
				end
			end
		end
	end

	local select_list = GameExtandPlayLogic:getRandomColorItems( mainLogic, #needReplaceItem )
	for k = 1, #select_list do 
		local blackCuteCoord = IntCoord:create(needReplaceItem[k].r, needReplaceItem[k].c)
		local replaceItemCoord = IntCoord:create(select_list[k].r, select_list[k].c)
		local action = GameBoardActionDataSet:createAs(
			GameActionTargetType.kGameItemAction,
			GameItemActionType.kItem_Black_Cute_Ball_Update,
			blackCuteCoord,
			replaceItemCoord,
			GamePlayConfig_MaxAction_time
		)
		action.completeCallback = callback
		mainLogic:addGameAction(action)
	end

	---找到的替换item不够
	if #select_list < #needReplaceItem then
		if _G.isLocalDevelopMode then printx(0, "find no enough items") end
		count = count - (#needReplaceItem - #select_list)
	end
	return count
end

function GameExtandPlayLogic:findMimosa(mainLogic, r, c )
	-- body
	local item = mainLogic.gameItemMap[r][c]
	if (item.ItemType == GameItemType.kMimosa or item.ItemType == GameItemType.kKindMimosa )
		-- and #item.mimosaHoldGrid > 0 and item.mimosaLevel >= GamePlayConfig_Mimosa_Grow_Step then
		and #item.mimosaHoldGrid > 0 and not item.isBackAllMimosa then
		return r, c
	else
		for r1 = 1, #mainLogic.gameItemMap do 
			for c1 = 1, #mainLogic.gameItemMap[r1] do 
				local temp_item = mainLogic.gameItemMap[r1][c1]
				-- if temp_item and #temp_item.mimosaHoldGrid > 0 and temp_item.mimosaLevel >= GamePlayConfig_Mimosa_Grow_Step then
				if temp_item and #temp_item.mimosaHoldGrid > 0 and not temp_item.isBackAllMimosa then
					for k, v in pairs(temp_item.mimosaHoldGrid) do
						if v.x == r and v.y == c then
							return r1, c1
						end
					end
				end
			end
		end 
	end
	return nil
end

-------含羞草退到r, c点 无保护
function GameExtandPlayLogic:backMimosaToRC(mainLogic, r, c, callback)
	-- body
	local _r, _c = GameExtandPlayLogic:findMimosa(mainLogic, r, c )
	if _r and _c then
		local item = mainLogic.gameItemMap[_r][_c]
		if item.ItemType == GameItemType.kBlocker195 then
			item.isBlocker195Lock = true
			mainLogic.needClearBlcoker195Data = true
		end

		local action = GameBoardActionDataSet:createAs(
							GameActionTargetType.kGameItemAction,
							GameItemActionType.kItem_KindMimosa_back,
							IntCoord:create(_r, _c),
							IntCoord:create(r, c),
							GamePlayConfig_MaxAction_time
							)
		action.completeCallback = callback
		local mimosaHoldGrid = item.mimosaHoldGrid
		local max = #mimosaHoldGrid
		local newHoldGrid = {}
		local list = {}
		local isPopHoldGrid = false
		for k = 1, max do
			local v = mimosaHoldGrid[k]
			if v.x == r and v.y == c then
				isPopHoldGrid = true
			end

			if isPopHoldGrid then
				table.insert(list, IntCoord:create(v.x, v.y))

			else
				table.insert(newHoldGrid, IntCoord:create(v.x, v.y))
			end
		end

		action.direction = item.mimosaDirection
		action.itemType = item.ItemType
		action.list = list

		item.mimosaHoldGrid = newHoldGrid
		item.mimosaLevel = 1
		if #newHoldGrid == 0 then
			item.mimosaLevel = 0
		end
		mainLogic:addDestroyAction(action)
	else
		if callback then callback() end
	end

end

-------含羞草退出所有 有保护
function GameExtandPlayLogic:backMimosa( mainLogic, r, c, callback)
	-- body
	local _r, _c = GameExtandPlayLogic:findMimosa(mainLogic, r, c )
	if _r and _c then
		local item = mainLogic.gameItemMap[_r][_c]
		local action = GameBoardActionDataSet:createAs(
							GameActionTargetType.kGameItemAction,
							GameItemActionType.kItem_Mimosa_back,
							IntCoord:create(_r, _c),
							nil,
							GamePlayConfig_MaxAction_time
							)
		action.completeCallback = callback
		action.mimosaHoldGrid = item.mimosaHoldGrid
		for k, v in pairs(item.mimosaHoldGrid) do    --------保护起来
			local item_t = mainLogic.gameItemMap[v.x][v.y]
			item_t.beEffectByMimosa = GameItemType.kMimosa 
		end
		action.direction = item.mimosaDirection
		action.itemType = item.ItemType
		item.mimosaLevel = 1
		item.isBackAllMimosa = true
		mainLogic:addDestroyAction(action)
	else
		if callback then callback() end
	end

end

function GameExtandPlayLogic:getMimosaToHoldGrid(itemType, mainLogic, r, c )
	-- body
	local item = mainLogic.gameItemMap[r][c]
	local rAdd, cAdd = 0, 0
	local result = nil
	if item and item.ItemType == itemType then
		if item.mimosaDirection == 1 then  --left
			rAdd = 0  cAdd = -1
		elseif item.mimosaDirection == 2 then  --right
			rAdd = 0  cAdd = 1
		elseif item.mimosaDirection == 3 then  --up
			rAdd = -1  cAdd = 0
		elseif item.mimosaDirection == 4 then  --down
			rAdd = 1  cAdd = 0
		end
	end

	local grid
	local i = 1
	if (item.mimosaHoldGrid and #item.mimosaHoldGrid > 0 ) then
		grid = IntCoord:create(item.mimosaHoldGrid[#item.mimosaHoldGrid].x + i * rAdd, item.mimosaHoldGrid[#item.mimosaHoldGrid].y + i * cAdd)
	else
		grid = IntCoord:create(r + i * rAdd, c + i * cAdd)
	end

	if mainLogic:hasChainInNeighbors(grid.x - i * rAdd, grid.y - i * cAdd, grid.x, grid.y) then
		return nil
	end

	if mainLogic.gameItemMap[grid.x] and mainLogic.gameItemMap[grid.x][grid.y] then
		local item_select = mainLogic.gameItemMap[grid.x][grid.y]
		local board_select = mainLogic.boardmap[grid.x][grid.y]
		if item_select and item_select.isUsed
			and not item_select.isEmpty
			and not item_select:hasFurball() 
			and not item_select:hasLock() 
			and not ( item_select.ItemType == GameItemType.kMissile and item_select.missileLevel == 0 )
			and not ( item_select.ItemType == GameItemType.kBuffBoom and item_select.level == 0 )
			and item_select.ItemType ~= GameItemType.kBlackCuteBall
			and item_select.ItemType ~= GameItemType.kPuffer
			and item_select:isAvailable()
			and not board_select.isMoveTile
			and board_select.tileBlockType == 0
			and board_select.transType == TransmissionType.kNone
			and (not item_select.isBlock
					or item_select.ItemType == GameItemType.kMagicLamp
					or item_select.ItemType == GameItemType.kWukong
					or item_select:isBlocker199Active()
					or item_select.ItemType == GameItemType.kPacman)
			and board_select.colorFilterState == ColorFilterState.kStateNone
			then
			result = grid
		end
	end
	return result
end

function GameExtandPlayLogic:updateMimosaToHoldGridList(itemType, mainLogic)
	-- body
	local itemMap = mainLogic.gameItemMap
	local result = {}
	for i = 1, GamePlayConfig_Mimosa_Grow_Grid_Num + 1 do 
		for r = #itemMap, 1, -1 do 
			if not result[r] then result[r] = {} end
			for c = #itemMap[r], 1, -1 do 
				local item = itemMap[r][c]
				if item and item.ItemType == itemType and item:isAvailable() 
					and item.mimosaLevel >= GamePlayConfig_Mimosa_Grow_Step then
					local tryGrid = GameExtandPlayLogic:getMimosaToHoldGrid(itemType, mainLogic, r, c )
					if tryGrid then
						if i == 1 then
							item.isCanGrow = true
						else
							local item_select = itemMap[tryGrid.x][tryGrid.y]

							if item_select.beEffectByMimosa == 0 then
								item_select.beEffectByMimosa = item.ItemType
								item_select.mimosaDirection = item.mimosaDirection
								if not result[r][c] then result[r][c] = {} end
								table.insert(result[r][c], tryGrid)
								table.insert(item.mimosaHoldGrid, tryGrid)
							end
							
						end
					end
				end
			end
		end
	end

	return result
	

end

function GameExtandPlayLogic:checkMimosa( itemType, mainLogic, callback )
	-- body
	local count = 0
	local map = mainLogic.gameItemMap
	local addGridMap = GameExtandPlayLogic:updateMimosaToHoldGridList(itemType, mainLogic)
	for r = 1, #map do 
		for c = 1, #map[r] do
			local item = map[r][c]
			if item and item.ItemType == itemType and item:isAvailable() then
				item.mimosaLevel = item.mimosaLevel + 1
				if item.mimosaLevel > GamePlayConfig_Mimosa_Grow_Step then
					local tryGrids = addGridMap[r][c]
					if tryGrids and #tryGrids > 0 then              -------生长
						local action = GameBoardActionDataSet:createAs(
							GameActionTargetType.kGameItemAction,
							GameItemActionType.kItem_Mimosa_Grow,
							IntCoord:create(r, c),
							nil,
							GamePlayConfig_MaxAction_time
							)
						action.completeCallback = callback
						action.addItem = tryGrids
						action.direction = item.mimosaDirection
						action.itemType = item.ItemType
						mainLogic:addGameAction(action)
						count = count + 1
					elseif #item.mimosaHoldGrid > 0 and not item.isCanGrow then    -------------退回
						local action = GameBoardActionDataSet:createAs(
							GameActionTargetType.kGameItemAction,
							GameItemActionType.kItem_Mimosa_back,
							IntCoord:create(r, c),
							nil,
							GamePlayConfig_MaxAction_time
							)
						action.completeCallback = callback
						action.mimosaHoldGrid = item.mimosaHoldGrid
						action.direction = item.mimosaDirection
						action.itemType = item.ItemType
						mainLogic:addGameAction(action)
						item.mimosaLevel = 1
						count = count + 1
					end
					item.isCanGrow = nil
				else 
					if item.mimosaLevel == GamePlayConfig_Mimosa_Grow_Step then
						local action = GameBoardActionDataSet:createAs(
							GameActionTargetType.kGameItemAction,
							GameItemActionType.kItem_Mimosa_Ready,
							IntCoord:create(r, c),
							nil,
							GamePlayConfig_MaxAction_time
							)
						action.completeCallback = callback
						mainLogic:addGameAction(action)
						count = count + 1
						if item.mimosaHoldGrid then
							ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_KindMimosa, ObstacleFootprintAction.k_Covered, #item.mimosaHoldGrid)
						end
					end
				end
			end
		end
	end
	return count
end



function GameExtandPlayLogic:MaydayBossLoseBlood(mainLogic, r, c, isMatch , actid , hitBlood)
	
	local item = mainLogic.gameItemMap[r][c]
	local boss = nil
	local boss_r, boss_c = r, c 
	if item.bossLevel > 0 then
		boss = item
	else
		if c - 1 > 0 and mainLogic.gameItemMap[r][c - 1].bossLevel > 0 then
			boss = mainLogic.gameItemMap[r][c - 1]
			boss_r, boss_c = r, c-1
		elseif r - 1 > 0 and mainLogic.gameItemMap[r - 1][c].bossLevel > 0 then
			boss = mainLogic.gameItemMap[r - 1][c]
			boss_r, boss_c = r-1, c
		elseif (c - 1 > 0 and r - 1 > 0) and mainLogic.gameItemMap[r - 1][c - 1].bossLevel > 0 then
			boss = mainLogic.gameItemMap[r - 1][c-1]
			boss_r, boss_c = r-1, c-1
		end
	end
	
	local canBeEffectBySpecaial = true
	if isMatch == false and actid and boss ~= nil then
		if not boss.specialEffectList then 
			boss.specialEffectList = {}
		end

		if boss.specialEffectList[actid] then
			canBeEffectBySpecaial = false 
		end

		if canBeEffectBySpecaial then
			boss.specialEffectList[actid] = true
		end
	end

	if boss ~= nil and boss.blood > 0 and canBeEffectBySpecaial then
		local addScore = GamePlayConfigScore.MayDayBossBeHit
		-- boss.digBlockCanbeDelete = false
		mainLogic:addScoreToTotal(r, c, addScore)

		local bloodLoseCount = isMatch and 1 or boss.speicial_hit_blood
		if hitBlood and type(hitBlood) == "number" and hitBlood > 0 then
			bloodLoseCount = hitBlood
		end
		-- hitCounter的增量不会超过boss当前血量
		if boss.blood > bloodLoseCount then
			boss.hitCounter = boss.hitCounter + bloodLoseCount
		else
			boss.hitCounter = boss.hitCounter + boss.blood
		end

		boss.blood = boss.blood - bloodLoseCount
		if boss.blood < 0 then boss.blood = 0 end
		local decAction = GameBoardActionDataSet:createAs(
			GameActionTargetType.kGameItemAction,
			GameItemActionType.kItem_Mayday_Boss_Loss_Blood,
			IntCoord:create(boss_r, boss_c),
			nil,
			GamePlayConfig_MaxAction_time)
		decAction.addInt = boss.blood / boss.maxBlood
		decAction.debug_string = tostring(boss.blood)..'/'..tostring(boss.maxBlood)
		mainLogic:addDestroyAction(decAction)
	end
end

function GameExtandPlayLogic:WeeklyBossLoseBlood(mainLogic, r, c, isMatch , actid , hitBlood)
	local item = mainLogic.gameItemMap[r][c]
	local boss = nil
	local boss_r, boss_c = r, c 
	if item.weeklyBossLevel > 0 then
		boss = item
	else
		if c - 1 > 0 and mainLogic.gameItemMap[r][c - 1].weeklyBossLevel > 0 then
			boss = mainLogic.gameItemMap[r][c - 1]
			boss_r, boss_c = r, c-1
		elseif r - 1 > 0 and mainLogic.gameItemMap[r - 1][c].weeklyBossLevel > 0 then
			boss = mainLogic.gameItemMap[r - 1][c]
			boss_r, boss_c = r-1, c
		elseif (c - 1 > 0 and r - 1 > 0) and mainLogic.gameItemMap[r - 1][c - 1].weeklyBossLevel > 0 then
			boss = mainLogic.gameItemMap[r - 1][c-1]
			boss_r, boss_c = r-1, c-1
		end
	end
	
	local canBeEffectBySpecaial = true
	if isMatch == false and actid and boss ~= nil then
		if not boss.specialEffectList then 
			boss.specialEffectList = {}
		end

		if boss.specialEffectList[actid] then
			canBeEffectBySpecaial = false 
		end

		if canBeEffectBySpecaial then
			boss.specialEffectList[actid] = true
		end
	end

	if boss ~= nil and boss.blood > 0 and canBeEffectBySpecaial then
		local addScore = GamePlayConfigScore.WeeklyBossBeHit
		mainLogic:addScoreToTotal(r, c, addScore)

		local bloodLoseCount = isMatch and 1 or boss.speicial_hit_blood
		if hitBlood and type(hitBlood) == "number" and hitBlood > 0 then
			bloodLoseCount = hitBlood
		end
		-- hitCounter的增量不会超过boss当前血量
		if boss.blood > bloodLoseCount then
			boss.hitCounter = boss.hitCounter + bloodLoseCount
		else
			boss.hitCounter = boss.hitCounter + boss.blood
		end

		boss.blood = boss.blood - bloodLoseCount
		if boss.blood < 0 then boss.blood = 0 end
		local decAction = GameBoardActionDataSet:createAs(
			GameActionTargetType.kGameItemAction,
			GameItemActionType.kItem_Weekly_Boss_Loss_Blood,
			IntCoord:create(boss_r, boss_c),
			nil,
			GamePlayConfig_MaxAction_time)
		decAction.addInt = boss.blood
		mainLogic:addDestroyAction(decAction)
	end
end

function GameExtandPlayLogic:showUFOReveivePanel(gameMode, isWin)
	local mainLogic = gameMode.mainLogic
    local function reviveGameCallback( ... )
        -- body
        if mainLogic.PlayUIDelegate then 
            mainLogic.PlayUIDelegate:playUFOReFlyInotAnimation()
        end
        gameMode.mainLogic:setNeedCheckFalling()
        mainLogic:setGamePlayStatus(GamePlayStatus.kNormal)
        mainLogic.fsm:changeState(mainLogic.fsm.fallingMatchState)
    end

    local function reviveMissileAnimationCallback( ... )
        -- body
        GameExtandPlayLogic:reviveGame( mainLogic, reviveGameCallback)
    end

    local function confirmReviev( isTryAgain )   ----确认使用兔兔导弹后，修改数据
        -- body
        if isTryAgain then
            mainLogic.isUFOWin = false
            local icon = Sprite:createWithSpriteFrameName("RabbitMissile")
            local scene = Director:sharedDirector():getRunningScene()
            local animation = PrefixPropAnimation:createReviveMissileAnimation(icon, reviveMissileAnimationCallback)
            scene:addChild(animation)
        else
            if isWin then 
            	mainLogic:setGamePlayStatus(GamePlayStatus.kWin)
            else
            	mainLogic:setGamePlayStatus(GamePlayStatus.kFailed)
            end
        end
    end

    local function addPanel()
        mainLogic.PlayUIDelegate:showAddRabbitMissilePanel(mainLogic.level, mainLogic.totalScore, gameMode:getScoreStarLevel(mainLogic), gameMode:reachTarget(), confirmReviev)
    end

    if mainLogic.PlayUIDelegate then 
        mainLogic.PlayUIDelegate:playUFOFlyawayAnimation(addPanel)
    end
end

function GameExtandPlayLogic:showAddStepPanel(gameMode)
	local mainLogic = gameMode.mainLogic;
	local function tryAgainWhenFailed(isTryAgain, propId, deltaStep)	----确认加5步之后，修改数据
	    if isTryAgain then
	      SnapshotManager:stop()
	      gameMode:getAddSteps(deltaStep or 5)
	      mainLogic:setGamePlayStatus(GamePlayStatus.kNormal)
	      mainLogic.fsm:changeState(mainLogic.fsm.waitingState)

	      if not mainLogic.replaying then
	      	local replaydata = {prop = propId or 10004, pt=UsePropsType.TEMP, x1 = r1, y1 = c1, x2 = r2, y2 = c2} --加五步，标识为临时，则不会开局当作虚假道具新增
	      	GamePlayContext:getInstance():onUseProp( replaydata.prop , mainLogic.realCostMove , UsePropsType.NORMAL ) --加到context是不要把pt设置为TEMP，而是NORMAL
	      	ReplayDataManager:updateGamePlayContext(false, true)
	      	ReplayDataManager:addReplayStep( replaydata )
	      	SnapshotManager:catchUseProp( replaydata )
	      	SnapshotManager:catchStep( mainLogic )
	      end
	      
	      --RemoteDebug:uploadLog( "GameExtandPlayLogic" ,  "showAddStepPanel  deltaStep" , deltaStep , "propId" , propId )

	      if deltaStep and deltaStep == 1 then
	      	mainLogic:checkUpdateLevelDifficultyAdjustByUseProp( UsePropsType.NORMAL , GamePropsType.kAdd1 )
	      elseif deltaStep and deltaStep == 2 then
	      	mainLogic:checkUpdateLevelDifficultyAdjustByUseProp( UsePropsType.NORMAL , GamePropsType.kAdd2 )
	      elseif deltaStep and deltaStep == 15 then
	      	mainLogic:checkUpdateLevelDifficultyAdjustByUseProp( UsePropsType.NORMAL , GamePropsType.kAdd15 )
	      else
	      	mainLogic:checkUpdateLevelDifficultyAdjustByUseProp( UsePropsType.NORMAL , propId or GamePropsType.kAdd5 )
	      end

	    else
	      mainLogic:setGamePlayStatus(GamePlayStatus.kFailed)
	    end
	end 

	if mainLogic.PlayUIDelegate then
	    mainLogic.PlayUIDelegate:addStep(mainLogic.level, mainLogic.totalScore, gameMode:getScoreStarLevel(mainLogic), gameMode:reachTarget(), tryAgainWhenFailed)
	end
end

function GameExtandPlayLogic:showAddTimePanel(gameMode)
	local mainLogic = gameMode.mainLogic

	local function addTimeCallback(confirmUse)
		if confirmUse then
			gameMode:addTime(15)
			mainLogic:setGamePlayStatus(GamePlayStatus.kNormal)
	      	mainLogic.fsm:changeState(mainLogic.fsm.waitingState)
		else
			mainLogic:setGamePlayStatus(GamePlayStatus.kFailed)
		end
	end

	if mainLogic.PlayUIDelegate then
		mainLogic.PlayUIDelegate:showAddTimePanel(mainLogic.level, mainLogic.totalScore, gameMode:getScoreStarLevel(mainLogic), gameMode:reachTarget(), addTimeCallback)
	end
end

function GameExtandPlayLogic:checkTransmission(mainLogic, callback)
	local result = 0
	local gameItemMap = mainLogic.gameItemMap
	local boardmap = mainLogic.boardmap
	local lockedTransmissionAmount = 0
	for r = 1, #boardmap do 
		for c = 1, #boardmap[r] do 
			local board = boardmap[r][c]
			if board.transType > 0 then
				if not board.isTransLock then
					result = result  + 1
					local to_r, to_c = board.transLink.x, board.transLink.y
					local action =  GameBoardActionDataSet:createAs(
						GameActionTargetType.kGameItemAction,
						GameItemActionType.kItem_Transmission,
						IntCoord:create(r, c),
						IntCoord:create(to_r, to_c),
						GamePlayConfig_MaxAction_time)
					action.completeCallback = callback
					action.itemData = gameItemMap[r][c]:copy()
					action.boardData = boardmap[r][c]:copy()
					action.toTransType = boardmap[to_r][to_c].transType
					action.toBoardDataDirect = boardmap[to_r][to_c].transDirect
					action.itemShowType = mainLogic.boardView.baseMap[r][c].itemShowType
					mainLogic:addGameAction(action)
				else
					lockedTransmissionAmount = lockedTransmissionAmount + 1
				end
			end
		end
	end
	if lockedTransmissionAmount > 0 then
		ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_Transmission, ObstacleFootprintAction.k_Covered, lockedTransmissionAmount)
	end

	if result > 0 then
		setTimeOut( function () GamePlayMusicPlayer:playEffect( GameMusicType.kPlayTransmissionMove ) end , 0.1 )
	end

	return result
end

--------------------
--蜂蜜罐子增加一层
--------------------
function GameExtandPlayLogic:increaseHoneyBottle( mainLogic, r, c, times, scoreScale )
	-- body
	scoreScale = scoreScale or 1
	local item = mainLogic.gameItemMap[r][c]
	if item.honeyBottleLevel + times > 4 then times = 4 - item.honeyBottleLevel end
	item.honeyBottleLevel = item.honeyBottleLevel + times
	
	local incAction = GameBoardActionDataSet:createAs(
	 		GameActionTargetType.kGameItemAction,
	 		GameItemActionType.kItem_Honey_Bottle_increase,
	 		IntCoord:create(r,c),
	 		nil,
	 		1)
	incAction.addInt = times
	mainLogic:addDestroyAction(incAction)
end

function GameExtandPlayLogic:checkHoneyBottleBroken( mainLogic, callback )
	-- body
	local gameItemMap = mainLogic.gameItemMap
	local boardMap = mainLogic.boardmap
	--select item to run
	local brokenHoneyBottle = {}
	local canBeInfectItemList = {}
	local subCanBeInfectItemList = {}
	for r = 1, #gameItemMap do 
		for c = 1, #gameItemMap[r] do
			local item = gameItemMap[r][c]
			if item then 
				local intCoord = IntCoord:create(r, c)
				if item.honeyBottleLevel > 3 and item:isAvailable() then
					table.insert(brokenHoneyBottle, intCoord)
				elseif item:canInfectByHoneyBottle() then
					if boardMap[r][c].honeySubSelect then 
						table.insert(subCanBeInfectItemList, intCoord)
					else
						table.insert(canBeInfectItemList, intCoord)
					end
				end
			end 
		end
	end
	
	for k, v in pairs(brokenHoneyBottle) do 
		local infectList = {}
		local createhoneys = mainLogic.honeys
		if not createhoneys then 
			printx( 1 , "   ===================createhoneys===========================   " , mainLogic.honeys)
			createhoneys = 1 
		end
		for k = 1, createhoneys do 
			local item 
			if #canBeInfectItemList > 0 then
				--todo
				item = table.remove(canBeInfectItemList, mainLogic.randFactory:rand(1, #canBeInfectItemList))
				table.insert(infectList, item)
			elseif #subCanBeInfectItemList > 0 then 
				item = table.remove(subCanBeInfectItemList, mainLogic.randFactory:rand(1, #subCanBeInfectItemList))
				table.insert(infectList, item)
			end
		end
		
		local addScore = GamePlayConfigScore.MatchAt_DigJewel
		mainLogic:addScoreToTotal(v.x, v.y, addScore)

		local infectAction = GameBoardActionDataSet:createAs(
	 		GameActionTargetType.kGameItemAction,
	 		GameItemActionType.kItem_Honey_Bottle_Broken,
	 		v,
	 		nil,
	 		GamePlayConfig_MaxAction_time)
		infectAction.infectList = infectList
		infectAction.completeCallback = callback
		mainLogic:addGameAction(infectAction)
	end

	return #brokenHoneyBottle
end

function GameExtandPlayLogic:honeyDestroy( mainLogic, r, c, scoreScale )
	local board = mainLogic.boardmap[r][c]
	if not board.isJustEffectByFilter then 
		local  item = mainLogic.gameItemMap[r][c]
		if item.ItemType == GameItemType.kBlocker195 then
			item.isBlocker195Lock = true
			mainLogic.needClearBlcoker195Data = true
		end

		----1-1.数据变化
		local origLevel = item.honeyLevel
		item.honeyLevel = item.honeyLevel - 1
		item.digBlockCanbeDelete = false
		
		mainLogic:tryDoOrderList(r, c, GameItemOrderType.kOthers, GameItemOrderType_Others.kHoney, 1)
		ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_Honey, ObstacleFootprintAction.k_Eliminate, 1)
		local honeyAction = GameBoardActionDataSet:createAs(
			GameActionTargetType.kGameItemAction,
			GameItemActionType.kItemDestroy_HoneyDec,
			IntCoord:create(r,c),				
			nil,				
			GamePlayConfig_Honey_Disappear)
		honeyAction.origLevel = origLevel
		mainLogic:addDestroyAction(honeyAction)
	end
end

function GameExtandPlayLogic:canSandTransferToPos(mainLogic, r, c)
	assert(mainLogic)
	assert(type(r)=="number")
	assert(type(c)=="number")

	if not mainLogic:isPosValid(r, c) then
		return false
	end

	local board = mainLogic.boardmap[r][c]
	if not board or board.sandLevel > 0 then
		return false 
	end 

	local item = mainLogic.gameItemMap[r][c]
	if not item or not item.isUsed or item:isPermanentBlocker() 
			or item.ItemType == GameItemType.kMagicStone
			or item:isActiveTotems()
			or (not item:isAvailable()) then -- 
		return false 
	end

	return true
end

function GameExtandPlayLogic:getSandTransferAvailablePosAround(mainLogic, r, c)
	local result = {}
	local boardmap = mainLogic.boardmap
	local board = boardmap[r][c]

	local aroundDirections = {
		{ dr = -1, dc = 0 }, 
		{ dr = 1, dc = 0 }, 
		{ dr = 0, dc = -1 }, 
		{ dr = 0, dc = 1 }
	}

	for _, dir in pairs(aroundDirections) do
		if not mainLogic:hasRopeInNeighbors(r, c, r + dir.dr, c + dir.dc)
			and not mainLogic:hasChainInNeighbors(r, c, r + dir.dr, c + dir.dc)
			and GameExtandPlayLogic:canSandTransferToPos(mainLogic, r + dir.dr, c + dir.dc) 
			then
			table.insert(result, IntCoord:create(r + dir.dr, c + dir.dc))
		end
	end
	return result
end

function GameExtandPlayLogic:getRandomTransferSandPos(mainLogic, sands, callback)
	local result = {}
	local boardmap = mainLogic.boardmap
	for _,v in pairs(sands) do
		local r = v.x
		local c = v.y
		local board = boardmap[r][c]
		if board.sandLevel > 0 and not v.handled then
			local posAround = self:getSandTransferAvailablePosAround(mainLogic, r, c)
			if #posAround > 0 then
				local fromPos = IntCoord:create(r, c)
				local toPos = posAround[mainLogic.randFactory:rand(1, #posAround)]
				-- local toPos = posAround[math.random(#posAround)]

				local sandLevel = board.sandLevel
				boardmap[toPos.x][toPos.y].sandLevel = sandLevel
				board.sandLevel = 0

				local sandTransferAction = GameBoardActionDataSet:createAs(
					GameActionTargetType.kGameItemAction,
					GameItemActionType.kItem_Sand_Transfer,
					IntCoord:clone(fromPos),				
					IntCoord:clone(toPos),				
					GamePlayConfig_MaxAction_time)
				mainLogic:addGameAction(sandTransferAction)
				sandTransferAction.addInt = sandLevel
				sandTransferAction.callback = callback

				table.insert(result, toPos)
				v.handled = true
			end
		end
	end
	return result
end

function GameExtandPlayLogic:getSandBoardPos(mainLogic)
	local result = {}
	local boardmap = mainLogic.boardmap
	for r = 1, #boardmap do 
		for c = 1, #boardmap[r] do 
			local board = boardmap[r][c]
			local item = mainLogic.gameItemMap[r][c]
			if board and board.sandLevel > 0 and item:isAvailable() then
				table.insert(result, IntCoord:create(r,c))
			end
		end
	end
	return result
end

function GameExtandPlayLogic:checkSandToTransfer( mainLogic, callback )
	local result = 0
	local boardmap = mainLogic.boardmap
	local sands = GameExtandPlayLogic:getSandBoardPos(mainLogic)
	local transferPos = GameExtandPlayLogic:getRandomTransferSandPos(mainLogic, sands, callback)
	while #transferPos > 0 do
		result = result + #transferPos

		transferPos = GameExtandPlayLogic:getRandomTransferSandPos(mainLogic, sands, callback)
	end
	return result
end

-- useOtherRows:如果指定的行内找不到足够的位置，是否使用其他行填补空缺
function GameExtandPlayLogic:getNormalPositionsForBoss(mainLogic, count, fromRow, toRow, banList, useOtherRows)
    local function isNormal(item)
        if item.ItemType == GameItemType.kAnimal
        and item.ItemSpecialType == 0 -- not special
        and item:isAvailable()
        and not item:hasLock() 
        and not item:hasFurball()
        then
            return true
        end
        return false
    end

	local function isBanned(r, c, banList)
		for k, v in pairs(banList) do
			if r == v.r and c == v.c then
				return true
			end
		end
		return false
	end

	if not fromRow then fromRow = 1 end
	if not toRow then toRow = 9	end
	if not count then count = 1 end
	if not useOtherRows then useOtherRows = true end
	if not banList or type(banList) ~= 'table' then banList = {} end

	local gameItemMap = mainLogic.gameItemMap

	local availablePos = {}
	for r = fromRow, toRow do
		for c = 1, #gameItemMap[r] do
			local item = gameItemMap[r][c]
			if isNormal(item) and not isBanned(r, c, banList) then
				table.insert(availablePos, {r=r, c=c})
			end
		end
	end

	if #availablePos < count and useOtherRows then
		local backupPos = {}
		for r = 1, #gameItemMap do
			if r < fromRow or r > toRow then
				for c = 1, #gameItemMap[r] do
					local item = gameItemMap[r][c]
					if isNormal(item) and not isBanned(r, c, banList) then
						table.insert(backupPos, {r=r, c=c})
					end
				end
			end
		end
		
		-- 为了兼容如果其他行也不够的情况
		local result = table.clone(availablePos)
		local backupCount = math.min(count - #availablePos, #backupPos)
		for i = 1, backupCount do
			local index = mainLogic.randFactory:rand(1, #backupPos)
			table.insert(result, backupPos[index])
			table.remove(backupPos, index)
		end
		return result
	end


	if #availablePos < count then
		return availablePos
	else
		local result = {}
		for i = 1, count do 
			local index = mainLogic.randFactory:rand(1, #availablePos)
			table.insert(result, availablePos[index])
			table.remove(availablePos, index)
		end
		return result
	end

end

function GameExtandPlayLogic:checkBossCasting(mainLogic, callback , passDrip)


	local counter = 0
	local gameItemMap = mainLogic.gameItemMap
	for r = 1, #gameItemMap do
		for c = 1, #gameItemMap[r] do
			if gameItemMap[r][c].ItemType == GameItemType.kBoss 
				and gameItemMap[r][c].bossLevel > 0  then
				local boss = gameItemMap[r][c]
				local buffBlood = BossConfig[boss.bossLevel].buffBlood
				local buffRate = BossConfig[boss.bossLevel].buffRate
				local buffNum = BossConfig[boss.bossLevel].buffNum
				local buffLimit = BossConfig[boss.bossLevel].buffLimit

				
				if boss.hitCounter >= buffBlood then
					-- local genCount = math.floor(boss.hitCounter / buffBlood) * buffNum
					local genCount = math.floor(boss.hitCounter / buffBlood)
					-- if _G.isLocalDevelopMode then printx(0, 'genCount', genCount) end
					local targetPositions = {}
					for i = 1, genCount do 
						local rand = mainLogic.randFactory:rand(1, 100) / 100
						-- if _G.isLocalDevelopMode then printx(0, rand, buffRate) end
						if rand <= buffRate then
							local randCount = 0
							local rand2 = mainLogic.randFactory:rand(1, 100)
							if rand2 >= 0 and rand2 < 60 then
								randCount = 1
							elseif rand2 >= 60 and rand2 < 90 then
								randCount = 2
							elseif rand2 >= 90 and rand2 <= 100 then
								randCount = 3
							end

							if _G.isLocalDevelopMode then printx(0, 'randCount', rand2, randCount) end

							local result = GameExtandPlayLogic:getNormalPositionsForBoss(mainLogic, randCount, 6, 9, targetPositions)
							for k, v in pairs(result) do 
								table.insert(targetPositions, v)
							end
						end
					end

					
					

					-- 最多只保留buffLimit个
					if #targetPositions > buffLimit then
						local tmp = {}
						for i=1, buffLimit do 
							table.insert(tmp, targetPositions[i])
						end
						targetPositions = tmp
					end

					if _G.isLocalDevelopMode then printx(0, 'finalCount', #targetPositions) end

					local rand = mainLogic.randFactory:rand(1, 100) / 100
					local dripPositions = {}
					local dripFixMap = {}
					if not passDrip and rand <= buffRate and mainLogic.hasDripOnLevel then
						dripPositions = GameExtandPlayLogic:getNormalPositionsForBoss(
											mainLogic, mainLogic.randFactory:rand(2, 3) , 6, 9, targetPositions)
						for k, v in pairs(dripPositions) do 
							table.insert(targetPositions, v)
							dripFixMap[tostring(v.r) .. "_" .. tostring(v.c) ] = true
						end
					end
					if _G.isLocalDevelopMode then printx(0, 'finalCount 2222  ', #targetPositions) end
					if #targetPositions > 0 then
						counter = counter + 1
						local action = GameBoardActionDataSet:createAs(
							GameActionTargetType.kGameItemAction,
							GameItemActionType.kItem_mayday_boss_casting,
							IntCoord:create(r, c),
							nil,
							GamePlayConfig_MaxAction_time)
						action.targetPositions = targetPositions
						action.dripPositions = dripFixMap
						action.completeCallback = callback
						mainLogic:addGameAction(action)
					end
					boss.hitCounter = boss.hitCounter - genCount * buffBlood
				end
			end
		end
	end
	return counter
end

function GameExtandPlayLogic:testRateOfQuestionMark( mainLogic, r, c )
	local tableRate = {}
	for i = 1, 100 do 
		local v = GameExtandPlayLogic:getChangeItemSelected( mainLogic, r, c)
		local changeType = v.changeType
		local changeItem = v.changeItem
		if changeType == UncertainCfgConst.kCanFalling then
			local tile = changeItem + 1
			if tile == TileConst.kGreyCute then 
				if not tableRate.kGrey then  
					tableRate.kGrey = 0 
				end 
				tableRate.kGrey = tableRate.kGrey + 1 
			elseif tile == TileConst.kBrownCute then 
				if not tableRate.kBrownCute then  
					tableRate.kBrownCute = 0 
				end 
				tableRate.kBrownCute = tableRate.kBrownCute + 1
			elseif tile == TileConst.kBlackCute then 
				if not tableRate.kBlackCute then  
					tableRate.kBlackCute = 0 
				end 
				tableRate.kBlackCute = tableRate.kBlackCute + 1
			elseif tile == TileConst.kCoin then 
				if not tableRate.kCoin then  
					tableRate.kCoin = 0 
				end 
				tableRate.kCoin = tableRate.kCoin + 1
			elseif tile == TileConst.kCrystal then 
				if not tableRate.kCrystal then  
					tableRate.kCrystal = 0 
				end 
				tableRate.kCrystal = tableRate.kCrystal + 1
			elseif tile == TileConst.kAddMove then 
				if not tableRate.kAddMove then  
					tableRate.kAddMove = 0 
				end 
				tableRate.kAddMove = tableRate.kAddMove + 1
			end
		elseif changeType == UncertainCfgConst.kCannotFalling then
			local tile = changeItem + 1
			if tile == TileConst.kPoison then 
				if not tableRate.kPoison then  
					tableRate.kPoison = 0 
				end 
				tableRate.kPoison = tableRate.kPoison + 1  
			elseif tile == TileConst.kPoisonBottle then 
				if not tableRate.kPoisonBottle then  
					tableRate.kPoisonBottle = 0 
				end 
				tableRate.kPoisonBottle = tableRate.kPoisonBottle + 1 
			elseif tile == TileConst.kDigJewel_1_blue then 
				if not tableRate.kDigJewel_1_blue then  
					tableRate.kDigJewel_1_blue = 0 
				end 
				tableRate.kDigJewel_1_blue = tableRate.kDigJewel_1_blue + 1 
			elseif tile == TileConst.kDigJewel_2_blue then 
				if not tableRate.kDigJewel_2_blue then  
					tableRate.kDigJewel_2_blue = 0 
				end 
				tableRate.kDigJewel_2_blue = tableRate.kDigJewel_2_blue + 1 
			elseif tile == TileConst.kDigJewel_3_blue then 
				if not tableRate.kDigJewel_3_blue then  
					tableRate.kDigJewel_3_blue = 0 
				end 
				tableRate.kDigJewel_3_blue = tableRate.kDigJewel_3_blue + 1 
			end
		elseif changeType == UncertainCfgConst.kSpecial then
			local specialType = AnimalTypeConfig.getSpecial(changeItem)
			if specialType == AnimalTypeConfig.kLine then
				if not tableRate.kLine then  
					tableRate.kLine = 0 
				end 
				tableRate.kLine = tableRate.kLine + 1 
			elseif specialType == AnimalTypeConfig.kColumn then
				if not tableRate.kColumn then  
					tableRate.kColumn = 0 
				end 
				tableRate.kColumn = tableRate.kColumn + 1 

			elseif specialType == AnimalTypeConfig.kWrap then
				if not tableRate.kWrap then  
					tableRate.kWrap = 0 
				end 
				tableRate.kWrap = tableRate.kWrap + 1 

			elseif specialType == AnimalTypeConfig.kColor then
				if not tableRate.kColor then  
					tableRate.kColor = 0 
				end 
				tableRate.kColor = tableRate.kColor + 1 

			end
		end
	end
	for k, v in pairs(tableRate) do
		if _G.isLocalDevelopMode then printx(0, k, v) end
	end
end

function GameExtandPlayLogic:filterItemList(itemList, banList)
	if #itemList > 0 and banList and #banList > 0 then 
		local fItemList = {}
		local deltaFallingWeight = 0
		local deltaAllWeight = 0

		for i, v in ipairs(itemList) do
			local changeItemId = v.changeItem + 1
			if table.includes(banList, changeItemId) then 
				if v.limitInCanFallingItem then 
					deltaFallingWeight = deltaFallingWeight - v.limitInCanFallingItem
				end
				if v.limitInAllItem then 
					deltaAllWeight = deltaAllWeight - v.limitInAllItem
				end
			else
				local cItem = table.clone(v)
				if v.limitInCanFallingItem then 
					cItem.limitInCanFallingItem = cItem.limitInCanFallingItem + deltaFallingWeight
				end
				if v.limitInAllItem then 
					cItem.limitInAllItem = cItem.limitInAllItem + deltaAllWeight
				end
				table.insert(fItemList, cItem)
			end
		end
		return fItemList
	end
	return itemList
end

--param @banList 指定福袋不会掉落的列表
function GameExtandPlayLogic:getChangeItemSelected(mainLogic, r, c, banList)
	local item = mainLogic.gameItemMap[r][c]
	local itemList = nil
	local dropPropsPercent = nil -- 0 ~ 100，nil表示不予干预
	local isOnlyFallingItem

	local uncertainCfg = nil
	if item.isProductByBossDie then 
		uncertainCfg = mainLogic.uncertainCfg2
	else
		uncertainCfg = mainLogic.uncertainCfg1
	end

	if not uncertainCfg then
		if _G.isLocalDevelopMode then printx(0, "getChangeItemSelected:uncertainCfg not exsit while BossDie=", item.isProductByBossDie) end
		return 
	end

	local canDropProps = false
	if uncertainCfg:hasDropProps() then

		if mainLogic.levelType == GameLevelType.kSummerWeekly then
			--if mainLogic.summerWeeklyData then
				--dropPropsPercent = mainLogic.summerWeeklyData.dropPropsPercent
			--end
			if GamePlayContext:getInstance().summerWeeklyData then
				dropPropsPercent = GamePlayContext:getInstance().summerWeeklyData.dropPropsPercent
			end
		elseif mainLogic.laborDayData then -- 强制指定道具掉落的百分比
			dropPropsPercent = mainLogic.laborDayData.dropPropsPercent
		end

		local user = UserManager:getInstance().user
		local dropPropCount = StageInfoLocalLogic:getTotalDropPropCount( user.uid )
		if dropPropCount >= 1 then -- 本次关卡掉落过一次后不再掉落
			dropPropsPercent = 0
		end

		if not dropPropsPercent or dropPropsPercent > 0 then -- 未强制指定或指定的掉落百分比大于0
			canDropProps = true
		end
	end

	if item.ItemStatus == GameItemStatusType.kNone
			or item.ItemStatus == GameItemStatusType.kItemHalfStable 
			-- or item.ItemStatus == GameItemStatusType.kJustArrived
			then
		isOnlyFallingItem = false
		itemList = uncertainCfg.allItemList
	else
		isOnlyFallingItem = true
		itemList = uncertainCfg.canfallingItemList
	end

	itemList = self:filterItemList(itemList, banList)

	local itemListNotEmpty = itemList and #itemList > 0
	if itemListNotEmpty or canDropProps then
		local total = 0
		local onlyProps = false
		if itemListNotEmpty then
			total = isOnlyFallingItem and itemList[#itemList].limitInCanFallingItem or itemList[#itemList].limitInAllItem
		end
		if canDropProps then 
			if dropPropsPercent == nil then -- 不需要调整概率，使用默认权重
				total = total + uncertainCfg.dropPropTotalWeight
			else -- 根据概率计算是否掉落道具
				if mainLogic.randFactory:rand(1, 10000) <= dropPropsPercent * 100 then
					onlyProps = true
				end
			end
		end

		-- if _G.isLocalDevelopMode then printx(0, canDropProps, dropPropsPercent, total) end

		if itemListNotEmpty and not onlyProps then
			local randValue = mainLogic.randFactory:rand(1, total)
			-- if _G.isLocalDevelopMode then printx(0, "randValue:", randValue, table.tostring(itemList)) end
			for k = 1, #itemList do 
				local limit = isOnlyFallingItem and itemList[k].limitInCanFallingItem or itemList[k].limitInAllItem
				if randValue <= limit then
					return itemList[k]
				end
			end
		end
		-- 随机到的是掉落道具
		if canDropProps then
			local dropPropList = uncertainCfg.dropPropList
			local propTotalWeight = dropPropList[#dropPropList].limitInProps
			local propRandValue = mainLogic.randFactory:rand(1, propTotalWeight)
			-- if _G.isLocalDevelopMode then printx(0, "propRandValue:", propRandValue, table.tostring(dropPropList)) end
			for k = 1, #dropPropList do 
				local limit = dropPropList[k].limitInProps
				if propRandValue <= limit then
					return dropPropList[k]
				end
			end
		end
	end

	return nil
end

function GameExtandPlayLogic:changeItemTypeFromQuestionMark(mainLogic, r, c)
	local item = mainLogic.gameItemMap[r][c]

	local banList 
	local function insertBanList(tileConstTypes)
		if not banList then 
			banList = {}
		end
		for i,v in ipairs(tileConstTypes) do
			if not table.includes(banList, v) then 
				table.insert(banList, v)
			end
		end
	end

	--被毛球覆盖的福袋 不可再产生毛球
	if item.furballType ~= 0 or item.furballDeleting then 					
		insertBanList({TileConst.kGreyCute, TileConst.kBrownCute})
	end 
	--首次次福袋爆炸不可产生褐色毛球和章鱼
	if mainLogic.questionMarkFirstBomb then
		insertBanList({TileConst.kPoisonBottle, TileConst.kBrownCute})
	end
	--周赛一局最多福袋可开出两个加五步
	if mainLogic.levelType == GameLevelType.kSummerWeekly and SeasonWeeklyRaceManager:getInstance():getQuestionMarkToAddMoveNum() >= 2 then  
		insertBanList({TileConst.kAddMove})
	end

	local selected = GameExtandPlayLogic:getChangeItemSelected(mainLogic, r, c, banList)
	if selected then 
		mainLogic.questionMarkFirstBomb = false

		mainLogic.addMoveBase = mainLogic.addMoveBase > 0 and mainLogic.addMoveBase or GamePlayConfig_Add_Move_Base
		if selected.changeType == UncertainCfgConst.kProps then
			local pos = mainLogic:getGameItemPosInView(r, c)
			if mainLogic.PlayUIDelegate then
				local activityId = 0
				local text = nil
				if mainLogic.levelType == GameLevelType.kSummerWeekly then
					text = Localization:getInstance():getText("weeklyrace.winter.prop.desc", {n="\n"})
				else
					activityId = mainLogic.activityId
				end
				mainLogic.PlayUIDelegate:addTimeProp(selected.changeItem, 1, pos, activityId, text)
			end
		end
		if selected.changeType == UncertainCfgConst.kCanFalling and selected.changeItem + 1 == TileConst.kAddMove then 
			--周赛一局最多福袋可开出两个加五步
			if mainLogic.levelType == GameLevelType.kSummerWeekly then
				local addMoveNum = SeasonWeeklyRaceManager:getInstance():getQuestionMarkToAddMoveNum()
				SeasonWeeklyRaceManager:getInstance():setQuestionMarkToAddMoveNum(addMoveNum + 1)
			end
		end

		item:changeItemFromQuestionMark(selected.changeType, selected.changeItem, mainLogic:randomColor(), mainLogic.addMoveBase)
		if not mainLogic.hasQuestionMarkProduct then
			mainLogic.hasQuestionMarkProduct = true
			local action = GameBoardActionDataSet:createAs(
			GameActionTargetType.kGameItemAction,
			GameItemActionType.kItem_QuestionMark_Protect,
			nil,
			nil,
			GamePlayConfig_MaxAction_time)
			mainLogic:addDestroyAction(action)
		end
		item.questionMarkProduct = 2
		mainLogic:checkItemBlock(r, c)
	else
		item:cleanAnimalLikeData()
	end
end

function GameExtandPlayLogic:questionMarkBomb( mainLogic, r, c )
	-- body
	local item = mainLogic.gameItemMap[r][c]
	--add score
	local addScore = GamePlayConfigScore.QuestionMarkDestory
	mainLogic:addScoreToTotal(r, c, addScore, item._encrypt.ItemColorType)

	GameExtandPlayLogic:itemDestroyHandler(mainLogic, r, c)
	GameExtandPlayLogic:changeItemTypeFromQuestionMark( mainLogic, r, c )
	mainLogic.swapHelpMap[r][c] = -mainLogic.swapHelpMap[r][c]

	local boardView = mainLogic.boardView
	local itemView = boardView.baseMap[r][c]
	itemView:playQuestionMarkDestroy()
	if itemView.itemSprite[ItemSpriteType.kEnterClipping] then
		itemView:FallingDataIntoClipping(item)
		local boardData = mainLogic.boardmap[r][c]
		local r1 = boardData.passEnterPoint_x
		local c1 = boardData.passEnterPoint_y
		if r1 > 0 and c1 > 0 then
			local exitItem = boardView.baseMap[r1][c1]
			if exitItem.itemSprite[ItemSpriteType.kClipping] then
				exitItem:FallingDataOutOfClipping(item)
			end
		end
	else
		itemView:initByItemData(item)
	end

	if item.isBlock then 
		FallingItemLogic:stopFCFallingByBlock(mainLogic, r, c)
	end
	
	itemView:upDatePosBoardDataPos(item)
	mainLogic.gameItemMap[r][c].isNeedUpdate = true
end 

function GameExtandPlayLogic:resetMagicStone(mainLogic)
	local gameItemMap = mainLogic.gameItemMap
	for r = 1, #gameItemMap do
		for c = 1, #gameItemMap[r] do
			local item = mainLogic.gameItemMap[r][c]
			if item.ItemType == GameItemType.kMagicStone and item.magicStoneLevel >= TileMagicStoneConst.kMaxLevel then
				item.magicStoneActiveTimes = 0
			end
		end
	end
end

function GameExtandPlayLogic:calcMagicStoneEffectPositions(mainLogic, r, c)
	local item = mainLogic.gameItemMap[r][c]
	local posOffset = TileMagicStone:calcEffectPositions(item.magicStoneDir)
	local validPos = {}
	for _, v in pairs(posOffset) do
		local tr, tc = r + v.x, c + v.y
		if mainLogic:isPosValid(tr, tc) and mainLogic.boardmap[tr][tc].isUsed then
			table.insert(validPos, v)
		end
	end
	return validPos
end

function GameExtandPlayLogic:tryFirstChestSquareGuide(mainLogic)
	if mainLogic.levelType ~= GameLevelType.kSummerWeekly then
		return
	end

	local gameItemMap = mainLogic.gameItemMap
	for r = 1, #gameItemMap do
		for c = 1, #gameItemMap[r] do
			local item = mainLogic.gameItemMap[r][c]
			if item and item.ItemType == GameItemType.kWeeklyBoss and item.weeklyBossLevel > 0 then
				GameGuide:tryFirstChestSquare(r, c)
				return
			end
		end
	end
end

function GameExtandPlayLogic:onEnterWaitingState(mainLogic)
	GameExtandPlayLogic:updateItemStates(mainLogic)
	-- 更新棋盘上受UFO影响Item的状态
	GameExtandPlayLogic:updateItemsEffectedByUFO(mainLogic)
	-- 水晶石引导
	GameExtandPlayLogic:trySwapCrystalStonesGuide(mainLogic)

	GameExtandPlayLogic:tryFirstChestSquareGuide(mainLogic)

	if mainLogic.gameMode:is(OlympicHorizontalEndlessMode) or 
		mainLogic.gameMode:is(SpringHorizontalEndlessMode) or 
		mainLogic.gameMode:is(MaydayEndlessMode) or 
		mainLogic.gameMode:is(MoleWeeklyRaceMode) then
		mainLogic.gameMode:onEnterWaitingState()
	end

	TimelyHammerGuideMgr.getInstance():handleGuide()

	if mainLogic.gameMode:is(MoleWeeklyRaceMode) then 
		mainLogic.forbidChargeFirework = false
	end

	--捕捉关卡快照
	local function catchStep()
		SnapshotManager:catchStep(mainLogic)
	end 
	xpcall(catchStep, function(err)
    	local message = err
   	 	local traceback = debug.traceback("", 2)
    	if _G.isLocalDevelopMode then printx(-99, message) end
   		if _G.isLocalDevelopMode then printx(-99, traceback) end
   	end)
end

function GameExtandPlayLogic:halloweenTutorial(mainLogic)
	if mainLogic.levelType == GameLevelType.kMoleWeekly then 
	    -- local goldZongziPos = nil
	    -- for r = 1, #mainLogic.gameItemMap do
	    --     for c = 1, #mainLogic.gameItemMap[r] do
	    --         local item = mainLogic.gameItemMap[r][c]
	    --         if item.ItemType == GameItemType.kGoldZongZi and not goldZongziPos then
	    --             goldZongziPos = {r = r, c = c}
	    --         end
	    --     end
	    -- end

	    -- if goldZongziPos then
	    --     GameGuide:sharedInstance():onGoldZongziAppear(goldZongziPos)
	    -- end
	end
end

function GameExtandPlayLogic:trySwapCrystalStonesGuide(mainLogic)
	-- 这个引导只在730关出现
	if mainLogic.level ~= 730 or not GameGuide:checkHaveGuide(mainLogic.level) then
		return
	end

	local function findNearbyActiveStonePos(r, c)
		local directions = {{dr=0, dc=1}, {dr=0, dc=-1}, {dr=1, dc=0}, {dr=-1, dc=0}}
		for _, dir in ipairs(directions) do
			local r1 = r + dir.dr
			local c1 = c + dir.dc
			if mainLogic:isPosValid(r1, c1) then
				local item = mainLogic.gameItemMap[r1][c1]
				if item and item.ItemType == GameItemType.kCrystalStone and item:isActiveCrystalStoneAvailble() 
						and not mainLogic:hasRopeInNeighbors(r, c, r1, c1) then
					return ccp(r1, c1)
				end
			end
		end
		return nil
	end

	local gameItemMap = mainLogic.gameItemMap
	for r = 1, #gameItemMap do
		for c = 1, #gameItemMap[r] do
			local item = mainLogic.gameItemMap[r][c]
			if item and item.ItemType == GameItemType.kCrystalStone and item:isActiveCrystalStoneAvailble() then
				local pos = findNearbyActiveStonePos(r, c)
				if pos then
					GameGuide:trySwapCrystalStonesGuide(ccp(r, c), pos)
					return
				end
			end
		end
	end	
end

function GameExtandPlayLogic:updateItemStates(mainLogic)
	local gameItemMap = mainLogic.gameItemMap
	for r = 1, #gameItemMap do
		for c = 1, #gameItemMap[r] do
			local item = mainLogic.gameItemMap[r][c]
			if item.ItemType == GameItemType.kMagicStone then -- 重置魔法石状态
				if item.magicStoneLevel >= TileMagicStoneConst.kMaxLevel then
					item.magicStoneActiveTimes = 0
				end
			elseif item.ItemType == GameItemType.kCrystalStone then -- 染色宝宝能量充满，改变状态
				if not item:isActiveCrystalStoneAvailble() and item:getCrystalStoneEnergy() >= GamePlayConfig_CrystalStone_Energy then
					item:setCrystalStoneActive(true)
					local itemView = mainLogic.boardView.baseMap[r][c]
					itemView:playCrystalStoneFullAnimate()
					ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_CrystalStone, ObstacleFootprintAction.k_Active, 1)
				end
			end
		end
	end
end

function GameExtandPlayLogic:checkIsReleaseEnery( mainLogic, callback )
	-- body
	local count = 0
	if mainLogic.theGamePlayType == GameModeTypeId.HEDGEHOG_DIG_ENDLESS_ID then
		local r, c = mainLogic.gameMode:findHedgehogRC()
		if mainLogic.gameMode:checkIsReleaseEnery(r, c) then
			count = count + 1
			local _action = GameBoardActionDataSet:createAs(
				GameActionTargetType.kGameItemAction,
				GameItemActionType.kItem_Hedgehog_Release_Energy,
				IntCoord:create(r, c),
				nil,
				GamePlayConfig_MaxAction_time)
			_action.completeCallback = callback
			_action.hedgehogLevel = 2
			mainLogic:addGameAction(_action)

			local dc_data = {
				game_type = "stage",
				game_name = "2016_children_day",
				category = "other",
				sub_category = "children_day_crazy_ready"
			}
			DcUtil:activity(dc_data)
		end
	end

	return count
end

function GameExtandPlayLogic:fireRocket(mainLogic, r, c, colortype)
	local item = mainLogic.gameItemMap[r][c]
	local targetPos = nil
	local isUFOExist = false

	if mainLogic.hasDropDownUFO and not mainLogic.isUFOWin and (mainLogic.theGamePlayStatus == GamePlayStatus.kNormal) then
		isUFOExist = true
	end
	if isUFOExist then
		targetPos = mainLogic.PlayUIDelegate:getUFOStayPositionInBoard()
		local sleepCD = GamePlayConfig_UFO_SleepCD_On_Hit
		if mainLogic.UFOSleepCD < sleepCD then
			mainLogic.UFOSleepCD = sleepCD
		end
	else
		targetPos = IntCoord:create(1, c)
	end

	local action = GameBoardActionDataSet:createAs(
                    GameActionTargetType.kGameItemAction,
                    GameItemActionType.kItem_Rocket_Active,
                    IntCoord:create(r, c),
                    targetPos,
                    GamePlayConfig_MaxAction_time
                )
	action.addInt = colortype
	action.isUFOExist = isUFOExist

    mainLogic:addDestructionPlanAction(action)
end

function GameExtandPlayLogic:playTileHighlight(mainLogic, type, startPos, endPos)
	if not startPos or not endPos then return end

	local fromR, fromC = startPos.x, startPos.y
	local toR, toC = endPos.x, endPos.y
	if fromR > toR then fromR, toR = toR, fromR end
	if fromC > toC then fromC, toC = toC, fromC end

	local gameItemMap = mainLogic.gameItemMap
	for r = 1, #gameItemMap do
		for c = 1, #gameItemMap[r] do
			if r >= fromR and r <= toR and c >= fromC and c <= toC then
				local item = mainLogic.gameItemMap[r][c]
				if item and item.isUsed then
					mainLogic.boardView.baseMap[r][c]:playTileHighlightEffect(type)
					mainLogic.boardView.baseMap[r][c].isNeedUpdate  = true
				end
			end
		end
	end	
end

function GameExtandPlayLogic:stopTileHighlight(mainLogic, startPos, endPos)
	if not startPos or not endPos then return end

	local fromR, fromC = startPos.x, startPos.y
	local toR, toC = endPos.x, endPos.y
	if fromR > toR then fromR, toR = toR, fromR end
	if fromC > toC then fromC, toC = toC, fromC end

	local gameItemMap = mainLogic.gameItemMap
	for r = 1, #gameItemMap do
		for c = 1, #gameItemMap[r] do
			if r >= fromR and r <= toR and c >= fromC and c <= toC then
				local item = mainLogic.gameItemMap[r][c]
				if item and item.isUsed then
					mainLogic.boardView.baseMap[r][c]:stopTileHighlightEffect()
					mainLogic.boardView.baseMap[r][c].isNeedUpdate  = true
				end
			end
		end
	end	
end

function GameExtandPlayLogic:specialCoverInactiveCrystalStone(mainLogic, r, c, scoreScale, fullCharge)
	local item = mainLogic.gameItemMap[r][c]
	if item and item.isUsed and item.ItemType == GameItemType.kCrystalStone and not item:isCrystalStoneActive() then -- 未充满的继续充能
		if mainLogic.theGamePlayStatus == GamePlayStatus.kNormal and item:canCrystalStoneBeCharged() then
			if fullCharge then
				item:chargeCrystalStoneEnergy(GamePlayConfig_CrystalStone_Energy)
			else
				item:chargeCrystalStoneEnergy(GamePlayConfig_CrystalEnergy_Special)
			end
			
			-- item.isNeedUpdate = true

			local theAction = GameBoardActionDataSet:createAs(
				GameActionTargetType.kGameItemAction,
				GameItemActionType.kItemSpecial_CrystalStone_Charge,
				nil, 			
				IntCoord:create(r,c),				
				GamePlayConfig_MaxAction_time
				)
			theAction.addInt1 = item._encrypt.ItemColorType
			theAction.addInt2 = item:getCrystalStoneEnergy()
			mainLogic:addDestructionPlanAction(theAction)
		end
	end
end

function GameExtandPlayLogic:specialCoverActiveCrystalStone(mainLogic, r, c, scoreScale)
	local item = mainLogic.gameItemMap[r][c]
	if item and item.isUsed and item:isAvailable() and not item:hasLock() then
		if item.ItemType == GameItemType.kCrystalStone and item:isCrystalStoneActive() then
			local theAction = GameBoardActionDataSet:createAs(
				GameActionTargetType.kGameItemAction,
				GameItemActionType.kItemSpecial_CrystalStone_Animal ,
				IntCoord:create(r,c),
				nil,				
				GamePlayConfig_SpecialBomb_CrystalStone_Animal_Time1
				)

			theAction.addInt1 = item._encrypt.ItemColorType ----染色宝宝的颜色
			mainLogic:addDestructionPlanAction(theAction)
		end
	end
end

function GameExtandPlayLogic:onItemTouchBegin(mainLogic, r, c)

	-- local function printGridDatasOnTouch(r, c)
	-- 	local item = mainLogic.gameItemMap[r][c]
	-- 	printx(11, "item:", table.tostringByKeyOrder(item))
	-- 	local board = mainLogic.boardmap[r][c]
	-- 	printx(11, "board:", table.tostringByKeyOrder(board))
	-- end

	if mainLogic.gameItemMap and mainLogic.gameItemMap[r] and mainLogic.gameItemMap[r][c] then
		-- printGridDatasOnTouch(r, c)
		local item = mainLogic.gameItemMap[r][c]
		if item.ItemType == GameItemType.kWukong then
			if item.wukongProgressCurr >= item.wukongProgressTotal and item.wukongState ~= TileWukongState.kReadyToJump then
				if wukongLastGuideCastingCount ~= wukongCastingCount then
					wukongLastGuideCastingCount = wukongCastingCount
					local boardmap = mainLogic.boardmap
					local moneyTargetBoardPos = {}
				    for r = 1, #boardmap do
				        for c = 1, #boardmap[r] do
				            local board = boardmap[r][c]
				            if board and board.isWukongTarget then
								table.insert(moneyTargetBoardPos, {r = r , c = c} )
				            end
				        end
				    end
					GameGuide:sharedInstance():onWukongGuideJump({wukongGuide = true, pos = moneyTargetBoardPos}, "wukongGuideJumpClick" )
				end
			end
		end
	end
end

function GameExtandPlayLogic:changeTotemsToWattingActive(mainLogic, r, c, scoreScale, isBomb)--设置闪电鸟到等待激活状态
	local item = mainLogic.gameItemMap[r][c]
	if item then 
		if item:isAvailable() and not item:hasLock() and item.ItemType == GameItemType.kTotems 
			and item.totemsState == GameItemTotemsState.kNone then
			item.totemsState = GameItemTotemsState.kWattingActive

			mainLogic:checkItemBlock(r, c)
			FallingItemLogic:stopFCFallingByBlock(mainLogic, r, c)
			FallingItemLogic:preUpdateHelpMap(mainLogic)

			if scoreScale ~= nil then
				mainLogic:addScoreToTotal(r, c, GamePlayConfigScore.NormalTotems * scoreScale, item._encrypt.ItemColorType)
			end

			local action = GameBoardActionDataSet:createAs(
                GameActionTargetType.kGameItemAction,
                GameItemActionType.kItem_Totems_Change,
                IntCoord:create(r, c),
                nil,
                GamePlayConfig_MaxAction_time)
			action.isBomb = isBomb --是否立即引爆
		    mainLogic:addDestroyAction(action)

		    SpecialCoverLogic:effectBlockerAt(mainLogic, r, c, 1)
		end
	end
end

function GameExtandPlayLogic:changeAllTotemsToWattingActiveWithColor(mainLogic, colortype, scoreScale)--设置所有同色闪电鸟到等待激活状态
	local gameItemMap = mainLogic.gameItemMap
	for r = 1, #gameItemMap do
		for c = 1, #gameItemMap[r] do
			local item = gameItemMap[r][c]
			if item and item.isUsed and item.ItemType == GameItemType.kTotems 
					and (item.ItemStatus == GameItemStatusType.kItemHalfStable or item.ItemStatus == GameItemStatusType.kNone)
					and not item:isActiveTotems() and item._encrypt.ItemColorType == colortype then
				GameExtandPlayLogic:changeTotemsToWattingActive(mainLogic, r, c, scoreScale, false)
			end
		end
	end	
end

function GameExtandPlayLogic:checkSuperCuteBallRecover(mainLogic, callback)
	local count = 0
	local boardmap = mainLogic.boardmap
	for r = 1, #boardmap do
		for c = 1, #boardmap[r] do
			local board = boardmap[r][c]
			local item = mainLogic.gameItemMap[r][c]
			if item and not item:hasBlocker206() and not item:hasSquidLock() then
				if board and board.isUsed and board:hasSuperCuteBall() and board.superCuteState == GameItemSuperCuteBallState.kInactive then
					if board.superCuteAddInt <= 0 then
						count = count + 1

						local item = mainLogic.gameItemMap[r][c]

						board.superCuteAddInt = 0
						board.superCuteState = GameItemSuperCuteBallState.kActive
						item.beEffectBySuperCute = true

						mainLogic:checkItemBlock(r, c)

						local recoverAction = GameBoardActionDataSet:createAs(
							GameActionTargetType.kGameItemAction,
							GameItemActionType.kItem_SuperCute_Recover,
							IntCoord:create(r,c),				
							nil,				
							GamePlayConfig_MaxAction_time)
						recoverAction.completeCallback = callback
						mainLogic:addGameAction(recoverAction)
					end
					board.superCuteAddInt = board.superCuteAddInt - 1
				end
			end
		end
	end	
	return count
end

function GameExtandPlayLogic:getSuperCuteValidAroundItems(mainLogic, centerItem)
	local aroundDirections = {
		{ x = -1, y = 0 }, 
		{ x = 1, y = 0 }, 
		{ x = 0, y = -1 }, 
		{ x = 0, y = 1 }
	}

	local function getItemAt(r, c)
		if mainLogic.gameItemMap[r] then
			return mainLogic.gameItemMap[r][c]
		end
		return nil
	end

	local function getBoardAt(r, c)
		if mainLogic.boardmap[r] then
			return mainLogic.boardmap[r][c]
		end
		return nil
	end

	local cx = centerItem.x
	local cy = centerItem.y

	local result = {}
	for i, coord in ipairs(aroundDirections) do 
		local tempItem = getItemAt(cy + coord.y, cx + coord.x);
		local tempBoard = getBoardAt(cy + coord.y, cx + coord.x)

		if tempItem 
			and not tempItem.isEmpty
			and (tempItem:isAvailable() or tempItem:isFreeGhost())
			and tempItem.beEffectByMimosa ~= GameItemType.kKindMimosa -- 不能跳到含羞草的藤曼上
			and tempItem.ItemType ~= GameItemType.kBlackCuteBall
			and tempItem.ItemType ~= GameItemType.kBigMonster
			and tempItem.ItemType ~= GameItemType.kBigMonsterFrosting
			and tempItem.ItemType ~= GameItemType.kChestSquare
			and tempItem.ItemType ~= GameItemType.kChestSquarePart
			and tempItem.ItemType ~= GameItemType.kSuperBlocker
			and tempItem.ItemType ~= GameItemType.kSquid
			and tempItem.ItemType ~= GameItemType.kSquidEmpty
			-- and tempItem.ItemType ~= GameItemType.kBlocker211
			and not tempItem:hasFurball()
			and tempBoard.tileBlockType ~= 1 -- 翻转地块
			and tempBoard.tileBlockType ~= 2 -- 翻转地块
			and not tempBoard.isMoveTile -- 移动地格
			and not tempBoard:hasSuperCuteBall() 
			and tempBoard.transType == TransmissionType.kNone -- 传送带
			and tempBoard.blockerCoverMaterialLevel ~= -1
			and tempBoard.blockerCoverFlag == 0
			and tempBoard.colorFilterState == ColorFilterState.kStateNone
			and not mainLogic:hasChainInNeighbors(cy, cx, cy + coord.y, cx + coord.x) 
			and self:findBiscuitBoardDataCoveredMe(mainLogic, tempItem.y, tempItem.x) == nil
			then
			table.insert(result, tempItem)
		end
	end
	return result
end

function GameExtandPlayLogic:checkSuperCuteBallTransfer(mainLogic, callback)
	local count = 0
	local boardmap = mainLogic.boardmap
	local superCuteBoardList = {}
	for r = 1, #boardmap do
		for c = 1, #boardmap[r] do
			local board = boardmap[r][c]
			if board and board.isUsed and board:hasSuperCuteBall() and board.superCuteState == GameItemSuperCuteBallState.kActive then
				table.insert(superCuteBoardList, board)
			end
		end
	end	
	if #superCuteBoardList > 0 then
		for _, board in pairs(superCuteBoardList) do
			local item = mainLogic.gameItemMap[board.y][board.x]
			local validAroundItems = GameExtandPlayLogic:getSuperCuteValidAroundItems(mainLogic, item)
			if not item:hasBlocker206() and not item:hasSquidLock() and #validAroundItems > 0 then
				local targetItem = validAroundItems[mainLogic.randFactory:rand(1, #validAroundItems)]
				local targetBoard = mainLogic.boardmap[targetItem.y][targetItem.x]

				targetBoard.superCuteState = board.superCuteState
				targetItem.beEffectBySuperCute = true

				board.superCuteState = GameItemSuperCuteBallState.kNone
				item.beEffectBySuperCute = false

				mainLogic:checkItemBlock(item.y,item.x)
				mainLogic:checkItemBlock(targetItem.y,targetItem.x)
				mainLogic:addNeedCheckMatchPoint(item.y,item.x)
				mainLogic.gameMode:checkDropDownCollect(item.y,item.x)

				count = count + 1
				local transferAction = GameBoardActionDataSet:createAs(
					GameActionTargetType.kGameItemAction,
					GameItemActionType.kItem_SuperCute_Transfer,
					IntCoord:create(item.y,item.x),				
					IntCoord:create(targetItem.y,targetItem.x),				
					GamePlayConfig_MaxAction_time)
				transferAction.completeCallback = callback
				mainLogic:addGameAction(transferAction)
			end 
		end
	end
	return count
end

function GameExtandPlayLogic:clacBoardRowCount(gameBoardMap)
	if type(gameBoardMap) == "table" then
		return #gameBoardMap
	else
		return 0
	end
end

function GameExtandPlayLogic:clacBoardColCount(gameBoardMap)
	if type(gameBoardMap) == "table" then
		if type(gameBoardMap[1]) == "table" then
			return #gameBoardMap[1]
		end
	end
	return 0
end

function GameExtandPlayLogic:decIceLevelAt(mainLogic, r, c)
	local item = mainLogic.gameItemMap[r][c]
	local board = mainLogic.boardmap[r][c]

	----1-1.数据变化
	local oldLevel = board.iceLevel
	board.iceLevel = board.iceLevel - 1

	if mainLogic.gameMode:is(OlympicHorizontalEndlessMode) then
		local IceAction = GameBoardActionDataSet:createAs(
			GameActionTargetType.kGameItemAction,
			GameItemActionType.kItemMatchAt_Olympic_IceDec,
			IntCoord:create(r,c),				
			nil,				
			GamePlayConfig_MaxAction_time)
		IceAction.addInt = oldLevel
		mainLogic:addDestroyAction(IceAction)
		board.isNeedUpdate = true
		item.isNeedUpdate = true

		--printx( 1 , "   GameExtandPlayLogic:decIceLevelAt  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  " , r,c)
		if mainLogic.PlayUIDelegate then
			local pos_t = mainLogic:getGameItemPosInView(r,c);
			local currIceNum = mainLogic.gameMode.encryptData.currIceNum or 0
			mainLogic.gameMode.encryptData.currIceNum = currIceNum + 1
			mainLogic.gameMode:updateScoreBoard()
		end

		-- if board.iceLevel < 1 then
		-- 	local itemView = mainLogic.boardView.baseMap[r][c]
		-- 	itemView:stopTopLevelHightLightEffect()
		-- end
	else
		----1-3.播放特效
		local IceAction = GameBoardActionDataSet:createAs(
			GameActionTargetType.kGameItemAction,
			GameItemActionType.kItemMatchAt_IceDec,
			IntCoord:create(r,c),				
			nil,				
			GamePlayConfig_MaxAction_time)
		IceAction.addInt = oldLevel
		mainLogic:addDestroyAction(IceAction)
		board.isNeedUpdate = true
		item.isNeedUpdate = true

		if mainLogic.PlayUIDelegate then
			if mainLogic.gameMode:is(LightUpMode) then
				local pos_t = mainLogic:getGameItemPosInView(r,c);
				local ice_left_count = mainLogic.gameMode:checkAllLightCount(mainLogic)
				mainLogic.PlayUIDelegate:setTargetNumber(0, 0, ice_left_count, pos_t)
			end
		end
	end
end

function GameExtandPlayLogic:decreaseOlympicLock(mainLogic, r, c)
	local item = mainLogic.gameItemMap[r][c]
	local decAction = GameBoardActionDataSet:createAs(
		GameActionTargetType.kGameItemAction,
		GameItemActionType.kItemMatchAt_OlympicLockDec,
		IntCoord:create(r, c),
		nil,
		GamePlayConfig_GameItemLockDeleteAction_CD)
	decAction.addInt = item.olympicLockLevel
	mainLogic:addDestroyAction(decAction)

	item.olympicLockLevel = item.olympicLockLevel - 1
end

function GameExtandPlayLogic:decreaseOlympicBlocker(mainLogic, r, c)
	local item = mainLogic.gameItemMap[r][c]
	local decAction = GameBoardActionDataSet:createAs(
		GameActionTargetType.kGameItemAction,
		GameItemActionType.kItemMatchAt_OlympicBlockDec,
		IntCoord:create(r, c),
		nil,
		GamePlayConfig_GameItemBlockerDeleteAction_CD)
	decAction.addInt = item.olympicBlockerLevel
	mainLogic:addDestroyAction(decAction)

	item.olympicBlockerLevel = item.olympicBlockerLevel - 1
end

function GameExtandPlayLogic:checkHasLightsInCol(mainLogic, col)
	for r = 1, #mainLogic.boardmap do
		local board = mainLogic.boardmap[r][col]
		if board and board.iceLevel > 0 then return true end
	end
	return false
end

function GameExtandPlayLogic:hitChestSquare(mainLogic,item,r,c,noScore,isFromSpringBomb )
	isFromSpringBomb = isFromSpringBomb or false
	if not noScore then
		local addScore = GamePlayConfigScore.ChestSquare
		mainLogic:addScoreToTotal(r, c, addScore)
	end
	if item.chestSquarePartStrength > 0 then 
		item.chestSquarePartStrength = item.chestSquarePartStrength - 1
		item.hitBySpringBomb = isFromSpringBomb

		                      --   if _G.isLocalDevelopMode then printx(0, "111111111",isFromSpringBomb) end
                        -- debug.debug()
		local decAction = GameBoardActionDataSet:createAs(
			GameActionTargetType.kGameItemAction,
			GameItemActionType.kItem_chestSquare_part_dec,
			IntCoord:create(r, c),
			nil,
			GamePlayConfig_MaxAction_time)
		mainLogic:addDestroyAction(decAction)
	end
end

function GameExtandPlayLogic:hitRandomProp(mainLogic, r, c, scoreScale, noScore, isFromSpringBomb)
	scoreScale = scoreScale or 1
	local item = mainLogic.gameItemMap[r][c]
	item.randomPropLevel = item.randomPropLevel -1

	if item.randomPropLevel == 0 then
		SnailLogic:SpecialCoverSnailRoadAtPos( mainLogic, r, c )
		item:AddItemStatus(GameItemStatusType.kDestroy)


		-- 新增临时道具
		local pos = mainLogic:getGameItemPosInView(r, c)
		if mainLogic.PlayUIDelegate then
			local activityId = 0
			local text = nil
			
			if mainLogic.levelType == GameLevelType.kSummerWeekly then
				
				text = Localization:getInstance():getText("2016_weeklyrace.summer.prop.desc", {n="\n"})
			else
				activityId = mainLogic.activityId
			end

			if not GamePlayContext:isResumeReplayMode() then
				-- 获得临时道具
				_G.random_prop_destory_r = r
				_G.random_prop_destory_c = c
				mainLogic.PlayUIDelegate:addTimeProp(item.randomPropDropId, 1, pos, activityId, text)
			end
			
			-- 记录本局获得的道具
			table.insert(mainLogic.getProps,item.randomPropDropId)
		end

		if _G.isLocalDevelopMode then printx(0, "item.randomPropDropId",item.randomPropDropId) end
		-- debug.debug()
	end

	if not noScore then
		local addScore = GamePlayConfigScore.MatchAtDigGround * scoreScale
		mainLogic:addScoreToTotal(r, c, addScore)
	end
	
	local action = GameBoardActionDataSet:createAs(
	 		GameActionTargetType.kGameItemAction,
	 		GameItemActionType.kItem_randomPropDec,
	 		IntCoord:create(r,c),
	 		nil,
	 		GamePlayConfig_MaxAction_time)
	action.cleanItem = true
	mainLogic:addDestroyAction(action)
end

function GameExtandPlayLogic:hitTangChicken( mainLogic,r,c )
	local item = mainLogic.gameItemMap[r][c]
	local num = math.min(item.tangChickenNum or 0,5)

	if num <= 0 then
		return
	end


	local cd = GamePlayConfig_TangChicken_Destroy1_Time
			+ GamePlayConfig_TangChicken_Destroy2_Time * (num - 1)
			+ GamePlayConfig_TangChicken_Destroy3_Time

	local action = GameBoardActionDataSet:createAs(
 		GameActionTargetType.kGameItemAction,
 		GameItemActionType.kItem_TangChicken_Destroy,
 		IntCoord:create(r,c),
 		nil,
 		cd)
	action.tangChickenNum = item.tangChickenNum
	-- 防止重复处理
	item.tangChickenNum = 0

	mainLogic:addDestroyAction(action)
end


function GameExtandPlayLogic:decreaseBlockerCoverMaterialLevelAt(mainLogic, r, c)
	local item = mainLogic.gameItemMap[r][c]
	local board = mainLogic.boardmap[r][c]
	local oldLevel = board.blockerCoverMaterialLevel

	if mainLogic.blockerCoverMaterialTotalNum == 1 and board.blockerCoverMaterialLevel == 1 then
		board.blockerCoverMaterialLevel = -1
	else
		board.blockerCoverMaterialLevel = board.blockerCoverMaterialLevel - 1
	end

	local addScore = GamePlayConfigScore.BlockerCoverMaterial
	mainLogic:addScoreToTotal(r, c, addScore, item._encrypt.ItemColorType)

	local action = GameBoardActionDataSet:createAs(
		GameActionTargetType.kGameItemAction,
		GameItemActionType.kItemMatchAt_BlockerCoverMaterialDec,
		IntCoord:create(r,c),				
		nil,				
		GamePlayConfig_MaxAction_time)
	action.oldLevel = oldLevel
	action.newLevel = board.blockerCoverMaterialLevel
	mainLogic:addDestroyAction(action)

	mainLogic:tryDoOrderList(r, c, GameItemOrderType.kOthers, GameItemOrderType_Others.kBlockerCoverMaterial, 1)
	ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_BlockerCoverMaterial, ObstacleFootprintAction.k_Hit, 1)

	if board.blockerCoverMaterialLevel <= 0 then
		mainLogic.blockerCoverMaterialTotalNum = mainLogic.blockerCoverMaterialTotalNum - 1
		ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_BlockerCoverMaterial, ObstacleFootprintAction.k_Eliminate, 1)
	end
end

function GameExtandPlayLogic:decreaseBlockerCover(mainLogic, r, c)
	local item = mainLogic.gameItemMap[r][c]
	local board = mainLogic.boardmap[r][c]

	if item.blockerCoverLevel <= 0 then
		return
	end

	if item.ItemType == GameItemType.kBlocker195 then
		item.isBlocker195Lock = true
		mainLogic.needClearBlcoker195Data = true
	end

	local scoreAdd = GamePlayConfigScore.MatchBySnow
		mainLogic:addScoreToTotal(r, c, scoreAdd)

	local oldLevel = item.blockerCoverLevel

	item.blockerCoverLevel = item.blockerCoverLevel - 1
	
	local action = GameBoardActionDataSet:createAs(
		GameActionTargetType.kGameItemAction,
		GameItemActionType.kItem_Blocker_Cover_Dec,
		IntCoord:create(r,c),				
		nil,				
		GamePlayConfig_MaxAction_time)
	action.oldLevel = oldLevel
	action.newLevel = item.blockerCoverLevel
	mainLogic:addDestroyAction(action)
	ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_BlockerCover, ObstacleFootprintAction.k_Hit, 1)

	if item.blockerCoverLevel == 0 then
		mainLogic:tryDoOrderList(r, c, GameItemOrderType.kOthers, GameItemOrderType_Others.kBlockerCover, 1)
		ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_BlockerCover, ObstacleFootprintAction.k_Eliminate, 1)
	end
end

function GameExtandPlayLogic:hitBlocker199(mainLogic, r, c, score)
	if _G.isLocalDevelopMode then printx(0, 'GameExtandPlayLogic:hitBloker199', r, c) end
	local item = mainLogic.gameItemMap[r][c]
	if item.ItemType == GameItemType.kBlocker199 then
		if item:isBlocker199Active() then
			GameExtandPlayLogic:matchBlocker199(mainLogic, r, c, score)
		else
			GameExtandPlayLogic:destroyBlocker199(mainLogic, r, c, 1, score)
		end
	end
end

function GameExtandPlayLogic:destroyBlocker199(mainLogic, r, c, count, score)
	if _G.isLocalDevelopMode then printx(0, 'GameExtandPlayLogic:destroyBlocker199', r, c) end
	local item = mainLogic.gameItemMap[r][c]
	if item.ItemType == GameItemType.kBlocker199 and item.level > 0 then
		local origLevel = item.level
		item.level = math.max(0, item.level - count)
		if item.level == 0 then 
			item.isActive = true
			ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_Blocker199, ObstacleFootprintAction.k_Active, 1)
		end

		local action = GameBoardActionDataSet:createAs(
			GameActionTargetType.kGameItemAction,
			GameItemActionType.kItem_Blocker199_Dec,
			IntCoord:create(r,c),				
			nil,				
			GamePlayConfig_MaxAction_time)
		action.addInt = item.level
		
		mainLogic:addDestructionPlanAction(action)
		ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_Blocker199, ObstacleFootprintAction.k_Hit, origLevel - item.level)
	end
end

function GameExtandPlayLogic:matchBlocker199(mainLogic, r, c, score)
	if _G.isLocalDevelopMode then printx(0, 'GameExtandPlayLogic:matchBlocker199', r, c) end
	local item = mainLogic.gameItemMap[r][c]
	--避免重复爆炸、防止颜色值为空
	if not item.isItemLock and item:isBlocker199Active() and item._encrypt.ItemColorType ~= 0 then
		item.isItemLock = true
		local pos, dirs = nil, nil
		if item.subtype == 1 then
			pos = IntCoord:create(1, -1)
			dirs = {ChainDirConfig.kUp, ChainDirConfig.kRight}
		elseif item.subtype == 2 then
			pos = IntCoord:create(1, 1)
			dirs = {ChainDirConfig.kDown, ChainDirConfig.kRight}
		elseif item.subtype == 3 then
			pos = IntCoord:create(-1, 1)
			dirs = {ChainDirConfig.kDown, ChainDirConfig.kLeft}
		elseif item.subtype == 4 then
			pos = IntCoord:create(-1, -1)
			dirs = {ChainDirConfig.kUp, ChainDirConfig.kLeft}
		end

		local action = GameBoardActionDataSet:createAs(
			GameActionTargetType.kGameItemAction,
			GameItemActionType.kItem_Blocker199_Explode,
			IntCoord:create(r,c),				
			pos,				
			GamePlayConfig_MaxAction_time)
		action.addInt = 1
		action.dirs = dirs
		mainLogic:addDestructionPlanAction(action)

		ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_Blocker199, ObstacleFootprintAction.k_Attack, 1)
	end
end


function GameExtandPlayLogic:decBuffBoom(mainLogic,item,r,c,noScore , count )
	--printx( 1 , "GameExtandPlayLogic:decBuffBoom  ~~~~~~~~~~~~~~~~~~~~~~~~~ " ,r , c )
	if not count then count = 1 end
	local item = mainLogic.gameItemMap[r][c]

	if item.ItemType == GameItemType.kBuffBoom then
		if item.level > 0 and not item.flag then
			item.level = item.level - count
			if item.level < 0 then item.level = 0 end
			item.flag = true
			mainLogic:checkItemBlock(r,c)
			FallingItemLogic:stopFCFallingByBlock(mainLogic, r, c)
			item:AddItemStatus( GameItemStatusType.kNone , true )

			local action =  GameBoardActionDataSet:createAs(
				GameActionTargetType.kPropsAction,
				GameItemActionType.kBuffBoom_Dec,
				IntCoord:create(r,c),
				nil,
				GamePlayConfig_MaxAction_time)

			--action.completeCallback = callback
			action.tarLevel = item.level
			mainLogic:addGlobalCoreAction(action)
			SnapshotManager:stop()
			--printx( 1 , "GameExtandPlayLogic:decBuffBoom  2222222222222222222 " ,r , c ,"item.buffDecCount" , item.buffDecCount , item , item.ItemType )
		end
	end
end

function GameExtandPlayLogic:getBlocker206GroupIds(mainLogic)
	if mainLogic.blocker206Cfg and table.size(mainLogic.blocker206Cfg) > 0 then
		local function getKey(passId)
			local key
			for k, _ in pairs(mainLogic.blocker206Cfg) do 
				if key == nil and k ~= passId then
					key = k
				else
					if passId then
						if k ~= passId and k < key then 
							key = k
						end
					else
						if k < key then 
							key = k
						end
					end
					
				end
			end

			return key
		end

		local currId = getKey()
		local nextId = getKey(currId)

		return currId , nextId
	end
	return nil
end

function GameExtandPlayLogic:destroyBlocker207(mainLogic , br , bc)
	if mainLogic.blocker206Cfg and table.size(mainLogic.blocker206Cfg) > 0 then


		local function getLockGroupKey()
			local key
			for k, _ in pairs(mainLogic.blocker206Cfg) do 
				if key == nil then
					key = k
				else
					if key > k then 
						key = k
					end
				end
			end

			return key
		end

		local lockGroupKey , nextGroupKey = GameExtandPlayLogic:getBlocker206GroupIds(mainLogic)

		if lockGroupKey then 

			----[[
			local dec207action = GameBoardActionDataSet:createAs(
				GameActionTargetType.kGameItemAction,
				GameItemActionType.kItem_Blocker207_Dec,
				IntCoord:create( br , bc ),			
				nil,				
				GamePlayConfig_MaxAction_time)

			dec207action.groupKey = lockGroupKey
			mainLogic:addDestroyAction(dec207action)
			mainLogic.blocker207DestroyNum = mainLogic.blocker207DestroyNum + 1
			ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_Blocker207, ObstacleFootprintAction.k_Eliminate, 1)
			--]]

			local needKeyNum = mainLogic.blocker206Cfg[lockGroupKey]
			if mainLogic.blocker207DestroyNum >= needKeyNum then 
				
				mainLogic.blocker207DestroyNum = mainLogic.blocker207DestroyNum - needKeyNum
				mainLogic.blocker206Cfg[lockGroupKey] = nil
				
				local action = GameBoardActionDataSet:createAs(
					GameActionTargetType.kGameItemAction,
					GameItemActionType.kItem_Blocker206_Dec,
					nil,				
					nil,				
					GamePlayConfig_MaxAction_time)

				action.unlockGroupKey = lockGroupKey
				action.nextGroupKey = nextGroupKey

				printx( 1 , "GameExtandPlayLogic:destroyBlocker207 ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ lockGroupKey",lockGroupKey,"nextGroupKey",nextGroupKey )
				mainLogic:addDestroyAction(action)

			end
		end
	end 
end

function GameExtandPlayLogic:doAllBlocker211Collect(mainLogic, pr, pc, itemColorType, ingoreColor, increment)--所有的寄居蟹进行收集
	if mainLogic.theGamePlayStatus ~= GamePlayStatus.kNormal then
		return
	end

	for r = 1, #mainLogic.gameItemMap do
		for c = 1, #mainLogic.gameItemMap[r] do
			GameExtandPlayLogic:doABlocker211Collect(mainLogic, pr, pc, r, c, itemColorType, ingoreColor, increment)
		end
	end
end

function GameExtandPlayLogic:doABlocker211Collect(mainLogic, pr, pc, r, c, itemColorType, ingoreColor, increment)--单个寄居蟹进行收集
	if mainLogic.theGamePlayStatus ~= GamePlayStatus.kNormal then
		return
	end
	
	local item = mainLogic.gameItemMap[r][c]
	if item:canDoBlocker211Collect(itemColorType, ingoreColor) then 
		item.level = item.level + increment
		if item.level >= item.subtype then
			item.level = item.subtype
			item.isActive = true 
		end
		-- printx(5, 'GameExtandPlayLogic:doABlocker211Collect',  pr, pc, r, c, item.subtype, item.level, debug.traceback())

		local theAction = GameBoardActionDataSet:createAs(
			GameActionTargetType.kGameItemAction,
			GameItemActionType.kItem_Blocker211_Collect,
			IntCoord:create(pr,pc), 			
			IntCoord:create(r,c),				
			GamePlayConfig_MaxAction_time)
		theAction.isActive = item.isActive
		mainLogic:addDestructionPlanAction(theAction)
	end
end

--果酱传播 查找消除队列 检测是否有果酱
function GameExtandPlayLogic:doJamSperadCheck( mainLogic )

    if mainLogic.theGamePlayType ~= GameModeTypeId.JAMSPREAD_ID then
        return
    end

    local MachIDList = {}

    if mainLogic.swapHelpMap then
        --找出有果酱的消除匹配IDlist
        for r1 = 1, #mainLogic.swapHelpMap do
			for c1 = 1,#mainLogic.swapHelpMap[r1] do
                local mathID = math.abs( mainLogic.swapHelpMap[r1][c1] )
                if not table.exist( MachIDList, mathID ) then
                    local mathBoard = mainLogic.boardmap[r1][c1]
                    local ItemData  = mainLogic.gameItemMap[r1][c1]
                    if mathBoard.isJamSperad and math.abs(mathID) > 0 and not ItemData:hasLock() then
                        table.insert( MachIDList, mathID )
                    end
                end
			end
		end

        for r1 = 1, #mainLogic.swapHelpMap do
			for c1 = 1,#mainLogic.swapHelpMap[r1] do
                local mathID = math.abs( mainLogic.swapHelpMap[r1][c1] )
                if table.exist( MachIDList, mathID ) then
                    local ItemData  = mainLogic.gameItemMap[r1][c1]
                    if not ItemData:hasLock() then
                        self:addJamSperadFlag( mainLogic, r1, c1 )
                    end
                end
            end
        end
    end
end

--果酱传播 普通消除匹配
function GameExtandPlayLogic:doJamSperadCreate(mainLogic, r, c )
    if mainLogic.theGamePlayType ~= GameModeTypeId.JAMSPREAD_ID then
        return
    end

    local board = mainLogic.boardmap[r][c];

	--果酱寻找同匹配位置
    if mainLogic.swapHelpMap then
		local moneyMathID = math.abs( mainLogic.swapHelpMap[r][c] )
		for r1 = 1, #mainLogic.swapHelpMap do
			for c1 = 1,#mainLogic.swapHelpMap[r1] do
				local mathID = math.abs( mainLogic.swapHelpMap[r1][c1] )
                local mathBoard = mainLogic.boardmap[r1][c1]
                
				if mathID > 0 and mathID == moneyMathID and not(r1 == r and c1 == c) and mathBoard.isJamSperad == false then
                    self:addJamSperadFlag( mainLogic, r1, c1 )
				end
			end
		end
	end
end

--果酱传播 标记boardmap isNeedUpdate isJamSperad
function GameExtandPlayLogic:addJamSperadFlag(mainLogic, r, c, bForceAdd )
    if mainLogic.theGamePlayType ~= GameModeTypeId.JAMSPREAD_ID then
        return
    end

    if bForceAdd == nil then bForceAdd = false end

    if mainLogic:isPosValid(r,c) then
        local itemInfo = mainLogic.gameItemMap[r][c]
        local mathBoard = mainLogic.boardmap[r][c]

        if itemInfo and mathBoard then
            if itemInfo.isEmpty then
                return
            end

            if mathBoard.isJamSperad then
                return
            end
    
            if not mainLogic:CheckPosCanStopJamSperad( IntCoord:create(r,c) ) or bForceAdd then
                mathBoard.isJamSperad = true
                mathBoard.isNeedUpdate = true

                mainLogic:tryDoOrderList(r, c, GameItemOrderType.kOthers, GameItemOrderType_Others.kJamSperad, 1)
            end
        end
    end
end

function GameExtandPlayLogic:onChargeMagicLamp(mainLogic, r, c, chargeVal)
	local action = GameBoardActionDataSet:createAs(
	                GameActionTargetType.kGameItemAction,
	                GameItemActionType.kItem_Magic_Lamp_Charging,
	                IntCoord:create(r, c),
	                nil,
	                GamePlayConfig_MaxAction_time
	            )
	action.count = chargeVal
	mainLogic:addDestroyAction(action)
end

function GameExtandPlayLogic:onDecBlackCuteball(mainLogic, item, decVal, scoreScale, noScore)
	local r, c = item.y, item.x
	if not scoreScale then scoreScale = 1 end

	if item.blackCuteStrength > 0 then
		local recordVal = math.min(decVal, item.blackCuteStrength) - 1
		if recordVal > 0 then
			--action里面会减一层，这里处理多层时的其他几层
			ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_BlackFurball, ObstacleFootprintAction.k_Hit, recordVal)
		end
		item.blackCuteStrength = item.blackCuteStrength - decVal
		if item.blackCuteStrength <= 0 then 
			item.blackCuteStrength = 0
			item:AddItemStatus(GameItemStatusType.kDestroy)
			SnailLogic:SpecialCoverSnailRoadAtPos( mainLogic, r, c )
		end
		
		if not noScore then
			local addScore = GamePlayConfigScore.MatchAt_BlackCuteBall * scoreScale
			mainLogic:addScoreToTotal(r, c, addScore)
		end

		local duringTime = 1
		if item.blackCuteStrength == 0 then 
			duringTime = GamePlayConfig_BlackCuteBall_Destroy
		end
		local blackCuteAction = GameBoardActionDataSet:createAs(
			GameActionTargetType.kGameItemAction,
			GameItemActionType.kItem_Black_Cute_Ball_Dec,
			IntCoord:create(r, c),
			nil,
			duringTime)
		blackCuteAction.blackCuteStrength = item.blackCuteStrength -- 为action提供定制数据
		mainLogic:addDestroyAction(blackCuteAction)
	end
end

function GameExtandPlayLogic:onUpgradeRoost(mainLogic, item, upgradeTimes, noScore)
	local r, c = item.y, item.x
	local originRoostLevel = item.roostLevel

	for i = 1, upgradeTimes do
		item:roostUpgrade()
	end
	local times = item.roostLevel - originRoostLevel
	ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_Roost, ObstacleFootprintAction.k_Hit, times)

	if times > 0 then
		if not noScore then
			if mainLogic.levelType ~= GameLevelType.kMoleWeekly then
				local scoreTotal = times * GamePlayConfigScore.Roost
				mainLogic:addScoreToTotal(r, c, scoreTotal)
			end
		end

		local UpgradeAction = GameBoardActionDataSet:createAs(
			GameActionTargetType.kGameItemAction,
			GameItemActionType.kItem_Roost_Upgrade,
			IntCoord:create(r, c),
			nil,
			1)
		UpgradeAction.addInt = times
		mainLogic:addDestroyAction(UpgradeAction)
	end
end

function GameExtandPlayLogic:onUpgradeMagicStone(mainLogic, item, isLastShoot)
	local r, c = item.y, item.x
	local stoneActiveAction = GameBoardActionDataSet:createAs(
		GameActionTargetType.kGameItemAction,
		GameItemActionType.kItem_Magic_Stone_Active,
		IntCoord:create(r, c),
		nil,
		1)

	local playStoneFire = false

	if isLastShoot then
		playStoneFire = true
		item.magicStoneLevel = TileMagicStoneConst.kMaxLevel
		stoneActiveAction.magicStoneLevel = TileMagicStoneConst.kMaxLevel
	else
		stoneActiveAction.magicStoneLevel = item.magicStoneLevel
		if item.magicStoneLevel >= TileMagicStoneConst.kMaxLevel then
			playStoneFire = true
		end
	end

	if not playStoneFire then -- levelUp
		item.magicStoneLevel = item.magicStoneLevel + 1
		if item.magicStoneLevel == TileMagicStoneConst.kMaxLevel then -- 收集目标
			mainLogic:tryDoOrderList(r, c, GameItemOrderType.kOthers, GameItemOrderType_Others.kMagicStone, 1)
		end
		GamePlayMusicPlayer:playEffect( GameMusicType.kPlayMagicstoneActive )
	else
		item.magicStoneActiveTimes = item.magicStoneActiveTimes + 1
		item.magicStoneLocked = true
		stoneActiveAction.targetPos = GameExtandPlayLogic:calcMagicStoneEffectPositions(mainLogic, r, c)
		GamePlayMusicPlayer:playEffect( GameMusicType.kPlayMagicstoneCasting )
	end

	mainLogic:addDestroyAction(stoneActiveAction)
end

function GameExtandPlayLogic:findBiscuitBoardDataCoveredMe(mainLogic, r, c)
	for rr = math.max(r - 3, 1), r do
		for cc = math.max(c - 3, 1), 9 do
			local boardData = mainLogic.boardmap[rr][cc]
			if boardData:isBiscuitAndCover(r, c) then
				return boardData
			end
		end
	end
end

function GameExtandPlayLogic:isEmptyBiscuit( mainLogic, r, c )
	local boardData = self:findBiscuitBoardDataCoveredMe(mainLogic, r, c)
	if boardData then
		local milkRow, milkCol = boardData:convertToMilkRC(r, c)
		return boardData:canApplyMilkAt(milkRow, milkCol)
	end
	return false
end

function GameExtandPlayLogic:applyMilkOnBiscuitAt(mainLogic, biscuitBoardData, milkRow, milkCol, r, c)
	local item = mainLogic.gameItemMap[r][c]
	local board = mainLogic.boardmap[r][c]

	local biscuitData = biscuitBoardData.biscuitData

	if biscuitData then
		biscuitData.milks[milkRow][milkCol] = biscuitData.milks[milkRow][milkCol] + 1

		mainLogic:tryDoOrderList(r, c, GameItemOrderType.kOthers, GameItemOrderType_Others.kMilks, 1)

		local applyMilkAction = GameBoardActionDataSet:createAs(
			GameActionTargetType.kGameItemAction,
			GameItemActionType.kItemMatchAt_ApplyMilk,
			IntCoord:create(biscuitBoardData.y, biscuitBoardData.x),				
			IntCoord:create(milkRow, milkCol),				
			GamePlayConfig_MaxAction_time)
		applyMilkAction.addInfo = "ready"
		applyMilkAction.addBiscuitData = biscuitData
		mainLogic:addDestroyAction(applyMilkAction)

		-- board.isNeedUpdate = true
		-- item.isNeedUpdate = true

		-- if mainLogic.PlayUIDelegate then
		-- 	local pos_t = mainLogic:getGameItemPosInView(r,c);
		-- 	local ice_left_count = mainLogic.gameMode:checkAllLightCount(mainLogic)
		-- 	mainLogic.PlayUIDelegate:setTargetNumber(0, 0, ice_left_count, pos_t)
		-- end
	end
end