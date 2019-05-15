
------Match对地图的影响-----------
require "zoo.gamePlay.BoardLogic.ScoreCountLogic"

MatchCoverLogic = class{}


function MatchCoverLogic:resetEffectHelpMap(mainLogic)
	mainLogic.EffectHelpMap = nil;
	mainLogic.EffectHelpMap = {}
	for r = 1, #mainLogic.boardmap do
		mainLogic.EffectHelpMap[r] = {}
		for c = 1,#mainLogic.boardmap do
			mainLogic.EffectHelpMap[r][c] = 0
		end
	end
end

function MatchCoverLogic:resetEffectChameleonHelpMap(mainLogic)
	mainLogic.EffectChameleonHelpMap = nil;
	-- mainLogic.EffectChameleonHelpMap = {}
	-- for r = 1, #mainLogic.boardmap do
	-- 	mainLogic.EffectChameleonHelpMap[r] = {}
	-- 	for c = 1,#mainLogic.boardmap do
	-- 		mainLogic.EffectChameleonHelpMap[r][c] = {}
	-- 	end
	-- end
end

----可以被此处的Match影响到---（似乎没有引用？）
function MatchCoverLogic:canBeEffectByMatchAt(mainLogic, r, c, sId)
	if r<=0 or r>#mainLogic.boardmap or c<=0 or c>#mainLogic.boardmap[r] then return false end;

	local item = mainLogic.gameItemMap[r][c];
	local board = mainLogic.boardmap[r][c];

	if (board.iceLevel > 0) and item.ItemType ~= GameItemType.kBottleBlocker then
		return true;
	end
	return false;
end

----可以被周围的Match影响到----（似乎没有引用？）
function MatchCoverLogic:canBeEffectByMatchAround(mainLogic, r, c, sId)
	if r<=0 or r>#mainLogic.boardmap or c<=0 or c>#mainLogic.boardmap[r] then return false end

	local item = mainLogic.gameItemMap[r][c];
	local board = mainLogic.boardmap[r][c];

	return false
end

