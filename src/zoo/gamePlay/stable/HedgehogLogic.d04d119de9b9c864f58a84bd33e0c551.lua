HedgehogLogic = class(SnailLogic)
function HedgehogLogic:create( context )
	-- body
	local v = HedgehogLogic.new()
	v.context = context
	v.mainLogic = context.mainLogic
	v.boardView = v.mainLogic.boardView
	return v
end

function HedgehogLogic:checkHedgehogBoxOnTheWay( ... )
	-- body
	local itemMap = self.mainLogic.gameItemMap
	local function _checkHedgehogBoxOnTheWay( r, c )
		-- body
		local item = itemMap[r][c]
		if item.ItemType == GameItemType.kHedgehogBox then
			return true
		end
		return false
	end

	for r = 1, #itemMap do 
		for c = 1, #itemMap[r] do 
			local item = itemMap[r][c]
			local board = self.mainLogic.boardmap[r][c]
			local nextpos = board:getNextSnailRoad()
			if item  and item:isHedgehog() and item:isAvailable() then
				if nextpos and self.mainLogic:isItemInTile(nextpos.x, nextpos.y) 
					and _checkHedgehogBoxOnTheWay(nextpos.x, nextpos.y) then 
					self.mainLogic.hedgehogBoxDestroy = {r = nextpos.x, c = nextpos.y}
				end
				break
			end
		end
	end
end

function HedgehogLogic:check()
	local function callback( ... )
		-- body
		self:handComplete();
	end

	self.hasItemToHandle = false
	self.completeItem = 0
	self.totalItem = 0
	if not self.mainLogic.snailMark then
		self:handComplete()
		return self.totalItem
	end


	if not self.mainLogic.hedgehogBoxDestroy then   -----检查刺猬礼盒状态
		self:checkHedgehogBoxOnTheWay()
	end

	self.totalItem = self:checkSnailList( callback)
	if self.totalItem == 0 then
		self:handComplete()
	else
		self.hasItemToHandle = true
	end
	return self.totalItem
end


function HedgehogLogic:checkSnailList( callback )
	-- body
	local itemMap = self.mainLogic.gameItemMap
	local count = 0
	local actions = {}
	

	local function moveHedgehog( r, c, list, snailRoadType, hedgehogLevel )
		-- body
		local action = GameBoardActionDataSet:createAs(
					GameActionTargetType.kGameItemAction,
					GameItemActionType.kItem_Hedgehog_Move,
					IntCoord:create(r,c),	
					nil,	
					GamePlayConfig_MaxAction_time)
		action.moveList = list
		action.completeCallback = callback
		action.direction = snailRoadType
		action.hedgehogLevel = hedgehogLevel
		self.mainLogic:addDestructionPlanAction(action)
		self.mainLogic:setNeedCheckFalling()
	end

	for r = 1, #itemMap do 
		for c = 1, #itemMap[r] do 
			local item = itemMap[r][c]
			local board = self.mainLogic.boardmap[r][c]
			local nextpos = board:getNextSnailRoad()
			if item  and item:isHedgehog() and item:isAvailable() then
				if self.mainLogic.hedgehogBoxDestroy then
					count = count + 1
					self:removeHedgehogBox(self.mainLogic.hedgehogBoxDestroy.r, self.mainLogic.hedgehogBoxDestroy.c, callback)
					self.mainLogic.hedgehogBoxDestroy = nil
				else
					local list = self:getMoveList(r, c)
					if #list > 0 then
						count = count + 1
						moveHedgehog(r, c, list, item.snailRoadType, item.hedgehogLevel)
					end
				end
				break
			end
		end
	end
	return count
end

