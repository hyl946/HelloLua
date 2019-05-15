SquirrelAnimation = class()


local function getRealPlistPath(path)
    local plistPath = path
    if __use_small_res then  
        plistPath = table.concat(plistPath:split("."),"@2x.")
    end

    return plistPath
end

function SquirrelAnimation:playUseAnimation(callback)
    local winSize = Director:sharedDirector():getWinSize()
    local vs = Director:sharedDirector():getVisibleSize()
    local vo = Director:sharedDirector():getVisibleOrigin()
    local scene = Director:sharedDirector():getRunningScene()

    local container = Layer:create()
    container:setTouchEnabled(true, 0, true)
    scene:addChild(container)

    local greyCover = LayerColor:create()
    greyCover:setColor(ccc3(0,0,0))
    greyCover:setOpacity(150)
    greyCover:setContentSize(CCSizeMake(winSize.width, winSize.height))
    greyCover:setPosition(ccp(0 , 0))
    container:addChild(greyCover)

    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(getRealPlistPath("flash/dig_block.plist"))

    FrameLoader:loadArmature('skeleton/autumn_weekly_animation', 'autumn_weekly_animation', 'autumn_weekly_animation')
    local walkingAnim = ArmatureNode:create('squirrel_with_basket')
    local grimaceAnim = ArmatureNode:create('squirrel_with_grimace')
    local walkingDuration = 2




    local function finishCallback()
        if container then
            container:removeFromParentAndCleanup(true)
            container = nil
        end
        if callback then
            callback()
        end
    end

    local function removeWalkingAnim()
        if walkingAnim then
            walkingAnim:removeFromParentAndCleanup(true)
            walkingAnim = nil
        end
        container:addChild(grimaceAnim)
        grimaceAnim:setPosition(ccp(0-50, 400))
    end

    local function removeGrimaceAnim()
        if grimaceAnim then
            grimaceAnim:removeFromParentAndCleanup(true)
            grimaceAnim = nil
        end
        finishCallback()
    end

    -- 漫天落下的坚果
    for i = 1, 30 do
        local destY = 50
        local squirrel = Sprite:createWithSpriteFrameName('dig_jewel_blue_0000')
        local x = math.random(1, vs.width)
        local delay = math.random(0, 15) / 10
        local bounceX = math.random(-20, 20)
        local bounceHeight = math.random(30, 60)
        local scale = math.random(80, 120) / 100
        local dropTime = math.random(70, 130) / 100 * 1.5
        local arr = CCArray:create()
        arr:addObject(CCDelayTime:create(delay))
        -- arr:addObject(
        --     CCSpawn:createWithTwoActions(
        --         CCRotateBy:create(1.5, math.random(-270, 270)), 
        --         -- CCEaseExponentialIn:create(CCMoveBy:create(1.8, ccp(0, -vs.height + 100)))
        --         CCMoveBy:create(1.5, ccp(0, destY - (vs.height + 50)))
        --         )
        --     )
        -- arr:addObject(
        --     CCSpawn:createWithTwoActions(
        --     CCSequence:createWithTwoActions(
        --         CCEaseSineOut:create(CCMoveTo:create(0.15, ccp(x - bounceX/2, bounceHeight+destY))),
        --         CCEaseSineIn:create(CCMoveTo:create(0.15, ccp(x - bounceX, destY)))
        --         ),
        --     CCRotateBy:create(0.3, math.random(-180, 180))
        --     )
        -- )

        arr:addObject(
            CCSpawn:createWithTwoActions(
                CCMoveBy:create(dropTime, ccp(0, destY - (vo.y + vs.height + 50))),
                CCSequence:createWithTwoActions(CCDelayTime:create(dropTime*(8/15)), CCFadeOut:create(0.2))
                )
            
            )
        squirrel:setPosition(ccp(x, vo.y + vs.height + 50))
        container:addChild(squirrel)
        squirrel:setScale(scale)
        squirrel:runAction(CCSequence:create(arr))

    end

    -- 落到篮子里的坚果
    local walkDelay = 0.4
    local distance = vs.width + 350
    local startX = vs.width + 50
    local walkTime = 2.5 -- sec
    local speed = distance / walkTime

    local receivingPoints = {150, 250, 350, 450, 550, 650} -- px
    local squirrelFlyTime = 0.6
    local offsetX = 0
    for k, v in pairs(receivingPoints) do
        local delay = walkDelay + v / speed - squirrelFlyTime
        local startPos = ccp(startX - v - offsetX, vo.y + vs.height + 50)
        local endPos = ccp(startX - v + 90, vo.y + 50 + 330)
        local arr = CCArray:create()
        arr:addObject(CCDelayTime:create(delay))
        arr:addObject(CCEaseSineInOut:create(HeBezierTo:create(squirrelFlyTime, endPos, false, 50)))
        arr:addObject(CCHide:create())
        local sprite = Sprite:createWithSpriteFrameName('dig_jewel_blue_0000')
        sprite:setScale(1.3)
        sprite:setPosition(startPos)
        sprite:runAction(CCSequence:create(arr))
        container:addChild(sprite)
    end

    -- 松鼠身后走sine曲线的小星星
    local stars = Layer:create()

    for i=1, 20 do
        local star = ArmatureNode:create('xingguan2')
        star:setPositionX(math.random(1, 100))
        star:setPositionY(math.random(1, 30))

        local function start()
            star:runAction(
            CCRepeatForever:create(CCSequence:createWithTwoActions(
                CCEaseSineInOut:create(CCMoveBy:create(0.7, ccp(0, 50))),
                CCEaseSineInOut:create(CCMoveBy:create(0.7, ccp(0, -50)))
                )
                ))
            star:runAction(CCMoveBy:create(3, ccp(600, 0)))
            star:runAction(CCRotateBy:create(3, 720))
            local arr = CCArray:create()
            arr:addObject(CCFadeIn:create(0.5))
            arr:addObject(CCDelayTime:create(1))
            arr:addObject(CCFadeOut:create(1))
            star:runAction(CCSequence:create(arr))
        end

        local arr2 = CCArray:create()
        arr2:addObject(CCHide:create())
        arr2:addObject(CCDelayTime:create(math.random(1, 200)/100))
        arr2:addObject(CCShow:create())
        arr2:addObject(CCCallFunc:create(start))
        star:runAction(CCSequence:create(arr2))
        stars:addChild(star)
    end
    container:addChild(stars)
    stars:setPosition(ccp(startX + 100, vo.y + 100))
    stars:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(walkDelay), CCMoveBy:create(walkTime*2, ccp(-distance*2, 0))))


    walkingAnim:setPosition(ccp(startX, vo.y + 400))
    walkingAnim:setAnimationScale(2/2.5)
    walkingAnim:addEventListener(ArmatureEvents.COMPLETE, removeWalkingAnim)
    walkingAnim:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(walkDelay), CCMoveBy:create(walkTime, ccp(-distance, 0))))
    walkingAnim:playByIndex(0,1)
    container:addChild(walkingAnim)
    grimaceAnim:addEventListener(ArmatureEvents.COMPLETE, removeGrimaceAnim)
    grimaceAnim:setAnimationScale(0.8)
    grimaceAnim:playByIndex(0,1)
