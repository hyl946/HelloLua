SquidLogic = class{}

------------------------------------------- Charge --------------------------------------------
function SquidLogic:squidCanCollectTarget(squid, targetType)
	if squid and squid.ItemType == GameItemType.kSquid then
		if  squid.squidTargetNeeded > 0 and 
			squid.squidTargetCount < squid.squidTargetNeeded and 
			targetType == squid.squidTargetType 
			then
			return true
		end
	end
	return false
end

function SquidLogic:initSquidOnBoard(mainLogic)
	local squidOnBoard = {}
	for r = 1, #mainLogic.gameItemMap do
		for c = 1, #mainLogic.gameItemMap[r] do
			local item = mainLogic.gameItemMap[r][c]
			if item and item.ItemType == GameItemType.kSquid then
				table.insert(squidOnBoard, item)
			end
		end
	end
	mainLogic.squidOnBoard = squidOnBoard
end

function SquidLogic:checkSquidCollectItem(mainLogic, fromRow, fromCol, targetType)
	-- printx(11, "check squid collect. row, col, targetType: ", fromRow, fromCol, targetType)
	if mainLogic.squidOnBoard == nil then
		-- printx(11, "= = = init squidOnBoard")
		SquidLogic:initSquidOnBoard(mainLogic)
	end
	-----------------
	-- squidOnBoard更新时机：1、消除一只 2、移动位置 3、用过回退
	-----------------
	-- printx(11, "squidOnBoard amount:", #mainLogic.squidOnBoard)
	if mainLogic.squidOnBoard and #mainLogic.squidOnBoard > 0 then
		for _, squid in pairs(mainLogic.squidOnBoard) do
			-- printx(11, "squid currAmount: ", squid.squidTargetCount)
			if squid:isVisibleAndFree() and SquidLogic:squidCanCollectTarget(squid, targetType) then
				local fromPos = IntCoord:create(fromCol, fromRow)
				SquidLogic:squidCollectItem(mainLogic, fromPos, squid, 1)

				local actionType = ObstacleFootprintAction.k_Charge.."_"..ObstacleFootprintManager:getSquidTargetSuffix(targetType)
				ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_Squid, actionType, 1)
			end
		end
	end
end

function SquidLogic:squidCollectItem(mainLogic, fromPos, targetSquid, addAmount)
	-- 提前把数据加上，收不了的就不要飞了
	targetSquid.squidTargetCount = targetSquid.squidTargetCount + addAmount

	local action = GameBoardActionDataSet:createAs(
			GameActionTargetType.kGameItemAction,
			GameItemActionType.kItem_Squid_Collect,
			fromPos,
			nil,				
			GamePlayConfig_MaxAction_time)
	action.targetSquid = targetSquid
	action.newTargetAmount = targetSquid.squidTargetCount
	mainLogic:addDestroyAction(action)
	-- mainLogic:addGlobalCoreAction(action)
	-- mainLogic:addDestructionPlanAction(theAction)
end

function SquidLogic:checkHammerHitSquid(mainLogic, targetItem)
	if targetItem then
		if targetItem.ItemType == GameItemType.kSquid then
			SquidLogic:squidCollectItem(mainLogic, nil, targetItem, 3)
		elseif targetItem.ItemType == GameItemType.kSquidEmpty then
			local targetSquid = SquidLogic:getSquidBySquidHead(mainLogic, targetItem)
			if targetSquid then
				SquidLogic:squidCollectItem(mainLogic, nil, targetSquid, 3)
			end
		end
	end
end

function SquidLogic:getSquidBySquidHead(mainLogic, headItem)
	local headR, headC = headItem.y, headItem.x

	--- 上右下左
	local aroundX = {0, 1, 0, -1}
	local aroundY = {-1, 0, 1, 0}
	local squidDirectionOfHeadDir = {3, 4, 1, 2}	--上述坐标对应的鱿鱼方向（从脑袋顶来看是逆向）

	for i = 1, 4 do
		local currCol = headC + aroundX[i]
		local currRow = headR + aroundY[i]
		if mainLogic.gameItemMap[currRow] and mainLogic.gameItemMap[currRow][currCol] then
			local item = mainLogic.gameItemMap[currRow][currCol]
			if item and item.ItemType == GameItemType.kSquid then
				if item.squidDirection == squidDirectionOfHeadDir[i] then
					return item
				end
			end
		end
	end

	return nil
end

------------------------------------------- Run --------------------------------------------
function SquidLogic:squidIsFull(mainLogic, item)
	if item.squidTargetCount >= item.squidTargetNeeded then
		return true
	end
	return false
