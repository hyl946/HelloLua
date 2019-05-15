TileTransferState = class(BaseStableState)

--包含原 TransmissionState & TileMoveState

function TileTransferState:create( context )
	-- body
	local v = TileTransferState.new()
	v.context = context
	v.mainLogic = context.mainLogic  --gameboardlogic
	v.boardView = v.mainLogic.boardView

	v:resetDatas()
	return v
end

function TileTransferState:dispose()
	BaseStableState.dispose(self)
end

function TileTransferState:update(dt)
	BaseStableState.update(self, dt)

	if self.hasMoveTileItemToHandle then 	--?
		for k, v in pairs(self.actionList) do
			self:runActionLogic(self.mainLogic, v, k)
			self:runActionView(self.mainLogic.boardView, v)
		end
	end
	
end

function TileTransferState:onExit()
	BaseStableState.onExit(self)
	self.nextState = nil
	self:resetDatas()
end

function TileTransferState:resetDatas()
	self.completeItem = 0
	self.totalItem = 0

	self.moveTileCount = 0
	self.actionList = {}
    self.targetPositions = {}
    self.moveTiles = {}

	self.hasTransmissionItemToHandle = false
	self.hasMoveTileItemToHandle = false
	self.proceedTransmissionEnded = false
	self.proceedMoveTileEnded = false
end

function TileTransferState:checkTransition()
	return self.nextState
end

function TileTransferState:getNextState()
	return self.context.missileFireFirstState
end

function TileTransferState:getClassName()
	return "TileTransferState"
end

function TileTransferState:onEnter()
    BaseStableState.onEnter(self)
    self.nextState = nil

	-- self.proceedTransmissionEnded = false
 --    self.proceedMoveTileEnded = false

 	self:resetDatas()

	self:TransmissionOnEnter()
    self:moveTileOnEnter()

	self:checkStateEndStatus()
end

--两边的逻辑都处理完毕了
function TileTransferState:checkStateEndStatus()
	-- printx(11, "Check end! transEnd,moveEnd:", self.proceedTransmissionEnded, self.proceedMoveTileEnded)
	if self.proceedTransmissionEnded == true and self.proceedMoveTileEnded == true then
    	self.nextState = self:getNextState()

    	if self.hasTransmissionItemToHandle or self.hasMoveTileItemToHandle then
			self.mainLogic:setNeedCheckFalling()
		end

		if self.hasMoveTileItemToHandle then
			self:updatePortals()
	    	FallingItemLogic:preUpdateHelpMap(self.mainLogic)
		end

		self.mainLogic.squidOnBoard = nil	-- 移动过后，需重新从棋盘获取一遍鱿鱼数据
	end
end

-------------------------------------------------------------------------------------------
--										Transmission
-------------------------------------------------------------------------------------------
function TileTransferState:TransmissionOnEnter()
	if(not self.mainLogic._fieldLogicPossibility[_FIELD_LOGIC_ID.transmission]) then
        self:handleTransmissionComplete()
        return 0
    end

    local function transmissionCallback( ... )
		self:handleTransmissionComplete()
	end

	self.totalItem = GameExtandPlayLogic:checkTransmission(self.mainLogic, transmissionCallback)
	if self.totalItem == 0 then
		self:handleTransmissionComplete()
	else
		self.hasTransmissionItemToHandle = true
	end
end

function TileTransferState:handleTransmissionComplete( ... )
	self.completeItem = self.completeItem + 1

	if self.completeItem >= self.totalItem then
		self.proceedTransmissionEnded = true
		self:checkStateEndStatus()
	end
end