-----通过Match辅助图来标注影响图
function MatchCoverLogic:signEffectByMatchHelpMap(mainLogic)
	MatchCoverLogic:resetEffectHelpMap(mainLogic);
	MatchCoverLogic:resetEffectChameleonHelpMap(mainLogic)

	mainLogic.comboHelpDataSet = {}
	mainLogic.comboHelpList = {}		----消除的id列表
	mainLogic.comboHelpNumCountList = {}
	mainLogic.comboHelpNumCountCrystalList = {}
	mainLogic.comboSumBombScore = {}
	mainLogic.comboHelpLightUpList = {}
	mainLogic.comboHelpNumCountBalloonList = {}
	mainLogic.comboHelpNumCountRabbitList = {}
	mainLogic.comboHelpNumCountSandList = {}
	mainLogic.comboHelpNumCountRocketList = {}
	mainLogic.comboHelpNumCountTotemsList = {}
	--mainLogic.comboHelpNumCountBlockerCoverMaterialList = {}
	local pcount = 0					----有几组消除
	local firstOneList = {}

	for r = 1, #mainLogic.swapHelpMap do 
		for c = 1, #mainLogic.swapHelpMap[r] do
			local spd = mainLogic.swapHelpMap[r][c]		----消除号id
			local isSpecialType = spd < 0 -- 该位置是否是合成的特效
			if (spd < 0) then spd = -spd end 				----消除号为负数的id，和正数的绝对值相等的id属于一个集合,0表示没有响应

			if spd > 0 then 	--该格子上有匹配
				if not isSpecialType then -- 特效的分数独立计算
					mainLogic.gameItemMap[r][c].hasGivenScore = true
				end
				mainLogic.EffectHelpMap[r][c] = -1 			----计算
				--------辅助计算分数
				if (mainLogic.comboHelpDataSet[spd] == nil or mainLogic.comboHelpDataSet[spd] == 0)		----还没有被计入过，开始首次统计
					then
					-------连击计数增加
					pcount = pcount + 1
					mainLogic.comboHelpList[pcount] = spd;
					mainLogic.comboHelpDataSet[spd] = pcount;
					firstOneList[spd] = IntCoord:create(r,c);														----集合中的第一个物体，以他为基础显示获取的分数
				end
				local item = mainLogic.gameItemMap[r][c]
				----某次连击的小动物数量增加
				if item:canBeComboNum() then
					if (mainLogic.comboHelpNumCountList[spd] == nil ) then mainLogic.comboHelpNumCountList[spd] = 0 end;
					mainLogic.comboHelpNumCountList[spd] = mainLogic.comboHelpNumCountList[spd] + 1;
				end
				----某次连击的水晶球数量增加
				if item:canBeComboNumCrystal() then
					item.oldItemType = nil
					if (mainLogic.comboHelpNumCountCrystalList[spd] == nil ) then mainLogic.comboHelpNumCountCrystalList[spd] = 0 end;
					mainLogic.comboHelpNumCountCrystalList[spd] = mainLogic.comboHelpNumCountCrystalList[spd] + 1;
				end
				if item:canBeComboNumBalloon() then 
					if (mainLogic.comboHelpNumCountBalloonList[spd] == nil ) then mainLogic.comboHelpNumCountBalloonList[spd] = 0 end;
					mainLogic.comboHelpNumCountBalloonList[spd] = mainLogic.comboHelpNumCountBalloonList[spd] + 1;
				end

				if item:canBeComboNumRabbit() then
					if (mainLogic.comboHelpNumCountRabbitList[spd] == nil ) then mainLogic.comboHelpNumCountRabbitList[spd] = 0 end;
					mainLogic.comboHelpNumCountRabbitList[spd] = mainLogic.comboHelpNumCountRabbitList[spd] + 1;
				end

				if item:canBeComboNumRocket() then
					if (mainLogic.comboHelpNumCountRocketList[spd] == nil ) then mainLogic.comboHelpNumCountRocketList[spd] = 0 end;
					mainLogic.comboHelpNumCountRocketList[spd] = mainLogic.comboHelpNumCountRocketList[spd] + 1;
				end

				if item:canBeComboTotems() then
					if (mainLogic.comboHelpNumCountTotemsList[spd] == nil ) then mainLogic.comboHelpNumCountTotemsList[spd] = 0 end;
					mainLogic.comboHelpNumCountTotemsList[spd] = mainLogic.comboHelpNumCountTotemsList[spd] + 1;
				end

				----统计爆炸的分数
				if mainLogic.comboSumBombScore[spd] == nil then mainLogic.comboSumBombScore[spd] = 0 end;
				if (mainLogic.swapHelpMap[r][c] > 0 ) then
					-----炸掉的部分，计算爆炸得分
					mainLogic.comboSumBombScore[spd] = mainLogic.comboSumBombScore[spd] + ScoreCountLogic:getScoreWithItemBomb(item)
				end
				
				if mainLogic.comboHelpLightUpList[spd] == nil then mainLogic.comboHelpLightUpList[spd] = 0 end
				if MatchCoverLogic:doEffectToLightUp(mainLogic, r, c) then
					mainLogic.comboHelpLightUpList[spd] = mainLogic.comboHelpLightUpList[spd] + 1
				end

				MatchCoverLogic:doEffectToBiscuit(mainLogic, r, c)

				if MatchCoverLogic:doEffectSandAtPos(mainLogic, r, c) then
					local sandCount = mainLogic.comboHelpNumCountSandList[spd] or 0
					mainLogic.comboHelpNumCountSandList[spd] = sandCount + 1
				end
				SnailLogic:SpecialCoverSnailRoadAtPos( mainLogic, r, c)

			elseif spd == 0 then  --该格子上无匹配
				MatchCoverLogic:trySignAtByAround(mainLogic, r, c)
			end
		end
	end

	local hasDifficultyAdjust = mainLogic:difficultyAdjustActivated()
	local ScoreAdjustConfig = LevelDiffcultyAdjustScoreLimitConfig[5][1]

	local currDS = ProductItemDiffChangeLogic:getCurrDS()
	if currDS and currDS > 0 then
		local uid = UserManager:getInstance():getUID() or "12345"
		local userGroup = 0
		if MaintenanceManager:getInstance():isEnabledInGroup("ScoreAdjustLogic" , "A" , uid) then
			userGroup = 1
		elseif MaintenanceManager:getInstance():isEnabledInGroup("ScoreAdjustLogic" , "B" , uid) then
			userGroup = 2
		elseif MaintenanceManager:getInstance():isEnabledInGroup("ScoreAdjustLogic" , "C" , uid) then
			userGroup = 3
		end

		if userGroup > 0 then
			ScoreAdjustConfig = LevelDiffcultyAdjustScoreLimitConfig[tonumber(currDS)][userGroup]
		else
			ScoreAdjustConfig = LevelDiffcultyAdjustScoreLimitConfig[5][1]
		end
	else
		hasDifficultyAdjust = false  --如果当前干预强度为0，那么可能是因为干预类型是FUUU，而次数正好处于不干预状态，所以这种情况也不会进行分数修正
	end


	for k,v in pairs(mainLogic.comboHelpList) do
		local spd = v
		local productSpecialType = mainLogic.swapHelpList[spd]		----合成的新的小动物的特效类型
		local numCount = mainLogic.comboHelpNumCountList[spd] 		----消除的小动物的数量
		local numCountCrystal = mainLogic.comboHelpNumCountCrystalList[spd] 		----消除的小动物的数量
		local numCountBalloon = mainLogic.comboHelpNumCountBalloonList[spd]
		local numCountRabbit = mainLogic.comboHelpNumCountRabbitList[spd]
		local bombScore = mainLogic.comboSumBombScore[spd]			----消除的小动物爆炸统计分数
		local lightCount = mainLogic.comboHelpLightUpList[spd]
		local numSand = mainLogic.comboHelpNumCountSandList[spd]
		local numRocket = mainLogic.comboHelpNumCountRocketList[spd]
		local numTotems = mainLogic.comboHelpNumCountTotemsList[spd] or 0
		local pos = firstOneList[spd]								----消除的小动物首个位置

		if numCount == nil then numCount = 0; end;
		if bombScore == nil then bombScore = 0; end;
		if numCountCrystal == nil then numCountCrystal = 0; end;
		if numCountBalloon == nil then numCountBalloon = 0 end
		if numCountRabbit == nil then numCountRabbit = 0 end
		if numRocket == nil then numRocket = 0 end
		numSand = numSand or 0

		if pos then
			local scoreTotal = 0
			local fixedScoreTotal = 0
			local oringinScoreTotal = 0

			local hasScoreFixed = false
			--hasDifficultyAdjust = true --for test !!!!!!!!!!!!!!!!!!!!!
			--printx( 1 , "hasDifficultyAdjust  -------------------------------------------------------  " , hasDifficultyAdjust)
			if hasDifficultyAdjust or TestDifficultyAdjustActivatedValue then
				-- test version
				local comboScale = ScoreCountLogic:getComboWithCount(mainLogic, k)
				local comboScaleThreshold = ScoreAdjustConfig.comboScaleThreshold
				local comboScaleAttenuation = ScoreAdjustConfig.comboScaleAttenuation

				local function fixScore( num , threshold , attenuation)
					local rst = num
					if num > threshold then

						rst = threshold - ( ( num - threshold ) / attenuation * threshold )
						if rst < 1 then rst = 1 end
						rst = math.floor(rst)
					end

					return rst
				end

				--printx( 1 , "comboScale = " , comboScale )
				comboScale = fixScore( comboScale , ScoreAdjustConfig.comboScaleThreshold , ScoreAdjustConfig.comboScaleAttenuation )
				--printx( 1 , "comboScale  fixScore = " , comboScale )
				numCount = fixScore( numCount , ScoreAdjustConfig.numCountThreshold , ScoreAdjustConfig.numCountAttenuation )
				lightCount = fixScore( lightCount , ScoreAdjustConfig.lightCountThreshold , ScoreAdjustConfig.lightCountAttenuation )
				numCountCrystal = fixScore( numCountCrystal , ScoreAdjustConfig.numCountCrystalThreshold , ScoreAdjustConfig.numCountCrystalAttenuation )
				numCountBalloon = fixScore( numCountBalloon , ScoreAdjustConfig.numCountBalloonThreshold , ScoreAdjustConfig.numCountBalloonAttenuation )
				numCountRabbit = fixScore( numCountRabbit , ScoreAdjustConfig.numCountRabbitThreshold , ScoreAdjustConfig.numCountRabbitAttenuation )
				numSand = fixScore( numSand , ScoreAdjustConfig.numSandThreshold , ScoreAdjustConfig.numSandAttenuation )
				numRocket = fixScore( numRocket , ScoreAdjustConfig.numRocketThreshold , ScoreAdjustConfig.numRocketAttenuation )
				numTotems = fixScore( numTotems , ScoreAdjustConfig.numTotemsThreshold , ScoreAdjustConfig.numTotemsAttenuation )

				scoreTotal = 
					ScoreCountLogic:getScoreWithSpecialTypeCombine(productSpecialType) 								----特效加分
					+ comboScale * numCount * GamePlayConfigScore.MatchDeletedBase 			----连击次数*小动物个数*一个小动物10分
					+ comboScale * lightCount * GamePlayConfigScore.MatchAtIce
					+ numCountCrystal * GamePlayConfigScore.MatchDeletedCrystal 													----水晶个数*一个水晶分数
					+ bombScore 																									----爆炸加分
					+ numCountBalloon * GamePlayConfigScore.Balloon
					+ numCountRabbit * GamePlayConfigScore.Rabbit
					+ numSand * GamePlayConfigScore.SandClean
					+ numRocket * GamePlayConfigScore.Rocket
					+ numTotems * GamePlayConfigScore.NormalTotems

				hasScoreFixed = true

			end

			local comboScale = ScoreCountLogic:getComboWithCount(mainLogic, k)

			oringinScoreTotal = 
				ScoreCountLogic:getScoreWithSpecialTypeCombine(productSpecialType) 								----特效加分
				+ comboScale * numCount * GamePlayConfigScore.MatchDeletedBase 			----连击次数*小动物个数*一个小动物10分
				+ comboScale * lightCount * GamePlayConfigScore.MatchAtIce
				+ numCountCrystal * GamePlayConfigScore.MatchDeletedCrystal 													----水晶个数*一个水晶分数
				+ bombScore 																									----爆炸加分
				+ numCountBalloon * GamePlayConfigScore.Balloon
				+ numCountRabbit * GamePlayConfigScore.Rabbit
				+ numSand * GamePlayConfigScore.SandClean
				+ numRocket * GamePlayConfigScore.Rocket
				+ numTotems * GamePlayConfigScore.NormalTotems

			if not hasScoreFixed then
				scoreTotal = oringinScoreTotal
			end
			

			local item = mainLogic.gameItemMap[pos.x][pos.y]
			mainLogic:addScoreToTotal(pos.x, pos.y, scoreTotal, item._encrypt.ItemColorType, 3 , nil , oringinScoreTotal) ----一整次消除所得分数
		end
	end
