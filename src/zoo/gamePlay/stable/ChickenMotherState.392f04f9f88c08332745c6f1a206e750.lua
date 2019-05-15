ChickenMotherState = class(BaseStableState)

function ChickenMotherState:create( context )
    -- body
    local v = ChickenMotherState.new()
    v.context = context
    v.mainLogic = context.mainLogic  --gameboardlogic
    v.boardView = v.mainLogic.boardView
    return v
end

function ChickenMotherState:onEnter()
    BaseStableState.onEnter(self)
    self.nextState = nil

    if not self.mainLogic.gameMode:is(SpringHorizontalEndlessMode) then
        self:handleComplete()
        return 
    end

    local counter = 0
    local function callback()
        counter = counter - 1
        if counter <= 0 then
            self:handleComplete(true)
        end
    end

    local function onCast( ... )
        local gameItemMap = self.mainLogic.gameItemMap

        local normalItems = {}
        local specialItems = {}
        local chickenItems = {}
        for r = 1, #gameItemMap do
            for c = 1, #gameItemMap[r] do
                local item = gameItemMap[r][c]
                if item 
                    and item:isAvailable()
                    and not item:hasLock() 
                    and not item:hasFurball()
                    and item.ItemType == GameItemType.kAnimal then

                    if item.ItemSpecialType == 0 then
                        table.insert(normalItems,item)
                        if item._encrypt.ItemColorType == AnimalTypeConfig.kYellow then
                            table.insert(chickenItems, item)
                        end
                    else
                        table.insert(specialItems,item)
                    end
                end
            end
        end


        local poss = { ccp(0,0) }
        local chickenMother = self.mainLogic.gameMode:getChickenMother()
        if chickenMother then
            poss = chickenMother:getFireworksPosition()
        end

        local len = #poss

        -- +3
        local hasAddMove3 = false
        if self.mainLogic.gameMode:getCastAddMove3Num() < 1 then
            local totalAdd3Num = self.mainLogic.gameMode:getTotalAddMove3Num()
            if totalAdd3Num < Spring2017Config.AddMove3MaxCount then -- 掉落次数限制
                local chance = Spring2017Config.GenerateAddMove3Chance * math.pow(0.5, totalAdd3Num)
                if chance < Spring2017Config.GenerateAddMove3MinChance then chance = Spring2017Config.GenerateAddMove3MinChance end
                chance = chance * 100 -- 整数
                hasAddMove3 = self.mainLogic.randFactory:rand(1, 10000) <= chance
            end
        end
        if hasAddMove3 then
            local items = table.filter(chickenItems,function( v ) return v.x >= 5 end)
            if #items == 0 then
                items = table.filter(normalItems,function( v ) return v.x >= 5 end)
            end
            if #items == 0 then
                items = table.filter(specialItems,function( v ) return v.x >= 5 end)
            end

            if #items > 0 then
                self.mainLogic.gameMode:incCastAddMove3Num()

                local index = self.mainLogic.randFactory:rand(1,#items)
                local r,c = items[index].y,items[index].x
                table.removeValue(normalItems,items[index])
                table.removeValue(specialItems,items[index])

                local action = GameBoardActionDataSet:createAs(
                    GameActionTargetType.kGameItemAction,
                    GameItemActionType.kItem_ChickenMonther_Cast,
                    IntCoord:create(r,c),
                    IntCoord:create(poss[1].x,poss[1].y),
                    GamePlayConfig_MaxAction_time)
                action.changeItemType = "toAddMove3"
                action.completeCallback = callback
                self.mainLogic:addGameAction(action)
                
                counter = counter + 1
            end
        end


        -- 特效
        local toSpecialCount = self.mainLogic.randFactory:rand(
            Spring2017Config.GenerateSpecialCount[1],
            Spring2017Config.GenerateSpecialCount[2]
        )
        toSpecialCount = math.min(toSpecialCount,#normalItems)

        for i=counter+1,counter + toSpecialCount do
            local index = self.mainLogic.randFactory:rand(1,#normalItems)
            local r,c = normalItems[index].y,normalItems[index].x
            table.remove(normalItems,index)

            local action = GameBoardActionDataSet:createAs(
                GameActionTargetType.kGameItemAction,
                GameItemActionType.kItem_ChickenMonther_Cast,
                IntCoord:create(r,c),
                IntCoord:create(poss[i%len + 1].x,poss[i%len + 1].y),
                GamePlayConfig_MaxAction_time)
            action.changeItemType = "toSpecial"
            local specialTypes = { AnimalTypeConfig.kLine, AnimalTypeConfig.kColumn }
            action.changeSpecialType = specialTypes[self.mainLogic.randFactory:rand(1, #specialTypes)]
            action.completeCallback = callback
            self.mainLogic:addGameAction(action)        
        end
        counter = counter + toSpecialCount 

        if counter == 0 then
            callback()
        end
    end

    if self.mainLogic.gameMode:playChickenMotherCastIfNeed(onCast) then
        self.context.needLoopCheck = true
    else
        self:handleComplete()
    end
end

function ChickenMotherState:handleComplete(hasItemHandle)
    self.nextState = self.context.magicLampReinitState
    if hasItemHandle then
        local result = ItemHalfStableCheckLogic:checkAllMapWithNoMove(self.mainLogic)
        if result then
            self.mainLogic:setNeedCheckFalling()
        else
            self.context:onEnter()
        end
    end
end

function ChickenMotherState:onExit()
    BaseStableState.onExit(self)
    self.nextState = nil
end

function ChickenMotherState:checkTransition()
    return self.nextState
end

function ChickenMotherState:getClassName()
    return "ChickenMotherState"
end