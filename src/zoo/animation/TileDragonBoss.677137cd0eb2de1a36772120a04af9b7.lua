local kCharacterAnimationTime = 1/26
local kEffectAnimationTime = 1/26
local OFFSET_X, OFFSET_Y = -5, 0

local animationList = table.const
{
    kNone = 0,
    kWandering = 1,
    kComeout = 2,
    kDie = 3,
    kHit = 4,
    kRandom = 5,
    kCasting = 6
}


-- 圣诞节活动boss
-- 因为game mode是halloween，所以叫halloween boss
TileDragonBoss = class(CocosObject)

function TileDragonBoss:create()
    local i = TileDragonBoss.new(CCNode:create())
    i:init()
    return i
end

function TileDragonBoss:init()
    self.body = CocosObject:create()
    self.body:setContentSize(CCSizeMake(9*70, 150))
    self.body:setAnchorPoint(ccp(0, 0))
    self:addChild(self.body)
    self.sprite = Sprite:createWithSpriteFrameName('dragonboat_boss_wander_0000')
    self.sprite:setAnchorPoint(ccp(0, 0))
    self.body:addChild(self.sprite)
    self.sprite:setPosition(ccp(0, 20))
    self:createBloodBar()
end

function TileDragonBoss:getBossSpriteWorldPosition()
    if self.body and self.sprite then
        local worldPos = self.body:convertToWorldSpace(self.sprite:getPosition())
        local bossSize = self.sprite:getContentSize()
        local centerPos = ccp(worldPos.x + bossSize.width / 2, worldPos.y)
        return centerPos
    end
    return nil
end

function TileDragonBoss:playWandering(dir)

    if not self.sprite or not self.sprite.refCocosObj then
        return
    end

    self.animate = animationList.kWandering
    self.sprite:stopAllActions()
    local animate = SpriteUtil:buildAnimate(SpriteUtil:buildFrames('dragonboat_boss_wander_%04d', 0, 30), kCharacterAnimationTime)
    self.sprite:play(animate)

    local totalTime = 12
    local curPosX = self.sprite:getPositionX()
    local maxX = 7*70
    local speed = (maxX / totalTime)
    local curDir = dir or 'right'

    local function onChangeDirection()
        local dist = math.random(1, maxX)
        local time = dist / speed
        -- if _G.isLocalDevelopMode then printx(0, 'random time', time) end
        setTimeOut(function() self:playRandom() end, time)
    end
    

    if curDir == 'right' then
        local time = (maxX - curPosX) / speed
        -- if _G.isLocalDevelopMode then printx(0, 'right', time) end
        local array = CCArray:create()
        array:addObject(CCCallFunc:create(
            function()  
                local lastDir = self.dir
                self.dir = 'right' 
                if lastDir ~= self.dir then
                    onChangeDirection() 
                end
            end))
        array:addObject(CCMoveTo:create(time, ccp(maxX, 20)))
        array:addObject(CCCallFunc:create(
            function()  
                local lastDir = self.dir
                self.dir = 'left'
                if lastDir ~= self.dir then
                    onChangeDirection() 
                end
            end))
        array:addObject(CCMoveTo:create(totalTime, ccp(0, 20)))
        self.sprite:runAction(CCRepeatForever:create(CCSequence:create(array)))

    elseif curDir == 'left' then
        local time = curPosX / speed -- distance / speed
        -- if _G.isLocalDevelopMode then printx(0, 'left', time) end
        local array = CCArray:create()
        array:addObject(CCCallFunc:create(
            function()  
                local lastDir = self.dir
                self.dir = 'left' 
                if lastDir ~= self.dir then
                    onChangeDirection() 
                end
            end))
        array:addObject(CCMoveTo:create(time, ccp(0, 20)))
        array:addObject(CCCallFunc:create(
            function()  
                local lastDir = self.dir
                self.dir = 'right' 
                if lastDir ~= self.dir then
                    onChangeDirection() 
                end
            end))
        array:addObject(CCMoveTo:create(totalTime, ccp(maxX, 20)))
        self.sprite:runAction(CCRepeatForever:create(CCSequence:create(array)))
    end
end

function TileDragonBoss:playRandom()

    local function callback()
        -- if _G.isLocalDevelopMode then printx(0, 'playRandom') end
        self:playWandering(self.dir)
    end

    if self.animate == animationList.kRandom
    or self.animate == animationList.kCasting
    or self.animate == animationList.kHit
    or self.animate == animationList.kComeout
    or self.animate == animationList.kDie then
        return
    end
    if self.sprite and self.sprite.refCocosObj then
        self.animate = animationList.kRandom
        self.sprite:stopAllActions()
        local animate = SpriteUtil:buildAnimate(SpriteUtil:buildFrames('dragonboat_boss_random_%04d', 0, 51), kCharacterAnimationTime)
        self.sprite:play(animate, 0, 1, callback)
    else
        callback()
    end
end

