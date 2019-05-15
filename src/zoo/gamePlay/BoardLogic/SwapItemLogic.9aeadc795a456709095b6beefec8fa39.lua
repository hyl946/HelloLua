require "zoo.gamePlay.BoardAction.GameBoardActionDataSet"
require "zoo.gamePlay.BoardLogic.MatchItemLogic"
require "zoo.gamePlay.BoardLogic.SpecialMatchLogic"
----交换两个Item的逻辑-----
----mainLogic是GameBoardLogic
SwapItemLogic = class{}

PossibleSwapPriority = table.const{
	kSpecial1 = 3,		--特效+特效交换
	kSpecial2 = 10, 	--鸟和其它

	kNormal1 = 21, 		--普通动物 --横或者竖五连以上
	kNormal2 = 22, 		--普通动物 --横竖同时三连以上
	kNormal3 = 23, 		--普通动物 --横或者竖四连以上
	kXXP = 24,			--星星瓶
	kRSBB = 25,			--染色宝宝
	kNormal4 = 26, 		--普通动物 --横或者竖三连

	kNone = 100,
}

--可以被交换，但是不一定有匹配
function SwapItemLogic:canBeSwaped(mainLogic, r1,c1,r2,c2)
	return SwapItemLogic:_canBeSwaped(mainLogic.boardmap, mainLogic.gameItemMap, r1,c1,r2,c2)
end

function SwapItemLogic:_canBeSwaped(_boardmap, _gameItemMap, r1,c1,r2,c2)
	if (r1 == r2 and c1 == c2 + 1)
		or (r1 == r2 and c1 == c2 - 1)
		or (r1 == r2 + 1 and c1 == c2)
		or (r1 == r2 - 1 and c1 == c2)
		then

		local board1 = _boardmap[r1][c1];
		local board2 = _boardmap[r2][c2];
		local item1 = _gameItemMap[r1][c1];
		local item2 = _gameItemMap[r2][c2];

		--相邻两个Item
		if item1:canBeSwap() and item2:canBeSwap() then
			------判断绳子&冰柱
			if (r1 == r2 and c1 == c2 + 1) then ----2左1右
				if board1:hasLeftRope() or board2:hasRightRope() then
					return 2;
				end
			end
			if (r1 == r2 and c1 == c2 - 1) then ----1左2右
				if board1:hasRightRope() or board2:hasLeftRope() then
					return 2;
				end
			end
			if (r1 == r2 + 1 and c1 == c2) then ----2上1下
				if board1:hasTopRope() or board2:hasBottomRope() then
					return 2;
				end
			end
			if (r1 == r2 - 1 and c1 == c2) then ----1上2下
				if board1:hasBottomRope() or board2:hasTopRope() then
					return 2;
				end
			end

			return 1
		end
	end
	return 0
end

local function checkItemBlock(mainLogic, item1, item2, r1, c1, r2, c2)--重新计算格子的block状态
	if item1.ItemType == GameItemType.kMagicLamp or item2.ItemType == GameItemType.kMagicLamp 
		or item1.ItemType == GameItemType.kWukong or item2.ItemType == GameItemType.kWukong
		or item1.ItemType == GameItemType.kBlocker199 or item2.ItemType == GameItemType.kBlocker199
		or item1.ItemType == GameItemType.kPacman or item2.ItemType == GameItemType.kPacman
		or item1:seizedByGhost() or item2:seizedByGhost()
		then
		mainLogic:checkItemBlock(r1, c1)
		mainLogic:checkItemBlock(r2, c2)
		FallingItemLogic:preUpdateHelpMap(mainLogic)
	end
end 

local function swapItemData(item1, item2)
	local item1Clone = item1:copy()
	local item2Clone = item2:copy()
	item1:getAnimalLikeDataFrom(item2Clone)
	item2:getAnimalLikeDataFrom(item1Clone)
end

