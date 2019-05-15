--------特效覆盖引起的各种逻辑----------

SpecialCoverLogic = class{}

-----在某个位置引起了特效消除-----减除冰层，减除牢笼，减除雪花等等效果
-- covertype : 1: 上下影响  2：左右影响  3：四周影响
-- noCD: 为false挖地、宝石一帧内多次调用会只调用一次， 为true会多次调用
function SpecialCoverLogic:SpecialCoverAtPos(mainLogic, r, c, covertype, scoreScale, actId, noCD, noScore, footprintType, SpecialSrcID )
	-----成功消除时候会影响周围的东西
	if SpecialCoverLogic:canEffectAround(mainLogic, r, c) then
		
		if covertype == 1 then
			SpecialCoverLogic:tryEffectSpecialAround(mainLogic, r, c, r - 1, c, noScore)		--上下
			SpecialCoverLogic:tryEffectSpecialAround(mainLogic, r, c, r + 1, c, noScore)
		elseif covertype == 2 then
			SpecialCoverLogic:tryEffectSpecialAround(mainLogic, r, c, r , c - 1, noScore)		--左右
			SpecialCoverLogic:tryEffectSpecialAround(mainLogic, r, c, r , c + 1, noScore)
		elseif covertype == 3 then
			SpecialCoverLogic:tryEffectSpecialAround(mainLogic, r, c, r - 1, c, noScore)		--四方
			SpecialCoverLogic:tryEffectSpecialAround(mainLogic, r, c, r + 1, c, noScore)
			SpecialCoverLogic:tryEffectSpecialAround(mainLogic, r, c, r , c - 1, noScore)
			SpecialCoverLogic:tryEffectSpecialAround(mainLogic, r, c, r , c + 1, noScore)
		end
	end
    local stopJamSpreadHelpMap = {}
	if SpecialCoverLogic:canBeEffectBySpecialAt(mainLogic, r, c) then
		SpecialCoverLogic:effectBlockerAt(mainLogic, r, c, scoreScale, actId, noCD, noScore, footprintType, SpecialSrcID, stopJamSpreadHelpMap)
	end
    SpecialCoverLogic:tryEffectByJamSperadSpecialAt(mainLogic, r, c, SpecialSrcID, stopJamSpreadHelpMap)
--    WanShengLogic:checkSpecialHitWanSheng(mainLogic, r, c, scoreScale)
end

function SpecialCoverLogic:specialCoverChainsAroundPos(mainLogic, r, c, dirs)
	dirs = dirs or {ChainDirConfig.kUp, ChainDirConfig.kDown, ChainDirConfig.kRight, ChainDirConfig.kLeft}
	SpecialCoverLogic:specialCoverChainsAtPos(mainLogic, r, c, dirs)
	for _, v in pairs(dirs) do
		if v == ChainDirConfig.kUp then
			SpecialCoverLogic:specialCoverChainsAtPos(mainLogic, r-1, c, {ChainDirConfig.kDown})
		elseif v == ChainDirConfig.kDown then
			SpecialCoverLogic:specialCoverChainsAtPos(mainLogic, r+1, c, {ChainDirConfig.kUp})
		elseif v == ChainDirConfig.kLeft then
			SpecialCoverLogic:specialCoverChainsAtPos(mainLogic, r, c-1, {ChainDirConfig.kRight})
		elseif v == ChainDirConfig.kRight then
			SpecialCoverLogic:specialCoverChainsAtPos(mainLogic, r, c+1, {ChainDirConfig.kLeft})
		end
	end
end

-- centerR, centerC, radius 区域特效使用
function SpecialCoverLogic:specialCoverChainsAtPos(mainLogic, r, c, breakDirs, isRemove)
	if not mainLogic:isPosValid(r, c) then
		return
	end
	breakDirs = breakDirs or {ChainDirConfig.kUp, ChainDirConfig.kDown, ChainDirConfig.kRight, ChainDirConfig.kLeft}

	local board = mainLogic.boardmap[r][c]
	-- local item = mainLogic.gameItemMap[r][c]
	local breakLevels = board:decChainsInDirections(breakDirs, isRemove)
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
	if not notEmpty then return end

	board.isNeedUpdate = true
	-- item.isNeedUpdate = true

	mainLogic.boardView.baseMap[r][c]:playChainBreakAnim(breakLevels, nil, isRemove)

	if hasChainBreaked then
		mainLogic:setChainBreaked()
		mainLogic.gameMode:checkDropDownCollect(r, c)
	end
	-- if _G.isLocalDevelopMode then printx(0, "breakLevels:", table.tostring(breakLevels)) end
