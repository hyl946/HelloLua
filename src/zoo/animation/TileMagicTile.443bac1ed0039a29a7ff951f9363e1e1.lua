TileMagicTile = class(CocosObject)

local kCharacterAnimationTime = 1/30

function TileMagicTile:create(level)
    local instance = TileMagicTile.new(CCNode:create())
    instance:init(level)
    return instance
end

function TileMagicTile:init(level)
    self.level = level
    if not self.bg then
        local mask = Sprite:createWithSpriteFrameName('magic_tile_mole_mask_layer_0000')
        mask:setAnchorPoint(ccp(0, 1))
        mask:setScale(0.98)

        self.bg = Sprite:createWithSpriteFrameName('magic_tile_mole_bg_0000')
        self.bg:setAnchorPoint(ccp(0, 1))
        self.bg:setPosition(ccp(0, -3))
        self.wave = Sprite:createWithSpriteFrameName('magic_tile_mole_wave_0000')
        self.wave:setAnchorPoint(ccp(0, 1))
        self.wave:setScale(1.2)
        self.clipping = ClippingNode.new(CCClippingNode:create(mask.refCocosObj))

        mask:dispose()

        self.clipping:setAlphaThreshold(0.1)
        self.clipping:setInverted(false)
        self.clipping:setContentSize(CCSizeMake(211, 140))
        self.clipping:setPositionX(-35)
        self.clipping:setPositionY(35)
        self.clipping:addChild(self.bg)
        self.clipping:addChild(self.wave)
        self.clipping:setAnchorPoint(ccp(0, 0))
        self.clipping:ignoreAnchorPointForPosition(true)
        -- self.clipping:setScale(0.95)

        local function initBubbles()
            for i = 1, 10 do
                local bubble = Sprite:createWithSpriteFrameName('magic_tile_mole_bubble_0000')
                local pos = ccp(math.random(10, 200), math.random(10, 100) - 140)
                self.clipping:addChild(bubble)
                bubble:setPosition(pos)
                local arr = CCArray:create()
                arr:addObject(CCMoveBy:create(1, ccp(0, 30)))
                arr:addObject(CCSequence:createWithTwoActions(CCSequence:createWithTwoActions(CCFadeIn:create(0.2), CCDelayTime:create(0.3)), CCFadeOut:create(0.3)))
                local spawn = CCSpawn:create(arr)
                local arr2 = CCArray:create()
                arr2:addObject(CCPlace:create(pos))
                arr2:addObject(spawn)
                arr2:addObject(CCDelayTime:create(math.random(2, 10) / 10))
                bubble:runAction(CCRepeatForever:create(CCSequence:create(arr2)))
                self.clipping:addChild(bubble)
            end
        end
        initBubbles()

        local waveStartPoint = ccp(-10, 25)
        self.wave:setPosition(waveStartPoint)
        self.wave:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCMoveBy:create(60/30, ccp(-280, 0)), CCPlace:create(waveStartPoint))))

        local bgChangeScale = 1.02
        local bgChangeTime = 20 * kCharacterAnimationTime
        self.bg:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(
            CCScaleTo:create(bgChangeTime, bgChangeScale, bgChangeScale), CCScaleTo:create(bgChangeTime, 1, 1)
            )))
       
        self:addChild(self.clipping)

        self.top = Sprite:createWithSpriteFrameName('magic_tile_mole_fg_0000')
        self.top:setAnchorPoint(ccp(0, 1))
        self.top:setPosition(ccp(-37, 40))
        self:addChild(self.top)

        self.rem = Sprite:createWithSpriteFrameName('magic_tile_mole_rem_0000')
        self.rem:setAnchorPoint(ccp(0, 1))
        self.rem:setPosition(ccp(-44, 43))
        self:addChild(self.rem)

        if self.level == 1 then
            self:playVanishCountDownAlert()
        else
            self.rem:setVisible(false)
        end
        
    end

    -- if level == 1 or __WIN32 then
    --     self.sprite = Sprite:createWithSpriteFrameName('magic_tile_dragonboat_highlight')
    --     -- self.sprite:setScale(1.01)
    --     self.sprite:setPosition(ccp(71, -35))
    --     self:addChild(self.sprite)
    -- end
    -- self:playAnim()
