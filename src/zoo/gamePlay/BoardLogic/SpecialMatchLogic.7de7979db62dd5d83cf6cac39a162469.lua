require "zoo.gamePlay.BoardLogic.BombItemLogic"
---------
-----特效交换逻辑
SpecialMatchLogic = class{}

SpecialMatchType = {
	kLineLine = 1,
	kWrapLine = 2,
	kWrapWrap = 3,
	kColorAnimal = 4,
	kColorWrap = 5,
	kColorLine = 6,
	kColorColor = 7,
}

-- 星星瓶 +（染色宝宝|星星瓶|魔力鸟）也会走这个逻辑
function SpecialMatchLogic:MatchBirdBird(mainLogic, r1,c1,r2,c2)
	local item1 = mainLogic.gameItemMap[r1][c1]
	local item2 = mainLogic.gameItemMap[r2][c2]
	local color2 = item2._encrypt.ItemColorType

	local ColorAction = GameBoardActionDataSet:createAs(
		GameActionTargetType.kGameItemAction,
		GameItemActionType.kItemSpecial_ColorColor_part1,
		IntCoord:create(r2,c2), 			----交换之后的魔力鸟1位置
		IntCoord:create(r1,c1),				----交换之后的魔力鸟2位置
		GamePlayConfig_SpecialBomb_BirdBird_Time1
		)
	ColorAction.addInfo = "Pass"
	ColorAction.addInt = color2 ----需要引爆的颜色
	ColorAction.addInt2 = 5
	mainLogic:addDestructionPlanAction(ColorAction)

	local birdCount = 0
	if item1.ItemSpecialType == AnimalTypeConfig.kColor then
		birdCount = birdCount + 1
		mainLogic:tryDoOrderList(r1,c1,GameItemOrderType.kSpecialBomb, GameItemOrderType_SB.kColor)
	elseif item1.ItemType == GameItemType.kBlocker195 then
		mainLogic:tryDoOrderList(r1,c1,GameItemOrderType.kOthers, GameItemOrderType_Others.kBlocker195)
	end

	if item2.ItemSpecialType == AnimalTypeConfig.kColor then
		birdCount = birdCount + 1
		mainLogic:tryDoOrderList(r2,c2,GameItemOrderType.kSpecialBomb, GameItemOrderType_SB.kColor)
	elseif item2.ItemType == GameItemType.kBlocker195 then
		mainLogic:tryDoOrderList(r2,c2,GameItemOrderType.kOthers, GameItemOrderType_Others.kBlocker195)
	end

	if birdCount == 2 then
		local keyname = "bird_bird_swap"
		GamePlayContext:getInstance():updatePlayInfo( keyname , 1 )
		mainLogic:tryDoOrderList(r1,c1,GameItemOrderType.kSpecialSwap, GameItemOrderType_SS.kColorColor)
	end

	GameExtandPlayLogic:doAllBlocker211Collect(mainLogic, r1, c1, 0, true, 3)
end

----鸟和区域特效交换
function SpecialMatchLogic:BirdWrapSwapBomb(mainLogic, r1, c1, r2, c2)
	local item1 = mainLogic.gameItemMap[r1][c1]		----鸟
	local item2 = mainLogic.gameItemMap[r2][c2]		----颜色
	local color2 = item2._encrypt.ItemColorType

	local keyname = "bird_wrap_swap"
	GamePlayContext:getInstance():updatePlayInfo( keyname , 1 )

	local ColorAction = GameBoardActionDataSet:createAs(
		GameActionTargetType.kGameItemAction,
		GameItemActionType.kItemSpecial_ColorWrap ,
		IntCoord:create(r2,c2), 			----交换之后的魔力鸟位置
		IntCoord:create(r1,c1),				----交换之后的普通物品位置
		GamePlayConfig_SpecialBomb_BirdLine_Time1
		)
	ColorAction.addInfo = "Pass"
	ColorAction.addInt = color2 ----需要引爆的颜色
	ColorAction.addInt2 = 4.5
	mainLogic:addDestructionPlanAction(ColorAction)
	if item1.ItemSpecialType == AnimalTypeConfig.kColor then
		mainLogic:tryDoOrderList(r2,c2,GameItemOrderType.kSpecialBomb, GameItemOrderType_SB.kColor)
		mainLogic:tryDoOrderList(r1,c1,GameItemOrderType.kSpecialSwap, GameItemOrderType_SS.kColorWrap)
	else
		mainLogic:tryDoOrderList(r2,c2,GameItemOrderType.kOthers, GameItemOrderType_Others.kBlocker195)
	end
	mainLogic:playEliminateMusic(GameMusicType.kSwapColorLine)
