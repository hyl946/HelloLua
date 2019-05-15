require "zoo.gamePlay.BoardAction.GameBoardActionDataSet"
require "zoo.gamePlay.BoardLogic.HanleBeforeFallingLogic"
require "zoo.gamePlay.BoardLogic.FallingItemLogic"
require "zoo.gamePlay.BoardLogic.SpecialCoverLogic"
require "zoo.config.MoleWeeklyRaceConfig"
--用来跑游戏动作逻辑的
GameBoardActionRunner = class{}


----每次每个循环调用这里一次
function GameBoardActionRunner:runActionList(mainLogic, actByView)
	if mainLogic == nil or mainLogic.gameActionList == nil then return end

	local maxIndex = table.maxn(mainLogic.gameActionList)
	for i = 1 , maxIndex do
		local atc = mainLogic.gameActionList[i]
		if atc then
			if atc.actionTarget == GameActionTargetType.kGameItemAction then
				GameBoardActionRunner:runGameItemAction(mainLogic, atc, i, actByView)
			end
		end
	end
	--[[
	for k,v in pairs(mainLogic.gameActionList) do
		if v.actionTarget == GameActionTargetType.kGameItemAction then
			GameBoardActionRunner:runGameItemAction(mainLogic, v, k, actByView)
		end
	end
	]]
end

function GameBoardActionRunner:runGameItemAction(mainLogic, theAction, actid, actByView)

	
	if actByView == false and theAction.actionStatus == GameActionStatus.kWaitingForStart then 		----非View驱动，纯数据的，直接进入Running状态
		theAction.actionStatus = GameActionStatus.kRunning
	end
	
	if theAction.actionStatus == GameActionStatus.kRunning then 		---running阶段，自动扣时间，到时间了，进入Death阶段
		if theAction.actionDuring < 0 then 
			theAction.actionStatus = GameActionStatus.kWaitingForDeath
		else
			theAction.actionDuring = theAction.actionDuring - 1
			GameBoardActionRunner:runningGameItemAction(mainLogic, theAction, actid, actByView)
		end
	end
-------------------------------------------------------------------------------------------------------------结束时--------------
	if theAction.actionType == GameItemActionType.kItem_Furball_Brown_Unstable then
		GameBoardActionRunner:runGameItemSpecialFurballUnstable(mainLogic, theAction, actid, actByView)
	else
		------没有特别指明的类型，当到达Death阶段的时候，进行动作删除----
		if theAction.actionStatus == GameActionStatus.kWaitingForDeath then
			if theAction.actionType == GameBoardActionType.kItem_Special_Mix then
				mainLogic:addNeedCheckMatchPoint(theAction.ItemPos1.x, theAction.ItemPos1.y)
				mainLogic:setNeedCheckFalling()
			end
			mainLogic.gameActionList[actid] = nil;
		end
	end
end