--交换两个Item--并且尝试匹配消除
function SwapItemLogic:SwapedItemAndMatch(mainLogic, r1, c1, r2, c2, doSwap)	--doSwap==true表示确实进行交换，并且引起相应效果，doSwap==false表示仅仅判断是否能够交换
	--染色宝宝交换
	local st = SwapItemLogic:_trySwapedCrystalStone(mainLogic, r1, c1, r2, c2, doSwap)
	if st then
		local possbileMoves = {{{ r = r1, c = c1 }, { r = r2, c = c2 }, dir = { r = r2 - r1, c = c2 - c1 } }}
		if doSwap then
			GamePlayContext:getInstance():updateLastSwapInfo( r1, c1, r2, c2 )
			mainLogic.modeProcessor:doProcessorOnSwapFinish()
		end
		return true, possbileMoves, PossibleSwapPriority.kRSBB
	end
	--星星瓶交换
	st = SwapItemLogic:_trySwapedBlocker195(mainLogic, r1, c1, r2, c2, doSwap)
	if st then
		local possbileMoves = {{{ r = r1, c = c1 }, { r = r2, c = c2 }, dir = { r = r2 - r1, c = c2 - c1 } }}
		if doSwap then
			GamePlayContext:getInstance():updateLastSwapInfo( r1, c1, r2, c2 )
			mainLogic.modeProcessor:doProcessorOnSwapFinish()
		end
		return true, possbileMoves, PossibleSwapPriority.kXXP
	end
	
	--1.特效交换	
	st, matchPriority = SwapItemLogic:_trySwapedSpecialItem(mainLogic, r1,c1,r2,c2, doSwap)
	if st then--能够进行特效交换
		local possbileMoves = {{{ r = r1, c = c1 }, { r = r2, c = c2 }, dir = { r = r2 - r1, c = c2 - c1 } }}
		if doSwap then
			GamePlayContext:getInstance():updateLastSwapInfo( r1, c1, r2, c2 )
			mainLogic.modeProcessor:doProcessorOnSwapFinish()
		end
		return true, possbileMoves, matchPriority
	end
	--其他交换
	local st1, possbileMoves, matchPriority = SwapItemLogic:_trySwapedMatchItem(mainLogic, r1, c1, r2, c2, doSwap)
	if st1 then---能够进行普通交换
		if doSwap then
			------2.交换后的动作
			mainLogic.gameMode:checkDropDownCollect(r1, c1)
			mainLogic.gameMode:checkDropDownCollect(r2, c2)
		end
		if doSwap then
			GamePlayContext:getInstance():updateLastSwapInfo( r1, c1, r2, c2 )
			mainLogic.modeProcessor:doProcessorOnSwapFinish()
		end
		return true, possbileMoves, matchPriority
	end
	return false
end

function SwapItemLogic:_trySwapedDrip(mainLogic, r1, c1, r2, c2, doSwap)
	local item1 = mainLogic.gameItemMap[r1][c1]
	local item2 = mainLogic.gameItemMap[r2][c2]

	if item1.ItemType == GameItemType.kDrip or item2.ItemType == GameItemType.kDrip then
		local sp1 = item1.ItemSpecialType
		local sp2 = item2.ItemSpecialType
		local color1 = item1._encrypt.ItemColorType
		local color2 = item2._encrypt.ItemColorType

		if sp1 == AnimalTypeConfig.kColor and item2.ItemType == GameItemType.kCrystalStone then
			if doSwap then 
				if item2:isActiveCrystalStoneAvailble() then
					SpecialMatchLogic:CrystalStoneWithBird(mainLogic, r2, c2, r1, c1)
				else
					SpecialMatchLogic:BirdColorSwapBomb(mainLogic, r1, c1, r2, c2) 
				end
			end
		elseif sp2 == AnimalTypeConfig.kColor and item1.ItemType == GameItemType.kCrystalStone then
			if doSwap then 
				if item1:isActiveCrystalStoneAvailble() then
					SpecialMatchLogic:CrystalStoneWithBird(mainLogic, r1, c1, r2, c2)
				else
					SpecialMatchLogic:BirdColorSwapBomb(mainLogic, r2, c2, r1, c1) 
				end
			end
		elseif item1.ItemType == GameItemType.kCrystalStone and item1:isActiveCrystalStoneAvailble() and item2:canBeCoverByCrystalStone() then
			if doSwap then 
				if sp2 == AnimalTypeConfig.kWrap then
					SpecialMatchLogic:CrystalStoneWithWrap(mainLogic, r1, c1, r2, c2)
				elseif (sp2 == AnimalTypeConfig.kLine or sp2 == AnimalTypeConfig.kColumn) then
					SpecialMatchLogic:CrystalStoneWithLine(mainLogic, r1, c1, r2, c2)
				else
					SpecialMatchLogic:CrystalStoneWithColor(mainLogic, r1, c1, r2, c2)
				end
			end
		elseif item2.ItemType == GameItemType.kCrystalStone and item2:isActiveCrystalStoneAvailble() and item1:canBeCoverByCrystalStone() then
			if doSwap then 
				if sp1 == AnimalTypeConfig.kWrap then
					SpecialMatchLogic:CrystalStoneWithWrap(mainLogic, r2, c2, r1, c1)
				elseif (sp1 == AnimalTypeConfig.kLine or sp1 == AnimalTypeConfig.kColumn) then
					SpecialMatchLogic:CrystalStoneWithLine(mainLogic, r2, c2, r1, c1)
				else
					SpecialMatchLogic:CrystalStoneWithColor(mainLogic, r2, c2, r1, c1)
				end
			end
		elseif item2.ItemType == GameItemType.kCrystalStone and item2:isActiveCrystalStoneAvailble() 
			and item1.ItemType == GameItemType.kCrystalStone and item1:isActiveCrystalStoneAvailble() then
			if doSwap then
				SpecialMatchLogic:CrystalStoneWithCrystalStone(mainLogic, r1, c1, r2, c2)
			end
		else
			return false
		end

		if doSwap then
			swapItemData(item1, item2)
			checkItemBlock(mainLogic, item1, item2, r1, c1, r2, c2)
		end
		return true


	end

	return false
