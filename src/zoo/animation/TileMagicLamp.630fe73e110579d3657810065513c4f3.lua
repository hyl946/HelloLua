TileMagicLamp = class(CocosObject)

TileMagicLampBody = class(CocosObject)

function TileMagicLampBody:create(color, level)
    local node = TileMagicLampBody.new(CCNode:create())
    node:init(color, level)
    return node
end

function TileMagicLampBody:init(color, level)
    self:initBody(color, level)
end

function TileMagicLampBody:clearBody()
    if self.border then
        self.border:removeFromParentAndCleanup(true)
        self.border = nil
    end
    if self.body then
        self.body:removeFromParentAndCleanup(true)
        self.body = nil
    end
end

function TileMagicLampBody:initBody(color, level)
    self.level = level
    self.color = color

    self.body = SpriteColorAdjust:createWithSpriteFrameName(string.format('magic_lamp_level_%d_0000', level))
    self.border = Sprite:createWithSpriteFrameName(string.format('magic_lamp_level_%d_border_0000', level))

    self:addChild(self.border)
    self:addChild(self.body)

    if level == 1 then
        self.body:setPosition(ccp(0, 0))
        self.border:setPosition(ccp(1, -4))
    elseif level == 2 then
        self.body:setPosition(ccp(0, 0))
        self.border:setPosition(ccp(0.5, -4))
    elseif level == 3 then
        self.body:setPosition(ccp(0, 0))
        self.border:setPosition(ccp(0.5, -4))
    else
        if level > 4 then level = 4 end
        self.body:setPosition(ccp(0, 1))
        self.border:setPosition(ccp(1, -3))
    end
    self:setColor(color)
end

local MagicLampHSBC = {
    [AnimalTypeConfig.kBlue]    = {-0.0366, 0.0910, 0.0477, 0.1115},
    [AnimalTypeConfig.kGreen]   = {-0.4094, 0.1439, 0.0477, 0.2293},
    [AnimalTypeConfig.kOrange]  = {-0.9152, 0.0801, -0.0106, 0.1763},
    [AnimalTypeConfig.kPurple]  = {0.3784, 0.0380, -0.0798, 0.1861},
    [AnimalTypeConfig.kRed]     = {0.9220, -0.0906, -0.0906, 0.1763},
    [AnimalTypeConfig.kYellow]  = {-0.8677, 0.7351, 0.2876, 0.5481},
}
local function getColorHSBC(hbscMap, colorType)
    assert(type(hbscMap) == "table")
    if hbscMap then
        for color, hbsc in pairs(hbscMap) do
            if color == colorType then
                return hbsc
            end
        end
    end
    return {0,0,0,0}
end

function TileMagicLampBody:setColor(color)
    local value = getColorHSBC(MagicLampHSBC, color)
    self.body:adjustColor(value[1],value[2],value[3],value[4])
    self.body:applyAdjustColorShader()
end

function TileMagicLampBody:playBodyAnimation(level, delay, callback)

    self:stopAllAnimation()

    if level ~= self.level then
        self:clearBody()
        self:initBody(self.color, level)
    end

    delay = delay or 0
    local frameNum = 22
    if level > 3 then frameNum = 30 end

    local bodyAnim = SpriteUtil:buildAnimate(SpriteUtil:buildFrames("magic_lamp_level_"..level.."_%04d", 0, frameNum), 1/20)
    self.body:play(bodyAnim, delay, 1, callback)
    self.body:setVisible(true)

    local borderAnim = SpriteUtil:buildAnimate(SpriteUtil:buildFrames("magic_lamp_level_"..level.."_border_%04d", 0, frameNum), 1/20)
    self.border:play(borderAnim, delay, 1)
    self.border:setVisible(true)
end