end

----鸟和直线特效交换
function SpecialMatchLogic:BirdLineSwapBomb(mainLogic, r1, c1, r2, c2)
	local item1 = mainLogic.gameItemMap[r1][c1]		----鸟
	local item2 = mainLogic.gameItemMap[r2][c2]		----颜色
	local color2 = item2._encrypt.ItemColorType

	local keyname = "bird_line_swap"
	GamePlayContext:getInstance():updatePlayInfo( keyname , 1 )

	local ColorAction = GameBoardActionDataSet:createAs(
		GameActionTargetType.kGameItemAction,
		GameItemActionType.kItemSpecial_ColorLine ,
		IntCoord:create(r2,c2), 			----交换之后的魔力鸟位置
		IntCoord:create(r1,c1),				----交换之后的普通物品位置
		GamePlayConfig_SpecialBomb_BirdLine_Time1
		)
	ColorAction.addInfo = "Pass"
	ColorAction.addInt = color2 ----需要引爆的颜色
	ColorAction.addInt2 = 4
	mainLogic:addDestructionPlanAction(ColorAction)
	if item1.ItemSpecialType == AnimalTypeConfig.kColor then
		mainLogic:tryDoOrderList(r2,c2,GameItemOrderType.kSpecialBomb, GameItemOrderType_SB.kColor)
		mainLogic:tryDoOrderList(r1,c1,GameItemOrderType.kSpecialSwap, GameItemOrderType_SS.kColorLine)
	else
		mainLogic:tryDoOrderList(r2,c2,GameItemOrderType.kOthers, GameItemOrderType_Others.kBlocker195)
	end
	mainLogic:playEliminateMusic(GameMusicType.kSwapColorLine)
end

----鸟和颜色交换
function SpecialMatchLogic:BirdColorSwapBomb(mainLogic, r1, c1, r2, c2)
	local item1 = mainLogic.gameItemMap[r1][c1]		----鸟
	local item2 = mainLogic.gameItemMap[r2][c2]		----颜色

	local keyname = "bird_color_swap"
	GamePlayContext:getInstance():updatePlayInfo( keyname , 1 )

	if item2.ItemType == GameItemType.kMagicLamp and item2.lampLevel > 0 and item2:isAvailable() then
		GameExtandPlayLogic:onChargeMagicLamp(mainLogic, r1, c1, 4)	----!!!:交换之后的普通物品位置
	elseif item2.ItemType == GameItemType.kWukong 
    		and item2.wukongProgressCurr < item2.wukongProgressTotal 
    		and ( item2.wukongState == TileWukongState.kNormal or item2.wukongState == TileWukongState.kOnHit )
    		and item2:isAvailable() and not mainLogic.isBonusTime then
		local action = GameBoardActionDataSet:createAs(
                    GameActionTargetType.kGameItemAction,
                    GameItemActionType.kItem_Wukong_Charging,
                    IntCoord:create(r1, c1),
                    nil,
                    GamePlayConfig_MaxAction_time
                )
		action.count = 3
		--mainLogic:addDestroyAction(action)
	    --产品需求，魔力鸟不额外获得能量（默认走SpecialCoverLogic的能量增加逻辑）
	end
	
	-- 鸟需要在此时就进入destroy状态,以免滞后几帧destroy产生掉落,当鸟与悬空的大眼怪交换时可复现此类问题
	item1:AddItemStatus(GameItemStatusType.kDestroy)
	
	local color2 = item2._encrypt.ItemColorType
	local ColorAction = GameBoardActionDataSet:createAs(
		GameActionTargetType.kGameItemAction,
		GameItemActionType.kItemSpecial_Color ,
		IntCoord:create(r2,c2), 			----交换之后的魔力鸟位置
		IntCoord:create(r1,c1),				----交换之后的普通物品位置
		GamePlayConfig_SpecialBomb_BirdAnimal_Time1
		)
	ColorAction.addInfo = "Pass"
	ColorAction.addInt = color2 ----需要引爆的颜色
	ColorAction.addInt2 = 2.5
	mainLogic:addDestructionPlanAction(ColorAction)
	mainLogic:tryDoOrderList(r1,c1,GameItemOrderType.kSpecialBomb, GameItemOrderType_SB.kColor)
	mainLogic:playEliminateMusic(GameMusicType.kEliminateColor)