end

function SwapItemLogic:_trySwapedCrystalStone(mainLogic, r1, c1, r2, c2, doSwap)
	local item1 = mainLogic.gameItemMap[r1][c1]
	local item2 = mainLogic.gameItemMap[r2][c2]

	if item1:seizedByGhost() or item2:seizedByGhost() then return false end

	if item1.ItemType == GameItemType.kCrystalStone or item2.ItemType == GameItemType.kCrystalStone then
		local sp1 = item1.ItemSpecialType
		local sp2 = item2.ItemSpecialType
		local color1 = item1._encrypt.ItemColorType
		local color2 = item2._encrypt.ItemColorType

		if sp1 == AnimalTypeConfig.kColor and item2.ItemType == GameItemType.kCrystalStone then
			if doSwap then 
				if item2:isActiveCrystalStoneAvailble() then
					SpecialMatchLogic:CrystalStoneWithBird(mainLogic, r2, c2, r1, c1)
				else
					SpecialMatchLogic:BirdColorSwapBomb(mainLogic, r1, c1, r2, c2) 
				end
			end
		elseif sp2 == AnimalTypeConfig.kColor and item1.ItemType == GameItemType.kCrystalStone then
			if doSwap then 
				if item1:isActiveCrystalStoneAvailble() then
					SpecialMatchLogic:CrystalStoneWithBird(mainLogic, r1, c1, r2, c2)
				else
					SpecialMatchLogic:BirdColorSwapBomb(mainLogic, r2, c2, r1, c1) 
				end
			end
		elseif item1.ItemType == GameItemType.kCrystalStone and item1:isActiveCrystalStoneAvailble() and item2:canBeCoverByCrystalStone() then
			if doSwap then 
				if sp2 == AnimalTypeConfig.kWrap then
					SpecialMatchLogic:CrystalStoneWithWrap(mainLogic, r1, c1, r2, c2)
				elseif (sp2 == AnimalTypeConfig.kLine or sp2 == AnimalTypeConfig.kColumn) then
					SpecialMatchLogic:CrystalStoneWithLine(mainLogic, r1, c1, r2, c2)
				else
					SpecialMatchLogic:CrystalStoneWithColor(mainLogic, r1, c1, r2, c2)
				end
			end
		elseif item2.ItemType == GameItemType.kCrystalStone and item2:isActiveCrystalStoneAvailble() and item1:canBeCoverByCrystalStone() then
			if doSwap then 
				if sp1 == AnimalTypeConfig.kWrap then
					SpecialMatchLogic:CrystalStoneWithWrap(mainLogic, r2, c2, r1, c1)
				elseif (sp1 == AnimalTypeConfig.kLine or sp1 == AnimalTypeConfig.kColumn) then
					SpecialMatchLogic:CrystalStoneWithLine(mainLogic, r2, c2, r1, c1)
				else
					SpecialMatchLogic:CrystalStoneWithColor(mainLogic, r2, c2, r1, c1)
				end
			end
		elseif item2.ItemType == GameItemType.kCrystalStone and item2:isActiveCrystalStoneAvailble() 
			and item1.ItemType == GameItemType.kCrystalStone and item1:isActiveCrystalStoneAvailble() then
			if doSwap then
				SpecialMatchLogic:CrystalStoneWithCrystalStone(mainLogic, r1, c1, r2, c2)
			end
		else
			return false
		end

		if doSwap then
			swapItemData(item1, item2)
			checkItemBlock(mainLogic, item1, item2, r1, c1, r2, c2)
		end
		return true
	end

	return false
