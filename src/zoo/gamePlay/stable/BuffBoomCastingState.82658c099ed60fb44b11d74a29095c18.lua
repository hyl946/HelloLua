BuffBoomCastingState = class(BaseStableState)

-- 排在前面的优先级高。具体什么名字不重要，能够对应上进行索引就行。
BuffCastingPriorityOrderFlag = {
	"kDigGround", "kBalloon", "kRocket", "kGift", "kSunFlask", "kFrosting", "kMagicLamp", "kMagicStone", 
	"kTurret", "kGhost", "kBottleBlocker", "kMissile", "kBlocker199", "kBlocker211", "kCrystalStone", 
	"kColorFilter", "kBlocker207", "kVenom", "kLock", "kBrownFurball", "kPuffer", "kSnow", "kRoost", 
	"kGreyFurball", "kHoney", "kBlackFurball1", "kBlackFurball2", "kCoin", "kHoneyBottle", "kSuperCute", 
	"kBlockerCover", "kBlockerCoverMaterial", "kMimosa", "kCommon"
}

function BuffBoomCastingState:create(context)
    local v = BuffBoomCastingState.new()
    v.context = context
    v.mainLogic = context.mainLogic
    v.boardView = v.mainLogic.boardView
    return v
end

function BuffBoomCastingState:dispose()
    self.mainLogic = nil
    self.boardView = nil
    self.context = nil
end

function BuffBoomCastingState:update(dt)
    
end

function BuffBoomCastingState:onEnter()
    BaseStableState.onEnter(self)
    self.nextState = nil
    self.hasItemToHandle = false
    
    if GameInitBuffLogic:hasBuffTypeD() then
    	self:tryBoom()
    else
    	self:onActionComplete()
    end
    
end

function BuffBoomCastingState:checkTarget(item , board , type1 , type2 , targetValue , currValue , fixNum)
	
	if not fixNum then fixNum = 0 end

	--printx(1 , "BuffBoomCastingState:checkTarget -----------------  " , type1 , type2 , targetValue , currValue , fixNum)

	if currValue + fixNum >= targetValue then
		return false
	end

	if type1 == GameItemOrderType.kAnimal then

		local color = AnimalTypeConfig.convertIndexToColorType(type2)

		if item.ItemType == GameItemType.kAnimal and item._encrypt.ItemColorType == color then
			return true
		end

	elseif type1 == GameItemOrderType.kSpecialBomb then
		--[[
		if type2 == GameItemOrderType_SB.kLine then

		elseif type2 == GameItemOrderType_SB.kWrap then

		elseif type2 == GameItemOrderType_SB.kColor then

		end
		]]

	elseif type1 == GameItemOrderType.kSpecialSwap then
		-- do nothing
	elseif type1 == GameItemOrderType.kSpecialTarget then

		if type2 == GameItemOrderType_ST.kSnowFlower then
			if item.ItemType == GameItemType.kSnow then
				return true
			end
		elseif type2 == GameItemOrderType_ST.kCoin then
			if item.ItemType == GameItemType.kCoin then
				return true
			end
		elseif type2 == GameItemOrderType_ST.kVenom then
			if item.ItemType == GameItemType.kVenom then
				return true
			end
		elseif type2 == GameItemOrderType_ST.kSnail then
			if item.isSnail then
				return true
			end
		elseif type2 == GameItemOrderType_ST.kGreyCuteBall then
			if item.furballType == GameItemFurballType.kGrey then
				return true
			end
		elseif type2 == GameItemOrderType_ST.kBrownCuteBall then
			if item.furballType == GameItemFurballType.kBrown then
				return true
			end
		elseif type2 == GameItemOrderType_ST.kBottleBlocker then
			if item.ItemType == GameItemType.kBottleBlocker then
				return true
			end
		elseif type2 == GameItemOrderType_ST.kChristmasBell then
			return false
		end

	elseif type1 == GameItemOrderType.kOthers then

		if type2 == GameItemOrderType_Others.kBalloon then
			if item.ItemType == GameItemType.kBalloon then
				return true
			end
		elseif type2 == GameItemOrderType_Others.kBlackCuteBall then
			if item.ItemType == GameItemType.kBlackCuteBall then
				return true
			end
		elseif type2 == GameItemOrderType_Others.kHoney then
			if item.honeyLevel > 0 then
				return true
			end
		elseif type2 == GameItemOrderType_Others.kSand then
			if board.sandLevel > 0 and not item.isEmpty then
				return true
			end
		elseif type2 == GameItemOrderType_Others.kMagicStone then
			if item.ItemType == GameItemType.kMagicStone then
				return true
			end
		elseif type2 == GameItemOrderType_Others.kBoomPuffer then
			if item.ItemType == GameItemType.kPuffer then
				return true
			end
		elseif type2 == GameItemOrderType_Others.kBlockerCoverMaterial then
			if board.blockerCoverMaterialLevel > 0 then
				return true
			end
		elseif type2 == GameItemOrderType_Others.kBlockerCover then
			if item.blockerCoverLevel > 0 then
				return true
			end
		elseif type2 == GameItemOrderType_Others.kBlocker195 then
			return false
		elseif type2 == GameItemOrderType_Others.kChameleon then
			return false
		end

	elseif type1 == GameItemOrderType.kSeaAnimal then
		-- do nothing
	end

	return false
