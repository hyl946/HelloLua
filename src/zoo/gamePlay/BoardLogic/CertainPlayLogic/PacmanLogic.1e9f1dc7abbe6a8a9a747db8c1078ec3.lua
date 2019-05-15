PacmanLogic = class{}

------------------------------------------------------------------------------------------------------------
--												GENERATE
------------------------------------------------------------------------------------------------------------
--- 小窝生产进度（显示用）
function PacmanLogic:getDenProduceProgress(mainLogic)
	if not mainLogic.pacmanConfig then
		return 0
	end

	local sumGeneratedAmount = mainLogic.pacmanGeneratedByStep + mainLogic.pacmanGeneratedByBoardMin

	local produceMaxNum = mainLogic.pacmanConfig.produceMaxNum or 0
	if produceMaxNum > 0 then
		--- 已经不会再生成了
		if sumGeneratedAmount >= produceMaxNum then
			return 0
		end
	end

	--- can generate by boardMin number?
	local boardMinNum = mainLogic.pacmanConfig.boardMinNum or 0
	if boardMinNum > 0 then
		local boardCurrAmount = #PacmanLogic:_getAllVisiblePacmanOnBoard(mainLogic)
		if boardCurrAmount < boardMinNum then
			return 1
		end
	end

	--- can generate by step?
	local stepNum = mainLogic.pacmanConfig.stepNum or 0
	local unlockNum = mainLogic.pacmanConfig.unlockNum or 0

	if unlockNum == 0 then
		return 0
	end

	local totalUnlockNum = PacmanLogic:_getTotalUnlockNumOfCurrStep(mainLogic)
	-- printx(11, "= = = pacmanSumGeneratedAmount, totalUnlockNum", sumGeneratedAmount, totalUnlockNum)
	if mainLogic.pacmanGeneratedByStep < totalUnlockNum then
		--- 可以马上生成（无视棋盘最多数量限制)
		-- printx(11, "Den Progress updated: 1")
		return 1
	else
		--能生成的均已生成完毕，需要等待步数后生成
		stepNum = math.max(stepNum, 1)
		local usedTimes = math.floor(mainLogic.realCostMoveWithoutBackProp / stepNum)
		local currCircleStep = mainLogic.realCostMoveWithoutBackProp - stepNum * usedTimes
		-- printx(11, "= = = realCostMoveWithoutBackProp", mainLogic.realCostMoveWithoutBackProp)
		-- printx(11, "= = = stepNum, usedTimes, currCircleStep", stepNum, usedTimes, currCircleStep)
		local progressPercent = math.min(currCircleStep / stepNum, 1)
		-- printx(11, "Den Progress updated:", progressPercent)
		return progressPercent
	end

	return 0
end

function PacmanLogic:updateDenProgressDisplay(mainLogic)
	local allDen = PacmanLogic:_getAllPacmansDen(mainLogic, false)
	if #allDen > 0 then
		local pickedPos = {}
		for _, den in ipairs(allDen) do
			local denView = mainLogic.boardView.baseMap[den.y][den.x]
			if denView then
				-- printx(11, "---------------- Update Den Progress!! -------------------------")
				-- printx(11, "row, column", den.y, den.x)
				denView:updatePacmansDenProgressDisplay()
			end
		end
	end
end