end

function SwapItemLogic:_trySwapedBlocker195(mainLogic, r1, c1, r2, c2, doSwap)
	local item1 = mainLogic.gameItemMap[r1][c1]
	local item2 = mainLogic.gameItemMap[r2][c2]

	if item1:seizedByGhost() and item2:seizedByGhost() then return false end

	if item1:isBlocker195Available() or item2:isBlocker195Available() then
		if item2:isBlocker195Available() then--交换数据省去多次判断
			item1, item2 = item2, item1
			r1, r2 = r2, r1
			c1, c2 = c2, c1
		end

		if item2:isFreeGhost() then
			if doSwap then
				SpecialMatchLogic:Blocker195WithSwap(mainLogic, GameItemActionType.kItemSpecial_Blocker195_Ghost, r1, c1, r2, c2)
			end
		elseif table.exist({GameItemType.kCrystal, GameItemType.kAddMove, GameItemType.kAddTime}, item2.ItemType) or (item2.ItemType == GameItemType.kAnimal and item2.ItemSpecialType == 0) then
			if doSwap then
				SpecialMatchLogic:Blocker195WithSwap(mainLogic, GameItemActionType.kItemSpecial_Blocker195_Color, r1, c1, r2, c2)
			end
		elseif table.exist({AnimalTypeConfig.kLine, AnimalTypeConfig.kColumn}, item2.ItemSpecialType)   then
			if doSwap then
				SpecialMatchLogic:BirdLineSwapBomb(mainLogic, r1, c1, r2, c2)
			end
		elseif item2.ItemSpecialType == AnimalTypeConfig.kWrap then
			if doSwap then
				SpecialMatchLogic:BirdWrapSwapBomb(mainLogic, r1, c1, r2, c2)
			end
		elseif item2:isActiveCrystalStoneAvailble() or item2:isBlocker195Available() or item2.ItemSpecialType == AnimalTypeConfig.kColor then
			if doSwap then
				SpecialMatchLogic:MatchBirdBird(mainLogic, r1, c1, r2, c2)
			end
		elseif table.exist({GameItemType.kGift, GameItemType.kNewGift, GameItemType.kBalloon, GameItemType.kMagicLamp, 
			GameItemType.kScoreBuffBottle, GameItemType.kFirecracker}, item2.ItemType) then
			if doSwap then
				SpecialMatchLogic:Blocker195WithSwap(mainLogic, GameItemActionType.kItemSpecial_Blocker195_Kind_Color, r1, c1, r2, c2)
			end 
		elseif item2.ItemType == GameItemType.kCrystalStone and not item2:isActiveCrystalStoneAvailble() then
			if doSwap then
				SpecialMatchLogic:Blocker195WithSwap(mainLogic, GameItemActionType.kItemSpecial_Blocker195_Kind_Color, r1, c1, r2, c2)
			end 
		elseif item2.ItemType == GameItemType.kTotems and item2.totemsState == GameItemTotemsState.kNone then
			if doSwap then
				SpecialMatchLogic:Blocker195WithSwap(mainLogic, GameItemActionType.kItemSpecial_Blocker195_Kind_Color, r1, c1, r2, c2)
			end
		elseif item2:isBlocker199Active() then
			if doSwap then
				SpecialMatchLogic:Blocker195WithSwap(mainLogic, GameItemActionType.kItemSpecial_Blocker195_Kind_Color, r1, c1, r2, c2)
			end
		elseif item2.ItemType == GameItemType.kCoin then
			if doSwap then
				SpecialMatchLogic:Blocker195WithSwap(mainLogic, GameItemActionType.kItemSpecial_Blocker195_Coin, r1, c1, r2, c2)
			end
		elseif item2.ItemType == GameItemType.kHoneyBottle then
			if doSwap then
				SpecialMatchLogic:Blocker195WithSwap(mainLogic, GameItemActionType.kItemSpecial_Blocker195_HoneyBottle, r1, c1, r2, c2)
			end
		elseif item2.ItemType == GameItemType.kMissile then
			if doSwap then
				SpecialMatchLogic:Blocker195WithSwap(mainLogic, GameItemActionType.kItemSpecial_Blocker195_Missile, r1, c1, r2, c2)
			end
		elseif item2.ItemType == GameItemType.kPuffer then
			if doSwap then
				SpecialMatchLogic:Blocker195WithSwap(mainLogic, GameItemActionType.kItemSpecial_Blocker195_Puffer, r1, c1, r2, c2)
			end
		elseif item2.ItemType == GameItemType.kBlocker207 then
			if doSwap then
				SpecialMatchLogic:Blocker195WithSwap(mainLogic, GameItemActionType.kItemSpecial_Blocker195_Blocker207, r1, c1, r2, c2)
			end
        elseif item2.ItemType == GameItemType.kWanSheng then
			if doSwap then
				SpecialMatchLogic:Blocker195WithSwap(mainLogic, GameItemActionType.kItemSpecial_Blocker195_WanSheng, r1, c1, r2, c2)
			end
		else
			return false
		end

		if doSwap then
			swapItemData(item1, item2)
			checkItemBlock(mainLogic, item1, item2, r1, c1, r2, c2)
		end
		return true
	end

	return false
