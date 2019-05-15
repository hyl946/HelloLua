TurretLogic = class{}

--turretIsTypeRandom 已废弃 炮塔都有弹片了

function TurretLogic:parseConfig(tileDef)
	if tileDef.tileProperties[TileConst.kTurret] then
		-- printx(11, "! ! ! Turret config:", table.tostringByKeyOrder(tileDef))

		local direction = 1
		local isRandomTurret = false

		local turretAttr = tileDef:getAttrOfProperty(TileConst.kTurret)
		if turretAttr and #turretAttr > 0 then
			local subtypes = string.split(turretAttr, '-')
			if subtypes and #subtypes == 2 then
				local randomFlag = subtypes[1]
--				if randomFlag == "2" then isRandomTurret = true end
				direction = subtypes[2]
			end
		end
		
		return true, direction, isRandomTurret
	end
	return false, nil, false
end

--更新炮弹等级  消除碰到后升级
function TurretLogic:updateTurretLevel(mainLogic, r, c, hitBySpecial)
	local maxLevel = 2		--击中2次后触发
	local maxLevelReached = false

	local item = mainLogic.gameItemMap[r][c]

	if item and item:isVisibleAndFree() and not item.turretLocked then

        local upgradeAction = GameBoardActionDataSet:createAs(
								 		GameActionTargetType.kGameItemAction,
								 		GameItemActionType.kItem_Turret_upgrade,
								 		IntCoord:create(r, c),
								 		nil,
								 		GamePlayConfig_MaxAction_time)
		-- printx(11, "updateTurretLevel:".."("..r..","..c..")")
        upgradeAction.hitBySpecial = hitBySpecial
		mainLogic:addDestroyAction(upgradeAction)
	end
end


--更新炮弹等级  消除碰到后升级
function TurretLogic:updateTurretLevel2(mainLogic, r, c, hitBySpecial)
	local maxLevel = 2		--击中2次后触发
	local maxLevelReached = false

	local item = mainLogic.gameItemMap[r][c]

	if item and item:isVisibleAndFree() and not item.turretLocked then

        if item.turretLevel == 0 then

            local bCanLevelUp = false
            if item.upgradeAction then
                if item.upgradeAction.CanAttackStartTime < 4 then
                    bCanLevelUp = true
                end 
            else
                bCanLevelUp = true
            end

            if bCanLevelUp then
                if hitBySpecial then
			        item.turretIsSuper = true
		        end
            end
        end

        if item.runAction == nil then
            item.runAction = false
        end

        if item.runAction == false then
            self:TurretRunAction( mainLogic, r, c)
        else
            if item.upgradeAction.CanAttackStartTime > 4 then
                if item.upgradeAction.turretItemOldLevel == 0 then
                    item.upgradeAction.turretItemOldLevel = 1
                end
            end
        end 
		
	end
end

--播放action
function TurretLogic:TurretRunAction(mainLogic, r, c)
	local maxLevel = 2		--击中2次后触发
	local maxLevelReached = false

    

	local item = mainLogic.gameItemMap[r][c]

    local fireTargetCoord = 0
    local PiecPosList = 0
    fireTargetCoord, PiecPosList = self:getTurretFireCenterCoord( mainLogic, item ) 

	if item and item:isVisibleAndFree() and not item.turretLocked then

        if item.turretLevel == 1 then
            if fireTargetCoord then
		        item.turretLevel = maxLevel
            else
                --没有目标到不会让他到满级了
                return
            end
        end

        item.runAction = true
		if item.turretLevel == maxLevel then
			maxLevelReached = true
			item.turretLocked = true
		end

		local upgradeAction = GameBoardActionDataSet:createAs(
								 		GameActionTargetType.kGameItemAction,
								 		GameItemActionType.kItem_Turret_upgrade,
								 		IntCoord:create(r, c),
								 		nil,
								 		GamePlayConfig_MaxAction_time)
		-- printx(11, "updateTurretLevel:".."("..r..","..c..")")
		upgradeAction.turretPos = ccp(r,c)
        upgradeAction.CanAttackStartTime = 0
		upgradeAction.maxLevelReached = maxLevelReached
		-- upgradeAction.completeCallback = actionCallback
		-- mainLogic:addGameAction(upgradeAction)
		mainLogic:addDestroyAction(upgradeAction)
        item.upgradeAction = upgradeAction

		-- printx(11, "= = = TurretLogic:updateTurretLevel = = = item.turretLevel, maxLevelReached:", item.turretLevel, maxLevelReached)
	end