end

function SquidLogic:isReadyToRunSquid(mainLogic, item)
	if item and item.ItemType == GameItemType.kSquid then
		if SquidLogic:squidIsFull(mainLogic, item) 
			and item:isVisibleAndFree()
			then
			return true
		end
	end
	return false
end

function SquidLogic:pickAllFullSquid(mainLogic)
	local allFullSquid = {}
	for r = 1, #mainLogic.gameItemMap do
		for c = 1, #mainLogic.gameItemMap[r] do
			local item = mainLogic.gameItemMap[r][c]
            if SquidLogic:isReadyToRunSquid(mainLogic, item) then
            	table.insert(allFullSquid, item)
            end
		end
	end
	return allFullSquid
end

function SquidLogic:getDirectionAddVal(squid)
	if squid.squidDirection == 2 then
		return 1, 0
	elseif squid.squidDirection == 3 then
		return 0, 1
	elseif squid.squidDirection == 4 then
		return -1, 0
	end
	return 0, -1
end

function SquidLogic:getSquidRunGrids(mainLogic, squid)
	local targetGrids = {}

	local squidCol, squidRow = squid.x, squid.y
	local directionAddC, directionAddR = self:getDirectionAddVal(squid)
	-- printx(11, "squidCol, squidRow", squidCol, squidRow)
	-- printx(11, "directionAddC, directionAddR", directionAddC, directionAddR)

	local nextCol, nextRow = squidCol + directionAddC, squidRow + directionAddR
	-- 先把自己的头部扔进去……
	local headGrid = {r = nextRow, c = nextCol}
	table.insert(targetGrids, headGrid)

	local hitEnd = false
	while not hitEnd do
		nextCol, nextRow = nextCol + directionAddC, nextRow + directionAddR
		-- printx(11, "nextCol, nextRow", nextCol, nextRow)
		if SquidLogic:isInvalidGridForSquid(mainLogic, nextRow, nextCol) then
			-- printx(11, "invalid")
			hitEnd = true
		else
			-- printx(11, "valid")
			local targetGrid = {r = nextRow, c = nextCol}
			table.insert(targetGrids, targetGrid)
		end
	end

	return targetGrids
end

function SquidLogic:isInvalidGridForSquid(mainLogic, row, col)
	if mainLogic.gameItemMap[row] and mainLogic.gameItemMap[row][col] then
		local targetItem = mainLogic.gameItemMap[row][col]
		local targetBoard
		if mainLogic.boardmap[row] and mainLogic.boardmap[row][col] then
			targetBoard = mainLogic.boardmap[row][col]
		end

		if not self:isInvalidTargetForSquid(mainLogic, targetItem, targetBoard) then
			return false
		else
			return true
		end
	else
		return true
	end
end

function SquidLogic:isInvalidTargetForSquid(mainLogic, targetItem, targetBoard)
	if not targetItem.isUsed
		or targetItem.ItemType == GameItemType.kSquid 
		or targetItem.ItemType == GameItemType.kSquidEmpty
		or targetItem.ItemType == GameItemType.kSuperBlocker 
		or targetItem:hasBlocker206()
		-- or targetItem:hasSquidLock() --squidLock是动画里的中间状态，这里应该不会出现这种锁
		then
		return true
	end

	if targetBoard then 	--判一下空吧

	end

	return false
end

function SquidLogic:removeSquidDataOfGrid(mainLogic, targetItem)
	targetItem.ItemType = GameItemType.kNone

	targetItem.squidDirection = 0
	targetItem.squidTargetType = 0
    targetItem.squidTargetNeeded = -1
    targetItem.squidTargetCount = 0

	targetItem.isEmpty = true
	targetItem.isBlock = false
	targetItem.isNeedUpdate = true

	mainLogic:checkItemBlock(targetItem.y, targetItem.x)
	mainLogic.squidOnBoard = nil	-- 重新从棋盘获取一遍鱿鱼数据

	SnailLogic:SpecialCoverSnailRoadAtPos(mainLogic, targetItem.y, targetItem.x)
end

