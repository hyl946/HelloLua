MagicTileResetState = class(BaseStableState)

function MagicTileResetState:create( context )
    -- body
    local v = MagicTileResetState.new()
    v.context = context
    v.mainLogic = context.mainLogic  --gameboardlogic
    v.boardView = v.mainLogic.boardView
    return v
end

function MagicTileResetState:onEnter()
    BaseStableState.onEnter(self)
    self.nextState = nil
    self.hasItemToHandle = false
    self.handleCount = 0
    self.completeCount = 0
    self.hasDieProcedure = false

    if(not self.mainLogic._fieldLogicPossibility[_FIELD_LOGIC_ID.magicTile]) then
        printx(0, '!skip')
        return
    end

    -- state处于大循环中，所以用标记保证每步只处理一次
    if self.mainLogic.gameMode.lastMagicTileResetStep ~= self.mainLogic.realCostMoveWithoutBackProp then
        self:handleMagicTile()
    else
        self:handleComplete()
    end
end

function MagicTileResetState:handleMagicTile()
    if not self.mainLogic.gameMode:is(MoleWeeklyRaceMode) then       --注意：若要打开mode限制，请注意lastSeedCountdownStep现已与mode绑定
        self:handleComplete()
        return 
    end

    self.mainLogic.gameMode.lastMagicTileResetStep = self.mainLogic.realCostMoveWithoutBackProp

    local function tileChangeCallback()
        self.completeCount = self.completeCount + 1
        if self.completeCount >= self.handleCount then
            if self.hasDieProcedure then
                self.context.needLoopCheck = true
            else
                self.hasItemToHandle = true
            end
            self:handleComplete()
        end
    end

    ---需要重新回复有效的tiles
    local toActivateMagicTiles = {}

    local boardmap = self.mainLogic.boardmap
    for r = 1, #boardmap do 
        for c = 1, #boardmap[r] do 
            local item = boardmap[r][c]
            if item then
                if item.isMagicTileAnchor then
                    if self.mainLogic.isInStep and item.magicTileId ~= nil and item.isHitThisRound == true then
                        -- 如果已经初始化就更新剩余
                        item.remainingHit = item.remainingHit - 1
                        item.isHitThisRound = false
                        if item.remainingHit == 1 then      --播放即将消失的提示
                            local itemView = self.mainLogic.boardView.baseMap[r][c]
                            if itemView then
                                itemView:playMagicTileVanishCountDownAlert()
                            end
                        end
                    end
                end

                if item.magicTileDisabledRound > 0 then
                    -- item.magicTileDisabledRound = item.magicTileDisabledRound - 1    --改版：去掉倒计时，永久失效（因恐产品反复，故不删除逻辑）
                    if item.magicTileDisabledRound <= 0 then
                        item.magicTileDisabledRound = 0
                        table.insert(toActivateMagicTiles, IntCoord:create(r, c))
                    end
                end
            end
        end
    end

    -- printx(11, "MagicTileResetState. toActivateMagicTiles:", table.tostring(toActivateMagicTiles))
    if #toActivateMagicTiles > 0 then
        for _, v in ipairs(toActivateMagicTiles) do
            local row, column = v.x, v.y

            local action = GameBoardActionDataSet:createAs(
                GameActionTargetType.kGameItemAction,
                GameItemActionType.kItem_Magic_Tile_Change,
                IntCoord:create(row,column),
                nil,
                GamePlayConfig_MaxAction_time
            )

            action.objective = 'reactiveGrid'
            action.targetGrid = toActivateMagicTiles
            action.completeCallback = tileChangeCallback
            self.mainLogic:addGameAction(action)
            self.handleCount = self.handleCount + 1
        end
    end

    for r = 1, #boardmap do 
        for c = 1, #boardmap[r] do 
            local item = boardmap[r][c]
            if item and item.isMagicTileAnchor and item.remainingHit == 1 then
                local action = GameBoardActionDataSet:createAs(
                    GameActionTargetType.kGameItemAction,
                    GameItemActionType.kItem_Magic_Tile_Change,
                    IntCoord:create(r,c),
                    nil,
                    GamePlayConfig_MaxAction_time
                )
                action.objective = 'color'
                action.completeCallback = tileChangeCallback
                self.mainLogic:addGameAction(action)
                self.handleCount = self.handleCount + 1
            elseif item and item.isMagicTileAnchor and item.remainingHit <= 0 then
                local action = GameBoardActionDataSet:createAs(
                    GameActionTargetType.kGameItemAction,
                    GameItemActionType.kItem_Magic_Tile_Change,
                    IntCoord:create(r,c),
                    nil,
                    GamePlayConfig_MaxAction_time
                )
                action.objective = 'die'
                action.completeCallback = tileChangeCallback
                self.mainLogic:addGameAction(action)
                self.handleCount = self.handleCount + 1
                self.hasDieProcedure = true
            end
        end
    end

    if self.handleCount == 0 then
        self:handleComplete()
    end
end

function MagicTileResetState:handleComplete()
    -- self.nextState = self.context.buffBoomGenerateState
    self.nextState = self.context.wukongReinitState
    if self.hasItemToHandle then
        self.context:onEnter()
    end
end

function MagicTileResetState:onExit()
    BaseStableState.onExit(self)
    self.nextState = nil
    self.hasItemToHandle = false
    self.handleCount = 0
    self.completeCount = 0
end

function MagicTileResetState:checkTransition()
    return self.nextState
end

function MagicTileResetState:getClassName()
    return "MagicTileResetState"
end