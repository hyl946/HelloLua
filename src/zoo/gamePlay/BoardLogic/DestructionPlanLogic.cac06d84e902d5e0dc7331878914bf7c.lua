DestructionPlanLogic = class()

function DestructionPlanLogic:update(mainLogic)
	local count = 0

	local maxIndex = table.maxn(mainLogic.destructionPlanList)
	for i = 1 , maxIndex do
		local atc = mainLogic.destructionPlanList[i]
		if atc then
			count = count + 1
			--printx( 1 , "   DestructionPlanLogic:update  " , count , "  v.actionType = " , v.actionType)
			DestructionPlanLogic:runLogicAction(mainLogic, atc, i)
			DestructionPlanLogic:runViewAction(mainLogic.boardView, atc)
		end
	end

	--[[
	for k,v in pairs(mainLogic.destructionPlanList) do
		count = count + 1
		--printx( 1 , "   DestructionPlanLogic:update  " , count , "  v.actionType = " , v.actionType)
		DestructionPlanLogic:runLogicAction(mainLogic, v, k)
		DestructionPlanLogic:runViewAction(mainLogic.boardView, v)
	end
	]]
	return count > 0
end

function DestructionPlanLogic:runLogicAction(mainLogic, theAction, actid)
	if theAction.actionStatus == GameActionStatus.kRunning then 		---running阶段，自动扣时间，到时间了，进入Death阶段
		if theAction.actionDuring < 0 then 
			theAction.actionStatus = GameActionStatus.kWaitingForDeath
		else
			theAction.actionDuring = theAction.actionDuring - 1
			DestructionPlanLogic:runningGameItemAction(mainLogic, theAction, actid)
		end
	-- elseif theAction.actionStatus == GameActionStatus.kWaitingForStart then
		-- theAction.actionStatus = GameActionStatus.kRunning
	elseif theAction.actionStatus == GameActionStatus.kWaitingForDeath then
		mainLogic:resetSpecialEffectList(actid)  --- 特效生命周期中对同一个障碍(boss)的作用只有一次的保护标志位重置
		mainLogic.destructionPlanList[actid] = nil
	end
end

