----面板动画函数------

require "zoo.itemView.ItemView"
require "zoo.itemView.PropsView"
require "zoo.gamePlay.BoardAction.GameBoardActionDataSet"

BoardViewAction = class{}


----求一个Item的真实位置itemPos中存储的是rc，所以对应的是yx
function BoardViewAction:getItemPosition(itemPos)
	local x = (itemPos.y - 0.5 ) * GamePlayConfig_Tile_Width
	local y = (GamePlayConfig_Max_Item_Y - itemPos.x - 0.5 ) * GamePlayConfig_Tile_Height
	return ccp(x,y)
end

----CDCount多少帧
function BoardViewAction:getActionTime(CDCount)
	return 1.0 / GamePlayConfig_Action_FPS * CDCount
end

function BoardViewAction:runSwapItemAction(boardView, theAction)
	local r1 = theAction.ItemPos1.x
	local c1 = theAction.ItemPos1.y
	local r2 = theAction.ItemPos2.x
	local c2 = theAction.ItemPos2.y

	local sprite1, spriteCover1 = boardView.baseMap[r1][c1]:getGameItemSprite()
	local sprite2, spriteCover2 = boardView.baseMap[r2][c2]:getGameItemSprite()
	if sprite1 == nil or sprite2 == nil then
		if _G.isLocalDevelopMode then printx(0, "BoardViewAction:runSwapItemAction sprite1 == nil or sprite2 == nil, it is a error!!!") end
		return false
	end

	local position1 = BoardViewAction:getItemPosition(theAction.ItemPos1)
	local position2 = BoardViewAction:getItemPosition(theAction.ItemPos2)
	
	sprite1:runAction(CCMoveTo:create(BoardViewAction:getActionTime(GamePlayConfig_SwapAction_CD), position2))
	sprite2:runAction(CCMoveTo:create(BoardViewAction:getActionTime(GamePlayConfig_SwapAction_CD), position1))
	if spriteCover1 then spriteCover1:runAction(CCMoveTo:create(BoardViewAction:getActionTime(GamePlayConfig_SwapAction_CD), position2)) end
	if spriteCover2 then spriteCover2:runAction(CCMoveTo:create(BoardViewAction:getActionTime(GamePlayConfig_SwapAction_CD), position1)) end
end

function BoardViewAction:runGameItemActionScoreGet(boardView, theAction)
	theAction.actionStatus = GameActionStatus.kRunning

	local r1 = theAction.ItemPos1.x;
	local c1 = theAction.ItemPos1.y;
	local item = boardView.baseMap[r1][c1];
	local num = theAction.addInt;
	local posType = theAction.addInt2;

	local color = theAction.scoreColorIndex or 6
	if color < 1 then color = 6 end
	--printx( 1 , "    " , table.tostring(boardView.labelBatchs) )
	local labelBatch = boardView.labelBatchs[color]

	local spriteGetScore = item:playGetScoreAction(boardView, num, ccp(0,800), posType, labelBatch, theAction.isBuffScore)
	labelBatch:addChild(spriteGetScore)

	--------传给UI界面，显示分数星星飞行特效
	if boardView.PlayUIDelegate then
		if boardView.PlayUIDelegate.scoreProgressBar then
			local pos = item:getBasePosition(item.x + 0.5, item.y - 0.5);
			local pos1 = boardView:getPosition();
			local pos2 = ccp(pos1.x + pos.x, pos1.y + pos.y)
			boardView.PlayUIDelegate:addScore(num , pos2);
		end
	end
end

function BoardViewAction:runGameItemActionRefresh_Item_Flying(boardView, theAction)
	theAction.actionStatus = GameActionStatus.kRunning
	local r1 = theAction.ItemPos1.x;
	local c1 = theAction.ItemPos1.y;
	local r2 = theAction.ItemPos2.x
	local c2 = theAction.ItemPos2.y

	local item1 = boardView.baseMap[r1][c1];
	local item2 = boardView.baseMap[r2][c2];

	local pos1 = item1:getBasePosition(c1,r1)
	local pos2 = item1:getBasePosition(c2,r2)

	if item1.itemSprite[ItemSpriteType.kSpecial] ~= nil then
		local length = math.sqrt(math.pow(pos2.y - pos1.y, 2) + math.pow(pos2.x - pos1.x, 2))
		local moveAction = HeBezierTo:create(BoardViewAction:getActionTime(GamePlayConfig_Refresh_Item_Flying_Time), pos1, true, length * 0.4)

		item1.itemSprite[ItemSpriteType.kSpecial]:setPosition(pos2);
		item1.itemSprite[ItemSpriteType.kSpecial]:runAction(CCEaseSineInOut:create(moveAction));
	end
end

function BoardViewAction:runGameItemActionPassRefreshItemFlying(boardView, theAction)
	local r1 = theAction.ItemPos1.x
	local c1 = theAction.ItemPos1.y
	local r2 = theAction.ItemPos2.x
	local c2 = theAction.ItemPos2.y
	-- printx(11, "play refresh flying: ("..r2..","..c2..") to ("..r1..","..c1..")")

	local item1 = boardView.baseMap[r1][c1] 		----目标
	local item2 = boardView.baseMap[r2][c2]			----来源

	local data1 = boardView.gameBoardLogic.gameItemMap[r1][c1] 		----目标
	local data2 = boardView.gameBoardLogic.gameItemMap[r2][c2]		----来源

	item1:flyingSpriteIntoItem(item2)

	if item1.oldData then
		-- 格子上有数据，不是真空区域？
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
end

function BoardViewAction:runGameItemActionPassRefreshItemFlyingOver(boardView, theAction)
	local r1 = theAction.ItemPos1.x
	local c1 = theAction.ItemPos1.y
	local r2 = theAction.ItemPos2.x
	local c2 = theAction.ItemPos2.y

	-- 在 flyingSpriteIntoItem中，没有移动的对象不播放动画，也就不用被更新
	if r1 == r2 and c1 == c2 then return end

	local item1 = boardView.baseMap[r1][c1] 		----目标
	local item2 = boardView.baseMap[r2][c2]			----来源

	local data1 = boardView.gameBoardLogic.gameItemMap[r1][c1] 		----目标
	local data2 = boardView.gameBoardLogic.gameItemMap[r2][c2]		----来源

	item1:flyingSpriteIntoItemEnd()
	item1.isNeedUpdate = true
end

function BoardViewAction:runGameItemActionItemCrystalChange(boardView, theAction)
	theAction.actionStatus = GameActionStatus.kRunning
	local r1 = theAction.ItemPos1.x;
	local c1 = theAction.ItemPos1.y;

	local data1 = boardView.gameBoardLogic.gameItemMap[r1][c1]
	local item1 = boardView.baseMap[r1][c1];
	local color = theAction.addInt;

	item1:playChangeCrystalColor(color);
	if item1.oldData then
		item1.oldData._encrypt.ItemColorType = color;
		data1._encrypt.ItemColorType = color;
	end
end

function BoardViewAction:runGameItemActionVenomSpread(boardView, theAction)
	theAction.actionStatus = GameActionStatus.kRunning
	local originR1 = theAction.ItemPos1.x
	local originC1 = theAction.ItemPos1.y

	local targetR1 = theAction.ItemPos2.x
	local targetC1 = theAction.ItemPos2.y

	local dir = { x = targetC1 - originC1, y = targetR1 - originR1 }
	local venom = boardView.baseMap[originR1][originC1]

	local function callback( ... )
		-- body
		theAction.addInfo = "replace"

	end
	venom:playVenomSpreadEffect(dir, callback, theAction.itemType)
end

function BoardViewAction:runningGameItemActionVenomSpread( boardView, theAction )
	-- body
	if theAction.addInfo == "replaceView" then 
		theAction.addInfo = "over"
		local originR1 = theAction.ItemPos1.x
		local originC1 = theAction.ItemPos1.y
		local venom = boardView.baseMap[originR1][originC1]
		if venom then 
			local sprite = venom.itemSprite[ItemSpriteType.kNormalEffect]
			if sprite and sprite:getParent() then
				sprite:removeFromParentAndCleanup(true)
			end
			venom.itemSprite[ItemSpriteType.kNormalEffect] = nil
		end
	end
end

function BoardViewAction:runGameItemActionFurballTransfer(boardView, theAction)
	theAction.actionStatus = GameActionStatus.kRunning
	local fr = theAction.ItemPos1.x
	local fc = theAction.ItemPos1.y

	local tr = theAction.ItemPos2.x
	local tc = theAction.ItemPos2.y

	local dir = { x = tc - fc, y = tr - fr }
	local fromItem = boardView.baseMap[fr][fc]
	local function callback( ... )
		-- body
		local tr = theAction.ItemPos2.x
		local tc = theAction.ItemPos2.y
		local targetItem = boardView.baseMap[tr][tc]
		targetItem:addFurballView(theAction.addInt)
		theAction.addInfo = "add"
		
	end
	fromItem:playFurballTransferEffect(dir, callback)
end

