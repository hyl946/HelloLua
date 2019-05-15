--冬季周赛 鼹鼠
MoleAnimation = class()

local function getRealPlistPath(path)
    local plistPath = path
    if __use_small_res then  
        plistPath = table.concat(plistPath:split("."),"@2x.")
    end

    return plistPath
end

function MoleAnimation:playUseAnimation(callback)
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

    FrameLoader:loadArmature('skeleton/winter_weekly_animation', 'winter_weekly_animation', 'winter_weekly_animation')
    local anim = ArmatureNode:create('mole_ani_one')
    local anim2 = ArmatureNode:create('mole_ani_two')

    local clipping = SimpleClippingNode:create()
    clipping:setContentSize(CCSizeMake(400, 400))
    clipping:setRecalcPosition(true)
    clipping:setAnchorPoint(ccp(0.5, 0.5))
    clipping:ignoreAnchorPointForPosition(false)
    clipping:setPosition(ccp(winSize.width/2, winSize.height/2 + 110))

    -- local clipping = LayerColor:create()
    -- clipping:setColor(ccc3(255,0,0))
    -- clipping:setOpacity(150)
    -- clipping:setContentSize(CCSizeMake(400, 400))
    -- clipping:setAnchorPoint(ccp(0.5, 0.5))
    -- clipping:ignoreAnchorPointForPosition(false)
    -- clipping:setPosition(ccp(winSize.width/2, winSize.height/2 + 100))

    clipping:addChild(anim2)

    local function finishCallback()
        if container then
            container:removeFromParentAndCleanup(true)
            container = nil
        end
        if callback then
            callback()
        end
    end
    anim2:addEventListener(ArmatureEvents.COMPLETE, finishCallback)
    anim2:playByIndex(0,1)
    anim2:setPosition(ccp(60, 250))
    container:addChild(clipping)
    
    anim:playByIndex(0,1)
    anim:setPosition(ccp(winSize.width/2 - 150, winSize.height/2))
    container:addChild(anim)
end

-- function MoleAnimation:playUseAnimation(callback)
--     local winSize = Director:sharedDirector():getWinSize()
--     local vs = Director:sharedDirector():getVisibleSize()
--     local vo = Director:sharedDirector():getVisibleOrigin()
--     local scene = Director:sharedDirector():getRunningScene()

--     local container = Layer:create()
--     container:setTouchEnabled(true, 0, true)
--     scene:addChild(container)

--     local greyCover = LayerColor:create()
--     greyCover:setColor(ccc3(0,0,0))
--     greyCover:setOpacity(150)
--     greyCover:setContentSize(CCSizeMake(winSize.width, winSize.height))
--     greyCover:setPosition(ccp(0 , 0))
--     container:addChild(greyCover)

--     FrameLoader:loadArmature('skeleton/winter_weekly_animation', 'winter_weekly_animation', 'winter_weekly_animation')
--     local anim = ArmatureNode:create('mole_ani')

--     local function finishCallback()
--         if container then
--             container:removeFromParentAndCleanup(true)
--             container = nil
--         end
--         if callback then
--             callback()
--         end
--     end

--     anim:setPosition(ccp(winSize.width/2 - 140, winSize.height/2))
--     -- anim:setAnimationScale(2/2.5)
--     anim:addEventListener(ArmatureEvents.COMPLETE, finishCallback)
--     anim:playByIndex(0,1)
--     container:addChild(anim)
-- end

-- 改为使用SimpleClippingNode实现
function MoleAnimation:buildItemIcon()
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(getRealPlistPath("flash/animation/weekly_others.plist"))
    local container = Sprite:createEmpty()

    local normal_bg = Sprite:createWithSpriteFrameName('squirrel_item_normal_bg_0000')
    local normal_nut = Sprite:createWithSpriteFrameName('squirrel_item_normal_nut_0000')
    local shine_bg = Sprite:createWithSpriteFrameName('squirrel_item_shine_bg_0000')
    local shine_nut = Sprite:createWithSpriteFrameName('squirrel_item_shine_nut_0000')
    local bubble = Sprite:createWithSpriteFrameName('squirrel_item_bubble_0000')
    local grey_nut = Sprite:createWithSpriteFrameName('squirrel_item_grey_nut_0000')

    container:addChild(shine_bg)
    container:addChild(grey_nut)
    grey_nut:setScale(0.9)
    -- grey_nut:setPositionX(0)
    -- grey_nut:setPositionY(-3)
    grey_nut:setPosition(ccp(0,-2))
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
    normal_nut:setPosition(ccp(centerX + 2, centerY))
    normal_nut:setScale(1/1.3)

    container:addChild(bubble)
    bubble:setScale(1.01)
    bubble:setPosition(ccp(0, 2))
    local animate = SpriteUtil:buildAnimate(SpriteUtil:buildFrames("squirrel_item_normal_bg_%04d", 0, 30), 1/30)
    normal_bg:play(animate, 0, 0)

    container:addChild(shine_nut)
    shine_nut:setVisible(false)
    shine_nut:setPosition(ccp(-0.5,1))

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
        bg:setPosition(ccp(-7, -2))
        container:addChild(bg_star)
        container:addChild(cricle)
        container:addChild(comet)
        container:addChild(nut)
        nut:setPosition(ccp(3, -1))
        container:addChild(goldNut)
        goldNut:setPosition(ccp(-2, 2))
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