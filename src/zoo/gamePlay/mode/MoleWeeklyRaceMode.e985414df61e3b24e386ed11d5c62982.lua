require "zoo.config.MoleWeeklyRaceConfig"
require "zoo.config.LevelDropPropConfig"
MoleWeeklyRaceMode = class(MoveMode)

--最老版额外地图生成逻辑已清理
--寻找历史遗迹可移步 HedgehogDigEndlessMode WukongMode MaydayEndlessMode 等（未考古验证，仅提供线索）

function MoleWeeklyRaceMode:initModeSpecial(config)
    self.mainLogic.digJewelCount = DigJewelCount.new()
    self.mainLogic.yellowDiamondCount = YellowDiamondCount.new()
    self.mainLogic.maydayBossCount = 0
    self.mainLogic.magicTileDemolishedNum = 0

    self.bossGenRowCountDown = 0

    -- 两周年活动新生成模式
    self.generationPoolSize = 16 --每次找出两屏
    self.generationDigItemMap = {}
    self.generationDigBoardMap = {}
    self.digItemMapReadCursor = MoleWeeklyRaceParam.DIG_GENERATE_CIRCLE_START_ROW
    self.digBoardMapReadCursor = MoleWeeklyRaceParam.DIG_GENERATE_CIRCLE_START_ROW
    self.generationPoolCursor = 1
    -- 两周年活动新生成模式 end

    -- 鼹鼠周赛特有
    self.firstLaySeedStep = -1              --第一次扔种子时的步数
    self.lastSeedCountdownStep = -1         --上次结算种子时的步数
    self.lastMagicTileResetStep = -1         --上次结算魔法地格的步数（因为魔法地格的处理移到了大循环中，所以用标记保证每步只处理一次）
    
    self.mainLogic:updateAllMagicTiles()
    self.mainLogic.passedRow = 0

    self.inBossGenerateTmp = false          --临时参数，boss第一屏出现用
    self.propReleasedBeforeBonus = false    --临时参数，结算前释放了道具大招

    self.moveBoforeScroll = 0


    self.BossHitStep = 0--BOSS走的步数 5步后进行引导判断重置为0

    MoleWeeklyRaceConfig:resetConfig()

    self:InitTodayDailyInfo() --增加周赛每日数据
    -- printx(11, "+++++++++ init MoleWeeklyRaceMode +++++++++")
end