--- 如果可以生成吃豆人，生成多少个
function PacmanLogic:getGeneratePacmanAmountIfNeeded(mainLogic)
	-- printx(11, "= = = = = Try calculate pacman generate amount. = = = = =")
	if not mainLogic.pacmanConfig then
		return 0, 0
	end

	local stepNum = mainLogic.pacmanConfig.stepNum or 0		--每隔几步
	local unlockNum = mainLogic.pacmanConfig.unlockNum or 0		--开放几只吃豆人
	local boardMaxNum = mainLogic.pacmanConfig.boardMaxNum or 0		--棋盘（明面上）最多
	local boardMinNum = mainLogic.pacmanConfig.boardMinNum or 0		--棋盘（明面上）最少，如果不达到，无视unlockNum生成至达到
	local produceMaxNum = mainLogic.pacmanConfig.produceMaxNum or 0		--总共生成上限

	local generateNumByBoardMin = 0
	local generateNumByStep = 0
	local toProduceMaxGap = 0

	local sumGeneratedAmount = mainLogic.pacmanGeneratedByStep + mainLogic.pacmanGeneratedByBoardMin
	if produceMaxNum > 0 then
		if sumGeneratedAmount >= produceMaxNum then
			-- printx(11, "pacman produce reached max")
			return 0, 0
		else
			toProduceMaxGap = produceMaxNum - sumGeneratedAmount
		end
	end

	local boardCurrAmount = 0
	if boardMinNum > 0 or boardMaxNum > 0 then
		boardCurrAmount = #PacmanLogic:_getAllVisiblePacmanOnBoard(mainLogic)
	end

	if boardMinNum > 0 and boardCurrAmount < boardMinNum then
		generateNumByBoardMin = boardMinNum - boardCurrAmount
		-- printx(11, "+ + + generate by boardMinNum. generateAmount:", generateNumByBoardMin)
	end

	if unlockNum > 0 then
		local totalUnlockNum = PacmanLogic:_getTotalUnlockNumOfCurrStep(mainLogic)

		-- printx(11, "curr totalUnlockNum:", totalUnlockNum)
		-- printx(11, "curr pacmanGeneratedByStep:", mainLogic.pacmanGeneratedByStep)
		if mainLogic.pacmanGeneratedByStep < totalUnlockNum then
			generateNumByStep = totalUnlockNum - mainLogic.pacmanGeneratedByStep
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
function PacmanLogic:_getTotalUnlockNumOfCurrStep(mainLogic)
	local totalUnlockNum = 0

	local stepNum = mainLogic.pacmanConfig.stepNum or 0		--每隔几步
	local unlockNum = mainLogic.pacmanConfig.unlockNum or 0		--开放几只吃豆人

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

function PacmanLogic:_getAllVisiblePacmanOnBoard(mainLogic)
	local allPacman = {}
	for r = 1, #mainLogic.gameItemMap do
		for c = 1, #mainLogic.gameItemMap[r] do
			local item = mainLogic.gameItemMap[r][c]
            if item and item.ItemType == GameItemType.kPacman 
            	and item:isAvailable() then
            	table.insert(allPacman, item)
            end
		end
	end
	return allPacman
end