end

function BuffBoomCastingState:tryBoom()
    local mainLogic = self.mainLogic
    local gameItemMap = mainLogic.gameItemMap
    local boardmap = mainLogic.boardmap

    --printx( 1 , "self.mainLogic.theOrderList = " , table.tostring(self.mainLogic.theOrderList) )

    local function findBoom()
    	local boomlist = {}

		for r = 1, #mainLogic.gameItemMap do
			for c = 1, #mainLogic.gameItemMap[r] do
				
				local item = mainLogic.gameItemMap[r][c]
				local board = mainLogic.boardmap[r][c]
				if item 
					and item.ItemType == GameItemType.kBuffBoom 
					and item.level == 0 
					and item.blockerCoverLevel == 0 
					and item.beEffectByMimosa == 0
					and not item:hasActiveSuperCuteBall()
					and not board.isReverseSide
					and not item:seizedByGhost()
					then

					local d = { r=r , c=c }
					table.insert( boomlist , d )
				end
			end
		end

		return boomlist
    end

    local booms = findBoom()

    if not booms or #booms == 0 then
    	self:onActionComplete()
        return
    end

    local availableGridList = {}
    local availableGridMap = {}
    local targetSortList = {}
    local mainTargetSortList = {}
    for i = 1 , #BuffCastingPriorityOrderFlag do
    	targetSortList[i] = {}
    end
    
	

    local function isAvailableGrid(item , board)

		--beEffectByMimosa
		if item and board and board.isUsed then

			if not item:hasBlocker206() and not board.isReverseSide and not item:hasSquidLock() --[[and board.side < 2]] and not item.isEmpty --[[and not item:hasActiveSuperCuteBall()]] then

				if item.ItemType ~= GameItemType.kPoisonBottle
					and item.ItemType ~= GameItemType.kTotems
					and item.ItemType ~= GameItemType.kBlocker195
					and item.ItemType ~= GameItemType.kChameleon
					and item.ItemType ~= GameItemType.kSuperBlocker
					and item.ItemType ~= GameItemType.kPacman
					and item.ItemType ~= GameItemType.kPacmansDen
				then

					if item.ItemType == GameItemType.kMimosa or item.ItemType == GameItemType.kKindMimosa then
						if item:mimosaHasGrowup() then
							return true
						end
					else
						return true
					end
				end
			end
		end
		
		return false
	end


    local function checkMap()

    	local orderSelectedCountMap = {}

		for r = 1, #mainLogic.gameItemMap do
			for c = 1, #mainLogic.gameItemMap[r] do
				
				local item = mainLogic.gameItemMap[r][c]
				local board = mainLogic.boardmap[r][c]

				if isAvailableGrid( item , board ) then
					
					table.insert( availableGridList , {r=r,c=c} )

					--------------------------init  mainTargetSortList -------------------------------
					local function addPosToMainTargetSortList(index , r , c)
						if not availableGridMap[tostring(r) .. "_" .. tostring(c)] then
							if not mainTargetSortList[index] then
								mainTargetSortList[index] = {}
							end
							table.insert( mainTargetSortList[index] , {r=r,c=c} )
							availableGridMap[tostring(r) .. "_" .. tostring(c)] = true
						end
					end

					local nextSnailItem = nil
					local function checkSnail(item , board)
						nextSnailItem = nil
						if item.isSnail and board.snailRoadType > 0 then

							local nextItem = nil
							local nextBoard = nil
							if board.snailRoadType == RouteConst.kLeft then
								nextItem = self.mainLogic.gameItemMap[item.y][item.x - 1]
								nextBoard = self.mainLogic.boardmap[item.y][item.x - 1]
							elseif board.snailRoadType == RouteConst.kRight then
								nextItem = self.mainLogic.gameItemMap[item.y][item.x + 1]
								nextBoard = self.mainLogic.boardmap[item.y][item.x + 1]
							elseif board.snailRoadType == RouteConst.kUp then
								if self.mainLogic.gameItemMap[item.y - 1] then
									nextItem = self.mainLogic.gameItemMap[item.y - 1][item.x]
									nextBoard = self.mainLogic.boardmap[item.y - 1][item.x]
								end
							elseif board.snailRoadType == RouteConst.kDown then
								if self.mainLogic.gameItemMap[item.y + 1] then
									nextItem = self.mainLogic.gameItemMap[item.y + 1][item.x]
									nextBoard = self.mainLogic.boardmap[item.y + 1][item.x]
								end
							end

							if nextItem and nextBoard 
								and isAvailableGrid( nextItem , nextBoard )
								and not nextItem.isEmpty 
								and not nextItem.isSnail 
								and SnailLogic:canEffectSnailRoadAt( self.mainLogic, nextItem.y, nextItem.x ) then
								nextSnailItem = nextItem
								return true
							end
						end
						return false
					end
					
					local playType = self.mainLogic.theGamePlayType
					
					if playType == GameModeTypeId.ORDER_ID then
						local orderList = self.mainLogic.theOrderList

						for k,v in ipairs(orderList) do

							if not orderSelectedCountMap[k] then orderSelectedCountMap[k] = 0 end

							if self:checkTarget( item , board , v.key1 , v.key2 , v.v1 , v.f1 , orderSelectedCountMap[k] ) then

								orderSelectedCountMap[k] = orderSelectedCountMap[k] + 1 

								if board.sandLevel > 0 then
									addPosToMainTargetSortList( 1 , r , c )
								elseif checkSnail( item , board ) then
									if nextSnailItem then
										addPosToMainTargetSortList( 2 , nextSnailItem.y , nextSnailItem.x )
									end
								elseif not item.isSnail and item.ItemType ~= GameItemType.kBlocker195 and item.ItemType ~= GameItemType.kChameleon then
									addPosToMainTargetSortList( 3 , r , c )
								end
							end
						end
					elseif playType == GameModeTypeId.SEA_ORDER_ID then

						if item.ItemType == GameItemType.kBigMonster or item.ItemType == GameItemType.kBigMonsterFrosting then
							if item.bigMonsterFrostingStrength > 0 then
								addPosToMainTargetSortList( 1 , r , c )
							end
						else
							local seaAnimals = self.mainLogic.gameMode.allSeaAnimals
							
							for k, v in pairs(seaAnimals) do
								--printx( 1 , "RRRRRRRRRRRRRRRRRRRRRRRRRR  seaAnimals ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~")
								--printx( 1 , "v.y=" , v.y , "v.x=" , v.x , "v.yEnd=" , v.yEnd , "v.xEnd=" , v.xEnd)
								if r >= v.y and r <= v.yEnd and c >= v.x and c <= v.xEnd then
									if not v.isFreed and not item.isEmpty and board.iceLevel > 0 then
										if item.ItemType == GameItemType.kAnimal or item.ItemType == GameItemType.kCrystal then
											addPosToMainTargetSortList( 2 , r , c )
										else
											addPosToMainTargetSortList( 3 , r , c )
										end
									end
								end
							end
						end
						
					elseif playType == GameModeTypeId.LIGHT_UP_ID then
						if board.iceLevel > 0 and not item.isEmpty then

							if item.ItemType == GameItemType.kBigMonster or item.ItemType == GameItemType.kBigMonsterFrosting then
								if item.bigMonsterFrostingStrength > 0 then
									--printx( 1 , "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ " , item.bigMonsterFrostingStrength , r,c)
									addPosToMainTargetSortList( 1 , r , c )
								end
							else
								if item.ItemType == GameItemType.kAnimal or item.ItemType == GameItemType.kCrystal then
									addPosToMainTargetSortList( 2 , r , c )
								else
									addPosToMainTargetSortList( 3 , r , c )
								end
							end
							
						end
					elseif playType == GameModeTypeId.DIG_TIME_ID or playType == GameModeTypeId.DIG_MOVE_ID or playType == GameModeTypeId.DIG_MOVE_ENDLESS_ID then
						if item.ItemType == GameItemType.kDigJewel then
							addPosToMainTargetSortList( 1 , r , c )
						elseif item.ItemType == GameItemType.kDigGround then
							addPosToMainTargetSortList( 2 , r , c )
						end
					elseif playType == GameModeTypeId.DROP_DOWN_ID then
						if item.ItemType == GameItemType.kIngredient then
							local function checkIngredientDropItem(r,c)
								local dropItem = nil
								if self.mainLogic.gameItemMap[r] then
									dropItem = self.mainLogic.gameItemMap[r][c]
								end

								local dropBoard = nil
								if self.mainLogic.gameItemMap[r] then
									dropBoard = self.mainLogic.gameItemMap[r][c]
								end

								if dropItem and not dropItem.isEmpty 
									and not dropBoard.isReverseSide
									and dropItem.ItemType ~= GameItemType.kPoisonBottle 
									and dropItem.ItemType ~= GameItemType.kSuperBlocker 
									and dropItem.ItemType ~= GameItemType.kChameleon 
									then
									return true
								end
								return false
							end

							if checkIngredientDropItem( r+1 , c ) then
								addPosToMainTargetSortList( 1 , r+1 , c )
							elseif checkIngredientDropItem( r+1 , c+1 ) then
								addPosToMainTargetSortList( 1 , r+1 , c+1 )
							elseif checkIngredientDropItem( r+1 , c-1 ) then
								addPosToMainTargetSortList( 1 , r+1 , c-1 )
							end
						end
					elseif playType == GameModeTypeId.LOTUS_ID then
						if board.lotusLevel > 0 and not item.isEmpty then
							addPosToMainTargetSortList( 1 , r , c )
						end
					elseif playType == GameModeTypeId.CLASSIC_MOVES_ID or playType == GameModeTypeId.CLASSIC_ID then
						--do nothing
					end

					--------------------------init  targetSortList -------------------------------
					local function addPosToTargetSortList(key , r , c)

						local index = table.indexOf(BuffCastingPriorityOrderFlag, key)
						-- printx(11, "index, r, c: "..index..", ("..r..","..c..")")

						if not availableGridMap[tostring(r) .. "_" .. tostring(c)] then
							if not targetSortList[index] then
								targetSortList[index] = {}
							end
							table.insert( targetSortList[index] , {r=r,c=c} )
							availableGridMap[tostring(r) .. "_" .. tostring(c)] = true
						end
					end

					if not item:hasActiveSuperCuteBall() then
						-- 参数字符串与 BuffCastingPriorityOrderFlag 内保持一致就行，BuffCastingPriorityOrderFlag 反映优先级顺序
						if item.ItemType == GameItemType.kDigGround then
							addPosToTargetSortList( "kDigGround" , r , c )
						elseif item.ItemType == GameItemType.kBalloon then
							addPosToTargetSortList( "kBalloon" , r , c )
						elseif item.ItemType == GameItemType.kRocket then
							addPosToTargetSortList( "kRocket" , r , c )
						elseif item.ItemType == GameItemType.kGift or item.ItemType == GameItemType.kNewGift then
							addPosToTargetSortList( "kGift" , r , c )
						elseif item.ItemType == GameItemType.kSunFlask then
							addPosToTargetSortList( "kSunFlask", r, c)
						elseif item.bigMonsterFrostingStrength > 0 then
							addPosToTargetSortList( "kFrosting" , r , c )
						elseif item.ItemType == GameItemType.kMagicLamp and item.lampLevel > 0 and item.lampLevel < 5 then
							addPosToTargetSortList( "kMagicLamp" , r , c )
						elseif item.ItemType == GameItemType.kMagicStone then
							addPosToTargetSortList( "kMagicStone" , r , c )
                        elseif item.ItemType == GameItemType.kTurret and not item.turretLocked then
							addPosToTargetSortList( "kTurret" , r , c )
						elseif item:isFreeGhost() and GhostLogic:ghostCanMoveUpward(item) then
							addPosToTargetSortList( "kGhost" , r , c )
						elseif item.ItemType == GameItemType.kBottleBlocker then
							addPosToTargetSortList( "kBottleBlocker" , r , c )
						elseif item.ItemType == GameItemType.kMissile and item.missileLevel > 0 then
							addPosToTargetSortList( "kMissile" , r , c )
						elseif item.ItemType == GameItemType.kBlocker199 then
							addPosToTargetSortList( "kBlocker199" , r , c )
						elseif item.ItemType == GameItemType.kBlocker211 then
							addPosToTargetSortList( "kBlocker211" , r , c )
						elseif item.ItemType == GameItemType.kCrystalStone and not item:isCrystalStoneActive() then
							addPosToTargetSortList( "kCrystalStone" , r , c )
						elseif board.colorFilterBLevel > 0 then
							addPosToTargetSortList( "kColorFilter" , r , c )
						elseif item.ItemType == GameItemType.kBlocker207 then
							addPosToTargetSortList( "kBlocker207" , r , c )
						elseif item.ItemType == GameItemType.kVenom then
							addPosToTargetSortList( "kVenom" , r , c )
						elseif item.cageLevel > 0 then
							addPosToTargetSortList( "kLock" , r , c )
						elseif item.furballType == GameItemFurballType.kBrown then
							addPosToTargetSortList( "kBrownFurball" , r , c )
						elseif item.ItemType == GameItemType.kPuffer and ( item.pufferState == PufferState.kNormal or item.pufferState == PufferState.kActivated ) then
							addPosToTargetSortList( "kPuffer" , r , c )
						elseif item.ItemType == GameItemType.kSnow then
							addPosToTargetSortList( "kSnow" , r , c )
						elseif item.ItemType == GameItemType.kRoost then
							addPosToTargetSortList( "kRoost" , r , c )
						elseif item.furballType == GameItemFurballType.kGrey then
							addPosToTargetSortList( "kGreyFurball" , r , c )
						elseif item.honeyLevel > 0 then
							addPosToTargetSortList( "kHoney" , r , c )
						elseif item.blackCuteStrength == 1 then
							addPosToTargetSortList( "kBlackFurball1" , r , c )
						elseif item.blackCuteStrength == 2 then
							addPosToTargetSortList( "kBlackFurball2" , r , c )
						elseif item.ItemType == GameItemType.kCoin then
							addPosToTargetSortList( "kCoin" , r , c )
						elseif item.ItemType == GameItemType.kHoneyBottle then
							addPosToTargetSortList( "kHoneyBottle" , r , c )
						elseif item:hasActiveSuperCuteBall() then
							addPosToTargetSortList( "kSuperCute" , r , c )
						elseif item.blockerCoverLevel > 0 then
							addPosToTargetSortList( "kBlockerCover" , r , c )
						elseif board.blockerCoverMaterialLevel > 0 then
							addPosToTargetSortList( "kBlockerCoverMaterial" , r , c )
						elseif item.ItemType == GameItemType.kMimosa or item.ItemType == GameItemType.kKindMimosa then
							addPosToTargetSortList( "kMimosa" , r , c )
						elseif item.ItemType == GameItemType.kAnimal or item.ItemType == GameItemType.kCrystal 
							or item.ItemType == GameItemType.kScoreBuffBottle then
							addPosToTargetSortList( "kCommon" , r , c )
						end
					end
				end
			end
		end
	end

	--[[
    -- bonus time
    if mainLogic.isBonusTime then
    	--printx( 1 , "    BuffBoomCastingState   ---------------------------  return 1")
        self:onActionComplete()
        return
    end
    ]]

    ------------------------do  random ---------------------------------------------
    checkMap()

    --printx( 1 , "TEST !!!!!!!!!!!!!!!!!!!!!!!! 111" , table.tostring(mainTargetSortList) )
    --printx( 1 , "TEST !!!!!!!!!!!!!!!!!!!!!!!! 222" , table.tostring(targetSortList) )

    for k,v in ipairs(booms) do
		local datas = v
		datas.targetList = {}
		--table.insert( datas.targetList , availableGridList[1] )
		--table.insert( datas.targetList , availableGridList[5] )
		--table.insert( datas.targetList , availableGridList[9] )

		for i = 1 , 3 do
			local finded = false
			for ia = 1 , 4 do
				
				local list = mainTargetSortList[ia]
				if list and #list > 0 then
					local rindex = self.mainLogic.randFactory:rand( 1 , #list )
					local pos = list[rindex]
					table.remove( list , rindex )

					table.insert( datas.targetList , pos )
					finded = true
					break
				end
			end
			
			--printx(1 , "targetSortList =" , table.tostring(targetSortList))
			if not finded then

				for ia = 1 , #BuffCastingPriorityOrderFlag do
					local list = targetSortList[ia]
					if list and #list > 0 then
						local rindex = self.mainLogic.randFactory:rand( 1 , #list )
						local pos = list[rindex]
						table.remove( list , rindex )

						table.insert( datas.targetList , pos )
						finded = true
						break
					end
				end
				
			end

			if not finded then
				break
			end
		end
	end


    local function actionCallback()
        self:onActionComplete()
    end

    local buffBoomExplodeAction = GameBoardActionDataSet:createAs(
                        GameActionTargetType.kGameItemAction,
                        GameItemActionType.kBuffBoom_Explode,
                        nil,
                        nil,
                        GamePlayConfig_MaxAction_time
                    )
    buffBoomExplodeAction.completeCallback = actionCallback
    buffBoomExplodeAction.booms = booms

    --printx( 1 , "  BuffBoomCastingState  11111111111111111111111111111111111111111111111111111111 ")
    --printx( 1 , "  ++++++++++++++++++++++++++++++++  list_1 = " , table.tostring(list_1)  )
    --printx( 1 , "  ++++++++++++++++++++++++++++++++  list_2 = " , table.tostring(list_2)  )
    --printx( 1 , "  ++++++++++++++++++++++++++++++++  list_3 = " , table.tostring(list_3)  )
    self.mainLogic:addGlobalCoreAction(buffBoomExplodeAction)

    self.context.needLoopCheck = true
end

function BuffBoomCastingState:getClassName()
    return "BuffBoomCastingState"
end

function BuffBoomCastingState:checkTransition()
    return self.nextState
end

function BuffBoomCastingState:onActionComplete(needEnter)
    self.nextState = self:getNextState()
    if needEnter then
    	self.context:onEnter()
    end
end

function BuffBoomCastingState:getNextState()
    return self.context.dripCastingStateInLast_B
end

function BuffBoomCastingState:onExit()
    BaseStableState.onExit(self)
end


-------------------------------------------------
BuffBoomCastingStateInSwapFirst = class(BuffBoomCastingState)

function BuffBoomCastingStateInSwapFirst:create(context)
	local v = BuffBoomCastingStateInSwapFirst.new()
	v.context = context
	v.mainLogic = context.mainLogic
	v.boardView = v.mainLogic.boardView
	return v
end

function BuffBoomCastingStateInSwapFirst:getNextState()
    -- return self.context.dripCastingStateInSwap
    return self.context.firecrackerBlastState
end

function BuffBoomCastingStateInSwapFirst:getClassName()
	return "BuffBoomCastingStateInSwapFirst"
end

-------------------------------------------------

BuffBoomCastingStateInLoop = class(BuffBoomCastingState)

function BuffBoomCastingStateInLoop:create(context)
	local v = BuffBoomCastingStateInLoop.new()
	v.context = context
	v.mainLogic = context.mainLogic
	v.boardView = v.mainLogic.boardView
	return v
end

function BuffBoomCastingStateInLoop:getNextState()
	-- return self.context.magicLampCastingStateInLoop
	return self.context.firecrackerBlastStateInLoop
end

function BuffBoomCastingStateInLoop:getClassName()
	return "BuffBoomCastingStateInLoop"
end