function HedgehogLogic:randomChangeItemChildrensDay()
	local dragonBoatData = self.mainLogic.dragonBoatData
  	if dragonBoatData then
  		local dropPercent = dragonBoatData.dropPropsPercent or 0

  		local isDropProp = false
  		local randPercent = 100
  		if dropPercent > 0 and dropPercent < 100 then
			local rand1 = self.mainLogic.randFactory:rand(1, 1000)
	  		local rand2 = self.mainLogic.randFactory:rand(1, 1000)
	  		randPercent = rand1 * rand2 / 1000000 * 100
  			isDropProp = (randPercent <= dropPercent)
  		elseif dropPercent >= 100 then
  			isDropProp = true
  		end

		if _G.isLocalDevelopMode then printx(0, ">>>>>>>>>randomChangeItemChildrensDay:", isDropProp, ",dropPercent:", dropPercent, ",randPercent:", randPercent) end
  		if isDropProp then
			local hedgehogBoxCfg = self.mainLogic.hedgehogBoxCfg
  			if hedgehogBoxCfg and hedgehogBoxCfg.propList then
				dragonBoatData.dropPropsPercent = 0 -- 一次关卡只掉落一个道具
				local randWeight = self.mainLogic.randFactory:rand(1,10000)
				local randProp = nil 
				for k = 1, #hedgehogBoxCfg.propList do
					if randWeight <= hedgehogBoxCfg.propList[k].limitInAllItem then
						randProp = hedgehogBoxCfg.propList[k]
						break
					end
				end
				if randProp then
					local result_item = {}
					result_item.changeType = HedgehogBoxCfgConst.kProp
					result_item.changeItem = randProp.changeItem
					return result_item
				end
			end
  		end
  	end
  	return nil
end

function HedgehogLogic:randomChangeItem( ... )
	-- body
	local hedgehogBoxCfg = self.mainLogic.hedgehogBoxCfg
	local randValue = self.mainLogic.randFactory:rand(1, 10000)
	local result = 0
	for k = 1, #hedgehogBoxCfg.itemList do
		if randValue <= hedgehogBoxCfg.itemList[k].limitInAllItem then
			result = k
			break
		end
	end

	if not self.mainLogic.hedgehogBoxBombed then    ---首次不能爆宝石
		if hedgehogBoxCfg.itemList[result].changeType == HedgehogBoxCfgConst.kJewl then
			if result == 1 then
				result = 2
			else
				result = result - 1
			end
		end
		self.mainLogic.hedgehogBoxBombed = true
	end

	if hedgehogBoxCfg.itemList[result].changeType == HedgehogBoxCfgConst.kProp then
		local randProp = self.mainLogic.randFactory:rand(1,10000)
		local _result = 0 
		for k = 1, #hedgehogBoxCfg.propList do
			if randProp <= hedgehogBoxCfg.propList[k].limitInAllItem then
				hedgehogBoxCfg.itemList[result].changeItem = hedgehogBoxCfg.propList[k].changeItem
				break
			end
		end
	end

	local result_item = {}
	local tmp = hedgehogBoxCfg.itemList[result]
	result_item.changeType = tmp.changeType
	result_item.changeItem = tmp.changeItem
	if tmp.changeType == HedgehogBoxCfgConst.kProp then
		hedgehogBoxCfg:changPercent(0)
	end
	return result_item
	-- return {changeType = HedgehogBoxCfgConst.kProp, changeItem =10060 }  --test
end

function HedgehogLogic:getHedgehogBoxEffectItem( max )
	-- body
	local itemMap = self.mainLogic.gameItemMap
	local itmeList = {}
	local itemList_bak = {}
	local count = 0
	for r = 1, #itemMap do
		for c = 1, #itemMap[r] do 
			local item = itemMap[r][c]
			if item.ItemType == GameItemType.kAnimal and item.ItemSpecialType == 0 and
				item:isAvailable() and not (item:hasFurball() or item:hasLock()) then
				if r < 5 then 
					table.insert(itemList_bak, {r = r, c = c})
				else
					table.insert(itmeList, {r = r, c = c})
				end
			end
		end
	end

	local result = {}
	for k = 1, max do
		local itemList_count = #itmeList
		local itemList_count_2 = #itemList_bak
		if itemList_count > 0 then
			local item_index = self.mainLogic.randFactory:rand(1, itemList_count)
			local item = table.remove(itmeList, item_index)
			table.insert(result, item)
		elseif itemList_count_2 > 0 then
			local item_index = self.mainLogic.randFactory:rand(1, itemList_count_2)
			local item = table.remove(itemList_bak, item_index)
			table.insert(result, item)
		else
			break
		end
	end
	return result
