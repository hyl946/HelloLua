ChestSquareLogic = class()

function ChestSquareLogic:create( context )
    -- body
    local v = ChestSquareLogic.new()
    v.context = context
    v.mainLogic = context.mainLogic  --gameboardlogic
    v.boardView = v.mainLogic.boardView
    return v
end

function ChestSquareLogic:update( ... )
end

function ChestSquareLogic:check()
    local function callback( ... )
        self:handChestSquareComplete();
    end

    self.hasItemToHandle = false
    self.completeItem = 0
    self.totalItem = self:checkChestSquareList(self.mainLogic, callback)

    if self.totalItem == 0 then
        self:handChestSquareComplete()
    else
        self.hasItemToHandle = true
    end
    return self.totalItem
end

function ChestSquareLogic:handChestSquareComplete( ... )
    self.completeItem = self.completeItem + 1 
    if self.completeItem >= self.totalItem then 
        if self.hasItemToHandle then
            self.mainLogic:setNeedCheckFalling();
        end
    end
end

function ChestSquareLogic:findChestSquare(mainLogic, r, c )
    local result_r, result_c
    local item = mainLogic.gameItemMap[r][c]
    if item.chestSquarePartType == 1 then 
        result_r = r
        result_c = c
    elseif item.chestSquarePartType == 2 then
        result_r = r
        result_c = c-1
    elseif item.chestSquarePartType == 3 then
        result_r = r - 1
        result_c = c
    elseif item.chestSquarePartType == 4 then
        result_r = r - 1
        result_c = c - 1
    end
    return result_r, result_c
end

function ChestSquareLogic:checkChestSquareList( mainLogic, callback )
    local count = 0
    if not mainLogic.chestSquareMark then
        return count
    end
    
    ---------------------大宝箱消除
    local hasChestSquare = false
    for r = 1,  #mainLogic.gameItemMap do
        for c = 1, #mainLogic.gameItemMap[r] do 
            local item = mainLogic.gameItemMap[r][c]
            if item and item.ItemType == GameItemType.kChestSquare then 
                hasChestSquare = true
                local totalStrength = item.chestSquarePartStrength 
                                    + mainLogic.gameItemMap[r][c+1].chestSquarePartStrength
                                    + mainLogic.gameItemMap[r+1][c].chestSquarePartStrength
                                    + mainLogic.gameItemMap[r+1][c+1].chestSquarePartStrength


                if totalStrength <= 0 then
                    local hitBySpringBomb = false
                    if item.hitBySpringBomb
                        or mainLogic.gameItemMap[r][c+1].hitBySpringBomb
                        or mainLogic.gameItemMap[r+1][c].hitBySpringBomb
                        or mainLogic.gameItemMap[r+1][c+1].hitBySpringBomb
                    then
                        hitBySpringBomb = true
                        -- if _G.isLocalDevelopMode then printx(0, "22222222222",hitBySpringBomb) end
                        -- debug.debug()
                    end


                    count = count + 1

                    mainLogic:addScoreToTotal(r, c, GamePlayConfigScore.ChestSquare)

                    local action = GameBoardActionDataSet:createAs(
                        GameActionTargetType.kGameItemAction,
                        GameItemActionType.kItem_ChestSquare_Jump,
                        IntCoord:create(r, c),
                        nil,
                        GamePlayConfig_MaxAction_time
                    )
                    action.hitBySpringBomb = hitBySpringBomb
                    action.completeCallback = callback
                    mainLogic:addDestroyAction(action)
                end
            end
        end 
    end

-- 要遍历所有行
    -- for r = 1,  9 do
    --     for c = 1, 9 do 
    --         if mainLogic.backItemMap[r] then
    --             local item = mainLogic.backItemMap[r][c]
    --             if item and item.ItemType == GameItemType.kBigMonster then 
    --                 hasChestSquare = true
    --             end
    --         end
    --     end
    -- end
    -- if not hasChestSquare then                  --大宝箱只会出现在地图配置中
    --     mainLogic.chestSquareMark = false
    -- end
    
    if count == 0 then return 0 end                     ----------------------没有雪怪需要处理

    mainLogic:setNeedCheckFalling()

    return count + 1
end