end

function TurretLogic:clacRealUsedMap(boardMap)
	local startRow, startCol = 9, 9
	local endRow, endCol = 1, 1
	for i = 1, #boardMap do
		for j = 1, #boardMap[i] do
			local board = boardMap[i][j]
			if board.isUsed then
				if j > endCol then endCol = j end
				if j < startCol then startCol = j end
				if i > endRow then endRow = i end
				if i < startRow then startRow = i end

				if board.isMoveTile and board.tileMoveMeta then
					for _, meta in pairs(board.tileMoveMeta.routes) do
						local r = meta.endPos.x
						local c = meta.endPos.y
						if c > endCol then endCol = c end
						if c < startCol then startCol = c end
						if r > endRow then endRow = r end
						if r < startRow then startRow = r end
					end
				end
			end
		end
	end
	return startRow, startCol, endRow, endCol
end

-- 炮塔击发的目标弹着点 只有中心目标
function TurretLogic:getTurretFireCenterPos(mainLogic, turret)
    local radius = 4  	--击发半径

	local col, row = turret.x, turret.y
	local direction = tonumber(turret.turretDir)
	--- 上右下左
	local aroundX = {0, 1, 0, -1}
	local aroundY = {-1, 0, 1, 0}

	local targetCol, targetRow = col + aroundX[direction] * radius, row + aroundY[direction] * radius

    --获取棋盘的左上角点 右下角点
    local startRow, startCol, endRow, endCol = self:clacRealUsedMap(mainLogic.boardmap)

    local bInMap = true
    if targetCol < startCol or  targetRow < startRow or targetCol > endCol or  targetRow > endRow then
        bInMap = false
    end


	if mainLogic:isPosValid(targetRow, targetCol) and bInMap then
        local fireTargetCoord = IntCoord:create(targetCol, targetRow)
        return fireTargetCoord
    end

    return nil
end

-- 炮塔击发的目标弹着点 有碎片位置 
function TurretLogic:getTurretFireCenterCoord(mainLogic, turret)
	local radius = 4  	--击发半径

	local col, row = turret.x, turret.y
	local direction = tonumber(turret.turretDir)
	--- 上右下左
	local aroundX = {0, 1, 0, -1}
	local aroundY = {-1, 0, 1, 0}

	local targetCol, targetRow = col + aroundX[direction] * radius, row + aroundY[direction] * radius

    --获取棋盘的左上角点 右下角点
    local startRow, startCol, endRow, endCol = self:clacRealUsedMap(mainLogic.boardmap)

    local bInMap = true
    if targetCol < startCol or  targetRow < startRow or targetCol > endCol or  targetRow > endRow then
        bInMap = false
    end


	if mainLogic:isPosValid(targetRow, targetCol) and bInMap then

        local fireTargetCoord = IntCoord:create(targetCol, targetRow)
        local PiecPosList = self:getPiecePosList(mainLogic, turret,fireTargetCoord )
		return fireTargetCoord, PiecPosList
	end

	return nil, nil
end

-- 打击中心目标
function TurretLogic:onHitTargets(mainLogic, turret, centerCoord)

	-- printx(11, "TurretLogic:onHitTargets:", table.tostringByKeyOrder(centerCoord))

	if not centerCoord then
		return
	end

	--攻击一个格子
	if turret.turretIsSuper then
		--打小十字
		local crossAction = GameBoardActionDataSet:createAs(
									GameActionTargetType.kGameItemAction,
									GameItemActionType.kItemSpecial_diagonalSquare,
									centerCoord,
									centerCoord,
									GamePlayConfig_MaxAction_time)
		crossAction.radius = 1
		crossAction.addInt2 = 1
		crossAction.eliminateChainIncludeHem = true
		crossAction.footprintType = ObstacleFootprintType.k_Turret
		mainLogic:addDestructionPlanAction(crossAction)
	else
		--打一个点
		local rectangleAction = GameBoardActionDataSet:createAs(
									GameActionTargetType.kGameItemAction,
									GameItemActionType.kItemSpecial_rectangle,
									centerCoord,
									centerCoord,
									GamePlayConfig_MaxAction_time)
		rectangleAction.addInt2 = 1
		rectangleAction.eliminateChainIncludeHem = true
		rectangleAction.footprintType = ObstacleFootprintType.k_Turret
		mainLogic:addDestructionPlanAction(rectangleAction)
	end