end

--一般情况：消除小木桩/冰块/流沙/夹心饼干
function SpecialCoverLogic:SpecialCoverLightUpAtPos(mainLogic, r, c, scoreScale, canEffectCoin, SpecialSrcID)
	--小木桩
	if SpecialCoverLogic:canEffectblockerCoverMaterial(mainLogic, r, c) then
		SpecialCoverLogic:doEffectblockerCoverMaterial(mainLogic, r, c)
		return
	end
	--冰块
	if SpecialCoverLogic:canEffectLightUpAt(mainLogic, r, c, canEffectCoin) then
		SpecialCoverLogic:doEffectLightUpAtPos(mainLogic, r, c, scoreScale)
	end
	--流沙
	if SpecialCoverLogic:canEffectSandAtPos(mainLogic, r, c, false) then
		SpecialCoverLogic:doEffectSandAtPos(mainLogic, r, c)
	end

	if SpecialCoverLogic:canApplyMilkAt(mainLogic, r, c) then
		SpecialCoverLogic:doApplyMilkAt(mainLogic, r, c)
	end

	if SpecialSrcID then
		--鱿鱼兼容：鱿鱼会锁住格子
		SpecialCoverLogic:tryEffectByJamSperadSpecialAt(mainLogic, r, c, SpecialSrcID, {})
	end
end

--特殊情况：消除小木桩/冰块/流沙/夹心饼干
function SpecialCoverLogic:SpecialCoverLightUpAtBlocker(mainLogic, r, c, scoreScale, condition)
	if not mainLogic:isPosValid(r, c) then return false end

	--local item = mainLogic.gameItemMap[r][c]
	local board = mainLogic.boardmap[r][c]
	if condition then
		if board.blockerCoverMaterialLevel > 0 then
			SpecialCoverLogic:doEffectblockerCoverMaterial(mainLogic, r, c)
			return
		end
	
		if board.iceLevel > 0 then
			SpecialCoverLogic:doEffectLightUpAtPos(mainLogic, r, c, scoreScale)
		end
		if board.sandLevel > 0 then
			SpecialCoverLogic:doEffectSandAtPos(mainLogic, r, c)
		end

		if GameExtandPlayLogic:isEmptyBiscuit(mainLogic, r, c) then
			SpecialCoverLogic:doApplyMilkAt(mainLogic, r, c)
		end
	end
end

function SpecialCoverLogic:canEffectblockerCoverMaterial(mainLogic, r, c)
	if not mainLogic:isPosValid(r, c) then
		return false
	end

	local board = mainLogic.boardmap[r][c]
	local item = mainLogic.gameItemMap[r][c]

	if board and board.blockerCoverMaterialLevel > 0 and item and item:canEffectLightUp() and not item.isReverseSide then
		if item.ItemType == GameItemType.kCoin then 
			return false
		elseif item.ItemType == GameItemType.kPuffer then
			return false
		elseif item.ItemType == GameItemType.kTotems then
			return false
		else
			return true
		end
	end

	return false
end

function SpecialCoverLogic:doEffectblockerCoverMaterial(mainLogic, r, c)
	GameExtandPlayLogic:decreaseBlockerCoverMaterialLevelAt(mainLogic, r, c)
end

function SpecialCoverLogic:canEffectLightUpAt(mainLogic, r, c, canEffectCoin)
	if mainLogic.theGamePlayType ~= GameModeTypeId.LIGHT_UP_ID
		and mainLogic.theGamePlayType ~= GameModeTypeId.SEA_ORDER_ID
		and mainLogic.theGamePlayType ~= GameModeTypeId.OLYMPIC_HORIZONTAL_ENDLESS_ID then 
		return false
	end
	if not mainLogic:isPosValid(r, c) then
		return false
	end
	local board = mainLogic.boardmap[r][c];
	local item = mainLogic.gameItemMap[r][c]
	if board.iceLevel > 0 and board.blockerCoverMaterialLevel == 0 then
		if item and item:canEffectLightUp() then
			if item.ItemType == GameItemType.kCoin and not canEffectCoin then 
				return false
			elseif item.ItemType == GameItemType.kPuffer and item.pufferState == PufferState.kNormal then 
				return false
			elseif item.ItemType == GameItemType.kTotems then
				return false
			else
				return true
			end
		end
	end 
	return false
end

