TileMoleMagicTileCover = class(CocosObject)

local kCharacterAnimationTime = 1/30
local assetNamePrefix = "magic_tile_mole_cover_"

function TileMoleMagicTileCover:create()
    local node = TileMoleMagicTileCover.new(CCNode:create())
    node.name = "moleMagicTileCover"

    node:init()
    return node
end

function TileMoleMagicTileCover:init()
    local itemSprite = Sprite:createWithSpriteFrameName(assetNamePrefix.."disappear_0000") --消失动画的第一帧就是稳定的覆盖图像
    self.itemSprite = itemSprite
    -- self.itemSprite:setPosition(ccp(0, -5))
    self:addChild(itemSprite)
end

function TileMoleMagicTileCover:playAppearAnimation()
    self.itemSprite:setVisible(false)

    local function onAddAnimationEnded()
        self.itemSprite:setVisible(true)
    end

    local appearAnimation = Sprite:createWithSpriteFrameName(assetNamePrefix.."appear_0000")
    appearAnimation:setPosition(ccp(1, -2))
    self:addChild(appearAnimation)

    local frames = SpriteUtil:buildFrames(assetNamePrefix.."appear_%04d", 0, 11)
    local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
    appearAnimation:play(animate, 0, 1, onAddAnimationEnded, true)
end

function TileMoleMagicTileCover:playDisappearAnimation(callback)
    self.itemSprite:stopAllActions()
    self.itemSprite:setVisible(false)

    local destroySprite = Sprite:createWithSpriteFrameName(assetNamePrefix.."disappear_0000")
    self.destroySprite = destroySprite
    -- destroySprite:setPosition(ccp(-5, -3))
    self:addChild(destroySprite)

    local frames = SpriteUtil:buildFrames(assetNamePrefix.."disappear_%04d", 0, 8)
    local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
    destroySprite:play(animate, 0, 1, callback, true)
end