end

-----帮助标注---
function MatchCoverLogic:trySignAtByAround(mainLogic, r, c)
	local addset = {}

	if r - 1 > 0 then 
		MatchCoverLogic:signCertainGrid(mainLogic, r, c, r - 1, c, addset)
	end
	if r + 1 <= #mainLogic.swapHelpMap then 
		MatchCoverLogic:signCertainGrid(mainLogic, r, c, r + 1, c, addset)
	end
	if c - 1 > 0 then 
		MatchCoverLogic:signCertainGrid(mainLogic, r, c, r, c - 1, addset)
	end
	if c + 1 <= #mainLogic.swapHelpMap[r] then 
		MatchCoverLogic:signCertainGrid(mainLogic, r, c, r, c + 1, addset)
	end

	local count = 0
	for k,v in pairs(addset) do
		if k > 1 and v == true then count = count + 1 end
	end

	----周围match了count次
	mainLogic.EffectHelpMap[r][c] = count
end

function MatchCoverLogic:signCertainGrid(mainLogic, rOrig, cOrig, r, c, addset)
	local item = mainLogic.gameItemMap[r][c]
	local swapFlag = math.abs(mainLogic.swapHelpMap[r][c])

	if not mainLogic:hasChainInNeighbors(rOrig, cOrig, r, c) and swapFlag > 0 then
		if item:canEffectAroundOnMatch(true) then  --包含萌豆的影响
			if item:canEffectAroundOnMatch() then  --EffectHelpMap记录，不考虑萌豆影响
				addset[swapFlag + 1] = true
			end

			--------EffectChameleonHelpMap记录，考虑萌豆影响----------
			--目前只针对有变色龙的情况下进行记录
			local origGridItem = mainLogic.gameItemMap[rOrig][cOrig]
			if origGridItem and origGridItem.ItemType == GameItemType.kChameleon then
				-- printx(11, "FROM: ", r, c, "AFFECT:", rOrig, cOrig)
				-- printx(11, "Item Status: ", table.tostring(item))
				-- printx(11, "specialType: ", item.ItemSpecialType)
				local targetColour = item._encrypt.ItemColorType
				local targetSpecial = item.ItemSpecialType

				-- printx(11, "originColourAndSpecial: ", table.tostring(item.originColourAndSpecial))
				--因为是先合成后检测周边，所以魔力鸟合成后丢失来源颜色，特效被合成后丢失来源special
				if item.originColourAndSpecial and #item.originColourAndSpecial > 0 then
					local oldColour = item.originColourAndSpecial[1]
					local oldSpecial = item.originColourAndSpecial[2]
					targetColour = oldColour
					targetSpecial = oldSpecial
				end

				--注意，这种写法是非法的，因为targetColour是加密的，实际的内存引用地址可能会变化
				-- local colourIndex = AnimalTypeConfig.colorTableToIndex[targetColour] 

				local colourIndex = AnimalTypeConfig.convertColorTypeToIndex(targetColour)
				
				if colourIndex and colourIndex > 0 then
					local effectRecord = colourIndex..","..targetSpecial
					-- printx(11, "effectRecord: ", effectRecord)

					if mainLogic.EffectChameleonHelpMap == nil then
						mainLogic.EffectChameleonHelpMap = {}
					end
					if mainLogic.EffectChameleonHelpMap[rOrig] == nil then
						mainLogic.EffectChameleonHelpMap[rOrig] = {}
					end
					if mainLogic.EffectChameleonHelpMap[rOrig][cOrig] == nil then
						mainLogic.EffectChameleonHelpMap[rOrig][cOrig] = {}
					end
					
					local chameleonEffectRecord = mainLogic.EffectChameleonHelpMap[rOrig][cOrig]
					-- printx(11, "chameleonEffectRecord before: ", table.tostring(chameleonEffectRecord))
					if not chameleonEffectRecord then
						chameleonEffectRecord = {}
					end
					table.insert(chameleonEffectRecord, effectRecord)
					-- printx(11, rOrig, cOrig, "chameleonEffectRecord after: ", table.tostring(chameleonEffectRecord))
					mainLogic.EffectChameleonHelpMap[rOrig][cOrig] = chameleonEffectRecord
				end
			end
		end
	end

	-- if item:canEffectAroundOnMatch() and not mainLogic:hasChainInNeighbors(rOrig, cOrig, r, c) then
	-- 	addset[math.abs(mainLogic.swapHelpMap[r][c]) + 1] = true 
	-- end