function SpecialCoverLogic:doEffectLightUpAtPos(mainLogic, r, c, scoreScale)
	if not mainLogic:isPosValid(r, c) then 
		return false 
	end

	local item = mainLogic.gameItemMap[r][c]
	local board = mainLogic.boardmap[r][c]

	scoreScale = scoreScale or 1
	if board.iceLevel > 0 then
		----1-2.分数统计
		local addScore = scoreScale * GamePlayConfigScore.MatchAtIce
		mainLogic:addScoreToTotal(r, c, addScore, nil, 2)
		
		GameExtandPlayLogic:decIceLevelAt(mainLogic, r, c)
	end
end


function SpecialCoverLogic:canApplyMilkAt(mainLogic, r, c)
	if not mainLogic:isPosValid(r, c) then return false end

	local item = mainLogic.gameItemMap[r][c]

	local boardmap = mainLogic.boardmap[r][c]
	local biscuitBoardData = GameExtandPlayLogic:findBiscuitBoardDataCoveredMe(mainLogic, r, c)
	if biscuitBoardData then
		if item.ItemType == GameItemType.kCoin then 
			return false
		elseif item.ItemType == GameItemType.kPuffer and item.pufferState == PufferState.kNormal then 
			return false
		elseif item.ItemType == GameItemType.kTotems then
			return false
		end
		local milkRow, milkCol = biscuitBoardData:convertToMilkRC(r, c)
		if item:canEffectLightUp() and biscuitBoardData:canApplyMilkAt(milkRow, milkCol) and boardmap.blockerCoverMaterialLevel == 0 then
			return true, biscuitBoardData, milkRow, milkCol
		end
	end

	return false

end

function SpecialCoverLogic:doApplyMilkAt(mainLogic, r, c, scoreScale)
	local biscuitBoardData = GameExtandPlayLogic:findBiscuitBoardDataCoveredMe(mainLogic, r, c)
	if biscuitBoardData then
		local milkRow, milkCol = biscuitBoardData:convertToMilkRC(r, c)
		GameExtandPlayLogic:applyMilkOnBiscuitAt(mainLogic, biscuitBoardData, milkRow, milkCol, r, c)
	end
end

function SpecialCoverLogic:canEffectSandAtPos(mainLogic, r, c, canEffectCoin)
	if not mainLogic:isPosValid(r, c) then
		return false
	end
	local board = mainLogic.boardmap[r][c];
	local item = mainLogic.gameItemMap[r][c]
	if board.sandLevel > 0 and board.blockerCoverMaterialLevel == 0 then
		if item and item:canEffectLightUp() then
			if item.ItemType == GameItemType.kCoin and not canEffectCoin then 
				return false
			elseif item.ItemType == GameItemType.kPuffer and item.pufferState == PufferState.kNormal then
				return false
			elseif item.ItemType == GameItemType.kTotems then
				return false
			else
				return true
			end
		end
	end 
	return false
end

--消除流沙
function SpecialCoverLogic:doEffectSandAtPos(mainLogic, r, c)
	if not mainLogic:isPosValid(r, c) then 
		return false 
	end

	local board = mainLogic.boardmap[r][c]
	if board.sandLevel > 0 then
		board.sandLevel = board.sandLevel - 1
		----1-3.播放特效
		local sandCleanAction = GameBoardActionDataSet:createAs(
			GameActionTargetType.kGameItemAction,
			GameItemActionType.kItem_Sand_Clean,
			IntCoord:create(r,c),				
			nil,				
			GamePlayConfig_MaxAction_time)
		mainLogic:addDestroyAction(sandCleanAction)
		mainLogic:tryDoOrderList(r, c, GameItemOrderType.kOthers, GameItemOrderType_Others.kSand, 1)
		ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_Sand, ObstacleFootprintAction.k_Eliminate, 1)

		local addScore = GamePlayConfigScore.SandClean
		mainLogic:addScoreToTotal(r, c, addScore, nil, 2)

		return true
	end
	return false
end

