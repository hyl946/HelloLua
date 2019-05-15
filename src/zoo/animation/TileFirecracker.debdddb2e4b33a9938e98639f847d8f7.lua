TileFirecracker = class(CocosObject)

local kCharacterAnimationTime = 1/30

local assetPrefix = "blocker_firecracker_"
local assetShiftY = -3

function TileFirecracker:create(colour)
	local node = TileFirecracker.new(CCNode:create())
	node.name = "firecracker"
	node.colour = colour

	node:setIdleState()
	return node
end

function TileFirecracker:_cleanSprite()
	if self.sprite then 
		self.sprite:removeFromParentAndCleanup(true)
	end
end

function TileFirecracker:setIdleState()
	self:_cleanSprite()

	self.sprite = Sprite:createWithSpriteFrameName(assetPrefix..self.colour.."_0000")
	self:addChild(self.sprite)

	self.sprite:setPosition(ccp(0, assetShiftY))

	self.inHitAnimation = false
end

function TileFirecracker:playBeingHitAnimation()
	if self.inHitAnimation then return end

	self.inHitAnimation = true
	self.sprite:stopAllActions()

	local speed = 2
	local shakeShift = 3
	local actArr = CCArray:create()

	local shakeLa = CCMoveBy:create(speed * kCharacterAnimationTime, ccp(shakeShift, 0))
	local shakeLb = CCMoveBy:create(speed * kCharacterAnimationTime, ccp(-shakeShift, 0))
	actArr:addObject(shakeLa)
	actArr:addObject(shakeLb)
	local shakeRa = CCMoveBy:create(speed * kCharacterAnimationTime, ccp(shakeShift, 0))
	local shakeRb = CCMoveBy:create(speed * kCharacterAnimationTime, ccp(-shakeShift, 0))
	actArr:addObject(shakeRa)
	actArr:addObject(shakeRb)

	local action = CCRepeatForever:create(CCSequence:create(actArr))
	self.sprite:runAction(action)
end

function TileFirecracker:switchToFirecrackerBlastAnimation()
	self:_cleanSprite()

	self.sprite = Sprite:createWithSpriteFrameName(assetPrefix..self.colour.."_0000")
	self:addChild(self.sprite)

	-- local frames = SpriteUtil:buildFrames(assetPrefix..self.colour.."_%04d", 0, 19)
	local frames = SpriteUtil:buildFrames(assetPrefix..self.colour.."_%04d", 0, 13)
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	self.sprite:play(animate, 0, 1, callback, false)
	-- self.sprite:runAction(CCRepeatForever:create(animate))

	self.sprite:setPosition(ccp(0, assetShiftY))

	self.inHitAnimation = false
end
