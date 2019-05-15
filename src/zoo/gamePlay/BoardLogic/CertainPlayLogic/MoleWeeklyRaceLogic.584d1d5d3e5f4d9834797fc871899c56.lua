MoleWeeklyRaceLogic = class{}

function MoleWeeklyRaceLogic:getReleaseSkillCountDown(mainLogic, boss)
	local releaseSkillGap = boss.bossReleaseSkillGap
    if not boss.bossFirstSkillReleased then
        -- printx(11, "releaseSkillGap - - - - - ")
        releaseSkillGap = releaseSkillGap - 1
    end
    -- printx(11, "releaseSkillGap", releaseSkillGap)

    local gapStep = mainLogic.realCostMove - boss.bossLastReleaseSkillStep
    local releaseCountDown = releaseSkillGap - gapStep

    -- printx(11, "getReleaseSkillCountDown,", releaseCountDown)
    return releaseCountDown
end

------------------------------------------------------------------------------------------------------------
--											SKILL: THICK HONEY
------------------------------------------------------------------------------------------------------------
--- 技能：投掷浓蜂蜜
function MoleWeeklyRaceLogic:pickThickHoneyTarget(mainLogic, pickAmount)
	if not pickAmount or pickAmount <= 0 then
		return nil
	end

	local gameItemMap = mainLogic.gameItemMap
	local boardMap = mainLogic.boardmap

	local candidateTargetList = {}
	for r = 1, #gameItemMap do 
		for c = 1, #gameItemMap[r] do
			local item = gameItemMap[r][c]
			if item then 
				local intCoord = IntCoord:create(r, c)
				if item:canInfectByHoneyBottle() and not boardMap[r][c].honeySubSelect then
					if item.ItemSpecialType == 0 then
						MoleWeeklyRaceLogic:_insertSplitByRowPriority(candidateTargetList, 1, r, intCoord)
					else
						MoleWeeklyRaceLogic:_insertSplitByRowPriority(candidateTargetList, 3, r, intCoord)
					end
				end
			end 
		end
	end

	-- MoleWeeklyRaceLogic:_testPrintListTable(candidateTargetList)
	
	local targetList = {}
	local item

	for k = 1, pickAmount do 
		for listIndex = 1, 2 do		-- index = 1 & 2 的为非特效，优先选择非特效
			local subList = candidateTargetList[listIndex]
			if subList and #subList > 0 then
				item = table.remove(subList, mainLogic.randFactory:rand(1, #subList))
				table.insert(targetList, item)
				break
			end
		end
	end

	-- local remainAmount = (pickAmount - #targetList) * 2		--非特效目标，数量翻倍
	local remainAmount = pickAmount - #targetList				--产品又说不翻倍了=___=
	if remainAmount > 0 then
		for index = 1, remainAmount do 
			for listIndex = 1, table.maxn(candidateTargetList) do
				local subList = candidateTargetList[listIndex]
				if subList and #subList > 0 then
					item = table.remove(subList, mainLogic.randFactory:rand(1, #subList))
					table.insert(targetList, item)
					break
				end
			end
		end
	end

	return targetList
end

function MoleWeeklyRaceLogic:_insertSplitByRowPriority(targetTable, startIndex, itemRow, insertItem, isPickRowType2)
	local dividingRow = MoleWeeklyRaceParam.PICK_TARGET_PRIORITY_ROW
	if isPickRowType2 then
		dividingRow = MoleWeeklyRaceParam.PICK_TARGET_PRIORITY_ROW_2
	end

	if itemRow >= dividingRow then
		MoleWeeklyRaceLogic:_insertToListTable(targetTable, startIndex, insertItem)
	else
		MoleWeeklyRaceLogic:_insertToListTable(targetTable, startIndex + 1, insertItem)
	end
end

function MoleWeeklyRaceLogic:_insertToListTable(targetTable, index, insertItem)
	if not targetTable then targetTable = {} end
	for i = 1, index do
		if not targetTable[i] then targetTable[i] = {} end
	end
	if not targetTable[index] then targetTable[index] = {} end

	table.insert(targetTable[index], insertItem)
end

function MoleWeeklyRaceLogic:_testPrintListTable(targetTable)
	local printStr = ""

	for index = 1, #targetTable do
		printStr = printStr.."[---index---]"..index.." :"
		local subList = targetTable[index]
		if subList then
			for index2 = 1, #subList do
				local targetItem = subList[index2]
				if targetItem.c then
					printStr = printStr.." ("..targetItem.r..", "..targetItem.c..") "
				else
					printStr = printStr.." ("..targetItem.x..","..targetItem.y..") "
				end
			end
		end
	end

	printx(11, printStr)
end

------------------------------------------------------------------------------------------------------------
--											SKILL: DEACTIVATE MAGIC TILE
------------------------------------------------------------------------------------------------------------
--- 技能：超级地格无效化
function MoleWeeklyRaceLogic:getAvailableMagicTileGrid(mainLogic)
	local function insertTargetByPriority(targetTable, priority, targetItem)
		if not targetTable[priority] then
			targetTable[priority] = {}
		end
		table.insert(targetTable[priority], targetItem)
	end

	local pickedGridByPriority = {}

	local gameItemMap = mainLogic.gameItemMap
	local boardmap = mainLogic.boardmap
    for r = 1, #boardmap do 
        for c = 1, #boardmap[r] do 
            local boardData = boardmap[r][c]
            local itemData = gameItemMap[r][c]
            if boardData and boardData.magicTileId ~= nil and boardData.magicTileDisabledRound <= 0 then
            	if itemData then
	                if itemData:isVisibleAndFree() 
	                	and itemData.ItemType == GameItemType.kAnimal or itemData.ItemType == GameItemType.kCrystal then
	                	insertTargetByPriority(pickedGridByPriority, 1, IntCoord:create(r, c))
	                elseif itemData.isEmpty then
	                	insertTargetByPriority(pickedGridByPriority, 2, IntCoord:create(r, c))
	                else
	                	insertTargetByPriority(pickedGridByPriority, 3, IntCoord:create(r, c))
	                end
	            end
            end
        end
    end

    -- printx(11, "pickedGridByPriority:", table.tostring(pickedGridByPriority))
    return pickedGridByPriority
end

function MoleWeeklyRaceLogic:pickTargetMagicTile(mainLogic, pickedGridByPriority, pickAmount)
	if not pickAmount or pickAmount <= 0 then
		return nil
	end

	local targetCoordList = {}
	local coord
	for index = 1, pickAmount do 
		for listIndex = 1, table.maxn(pickedGridByPriority) do
			local subList = pickedGridByPriority[listIndex]
			if subList and #subList > 0 then
				coord = table.remove(subList, mainLogic.randFactory:rand(1, #subList))
				table.insert(targetCoordList, coord)
				break
			end
		end
	end

	return targetCoordList
end

function MoleWeeklyRaceLogic:playMagicTileHitBossAnimation(isHitAnimation, startPos, endPos, finishCallback, callbackParas)
	local scene = Director:sharedDirector():getRunningScene()

	local animation = Sprite:createWithSpriteFrameName("magic_tile_mole_hit_bullet_0000")

	local angle = -math.deg(math.atan2(endPos.y - startPos.y, endPos.x - startPos.x))
	animation:setPosition(startPos)
	animation:setRotation(angle + 90)		--素材是冲上的，多转一下

	local function onfinish()
		if animation then animation:removeFromParentAndCleanup(true) end

		local splashAnimation = Sprite:createWithSpriteFrameName("magic_tile_mole_hit_effect_0000")
		local frames = SpriteUtil:buildFrames("magic_tile_mole_hit_effect_%04d", 0, 19)
		local anim = SpriteUtil:buildAnimate(frames, 1/30)
		splashAnimation:play(anim, 0, 1, nil, true)
		splashAnimation:setPosition(endPos)
		scene:addChild(splashAnimation)

		if finishCallback then finishCallback() end
	end

	local actArr = CCArray:create()
	actArr:addObject(CCMoveTo:create(0.4, ccp(endPos.x , endPos.y)))
	actArr:addObject(CCCallFunc:create(onfinish) )
	animation:runAction(CCSequence:create(actArr))

	scene:addChild(animation)
end

------------------------------------------------------------------------------------------------------------
--											SKILL: FRAGILE BLACK CUTEBALL
------------------------------------------------------------------------------------------------------------
--- 技能：投掷黑毛球
function MoleWeeklyRaceLogic:pickFragileCuteBallTargetTile(mainLogic, pickAmount)
	if not pickAmount or pickAmount <= 0 then
		return nil
	end

	local rawCoordList = {}
	local gameItemMap = mainLogic.gameItemMap
	local boardmap = mainLogic.boardmap
	for r = 1, #gameItemMap do 
		for c = 1, #gameItemMap[r] do
			local item = gameItemMap[r][c]
			local boardData = boardmap[r][c]
			if item then
				if item:isAvailable() and not item:hasLock() and not item:hasFurball() and not boardData:hasSuperCuteBall() then
					local intCoord = {x = r, y = c}
					if item.ItemType == GameItemType.kAnimal then
						if item.ItemSpecialType == 0 then
							MoleWeeklyRaceLogic:_insertSplitByRowPriority(rawCoordList, 1, r, intCoord)
						else
							MoleWeeklyRaceLogic:_insertSplitByRowPriority(rawCoordList, 3, r, intCoord)
						end
					elseif item.ItemType == GameItemType.kCrystal then
						MoleWeeklyRaceLogic:_insertSplitByRowPriority(rawCoordList, 5, r, intCoord)
					end
				end
			end 
		end
	end

	-- MoleWeeklyRaceLogic:_testPrintListTable(rawCoordList)

	local targetCoordList = {}
	local coord
	for index = 1, pickAmount do 
		for listIndex = 1, table.maxn(rawCoordList) do
			local subList = rawCoordList[listIndex]
			if subList and #subList > 0 then
				coord = table.remove(subList, mainLogic.randFactory:rand(1, #subList))
				table.insert(targetCoordList, coord)
				break
			end
		end
	end

	return targetCoordList
end

------------------------------------------------------------------------------------------------------------
--											SKILL: SEED SACK
------------------------------------------------------------------------------------------------------------
--- 技能：投掷种子袋
function MoleWeeklyRaceLogic:pickLaySeedGrids(mainLogic, pickAmount)
	if not pickAmount or pickAmount <= 0 then
		return nil
	end

	local gameItemMap = mainLogic.gameItemMap

	local rawCoordList = {}
	for r = 1, #gameItemMap do 
		for c = 1, #gameItemMap[r] do
            local item = gameItemMap[r][c]
            if item and item:isVisibleAndFree() then
            	if item.ItemType == GameItemType.kAnimal or item.ItemType == GameItemType.kCrystal then
					if item.ItemSpecialType == 0 then
						MoleWeeklyRaceLogic:_insertSplitByRowPriority(rawCoordList, 1, r, IntCoord:create(r, c))
					else
						MoleWeeklyRaceLogic:_insertSplitByRowPriority(rawCoordList, 3, r, IntCoord:create(r, c))
					end
        		end
            end
		end
	end

	local targetCoordList = {}
	local coord
	for index = 1, pickAmount do 
		for listIndex = 1, table.maxn(rawCoordList) do
			local subList = rawCoordList[listIndex]
			if subList and #subList > 0 then
				coord = table.remove(subList, mainLogic.randFactory:rand(1, #subList))
				table.insert(targetCoordList, coord)
				break
			end
		end
	end

	-- printx(11, "+ + + + + LaySeedGrids  pickedGrid:", table.tostring(targetCoordList))
	return targetCoordList
end

function MoleWeeklyRaceLogic:breakSeed(mainLogic, r, c, times, scoreScale)
	scoreScale = scoreScale or 1
	local item = mainLogic.gameItemMap[r][c]
	item.moleBossSeedHP = item.moleBossSeedHP - times
	if item.moleBossSeedHP < 0 then item.moleBossSeedHP = 0 end

	local itemView = mainLogic.boardView.baseMap[r][c]
	itemView:playMoleBossSeedBeingHit()
end

function MoleWeeklyRaceLogic:getAllSeedsOnBoard(mainLogic)
	local gameItemMap = mainLogic.gameItemMap

	local brokenSeeds = {}
	local intactSeeds = {}

	for r = 1, #gameItemMap do 
		for c = 1, #gameItemMap[r] do
            local item = gameItemMap[r][c]
            if item and item.ItemType == GameItemType.kMoleBossSeed then
            	if item.moleBossSeedHP > 0 then
            		table.insert(intactSeeds, item)
            	else
            		table.insert(brokenSeeds, item)
            	end
            end
		end
	end

	return brokenSeeds, intactSeeds
end

function MoleWeeklyRaceLogic:pickSeedToSpecialGrids(mainLogic, pickAmount)
	-- printx(11, "pickAmount:", pickAmount)
	if not pickAmount or pickAmount <= 0 then
		return {}
	end

	local gameItemMap = mainLogic.gameItemMap
	local boardMap = mainLogic.boardmap

	local recommendedGrid = {}
	local commonGrid = {}

	-- 	目标：普通动物, 水晶球
	--	优先级层次： 1、超级地块  2、非超级地块
	for r = 1, #gameItemMap do 
		for c = 1, #gameItemMap[r] do
            local item = gameItemMap[r][c]
			local boardData = boardMap[r][c]
            if item and item:isVisibleAndFree() and item.ItemSpecialType == 0 then
            	if item.ItemType == GameItemType.kAnimal or item.ItemType == GameItemType.kCrystal then
	            	if boardData and boardData.magicTileId ~= nil then
	            		table.insert(recommendedGrid, IntCoord:create(r, c))
	            	else
	            		table.insert(commonGrid, IntCoord:create(r, c))
	                end
	            end
            end
		end
	end
	
	local targetCoordList = {}
	local coord

	-- printx(11, "+ + + + + recommendedGrid:", table.tostring(recommendedGrid))
	-- printx(11, "+ + + + + commonGrid:", table.tostring(commonGrid))

	for k = 1, pickAmount do 
		if #recommendedGrid > 0 then
			coord = table.remove(recommendedGrid, mainLogic.randFactory:rand(1, #recommendedGrid))
			table.insert(targetCoordList, coord)
		elseif #commonGrid > 0 then 
			coord = table.remove(commonGrid, mainLogic.randFactory:rand(1, #commonGrid))
			table.insert(targetCoordList, coord)
		end
	end

	-- printx(11, "+ + + + + Seed to special. pickedGrid:", table.tostring(targetCoordList))

	return targetCoordList
end

------------------------------------------------------------------------------------------------------------
--										MAGIC TILE DEMOLISH BLAST
------------------------------------------------------------------------------------------------------------
--- （严格意义上非boss技能）超级地格消失时的爆破
function MoleWeeklyRaceLogic:pickMagicTileBlastTarget(mainLogic, pickAmount)
	if not pickAmount or pickAmount <= 0 then
		return {}
	end

	local initWeightArray = {}
	local gameItemMap = mainLogic.gameItemMap
	for r = 1, #gameItemMap do 
		for c = 1, #gameItemMap[r] do 
			local w = {}
			w.row = r 
			w.col = c 
			w.weight = MoleWeeklyRaceLogic:_getMagicTileBlastTargetPrior(mainLogic, r, c)
			table.insert(initWeightArray, w)
		end
	end

	local unOrderWeightArray = table.randomOrder(initWeightArray, mainLogic)
	local function sortFunc(a, b)
		return a.weight > b.weight
	end
	table.sort(unOrderWeightArray, sortFunc)

	local ret = {}
	for i = 1, pickAmount do
		if (unOrderWeightArray[i].weight > 0) then 
			table.insert(ret,IntCoord:create(unOrderWeightArray[i].col,unOrderWeightArray[i].row))
		end
	end
	return ret
end

function MoleWeeklyRaceLogic:_getMagicTileBlastTargetPrior(mainLogic, r, c )
	local ret = CommonMultipleHittingPriorityLogic:getTargetGridPrior(mainLogic, r, c)

	local itemData = mainLogic.gameItemMap[r][c]
	if MoleWeeklyRaceLogic:_isCloudItem(itemData) then
		local addWeight = #mainLogic.gameItemMap - itemData.y	--云块类，优先攻击靠上的
		-- printx(11, "Found Cloud grid! r,c:("..itemData.y..","..itemData.x.."), addPrioridyWeight: "..addWeight)
		ret = ret + addWeight
	end

	return ret
end

-- function MoleWeeklyRaceLogic:_getMagicTileBlastTargetPrior(mainLogic, r, c )
-- 	local MagicTileBlastTargetWeightPriority1 = 100
-- 	local MagicTileBlastTargetWeightPriority2 = 90
-- 	local MagicTileBlastTargetWeightPriority3 = 80
-- 	local MagicTileBlastTargetWeightPriority4 = 70
-- 	local MagicTileBlastTargetWeightPriority5 = 60
-- 	local MagicTileBlastTargetWeightPriority6 = 50
-- 	local MagicTileBlastTargetWeightInvalid = -1

-- 	local ret = 0
-- 	local itemData = mainLogic.gameItemMap[r][c]
-- 	local boradData = mainLogic.boardmap[r][c]

-- 	if itemData.isReverseSide == true then -- 单面翻转地块反面
-- 		ret = 0 
-- 	elseif itemData:isMissileTargetPrior1() or boradData:isMissileTargetPrior1() then
-- 		ret = MagicTileBlastTargetWeightPriority1
-- 	elseif itemData:isMissileTargetPrior2(boradData) or boradData:isMissileTargetPrior2(itemData) then 
-- 		ret = MagicTileBlastTargetWeightPriority2
-- 		if MoleWeeklyRaceLogic:_isCloudItem(itemData) then
-- 			local addWeight = #mainLogic.gameItemMap - itemData.y	--云块类，优先攻击靠上的
-- 			-- printx(11, "Found Cloud grid! r,c:("..itemData.y..","..itemData.x.."), addPrioridyWeight: "..addWeight)
-- 			ret = ret + addWeight
-- 		end
-- 	elseif itemData:isMissileTargetPrior3(boradData) or boradData:isMissileTargetPrior3(itemData) then 
-- 		ret = MagicTileBlastTargetWeightPriority3
-- 	elseif itemData:isMissileTargetPrior4() or boradData:isMissileTargetPrior4() then 
-- 		ret = MagicTileBlastTargetWeightPriority4
-- 	elseif itemData:isMissileTargetPrior5() or boradData:isMissileTargetPrior5() then 
-- 		ret = MagicTileBlastTargetWeightPriority5
-- 	elseif itemData:isMissileTargetPrior6() or boradData:isMissileTargetPrior6() then 
-- 		ret = MagicTileBlastTargetWeightPriority6
-- 	else
-- 		ret = 0
-- 	end

-- 	if itemData:isMissileTargetInvalid() or boradData:isMissileTargetInvalid() then -- 优先不打的
-- 		ret = MagicTileBlastTargetWeightInvalid
-- 	end
-- 	return ret
-- end

function MoleWeeklyRaceLogic:_isCloudItem(itemData)
	if itemData.digGroundLevel > 0 or itemData.digJewelLevel > 0 or itemData.yellowDiamondLevel > 0 
		or (itemData.ItemType == GameItemType.kMoleBossCloud)
		then
		return true
	end
	return false
end

------------------------------------------------------------------------------------------------------------
--											SKILL: SMALL CLOUD BLOCK
------------------------------------------------------------------------------------------------------------
--- 技能：投掷一格的宝石云块
function MoleWeeklyRaceLogic:pickSmallCloudBlockTargets(mainLogic, pickAmount)
	if not pickAmount or pickAmount <= 0 then
		return nil
	end

	local rawCoordList = {}
	local gameItemMap = mainLogic.gameItemMap
	for r = 1, #gameItemMap do 
		for c = 1, #gameItemMap[r] do
			local item = gameItemMap[r][c]
			if item and item:isVisibleAndFree() then
				local intCoord = {x = r, y = c}
				if item.ItemType == GameItemType.kAnimal or item.ItemType == GameItemType.kCrystal then
					if item.ItemSpecialType == 0 then
						MoleWeeklyRaceLogic:_insertSplitByRowPriority(rawCoordList, 1, r, intCoord, true)
					else
						MoleWeeklyRaceLogic:_insertSplitByRowPriority(rawCoordList, 3, r, intCoord, true)
					end
				end
			end 
		end
	end

	-- MoleWeeklyRaceLogic:_testPrintListTable(rawCoordList)

	local targetCoordList = {}
	local coord
	for index = 1, pickAmount do 
		for listIndex = 1, table.maxn(rawCoordList) do
			local subList = rawCoordList[listIndex]
			if subList and #subList > 0 then
				coord = table.remove(subList, mainLogic.randFactory:rand(1, #subList))
				table.insert(targetCoordList, coord)
				break
			end
		end
	end

	return targetCoordList
end

------------------------------------------------------------------------------------------------------------
--											SKILL: BIG CLOUD BLOCK
------------------------------------------------------------------------------------------------------------
--获取生成大云块的左上角坐标
function MoleWeeklyRaceLogic:pickPositionForBigCloud(mainLogic, pickAmount)
	-- printx(11, "---------- MoleWeeklyRaceLogic:pickPositionForBigCloud ---------- ")
	if not pickAmount or pickAmount <= 0 then
		return nil
	end

	local targetPosList = {}		--由普通动物和水晶球组成的四格
	local targetPosMarkedPos = {}	--被标记会被选中的位置（下面pick sub的时候用）
	targetPosList, targetPosMarkedPos = MoleWeeklyRaceLogic:_pickOnTypeOfPositionForBigCloud(mainLogic, pickAmount)

	local targetList = {}
	local pickedPos
	for k = 1, pickAmount do 
		if #targetPosList > 0 then
			pickedPos = table.remove(targetPosList, 1)
			table.insert(targetList, pickedPos)
		end
	end

	local pickAmountLeft = pickAmount - #targetList
	if pickAmountLeft > 0 then
		local subPosList = {}			--由上述内容+特效动物和魔力鸟组成的四格
		subPosList = MoleWeeklyRaceLogic:_pickOnTypeOfPositionForBigCloud(mainLogic, pickAmountLeft, true, targetPosMarkedPos)

		for k = 1, pickAmountLeft do 
			if #subPosList > 0 then
				pickedPos = table.remove(subPosList, 1)
				table.insert(targetList, pickedPos)
			end
		end
	end

	return targetList
end

function MoleWeeklyRaceLogic:_pickOnTypeOfPositionForBigCloud(mainLogic, pickAmount, isSub, invalidMarkedDict)
	local targetPosList = {}
	local markedPos = {}		--本轮筛选中已被占用的格子
	if not invalidMarkedDict then invalidMarkedDict = {} end	--被占用的格子

	--- 左上为原点，四格
	local aroundX = {0, 1, 0, 1}
	local aroundY = {0, 0, 1, 1}

	local function fullfillTargetCondition(targetItem)
		if isSub and MoleWeeklyRaceLogic:_isSubPickableTargetForBigCloud(targetItem) then
			return true
		elseif MoleWeeklyRaceLogic:_isPickableTargetForBigCloud(targetItem) then
			return true
		end
		return false
	end

	local r = #mainLogic.gameItemMap - 1
	local c
	local item
	while r >= 1 do 			--屏幕最下排不用检测
		for c = 1, #mainLogic.gameItemMap[r] - 1 do 	--屏幕最右侧不用检测
			local hasInvalidGrid = false

			for i = 1, 4 do
				local currRow = r + aroundY[i]
				local currCol = c + aroundX[i]
				local locationKey = currCol..","..currRow

				--排除中心有绳子的情况
				if i == 1 then
					if mainLogic:hasRopeInNeighbors(currRow, currCol, currRow, currCol + 1) 
						or mainLogic:hasRopeInNeighbors(currRow, currCol, currRow + 1, currCol) then
						hasInvalidGrid = true	--右下
						break
					end
				elseif i == 2 then
					if mainLogic:hasRopeInNeighbors(currRow, currCol, currRow + 1, currCol) then
						hasInvalidGrid = true	--下
						break
					end
				elseif i == 3 then
					if mainLogic:hasRopeInNeighbors(currRow, currCol, currRow, currCol + 1) then
						hasInvalidGrid = true	--右
						break
					end
				end

				item = mainLogic:getGameItemAt(currRow, currCol)
				if item and item:isVisibleAndFree() and 
					not invalidMarkedDict[locationKey] and not markedPos[locationKey] then
					if not fullfillTargetCondition(item) then
						hasInvalidGrid = true
						break
					end
				else
					hasInvalidGrid = true
					break
				end
			end

			if not hasInvalidGrid then
				local targetPos = IntCoord:create(r, c)
				table.insert(targetPosList, targetPos)
				for i = 1, 4 do
					local markLocationKey = (c + aroundX[i])..","..(r + aroundY[i])
					markedPos[markLocationKey] = true
				end
			end

			if #targetPosList >= pickAmount then break end
		end

		if #targetPosList >= pickAmount then break end
		r = r - 1
	end

	return targetPosList, markedPos
end

function MoleWeeklyRaceLogic:_isPickableTargetForBigCloud(itemData)
	if itemData.ItemType == GameItemType.kAnimal and itemData.ItemSpecialType == 0 then
		return true
	elseif itemData.ItemType == GameItemType.kCrystal then
		return true
	end
	return false
end

function MoleWeeklyRaceLogic:_isSubPickableTargetForBigCloud(itemData)
	if itemData.ItemType == GameItemType.kAnimal then
		if itemData.ItemSpecialType == AnimalTypeConfig.kColor 
			or itemData.ItemSpecialType == AnimalTypeConfig.kLine
			or itemData.ItemSpecialType == AnimalTypeConfig.kColumn
			or itemData.ItemSpecialType == AnimalTypeConfig.kWrap then
			return true
		end
	end
	return false
end

function MoleWeeklyRaceLogic:initMoleBossCloudBlock(mainLogic, r, c)
	--- 左上为原点，四格
	local aroundX = {0, 1, 0, 1}
	local aroundY = {0, 0, 1, 1}

	for i = 1, 4 do
		local currRow = r + aroundX[i]
		local currCol = c + aroundY[i]
		local isAnchorPoint = false
		if i == 1 then isAnchorPoint = true end

		item = mainLogic:getGameItemAt(currRow, currCol)
		if item then
			-- item:cleanAnimalLikeData()
			item._encrypt.ItemColorType = 0
			item.ItemSpecialType = 0
			MoleWeeklyRaceLogic:_initMoleBossCloud(item, isAnchorPoint)
			item.isNeedUpdate = true
			mainLogic:checkItemBlock(currRow, currCol)
		end
	end
end

function MoleWeeklyRaceLogic:_initMoleBossCloud(item, isAnchorPoint)
	item.ItemType = GameItemType.kMoleBossCloud
	item.moleBossCloudLevel = 0
	item.isBlock = true 
	item.isEmpty = false 
	
	if isAnchorPoint then 		--左上角的锚点
		item.moleBossCloudLevel = 1 --这个写死即可 用以区分占位格子
		item.maxBlood = MoleWeeklyRaceParam.SKILL_CLOUD_HP
		item.blood = item.maxBlood
		item.moves = 0--WeeklyBossConfig.moves
		item.maxMoves = item.moves
		item.animal_num = 0--WeeklyBossConfig.animal_num
		item.drop_sapphire = MoleWeeklyRaceParam.SKILL_CLOUD_DESTROY_JEWEL
		item.speicial_hit_blood = MoleWeeklyRaceParam.SKILL_CLOUD_SPECIAL_HIT_EFFECT
		item.hitCounter = 0
	end
end

function MoleWeeklyRaceLogic:MoleBossCloudLoseBlood(mainLogic, r, c, isMatch , actid , hitBlood)
	-- printx(11, "boss cloud lose blood: isMatch, hitBlood:", isMatch, hitBlood)
	local item = mainLogic.gameItemMap[r][c]
	local cloud = nil
	local cloudR, cloudC = r, c 
	if item.moleBossCloudLevel > 0 then
		cloud = item
	else
		if c - 1 > 0 and mainLogic.gameItemMap[r][c - 1].moleBossCloudLevel > 0 then
			cloud = mainLogic.gameItemMap[r][c - 1]
			cloudR, cloudC = r, c-1
		elseif r - 1 > 0 and mainLogic.gameItemMap[r - 1][c].moleBossCloudLevel > 0 then
			cloud = mainLogic.gameItemMap[r - 1][c]
			cloudR, cloudC = r-1, c
		elseif (c - 1 > 0 and r - 1 > 0) and mainLogic.gameItemMap[r - 1][c - 1].moleBossCloudLevel > 0 then
			cloud = mainLogic.gameItemMap[r - 1][c-1]
			cloudR, cloudC = r-1, c-1
		end
	end
	
	local canBeEffectBySpecaial = true
	if isMatch == false and actid and cloud ~= nil then
		if not cloud.specialEffectList then 
			cloud.specialEffectList = {}
		end

		if cloud.specialEffectList[actid] then
			canBeEffectBySpecaial = false 
		end

		if canBeEffectBySpecaial then
			cloud.specialEffectList[actid] = true
		end
	end

	-- printx(11, "cloud.blood:", cloud.blood)
	if cloud ~= nil and cloud.blood > 0 and canBeEffectBySpecaial then
		local addScore = GamePlayConfigScore.WeeklyBossBeHit	--change later?
		mainLogic:addScoreToTotal(r, c, addScore)

		local bloodLoseCount = isMatch and 1 or cloud.speicial_hit_blood
		if hitBlood and type(hitBlood) == "number" and hitBlood > 0 then
			bloodLoseCount = hitBlood
		end
		-- hitCounter的增量不会超过boss当前血量
		if cloud.blood > bloodLoseCount then
			cloud.hitCounter = cloud.hitCounter + bloodLoseCount
		else
			cloud.hitCounter = cloud.hitCounter + cloud.blood
		end

		-- printx(11, "bloodLoseCount:", bloodLoseCount)
		cloud.blood = cloud.blood - bloodLoseCount
		if cloud.blood < 0 then cloud.blood = 0 end

		if cloud.blood > 0 then
			local itemView = mainLogic.boardView.baseMap[cloudR][cloudC]
			itemView:playMoleBossCloudHit(boardView, cloud.blood)
		else
			local decAction = GameBoardActionDataSet:createAs(
				GameActionTargetType.kGameItemAction,
				GameItemActionType.kItem_MoleWeekly_Boss_Cloud_Die,
				IntCoord:create(cloudR, cloudC),
				nil,
				GamePlayConfig_MaxAction_time)
			decAction.addInt = cloud.blood
			mainLogic:addDestroyAction(decAction)
		end
	end
end

------------------------------------借贵宝地一用： Mole Special props -------------------------
function MoleWeeklyRaceLogic:getMoleSpecialPropsDatas(mainLogic)
	local targetList = {}
	local throwAddStepAmount = 0
	local throwColourAmount = 0
	local hpDamage = 0

	if mainLogic.PlayUIDelegate and mainLogic.PlayUIDelegate.propList and mainLogic.PlayUIDelegate.propList.rightPropList then
		local rightPropList = mainLogic.PlayUIDelegate.propList.rightPropList
		local springItem = rightPropList.springItem
		if springItem then
			local currConfig = springItem:getPropSkillConfig()
			if currConfig then 
				-- hpDamage = currConfig.hpDamage 	--抛弃使用配置数据
				if currConfig.throwAddStepPercent then
					if mainLogic.randFactory:rand(1, 100) <= currConfig.throwAddStepPercent * 100 then
						throwAddStepAmount = 1
					end
				end

				throwColourAmount = currConfig.throwColourAmount
				local wholePickAmount = currConfig.throwEffectAmount + throwColourAmount + throwAddStepAmount
				targetList = MoleWeeklyRaceLogic:_pickMoleSpecialPropTargets(mainLogic, wholePickAmount)
			end

			if mainLogic:getMoleWeeklyBossData() then
				hpDamage = math.floor(mainLogic:getMoleWeeklyBossData().totalBlood / 2)
			end
		end
	end

	printx(11, "MoleSpecialPropsDatas: ", table.tostring(targetList), throwAddStepAmount, throwColourAmount, hpDamage)
	return targetList, throwAddStepAmount, throwColourAmount, hpDamage
end

function MoleWeeklyRaceLogic:_pickMoleSpecialPropTargets(mainLogic, pickAmount)
	-- printx(11, "= = = pickMoleSpecialPropTargets = = = pickAmount", pickAmount)
	if not pickAmount or pickAmount <= 0 then
		return {}
	end

	local rawCoordList = {}
	local gameItemMap = mainLogic.gameItemMap
	for r = 1, #gameItemMap do 
		for c = 1, #gameItemMap[r] do
			local item = gameItemMap[r][c]
			if item and item:isVisibleAndFree() then
				local intCoord = {r = r, c = c}
				if (item.ItemType == GameItemType.kAnimal and item.ItemSpecialType == 0) or item.ItemType == GameItemType.kCrystal then
					MoleWeeklyRaceLogic:_insertSplitByRowPriority(rawCoordList, 1, r, intCoord)
				end
			end 
		end
	end

	-- MoleWeeklyRaceLogic:_testPrintListTable(rawCoordList)

	local targetCoordList = {}
	local coord
	for index = 1, pickAmount do 
		for listIndex = 1, table.maxn(rawCoordList) do
			local subList = rawCoordList[listIndex]
			if subList and #subList > 0 then
				coord = table.remove(subList, mainLogic.randFactory:rand(1, #subList))
				table.insert(targetCoordList, coord)
				break
			end
		end
	end

	return targetCoordList
end

------------------------------- Target --------------------------------
function MoleWeeklyRaceLogic:getFinalAmountForJewel(mainLogic)
    local finalAmount = mainLogic.digJewelCount:getValue()
    if RankRaceMgr and RankRaceMgr:getInstance() then
        RankRaceMgr:getInstance():setBaseTarget_0(finalAmount)      --为了显示，先记录一下原始值
        finalAmount = RankRaceMgr:getInstance():getFinalTarget(finalAmount)     --获取加成之后的数值
    end
    return finalAmount
end

function MoleWeeklyRaceLogic:fullfillStageExtraRequirements(mainLogic)
    local fullAmount = MoleWeeklyRaceConfig:getCollectTargetAmount()
    local currAmount = mainLogic.digJewelCount:getValue()
    if currAmount >= fullAmount then
        return true
    else
        return false
    end
end

----------------------------- AddFiveSteps ---------------------------
function MoleWeeklyRaceLogic:demolishBossImmediately(mainLogic)
	local bossData = mainLogic:getMoleWeeklyBossData()
	if bossData then
		bossData.hit = bossData.totalBlood
	end
end

------------------------------- Guide --------------------------------
function MoleWeeklyRaceLogic:isCloudLikeItem(itemType)
	if itemType == GameItemType.kDigGround
        or itemType == GameItemType.kDigJewel
        or itemType == GameItemType.kMoleBossCloud
        or itemType == GameItemType.kYellowDiamondGrass
        then
        return true
    end
    return false
end

function MoleWeeklyRaceLogic:getVisibleMagicTileLocation(mainLogic)
	local boardmap = mainLogic.boardmap
    for r = 1, #boardmap do 
        for c = 1, #boardmap[r] do 
            local boardItem = boardmap[r][c]
            if boardItem and boardItem.isMagicTileAnchor then
            	for i = r, r + 1 do
					for j = c, c + 2 do
						if mainLogic.gameItemMap[i] and mainLogic.gameItemMap[i][j] then
							local item = mainLogic.gameItemMap[i][j]
							if not MoleWeeklyRaceLogic:isCloudLikeItem(item.ItemType) then
								locationPoint = {r = r, c = c}
								return locationPoint
							end
						end
					end
				end
            end
        end
    end
    return nil
end

function MoleWeeklyRaceLogic:setSkillFlagForGuide(mainLogic, skillType)
	if not mainLogic.gameMode.releaseSkillFlag then
		mainLogic.gameMode.releaseSkillFlag = {}
	end
	mainLogic.gameMode.releaseSkillFlag[skillType] = true
end

function MoleWeeklyRaceLogic:getTargetLocationForGuide(mainLogic, skillType)
	if mainLogic.gameMode.releaseSkillFlag and mainLogic.gameMode.releaseSkillFlag[skillType] then
		if skillType == MoleWeeklyBossSkillType.FRAGILE_BLACK_CUTEBALL then
			return MoleWeeklyRaceLogic:getFirstTargetItemOnBoard(mainLogic, GameItemType.kBlackCuteBall)
		elseif skillType == MoleWeeklyBossSkillType.BIG_CLOUD_BLOCK then
			return MoleWeeklyRaceLogic:getFirstTargetItemOnBoard(mainLogic, GameItemType.kMoleBossCloud)
		elseif skillType == MoleWeeklyBossSkillType.SEED then
			return MoleWeeklyRaceLogic:getFirstTargetItemOnBoard(mainLogic, GameItemType.kMoleBossSeed)
		elseif skillType == MoleWeeklyBossSkillType.THICK_HONEY then
			return MoleWeeklyRaceLogic:getFirstTargetItemOnBoard(mainLogic, nil, true)
		elseif skillType == MoleWeeklyBossSkillType.DEAVTIVATE_MAGIC_TILE then
			return MoleWeeklyRaceLogic:getFirstTargetItemOnBoard(mainLogic, nil, false, true)
		elseif skillType == GamePropsType.kMoleWeeklyRaceSPProp then
			return MoleWeeklyRaceLogic:getFirstTargetItemOnBoard(mainLogic, GameItemType.kBalloon)
		end
	end
	return nil
end

function MoleWeeklyRaceLogic:setTargetLocationForGuideEnd(mainLogic, skillType)
    if mainLogic.gameMode.releaseSkillFlag and mainLogic.gameMode.releaseSkillFlag[skillType] then
        mainLogic.gameMode.releaseSkillFlag[skillType] = false
    end
end

function MoleWeeklyRaceLogic:getFirstTargetItemOnBoard(mainLogic, itemType, checkHoney, checkMagicTileCover)
	local locationPoint

	if checkMagicTileCover then
		local boardmap = mainLogic.boardmap
	    for r = 1, #boardmap do
	        for c = 1, #boardmap[r] do
	        	local boardItem = mainLogic.boardmap[r][c]
    			if boardItem and boardItem.magicTileDisabledRound > 0 then
    				locationPoint = {r = r, c = c}
					return locationPoint
    			end
	        end
	    end
	else
		local gameItemMap = mainLogic.gameItemMap
	    for r = 1, #gameItemMap do
	        for c = 1, #gameItemMap[r] do
	        	local item = gameItemMap[r][c]
	        	if checkHoney then
	        		if item and item.honeyLevel > 0 then
		        		locationPoint = {r = r, c = c}
						return locationPoint
		        	end
	        	else
	        		if item and item.ItemType == itemType then
		        		locationPoint = {r = r, c = c}
						return locationPoint
		        	end
	        	end
	        end
	    end
	end

    return nil
end
