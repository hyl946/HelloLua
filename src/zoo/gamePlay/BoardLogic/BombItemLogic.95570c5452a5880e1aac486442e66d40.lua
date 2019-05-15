--------------
------特效爆炸逻辑
--------------
BombItemLogic = class{}

function BombItemLogic:BombByMatch(mainLogic)
	local function getMatchPosList(matchFlag)
		local result = {}
		for r = 1, #mainLogic.swapHelpMap do
			for c = 1, #mainLogic.swapHelpMap[r] do
				if mainLogic.swapHelpMap[r][c] == matchFlag then
					table.insert(result, { r = r, c = c })
				end
			end
		end
		return result
	end

	if mainLogic.theGamePlayType == GameModeTypeId.LIGHT_UP_ID 
		or mainLogic.theGamePlayType == GameModeTypeId.SEA_ORDER_ID 
		then 
		for r = 1, #mainLogic.swapHelpMap do
			for c = 1, #mainLogic.swapHelpMap[r] do
				local matchFlag = mainLogic.swapHelpMap[r][c]
				if matchFlag > 0 then 		----参与了本次消除
					local item = mainLogic.gameItemMap[r][c]
					local specialType = mainLogic.gameItemMap[r][c].ItemSpecialType 	--特殊类型
					
					if AnimalTypeConfig.isSpecialTypeValid(specialType) then
						if not item.isItemLock then
							local matchPosList = getMatchPosList(matchFlag)
							item.lightUpBombMatchPosList = matchPosList
						end
					end
				end 
			end
		end
	end
end

----返回0表示未能发生爆炸
----否则返回对应的爆炸特效种类
----scoreScale表示引爆的小动物分数的计算倍数
----isBombScore表示爆炸物品是否计算分数----0不计算[假爆炸]1计算基础分数[真爆炸]2当做再次爆炸[真爆炸]
function BombItemLogic:BombItem(mainLogic, r, c, isBombScore, scoreScale)
	----引发爆破动作，running过程中，向前推进，或者一开始就处理完毕，然后依次启动掉落或者是连锁爆炸
	if isBombScore == nil then isBombScore = 0 end;
	if scoreScale == nil then scoreScale = 0 end;
	if (scoreScale <0) then scoreScale = 0 end;

	local specialType = mainLogic.gameItemMap[r][c].ItemSpecialType 

	return BombItemLogic:BombItemToChange(mainLogic, r, c, specialType, isBombScore, scoreScale)
end


----返回0表示未能发生爆炸
----否则返回对应的爆炸特效种类
----isFromeSpecial 是否由于特效交换导致的
function BombItemLogic:BombItemToChange(mainLogic, r, c, newSpecialType, isBombScore, scoreScale, specialMatchType)
	if r <= 0 or r > #mainLogic.boardmap or c <=0 or c> #mainLogic.boardmap[r] then return 0 end
	local item = mainLogic.gameItemMap[r][c]
	if item.isItemLock then return 0 end
	if scoreScale < 0 then scoreScale = 0 end

	if newSpecialType == AnimalTypeConfig.kLine then 			
		BombItemLogic:_BombItemLine(mainLogic, r, c, isBombScore, scoreScale, specialMatchType)
		return newSpecialType;
	elseif newSpecialType == AnimalTypeConfig.kColumn then 	
		BombItemLogic:_BombItemColumn(mainLogic, r, c, isBombScore, scoreScale, specialMatchType)
		return newSpecialType
	elseif newSpecialType == AnimalTypeConfig.kWrap then
		BombItemLogic:_BombItemWrap(mainLogic, r, c, isBombScore, scoreScale, specialMatchType)
		return newSpecialType
	elseif newSpecialType == AnimalTypeConfig.kColor then
		BombItemLogic:_BombItemColor(mainLogic,r,c, isBombScore, scoreScale, specialMatchType)
		return newSpecialType
	end

	return 0
end


function BombItemLogic:_BombItemLine(mainLogic, r, c, isBombScore, scoreScale, specialMatchType)	----直线爆炸特效---排
	if (scoreScale == 0) then scoreScale = 1.5 end
	-----1.计算分数
	if isBombScore == 1 then
		local item = mainLogic.gameItemMap[r][c]
		item.bombRes = nil
		item.isItemLock = true

		if not (mainLogic.gameItemMap[r][c].hasGivenScore or specialMatchType) then
			local scoreAdd = GamePlayConfigScore.SpecialBombkLine
			mainLogic:addScoreToTotal(r, c, scoreAdd, item._encrypt.ItemColorType)
			
			mainLogic.gameItemMap[r][c].hasGivenScore = true
		end
		mainLogic:tryDoOrderList(r,c,GameItemOrderType.kSpecialBomb, GameItemOrderType_SB.kLine)
		GameExtandPlayLogic:doAllBlocker195Collect(mainLogic, r, c, Blocker195CollectType.kLine)
		SquidLogic:checkSquidCollectItem(mainLogic, r, c, SquidCollectType[1])	--直线特效没有自己的大类型，故在SquidCollectType中获取特殊代号
	end

	
	local lineAction = GameBoardActionDataSet:createAs(
		GameActionTargetType.kGameItemAction,
		GameItemActionType.kItemSpecial_Line,
		IntCoord:create(r,c),
		nil,
		GamePlayConfig_SpecialBomb_Line_Anim_CD
	)
	lineAction.specialMatchType = specialMatchType
	lineAction.addInt2 = scoreScale;
	mainLogic:addDestructionPlanAction(lineAction)

	if not specialMatchType then 
		GamePlayMusicPlayer:playEffect(GameMusicType.kEliminateLine)
	end
end

function BombItemLogic:_BombItemColumn(mainLogic, r, c, isBombScore, scoreScale, specialMatchType)	----直线爆炸特效---列
	if (scoreScale == 0) then scoreScale = 1.5 end;
	if (scoreScale <0) then scoreScale = 0 end;

	if isBombScore == 1 then
		local item = mainLogic.gameItemMap[r][c]
		item.bombRes = nil
		item.isItemLock = true

		if not (mainLogic.gameItemMap[r][c].hasGivenScore or specialMatchType) then
			local scoreAdd = GamePlayConfigScore.SpecialBombkColumn
			mainLogic:addScoreToTotal(r, c, scoreAdd, item._encrypt.ItemColorType)
			mainLogic.gameItemMap[r][c].hasGivenScore = true
		end
		mainLogic:tryDoOrderList(r,c,GameItemOrderType.kSpecialBomb, GameItemOrderType_SB.kLine)
		GameExtandPlayLogic:doAllBlocker195Collect(mainLogic, r, c, Blocker195CollectType.kLine)
		SquidLogic:checkSquidCollectItem(mainLogic, r, c, SquidCollectType[1])	--直线特效没有自己的大类型，故在SquidCollectType中获取特殊代号
	end

	

	----2.确认直线特效--->开始爆炸
	local columnAction = GameBoardActionDataSet:createAs(
		GameActionTargetType.kGameItemAction,
		GameItemActionType.kItemSpecial_Column,
		IntCoord:create(r,c),
		nil,
		GamePlayConfig_SpecialBomb_Column_Anim_CD
		)
	columnAction.specialMatchType = specialMatchType
	columnAction.addInt2 = scoreScale;
	mainLogic:addDestructionPlanAction(columnAction)

	if not specialMatchType then
		GamePlayMusicPlayer:playEffect(GameMusicType.kEliminateLine);
	end