function TileDragonBoss:playHit(fromPosInWorld, callback, isSpecial)
    -- if _G.isLocalDevelopMode then printx(0, 'play hit') end

    local function localCB()

        self:playWandering(self.dir)
        if callback then
            callback()
        end
    end

    local ball = TileDragonBoss:buildWaterBallAnim()
    -- if isSpecial then 
    --     ball = Sprite:createWithSpriteFrameName('xmas_snowball_red_0000')
    -- else
    --     ball = Sprite:createWithSpriteFrameName('xmas_snowball_0000')
    -- end
    local function arrive()
        local pos = ccp(ball:getPositionX(), ball:getPositionY())

        if ball and ball.refCocosObj and not ball.isDisposed then
            ball:removeFromParentAndCleanup(true)
            ball = nil
        end
        -- local snow = Sprite:createWithSpriteFrameName('xmas_boss_hiticon_0000')
        -- local animation = SpriteUtil:buildAnimate(SpriteUtil:buildFrames('xmas_boss_hiticon_%04d', 0, 20), kCharacterAnimationTime)
        -- local function remove()
        --     if snow and snow.refCocosObj then
        --         snow:removeFromParentAndCleanup(true)
        --     end
        -- end
        -- snow:play(animation, 0, 1, remove)
        -- snow:setPosition(pos)
        -- -- snow:setOpacity(0)
        -- self.body:addChild(snow)
    end

    local spriteSize = self.sprite:getGroupBounds().size

    local toPos = self.sprite:getPosition()
    toPos = ccp(toPos.x + spriteSize.width / 2 + 25, toPos.y + spriteSize.height / 2 - 35)
    local fromPos = self.body:convertToNodeSpace(fromPosInWorld)
    local rotate = math.acos((toPos.y - fromPos.y) / ccpDistance(fromPos, toPos)) * 180 / 3.14

    if toPos.x < fromPos.x then
        rotate = -rotate
    end

    -- local array = CCArray:create()
    -- array:addObject(CCEaseSineOut:create(CCMoveTo:create(1.2, toPos)))
    -- array:addObject(CCEaseSineIn:create(CCFadeTo:create(1.2, 255)))
    ball:setPosition(fromPos)
    ball:setRotation(rotate + 180)
    ball:setScale(0.6)
    local action1 = CCSpawn:createWithTwoActions(CCMoveTo:create(20 * kCharacterAnimationTime, toPos), CCScaleTo:create(20 * kCharacterAnimationTime, 0.8))
    ball:runAction(CCSequence:createWithTwoActions(CCEaseSineIn:create(action1), CCCallFunc:create(arrive)))
    self.body:addChild(ball)

    if self.animate == animationList.kHit
    or self.animate == animationList.kCasting 
    or self.animate == animationList.kDie then
        if callback then callback() end
    else
        self.animate = animationList.kHit
        self.sprite:stopAllActions()
        local animate = SpriteUtil:buildAnimate(SpriteUtil:buildFrames('dragonboat_boss_hit_%04d', 0, 66), kCharacterAnimationTime)
        self.sprite:play(animate, 0, 1, localCB)
    end

end

function TileDragonBoss:playDie(callback, onAddDrops)
    -- if _G.isLocalDevelopMode then printx(0, debug.traceback()) end
    if self.animate == animationList.kDie then
        -- if callback then callback() end
        return
    end
    self.animate = animationList.kDie

    self.sprite:stopAllActions()
    local function localCB()
        if callback then
            local winSize = Director:sharedDirector():getWinSize()
            local diePos = ccp(winSize.width / 2, winSize.height / 2 - 50)
            callback(diePos)
        end
    end

    local function playJumpAnim()
        local runningScene = Director:sharedDirector():getRunningScene()
        if runningScene then
            local jumpAnim = TileDragonBoss:buildBossJumpAnim(localCB, onAddDrops)
            jumpAnim:setPosition(ccp(runningScene.screenWidth / 2, runningScene.screenHeight / 2))
            runningScene:addChild(jumpAnim)
        else
           localCB() 
        end
    end

    local animate = SpriteUtil:buildAnimate(SpriteUtil:buildFrames('dragonboat_boss_die_%04d', 0, 23), kCharacterAnimationTime)
    self.sprite:play(animate, 0, 1, playJumpAnim)
end

function TileDragonBoss:playComeout(callback)

    if self.animate == animationList.kComeout then
        if callback then callback() end
        return
    end
    self.animate = animationList.kComeout

    self:stopAllActions()
    local function localCB()
        self:playWandering(self.dir)
        if callback then
            callback()
        end
    end

    local animate = SpriteUtil:buildAnimate(SpriteUtil:buildFrames('dragonboat_boss_comeout_%04d', 0, 36), kCharacterAnimationTime)
    self.sprite:play(animate, 0, 1, localCB)

    local comeEffect = TileDragonBoss:buildBossComeEffect()
    local spriteSize = self.sprite:getContentSize()
    comeEffect:setPosition(ccp(spriteSize.width/2 - 15, 40))
    self.sprite:addChild(comeEffect)
end

