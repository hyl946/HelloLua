MaydayEndlessMode = class(MoveMode)

-- 循环开始的行
MaydayEndlessModeStartCopyLine = 19  -- 19

local function swapInTable(table, i, j)
    local t = table[i]
    table[i] = table[j]
    table[j] = t
end

local ground_upgrade_interval       = 4     -- upgrade ground per 4 rows
local add_max_jewel_interval        = 6     -- max_jewel adds 1 per 6 rows
local generate_add_move_interval    = 5     -- generate 1 add_move per 5 rows
local max_jewel_limit               = 8    -- max jewel limit is 8
local initial_max_jewel             = 6
local max_generate_row              = 2
local generate_boss_interval        = 4
local generate_jewel_interval       = 2
local initial_level2_count          = 4
local max_level2_count              = 10
local max_level3_count              = 3


function MaydayEndlessMode:initModeSpecial(config)
    self.levelConfig = config
    self.mainLogic.digJewelCount = DigJewelCount.new()
    self.mainLogic.maydayBossCount = 0

    -- initialize ground pool
    self.groundPool = {}
    local length = 9*max_generate_row
    for i=1, length do
        if i >= 1 and i <= initial_level2_count then
            self.groundPool[i] = 2 
        else    
            self.groundPool[i] = 1 -- level 1 ground
        end
    end
    -- 打乱次序
    for i =1 , 2*length do 
        local selector = self.mainLogic.randFactory:rand(1, length)
        swapInTable(self.groundPool, 1, selector)
    end

    self.rowCountSinceLastGroundUpgrade = 0
    self.maxJewel = initial_max_jewel
    self.generatedRowCount = 0
    self.rowCountSinceLastAddMove = 0


    self.lastGenBossTimes = 0
    self.lastGenJewelTimes = 0
    self.mainLogic.passedRow = 0
    self.moveBoforeScroll = 0
end

function MaydayEndlessMode:afterFail()
    if _G.isLocalDevelopMode then printx(0, 'MaydayEndlessMode:afterFail') end
    local mainLogic = self.mainLogic
    local function tryAgainWhenFailed(isTryAgain,  propId, deltaStep)   ----确认加5步之后，修改数据
        if isTryAgain then
            local function callback()
                self:getAddSteps(deltaStep or 5)
                mainLogic:setGamePlayStatus(GamePlayStatus.kNormal)
                if not mainLogic.replaying then
                    mainLogic.fsm:changeState(mainLogic.fsm.waitingState)

                    local replaydata = {prop = GamePropsType.kBombAdd5, pt=UsePropsType.TEMP, x1 = r1, y1 = c1, x2 = r2, y2 = c2} --加五步，标识为临时，则不会开局当作虚假道具新增
                    ReplayDataManager:addReplayStep(replaydata)
                    SnapshotManager:catchUseProp(replaydata)
                end

                if mainLogic.PlayUIDelegate and mainLogic.PlayUIDelegate.useSpringItemCallback then 
                    mainLogic.PlayUIDelegate:useSpringItemCallback(true, true)
                end
            end
            BossAnimation:playBombAnimation(callback)
        else
            if MoveMode.reachEndCondition(self) then
                self.leftMoveToWin = self.theCurMoves
                mainLogic:setGamePlayStatus(GamePlayStatus.kBonus)
                if mainLogic.PlayUIDelegate and mainLogic.PlayUIDelegate.levelTargetPanel then
                    mainLogic.PlayUIDelegate.levelTargetPanel:setExtraTargetInvisible()
                end
            else
                mainLogic:setGamePlayStatus(GamePlayStatus.kFailed)
            end
        end
    end 
    if mainLogic.PlayUIDelegate then
        mainLogic.PlayUIDelegate:addStep(mainLogic.level, mainLogic.totalScore, self:getScoreStarLevel(mainLogic), self:reachTarget(), tryAgainWhenFailed)
    end
end