end

function BombItemLogic:_BombItemWrap(mainLogic, r, c, isBombScore, scoreScale, specialMatchType)
	if (scoreScale == 0) then scoreScale = 2.0 end;
	if (scoreScale <0) then scoreScale = 0 end;

	if isBombScore == 1 then
		local item = mainLogic.gameItemMap[r][c]
		item.bombRes = nil
		item.isItemLock = true

		if not mainLogic.gameItemMap[r][c].hasGivenScore then 
			local scoreAdd = GamePlayConfigScore.SpecialBombkWrap
			mainLogic:addScoreToTotal(r, c, scoreAdd, item._encrypt.ItemColorType)
			mainLogic.gameItemMap[r][c].hasGivenScore = true
		end
		mainLogic:tryDoOrderList(r,c,GameItemOrderType.kSpecialBomb, GameItemOrderType_SB.kWrap)
		GameExtandPlayLogic:doAllBlocker195Collect(mainLogic, r, c, Blocker195CollectType.kWrap)
		SquidLogic:checkSquidCollectItem(mainLogic, r, c, SquidCollectType[2])	--爆炸特效没有自己的大类型，故在SquidCollectType中获取特殊代号
	end

	local warpAction = GameBoardActionDataSet:createAs(
		GameActionTargetType.kGameItemAction,
		GameItemActionType.kItemSpecial_Wrap,
		IntCoord:create(r,c),
		nil,
		GamePlayConfig_SpecialBomb_Wrap
		)
	warpAction.addInt2 = scoreScale;
	warpAction.specialMatchType = specialMatchType
	mainLogic:addDestructionPlanAction(warpAction)

	if not specialMatchType then
		GamePlayMusicPlayer:playEffect(GameMusicType.kEliminateWrap);
	end
end

--------魔力鸟被炸到了------------
function BombItemLogic:_BombItemColor(mainLogic, r, c, isBombScore, scoreScale, specialMatchType)
	if (scoreScale == 0) then scoreScale = 2.5 end
	if (scoreScale <0) then scoreScale = 0 end

	local item = mainLogic.gameItemMap[r][c]
	item.bombRes = nil
	item.isItemLock = true

	local ColorAction = GameBoardActionDataSet:createAs(
		GameActionTargetType.kGameItemAction,
		GameItemActionType.kItemSpecial_Color ,
		IntCoord:create(r,c),
		nil,
		GamePlayConfig_SpecialBomb_BirdAnimal_Time1
		)
	ColorAction.addInt = 0
	ColorAction.specialMatchType = specialMatchType
	ColorAction.addInt2 = scoreScale
	mainLogic:addDestructionPlanAction(ColorAction)
	mainLogic:tryDoOrderList(r,c,GameItemOrderType.kSpecialBomb, GameItemOrderType_SB.kColor)

	if not specialMatchType then
		GamePlayMusicPlayer:playEffect(GameMusicType.kEliminateColor)
	end
end


----尝试被某一次特效爆炸覆盖
----返回0，超出地图范围----返回2，遇到银币，需要中断----返回1：正常消除东西
----coverFalling是否进行掉落中的东西的爆炸计算
----scoreScale分数倍率
----bombNoReach炸掉没抵达的东西
function BombItemLogic:tryCoverByBomb(mainLogic, r, c, coverFalling, scoreScale, bombNoReach, noScore, footprintType)
	if r <= 0 or r > #mainLogic.boardmap or c <=0 or c> #mainLogic.boardmap[r] then return 0 end
	if mainLogic.boardmap[r][c].isUsed == false then return 0 end

	if bombNoReach == nil then bombNoReach = false end

	local item = mainLogic.gameItemMap[r][c]
	local recordFootprint = false

	if item:canBeEliminateBySpecial() then
		if item.ItemStatus == GameItemStatusType.kIsMatch
			or item.ItemStatus == GameItemStatusType.kIsSpecialCover
			then
		elseif item.ItemStatus == GameItemStatusType.kNone
			or item.ItemStatus == GameItemStatusType.kWaitBomb then
			-------普通的,可以被消除-----
			BombItemLogic:_removeGameItemBySpecialBomb(mainLogic, r, c, scoreScale, noScore)
			recordFootprint = true
		elseif item.ItemStatus == GameItemStatusType.kIsFalling
			or item.ItemStatus == GameItemStatusType.kJustStop
			or item.ItemStatus == GameItemStatusType.kItemHalfStable
			or item.ItemStatus == GameItemStatusType.kJustArrived
			then 				----物体正在掉落
			if coverFalling then
				-----爆炸掉掉落中的东西-----
				if (item.dataReach or bombNoReach) then 							----数据已经抵达
					BombItemLogic:_removeGameItemBySpecialBomb(mainLogic, r, c, scoreScale, noScore)
					recordFootprint = true
				elseif r + 1 <= #mainLogic.gameItemMap then  			----数据未抵达，	但是可以检测下面那个物体是否还处于上方这个物体的爆炸范围内
					if BombItemLogic:isItemTypeCanBeEliminateByBird(mainLogic, r + 1, c) then 			----如果下面那个是可以爆炸覆盖的类型
						local item2 = mainLogic.gameItemMap[r + 1][c];
						if item2.ItemStatus == GameItemStatusType.kIsFalling 						----正在掉落
							and item2.dataReach == false  											----数据未达
							and item2.comePos.x == r 												----位置正确
							and item2.comePos.y == c 
							then 
							BombItemLogic:_removeGameItemBySpecialBomb(mainLogic, r + 1, c, scoreScale, noScore)
							recordFootprint = true
						end
					end
				end
			end
		end

		if footprintType and recordFootprint then
			ObstacleFootprintManager:addRecord(footprintType, ObstacleFootprintAction.k_HitTargets, 1)
		end

		if item.ItemType == GameItemType.kCoin and item.ItemStatus ~= GameItemStatusType.kDestroy then
			if mainLogic.levelType == GameLevelType.kSpring2018 or mainLogic.levelType == GameLevelType.kSpring2017 then
				return 1
			end
			return 2
		else
			SnailLogic:SpecialCoverSnailRoadAtPos( mainLogic, r, c )
			return 1
		end
	elseif item.ItemType == GameItemType.kQuestionMark and item:isQuestionMarkcanBeDestroy() then
		GameExtandPlayLogic:questionMarkBomb( mainLogic, r, c )
	elseif item.ItemType == GameItemType.kPuffer and item:isVisibleAndFree() then
		return 2
	elseif item.isEmpty then 
		SnailLogic:SpecialCoverSnailRoadAtPos( mainLogic, r, c )
	end
	return 0
