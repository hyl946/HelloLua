TilePacman = class(CocosObject)

PacmanJumpDirection = table.const{
	kUp = 1,
	kRight = 2,
	kDown = 3,
	kLeft = 4,
}

local PacmanLayerIndex = {
	bodyLayer = 1,
	progressLayer = 2,
	handLayer = 3,
	hueLayer = 4,
}

local kCharacterAnimationTime = 1/30

function TilePacman:create(texture, color, devourAmount, fullDevourAmount, isSuper)
	-- local node = TilePacman.new(CCNode:create())
	-- node.name = "pacman"
	
	local sprite = CCSprite:create()
	sprite:setTexture(texture)
	local node = TilePacman.new(sprite)
	node.name = "pacman"
	node.parentTexture = texture

	node:init(color, devourAmount, fullDevourAmount, isSuper)

	return node
end

function TilePacman:init(color, devourAmount, fullDevourAmount, isSuper)
    self.color = color
    self.devourAmount = devourAmount
    self.fullDevourAmount = fullDevourAmount

    if isSuper and isSuper == 2 then	--只有为2的时候，动画才体现超级效果
    	self:setIdleAnimation()
    	self.isSuper = true
		self:changeToSuper()
	else
		if isSuper and isSuper == 1 then
	    	self.isSuper = true
	    end
		self:setIdleAnimation()
    end
end

function TilePacman:removeViewPack()
	if self.body and not self.body.isDisposed then
		self.body:removeFromParentAndCleanup(true)
		self.body = nil
	end

	if self.hand and not self.hand.isDisposed then
		self.hand:removeFromParentAndCleanup(true)
		self.hand = nil
	end

	if self.progress and not self.progress.isDisposed then
		self.progress:removeFromParentAndCleanup(true)
		self.progress = nil
	end

	if self.hue and not self.hue.isDisposed then
		self.hue:removeFromParentAndCleanup(true)
		self.hue = nil
	end

	if self.itemSprite and not self.itemSprite.isDisposed then
		self.itemSprite:removeFromParentAndCleanup(true)
		self.itemSprite = nil
	end
end

--------------------------------------------------------------------------------
--									IDLE
--------------------------------------------------------------------------------
function TilePacman:setIdleAnimation()
	self:removeViewPack()

	local bodyAssetPrefix = "blocker_pacman_idle_body_"..self.color
	local handAssetPrefix = "blocker_pacman_idle_hand_"..self.color
	local hueAssetPrefix = nil
	if self.isSuper then
		bodyAssetPrefix = "blocker_pacman_idle_super_body_"..self.color
		hueAssetPrefix = "blocker_pacman_effect_super_idle"
	end
	self.body = Sprite:createWithSpriteFrameName(bodyAssetPrefix.."_0000")
	self.hand = Sprite:createWithSpriteFrameName(handAssetPrefix.."_0000")
	if hueAssetPrefix then self.hue = Sprite:createWithSpriteFrameName(hueAssetPrefix.."_0000") end

	local progressFrame = self:_getProgressFrame()
	local progressSuffix = ""..progressFrame
	if progressFrame < 10 then progressSuffix = "0"..progressSuffix end
	self.progress = Sprite:createWithSpriteFrameName("blocker_pacman_progress_00"..progressSuffix)

	--- adjust positions
	if self.isSuper then self.body:setPosition(ccp(0, 3)) end
	self.hand:setPosition(ccp(0, 3))
	self.progress:setPosition(ccp(0, -11))
	-- if self.hue then self.hue:setPosition(ccp(0, -11)) end

	local containerSprite = Sprite:createEmpty()
	containerSprite:setTexture(self.parentTexture)
	containerSprite:addChildAt(self.body, PacmanLayerIndex.bodyLayer)
	containerSprite:addChildAt(self.hand, PacmanLayerIndex.handLayer)
	containerSprite:addChildAt(self.progress, PacmanLayerIndex.progressLayer)
	if self.hue then containerSprite:addChildAt(self.hue, PacmanLayerIndex.hueLayer) end

	self.itemSprite = containerSprite
	self.itemSprite:setPosition(ccp(0, -3))
	self:addChildAt(self.itemSprite, 0)

	--- idleAnimation
	self:_playCertainAnimation(self.body, bodyAssetPrefix, 15, kCharacterAnimationTime, true)
	self:_playCertainAnimation(self.hand, handAssetPrefix, 15, kCharacterAnimationTime, true)
	self:_playCertainAnimation(self.hue, hueAssetPrefix, 15, kCharacterAnimationTime, true)
