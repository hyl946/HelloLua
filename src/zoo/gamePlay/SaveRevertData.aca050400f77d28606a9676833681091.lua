
SaveRevertData = class()

function SaveRevertData:ctor()
	self.gameItemMap = nil
	self.boardMap = nil
	self.totalScore = 0
	self.oringinTotalScore = 0
	self.theCurMoves = 0
end

function SaveRevertData:dispose()
	self.gameItemMap = nil
	self.boardMap = nil
end

function SaveRevertData:create(mainLogic , justCreate)
	local ret = SaveRevertData.new()

	local cloneGameItemMapForRevert = {}
	local cloneBoardMapForRevert = {}

	for r = 1, #mainLogic.gameItemMap do
		cloneGameItemMapForRevert[r] = {}
		for c = 1, #mainLogic.gameItemMap[r] do
			cloneGameItemMapForRevert[r][c] = mainLogic.gameItemMap[r][c]:copy()
		end
	end

	for r = 1, #mainLogic.boardmap do
		cloneBoardMapForRevert[r] = {}
		for c = 1, #mainLogic.boardmap[r] do
			cloneBoardMapForRevert[r][c] = mainLogic.boardmap[r][c]:copy()
		end
	end

	local cloneGameBackItemMapForRevert = {}
	if mainLogic.backItemMap then
		for r = 1, 9 do
			if mainLogic.backItemMap[r] then
				cloneGameBackItemMapForRevert[r] = {}
				for c = 1, 9 do
					if mainLogic.backItemMap[r][c] then
						cloneGameBackItemMapForRevert[r][c] = mainLogic.backItemMap[r][c]:copy()
					end
				end
			end
		end
	end
	
	local cloneBackBoardMapForRevert = {}
	if mainLogic.backBoardMap then
		for r = 1, 9 do
			if mainLogic.backBoardMap[r] then
				cloneBackBoardMapForRevert[r] = {}
				for c = 1, 9 do
					if mainLogic.backBoardMap[r][c] then
						cloneBackBoardMapForRevert[r][c] = mainLogic.backBoardMap[r][c]:copy()
					end
				end
			end
		end
	end

	ret.gameItemMap = cloneGameItemMapForRevert
	ret.boardmap = cloneBoardMapForRevert
	ret.backItemMap = cloneGameBackItemMapForRevert
	ret.backBoardMap = cloneBackBoardMapForRevert
	ret.totalScore = mainLogic.totalScore
	ret.oringinTotalScore = mainLogic.oringinTotalScore
	ret.theCurMoves = mainLogic.theCurMoves
	ret.bigMonsterMark = mainLogic.bigMonsterMark
	ret.chestSquareMark = mainLogic.chestSquareMark
	
	--[[
	ret.blockProductRules = {}
	for k, v in pairs(mainLogic.blockProductRules) do
		local tmpRule = {}
		tmpRule.id 				  = v.id
		tmpRule.blockProductType  = v.blockProductType
		tmpRule.itemID            = v.itemID
		tmpRule.blockMoveCount    = v.blockMoveCount 
		tmpRule.blockMoveTarget   = v.blockMoveTarget
		tmpRule.blockShouldCome   = v.blockShouldCome
		tmpRule.blockSpawnDensity = v.blockSpawnDensity
		tmpRule.blockSpawned      = v.blockSpawned
		tmpRule.needClearBlockSpawnedNextStep = v.needClearBlockSpawnedNextStep
		tmpRule.itemType          = v.itemType
		tmpRule.maxNum            = v.maxNum
		tmpRule.minNum            = v.minNum
		tmpRule.dropNumLimit      = v.dropNumLimit
		tmpRule.totalDroppedNum   = v.totalDroppedNum
		tmpRule.specialType = v.specialType
		tmpRule.otherInfo = v.otherInfo
		table.insert( ret.blockProductRules, tmpRule )
	end
	]]

	ret.productRuleGroup = {}
	for k, v in ipairs(mainLogic.productRuleGroup) do
		local tab = {}
		for k2, v2 in ipairs(v) do
			local tmpRule = {}
			tmpRule.id 				  = v2.id
			tmpRule.blockProductType  = v2.blockProductType
			tmpRule.itemID            = v2.itemID
			tmpRule.blockMoveCount    = v2.blockMoveCount 
			tmpRule.blockMoveTarget   = v2.blockMoveTarget
			tmpRule.blockShouldCome   = v2.blockShouldCome
			tmpRule.blockSpawnDensity = v2.blockSpawnDensity
			tmpRule.blockSpawned      = v2.blockSpawned
			tmpRule.needClearBlockSpawnedNextStep = v2.needClearBlockSpawnedNextStep
			tmpRule.itemType          = v2.itemType
			tmpRule.maxNum            = v2.maxNum
			tmpRule.minNum            = v2.minNum
			tmpRule.dropNumLimit      = v2.dropNumLimit
			tmpRule.totalDroppedNum   = v2.totalDroppedNum
			tmpRule.specialType = v2.specialType
			tmpRule.otherInfo = v2.otherInfo
			table.insert( tab , tmpRule )
		end
		table.insert( ret.productRuleGroup , tab )
	end

	local logicVer = mainLogic.logicVer

	-- printx( 1 , "logicVer ----------------------" , logicVer)

	if logicVer == 2 then
		ret.cachePoolV2 = table.clone( mainLogic.cachePoolV2 )
	else
		ret.cachePoolV2 = {}
		if mainLogic.cachePoolV2 then 
			for k1 , v1 in ipairs(mainLogic.cachePoolV2) do
				local tab = {}
				for k, v in pairs(v1) do
					tab[k] = {}
					for _k, _v in pairs(v) do 
						local itemData = _v:copy()
						table.insert(tab[k], itemData)
					end
				end
				table.insert(ret.cachePoolV2 , tab )
			end
		end
	end

	ret.pm25count = mainLogic.pm25count
	ret.snailCount = mainLogic.snailCount
	ret.snailMoveCount = mainLogic.snailMoveCount
	ret.questionMarkFirstBomb = mainLogic.questionMarkFirstBomb
	ret.UFOSleepCD = mainLogic.UFOSleepCD
	ret.oldUFOSleepCD = mainLogic.oldUFOSleepCD
	ret.blockerCoverMaterialTotalNum = mainLogic.blockerCoverMaterialTotalNum
	ret.blocker207DestroyNum = mainLogic.blocker207DestroyNum
	ret.realCostMoveWithoutBackProp = mainLogic.realCostMoveWithoutBackProp
	ret.staticLevelMoves = mainLogic.staticLevelMoves
	ret.lastCreateBuffBoomMoveSteps = mainLogic.lastCreateBuffBoomMoveSteps
	ret.pacmanGeneratedByStep = mainLogic.pacmanGeneratedByStep
	ret.pacmanGeneratedByBoardMin = mainLogic.pacmanGeneratedByBoardMin
	ret.ghostGeneratedByStep = mainLogic.ghostGeneratedByStep
	ret.ghostGeneratedByBoardMin = mainLogic.ghostGeneratedByBoardMin
	if mainLogic.blocker206Cfg then ret.blocker206Cfg = table.clone(mainLogic.blocker206Cfg) end
	ret.actCollectionNum = mainLogic.actCollectionNum

	ret.generatedScoreBuffBottle = mainLogic.generatedScoreBuffBottle or 0
	ret.destroyedScoreBuffBottle = mainLogic.destroyedScoreBuffBottle or 0
	if mainLogic.scoreBuffBottleLeftSpecialTypes then
		ret.scoreBuffBottleLeftSpecialTypes = table.clone(mainLogic.scoreBuffBottleLeftSpecialTypes)
	end
	-- ret.scoreBuffBottleInitAmount = mainLogic.scoreBuffBottleInitAmount	--为了replay，存储在replayData的ctx中
	ret.sunflowersAppetite = mainLogic.sunflowersAppetite
	ret.sunflowerEnergy = mainLogic.sunflowerEnergy
	ret.generateFirecrackerTimes = mainLogic.generateFirecrackerTimes
	ret.generateFirecrackerTimesForPreBuff = mainLogic.generateFirecrackerTimesForPreBuff

	ret.currRandomSeed = mainLogic.randFactory:getCurrHoldrand()
	ret.currPrePropRandomSeed = mainLogic.prePropRandFactory:getCurrHoldrand()
	ret.destroyLotusNum = mainLogic.destroyLotusNum
	ret.coinDestroyNum = mainLogic.coinDestroyNum

	ret.actCollDatas = ActCollectionLogic:getDataForRevert()
    ret.springFestival2019Data = SpringFestival2019Manager:getInstance():getDataForRevert()
    ret.TurnTable2019Data = TurnTable2019Manager:getInstance():getDataForRevert()

	--ret.lotusEliminationNum = mainLogic.lotusEliminationNum
	--ret.lotusPrevStepEliminationNum = mainLogic.lotusPrevStepEliminationNum

	ret.buffPassedPlanList = table.clone( GameInitBuffLogic:getInitBuffPassedPlanList() )
	ret.prePropsPassedPlanList = table.clone( GameInitBuffLogic:getPrePropsPassedPlanList() )
	local buffAnimeType , buffAnimeTypeParameter = GameInitBuffLogic:getAddBuffAnimeType()
	ret.buffAnimeType = buffAnimeType
	ret.buffAnimeTypeParameter = buffAnimeTypeParameter

	if not justCreate then
		mainLogic.gameMode:saveDataForRevert(ret)
	end

	ret.gamePlayCxt = GamePlayContext:getInstance():getRevertData()

	return ret
end

function SaveRevertData:setUsePropInfo( usePropInfo )
	self.usePropInfo = usePropInfo
end

function SaveRevertData:getUsePropInfo( ... )
	return self.usePropInfo
end

function SaveRevertData:addGiftInfo( giftInfo )
	if not self.giftInfos then
		self.giftInfos = {}
	end
	table.insert(self.giftInfos,giftInfo)
end
function SaveRevertData:getGiftInfos( ... )
	return self.giftInfos or {}
end


function SaveRevertData:getItemPos( key )
	if key > 0 then
		for r = 1, #self.gameItemMap do
			for c = 1, #self.gameItemMap[r] do
				if self.gameItemMap[r][c].key == key then
					return r,c
				end
			end
		end
	end
end