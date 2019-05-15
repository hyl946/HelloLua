MaydayBossDieState = class(BaseStableState)


function MaydayBossDieState:create(context)
    local v = MaydayBossDieState.new()
    v.context = context
    v.mainLogic = context.mainLogic  --gameboardlogic
    v.boardView = v.mainLogic.boardView
    return v
end

function MaydayBossDieState:update()
end

function MaydayBossDieState:onEnter()
    printx( -1 , "---->>>> MaydayBossDieState enter")
    self.nextState = nil

    if(not self.mainLogic._fieldLogicPossibility[_FIELD_LOGIC_ID[GameItemType.kBoss]]) then
        printx(0, '!skip')
        return 0
    end

    local function callback()
        if _G.isLocalDevelopMode then printx(0, 'DIE COMPLEPTE') end
        self:handleComplete();
    end

    local gameItemMap = self.mainLogic.gameItemMap
    local count = 0
    local posTable = {}
    local posR, posC = 0, 0
    local drop_sapphire = 0
    local addMoveCount = 0
    local deadbuffNum = 0 -- 生成春节问好数量
    for r = 1, #gameItemMap do 
        for c = 1, #gameItemMap[r] do
            local item = gameItemMap[r][c]
            if item.ItemType == GameItemType.kBoss 
            and item.bossLevel > 0 
            and item.blood ~= nil
            and item.blood <= 0 
            and not item.isDead then
                count = count + 1
                table.insert(posTable, {posR = r or 0, posC = c or 0})
                addMoveCount = item.animal_num
                drop_sapphire = item.drop_sapphire
                deadbuffNum = BossConfig[item.bossLevel].deadbuffNum
                item.isDead = true
            end
        end
    end

    if count > 0 then
        local function bossDie()
            for i=1,count do
                local posInfo = posTable[i]
                if posInfo then 
                    local addMoveItemPos = GameExtandPlayLogic:getNormalPositionsForBoss(self.mainLogic, addMoveCount, 6, 9, nil)
                    local questionItemPos = GameExtandPlayLogic:getNormalPositionsForBoss(self.mainLogic, deadbuffNum, 6, 9, addMoveItemPos)

                    local banlist = {}
                    for k, v in pairs(addMoveItemPos) do
                        table.insert( banlist , v )
                    end
                    for k, v in pairs(questionItemPos) do
                        table.insert( banlist , v )
                    end

                    local dripPos = {}
                    if self.mainLogic.hasDripOnLevel then
                        dripPos = GameExtandPlayLogic:getNormalPositionsForBoss(
                            self.mainLogic,  self.mainLogic.randFactory:rand(2, 3) , 6, 9, banlist)
                    end
                   
                    -- if _G.isLocalDevelopMode then printx(0, 'addMoveItemPos', table.tostring(addMoveItemPos)) end
                    -- if _G.isLocalDevelopMode then printx(0, 'questionItemPos', table.tostring(questionItemPos)) end

                    local action = GameBoardActionDataSet:createAs(
                                    GameActionTargetType.kGameItemAction,
                                    GameItemActionType.kItem_Mayday_Boss_Die,
                                    IntCoord:create(posInfo.posR, posInfo.posC),
                                    nil,
                                    GamePlayConfig_MaxAction_time
                                )
                    action.completeCallback = callback
                    action.addMoveItemPos = addMoveItemPos
                    action.questionItemPos = questionItemPos
                    action.dripPos = dripPos
                    self.mainLogic:addDestroyAction(action)
                end
            end
            self.mainLogic:setNeedCheckFalling()
        end

        -- 如果boss死前可以发放大招，那么发大招之后才死
        local buffCount = 0
        local _buffCounter = 0
        local function buffCallback()
            _buffCounter = _buffCounter + 1
            if _buffCounter >= buffCount then
                bossDie()
            end
        end        

        buffCount = GameExtandPlayLogic:checkBossCasting(self.mainLogic, buffCallback , true)

        if buffCount == 0 then
            bossDie()
        end
    end 

    return count
end


function MaydayBossDieState:handleComplete()
    self.mainLogic:setNeedCheckFalling();
end

function MaydayBossDieState:onExit()
    printx( -1 , "----<<<< MaydayBossDieState exit")
    self.nextState = nil
    self.hasItemToHandle = false
end

function MaydayBossDieState:checkTransition()
    printx( -1 , "-------------------------MaydayBossDieState checkTransition")
    return self.nextState
end