end

function TilePacman:_playCertainAnimation(targetSprite, spritePrefix, animationFrame, animationTime, doubleWithReverse)
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

function TilePacman:_getProgressFrame()
	local totalFrames = 29

	-- printx(11, " + + + + + devourAmount, fullDevourAmount", self.devourAmount, self.fullDevourAmount)
	local currFrame = math.floor(math.min(self.devourAmount / self.fullDevourAmount, 1) * totalFrames)
	currFrame = math.max(currFrame, 0)
	-- printx(11, " + + + + + Curr Progress Frame:", currFrame)
	return currFrame
end

--------------------------------------------------------------------------------
--								Change to Super
--------------------------------------------------------------------------------
function TilePacman:changeToSuper()
	-- printx(11, " + + + + + view changeToSuper")
	local toSuperEffectAnimation = Sprite:createWithSpriteFrameName("blocker_pacman_effect_super_transform_0000")
	toSuperEffectAnimation:setPosition(ccp(-150, 150))
	self:addChildAt(toSuperEffectAnimation, 1)	--1: upper than itemSprite

	local frames = SpriteUtil:buildFrames("blocker_pacman_effect_super_transform_%04d", 0, 16)
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	toSuperEffectAnimation:play(animate, 0, 1, onAnimationFinished, true)

	local function changePacman()
		self.isSuper = true
		self:setIdleAnimation()
	end
	self.itemSprite:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(9 * kCharacterAnimationTime), CCCallFunc:create(changePacman)))
end