function BoardViewAction:runningGameItemActionFurballTransfer(boardView, theAction)
	if theAction.addInfo == "add" then 
		theAction.addInfo = "over"
		local fr = theAction.ItemPos1.x
		local fc = theAction.ItemPos1.y
		local fromItem = boardView.baseMap[fr][fc]
		if fromItem.itemSprite[ItemSpriteType.kSpecial] and fromItem.itemSprite[ItemSpriteType.kSpecial]:getParent() then
			fromItem.itemSprite[ItemSpriteType.kSpecial]:removeFromParentAndCleanup(true)
			fromItem.itemSprite[ItemSpriteType.kSpecial] = nil
		end
	end
end

function BoardViewAction:runGameItemActionFurballSplit(boardView, theAction)
	theAction.actionStatus = GameActionStatus.kRunning

	local fr = theAction.ItemPos1.x
	local fc = theAction.ItemPos1.y

	local dir = { x = 0, y = 0 }
	if theAction.ItemPos2 then
		local tr = theAction.ItemPos2.x
		local tc = theAction.ItemPos2.y

		dir = { x = tc - fc, y = tr - fr }
	end
	local function callback( ... )
		-- body
		if theAction.ItemPos2 then
			local tr = theAction.ItemPos2.x
			local tc = theAction.ItemPos2.y
			local targetItem = boardView.baseMap[tr][tc]
			targetItem:addFurballView(GameItemFurballType.kGrey)
		end
		theAction.addInfo = "add"
	end

	GameExtandPlayLogic:doAllBlocker195Collect(boardView.gameBoardLogic, fr, fc, Blocker195CollectType.kBrownCute)
	SquidLogic:checkSquidCollectItem(boardView.gameBoardLogic, fr, fc, TileConst.kBrownCute)
	boardView.gameBoardLogic:setNeedCheckFalling()
	local fromItem = boardView.baseMap[fr][fc]
	fromItem:playFurballSplitEffect(dir, callback)
end

function BoardViewAction:runningGameItemActionFurballSplit(boardView, theAction)
	if theAction.addInfo == "add" then
		theAction.addInfo = "over"
		local fr = theAction.ItemPos1.x
		local fc = theAction.ItemPos1.y
		local fromItem = boardView.baseMap[fr][fc]
		fromItem:cleanFurballEffectView()
		fromItem:addFurballView(GameItemFurballType.kGrey)

		-- if theAction.ItemPos2 then
		-- 	local tr = theAction.ItemPos2.x
		-- 	local tc = theAction.ItemPos2.y
		-- 	local targetItem = boardView.baseMap[tr][tc]
		-- 	targetItem:addFurballView(GameItemFurballType.kGrey)
		-- end
	end
end

function BoardViewAction:runGameItemActionFurballUnstable(boardView, theAction)
	theAction.actionStatus = GameActionStatus.kRunning
	local r = theAction.ItemPos1.x
	local c = theAction.ItemPos1.y

	local item = boardView.baseMap[r][c]
	item:playFurballUnstableEffect()
end

function BoardViewAction:runGameItemActionFurballShield(boardView, theAction)
	theAction.actionStatus = GameActionStatus.kRunning

	local r = theAction.ItemPos1.x
	local c = theAction.ItemPos1.y

	local item = boardView.baseMap[r][c]
	item:playFurballShieldEffect()
end

