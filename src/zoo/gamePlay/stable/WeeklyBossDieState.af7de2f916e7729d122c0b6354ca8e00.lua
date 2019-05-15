
WeeklyBossDieState = class(BaseStableState)

function WeeklyBossDieState:create(context)
    local v = WeeklyBossDieState.new()
    v.context = context
    v.mainLogic = context.mainLogic  --gameboardlogic
    v.boardView = v.mainLogic.boardView
    return v
end

function WeeklyBossDieState:update()
end

function WeeklyBossDieState:onEnter()
    printx( -1 , "---->>>> WeeklyBossDieState enter")
    self.nextState = nil

    if(not self.mainLogic._fieldLogicPossibility[_FIELD_LOGIC_ID[GameItemType.kWeeklyBoss]]) then
        printx(0, '!skip')
        return 0
    end
    
    local function callback()
        printx( -1 , 'WeeklyBossDieState-->DIE COMPLEPTE')
        self:handleComplete()
    end

    local gameItemMap = self.mainLogic.gameItemMap
    local count = 0
    local posTable = {}
    local drop_sapphire = 0
    for r = 1, #gameItemMap do 
        for c = 1, #gameItemMap[r] do
            local item = gameItemMap[r][c]
            if item.ItemType == GameItemType.kWeeklyBoss 
            and item.weeklyBossLevel > 0 
            and item.blood ~= nil
            and item.blood <= 0 
            and not item.isDead then
                count = count + 1
                table.insert(posTable, {posR = r or 0, posC = c or 0})
                -- posR, posC = r, c
                drop_sapphire = item.drop_sapphire
                item.isDead = true
            end
        end
    end

    if count > 0 then 
        for i=1,count do
            local posInfo = posTable[i]
            if posInfo then 
                local action = GameBoardActionDataSet:createAs(
                                GameActionTargetType.kGameItemAction,
                                GameItemActionType.kItem_Weekly_Boss_Die,
                                IntCoord:create(posInfo.posR, posInfo.posC),
                                nil,
                                GamePlayConfig_MaxAction_time
                            )
                if i == count then 
                    action.completeCallback = callback
                end
                self.mainLogic:addDestroyAction(action)
            end
        end
        self.mainLogic:setNeedCheckFalling()
    end

    return count
end

function WeeklyBossDieState:handleComplete()
    self.mainLogic:setNeedCheckFalling();
end

function WeeklyBossDieState:onExit()
    printx( -1 , "----<<<< WeeklyBossDieState exit")
    self.nextState = nil
    self.hasItemToHandle = false
end

function WeeklyBossDieState:checkTransition()
    printx( -1 , "-------------------------WeeklyBossDieState checkTransition")
    return self.nextState
end
