DripCastingState = class(BaseStableState)

function DripCastingState:create(context)
    local v = DripCastingState.new()
    v.context = context
    v.mainLogic = context.mainLogic
    v.boardView = v.mainLogic.boardView
    return v
end

function DripCastingState:dispose()
    self.mainLogic = nil
    self.boardView = nil
    self.context = nil
end

function DripCastingState:update(dt)
    
end

function DripCastingState:onEnter()
    BaseStableState.onEnter(self)
    self.nextState = nil
    self.hasItemToHandle = false

    if(not self.mainLogic._fieldLogicPossibility[_FIELD_LOGIC_ID[GameItemType.kDrip]]) then
        self:onActionComplete()
        return 0
    end


    local resultNum = 0

    if _G.test_DripMode == 2 then
    	resultNum = 0
    	self:onActionComplete()
    else
    	resultNum = self:tryToCasting()
    end

    return resultNum
end

function DripCastingState:isNormal(item)
    if (item.ItemType == GameItemType.kAnimal or item.ItemType == GameItemType.kAddMove or item.ItemType == GameItemType.kCrystal)
    and item.ItemSpecialType == 0 -- not special
    and item:isAvailable()
    --and not item:hasLock() 
    --and not item:hasFurball()
    and not self.selectedMap[item.y .. "_" .. item.x]
    then
        return true
    end
    
    return false
end