----可以被此处的Special影响到---
function SpecialCoverLogic:canBeEffectBySpecialAt(mainLogic, r, c)
	if not mainLogic:isPosValid(r, c) then return false end

	local item = mainLogic.gameItemMap[r][c];
	if item.isReverseSide then return false end
	if item:hasBlocker206() or item:hasSquidLock() then return false end
	local board = mainLogic.boardmap[r][c];
	if item:hasLock()
		or item.snowLevel > 0
		or item.venomLevel > 0
		or board.colorFilterBLevel > 0
		or item.blockerCoverLevel > 0
		or board.blockerCoverMaterialLevel > 0
		or board.lotusLevel > 0
		or item.ItemType == GameItemType.kRoost
		or item:hasFurball()
		or item:hasActiveSuperCuteBall()
		or item.digGroundLevel > 0
		or item.digJewelLevel > 0 
        or item.yellowDiamondLevel > 0 
		or item.bigMonsterFrostingStrength > 0
		or item.chestSquarePartStrength > 0
		or item.ItemType == GameItemType.kBlackCuteBall
		or item.ItemType == GameItemType.kMimosa 
		or item.ItemType == GameItemType.kKindMimosa
		or item.ItemType == GameItemType.kOlympicBlocker
		or item.beEffectByMimosa > 0
		or item.ItemType == GameItemType.kBoss
		or item.ItemType == GameItemType.kWeeklyBoss
		or item.ItemType == GameItemType.kMoleBossCloud
		or item.ItemType == GameItemType.kHoneyBottle
		or item.ItemType == GameItemType.kMagicLamp
		or item.ItemType == GameItemType.kWukong
		or item.ItemType == GameItemType.kBottleBlocker
		or item.ItemType == GameItemType.kMagicStone
		or item.ItemType == GameItemType.kCrystalStone
		or item.ItemType == GameItemType.kMissile
		or item.ItemType == GameItemType.kBuffBoom
		or item.ItemType == GameItemType.kRandomProp
		or (item.ItemType == GameItemType.kPuffer 
			and ( item.pufferState == PufferState.kNormal or item.pufferState == PufferState.kActivated ) )
		or item.ItemType == GameItemType.kTangChicken
		or item.ItemType == GameItemType.kBlocker199
		or item.ItemType == GameItemType.kBlocker207
        or item.ItemType == GameItemType.kTurret
		or item.ItemType == GameItemType.kMoleBossSeed
		or item:isFreeGhost()
		or item.ItemType == GameItemType.kScoreBuffBottle
		or item.ItemType == GameItemType.kSunFlask
		or item.ItemType == GameItemType.kFirecracker
        or item.ItemType == GameItemType.kWanSheng
		then
		return true
	end
	return false
end

function SpecialCoverLogic:tryEffectByJamSperadSpecialAt(mainLogic, r, c, SpecialSrcID, helpMap)
    if mainLogic.theGamePlayType ~= GameModeTypeId.JAMSPREAD_ID then
        return
    end

    if not mainLogic:isPosValid(r, c) then return false end

	local item = mainLogic.gameItemMap[r][c];
	local board = mainLogic.boardmap[r][c];

    if item.isReverseSide then return false end
	if item:hasBlocker206() or item:hasSquidLock() then return false end

    if board.isJamSperad == false then
        if not helpMap[r.."_"..c] and SpecialSrcID and mainLogic:checkSrcSpecialCoverListIsHaveJamSperad( SpecialSrcID ) then
             GameExtandPlayLogic:addJamSperadFlag(mainLogic, r, c )
        end
    end
    
end

----是否可以引起周围的消除----
function SpecialCoverLogic:canEffectAround(mainLogic, r, c)
	if mainLogic.gameItemMap[r] and mainLogic.gameItemMap[r][c] then
		if mainLogic.gameItemMap[r][c]:isColorful() 
			and not mainLogic.gameItemMap[r][c]:hasLock()
			and not mainLogic.gameItemMap[r][c]:hasFurball()
			and mainLogic.gameItemMap[r][c]:isAvailable()
			and mainLogic.gameItemMap[r][c].ItemType ~= GameItemType.kBottleBlocker

			then 
			return true
		end
	end
	return false
end

function SpecialCoverLogic:tryEffectSpecialAround(mainLogic, r, c, r1, c1, noScore)
	if r1 == 9 and c1 == 3 then
		local item = mainLogic.gameItemMap[r1][c1]
	end
	if not mainLogic:isPosValid(r1, c1) then 
		return end

	if SpecialCoverLogic:canBeEffectBySpecialCoverAnimalAround(mainLogic, r, c, r1, c1) then
		SpecialCoverLogic:effectBlockerAt(mainLogic, r1, c1, 1, nil, false, noScore)
	end
end

