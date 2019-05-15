LotusUpdateState = class(BaseStableState)

function LotusUpdateState:create(context)
    local v = LotusUpdateState.new()
    v.context = context
    v.mainLogic = context.mainLogic
    v.boardView = v.mainLogic.boardView
    return v
end

function LotusUpdateState:dispose()
    self.mainLogic = nil
    self.boardView = nil
    self.context = nil
end

function LotusUpdateState:update(dt)
    
end

function LotusUpdateState:onEnter()
    BaseStableState.onEnter(self)
    self.nextState = nil
    self.hasItemToHandle = false

    if(not self.mainLogic._fieldLogicPossibility[_FIELD_LOGIC_ID.lotus]) then
        printx(0, '!skip')
		self:updateLotusNum()
        self:onActionComplete()
        return
    end

    self:tryLotusUpdate()
    --self.nextState = self:getNextState()
end

function LotusUpdateState:doLotusChangeLevel()

end

function LotusUpdateState:doCreateNewLotus()

end

function LotusUpdateState:updateLotusNum()
    local mainLogic = self.mainLogic

    local function checkAllLotusCount()
		local countsum = 0
		for r = 1, #mainLogic.gameItemMap do
			for c = 1, #mainLogic.gameItemMap[r] do
				local board1 = mainLogic.boardmap[r][c]
				if board1.isUsed == true and board1.lotusLevel > 0 then
					countsum = countsum + 1
				end
			end
		end
		return countsum;
	end

	if mainLogic.gameMode and mainLogic.gameMode.checkAllLotusCount and type(mainLogic.gameMode.checkAllLotusCount) == "function" then
		mainLogic.currLotusNum = mainLogic.gameMode:checkAllLotusCount()
	else
		mainLogic.currLotusNum = checkAllLotusCount()
	end
end

function LotusUpdateState:tryLotusUpdate()
    local mainLogic = self.mainLogic
    local gameItemMap = mainLogic.gameItemMap
    local boardmap = mainLogic.boardmap

	self:updateLotusNum()

    

    -- bonus time
    if mainLogic.isBonusTime then
    	-- printx( 1 , "    LotusUpdateState   ---------------------------  return 1")
        self:onActionComplete()
        return
    end

    local lotusBoards = {}
    local lotusBoards_level_1 = {}
    local lotusBoards_level_2 = {}
    local lotusBoards_level_3 = {}
    local lotusItems = {}
    local board = nil
    local item = nil

    for r = 1, #boardmap do
        for c = 1, #boardmap[r] do
            board = boardmap[r][c]
            item = gameItemMap[r][c]
            if board and board.lotusLevel > 0 and (not ((item and item:hasBlocker206()) or (item and item:hasSquidLock())) ) then--锁链能锁住荷叶
            	table.insert( lotusBoards , board)
            	--lotusBoards[tostring(r) .. "_" .. tostring(c)] = board
            	if board.lotusLevel == 1 then
            		table.insert( lotusBoards_level_1 , board)
            		--lotusBoards_level_1[tostring(r) .. "_" .. tostring(c)] = board
            	elseif board.lotusLevel == 2 then
            		table.insert( lotusBoards_level_2 , board)
            		--lotusBoards_level_2[tostring(r) .. "_" .. tostring(c)] = board
            	elseif board.lotusLevel == 3 then
            		table.insert( lotusBoards_level_3 , board)
            		--lotusBoards_level_3[tostring(r) .. "_" .. tostring(c)] = board
            	end
