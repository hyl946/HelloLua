kCharacterAnimationTime = 1/24

local vs, vo, fireworkCenter, crakcerPos, bombPos, coonPos

local function _init()
    vs = Director:sharedDirector():getVisibleSize()
    vo = Director:sharedDirector():getVisibleOrigin()
    fireworkCenter = ccp(vs.width/2, vs.height / 2 + 230)
    crakcerPos = ccp(vs.width/2-33, 200)
    bombPos = ccp(vs.width/2, crakcerPos.y - 100)
    coonPos= ccp(vs.width/2+ 150, bombPos.y + 140)
end


SpringFestivalEffect = class()

function SpringFestivalEffect:playFirework(container, callback)

    local factor = 1
    -- if _G.isLocalDevelopMode then printx(0, ':playFirework') end

    local localContainer = Layer:create()
    local counter = 0
    local function explodeFinishCallback()
        counter = counter + 1
        if counter >= 36 then
            setTimeOut(callback, 0.5)
        end
    end

    local function getRotateAndScaleOffset(rotate)
        local rotateOffset, scaleOffset 
        if rotate > 180 then 
            rotateOffset = rotate - 360
        else
            rotateOffset = rotate
        end
        rotateOffset = rotateOffset / 180 * 8
        local scaleOffset = 1.1 - (10-math.abs(rotateOffset)*6) / 100
        return rotateOffset, scaleOffset
    end


    for i = 1, 12 do 
        local animSpeed = kCharacterAnimationTime*1.5
        local sprite = SpriteColorAdjust:createWithSpriteFrameName('firework_0000')
        local rotate = (i - 1) * 30 - 13.7


        local frames = SpriteUtil:buildAnimate(SpriteUtil:buildFrames('firework_%04d', 0, 22), animSpeed)
        local delay = 0
        sprite:play(frames, delay, 1, explodeFinishCallback)
        sprite:setAnchorPoint(ccp(0.5, 0))
        sprite:setRotation(rotate)
        sprite:setScaleY(1.2*factor)
        sprite:setScaleX(1.2*factor*0.8)
        sprite:setPosition(fireworkCenter)
        sprite:adjustColor(0, -0.5,0.7,-0.5)
        sprite:applyAdjustColorShader()

        local rotateOffset, scaleOffset = getRotateAndScaleOffset(rotate)
        local arr = CCArray:create()
        arr:addObject(CCMoveBy:create(animSpeed*22, ccp(0, -50)))
        arr:addObject(CCRotateBy:create(animSpeed*22, rotateOffset))
        arr:addObject(CCScaleBy:create(animSpeed*22, 1, scaleOffset))
        arr:addObject(CCSequence:createWithTwoActions(CCDelayTime:create(0.5), CCFadeOut:create(animSpeed*10)))
        sprite:runAction(
            CCEaseSineIn:create(CCSpawn:create(arr))
            
        )

        localContainer:addChild(sprite)
    end

    for i = 1, 12 do 
        local animSpeed = kCharacterAnimationTime*1.3
        local sprite = SpriteColorAdjust:createWithSpriteFrameName('firework_0000')
        local rotate = (i - 1) * 30
        local frames = SpriteUtil:buildAnimate(SpriteUtil:buildFrames('firework_%04d', 0, 22), animSpeed)
        local delay = 0
        sprite:play(frames, delay, 1, explodeFinishCallback)
        sprite:setAnchorPoint(ccp(0.5, 0))
        sprite:setRotation(rotate)
        sprite:setScaleY(1*factor)
        sprite:setScaleX(1*factor*0.8)
        sprite:setPosition(fireworkCenter)
        sprite:adjustColor(0, 0,0.1,0.1)
        sprite:applyAdjustColorShader()

        local rotateOffset, scaleOffset = getRotateAndScaleOffset(rotate)
        local arr = CCArray:create()
        arr:addObject(CCMoveBy:create(animSpeed*22, ccp(0, -30)))
        arr:addObject(CCRotateBy:create(animSpeed*22, rotateOffset))
        arr:addObject(CCScaleBy:create(animSpeed*22, 1, scaleOffset))
        arr:addObject(CCSequence:createWithTwoActions(CCDelayTime:create(0.5), CCFadeOut:create(animSpeed*10)))
        sprite:runAction(
            CCEaseSineIn:create(CCSpawn:create(arr))
            
        )
        localContainer:addChild(sprite)
    end
    for i = 1, 12 do 
        local animSpeed = kCharacterAnimationTime*1.15
        local sprite = SpriteColorAdjust:createWithSpriteFrameName('firework_0000')
        local rotate = (i - 1) * 30 + 13.7
        local frames = SpriteUtil:buildAnimate(SpriteUtil:buildFrames('firework_%04d', 0, 22), animSpeed)
        local delay = 0
        sprite:play(frames, delay, 1, explodeFinishCallback)
        sprite:setAnchorPoint(ccp(0.5, 0))
        sprite:setRotation(rotate)
        sprite:setPosition(fireworkCenter)
        sprite:setScaleY(0.7*factor)
        sprite:setScaleX(0.7*factor*0.8)
        sprite:adjustColor(-0.51, 0,0.1,0.1)
        sprite:applyAdjustColorShader()

        local rotateOffset, scaleOffset = getRotateAndScaleOffset(rotate)
        local arr = CCArray:create()
        arr:addObject(CCMoveBy:create(animSpeed*22, ccp(0, -15)))
        arr:addObject(CCRotateBy:create(animSpeed*22, rotateOffset))
        arr:addObject(CCScaleBy:create(animSpeed*22, 1, scaleOffset))
        arr:addObject(CCSequence:createWithTwoActions(CCDelayTime:create(0.5), CCFadeOut:create(animSpeed*10)))
        sprite:runAction(
            CCEaseSineIn:create(CCSpawn:create(arr))
            
        )

        localContainer:addChild(sprite)
    end
    for i = 1, 12 do 
        local animSpeed = kCharacterAnimationTime*1.0
        local sprite = SpriteColorAdjust:createWithSpriteFrameName('firework_0000')
        local rotate = (i - 1) * 30
        local frames = SpriteUtil:buildAnimate(SpriteUtil:buildFrames('firework_%04d', 0, 22), animSpeed)
        local delay = 0
        sprite:play(frames, delay, 1, explodeFinishCallback)
        sprite:setAnchorPoint(ccp(0.5, 0))
        sprite:setRotation(rotate)
        sprite:setPosition(fireworkCenter)
        sprite:setScaleY(0.4*factor)
        sprite:setScaleX(0.4*factor*0.8)
        sprite:adjustColor(-1, 0,0.1,0.1)
        sprite:applyAdjustColorShader()
        
        local rotateOffset, scaleOffset = getRotateAndScaleOffset(rotate)
        local arr = CCArray:create()
        arr:addObject(CCMoveBy:create(animSpeed*22, ccp(0, -10)))
        arr:addObject(CCRotateBy:create(animSpeed*22, rotateOffset))
        arr:addObject(CCScaleBy:create(animSpeed*22, 1, scaleOffset))
        arr:addObject(CCSequence:createWithTwoActions(CCDelayTime:create(0.5), CCFadeOut:create(animSpeed*10)))
        sprite:runAction(
            CCEaseSineIn:create(CCSpawn:create(arr))
            
        )

        localContainer:addChild(sprite)
    end
    container:addChild(localContainer)