function TileDragonBoss:buildBossDieDropsAnim(dropBell, dropAddMove, callback)
    dropBell = dropBell or 0
    dropAddMove = dropAddMove or 0
    local anim = Sprite:createEmpty()

    local time1 = 8 * kCharacterAnimationTime
    local time2 = 8 * kCharacterAnimationTime

    local dxsprite = dropBell > 0 and (170 / dropBell) or 0
    local dysprite = dropBell > 0 and (50 / dropBell * 2) or 0
    -- if _G.isLocalDevelopMode then printx(0, "dxsprite:", dxsprite, dysprite) end
    local bells = {}
    local addMoves = {}

    anim.bells = bells
    anim.addMoves = addMoves

    local totalDrop = dropBell + dropAddMove
    local animCounter = 0

    local function onAnimComplete()
        animCounter = animCounter - 1
        if animCounter == 0 then
            if callback then callback() end
        end
    end

    for i = 1, totalDrop do
        animCounter = animCounter + 1
        local isAddMove = false
        if #bells >= dropBell or (#addMoves < dropAddMove and math.random(totalDrop) > dropBell) then
            isAddMove = true
        end
        local direction = 1
        if i % 2 == 0 then direction = -1 end 
        local sprite = nil
        if not isAddMove then
            sprite = Sprite:createWithSpriteFrameName("target.dig_move_endless instance 10000")
            table.insert(bells, sprite)
            anim:addChild(sprite)
        else
            sprite = TileDragonBoss:buildAddMoveLightAnim()
            table.insert(addMoves, sprite)
            anim:addChildAt(sprite, 999)
        end
        sprite:setRotation(20 - math.random(40))
        sprite:setScale(0.5)
        sprite:setOpacity(0)
        local spriteSeq = CCArray:create()
        local d = math.floor(i / 2)
        local moveBy1 = CCMoveBy:create(time1, ccp(direction * (d * dxsprite + math.random(40) + 15), (90 - d * dysprite + math.random(20))))
        spriteSeq:addObject(CCSpawn:createWithTwoActions(CCFadeIn:create(time1), moveBy1))

        local spriteSeq2 = CCArray:create()
        spriteSeq2:addObject(CCMoveBy:create(time2, ccp(direction * (math.random(50) + d * dxsprite), math.random(50) - 200 + d * dysprite)))
        spriteSeq2:addObject(CCScaleTo:create(time2, 0.8))
        spriteSeq2:addObject(CCRotateBy:create(time2, 10 - math.random(20)))
        spriteSeq2:addObject(CCDelayTime:create(1))
        spriteSeq:addObject(CCSpawn:create(spriteSeq2))
        spriteSeq:addObject(CCCallFunc:create(onAnimComplete))

        sprite:runAction(CCSequence:create(spriteSeq))
    end

    return anim
end

function TileDragonBoss:playCasting(destPositions, callback)
    -- if _G.isLocalDevelopMode then printx(0, 'TileDragonBoss:playCasting') end
    -- if _G.isLocalDevelopMode then printx(0, self.animate) end
    -- debug.debug()?
    if self.animate == animationList.kCasting then
        if callback then callback() end
        return
    end
    self.animate = animationList.kCasting

    local function localCB()
        self:playWandering(self.dir)
        if callback then
            callback()
        end
    end

    self.sprite:stopAllActions()
    
    local rectSize = self.sprite:getGroupBounds().size
    local spriteSize = {width = rectSize.width, height = rectSize.height}

    local count = 0
    local function ballCallback()
        count = count + 1
        if count >= #destPositions then
            localCB()
        end
    end

    local delay = 53 * kCharacterAnimationTime

    local function playBallsAnim()
        for k,v in pairs(destPositions) do
            local ball = TileDragonBoss:buildWaterBallAnim()
            ball:setScale(0.6)
            local toPos = self.body:convertToNodeSpace(v)
            toPos.x, toPos.y = toPos.x - 13, toPos.y + 10
            local fromPos = ccp(self.sprite:getPositionX(), self.sprite:getPositionY())
            fromPos.x, fromPos.y = fromPos.x + spriteSize.width / 2 - 15, fromPos.y - 15
           
            local array = CCArray:create()
            -- array:addObject(CCDelayTime:create(delay))
            -- array:addObject(CCFadeIn:create(0.1))
            array:addObject(CCSpawn:createWithTwoActions(CCMoveTo:create(0.8, ccp(toPos.x + 15, toPos.y - 15)), CCScaleTo:create(0.8, 0.8)))
            local function onBallAnimComplete()
                if ball and not ball.isDisposed then 
                    ball:removeFromParentAndCleanup(true) 
                    ball = nil
                end
                local ballEffect = TileDragonBoss:buildWaterBallBreakAnim(ballCallback)
                ballEffect:setPosition(ccp(toPos.x, toPos.y))
                self.body:addChild(ballEffect)
            end
            array:addObject(CCCallFunc:create(onBallAnimComplete))
            ball:runAction(CCSequence:create(array))

            local angle = 360 - math.asin((toPos.x - fromPos.x) / ccpDistance(fromPos, toPos)) * 180 / 3.14
            ball:setRotation(angle)
            ball:setPosition(ccp(fromPos.x, fromPos.y))
            -- ball:setOpacity(0)
            self.body:addChild(ball)
        end
    end

    local animate = SpriteUtil:buildAnimate(SpriteUtil:buildFrames('dragonboat_boss_casting_%04d', 0, 80), kCharacterAnimationTime)
    
    -- self.sprite:runAction(CCSequence:createWithTwoActions(animate, CCCallFunc:create(localCB)))
    -- self.sprite:play(animate, 0, 1, localCB)
    local action2 = CCSequence:createWithTwoActions(CCDelayTime:create(delay), CCCallFunc:create(playBallsAnim))
    -- self.sprite:play(animate, 0, 1, nil)
    self.sprite:runAction(CCSpawn:createWithTwoActions(animate, action2))
