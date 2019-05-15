require "zoo.gamePlay.fsm.GameState"

SwapState = class(GameState)

function SwapState:create(context)
	local v = SwapState.new()
	v.context = context
	v.mainLogic = context.mainLogic
	return v
end

function SwapState:onEnter()
	printx( -1 , ">>>>>>>>>>>>>>>>>swap state enter")
	self.nextState = nil
end

function SwapState:onExit()
	printx( -1 , "<<<<<<<<<<<<<<<<<swap state exit")
	self.nextState = nil
end

function SwapState:update(dt)
	self:runSwapAction()
end

function SwapState:checkTransition()
	return self.nextState
end

function SwapState:runSwapAction()

	local maxIndex = table.maxn(self.mainLogic.swapActionList)
	for i = 1 , maxIndex do
		local atc = self.mainLogic.swapActionList[i]
		if atc then
			self:runSwapActionLogic(self.mainLogic, atc, i)
			self:runSwapActionView(self.mainLogic.boardView, atc)
		end
	end
	--[[
	for k,v in pairs(self.mainLogic.swapActionList) do
		self:runSwapActionLogic(self.mainLogic, v, k)
		self:runSwapActionView(self.mainLogic.boardView, v)
	end
	]]
end

function SwapState:runSwapActionLogic(mainLogic, theAction, actid)
	if theAction.actionStatus == GameActionStatus.kRunning then 		---running阶段，自动扣时间，到时间了，进入Death阶段
		if theAction.actionDuring < 0 then 
			theAction.actionStatus = GameActionStatus.kWaitingForDeath
		else
			theAction.actionDuring = theAction.actionDuring - 1
		end
	end

	local swapCallback = theAction.swapCallback

	if theAction.actionType == GameBoardActionType.kStartTrySwapItem then 							----交换动作
		if theAction.actionStatus == GameActionStatus.kWaitingForDeath then 
			----结束状态
			local r1 = theAction.ItemPos1.x
			local c1 = theAction.ItemPos1.y
			local r2 = theAction.ItemPos2.x
			local c2 = theAction.ItemPos2.y

			local swapSuccess
			if theAction.swapSuccess == nil then 
				swapSuccess = mainLogic:SwapedItemAndMatch(r1,c1,r2,c2, true)
			else
				swapSuccess = theAction.swapSuccess
			end

			if swapSuccess then 			---转换成功
				-- 交换成功动画
				local sprite1, spriteCover1 = mainLogic.boardView.baseMap[r1][c1]:getGameItemSprite()
				local sprite2, spriteCover2 = mainLogic.boardView.baseMap[r2][c2]:getGameItemSprite()
				if sprite1 then sprite1:setScale(1) end
				if sprite2 then sprite2:setScale(1) end
				if spriteCover1 then spriteCover1:setScale(1) end
				if spriteCover2 then spriteCover2:setScale(1) end

				if GameGuide and GameGuide:sharedInstance().pauseBoardUpdateForBombEffect == true then
					GameGuide:sharedInstance().pauseBoardUpdateForBombEffect = false
					theAction.actionStatus = GameActionStatus.kRunning
					theAction.actionDuring = math.ceil(GamePlayConfig_Action_FPS * (GameGuide:sharedInstance().pauseTime or 3) * 0.6)
					theAction.swapSuccess = swapSuccess
					mainLogic.gameItemMap[r1][c1].isNeedUpdate = false
					mainLogic.gameItemMap[r2][c2].isNeedUpdate = false
					return
				elseif GameGuide and GameGuide:sharedInstance().pauseBoardUpdateForIceEffect == true then
					GameGuide:sharedInstance().pauseBoardUpdateForIceEffect = false
					theAction.actionStatus = GameActionStatus.kRunning
					theAction.actionDuring = math.ceil(GamePlayConfig_Action_FPS * (GameGuide:sharedInstance().pauseTime or 3) * 0.6)
					theAction.swapSuccess = swapSuccess
					mainLogic.gameItemMap[r1][c1].isNeedUpdate = false
					mainLogic.gameItemMap[r2][c2].isNeedUpdate = false
					return
				end

				-- 重放代码记录
				if not mainLogic.replaying 
					or mainLogic.replayMode == ReplayMode.kConsistencyCheck_Step1 
					or mainLogic.replayMode == ReplayMode.kAutoPlayCheck  
					or (mainLogic.replayMode == ReplayMode.kMcts and _G.launchCmds.domain) then
					-- table.insert(mainLogic.replaySteps, {x1 = r1, x2 = r2, y1 = c1, y2 = c2})
					mainLogic:addReplayStep({x1 = r1, x2 = r2, y1 = c1, y2 = c2})
					SnapshotManager:catchSwapData({x1 = r1, x2 = r2, y1 = c1, y2 = c2})
				end

				mainLogic.gameItemMap[r1][c1].isNeedUpdate = true
				mainLogic.gameItemMap[r2][c2].isNeedUpdate = true
				theAction.addInfo = "success"
				mainLogic.swapActionList[actid] = nil
				mainLogic:setNeedCheckFalling()
				self.nextState = self.context.fallingMatchState
				if swapCallback then swapCallback(true) end
			else
				----转换失败
				local swapActionFailed = GameBoardActionDataSet:createAs(
					GameActionTargetType.kGameBoardAction,
					GameBoardActionType.kStartTrySwapItemFailed,
					theAction.ItemPos1,
					theAction.ItemPos2,
					GamePlayConfig_SwapAction_Failed_CD					----失败动画时间
				)
				mainLogic.swapActionList[actid] = swapActionFailed

				if mainLogic.replaying then
					local runningScene = Director.sharedDirector():getRunningSceneLua()
					if runningScene and runningScene.isCheckReplayScene then
						runningScene:dp(Event.new("replay_error", {msg="swap_fail"}))
					end
				end
				if swapCallback then swapCallback(false) end
			end
		end
	elseif theAction.actionType == GameBoardActionType.kStartTrySwapItemFailed then
		if theAction.actionStatus == GameActionStatus.kWaitingForDeath then
			mainLogic.swapActionList[actid] = nil	----删除反转换需求
			self.nextState = self.context.waitingState
		end
	elseif theAction.actionType == GameBoardActionType.kStartTrySwapItem_fun then
		if theAction.actionStatus == GameActionStatus.kWaitingForDeath then
			local swapActionFailed = GameBoardActionDataSet:createAs(
				GameActionTargetType.kGameBoardAction,
				GameBoardActionType.kStartTrySwapItemFailed,
				theAction.ItemPos1,
				theAction.ItemPos2,
				GamePlayConfig_SwapAction_Fun_Failed_CD					----失败动画时间
			)
			mainLogic.swapActionList[actid] = swapActionFailed
		end
	end
