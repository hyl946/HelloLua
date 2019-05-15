local kCharacterAnimationTime = 1/24
local OFFSET_X, OFFSET_Y = 0, 0

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
TileHalloweenBoss = class(CocosObject)

function TileHalloweenBoss:create()
    local i = TileHalloweenBoss.new(CCNode:create())
    i:init()
    return i
end

function TileHalloweenBoss:init()
    self.body = CocosObject:create()
    self.body:setContentSize(CCSizeMake(9*70, 150))
    self.body:setAnchorPoint(ccp(0, 0))
    self:addChild(self.body)
    self.sprite = Sprite:createWithSpriteFrameName('xmas_boss_wander_0000')
    self.sprite:setAnchorPoint(ccp(0, 0))
    self.body:addChild(self.sprite)
    self.sprite:setPosition(ccp(0, 20))
    self:createBloodBar()
end

function TileHalloweenBoss:playWandering(dir)

    if not self.sprite or not self.sprite.refCocosObj then
        return
    end

    self.animate = animationList.kWandering
    self.sprite:stopAllActions()
    local animate = SpriteUtil:buildAnimate(SpriteUtil:buildFrames('xmas_boss_wander_%04d', 0, 18), kCharacterAnimationTime)
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

function TileHalloweenBoss:playRandom()

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
        local animate = SpriteUtil:buildAnimate(SpriteUtil:buildFrames('xmas_boss_random_%04d', 0, 38), kCharacterAnimationTime)
        self.sprite:play(animate, 0, 1, callback)
    else
        callback()
    end
end

function TileHalloweenBoss:playHit(fromPosInWorld, callback, isSpecial)
    -- if _G.isLocalDevelopMode then printx(0, 'play hit') end

    local function localCB()

        self:playWandering(self.dir)
        if callback then
            callback()
        end
    end

    local ball
    if isSpecial then 
        ball = Sprite:createWithSpriteFrameName('xmas_snowball_red_0000')
    else
        ball = Sprite:createWithSpriteFrameName('xmas_snowball_0000')
    end
    local function arrive()
        local pos = ccp(ball:getPositionX(), ball:getPositionY())

        if ball and ball.refCocosObj and not ball.isDisposed then
            ball:removeFromParentAndCleanup(true)
            ball = nil
        end
        local snow = Sprite:createWithSpriteFrameName('xmas_boss_hiticon_0000')
        local animation = SpriteUtil:buildAnimate(SpriteUtil:buildFrames('xmas_boss_hiticon_%04d', 0, 20), kCharacterAnimationTime)
        local function remove()
            if snow and snow.refCocosObj then
                snow:removeFromParentAndCleanup(true)
            end
        end
        snow:play(animation, 0, 1, remove)
        snow:setPosition(pos)
        -- snow:setOpacity(0)
        self.body:addChild(snow)
    end

    local spriteSize = self.sprite:getGroupBounds().size

    local toPos = self.sprite:getPosition()
    toPos = ccp(toPos.x + spriteSize.width / 2, toPos.y + spriteSize.height / 2)
    local fromPos = self.body:convertToNodeSpace(fromPosInWorld)
    local rotate = math.acos((toPos.y - fromPos.y) / ccpDistance(fromPos, toPos)) * 180 / 3.14

    if toPos.x < fromPos.x then
        rotate = -rotate
    end

    local array = CCArray:create()
    array:addObject(CCEaseSineOut:create(CCMoveTo:create(1.2, toPos)))
    array:addObject(CCEaseSineIn:create(CCFadeTo:create(1.2, 255)))
    ball:setPosition(fromPos)
    ball:setRotation(rotate)
    ball:runAction(CCSequence:createWithTwoActions(CCSpawn:create(array), CCCallFunc:create(arrive)))
    self.body:addChild(ball)

    if self.animate == animationList.kHit
    or self.animate == animationList.kCasting 
    or self.animate == animationList.kDie then
        if callback then callback() end
    else
        self.animate = animationList.kHit
        self.sprite:stopAllActions()
        local animate = SpriteUtil:buildAnimate(SpriteUtil:buildFrames('xmas_boss_hit_%04d', 0, 55), kCharacterAnimationTime)
        self.sprite:play(animate, 0, 1, localCB)
    end

end

function TileHalloweenBoss:playDie(callback)
    -- if _G.isLocalDevelopMode then printx(0, debug.traceback()) end
    if self.animate == animationList.kDie then
        -- if callback then callback() end
        return
    end
    self.animate = animationList.kDie

    self.sprite:stopAllActions()
    local function localCB()
        if callback then
            callback()
        end
    end

    local animate = SpriteUtil:buildAnimate(SpriteUtil:buildFrames('xmas_boss_die_%04d', 0, 26), kCharacterAnimationTime)
    self.sprite:play(animate, 0, 1, localCB)

end

function TileHalloweenBoss:playComeout(callback)

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

    local animate = SpriteUtil:buildAnimate(SpriteUtil:buildFrames('xmas_boss_comeout_%04d', 0, 15), kCharacterAnimationTime)
    self.sprite:play(animate, 0, 1, localCB)