function TileMagicLampBody:playBeforeCast()
    self:stopAllAnimation()

    self:clearBody()

    local bodyX, bodyY = 0, 0
    self.border = Sprite:createWithSpriteFrameName("magic_lamp_before_casting_border_0000")
    self:addChild(self.border)
    self.border:setPosition(ccp(bodyX+1, bodyY-3.5))
    local borderAnim = SpriteUtil:buildAnimate(SpriteUtil:buildFrames("magic_lamp_before_casting_border_%04d", 0, 13), 1/20)
    self.border:play(borderAnim, 0, 0)

    self.body = SpriteColorAdjust:createWithSpriteFrameName("magic_lamp_before_casting_0000")
    self:addChild(self.body)
    self.body:setPosition(ccp(bodyX, bodyY))
    local bodyAnim = SpriteUtil:buildAnimate(SpriteUtil:buildFrames("magic_lamp_before_casting_%04d", 0, 13), 1/20)
    self.body:play(bodyAnim, 0, 0)

    self:setColor(self.color)
end

function TileMagicLampBody:playCasting(repeatTimes, callback)
    self:stopAllAnimation()

    self:clearBody()

    local bodyX, bodyY = -0.5, 13.5
    repeatTimes = repeatTimes or 1
    self.border = Sprite:createWithSpriteFrameName("magic_lamp_casting_border_0000")
    self:addChild(self.border)
    self.border:setPosition(ccp(bodyX+1, bodyY-3))
    local borderAnim = SpriteUtil:buildAnimate(SpriteUtil:buildFrames("magic_lamp_casting_border_%04d", 0, 28), 0.8/20) --1/20
    self.border:play(borderAnim, 0, repeatTimes)

    self.body = SpriteColorAdjust:createWithSpriteFrameName("magic_lamp_casting_0000")
    self:addChild(self.body)
    self.body:setPosition(ccp(bodyX, bodyY))
    local bodyAnim = SpriteUtil:buildAnimate(SpriteUtil:buildFrames("magic_lamp_casting_%04d", 0, 28), 0.8/20) --1/20
    self.body:play(bodyAnim, 0, repeatTimes, callback)

    self:setColor(self.color)
end

function TileMagicLampBody:setGrey()
    self:clearBody()

    local bodyPosX, bodyPosY = 0, 0
    self.border = Sprite:createWithSpriteFrameName("magic_lamp_greying_border_0000")
    self.border:setPosition(ccp(bodyPosX+0.3, bodyPosY-4))
    self:addChild(self.border)

    self.body = SpriteColorAdjust:createWithSpriteFrameName('magic_lamp_greying_0000')
    self.body:setPosition(ccp(bodyPosX, bodyPosY))
    self:addChild(self.body)
end

function TileMagicLampBody:playReinit(color, callback)
    self:stopAllAnimation()

    self:setGrey()
    self:setColor(color)

    local function onAnimeFinish()
        if callback then callback() end
    end

    local bodyAnim = SpriteUtil:buildAnimate(SpriteUtil:buildFrames("magic_lamp_greying_%04d", 0, 10), 1/20)
    self.body:play(bodyAnim, 0, 1, onAnimeFinish)

    local borderAnim = SpriteUtil:buildAnimate(SpriteUtil:buildFrames("magic_lamp_greying_border_%04d", 0, 10), 1/20)
    self.border:play(borderAnim, 0, 1)
end

function TileMagicLampBody:stopAllAnimation()
    self.body:stopAllActions()
    self.border:stopAllActions()
end

-----------------------------------------------------------

function TileMagicLamp:create(color, level)
    local node = TileMagicLamp.new(CCNode:create())
    node:init(color, level)
    return node
end

function TileMagicLamp:init(color, level)
    if not level then level = 4 end
    self.level = tonumber(level)
    if not color then color = AnimalTypeConfig.kRed end
    self.color = color
    if level == 0 then
        self:setLevel(1)
        self:setGrey()

    elseif level < 5 then
        self:setLevel(self.level)
        self:playLevel(self.level, 5)
    else
        self:setLevel(4)
        self:playBeforeCast()
    end
end

function TileMagicLamp:setLevel(level)
    if self.stars then
        self.stars:removeFromParentAndCleanup(true)
    end
    self.stars = self:createStars()
    self.stars:setVisible(false)
    if not self.body then
        self.body = TileMagicLampBody:create(self.color, level)
    else
        self.body:clearBody()
        self.body:initBody(self.color, level)
    end
    self:addChild(self.body)
    self:addChild(self.stars)
end

function TileMagicLamp:setGrey()
    self.body:setGrey()
    self.stars:setVisible(false)