end

-----直线特效交换爆炸
function SpecialMatchLogic:LineLineSwapBomb(mainLogic, r1, c1, r2, c2)
	local item1 = mainLogic.gameItemMap[r1][c1]
	local item2 = mainLogic.gameItemMap[r2][c2]
	local sp1 = item1.ItemSpecialType
	local sp2 = item2.ItemSpecialType

    local boardData1 = mainLogic.boardmap[r1][c1]
	local boardData2 = mainLogic.boardmap[r2][c2]

    if boardData1.isJamSperad or boardData2.isJamSperad then
        GameExtandPlayLogic:addJamSperadFlag(mainLogic, r1, c1, true )
        GameExtandPlayLogic:addJamSperadFlag(mainLogic, r2, c2, true )
    end

	-----1.计算分数
	local addScore = GamePlayConfigScore.SwapLineLine
	mainLogic:addScoreToTotal(r1, c1, addScore, item1._encrypt.ItemColorType)

	mainLogic:playEliminateMusic(GameMusicType.kSwapLineLine)

	-----2.引爆其他部分
	BombItemLogic:BombItemToChange(mainLogic, r1, c1, sp2, 1, 3, SpecialMatchType.kLineLine)
	BombItemLogic:BombItemToChange(mainLogic, r2, c2, sp1, 1, 3, SpecialMatchType.kLineLine)

	local keyname = "line_line_swap"
	GamePlayContext:getInstance():updatePlayInfo( keyname , 1 )

	mainLogic:tryDoOrderList(r1,c1,GameItemOrderType.kSpecialSwap, GameItemOrderType_SS.kLineLine)
end