function PacmanLogic:pickGenerateTargets(mainLogic, needAmount)
	local pickedTargets = {}
	local candidateTargets = {}

	local allDen = PacmanLogic:_getAllPacmansDen(mainLogic, true)
	if #allDen > 0 then
		local pickedPos = {}
		for _, den in ipairs(allDen) do
			local row, col = den.y, den.x
			--- 上右下左
			local aroundX = {0, 1, 0, -1}
			local aroundY = {-1, 0, 1, 0}

			for i = 1, 4 do
				local currCol = col + aroundX[i]
				local currRow = row + aroundY[i]
				local locationKey = currCol..","..currRow

				if not pickedPos[locationKey] and not mainLogic:hasChainInNeighbors(row, col, currRow, currCol) then
					local item = mainLogic:getGameItemAt(currRow, currCol)
					if item and PacmanLogic:_isReplaceableItemForGeneratePacman(item) then
						item.pacmansDenPos = IntCoord:create(col, row)
						table.insert(candidateTargets, item)
						pickedPos[locationKey] = true
					end
				end
			end
		end
	end

	local pickAmount = math.min(#candidateTargets, needAmount)
	if pickAmount > 0 then
		if pickAmount < #candidateTargets then 
			candidateTargets = table.randomOrder(candidateTargets, mainLogic)
		end
		for j = 1, pickAmount do
			local targetItem = candidateTargets[j]
			targetItem.pacmanColour = PacmanLogic:_pickColourForNewPacman(mainLogic, targetItem)
			table.insert(pickedTargets, targetItem)
		end
	end

	return pickedTargets
end

function PacmanLogic:_getAllPacmansDen(mainLogic, isAvailableOnly)
	local allPacmansDen = {}
	for r = 1, #mainLogic.gameItemMap do
		for c = 1, #mainLogic.gameItemMap[r] do
			local item = mainLogic.gameItemMap[r][c]
            if item and item.ItemType == GameItemType.kPacmansDen then
            	if not isAvailableOnly or item:isVisibleAndFree() then
	            	table.insert(allPacmansDen, item)
	            end
            end
		end
	end
	return allPacmansDen
end

function PacmanLogic:_isReplaceableItemForGeneratePacman(item)
	if not item.isEmpty and item:isVisibleAndFree() then
		if item.ItemType == GameItemType.kCrystal then
			return true
		elseif item.ItemType == GameItemType.kAnimal and item.ItemSpecialType == 0 then
			return true
		end
	end
	return false
end

function PacmanLogic:_pickColourForNewPacman(mainLogic, targetItem)
	local pickedColour = 1
	local permittedColours = mainLogic.pacmanConfig.permittedColours
	-- printx(11, "permittedColours", table.tostring(permittedColours))
	if permittedColours == nil or #permittedColours == 0 then
		local index1 = mainLogic.randFactory:rand(1, #mainLogic.mapColorList)
		pickedColour = AnimalTypeConfig.convertColorTypeToIndex(mainLogic.mapColorList[index1])
	else
		local index2 = mainLogic.randFactory:rand(1, #permittedColours)
		pickedColour = permittedColours[index2]
	end

	-- printx(11, "Pick colour for new pacman:", pickedColour)
	return pickedColour
end

function PacmanLogic:updateNewPacman(mainLogic, targetItem)

	PacmanLogic:_addDevouredItemAsRemoved(mainLogic, targetItem, targetItem)

	--- 赋予新格子相应属性
	targetItem.ItemType = GameItemType.kPacman
	-- printx(11, " = = = updateNewPacman at ("..targetItem.x..","..targetItem.y..")")
	-- printx(11, "setPacmanColour. old("..targetItem.x..","..targetItem.y.."):"..targetItem.pacmanColour..", new("..oldPacman.x..","..oldPacman.y.."):"..oldPacman.pacmanColour)
	targetItem.pacmanDevourAmount = 0

	targetItem.isEmpty = false
	targetItem.isBlock = true
	targetItem._encrypt.ItemColorType = 0
	targetItem.ItemSpecialType = 0
	targetItem.isNeedUpdate = true

	mainLogic:checkItemBlock(targetItem.y, targetItem.x)
end

------------------------------------------------------------------------------------------------------------
--												EAT
------------------------------------------------------------------------------------------------------------
function PacmanLogic:pacmanIsFull(mainLogic, item)
	local devourAmount = item.pacmanDevourAmount
	local maxDevourAmount = (mainLogic.pacmanConfig and mainLogic.pacmanConfig.devourCount) or 1
	if devourAmount >= maxDevourAmount then
		return true
	end
	return false
end

function PacmanLogic:isReadyToEatPacman(mainLogic, item)
	if item and item.ItemType == GameItemType.kPacman then
		if not PacmanLogic:pacmanIsFull(mainLogic, item) 
			and item:isVisibleAndFree()
			then
			return true
		end
	end
	return false
end

function PacmanLogic:pickAllHungryPacman(mainLogic)
	local allHungryPacman = {}
	for r = 1, #mainLogic.gameItemMap do
		for c = 1, #mainLogic.gameItemMap[r] do
			local item = mainLogic.gameItemMap[r][c]
            if PacmanLogic:isReadyToEatPacman(mainLogic, item) then
            	table.insert(allHungryPacman, item)
            end
		end
	end
	return allHungryPacman
end

function PacmanLogic:pickTargetForCertainPacman(mainLogic, pacman, pickedPosition)
	local row, col = pacman.y, pacman.x

	--- 上右下左
	local aroundX = {0, 1, 0, -1}
	local aroundY = {-1, 0, 1, 0}
	
	local eatableItems = {}
	for i = 1, 4 do
		local currCol = col + aroundX[i]
		local currRow = row + aroundY[i]
		local locationKey = currCol..","..currRow
		if not pickedPosition[locationKey] then		--格子没有被别人吃过 / 没有将要被吃
			if not mainLogic:hasChainInNeighbors(row, col, currRow, currCol) then -- 两者之间没有冰柱
				local item = mainLogic:getGameItemAt(currRow, currCol)
				if item and PacmanLogic:_isEatableItemForPacman(item, pacman.pacmanColour) then
					table.insert(eatableItems, item)
				end
			end
		end
	end
	
	local targetItem = nil
	if #eatableItems > 0 then
		local index = mainLogic.randFactory:rand(1, #eatableItems)
		targetItem = eatableItems[index]
		
		local coordKey = targetItem.x..","..targetItem.y
		pickedPosition[coordKey] = true

		local pacmanCoord = pacman.x..","..pacman.y
		if not pickedPosition[pacmanCoord] then
			pickedPosition[pacmanCoord] = true		--加入吃豆人初始格子，方便最后统一处理
		end
	end
	
	return targetItem
end

function PacmanLogic:_isEatableItemForPacman(item, targetColourIndex)
	if not item.isEmpty and item:isVisibleAndFree() then
		if item.ItemType == GameItemType.kAnimal 
			or item.ItemType == GameItemType.kCrystal
			or item.ItemType == GameItemType.kGift
			or item.ItemType == GameItemType.kNewGift
			or item.ItemType == GameItemType.kBalloon
			then
			local realColour = AnimalTypeConfig.convertIndexToColorType(targetColourIndex)
			if item._encrypt.ItemColorType == realColour then
				return true
			end
		end
	end
	return false
end

function PacmanLogic:updatePacmanPosition(mainLogic, oldPacman, targetItem, pacmanCollection)

	PacmanLogic:_addDevouredItemAsRemoved(mainLogic, oldPacman, targetItem)

	--- 删除老格子的吃豆人属性
	oldPacman.ItemType = GameItemType.kNone

	--- 赋予新格子相应属性
	targetItem.ItemType = GameItemType.kPacman
	-- printx(11, "+ + + updatePacmanPosition to ("..targetItem.x..","..targetItem.y..")")
	-- printx(11, "setPacmanColour. old("..targetItem.x..","..targetItem.y.."):"..targetItem.pacmanColour..", new("..oldPacman.x..","..oldPacman.y.."):"..oldPacman.pacmanColour)
	targetItem.pacmanColour = oldPacman.pacmanColour
	targetItem.pacmanDevourAmount = oldPacman.pacmanDevourAmount + 1
	targetItem.pacmanIsSuper = oldPacman.pacmanIsSuper

	targetItem.isEmpty = false
	targetItem.isBlock = true
	targetItem._encrypt.ItemColorType = 0
	targetItem.ItemSpecialType = 0
	targetItem.isNeedUpdate = true

	if pacmanCollection then
		table.removeValue(pacmanCollection, oldPacman)
		table.insert(pacmanCollection, targetItem)
	end
end

--- 虽然是被吃掉了，但是需要加上被消除的效果（但不触发特效）
function PacmanLogic:_addDevouredItemAsRemoved(mainLogic, oldPacman, targetItem)

	local r, c = targetItem.y, targetItem.x
	
	local addScore = GamePlayConfigScore.MatchDeletedBase
	if targetItem.ItemType == GameItemType.kAnimal then
		if targetItem.ItemSpecialType ~= 0 then
			oldPacman.pacmanIsSuper = 0	--动画先不更新，故先置为0

			if targetItem.ItemSpecialType == AnimalTypeConfig.kLine or targetItem.ItemSpecialType == AnimalTypeConfig.kColumn then
				mainLogic:tryDoOrderList(r, c, GameItemOrderType.kSpecialBomb, GameItemOrderType_SB.kLine)
				GameExtandPlayLogic:doAllBlocker195Collect(mainLogic, r, c, Blocker195CollectType.kLine)
				SquidLogic:checkSquidCollectItem(mainLogic, r, c, SquidCollectType[1])	--直线特效没有自己的大类型，故在SquidCollectType中获取特殊代号
				addScore = GamePlayConfigScore.SpecialBombkLine
			elseif targetItem.ItemSpecialType == AnimalTypeConfig.kWrap then
				mainLogic:tryDoOrderList(r, c, GameItemOrderType.kSpecialBomb, GameItemOrderType_SB.kWrap)
				GameExtandPlayLogic:doAllBlocker195Collect(mainLogic, r, c, Blocker195CollectType.kWrap)
				SquidLogic:checkSquidCollectItem(mainLogic, r, c, SquidCollectType[2])	--爆炸特效没有自己的大类型，故在SquidCollectType中获取特殊代号
				addScore = GamePlayConfigScore.SpecialBombkWrap
			end
		end
	elseif targetItem.ItemType == GameItemType.kCrystal then
		addScore = GamePlayConfigScore.MatchDeletedCrystal
		ObstacleFootprintManager:addCrystalBallEliminateRecord(targetItem)
	elseif targetItem.ItemType == GameItemType.kNewGift then
		addScore = 0
	elseif targetItem.ItemType == GameItemType.kBalloon then
		addScore = GamePlayConfigScore.Balloon
	end

	--- 加分
	--- 统计关卡目标
	if addScore > 0 then
		mainLogic:addScoreToTotal(r, c, addScore, targetItem._encrypt.ItemColorType)
	end
	mainLogic:tryDoOrderList(r, c, GameItemOrderType.kAnimal, targetItem._encrypt.ItemColorType)

	--- 检查其他
	SnailLogic:doEffectSnailRoadAtPos(mainLogic, r, c)
	GameExtandPlayLogic:decreaseLotus(mainLogic, r, c)
	---- 检测冰块沙子
	SpecialCoverLogic:SpecialCoverLightUpAtPos(mainLogic, r, c, scoreScale)

	if targetItem:canChargeCrystalStone() then
		-- printx(11, "ChargeCrystalStone")
		GameExtandPlayLogic:chargeCrystalStone(mainLogic, r, c, targetItem._encrypt.ItemColorType)
		GameExtandPlayLogic:doAllBlocker211Collect(mainLogic, r, c, targetItem._encrypt.ItemColorType, false, 1)
	end

	GameExtandPlayLogic:itemDestroyHandler(mainLogic, r, c)
end

function PacmanLogic:cleanBoardDataAfterAllFinishedEating(mainLogic, pickedPosition)
	for k, v in pairs(pickedPosition) do
		local position = string.split(k, ",")
		local c, r = tonumber(position[1]), tonumber(position[2])

		-- printx(11, "cleanBoardData. position Row, Col:", r, c)
		local item = mainLogic:getGameItemAt(r, c)
		local itemView = mainLogic.boardView.baseMap[r][c]
		if item then
			if item.ItemType == GameItemType.kPacman then
				-- printx(11, "update pacman, isSuper:", item.pacmanIsSuper)
				if item.pacmanIsSuper == 0 then		--刚变为超级吃豆人，动画还没有变，更新动画
					item.pacmanIsSuper = 2
				end	
			else
				-- printx(11, "update eaten grid")
				--- 吃完后空着的格子
				-- GameExtandPlayLogic:itemDestroyHandler(mainLogic, r, c)
				item:cleanAnimalLikeData()
				item.isBlock = false
			end

			mainLogic:checkItemBlock(r,c)
			item.isNeedUpdate = true
		end
  	end
end

------------------------------------------------------------------------------------------------------------
--												BLOW
------------------------------------------------------------------------------------------------------------
function PacmanLogic:isReadyToBlowPacman(mainLogic, item)
	if item and item.ItemType == GameItemType.kPacman then
		if PacmanLogic:pacmanIsFull(mainLogic, item) 
			and item:isVisibleAndFree()
			then
			return true
		end
	end
	return false
end

function PacmanLogic:pickAllFullPacman(mainLogic)
	local allFullPacman = {}
	for r = 1, #mainLogic.gameItemMap do
		for c = 1, #mainLogic.gameItemMap[r] do
			local item = mainLogic.gameItemMap[r][c]
            if PacmanLogic:isReadyToBlowPacman(mainLogic, item) then
            	table.insert(allFullPacman, item)
            end
		end
	end
	return allFullPacman
end

function PacmanLogic:onHitTargets(mainLogic, pacman, targetItems)

	-- --testTmp
	-- targetItems = {}
	-- local testPoint = {x=6, y=5}
	-- table.insert(targetItems, testPoint)

	-- printx(11, "PacmanLogic:onHitTargets")
	-- for _, testPrintItem in pairs(targetItems) do
	-- 	printx(11, "target r, c:", testPrintItem.y, testPrintItem.x)
	-- end

	if not targetItems or (#targetItems <= 0) then
		return
	end

	local eliminateChainIncludeHem = false
	local specialEffect = nil
	if pacman.pacmanIsSuper then
		specialEffect = {}
		for index = 1, #targetItems do
			--1:line 2:column 3:wrap
			local specialID = mainLogic.randFactory:rand(1, 3)
			table.insert(specialEffect, specialID)
		end
	else
		eliminateChainIncludeHem = true
	end

	-- printx(11, "specialEffect", table.tostring(specialEffect))

	local function goUntilHitCoin(startX, startY, endX, endY)
		local currX = startX
		local currY = startY
		local addX, addY = 0, 0
		local hitEnd = false
		local returnVal = 0

		if endX > 0 then
			if endX > startX then addX = 1 elseif endX < startX then addX = -1 else return endX end
		end
		if endY > 0 then
			if endY > startY then addY = 1 elseif endY < startY then addY = -1 else return endY end
		end

		-- printx(11, "startX, startY, endX, endY, addX, addY:", startX, startY, endX, endY, addX, addY)

		if addX and addX ~= 0 then
			returnVal = currX
			while not hitEnd do 
				currX = currX + addX
				if mainLogic:isPosValid(currY, currX) then
					returnVal = currX
					local item = mainLogic.gameItemMap[currY][currX]
					if item and item:isVisibleAndFree() and (item.ItemType == GameItemType.kCoin or item.ItemType == GameItemType.kPuffer) then
						ObstacleFootprintManager:addBlockEffectRecord(item)
						hitEnd = true
					end
				end
				if currX == endX then
					hitEnd = true
				end
			end
		else
			returnVal = currY
			while not hitEnd do 
				currY = currY + addY
				if mainLogic:isPosValid(currY, currX) then
					returnVal = currY
					local item = mainLogic.gameItemMap[currY][currX]
					if item and item:isVisibleAndFree() and (item.ItemType == GameItemType.kCoin or item.ItemType == GameItemType.kPuffer) then
						ObstacleFootprintManager:addBlockEffectRecord(item)
						hitEnd = true
					end
				end
				if currY == endY then
					hitEnd = true
				end
			end
		end

		-- printx(11, "returnVal", returnVal)
		return returnVal
	end

	for i, targetItem in ipairs(targetItems) do
		local startPoint = IntCoord:create(targetItem.x, targetItem.y)
		local endPoint = IntCoord:create(targetItem.x, targetItem.y)
		local isWrapEffect = false
		if specialEffect then
			local specialEffectID = specialEffect[i]
			if specialEffectID == 1 then	--Line
				startPoint.x = goUntilHitCoin(targetItem.x, targetItem.y, 1, 0)
				endPoint.x = goUntilHitCoin(targetItem.x, targetItem.y, #mainLogic.gameItemMap[targetItem.y], 0)
			elseif specialEffectID == 2 then	--Column
				startPoint.y = goUntilHitCoin(targetItem.x, targetItem.y, 0, 1)
				endPoint.y = goUntilHitCoin(targetItem.x, targetItem.y, 0, #mainLogic.gameItemMap)
			elseif specialEffectID == 3 then	--Wrap
				isWrapEffect = true
			end
			-- printx(11, "specialEffectID", specialEffectID)
		end
		-- printx(11, "positions", "("..startPoint.y..","..startPoint.x..")".."("..endPoint.y..","..endPoint.x..")")
		
		if isWrapEffect then
			local diagonalSquareAction = GameBoardActionDataSet:createAs(
										GameActionTargetType.kGameItemAction,
										GameItemActionType.kItemSpecial_diagonalSquare,
										startPoint,
										nil,
										GamePlayConfig_MaxAction_time)
			diagonalSquareAction.radius = 2
			diagonalSquareAction.addInt2 = 2
			-- diagonalSquareAction.eliminateChainIncludeHem = eliminateChainIncludeHem	--斜方形先一律不考虑边框吧，有需求再加
			diagonalSquareAction.footprintType = ObstacleFootprintType.k_Pacman
			mainLogic:addDestructionPlanAction(diagonalSquareAction)
		else
			local rectangleAction = GameBoardActionDataSet:createAs(
										GameActionTargetType.kGameItemAction,
										GameItemActionType.kItemSpecial_rectangle,
										startPoint,
										endPoint,
										GamePlayConfig_MaxAction_time)
			rectangleAction.addInt2 = 1.5
			rectangleAction.eliminateChainIncludeHem = eliminateChainIncludeHem
			rectangleAction.footprintType = ObstacleFootprintType.k_Pacman
			mainLogic:addDestructionPlanAction(rectangleAction)
		end
	end
end

------------------------------------------------------------------------------------------------------------
--												PROPS
------------------------------------------------------------------------------------------------------------
function PacmanLogic:dealWithHammerHit(mainLogic, item)
	if item and item.ItemType == GameItemType.kPacman and item:isVisibleAndFree() then
		if not PacmanLogic:pacmanIsFull(mainLogic, item) then
			local hammerAddAmount = 3	--锤子的效果
			item.pacmanDevourAmount = item.pacmanDevourAmount + hammerAddAmount
			item.isNeedUpdate = true
		end
	end
end

------------------------------------------------------------------------------------------------------------
--												Others
------------------------------------------------------------------------------------------------------------
function PacmanLogic:getJumpDirectionIndex(direction)
	local jumDir = nil
	if direction.x == 0 and direction.y == 1 then
		jumDir = PacmanJumpDirection.kRight
	elseif direction.x == 0 and direction.y == -1 then
		jumDir = PacmanJumpDirection.kLeft
	elseif direction.x == 1 and direction.y == 0 then
		jumDir = PacmanJumpDirection.kDown
	elseif direction.x == -1 and direction.y == 0 then
		jumDir = PacmanJumpDirection.kUp
	end
	return jumDir
end