function DestructionPlanLogic:runViewAction(boardView, theAction)
	if theAction.actionType == GameItemActionType.kItemSpecial_Line then 			----横排消除
		if theAction.actionStatus == GameActionStatus.kWaitingForStart then
			DestructionPlanLogic:runGameItemActionBombSpecialLine(boardView, theAction)
		end
	elseif theAction.actionType == GameItemActionType.kItemSpecial_Column then 			----竖排消除
		if theAction.actionStatus == GameActionStatus.kWaitingForStart then
			DestructionPlanLogic:runGameItemActionBombSpecialColumn(boardView, theAction)
		end
	elseif theAction.actionType == GameItemActionType.kItemSpecial_Wrap then 			----区域消除
		if theAction.actionStatus == GameActionStatus.kWaitingForStart then
			DestructionPlanLogic:runGameItemActionBombSpecialWrap(boardView, theAction)
		end
	elseif theAction.actionType == GameItemActionType.kItemSpecial_WrapWrap then
		if theAction.actionStatus == GameActionStatus.kWaitingForStart then
			DestructionPlanLogic:runGameItemActionBombSpecialWrapWrap(boardView, theAction)
		end			
	elseif theAction.actionType == GameItemActionType.kItemSpecial_WrapLine then
		if theAction.actionStatus == GameActionStatus.kWaitingForStart then
			DestructionPlanLogic:runGameItemActionBombSpecialWrapLine(boardView, theAction)
		end		
	elseif theAction.actionType == GameItemActionType.kItemSpecial_Color then 			----魔力鸟
		if theAction.actionStatus == GameActionStatus.kWaitingForStart then
			DestructionPlanLogic:runGameItemActionBombSpecialColor(boardView, theAction)
		end
		if theAction.addInfo == "Over" then
			DestructionPlanLogic:runGameItemActionBombSpecialColor_End(boardView, theAction)
		end
	elseif theAction.actionType == GameItemActionType.kItemSpecial_ColorLine then
		if theAction.actionStatus == GameActionStatus.kWaitingForStart then
			DestructionPlanLogic:runGameItemActionBombBirdLine(boardView, theAction)				----鸟和直线交换之后
		end
		if theAction.addInfo == "BombTime" then
			DestructionPlanLogic:runGameItemActionBombBirdLine_End(boardView, theAction)
		end
	elseif theAction.actionType == GameItemActionType.kItemSpecial_ColorLine_flying then
			DestructionPlanLogic:runGameItemActionBombBirdLineFlying(boardView, theAction)		----鸟和直线交换之后，飞出的特效
	elseif theAction.actionType == GameItemActionType.kItemSpecial_ColorWrap then
		if theAction.actionStatus == GameActionStatus.kWaitingForStart then
			DestructionPlanLogic:runGameItemActionBombBirdLine(boardView, theAction)				----鸟和(区域)交换之后
		end
		if theAction.addInfo == "BombTime" then
			DestructionPlanLogic:runGameItemActionBombBirdLine_End(boardView, theAction)
		end
	elseif theAction.actionType == GameItemActionType.kItemSpecial_ColorWrap_flying then
			DestructionPlanLogic:runGameItemActionBombBirdLineFlying(boardView, theAction)		----鸟和(区域)交换之后，飞出的特效
	-- elseif theAction.actionType == GameItemActionType.kItemSpecial_ColorColor then
	-- 	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
	-- 		DestructionPlanLogic:runGameItemActionBombBirdBird(boardView, theAction)				----鸟鸟交换之后
	-- 	end
	-- 	if theAction.addInfo == "BombAll" then
	-- 		DestructionPlanLogic:runGameItemActionBirdBirdExplode(boardView, theAction)
	-- 	elseif theAction.addInfo == "CleanAll" then
	-- 		DestructionPlanLogic:runGameItemActionBombBirdBird_End(boardView, theAction)
	-- 	end
	elseif theAction.actionType == GameItemActionType.kItemSpecial_ColorColor_part1 then
		if theAction.actionStatus == GameActionStatus.kWaitingForStart then
			DestructionPlanLogic:runGameItemActionBombBirdBird(boardView, theAction)
		end
	elseif theAction.actionType == GameItemActionType.kItemSpecial_ColorColor_part2 then
		if theAction.actionStatus == GameActionStatus.kWaitingForStart then
			theAction.actionStatus = GameActionStatus.kRunning
		end
		DestructionPlanLogic:runGameItemActionBirdBirdExplode(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItemSpecial_ColorColor_part3 then
		if theAction.actionStatus == GameActionStatus.kWaitingForStart then
			theAction.actionStatus = GameActionStatus.kRunning
		end
		if theAction.addInfo == "CleanAll" then
			DestructionPlanLogic:runGameItemActionBombBirdBird_End(boardView, theAction)
		end
	elseif theAction.actionType == GameItemActionType.kItem_Snail_Move then
		DestructionPlanLogic:runGameItemActionSnailMove(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_Hedgehog_Move then
		DestructionPlanLogic:runGameItemActionHedgehogMove(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_Hedgehog_Crazy_Move then
		DestructionPlanLogic:runGameItemActionHedgehogCrazyMove(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_Magic_Stone_Active then
		DestructionPlanLogic:runGameItemActionMagicStone(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_Bottle_Destroy_Around then
		DestructionPlanLogic:runnGameItemActionBottleBlockerDestroyAround(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_Rocket_Active then
		DestructionPlanLogic:runGameItemActionRocketActive(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItemSpecial_CrystalStone_Animal then 
		DestructionPlanLogic:runGameItemSpecialCrystalStoneAnimalAction(boardView, theAction)
	-- elseif theAction.actionType == GameItemActionType.kItemSpecial_CrystalStone_Bird then 
	-- 	DestructionPlanLogic:runGameItemSpecialCrystalStoneBirdAction(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItemSpecial_CrystalStone_Bird_part1 then 
		DestructionPlanLogic:runGameItemSpecialCrystalStoneBirdPart1Action(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItemSpecial_CrystalStone_Bird_part2 then 
		DestructionPlanLogic:runGameItemSpecialCrystalStoneBirdPart2Action(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItemSpecial_CrystalStone_Bird_part3 then 
		DestructionPlanLogic:runGameItemSpecialCrystalStoneBirdPart3Action(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItemSpecial_CrystalStone_CrystalStone then 
		DestructionPlanLogic:runGameItemSpecialCrystalStoneCrystalStoneAction(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItemSpecial_CrystalStone_Charge then
		DestructionPlanLogic:runGameItemCrystalStoneChargeAction(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_Wukong_FallToClearItem then
		DestructionPlanLogic:runGameItemActionWukongFallToClear(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_Wukong_MonkeyBar then
		DestructionPlanLogic:runGameItemActionWukongMonkeyBar(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_Wukong_Casting then
		DestructionPlanLogic:runGameItemActionWukongCasting(boardView, theAction)
	-- elseif theAction.actionType == GameItemActionType.kItem_SuperTotems_Explode then
	-- 	DestructionPlanLogic:runGameItemSuperTotemsExplodeAction(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_SuperTotems_Explode_part1 then
		DestructionPlanLogic:runGameItemSuperTotemsExplodePart1Action(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_SuperTotems_Explode_part2 then
		DestructionPlanLogic:runGameItemSuperTotemsExplodePart2Action(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_Drip_Casting then
		DestructionPlanLogic:runGameItemActionDripCasting(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_Puffer_Explode then
		DestructionPlanLogic:runningGameItemActionPufferExplode(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_Puffer_Active then
		DestructionPlanLogic:runningGameItemActionPufferActive(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_Check_Has_Drip then
		DestructionPlanLogic:runningGameItemActionCheckHasDrip(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItemMatchAt_OlympicBlockExplode then
		DestructionPlanLogic:runGameItemActionOlympicBlockExplode(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kBombAll_OlympicMode then
		DestructionPlanLogic:runGameItemActionBombAllOlympicMode(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_Blocker195_Collect then
		DestructionPlanLogic:runGameItemBlocker195CollectAction(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItemSpecial_Blocker195_Color then
		DestructionPlanLogic:runGameItemBlocker195ColorAction(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItemSpecial_Blocker195_Kind_Color then
		DestructionPlanLogic:runGameItemBlocker195KindColorAction(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItemSpecial_Blocker195_Coin then
		DestructionPlanLogic:runGameItemBlocker195CoinAction(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItemSpecial_Blocker195_HoneyBottle then
		DestructionPlanLogic:runGameItemBlocker195HoneyBottleAction(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItemSpecial_Blocker195_Missile then
		DestructionPlanLogic:runGameItemBlocker195MissileAction(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItemSpecial_Blocker195_Puffer then
		DestructionPlanLogic:runGameItemBlocker195PufferAction(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItemSpecial_Blocker195_Blocker207 then
		DestructionPlanLogic:runGameItemBlocker195Blocker207Action(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItemSpecial_Blocker195_Ghost then
		DestructionPlanLogic:runGameItemBlocker195BlockerGhostAction(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_Blocker199_Dec then
		DestructionPlanLogic:runGameItemBlocker199DecAction(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_Blocker199_Explode then
		DestructionPlanLogic:runGameItemBlocker199ExplodeAction(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kNationDay2017_Cast then
		DestructionPlanLogic:runNationDay2017CastAction(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kNationDay2017_Bomb_All then
		DestructionPlanLogic:runGameItemActionNationDay2017BombAll(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItemSpecial_rectangle then
		DestructionPlanLogic:runGameItemActionRectangleBombView(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItemSpecial_diagonalSquare then
		DestructionPlanLogic:runGameItemActionDiagonalSquareBombView(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_Blocker211_Collect then
		DestructionPlanLogic:runGameItemBlocker211CollectAction(boardView, theAction)
    elseif theAction.actionType == GameItemActionType.kMoleWeekly_Bomb_All then
		DestructionPlanLogic:runningGameItemMoleWeekly_Bomb_All_View(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_Squid_BombGrid then
		DestructionPlanLogic:runGameItemActionSquidBombGridView(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_Line_Prop_Effect then
		DestructionPlanLogic:runGamePropsLineEffectView(boardView, theAction)
    elseif theAction.actionType == GameItemActionType.kItemSpecial_Blocker195_WanSheng then
		DestructionPlanLogic:runGameItemBlocker195WanShengAction(boardView, theAction)
	end
end

function DestructionPlanLogic:runningGameItemAction(mainLogic, theAction, actid)
	if theAction.actionType == GameItemActionType.kItemSpecial_Line then 
		DestructionPlanLogic:runingGameItemSpecialBombLineAction(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItemSpecial_Column then 
		DestructionPlanLogic:runingGameItemSpecialBombColumnAction(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItemSpecial_Wrap then 
		DestructionPlanLogic:runingGameItemSpecialBombWrapAction(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItemSpecial_WrapWrap then
		DestructionPlanLogic:runingGameItemSpecialBombWrapWrapAction(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItemSpecial_Color then 						----鸟和普通动物交换、爆炸
		DestructionPlanLogic:runingGameItemSpecialBombColorAction(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItemSpecial_ColorLine then 					----鸟和直线特效交换----
		DestructionPlanLogic:runingGameItemSpecialBombColorLineAction(mainLogic, theAction, actid, AnimalTypeConfig.kLine)
	elseif theAction.actionType == GameItemActionType.kItemSpecial_ColorLine_flying then 			----鸟和直线交换之后，飞行的小鸟----
		DestructionPlanLogic:runingGameItemSpecialBombColorLineAction_flying(mainLogic, theAction, actid, AnimalTypeConfig.kLine)
	elseif theAction.actionType == GameItemActionType.kItemSpecial_ColorWrap then 					----鸟和直线特效交换----
		DestructionPlanLogic:runingGameItemSpecialBombColorLineAction(mainLogic, theAction, actid, AnimalTypeConfig.kWrap)
	elseif theAction.actionType == GameItemActionType.kItemSpecial_ColorWrap_flying then 			----鸟和直线交换之后，飞行的小鸟----
		DestructionPlanLogic:runingGameItemSpecialBombColorLineAction_flying(mainLogic, theAction, actid, AnimalTypeConfig.kWrap)
	-- elseif theAction.actionType == GameItemActionType.kItemSpecial_ColorColor then 					----鸟鸟消除
	-- 	DestructionPlanLogic:runingGameItemSpecialBombColorColorAction(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItemSpecial_ColorColor_part1 then 					----鸟鸟消除第一部分：
		DestructionPlanLogic:runingGameItemSpecialBombColorColorPart1Action(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItemSpecial_ColorColor_part2 then 					----鸟鸟消除第二部分：部分引爆后达到微稳定
		DestructionPlanLogic:runingGameItemSpecialBombColorColorPart2Action(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItemSpecial_ColorColor_part3 then 					----鸟鸟消除第三部分：全屏消除
		DestructionPlanLogic:runingGameItemSpecialBombColorColorPart3Action(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItem_Snail_Move then
		DestructionPlanLogic:runningGameItemActionSnailMove(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItem_Hedgehog_Move then
		DestructionPlanLogic:runningGameItemActionHedgehogMove(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItem_Hedgehog_Crazy_Move then
		DestructionPlanLogic:runningGameItemActionHedgehogCrazyMove(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItem_Magic_Stone_Active then
		DestructionPlanLogic:runningGameItemActionMagicStoneActive(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItem_Bottle_Destroy_Around then
		DestructionPlanLogic:runningGameItemActionBottleBlockerDestroyAroundActive(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItem_Rocket_Active then
		DestructionPlanLogic:runningGameItemActionRocketActive(mainLogic, theAction, actid)

	elseif theAction.actionType == GameItemActionType.kItemSpecial_CrystalStone_Animal then 
		DestructionPlanLogic:runingGameItemSpecialCrystalStoneAnimalAction(mainLogic, theAction, actid)
	-- elseif theAction.actionType == GameItemActionType.kItemSpecial_CrystalStone_Bird then 
	-- 	DestructionPlanLogic:runingGameItemSpecialCrystalStoneBirdAction(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItemSpecial_CrystalStone_Bird_part1 then 
		DestructionPlanLogic:runingGameItemSpecialCrystalStoneBirdPart1Action(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItemSpecial_CrystalStone_Bird_part2 then 
		DestructionPlanLogic:runingGameItemSpecialCrystalStoneBirdPart2Action(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItemSpecial_CrystalStone_Bird_part3 then 
		DestructionPlanLogic:runingGameItemSpecialCrystalStoneBirdPart3Action(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItemSpecial_CrystalStone_CrystalStone then 
		DestructionPlanLogic:runingGameItemSpecialCrystalStoneCrystalStoneAction(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItemSpecial_CrystalStone_Charge then
		DestructionPlanLogic:runingGameItemCrystalStoneChargeAction(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItem_Wukong_FallToClearItem then
		DestructionPlanLogic:runingGameItemActionWukongFallToClear(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_Wukong_MonkeyBar then
		DestructionPlanLogic:runingGameItemActionWukongMonkeyBar(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_Wukong_Casting then
		DestructionPlanLogic:runingGameItemActionWukongCasting(mainLogic, theAction, actid, actByView)
	-- elseif theAction.actionType == GameItemActionType.kItem_SuperTotems_Explode then
	-- 	DestructionPlanLogic:runingGameItemSuperTotemsExplodeAction(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItem_SuperTotems_Explode_part1 then
		DestructionPlanLogic:runingGameItemSuperTotemsExplodePart1Action(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItem_SuperTotems_Explode_part2 then
		DestructionPlanLogic:runingGameItemSuperTotemsExplodePart2Action(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItem_Drip_Casting then
		DestructionPlanLogic:runningGameItemActionDripCasting(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItem_Puffer_Explode then
		DestructionPlanLogic:runGameItemActionPufferExplode(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItem_Puffer_Active then
		DestructionPlanLogic:runGameItemActionPufferActive(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItem_Check_Has_Drip then
		DestructionPlanLogic:runGameItemActionCheckHasDrip(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItemMatchAt_OlympicBlockExplode then
		DestructionPlanLogic:runningGameItemActionOlympicBlockExplode(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kBombAll_OlympicMode then
		DestructionPlanLogic:runningGameItemActionBombAllOlympicMode(mainLogic, theAction, actid, actByView)
	elseif 
		theAction.actionType == GameItemActionType.kItem_Blocker195_Collect
		or theAction.actionType == GameItemActionType.kItemSpecial_Blocker195_Color 
		or theAction.actionType == GameItemActionType.kItemSpecial_Blocker195_Kind_Color 
		or theAction.actionType == GameItemActionType.kItemSpecial_Blocker195_Coin 
		or theAction.actionType == GameItemActionType.kItemSpecial_Blocker195_HoneyBottle 
		or theAction.actionType == GameItemActionType.kItemSpecial_Blocker195_Missile 
		or theAction.actionType == GameItemActionType.kItemSpecial_Blocker195_Puffer 
		or theAction.actionType == GameItemActionType.kItemSpecial_Blocker195_Blocker207 
		or theAction.actionType == GameItemActionType.kItemSpecial_Blocker195_Ghost 
        or theAction.actionType == GameItemActionType.kItemSpecial_Blocker195_WanSheng 
		then
		DestructionPlanLogic:runningGameItemBlocker195OverAction(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItem_Blocker199_Dec then
		DestructionPlanLogic:runningGameItemBlocker199DecAction(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItem_Blocker199_Explode then
		DestructionPlanLogic:runningGameItemBlocker199ExplodeAction(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kNationDay2017_Cast then
		DestructionPlanLogic:runningNationDay2017CastAction(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kNationDay2017_Bomb_All then
		DestructionPlanLogic:runningGameItemActionNationDay2017BombAll(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItemSpecial_rectangle then
		DestructionPlanLogic:runGameItemActionRectangleBombLogic(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItemSpecial_diagonalSquare then
		DestructionPlanLogic:runGameItemActionDiagonalSquareBombLogic(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItem_Blocker211_Collect then
		DestructionPlanLogic:runningGameItemBlocker211CollectAction(mainLogic, theAction, actid)
    elseif theAction.actionType == GameItemActionType.kMoleWeekly_Bomb_All then
		DestructionPlanLogic:runningGameItemMoleWeekly_Bomb_All_Logic(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItem_Squid_BombGrid then
		DestructionPlanLogic:runGameItemActionSquidBombGridLogic(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItem_Line_Prop_Effect then
		DestructionPlanLogic:runGamePropsLineEffectLogic(mainLogic, theAction, actid)
	end
end


local function JamSperadSpecialIDCheck( mainLogic, pos, nextPos, bStop, StopNum, srcSpecialID, justRemove )
    local bStop = bStop
    local StopNum = StopNum
    local srcSpecialID = srcSpecialID
    local nextPos = nextPos

    if not mainLogic:isPosValid(nextPos.x, nextPos.y) then
        nextPos = IntCoord:create(pos.x,pos.y)
    end

    --如果前面没有果酱 当前位置有果酱 可以往下传播
    local boardData = mainLogic.boardmap[pos.x][pos.y]
    local itemData = mainLogic.gameItemMap[pos.x][pos.y]
    if not mainLogic:checkSrcSpecialCoverListIsHaveJamSperad( srcSpecialID ) 
    	and boardData.isJamSperad 
    	and not itemData.isEmpty 
    	and not mainLogic:CheckPosCanStopJamSperad( IntCoord:create(pos.x,pos.y), nil, justRemove )
    then
        srcSpecialID = mainLogic:addSrcSpecialCoverToList( ccp(pos.x,pos.y) )
    end

    local bCanStop = mainLogic:CheckPosCanStopJamSperad( IntCoord:create(pos.x,pos.y) , IntCoord:create(nextPos.x,nextPos.y), justRemove )
    local bNextCanStop = mainLogic:CheckPosCanStopJamSperad( IntCoord:create(nextPos.x,nextPos.y), IntCoord:create(pos.x,pos.y) ) 

    --特别兼容 由于消除会一个一个来。有阻挡的障碍会在前一个被消除掉，这里预先判断他的下一个是否阻挡。做个计数器
    if bNextCanStop and not bStop then
        bStop = true
        StopNum = 1
    end

    if bCanStop and not bStop then
        bStop = true
        StopNum = 0
    end

    local SpecialID = srcSpecialID
    if bStop and StopNum == 0 then
        SpecialID = nil
    end

    if StopNum > 0 then
        StopNum = StopNum - 1
    end
    --

    return SpecialID, StopNum, bStop, srcSpecialID
end

function DestructionPlanLogic:JamSperadSpecialIDCheck( ... )
	return JamSperadSpecialIDCheck(...)
end

function DestructionPlanLogic:runningGameItemBlocker211CollectAction(mainLogic, theAction, actid)
	if theAction.actionStatus == GameActionStatus.kRunning then
		local r, c = theAction.ItemPos2.x, theAction.ItemPos2.y
		local item = mainLogic.gameItemMap[r][c]
		theAction.jsq = theAction.jsq + 1

		if theAction.addInfo == 'collect' then
			local maxJsq = 35
			if theAction.isActive then maxJsq = 65 end
			if theAction.jsq >= maxJsq then
				theAction.jsq = 0

				if theAction.isActive then
					theAction.addInfo = 'explode'
				else
					theAction.addInfo = 'over'
				end
			end
		elseif theAction.addInfo == 'explode' then
			if theAction.jsq == 45 then
				local action = GameBoardActionDataSet:createAs(
					GameActionTargetType.kGameItemAction,
					GameItemActionType.kItemSpecial_rectangle,
					IntCoord:create(c - 1, r - 1),
					IntCoord:create(c + 1, r + 1),
					GamePlayConfig_MaxAction_time)
				action.addInt2 = 1
				-- action.eliminateChainIncludeHem = true
				action.footprintType = ObstacleFootprintType.k_Blocker211
				mainLogic:addDestructionPlanAction(action)
				ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_Blocker211, ObstacleFootprintAction.k_Attack, 1)
			end

			if theAction.jsq >= 65 then
				theAction.jsq = 0
				item.level = 0 
				item.isActive = false 
				item.flag = true

				if item and item.needRemoveEventuallyBySquid then
					item:cleanAnimalLikeData()
					item.isNeedUpdate = true
					mainLogic:checkItemBlock(r, c)
				end
				
				theAction.addInfo = 'over'
			end
		elseif theAction.addInfo == 'over' then
			theAction.actionStatus = GameActionStatus.kWaitingForDeath
		end
	end	
end

function DestructionPlanLogic:runGameItemBlocker211CollectAction(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		theAction.jsq = 0
		theAction.addInfo = 'collect'

		local item = boardView.baseMap[theAction.ItemPos2.x][theAction.ItemPos2.y]
		local data = boardView.gameBoardLogic.gameItemMap[theAction.ItemPos2.x][theAction.ItemPos2.y]
		if item then 
			item:playBlocker211CollectAnimation(data)
		end
	else
		local r, c = theAction.ItemPos2.x, theAction.ItemPos2.y
		local item = boardView.baseMap[r][c]
		if theAction.addInfo == 'explode' then
			if theAction.jsq == 0 then
				if item then item:playBlocker211ExplodeAnimation() end
			elseif theAction.jsq == 32 then
				--if item then item:playBlocker211EmptyAnimation() end
				local fromPos = item:getBasePosition(c, r)
				for r1 = r - 1, r + 1 do
					for c1 = c - 1, c + 1 do
						if boardView.gameBoardLogic:isPosValid(r1, c1) and not (r1 == r and c1 == c) then
							local toPos = item:getBasePosition(c1, r1)
							item:playBlocker211Effect1Animation(fromPos, toPos)
						end
					end
				end 
			end
		elseif theAction.addInfo == 'over' then
			if not theAction.isActive and item then item:renewBlocker211IdleAnimation() end
		end
	end
end

function DestructionPlanLogic:runningGameItemActionNationDay2017BombAll(mainLogic, theAction, actid)
	if theAction.addInfo == "bombAll" then
		GamePlayMusicPlayer:playEffect(GameMusicType.kSwapColorColorCleanAll)
		local startRow, startCol = theAction.ItemPos1.x, theAction.ItemPos1.y
		local endRow, endCol = theAction.ItemPos2.x, theAction.ItemPos2.y

        local SpecialID = mainLogic:addSrcSpecialCoverToList( theAction.ItemPos1, theAction.ItemPos2 )

		local rowCount = theAction.addInt or 0
		local delRow = startRow + rowCount
		if delRow <= endRow then
			for c = startCol, endCol do
				local item = mainLogic.gameItemMap[delRow] and mainLogic.gameItemMap[delRow][c] or nil
				if item and item.ItemType ~= GameItemType.kTangChicken then
					BombItemLogic:tryCoverByBomb(mainLogic, delRow, c, true, 1, true, true)
					SpecialCoverLogic:SpecialCoverAtPos(mainLogic, delRow, c, 0, nil, nil, true, true, nil, SpecialID ) 
				end
			end
		end
		theAction.addInt = rowCount + 1
		if startRow + theAction.addInt > endRow then
			theAction.addInfo = "over"
		end
	elseif theAction.addInfo == "over" then
		if theAction.completeCallback then
			theAction.completeCallback()
		end
		mainLogic.destructionPlanList[actid] = nil
	end
end

function DestructionPlanLogic:runGameItemActionNationDay2017BombAll(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning

		local function onBomb( ... )
			theAction.addInfo = "bombAll"
		end
		local function onFinish()

		end
		local animation = NationDay2017Animations:createBigBangAnime(onBomb, onFinish)
		boardView.PlayUIDelegate.effectLayer:addChild(animation)
	end
end

function DestructionPlanLogic:runningNationDay2017CastAction(mainLogic, theAction, actid)
	if theAction.addInfo == "start" then
		theAction.jsq = 0
		local targetPosList = theAction.specialTargetPosList
		if targetPosList and #targetPosList > 0 then
			theAction.addInfo = "fly" --"waitingToFly"
		else
			theAction.addInfo = "explode"
		end
	-- elseif theAction.addInfo == "waitingToFly" then
	-- 	theAction.jsq = theAction.jsq + 1
	-- 	if theAction.jsq == 35 then
	-- 		theAction.addInfo = "fly"
	-- 		theAction.jsq = 0
	-- 	end
	elseif theAction.addInfo == "waitingFlyOver" then
		theAction.jsq = theAction.jsq + 1
		if theAction.jsq == 70 then
			GamePlayMusicPlayer:playEffect("music/sound.nationday.bomb.mp3")
			theAction.addInfo = "explode"
			theAction.jsq = 0
		end
	elseif theAction.addInfo == "explode" then
		theAction.jsq = theAction.jsq + 1
		local targetPosList = theAction.specialTargetPosList
		if #targetPosList > 0 then
			for _, pos in ipairs(targetPosList) do
				
				local r1 , c1 = pos.r, pos.c
				local item = mainLogic.gameItemMap[r1][c1]

				local function explodeItem(r,c ,specialAtSnail)
					if r >= 1 and r <= 9 and c >= 1 and c <= 9 then
						local bitem = nil
						if mainLogic.gameItemMap[r] then
							bitem = mainLogic.gameItemMap[r][c]
						end
						if bitem and bitem.isUsed and bitem.ItemType ~= GameItemType.kTangChicken then
							SpecialCoverLogic:SpecialCoverLightUpAtPos(mainLogic, r, c, 1, true)
							BombItemLogic:tryCoverByBomb(mainLogic, r, c, true, 1, true)
							SpecialCoverLogic:SpecialCoverAtPos(mainLogic, r, c, 3, 1, actId)

							SpecialCoverLogic:specialCoverChainsAroundPos(mainLogic, r, c, {ChainDirConfig.kUp, ChainDirConfig.kDown, ChainDirConfig.kRight, ChainDirConfig.kLeft})
							if specialAtSnail then
								SnailLogic:SpecialCoverSnailRoadAtPos( mainLogic, r, c )
							end
						end
					end

					mainLogic:setNeedCheckFalling()
				end

				if theAction.jsq == 1 then
					explodeItem(r1     , c1 , true)
					--item:cleanAnimalLikeData()
				elseif theAction.jsq == 2 then
					explodeItem(r1 + 1 , c1)
					explodeItem(r1 - 1 , c1)
					explodeItem(r1     , c1 + 1)
					explodeItem(r1     , c1 - 1)
				elseif theAction.jsq == 3 then
					explodeItem(r1 + 1 , c1 + 1)
					explodeItem(r1 + 1 , c1 - 1)
					explodeItem(r1 - 1 , c1 + 1)
					explodeItem(r1 - 1 , c1 - 1)
					theAction.addInfo = "explodeComplete"
				end
			end	
		else
			theAction.addInfo = "explodeComplete"
		end
		
	elseif theAction.addInfo == "explodeComplete" then
		theAction.addInfo = "over"
	elseif theAction.addInfo == "over" then
		if theAction.completeCallback then
			theAction.completeCallback()
		end
		mainLogic.destructionPlanList[actid] = nil
	end
end

function DestructionPlanLogic:runNationDay2017CastAction(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning

		theAction.addInfo = "start"
	else
		if theAction.addInfo == "fly" then
			local fromPos = theAction.castFromPos or {x = 0, y = 0}
			local function onAimationFinish()
			end
			local function onFire()
				local targetPosList = theAction.specialTargetPosList
				if targetPosList and #targetPosList > 0 then
					for i , pos in ipairs(targetPosList) do
						local targetItemView = boardView.baseMap[pos.r][pos.c]
						targetItemView:playBoomByOlympicBlockerEffectFromPos( i, ccp(fromPos.x, fromPos.y), onAimationFinish)
						if _G.isLocalDevelopMode then
							local pos = targetItemView:getBasePosition(pos.c, pos.r)
							local debugNum = TextField:create(tostring(theAction.debugBombNum).."-"..i , "Helvetica", 72)
							debugNum:setColor(ccc3(255, 0, 0))
							debugNum:setPosition(pos)
							local function removeFunc()
								debugNum:removeFromParentAndCleanup(true)
							end
							debugNum:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(2), CCCallFunc:create(removeFunc)))
							boardView:addChild(debugNum)
						end
					end
				end
				theAction.addInfo = "waitingFlyOver"
			end
			boardView.gameBoardLogic.gameMode:runUseBombAnimation(onFire)
		end
	end
end

function DestructionPlanLogic:runningGameItemActionBombAllOlympicMode(mainLogic, theAction, actid, actByView)
	if theAction.addInfo == "bombAll" then
		local startRow, startCol = theAction.ItemPos1.x, theAction.ItemPos1.y
		local endRow, endCol = theAction.ItemPos2.x, theAction.ItemPos2.y
		local rowCount = theAction.addInt or 0
		local delRow = startRow + rowCount

		local SpecialID = mainLogic:addSrcSpecialCoverToList( theAction.ItemPos1, theAction.ItemPos2 )

		if delRow <= endRow then
			for c = startCol, endCol do
				BombItemLogic:forceClearItemInOlympicMode(mainLogic, delRow, c, SpecialID)
			end
		end
		theAction.addInt = rowCount + 1
		if startRow + theAction.addInt > endRow then
			theAction.addInfo = "over"
		end
	elseif theAction.addInfo == "over" then
		if theAction.completeCallback then
			theAction.completeCallback()
		end
		mainLogic.destructionPlanList[actid] = nil
	end
end

function DestructionPlanLogic:runGameItemActionBombAllOlympicMode(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning

		theAction.addInfo = "bombAll"

		local function playEff(col)
			local pos = {x=3 , y=col}
			local position1 = DestructionPlanLogic:getItemPosition(pos)
			local effect = CommonEffect:buildLineEffect(boardView.specialEffectBatch)
			effect:setPosition(position1)
			effect:setRotation(90)
			
			boardView.specialEffectBatch:addChild(effect)
		end

		playEff(2)
		playEff(3)
		playEff(4)
		
	end
end

function DestructionPlanLogic:runningGameItemActionOlympicBlockExplode(mainLogic, theAction, actid, actByView)

	if theAction.addInfo == "start" then

		--[[
		if mainLogic.gameMode:is(OlympicHorizontalEndlessMode) then
			local addStep = theAction.addInt or 3
			mainLogic.gameMode:addFollowAnimalSwoonRound(addStep)
		end
		]]
		theAction.jsq = 0
		local targetPosList = theAction.specialTargetPosList
		if targetPosList and #targetPosList > 0 then
			theAction.addInfo = "waitingToFly"
		else
			theAction.addInfo = "explode"
		end
	elseif theAction.addInfo == "waitingToFly" then
		theAction.jsq = theAction.jsq + 1
		if theAction.jsq == 35 then
			theAction.addInfo = "fly"
			theAction.jsq = 0
		end

	elseif theAction.addInfo == "waitingFlyOver" then
		theAction.jsq = theAction.jsq + 1
		if theAction.jsq == 85 then
			theAction.addInfo = "explode"
			theAction.jsq = 0
		end
	elseif theAction.addInfo == "explode" then

		theAction.jsq = theAction.jsq + 1

		local targetPosList = theAction.specialTargetPosList

		if #targetPosList > 0 then
			for _, pos in ipairs(targetPosList) do
				
				local r1 , c1 = pos.r + 1, pos.c + 1
				local item = mainLogic.gameItemMap[r1][c1]

				local function explodeItem(r,c ,specialAtSnail)

					if r >= 1 and r <= 9 and c >= 1 and c <= 9 then
						local bitem = nil
						if mainLogic.gameItemMap[r] then
							bitem = mainLogic.gameItemMap[r][c]
						end

						if bitem then
							SpecialCoverLogic:SpecialCoverLightUpAtPos(mainLogic, r, c, 1, true)
							BombItemLogic:tryCoverByBomb(mainLogic, r, c, true, 1, true)
							SpecialCoverLogic:SpecialCoverAtPos(mainLogic, r, c, 3, 1, actId)

							SpecialCoverLogic:specialCoverChainsAroundPos(mainLogic, r, c, {ChainDirConfig.kUp, ChainDirConfig.kDown, ChainDirConfig.kRight, ChainDirConfig.kLeft})
							if specialAtSnail then
								SnailLogic:SpecialCoverSnailRoadAtPos( mainLogic, r, c )
							end
						end
					end

					mainLogic:setNeedCheckFalling()
				end

				if theAction.jsq == 1 then
					explodeItem(r1     , c1 , true)
					--item:cleanAnimalLikeData()
				elseif theAction.jsq == 2 then
					explodeItem(r1 + 1 , c1)
					explodeItem(r1 - 1 , c1)
					explodeItem(r1     , c1 + 1)
					explodeItem(r1     , c1 - 1)
				elseif theAction.jsq == 3 then
					explodeItem(r1 + 1 , c1 + 1)
					explodeItem(r1 + 1 , c1 - 1)
					explodeItem(r1 - 1 , c1 + 1)
					explodeItem(r1 - 1 , c1 - 1)
					theAction.addInfo = "explodeComplete"
				end
			end	
		else
			theAction.addInfo = "explodeComplete"
		end
		
	elseif theAction.addInfo == "explodeComplete" then
		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local item = mainLogic.gameItemMap[r][c]
		item:cleanAnimalLikeData()
		item.isNeedUpdate = true
		mainLogic:checkItemBlock(r, c)
		mainLogic:setNeedCheckFalling()
		FallingItemLogic:preUpdateHelpMap(mainLogic)
		theAction.addInfo = "over"
	elseif theAction.addInfo == "over" then
		if theAction.completeCallback then
			theAction.completeCallback()
		end
		mainLogic.destructionPlanList[actid] = nil
	end
	--[[
	if theAction.addInfo == "start" then
		if mainLogic.gameMode:is(OlympicHorizontalEndlessMode) then
			local addStep = theAction.addInt or 3
			mainLogic.gameMode:addFollowAnimalSwoonRound(addStep)
		end
		local targetPosList = theAction.specialTargetPosList
		if targetPosList and #targetPosList > 0 then
			theAction.addInfo = "waitingFlyOver"
			theAction.addInt = 0
		else
			theAction.addInfo = "explode"
		end
	elseif theAction.addInfo == "waitingFlyOver" then
		theAction.addInt = theAction.addInt + 1
		if theAction.addInt == 30 then
			local targetPosList = theAction.specialTargetPosList
			local specialTypeList = {AnimalTypeConfig.kLine, AnimalTypeConfig.kColumn, AnimalTypeConfig.kWrap}
			for _, pos in ipairs(targetPosList) do
				local targetItem = mainLogic.gameItemMap[pos.x][pos.y]
				targetItem.ItemSpecialType = specialTypeList[mainLogic.randFactory:rand(1, #specialTypeList)]
				targetItem.isNeedUpdate = true
			end
			theAction.addInfo = "explode"
		end
	elseif theAction.addInfo == "explode" then
		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local item = mainLogic.gameItemMap[r][c]
		item:cleanAnimalLikeData()
		item.isNeedUpdate = true
		mainLogic:checkItemBlock(r, c)
		mainLogic:setNeedCheckFalling()
		FallingItemLogic:preUpdateHelpMap(mainLogic)
		theAction.addInfo = "over"
	elseif theAction.addInfo == "over" then
		if theAction.completeCallback then
			theAction.completeCallback()
		end
		mainLogic.destructionPlanList[actid] = nil
	end
	]]
end

function DestructionPlanLogic:runGameItemActionOlympicBlockExplode(boardView, theAction)

	local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
	local itemView = boardView.baseMap[r][c]
	local tileOlympicBlocker = itemView.itemSprite[ItemSpriteType.kItemShow]

	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning

		if tileOlympicBlocker then
			tileOlympicBlocker:playBoomAnimation()
		end

		theAction.addInfo = "start"

	else
		if theAction.addInfo == "fly" then

			if tileOlympicBlocker then
				tileOlympicBlocker:removeFromParentAndCleanup(true)
				itemView.itemSprite[ItemSpriteType.kItemShow] = nil
			end

			local function onAimationFinish()
				--theAction.addInfo = "waitingFlyOver" 
			end

			local targetPosList = theAction.specialTargetPosList
			if targetPosList and #targetPosList > 0 then
				for i , pos in ipairs(targetPosList) do
					local targetItemView = boardView.baseMap[pos.r + 1][pos.c + 1]
					targetItemView:playBoomByOlympicBlockerEffect( i , itemView , onAimationFinish)
				end
			end
			theAction.addInfo = "waitingFlyOver"
		end
	end
	--printx( 1 , "   DestructionPlanLogic:runGameItemActionOlympicBlockExplode   theAction.addInfo = " , theAction.addInfo)
end

function DestructionPlanLogic:runningGameItemActionCheckHasDrip(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
	end
end

function DestructionPlanLogic:runGameItemActionCheckHasDrip(mainLogic, theAction, actid)
	if theAction.actionStatus == GameActionStatus.kRunning then
		local gameItemMap = mainLogic.gameItemMap
		local item = nil
		local dripNum = 0

		for r = 1, #gameItemMap do 
	        for c = 1, #gameItemMap[r] do

	            item = gameItemMap[r][c]
	            if item ~= nil and item.ItemType == GameItemType.kDrip 
	            	and ( item.dripState == DripState.kGrow or item.dripState == DripState.kReadyToMove ) then
	            	dripNum = dripNum + 1
	            end
	        end
		end
		if dripNum == 0 then
			if theAction.completeCallback then
				theAction.completeCallback()
			end
			mainLogic.destructionPlanList[actid] = nil
		end
	end
end


function DestructionPlanLogic:runningGameItemActionPufferActive(boardView, theAction)
	local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
	local item = boardView.baseMap[r][c]
	--printx( 1 , "  --------   DestructionPlanLogic:runningGameItemActionPufferActive  addInfo = " , theAction.addInfo , theAction.jsq)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning

		item.isNeedUpdate = true
		theAction.jsq = 0
		theAction.addInfo = "watingAnimation"
		--[[
		local function onAimationFinish()
			theAction.addInfo = "over"
		end
		item:playSuperCuteRecover(onAimationFinish)
		]]
	else
		if theAction.addInfo == "watingAnimation" then

			theAction.jsq = theAction.jsq + 1
			--printx( 1 , "  WTF!!!!!!!!!!!!!!!!!!!!!!!!   " , theAction.jsq)
			if theAction.jsq >= 30 then
				theAction.addInfo = "over"
				item.isNeedUpdate = true
			end
		end
	end
end

function DestructionPlanLogic:runGameItemActionPufferActive(mainLogic, theAction, actid)
	if theAction.actionStatus == GameActionStatus.kRunning then

		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local item = mainLogic.gameItemMap[r][c]
		--printx( 1 , "  ++++++++   DestructionPlanLogic:runGameItemActionPufferActive  addInfo = " , theAction.addInfo , theAction.jsq)
		if theAction.addInfo == "watingAnimation" then
			if theAction.jsq == 0 then
				item.isNeedUpdate = true
			end
		elseif theAction.addInfo == "over" then

			item.pufferState = PufferState.kActivated
			mainLogic:checkItemBlock(r,c)
			item.isNeedUpdate = true

			if theAction.completeCallback then
				theAction.completeCallback()
			end
			mainLogic.destructionPlanList[actid] = nil

			--printx( 1 , "  ~~~~~~~~~~~~~~~~~~~~~~~~~  DestructionPlanLogic:runGameItemActionPufferActive  ~~~~~~~~~~~~~~~~~~")
		end
	end
end

function DestructionPlanLogic:runningGameItemActionPufferExplode(boardView, theAction)
	local r1, c1 = theAction.ItemPos1.x, theAction.ItemPos1.y

	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		theAction.jsq = 0
		theAction.addInfo = "bomb"
	else

	end
end

function DestructionPlanLogic:runGameItemActionPufferExplode(mainLogic, theAction, actid)
	if theAction.actionStatus == GameActionStatus.kRunning then

		local r1 , c1 = theAction.ItemPos1.x, theAction.ItemPos1.y
		local item = mainLogic.gameItemMap[r1][c1]

        local SpecialID = mainLogic:addSrcSpecialCoverToList( theAction.ItemPos1 )

		theAction.jsq = theAction.jsq + 1

		local function explodeItem(r,c ,specialAtSnail)

			if r >= 1 and r <= 9 and c >= 1 and c <= 9 then
				local bitem = nil
				if mainLogic.gameItemMap[r] then
					bitem = mainLogic.gameItemMap[r][c]
				end

				if bitem then
					SpecialCoverLogic:SpecialCoverLightUpAtPos(mainLogic, r, c, 1, true)
					BombItemLogic:tryCoverByBomb(mainLogic, r, c, true, 1, true, nil, ObstacleFootprintType.k_Puffer)
					SpecialCoverLogic:SpecialCoverAtPos(mainLogic, r, c, 3, 1, actId, nil, nil, ObstacleFootprintType.k_Puffer, SpecialID )

					SpecialCoverLogic:specialCoverChainsAroundPos(mainLogic, r, c, {ChainDirConfig.kUp, ChainDirConfig.kDown, ChainDirConfig.kRight, ChainDirConfig.kLeft})
					if specialAtSnail then
						SnailLogic:SpecialCoverSnailRoadAtPos( mainLogic, r, c )
					end
					GameExtandPlayLogic:doABlocker211Collect(mainLogic, nil, nil, r, c, 0, true, 3)
				end

				------------------------ for test -----------------------------
				--[[
				local bboard = nil
				if mainLogic.boardmap[r] then
					bboard = mainLogic.boardmap[r][c]
				end

				if bboard then
					bboard:setGravity( BoardGravityDirection.kDown )
					bboard:setGravitySkinType( BoardGravitySkinType.kNone )
					bboard.isNeedUpdate = true
				end
				]]
				---------------------------------------------------------------
			end

			mainLogic:setNeedCheckFalling()
		end

		if theAction.addInfo == "bomb" then

			if theAction.jsq == 1 then
				
			elseif theAction.jsq == 18 then
				explodeItem(r1 + 1 , c1)
				explodeItem(r1 - 1 , c1)
				explodeItem(r1     , c1 + 1)
				explodeItem(r1     , c1 - 1)
			elseif theAction.jsq == 19 then
				explodeItem(r1 + 1 , c1 + 1)
				explodeItem(r1 + 1 , c1 - 1)
				explodeItem(r1 - 1 , c1 + 1)
				explodeItem(r1 - 1 , c1 - 1)

				explodeItem(r1     , c1 , true)
				item:cleanAnimalLikeData()

				theAction.addInfo = "over"
			end

		elseif theAction.addInfo == "over" then
			GameExtandPlayLogic:doAllBlocker195Collect(mainLogic, r1, c1, Blocker195CollectType.kPuffer)
			SquidLogic:checkSquidCollectItem(mainLogic, r1, c1, TileConst.kPufferActivated)
			mainLogic.destructionPlanList[actid] = nil
			mainLogic:checkItemBlock(r1, c1)
			if theAction.completeCallback then
				theAction.completeCallback()
			end
		end
	end
end



function DestructionPlanLogic:runGameItemActionDripCasting(boardView, theAction)

	local r1, c1 = theAction.ItemPos1.x, theAction.ItemPos1.y

	local function creatFlyAnimation(count)
		if not theAction.fromPosEffs then theAction.fromPosEffs = {} end
		if not theAction.flyEffs then theAction.flyEffs = {} end

		local createEff = function ( tarindex , showEff )
			if not boardView.gameBoardLogic or boardView.gameBoardLogic.isDisposed then
				return
			end
			
			if not boardView or boardView.isDisposed then
				return
			end

			if showEff then
				local fromPosEff = TileDrip:createEff( "dirp_eff_explode_1" )
				fromPosEff:setPosition( ccp( theAction.fromPos.x , theAction.fromPos.y ) )
				boardView:addChild( fromPosEff )
				table.insert( theAction.fromPosEffs , fromPosEff )
			end

			local eff = TileDrip:createEff( "drip_eff_fly" )
			eff:setPosition( ccp( theAction.fromPos.x , theAction.fromPos.y ) )
			eff.body:setPositionY(5)
			eff.body:playByIndex(0)
			boardView:addChild( eff )

			if theAction.toPosList and theAction.toPosList[tarindex] then
				local actArr2 = CCArray:create()
				actArr2:addObject( CCEaseSineOut:create( 
					CCMoveTo:create( 0.4 , ccp(theAction.toPosList[tarindex].x , theAction.toPosList[tarindex].y)) )  )
				actArr2:addObject( CCCallFunc:create( function ()  

				end ) )
				eff:runAction( CCSequence:create(actArr2) )
			else
			end
			

			table.insert( theAction.flyEffs , eff )

		end

		for i = 1 , count do
			local delayTime = ((i - 1) * 0.125) + 0.01
			setTimeOut( function () createEff(i , i == 1) end , delayTime )
		end
		
	end

	local function creatOnHitAnimation(index , toPos)

		local eff1 = theAction.fromPosEffs[index]
		if eff1 and not eff1.isDisposed then 
			eff1:removeFromParentAndCleanup(true) 
		end
		local eff2 = theAction.flyEffs[index]
		if eff2 and not eff2.isDisposed then 
			eff2:removeFromParentAndCleanup(true) 
		end

		if not toPos then return end

		local eff3 = TileDrip:createEff( "dirp_eff_explode_2" )
		eff3:setPosition( ccp( toPos.x , toPos.y ) )
		boardView:addChild( eff3 )

		local actArr3 = CCArray:create()
		actArr3:addObject( CCDelayTime:create( 1 )  )
		actArr3:addObject( CCCallFunc:create( function ()  
			if eff3 and not eff3.isDisposed then eff3:removeFromParentAndCleanup(true) end
		end ) )
		eff3:runAction( CCSequence:create(actArr3) )
	end

	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning

		theAction.addInfo = "checkMatch"
		theAction.jsq = 0
	else
		if theAction.addInfo == "playLeaderUpgradeAndCasting" then

			theAction.jsq = theAction.jsq + 1
			
			if theAction.jsq == 1 then

				local leaderView = boardView.baseMap[r1][c1]
				leaderView.isNeedUpdate = true
				local fromPos = leaderView:getBasePosition( c1 , r1 )
				local toPosList = {}

				for ia = 1 , #theAction.castingTarget do
					local tp = leaderView:getBasePosition( theAction.castingTarget[ia].x , theAction.castingTarget[ia].y )
					tp.x = tp.x + 35
					tp.y = tp.y - 35
					table.insert( toPosList , tp )
				end
				
				theAction.fromPos = fromPos
				theAction.toPosList = toPosList

				--[[
				if theAction.targetBoss then
					local bosspos = theAction.toPosList[1]
					table.insert( theAction.toPosList , bosspos )
					table.insert( theAction.toPosList , bosspos )
					--Boss无论发射几次，都命中同一个格子
				end
				]]

			elseif theAction.jsq == 25 then
				
				if theAction.dripMatchCount == 3 then
					creatFlyAnimation( 1 , theAction.fromPos , theAction.toPosList )
				elseif theAction.dripMatchCount == 4 then
					creatFlyAnimation( 2 , theAction.fromPos , theAction.toPosList )
				elseif theAction.dripMatchCount >= 5 then
					creatFlyAnimation( 3 , theAction.fromPos , theAction.toPosList )
				else
					creatFlyAnimation( 1 , theAction.fromPos , theAction.toPosList )
				end

			elseif theAction.jsq == 43 then
				theAction.addInfo = "deleteLeader"
			elseif theAction.jsq == 45 then
				creatOnHitAnimation(1 , theAction.toPosList[1])
				--if theAction.dripMatchCount == 3 then
					theAction.addInfo = "reachTarget1"
				--end
			elseif theAction.jsq == 55 then
				creatOnHitAnimation(2 , theAction.toPosList[2])
				--if theAction.dripMatchCount == 4 then
					theAction.addInfo = "reachTarget2"
				--end
			elseif theAction.jsq == 65 then
				creatOnHitAnimation(3 , theAction.toPosList[3])
				theAction.addInfo = "reachTarget3"
			end
		elseif theAction.addInfo == "playMove" then
			theAction.jsq = theAction.jsq + 1

			local moveView = boardView.baseMap[r1][c1]
			if theAction.jsq == 1 then
				moveView.isNeedUpdate = true
			elseif theAction.jsq == 18 then
				theAction.addInfo = "deleteMacthItem"
			end
		end
	end
end

function DestructionPlanLogic:runningGameItemActionDripCasting(mainLogic, theAction, actid)
	if theAction.actionStatus == GameActionStatus.kRunning then

		local r1 , c1 = theAction.ItemPos1.x, theAction.ItemPos1.y
		local item = mainLogic.gameItemMap[r1][c1]

		theAction.dripMatchCount = item.dripMatchCount
		local filterMap = {}
		--theAction.dripMatchCount = 5

		local function getCastingListByKeyItem(keyItem)
			local castingList = {}
			table.insert( castingList , keyItem )
			--printx( 1 , "   keyItemkeyItemkeyItemkeyItemkeyItemkeyItemkeyItem =  " , keyItem , keyItem.x)
			if mainLogic.gameItemMap[keyItem.y][keyItem.x + 1] then 
				table.insert( castingList , mainLogic.gameItemMap[keyItem.y][keyItem.x + 1] ) 
			end

			if mainLogic.gameItemMap[keyItem.y + 1] then
				if mainLogic.gameItemMap[keyItem.y + 1][keyItem.x + 1] then 
					table.insert( castingList , mainLogic.gameItemMap[keyItem.y + 1][keyItem.x + 1] ) 
				end
				if mainLogic.gameItemMap[keyItem.y + 1][keyItem.x] then
					table.insert( castingList , mainLogic.gameItemMap[keyItem.y + 1][keyItem.x] ) 
				end
			end
			return castingList
		end

		local function checkGrid(keyItem)
			
			local castingList = getCastingListByKeyItem(keyItem)
			local keyItemY = keyItem.y
			local hasJewelOnKeyItemY = false
			local hasCloudOnKeyItemY = false
			local hasFilterItem = false
			local checkItem = nil
			local jewel = 0
			local cloud = 0
			local available = false
			for i = 1 , #castingList do

				checkItem = castingList[i]

				if filterMap[ tostring(checkItem.x) .. "_" .. tostring(checkItem.y) ] then
					if checkItem.x ~= 2 and checkItem.x ~= 8 and checkItem.y ~= 2 and checkItem.y ~= 8 then
						hasFilterItem = true
					end
				else
					if checkItem.ItemType == GameItemType.kDigJewel then
						jewel = jewel + 1
						if checkItem.y == keyItemY then
							hasJewelOnKeyItemY = true
						end
					end
					if checkItem.ItemType == GameItemType.kDigGround then
						cloud = cloud + 1
						if checkItem.y == keyItemY then
							hasCloudOnKeyItemY = true
						end
					end

					if checkItem.ItemType == GameItemType.kRandomProp or checkItem.ItemType == GameItemType.kChestSquare
	   		 					or checkItem.ItemType == GameItemType.kChestSquarePart then
						cloud = cloud + 1
						if checkItem.y == keyItemY then
							hasCloudOnKeyItemY = true
						end
					end


					if checkItem.x <= 9 and checkItem.y <= 9 then
						available = true
					end
				end
			end

			if not hasJewelOnKeyItemY and not hasCloudOnKeyItemY then
				jewel = 0
				cloud = 0
			end

			if hasFilterItem then
				jewel = 0
				cloud = 0
				available = false
			end

			return { jewel = jewel , cloud = cloud , available = available }
		end

		local function getCastingTarget( needCount )

			filterMap = {}
			filterMap[ tostring(c1) .. "_" .. tostring(r1) ] = true
			local findTarget = function ()
					--GameItemType.kBoss
				local checkItem = nil
				local bossList = {}
				local weeklyBossList = {}
				local blockList = {}
				local cloudList = {}
				local jewelList = {}
				local animalList = {}
				local allList = {}



				--先算出一个target坐标，然后以此为左上点，取四格
				for r = 1, #mainLogic.gameItemMap do--屏幕最下排不用检测
	   		 		for c = 1, #mainLogic.gameItemMap[r] do--屏幕最右侧不用检测
	   		 			checkItem = mainLogic.gameItemMap[r][c]
	   		 			if checkItem and not filterMap[ tostring(checkItem.x) .. "_" .. tostring(checkItem.y) ] then
	   		 				if checkItem.ItemType == GameItemType.kBoss and checkItem.bossLevel > 0 and checkItem.blood ~= nil and checkItem.blood > 0 then
	   		 					table.insert( bossList , checkItem )
	   		 				elseif checkItem.ItemType == GameItemType.kWeeklyBoss and checkItem.weeklyBossLevel > 0 and checkItem.blood ~= nil and checkItem.blood > 0 then
	   		 					table.insert( weeklyBossList , checkItem )
	   		 				elseif checkItem.ItemType == GameItemType.kDigGround or checkItem.ItemType == GameItemType.kDigJewel
	   		 					or checkItem.ItemType == GameItemType.kRandomProp or checkItem.ItemType == GameItemType.kChestSquare
	   		 					or checkItem.ItemType == GameItemType.kChestSquarePart  then
	   		 					table.insert( blockList , checkItem )


	   		 					if checkItem.ItemType == GameItemType.kDigGround 
	   		 					or checkItem.ItemType == GameItemType.kRandomProp or checkItem.ItemType == GameItemType.kChestSquare
	   		 					or checkItem.ItemType == GameItemType.kChestSquarePart
	   		 					then
	   		 						table.insert( cloudList , checkItem )
	   		 					elseif checkItem.ItemType == GameItemType.kDigJewel then
	   		 						table.insert( jewelList , checkItem )
	   		 					else
	   		 						table.insert( cloudList , checkItem ) 
	   		 					end
	   		 				elseif checkItem.ItemType == GameItemType.kAnimal and not AnimalTypeConfig.isSpecialTypeValid(checkItem.ItemSpecialType) then
	   		 					table.insert( animalList , checkItem )
	   		 				end
	   		 				table.insert( allList , checkItem )
	   		 			end
	   		 		end
	   		 	end
	   		 	--bossList = {}
	   		 	if #bossList > 0 then
	   		 		theAction.targetBoss = true
	   		 		return bossList[1]
	   		 	elseif #weeklyBossList > 0 then 
	   		 		theAction.targetBoss = true
	   		 		return weeklyBossList[1]
	   		 	elseif #blockList > 0 then
	   		 		
	   		 		local topBlockY = 9
   		 			local topBlock = {}
   		 			local topList = {}
   		 			local checkitem = nil

   		 			for i = 1 , #blockList do
   		 				if blockList[i].y < topBlockY then
   		 					topBlockY = blockList[i].y
   		 				end
   		 			end

   		 			--if topBlockY == 9 then topBlockY = 8 end
   		 			for c = 1, #mainLogic.gameItemMap[topBlockY] - 1 do

   		 				checkitem = mainLogic.gameItemMap[topBlockY][c]
   		 				--if not filterMap[ tostring(checkitem.x) .. "_" .. tostring(checkitem.y) ] then
   		 					table.insert( topList , checkitem )
   		 				--end
   		 				
   		 			end

   		 			for i = 1 , #blockList do
   		 				if blockList[i].y == topBlockY then
   		 					table.insert( topBlock , blockList[i] )
   		 				end
   		 			end

   		 			local maxJewel = 0
   		 			local maxJewelList = {}
   		 			local maxCloud = 0
   		 			local maxCloudList = {}


   		 			for i = 1 , #topList do
   		 				if maxJewel < checkGrid( topList[i] ).jewel then
   		 					maxJewel = checkGrid( topList[i] ).jewel
   		 				end
   		 			end

   		 			if maxJewel > 0 then
   		 				for i = 1 , #topList do
	   		 				if maxJewel == checkGrid( topList[i] ).jewel then
	   		 					table.insert( maxJewelList , topList[i] )
	   		 				end
	   		 			end

	   		 			for i = 1 , #maxJewelList do
   		 					if maxCloud < checkGrid( maxJewelList[i] ).cloud then
	   		 					maxCloud = checkGrid( maxJewelList[i] ).cloud
	   		 				end
	   		 			end

	   		 			for i = 1 , #maxJewelList do
	   		 				if maxCloud == checkGrid( maxJewelList[i] ).cloud then
	   		 					table.insert( maxCloudList , maxJewelList[i] )
	   		 				end
	   		 			end
   		 			else
   		 				for i = 1 , #topList do
			 				if maxCloud < checkGrid( topList[i] ).cloud then
	   		 					maxCloud = checkGrid( topList[i] ).cloud
	   		 				end
	   		 			end

	   		 			for i = 1 , #topList do
	   		 				if maxCloud == checkGrid( topList[i] ).cloud then
	   		 					table.insert( maxCloudList , topList[i] )
	   		 				end
	   		 			end
   		 			end


   		 			if maxJewel > 0 then

   		 				if #maxJewelList > 1 then

		   		 			if #maxCloudList > 1 then
		   		 				local idx = mainLogic.randFactory:rand(1, #maxCloudList)
		   		 				return maxCloudList[idx]
		   		 			else
		   		 				return maxCloudList[1]
		   		 			end

   		 				else
   		 					return maxJewelList[1]
   		 				end
   		 				
   		 			else
   		 				
   		 				if #maxCloudList > 1 then
	   		 				local idx = mainLogic.randFactory:rand(1, #maxCloudList)
	   		 				return maxCloudList[idx]
	   		 			else
	   		 				return maxCloudList[1]
	   		 			end

   		 			end

	   		 	elseif #animalList > 0 then
	   		 		local availableAniamlList = {}
	   		 		for i = 1 , #animalList do
	   		 			if checkGrid( animalList[i] ).available then
	   		 				table.insert( availableAniamlList , animalList[i] )
	   		 			end
	   		 		end

	   		 		if #availableAniamlList > 0 then
	   		 			local idx = mainLogic.randFactory:rand(1, #availableAniamlList)
		   		 		return availableAniamlList[idx]
	   		 		end
	   		 	elseif #allList > 0 then
	   		 		local availableAllList = {}
	   		 		for i = 1 , #allList do
	   		 			if checkGrid( allList[i] ).available then
	   		 				table.insert( availableAllList , allList[i] )
	   		 			end
	   		 		end
	   		 		local idx = mainLogic.randFactory:rand(1, #availableAllList)
		   		 	return availableAllList[idx]
	   		 	end

				return {}
			end
			
			local resultList = {}
			for i = 1 , needCount do
				local rst = findTarget()
				if rst then

					if rst.y == 9 then
						local newrst = mainLogic.gameItemMap[8][rst.x]
						if newrst then
							rst = newrst
						else
							break
						end
					end

					if rst.x == 9 then
						local newrst = mainLogic.gameItemMap[rst.y][8]
						if newrst then
							rst = newrst
						else
							break
						end
					end
					
					--printx( 1 , "  FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF   rst.x " , rst.x , "   rst.y " , rst.y)
					filterMap[ tostring(rst.x) .. "_" .. tostring(rst.y) ] = true
					filterMap[ tostring(rst.x + 1) .. "_" .. tostring(rst.y) ] = true
					filterMap[ tostring(rst.x) .. "_" .. tostring(rst.y + 1) ] = true
					filterMap[ tostring(rst.x + 1) .. "_" .. tostring(rst.y + 1) ] = true
					--[[
					if rst.x - 1 ~= 1 then
						filterMap[ tostring(rst.x - 1) .. "_" .. tostring(rst.y) ] = true
						filterMap[ tostring(rst.x - 1) .. "_" .. tostring(rst.y + 1) ] = true
					end

					if rst.y - 1 ~= 1 then
						filterMap[ tostring(rst.x) .. "_" .. tostring(rst.y - 1) ] = true
						filterMap[ tostring(rst.x + 1) .. "_" .. tostring(rst.y - 1) ] = true
					end
					
					if rst.x - 1 ~= 1 and rst.y - 1 ~= 1 then
						filterMap[ tostring(rst.x - 1) .. "_" .. tostring(rst.y - 1) ] = true
					end
					
					--]]

					table.insert( resultList , rst )
				end
			end
			
			return resultList
		end

		local function reachTarget(target , tarIndex)
			local castingList = getCastingListByKeyItem(target)
			for i = 1 , #castingList do
				local castingItem = castingList[i]
				if castingItem.ItemType == GameItemType.kBoss 
					or castingItem.ItemType == GameItemType.kWeeklyBoss 
					or castingItem.ItemType == GameItemType.kMoleBossCloud then

					local loseBlood = 5
					if theAction.dripMatchCount == 3 then
						loseBlood = 3
					elseif theAction.dripMatchCount == 4 then
						loseBlood = 4
					elseif theAction.dripMatchCount == 5 then
						loseBlood = 5
					end

					if castingItem.ItemType == GameItemType.kBoss and castingItem.bossLevel > 0 then
						--BombItemLogic:tryCoverByBomb(mainLogic, castingItem.y , castingItem.x , true, 1, true, true)
						GameExtandPlayLogic:MaydayBossLoseBlood(mainLogic, castingItem.y , castingItem.x , true , actid , loseBlood)
					elseif castingItem.ItemType == GameItemType.kWeeklyBoss and castingItem.weeklyBossLevel > 0 then
						GameExtandPlayLogic:WeeklyBossLoseBlood(mainLogic, castingItem.y , castingItem.x , true , actid , loseBlood)
					elseif castingItem.ItemType == GameItemType.kMoleBossCloud and castingItem.moleBossCloudLevel > 0 then
						MoleWeeklyRaceLogic:MoleBossCloudLoseBlood(mainLogic, castingItem.y , castingItem.x , true , actid , loseBlood)
					end
				else
					BombItemLogic:clearItemWithoutCover(mainLogic , castingItem.y , castingItem.x)
				end
			end
		end

		if theAction.addInfo == "checkMatch" then

			if item.dripState == DripState.kGrow then
				theAction.isLeader = true
			else
				theAction.isLeader = false
			end

			theAction.leaderPos = { x = item.dripLeaderPos.x , y = item.dripLeaderPos.y }
			theAction.jsq = 0

			if theAction.isLeader then
				theAction.addInfo = "waitingForUpgrade"
			else
				theAction.addInfo = "playMove"
				item.dripState = DripState.kMove
				item.isNeedUpdate = true
			end

		elseif theAction.addInfo == "waitingForUpgrade" then

			theAction.jsq = theAction.jsq + 1
			if theAction.jsq >= 7 then
				item.dripState = DripState.kCasting
				item.isNeedUpdate = true
				theAction.addInfo = "playLeaderUpgradeAndCasting"
				theAction.jsq = 0
				
				local needTarget = 3
				if theAction.dripMatchCount == 3 then
					needTarget = 1
				elseif theAction.dripMatchCount == 4 then
					needTarget = 2
				elseif theAction.dripMatchCount == 5 then
					needTarget = 3
				end

				theAction.castingTarget = getCastingTarget(needTarget)
				needTarget = #theAction.castingTarget

				if theAction.targetBoss then
					local bossTar = theAction.castingTarget[1]
					theAction.castingTarget = {}
					for i = 1 , needTarget do
						table.insert( theAction.castingTarget , bossTar )
					end
				end

				if #theAction.castingTarget == 0 then
					item:cleanAnimalLikeData()
					item.isNeedUpdate = true
					theAction.addInfo = "over"
				end
			end
		elseif theAction.addInfo == "deleteLeader" then

			item:cleanAnimalLikeData()
			item.isNeedUpdate = true

			theAction.leaderDeleted = true

			if theAction.allEffDeleted then
				theAction.addInfo = "over"
			else
				theAction.addInfo = "playLeaderUpgradeAndCasting"--第20帧删除发射体，在切回去继续计时
			end

		elseif theAction.addInfo == "reachTarget1" then
			local targetItem = theAction.castingTarget[1]
			if targetItem then reachTarget( targetItem , 1 ) end

			if theAction.dripMatchCount == 3 then
				if theAction.leaderDeleted then
					theAction.addInfo = "over"
				else
					theAction.allEffDeleted = true
					theAction.addInfo = "playLeaderUpgradeAndCasting"
				end
			else
				theAction.addInfo = "playLeaderUpgradeAndCasting"
			end
			
		elseif theAction.addInfo == "reachTarget2" then
			local targetItem = theAction.castingTarget[2]
			if not theAction.targetBoss and targetItem then reachTarget( targetItem , 2 ) end

			if theAction.dripMatchCount == 4 then
				if theAction.leaderDeleted then
					theAction.addInfo = "over"
				else
					theAction.allEffDeleted = true
					theAction.addInfo = "playLeaderUpgradeAndCasting"
				end
			else
				theAction.addInfo = "playLeaderUpgradeAndCasting"
			end
		elseif theAction.addInfo == "reachTarget3" then
			local targetItem = theAction.castingTarget[3]
			if not theAction.targetBoss and targetItem then reachTarget( targetItem , 3 ) end
			if theAction.leaderDeleted then
				theAction.addInfo = "over"
			else
				theAction.allEffDeleted = true
				theAction.addInfo = "playLeaderUpgradeAndCasting"
			end
		elseif theAction.addInfo == "deleteMacthItem" then

			item:cleanAnimalLikeData()
			item.isNeedUpdate = true
			theAction.addInfo = "over"

		elseif theAction.addInfo == "over" then
			----[[
			--printx( 1 , "   DestructionPlanLogic:runningGameItemActionDripCasting   -----------   r = " , r1 , "  c = " , c1 ,  "  isLeader = " , theAction.isLeader )
			mainLogic:checkItemBlock(r1, c1)
			mainLogic:setNeedCheckFalling()
			mainLogic.destructionPlanList[actid] = nil
			if theAction.completeCallback then
				theAction.completeCallback()
			end
			--]]
		end
	end
end

--[[
function DestructionPlanLogic:runGameItemActionHalloweenBossClearLine(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		theAction.frameCount = 0
		theAction.moveCount = 0
		theAction.addInfo = 'play'
		local position1 = DestructionPlanLogic:getItemPosition({x = 9, y = 5})
		local effect = CommonEffect:buildRainbowLineEffect(boardView.rainbowBatch)
		effect:setPosition(position1)
		
		boardView.rainbowBatch:addChild(effect)

		-- local position2 = DestructionPlanLogic:getItemPosition({x = 5, y = 5})
		-- local effect2 = CommonEffect:buildRainbowLineEffect(boardView.rainbowBatch)
		-- effect2:setPosition(position2)
		-- effect2:setRotation(90)
		
		-- boardView.rainbowBatch:addChild(effect2)
	end
end

function DestructionPlanLogic:runningGameItemActionHalloweenBossClearLine(mainLogic, theAction, actid)
	if theAction.addInfo == 'play' then
		theAction.frameCount = theAction.frameCount + 1
		local function clearItem(row,col)
			local clearItem = mainLogic.gameItemMap[row][col]
			BombItemLogic:forceClearItemWithCover(mainLogic , row , col)
		end
		if theAction.frameCount >= GamePlayConfig_SpecialBomb_Line_Add_CD then
			theAction.frameCount = 0		

			local index1, index2 = 5 + theAction.moveCount, 5 - theAction.moveCount
			if index1 > 9 or index2 < 1 then
				theAction.addInfo = 'over'
			else
				if index2 == index1 and index1 == 5 then
					clearItem(9, 5)
				elseif index1 <= 9 and index2 >= 1 then
					clearItem(9, index1)
					clearItem(9, index2)
				end
				mainLogic:setNeedCheckFalling()
				theAction.moveCount = theAction.moveCount + 1
			end
		end
		if not theAction.clearedColumn then
			for i = 3, 9 do
				clearItem(i, 5)
			end
			theAction.clearedColumn = true
		end
	elseif theAction.addInfo == 'over' then
		mainLogic:setNeedCheckFalling()
		mainLogic.destructionPlanList[actid] = nil
		if theAction.completeCallback then
			theAction.completeCallback()
		end
	end
end
]]

--[[
function DestructionPlanLogic:runGameItemSuperTotemsExplodeAction(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning

		theAction.actionTick = 1
		theAction.addInfo = "start"
	elseif theAction.addInfo == "startBomb" then
		local r1, c1 = theAction.ItemPos1.x, theAction.ItemPos1.y
		local r2, c2 = theAction.ItemPos2.x, theAction.ItemPos2.y

		local linkToPos = IntCoord:create(r2, c2)
		local item1 = boardView.baseMap[r1][c1]
		item1:playSuperTotemsWaittingExplode(linkToPos)
		item1.isNeedUpdate = true

		local item2 = boardView.baseMap[r2][c2]
		item2:playSuperTotemsWaittingExplode()
		item2.isNeedUpdate = true

		if theAction.isLongWaitTime then
			local layer = LayerColor:create()
			local size = Director:sharedDirector():getWinSize()
			layer:setContentSize(size)
			layer:setOpacity(180)
			local scene = Director:sharedDirector():getRunningScene()
			scene:addChild(layer)
			theAction.guideMask = layer
			
			local pos1 = layer:convertToNodeSpace(item1.itemSprite[ItemSpriteType.kItemShow]:getParent():convertToWorldSpace(item1:getBasePosition(r1, c1)))
			local pos2 = layer:convertToNodeSpace(item1.itemSprite[ItemSpriteType.kItemShow]:getParent():convertToWorldSpace(item1:getBasePosition(r2, c2)))
			local waittingAnimate1 = TileTotemsAnimation:buildTotemsWattingExplodeAnimate()
			waittingAnimate1:setPosition(pos1)
			local targetPos = layer:convertToNodeSpace(item1.itemSprite[ItemSpriteType.kItemShow]:getParent():convertToWorldSpace(item1:getBasePosition(r2, c2)))
			local lightningAnimate = TileTotemsAnimation:buildTotemsExplodeLightning(pos1, targetPos)
			lightningAnimate:setPosition(pos1)
			local waittingAnimate2 = TileTotemsAnimation:buildTotemsWattingExplodeAnimate()
			waittingAnimate2:setPosition(pos2)
			layer:addChild(lightningAnimate)
			layer:addChild(waittingAnimate1)
			layer:addChild(waittingAnimate2)


			local image = Sprite:createWithSpriteFrameName('guides_super_bird.png')
			image:setAnchorPoint(ccp(0, 0))
			image:setScaleX((pos1.x-pos2.x) / image:getGroupBounds().size.width + 0.2)
			image:setScaleY((pos1.y-pos2.y) / image:getGroupBounds().size.height + 0.22)
			layer:addChild(image)
			local pos = layer:convertToNodeSpace(ccp(pos2.x, pos2.y))
			image:setPosition(ccp(pos.x - 50, pos.y - 50))


		end
	elseif theAction.addInfo == "bombSelf" then
		local r1, c1 = theAction.ItemPos1.x, theAction.ItemPos1.y
		local item1 = boardView.baseMap[r1][c1]
		item1:playSuperTotemsDestoryAnimate()

		local r2, c2 = theAction.ItemPos2.x, theAction.ItemPos2.y
		local item2 = boardView.baseMap[r2][c2]
		item2:playSuperTotemsDestoryAnimate()
	end
end
]]

function DestructionPlanLogic:runGameItemSuperTotemsExplodePart1Action(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning

		theAction.actionTick = 1
		theAction.addInfo = "start"
	elseif theAction.addInfo == "startBomb" then
		local r1, c1 = theAction.ItemPos1.x, theAction.ItemPos1.y
		local r2, c2 = theAction.ItemPos2.x, theAction.ItemPos2.y

		local linkToPos = IntCoord:create(r2, c2)
		local item1 = boardView.baseMap[r1][c1]
		item1:playSuperTotemsWaittingExplode(linkToPos)
		item1.isNeedUpdate = true

		local item2 = boardView.baseMap[r2][c2]
		item2:playSuperTotemsWaittingExplode()
		item2.isNeedUpdate = true

		if theAction.isLongWaitTime then
			local layer = LayerColor:create()
			local size = Director:sharedDirector():getWinSize()
			layer:setContentSize(size)
			layer:setOpacity(180)
			local scene = Director:sharedDirector():getRunningScene()
			scene:addChild(layer)
			theAction.guideMask = layer
			
			local pos1 = layer:convertToNodeSpace(item1.itemSprite[ItemSpriteType.kItemShow]:getParent():convertToWorldSpace(item1:getBasePosition(r1, c1)))
			local pos2 = layer:convertToNodeSpace(item1.itemSprite[ItemSpriteType.kItemShow]:getParent():convertToWorldSpace(item1:getBasePosition(r2, c2)))
			local waittingAnimate1 = TileTotemsAnimation:buildTotemsWattingExplodeAnimate()
			waittingAnimate1:setPosition(pos1)
			local targetPos = layer:convertToNodeSpace(item1.itemSprite[ItemSpriteType.kItemShow]:getParent():convertToWorldSpace(item1:getBasePosition(r2, c2)))
			local lightningAnimate = TileTotemsAnimation:buildTotemsExplodeLightning(pos1, targetPos)
			lightningAnimate:setPosition(pos1)
			local waittingAnimate2 = TileTotemsAnimation:buildTotemsWattingExplodeAnimate()
			waittingAnimate2:setPosition(pos2)
			layer:addChild(lightningAnimate)
			layer:addChild(waittingAnimate1)
			layer:addChild(waittingAnimate2)

			local image = Sprite:createWithSpriteFrameName('guides_super_bird.png')
			image:setAnchorPoint(ccp(0, 0))
			image:setScaleX((pos1.x-pos2.x) / image:getGroupBounds().size.width + 0.4)
			image:setScaleY((pos1.y-pos2.y) / image:getGroupBounds().size.height + 0.44)
			layer:addChild(image)
			local pos = layer:convertToNodeSpace(ccp(pos2.x, pos2.y))
			image:setPosition(ccp(pos.x - 50, pos.y - 50))
		end
	end
end

function DestructionPlanLogic:runGameItemSuperTotemsExplodePart2Action(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning

		theAction.actionTick = 1
		theAction.addInfo = "start"
	elseif theAction.addInfo == "bombSelf" then
		local r1, c1 = theAction.ItemPos1.x, theAction.ItemPos1.y
		local item1 = boardView.baseMap[r1][c1]
		item1:playSuperTotemsDestoryAnimate()

		local r2, c2 = theAction.ItemPos2.x, theAction.ItemPos2.y
		local item2 = boardView.baseMap[r2][c2]
		item2:playSuperTotemsDestoryAnimate()
	end
end

--[[
function DestructionPlanLogic:runingGameItemSuperTotemsExplodeAction(mainLogic, theAction, actid)
	if theAction.actionStatus == GameActionStatus.kRunning then
		if theAction.addInfo == "start" then
			theAction.addInfo = "waiting1"
			theAction.actionTick = 1
			if GameGuide and GameGuide:sharedInstance().pauseBoardUpdateForSuperBird == true and not theAction.isGuidePlayed then
				GameGuide:sharedInstance().pauseBoardUpdateForSuperBird = false
				theAction.isGuidePlayed = true
				theAction.waitingTime = GamePlayConfig_Action_FPS * (GameGuide:sharedInstance().pauseTime or 3)
				theAction.isLongWaitTime = true
			else
				theAction.waitingTime = 10
				theAction.isLongWaitTime = false
			end
		elseif theAction.addInfo == "waiting1" then -- 等待小金刚变身
			if theAction.actionTick == 8 then
				theAction.addInfo = "startBomb"
			end
			theAction.actionTick = theAction.actionTick + 1
		elseif theAction.addInfo == "startBomb" then -- 播放等待爆炸动画和地格提示动画
			GameExtandPlayLogic:playTileHighlight(mainLogic, TileHighlightType.kTotems, theAction.ItemPos1, theAction.ItemPos2)
			theAction.addInfo = "waiting2"

		elseif theAction.addInfo == "waiting2" then -- 等待棋盘稳定后爆掉区域内的动物
			if mainLogic:isItemAllStable() then
				theAction.addInfo = "waiting3"
				theAction.actionTick = 1
			end
		elseif theAction.addInfo == "waiting3" then
			
			if theAction.actionTick == theAction.waitingTime then
				theAction.addInfo = "bombAll"
				if theAction.guideMask and not theAction.guideMask.isDisposed then
					theAction.guideMask:removeFromParentAndCleanup(true)
					theAction.guideMask = nil
				end
			end
			theAction.actionTick = theAction.actionTick + 1


		elseif theAction.addInfo == "bombAll" then
			local r1, c1 = theAction.ItemPos1.x, theAction.ItemPos1.y
			local r2, c2 = theAction.ItemPos2.x, theAction.ItemPos2.y

			local fromR, toR = r1, r2
			if fromR > toR then
				fromR, toR = toR, fromR
			end
			local fromC, toC = c1, c2
			if fromC > toC then
				fromC, toC = toC, fromC
			end

			local scoreScale = GamePlayConfig_Score_SuperTotems_Scale
			for r = fromR, toR do
				for c = fromC, toC do
					if mainLogic:isPosValid(r, c) then
						if not DestructionPlanLogic:existInSpecialBombLightUpPos(mainLogic, r, c, theAction.lightUpBombMatchPosList) then
							SpecialCoverLogic:SpecialCoverLightUpAtPos(mainLogic, r, c, scoreScale)
						end
						BombItemLogic:tryCoverByBomb(mainLogic, r, c, true, scoreScale)
						SpecialCoverLogic:SpecialCoverAtPos(mainLogic, r, c, 3, scoreScale, actid)
						local breakDirs = {}
						if r > fromR then table.insert(breakDirs, ChainDirConfig.kUp) end
						if r < toR then table.insert(breakDirs, ChainDirConfig.kDown) end
						if c > fromC then table.insert(breakDirs, ChainDirConfig.kLeft) end
						if c < toC then table.insert(breakDirs, ChainDirConfig.kRight) end
						SpecialCoverLogic:specialCoverChainsAtPos(mainLogic, r, c, breakDirs)
					end
				end
			end	
			GameExtandPlayLogic:stopTileHighlight(mainLogic, theAction.ItemPos1, theAction.ItemPos2)

			theAction.addInfo = "bombSelf"
		elseif theAction.addInfo == "bombSelf" then
			-- add scores
			local r1, c1 = theAction.ItemPos1.x, theAction.ItemPos1.y
			local r2, c2 = theAction.ItemPos2.x, theAction.ItemPos2.y
			mainLogic:addScoreToTotal(r1, c1, GamePlayConfigScore.SuperTotems)
			mainLogic:addScoreToTotal(r2, c2, GamePlayConfigScore.SuperTotems)
			
			theAction.addInfo = "over"
		elseif theAction.addInfo == "over" then
			local function removeCallback(board, item, r, c)
				--在“bombAll”阶段尝试点亮蜗牛路径，但是因为两只蜗牛数据没清空没法点亮，所以这里再次调用一次
				SnailLogic:SpecialCoverSnailRoadAtPos(mainLogic, r, c)
				if board.blockerCoverMaterialLevel > 0 then
					SpecialCoverLogic:doEffectblockerCoverMaterial(mainLogic, r, c)
					return
				end

				if board.iceLevel > 0 and board.blockerCoverMaterialLevel == 0 then
					SpecialCoverLogic:doEffectLightUpAtPos(mainLogic, r, c, 1)
				end

				if board.sandLevel > 0 and board.blockerCoverMaterialLevel == 0 then
					SpecialCoverLogic:doEffectSandAtPos(mainLogic, r, c)
				end
			end

			local r1, c1 = theAction.ItemPos1.x, theAction.ItemPos1.y
			local r2, c2 = theAction.ItemPos2.x, theAction.ItemPos2.y		
			local item1 = mainLogic.gameItemMap[r1][c1]
			local board1 = mainLogic.boardmap[r1][c1]
			removeCallback(board1, item1, r1, c1)
			item1:cleanAnimalLikeData()
			mainLogic:checkItemBlock(r1, c1)
			item1.isNeedUpdate = true

			local item2 = mainLogic.gameItemMap[r2][c2]
			local board2 = mainLogic.boardmap[r2][c2]
			removeCallback(board2, item2, r2, c2)
			item2:cleanAnimalLikeData()
			mainLogic:checkItemBlock(r2, c2)
			item2.isNeedUpdate = true

			theAction.actionStatus = GameActionStatus.kWaitingForDeath
		end
	end
end
]]

function DestructionPlanLogic:runingGameItemSuperTotemsExplodePart1Action(mainLogic, theAction, actid)
	if theAction.actionStatus == GameActionStatus.kRunning then
		if theAction.addInfo == "start" then
			theAction.addInfo = "waiting1"
			theAction.actionTick = 1
			if GameGuide and GameGuide:sharedInstance().pauseBoardUpdateForSuperBird == true and not theAction.isGuidePlayed then
				GameGuide:sharedInstance().pauseBoardUpdateForSuperBird = false
				theAction.isGuidePlayed = true
				theAction.waitingTime = GamePlayConfig_Action_FPS * (GameGuide:sharedInstance().pauseTime or 3)
				theAction.isLongWaitTime = true
			else
				theAction.waitingTime = 10
				theAction.isLongWaitTime = false
			end
		elseif theAction.addInfo == "waiting1" then -- 等待小金刚变身
			if theAction.actionTick == 8 then
				theAction.addInfo = "startBomb"
			end
			theAction.actionTick = theAction.actionTick + 1
		elseif theAction.addInfo == "startBomb" then -- 播放等待爆炸动画和地格提示动画
			GameExtandPlayLogic:playTileHighlight(mainLogic, TileHighlightType.kTotems, theAction.ItemPos1, theAction.ItemPos2)
			theAction.addInfo = "over"
		elseif theAction.addInfo == "over" then
			local part2Action = GameBoardActionDataSet:createAs(
				GameActionTargetType.kGameItemAction,
				GameItemActionType.kItem_SuperTotems_Explode_part2,
				IntCoord:create(theAction.ItemPos1.x, theAction.ItemPos1.y),
				IntCoord:create(theAction.ItemPos2.x, theAction.ItemPos2.y),
				GamePlayConfig_MaxAction_time
				)
			part2Action.waitingTime = theAction.waitingTime
			part2Action.guideMask = theAction.guideMask
			-- part2Action.isGuidePlayed = theAction.isGuidePlayed		--应该是没有用
			-- part2Action.isLongWaitTime = theAction.isLongWaitTime	--应该是用不上了
			mainLogic:addStableDestructionPlanAction(part2Action)

			theAction.actionStatus = GameActionStatus.kWaitingForDeath
		end
	end
end

function DestructionPlanLogic:runingGameItemSuperTotemsExplodePart2Action(mainLogic, theAction, actid)

	if theAction.actionStatus == GameActionStatus.kRunning then
		if theAction.addInfo == "start" then -- 等待棋盘稳定后爆掉区域内的动物
			local passPosMap = {}
			passPosMap[tostring(theAction.ItemPos1.x) .. "_" .. tostring(theAction.ItemPos1.y)] = true
			passPosMap[tostring(theAction.ItemPos2.x) .. "_" .. tostring(theAction.ItemPos2.y)] = true

			if mainLogic:isItemAllStable( passPosMap ) then
				theAction.addInfo = "waiting3"
				theAction.actionTick = 1
			end
		elseif theAction.addInfo == "waiting3" then
			
			if theAction.actionTick == theAction.waitingTime then
				theAction.addInfo = "bombAll"
				if theAction.guideMask and not theAction.guideMask.isDisposed then
					theAction.guideMask:removeFromParentAndCleanup(true)
					theAction.guideMask = nil
				end
			end
			theAction.actionTick = theAction.actionTick + 1


		elseif theAction.addInfo == "bombAll" then
			local r1, c1 = theAction.ItemPos1.x, theAction.ItemPos1.y
			local r2, c2 = theAction.ItemPos2.x, theAction.ItemPos2.y

			local fromR, toR = r1, r2
			if fromR > toR then
				fromR, toR = toR, fromR
			end
			local fromC, toC = c1, c2
			if fromC > toC then
				fromC, toC = toC, fromC
			end

            local SpecialID = mainLogic:addSrcSpecialCoverToList( theAction.ItemPos1, theAction.ItemPos2 )

			local scoreScale = GamePlayConfig_Score_SuperTotems_Scale
			for r = fromR, toR do
				for c = fromC, toC do
					if mainLogic:isPosValid(r, c) then
						if not DestructionPlanLogic:existInSpecialBombLightUpPos(mainLogic, r, c, theAction.lightUpBombMatchPosList) then
							SpecialCoverLogic:SpecialCoverLightUpAtPos(mainLogic, r, c, scoreScale)
						end
	    				GameExtandPlayLogic:doABlocker211Collect(mainLogic, nil, nil, r, c, 0, true, 3)
						BombItemLogic:tryCoverByBomb(mainLogic, r, c, true, scoreScale, nil, nil, ObstacleFootprintType.k_Totems)
						SpecialCoverLogic:SpecialCoverAtPos(mainLogic, r, c, 3, scoreScale, actid, nil, nil, ObstacleFootprintType.k_Totems, SpecialID )
						local breakDirs = {}
						if r > fromR then table.insert(breakDirs, ChainDirConfig.kUp) end
						if r < toR then table.insert(breakDirs, ChainDirConfig.kDown) end
						if c > fromC then table.insert(breakDirs, ChainDirConfig.kLeft) end
						if c < toC then table.insert(breakDirs, ChainDirConfig.kRight) end
						SpecialCoverLogic:specialCoverChainsAtPos(mainLogic, r, c, breakDirs)
					end
				end
			end	

            --闪电鸟本身感染果酱
            local isJamSperad1 = mainLogic.boardmap[r1][c1].isJamSperad
            local isJamSperad2 = mainLogic.boardmap[r2][c2].isJamSperad

            if isJamSperad1 or isJamSperad2 then
                GameExtandPlayLogic:addJamSperadFlag(mainLogic, r1, c1, true )
                GameExtandPlayLogic:addJamSperadFlag(mainLogic, r2, c2, true )
            end
            --

			GameExtandPlayLogic:stopTileHighlight(mainLogic, theAction.ItemPos1, theAction.ItemPos2)

			theAction.addInfo = "bombSelf"
		elseif theAction.addInfo == "bombSelf" then
			-- add scores
			local r1, c1 = theAction.ItemPos1.x, theAction.ItemPos1.y
			local r2, c2 = theAction.ItemPos2.x, theAction.ItemPos2.y
			mainLogic:addScoreToTotal(r1, c1, GamePlayConfigScore.SuperTotems)
			mainLogic:addScoreToTotal(r2, c2, GamePlayConfigScore.SuperTotems)
			ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_Totems, ObstacleFootprintAction.k_Attack, 2)

			theAction.addInfo = "over"
		elseif theAction.addInfo == "over" then
			local function removeCallback(board, item, r, c)
				--在“bombAll”阶段尝试点亮蜗牛路径，但是因为两只蜗牛数据没清空没法点亮，所以这里再次调用一次
				SnailLogic:SpecialCoverSnailRoadAtPos(mainLogic, r, c)
				if board.blockerCoverMaterialLevel > 0 then
					SpecialCoverLogic:doEffectblockerCoverMaterial(mainLogic, r, c)
					return
				end

				if board.iceLevel > 0 and board.blockerCoverMaterialLevel == 0 then
					SpecialCoverLogic:doEffectLightUpAtPos(mainLogic, r, c, 1)
				end

				if board.sandLevel > 0 and board.blockerCoverMaterialLevel == 0 then
					SpecialCoverLogic:doEffectSandAtPos(mainLogic, r, c)
				end

				if GameExtandPlayLogic:isEmptyBiscuit(mainLogic, r, c) then
					SpecialCoverLogic:doApplyMilkAt(mainLogic, r, c)
				end

			end

			local r1, c1 = theAction.ItemPos1.x, theAction.ItemPos1.y
			local r2, c2 = theAction.ItemPos2.x, theAction.ItemPos2.y		
			local item1 = mainLogic.gameItemMap[r1][c1]
			local board1 = mainLogic.boardmap[r1][c1]
			removeCallback(board1, item1, r1, c1)
			item1:cleanAnimalLikeData()
			mainLogic:checkItemBlock(r1, c1)
			item1.isNeedUpdate = true

			local item2 = mainLogic.gameItemMap[r2][c2]
			local board2 = mainLogic.boardmap[r2][c2]
			removeCallback(board2, item2, r2, c2)
			item2:cleanAnimalLikeData()
			mainLogic:checkItemBlock(r2, c2)
			item2.isNeedUpdate = true

			theAction.actionStatus = GameActionStatus.kWaitingForDeath
		end
	end
end


function DestructionPlanLogic:runGameItemActionWukongCasting(boardView, theAction)

	local r , c = theAction.ItemPos1.x, theAction.ItemPos1.y
	local tr , tc = theAction.monkeyTargetPos.y, theAction.monkeyTargetPos.x
	local fromItem = boardView.baseMap[r][c]
	local targetItem = boardView.baseMap[tr][tc]
	local tarPos = IntCoord:clone(theAction.monkeyTargetPos)

	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning 
		theAction.addInfo = "start"
	else

		local function onJumpFin()
			theAction.addInfo = "jumpFin"
		end

		if theAction.addInfo == "startJump" then
			fromItem:changeWukongState( TileWukongState.kJumping )
			if theAction.noJump then
				--setTimeOut( onJumpFin , 2 )
				fromItem:playWukongJumpAnimation(tarPos , onJumpFin , true)
				--[[
				fromItem:playWukongJumpAnimation(tarPos , function () 
					fromItem:onWukongJumpFin()
					onJumpFin()
					end , true)
					]]
			else
				fromItem:playWukongJumpAnimation(tarPos , onJumpFin)
			end
			theAction.musicDelay = 0
			theAction.addInfo = "watingForMusic"
		elseif theAction.addInfo == "watingForMusic" then
			theAction.musicDelay = theAction.musicDelay + 1
			if theAction.musicDelay == 30 then
				GamePlayMusicPlayer:playEffect(GameMusicType.kWukongCasting)
			end
		elseif theAction.addInfo == "fallToClearDone" then
			
			theAction.addInfo = "playMonkeyBar"
			boardView:playMonkeyBar(tr , theAction.monkeyColorIndex)

			theAction.jsq = 0
		elseif theAction.addInfo == "doClearTopCloud" then
			theAction.jsq = theAction.jsq + 1
			if theAction.jsq >= 2 then
				theAction.jsq = 0

				if theAction.needPlayClearBlockAnimationPos and #theAction.needPlayClearBlockAnimationPos > 0 then
					for i = 1 , 1 do
						local pos = theAction.needPlayClearBlockAnimationPos[1]
						if pos then
							table.remove( theAction.needPlayClearBlockAnimationPos , 1 )
							local needClearItem = boardView.baseMap[pos.r][pos.c]

							theAction.clearBlockAnimationCount = theAction.clearBlockAnimationCount + 1
							needClearItem:playMaydayBossChangeToAddMove(boardView, targetItem, function () 
									table.insert( theAction.needClearBlockPos , pos )
									theAction.clearBlockAnimationCount = theAction.clearBlockAnimationCount - 1
								end)
						end
					end
					
				else
					if theAction.clearBlockAnimationCount <= 0 then
						if theAction.nextFrameChangeToOver then
							theAction.addInfo = "over"
						end
						theAction.nextFrameChangeToOver = true
					end
				end
			end
		end
		
	end
end

function DestructionPlanLogic:runingGameItemActionWukongCasting(mainLogic, theAction, actid, actByView)
	if theAction.actionStatus == GameActionStatus.kRunning then
		
		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local tr , tc = theAction.monkeyTargetPos.y, theAction.monkeyTargetPos.x
		local fromItem = mainLogic.gameItemMap[r][c]
		local toItem = mainLogic.gameItemMap[tr][tc]

		local SpecialID = mainLogic:addSrcSpecialCoverToList( theAction.ItemPos1 )

		local function onFallToClearDone() -- 跳跃完成
			theAction.addInfo = "fallToClearDone"
			toItem.wukongState = TileWukongState.kReadyToCasting
		end

		if theAction.addInfo == "start" then
			toItem.wukongState = TileWukongState.kJumping  --注意这里有个坑，为什么要设置toItem的wukongState，因为要用这个属性来阻止其掉落，尽管这时toItem并不是一个wukong
			theAction.addInfo = "startJump"
			theAction.monkeyColorIndex = AnimalTypeConfig.convertColorTypeToIndex( fromItem._encrypt.ItemColorType )
		elseif theAction.addInfo == "jumpFin" then
			wukongCastingCount = wukongCastingCount + 1
			toItem.wukongProgressTotal = getBaseWukongChargingTotalValue()

			if theAction.noJump then
				onFallToClearDone()
			else
				local action = GameBoardActionDataSet:createAs(
                        GameActionTargetType.kGameItemAction,
                        GameItemActionType.kItem_Wukong_FallToClearItem,
                        IntCoord:create(tr, tc),
                        nil,
                        GamePlayConfig_MaxAction_time
                    )
		        action.completeCallback = onFallToClearDone
		        action.monkeyFromPos = IntCoord:create(r, c)
		        mainLogic:addDestructionPlanAction(action)
				
				mainLogic:setNeedCheckFalling()
				theAction.addInfo = "wating"
			end
			

		elseif theAction.addInfo == "playMonkeyBar" then
			theAction.jsq = theAction.jsq + 1

			if theAction.jsq >= 15 then 
				toItem.wukongState = TileWukongState.kCasting

				local function onMonekyBarDone()
					theAction.addInfo = "clearTopCloud"
					--toItem.wukongState = TileWukongState.kReadyToChangeColor
					toItem.wukongState = TileWukongState.kGift 
					mainLogic:releasReplayReordPreviewBlock()
				end
				
				local action = GameBoardActionDataSet:createAs(
	                        GameActionTargetType.kGameItemAction,
	                        GameItemActionType.kItem_Wukong_MonkeyBar,
	                        IntCoord:create(tr, tc),
	                        nil,
	                        GamePlayConfig_MaxAction_time
	                    )
		        action.completeCallback = onMonekyBarDone
		        mainLogic:addDestructionPlanAction(action)

				--mainLogic:setNeedCheckFalling()
				theAction.jsq = 0
				theAction.addInfo = "wating"
			end
		elseif theAction.addInfo == "clearTopCloud" then
			local needClearBlock = {}
			for ir = 1, #mainLogic.gameItemMap do
				for ic = 1, #mainLogic.gameItemMap[ir] do
					local checkItem = mainLogic.gameItemMap[ir][ic]

					if checkItem and ir < tr and ( checkItem.ItemType == GameItemType.kDigJewel or checkItem.ItemType == GameItemType.kDigGround ) then
						table.insert( needClearBlock , {r = ir , c = ic} )
					end
				end
			end
			--[[
			local randomList = {}
			if #needClearBlock > 0 then
				local listLength = #needClearBlock
				for ia = 1 , listLength do
					local idx = mainLogic.randFactory:rand(1, #needClearBlock)
					table.insert( randomList , needClearBlock[idx] )
					table.remove( needClearBlock , idx )
				end
			end
			]]

			theAction.needPlayClearBlockAnimationPos = needClearBlock
			--theAction.needPlayClearBlockAnimationPos = randomList
			theAction.needClearBlockPos = {}
			theAction.clearBlockAnimationCount = 0
			theAction.jsq = 0
			--if not needFouceClear then
				theAction.addInfo = "doClearTopCloud"
			--end
		elseif theAction.addInfo == "doClearTopCloud" then

			for i = 1, #theAction.needClearBlockPos do
				local pos = theAction.needClearBlockPos[i]
				local needClearItem = mainLogic.gameItemMap[pos.r][pos.c]

				if needClearItem.ItemType == GameItemType.kDigJewel or needClearItem.ItemType == GameItemType.kDigGround then
					BombItemLogic:forceClearItemWithCover(mainLogic , pos.r , pos.c, SpecialID)
				end
			end
			theAction.needClearBlockPos = {}
		elseif theAction.addInfo == "over" then
			mainLogic:setNeedCheckFalling()
			mainLogic.destructionPlanList[actid] = nil
			
			if theAction.completeCallback then
				theAction.completeCallback()
			end
		end
	end
end

function DestructionPlanLogic:runGameItemActionWukongFallToClear(boardView, theAction)
	
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning 
		
		theAction.addInfo = "start"

		local r , c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local toItem = boardView.baseMap[r][c]
		local mr , mc = theAction.monkeyFromPos.x, theAction.monkeyFromPos.y
		local monkey = boardView.baseMap[mr][mc]
		theAction.monkey = monkey
		boardView:viberate()

	else
		if theAction.addInfo == "build" then
			
		elseif theAction.addInfo == "over" then
			theAction.monkey:onWukongJumpFin()
		end
	end
end

function DestructionPlanLogic:runingGameItemActionWukongFallToClear(mainLogic, theAction, actid, actByView)
	if theAction.actionStatus == GameActionStatus.kRunning then
		

		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local toItem = mainLogic.gameItemMap[r][c]
		local mr , mc = theAction.monkeyFromPos.x, theAction.monkeyFromPos.y
		local monkey = mainLogic.gameItemMap[mr][mc]

        local SpecialID = mainLogic:addSrcSpecialCoverToList( theAction.ItemPos1 )

		if theAction.addInfo == "start" then
			SpecialCoverLogic:SpecialCoverLightUpAtPos(mainLogic, r, c, 1)
			BombItemLogic:tryCoverByBomb(mainLogic, r, c, true, 1)
			SpecialCoverLogic:SpecialCoverAtPos(mainLogic, r, c, 3,nil,nil,nil,nil,nil,SpecialID)
			mainLogic:checkItemBlock(r, c)

			theAction.addInfo = "wating"
			theAction.jsq = 0

		elseif theAction.addInfo == "wating" then
			theAction.jsq = theAction.jsq + 1
			--toItem.isBlock = true
			if toItem.ItemType == GameItemType.kNone then
				theAction.addInfo = "build" 
			end
			if theAction.jsq >= 300 then
				theAction.addInfo = "build" --只是一个保险
			end
		elseif theAction.addInfo == "build" then
			toItem.ItemType = GameItemType.kWukong 
			toItem.isBlock = true 
			toItem.isEmpty = false 
			toItem._encrypt.ItemColorType = monkey._encrypt.ItemColorType
			toItem.wukongProgressCurr = toItem.wukongProgressTotal
			toItem.needHideMoneyBar = true
			--toItem.wukongState = TileWukongState.kReadyToChangeColor
			mainLogic:checkItemBlock(r, c)
			toItem.isNeedUpdate = true

			GameExtandPlayLogic:itemDestroyHandler(mainLogic, mr, mc)
			monkey:cleanAnimalLikeData()
			monkey.wukongState = TileWukongState.kNormal
			mainLogic:checkItemBlock(mr, mc)
			monkey.isNeedUpdate = true

			theAction.addInfo = "over" 
		elseif theAction.addInfo == "over" then
			mainLogic:setNeedCheckFalling()

			mainLogic.destructionPlanList[actid] = nil
			if theAction.completeCallback then
				theAction.completeCallback()
			end
		end
	end
end

function DestructionPlanLogic:runGameItemActionWukongMonkeyBar(boardView, theAction)
	
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning 

		theAction.addInfo = "start"

		local r , c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local monkey = boardView.baseMap[r][c]

	end
end

function DestructionPlanLogic:runingGameItemActionWukongMonkeyBar(mainLogic, theAction, actid, actByView)
	if theAction.actionStatus == GameActionStatus.kRunning then

		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local monkey = mainLogic.gameItemMap[r][c]
		local checkItem = nil

		if not theAction.jsq then theAction.jsq = 0 end
		if not theAction.currCol then theAction.currCol = 9 end

		local SpecialID = mainLogic:addSrcSpecialCoverToList( theAction.ItemPos1 )

		local function checkItemIsEmpty(row,col)
			checkItem = nil
			if mainLogic.gameItemMap[row] then
				checkItem = mainLogic.gameItemMap[row][col]
			end

			if checkItem and not checkItem.isEmpty and checkItem.ItemType ~= GameItemType.kWukong then
				return false
			end
			return true
		end

		if theAction.addInfo == "start" then

			theAction.jsq = theAction.jsq + 1


			if theAction.jsq >= 5 then

				local dr = r
				local dc = 9
				

				local function clearItem(row,col)
					local clearItem = mainLogic.gameItemMap[row][col]
					BombItemLogic:forceClearItemWithCover(mainLogic , row , col, SpecialID)
				end

				

				if not checkItemIsEmpty(r , theAction.currCol) then
					clearItem(r , theAction.currCol)
				end

				if not checkItemIsEmpty(r + 1 , theAction.currCol) then
					clearItem(r + 1 , theAction.currCol)
				end

				if not checkItemIsEmpty(r - 1 , theAction.currCol) then
					clearItem(r - 1 , theAction.currCol)
				end
				
				theAction.currCol = theAction.currCol - 1
				theAction.jsq = 0

				mainLogic:setNeedCheckFalling()

				if theAction.currCol <= 0 then
					theAction.addInfo = "over"
				end
			end

			--theAction.addInfo = "over"

		elseif theAction.addInfo == "over" then

			mainLogic:setNeedCheckFalling()

			mainLogic.destructionPlanList[actid] = nil
			if theAction.completeCallback then
				theAction.completeCallback()
			end
		end
	end
end


function DestructionPlanLogic:runGameItemCrystalStoneChargeAction(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning

		local color = theAction.addInt1
		local totalEnergy = theAction.addInt2 or 0

		local r2, c2 = theAction.ItemPos2.x, theAction.ItemPos2.y
		local item2 = boardView.baseMap[r2][c2]
		local energyPercent = totalEnergy / GamePlayConfig_CrystalStone_Energy

		item2:updateCrystalStoneEnergy(energyPercent, true)
		if theAction.ItemPos1 then -- 添加特效飞行动画
			item2:playCrystalStoneCharge(theAction.ItemPos1, color)
		else -- 直接播放加能量特效
			item2:playCrystalStoneChargeEffect()
		end
	end
end

function DestructionPlanLogic:runingGameItemCrystalStoneChargeAction(mainLogic, theAction, actid)
	if theAction.actionStatus == GameActionStatus.kRunning then
		theAction.actionStatus = GameActionStatus.kWaitingForDeath
	end
end 

--[[
function DestructionPlanLogic:runGameItemSpecialCrystalStoneBirdAction(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning

		theAction.addInfo = "start"

		local r1, c1 = theAction.ItemPos1.x, theAction.ItemPos1.y
		local item1 = boardView.baseMap[r1][c1]
		item1:playCrystalStoneChangeToWaiting()

		local r2, c2 = theAction.ItemPos2.x, theAction.ItemPos2.y
		local item2 = boardView.baseMap[r2][c2]
		item2:playBridBackEffect(true, 1.3)
		theAction.isPlayingBirdBackEffect = true
	else
		if theAction.addInfo == "bombSpecials" and theAction.isPlayingBirdBackEffect then
			local r2, c2 = theAction.ItemPos2.x, theAction.ItemPos2.y
			local item2 = boardView.baseMap[r2][c2]
			item2:playBridBackEffect(false)
			theAction.isPlayingBirdBackEffect = false
		end
	end
end
]]

function DestructionPlanLogic:runGameItemSpecialCrystalStoneBirdPart1Action(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning

		theAction.addInfo = "start"

		local r1, c1 = theAction.ItemPos1.x, theAction.ItemPos1.y
		local item1 = boardView.baseMap[r1][c1]
		item1:playCrystalStoneChangeToWaiting()

		local r2, c2 = theAction.ItemPos2.x, theAction.ItemPos2.y
		local item2 = boardView.baseMap[r2][c2]
		item2:playBridBackEffect(true, 1.3)
		theAction.isPlayingBirdBackEffect = true
	end
end

function DestructionPlanLogic:runGameItemSpecialCrystalStoneBirdPart2Action(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		theAction.addInfo = "start"
	else
		if theAction.addInfo == "bombSpecials" and theAction.isPlayingBirdBackEffect then
			local r2, c2 = theAction.ItemPos2.x, theAction.ItemPos2.y
			local item2 = boardView.baseMap[r2][c2]
			item2:playBridBackEffect(false)
			theAction.isPlayingBirdBackEffect = false
		end
	end
end

function DestructionPlanLogic:runGameItemSpecialCrystalStoneBirdPart3Action(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		theAction.addInfo = "start"
	end
end

--[[
function DestructionPlanLogic:runingGameItemSpecialCrystalStoneBirdAction(mainLogic, theAction, actid)
	if theAction.actionStatus == GameActionStatus.kRunning then
		local r1, c1 = theAction.ItemPos1.x, theAction.ItemPos1.y
		local r2, c2 = theAction.ItemPos2.x, theAction.ItemPos2.y
		if theAction.addInfo == "start" then -- 炸掉魔力鸟
			local item1 = mainLogic.gameItemMap[r1][c1]
			item1.crystalStoneBombType = GameItemCrystalStoneBombType.kSpecial
			SnailLogic:SpecialCoverSnailRoadAtPos( mainLogic, r1, c1 ) -- 点亮蜗牛轨迹

			local item2 = mainLogic.gameItemMap[r2][c2]
			item2:AddItemStatus(GameItemStatusType.kDestroy)
			local CoverAction2 = GameBoardActionDataSet:createAs(
				GameActionTargetType.kGameItemAction,
				GameItemActionType.kItemCoverBySpecial_Color,
				IntCoord:create(r2,c2),
				nil,
				GamePlayConfig_SpecialBomb_BirdBird_Time2)
			CoverAction2.addInfo = "kAnimal"
			mainLogic:addDestroyAction(CoverAction2)
			mainLogic.gameItemMap[r2][c2].gotoPos = nil
			mainLogic.gameItemMap[r2][c2].comePos = nil
			SpecialCoverLogic:SpecialCoverLightUpAtPos(mainLogic, r2, c2, 3)
			SnailLogic:SpecialCoverSnailRoadAtPos( mainLogic, r2, c2 )
			GameExtandPlayLogic:decreaseLotus( mainLogic, r2, c2 , 1 , false)

			-- 分数
			local addScore = GamePlayConfigScore.CrystalStone * 1.5
			mainLogic:addScoreToTotal(r1, c1, addScore, item1._encrypt.ItemColorType)

			theAction.addInfo = "waiting1"
		elseif theAction.addInfo == "waiting1" then
			if mainLogic:isItemAllStable()
				and mainLogic:numDestrunctionPlan() == 1 -- 只剩下自己了
				then
				------停止掉落了-----
				----进入下一个阶段----
				theAction.addInfo = "bombSpecials"
				local result = {}
				for r = 1, #mainLogic.gameItemMap do
					for c = 1, #mainLogic.gameItemMap[r] do
						if (BombItemLogic:canBeBombByBirdBird(mainLogic, r, c)) 
							and (r1 ~= r or c1 ~= c) and (r2 ~= r or c2 ~= c) 
							then
							table.insert(result, mainLogic:getGameItemPosInView(r, c))
						end
					end
				end				
				theAction.bombList = result
				theAction.actionTick = 0
			end
		elseif theAction.addInfo == "bombSpecials" then
			theAction.actionTick = theAction.actionTick + 1
			if theAction.actionTick >= GamePlayConfig_SpecialBomb_CrystalStone_Bird_Time2 then
				BombItemLogic:BombAll(mainLogic)--------引爆所有特效
				theAction.addInfo = "waiting2"
				theAction.actionTick = 0
			end
		elseif theAction.addInfo == "waiting2" then
			if mainLogic:isItemAllStable()
				and mainLogic:numDestrunctionPlan() == 1
				then
				mainLogic:tryBombCrystalStones(true)
				theAction.addInfo = "bombAll"
				theAction.actionTick = 0
			end
		elseif theAction.addInfo == "bombAll" then
			theAction.actionTick = theAction.actionTick + 1
			if theAction.actionTick >= GamePlayConfig_SpecialBomb_CrystalStone_Bird_Time3 then
				BombItemLogic:bombAllByCrystalStone(mainLogic, true, 5)
				theAction.addInfo = "over"
				theAction.actionTick = 0
			end
		elseif theAction.addInfo == "over" then
			mainLogic.destructionPlanList[actid] = nil
		end
	end
end
]]

function DestructionPlanLogic:runingGameItemSpecialCrystalStoneBirdPart1Action(mainLogic, theAction, actid)
	if theAction.actionStatus == GameActionStatus.kRunning then

        local r1, c1 = theAction.ItemPos1.x, theAction.ItemPos1.y
        local r2, c2 = theAction.ItemPos2.x, theAction.ItemPos2.y

		if theAction.addInfo == "start" then -- 炸掉魔力鸟
			if theAction.ItemPos1 and theAction.ItemPos2 then
	            --星星瓶 与 魔力鸟 互相感染
	            local isJamSperad1 = mainLogic.boardmap[r1][c1].isJamSperad
	            local isJamSperad2 = mainLogic.boardmap[r2][c2].isJamSperad

	            if isJamSperad1 or isJamSperad2 then
	                GameExtandPlayLogic:addJamSperadFlag(mainLogic, r1, c1, true )
	                GameExtandPlayLogic:addJamSperadFlag(mainLogic, r2, c2, true )
	            end
	        end

			local item1 = mainLogic.gameItemMap[r1][c1]
			item1.crystalStoneBombType = GameItemCrystalStoneBombType.kSpecial
			SnailLogic:SpecialCoverSnailRoadAtPos( mainLogic, r1, c1 ) -- 点亮蜗牛轨迹

			local item2 = mainLogic.gameItemMap[r2][c2]
			item2:AddItemStatus(GameItemStatusType.kDestroy)
			local CoverAction2 = GameBoardActionDataSet:createAs(
				GameActionTargetType.kGameItemAction,
				GameItemActionType.kItemCoverBySpecial_Color,
				IntCoord:create(r2,c2),
				nil,
				GamePlayConfig_SpecialBomb_BirdBird_Time2)
			CoverAction2.addInfo = "kAnimal"
			mainLogic:addDestroyAction(CoverAction2)
			mainLogic.gameItemMap[r2][c2].gotoPos = nil
			mainLogic.gameItemMap[r2][c2].comePos = nil
			SpecialCoverLogic:SpecialCoverLightUpAtPos(mainLogic, r2, c2, 3)
			SnailLogic:SpecialCoverSnailRoadAtPos( mainLogic, r2, c2 )
			GameExtandPlayLogic:decreaseLotus( mainLogic, r2, c2 , 1 , false)

			-- 分数
			local addScore = GamePlayConfigScore.CrystalStone * 1.5
			mainLogic:addScoreToTotal(r1, c1, addScore, item1._encrypt.ItemColorType)

			local part2Action = GameBoardActionDataSet:createAs(
				GameActionTargetType.kGameItemAction,
				GameItemActionType.kItemSpecial_CrystalStone_Bird_part2,
				IntCoord:create(r1, c1),
				IntCoord:create(r2, c2),
				GamePlayConfig_SpecialBomb_BirdBird_Time1
				)
			part2Action.isPlayingBirdBackEffect = theAction.isPlayingBirdBackEffect
			mainLogic:addStableDestructionPlanAction(part2Action)

			theAction.addInfo = "over"

		elseif theAction.addInfo == "over" then
			mainLogic.destructionPlanList[actid] = nil
		end
	end
end

function DestructionPlanLogic:runingGameItemSpecialCrystalStoneBirdPart2Action(mainLogic, theAction, actid)
	if theAction.actionStatus == GameActionStatus.kRunning then
		local r1, c1 = theAction.ItemPos1.x, theAction.ItemPos1.y
		local r2, c2 = theAction.ItemPos2.x, theAction.ItemPos2.y

		local SpecialID = mainLogic:addSrcSpecialCoverToList( theAction.ItemPos1, theAction.ItemPos2 )

		if theAction.addInfo == "start" then
			if mainLogic:isItemAllStable()
				and mainLogic:numDestrunctionPlan() == 1 -- 只剩下自己了
				then
				------停止掉落了-----
				----进入下一个阶段----
				theAction.addInfo = "bombSpecials"
				local result = {}
				for r = 1, #mainLogic.gameItemMap do
					for c = 1, #mainLogic.gameItemMap[r] do
						if (BombItemLogic:canBeBombByBirdBird(mainLogic, r, c)) 
							and (r1 ~= r or c1 ~= c) and (r2 ~= r or c2 ~= c) 
							then
							table.insert(result, mainLogic:getGameItemPosInView(r, c))
						end
					end
				end				
				theAction.bombList = result
				theAction.actionTick = 0
			end
		elseif theAction.addInfo == "bombSpecials" then
			theAction.actionTick = theAction.actionTick + 1
			if theAction.actionTick >= GamePlayConfig_SpecialBomb_CrystalStone_Bird_Time2 then
				BombItemLogic:BombAll(mainLogic, SpecialID )--------引爆所有特效
				theAction.addInfo = "over"
				theAction.actionTick = 0

				local part3Action = GameBoardActionDataSet:createAs(
				GameActionTargetType.kGameItemAction,
				GameItemActionType.kItemSpecial_CrystalStone_Bird_part3,
				IntCoord:create(r1, c1),
				IntCoord:create(r2, c2),
				GamePlayConfig_SpecialBomb_BirdBird_Time1
					)
				mainLogic:addStableDestructionPlanAction(part3Action)
			end
		elseif theAction.addInfo == "over" then
			mainLogic.destructionPlanList[actid] = nil
		end
	end
end

function DestructionPlanLogic:runingGameItemSpecialCrystalStoneBirdPart3Action(mainLogic, theAction, actid)
	if theAction.actionStatus == GameActionStatus.kRunning then
		if theAction.addInfo == "start" then
			if mainLogic:isItemAllStable()
				and mainLogic:numDestrunctionPlan() == 1
				then
				mainLogic:tryBombCrystalStones(true)
				theAction.addInfo = "bombAll"
				theAction.actionTick = 0
			end
		elseif theAction.addInfo == "bombAll" then
			theAction.actionTick = theAction.actionTick + 1
			if theAction.actionTick >= GamePlayConfig_SpecialBomb_CrystalStone_Bird_Time3 then

				local SpecialID = mainLogic:addSrcSpecialCoverToList( theAction.ItemPos1, theAction.ItemPos2 )

				BombItemLogic:bombAllByCrystalStone(mainLogic, true, 5, SpecialID )
				theAction.addInfo = "over"
				theAction.actionTick = 0
			end
		elseif theAction.addInfo == "over" then
			mainLogic.destructionPlanList[actid] = nil
		end
	end
end

function DestructionPlanLogic:runGameItemSpecialCrystalStoneCrystalStoneAction(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning

		theAction.addInfo = "start"
	end
end

function DestructionPlanLogic:runingGameItemSpecialCrystalStoneCrystalStoneAction(mainLogic, theAction, actid)
	if theAction.actionStatus == GameActionStatus.kRunning then
		if theAction.addInfo == "start" then
			theAction.addInfo = "changeColor"
			mainLogic.isCrystalStoneInHandling = true
			local itemPosList = {}
			for i = 1, #mainLogic.gameItemMap do
				for j = 1, #mainLogic.gameItemMap[i] do
					local item = mainLogic.gameItemMap[i][j]
					if item and item:canBeCoverByCrystalStone() then
						table.insert(itemPosList, IntCoord:create(i, j))
					end
				end
			end

			local r1, c1 = theAction.ItemPos1.x, theAction.ItemPos1.y
			local item1 = mainLogic.gameItemMap[r1][c1]
			item1.crystalStoneBombType = GameItemCrystalStoneBombType.kNormal
			SnailLogic:SpecialCoverSnailRoadAtPos( mainLogic, r1, c1 )

			local r2, c2 = theAction.ItemPos2.x, theAction.ItemPos2.y
			local item2 = mainLogic.gameItemMap[r2][c2]
			item2.crystalStoneBombType = GameItemCrystalStoneBombType.kNormal
			SnailLogic:SpecialCoverSnailRoadAtPos( mainLogic, r2, c2 )

			-- 分数
			local addScore = GamePlayConfigScore.CrystalStone * 2
			mainLogic:addScoreToTotal(r1, c1, addScore, item1._encrypt.ItemColorType)

			theAction.handleList = itemPosList
			theAction.handled = 0
			theAction.interval = 0

			--果酱兼容
			local boardData1 = mainLogic.boardmap[theAction.ItemPos1.x][theAction.ItemPos1.y]
			local boardData2 = mainLogic.boardmap[theAction.ItemPos2.x][theAction.ItemPos2.y]
			local isJamSperad1 = boardData1.isJamSperad
			local isJamSperad2 = boardData2.isJamSperad

			if isJamSperad1 and not isJamSperad2 then
				GameExtandPlayLogic:addJamSperadFlag(mainLogic, theAction.ItemPos2.x, theAction.ItemPos2.y, true )
			end

			if not isJamSperad1 and isJamSperad2 then
				GameExtandPlayLogic:addJamSperadFlag(mainLogic, theAction.ItemPos1.x, theAction.ItemPos1.y, true )
			end

		elseif theAction.addInfo == "changeColor" then
			theAction.interval = theAction.interval + 1
			if theAction.handled >= #theAction.handleList then
				mainLogic.isCrystalStoneInHandling = false
				theAction.addInfo = "waiting"
				theAction.actionTick = 0
			elseif theAction.interval > GamePlayConfig_CrystalStone2_Handle_Interval then
				theAction.interval = 0
				local targetColor = theAction.addInt1
				local r1, c1 = theAction.ItemPos1.x, theAction.ItemPos1.y

				for index = theAction.handled + 1, theAction.handled + GamePlayConfig_CrystalStone2_Handle_One_Time do
					local itemPos = theAction.handleList[index]
					if itemPos then
						local action = GameBoardActionDataSet:createAs(
							GameActionTargetType.kGameItemAction,
							GameItemActionType.kItemSpecial_CrystalStone_Flying,
							IntCoord:create(r1, c1),
							itemPos,
							GamePlayConfig_CrystalStone_Fly_Time1)
						action.addInt1 = targetColor
						action.addInt3 = 1 -- by CrystalStoneCrystalStone
						mainLogic:addGameAction(action)

						theAction.handled = theAction.handled + 1
					else
						break
					end
				end
			end
		elseif theAction.addInfo == "waiting" then
			theAction.actionTick = theAction.actionTick + 1
			if theAction.actionTick > GamePlayConfig_SpecialBomb_CrystalStone2_Time2 then
				mainLogic:tryBombCrystalStones()
				theAction.addInfo = "over"
				theAction.actionTick = 0
			end
		elseif theAction.addInfo == "over" then
			mainLogic.destructionPlanList[actid] = nil
		end
	end
end

function DestructionPlanLogic:runGameItemSpecialCrystalStoneAnimalAction(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning

		theAction.addInfo = "start"
	end
end

function DestructionPlanLogic:runingGameItemSpecialCrystalStoneAnimalAction(mainLogic, theAction, actid)
	if theAction.actionStatus == GameActionStatus.kRunning then
		local targetColor = theAction.addInt1
		local colorToChange = theAction.addInt2
		local sptype = theAction.addInt3 or 0

		if theAction.addInfo == "start" then
			if theAction.ItemPos1 and theAction.ItemPos2 then
	            local r1, c1 = theAction.ItemPos1.x, theAction.ItemPos1.y
			    local r2, c2 = theAction.ItemPos2.x, theAction.ItemPos2.y

	            --星星瓶 与 动物 互相感染
	            local isJamSperad1 = mainLogic.boardmap[r1][c1].isJamSperad
	            local isJamSperad2 = mainLogic.boardmap[r2][c2].isJamSperad

	            if isJamSperad1 or isJamSperad2 then
	                GameExtandPlayLogic:addJamSperadFlag(mainLogic, r1, c1, true )
	                GameExtandPlayLogic:addJamSperadFlag(mainLogic, r2, c2, true )
	            end
	        end

			local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
			local item1 = mainLogic.gameItemMap[r][c]
			-- 分数
			local addScore = GamePlayConfigScore.CrystalStone
			mainLogic:addScoreToTotal(r, c, addScore, item1._encrypt.ItemColorType)

			item1.crystalStoneBombType = GameItemCrystalStoneBombType.kNormal
			SnailLogic:SpecialCoverSnailRoadAtPos( mainLogic, r, c )

			local colorPosList = mainLogic:getPositionCoverByCrystalStone(targetColor, colorToChange, sptype)
			if colorPosList and #colorPosList > 0 then
				local actionNum = #colorPosList
				local function completeCallback()
					actionNum = actionNum - 1
					if actionNum <= 0 then
						local isSpecialType = sptype and sptype ~= 0
						if theAction.ItemPos2 and not isSpecialType then
							local r2, c2 = theAction.ItemPos2.x, theAction.ItemPos2.y
							mainLogic:addNeedCheckMatchPoint(r2, c2)
						end
						theAction.addInfo = "colorChangeEnd"
					end
				end

				for _, v in pairs(colorPosList) do
					local action = GameBoardActionDataSet:createAs(
						GameActionTargetType.kGameItemAction,
						GameItemActionType.kItemSpecial_CrystalStone_Flying,
						IntCoord:create(r, c),
						IntCoord:create(v.x, v.y),
						GamePlayConfig_CrystalStone_Fly_Time1)
					action.addInt1 = targetColor
					action.addInt2 = sptype -- special type
					action.completeCallback = completeCallback
					mainLogic:addGameAction(action)
				end

				theAction.addInfo = "waiting"
				theAction.actionTick = 0
			else
				theAction.addInfo = "colorChangeEnd"
			end
		elseif theAction.addInfo == "waiting" then
			
		elseif theAction.addInfo == "colorChangeEnd" then
			theAction.addInfo = "explode"
		elseif theAction.addInfo == "explode" then
			mainLogic:tryBombCrystalStones()
			theAction.addInfo = "over"
		elseif theAction.addInfo == "over" then
			mainLogic.destructionPlanList[actid] = nil
		end
	end
end

function DestructionPlanLogic:runningGameItemBlocker195OverAction(mainLogic, theAction, actid)
	if theAction.actionStatus == GameActionStatus.kRunning and theAction.addInfo == "over" then
		--if _G.isLocalDevelopMode then printx(0, 'hjh', 'DestructionPlanLogic:runningGameItemBlocker195OverAction') end
		theAction.actionStatus = GameActionStatus.kWaitingForDeath
	end
end

function DestructionPlanLogic:runGameItemBlocker195CollectAction(boardView, theAction)
	--if _G.isLocalDevelopMode then printx(0, 'hjh', 'DestructionPlanLogic:runGameItemBlocker195CollectAction') end
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning

		local r2, c2 = theAction.ItemPos2.x, theAction.ItemPos2.y
		local item2 = boardView.baseMap[r2][c2]
		local itemData2 =  boardView.gameBoardLogic.gameItemMap[r2][c2]
		local percent = theAction.addInt1
		local playFlying = theAction.addInt2

		theAction.jsq = 0
		theAction.maxJsq = 0
		if itemData2.ItemType == GameItemType.kBlocker195 and itemData2.subtype == theAction.collectType then--如果不判断，掉落过程中动画可能会播错
			if percent < 1 then
				theAction.maxJsq = 100
			else
				theAction.maxJsq = 145
			end

			item2:playBlocker195CollectAnimation(itemData2.level, percent)
			if playFlying == 1 then
				item2:playBlocker195Light1Animation(theAction.ItemPos1)
			end
		end
	elseif theAction.actionStatus == GameActionStatus.kRunning then
		theAction.jsq = theAction.jsq + 1
		if theAction.jsq >= theAction.maxJsq then
			theAction.addInfo = "over"
		end
	end
end 

local function doBlocker195FullSwap(boardView, theAction, positionList, callback)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
	end

	if theAction.actionStatus == GameActionStatus.kRunning then
		local r1 = theAction.ItemPos1.x
		local c1 = theAction.ItemPos1.y
		local mainLogic = boardView.gameBoardLogic

		local SpecialID = mainLogic:addSrcSpecialCoverToList( theAction.ItemPos1, theAction.ItemPos2 )

		if theAction.addInfo == "" then
			theAction.addInfo = "start"
			local addScore = GamePlayConfigScore.SwapBlocker195
			mainLogic:addScoreToTotal(r1, c1, addScore)

			local item1 = mainLogic.gameItemMap[r1][c1]
			item1:AddItemStatus(GameItemStatusType.kDestroy)
			local action =	GameBoardActionDataSet:createAs(
				GameActionTargetType.kGameItemAction,
				GameItemActionType.kItem_Blocker195_Dec,
				IntCoord:create(r1,c1),
				nil,
				GamePlayConfig_Blcoker195_Destroy_Time)
			mainLogic:addDestroyAction(action)
			return
		elseif theAction.addInfo == "start" then
			theAction.addInfo = "waiting"
			theAction.jsq = 0
			return
		elseif theAction.addInfo == "waiting" then
			theAction.jsq = theAction.jsq + 1
			if theAction.jsq >= 20 then
				theAction.addInfo = "flying"
				theAction.jsq = 0
				theAction.posList = positionList
				local itemView = boardView.baseMap[r1][c1]
				local fromPos = itemView:getBasePosition(c1, r1)
				for k,v in pairs(theAction.posList) do
					local row, col = v.x, v.y
					local exchangeWithGhost = false
					if theAction.actionType == GameItemActionType.kItemSpecial_Blocker195_Ghost then
						row, col = v.y, v.x
						exchangeWithGhost = true
					end

					local item = mainLogic.gameItemMap[row][col]
					if item:isAvailable() or (exchangeWithGhost and item:isFreeGhost()) then 
						local toPos = boardView.baseMap[row][col]:getBasePosition(col, row)
						itemView:playBlocker195FlyAnimation(fromPos, toPos)
					end
				end
			end
		elseif theAction.addInfo == "flying" then
			theAction.jsq = theAction.jsq + 1
			if theAction.jsq >= 38 then
				theAction.addInfo = "bomb"
				theAction.jsq = 0
				for k,v in pairs(theAction.posList) do
					local row, col = v.x, v.y
					local exchangeWithGhost = false
					if theAction.actionType == GameItemActionType.kItemSpecial_Blocker195_Ghost then
						row, col = v.y, v.x
						exchangeWithGhost = true
					end
					local item = mainLogic.gameItemMap[row][col] 
					if item:isAvailable() and item.beEffectByMimosa == 0 or (exchangeWithGhost and item:isFreeGhost()) then 
						callback(mainLogic, v, SpecialID)
					elseif item.beEffectByMimosa == GameItemType.kKindMimosa then
 						GameExtandPlayLogic:backMimosaToRC(mainLogic, row, col)
 					end
				end
			end
		elseif theAction.addInfo == "bomb" then
			mainLogic:tryBombSuperTotems()
			theAction.addInfo = "over"
		end
	end
end

local function clearSameColor(mainLogic, position, SpecialID )
	local r, c = position.x, position.y
	GameExtandPlayLogic:changeTotemsToWattingActive(mainLogic, r, c, 1, false)
	SpecialCoverLogic:SpecialCoverLightUpAtPos(mainLogic, r, c, 1)
	BombItemLogic:tryCoverByBomb(mainLogic, r, c, true, 1)
	SpecialCoverLogic:SpecialCoverAtPos(mainLogic, r, c, 3, nil,nil,nil,nil,nil,SpecialID)
end

function DestructionPlanLogic:runGameItemBlocker195ColorAction(boardView, theAction)
	local mainLogic = boardView.gameBoardLogic
	local r2, c2 = theAction.ItemPos2.x, theAction.ItemPos2.y
	local item2 = mainLogic.gameItemMap[r2][c2] 
	local color = item2._encrypt.ItemColorType
	local posList = mainLogic:getPosListOfColor(color)
	doBlocker195FullSwap(boardView, theAction, posList, clearSameColor)
end

function DestructionPlanLogic:runGameItemBlocker195KindColorAction(boardView, theAction)
	local mainLogic = boardView.gameBoardLogic
	local r2, c2 = theAction.ItemPos2.x, theAction.ItemPos2.y
	local item2 = mainLogic.gameItemMap[r2][c2] 
	local color = item2._encrypt.ItemColorType
	local posList = mainLogic:getPosListOfColor(color)
	posList = table.union(posList, mainLogic:getPosListOfItemType(item2.ItemType, color))
	doBlocker195FullSwap(boardView, theAction, posList, clearSameColor)
end

function DestructionPlanLogic:runGameItemBlocker195CoinAction(boardView, theAction)
	local mainLogic = boardView.gameBoardLogic
	local posList = mainLogic:getPosListOfItemType(GameItemType.kCoin)

    local SpecialID = mainLogic:addSrcSpecialCoverToList( theAction.ItemPos1, theAction.ItemPos2 )

	local function callback(mainLogic, position)
		BombItemLogic:tryCoverByBomb(mainLogic, position.x, position.y, true, 1)
		SpecialCoverLogic:SpecialCoverAtPos(mainLogic, position.x, position.y, 3, nil,nil,nil,nil,nil,SpecialID) 
	end
	doBlocker195FullSwap(boardView, theAction, posList, callback)
end

function DestructionPlanLogic:runGameItemBlocker195HoneyBottleAction(boardView, theAction)
	local mainLogic = boardView.gameBoardLogic
	local posList = mainLogic:getPosListOfItemType(GameItemType.kHoneyBottle)
	local function callback(mainLogic, position)
		local r, c = position.x, position.y
		if SpecialCoverLogic:canBeEffectBySpecialAt(mainLogic, r, c) then
			SpecialCoverLogic:effectBlockerAt(mainLogic, r, c, 1, nil, false, false)
		end
	end
	doBlocker195FullSwap(boardView, theAction, posList, callback)
end

function DestructionPlanLogic:runGameItemBlocker195MissileAction(boardView, theAction)
	local mainLogic = boardView.gameBoardLogic
	local posList = mainLogic:getPosListOfItemType(GameItemType.kMissile)
	local function callback(mainLogic, position)
		local r, c = position.x, position.y
		if SpecialCoverLogic:canBeEffectBySpecialAt(mainLogic, r, c) then
			SpecialCoverLogic:effectBlockerAt(mainLogic, r, c, 1, nil, false, false)
		end
	end
	doBlocker195FullSwap(boardView, theAction, posList, callback)
end

function DestructionPlanLogic:runGameItemBlocker195PufferAction(boardView, theAction)
	local mainLogic = boardView.gameBoardLogic
	local posList = mainLogic:getPosListOfItemType(GameItemType.kPuffer)
	local function callback(mainLogic, position)
		local r, c = position.x, position.y
		if SpecialCoverLogic:canBeEffectBySpecialAt(mainLogic, r, c) then
			SpecialCoverLogic:effectBlockerAt(mainLogic , r , c)
		end
	end
	doBlocker195FullSwap(boardView, theAction, posList, callback)
end

function DestructionPlanLogic:runGameItemBlocker195Blocker207Action(boardView, theAction)
	local mainLogic = boardView.gameBoardLogic
	local posList = mainLogic:getPosListOfItemType(GameItemType.kBlocker207)

    local SpecialID = mainLogic:addSrcSpecialCoverToList( theAction.ItemPos1, theAction.ItemPos2 )

	local function callback(mainLogic, position)
		local r, c = position.x, position.y
		if SpecialCoverLogic:canBeEffectBySpecialAt(mainLogic, r, c) then
			BombItemLogic:tryCoverByBomb(mainLogic, r, c, true, 1)
			SpecialCoverLogic:SpecialCoverAtPos(mainLogic, r, c, 3, nil,nil,nil,nil,nil,SpecialID) 
		end
	end
	doBlocker195FullSwap(boardView, theAction, posList, callback)
end

function DestructionPlanLogic:runGameItemBlocker195BlockerGhostAction(boardView, theAction)
	local mainLogic = boardView.gameBoardLogic
	local posList = GhostLogic:getAllVisibleGhostOnBoard(mainLogic)

    local SpecialID = mainLogic:addSrcSpecialCoverToList( theAction.ItemPos1, theAction.ItemPos2 )

	local function callback(mainLogic, position)
		local r, c = position.y, position.x
		if SpecialCoverLogic:canBeEffectBySpecialAt(mainLogic, r, c) then
			SpecialCoverLogic:SpecialCoverAtPos(mainLogic, r, c, 3, nil,nil,nil,nil,nil,SpecialID) 
		end
	end
	doBlocker195FullSwap(boardView, theAction, posList, callback)
end

function DestructionPlanLogic:runGameItemBlocker195WanShengAction(boardView, theAction)
	local mainLogic = boardView.gameBoardLogic
	local posList = mainLogic:getPosListOfItemType(GameItemType.kWanSheng)
	local function callback(mainLogic, position)
		local r, c = position.x, position.y
		if SpecialCoverLogic:canBeEffectBySpecialAt(mainLogic, r, c) then
			SpecialCoverLogic:effectBlockerAt(mainLogic, r, c, 1, nil, false, false)
		end
	end
	doBlocker195FullSwap(boardView, theAction, posList, callback)
end

function DestructionPlanLogic:runningGameItemBlocker199DecAction(mainLogic, theAction, actid)
	if theAction.actionStatus == GameActionStatus.kRunning and theAction.addInfo == "over" then
		theAction.actionStatus = GameActionStatus.kWaitingForDeath
	end
end

function DestructionPlanLogic:runGameItemBlocker199DecAction(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning

		local r1, c1 = theAction.ItemPos1.x, theAction.ItemPos1.y
		local item = boardView.baseMap[r1][c1]

		item:playBlocker199GrowupAnimation(theAction.addInt)
		theAction.addInfo = "over"
	elseif theAction.actionStatus == GameActionStatus.kRunning then
		--[[theAction.jsq = theAction.jsq + 1
		if theAction.jsq >= theAction.maxJsq then
			theAction.addInfo = "over"
		end]]--
	end
end

function DestructionPlanLogic:runningGameItemBlocker199ExplodeAction(mainLogic, theAction, actid)
	if theAction.actionStatus == GameActionStatus.kRunning then 
		local r1 = theAction.ItemPos1.x
		local c1 = theAction.ItemPos1.y
		local scoreScale = theAction.addInt
		local item = mainLogic.gameItemMap[r1][c1]
		local itemView = mainLogic.boardView.baseMap[r1][c1]

--        local SpecialID = mainLogic:addSrcSpecialCoverToList( theAction.ItemPos1 )

		if theAction.addInfo == '' then
			theAction.jsq = 1

			if not theAction.SpecialID then
	            theAction.SpecialID = mainLogic:addSrcSpecialCoverToList( theAction.ItemPos1 )

	            local bLeftCanStop = mainLogic:CheckPosCanStopJamSperad( IntCoord:create(theAction.ItemPos1.x,theAction.ItemPos1.y),
	                IntCoord:create(theAction.ItemPos1.x,theAction.ItemPos1.y+1) )
	            local bRightCanStop = mainLogic:CheckPosCanStopJamSperad( IntCoord:create(theAction.ItemPos1.x,theAction.ItemPos1.y),
	                IntCoord:create(theAction.ItemPos1.x,theAction.ItemPos1.y-1) )
	            local bUpCanStop = mainLogic:CheckPosCanStopJamSperad( IntCoord:create(theAction.ItemPos1.x,theAction.ItemPos1.y),
	                IntCoord:create(theAction.ItemPos1.x+1,theAction.ItemPos1.y) )
	            local bDownCanStop = mainLogic:CheckPosCanStopJamSperad( IntCoord:create(theAction.ItemPos1.x,theAction.ItemPos1.y),
	                IntCoord:create(theAction.ItemPos1.x-1,theAction.ItemPos1.y) )

	            if bLeftCanStop then theAction.LeftSpecialID = nil else theAction.LeftSpecialID = theAction.SpecialID end
	            if bRightCanStop then theAction.RightSpecialID = nil else theAction.RightSpecialID = theAction.SpecialID end
	            if bUpCanStop then theAction.UpSpecialID = nil else theAction.UpSpecialID = theAction.SpecialID end
	            if bDownCanStop then theAction.DownSpecialID = nil else theAction.DownSpecialID = theAction.SpecialID end

	            theAction.LeftStop = false
	            theAction.RightStop = false
	            theAction.UpStop = false
	            theAction.DownStop = false
	            theAction.LeftStopNum = 0
	            theAction.RightStopNum = 0
	            theAction.UpStopNum = 0
	            theAction.DownStopNum = 0
	        end

			theAction.addInfo = 'doing'
			itemView:playBlocker199ExplodeAnimation()
			mainLogic:addScoreToTotal(r1, c1, 100, item._encrypt.ItemColorType)
			theAction.lightUpBombMatchPosList = item.lightUpBombMatchPosList

			if item.ItemStatus == GameItemStatusType.kWaitBomb then item:AddItemStatus( GameItemStatusType.kNone , true ) end
			if not DestructionPlanLogic:existInSpecialBombLightUpPos(mainLogic, r1, c1, theAction.lightUpBombMatchPosList) then
				GameExtandPlayLogic:decreaseLotus(mainLogic, r1, c1 , 1)
				SpecialCoverLogic:SpecialCoverLightUpAtBlocker(mainLogic, r1, c1, 1, true)
			end
			SpecialCoverLogic:SpecialCoverAtPos(mainLogic, r1, c1, 3, 1, actid, nil,nil,nil,theAction.SpecialID)
			SpecialCoverLogic:specialCoverChainsAtPos(mainLogic, r1, c1, theAction.dirs)

			local function callback(r, c, dirs1, dirs2, SpecialID)
				if not DestructionPlanLogic:existInSpecialBombLightUpPos(mainLogic, r, c, theAction.lightUpBombMatchPosList) then
					SpecialCoverLogic:SpecialCoverLightUpAtPos(mainLogic, r, c, 1)
				end
				GameExtandPlayLogic:doABlocker211Collect(mainLogic, nil, nil, r, c, 0, true, 3)
				local s1 = BombItemLogic:tryCoverByBomb(mainLogic, r, c, true, 1, true, nil, ObstacleFootprintType.k_Blocker199)
				SpecialCoverLogic:SpecialCoverAtPos(mainLogic, r, c, 2, 1, actid, nil, nil, ObstacleFootprintType.k_Blocker199,SpecialID)
				if s1 == 2 then 
					SpecialCoverLogic:specialCoverChainsAtPos(mainLogic, r, c, dirs1)
					ObstacleFootprintManager:addBlockEffectRecord(mainLogic.gameItemMap[r][c])
					return true 
				else
					SpecialCoverLogic:specialCoverChainsAtPos(mainLogic, r, c, dirs2)
					return false
				end
			end

			local len = 0
			if theAction.ItemPos2.x == 1 then
				for i = c1 + 1, 9 do

                    local CurBoard = mainLogic.boardmap[r1][i]
                    if CurBoard.isJamSperad and theAction.LeftStop then
                        theAction.LeftStop = false
                        theAction.LeftStopNum = 0
                    end

                    local SpecialID = nil
                    local nextPos = ccp(r1,i+1)
                    SpecialID, theAction.LeftStopNum, theAction.LeftStop, theAction.LeftSpecialID = JamSperadSpecialIDCheck( 
                        mainLogic, 
                        ccp(r1,i), 
                        nextPos,
                        theAction.LeftStop, 
                        theAction.LeftStopNum, 
                        theAction.LeftSpecialID )

					local isBreak = callback(r1, i, {ChainDirConfig.kLeft}, {ChainDirConfig.kLeft, ChainDirConfig.kRight}, SpecialID)
					if isBreak then break end
					len = len + 1
				end
				if len > 0 then itemView:playBlocker199EffectAnimation(len, 90) end
			else
				for i= c1 - 1, 1, -1 do

                    local CurBoard = mainLogic.boardmap[r1][i]
                    if CurBoard.isJamSperad and theAction.LeftStop then
                        theAction.RightStop = false
                        theAction.RightStopNum = 0
                    end

                    local SpecialID = nil
                    local nextPos = ccp(r1,i-1)
                    SpecialID, theAction.RightStopNum, theAction.RightStop, theAction.RightSpecialID = JamSperadSpecialIDCheck( 
                        mainLogic, 
                        ccp(r1,i), 
                        nextPos,
                        theAction.RightStop, 
                        theAction.RightStopNum, 
                        theAction.RightSpecialID )

					local isBreak = callback(r1, i, {ChainDirConfig.kRight}, {ChainDirConfig.kLeft, ChainDirConfig.kRight}, SpecialID)
					if isBreak then break end
					len = len + 1
				end
				if len > 0 then itemView:playBlocker199EffectAnimation(len,-90) end
			end

			len = 0
			if theAction.ItemPos2.y == 1 then
				for i = r1 + 1, 9 do

                    local CurBoard = mainLogic.boardmap[i][c1]
                    if CurBoard.isJamSperad and theAction.LeftStop then
                        theAction.UpStop = false
                        theAction.UpStopNum = 0
                    end

                    local SpecialID = nil
                    local nextPos = ccp(i+1,c1)
                    SpecialID, theAction.UpStopNum, theAction.UpStop, theAction.UpSpecialID = JamSperadSpecialIDCheck( 
                        mainLogic, 
                        ccp(i,c1), 
                        nextPos,
                        theAction.UpStop, 
                        theAction.UpStopNum, 
                        theAction.UpSpecialID )

					local isBreak = callback(i, c1, {ChainDirConfig.kUp}, {ChainDirConfig.kUp, ChainDirConfig.kDown},SpecialID)
					if isBreak then break end
					len = len + 1
				end
				if len > 0 then itemView:playBlocker199EffectAnimation(len, 180) end
			else
				for i = r1 - 1, 1, -1 do

                    local CurBoard = mainLogic.boardmap[i][c1]
                    if CurBoard.isJamSperad and theAction.LeftStop then
                        theAction.DownStop = false
                        theAction.DownStopNum = 0
                    end

                    local SpecialID = nil
                    local nextPos = ccp(i-1,c1)
                    SpecialID, theAction.DownStopNum, theAction.DownStop, theAction.DownSpecialID = JamSperadSpecialIDCheck( 
                        mainLogic, 
                        ccp(i,c1), 
                        nextPos,
                        theAction.DownStop, 
                        theAction.DownStopNum, 
                        theAction.DownSpecialID )

					local isBreak = callback(i, c1, {ChainDirConfig.kDown}, {ChainDirConfig.kUp, ChainDirConfig.kDown},SpecialID)
					if isBreak then break end
					len = len + 1
				end
				if len > 0 then itemView:playBlocker199EffectAnimation(len, 0) end
			end
		elseif theAction.addInfo == 'doing' then
			theAction.jsq = theAction.jsq + 1

			-- 若被鱿鱼大招影响，此时消除视图
			if theAction.jsq == 40 then
				if item and item.needRemoveEventuallyBySquid then
					theAction.itemRemoved = true
					item:cleanAnimalLikeData()
					item.isNeedUpdate = true
					mainLogic:checkItemBlock(r1, c1)
				end
			end

			if theAction.jsq >= 53 then
				theAction.addInfo = 'over'
			end
		end

		if theAction.addInfo == 'over' then
			if not theAction.itemRemoved then item._encrypt.ItemColorType = 0 end
			theAction.actionStatus = GameActionStatus.kWaitingForDeath
		end
	end
end

function DestructionPlanLogic:runGameItemBlocker199ExplodeAction(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning

		--播放特效
		--[[local r1 = theAction.ItemPos1.x
		local c1 = theAction.ItemPos1.y
		local position1 = DestructionPlanLogic:getItemPosition(theAction.ItemPos1)
		local effect = CommonEffect:buildLineEffect(boardView.specialEffectBatch)
		effect:setPosition(position1)
		effect:setRotation(90)
		
		boardView.specialEffectBatch:addChild(effect)]]--
	end
end

function DestructionPlanLogic:runningGameItemActionRocketActive(mainLogic, theAction, actid)
	if theAction.actionStatus == GameActionStatus.kRunning then
		if theAction.addInfo == "over" then
			mainLogic.destructionPlanList[actid] = nil
		elseif theAction.addInfo == "rocketFly" then
			local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y

            local SpecialID = mainLogic:addSrcSpecialCoverToList( theAction.ItemPos1, theAction.ItemPos2 )

			SpecialCoverLogic:SpecialCoverLightUpAtPos(mainLogic, r, c, GamePlayConfig_Score_Rocket_Bomb_Scale, true)
			BombItemLogic:tryCoverByBomb(mainLogic, r, c, true, GamePlayConfig_Score_Rocket_Bomb_Scale, true)
			SpecialCoverLogic:SpecialCoverAtPos(mainLogic, r, c, 2, GamePlayConfig_Score_Rocket_Bomb_Scale, actId, nil, nil, nil,SpecialID)
			SpecialCoverLogic:specialCoverChainsAtPos(mainLogic, r, c, {ChainDirConfig.kUp})
			
			if r > 1 then
				for tr = r-1, 1, -1 do
					local item = nil
					if mainLogic.gameItemMap[tr] then
						item = mainLogic.gameItemMap[tr][c]
					end
					if item then

						SpecialCoverLogic:SpecialCoverLightUpAtPos(mainLogic, tr, c, GamePlayConfig_Score_Rocket_Bomb_Scale, true)
						BombItemLogic:tryCoverByBomb(mainLogic, tr, c, true, GamePlayConfig_Score_Rocket_Bomb_Scale, true)
						SpecialCoverLogic:SpecialCoverAtPos(mainLogic, tr, c, 2, GamePlayConfig_Score_Rocket_Bomb_Scale, actId, nil, nil, nil,SpecialID)
						SpecialCoverLogic:specialCoverChainsAtPos(mainLogic, tr, c, {ChainDirConfig.kUp, ChainDirConfig.kDown})
					end
				end
			end
			
			theAction.addInfo = "over"
		end
	end
end

function DestructionPlanLogic:runGameItemActionRocketActive(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning

		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local item = boardView.baseMap[r][c]

		local function callback()
			if theAction.isUFOExist then
				boardView.PlayUIDelegate:playUFOHitAnimation()
				ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_UFO, ObstacleFootprintAction.k_Hit, 1)
			end
		end
		theAction.addInfo = "rocketFly"
		local color = theAction.addInt
		item:playRocketFlyAnimation(boardView, color, theAction.ItemPos1, theAction.ItemPos2, callback)
		ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_Rocket, ObstacleFootprintAction.k_Eliminate, 1)
	end
end

function DestructionPlanLogic:runningGameItemActionBottleBlockerDestroyAroundActive(mainLogic, theAction, actid)

	if theAction.actionStatus == GameActionStatus.kRunning then

        local SpecialID = mainLogic:addSrcSpecialCoverToList( theAction.ItemPos1 )

		local item = mainLogic.gameItemMap[theAction.ItemPos1.x][theAction.ItemPos1.y]

		local bottleRow = item.y
		local bottleCol = item.x

		local function explodeItem(r,c)

			if r >= 1 and r <= 9 and c >= 1 and c <= 9 then
				local item = nil
				if mainLogic.gameItemMap[r] then
					item = mainLogic.gameItemMap[r][c]
				end

				if item then
					SpecialCoverLogic:SpecialCoverLightUpAtPos(mainLogic, r, c, 1, true)
					BombItemLogic:tryCoverByBomb(mainLogic, r, c, true, 1, true)
					SpecialCoverLogic:SpecialCoverAtPos(mainLogic, r, c, 3, 1, actId, nil, nil, nil, SpecialID)
					GameExtandPlayLogic:doABlocker211Collect(mainLogic, nil, nil, r, c, 0, true, 3)
					--if SpecialCoverLogic:canBeEffectBySpecialAt(mainLogic, r, c) then
					--	SpecialCoverLogic:effectBlockerAt(mainLogic, r, c, 1, actid)
					--end
				end
			end
		end

		explodeItem(bottleRow + 1 , bottleCol)
		explodeItem(bottleRow - 1 , bottleCol)
		explodeItem(bottleRow     , bottleCol + 1)
		explodeItem(bottleRow     , bottleCol - 1)

		explodeItem(bottleRow     , bottleCol)
		-- 消除一层瓶子四周的冰柱
		SpecialCoverLogic:specialCoverChainsAroundPos(mainLogic, bottleRow, bottleCol, {ChainDirConfig.kUp, ChainDirConfig.kDown, ChainDirConfig.kRight, ChainDirConfig.kLeft})
		SnailLogic:SpecialCoverSnailRoadAtPos( mainLogic, bottleRow, bottleCol )
		
		mainLogic:checkItemBlock(bottleRow, bottleCol)
		mainLogic:setNeedCheckFalling()

		theAction.actionStatus = GameActionStatus.kWaitingForDeath

		if item.bottleActionRunningCount then item.bottleActionRunningCount = item.bottleActionRunningCount - 1 end
	end
	
end


function DestructionPlanLogic:runningGameItemActionMagicStoneActive(mainLogic, theAction, actid)
	local r = theAction.ItemPos1.x
	local c = theAction.ItemPos1.y

	if theAction.addInfo == "over" then
		if theAction.addInfo1 == "animFinish" then -- 等待动画播完

			local item = mainLogic.gameItemMap[r][c]
			if item and item.needRemoveEventuallyBySquid then
				if mainLogic.boardView.baseMap[r] and mainLogic.boardView.baseMap[r][c] then
					local itemView = mainLogic.boardView.baseMap[r][c]
					itemView:squidCommonDestroyItemAnimation()
				end

				item:cleanAnimalLikeData()
				mainLogic:checkItemBlock(r, c)
			end

			mainLogic.destructionPlanList[actid] = nil
		end
	else
		theAction.addInt = theAction.addInt + 1
		--printx( 1 , "    DestructionPlanLogic:runningGameItemActionMagicStoneActive  addInt = " , theAction.addInt , actid , r , c)
		if theAction.addInt == 16 then -- PC是16
			-- 魔法石所在格子的冰柱处理
			SpecialCoverLogic:specialCoverChainsAtPos(mainLogic, r, c, {ChainDirConfig.kUp, ChainDirConfig.kDown, ChainDirConfig.kRight, ChainDirConfig.kLeft})
			if theAction.targetPos then
				local item = mainLogic.gameItemMap[r][c]

                local SpecialID = mainLogic:addSrcSpecialCoverToList( theAction.ItemPos1 )

				for _,v in pairs(theAction.targetPos) do
					local tr, tc = r + v.x, c + v.y
					SpecialCoverLogic:SpecialCoverLightUpAtPos(mainLogic, tr, tc, 1, false)  --可以作用银币
					BombItemLogic:tryCoverByBomb(mainLogic, tr, tc, true, 1, nil, nil, ObstacleFootprintType.k_MagicStone)
					SpecialCoverLogic:SpecialCoverAtPos(mainLogic, tr, tc, 3, nil, nil, nil, nil, ObstacleFootprintType.k_MagicStone,SpecialID) 
					GameExtandPlayLogic:doABlocker211Collect(mainLogic, nil, nil, tr, tc, 0, true, 3)
					-- 对消除区域冰柱的影响
					local breakChainDirs = {}
					if math.abs(v.x) + math.abs(v.y) == 1 then -- 相邻的3个格子
						breakChainDirs = {ChainDirConfig.kUp, ChainDirConfig.kDown, ChainDirConfig.kRight, ChainDirConfig.kLeft}
					else -- 不相邻的5个格子
						if v.x < 0 then table.insert(breakChainDirs, ChainDirConfig.kDown) end
						if v.x > 0 then table.insert(breakChainDirs, ChainDirConfig.kUp) end
						if v.y < 0 then table.insert(breakChainDirs, ChainDirConfig.kRight) end
						if v.y > 0 then table.insert(breakChainDirs, ChainDirConfig.kLeft) end
					end
					SpecialCoverLogic:specialCoverChainsAtPos(mainLogic, tr, tc, breakChainDirs)
				end
			end
		elseif theAction.addInt > 33 then  -- 16*2+1，确保一个来回不会被触发
			local item = mainLogic.gameItemMap[r][c]
			if item and not item.needRemoveEventuallyBySquid then
				item.magicStoneLocked = false
			end

			--printx( 1 , "   DestructionPlanLogic:runningGameItemActionMagicStoneActive   magicStoneLocked = false   actid = " , actid ,  r , c , "  theAction.addInfo1 = " , theAction.addInfo1)
			theAction.addInfo = "over"
		end
	end
end

function DestructionPlanLogic:runnGameItemActionBottleBlockerDestroyAround(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
	end
end

function DestructionPlanLogic:runGameItemActionMagicStone(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning

		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local item = boardView.baseMap[r][c]

		theAction.addInt = 1
		local function onAnimFinished()
			theAction.addInfo1 = "animFinish"
		end
		item:playStoneActiveAnim(theAction.magicStoneLevel, theAction.targetPos, onAnimFinished)

		if theAction.magicStoneLevel < TileMagicStoneConst.kMaxLevel then
			theAction.addInfo = "over"
		end
	end
end

function DestructionPlanLogic:runGameItemActionHedgehogCrazyMove(boardView, theAction)
	-- body
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		theAction.addInfo ="moveStart"
		theAction.addInt = 20
		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local item = boardView.baseMap[r][c]
		item:playHedgehogInShellAnimation(theAction.direction, nil, 2, true)
	elseif theAction.addInfo == "moving" then
		theAction.addInfo = ""
		GamePlayMusicPlayer:playEffect(GameMusicType.kHedgehogCrazyMove)
		local r1, c1 = theAction.ItemPos1.x, theAction.ItemPos1.y
		local r2, c2 = theAction.ItemPos2.x, theAction.ItemPos2.y
		local item1 = boardView.baseMap[r1][c1]
		local item2 = boardView.baseMap[r2][c2]
		if item2.itemSprite[ItemSpriteType.kSnailMove] ~= nil then
			theAction.addInfo = "moving"
		else
			item2.itemSprite[ItemSpriteType.kSnailMove] = item1.itemSprite[ItemSpriteType.kSnailMove]
			item1.itemSprite[ItemSpriteType.kSnailMove] = nil
			local rotation 
			if c2 - c1 == 1 then rotation = 0 
			elseif c2 - c1 == -1 then rotation = 180
			elseif r2 - r1 == 1 then rotation = 90
			elseif r2 - r1 == -1 then rotation = -90 end
			theAction.addInfo = "moveEnd"
			theAction.addInt = 12
			item2:playSnailMovingAnimation(rotation)
		end
	elseif theAction.addInfo == "normal" then
		theAction.addInfo = ""
		local r2, c2 = theAction.ItemPos2.x, theAction.ItemPos2.y
		local item2 = boardView.baseMap[r2][c2]
		theAction.addInfo = "over"
		theAction.addInt = 13
		item2:playHedgehogOutShellAnimation(theAction.direction, nil , 1)
	end
end

function DestructionPlanLogic:runGameItemActionHedgehogMove(boardView, theAction)
	-- body
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		theAction.addInfo ="moveStart"
		theAction.addInt = 10
		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local item = boardView.baseMap[r][c]
		item:playHedgehogInShellAnimation(theAction.direction, nil, theAction.hedgehogLevel)
	elseif theAction.addInfo == "moving" then
		theAction.addInfo = ""
		local r1, c1 = theAction.ItemPos1.x, theAction.ItemPos1.y
		local r2, c2 = theAction.ItemPos2.x, theAction.ItemPos2.y
		local item1 = boardView.baseMap[r1][c1]
		local item2 = boardView.baseMap[r2][c2]
		if item2.itemSprite[ItemSpriteType.kSnailMove] ~= nil then
			theAction.addInfo = "moving"
		else
			item2.itemSprite[ItemSpriteType.kSnailMove] = item1.itemSprite[ItemSpriteType.kSnailMove]
			item1.itemSprite[ItemSpriteType.kSnailMove] = nil
			local rotation 
			if c2 - c1 == 1 then rotation = 0 
			elseif c2 - c1 == -1 then rotation = 180
			elseif r2 - r1 == 1 then rotation = 90
			elseif r2 - r1 == -1 then rotation = -90 end
			theAction.addInfo = "moveEnd"
			theAction.addInt = 12
			item2:playSnailMovingAnimation(rotation)
		end
	elseif theAction.addInfo == "normal" then
		theAction.addInfo = ""
		local r2, c2 = theAction.ItemPos2.x, theAction.ItemPos2.y
		local item2 = boardView.baseMap[r2][c2]
		theAction.addInfo = "over"
		theAction.addInt = 13
		item2:playHedgehogOutShellAnimation(theAction.direction, nil, theAction.hedgehogLevel)
	end
end

function DestructionPlanLogic:runGameItemActionSnailMove(boardView, theAction)
	-- body
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		theAction.addInfo ="moveStart"
		theAction.addInt = 26 --30
		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local item = boardView.baseMap[r][c]
		item:playSnailInShellAnimation(theAction.direction)
	elseif theAction.addInfo == "moving" then
		theAction.addInfo = ""
		local r1, c1 = theAction.ItemPos1.x, theAction.ItemPos1.y
		local r2, c2 = theAction.ItemPos2.x, theAction.ItemPos2.y
		local item1 = boardView.baseMap[r1][c1]
		local item2 = boardView.baseMap[r2][c2]
		if item2.itemSprite[ItemSpriteType.kSnailMove] ~= nil then
			theAction.addInfo = "moving"
		else
			item2.itemSprite[ItemSpriteType.kSnailMove] = item1.itemSprite[ItemSpriteType.kSnailMove]
			item1.itemSprite[ItemSpriteType.kSnailMove] = nil
			local rotation 
			if c2 - c1 == 1 then rotation = 0 
			elseif c2 - c1 == -1 then rotation = 180
			elseif r2 - r1 == 1 then rotation = 90
			elseif r2 - r1 == -1 then rotation = -90 end
			theAction.addInfo = "moveEnd"
			theAction.addInt = 8 --12
			item2:playSnailMovingAnimation(rotation)
		end

		
	elseif theAction.addInfo == "disappear" then
		theAction.addInfo = ""
		local r2, c2 = theAction.ItemPos2.x, theAction.ItemPos2.y
		local item2 = boardView.baseMap[r2][c2]
		theAction.addInfo = "over"
		theAction.addInt = 40
		item2:playSnailDisappearAnimation()
	elseif theAction.addInfo == "normal" then
		theAction.addInfo = ""
		local r2, c2 = theAction.ItemPos2.x, theAction.ItemPos2.y
		local item2 = boardView.baseMap[r2][c2]
		theAction.addInfo = "over"
		theAction.addInt = 30
		item2:playSnailOutShellAnimation(theAction.direction)
	end

end

function DestructionPlanLogic:runningGameItemActionHedgehogCrazyMove(mainLogic, theAction, actid)
	-- body
	if theAction.addInt > 1 then 
		theAction.addInt = theAction.addInt - 1
		return 
	end
	
	if theAction.addInfo == "moveStart" then
		local list = theAction.moveList
		
		if #list > 0 then
			local pos = table.remove(list, 1)
			theAction.ItemPos1 = theAction.ItemPos2 or theAction.ItemPos1
			theAction.ItemPos2 = pos
			theAction.addInfo = "moving"
		else
			local r, c = theAction.ItemPos2.x, theAction.ItemPos2.y
			local board = mainLogic.boardmap[r][c]
			if board.isSnailCollect then
				theAction.addInfo = "disappear"
			else
				theAction.addInfo = "normal"
				theAction.direction = board.snailRoadType
			end

		end
	elseif theAction.addInfo == "moveEnd" then
		theAction.addInfo = "moveStart"
		local r1, c1 = theAction.ItemPos1.x, theAction.ItemPos1.y
		local item1 = mainLogic.gameItemMap[r1][c1]
		local board1 = mainLogic.boardmap[r1][c1]
		if item1:isHedgehog() then 
			item1:cleanAnimalLikeData()
			item1.hedgehogLevel = 0
		end

		if board1.snailTargetCount > 0 then 
			board1.snailTargetCount = board1.snailTargetCount - 1
		end

		if board1.snailTargetCount > 0 then 
			item1.snailTarget = true
		else
			item1.snailTarget = false
		end

		mainLogic:checkItemBlock(r1, c1)

		local r, c = theAction.ItemPos2.x, theAction.ItemPos2.y
		local item2 = mainLogic.gameItemMap[r][c]
		local board2 = mainLogic.boardmap[r][c]
		HedgehogLogic:resetHedgehogRoadAtPos( mainLogic, r, c )
		board2.snailTargetCount = board2.snailTargetCount + 1
		item2.snailTarget = true
		HedgehogLogic:cleanItem( mainLogic, r, c )
	elseif theAction.addInfo == "over" then
		local r, c = theAction.ItemPos2.x, theAction.ItemPos2.y
		local board = mainLogic.boardmap[r][c]
		local itemdata = mainLogic.gameItemMap[r][c]
		itemdata:changeToHedgehog(board.snailRoadType, theAction.hedgehogLevel)
		SnailLogic:resetSnailRoadAtPos( mainLogic, r, c )
		mainLogic:checkItemBlock(r, c)
		if theAction.completeCallback then
			theAction.completeCallback()
		end
		mainLogic.isHedgehogCrazy = false
		mainLogic.destructionPlanList[actid] = nil
	end
end

function DestructionPlanLogic:runningGameItemActionHedgehogMove(mainLogic, theAction, actid)
	-- body
	if theAction.addInt > 1 then 
		theAction.addInt = theAction.addInt - 1
		return 
	end
	if theAction.addInfo == "moveStart" then
		local list = theAction.moveList
		
		if #list > 0 then
			local pos = table.remove(list, 1)
			theAction.ItemPos1 = theAction.ItemPos2 or theAction.ItemPos1
			theAction.ItemPos2 = pos
			theAction.addInfo = "moving"
		else
			local r, c = theAction.ItemPos2.x, theAction.ItemPos2.y
			local board = mainLogic.boardmap[r][c]
			theAction.addInfo = "normal"
			theAction.direction = board.snailRoadType
		end
	elseif theAction.addInfo == "moveEnd" then
		theAction.addInfo = "moveStart"
		local r1, c1 = theAction.ItemPos1.x, theAction.ItemPos1.y
		local item1 = mainLogic.gameItemMap[r1][c1]
		local board1 = mainLogic.boardmap[r1][c1]

        local SpecialID = mainLogic:addSrcSpecialCoverToList( theAction.ItemPos1 )
		

		if item1:isHedgehog() then 
			item1:cleanAnimalLikeData()
			item1.hedgehogLevel = 0
		end

		if board1.snailTargetCount > 0 then 
			board1.snailTargetCount = board1.snailTargetCount - 1
		end

		if board1.snailTargetCount > 0 then 
			item1.snailTarget = true
		else
			item1.snailTarget = false
		end

		mainLogic:checkItemBlock(r1, c1)
		local r, c = theAction.ItemPos2.x, theAction.ItemPos2.y
		local item2 = mainLogic.gameItemMap[r][c]
		local board2 = mainLogic.boardmap[r][c]
		HedgehogLogic:resetHedgehogRoadAtPos( mainLogic, r, c )

		board2.snailTargetCount = board2.snailTargetCount + 1
		item2.snailTarget = true
		SpecialCoverLogic:SpecialCoverLightUpAtPos(mainLogic, r, c, 1)
		BombItemLogic:tryCoverByBomb(mainLogic, r, c, true, 1)
		SpecialCoverLogic:SpecialCoverAtPos(mainLogic, r, c, 3, nil,nil,nil,nil,nil,SpecialID)
		mainLogic:checkItemBlock(r, c)
	elseif theAction.addInfo == "over" then
		local r, c = theAction.ItemPos2.x, theAction.ItemPos2.y
		local board = mainLogic.boardmap[r][c]
		local itemdata = mainLogic.gameItemMap[r][c]
		itemdata:changeToHedgehog(board.snailRoadType, theAction.hedgehogLevel)
		SnailLogic:resetSnailRoadAtPos( mainLogic, r, c )
		mainLogic:checkItemBlock(r, c)
		if theAction.completeCallback then
			theAction.completeCallback()
		end

		mainLogic.destructionPlanList[actid] = nil
	end
end

function DestructionPlanLogic:runningGameItemActionSnailMove(mainLogic, theAction, actid)
	-- body
	if theAction.addInt > 1 then 
		theAction.addInt = theAction.addInt - 1
		return 
	end
	
	if theAction.addInfo == "moveStart" then
		local list = theAction.moveList
		if #list > 0 then
			local pos = table.remove(list, 1)
			theAction.ItemPos1 = theAction.ItemPos2 or theAction.ItemPos1
			theAction.ItemPos2 = pos
			theAction.addInfo = "moving"
		else
			local r, c = theAction.ItemPos2.x, theAction.ItemPos2.y
			local board = mainLogic.boardmap[r][c]
			if board.isSnailCollect then
				theAction.addInfo = "disappear"
			else
				theAction.addInfo = "normal"
				theAction.direction = board.snailRoadType
			end

		end
	elseif theAction.addInfo == "moveEnd" then
		theAction.addInfo = "moveStart"
		local r1, c1 = theAction.ItemPos1.x, theAction.ItemPos1.y
		local item1 = mainLogic.gameItemMap[r1][c1]
		local board1 = mainLogic.boardmap[r1][c1]
		SnailLogic:resetSnailRoadAtPos( mainLogic, r1, c1 )

        local SpecialID = mainLogic:addSrcSpecialCoverToList( theAction.ItemPos1 )

		if item1.isSnail then 
			item1:cleanAnimalLikeData()
			-- item1.isBlock = false
			item1.isSnail = false
		end

		if board1.snailTargetCount > 0 then 
			board1.snailTargetCount = board1.snailTargetCount - 1
		end

		if board1.snailTargetCount > 0 then 
			item1.snailTarget = true
		else
			item1.snailTarget = false
		end

		mainLogic:checkItemBlock(r1, c1)

		local r, c = theAction.ItemPos2.x, theAction.ItemPos2.y
		local item2 = mainLogic.gameItemMap[r][c]
		local board2 = mainLogic.boardmap[r][c]

		board2.snailTargetCount = board2.snailTargetCount + 1
		item2.snailTarget = true
		SpecialCoverLogic:SpecialCoverLightUpAtPos(mainLogic, r, c, 1)
		BombItemLogic:tryCoverByBomb(mainLogic, r, c, true, 1)
		SpecialCoverLogic:SpecialCoverAtPos(mainLogic, r, c, 3, nil,nil,nil,nil,nil,SpecialID)
		mainLogic:checkItemBlock(r, c)
	elseif theAction.addInfo == "over" then
		local r, c = theAction.ItemPos2.x, theAction.ItemPos2.y
		local board = mainLogic.boardmap[r][c]
		local itemdata = mainLogic.gameItemMap[r][c]
		if board.isSnailCollect then
			board.snailTargetCount = board.snailTargetCount - 1
			if  board.snailTargetCount > 0 then 
				itemdata.snailTarget = true 
			else
				itemdata.snailTarget = false
			end

			local addScore = GamePlayConfigScore.Collect_Snail
			mainLogic:addScoreToTotal(r, c, addScore)

			mainLogic:tryDoOrderList(r,c,GameItemOrderType.kSpecialTarget, GameItemOrderType_ST.kSnail, 1)
			ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_Snail, ObstacleFootprintAction.k_Collect, 1)
		else
			itemdata:changeToSnail(board.snailRoadType)
		end
		SnailLogic:resetSnailRoadAtPos( mainLogic, r, c )
		mainLogic:checkItemBlock(r, c)
		if theAction.completeCallback then
			theAction.completeCallback()
		end

		mainLogic.destructionPlanList[actid] = nil
	end
end

function DestructionPlanLogic:getActionTime(CDCount)
	return 1.0 / GamePlayConfig_Action_FPS * CDCount
end

function DestructionPlanLogic:runingGameItemSpecialBombWrapWrapAction(mainLogic, theAction, actid)
	local function getRectBombPos(length, r, c)
		local result = {}
		local rowOffset = r - math.floor(length / 2) - 1
		local colOffset = c - math.floor(length / 2)

		for i = 1, length do
			for j = math.abs(i - 1 - math.floor(length / 2)), length - 1 - math.abs(i - 1 - math.floor(length / 2)) do
				local p = { c = j + colOffset, r = i + rowOffset }
				table.insert(result, p)
			end
		end

		return result
	end

	if theAction.actionDuring == 1 then
		local r1 = theAction.ItemPos1.x
		local c1 = theAction.ItemPos1.y

		local r2 = theAction.ItemPos2.x
		local c2 = theAction.ItemPos2.y

		local scoreScale = 4
		local mergePos = {}
		local pos1Rect = getRectBombPos(9, r1, c1)
		local pos2Rect = getRectBombPos(9, r2, c2)

		for i,v in ipairs(pos1Rect) do
			mergePos[v.c .. "_" .. v.r] = v
		end
		for i,v in ipairs(pos2Rect) do
			mergePos[v.c .. "_" .. v.r] = v
		end

		local centerR = (r1 + r2) / 2
		local centerC = (c1 + c2) / 2

        local SpecialID = mainLogic:addSrcSpecialCoverToList( theAction.ItemPos1, theAction.ItemPos2 )

		for k,v in pairs(mergePos) do
			if v.r >= 1 and v.r <= #mainLogic.boardmap
				and v.c >= 1 and v.c <= #mainLogic.boardmap[v.r] 
				then
				if mainLogic.boardmap[v.r][v.c].isUsed then
					local itemView = mainLogic.boardView.baseMap[v.r][v.c]
					itemView:playMixTileHighlightEffect()
				end

				SpecialCoverLogic:SpecialCoverLightUpAtPos(mainLogic, v.r, v.c, scoreScale)
				BombItemLogic:tryCoverByBomb(mainLogic, v.r, v.c, true, scoreScale)
				SpecialCoverLogic:SpecialCoverAtPos(mainLogic, v.r, v.c, 3, scoreScale, actid, nil,nil,nil,SpecialID )
				local breakDirs = DestructionPlanLogic:calcBreakChainDirsAtPos(v.r, v.c, centerR, centerC, 4.5)
				SpecialCoverLogic:specialCoverChainsAtPos(mainLogic, v.r, v.c, breakDirs)
				GameExtandPlayLogic:doABlocker211Collect(mainLogic, nil, nil, v.r, v.c, 0, true, 3)
			end
		end
		GamePlayMusicPlayer:playEffect(GameMusicType.kSwapWrapWrap);
	end
end

function DestructionPlanLogic:existInSpecialBombLightUpPos(mainLogic, r, c, lightUpMatchPosList)
	if lightUpMatchPosList then
		for i,v in ipairs(lightUpMatchPosList) do
			if v.r == r and v.c == c then
				return true
			end
		end
	end
	return false
end

function DestructionPlanLogic:getItemPosition(itemPos)
	local x = (itemPos.y - 0.5 ) * GamePlayConfig_Tile_Width
	local y = (GamePlayConfig_Max_Item_Y - itemPos.x - 0.5 ) * GamePlayConfig_Tile_Height
	return ccp(x,y)
end

-- 针对区域消除，计算区域内格子需要消除的冰柱
function DestructionPlanLogic:calcBreakChainDirsAtPos(r, c, centerR, centerC, radius)
	local breakDirs = {}
	local deltaR = r - centerR
	local deltaC = c - centerC
	local calcRadius = math.abs(deltaR) + math.abs(deltaC)
	if calcRadius < radius then
		breakDirs = {ChainDirConfig.kUp, ChainDirConfig.kDown, ChainDirConfig.kLeft, ChainDirConfig.kRight}
	elseif calcRadius == radius then
		if deltaR < 0 then
			table.insert(breakDirs, ChainDirConfig.kDown)
		elseif deltaR > 0 then
			table.insert(breakDirs, ChainDirConfig.kUp)
		end

		if deltaC < 0  then
			table.insert(breakDirs, ChainDirConfig.kRight)
		elseif deltaC > 0 then
			table.insert(breakDirs, ChainDirConfig.kLeft)
		end
	end
	return breakDirs
end

----直线（横线）消除特效的执行中逻辑
----一点点展开
function DestructionPlanLogic:runingGameItemSpecialBombLineAction(mainLogic, theAction, actid)
	if theAction.addInfo == "over" then
		return
	end

	local r1 = theAction.ItemPos1.x
	local c1 = theAction.ItemPos1.y
	local scoreScale = theAction.addInt2
	local item = mainLogic.gameItemMap[r1][c1]
    local board = mainLogic.boardmap[r1][c1]

    if not theAction.SpecialID then
        theAction.SpecialID = mainLogic:addSrcSpecialCoverToList( theAction.ItemPos1 )

        local bLeftCanStop = mainLogic:CheckPosCanStopJamSperad( IntCoord:create(theAction.ItemPos1.x,theAction.ItemPos1.y),
            IntCoord:create(theAction.ItemPos1.x,theAction.ItemPos1.y-1) )
        local bRightCanStop = mainLogic:CheckPosCanStopJamSperad( IntCoord:create(theAction.ItemPos1.x,theAction.ItemPos1.y),
            IntCoord:create(theAction.ItemPos1.x,theAction.ItemPos1.y+1) )

        if bLeftCanStop then theAction.LeftSpecialID = nil else theAction.LeftSpecialID = theAction.SpecialID end
        if bRightCanStop then theAction.RightSpecialID = nil else theAction.RightSpecialID = theAction.SpecialID end

        theAction.LeftStop = false
        theAction.RightStop = false
        theAction.LeftStopNum = 0
        theAction.RightStopNum = 0
    end

	if theAction.addInt == 0 then
		if item.ItemStatus == GameItemStatusType.kWaitBomb then item:AddItemStatus( GameItemStatusType.kNone , true ) end
		theAction.lightUpBombMatchPosList = item.lightUpBombMatchPosList
		theAction.extendOffset = 0

		if not DestructionPlanLogic:existInSpecialBombLightUpPos(mainLogic, r1, c1, theAction.lightUpBombMatchPosList) then
			SpecialCoverLogic:SpecialCoverLightUpAtPos(mainLogic, r1, c1, scoreScale)
		end

		BombItemLogic:tryCoverByBomb(mainLogic, r1, c1, true, 0, true)----加过分数的---
		SpecialCoverLogic:SpecialCoverAtPos(mainLogic, r1, c1, 1, nil, actid, nil,nil,nil,theAction.SpecialID ) ----原点---
		SpecialCoverLogic:specialCoverChainsAtPos(mainLogic, r1, c1, {ChainDirConfig.kLeft, ChainDirConfig.kRight})
	end

	theAction.addInt = theAction.addInt + 1

	local addCD = GamePlayConfig_SpecialBomb_Line_Add_CD
	if addCD <= 0 then addCD = 1 end
	local maxRange = math.floor(theAction.addInt / addCD)

	if c1 - theAction.extendOffset <= 0 and c1 + theAction.extendOffset > #mainLogic.gameItemMap[r1] then
		theAction.addInfo = "over"
		return
	end

	local offset = theAction.extendOffset + 1
	local output = "destroy items "

	while offset <= maxRange do
		c2 = c1 - offset
		c3 = c1 + offset

		output = output .. string.format("(%d, %d) ", r1, c2) .. string.format("(%d, %d)", r1, c3)

		if theAction.addInfo ~= "left" then
			if c1 ~= c2 and mainLogic:isPosValid(r1, c2) and mainLogic.gameItemMap[r1][c2].dataReach then

                local CurBoard = mainLogic.boardmap[r1][c2]
                if CurBoard.isJamSperad and theAction.LeftStop then
                    theAction.LeftStop = false
                    theAction.LeftStopNum = 0
                end

                local SpecialID = nil
                local nextPos = ccp(r1,c2-1)
                SpecialID, theAction.LeftStopNum, theAction.LeftStop, theAction.LeftSpecialID = JamSperadSpecialIDCheck( 
                    mainLogic, 
                    ccp(r1,c2), 
                    nextPos,
                    theAction.LeftStop, 
                    theAction.LeftStopNum, 
                    theAction.LeftSpecialID )

				if not DestructionPlanLogic:existInSpecialBombLightUpPos(mainLogic, r1, c2, theAction.lightUpBombMatchPosList) then
					SpecialCoverLogic:SpecialCoverLightUpAtPos(mainLogic, r1, c2, scoreScale)
				end
				local s1 = BombItemLogic:tryCoverByBomb(mainLogic, r1, c2, false, scoreScale)  		----左边

				SpecialCoverLogic:SpecialCoverAtPos(mainLogic, r1, c2, 1, scoreScale, actid, nil,nil,nil,SpecialID)

				if mainLogic:isPosValid(r1, c2) then 
					GameExtandPlayLogic:doABlocker211Collect(mainLogic, r1, c1, r1, c2, item._encrypt.ItemColorType, true, 3)
				end
				if s1 == 2 then   ----遇到银币
					SpecialCoverLogic:specialCoverChainsAtPos(mainLogic, r1, c2, {ChainDirConfig.kRight})
					ObstacleFootprintManager:addBlockEffectRecord(mainLogic.gameItemMap[r1][c2])
					if theAction.addInfo == "" then
						theAction.addInfo = "left"			----左部终止
					elseif theAction.addInfo == "right" then
						theAction.addInfo = "over"			----全部终止
						return
					end
				else
					SpecialCoverLogic:specialCoverChainsAtPos(mainLogic, r1, c2, {ChainDirConfig.kLeft, ChainDirConfig.kRight})
				end
			end
		end

		if theAction.addInfo ~= "right" then
			if c1 ~= c3 and mainLogic:isPosValid(r1, c3) and mainLogic.gameItemMap[r1][c3].dataReach then

                local CurBoard = mainLogic.boardmap[r1][c3]
                if CurBoard.isJamSperad and theAction.RightStop then
                    theAction.RightStop = false
                    theAction.RightStopNum = 0
                end

                local SpecialID = nil
                local nextPos = ccp(r1,c3+1)
                SpecialID, theAction.RightStopNum, theAction.RightStop, theAction.RightSpecialID = JamSperadSpecialIDCheck( 
                    mainLogic, 
                    ccp(r1,c3), 
                    nextPos,
                    theAction.RightStop, 
                    theAction.RightStopNum, 
                    theAction.RightSpecialID )

				if not DestructionPlanLogic:existInSpecialBombLightUpPos(mainLogic, r1, c3, theAction.lightUpBombMatchPosList) then
					SpecialCoverLogic:SpecialCoverLightUpAtPos(mainLogic, r1, c3, scoreScale)
				end
				local s2 = BombItemLogic:tryCoverByBomb(mainLogic, r1, c3, false, scoreScale) 			----右边
				SpecialCoverLogic:SpecialCoverAtPos(mainLogic, r1, c3, 1, scoreScale, actid, nil,nil,nil,SpecialID)
				if mainLogic:isPosValid(r1, c3) then 
					GameExtandPlayLogic:doABlocker211Collect(mainLogic, r1, c1, r1, c3, item._encrypt.ItemColorType, true, 3)
				end
				if s2 == 2 then 
					SpecialCoverLogic:specialCoverChainsAtPos(mainLogic, r1, c3, {ChainDirConfig.kLeft})
					ObstacleFootprintManager:addBlockEffectRecord(mainLogic.gameItemMap[r1][c3])
					if theAction.addInfo == "" then
						theAction.addInfo = "right"
					elseif theAction.addInfo == "left" then
						theAction.addInfo = "over"
						return
					end
				else
					SpecialCoverLogic:specialCoverChainsAtPos(mainLogic, r1, c3, {ChainDirConfig.kLeft, ChainDirConfig.kRight})
				end
			end
		end

		theAction.extendOffset = offset
		offset = offset + 1
	end
	-- if _G.isLocalDevelopMode then printx(0, output) end
end

----直线（竖排）消除特效执行中逻辑
function DestructionPlanLogic:runingGameItemSpecialBombColumnAction(mainLogic, theAction, actid)
	if theAction.addInfo == "over" then
		return 
	end
	----执行一次就over----
	local r1 = theAction.ItemPos1.x
	local c1 = theAction.ItemPos1.y
	local scoreScale = theAction.addInt2
	local item = mainLogic.gameItemMap[r1][c1]

    if not theAction.SpecialID then
        theAction.SpecialID = mainLogic:addSrcSpecialCoverToList( theAction.ItemPos1 )

        local bUpCanStop = mainLogic:CheckPosCanStopJamSperad( IntCoord:create(theAction.ItemPos1.x,theAction.ItemPos1.y),
            IntCoord:create(theAction.ItemPos1.x-1,theAction.ItemPos1.y) )
        local bDownCanStop = mainLogic:CheckPosCanStopJamSperad( IntCoord:create(theAction.ItemPos1.x,theAction.ItemPos1.y),
            IntCoord:create(theAction.ItemPos1.x+1,theAction.ItemPos1.y) )

        if bUpCanStop then theAction.upSpecialID = nil else theAction.upSpecialID = theAction.SpecialID end
        if bDownCanStop then theAction.downSpecialID = nil else theAction.downSpecialID = theAction.SpecialID end

        theAction.upStop = false
        theAction.downStop = false
        theAction.upStopNum = 0
        theAction.downStopNum = 0
    end

	theAction.addInfo = "over"
	theAction.lightUpBombMatchPosList = item.lightUpBombMatchPosList

	if item.ItemStatus == GameItemStatusType.kWaitBomb then item:AddItemStatus( GameItemStatusType.kNone , true ) end
	if not DestructionPlanLogic:existInSpecialBombLightUpPos(mainLogic, r1, c1, theAction.lightUpBombMatchPosList) then
		SpecialCoverLogic:SpecialCoverLightUpAtPos(mainLogic, r1, c1, 2)
	end
	BombItemLogic:tryCoverByBomb(mainLogic, r1, c1, true, 0, true)----加过分数的---
	SpecialCoverLogic:SpecialCoverAtPos(mainLogic, r1, c1, 2, nil, actid, nil,nil,nil,theAction.SpecialID) ----原点---
	SpecialCoverLogic:specialCoverChainsAtPos(mainLogic, r1, c1, {ChainDirConfig.kUp, ChainDirConfig.kDown})

	for i=r1 + 1, #mainLogic.gameItemMap do

        local CurBoard = mainLogic.boardmap[i][c1]
        if CurBoard.isJamSperad and theAction.downStop then
            theAction.downStop = false
            theAction.downStopNum = 0
        end

        local SpecialID = nil
        local nextPos = ccp(i+1,c1)
        SpecialID, theAction.downStopNum, theAction.downStop, theAction.downSpecialID = JamSperadSpecialIDCheck( 
            mainLogic, 
            ccp(i,c1), 
            nextPos,
            theAction.downStop, 
            theAction.downStopNum, 
            theAction.downSpecialID )

		if not DestructionPlanLogic:existInSpecialBombLightUpPos(mainLogic, i, c1, theAction.lightUpBombMatchPosList) then
			SpecialCoverLogic:SpecialCoverLightUpAtPos(mainLogic, i, c1, scoreScale)
		end
		local s1 = BombItemLogic:tryCoverByBomb(mainLogic, i, c1, true, scoreScale, true) 		----空中的也炸掉
		SpecialCoverLogic:SpecialCoverAtPos(mainLogic, i, c1, 2, scoreScale, actid, nil,nil,nil,SpecialID)
		if mainLogic:isPosValid(i, c1) then 
			GameExtandPlayLogic:doABlocker211Collect(mainLogic, r1, c1, i, c1, item._encrypt.ItemColorType, true, 3)
		end
		if s1 == 2 then 
			SpecialCoverLogic:specialCoverChainsAtPos(mainLogic, i, c1, {ChainDirConfig.kUp})
			ObstacleFootprintManager:addBlockEffectRecord(mainLogic.gameItemMap[i][c1])
			break 
		else
			SpecialCoverLogic:specialCoverChainsAtPos(mainLogic, i, c1, {ChainDirConfig.kUp, ChainDirConfig.kDown})
		end----遇到银币
	end

	for i=r1 - 1, 1, -1 do
        
        local CurBoard = mainLogic.boardmap[i][c1]
        if CurBoard.isJamSperad and theAction.upStop then
            theAction.upStop = false
            theAction.upStopNum = 0
        end

        local SpecialID = nil
        local nextPos = ccp(i-1,c1)
        SpecialID, theAction.upStopNum, theAction.upStop, theAction.upSpecialID = JamSperadSpecialIDCheck( 
            mainLogic, 
            ccp(i,c1), 
            nextPos,
            theAction.upStop, 
            theAction.upStopNum, 
            theAction.upSpecialID )

		if not DestructionPlanLogic:existInSpecialBombLightUpPos(mainLogic, i, c1, theAction.lightUpBombMatchPosList) then
			SpecialCoverLogic:SpecialCoverLightUpAtPos(mainLogic, i, c1, scoreScale)
		end
		local s1 = BombItemLogic:tryCoverByBomb(mainLogic, i, c1, true, scoreScale, true) 		----空中的也炸掉
		SpecialCoverLogic:SpecialCoverAtPos(mainLogic, i, c1, 2, scoreScale, actid, nil,nil,nil,SpecialID )
		if mainLogic:isPosValid(i, c1) then 
			GameExtandPlayLogic:doABlocker211Collect(mainLogic, r1, c1, i, c1, item._encrypt.ItemColorType, true, 3)
		end
		if s1 == 2 then 
			SpecialCoverLogic:specialCoverChainsAtPos(mainLogic, i, c1, {ChainDirConfig.kDown})
			ObstacleFootprintManager:addBlockEffectRecord(mainLogic.gameItemMap[i][c1])
			break 
		else
			SpecialCoverLogic:specialCoverChainsAtPos(mainLogic, i, c1, {ChainDirConfig.kUp, ChainDirConfig.kDown})
		end----遇到银币
	end
end

function DestructionPlanLogic:runingGameItemSpecialBombWrapAction(mainLogic, theAction, actid)
	local function getRectBombPos(length, r, c)
		local result = {}
		local rowOffset = r - math.floor(length / 2) - 1
		local colOffset = c - math.floor(length / 2)

		for i = 1, length do
			for j = math.abs(i - 1 - math.floor(length / 2)), length - 1 - math.abs(i - 1 - math.floor(length / 2)) do
				local p = { c = j + colOffset, r = i + rowOffset }
				table.insert(result, p)
			end
		end

		return result
	end

	if theAction.addInfo == "over" then
		return 
	end

	----执行一次就over----
	local r1 = theAction.ItemPos1.x
	local c1 = theAction.ItemPos1.y
	local item = mainLogic.gameItemMap[r1][c1]
	local scoreScale = theAction.addInt2
	theAction.addInfo = "over"
	theAction.lightUpBombMatchPosList = item.lightUpBombMatchPosList

    local SpecialID = mainLogic:addSrcSpecialCoverToList( theAction.ItemPos1 )

	if item.ItemStatus == GameItemStatusType.kWaitBomb then 
		item:AddItemStatus( GameItemStatusType.kNone , true ) 
	end

	local bombPosList = getRectBombPos(5, r1, c1)

	local centerR = r1
	local centerC = c1
	for k,v in ipairs(bombPosList) do
		if mainLogic:isPosValid(v.r, v.c) then
			if mainLogic.boardmap[v.r][v.c].isUsed then
				local itemView = mainLogic.boardView.baseMap[v.r][v.c]
				itemView:playMixTileHighlightEffect()
			end
			if mainLogic.gameItemMap[v.r][v.c].dataReach then
			if not DestructionPlanLogic:existInSpecialBombLightUpPos(mainLogic, v.r, v.c, theAction.lightUpBombMatchPosList) then
				SpecialCoverLogic:SpecialCoverLightUpAtPos(mainLogic, v.r, v.c, scoreScale)
			end
			if v.r == r1 and v.c == c1 then
				BombItemLogic:tryCoverByBomb(mainLogic, v.r, v.c, true, 0, true)
			else
				BombItemLogic:tryCoverByBomb(mainLogic, v.r, v.c, true, scoreScale)
				GameExtandPlayLogic:doABlocker211Collect(mainLogic, r1, c1, v.r, v.c, item._encrypt.ItemColorType, true, 3)
			end
			SpecialCoverLogic:SpecialCoverAtPos(mainLogic, v.r, v.c, 3, scoreScale, actid, nil,nil,nil,SpecialID)
			local breakDirs = DestructionPlanLogic:calcBreakChainDirsAtPos(v.r, v.c, centerR, centerC, 2)
			SpecialCoverLogic:specialCoverChainsAtPos(mainLogic, v.r, v.c, breakDirs)
		end
	end
	end
end

--------鸟和某个颜色动物交换引起的爆炸
function DestructionPlanLogic:runingGameItemSpecialBombColorAction(mainLogic, theAction, actid)
	local r1 = theAction.ItemPos1.x
	local c1 = theAction.ItemPos1.y
	local item1 = mainLogic.gameItemMap[r1][c1]

    local SpecialID = mainLogic:addSrcSpecialCoverToList( theAction.ItemPos1, theAction.ItemPos2 )

	if theAction.addInfo == "" or theAction.addInfo == "Pass" then
		theAction.addInfo = "start"
		-----进入开始阶段----鸟消失动画-------------按照特效消除的方式消失而不是Match
		----1.分数
		if item1.ItemStatus == GameItemStatusType.kWaitBomb then item1:AddItemStatus( GameItemStatusType.kNone , true ) end
		local addScore = GamePlayConfigScore.SwapColorAnimal
		mainLogic:addScoreToTotal(r1, c1, addScore)

		-----2.动画
		item1:AddItemStatus(GameItemStatusType.kDestroy)
		local CoverAction =	GameBoardActionDataSet:createAs(
			GameActionTargetType.kGameItemAction,
			GameItemActionType.kItemCoverBySpecial_Color,
			IntCoord:create(r1,c1),
			nil,
			GamePlayConfig_SpecialBomb_BirdAnimal_Time1)
		CoverAction.addInfo = "kAnimal"
		mainLogic:addDestroyAction(CoverAction)
		mainLogic.gameItemMap[r1][c1].gotoPos = nil
		mainLogic.gameItemMap[r1][c1].comePos = nil
		mainLogic.gameItemMap[r1][c1].isEmpty = false

		local scoreScale = theAction.addInt2

		----特效影响-----
		local color = theAction.addInt
		if color == 0 then
			color = mainLogic:getBirdEliminateColor()
			theAction.addInt = color
		end
		GameExtandPlayLogic:changeAllTotemsToWattingActiveWithColor(mainLogic, color, scoreScale)

		SpecialCoverLogic:SpecialCoverLightUpAtPos(mainLogic, r1, c1, scoreScale)
		SpecialCoverLogic:SpecialCoverAtPos(mainLogic, r1, c1, 3, nil, actid, nil,nil,nil,SpecialID)
		SnailLogic:SpecialCoverSnailRoadAtPos( mainLogic, r1, c1 )
		return
	elseif theAction.addInfo == "start" then
		theAction.addInfo = "waiting"
		-----进入等待阶段----鸟正在播放动画-----
		mainLogic:tryBombSuperTotems()--隔一帧激活
		return
	elseif theAction.addInfo == "waiting" then
		-----等待鸟动画完毕，进入爆炸阶段-----
		if theAction.actionDuring <= GamePlayConfig_SpecialBomb_BirdAnimal_Time3 then
			theAction.addInfo = "shake"

			local color = theAction.addInt
			local posList = mainLogic:getPosListOfColor(color)
			for k,v in pairs(posList) do
				local itemBomb = mainLogic.gameItemMap[v.x][v.y]
				if itemBomb:canBeCoverByBirdAnimal() 
					and itemBomb.ItemType == GameItemType.kAnimal
					and itemBomb.ItemSpecialType == 0 
					and not itemBomb:hasFurball() 
					and not itemBomb:hasLock() 
					and (
						itemBomb.ItemStatus == GameItemStatusType.kItemHalfStable 
						or itemBomb.ItemStatus == GameItemStatusType.kNone
						or itemBomb.ItemStatus == GameItemStatusType.kJustArrived
						) 
					then
					local ShakeAction = GameBoardActionDataSet:createAs(
						GameActionTargetType.kGameItemAction,
						GameItemActionType.kItemShakeBySpecialColor,
						IntCoord:create(v.x, v.y),
						nil,
						GamePlayConfig_SpecialBomb_BirdAnimal_Shake_Time)
					ShakeAction.theItemColor = color
					mainLogic:addGameAction(ShakeAction)
				end
			end
		end
	elseif theAction.addInfo == "shake" then
		if theAction.actionDuring <= GamePlayConfig_SpecialBomb_BirdAnimal_Time2 then
			theAction.addInfo = "bomb"
		end
	elseif theAction.addInfo == "bomb" then
		-----等着结束的阶段-----
		theAction.addInfo = "nothing"
	end

	if theAction.addInfo == "nothing" and theAction.actionDuring == 1 then ----最后一帧
		theAction.addInfo = "Over"
	end

	if theAction.addInfo == "bomb" then
		local color = theAction.addInt
		if color == 0 then
			color = mainLogic:getBirdEliminateColor()
		end
		----被引爆---
		local posList = mainLogic:getPosListOfColor(color)
		for k,v in pairs(posList) do
			local itemBomb = mainLogic.gameItemMap[v.x][v.y]
			if itemBomb:canBeCoverByBirdAnimal() then 			----可以被消除的东西
				local scoreScale = theAction.addInt2
				SpecialCoverLogic:SpecialCoverLightUpAtPos(mainLogic, v.x, v.y, scoreScale)
				BombItemLogic:tryCoverByBird(mainLogic, v.x, v.y, r1, c1, scoreScale)
				SpecialCoverLogic:SpecialCoverAtPos(mainLogic, v.x, v.y, 3, scoreScale, actid, nil,nil,nil,SpecialID) 	----被鸟引爆----
			elseif itemBomb.beEffectByMimosa == GameItemType.kKindMimosa then
				GameExtandPlayLogic:backMimosaToRC(mainLogic, v.x, v.y)
			elseif itemBomb.ItemType == GameItemType.kTotems then--闪电鸟集中引爆的时候没有处理附着在上面的障碍
				SpecialCoverLogic:SpecialCoverAtPos(mainLogic, v.x, v.y, 3, scoreScale, actid, nil,nil,nil,SpecialID)
			end
		end
	end
end

----鸟和直线特效交换----
function DestructionPlanLogic:runingGameItemSpecialBombColorLineAction(mainLogic, theAction, actid, sptype)
	local r1 = theAction.ItemPos1.x
	local c1 = theAction.ItemPos1.y
	local r2 = theAction.ItemPos2.x
	local c2 = theAction.ItemPos2.y
	local item1 = mainLogic.gameItemMap[r1][c1] 		----魔力鸟
	local item2 = mainLogic.gameItemMap[r2][c2]		----直线特效
	local color = theAction.addInt
	local scoreScale = theAction.addInt2

	local SpecialID = mainLogic:addSrcSpecialCoverToList( theAction.ItemPos1, theAction.ItemPos2 )

	if theAction.addInfo == "" or theAction.addInfo == "Pass" then
		theAction.addInfo = "start"

		local addTime = 0
		if GameGuide and GameGuide:sharedInstance().pauseBoardUpdateForBirdLine == true and not theAction.isGuidePlayed then
			GameGuide:sharedInstance().pauseBoardUpdateForBirdLine = false

			theAction.playGuide = true
			addTime = GamePlayConfig_Action_FPS * (GameGuide:sharedInstance().pauseTime or 3)

		end


		-----进入开始阶段----鸟消失动画-------------按照特效消除的方式消失而不是Match
		----1.1分数
		local sp2 = item2.ItemSpecialType
		local addScore = GamePlayConfigScore.SwapColorLine
		if sp2 == AnimalTypeConfig.kWrap then addScore = GamePlayConfigScore.SwapColorWrap end
		if item1.ItemType == GameItemType.kBlocker195 then addScore = GamePlayConfigScore.SwapBlocker195 end
		mainLogic:addScoreToTotal(r1, c1, addScore)
		
		----1.2动画效果
		item1:AddItemStatus(GameItemStatusType.kDestroy)
		local action 
		if item1.ItemType == GameItemType.kBlocker195 then
			action = GameBoardActionDataSet:createAs(
				GameActionTargetType.kGameItemAction,
				GameItemActionType.kItem_Blocker195_Dec,
				IntCoord:create(r1,c1),
				nil,
				GamePlayConfig_Blcoker195_Destroy_Time)
		else
			action = GameBoardActionDataSet:createAs(
				GameActionTargetType.kGameItemAction,
				GameItemActionType.kItemCoverBySpecial_Color,
				IntCoord:create(r1,c1),
				nil,
				GamePlayConfig_SpecialBomb_BirdLine_Time2 + GamePlayConfig_SpecialBomb_BirdLine_Time4 + addTime)
			action.addInfo = "kAnimal"
			action.specialMatchType = SpecialMatchType.kColorLine
		end
		mainLogic:addDestroyAction(action)
		mainLogic.gameItemMap[r1][c1].gotoPos = nil
		mainLogic.gameItemMap[r1][c1].comePos = nil
		GameExtandPlayLogic:changeAllTotemsToWattingActiveWithColor(mainLogic, color, scoreScale)
		SpecialCoverLogic:SpecialCoverLightUpAtPos(mainLogic, r1, c1, 3)
		return
	elseif theAction.addInfo == "start" then
		theAction.addInfo = "waiting1" 		----第一次等待
		mainLogic:tryBombSuperTotems()--隔一帧激活
	elseif theAction.addInfo == "waiting1" then
		if theAction.actionDuring == GamePlayConfig_SpecialBomb_BirdLine_Time1 - GamePlayConfig_SpecialBomb_BirdLine_Time2 then
			------开始飞行------
			theAction.addInfo = "flyingBird"
            ------鸟底板添加果酱
            local mathBoard2 = mainLogic.boardmap[r2][c2]
		    if mathBoard2.isJamSperad then
			    GameExtandPlayLogic:addJamSperadFlag(mainLogic, r1, c1 )
		    end

			------飞行及标记------
			BombItemLogic:setSignOfBombResWithBirdFlying(mainLogic, r1, c1, color, sptype, SpecialID) ----全部变成直线特效----(区域)
			item2.bombRes = IntCoord:create(r1, c1)
		end
	elseif theAction.addInfo == "flyingBird" then
		theAction.addInfo = "waiting2"			----飞行等待
	elseif theAction.addInfo == "waiting2" then
		if theAction.actionDuring == GamePlayConfig_SpecialBomb_BirdLine_Time1 - GamePlayConfig_SpecialBomb_BirdLine_Time4 then
			------进入引爆时间-----
			if theAction.playGuide == true then

				local baseMap = mainLogic.boardView.baseMap
				local gameItemMap = mainLogic.gameItemMap
				local layer = LayerColor:create()
				local size = Director:sharedDirector():getWinSize()
				layer:setContentSize(size)
				layer:setOpacity(180)
				local scene = Director:sharedDirector():getRunningScene()
				scene:addChild(layer)
				theAction.layer = layer
				local scale = mainLogic.boardView:getScale() or 1
				for r = 1, #gameItemMap do
					for c = 1, #gameItemMap[r] do
						local item = gameItemMap[r][c]
						if item.bombRes and item.bombRes.x == r1 and item.bombRes.y == c1 then
							local animal
							if item._encrypt.ItemColorType == AnimalTypeConfig.kBlue then
								animal = 'horse'
							elseif item._encrypt.ItemColorType == AnimalTypeConfig.kRed then
								animal = 'fox'
							elseif item._encrypt.ItemColorType == AnimalTypeConfig.kPurple then
								animal = 'cat'
							elseif item._encrypt.ItemColorType == AnimalTypeConfig.kBrown then
								animal = 'bear'
							elseif item._encrypt.ItemColorType == AnimalTypeConfig.kYellow then
								animal = 'chicken'
							elseif item._encrypt.ItemColorType == AnimalTypeConfig.kGreen then
								animal = 'frog'
							end
							local sprite
							if item.ItemSpecialType == AnimalTypeConfig.kLine then
								sprite = TileCharacter:create(animal)
								sprite:play(kTileCharacterAnimation.kLineRow)
							elseif item.ItemSpecialType == AnimalTypeConfig.kColumn then
								sprite = TileCharacter:create(animal)
								sprite:play(kTileCharacterAnimation.kLineColumn)
							end
							layer:addChild(sprite)
							sprite:setScale(scale)
							sprite:setPosition(layer:convertToNodeSpace(mainLogic:getGameItemPosInView(r, c)))
						end
					end
				end

				theAction.addInfo = 'guideWaiting'
				theAction.guideWaitingTime = GamePlayConfig_Action_FPS * (GameGuide:sharedInstance().pauseTime or 3)
			else
				theAction.addInfo = "BombTime"
			end
		end
	elseif theAction.addInfo == 'guideWaiting' then
		theAction.guideWaitingTime = theAction.guideWaitingTime - 1

		if theAction.guideWaitingTime < 0 then
			if theAction.layer and not theAction.layer.isDisposed then
				theAction.layer = theAction.layer:removeFromParentAndCleanup(true)
				theAction.layer = nil
			end

			theAction.addInfo = "BombTime"
		end

	elseif theAction.addInfo == "BombTime" then

		----挨个引爆----直到没有可以引爆的为止，进入结束状态-----
		local xtime = GamePlayConfig_SpecialBomb_BirdLine_Time1 - theAction.actionDuring - GamePlayConfig_SpecialBomb_BirdLine_Time4 		----已经经过的时间
		if xtime > 0 and xtime % math.ceil(GamePlayConfig_SpecialBomb_BirdLine_Time5) == 0 then ----每隔一段时间
			if (BombItemLogic:tryBombWithBombRes(mainLogic, r1, c1, 1, scoreScale)) then
				----引爆某一个
			else
				----失败了----没有可以引爆的了，----爆炸结束----
				theAction.addInfo = "Over"
			end
		end
	elseif theAction.addInfo == "Over" then
		mainLogic.destructionPlanList[actid] = nil	----删除动作------目标驱动类的动作----
	end
end

----鸟和直线特效交换----鸟向四处飞----
function DestructionPlanLogic:runingGameItemSpecialBombColorLineAction_flying(mainLogic, theAction, actid, sptype)
	local r1 = theAction.ItemPos1.x
	local c1 = theAction.ItemPos1.y
	local r2 = theAction.ItemPos2.x
	local c2 = theAction.ItemPos2.y
	local color = theAction.addInt

	local item1 = mainLogic.gameItemMap[r1][c1] 		----消除动物
	local item2 = mainLogic.gameItemMap[r2][c2] 		----魔力鸟来源

	if theAction.addInfo == "changeItem" then  		----结束----
		if item1:canBecomeSpecialBySwapColorSpecial() and item1._encrypt.ItemColorType == theAction.swapColor then
			if (sptype == AnimalTypeConfig.kLine or sptype == AnimalTypeConfig.kColumn) then
				local lineColumnRandList = {AnimalTypeConfig.kLine, AnimalTypeConfig.kColumn}
				local resultSpecialType = lineColumnRandList[mainLogic.randFactory:rand(1, 2)]
				GameExtandPlayLogic:itemDestroyHandler(mainLogic, r1, c1)
				item1.ItemType = GameItemType.kAnimal
				item1.ItemSpecialType = resultSpecialType
				item1.isNeedUpdate = true
			elseif (sptype == AnimalTypeConfig.kWrap) then
				GameExtandPlayLogic:itemDestroyHandler(mainLogic, r1, c1)
				item1.ItemType = GameItemType.kAnimal
				item1.ItemSpecialType = AnimalTypeConfig.kWrap
				item1.isNeedUpdate = true
			end
		end

		local mathBoard2 = mainLogic.boardmap[r2][c2]
		if mathBoard2.isJamSperad then
			GameExtandPlayLogic:addJamSperadFlag(mainLogic, r1, c1 )
		end
		
		theAction.addInfo = "Over"
	end
end

-- ----鸟鸟交换----
--[[
function DestructionPlanLogic:runingGameItemSpecialBombColorColorAction(mainLogic, theAction, actid)
	local function getSpecialBombPosList()
		local result = {}
		for r = 1, #mainLogic.gameItemMap do
			for c = 1, #mainLogic.gameItemMap[r] do
				if (BombItemLogic:canBeBombByBirdBird(mainLogic, r, c)) 
					and (r1 ~= r or c1 ~= c) and (r2 ~= r or c2 ~= c) 
					then
					table.insert(result, mainLogic:getGameItemPosInView(r, c))
				end
			end
		end
		return result
	end

	local r1 = theAction.ItemPos1.x
	local c1 = theAction.ItemPos1.y
	local r2 = theAction.ItemPos2.x
	local c2 = theAction.ItemPos2.y

	local item1 = mainLogic.gameItemMap[r1][c1] 		----鸟1
	local item2 = mainLogic.gameItemMap[r2][c2] 		----鸟2
	local scoreScale = theAction.addInt2

	if theAction.addInfo == "" or theAction.addInfo == "Pass" then
		theAction.addInfo = "start"
		-----进入开始阶段----鸟消失动画-------------按照特效消除的方式消失而不是Match
		----1.分数
		local addScore = GamePlayConfigScore.SwapColorColor
		if item1.ItemType == GameItemType.kBlocker195 or item2.ItemType == GameItemType.kBlocker195 then
			addScore = GamePlayConfigScore.SwapSuperBlocker195
		end
		mainLogic:addScoreToTotal(r1, c1, addScore)

		-----2.动画
		local function destroyCallback(item, r1, c1, r2, c2)
			local function getGameBoardAction(actionType, time)
				local action = GameBoardActionDataSet:createAs(
					GameActionTargetType.kGameItemAction,
					actionType,
					IntCoord:create(r1,c1),
					IntCoord:create(r2,c2),
					time)
				return action
			end

			item:AddItemStatus(GameItemStatusType.kDestroy)
			local action = nil
			if item.ItemSpecialType == AnimalTypeConfig.kColor then
				action = getGameBoardAction(GameItemActionType.kItemCoverBySpecial_Color, GamePlayConfig_SpecialBomb_BirdBird_Time2)
				action.addInfo = "kAnimal"
				action.specialMatchType = SpecialMatchType.kColorColor
				action.isMasterBird = true
				SpecialCoverLogic:SpecialCoverLightUpAtPos(mainLogic, r1, c1, 3)
				SnailLogic:SpecialCoverSnailRoadAtPos(mainLogic, r1, c1 )
			elseif item.ItemType == GameItemType.kBlocker195 then
				action = getGameBoardAction(GameItemActionType.kItem_Blocker195_Dec, GamePlayConfig_Blcoker195_Destroy_Time)
			elseif item.ItemType == GameItemType.kCrystalStone then
				action = getGameBoardAction(GameItemActionType.kItemSpecial_CrystalStone_Destroy, GamePlayConfig_SpecialBomb_CrystalStone_Destory_Time1)
				action.addInt = item._encrypt.ItemColorType
				action.isSpecial = true
			end
			mainLogic:addDestroyAction(action)
			item.gotoPos = nil
			item.comePos = nil
		end

		destroyCallback(item1, r1, c1, r2, c2)
		destroyCallback(item2, r2, c2, r1, c1)
		GamePlayMusicPlayer:playEffect(GameMusicType.kSwapColorColorSwap)

		return
	elseif theAction.addInfo == "start" then
		theAction.addInfo = "waiting1"
		theAction.addInt = 1
	elseif theAction.addInfo == "waiting1" then
		--------第一次等待-------
		if mainLogic:isItemAllStable()
			and mainLogic:numDestrunctionPlan() == 1 
			then
			------停止掉落了-----
			----进入下一个阶段----
			theAction.addInfo = "BombAll"
			theAction.bombList = getSpecialBombPosList()
			theAction.addInt = 1
		else
			theAction.addInt = 1----重新计时----
		end
	elseif theAction.addInfo == "BombAll" then
		if theAction.addInt >= GamePlayConfig_SpecialBomb_BirdBird_Time3 then
			theAction.addInfo = "waiting2"
			BombItemLogic:BombAll(mainLogic)--------引爆所有特效
			theAction.addInt = 1
		end
		theAction.addInt = theAction.addInt + 1
	elseif theAction.addInfo == "waiting2" then
		--------第二次等待-------
		if mainLogic:isItemAllStable()
			and mainLogic:numDestrunctionPlan() == 1 
			then
			theAction.addInfo = "shake"
		else
			theAction.addInt = 1----重新计时----
		end
	elseif theAction.addInfo == "shake" then
		if theAction.addInt == 1 then
			for r = 1, #mainLogic.gameItemMap do
				for c = 1, #mainLogic.gameItemMap[r] do
					local item = mainLogic.gameItemMap[r][c]
					if item:isItemCanBeEliminateByBirdBird() then
						local ShakeAction = GameBoardActionDataSet:createAs(
							GameActionTargetType.kGameItemAction,
							GameItemActionType.kItemShakeBySpecialColor,
							IntCoord:create(r, c),
							nil,
							GamePlayConfig_SpecialBomb_BirdBird_Time4)
						mainLogic:addGameAction(ShakeAction)
					end
				end
			end

		end

		theAction.addInt = theAction.addInt + 1
		if (theAction.addInt >= GamePlayConfig_SpecialBomb_BirdBird_Time4) then
			----进入下一个阶段----
			theAction.addInfo = "CleanAll"
			theAction.addInt = 0
		end
	elseif theAction.addInfo == "CleanAll" then
		theAction.addInt = theAction.addInt + 1
		if theAction.addInt >= 1 then
			local birdBirdPos = { r = theAction.ItemPos1.x, c = theAction.ItemPos1.y }
			local collectPos = IntCoord:create((r1 + r2)/2, (c1+c2)/2)
	 		BombItemLogic:tryCoverByBirdBird(mainLogic, birdBirdPos, 1, scoreScale, collectPos)
			theAction.addInfo = "waiting3"

			GamePlayMusicPlayer:playEffect(GameMusicType.kSwapColorColorCleanAll)
		end
	elseif theAction.addInfo == "waiting3" then
		theAction.addInt = theAction.addInt + 1
		if (theAction.addInt >= GamePlayConfig_SpecialBomb_BirdBird_Time5) then
			----进入下一个阶段----
			theAction.addInfo = "Over"
		end
	elseif theAction.addInfo == "Over" then
		mainLogic.destructionPlanList[actid] = nil
	end
end
]]

----鸟鸟交换拆分版：Part1  鸟自身消除  ----
function DestructionPlanLogic:runingGameItemSpecialBombColorColorPart1Action(mainLogic, theAction, actid)

	local r1 = theAction.ItemPos1.x
	local c1 = theAction.ItemPos1.y
	local r2 = theAction.ItemPos2.x
	local c2 = theAction.ItemPos2.y

	local item1 = mainLogic.gameItemMap[r1][c1] 		----鸟1
	local item2 = mainLogic.gameItemMap[r2][c2] 		----鸟2

	if theAction.addInfo == "" or theAction.addInfo == "Pass" then
		theAction.addInfo = "start"
		-----进入开始阶段----鸟消失动画-------------按照特效消除的方式消失而不是Match
		----1.分数
		local addScore = GamePlayConfigScore.SwapColorColor
		if item1.ItemType == GameItemType.kBlocker195 or item2.ItemType == GameItemType.kBlocker195 then
			addScore = GamePlayConfigScore.SwapSuperBlocker195
			ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_Blocker195, ObstacleFootprintAction.k_HugeAttack, 1)
		end
		mainLogic:addScoreToTotal(r1, c1, addScore)

		-----2.动画
		local function destroyCallback(item, r1, c1, r2, c2)
			local function getGameBoardAction(actionType, time)
				local action = GameBoardActionDataSet:createAs(
					GameActionTargetType.kGameItemAction,
					actionType,
					IntCoord:create(r1,c1),
					IntCoord:create(r2,c2),
					time)
				return action
			end

			item:AddItemStatus(GameItemStatusType.kDestroy)
			local action = nil
			if item.ItemSpecialType == AnimalTypeConfig.kColor then
				action = getGameBoardAction(GameItemActionType.kItemCoverBySpecial_Color, GamePlayConfig_SpecialBomb_BirdBird_Time2)
				action.addInfo = "kAnimal"
				action.specialMatchType = SpecialMatchType.kColorColor
				action.isMasterBird = true
				SpecialCoverLogic:SpecialCoverLightUpAtPos(mainLogic, r1, c1, 3)
				SnailLogic:SpecialCoverSnailRoadAtPos(mainLogic, r1, c1 )
			elseif item.ItemType == GameItemType.kBlocker195 then
				action = getGameBoardAction(GameItemActionType.kItem_Blocker195_Dec, GamePlayConfig_Blcoker195_Destroy_Time)
			elseif item.ItemType == GameItemType.kCrystalStone then
				action = getGameBoardAction(GameItemActionType.kItemSpecial_CrystalStone_Destroy, GamePlayConfig_SpecialBomb_CrystalStone_Destory_Time1)
				action.addInt = item._encrypt.ItemColorType
				action.isSpecial = true
			end
			mainLogic:addDestroyAction(action)
			item.gotoPos = nil
			item.comePos = nil
		end

		destroyCallback(item1, r1, c1, r2, c2)
		destroyCallback(item2, r2, c2, r1, c1)
		GamePlayMusicPlayer:playEffect(GameMusicType.kSwapColorColorSwap)

		return
	elseif theAction.addInfo == "start" then
		theAction.addInfo = "Over"
		theAction.addInt = 1

		local part2Action = GameBoardActionDataSet:createAs(
				GameActionTargetType.kGameItemAction,
				GameItemActionType.kItemSpecial_ColorColor_part2,
				IntCoord:create(r1, c1),
				IntCoord:create(r2, c2),
				GamePlayConfig_SpecialBomb_BirdBird_Time1
				)
			part2Action.addInt = theAction.addInt ----现在是计时器
			part2Action.addInt2 = theAction.addInt2
			mainLogic:addStableDestructionPlanAction(part2Action)
	elseif theAction.addInfo == "Over" then
		mainLogic.destructionPlanList[actid] = nil
	end
end

----鸟鸟交换拆分版：Part2  棋盘特效消除  ----
function DestructionPlanLogic:runingGameItemSpecialBombColorColorPart2Action(mainLogic, theAction, actid)
	local function getSpecialBombPosList()
		local result = {}
		for r = 1, #mainLogic.gameItemMap do
			for c = 1, #mainLogic.gameItemMap[r] do
				if (BombItemLogic:canBeBombByBirdBird(mainLogic, r, c)) 
					and (r1 ~= r or c1 ~= c) and (r2 ~= r or c2 ~= c) 
					then
					table.insert(result, mainLogic:getGameItemPosInView(r, c))
				end
			end
		end
		return result
	end

	local r1 = theAction.ItemPos1.x
	local c1 = theAction.ItemPos1.y
	local r2 = theAction.ItemPos2.x
	local c2 = theAction.ItemPos2.y

	local SpecialID = mainLogic:addSrcSpecialCoverToList( theAction.ItemPos1, theAction.ItemPos2 )

	if theAction.addInfo == "" or theAction.addInfo == "Pass" then
		--------第一次等待-------
		if mainLogic:isItemAllStable()
			and mainLogic:numDestrunctionPlan() == 1 
			then
			------停止掉落了-----
			----进入下一个阶段----
			theAction.addInfo = "BombAll"
			theAction.bombList = getSpecialBombPosList()
			theAction.addInt = 1
		else
			theAction.addInt = 1----重新计时----
		end
	elseif theAction.addInfo == "BombAll" then
		if theAction.addInt >= GamePlayConfig_SpecialBomb_BirdBird_Time3 then
			theAction.addInfo = "Over"
			BombItemLogic:BombAll(mainLogic, SpecialID)--------引爆所有特效
			theAction.addInt = 1

			local part3Action = GameBoardActionDataSet:createAs(
				GameActionTargetType.kGameItemAction,
				GameItemActionType.kItemSpecial_ColorColor_part3,
				IntCoord:create(r1, c1),
				IntCoord:create(r2, c2),
				GamePlayConfig_SpecialBomb_BirdBird_Time1
				)
			part3Action.addInt = theAction.addInt ----现在是计时器
			part3Action.addInt2 = theAction.addInt2
			mainLogic:addStableDestructionPlanAction(part3Action)
		end
		theAction.addInt = theAction.addInt + 1
	elseif theAction.addInfo == "Over" then
		mainLogic.destructionPlanList[actid] = nil
	end
end

----鸟鸟交换拆分版：Part3  全屏消除  ----
function DestructionPlanLogic:runingGameItemSpecialBombColorColorPart3Action(mainLogic, theAction, actid)
	local r1 = theAction.ItemPos1.x
	local c1 = theAction.ItemPos1.y
	local r2 = theAction.ItemPos2.x
	local c2 = theAction.ItemPos2.y
	local scoreScale = theAction.addInt2

	if theAction.addInfo == "" or theAction.addInfo == "Pass" then
		--------第二次等待-------
		if mainLogic:isItemAllStable()
			and mainLogic:numDestrunctionPlan() == 1 
			then
			theAction.addInfo = "shake"
		else
			theAction.addInt = 1----重新计时----
		end
	elseif theAction.addInfo == "shake" then
		if theAction.addInt == 1 then
			for r = 1, #mainLogic.gameItemMap do
				for c = 1, #mainLogic.gameItemMap[r] do
					local item = mainLogic.gameItemMap[r][c]
					if item:isItemCanBeEliminateByBirdBird() then
						local ShakeAction = GameBoardActionDataSet:createAs(
							GameActionTargetType.kGameItemAction,
							GameItemActionType.kItemShakeBySpecialColor,
							IntCoord:create(r, c),
							nil,
							GamePlayConfig_SpecialBomb_BirdBird_Time4)
						mainLogic:addGameAction(ShakeAction)
					end
				end
			end
		end

		theAction.addInt = theAction.addInt + 1
		if (theAction.addInt >= GamePlayConfig_SpecialBomb_BirdBird_Time4) then
			----进入下一个阶段----
			theAction.addInfo = "CleanAll"
			theAction.addInt = 0
		end
	elseif theAction.addInfo == "CleanAll" then
		theAction.addInt = theAction.addInt + 1
		if theAction.addInt >= 1 then
			local birdBirdPos = { r = theAction.ItemPos1.x, c = theAction.ItemPos1.y }
			local birdBirdPos2 = { r = theAction.ItemPos2.x, c = theAction.ItemPos2.y }
			local collectPos = IntCoord:create((r1 + r2)/2, (c1+c2)/2)
	 		BombItemLogic:tryCoverByBirdBird(mainLogic, birdBirdPos, 1, scoreScale, collectPos, birdBirdPos2)
			theAction.addInfo = "waiting3"

			GamePlayMusicPlayer:playEffect(GameMusicType.kSwapColorColorCleanAll)
		end
	elseif theAction.addInfo == "waiting3" then
		theAction.addInt = theAction.addInt + 1
		if (theAction.addInt >= GamePlayConfig_SpecialBomb_BirdBird_Time5) then
			----进入下一个阶段----
			theAction.addInfo = "Over"
		end
	elseif theAction.addInfo == "Over" then
		mainLogic.destructionPlanList[actid] = nil
	end
end

function DestructionPlanLogic:runGameItemActionBombSpecialWrapLine(boardView, theAction)
	theAction.actionStatus = GameActionStatus.kRunning

	-- local position1 = DestructionPlanLogic:getItemPosition(theAction.ItemPos1)
	-- local position2 = DestructionPlanLogic:getItemPosition(theAction.ItemPos2)

	-- local effect = CommonEffect:buildWrapLineEffect(boardView.specialEffectBatch)
	-- effect:setPosition(ccp((position1.x + position2.x)/2, (position1.y+position2.y)/2))

	-- if theAction.ItemSpecialType == AnimalTypeConfig.kColumn then
	-- 	effect:setRotation(90)
	-- end
	
	-- boardView.specialEffectBatch:addChild(effect)

	-- local r = theAction.ItemPos1.x
	-- local c = theAction.ItemPos1.y
	-- local character = boardView.baseMap[r][c].itemSprite[ItemSpriteType.kItemShow]
	-- if character and character.name then
	-- 	local animate = ItemViewUtils:buildWrapLineEffectLineAnimate(character.name, theAction.ItemSpecialType)
	-- 	if animate then
	-- 		animate:setPosition(ccp((position1.x + position2.x)/2, (position1.y+position2.y)/2))
	-- 		boardView.specialEffectHighNode:addChild(animate)
	-- 	end
	-- end
end

function DestructionPlanLogic:runGameItemActionBombSpecialLine(boardView, theAction) 		----播放横排直线爆炸特效
	theAction.actionStatus = GameActionStatus.kRunning

	-- if theAction.specialMatchType ~= SpecialMatchType.kWrapLine then
		local r1 = theAction.ItemPos1.x
		local c1 = theAction.ItemPos1.y
		local position1 = DestructionPlanLogic:getItemPosition(theAction.ItemPos1)
		local effect = CommonEffect:buildLineEffect(boardView.specialEffectBatch)
		effect:setPosition(position1)
		
		boardView.specialEffectBatch:addChild(effect)
	-- end
end 

function DestructionPlanLogic:runGameItemActionBombSpecialColumn(boardView, theAction)		----播放竖排直线爆炸特效
	-- body
	theAction.actionStatus = GameActionStatus.kRunning

	-- if theAction.specialMatchType ~= SpecialMatchType.kWrapLine then
		local r1 = theAction.ItemPos1.x
		local c1 = theAction.ItemPos1.y
		local position1 = DestructionPlanLogic:getItemPosition(theAction.ItemPos1)
		local effect = CommonEffect:buildLineEffect(boardView.specialEffectBatch)
		effect:setPosition(position1)
		effect:setRotation(90)
		
		boardView.specialEffectBatch:addChild(effect)
	-- end
end

function DestructionPlanLogic:runGameItemActionBombSpecialWrap(boardView, theAction)			----播放区域特效爆炸效果
	theAction.actionStatus = GameActionStatus.kRunning

	local position1 = DestructionPlanLogic:getItemPosition(theAction.ItemPos1)
	local effect = CommonEffect:buildWrapEffect(boardView.specialEffectBatch)
	effect:setPosition(position1)
	boardView.specialEffectBatch:addChild(effect)
end

function DestructionPlanLogic:runGameItemActionBombSpecialWrapWrap(boardView, theAction)
	theAction.actionStatus = GameActionStatus.kRunning

	local position1 = DestructionPlanLogic:getItemPosition(theAction.ItemPos1)
	local effect = CommonEffect:buildWrapEffect(boardView.specialEffectBatch, 0.3)
	effect:setPosition(position1)
	boardView.specialEffectBatch:addChild(effect)

	local position2 = DestructionPlanLogic:getItemPosition(theAction.ItemPos2)
	local effect2 = CommonEffect:buildWrapEffect(boardView.specialEffectBatch, 0.3)
	effect2:setPosition(position2)
	boardView.specialEffectBatch:addChild(effect2)
end

function DestructionPlanLogic:runGameItemActionBombSpecialColor(boardView, theAction)
	theAction.actionStatus = GameActionStatus.kRunning
	-----对魔力鸟播放黑洞特效-----
	local r1 = theAction.ItemPos1.x;
	local c1 = theAction.ItemPos1.y;
	local item = boardView.baseMap[r1][c1];
	item:playBridBackEffect(true, 1.3)
end

function DestructionPlanLogic:runGameItemActionBombSpecialColor_End(boardView, theAction)
	-----对魔力鸟停止黑洞特效-----
	local r1 = theAction.ItemPos1.x;
	local c1 = theAction.ItemPos1.y;
	local item = boardView.baseMap[r1][c1];
	item:playBridBackEffect(false);
end

function DestructionPlanLogic:runGameItemActionBombBirdLine(boardView, theAction)
	theAction.actionStatus = GameActionStatus.kRunning
	-----对魔力鸟播放黑洞特效-----
	local r1 = theAction.ItemPos1.x;
	local c1 = theAction.ItemPos1.y;
	local item = boardView.baseMap[r1][c1];
	item:playBridBackEffect(true, 0.75);
end

function DestructionPlanLogic:runGameItemActionBombBirdLine_End(boardView, theAction)
	-----对魔力鸟停止黑洞特效-----
	local r1 = theAction.ItemPos1.x;
	local c1 = theAction.ItemPos1.y;
	local item = boardView.baseMap[r1][c1];
	item:playBridBackEffect(false);
end

function DestructionPlanLogic:runGameItemActionBombBirdLineFlying(boardView, theAction)		----鸟和直线交换之后，飞出的特效
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		local r1 = theAction.ItemPos1.x
		local c1 = theAction.ItemPos1.y
		local r2 = theAction.ItemPos2.x
		local c2 = theAction.ItemPos2.y

		local item1 = boardView.baseMap[r1][c1] 		----物体
		local item2 = boardView.baseMap[r2][c2]			----鸟

		-- local flyingtime = DestructionPlanLogic:getActionTime(theAction.actionDuring - theAction.addInt)
		local flyingtime = DestructionPlanLogic:getActionTime(theAction.actionDuring)
		local delaytime = DestructionPlanLogic:getActionTime(theAction.addInt)

		if theAction.ItemType == GameItemType.kBlocker195 then
			local toPos = item1:getBasePosition(c1, r1)
			local fromPos = item1:getBasePosition(c2, r2)
			item1:playBlocker195FlyAnimation(fromPos, toPos)
			item1.isNeedUpdate = true
		else
			item1:playFlyingBirdEffect(r2, c2, delaytime, flyingtime, theAction.ItemSpecialType)
		end
	else
		if theAction.actionDuring == 5 then
			local r1 = theAction.ItemPos1.x
			local c1 = theAction.ItemPos1.y
			local item1 = boardView.baseMap[r1][c1] 		----物体
			item1:playMixTileHighlightEffect()
		elseif theAction.actionDuring == 3 then
			theAction.addInfo = "changeItem"
		elseif theAction.actionDuring == 1 then
			local r1 = theAction.ItemPos1.x
			local c1 = theAction.ItemPos1.y
			local item1 = boardView.baseMap[r1][c1] 		----物体
			item1:playAnimalSpriteZoomIn()
		end
	end
end

function DestructionPlanLogic:runGameItemActionBombBirdBird(boardView, theAction)
	theAction.actionStatus = GameActionStatus.kRunning
	-----对魔力鸟播放黑洞特效-----
	local r1 = theAction.ItemPos1.x
	local c1 = theAction.ItemPos1.y
	local r2 = theAction.ItemPos2.x
	local c2 = theAction.ItemPos2.y

	local item = boardView.baseMap[r1][c1]

	local position1 = item:getBasePosition(c1, r1)
	local position2 = item:getBasePosition(c2, r2)
	local pos = ccp((position1.x+position2.x)/2, (position1.y+position2.y)/2)

	item:playBirdBirdBackEffect(true, pos)
end

function DestructionPlanLogic:runGameItemActionBirdBirdExplode(boardView, theAction)
	if theAction.hasExplode == nil and theAction.addInfo == "BombAll" then
		theAction.hasExplode = true
		local r1 = theAction.ItemPos1.x
		local c1 = theAction.ItemPos1.y
		local item = boardView.baseMap[r1][c1]
		item:playBirdBirdExplodeEffect(true, theAction.bombList)
	end
	if theAction.hasExplode and theAction.addInfo == "Over" then
		local r1 = theAction.ItemPos1.x
		local c1 = theAction.ItemPos1.y
		local item = boardView.baseMap[r1][c1]
		item:finishBirdBirdExplodeEffect()
	end
end

function DestructionPlanLogic:runGameItemActionBombBirdBird_End(boardView, theAction)
	-----对魔力鸟停止黑洞特效-----
	local r1 = theAction.ItemPos1.x
	local c1 = theAction.ItemPos1.y
	local item = boardView.baseMap[r1][c1]
	item:playBirdBirdBackEffect(false)
end

--------------------------------- Rectangle Bomb ---------------------------------
function DestructionPlanLogic:runGameItemActionRectangleBombLogic(mainLogic, theAction, actid)
	if theAction.addInfo == "over" then
		return 
	end

	local r1 = theAction.ItemPos1.y
	local c1 = theAction.ItemPos1.x
	local r2 = theAction.ItemPos2.y
	local c2 = theAction.ItemPos2.x
	local scoreScale = theAction.addInt2

    local SpecialID = mainLogic:addSrcSpecialCoverToList( theAction.ItemPos1, theAction.ItemPos2 )

	local function getEliminateChainDir(r, c)
		local chainDir = {}
		--非边缘
		if r + 1 <= r2 then table.insert(chainDir, ChainDirConfig.kDown) end
		if r - 1 >= r1 then table.insert(chainDir, ChainDirConfig.kUp) end
		if c + 1 <= c2 then table.insert(chainDir, ChainDirConfig.kRight) end
		if c - 1 >= c1 then table.insert(chainDir, ChainDirConfig.kLeft) end
		if theAction.eliminateChainIncludeHem then 	--对区域外边框的冰柱也会进行消除
			if r + 1 > r2 then table.insert(chainDir, ChainDirConfig.kDown) end
			if r - 1 < r1 then table.insert(chainDir, ChainDirConfig.kUp) end
			if c + 1 > c2 then table.insert(chainDir, ChainDirConfig.kRight) end
			if c - 1 < c1 then table.insert(chainDir, ChainDirConfig.kLeft) end
		end
		-- printx(11, "chainDir at ("..r..","..c..")", table.tostring(chainDir))
		return chainDir
	end

	for r = r1, r2 do
		for c = c1, c2 do
			if mainLogic:isPosValid(r, c) then
				local item = mainLogic.gameItemMap[r][c]
				SpecialCoverLogic:SpecialCoverLightUpAtPos(mainLogic, r, c, scoreScale)
				BombItemLogic:tryCoverByBomb(mainLogic, r, c, true, scoreScale, nil, nil, theAction.footprintType)
				SpecialCoverLogic:SpecialCoverAtPos(mainLogic, r, c, 3, scoreScale, nil, nil, nil, theAction.footprintType, theAction.SpecialID or SpecialID) --先看看效果吧="=;
				SpecialCoverLogic:specialCoverChainsAtPos(mainLogic, r, c, getEliminateChainDir(r, c))
				-- SpecialCoverLogic:specialCoverChainsAtPos(mainLogic, r, c, {ChainDirConfig.kUp, ChainDirConfig.kDown, ChainDirConfig.kLeft, ChainDirConfig.kRight})
				GameExtandPlayLogic:doABlocker211Collect(mainLogic, nil, nil, r, c, 0, true, 3)
			end
		end
	end

	-- 处理属于邻格子的边缘冰柱
	if theAction.eliminateChainIncludeHem then
		local outerR, outerC
		outerR = r1 - 1
		for outerC = c1, c2 do
			if mainLogic:isPosValid(outerR, outerC) then
				SpecialCoverLogic:specialCoverChainsAtPos(mainLogic, outerR, outerC, {ChainDirConfig.kDown})
			end
		end

		outerR = r2 + 1
		for outerC = c1, c2 do
			if mainLogic:isPosValid(outerR, outerC) then
				SpecialCoverLogic:specialCoverChainsAtPos(mainLogic, outerR, outerC, {ChainDirConfig.kUp})
			end
		end

		outerC = c1 - 1
		for outerR = r1, r2 do
			if mainLogic:isPosValid(outerR, outerC) then
				SpecialCoverLogic:specialCoverChainsAtPos(mainLogic, outerR, outerC, {ChainDirConfig.kRight})
			end
		end

		outerC = c2 + 1
		for outerR = r1, r2 do
			if mainLogic:isPosValid(outerR, outerC) then
				SpecialCoverLogic:specialCoverChainsAtPos(mainLogic, outerR, outerC, {ChainDirConfig.kLeft})
			end
		end
	end

	----执行一次就over----
	theAction.addInfo = "over"
	mainLogic.destructionPlanList[actid] = nil
end

function DestructionPlanLogic:runGameItemActionRectangleBombView(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning

		-- --tmp：先用直线特效表示一下="=
		-- local position1 = DestructionPlanLogic:getItemPosition(theAction.ItemPos1)
		-- local effect = CommonEffect:buildLineEffect(boardView.specialEffectBatch)
		-- effect:setPosition(position1)
		-- if theAction.ItemPos1.x == theAction.ItemPos2.x then
		-- 	effect:setRotation(90)
		-- end
		
		-- boardView.specialEffectBatch:addChild(effect)
	end
end

--------------------------------- Diagonal Square Bomb ---------------------------------
function DestructionPlanLogic:runGameItemActionDiagonalSquareBombLogic(mainLogic, theAction, actid)
	if theAction.addInfo == "over" then
		return 
	end

	local function getBombPosList(radius, centreR, centreC)
		local result = {}
		for i = -radius, radius do
			local targetRow = centreR + i
			local colWidthShift = radius - math.abs(i)

			for j = (centreC - colWidthShift), (centreC + colWidthShift) do
				local p = {c = j, r = targetRow}
				table.insert(result, p)
			end
		end
		return result
	end

	local centerR = theAction.ItemPos1.y
	local centerC = theAction.ItemPos1.x
	local scoreScale = theAction.addInt2
	local bombPosList = getBombPosList(theAction.radius, centerR, centerC)

	local pos1 = IntCoord:create(theAction.ItemPos1.y,theAction.ItemPos1.x)
	local pos2 = nil
	if theAction.ItemPos2 then
		pos2 = IntCoord:create(theAction.ItemPos2.y,theAction.ItemPos2.x)
	end
    local SpecialID = mainLogic:addSrcSpecialCoverToList( pos1, pos2 )

	for _, v in ipairs(bombPosList) do
		local r, c = v.r, v.c
		if mainLogic:isPosValid(r, c) then
			local item = mainLogic.gameItemMap[r][c]
			SpecialCoverLogic:SpecialCoverLightUpAtPos(mainLogic, r, c, scoreScale)
			BombItemLogic:tryCoverByBomb(mainLogic, r, c, true, scoreScale, nil, nil, theAction.footprintType)
			SpecialCoverLogic:SpecialCoverAtPos(mainLogic, r, c, 3, scoreScale, nil, nil, nil, theAction.footprintType, SpecialID) --先看看效果吧="=;
			local breakDirs = DestructionPlanLogic:calcBreakChainDirsAtPos(r, c, centerR, centerC, theAction.radius)
			SpecialCoverLogic:specialCoverChainsAtPos(mainLogic, r, c, breakDirs)
            GameExtandPlayLogic:doABlocker211Collect(mainLogic, nil, nil, r, c, 0, true, 3)
		end
	end

	----执行一次就over----
	theAction.addInfo = "over"
	mainLogic.destructionPlanList[actid] = nil
end

function DestructionPlanLogic:runGameItemActionDiagonalSquareBombView(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning

		-- --tmp：先用爆炸特效表示一下="=
		-- local position1 = DestructionPlanLogic:getItemPosition(theAction.ItemPos1)
		-- local effect = CommonEffect:buildWrapEffect(boardView.specialEffectBatch)
		-- effect:setPosition(position1)
		-- boardView.specialEffectBatch:addChild(effect)
	end
end

function DestructionPlanLogic:runningGameItemMoleWeekly_Bomb_All_Logic(mainLogic, theAction, actid)
    if theAction.addInfo == "bombAll" then
		GamePlayMusicPlayer:playEffect(GameMusicType.kSwapColorColorCleanAll)
--		local startRow, startCol = theAction.ItemPos1.x, theAction.ItemPos1.y
--		local endRow, endCol = theAction.ItemPos2.x, theAction.ItemPos2.y
--		local rowCount = theAction.addInt or 0
--		local delRow = startRow + rowCount
--		if delRow <= endRow then
--			for c = startCol, endCol do
--				local item = mainLogic.gameItemMap[delRow] and mainLogic.gameItemMap[delRow][c] or nil
--				BombItemLogic:forceClearItemWithCover(mainLogic, delRow, c)
--			end
--		end

        BombItemLogic:springFestivalBombScreen( mainLogic )

--		theAction.addInt = rowCount + 1
--		if startRow + theAction.addInt > endRow then
--			theAction.addInfo = "over"
--		end

        theAction.addInfo = "over"
	elseif theAction.addInfo == "over" then
		if theAction.completeCallback then
			theAction.completeCallback()
		end
		mainLogic.destructionPlanList[actid] = nil
	end
end

function DestructionPlanLogic:runningGameItemMoleWeekly_Bomb_All_View(boardView, theAction)
    if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning

		theAction.addInfo = "bombAll"
	end
end

------------------------------------- Squid Bomb ---------------------------------
function DestructionPlanLogic:runGameItemActionSquidBombGridLogic(mainLogic, theAction, actid)
	if theAction.addInfo == "over" then
		return 
	end

	SquidLogic:onSquidBombGrid(mainLogic, theAction)

	----执行一次就over----
	theAction.addInfo = "over"
	mainLogic.destructionPlanList[actid] = nil
end

function DestructionPlanLogic:runGameItemActionSquidBombGridView(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
	end
end

------------------------------ 横竖特效小捣蛋...啊不，导弹 -------------------------------
function DestructionPlanLogic:runGamePropsLineEffectLogic(mainLogic, theAction, actid)
	local isColumn = theAction.isColumn
	local origR, origC = theAction.ItemPos1.x, theAction.ItemPos1.y

	local boardView = mainLogic.boardView

	if theAction.addInfo == "startAction" then
		theAction.addInfo = "startAnimation"
		theAction.jsq = 0
	end

	if theAction.addInfo == "startAnimation" then
		theAction.jsq = theAction.jsq + 1
		-- 动画在usePropState播了
		if theAction.jsq == 10 then
			theAction.addInfo = "startBombGrids"
			theAction.bombIndex = 1
			theAction.jsq = 0
		end
	end

	if theAction.addInfo == "startBombGrids" then
		theAction.jsq = theAction.jsq + 1

		local maxLength = 10 --行进最长格子数
		local bombDelay = 3
		-- printx(11, "startBomb", isColumn, theAction.jsq, theAction.bombIndex)
		if theAction.jsq == theAction.bombIndex * bombDelay then
			local r, c
			if isColumn then
				c = origC
				r = theAction.bombIndex
				if origR > 5 then 	--大于某列，要反着播
					r = maxLength - theAction.bombIndex
				end
			else
				r = origR
				c = theAction.bombIndex
				if origC > 5 then
					c = maxLength - theAction.bombIndex
				end
			end
			-- printx(11, "r, c :("..r..","..c..")")
			local targetGrid = {x = c, y = r}
			local rectangleAction = GameBoardActionDataSet:createAs(
										GameActionTargetType.kGameItemAction,
										GameItemActionType.kItemSpecial_rectangle,
										targetGrid,
										targetGrid,
										GamePlayConfig_MaxAction_time)
			rectangleAction.addInt2 = 1
			rectangleAction.eliminateChainIncludeHem = false

			--果酱兼容
			if mainLogic.theGamePlayType == GameModeTypeId.JAMSPREAD_ID then
				rectangleAction.SpecialID = mainLogic:addSrcSpecialCoverToListEx( {targetGrid}, true )
			end

			mainLogic:addDestructionPlanAction(rectangleAction)

			-- 消冰柱
			local chainDirections = {}
			if isColumn then
				table.insert(chainDirections, ChainDirConfig.kDown)
				table.insert(chainDirections, ChainDirConfig.kUp)
			else
				table.insert(chainDirections, ChainDirConfig.kRight)
				table.insert(chainDirections, ChainDirConfig.kLeft)
			end
			SpecialCoverLogic:specialCoverChainsAtPos(mainLogic, r, c, chainDirections)

			theAction.bombIndex = theAction.bombIndex + 1
		end

		if theAction.bombIndex >= maxLength then
			theAction.addInfo = "bombEnded"
			theAction.jsq = 0
		end
	end

	if theAction.addInfo == "bombEnded" then
		theAction.jsq = theAction.jsq + 1
		if theAction.jsq == 60 then
			theAction.addInfo = "over"
		end
	end

	if theAction.addInfo == "over" then
		if theAction.completeCallback then
			theAction.completeCallback()
		end
		mainLogic.destructionPlanList[actid] = nil
	end
end

function DestructionPlanLogic:runGamePropsLineEffectView(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning

        theAction.addInfo = "startAction"
    end
end