end

function TileHalloweenBoss:playCasting(destPositions, callback)
    -- if _G.isLocalDevelopMode then printx(0, 'TileHalloweenBoss:playCasting') end
    -- if _G.isLocalDevelopMode then printx(0, self.animate) end
    -- debug.debug()?
    if self.animate == animationList.kCasting then
        if callback then callback() end
        return
    end
    self.animate = animationList.kCasting

    local function localCB()
        -- if _G.isLocalDevelopMode then printx(0, '%%% local callback') end
        self:playWandering(self.dir)
        if callback then
            callback()
        end
    end

    self.sprite:stopAllActions()

    local delay = 33 * kCharacterAnimationTime -- 第33帧开始扔雪球(目测)
    local animate = SpriteUtil:buildAnimate(SpriteUtil:buildFrames('xmas_boss_casting_%04d', 0, 48), kCharacterAnimationTime)
    -- self.sprite:play(animate, 0, 1, localCB)
    self.sprite:play(animate, 0, 1, nil)
    local spriteSize = self.sprite:getGroupBounds().size

    local count = 0
    local function ballCallback()
        count = count + 1
        if count >= #destPositions then
            localCB()
        end
    end


    for k,v in pairs(destPositions) do
        local ball = Sprite:createWithSpriteFrameName('xmas_snowball_0000')
        ball:setScale(1.2)
        local toPos = self.body:convertToNodeSpace(v)
        local fromPos = ccp(self.sprite:getPositionX(), self.sprite:getPositionY())
        fromPos.x, fromPos.y = fromPos.x + spriteSize.width / 2, fromPos.y + spriteSize.height / 2
        local array = CCArray:create()
        array:addObject(CCDelayTime:create(delay))
        array:addObject(CCFadeIn:create(0.1))
        array:addObject(CCEaseSineOut:create(
            CCSpawn:createWithTwoActions(CCMoveTo:create(1.2, ccp(toPos.x, toPos.y)), CCFadeTo:create(1.2, 255))
            ))
        array:addObject(CCCallFunc:create(
            function () 
                if ball and not ball.isDisposed then 
                    ball:removeFromParentAndCleanup(true) 
                    ball = nil
                end
                ballCallback()
            end))
        local angle = 180 - math.asin((toPos.x - fromPos.x) / ccpDistance(fromPos, toPos)) * 180 / 3.14
        ball:setRotation(angle)
        ball:setOpacity(0)
        ball:runAction(CCSequence:create(array))
        ball:setPosition(ccp(fromPos.x, fromPos.y))
        self.body:addChild(ball)
    end
end

function TileHalloweenBoss:createBloodBar()
    local blood = Sprite:createEmpty()
    local bloodbg = Sprite:createWithSpriteFrameName("xmas_boss_bloodbg_0000")
    bloodbg:setAnchorPoint(ccp(0, 0.5))
    blood:addChild(bloodbg)

    local bloodfg_mask = Sprite:createWithSpriteFrameName("xmas_boss_bloodbar_0000")
    local bloodfg = Sprite:createWithSpriteFrameName("xmas_boss_bloodbar_0000")
    clipingnode = ClippingNode.new(CCClippingNode:create(bloodfg_mask.refCocosObj))
    clipingnode:setPositionX(10)
    clipingnode:setAlphaThreshold(0.1)
    bloodfg_mask:setAnchorPoint(ccp(0, 0.5))
    bloodfg:setAnchorPoint(ccp(0, 0.5))
    clipingnode:addChild(bloodfg)

    blood:addChild(clipingnode)
    self.body:addChild(blood)
    self.bloodBar = bloodfg
    bloodfg:setPosition(OFFSET_X, 0)
    self.bloodBarWidth = bloodfg:getGroupBounds().size.width

    local pos_x = -self.bloodBarWidth /2
    local pos_y = -GamePlayConfig_Tile_Height * 3 /4
    blood:setPosition(ccp(0, 30))
    self.blood = blood
end

function TileHalloweenBoss:setBloodPercent(percent, isPlayAnimation)
    if self.bloodBar and percent then
        if percent > 1 then percent = 1 end
        self.bloodBar:stopAllActions()
        if isPlayAnimation then
            self.bloodBar:runAction(CCMoveTo:create(0.5, ccp((percent - 1) * self.bloodBarWidth + OFFSET_X, 0)))
        else
            self.bloodBar:setPosition(ccp((percent - 1) * self.bloodBarWidth + OFFSET_X, 0))
        end        
    end
end

function TileHalloweenBoss:getSpriteWorldPosition()
    return self.body:convertToWorldSpace(self.sprite:getPosition())
end

function TileHalloweenBoss:setSpriteX(x)
    local pos = ccp(x, 0)
    local realPos = self.body:convertToNodeSpace(pos)
    if realPos.x < 0 then realPos.x = 0 end
    if realPos.x > 7*70 then realPos.x = 7*70 end
    self.sprite:setPositionX(realPos.x)
end