end

-- 碎片打击目标
function TurretLogic:onHitPieceTargets(mainLogic, turret, centerCoord, PiectPos)

	-- printx(11, "TurretLogic:onHitTargets:", table.tostringByKeyOrder(centerCoord))

	if not centerCoord then
		return
	end

    local targetCoord = PiectPos

	if turret.turretIsSuper then
		--特殊炮弹矩形
		--播放弹片动画
--		for _, targetCoord in ipairs(targetCoords) do

			--打小十字
			local crossAction = GameBoardActionDataSet:createAs(
										GameActionTargetType.kGameItemAction,
										GameItemActionType.kItemSpecial_diagonalSquare,
										targetCoord,
										targetCoord,
										GamePlayConfig_MaxAction_time)
			crossAction.radius = 1
			crossAction.addInt2 = 1
			crossAction.eliminateChainIncludeHem = true
			crossAction.footprintType = ObstacleFootprintType.k_Turret
			mainLogic:addDestructionPlanAction(crossAction)
--		end
	else
		--普通炮弹单点
		--播放弹片动画
--		for _, targetCoord in ipairs(targetCoords) do
			--打一个点
			local rectangleAction = GameBoardActionDataSet:createAs(
										GameActionTargetType.kGameItemAction,
										GameItemActionType.kItemSpecial_rectangle,
										targetCoord,
										targetCoord,
										GamePlayConfig_MaxAction_time)
			rectangleAction.addInt2 = 1
			rectangleAction.eliminateChainIncludeHem = true
			rectangleAction.footprintType = ObstacleFootprintType.k_Turret
			mainLogic:addDestructionPlanAction(rectangleAction)
--		end
	end
end