end

function HedgehogLogic:removeHedgehogBox( r, c, callback  )
	-- body
	local mainLogic = self.mainLogic
	function _callback( ... )
		-- body
		if callback then 
			callback()
		end
	end
	--todo
	local selectChangeItem = self:randomChangeItemChildrensDay() -- 只有道具
	local effectItem = nil
	if _G.isLocalDevelopMode then printx(0, ">>>>>>>>>>>>>>selectChangeItem", table.tostring(selectChangeItem)) end
	if selectChangeItem then
		if selectChangeItem.changeType == HedgehogBoxCfgConst.kProp then
			-- local pos = mainLogic:getGameItemPosInView(r, c)
			-- if mainLogic.PlayUIDelegate then
			-- 	local activityId = 0
			-- 	local text = Localization:getInstance():getText("activity.GuoQing.getprop.tips")
			-- 	activityId = mainLogic.activityId
			-- 	mainLogic.PlayUIDelegate:addTimeProp(selectChangeItem.changeItem, 1, pos, activityId, text)
			-- end
		-- elseif selectChangeItem.changeType == HedgehogBoxCfgConst.kJewl then
		-- elseif selectChangeItem.changeType == HedgehogBoxCfgConst.kAddMove then
		-- 	effectItem = self:getHedgehogBoxEffectItem(GamePlayConfig_HedgehogAwardAddMove)
		-- elseif selectChangeItem.changeType == HedgehogBoxCfgConst.kSpecial then
		-- 	effectItem = self:getHedgehogBoxEffectItem(GamePlayConfig_HedgehogAwardLine + GamePlayConfig_HedgehogAwardWrap)
		end
	end

	local addJewelCount = 10
	local specialNum = 4
	--hedgelog box 
	local action = GameBoardActionDataSet:createAs(
					GameActionTargetType.kGameItemAction,
					GameItemActionType.kItem_Hedgehog_Box_Change,
					IntCoord:create(r,c),	
					nil,	
					GamePlayConfig_MaxAction_time)
	action.completeCallback = _callback
	if selectChangeItem then
		action.changeType = selectChangeItem.changeType
		action.changeItem = selectChangeItem.changeType == HedgehogBoxCfgConst.kProp and selectChangeItem.changeItem or nil
	end
	action.effectItem = effectItem
	action.addJewelCount = addJewelCount
	if specialNum > 0 then
		action.specialItems = self:getHedgehogBoxEffectItem(specialNum)
	end
	
	self.mainLogic:addGameAction(action)

	mainLogic.digJewelCount:setValue(mainLogic.digJewelCount:getValue() + addJewelCount)
end

function HedgehogLogic:resetPreSnailRoads( boardmap )
	-- body
	local function setPre( r, c )
		-- body
		local board = boardmap[r][c]
		if board and board:isHasPreSnailRoad() then
			if r - 1 > 0 and boardmap[r-1][c] and boardmap[r-1][c].snailRoadType == RouteConst.kDown then
				board:setPreSnailRoad( RouteConst.kDown, r-1, c)
			elseif boardmap[r+1] and boardmap[r+1][c] and boardmap[r+1][c].snailRoadType == RouteConst.kUp then
				board:setPreSnailRoad( RouteConst.kUp, r+ 1, c)
			elseif c - 1 > 0 and boardmap[r][c -1] and boardmap[r][c -1].snailRoadType == RouteConst.kRight then
				board:setPreSnailRoad(RouteConst.kRight, r, c-1)
			elseif boardmap[r][c+1] and boardmap[r][c+1].snailRoadType == RouteConst.kLeft then
				board:setPreSnailRoad(RouteConst.kLeft, r, c+1)
			else
				board:setPreSnailRoad()
			end

		end
	end

	for r = 1, #boardmap do 
		for c = 1, #boardmap[r] do 
			setPre(r, c)
		end
	end