------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
--									令人头疼的各种消除逻辑，由此开始
------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------
function SquidLogic:onSquidBombGrid(mainLogic, theAction)
	local targetItem, squidDirection = theAction.targetItem, theAction.squidDirection

	if not targetItem then return end

	targetItem:reduceSquidLockValue()
	if targetItem:hasSquidLock() then return end --被复数条鱿鱼锁住，没解锁完

	local r, c = targetItem.y, targetItem.x
	local targetItemType = targetItem.ItemType
	local targetItemView
	if mainLogic.boardView.baseMap[r] and mainLogic.boardView.baseMap[r][c] then
		targetItemView = mainLogic.boardView.baseMap[r][c]
	end
	local targetBoard
	if mainLogic.boardmap[r] and mainLogic.boardmap[r][c] then
		targetBoard = mainLogic.boardmap[r][c]
	end

	-- printx(11, "Deal with targetItem, itemType:", targetItemType)

	-- 处理覆盖物
	SquidLogic:dealWithCovers(mainLogic, targetItem, targetItemView, targetBoard)

	-- 因为锁层级会和底下之物一并处理，不会阻挡效果，所以先处理完锁之后处理底下之物
	SquidLogic:dealWithLocks(mainLogic, targetItem, targetItemView)

	if targetItem:isVisibleAndFree() then
		-- printx(11, "targetItem, isVisibleAndFree")
		local isJustRemoveTarget = false
		local forbidNeedUpdate = false

		if SquidLogic:isCommonBombItem(targetItem) then
			BombItemLogic:tryCoverByBomb(mainLogic, r, c, true, 1)
			SpecialCoverLogic:SpecialCoverAtPos(mainLogic, r, c, 3, 1)
			mainLogic:checkItemBlock(r, c)	--虽然解开了鱿鱼锁，但是要是不先checkBlock，isBlock的状态会屏蔽一些地表层的消除检测
			SpecialCoverLogic:SpecialCoverLightUpAtPos(mainLogic, r, c, 1, nil, theAction.SpecialID)
		elseif SquidLogic:isJustRemoveItem(targetItem) then
			isJustRemoveTarget = true
		else
			if targetItem.snowLevel > 0 then
				SquidLogic:squidRemoveSnow(mainLogic, targetItem)
			elseif targetItemType == GameItemType.kHoneyBottle then
				if targetItem.honeyBottleLevel > 0 and targetItem.honeyBottleLevel <= 3  then
					GameExtandPlayLogic:increaseHoneyBottle(mainLogic, r, c, 3, 1)
				end
			elseif targetItemType == GameItemType.kBottleBlocker then
				GameExtandPlayLogic:decreaseBottleBlocker(mainLogic, r, c , 1 , false, true)
			elseif targetItemType == GameItemType.kPuffer then
				if targetItem.pufferState ~= PufferState.kActivated then
					targetItem.pufferState = PufferState.kActivated
					if targetItemView then
						targetItemView:changePufferState({pufferState = PufferState.kActivated})
					end
				end
				GameExtandPlayLogic:decreasePuffer(mainLogic, r, c)
			elseif targetItemType == GameItemType.kPacman then
				local maxDevourAmount = (mainLogic.pacmanConfig and mainLogic.pacmanConfig.devourCount) or 1
				targetItem.pacmanDevourAmount = maxDevourAmount
				targetItem.pacmanIsSuper = 2
			elseif targetItemType == GameItemType.kSunFlask then
				SunflowerLogic:breakSunFlask(mainLogic, r, c, targetItem.sunFlaskLevel, 1)
				forbidNeedUpdate = true	--会影响动画
			elseif targetItemType == GameItemType.kMissile then
				GameExtandPlayLogic:hitMissile(mainLogic, targetItem, r, c, false, true)
			elseif targetItemType == GameItemType.kMagicLamp then
				targetItem.needRemoveEventuallyBySquid = true
				GameExtandPlayLogic:onChargeMagicLamp(mainLogic, r, c, 4)
			elseif targetItem:isBlocker199Active() then
				if targetItem._encrypt.ItemColorType ~= 0 then
					targetItem.needRemoveEventuallyBySquid = true
					GameExtandPlayLogic:matchBlocker199(mainLogic, r, c, 1)
				else
					isJustRemoveTarget = true
				end
			elseif targetItem.ItemType == GameItemType.kSunflower then
				SquidLogic:squidHitSunflower(mainLogic, targetItemView)
			elseif targetItem.ItemType == GameItemType.kBlocker211 then
				if targetItem:canDoBlocker211Collect(0, true) then
					targetItem.needRemoveEventuallyBySquid = true
					GameExtandPlayLogic:doABlocker211Collect(mainLogic, nil, nil, r, c, 0, true, targetItem.subtype)
				else
					-- 置灰冷却时间内，无法触发大招，直接消除
					isJustRemoveTarget = true
				end
			elseif targetItem.ItemType == GameItemType.kTurret then
				isJustRemoveTarget = SquidLogic:dealWithTurretRemove(mainLogic, targetItem)
			elseif targetItem.ItemType == GameItemType.kBlackCuteBall then
				GameExtandPlayLogic:onDecBlackCuteball(mainLogic, targetItem, targetItem.blackCuteStrength)
			elseif targetItem.ItemType == GameItemType.kTotems then
				GameExtandPlayLogic:changeTotemsToWattingActive(mainLogic, r, c, 1, true)
			elseif targetItem.ItemType == GameItemType.kCrystalStone then
				GameExtandPlayLogic:specialCoverInactiveCrystalStone(mainLogic, r, c, 1, true)
			elseif targetItem.ItemType == GameItemType.kBlocker195 then
				GameExtandPlayLogic:doABlocker195Collect(mainLogic, targetItem, nil, nil, r, c, nil, 0, false, true)
				forbidNeedUpdate = true
			elseif targetItem.ItemType == GameItemType.kRoost then
				targetItem.needRemoveEventuallyBySquid = true
				GameExtandPlayLogic:onUpgradeRoost(mainLogic, targetItem, 3)
			elseif targetItem.ItemType == GameItemType.kMagicStone then
				if targetItem:canMagicStoneBeActive() then
					targetItem.needRemoveEventuallyBySquid = true
					GameExtandPlayLogic:onUpgradeMagicStone(mainLogic, targetItem, true)
				else
					isJustRemoveTarget = true
				end
			elseif targetItem.ItemType == GameItemType.kKindMimosa then
				if #targetItem.mimosaHoldGrid == 0 then
					isJustRemoveTarget = true
				else
					SquidLogic:onSquidHitKindMimosa(mainLogic, targetItem)
				end
			elseif targetItem.ItemType == GameItemType.kWanSheng then
                WanShengLogic:increaseWanSheng(mainLogic, r, c, 3, 1)
			end
		end

		if isJustRemoveTarget then
			if theAction.SpecialID then
				--强制消除，涂上果酱
				GameExtandPlayLogic:addJamSperadFlag(mainLogic, r, c, true )
			end

			SquidLogic:squidRemoveItemData(mainLogic, targetItem)
			--view
			if targetItemView then
				local spriteLayer
				if targetItemType == GameItemType.kPacmansDen then
					targetItemView:squidDestroyPacmansDenAnimation()	--小窝在Batch层，特殊处理下
				elseif targetItemType == GameItemType.kBlocker199 then
					targetItemView:removeBlocker199View()				--水母外边的圈需要特殊处理，不然消失会滞后……
				else
					targetItemView:squidCommonDestroyItemAnimation(spriteLayer)
				end
				-- targetItemView:playCommonVanishAnimation()
				-- forbidNeedUpdate = true
			end
		end

		if not forbidNeedUpdate then
			targetItem.isNeedUpdate = true
		end
		mainLogic:checkItemBlock(r, c)
	end

	SnailLogic:SpecialCoverSnailRoadAtPos(mainLogic, r, c)
	-- 根据章鱼方向处理绳子和冰柱
	SquidLogic:squidRemoveChainAndRope(mainLogic, squidDirection, r, c, targetItemView)