function DripCastingState:createSpeical(zongzi , itemList)
    
    local i
    local randList = {}
    local randListNum = releaseSpecialNum
    local function actionCallback()
        self.zongziReleasedNum = self.zongziReleasedNum + 1
        if self.zongziReleasedNum >= #self.zongziList then
            self:onActionComplete(true)
        end
    end

    if #itemList < releaseSpecialNum then
    	randListNum = #itemList
    end

    local randIndex = 1

    if randListNum > 0 then
    	for i=1,randListNum do  
    		randIndex = self.mainLogic.randFactory:rand(1, #itemList)   
    		table.insert( randList , itemList[randIndex] )
    		self.selectedMap[itemList[randIndex].r .. "_" .. itemList[randIndex].c] = true
    		table.remove( itemList , randIndex )
		end 
    end

	local action = GameBoardActionDataSet:createAs(
		GameActionTargetType.kGameItemAction,
		GameItemActionType.kItem_Gold_ZongZi_Explode,
		IntCoord:create(zongzi.y, zongzi.x),
		nil,
		GamePlayConfig_MaxAction_time
	)

	action.completeCallback = actionCallback
	action.speicalItemPos = randList
	self.mainLogic:addGameAction(action)
end

function DripCastingState:tryToCasting()

    local mainLogic = self.mainLogic
    local gameItemMap = mainLogic.gameItemMap
    local gameBoardMap = mainLogic.boardmap
   
    local dripList = {}
    local item = nil
    local board = nil

   for r = 1, #gameItemMap do 
        for c = 1, #gameItemMap[r] do
        	item = nil
            item = gameItemMap[r][c]
            if item ~= nil and item.ItemType == GameItemType.kDrip 
            	and ( item.dripState == DripState.kGrow or item.dripState == DripState.kReadyToMove ) then
            	table.insert( dripList , item )
            end
        end
	end
    
    if #dripList > 0 then

	    if _G.test_DripMode == 2 then

		    local checkHasDripAction = GameBoardActionDataSet:createAs(
		 		GameActionTargetType.kGameItemAction,
		 		GameItemActionType.kItem_Check_Has_Drip,
		 		IntCoord:create( 1 , 1 ),
		 		nil,
		 		GamePlayConfig_MaxAction_time)

			checkHasDripAction.completeCallback = function () self:onActionComplete() end
			
			--mainLogic:addGameAction(checkHasDripAction)
			mainLogic:addDestructionPlanAction(checkHasDripAction)

			--GameExtandPlayLogic:dripCasting( mainLogic, dripList , function () self:onActionComplete() end )
	    	
	    else
	    	GameExtandPlayLogic:dripCasting( mainLogic, dripList , function () self:onActionComplete() end )
	    end

	    self.context.needLoopCheck = true
    else
    	self:onActionComplete()
    end

    return #dripList
end

function DripCastingState:getClassName()
    return "DripCastingStateFUCK"
end

function DripCastingState:checkTransition()
    return self.nextState
end

function DripCastingState:onActionComplete()
    self.nextState = self:getNextState()	
    --self.context:onEnter()
end

function DripCastingState:getNextState()
    --return self.context.getHalloweenBossossStateInLoop
    --crash.crash()
end

function DripCastingState:onExit()
    BaseStableState.onExit(self)
    self.hasItemToHandle = nil
    self.nextState = nil
end


DripCastingStateInSwap = class(DripCastingState)

function DripCastingStateInSwap:create(context)
    local v = DripCastingStateInSwap.new()
    v.context = context
    v.mainLogic = context.mainLogic
    v.boardView = v.mainLogic.boardView
    return v
end

function DripCastingStateInSwap:getNextState()
    return self.context.blackCuteBallState
    -- return self.context.ghostMoveState
end

function DripCastingStateInSwap:getClassName()
    return "DripCastingStateInSwap"
end


DripCastingStateInFrist = class(DripCastingState)

function DripCastingStateInFrist:create(context)
    local v = DripCastingStateInFrist.new()
    v.context = context
    v.mainLogic = context.mainLogic
    v.boardView = v.mainLogic.boardView
    return v
end

function DripCastingStateInFrist:getNextState()
    return nil
    --return self.context.roostReplaceStateInLoop
end

function DripCastingStateInFrist:getClassName()
    return "DripCastingStateInFrist"
end



DripCastingStateInLoop = class(DripCastingState)

function DripCastingStateInLoop:create(context)
    local v = DripCastingStateInLoop.new()
    v.context = context
    v.mainLogic = context.mainLogic
    v.boardView = v.mainLogic.boardView
    return v
end

function DripCastingStateInLoop:getNextState()
    return self.context.roostReplaceStateInLoop
end

function DripCastingStateInLoop:getClassName()
    return "DripCastingStateInLoop"
end

DripCastingStateInLast = class(DripCastingState)

function DripCastingStateInLast:create(context)
    local v = DripCastingStateInLast.new()
    v.context = context
    v.mainLogic = context.mainLogic
    v.boardView = v.mainLogic.boardView
    return v
end

function DripCastingStateInLast:onEnter()
    BaseStableState.onEnter(self)
    self.nextState = nil
    self.hasItemToHandle = false

    local resultNum = 0

    if _G.test_DripMode == 2 then
    	resultNum = self:tryToCasting()
    else
    	resultNum = self:tryToCasting()
    end

    return resultNum
end


function DripCastingStateInLast:getNextState()
    return self.context.digScrollGroundStateInLoop
end

function DripCastingStateInLast:getClassName()
    return "DripCastingStateInLast"
end


DripCastingStateInLast_B = class(DripCastingStateInLast)

function DripCastingStateInLast_B:create(context)
    local v = DripCastingStateInLast_B.new()
    v.context = context
    v.mainLogic = context.mainLogic
    v.boardView = v.mainLogic.boardView
    return v
end

function DripCastingStateInLast_B:getNextState()
    return self.context.checkNeedLoopState
end

function DripCastingStateInLast_B:getClassName()
    return "DripCastingStateInLast_B"
end


DripCastingStateInLast_C = class(DripCastingStateInLast)

function DripCastingStateInLast_C:create(context)
    local v = DripCastingStateInLast_C.new()
    v.context = context
    v.mainLogic = context.mainLogic
    v.boardView = v.mainLogic.boardView
    return v
end

function DripCastingStateInLast_C:getNextState()
    return self.context.blocker211State
end

function DripCastingStateInLast_C:getClassName()
    return "DripCastingStateInLast_C"
end