end

----尝试被某一次特效爆炸覆盖
----返回0，超出地图范围----返回2，遇到银币，需要中断----返回1：正常消除东西
----scoreScale分数倍率
function BombItemLogic:tryCoverByBombForFilter(mainLogic, r, c, scoreScale)
	if r <= 0 or r > #mainLogic.boardmap or c <=0 or c> #mainLogic.boardmap[r] then return 0 end
	if mainLogic.boardmap[r][c].isUsed == false then return 0 end
	local item = mainLogic.gameItemMap[r][c]
	local recordFootprint = false

	if item:canBeEliminateByFilter() then
		if item.ItemStatus == GameItemStatusType.kIsMatch
			or item.ItemStatus == GameItemStatusType.kIsSpecialCover
			then
		elseif item.ItemStatus == GameItemStatusType.kNone
			or item.ItemStatus == GameItemStatusType.kWaitBomb then
			-------普通的,可以被消除-----
			BombItemLogic:_removeGameItemBySpecialBomb(mainLogic, r, c, scoreScale)
			recordFootprint = true
		elseif item.ItemStatus == GameItemStatusType.kIsFalling
			or item.ItemStatus == GameItemStatusType.kJustStop
			or item.ItemStatus == GameItemStatusType.kItemHalfStable
			or item.ItemStatus == GameItemStatusType.kJustArrived
			then 				----物体正在掉落
			if item.dataReach then 							----数据已经抵达
				BombItemLogic:_removeGameItemBySpecialBomb(mainLogic, r, c, scoreScale)
				recordFootprint = true
			end
		end
		SnailLogic:SpecialCoverSnailRoadAtPos(mainLogic, r, c)
		if recordFootprint then
			ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_ColorFilter, ObstacleFootprintAction.k_HitTargets, 1)
		end
	elseif item.ItemType == GameItemType.kQuestionMark and item:isAvailable() and not item:hasFurball() then
		GameExtandPlayLogic:questionMarkBomb(mainLogic, r, c)
	end
end

function BombItemLogic:_removeGameItemBySpecialBomb(mainLogic, r, c, scoreScale, noScore)
	local item = mainLogic.gameItemMap[r][c]
	--特效的分数由特效爆炸逻辑计算
	if not item.hasGivenScore and item.ItemSpecialType == 0 then
		if not noScore then
			local scoreAdd = 0
			local scoreBase = ScoreCountLogic:getItemDestroyBaseScore(mainLogic.gameItemMap[r][c].ItemType)
			scoreAdd = scoreBase * scoreScale
			if scoreAdd > 0 then
				mainLogic:addScoreToTotal(r, c, scoreAdd, item._encrypt.ItemColorType)
			end
		end
		item.hasGivenScore = true
	end
	item:AddItemStatus(GameItemStatusType.kIsSpecialCover)
end

----如果可以被鸟特效直接消除
function BombItemLogic:isItemTypeCanBeEliminateByBird(mainLogic, r, c)
	local item = mainLogic.gameItemMap[r][c];
	return item:canBeEliminateByBirdAnimal()
end

----被Bird的特效覆盖到----
function BombItemLogic:tryCoverByBird(mainLogic, r, c, r2, c2, scoreScale)
	----1.判断是否可以使用----
	if r <= 0 or r > #mainLogic.boardmap or c <=0 or c> #mainLogic.boardmap[r] then return 0 end
	if mainLogic.boardmap[r][c].isUsed == false then return 0 end
	----2.分类处理
	local item = mainLogic.gameItemMap[r][c]
	if BombItemLogic:isItemTypeCanBeEliminateByBird(mainLogic,r,c) then
		----第一类别
		----状态判断
		if item.ItemStatus == GameItemStatusType.kIsMatch
			or item.ItemStatus == GameItemStatusType.kIsSpecialCover
			then
			-------已经被覆盖过的，只扣除层数，显示相应动画，不显示动物爆炸的特效 -- to do 
		elseif item.ItemStatus == GameItemStatusType.kNone 
			or item.ItemStatus == GameItemStatusType.kWaitBomb
			or item.ItemStatus == GameItemStatusType.kJustStop
			or item.ItemStatus == GameItemStatusType.kItemHalfStable
			or item.ItemStatus == GameItemStatusType.kJustArrived
			then
			-------普通的,可以被消除-------------进行消除-----
			local specialType = item.ItemSpecialType
			if specialType == AnimalTypeConfig.kLine 
				or specialType == AnimalTypeConfig.kColumn
				or specialType == AnimalTypeConfig.kWrap
				then
				item:AddItemStatus(GameItemStatusType.kIsSpecialCover)
			else
				----未发生爆炸---->>引起特效消除-----旋转进入鸟的黑洞
				----1.获得分数
				local scoreAdd = 0
				local scoreBase = 0
				if item.ItemType == GameItemType.kAnimal then
					scoreBase = GamePlayConfigScore.MatchDeletedBase
				elseif item.ItemType == GameItemType.kCrystal then
					scoreBase = GamePlayConfigScore.MatchDeletedCrystal
				elseif mainLogic.gameItemMap[r][c].ItemType == GameItemType.kRocket then
					scoreBase = GamePlayConfigScore.Rocket
				end
				scoreAdd = scoreBase * scoreScale 

				mainLogic:addScoreToTotal(r, c, scoreAdd, item._encrypt.ItemColorType)

				if item.ItemType == GameItemType.kAnimal then
					----2.播放动画
					local CoverAction =	GameBoardActionDataSet:createAs(
						GameActionTargetType.kGameItemAction,
						GameItemActionType.kItemSpecial_Color_ItemDeleted,
						IntCoord:create(r,c),				----炸掉的东西
						IntCoord:create(r2,c2),				----飞向的位置
						GamePlayConfig_SpecialBomb_BirdAnimal_Time2) 			----炸掉的时间
					CoverAction.addInfo = "kAnimal"
					mainLogic:addDestroyAction(CoverAction)
					item:AddItemStatus(GameItemStatusType.kDestroy) 		----修改状态

					if item:canChargeCrystalStone() then
						GameExtandPlayLogic:chargeCrystalStone(mainLogic, r, c, item._encrypt.ItemColorType)
					end
				else
					item:AddItemStatus(GameItemStatusType.kIsSpecialCover) 		----修改状态
				end
				SnailLogic:SpecialCoverSnailRoadAtPos( mainLogic, r, c )
				mainLogic:tryDoOrderList(r,c, GameItemOrderType.kAnimal, item._encrypt.ItemColorType)
			end

		elseif item.ItemStatus == GameItemStatusType.kIsFalling then  		----物体正在掉落
			local specialType = item.ItemSpecialType
			if specialType == AnimalTypeConfig.kLine 
				or specialType == AnimalTypeConfig.kColumn
				or specialType == AnimalTypeConfig.kWrap
				then
				item:AddItemStatus(GameItemStatusType.kIsSpecialCover)
			else
				----未发生爆炸---->>引起特效消除-----旋转进入鸟的黑洞
				----1.获得分数
				local scoreBase = 0
				if item.ItemType == GameItemType.kAnimal then
					scoreBase = GamePlayConfigScore.MatchDeletedBase
				elseif item.ItemType == GameItemType.kCrystal then
					scoreBase = GamePlayConfigScore.MatchDeletedCrystal
				elseif item.ItemType == GameItemType.kRocket then
					scoreBase = GamePlayConfigScore.Rocket
				end
				local scoreAdd = scoreBase * scoreScale;

				mainLogic:addScoreToTotal(r, c, scoreAdd, item._encrypt.ItemColorType)

				if item.ItemType == GameItemType.kAnimal then
				----2.播放动画
					local CoverAction =	GameBoardActionDataSet:createAs(
						GameActionTargetType.kGameItemAction,
						GameItemActionType.kItemSpecial_Color_ItemDeleted,
						IntCoord:create(r,c),				----炸掉的东西
						IntCoord:create(r2,c2),				----飞向的位置
						GamePlayConfig_SpecialBomb_BirdAnimal_Time2) 			----炸掉的时间
					CoverAction.addInfo = "kAnimal"
					mainLogic:addDestroyAction(CoverAction)
					item:AddItemStatus(GameItemStatusType.kDestroy) 		----修改状态

					if item:canChargeCrystalStone() then
						GameExtandPlayLogic:chargeCrystalStone(mainLogic, r, c, item._encrypt.ItemColorType)
					end
				else
					item:AddItemStatus(GameItemStatusType.kIsSpecialCover)
				end
				item.itemSpeed = 0;
				item.isEmpty = false;
				item.dataReach = true;
				item.gotoPos = nil;
				item.comePos = nil;
				mainLogic:tryDoOrderList(r, c, GameItemOrderType.kAnimal, item._encrypt.ItemColorType)
			end
		end
	elseif item.ItemType == GameItemType.kQuestionMark and item:isQuestionMarkcanBeDestroy() then
		GameExtandPlayLogic:questionMarkBomb( mainLogic, r, c )
	-- elseif item.beEffectByMimosa == GameItemType.kKindMimosa then
	-- 	GameExtandPlayLogic:backMimosaToRC(mainLogic, r, c)
	else
		----其他类别
	end