function SpecialMatchLogic:WrapLineSwapBomb(mainLogic, r1, c1, r2, c2)
	local item1 = mainLogic.gameItemMap[r1][c1]
	local item2 = mainLogic.gameItemMap[r2][c2]
	local sp1 = item1.ItemSpecialType
	local sp2 = item2.ItemSpecialType

	local keyname = "line_wrap_swap"
	GamePlayContext:getInstance():updatePlayInfo( keyname , 1 )

	-----1.计算分数
	local addScore = GamePlayConfigScore.SwapLineWrap
	mainLogic:addScoreToTotal(r1, c1, addScore, item1._encrypt.ItemColorType)

	mainLogic:tryDoOrderList(r2,c2,GameItemOrderType.kSpecialBomb, GameItemOrderType_SB.kLine)
	GameExtandPlayLogic:doAllBlocker195Collect(mainLogic, r2, c2, Blocker195CollectType.kLine)
	SquidLogic:checkSquidCollectItem(mainLogic, r2, c2, SquidCollectType[1])
	mainLogic:tryDoOrderList(r1,c1,GameItemOrderType.kSpecialBomb, GameItemOrderType_SB.kWrap)
	GameExtandPlayLogic:doAllBlocker195Collect(mainLogic, r1, c1, Blocker195CollectType.kWrap)
	SquidLogic:checkSquidCollectItem(mainLogic, r1, c1, SquidCollectType[2])
	mainLogic:tryDoOrderList(r1,c1,GameItemOrderType.kSpecialSwap, GameItemOrderType_SS.kWrapLine)

    --果酱兼容
    local SpecialID = mainLogic:addSrcSpecialCoverToList( IntCoord:create(r1,c1), IntCoord:create(r2,c2) )
	
	-----2.引爆其他部分
	if sp2 == AnimalTypeConfig.kLine then
		if c2 == c1 - 1 then ------左
			BombItemLogic:BombItemToChange(mainLogic, r1 + 1, c1, sp2, 2, 3.5, SpecialMatchType.kWrapLine)
			BombItemLogic:BombItemToChange(mainLogic, r1, c1, sp2, 0, 3.5, SpecialMatchType.kWrapLine)
			BombItemLogic:BombItemToChange(mainLogic, r1 - 1, c1, sp2, 0, 3.5, SpecialMatchType.kWrapLine)
			BombItemLogic:BombItemToChange(mainLogic, r1 - 2, c1, sp2, 2, 3.5, SpecialMatchType.kWrapLine)

            if mainLogic:checkSrcSpecialCoverListIsHaveJamSperad(SpecialID) then
		        GameExtandPlayLogic:addJamSperadFlag(mainLogic,  r1 + 1, c1 )
                GameExtandPlayLogic:addJamSperadFlag(mainLogic,  r1, c1 )
                GameExtandPlayLogic:addJamSperadFlag(mainLogic,  r1 - 1, c1 )
                GameExtandPlayLogic:addJamSperadFlag(mainLogic,  r1 - 2, c1 )
	        end

		elseif c2 == c1 + 1 then -----右
			BombItemLogic:BombItemToChange(mainLogic, r1 + 2, c1, sp2, 2, 3.5, SpecialMatchType.kWrapLine)
			BombItemLogic:BombItemToChange(mainLogic, r1 + 1, c1, sp2, 0, 3.5, SpecialMatchType.kWrapLine)
			BombItemLogic:BombItemToChange(mainLogic, r1, c1, sp2, 0, 3.5, SpecialMatchType.kWrapLine)
			BombItemLogic:BombItemToChange(mainLogic, r1 - 1, c1, sp2, 2, 3.5, SpecialMatchType.kWrapLine)

            if mainLogic:checkSrcSpecialCoverListIsHaveJamSperad(SpecialID) then
		        GameExtandPlayLogic:addJamSperadFlag(mainLogic,  r1 + 2, c1 )
                GameExtandPlayLogic:addJamSperadFlag(mainLogic,  r1 + 1, c1 )
                GameExtandPlayLogic:addJamSperadFlag(mainLogic,  r1, c1 )
                GameExtandPlayLogic:addJamSperadFlag(mainLogic,  r1 - 1, c1 )
	        end
		elseif r2 == r1 - 1 then -----上
			BombItemLogic:BombItemToChange(mainLogic, r1 + 1, c1, sp2, 2, 3.5, SpecialMatchType.kWrapLine)
			BombItemLogic:BombItemToChange(mainLogic, r1, c1, sp2, 0, 3.5, SpecialMatchType.kWrapLine)
			BombItemLogic:BombItemToChange(mainLogic, r1 - 1, c1, sp2, 0, 3.5, SpecialMatchType.kWrapLine)
			BombItemLogic:BombItemToChange(mainLogic, r1 - 2, c1, sp2, 2, 3.5, SpecialMatchType.kWrapLine)

            if mainLogic:checkSrcSpecialCoverListIsHaveJamSperad(SpecialID) then
		        GameExtandPlayLogic:addJamSperadFlag(mainLogic,  r1 + 1, c1 )
                GameExtandPlayLogic:addJamSperadFlag(mainLogic,  r1, c1 )
                GameExtandPlayLogic:addJamSperadFlag(mainLogic,  r1 - 1, c1 )
                GameExtandPlayLogic:addJamSperadFlag(mainLogic,  r1 - 2, c1 )
	        end

		elseif r2 == r1 + 1 then -----下
			BombItemLogic:BombItemToChange(mainLogic, r1 + 2, c1, sp2, 2, 3.5, SpecialMatchType.kWrapLine)
			BombItemLogic:BombItemToChange(mainLogic, r1 + 1, c1, sp2, 0, 3.5, SpecialMatchType.kWrapLine)
			BombItemLogic:BombItemToChange(mainLogic, r1, c1, sp2, 0, 3.5, SpecialMatchType.kWrapLine)
			BombItemLogic:BombItemToChange(mainLogic, r1 - 1, c1, sp2, 2, 3.5, SpecialMatchType.kWrapLine)

            if mainLogic:checkSrcSpecialCoverListIsHaveJamSperad(SpecialID) then
		        GameExtandPlayLogic:addJamSperadFlag(mainLogic,  r1 + 2, c1 )
                GameExtandPlayLogic:addJamSperadFlag(mainLogic,  r1 + 1, c1 )
                GameExtandPlayLogic:addJamSperadFlag(mainLogic,  r1, c1 )
                GameExtandPlayLogic:addJamSperadFlag(mainLogic,  r1 - 1, c1 )
	        end
		end
	elseif sp2 == AnimalTypeConfig.kColumn then
		if c2 == c1 - 1 then ------左
			BombItemLogic:BombItemToChange(mainLogic, r1, c2 - 1, sp2, 2, 3.5, SpecialMatchType.kWrapLine)
			BombItemLogic:BombItemToChange(mainLogic, r1, c2, sp2, 0, 3.5, SpecialMatchType.kWrapLine)
			BombItemLogic:BombItemToChange(mainLogic, r1, c1, sp2, 0, 3.5, SpecialMatchType.kWrapLine)
			BombItemLogic:BombItemToChange(mainLogic, r1, c1 + 1, sp2, 2, 3.5, SpecialMatchType.kWrapLine)

            if mainLogic:checkSrcSpecialCoverListIsHaveJamSperad(SpecialID) then
		        GameExtandPlayLogic:addJamSperadFlag(mainLogic,  r1, c2 - 1 )
                GameExtandPlayLogic:addJamSperadFlag(mainLogic,  r1, c2 )
                GameExtandPlayLogic:addJamSperadFlag(mainLogic,  r1, c1 )
                GameExtandPlayLogic:addJamSperadFlag(mainLogic,  r1, c1 + 1 )
	        end
		elseif c2 == c1 + 1 then -----右
			BombItemLogic:BombItemToChange(mainLogic, r1, c1 - 1, sp2, 2, 3.5, SpecialMatchType.kWrapLine)
			BombItemLogic:BombItemToChange(mainLogic, r1, c1, sp2, 0, 3.5, SpecialMatchType.kWrapLine)
			BombItemLogic:BombItemToChange(mainLogic, r1, c2, sp2, 0, 3.5, SpecialMatchType.kWrapLine)
			BombItemLogic:BombItemToChange(mainLogic, r1, c2 + 1, sp2, 2, 3.5, SpecialMatchType.kWrapLine)

            if mainLogic:checkSrcSpecialCoverListIsHaveJamSperad(SpecialID) then
		        GameExtandPlayLogic:addJamSperadFlag(mainLogic,  r1, c1 - 1 )
                GameExtandPlayLogic:addJamSperadFlag(mainLogic,  r1, c1 )
                GameExtandPlayLogic:addJamSperadFlag(mainLogic,  r1, c2 )
                GameExtandPlayLogic:addJamSperadFlag(mainLogic,  r1, c2 + 1 )
	        end
		elseif r2 == r1 - 1 then -----上
			BombItemLogic:BombItemToChange(mainLogic, r1, c1 - 1, sp2, 2, 3.5, SpecialMatchType.kWrapLine)
			BombItemLogic:BombItemToChange(mainLogic, r1, c1, sp2, 0, 3.5, SpecialMatchType.kWrapLine)
			BombItemLogic:BombItemToChange(mainLogic, r1, c1 + 1, sp2, 0, 3.5, SpecialMatchType.kWrapLine)
			BombItemLogic:BombItemToChange(mainLogic, r1, c1 + 2, sp2, 2, 3.5, SpecialMatchType.kWrapLine)

            if mainLogic:checkSrcSpecialCoverListIsHaveJamSperad(SpecialID) then
		        GameExtandPlayLogic:addJamSperadFlag(mainLogic,  r1, c1 - 1 )
                GameExtandPlayLogic:addJamSperadFlag(mainLogic,  r1, c1 )
                GameExtandPlayLogic:addJamSperadFlag(mainLogic,  r1, c1 + 1 )
                GameExtandPlayLogic:addJamSperadFlag(mainLogic,  r1, c1 + 2 )
	        end
		elseif r2 == r1 + 1 then -----下
			BombItemLogic:BombItemToChange(mainLogic, r1, c1 - 2, sp2, 2, 3.5, SpecialMatchType.kWrapLine)
			BombItemLogic:BombItemToChange(mainLogic, r1, c1 - 1, sp2, 0, 3.5, SpecialMatchType.kWrapLine)
			BombItemLogic:BombItemToChange(mainLogic, r1, c1, sp2, 0, 3.5, SpecialMatchType.kWrapLine)
			BombItemLogic:BombItemToChange(mainLogic, r1, c1 + 1, sp2, 2, 3.5, SpecialMatchType.kWrapLine)

            if mainLogic:checkSrcSpecialCoverListIsHaveJamSperad(SpecialID) then
		        GameExtandPlayLogic:addJamSperadFlag(mainLogic,  r1, c1 - 2 )
                GameExtandPlayLogic:addJamSperadFlag(mainLogic,  r1, c1 - 1 )
                GameExtandPlayLogic:addJamSperadFlag(mainLogic,  r1, c1 )
                GameExtandPlayLogic:addJamSperadFlag(mainLogic,  r1, c1 + 1 )
	        end
		end
	end
	item1.isItemLock = true
	item2.isItemLock = true
	mainLogic:playEliminateMusic(GameMusicType.kSwapWrapLine)

	local WrapLineAction = GameBoardActionDataSet:createAs(
		GameActionTargetType.kGameItemAction,
		GameItemActionType.kItemSpecial_WrapLine,
		IntCoord:create(r1, c1),
		IntCoord:create(r2, c2),
		1)
	WrapLineAction.ItemSpecialType = sp2
	mainLogic:addDestructionPlanAction(WrapLineAction)