end

--------------------------------- 类型分类 -----------------------------------
-- 普通的，消除掉就好了的对象，没有什么特殊处理
function SquidLogic:isCommonBombItem(targetItem)
	-- printx(11, "squid bomb, isCommonBombItem:", targetItem.ItemType)
	if targetItem.ItemType == GameItemType.kAnimal 
		or targetItem.ItemType == GameItemType.kCrystal 
		or targetItem.ItemType == GameItemType.kNewGift 
		or targetItem.ItemType == GameItemType.kBalloon 
		then
		return true
	end

	-- 按文档里面分着来写好找，没有任何其他深意_(:3 」∠)_
	if targetItem.ItemType == GameItemType.kVenom 
		or targetItem.ItemType == GameItemType.kCoin 
		or targetItem.ItemType == GameItemType.kBlocker207 
		or targetItem.ItemType == GameItemType.kScoreBuffBottle 
		or targetItem.ItemType == GameItemType.kFirecracker
		or targetItem.ItemType == GameItemType.kBigMonster
		or targetItem.ItemType == GameItemType.kBigMonsterFrosting
		or targetItem.ItemType == GameItemType.kBlocker207
		then
		return true
	end
	-- printx(11, "Nah-nah")
	return false
end

-- 简单粗暴，删你数据，灭你视图
function SquidLogic:isJustRemoveItem(targetItem)
	-- printx(11, "squid bomb, isJustRemoveItem:", targetItem.ItemType)
	if targetItem.ItemType == GameItemType.kChameleon 
		or (targetItem.ItemType == GameItemType.kBlocker199 and not targetItem:isBlocker199Active())
		or targetItem.ItemType == GameItemType.kPacmansDen 
		or targetItem.ItemType == GameItemType.kPoisonBottle 
		then
		return true
	end
	-- printx(11, "Nah-nah")
	return false