end

function SwapState:runSwapActionView(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		if theAction.actionType == GameBoardActionType.kStartTrySwapItem then 
			SwapState:runSwapItemAction(boardView, theAction)
			theAction.actionStatus = GameActionStatus.kRunning

		elseif theAction.actionType == GameBoardActionType.kStartTrySwapItemFailed then
			SwapState:runSwapItemFailedAction(boardView, theAction)
			theAction.actionStatus = GameActionStatus.kRunning
		elseif theAction.actionType == GameBoardActionType.kStartTrySwapItem_fun then
			theAction.actionStatus = GameActionStatus.kRunning
			SwapState:runSwapItemActionFun(boardView, theAction)
		end
	elseif theAction.actionStatus == GameActionStatus.kWaitingForDeath then
		if theAction.actionType == GameBoardActionType.kStartTrySwapItem then 
			SwapState:runSwapItemActionComplete(boardView, theAction)
		end
	end
end

function SwapState:getItemPosition(itemPos)
	local x = (itemPos.y - 0.5 ) * GamePlayConfig_Tile_Width
	local y = (GamePlayConfig_Max_Item_Y - itemPos.x - 0.5 ) * GamePlayConfig_Tile_Height
	return ccp(x,y)
end

function SwapState:getActionTime(CDCount)
	return 1.0 / GamePlayConfig_Action_FPS * CDCount
end

function SwapState:runSwapItemAction(boardView, theAction)
	local r1 = theAction.ItemPos1.x
	local c1 = theAction.ItemPos1.y
	local r2 = theAction.ItemPos2.x
	local c2 = theAction.ItemPos2.y

	local sprite1, spriteCover1 = boardView.baseMap[r1][c1]:getGameItemSprite()
	local sprite2, spriteCover2 = boardView.baseMap[r2][c2]:getGameItemSprite()
	if sprite1 == nil or sprite2 == nil then
		if _G.isLocalDevelopMode then 
			printx(0, "SwapState:runSwapItemAction sprite1 == nil or sprite2 == nil, it is a error!!!") 
			printx(0, "SwapState:runSwapItemAction sprite1 at " , r1,c1 , sprite1 ,  "  sprite2 at " , r2,c2 ,sprite2) 
		end
		return false
	end

	local position1 = SwapState:getItemPosition(theAction.ItemPos1)
	local position2 = SwapState:getItemPosition(theAction.ItemPos2)

	if false and CrashResumeGamePlaySpeedUp and boardView.gameBoardLogic and boardView.gameBoardLogic.replaying and boardView.replayMode and boardView.replayMode == ReplayMode.kResume then

		sprite1:setPositionXY( position2.x , position2.y )
		if spriteCover1 then spriteCover1:setPositionXY( position2.x , position2.y ) end
		sprite2:setPositionXY( position1.x , position1.y )
		if spriteCover2 then spriteCover2:setPositionXY( position1.x , position1.y ) end
	else
		sprite1:runAction(SwapState:createSuccessActionsForTwoItem(position2, 1))
		if spriteCover1 then spriteCover1:runAction(SwapState:createSuccessActionsForTwoItem(position2, 1)) end
		sprite2:runAction(SwapState:createSuccessActionsForTwoItem(position1, 2))
		if spriteCover2 then spriteCover2:runAction(SwapState:createSuccessActionsForTwoItem(position1, 2)) end
	end
	
end

function SwapState:createSuccessActionsForTwoItem(endPosition, scaleType)
	local MoveToAction = CCMoveTo:create(SwapState:getActionTime(6), endPosition)
	local scaleAction = CCSequence:create(SwapState:createSuccessScaleAction(scaleType))
	local action = CCSpawn:createWithTwoActions(MoveToAction, scaleAction)
	return action
end

function SwapState:createSuccessScaleAction(scaleType)
	local scaleActionSeq = CCArray:create()
	if scaleType == 1 then -- 横向
		scaleActionSeq:addObject(CCScaleTo:create(BoardViewAction:getActionTime(3), 1.05, 0.96))
		scaleActionSeq:addObject(CCScaleTo:create(BoardViewAction:getActionTime(3), 1.05, 0.96))
		scaleActionSeq:addObject(CCScaleTo:create(BoardViewAction:getActionTime(2), 0.95, 1.05))
	else -- 纵向
		scaleActionSeq:addObject(CCScaleTo:create(BoardViewAction:getActionTime(3), 0.96, 1.05))
		scaleActionSeq:addObject(CCScaleTo:create(BoardViewAction:getActionTime(3), 0.95, 1.07))
		scaleActionSeq:addObject(CCScaleTo:create(BoardViewAction:getActionTime(2), 1.05, 0.95))
	end
	return scaleActionSeq
end

function SwapState:runSwapItemActionComplete(boardView, theAction)
	if theAction.addInfo ~= "success" then
		return
	end
	local r1 = theAction.ItemPos1.x
	local c1 = theAction.ItemPos1.y
	local r2 = theAction.ItemPos2.x
	local c2 = theAction.ItemPos2.y
	local item1 = boardView.baseMap[r1][c1]
	local item2 = boardView.baseMap[r2][c2]

	local tempSprite = nil
	local tempType = 0

	local item2Checked = false
	local item1Checked = false
	for i = 1, #ItemSpriteCanSwapLayers do
		local layerType = ItemSpriteCanSwapLayers[i]

		if not item2Checked and item2.itemSprite[layerType] then
			tempType = layerType
			tempSprite = item2.itemSprite[layerType]
			item2.itemSprite[layerType] = nil
			item2Checked = true
		end

		if not item1Checked and item1.itemSprite[layerType] then
			item2.itemSprite[layerType] = item1.itemSprite[layerType]
			item1.itemSprite[layerType] = nil
			item1Checked = true
		end

		if item1Checked and item2Checked then break end
	end
	item1.itemSprite[tempType] = tempSprite

	local coverType = ItemSpriteType.kGhost
	local tempCoverSprite = item2.itemSprite[coverType]
	item2.itemSprite[coverType] = item1.itemSprite[coverType]
	item1.itemSprite[coverType] = tempCoverSprite

	local tempItemType = item1.oldData.ItemType
	local tempItemColorType = item1.oldData._encrypt.ItemColorType
	local tempSpecialType = item1.oldData.ItemSpecialType
	local tempShowType = item1.itemShowType
	local tempIsBlock = item1.oldData.isBlock

	item1.oldData.ItemType = item2.oldData.ItemType
	item1.oldData._encrypt.ItemColorType = item2.oldData._encrypt.ItemColorType
	item1.oldData.ItemSpecialType = item2.oldData.ItemSpecialType
	item1.itemShowType = item2.itemShowType
	item1.oldData.isBlock = item2.oldData.isBlock

	item2.oldData.ItemType = tempItemType
	item2.oldData._encrypt.ItemColorType = tempItemColorType
	item2.oldData.ItemSpecialType = tempSpecialType
	item2.itemShowType = tempShowType
	item2.oldData.isBlock = tempIsBlock
end

function SwapState:runSwapSuccessAction(boardView, theAction)
	local r1 = theAction.ItemPos1.x
	local c1 = theAction.ItemPos1.y
	local r2 = theAction.ItemPos2.x
	local c2 = theAction.ItemPos2.y

	local sprite1, spriteCover1 = boardView.baseMap[r1][c1]:getGameItemSprite()
	local sprite2, spriteCover2 = boardView.baseMap[r2][c2]:getGameItemSprite()
	if sprite1 == nil or sprite2 == nil then
		if _G.isLocalDevelopMode then printx(0, "SwapState:runSwapItemAction sprite1 == nil or sprite2 == nil, it is a error!!!") end
		return false
	end

	sprite1:runAction(CCScaleTo:create(BoardViewAction:getActionTime(2), 1, 1))
	sprite2:runAction(CCScaleTo:create(BoardViewAction:getActionTime(2), 1, 1))
	if spriteCover1 then spriteCover1:runAction(CCScaleTo:create(BoardViewAction:getActionTime(2), 1, 1)) end
	if spriteCover2 then spriteCover2:runAction(CCScaleTo:create(BoardViewAction:getActionTime(2), 1, 1)) end
end

function SwapState:runSwapItemFailedAction(boardView, theAction)
	local r1 = theAction.ItemPos1.x
	local c1 = theAction.ItemPos1.y
	local r2 = theAction.ItemPos2.x
	local c2 = theAction.ItemPos2.y

	local sprite1, spriteCover1 = boardView.baseMap[r1][c1]:getGameItemSprite()
	local sprite2, spriteCover2 = boardView.baseMap[r2][c2]:getGameItemSprite()
	if sprite1 == nil or sprite2 == nil then
		if _G.isLocalDevelopMode then printx(0, "SwapState:runSwapItemFailedAction sprite1 == nil or sprite2 == nil, it is a error!!!") end
		return false
	end

	local position1 = SwapState:getItemPosition(theAction.ItemPos1)
	local position2 = SwapState:getItemPosition(theAction.ItemPos2)
	local time = theAction.actionDuring

	sprite1:runAction(SwapState:createFailActionsForTwoItem(position1, 1))
	if spriteCover1 then spriteCover1:runAction(SwapState:createFailActionsForTwoItem(position1, 1)) end
	sprite2:runAction(SwapState:createFailActionsForTwoItem(position2, 2))
	if spriteCover2 then spriteCover2:runAction(SwapState:createFailActionsForTwoItem(position2, 2)) end
end

function SwapState:createFailActionsForTwoItem(endPosition, scaleType)
	local MoveToAction = CCMoveTo:create(SwapState:getActionTime(8), endPosition)
	local scaleAction = CCSequence:create(SwapState:createFailScaleAction(scaleType))
	local action = CCSpawn:createWithTwoActions(MoveToAction, scaleAction)
	return action
end

function SwapState:createFailScaleAction(scaleType)
	local scaleActionSeq = CCArray:create()
	if scaleType == 1 then -- 横向
		scaleActionSeq:addObject(CCScaleTo:create(BoardViewAction:getActionTime(3), 1.05, 0.96))
		scaleActionSeq:addObject(CCScaleTo:create(BoardViewAction:getActionTime(3), 1.05, 0.96))
		scaleActionSeq:addObject(CCScaleTo:create(BoardViewAction:getActionTime(2), 0.95, 1.05))
		scaleActionSeq:addObject(CCScaleTo:create(BoardViewAction:getActionTime(2), 1, 1))
	else -- 纵向
		scaleActionSeq:addObject(CCScaleTo:create(BoardViewAction:getActionTime(3), 0.96, 1.05))
		scaleActionSeq:addObject(CCScaleTo:create(BoardViewAction:getActionTime(3), 0.95, 1.07))
		scaleActionSeq:addObject(CCScaleTo:create(BoardViewAction:getActionTime(2), 1.05, 0.95))
		scaleActionSeq:addObject(CCScaleTo:create(BoardViewAction:getActionTime(2), 1, 1))
	end
	return scaleActionSeq
end

function SwapState:runSwapItemActionFun(boardView, theAction)
	local r1 = theAction.ItemPos1.x
	local c1 = theAction.ItemPos1.y
	local r2 = theAction.ItemPos2.x
	local c2 = theAction.ItemPos2.y

	local sprite1, spriteCover1 = boardView.baseMap[r1][c1]:getGameItemSprite()
	local sprite2, spriteCover2 = boardView.baseMap[r2][c2]:getGameItemSprite()
	if sprite1 == nil or sprite2 == nil then
		return false
	end

	local position1 = SwapState:getItemPosition(theAction.ItemPos1)
	local position2 = SwapState:getItemPosition(theAction.ItemPos2)

	local posmid = ccp((position1.x + position2.x)/2, (position1.y + position2.y)/2);
	local posmid1 = ccp((position1.x + posmid.x)/2, (position1.y + posmid.y)/2);
	local posmid2 = ccp((posmid.x + position2.x)/2, (posmid.y + position2.y)/2);
	
	sprite1:runAction(CCMoveTo:create(SwapState:getActionTime(GamePlayConfig_SwapAction_Fun_CD), posmid1))
	sprite2:runAction(CCMoveTo:create(SwapState:getActionTime(GamePlayConfig_SwapAction_Fun_CD), posmid2))
	if spriteCover1 then spriteCover1:runAction(CCMoveTo:create(SwapState:getActionTime(GamePlayConfig_SwapAction_Fun_CD), posmid1)) end
	if spriteCover2 then spriteCover2:runAction(CCMoveTo:create(SwapState:getActionTime(GamePlayConfig_SwapAction_Fun_CD), posmid2)) end
end
