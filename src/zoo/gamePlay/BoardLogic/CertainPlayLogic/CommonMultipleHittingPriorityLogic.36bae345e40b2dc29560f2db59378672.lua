CommonMultipleHittingPriorityLogic = {}

function CommonMultipleHittingPriorityLogic:getTargetGridPrior(mainLogic, r, c, selfItem, exceptGrids)
	local priorityVal = 0
	local itemData = mainLogic.gameItemMap[r][c]
	local boradData = mainLogic.boardmap[r][c]

	if selfItem and selfItem.y == r and selfItem.x == c then
		return -999
	end

	if exceptGrids then
		for _, v in ipairs(exceptGrids) do
			if (v.row == r and v.col == c) then
				return -999
			end
		end
	end

	if CommonMultipleHittingPriorityLogic._isTargetInvalid(itemData, boardData) then
		return -999
	else
		-- 真正反映优先级的队列
		local priorityFuncList = {}
		table.insert(priorityFuncList, CommonMultipleHittingPriorityLogic._isTargetPrior1)
		table.insert(priorityFuncList, CommonMultipleHittingPriorityLogic._isTargetPrior1Point5)
		table.insert(priorityFuncList, CommonMultipleHittingPriorityLogic._isTargetPrior2)
		table.insert(priorityFuncList, CommonMultipleHittingPriorityLogic._isTargetPrior3)
		table.insert(priorityFuncList, CommonMultipleHittingPriorityLogic._isTargetPrior4)
		table.insert(priorityFuncList, CommonMultipleHittingPriorityLogic._isTargetPrior5)
		table.insert(priorityFuncList, CommonMultipleHittingPriorityLogic._isTargetPrior6)

		local priorityGap = 10 -- 优先级削减梯度
		local currPriVal = priorityGap * (#priorityFuncList + 1)
		
		for i = 1, #priorityFuncList do
			local currFunc = priorityFuncList[i]
			if currFunc(mainLogic, itemData, boradData) then
				priorityVal = currPriVal
				break
			end
			currPriVal = currPriVal - priorityGap
		end

		-- 在豆荚列的优先消除 只打豆荚下面
		if mainLogic.theGamePlayType == GameModeTypeId.DROP_DOWN_ID then
			for cr = 1, r do 
				if (mainLogic.gameItemMap[cr][c].ItemType == GameItemType.kIngredient) then
					priorityVal = priorityVal * 10
					break
				end
			end
		end
		
	end

	return priorityVal
end

function CommonMultipleHittingPriorityLogic._isTargetInvalid(itemData, boardData)
	-- 真正的一票否决制
	if itemData.isReverseSide or itemData:hasBlocker206() or itemData:hasSquidLock() then
		return true
	end

	-- 有覆盖物的情况下走覆盖物的优先级
    if not itemData:hasLock() and not itemData:isFreeGhost() then
    	-- 无覆盖物时的否决
    	if itemData.ItemType == GameItemType.kChameleon 
    		or itemData.ItemType == GameItemType.kPacman
    		or itemData.ItemType == GameItemType.kTotems
    		or itemData.ItemType == GameItemType.kPoisonBottle
    		or itemData.ItemType == GameItemType.kPacmansDen
    		or itemData.ItemType == GameItemType.kSunflower
    		or itemData.ItemType == GameItemType.kSquid
    		or itemData.ItemType == GameItemType.kSquidEmpty
    		then
    		return true
    	end
    end
    
	return false
end 

function CommonMultipleHittingPriorityLogic._isValidSeaAnimalGrid(mainLogic, itemData, boardData)
	local isValidSeaAnimal = false
	local r, c = itemData.y, itemData.x

	function isValidSeaAnimalGrid(row, col)
		if mainLogic.boardmap[row][col].iceLevel and mainLogic.boardmap[row][col].iceLevel > 0 or
			(mainLogic.boardmap[row][col].tileBlockType == 1 and mainLogic.boardmap[row][col].isReverseSide) then
			if itemData.ItemType ~= GameItemType.kNone and SpecialCoverLogic:canEffectLightUpAt(mainLogic, row, col) then
				return true
			end
		end
		return false
	end

	if (boardData.iceLevel > 0 and mainLogic.gameMode.allSeaAnimals) then
		for k, v in pairs(mainLogic.gameMode.allSeaAnimals) do
			for row = v.y, v.yEnd do 
				for col = v.x, v.xEnd do
					if r == row and c == col then
						if isValidSeaAnimalGrid(row, col) then
							isValidSeaAnimal = true
							break
						end
					end
				end
			end
		end
	end

	return isValidSeaAnimal
end

-- 优先级 后缀数字不绝对反映优先级顺序，具体顺序以 priorityFuncList 为准
function CommonMultipleHittingPriorityLogic._isTargetPrior1(mainLogic, itemData, boardData)
	if CommonMultipleHittingPriorityLogic._isValidSeaAnimalGrid(mainLogic, itemData, boardData) then
		return true
	end

	if not itemData.colorFilterBLock 
		and (itemData.cageLevel > 0
				or itemData.venomLevel > 0
				or itemData.ItemType == GameItemType.kVenom
				or itemData.ItemType == GameItemType.kBalloon
				or (itemData.bigMonsterFrostingStrength and itemData.bigMonsterFrostingStrength > 0)
				or (itemData.chestSquarePartStrength and itemData.chestSquarePartStrength > 0))
				or itemData.ItemType == GameItemType.kMoleBossSeed
				or (itemData:isFreeGhost() and GhostLogic:ghostCanMoveUpward(itemData))
		then
		return true
	end

	return false
end

function CommonMultipleHittingPriorityLogic._isTargetPrior1Point5(mainLogic, itemData, boardData)
	if itemData.ItemType == GameItemType.kSunFlask
		then
		return true
	end

	if GameExtandPlayLogic:isEmptyBiscuit(mainLogic, boardData.y, boardData.x) 
		and table.includes({
			GameItemType.kAnimal,
			GameItemType.kCrystal,
			GameItemType.kNewGift,
		}, itemData.ItemType) then
		return true
	end

	return false
end

function CommonMultipleHittingPriorityLogic._isTargetPrior2(mainLogic, itemData, boardData)
	if  itemData.snowLevel > 0 
		or itemData.ItemType == GameItemType.kHoneyBottle
		or itemData.furballType == GameItemFurballType.kBrown
		or itemData.ItemType == GameItemType.kRocket 
		or (itemData.ItemType == GameItemType.kPuffer and itemData.pufferState == PufferState.kNormal)
		or itemData.ItemType == GameItemType.kBottleBlocker
		or itemData.digGroundLevel > 0
		or itemData.digJewelLevel > 0
		or itemData.blockerCoverLevel > 0
		or (itemData.ItemType == GameItemType.kBlocker199 and not itemData:isBlocker199Active()) 
		or itemData.ItemType == GameItemType.kBlocker207
		or itemData.ItemType == GameItemType.kMoleBossCloud
        or itemData.yellowDiamondLevel > 0
        or itemData.ItemType == GameItemType.kWanSheng
		then
		return true
	end

	if 	(boardData.iceLevel > 0  and itemData.ItemType ~= GameItemType.kNone)
		or (boardData.lotusLevel > 1 and itemData.ItemType ~= GameItemType.kNone)
		or boardData.colorFilterBLevel > 0 
		or (boardData.blockerCoverMaterialLevel > 0 and itemData.ItemType ~= GameItemType.kNone)
		then
		return true
	end

	return false
end

function CommonMultipleHittingPriorityLogic._isTargetPrior3(mainLogic, itemData, boardData)
	if itemData.ItemType == GameItemType.kCoin
		or itemData.furballType == GameItemFurballType.kGrey
		or itemData.ItemType == GameItemType.kBlackCuteBall
		or itemData.honeyLevel > 0
		then
		return true
	end

	if (boardData.sandLevel > 0 and itemData.ItemType ~= GameItemType.kNone) 
		or (boardData.lotusLevel == 1 and itemData.ItemType ~= GameItemType.kNone) 
		then
		return true
	end

	return false
end

function CommonMultipleHittingPriorityLogic._isTargetPrior4(mainLogic, itemData, boardData)
	if (itemData.ItemType == GameItemType.kCrystalStone and (not itemData.crystalStoneActive))
		or itemData.ItemType == GameItemType.kMagicStone
		or itemData.ItemType == GameItemType.kRoost
		or itemData.ItemType == GameItemType.kMagicLamp
		or itemData.ItemType == GameItemType.kKindMimosa
		or itemData.beEffectBySuperCute == true
		or itemData:isBlocker199Active()
		or itemData:canDoBlocker211Collect(nil, true)
        or itemData.ItemType == GameItemType.kTurret
		then
		return true
	end
	return false
end

function CommonMultipleHittingPriorityLogic._isTargetPrior5(mainLogic, itemData, boardData)
	if (itemData.ItemType == GameItemType.kAnimal and not itemData:isSpecial())
		or itemData.ItemType == GameItemType.kCrystal
		or (itemData.ItemType == GameItemType.kMissile and itemData.missileLevel > 0)
		or (itemData.ItemType == GameItemType.kBuffBoom and itemData.level > 0)
		or itemData.ItemType == GameItemType.kScoreBuffBottle
		or itemData.ItemType == GameItemType.kFirecracker
		then
		return true
	end
	return false
end

function CommonMultipleHittingPriorityLogic._isTargetPrior6(mainLogic, itemData, boardData)
	if itemData.ItemType == GameItemType.kNewGift
		or (itemData.pufferState == PufferState.kActivated and itemData.ItemType == GameItemType.kPuffer)
		or (itemData.ItemType == GameItemType.kAnimal and itemData:isSpecial())
        or ( boardData.isJamSperad )
		then
		return true
	end
	return false
end