end

function TileDragonBoss:buildBossJumpAnim(onAnimFinish, onAddDrops)
    local delayTime = 0.5
    local anim = Sprite:createEmpty()

    local bg = LayerColor:create()
    bg:setColor(ccc3(0,0,0))
    bg:setOpacity(255 * 0.6)
    local winSize = Director:sharedDirector():getWinSize()
    bg:changeWidthAndHeight(winSize.width, winSize.height)
    bg:setAnchorPoint(ccp(0.5, 0.5))
    bg:ignoreAnchorPointForPosition(false)
    anim:addChild(bg)

    local unitTime = kCharacterAnimationTime

    local animCounter = 0
    local function onAnimComplete()
        animCounter = animCounter - 1
        if animCounter == 0 then
            if anim and not anim.isDisposed then anim:removeFromParentAndCleanup(true) end
            if onAnimFinish then onAnimFinish() end
        end
    end

    local waterBg = Sprite:createWithSpriteFrameName("dragonboat_water_static_0000")
    anim:addChild(waterBg)
    waterBg:setPosition(ccp(0, -130))
    waterBg:setScale(68/231, 13.6/39)
    waterBg:ignoreAnchorPointForPosition(false)
    local waterBgSeq = CCArray:create()
    waterBgSeq:addObject(CCDelayTime:create(delayTime))
    waterBgSeq:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(8 * unitTime, 1), CCMoveBy:create(8 * unitTime, ccp(0, -13))))
    waterBgSeq:addObject(CCDelayTime:create(18 * unitTime))
    waterBgSeq:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(11 * unitTime, 398/231, 53.7/39), CCFadeTo:create(11 * unitTime, 25.5)))
    waterBgSeq:addObject(CCCallFunc:create(onAnimComplete))
    animCounter = animCounter + 1
    waterBg:runAction(CCSequence:create(waterBgSeq))

    local bossClippingNode = ClippingNode:create(CCRectMake(0,0,winSize.width,700))
    bossClippingNode:setAnchorPoint(ccp(0.5, 0.5))
    bossClippingNode:ignoreAnchorPointForPosition(false)
    bossClippingNode:setPosition(ccp(-winSize.width/2, -winSize.height/2 + 500))
    local boss = Sprite:createWithSpriteFrameName("dragonboat_boss_jump_0000")
    bossClippingNode:addChild(boss)
    boss:setPosition(ccp(winSize.width/2, 540))
    anim:addChild(bossClippingNode)
    local bossAnim = SpriteUtil:buildAnimate(SpriteUtil:buildFrames("dragonboat_boss_jump_%04d", 0, 17), unitTime)
    local bossSeq = CCArray:create()
    bossSeq:addObject(CCDelayTime:create(delayTime))
    bossSeq:addObject(CCEaseSineOut:create(CCMoveBy:create(38 * unitTime, ccp(0, -900))))

    -- bossSeq:addObject(CCMoveBy:create(8 * unitTime, ccp(0, -150)))
    -- bossSeq:addObject(CCMoveBy:create(8 * unitTime, ccp(0, -200)))
    -- bossSeq:addObject(CCMoveBy:create(13 * unitTime, ccp(0, -350)))
    local function onBossAnimComplete()
        if boss then boss:removeFromParentAndCleanup(true) end
        if onAnimComplete then onAnimComplete() end
    end
    bossSeq:addObject(CCCallFunc:create(onBossAnimComplete))
    animCounter = animCounter + 1
    boss:runAction(CCSpawn:createWithTwoActions(bossAnim, CCSequence:create(bossSeq)))

    local waterFlower = Sprite:createWithSpriteFrameName("dragonboat_water_flower_0000")
    waterFlower:setOpacity(0)
    waterFlower:setPosition(ccp(0, -80))
    anim:addChild(waterFlower)
    local waterFlowerAnim = SpriteUtil:buildAnimate(SpriteUtil:buildFrames("dragonboat_water_flower_%04d", 0, 11), unitTime)
    local waterFlowerSeq = CCArray:create()
    waterFlowerSeq:addObject(CCDelayTime:create(delayTime))
    waterFlowerSeq:addObject(CCDelayTime:create(17 * unitTime))
    local function addDropsAnim()
        if onAddDrops then onAddDrops() end
    end
    waterFlowerSeq:addObject(CCCallFunc:create(addDropsAnim))
    waterFlowerSeq:addObject(CCFadeIn:create(0.1))
    waterFlowerSeq:addObject(waterFlowerAnim)
    local function onWaterAnimComplete()
        if waterFlower then waterFlower:removeFromParentAndCleanup(true) end
        if onAnimComplete then onAnimComplete() end
    end
    waterFlowerSeq:addObject(CCCallFunc:create(onWaterAnimComplete))
    animCounter = animCounter + 1
    waterFlower:runAction(CCSequence:create(waterFlowerSeq))

    return anim