end

function TileMagicTile:playVanishCountDownAlert()
    self.rem:setVisible(true)

    local speed = 18
    local actArr = CCArray:create()
    actArr:addObject(CCFadeOut:create(speed * kCharacterAnimationTime))
    actArr:addObject(CCFadeIn:create(speed * kCharacterAnimationTime))
    local action = CCRepeatForever:create(CCSequence:create(actArr))
    self.rem:runAction(action)
end

function TileMagicTile:playDisappearAnimation(callback)
    self.bg:setVisible(false)
    self.wave:setVisible(false)
    self.rem:stopAllActions()
    self.rem:setVisible(false)
    self.top:setVisible(false)
    if self.sprite then
        self.sprite:setVisible(false)
    end

    local vanishAnimation = Sprite:createWithSpriteFrameName("magic_tile_mole_disappear_0000")
    vanishAnimation:setPosition(ccp(70, -35))
    self:addChild(vanishAnimation)

    local frames = SpriteUtil:buildFrames("magic_tile_mole_disappear_%04d", 0, 7)
    local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
    vanishAnimation:play(animate, 0, 1, callback, true)
end

function TileMagicTile:changeColor(color)
    if color == 'red' then
        if self.sprite then self.sprite:removeFromParentAndCleanup(true) end
        self:init(1)
    end
end

function TileMagicTile:playAnim()
    -- if self.level == 1 or __WIN32 then
    --     local a = CCArray:create()
    --     a:addObject(CCFadeOut:create(0.5))
    --     a:addObject(CCDelayTime:create(0.5))
    --     a:addObject(CCFadeIn:create(0.5))
    --     a:addObject(CCDelayTime:create(0.5))
    --     self.sprite:runAction(CCRepeatForever:create(CCSequence:create(a)))
    -- -- else
    -- --     self.bg:stopAllActions()
    -- --     local seq = CCArray:create()
    -- --     seq:addObject(CCScaleTo:create(0.8, 1.01, 1))
    -- --     seq:addObject(CCScaleTo:create(0.8, 1, 1.01))
    -- --     self.bg:runAction(CCRepeatForever:create(CCSequence:create(seq)))
    -- end
end

-- function TileMagicTile:createWaterAnim()
--     local sprite = Sprite:createWithSpriteFrameName("magic_tile_water_0000")
--     local frames = SpriteUtil:buildFrames("magic_tile_water_%04d", 0, 30)
--     local anim = CCRepeatForever:create(SpriteUtil:buildAnimate(frames, 1/18))
--     sprite:runAction(anim)
--     return sprite
-- end

-- function TileMagicTile:playBlastHitAnimation(startPoint, endPoint)
--     local layer = Layer:create()

--     local animation = Sprite:createWithSpriteFrameName("blocker_pacman_effect_hit_0000")
--     local frames = SpriteUtil:buildFrames("blocker_pacman_effect_hit_%04d", 0, 22)
--     local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
--     animation:play(animate, 0, 1, onAnimationFinished, true)

--     local angle = -math.deg(math.atan2(endPoint.y - startPoint.y, endPoint.x - startPoint.x))
--     animation:setPosition(startPoint)
--     animation:setRotation(angle)
--     animation:setAnchorPoint(ccp(0.8, 0.46))

--     local function finishCallback()
--         layer:removeFromParentAndCleanup(true) 
--     end

--     local actArr = CCArray:create()
--     actArr:addObject(CCMoveTo:create(0.4, ccp(endPoint.x , endPoint.y)))
--     -- actArr:addObject(CCDelayTime:create(0.5))
--     actArr:addObject(CCCallFunc:create(finishCallback) )
--     animation:runAction(CCSequence:create(actArr))

--     layer:addChild(animation)

--     return layer
-- end
