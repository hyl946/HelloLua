-- --------------------------------------
-- 大宝箱 道具云块
-- --------------------------------------

    -- self.anim = ArmatureNode:create('ThanksGiving/ThanksGiving')
    -- self.anim:setPosition(ccp(218, -466))
    -- self.anim:playByIndex(0, 1)
    -- self.anim:update(0.001)
    -- self.anim:stop()
    -- self.anim:addEventListener(ArmatureEvents.COMPLETE, function()
    --             self:mainAnimComplete()
    --         end)

TileChestScale = 0.85
TileChestSquare = class(CocosObject)

function TileChestSquare:create()
    -- body
    local node = TileChestSquare.new(CCNode:create())
    node.name = "tile_chest_square"
    node:initSprite()
    return node
end

function TileChestSquare:initSprite( ... )
    FrameLoader:loadArmature("skeleton/chest")

    self.sprite = ArmatureNode:create("out/chest_square_hit")  -- chest_square_stand
    self.sprite:setPosition(ccp(-35,35))
    self.sprite:playByIndex(0, 1)
    self.sprite:update(0.001)
    self.sprite:setScale(TileChestScale)
    self.sprite:stop()

    self:addChild(self.sprite)
end

function TileChestSquare:playHit(callback )
    self:removeSprite()

    self.sprite = ArmatureNode:create("out/chest_square_hit")
    self.sprite:setPosition(ccp(-35,35))
    self.sprite:playByIndex(0, 1)
    self.sprite:setScale(TileChestScale)
    self.sprite:addEventListener(ArmatureEvents.COMPLETE, function()
                    if callback then callback() end 
                end)
    self:addChild(self.sprite)
    
end

function TileChestSquare:playJumpAnimation(callback )
    self:removeSprite()

    self.sprite = ArmatureNode:create("out/chest_square_die")
    self.sprite:setPosition(ccp(-35,50))
    self.sprite:playByIndex(0, 1)
    self.sprite:setScale(TileChestScale)
    self.sprite:addEventListener(ArmatureEvents.COMPLETE, function()
                    if callback then callback() end 
                end)
    self:addChild(self.sprite)
end


function TileChestSquare:removeSprite()
    if self.sprite then
        self.sprite:stop()
        self.sprite:removeFromParentAndCleanup(true)
        self.sprite = nil
    end
end









TileChestSquarePart = class(CocosObject)

function TileChestSquarePart:create(type)
    local node = TileChestSquarePart.new(CCNode:create())
    node.name = "tile_chest_square_part"
    node:initSprite(type)
    return node
end

function TileChestSquarePart:initSprite(type)
    FrameLoader:loadArmature("skeleton/chest")

    self.sprite = ArmatureNode:create("out/chest_square_part_stand")
    self.sprite:setPosition(ccp(-39,42))
    self.sprite:playByIndex(0, 0)
        self.sprite:setScale(TileChestScale)
    self:addChild(self.sprite)
end


function TileChestSquarePart:createFront(type)
    local node = TileChestSquarePart.new(CCNode:create())
    node.name = "tile_chest_square_part_front"
    node:initSpriteFront(type)
    return node
end

function TileChestSquarePart:initSpriteFront(type)
    -- FrameLoader:loadArmature("skeleton/chest")

end

function TileChestSquarePart:playDestroyAnimation(callback)
    self:removeSprite()

    self.sprite = ArmatureNode:create("out/chest_square_part_back_die")
    self.sprite:setPosition(ccp(-33,35))
    self.sprite:playByIndex(0, 1)
        self.sprite:setScale(TileChestScale)
    self.sprite:addEventListener(ArmatureEvents.COMPLETE, function()
                        if callback then callback() end
                end)
    self:addChild(self.sprite)


end

function TileChestSquarePart:playFrontDestroyAnimation(callback)
    self:removeSprite()

    self.sprite = ArmatureNode:create("out/chest_square_part_front_die")
    self.sprite:setPosition(ccp(-33,35))
    self.sprite:playByIndex(0, 1)
        self.sprite:setScale(TileChestScale)
    self.sprite:addEventListener(ArmatureEvents.COMPLETE, function()
                        if callback then callback() end
                end)
    self:addChild(self.sprite)

    if callback then callback() end
end

function TileChestSquarePart:removeSprite()
    if self.sprite then
        self.sprite:stop()
        self.sprite:removeFromParentAndCleanup(true)
        self.sprite = nil
    end
end