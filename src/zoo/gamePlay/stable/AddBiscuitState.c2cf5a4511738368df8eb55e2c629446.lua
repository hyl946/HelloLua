AddBiscuitState = class(BaseStableState)


function AddBiscuitState:create( context )
    local v = AddBiscuitState.new()
    v.context = context
    v.mainLogic = context.mainLogic  --gameboardlogic
    v.boardView = v.mainLogic.boardView
    return v
end

function AddBiscuitState:update( ... )
    -- body
end

function AddBiscuitState:onEnter()
    printx( -1 , "---->>>> AddBiscuitState enter")
    if self:tryCollect() <= 0 then
    	self:handleComplete()
    end
end

function AddBiscuitState:getClassName()
    return "AddBiscuitState"
end

function AddBiscuitState:handleComplete(hadItemProcessed)
    self.nextState = self:getNextState()
    if hadItemProcessed then
    	self.mainLogic:setNeedCheckFalling()
    	self.context.needLoopCheck = true
    end
end

function AddBiscuitState:getNextState( ... )
	return self.context.generateBlockerCoverStateInLoop
end

function AddBiscuitState:onExit()
    printx( -1 , "----<<<< AddBiscuitState exit")
    self.nextState = nil
end

function AddBiscuitState:checkTransition()
    printx( -1 , "-------------------------AddBiscuitState checkTransition", 'self.nextState', self.nextState)
    return self.nextState
end


function AddBiscuitState:__tryCollect(gameItemMap , boardMap , callback)

	local count = 0
	self.noBiscuitInBoard = true
	for r = 1, 9 do
		for c = 1, 9 do
			local boardData = boardMap[r][c]
			if boardData.isUsed then
				local biscuitData = boardData.biscuitData
				if biscuitData then
					self.noBiscuitInBoard = false

					local canAddNewBiscuit = true
					local canCollectBiscuit = false

					local biscuitLevel = biscuitData.level
					for milkRow = 1, biscuitData.nRow do
						for milkCol = 1, biscuitData.nCol do
							if biscuitLevel ~= biscuitData.milks[milkRow][milkCol] then
								canAddNewBiscuit = false
							end
						end
					end
					if canAddNewBiscuit then
						if biscuitLevel == 3 then
							canAddNewBiscuit = false
							canCollectBiscuit = true
						end
					end
					if canAddNewBiscuit then
						local destruction = GameBoardActionDataSet:createAs(
							GameActionTargetType.kGameItemAction,
							GameItemActionType.kItem_AddNewBiscuit,
							IntCoord:create(r, c),
							nil, 
							GamePlayConfig_MaxAction_time)
						destruction.completeCallback = callback
						destruction.addInfo = "ready"
						destruction.addInt = biscuitLevel + 1
						destruction.addBiscuitData = biscuitData
						self.mainLogic:addGameAction(destruction)
						count = count + 1
					end

					if canCollectBiscuit then
						local targetPoint1 = IntCoord:create(c, r)
						local rectangleAction = GameBoardActionDataSet:createAs(
							GameActionTargetType.kGameItemAction,
							GameItemActionType.kItem_CollectBiscuit,
							targetPoint1,
							nil,
							GamePlayConfig_MaxAction_time)
						rectangleAction.completeCallback = callback
						rectangleAction.addInfo = 'ready'

						local itemView = self.mainLogic.boardView.baseMap[r][c]
						if itemView and itemView.itemSprite and itemView.itemSprite[ItemSpriteType.kBiscuit] then
							local pos = itemView.itemSprite[ItemSpriteType.kBiscuit]:getPosition()
							rectangleAction.pos = itemView.itemSprite[ItemSpriteType.kBiscuit]:getParent():convertToWorldSpace(ccp(pos.x, pos.y))
						end


						self.mainLogic:addGameAction(rectangleAction)
						count = count + 1
					end
				end
			end
		end
	end

-- self.mainLogic:tryDoOrderList(v.y,v.x,key1,key2,getNum, rotation)
-- ObstacleFootprintManager:addRecord(ObstacleFootprintType.k_SeaAnimal, ObstacleFootprintAction.k_List, 1, footprintSubType)
-- self.mainLogic:addScoreToTotal(v.x, v.y, addScore, nil, 2)
	return count
end

function AddBiscuitState:tryCollect()

	if self.noBiscuitInBoard then
		return 0
	end

	local count = 0
	local callbackCount = 0
	local function callback()
		callbackCount = callbackCount + 1
		if callbackCount == count then
			self:handleComplete(true)
		end
	end
 
	local gameItemMap = self.mainLogic.gameItemMap
	local boardMap = self.mainLogic.boardmap
	count = self:__tryCollect(gameItemMap , boardMap , callback)
	return count
end