end

--------两个区域特效交换爆炸--------
function SpecialMatchLogic:WrapWrapSwapBomb(mainLogic, r1, c1, r2, c2)
	local item1 = mainLogic.gameItemMap[r1][c1]
	local item2 = mainLogic.gameItemMap[r2][c2]

	local keyname = "wrap_wrap_swap"
	GamePlayContext:getInstance():updatePlayInfo( keyname , 1 )

	-----1.计算分数
	local addScore = GamePlayConfigScore.SwapWrapWrap
	mainLogic:addScoreToTotal(r1, c1, addScore, item1._encrypt.ItemColorType)

	mainLogic:tryDoOrderList(r1,c1,GameItemOrderType.kSpecialBomb, GameItemOrderType_SB.kWrap)
	mainLogic:tryDoOrderList(r2,c2,GameItemOrderType.kSpecialBomb, GameItemOrderType_SB.kWrap)
	GameExtandPlayLogic:doAllBlocker195Collect(mainLogic, r1, c1, Blocker195CollectType.kWrap)
	GameExtandPlayLogic:doAllBlocker195Collect(mainLogic, r1, c1, Blocker195CollectType.kWrap)
	SquidLogic:checkSquidCollectItem(mainLogic, r1, c1, SquidCollectType[2])
	SquidLogic:checkSquidCollectItem(mainLogic, r2, c2, SquidCollectType[2])
	mainLogic:tryDoOrderList(r1,c1,GameItemOrderType.kSpecialSwap, GameItemOrderType_SS.kWrapWrap)

	-----2.锁上 不会再次爆炸
	item1.isItemLock = true;
	item2.isItemLock = true;

	-----3.引爆其他部分
	local WrapWrapAction = GameBoardActionDataSet:createAs(
		GameActionTargetType.kGameItemAction,
		GameItemActionType.kItemSpecial_WrapWrap,
		IntCoord:create(r1, c1),
		IntCoord:create(r2, c2),
		GamePlayConfig_SpecialBomb_WrapWrap)
	mainLogic:addDestructionPlanAction(WrapWrapAction)
