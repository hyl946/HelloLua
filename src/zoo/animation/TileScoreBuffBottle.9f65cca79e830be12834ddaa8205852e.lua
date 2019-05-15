TileScoreBuffBottle = class(CocosObject)

local kCharacterAnimationTime = 1/30

local assetPrefix = "blocker_scoreBuff_"
local assetShiftY = -3

function TileScoreBuffBottle:create(colour)
	local node = TileScoreBuffBottle.new(CCNode:create())
	node.name = "scoreBuffBottle"
	node.colour = colour

	node:playIdleAnimation()
	return node
end

function TileScoreBuffBottle:_cleanSprite()
	if self.sprite then 
		self.sprite:removeFromParentAndCleanup(true)
	end
end

function TileScoreBuffBottle:playIdleAnimation()
	self:_cleanSprite()

	self.sprite = Sprite:createWithSpriteFrameName(assetPrefix..self.colour.."_0000")
	self:addChild(self.sprite)

	local frames = SpriteUtil:buildFrames(assetPrefix..self.colour.."_%04d", 0, 50)
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	self.sprite:runAction(CCRepeatForever:create(animate))

	self.sprite:setPosition(ccp(0, assetShiftY))

	self.inHitAnimation = false
end

function TileScoreBuffBottle:playBeingHitAnimation()
	if self.inHitAnimation then return end

	self.inHitAnimation = true
	self.sprite:stopAllActions()

	local speed = 2
	local shakeShift = 3
	local actArr = CCArray:create()

	-- local pressShape = CCScaleTo:create(speed * kCharacterAnimationTime, 1, 1)
	-- local pressMove = CCMoveBy:create(speed * kCharacterAnimationTime, ccp(5, 0))
	-- local press = CCSpawn:createWithTwoActions(pressShape, pressMove)
	-- actArr:addObject(press)

	-- local bouceShape = CCScaleTo:create(speed * kCharacterAnimationTime, 1, 1)
	-- local bounceMove = CCMoveBy:create(speed * kCharacterAnimationTime, ccp(-5, 0))
	-- local bounce = CCSpawn:createWithTwoActions(bouceShape, bounceMove)
	-- actArr:addObject(bounce)

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

function TileScoreBuffBottle:playScoreBuffBottleBlastAnimation(colour, callback)
	local animation = Sprite:createWithSpriteFrameName(assetPrefix..colour.."_break_0000")
	local frames = SpriteUtil:buildFrames(assetPrefix..colour.."_break_%04d", 0, 22)
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	animation:play(animate, 0, 1, callback, true)

	GamePlayMusicPlayer:playEffect(GameMusicType.kPlayHoneybottleMatch)

	return animation
end