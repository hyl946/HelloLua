MaydayBossJumpState = class(BaseStableState)


function MaydayBossJumpState:create( context )
    -- body
    local v = MaydayBossJumpState.new()
    v.context = context
    v.mainLogic = context.mainLogic  --gameboardlogic
    v.boardView = v.mainLogic.boardView
    return v
end

function MaydayBossJumpState:update( ... )
    -- body
end

function MaydayBossJumpState:onEnter()
    BaseStableState.onEnter(self)
    self.nextState = nil

    if(not self.mainLogic._fieldLogicPossibility[_FIELD_LOGIC_ID[GameItemType.kBoss]]) then
        printx(0, '!skip')
        self.nextState = self:getNextState()
        return
    end

    
    if not self.lastMove then self.lastMove = self.mainLogic.realCostMove end


    local gameItemMap = self.mainLogic.gameItemMap
    local boardMap = self.mainLogic.boardmap
    local count = 0
    local posR, posC = 0, 0
    for r = 1, #gameItemMap do 
        for c = 1, #gameItemMap[r] do
            local item = gameItemMap[r][c]
            if item.ItemType == GameItemType.kBoss 
            -- and item.bossLevel >= 3 
            and item.blood ~= nil
            and item.blood > 0 
            and self.lastMove < self.mainLogic.realCostMove 
            and item.maxMoves > 0
            then
                if _G.isLocalDevelopMode then printx(0, 'moves', item.moves) end
                if item.moves <= 1 then
                    item.moves = item.moves - 1
                    count = count + 1
                    item.moves = item.maxMoves
                    self.lastMove = self.mainLogic.realCostMove
                    posR, posC = r, c
                else
                    item.moves = item.moves - 1
                    -- item.moves = item.moves - 10 -- test
                end
            end
        end
    end

    local function isNormal(item)
        if item.ItemType == GameItemType.kAnimal
            and item.ItemSpecialType == 0 -- not special
            and item:isAvailable()
            and not item:hasLock() 
            and not item:hasFurball()
        then
            return true
        end
        return false
    end

    local function checkRopeCloudOK(r, c)
        local TL = gameItemMap[r][c]
        local TR = gameItemMap[r][c+1]
        local BL = gameItemMap[r+1][c]
        local BR = gameItemMap[r+1][c+1]

        local TLmap = boardMap[r][c]
        local TRmap = boardMap[r][c+1]
        local BLmap = boardMap[r+1][c]
        local BRmap = boardMap[r+1][c+1] 

        if TLmap:hasRightRope() or TLmap:hasBottomRope()
        or TRmap:hasLeftRope() or TRmap:hasBottomRope()
        or BLmap:hasTopRope() or BLmap:hasRightRope()
        or BRmap:hasTopRope() or BRmap:hasLeftRope() 
        or not (isNormal(TL) and isNormal(TR) and isNormal(BL) and isNormal(BR)) then
            return false
        end
        return true
    end

    local function hasOverlap(r, c)
        if r >= posR and r <= posR + 1 and c >= posC and c <= posC + 1 then
            return true
        end
        return false
    end

    local function noMoveTile(r, c)
        local boardDatal = boardMap[r][c]
        local boardDatar = boardMap[r][c+1]
        local boardDatald = boardMap[r+1][c]
        local boardDatard = boardMap[r+1][c+1]
        if boardDatal and not boardDatal.isMoveTile and 
            boardDatar and not boardDatar.isMoveTile and
            boardDatald and not boardDatald.isMoveTile and
            boardDatard and not boardDatard.isMoveTile then
            return true
        end
        return false
    end

    local function newGetJumpTo()
        local availablePos = {}
        for r = 1, 8 do 
            for c = 1, 8 do 
                local item = gameItemMap[r][c]
                local boardData = boardMap[r][c]
                if isNormal(item) and not hasOverlap(r, c) and noMoveTile(r, c) then
                    table.insert(availablePos, {r=r, c=c})
                end
            end
        end
        local finalAvailablePos = {}
        for k, v in pairs(availablePos) do 
            if checkRopeCloudOK(v.r, v.c) then
                table.insert(finalAvailablePos, v)
            end
        end
        if #finalAvailablePos > 0 then
            local selector = self.mainLogic.randFactory:rand(1, #finalAvailablePos)
            return finalAvailablePos[selector].r, finalAvailablePos[selector].c
        else 
            return nil, nil
        end
    end


    local function callback( ... )
        -- body
        self:handleComplete(count > 0);
    end

    if count > 0 then    
        local jumpToR, jumpToC = newGetJumpTo()

        if jumpToR == nil or jumpToC == nil then -- boss没有地方可跳了
            self.nextState = self:getNextState()
        else

            if _G.isLocalDevelopMode then printx(0, 'getJumpTo', posR, posC, jumpToR, jumpToC) end

            local action = GameBoardActionDataSet:createAs(
                            GameActionTargetType.kGameItemAction,
                            GameItemActionType.kItem_Mayday_Boss_Jump,
                            IntCoord:create(posR, posC),
                            IntCoord:create(jumpToR, jumpToC),
                            GamePlayConfig_MaxAction_time
                        )
            action.completeCallback = callback
            self.mainLogic:addGameAction(action)
        end
    else
        self.nextState = self:getNextState()
    end 
end


function MaydayBossJumpState:handleComplete(jumped)
    self.nextState = self:getNextState()
    if jumped then
        self.mainLogic:setNeedCheckFalling();
    else
        self.context:onEnter()
    end
end

function MaydayBossJumpState:onExit()
    BaseStableState.onExit(self)
    self.nextState = nil
    self.hasItemToHandle = false
end

function MaydayBossJumpState:checkTransition()
    return self.nextState
end

function MaydayBossJumpState:getNextState()
    return self.context.roostReplaceStateInSwapFirst
end

function MaydayBossJumpState:getClassName()
    return "MaydayBossJumpState"
end