end

function SquirrelAnimation:buildItemIcon2()
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(getRealPlistPath("flash/animation/nut_item.plist"))
    local container = Sprite:createEmpty()

    local normal_bg = Sprite:createWithSpriteFrameName('squirrel_item_normal_bg_0000')
    local normal_nut = Sprite:createWithSpriteFrameName('squirrel_item_normal_nut_0000')
    local shine_bg = Sprite:createWithSpriteFrameName('squirrel_item_shine_bg_0000')
    local shine_nut = Sprite:createWithSpriteFrameName('squirrel_item_shine_nut_0000')
    local bubble = Sprite:createWithSpriteFrameName('squirrel_item_bubble_0000')
    local grey_nut = Sprite:createWithSpriteFrameName('squirrel_item_grey_nut_0000')


    container:addChild(shine_bg)
    container:addChild(grey_nut)
    grey_nut:setScale(0.95)
    grey_nut:setPositionX(1)
    grey_nut:setPositionY(-3)
    shine_bg:setVisible(false)

    local adjustY = -2

    local size = normal_bg:getGroupBounds().size
    local rect = {size = {width = size.width, height = size.height + 2}}
    local baseOffsetX = size.width / 2
    local baseOffsetY =  size.height / 2
    -- local clipping = ClippingNode:create(rect)
    local clipping = SimpleClippingNode:create()
    clipping:setContentSize(CCSizeMake(rect.size.width, rect.size.height))
    clipping:setRecalcPosition(true)
    clipping:setAnchorPoint(ccp(0, 0))
    -- local clipping = LayerColor:create()
    -- clipping:setContentSize(CCSizeMake(rect.size.width, rect.size.height))
    clipping:addChild(normal_bg)
    clipping:addChild(normal_nut)
    normal_bg:setPosition(ccp(baseOffsetX, baseOffsetY+adjustY))
    normal_nut:setPosition(ccp(baseOffsetX, baseOffsetY+adjustY))
    normal_nut:setScale(1/1.37)
    clipping:setPosition(ccp(-baseOffsetX, -baseOffsetY-adjustY+0.5))
    -- container:addChild(normal_bg)
    container:addChild(clipping)
    container:addChild(bubble)
    bubble:setScale(1.01)
    bubble:setPosition(ccp(0, 2))
    local animate = SpriteUtil:buildAnimate(SpriteUtil:buildFrames("squirrel_item_normal_bg_%04d", 0, 30), 1/30)
    normal_bg:play(animate, 0, 0)

    container:addChild(shine_nut)
    shine_nut:setVisible(false)

    local circleMask = Sprite:createWithSpriteFrameName('squirrel_item_normal_bg_0000')
    local waveClipping = ClippingNode.new(CCClippingNode:create(circleMask.refCocosObj))
    local wave = Sprite:createWithSpriteFrameName('squirrel_item_wave_0000')
    local animate2 = SpriteUtil:buildAnimate(SpriteUtil:buildFrames("squirrel_item_wave_%04d", 0, 20), 1/24)
    wave:play(animate2, 0, 0)
    wave:setPositionY(-baseOffsetY)
    -- wave:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCMoveBy:create(3, ccp(0, 120)), CCMoveBy:create(3, ccp(0, -120)))))
    waveClipping:setAnchorPoint(ccp(0, 0))
    waveClipping:setAlphaThreshold(0.1)
    waveClipping:addChild(wave)
    waveClipping:setPosition(ccp(0, adjustY+1))
    container:addChild(waveClipping)


    container.bubble = bubble
    container.normal_bg = normal_bg
    container.normal_nut = normal_nut
    container.clipping = clipping
    container.shine_bg = shine_bg
    container.shine_nut = shine_nut
    container.wave = wave
    container.waveClipping = waveClipping


    container.setPercent = function (_self, percent, playAnim)
        if percent > 1 then percent = 1 end
        if percent < 0 then percent = 0 end

        if _self.percent == 1 and percent == 1 then
            return
        end
        

        _self.wave:setOpacity(130)


        local function arriveCheck()
            if _self.percent == 1 or _self.percent == 0 then
                _self.wave:runAction(CCFadeOut:create(0.1))
            end
        end

        local length = 120
        local y = ( 1- percent) * length 

        if not playAnim then 
            _self.normal_bg:setPositionY(baseOffsetY+y)
            _self.normal_nut:setPositionY(baseOffsetY+y)
            _self.clipping:setPositionY(-baseOffsetY-y)
            _self.clipping:doRecalcPosition()
            arriveCheck()
        else
            _self.normal_bg:stopActionByTag(123)
            _self.normal_nut:stopActionByTag(123)
            _self.clipping:stopAllActions()
            local action1 = CCMoveTo:create(0.5, ccp(baseOffsetX, baseOffsetY+y))
            action1:setTag(123)
            _self.normal_bg:runAction(action1)
            local action2 = CCMoveTo:create(0.5, ccp(baseOffsetX, baseOffsetY+y))
            action2:setTag(123)
            _self.normal_nut:runAction(action2)
            _self.clipping:runAction(CCMoveTo:create(0.5, ccp(-baseOffsetX, -baseOffsetY-y)))
            _self.wave:stopActionByTag(123)
            local action3 = CCSequence:createWithTwoActions(CCMoveTo:create(0.5, ccp(0, -baseOffsetY+length-y)), CCCallFunc:create(arriveCheck))
            action3:setTag(123)
            _self.wave:runAction(action3)
        end

        _self.percent = percent
    
        if _self.percent >= 1 then
          _self:playGolden(true)
        else
            _self:playGolden(false)
        end
    end

    container.playGolden = function (_self, enable)
        if enable then
            _self.shine_bg:setVisible(true)
            _self.shine_bg:setOpacity(0)
            _self.shine_nut:setVisible(true)
            _self.shine_bg:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCFadeIn:create(0.6), CCFadeOut:create(0.6))))
            _self.shine_nut:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCFadeIn:create(0.6), CCFadeOut:create(0.6))))

        else
            _self.shine_bg:setVisible(false)
            _self.shine_nut:setVisible(false)
            _self.shine_bg:stopAllActions()
            _self.shine_nut:stopAllActions()
        end
    end 

    container.playFlyNut = function (_self)
        local vs = Director:sharedDirector():getVisibleSize()
        local vo = Director:sharedDirector():getVisibleOrigin()
        local scene = Director:sharedDirector():getRunningScene()
        if not scene then return end
        local container = Layer:create()
        local nut = Sprite:createWithSpriteFrameName('squirrel_item_normal_nut_0000')
        local goldNut = Sprite:createWithSpriteFrameName('squirrel_item_gold_nut_0000')
        local comet = Sprite:createWithSpriteFrameName('squirrel_item_comet_0000')
        local cricle = Sprite:createWithSpriteFrameName('squirrel_item_circle_0000')
        local bg = Sprite:createWithSpriteFrameName('squirrel_item_bg_0000')
        local bg_star = Sprite:createWithSpriteFrameName('squirrel_item_bg_star_0000')
        container:addChild(bg)
        container:addChild(bg_star)
        container:addChild(cricle)
        container:addChild(comet)
        container:addChild(nut)
        container:addChild(goldNut)
        goldNut:setOpacity(0)
        comet:setAnchorPoint(ccp(0, 1))
        comet:setPosition(ccp(-50, 50))
        local startPos = _self.shine_nut:getParent():convertToWorldSpace(_self.shine_nut:getPosition())
        scene:addChild(container)
        container:setPosition(scene:convertToNodeSpace(startPos))
        local animate = SpriteUtil:buildAnimate(SpriteUtil:buildFrames("squirrel_item_comet_%04d", 0, 13), 1/24)
        comet:play(animate, 0, 1)

        local destPos = ccp(vo.x+vs.width/2, vo.y+vs.height/2)

        local function remove()
            if container then 
                container:removeFromParentAndCleanup(true)
                container = nil
                _self.flyAnim = nil
            end
        end

        local function onArrive()
            local animate = SpriteUtil:buildAnimate(SpriteUtil:buildFrames("squirrel_item_circle_%04d", 0, 16), 1/30)
            cricle:play(animate, 0, 1, remove)            
        end

        local function onWait()
            goldNut:runAction(CCRepeat:create(CCSequence:createWithTwoActions(CCFadeTo:create(0.5*0.75, 255), CCFadeTo:create(0.5*0.75, 0)), 2))
            local arr_bg = CCArray:create()
            arr_bg:addObject(CCScaleTo:create(0.1*0.75, 1))  
            arr_bg:addObject(CCDelayTime:create(1.85*0.75))
            arr_bg:addObject(CCScaleTo:create(0.05*0.75, 0))
            bg:runAction(CCSequence:create(arr_bg))
            bg:runAction(CCRotateBy:create(3, 180))
            bg_star:runAction(CCSequence:createWithTwoActions(CCScaleTo:create(0.4*0.75, 1), CCHide:create()))
        end

        bg:setScale(0)
        bg_star:setScale(0)


        local arr = CCArray:create()
        arr:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(13/24, 1), CCEaseSineOut:create(CCMoveTo:create(13/24, destPos))))
        arr:addObject(CCCallFunc:create(onWait))
        arr:addObject(CCDelayTime:create(2*0.75))
        arr:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(13/24, 1/1.5), CCEaseSineIn:create(CCMoveTo:create(13/24, startPos))))
        arr:addObject(CCCallFunc:create(onArrive))
        container:runAction(CCSequence:create(arr))
        _self.flyAnim = container

    end   

    container.cancelFlyAnim = function (_self)
        if not _self.flyAnim then return end
        _self.flyAnim:removeFromParentAndCleanup(true)
        _self.flyAnim = nil
    end

    return container
