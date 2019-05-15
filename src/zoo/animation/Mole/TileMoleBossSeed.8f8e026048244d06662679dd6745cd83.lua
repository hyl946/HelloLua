TileMoleBossSeed = class(CocosObject)

local kCharacterAnimationTime = 1/30

local SeedLayerIndex = {
	bgLayer = 1,
	bagLayer = 2,
	fgLayer = 3,
}

local assetNamePrefix = "mole_skill_seed_"

function TileMoleBossSeed:create(texture, countDown)
	local sprite = CCSprite:create()
	sprite:setTexture(texture)
	local node = TileMoleBossSeed.new(sprite)
	node.name = "mole_boss_seed"
	node.parentTexture = texture

	local currCountDown = 2
	if countDown then currCountDown = countDown end
	local testMaxCountDown = 2	--test
	currCountDown = math.min(currCountDown, testMaxCountDown)	--test
	node.countDown = currCountDown

	node:init()
	return node
end

function TileMoleBossSeed:init( ... )
	self:setIdleAnimation()
end

function TileMoleBossSeed:removeViewPack(ignoreItemSprite)
	if self.bagSprite and not self.bagSprite.isDisposed then
		self.bagSprite:removeFromParentAndCleanup(true)
		self.bagSprite = nil
	end

	if self.hue and not self.hue.isDisposed then
		self.hue:removeFromParentAndCleanup(true)
		self.hue = nil
	end

	if not ignoreItemSprite then
		if self.itemSprite and not self.itemSprite.isDisposed then
			self.itemSprite:removeFromParentAndCleanup(true)
			self.itemSprite = nil
		end
	end
end

--------------------------------------------------------------------------------
--									IDLE
--------------------------------------------------------------------------------
function TileMoleBossSeed:setIdleAnimation()
	self:_setIdleView()

	--- idleAnimation
	self:_playCertainAnimation(self.hue, assetNamePrefix.."fg_2", 30, kCharacterAnimationTime)
	self.inIdleState = true
end

function TileMoleBossSeed:_setIdleView()
	self:removeViewPack()

	self.bagSprite = Sprite:createWithSpriteFrameName(assetNamePrefix.."bg_"..self.countDown.."_0000")
	self.hue = Sprite:createWithSpriteFrameName(assetNamePrefix.."fg_2".."_0000")
	if self.countDown == 2 then
		self.hue:setPosition(ccp(0, 20))
	else
		self.hue:setScale(1.2)
		self.hue:setPosition(ccp(-2, 20))
	end

	local containerSprite = Sprite:createEmpty()
	containerSprite:setTexture(self.parentTexture)
	containerSprite:addChildAt(self.bagSprite, SeedLayerIndex.bagLayer)
	containerSprite:addChildAt(self.hue, SeedLayerIndex.fgLayer)

	self.itemSprite = containerSprite
	if self.countDown == 2 then
		self.itemSprite:setPosition(ccp(2, -1))
	else
		self.itemSprite:setPosition(ccp(2, -5))
	end
	self:addChildAt(self.itemSprite, 0)
end

function TileMoleBossSeed:_playCertainAnimation(targetSprite, spritePrefix, animationFrame, animationTime, doubleWithReverse)
	if targetSprite then
		targetSprite:stopAllActions()

	    local frames = SpriteUtil:buildFrames(spritePrefix.."_%04d", 0, animationFrame)
		local animation = SpriteUtil:buildAnimate(frames, animationTime)
		if doubleWithReverse then
			local frames2 = SpriteUtil:buildFrames(spritePrefix.."_%04d", 0, animationFrame, true)
			local animation2 = SpriteUtil:buildAnimate(frames2, animationTime)

			local sequence = CCArray:create()
			-- sequence:addObject(CCDelayTime:create(0.7))
			sequence:addObject(animation)
			sequence:addObject(animation2)
			-- sequence:addObject(CCDelayTime:create(1))
			local action = CCRepeatForever:create(CCSequence:create(sequence))

			targetSprite:runAction(action)
		else
			targetSprite:play(animation)
		end
	end
end

--------------------------------------------------------------------------------
--									HIT and BREAK
--------------------------------------------------------------------------------
function TileMoleBossSeed:playBeingHitAnimation()
	if self.inIdleState then
		self.itemSprite:stopAllActions()

		local speed = 6
		local actArr = CCArray:create()

		local pressShape = CCScaleTo:create(speed * kCharacterAnimationTime, 1, 0.8)
		local pressMove = CCMoveBy:create(speed * kCharacterAnimationTime, ccp(0, -6))
		local press = CCSpawn:createWithTwoActions(pressShape, pressMove)
		actArr:addObject(press)

		local bouceShape = CCScaleTo:create(speed * kCharacterAnimationTime, 1, 1)
		local bounceMove = CCMoveBy:create(speed * kCharacterAnimationTime, ccp(0, 6))
		local bounce = CCSpawn:createWithTwoActions(bouceShape, bounceMove)
		actArr:addObject(bounce)

		local action = CCRepeatForever:create(CCSequence:create(actArr))
		self.itemSprite:runAction(action)
	end
end