----可以被周围的SpecialCoverAnimal<特效消除小动物>影响到----
function SpecialCoverLogic:canBeEffectBySpecialCoverAnimalAround(mainLogic, r, c, r1, c1)
	if not mainLogic:isPosValid(r1, c1) then return false end

	local item = mainLogic.gameItemMap[r1][c1]
	local board = mainLogic.boardmap[r1][c1]

	if not item:isAvailable() then return false end

	if item 
		and (item.ItemType == GameItemType.kVenom 
		or item.ItemType == GameItemType.kDigGround
		or item.ItemType == GameItemType.kDigJewel
		or item.chestSquarePartType > 0
		or item.ItemType == GameItemType.kRandomProp)
		-- or item.honeyLevel > 0 
		then
		if mainLogic:hasChainInNeighbors(r, c, r1, c1) then -- 两者之间有冰柱
			return false
		end
		return true
	end
	return false
end

function SpecialCoverLogic:canEffectLotusAt(mainLogic, r, c)
	if not mainLogic:isPosValid(r, c) then
		return false
	end

	local board = mainLogic.boardmap[r][c]
	local item = mainLogic.gameItemMap[r][c]

	if item.isEmpty 
		or not item:isAvailable()
		or (item.ItemType == GameItemType.kPuffer and item.pufferState == PufferState.kNormal)
		or item.ItemType == GameItemType.kCoin 
		or item.ItemType == GameItemType.kCrystalStone 
		or item.ItemType == GameItemType.kVenom 
		or item.ItemType == GameItemType.kSnow 
		or item.ItemType == GameItemType.kBlackCuteBall
		or item.ItemType == GameItemType.kHoneyBottle
		or item.ItemType == GameItemType.kMissile
		or item.ItemType == GameItemType.kBuffBoom
		or item.ItemType == GameItemType.kBlocker195
		or item.ItemType == GameItemType.kBlocker207
		or item.ItemType == GameItemType.kMoleBossSeed
		or item.ItemType == GameItemType.kChameleon
		or item.ItemType == GameItemType.kPacman
		or item.honeyLevel > 0
		or item.cageLevel > 0
		or item.beEffectByMimosa > 0
		or item.furballLevel > 0
		or board.lotusLevel <= 0
		or board.isReverseSide
		or (board.lotusLevel == 1 and (board.blockerCoverMaterialLevel ~= 0 or item.ItemType == GameItemType.kBlocker199))
		or not item:canEffectLotus(board.lotusLevel) 
        or item.ItemType == GameItemType.kWanSheng
		then
		return false
	end 

	return true
end

function SpecialCoverLogic:canEffectPusfferAt(mainLogic, r, c)
	local board = mainLogic.boardmap[r][c]
	local item = mainLogic.gameItemMap[r][c]
	if item.isEmpty 
		or not item:isAvailable()
		or item.honeyLevel > 0
		or item.cageLevel > 0
		or item.beEffectByMimosa > 0
		or item.furballLevel > 0
		or board.isReverseSide
		then
		return false
	end
	return true
end

