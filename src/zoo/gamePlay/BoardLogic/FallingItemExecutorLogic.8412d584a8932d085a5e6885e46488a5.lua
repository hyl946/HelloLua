
FallingItemExecutorLogic = class{}

function FallingItemExecutorLogic:update(mainLogic)
	BoardViewPass:runAllAction(mainLogic.boardView)
	local count = FallingItemExecutorLogic:runAllAction(mainLogic)
	return count > 0
end

function FallingItemExecutorLogic:runAllAction(mainLogic)
	local count = 0
	local maxIndex = table.maxn(mainLogic.fallingActionList)
	for i = 1 , maxIndex do
		local atc = mainLogic.fallingActionList[i]
		if atc then
			count = count + 1

			FallingItemExecutorLogic:runViewAction(mainLogic.boardView, atc)
			FallingItemExecutorLogic:runLogicAction(mainLogic, atc, i)
		end
	end
	return count
end

function FallingItemExecutorLogic:runLogicAction(mainLogic, theAction, actid)
	-- if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		-- theAction.actionStatus = GameActionStatus.kRunning
	if theAction.actionStatus == GameActionStatus.kRunning then
		if theAction.actionDuring < 0 then 
			theAction.actionStatus = GameActionStatus.kWaitingForDeath
		else
			theAction.actionDuring = theAction.actionDuring - 1
			FallingItemExecutorLogic:runningGameItemAction(mainLogic, theAction, actid)
		end
	end
end