end

function MatchCoverLogic:doEffectToLightUp(mainLogic, r, c)
	if not mainLogic:isPosValid(r, c) then return false end

	local item = mainLogic.gameItemMap[r][c]
	local board = mainLogic.boardmap[r][c]
	------2.冰层变化------
	if item:canEffectLightUp() and board.iceLevel > 0 and board.blockerCoverMaterialLevel == 0 then
		GameExtandPlayLogic:decIceLevelAt(mainLogic, r, c)
		return true
	end

	return false
end

function MatchCoverLogic:doEffectToBiscuit( mainLogic, r, c )
	if not mainLogic:isPosValid(r, c) then return false end
	local item = mainLogic.gameItemMap[r][c]
	local boardmap = mainLogic.boardmap[r][c]
	local biscuitBoardData = GameExtandPlayLogic:findBiscuitBoardDataCoveredMe(mainLogic, r, c)
	if biscuitBoardData then
		local milkRow, milkCol = biscuitBoardData:convertToMilkRC(r, c)
		if item:canEffectLightUp() and biscuitBoardData:canApplyMilkAt(milkRow, milkCol) and boardmap.blockerCoverMaterialLevel == 0 then
			GameExtandPlayLogic:applyMilkOnBiscuitAt(mainLogic, biscuitBoardData, milkRow, milkCol, r, c)
			return true
		end
		return false
	end
end

function MatchCoverLogic:doEffectSandAtPos(mainLogic, r, c)
	if not mainLogic:isPosValid(r, c) then return false end
	local board = mainLogic.boardmap[r][c]
	local item = mainLogic.gameItemMap[r][c]

	if item:canEffectLightUp() and board.sandLevel > 0 and board.blockerCoverMaterialLevel == 0 then
		board.sandLevel = board.sandLevel - 1
		local sandCleanAction = GameBoardActionDataSet:createAs(
			GameActionTargetType.kGameItemAction,
			GameItemActionType.kItem_Sand_Clean,
			IntCoord:create(r,c),				
			nil,				
			GamePlayConfig_MaxAction_time)
		mainLogic:addDestroyAction(sandCleanAction)
		mainLogic:tryDoOrderList(r, c, GameItemOrderType.kOthers, GameItemOrderType_Others.kSand, 1)
		ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_Sand, ObstacleFootprintAction.k_Eliminate, 1)
		return true
	end
	return false
end



function MatchCoverLogic:doEffectChainsAtPosWithDirs(mainLogic, r, c, breakDirs)
	if not mainLogic:isPosValid(r, c) or #breakDirs < 1 then return false end

	local board = mainLogic.boardmap[r][c]
	local breakLevels = board:decChainsInDirections(breakDirs)
	local notEmpty = false
	local hasChainBreaked = false
	for dir, level in pairs(breakLevels) do
		if level > 0 then 
			notEmpty = true
		end
		if level == 1 then
			hasChainBreaked = true
		end
	end
	if not notEmpty then return false end

	mainLogic.boardView.baseMap[r][c]:playChainBreakAnim(breakLevels, nil)

	if hasChainBreaked then
		mainLogic:setChainBreaked()
		mainLogic.gameMode:checkDropDownCollect(r, c)
	end

	board.isNeedUpdate = true
	return true
