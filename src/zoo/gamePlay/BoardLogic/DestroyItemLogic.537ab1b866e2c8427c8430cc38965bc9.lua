DestroyItemLogic = class()

function DestroyItemLogic:update(mainLogic)
	local count1 = DestroyItemLogic:destroyDecision(mainLogic)
	local count2 = DestroyItemLogic:destroyExecutor(mainLogic)
	-- 检测blocker状态变化
	mainLogic:updateFallingAndBlockStatus()
	--printx( 1 , "   DestroyItemLogic:update  " , count1 , count2)
	return count1 > 0 or count2 > 0
end

function DestroyItemLogic:destroyDecision(mainLogic)
	local count = 0
	local output = "destroy item: "
	local flag = false
	for r = 1, #mainLogic.gameItemMap do
		for c = 1, #mainLogic.gameItemMap[r] do
			local item = mainLogic.gameItemMap[r][c]

			if (item.ItemStatus == GameItemStatusType.kIsSpecialCover 
				or item.ItemStatus == GameItemStatusType.kIsMatch)
				and item.ItemType ~= GameItemType.kDrip
				then
				count = count + 1
				output = output .. string.format("(%d, %d) ", r, c)
				flag = true
				
				local specialType = mainLogic.gameItemMap[r][c].ItemSpecialType
				if AnimalTypeConfig.isSpecialTypeValid(specialType) then

					local keyname = ""

					if item.ItemStatus == GameItemStatusType.kIsMatch then
						if specialType == AnimalTypeConfig.kLine or specialType == AnimalTypeConfig.kColumn then
							keyname = "line_match_swap"
						elseif specialType == AnimalTypeConfig.kWrap then
							keyname = "wrap_match_swap"
						end
					elseif item.ItemStatus == GameItemStatusType.kIsSpecialCover then
						if specialType == AnimalTypeConfig.kLine or specialType == AnimalTypeConfig.kColumn then
							keyname = "line_cover"
						elseif specialType == AnimalTypeConfig.kWrap then
							keyname = "wrap_cover"
						elseif specialType == AnimalTypeConfig.kColor then
							keyname = "bird_cover"
						end
					end
					GamePlayContext:getInstance():updatePlayInfo( keyname , 1 )
					
					BombItemLogic:BombItem(mainLogic, r, c, 1, 0)

				end

				if item.ItemType == GameItemType.kAnimal and specialType == 0 then
					GamePlayContext:getInstance():updatePlayInfo( "animal_destroy_count" , 1 )
				end

				if item.ItemType == GameItemType.kBlocker199 then
					item.bombRes = nil
					item:AddItemStatus( GameItemStatusType.kNone , true )
					if SpecialCoverLogic:canBeEffectBySpecialAt(mainLogic, r, c) then
						SpecialCoverLogic:effectBlockerAt(mainLogic, r, c, 1, nil, false, false)
					end
				elseif specialType ~= AnimalTypeConfig.kColor then
					item:AddItemStatus(GameItemStatusType.kDestroy)
					mainLogic:tryDoOrderList(r, c, GameItemOrderType.kAnimal, item._encrypt.ItemColorType)
					local deletedAction = GameBoardActionDataSet:createAs(
						GameActionTargetType.kGameItemAction,
						GameItemActionType.kItemDeletedByMatch,
						IntCoord:create(r,c),
						nil,
						GamePlayConfig_GameItemAnimalDeleteAction_CD)

					if item.ItemType == GameItemType.kBalloon then 
						deletedAction.addInfo = "balloon"
						ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_Balloon, ObstacleFootprintAction.k_Eliminate, 1)
					end
					if item.ItemType == GameItemType.kDrip then 
						deletedAction.addInfo = "drip"
					end
					if item.ItemType == GameItemType.kCrystal then 
						ObstacleFootprintManager:addCrystalBallEliminateRecord(item)
					end
					-- if item.ItemSpecialType == AnimalTypeConfig.kWrap then
					-- 	deletedAction.addInfo = "wrap"
					-- end
					mainLogic:addDestroyAction(deletedAction)

					if item:canChargeCrystalStone() then
						GameExtandPlayLogic:chargeCrystalStone(mainLogic, r, c, item._encrypt.ItemColorType)
						GameExtandPlayLogic:doAllBlocker211Collect(mainLogic, r, c, item._encrypt.ItemColorType, false, 1)--寄居蟹充能
					end	
				end
			end
		end
	end
	if flag then
		-- if _G.isLocalDevelopMode then printx(0, output) end
	end
	return count
end

function DestroyItemLogic:destroyExecutor(mainLogic)
	local count = 0

	local maxIndex = table.maxn(mainLogic.destroyActionList)
	for i = 1 , maxIndex do
		local atc = mainLogic.destroyActionList[i]
		if atc then
			count = count + 1
			--printx( 1 , "   DestroyItemLogic:destroyExecutor  " , atc.actionType)
			DestroyItemLogic:runLogicAction(mainLogic, atc, i)
			DestroyItemLogic:runViewAction(mainLogic.boardView, atc)
		end
	end
	--[[
	for k,v in pairs(mainLogic.destroyActionList) do
		count = count + 1
		DestroyItemLogic:runLogicAction(mainLogic, v, k)
		DestroyItemLogic:runViewAction(mainLogic.boardView, v)
	end
	]]
	return count
end