function GameBoardActionRunner:runningGameItemAction(mainLogic, theAction, actid, actByView)
	-- if _G.isLocalDevelopMode then printx(0, 'run GameBoardActionRunner:runningGameItemAction') end
	if theAction.actionType == GameItemActionType.kItemScore_Get then
		GameBoardActionRunner:runningGameItemScoreGet(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItemRefresh_Item_Flying then
		GameBoardActionRunner:runningGameItemRefresh_Item_Flying(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_Crystal_Change then
		GameBoardActionRunner:runningGameItem_Crystal_Change(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_Venom_Spread then
		GameBoardActionRunner:runningGameItem_Venom_Spread(mainLogic, theAction, actid, actByView)	
	elseif theAction.actionType == GameItemActionType.kItem_Furball_Transfer then
		GameBoardActionRunner:runningGameItem_Furball_Transfer(mainLogic, theAction, actid, actByView)		
	elseif theAction.actionType == GameItemActionType.kItem_Furball_Split then
		GameBoardActionRunner:runningGameItem_Furball_Split(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_Roost_Replace then
		GameBoardActionRunner:runningGameItem_Roost_Replace(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_Balloon_update then 
		GameBoardActionRunner:runningGameItem_BalloonUpdate( mainLogic, theAction, actid, actByView )
	elseif theAction.actionType == GameItemActionType.kItem_balloon_runAway then
		GameBoardActionRunner:runGameItemlogicActionBalloonRunaway(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_ItemChangeToIngredient then 
		GameBoardActionRunner:runningGameItemlogicActionChangeToIngredient( mainLogic, theAction, actid, actByView )
	elseif theAction.actionType == GameItemActionType.kItem_ItemForceToMove then 
		GameBoardActionRunner:runningGameItemLogicActionForceMoveItem( mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_TileBlocker_Update then 
		GameBoardActionRunner:runningGameItemActionTileBlockerUpdate(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_DoubleSideTileBlocker_Update then 
		GameBoardActionRunner:runningGameItemActionDoubleSideTileBlockerUpdate(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_Monster_Destroy_Item then
		GameBoardActionRunner:runningGameItemActionMonsterDestroyItem(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_PM25_Update then
		GameBoardActionRunner:runningGameItemActionUpdatePM25(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_Black_Cute_Ball_Update then
		GameBoardActionRunner:runningGameItemActionBlackCuteBallUpdate(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_Mimosa_Grow then
		GameBoardActionRunner:runningGameItemActionMimosaGrow(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_Mimosa_back then
		GameBoardActionRunner:runningGameItemActionMimosaBack(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_Mimosa_Ready then
		GameBoardActionRunner:runningGameItemActionMimosaReady(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_Snail_Road_Bright then
		GameBoardActionRunner:runningGameItemActionSnailRoadBright(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_Hedgehog_Road_State then
		GameBoardActionRunner:runningGameItemActionHedgehogRoadState(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_Snail_Product then
		GameBoardActionRunner:runningGameItemActionProductSnail(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_Mayday_Boss_Jump then
		GameBoardActionRunner:runnningGameItemActionBossJump(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_Rabbit_Product then
		GameBoardActionRunner:runningGameItemActionProductRabbit(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_Transmission then
		GameBoardActionRunner:runningGameItemActionTransmission(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kOctopus_Change_Forbidden_Level then
		GameBoardActionRunner:runningGameItemActionOctopusChangeForbiddenLevel(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_Area_Destruction then
		GameBoardActionRunner:runningGameItemActionDestroyArea(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_Magic_Lamp_Casting then
		GameBoardActionRunner:runningGameItemActionMagicLampCasting(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_Wukong_CheckAndChangeState then
		GameBoardActionRunner:runGameItemActionWukongCheckAndChangeState(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_Wukong_Gift then
		GameBoardActionRunner:runGameItemActionWukongGift(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_Wukong_Reinit then
		GameBoardActionRunner:runGameItemActionWukongReinit(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_Wukong_JumpToTarget then
		GameBoardActionRunner:runGameItemActionWukongJumping(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_Magic_Lamp_Reinit then
		GameBoardActionRunner:runningGameItemActionMagicLampReinit(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_Honey_Bottle_Broken then
		GameBoardActionRunner:runningGameItemActionHoneyBottleBroken(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_Magic_Tile_Hit then
		GameBoardActionRunner:runningGameItemActionMagicTileHit(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_Magic_Tile_Change then
		GameBoardActionRunner:runningGameItemActionMagicTileChange(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_Sand_Transfer then
		GameBoardActionRunner:runningGameItemActionSandTransfer(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_mayday_boss_casting then
		GameBoardActionRunner:runningGameItemActionMaydayBossCasting(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_Hedgehog_Clean_Dig_Groud then
		GameBoardActionRunner:runningGameItemActionCleanDigGround(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_Hedgehog_Box_Change then
		GameBoardActionRunner:runningGameItemActionHedgehogBoxChange(mainLogic, theAction, actid, actByView)
	elseif  theAction.actionType == GameItemActionType.kItem_Hedgehog_Release_Energy then
		GameBoardActionRunner:runningGameItemActionHedgehogReleaseEnergy(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItemSpecial_CrystalStone_Flying then
		GameBoardActionRunner:runningGameitemActionCrystalStoneFlying(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_Update_Lotus then
		GameBoardActionRunner:runningGameitemActionUpdateLotus(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_SuperCute_Recover then
		GameBoardActionRunner:runningGameItemActionRecoverSuperCute(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_SuperCute_Transfer then
		GameBoardActionRunner:runningGameItemActionTransferSuperCute(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_ChickenMonther_Cast then
		GameBoardActionRunner:runGameItemActionChickenMontherCast(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kBonus_Step_To_Line then
		GameBoardActionRunner:runningGameItemActionBonusStepToLine(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_Generate_Blocker_Cover then
		GameBoardActionRunner:runningGameItemActionGenerateBlockerCover(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_Blocker199_Reinit then
		GameBoardActionRunner:runningGameItemActionBlocker199Reinit(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_ColorFilter_Filter then
		GameBoardActionRunner:runningGameItemActionColorFilterFilter(mainLogic, theAction, actid, actByView)
    elseif theAction.actionType == GameItemActionType.kItem_WanSheng_Broken then
		GameBoardActionRunner:runningGameItemActionWanShengBroken(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_AddNewBiscuit then
		GameBoardActionRunner:runningGameItemActionAddNewBiscuit(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItem_CollectBiscuit then
		GameBoardActionRunner:runningGameItemActionCollectBiscuit(mainLogic, theAction, actid, actByView)
	end
end

function GameBoardActionRunner:runningGameItemActionColorFilterFilter(mainLogic, theAction, actid, actByView)
	if theAction.addInfo == 'over' then
		if theAction.completeCallback then
			theAction.completeCallback()
		end
		mainLogic.gameActionList[actid] = nil
	end
end

function GameBoardActionRunner:runningGameItemActionGenerateBlockerCover(mainLogic, theAction, actid, actByView)
	local r = theAction.ItemPos1.x
	local c = theAction.ItemPos1.y

	if theAction.addInfo == "doGenerate" then
		local originItem = mainLogic.gameItemMap[r][c]
		local originBoard = mainLogic.boardmap[r][c]
		local generateAmount = 0

		local function doGenerate(level , list)
			--printx( 1 , "   doGenerate  level = " , level , "  #list = " , #list)
			if list and #list > 0 then

				for k,v in ipairs(list) do

					local item = mainLogic.gameItemMap[v.r][v.c]
					if item then
						item.blockerCoverLevel = level

						if item.ItemType == GameItemType.kMimosa 
							or item.ItemType == GameItemType.kKindMimosa
							or item.beEffectByMimosa ~= 0
							then
							GameExtandPlayLogic:backMimosa( mainLogic, v.r, v.c )
							mainLogic:setNeedCheckFalling()
						end

						mainLogic:checkItemBlock(v.r,v.c)
						item.isNeedUpdate = true

						generateAmount = generateAmount + 1
					end
				end
			end

		end

		doGenerate( 1 , theAction.list_1 )
		doGenerate( 2 , theAction.list_2 )
		doGenerate( 3 , theAction.list_3 )

		originBoard.blockerCoverMaterialLevel = 0
		originBoard.isNeedUpdate = true

		ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_BlockerCoverMaterial, ObstacleFootprintAction.k_GenerateSubItem, generateAmount)

		theAction.addInfo = "watingForOver"
		theAction.jsq = 0
	elseif theAction.addInfo == "watingForOver" then
		theAction.jsq = theAction.jsq + 1
		if theAction.jsq > 50 then
			theAction.addInfo = "over"
		end
	elseif theAction.addInfo == "over" then

		--mainLogic:tryBombSuperTotemsByForce()
		--SnailLogic:SpecialCoverSnailRoadAtPos( mainLogic, r, c)
		if theAction.completeCallback then
			theAction.completeCallback()
		end
		mainLogic.gameActionList[actid] = nil 
	end
end

function GameBoardActionRunner:runningGameItemActionBonusStepToLine(mainLogic, theAction, actid, actByView)
	if theAction.addInfo == "start" then
		theAction.addInfo = "wait1"
		theAction.actionTick = 0

		local function onFlyEndCallback()
			local specialType = theAction.addInt
			local pos = theAction.ItemPos1
			local item = mainLogic.gameItemMap[pos.x][pos.y]
			local bonusTimeScore = GamePlayConfigScore.BonusTimeScore -- 2500
			if item.ItemType == GameItemType.kAnimal then
				theAction.addInt1 = item._encrypt.ItemColorType
				item:changeItemType(item._encrypt.ItemColorType, specialType)
				item.isNeedUpdate = true

				theAction.addInfo = "flyEnd"
				theAction.actionTick = 0
			else
				theAction.addInfo = "finish"
			end

			mainLogic:addScoreToTotal(pos.x, pos.y, bonusTimeScore, item._encrypt.ItemColorType)

            --春节送小动物
            if SpringFestival2019Manager.getInstance():getCurIsAct() and SpringFestival2019Manager.getInstance():getFlyPigLeftNum() > 0 then
                local leftNum = SpringFestival2019Manager.getInstance():getFlyPigLeftNum()

                local EndMoveSkillIndex = SpringFestival2019Manager.getInstance().EndMoveSkillIndex
                local EndMoveSkillID = SpringFestival2019Manager.getInstance().EndMoveSkillID
                local maxNum = #EndMoveSkillIndex
                local curIndex = maxNum-leftNum+1

                mainLogic.PlayUIDelegate:flySpring2019AddNumAnimation( pos.x, pos.y, EndMoveSkillID[curIndex] )
                PigYearLogic:addGemByIndex( EndMoveSkillIndex[curIndex], 1 )

                SpringFestival2019Manager.getInstance():setFlyPigNumChange()
            end
		end

		local pos = theAction.ItemPos1
		local from = mainLogic.PlayUIDelegate.gameBoardView.moveCountPos
		local to = mainLogic:getGameItemPosInView(pos.x, pos.y)
		local star = BonusFallingStar:create(from, to, nil, onFlyEndCallback)
		GamePlayMusicPlayer:playEffect(GameMusicType.kBonusStepToLine)
		mainLogic.PlayUIDelegate.effectLayer:addChild(star)
	-- elseif theAction.addInfo == "wait1" then
	-- 	theAction.actionTick = theAction.actionTick + 1
	-- 	if theAction.actionTick == 25 then
	-- 		local specialType = theAction.addInt
	-- 		local pos = theAction.ItemPos1
	-- 		local item = mainLogic.gameItemMap[pos.x][pos.y]
	-- 		local bonusTimeScore = GamePlayConfigScore.BonusTimeScore -- 2500
	-- 		if item.ItemType == GameItemType.kAnimal then
	-- 			theAction.addInt1 = item._encrypt.ItemColorType
	-- 			item:changeItemType(item._encrypt.ItemColorType, specialType)
	-- 			item.isNeedUpdate = true

	-- 			theAction.addInfo = "flyEnd"
	-- 			theAction.actionTick = 0
	-- 		else
	-- 			theAction.addInfo = "finish"
	-- 		end

	-- 		ScoreCountLogic:addScoreToTotal(mainLogic, bonusTimeScore);
	-- 		local ScoreAction = GameBoardActionDataSet:createAs(
	-- 			GameActionTargetType.kGameItemAction,
	-- 			GameItemActionType.kItemScore_Get,
	-- 			pos, nil, 1)
	-- 		ScoreAction.addInt = bonusTimeScore;
	-- 		mainLogic:addGameAction(ScoreAction)
	-- 	end
	elseif theAction.addInfo == "wait2" then
		theAction.actionTick = theAction.actionTick + 1
		if theAction.actionTick == 10 then
			theAction.addInfo = "finish"
		end
	elseif theAction.addInfo == "finish" then
		if theAction.completeCallback then
			theAction.completeCallback()
		end
		mainLogic.gameActionList[actid] = nil
	end
end

function GameBoardActionRunner:runGameItemActionChickenMontherCast(mainLogic, theAction, actid, actByView)
	if theAction.actionStatus == GameActionStatus.kRunning then
		if theAction.addInfo == "create" then
			theAction.addInfo = ""

			local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
			local item = mainLogic.gameItemMap[r][c]

			if theAction.changeItemType == "toAddMove3" then
				item.ItemType = GameItemType.kAddMove
				item._encrypt.ItemColorType = AnimalTypeConfig.kYellow
				item:initAddMoveConfig(3)

				mainLogic:addNeedCheckMatchPoint(r , c)
			
			elseif theAction.changeItemType == "toSpecial" then
				item.ItemSpecialType = theAction.changeSpecialType
			end
			
			item.isNeedUpdate = true
		end

		if theAction.addInfo == "over" then
			theAction.addInfo = ""
			if theAction.completeCallback then
				theAction.completeCallback()
			end
			-- mainLogic:setNeedCheckFalling()
			mainLogic.gameActionList[actid] = nil
		end

	end
end

function GameBoardActionRunner:runningGameItemActionTransferSuperCute(mainLogic, theAction, actid, actByView)
	if theAction.actionStatus == GameActionStatus.kRunning then
		if theAction.addInfo == "over" then
			local fr, fc = theAction.ItemPos1.x, theAction.ItemPos1.y
			local tr, tc = theAction.ItemPos2.x, theAction.ItemPos2.y
			local fromItem = mainLogic.gameItemMap[fr][fc]
			local item = mainLogic.gameItemMap[tr][tc]
			if fromItem:isActiveTotems() then
				mainLogic:addNewSuperTotemPos(IntCoord:create(fr, fc))
			end
			if item.ItemType == GameItemType.kKindMimosa or item.beEffectByMimosa == GameItemType.kKindMimosa then
				GameExtandPlayLogic:backMimosa( mainLogic, tr, tc )
			end

			if theAction.completeCallback then
				theAction.completeCallback()
			end
			mainLogic.gameActionList[actid] = nil
		end
	end
end

function GameBoardActionRunner:runningGameItemActionRecoverSuperCute(mainLogic, theAction, actid, actByView)
	if theAction.actionStatus == GameActionStatus.kRunning then
		if theAction.addInfo == "over" then
			local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y

			local item = mainLogic.gameItemMap[r][c]
			if item.ItemType == GameItemType.kKindMimosa or item.beEffectByMimosa == GameItemType.kKindMimosa then
				GameExtandPlayLogic:backMimosa( mainLogic, r, c )
			end

			if theAction.completeCallback then
				theAction.completeCallback()
			end
			mainLogic.gameActionList[actid] = nil
		end
	end
end

function GameBoardActionRunner:runningGameitemActionUpdateLotus(mainLogic, theAction, actid, actByView)
	--[[
	if theAction.actionStatus == GameActionStatus.kRunning then

		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local item = mainLogic.gameItemMap[r][c]
		local board = mainLogic.boardmap[r][c]
		local updateType = theAction.updateType

		if theAction.addInfo == "update" then

			theAction.viewJSQ = 0
			theAction.viewJSQTarget = 0

			if updateType == 1 then
				theAction.viewJSQTarget = 10
				mainLogic.currLotusNum = mainLogic.currLotusNum + 1
			elseif updateType == 2 then
				theAction.viewJSQTarget = 16
			else
				theAction.viewJSQTarget = 22
			end

			theAction.addInfo = "playAnimation"

		end

		if theAction.addInfo == "playing" then

			if theAction.viewJSQ == 0 then
				board.lotusLevel = board.lotusLevel + 1
				if board.lotusLevel > 3 then board.lotusLevel = 3 end
				item.lotusLevel = board.lotusLevel

				board.isNeedUpdate = true
				item.isNeedUpdate = true
				mainLogic:checkItemBlock(r, c)
			end

			theAction.viewJSQ = theAction.viewJSQ + 1
			if theAction.viewJSQ > theAction.viewJSQTarget then
				theAction.addInfo = "over"
			end
		end

		if theAction.addInfo == "over" then

			if updateType == 1 then
				local pos = mainLogic:getGameItemPosInView(r, c)
				mainLogic.PlayUIDelegate:setTargetNumber(0, 0, mainLogic.currLotusNum, pos)
			end

			if theAction.completeCallback then
				theAction.completeCallback()
			end
			mainLogic.gameActionList[actid] = nil
		end
	end
	]]

	if theAction.actionStatus == GameActionStatus.kRunning then
		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local item = mainLogic.gameItemMap[r][c]
		local board = mainLogic.boardmap[r][c]
		local updateType = theAction.updateType

		if theAction.addInfo == "playAnimation" then
			theAction.viewJSQ = 0
			theAction.viewJSQTarget = 0

			if updateType == 1 then
				theAction.viewJSQTarget = 10
				mainLogic.currLotusNum = mainLogic.currLotusNum + 1
			elseif updateType == 2 then
				theAction.viewJSQTarget = 16
			else
				theAction.viewJSQTarget = 22
			end

			board.lotusLevel = board.lotusLevel + 1
			if board.lotusLevel > 3 then board.lotusLevel = 3 end
			item.lotusLevel = board.lotusLevel

			board.isNeedUpdate = true
			item.isNeedUpdate = true
			mainLogic:checkItemBlock(r, c)

			theAction.addInfo = "playing"
		elseif theAction.addInfo == "playing" then
			theAction.viewJSQ = theAction.viewJSQ + 1
			if theAction.viewJSQ > theAction.viewJSQTarget then
				theAction.addInfo = "over"
			end
		elseif theAction.addInfo == "over" then
			if updateType == 1 then
				local pos = mainLogic:getGameItemPosInView(r, c)
				if mainLogic.PlayUIDelegate.targetType == kLevelTargetType.order_lotus then --内有assert，会报错
					mainLogic.PlayUIDelegate:setTargetNumber(0, 0, mainLogic.currLotusNum, ccp(0,0))
				end
			end

			if theAction.completeCallback then
				theAction.completeCallback()
			end
			mainLogic.gameActionList[actid] = nil
		end
	end
end

function GameBoardActionRunner:runningGameItemScoreGet(mainLogic, theAction, actid, actByView)
	if theAction.actionStatus == GameActionStatus.kRunning then
		mainLogic.gameActionList[actid] = nil
	end
end

function GameBoardActionRunner:runningGameitemActionCrystalStoneFlying(mainLogic, theAction, actid, actByView)
	if theAction.actionStatus == GameActionStatus.kRunning then
		if not theAction.actionTick then 
			theAction.actionTick = 1
		else
			theAction.actionTick = theAction.actionTick + 1
		end
		
		if theAction.addInfo == "over" then
			mainLogic.gameActionList[actid] = nil
		else
			local isSpecialType = theAction.addInt2 and theAction.addInt2 ~= 0
			if theAction.actionTick == GamePlayConfig_CrystalStone_Fly_Time2 then
				local r, c = theAction.ItemPos2.x, theAction.ItemPos2.y
		        local item = mainLogic.gameItemMap[r][c]
		        local sptype = theAction.addInt2
		        local targetColor = theAction.addInt1

		        
				--果酱兼容
				local boardData = mainLogic.boardmap[theAction.ItemPos1.x][theAction.ItemPos1.y]
				local isJamSperad = boardData.isJamSperad
				if isJamSperad then
					GameExtandPlayLogic:addJamSperadFlag(mainLogic, theAction.ItemPos2.x, theAction.ItemPos2.y )
				end


				if not isSpecialType then
					if item and theAction.addInt3 == 1 and item:canBeCoverByCrystalStone() then -- addInt3 == 1 两个染色宝宝交换需要处理变色问题
		        		item.ItemCheckColorType = item._encrypt.ItemColorType
		        		item._encrypt.ItemColorType = targetColor
						item.isNeedUpdate = true
					else
						item._encrypt.ItemColorType = targetColor
						item.isNeedUpdate = true
					end
				else
					if (sptype == AnimalTypeConfig.kLine or sptype == AnimalTypeConfig.kColumn) then
						local specialTypes = { AnimalTypeConfig.kLine, AnimalTypeConfig.kColumn }
						local targetSpecialType = specialTypes[mainLogic.randFactory:rand(1, 2)]
						item.ItemSpecialType = targetSpecialType
					elseif sptype == AnimalTypeConfig.kWrap then
						item.ItemSpecialType = AnimalTypeConfig.kWrap
					end
					item.ItemType = GameItemType.kAnimal
					item._encrypt.ItemColorType = targetColor
					item.isNeedUpdate = true

					item.bombRes = IntCoord:create(r, c)
				end
			elseif not isSpecialType and theAction.actionTick == GamePlayConfig_CrystalStone_Fly_Time2 + 1 then
				local r, c = theAction.ItemPos2.x, theAction.ItemPos2.y
				mainLogic:addNeedCheckMatchPoint(r, c)
				if theAction.completeCallback then theAction.completeCallback() end
				theAction.addInfo = "over"
			elseif isSpecialType and theAction.actionTick == GamePlayConfig_CrystalStone_Fly_Time3 then
				local r, c = theAction.ItemPos2.x, theAction.ItemPos2.y
				BombItemLogic:tryBombWithBombRes(mainLogic, r, c, 1, scoreScale)
				if theAction.completeCallback then theAction.completeCallback() end
				theAction.addInfo = "over"
			end
		end
	end
end

function GameBoardActionRunner:runningGameItemActionCleanDigGround(mainLogic, theAction, actid, actByView)
	-- body
	if theAction.addInfo == "bomb" then
		local maxR = theAction.ItemPos1.x
		local count = 0
		if theAction.bombCount < maxR then

            local SpecialID = mainLogic:addSrcSpecialCoverToList( theAction.ItemPos1 )

			local r = maxR - theAction.bombCount
			for c = 1, #mainLogic.gameItemMap[r] do 
	            local item = mainLogic.gameItemMap[r][c]
	            if item.digGroundLevel > 0 then
	                for k = 1, item.digGroundLevel do 
	                    SpecialCoverLogic:SpecialCoverAtPos(mainLogic, r, c, 0, nil, nil, true, false, nil, SpecialID ) 
	                end
	                count = count + 1
	            elseif item.digJewelLevel > 0 then
	                for k = 1, item.digJewelLevel do 
	                    GameExtandPlayLogic:decreaseDigJewel(mainLogic, r, c, nil, false, false)
	                end
	                count = count + 1
	            elseif item.randomPropLevel > 0  then
	                for k = 1, item.randomPropLevel do 
	                    GameExtandPlayLogic:hitRandomProp(mainLogic, r, c, nil, false, false)
	                end
	                count = count + 1
	            end
	        end
			theAction.bombCount = theAction.bombCount + 1
		else
			theAction.addInfo = "over"
		end
		if count > 0 then
	    	mainLogic:setNeedCheckFalling()
		end
	elseif theAction.addInfo == "over" then
		if theAction.completeCallback then 
			theAction.completeCallback()
		end
		mainLogic.gameActionList[actid] = nil
	end
end

function GameBoardActionRunner:runningGameItemActionHedgehogReleaseEnergy(mainLogic, theAction, actid, actByView)
	-- body
	if theAction.addInfo == "updateData" then
		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local item = mainLogic.gameItemMap[r][c]
		item.hedgehogLevel = theAction.hedgehogLevel
		item.isNeedUpdate = true
		mainLogic.gameMode:releaseEnerge()
		theAction.addInfo = "updateTarget"
	elseif theAction.addInfo == "over" then
		if theAction.completeCallback then
			theAction.completeCallback()
		end
		mainLogic.gameActionList[actid] = nil
	end
end
function GameBoardActionRunner:runningGameItemActionHedgehogBoxChange(mainLogic, theAction, actid, actByView)
	-- body
	if theAction.addInfo == "animationOver" then
		local addJewel = theAction.addJewelCount or 0
		if addJewel > 0 then
			mainLogic.PlayUIDelegate:setTargetNumber(0, 1, mainLogic.digJewelCount:getValue(), 
				ccp(0,0), nil, false, mainLogic.gameMode:getPercentEnerge())
		end
		theAction.addInfo = "addProp"
	elseif theAction.addInfo == "addProp" then
		if theAction.changeType == HedgehogBoxCfgConst.kProp then
			local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
			local pos = mainLogic:getGameItemPosInView(r, c)
			if mainLogic.PlayUIDelegate and theAction.changeItem then
				local activityId = 0
				local text = mainLogic.dropPropText or Localization:getInstance():getText("activity.GuoQing.getprop.tips")
				activityId = mainLogic.activityId
				mainLogic.PlayUIDelegate:addTimeProp(theAction.changeItem, 1, pos, activityId, text)
			end
		end
		theAction.addInfo = "effect"
	elseif theAction.addInfo == "effectOver" then
		if theAction.changeType == HedgehogBoxCfgConst.kAddMove  then
			for k, v in pairs(theAction.effectItem) do 
				local item = mainLogic.gameItemMap[v.r][v.c]
				item.ItemType = GameItemType.kAddMove
				item.numAddMove = mainLogic.addMoveBase or GamePlayConfig_Add_Move_Base
				item.isNeedUpdate = true
			end
		elseif theAction.changeType == HedgehogBoxCfgConst.kSpecial then
			local total = #theAction.effectItem
			local rate = math.ceil(GamePlayConfig_HedgehogAwardWrap * total
				/(GamePlayConfig_HedgehogAwardWrap + GamePlayConfig_HedgehogAwardLine))
			for k = 1, total do 
				local item_selectd = theAction.effectItem[k]
				local item = mainLogic.gameItemMap[item_selectd.r][item_selectd.c]
				if k <= rate/2 then
					item.ItemSpecialType = AnimalTypeConfig.kLine
				elseif k <= rate then
					item.ItemSpecialType = AnimalTypeConfig.kColumn
				else
					item.ItemSpecialType = AnimalTypeConfig.kWrap
				end
				item.isNeedUpdate = true 
			end
		elseif theAction.changeType == HedgehogBoxCfgConst.kJewl then
			mainLogic.digJewelCount:setValue(mainLogic.digJewelCount:getValue() + GamePlayConfig_HedgehogAwardJewel)
			if mainLogic.PlayUIDelegate then
				local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
				local pos = mainLogic:getGameItemPosInView(r, c)
				for k = 1, GamePlayConfig_HedgehogAwardJewel do 
					mainLogic.gameMode:addEnergeCount(1)
					mainLogic.PlayUIDelegate:setTargetNumber(0, 1, mainLogic.digJewelCount:getValue(), pos, nil, nil, mainLogic.gameMode:getPercentEnerge())
				end
			end
		end

		if theAction.specialItems and #theAction.specialItems > 0 then
			local total = #theAction.specialItems
			local specialTypes = {AnimalTypeConfig.kLine, AnimalTypeConfig.kColumn, AnimalTypeConfig.kWrap}
			for k = 1, total do 
				local item_selectd = theAction.specialItems[k]
				local item = mainLogic.gameItemMap[item_selectd.r][item_selectd.c]
				item.ItemSpecialType = specialTypes[mainLogic.randFactory:rand(1, #specialTypes)]
				item.isNeedUpdate = true 
			end
		end
		mainLogic.maydayBossCount = mainLogic.maydayBossCount + 1
		if mainLogic.PlayUIDelegate then
			local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
			local position = mainLogic:getGameItemPosInView(r, c)
			mainLogic.PlayUIDelegate:setTargetNumber(0, 2, mainLogic.maydayBossCount, position)
		end
		theAction.addInfo = "updateView"
	elseif theAction.addInfo == "over" then
		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local item = mainLogic.gameItemMap[r][c]
		item:cleanAnimalLikeData()
		SnailLogic:doEffectSnailRoadAtPos(mainLogic, r, c)
		mainLogic:checkItemBlock(r,c)
		item.isNeedUpdate = true
		if theAction.completeCallback then
			theAction.completeCallback()
		end
		mainLogic.gameActionList[actid] = nil
		mainLogic:setNeedCheckFalling()
	end
end

function GameBoardActionRunner:runningGameItemActionMagicTileHit(mainLogic, theAction, actid, actByView) 
	if theAction.addInfo == 'over' then
		if not theAction.bossDead then
			local item = mainLogic.boardmap[theAction.ItemPos1.x][theAction.ItemPos1.y]
			if item then
				local id = item.magicTileId
				for r = 1, #mainLogic.boardmap do
					for c = 1, #mainLogic.boardmap[r] do
						local item2 = mainLogic.boardmap[r][c]
						if item2.isMagicTileAnchor == true and item2.magicTileId == id then
							item2.isHitThisRound = true
						end
					end
				end
			end
		end
		mainLogic.gameActionList[actid] = nil
	end
end

function GameBoardActionRunner:runningGameItemActionMagicTileChange(mainLogic, theAction, actid, actByView)
	if theAction.addInfo == 'over' then
		theAction.addInfo = ""
		-- if _G.isLocalDevelopMode then printx(0, '***************** Magic Tile Change') end
		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y

		local function onDieFinish()
			theAction.addInfo = "finish"
		end

		if theAction.objective == 'die' then
			for i = r, r + 1 do
				for j = c, c + 2 do
					if mainLogic.boardmap[i] then
						local item = mainLogic.boardmap[i][j]
						if item then
							item.isMagicTileAnchor = false
							item.remainingHit = nil
							item.magicTileId = nil
							item.magicTileDisabledRound = 0
						end
					end
				end
			end

            if mainLogic.magicTileDemolishedNum then
                mainLogic.magicTileDemolishedNum = mainLogic.magicTileDemolishedNum + 1
            end

			local targetPositions = MoleWeeklyRaceLogic:pickMagicTileBlastTarget(mainLogic, MoleWeeklyRaceParam.MAGIC_TILE_BLAST_SPLIT)
			local action = GameBoardActionDataSet:createAs(
		        GameActionTargetType.kGameItemAction,
		        GameItemActionType.kItem_MoleWeekly_Magic_Tile_Blast, 
		        theAction.ItemPos1,
		        nil,
		        GamePlayConfig_MaxAction_time
		        )
		    action.targetPositions = targetPositions
		    action.completeCallback = onDieFinish
		    mainLogic:addDestroyAction(action)
			mainLogic:setNeedCheckFalling()

		elseif theAction.objective == 'color' or theAction.objective == 'reactiveGrid' then
			-- 啥也不做
			theAction.addInfo = "finish"
		end
	elseif theAction.addInfo == "finish" then
		if theAction.completeCallback then
			theAction.completeCallback()
		end
		mainLogic.gameActionList[actid] = nil
	end
end

function GameBoardActionRunner:runningGameItemActionHoneyBottleBroken(mainLogic, theAction, actid, actByView)
	-- body
	if theAction.addInfo == "over" then
		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local item = mainLogic.gameItemMap[r][c]
		item:cleanAnimalLikeData()
		item.isBlock = false
		-- item.isNeedUpdate = true
		mainLogic:checkItemBlock(r, c)

		for k, v in pairs(theAction.infectList) do 
			local tItem = mainLogic.gameItemMap[v.x][v.y]
			tItem.honeyLevel = 1
			mainLogic:checkItemBlock(v.x, v.y)
			tItem.isNeedUpdate = true
		end
		ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_HoneyBottle, ObstacleFootprintAction.k_GenerateSubItem, #theAction.infectList)

		if theAction.completeCallback then 
			theAction.completeCallback()
		end
		mainLogic.gameActionList[actid] = nil
		SnailLogic:SpecialCoverSnailRoadAtPos( mainLogic, r, c )
	end
end

function GameBoardActionRunner:runningGameItemActionMagicLampReinit(mainLogic, theAction, actid, actByView)
	if theAction.addInfo == 'over' then
		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local item = mainLogic.gameItemMap[r][c]
		item.lampLevel = 1
		item._encrypt.ItemColorType = theAction.color
		item.isNeedUpdate = true
		if theAction.completeCallback then
			theAction.completeCallback()
		end
		mainLogic.gameActionList[actid] = nil
	end
end

function GameBoardActionRunner:runningGameItemActionMagicLampCasting(mainLogic, theAction, actid, actByView)

	if not theAction.specialTypes then
		theAction.specialTypes = {}
		for k, v in pairs(theAction.speicalItemPos) do
			local item = mainLogic.gameItemMap[v.r][v.c]
			local list = { AnimalTypeConfig.kLine, AnimalTypeConfig.kColumn }
			table.insert( theAction.specialTypes , list[mainLogic.randFactory:rand(1, 2)] )
		end
	end

	if theAction.addInfo == 'over' then
		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local lamp = mainLogic.gameItemMap[r][c]
		lamp.lampLevel = 0
		lamp._encrypt.ItemColorType = AnimalTypeConfig.kNone

		local boardData = mainLogic.boardmap[r][c]
		local isJamSperad = boardData.isJamSperad

		local toItemPos = theAction.speicalItemPos
		for k, v in pairs(toItemPos) do
			local item = mainLogic.gameItemMap[v.r][v.c]
			local toBoardData = mainLogic.boardmap[v.r][v.c]
			local targetSpecialType = theAction.specialTypes[k]
			item.ItemType = GameItemType.kAnimal
			item.ItemSpecialType = targetSpecialType
			item.isNeedUpdate = true

			if isJamSperad then
				GameExtandPlayLogic:addJamSperadFlag(mainLogic, v.r, v.c )
				toBoardData.isNeedUpdate = true
			end
		end
		ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_MagicLamp, ObstacleFootprintAction.k_Attack, #toItemPos)

		local function bombAll()

			if mainLogic.isDisposed then return end

			-- 为了等一下动画
			if lamp and lamp.needRemoveEventuallyBySquid then
				lamp:cleanAnimalLikeData()
				lamp.isNeedUpdate = true
				mainLogic:checkItemBlock(r, c)
			end

            local SpecialID = mainLogic:addSrcSpecialCoverToList( theAction.ItemPos1 )
			
			for k, v in pairs(toItemPos) do
				SpecialCoverLogic:SpecialCoverLightUpAtPos(mainLogic, v.r, v.c, 1, true)  --可以作用银币
				BombItemLogic:tryCoverByBomb(mainLogic, v.r, v.c, true, 1)
				SpecialCoverLogic:SpecialCoverAtPos( mainLogic, v.r, v.c, 3, nil,nil,nil,nil,nil,SpecialID )
			end

			if theAction.completeCallback then
				theAction.completeCallback()
			end

		end
		setTimeOut(bombAll, 0.24)	--0.3
		-- bombAll()
		mainLogic.gameActionList[actid] = nil
	end
end

function GameBoardActionRunner:runGameItemActionWukongCheckAndChangeState(mainLogic, theAction, actid, actByView)

	if theAction.actionStatus == GameActionStatus.kRunning then

		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local monkey = mainLogic.gameItemMap[r][c]

		local function onCompleteCallback()
			if theAction.completeCallback then
				theAction.completeCallback()
			end
		end

		if theAction.addInfo == "onChangeToReadyToJumpFin" then
			--monkey.wukongIsReadyToJump = true
			monkey.wukongState = TileWukongState.kReadyToJump
			mainLogic.gameActionList[actid] = nil
			onCompleteCallback()
		elseif theAction.addInfo == "onChangeToActiveFin" then
			--monkey.wukongIsReadyToJump = false
			monkey.wukongState = TileWukongState.kOnActive
			mainLogic.gameActionList[actid] = nil
			onCompleteCallback()
		end
	end
	
end

function GameBoardActionRunner:runGameItemActionWukongGift(mainLogic, theAction, actid, actByView)

	local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
	local fromItem = mainLogic.gameItemMap[r][c]

	if theAction.addInfo == 'anim_over' then
		
		----[[
		local addStepPositions = theAction.addStepPositions
		for k, v in pairs(addStepPositions) do
			local item = mainLogic.gameItemMap[v.r][v.c]
			item.ItemType = GameItemType.kAddMove
			item:initAddMoveConfig(mainLogic.addMoveBase)
			item.isNeedUpdate = true
		end
		--]]
		----[[
		local lineAndColumnPositions = theAction.lineAndColumnPositions
		for k, v in pairs(lineAndColumnPositions) do
			local item = mainLogic.gameItemMap[v.r][v.c]
			item.ItemType = GameItemType.kAnimal
			local rand = mainLogic.randFactory:rand(1, 2)
			if rand == 1 then
				item.ItemSpecialType = AnimalTypeConfig.kLine
			else
				item.ItemSpecialType = AnimalTypeConfig.kColumn  
			end
			
			item.isNeedUpdate = true
		end

		local warpPositions = theAction.warpPositions
		for k, v in pairs(warpPositions) do
			local item = mainLogic.gameItemMap[v.r][v.c]
			item.ItemType = GameItemType.kAnimal
			item.ItemSpecialType = AnimalTypeConfig.kWrap
			item.isNeedUpdate = true
		end
		--]]

		theAction.fromItemPosition = mainLogic:getGameItemPosInView( r , c )
		
		mainLogic:addDigJewelCountWhenBossDie(10 , theAction.fromItemPosition)



		local function dropProps()
            local totalWeight = mainLogic.wukongPropConfig:getTotalWeight()
            local random = mainLogic.randFactory:rand(1, totalWeight)
            local randPropId = mainLogic.wukongPropConfig:getRandProp(random)
           	--randPropId = 10061
            if randPropId then
                if mainLogic.PlayUIDelegate then
                    local showText = mainLogic.dropPropText or ""
                    mainLogic.PlayUIDelegate:addTimeProp(randPropId, 1, theAction.fromItemPosition , mainLogic.activityId , showText)
                end
            end
        end

        local totalPlayNum = 999
        local dropPropCount = 999

        if mainLogic.dragonBoatData then
        	totalPlayNum = mainLogic.dragonBoatData.totalPlayNum
        	dropPropCount = mainLogic.dragonBoatData.dropPropCount
        end

        
        
        if dropPropCount < 20 and not mainLogic.gameMode.wukongDropProp then
        	--1,3,5,7,11,17,21,25
        	if totalPlayNum == 1 
        		or totalPlayNum == 3 
        		or totalPlayNum == 5 
        		or totalPlayNum == 7 
        		or totalPlayNum == 11 
        		or totalPlayNum == 17 
        		or totalPlayNum == 21 
        		or totalPlayNum == 25 
        		then
        		dropProps()
        		mainLogic.gameMode.wukongDropProp = true
        	elseif mainLogic.randFactory:rand(1, 10000) <= 5 then
        		dropProps()
        		mainLogic.gameMode.wukongDropProp = true
        	end
        end

        theAction.addInfo = "data_over"

	elseif theAction.addInfo == 'over' then

		fromItem.wukongState = TileWukongState.kReadyToChangeColor

		if theAction.completeCallback then
			theAction.completeCallback()
		end
		mainLogic.gameActionList[actid] = nil

	end	
end

function GameBoardActionRunner:runGameItemActionWukongReinit(mainLogic, theAction, actid, actByView)

	local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
	local item = mainLogic.gameItemMap[r][c]
	local boardmap = mainLogic.boardmap
	if theAction.addInfo == "clearTargetBorad" then
		item.wukongState = TileWukongState.kChangeColor

		local wukongTargets = theAction.wukongTargetsPosition
		for k, v in pairs(wukongTargets) do
            local board = boardmap[v.x][v.y]
            board.isWukongTarget = false
            board.isNeedUpdate = true
        end
        theAction.addInfo = "clearTargetBoradFin"

	elseif theAction.addInfo == "changeWukongColorFin" then
		item.wukongState = TileWukongState.kNormal
		item._encrypt.ItemColorType = theAction.color
		item.isEmpty = false
		item.wukongProgressCurr = 0
		item.isNeedUpdate = true

		mainLogic:checkItemBlock(r, c)
		mainLogic:setNeedCheckFalling()

		if theAction.completeCallback then
			theAction.completeCallback()
		end
		mainLogic.gameActionList[actid] = nil
	end
end


function GameBoardActionRunner:runGameItemActionWukongJumping(mainLogic, theAction, actid, actByView)
	if theAction.actionStatus == GameActionStatus.kRunning then
		

		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local tr , tc = theAction.monkeyTargetPos.y, theAction.monkeyTargetPos.x
		local fromItem = mainLogic.gameItemMap[r][c]
		local toItem = mainLogic.gameItemMap[tr][tc]


		local function onFallToClearDone() -- 跳跃完成
			theAction.addInfo = "over"
		end

		if theAction.addInfo == "startJump" then
			toItem.wukongState = TileWukongState.kJumping

		elseif theAction.addInfo == "jumpFin" then

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
			--theAction.jumpJsq = 0
			--toItem.isBlock = true

		elseif theAction.addInfo == "over" then
			toItem.wukongState = TileWukongState.kReadyToCasting

			mainLogic.gameActionList[actid] = nil
			
			if theAction.completeCallback then
				theAction.completeCallback()
			end
		end
	end
end

function GameBoardActionRunner:runningGameItemActionDestroyArea(mainLogic, theAction, actid, actByView)
	local x, y = theAction.ItemPos1.x, theAction.ItemPos1.y
	local xEnd, yEnd = theAction.ItemPos2.x, theAction.ItemPos2.y

    local SpecialID = mainLogic:addSrcSpecialCoverToList( theAction.ItemPos1, theAction.ItemPos2 )

	for r = y, yEnd do
		for c = x, xEnd do
			SpecialCoverLogic:SpecialCoverLightUpAtPos(mainLogic, r, c, 1, true)  --可以作用银币
			BombItemLogic:tryCoverByBomb(mainLogic, r, c, true, 1)
			SpecialCoverLogic:SpecialCoverAtPos(mainLogic, r, c, 3,nil,nil,nil,nil,nil,SpecialID)
		end
	end

	local data = mainLogic.boardmap[y][x]
	data.seaAnimalType = nil

	local item = mainLogic.boardView.baseMap[y][x]
	item:clearSeaAnimal()

	local str = string.format(GameMusicType.kEliminate, 1)
 	GamePlayMusicPlayer:playEffect(str);
	mainLogic.gameActionList[actid] = nil
	mainLogic:setNeedCheckFalling()
end


function GameBoardActionRunner:runningGameItemActionTransmission(mainLogic, theAction, actid, actByView)
	if theAction.addInfo == "moveOver" then
		local from_r, from_c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local to_r, to_c = theAction.ItemPos2.x, theAction.ItemPos2.y

		mainLogic.boardmap[to_r][to_c]:changeDataAfterTrans(theAction.boardData)
		mainLogic.boardmap[to_r][to_c].isNeedUpdate = false
		local gameItemdata = mainLogic.gameItemMap[to_r][to_c]
		theAction.itemData.x = gameItemdata.x
		theAction.itemData.y = gameItemdata.y
		gameItemdata = nil
		mainLogic.gameItemMap[to_r][to_c]:getAnimalLikeDataFrom(theAction.itemData)
		mainLogic.gameItemMap[to_r][to_c].isNeedUpdate = false
		theAction.boardData = mainLogic.boardmap[to_r][to_c]
		theAction.addInfo = "reInitView"
	elseif theAction.addInfo == "over" then
		local to_r, to_c = theAction.ItemPos2.x, theAction.ItemPos2.y
		mainLogic:addNeedCheckMatchPoint(to_r, to_c)
		mainLogic:checkItemBlock(to_r, to_c)
		mainLogic.gameMode:checkDropDownCollect(to_r, to_c)

		if theAction.completeCallback then
			theAction.completeCallback()
		end
		mainLogic.gameActionList[actid] = nil
	end
end

function GameBoardActionRunner:runningGameItemActionOctopusChangeForbiddenLevel(mainLogic, theAction, actid, actByView)
	if theAction.addInfo == 'over' then
		local r, c = theAction.ItemPos1.y, theAction.ItemPos1.x
		local item = mainLogic.gameItemMap[r][c]
		item.forbiddenLevel = theAction.level
		if theAction.completeCallback then
			theAction.completeCallback()
		end
		mainLogic.gameActionList[actid] = nil
	end
end

function GameBoardActionRunner:runningGameItemActionMaydayBossCasting(mainLogic, theAction, actid, actByView)
	if theAction.addInfo == 'anim_over' then
		theAction.addInfo = 'data_over'
		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local targetPositions = theAction.targetPositions
		local dripPositions = theAction.dripPositions
		if not dripPositions then dripPositions = {} end

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

		for k, v in pairs(targetPositions) do
			local item = mainLogic.gameItemMap[v.r][v.c]

			if dripPositions[tostring(v.r) .. "_" .. tostring(v.c)] then

				item.ItemType = GameItemType.kDrip
				item._encrypt.ItemColorType = AnimalTypeConfig.kDrip
				item.dripState = DripState.kNormal
				item:AddItemStatus( GameItemStatusType.kNone , true )
				item.isNeedUpdate = true
				mainLogic:addNeedCheckMatchPoint(v.r , v.c)
				mainLogic:setNeedCheckFalling()

			elseif isNormal(item) then
				assert(item._encrypt.ItemColorType, "ItemColorType should not be nil")
				item.ItemType = GameItemType.kQuestionMark
				mainLogic:onProduceQuestionMark(v.r, v.c)
				item.isNeedUpdate = true
			end
			
		end
	elseif theAction.addInfo == 'over' then
		
		if theAction.completeCallback then
			theAction.completeCallback()
		end
		mainLogic.gameActionList[actid] = nil
	end	
end

function GameBoardActionRunner:runnningGameItemActionBossJump(mainLogic, theAction, actid, actByView)

	local function cleanItem(r, c)
		local item = mainLogic.gameItemMap[r][c]
		local board = mainLogic.boardmap[r][c]
		item:cleanAnimalLikeData()
		item.isBlock = false
		item.isNeedUpdate = true
		mainLogic:checkItemBlock(r, c)
	end
	local function copyItem(from_r, from_c, to_r, to_c)
		mainLogic.gameItemMap[to_r][to_c] = mainLogic.gameItemMap[from_r][from_c]:copy()
		mainLogic.gameItemMap[to_r][to_c].isNeedUpdate = true
		mainLogic.gameItemMap[to_r][to_c].x = to_c
		mainLogic.gameItemMap[to_r][to_c].y = to_r
		mainLogic:checkItemBlock(to_r, to_c)
	end

	if theAction.addInfo == 'over' then
		local from_r, from_c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local to_r, to_c = theAction.ItemPos2.x, theAction.ItemPos2.y
		copyItem(from_r, from_c, to_r, to_c)
		copyItem(from_r, from_c+1, to_r, to_c+1)
		copyItem(from_r+1, from_c, to_r+1, to_c)
		copyItem(from_r+1, from_c+1, to_r+1, to_c+1)

		cleanItem(from_r, from_c)
		cleanItem(from_r + 1, from_c)
		cleanItem(from_r, from_c+1)
		cleanItem(from_r+ 1, from_c+1)

		if theAction.completeCallback then
			theAction.completeCallback()
		end
		mainLogic.gameActionList[actid] = nil
		mainLogic:setNeedCheckFalling()
		FallingItemLogic:preUpdateHelpMap(mainLogic)
		-- debug.debug()
	end
end

function GameBoardActionRunner:runningGameItemActionProductRabbit(mainLogic, theAction, actid, actByView)
	if theAction.addInfo == 'shifted' then
		if theAction.ItemPos2 then
			-- copy
			-- local fromPos = theAction.ItemPos1
			-- local toPos = 
			local ox = mainLogic.gameItemMap[theAction.ItemPos2.r][theAction.ItemPos2.c].x
			local oy = mainLogic.gameItemMap[theAction.ItemPos2.r][theAction.ItemPos2.c].y
			mainLogic.gameItemMap[theAction.ItemPos2.r][theAction.ItemPos2.c] = mainLogic.gameItemMap[theAction.ItemPos1.r][theAction.ItemPos1.c]:copy()
			mainLogic.gameItemMap[theAction.ItemPos2.r][theAction.ItemPos2.c].isNeedUpdate = true
			mainLogic.gameItemMap[theAction.ItemPos2.r][theAction.ItemPos2.c].x = ox
			mainLogic.gameItemMap[theAction.ItemPos2.r][theAction.ItemPos2.c].y = oy
		end
	elseif theAction.addInfo == 'over' then
		local item = mainLogic.gameItemMap[theAction.ItemPos1.r][theAction.ItemPos1.c]
		item:changeToRabbit(theAction.color, theAction.level)
		item:changeRabbitState(GameItemRabbitState.kSpawn)
		item.isNeedUpdate = true
		if theAction.completeCallback then
			theAction.completeCallback()
		end

		mainLogic.gameActionList[actid] = nil
	end
end

function GameBoardActionRunner:runningGameItemActionProductSnail(mainLogic, theAction, actid, actByView)
	-- body
	if theAction.addInfo == "over" then
		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local item = mainLogic.gameItemMap[r][c]
		local board = mainLogic.boardmap[r][c]

		if item.honeyLevel > 0 then
			mainLogic:tryDoOrderList(r, c, GameItemOrderType.kOthers, GameItemOrderType_Others.kHoney, 1)
			item.honeyLevel = 0
			ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_Honey, ObstacleFootprintAction.k_Eliminate, 1)
		end

		item:changeToSnail(board.snailRoadType)
		mainLogic:checkItemBlock(r, c)
		FallingItemLogic:preUpdateHelpMap(mainLogic)
		if theAction.completeCallback then
			theAction.completeCallback()
		end
		item.isNeedUpdate = true
		mainLogic.gameActionList[actid] = nil

	end
end

function GameBoardActionRunner:runningGameItemActionSnailRoadBright(mainLogic, theAction, actid, actByView)
	-- body
	if theAction.addInfo == "over" then
		mainLogic.gameActionList[actid] = nil
	end
end

function GameBoardActionRunner:runningGameItemActionHedgehogRoadState(mainLogic, theAction, actid, actByView)
	-- body
	if theAction.addInfo == "over" then
		mainLogic.gameActionList[actid] = nil
	end
end

function GameBoardActionRunner:runningGameItemActionMimosaReady(mainLogic, theAction, actid, actByView)
	-- body
	if theAction.addInfo == "over" then
		if theAction.completeCallback then 
			theAction.completeCallback()
		end
		mainLogic.gameActionList[actid] = nil
	end

end

function GameBoardActionRunner:runningGameItemActionMimosaGrow(mainLogic, theAction, actid, actByView)
	-- body
	if theAction.addInfo == "animation_over" then
		theAction.addInfo = "effect_item"
		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local item = mainLogic.gameItemMap[r][c]
		local list = item.mimosaHoldGrid
		for k, v in pairs(theAction.addItem) do 
			mainLogic:checkItemBlock(v.x,v.y)
			-- table.insert(list, v)
		end
		FallingItemLogic:preUpdateHelpMap(mainLogic)
		theAction.mimosaHoldGrid = list
		ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_KindMimosa, ObstacleFootprintAction.k_Covered, #list)
	elseif theAction.addInfo == "over" then
		if theAction.completeCallback then 
			theAction.completeCallback()
		end
		mainLogic.gameActionList[actid] = nil
	end

end

function GameBoardActionRunner:runningGameItemActionMimosaBack(mainLogic, theAction, actid, actByView)
	-- body
	if theAction.addInfo == "over" then
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
		-- item.mimosaLevel = 1
		if theAction.completeCallback then
			theAction.completeCallback()
		end

		mainLogic.gameActionList[actid] = nil
	end

end

function GameBoardActionRunner:runningGameItemActionBlackCuteBallUpdate(mainLogic, theAction, actid, actByView)
	-- body
	if theAction.addInfo == "replace" then
		theAction.addInfo = "over"
		if theAction.ItemPos2 then
			local r1, c1 = theAction.ItemPos1.x, theAction.ItemPos1.y
			local item1 = mainLogic.gameItemMap[r1][c1]

			local r2, c2 = theAction.ItemPos2.x, theAction.ItemPos2.y
			local item2 = mainLogic.gameItemMap[r2][c2]
			item2.ItemType = GameItemType.kBlackCuteBall
			item2.isBlock = false
			item2._encrypt.ItemColorType = 0
			item2.ItemSpecialType = 0
			item2.isEmpty = false
			item2.blackCuteStrength = item1.blackCuteStrength
			item2.blackCuteMaxStrength = item1.blackCuteMaxStrength
			item2.isNeedUpdate = true
			ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_BlackFurball, ObstacleFootprintAction.k_Attack, 1)
		end

	elseif theAction.addInfo == "over" then
		local r1, c1 = theAction.ItemPos1.x, theAction.ItemPos1.y
		local item1 = mainLogic.gameItemMap[r1][c1]

		if theAction.ItemPos2 then
			item1:cleanAnimalLikeData()
		elseif item1.blackCuteStrength < item1.blackCuteMaxStrength then
			item1.blackCuteStrength = item1.blackCuteStrength + 1
		end

		if theAction.completeCallback then 
			theAction.completeCallback()
		end
		mainLogic.gameActionList[actid] = nil
	end
end

function GameBoardActionRunner:runningGameItemActionUpdatePM25(mainLogic, theAction, actid, actByView)
	-- body
	if theAction.addInfo == "over" then 
		mainLogic.gameActionList[actid] = nil

		FallingItemLogic:preUpdateHelpMap(mainLogic)
		if theAction.completeCallback then 
			theAction.completeCallback()
		end
	elseif theAction.addInfo == "replace" then
		theAction.addInfo = "replaceView"
		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local item = mainLogic.gameItemMap[r][c]
		local board = mainLogic.boardmap[r][c]
		if item then 
			item:changeToDigGround(1)
			item.isNeedUpdate = true
		end

		if board then 
			board.isBlock = true
		end
	end
end

function GameBoardActionRunner:runningGameItemActionMonsterDestroyItem(mainLogic, theAction, actid, actByView, SpecialID)
	-- body
	local function overAction( ... )
		-- body
		theAction.addInfo = ""
		mainLogic.gameActionList[actid] = nil
		if theAction.completeCallback then 
			theAction.completeCallback()
		end
		mainLogic:setNeedCheckFalling()
	end

	local function bombItem(r, c, dirs, SpecialID)
		-- body
		local item = mainLogic.gameItemMap[r][c]
		local boardData = mainLogic.boardmap[r][c]

		--[[
		local coverEffectData = CoverEffectData:createByCommonDatas(
				CoverEffectSourceType.kObstacleLogic , GameItemType.kBigMonster , 
				CoverAroundEffectType.kAround , 1 , false)
		coverEffectData:setCoverFalling(true)
		coverEffectData:setBreakDirs(dirs)

		SpecialCoverLogic:tryEffectAtPos(mainLogic, r, c, coverEffectData)
		]]

		BombItemLogic:tryCoverByBomb(mainLogic, r, c, true, 1)
		SpecialCoverLogic:SpecialCoverAtPos(mainLogic, r, c, 3,nil,nil,nil,nil,nil,SpecialID) 
		SpecialCoverLogic:specialCoverChainsAtPos(mainLogic, r, c, dirs) --冰柱处理
		SpecialCoverLogic:SpecialCoverLightUpAtPos(mainLogic, r, c, 1)
		GameExtandPlayLogic:doABlocker211Collect(mainLogic, nil, nil, r, c, item._encrypt.ItemColorType, false, 3)
		--[[
		if (boardData.iceLevel > 0 or boardData.sandLevel > 0 )  and 
		   (item.ItemType == GameItemType.kAnimal or item.ItemType == GameItemType.kCrystal) and
		   not item:hasFurball() and 
		   not item:hasLock() and 
		  item:isAvailable() then 
			SpecialCoverLogic:SpecialCoverLightUpAtPos(mainLogic, r, c, 1)
		end
		]]
	end

	if theAction.addInfo == "over" then
		local r_min = theAction.ItemPos1.x
		local r_max = theAction.ItemPos2.x
		local c_min = theAction.ItemPos1.y
		local c_max = theAction.ItemPos2.y
		-- if _G.isLocalDevelopMode then printx(0, "TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT") end
		-- if _G.isLocalDevelopMode then printx(0, "TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT") end
		-- if _G.isLocalDevelopMode then printx(0, "r_min",r_min,"r_max",r_max,"c_min",c_min,"c_max",c_max,"theAction.time_count",theAction.time_count) end
		-- if _G.isLocalDevelopMode then printx(0, "TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT") end
		-- if _G.isLocalDevelopMode then printx(0, "TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT") end

		--果酱的处理
		local PosList = {}
		for i,v in pairs(theAction.SrcPosList) do
			--xy = rc
			table.insert( PosList, IntCoord:create( v.x, v.y ) )	--左上
			table.insert( PosList, IntCoord:create( v.x, v.y+1 ) ) --右
			table.insert( PosList, IntCoord:create( v.x+1, v.y ) ) --左下
			table.insert( PosList, IntCoord:create( v.x+1, v.y+1 ) ) --右下
		end
		local SpecialID = mainLogic:addSrcSpecialCoverToListEx( PosList )


		if r_max - r_min > 3 and c_max - c_min > 3 then        ---脚踩全屏
			theAction.time_count = theAction.time_count or 0
			if theAction.time_count >= 5 then
				overAction()
			else
				local dirs = {ChainDirConfig.kUp, ChainDirConfig.kDown, ChainDirConfig.kRight, ChainDirConfig.kLeft}

				for r = 5 - theAction.time_count, 5 + theAction.time_count do 
					for c = 5 - theAction.time_count, 5 + theAction.time_count do
						if r >= 5 - theAction.time_count + 1 and 
						   r <= 5 + theAction.time_count - 1 and 
						   c >= 5 - theAction.time_count + 1 and 
						   c <= 5 + theAction.time_count - 1 then
						else
							bombItem(r, c, dirs, SpecialID)
						end
					end
				end
				theAction.time_count = theAction.time_count + 1
			end

		else                                                   ---3*2格子
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
					bombItem(r, c, dirs, SpecialID )
				end
			end

			overAction()
		end
	end
end

function GameBoardActionRunner:runningGameItemActionTileBlockerUpdate( mainLogic, theAction, actid, actByView)
	-- body
	local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y

	if theAction.addInfo == "checkEffectGrid" then
		local checkItem = mainLogic.gameItemMap[r][c]

		if not checkItem.isReverseSide 
			and (checkItem.ItemType == GameItemType.kMimosa or checkItem.ItemType == GameItemType.kKindMimosa)
			then
			GameExtandPlayLogic:backMimosa( mainLogic, r, c, nil )
			mainLogic:setNeedCheckFalling(true)
			theAction.addInfo = "waitingForPlayAnimation"
		else
			theAction.addInfo = "playAnimation"
		end
	elseif theAction.addInfo == "animation_fin" then
		
		if theAction.coutDown == 0 then
			mainLogic.boardmap[r][c].isReverseSide = not mainLogic.boardmap[r][c].isReverseSide
			mainLogic.gameItemMap[r][c].isReverseSide = not mainLogic.gameItemMap[r][c].isReverseSide
			-- mainLogic.gameItemMap[r][c].isBlock = mainLogic.gameItemMap[r][c]:checkBlock() --mainLogic.boardmap[r][c].isReverseSide
			mainLogic:checkItemBlock(r,c)
			if not mainLogic.boardmap[r][c].isReverseSide then
				mainLogic.gameMode:checkDropDownCollect(r, c)
			end
			FallingItemLogic:preUpdateHelpMap(mainLogic)
			mainLogic:addNeedCheckMatchPoint(r, c)
			if mainLogic.boardmap[r][c].isReverseSide and ObstacleFootprintManager:tileBlockerHasSthInCover(r, c) then
				ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_TileBlocker, ObstacleFootprintAction.k_Covered, 1)
			end

			if mainLogic.gameItemMap[r][c]:isActiveTotems() and not mainLogic.gameItemMap[r][c].isReverseSide then
				-- 如果翻过来的是超级小金刚，检查当前棋盘上是否有已存在的超级小金刚
				mainLogic:addNewSuperTotemPos(IntCoord:create(r, c))
			end

			mainLogic.boardmap[r][c].reverseCount = gTileBlockDefaultCount
		end
		theAction.addInfo = "over"

	elseif theAction.addInfo == "over" then
		mainLogic.gameActionList[actid] = nil

		if theAction.completeCallback and type(theAction.completeCallback) == "function" then
			theAction.completeCallback()
		end
	end
end

function GameBoardActionRunner:runningGameItemActionDoubleSideTileBlockerUpdate( mainLogic, theAction, actid, actByView)
	-- body
	local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
	local checkItem = mainLogic.gameItemMap[r][c]

	if theAction.addInfo == "checkEffectGrid" then
		
		if not checkItem.isReverseSide 
			and (checkItem.ItemType == GameItemType.kMimosa or checkItem.ItemType == GameItemType.kKindMimosa)
			then
			GameExtandPlayLogic:backMimosa( mainLogic, r, c, nil )
			mainLogic:setNeedCheckFalling(true)
			theAction.addInfo = "waitingForPlayAnimation"
		else
			theAction.addInfo = "playAnimation"
		end
	elseif theAction.addInfo == "animation_fin" then
		if theAction.coutDown == 0 then
			local itemData = nil
			if mainLogic.gameItemMap[r] and mainLogic.gameItemMap[r][c] then
				itemData = mainLogic.gameItemMap[r][c]
			end

			local boardData = mainLogic.boardmap[r][c]

			local backItemData = nil
			if mainLogic.backItemMap[r] and mainLogic.backItemMap[r][c] then
				backItemData = mainLogic.backItemMap[r][c]
			end

			local backBoardMap = nil
			if mainLogic.backBoardMap[r] and mainLogic.backBoardMap[r][c] then
				backBoardMap = mainLogic.backBoardMap[r][c]
			end

			if boardData.side == 2 then

				if itemData and backItemData then
					local cacheItem = itemData:copy()
					itemData:resetDatas( gCopyDataMode.kDoubleSideBlockerTurn )
					GameItemData.copyDatasFrom( itemData , backItemData , gCopyDataMode.kDoubleSideBlockerTurn )
					backItemData:resetDatas()
					GameItemData.copyDatasFrom( backItemData , cacheItem )
					itemData.isNeedUpdate = true
				end

				if backBoardMap then
					local cacheBoard = boardData:copy()
					boardData:resetDatas( gCopyDataMode.kDoubleSideBlockerTurn )
					GameBoardData.copyDatasFrom( boardData , backBoardMap , gCopyDataMode.kDoubleSideBlockerTurn )
					backBoardMap:resetDatas()
					GameBoardData.copyDatasFrom( backBoardMap , cacheBoard )
					boardData.isNeedUpdate = true
				end

				boardData.side = 2
			else
				if itemData and backItemData then
					local cacheItem = itemData:copy()
					itemData:resetDatas( gCopyDataMode.kDoubleSideBlockerTurn )
					GameItemData.copyDatasFrom( itemData , backItemData , gCopyDataMode.kDoubleSideBlockerTurn )
					backItemData:resetDatas()
					GameItemData.copyDatasFrom( backItemData , cacheItem )
					itemData.isNeedUpdate = true
				end

				if backBoardMap then
					local cacheBoard = boardData:copy()
					boardData:resetDatas( gCopyDataMode.kDoubleSideBlockerTurn )
					GameBoardData.copyDatasFrom( boardData , backBoardMap , gCopyDataMode.kDoubleSideBlockerTurn )
					backBoardMap:resetDatas()
					GameBoardData.copyDatasFrom( backBoardMap , cacheBoard )
					boardData.isNeedUpdate = true
				end

				boardData.side = 1
			end

			boardData.reverseCount = gTileBlockDefaultCount

			needTestPrint = true
			itemData.forceUpdate = true
			boardData.forceUpdate = true
			
			mainLogic:checkItemBlock(r,c)
			FallingItemLogic:preUpdateHelpMap(mainLogic)
			mainLogic:addNeedCheckMatchPoint(r, c)
			

			if itemData.ItemType == GameItemType.kMimosa or itemData.ItemType == GameItemType.kKindMimosa then
				if itemData.mimosaLevel == GamePlayConfig_Mimosa_Grow_Step then
					local action = GameBoardActionDataSet:createAs(
						GameActionTargetType.kGameItemAction,
						GameItemActionType.kItem_Mimosa_Ready,
						IntCoord:create(r, c),
						nil,
						GamePlayConfig_MaxAction_time
						)
					action.completeCallback = callback
					mainLogic:addGameAction(action)
				end
			end
			
		end

		theAction.addInfo = "over"

	elseif theAction.addInfo == "over" then

		mainLogic:tryBombSuperTotemsByForce()
		mainLogic.gameActionList[actid] = nil
		mainLogic.needUpdateSeaAnimalStaticData = true

		if theAction.completeCallback and type(theAction.completeCallback) == "function" then
			theAction.completeCallback()
		end
	end
end


function GameBoardActionRunner:runningGameItemLogicActionForceMoveItem( mainLogic, theAction, actid, actByView)
	-- body
	if theAction.addInfo == "over" then 
		theAction.addInfo = nil
		mainLogic.gameActionList[actid] = nil
		local r1, c1  = theAction.ItemPos1.x, theAction.ItemPos1.y
		
		if not theAction.isTop then 
			if theAction.isUfoLikeItem then
				local r2, c2 = theAction.ItemPos2.x, theAction.ItemPos2.y
				local data1 = mainLogic.gameItemMap[r1][c1]
				local data2 = mainLogic.gameItemMap[r2][c2]
				if not SwapItemLogic:_trySwapedMatchItem(mainLogic, r1, c1, r2, c2, true) then
					local item1Clone = data1:copy()
					local item2Clone = data2:copy()
					data2:getAnimalLikeDataFrom(item1Clone)
					data1:getAnimalLikeDataFrom(item2Clone)
					data1.isNeedUpdate = false
					data2.isNeedUpdate = false
				end
				ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_UFO, ObstacleFootprintAction.k_Lift, 1)
			end

			if theAction.completeCallback and type(theAction.completeCallback) == "function" then
				theAction.completeCallback()
			end
		else
			local item = mainLogic.gameItemMap[theAction.ItemPos1.x][theAction.ItemPos1.y]
			local collect_item = {r = r1, c = c1, level = item.rabbitLevel}
			item:cleanAnimalLikeData()
			mainLogic.isUFOWin = true
			table.insert(mainLogic.UFOCollection, collect_item)
			ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_UFO, ObstacleFootprintAction.k_Lift, 1)
			if theAction.completeCallback then theAction.completeCallback() end
		end

	end
end

function GameBoardActionRunner:runningGameItemlogicActionChangeToIngredient( mainLogic, theAction, actid, actByView )
	-- body
	if theAction.addInfo == "over" then 
		-- debug.debug()
		theAction.addInfo = nil
		local r1, c1  = theAction.ItemPos1.x, theAction.ItemPos1.y
		local item = mainLogic.gameItemMap[r1][c1]
		item:changeToIngredient()
		item.isNeedUpdate = true
		if theAction.completeCallback and type(theAction.completeCallback) then
				theAction.completeCallback()
		end
		mainLogic.gameActionList[actid] = nil
	end
end

------气球更新
function GameBoardActionRunner:runningGameItem_BalloonUpdate( mainLogic, theAction, actid, actByView )
	-- body
	if theAction.actionDuring == 1 then
		if theAction.completeCallback and type(theAction.completeCallback) then 
			theAction.completeCallback()
		end
		mainLogic.gameActionList[actid] = nil
	end
end

function GameBoardActionRunner:runGameItemlogicActionBalloonRunaway(mainLogic, theAction, actid, actByView)
	-- body
	if theAction.actionStatus == GameActionStatus.kRunning then
		if theAction.actionDuring == 1 then 
			local item = mainLogic.gameItemMap[theAction.ItemPos1.x][theAction.ItemPos1.y]
			item:cleanAnimalLikeData()
			ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_Balloon, ObstacleFootprintAction.k_Waste, 1)
			mainLogic.gameActionList[actid] = nil
			if theAction.completeCallback and type(theAction.completeCallback) == "function" then
				theAction.completeCallback()
			end
		end
	end
end

-----水晶变化
function GameBoardActionRunner:runningGameItem_Crystal_Change(mainLogic, theAction, actid, actByView)
	if theAction.addInfo == "over" then
		if theAction.callback and type(theAction.callback) == "function" then
			theAction.callback()
		end
		mainLogic.gameActionList[actid] = nil
		return
	end
	if theAction.actionDuring == 1 then
		theAction.addInfo = "over"
	end
end

-----毒液蔓延
function GameBoardActionRunner:runningGameItem_Venom_Spread(mainLogic, theAction, actid, actByView)
	if theAction.addInfo == "replace" then

		theAction.addInfo = "replaceView"
		local r1 = theAction.ItemPos2.x
		local c1 = theAction.ItemPos2.y

		local targetItem = mainLogic.gameItemMap[r1] and mainLogic.gameItemMap[r1][c1]
		local targetBoard = mainLogic.boardmap[r1] and mainLogic.boardmap[r1][c1]

		if targetItem then
			targetItem:changeToVenom()
			targetItem.isNeedUpdate = true
		end
		if targetBoard then
			targetBoard.isBlock = true
		end
		FallingItemLogic:preUpdateHelpMap(mainLogic)
		ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_Poison, ObstacleFootprintAction.k_Appear, 1)
		if theAction.itemType == GameItemType.kPoisonBottle then
			ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_PoisonBottle, ObstacleFootprintAction.k_GenerateSubItem, 1)
		end
	elseif theAction.addInfo == "over" then
		if theAction.callback and type(theAction.callback) == "function" then
			theAction.callback()
		end
		mainLogic.gameActionList[actid] = nil
	end
end

function GameBoardActionRunner:runningGameItem_Furball_Transfer(mainLogic, theAction, actid, actByView)
	if theAction.addInfo == "over" then
		if theAction.callback and type(theAction.callback) == "function" then
			theAction.callback()
		end
		mainLogic.gameActionList[actid] = nil
	end
end


function GameBoardActionRunner:runningGameItem_Furball_Split(mainLogic, theAction, actid, actByView)
	if theAction.addInfo == "over" then
		
		if theAction.callback and type(theAction.callback) == "function" then
			theAction.callback()
		end
		mainLogic.gameActionList[actid] = nil
	end	

end

function GameBoardActionRunner:runningGameItem_Roost_Replace(mainLogic, theAction, actid, actByView)
	if theAction.addInfo == "replace" then
		for i, pos in ipairs(theAction.itemList) do
			local r = pos.x
			local c = pos.y
			local changeItem = mainLogic.gameItemMap[r][c]
			changeItem.isNeedUpdate = true
		end

		local roostR = theAction.ItemPos1.x
		local roostC = theAction.ItemPos1.y
		if mainLogic.gameItemMap[roostR] and mainLogic.gameItemMap[roostR][roostC] then
			local roost = mainLogic.gameItemMap[roostR][roostC]
			if roost.needRemoveEventuallyBySquid then
				roost:cleanAnimalLikeData()
				roost.isNeedUpdate = true
				mainLogic:checkItemBlock(roostR, roostC)
			end
		end

		theAction.addInfo = "replaceOver"
	elseif theAction.addInfo == "over" then	
		if theAction.callback and type(theAction.callback) == "function" then
			theAction.callback()
		end
		mainLogic.gameActionList[actid] = nil
	end	
end

function GameBoardActionRunner:existInSpecialBombLightUpPos(r, c, lightUpMatchPosList)
	if lightUpMatchPosList then
		for i,v in ipairs(lightUpMatchPosList) do
			if v.r == r and v.c == c then
				return true
			end
		end
	end
	return false
end

function GameBoardActionRunner:runningGameItemRefresh_Item_Flying(mainLogic, theAction, actid, actByView)
	if theAction.addInfo == "over" then

		--[[
		local r1 = theAction.ItemPos1.x
		local c1 = theAction.ItemPos1.y
		local r2 = theAction.ItemPos2.x
		local c2 = theAction.ItemPos2.y

		local data1 = boardView.gameBoardLogic.gameItemMap[r1][c1] 		----目标
		local data2 = boardView.gameBoardLogic.gameItemMap[r2][c2]		----来源

		if item1.oldData then
			item1.isNeedUpdate = true

			item1.oldData._encrypt.ItemColorType = data1._encrypt.ItemColorType
			item1.oldData.ItemSpecialType = data1.ItemSpecialType
			if data1.ItemSpecialType == AnimalTypeConfig.kColor then
				item1.itemShowType = ItemSpriteItemShowType.kBird
			else
				item1.itemShowType = ItemSpriteItemShowType.kCharacter
			end 
		else 
		end
		]]

		if theAction.callback and type(theAction.callback) == "function" then
			theAction.callback()
		end
		mainLogic.gameActionList[actid] = nil
	elseif theAction.addInfo == "Pass" then
		theAction.addInfo = "waiting1"
		local r1 = theAction.ItemPos1.x
		local c1 = theAction.ItemPos1.y
		local item1 = mainLogic.gameItemMap[r1][c1]
		item1.isNeedUpdate = true
	elseif theAction.addInfo == "waiting1" then
		if theAction.actionDuring == 1 then 
			theAction.addInfo = "over"
		end
	end
end

function GameBoardActionRunner:runGameItemSpecialFurballUnstable(mainLogic, theAction, actid, actByView)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		mainLogic:setNeedCheckFalling()
	elseif theAction.actionStatus == GameActionStatus.kWaitingForDeath then
		mainLogic.gameActionList[actid] = nil
	end
end

function GameBoardActionRunner:runningGameItemActionSandTransfer(mainLogic, theAction, actid, actByView)
	if theAction.addInfo == "over" then
		if theAction.callback and type(theAction.callback) == "function" then
			theAction.callback()
		end
		mainLogic.gameActionList[actid] = nil
	end
end

function GameBoardActionRunner:runningGameItemActionBlocker199Reinit(mainLogic, theAction, actid, actByView)
	if theAction.addInfo == 'over' then
		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local item = mainLogic.gameItemMap[r][c]
		--item._encrypt.ItemColorType = theAction.color
		item.isItemLock = false
		--item.isNeedUpdate = true
		if theAction.completeCallback then
			theAction.completeCallback()
		end
		mainLogic.gameActionList[actid] = nil
	end
end


--万生消除
function GameBoardActionRunner:runningGameItemActionWanShengBroken(mainLogic, theAction, actid, actByView)
	-- body
	if theAction.addInfo == "ChangeItem" then
		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
--		local item = mainLogic.gameItemMap[r][c]
--		item:cleanAnimalLikeData()
--		item.isBlock = false
        theAction.needUpdateView = false
        theAction.UpdateData = {}
		-- item.isNeedUpdate = true
		mainLogic:checkItemBlock(r, c)

		for k, v in pairs(theAction.infectList) do 
			local tItem = mainLogic.gameItemMap[v.item.x][v.item.y]
            local tBoard = mainLogic.boardmap[v.item.x][v.item.y]
            local wanShengConfig = v.wanShengConfig 

            local bUpdateBoard =false
            local bCanNeedCheckMatch = false

            local ItemType = wanShengConfig.mType+1
            local attr = wanShengConfig.attr
            local animalDef = wanShengConfig.animalDef
            local id = wanShengConfig.id
            
            if ItemType == TileConst.kMagicLamp then
                --大眼仔
                tItem:changeToMagicLamp()

                bCanNeedCheckMatch = true
            elseif ItemType == TileConst.kBottleBlocker then
                --精灵萌豆
                local level = 1
                if id then
                    if id == 10110 then
                        level = 1
                    elseif  id == 10120 then
                        level = 2
                    elseif  id == 10130 then
                        level = 3
                    end
                end
                tItem:changeToBottleBlocker( level )

                bCanNeedCheckMatch = true
            elseif ItemType == TileConst.kColorFilter then
                --过滤器
                local addInfo = 3
                tItem:changeToColorFilter( tonumber(attr), addInfo )
                tBoard:changeToColorFilter( tonumber(attr), addInfo )
--                bUpdateBoard = true

                theAction.needUpdateView = true
                table.insert( theAction.UpdateData, { ItemType = ItemType, r=v.item.x, c=v.item.y} )

            elseif ItemType == TileConst.kPacman then
                --吃豆人
                tItem:changeToPacman()
            elseif ItemType == TileConst.kFrosting1 
                or ItemType == TileConst.kFrosting2 
                or ItemType == TileConst.kFrosting3 
                or ItemType == TileConst.kFrosting4 
                or ItemType == TileConst.kFrosting5 then
                --1层雪---5层雪
                local level = ItemType - TileConst.kFrosting1  +1
                tItem:changeToFrosting( level )
            elseif ItemType == TileConst.kLock then
                --牢笼
                tItem:changeToLock()
            elseif ItemType == TileConst.kCoin then 
                --银币
                tItem:changeToCoin()
            elseif ItemType == TileConst.kCrystal then 
                --水晶球
                tItem:changeToCrystal()
                bCanNeedCheckMatch = true
            elseif ItemType == TileConst.kDigGround_1
                or ItemType == TileConst.kDigGround_2 
                or ItemType == TileConst.kDigGround_3  then 
                --1层云
                local level = ItemType - TileConst.kDigGround_1 +1
                tItem:changeToDigGround( level )
            elseif ItemType == TileConst.kGreyCute then 
                --灰毛球
                tItem:changeToGreyCute()
                theAction.needUpdateView = true
--                table.insert( theAction.UpdateData, { ItemType = ItemType, r=v.item.x, c=v.item.y} )
            elseif ItemType == TileConst.kBrownCute then 
                --褐毛球
                tItem:changeToBrownCute()
                theAction.needUpdateView = true
--                table.insert( theAction.UpdateData, { ItemType = ItemType, r=v.item.x, c=v.item.y} )
            elseif ItemType == TileConst.kBlackCute then 
                --黑毛球
                tItem:changeToBlackCute()
                theAction.needUpdateView = true
            elseif ItemType == TileConst.kPoison then 
                --毒液
                tItem:changeToPoison()
            elseif ItemType == TileConst.kHoneyBottle then 
                --蜂蜜罐
                tItem:changeToHoneyBottle()
            elseif ItemType == TileConst.kPuffer
                or ItemType == TileConst.kPufferActivated  then 
                --气鼓鱼
                local level = ItemType - TileConst.kPuffer +1
                tItem:changeToPuffer( level )
            elseif ItemType == TileConst.kMissile then 
                --冰封导弹
                tItem:changeToMissile()
            elseif ItemType == TileConst.kChameleon then 
                --变色龙
                tItem:changeToChameleon()
            elseif ItemType == TileConst.kBlocker207 then 
                --钥匙
                tItem:changeToBlocker207()
            elseif ItemType == TileConst.kTurret then 
                --炮台
                local level = WanShengLogic:getTurretLevel( attr )
                tItem:changeToTurret( level )
            elseif ItemType == TileConst.kSunFlask then 
                --太阳瓶子
                local level = WanShengLogic:getSunFlaskLevel( attr )
                tItem:changeToSunFlask( level )
            elseif ItemType == TileConst.kMagicStone_Up or 
                ItemType == TileConst.kMagicStone_Right or
                ItemType == TileConst.kMagicStone_Down or
                ItemType == TileConst.kMagicStone_Left then
                --魔法石

                local dir = ItemType - TileConst.kMagicStone_Up +1
                tItem:changeToMagicStone( dir )
            elseif ItemType == TileConst.kCrystalStone then
                --染色宝宝
                tItem:changeToCrystalStone()
            elseif ItemType == TileConst.kTotems then
                --闪电鸟
                tItem:changeToTotems( animalDef )
                bCanNeedCheckMatch = true
            elseif ItemType == TileConst.kAnimal then 
                --小动物
                tItem:changeToAnimal( animalDef )
                bCanNeedCheckMatch = true
            end

            local actionType = ObstacleFootprintManager:getLotusBlockerGenerateActionType(ItemType, animalDef)
            ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_LotusBlocker, actionType, 1)

			mainLogic:checkItemBlock(v.item.x, v.item.y)

            tItem.forceUpdate = true
			tItem.isNeedUpdate = true

            if bUpdateBoard then 
                tBoard.isNeedUpdate = true
            end

            if bCanNeedCheckMatch then
                mainLogic:addNeedCheckMatchPoint(v.item.x,v.item.y)
            end

            --果酱兼容
            if theAction.SpecialID then
            	GameExtandPlayLogic:addJamSperadFlag(mainLogic, v.item.x,v.item.y )
            end
		end
--		ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_HoneyBottle, ObstacleFootprintAction.k_GenerateSubItem, #theAction.infectList)

        if theAction.needUpdateView then
            theAction.addInfo = "updateView"
        else
            theAction.addInfo = "destorySelf"
        end
    elseif theAction.addInfo == "destorySelf" then
        local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
        local item = mainLogic.gameItemMap[r][c]
		item:cleanAnimalLikeData()
        mainLogic:checkItemBlock(r,c)
        SnailLogic:doEffectSnailRoadAtPos(mainLogic, r, c)

        theAction.addInfo = "over"
    elseif theAction.addInfo == "over" then
        if theAction.completeCallback then 
			theAction.completeCallback()
		end

		mainLogic.gameActionList[actid] = nil
    end
end

function GameBoardActionRunner:runningGameItemActionAddNewBiscuit( mainLogic, theAction, actid, actByView )
	if theAction.addInfo == "ready" then
		theAction.addInfo = "playAnim"
		theAction.counter = 0
	elseif theAction.addInfo == "waitingAnim" then
		theAction.counter = theAction.counter + 1
		if theAction.counter >= 20 then
			theAction.addInfo = "over"
		end
	elseif theAction.addInfo == "over" then
		local r = theAction.ItemPos1.x
		local c = theAction.ItemPos1.y
		local newLevel = theAction.addInt
		mainLogic.boardmap[r][c]:upgradeBiscuit(newLevel)
		if theAction.completeCallback then 
			theAction.completeCallback()
		end
		mainLogic.gameActionList[actid] = nil
	end
end

function GameBoardActionRunner:runningGameItemActionCollectBiscuit( mainLogic, theAction, actid, actByView )

	if theAction.addInfo == "ready" then
		theAction.addInfo = "playAnim"
		theAction.counter = 0
	elseif theAction.addInfo == "waitingAnim" then
		theAction.counter = theAction.counter + 1
		if theAction.counter >= 20 then
			theAction.addInfo = "over"
		end
	elseif theAction.addInfo == "over" then
		local r = theAction.ItemPos1.y
		local c = theAction.ItemPos1.x
		if theAction.completeCallback then 
			theAction.completeCallback()
		end
		mainLogic.gameActionList[actid] = nil

		ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_Biscuit, ObstacleFootprintAction.k_Attack, 1)

		mainLogic:tryDoOrderList(
			r, c,
			GameItemOrderType.kOthers, 
			GameItemOrderType_Others.kBiscuit,
			1,
			nil, 
			theAction.pos
		)

		local biscuitData = mainLogic.boardmap[r][c].biscuitData

		local targetPoint1 = IntCoord:create(c, r)
		local targetPoint2 = IntCoord:create(c + biscuitData.nCol - 1, r + biscuitData.nRow - 1)
		local rectangleAction = GameBoardActionDataSet:createAs(
			GameActionTargetType.kGameItemAction,
			GameItemActionType.kItemSpecial_rectangle,
			targetPoint1,
			targetPoint2,
			GamePlayConfig_MaxAction_time)
		rectangleAction.addInt2 = 1.5
		rectangleAction.eliminateChainIncludeHem = true
		rectangleAction.footprintType = ObstacleFootprintType.k_Biscuit
		mainLogic:addDestructionPlanAction(rectangleAction)
		mainLogic.boardmap[r][c].biscuitData = nil

		mainLogic:addScoreToTotal(r, c, GamePlayConfigScore.BiscuitCollected)
	end
end