--            	lotusItems[tostring(r) .. "_" .. tostring(c)] = gameItemMap[r][c]
            end
        end
    end

    local function actionCallback ()
        self:onActionComplete(true)
    end

    if #lotusBoards == 0 or mainLogic.lotusEliminationNum ~= mainLogic.lotusPrevStepEliminationNum then
    	-- printx( 1 , "    LotusUpdateState   ---------------------------  return 2    " , 
    	-- 	#lotusBoards , mainLogic.lotusEliminationNum , mainLogic.lotusPrevStepEliminationNum)
    	mainLogic.lotusPrevStepEliminationNum = mainLogic.lotusEliminationNum
        self:onActionComplete()
        return
    end

    local rate_1 = 0
    local rate_2 = 0
    local rate_3 = 0

    if #lotusBoards_level_1 <= 3 then
    	rate_1 = 0.9
    	rate_2 = 0.05
    	rate_3 = 0.05
    else
    	if #lotusBoards_level_2 <= 3 then
    		rate_1 = 0.1
    		rate_2 = 0.8
    		rate_3 = 0.1
    	else
    		if #lotusBoards_level_3 <= 3 then
    			rate_1 = 0.2
    			rate_2 = 0.2
    			rate_3 = 0.6
    		else
    			local rateA = #lotusBoards_level_1 / 4
    			local rateB = #lotusBoards_level_2 / 3
    			local rateC = #lotusBoards_level_3 / 2

    			rate_1 = rateA / (rateA + rateB + rateC)
    			rate_2 = rateB / (rateA + rateB + rateC)
    			rate_3 = rateC / (rateA + rateB + rateC)
    		end
    	end
    end

    if #lotusBoards_level_1 == 0 then
		rate_1 = rate_1 + rate_2
		rate_2 = 0
	end

	if #lotusBoards_level_2 == 0 then
		rate_1 = rate_1 + rate_3
		rate_3 = 0
	end

	local function isAvailableItem(item , board)

		--beEffectByMimosa
		if item 
			and item.blockerCoverLevel == 0
			and (
					not item.isBlock 
					or item.ItemType == GameItemType.kSnow 
					or item.ItemType == GameItemType.kMagicLamp 
					or item.ItemType == GameItemType.kVenom
					or item.ItemType == GameItemType.kBlocker199
					or item.beEffectByMimosa > 0 
					or item.cageLevel > 0
					or item.honeyLevel > 0
					or item.ItemType == GameItemType.kPacman
					or item.ItemType == GameItemType.kSunFlask
					or item.ItemType == GameItemType.kSunflower
				) 
			and board 
			and board.isUsed 
			and board.colorFilterBLevel == 0
			and board.lotusLevel == 0 
			and board.blockerCoverMaterialLevel ~= -1 
			and not board.isReverseSide then
			return true
		end
		return false
	end

	local level_1_canCreateList = {}
	local level_2_canCreateList = {}
	local level_3_canCreateList = {}
	local boardAround = nil

	
	for k, board in pairs(lotusBoards) do

		local board_center = boardmap[board.y][board.x]
		local item_center = gameItemMap[board.y][board.x]
		--蔓延
		if not board_center.isReverseSide 
			and board_center.blockerCoverMaterialLevel ~= -1
			and board_center.colorFilterBLevel == 0
			and item_center.blockerCoverLevel == 0
			and not item_center:hasActiveSuperCuteBall() 
			and not item_center:seizedByGhost() then
			item = nil
			if gameItemMap[board.y + 1] then
				item = gameItemMap[board.y + 1][board.x]
			end
			boardAround = nil
			if boardmap[board.y + 1] then
				boardAround = boardmap[board.y + 1][board.x]
			end
			if isAvailableItem(item , boardAround) 
				and not board_center:hasChainInDirection(ChainDirConfig.kDown) 
				and not boardAround:hasChainInDirection(ChainDirConfig.kUp) then
				level_1_canCreateList[ tostring(item.y) .. "_" .. tostring(item.x) ] = item
			end

			item = nil
			if gameItemMap[board.y - 1] then
				item = gameItemMap[board.y - 1][board.x]
			end
			boardAround = nil
			if boardmap[board.y - 1] then
				boardAround = boardmap[board.y - 1][board.x]
			end
			if isAvailableItem(item , boardAround) 
				and not board_center:hasChainInDirection(ChainDirConfig.kUp) 
				and not boardAround:hasChainInDirection(ChainDirConfig.kDown) then
				level_1_canCreateList[ tostring(item.y) .. "_" .. tostring(item.x) ] = item
			end

			item = gameItemMap[board.y][board.x + 1]
			boardAround = boardmap[board.y][board.x + 1]
			if isAvailableItem(item , boardAround) 
				and not board_center:hasChainInDirection(ChainDirConfig.kRight) 
				and not boardAround:hasChainInDirection(ChainDirConfig.kLeft) then
				level_1_canCreateList[ tostring(item.y) .. "_" .. tostring(item.x) ] = item
			end

			item = gameItemMap[board.y][board.x - 1]
			boardAround = boardmap[board.y][board.x - 1]
			if isAvailableItem(item , boardAround) 
				and not board_center:hasChainInDirection(ChainDirConfig.kLeft) 
				and not boardAround:hasChainInDirection(ChainDirConfig.kRight) then
				level_1_canCreateList[ tostring(item.y) .. "_" .. tostring(item.x) ] = item
			end
		end
	end

	for k, board in pairs(lotusBoards_level_1) do

		local board_center = boardmap[board.y][board.x]
		local item_center = gameItemMap[board.y][board.x]
		--包裹（草地只能捆住普通小动物、直线特效、爆炸特效、水晶球、倒计时炸弹、+5步动物、倒计时炸弹和大眼仔
		if item_center and 
			item_center.ItemSpecialType ~= AnimalTypeConfig.kColor and 
			item_center.ItemType ~= GameItemType.kCoin and 
			item_center.ItemType ~= GameItemType.kBlocker207 and 
			item_center.ItemType ~= GameItemType.kBlackCuteBall and
			item_center.venomLevel == 0 and
			item_center.furballLevel == 0 and
			item_center.beEffectByMimosa == 0 and
			item_center.cageLevel == 0 and
			item_center.honeyLevel == 0 and
            item_center.missileLevel <= 0 and 
            item_center.blockerCoverLevel == 0 and 
            board_center.colorFilterBLevel == 0 and 
			not item_center:hasActiveSuperCuteBall() and
			not item_center:seizedByGhost() and
			board_center.blockerCoverMaterialLevel ~= -1 and
			not board.isReverseSide and
			(
				item_center.ItemType == GameItemType.kAnimal or
				item_center.ItemType == GameItemType.kCrystal or
				item_center.ItemType == GameItemType.kAddMove or
				item_center.ItemType == GameItemType.kMagicLamp or
				item_center.ItemType == GameItemType.kNewGift or
				item_center.ItemType == GameItemType.kGift or
				item_center.ItemType == GameItemType.kAnimal or
				item_center.ItemType == GameItemType.kScoreBuffBottle or
				item_center:isBlocker199Active()
			) then
			--level_2_canCreateList[ tostring(item.y) .. "_" .. tostring(item.x) ] = item
			table.insert( level_2_canCreateList , item_center )
		end
	end

	for k, board in pairs(lotusBoards_level_2) do
		local item = gameItemMap[board.y][board.x]
		--level_3_canCreateList[ tostring(board.y) .. "_" .. tostring(board.x) ] = gameItemMap[board.y][board.x]
		--覆盖
		if not board.isReverseSide 
			and board.blockerCoverMaterialLevel ~= -1 
			and board.colorFilterBLevel == 0
			and item.blockerCoverLevel == 0
			and not item:hasActiveSuperCuteBall() 
			and not item:seizedByGhost() then
			table.insert( level_3_canCreateList , gameItemMap[board.y][board.x] )
		end
	end

	local tempList = {}
	for k, item in pairs(level_1_canCreateList) do
		table.insert( tempList , item )
	end
	level_1_canCreateList = tempList

	if #level_1_canCreateList > 0 then
		if #level_2_canCreateList == 0 then
			rate_1 = rate_1 + rate_2
			rate_2 = 0
		end

		if #level_3_canCreateList == 0 then
			rate_1 = rate_1 + rate_3
			rate_3 = 0
		end
	else
		if #level_2_canCreateList > 0 then
			rate_2 = rate_2 + rate_1
			rate_1 = 0

			if #level_3_canCreateList == 0 then
				rate_2 = rate_2 + rate_3
				rate_3 = 0
			end
		elseif #level_3_canCreateList > 0 then
			rate_1 = 0
			rate_2 = 0
			rate_3 = 1
		else
			-- printx( 1 , "    LotusUpdateState   ---------------------------  return 3")
			self:onActionComplete()
       		return
		end
	end
	-- printx( 1 , "    +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
	-- printx( 1 , "    +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
	-- printx( 1 , "    LotusUpdateState   Random result :")
	-- printx( 1 , "    rate_1 :" , rate_1)
	-- printx( 1 , "    rate_2 :" , rate_2)
	-- printx( 1 , "    rate_3 :" , rate_3)
	-- printx( 1 , "    +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
	-- printx( 1 , "    +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++")
	rate_1 = rate_1 * 1000
	rate_2 = rate_2 * 1000
	rate_3 = rate_3 * 1000
	local randomResult = self.mainLogic.randFactory:rand(1,1000)
	local randomItem = nil
	local updateType = 0

	local function randomItemByCanCreateList(canCreateList)
		return canCreateList[ self.mainLogic.randFactory:rand(1 , #canCreateList) ]
	end

	if randomResult <= rate_1 then
		randomItem = randomItemByCanCreateList(level_1_canCreateList)
		updateType = 1
	elseif randomResult > rate_1 and randomResult <= rate_1 + rate_2 then
		randomItem = randomItemByCanCreateList(level_2_canCreateList)
		updateType = 2
	else
		randomItem = randomItemByCanCreateList(level_3_canCreateList)
		updateType = 3
	end

    if randomItem then

        local lotusUpdateAction = GameBoardActionDataSet:createAs(
                        GameActionTargetType.kGameItemAction,
                        GameItemActionType.kItem_Update_Lotus,
                        IntCoord:create(randomItem.y, randomItem.x),
                        nil,
                        GamePlayConfig_MaxAction_time
                    )
        lotusUpdateAction.completeCallback = actionCallback
        lotusUpdateAction.updateType = updateType
        
        self.mainLogic:addGameAction(lotusUpdateAction)

        if updateType == 1 then
        	ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_Lotus, ObstacleFootprintAction.k_Expand, 1)
        else
        	ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_Lotus, ObstacleFootprintAction.k_Upgrade, 1)
        end
    end
end

function LotusUpdateState:getClassName()
    return "LotusUpdateState"
end

function LotusUpdateState:checkTransition()
    return self.nextState
end

function LotusUpdateState:onActionComplete(needEnter)
    self.nextState = self:getNextState()
    if needEnter then
    	self.context:onEnter()
    end
end

function LotusUpdateState:getNextState()
    return self.context.sandTransferState
end

function LotusUpdateState:onExit()
    BaseStableState.onExit(self)
end