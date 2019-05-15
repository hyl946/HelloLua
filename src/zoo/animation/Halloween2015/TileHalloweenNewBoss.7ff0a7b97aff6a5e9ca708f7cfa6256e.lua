
require "zoo.animation.Halloween2015.HalloweenAnimation"
require "zoo.animation.Halloween2015.HalloweenPumpkin"
require "zoo.animation.Halloween2015.PumpkinExplode"
require "zoo.animation.Halloween2015.HalloweenGhost"

local kCharacterAnimationTime = 1/26
local kEffectAnimationTime = 1/26
local OFFSET_X, OFFSET_Y = 0, 0

local animationList = table.const
{
    kNone = 0,
    kWating = 1,
    kComeout = 2,
    kDie = 3,
    kHit = 4,
    kCasting = 5,
}

local minPosX = Director:sharedDirector():getVisibleSize().width / 2

TileHalloweenNewBoss = class(CocosObject)
function TileHalloweenNewBoss:create()
    local i = TileHalloweenNewBoss.new(CCNode:create())
    i:init()
    return i
end

function TileHalloweenNewBoss:init()
    self.body = CocosObject:create()
    self.bossContentWidth = 9*70
    self.bossContentHeight = 150
    self.body:setAnchorPoint(ccp(0, 0))
    self.body:setPosition(ccp(0,0))
    self:addChild(self.body)

    self.halloweenPumpkin = HalloweenPumpkin:create()
    self.body:addChild(self.halloweenPumpkin)
    self.halloweenPumpkin:adjustPostion(self.bossContentWidth/2)

    ----test----
    -- self.halloweenPumpkin:setTouchEnabled(true, 0, true)
    -- self.halloweenPumpkin:addEventListener(DisplayEvents.kTouchTap, function ()
    --     local pumpkinExplode = PumpkinExplode:create(targetItemCount, itemEndPos, propCount, propEndPos)
    --     pumpkinExplode:show(onFlyAnimFinish)
    -- end)
end

function TileHalloweenNewBoss:getBossSpriteWorldPosition()
    if self.body and self.halloweenPumpkin then
        local worldPos = self.body:convertToWorldSpace(self.halloweenPumpkin:getPosition())
        local centerPos = ccp(minPosX , worldPos.y)
        return centerPos
    end
    return nil
end

--Boss出现动画
function TileHalloweenNewBoss:playComeout(callback)
    if self.animate == animationList.kComeout then
        if callback then callback() end
        return
    end
    self.animate = animationList.kComeout

    if self.halloweenPumpkin then 
        self.halloweenPumpkin:playComout(callback)
    end

    setTimeOut(function ()
        local ghost = HalloweenAnimation:getInstance():getHalloweenGhost()
        if ghost then 
            ghost:setPumpkinOnScene(true)
        end
    end, 1)
end

--Boss待机状态
function TileHalloweenNewBoss:playWating()
    if not self.halloweenPumpkin or not self.halloweenPumpkin.refCocosObj then
        return
    end

    self.animate = animationList.kWating
    self.halloweenPumpkin:stopReadyToCast()
end

--被击中状态
function TileHalloweenNewBoss:playHit(fromPosInWorld, callback, isSpecial, hit, totalBlood, index)
    local progress = hit / totalBlood
    if progress > 1 then progress = 1 end

    local function localCB()
        self.animate = animationList.kWating
        if callback then
            callback()
        end
    end

    local bossPos = self:getBossSpriteWorldPosition()
    

    local function endCallback(datas)
	    self.animate = animationList.kHit
        local ghost = HalloweenAnimation:getInstance():getHalloweenGhost()
        if ghost then 
            ghost:playSmile()
        end
        if self.halloweenPumpkin then
            self.halloweenPumpkin:showYellowLight()
        end
    end

    local function playSugarFly(innerIndex)
        if not innerIndex then innerIndex = 1 end
        local endPos = ccp(bossPos.x + math.random(-20, 20) , bossPos.y + math.random(80, 130))
        local randomFromPos = ccp(fromPosInWorld.x + math.random(-30, 30), fromPosInWorld.y + math.random(-30, 30))
        HalloweenAnimation:playSugarFlyAnimation(randomFromPos, endPos, (0.3 + (0.2 * index) + (innerIndex-1)*0.1), endCallback)
    end
    if isSpecial then 
        for i=1,3 do
            playSugarFly(i)
        end
    else
        playSugarFly()
    end