end

-- 染色宝宝和区域特效
function SpecialMatchLogic:CrystalStoneWithWrap(mainLogic, r1, c1, r2, c2)
	local item1 = mainLogic.gameItemMap[r1][c1]
	local item2 = mainLogic.gameItemMap[r2][c2]
	local color1 = item1._encrypt.ItemColorType
	local color2 = item2._encrypt.ItemColorType

	local theAction = GameBoardActionDataSet:createAs(
		GameActionTargetType.kGameItemAction,
		GameItemActionType.kItemSpecial_CrystalStone_Animal ,
		IntCoord:create(r2,c2), 			----交换之后的染色宝宝位置
		IntCoord:create(r1,c1),				----交换之后的区域特效位置
		GamePlayConfig_SpecialBomb_CrystalStone_Animal_Time1
		)

	theAction.addInt1 = color1 ----染色宝宝的颜色
	theAction.addInt2 = color2 ----目标颜色
	theAction.addInt3 = item2.ItemSpecialType ----目标特效
	mainLogic:addDestructionPlanAction(theAction)
end

-- 染色宝宝和直线特效
function SpecialMatchLogic:CrystalStoneWithLine(mainLogic, r1, c1, r2, c2)
	local item1 = mainLogic.gameItemMap[r1][c1]
	local item2 = mainLogic.gameItemMap[r2][c2]
	local color1 = item1._encrypt.ItemColorType
	local color2 = item2._encrypt.ItemColorType

	local theAction = GameBoardActionDataSet:createAs(
		GameActionTargetType.kGameItemAction,
		GameItemActionType.kItemSpecial_CrystalStone_Animal ,
		IntCoord:create(r2,c2), 			----交换之后的染色宝宝位置
		IntCoord:create(r1,c1),				----交换之后的区域特效位置
		GamePlayConfig_SpecialBomb_CrystalStone_Animal_Time1
		)

	theAction.addInt1 = color1 ----染色宝宝的颜色
	theAction.addInt2 = color2 ----目标颜色
	theAction.addInt3 = item2.ItemSpecialType ----目标特效
	mainLogic:addDestructionPlanAction(theAction)