function SpecialCoverLogic:effectBlockerAt(mainLogic, r, c, scoreScale, actId, noCD, noScore, footprintType, SpecialSrcID, helpMap )
	if r<=0 or r>#mainLogic.boardmap or c<=0 or c>#mainLogic.boardmap[r] then return false end;

    if helpMap then
        helpMap[r.."_"..c] = true
    end

	local item = mainLogic.gameItemMap[r][c];
	local board = mainLogic.boardmap[r][c];
	scoreScale = scoreScale or 1

	if footprintType and not board.isReverseSide and not item:hasBlocker206() and not item:hasSquidLock() then
		ObstacleFootprintManager:addRecord(footprintType, ObstacleFootprintAction.k_HitTargets, 1)
	end

	if board.colorFilterBLevel > 0 and not board.isReverseSide and not item:hasBlocker206() and not item:hasSquidLock() then
		local color = AnimalTypeConfig.colorTypeList[board.colorFilterColor]
		mainLogic:addScoreToTotal(r, c, GamePlayConfigScore.MatchBySnow * scoreScale, color)
		ColorFilterLogic:dcreaseColorFilterB(r, c)
		return 
	end

	local hasLockOrigin = item:hasLock()
	-- if _G.isLocalDevelopMode then printx(0, "ttttttttttt",r,c,item.chestSquarePartType) end
	-- debug.debug()
	if not item:hasBlocker206() and not item:hasSquidLock() and board.superCuteState == GameItemSuperCuteBallState.kActive and not board.superCuteInHit then
		if item.ItemType == GameItemType.kBlocker195 then
			item.isBlocker195Lock = true
			mainLogic.needClearBlcoker195Data = true
		end
		board.superCuteInHit = true
		if not mainLogic.isInStep then
			board.superCuteAddInt = GamePlayConfig_SuperCute_InactiveRound_UseProp
		else
			board.superCuteAddInt = GamePlayConfig_SuperCute_InactiveRound_UseMove
		end
		
		local action = GameBoardActionDataSet:createAs(
                        GameActionTargetType.kGameItemAction,
                        GameItemActionType.kItem_SuperCute_Inactive,
                        IntCoord:create(r, c),
                        nil,
                        GamePlayConfig_MaxAction_time)
	    mainLogic:addDestroyAction(action)
		return
	end

	if item:isFreeGhost() then
		GhostLogic:addGhostPace(mainLogic, item, 1, true)
		return
	end

	if item.questionMarkProduct > 0 then  ------------从问号障碍生成，需要保护一段时间
		return 
	end

	local shouldLotusEffect = SpecialCoverLogic:canEffectLotusAt(mainLogic, r, c)
	local shouldPufferEffect = SpecialCoverLogic:canEffectPusfferAt(mainLogic, r, c)
	
	if item.blockerCoverLevel > 0 and not board.isReverseSide then
		GameExtandPlayLogic:decreaseBlockerCover(mainLogic, r, c)
		return
	
	elseif item.cageLevel > 0 then
		------1.牢笼变化------
		----1-1.数据变化
		item.cageLevel = item.cageLevel - 1

		-----1-2.分数变化
		if not noScore then
			local addScore = GamePlayConfigScore.MatchAtLock * scoreScale
			mainLogic:addScoreToTotal(r, c, addScore)
		end

		----1-3.播放特效
		local LockAction = GameBoardActionDataSet:createAs(
			GameActionTargetType.kGameItemAction,
			GameItemActionType.kItemMatchAt_LockDec,
			IntCoord:create(r,c),				
			nil,				
			GamePlayConfig_GameItemSnowDeleteAction_CD)
		mainLogic:addDestroyAction(LockAction)
		-- item.isNeedUpdate = true
		-- board.isNeedUpdate = true
	elseif item.ItemType == GameItemType.kBlocker199 and board.lotusLevel < 2 and item.honeyLevel <= 0 then
		GameExtandPlayLogic:hitBlocker199(mainLogic, r, c, 1)
	elseif item.honeyLevel > 0 then
		GameExtandPlayLogic:honeyDestroy( mainLogic, r, c, scoreScale )
	elseif item.olympicLockLevel > 0 then
		GameExtandPlayLogic:decreaseOlympicLock(mainLogic, r, c)
	end

	----2.检测雪花/毒液消除----
	if item.snowLevel > 0 then
		----1-1.数据变化
		item.snowLevel = item.snowLevel - 1
		if item.snowLevel == 0 then
			item:AddItemStatus(GameItemStatusType.kDestroy)
			SnailLogic:SpecialCoverSnailRoadAtPos( mainLogic, r, c )
			mainLogic:tryDoOrderList(r, c, GameItemOrderType.kSpecialTarget, GameItemOrderType_ST.kSnowFlower, 1) -------记录消除
		end

		if not noScore then
			----1-2.分数统计
			local addScore = scoreScale * GamePlayConfigScore.MatchBySnow
			mainLogic:addScoreToTotal(r, c, addScore)
		end

		local cd = GamePlayConfig_GameItemSnowDeleteAction_CD
				
		----1-3.播放特效
		local SnowAction = GameBoardActionDataSet:createAs(
			GameActionTargetType.kGameItemAction,
			GameItemActionType.kItemMatchAt_SnowDec,
			IntCoord:create(r,c),				
			nil,				
			cd)
		SnowAction.addInt = item.snowLevel + 1
		SnowAction.hitTimes = 1
		mainLogic:addDestroyAction(SnowAction)
	elseif item.venomLevel > 0 then
		item.venomLevel = item.venomLevel - 1
		SnailLogic:SpecialCoverSnailRoadAtPos( mainLogic, r, c )
		mainLogic:tryDoOrderList(r, c, GameItemOrderType.kSpecialTarget, GameItemOrderType_ST.kVenom, 1) -------记录消除

		if not noScore then
			local addScore = scoreScale * GamePlayConfigScore.MatchBySnow
			mainLogic:addScoreToTotal(r, c, addScore)
		end

		local VenomAction = GameBoardActionDataSet:createAs(
			GameActionTargetType.kGameItemAction,
			GameItemActionType.kItemMatchAt_VenowDec,
			IntCoord:create(r, c),
			nil,
			GamePlayConfig_GameItemBlockerDeleteAction_CD)
		mainLogic:addDestroyAction(VenomAction)
		mainLogic.gameItemMap[r][c]:AddItemStatus(GameItemStatusType.kDestroy)
	elseif item.ItemType == GameItemType.kRoost then
		GameExtandPlayLogic:onUpgradeRoost(mainLogic, item, 1, noScore)
	elseif item.digGroundLevel > 0 then
		if item.digBlockCanbeDelete then
			if not noCD then 
				item.digBlockCanbeDelete = false
			end
			GameExtandPlayLogic:decreaseDigGround(mainLogic, r, c,scoreScale, noScore)
		end
	elseif item.digJewelLevel > 0 then
		if item.digBlockCanbeDelete then
			if not noCD then 
				item.digBlockCanbeDelete = false
			end
			GameExtandPlayLogic:decreaseDigJewel(mainLogic, r, c, scoreScale, noScore)
		end
    elseif item.yellowDiamondLevel > 0 then
		if item.yellowDiamondCanbeDelete then
			if not noCD then 
				item.yellowDiamondCanbeDelete = false
			end
			GameExtandPlayLogic:decreaseYellowDiamond(mainLogic, r, c, scoreScale, noScore)
		end
	elseif item.randomPropLevel > 0 then
		if item.digBlockCanbeDelete then
			if not noCD then 
				item.digBlockCanbeDelete = false
			end
			GameExtandPlayLogic:hitRandomProp(mainLogic, r, c, scoreScale, noScore)
		end
	elseif item.ItemType == GameItemType.kBottleBlocker and item.bottleLevel > 0 and item:isAvailable() then
		--if item.bottleState == BottleBlockerState.Waiting then
			GameExtandPlayLogic:decreaseBottleBlocker(mainLogic, r, c , scoreScale , noScore)
		--end
	elseif item.bigMonsterFrostingType > 0 then 
		if not noScore then
			local addScore = scoreScale * GamePlayConfigScore.MatchBySnow
			mainLogic:addScoreToTotal(r, c, addScore)
		end

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
		GameExtandPlayLogic:hitChestSquare(mainLogic,item,r,c,noScore)
	elseif item.ItemType == GameItemType.kBlackCuteBall then
		GameExtandPlayLogic:onDecBlackCuteball(mainLogic, item, 1, 1, noScore)
	elseif item.ItemType == GameItemType.kMimosa or item.beEffectByMimosa == GameItemType.kMimosa then
		GameExtandPlayLogic:backMimosa( mainLogic, r, c )
	elseif item.ItemType == GameItemType.kKindMimosa or item.beEffectByMimosa == GameItemType.kKindMimosa then
		GameExtandPlayLogic:backMimosa( mainLogic, r, c )
	elseif item.ItemType == GameItemType.kBoss  then
		GameExtandPlayLogic:MaydayBossLoseBlood(mainLogic, r, c, false, actId)
	elseif item.ItemType == GameItemType.kWeeklyBoss then
		GameExtandPlayLogic:WeeklyBossLoseBlood(mainLogic, r, c, false, actId)
	elseif item.ItemType == GameItemType.kMoleBossCloud then
		MoleWeeklyRaceLogic:MoleBossCloudLoseBlood(mainLogic, r, c, false, actId)
	elseif item.honeyBottleLevel > 0 and item.honeyBottleLevel <= 3 then
		GameExtandPlayLogic:increaseHoneyBottle(mainLogic, r, c,1, scoreScale)
	elseif item.ItemType == GameItemType.kMagicLamp and item.lampLevel > 0 and not hasLockOrigin and not board.isJustEffectByFilter then
		GameExtandPlayLogic:onChargeMagicLamp(mainLogic, r, c, 1)
	elseif item.ItemType == GameItemType.kMissile then
		GameExtandPlayLogic:hitMissile(mainLogic,item,r,c,noScore)
	elseif item.ItemType == GameItemType.kBuffBoom then
		GameExtandPlayLogic:decBuffBoom(mainLogic,item,r,c,noScore)
	elseif item.ItemType == GameItemType.kWukong 
    		and item.wukongProgressCurr < item.wukongProgressTotal 
    		and ( item.wukongState == TileWukongState.kNormal or item.wukongState == TileWukongState.kOnHit )
    		and not hasLockOrigin and not mainLogic.isBonusTime then
		local action = GameBoardActionDataSet:createAs(
                    GameActionTargetType.kGameItemAction,
                    GameItemActionType.kItem_Wukong_Charging,
                    IntCoord:create(r, c),
                    nil,
                    GamePlayConfig_MaxAction_time
                )
		action.count = 3
	    mainLogic:addDestroyAction(action)

    elseif item.ItemType == GameItemType.kMagicStone and item:canMagicStoneBeActive() then
    	GameExtandPlayLogic:onUpgradeMagicStone(mainLogic, item)
	elseif item.ItemType == GameItemType.kCrystalStone and not hasLockOrigin then -- 水晶石没有被锁住
		if not item:isCrystalStoneActive() then -- 充满的水晶石被特效打到不会触发，被锤子砸时单独处理
			GameExtandPlayLogic:specialCoverInactiveCrystalStone(mainLogic, r, c, scoreScale)
		end
	elseif item.ItemType == GameItemType.kOlympicBlocker and not hasLockOrigin and item.olympicBlockerLevel > 0 then
		GameExtandPlayLogic:decreaseOlympicBlocker(mainLogic, r, c)
	elseif item.ItemType == GameItemType.kTangChicken then
		GameExtandPlayLogic:hitTangChicken(mainLogic, r, c)	
	elseif item.ItemType == GameItemType.kBlocker207 and (item.ItemStatus == GameItemStatusType.kNone 
		or item.ItemStatus == GameItemStatusType.kItemHalfStable) and not hasLockOrigin and item:isAvailable() then
		GameExtandPlayLogic:destroyBlocker207(mainLogic , r , c)
    elseif item.ItemType == GameItemType.kTurret then
		TurretLogic:updateTurretLevel(mainLogic, r, c, true)					
	elseif item.moleBossSeedHP > 0 then
		MoleWeeklyRaceLogic:breakSeed(mainLogic, r, c, 1, scoreScale)
	elseif item.ItemType == GameItemType.kScoreBuffBottle and item:isVisibleAndFree() and not hasLockOrigin then
		ScoreBuffBottleLogic:onScoreBuffBottleSimulated(item)
	elseif item.ItemType == GameItemType.kSunFlask and item.sunFlaskLevel > 0 then
		SunflowerLogic:breakSunFlask(mainLogic, r, c, 1, scoreScale)
	elseif item.ItemType == GameItemType.kFirecracker and item:isVisibleAndFree() and not hasLockOrigin then
	  	FirecrackerLogic:onFirecrackerSimulated(item)
    elseif item.wanShengLevel > 0 and item.wanShengLevel <= 3 then
        WanShengLogic:increaseWanSheng(mainLogic, r, c, 1, scoreScale)
	end
	
	--毛球
	if item:hasFurball() and item.blockerCoverLevel == 0 and board.colorFilterBLevel == 0 then
		if item.furballType == GameItemFurballType.kGrey then
			item.furballLevel = 0
			item.furballType = GameItemFurballType.kNone
			item.furballDeleting = true

			local scoreAdd = GamePlayConfigScore.Furball * scoreScale
			mainLogic:addScoreToTotal(r, c, scoreAdd)

			local FurballAction = GameBoardActionDataSet:createAs(
				GameActionTargetType.kGameItemAction,
				GameItemActionType.kItem_Furball_Grey_Destroy,
				IntCoord:create(r, c),
				nil,
				GamePlayConfig_GameItemGreyFurballDeleteAction_CD)
			mainLogic:addDestroyAction(FurballAction)
			mainLogic:tryDoOrderList(r, c, GameItemOrderType.kSpecialTarget, GameItemOrderType_ST.kGreyCuteBall, 1)
		elseif item.furballType == GameItemFurballType.kBrown then
			if not item.isBrownFurballUnstable then
				item.isBrownFurballUnstable = true
				local FurballAction = GameBoardActionDataSet:createAs(
					GameActionTargetType.kGameItemAction,
					GameItemActionType.kItem_Furball_Brown_Unstable,
					IntCoord:create(r, c),
					nil,
					1)
				mainLogic:addGameAction(FurballAction)	

				local scoreAdd = GamePlayConfigScore.Furball * scoreScale
				mainLogic:addScoreToTotal(r, c, scoreAdd)
				
				mainLogic:tryDoOrderList(r, c, GameItemOrderType.kSpecialTarget, GameItemOrderType_ST.kBrownCuteBall, 1)
			end
		end
	end

	if shouldLotusEffect then
		GameExtandPlayLogic:decreaseLotus(mainLogic, r, c , 1 , false)
	end

	if shouldPufferEffect then
		GameExtandPlayLogic:decreasePuffer(mainLogic, r, c , 1 , false)
	end

    if helpMap then
        helpMap[r.."_"..c] = false
    end


end