end

function TileMagicLamp:playLevel(level, delay)
    if not delay then delay = 0 end
    if not level then level = 1 end

    local function repeatFunc()
        local function callback()
            self.stars:setVisible(false)
        end
        self.body:playBodyAnimation(level, 0, callback)
        if level >= 3 then
            self.stars:setVisible(true)
        else
            self.stars:setVisible(false)
        end
    end
    local function start()
        self.body:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCCallFunc:create(repeatFunc), CCDelayTime:create(5))))
    end
    self.body:stopAllActions()
    self.body:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(delay), CCCallFunc:create(start)))
end

function TileMagicLamp:playBeforeCast()
    self.body:stopAllActions()
    self.body:playBeforeCast()
    self.stars:setVisible(true)
end

function TileMagicLamp:playCasting()
    local function onAnimeFinish()
        self:setGrey()
    end
    self.body:stopAllActions()
    self.body:playCasting(1, onAnimeFinish)

    self.light = SpriteColorAdjust:createWithSpriteFrameName("magic_lamp_casting_light_0000")
    local lightAnim = SpriteUtil:buildAnimate(SpriteUtil:buildFrames("magic_lamp_casting_light_%04d", 0, 14), 1/20)
    self.light:play(lightAnim, 0, 1, function () if self.light then self.light:removeFromParentAndCleanup(true) end end)
    self:addChild(self.light)
    self.stars:setVisible(false)
end

function TileMagicLamp:createStars()
    local es_spx = {-33, -27, -18, -4, 13, 26, 29}
    local es_spy = {-26, 21, -30, -28, 30, -20, 10}

    local es_epx = {-33, -27, -18, -4, 13, 26, 29}
    local es_epy = {-2, 33, -25, -21, 34, 1, 33}

    local es_delay = {0, 0.08, 0.21, 0.13, 0.28, 0.25, 0.19}
    local es_sc = {0.22, 0.25, 0.33, 0.42, 0.36, 0.4, 0.31}
    local node = Sprite:createEmpty()
    for i=1,#es_spx do
        local effectStar_C = Sprite:createWithSpriteFrameName("Wrap_Effect_Star.png");
        effectStar_C:setPosition(ccp(es_spx[i], es_spy[i]));
        effectStar_C:setScale(es_sc[i]);
        node:addChild(effectStar_C);

        local function onTimeout()
            local delayAction = CCDelayTime:create(es_delay[i]);                        ----等待
            local showAction = CCFadeTo:create(0.2, 200 + i * i);                       ----显示
            local movetoAction = CCMoveTo:create(0.5, ccp(es_epx[i], (es_epy[i] + es_spy[i]) / 2));         ----移动
            local sp1 = CCSpawn:createWithTwoActions(showAction, movetoAction); 

            local delayAction2 = CCDelayTime:create(0.1);                       ----等待
            local showAction2 = CCFadeTo:create(0.3, 0);                        ----显示
            local movetoAction2 = CCMoveTo:create(0.4, ccp(es_epx[i], es_epy[i]));          ----移动
            local sq1 = CCSequence:createWithTwoActions(delayAction2, showAction2);
            local sp2 = CCSpawn:createWithTwoActions(sq1, movetoAction2);

            local movetoAction3 = CCMoveTo:create(0.01, ccp(es_spx[i], es_spy[i]));

            local arr = CCArray:create();
            arr:addObject(delayAction)
            arr:addObject(sp1)
            arr:addObject(sp2)
            arr:addObject(movetoAction3);
            effectStar_C:stopAllActions()
            effectStar_C:runAction(CCRepeatForever:create(CCSequence:create(arr)))
        end

        delayTime = delayTime or 0
        effectStar_C:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(delayTime), CCCallFunc:create(onTimeout)))
    end
    return node
end

function TileMagicLamp:playReinit(color, callback)
    self.color = color
    local function onAnimeFinish()
        self.body:clearBody()
        self.body:initBody(color, 1)
        self:playLevel(1, 0)
        if callback then callback() end
    end
    self.body:stopAllActions()
    self.body:playReinit(color, onAnimeFinish)
    self.stars:setVisible(false)
end