end

--------------------------------- 各类型删除逻辑 -----------------------------------
-- 通用数据删除
function SquidLogic:squidRemoveItemData(mainLogic, targetItem)
	if targetItem.ItemType == GameItemType.kChameleon then
		ChameleonLogic:onChameleonDemolished(mainLogic, targetItem)
	end

	targetItem:cleanAnimalLikeData()
end

-- 根据章鱼方向处理绳子和冰柱
function SquidLogic:squidRemoveChainAndRope(mainLogic, squidDirection, r, c, targetItemView)
	local boardData
	if mainLogic.boardmap[r] and mainLogic.boardmap[r][c] then
		boardData = mainLogic.boardmap[r][c]
	end
	if squidDirection == 1 or squidDirection == 3 then
		SpecialCoverLogic:specialCoverChainsAtPos(mainLogic, r, c, {ChainDirConfig.kUp}, true)
		SpecialCoverLogic:specialCoverChainsAtPos(mainLogic, r, c, {ChainDirConfig.kDown}, true)
		if boardData then
			boardData:removeRopeOfDirection(1)
			boardData:removeRopeOfDirection(3)
		end
	else
		SpecialCoverLogic:specialCoverChainsAtPos(mainLogic, r, c, {ChainDirConfig.kRight}, true)
		SpecialCoverLogic:specialCoverChainsAtPos(mainLogic, r, c, {ChainDirConfig.kLeft}, true)
		if boardData then
			boardData:removeRopeOfDirection(2)
			boardData:removeRopeOfDirection(4)
		end
	end

	if targetItemView then
		targetItemView:refreshRopeView(boardData)
	end
end

-- 处理覆盖物层级
-- 因为之后要同时处理下面的被覆盖物，所以一律难以走原来的action逻辑，只能单独处理
-- ！！！=== 请注意覆盖物之间的覆盖关系，优先处理最外层的 ===！！！
function SquidLogic:dealWithCovers(mainLogic, targetItem, targetItemView, targetBoard)
	local r, c = targetItem.y, targetItem.x

	if targetItem.blockerCoverLevel > 0 then
		SquidLogic:removeLeafPile(mainLogic, targetItem, targetItemView, targetBoard)
	end

	if targetBoard then
		if targetBoard.colorFilterBLevel > 0 then
			SquidLogic:removeColourFilter(mainLogic, targetItem, targetItemView, targetBoard)
		end

		if targetBoard.lotusLevel > 1 then
			-- 二、三级荷塘，先消除他们，以便之后在流程中再处理被覆盖物
			SquidLogic:removeThickLotus(mainLogic, targetItem, targetItemView, targetBoard)
		end

		if targetBoard.superCuteState == GameItemSuperCuteBallState.kActive then
			SquidLogic:disactiveSuperCuteball(mainLogic, targetItem, targetItemView, targetBoard)
		end
	end

	if targetItem:isFreeGhost() then
		GhostLogic:addGhostPace(mainLogic, targetItem, 9)
	end

end

