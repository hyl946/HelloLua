ScoreBuffBottleGenrateState = class(BaseStableState)

function ScoreBuffBottleGenrateState:create(context)
    local v = ScoreBuffBottleGenrateState.new()
    v.context = context
    v.mainLogic = context.mainLogic
    v.boardView = v.mainLogic.boardView
    return v
end

function ScoreBuffBottleGenrateState:dispose()
    self.mainLogic = nil
    self.boardView = nil
    self.context = nil
end

function ScoreBuffBottleGenrateState:getClassName()
    return "ScoreBuffBottleGenrateState"
end

function ScoreBuffBottleGenrateState:update(dt)
    
end

function ScoreBuffBottleGenrateState:checkTransition()
    return self.nextState
end

function ScoreBuffBottleGenrateState:onActionComplete(needEnter)
    self:resumeTimeAfterGenerate()

    self.nextState = self:getNextState()
    if needEnter then
        self.context:onEnter()
    end
end

function ScoreBuffBottleGenrateState:getNextState()
    return self.context.checkHedgehogCrazyState
end

function ScoreBuffBottleGenrateState:onExit()
    BaseStableState.onExit(self)
end

function ScoreBuffBottleGenrateState:onEnter()
    BaseStableState.onEnter(self)
    self.nextState = nil
    self.hasItemToHandle = false
    
    local needGenerateAmount = ScoreBuffBottleLogic:getLeftScoreBuffBottleAmount(self.mainLogic)
    if needGenerateAmount > 0 then
        local gameContext = GamePlayContext:getInstance()
        local guideContext = gameContext:getGuideContext()
        local lastGuideStep = guideContext.lastGuideStep    -- 没有引导关：-1; 有引导关：最大(配置的)步数

        -- printx(11, "check scoreBuff generate, guide, ", guideContext.allowRepeatGuide, guideContext.showRepeatGuideButton, lastGuideStep)
        -- allowRepeatGuide 的时候，会在其他逻辑中屏蔽重复引导按钮，所以可以正常扔buff
        if guideContext.allowRepeatGuide or (self.mainLogic.realCostMoveWithoutBackProp > lastGuideStep) then
            if not self:_tryGenerateScoreBuffBottle(needGenerateAmount) then
                self:onActionComplete()
            end
        else
            self:onActionComplete()
        end
    else
    	self:onActionComplete()
    end
    
end

function ScoreBuffBottleGenrateState:_tryGenerateScoreBuffBottle(generateAmount)
    local pickedGenerateTarget = ScoreBuffBottleLogic:pickValidTarget(self.mainLogic, generateAmount)
    -- printx(11, "pickedGenerateTarget", #pickedGenerateTarget)
    if #pickedGenerateTarget > 0 then
        self:pauseTimeWhileGenerate()

        self:playThrowBottleAnimation(pickedGenerateTarget)
        return true
    end

	return false
end

function ScoreBuffBottleGenrateState:playThrowBottleAnimation(pickedGenerateTarget)
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
    
    local anim = gAnimatedObject:createWithFilename('gaf/scoreBuffBottle/ScoreBuffBottle_throw.gaf')
    local animPos = ccp(vo.x + vs.width / 2 - 355, vo.y + vs.height/2 + 670)
    anim:setPosition(animPos)

    local function finishCallback( ... )
        if container then
            container:removeFromParentAndCleanup(true)
            container = nil
        end
        -- if callback then
        --     callback()
        -- end
    end

    local function onStartPeriodFinished()
        anim:setSequenceDelegate('throw', finishCallback)
        anim:playSequence("throw", false, true, ASSH_RESTART)
        anim:start()

        local flyAniDuration = 0.3
        for _, targetItem in ipairs(pickedGenerateTarget) do
            self:playFlyToGridAnimation(targetItem, animPos, flyAniDuration)
        end

        self:thowBottleToBoard(pickedGenerateTarget, flyAniDuration)
    end

    anim:setSequenceDelegate('start', onStartPeriodFinished, true)
    anim:playSequence("start", false, true, ASSH_RESTART)
    anim:start()

    container:addChild(anim)
end

function ScoreBuffBottleGenrateState:playFlyToGridAnimation(targetItem, hugeAnimationPos, flyAniDuration)
    local scene = Director:sharedDirector():getRunningScene()

    local startPos = ccp(hugeAnimationPos.x + 350, hugeAnimationPos.y - 700)
    local endPos = self.mainLogic.boardView.gameBoardLogic:getGameItemPosInView(targetItem.y, targetItem.x)

    local animation = Sprite:createWithSpriteFrameName("blocker_scoreBuff_fly_single_0000")
    -- local animation = Sprite:createWithSpriteFrameName("blocker_scoreBuff_fly_0000")
    -- local frames = SpriteUtil:buildFrames("blocker_scoreBuff_fly_%04d", 0, 8)
    -- local flyAnimation = SpriteUtil:buildAnimate(frames, 1/30)
    -- animation:play(flyAnimation, 0, 1, nil, true)

    local angle = -math.deg(math.atan2(endPos.y - startPos.y, endPos.x - startPos.x))
    animation:setPosition(startPos)
    animation:setRotation(angle)

    local function onfinish()
        if animation then animation:removeFromParentAndCleanup(true) end

        local splashPos = ccp(endPos.x - 5, endPos.y)
        local splashAnimation = Sprite:createWithSpriteFrameName("blocker_scoreBuff_blast_0000")
        local frames = SpriteUtil:buildFrames("blocker_scoreBuff_blast_%04d", 0, 18)
        local anim = SpriteUtil:buildAnimate(frames, 1/30)
        splashAnimation:play(anim, 0, 1, nil, true)
        splashAnimation:setPosition(splashPos)
        splashAnimation:setScale(2)
        scene:addChild(splashAnimation)

        if finishCallback then finishCallback() end
    end

    local actArr = CCArray:create()
    actArr:addObject(CCMoveTo:create(flyAniDuration, ccp(endPos.x, endPos.y)))
    actArr:addObject(CCCallFunc:create(onfinish) )
    animation:runAction(CCSequence:create(actArr))

    scene:addChild(animation)
end

function ScoreBuffBottleGenrateState:thowBottleToBoard(pickedGenerateTarget, flyAniDuration)
    local function callback()
        self:onActionComplete()
    end

    local action =  GameBoardActionDataSet:createAs(
        GameActionTargetType.kPropsAction,
        GameItemActionType.kItem_ScoreBuffBottle_Add,
        nil,
        nil,
        GamePlayConfig_MaxAction_time)
    action.targetItems = pickedGenerateTarget
    action.preAnimationDelay = flyAniDuration
    action.completeCallback = callback
    self.mainLogic:addGlobalCoreAction(action)
end

function ScoreBuffBottleGenrateState:pauseTimeWhileGenerate()
    self.mainLogic.isGamePaused = true
end

function ScoreBuffBottleGenrateState:resumeTimeAfterGenerate()
    self.mainLogic.isGamePaused = false
end