end

function SpringFestivalEffect:playMegaPropSkillComeIn(container, callback)
    local scene = Director:sharedDirector():getRunningScene()
    local sprite = Sprite:createWithSpriteFrameName('cracker_0000')
    sprite:setAnchorPoint(ccp(0, 0))
    sprite:setPosition(crakcerPos)
    sprite:runAction(CCSequence:createWithTwoActions(CCEaseBounceOut:create(CCMoveBy:create(0.2, ccp(0, -100))), CCCallFunc:create(callback)))
    container:addChild(sprite)
    return sprite
end

function SpringFestivalEffect:playFuze(sprite, callback)
    local frames = SpriteUtil:buildAnimate(SpriteUtil:buildFrames('cracker_%04d', 1, 6), kCharacterAnimationTime)
    local function localCB()
        callback()
        sprite:runAction(CCFadeOut:create(0.5))
    end
    sprite:play(frames, 0, 1, localCB)
end

function SpringFestivalEffect:playCoon(container, callback)
    -- if _G.isLocalDevelopMode then printx(0, ':playCoon') end
    FrameLoader:loadArmature('skeleton/spring_animation')
    local node = ArmatureNode:create("spring_coon")
    node:setAnchorPoint(ccp(0.5, 0.5))
    node:setPosition(ccp(vs.width + 200, coonPos.y))
    container:addChild(node)

    local function cleanup()
        local sprite = Sprite:createWithSpriteFrameName('spring_coon_0000')
        local hat = Sprite:createWithSpriteFrameName('spring_coon_hat_0000')
        sprite:setPosition(coonPos)
        sprite:setAnchorPoint(ccp(0.5, 0.5))
        sprite:setScale(2)
        node:runAction(
                CCSpawn:createWithTwoActions(
                    CCFadeOut:create(0.3),
                    CCMoveTo:create(0.4, ccp(vs.width + 400, coonPos.y))
                )
            )
        sprite:runAction(
                CCSpawn:createWithTwoActions(CCFadeIn:create(0.1), CCMoveTo:create(0.4, ccp(vs.width + 400, coonPos.y)))
                
                )
        container:addChild(sprite)
        hat:setPosition(ccp(coonPos.x + 30, coonPos.y + 100))
        hat:runAction(
            CCSpawn:createWithTwoActions(
                CCRotateBy:create(0.5, -720),
                CCEaseExponentialIn:create(
                    CCSpawn:createWithTwoActions(
                        CCFadeOut:create(0.4),
                        CCMoveBy:create(0.4, ccp(0, -300)))
                    )
                )
            )
        container:addChild(hat)
        if callback then callback() end
    end

    local function arrive()
        node:playByIndex(0)
        node:setAnimationScale(0.5)
        setTimeOut(cleanup, 0.5)
    end
    node:runAction(
        CCSequence:createWithTwoActions(
            CCMoveTo:create(0.3, coonPos),
            CCCallFunc:create(arrive)
            )
        )