end

--------鸟和特效交换后，飞向各个地方新特效-----
function BombItemLogic:setSignOfBombResWithBirdFlying(mainLogic, r1, c1, theColor, newType,SpecialID)
	local bombRes = IntCoord:create(r1,c1)

	local PosList = mainLogic:getPosListOfColor(theColor)
	local count = #PosList

	for i,v in ipairs(PosList) do
		local r = v.x;
		local c = v.y;
		local item = mainLogic.gameItemMap[r][c]
		local borad = mainLogic.boardmap[r][c]
		if borad.lotusLevel > 0 and borad.lotusLevel ~= 3 then
			GameExtandPlayLogic:decreaseLotus( mainLogic , r ,c , 1 , false)
		end

		if item.ItemSpecialType ~= AnimalTypeConfig.kColor
			and item:canBecomeSpecialBySwapColorSpecial()
			then

			if item.beEffectByMimosa == GameItemType.kKindMimosa then
				GameExtandPlayLogic:backMimosaToRC(mainLogic, r, c)
			end

			if item:hasFurball() then
				SpecialCoverLogic:SpecialCoverAtPos(mainLogic, v.x, v.y, 3, nil,nil,nil,nil,nil,SpecialID)
			end

			-- 多层蜂蜜都爆掉
			if item.honeyLevel > 1 then
				item.honeyLevel = 1
			end

			local length = math.sqrt(math.pow(r1 - r, 2) + math.pow(c1 - c, 2))
			local duringTime = 12 + math.ceil(16 * length / 11)
			if (newType == AnimalTypeConfig.kLine or newType == AnimalTypeConfig.kColumn) then
				if (item.ItemSpecialType == AnimalTypeConfig.kLine or item.ItemSpecialType == AnimalTypeConfig.kColumn) then
					----如果已经是直线特效则没有飞行效果--
					item.bombRes = bombRes 											----记录来源
				else
					----开始变化----
					local FlyingAction = GameBoardActionDataSet:createAs(
						GameActionTargetType.kGameItemAction,
						GameItemActionType.kItemSpecial_ColorLine_flying,
						IntCoord:create(r,c),				----物体位置
						IntCoord:create(r1,c1),				----鸟的位置
						duringTime)				----总时间必须大于0.1
					FlyingAction.addInt = i	----做个延迟
					FlyingAction.ItemSpecialType = newType
					FlyingAction.swapColor = theColor
					FlyingAction.ItemType = mainLogic.gameItemMap[r1][c1].ItemType
					mainLogic:addDestructionPlanAction(FlyingAction)
					item.bombRes = bombRes 											----记录来源
				end
			elseif (newType == AnimalTypeConfig.kWrap) then
				if item.ItemSpecialType == AnimalTypeConfig.kWrap then
					item.bombRes = bombRes
				else
					----开始变化----
					local FlyingAction = GameBoardActionDataSet:createAs(
						GameActionTargetType.kGameItemAction,
						GameItemActionType.kItemSpecial_ColorWrap_flying,
						IntCoord:create(r,c),				----物体位置
						IntCoord:create(r1,c1),				----鸟的位置
						duringTime)				----总时间必须大于0.1
					FlyingAction.addInt = i										----做个延迟
					FlyingAction.ItemSpecialType = newType
					FlyingAction.swapColor = theColor
					mainLogic:addDestructionPlanAction(FlyingAction)
					item.bombRes = bombRes 											----记录来源
				end
			end

			if item:hasFurball() and item.furballType == GameItemFurballType.kBrown then
				item.bombRes = nil
			else
				-- item:AddItemStatus(GameItemStatusType.kWaitBomb)
			end
		elseif item.ItemType == GameItemType.kMagicLamp and item.lampLevel > 0 and item:isAvailable() then
			SpecialCoverLogic:SpecialCoverAtPos(mainLogic, r, c, 3, nil, nil ,nil ,nil ,nil, SpecialID )
			-- local action = GameBoardActionDataSet:createAs(
   --                      GameActionTargetType.kGameItemAction,
   --                      GameItemActionType.kItem_Magic_Lamp_Charging,
   --                      IntCoord:create(r, c),
   --                      nil,
   --                      GamePlayConfig_MaxAction_time
   --                  )
			-- action.count = 1
		 --    mainLogic:addDestroyAction(action)
    	elseif item.ItemType == GameItemType.kWukong 
    		and item.wukongProgressCurr < item.wukongProgressTotal 
    		and ( item.wukongState == TileWukongState.kNormal or item.wukongState == TileWukongState.kOnHit or item.wukongState == TileWukongState.kOnActive )
    		and item:isAvailable() and not mainLogic.isBonusTime then
    		local action = GameBoardActionDataSet:createAs(
                        GameActionTargetType.kGameItemAction,
                        GameItemActionType.kItem_Wukong_Charging,
                        IntCoord:create(r, c),
                        nil,
                        GamePlayConfig_MaxAction_time
                    )
			action.count = 3
		    mainLogic:addDestroyAction(action)
		elseif item.ItemType == GameItemType.kBlocker199 then
			item.bombRes = bombRes
		end
	end
