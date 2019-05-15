WukongCheckJumpState = class(BaseStableState)

function WukongCheckJumpState:create(context)
    local v = WukongCheckJumpState.new()
    v.context = context
    v.mainLogic = context.mainLogic
    v.boardView = v.mainLogic.boardView
    v.lastCostMoveByGuideWukong = 0
    v.lastCostMoveByGuideWukongTarget = 0
    return v
end

function WukongCheckJumpState:dispose()
    self.mainLogic = nil
    self.boardView = nil
    self.context = nil
    self.lastCostMoveByGuideWukong = 0
    self.lastCostMoveByGuideWukongTarget = 0
end

function WukongCheckJumpState:update(dt)
    
end

function WukongCheckJumpState:onEnter()
    BaseStableState.onEnter(self)
    self.nextState = nil
    --self.lastCostMove = self.mainLogic.realCostMove

    if(not self.mainLogic._fieldLogicPossibility[_FIELD_LOGIC_ID[GameItemType.kWukong]]) then
        printx(0, '!skip')
        self:onActionComplete()
        return
    end

    self:checkJump()
end

function WukongCheckJumpState:checkJump()
    local mainLogic = self.mainLogic
    local gameItemMap = mainLogic.gameItemMap
    local boardmap = mainLogic.boardmap

    -- bonus time
    if mainLogic.isBonusTime then
        self:onActionComplete()
        return
    end

    -- get the lamps
    local monkeys = {}
    for r = 1, #gameItemMap do
        for c = 1, #gameItemMap[r] do
            local item = gameItemMap[r][c]
            if item and item.ItemType == GameItemType.kWukong and item:isAvailable() then
                table.insert(monkeys, item)
            end
        end
    end

    local moneyTargetBoards = {}
    local moneyTargetBoardPos = {}
    for r = 1, #boardmap do
        for c = 1, #boardmap[r] do
            local board = boardmap[r][c]
            if board and board.isWukongTarget then

                if not board.isBlock then
                    local itemOnBoard = nil
                    if gameItemMap[r] then
                        itemOnBoard = gameItemMap[r][c]
                    end

                    if not itemOnBoard 
                        or ( itemOnBoard 
                            and not itemOnBoard:hasFurball() 
                            and itemOnBoard.ItemType ~= GameItemType.kCoin
                            and itemOnBoard.ItemType ~= GameItemType.kVenom ) 
                        then
                        table.insert(moneyTargetBoards, board)
                    end
                end
                table.insert(moneyTargetBoardPos, {r = r , c = c} )
            end
        end
    end

    if #monkeys == 0 then
        self:onActionComplete()
        return
    end

    local count = 0
    local function actionCallback()
        count = count + 1
        if count >= #monkeys then
            self:onActionComplete()
            self.context:onEnter() -- 改State不会造成棋盘掉落，需要手动调用onEnter
        end
    end

    local action = nil
    for k, v in pairs(monkeys) do

    	local monkey = v

        if monkey.wukongProgressCurr >= monkey.wukongProgressTotal then
           
            if #moneyTargetBoards > 0 then
                

                local ranList = {}
                local maxRow = 0
                local board = nil

                for ik, iv in pairs(moneyTargetBoards) do
                    board = iv
                    if board.y == 8 then
                        table.insert( ranList , board )
                    end
                end

                if #ranList == 0 then
                    for ik, iv in pairs(moneyTargetBoards) do
                        board = iv
                        if board.y > maxRow then
                            maxRow = board.y
                        end
                    end

                    for ik, iv in pairs(moneyTargetBoards) do
                        board = iv
                        if board.y == maxRow then
                            table.insert( ranList , board )
                        end
                    end
                end
                

                local idx = self.mainLogic.randFactory:rand(1, #ranList)
                local selectBoard = ranList[idx]
                monkey.wukongJumpPos = IntCoord:create( selectBoard.x , selectBoard.y )

                local deleteIndex = nil
                for ik, iv in pairs(moneyTargetBoards) do
                    if iv.x == selectBoard.x and iv.y == selectBoard.y then
                        deleteIndex = ik
                    end
                end
                if deleteIndex then table.remove(moneyTargetBoards, deleteIndex) end

                if monkey.wukongState == TileWukongState.kNormal or monkey.wukongState == TileWukongState.kOnActive then
                    
                    action = GameBoardActionDataSet:createAs(
                        GameActionTargetType.kGameItemAction,
                        GameItemActionType.kItem_Wukong_CheckAndChangeState,
                        IntCoord:create(monkey.y, monkey.x),
                        nil,
                        GamePlayConfig_MaxAction_time
                    )
                    action.completeCallback = actionCallback
                    action.addInfo = "changeToReadyToJump"
                    
                    self.mainLogic:addGameAction(action)
                    GameGuide:sharedInstance():onWukongCrazy({r = monkey.y , c = monkey.x})
                    --GameGuide:sharedInstance():onWukongGuideJump( moneyTargetBoardPos )
                    
                    DcUtil:activity( { category="other",sub_category="spring_festival_crazy_ready" } )
                end
                
                self.lastCostMoveByGuideWukongTarget = self.mainLogic.realCostMove
                if self.mainLogic.realCostMove - self.lastCostMoveByGuideWukong >= 2 then
                    if self.mainLogic.boardView.baseMap[monkey.y] 
                        and self.mainLogic.boardView.baseMap[monkey.y][monkey.x] 
                        and self.mainLogic.boardView.baseMap[monkey.y][monkey.x]:getWukongSprite() then
                        local monkeyView = self.mainLogic.boardView.baseMap[monkey.y][monkey.x]:getWukongSprite()
                        local guidepos = monkeyView:getPositionInWorldSpace()
                        self.mainLogic.PlayUIDelegate:playHandGuideAnimation(guidepos)
                    end
                    
                end
            else

                if monkey.wukongState == TileWukongState.kReadyToJump then
                    
                    action = GameBoardActionDataSet:createAs(
                        GameActionTargetType.kGameItemAction,
                        GameItemActionType.kItem_Wukong_CheckAndChangeState,
                        IntCoord:create(monkey.y, monkey.x),
                        nil,
                        GamePlayConfig_MaxAction_time
                    )
                    action.completeCallback = actionCallback
                    action.addInfo = "changeToActive"
                    
                    self.mainLogic:addGameAction(action)
                end

                if self.mainLogic.realCostMove - self.lastCostMoveByGuideWukongTarget >= 5 then
                    GameGuide:sharedInstance():onWukongGuideJump({wukongGuide = true, pos = moneyTargetBoardPos}, "wukongGuideJumpAuto")
                    self.lastCostMoveByGuideWukongTarget = self.mainLogic.realCostMove
                end
                self.lastCostMoveByGuideWukong = self.mainLogic.realCostMove
            end

            local monkeyItem = mainLogic.boardView.baseMap[monkey.y][monkey.x] 
            if monkeyItem then
                monkeyItem.isNeedUpdate = true
            end
        else
            self.lastCostMoveByGuideWukongTarget = self.mainLogic.realCostMove
            self.lastCostMoveByGuideWukong = self.mainLogic.realCostMove
        end
        
    end

    --mainLogic.boardView:updateWukongTargetBoard()

    if not action then
        self:onActionComplete()
    end
    
end

function WukongCheckJumpState:onExit()
    BaseStableState.onExit(self)
end

function WukongCheckJumpState:checkTransition()
    return self.nextState
end

function WukongCheckJumpState:onActionComplete()
	self.nextState = self:getNextState()
end

function WukongCheckJumpState:getNextState( ... )
    -- body
    return self.context.dripCastingStateInLast_C
end

function WukongCheckJumpState:getClassName( ... )
    -- body
    return "WukongCheckJumpState"
end