end

--尝试交换两个特效
function SwapItemLogic:_trySwapedSpecialItem(mainLogic, r1,c1,r2,c2, doSwap)--doSwap==true表示确实进行交换，并且引起相应效果，doSwap==false表示仅仅判断是否能够交换
	local item1 = mainLogic.gameItemMap[r1][c1]
	local item2 = mainLogic.gameItemMap[r2][c2]
	local sp1 = item1.ItemSpecialType
	local sp2 = item2.ItemSpecialType
	local color1 = item1._encrypt.ItemColorType
	local color2 = item2._encrypt.ItemColorType

	if item1:seizedByGhost() or item2:seizedByGhost() then return false end

	local function swapAndCheck()
		swapItemData(item1, item2)
		checkItemBlock(mainLogic, item1, item2, r1, c1, r2, c2)
	end
	
	if AnimalTypeConfig.isSpecialTypeValid(sp1) and AnimalTypeConfig.isSpecialTypeValid(sp2) then
		--两个都是特效
		if doSwap then ----------确实要交换
			if sp1 == sp2 and sp1 == AnimalTypeConfig.kColor then 		--鸟+鸟特效
				SpecialMatchLogic:MatchBirdBird(mainLogic, r1, c1, r2, c2) 
			elseif sp1 == AnimalTypeConfig.kColor and sp2 == AnimalTypeConfig.kWrap then 	--鸟+区域特效
				SpecialMatchLogic:BirdWrapSwapBomb(mainLogic, r1, c1, r2, c2)
			elseif sp2 == AnimalTypeConfig.kColor and sp1 == AnimalTypeConfig.kWrap then 	--鸟+区域特效
				SpecialMatchLogic:BirdWrapSwapBomb(mainLogic, r2, c2, r1, c1)
			elseif sp1 == AnimalTypeConfig.kColor and (sp2 == AnimalTypeConfig.kLine or sp2 == AnimalTypeConfig.kColumn) then 	--鸟+直线特效
				SpecialMatchLogic:BirdLineSwapBomb(mainLogic, r1, c1, r2, c2)
			elseif sp2 == AnimalTypeConfig.kColor and (sp1 == AnimalTypeConfig.kLine or sp1 == AnimalTypeConfig.kColumn) then 	--鸟+直线特效
				SpecialMatchLogic:BirdLineSwapBomb(mainLogic, r2, c2, r1, c1)
			elseif sp1 == AnimalTypeConfig.kWrap and sp2 == AnimalTypeConfig.kWrap then 	--区域+区域特效
				SpecialMatchLogic:WrapWrapSwapBomb(mainLogic, r1, c1, r2, c2)
			elseif sp1 == AnimalTypeConfig.kWrap and (sp2 == AnimalTypeConfig.kLine or sp2 == AnimalTypeConfig.kColumn) then 		--区域+直线特效
				SpecialMatchLogic:WrapLineSwapBomb(mainLogic, r1, c1, r2, c2)
			elseif sp2 == AnimalTypeConfig.kWrap and (sp1 == AnimalTypeConfig.kLine or sp1 == AnimalTypeConfig.kColumn) then 		--区域+直线特效
				SpecialMatchLogic:WrapLineSwapBomb(mainLogic, r2, c2, r1, c1)
			elseif (sp1 == AnimalTypeConfig.kLine or sp1 == AnimalTypeConfig.kColumn) 
				and (sp2 == AnimalTypeConfig.kLine or sp2 == AnimalTypeConfig.kColumn) then --直线+直线
				SpecialMatchLogic:LineLineSwapBomb(mainLogic, r1, c1, r2, c2)
			end
			swapAndCheck()
		end
		return true, PossibleSwapPriority.kSpecial1
	end

	if sp1 == AnimalTypeConfig.kColor and AnimalTypeConfig.isColorTypeValid(color2) and color ~= AnimalTypeConfig.kDrip then 			--鸟+颜色
		if doSwap then 
			SpecialMatchLogic:BirdColorSwapBomb(mainLogic, r1, c1, r2, c2) 
			swapAndCheck()
		end
		return true, PossibleSwapPriority.kSpecial2
	elseif sp2 == AnimalTypeConfig.kColor and AnimalTypeConfig.isColorTypeValid(color1) and color ~= AnimalTypeConfig.kDrip then 		--鸟+颜色
		if doSwap then 
			SpecialMatchLogic:BirdColorSwapBomb(mainLogic, r2, c2, r1, c1) 
			swapAndCheck()
		end
		return true, PossibleSwapPriority.kSpecial2
	end

	return false