function MoleWeeklyRaceMode:onGameInit()


    if self.mainLogic.replayMode == ReplayMode.kNone then
        ReplayDataManager:updateRankRaceContext(nil, {
            levelIndex = RankRaceMgr:getInstance():getLevelIndex(),
        })
    end


    local context = self

    local function realStartGame()
        self:onStartGame()
    end

    local function playBigSkillAnim()
        local instance = RankRaceMgr:getExistedInstance()
        if instance then
            local bIsCanShowSkillGuide = instance.data:getIsShowSkillGuide()
            if bIsCanShowSkillGuide then

                --大招初始动画
                local level = self.mainLogic:getMoleWeeklyBossData().bossGroupID

                local percent = 0
                local playUI = Director:sharedDirector():getRunningScene()
	            if playUI and playUI.propList then
		            local springItem = playUI.propList:findSpringItem()

                    if springItem then
                        percent = springItem:getPropSkillConfig().preFillPercent*100
                    end
                end
                percent = math.ceil2( percent )

                if level ~= 1 then
                    self.mainLogic.PlayUIDelegate:PlayInitPowerAnim( level, percent )--初始充能动画播放
                    --
                    instance.data:setIsShowSkillGuide( false )
                end

                self:onStartGame()
            else
                self:onStartGame()
            end
        else
            self:onStartGame()
        end
    end

    local function setGameStart()
        context.mainLogic:setGamePlayStatus(GamePlayStatus.kNormal)
        context.mainLogic.boardView:showItemViewLayer()
        context.mainLogic.boardView:removeDigScrollView()
        context.mainLogic.boardView.isPaused = false
        context.mainLogic.fsm:initState()

        self:_tryGenerateBoss(playBigSkillAnim)
        -- self:onStartGame()
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

    self.mainLogic:updateAllMagicTiles(extraBoardMap)
    -- if _G.isLocalDevelopMode then printx(0, 'extraItemMap', #extraItemMap, 'extraBoardMap', #extraBoardMap) end

    --从第20行开始向上滚动
    local first20ItemMap = {}
    local first20BoardMap = {}
    for i=1,math.min(20,#extraItemMap) do
        table.insert(first20ItemMap,extraItemMap[i])
        table.insert(first20BoardMap,extraBoardMap[i])
    end

    self.mainLogic.boardView:initDigScrollView(first20ItemMap, first20BoardMap)
    self.mainLogic.boardView:hideItemViewLayer()
    
    if self.mainLogic.PlayUIDelegate then
        self.mainLogic.PlayUIDelegate:playLevelTargetPanelAnim(playDigScrollAnimation)
    else
        playDigScrollAnimation()
    end
    self.mainLogic:stopWaitingOperation()
end

------------------------------------ Ending ------------------------------------
function MoleWeeklyRaceMode:reachEndCondition()
    return MoveMode.reachEndCondition(self)
end

function MoleWeeklyRaceMode:reachTarget()
    return false
end

function MoleWeeklyRaceMode:afterFail()
    -- printx(11, "----------- = = = * * * afterFail * * * = = = -----------")
    if _G.isLocalDevelopMode then printx(0, 'MoleWeeklyRaceMode:afterFail') end

    local mainLogic = self.mainLogic
    local Instance = self
    local function tryAgainWhenFailed(isTryAgain, propId, deltaStep)   ----确认加5步之后，修改数据
        if isTryAgain then
            Instance:addStepSucess()
        else
            if MoveMode.reachEndCondition(Instance) then
                Instance.leftMoveToWin = Instance.theCurMoves

                if mainLogic.isFullFirework then
                    Instance.propReleasedBeforeBonus = true

                    -- 关卡大招使用情况打点
                    local boss = mainLogic:getMoleWeeklyBossData()
                    local bossHP = 0
                    if boss then
                        bossHP = boss.totalBlood - boss.hit
                    end

                    local dcData = {
	                    game_type = "stage",
	                    game_name = "",
	                    category = "weeklyrace2018",
	                    sub_category = "weeklyrace2018_use_skill",
	                    t1 = mainLogic.level,
	                    t2 = bossHP,
                        t3 = 3,
                    }
                    DcUtil:activity(dcData)

                    mainLogic:useMegaPropSkill(false, true, true, true)
                else
                    Instance:enterRealBonusState()
                end
            else
                mainLogic:setGamePlayStatus(GamePlayStatus.kFailed)
            end
        end
    end 
    if mainLogic.PlayUIDelegate then
        mainLogic.PlayUIDelegate:addStep(mainLogic.level, mainLogic.totalScore, self:getScoreStarLevel(), self:reachTarget(), tryAgainWhenFailed)
    end
end

function MoleWeeklyRaceMode:addStepSucess()
    local mainLogic = self.mainLogic
    local Instance = self

    local function BoomEndCallback()
        Instance:getAddSteps(deltaStep or 5)

        --Boss死亡
        if mainLogic.PlayUIDelegate and mainLogic.PlayUIDelegate.bossBeeController then
            local BossData = mainLogic:getMoleWeeklyBossData()
            if BossData then
                mainLogic.PlayUIDelegate:setRainbowPercent(0)
				mainLogic.PlayUIDelegate.bossBeeController:playHit( nil, 0, BossData.totalBlood-BossData.hit )
            end
		end
        MoleWeeklyRaceLogic:demolishBossImmediately( mainLogic )

        self:playBombAll()
    end

    Instance:playBombAnimation(BoomEndCallback)
end

function MoleWeeklyRaceMode:playBombAll()
    local mainLogic = self.mainLogic
    --全屏爆炸不计大招能量
    if mainLogic and not mainLogic.isDisposed then
        mainLogic.forbidChargeFirework = true
    end

    --全屏爆炸
    mainLogic:setGamePlayStatus(GamePlayStatus.kNormal)
    mainLogic.fsm:changeState(mainLogic.fsm.fallingMatchState)
    local action = GameBoardActionDataSet:createAs(
            GameActionTargetType.kGameItemAction,
            GameItemActionType.kMoleWeekly_Bomb_All,
            IntCoord:create(2, 1),
            IntCoord:create(9, 9),
            GamePlayConfig_MaxAction_time
        )
    mainLogic:addDestructionPlanAction(action)
    mainLogic:setNeedCheckFalling()
end

function MoleWeeklyRaceMode:playBombAnimation(callback)
    local winSize = Director:sharedDirector():getWinSize()
    local vs = Director:sharedDirector():getVisibleSize()
    local vo = Director:sharedDirector():getVisibleOrigin()
    local scene = Director:sharedDirector():getRunningScene()

    local container = Layer:create()
    container:setTouchEnabled(true, 0, true)
    scene:addChild(container)

    local oriDeltaY = 50
    local greyCover = LayerColor:create()
    greyCover:setColor(ccc3(0,0,0))
    greyCover:setOpacity(150)
    greyCover:setContentSize(CCSizeMake(winSize.width, winSize.height + oriDeltaY*2))
    greyCover:setPosition(ccp(0 ,  -oriDeltaY))
    container:addChild(greyCover)

    setTimeOut(function ()
        GamePlayMusicPlayer:playEffect(GameMusicType.kSwapColorColorCleanAll)
    end, 0.5)
    
    local anim = gAnimatedObject:createWithFilename('gaf/weekly_2018s1/bomb_add_step/bomb_add_step.gaf')
    anim:setPosition(ccp(vo.x + vs.width / 2 - 365, vo.y + vs.height/2 + 700))

    local function finishCallback( ... )
        if container then
            container:removeFromParentAndCleanup(true)
            container = nil
        end
        if callback then
            callback()
        end
    end

    local function lionEfinish()

        anim:setSequenceDelegate('shake', finishCallback)
        anim:playSequence("shake", false, true, ASSH_RESTART)
        anim:start()


        local scene = Director:sharedDirector():getRunningScene()
        local arr = CCArray:create()
        local oriMoveTime = 0.04
        arr:addObject(CCEaseSineOut:create(CCMoveBy:create(oriMoveTime, ccp(0, oriDeltaY))))
        arr:addObject(CCEaseSineIn:create(CCMoveBy:create(oriMoveTime, ccp(0, -oriDeltaY))))
        arr:addObject(CCEaseSineOut:create(CCMoveBy:create(oriMoveTime, ccp(0, -oriDeltaY))))
        arr:addObject(CCEaseSineIn:create(CCMoveBy:create(oriMoveTime, ccp(0, oriDeltaY))))
        arr:addObject(CCEaseSineOut:create(CCMoveBy:create(oriMoveTime/2, ccp(0, oriDeltaY/2))))
        arr:addObject(CCEaseSineIn:create(CCMoveBy:create(oriMoveTime/2, ccp(0, -oriDeltaY/2))))
        arr:addObject(CCEaseSineOut:create(CCMoveBy:create(oriMoveTime/2, ccp(0, -oriDeltaY/2))))
        arr:addObject(CCEaseSineIn:create(CCMoveBy:create(oriMoveTime/2, ccp(0, oriDeltaY/2))))
        scene:runAction(CCSequence:create(arr))
    end

    anim:setSequenceDelegate('normal', lionEfinish, true)
    anim:playSequence("normal", false, true, ASSH_RESTART)
    anim:start()

    container:addChild(anim)
end

function MoleWeeklyRaceMode:enterRealBonusState()
    self.propReleasedBeforeBonus = false
    self.mainLogic:setGamePlayStatus(GamePlayStatus.kBonus)
end

function MoleWeeklyRaceMode:getScoreStarLevel(...)
    local starlevel = 1
    if MoleWeeklyRaceLogic:fullfillStageExtraRequirements(self.mainLogic) then
        starlevel = 3
    end
    return starlevel
end

------------------------------------ Generate boss ------------------------------------
function MoleWeeklyRaceMode:_tryGenerateBoss(callBack)
    -- printx(11, "= = = * * * _tryGenerateBoss * * * = = =")
    local boss = self.mainLogic:getMoleWeeklyBossData()
    if not boss then
        self.inBossGenerateTmp = true
        local function completeCallback()
            -- printx(11, "= = = Real Gen = = =")
            if not self.firstBoss then
                self.firstBoss = true
                local guideTilePos = self:getGuideTilePos()
                if guideTilePos then
                    GameGuide:sharedInstance():onHalloweenBossFirstComeout(guideTilePos)
                end
            end
            self.inBossGenerateTmp = false
            if callBack then callBack() end
        end

        if _G.isLocalDevelopMode then printx(0, 'gen boss') end
        local action = GameBoardActionDataSet:createAs(
                GameActionTargetType.kGameItemAction,
                GameItemActionType.kItem_MoleWeekly_Boss_Create,
                nil,
                nil,
                GamePlayConfig_MaxAction_time
            )
        action.completeCallback = completeCallback
        -- self.mainLogic:addGameAction(action)
        self.mainLogic:addGlobalCoreAction(action)
    else
        if callBack then callBack() end
    end
end

function MoleWeeklyRaceMode:getGuideTilePos()
    local boardmap = self.mainLogic.boardmap
    for r = 1, #boardmap do
        if boardmap[r] then
            for c = 1, #boardmap[r] do
                local item = boardmap[r][c]
                if item and item.isMagicTileAnchor then
                    local pos = {r = r, c = c}
                    return pos
                end
            end
        end
    end
end

------------------------------------ Boss Die ------------------------------------
function MoleWeeklyRaceMode:onBossDie()
    -- local leftGroundRow = self:getDigGroundMaxRow()
    -- self.bossGenRowCountDown = 5 - leftGroundRow
    self.bossGenRowCountDown = MoleWeeklyRaceParam.BOSS_REGENERATE_ROW_COUNT
    --printx(11, "============ BOSS DIE!! ========== leftGroundRow, genRow", leftGroundRow, self.bossGenRowCountDown)
    if _G.isLocalDevelopMode then printx(0, "MoleWeeklyRaceMode:onBossDie, bossGenRowCountDown=", self.bossGenRowCountDown) end
end

------------------------------------ Scroll ------------------------------------
function MoleWeeklyRaceMode:checkScrollDigGround(stableScrollCallback)
    local maxDigGroundRow = self:getDigGroundMaxRow()

    if maxDigGroundRow <= MoleWeeklyRaceParam.SCROLL_GROUND_MIN_LIMIT then
        local moveUpRow = MoleWeeklyRaceParam.SCROLL_GROUND_MAX_LIMIT - maxDigGroundRow
        moveUpRow = math.floor(moveUpRow / 2) * 2   --因为特殊区域的关系，只滚动偶数行

        local function __stableCallback()
            if stableScrollCallback then
                stableScrollCallback()
            end
        end

        local function localCallback()
            self.mainLogic:updateAllMagicTiles()
            self:_tryGenerateBoss(__stableCallback)
        end
        self:doScrollDigGround(moveUpRow, localCallback)
        return true
    end
    return false
end

--获得从含有挖地云块的第一层到最下一层的层数
function MoleWeeklyRaceMode:getDigGroundMaxRow()
    local gameItemMap = self.mainLogic.gameItemMap
    for r = 1, #gameItemMap do
        for c = 1, #gameItemMap[r] do
            local gameItem = gameItemMap[r][c]
            if gameItem and MoleWeeklyRaceLogic:isCloudLikeItem(gameItem.ItemType) then
                return 10 - r
            end
        end
    end
    return 0
end

function MoleWeeklyRaceMode:doScrollDigGround(moveUpRow, stableScrollCallback)
    -- if _G.isLocalDevelopMode then printx(0, 'moveUpRow', moveUpRow) end debug.debug()
    local extraItemMap, extraBoardMap = self:getExtraMap(self.mainLogic.passedRow, moveUpRow)
    for k, v in pairs(extraItemMap) do
        if _G.isLocalDevelopMode then printx(0, 'row', k) end
    end
    local mainLogic = self.mainLogic
    local context = self
    context.moveBoforeScroll = 0
    -- printx(11, "========= ScrollDigGround startRow: =========", mainLogic.boardView.startRowIndex)

    local bossGenerated = false
    local function scrollCallback()
        local newItemMap = {}
        local newBoardMap = {}
        for r = 1, 9 do
            local row = r + moveUpRow
            newItemMap[r] = {}
            newBoardMap[r] = {}
            for c = 1, 9 do
                local item = extraItemMap[row][c]:copy()
                local tileDef = TileMetaData.new()
                tileDef:addTileData(TileConst.kEmpty)
                if r < mainLogic.boardView.startRowIndex then 
                    item = GameItemData:create() 
                    item:initByConfig(tileDef)
                end
                
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
                -- if r < mainLogic.boardView.startRowIndex and item.magicTileId ~= nil then 
                if r < mainLogic.boardView.startRowIndex then 
                    board = GameBoardData:create() 
                    board:initByConfig(tileDef)
                    board.isUsed = false
                end
                board.y = r
                if mainLogic.boardmap[row] and mainLogic.boardmap[row][c] then
                    board.isProducer = mainLogic.boardmap[row][c].isProducer
                    board.theGameBoardFallType = table.clone(mainLogic.boardmap[row][c].theGameBoardFallType)
                end
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
    end

    local genBoss = (self.mainLogic:getMoleWeeklyBossData() == nil)

    if genBoss and not self.inBossGenerateTmp then
        if _G.isLocalDevelopMode then printx(0, 'genBoss self.bossGenRowCountDown', self.bossGenRowCountDown) end
        if self.bossGenRowCountDown <= moveUpRow then
            bossGenerated = true
        else
            self.bossGenRowCountDown = self.bossGenRowCountDown - moveUpRow
        end
    end

    self.mainLogic.passedRow = self.mainLogic.passedRow + moveUpRow
    self.mainLogic.boardView:hideItemViewLayer()
    self.mainLogic.boardView:scrollMoreDigView(extraItemMap, extraBoardMap, scrollCallback)
end

function MoleWeeklyRaceMode:getExtraMap(passedRow, additionRow)
    if _G.isLocalDevelopMode then printx(0, 'passedRow, additionRow', passedRow, additionRow, '#self.mainLogic.digItemMap', #self.mainLogic.digItemMap, '#self.mainLogic.gameItemMap', #self.mainLogic.gameItemMap) end
    -- debug.debug()
    local itemMap = {}
    local boardMap = {}

    local rowCountUsingConfig = 0
    local rowCountUsingGenerator = 0

    local totalAvailableConfigRowCount = #self.mainLogic.digItemMap
    ---------------------- TEST -----------------------
    -- local totalAvailableConfigRowCount = 0 -- TEST
    ---------------------------------------------------

    if passedRow + additionRow <= totalAvailableConfigRowCount then -- all rows from config
        rowCountUsingConfig = additionRow
        rowCountUsingGenerator = 0
    elseif passedRow >= totalAvailableConfigRowCount then -- all rows from generator
        rowCountUsingConfig = 0
        rowCountUsingGenerator = additionRow 
    else
        rowCountUsingConfig = totalAvailableConfigRowCount - passedRow
        rowCountUsingGenerator = additionRow - rowCountUsingConfig
    end

    -- init row 1 to row 9
    local normalRowCount = #self.mainLogic.gameItemMap
    -- if _G.isLocalDevelopMode then printx(0, 'normalRowCount', normalRowCount) end
    for row = 1, normalRowCount do
        table.insert(itemMap, self.mainLogic.gameItemMap[row])
        table.insert(boardMap, self.mainLogic.boardmap[row])
    end

    -- read config rows if available
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

    if rowCountUsingGenerator > 0 then
        local newItemRows, newBoardRows = self:generateGroundRow(rowCountUsingGenerator)
        local genRowStartIndex = additionRow + normalRowCount - rowCountUsingGenerator

        if _G.isLocalDevelopMode then printx(0, 'newItemRows', #newItemRows, 'newBoardRows', #newBoardRows) end

        for k1, itemRow in pairs(newItemRows) do 
            table.insert(itemMap, itemRow)
            for k2, col in pairs(itemRow) do 
                col.x = k2
                col.y = k1 + genRowStartIndex
            end
        end

        for k1, boardRow in pairs(newBoardRows) do 
            table.insert(boardMap, boardRow)
            for k2, col in pairs(boardRow) do 
                col.x = k2
                col.y = k1 + genRowStartIndex
            end
        end
    end

    -- if _G.isLocalDevelopMode then printx(0, 'itemMap, boardMap', #itemMap, #boardMap) end
    return itemMap, boardMap
end

function MoleWeeklyRaceMode:generateGroundRow(rowCount)
    local newItemMap, newBoardMap = {}, {}
    if rowCount <= 0 then return newItemMap, newBoardMap end

    if _G.isLocalDevelopMode then printx(0, 'rowCount', rowCount) end
    for i = 1, rowCount do
        if self.generationPoolCursor > self.generationPoolSize or not self.poolInited then
            self:initGenerationPool()
            self.poolInited = true
        end
        if _G.isLocalDevelopMode then printx(0, 'generationPoolCursor', self.generationPoolCursor) end
        table.insert(newItemMap, self.generationDigItemMap[self.generationPoolCursor])
        table.insert(newBoardMap, self.generationDigBoardMap[self.generationPoolCursor])
        self.generationPoolCursor = self.generationPoolCursor + 1
    end
    return newItemMap, newBoardMap
end

function MoleWeeklyRaceMode:initGenerationPool()
    if _G.isLocalDevelopMode then printx(0, 'initGenerationPool') end
    -- if self.generationPoolCursor <= self.generationPoolSize then
    --     return
    -- end

    self.generationPoolCursor = 1
    self.generationDigItemMap = {}
    self.generationDigBoardMap = {}
    local templateDigItemMap = self:readDigItemMap(self.generationPoolSize)
    local templateDigBoardMap = self:readDigBoardMap(self.generationPoolSize)

    if _G.isLocalDevelopMode then printx(0, 'templateDigItemMap', #templateDigItemMap) end

    for cycle = 1, 4 do
        local itemMap = {}
        local boardMap = {}
        for index = 1, 4 do
            local cursor = (cycle-1)*4+index
            local copyItemRow = {}
            for i = 1, 9 do
                local copyItem = templateDigItemMap[cursor][i]:copy()
                table.insert(copyItemRow, copyItem)
            end
            table.insert(itemMap, copyItemRow)

            local copyBoardRow = {}
            for i = 1, 9 do
                local copyItem = templateDigBoardMap[cursor][i]:copy()
                table.insert(copyBoardRow, copyItem)
            end
            table.insert(boardMap, copyBoardRow)
        end

        -- self:generateVariousThings(itemMap, boardMap)

        for i = 1, 4 do
            table.insert(self.generationDigItemMap, itemMap[i])
            table.insert(self.generationDigBoardMap, boardMap[i])
        end
    end
    -- if _G.isLocalDevelopMode then printx(0, 'start..................') end
    -- for r = 1, 16 do
    --     if _G.isLocalDevelopMode then printx(0, 'row no.', r) end
    --     for c = 1, 9 do
    --         if _G.isLocalDevelopMode then printx(0, self.generationDigItemMap[r][c].ItemType) end
    --     end
    --     if _G.isLocalDevelopMode then printx(0, 'row end') end
    -- end
    -- if _G.isLocalDevelopMode then printx(0, 'end...............') end

    if _G.isLocalDevelopMode then printx(0, 'self.generationDigItemMap', #self.generationDigItemMap) end
    if _G.isLocalDevelopMode then printx(0, 'self.generationDigBoardMap', #self.generationDigBoardMap) end
end

function MoleWeeklyRaceMode:readDigItemMap(rowCount)
    local ret = {}
    for i = 1, rowCount do
        if self.digItemMapReadCursor > #self.mainLogic.digItemMap then
            self.digItemMapReadCursor = MoleWeeklyRaceParam.DIG_GENERATE_CIRCLE_START_ROW
        end
        table.insert(ret, self.mainLogic.digItemMap[self.digItemMapReadCursor])
        self.digItemMapReadCursor = self.digItemMapReadCursor + 1
    end
    return ret
end

function MoleWeeklyRaceMode:readDigBoardMap(rowCount)
    local ret = {}
    for i = 1, rowCount do
        if self.digBoardMapReadCursor > #self.mainLogic.digBoardMap then
            self.digBoardMapReadCursor = MoleWeeklyRaceParam.DIG_GENERATE_CIRCLE_START_ROW
        end
        table.insert(ret, self.mainLogic.digBoardMap[self.digBoardMapReadCursor])
        self.digBoardMapReadCursor = self.digBoardMapReadCursor + 1
    end
    return ret
end

---------------------------------------------- Revert (闪退恢复) -----------------------------------------
function MoleWeeklyRaceMode:saveDataForRevert(saveRevertData)
    -- printx(11, "= = = = = saveDataForRevert . . . MoleWeeklyRaceMode")

    local mainLogic = self.mainLogic
    saveRevertData.passedRow = mainLogic.passedRow
    saveRevertData.digJewelCount = mainLogic.digJewelCount:getValue()
    saveRevertData.yellowDiamondCount = mainLogic.yellowDiamondCount:getValue()
    saveRevertData.maydayBossCount = mainLogic.maydayBossCount
    saveRevertData.magicTileDemolishedNum = mainLogic.magicTileDemolishedNum

    -- 道具大招数据
    saveRevertData.fireworkEnergy = mainLogic.fireworkEnergy
    saveRevertData.isFullFirework = mainLogic.isFullFirework

    -- mode数据
    saveRevertData.moleWeeklyModeData = {}
    saveRevertData.moleWeeklyModeData.bossGenRowCountDown = self.bossGenRowCountDown
    saveRevertData.moleWeeklyModeData.digItemMapReadCursor = self.digItemMapReadCursor
    saveRevertData.moleWeeklyModeData.digBoardMapReadCursor = self.digBoardMapReadCursor
    saveRevertData.moleWeeklyModeData.generationPoolCursor = self.generationPoolCursor
    saveRevertData.moleWeeklyModeData.firstLaySeedStep = self.firstLaySeedStep
    saveRevertData.moleWeeklyModeData.lastSeedCountdownStep = self.lastSeedCountdownStep
    saveRevertData.moleWeeklyModeData.lastMagicTileResetStep = self.lastMagicTileResetStep
    -- mainLogic.gameMode.poolInited    -- 应该不用加？
    saveRevertData.moleWeeklyModeData.firstBoss = firstBoss

    -- 配置数据
    MoleWeeklyRaceMode:saveConfigFromSectionResume(saveRevertData)
    -- printx(11, "Save to Data: moleWeeklyModeData, BossNo:", table.tostring(saveRevertData.moleWeeklyRaceConf.specialSkillBossNo))

    -- boss数据
    local moleBossData = mainLogic:getMoleWeeklyBossData()
    if moleBossData then
        saveRevertData.moleBossData = {}
        for k, _ in pairs(moleBossData) do
            saveRevertData.moleBossData[k] = moleBossData[k]
        end
    end

    MoveMode.saveDataForRevert(self, saveRevertData)
end

function MoleWeeklyRaceMode:saveConfigFromSectionResume(saveRevertData)
    --配置不会变，初始化一次就能存了
    if MoleWeeklyRaceConfig:hasSavedConfig() then
        saveRevertData.moleWeeklyRaceConf = MoleWeeklyRaceConfig:getConfigData()    --读取的是回放中的配置，格式正确，不用重构
    else
        if not self.configForSaveData then --第一次，转化出接受的格式存储
            local config = MoleWeeklyRaceConfig:getConfigData()

            local function copyTable(targetTable, newTable)
                local newTable = {}
                for k, v in pairs(targetTable) do
                    if type(v) == "table" and k ~= "class" then
                        newTable[k] = copyTable(v)
                    else
                        if k ~= "declare" and k ~= "class" then
                            newTable[k] = v
                        end
                    end
                end
                return newTable
            end

            self.configForSaveData = copyTable(config)
            -- printx(11, "configForSaveData copied: BossNo:", table.tostring(self.configForSaveData.specialSkillBossNo))
        end
        saveRevertData.moleWeeklyRaceConf = self.configForSaveData
    end
end

function MoleWeeklyRaceMode:revertDataFromBackProp()
    -- printx(11, "+ + + + + revertDataFromBackProp . . . MoleWeeklyRaceMode")
    local mainLogic = self.mainLogic
    local saveRevertData = mainLogic.saveRevertData

    mainLogic.passedRow = saveRevertData.passedRow
    mainLogic.digJewelCount:setValue(saveRevertData.digJewelCount)
    mainLogic.yellowDiamondCount:setValue(saveRevertData.yellowDiamondCount)
    mainLogic.maydayBossCount = saveRevertData.maydayBossCount
    mainLogic.magicTileDemolishedNum = saveRevertData.magicTileDemolishedNum

    mainLogic.fireworkEnergy = saveRevertData.fireworkEnergy
    mainLogic.isFullFirework = saveRevertData.isFullFirework

    self.bossGenRowCountDown = saveRevertData.moleWeeklyModeData.bossGenRowCountDown
    self.digItemMapReadCursor = saveRevertData.moleWeeklyModeData.digItemMapReadCursor
    self.digBoardMapReadCursor = saveRevertData.moleWeeklyModeData.digBoardMapReadCursor
    self.generationPoolCursor = saveRevertData.moleWeeklyModeData.generationPoolCursor
    self.firstLaySeedStep = saveRevertData.moleWeeklyModeData.firstLaySeedStep
    self.lastSeedCountdownStep = saveRevertData.moleWeeklyModeData.lastSeedCountdownStep
    self.lastMagicTileResetStep = saveRevertData.moleWeeklyModeData.lastMagicTileResetStep
    self.firstBoss = saveRevertData.moleWeeklyModeData.firstBoss

    -- printx(11, "================ Load from Data: moleWeeklyModeData ================")
    -- printx(11, "BossNo: ", saveRevertData.moleWeeklyRaceConf.specialSkillBossNo)
    -- printx(11, "fireworkEnergy: ", mainLogic.fireworkEnergy)

    MoleWeeklyRaceMode:parseConfigFromSectionResume(saveRevertData.moleWeeklyRaceConf)

    if saveRevertData.moleBossData then
        mainLogic.moleBossData = {}
        for k, _ in pairs(saveRevertData.moleBossData) do
            mainLogic.moleBossData[k] = saveRevertData.moleBossData[k]
        end
    else
        mainLogic.moleBossData = nil
    end

    MoveMode.revertDataFromBackProp(self)
end

function MoleWeeklyRaceMode:parseConfigFromSectionResume(savedConfig)
    -- printx(11, "moleConfig conf: ", table.tostring(savedConfig))
    -- printx(11, "releaseSkillGap type", type(savedConfig.bossConfig[2].releaseSkillGap), savedConfig.bossConfig[2].releaseSkillGap)
    -- printx(11, "throwEffectAmount type", type(savedConfig.propSkill[2].throwEffectAmount), savedConfig.propSkill[2].throwEffectAmount)
    -- printx(11, "skillWeight type", type(savedConfig.groupConfig[4].skillWeight[1]), savedConfig.groupConfig[4].skillWeight[1])
    -- printx(11, "use Config from section resume: BossNo", table.tostring(savedConfig.specialSkillBossNo))

    MoleWeeklyRaceConfig:setSavedConfig(savedConfig)
    -- MetaManager:getInstance():setMoleWeeklyRaceConfigFromSectionResume(savedConfig)
end

function MoleWeeklyRaceMode:revertUIFromBackProp()
    -- printx(11, "+ + + + + revertUIFromBackProp !! ")

    local mainLogic = self.mainLogic
    if mainLogic.PlayUIDelegate then
        mainLogic.PlayUIDelegate:revertTargetNumber(0, 0, mainLogic.digJewelCount:getValue())
        -- mainLogic.PlayUIDelegate:setFireworkEnergy(mainLogic.fireworkEnergy)
        mainLogic.PlayUIDelegate:resetFireworkStatusForRevert(mainLogic.fireworkEnergy)

        local bossData = mainLogic.moleBossData
        if bossData then
            mainLogic.boardView.PlayUIDelegate:initBossBeeDuanMian(
                MoleWeeklyRaceConfig:getCurrSkillTypeArr(bossData.bossGroupID), 
                bossData.totalBlood - bossData.hit, 
                bossData.totalBlood,
                bossData.bossSkillType,
                MoleWeeklyRaceLogic:getReleaseSkillCountDown(mainLogic, bossData)
                )
        end
    end

    MoveMode.revertUIFromBackProp(self)
end


function MoleWeeklyRaceMode:useMove()
    MoveMode.useMove(self)

    local BossData = self.mainLogic:getMoleWeeklyBossData()
    if BossData then
        if not self.BossHitStartNum  then
            self.BossHitStartNum = BossData.hit
        end

        --受到了伤害
        if self.BossHitStartNum ~= BossData.hit then
            self.BossHitStep = 1
            self.BossHitStartNum = nil
        else
            self.BossHitStep = self.BossHitStep + 1
        end
    else
        self.moveBoforeScroll = self.moveBoforeScroll + 1 
        self.BossHitStep = 0
    end
end

function MoleWeeklyRaceMode:onEnterWaitingState()

    local BossData = self.mainLogic:getMoleWeeklyBossData()

    if self.mainLogic and self.mainLogic.PlayUIDelegate then

        local bCanRunGuide = false

        local rightPropList = self.mainLogic.PlayUIDelegate.propList.rightPropList
        local springItem = rightPropList.springItem

        if self.mainLogic.theCurMoves < 5  and springItem.percent ~= 1 then
            --大招引导判断3
            if springItem and springItem.percent > 0.7 then
                bCanRunGuide = true
            end
        end

        if BossData then
            --大招引导判断1
            local totalBlood = BossData.totalBlood
            local Curblood = BossData.totalBlood - BossData.hit

            local bHpChange = false
            if self.BossHitStartNum ~= BossData.hit then 
                bHpChange = true
            end

            if Curblood/totalBlood > 0.3 and self.BossHitStep >= 5 and bHpChange == false and springItem.percent ~= 1 then
                self.BossHitStep = 0
                self.BossHitStartNum = nil
                bCanRunGuide = true
            end

        else
            --大招引导判断2
            if self.moveBoforeScroll >= 5 and springItem.percent ~= 1 then 
                bCanRunGuide = true
            end
        end

        if bCanRunGuide then
            local bHaveGuideInfo, GuideNum = self:CheckTodayDailyGuide() 
            if bHaveGuideInfo and GuideNum == 0 then
                self.mainLogic.PlayUIDelegate:playFirstBuyMoleWeekFirewordGuide() 
                self:setTodayDailyGuideComplete()
                self.moveBoforeScroll = 0
            end
        end
    end
end

function MoleWeeklyRaceMode:InitTodayDailyInfo()
    local userDailyData = Localhost:readLocalDailyData()
	if type(userDailyData) ~= 'table' then
		--我觉得这个分支不会走进来
		return
	end

	if not userDailyData.__MoleWeeklyDailyInfo then
		userDailyData.__MoleWeeklyDailyInfo = {}
	end

	if not userDailyData.__MoleWeeklyDailyInfo.runFirewordGuide then
		userDailyData.__MoleWeeklyDailyInfo.runFirewordGuide = 0
	end

	Localhost:writeLocalDailyData(nil, userDailyData)
end

function MoleWeeklyRaceMode:CheckTodayDailyGuide()
    local userDailyData = Localhost:readLocalDailyData()
	if type(userDailyData) ~= 'table' then
		--我觉得这个分支不会走进来
		return false, 0
	end

	if userDailyData.__MoleWeeklyDailyInfo then
        return true, userDailyData.__MoleWeeklyDailyInfo.runFirewordGuide
    end

    return false, 0
end

function MoleWeeklyRaceMode:setTodayDailyGuideComplete()
    local userDailyData = Localhost:readLocalDailyData()
	if type(userDailyData) ~= 'table' then
		--我觉得这个分支不会走进来
		return
	end

	if userDailyData.__MoleWeeklyDailyInfo then
        userDailyData.__MoleWeeklyDailyInfo.runFirewordGuide = 1
    end

    Localhost:writeLocalDailyData(nil, userDailyData)
end

----------------------------------------------------------------------------------------------------------------------
--====================================================================================================================
--                                                以下为历史遗迹观光区
--====================================================================================================================
----------------------------------------------------------------------------------------------------------------------

------------------------------------------- 随机生成部分  ----------------------------------
-------  虽目前版本已不使用，但暂且先不删除
local GenerationConfig = {
    digJewel = {4, 4},
    digGround = {2, 4},
    furball = {border = 20, count = {2, 3}},
    cage = {border = 40, count = {3, 4}},
    venom = {border = 60, count = {2, 3}},
    coin = {border = 80, count = {3, 4}},
    octopus = {border = 100, count = {1, 1}},
    addStep = {0, 0},
}

function MoleWeeklyRaceMode:generateVariousThings(itemMap, boardMap)
    local digGroundCount = self.mainLogic.randFactory:rand(GenerationConfig.digGround[1],GenerationConfig.digGround[2])
    if digGroundCount > 0 then
       self:generateDigGround(itemMap, digGroundCount)
    end

    local digJewelCount = self.mainLogic.randFactory:rand(GenerationConfig.digJewel[1],GenerationConfig.digJewel[2])
    if digJewelCount > 0 then
       self:generateDigJewel(itemMap, digJewelCount)
    end

    local addStepCount = self.mainLogic.randFactory:rand(GenerationConfig.addStep[1],GenerationConfig.addStep[2])
    if addStepCount > 0 then
       self:generateAddStep(itemMap, addStepCount)
    end

    local selection = self.mainLogic.randFactory:rand(1, 100)
    if _G.isLocalDevelopMode then printx(0, 'selection', selection) end
    if selection <= GenerationConfig.furball.border then
       local color = ((self.mainLogic.randFactory:rand(1, 100) <= 50) and GameItemFurballType.kGrey or GameItemFurballType.kBrown)
       local count = self.mainLogic.randFactory:rand(GenerationConfig.furball.count[1],GenerationConfig.furball.count[2])
       self:generateFurball(itemMap, count, color)
    elseif selection <= GenerationConfig.cage.border then
       local count = self.mainLogic.randFactory:rand(GenerationConfig.cage.count[1],GenerationConfig.cage.count[2])
       self:generateCage(itemMap, count)
    elseif selection <= GenerationConfig.venom.border then
       local count = self.mainLogic.randFactory:rand(GenerationConfig.venom.count[1],GenerationConfig.venom.count[2])
       self:generateVenom(itemMap, count)
    elseif selection <= GenerationConfig.coin.border then
       local count = self.mainLogic.randFactory:rand(GenerationConfig.coin.count[1],GenerationConfig.coin.count[2])
       self:generateCoin(itemMap, count)
    elseif selection <= GenerationConfig.octopus.border then
       local count = self.mainLogic.randFactory:rand(GenerationConfig.octopus.count[1],GenerationConfig.octopus.count[2])
       self:generateOctopus(itemMap, boardMap, count)
    end
end

function MoleWeeklyRaceMode:generateFunc(itemMap, boardMap, count, changePara, validateFunc, changeFunc)
    local pool = {}
    local cordinates = {}
    for r = 1, #itemMap do
        for c = 1, #itemMap[r] do
            local item = itemMap[r][c]
            if validateFunc(item) then
                table.insert(pool, item)
                table.insert(cordinates, {r, c})
                -- if _G.isLocalDevelopMode then printx(0, 'validateFunc', r, c) end
            end
        end
    end

    if #pool <= count then
        for k, v in pairs(pool) do
            changeFunc(v, changePara)
        end
    else
        local selected = {}
        for i = 1, count do
            local index = self.mainLogic.randFactory:rand(1, #pool)
            table.insert(selected, pool[index])
            if _G.isLocalDevelopMode then printx(0, 'selected r, c ', cordinates[index][1], cordinates[index][2]) end
            table.remove(pool, index)
            table.remove(cordinates, index)
        end
        for k, v in pairs(selected) do
            changeFunc(v, changePara)
        end
    end
end

function MoleWeeklyRaceMode:generateDigJewel(itemMap, count)
    if _G.isLocalDevelopMode then printx(0, 'generateDigJewel', count) end

    local function validateFunc(item)
        if item and item.ItemType == GameItemType.kDigGround then 
            return true
        end
        return false
    end
    local function changeToDigJewel(item)
        local level = item.digGroundLevel
        item:cleanAnimalLikeData()
        item.isEmpty = false
        item.ItemType = GameItemType.kDigJewel
        item.digJewelLevel = level
        item.isBlock = true
        item.isNeedUpdate = true
    end
    self:generateFunc(itemMap, nil, count, nil, validateFunc, changeToDigJewel)
end

function MoleWeeklyRaceMode:generateDigGround(itemMap, count)
    if _G.isLocalDevelopMode then printx(0, 'generateDigGround', count) end

    local function validateFunc(item)
        if item and item.ItemType == GameItemType.kDigGround then
            if item.digGroundLevel < 3 then
                return true
            end
        elseif item and item.ItemType == GameItemType.kDigJewel then
            if item.digJewelLevel < 3 then
                return true
            end
        end
        return false
    end

    local function changeLevel(item)
        if item.ItemType == GameItemType.kDigGround then
            item.digGroundLevel = item.digGroundLevel + 1
        elseif item.ItemType == GameItemType.kDigJewel then
            item.digJewelLevel = item.digJewelLevel + 1
        end
    end
    self:generateFunc(itemMap, nil, count, nil, validateFunc, changeLevel)
end

function MoleWeeklyRaceMode:isItemAnimalOrDigGround(item)
    if (item.ItemType == GameItemType.kAnimal 
    and item.ItemSpecialType == 0 
    and not item:hasLock() and not item:hasFurball())
    or item.ItemType == GameItemType.kDigGround
    then
        return true
    end
    return false
end

function MoleWeeklyRaceMode:getRandomAnimalColor()
    local count = #self.mainLogic.mapColorList
    local select = self.mainLogic.randFactory:rand(1, count)
    return self.mainLogic.mapColorList[select]
end

function MoleWeeklyRaceMode:generateCage(itemMap, count)
    if _G.isLocalDevelopMode then printx(0, 'generateCage', count) end
    local function validateFunc(item)
        return self:isItemAnimalOrDigGround(item)
    end
    local function changetoCage(item)
        if item.ItemType == GameItemType.kAnimal then
            item.cageLevel = 1
            -- item.isBlock = true
        elseif item.ItemType == GameItemType.kDigGround then
            item:cleanAnimalLikeData()
            item.isEmpty = false
            item.ItemType = GameItemType.kAnimal
            item._encrypt.ItemColorType = self:getRandomAnimalColor()
            item.cageLevel = 1
            -- item.isBlock = true
        end
    end
    self:generateFunc(itemMap, nil, count, nil, validateFunc, changetoCage)
end

function MoleWeeklyRaceMode:generateVenom(itemMap, count)
    if _G.isLocalDevelopMode then printx(0, 'generateVenom', count) end
    local function validateFunc(item)
        return self:isItemAnimalOrDigGround(item)
    end
    local function changetoVenom(item)
        item:cleanAnimalLikeData()
        item.isEmpty = false
        item.ItemType = GameItemType.kVenom
        item.isBlock = true
        item.venomLevel = 1
    end
    self:generateFunc(itemMap, nil, count, nil, validateFunc, changetoVenom)
end

function MoleWeeklyRaceMode:generateCoin(itemMap, count)
    if _G.isLocalDevelopMode then printx(0, 'generateCoin', count) end
    local function validateFunc(item)
        return self:isItemAnimalOrDigGround(item)
    end
    local function changeToCoin(item)
        item:cleanAnimalLikeData()
        item.isEmpty = false
        item.ItemType = GameItemType.kCoin
    end
    self:generateFunc(itemMap, nil, count, nil, validateFunc, changeToCoin)
end

function MoleWeeklyRaceMode:generateOctopus(itemMap, boardMap, count)
    if _G.isLocalDevelopMode then printx(0, 'generateOctopus', count) end
    local function validateFunc(item)
        return self:isItemAnimalOrDigGround(item)
    end
    local function changeToOctopus(item)
        item:cleanAnimalLikeData()
        item.ItemType = GameItemType.kPoisonBottle
        item.forbiddenLevel = 0 
        item.isBlock = true
    end
    self:generateFunc(itemMap, boardMap, count, nil, validateFunc, changeToOctopus)

end

function MoleWeeklyRaceMode:generateFurball(itemMap, count, color)
    if _G.isLocalDevelopMode then printx(0, 'generateFurball', count) end
    local function validateFunc(item)
        return self:isItemAnimalOrDigGround(item)
    end
    local function changeToFurball(item, color)
        item:cleanAnimalLikeData()
        item.ItemType = GameItemType.kAnimal
        item._encrypt.ItemColorType = self:getRandomAnimalColor()
        item.furballLevel = 1
        item.furballType = color
        -- item.isBlock = true
        item.isEmpty = false
    end
    self:generateFunc(itemMap, nil, count, color, validateFunc, changeToFurball)
end

function MoleWeeklyRaceMode:generateAddStep(itemMap, count)
    -- not needed
end
------------------------------------------- 随机生成部分 END ----------------------------------