function DestroyItemLogic:runLogicAction(mainLogic, theAction, actid)
	-- if _G.isLocalDevelopMode then printx(0, 'run DestroyItemLogic:runLogicAction') end
	if theAction.actionStatus == GameActionStatus.kRunning then 		---running阶段，自动扣时间，到时间了，进入Death阶段
		if theAction.actionDuring < 0 then 
			theAction.actionStatus = GameActionStatus.kWaitingForDeath
		else
			theAction.actionDuring = theAction.actionDuring - 1
			DestroyItemLogic:runningGameItemAction(mainLogic, theAction, actid)
		end
	end

	if theAction.actionType == GameItemActionType.kItemDeletedByMatch then 			--被匹配消除
		DestroyItemLogic:runGameItemDeletedByMatch(mainLogic, theAction, actid)	
	elseif theAction.actionType == GameItemActionType.kItemCoverBySpecial_Color then 			--被特效消除
		DestroyItemLogic:runGameItemSpecialCoverAction(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItemSpecial_Color_ItemDeleted then 		----鸟和普通动物交换、爆炸---》普通物体最终被消耗掉
		DestroyItemLogic:runGameItemSpecialBombColorAction_ItemDeleted(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItemSpecial_ColorColor_ItemDeleted then
		DestroyItemLogic:runGameItemSpecialBombColorColorAction_ItemDeleted(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItemMatchAt_SnowDec then
		DestroyItemLogic:runGameItemSpecialSnowDec(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItemMatchAt_VenowDec then
		DestroyItemLogic:runGameItemSpecialVenomDec(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItem_Furball_Grey_Destroy then
		DestroyItemLogic:runGameItemSpecialGreyFurballDestroy(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItemMatchAt_LockDec then
		DestroyItemLogic:runGameItemSpecialLockDec(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItem_Roost_Upgrade then
		DestroyItemLogic:runGameItemRoostUpgrade(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItem_DigGroundDec then
		DestroyItemLogic:runGameItemDigGroundDecLogic(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItem_DigJewleDec then
		DestroyItemLogic:runGameItemDigJewelDecLogic(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItem_randomPropDec then
		DestroyItemLogic:runGameItemRandomPropDecLogic(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItem_Bottle_Blocker_Explode then
		DestroyItemLogic:runGameItemBottleBlockerDecLogic(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItem_Monster_frosting_dec then 
		DestroyItemLogic:runGameItemMonsterFrostingLogic(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItem_chestSquare_part_dec then 
		DestroyItemLogic:runGameItemChestSquarePartLogic(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItem_Black_Cute_Ball_Dec then
		DestroyItemLogic:runGameItemBlackCuteBallDec(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItem_Mayday_Boss_Loss_Blood then
		DestroyItemLogic:runningGameItemActionMaydayBossLossBlood(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_Weekly_Boss_Loss_Blood then
		DestroyItemLogic:runningGameItemActionWeeklyBossLossBlood(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_Magic_Lamp_Charging then
		DestroyItemLogic:runningGameItemActionMagicLampCharging(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_Wukong_Charging then
		DestroyItemLogic:runningGameItemActionWukongCharging(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_WitchBomb then
		DestroyItemLogic:runningGameItemActionWitchBomb(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_Honey_Bottle_increase then
		DestroyItemLogic:runningGameItemActionHoneyBottleIncrease(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItemDestroy_HoneyDec then
		DestroyItemLogic:runningGameItemActionHoneyDec(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_Sand_Clean then
		DestroyItemLogic:runningGameItemActionCleanSand(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItemMatchAt_IceDec then
		DestroyItemLogic:runningGameItemActionIceDec(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_QuestionMark_Protect then
		DestroyItemLogic:runGameItemQuestionMarkProtect(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_Magic_Stone_Active then
		DestroyItemLogic:runGameItemMagicStoneActive(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_Monster_Jump then
		DestroyItemLogic:runningGameItemActionMonsterJump(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_ChestSquare_Jump then
		DestroyItemLogic:runningGameItemActionChestSquareJump(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItemSpecial_CrystalStone_Destroy then
		DestroyItemLogic:runningGameItemActionCrystalStoneDestroy(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItem_Totems_Change then
		DestroyItemLogic:runingGameItemTotemsChangeAction(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItem_SuperTotems_Bomb_By_Match then
		DestroyItemLogic:runingGameItemTotemsBombByMatch(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItem_Decrease_Lotus then
		DestroyItemLogic:runningGameItemActionDecreaseLotus(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItem_SuperCute_Inactive then
		DestroyItemLogic:runningGameItemActionInactiveSuperCute(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItem_Mayday_Boss_Die then
		DestroyItemLogic:runnningGameItemActionBossDie(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_Weekly_Boss_Die then
		DestroyItemLogic:runnningGameItemActionWeeklyBossDie(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItemMatchAt_OlympicLockDec then
		DestroyItemLogic:runningGameItemActionOlympicLockDec(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItemMatchAt_OlympicBlockDec then
		DestroyItemLogic:runningGameItemActionOlympicBlockDec(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItemMatchAt_Olympic_IceDec then
		DestroyItemLogic:runningGameItemActionOlympicIceDec(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kMissileHit then
		DestroyItemLogic:runningGameItemActionMissileHit(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItemMatchAt_BlockerCoverMaterialDec then
		DestroyItemLogic:runningGameItemActionBlockerCoverMaterialDec(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_Blocker_Cover_Dec then
		DestroyItemLogic:runningGameItemActionBlockerCoverDec(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kMissileFire then
		DestroyItemLogic:runningGameItemActionMissileFire(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kMissileHitSingle then
		DestroyItemLogic:runningGameItemActionMissileHitSingle(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_TangChicken_Destroy then
		DestroyItemLogic:runningGameItemActionTangChicken(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kEliminateMusic then
		DestroyItemLogic:runningGameItemActionPlayEliminateMusic(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_Blocker195_Dec then
		DestroyItemLogic:runningGameItemActionBlocker195Dec(mainLogic, theAction, actid, actByView)	
	elseif theAction.actionType == GameItemActionType.kItem_ColorFilterB_Dec then
		DestroyItemLogic:runningGameItemActionColorFilterBDec(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_Chameleon_transform then
		DestroyItemLogic:runGameItemActionChameleonTransformLogic(mainLogic, theAction, actid)	--run还是running，你们有个统一的主意吗？？？				
	elseif theAction.actionType == GameItemActionType.kItem_Blocker206_Dec then
		DestroyItemLogic:runningGameItemActionBlocker206Dec(mainLogic, theAction, actid, actByView)	
	elseif theAction.actionType == GameItemActionType.kItem_Blocker207_Dec then		
		DestroyItemLogic:runningGameItemActionBlocker207Dec(mainLogic, theAction, actid, actByView)	
	elseif theAction.actionType == GameItemActionType.kItem_pacman_eatTarget then
		DestroyItemLogic:runGameItemActionPacmanEatTargetLogic(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItem_pacman_blow then
		DestroyItemLogic:runGameItemActionPacmanBlowLogic(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItem_pacmansDen_generate then
		DestroyItemLogic:runGameItemActionPacmanGenerateLogic(mainLogic, theAction, actid, actByView)
    elseif theAction.actionType == GameItemActionType.kItem_Turret_upgrade then
		DestroyItemLogic:runGameItemActionTurretUpgradeLogic(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_MoleWeekly_Magic_Tile_Blast then
		DestroyItemLogic:runGameItemActionMoleWeeklyMagicTileBlastLogic(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_MoleWeekly_Boss_Cloud_Die then
		DestroyItemLogic:runGameItemActionMoleWeeklyCloudDieLogic(mainLogic, theAction, actid, actByView)
    elseif theAction.actionType == GameItemActionType.kItem_YellowDiamondDec then
		DestroyItemLogic:runGameItemYellowDiamondDecLogic(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItem_ghost_move then
		DestroyItemLogic:runGameItemActionGhostMoveLogic(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItem_ghost_collect then
		DestroyItemLogic:runGameItemActionGhostCollectLogic(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItem_SunFlask_Blast then
		DestroyItemLogic:runGameItemActionSunFlaskBlastLogic(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_SunFlower_Blast then
		DestroyItemLogic:runGameItemActionSunFlowerBlastLogic(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_Squid_Collect then
		DestroyItemLogic:runGameItemActionSquidCollectLogic(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_Squid_Run then
		DestroyItemLogic:runGameItemActionSquidRunLogic(mainLogic, theAction, actid, actByView)
    elseif theAction.actionType == GameItemActionType.kItem_WanSheng_increase then
		DestroyItemLogic:runningGameItemActionWanShengIncrease(mainLogic, theAction, actid, actByView)
    elseif theAction.actionType == GameItemActionType.kItem_SpringFestival2019_Skill1 then
		DestroyItemLogic:runningGameItemActionSprintFestival2019Skill1Logic(mainLogic, theAction, actid, actByView)
    elseif theAction.actionType == GameItemActionType.kItem_SpringFestival2019_Skill2 then
		DestroyItemLogic:runningGameItemActionSprintFestival2019Skill2Logic(mainLogic, theAction, actid, actByView)
    elseif theAction.actionType == GameItemActionType.kItem_SpringFestival2019_Skill3 then
		DestroyItemLogic:runningGameItemActionSprintFestival2019Skill3Logic(mainLogic, theAction, actid, actByView)
    elseif theAction.actionType == GameItemActionType.kItem_SpringFestival2019_Skill4 then
		DestroyItemLogic:runningGameItemActionSprintFestival2019Skill4Logic(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItemMatchAt_ApplyMilk then
		DestroyItemLogic:runningGameItemActionApplyMilkLogic(mainLogic, theAction, actid)
	end
end

function DestroyItemLogic:runningGameItemActionBlocker207Dec(mainLogic, theAction, actid, actByView)

	if theAction.addInfo == "checkChargeList" then

		local groupKey = theAction.groupKey or -1

		theAction.chargeList = {}

		for r = 1, #mainLogic.gameItemMap do
			for c = 1, #mainLogic.gameItemMap do 
				local item = mainLogic.gameItemMap[r][c]
				if item then 

					if item.lockLevel == groupKey and item.lockHead then
						table.insert( theAction.chargeList , {r = r , c = c} )
					end

				end
			end
		end

		theAction.addInfo = "flyEff"

	elseif theAction.addInfo == "over" then
		mainLogic.destroyActionList[actid] = nil
	end

end

function DestroyItemLogic:runningGameItemActionBlocker206Dec(mainLogic, theAction, actid, actByView)
	
	if theAction.addInfo == "checkNeedUnlockBlocker" then

		local unlockGroupKey = theAction.unlockGroupKey or -1
		local nextGroupKey = theAction.nextGroupKey or -1

		theAction.unlockGroup = {}
		theAction.nextGroup = {}

		for r = 1, #mainLogic.gameItemMap do
			for c = 1, #mainLogic.gameItemMap do 
				local item = mainLogic.gameItemMap[r][c]
				if item then 

					if item.lockLevel == unlockGroupKey then
						table.insert( theAction.unlockGroup , {r = r , c = c} )
					elseif item.lockLevel == nextGroupKey then
						table.insert( theAction.nextGroup , {r = r , c = c} )
						item.lockBoxActive = true
					end

				end
			end
		end

		theAction.addInfo = "playUnlock"

	elseif theAction.addInfo == "doUnlock" then

		if theAction.unlockGroup and #theAction.unlockGroup then
			for i = 1 , #theAction.unlockGroup do
				local pos = theAction.unlockGroup[i]

				local item = mainLogic.gameItemMap[pos.r][pos.c]

				item.lockLevel = 0
				mainLogic:checkItemBlock(pos.r, pos.c)
				mainLogic:addNeedCheckMatchPoint(pos.r, pos.c)
				mainLogic.gameMode:checkDropDownCollect(pos.r, pos.c)
				
				Blocker206Logic:cancelEffectByLock(mainLogic)
				mainLogic:setNeedCheckFalling()
			end
			ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_Blocker206, ObstacleFootprintAction.k_Unlocked, #theAction.unlockGroup)
		end

		mainLogic.destroyActionList[actid] = nil
	end

end

function DestroyItemLogic:runningGameItemActionColorFilterBDec(mainLogic, theAction, actid, actByView)
	if theAction.addInfo == "over" then
		local newLevel = theAction.newLevel

		if newLevel <= 0 then
			local r1 = theAction.ItemPos1.x
			local c1 = theAction.ItemPos1.y
			
			GameExtandPlayLogic:doAllBlocker195Collect(mainLogic, r1, c1, Blocker195CollectType.kColorFilter)
			SquidLogic:checkSquidCollectItem(mainLogic, r1, c1, TileConst.kColorFilter)

			local itemData = mainLogic.gameItemMap[r1][c1]
			itemData:setColorFilterBLock(false)

			local boardData = mainLogic.boardmap[r1][c1]
			boardData.colorFilterState = ColorFilterState.kStateA
			boardData.isNeedUpdate = true
			boardData.colorFilterBLevel = 0
			
			mainLogic:checkItemBlock(r1, c1)
			ColorFilterLogic:handleFilter(r1, c1) 
			mainLogic:addNeedCheckMatchPoint(r1, c1)
			mainLogic.gameMode:checkDropDownCollect(r1, c1)
			mainLogic:setNeedCheckFalling()
			mainLogic:tryBombSuperTotemsByForce()
		end 

		mainLogic.destroyActionList[actid] = nil
	end
end

function DestroyItemLogic:runningGameItemActionBlocker195Dec(mainLogic, theAction, actid, actByView)
	if theAction.actionStatus == GameActionStatus.kWaitingForDeath then
		local r1, c1 = theAction.ItemPos1.x,theAction.ItemPos1.y
		local item = mainLogic.gameItemMap[r1][c1]

		GameExtandPlayLogic:decreaseLotus(mainLogic, r1, c1 , 1)
		SnailLogic:SpecialCoverSnailRoadAtPos(mainLogic, r1, c1)
		SpecialCoverLogic:SpecialCoverLightUpAtBlocker(mainLogic, r1, c1, 1, item:isBlocker195Available())
		
		item:cleanAnimalLikeData()
		mainLogic:setNeedCheckFalling()
		ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_Blocker195, ObstacleFootprintAction.k_Attack, 1)

		mainLogic.destroyActionList[actid] = nil
	end
end

function DestroyItemLogic:runningGameItemActionPlayEliminateMusic(mainLogic, theAction, actid, actByView)
	if theAction.actionStatus == GameActionStatus.kRunning then
		mainLogic.destroyActionList[actid] = nil
	end
end

function DestroyItemLogic:runningGameItemActionBlockerCoverDec(mainLogic, theAction, actid, actByView)
	if theAction.addInfo == "over" then

		local r1 = theAction.ItemPos1.x;
		local c1 = theAction.ItemPos1.y;

		if theAction.newLevel <= 0 then
			mainLogic:checkItemBlock( r1 , c1 )
			mainLogic:addNeedCheckMatchPoint(r1, c1)
			mainLogic.gameMode:checkDropDownCollect(r1, c1)
			mainLogic:setNeedCheckFalling()
			mainLogic:tryBombSuperTotemsByForce()
		end

		mainLogic.destroyActionList[actid] = nil
	end
end

function DestroyItemLogic:runningGameItemActionBlockerCoverMaterialDec(mainLogic, theAction, actid, actByView)
	if theAction.addInfo == "over" then
		mainLogic.destroyActionList[actid] = nil
	end
end

function DestroyItemLogic:runningGameItemActionTangChicken(mainLogic, theAction, actid, actByView)		
	if theAction.actionStatus == GameActionStatus.kRunning then
		if not theAction.hasCollectedNum then
			theAction.actTick = theAction.actTick or 0
			theAction.actTick = theAction.actTick + 1
			if theAction.actTick >= GamePlayConfig_TangChicken_Destroy1_Time then
				theAction.hasCollectedNum = true
				if mainLogic.gameMode:is(SpringHorizontalEndlessMode) then
					mainLogic.gameMode:collectChicken(theAction.tangChickenNum)
				end
			end
		end
	elseif theAction.actionStatus == GameActionStatus.kWaitingForDeath then
		local r,c = theAction.ItemPos1.x,theAction.ItemPos1.y
		local item = mainLogic.gameItemMap[r][c]
		item:cleanAnimalLikeData()
		item.isUsed = false

		local boardData = mainLogic.boardmap[r][c]
		boardData.isUsed = false

		mainLogic.destroyActionList[actid] = nil
	end
end

function DestroyItemLogic:runningGameItemActionMissileHitSingle(mainLogic, theAction, actid, actByView)

	if (theAction.addInfo == "over") then
		local function bombItem(r, c)
			local item = mainLogic.gameItemMap[r][c]
			local boardData = mainLogic.boardmap[r][c]

            local SpecialID = mainLogic:addSrcSpecialCoverToList( ccp(theAction.ItemPos1.y,theAction.ItemPos1.x) )
           	
			BombItemLogic:tryCoverByBomb(mainLogic, r, c, true, 1, nil, nil, ObstacleFootprintType.k_Missile)
			SpecialCoverLogic:SpecialCoverAtPos(mainLogic, r, c, 3, nil, nil, nil, nil, ObstacleFootprintType.k_Missile, SpecialID) 
			-- SpecialCoverLogic:specialCoverChainsAtPos(mainLogic, r, c) 
			SpecialCoverLogic:SpecialCoverLightUpAtPos(mainLogic, r, c, 1)
			GameExtandPlayLogic:doABlocker211Collect(mainLogic, theAction.ItemPos1.y, theAction.ItemPos1.x, r, c, 0, true, 3)
		end

		bombItem(theAction.ItemPos2.y,theAction.ItemPos2.x)

		if (theAction.completeCallback ) then
			theAction.completeCallback()
			mainLogic:setNeedCheckFalling()
		end
		mainLogic.destroyActionList[actid] = nil 
	end

end

function DestroyItemLogic:runningGameItemActionMissileFire(mainLogic, theAction, actid, actByView)

	if theAction.actionStatus == GameActionStatus.kRunning then
		-- 随机选择若干位置发射
		-- 等爆炸动画播放完成之后，发射导弹
		if (theAction.counter == 15) then
			theAction.allMissileChildActionComplete = false
			theAction.totalAttackPosition = 0
			local missileHitCount = 0
			local missileChildHitCallback = function()
				missileHitCount = missileHitCount + 1
				if (missileHitCount >= theAction.totalAttackPosition) then
					theAction.allMissileChildActionComplete = true
				end
			end

			-- 全部将要发射的冰封导弹
			for i,missile in ipairs(theAction.missiles) do
				-- 每一个冰封导弹，分裂成mainLogic.missileSplit个小弹头
				-- 按照优先级随机 mainLogic.missileSplit 个位置
				local targetPositions = GameExtandPlayLogic:findMissileTarget(mainLogic,missile, mainLogic.missileSplit)
				-- if _G.isLocalDevelopMode then printx(0, #targetPositions,"targetPositions",table.tostring(targetPositions)) end
				theAction.totalAttackPosition = theAction.totalAttackPosition + #targetPositions
				
				if (#targetPositions > 0) then
					for _,toPosition in ipairs(targetPositions) do

						local actionDeleteByMissile = GameBoardActionDataSet:createAs(
							GameActionTargetType.kGameItemAction,
							GameItemActionType.kMissileHitSingle, 
							IntCoord:create(missile.x, missile.y),	-- from positoin
							toPosition,	-- toPosition
							GamePlayConfig_MaxAction_time
							)
						actionDeleteByMissile.completeCallback = missileChildHitCallback
						-- actionDeleteByMissile.delayIndex = i * 12
						mainLogic:addDestroyAction(actionDeleteByMissile)
						mainLogic:setNeedCheckFalling()
					end
				else
					missileChildHitCallback()
				end

			end
		end

		if (theAction.addInfo == "fired" and theAction.allMissileChildActionComplete ) then
			if (theAction.completeCallback ) then
				theAction.completeCallback()
				mainLogic.destroyActionList[actid] = nil 
			end
		end
	end
end

function DestroyItemLogic:runGameItemActionMissileFireView(boardView,theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		theAction.counter = 0

		for i,itemView in ipairs(theAction.missileViews) do
			if itemView and itemView:getGameItemSprite() then
				itemView:getGameItemSprite():fire()
			end
		end

	elseif theAction.actionStatus == GameActionStatus.kRunning then
		if (theAction.counter == 45) then
			theAction.addInfo = "fired"
		end
	end

	theAction.counter = theAction.counter + 1
end

function DestroyItemLogic:runGameItemActionMissileHitSingleView(boardView,theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		-- 发射导弹动画
		theAction.counter = 0

		local fromPos = theAction.ItemPos1
		local toPos = theAction.ItemPos2

		local missilePos = IntCoord:clone(fromPos)
		local itemView = boardView.baseMap[toPos.y][toPos.x]
		if itemView then 
			itemView:playMissileFlyAnimation(missilePos,function()  
				if _G.isLocalDevelopMode then printx(0, "playMissileFlyAnimation callback",toPos.y,toPos.x) end
				-- 在指定位置上播放爆炸动画
				if itemView then 
					itemView:playMissleBombAnimation()
				end
			end)
		end



	elseif theAction.actionStatus == GameActionStatus.kRunning then
		if (theAction.counter == 30) then
			theAction.addInfo = "over"
		end
		theAction.counter = theAction.counter + 1
	end
end

function DestroyItemLogic:runningGameItemActionOlympicIceDec(mainLogic, theAction, actid, actByView)
	if theAction.addInfo == "start" then
		theAction.addInfo = ""
		if mainLogic.PlayUIDelegate then
			local olympicTopNode = mainLogic.PlayUIDelegate.olympicTopNode
			if olympicTopNode then
				local r1 = theAction.ItemPos1.x
				local c1 = theAction.ItemPos1.y
				local item = mainLogic.boardView.baseMap[r1][c1]
				local fromPos = mainLogic.boardView:convertToWorldSpace(item:getBasePosition(c1, r1))
				local colId = c1 + mainLogic.passedCol

				local hasLight = GameExtandPlayLogic:checkHasLightsInCol(mainLogic, c1)
				olympicTopNode:playFlyToHoleEffect(colId, fromPos, not hasLight)
			end
		end
	elseif theAction.addInfo == "over" then
		mainLogic.destroyActionList[actid] = nil
	end
end

function DestroyItemLogic:runGameItemActionOlympicIceDec(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		theAction.addInfo = "start"

		local r1 = theAction.ItemPos1.x;
		local c1 = theAction.ItemPos1.y;
		local item = boardView.baseMap[r1][c1];
		local function onAnimCompleted()
			theAction.addInfo = "over"
		end
		local iceLevel = theAction.addInt
		item:playOlympicIceDecEffect(iceLevel, onAnimCompleted)
	end
end

function DestroyItemLogic:runningGameItemActionOlympicBlockDec(mainLogic, theAction, actid, actByView)
	if theAction.addInfo == "start" then
		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local item = mainLogic.gameItemMap[r][c]
		if theAction.addInt > 1 then
			item.isNeedUpdate = true
		else
			item.isNeedUpdate = true
			-- if mainLogic.gameMode:is(OlympicHorizontalEndlessMode) then
			-- 	mainLogic.gameMode:updateWaitSteps(mainLogic.gameMode.olympicWaitSteps + 3)
			-- end
		end
		theAction.addInfo = "wait"
	elseif theAction.actionStatus == GameActionStatus.kWaitingForDeath then
		mainLogic.destroyActionList[actid] = nil
	end
end

function DestroyItemLogic:runGameItemActionOlympicBlockDec(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.addInfo = "start"
		theAction.actionStatus = GameActionStatus.kRunning
		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local itemView = boardView.baseMap[r][c]
		local function onAnimCompleted()
			-- theAction.addInfo = "over"
		end
		itemView:playOlympicBlockerDecEffect(theAction.addInt, onAnimCompleted)
	end
end

function DestroyItemLogic:runningGameItemActionOlympicLockDec(mainLogic, theAction, actid, actByView)
	if theAction.addInfo == "start" then
		theAction.hasMatched = true
		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local item = mainLogic.gameItemMap[r][c]
		item.isNeedUpdate = true
		theAction.addInfo = "wait"
	elseif theAction.actionStatus == GameActionStatus.kWaitingForDeath then
		if theAction.addInt <= 1 then
			local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
			mainLogic:checkItemBlock(r, c)
			mainLogic:addNeedCheckMatchPoint(r, c)
			mainLogic:setNeedCheckFalling(r, c)
			FallingItemLogic:preUpdateHelpMap(mainLogic)
		end
		mainLogic.destroyActionList[actid] = nil
	end
end

function DestroyItemLogic:runGameItemActionOlympicLockDec(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		theAction.addInfo = "start"
		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local itemView = boardView.baseMap[r][c]
		itemView:playOlympicLockDecEffect(theAction.addInt)

		GamePlayMusicPlayer:playEffect(GameMusicType.kSnowBreak)
	end
end

function DestroyItemLogic:runGameItemActionMaydayBossDie(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning 
		theAction.actionTick = 0

		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local fromItem = boardView.baseMap[r][c]
		local addMoveItems = theAction.addMoveItemPos
		local questionItems = theAction.questionItemPos
		local dripPos = theAction.dripPos
		if not dripPos then dripPos = {} end

		local function dropCallback()
			-- if not theAction.completeCount then theAction.completeCount = 0 end
			-- theAction.completeCount = theAction.completeCount + 1
			-- if theAction.completeCount >= #addMoveItems + #questionItems + #dripPos then
			-- 	theAction.addInfo = 'dropped'
			-- end
		end
		if #addMoveItems == 0 and #questionItems == 0 and #dripPos == 0 then
			dropCallback()
		else
			for k, v in pairs(addMoveItems) do 
				local item = boardView.baseMap[v.r][v.c]
				item:playMaydayBossChangeToAddMove(boardView, fromItem, dropCallback)
			end
			for k, v in pairs(questionItems) do 
				local item = boardView.baseMap[v.r][v.c]
				item:playMaydayBossChangeToAddMove(boardView, fromItem, dropCallback)
			end

			for k, v in pairs(dripPos) do 
				local item = boardView.baseMap[v.r][v.c]
				item:playMaydayBossChangeToAddMove(boardView, fromItem, dropCallback)
			end
		end
		setTimeOut(function () GamePlayMusicPlayer:playEffect(GameMusicType.kWeeklyBossDie) end, 0.60)		
		theAction.addInfo = "dropAction"
		theAction.actionTick = 0
	elseif theAction.addInfo == 'dropped' then
		theAction.addInfo = "dieAction"
		theAction.actionTick = 0
		local function dieCallback()
			-- theAction.addInfo = 'over'
		end
		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local item = boardView.baseMap[r][c]
		item:playMaydayBossDie(self, dieCallback)
	end
end

function DestroyItemLogic:runnningGameItemActionBossDie(mainLogic, theAction, actid, actByView)
	if theAction.actionStatus == GameActionStatus.kRunning  then
		theAction.actionTick = theAction.actionTick + 1

		local function cleanItem(r, c)
			local item = mainLogic.gameItemMap[r][c]
			local board = mainLogic.boardmap[r][c]
			item:cleanAnimalLikeData()
			item.isDead = false
			item.isBlock = false
			item.isNeedUpdate = true
			mainLogic:checkItemBlock(r, c)
		end
		local function isNormal(item)
	        if item.ItemType == GameItemType.kAnimal
	        and item.ItemSpecialType ~= AnimalTypeConfig.kColor
	        and item:isAvailable()
	        and not item:hasLock() 
	        and not item:hasFurball()
	        then
	            return true
	        end
	        return false
	    end

		if theAction.addInfo == "dropAction" and theAction.actionTick == 30 then
			theAction.addInfo = 'dropped'
			local addMoveItems = theAction.addMoveItemPos
			local questionItems = theAction.questionItemPos
			local dripPos = theAction.dripPos
			if not dripPos then dripPos = {} end
			for k, v in pairs(addMoveItems) do
				local item = mainLogic.gameItemMap[v.r][v.c]
				if isNormal(item) then
					item.ItemType = GameItemType.kAddMove
					item:initAddMoveConfig(mainLogic.addMoveBase)
					item.isNeedUpdate = true
				end
			end
			for k, v in pairs(questionItems) do
				local item = mainLogic.gameItemMap[v.r][v.c]
				if isNormal(item) then
					assert(item._encrypt.ItemColorType, "ItemColorType should not be nil")
					item.ItemType = GameItemType.kQuestionMark
					item.isProductByBossDie = true
					mainLogic:onProduceQuestionMark(v.r, v.c)
					-- item:initAddMoveConfig(mainLogic.addMoveBase)
					item.isNeedUpdate = true
				end
			end
			for k, v in pairs(dripPos) do
				local item = mainLogic.gameItemMap[v.r][v.c]
				if isNormal(item) then
					item.ItemType = GameItemType.kDrip
					item._encrypt.ItemColorType = AnimalTypeConfig.kDrip
					item:AddItemStatus( GameItemStatusType.kNone , true )
					item.dripState = DripState.kNormal
					item.isNeedUpdate = true
					mainLogic:addNeedCheckMatchPoint(v.r , v.c)
				end
			end
		elseif theAction.addInfo == "dieAction" and theAction.actionTick == 75 then
			theAction.addInfo = 'over'
			local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
			GameExtandPlayLogic:itemDestroyHandler(mainLogic, r, c)
			cleanItem(r, c)
			cleanItem(r + 1, c)
			cleanItem(r, c+1)
			cleanItem(r+ 1, c+1)
			mainLogic:setNeedCheckFalling()
			FallingItemLogic:preUpdateHelpMap(mainLogic)
		elseif theAction.addInfo == 'over' then
			if theAction.completeCallback then
				theAction.completeCallback()
			end
			mainLogic.destroyActionList[actid] = nil
    	end
	end
end

function DestroyItemLogic:runGameItemActionWeeklyBossDie(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning 
		theAction.actionTick = 0
		theAction.addInfo = "dieAction"
		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local item = boardView.baseMap[r][c]
		item:playWeeklyBoosDie(self)
	end
end

function DestroyItemLogic:runnningGameItemActionWeeklyBossDie(mainLogic, theAction, actid, actByView)
	if theAction.actionStatus == GameActionStatus.kRunning  then
		theAction.actionTick = theAction.actionTick + 1
		local function cleanItem(r, c)
			local item = mainLogic.gameItemMap[r][c]
			local board = mainLogic.boardmap[r][c]
			item:cleanAnimalLikeData()
			item.isDead = false
			item.isBlock = false
			item.isNeedUpdate = true
			mainLogic:checkItemBlock(r, c)
		end

		if theAction.addInfo == "dieAction" and theAction.actionTick == 40 then
			theAction.addInfo = 'over'
			local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
			GameExtandPlayLogic:itemDestroyHandler(mainLogic, r, c)
			cleanItem(r, c)
			cleanItem(r + 1, c)
			cleanItem(r, c+1)
			cleanItem(r+ 1, c+1)
			mainLogic:setNeedCheckFalling()
			FallingItemLogic:preUpdateHelpMap(mainLogic)
		elseif theAction.addInfo == 'over' then
			if theAction.completeCallback then
				theAction.completeCallback()
			end
			mainLogic.destroyActionList[actid] = nil
    	end
	end
end


function DestroyItemLogic:runGameItemActionInactiveSuperCute(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning

		theAction.actionTick = 1

		local function callback()
			-- theAction.addInfo = "over"
		end
		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local item = boardView.baseMap[r][c]
		GameExtandPlayLogic:doAllBlocker195Collect(boardView.gameBoardLogic, r, c, Blocker195CollectType.kSuperCute)
		SquidLogic:checkSquidCollectItem(boardView.gameBoardLogic, r, c, TileConst.kSuperCute)
		item:playSuperCuteInactive(callback)
	end
end


function DestroyItemLogic:runningGameItemActionInactiveSuperCute(mainLogic, theAction, actid)
	if theAction.actionStatus == GameActionStatus.kRunning then
		-- tick
		theAction.actionTick = theAction.actionTick + 1
		if theAction.actionTick == GamePlayConfig_SuperCute_InactiveTick then
			local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y

			local board = mainLogic.boardmap[r][c]
			local item = mainLogic.gameItemMap[r][c]

			board.superCuteState = GameItemSuperCuteBallState.kInactive
			board.superCuteInHit = false
			item.beEffectBySuperCute = false

			mainLogic:checkItemBlock(r, c)
			mainLogic:addNeedCheckMatchPoint(r, c)
			mainLogic.gameMode:checkDropDownCollect(r, c)
			mainLogic:setNeedCheckFalling()

			if item:isActiveTotems() then
				mainLogic:addNewSuperTotemPos(IntCoord:create(r, c))
				mainLogic:tryBombSuperTotems()
			end

			ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_SuperCute, ObstacleFootprintAction.k_BackOff, 1)

			mainLogic.destroyActionList[actid] = nil
		end
	end
end

function DestroyItemLogic:runingGameItemTotemsBombByMatch(mainLogic, theAction, actid)
	mainLogic:tryBombSuperTotems()
	mainLogic.destroyActionList[actid] = nil
end
function DestroyItemLogic:runningGameItemActionDecreaseLotus(mainLogic, theAction, actid)
	--printx( 1 , "   DestroyItemLogic:runningGameItemActionDecreaseLotus   " , actid)
	if theAction.actionStatus == GameActionStatus.kRunning then
		local r1 = theAction.ItemPos1.x
		local c1 = theAction.ItemPos1.y
		local item = mainLogic.gameItemMap[r1][c1]
		local board = mainLogic.boardmap[r1][c1]

		if theAction.addInfo == "start" then
			
			--theAction.originLotusLevel
			if board.lotusLevel <= 0 then
				theAction.addInfo = "over"
			else
				theAction.addInfo = "playAnimation"
				theAction.viewJSQ = 0
				theAction.viewJSQTarget = 0
				theAction.currLotusLevel = board.lotusLevel

				local addScore = 0
				if board.lotusLevel == 3 then
					theAction.viewJSQTarget = 17
					addScore = GamePlayConfigScore.LotusLevel3
				elseif board.lotusLevel == 2 then
					theAction.viewJSQTarget = 13
					addScore = GamePlayConfigScore.LotusLevel2
				elseif board.lotusLevel == 1 then
					theAction.viewJSQTarget = 10
					addScore = GamePlayConfigScore.LotusLevel1
				end

				board.lotusLevel = board.lotusLevel - 1
				if board.lotusLevel < 0 then board.lotusLevel = 0 end
				item.lotusLevel = board.lotusLevel

				mainLogic.lotusEliminationNum = mainLogic.lotusEliminationNum + 1

				----[[
				mainLogic:addScoreToTotal(r1, c1, addScore)
				--]]
			end
			

		elseif theAction.addInfo == "playing" then

			if theAction.viewJSQ == 0 then
				
				if board.lotusLevel == 0 and theAction.currLotusLevel == 1 then
					board.isBlock = false

					mainLogic.currLotusNum = mainLogic.currLotusNum - 1
					mainLogic.destroyLotusNum = mainLogic.destroyLotusNum + 1

					local pos = mainLogic:getGameItemPosInView(r1, c1)
					if mainLogic.PlayUIDelegate.targetType == kLevelTargetType.order_lotus then --内有assert，会报错
						mainLogic.PlayUIDelegate:setTargetNumber(0, 0, mainLogic.currLotusNum, pos)
					end
					ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_Lotus, ObstacleFootprintAction.k_Eliminate, 1)
				end
				board.isNeedUpdate = true
				if item and item.ItemType == GameItemType.kPacman then
					--- 吃豆人造成消除时不马上更新视图，等吃豆人吃完再统一更新
				else
					item.isNeedUpdate = true
				end
				mainLogic:checkItemBlock(r1, c1)

			end

			theAction.viewJSQ = theAction.viewJSQ + 1
			if theAction.viewJSQ >= theAction.viewJSQTarget then
				theAction.addInfo = "over"
			end
		elseif theAction.addInfo == "over" then

			if board.lotusLevel >= 0 and board.lotusLevel <= 2 then

				mainLogic:addNeedCheckMatchPoint(r1, c1)
				mainLogic:setNeedCheckFalling()
			end
			mainLogic.destroyActionList[actid] = nil
		end
	end
	
end

function DestroyItemLogic:runningGameItemActionCrystalStoneDestroy(mainLogic, theAction, actid)
	if theAction.actionStatus == GameActionStatus.kRunning then
		local r1 = theAction.ItemPos1.x
		local c1 = theAction.ItemPos1.y
		local gameItem = mainLogic.gameItemMap[r1][c1]

		if not theAction.hasBreakedLightUp then
			local condition = false
			if gameItem.ItemType == GameItemType.kCrystalStone and gameItem:isCrystalStoneActive() then
				condition = true
			end
			SpecialCoverLogic:SpecialCoverLightUpAtBlocker(mainLogic, r1, c1, 5, condition)
			theAction.hasBreakedLightUp = true
		end

		if theAction.actionDuring == 0 or 
			(theAction.isSpecial and theAction.actionDuring == GamePlayConfig_SpecialBomb_CrystalStone_Destory_Time2) then
			if gameItem.ItemType == GameItemType.kCrystalStone then	 -----动物
				gameItem:cleanAnimalLikeData()
				mainLogic:setNeedCheckFalling()
				if mainLogic.boardmap[r1][c1] and mainLogic.boardmap[r1][c1].lotusLevel and mainLogic.boardmap[r1][c1].lotusLevel > 0 then
					GameExtandPlayLogic:decreaseLotus( mainLogic, r1, c1 , 1)
				end

				if theAction.isSpecial then -- 消除一层冰
					SpecialCoverLogic:SpecialCoverLightUpAtPos(mainLogic, r1, c1, 1, false)
				end

				ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_CrystalStone, ObstacleFootprintAction.k_Attack, 1)
			end

			mainLogic.destroyActionList[actid] = nil
		end
	end
end

function DestroyItemLogic:runGameItemMagicStoneActive(mainLogic, theAction, actid, actByView)
	local r,c  = theAction.ItemPos1.x, theAction.ItemPos1.y
	local stoneActiveAction = GameBoardActionDataSet:createAs(
			GameActionTargetType.kGameItemAction,
			GameItemActionType.kItem_Magic_Stone_Active,
			IntCoord:create(r, c),
			nil,
			GamePlayConfig_MaxAction_time)

	stoneActiveAction.magicStoneLevel = theAction.magicStoneLevel
	stoneActiveAction.targetPos = theAction.targetPos

	mainLogic:addDestructionPlanAction(stoneActiveAction)

	ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_MagicStone, ObstacleFootprintAction.k_Hit, 1)

	mainLogic.destroyActionList[actid] = nil
end

function DestroyItemLogic:runGameItemQuestionMarkProtect(mainLogic, theAction, actid, actByView)
	-- body
	local gameItemMap = mainLogic.gameItemMap
	local leftItem = 0
	for r = 1, #gameItemMap do 
		for c = 1, #gameItemMap[r] do 
			local item = gameItemMap[r][c]
			if item.questionMarkProduct > 0 then

				item.questionMarkProduct = item.questionMarkProduct - 1
				if item.questionMarkProduct == 1 then
					mainLogic:addNeedCheckMatchPoint(r, c)
				end

				if item.questionMarkProduct > 0 then
					leftItem = leftItem + 1
				end
			end
		end
	end
	
	if leftItem == 0 then
		mainLogic.hasQuestionMarkProduct = nil
		mainLogic.destroyActionList[actid] = nil
	end
end

function DestroyItemLogic:runningGameItemActionIceDec(mainLogic, theAction, actid, actByView)
	if theAction.addInfo == "over" then
		mainLogic.destroyActionList[actid] = nil
	end
end

function DestroyItemLogic:runningGameItemActionHoneyDec(mainLogic, theAction, actid, actByView)
	-- body
	if not theAction.hasMatch then
		theAction.hasMatch = true
		local r,c  = theAction.ItemPos1.x, theAction.ItemPos1.y
		mainLogic.gameItemMap[r][c].isNeedUpdate = true
		mainLogic.gameItemMap[r][c].digBlockCanbeDelete = true
		mainLogic:checkItemBlock(r, c)
		mainLogic:addNeedCheckMatchPoint(r, c)
	elseif theAction.actionStatus == GameActionStatus.kWaitingForDeath then
		mainLogic.destroyActionList[actid] = nil
	end
end

function DestroyItemLogic:runningGameItemActionWitchBomb(mainLogic, theAction, actid, actByView)

	if theAction.addInfo == 'over' then

		local interval = theAction.interval
		local intervalFrames = math.floor(interval * 60)
		theAction.frameCount = theAction.frameCount - 1
		if theAction.frameCount <= 0 and theAction.col > 0 then
			-- if _G.isLocalDevelopMode then printx(0, 'theAction.col', theAction.col) end
			local c1, c2 = theAction.col, theAction.col
			local r1, r2 = theAction.rows.r1, theAction.rows.r2
			local item1 = nil
			if mainLogic.gameItemMap[r1] then
				item1 = mainLogic.gameItemMap[r1][c1]
			end
			local item2 = nil
			if mainLogic.gameItemMap[r2] then
				item2 = mainLogic.gameItemMap[r2][c2]
			end
			if item1 and item1.isEmpty == false then
				SpecialCoverLogic:SpecialCoverLightUpAtPos(mainLogic, r1, c1, 1, true)  --可以作用银币
				BombItemLogic:tryCoverByBomb(mainLogic, r1, c1, true, 1)
				SpecialCoverLogic:SpecialCoverAtPos(mainLogic, r1, c1, 3, nil, actid)
			end
			if item2 and item2.isEmpty == false then
				SpecialCoverLogic:SpecialCoverLightUpAtPos(mainLogic, r2, c2, 1, true)  --可以作用银币
				BombItemLogic:tryCoverByBomb(mainLogic, r2, c2, true, 1)
				SpecialCoverLogic:SpecialCoverAtPos(mainLogic, r2, c2, 3, nil, actid) 
			end
			-- 消除冰柱
			local upRow, downRow = r1, r2
			if upRow > downRow then upRow, downRow = downRow, upRow end
			SpecialCoverLogic:specialCoverChainsAtPos(mainLogic, r1, c1)
			SpecialCoverLogic:specialCoverChainsAtPos(mainLogic, r2, c2)
			SpecialCoverLogic:specialCoverChainsAtPos(mainLogic, upRow-1, c1, {ChainDirConfig.kDown})
			SpecialCoverLogic:specialCoverChainsAtPos(mainLogic, downRow+1, c1, {ChainDirConfig.kUp})

			theAction.col = theAction.col - 1
			theAction.frameCount = intervalFrames
		end
		if theAction.col <= 0 then
			-- if _G.isLocalDevelopMode then printx(0, 'action over') end
			mainLogic:resetSpecialEffectList(actid)  --- 特效生命周期中对同一个障碍(boss)的作用只有一次的保护标志位重置
			mainLogic.destroyActionList[actid] = nil
		end
	end
end

function DestroyItemLogic:runningGameItemActionHoneyBottleIncrease(mainLogic, theAction, actid, actByView)
	-- body
	if theAction.actionStatus == GameActionStatus.kWaitingForDeath then
        local r = theAction.ItemPos1.x
		local c = theAction.ItemPos1.y
        local itemData = mainLogic.gameItemMap[r][c]
        itemData.isNeedUpdate = true

		ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_HoneyBottle, ObstacleFootprintAction.k_Hit, theAction.addInt)
		mainLogic.destroyActionList[actid] = nil
	end
end

function DestroyItemLogic:runningGameItemActionMagicLampCharging(mainLogic, theAction, actid, actByView)
	local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
	local item = mainLogic.gameItemMap[r][c]

	-- bonus time不充能
	-- 灰色的不能充能
	if not item or item.ItemType ~= GameItemType.kMagicLamp
	or mainLogic.isBonusTime
	or item.lampLevel == 0 then
		mainLogic.destroyActionList[actid] = nil
		return
	end

	local oldLampLevel = item.lampLevel
	local count = theAction.count
	if item.lampLevel + count >= 5 then
		item.lampLevel = 5
	else
		item.lampLevel = item.lampLevel + count
	end
	ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_MagicLamp, ObstacleFootprintAction.k_Hit, item.lampLevel - oldLampLevel)

	local itemV = mainLogic.boardView.baseMap[r][c]
	itemV:setMagicLampLevel(item.lampLevel)

	-- 加上匹配检查点， 防止出现不三消的情况
	mainLogic:checkItemBlock(r,c)
	mainLogic:setNeedCheckFalling()
	mainLogic:addNeedCheckMatchPoint(r, c)
	mainLogic.destroyActionList[actid] = nil
end

function DestroyItemLogic:runningGameItemActionMonsterJump( mainLogic, theAction, actid, actByView )
	-- body
	if theAction.addInfo == "over" then
		theAction.addInfo = ""
		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local gameItemMap = mainLogic.gameItemMap
		local itemList = {gameItemMap[r][c], gameItemMap[r][c+1], gameItemMap[r+1][c], gameItemMap[r+1][c+1]}
		for k, v in pairs(itemList) do 
			v:cleanAnimalLikeData()
			mainLogic:checkItemBlock(v.y,v.x)
		end
		mainLogic.destroyActionList[actid] = nil
		FallingItemLogic:preUpdateHelpMap(mainLogic)
		ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_BigMonster, ObstacleFootprintAction.k_Eliminate, 1)

		if theAction.completeCallback then 
			theAction.completeCallback()
		end
	end

end

function DestroyItemLogic:runningGameItemActionMaydayBossLossBlood(mainLogic, theAction, actid, actByView)
	if theAction.addInfo == "over" then
		if theAction.completeCallback then
			theAction.completeCallback()
		end

		mainLogic.destroyActionList[actid] = nil
	end
end

function DestroyItemLogic:runningGameItemActionWeeklyBossLossBlood(mainLogic, theAction, actid, actByView)
	if theAction.addInfo == "over" then
		if theAction.completeCallback then
			theAction.completeCallback()
		end

		mainLogic.destroyActionList[actid] = nil
	end
end

function DestroyItemLogic:runningGameItemAction(mainLogic, theAction, actid)
	if theAction.actionType == GameItemActionType.kItemSpecial_Color_ItemDeleted 
		or theAction.actionType == GameItemActionType.kItemSpecial_ColorColor_ItemDeleted then 			----鸟和普通动物交换，引起同色动物的消除
		DestroyItemLogic:runingGameItemSpecialBombColorAction_ItemDeleted(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItem_CollectIngredient then
		DestroyItemLogic:runningGameItem_CollectIngredient(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItem_Mimosa_back then
		DestroyItemLogic:runningGameItemActionMimosaBack(mainLogic, theAction, actid)
	elseif theAction.actionType == GameItemActionType.kItem_KindMimosa_back then
		DestroyItemLogic:runningGameItemActionKindMimosaBack(mainLogic, theAction, actid)
	end
end

function DestroyItemLogic:runViewAction(boardView, theAction)
	if theAction.actionType == GameItemActionType.kItemDeletedByMatch then 			----Match消除
		if theAction.actionStatus == GameActionStatus.kWaitingForStart then
			DestroyItemLogic:runGameItemDeletedByMatchAction(boardView, theAction)
		end
	elseif theAction.actionType == GameItemActionType.kItemCoverBySpecial_Color then  		----cover消除
		if theAction.actionStatus == GameActionStatus.kWaitingForStart then
			DestroyItemLogic:runGameItemActionCoverBySpecial(boardView, theAction)
		end
	elseif theAction.actionType == GameItemActionType.kItemSpecial_Color_ItemDeleted 
		or theAction.actionType == GameItemActionType.kItemSpecial_ColorColor_ItemDeleted then 		----魔力鸟引起的消除
		if theAction.actionStatus == GameActionStatus.kWaitingForStart then
			DestroyItemLogic:runGameItemActionBombSpecialColor_ItemDeleted(boardView, theAction)
		end
	elseif theAction.actionType == GameItemActionType.kItem_CollectIngredient then
		if theAction.addInfo == "Pass" then
			DestroyItemLogic:runGameItemActionCollectIngredient(boardView, theAction)
		end
	elseif theAction.actionType == GameItemActionType.kItemMatchAt_SnowDec then 		----产生雪块消除特效
		if theAction.actionStatus == GameActionStatus.kWaitingForStart then
			DestroyItemLogic:runGameItemActionSnowDec(boardView, theAction)
		else
			local r1 = theAction.ItemPos1.x
			local c1 = theAction.ItemPos1.y
			if boardView.baseMap[r1][c1].itemSprite[ItemSpriteType.kSnowShow]~= nil
				and boardView.baseMap[r1][c1].itemSprite[ItemSpriteType.kSnowShow]:getParent() then ----已经被正常添加了父节点，删除特殊效果
				boardView.baseMap[r1][c1].itemSprite[ItemSpriteType.kSnowShow] = nil
			end
		end
	elseif theAction.actionType == GameItemActionType.kItemMatchAt_VenowDec then
		if theAction.actionStatus == GameActionStatus.kWaitingForStart then
			DestroyItemLogic:runGameItemActionVenomDec(boardView, theAction)
		end
	elseif theAction.actionType ==  GameItemActionType.kItem_Furball_Grey_Destroy then
		if theAction.actionStatus == GameActionStatus.kWaitingForStart then
			DestroyItemLogic:runGameItemActionGreyFurballDestroy(boardView, theAction)
		elseif theAction.actionStatus == GameActionStatus.kRunning then
			DestroyItemLogic:runningGameItemActionGreyFurballDestroy(boardView, theAction)	
		end
	elseif theAction.actionType == GameItemActionType.kItemMatchAt_LockDec then 		----产生牢笼消除特效
		if theAction.actionStatus == GameActionStatus.kWaitingForStart then
			DestroyItemLogic:runGameItemActionLockDec(boardView, theAction)
		else
			local r1 = theAction.ItemPos1.x;
			local c1 = theAction.ItemPos1.y;
			if boardView.baseMap[r1][c1].itemSprite[ItemSpriteType.kLockShow]~= nil
				and boardView.baseMap[r1][c1].itemSprite[ItemSpriteType.kLockShow]:getParent() then ----已经被正常添加了父节点，删除特殊效果
				boardView.baseMap[r1][c1].itemSprite[ItemSpriteType.kLockShow] = nil;
			end
		end
	elseif theAction.actionType == GameItemActionType.kItem_Roost_Upgrade then
		if theAction.actionStatus == GameActionStatus.kWaitingForStart then
			DestroyItemLogic:runGameItemActionRoostUpgrade(boardView, theAction)
		end
	elseif theAction.actionType == GameItemActionType.kItem_DigGroundDec then
		DestroyItemLogic:runGameItemViewDigGroundDec(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_DigJewleDec then 
		DestroyItemLogic:runGameItemViewDigJewelDec(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_randomPropDec then 
		DestroyItemLogic:runGameItemViewRandomPropDec(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_Bottle_Blocker_Explode then 
		DestroyItemLogic:runGameItemViewBottleBlockerDec(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_Monster_frosting_dec then 
		if theAction.actionStatus == GameActionStatus.kWaitingForStart then
			DestroyItemLogic:runGameItemViewMonsterFrostingDec(boardView, theAction)
		end
	elseif theAction.actionType == GameItemActionType.kItem_chestSquare_part_dec then 
		DestroyItemLogic:runGameItemViewChestSquarePartDec(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_Black_Cute_Ball_Dec then
		if theAction.actionStatus == GameActionStatus.kWaitingForStart then
			DestroyItemLogic:runGameItemViewBlackCuteBallDec(boardView, theAction)
		end
	elseif theAction.actionType == GameItemActionType.kItem_Mimosa_back then
		DestroyItemLogic:runGameItemActionMimosaBack(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_KindMimosa_back then
		DestroyItemLogic:runGameItemActionKindMimosaBack(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_Mayday_Boss_Loss_Blood then
		DestroyItemLogic:runGameItemActionBossLossBlood(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_Weekly_Boss_Loss_Blood then
		DestroyItemLogic:runGameItemActionWeeklyBossLossBlood(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_Wukong_Charging then
		DestroyItemLogic:runGameItemViewActionWukongCharging(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_Magic_Lamp_Charging then
		theAction.actionStatus = GameActionStatus.kRunning
	elseif theAction.actionType == GameItemActionType.kItem_WitchBomb then
		DestroyItemLogic:runGameItemActionWitchBomb(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_Honey_Bottle_increase then 
		DestroyItemLogic:runGameItemActionHoneyBottleInc(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItemDestroy_HoneyDec then
		DestroyItemLogic:runGameItemActionHoneyDec(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_Sand_Clean then
		DestroyItemLogic:runGameItemActionSandClean(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItemMatchAt_IceDec then
		DestroyItemLogic:runGameItemActionIceDec(boardView, theAction)	
	elseif theAction.actionType == GameItemActionType.kItem_Monster_Jump then
		DestroyItemLogic:runGameItemActionMonsterJump( boardView, theAction )
	elseif theAction.actionType == GameItemActionType.kItem_ChestSquare_Jump then
		DestroyItemLogic:runGameItemActionChestSquareJump( boardView, theAction )
	elseif theAction.actionType == GameItemActionType.kItemSpecial_CrystalStone_Destroy then
		DestroyItemLogic:runGameItemActionCrystalStoneDestroy( boardView, theAction )
	elseif theAction.actionType == GameItemActionType.kItem_Totems_Change then
		DestroyItemLogic:runGameItemTotemsChangeAction(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_SuperTotems_Bomb_By_Match then
	elseif theAction.actionType == GameItemActionType.kItem_Decrease_Lotus then
		DestroyItemLogic:runGameItemDecreaseLotusAction(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_SuperCute_Inactive then
		DestroyItemLogic:runGameItemActionInactiveSuperCute(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_Mayday_Boss_Die then
		DestroyItemLogic:runGameItemActionMaydayBossDie(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_Weekly_Boss_Die then
		DestroyItemLogic:runGameItemActionWeeklyBossDie(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItemMatchAt_OlympicLockDec then
		DestroyItemLogic:runGameItemActionOlympicLockDec(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItemMatchAt_OlympicBlockDec then
		DestroyItemLogic:runGameItemActionOlympicBlockDec(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItemMatchAt_Olympic_IceDec then
		DestroyItemLogic:runGameItemActionOlympicIceDec(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kMissileHit then
		DestroyItemLogic:runGameItemActionMissileHitView(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItemMatchAt_BlockerCoverMaterialDec then
		DestroyItemLogic:runGameItemActionBlockerCoverMaterialDec(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_Blocker_Cover_Dec then
		DestroyItemLogic:runGameItemActionBlockerCoverDec(boardView, theAction) 
	elseif theAction.actionType == GameItemActionType.kMissileFire then
		DestroyItemLogic:runGameItemActionMissileFireView(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kMissileHitSingle then
		DestroyItemLogic:runGameItemActionMissileHitSingleView(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_TangChicken_Destroy then
		DestroyItemLogic:runGameItemActionTangChickenView(boardView, theAction)			
	elseif theAction.actionType == GameItemActionType.kEliminateMusic then
		DestroyItemLogic:runGameItemActionPlayEliminateMusic(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_Blocker195_Dec then
		DestroyItemLogic:runGameItemActionBlocker195Dec(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_ColorFilterB_Dec then
		DestroyItemLogic:runGameItemActionColorFilterBDec(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_Blocker206_Dec then
		DestroyItemLogic:runGameItemActionBlocker206Dec(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_Blocker207_Dec then
		DestroyItemLogic:runGameItemActionBlocker207Dec(boardView, theAction)			
	elseif theAction.actionType == GameItemActionType.kItem_Chameleon_transform then
		DestroyItemLogic:runGameItemActionChameleonTransformView(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_pacman_eatTarget then
		DestroyItemLogic:runGameItemActionPacmanEatTargetView(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_pacman_blow then
		DestroyItemLogic:runGameItemActionPacmanBlowView(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_pacmansDen_generate then
		DestroyItemLogic:runGameItemActionPacmanGenerateView(boardView, theAction)
    elseif theAction.actionType == GameItemActionType.kItem_Turret_upgrade then
		DestroyItemLogic:runGameItemActionTurretUpgradeView(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_MoleWeekly_Magic_Tile_Blast then
		DestroyItemLogic:runGameItemActionMoleWeeklyMagicTileBlastView(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_MoleWeekly_Boss_Cloud_Die then
		DestroyItemLogic:runGameItemActionMoleWeeklyBossCloudDieView(boardView, theAction)
    elseif theAction.actionType == GameItemActionType.kItem_YellowDiamondDec then
		DestroyItemLogic:runGameItemViewYellowDiamond(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_ghost_move then
		DestroyItemLogic:runGameItemActionGhostMoveView(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_ghost_collect then
		DestroyItemLogic:runGameItemActionGhostCollectView(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_SunFlask_Blast then
		DestroyItemLogic:runGameItemActionSunFlaskBlastView(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_SunFlower_Blast then
		DestroyItemLogic:runGameItemActionSunFlowerBlastView(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_Squid_Collect then
		DestroyItemLogic:runGameItemActionSquidCollectView(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_Squid_Run then
		DestroyItemLogic:runGameItemActionSquidRunView(boardView, theAction)
    elseif theAction.actionType == GameItemActionType.kItem_WanSheng_increase then 
		DestroyItemLogic:runGameItemActionWanShengInc(boardView, theAction)
    elseif theAction.actionType == GameItemActionType.kItem_SpringFestival2019_Skill1 then 
		DestroyItemLogic:runGameItemActionSprintFestival2019Skill1View(boardView, theAction)
    elseif theAction.actionType == GameItemActionType.kItem_SpringFestival2019_Skill2 then 
		DestroyItemLogic:runGameItemActionSprintFestival2019Skill2View(boardView, theAction)
    elseif theAction.actionType == GameItemActionType.kItem_SpringFestival2019_Skill3 then 
		DestroyItemLogic:runGameItemActionSprintFestival2019Skill3View(boardView, theAction)
    elseif theAction.actionType == GameItemActionType.kItem_SpringFestival2019_Skill4 then 
		DestroyItemLogic:runGameItemActionSprintFestival2019Skill4View(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItemMatchAt_ApplyMilk then
		DestroyItemLogic:runningGameItemActionApplyMilkView(boardView, theAction)
	end
end

function DestroyItemLogic:runGameItemActionBlocker207Dec(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning

		theAction.addInfo = "checkChargeList"

	else

		local r1 = theAction.ItemPos1.x
		local c1 = theAction.ItemPos1.y
		local item = boardView.baseMap[r1][c1]
		local fromItemPos = ccp(r1 , c1)

		if theAction.addInfo == "flyEff" then

			if theAction.chargeList and #theAction.chargeList > 0 then
				for i = 1 , #theAction.chargeList do
					local pos = theAction.chargeList[i]
					local item = boardView.baseMap[pos.r][pos.c];
					local itemData = boardView.gameBoardLogic.gameItemMap[pos.r][pos.c]
					itemData.needKeys = itemData.needKeys - 1
					printx( 1 , "DestroyItemLogic:runGameItemActionBlocker207Dec  " , pos.r , pos.c )
					item:playBlocker206ChargeAnimation(fromItemPos)
				end
			end

			theAction.addInfo = "waitingForFly"
			theAction.jsq = 0
		elseif theAction.addInfo == "waitingForFly" then
			theAction.jsq = theAction.jsq + 1
			if theAction.jsq >= 50 then
				theAction.addInfo = "over"
				theAction.jsq = 0
			end
		end

	end
end

function DestroyItemLogic:runGameItemActionBlocker206Dec(boardView, theAction)
	--printx(1 , "DestroyItemLogic:runGameItemActionBlocker206Dec   ")
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning

		theAction.addInfo = "waitingForFly"
		theAction.jsq = 0
	else
		if theAction.addInfo == "waitingForFly" then
			theAction.jsq = theAction.jsq + 1
			if theAction.jsq >= 70 then
				theAction.addInfo = "checkNeedUnlockBlocker"
				theAction.jsq = 0
			end
		elseif theAction.addInfo == "playUnlock" then

			printx(1 , "DestroyItemLogic:runGameItemActionBlocker206Dec   playUnlock  #theAction.nextGroup " , #theAction.nextGroup )
			if theAction.nextGroup and #theAction.nextGroup > 0 then
				for i = 1 , #theAction.nextGroup do
					local pos = theAction.nextGroup[i]
					local item = boardView.baseMap[pos.r][pos.c];
					item:playBlocker206ActiveAnimation()
				end
			end

			if theAction.unlockGroup and #theAction.unlockGroup > 0 then
				for i = 1 , #theAction.unlockGroup do
					local pos = theAction.unlockGroup[i]
					local item = boardView.baseMap[pos.r][pos.c];
					item:playBlocker206DestroyAnimation()
				end
			end

			theAction.addInfo = "waitingForUnlock"
			theAction.jsq = 0

		elseif theAction.addInfo == "waitingForUnlock" then
			theAction.jsq = theAction.jsq + 1
			if theAction.jsq >= 60 then
				theAction.addInfo = "doUnlock"
			end
		end
	end
end

function DestroyItemLogic:runGameItemActionColorFilterBDec(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		local oldLevel = theAction.oldLevel
		local newLevel = theAction.newLevel
		local r1 = theAction.ItemPos1.x
		local c1 = theAction.ItemPos1.y
		local item = boardView.baseMap[r1][c1]
		local colorIndex = theAction.addInt

		item:playColorFilterBDec(oldLevel)
		theAction.jsq = 0
		theAction.maxJsp = 25

		if newLevel <= 0 then 
			item:playColorFilterBDisappear()
		end

		theAction.addInfo = "waitingForAnimation"
	elseif theAction.addInfo == "waitingForAnimation" then 
		theAction.jsq = theAction.jsq + 1
		local newLevel = theAction.newLevel
		if newLevel <= 0 and theAction.jsq == theAction.maxJsp - 5 then 
			local r1 = theAction.ItemPos1.x
			local c1 = theAction.ItemPos1.y
			local item = boardView.baseMap[r1][c1]
			item:showFilterBHideLayers()
		end
		if theAction.jsq >= theAction.maxJsp then
			theAction.addInfo = "over"
		end
	end
end

function DestroyItemLogic:runGameItemActionBlocker195Dec(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		local r1 = theAction.ItemPos1.x;
		local c1 = theAction.ItemPos1.y;
		local item = boardView.baseMap[r1][c1];
		item:playBlocker195DestroyAnimation()
		SpecialCoverLogic:SpecialCoverLightUpAtPos(boardView.gameBoardLogic, r1, c1, 1, true)
	end
end

function DestroyItemLogic:runGameItemActionPlayEliminateMusic(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning

		local music = theAction.music
		if music then
			GamePlayMusicPlayer:playEffect(music)
		end
	end
end

function DestroyItemLogic:runGameItemActionBlockerCoverDec(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		local r1 = theAction.ItemPos1.x;
		local c1 = theAction.ItemPos1.y;
		local item = boardView.baseMap[r1][c1];

		local maxJsqs = {60, 60, 60}
		theAction.addInfo = "waitingForAnimation"
		theAction.jsq = 0
		theAction.maxJsq = maxJsqs[theAction.oldLevel]

		item:decreaseBlockerCover(theAction.newLevel)
	else
		if theAction.addInfo == "waitingForAnimation" then
			
			theAction.jsq = theAction.jsq + 1

			if theAction.jsq >= theAction.maxJsq then
				theAction.addInfo = "over"
			end
		end
	end
end

function DestroyItemLogic:runGameItemActionBlockerCoverMaterialDec(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		local r1 = theAction.ItemPos1.x;
		local c1 = theAction.ItemPos1.y;
		local item = boardView.baseMap[r1][c1];

		if theAction.newLevel == -1 then
			theAction.addInfo = "over"
			item:playBlockerCoverMaterialWait()
		else
			local maxJsqs = {46, 46, 76}
			theAction.addInfo = "waitingForAnimation"
			theAction.jsq = 0
			theAction.maxJsq = maxJsqs[theAction.oldLevel]
			item:playBlockerCoverMaterialDecEffect(theAction.newLevel)
		end
	else
		if theAction.addInfo == "waitingForAnimation" then
			
			theAction.jsq = theAction.jsq + 1

			if theAction.jsq >= theAction.maxJsq then
				theAction.addInfo = "over"
			end
		end
	end
end

function DestroyItemLogic:runGameItemActionTangChickenView(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local itemView = boardView.baseMap[r][c]

		local gameBoardLogic = boardView.gameBoardLogic
		local function playCollectAnim( fromPos,playEffect )
			gameBoardLogic.gameMode:playCollectEffect()
			-- gameBoardLogic.gameMode:playCollectAnim(fromPos,playEffect,nil,0.3)
		end
		local toPos = gameBoardLogic.gameMode:getCollectPosition()
		itemView:playTangChickenDisappear(playCollectAnim, toPos, theAction.tangChickenNum)	

		-- local function playMusic()
		-- 	GamePlayMusicPlayer:getInstance():playEffect(GameMusicType.kSpring2017Hit)
		-- end
		-- setTimeOut(playMusic, 0.15)
	end
end

function DestroyItemLogic:runGameItemDecreaseLotusAction(boardView, theAction)
	--printx( 1 , "  DestroyItemLogic:runGameItemDecreaseLotusAction  " , theAction.actionStatus , theAction.addInfo)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		theAction.addInfo = "start"
	elseif theAction.addInfo == "playAnimation" then
		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local itemView = boardView.baseMap[r][c]

		if itemView then
			itemView:playLotusAnimation( theAction.currLotusLevel , "out" )
			if theAction.currLotusLevel == 3 then
				itemView:setLotusHoldItemVisible(true)
			end
		end
		theAction.addInfo = "playing"
	end
end

function DestroyItemLogic:runGameItemTotemsChangeAction(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning

		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local itemView = boardView.baseMap[r][c]

		itemView:playTotemsChangeToActive()
	end
end

function DestroyItemLogic:runingGameItemTotemsChangeAction(mainLogic, theAction, actid)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local item = mainLogic.gameItemMap[r][c]

		if item and item.ItemType == GameItemType.kTotems then
			item.totemsState = GameItemTotemsState.kActive
			
			-- mainLogic:checkItemBlock(r, c)
			-- FallingItemLogic:stopFCFallingByBlock(mainLogic, r, c)
			-- FallingItemLogic:preUpdateHelpMap(mainLogic)
			
			mainLogic:addNewSuperTotemPos(IntCoord:create(r, c))

			if theAction.isBomb then
				mainLogic:tryBombSuperTotems()
			end
		end
	elseif theAction.actionStatus == GameActionStatus.kRunning then
		mainLogic.destroyActionList[actid] = nil
	end
end

function DestroyItemLogic:runGameItemViewActionWukongCharging( boardView, theAction )

	if not theAction.viewJSQ then theAction.viewJSQ = 0 end
	theAction.viewJSQ = theAction.viewJSQ + 1
	local r = theAction.ItemPos1.x
	local c = theAction.ItemPos1.y
	local itemView = boardView.baseMap[r][c]

	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		theAction.addInfo = "start"
		itemView:changeWukongState(TileWukongState.kOnHit)
	elseif theAction.actionStatus == GameActionStatus.kRunning then

		if theAction.addInfo == "playAnimation" then
			
			local fromPositions = theAction.fromPosition
			if fromPositions and #fromPositions > 0 then

				for k,v in pairs(fromPositions) do
					
					local localPosition = v
					local targetPosition = ccp(0,0)
					if itemView.itemSprite[ItemSpriteType.kItemShow] then
						targetPosition = itemView.itemSprite[ItemSpriteType.kItemShow]:convertToWorldSpace(ccp(0,0))
					end
					local sprite = Sprite:createWithSpriteFrameName("wukong_charging_eff")
					sprite:setAnchorPoint(ccp(0.5, 0.5))
					sprite:setPosition(ccp(localPosition.x, localPosition.y))
					--sprite:setScale(math.random()*0.6 + 0.7)
					sprite:setOpacity(80)
					local moveTime = 0.45 + math.random() * 0.64
					local moveTo = CCMoveTo:create(moveTime, ccp(targetPosition.x, targetPosition.y - 28 ))
					local function onMoveFinished( ) sprite:removeFromParentAndCleanup(true) end
					--local moveIn = CCEaseElasticOut:create(CCMoveTo:create(0.25, ccp(x, y)))
					local array = CCArray:create()
					--array:addObject(CCSpawn:createWithTwoActions(moveIn, CCFadeIn:create(0.25)))
					array:addObject(CCEaseSineOut:create(moveTo))
					array:addObject(CCCallFunc:create(onMoveFinished))
					array:addObject(CCFadeTo:create(0.25 , 0))
					sprite:runAction(CCSequence:create(array))
					sprite:runAction(CCFadeTo:create(0.2 , 255))

					local scene = Director:sharedDirector():getRunningScene()
					scene:addChild(sprite)
				end
			end
			
			theAction.addInfo = "wait"
		end

		if theAction.viewJSQ == 50 then
			itemView:setWukongProgress( theAction.wukongProgressCurr ,  theAction.wukongProgressTotal )
		end

		if theAction.viewJSQ == 100 then
			theAction.addInfo = "onFin"
		end
		if theAction.addInfo == "onChangeState" then
			if theAction.viewState == TileWukongState.kOnActive then
				itemView:changeWukongState(TileWukongState.kOnActive)
			else
				itemView:changeWukongState(TileWukongState.kNormal)
			end

			theAction.addInfo = "over"
		end
	end
end

function DestroyItemLogic:runningGameItemActionWukongCharging(mainLogic, theAction, actid, actByView)

	if theAction.actionStatus == GameActionStatus.kRunning then

		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local item = mainLogic.gameItemMap[r][c]

		if theAction.addInfo == "start" then
			item.wukongState = TileWukongState.kOnHit

			local newValue = item.wukongProgressCurr + baseWukongChargingValue + theAction.count
			if newValue > item.wukongProgressTotal then
				newValue = item.wukongProgressTotal
			end

			theAction.wukongProgressCurr = newValue
			theAction.wukongProgressTotal = item.wukongProgressTotal

			item.wukongProgressCurr = newValue

			theAction.addInfo = "playAnimation"

		elseif theAction.addInfo == "onFin" then
			
			--item.wukongProgressCurr = item.wukongProgressCurr + baseWukongChargingValue + theAction.count
			if item.wukongProgressCurr == item.wukongProgressTotal then
				--item.wukongProgressCurr = item.wukongProgressTotal
				theAction.viewState = TileWukongState.kOnActive
				item.wukongState = TileWukongState.kOnActive
			else
				theAction.viewState = item.wukongState
				item.wukongState = TileWukongState.kNormal
			end
			
			theAction.addInfo = "onChangeState"
		elseif theAction.addInfo == "over" then
			-- 加上匹配检查点， 防止出现不三消的情况
			mainLogic:checkItemBlock(r,c)
			mainLogic:setNeedCheckFalling()
			mainLogic:addNeedCheckMatchPoint(r, c)
			mainLogic.destroyActionList[actid] = nil
		end
	end
end

function DestroyItemLogic:runGameItemActionCrystalStoneDestroy( boardView, theAction )
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning

		local r = theAction.ItemPos1.x
		local c = theAction.ItemPos1.y
		local itemView = boardView.baseMap[r][c]
		local function finishCallback()
			-- theAction.addInfo = "over"
		end

		local color = theAction.addInt
		local isSpecial = theAction.isSpecial
		itemView:playCrystalStoneDisappear(isSpecial, finishCallback)
	end
end


function DestroyItemLogic:runningGameItemActionChestSquareJump( mainLogic, theAction, actid, actByView )
	if theAction.addInfo == "over" then
		theAction.addInfo = ""
		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local gameItemMap = mainLogic.gameItemMap
		
		GameExtandPlayLogic:itemDestroyHandler(mainLogic, r, c)
		
		local itemList = {gameItemMap[r][c], gameItemMap[r][c+1], gameItemMap[r+1][c], gameItemMap[r+1][c+1]}
		for k, v in pairs(itemList) do 
			v:cleanAnimalLikeData()
			mainLogic:checkItemBlock(v.y,v.x)
		end

		-- 添加大招能量
		if mainLogic.theGamePlayType == 12  and not  theAction.hitBySpringBomb then -- and not isFromSpringBomb
			mainLogic:chargeFirework(10, r, c)
		end

		mainLogic.destroyActionList[actid] = nil
		FallingItemLogic:preUpdateHelpMap(mainLogic)

		if theAction.completeCallback then 
			theAction.completeCallback()
		end
	end

end

function DestroyItemLogic:runGameItemActionChestSquareJump( boardView, theAction )
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		local r = theAction.ItemPos1.x
		local c = theAction.ItemPos1.y
		local itemView = boardView.baseMap[r][c]

		local function finishCallback( ... )
		end

		theAction.addInfo = "watingForAnimation"
		theAction.jsq = 0
		itemView:playChesteSquareJumpAnimation(finishCallback)
	else
		theAction.jsq = theAction.jsq + 1
		if theAction.addInfo == "watingForAnimation" then
			if theAction.jsq == 25 then
				theAction.addInfo = "over"
			end
		end
	end
end

function DestroyItemLogic:runGameItemActionMonsterJump( boardView, theAction )
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		local r = theAction.ItemPos1.x
		local c = theAction.ItemPos1.y
		local itemView = boardView.baseMap[r][c]
		local function jumpCallback( ... )
			boardView:viberate()
		end

		local function finishCallback( ... )
			--theAction.addInfo = "over"
		end
		theAction.addInfo = "watingForAnimation"
		theAction.jsq = 0
		itemView:playMonsterJumpAnimation(jumpCallback, finishCallback)
	else
		theAction.jsq = theAction.jsq + 1
		if theAction.addInfo == "watingForAnimation" then
			if theAction.jsq >= 110 then
				theAction.addInfo = "over"
			end
		end
	end
end

-----播放消除冰层的动画------
function DestroyItemLogic:runGameItemActionIceDec(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning

		local r1 = theAction.ItemPos1.x;
		local c1 = theAction.ItemPos1.y;
		local item = boardView.baseMap[r1][c1];
		local function onAnimCompleted()
			theAction.addInfo = "over"
		end
		item:playIceDecEffect(theAction.addInt, onAnimCompleted)
		GamePlayMusicPlayer:playEffect(GameMusicType.kIceBreak)

		ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_Light, ObstacleFootprintAction.k_Hit, 1)
		if theAction.addInt == 1 then
			ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_Light, ObstacleFootprintAction.k_Eliminate, 1)
		end
	end
end

function DestroyItemLogic:runGameItemActionSandClean(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning

		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local item = boardView.baseMap[r][c]

		local function onAnimCompleted()
			theAction.addInfo = "over"
		end

		GameExtandPlayLogic:doAllBlocker195Collect(boardView.gameBoardLogic, r, c, Blocker195CollectType.kSand)
		SquidLogic:checkSquidCollectItem(boardView.gameBoardLogic, r, c, TileConst.kSand)
		item:playSandClean(onAnimCompleted)
	end
end

function DestroyItemLogic:runningGameItemActionCleanSand(mainLogic, theAction, actid, actByView)
	if theAction.addInfo == "over" then
		mainLogic.destroyActionList[actid] = nil
	end
end

function DestroyItemLogic:runGameItemActionHoneyDec(boardView, theAction)
	-- body
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		local r = theAction.ItemPos1.x
		local c = theAction.ItemPos1.y
		GameExtandPlayLogic:doAllBlocker195Collect(boardView.gameBoardLogic, r, c, Blocker195CollectType.kHoney)
		SquidLogic:checkSquidCollectItem(boardView.gameBoardLogic, r, c, TileConst.kHoney)
		local itemView = boardView.baseMap[r][c]
		itemView:playHoneyDec(theAction.origLevel)
	end
end

function DestroyItemLogic:runGameItemActionHoneyBottleInc(boardView, theAction)
	-- body
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		local r = theAction.ItemPos1.x
		local c = theAction.ItemPos1.y
		local itemView = boardView.baseMap[r][c]
		itemView:playHoneyBottleDec(theAction.addInt)
	end
end

function DestroyItemLogic:runGameItemActionWitchBomb(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning		
	
		theAction.addInfo = 'started'
		theAction.frameCount = math.ceil(theAction.startDelay * 60) -- 女巫飞到第九列的等待时间
		-- if _G.isLocalDevelopMode then printx(0, 'start', theAction.frameCount) end

	elseif theAction.actionStatus == GameActionStatus.kRunning then
		if theAction.addInfo == 'started' then
			theAction.frameCount = theAction.frameCount - 1
			if theAction.frameCount <= 0 then
				theAction.frameCount = 0 -- 爆炸立即开始
				-- if _G.isLocalDevelopMode then printx(0, 'started', theAction.frameCount) end
				theAction.addInfo = "over"
			end
		end
	end
end

function DestroyItemLogic:runGameItemActionBossLossBlood(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		local function callback( ... )
			-- body
			theAction.addInfo = "over"
		end

		local r = theAction.ItemPos1.x
		local c = theAction.ItemPos1.y
		local itemView = boardView.baseMap[r][c]
		itemView:updateBossBlood(theAction.addInt, true, theAction.debug_string)
		itemView:playBossHit(boardView)
		callback()
	end
end

function DestroyItemLogic:runGameItemActionWeeklyBossLossBlood(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		local function callback()
			theAction.addInfo = "over"
		end

		local r = theAction.ItemPos1.x
		local c = theAction.ItemPos1.y
		local itemView = boardView.baseMap[r][c]
		itemView:playWeeklyBossHit(boardView, theAction.addInt)
		callback()
	end
end

function DestroyItemLogic:runGameItemDeletedByMatch(mainLogic, theAction, actid)
	if theAction.actionStatus == GameActionStatus.kRunning and not theAction.isStarted then
		theAction.isStarted = true

		local r1 = theAction.ItemPos1.x
		local c1 = theAction.ItemPos1.y
		GameExtandPlayLogic:itemDestroyHandler(mainLogic, r1, c1)
	end

	if theAction.actionStatus == GameActionStatus.kWaitingForDeath then
		local r1 = theAction.ItemPos1.x
		local c1 = theAction.ItemPos1.y
		local gameItem = mainLogic.gameItemMap[r1][c1]
		if gameItem.ItemType ~= GameItemType.kDrip then
			gameItem:cleanAnimalLikeData()
		end
		mainLogic:setNeedCheckFalling()
		mainLogic.destroyActionList[actid] = nil
	end
end

function DestroyItemLogic:runGameItemSpecialCoverAction(mainLogic, theAction, actid)
	if theAction.actionStatus == GameActionStatus.kRunning and not theAction.isStarted then
		theAction.isStarted = true
		local r1 = theAction.ItemPos1.x
		local c1 = theAction.ItemPos1.y
		GameExtandPlayLogic:itemDestroyHandler(mainLogic, r1, c1)
	end

	if theAction.actionStatus == GameActionStatus.kWaitingForDeath then
		if theAction.addInfo == "kAnimal" then
			local r1 = theAction.ItemPos1.x
			local c1 = theAction.ItemPos1.y
			local gameItem = mainLogic.gameItemMap[r1][c1]

			if gameItem.ItemType == GameItemType.kAnimal 		-----动物
				and not gameItem:hasFurball()
				then
				gameItem:cleanAnimalLikeData()
				mainLogic:setNeedCheckFalling()
			end
				
			mainLogic.destroyActionList[actid] = nil
		end
	end
end

function DestroyItemLogic:runGameItemSpecialBombColorAction_ItemDeleted(mainLogic, theAction, actid)
	if theAction.actionStatus == GameActionStatus.kWaitingForDeath then
		local r1 = theAction.ItemPos1.x
		local c1 = theAction.ItemPos1.y
		local r2 = theAction.ItemPos2.x
		local c2 = theAction.ItemPos2.y
		local gameItem = mainLogic.gameItemMap[r1][c1]
		local gameItem2 = mainLogic.gameItemMap[r2][c2]
		if r1 == r2 and c1 == c2 then
			if _G.isLocalDevelopMode then printx(0, "Error!!! runGameItemSpecialBombColorAction_ItemDeleted deleted self") end
		else
			GameExtandPlayLogic:doAllBlocker211Collect(mainLogic, r1, c1, gameItem._encrypt.ItemColorType, false, 1)
			GameExtandPlayLogic:itemDestroyHandler(mainLogic, r1, c1)
			gameItem:cleanAnimalLikeData()
			gameItem2.isEmpty = false
		end

		mainLogic:setNeedCheckFalling()
		mainLogic.destroyActionList[actid] = nil
	end
end

function DestroyItemLogic:runGameItemSpecialBombColorColorAction_ItemDeleted(mainLogic, theAction, actid)
	if theAction.actionStatus == GameActionStatus.kWaitingForDeath then
		local r1 = theAction.ItemPos1.x
		local c1 = theAction.ItemPos1.y
		local r2 = theAction.ItemPos2.x
		local c2 = theAction.ItemPos2.y
		local gameItem = mainLogic.gameItemMap[r1][c1]
		local gameItem2 = mainLogic.gameItemMap[r2][c2]

		GameExtandPlayLogic:itemDestroyHandler(mainLogic, r1, c1)
		gameItem:cleanAnimalLikeData()

		mainLogic:setNeedCheckFalling()
		mainLogic.destroyActionList[actid] = nil
	end
end

function DestroyItemLogic:runGameItemSpecialSnowDec(mainLogic, theAction, actid)
	if theAction.actionStatus == GameActionStatus.kRunning then
		if theAction.addInfo == "update" then
			theAction.addInfo = ""
			mainLogic.gameItemMap[theAction.ItemPos1.x][theAction.ItemPos1.y].isNeedUpdate = true
		end
	elseif theAction.actionStatus == GameActionStatus.kWaitingForDeath then
		mainLogic.gameItemMap[theAction.ItemPos1.x][theAction.ItemPos1.y].isNeedUpdate = true
		mainLogic.boardmap[theAction.ItemPos1.x][theAction.ItemPos1.y].isNeedUpdate = true
		ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_Snow, ObstacleFootprintAction.k_Hit, theAction.hitTimes)
		--雪花只有在爆完最后一层后才需要检测
		if theAction.addInt == 1 then
			mainLogic:checkItemBlock(theAction.ItemPos1.x, theAction.ItemPos1.y)
			mainLogic:setNeedCheckFalling()
			ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_Snow, ObstacleFootprintAction.k_Eliminate, 1)
		end
		mainLogic.destroyActionList[actid] = nil
	end
end

function DestroyItemLogic:runGameItemSpecialVenomDec(mainLogic, theAction, actid)
	if theAction.actionStatus == GameActionStatus.kWaitingForDeath then
		mainLogic:checkItemBlock(theAction.ItemPos1.x, theAction.ItemPos1.y)
		mainLogic.gameItemMap[theAction.ItemPos1.x][theAction.ItemPos1.y].isNeedUpdate = true
		mainLogic.boardmap[theAction.ItemPos1.x][theAction.ItemPos1.y].isNeedUpdate = true
		mainLogic:markVenomDestroyedInStep()
		mainLogic:setNeedCheckFalling()
		mainLogic.destroyActionList[actid] = nil
		ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_Poison, ObstacleFootprintAction.k_Eliminate, 1)
	end
end

function DestroyItemLogic:runGameItemSpecialGreyFurballDestroy(mainLogic, theAction, actid)
	if theAction.actionStatus == GameActionStatus.kRunning then
		if not theAction.hasMatch then
			theAction.hasMatch = true
			local r = theAction.ItemPos1.x
			local c = theAction.ItemPos1.y
			local item = mainLogic.gameItemMap[r][c]
			mainLogic:addNeedCheckMatchPoint(r, c)
			mainLogic:setNeedCheckFalling()
		end
	elseif theAction.actionStatus == GameActionStatus.kWaitingForDeath then
		local r = theAction.ItemPos1.x
		local c = theAction.ItemPos1.y
		local item = mainLogic.gameItemMap[r][c]
		item.furballDeleting = false
		mainLogic.destroyActionList[actid] = nil
		ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_GreyFurball, ObstacleFootprintAction.k_Eliminate, 1)
	end
end

function DestroyItemLogic:runGameItemSpecialLockDec(mainLogic, theAction, actid)
	if theAction.actionStatus == GameActionStatus.kRunning then
		if not theAction.hasMatch then
			theAction.hasMatch = true
			local r = theAction.ItemPos1.x
			local c = theAction.ItemPos1.y
			local item = mainLogic.gameItemMap[r][c]
			mainLogic:checkItemBlock(r,c)
			mainLogic:setNeedCheckFalling()
			mainLogic:addNeedCheckMatchPoint(r, c)
		end
	elseif theAction.actionStatus == GameActionStatus.kWaitingForDeath then
		mainLogic.destroyActionList[actid] = nil
		ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_Lock, ObstacleFootprintAction.k_Eliminate, 1)
	end
end

function DestroyItemLogic:runGameItemRoostUpgrade(mainLogic, theAction, actid)
	if theAction.actionStatus == GameActionStatus.kWaitingForDeath then
		mainLogic.destroyActionList[actid] = nil
	end
end

function DestroyItemLogic:runingGameItemSpecialBombColorAction_ItemDeleted(mainLogic, theAction, actid)
	local r1 = theAction.ItemPos1.x
	local c1 = theAction.ItemPos1.y
	local r2 = theAction.ItemPos2.x
	local c2 = theAction.ItemPos2.y
	local color = theAction.addInt

	local item1 = mainLogic.gameItemMap[r1][c1] 		----消除动物
	local item2 = mainLogic.gameItemMap[r2][c2] 		----魔力鸟来源

	if theAction.addInfo == "" then
		theAction.addInfo = "Pass"						----引起界面动画计算
	elseif theAction.addInfo == "Pass" then
		theAction.addInfo = "doing" 					----数据运算等待中----结束运算在函数runGameItemSpecialBombColorAction_ItemDeleted中
	end
end

function DestroyItemLogic:runningGameItem_CollectIngredient(mainLogic, theAction, actid)
	if theAction.addInfo == "Pass" then
		theAction.addInfo = "waiting1"
	elseif theAction.addInfo == "waiting1" then
		if theAction.actionDuring == 0 then 
			local r1 = theAction.ItemPos1.x
			local c1 = theAction.ItemPos1.y
			local item1 = mainLogic.gameItemMap[r1][c1] 		----豆荚位置
			item1:cleanAnimalLikeData()
			mainLogic:setNeedCheckFalling()
			mainLogic.destroyActionList[actid] = nil
			mainLogic.toBeCollected = mainLogic.toBeCollected -1
		end
	end
end

function DestroyItemLogic:runGameItemDeletedByMatchAction(boardView, theAction) 		----animal被删除
	local r1 = theAction.ItemPos1.x
	local c1 = theAction.ItemPos1.y
	local itemView = boardView.baseMap[r1][c1]
	local itemSprite = itemView:getItemSprite(ItemSpriteType.kItem)
	theAction.actionStatus = GameActionStatus.kRunning
	
	if theAction.addInfo == "balloon" then
		boardView.baseMap[r1][c1]:playBalloonBombEffect()
	elseif theAction.addInfo == "wrap" then
		boardView.baseMap[r1][c1]:playWrapItemBombEffect()
	else
		boardView.baseMap[r1][c1]:playAnimationAnimalDestroy()
	end
end

function DestroyItemLogic:runGameItemActionCoverBySpecial(boardView, theAction)
	local r1 = theAction.ItemPos1.x
	local c1 = theAction.ItemPos1.y
	theAction.actionStatus = GameActionStatus.kRunning

	if theAction.addInfo == "kAnimal" then
		if theAction.specialMatchType == SpecialMatchType.kColorLine then
			boardView.baseMap[r1][c1]:playBirdSpecial_BirdDestroyEffect()
		elseif theAction.specialMatchType == SpecialMatchType.kColorWrap then
			boardView.baseMap[r1][c1]:playBirdSpecial_BirdDestroyEffect()
		elseif theAction.specialMatchType == SpecialMatchType.kColorColor then
			local r2 = theAction.ItemPos2.x
			local c2 = theAction.ItemPos2.y
			boardView.baseMap[r1][c1]:playBirdBird_BirdDestroyEffect(IntCoord:create((r1+r2)/2, (c1+c2)/2), theAction.isMasterBird)
		else
			boardView.baseMap[r1][c1]:playAnimationAnimalDestroy()
		end
	elseif theAction.addInfo == "kLock" then
	elseif theAction.addInfo == "kCrystal" then 
	elseif theAction.addInfo == "kGift" then
	elseif theAction.addInfo == "kNewGift" then
	end
end

function DestroyItemLogic:runGameItemActionBombSpecialColor_ItemDeleted(boardView, theAction)
	theAction.actionStatus = GameActionStatus.kRunning
	local r1 = theAction.ItemPos1.x
	local c1 = theAction.ItemPos1.y
	local r2 = theAction.ItemPos2.x
	local c2 = theAction.ItemPos2.y

	local position1 = DestroyItemLogic:getItemPosition(theAction.ItemPos1)
	
	local collectPos = theAction.collectPos or theAction.ItemPos2
	local position2 = DestroyItemLogic:getItemPosition(collectPos)

	local item = boardView.baseMap[r1][c1]
	item:playAnimationAnimalDestroyByBird(position1, position2)
end

function DestroyItemLogic:runGameItemActionCollectIngredient(boardView, theAction)
	theAction.actionStatus = GameActionStatus.kRunning
	local r1 = theAction.ItemPos1.x
	local c1 = theAction.ItemPos1.y

	local item1 = boardView.baseMap[r1][c1]

	item1:playCollectIngredientAction(theAction.itemShowType ,boardView, boardView.IngredientActionPos)
	ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_Fudge, ObstacleFootprintAction.k_Collect, 1)
end

function DestroyItemLogic:runGameItemActionSnowDec(boardView, theAction)
	theAction.actionStatus = GameActionStatus.kRunning
	theAction.addInfo = "update"

	local r = theAction.ItemPos1.x
	local c = theAction.ItemPos1.y
	local item = boardView.baseMap[r][c]
	item:playSnowDecEffect(theAction.addInt)
	if theAction.addInt <= 1 then 
		GameExtandPlayLogic:doAllBlocker195Collect(boardView.gameBoardLogic, r, c, Blocker195CollectType.kSnow)
		SquidLogic:checkSquidCollectItem(boardView.gameBoardLogic, r, c, TileConst.kFrosting1)
	end
	GamePlayMusicPlayer:playEffect(GameMusicType.kSnowBreak)
end

function DestroyItemLogic:runGameItemActionVenomDec(boardView, theAction)
	theAction.actionStatus = GameActionStatus.kRunning

	local r = theAction.ItemPos1.x
	local c = theAction.ItemPos1.y
	local item = boardView.baseMap[r][c]
	GameExtandPlayLogic:doAllBlocker195Collect(boardView.gameBoardLogic, r, c, Blocker195CollectType.kPoison)
	SquidLogic:checkSquidCollectItem(boardView.gameBoardLogic, r, c, TileConst.kPoison)
	item:playVenomDestroyEffect()
end

function DestroyItemLogic:runGameItemActionGreyFurballDestroy(boardView, theAction)
	theAction.actionStatus = GameActionStatus.kRunning
	local r = theAction.ItemPos1.x
	local c = theAction.ItemPos1.y

	local item = boardView.baseMap[r][c]
	GameExtandPlayLogic:doAllBlocker195Collect(boardView.gameBoardLogic, r, c, Blocker195CollectType.kGreyCute)
	SquidLogic:checkSquidCollectItem(boardView.gameBoardLogic, r, c, TileConst.kGreyCute)
	item:playGreyFurballDestroyEffect()
end

function DestroyItemLogic:runningGameItemActionGreyFurballDestroy(boardView, theAction)
	if theAction.actionDuring == 1 then
		local r = theAction.ItemPos1.x
		local c = theAction.ItemPos1.y
		local item = boardView.baseMap[r][c]
		item:cleanFurballEffectView()
	end
end

function DestroyItemLogic:runGameItemActionLockDec(boardView, theAction)
	theAction.actionStatus = GameActionStatus.kRunning

	local r = theAction.ItemPos1.x;
	local c = theAction.ItemPos1.y;
	local item = boardView.baseMap[r][c];
	GameExtandPlayLogic:doAllBlocker195Collect(boardView.gameBoardLogic, r, c, Blocker195CollectType.kLock)
	SquidLogic:checkSquidCollectItem(boardView.gameBoardLogic, r, c, TileConst.kLock)
	item:playLockDecEffect();
end

function DestroyItemLogic:runGameItemActionRoostUpgrade(boardView, theAction)
	theAction.actionStatus = GameActionStatus.kRunning

	local r = theAction.ItemPos1.x
	local c = theAction.ItemPos1.y

	local item = boardView.baseMap[r][c]
	local times = theAction.addInt
	item:playRoostUpgradeAnimation(times)
end

function DestroyItemLogic:runGameItemDigGroundDecLogic( mainLogic,  theAction, actid)
	-- body
	if theAction.actionStatus == GameActionStatus.kRunning then 
		if theAction.actionDuring == GamePlayConfig_GameItemDigGroundDeleteAction_CD - 4 then
			local item = mainLogic.gameItemMap[theAction.ItemPos1.x][theAction.ItemPos1.y]
			if item then item.digBlockCanbeDelete = true end
		end
	end

	if theAction.actionStatus == GameActionStatus.kWaitingForDeath then
		
		local item = mainLogic.gameItemMap[theAction.ItemPos1.x][theAction.ItemPos1.y]
		if theAction.cleanItem then
			GameExtandPlayLogic:doAllBlocker195Collect(mainLogic, theAction.ItemPos1.x, theAction.ItemPos1.y, Blocker195CollectType.kDigGround)
			SquidLogic:checkSquidCollectItem(mainLogic, theAction.ItemPos1.x, theAction.ItemPos1.y, TileConst.kDigGround_1)
			item:cleanAnimalLikeData()
			mainLogic:checkItemBlock(theAction.ItemPos1.x, theAction.ItemPos1.y)
			mainLogic:setNeedCheckFalling()
			ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_DigGround, ObstacleFootprintAction.k_Eliminate, 1)
		end
		mainLogic.destroyActionList[actid] = nil
	end
end

function DestroyItemLogic:runGameItemViewDigGroundDec( boardView, theAction )
	-- body
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then 
		theAction.actionStatus = GameActionStatus.kRunning
		local r = theAction.ItemPos1.x
		local c = theAction.ItemPos1.y
		local item = boardView.baseMap[r][c]

		item:playDigGroundDecAnimation(boardView)
	end
end

function DestroyItemLogic:runGameItemDigJewelDecLogic( mainLogic,  theAction, actid)
	-- body
	if theAction.actionStatus == GameActionStatus.kRunning then 
		if theAction.actionDuring == GamePlayConfig_GameItemDigJewelDeleteAction_CD - 4 then
			local item = mainLogic.gameItemMap[theAction.ItemPos1.x][theAction.ItemPos1.y]
			if item then item.digBlockCanbeDelete = true end
		end
	end

	if theAction.actionStatus == GameActionStatus.kWaitingForDeath then
		local r = theAction.ItemPos1.x
		local c = theAction.ItemPos1.y
		local item = mainLogic.gameItemMap[r][c]
		if theAction.cleanItem then
			GameExtandPlayLogic:itemDestroyHandler(mainLogic, r, c)
			item:cleanAnimalLikeData()
			mainLogic:checkItemBlock(theAction.ItemPos1.x, theAction.ItemPos1.y)
			mainLogic:setNeedCheckFalling()
			ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_DigGround, ObstacleFootprintAction.k_Eliminate, 1)
			ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_DigJewel, ObstacleFootprintAction.k_Collect, 1)
		end
		mainLogic.destroyActionList[actid] = nil
	end
end

function DestroyItemLogic:runGameItemViewDigJewelDec( boardView, theAction )
	-- body
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then 
		theAction.actionStatus = GameActionStatus.kRunning
		local r = theAction.ItemPos1.x
		local c = theAction.ItemPos1.y
		local item = boardView.baseMap[r][c]
		item:playDigJewelDecAnimation(boardView)
	end
end


function DestroyItemLogic:runGameItemViewRandomPropDec(boardView,theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then 
		theAction.actionStatus = GameActionStatus.kRunning
		local r = theAction.ItemPos1.x
		local c = theAction.ItemPos1.y
		local item = boardView.baseMap[r][c]

		item:playRandomPropDie(boardView)
		theAction.counter = 0
	end
end

function DestroyItemLogic:runGameItemRandomPropDecLogic( mainLogic,  theAction, actid)
	if theAction.actionStatus == GameActionStatus.kRunning then 
		theAction.counter = theAction.counter + 1
		-- if _G.isLocalDevelopMode then printx(0, "pppppppppppppppp",theAction.actionDuring,  GamePlayConfig_GameItemDigJewelDeleteAction_CD,mainLogic.gameItemMap[theAction.ItemPos1.x][theAction.ItemPos1.y].digBlockCanbeDelete) end
		-- 这里的逻辑显然错了。。。
		if theAction.actionDuring == GamePlayConfig_GameItemDigJewelDeleteAction_CD - 4 then --有一个保护时间
			local item = mainLogic.gameItemMap[theAction.ItemPos1.x][theAction.ItemPos1.y]
			if item then item.digBlockCanbeDelete = true end
		end

		if theAction.counter > 30 then
			local r = theAction.ItemPos1.x
			local c = theAction.ItemPos1.y
			local item = mainLogic.gameItemMap[r][c]
			if theAction.cleanItem then
				GameExtandPlayLogic:itemDestroyHandler(mainLogic, r, c)
				item:cleanAnimalLikeData()
				mainLogic:checkItemBlock(theAction.ItemPos1.x, theAction.ItemPos1.y)
				mainLogic:setNeedCheckFalling()
			end
			mainLogic.destroyActionList[actid] = nil
		end
	end
end

function DestroyItemLogic:runGameItemBottleBlockerDecLogic( mainLogic,  theAction, actid)
	if theAction.actionStatus == GameActionStatus.kRunning then 
		local item = mainLogic.gameItemMap[theAction.ItemPos1.x][theAction.ItemPos1.y]

		local bottleRow = item.y
		local bottleCol = item.x

		if item.ItemType ~= GameItemType.kBottleBlocker then
			mainLogic.destroyActionList[actid] = nil
		end

		if theAction.addInfo == "start" then
			theAction.addInfo = ""
			if not item.bottleActionRunningCount then item.bottleActionRunningCount = 0 end
			item.bottleActionRunningCount = item.bottleActionRunningCount + 1
		end

		if theAction.oldState == BottleBlockerState.HitAndChanging then
			if theAction.actionDuring == GamePlayConfig_MaxAction_time - 60 then
				--瓶子消掉一层
				-- printx( 1 , " *********************   " , item._encrypt.ItemColorType , theAction.newColor)
				item._encrypt.ItemColorType = theAction.newColor
				--item.bottleState = BottleBlockerState.Waiting
				if item.bottleActionRunningCount then item.bottleActionRunningCount = item.bottleActionRunningCount - 1 end
				item.isNeedUpdate = true
				
				mainLogic:addNeedCheckMatchPoint(bottleRow, bottleCol)
				mainLogic:setNeedCheckFalling()
				theAction.actionStatus = GameActionStatus.kWaitingForDeath
			end
		elseif theAction.oldState == BottleBlockerState.ReleaseSpirit then
			-- if theAction.actionDuring == GamePlayConfig_MaxAction_time - 16 then
			--瓶子完全碎掉，释放十字特效
			local destroyAroundAction = GameBoardActionDataSet:createAs(
					GameActionTargetType.kGameItemAction,
					GameItemActionType.kItem_Bottle_Destroy_Around,
					IntCoord:create(bottleRow, bottleCol),
					nil,
					GamePlayConfig_MaxAction_time)
			mainLogic:addDestructionPlanAction(destroyAroundAction)
			theAction.actionStatus = GameActionStatus.kWaitingForDeath
			-- end
		else
			--assert(false, "unexcept bottle state:"..tostring(item.bottleState))
			theAction.actionStatus = GameActionStatus.kWaitingForDeath
		end
	end

	if theAction.actionStatus == GameActionStatus.kWaitingForDeath then
		mainLogic.destroyActionList[actid] = nil
	end
end

function DestroyItemLogic:runGameItemViewBottleBlockerDec( boardView, theAction )
	-- body
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then 
		theAction.actionStatus = GameActionStatus.kRunning
		local r = theAction.ItemPos1.x
		local c = theAction.ItemPos1.y
		local item = boardView.baseMap[r][c]

		local newColor = GameExtandPlayLogic:randomBottleBlockerColor(boardView.gameBoardLogic, r, c)

		if not newColor then
			newColor = theAction.oldColor
		end

		theAction.newColor = newColor
		theAction.addInfo = "start"
		
		--boardView.gameBoardLogic.gameItemMap[r][c].bottleBlockerNewColor = theAction.newColor
		--boardView.gameBoardLogic.gameItemMap[r][c]._encrypt.ItemColorType = AnimalTypeConfig.kNone
		if theAction.newBottleLevel == 0 then
			GameExtandPlayLogic:doAllBlocker195Collect(boardView.gameBoardLogic, r, c, Blocker195CollectType.kBottleBlocker)
			SquidLogic:checkSquidCollectItem(boardView.gameBoardLogic, r, c, TileConst.kBottleBlocker)
		end
		item:playBottleBlockerHitAnimation(boardView , theAction.newBottleLevel , theAction.newColor)
	end
end

function DestroyItemLogic:runGameItemChestSquarePartLogic(mainLogic, theAction, actid)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then 
		theAction.counter = 0
		theAction.actionStatus = GameActionStatus.kRunning


		local r = theAction.ItemPos1.x
		local c = theAction.ItemPos1.y

		-- 对应的大宝箱也要颤抖一下。。。fuuu
		local tr,tc =  ChestSquareLogic:findChestSquare(mainLogic,r,c)
		theAction.tr = tr
		theAction.tc = tc
	end

	if theAction.actionStatus == GameActionStatus.kRunning then
		if theAction.counter > 60 then
			mainLogic.destroyActionList[actid] = nil
		end
	end

	theAction.counter = theAction.counter + 1
end

function DestroyItemLogic:runGameItemViewChestSquarePartDec(boardView,theAction)
	if ( theAction.counter  == 1) then
		local r = theAction.ItemPos1.x
		local c = theAction.ItemPos1.y
		local item = boardView.baseMap[r][c]
		
		item:playChestSquarePartDec()

		-- 对应的大宝箱也要颤抖一下。。。fuuu
		if theAction.tr and theAction.tc then 
			local itemBig = boardView.baseMap[theAction.tr][theAction.tc]
			itemBig:playChesteSquareHit()
		end
	end
end

function DestroyItemLogic:runGameItemViewMonsterFrostingDec(boardView, theAction)
	theAction.actionStatus = GameActionStatus.kRunning
	local r = theAction.ItemPos1.x
	local c = theAction.ItemPos1.y
	local item = boardView.baseMap[r][c]
	item:playMonsterFrostingDec()

	local r_m , c_m = BigMonsterLogic:findTheMonster( boardView.gameBoardLogic, r, c )
	if r_m and c_m then
		local item_monster = boardView.baseMap[r_m][c_m]
		item_monster:playMonsterEncourageAnimation()
	end
end

function DestroyItemLogic:runGameItemMonsterFrostingLogic(mainLogic, theAction, actid)
	-- body
	if theAction.actionStatus == GameActionStatus.kWaitingForDeath then
		mainLogic.destroyActionList[actid] = nil
		ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_BigMonster, ObstacleFootprintAction.k_Hit, 1)
	end
end

function DestroyItemLogic:runGameItemViewBlackCuteBallDec(boardView, theAction)
	-- body
	local function animationCallback( ... )
		-- body
		-- theAction.actionStatus = GameActionStatus.kWaitingForDeath
	end
	theAction.actionStatus = GameActionStatus.kRunning
	local r = theAction.ItemPos1.x
	local c = theAction.ItemPos1.y
	local item = boardView.baseMap[r][c]
	local currentStrength = theAction.blackCuteStrength
	if currentStrength == 0 then
		GameExtandPlayLogic:doAllBlocker195Collect(boardView.gameBoardLogic, r, c, Blocker195CollectType.kBlackCute)
		SquidLogic:checkSquidCollectItem(boardView.gameBoardLogic, r, c, TileConst.kBlackCute)
	end

	item:playBlackCuteBallDecAnimation(currentStrength, animationCallback)
end

function DestroyItemLogic:runGameItemBlackCuteBallDec(mainLogic, theAction, actid)
	-- body
	if theAction.actionStatus == GameActionStatus.kWaitingForDeath then 
		local currentStrength = theAction.blackCuteStrength
		local r = theAction.ItemPos1.x
		local c = theAction.ItemPos1.y
		local item = mainLogic.gameItemMap[r][c]
		if currentStrength == 0 then 
			if item then 
				GameExtandPlayLogic:itemDestroyHandler(mainLogic, r, c)
				item:cleanAnimalLikeData()
				mainLogic:checkItemBlock(theAction.ItemPos1.x, theAction.ItemPos1.y)
				mainLogic:setNeedCheckFalling()
			end
			ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_BlackFurball, ObstacleFootprintAction.k_Eliminate, 1)
		else

		end
		item.lastInjuredStep = mainLogic.realCostMove
		ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_BlackFurball, ObstacleFootprintAction.k_Hit, 1)
		mainLogic.destroyActionList[actid] = nil
	end
end
function DestroyItemLogic:runGameItemActionMissileHitView(boardView, theAction)
	if theAction.counter == 0 then 
		local r = theAction.ItemPos1.x
		local c = theAction.ItemPos1.y
		local item = boardView.baseMap[r][c]
		local currentStrength = theAction.missileLevel
		if currentStrength == 0 then
			GameExtandPlayLogic:doAllBlocker195Collect(boardView.gameBoardLogic, r, c, Blocker195CollectType.kMissile)
			SquidLogic:checkSquidCollectItem(boardView.gameBoardLogic, r, c, TileConst.kMissile)
		end
		item:playMissileDecAnimation(currentStrength)
		-- if _G.isLocalDevelopMode then printx(0, r,c,currentStrength) end
	end
end

function DestroyItemLogic:runningGameItemActionMissileHit(mainLogic, theAction, actid)
	
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then 
		theAction.actionStatus = GameActionStatus.kRunning

		theAction.counter  = 0
	else
		theAction.counter = theAction.counter + 1

		if theAction.counter  > 1 then 
			mainLogic.destroyActionList[actid] = nil
			mainLogic:setNeedCheckFalling()
		end
	end
end


function DestroyItemLogic:runGameItemActionMimosaBack(boardView, theAction)
	-- body
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		theAction.addInfo = "start"
		local function callback( ... )
			-- body
			--theAction.addInfo = "over"
		end

		local list = theAction.mimosaHoldGrid
		local time = 0
		for k = 1, #list do 
			local r, c = list[k].x, list[k].y
			local itemView = boardView.baseMap[r][c]
			local call_func = k==#list and callback or nil
			itemView:playMimosaEffectAnimation(theAction.itemType,theAction.direction, time * (#list - k),  call_func, false)
		end

		local r = theAction.ItemPos1.x
		local c = theAction.ItemPos1.y
		local itemView = boardView.baseMap[r][c]
		itemView:playMimosaBackAnimation(time)

		theAction.jsq = 0
	else

		if theAction.addInfo == "wait" then
			theAction.jsq = theAction.jsq + 1
			if theAction.jsq == 36 then
				theAction.addInfo = "over"
			end
		end
	end

end

function DestroyItemLogic:runGameItemActionKindMimosaBack(boardView, theAction)
	-- body
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		theAction.addInfo = "start"
		local function callback( ... )
			-- body
			--theAction.addInfo = "over"
		end

		local list = theAction.list
		local time = 0
		for k = 1, #list do 
			local r, c = list[k].x, list[k].y
			local itemView = boardView.baseMap[r][c]
			local call_func = k==#list and callback or nil
			itemView:playMimosaEffectAnimation(theAction.itemType,theAction.direction, time * (#list - k),  call_func, false)
		end

		local r = theAction.ItemPos1.x
		local c = theAction.ItemPos1.y
		local itemView = boardView.baseMap[r][c]
		itemView:playMimosaBackAnimation(time)

		theAction.jsq = 0
	else
		if theAction.addInfo == "wait" then
			theAction.jsq = theAction.jsq + 1
			if theAction.jsq == 36 then
				theAction.addInfo = "over"
			end
		end
	end
end

function DestroyItemLogic:runningGameItemActionMimosaBack(mainLogic, theAction, actid)
	-- body
	if theAction.addInfo == "start" then
		theAction.addInfo = "wait"


		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local item = mainLogic.gameItemMap[r][c]
		local list = item.mimosaHoldGrid
		for k, v in pairs(list) do 
			local item_grid = mainLogic.gameItemMap[v.x][v.y]
			item_grid.beEffectByMimosa = 0
			item_grid.mimosaDirection = 0
			mainLogic:checkItemBlock(v.x, v.y)
			mainLogic:addNeedCheckMatchPoint(v.x, v.y)
		end
		FallingItemLogic:preUpdateHelpMap(mainLogic)
		item.mimosaHoldGrid = {}
		item.isBackAllMimosa = nil
	elseif theAction.addInfo == "over" then
		local mr, mc = theAction.ItemPos1.x, theAction.ItemPos1.y
		local mimosa = mainLogic.gameItemMap[mr][mc]
		if mimosa and mimosa.needRemoveEventuallyBySquid then
			if mainLogic.boardView.baseMap[mr] and mainLogic.boardView.baseMap[mr][mc] then
				local itemView = mainLogic.boardView.baseMap[mr][mc]
				itemView:squidCommonDestroyItemAnimation()
			end

			mimosa:cleanAnimalLikeData()
			mainLogic:checkItemBlock(mr, mc)
		end

		if theAction.completeCallback then
			theAction.completeCallback()
		end

		mainLogic.destroyActionList[actid] = nil
	end

end

function DestroyItemLogic:runningGameItemActionKindMimosaBack(mainLogic, theAction, actid)
	-- body
	if theAction.addInfo == "start" then
		theAction.addInfo = "wait"
		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local item = mainLogic.gameItemMap[r][c]
		local list = theAction.list
		for k, v in pairs(list) do 
			local item_grid = mainLogic.gameItemMap[v.x][v.y]
			item_grid.beEffectByMimosa = 0
			item_grid.mimosaDirection = 0
			mainLogic:checkItemBlock(v.x, v.y)
			mainLogic:addNeedCheckMatchPoint(v.x, v.y)
		end
		FallingItemLogic:preUpdateHelpMap(mainLogic)
	elseif theAction.addInfo == "over" then
		if theAction.completeCallback then
			theAction.completeCallback()
		end

		mainLogic.destroyActionList[actid] = nil
	end
end

function DestroyItemLogic:getItemPosition(itemPos)
	local x = (itemPos.y - 0.5 ) * GamePlayConfig_Tile_Width
	local y = (GamePlayConfig_Max_Item_Y - itemPos.x - 0.5 ) * GamePlayConfig_Tile_Height
	return ccp(x,y)
end


-----------------------------------------
--       Chameleon
-----------------------------------------
function DestroyItemLogic:runGameItemActionChameleonTransformLogic(mainLogic, theAction, actid)	--Logic
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		theAction.jsq = 0
	end

	local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
	local chameleon = mainLogic.gameItemMap[r][c]

	--动画炸裂进程中，更新转化物数据与视图
	if theAction.jsq == 16 then
		ChameleonLogic:initNewItemView(mainLogic, chameleon)
	end

	if theAction.addInfo == 'over' then
		chameleon = mainLogic.gameItemMap[r][c]
		ChameleonLogic:onChameleonDemolished(mainLogic, chameleon)
		ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_Chameleon, ObstacleFootprintAction.k_Eliminate, 1)

		if theAction.completeCallback then
			theAction.completeCallback()
		end
		mainLogic.destroyActionList[actid] = nil
	end
end

function DestroyItemLogic:runGameItemActionChameleonTransformView(boardView, theAction)	--View

	if theAction.actionStatus == GameActionStatus.kRunning then

		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y

		if theAction.jsq == 0 then
			local chameleonView = boardView.baseMap[r][c]
			chameleonView:playChameleonBlast()
		end

		theAction.jsq = theAction.jsq + 1

		if theAction.jsq == 32 then
			theAction.addInfo = "over"
		end

	end
end

------------------------------------------------------------------------------------
--       							Pacman
------------------------------------------------------------------------------------
------- EAT ---------
function DestroyItemLogic:runGameItemActionPacmanEatTargetLogic(mainLogic, theAction, actid)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		theAction.jsq = 0
	end

	if theAction.addInfo == 'over' then
		-- printx(11, "runGameItemActionPacmanEatTargetLogic   OVER")
		PacmanLogic:updatePacmanPosition(mainLogic, theAction.targetPacman, theAction.targetItem, theAction.pacmanCollection)
		ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_Pacman, ObstacleFootprintAction.k_Attack, 1)

		if theAction.completeCallback then
			theAction.completeCallback()
		end
		mainLogic.destroyActionList[actid] = nil
	end
end

function DestroyItemLogic:runGameItemActionPacmanEatTargetView(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kRunning then
		-- printx(11, "runGameItemActionPacmanEatTargetView", theAction.jsq)
		if theAction.jsq == 0 then
			local function callback()
				theAction.addInfo = "over"
			end

			local fromRow, fromCol = theAction.ItemPos1.y, theAction.ItemPos1.x
			local toRow, toCol = theAction.ItemPos2.y, theAction.ItemPos2.x
			local pacmanView = boardView.baseMap[fromRow][fromCol]
			pacmanView:playPacmanMove(IntCoord:create(toRow - fromRow, toCol - fromCol), callback)
		end

		theAction.jsq = theAction.jsq + 1
	end
end

------- BLOW ---------
function DestroyItemLogic:runGameItemActionPacmanBlowLogic(mainLogic, theAction, actid)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		theAction.jsq = 0
	end

	if theAction.addInfo == "hitTarget" then
		theAction.addInfo = ""
		PacmanLogic:onHitTargets(mainLogic, theAction.targetPacman, theAction.targetPositions)
	end

	if theAction.addInfo == 'over' then
		-- printx(11, "runGameItemActionPacmanBlowLogic   OVER")

		local targetPacman = theAction.targetPacman
		targetPacman:cleanAnimalLikeData()
		-- targetPacman.isUsed = false
		targetPacman.isNeedUpdate = true
		mainLogic:checkItemBlock(targetPacman.y, targetPacman.x)
		mainLogic:tryDoOrderList(targetPacman.y, targetPacman.x, GameItemOrderType.kOthers, GameItemOrderType_Others.kPacman, 1)
		local boardMinNum = mainLogic.pacmanConfig.boardMinNum or 0
		if boardMinNum > 0 then
			PacmanLogic:updateDenProgressDisplay(mainLogic)	-- 如果设置了吃豆人棋盘最小数量，那么吃豆人的消除可能会触发生产，遂尝试刷新窝进度的显示
		end

		if theAction.completeCallback then
			theAction.completeCallback()
		end
		mainLogic.destroyActionList[actid] = nil
	end
end

function DestroyItemLogic:runGameItemActionPacmanBlowView(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kRunning then
		-- printx(11, "runGameItemActionPacmanBlowView", theAction.jsq)

		local pacman = theAction.targetPacman
		local pacmanView = boardView.baseMap[pacman.y][pacman.x]

		--- 开始播放吃豆人Blast动画
		--- 播放发射光效流星
		if theAction.jsq == 0 then
			pacmanView:playPacmanBlastAnimation()

			local fromPos = pacmanView:getBasePosition(pacman.x, pacman.y)
			for _, v in pairs(theAction.targetPositions) do
				local toPos = boardView.baseMap[v.y][v.x]:getBasePosition(v.x, v.y)
				pacmanView:playPacmansBlowHitAnimation(fromPos, toPos)
			end
		end

		theAction.jsq = theAction.jsq + 1

		--- 击中目标
		local hitAnimationDelay = 30
		if theAction.jsq == hitAnimationDelay then
			theAction.addInfo = "hitTarget"
		end

		--- 整体结束
		local blowDurationDelay = 60
		if theAction.jsq == blowDurationDelay then
			theAction.addInfo = "over"
		end
	end
end

------- GENERATE ---------
function DestroyItemLogic:runGameItemActionPacmanGenerateLogic(mainLogic, theAction, actid, actByView)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		-- printx(11, "start runGameItemActionPacmanGenerate")
		theAction.actionStatus = GameActionStatus.kRunning
		theAction.jsq = 0
	end

	if theAction.addInfo == 'over' then
		-- printx(11, "runGameItemActionPacmanGenerateLogic   OVER")

		local generateNumByBoardMin = theAction.generateNumByBoardMin
		local generateNumByStep = theAction.generateNumByStep

		for _, targetItem in ipairs(theAction.pickedTargets) do
			PacmanLogic:updateNewPacman(mainLogic, targetItem)
			if generateNumByBoardMin > 0 then
				mainLogic.pacmanGeneratedByBoardMin = mainLogic.pacmanGeneratedByBoardMin + 1
				generateNumByBoardMin = generateNumByBoardMin - 1
				-- printx(11, "add pacmanGeneratedByBoardMin to: ", mainLogic.pacmanGeneratedByBoardMin)
			else
				mainLogic.pacmanGeneratedByStep = mainLogic.pacmanGeneratedByStep + 1
				-- generateNumByStep = generateNumByStep - 1
				-- printx(11, "add pacmanGeneratedByStep to: ", mainLogic.pacmanGeneratedByStep)
			end
		end

		if theAction.completeCallback then
			theAction.completeCallback()
		end
		mainLogic.destroyActionList[actid] = nil
	end
end

function DestroyItemLogic:runGameItemActionPacmanGenerateView(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kRunning then

		if theAction.jsq == 0 then
			local denRecord = {}
			local denPositions = {}
			for _, targetItem in ipairs(theAction.pickedTargets) do
				local function onGenerateJumpEnd()
					if theAction.generateCount then
						theAction.generateCount = theAction.generateCount - 1
					end

					if not theAction.generateCount or theAction.generateCount <= 0 then
						theAction.addInfo = "over"
					end
				end

				local denPos = targetItem.pacmansDenPos
				local denView = boardView.baseMap[denPos.y][denPos.x]

				local fromRow, fromCol = denPos.y, denPos.x
				local toRow, toCol = targetItem.y, targetItem.x
				denView:playPacmansDenGeneratePacman(IntCoord:create(toRow - fromRow, toCol - fromCol), 
					targetItem.pacmanColour, onGenerateJumpEnd)
				if not theAction.generateCount then
					theAction.generateCount = 0
				end
				theAction.generateCount = theAction.generateCount + 1
				
				local locationKey = denPos.x..","..denPos.y
				if not denRecord[locationKey] then
					table.insert(denPositions, denPos)
					denRecord[locationKey] = true
				end
			end

			for _, genDenPos in ipairs(denPositions) do
				--- Den play generate animation
				local genDenView = boardView.baseMap[genDenPos.y][genDenPos.x]
				genDenView:playPacmansDenGenerate()
			end
		end

		theAction.jsq = theAction.jsq + 1

		-- local realReplaceDelay = 25
		-- if theAction.jsq == realReplaceDelay then
		-- 	for _, targetItem in ipairs(theAction.pickedTargets) do
		-- 		local targetItemView = boardView.baseMap[targetItem.y][targetItem.x]
		-- 		if targetItemView then
		-- 			local sp = targetItemView:getGameItemSprite()
		-- 			if sp then 
		-- 				-- sp:setVisible(false)
		-- 				sp:runAction(CCSpawn:createWithTwoActions(
		-- 					CCEaseOut:create(CCMoveBy:create(1, ccp(0, -GamePlayConfig_Tile_Height)), 1/3) , 
		-- 					CCEaseSineOut:create(CCFadeOut:create(1) )))
		-- 			end
		-- 		end
		-- 	end
		-- end

		-- local wholeAnimationDelay = 60
		-- if theAction.jsq == wholeAnimationDelay then
		-- 	theAction.addInfo = "over"
		-- 	printx(11, "runGameItemActionPacmanEatTargetView  set addinfo over")
		-- end
	end
end

------------------ Turret 第二版 ----------------------
function DestroyItemLogic:runGameItemActionTurretUpgradeLogic(mainLogic, theAction, actid)
    local fromRow, fromCol = theAction.ItemPos1.x, theAction.ItemPos1.y

    if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		theAction.jsq = 0
        theAction.turret = mainLogic.gameItemMap[fromRow][fromCol]
        theAction.isRunAddStartTime = false

         theAction.CanAttackStartTime = 0

        theAction.addInfo = "TouchTurret"

        theAction.needRemoveEventuallyBySquid = theAction.turret.needRemoveEventuallyBySquid
	end
        
    theAction.CanAttackStartTime = theAction.CanAttackStartTime + 1

    --延迟4帧 确定升级状态
    if theAction.CanAttackStartTime > 5 then
        --确定升级
        theAction.turret.updateType = 2
    end

    if theAction.addInfo == 'TouchTurret' then 
        --碰撞
        if theAction.turret.turretLevel == 0 then

            if theAction.turret.updateType == 0 then
                theAction.turret.updateType = 1
            end
            theAction.turret.turretLevel = 1
           
            theAction.isRunAddStartTime = true --只能第一个执行升级的action运行touch计数++
            if theAction.hitBySpecial then
                theAction.turret.turretIsSuper = true
            end

            theAction.addInfo = "PreUpgrade"

        elseif theAction.turret.turretLevel == 1 then
            --4帧内可连续碰撞改变特效形态
            if theAction.turret.updateType == 1 then
                if theAction.hitBySpecial then
                    theAction.turret.turretIsSuper = true
                end

                theAction.addInfo = "waitover"

            elseif theAction.turret.updateType == 2 then
                if not theAction.turret.turretLocked then

                    local CenterPos = TurretLogic:getTurretFireCenterPos(mainLogic, theAction.turret)
                    if CenterPos then
                         --开炮
			            theAction.fireTargetCoord, theAction.PiectPosList = TurretLogic:getTurretFireCenterCoord(mainLogic, theAction.turret)
			            ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_Turret, ObstacleFootprintAction.k_Attack, 1)

                        --theAction.turret.turretLevel = 2
                        theAction.turret.turretLevel = 0 --开炮就0级了
                        theAction.turret.turretLocked = true
                    end

                    theAction.jsq = 0
                    theAction.addInfo = "FireCenter"
                else
                    theAction.addInfo = "waitover"
                end
            end
        end

    elseif theAction.addInfo == "hitTarget" then
        --击打中心
		theAction.addInfo = "waitHitover"
        theAction.jsq = 0
		TurretLogic:onHitTargets(mainLogic, theAction.turret, theAction.fireTargetCoord)

	elseif theAction.addInfo == "hitPieceTarget" then
        --碎片击打
        if #theAction.HitPieceDelayList == 0 then
            theAction.turret.turretIsSuper = false

            theAction.addInfo = "waitHitPieceover"
            theAction.jsq = 0
        else
            for i,v in pairs(theAction.HitPieceDelayList) do
                if v.Delay == theAction.jsq then

                	--如果自身有果酱。打出去的目标也给果酱属性
			        if TurrectHaveJamSperad then
				        GameExtandPlayLogic:addJamSperadFlag(mainLogic, v.r, v.c )
				    end

                    bAllFinish = false
                    TurretLogic:onHitPieceTargets(mainLogic, theAction.turret, theAction.fireTargetCoord, ccp(v.c,v.r) )
                    table.remove( theAction.HitPieceDelayList, i )
                end
             end
        end
    elseif theAction.addInfo == 'over' then
        local bCanOver = true
        if theAction.CanAttackStartTime < 4 then
            bCanOver = false
        end

        if bCanOver then
            if theAction.turret and theAction.turret.needRemoveEventuallyBySquid then
			    theAction.turret:cleanAnimalLikeData()
			    theAction.turret.isNeedUpdate = true
			    mainLogic:checkItemBlock(theAction.turret.y, theAction.turret.x)
		    end

            mainLogic.destroyActionList[actid] = nil
        end
    end
end

function DestroyItemLogic:runGameItemActionTurretUpgradeView(boardView, theAction)

    local fromRow, fromCol = theAction.ItemPos1.x, theAction.ItemPos1.y
    local turretView = boardView.baseMap[fromRow][fromCol]
    local ActionOverDelay = 20 --default

    local mathBoard = boardView.gameBoardLogic.boardmap[fromRow][fromCol]
	local TurrectHaveJamSperad = mathBoard.isJamSperad

    if theAction.actionStatus == GameActionStatus.kRunning then

        if theAction.addInfo == 'PreUpgrade' then
            turretView:playTurretPreUpgradeAnimation(theAction.turret.turretIsSuper, nil )

            theAction.addInfo = "waiPreUpgrade"
            theAction.jsq = 0
        elseif theAction.addInfo == "waiPreUpgrade" then
		    local hitAnimationDelay = 10
            if theAction.jsq == hitAnimationDelay then
		        --播放炮台变换
                local fromPos = turretView:getBasePositionWeek(fromCol, fromRow)
			    turretView:playTurretUpgradeAnimation(theAction.turret.turretIsSuper, fromPos )

                --等待结束
                theAction.addInfo = "waitover"
                theAction.jsq = 0
                ActionOverDelay = 0
            end
        elseif theAction.addInfo == 'FireCenter' then
            --可以开炮的时候
            if theAction.fireTargetCoord then
                --播放炮弹准星
				local fromPos = turretView:getBasePositionWeek(fromCol, fromRow)
				local targetX, targetY = theAction.fireTargetCoord.x, theAction.fireTargetCoord.y
				local toPos = boardView.baseMap[targetY][targetX]:getBasePositionWeek(targetX, targetY)

                local pos = ccp(toPos.x,toPos.y)

				turretView:playTurretFireFlyAnimation(fromPos, toPos)

                theAction.addInfo = "targetBlink"
                theAction.jsq = 0
            else
                --如果炮弹位置中心没找到 说明打不到  等待结束
                theAction.addInfo = "waitover"
                theAction.jsq = 0
                ActionOverDelay = 20
			end
        elseif theAction.addInfo == "targetBlink" then
             ---准星后 击中目标
		    local hitAnimationDelay = 10
		    if theAction.jsq == hitAnimationDelay then
                if theAction.fireTargetCoord then
                	--播放炮弹准星
				    local fromPos = turretView:getBasePositionWeek(fromCol, fromRow)
			        turretView:playTurretUpgradeAnimation(theAction.turret.turretIsSuper,fromPos)
                end
			    theAction.addInfo = "fly"
		    end
        elseif theAction.addInfo == "fly" then
            ---fly后 击中目标
		    local hitAnimationDelay = 28
		    if theAction.jsq == hitAnimationDelay then
                local targetX, targetY = theAction.fireTargetCoord.x, theAction.fireTargetCoord.y
				local toPos = boardView.baseMap[targetY][targetX]:getBasePositionWeek(targetX, targetY)

                local pos = ccp(toPos.x,toPos.y)

                --如果自身有果酱。打出去的目标也给果酱属性
		        if TurrectHaveJamSperad then
			        GameExtandPlayLogic:addJamSperadFlag(boardView.gameBoardLogic, targetY, targetX )
			    end

                turretView:playTurretMainBoomAnimation( toPos)
			    theAction.addInfo = "hitTarget"
		    end
        elseif theAction.addInfo == "waitHitover" then
            ---碎片飞
		    local hitAnimationDelay = 18
		    if theAction.jsq == hitAnimationDelay then

                local targetX, targetY = theAction.fireTargetCoord.x, theAction.fireTargetCoord.y
				local fromPos = boardView.baseMap[targetY][targetX]:getBasePositionWeek(targetX, targetY)

                local pos = ccp(fromPos.x,fromPos.y)

                theAction.PieceAllNum =  #theAction.PiectPosList
--                local CurPieceHitNum = 0

                local DelayTime = 0
                local DelayNum = 0
                function PieceFlyEnd( PieceInedx )
                    --回调没用了
                end

                local HitPieceDelayList = {}
                for i,v in pairs(theAction.PiectPosList) do
                    local toPos =  boardView.baseMap[v.y][v.x]:getBasePositionWeek(v.x, v.y)
                    turretView:playTurretPieceFlyAnimation(ccp(fromPos.x,fromPos.y), toPos, DelayTime, i, PieceFlyEnd, theAction.turret.turretIsSuper )
                    DelayTime = DelayTime + 0.1

                    DelayNum = DelayNum + 6
                    local Info = {}
                    Info.Delay = DelayNum
                    Info.r = v.y
                    Info.c = v.x
                    table.insert( HitPieceDelayList, Info )
                end

--                if #theAction.PiectPosList == 0 then
--                    --等待结束
--                    theAction.addInfo = "waitover"
--                    theAction.jsq = 0
--                    ActionOverDelay = 20
--                else
                    theAction.HitPieceDelayList = HitPieceDelayList
                    theAction.addInfo = "hitPieceTarget"
                    theAction.jsq = 0
--                end
		    end
        elseif theAction.addInfo == "waitHitPieceover" then
            --等待碎片飞行结束
		    local hitAnimationDelay = 28
		    if theAction.jsq == hitAnimationDelay then
			    theAction.addInfo = "waitover"
                theAction.jsq = 0
                ActionOverDelay = 20
		    end
        elseif theAction.addInfo == "waitover" then
            --- 整体结束
		    if theAction.jsq == ActionOverDelay then
		    	if theAction.needRemoveEventuallyBySquid then
		    		turretView:squidCommonDestroyItemAnimation()
		    	end

			    theAction.addInfo = "over"
		    end
        end

        theAction.jsq = theAction.jsq + 1
    end


end


------------------ Turret ----------------------
function DestroyItemLogic:runGameItemActionTurretUpgradeLogic2(mainLogic, theAction, actid)
	local turretPos = theAction.turretPos
	local turret = mainLogic.gameItemMap[turretPos.x][turretPos.y]
    if not theAction.turretItemOldLevel then
        theAction.turretItemOldLevel = turret.turretLevel
    end
    theAction.turretItemLevel = turret.turretLevel
	theAction.turretIsSuper = turret.turretIsSuper

	local mathBoard = mainLogic.boardmap[turretPos.x][turretPos.y]
	local TurrectHaveJamSperad = mathBoard.isJamSperad

    theAction.CanAttackStartTime = theAction.CanAttackStartTime + 1

	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		theAction.jsq = 0
        theAction.addInfo = "TurretUpdate"
        theAction.needRemoveEventuallyBySquid = turret.needRemoveEventuallyBySquid

        --炮台满级可以发射
		if theAction.maxLevelReached then
			theAction.fireTargetCoord, theAction.PiectPosList = TurretLogic:getTurretFireCenterCoord(mainLogic, turret)
			ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_Turret, ObstacleFootprintAction.k_Attack, 1)
		end
	end

	if theAction.addInfo == "hitTarget" then
		theAction.addInfo = "waitHitover"
        theAction.jsq = 0
		TurretLogic:onHitTargets(mainLogic, turret, theAction.fireTargetCoord)
	end

	if theAction.addInfo == "hitPieceTarget" then

        if #theAction.HitPieceDelayList == 0 then
            theAction.addInfo = "waitHitPieceover"
            theAction.jsq = 0
        else
            for i,v in pairs(theAction.HitPieceDelayList) do
                if v.Delay == theAction.jsq then

                	--如果自身有果酱。打出去的目标也给果酱属性
			        if TurrectHaveJamSperad then
				        GameExtandPlayLogic:addJamSperadFlag(mainLogic, v.r, v.c )
				    end

                    bAllFinish = false
                    TurretLogic:onHitPieceTargets(mainLogic, turret, theAction.fireTargetCoord, ccp(v.c,v.r) )
                    table.remove( theAction.HitPieceDelayList, i )
                end
             end
        end
	end

	if theAction.addInfo == 'over' then

        if theAction.turretItemOldLevel ~= turret.turretLevel then
            theAction.actionStatus = GameActionStatus.kWaitingForStart
            theAction.addInfo = ""
            theAction.maxLevelReached = true
            turret.turretLevel = 1
            theAction.IsCanSetLock = true
        else
		    if theAction.maxLevelReached and theAction.fireTargetCoord then
			    turret.turretLevel = 0
			    turret.turretIsSuper = false
            elseif theAction.maxLevelReached and theAction.fireTargetCoord == nil then
--              turret.turretLevel = 0
--			    turret.turretIsSuper = false
            else
                local maxLevel = 2		--击中2次后触发
                if turret.turretLevel < maxLevel then
                    turret.turretLevel = turret.turretLevel + 1 
                end
		    end

            turret.runAction = false
            turret.upgradeAction = nil

            if theAction.IsCanSetLock then
                turret.turretLocked = true
            end

            if turret and turret.needRemoveEventuallyBySquid then
				turret:cleanAnimalLikeData()
				turret.isNeedUpdate = true
				mainLogic:checkItemBlock(turret.y, turret.x)
			end

		    -- if theAction.completeCallback then
		    -- 	theAction.completeCallback()
		    -- end
		    mainLogic.destroyActionList[actid] = nil
        end

	end
end

function DestroyItemLogic:runGameItemActionTurretUpgradeView2(boardView, theAction)
    local turretPos = theAction.turretPos
	local turretView = boardView.baseMap[turretPos.x][turretPos.y]

	local mathBoard = boardView.gameBoardLogic.boardmap[turretPos.x][turretPos.y]
	local TurrectHaveJamSperad = mathBoard.isJamSperad

	if theAction.actionStatus == GameActionStatus.kRunning then
		-- printx(11, "runGameItemActionTurretUpgradeView", theAction.jsq)
        local ActionOverDelay = 20 --default
        if theAction.addInfo == "TurretUpdate" then

            if theAction.turretItemLevel == 0 then
		        if theAction.jsq == 0 then
			        --播放炮台变换前置
                    function preUpgradeEnd()
                        --nouse 走帧回调了
                    end

			        turretView:playTurretPreUpgradeAnimation(theAction.turretIsSuper, preUpgradeEnd )

                    theAction.addInfo = "waiPreUpgrade"
                    theAction.jsq = 0
		        end
            else
                --可以开炮的时候
                if theAction.fireTargetCoord then
                    --播放炮弹准星
				    local fromPos = turretView:getBasePositionWeek(turretPos.y, turretPos.x)
				    local targetX, targetY = theAction.fireTargetCoord.x, theAction.fireTargetCoord.y
				    local toPos = boardView.baseMap[targetY][targetX]:getBasePositionWeek(targetX, targetY)

                    local pos = ccp(toPos.x,toPos.y)

				    turretView:playTurretFireFlyAnimation(fromPos, toPos)

                    theAction.addInfo = "targetBlink"
                    theAction.jsq = 0
                else
                    --如果炮弹位置中心没找到 说明打不到  等待结束
                    theAction.addInfo = "waitover"
                    theAction.jsq = 0
                    ActionOverDelay = 20
			    end
            end
        end

        ---等待升级结束
        if theAction.addInfo == "waiPreUpgrade" then
		    local hitAnimationDelay = 10
            if theAction.jsq == hitAnimationDelay then
		        --播放炮台变换
                local fromPos = turretView:getBasePositionWeek(turretPos.y, turretPos.x)
			    turretView:playTurretUpgradeAnimation(theAction.turretIsSuper, fromPos )

                --等待结束
                theAction.addInfo = "waitover"
                theAction.jsq = 0
                ActionOverDelay = 0
            end
        end

		---准星后 击中目标
        if theAction.addInfo == "targetBlink" then
		    local hitAnimationDelay = 10
		    if theAction.jsq == hitAnimationDelay then
                if theAction.fireTargetCoord then
                	--播放炮弹准星
				    local fromPos = turretView:getBasePositionWeek(turretPos.y, turretPos.x)
			        turretView:playTurretUpgradeAnimation(theAction.turretIsSuper,fromPos)
                end
			    theAction.addInfo = "fly"
		    end
        end

        ---fly后 击中目标
        if theAction.addInfo == "fly" then
		    local hitAnimationDelay = 28
		    if theAction.jsq == hitAnimationDelay then
                local targetX, targetY = theAction.fireTargetCoord.x, theAction.fireTargetCoord.y
				local toPos = boardView.baseMap[targetY][targetX]:getBasePositionWeek(targetX, targetY)

                local pos = ccp(toPos.x,toPos.y)

                --如果自身有果酱。打出去的目标也给果酱属性
		        if TurrectHaveJamSperad then
			        GameExtandPlayLogic:addJamSperadFlag(boardView.gameBoardLogic, targetY, targetX )
			    end

                turretView:playTurretMainBoomAnimation( toPos)
			    theAction.addInfo = "hitTarget"
		    end
        end

        ---碎片飞
        if theAction.addInfo == "waitHitover" then
		    local hitAnimationDelay = 18
		    if theAction.jsq == hitAnimationDelay then

                local targetX, targetY = theAction.fireTargetCoord.x, theAction.fireTargetCoord.y
				local fromPos = boardView.baseMap[targetY][targetX]:getBasePositionWeek(targetX, targetY)

                local pos = ccp(fromPos.x,fromPos.y)

                theAction.PieceAllNum =  #theAction.PiectPosList
--                local CurPieceHitNum = 0

                local DelayTime = 0
                local DelayNum = 0
                function PieceFlyEnd( PieceInedx )
                    --回调没用了
                end

                local HitPieceDelayList = {}
                for i,v in pairs(theAction.PiectPosList) do
                    local toPos =  boardView.baseMap[v.y][v.x]:getBasePositionWeek(v.x, v.y)
                    turretView:playTurretPieceFlyAnimation(ccp(fromPos.x,fromPos.y), toPos, DelayTime, i, PieceFlyEnd, theAction.turretIsSuper )
                    DelayTime = DelayTime + 0.1

                    DelayNum = DelayNum + 6
                    local Info = {}
                    Info.Delay = DelayNum
                    Info.r = v.y
                    Info.c = v.x
                    table.insert( HitPieceDelayList, Info )
                end

                if #theAction.PiectPosList == 0 then
                    --等待结束
                    theAction.addInfo = "waitover"
                    theAction.jsq = 0
                    ActionOverDelay = 20
                else
                    theAction.HitPieceDelayList = HitPieceDelayList
                    theAction.addInfo = "hitPieceTarget"
                    theAction.jsq = 0
                end
		    end
        end

        ---hitTarget后 碎片击中目标
--        if theAction.addInfo == "PieceFly" then
--		    local hitAnimationDelay = 20
--		    if theAction.jsq == hitAnimationDelay then
--			    theAction.addInfo = "hitPieceTarget"
--		    end
--        end

        ---hitPieceTarget后 延迟结束
        if theAction.addInfo == "waitHitPieceover" then
		    local hitAnimationDelay = 28
		    if theAction.jsq == hitAnimationDelay then
			    theAction.addInfo = "waitover"
                theAction.jsq = 0
                ActionOverDelay = 20
		    end
        end

		--- 整体结束
        if theAction.addInfo == "waitover" then
		    if theAction.jsq == ActionOverDelay then
		    	if theAction.needRemoveEventuallyBySquid then
		    		turretView:squidCommonDestroyItemAnimation()
		    	end

			    theAction.addInfo = "over"
		    end
        end

        theAction.jsq = theAction.jsq + 1
	end
end



---------------------------------------------------------------------------------------------------------
--										MOLE WEEKLY BOSS SKILL
---------------------------------------------------------------------------------------------------------
function DestroyItemLogic:runGameItemActionMoleWeeklyMagicTileBlastLogic(mainLogic, theAction, actid)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		theAction.jsq = 0
	end

	if theAction.addInfo == "hitTarget" then
		theAction.addInfo = ""

		for _, v in pairs(theAction.targetPositions) do
			-- printx(11, "MoleWeeklyMagicTileBlast    Hit: ("..v.y..","..v.x..")")
			local targetPoint = IntCoord:create(v.x, v.y)
			local rectangleAction = GameBoardActionDataSet:createAs(
										GameActionTargetType.kGameItemAction,
										GameItemActionType.kItemSpecial_rectangle,
										targetPoint,
										targetPoint,
										GamePlayConfig_MaxAction_time)
			rectangleAction.addInt2 = 1.5
			rectangleAction.eliminateChainIncludeHem = true
			mainLogic:addDestructionPlanAction(rectangleAction)
		end
	end

	if theAction.addInfo == 'over' then
		-- printx(11, "runGameItemActionMoleWeeklyMagicTileBlastLogic   OVER")

		if theAction.completeCallback then
			theAction.completeCallback()
		end
		mainLogic.destroyActionList[actid] = nil
	end
end

function DestroyItemLogic:runGameItemActionMoleWeeklyMagicTileBlastView(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kRunning then

		local fromRow, fromCol = theAction.ItemPos1.x, theAction.ItemPos1.y
		local fromView = boardView.baseMap[fromRow][fromCol]

		--- 播放发射光效流星
		if theAction.jsq == 0 then
			local fromPos = fromView:getBasePosition(fromCol, fromRow)
			fromPos.x = fromPos.x + fromView.w
			fromPos.y = fromPos.y - fromView.h / 2
			for _, v in pairs(theAction.targetPositions) do
				local toPos = boardView.baseMap[v.y][v.x]:getBasePosition(v.x, v.y)
				-- fromView:playMoleWeeklyBossSkillFlyTo(fromPos, toPos)
				fromView:playMoleBossSeedHitAnimation(fromPos, toPos)	--一家人，借用一下动画效果
			end
		end

		theAction.jsq = theAction.jsq + 1

		--- 击中目标
		local hitAnimationDelay = 30
		if theAction.jsq == hitAnimationDelay then
			theAction.addInfo = "hitTarget"
		end

		--- 整体结束
		local blowDurationDelay = 60
		if theAction.jsq == blowDurationDelay then
			theAction.addInfo = "over"
		end
	end
end

function DestroyItemLogic:runGameItemActionMoleWeeklyCloudDieLogic(mainLogic, theAction, actid)
	if theAction.actionStatus == GameActionStatus.kRunning  then
		theAction.actionTick = theAction.actionTick + 1
		local function cleanItem(r, c)
			local item = mainLogic.gameItemMap[r][c]
			local board = mainLogic.boardmap[r][c]
			item:cleanAnimalLikeData()
			item.isDead = false
			item.isBlock = false
			item.isNeedUpdate = true
			mainLogic:checkItemBlock(r, c)
		end

		if theAction.addInfo == "dieAction" and theAction.actionTick == 40 then
			theAction.addInfo = 'over'
			local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
			GameExtandPlayLogic:itemDestroyHandler(mainLogic, r, c)
			cleanItem(r, c)
			cleanItem(r + 1, c)
			cleanItem(r, c+1)
			cleanItem(r+ 1, c+1)
			mainLogic:setNeedCheckFalling()
			FallingItemLogic:preUpdateHelpMap(mainLogic)
		elseif theAction.addInfo == 'over' then
			if theAction.completeCallback then
				theAction.completeCallback()
			end
			mainLogic.destroyActionList[actid] = nil
    	end
	end
end

function DestroyItemLogic:runGameItemActionMoleWeeklyBossCloudDieView(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning 
		theAction.actionTick = 0
		theAction.addInfo = "dieAction"
		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local item = boardView.baseMap[r][c]
		item:playMoleWeeklyBossCloudDie()
	end
end

--
function DestroyItemLogic:runGameItemYellowDiamondDecLogic( mainLogic,  theAction, actid)
	-- body
	if theAction.actionStatus == GameActionStatus.kRunning then 
		if theAction.actionDuring == GamePlayConfig_GameItemYellowDiamondDeleteAction_CD - 4 then
			local item = mainLogic.gameItemMap[theAction.ItemPos1.x][theAction.ItemPos1.y]
			if item then item.yellowDiamondCanbeDelete = true end
		end
	end

	if theAction.actionStatus == GameActionStatus.kWaitingForDeath then
		local r = theAction.ItemPos1.x
		local c = theAction.ItemPos1.y
		local item = mainLogic.gameItemMap[r][c]
		if theAction.cleanItem then
			GameExtandPlayLogic:itemDestroyHandler(mainLogic, r, c)
			item:cleanAnimalLikeData()
			mainLogic:checkItemBlock(theAction.ItemPos1.x, theAction.ItemPos1.y)
			mainLogic:setNeedCheckFalling()
		end
		mainLogic.destroyActionList[actid] = nil
	end
end

function DestroyItemLogic:runGameItemViewYellowDiamond( boardView, theAction )
	-- body
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then 
		theAction.actionStatus = GameActionStatus.kRunning
		local r = theAction.ItemPos1.x
		local c = theAction.ItemPos1.y
		local item = boardView.baseMap[r][c]
		item:playYellowDiamondDecAnimation(boardView)
	end
end

-------------------------------------- GHOST MOVE ----------------------------------------
function DestroyItemLogic:runGameItemActionGhostMoveLogic(mainLogic, theAction, actid)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		theAction.jsq = 0
	end

	if theAction.addInfo == "animationEnd" then

		GhostLogic:refreshGameItemDataAfterGhostMove(mainLogic)
		-- printx(11, "runGameItemActionGhostMoveLogic   OVER")
		-- ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_Pacman, ObstacleFootprintAction.k_Attack, 1)

		-- theAction.addInfo = "over"
		theAction.addInfo = "updateBlockState"
		theAction.refreshViewDelay = 0
	end

	if theAction.addInfo == 'updateBlockState' then
		-- 唉……由于视图不会立即更新，所以被挤下来的对象如果马上下落的话视图会错误。所以等一下。
		if theAction.refreshViewDelay == 1 then
			-- GhostLogic:refreshBlockStateAfterGhostMove(mainLogic)	--完成幽灵收集以后再刷新状态
			theAction.addInfo = "over"
		end
		theAction.refreshViewDelay = theAction.refreshViewDelay + 1
	end

	if theAction.addInfo == 'over' then
		if theAction.completeCallback then
			theAction.completeCallback()
		end
		mainLogic.destroyActionList[actid] = nil
	end
end

function DestroyItemLogic:runGameItemActionGhostMoveView(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kRunning then
		if theAction.jsq == 0 then

			local inAnimationCount = 0

			local function completeCallback( ... )
				inAnimationCount = inAnimationCount - 1
				if inAnimationCount <= 0 then
					theAction.addInfo = "animationEnd"
				end
			end

			local downMoveSpeed = 0.2
			local upMoveSpeed1 = 0.3
			local upMoveSpeed2 = 0.4

			for r = 1, #boardView.gameBoardLogic.gameItemMap do
				for c = 1, #boardView.gameBoardLogic.gameItemMap[r] do
					local item = boardView.gameBoardLogic.gameItemMap[r][c]
					local itemView = boardView.baseMap[r][c]
					if item and itemView then
						if item.tempGhostPace ~= 0 then
							local moveSpeed
							if item.tempGhostPace > 0 then
								moveSpeed = downMoveSpeed
							else
								if item.tempGhostPace < -5 then
									moveSpeed = upMoveSpeed2
								else
									moveSpeed = upMoveSpeed1
								end
							end
							
							local sprite = itemView:getGameItemSprite()
							if sprite then
								local position = UsePropState:getItemPosition(IntCoord:create(item.y + item.tempGhostPace, item.x))

								local arr = CCArray:create()
								arr:addObject(CCDelayTime:create(0.15))
								arr:addObject(CCMoveTo:create(moveSpeed, position))
								arr:addObject(CCDelayTime:create(0.3))
								arr:addObject(CCCallFunc:create(completeCallback))
								local move_action = CCSequence:create(arr) 

								sprite:runAction(move_action)
								inAnimationCount = inAnimationCount + 1
							end

							if item:seizedByGhost() then
								itemView:playGhostFly(item.tempGhostPace)
							end
						else
							--没有可移动的步数
							if item.ghostPaceLength > 0 then
								GhostLogic:switchStatusBackToNormalWithoutMoving(boardView.gameBoardLogic, item)
							end
						end
						
					end
				end
			end

			if inAnimationCount == 0 then
				theAction.jsq = 1
				theAction.addInfo = "animationEnd"
			end
		end

		theAction.jsq = theAction.jsq + 1
	end
end

------ collect
function DestroyItemLogic:runGameItemActionGhostCollectLogic(mainLogic, theAction, actid)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		theAction.jsq = 0
	end

	if theAction.addInfo == "animationEnd" then
		for _, formerGhost in pairs(theAction.targetList) do
			local row, col = formerGhost.y, formerGhost.x
			formerGhost.coveredByGhost = false
			formerGhost.tempGhostPace = 0
			formerGhost.ghostPaceLength = 0
			mainLogic:addScoreToTotal(row, col, 100)
			GameExtandPlayLogic:doAllBlocker195Collect(mainLogic, row, col, Blocker195CollectType.kGhost)
			SquidLogic:checkSquidCollectItem(mainLogic, row, col, TileConst.kGhost)
			mainLogic:tryDoOrderList(row, col, GameItemOrderType.kOthers, GameItemOrderType_Others.kGhost, 1)

			mainLogic:checkItemBlock(row, col)
			mainLogic:addNeedCheckMatchPoint(row , col)
			mainLogic.gameMode:checkDropDownCollect(row, col)
			ColorFilterLogic:handleFilter(row, col) 	--即时检测过滤器过滤
			
			formerGhost.isNeedUpdate = true
			-- formerGhost.forceUpdate = true		--若落下类型颜色等相同，视图可能不更新。故而强制

			ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_Ghost, ObstacleFootprintAction.k_Collect, 1)
		end

		-- printx(11, "runGameItemActionGhostCollectLogic   OVER")
		theAction.addInfo = "over"
	end

	if theAction.addInfo == "over" then
		if theAction.completeCallback then
			theAction.completeCallback()
		end
		mainLogic.destroyActionList[actid] = nil
	end
end

function DestroyItemLogic:runGameItemActionGhostCollectView(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kRunning then
		if theAction.jsq == 0 then
			for _, targetGhost in pairs(theAction.targetList) do
				local itemView = boardView.baseMap[targetGhost.y][targetGhost.x]
				if itemView then
					itemView:playGhostDisappear()
				end
			end
		end

		if theAction.jsq == 40 then
			theAction.addInfo = "animationEnd"
		end

		theAction.jsq = theAction.jsq + 1
	end
end

-------------------------------------	Sunflower	-------------------------------------------------
function DestroyItemLogic:runGameItemActionSunFlaskBlastLogic(mainLogic, theAction, actid)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		theAction.jsq = 0
	end

	if theAction.addInfo == "blastEffect" then
		theAction.addInfo = ""

		local c, r = theAction.ItemPos1.x, theAction.ItemPos1.y
		local rectangleAction = GameBoardActionDataSet:createAs(
									GameActionTargetType.kGameItemAction,
									GameItemActionType.kItemSpecial_rectangle,
									IntCoord:create(c - 1, r - 1),
									IntCoord:create(c + 1, r + 1),
									GamePlayConfig_MaxAction_time)
		rectangleAction.addInt2 = 1
		-- rectangleAction.eliminateChainIncludeHem = true
		rectangleAction.footprintType = ObstacleFootprintType.k_SunFlask
		mainLogic:addDestructionPlanAction(rectangleAction)

		SnailLogic:SpecialCoverSnailRoadAtPos(mainLogic, theAction.targetFlask.y, theAction.targetFlask.x)	--需要点亮路径
	end

	if theAction.addInfo == "vanish" then
		theAction.addInfo = ""

		SunflowerLogic:onSunFlaskDestroyed(mainLogic, theAction.targetFlask)
		ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_SunFlask, ObstacleFootprintAction.k_Attack, 1)
	end

	if theAction.addInfo == "over" then
		-- printx(11, "runGameItemActionSunFlaskBlastLogic   OVER")

		if theAction.completeCallback then
			theAction.completeCallback()
		end
		mainLogic.destroyActionList[actid] = nil
	end
end

function DestroyItemLogic:runGameItemActionSunFlaskBlastView(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kRunning then
		--动画外层播放了，这里重复……
		-- if theAction.jsq == 0 then
			-- local c, r = theAction.ItemPos1.x, theAction.ItemPos1.y
			-- local itemView = boardView.baseMap[r][c]
			-- itemView:playSunFlaskBeingHit()
		-- end 		

		theAction.jsq = theAction.jsq + 1

		--- 释放瓶中太阳
		local addSunDelay = 9
		if theAction.jsq == addSunDelay then
			-- theAction.addInfo = "addSun"
			if theAction.targetSunflower then 	--场上没有向日葵就不播放释放太阳
				local sunflowerView = boardView.baseMap[theAction.targetSunflower.y][theAction.targetSunflower.x]
				if sunflowerView then
					if theAction.targetSunflower:isVisibleAndFree() then
						local flaskView = boardView.baseMap[theAction.ItemPos1.y][theAction.ItemPos1.x]
						local fromPos = flaskView:getBasePosition(theAction.ItemPos1.x, theAction.ItemPos1.y)
						local toPos = sunflowerView:getBasePosition(theAction.targetSunflower.x, theAction.targetSunflower.y)
						sunflowerView:playSunflowerAbsorbSun(fromPos, toPos)
					else
						sunflowerView:decreaseSunflowerNumViewRespectively()	--不显示在明面上的，削减数字就行
					end
				end
			end
		end

		--- 震荡波效果
		local blastAnimationDelay = 14
		if theAction.jsq == blastAnimationDelay then
			theAction.addInfo = "blastEffect"
		end

		-- 自身消失
		local vanishDelay = blastAnimationDelay + 17
		if theAction.jsq == vanishDelay then
			theAction.addInfo = "vanish"
		end

		--- 整体结束（考虑等待太阳被向日葵吃掉的动画）
		local blowDurationDelay = 60
		if theAction.jsq == blowDurationDelay then
			theAction.addInfo = "over"
		end
	end
end

-----
function DestroyItemLogic:runGameItemActionSunFlowerBlastLogic(mainLogic, theAction, actid)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		theAction.jsq = 0
	end

	if theAction.addInfo == "blastEffect" then
		theAction.addInfo = ""

		local rectangleAction = GameBoardActionDataSet:createAs(
									GameActionTargetType.kGameItemAction,
									GameItemActionType.kItemSpecial_rectangle,
									IntCoord:create(0, 0),
									IntCoord:create(9, 9),
									GamePlayConfig_MaxAction_time)
		rectangleAction.addInt2 = 1
		-- rectangleAction.eliminateChainIncludeHem = true
		mainLogic:addDestructionPlanAction(rectangleAction)

		SnailLogic:SpecialCoverSnailRoadAtPos(mainLogic, theAction.targetFlower.y, theAction.targetFlower.x)	--需要点亮路径

		GamePlayMusicPlayer:playEffect(GameMusicType.kSunflowerBlast)
	end

	-- if theAction.addInfo == "deleteSelf" then
	-- 	theAction.addInfo = ""
	-- 	SunflowerLogic:onSunFlowerDestroyed(mainLogic, theAction.targetFlower)
	-- end

	if theAction.addInfo == "over" then
		-- printx(11, "runGameItemActionSunFlowerBlastLogic   OVER")
		SunflowerLogic:onSunFlowerDestroyed(mainLogic, theAction.targetFlower)

		if theAction.completeCallback then
			theAction.completeCallback()
		end
		mainLogic.destroyActionList[actid] = nil
	end
end

function DestroyItemLogic:runGameItemActionSunFlowerBlastView(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kRunning then
		if theAction.jsq == 0 then
			theAction.addInfo = "blastEffect"
		end

		theAction.jsq = theAction.jsq + 1

		-- if theAction.jsq == 2 then
		-- 	theAction.addInfo = "deleteSelf"
		-- end

		--- 整体结束
		local blowDurationDelay = 10
		if theAction.jsq == blowDurationDelay then
			theAction.addInfo = "over"
		end
	end
end

------------------------------------------------------------------------------
--										Squid
------------------------------------------------------------------------------
--------- Collect
function DestroyItemLogic:runGameItemActionSquidCollectLogic(mainLogic, theAction, actid)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		theAction.jsq = 0
	end

	if theAction.addInfo == "over" then
		-- printx(11, "runGameItemActionSquidCollectLogic   OVER")
		if theAction.completeCallback then
			theAction.completeCallback()
		end
		mainLogic.destroyActionList[actid] = nil
	end
end

function DestroyItemLogic:runGameItemActionSquidCollectView(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kRunning then
		if theAction.jsq == 0 then
			local targetSquid = theAction.targetSquid
			local newTargetAmount = theAction.newTargetAmount

			local squidView = boardView.baseMap[targetSquid.y][targetSquid.x]
			local fromPos
			if theAction.ItemPos1 then
				fromPos = squidView:getBasePosition(theAction.ItemPos1.x, theAction.ItemPos1.y)
			end
			local toPos = squidView:getBasePosition(targetSquid.x, targetSquid.y)
			squidView:playSquidTargetFly(fromPos, toPos, newTargetAmount)
		end

		theAction.jsq = theAction.jsq + 1

		--- 整体结束
		local wholeDurationDelay = 60
		if theAction.newTargetAmount >= theAction.targetSquid.squidTargetNeeded then
			wholeDurationDelay = 120	--如果充满了，会有更多动画，等待时间延长
		end
		if theAction.jsq == wholeDurationDelay then
			theAction.addInfo = "over"
		end
	end
end

--------- Run
function DestroyItemLogic:runGameItemActionSquidRunLogic(mainLogic, theAction, actid)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		local targetGrids = theAction.targetGrids
		local headpos = targetGrids[1]
		local direction = theAction.targetSquid.squidDirection
		local addr,addc
		if direction == SquidDirection.kUp then
			addr,addc = 1, 0
		elseif direction == SquidDirection.kRight then
			addr,addc = 0, 1
		elseif direction == SquidDirection.kDown then
			addr,addc = -1, 0
		elseif direction == SquidDirection.kLeft then
			addr,addc = 0, 1
		end
		local firstpos = IntCoord:create(headpos.r + addr, headpos.c + addc)
		theAction.SpecialID1, theAction.SpecialID2 = mainLogic:addSrcSpecialCoverToList( firstpos, IntCoord:create(headpos.r, headpos.c) )

		local jamList = {}
		local SpecialID, JamStopNum, JamStop

		SpecialID = theAction.SpecialID2 or theAction.SpecialID1

		for i,target in ipairs(targetGrids) do
			if i > 1 then
				local curpos = IntCoord:create(target.r, target.c)
				local nextpos = targetGrids[i+1]
				if nextpos then
					nextpos = IntCoord:create(nextpos.r, nextpos.c)
				else
					nextpos = IntCoord:create(-1, -1)
				end
				local boardData = mainLogic.boardmap[target.r][target.c]
				if boardData.isJamSperad then
					JamStop = false
					JamStopNum = 0
				end

				SpecialID, JamStopNum, JamStop = DestructionPlanLogic:JamSperadSpecialIDCheck(
					mainLogic,
					curpos,
					nextpos,
					JamStop or false,
					JamStopNum or 0,
					SpecialID,
					SquidLogic:isJustRemoveItem(target)
				)

				jamList[i] = SpecialID
			end
		end
		theAction.jamList = jamList

		for _, targetPos in pairs(targetGrids) do
			if mainLogic.gameItemMap[targetPos.r] and mainLogic.gameItemMap[targetPos.r][targetPos.c] then
				local toLockItem = mainLogic.gameItemMap[targetPos.r][targetPos.c]
				if toLockItem then
					-- printx(11, "* add lock")
					toLockItem:addSquidLockValue()
					mainLogic:checkItemBlock(toLockItem.y, toLockItem.x)
				end
			end
		end

		mainLogic:addScoreToTotal(theAction.targetSquid.y, theAction.targetSquid.x, GamePlayConfigScore.MatchBySnow)
		ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_Squid, ObstacleFootprintAction.k_Attack, 1)
		ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_Squid, ObstacleFootprintAction.k_HitTargets, theAction.gridAmount - 1) --包含自己的一个格子

		theAction.actionStatus = GameActionStatus.kRunning
		theAction.jsq = 0
	end

	--kItem_Squid_BombGrid
	if theAction.addInfo == "startBombItem" then
		theAction.startBomb = true
		theAction.bombedGridAmount = 0
		theAction.bombFrameGap = 1

		theAction.addInfo = ""
	end

	if theAction.startBomb then
		theAction.bombFrameGap = theAction.bombFrameGap - 1
		if theAction.bombFrameGap <= 0 then
			local targetGridItem
			local currPos = theAction.targetGrids[theAction.bombedGridAmount + 1]
			if currPos and mainLogic.gameItemMap[currPos.r] then
				targetGridItem = mainLogic.gameItemMap[currPos.r][currPos.c]
			end

			if targetGridItem then
				-- targetGridItem:reduceSquidLockValue()
				-- if not targetGridItem:hasSquidLock() then
					if theAction.bombedGridAmount < 1 then
						--章鱼头部的格子
						theAction.targetSquidHead = targetGridItem
						if theAction.SpecialID1 or theAction.SpecialID2 then
							GameExtandPlayLogic:addJamSperadFlag(mainLogic, currPos.r, currPos.c, true )
						end
					else
						--其他格子
						local bombAction = GameBoardActionDataSet:createAs(
													GameActionTargetType.kGameItemAction,
													GameItemActionType.kItem_Squid_BombGrid,
													nil,
													nil,
													GamePlayConfig_MaxAction_time)

						local nextpos = theAction.targetGrids[theAction.bombedGridAmount + 2]
						if nextpos then
							nextpos = IntCoord:create(nextpos.r, nextpos.c)
						else
							nextpos = IntCoord:create(-1, -1)
						end

						bombAction.targetItem = targetGridItem
						bombAction.nextPos = nextpos
						bombAction.squidDirection = theAction.targetSquid.squidDirection
						bombAction.SpecialID = theAction.jamList[theAction.bombedGridAmount + 1]
						-- bombAction.jamList = theAction.jamList
						-- mainLogic:addDestroyAction(bombAction)
						mainLogic:addDestructionPlanAction(bombAction)
					end
				-- end
			end
			
			theAction.bombedGridAmount = theAction.bombedGridAmount + 1
			theAction.bombFrameGap = 2	--每几帧炸一个格子
		end

		if theAction.bombedGridAmount >= (theAction.gridAmount + 1) then
			theAction.startBomb = false
		end
	end

	if theAction.addInfo == "animationEnded" then
		mainLogic:tryDoOrderList(theAction.targetSquid.y, theAction.targetSquid.x, GameItemOrderType.kOthers, GameItemOrderType_Others.kSquid, 1)
		SquidLogic:removeSquidDataOfGrid(mainLogic, theAction.targetSquid)	--最后清除鱿鱼格子的数据
		theAction.targetSquidHead:cleanSquidLock()
		SquidLogic:removeSquidDataOfGrid(mainLogic, theAction.targetSquidHead)

		theAction.addInfo = "over"
	end

	if theAction.addInfo == "over" then
		-- printx(11, "runGameItemActionSquidCollectLogic   OVER")
		if theAction.completeCallback then
			theAction.completeCallback()
		end
		mainLogic.destroyActionList[actid] = nil
	end
end

function DestroyItemLogic:runGameItemActionSquidRunView(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kRunning then
		if theAction.jsq == 0 then
			local targetSquid = theAction.targetSquid
			local gridAmount = theAction.gridAmount	--由于鱿鱼帽子的缘故，此值必 >= 1

			local squidView = boardView.baseMap[targetSquid.y][targetSquid.x]
			local startPos = squidView:getBasePosition(theAction.targetSquid.x, theAction.targetSquid.y)
			squidView:playSquidRun(gridAmount, startPos)
		end

		theAction.jsq = theAction.jsq + 1
		-- printx(11, "* * *", theAction.jsq)

		local startBombDelay = 75
		if theAction.jsq == startBombDelay then
			theAction.addInfo = "startBombItem"
		end

		--- 整体结束
		local wholeDurationDelay = 100	--注意这个值不要比 startBombDelay + gridAmount * bombFrameGap 要小，不然处理不完被炸的格子
		if theAction.jsq == wholeDurationDelay then
			theAction.addInfo = "animationEnded"
		end
	end
end


--万生被打
function DestroyItemLogic:runningGameItemActionWanShengIncrease(mainLogic, theAction, actid, actByView)
	-- body
    if theAction.addInfo == "NeedUpdate" then
        local r = theAction.ItemPos1.x
		local c = theAction.ItemPos1.y

        local itemData = mainLogic.gameItemMap[r][c]
--        itemData.isNeedUpdate = true

        theAction.addInfo = "over"
    elseif theAction.addInfo == "over" then
        mainLogic.destroyActionList[actid] = nil
    end
end

function DestroyItemLogic:runGameItemActionWanShengInc(boardView, theAction)
	-- body
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		local r = theAction.ItemPos1.x
		local c = theAction.ItemPos1.y
		local itemView = boardView.baseMap[r][c]
		itemView:playWanShengDec(theAction.addInt)

        theAction.jsq = 0
        theAction.UpdateCDTime = 1

        local level1To2NeedCD = 52
        local level2To3NeedCD = 59

        local itemData = boardView.gameBoardLogic.gameItemMap[r][c]
        if itemData.wanShengLevel == 2 then
            theAction.UpdateCDTime = level1To2NeedCD
        elseif itemData.wanShengLevel == 3 then
            theAction.UpdateCDTime = level1To2NeedCD + level2To3NeedCD
        end
	end

    if theAction.actionStatus == GameActionStatus.kRunning then
        if theAction.jsq == theAction.UpdateCDTime then
            theAction.addInfo = "NeedUpdate"
        end

        theAction.jsq = theAction.jsq + 1
    end
end


--春节技能1
function DestroyItemLogic:runningGameItemActionSprintFestival2019Skill1Logic(mainLogic, theAction, actid, actByView)

	-- body
    if theAction.addInfo == "initPosInfo" then
        local randomPos = mainLogic.randFactory:rand(1, #theAction.canBeInfectItemList)
        theAction.PosInfo = theAction.canBeInfectItemList[randomPos]

        theAction.addInfo = "playAnim"
    elseif theAction.addInfo == "changeItem" then
--        local randomPos = mainLogic.randFactory:rand(1, #theAction.canBeInfectItemList)
--        local PosInfo = theAction.canBeInfectItemList[randomPos]
        local PosInfo = theAction.PosInfo

        local gameItemMap = mainLogic.gameItemMap
        if gameItemMap[PosInfo.x] and gameItemMap[PosInfo.x][PosInfo.y] then
            local item = gameItemMap[PosInfo.x][PosInfo.y]
            item:changeToLineAnimal()

            theAction.jsq = 0
            theAction.addInfo = "waitOver"
        else
            theAction.addInfo = "over"
        end
    elseif theAction.addInfo == "waitOver" then
        if theAction.jsq == 20 then
            theAction.addInfo = "over"
        end
    elseif theAction.addInfo == "over" then
        mainLogic.destroyActionList[actid] = nil
    end
end

function DestroyItemLogic:runGameItemActionSprintFestival2019Skill1View(boardView, theAction)
	-- body
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning

        theAction.jsq = 0
		theAction.addInfo = "initPosInfo"
	end

    if theAction.actionStatus == GameActionStatus.kRunning then

        if theAction.addInfo == "playAnim" then

            local r = theAction.PosInfo.x
            local c = theAction.PosInfo.y
		    local item = boardView.baseMap[r][c]
            local toWorldPos =  boardView:convertToWorldSpace(item:getBasePosition(c, r))
            SpringFestival2019Manager.getInstance():playSpringFestivalAnim1( theAction.WorldSpace, toWorldPos )

            theAction.jsq = 0
            theAction.addInfo = "waitAnimEnd"
        elseif  theAction.addInfo == "waitAnimEnd" then
            if theAction.jsq == 20 then
                theAction.addInfo = "changeItem"
            end
        end

        theAction.jsq = theAction.jsq + 1
    end
end


--春节技能2
function DestroyItemLogic:runningGameItemActionSprintFestival2019Skill2Logic(mainLogic, theAction, actid, actByView)
	-- body
   if theAction.addInfo == "over" then
        mainLogic.destroyActionList[actid] = nil
    end
end

function DestroyItemLogic:runGameItemActionSprintFestival2019Skill2View(boardView, theAction)
	-- body
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
	end

    if theAction.actionStatus == GameActionStatus.kRunning then
        SpringFestival2019Manager.getInstance():playSpringFestivalAnim2( theAction.WorldSpace )

        theAction.addInfo = "over" 
--        theAction.jsq = theAction.jsq + 1
    end
end


--春节技能3
function DestroyItemLogic:runningGameItemActionSprintFestival2019Skill3Logic(mainLogic, theAction, actid, actByView)
    -- body
	local function overAction( ... )
		-- body
		theAction.addInfo = ""
		mainLogic.destroyActionList[actid] = nil
		if theAction.completeCallback then 
			theAction.completeCallback()
		end
		mainLogic:setNeedCheckFalling()
	end

	local function bombItem(r, c, dirs)
		-- body
		local item = mainLogic.gameItemMap[r][c]
		local boardData = mainLogic.boardmap[r][c]

        if item.isUsed then
		    BombItemLogic:tryCoverByBomb(mainLogic, r, c, true, 1)
		    SpecialCoverLogic:SpecialCoverAtPos(mainLogic, r, c, 3,nil,nil,nil,nil,nil) 
		    SpecialCoverLogic:specialCoverChainsAtPos(mainLogic, r, c, dirs) --冰柱处理
		    SpecialCoverLogic:SpecialCoverLightUpAtPos(mainLogic, r, c, 1)
		    GameExtandPlayLogic:doABlocker211Collect(mainLogic, nil, nil, r, c, item._encrypt.ItemColorType, false, 3)

            --背景高亮
            local view = mainLogic.boardView.baseMap[r][c]
            view:playBonusTimeEffcet()
        end
	end

	if theAction.addInfo == "over" then
		local r_min = theAction.ItemPos1.x
		local r_max = theAction.ItemPos2.x
		local c_min = theAction.ItemPos1.y
		local c_max = theAction.ItemPos2.y

        ---3*2格子
		for r = r_min , r_max do 
			for c = c_min, c_max do 
				local dirs = {ChainDirConfig.kUp, ChainDirConfig.kDown, ChainDirConfig.kRight, ChainDirConfig.kLeft}
				if r == r_min then 
					table.remove(dirs, ChainDirConfig.kUp)
				elseif r == r_max then 
					table.remove(dirs, ChainDirConfig.kDown)
				elseif c == c_min then 
					table.remove(dirs, ChainDirConfig.kLeft)
				elseif c == c_max then 
					table.remove(dirs, ChainDirConfig.kRight)
				end
				bombItem(r, c, dirs )
			end
		end

		overAction()
	end
end

function DestroyItemLogic:runGameItemActionSprintFestival2019Skill3View(boardView, theAction)
	-- body
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning

        local r_min = theAction.ItemPos1.x
		local r_max = theAction.ItemPos2.x
		local c_min = theAction.ItemPos1.y
		local c_max = theAction.ItemPos2.y
		
        --view 展示
        theAction.addInfo = "waitForAnimation"
		theAction.jsq = 0
        theAction.animationStartDelay = theAction.delayIndex * 5
        theAction.animationDelay = 25
	end

    if theAction.actionStatus == GameActionStatus.kRunning then
        if theAction.addInfo == "waitForAnimation" then
            if theAction.jsq == theAction.animationStartDelay then
                local r_min = theAction.ItemPos1.x
		        local r_max = theAction.ItemPos2.x
		        local c_min = theAction.ItemPos1.y
		        local c_max = theAction.ItemPos2.y

                ---2*2格子
		        local item = boardView.baseMap[r_min][c_min]
                local toWorldPos =  boardView:convertToWorldSpace(item:getBasePosition(c_min, r_min))
                SpringFestival2019Manager.getInstance():playSpringFestivalAnim3( theAction.WorldSpace, toWorldPos )

                theAction.addInfo = "playAnimation"
                theAction.jsq = 0
            end
        elseif theAction.addInfo == "playAnimation" then
            if theAction.jsq == theAction.animationDelay then
			    theAction.addInfo = "over" 
		    end
	    end

        theAction.jsq = theAction.jsq + 1
    end

    
end


--春节技能4
function DestroyItemLogic:runningGameItemActionSprintFestival2019Skill4Logic(mainLogic, theAction, actid, actByView)
	-- body
    if theAction.addInfo == "changeItem" then
        local gameItemMap = mainLogic.gameItemMap
        for i,v in ipairs(theAction.PosList) do
            if gameItemMap[v.x] and gameItemMap[v.x][v.y] then
                local item = gameItemMap[v.x][v.y]
--                item:changeToLineAnimal()

                local lineColumnRandList = {AnimalTypeConfig.kLine, AnimalTypeConfig.kColumn}
				local resultSpecialType = lineColumnRandList[mainLogic.randFactory:rand(1, 2)]
				GameExtandPlayLogic:itemDestroyHandler(mainLogic, v.x, v.y)

				item.ItemType = GameItemType.kAnimal
				item.ItemSpecialType = resultSpecialType
				item.isNeedUpdate = true
            end
        end

        theAction.jsq = 0
        theAction.addInfo = "waitboom"
    elseif theAction.addInfo == "waitboom" then
        if theAction.jsq == 20 then
            theAction.addInfo = "boom"
        end
    elseif theAction.addInfo == "boom" then

        local gameItemMap = mainLogic.gameItemMap
        for i,v in ipairs(theAction.PosList) do

            local r = v.x
            local c = v.y
            local item = gameItemMap[r][c]

            if item then
                item:AddItemStatus(GameItemStatusType.kIsSpecialCover)
            end
        end
        
        theAction.addInfo = "over"
    elseif theAction.addInfo == "over" then
        mainLogic.destroyActionList[actid] = nil
    end
end

function DestroyItemLogic:runGameItemActionSprintFestival2019Skill4View(boardView, theAction)
	-- body
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning

        --view 展示
        theAction.addInfo = "waitForAnimation"
		theAction.jsq = 0
        theAction.animationDelay = 90
	end

    if theAction.actionStatus == GameActionStatus.kRunning then

         if theAction.addInfo == "waitForAnimation" then

            local toWorldPosList = {}
            for i,v in ipairs(theAction.PosList) do
                local r = v.x
                local c = v.y
                local item = boardView.baseMap[r][c]
                local toWorldPos =  boardView:convertToWorldSpace(item:getBasePosition(c, r))
                table.insert( toWorldPosList, toWorldPos )
            end

            SpringFestival2019Manager.getInstance():playSpringFestivalAnim4( theAction.WorldSpace, toWorldPosList )

		    theAction.addInfo = "playAnimation"
            theAction.jsq = 0

        elseif theAction.addInfo == "playAnimation" then
            if theAction.jsq == theAction.animationDelay then
			    theAction.addInfo = "changeItem" 
		    end
	    end

        theAction.jsq = theAction.jsq + 1
    end
end

function DestroyItemLogic:runningGameItemActionApplyMilkLogic( mainLogic, theAction, actid )
	if theAction.addInfo == "ready" then
        theAction.addInfo = "updateView"
        theAction.jsq = 0
    elseif theAction.addInfo == "waiting" then
    	theAction.jsq = theAction.jsq + 1
        if theAction.jsq == 20 then
	        theAction.addInfo = "over"
        end
    elseif theAction.addInfo == "over" then
    	ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_Biscuit, ObstacleFootprintAction.k_Charge, 1)
        mainLogic.destroyActionList[actid] = nil
    end
end

function DestroyItemLogic:runningGameItemActionApplyMilkView( boardView, theAction )
	if theAction.addInfo == "updateView" then
        local itemView = boardView.baseMap[theAction.ItemPos1.x][theAction.ItemPos1.y]
        itemView:playAppkyMilkAnim(theAction.addBiscuitData, theAction.ItemPos2.x, theAction.ItemPos2.y)
        theAction.addInfo = "waiting"
    end
end