end

-- 改为使用SimpleClippingNode实现
function SquirrelAnimation:buildItemIcon()
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(getRealPlistPath("flash/animation/nut_item.plist"))
    local container = Sprite:createEmpty()

    local normal_bg = Sprite:createWithSpriteFrameName('squirrel_item_normal_bg_0000')
    local normal_nut = Sprite:createWithSpriteFrameName('squirrel_item_normal_nut_0000')
    local shine_bg = Sprite:createWithSpriteFrameName('squirrel_item_shine_bg_0000')
    local shine_nut = Sprite:createWithSpriteFrameName('squirrel_item_shine_nut_0000')
    local bubble = Sprite:createWithSpriteFrameName('squirrel_item_bubble_0000')
    local grey_nut = Sprite:createWithSpriteFrameName('squirrel_item_grey_nut_0000')

    container:addChild(shine_bg)
    container:addChild(grey_nut)
    grey_nut:setScale(0.95)
    grey_nut:setPositionX(1)
    grey_nut:setPositionY(-3)
    shine_bg:setVisible(false)

    local adjustY = -2

    local size = normal_bg:getGroupBounds().size
    local contentWidth = size.width
    local contentHeight = size.height + 2
    local centerX = contentWidth / 2
    local centerY = contentHeight / 2

    local clipping = SimpleClippingNode:create()
    clipping:setContentSize(CCSizeMake(contentWidth, contentHeight))
    clipping:setRecalcPosition(true)
    clipping:setAnchorPoint(ccp(0.5, 0))
    clipping:ignoreAnchorPointForPosition(false)
    clipping:setPosition(ccp(0, -centerY))
    container:addChild(clipping)

    clipping:addChild(normal_bg)
    clipping:addChild(normal_nut)

    normal_bg:setPosition(ccp(centerX, centerY))
    normal_nut:setPosition(ccp(centerX, centerY))
    normal_nut:setScale(1/1.36)

    container:addChild(bubble)
    bubble:setScale(1.01)
    bubble:setPosition(ccp(0, 2))
    local animate = SpriteUtil:buildAnimate(SpriteUtil:buildFrames("squirrel_item_normal_bg_%04d", 0, 30), 1/30)
    normal_bg:play(animate, 0, 0)

    container:addChild(shine_nut)
    shine_nut:setVisible(false)

    local waveClipping = SimpleClippingNode:create()
    waveClipping:setContentSize(CCSizeMake(contentWidth, contentHeight))
    waveClipping:setRecalcPosition(true)
    waveClipping:setAnchorPoint(ccp(0.5, 0))
    waveClipping:ignoreAnchorPointForPosition(false)
    waveClipping:setPosition(ccp(1, -centerY))
    container:addChild(waveClipping)

    local wave = Sprite:createWithSpriteFrameName('squirrel_item_wave_0000')
    local animate2 = SpriteUtil:buildAnimate(SpriteUtil:buildFrames("squirrel_item_wave_%04d", 0, 20), 1/24)
    wave:play(animate2, 0, 0)
    wave:setPosition(ccp(centerX, 0))
    waveClipping:addChild(wave)

    container.bubble = bubble
    container.normal_bg = normal_bg
    container.normal_nut = normal_nut
    container.clipping = clipping
    container.shine_bg = shine_bg
    container.shine_nut = shine_nut
    container.wave = wave
    container.waveClipping = waveClipping

    container.setPercent = function (_self, percent, playAnim)
        if percent > 1 then percent = 1 end
        if percent < 0 then percent = 0 end

        if _self.percent == 1 and percent == 1 then
            return
        end
        _self.percent = percent

        _self:unscheduleUpdate()
        _self.wave:setOpacity(255*0.6)
        local function arriveCheck()
            if _self.percent == 1 or _self.percent == 0 then
                -- _self.wave:runAction(CCFadeOut:create(0.1))
                _self.wave:setOpacity(0)
            end
        end

        local function calcWaveClippingWidth(height)
            local r = contentHeight / 2
            local a = r - height
            local width = 0
            if a >= -r and a <= r then
                width = math.sqrt(r * r - a * a) * 2
            end
            -- 因为波浪位置有点儿偏下，上下部分需要做不同的宽度调整
            local fixScale = a > 0 and 0.2 or 0.1
            width = width - width * math.abs(a/r) * fixScale
            return width
        end 

        local offsetY = 2
        local waveTargetPosY = contentHeight*percent+offsetY
        local clippingTargetHeight = contentHeight*percent+offsetY+2
        if not playAnim then 
            _self.wave:setPositionY(waveTargetPosY)
            _self.waveClipping:setContentSize(CCSizeMake(calcWaveClippingWidth(waveTargetPosY), contentHeight))
            _self.clipping:setContentSize(CCSizeMake(contentWidth, clippingTargetHeight))
            arriveCheck()
        else
            local totalDt = 0
            local animateTime = 0.5

            local waveOriPosY = _self.wave:getPositionY()
            local clippingOriHeight = _self.clipping:getContentSize().height + 1
            local function updateFunc(dt)
                totalDt = totalDt + dt
                local finished = false
                local wavePosY = waveTargetPosY
                local clippingHeight = clippingTargetHeight
                if totalDt < animateTime then
                    wavePosY = waveOriPosY + (waveTargetPosY - waveOriPosY) * totalDt / animateTime
                    clippingHeight = clippingOriHeight + (clippingTargetHeight - clippingOriHeight) * totalDt / animateTime
                else
                    finished = true
                end
                _self.wave:setPositionY(wavePosY)
                _self.clipping:setContentSize(CCSizeMake(contentWidth, clippingHeight))
                _self.waveClipping:setContentSize(CCSizeMake(calcWaveClippingWidth(wavePosY), contentHeight))

                if finished then
                    arriveCheck()
                    _self:unscheduleUpdate()
                end
            end
            _self:scheduleUpdateWithPriority(updateFunc, 0)
        end
    
        if _self.percent >= 1 then
          _self:playGolden(true)
        else
            _self:playGolden(false)
        end
    end

    container.playGolden = function (_self, enable)
        if enable then
            _self.shine_bg:setVisible(true)
            _self.shine_bg:setOpacity(0)
            _self.shine_nut:setVisible(true)
            _self.shine_bg:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCFadeIn:create(0.6), CCFadeOut:create(0.6))))
            _self.shine_nut:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCFadeIn:create(0.6), CCFadeOut:create(0.6))))

        else
            _self.shine_bg:setVisible(false)
            _self.shine_nut:setVisible(false)
            _self.shine_bg:stopAllActions()
            _self.shine_nut:stopAllActions()
        end
    end 

    container.playFlyNut = function (_self)
        local vs = Director:sharedDirector():getVisibleSize()
        local vo = Director:sharedDirector():getVisibleOrigin()
        local scene = Director:sharedDirector():getRunningScene()
        if not scene then return end
        local container = Layer:create()
        local nut = Sprite:createWithSpriteFrameName('squirrel_item_normal_nut_0000')
        local goldNut = Sprite:createWithSpriteFrameName('squirrel_item_gold_nut_0000')
        local comet = Sprite:createWithSpriteFrameName('squirrel_item_comet_0000')
        local cricle = Sprite:createWithSpriteFrameName('squirrel_item_circle_0000')
        local bg = Sprite:createWithSpriteFrameName('squirrel_item_bg_0000')
        local bg_star = Sprite:createWithSpriteFrameName('squirrel_item_bg_star_0000')
        container:addChild(bg)
        container:addChild(bg_star)
        container:addChild(cricle)
        container:addChild(comet)
        container:addChild(nut)
        container:addChild(goldNut)
        goldNut:setOpacity(0)
        comet:setAnchorPoint(ccp(0, 1))
        comet:setPosition(ccp(-50, 50))
        local startPos = _self.shine_nut:getParent():convertToWorldSpace(_self.shine_nut:getPosition())
        scene:addChild(container)
        container:setPosition(scene:convertToNodeSpace(startPos))
        local animate = SpriteUtil:buildAnimate(SpriteUtil:buildFrames("squirrel_item_comet_%04d", 0, 13), 1/24)
        comet:play(animate, 0, 1)

        local destPos = ccp(vo.x+vs.width/2, vo.y+vs.height/2)

        local function remove()
            if container then 
                container:removeFromParentAndCleanup(true)
                container = nil
                _self.flyAnim = nil
            end
        end

        local function onArrive()
            local animate = SpriteUtil:buildAnimate(SpriteUtil:buildFrames("squirrel_item_circle_%04d", 0, 16), 1/30)
            cricle:play(animate, 0, 1, remove)            
        end

        local function onWait()
            goldNut:runAction(CCRepeat:create(CCSequence:createWithTwoActions(CCFadeTo:create(0.5*0.75, 255), CCFadeTo:create(0.5*0.75, 0)), 2))
            local arr_bg = CCArray:create()
            arr_bg:addObject(CCScaleTo:create(0.1*0.75, 1))  
            arr_bg:addObject(CCDelayTime:create(1.85*0.75))
            arr_bg:addObject(CCScaleTo:create(0.05*0.75, 0))
            bg:runAction(CCSequence:create(arr_bg))
            bg:runAction(CCRotateBy:create(3, 180))
            bg_star:runAction(CCSequence:createWithTwoActions(CCScaleTo:create(0.4*0.75, 1), CCHide:create()))
        end

        bg:setScale(0)
        bg_star:setScale(0)


        local arr = CCArray:create()
        arr:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(13/24, 1), CCEaseSineOut:create(CCMoveTo:create(13/24, destPos))))
        arr:addObject(CCCallFunc:create(onWait))
        arr:addObject(CCDelayTime:create(2*0.75))
        arr:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(13/24, 1/1.5), CCEaseSineIn:create(CCMoveTo:create(13/24, startPos))))
        arr:addObject(CCCallFunc:create(onArrive))
        container:runAction(CCSequence:create(arr))
        _self.flyAnim = container

    end   

    container.cancelFlyAnim = function (_self)
        if not _self.flyAnim then return end
        _self.flyAnim:removeFromParentAndCleanup(true)
        _self.flyAnim = nil
    end

    container:setPercent(0)

    return container
end