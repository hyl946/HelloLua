GenerateBlockerCoverState = class(BaseStableState)

function GenerateBlockerCoverState:create(context)
    local v = GenerateBlockerCoverState.new()
    v.context = context
    v.mainLogic = context.mainLogic
    v.boardView = v.mainLogic.boardView
    return v
end

function GenerateBlockerCoverState:dispose()
    self.mainLogic = nil
    self.boardView = nil
    self.context = nil
end

function GenerateBlockerCoverState:update(dt)
    
end

function GenerateBlockerCoverState:onEnter()
    BaseStableState.onEnter(self)
    self.nextState = nil
    self.hasItemToHandle = false

    if(not self.mainLogic._fieldLogicPossibility[_FIELD_LOGIC_ID.blockerCover]) then
        printx(0, '!skip')
        self:onActionComplete()
        return
    end

    
    self:tryGenerateBlockerCover()
    --self.nextState = self:getNextState()
end

function GenerateBlockerCoverState:tryGenerateBlockerCover()
    local mainLogic = self.mainLogic
    local gameItemMap = mainLogic.gameItemMap
    local boardmap = mainLogic.boardmap

    local function findBlockerCoverMaterial()
		for r = 1, #mainLogic.gameItemMap do
			for c = 1, #mainLogic.gameItemMap[r] do
				local board1 = mainLogic.boardmap[r][c]
				if board1.isUsed == true and board1.blockerCoverMaterialLevel == -1 then
					return board1
				end
			end
		end
		return nil
	end

    -- bonus time
    if mainLogic.isBonusTime then
    	--printx( 1 , "    GenerateBlockerCoverState   ---------------------------  return 1")
        self:onActionComplete()
        return
    end

    local blockerCoverMaterial = findBlockerCoverMaterial()

    if not blockerCoverMaterial then
    	self:onActionComplete()
        return
    end

    local function isAvailableGrid(item , board)

		--beEffectByMimosa
		if board and board.isUsed then

			if not board.isReverseSide and not board:hasSuperCuteBall() then

				if item and (item:isAvailable() or item:isFreeGhost()) then

					if item.isEmpty then
						return true
					else
						if item.ItemType ~= GameItemType.kBigMonsterFrosting and item.bigMonsterFrostingType == 0 then
							return true
						end
					end
				end
			end
		end
		
		return false
	end


    local allFlagBoards = {}
    local flagBoards = {}
    local otherBoards = {}
    local item = nil
    local board = nil

    for i = 1 , 6 do
    	flagBoards[i] = {}
    end

    for r = 1, #boardmap do
        for c = 1, #boardmap[r] do

            board = boardmap[r][c]
            item = nil
            if gameItemMap[board.y] then
            	item = gameItemMap[board.y][board.x]
            end

            if isAvailableGrid( item , board ) then

            	if board and board.blockerCoverFlag > 0 then

	            	table.insert( allFlagBoards , board)

	            	if not flagBoards[board.blockerCoverFlag] then
	            		flagBoards[board.blockerCoverFlag] = {}
	            	end

	            	table.insert( flagBoards[board.blockerCoverFlag] , board )
	            	
	            else
	            	table.insert( otherBoards , board)
	            end
            end
            
        end
    end

    
    if #allFlagBoards == 0 then
    	self:onActionComplete()
        return
    end

    local tarNeedTotalNum = mainLogic.blockerCoverTarNum1 + mainLogic.blockerCoverTarNum2 + mainLogic.blockerCoverTarNum3
    if tarNeedTotalNum > #allFlagBoards then
    	--if _G.isLocalDevelopMode then printx(0, "GenerateBlockerCoverState  return 3") end
    	--self:onActionComplete()
    	--return
    end

    local function selectBoard( level )

    	local selectedList = {}
    	local tarNum = mainLogic["blockerCoverTarNum" .. tostring(level)]

    	local fixNum = 0
        local randNum = 0
        local forceRandNum = 0

        fixNum = #flagBoards[level] --无视mainLogic.blockerCoverTarNum填充满所有的fixFlag

        if tarNum - fixNum > 0 then
            if #flagBoards[level + 3] >= tarNum - fixNum then
                randNum = tarNum - fixNum
            else
                randNum = #flagBoards[level + 3]

                if #otherBoards >= tarNum - fixNum - randNum then
                    forceRandNum = tarNum - fixNum - randNum
                else
                    forceRandNum = #otherBoards
                end
            end
        end

        for k,v in ipairs(flagBoards[level]) do
            table.insert( selectedList , { r = v.y , c = v.x } )
        end

        if randNum > 0 then
            for i = 1 , randNum do
                local randIndex = mainLogic.randFactory:rand( 1 , #flagBoards[level + 3] )
                board = flagBoards[level + 3][randIndex]
                table.insert( selectedList , { r = board.y , c = board.x } )
                table.remove( flagBoards[level + 3] , randIndex )
            end
        end

        if forceRandNum > 0 then
            for i = 1 , forceRandNum do
                local randIndex = mainLogic.randFactory:rand( 1 , #otherBoards )
                board = otherBoards[randIndex]
                table.insert( selectedList , { r = board.y , c = board.x } )
                table.remove( otherBoards , randIndex )
            end
        end
        --mainLogic.randFactory:rand(1 , #canCreateList)

	    return selectedList

    end

    local list_1 = selectBoard( 1 )
    local list_2 = selectBoard( 2 )
    local list_3 = selectBoard( 3 )

    local function actionCallback ()
        self:onActionComplete(true)
    end

    local generateBlockerCoverAction = GameBoardActionDataSet:createAs(
                        GameActionTargetType.kGameItemAction,
                        GameItemActionType.kItem_Generate_Blocker_Cover,
                        IntCoord:create(blockerCoverMaterial.y, blockerCoverMaterial.x),
                        nil,
                        GamePlayConfig_MaxAction_time
                    )
    generateBlockerCoverAction.completeCallback = actionCallback
    generateBlockerCoverAction.list_1 = list_1
    generateBlockerCoverAction.list_2 = list_2
    generateBlockerCoverAction.list_3 = list_3

    --printx( 1 , "  GenerateBlockerCoverState  11111111111111111111111111111111111111111111111111111111 ")
    --printx( 1 , "  ++++++++++++++++++++++++++++++++  list_1 = " , table.tostring(list_1)  )
    --printx( 1 , "  ++++++++++++++++++++++++++++++++  list_2 = " , table.tostring(list_2)  )
    --printx( 1 , "  ++++++++++++++++++++++++++++++++  list_3 = " , table.tostring(list_3)  )
    self.mainLogic:addGameAction(generateBlockerCoverAction)
end

function GenerateBlockerCoverState:getClassName()
    return "GenerateBlockerCoverState"
end

function GenerateBlockerCoverState:checkTransition()
    return self.nextState
end

function GenerateBlockerCoverState:onActionComplete(needEnter)
    self.nextState = self:getNextState()
    if needEnter then
    	self.context:onEnter()
    end
end

function GenerateBlockerCoverState:getNextState()
    return self.context.sandTransferState
end

function GenerateBlockerCoverState:onExit()
    BaseStableState.onExit(self)
end


-------------------------------------------------

GenerateBlockerCoverStateInSwapFirst = class(GenerateBlockerCoverState)

function GenerateBlockerCoverStateInSwapFirst:create(context)
	local v = GenerateBlockerCoverStateInSwapFirst.new()
	v.context = context
	v.mainLogic = context.mainLogic
	v.boardView = v.mainLogic.boardView
	return v
end

function GenerateBlockerCoverStateInSwapFirst:getNextState()
    return self.context.superCuteBallState
end

function GenerateBlockerCoverStateInSwapFirst:getClassName()
	return "GenerateBlockerCoverStateInSwapFirst"
end

-------------------------------------------------

GenerateBlockerCoverStateInLoop = class(GenerateBlockerCoverState)

function GenerateBlockerCoverStateInLoop:create(context)
	local v = GenerateBlockerCoverStateInLoop.new()
	v.context = context
	v.mainLogic = context.mainLogic
	v.boardView = v.mainLogic.boardView
	return v
end

function GenerateBlockerCoverStateInLoop:getNextState()
    return self.context.tileBlockerStateInLoop
end

function GenerateBlockerCoverStateInLoop:getClassName()
	return "GenerateBlockerCoverStateInLoop"
end