end

function HedgehogLogic:getMoveList( r, c, isOnlyCheck )
	-- body
	local list = {}
	local item = self.mainLogic.gameItemMap[r][c]
	local board = self.mainLogic.boardmap[r][c]
	local prePos = IntCoord:create(r, c)
	local nextpos = board:getNextSnailRoad()
	local nextboard  = nil
	if nextpos and self:checkItemCanMove(prePos, nextpos) then
		local nextboard = self.mainLogic.boardmap[nextpos.x][nextpos.y]
		local nextItem = self.mainLogic.gameItemMap[nextpos.x][nextpos.y]
		while nextItem.ItemType == kHedgehogBox  do  -- 处理连续的蜗牛
			table.insert(list, nextpos)
			prePos = nextpos
			nextpos = nextboard:getNextSnailRoad()
			nextItem = self.mainLogic.gameItemMap[nextpos.x][nextpos.y]
			nextboard = self.mainLogic.boardmap[nextpos.x][nextpos.y]
			return list
		end
		while nextboard and nextboard.hedgeRoadState == HedgeRoadState.kPass and self:checkItemCanMove(prePos, nextpos) do       ---连续的路径
			table.insert(list, nextpos)
			local item = self.mainLogic.gameItemMap[nextpos.x][nextpos.y]
			if not isOnlyCheck then
				item.snailTarget = true
				self.mainLogic:checkItemBlock(nextpos.x, nextpos.y)
			end
			
			prePos = nextpos
			nextpos = nextboard:getNextSnailRoad()

			if nextpos and self:checkItemCanMove(prePos, nextpos) then
				nextboard = self.mainLogic.boardmap[nextpos.x][nextpos.y]
			else
				nextboard = nil
			end
		end
	end
	return list
end

function HedgehogLogic:checkHedgehogCrazyList( mainLogic, callback )
	-- body
	local itemMap = mainLogic.gameItemMap
	local count = 0
	for r = 1, #itemMap do 
		for c = 1, #itemMap[r] do 
			local item = itemMap[r][c]
			if item  and item:isHedgehog() and item:isAvailable() then
				local list = HedgehogLogic:getCrazyMoveList( mainLogic, r, c )
				if #list > 0 then
					count = count + 1
					local action = GameBoardActionDataSet:createAs(
						GameActionTargetType.kGameItemAction,
						GameItemActionType.kItem_Hedgehog_Crazy_Move,
						IntCoord:create(r,c),	
						nil,	
						GamePlayConfig_MaxAction_time)
					action.moveList = list
					action.completeCallback = callback
					action.direction = item.snailRoadType
					action.hedgehogLevel = 1
					mainLogic:addDestructionPlanAction(action)
				end
			end
		end
	end
	if count > 0 then 
		mainLogic:setNeedCheckFalling()
	end
	return count

end