end

function SpringFestivalEffect:playBombRise(container, callback)
    -- if _G.isLocalDevelopMode then printx(0, ':playBombRise') end
    local sprite = Sprite:createWithSpriteFrameName('spring_bomb_0000')
    local function localCallback()
        sprite:runAction(CCFadeOut:create(0.1))
        if callback then callback() end
    end
    sprite:setAnchorPoint(ccp(0.5, 0))
    sprite:runAction(
        CCSequence:createWithTwoActions(
            CCMoveBy:create(0.5, ccp(0, fireworkCenter.y - crakcerPos.y)),
            CCCallFunc:create(localCallback)
            )
        )
    sprite:setPosition(bombPos)
    container:addChild(sprite)
end

function SpringFestivalEffect:playFireworkAnimation(callback)
    _init()
    local container = Layer:create()
    local scene = Director:sharedDirector():getRunningScene()
    container:setPosition(ccp(vo.x, vo.y))
    local greyCover = LayerColor:create()
    greyCover:setColor(ccc3(0,0,0))
    greyCover:setOpacity(150)
    greyCover:setContentSize(CCSizeMake(vs.width, vs.height))
    greyCover:setPosition(ccp(0, 0))
    container:addChild(greyCover)
    scene:addChild(container)
    container:setPosition(ccp(vo.x, vo.y))
    container:setTouchEnabled(true, 0, true)

    local sprite

    local function allFinishCallback()
        if container and container.refCocosObj then
            container:removeFromParentAndCleanup(true)
        end
        if callback then callback() end
    end

    local function bombRiseCallback()
        self:playFirework(container, allFinishCallback)
    end
    local function fuzeCallback()
        self:playBombRise(container, bombRiseCallback)
    end
    local function coonCallback()
        self:playFuze(sprite, fuzeCallback)
    end
    local function crackerComeinCallback()        
        self:playCoon(container, coonCallback)
    end
    sprite = self:playMegaPropSkillComeIn(container, crackerComeinCallback)

end