end


--------挨个引爆特效--------运行一次引爆一个----
function BombItemLogic:tryBombWithBombRes(mainLogic, r1, c1, isBombScore, scoreScale)
	for r = 1, #mainLogic.gameItemMap do
		for c = 1, #mainLogic.gameItemMap[r] do
			local item = mainLogic.gameItemMap[r][c];
			if item.bombRes ~= nil and item.bombRes.x == r1 and item.bombRes.y == c1 then
				if item.ItemStatus == GameItemStatusType.kNone 
					or item.ItemStatus == GameItemStatusType.kItemHalfStable 
					or item.ItemStatus == GameItemStatusType.kJustArrived
					or item.ItemStatus == GameItemStatusType.kWaitBomb
					then
					item:AddItemStatus(GameItemStatusType.kIsSpecialCover)
				end
				return true
			end
		end
	end
	return false
end

------是否可以被引爆-----
function BombItemLogic:canBeBombByBirdBird(mainLogic, r, c)
	local item = mainLogic.gameItemMap[r][c]
	if item.ItemType == GameItemType.kAnimal
		and AnimalTypeConfig.isSpecialTypeValid(item.ItemSpecialType)
		and item:isAvailable()
		then
		return true
	end
	return false;
end

-------一次性引爆所有特效-----
function BombItemLogic:BombAll(mainLogic, SpecialID )
	for r = 1, #mainLogic.gameItemMap do
		for c = 1, #mainLogic.gameItemMap[r] do
			if (BombItemLogic:canBeBombByBirdBird(mainLogic, r, c)) then
				-----可以被直接引爆的情况-----
				local item = mainLogic.gameItemMap[r][c]
				if item:hasLock() then
				elseif item:hasFurball() then
					SpecialCoverLogic:SpecialCoverAtPos(mainLogic, r, c, 1, 4, nil,nil,nil,nil, SpecialID )
				else
					item:AddItemStatus(GameItemStatusType.kIsSpecialCover)
				end
			end
		end
	end
end

---------一次性引爆所有带有颜色的item------------------
function BombItemLogic:bombAllColorItem(mainLogic, SpecialID)
	for r = 1, #mainLogic.gameItemMap do 
		for c = 1, #mainLogic.gameItemMap[r] do 
			local item = mainLogic.gameItemMap[r][c]
			if item and item:isColorful() then
				if item.ItemType == GameItemType.kRabbit then
					item:changeRabbitState(GameItemRabbitState.kNoTarget)
				end
				
				if item:hasLock() then
				elseif item:hasFurball() then
					SpecialCoverLogic:SpecialCoverAtPos(mainLogic, r, c, 1, 4, nil,nil,nil,nil, SpecialID)
				else
					item:AddItemStatus(GameItemStatusType.kIsSpecialCover)
				end
			end
		end
	end
end

----统计当前可爆炸的特效
function BombItemLogic:getNumSpecialBomb(mainLogic)
	local result = 0
	if mainLogic and mainLogic.gameItemMap then 
		for r = 1, #mainLogic.gameItemMap do
			for c = 1, #mainLogic.gameItemMap[r] do
				if BombItemLogic:canBeBombByBirdBird(mainLogic, r, c) then
					local item = mainLogic.gameItemMap[r][c]
					if item:hasLock() then
						result = result + 1
					elseif item:hasFurball() then
						if item.furballType == GameItemFurballType.kGrey then
							result = result + 1
						end
					else
						result = result + 1
					end
				end
			end
		end
	else
		he_log_error("mainLogic is disposed when getNumSpecialBomb")
	end

	return result
end

-- 效果与魔力鸟与魔力鸟效果完全相同，只是动画不一样
function BombItemLogic:bombAllByCrystalStone(mainLogic, isBombScore, scoreScale, SpecialID)

	for r = 1, #mainLogic.gameItemMap do
		for c = 1, #mainLogic.gameItemMap[r] do

			--果酱兼容
			if mainLogic:checkSrcSpecialCoverListIsHaveJamSperad(SpecialID) then
				GameExtandPlayLogic:addJamSperadFlag(mainLogic, r, c )
			end

			local item = mainLogic.gameItemMap[r][c]
			if item:isItemCanBeCoverByBirdBird() then
				if item:isItemCanBeEliminateByBirdBird() then
					----1.分数
					if not scoreScale or scoreScale == 0 then scoreScale = 1 end
					if scoreScale < 0 then scoreScale = 0 end

					local addScore = GamePlayConfigScore.MatchDeletedBase * scoreScale
					if mainLogic.gameItemMap[r][c].ItemType == GameItemType.kCrystal then 	 -----水晶则消除增加100分
						addScore = GamePlayConfigScore.MatchDeletedCrystal * scoreScale
					elseif mainLogic.gameItemMap[r][c].ItemType == GameItemType.kBalloon then 
						addScore = GamePlayConfigScore.Balloon * scoreScale
					elseif mainLogic.gameItemMap[r][c].ItemType == GameItemType.kRabbit then
						addScore = GamePlayConfigScore.Rabbit * scoreScale
					elseif mainLogic.gameItemMap[r][c].ItemType == GameItemType.kRocket then
						addScore = GamePlayConfigScore.Rocket * scoreScale
					end
					mainLogic:addScoreToTotal(r, c, addScore, item._encrypt.ItemColorType)

					item:AddItemStatus(GameItemStatusType.kIsSpecialCover)

					if mainLogic.gameItemMap[r][c].ItemType == GameItemType.kCrystal or mainLogic.gameItemMap[r][c].ItemType == GameItemType.kCoin then
						ProductItemLogic:shoundCome(mainLogic, mainLogic.gameItemMap[r][c].ItemType)
					end

					SpecialCoverLogic:SpecialCoverLightUpAtPos(mainLogic, r, c, scoreScale)
					SnailLogic:SpecialCoverSnailRoadAtPos( mainLogic, r, c )
					if mainLogic.boardmap[r][c].lotusLevel > 0 then
						GameExtandPlayLogic:decreaseLotus(mainLogic, r, c , 1 , false)
					end
				elseif item:hasLock() or item:hasFurball() then
					SpecialCoverLogic:SpecialCoverAtPos(mainLogic, r, c, 3, scoreScale,nil,nil,nil,nil,SpecialID)
				elseif item.ItemType == GameItemType.kCoin or item.ItemType == GameItemType.kBlocker207 then
					local addScore = GamePlayConfigScore.MatchDeletedCrystal * scoreScale
					mainLogic:addScoreToTotal(r, c, addScore)
					item:AddItemStatus(GameItemStatusType.kIsSpecialCover)
				elseif item.ItemType == GameItemType.kBlackCuteBall then
					GameExtandPlayLogic:onDecBlackCuteball(mainLogic, item, 1, scoreScale)
				elseif item.ItemType == GameItemType.kQuestionMark and item:isQuestionMarkcanBeDestroy() then
					GameExtandPlayLogic:questionMarkBomb( mainLogic, r, c )
				elseif item.ItemType == GameItemType.kCrystalStone 
					or item.ItemType == GameItemType.kPuffer
					or item.ItemType == GameItemType.kMissile
					or item.ItemType == GameItemType.kBuffBoom
					or item.ItemType == GameItemType.kScoreBuffBottle
					or item.ItemType == GameItemType.kFirecracker
					then
					SpecialCoverLogic:SpecialCoverAtPos(mainLogic, r, c, 0, scoreScale,nil,nil,nil,nil,SpecialID)
				end
			elseif item:isBlockerCanBeCoverByBirdBrid() then
				SpecialCoverLogic:SpecialCoverAtPos(mainLogic, r, c, 3, scoreScale,nil,nil,nil,nil,SpecialID)
			elseif item.isEmpty then
				SnailLogic:SpecialCoverSnailRoadAtPos( mainLogic, r, c )
			else
				SpecialCoverLogic:SpecialCoverLightUpAtPos(mainLogic, r, c, scoreScale)
			end
			SpecialCoverLogic:specialCoverChainsAtPos(mainLogic, r, c, {ChainDirConfig.kUp, ChainDirConfig.kDown, ChainDirConfig.kLeft, ChainDirConfig.kRight})
		end
	end
