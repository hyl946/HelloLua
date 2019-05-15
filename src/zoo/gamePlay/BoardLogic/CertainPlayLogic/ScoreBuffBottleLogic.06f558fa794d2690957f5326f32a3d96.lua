require "zoo.localActivity.CollectStars.CollectStarsManager"
require "zoo.panel.CommonTip"

ScoreBuffBottleLogic = {}

function ScoreBuffBottleLogic:hasScoreBuffBottleInLevel(levelID)
	if ScoreBuffBottleLogic:getScoreBuffBottleInitAmount(levelID) > 0 then
		return true
	else
		return false
	end
end

function ScoreBuffBottleLogic:getScoreBuffBottleInitAmount(levelID)
	-- printx(11, "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ !!!", debug.traceback())
	--
--
--
--
--


	local mainLogic = GameBoardLogic:getCurrentLogic()
	-- printx(11, "mainLogic?", mainLogic)
	-- printx(11, "tempInitAmountForReplay", self.tempInitAmountForReplay)

	-- 来自回放数据
	if mainLogic and self.tempInitAmountForReplay then
		mainLogic.scoreBuffBottleInitAmount = self.tempInitAmountForReplay
		self.tempInitAmountForReplay = nil
		-- printx(11, "getScoreBuffBottleInitAmount from tempInitAmountForReplay, now:",  self.tempInitAmountForReplay)
	end

	if mainLogic and mainLogic.scoreBuffBottleInitAmount then
		-- printx(11, "getScoreBuffBottleInitAmount from logic", mainLogic.scoreBuffBottleInitAmount)
		return mainLogic.scoreBuffBottleInitAmount
	end

	local initAmount = 0
	if not levelID then
		if mainLogic then
			levelID = mainLogic.level
		end
	end
	if levelID and levelID > 0 then
		initAmount = CollectStarsManager:getInstance():getProgressNun(levelID)
		-- printx(11, "getScoreBuffBottleInitAmount from data, levelID, initAmount", levelID, initAmount)
		if mainLogic and not mainLogic.scoreBuffBottleInitAmount then
			mainLogic.scoreBuffBottleInitAmount = initAmount
		end
	end

	-- printx(11, "getScoreBuffBottleInitAmount from data", initAmount)
	return initAmount
end

function ScoreBuffBottleLogic:setInitAmountForReplay(amount)
	-- printx(11, "setInitAmountForReplay", amount)
	self.tempInitAmountForReplay = amount
end

function ScoreBuffBottleLogic:clearInitAmountForReplay()
	-- printx(11, "CLEAR CLEAR CLEAR !!!", amount)
	self.tempInitAmountForReplay = nil
end

function ScoreBuffBottleLogic:changeTestInitAmount()
	if not self.testInitAmount then
		self.testInitAmount = 0
	end

	self.testInitAmount = self.testInitAmount + 1

	if self.testInitAmount > 5 then
		self.testInitAmount = -1
	end

	if self.testInitAmount >= 0 then
		CommonTip:showTip( "初始刷星瓶个数："..self.testInitAmount , 'positive')
	else
		CommonTip:showTip( "关闭刷星瓶个数调试，采用实际数据", 'positive')
	end
end

function ScoreBuffBottleLogic:getLeftScoreBuffBottleAmount(mainLogic)
	local leftAmount = math.max(ScoreBuffBottleLogic:getScoreBuffBottleInitAmount() - mainLogic.generatedScoreBuffBottle, 0)
	-- printx(11, "= = = getLeftScoreBuffBottleAmount", leftAmount)
	return leftAmount
end

-- 场上是否有瓶子，需要检测（因为每次stable都要调用检测，每次都扫描棋盘不合适）
function ScoreBuffBottleLogic:needCheckScoreBuffBottle(mainLogic)
	local amountOnBoard = 0
	if mainLogic.generatedScoreBuffBottle and mainLogic.destroyedScoreBuffBottle then
		amountOnBoard = mainLogic.generatedScoreBuffBottle - mainLogic.destroyedScoreBuffBottle
	end
	-- printx(11, "= = = needCheckScoreBuffBottle", amountOnBoard)
	if amountOnBoard > 0 then
		return true
	else
		return false
	end
