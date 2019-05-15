GhostLogic = class{}

------------------------------------------------------------------------------------------------------------
--												GENERATE
------------------------------------------------------------------------------------------------------------
--- 如果可以生成幽灵，生成多少个
function GhostLogic:getGenerateGhostAmountIfNeeded(mainLogic)
	-- printx(11, "= = = = = Try calculate ghost generate amount. = = = = =")
	if not mainLogic.ghostConfig then
		return 0, 0
	end

	local stepNum = mainLogic.ghostConfig.stepNum or 0		--每隔几步
	local unlockNum = mainLogic.ghostConfig.unlockNum or 0		--开放几只幽灵
	local boardMaxNum = mainLogic.ghostConfig.boardMaxNum or 0		--棋盘（明面上）最多
	local boardMinNum = mainLogic.ghostConfig.boardMinNum or 0		--棋盘（明面上）最少，如果不达到，无视unlockNum生成至达到
	local produceMaxNum = mainLogic.ghostConfig.produceMaxNum or 0		--总共生成上限

	local generateNumByBoardMin = 0
	local generateNumByStep = 0
	local toProduceMaxGap = 0

	local sumGeneratedAmount = mainLogic.ghostGeneratedByStep + mainLogic.ghostGeneratedByBoardMin
	if produceMaxNum > 0 then
		if sumGeneratedAmount >= produceMaxNum then
			-- printx(11, "ghost produce reached max")
			return 0, 0
		else
			toProduceMaxGap = produceMaxNum - sumGeneratedAmount
		end
	end

	local boardCurrAmount = 0
	if boardMinNum > 0 or boardMaxNum > 0 then
		boardCurrAmount = #GhostLogic:getAllVisibleGhostOnBoard(mainLogic)
	end

	if boardMinNum > 0 and boardCurrAmount < boardMinNum then
		generateNumByBoardMin = boardMinNum - boardCurrAmount
		-- printx(11, "+ + + generate by boardMinNum. generateAmount:", generateNumByBoardMin)
	end

	if unlockNum > 0 then
		local totalUnlockNum = GhostLogic:_getTotalUnlockNumOfCurrStep(mainLogic)

		-- printx(11, "curr totalUnlockNum:", totalUnlockNum)
		-- printx(11, "curr ghostGeneratedByStep:", mainLogic.ghostGeneratedByStep)
		if mainLogic.ghostGeneratedByStep < totalUnlockNum then
			generateNumByStep = totalUnlockNum - mainLogic.ghostGeneratedByStep
			-- printx(11, "+ + + generate by step. generateAmount:", generateNumByStep)
			if boardMaxNum > 0 then
				generateNumByStep = math.min(generateNumByStep, math.max(boardMaxNum - boardCurrAmount - generateNumByBoardMin, 0))
				-- printx(11, "- - - cutted by boardMaxNum. generateAmount:", generateNumByStep)
			end
		end
	end

	if toProduceMaxGap > 0 and (generateNumByBoardMin + generateNumByStep) > toProduceMaxGap then
		generateNumByBoardMin = math.min(generateNumByBoardMin, toProduceMaxGap)
		generateNumByStep = math.min(generateNumByStep, toProduceMaxGap - generateNumByBoardMin)
		-- printx(11, "cutted by toProduceMaxGap. generateNumByBoardMin:", generateNumByBoardMin)
		-- printx(11, "cutted by toProduceMaxGap. generateNumByStep:", generateNumByStep)
	end

	return generateNumByBoardMin, generateNumByStep
end

--- 至今为止累计开放的生成数量
function GhostLogic:_getTotalUnlockNumOfCurrStep(mainLogic)
	local totalUnlockNum = 0

	local stepNum = mainLogic.ghostConfig.stepNum or 0		--每隔几步
	local unlockNum = mainLogic.ghostConfig.unlockNum or 0		--开放几只幽灵

	-- printx(11, "realCostMoveWithoutBackProp, stepNum", mainLogic.realCostMoveWithoutBackProp, stepNum)
	if mainLogic.realCostMoveWithoutBackProp >= stepNum then
		if mainLogic.realCostMoveWithoutBackProp == 0 then	--进入游戏就有生成
			totalUnlockNum = unlockNum
		else
			totalUnlockNum = unlockNum * math.floor(mainLogic.realCostMoveWithoutBackProp / math.max(stepNum, 1))
			if stepNum == 0 then	--初始生成的话，要加上一轮
				totalUnlockNum = totalUnlockNum + unlockNum
			end
		end
	end

	return totalUnlockNum
