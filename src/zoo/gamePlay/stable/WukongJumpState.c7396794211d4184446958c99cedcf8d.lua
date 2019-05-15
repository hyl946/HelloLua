WukongJumpState = class(BaseStableState)


function WukongJumpState:create(context)
    local v = WukongJumpState.new()
    v.context = context
    v.mainLogic = context.mainLogic
    v.boardView = v.mainLogic.boardView
    return v
end

function WukongJumpState:dispose()
    self.mainLogic = nil
    self.boardView = nil
    self.context = nil
end

function WukongJumpState:update(dt)
    
end

function WukongJumpState:onEnter()

end

function WukongJumpState:tryJumpToTarget(sourceType)
    local mainLogic = self.mainLogic
    local gameItemMap = mainLogic.gameItemMap
    local boardmap = mainLogic.boardmap

    

    local monkeys = {}
    for r = 1, #gameItemMap do
        for c = 1, #gameItemMap[r] do
            local item = gameItemMap[r][c]
            if item and item.ItemType == GameItemType.kWukong and item:isAvailable() then

                local moneyBoard = boardmap[item.y][item.x]
                local onMoneyBoard = false
                if moneyBoard and moneyBoard.isWukongTarget then
                    onMoneyBoard = true
                end

                if sourceType == "InProp" then
                    if onMoneyBoard then
                        item.onMoneyBoard = true
                        table.insert(monkeys, item)
                    elseif mainLogic.gameMode.useWukongJump and item.wukongState == TileWukongState.kReadyToJump then
                        table.insert(monkeys, item)
                    end
                elseif sourceType == "InBonus" and item.wukongState == TileWukongState.kReadyToJump then
                    table.insert(monkeys, item)
            	elseif sourceType == "InSwapFirst" and onMoneyBoard then
            		table.insert(monkeys, item)
            	end
                
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
        end
    end

    local actionMonkeys = {}

    for k, v in pairs(monkeys) do
        local monkey = v

        local function createActions(targetPos)
        	local action = GameBoardActionDataSet:createAs(
                        GameActionTargetType.kGameItemAction,
                        GameItemActionType.kItem_Wukong_Casting,
                        IntCoord:create(monkey.y, monkey.x),
                        nil,
                        GamePlayConfig_MaxAction_time
                    )
	        action.completeCallback = actionCallback
	        action.monkeyTargetPos = targetPos

            mainLogic:addReplayReordPreviewBlock()

	        return action
        end

        if sourceType == "InProp" or sourceType == "InBonus" then

            if monkey.onMoneyBoard then
                local jumpAction = createActions( IntCoord:create(monkey.x, monkey.y) )
                jumpAction.noJump = true
                self.mainLogic:addDestructionPlanAction( jumpAction )
                mainLogic:setNeedCheckFalling()
                table.insert( actionMonkeys , monkey )
            else
                local monkeyTargetPos = monkey.wukongJumpPos

                if monkeyTargetPos then
                    self.mainLogic:addDestructionPlanAction( createActions(monkeyTargetPos) )
                    mainLogic:setNeedCheckFalling()
                    table.insert( actionMonkeys , monkey )
                    mainLogic.gameMode.useWukongJump = false

                    if sourceType == "InProp" then
                        GameGuide:sharedInstance():onWukongCrazyClick()
                        DcUtil:activity( { category="other",sub_category="spring_festival_crazy_click" } )
                    end
                end
            end
        else
            --[[
        	local moneyBoard = boardmap[monkey.y][monkey.x]
	        if moneyBoard and moneyBoard.isWukongTarget then
	        	
	        end
            ]]

            local jumpAction = createActions( IntCoord:create(monkey.x, monkey.y) )
            jumpAction.noJump = true
            self.mainLogic:addDestructionPlanAction( jumpAction )
            mainLogic:setNeedCheckFalling()
            table.insert( actionMonkeys , monkey )
        end
    end

    if #actionMonkeys == 0 then
    	self:onActionComplete()
    end

end

function WukongJumpState:onExit()
    BaseStableState.onExit(self)
end

function WukongJumpState:checkTransition()
    return self.nextState
end

function WukongJumpState:onActionComplete(bomb)
    self.nextState = self:getNextState()
end

function WukongJumpState:getNextState( ... )
    -- body
    return nil
end

function WukongJumpState:getClassName( ... )
    -- body
    return "WukongJumpState"
end

WukongJumpStateInSwapFirst = class(WukongJumpState)
function WukongJumpStateInSwapFirst:create(context)
    local v = WukongJumpStateInSwapFirst.new()
    v.context = context
    v.mainLogic = context.mainLogic
    v.boardView = v.mainLogic.boardView
    return v 
end

function WukongJumpStateInSwapFirst:onEnter()
    BaseStableState.onEnter(self)
    self.nextState = nil

    if(not self.mainLogic._fieldLogicPossibility[_FIELD_LOGIC_ID[GameItemType.kWukong]]) then
        printx(0, '!skip')
        self:onActionComplete()
        return
    end

    WukongJumpState.tryJumpToTarget(self , "InSwapFirst")
    --self.nextState = self:getNextState()
end

function WukongJumpStateInSwapFirst:getClassName()
    return "WukongJumpStateInSwapFirst"
end

function WukongJumpStateInSwapFirst:getNextState()
    return self.context.furballSplitStateInSwapFirst
end



WukongJumpStateInProp = class(WukongJumpState)
function WukongJumpStateInProp:create(context)
    local v = WukongJumpStateInProp.new()
    v.context = context
    v.mainLogic = context.mainLogic
    v.boardView = v.mainLogic.boardView
    return v
end

function WukongJumpStateInProp:onEnter()
    BaseStableState.onEnter(self)
    self.nextState = nil

    if(not self.mainLogic._fieldLogicPossibility[_FIELD_LOGIC_ID[GameItemType.kWukong]]) then
        printx(0, '!skip')
        self:onActionComplete()
        return
    end

    WukongJumpState.tryJumpToTarget(self, "InProp")
    --self.nextState = self:getNextState()
end

function WukongJumpStateInProp:getClassName()
    return "WukongJumpStateInProp"
end

function WukongJumpStateInProp:getNextState()
    return self.context.hedgehogCrazyInProp
    --return self.context.balloonCheckStateInLoop
end


WukongJumpStateInBonus = class(WukongJumpState)
function WukongJumpStateInBonus:create(context)
    local v = WukongJumpStateInBonus.new()
    v.context = context
    v.mainLogic = context.mainLogic
    v.boardView = v.mainLogic.boardView
    return v
end

function WukongJumpStateInBonus:onEnter()
    BaseStableState.onEnter(self)
    self.nextState = nil

    if(not self.mainLogic._fieldLogicPossibility[_FIELD_LOGIC_ID[GameItemType.kWukong]]) then
        printx(0, '!skip')
        self:onActionComplete()
        return
    end

    WukongJumpState.tryJumpToTarget(self, "InBonus")
    --self.nextState = self:getNextState()
end

function WukongJumpStateInBonus:getClassName()
    return "WukongJumpStateInBonus"
end

function WukongJumpStateInBonus:getNextState()
    return self.context.bonusEffectState
    --return self.context.balloonCheckStateInLoop
end