-- 处理锁层级
function SquidLogic:dealWithLocks(mainLogic, targetItem, targetItemView)
	local r, c = targetItem.y, targetItem.x

	if targetItem.cageLevel > 0 then
		targetItem.cageLevel = 0
		mainLogic:addScoreToTotal(r, c, GamePlayConfigScore.MatchAtLock)

		local LockAction = GameBoardActionDataSet:createAs(
			GameActionTargetType.kGameItemAction,
			GameItemActionType.kItemMatchAt_LockDec,
			IntCoord:create(r,c),				
			nil,				
			GamePlayConfig_GameItemSnowDeleteAction_CD)
		mainLogic:addDestroyAction(LockAction)

	elseif targetItem.honeyLevel > 0 then
		-- GameExtandPlayLogic:honeyDestroy(mainLogic, r, c, scoreScale)	-- 通用逻辑要置位item.digBlockCanbeDelete，影响后续逻辑，比较麻烦
		targetItem.honeyLevel = 0

		mainLogic:tryDoOrderList(r, c, GameItemOrderType.kOthers, GameItemOrderType_Others.kHoney, 1)
		ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_Honey, ObstacleFootprintAction.k_Eliminate, 1)
		GameExtandPlayLogic:doAllBlocker195Collect(mainLogic, r, c, Blocker195CollectType.kHoney)
		SquidLogic:checkSquidCollectItem(mainLogic, r, c, TileConst.kHoney)

		if targetItemView then targetItemView:playHoneyDec(1) end
	elseif targetItem.furballLevel > 0  then
		-- printx(11, "= = =          deal with furball")
		local origFurballType = targetItem.furballType
		targetItem.furballLevel = 0
		targetItem.furballType = GameItemFurballType.kNone

		local addScore = GamePlayConfigScore.Furball
		mainLogic:addScoreToTotal(r, c, addScore)

		if origFurballType == GameItemFurballType.kGrey then
			local FurballAction = GameBoardActionDataSet:createAs(
				GameActionTargetType.kGameItemAction,
				GameItemActionType.kItem_Furball_Grey_Destroy,
				IntCoord:create(r, c),
				nil,
				GamePlayConfig_GameItemGreyFurballDeleteAction_CD)
			mainLogic:addDestroyAction(FurballAction)

			mainLogic:tryDoOrderList(r, c, GameItemOrderType.kSpecialTarget, GameItemOrderType_ST.kGreyCuteBall, 1)
			ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_GreyFurball, ObstacleFootprintAction.k_Eliminate, 1)
		elseif origFurballType == GameItemFurballType.kBrown then
			targetItem.isBrownFurballUnstable = false

			GameExtandPlayLogic:doAllBlocker195Collect(mainLogic, r, c, Blocker195CollectType.kBrownCute)
			SquidLogic:checkSquidCollectItem(mainLogic, r, c, TileConst.kBrownCute)
			mainLogic:tryDoOrderList(r, c, GameItemOrderType.kSpecialTarget, GameItemOrderType_ST.kBrownCuteBall, 1)

			if targetItemView then 
				targetItemView:squidCommonDestroyItemAnimation(ItemSpriteType.kFurBall)
			end
		end
	elseif targetItem.beEffectByMimosa == GameItemType.kKindMimosa then
		SquidLogic:onSquidHitKindMimosa(mainLogic, targetItem)
	elseif targetItem.ItemType == GameItemType.kDigGround or targetItem.ItemType == GameItemType.kDigJewel then
		BombItemLogic:forceClearItemWithCover(mainLogic, r, c)
	end
end

-- 雪块
function SquidLogic:squidRemoveSnow(mainLogic, targetItem)
	local decreaseLevels = targetItem.snowLevel
	local r, c = targetItem.y, targetItem.x

	targetItem.snowLevel = 0
	SnailLogic:SpecialCoverSnailRoadAtPos(mainLogic, r, c)
	targetItem:AddItemStatus(GameItemStatusType.kDestroy)
	mainLogic:tryDoOrderList(r, c, GameItemOrderType.kSpecialTarget, GameItemOrderType_ST.kSnowFlower, 1) -------记录消除
	-- 分数统计
	mainLogic:addScoreToTotal(r, c, GamePlayConfigScore.MatchBySnow * decreaseLevels)

	-- 播放特效
	local SnowAction = GameBoardActionDataSet:createAs(
		GameActionTargetType.kGameItemAction,
		GameItemActionType.kItemMatchAt_SnowDec,
		IntCoord:create(r,c),				
		nil,				
		GamePlayConfig_GameItemSnowDeleteAction_CD)
	SnowAction.addInt = 1
	SnowAction.hitTimes = decreaseLevels
	mainLogic:addDestroyAction(SnowAction)
end

function SquidLogic:squidHitSunflower(mainLogic, sunflowerView)
	if mainLogic and mainLogic.sunflowersAppetite and mainLogic.sunflowersAppetite > 0 then
		mainLogic.sunflowerEnergy = mainLogic.sunflowersAppetite

		if sunflowerView then
			sunflowerView:playSunflowerAbsorbSun(nil, nil, 0)
		end
	end
end