end

-- 消除被match的格子及其四周响应方向上的冰柱，同一个matchData的不可相互消除
function MatchCoverLogic:doEffectChainsAtPos(mainLogic, r, c)
	if not mainLogic:isPosValid(r, c) then return false end
	local board = mainLogic.boardmap[r][c]
	local item = mainLogic.gameItemMap[r][c]

	local ret = false
	local breakDirs = {ChainDirConfig.kUp, ChainDirConfig.kDown, ChainDirConfig.kLeft, ChainDirConfig.kRight}
	if self:doEffectChainsAtPosWithDirs(mainLogic, r, c, breakDirs) then
		ret = true
	end

	local function canEffectNearby(r2, c2)
		if not mainLogic:isPosValid(r2, c2) then return false end
		local item2 = mainLogic.gameItemMap[r2][c2]
		if (item2 and not item2:canEffectChains())  -- 该位置不能影响自己格内的冰柱
				or not mainLogic:isTheSameMatchData(r, c, r2, c2) then -- 或者两者不属于同一匹配组
			return true
		end
		return false
	end

	if canEffectNearby(r-1, c) then 
		if self:doEffectChainsAtPosWithDirs(mainLogic, r-1, c, {ChainDirConfig.kDown}) then
			ret = true
		end
	end
	if canEffectNearby(r+1, c) then 
		if self:doEffectChainsAtPosWithDirs(mainLogic, r+1, c, {ChainDirConfig.kUp}) then
			ret = true
		end
	end
	if canEffectNearby(r, c-1) then 
		if self:doEffectChainsAtPosWithDirs(mainLogic, r, c-1, {ChainDirConfig.kRight}) then
			ret = true
		end
	end
	if canEffectNearby(r, c+1) then 
		if self:doEffectChainsAtPosWithDirs(mainLogic, r, c+1, {ChainDirConfig.kLeft}) then
			ret = true
		end
	end
	return ret
end