function TileMoleBossSeed:playBreakAnimation(callback)
	self.inIdleState = false
	self.itemSprite:stopAllActions()

	local function onBreakEnd()
		-- printx(11, "--------- ---------- SEED, BREAK END ========== ==============")
		self:removeViewPack()
		if type(callback) == "function" then callback() end
	end

	local frameSet = 6

	--fade
	local function _waitAndFade(targetSprite, waitDurationFrame, fadeDurationFrame)
		local actArr = CCArray:create()
		actArr:addObject(CCDelayTime:create(waitDurationFrame * kCharacterAnimationTime))
		actArr:addObject(CCFadeOut:create(fadeDurationFrame * kCharacterAnimationTime))
		targetSprite:runAction(CCSequence:create(actArr))
	end
	_waitAndFade(self.hue, frameSet, frameSet)
	_waitAndFade(self.bagSprite, frameSet, frameSet)

	--bounce
	local actArr = CCArray:create()
	local duration = frameSet * kCharacterAnimationTime

	local pressShape = CCScaleTo:create(duration, 1, 0.9)
	local pressMove = CCMoveBy:create(duration, ccp(0, -3))
	local press = CCSpawn:createWithTwoActions(pressShape, pressMove)
	actArr:addObject(press)

	local bouceShape = CCScaleTo:create(duration, 0.64, 1.3)
	local bounceMove = CCMoveBy:create(duration, ccp(0, 12))
	local bounce = CCSpawn:createWithTwoActions(bouceShape, bounceMove)
	actArr:addObject(bounce)
	-- self.itemSprite:runAction(CCSequence:createWithTwoActions(CCSequence:create(actArr), CCCallFunc:create(onBreakEnd)))
	self.itemSprite:runAction(CCSequence:create(actArr))
	self:_addBlastCircleEffect(kCharacterAnimationTime, duration, -110, 70, onBreakEnd)
end

--------------------------------------------------------------------------------
--									COUNT DOWN
--------------------------------------------------------------------------------
function TileMoleBossSeed:playCountDownAnimation(callback)
	local function onAnimationEnded()
		if self.countDown > 0 then
			self:setIdleAnimation()
		else
			self:removeViewPack()
		end
		
		if type(callback) == "function" then callback() end
	end

	self:removeViewPack()

	local animationPrefix = assetNamePrefix.."decrease_"..self.countDown
	self.bagSprite = Sprite:createWithSpriteFrameName(animationPrefix.."_0000")
	if self.countDown == 2 then
		self.bagSprite:setPosition(ccp(2, 9.8))
	else
		self.bagSprite:setPosition(ccp(-2, -0.2))
	end

	local containerSprite = Sprite:createEmpty()
	containerSprite:setTexture(self.parentTexture)
	containerSprite:addChildAt(self.bagSprite, SeedLayerIndex.bagLayer)

	self.itemSprite = containerSprite
	-- self.itemSprite:setPosition(ccp(0, -3))
	self:addChildAt(self.itemSprite, 0)

	local animationFrame = 19
	if self.countDown == 2 then
		animationFrame = 20
	end

	local frames = SpriteUtil:buildFrames(animationPrefix.."_%04d", 0, animationFrame)
	local animation = SpriteUtil:buildAnimate(frames, animationTime)
	self.bagSprite:play(animation, 0, 1, onAnimationEnded)

	self.countDown = self.countDown - 1
end

--------------------------------------------------------------------------------
--									EFFECT
--------------------------------------------------------------------------------
function TileMoleBossSeed:_addBlastCircleEffect(animationTime, delay, xShift, yShift, callback)
	local function startEffect()
		local circleEffect = Sprite:createWithSpriteFrameName("mole_skill_seed_vanish_effect_0000")
		circleEffect:setPosition(ccp(xShift, 0 + yShift))
		self:addChildAt(circleEffect, 1)	--1: upper than itemSprite
		local frames = SpriteUtil:buildFrames("mole_skill_seed_vanish_effect_%04d", 0, 15)
		local animate = SpriteUtil:buildAnimate(frames, animationTime)
		circleEffect:play(animate, 0, 1, callback, true)
	end
	
	self.itemSprite:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(delay), CCCallFunc:create(startEffect)))
end

function TileMoleBossSeed:playHitEffectAnimation(startPoint, endPoint)
	-- printx(11, "hit!   from ("..startPoint.x..","..startPoint.y..")  to  ("..endPoint.x..","..endPoint.y..")")
	local layer = Layer:create()

	local animation = Sprite:createWithSpriteFrameName("mole_skill_seed_hit_line_0000")
	local frames = SpriteUtil:buildFrames("mole_skill_seed_hit_line_%04d", 0, 19)
	-- local animation = Sprite:createWithSpriteFrameName("blocker_pacman_effect_hit_0000")
	-- local frames = SpriteUtil:buildFrames("blocker_pacman_effect_hit_%04d", 0, 22)
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	animation:play(animate, 0, 1, onAnimationFinished, true)

	local angle = -math.deg(math.atan2(endPoint.y - startPoint.y, endPoint.x - startPoint.x))
	animation:setPosition(startPoint)
	animation:setRotation(angle)
	animation:setAnchorPoint(ccp(0.8, 0.46))

	local function finishCallback()
		-- printx(11, "+ + + hit finished + + +")

		local function blastCallBack()
			-- printx(11, "+ + + blast finished + + +")
			layer:removeFromParentAndCleanup(true)
		end
		
		local circleEffect = Sprite:createWithSpriteFrameName("mole_skill_seed_vanish_effect_0000")
		circleEffect:setPosition(ccp(endPoint.x - 110, endPoint.y + 70))
		layer:addChildAt(circleEffect, 1)	--1: upper than itemSprite
		local frames = SpriteUtil:buildFrames("mole_skill_seed_vanish_effect_%04d", 0, 15)
		local animate = SpriteUtil:buildAnimate(frames, animationTime)
		circleEffect:play(animate, 0, 1, blastCallBack, true)
	end

	local actArr = CCArray:create()
	actArr:addObject(CCMoveTo:create(0.4, ccp(endPoint.x , endPoint.y)))
	-- actArr:addObject(CCDelayTime:create(0.5))
	actArr:addObject(CCCallFunc:create(finishCallback) )
	animation:runAction(CCSequence:create(actArr))

	layer:addChild(animation)

	return layer
end


