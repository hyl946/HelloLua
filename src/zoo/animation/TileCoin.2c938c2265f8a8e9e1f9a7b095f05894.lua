
TileCoin = class(CocosObject)

local kCharacterAnimationTime = 1/30

function TileCoin:create()
	local node = TileCoin.new(CCNode:create())
	node.name = "coin"

	local effectSprite = Sprite:createWithSpriteFrameName("coin_normal")
	node.effectSprite = effectSprite
	node:addChild(effectSprite)

	return node
end

function TileCoin:playDestroyAnimation()
	local frames = SpriteUtil:buildFrames("coin_destroy%02d", 0, 12)
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	self.effectSprite:play(animate, 0, 1)
end