--------------------------------------------------------------------------------
--									JUMP
--------------------------------------------------------------------------------
function TilePacman:playPacmanJump(direction, callback)
	self:removeViewPack()

	local bodyAssetPrefix = "blocker_pacman_jump_body_"..self.color
	local handAssetPrefix = "blocker_pacman_jump_hand_"..self.color
	local hueAssetPrefix = nil
	if self.isSuper then
		hueAssetPrefix = "blocker_pacman_effect_super_jump"
	end
	self.body = Sprite:createWithSpriteFrameName(bodyAssetPrefix.."_0000")
	self.hand = Sprite:createWithSpriteFrameName(handAssetPrefix.."_0000")
	if hueAssetPrefix then self.hue = Sprite:createWithSpriteFrameName(hueAssetPrefix.."_0000") end

	local progressFrame = self:_getProgressFrame()
	local progressSuffix = ""..progressFrame
	if progressFrame < 10 then progressSuffix = "0"..progressSuffix end
	self.progress = Sprite:createWithSpriteFrameName("blocker_pacman_progress_00"..progressSuffix)

	--- adjust positions
	if self.isSuper then self.body:setPosition(ccp(0, 3)) end
	self.hand:setPosition(ccp(0, -2))
	self.progress:setPosition(ccp(0, -35.5))
	if self.hue then self.hue:setPosition(ccp(0, 5)) end

	local containerSprite = Sprite:createEmpty()
	containerSprite:setTexture(self.parentTexture)
	containerSprite:addChildAt(self.body, PacmanLayerIndex.bodyLayer)
	containerSprite:addChildAt(self.hand, PacmanLayerIndex.handLayer)
	containerSprite:addChildAt(self.progress, PacmanLayerIndex.progressLayer)
	if self.hue then containerSprite:addChildAt(self.hue, PacmanLayerIndex.hueLayer) end

	self.itemSprite = containerSprite
	if self.isSuper then
		self.itemSprite:setPosition(ccp(0, 18))
	else
		self.itemSprite:setPosition(ccp(0, 22))
	end
	self:addChildAt(self.itemSprite, 0)
	
	--- animation
	local moveAnimationTime = kCharacterAnimationTime * 30 / 45

	self:_playCertainAnimation(self.body, bodyAssetPrefix, 30, moveAnimationTime)
	self:_playCertainAnimation(self.hand, handAssetPrefix, 30, moveAnimationTime)
	self:_playCertainAnimation(self.hue, hueAssetPrefix, 30, moveAnimationTime)

	local directionXShift = 0
	local directionYShift = 0
	if direction == PacmanJumpDirection.kUp then
		directionYShift = 70
	elseif direction == PacmanJumpDirection.kRight then
		directionXShift = 70
	elseif direction == PacmanJumpDirection.kDown then
		directionYShift = -70
	elseif direction == PacmanJumpDirection.kLeft then
		directionXShift = -70
	end

	local actArr = CCArray:create()
	actArr:addObject(CCDelayTime:create(8 * moveAnimationTime))
	actArr:addObject(CCMoveBy:create(11 * moveAnimationTime, ccp(directionXShift, directionYShift)))
	actArr:addObject(CCDelayTime:create(11 * moveAnimationTime))
	-- local jumpAction = CCSpawn:createWithTwoActions(CCSequence:create(actArr), animate)

	local function onJumpFinish()
		if type(callback) == "function" then callback() end
	end
	-- self.itemSprite:runAction(CCSequence:createWithTwoActions(jumpAction, CCCallFunc:create(onJumpFinish)))
	self.itemSprite:runAction(CCSequence:createWithTwoActions(CCSequence:create(actArr), CCCallFunc:create(onJumpFinish)))

	self:setProgressJumpRoute(moveAnimationTime)
	self:setStompEffect(moveAnimationTime, 15 * moveAnimationTime, directionXShift, directionYShift)
end

function TilePacman:setProgressJumpRoute(moveAnimationTime)
	local actArr = CCArray:create()

	local ballPress = CCScaleTo:create(6 * moveAnimationTime, 1, 0.75)
	local ballPressMove = CCMoveBy:create(6 * moveAnimationTime, ccp(0, -6))
	local press = CCSpawn:createWithTwoActions(ballPress, ballPressMove)
	actArr:addObject(press)

	local ballBounce = CCScaleTo:create(1 * moveAnimationTime, 1, 1)
	local ballBounceMove = CCMoveBy:create(1 * moveAnimationTime, ccp(0, 40))
	local bounce = CCSpawn:createWithTwoActions(ballBounce, ballBounceMove)
	actArr:addObject(bounce)

	actArr:addObject(CCMoveBy:create(1 * moveAnimationTime, ccp(0, 30)))

	local ballSlim = CCScaleTo:create(4 * moveAnimationTime, 0.85, 1)
	local ballSlimMove = CCMoveBy:create(4 * moveAnimationTime, ccp(0, 16))
	local slim = CCSpawn:createWithTwoActions(ballSlim, ballSlimMove)
	actArr:addObject(slim)

	local ballSlimBounce = CCScaleTo:create(3 * moveAnimationTime, 1, 1)
	local ballSlimBounceMove = CCMoveBy:create(3 * moveAnimationTime, ccp(0, -20))
	local slimBounce = CCSpawn:createWithTwoActions(ballSlimBounce, ballSlimBounceMove)
	actArr:addObject(slimBounce)

	actArr:addObject(CCMoveBy:create(3 * moveAnimationTime, ccp(0, -60)))
	
	local ballPress2 = CCScaleTo:create(2 * moveAnimationTime, 1, 0.75)
	local ballPressMove2 = CCMoveBy:create(2 * moveAnimationTime, ccp(0, -6))
	local press2 = CCSpawn:createWithTwoActions(ballPress2, ballPressMove2)
	actArr:addObject(press2)

	local ballBounce2 = CCScaleTo:create(2 * moveAnimationTime, 1, 1)
	local ballBounceMove2 = CCMoveBy:create(2 * moveAnimationTime, ccp(0, 6))
	local bounce2 = CCSpawn:createWithTwoActions(ballBounce2, ballBounceMove2)
	actArr:addObject(bounce2)

	actArr:addObject(CCDelayTime:create(8 * moveAnimationTime))

	self.progress:runAction(CCSequence:create(actArr))