end

function TileDragonBoss:createBloodBar()
    local blood = Sprite:createEmpty()
    local bloodbg = Sprite:createWithSpriteFrameName("dragonboat_boss_bloodbg_0000")
    bloodbg:setAnchorPoint(ccp(0, 0.5))
    bloodbg:setPosition(ccp(-3, 0))
    blood:addChild(bloodbg)

    local bloodfg_mask = Sprite:createWithSpriteFrameName("dragonboat_boss_bloodbar_0000")
    local bloodfg = Sprite:createWithSpriteFrameName("dragonboat_boss_bloodbar_0000")
    local clipingnode = ClippingNode.new(CCClippingNode:create(bloodfg_mask.refCocosObj))
    clipingnode:setPositionX(10)
    clipingnode:setAlphaThreshold(0.1)
    bloodfg_mask:setAnchorPoint(ccp(0, 0.5))
    bloodfg:setAnchorPoint(ccp(0, 0.5))
    clipingnode:addChild(bloodfg)

    blood:addChild(clipingnode)
    self.body:addChild(blood)
    self.bloodBar = bloodfg
    bloodfg:setPosition(ccp(OFFSET_X, 0))
    bloodfg_mask:setPosition(ccp(OFFSET_X-1, 0))
    self.bloodBarWidth = bloodfg:getGroupBounds().size.width

    local bloodEffect = TileDragonBoss:buildBloodBarEffect()
    bloodEffect:setPosition(ccp(self.bloodBarWidth - 30, 5))
    bloodfg:addChild(bloodEffect)
    bloodEffect:setScale(0.5)
    self.bloodEffect = bloodEffect
    self.bloodEffect:setVisible(true)

    -- local pos_x = -self.bloodBarWidth /2
    -- local pos_y = -GamePlayConfig_Tile_Height * 3 /4
    blood:setPosition(ccp(0, 30))
    self.blood = blood
end

function TileDragonBoss:setBloodPercent(percent, isPlayAnimation)
    if self.bloodBar and percent then
        if percent > 1 then percent = 1 end
        self.bloodBar:stopAllActions()
        if isPlayAnimation then
            local newPos = ccp((percent - 1) * self.bloodBarWidth + OFFSET_X, 0)
            self.bloodBar:runAction(CCMoveTo:create(0.5, ccp(newPos.x, newPos.y)))
        else
            self.bloodBar:setPosition(ccp((percent - 1) * self.bloodBarWidth + OFFSET_X, 0))
        end        
    end
end

function TileDragonBoss:getSpriteWorldPosition()
    return self.body:convertToWorldSpace(self.sprite:getPosition())
end

function TileDragonBoss:setSpriteX(x)
    local pos = ccp(x, 0)
    local realPos = self.body:convertToNodeSpace(pos)
    if realPos.x < 0 then realPos.x = 0 end
    if realPos.x > 7*70 then realPos.x = 7*70 end
    self.sprite:setPositionX(realPos.x)
end

function TileDragonBoss:buildBossFlyStar(onAnimFinish)
    local starAnim = Sprite:createEmpty()

    local stars = {
        {x=-4, y=-38, dx=1, dy = -190, delay=0, scale = 0.4},
        {x=12, y=-43, dx=-2, dy = -120, delay=0, scale = 0.5},
        {x=-1, y=-65, dx=1, dy = -250, delay=0, scale = 0.4},
        {x=2, y=-43, dx=-1, dy = -160, delay=6 * kEffectAnimationTime, scale = 0.6},
    }
    local animCounter = 0

    local function onAnimComplete()
        animCounter = animCounter - 1
        -- if animCounter == 0 then
        --     if starAnim and starAnim:getParent() then 
        --         starAnim:removeFromParentAndCleanup(true)
        --     end
        --     if onAnimFinish then onAnimFinish() end
        -- end
    end

    for _, v in pairs(stars) do
        animCounter = animCounter + 1
        local star = Sprite:createWithSpriteFrameName("light_fivestar")
        star:setPosition(ccp(v.x, v.y))
        star:setVisible(false)
        if v.scale then
            star:setScale(v.scale)
        end
       
        local starSeq = CCArray:create()
        local delayTime = v.delay or 0
        starSeq:addObject(CCDelayTime:create(delayTime))
        starSeq:addObject(CCCallFunc:create(function() star:setVisible(true) end))
        starSeq:addObject(CCMoveBy:create(11 * kEffectAnimationTime, ccp(v.dx, v.dy)))
        starSeq:addObject(CCSpawn:createWithTwoActions(CCMoveBy:create(9 * kEffectAnimationTime, ccp(v.dx, v.dy)), CCFadeOut:create(9 * kEffectAnimationTime)))
        starSeq:addObject(CCCallFunc:create(onAnimComplete))

        star:runAction(CCSequence:create(starSeq))

        starAnim:addChild(star)
    end

    animCounter = animCounter + 1
    local lightSprite = Sprite:createWithSpriteFrameName("light_move")
    lightSprite:setAnchorPoint(ccp(0.5, 1))
    lightSprite:setScale(0.4, 1)
    local lightSeq = CCArray:create()
    lightSeq:addObject(CCScaleTo:create(20 * kEffectAnimationTime, 1, 1))
    lightSeq:addObject(CCCallFunc:create(onAnimComplete))
    lightSprite:runAction(CCSequence:create(lightSeq))

    starAnim:addChild(lightSprite)

    return starAnim