end

--Boss释放特效
function TileHalloweenNewBoss:playCasting(destPositions, callback)
    if self.animate == animationList.kCasting then
        if callback then callback() end
        return
    end

    if not destPositions or #destPositions < 1 then
        if callback then callback() end
        return
    end
    self.animate = animationList.kCasting

    local count = 0
    local function onAnimationDone()
        count = count + 1
        if count >= #destPositions then
            if callback then
                callback()
            end
        end
    end

    local function playBallsAnim()
        for k,v in pairs(destPositions) do
            local toPos = ccp(v.x , v.y)
            local fromWorldPos = HalloweenAnimation:getInstance():getPumpkinCenterWorldPos()
            HalloweenAnimation:getInstance():playSugarFlyAnimation(fromWorldPos, toPos, 0.8, function ()
                onAnimationDone()
            end, true)
        end
    end

    self.halloweenPumpkin:playReadyToCast(playBallsAnim)
end

--Boss释放特效
function TileHalloweenNewBoss:playReadyToCast()
    self.halloweenPumpkin:playReadyToCast()
end


--Boss死亡
function TileHalloweenNewBoss:playDie(targetItemCount, itemEndPos, propCount, propEndPos, callback)
    if self.animate == animationList.kDie then
        return
    end
    self.animate = animationList.kDie

    local function onFlyAnimFinish(isPropAnim)
    	-- if isPropAnim then
    	-- end
        
    	if callback then callback(isPropAnim) end
    end

    self.halloweenPumpkin:setVisible(false)

    local pumpkinExplode = PumpkinExplode:create(targetItemCount, itemEndPos, propCount, propEndPos)
    pumpkinExplode:show(onFlyAnimFinish)

    setTimeOut(function ()
        local ghost = HalloweenAnimation:getInstance():getHalloweenGhost()
        if ghost then 
            ghost:setPumpkinOnScene(false)
        end
    end, 2)
end

function TileHalloweenNewBoss:setBloodPercent(percent, isPlayAnimation)
    if self.halloweenPumpkin and percent then 
        self.halloweenPumpkin:setPercent(percent, isPlayAnimation)
    end
end

function TileHalloweenNewBoss:getSpriteWorldPosition()
	return self:getBossSpriteWorldPosition()
end

function TileHalloweenNewBoss:buildBossFlyStar(onAnimFinish)
    local starAnim = Sprite:createEmpty()

    local stars = {
        {x=-4, y=-38, dx=1, dy = -190, delay=0, scale = 1.0},
        {x=12, y=-43, dx=-2, dy = -120, delay=0, scale = 1.2},
        {x=-1, y=-65, dx=1, dy = -250, delay=0, scale = 1.1},
        {x=2, y=-43, dx=-1, dy = -160, delay=6 * kEffectAnimationTime, scale = 1.3},
    }

    for _, v in pairs(stars) do
        local star = Sprite:createWithSpriteFrameName("boss_icon_star.png")
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

    local sprite = Sprite:createWithSpriteFrameName("boss_pumpkin_icon_fly_0000.png")
    sprite:setAnchorPoint(ccp(0.5, 1))
    local frames = SpriteUtil:buildFrames("boss_pumpkin_icon_fly_%04d.png", 0, 19)
    local duration = 0.6
    local anim = SpriteUtil:buildAnimate(frames, duration/19)
    sprite:play(anim, 0, 1)

    starAnim:addChild(sprite)
    return starAnim
end

function TileHalloweenNewBoss:buildHalloweenBoss()
    local bossSprite = Sprite:createWithSpriteFrameName("pumpkin_boss_icon.png")
    return bossSprite
end