-- 消除二、三级荷塘
function SquidLogic:removeThickLotus(mainLogic, targetItem, targetItemView, targetBoard)
	local r, c = targetItem.y, targetItem.x

	if targetBoard and targetBoard.lotusLevel > 1 then

		-- local lotusDecAction = GameBoardActionDataSet:createAs(
		--  		GameActionTargetType.kGameItemAction,
		--  		GameItemActionType.kItem_Decrease_Lotus,
		--  		IntCoord:create(r,c),
		--  		nil,
		--  		GamePlayConfig_MaxAction_time)
		-- lotusDecAction.originLotusLevel = board.lotusLevel
		-- lotusDecAction.decreaseAll = decreaseAll
		-- mainLogic:addDestroyAction(lotusDecAction)

		local origLotusLevel = targetBoard.lotusLevel
		targetBoard.lotusLevel = 0
		targetItem.lotusLevel = 0

		local addScore = GamePlayConfigScore.LotusLevel2
		if origLotusLevel == 3 then
			addScore = addScore + GamePlayConfigScore.LotusLevel3
		end
		mainLogic:addScoreToTotal(r, c, addScore)

		mainLogic.lotusEliminationNum = mainLogic.lotusEliminationNum + origLotusLevel
		mainLogic.currLotusNum = mainLogic.currLotusNum - 1
		mainLogic.destroyLotusNum = mainLogic.destroyLotusNum + 1
		local pos = mainLogic:getGameItemPosInView(r, c)
		if mainLogic.PlayUIDelegate.targetType == kLevelTargetType.order_lotus then --内有assert，会报错
			mainLogic.PlayUIDelegate:setTargetNumber(0, 0, mainLogic.currLotusNum, pos)
		end
		ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_Lotus, ObstacleFootprintAction.k_Eliminate, origLotusLevel)

		if targetItemView then
			targetItemView:playLotusAnimation(1, "out")
			if origLotusLevel == 3 then
				targetItemView:setLotusHoldItemVisible(true)
			end
		end

		-- targetItem.isNeedUpdate = true
		-- targetBoard.isNeedUpdate = true
		mainLogic:checkItemBlock(r, c)
	end
end

function SquidLogic:dealWithTurretRemove(mainLogic, targetTurret)
	local r, c = targetTurret.y, targetTurret.x
	targetTurret.needRemoveEventuallyBySquid = true

	-- 本轮已经发射过
	if targetTurret.turretLocked then
		return true
	end

    local fireTargetCoord = TurretLogic:getTurretFireCenterPos(mainLogic, targetTurret)
    if fireTargetCoord then
        targetTurret.turretLevel = 1
		targetTurret.turretIsSuper = true
		TurretLogic:updateTurretLevel(mainLogic, r, c, true)
    else
        -- 没有目标，1级直接消除，0级升级后消除
	    if targetTurret.turretLevel == 1 then
		    return true
	    else
		    targetTurret.turretIsSuper = true
		    TurretLogic:updateTurretLevel(mainLogic, r, c, true)
	    end
    end

	return false
end

-- 唉……这些走action的逻辑……为了能够把覆盖下的东西同时删掉，只能重新写一遍。 心累 (ノ゜Д゜)ノ
function SquidLogic:removeColourFilter(mainLogic, targetItem, targetItemView, targetBoard)
	local r, c = targetItem.y, targetItem.x

	local origLevel = targetBoard.colorFilterBLevel
	targetBoard.colorFilterBLevel = 0

	if targetItemView then 
		targetItemView:playColorFilterBDisappear() 
		targetItemView:showFilterBHideLayers()
	end

	local color = AnimalTypeConfig.colorTypeList[targetBoard.colorFilterColor]
	mainLogic:addScoreToTotal(r, c, GamePlayConfigScore.MatchBySnow * origLevel, color)
	ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_ColorFilter, ObstacleFootprintAction.k_Hit, origLevel)
	GameExtandPlayLogic:doAllBlocker195Collect(mainLogic, r, c, Blocker195CollectType.kColorFilter)
	SquidLogic:checkSquidCollectItem(mainLogic, r, c, TileConst.kColorFilter)

	targetItem:setColorFilterBLock(false)

	targetBoard.colorFilterState = ColorFilterState.kStateA
	targetBoard.isNeedUpdate = true
	targetBoard.colorFilterBLevel = 0
	
	mainLogic:checkItemBlock(r, c)
	-- ColorFilterLogic:handleFilter(r, c) 
	-- mainLogic:addNeedCheckMatchPoint(r, c)
	mainLogic.gameMode:checkDropDownCollect(r, c)
	-- mainLogic:setNeedCheckFalling()
	-- mainLogic:tryBombSuperTotemsByForce()
end