end

function TileDragonBoss:buildWaterBallAnim()
    local anim = Sprite:createEmpty()

    local waterBall = Sprite:createWithSpriteFrameName("waterball2")
    anim:addChild(waterBall)
    local waterBallSeq = CCArray:create()
    waterBallSeq:addObject(CCScaleTo:create(7 * kEffectAnimationTime, 1.06, 0.91))
    waterBallSeq:addObject(CCScaleTo:create(7 * kEffectAnimationTime, 0.94, 1.06))
    waterBallSeq:addObject(CCScaleTo:create(6 * kEffectAnimationTime, 1, 1))
    waterBall:runAction(CCSequence:create(waterBallSeq))

    local ballMove1 = Sprite:createWithSpriteFrameName("waterball_star1")
    anim:addChild(ballMove1)
    ballMove1:setOpacity(255)
    ballMove1:setPosition(ccp(-16, 54))
    ballMove1:setScale(0.42)
    local ballMove1Seq = CCArray:create()
    local function ballMove1SeqReinit()
        ballMove1:setOpacity(255)
        ballMove1:setPosition(ccp(-16, 54))
    end
    ballMove1Seq:addObject(CCCallFunc:create(ballMove1SeqReinit))
    ballMove1Seq:addObject(CCSpawn:createWithTwoActions(CCMoveBy:create(20 * kEffectAnimationTime, ccp(0, 240)), CCFadeOut:create(20 * kEffectAnimationTime)))
    ballMove1:runAction(CCSequence:create(ballMove1Seq))

    local ballMove2 = Sprite:createWithSpriteFrameName("waterball_star1")
    anim:addChild(ballMove2)
    ballMove2:setOpacity(255 * 0.8)
    ballMove2:setPosition(ccp(8, 70))
    ballMove2:setScale(0.35)
    local ballMove2Action1 = CCSpawn:createWithTwoActions(CCMoveBy:create(14 * kEffectAnimationTime, ccp(0, 180)), CCFadeOut:create(14 * kEffectAnimationTime))
    local ballMove2Seq = CCArray:create()
    local function ballMove2Reinit()
        ballMove2:setOpacity(255)
        ballMove2:setPosition(ccp(8, 54))
    end
    ballMove2Seq:addObject(CCCallFunc:create(ballMove2Reinit))
    ballMove2Seq:addObject(CCSpawn:createWithTwoActions(CCMoveBy:create(20 * kEffectAnimationTime, ccp(0, 200)), CCFadeOut:create(20 * kEffectAnimationTime)))
    local ballMove2Action2 = CCSequence:create(ballMove2Seq)
    ballMove2:runAction(CCSequence:createWithTwoActions(ballMove2Action1, ballMove2Action2))
  
    local ballMove3 = Sprite:createWithSpriteFrameName("waterball_star1")
    anim:addChild(ballMove3)
    ballMove3:setOpacity(255 * 0.6)
    ballMove3:setPosition(ccp(-5, 80))
    ballMove3:setScale(0.21)
    local ballMove3Action1 = CCSpawn:createWithTwoActions(CCMoveBy:create(11 * kEffectAnimationTime, ccp(0, 120)), CCFadeOut:create(11 * kEffectAnimationTime))
    local ballMove3Seq = CCArray:create()
    local function ballMove3Reinit()
        ballMove3:setOpacity(255)
        ballMove3:setPosition(ccp(-5, 54))
    end
    ballMove3Seq:addObject(CCCallFunc:create(ballMove3Reinit))
    ballMove3Seq:addObject(CCSpawn:createWithTwoActions(CCMoveBy:create(20 * kEffectAnimationTime, ccp(0, 180)), CCFadeOut:create(20 * kEffectAnimationTime)))
    local ballMove3Action2 = CCSequence:create(ballMove3Seq)
    ballMove3:runAction(CCSequence:createWithTwoActions(ballMove3Action1, ballMove3Action2))

    local ballMove4 = Sprite:createWithSpriteFrameName("waterball_star1")
    anim:addChild(ballMove4)
    ballMove4:setOpacity(255 * 0.2)
    ballMove4:setPosition(ccp(6, 170))
    ballMove4:setScale(0.3)
    local ballMove4Action1 = CCSpawn:createWithTwoActions(CCMoveBy:create(5 * kEffectAnimationTime, ccp(0, 40)), CCFadeOut:create(5 * kEffectAnimationTime))
    local ballMove4Seq = CCArray:create()
    local function ballMove4Reinit()
        ballMove4:setOpacity(255)
        ballMove4:setPosition(ccp(6, 64))
    end
    ballMove4Seq:addObject(CCCallFunc:create(ballMove4Reinit))
    ballMove4Seq:addObject(CCSpawn:createWithTwoActions(CCMoveBy:create(20 * kEffectAnimationTime, ccp(0, 200)), CCFadeOut:create(20 * kEffectAnimationTime)))
    local ballMove4Action2 = CCSequence:create(ballMove4Seq)
    ballMove4:runAction(CCSequence:createWithTwoActions(ballMove4Action1, ballMove4Action2))

    anim._setRotation = anim.setRotation
    anim.setRotation = function(self, rotation)
        anim:_setRotation(rotation)
        waterBall:setRotation(-rotation)
    end

    return anim