end

--判断是否有match
function SwapItemLogic:_trySwapedMatchItem(mainLogic, r1, c1, r2, c2, doSwap)	--doSwap:Boolean，false表示仅判断是否能交换
	local data1 = mainLogic.gameItemMap[r1][c1]
	local data2 = mainLogic.gameItemMap[r2][c2]
	local color1 = data1._encrypt.ItemColorType
	local color2 = data2._encrypt.ItemColorType
	if data1:seizedByGhost() then color1 = 0 end
	if data2:seizedByGhost() then color2 = 0 end

	if (color1 == color2) and data1:canBeCoverByMatch() and data2:canBeCoverByMatch() then --同样的颜色交换，没有意义
 		return false 
	end
	--1.临时性颜色交换
	local item1Clone = data1:copy()
	local item2Clone = data2:copy()
	data2:getAnimalLikeDataFrom(item1Clone)
	data1:getAnimalLikeDataFrom(item2Clone)

	--2.对Item(x,y)进行检查
	MatchItemLogic:cleanSwapHelpMap(mainLogic)
	local ts1, possibleMove1, matchType1 = MatchItemLogic:checkMatchStep1(mainLogic, r1,c1,color2, doSwap)
	local ts2, possibleMove2, matchType2 = MatchItemLogic:checkMatchStep1(mainLogic, r2,c2,color1, doSwap)
	matchType1 = matchType1 or 9999
	matchType2 = matchType2 or 9999
	local possibleMoves = {}

	if ts1 then
		possibleMove1 = table.union({{ r = r2, c = c2 }}, possibleMove1)
		possibleMove1["dir"] = { r = r1 - r2, c = c1 - c2 }
		table.insert(possibleMoves, possibleMove1)
	end

	if ts2 then
		possibleMove2 = table.union({{ r = r1, c = c1 }}, possibleMove2)
		possibleMove2["dir"] = { r = r2 - r1, c = c2 - c1 }
		table.insert(possibleMoves, possibleMove2)
	end

	if ts1 or ts2 then
		----成功合成
		----开始修改数据
		if doSwap then
			-- data1.isNeedUpdate = true
			-- data2.isNeedUpdate = true
			mainLogic:addNeedCheckMatchPoint(r1, c1)
			mainLogic:addNeedCheckMatchPoint(r2, c2)

			checkItemBlock(mainLogic, data1, data2, r1, c1, r2, c2)
		else
			----不是真实交换，所以颜色数据返还
			data1:getAnimalLikeDataFrom(item1Clone)
			data2:getAnimalLikeDataFrom(item2Clone)
			--data1.isNeedUpdate = false
			--data2.isNeedUpdate = false
			if not data1.forceUpdate then data1.isNeedUpdate = false end
			if not data2.forceUpdate then data2.isNeedUpdate = false end
		end
		----清理帮助数组
		MatchItemLogic:cleanSwapHelpMap(mainLogic)
		local matchType 
		if matchType1 < matchType2 then 
			matchType = matchType1
		else
			matchType = matchType2
		end
		return true, possibleMoves, matchType
	else
		--回调颜色
		data1:getAnimalLikeDataFrom(item1Clone)
		data2:getAnimalLikeDataFrom(item2Clone)
		if not data1.forceUpdate then data1.isNeedUpdate = false end
		if not data2.forceUpdate then data2.isNeedUpdate = false end
		--data1.isNeedUpdate = false
		--data2.isNeedUpdate = false
		return false
	end