--------响应match的变化-------
function MatchCoverLogic:doEffectByMatchHelpMap(mainLogic)
	mainLogic.newSuperTotemsPos = {}

	----0. 通过EffectChameleonHelpMap检测处理影响变色龙的匹配
	-------因为某些碰撞消除会影响到锁的状态，所以先处理变色龙，再处理doEffectAtByMatchAround
	ChameleonLogic:checkTransformByEffectMap(mainLogic)

    ----1, 果酱传播要在消除之前判断 要不然会把障碍先消除了。造成错误的传播
    GameExtandPlayLogic:doJamSperadCheck( mainLogic )

	----1.检测match对棋盘的变化
	for r=1,#mainLogic.EffectHelpMap do
		for c=1,#mainLogic.EffectHelpMap[r] do
			local spd = mainLogic.swapHelpMap[r][c];		----消除号id
			if (spd < 0) then spd = -spd; end
			local comboCount = mainLogic.comboHelpDataSet[spd];

			if mainLogic.EffectHelpMap[r][c] == -1 then 		----当前位置发生match
				--printx(11, "Effect -1: ", r, c);
				MatchCoverLogic:doEffectAtByMatchAt(mainLogic, r, c, comboCount)
			elseif mainLogic.EffectHelpMap[r][c] > 0 then		----当前位置周围有n次match
				--printx(11, "Effect >1: ", r, c, mainLogic.EffectHelpMap[r][c]);
				MatchCoverLogic:doEffectAtByMatchAround(mainLogic, r, c, comboCount)
			end
		end
	end

	local action = GameBoardActionDataSet:createAs(
                    GameActionTargetType.kGameItemAction,
                    GameItemActionType.kItem_SuperTotems_Bomb_By_Match,
                    nil,
                    nil,
                    1)
    mainLogic:addDestroyAction(action)

	-- match 产生的图腾一次性处理
	mainLogic:tryBombSuperTotems()

	if #mainLogic.comboHelpList > 0 then
		ScoreCountLogic:addCombo(mainLogic, #mainLogic.comboHelpList);
	end
end

----------------------此处Match消除，引起相应变化---------
function MatchCoverLogic:doEffectAtByMatchAt(mainLogic, r, c, comboCount)
	if r<=0 or r>#mainLogic.boardmap or c<=0 or c>#mainLogic.boardmap[r] then return false end;

	local item = mainLogic.gameItemMap[r][c];
	local board = mainLogic.boardmap[r][c];

--    if board.isJamSperad then
--        GameExtandPlayLogic:doJamSperadCreate( mainLogic, r, c )
--    end

	------1.牢笼--------
	if item.cageLevel > 0 then
		----1-1.数据变化
		item.cageLevel = item.cageLevel - 1
		mainLogic:checkItemBlock(r,c)
		
		----1-2.分数统计
		mainLogic:addScoreToTotal(r, c, GamePlayConfigScore.MatchAtLock)

		----1-3.播放特效
		local LockAction = GameBoardActionDataSet:createAs(
			GameActionTargetType.kGameItemAction,
			GameItemActionType.kItemMatchAt_LockDec,
			IntCoord:create(r,c),				
			nil,				
			1)
		mainLogic:addDestroyAction(LockAction)
		return
	elseif item.honeyLevel > 0 then
		GameExtandPlayLogic:honeyDestroy( mainLogic, r, c, 1 )
		return
	elseif item.beEffectByMimosa == GameItemType.kKindMimosa then
		GameExtandPlayLogic:backMimosaToRC(mainLogic, r, c)
		return 
	end
	if item.ItemType == GameItemType.kMagicLamp and item.lampLevel > 0 and item.lampLevel < 5 and 
		item:isAvailable() and board.lotusLevel <= 1 and not board.isJustEffectByFilter then
		GameExtandPlayLogic:onChargeMagicLamp(mainLogic, r, c, 1)
	elseif item.ItemType == GameItemType.kWukong 
    		and item.wukongProgressCurr < item.wukongProgressTotal 
    		and ( item.wukongState == TileWukongState.kNormal or item.wukongState == TileWukongState.kOnHit )
    		and item:isAvailable() and not mainLogic.isBonusTime then
		local action = GameBoardActionDataSet:createAs(
                    GameActionTargetType.kGameItemAction,
                    GameItemActionType.kItem_Wukong_Charging,
                    IntCoord:create(r, c),
                    nil,
                    GamePlayConfig_MaxAction_time
                )
		local wukongMathPositions = {}
		if mainLogic.swapHelpMap then

			local moneyMathID = math.abs( mainLogic.swapHelpMap[r][c] )

			for r1 = 1, #mainLogic.swapHelpMap do
				for c1 = 1,#mainLogic.swapHelpMap[r1] do
					local mathID = math.abs( mainLogic.swapHelpMap[r1][c1] )
					if mathID > 0 and mathID == moneyMathID and not(r1 == r and c1 == c) then
						table.insert( wukongMathPositions , mainLogic:getGameItemPosInView(r1, c1) )
					end

				end
			end
			action.fromPosition = wukongMathPositions
		end

		action.count = #wukongMathPositions
	    mainLogic:addDestroyAction(action) 
	elseif item.ItemType == GameItemType.kDrip then
		mainLogic:addScoreToTotal(r, c, GamePlayConfigScore.MatchAtLock)

		if item.dripState == DripState.kGrow then
			local dripMatchCount = 0
			if mainLogic.swapHelpMap then
				local leaderMathID = math.abs( mainLogic.swapHelpMap[r][c] )
				for r1 = 1, #mainLogic.swapHelpMap do
					for c1 = 1,#mainLogic.swapHelpMap[r1] do
						local mathID = math.abs( mainLogic.swapHelpMap[r1][c1] )
						if mathID > 0 and mathID == leaderMathID then
							dripMatchCount = dripMatchCount + 1
						end
					end
				end
			end
			item.dripMatchCount = dripMatchCount
		end
		
	elseif item.ItemType == GameItemType.kQuestionMark and item:isQuestionMarkcanBeDestroy() then
		GameExtandPlayLogic:questionMarkBomb( mainLogic, r, c )
	elseif item.ItemType == GameItemType.kBottleBlocker and item.bottleLevel > 0 and item:isAvailable() then
		--if item.bottleState == BottleBlockerState.Waiting then
			GameExtandPlayLogic:decreaseBottleBlocker(mainLogic, r, c , 1 , false)
		--end
	elseif item.ItemType == GameItemType.kTotems then
		GameExtandPlayLogic:changeTotemsToWattingActive(mainLogic, r, c, nil, false)
	elseif item:isBlocker199Active() then
		GameExtandPlayLogic:matchBlocker199(mainLogic, r, c, 1)
	elseif item.ItemType == GameItemType.kScoreBuffBottle and item:isVisibleAndFree() then
	  	ScoreBuffBottleLogic:onScoreBuffBottleSimulated(item)
	elseif item.ItemType == GameItemType.kFirecracker and item:isVisibleAndFree() then
	  	FirecrackerLogic:onFirecrackerSimulated(item)
	end

	if board.blockerCoverMaterialLevel > 0 and item:canEffectLightUp() and not item.isReverseSide then
		GameExtandPlayLogic:decreaseBlockerCoverMaterialLevelAt(mainLogic, r, c)
		SnailLogic:SpecialCoverSnailRoadAtPos( mainLogic, r, c)
	elseif board.lotusLevel > 0 and item:canEffectLotus(board.lotusLevel) then
		GameExtandPlayLogic:decreaseLotus(mainLogic, r, c , 1 , false)
	end

	if item:canEffectChains() then
		self:doEffectChainsAtPos(mainLogic, r, c)
	end
end

--周围有东西被消除，触发相应的障碍逻辑
function MatchCoverLogic:doEffectAtByMatchAround(mainLogic, r, c, comboCount)
	if r<=0 or r>#mainLogic.boardmap or c<=0 or c>#mainLogic.boardmap[r] then return false end;

	local item = mainLogic.gameItemMap[r][c];
	local board = mainLogic.boardmap[r][c];
	local count = mainLogic.EffectHelpMap[r][c];
	local t_count = count
	
	-- printx(11, table.tostring(AnimalTypeConfig.colorTypeList))
	-- printx(11, table.tostring(item._encrypt.ItemColorType))
	-- printx(11, "+ + + + + + + + + + + + + + + + + + + + + + + + ")
	-- printx(11, AnimalTypeConfig.colorTypeList[2])
	-- printx(11, AnimalTypeConfig.kGreen)
	-- printx(11, item._encrypt.ItemColorType)
	-- printx(11, r, c, item.ItemType, AnimalTypeConfig.colorTableToIndex[item._encrypt.ItemColorType])

	if board.colorFilterBLevel > 0 and not item.isReverseSide and not item:hasBlocker206() and not item:hasSquidLock() then
		local f_count = 1;
		if board.colorFilterBLevel >= count then
			f_count = count
		else
			f_count = board.colorFilterBLevel
		end
		local color = AnimalTypeConfig.colorTypeList[board.colorFilterColor]
		mainLogic:addScoreToTotal(r, c, GamePlayConfigScore.MatchBySnow * f_count, color)
		ColorFilterLogic:dcreaseColorFilterB(r, c, count)
		return 
	end

	if not item:isAvailable() or item.beEffectByMimosa > 0 then 
		if item:isFreeGhost() then
			GhostLogic:addGhostPace(mainLogic, item, count)
		end
		if item.blockerCoverLevel > 0 and not item.isReverseSide then
			GameExtandPlayLogic:decreaseBlockerCover( mainLogic, r, c )
		end
		return  
	end

	local hashoney = item.honeyLevel > 0
	--蜂蜜------------------
	if item.honeyLevel > 0 and item.blockerCoverLevel == 0 then
		GameExtandPlayLogic:honeyDestroy( mainLogic, r, c, 1 )
	end

	if board.lotusLevel == 3 then

		GameExtandPlayLogic:decreaseLotus(mainLogic, r, c , 1 , false)
	
	elseif (item.snowLevel > 0 and t_count > 0) then
		----1.检测雪花消除----
		----1-1.数据变化
		local f_count = 1;
		if item.snowLevel >= t_count then
			item.snowLevel = item.snowLevel - t_count;
			f_count = t_count;
			t_count = 0;
		else
			t_count = t_count - item.snowLevel;
			f_count = item.snowLevel;
			item.snowLevel = 0;
		end
		if item.snowLevel == 0 then
			SnailLogic:SpecialCoverSnailRoadAtPos( mainLogic, r, c )
			item:AddItemStatus(GameItemStatusType.kDestroy)
			mainLogic:tryDoOrderList(r,c,GameItemOrderType.kSpecialTarget, GameItemOrderType_ST.kSnowFlower, 1) -------记录消除
		end
		
		----1-2.分数统计
		mainLogic:addScoreToTotal(r, c, GamePlayConfigScore.MatchBySnow * f_count)

		local cd = GamePlayConfig_GameItemSnowDeleteAction_CD
		
		----1-3.播放特效
		local SnowAction = GameBoardActionDataSet:createAs(
			GameActionTargetType.kGameItemAction,
			GameItemActionType.kItemMatchAt_SnowDec,
			IntCoord:create(r,c),				
			nil,				
			cd)
		SnowAction.addInt = item.snowLevel + 1
		SnowAction.hitTimes = f_count
		mainLogic:addDestroyAction(SnowAction)
	elseif item.venomLevel > 0 then
		item.venomLevel = item.venomLevel - 1
		item:AddItemStatus(GameItemStatusType.kDestroy)
		SnailLogic:SpecialCoverSnailRoadAtPos( mainLogic, r, c )
		mainLogic:tryDoOrderList(r, c, GameItemOrderType.kSpecialTarget, GameItemOrderType_ST.kVenom, 1)

		mainLogic:addScoreToTotal(r, c, GamePlayConfigScore.MatchBySnow)

		local VenomAction = GameBoardActionDataSet:createAs(
			GameActionTargetType.kGameItemAction,
			GameItemActionType.kItemMatchAt_VenowDec,
			IntCoord:create(r, c),
			nil,
			GamePlayConfig_GameItemBlockerDeleteAction_CD)
		mainLogic:addDestroyAction(VenomAction)
	elseif item.olympicLockLevel > 0 then
		GameExtandPlayLogic:decreaseOlympicLock(mainLogic, r, c)
	elseif item.furballLevel > 0 
		and (item.ItemStatus == GameItemStatusType.kNone 
		or item.ItemStatus == GameItemStatusType.kItemHalfStable)
		then
		if item.furballType == GameItemFurballType.kGrey then
			item.furballLevel = 0
			item.furballType = GameItemFurballType.kNone
			item.furballDeleting = true

			local addScore = GamePlayConfigScore.Furball
			mainLogic:addScoreToTotal(r, c, addScore)

			local FurballAction = GameBoardActionDataSet:createAs(
				GameActionTargetType.kGameItemAction,
				GameItemActionType.kItem_Furball_Grey_Destroy,
				IntCoord:create(r, c),
				nil,
				GamePlayConfig_GameItemGreyFurballDeleteAction_CD)
			mainLogic:addDestroyAction(FurballAction)
			mainLogic:tryDoOrderList(r, c, GameItemOrderType.kSpecialTarget, GameItemOrderType_ST.kGreyCuteBall, 1)
		elseif item.furballType == GameItemFurballType.kBrown and not item.isBrownFurballUnstable then
			local FurballAction = GameBoardActionDataSet:createAs(
				GameActionTargetType.kGameItemAction,
				GameItemActionType.kItem_Furball_Brown_Shield,
				IntCoord:create(r, c),
				nil,
				1)
			mainLogic:addGameAction(FurballAction)
		end
	elseif item.ItemType == GameItemType.kBlackCuteBall and (item.ItemStatus == GameItemStatusType.kNone 
		or item.ItemStatus == GameItemStatusType.kItemHalfStable) then
		GameExtandPlayLogic:onDecBlackCuteball(mainLogic, item, t_count)
	elseif item.ItemType == GameItemType.kCoin 
		and (item.ItemStatus == GameItemStatusType.kNone 
		or item.ItemStatus == GameItemStatusType.kItemHalfStable)
		and not hashoney
		then
		item:AddItemStatus(GameItemStatusType.kDestroy)
		mainLogic:addScoreToTotal(r, c, GamePlayConfigScore.MatchBySnow)

		--2017元宵节
		local cd
		--[[if _G.IS_PLAY_YUANXIAO2017_LEVEL then
			cd = 20 * GamePlayConfig_Action_FPS_Time_Scale_F
		else]]
			cd = GamePlayConfig_GameItemAnimalDeleteAction_CD
		--end
		local CoinAction = GameBoardActionDataSet:createAs(
			GameActionTargetType.kGameItemAction,
			GameItemActionType.kItemDeletedByMatch,
			IntCoord:create(r, c),
			nil,
			cd)
		mainLogic:addDestroyAction(CoinAction)		
	
	elseif item.ItemType == GameItemType.kRoost 
		and (item.ItemStatus == GameItemStatusType.kNone or item.ItemStatus == GameItemStatusType.kItemHalfStable)
		then
		GameExtandPlayLogic:onUpgradeRoost(mainLogic, item, t_count)
	elseif item.digGroundLevel > 0 and item.digBlockCanbeDelete == true  then
		item.digBlockCanbeDelete = false
		GameExtandPlayLogic:decreaseDigGround(mainLogic, r, c)
	elseif item.digJewelLevel > 0 and item.digBlockCanbeDelete == true  then
		item.digBlockCanbeDelete = false
		GameExtandPlayLogic:decreaseDigJewel(mainLogic, r, c)
	elseif item.randomPropLevel > 0 and item.digBlockCanbeDelete == true  then
		item.digBlockCanbeDelete = false
		GameExtandPlayLogic:hitRandomProp(mainLogic, r, c)
	elseif item.bigMonsterFrostingType > 0 then 
		--add score
		local addScore = GamePlayConfigScore.MatchBySnow
		mainLogic:addScoreToTotal(r, c, addScore)
		--dec ice
		if item.bigMonsterFrostingStrength > 0 then 
			item.bigMonsterFrostingStrength = item.bigMonsterFrostingStrength - 1
			local decAction = GameBoardActionDataSet:createAs(
				GameActionTargetType.kGameItemAction,
				GameItemActionType.kItem_Monster_frosting_dec,
				IntCoord:create(r, c),
				nil,
				GamePlayConfig_MonsterFrosting_Dec)
			mainLogic:addDestroyAction(decAction)
		end
	elseif item.chestSquarePartType > 0 then 
		GameExtandPlayLogic:hitChestSquare(mainLogic,item,r,c,false)
	elseif item.ItemType == GameItemType.kBoss then
		GameExtandPlayLogic:MaydayBossLoseBlood(mainLogic, r, c, true)
	elseif item.ItemType == GameItemType.kWeeklyBoss then
		GameExtandPlayLogic:WeeklyBossLoseBlood(mainLogic, r, c, true)
	elseif item.ItemType == GameItemType.kMoleBossCloud then
		MoleWeeklyRaceLogic:MoleBossCloudLoseBlood(mainLogic, r, c, true)
	elseif  item.honeyBottleLevel > 0 and item.honeyBottleLevel <= 3 then
		GameExtandPlayLogic:increaseHoneyBottle(mainLogic, r, c, t_count, scoreScale)
	elseif item.ItemType == GameItemType.kMagicStone and item:canMagicStoneBeActive() then
		GameExtandPlayLogic:onUpgradeMagicStone(mainLogic, item)
	elseif item.ItemType == GameItemType.kPuffer and item.pufferState == PufferState.kActivated and not hashoney then
		GameExtandPlayLogic:decreasePuffer(mainLogic, r, c , 1 , false)
	elseif item.ItemType == GameItemType.kOlympicBlocker and item.olympicBlockerLevel > 0 then
		GameExtandPlayLogic:decreaseOlympicBlocker(mainLogic, r, c)
	elseif item.ItemType == GameItemType.kMissile then
		GameExtandPlayLogic:hitMissile(mainLogic,item,r,c,false)
	elseif item.ItemType == GameItemType.kBuffBoom then
		GameExtandPlayLogic:decBuffBoom(mainLogic,item,r,c,false,count)
	elseif item.ItemType == GameItemType.kTangChicken then
		GameExtandPlayLogic:hitTangChicken(mainLogic,r,c)
	elseif item.ItemType == GameItemType.kBlocker199 then
		GameExtandPlayLogic:destroyBlocker199(mainLogic, r, c, t_count, 1)
	elseif item.ItemType == GameItemType.kBlocker207 
		and (item.ItemStatus == GameItemStatusType.kNone 
		or item.ItemStatus == GameItemStatusType.kItemHalfStable)
		and not hashoney
		then
		item:AddItemStatus(GameItemStatusType.kDestroy)
		mainLogic:addScoreToTotal(r, c, GamePlayConfigScore.MatchBySnow)
		local blockerAction = GameBoardActionDataSet:createAs(
			GameActionTargetType.kGameItemAction,
			GameItemActionType.kItemDeletedByMatch,
			IntCoord:create(r, c),
			nil,
			GamePlayConfig_GameItemAnimalDeleteAction_CD)
		mainLogic:addDestroyAction(blockerAction)
	elseif item.moleBossSeedHP > 0 then
		MoleWeeklyRaceLogic:breakSeed(mainLogic, r, c, t_count, scoreScale)
    elseif item.yellowDiamondLevel > 0 and item.yellowDiamondCanbeDelete == true  then
		item.yellowDiamondCanbeDelete = false
		GameExtandPlayLogic:decreaseYellowDiamond(mainLogic, r, c)
    elseif item.ItemType == GameItemType.kTurret then
		TurretLogic:updateTurretLevel(mainLogic, r, c, false)
	elseif item.sunFlaskLevel > 0 then
		SunflowerLogic:breakSunFlask(mainLogic, r, c, t_count, scoreScale)
    elseif item.ItemType == GameItemType.kWanSheng then
		WanShengLogic:increaseWanSheng(mainLogic, r, c, t_count, scoreScale)
	end
end