end

function GhostLogic:getAllVisibleGhostOnBoard(mainLogic)
	local allGhost = {}
	for r = 1, #mainLogic.gameItemMap do
		for c = 1, #mainLogic.gameItemMap[r] do
			local item = mainLogic.gameItemMap[r][c]
            if item and item:isFreeGhost() then
            	table.insert(allGhost, item)
            end
		end
	end
	return allGhost
end

GhostAppearPriority = table.const{ 
	[1] = {GameItemType.kBlocker195, GameItemType.kCrystalStone, GameItemType.kTotems},
	[2] = {GameItemType.kMissile, GameItemType.kBlocker199, GameItemType.kGift, GameItemType.kNewGift, GameItemType.kMagicLamp, 
			GameItemType.kPacman, GameItemType.kPuffer, GameItemType.kBlocker207, GameItemType.kBalloon, GameItemType.kBuffBoom, 
			GameItemType.kScoreBuffBottle, GameItemType.kFirecracker},
	[3] = {GameItemType.kAnimal},
	[4] = {GameItemType.kHoneyBottle, GameItemType.kWanSheng, GameItemType.kIngredient, GameItemType.kCoin, GameItemType.kChameleon},
	[5] = {GameItemType.kCrystal, GameItemType.kAnimal},
}
function GhostLogic:pickGenerateTargets(mainLogic, needAmount)
	local pickedTargets = {}
	local candidateTargets = {}
	for i = 1, #GhostAppearPriority do
		candidateTargets[i] = {}	--五个优先级
	end

	local function getPriorityOfItem(item)
		if item and not item.isEmpty and item:isVisibleAndFree() then
			for pri = 1, #GhostAppearPriority do
				local targetsOfPri = GhostAppearPriority[pri]
				local index = table.indexOf(targetsOfPri, item.ItemType)
				-- printx(11, "pri = "..pri..", targetsOfPri", table.tostring(targetsOfPri))
				-- printx(11, "index", index, item.ItemType)
				if index and index > 0 then
					-- printx(11, "index, item.ItemType", index, item.ItemType, item.x, item.y)
					if item.ItemType == GameItemType.kAnimal then
						if pri == 3 and AnimalTypeConfig.isSpecialAnimal(item.ItemSpecialType) then		--3号优先级是特效动物
							return pri
						elseif pri == 5 and item.ItemSpecialType == 0 then		--5号优先级是普通动物
							return pri
						end
					elseif item.ItemType == GameItemType.kBlocker199 then
						if item:isBlocker199Active() then return pri else return 0 end
					elseif item.ItemType == GameItemType.kTotems then
						if not item:isActiveTotems() then return pri else return 0 end
					else
						return pri
					end
				end
			end
		end
		return 0
	end

	local candidateAmount = 0
	local allAppearPoint = GhostLogic:getAllGhostsAppearPoint(mainLogic)
	if #allAppearPoint > 0 then
		local pickedPos = {}
		for _, appearPoint in ipairs(allAppearPoint) do
			local row, col = appearPoint.y, appearPoint.x
			local gridItem = mainLogic:getGameItemAt(row, col)
			local priority = getPriorityOfItem(gridItem)
			-- printx(11, "row, col, priority", row, col, priority)
			if priority > 0 then
				table.insert(candidateTargets[priority], gridItem)
				candidateAmount = candidateAmount + 1
			end
		end
	end

	local pickAmount = math.min(needAmount, candidateAmount)
	-- printx(11, "pickAmount", pickAmount, table.tostring(candidateTargets))
	if pickAmount > 0 then
		for k = 1, pickAmount do 
			for listIndex = 1, #candidateTargets do
				local subList = candidateTargets[listIndex]
				-- printx(11, "listIndex", listIndex, table.tostring(subList))
				if subList and #subList > 0 then
					local targetItem = table.remove(subList, mainLogic.randFactory:rand(1, #subList))
					table.insert(pickedTargets, targetItem)
					break
				end
			end
		end
	end

	return pickedTargets
end

function GhostLogic:getAllGhostsAppearPoint(mainLogic)
	local allAppearPoint = {}
	for r = 1, #mainLogic.boardmap do
		for c = 1, #mainLogic.boardmap[r] do
			local board = mainLogic.boardmap[r][c]
            if board and board.isGhostAppear then
            	table.insert(allAppearPoint, board)
            end
		end
	end
	return allAppearPoint
end

function GhostLogic:updateNewGhost(mainLogic, targetItem)
	--- 赋予新格子相应属性
	targetItem.coveredByGhost = true
	targetItem.ghostPaceLength = 0
	targetItem.tempGhostPace = 0

	targetItem.isNeedUpdate = true
	targetItem.forceUpdate = true	--新生产出来的需要forceUpdate确保itemView中的oldData获得幽灵覆盖状态的数据

	mainLogic:checkItemBlock(targetItem.y, targetItem.x)
end

-- 解释一下：还有多少只幽灵有可能被产出。
-- < 0 : 不限制数量，步数够管够
function GhostLogic:calculateGhostsLeftMaxAppearAmount(mainLogic)
	local allAppearPoint = GhostLogic:getAllGhostsAppearPoint(mainLogic)
	if #allAppearPoint > 0 then
		if not mainLogic.ghostConfig then
			return 0
		end

		local unlockNum = mainLogic.ghostConfig.unlockNum or 0
		if unlockNum <= 0 then
			return 0
		end

		local produceMaxNum = mainLogic.ghostConfig.produceMaxNum or 0
		if produceMaxNum > 0 then
			local sumGeneratedAmount = mainLogic.ghostGeneratedByStep + mainLogic.ghostGeneratedByBoardMin
			if sumGeneratedAmount >= produceMaxNum then
				return 0
			else
				return produceMaxNum - sumGeneratedAmount
			end
		else
			return -1
		end
	end
	return 0
end


------------------------------------------------------------------------------------------------------------
--												MOVE
------------------------------------------------------------------------------------------------------------
function GhostLogic:addGhostPace(mainLogic, targetItem, num, isSpecial)
	if targetItem:seizedByGhost() then
		local addAmount = 1
		if num and num > 0 then 
			addAmount = num 
		end
		if isSpecial then
			addAmount = addAmount * 2
		end

		targetItem.ghostPaceLength = targetItem.ghostPaceLength + addAmount
		-- printx(11, "ghost pace added. now:", targetItem.ghostPaceLength)
		-- printx(11, debug.traceback())
		ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_Ghost, ObstacleFootprintAction.k_IntendedSteps, addAmount)

		local itemView = mainLogic.boardView.baseMap[targetItem.y][targetItem.x]
		if itemView then
			itemView:playGhostActive()
		end
	end
end

function GhostLogic:isReadyToFlyGhost(mainLogic, item)
	if item and item:isFreeGhost() then
		if item.ghostPaceLength > 0 then
			return true
		end
	end
	return false
end

-- 保持有序：从左到右，从上到下，按列扫描
function GhostLogic:pickAllActiveGhostsByOrder(mainLogic)
	local allActiveGhost = {}

	for c = 1, 9 do
		for r = 1, 9 do
			if mainLogic.gameItemMap[r] then
				local item = mainLogic.gameItemMap[r][c]
	            if GhostLogic:isReadyToFlyGhost(mainLogic, item) then
	            	-- printx(11, "insert active!!  col:"..c..", row:"..r.."  pace:"..item.ghostPaceLength)
	            	table.insert(allActiveGhost, item)
	            end
			end
		end
	end

	-- printx(11, "allActiveGhost pickAmount", #allActiveGhost)
	return allActiveGhost
end

function GhostLogic:isReadyToCollectGhost(mainLogic, item)
	if item and item:isFreeGhost() then
		if mainLogic.boardmap[item.y] and mainLogic.boardmap[item.y][item.x] then
			local currBoard = mainLogic.boardmap[item.y][item.x]
			if currBoard.isGhostCollect then
				return true
			end
		end
	end
	return false
end

-- 其他障碍选取目标时判断用
function GhostLogic:ghostCanMoveUpward(targetGhost)
	local mainLogic = GameBoardLogic:getCurrentLogic()
	local col, row = targetGhost.x, targetGhost.y

	local aboveItem
	if mainLogic.gameItemMap[row - 1] and mainLogic.gameItemMap[row - 1][col] then
		aboveItem = mainLogic.gameItemMap[row - 1][col]
	end

	return GhostLogic:_ghostCanMoveUpward(mainLogic, col, row, aboveItem)
end


function GhostLogic:_ghostCanMoveUpward(mainLogic, col, row, aboveItem)
	-- test if it is about to collect first
	if mainLogic.boardmap[row] and mainLogic.boardmap[row][col] then
		local currBoard = mainLogic.boardmap[row][col]
		if currBoard.isGhostCollect then
			return false	--当前格子有收集口，被卡住等待收集
		end
	end

	-- Try to climb
	row = row - 1
	if row < 1 or not aboveItem or mainLogic:hasChainInNeighbors(row + 1, col, row, col) then 
		return false
	end

	if GhostLogic:_isExchangeableItemForGhost(mainLogic, aboveItem, row, col) then
		return true
	else
		return false
	end
end

function GhostLogic:arrangeAllMovementsCausedByGhosts(mainLogic, allActiveGhosts)
	local hasRealMoving = false

	local ghostsByCol = {}
	for index = 1, #allActiveGhosts do
		local ghost = allActiveGhosts[index]
		if not ghostsByCol[ghost.x] then ghostsByCol[ghost.x] = {} end
		table.insert(ghostsByCol[ghost.x], ghost)
	end

	for col, colLists in pairs(ghostsByCol) do
		-- Each column
		if not colLists or #colLists <= 0 then break end

		local modelCol = {}
		for rowNum = 1, 9 do
			if mainLogic.gameItemMap[rowNum] and mainLogic.gameItemMap[rowNum][col] then
				modelCol[rowNum] = mainLogic.gameItemMap[rowNum][col]
			else
				-- printx(11, "set nil !   ("..col..","..rowNum..")")
				modelCol[rowNum] = nil
			end
		end
		local hasMovingInCurrCol = false

		for i = 1, #colLists do
			-- Each ghost, up to down
			local currGhost = colLists[i]
			local currRow = currGhost.y
			local gridClimbedNum = 0

			local hitEnd = false
			while not hitEnd do 
				local aboveItem = modelCol[currRow - 1]
				hitEnd = not GhostLogic:_ghostCanMoveUpward(mainLogic, col, currRow, aboveItem)
				if not hitEnd then
					modelCol[currRow - 1], modelCol[currRow] = modelCol[currRow], modelCol[currRow - 1]
					gridClimbedNum = gridClimbedNum + 1
					hasMovingInCurrCol = true

					if gridClimbedNum >= currGhost.ghostPaceLength then
						hitEnd = true
					end
				end

				currRow = currRow - 1
			end
		end

		if hasMovingInCurrCol then
			for newRow = 1, 9 do
				local tempItem = modelCol[newRow]
				if tempItem then
					local rowGap = newRow - tempItem.y 	-- row need to move caused by ghost
					if rowGap ~= 0 then
						tempItem.tempGhostPace = rowGap
						-- printx(11, "MOVE!   ("..tempItem.x..","..tempItem.y..") : ", rowGap)
					end
				else
					-- printx(11, "tempItem = nil!   ("..tempItem.x..","..tempItem.y..") : ")
				end
			end
			hasRealMoving = true
		end
	end

	return hasRealMoving
end

function GhostLogic:_isExchangeableItemForGhost(mainLogic, item, row, col)
	if item and item:isVisibleAndFree() then
		for k, targetList in pairs(GhostAppearPriority) do 		-- 优先级列表中保存的亦是支持覆盖的类型的全部
			local index = table.indexOf(targetList, item.ItemType)
			if index and index > 0 then
				if item.ItemType == GameItemType.kBlocker199 then
					if item:isBlocker199Active() then return true else return false end
				elseif item.ItemType == GameItemType.kTotems then
					if not item:isActiveTotems() then return true else return false end
				else
					return true
				end
			end
		end
	end
	return false
end

function GhostLogic:refreshGameItemDataAfterGhostMove(mainLogic)
	local newColumnMap = {}
	for r = 1, #mainLogic.gameItemMap do
		for c = 1, #mainLogic.gameItemMap[r] do
			local oldItem = mainLogic.gameItemMap[r][c]
		    if oldItem and oldItem.tempGhostPace ~= 0 then
		    	if not newColumnMap[oldItem.x] then newColumnMap[oldItem.x] = {} end
		    	if oldItem:seizedByGhost() and (oldItem.tempGhostPace < 0) then
		    		ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_Ghost, ObstacleFootprintAction.k_Steps, 
		    			math.abs(oldItem.tempGhostPace))
		    	end
		    	local newRow = oldItem.y + oldItem.tempGhostPace
				newColumnMap[oldItem.x][newRow] = oldItem:copy()
		    end
		end
	end

	for col, colLists in pairs(newColumnMap) do
		for row, copiedItem in pairs(colLists) do
			if mainLogic.gameItemMap[row] and mainLogic.gameItemMap[row][col] then
				local currItem = mainLogic.gameItemMap[row][col]
				currItem:getAnimalLikeDataFrom(copiedItem)
				currItem.isNeedUpdate = true
				currItem.forceUpdate = true

				-- printx(11, "("..col..","..row..")  ghostData:", currItem.coveredByGhost, currItem.ghostPaceLength)
				currItem.tempGhostPace = 0
				currItem.ghostPaceLength = 0
				-- printx(11, "("..col..","..row..")  ghostData after:", currItem.coveredByGhost, currItem.ghostPaceLength)

				if currItem:seizedByGhost() then
					mainLogic:checkItemBlock(row, col)
				else
					-- 被挤下去的对象需要先更新视图再参与掉落
					currItem.updateLaterByGhost = true
				end
			end
		end
	end

end

function GhostLogic:refreshBlockStateAfterGhostMove(mainLogic)
	for r = 1, #mainLogic.gameItemMap do
		for c = 1, #mainLogic.gameItemMap[r] do
			local targetItem = mainLogic.gameItemMap[r][c]
		    if targetItem and targetItem.updateLaterByGhost then
		    	mainLogic:checkItemBlock(r, c)
				mainLogic:addNeedCheckMatchPoint(r , c)
		    end
		end
	end
end

function GhostLogic:switchStatusBackToNormalWithoutMoving(mainLogic, targetItem)
	if targetItem and targetItem:seizedByGhost() then

		targetItem.tempGhostPace = 0
		targetItem.ghostPaceLength = 0

		local itemView = mainLogic.boardView.baseMap[targetItem.y][targetItem.x]
		if itemView then
			itemView:playGhostNormal()
		end
	end
end


----------------------------------------------------------------------
function GhostLogic:pickAllToCollectGhosts(mainLogic)
	local allToCollectGhost = {}
	for r = 1, #mainLogic.boardmap do
		for c = 1, #mainLogic.boardmap[r] do
			local board = mainLogic.boardmap[r][c]
            if board and board.isGhostCollect then
            	if mainLogic.gameItemMap[r] and mainLogic.gameItemMap[r][c] then
            		local item = mainLogic.gameItemMap[r][c]
            		if item:isFreeGhost() then
            			table.insert(allToCollectGhost, item)
            		end
            	end
            end
		end
	end

	-- printx(11, "allToCollectGhost pickAmount", #allToCollectGhost)
	return allToCollectGhost
end