function BoardViewAction:runGameItemActionAnimalShakeBySpecialColor(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		local r = theAction.ItemPos1.x
		local c = theAction.ItemPos1.y
		local itemView = boardView.baseMap[r][c]
		if not theAction.theItemColor	-- 不需要指定颜色
			or (itemView.oldData and theAction.theItemColor == itemView.oldData._encrypt.ItemColorType) then -- 是指定颜色的动物
			itemView:playShakeBySpecialColorEffect()
		end
	elseif theAction.actionStatus == GameActionStatus.kRunning then
		if theAction.actionDuring == 1 then
			local r = theAction.ItemPos1.x
			local c = theAction.ItemPos1.y
			local itemView = boardView.baseMap[r][c]
			itemView:stopShakeBySpecialColorEffect()
		end
	end
end

function BoardViewAction:runGameItemActionRoostReplace(boardView, theAction)
	local function replaceAnimComplete()
		if theAction.addInfo == "start" then
			theAction.addInfo = "add"
		end
	end
	theAction.actionStatus = GameActionStatus.kRunning
	local r = theAction.ItemPos1.x
	local c = theAction.ItemPos1.y
	local itemView = boardView.baseMap[r][c]
	itemView:playRoostReplaceAnimation(replaceAnimComplete)
	theAction.addInfo = "start"
	theAction.actionTick = 0
end

function BoardViewAction:runningGameItemActionRoostReplace(boardView, theAction)
	if theAction.addInfo == "start" then
		theAction.actionTick = theAction.actionTick + 1
		-- 确保就算动画回调出了问题也能结束action
		if theAction.actionTick == 50 then
			theAction.actionTick = 0
			theAction.addInfo = "add"
		end
	elseif theAction.addInfo == "add" then
		theAction.addInfo = "waitReplace"
		theAction.actionTick = 0

		local function flyAnimComplete()
			if theAction.addInfo == "waitReplace" then
				theAction.addInfo = "replace"
			end
		end

		if theAction.itemList and #theAction.itemList > 0 then
			local roostPos = IntCoord:clone(theAction.ItemPos1)
			for i, itemPos in ipairs(theAction.itemList) do
				local r = itemPos.x
				local c = itemPos.y
				local itemView = boardView.baseMap[r][c]
				itemView:playRoostReplaceFlyAnimation(roostPos, flyAnimComplete)
			end
		else
			setTimeOut(flyAnimComplete, 0.6)
		end

	elseif theAction.addInfo == "waitReplace" then

		theAction.actionTick = theAction.actionTick + 1
		-- 确保就算动画回调出了问题也能结束action
		if theAction.actionTick == 36 then
			theAction.addInfo = "replace"
		end

	elseif theAction.addInfo == "replaceOver" then
		if theAction.itemList and #theAction.itemList > 0 then
			for i, itemPos in ipairs(theAction.itemList) do
				local r = itemPos.x
				local c = itemPos.y
				local itemView = boardView.baseMap[r][c]
				if itemView.itemSprite[ItemSpriteType.kRoostFly] then
					itemView.itemSprite[ItemSpriteType.kRoostFly]:removeFromParentAndCleanup(true)
					itemView.itemSprite[ItemSpriteType.kRoostFly] = nil
					itemView.isNeedUpdate = true
				end
			end
		end
		theAction.addInfo2 = nil
		theAction.addInfo = "over"
	end
end

function BoardViewAction:runGameItemActionBalloonUpdateNum(boardView, theAction )
	-- body
	theAction.actionStatus = GameActionStatus.kRunning
	local itemviewMap = boardView.baseMap
	itemviewMap[theAction.ItemPos1.x][theAction.ItemPos1.y]:updateBalloonStep(theAction.numberShow)
end

function BoardViewAction:runGameItemViewActionBallooRunaway(boardView, theAction)
	-- body
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then 
		theAction.actionStatus = GameActionStatus.kRunning
		local itemviewMap = boardView.baseMap
		itemviewMap[theAction.ItemPos1.x][theAction.ItemPos1.y]:playBalloonActionRunaway(boardView)
		GamePlayMusicPlayer:playEffect(GameMusicType.kBalloonRunaway)
		
	
	end
end
function BoardViewAction:runGameItemViewActionForceMoveItem(boardView, theAction)
	-- body
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then 
		theAction.actionStatus = GameActionStatus.kRunning
		local r1 = theAction.ItemPos1.x
		local c1 = theAction.ItemPos1.y
		local r2 = theAction.ItemPos2 and theAction.ItemPos2.x
		local c2 = theAction.ItemPos2 and theAction.ItemPos2.y
		local itemView = boardView.baseMap[r1][c1]
		local sprite, spriteCover = boardView.baseMap[r1][c1]:getGameItemSprite()

		local function completeCallback( ... )
			-- body
			theAction.addInfo = "over"
			if theAction.isTop then
			else 
				if theAction.isUfoLikeItem then 
					boardView:swapItemView(boardView.baseMap[r1][c1], boardView.baseMap[r2][c2])
				end
			end
		end

		local position = UsePropState:getItemPosition(IntCoord:create(r2,c2))
		if theAction.isTop  then 
			local function callback( ... )
				-- body
				completeCallback()
			end
			local arr = CCArray:create()
			local moveTime = 0.5
			if itemView.itemShowType == ItemSpriteItemShowType.kRabbit then
				sprite:playRunAnimation()
				arr:addObject(CCDelayTime:create(0.7))
				moveTime = 1
			else
				local action_rotation = CCRepeat:create(CCSequence:createWithTwoActions(CCRotateTo:create(0.1, -15), CCRotateTo:create(0.1, 0)), 3) 
				arr:addObject(action_rotation)
			end

			local action_move = CCEaseExponentialOut:create(CCMoveTo:create(moveTime, position)) 
			local action_scale = CCScaleTo:create(0.5, 0)
			arr:addObject(CCSpawn:createWithTwoActions(action_scale, action_move) ) 
			arr:addObject(CCCallFunc:create(callback))
			sprite:runAction(CCSequence:create(arr))
			if spriteCover then spriteCover:runAction(CCSequence:create(arr:copy())) end
		else 
			
			if theAction.isUfoLikeItem and boardView.PlayUIDelegate then
				itemView:playUpstairsAnimation(r2, c2, boardView, theAction.isShowDangerous, completeCallback)
			else
				local arr = CCArray:create()
				arr:addObject(CCDelayTime:create(0.4))
				arr:addObject(CCMoveTo:create(0.25, position))
				arr:addObject(CCCallFunc:create(completeCallback))
				if sprite then 
					sprite:runAction(CCSequence:create(arr))
					if spriteCover then spriteCover:runAction(CCSequence:create(arr:copy())) end
				else
					if boardView.gameBoardLogic then
						local item = boardView.gameBoardLogic.gameItemMap[r1][c1]
						 he_log_error("runGameItemViewActionForceMoveItem sprite = nil  item.ItemType = "..item.ItemType
						 	.." item._encrypt.ItemColorType = "..item._encrypt.ItemColorType
						 	.." item.ItemSpecialType = "..item.ItemSpecialType)
					end

					completeCallback()
				end
			end 
		end
	end
end

function BoardViewAction:runGameItemViewActionChangeToIngredient( boardView, theAction )
	-- body
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then 
		theAction.actionStatus = GameActionStatus.kRunning
		local r1 = theAction.ItemPos1.x
		local c1 = theAction.ItemPos1.y
		local itemview = boardView.baseMap[r1][c1]

		local r2 = theAction.ItemPos2.x
		local c2 = theAction.ItemPos2.y
		-- debug.debug()
		local visibleSize = CCDirector:sharedDirector():getVisibleSize()
		local fromPosition =  boardView.gameBoardLogic:getGameItemPosInView(r2, c2)
		fromPosition = ccp(fromPosition.x, visibleSize.height)
		local function callback( ... )
			-- body
			theAction.addInfo = "over"
		end 
		itemview:playChangeToIngredientAnimation(boardView, fromPosition, callback)
	else
	end
end

function BoardViewAction:runGameItemActionTileBlockerUpdate(boardView, theAction)
	-- body
	local r = theAction.ItemPos1.x
	local c = theAction.ItemPos1.y
	local itemview = boardView.baseMap[r][c]

	if theAction.actionStatus == GameActionStatus.kWaitingForStart then 
		theAction.actionStatus = GameActionStatus.kRunning
		
		local function callback( ... )
			-- body
			--theAction.addInfo = "over"
		end 
		
		if theAction.coutDown == 0 then
			theAction.addInfo = "checkEffectGrid"
			theAction.jsq = 0
		else
			itemview:playTileBoardUpdate(theAction.coutDown, theAction.isReverseSide, callback, boardView)
			theAction.addInfo = "over"
		end
	else
		if theAction.addInfo == "playAnimation" then
			itemview:playTileBoardUpdate(theAction.coutDown, theAction.isReverseSide, callback, boardView)
			theAction.addInfo = "waitingForFin"
			theAction.jsq = 0
		elseif theAction.addInfo == "waitingForPlayAnimation" then
			theAction.jsq = theAction.jsq + 1
			if theAction.jsq == 40 then
				theAction.addInfo = "playAnimation"
			end
		elseif theAction.addInfo == "waitingForFin" then
			theAction.jsq = theAction.jsq + 1
			if theAction.jsq == 35 then
				theAction.addInfo = "animation_fin"
			end
		end
	end
end

function BoardViewAction:runGameItemActionDoubleSideTileBlockerUpdate(boardView, theAction)
	-- body
	local r = theAction.ItemPos1.x
	local c = theAction.ItemPos1.y
	local itemview = boardView.baseMap[r][c]

	if theAction.actionStatus == GameActionStatus.kWaitingForStart then 
		theAction.actionStatus = GameActionStatus.kRunning
		
		local function callback( ... )
			-- body
			--theAction.addInfo = "over"
		end

		if theAction.coutDown == 0 then
			theAction.addInfo = "checkEffectGrid"
			theAction.jsq = 0
		else
			itemview:playDoubleSideTileBoardUpdate(theAction.coutDown, theAction.oldSide, callback, boardView)
			theAction.addInfo = "over"
		end
	else

		if theAction.addInfo == "playAnimation" then
			itemview:playDoubleSideTileBoardUpdate(theAction.coutDown, theAction.oldSide, callback, boardView)
			theAction.addInfo = "waitingForFin"
			theAction.jsq = 0
		elseif theAction.addInfo == "waitingForPlayAnimation" then
			theAction.jsq = theAction.jsq + 1
			if theAction.jsq == 40 then
				theAction.addInfo = "playAnimation"
			end
		elseif theAction.addInfo == "waitingForFin" then
			theAction.jsq = theAction.jsq + 1
			if theAction.jsq == 20 then
				theAction.addInfo = "animation_fin"
			end
		end
	end
end

function BoardViewAction:runGameItemActionMonsterDestroyItem(boardView, theAction )
	-- body
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		local r_min = theAction.ItemPos1.x
		local r_max = theAction.ItemPos2.x
		local c_min = theAction.ItemPos1.y
		local c_max = theAction.ItemPos2.y
		local function animationCallback( ... )
			-- body
			-- boardView:viberate()
			--theAction.addInfo = "over"
		end
		local item = boardView.baseMap[r_min][c_min]
		item:playMonsterDestroyItem(r_min, r_max, c_min, c_max, theAction.delayIndex, animationCallback)

		if r_max - r_min > 5 then
			theAction.animationDelay = 80
		else
			theAction.animationDelay = 30 + (12*theAction.delayIndex)
		end
		theAction.addInfo = "waitForAnimation"
		theAction.jsq = 0
	else

		if theAction.addInfo == "waitForAnimation" then
			theAction.jsq = theAction.jsq + 1

			if theAction.jsq == theAction.animationDelay then
				theAction.addInfo = "over" 
			end
		end
	end
end

function BoardViewAction:runGameItemActionPM25Update(boardView, theAction) 
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then 
		theAction.actionStatus = GameActionStatus.kRunning
		local r = theAction.ItemPos1.x
		local c = theAction.ItemPos1.y
		local itemView = boardView.baseMap[r][c]
		local function animationCallback( ... )
			-- body
			theAction.addInfo = "replace"
		end
		itemView:playChangeToDigGround(boardView, animationCallback)
	elseif theAction.addInfo == "replaceView" then
		theAction.addInfo = "over"
		local r = theAction.ItemPos1.x
		local c = theAction.ItemPos1.y
		local itemView = boardView.baseMap[r][c]
		local s = itemView.itemSprite[ItemSpriteType.kNormalEffect]
		if s then 
			s:removeFromParentAndCleanup(true)
			itemView.itemSprite[ItemSpriteType.kNormalEffect] = nil
			itemView.isNeedUpdate = true
		end

	end
end

function BoardViewAction:runGameItemActionBlackCuteBallUpdate(boardView, theAction)
	-- body
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		local function animationCallback( ... )
			-- body
			theAction.addInfo = "replace"
		end

		local r1 = theAction.ItemPos1.x
		local c1 = theAction.ItemPos1.y
		local itemView1 = boardView.baseMap[r1][c1]
		if theAction.ItemPos2 then      ----jump
			local r2 = theAction.ItemPos2.x
			local c2 = theAction.ItemPos2.y
			local itemView2 = boardView.baseMap[r2][c2]
			local function itemHide( ... )
				-- body
				if itemView2 then 
					local sp = itemView2:getGameItemSprite()
					if sp then 
						-- sp:setVisible(false) 
						sp:runAction(CCSpawn:createWithTwoActions(CCEaseOut:create(CCMoveBy:create(1, ccp(0, -GamePlayConfig_Tile_Height * 7)), 1/3) , 
							CCEaseSineOut:create(CCFadeOut:create(1) )))
					end
				end

			end
			itemView1:playBlackCuteBallJumpToAnimation(r2, c2, itemHide, animationCallback)
		else                            ----addStrength
			itemView1:playBlackCuteBallDecAnimation(2, animationCallback)
		end
	end
end

function BoardViewAction:runGameItemActionMimosaGrow(boardView, theAction)
	-- body
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		local r = theAction.ItemPos1.x
		local c = theAction.ItemPos1.y
		local itemView = boardView.baseMap[r][c]
		local function mimosa_callback( ... )
			-- body
			theAction.addInfo = "animation_over"
		end
		itemView:playMimosaGrowAnimation(mimosa_callback)
	elseif theAction.addInfo == "effect_item" then
		theAction.addInfo = ""
		local list = theAction.mimosaHoldGrid
		local time = 0 ---延迟生长，后面决定去掉延迟
		local function callback( ... )
			-- body
			theAction.addInfo = "over"
		end
		for k = 1, #list do 
			local r, c = list[k].x, list[k].y
			local itemView = boardView.baseMap[r][c]
			if k == #list then
				itemView:playMimosaEffectAnimation(theAction.itemType, theAction.direction, time * k,  callback, true)
			else
				itemView:playMimosaEffectAnimation(theAction.itemType, theAction.direction, time * k, nil, true)
			end
			
		end
	end

end

function BoardViewAction:runGameItemActionMimosaBack(boardView, theAction)
	-- body
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		local function callback( ... )
			-- body
			theAction.addInfo = "over"
		end

		local list = theAction.mimosaHoldGrid
		local delaytime = 0.6
		for k = 1, #list do 
			local r, c = list[k].x, list[k].y
			local itemView = boardView.baseMap[r][c]
			local call_func = k==#list and callback or nil
			itemView:playMimosaEffectAnimation(theAction.itemType, theAction.direction, delaytime,  call_func, false)
		end

		local r = theAction.ItemPos1.x
		local c = theAction.ItemPos1.y
		local itemView = boardView.baseMap[r][c]

		itemView:playMimosaBackAnimation(delaytime)
	end

end

function BoardViewAction:runGameItemActionMimosaReady(boardView, theAction)
	-- body
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		theAction.addInfo = "over"
		local r, c = theAction.ItemPos1.x,  theAction.ItemPos1.y
		local itemView = boardView.baseMap[r][c]
		itemView:playMimosaReadyAnimation()
	end
end

function BoardViewAction:runGameItemActionHedgehogRoadState(boardView, theAction)
	-- body
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		theAction.addInfo = "over"
		local r, c = theAction.ItemPos1.x,  theAction.ItemPos1.y
		local itemView = boardView.baseMap[r][c]
		itemView:playHedgehogRoadChangeState(theAction.hedgeRoadState)
	end
end

function BoardViewAction:runGameItemActionSnailRoadBright(boardView, theAction)
	-- body
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		theAction.addInfo = "over"
		local r, c = theAction.ItemPos1.x,  theAction.ItemPos1.y
		local itemView = boardView.baseMap[r][c]
		itemView:playSnailRoadChangeState(true)
	end
end

function BoardViewAction:runGameItemActionProductSnail(boardView, theAction)
	-- body
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		local function animationCallback( ... )
			-- body
			theAction.addInfo = "over"
		end
		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local item = boardView.baseMap[r][c]
		item:changToSnail(theAction.direction, animationCallback)
	end
end

function BoardViewAction:runGameItemActionMagicLampReinit(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning 
		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local view = boardView.baseMap[r][c]
		local function callback()
			theAction.addInfo = 'over'
		end
		view:setMagicLampLevel(0, theAction.color, callback) 
	end 
end

function BoardViewAction:runGameItemActionMagicLampCasting(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning 
		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local fromItem = boardView.baseMap[r][c]
		fromItem:setMagicLampLevel(6)
		local toItemPos = theAction.speicalItemPos
		local function actionCallback()
			if not theAction.completeCount then theAction.completeCount = 0 end
			theAction.completeCount = theAction.completeCount + 1
			if theAction.completeCount >= #toItemPos then
				theAction.addInfo = 'over'
			end
		end

		if not toItemPos or #toItemPos == 0 then 
			setTimeOut(actionCallback, 1.4)
		else
			for k, v in pairs(toItemPos) do
				local item = boardView.baseMap[v.r][v.c]
				item:playChangeToLineSpecial(boardView, fromItem, direction, actionCallback)
			end
		end
	end	
end

function BoardViewAction:runGameItemActionWukongCheckAndChangeState(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning 

		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local monkey = boardView.baseMap[r][c]

		local function onChangeToReadyToJumpFin()
			theAction.addInfo = "onChangeToReadyToJumpFin"
		end

		local function onChangeToActiveFin()
			theAction.addInfo = "onChangeToActiveFin"
		end

		if theAction.addInfo == "changeToReadyToJump" then
			monkey:changeWukongState( TileWukongState.kReadyToJump , onChangeToReadyToJumpFin )
		elseif theAction.addInfo == "changeToActive" then
			monkey:changeWukongState( TileWukongState.kOnActive , onChangeToActiveFin )
		end
	end
end

function BoardViewAction:runGameItemActionWukongGift(boardView, theAction)

	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning 
		theAction.addInfo = 'animated'
		--[[
		local function callback()
			theAction.addInfo = 'animated'
		end
		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local item = boardView.baseMap[r][c]
		item:playMaydayBossCast(boardView, callback)
		]]

	elseif theAction.addInfo == 'animated' then
		theAction.addInfo = "waiting"
		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local fromItem = boardView.baseMap[r][c]

		local targetPositions = {}
		local addStepPositions = theAction.addStepPositions
		local lineAndColumnPositions = theAction.lineAndColumnPositions
		local warpPositions = theAction.warpPositions
		
		for k, v in ipairs(addStepPositions) do 
			table.insert( targetPositions , v )
		end

		for k, v in ipairs(lineAndColumnPositions) do 
			table.insert( targetPositions , v )
		end

		for k, v in ipairs(warpPositions) do 
			table.insert( targetPositions , v )
		end

		theAction.completeCount = 0
		local function dropCallback()
			theAction.completeCount = theAction.completeCount + 1
			if theAction.completeCount >= #targetPositions then
				theAction.addInfo = 'toChange'
			end
		end

		if #targetPositions > 0 then
			for k, v in pairs(targetPositions) do 
				local item = boardView.baseMap[v.r][v.c]
				item:playMaydayBossChangeToAddMove(boardView, fromItem, dropCallback)
			end
		else
			dropCallback()
		end
		
	elseif theAction.addInfo == 'toChange' then
		theAction.addInfo = "anim_over"
	elseif theAction.addInfo == 'data_over' then
		theAction.addInfo = 'over'
	end
end

function BoardViewAction:runGameItemActionWukongReinit(boardView, theAction)

	local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
	local view = boardView.baseMap[r][c]

	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning 

		theAction.addInfo = "clearTargetBorad"
		local wukongTargets = theAction.wukongTargetsPosition

		for k, v in pairs(wukongTargets) do
            local board = boardView.baseMap[v.x][v.y]
            board:deleteWukongTarget()
        end
	else
		local function changeWukongColorFin()
			theAction.addInfo = "changeWukongColorFin"
		end

		if theAction.addInfo == "clearTargetBoradFin" then
        	view:changeWukongColor( theAction.color , changeWukongColorFin )
        	--view:showMonkeyBar()
        elseif theAction.addInfo == "over" then

        end
	end 
end


function BoardViewAction:runGameItemActionWukongJumping(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning 

		local r , c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local tr , tc = theAction.monkeyTargetPos.y, theAction.monkeyTargetPos.x
		local monkey = boardView.baseMap[r][c]
		local targetItem = boardView.baseMap[tr][tc]
		local tarPos = IntCoord:clone(theAction.monkeyTargetPos)

		theAction.addInfo = "startJump"

		local function onJumpFin()
			theAction.addInfo = "jumpFin"
		end
		monkey:changeWukongState( TileWukongState.kJumping )
		monkey:playWukongJumpAnimation(tarPos , onJumpFin)
	end
end

function BoardViewAction:runGameItemActionMaydayBossCasting(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning 

		local function callback()
			theAction.addInfo = 'animated'
		end
		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local item = boardView.baseMap[r][c]
		item:playMaydayBossCast(boardView, callback)
		GamePlayMusicPlayer:playEffect(GameMusicType.kWeeklyBossCast)
	elseif theAction.addInfo == 'animated' then
		theAction.addInfo = ''
		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local fromItem = boardView.baseMap[r][c]
		local targetPositions = theAction.targetPositions

		theAction.completeCount = 0
		local function dropCallback()
			theAction.completeCount = theAction.completeCount + 1
			if theAction.completeCount >= #targetPositions then
				theAction.addInfo = 'toChange'
			end
		end
		for k, v in pairs(targetPositions) do 
			local item = boardView.baseMap[v.r][v.c]
			item:playMaydayBossChangeToAddMove(boardView, fromItem, dropCallback)
		end
	elseif theAction.addInfo == 'toChange' then
		theAction.addInfo = ''
		local targetPositions = theAction.targetPositions
		theAction.completeCount = 0
		local function changeCallback()
			theAction.completeCount = theAction.completeCount + 1
			if theAction.completeCount >= #targetPositions then
				theAction.addInfo = 'anim_over'
			end

		end
		for k, v in pairs(targetPositions) do
			local item = boardView.baseMap[v.r][v.c]
			item:playQuestionMarkDestroy(changeCallback)
		end
	elseif theAction.addInfo == 'data_over' then
		theAction.addInfo = 'over'
	end
end

function BoardViewAction:runGameItemActionMaydayBossJump(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning 
		local from_r, from_c = theAction.ItemPos1.x, theAction.ItemPos1.y
		
		local itemFrom = boardView.baseMap[from_r][from_c]
		
		local function jumpCallback()
			theAction.addInfo = "bossDisappered"
		end
		itemFrom:playMaydayBossDisappear(self, jumpCallback)
	elseif theAction.addInfo == "bossDisappered" then
		theAction.addInfo = ""
		local from_r, from_c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local from_data = boardView.gameBoardLogic:getItemMap()[from_r][from_c]
		local to_r, to_c = theAction.ItemPos2.x, theAction.ItemPos2.y
		local data = {x = to_c, y = to_r, w=from_data.w, h = from_data.h, blood = from_data.blood, maxBlood = from_data.maxBlood}
		local itemTo = boardView.baseMap[to_r][to_c]
		local function comeCallback()
			if _G.isLocalDevelopMode then printx(0, 'comeCallback') end
			theAction.addInfo = 'over'
		end
		itemTo:playMaydayBossComeout(self, data, comeCallback)
	end
end

function BoardViewAction:runGameitemActionProductRabbit(boardView, theAction)
	-- body
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		local function shiftCallback( ... )
			-- body
			theAction.addInfo = "shifted"
		end

		local pos = theAction.ItemPos1
		local shiftToPos = theAction.ItemPos2

		if shiftToPos then
			if _G.isLocalDevelopMode then printx(0, 'boardView.baseMap[pos.r][pos.c]', pos.r, pos.c) end
			local item = boardView.baseMap[pos.r][pos.c]
			item:playBirdShiftToAnim(shiftToPos, shiftCallback)
		else
			shiftCallback()
		end
	elseif theAction.addInfo == 'shifted' then
		theAction.addInfo = ''
		local function produceCallback()
			theAction.addInfo = 'over'
		end
		local pos = theAction.ItemPos1
		local item = boardView.baseMap[pos.r][pos.c]
		local color = theAction.color
		item:changeToRabbit(color, theAction.level, produceCallback)
	end
end

function BoardViewAction:runGameitemActionTransmission(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		local from_r, from_c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local to_r, to_c = theAction.ItemPos2.x, theAction.ItemPos2.y
		local item = boardView.baseMap[from_r][from_c]
		local boardData = theAction.boardData
		local itemData = theAction.itemData
		local toTransType = theAction.toTransType

		-- theAction.itemShowType = item.itemShowType

		local function callback()
			theAction.addInfo = "moveOver"
			--if _G.isLocalDevelopMode then printx(0, ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>moveOver", from_r, from_c, to_r, to_c) end
		end

		theAction.transType = boardData.transType -- 留给下一个阶段用
		if boardData.transType == TransmissionType.kSingleTile or boardData.transType == TransmissionType.kEnd then 
			local function getP(direction)
				local p = ccp(0, 0)
				if direction == TransmissionDirection.kRight then
					p.x = GamePlayConfig_Tile_Width
				elseif direction == TransmissionDirection.kLeft then
					p.x = -GamePlayConfig_Tile_Width
				elseif direction == TransmissionDirection.kUp then
					p.y = GamePlayConfig_Tile_Height
				else
					p.y = -GamePlayConfig_Tile_Height
				end
				return p
			end
			item:tailTransToOut(itemData, boardData, getP(boardData.transDirect), boardData.transType)
			local startItem = boardView.baseMap[to_r][to_c]
			startItem:headTransToIn(itemData, boardData, getP(theAction.toBoardDataDirect), toTransType, callback)
		else
			local isCorner = (boardData.transType ~= TransmissionType.kStart and boardData.transType ~= TransmissionType.kRoad)
			local p = ccp((to_c - from_c) * GamePlayConfig_Tile_Width, -(to_r - from_r) * GamePlayConfig_Tile_Height)
			item:roadTransToNext(p, isCorner, callback)
		end
	elseif theAction.addInfo == "reInitView" then
		theAction.addInfo = "over"
		local to_r, to_c = theAction.ItemPos2.x, theAction.ItemPos2.y
		local from_r, from_c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local itemData = theAction.itemData
		local boardData = theAction.boardData
		local toItem = boardView.baseMap[to_r][to_c]
		local fromItem = boardView.baseMap[from_r][from_c]

		toItem.oldData = itemData
		toItem.itemShowType = theAction.itemShowType
		toItem.oldBoard = boardData:copy()

		if theAction.transType == TransmissionType.kSingleTile or theAction.transType == TransmissionType.kEnd then
			toItem:reinitTransHeadByLogic(itemData, boardData)
		else
			toItem:reinitTransRoadByLogic(itemData, boardData, fromItem:getTransContainer())
		end
	end
end


function BoardViewAction:runGameItemActionOctopusChangeForbiddenLevel(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		local level = theAction.level
		local r, c = theAction.ItemPos1.y, theAction.ItemPos1.x
		local item = boardView.baseMap[r][c]
		local function callback ()
			theAction.addInfo = 'over'
		end
		item:playForbiddenLevelAnimation(level, true, callback)
	end
end

function BoardViewAction:runGameitemActionHoneyBottleBroken(boardView, theAction)
	-- body
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local item = boardView.baseMap[r][c]
		local count = 0
		local total  = #theAction.infectList + 1 -- 1 - bottle broken animation
		local function finishcallback( ... )
			-- body
			count = count + 1
			if count >= total then
				theAction.addInfo = "over"
			end
		end

		local function brokenCallback( ... )
			-- body
			for k, v in pairs(theAction.infectList) do 
				local itemInfect = boardView.baseMap[v.x][v.y]
				itemInfect:playBeInfectAnimation(item:getBasePosition(item.x, item.y), finishcallback, 1)
			end
		end
		GameExtandPlayLogic:doAllBlocker195Collect(boardView.gameBoardLogic, r, c, Blocker195CollectType.kHoneyBottle)
		SquidLogic:checkSquidCollectItem(boardView.gameBoardLogic, r, c, TileConst.kHoneyBottle)
		brokenCallback()
		item:playHoneyBottleBroken(finishcallback)
	end
end

function BoardViewAction:runGameitemActionMagicTileHit(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning

		local function finish()
			theAction.addInfo = 'over'
		end

		local scene = Director:sharedDirector():getRunningScene()
		local bossData = boardView.gameBoardLogic:getMoleWeeklyBossData()
		if not bossData or bossData.hit >= bossData.totalBlood then
			--boss已经死了
			theAction.bossDead = true
			finish()
			return
		end

		local newHit = 0
		if bossData then
			if _G.isLocalDevelopMode then printx(0, 'theAction.count', theAction.count) end
			bossData.hit = bossData.hit + theAction.count
		end

		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local pos = boardView.gameBoardLogic:getGameItemPosInView(r, c)
		theAction.bossPosition = ccp(0, 0)
		local function onFlyReachCallback()
			if _G.isLocalDevelopMode then printx(0, 'onFlyReachCallback') end
			if boardView.PlayUIDelegate and boardView.PlayUIDelegate.bossBeeController then
				boardView.PlayUIDelegate.bossBeeController:playHit( nil, bossData.totalBlood-bossData.hit, theAction.count )
			end
			-- GamePlayMusicPlayer:playEffect(GameMusicType.kHalloweenBeeHit)
		end

		if boardView.PlayUIDelegate and boardView.PlayUIDelegate.bossBeeController then
			local bossTarget = boardView.PlayUIDelegate.bossBeeController.BossNode
			local bossWorldPos = bossTarget:getParent():convertToWorldSpace(bossTarget:getPosition())
			theAction.bossPosition = ccp(bossWorldPos.x, bossWorldPos.y)	--打击boss掉落收集物时用
			bossWorldPos.y = bossWorldPos.y + 80	--head
			boardView.PlayUIDelegate:setRainbowPercent((bossData.totalBlood-bossData.hit) / bossData.totalBlood)
			local shiftRange = 60
			local shiftX, shiftY = math.random(-shiftRange, shiftRange), math.random(-shiftRange, shiftRange)
			MoleWeeklyRaceLogic:playMagicTileHitBossAnimation(true, pos, ccp(bossWorldPos.x + shiftX, bossWorldPos.y + shiftY), onFlyReachCallback)
		end

		finish()
	end
end

function BoardViewAction:runGameitemActionMagicTileChange(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		theAction.delayEnd = false

		local function finish()
			theAction.addInfo = 'over'
		end

		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		if theAction.objective == 'die' then
			local item = boardView.baseMap[r][c]
			if item then
				item:deleteMagicTile()
			end

			for i = r, r + 1 do
				for j = c, c + 2 do
					if boardView.baseMap[i] then
						local item = boardView.baseMap[i][j]
						if item then
							item:removeMoleMagicTileCover()
						end
					end
				end
			end
		elseif theAction.objective == 'color' then
			local item = boardView.baseMap[r][c]
			if item then
				item:changeMagicTileColor('red')
			end
		elseif theAction.objective == 'reactiveGrid' then
			local item = boardView.baseMap[r][c]
			if item then
				item:removeMoleMagicTileCover()
			end
		end	

		finish()
	end
end

function BoardViewAction:runGameItemActionSandTransfer(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning

		local fr, fc = theAction.ItemPos1.x, theAction.ItemPos1.y
		local tr, tc = theAction.ItemPos2.x, theAction.ItemPos2.y
		-- if _G.isLocalDevelopMode then printx(0, "runGameItemActionSandTransfer:", fr,fc,"->",tr,tc) end
		local fromItem = boardView.baseMap[fr][fc]
		local toItem = boardView.baseMap[tr][tc]
		local function callback( ... )
			theAction.addInfo = "add"
			toItem:addSandView(theAction.addInt)
		end
		local direction = {dr=tr-fr, dc=tc-fc}
		fromItem:playSandMoveAnim(callback, direction)
	end
end

function BoardViewAction:runningGameItemActionSandTransfer(boardView, theAction)
	if theAction.addInfo == "add" then
		theAction.addInfo = "over"
		local fr, fc = theAction.ItemPos1.x, theAction.ItemPos1.y
		local fromItem = boardView.baseMap[fr][fc]
		fromItem.itemSprite[ItemSpriteType.kSandMove]:removeFromParentAndCleanup(true)
		fromItem.itemSprite[ItemSpriteType.kSandMove] = nil
	end
end

function BoardViewAction:runGameItemActionHedgehogBoxChange(boardView, theAction)
	-- body
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		local function animCallback( ... )
			-- body
			theAction.addInfo = "animationOver"
		end
		local targetPos = boardView.gameBoardLogic:getLevelTargetGlobalPosition(1)
		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local item = boardView.baseMap[r][c]
		item:playHedgehogBoxOpen(animCallback, ccp(targetPos.x, targetPos.y))
	elseif theAction.addInfo == "effect" then
		theAction.addInfo = ""
		local function effectOver( ... )
			-- body
			theAction.current = theAction.current + 1
			if _G.isLocalDevelopMode then printx(0, theAction.current, theAction.total) end
			if theAction.current >= theAction.total then
				-- debug.debug()
				theAction.addInfo = "effectOver"
			end
		end
		theAction.total = 0
		theAction.current = 0
		local changeItemList = {}
		if theAction.changeType == HedgehogBoxCfgConst.kAddMove or 
			theAction.changeType == HedgehogBoxCfgConst.kSpecial then
			if theAction.effectItem then
				for k, v in pairs(theAction.effectItem) do
					table.insert(changeItemList, v)
				end
			end
		end
		if theAction.specialItems then
			for k, v in pairs(theAction.specialItems) do
				table.insert(changeItemList, v)
			end
		end
		if #changeItemList > 0 then
			local r_o, c_o = theAction.ItemPos1.x, theAction.ItemPos1.y
			local itemFrom = boardView.baseMap[r_o][c_o]
			for k, v in pairs(changeItemList) do 
				local item = boardView.baseMap[v.r][v.c]
				theAction.total = theAction.total + 1
				item:playMaydayBossChangeToAddMove(boardView,  itemFrom, effectOver)
			end
		else
			effectOver()
		end
	elseif theAction.addInfo == "updateView" then
		theAction.addInfo = "over"
	end
end

function BoardViewAction:runGameItemActionHedgehogReleaseEnergy(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		local delegate = boardView.gameBoardLogic.PlayUIDelegate
		local function animate_callback( ... )
			-- body
			theAction.addInfo = "change"
		end
		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local item = boardView.baseMap[r][c].itemSprite[ItemSpriteType.kSnail]
		local to_pos = item:getPositionInWorldSpace()

		if delegate then
			delegate:playTargetReleaseEnergy(to_pos, animate_callback)
		else
			animate_callback()
		end
	elseif theAction.addInfo == "change" then
		local function animate_callback_2( ... )
			-- body
			theAction.addInfo = "updateData"
		end
		theAction.addInfo = ""
		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local item = boardView.baseMap[r][c]
		item:playHedgehogChangeAnimation(theAction.hedgehogLevel, animate_callback_2)
	elseif theAction.addInfo == "updateTarget" then
		theAction.addInfo = "over"
	end
end

function BoardViewAction:runGameItemActionCrystalStoneFlying(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning

		local fr, fc = theAction.ItemPos1.x, theAction.ItemPos1.y
		local tr, tc = theAction.ItemPos2.x, theAction.ItemPos2.y

		local toItem = boardView.baseMap[tr][tc]
		local color = theAction.addInt1

		toItem:playChangeColorByCrystalStone(theAction.ItemPos1, color)
	end
end

function BoardViewAction:runGameItemActionHedgehogCleanDigGroud(boardView, theAction)
	-- body
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local item = boardView.baseMap[r][c]
		theAction.bombView = 0
		local function bomb( ... )
			-- body
			theAction.bombView = theAction.bombView + 1
			if theAction.bombView >= #theAction.itemlist then
				theAction.addInfo = 'bomb'
				theAction.bombCount = 1
			end
		end
		for k = 1, #theAction.itemlist do 
			local itemRC = theAction.itemlist[k]
			local _item = boardView.baseMap[itemRC.r][itemRC.c]
			_item:playMaydayBossChangeToAddMove(boardView, item, bomb)
		end
		-- item:playHedgehogCleanDigGround(bomb)
	end
end

function BoardViewAction:runGameItemActionUpdateLotus(boardView, theAction)
	local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
	local item = boardView.baseMap[r][c]
	local updateType = theAction.updateType
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		
		if updateType == 1 then
			item:playLotusAnimation(1 , "in")
		elseif updateType == 2 then
			item:playLotusAnimation(2 , "in")
		else
			item:playLotusAnimation(3 , "in")
		end
		theAction.addInfo = "playAnimation"
	else
		printx( 1 , "   BoardViewAction:runGameItemActionUpdateLotus   " , theAction.viewJSQ ,theAction.viewJSQTarget,theAction.addInfo )
		if theAction.addInfo == "playing" then
			if updateType == 3 and theAction.viewJSQ > theAction.viewJSQTarget - 2 then
				item:setLotusHoldItemVisible(false)
			end
		end
	end
end

function BoardViewAction:runGameItemActionTransferSuperCute(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning

		local fr, fc = theAction.ItemPos1.x, theAction.ItemPos1.y
		local tr, tc = theAction.ItemPos2.x, theAction.ItemPos2.y

		local item = boardView.baseMap[fr][fc]

		local function callback()
			theAction.addInfo = "add"
			local toItem = boardView.baseMap[tr][tc]
			toItem:addSuperCuteBall(GameItemSuperCuteBallState.kActive)
			toItem.isNeedUpdate = true
		end
		item:playSuperCuteMove(IntCoord:create(tr - fr, tc - fc), callback)
	elseif theAction.actionStatus == GameActionStatus.kRunning then
		if theAction.addInfo == "add" then
			local fr, fc = theAction.ItemPos1.x, theAction.ItemPos1.y
			local item = boardView.baseMap[fr][fc]
			theAction.addInfo = "over"
			if item.itemSprite[ItemSpriteType.kSpecial] and item.itemSprite[ItemSpriteType.kSpecial]:getParent() then
				item.itemSprite[ItemSpriteType.kSpecial]:removeFromParentAndCleanup(true)
			end
			item.itemSprite[ItemSpriteType.kSpecial] = nil
		end
	end
end

function BoardViewAction:runGameItemActionRecoverSuperCute(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning

		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y

		if _G.isLocalDevelopMode then printx(0, ">>>>>>>>>>>>>>>>>runGameItemActionRecoverSuperCute", r, c) end

		local item = boardView.baseMap[r][c]

		local function onAimationFinish()
			theAction.addInfo = "over"
		end
		item:playSuperCuteRecover(onAimationFinish)
	end
end

function BoardViewAction:runGameItemActionChickenMontherCast(boardView,theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning

		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local item = boardView.baseMap[r][c]

		local fromPos = ccp(theAction.ItemPos2.x, theAction.ItemPos2.y)
		local toPos = boardView:convertToWorldSpace(item:getBasePosition(c,r))

		local function onCreate()
			theAction.addInfo = "create"
		end

		local function onOver( ... )
			theAction.addInfo = "over"
		end


		if boardView.PlayUIDelegate then
			local anim = SpringAnimations:createChangeEffect(fromPos, toPos, onCreate, onOver, true)
			boardView.PlayUIDelegate.effectLayer:addChild(anim)
		else
			onOver()
		end
	end
end


----播放Item动画
function BoardViewAction:runGameItemAction(boardView, theAction, actid)
	if theAction.actionType == GameItemActionType.kItemScore_Get then
		if theAction.actionStatus == GameActionStatus.kWaitingForStart then
			BoardViewAction:runGameItemActionScoreGet(boardView, theAction)	
		end
	elseif theAction.actionType == GameItemActionType.kItemRefresh_Item_Flying then
		if theAction.actionStatus == GameActionStatus.kWaitingForStart then
			BoardViewAction:runGameItemActionPassRefreshItemFlying(boardView, theAction)
			BoardViewAction:runGameItemActionRefresh_Item_Flying(boardView, theAction)	
		end
		if theAction.addInfo == "over" then
			BoardViewAction:runGameItemActionPassRefreshItemFlyingOver(boardView, theAction)
		end
	elseif theAction.actionType == GameItemActionType.kItem_Crystal_Change then
		if theAction.actionStatus == GameActionStatus.kWaitingForStart then
			BoardViewAction:runGameItemActionItemCrystalChange(boardView, theAction)
		end
	elseif theAction.actionType == GameItemActionType.kItem_Venom_Spread then
		if theAction.actionStatus == GameActionStatus.kWaitingForStart then
			BoardViewAction:runGameItemActionVenomSpread(boardView, theAction)
		elseif theAction.actionStatus == GameActionStatus.kRunning then 
			BoardViewAction:runningGameItemActionVenomSpread(boardView,theAction)
		end
	elseif theAction.actionType == GameItemActionType.kItem_Furball_Transfer then
		if theAction.actionStatus == GameActionStatus.kWaitingForStart then
			BoardViewAction:runGameItemActionFurballTransfer(boardView, theAction)
		elseif theAction.actionStatus == GameActionStatus.kRunning then
			BoardViewAction:runningGameItemActionFurballTransfer(boardView, theAction)
		end
	elseif theAction.actionType == GameItemActionType.kItem_Furball_Split then
		if theAction.actionStatus == GameActionStatus.kWaitingForStart then
			BoardViewAction:runGameItemActionFurballSplit(boardView, theAction)
		elseif theAction.actionStatus == GameActionStatus.kRunning then
			BoardViewAction:runningGameItemActionFurballSplit(boardView, theAction)
		end		
	elseif theAction.actionType == GameItemActionType.kItem_Furball_Brown_Unstable then
		if theAction.actionStatus == GameActionStatus.kWaitingForStart then
			BoardViewAction:runGameItemActionFurballUnstable(boardView, theAction)
		end
	elseif theAction.actionType == GameItemActionType.kItem_Furball_Brown_Shield then
		if theAction.actionStatus == GameActionStatus.kWaitingForStart then
			BoardViewAction:runGameItemActionFurballShield(boardView, theAction)
		end
	elseif theAction.actionType == GameItemActionType.kItemShakeBySpecialColor then
		if theAction.actionStatus == GameActionStatus.kWaitingForStart then
			BoardViewAction:runGameItemActionAnimalShakeBySpecialColor(boardView, theAction)
		elseif theAction.actionStatus == GameActionStatus.kRunning then
			BoardViewAction:runGameItemActionAnimalShakeBySpecialColor(boardView, theAction)
		end
	elseif theAction.actionType == GameItemActionType.kItem_Roost_Replace then
		if theAction.actionStatus == GameActionStatus.kWaitingForStart then
			BoardViewAction:runGameItemActionRoostReplace(boardView, theAction)
		elseif theAction.actionStatus == GameActionStatus.kRunning then
			BoardViewAction:runningGameItemActionRoostReplace(boardView, theAction)
		end
	elseif theAction.actionType == GameItemActionType.kItem_Balloon_update then
		if theAction.actionStatus == GameActionStatus.kWaitingForStart then 
			BoardViewAction:runGameItemActionBalloonUpdateNum(boardView, theAction)
		end
	elseif theAction.actionType == GameItemActionType.kItem_balloon_runAway then 
		BoardViewAction:runGameItemViewActionBallooRunaway(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_ItemChangeToIngredient then 
		BoardViewAction:runGameItemViewActionChangeToIngredient( boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_ItemForceToMove then 
		BoardViewAction:runGameItemViewActionForceMoveItem(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_TileBlocker_Update then 
		BoardViewAction:runGameItemActionTileBlockerUpdate(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_DoubleSideTileBlocker_Update then 
		BoardViewAction:runGameItemActionDoubleSideTileBlockerUpdate(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_Monster_Destroy_Item then
		BoardViewAction:runGameItemActionMonsterDestroyItem(boardView, theAction )
	elseif theAction.actionType == GameItemActionType.kItem_PM25_Update then
		BoardViewAction:runGameItemActionPM25Update(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_Black_Cute_Ball_Update then
		BoardViewAction:runGameItemActionBlackCuteBallUpdate(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_Mimosa_Grow then
		BoardViewAction:runGameItemActionMimosaGrow(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_Mimosa_back then
		BoardViewAction:runGameItemActionMimosaBack(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_Mimosa_Ready then
		BoardViewAction:runGameItemActionMimosaReady(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_Snail_Road_Bright then
		BoardViewAction:runGameItemActionSnailRoadBright(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_Hedgehog_Road_State then
		BoardViewAction:runGameItemActionHedgehogRoadState(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_Snail_Product then
		BoardViewAction:runGameItemActionProductSnail(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_Mayday_Boss_Jump then
		BoardViewAction:runGameItemActionMaydayBossJump(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_Rabbit_Product then 
		BoardViewAction:runGameitemActionProductRabbit(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kOctopus_Change_Forbidden_Level then
		BoardViewAction:runGameItemActionOctopusChangeForbiddenLevel(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_Transmission then 
		BoardViewAction:runGameitemActionTransmission(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_Area_Destruction then
		theAction.actionStatus = GameActionStatus.kRunning
	elseif theAction.actionType == GameItemActionType.kItem_Magic_Lamp_Casting then
		BoardViewAction:runGameItemActionMagicLampCasting(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_Wukong_CheckAndChangeState then
		BoardViewAction:runGameItemActionWukongCheckAndChangeState(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_Wukong_Gift then
		BoardViewAction:runGameItemActionWukongGift(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_Wukong_Reinit then
		BoardViewAction:runGameItemActionWukongReinit(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_Wukong_JumpToTarget then
		BoardViewAction:runGameItemActionWukongJumping(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_Magic_Lamp_Reinit then
		BoardViewAction:runGameItemActionMagicLampReinit(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_Honey_Bottle_Broken then
		BoardViewAction:runGameitemActionHoneyBottleBroken(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_Magic_Tile_Hit then
		BoardViewAction:runGameitemActionMagicTileHit(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_Magic_Tile_Change then
		BoardViewAction:runGameitemActionMagicTileChange(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_Sand_Transfer then
		if theAction.actionStatus == GameActionStatus.kWaitingForStart then
			BoardViewAction:runGameItemActionSandTransfer(boardView, theAction)
		elseif theAction.actionStatus == GameActionStatus.kRunning then
			BoardViewAction:runningGameItemActionSandTransfer(boardView, theAction)
		end
	elseif theAction.actionType == GameItemActionType.kItem_mayday_boss_casting then
		BoardViewAction:runGameItemActionMaydayBossCasting(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_Hedgehog_Clean_Dig_Groud then
		BoardViewAction:runGameItemActionHedgehogCleanDigGroud(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_Hedgehog_Box_Change then
		BoardViewAction:runGameItemActionHedgehogBoxChange(boardView, theAction)
	elseif  theAction.actionType == GameItemActionType.kItem_Hedgehog_Release_Energy then
		BoardViewAction:runGameItemActionHedgehogReleaseEnergy(boardView, theAction)
	elseif  theAction.actionType == GameItemActionType.kItemSpecial_CrystalStone_Flying then
		BoardViewAction:runGameItemActionCrystalStoneFlying(boardView, theAction)
	elseif  theAction.actionType == GameItemActionType.kItem_Update_Lotus then
		BoardViewAction:runGameItemActionUpdateLotus(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_SuperCute_Recover then
		BoardViewAction:runGameItemActionRecoverSuperCute(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_SuperCute_Transfer then
		BoardViewAction:runGameItemActionTransferSuperCute(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_ChickenMonther_Cast then
		BoardViewAction:runGameItemActionChickenMontherCast(boardView,theAction)
	elseif theAction.actionType == GameBoardActionType.kItem_Special_Mix then
		BoardViewAction:runGameItemActioSpecialMix(boardView, theAction, actid) 
	elseif theAction.actionType == GameItemActionType.kBonus_Step_To_Line then
		BoardViewAction:runGameItemActioBonusStepToLine(boardView, theAction) 
	elseif theAction.actionType == GameItemActionType.kItem_Generate_Blocker_Cover then
		BoardViewAction:runGameItemActioGenerateBlockerCover(boardView, theAction) 
	elseif theAction.actionType == GameItemActionType.kItem_Blocker199_Reinit then
		BoardViewAction:runGameItemActionBlocker199Reinit(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_ColorFilter_Filter then
		BoardViewAction:runGameItemActionColorFilterFilter(boardView, theAction)
    elseif theAction.actionType == GameItemActionType.kItem_WanSheng_Broken then
		BoardViewAction:runGameitemActionWanShengBroken(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_AddNewBiscuit then
		BoardViewAction:runGameitemActionAddNewBiscuit(boardView, theAction)
	elseif theAction.actionType == GameItemActionType.kItem_CollectBiscuit then
		BoardViewAction:runGameitemActionCollectBiscuit(boardView, theAction)
	end
end

function BoardViewAction:runGameItemActionColorFilterFilter(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning 
		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local view = boardView.baseMap[r][c]
		view:playColorFilterAFilter() 
		theAction.addInfo = 'over'
	end 
end

function BoardViewAction:runGameItemActioGenerateBlockerCover(boardView, theAction)

	local r = theAction.ItemPos1.x
	local c = theAction.ItemPos1.y

	local originItem = boardView.baseMap[r][c]

	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning

		theAction.jsq = 0
		theAction.addInfo = "waitingForAnimation"

		

		local function playFlyAnimation(level , list)
			if list and #list > 0 then

				for k,v in ipairs(list) do
					local item = boardView.baseMap[v.r][v.c]
					if item then

						local fromPos = originItem:getBasePosition( c , r )
						local toPos = item:getBasePosition( v.c , v.r )

						local eff = TileBlockerCover:createJoinAnimation( fromPos , toPos )

						boardView:addChild( eff )
					end
				end
			end

		end

		playFlyAnimation( 1 , theAction.list_1 )
		playFlyAnimation( 2 , theAction.list_2 )
		playFlyAnimation( 3 , theAction.list_3 )
		--local itemView = sdsadasdas
		--sdafasdgfsadgdsg(  )

	else
		if theAction.addInfo == "waitingForAnimation" then
			theAction.jsq = theAction.jsq + 1

			if theAction.jsq >= 15 then

				originItem:playBlockerCoverMaterialDecEffect(0)

				local function playGenerateAnimation(level , list)
					if list and #list > 0 then
						for k,v in ipairs(list) do
							local item = boardView.baseMap[v.r][v.c]
							if item then
								item:growupBlockerCover(level)
							end
						end
					end
				end

				playGenerateAnimation( 1 , theAction.list_1 )
				playGenerateAnimation( 2 , theAction.list_2 )
				playGenerateAnimation( 3 , theAction.list_3 )

				theAction.addInfo = "doGenerate"
			end
		end
	end
end

function BoardViewAction:runGameItemActioBonusStepToLine(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning

		theAction.addInfo = "start"
	else
		if theAction.addInfo == "flyEnd" then
			local r = theAction.ItemPos1.x
			local c = theAction.ItemPos1.y

			if boardView.PlayUIDelegate then
				local pos = boardView.PlayUIDelegate:getGlobalPositionUnit(r, c)
				local explodeSprite, explodeAnime = SpriteUtil:buildAnimatedSprite(1/30, "special_effect_explode_blue_%04d", 0, 18)
		  		explodeSprite:play(explodeAnime, 0, 1, nil, true)
			  	explodeSprite:setPosition(ccp(pos.x-5, pos.y))
				boardView.PlayUIDelegate.effectLayer:addChild(explodeSprite)
			end

			local specialType = theAction.addInt
			local color = theAction.addInt1
			local itemView = boardView.baseMap[r][c]
			itemView:playAnimalChangeToSpecialEffect(color, specialType, 0.2)
			theAction.addInfo = "wait2"
		end
	end
end

function BoardViewAction:runGameItemActioSpecialMix(boardView, theAction, actid) 
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning

		local r = theAction.ItemPos1.x
		local c = theAction.ItemPos1.y

		local posList = theAction.mixPosList
		local specialType = theAction.specialType

		local relativePosList = {}
		for _, pos in ipairs(posList) do
			local mixItem = boardView.baseMap[pos.x][pos.y]
			mixItem:playMixTileHighlightEffect()
			table.insert(relativePosList, {x=pos.x - r, y = pos.y - c})
		end
		local function callback() 
			--boardView.gameBoardLogic.gameActionList[actid] = nil
		end
		local targetItem = boardView.baseMap[r][c]
		targetItem:playMixTileHighlightEffect()
		targetItem:playMixAnimation(specialType, relativePosList, callback)
	end
end


function BoardViewAction:runAllAction(boardView)
	if boardView and boardView.gameBoardLogic and boardView.gameBoardLogic.gameActionList then
		local actionList = boardView.gameBoardLogic.gameActionList

		local maxIndex = table.maxn(actionList)
		for i = 1 , maxIndex do
			local atc = actionList[i]
			if atc then
				if atc.actionTarget == GameActionTargetType.kGameItemAction then
					BoardViewAction:runGameItemAction(boardView, atc, i)
				end
			end
		end

		--[[
		for k,v in pairs(actionList) do
			if v.actionTarget == GameActionTargetType.kGameItemAction then
				BoardViewAction:runGameItemAction(boardView, v)
			end
		end
		]]
	end
end

function BoardViewAction:runGameItemActionBlocker199Reinit(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning 
		theAction.jsq = 1
		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local view = boardView.baseMap[r][c]
		view:playBlocker199ReinitAnimation(theAction.type, theAction.color, theAction.isRotation)
	elseif theAction.actionStatus == GameActionStatus.kRunning then
		theAction.jsq = theAction.jsq + 1
		if theAction.jsq >= 28 then
			theAction.addInfo = 'over'
		end
	end 
end


--万生消除
function BoardViewAction:runGameitemActionWanShengBroken(boardView, theAction)
	-- body
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
		local r, c = theAction.ItemPos1.x, theAction.ItemPos1.y
		local item = boardView.baseMap[r][c]
		local count = 0
		local total  = #theAction.infectList + 1 -- 1 - bottle broken animation
        local itemInfo = boardView.gameBoardLogic.gameItemMap[r][c]
        local config = itemInfo.wanShengConfig

		local function finishcallback( ... )
			-- body
			count = count + 1
			if count >= total then
				theAction.addInfo = "ChangeItem"
			end
		end

		local function brokenCallback( ... )
			-- body
			for k, v in pairs(theAction.infectList) do 
				local itemInfect = boardView.baseMap[v.item.x][v.item.y]
				itemInfect:playWanShengEndFlyAnimation( config, item:getBasePosition(item.x, item.y), finishcallback, 1)
			end
		end
--		GameExtandPlayLogic:doAllBlocker195Collect(boardView.gameBoardLogic, r, c, Blocker195CollectType.kHoneyBottle)
		SquidLogic:checkSquidCollectItem(boardView.gameBoardLogic, r, c, TileConst.kWanSheng)
		brokenCallback()
		item:playWanShengBroken(finishcallback)
	end

    if theAction.addInfo == "updateView" then

        if #theAction.UpdateData > 0 then
            local Data = theAction.UpdateData[1]
            if Data.ItemType == TileConst.kColorFilter then

                local boardmap = boardView.gameBoardLogic:getBoardMap();
                local ItemData = boardView.gameBoardLogic.gameItemMap[Data.r][Data.c] 		----目标
                local data = boardmap[Data.r][Data.c]
                local itemview = boardView.baseMap[Data.r][Data.c]
                if data.colorFilterState == ColorFilterState.kStateA or data.colorFilterState == ColorFilterState.kStateB then 
		            local pos = itemview:getBasePosition(itemview.x, itemview.y)
		            local colorFilterA = TileColorFilterA:create(data.colorFilterColor)
		            itemview.itemSprite[ItemSpriteType.kColorFilterA] = colorFilterA
		            colorFilterA:setPosition(pos)
		            if data.colorFilterBLevel > 0 then 
			            local colorFilterB = TileColorFilterB:create(itemview.getContainer(ItemSpriteType.kColorFilterB).refCocosObj:getTexture(), 
															            data.colorFilterColor, data.colorFilterBLevel)
			            itemview.itemSprite[ItemSpriteType.kColorFilterB] = colorFilterB
			            colorFilterB:setPosition(pos)
			            itemview.colorFiterEffect = true

                        ItemData.isNeedUpdate = true
		            end
	            end
            end

            table.remove( theAction.UpdateData, 1)
        else
            theAction.addInfo = "destorySelf"
        end
    end
    
end

function BoardViewAction:runGameitemActionAddNewBiscuit( boardView, action )
	if action.actionStatus == GameActionStatus.kWaitingForStart then
		action.actionStatus = GameActionStatus.kRunning
	end

	if action.addInfo == 'playAnim' then
		action.addInfo = 'waitingAnim'
		local r = action.ItemPos1.x
		local c = action.ItemPos1.y
		local newLevel = action.addInt
		boardView.baseMap[r][c]:playUpgradeBiscuitAnim(action.addBiscuitData, newLevel)
	end
end

function BoardViewAction:runGameitemActionCollectBiscuit( boardView, action )

	if action.actionStatus == GameActionStatus.kWaitingForStart then
		action.actionStatus = GameActionStatus.kRunning
	end
	if action.addInfo == 'playAnim' then
		action.addInfo = 'waitingAnim'
		local r = action.ItemPos1.y
		local c = action.ItemPos1.x
		boardView.baseMap[r][c]:playBicsuitCollectAnim(function ( ... )
			action.addInfo = 'over'
		end)
	end
end