function HedgehogLogic:getCrazyMoveList( mainLogic, r, c )
	-- body
	local list = {}
	local item = mainLogic.gameItemMap[r][c]
	local board = mainLogic.boardmap[r][c]
	local prePos = IntCoord:create(r, c)
	local nextpos = board:getNextSnailRoad()
	local nextboard  = nil
	local max = GamePlayConfig_HedgehogBuffStep
	local current = 0

	local function endWithHedgebox( tableList )
		-- body
		if #tableList > 0 then
			local pos = tableList[#tableList]
			local item = mainLogic.gameItemMap[pos.x][pos.y]
			if item.ItemType == GameItemType.kHedgehogBox then 
				return true
			end
		end
		return false

	end

	if nextpos then
		local nextboard = mainLogic.boardmap[nextpos.x][nextpos.y]
		local nextItem = mainLogic.gameItemMap[nextpos.x][nextpos.y]
		while nextboard do  
			table.insert(list, nextpos)
			current = current + 1
			local item = mainLogic.gameItemMap[nextpos.x][nextpos.y]
			item.snailTarget = true
			mainLogic:checkItemBlock(nextpos.x, nextpos.y)
			prePos = nextpos
			nextpos = nextboard:getNextSnailRoad()

			if nextpos and mainLogic:isItemInTile(nextpos.x, nextpos.y) then
				nextboard = mainLogic.boardmap[nextpos.x][nextpos.y]
			else
				nextboard = nil
			end
			if current >= max then
				break
			end
		end

		while endWithHedgebox(list) do
			table.remove(list, #list)
		end
	end
	return list
end

function HedgehogLogic:cleanItem( mainLogic, r, c )
	-- body
	SpecialCoverLogic:SpecialCoverLightUpAtPos(mainLogic, r, c, 1)
	local item = mainLogic.gameItemMap[r][c]
	if item.digGroundLevel > 0 then
        for k = 1, item.digGroundLevel do 
            SpecialCoverLogic:SpecialCoverAtPos(mainLogic, r, c, 0, nil, nil, true, false) 
        end
    elseif item.digJewelLevel > 0 then
        for k = 1, item.digJewelLevel do 
            GameExtandPlayLogic:decreaseDigJewel(mainLogic, r, c, nil, false, false)
        end
    elseif item:hasFurball() then
    	if item.furballType == GameItemFurballType.kGrey then
    		SpecialCoverLogic:SpecialCoverAtPos(mainLogic, r, c, 3)
    		-- SpecialCoverLogic:SpecialCoverAtPos(mainLogic, r, c, 3)
		elseif item.furballType == GameItemFurballType.kBrown then
			item.furballLevel = 0
			item.furballType = GameItemFurballType.kNone
			item.furballDeleting = true
			local scoreAdd = GamePlayConfigScore.Furball
			mainLogic:addScoreToTotal(r, c, scoreAdd)

			local FurballAction = GameBoardActionDataSet:createAs(
				GameActionTargetType.kGameItemAction,
				GameItemActionType.kItem_Furball_Grey_Destroy,
				IntCoord:create(r, c),
				nil,
				GamePlayConfig_GameItemGreyFurballDeleteAction_CD)
			mainLogic:addDestroyAction(FurballAction)
		end
    elseif item.ItemType == GameItemType.kBlackCuteBall then
    	for k = 1, item.blackCuteStrength do 
    		SpecialCoverLogic:SpecialCoverAtPos(mainLogic, r, c, 0, nil, nil, true, false)
    	end
    elseif item.ItemType == GameItemType.kHedgehogBox then
    	mainLogic.hedgehogBoxDestroy= { r = r, c = c}
    elseif item.yellowDiamondLevel > 0  then
        for k = 1, item.yellowDiamondLevel do 
            GameExtandPlayLogic:decreaseYellowDiamond(mainLogic, r, c, nil, false, false)
        end
    else
    	SpecialCoverLogic:SpecialCoverAtPos(mainLogic, r, c, 3)
    end
    BombItemLogic:tryCoverByBomb(mainLogic, r, c, true, 1)
	mainLogic:checkItemBlock(r, c)
end

function HedgehogLogic:resetHedgehogRoadAtPos( mainLogic, r, c )
	-- body
	local item = mainLogic.gameItemMap[r][c]
	local board = mainLogic.boardmap[r][c]
	if board.hedgeRoadState ~= HedgeRoadState.kDestroy then
		board:changeHedgehogRoadState(HedgeRoadState.kDestroy)
		local action = GameBoardActionDataSet:createAs(
			GameActionTargetType.kGameItemAction,
			GameItemActionType.kItem_Hedgehog_Road_State,
			IntCoord:create(r,c),	
			nil,	
			GamePlayConfig_MaxAction_time)
		action.hedgeRoadState = board.hedgeRoadState
		mainLogic:addGameAction(action)
	end
end

function HedgehogLogic:handComplete( ... )
	-- body
	
end