function FallingItemExecutorLogic:runningGameItemAction(mainLogic, theAction, actid)
	if theAction.actionType == GameItemActionType.kItemFalling_UpDown then
		FallingItemExecutorLogic:runningGameItemFallingUpDown(mainLogic,theAction,actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItemFalling_LeftRight then
		FallingItemExecutorLogic:runningGameItemFallingLeftRight(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItemFalling_Product then
		FallingItemExecutorLogic:runningGameItemFallingProduct(mainLogic, theAction, actid, actByView)
	elseif theAction.actionType == GameItemActionType.kItemFalling_Pass then
		FallingItemExecutorLogic:runningGameItemFallingPass(mainLogic, theAction, actid, actByView)
	end
end

function FallingItemExecutorLogic:runViewAction(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning
	end
end

function FallingItemExecutorLogic:runningGameItemFallingUpDown(mainLogic, theAction, actid, actByView)
	local r1 = theAction.ItemPos1.x
	local c1 = theAction.ItemPos1.y
	local r2 = theAction.ItemPos2.x
	local c2 = theAction.ItemPos2.y

	local item1 = mainLogic.gameItemMap[r1][c1] 		----起点方块
	local item2 = mainLogic.gameItemMap[r2][c2] 		----终点空位

	local board1 = mainLogic.boardmap[r1][c1] 		----起点方块
	local board2 = mainLogic.boardmap[r2][c2] 		----终点空位

	-- printx( 1 , "[runningGameItemFallingUpDown]  ~~~~~~~~~~~~~~~~~~~~~~   " , r2, c2 , "\n")

	--------1.掉落过程中可能被干掉------
	if (item2.ItemStatus == GameItemStatusType.kIsMatch 	----被合成或者特效消除
		or item2.ItemStatus == GameItemStatusType.kIsSpecialCover
		or item2.ItemStatus == GameItemStatusType.kDestroy)
		then
		item2.gotoPos = nil
		item2.comePos = nil
		item2.isNeedUpdate = true
		item1.isNeedUpdate = true
		mainLogic.fallingActionList[actid] = nil
		return
	end

	---------2.掉落结束了---------
	if theAction.addInfo == "over" then
		if (item2.ItemStatus == GameItemStatusType.kJustStop) then
			item2:AddItemStatus(GameItemStatusType.kItemHalfStable) 			----半稳定态
			mainLogic:setNeedCheckFalling()
			item2.isNeedUpdate = true
		end
		mainLogic.fallingActionList[actid] = nil	----删除动作------目标驱动类的动作----
		return 
	end

	---------3.开始掉落---Sprite进行传递------
	if theAction.addInfo == "" then
		theAction.addInfo = "Pass"				--告诉界面进行sprite传递
		------删除原有Item数据-------
	elseif theAction.addInfo == "Pass" then
		theAction.addInfo = "Falling" 			----继续掉落
	end

	

	if (item2.itemSpeed == 0) then 						----初始速度
		item2.itemSpeed = GamePlayConfig_FallingSpeed_Start
		-- printx( 1 , "[runningGameItemFallingUpDown]  111   item2.itemSpeed =" , item2.itemSpeed)
	end 

	-----------4.检测撞车------减速------------
	------------4.1检测撞车---》直接撞上-------
	local reachBorder = false
	local item3 = nil
	local board3 = nil
	local hasCrashed = false
	local item2SpeedOverItem3 = false

	local function updateInfos(logicType)
		if board1:isGravityDown() then
			if logicType == 1 then
				if ( r2 + 1 > 9 ) then reachBorder = true end
				if not reachBorder then 
					item3 = mainLogic.gameItemMap[r2 + 1][c2] 
					board3 = mainLogic.boardmap[r2 + 1][c2]
				end
			end
			if item3 then
				if item3.itemPosAdd.y > item2.itemPosAdd.y - item2.itemSpeed then
					hasCrashed = true
				end

				if logicType == 1 then
					if board3:isGravityDown() then
						item2SpeedOverItem3 = item2.itemSpeed > item3.itemSpeed
					else
						item2SpeedOverItem3 = true
					end
				else
					item2SpeedOverItem3 = item2.itemSpeed > item3.itemSpeed
				end
			end
		elseif board1:isGravityUp() then
			if logicType == 1 then
				if ( r2 - 1 < 1 ) then reachBorder = true end
				if not reachBorder then 
					item3 = mainLogic.gameItemMap[r2 - 1][c2]
					board3 = mainLogic.boardmap[r2 - 1][c2] 
				end
			end
			if item3 then
				if item3.itemPosAdd.y < item2.itemPosAdd.y + item2.itemSpeed then
					hasCrashed = true
				end
				if logicType == 1 then
					if board3:isGravityUp() then
						item2SpeedOverItem3 = item2.itemSpeed > item3.itemSpeed
					else
						item2SpeedOverItem3 = true
					end
				else
					item2SpeedOverItem3 = item2.itemSpeed > item3.itemSpeed
				end
			end
		elseif board1:isGravityLeft() then
			if logicType == 1 then
				if ( c2 - 1 < 1 ) then reachBorder = true end
				if not reachBorder then 
					item3 = mainLogic.gameItemMap[r2][c2 - 1] 
					board3 = mainLogic.boardmap[r2][c2 - 1]
				end
			end
			if item3 then
				if item3.itemPosAdd.x < item2.itemPosAdd.x - item2.itemSpeed then
					hasCrashed = true
				end
				if logicType == 1 then
					if board3:isGravityLeft() then
						item2SpeedOverItem3 = item2.itemSpeed > item3.itemSpeed
					else
						item2SpeedOverItem3 = true
					end
				else
					item2SpeedOverItem3 = item2.itemSpeed > item3.itemSpeed
				end
			end
		else
			if logicType == 1 then
				if ( c2 + 1 > 9 ) then reachBorder = true end
				if not reachBorder then 
					item3 = mainLogic.gameItemMap[r2][c2 + 1] 
					board3 = mainLogic.boardmap[r2][c2 + 1]
				end
			end
			if item3 then
				if item3.itemPosAdd.x > item2.itemPosAdd.x + item2.itemSpeed then
					hasCrashed = true
				end
				if logicType == 1 then
					if board3:isGravityRight() then
						item2SpeedOverItem3 = item2.itemSpeed > item3.itemSpeed
					else
						item2SpeedOverItem3 = true
					end
				else
					item2SpeedOverItem3 = item2.itemSpeed > item3.itemSpeed
				end
			end
		end
	end

	updateInfos(1)
	-----------4.检测撞车------减速------------
	------------4.1检测撞车---》直接撞上-------
	if not reachBorder then 		----范围之内
		if item3 and item3.isUsed then 						----使用中
			if item3.ItemStatus == GameItemStatusType.kIsFalling then 				----掉落中
				if item3.itemSpeed>0 
					and item3.comePos ~= nil
					and item3.comePos.x == r2
					and item3.comePos.y == c2
					and item2SpeedOverItem3
					and hasCrashed --要撞车了
					then

					-- printx( 1 , "[runningGameItemFallingUpDown]  撞车  111  item2.itemSpeed =" , item2.itemSpeed , "item3.itemSpeed =" , item3.itemSpeed)
					item2.itemSpeed = item3.itemSpeed - GamePlayConfig_FallingSpeed_Add
					if (item2.itemSpeed < 0 ) then item2.itemSpeed = 0 end
					
					
					if not UseNewFallingLogic then
						item2.itemPosAdd.y = item3.itemPosAdd.y + item2.itemSpeed + GamePlayConfig_FallingSpeed_Add
					else
						if board1:isGravityDown() then
							item2.itemPosAdd.y = item3.itemPosAdd.y + item2.itemSpeed + GamePlayConfig_FallingSpeed_Add
						elseif board1:isGravityUp() then
							
							item2.itemPosAdd.y = item3.itemPosAdd.y - item2.itemSpeed - GamePlayConfig_FallingSpeed_Add
						elseif board1:isGravityLeft() then
							item2.itemPosAdd.x = item3.itemPosAdd.x + item2.itemSpeed + GamePlayConfig_FallingSpeed_Add
						else
							item2.itemPosAdd.x = item3.itemPosAdd.x - item2.itemSpeed - GamePlayConfig_FallingSpeed_Add
						end
					end
				end
			end
		end
	end

  	
	if board2:hasEnterPortal() then
		local r3 = board2.passExitPoint_x;
		local c3 = board2.passExitPoint_y;
		item3 = mainLogic.gameItemMap[r3][c3]
		board3 = mainLogic.boardmap[r3][c3]
		updateInfos(2)
		if item3.itemSpeed>0 
			and item3.comePos ~= nil
			and item3.comePos.x == r2
			and item3.comePos.y == c2
			and item2SpeedOverItem3
			and hasCrashed --要撞车了
			then

			-- printx( 1 , "[runningGameItemFallingUpDown]  撞车  222  item2.itemSpeed =" , item2.itemSpeed , "item3.itemSpeed =" , item3.itemSpeed)
			item2.itemSpeed = item3.itemSpeed - GamePlayConfig_FallingSpeed_Add
			-- printx( 1 , "[runningGameItemFallingUpDown]  333   item2.itemSpeed =" , item2.itemSpeed)
			if (item2.itemSpeed < 0 ) then item2.itemSpeed = 0 end
			
			if not UseNewFallingLogic then
				item2.itemPosAdd.y = item3.itemPosAdd.y + item2.itemSpeed + GamePlayConfig_FallingSpeed_Add
			else
				if board1:isGravityDown() then
					item2.itemPosAdd.y = item3.itemPosAdd.y + item2.itemSpeed + GamePlayConfig_FallingSpeed_Add
				elseif board1:isGravityUp() then
					item2.itemPosAdd.y = item3.itemPosAdd.y - item2.itemSpeed - GamePlayConfig_FallingSpeed_Add
					
				elseif board1:isGravityLeft() then
					item2.itemPosAdd.x = item3.itemPosAdd.x + item2.itemSpeed + GamePlayConfig_FallingSpeed_Add
				else
					item2.itemPosAdd.x = item3.itemPosAdd.x - item2.itemSpeed - GamePlayConfig_FallingSpeed_Add
				end
			end

			--printx( 1 , "runningGameItemFallingUpDown  4.2检测撞车---》下方是一个通道,检测通道对面" , r2,c2 )
		end
	end
	-- printx( 1 , "[runningGameItemFallingUpDown]  444.1   item2.itemSpeed =" , item2.itemSpeed , "+GamePlayConfig_FallingSpeed_Add" , GamePlayConfig_FallingSpeed_Add )
	item2.itemSpeed = item2.itemSpeed + GamePlayConfig_FallingSpeed_Add 		----求新的速度
	-- printx( 1 , "[runningGameItemFallingUpDown]  444.2   item2.itemSpeed =" , item2.itemSpeed , "GamePlayConfig_FallingSpeed_Max =" , GamePlayConfig_FallingSpeed_Max)
	if item2.itemSpeed > GamePlayConfig_FallingSpeed_Max then 
		item2.itemSpeed = GamePlayConfig_FallingSpeed_Max 
	end
	-- printx( 1 , "[runningGameItemFallingUpDown]  444.3   item2.itemSpeed =" , item2.itemSpeed)

	if UseNewFallingLogic == 1 or UseNewFallingLogic == 1.1 then
		
		if board1:isGravityDown() then
			item2.itemPosAdd.y = item2.itemPosAdd.y - item2.itemSpeed
		elseif board1:isGravityUp() then
			item2.itemPosAdd.y = item2.itemPosAdd.y + item2.itemSpeed
		elseif board1:isGravityLeft() then
			item2.itemPosAdd.x = item2.itemPosAdd.x - item2.itemSpeed
		else
			item2.itemPosAdd.x = item2.itemPosAdd.x + item2.itemSpeed
		end

	elseif UseNewFallingLogic == 1.2 then
		item2.itemPosAdd.y = item2.itemPosAdd.y - item2.itemSpeed
	else
		item2.itemPosAdd.y = math.max(item2.itemPosAdd.y - item2.itemSpeed, 0)					----求新位置
	end
	
	-----5.处理使得上面的方块进入下面,本次小段掉落结束------
	local reachPosition = false
	local nearPosition = false
	if not UseNewFallingLogic then
		reachPosition = item2.itemPosAdd.y <= 0
		nearPosition = item2.itemPosAdd.y <= GamePlayConfig_Tile_Height / 2.0
	else
		if board1:isGravityDown() then
			reachPosition = item2.itemPosAdd.y <= 0
			nearPosition = item2.itemPosAdd.y <= GamePlayConfig_Tile_Height / 2.0
		elseif board1:isGravityUp() then
			reachPosition = item2.itemPosAdd.y >= 0
			nearPosition = item2.itemPosAdd.y >= GamePlayConfig_Tile_Height / -2.0

			-- printx( 1 , "[runningGameItemFallingUpDown] reachPosition=" , reachPosition , "nearPosition=" , nearPosition )
		elseif board1:isGravityLeft() then
			reachPosition = item2.itemPosAdd.x <= 0
			nearPosition = item2.itemPosAdd.x <= GamePlayConfig_Tile_Width / 2.0
		else
			reachPosition = item2.itemPosAdd.x >= 0
			nearPosition = item2.itemPosAdd.x >= GamePlayConfig_Tile_Width / -2.0
		end
	end


	if reachPosition then 
		item2.dataReach = true	 											----数据抵达，能被特效消除
		
		-- printx( 1 , "runningGameItemFallingUpDown  over  reachPosition!!!  actid =" , actid )
		if mainLogic.gameMode:checkDropDownCollect(r2, c2) then
			item2.itemPosAdd.x = 0											----位置修正
			item2.itemPosAdd.y = 0											----位置修正
			item2.itemSpeed = 0												----速度变0
		else
			if UseNewFallingLogic then
				--printx( 1 , "[runningGameItemFallingUpDown] ---------------------- 111  item2.ItemStatus =" , item2.ItemStatus )
				if ColorFilterLogic:handleFilter(r2, c2) then 
					--printx( 1 , "[runningGameItemFallingUpDown] ---------------------- 222  item2.ItemStatus =" , item2.ItemStatus )
					item2.itemPosAdd.x = 0
					item2.itemPosAdd.y = 0
					item2.itemSpeed = 0
					item2:AddItemStatus(GameItemStatusType.kItemHalfStable)
				else
					-- printx( 1 , "runningGameItemFallingUpDown  over at" , r2, c2)
					-- printx( 1 , "runningGameItemFallingUpDown  over ~~~~~~~~~~~~~~  item2.itemPosAdd =" , item2.itemPosAdd.x , item2.itemPosAdd.y , "item2.itemSpeed =" , item2.itemSpeed)
					if UseNewFallingLogic == 1 or UseNewFallingLogic == 1.1 then
						NewFallingItemLogic:checkResetSpeedByFallingGoal(mainLogic, r2, c2)
					end
					-- printx( 1 , "runningGameItemFallingUpDown  over RESET!!!!!!!!!  item2.itemPosAdd =" , item2.itemPosAdd.x , item2.itemPosAdd.y , "item2.itemSpeed =" , item2.itemSpeed)

					item2:AddItemStatus(GameItemStatusType.kJustArrived)
					--mainLogic.fallingActionList[actid] = nil
					NewFallingItemLogic:checkResetSpeedByPortal(mainLogic, r2, c2)

					
				end
			else
				local fallType = FallingItemLogic:checkStopFallingDown(mainLogic, r2, c2)

				if fallType == 1 then 
				elseif fallType == 2 then
					--printx( 1 , "runningGameItemFallingUpDown  -----------------------  fallType =" , fallType , r2,c2 )
					item2.itemPosAdd.x = 0
					item2.itemPosAdd.y = 0
					item2.itemSpeed = 0
				else
					item2.itemPosAdd.x = 0
					item2.itemPosAdd.y = 0
					item2.itemSpeed = 0	
					item2:AddItemStatus(GameItemStatusType.kItemHalfStable)
					mainLogic.fallingActionList[actid] = nil
				end
			end
			
		end

		item2.gotoPos = nil
		item2.comePos = nil
		
		theAction.addInfo = "over"											----该动作结束
	elseif nearPosition then
		item2.dataReach = true												----可以被爆掉了
		theAction.addInfo = "halfover"
	end

	if theAction.addInfo == "over" then 
		if not UseNewFallingLogic and ColorFilterLogic:handleFilter(r2, c2) then 
			item2:AddItemStatus(GameItemStatusType.kItemHalfStable)
		end
	end
	-----6.更新显示位置--------
	item1.isNeedUpdate = true
	item2.isNeedUpdate = true
end

function FallingItemExecutorLogic:runningGameItemFallingLeftRight(mainLogic, theAction, actid, actByView)

	local r1 = theAction.ItemPos1.x
	local c1 = theAction.ItemPos1.y
	local r2 = theAction.ItemPos2.x
	local c2 = theAction.ItemPos2.y

	-- printx( 1 , "FallingItemExecutorLogic:runningGameItemFallingLeftRight[NEW] " .. tostring(r1) .. "_" .. tostring(c1) .. "  -->  " .. tostring(r2) .. "_" .. tostring(c2) )

	local item1 = mainLogic.gameItemMap[r1][c1] 		----起点方块
	local item2 = mainLogic.gameItemMap[r2][c2] 		----终点空位

	local board1 = mainLogic.boardmap[r1][c1] 		----起点方块
	local board2 = mainLogic.boardmap[r2][c2] 		----终点空位

	-- printx( 1 , "AAA  item2.itemPosAdd  x = " .. tostring(item2.itemPosAdd.x) .. "   y = " .. tostring(item2.itemPosAdd.y) )

	if (item2.ItemStatus == GameItemStatusType.kIsMatch 	----被合成或者特效消除
		or item2.ItemStatus == GameItemStatusType.kIsSpecialCover
		or item2.ItemStatus == GameItemStatusType.kDestroy)
		then
		item2.gotoPos = nil
		item2.comePos = nil
		item2.isNeedUpdate = true
		item1.isNeedUpdate = true
		mainLogic.fallingActionList[actid] = nil;
		return
	end

	if theAction.addInfo == "over" then
		if (item2.ItemStatus == GameItemStatusType.kJustStop) then
			item2:AddItemStatus(GameItemStatusType.kItemHalfStable)			----半稳定态
			mainLogic:setNeedCheckFalling()
			item2.isNeedUpdate = true;
		end
		mainLogic.fallingActionList[actid] = nil;	----删除动作------目标驱动类的动作----
		return 
	end

	if theAction.addInfo == "" then
		theAction.addInfo = "Pass"				--告诉界面进行sprite传递
	elseif theAction.addInfo == "Pass" then
		theAction.addInfo = "Falling" 			----继续掉落
	end

	local dataReatch = false
	local dataNear = false

	if board1:isGravityDown() then
		item2.itemPosAdd.x = item2.itemPosAdd.x - (c1 - c2) * GamePlayConfig_Falling_LeftRight_Speed_X 						------修改位置
		item2.itemPosAdd.y = math.max(item2.itemPosAdd.y - GamePlayConfig_Falling_LeftRight_Speed_Y, 0) 					------修改位置
		dataReatch = item2.itemPosAdd.y <= 0
		dataNear = item2.itemPosAdd.y <= GamePlayConfig_Tile_Height / 2.0
	elseif board1:isGravityUp() then
		item2.itemPosAdd.x = item2.itemPosAdd.x - (c1 - c2) * GamePlayConfig_Falling_LeftRight_Speed_X 						------修改位置
		item2.itemPosAdd.y = math.min(item2.itemPosAdd.y + GamePlayConfig_Falling_LeftRight_Speed_Y, 0) 					------修改位置
		dataReatch = item2.itemPosAdd.y >= 0
		dataNear = item2.itemPosAdd.y >= GamePlayConfig_Tile_Height / -2.0
	elseif board1:isGravityLeft() then
		item2.itemPosAdd.x = math.max(item2.itemPosAdd.x - GamePlayConfig_Falling_LeftRight_Speed_X, 0) 					------修改位置
		item2.itemPosAdd.y = item2.itemPosAdd.y - (r2 - r1) * GamePlayConfig_Falling_LeftRight_Speed_Y 						------修改位置
		dataReatch = item2.itemPosAdd.x <= 0
		dataNear = item2.itemPosAdd.x <= GamePlayConfig_Tile_Width / 2.0
	else
		item2.itemPosAdd.x = math.min(item2.itemPosAdd.x + GamePlayConfig_Falling_LeftRight_Speed_X, 0) 					------修改位置
		item2.itemPosAdd.y = item2.itemPosAdd.y - (r2 - r1) * GamePlayConfig_Falling_LeftRight_Speed_Y 						------修改位置
		dataReatch = item2.itemPosAdd.x >= 0
		dataNear = item2.itemPosAdd.x >= GamePlayConfig_Tile_Width / -2.0

		-- printx( 1 , "BBB  item2.itemPosAdd  x = " .. tostring(item2.itemPosAdd.x) .. "   y = " .. tostring(item2.itemPosAdd.y) )
	end
	
	if dataReatch then 
		item2.dataReach = true	 											----数据抵达，能被特效消除
		item2.gotoPos = nil
		item2.comePos = nil
		if mainLogic.gameMode:checkDropDownCollect(r2, c2) then
			item2.itemPosAdd.y = 0											----位置修正
			item2.itemSpeed = 0												----速度变0
		else
			if UseNewFallingLogic then
				
				if ColorFilterLogic:handleFilter(r2, c2) then 
					item2.itemPosAdd.x = 0
					item2.itemPosAdd.y = 0
					item2.itemSpeed = 0
					item2:AddItemStatus(GameItemStatusType.kItemHalfStable)
				else
					item2.itemPosAdd.x = 0
					item2.itemPosAdd.y = 0
					item2:AddItemStatus(GameItemStatusType.kJustArrived)
					--mainLogic.fallingActionList[actid] = nil
				end
			else
				local fallType = FallingItemLogic:checkStopFallingDown(mainLogic, r2, c2)
				if fallType == 1 then 
				elseif fallType == 2 then
				else
					item2:AddItemStatus(GameItemStatusType.kItemHalfStable)
					mainLogic.fallingActionList[actid] = nil
				end
				item2.itemPosAdd.y = 0
				item2.itemSpeed = 0
			end
			
		end

		-- printx( 1 , "over!!!!!!  item2.itemPosAdd   x = " .. tostring(item2.itemPosAdd.x) .. "   y = " .. tostring(item2.itemPosAdd.y) )
		theAction.addInfo = "over"											----该动作结束
	elseif dataNear then
		item2.dataReach = true												----可以被爆掉了
		theAction.addInfo = "halfover"
	end

	if theAction.addInfo == "over" then 
		if not UseNewFallingLogic and ColorFilterLogic:handleFilter(r2, c2) then 
			item2:AddItemStatus(GameItemStatusType.kItemHalfStable)
		end
	end
	-----更新显示位置--------
	item1.isNeedUpdate = true
	item2.isNeedUpdate = true
end

function FallingItemExecutorLogic:runningGameItemFallingProduct(mainLogic, theAction, actid, actByView)
	local r1 = theAction.ItemPos1.x
	local c1 = theAction.ItemPos1.y
	local r2 = theAction.ItemPos2.x
	local c2 = theAction.ItemPos2.y

	local item1 = mainLogic.gameItemMap[r1][c1] 		----生成位置
	local board1 = mainLogic.boardmap[r1][c1] 		----生成位置
	-- local board2 = mainLogic.boardmap[r2][c2] 		----生成后应该掉落的位置


	if (item1.ItemStatus == GameItemStatusType.kIsMatch 	----被合成或者特效消除
		or item1.ItemStatus == GameItemStatusType.kIsSpecialCover
		or item1.ItemStatus == GameItemStatusType.kDestroy)
		then
		item1.gotoPos = nil
		item1.comePos = nil
		item1.isNeedUpdate = true
		mainLogic.fallingActionList[actid] = nil

		local itemView1 = mainLogic.boardView.baseMap[r1][c1]
		itemView1:cleanClippingSpriteOfItem()
		return
	end

	---------结束结算----------
	if theAction.addInfo == "over" then
		if (item1.ItemStatus == GameItemStatusType.kJustStop) then
			item1:AddItemStatus(GameItemStatusType.kItemHalfStable)			----半稳定态
			item1.isNeedUpdate = true;
			mainLogic:setNeedCheckFalling()
		end
		mainLogic.fallingActionList[actid] = nil;	----删除动作------目标驱动类的动作----
		return 
	end
	
	---------位置修正--------------
	if theAction.addInfo == "Pass" then
		theAction.addInfo = "Falling"
	end

	local item2 = mainLogic:getGameItemAt(r2, c2) 		----下方方块
	--printx( 1 , "[runningGameItemFallingProduct]  !!!!!!!!!!!!!!!!!!!!   " , r1, c1)
	
	if item2 ~= nil and item2.ItemStatus == GameItemStatusType.kIsFalling and item2.itemSpeed > 0 then
		if UseNewFallingLogic then 
			--item1.itemSpeed = item2.itemSpeed - GamePlayConfig_FallingSpeed_Add
			--if item1.itemSpeed < 0 then item1.itemSpeed = GamePlayConfig_FallingSpeed_Start end
			
			if UseNewFallingLogic == 1.2 then
				local item2NewY = item2.itemPosAdd.y - item2.itemSpeed
				if item2NewY >= 0 then
					item1.itemSpeed = item2.itemSpeed
				else
					item1.itemSpeed = item2.itemPosAdd.y
				end
			else
				item1.itemSpeed = item2.itemSpeed
			end
			--printx( 1 , "[runningGameItemFallingProduct]  111  item1.itemSpeed =" , item1.itemSpeed)
		else
			item1.itemSpeed = item2.itemSpeed
			--printx( 1 , "[runningGameItemFallingProduct]  222  item1.itemSpeed =" , item1.itemSpeed)
		end
	else
		if (item1.itemSpeed == 0) then 												----初始速度
			item1.itemSpeed = GamePlayConfig_FallingSpeed_Start
			--printx( 1 , "[runningGameItemFallingProduct]  333  item1.itemSpeed =" , item1.itemSpeed)
		end 
		item1.itemSpeed = item1.itemSpeed + GamePlayConfig_FallingSpeed_Add 		----求新的速度	
		--printx( 1 , "[runningGameItemFallingProduct]  444  item1.itemSpeed =" , item1.itemSpeed)	
	end

	if item1.itemSpeed > GamePlayConfig_FallingSpeed_Max then 
		item1.itemSpeed = GamePlayConfig_FallingSpeed_Max 
		--printx( 1 , "[runningGameItemFallingProduct]  555  item1.itemSpeed =" , item1.itemSpeed)
	end
	--printx( 1 , "[runningGameItemFallingProduct]  @@@@@@@@@@@@@@@@@@@@@  item1.itemSpeed =" , item1.itemSpeed)

	local dataReatch = false
	local dataNear = false

	if board1:isGravityDown() then
		item1.ClippingPosAdd.y = item1.ClippingPosAdd.y - item1.itemSpeed						----求新位置
		item1.itemPosAdd.y = item1.ClippingPosAdd.y
		if item1.ClippingPosAdd.y <= 0 then dataReatch = true end
		if item1.ClippingPosAdd.y <= GamePlayConfig_Tile_Height / 2.0 then dataNear = true end
	elseif board1:isGravityUp() then
		item1.ClippingPosAdd.y = item1.ClippingPosAdd.y + item1.itemSpeed						----求新位置
		item1.itemPosAdd.y = item1.ClippingPosAdd.y
		if item1.ClippingPosAdd.y >= 0 then dataReatch = true end
		if item1.ClippingPosAdd.y >= GamePlayConfig_Tile_Height / -2.0 then dataNear = true end
	elseif board1:isGravityLeft() then
		item1.ClippingPosAdd.x = item1.ClippingPosAdd.x - item1.itemSpeed						----求新位置
		item1.itemPosAdd.x = item1.ClippingPosAdd.x
		if item1.ClippingPosAdd.x <= 0 then dataReatch = true end
		if item1.ClippingPosAdd.x <= GamePlayConfig_Tile_Width / 2.0 then dataNear = true end
	else
		item1.ClippingPosAdd.x = item1.ClippingPosAdd.x + item1.itemSpeed						----求新位置
		item1.itemPosAdd.x = item1.ClippingPosAdd.x
		if item1.ClippingPosAdd.x >= 0 then dataReatch = true end
		if item1.ClippingPosAdd.x >= GamePlayConfig_Tile_Width / -2.0 then dataNear = true end
	end

	-----------1.处理使得方块正式进入-------------------
	if dataReatch then 
		item1.dataReach = true 												----数据抵达，能被特效消除
		item1.isProduct = false
		item1.gotoPos = nil;
		item1.comePos = nil;

		----视图从clippingNode转移到正常图层
		local itemView1 = mainLogic.boardView.baseMap[r1][c1]
		itemView1:takeClippingNodeToSprite(item1)

		if mainLogic.gameMode:checkDropDownCollect(r1, c1) then
			item1.ClippingPosAdd.x = 0;										----位置修正
			item1.ClippingPosAdd.y = 0;										----位置修正
			item1.itemPosAdd.x = 0;
			item1.itemPosAdd.y = 0;
			item1.itemSpeed = 0;											----速度变0
		else
			if UseNewFallingLogic then
				
				if ColorFilterLogic:handleFilter(r1, c1) then 
					item1.itemPosAdd.x = 0
					item1.itemPosAdd.y = 0
					item1.itemSpeed = 0
					item1:AddItemStatus(GameItemStatusType.kItemHalfStable)
				else
					item1:AddItemStatus(GameItemStatusType.kJustArrived)
					--mainLogic.fallingActionList[actid] = nil
				end
				
			else
				local fallType = FallingItemLogic:checkStopFallingDown(mainLogic, r1, c1)
				if fallType == 1 then 	----不能再掉落了
				elseif fallType == 2 then
					item1.itemPosAdd.y = 0											----位置修正
					item1.itemSpeed = 0												----速度变0
				else
					item1.ClippingPosAdd.y = 0;										----位置修正
					item1.itemPosAdd.y = 0;
					item1.itemSpeed = 0;											----速度变0
					-- item1:AddItemStatus(GameItemStatusType.kJustStop);				----暂停状态
					item1:AddItemStatus(GameItemStatusType.kItemHalfStable)
					mainLogic.fallingActionList[actid] = nil
				end
			end
			
		end
		theAction.addInfo = "over"
	elseif dataNear then
		item1.dataReach = true												----可以被爆掉了
		theAction.addInfo = "halfover"
	end

	if theAction.addInfo == "over" then 
		if not UseNewFallingLogic and ColorFilterLogic:handleFilter(r1, c1) then 
			item1:AddItemStatus(GameItemStatusType.kItemHalfStable)
		end 
	end
	item1.isNeedUpdate = true
end

--------掉落时生成新的Item
function FallingItemExecutorLogic:runningGameItemFallingPass(mainLogic, theAction, actid, actByView)
	local r1 = theAction.ItemPos1.x
	local c1 = theAction.ItemPos1.y
	local r2 = theAction.ItemPos2.x
	local c2 = theAction.ItemPos2.y
	
	local item1 = mainLogic.gameItemMap[r1][c1] 		----上方方块
	local board1 = mainLogic.boardmap[r1][c1]
	local item2 = mainLogic.gameItemMap[r2][c2] 		----下面空位
	local board2 = mainLogic.boardmap[r2][c2]

	if (item2.ItemStatus == GameItemStatusType.kIsMatch 	----被合成或者特效消除
		or item2.ItemStatus == GameItemStatusType.kIsSpecialCover
		or item2.ItemStatus == GameItemStatusType.kDestroy)
		then
		item2.gotoPos = nil
		item2.comePos = nil
		item2.isNeedUpdate = true
		mainLogic.fallingActionList[actid] = nil

		local itemView1 = mainLogic.boardView.baseMap[r1][c1]
		local itemView2 = mainLogic.boardView.baseMap[r2][c2]
		itemView1:cleanEnterClippingSpriteOfItem()
		itemView2:cleanClippingSpriteOfItem()
		return
	end

	---------结束结算----------
	if theAction.addInfo == "over" then
		if (item2.ItemStatus == GameItemStatusType.kJustStop) then
			item2:AddItemStatus(GameItemStatusType.kItemHalfStable)			----半稳定态
			item2.isNeedUpdate = true
			mainLogic:setNeedCheckFalling()
		end
		mainLogic.fallingActionList[actid] = nil	----删除动作------目标驱动类的动作----
		return 
	end

	---------位置修正--------------

	if theAction.addInfo == "Pass" then
		theAction.addInfo = "Falling"
	end

	if (item2.itemSpeed == 0) then 						----初始速度
		item2.itemSpeed = GamePlayConfig_FallingSpeed_Start
	end 


--===================================================================================
	local reachBorder = false
	local item3 = nil
	local board3 = nil
	local hasCrashed = false
	local item2SpeedOverItem3 = false

	if board2:isGravityDown() then
		if ( r2 + 1 > 9 ) then reachBorder = true end
		if not reachBorder then 
			item3 = mainLogic.gameItemMap[r2 + 1][c2] 
			board3 = mainLogic.boardmap[r2 + 1][c2]
		end
		if item3 then
			if item3.itemPosAdd.y > item2.itemPosAdd.y - item2.itemSpeed then
				hasCrashed = true
			end
			if board3:isGravityDown() then
				item2SpeedOverItem3 = item2.itemSpeed > item3.itemSpeed
			else
				item2SpeedOverItem3 = true
			end
		end
	elseif board2:isGravityUp() then
		if ( r2 - 1 < 1 ) then reachBorder = true end
		if not reachBorder then 
			item3 = mainLogic.gameItemMap[r2 - 1][c2]
			board3 = mainLogic.boardmap[r2 - 1][c2] 
		end
		if item3 then
			if item3.itemPosAdd.y < item2.itemPosAdd.y + item2.itemSpeed then
				hasCrashed = true
			end
			if board3:isGravityUp() then
				item2SpeedOverItem3 = item2.itemSpeed > item3.itemSpeed
			else
				item2SpeedOverItem3 = true
			end
		end
	elseif board2:isGravityLeft() then
		if ( c2 - 1 < 1 ) then reachBorder = true end
		if not reachBorder then 
			item3 = mainLogic.gameItemMap[r2][c2 - 1] 
			board3 = mainLogic.boardmap[r2][c2 - 1]
		end
		if item3 then
			if item3.itemPosAdd.x < item2.itemPosAdd.x - item2.itemSpeed then
				hasCrashed = true
			end
			if board3:isGravityLeft() then
				item2SpeedOverItem3 = item2.itemSpeed > item3.itemSpeed
			else
				item2SpeedOverItem3 = true
			end
		end
	else
		if ( c2 + 1 > 9 ) then reachBorder = true end
		if not reachBorder then 
			item3 = mainLogic.gameItemMap[r2][c2 + 1] 
			board3 = mainLogic.boardmap[r2][c2 + 1]
		end
		if item3 then
			if item3.itemPosAdd.x > item2.itemPosAdd.x + item2.itemSpeed then
				hasCrashed = true
			end
			if board3:isGravityRight() then
				item2SpeedOverItem3 = item2.itemSpeed > item3.itemSpeed
			else
				item2SpeedOverItem3 = true
			end
		end
	end

	----------------检测撞车------减速------------
	--if (r2 + 1 < #mainLogic.gameItemMap) then 		----范围之内
	if not reachBorder then 		----
		if item3 and item3.isUsed then 						----使用中
			if item3.ItemStatus == GameItemStatusType.kIsFalling then 				----掉落中
				if item3.itemSpeed>0 
					and item3.comePos ~= nil
					and item3.comePos.x == r2
					and item3.comePos.y == c2
					and item2SpeedOverItem3
					and hasCrashed --要撞车了
					then

					item2.itemSpeed = item3.itemSpeed - GamePlayConfig_FallingSpeed_Add
					if (item2.itemSpeed < 0 ) then item2.itemSpeed = 0 end
					
					if not UseNewFallingLogic then
						item2.itemPosAdd.y = item3.itemPosAdd.y + item2.itemSpeed + GamePlayConfig_FallingSpeed_Add
					else
						if board2:isGravityDown() then
							item2.itemPosAdd.y = item3.itemPosAdd.y + item2.itemSpeed + GamePlayConfig_FallingSpeed_Add
						elseif board2:isGravityUp() then
							item2.itemPosAdd.y = item3.itemPosAdd.y - item2.itemSpeed - GamePlayConfig_FallingSpeed_Add
						elseif board2:isGravityLeft() then
							item2.itemPosAdd.x = item3.itemPosAdd.x + item2.itemSpeed + GamePlayConfig_FallingSpeed_Add
						else
							item2.itemPosAdd.x = item3.itemPosAdd.x - item2.itemSpeed - GamePlayConfig_FallingSpeed_Add
						end
					end
				end
			end
		end
	end

	item2.itemSpeed = item2.itemSpeed + GamePlayConfig_FallingSpeed_Add 		----求新的速度
	if item2.itemSpeed > GamePlayConfig_FallingSpeed_Max then item2.itemSpeed = GamePlayConfig_FallingSpeed_Max end


	if UseNewFallingLogic then
		
		if board2:isGravityDown() then
			item2.ClippingPosAdd.y = item2.ClippingPosAdd.y - item2.itemSpeed			----求新位置
			item2.itemPosAdd.y = math.max(item2.ClippingPosAdd.y, 0)
		elseif board2:isGravityUp() then
			item2.ClippingPosAdd.y = item2.ClippingPosAdd.y + item2.itemSpeed			----求新位置
			item2.itemPosAdd.y = math.min(item2.ClippingPosAdd.y, 0)
		elseif board2:isGravityLeft() then
			item2.ClippingPosAdd.x = item2.ClippingPosAdd.x - item2.itemSpeed			----求新位置
			item2.itemPosAdd.x = math.max(item2.ClippingPosAdd.x, 0)
		else
			item2.ClippingPosAdd.x = item2.ClippingPosAdd.x + item2.itemSpeed			----求新位置
			item2.itemPosAdd.x = math.min(item2.ClippingPosAdd.x, 0)
		end

		if board1:isGravityDown() then
			item1.EnterClippingPosAdd.y = item1.EnterClippingPosAdd.y - item2.itemSpeed
		elseif board1:isGravityUp() then
			item1.EnterClippingPosAdd.y = item1.EnterClippingPosAdd.y + item2.itemSpeed
		elseif board1:isGravityLeft() then
			item1.EnterClippingPosAdd.x = item1.EnterClippingPosAdd.x - item2.itemSpeed
		else
			item1.EnterClippingPosAdd.x = item1.EnterClippingPosAdd.x + item2.itemSpeed
		end

		--[[
		printx( 1 , 
			"item2.ClippingPosAdd.x" , item2.ClippingPosAdd.x , 
			"item2.ClippingPosAdd.y" , item2.ClippingPosAdd.y , 
			"\nitem2.itemPosAdd.x" , item2.itemPosAdd.x , 
			"item2.itemPosAdd.y" , item2.itemPosAdd.y , 
			"\nitem1.EnterClippingPosAdd.x" , item1.EnterClippingPosAdd.x,
			"item1.EnterClippingPosAdd.y" , item1.EnterClippingPosAdd.y)
			]]
	else
		item2.ClippingPosAdd.y = item2.ClippingPosAdd.y - item2.itemSpeed			----求新位置
		item2.itemPosAdd.y = math.max(item2.ClippingPosAdd.y, 0)
		item1.EnterClippingPosAdd.y = item2.ClippingPosAdd.y - item1.h
	end


	local reachPosition = false
	local nearPosition = false
	if not UseNewFallingLogic then
		reachPosition = item2.itemPosAdd.y <= 0
		nearPosition = item2.itemPosAdd.y <= GamePlayConfig_Tile_Height / 2.0
	else
		if board2:isGravityDown() then
			reachPosition = item2.itemPosAdd.y <= 0
			nearPosition = item2.itemPosAdd.y <= GamePlayConfig_Tile_Height / 2.0
		elseif board2:isGravityUp() then
			reachPosition = item2.itemPosAdd.y >= 0
			nearPosition = item2.itemPosAdd.y >= GamePlayConfig_Tile_Height / -2.0

			-- printx( 1 , "[runningGameItemFallingUpDown] reachPosition=" , reachPosition , "nearPosition=" , nearPosition )
		elseif board2:isGravityLeft() then
			reachPosition = item2.itemPosAdd.x <= 0
			nearPosition = item2.itemPosAdd.x <= GamePlayConfig_Tile_Width / 2.0
		else
			reachPosition = item2.itemPosAdd.x >= 0
			nearPosition = item2.itemPosAdd.x >= GamePlayConfig_Tile_Width / -2.0
		end
	end
	
	
	-----------1.处理使得方块正式进入-------------------
	if reachPosition then 
		item2.dataReach = true 											----数据抵达，能被特效消除
		item2.isProduct = false
		item2.gotoPos = nil
		item2.comePos = nil

		----视图从clippingNode转移到正常图层
		local itemView1 = mainLogic.boardView.baseMap[r1][c1]
		local itemView2 = mainLogic.boardView.baseMap[r2][c2]	
		itemView2:takeClippingNodeToSprite(item2)
		itemView1:cleanEnterClippingSpriteOfItem()
		itemView1.isNeedUpdate = true
		itemView2.isNeedUpdate = true

		if mainLogic.gameMode:checkDropDownCollect(r2, c2) then
			item2.ClippingPosAdd.y = 0										----位置修正
			item2.itemPosAdd.y = 0
			item2.itemSpeed = 0												----速度变0
		else
			if UseNewFallingLogic then
				if ColorFilterLogic:handleFilter(r2, c2) then 
					item2.itemPosAdd.y = 0
					item2.itemSpeed = 0
					item2:AddItemStatus(GameItemStatusType.kItemHalfStable)
				else
					item2:AddItemStatus(GameItemStatusType.kJustArrived)
					--mainLogic.fallingActionList[actid] = nil
				end
			else
				local fallType = FallingItemLogic:checkStopFallingDown(mainLogic, r2, c2) 
				if fallType == 1 then 
				elseif fallType == 2 then
					item2.itemPosAdd.y = 0											----位置修正
					item2.itemSpeed = 0												----速度变0
				else
					item2.ClippingPosAdd.y = 0										----位置修正
					item2.itemPosAdd.y = 0
					item2.itemSpeed = 0												----速度变0
					-- item2:AddItemStatus(GameItemStatusType.kJustStop)				----暂停状态
					item2:AddItemStatus(GameItemStatusType.kItemHalfStable)
					mainLogic.fallingActionList[actid] = nil
				end
			end
			
		end
		theAction.addInfo = "over"
	elseif nearPosition then
		item2.dataReach = true												----可以被爆掉了
		theAction.addInfo = "halfover"
	end

	if theAction.addInfo == "over" then 
		if not UseNewFallingLogic and ColorFilterLogic:handleFilter(r2, c2) then 
			item2:AddItemStatus(GameItemStatusType.kItemHalfStable)
		end
	end

	item1.isNeedUpdate = true
	item2.isNeedUpdate = true
end