end

--染色宝宝和普通动物
function SpecialMatchLogic:CrystalStoneWithColor(mainLogic, r1, c1, r2, c2)
	local item1 = mainLogic.gameItemMap[r1][c1] -- 染色宝宝
	local item2 = mainLogic.gameItemMap[r2][c2] -- 普通动物
	local color1 = item1._encrypt.ItemColorType
	local color2 = item2._encrypt.ItemColorType

	local theAction = GameBoardActionDataSet:createAs(
		GameActionTargetType.kGameItemAction,
		GameItemActionType.kItemSpecial_CrystalStone_Animal ,
		IntCoord:create(r2,c2), 			----交换之后的染色宝宝位置
		IntCoord:create(r1,c1),				----交换之后的区域特效位置
		GamePlayConfig_SpecialBomb_CrystalStone_Animal_Time1
		)

	theAction.addInt1 = color1 ----染色宝宝的颜色
	theAction.addInt2 = color2 ----目标颜色
	theAction.addInt3 = item2.ItemSpecialType ----目标特效
	mainLogic:addDestructionPlanAction(theAction)
end

--染色宝宝和染色宝宝
function SpecialMatchLogic:CrystalStoneWithCrystalStone(mainLogic, r1, c1, r2, c2)
	local item1 = mainLogic.gameItemMap[r1][c1]
	local item2 = mainLogic.gameItemMap[r2][c2]
	local color1 = item1._encrypt.ItemColorType
	-- local color2 = item2._encrypt.ItemColorType

	local theAction = GameBoardActionDataSet:createAs(
		GameActionTargetType.kGameItemAction,
		GameItemActionType.kItemSpecial_CrystalStone_CrystalStone,
		IntCoord:create(r2,c2), 			----交换之后的染色宝宝1位置
		IntCoord:create(r1,c1),				----交换之后的染色宝宝2位置
		GamePlayConfig_SpecialBomb_CrystalStone2_Time1
		)
	
	theAction.addInt1 = color1 ----选定染色宝宝的颜色
	mainLogic:addDestructionPlanAction(theAction)
end

function SpecialMatchLogic:CrystalStoneWithBird(mainLogic, r1, c1, r2, c2)
	local item1 = mainLogic.gameItemMap[r1][c1]
	local item2 = mainLogic.gameItemMap[r2][c2]

	local theAction = GameBoardActionDataSet:createAs(
		GameActionTargetType.kGameItemAction,
		GameItemActionType.kItemSpecial_CrystalStone_Bird_part1,
		IntCoord:create(r2,c2), 			----交换之后的染色宝宝位置
		IntCoord:create(r1,c1),				----交换之后的魔力鸟位置
		GamePlayConfig_SpecialBomb_CrystalStone_Bird_Time1
		)
	
	mainLogic:addDestructionPlanAction(theAction)
end

function SpecialMatchLogic:Blocker195WithSwap(mainLogic, actionType, r1, c1, r2, c2)
	local action = GameBoardActionDataSet:createAs(
		GameActionTargetType.kGameItemAction,
		actionType,
		IntCoord:create(r2,c2), 			
		IntCoord:create(r1,c1),
		GamePlayConfig_MaxAction_time
		)
	mainLogic:addDestructionPlanAction(action)

	mainLogic:tryDoOrderList(r1,c1,GameItemOrderType.kOthers, GameItemOrderType_Others.kBlocker195)
end