function MaydayEndlessMode:onGameInit()
    local context = self

    --context.moveBoforeScroll = 0

    local function setGameStart()
        context.mainLogic:setGamePlayStatus(GamePlayStatus.kNormal)
        context.mainLogic.boardView:showItemViewLayer()
        context.mainLogic.boardView:removeDigScrollView()
        context.mainLogic.boardView.isPaused = false
        context.mainLogic.fsm:initState()

        self.generatedRowCount = 0
        self.lastGenJewelTimes = 0
        self.lastGenBossTimes  = 0

       self:onStartGame()

        if context.mainLogic.PlayUIDelegate then
            context.mainLogic.PlayUIDelegate:playFirstShowFireworkGuide()
        end

    end

    local function playInitBuffAnimation()
        if GameInitBuffLogic:hasAnyInitBuffIncludedReplay() then

            GameInitBuffLogic:tryFindBuffPos()

            if GameInitBuffLogic:hasAnyInitBuff() then
                GameInitBuffLogic:doChangeBoardByGameInitBuff( function () setGameStart() end )
            else
                setGameStart()
            end
        else
            setGameStart()
        end
    end

    local function playPrePropAnimation()

        if context.mainLogic.PlayUIDelegate then
            context.mainLogic.PlayUIDelegate:playPrePropAnimation(playInitBuffAnimation) 
        else
            setGameStart()
        end
    end

    local function playDigScrollAnimation()
        context.mainLogic.boardView:startScrollInitDigView(playPrePropAnimation)
    end

    local extraItemMap, extraBoardMap = context:getExtraMap(0, #context.mainLogic.digBoardMap)
    if _G.isLocalDevelopMode then printx(0, 'extraItemMap', #extraItemMap, 'extraBoardMap', #extraBoardMap) end
    -- 2016-11-17 张宏超（KENG），从第20行开始向上滚动
    local first20ItemMap = {}
    local first20BoardMap = {}
    for i=1,math.min(25,#extraItemMap) do
        table.insert(first20ItemMap,extraItemMap[i])
        table.insert(first20BoardMap,extraBoardMap[i])
    end

    self.mainLogic.boardView:initDigScrollView(first20ItemMap, first20BoardMap)
    -- self.mainLogic.boardView:initDigScrollView(extraItemMap, extraBoardMap)
    self.mainLogic.boardView:hideItemViewLayer()
    

    if self.mainLogic.PlayUIDelegate then
        self.mainLogic.PlayUIDelegate:playLevelTargetPanelAnim(playDigScrollAnimation)
    else
        playDigScrollAnimation()
    end
    self.mainLogic:stopWaitingOperation()
end

function MaydayEndlessMode:reachEndCondition()
    return MoveMode.reachEndCondition(self)
end

function MaydayEndlessMode:reachTarget()
    return false
end


-- 循环生成，从第20行开始的行
function MaydayEndlessMode:generateAdditionMap(passedRow, addRow)
    local mainLogic = self.mainLogic
    local animalMap = self.levelConfig.animalMap

    local newItemMap, newBoardMap = {}, {}
    local gap = MaydayEndlessModeStartCopyLine - 9
    -- MaydayEndlessModeStartCopyLine行以后的为循环生成区域
    local totalAdditionRowCount = #self.mainLogic.digBoardMap - gap
    -- if _G.isLocalDevelopMode then printx(0, "@peng2 totalAdditionRowCount",totalAdditionRowCount) end 

     for i = 1, addRow do
        -- 理论上passedRow不应该小于gap，但是原有逻辑在处理即有config，又有generator生成时，passedRow默认还是0，其实应该加上config里生成的row
        -- 股passedRow的最小值应该是gap
        if (passedRow < gap) then passedRow = gap end


        local realRow = (passedRow  +  i - gap) % totalAdditionRowCount
        if realRow == 0 then realRow = totalAdditionRowCount end

        
        realRow  = realRow + gap  -- 循环生成层和tilemap之间的要忽略
        
        if _G.isLocalDevelopMode then printx(0, "@peng2","totalAdditionRowCount",totalAdditionRowCount," realRow",realRow," passedRow",passedRow," addRow i",i) end
        if _G.isLocalDevelopMode then printx(0, passedRow,addRow,#self.mainLogic.digBoardMap) end
        
        for col = 1, 9 do
            newItemMap[i] = newItemMap[i] or {}
            newBoardMap[i] = newBoardMap[i] or {}

            local itemData = self.mainLogic.digItemMap[realRow][col]:copy()
            newItemMap[i][col] = itemData
            
            local animalDef = animalMap[realRow+9][col]
            if animalDef then
                itemData:initByAnimalDef(animalDef)
            end

            if itemData:isColorful() then           --可以随机颜色的物体
                if itemData._encrypt.ItemColorType == AnimalTypeConfig.kRandom           --随机类型
                    and itemData.ItemSpecialType ~= AnimalTypeConfig.kColor then    
                        itemData._encrypt.ItemColorType = mainLogic:randomColor()
                end
            end

            local boardData = self.mainLogic.digBoardMap[realRow][col]:copy()
            newBoardMap[i][col] = boardData


            -- 超过产品配置的原始最大行数，如果是道具云块，要变成随机小动物
            if ( (passedRow + addRow) > #self.mainLogic.digBoardMap and itemData.ItemType == GameItemType.kRandomProp ) then
-- if ( itemData.ItemType == GameItemType.kDigGround ) then
    -- 变成小动物有问题，isblock还是true
                -- itemData:resetDatas()
                -- itemData.ItemType = GameItemType.kAnimal
                -- itemData._encrypt.ItemColorType = AnimalTypeConfig.kRandom
                -- itemData._encrypt.ItemColorType = mainLogic:randomColor()
                -- itemData.ItemSpecialType = 0
                -- itemData.isUsed = true
                -- itemData.isBlock = false
                -- itemData.isEmpty = false

                -- boardData:resetDatas()
                -- boardData.isBlock = false
                
                -- self.mainLogic.isBlockChange = true
                
                -- 变成云块吧。。。
                itemData.ItemType = GameItemType.kDigGround
                
                itemData.randomPropType = 0   -- 道具云块标记
                itemData.randomPropDropId = 0 -- 道具云块掉落的道具id
                itemData.randomPropLevel = 0 -- 道具云块等级，目前只有1级

                itemData.digGroundLevel = 1 
                itemData.isBlock = true 
                itemData.isEmpty = false

                newItemMap[i][col] = itemData
                newBoardMap[i][col] = boardData
            end
        end
     end
     return newItemMap, newBoardMap
end

--passedRow     已滚动过的行数
--additionRow   向下扩展的行数
function MaydayEndlessMode:getExtraMap(passedRow, additionRow)
    local itemMap = {}
    local boardMap = {}

    local rowCountUsingConfig = 0
    local rowCountUsingGenerator = 0

    -- 固定生成的行数
    -- local MaydayEndlessModeStartCopyLine = 20 --#self.mainLogic.digItemMap
    ---------------------- TEST -----------------------
    -- local MaydayEndlessModeStartCopyLine = 0 -- TEST
    ---------------------------------------------------
    local boundLine = (MaydayEndlessModeStartCopyLine - 9 )
    -- local boundLine = (MaydayEndlessModeStartCopyLine - 9)
    if passedRow + additionRow <= boundLine then -- all rows from config
        rowCountUsingConfig = additionRow
        rowCountUsingGenerator = 0
    elseif passedRow >= boundLine then -- all rows from generator
        rowCountUsingConfig = 0
        rowCountUsingGenerator = additionRow 
    else
        rowCountUsingConfig = boundLine - passedRow
        rowCountUsingGenerator = additionRow - rowCountUsingConfig
    end
    if _G.isLocalDevelopMode then printx(0, "@peng dig ","passedRow",passedRow,"additionRow",additionRow,"rowCountUsingConfig",rowCountUsingConfig,"rowCountUsingGenerator",rowCountUsingGenerator) end

    -- init row 1 to row 9
    local normalRowCount = #self.mainLogic.gameItemMap
    -- if _G.isLocalDevelopMode then printx(0, 'normalRowCount', normalRowCount) end
    for row = 1, normalRowCount do
        table.insert(itemMap, self.mainLogic.gameItemMap[row])
        table.insert(boardMap, self.mainLogic.boardmap[row])
    end

    -- 使用digmap 20行之前的配置
    if rowCountUsingConfig > 0 then
        -- if _G.isLocalDevelopMode then printx(0, 'using config') end
        for i = 1, rowCountUsingConfig do 
            local configRowIndex = passedRow + i
            table.insert(itemMap, self.mainLogic.digItemMap[configRowIndex])
            table.insert(boardMap, self.mainLogic.digBoardMap[configRowIndex])
            for c = 1, #self.mainLogic.digItemMap[configRowIndex] do 
                self.mainLogic.digItemMap[configRowIndex][c].y = i + normalRowCount
            end
            for c = 1, #self.mainLogic.digBoardMap[configRowIndex] do
                self.mainLogic.digBoardMap[configRowIndex][c].y = i + normalRowCount
            end
        end
    end

    -- 从20行开始生成
    if rowCountUsingGenerator > 0 then

        local newItemMap, newBoardMap = self:generateAdditionMap(passedRow, rowCountUsingGenerator)
        local genRowStartIndex = additionRow + normalRowCount - rowCountUsingGenerator

        for r = 1, #newItemMap do
            itemMap[r + genRowStartIndex] = {}
            boardMap[r+genRowStartIndex] = {}

            for c = 1, #newItemMap[r] do
                local item = newItemMap[r][c]
                local board = newBoardMap[r][c]
                -- if _G.isLocalDevelopMode then printx(0, "===>",item.isBlock,board.isBlock) end
                item.y = genRowStartIndex + r
                board.y = genRowStartIndex + r
                        
                -- if _G.isLocalDevelopMode then printx(0, "genRowStartIndex ",genRowStartIndex ,r,c) end
                itemMap[r + genRowStartIndex][c] = item
                boardMap[r+genRowStartIndex][c] = board

            end
        end
    end
    return itemMap, boardMap
end

-- -- 原有的滚动逻辑
-- function MaydayEndlessMode:getExtraMap(passedRow, additionRow)
--     local itemMap = {}
--     local boardMap = {}

--     local rowCountUsingConfig = 0
--     local rowCountUsingGenerator = 0

--     local totalAvailableConfigRowCount = #self.mainLogic.digItemMap
--     ---------------------- TEST -----------------------
--     -- local totalAvailableConfigRowCount = 0 -- TEST
--     ---------------------------------------------------

    
--     if passedRow + additionRow <= totalAvailableConfigRowCount then -- all rows from config
--         rowCountUsingConfig = additionRow
--         rowCountUsingGenerator = 0
--     elseif passedRow >= totalAvailableConfigRowCount then -- all rows from generator
--         rowCountUsingConfig = 0
--         rowCountUsingGenerator = additionRow 
--     else
--         rowCountUsingConfig = totalAvailableConfigRowCount - passedRow
--         rowCountUsingGenerator = additionRow - rowCountUsingConfig
--     end
--     if _G.isLocalDevelopMode then printx(0, "@peng dig ",passedRow,additionRow,rowCountUsingConfig,rowCountUsingGenerator) end

--     -- init row 1 to row 9
--     local normalRowCount = #self.mainLogic.gameItemMap
--     -- if _G.isLocalDevelopMode then printx(0, 'normalRowCount', normalRowCount) end
--     for row = 1, normalRowCount do
--         table.insert(itemMap, self.mainLogic.gameItemMap[row])
--         table.insert(boardMap, self.mainLogic.boardmap[row])
--     end

--     -- read config rows if available
--     if rowCountUsingConfig > 0 then
--         -- if _G.isLocalDevelopMode then printx(0, 'using config') end
--         for i = 1, rowCountUsingConfig do 
--             local configRowIndex = passedRow + i
--             table.insert(itemMap, self.mainLogic.digItemMap[configRowIndex])
--             table.insert(boardMap, self.mainLogic.digBoardMap[configRowIndex])
--             for c = 1, #self.mainLogic.digItemMap[configRowIndex] do 
--                 self.mainLogic.digItemMap[configRowIndex][c].y = i + normalRowCount
--             end
--             for c = 1, #self.mainLogic.digBoardMap[configRowIndex] do
--                 self.mainLogic.digBoardMap[configRowIndex][c].y = i + normalRowCount
--             end
--         end
--     end

--     if rowCountUsingGenerator > 0 then
--         local generatedItems = self:generateGroundRow(rowCountUsingGenerator)
--         local newItemRows = {}
--         local newBoardRows = {}
--         for i=1, rowCountUsingGenerator do 
--             newItemRows[i] = {}
--             newBoardRows[i] = {}
--         end


--         for k, v in pairs(generatedItems) do 
--             local item = GameItemData:create()
--             item:initByConfig(v)
--             local r = self.mainLogic:randomColor()
--             local colorIndex = AnimalTypeConfig.convertColorTypeToIndex(r)
--             item:initByAnimalDef(math.pow(2, colorIndex))
--             item:initBalloonConfig(self.mainLogic.balloonFrom)
--             item:initAddMoveConfig(self.mainLogic.addMoveBase)
--             if item.ItemType == GameItemType.kBoss then 
--                 if _G.isLocalDevelopMode then printx(0, item.bossLevel, item.blood) end
--             end

--             local board = GameBoardData:create()
--             board:initByConfig(v)

--             local rowIndex = math.ceil(k / 9)
--             local colIndex = k - (rowIndex - 1) * 9 
--             newItemRows[rowIndex][colIndex] = item
--             newBoardRows[rowIndex][colIndex] = board
--         end


--         local genRowStartIndex = additionRow + normalRowCount - rowCountUsingGenerator

--         for k1, itemRow in pairs(newItemRows) do 
--             table.insert(itemMap, itemRow)
--             for k2, col in pairs(itemRow) do 
--                 col.x = k2
--                 col.y = k1 + genRowStartIndex
--             end
--         end

--         for k1, boardRow in pairs(newBoardRows) do 
--             table.insert(boardMap, boardRow)
--             for k2, col in pairs(boardRow) do 
--                 col.x = k2
--                 col.y = k1 + genRowStartIndex
--             end
--         end
--     end

--     -- if _G.isLocalDevelopMode then printx(0, 'itemMap, boardMap', #itemMap, #boardMap) end
--     return itemMap, boardMap
-- end

function MaydayEndlessMode:checkScrollDigGround(stableScrollCallback)
    local maxDigGroundRow = self:getDigGroundMaxRow()
    local SCROLL_GROUND_MIN_LIMIT = 2
    local SCROLL_GROUND_MAX_LIMIT = 4

    if maxDigGroundRow <= SCROLL_GROUND_MIN_LIMIT and not self:hasBossOnMap() then
        local moveUpRow = SCROLL_GROUND_MAX_LIMIT - maxDigGroundRow
        
        -- 只滚动偶数行，避免boss被分割。boss只生成在偶数行
        if moveUpRow % 2 ~= 0 then 
            moveUpRow = moveUpRow - 1 
        end

        self:doScrollDigGround(moveUpRow, stableScrollCallback)
        return true
    end
    return false
end

function MaydayEndlessMode:doScrollDigGround(moveUpRow, stableScrollCallback)
    local extraItemMap, extraBoardMap = self:getExtraMap(self.mainLogic.passedRow, moveUpRow)
    local mainLogic = self.mainLogic
    local context = self
    context.moveBoforeScroll = 0

    local function scrollCallback()
        local newItemMap = {}
        local newBoardMap = {}
        for r = 1, 9 do
            local row = r + moveUpRow
            newItemMap[r] = {}
            newBoardMap[r] = {}
            for c = 1, 9 do
                local item = extraItemMap[row][c]:copy()
                local mimosaHoldGrid = item.mimosaHoldGrid
                item.mimosaHoldGrid = {}
                for k, v in pairs(mimosaHoldGrid) do 
                    v.x = v.x - moveUpRow
                    if v.x > 0 then
                        table.insert(item.mimosaHoldGrid, v)
                    end
                end
                item.y = r
                
                local board = extraBoardMap[row][c]:copy()
                local originalBoard = mainLogic.boardmap[r][c]

                board.y = r
                board:reinitTileMoveByScroll()
                board:reinitTransmissionLinkByScroll()
                
                newItemMap[r][c] = item
                newBoardMap[r][c] = board
                mainLogic:addNeedCheckMatchPoint(r, c)
            end
        end
        mainLogic.gameItemMap = nil
        mainLogic.gameItemMap = newItemMap
        mainLogic.boardmap = nil
        mainLogic.boardmap = newBoardMap

        mainLogic:updateScrollCannon()

        FallingItemLogic:preUpdateHelpMap(mainLogic)
        mainLogic.boardView:reInitByGameBoardLogic()
        mainLogic.boardView:showItemViewLayer()
        mainLogic.boardView:removeDigScrollView()

        if stableScrollCallback and type(stableScrollCallback) == "function" then
            stableScrollCallback()
        end

        --         for r = 1, 9 do
        --     for c = 1, 9 do
        --         local item = mainLogic.gameItemMap[r][c]
        --         local board = mainLogic.boardmap[r][c]
        --         if _G.isLocalDevelopMode then printx(0, "..........",item.isBlock,board.isBlock) end
        --     end
        -- end

    end

    self.mainLogic.passedRow = self.mainLogic.passedRow + moveUpRow
    self.mainLogic.boardView:hideItemViewLayer()
    local time, numExtraRow = self.mainLogic.boardView:scrollMoreDigView(extraItemMap, extraBoardMap, scrollCallback)
    
    if time and numExtraRow then
        if mainLogic.PlayUIDelegate then
            local gameBg = mainLogic.PlayUIDelegate.gameBgNode
            if gameBg and ScrollGameBg_V and gameBg:is(ScrollGameBg_V) then
                gameBg:startScroll(numExtraRow*70, time)
            end
        end
    end
end

--获得从含有挖地云块的第一层到最下一层的层数
function MaydayEndlessMode:getDigGroundMaxRow()
    local gameItemMap = self.mainLogic.gameItemMap
    for r = 1, #gameItemMap do
        for c = 1, #gameItemMap[r] do
            if gameItemMap[r][c].ItemType == GameItemType.kDigGround
                or gameItemMap[r][c].ItemType == GameItemType.kDigJewel
                or gameItemMap[r][c].ItemType == GameItemType.kRandomProp
                then
                return 10 - r
            end
        end
    end
    return 0
end

function MaydayEndlessMode:hasBossOnMap()
    local gameItemMap = self.mainLogic.gameItemMap
    for r = #gameItemMap, 1, -1 do -- 从最后一行开始，效率更高
        for c = 1, #gameItemMap[r] do 
            if gameItemMap[r][c].ItemType == GameItemType.kBoss 
            or gameItemMap[r][c].ItemType == GameItemType.kWeeklyBoss then 
                return true
            end
        end
    end
    return false
end

function MaydayEndlessMode:saveDataForRevert(saveRevertData)
    local mainLogic = self.mainLogic
    saveRevertData.passedRow = mainLogic.passedRow
    saveRevertData.digJewelCount = mainLogic.digJewelCount:getValue()
    saveRevertData.maydayBossCount = mainLogic.maydayBossCount
    MoveMode.saveDataForRevert(self,saveRevertData)
end

function MaydayEndlessMode:revertDataFromBackProp()
    local mainLogic = self.mainLogic
    mainLogic.passedRow = mainLogic.saveRevertData.passedRow
    mainLogic.digJewelCount:setValue(mainLogic.saveRevertData.digJewelCount)
    mainLogic.maydayBossCount = mainLogic.saveRevertData.maydayBossCount
    MoveMode.revertDataFromBackProp(self)
end

function MaydayEndlessMode:revertUIFromBackProp()
    local mainLogic = self.mainLogic
    if mainLogic.PlayUIDelegate then
        mainLogic.PlayUIDelegate:revertTargetNumber(0, 0, mainLogic.digJewelCount:getValue())
        mainLogic.PlayUIDelegate:revertTargetNumber(0, 2, mainLogic.maydayBossCount)
    end
    MoveMode.revertUIFromBackProp(self)
end

function MaydayEndlessMode:generateGroundRow(rowCount)

    local result = {}

    if rowCount <= 0 then return result end

    self.generatedRowCount = self.generatedRowCount + rowCount
    self.rowCountSinceLastAddMove = self.rowCountSinceLastAddMove + rowCount

    self:upgradeGround(rowCount)

    local genBossCount = self:getGenBossCount()
    local genJewelCount = self:getGenJewelCount(rowCount)
    local shouldAddMove = self:shouldAddMove()

    if _G.isLocalDevelopMode then printx(0, 'rowCount', rowCount) end
    if _G.isLocalDevelopMode then printx(0, 'generatedRowCount', self.generatedRowCount) end
    if _G.isLocalDevelopMode then printx(0, 'genBossCount', genBossCount) end
    if _G.isLocalDevelopMode then printx(0, 'genJewelCount', genJewelCount) end


    local length = 9 * rowCount
    local usableIndex = {}
    for i=1, length do
        table.insert(usableIndex, i)
    end
    local function removeUsableIndex(index)
        for k, v in pairs(usableIndex) do
            if v == index then
                table.remove(usableIndex, k)
            end
        end
    end


    for i = 1, genBossCount do 
        -- 永远是在倒数第二行生成boss，每行最后一个格子不能生成
        local selector = self.mainLogic.randFactory:rand(length - 17, length - 10)
        local index = usableIndex[selector]
        result[index]         = self:getBossTileDef()
        result[index + 1]     = self:getBossEmptyTileDef()
        result[index + 9]     = self:getBossEmptyTileDef()
        result[index + 10]    = self:getBossEmptyTileDef()
        removeUsableIndex(index)
        removeUsableIndex(index+1)
        removeUsableIndex(index+9)
        removeUsableIndex(index+10)
    end
    -- generate add_move
    if shouldAddMove then
        local selector = self.mainLogic.randFactory:rand(1, #usableIndex)
        local index = usableIndex[selector]
        removeUsableIndex(index)
        result[index] = self:getAddMoveTileDef()
    end

    -- generate jewel
    local maxIndex = math.min(genJewelCount, #usableIndex)
    for i = 1, maxIndex do
        local selector = self.mainLogic.randFactory:rand(1, #usableIndex)
        local index = usableIndex[selector]
        removeUsableIndex(index)
        result[index] = self:getJewelTileDef(index)
    end

    for i=1, length do 
        if result[i] == nil then 
            result[i] = self:getGroundTileDef(i)
        end
    end

    return result

end

function MaydayEndlessMode:shouldAddMove()
    if self.mainLogic.levelType == GameLevelType.kSummerWeekly then
        return false
    end

    if self.rowCountSinceLastAddMove >= generate_add_move_interval then
        self.rowCountSinceLastAddMove = self.rowCountSinceLastAddMove - generate_add_move_interval
        return true
    else 
        return false
    end
end

function MaydayEndlessMode:getMaxJewelPerTwoRows()
    local maxJewel = initial_max_jewel + math.floor(self.generatedRowCount / add_max_jewel_interval)
    return math.min(maxJewel, max_jewel_limit)
end

function MaydayEndlessMode:upgradeGround(rowCount)
    self.rowCountSinceLastGroundUpgrade = self.rowCountSinceLastGroundUpgrade + rowCount
    if self.rowCountSinceLastGroundUpgrade >= ground_upgrade_interval then

        local counter  = 0
        local length = 9 * max_generate_row
        local level2_count = 0
        local level3_count = 0


        -- 限制每两行生成的各级云层数量。。。。。
        for i=1, length do 
            if self.groundPool[i] == 2 then
                level2_count = level2_count + 1
            elseif self.groundPool[i] == 3 then
                level3_count = level3_count + 1
            end
        end
        if level2_count >= max_level2_count and level3_count >= max_level3_count then
            return
        end

        while counter <= length do
            counter = counter + 1
            local selector = self.mainLogic.randFactory:rand(1, length)
            if (self.groundPool[selector] == 1 and level2_count < max_level2_count)
            or (self.groundPool[selector] == 2 and level3_count < max_level3_count) then
                self.groundPool[selector] = self.groundPool[selector] + 1
                break
            end
        end
        self.rowCountSinceLastGroundUpgrade = self.rowCountSinceLastGroundUpgrade - ground_upgrade_interval
    end
end

function MaydayEndlessMode:getGenBossCount()
    local genBossTimes = math.floor(self.generatedRowCount / generate_boss_interval)
    -- if _G.isLocalDevelopMode then printx(0, 'genBossTimes', genBossTimes, self.lastGenBossTimes) end
    if genBossTimes > self.lastGenBossTimes then
        self.lastGenBossTimes = genBossTimes
        return 1
    else
        return 0
    end
end

function MaydayEndlessMode:getGenJewelCount(rowCount)
    local genJewelTimes = math.floor(self.generatedRowCount / generate_jewel_interval)
    -- if _G.isLocalDevelopMode then printx(0, 'genJewelTimes', genJewelTimes, self.lastGenJewelTimes) end
    -- if genJewelTimes > self.lastGenJewelTimes then
    --     local diff = genJewelTimes - self.lastGenJewelTimes
    --     self.lastGenJewelTimes = genJewelTimes
    --     return self:getMaxJewelPerTwoRows(rowCount) * diff
    -- end
    -- return 0
    local result = self:getMaxJewelPerTwoRows(rowCount) / 2 * rowCount
    return result
end

function MaydayEndlessMode:getAddMoveTileDef()
    -- add_move + animal
    local tileDef = TileMetaData.new()
    tileDef:addTileData(TileConst.kAddMove)
    tileDef:addTileData(TileConst.kAnimal)
    return tileDef
end

function MaydayEndlessMode:getGroundTileDef(index)
    if index > 9*max_generate_row then
        index = index % (9*max_generate_row)
    end
    local level = self.groundPool[index] or 1
    local tileDef = TileMetaData.new()
    tileDef:addTileData(TileConst.kDigGround)
    tileDef:addTileData(TileConst.kBlocker)
    if level == 1 then
        tileDef:addTileData(TileConst.kDigGround_1)
    elseif level == 2 then
        tileDef:addTileData(TileConst.kDigGround_2)
    elseif level == 3 then
        tileDef:addTileData(TileConst.kDigGround_3)
    end
    return tileDef
end

function MaydayEndlessMode:getJewelTileDef(index)
    if index > 9*max_generate_row then
        index = index % (9*max_generate_row)
    end
    local level = self.groundPool[index] or 1
    local tileDef = TileMetaData.new()
    -- if _G.isLocalDevelopMode then printx(0, 'level', level) end
    tileDef:addTileData(TileConst.kBlocker)
    if level == 1 then
        tileDef:addTileData(TileConst.kDigJewel_1_blue)
    elseif level == 2 then
        tileDef:addTileData(TileConst.kDigJewel_2_blue)
    elseif level == 3 then
        tileDef:addTileData(TileConst.kDigJewel_3_blue)
    end
    return tileDef
end

function MaydayEndlessMode:getBossTileDef()
    local tileDef = TileMetaData.new()
    tileDef:addTileData(TileConst.kBlocker)
    tileDef:addTileData(TileConst.kMayDayBlocker4)
    return tileDef
end

function MaydayEndlessMode:getBossEmptyTileDef()
    local tileDef = TileMetaData.new()
    tileDef:addTileData(TileConst.kBlocker)
    tileDef:addTileData(TileConst.kMaydayBlockerEmpty)
    return tileDef
end

function MaydayEndlessMode:initBossBlood()
    local gameItemMap = self.mainLogic.gameItemMap
    for r = 1, #gameItemMap do
        for c = 1, #gameItemMap[r] do
            local item = gameItemMap[r][c]
            if item.ItemType == GameItemType.kBoss and item.bossLevel > 0 then
                item.blood = 10
            end
        end
    end
end

function MaydayEndlessMode:useMove()
    MoveMode.useMove(self)
    self.moveBoforeScroll = self.moveBoforeScroll + 1 
end

function MaydayEndlessMode:onEnterWaitingState()
   if self.mainLogic and self.mainLogic.PlayUIDelegate then
        --移动五步未滚屏
        if self.moveBoforeScroll < 5 then return end
        --大招储能>50% <100%
        local rightPropList = self.mainLogic.PlayUIDelegate.propList.rightPropList
        local springItem = rightPropList.springItem
        if not springItem or not springItem.percent or springItem.percent < 0.5 or springItem.percent >= 1 then return end
        --当前屏幕有boss
        local gameItemMap = self.mainLogic.gameItemMap
        for r = 1, #gameItemMap do
            for c = 1, #gameItemMap[r] do
                if gameItemMap[r][c].ItemType == GameItemType.kBoss and gameItemMap[r][c].bossLevel > 0  then
                    self.mainLogic.PlayUIDelegate:playFirstBuyFirewordGuide() 
                    break
                end
            end
        end
    end
end