end

-------鸟鸟交换清屏-----
function BombItemLogic:tryCoverByBirdBird(mainLogic, birdBirdPos, isBombScore, scoreScale, collectPos, birdBirdPos2)

	local SpecialID = mainLogic:addSrcSpecialCoverToList( ccp(birdBirdPos.r,birdBirdPos.c), ccp(birdBirdPos2.r,birdBirdPos2.c) )

	for r = 1, #mainLogic.gameItemMap do
		for c = 1, #mainLogic.gameItemMap[r] do
			local item = mainLogic.gameItemMap[r][c]

			--果酱兼容
			if mainLogic:checkSrcSpecialCoverListIsHaveJamSperad(SpecialID) then
				GameExtandPlayLogic:addJamSperadFlag(mainLogic, r, c )
			end

			if item:isItemCanBeCoverByBirdBird() then
				if item:isItemCanBeEliminateByBirdBird() then
					----1.分数
					if scoreScale == 0 then scoreScale = 1 end
					if scoreScale < 0 then scoreScale = 0 end

					local addScore = GamePlayConfigScore.MatchDeletedBase * scoreScale
					if item.ItemType == GameItemType.kCrystal then 	 -----水晶则消除增加100分
						addScore = GamePlayConfigScore.MatchDeletedCrystal * scoreScale
					elseif item.ItemType == GameItemType.kBalloon then 
						addScore = GamePlayConfigScore.Balloon * scoreScale
					elseif item.ItemType == GameItemType.kRabbit then
						addScore = GamePlayConfigScore.Rabbit * scoreScale
					elseif item.ItemType == GameItemType.kRocket then
						addScore = GamePlayConfigScore.Rocket * scoreScale
					end
					mainLogic:addScoreToTotal(r, c, addScore, item._encrypt.ItemColorType)

					----2.动画
					if item.ItemType == GameItemType.kAnimal then
						if AnimalTypeConfig.isSpecialTypeValid(item.ItemSpecialType) then
							item:AddItemStatus(GameItemStatusType.kIsSpecialCover)
						else
							local CoverAction = nil
							CoverAction = GameBoardActionDataSet:createAs(
								GameActionTargetType.kGameItemAction,
								GameItemActionType.kItemSpecial_ColorColor_ItemDeleted,
								IntCoord:create(r,c),
								IntCoord:create(birdBirdPos.r, birdBirdPos.c),
								GamePlayConfig_SpecialBomb_BirdBird_Time5)
							CoverAction.addInfo = "kAnimal"
							CoverAction.addInt2 = scoreScale
							CoverAction.collectPos = collectPos
							mainLogic:addDestroyAction(CoverAction)

							item:AddItemStatus(GameItemStatusType.kDestroy)
							mainLogic:tryDoOrderList(r, c, GameItemOrderType.kAnimal, item._encrypt.ItemColorType)

							if item:canChargeCrystalStone() then
								GameExtandPlayLogic:chargeCrystalStone(mainLogic, r, c, item._encrypt.ItemColorType)
								GameExtandPlayLogic:doAllBlocker211Collect(mainLogic, r, c, item._encrypt.ItemColorType, false, 1)
							end
						end
						item.gotoPos = nil
						item.comePos = nil
					else
						item:AddItemStatus(GameItemStatusType.kIsSpecialCover)
					end

					if item.ItemType == GameItemType.kCrystal or item.ItemType == GameItemType.kCoin then
						ProductItemLogic:shoundCome(mainLogic, item.ItemType)
					end

					SpecialCoverLogic:SpecialCoverLightUpAtPos(mainLogic, r, c, scoreScale)
					SnailLogic:SpecialCoverSnailRoadAtPos( mainLogic, r, c )

					if mainLogic.boardmap[r][c].lotusLevel > 0 then
						GameExtandPlayLogic:decreaseLotus(mainLogic, r, c , 1 , false)
					end
				elseif item:hasLock() or item:hasFurball() then
					SpecialCoverLogic:SpecialCoverAtPos(mainLogic, r, c, 3, scoreScale,nil,nil,nil,nil,SpecialID)
				elseif item.ItemType == GameItemType.kCoin or item.ItemType == GameItemType.kBlocker207 then
					local addScore = GamePlayConfigScore.MatchDeletedCrystal * scoreScale
					mainLogic:addScoreToTotal(r, c, addScore)
					item:AddItemStatus(GameItemStatusType.kIsSpecialCover)
				elseif item.ItemType == GameItemType.kBlackCuteBall then
					GameExtandPlayLogic:onDecBlackCuteball(mainLogic, item, 1, scoreScale)
				elseif item.ItemType == GameItemType.kQuestionMark and item:isQuestionMarkcanBeDestroy() then
					GameExtandPlayLogic:questionMarkBomb( mainLogic, r, c )
				elseif item.ItemType == GameItemType.kCrystalStone 
					or item.ItemType == GameItemType.kPuffer 
					or item.ItemType == GameItemType.kMissile 
					or item.ItemType == GameItemType.kBuffBoom 
					or item.ItemType == GameItemType.kScoreBuffBottle
					or item.ItemType == GameItemType.kFirecracker
					then
					SpecialCoverLogic:SpecialCoverAtPos(mainLogic, r, c, 0, scoreScale,nil,nil,nil,nil,SpecialID)
				end
			elseif item:isBlockerCanBeCoverByBirdBrid() then
				SpecialCoverLogic:SpecialCoverAtPos(mainLogic, r, c, 3, scoreScale,nil,nil,nil,nil,SpecialID)
			elseif item.isEmpty then
				SnailLogic:SpecialCoverSnailRoadAtPos( mainLogic, r, c )
			else
				SpecialCoverLogic:SpecialCoverLightUpAtPos(mainLogic, r, c, scoreScale)
			end
			SpecialCoverLogic:specialCoverChainsAtPos(mainLogic, r, c, {ChainDirConfig.kUp, ChainDirConfig.kDown, ChainDirConfig.kLeft, ChainDirConfig.kRight})
		end
	end