end

function TilePacman:setStompEffect(moveAnimationTime, delay, xShift, yShift)
	local function startStomp()
		local stompEffect1 = Sprite:createWithSpriteFrameName("blocker_pacman_effect_eat_1_0000")
		stompEffect1:setPosition(ccp(xShift, 0 + yShift))
		self:addChildAt(stompEffect1, 1)	--1: upper than itemSprite
		local frames = SpriteUtil:buildFrames("blocker_pacman_effect_eat_1_%04d", 0, 10)
		local animate = SpriteUtil:buildAnimate(frames, moveAnimationTime)
		stompEffect1:play(animate, 0, 1, onAnimationFinished, true)

		local stompEffect2 = Sprite:createWithSpriteFrameName("blocker_pacman_effect_eat_2_0000")
		stompEffect2:setPosition(ccp(-152 + xShift, 150 + yShift))
		self:addChildAt(stompEffect2, 2)	--2: upper than itemSprite and stompEffect1
		local frames = SpriteUtil:buildFrames("blocker_pacman_effect_eat_2_%04d", 0, 16)
		local animate = SpriteUtil:buildAnimate(frames, moveAnimationTime)
		stompEffect2:play(animate, 0, 1, onAnimationFinished, true)
	end
	
	self.itemSprite:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(delay), CCCallFunc:create(startStomp)))
end

--------------------------------------------------------------------------------
--									BLAST
--------------------------------------------------------------------------------
function TilePacman:playPacmanBlastAnimation(callback)
	self.itemSprite:stopAllActions()

	local function onBlastEnd()
		self.itemSprite:setVisible(false)
		if type(callback) == "function" then callback() end
	end

	local actArr = CCArray:create()
	actArr:addObject(CCScaleTo:create(4 * kCharacterAnimationTime, 1.2))
	actArr:addObject(CCScaleTo:create(6 * kCharacterAnimationTime, 0.01))
	actArr:addObject(CCDelayTime:create(12 * kCharacterAnimationTime))

	self.itemSprite:runAction(CCSequence:createWithTwoActions(CCSequence:create(actArr), CCCallFunc:create(onBlastEnd)))
	self:setStompEffect(kCharacterAnimationTime, 8 * kCharacterAnimationTime, 0, 0)
end

function TilePacman:playHitEffectAnimation(startPoint, endPoint)
	local layer = Layer:create()

	local animation = Sprite:createWithSpriteFrameName("blocker_pacman_effect_hit_0000")
	local frames = SpriteUtil:buildFrames("blocker_pacman_effect_hit_%04d", 0, 22)
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	animation:play(animate, 0, 1, onAnimationFinished, true)

	local angle = -math.deg(math.atan2(endPoint.y - startPoint.y, endPoint.x - startPoint.x))
	animation:setPosition(startPoint)
	animation:setRotation(angle)
	animation:setAnchorPoint(ccp(0.8, 0.46))

	local function finishCallback()
		layer:removeFromParentAndCleanup(true) 
	end

	local actArr = CCArray:create()
	actArr:addObject(CCMoveTo:create(0.4, ccp(endPoint.x , endPoint.y)))
	actArr:addObject(CCDelayTime:create(0.5))
	actArr:addObject(CCCallFunc:create(finishCallback) )
	animation:runAction(CCSequence:create(actArr))

	layer:addChild(animation)

	return layer
end