end

------------ 加载素材用 -------------
function ScoreBuffBottleLogic:setScoreBuffAssetFlag()
	self.scoreBuffAssetFlag = true
end

function ScoreBuffBottleLogic:hasScoreBuffForAsset(levelID)
	local flag = false
	if self.scoreBuffAssetFlag or ScoreBuffBottleLogic:hasScoreBuffBottleInLevel(levelID) then
		flag = true
	end

	self.scoreBuffAssetFlag = false
	-- printx(11, "= = = Check: hasScoreBuffForAsset", flag, self.scoreBuffAssetFlag)
	return flag
end

---------------------------------------------------- Generate ---------------------------------------------------
function ScoreBuffBottleLogic:pickValidTarget(mainLogic, replaceAmount)
	local function insertTargetByPriority(targetTable, priority, targetItem)
		if not targetTable[priority] then
			targetTable[priority] = {}
		end
		table.insert(targetTable[priority], targetItem)
	end

	local targetByPriority = {}
	for r = 1, #mainLogic.gameItemMap do
		for c = 1, #mainLogic.gameItemMap[r] do
			local item = mainLogic.gameItemMap[r][c]
			local board
			if mainLogic.boardmap[r] then board = mainLogic.boardmap[r][c] end
		    if item and board and not board.preAndBuffFirecrackerPassSelect 
		    	and item.ItemType == GameItemType.kAnimal and item.ItemSpecialType == 0 
		    	then
		    	if item:isVisibleAndFree() then
		    		insertTargetByPriority(targetByPriority, 1, item)
		    	else
		    		if not (
		    			item:hasFurball() 
		    			or item.isReverseSide 
						or item:hasActiveSuperCuteBall()
						or item.blockerCoverLevel > 0
						or item.colorFilterBLock
						or item:hasBlocker206()
						or item:seizedByGhost()
						or item:hasSquidLock()
		    			) then
		    			if item.beEffectByMimosa == GameItemType.kKindMimosa then
		    				insertTargetByPriority(targetByPriority, 2, item)
	    				elseif item.cageLevel ~= 0 then
	    					insertTargetByPriority(targetByPriority, 3, item)
	    				end
			    	end
		    	end
		    end
		end
	end

	local pickedTarget = {}
	local pickedItem
	for index = 1, replaceAmount do 
		for listIndex = 1, table.maxn(targetByPriority) do
			local subList = targetByPriority[listIndex]
			if subList and #subList > 0 then
				pickedItem = table.remove(subList, mainLogic.randFactory:rand(1, #subList))
				table.insert(pickedTarget, pickedItem)
				break
			end
		end
	end

	return pickedTarget

	--test
	-- local item = mainLogic.gameItemMap[8][5]
	-- table.insert(pickedTarget, item)
	-- return pickedTarget
end

---------------------------------------------------- Destroy ---------------------------------------------------
--------------------- Score --------------------
-- function ScoreBuffBottleLogic:getScoreBuffBottleEffectPercent()
-- 	local effectPercent = MetaManager.getInstance():getScoreBuffBottleEffectPercent()
-- 	if not effectPercent then effectPercent = 0 end
-- 	effectPercent = math.max(effectPercent, 0)
-- 	effectPercent = math.min(effectPercent, 1)

-- 	return effectPercent
-- end

function ScoreBuffBottleLogic:getScoreIncreaseValueOfBottle(mainLogic)
	-- local effectPercent = ScoreBuffBottleLogic:getScoreBuffBottleEffectPercent()
	local effectPercent = CollectStarsManager:getInstance():getScoreBuffBottleEffectPercent()

	local increaseVal = 0
	local threeStarScore = 0
	if mainLogic.scoreTargets and #mainLogic.scoreTargets >= 3 then
		threeStarScore = mainLogic.scoreTargets[3]
	end
	increaseVal = math.ceil(threeStarScore * effectPercent)

	return increaseVal
end

function ScoreBuffBottleLogic:onScoreBuffBottleSimulated(targetBottle)
	-- printx(11, "--------------- onScoreBuffBottleSimulated -----------------------")
	targetBottle.isToBlastScoreBuffBottles = true

	local mainLogic = GameBoardLogic:getCurrentLogic()
	local itemView = mainLogic.boardView.baseMap[targetBottle.y][targetBottle.x]
	if itemView then
		itemView:playScoreBuffBottleBeingHit()
	end
end

function ScoreBuffBottleLogic:getAllToBlastScoreBuffBottleOnBoard(mainLogic)
	local allBottles = {}
	for r = 1, #mainLogic.gameItemMap do
		for c = 1, #mainLogic.gameItemMap[r] do
			local item = mainLogic.gameItemMap[r][c]
            if item and item.isToBlastScoreBuffBottles and item.ItemType == GameItemType.kScoreBuffBottle and item:isVisibleAndFree() then
            	table.insert(allBottles, item)
            end
		end
	end
	return allBottles
end

function ScoreBuffBottleLogic:onDestroyScoreBuffBottle(mainLogic, targetItem)
	-- printx(11, "--------------- onDestroyScoreBuffBottle -----------------------")
	if targetItem then
		targetItem.isToBlastScoreBuffBottles = false

		GameExtandPlayLogic:chargeCrystalStone(mainLogic, targetItem.y, targetItem.x, targetItem._encrypt.ItemColorType)
		GameExtandPlayLogic:doAllBlocker211Collect(mainLogic, targetItem.y, targetItem.x, targetItem._encrypt.ItemColorType, false, 1)

		targetItem.ItemType = GameItemType.kAnimal
		local specialType = ScoreBuffBottleLogic:_getCurrSpecialType(mainLogic)
		if specialType then
			targetItem.ItemSpecialType = specialType
			if targetItem.ItemSpecialType == AnimalTypeConfig.kColor then
				targetItem._encrypt.ItemColorType = 0
			end
		end
		targetItem.isNeedUpdate = true
		mainLogic:addNeedCheckMatchPoint(targetItem.y, targetItem.x)

		-- todo : special fly effect?
		local addScore = ScoreBuffBottleLogic:getScoreIncreaseValueOfBottle(mainLogic)
		if addScore > 0 then
			mainLogic:addScoreToTotal(targetItem.y, targetItem.x, addScore, targetItem._encrypt.ItemColorType, nil, true)
		end

		mainLogic.destroyedScoreBuffBottle = mainLogic.destroyedScoreBuffBottle + 1
	end
end

function ScoreBuffBottleLogic:_getCurrSpecialType(mainLogic)
	if not mainLogic.scoreBuffBottleLeftSpecialTypes then
		local specialTypes = MetaManager.getInstance():getScoreBuffBottleSpecialTypes()
		if specialTypes and #specialTypes > 0 then
			local maxVal = math.min(ScoreBuffBottleLogic:getScoreBuffBottleInitAmount(), #specialTypes)
			local typePool = {}
			for index = 1, maxVal do
				table.insert(typePool, specialTypes[index])
			end
			mainLogic.scoreBuffBottleLeftSpecialTypes = typePool
		end
	end

	-- printx(11, "pool before:", table.tostring(mainLogic.scoreBuffBottleLeftSpecialTypes))

	local specialType
	if mainLogic.scoreBuffBottleLeftSpecialTypes then
		local specialTypeIndex = table.remove(mainLogic.scoreBuffBottleLeftSpecialTypes, 
			mainLogic.randFactory:rand(1, #mainLogic.scoreBuffBottleLeftSpecialTypes))
		if specialTypeIndex == 1 then
			local lineType = {AnimalTypeConfig.kLine, AnimalTypeConfig.kColumn}
			specialType = lineType[mainLogic.randFactory:rand(1, #lineType)]
		elseif specialTypeIndex == 2 then
			specialType = AnimalTypeConfig.kWrap
		elseif specialTypeIndex == 3 then
			specialType = AnimalTypeConfig.kColor
		end
	end

	-- printx(11, "pool after:", table.tostring(mainLogic.scoreBuffBottleLeftSpecialTypes))

	if specialType then
		return specialType
	else
		return nil
	end
end