-- 心 累 啊
function SquidLogic:removeLeafPile(mainLogic, targetItem, targetItemView, targetBoard)
	local r, c = targetItem.y, targetItem.x

	local origLevel = targetItem.blockerCoverLevel
	targetItem.blockerCoverLevel = 0

	if targetItemView then 
		targetItemView:decreaseBlockerCover(targetItem.blockerCoverLevel)
	end

	local scoreAdd = GamePlayConfigScore.MatchBySnow * origLevel
	mainLogic:addScoreToTotal(r, c, scoreAdd)

	mainLogic:tryDoOrderList(r, c, GameItemOrderType.kOthers, GameItemOrderType_Others.kBlockerCover, 1)
	ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_BlockerCover, ObstacleFootprintAction.k_Eliminate, 1)
	ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_BlockerCover, ObstacleFootprintAction.k_Hit, origLevel)

	mainLogic:checkItemBlock(r, c)
	-- mainLogic:addNeedCheckMatchPoint(r, c)
	mainLogic.gameMode:checkDropDownCollect(r, c)
	-- mainLogic:setNeedCheckFalling()
	-- mainLogic:tryBombSuperTotemsByForce()
	if targetItem:isActiveTotems() and targetItem:isAvailable() then
		mainLogic:addNewSuperTotemPos(IntCoord:create(r, c))
		mainLogic:tryBombSuperTotems()
	end
end

function SquidLogic:disactiveSuperCuteball(mainLogic, targetItem, targetItemView, targetBoard)
	local r, c = targetItem.y, targetItem.x

	if targetItem.ItemType == GameItemType.kBlocker195 then
		targetItem.isBlocker195Lock = true
		mainLogic.needClearBlcoker195Data = true
	end

	if targetItemView then 
		targetItemView:playSuperCuteInactive()
	end

	targetBoard.superCuteAddInt = GamePlayConfig_SuperCute_InactiveRound_UseMove
	targetBoard.superCuteState = GameItemSuperCuteBallState.kInactive
	targetItem.beEffectBySuperCute = false

	GameExtandPlayLogic:doAllBlocker195Collect(mainLogic, r, c, Blocker195CollectType.kSuperCute)
	SquidLogic:checkSquidCollectItem(mainLogic, r, c, TileConst.kSuperCute)
	ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_SuperCute, ObstacleFootprintAction.k_BackOff, 1)

	mainLogic:checkItemBlock(r, c)
	-- mainLogic:addNeedCheckMatchPoint(r, c)
	mainLogic.gameMode:checkDropDownCollect(r, c)
	-- mainLogic:setNeedCheckFalling()
	if targetItem:isActiveTotems() and targetItem:isAvailable() then
		mainLogic:addNewSuperTotemPos(IntCoord:create(r, c))
		mainLogic:tryBombSuperTotems()
	end
end

function SquidLogic:onSquidHitKindMimosa(mainLogic, targetItem)
	local r, c = targetItem.y, targetItem.x

	local headR, headC = GameExtandPlayLogic:findMimosa(mainLogic, r, c )
	if headR and headC and mainLogic.gameItemMap[headR] then
		local mimosaHead = mainLogic.gameItemMap[headR][headC]
		if mimosaHead and not mimosaHead.needRemoveEventuallyBySquid then 	--影响到它的，一只鱿鱼足矣
			mimosaHead.needRemoveEventuallyBySquid = true
			GameExtandPlayLogic:backMimosa(mainLogic, r, c)
		end
	end
end

----------------------- AI用 ----------------------------
function SquidLogic:getPossibleCollectTargetOfLevel(config)
	local possibleTargets = {}

	if (config.squidConfig) then
		for k, v in pairs(config.squidConfig) do
			local targetData = splite(v, "_")
			local targetType = tonumber(targetData[1])
			if targetType < 100000 then targetType = targetType + 1 end
			possibleTargets[targetType] = true
		end
	end

	return possibleTargets
end

function SquidLogic:getSquidAmountOnBoardByTargetType(mainLogic)
	local amountOfTarget = {}

	for r = 1, #mainLogic.gameItemMap do
		for c = 1, #mainLogic.gameItemMap[r] do
			local item = mainLogic.gameItemMap[r][c]
			if item and item.ItemType == GameItemType.kSquid then
				local targetType = item.squidTargetType
				if not amountOfTarget[targetType] then
					amountOfTarget[targetType] = 1
				else
					amountOfTarget[targetType] = amountOfTarget[targetType] + 1
				end
			end
		end
	end

	return amountOfTarget
end