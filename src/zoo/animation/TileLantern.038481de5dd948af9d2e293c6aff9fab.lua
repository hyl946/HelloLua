--元宵节灯笼

TileLantern = class(CocosObject)

function TileLantern:create()
	local node = TileLantern.new(CCNode:create())
	node.name = "lantern"

	local effectSprite = Sprite:createWithSpriteFrameName("lantern_normal")
	node.effectSprite = effectSprite
	effectSprite:setPosition(ccp(3, -4))
	node:addChild(effectSprite)

	return node
end

function TileLantern:playDestroyAnimation()
	local frames = SpriteUtil:buildFrames("lantern_destroy_%04d", 1, 17)
	local animate = SpriteUtil:buildAnimate(frames, 1/24)
	self.effectSprite:play(animate, 0, 1)
end