end

-----BounsTime的时候随机引爆现有特效
function BombItemLogic:BonusTime_RandomBombOne(mainLogic, trueBomb)
	for i = 1, 3 do
		for r = 1, #mainLogic.gameItemMap do
			for c = 1, #mainLogic.gameItemMap[r] do
				local item = mainLogic.gameItemMap[r][c]
				if item.isUsed == true 
					and item.ItemType == GameItemType.kAnimal
					and item.ItemSpecialType ~= 0 
					and item:isAvailable()
					then

					if item:hasFurball() then
						SpecialCoverLogic:effectBlockerAt(mainLogic, r, c, 1)
					end

					-- 多层蜂蜜都爆掉
					if item.honeyLevel > 1 then
						item.honeyLevel = 1
					end

					if not item:hasFurball() or item.furballType == GameItemFurballType.kGrey then
						if i == 1 then
							if item.ItemSpecialType == AnimalTypeConfig.kWrap then
								if item.ItemStatus == GameItemStatusType.kNone and trueBomb then
									mainLogic.gameItemMap[r][c]:AddItemStatus(GameItemStatusType.kIsSpecialCover)
									mainLogic:setNeedCheckFalling()
								end
								return true
							end
						elseif i == 2 then
							if item.ItemSpecialType == AnimalTypeConfig.kColumn 
								or item.ItemSpecialType == AnimalTypeConfig.kLine then
								if item.ItemStatus == GameItemStatusType.kNone and trueBomb then
									mainLogic.gameItemMap[r][c]:AddItemStatus(GameItemStatusType.kIsSpecialCover)
									mainLogic:setNeedCheckFalling()
								end
								return true
							end
						elseif i == 3 then
							if item.ItemSpecialType == AnimalTypeConfig.kColor then
								if item.ItemStatus == GameItemStatusType.kNone and trueBomb then
									mainLogic.gameItemMap[r][c]:AddItemStatus(GameItemStatusType.kIsSpecialCover)
									mainLogic:setNeedCheckFalling()
								end
								return true
							end
						end
					end
				end
			end
		end
	end
	return false
end

function BombItemLogic:initRandomAnimalChangeList(mainLogic)
	mainLogic.randomAnimalHelpList = {}
	local counts = 0;
	for r=1,#mainLogic.gameItemMap do
		for c=1,#mainLogic.gameItemMap[r] do
			local item = mainLogic.gameItemMap[r][c]
			if item.ItemType == GameItemType.kAnimal 
				and AnimalTypeConfig.isColorTypeValid(item._encrypt.ItemColorType) 
				and item.ItemSpecialType == 0 
				and not item:hasFurball() 
				and not item:hasLock()
				and item:isAvailable() then
				----普通动物
				counts = counts + 1
				mainLogic.randomAnimalHelpList[counts] = IntCoord:create(r,c)
			end
		end
	end
end