function TurretLogic:getPiecePosList(mainLogic, turret, centerCoord)
    local randomPickAmount = 4	--弹片弹出数量
	local targetCoords = {}

	--找出弹片位置
	local candidateCoords = {}
    local candidateCoords_Loser = {}
	if turret.turretIsSuper then
		candidateCoords,candidateCoords_Loser = TurretLogic:_pickCandidateCoordsForSuperTurret(mainLogic, centerCoord)
	else
		candidateCoords,candidateCoords_Loser = TurretLogic:_pickCandidateCoordsForCommonTurret(mainLogic, centerCoord)
	end

    --高优先级是否可用
	local availableCoords = {}
	for _, pos in ipairs(candidateCoords) do
		if TurretLogic:_isPickableTargetGrid(mainLogic, pos.y, pos.x) then
			table.insert(availableCoords, pos)
		end
	end

    --低优先级是否可用
    local availableCoords_Loser = {}
	for _, pos in ipairs(candidateCoords_Loser) do
		if TurretLogic:_isPickableTargetGrid(mainLogic, pos.y, pos.x) then
			table.insert(availableCoords_Loser, pos)
		end
	end

    --优先级填入
	for k = 1, randomPickAmount do 
		if #availableCoords > 0 then
			coord = table.remove(availableCoords, mainLogic.randFactory:rand(1, #availableCoords))
			table.insert(targetCoords, coord)
		end
	end

    --如果正常碎片位置未满 填入低优先级道具
    if #targetCoords < randomPickAmount then
        for k = #targetCoords+1, randomPickAmount do 
		    if #availableCoords_Loser > 0 then
			    coord = table.remove(availableCoords_Loser, mainLogic.randFactory:rand(1, #availableCoords_Loser))
			    table.insert(targetCoords, coord)
		    end
	    end
    end


    return targetCoords
end

--获取普通碎片的位置列表
function TurretLogic:_pickCandidateCoordsForCommonTurret(mainLogic, centerCoord)
	--候选区域：半径为2的菱形区域
	local blowRadius = 2
	local function getAllPosList(radius, centreR, centreC)
		local result = {}
        local LosetList = {}
		for i = -radius, radius do
			local targetRow = centreR + i
			local colWidthShift = radius - math.abs(i)

			for j = (centreC - colWidthShift), (centreC + colWidthShift) do
				if j ~= centreC or targetRow ~= centreR then
					

                    local bIsLoset = self:_isPosLoser( mainLogic, targetRow, j ) 

                    if bIsLoset then
                        table.insert(LosetList, IntCoord:create(j, targetRow))
                    else
					    table.insert(result, IntCoord:create(j, targetRow))
                    end
				end
			end
		end
		return result,LosetList
	end

	local allPosList,LosetList = getAllPosList(blowRadius, centerCoord.y, centerCoord.x)
	return allPosList,LosetList
end

--获取特效碎片的位置列表
function TurretLogic:_pickCandidateCoordsForSuperTurret(mainLogic, centerCoord)
	--候选区域：中心点外围一圈
	local function getAllPosList(centreR, centreC)
		local result = {}
        local LosetList = {}
		for row = centreR - 1, centreR + 1 do
			for col = centreC - 1, centreC + 1 do
				if col ~= centreC or row ~= centreR then

                    local bIsLoset = self:_isPosLoser( mainLogic, row, col ) 

                    if bIsLoset then
                        table.insert(LosetList, IntCoord:create(col, row))
                    else
					    table.insert(result, IntCoord:create(col, row))
                    end
				end
			end
		end
		return result,LosetList
	end

	local allPosList,LosetList = getAllPosList(centerCoord.y, centerCoord.x)
	return allPosList,LosetList
end

--这个格子是否低优先级
function TurretLogic:_isPosLoser(mainLogic, r, c)
	if mainLogic:isPosValid(r, c) then
		local targetItem = mainLogic.gameItemMap[r][c]
		local targetBoard = mainLogic.boardmap[r][c]

		if targetBoard.isUsed then
            if targetItem.ItemType == GameItemType.kNone
                or targetItem.ItemType == GameItemType.kChameleon --染色蛋
                or targetItem.ItemType == GameItemType.kBlocker195 --星星瓶
                or targetItem.ItemType == GameItemType.kPacman --蓄电精灵
                or targetItem.ItemType == GameItemType.kTotems --闪电鸟
                or targetItem.ItemType == GameItemType.kSnail --蜗牛
                or targetItem.ItemType == GameItemType.kBigMonsterFrosting --雪怪已经被消除了的角落 这里判断好像有问题。等待更改
                or targetItem.ItemType == GameItemType.kIngredient --豆荚
            then
                return true
            end
		else
			return true
		end
	end

	return false
end

--这个格子 是否可以飞弹片
function TurretLogic:_isPickableTargetGrid(mainLogic, r, c)
	if mainLogic:isPosValid(r, c) then
		local targetItem = mainLogic.gameItemMap[r][c]
		local targetBoard = mainLogic.boardmap[r][c]

		if targetBoard.isUsed then
			if targetItem.isReverseSide --翻转
				or targetItem:hasBlocker206() --是否锁了
				or targetItem.ItemType == GameItemType.kPacmansDen --蓄电精灵小窝
                or targetItem.ItemType == GameItemType.kPoisonBottle --章鱼
                or targetItem:hasSquidLock()
				then
				return false
			else
				return true
			end
		end
	end

	return false
end

--更新炮台锁定状态 itemView重新创建了一遍
function TurretLogic:updateTurretLockStatus(mainLogic)
	for r = 1, #mainLogic.gameItemMap do
		for c = 1, #mainLogic.gameItemMap[r] do
			local item = mainLogic.gameItemMap[r][c]
            if item.ItemType == GameItemType.kTurret then
            	item.turretLocked = false
                item.updateType = 0
				local turretView = mainLogic.boardView.baseMap[item.y][item.x]
				if turretView then
					turretView:setTurretViewBackToActive()
				end
            end
		end
	end
end