-------------------------------------------------------------------------------------------
--										Move Tile
-------------------------------------------------------------------------------------------
function TileTransferState:moveTileOnEnter()
	if(not self.mainLogic._fieldLogicPossibility[_FIELD_LOGIC_ID.moveTile]) then
        self.proceedMoveTileEnded = true
        return
    end
    
    local boardmap = self.mainLogic.boardmap or {}
    local gameItemMap = self.mainLogic.gameItemMap or {}
  	for r = 1, #boardmap do 
    	for c = 1, #boardmap[r] do 
    		local board = boardmap[r][c]
    		local item = gameItemMap[r][c]
            if board and board.isMoveTile then
            	if board:checkTileCanMove() and not item:hasBlocker206() and not item:hasSquidLock() then
            		board:resetMoveTileData()

            		local routeMeta = board.tileMoveMeta:findRouteByPos(r, c, board.tileMoveReverse)
            		if not routeMeta then
            			self.proceedMoveTileEnded = true
            			return 
            		end

            		local canTurn = true -- 是否可以拐弯
            		local movePointList = {}
            		table.insert(movePointList, IntCoord:create(r, c))
            		local tr, tc, leftStep = routeMeta:moveWithStep(r, c, board.tileMoveMeta.step, board.tileMoveReverse)
            		table.insert(movePointList, IntCoord:create(tr, tc))
            		while leftStep > 0 do
            			local nextRouteMeta = nil
            			if board.tileMoveReverse then nextRouteMeta = routeMeta.pre else nextRouteMeta = routeMeta.next end
            			if nextRouteMeta and (canTurn or nextRouteMeta:getDirection() == routeMeta:getDirection()) then
            				tr, tc, leftStep = nextRouteMeta:moveWithStep(tr, tc, leftStep, board.tileMoveReverse)
            				table.insert(movePointList, IntCoord:create(tr, tc))
            				routeMeta = nextRouteMeta
            			else
            				break
            			end
            		end
            		if routeMeta:isFinalPos(tr, tc, board.tileMoveReverse) then
            			board.tileMoveReverse = not board.tileMoveReverse
            		end

            		self.targetPositions[tr.."_"..tc] = true
            		self.moveTiles[r.."_"..c] = {tr, tc}

            		self.moveTileCount = self.moveTileCount + 1
        			self.hasMoveTileItemToHandle = true

        			local action = GameBoardActionDataSet:createAs(
						GameActionTargetType.kGameBoardAction,
						GameBoardActionType.kTileMove,
						IntCoord:create(r, c),
						IntCoord:create(tr, tc),
						GamePlayConfig_MaxAction_time)

        			local function movetTileCompleteCallback()
        				self:handleMoveTileComplete()
        			end
        			action.completeCallback = movetTileCompleteCallback
        			action.itemData = self.mainLogic.gameItemMap[r][c]:copy()
        			action.boardData = board:copy()
        			action.movePointList = movePointList

        			self.actionList[#self.actionList + 1] = action
            	end
            end
    	end
    end
    if self.moveTileCount <= 0 then
    	self.proceedMoveTileEnded = true
	end
end

function TileTransferState:handleMoveTileComplete( ... )
	self.moveTileCount = self.moveTileCount - 1

	if self.moveTileCount <= 0 then
    	self.proceedMoveTileEnded = true
    	self:checkStateEndStatus()
	end
end

function TileTransferState:runActionLogic(mainLogic, theAction, actid)
	if theAction.addInfo == "over" or theAction.actionStatus == GameActionStatus.kWaitingForDeath then
		self.actionList[actid] = nil
		if theAction.completeCallback then theAction.completeCallback() end
	else
		if theAction.actionStatus == GameActionStatus.kRunning then 		---running阶段，自动扣时间，到时间了，进入Death阶段
			if theAction.actionDuring < 0 then 
				theAction.actionStatus = GameActionStatus.kWaitingForDeath
			else
				theAction.actionDuring = theAction.actionDuring - 1
			end
		elseif theAction.actionStatus == GameActionStatus.kWaitingForStart then
			local fr, fc = theAction.ItemPos1.x, theAction.ItemPos1.y
			local tr, tc = theAction.ItemPos2.x, theAction.ItemPos2.y

			local fromBoardData = theAction.boardData
			local fromItemData = theAction.itemData
			self.mainLogic.boardmap[tr][tc]:copyDatasFrom(fromBoardData)
			self.mainLogic.gameItemMap[tr][tc]:copyDatasFrom(fromItemData)

			if not self.targetPositions[fr.."_"..fc] then
				self.mainLogic.boardmap[fr][fc]:resetDatas()
				self.mainLogic.gameItemMap[fr][fc]:resetDatas()
			end

			if not fromItemData.isBlock and not fromBoardData.isBlock then
				self.mainLogic:setTileMoved()
			end
			self.mainLogic:addNeedCheckMatchPoint(tr, tc)
		end
	end
end

function TileTransferState:runActionView(boardView, theAction)
	if theAction.actionStatus == GameActionStatus.kWaitingForStart then
		theAction.actionStatus = GameActionStatus.kRunning

		local fr, fc = theAction.ItemPos1.x, theAction.ItemPos1.y
		local tr, tc = theAction.ItemPos2.x, theAction.ItemPos2.y

		local prePoints = nil
		local totalMoveSteps = 0
		for _, v in ipairs(theAction.movePointList) do
			if prePoints then
				totalMoveSteps = totalMoveSteps + math.abs(v.x - prePoints.x) + math.abs(v.y - prePoints.y)
			end
			prePoints = v
		end	
		if totalMoveSteps < 1 then return end

		local datas = {}
		ItemView.copyDatasFrom(datas, boardView.baseMap[fr][fc])

		local fromItem = boardView.baseMap[fr][fc]
		local toItem = boardView.baseMap[tr][tc]
		local moveDataList = {}
		local timePerStep = 0.8 / totalMoveSteps
		prePoints = nil
		for _, v in ipairs(theAction.movePointList) do
			if prePoints then
				local moveStep = math.abs(v.x - prePoints.x) + math.abs(v.y - prePoints.y)	
				table.insert(moveDataList, {time = timePerStep * moveStep, pos = fromItem:getBasePosition(v.y, v.x)})
			else
				table.insert(moveDataList, {time = 0, pos = fromItem:getBasePosition(v.y, v.x)})
			end
			prePoints = v
		end	

		local function onMoveFinishCallback()			
			toItem:removeBoardViewTranscontainer()
    		toItem:upDatePosBoardDataPos(self.mainLogic.gameItemMap[tr][tc], true)
			toItem.isNeedUpdate = true

			theAction.addInfo = "over"
		end
		toItem:playTileMoveAnimation(fromItem:getBoardViewTransContainer(), moveDataList, onMoveFinishCallback)
		fromItem:removeBoardViewTranscontainer()
	end
end

function TileTransferState:updatePortals()
	local updateEnterPortals = {}
	local updateExitPortals = {}
	for fromPos, toPos in pairs(self.moveTiles) do
		local tr = toPos[1]
		local tc = toPos[2]
		local newBoard = self.mainLogic.boardmap[tr][tc]
		if newBoard:hasEnterPortal() then
			local exitPointX, exitPointY = newBoard.passExitPoint_x, newBoard.passExitPoint_y
			local newPoint = self.moveTiles[exitPointX.."_"..exitPointY] 
			if newPoint then
				exitPointX, exitPointY = newPoint[1], newPoint[2]
			end
			table.insert(updateExitPortals, {posX=exitPointX, posY=exitPointY, enterPosX=tr, enterPosY=tc})
		end
		if newBoard:hasExitPortal() then
			local enterPointX, enterPointY = newBoard.passEnterPoint_x, newBoard.passEnterPoint_y
			local newPoint = self.moveTiles[enterPointX.."_"..enterPointY]
			if newPoint then
				enterPointX, enterPointY = newPoint[1], newPoint[2]
			end
			table.insert(updateEnterPortals, {posX=enterPointX, posY=enterPointY, exitPosX=tr, exitPosY=tc})
		end
	end
	for _, v in pairs(updateEnterPortals) do
		local enterPortalBoard = self.mainLogic.boardmap[v.posX][v.posY]
		enterPortalBoard.passExitPoint_x = v.exitPosX
		enterPortalBoard.passExitPoint_y = v.exitPosY
	end
	for _, v in pairs(updateExitPortals) do
		local exitPortalBoard = self.mainLogic.boardmap[v.posX][v.posY]
		exitPortalBoard.passEnterPoint_x = v.enterPosX
		exitPortalBoard.passEnterPoint_y = v.enterPosY
	end
end