end

--param priorityTable可传入已定义好的（PossibleSwapPriority）优先级table 推荐交换时可以只从其中筛选 暂时没用上
function SwapItemLogic:calculatePossibleSwap(mainLogic, priorityTable, needAll)
	if priorityTable then 
		assert(type(priorityTable) == "table", "param 2 must be a table")
	end
	local mainPriorityTable = {}
	if priorityTable and #priorityTable > 0 then 
		for k,v in pairs(priorityTable) do
			if table.keyOf(PossibleSwapPriority, v) then 
				table.insert(mainPriorityTable, v)
			end
		end
	end
	if #mainPriorityTable == 0 then 
		for k,v in pairs(PossibleSwapPriority) do
			table.insert(mainPriorityTable, v)
		end
	end

	local result = {}
	--值越小 优先级越高
	local maxPriority = nil
	local function insertPossibleMoves(priority, possbileMoves)
		if not table.includes(mainPriorityTable, priority) then return end
		if needAll then 
			result = table.union(result, possbileMoves)
			return
		end
		if not maxPriority then 
			maxPriority = priority
		elseif maxPriority > priority then 
			maxPriority = priority
		end
		if maxPriority == priority then 
			if not result[maxPriority] then 
				result[maxPriority] = {}
			end
			result[maxPriority] = table.union(result[maxPriority], possbileMoves)
		end
	end

	for r = 1, #mainLogic.gameItemMap do
		for c = 1, #mainLogic.gameItemMap[r] do
			local r1 = r
			local c1 = c
			local r2 = r
			local c2 = c + 1
			local r3 = r + 1
			local c3 = c

			if c2 <= #mainLogic.gameItemMap[r] and SwapItemLogic:canBeSwaped(mainLogic, r1, c1, r2, c2) == 1 then
				local st1, possbileMoves, pLv = SwapItemLogic:SwapedItemAndMatch(mainLogic, r1, c1, r2, c2, false) 
				if st1 then
					insertPossibleMoves(pLv, possbileMoves)
				end
			end
			if r3 <= #mainLogic.gameItemMap and SwapItemLogic:canBeSwaped(mainLogic, r1, c1, r3, c3) == 1 then
				local st2, possbileMoves, pLv = SwapItemLogic:SwapedItemAndMatch(mainLogic, r1, c1, r3, c3, false)
				if st2 then
					insertPossibleMoves(pLv, possbileMoves)
				end
			end
		end
	end

	if needAll then 
		return result
	end

	return result[maxPriority] or {}, maxPriority
end