function BombItemLogic:getRandomAnimalChangeToLineSpecial(mainLogic)
	if #mainLogic.randomAnimalHelpList == 0 then
		return nil
	end

	local rid = mainLogic.randFactory:rand(1, #mainLogic.randomAnimalHelpList);
	local pos = mainLogic.randomAnimalHelpList[rid]
	local ret = IntCoord:create(pos.x, pos.y)
	table.remove(mainLogic.randomAnimalHelpList, rid)
	return ret
end

function BombItemLogic:forceClearItemInOlympicMode(mainLogic, r, c, SpecialID)
	local board = mainLogic.boardmap[r][c]
	local item = mainLogic.gameItemMap[r][c]

	if not board.isUsed or not item.isUsed then return end

	local function clearItem( r, c , times, bomb, special)

		local clearItem = mainLogic.gameItemMap[r][c]
		local clearBoard = mainLogic.boardmap[r][c]

		if clearItem.ItemType == GameItemType.kBlackCuteBall or clearItem.furballType == GameItemFurballType.kBrown then
			clearItem:cleanAnimalLikeData()
			clearItem.isNeedUpdate = true
			mainLogic:checkItemBlock(r,c)
		else
			times = times + clearItem.cageLevel

			if clearItem.snowLevel > 0 then
				times = times + clearItem.snowLevel - 1
			end

			for i=1, times do
				if bomb then
					BombItemLogic:tryCoverByBomb(mainLogic, r, c, true, 1, true, true)
				end
				if special then
					SpecialCoverLogic:SpecialCoverAtPos(mainLogic, r, c, 0, nil, nil, true, true, nil, SpecialID) 
				end
			end
		end
		
	end
	-- del all ices
	if board.iceLevel > 0 then
		for i = 1, board.iceLevel do
			GameExtandPlayLogic:decIceLevelAt(mainLogic, r, c)
		end
	end
	-- del all olympicLock
	if item.olympicLockLevel > 0 then
		for i = 1, item.olympicLockLevel do
			GameExtandPlayLogic:decreaseOlympicLock(mainLogic, r, c)
		end
	end
	-- del all olympicBlocker
	if item.ItemType == GameItemType.kOlympicBlocker then
		for i = 1, item.olympicBlockerLevel do
			GameExtandPlayLogic:decreaseOlympicBlocker(mainLogic, r, c)
		end
	end

	clearItem(r, c, 1, true, true)
end

function BombItemLogic:forceClearItemWithCover(mainLogic , r, c, SpecialID)
	local gameItemMap = mainLogic.gameItemMap
	local item = nil
	if gameItemMap and gameItemMap[r] and gameItemMap[r][c] then
		item = gameItemMap[r][c]
	end

	local function clearItem( r, c , times, bomb, special)
		for i=1, times do
			if bomb then
				BombItemLogic:tryCoverByBomb(mainLogic, r, c, true, 1, true, true)
			end
			if special then
				SpecialCoverLogic:SpecialCoverAtPos(mainLogic, r, c, 0, nil, nil, true, true, nil, SpecialID ) 
			end
		end
	end

	if item then
		if item.ItemType == GameItemType.kDigGround then
			--[[
			clearItem(item.digGroundLevel , false , true)
			]]
			for i = 1, item.digGroundLevel do
				if item.digGroundLevel > 0 then
					--if item.digBlockCanbeDelete then
						GameExtandPlayLogic:decreaseDigGround(mainLogic, r, c, 1, true)
					--end
				end
			end

		elseif item.ItemType == GameItemType.kDigJewel then
			for i = 1, item.digJewelLevel do
				if item.digJewelLevel > 0 then
					--if item.digBlockCanbeDelete then
						GameExtandPlayLogic:decreaseDigJewel(mainLogic, r, c, nil, true, true)
					--end
				end
			end
		elseif item.ItemType == GameItemType.kRandomProp then
			for i = 1, item.randomPropLevel do
				if item.randomPropLevel > 0 then
					--if item.digBlockCanbeDelete then
						GameExtandPlayLogic:hitRandomProp(mainLogic, r, c, nil, true, true)
					--end
				end
			end
        elseif item.ItemType == GameItemType.kYellowDiamondGrass then
			for i = 1, item.yellowDiamondLevel do
				if item.yellowDiamondLevel > 0 then
					--if item.digBlockCanbeDelete then
						GameExtandPlayLogic:decreaseYellowDiamond(mainLogic, r, c, nil, true, true)
					--end
				end
			end
		else				
			clearItem(r, c, 1, true, true)					
		end			
	end
end

function BombItemLogic:clearItemWithoutCover(mainLogic , r, c)
	local gameItemMap = mainLogic.gameItemMap
	local item = nil
	if gameItemMap and gameItemMap[r] and gameItemMap[r][c] then
		item = gameItemMap[r][c]
	end

	local function clearItem( r, c , times, bomb, special)
		for i=1, times do
			if bomb then
				BombItemLogic:tryCoverByBomb(mainLogic, r, c, true, 1.5, true, false)
			end
			if special then
				--SpecialCoverLogic:SpecialCoverAtPos(mainLogic, r, c, 0, nil, nil, true, true) 
			end

			SpecialCoverLogic:SpecialCoverLightUpAtPos(mainLogic, r, c, 1.5, true)
			SpecialCoverLogic:specialCoverChainsAtPos(mainLogic, r , c)

			if SpecialCoverLogic:canBeEffectBySpecialAt(mainLogic, r, c) then
				SpecialCoverLogic:effectBlockerAt(mainLogic, r, c, 1.5 , nil , false, false)
			end
		end
	end
	clearItem(r, c, 1, true, false)	
	--[[
	if item then
		if item.ItemType == GameItemType.kDigGround then
			if item.digGroundLevel > 0 then
				--if item.digBlockCanbeDelete then
					GameExtandPlayLogic:decreaseDigGround(mainLogic, r, c, 1, true)
				--end
			end
		elseif item.ItemType == GameItemType.kDigJewel then
			if item.digJewelLevel > 0 then
				--if item.digBlockCanbeDelete then
					GameExtandPlayLogic:decreaseDigJewel(mainLogic, r, c, nil, true, true)
				--end
			end
		else				
			clearItem(r, c, 1, true, false)					
		end			
	end
	]]
end

function BombItemLogic:springFestivalBombScreen(mainLogic)

	local function bombItemMultiTimes(r, c, times, bomb, special)
		for i=1, times do
			-- SpecialCoverLogic:SpecialCoverLightUpAtPos(mainLogic, r, c, 1, true)
			if bomb then
				BombItemLogic:tryCoverByBomb(mainLogic, r, c, true, 1, nil, true)
			end
			if special then
				SpecialCoverLogic:SpecialCoverAtPos(mainLogic, r, c, 0, nil, nil, true, true) 
			end
		end
	end

	local function bombJewel(mainLogic, r, c)
		local item = mainLogic.gameItemMap[r][c]
		if item.digJewelLevel > 0 then
			if item.digBlockCanbeDelete then
				GameExtandPlayLogic:decreaseDigJewel(mainLogic, r, c, nil, true, true)
			end
		end
	end

    local function bombYellowDiamond(mainLogic, r, c)
		local item = mainLogic.gameItemMap[r][c]
		if item.yellowDiamondLevel > 0 then
			if item.yellowDiamondCanbeDelete then
				GameExtandPlayLogic:decreaseYellowDiamond(mainLogic, r, c, nil, true, true)
			end
		end
	end

	local gameItemMap = mainLogic.gameItemMap
	for r = 1, #gameItemMap do
		for c = 1, #gameItemMap[r] do
			local item = gameItemMap[r][c]

			if item.ItemType == GameItemType.kDigGround then
				bombItemMultiTimes(r, c, item.digGroundLevel, false, true)
			elseif item.ItemType == GameItemType.kDigJewel then
				-- bombItemMultiTimes(r, c, item.digJewelLevel, false, true)
				for i = 1, item.digJewelLevel do
					bombJewel(mainLogic, r, c)
				end
			elseif item.ItemType == GameItemType.kRandomProp then
				for i = 1, item.randomPropLevel do
					local item2 = mainLogic.gameItemMap[r][c]
					if item2.randomPropLevel > 0 then
						if item2.digBlockCanbeDelete then
							GameExtandPlayLogic:hitRandomProp(mainLogic, r, c, nil, true, true)
						end
					end
				end
			elseif item.ItemType == GameItemType.kBoss and item.bossLevel > 0 then
				bombItemMultiTimes(r, c, item.blood, false, true)
			elseif item.ItemType == GameItemType.kWeeklyBoss and item.weeklyBossLevel > 0 then
				bombItemMultiTimes(r, c, item.blood, false, true)
			elseif item.ItemType == GameItemType.kMoleBossCloud and item.moleBossCloudLevel > 0 then
				bombItemMultiTimes(r, c, item.blood, false, true)
			elseif item.ItemType == GameItemType.kChestSquarePart or item.ItemType == GameItemType.kChestSquare then
				GameExtandPlayLogic:hitChestSquare(mainLogic,item,r,c,false,true )
            elseif item.ItemType == GameItemType.kYellowDiamondGrass then
				-- bombItemMultiTimes(r, c, item.digJewelLevel, false, true)
				for i = 1, item.yellowDiamondLevel do
					bombYellowDiamond(mainLogic, r, c)
				end
			else
				if item.honeyLevel > 0 then
					bombItemMultiTimes(r, c, item.honeyLevel, true, true)	
				else
					bombItemMultiTimes(r, c, 1, true, true)	
				end		
			end			
		end
	end
end