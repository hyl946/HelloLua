
TileMissile = class(CocosObject)
TileMissileInitOffsetX = 1.5
TileMissileInitOffsetY = 0
function TileMissile:ctor()
end

function TileMissile:create(level)
    local node = TileMissile.new(CCNode:create())
    node:init(level)
    return node
end

function TileMissile:init(level)
    FrameLoader:loadArmature("skeleton/missile")

    -- if level then
        self:initSprite(level)
    -- else
        -- self:playDecAnimation(1)
    -- end
end

function TileMissile:getPosOffset(level)
    --     -33 , 34.5

    if level == 3 then
        return 0, 0 
    elseif  level == 2 then
        return 0, 2
    elseif  level == 1 then
        return -3.5, 4.5
    elseif  level == 0 then
        return -3, 3
    end

    return 0, 0
end

function TileMissile:initSprite(level)

    self:removeSprite()
    self.sprite = self:createSprite(level)
    local _spriteOffsetX, _spriteOffsetY = self:getPosOffset(level)

    local currPos = self.sprite:getPosition()
    self.sprite:setPosition(ccp( currPos.x + _spriteOffsetX, currPos.y + _spriteOffsetY))
    self:addChildAt(self.sprite,0)

    -- self.effectSprite = Sprite:create()
    -- self:addChildAt(self.effectSprite,1)
end

function TileMissile:createSprite(level)
    local node = ArmatureNode:create("out/stand"..tostring(level))
    node:setPosition(ccp(-34.5+TileMissileInitOffsetX,34.5+TileMissileInitOffsetY))
    node:playByIndex(0, 0)
    return node
end

function TileMissile:removeSprite()
    if self.sprite then
        self.sprite:stop()
        self.sprite:removeFromParentAndCleanup(true)
        self.sprite = nil
    end
end

function TileMissile:playLife2()
    self:removeSprite()

    local node = ArmatureNode:create("out/stand2")
    self.sprite = node
    self:addChildAt(self.sprite,0)
    node:setPosition(ccp(-34.5+TileMissileInitOffsetX,36.5+TileMissileInitOffsetY))
    node:playByIndex(0, 0,-1,0)

    -- node:addEventListener(ArmatureEvents.COMPLETE, function()
    --                 if callback then callback() end 
    --             end)
end

function TileMissile:playLife1()
self:removeSprite()

    local node = ArmatureNode:create("out/stand1")
    self.sprite = node
    self:addChildAt(self.sprite,0)
    node:setPosition(ccp(-38+TileMissileInitOffsetX,39+TileMissileInitOffsetY))
    node:playByIndex(0, 0,-1,0)


end

-- 死亡待机
function TileMissile:playLife0(  )
    self:removeSprite()

    local node = ArmatureNode:create("out/stand0")
    self.sprite = node
    self:addChildAt(self.sprite,0)
    node:setPosition(ccp(-37.5+TileMissileInitOffsetX,37.5+TileMissileInitOffsetY))
    node:playByIndex(0, 0,-1 , 0)
    node:setAnimationScale(1.3)
end

function TileMissile:fire()
    self:removeSprite()

    local node = ArmatureNode:create("out/bombing")
    self.sprite = node
    self:addChildAt(self.sprite,0)

    node:setPosition(ccp(-37.5+TileMissileInitOffsetX,37.5+TileMissileInitOffsetY))
    node:playByIndex(0, 1)

end

-- function TileMissile:fly( callback )
--     if callback then callback() end
-- end


-- function TileMissile:bomb( callback )
--     if callback then callback() end
-- end

function TileMissile:createFlyEffect()
    local node = ArmatureNode:create("out/flying")
    node:playByIndex(0, 0)

    return node
end

function TileMissile:playDecAnimation(curLevel, onAnimFinished)
    local function effectComplete()
        if (self.effectSprite ~= nil) then
            self.effectSprite:stop()
            self.effectSprite:removeFromParentAndCleanup(true)
            self.effectSprite = nil
        end
    end

    effectComplete()

    local node = ArmatureNode:create("out/matching")
    self.effectSprite = node
    self:addChildAt(self.effectSprite,1)
    node:setPosition(ccp(-32.5+TileMissileInitOffsetX,32.5+TileMissileInitOffsetY))
    node:playByIndex(0)
    node:addEventListener(ArmatureEvents.COMPLETE, effectComplete)
end





-- ==============================================================


function TileMissile:createFlySprite()
    return Sprite:createWithSpriteFrameName("olympic_blocker_fly_item")
end

function TileMissile:removeDecAnimation()
    if self.decAnimation then 
        self.decAnimation:removeFromParentAndCleanup(true)
        self.decAnimation = nil
    end
end








---------------------------------
--雪怪脚踏动画 3*2
---------------------------------
MissileBomb = class(CocosObject)
function MissileBomb:create( finishCallback,animationCallback  )
    -- body
    local s = MissileBomb.new(CCNode:create())
    s.name = "MissileBomb"
    s:init(finishCallback,animationCallback )
    return s
end

function MissileBomb:init( finishCallback,animationCallback)
    local function callback_middle( ... )
        if animationCallback then
            animationCallback()
        end
    end 

    local function callback_over( ... )
        if finishCallback then 
            finishCallback()
        end
    end

    local function callback_out()
        FrameLoader:loadArmature( "skeleton/missile")
        local mainSprite = ArmatureNode:create("out/matching")
        self:addChild(mainSprite)
        mainSprite:playByIndex(0, 1)

        local action_delay = CCDelayTime:create(0.5)
        local action_callback = CCCallFunc:create(callback_middle)
        self:runAction(CCSequence:createWithTwoActions(action_delay,action_callback))

        local delay_time_2 = CCDelayTime:create(2)
        local action_callback_2 = CCCallFunc:create(callback_over)
        self:runAction(CCSequence:createWithTwoActions(delay_time_2, action_callback_2))
    end

    local action_out_callback = CCCallFunc:create(callback_out)
    self:runAction(action_out_callback)
end