end

function TileDragonBoss:buildWaterBallBreakAnim(onAnimFinish)
    local anim = Sprite:createEmpty()

    local waterBall = Sprite:createWithSpriteFrameName("dragonboat_waterball_break_0000")
    local waterBallAnim = SpriteUtil:buildAnimate(SpriteUtil:buildFrames("dragonboat_waterball_break_%04d", 7, 21), kEffectAnimationTime)
    local function onAnimComplete()
        if anim then anim:removeFromParentAndCleanup(true) end
        if onAnimFinish then onAnimFinish() end
    end
    waterBall:runAction(CCSequence:createWithTwoActions(waterBallAnim, CCCallFunc:create(onAnimComplete)))
    anim:addChild(waterBall)

    return anim
end

function TileDragonBoss:buildAddMoveLightAnim()
    local anim = Sprite:createEmpty()

    local light = Sprite:createWithSpriteFrameName("dragonboat_addmove_light_0000")
    local lightAnim = SpriteUtil:buildAnimate(SpriteUtil:buildFrames("dragonboat_addmove_light_%04d", 0, 15), kEffectAnimationTime)
    light:runAction(CCRepeatForever:create(lightAnim))
    anim:addChild(light)

    return anim
end

function TileDragonBoss:buildBloodBarEffect()
    local anim = Sprite:createEmpty()

    local sprite = Sprite:createWithSpriteFrameName("dragonboat_bloodbar_effect_0000")
    local spriteAnim = SpriteUtil:buildAnimate(SpriteUtil:buildFrames("dragonboat_bloodbar_effect_%04d", 0, 20), kEffectAnimationTime)
    sprite:runAction(CCRepeatForever:create(spriteAnim))
    anim:addChild(sprite)

    return anim
end

function TileDragonBoss:buildAddMoveAnim(flyTime, movePos, onAnimFinish)
    local anim = Sprite:createEmpty()

    local fly = TileDragonBoss:buildAddMoveFlyAnim()
    fly:setScale(0.8)
    local rotation = 0
    if movePos.y ~= 0 then 
        rotation = math.atan(movePos.x / movePos.y) * 180 / 3.14
        if movePos.y < 0 then rotation = rotation + 180 end
    elseif movePos.x > 0 then
        rotation = 90
    elseif movePos.x < 0 then
        rotation = -90
    end
    fly:setRotation(rotation)
    local flySeq = CCArray:create()
    flySeq:addObject(CCMoveBy:create(flyTime, ccp(movePos.x, movePos.y)))
    local function onAnimComplete()
        if anim then anim:removeFromParentAndCleanup(true) end
        if onAnimFinish then onAnimFinish() end
    end
    local function onFlyComplete()
        if fly then fly:removeFromParentAndCleanup(true) end
        local effect = TileDragonBoss:buildAddMoveEffect(onAnimComplete)
        effect:setScale(1.4)
        effect:setPosition(ccp(movePos.x, movePos.y))
        anim:addChild(effect)
    end
    flySeq:addObject(CCCallFunc:create(onFlyComplete))
    fly:runAction(CCSequence:create(flySeq))
    anim:addChild(fly)

    return anim
end

function TileDragonBoss:buildAddMoveFlyAnim()
    local anim = Sprite:createEmpty()
    local fly = Sprite:createWithSpriteFrameName("dragonboat_addmove_fly_0000")
    fly:setPosition(ccp(0, -100))
    local flyAnim = SpriteUtil:buildAnimate(SpriteUtil:buildFrames("dragonboat_addmove_fly_%04d", 0, 25), kEffectAnimationTime)
    
    fly:runAction(CCRepeatForever:create(flyAnim))
    anim:addChild(fly)

    return anim
end

function TileDragonBoss:buildBossComeEffect(onAnimFinish)
    local anim = Sprite:createEmpty()

    local come = Sprite:createWithSpriteFrameName("dragonboat_boss_come_0000")
    local comeAnim = SpriteUtil:buildAnimate(SpriteUtil:buildFrames("dragonboat_boss_come_%04d", 0, 12), kEffectAnimationTime)
    local function onAnimComplete()
        if anim then anim:removeFromParentAndCleanup(true) end
        if onAnimFinish then onAnimFinish() end
    end
    come:runAction(CCSequence:createWithTwoActions(comeAnim, CCCallFunc:create(onAnimComplete)))
    anim:addChild(come)

    return anim
end

function TileDragonBoss:buildHalloweenBoss()
    local bossSprite = Sprite:createWithSpriteFrameName("dragonboat_boss_icon_0000")
    local seq = CCArray:create()
    seq:addObject(SpriteUtil:buildAnimate(SpriteUtil:buildFrames('dragonboat_boss_icon_%04d', 0, 4), kEffectAnimationTime))
    seq:addObject(SpriteUtil:buildAnimate(SpriteUtil:buildFrames('dragonboat_boss_icon_%04d', 0, 4, true), kEffectAnimationTime))
    seq:addObject(CCDelayTime:create(2*kEffectAnimationTime))
    bossSprite:play(CCSequence:create(seq), 0, 1)
    return bossSprite
end

function TileDragonBoss:buildAddMoveEffect(onAnimFinish)
    local anim = Sprite:createEmpty()
    local sprite = Sprite:createWithSpriteFrameName("dragonboat_addmove_effect_0000")
    local spriteAnim = SpriteUtil:buildAnimate(SpriteUtil:buildFrames("dragonboat_addmove_effect_%04d", 0, 10), kEffectAnimationTime)
    local function onAnimComplete()
        if anim then anim:removeFromParentAndCleanup(true) end
        if onAnimFinish then onAnimFinish() end
    end
    sprite:runAction(CCSequence:createWithTwoActions(spriteAnim, CCCallFunc:create(onAnimComplete)))
    anim:addChild(sprite)
    return anim
end

function TileDragonBoss:buildAddMoveEffect2()
    local anim = Sprite:createEmpty()

    local stars = {
        {startPos=ccp(1, 2), moveBy=ccp(-1, 32), scale=15.8/32},
        {startPos=ccp(3, 4), moveBy=ccp(28, 14), scale=11.2/32},
        {startPos=ccp(5, 0), moveBy=ccp(30, -16), scale=15.8/32},
        {startPos=ccp(2, -2), moveBy=ccp(1, -36), scale=15.8/32},
        {startPos=ccp(-2, -3), moveBy=ccp(-18, -27), scale=11.8/32},
        {startPos=ccp(-4, -2), moveBy=ccp(-30, -10), scale=15.8/32},
        {startPos=ccp(-3, 2), moveBy=ccp(-24, 16), scale=13.8/32},
    }

    for _, v in pairs(stars) do
        local star = Sprite:createWithSpriteFrameName("light_crossstar")
        star:setScale(v.scale)
        star:setPosition(v.startPos)
        local seq = CCArray:create()
        seq:addObject(CCMoveBy:create(6 * kEffectAnimationTime, v.moveBy))
        seq:addObject(CCSpawn:createWithTwoActions(CCMoveBy:create(5 * kEffectAnimationTime, ccp(v.moveBy.x/6, v.moveBy.y/6)), CCScaleTo:create(4 * kEffectAnimationTime, 0)))
        star:runAction(CCSequence:create(seq))
        anim:addChild(star)
    end

    local light = Sprite:createWithSpriteFrameName("lightball1")
    anim:addChild(light)
    light:setScale(13 / 62)
    local lightSeq = CCArray:create()
    lightSeq:addObject(CCScaleTo:create(6 * kEffectAnimationTime, 30.7 / 62))
    lightSeq:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(6 * kEffectAnimationTime, 13 / 62), CCFadeOut:create(6 * kEffectAnimationTime)))
    light:runAction(CCSequence:create(lightSeq))

    local lightCircle = Sprite:createWithSpriteFrameName("light_circle")
    anim:addChild(lightCircle)
    lightCircle:setScale(39 / 108)
    lightCircle:setOpacity(0)
    local lightCircleSeq = CCArray:create()
    lightCircleSeq:addObject(CCDelayTime:create(2 * kEffectAnimationTime))
    local function setLightCircleOpacity() 
        if lightCircle then lightCircle:setOpacity(255) end
    end
    lightCircleSeq:addObject(CCCallFunc:create(setLightCircleOpacity))
    lightCircleSeq:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(5 * kEffectAnimationTime, 78 / 108), CCFadeOut:create(5 * kEffectAnimationTime)))
    lightCircle:runAction(CCSequence:create(lightCircleSeq))

    return anim
end