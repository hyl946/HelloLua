TilePacmansDen = class(CocosObject)

local PacmansDenLayerIndex = {
	bodyLayer = 1,
	progressLayer = 2,
	glassLayer = 3,
}

local kCharacterAnimationTime = 1/30

function TilePacmansDen:create(texture)
	-- local node = TilePacmansDen.new(CCNode:create())
	-- node.name = "pacmansDen"

	local sprite = CCSprite:create()
	sprite:setTexture(texture)
	local node = TilePacmansDen.new(sprite)
	node.name = "pacmansDen"
	node.parentTexture = texture

	local itemSprite = Sprite:createWithSpriteFrameName("blocker_pacmansDen_idle_0000")
	node.itemSprite = itemSprite
	node.itemSprite:setPosition(ccp(0, -1))
	node:addChild(itemSprite)

	node:init()

	return node
end

function TilePacmansDen:init()
    self:_initIdleAnimation()
end

function TilePacmansDen:removeViewPack()
	if self.body and not self.body.isDisposed then
		self.body:removeFromParentAndCleanup(true)
		self.body = nil
	end

	if self.glass and not self.glass.isDisposed then
		self.glass:removeFromParentAndCleanup(true)
		self.glass = nil
	end

	if self.progress and not self.progress.isDisposed then
		self.progress:removeFromParentAndCleanup(true)
		self.progress = nil
	end

	if self.itemSprite and not self.itemSprite.isDisposed then
		self.itemSprite:removeFromParentAndCleanup(true)
		self.itemSprite = nil
	end
end

--------------------------------------------------------------------------------
--									IDLE
--------------------------------------------------------------------------------
function TilePacmansDen:_initIdleAnimation()
	-- printx(11, "+ + + init pacmans den + + +")
	self:removeViewPack()

	self.body = Sprite:createWithSpriteFrameName("blocker_pacmansDen_idle_0000")
	self.glass = Sprite:createWithSpriteFrameName("blocker_pacmansDen_glass_0000")

	local progressFrame = self:_getProgressFrame()
	local progressSuffix = ""..progressFrame
	if progressFrame < 10 then progressSuffix = "0"..progressSuffix end
	self.progress = Sprite:createWithSpriteFrameName("blocker_pacmansDen_progress_00"..progressSuffix)
	self.currProgressFrame = progressFrame
	-- self.progress = Sprite:createWithSpriteFrameName("blocker_pacmansDen_progress_0000")
	-- if self.currProgressFrame == nil then 
	-- 	self.currProgressFrame = 0
	-- end

	--- adjust positions
	self.body:setPosition(ccp(3, -10))
	self.glass:setPosition(ccp(1, 6))
	self.progress:setPosition(ccp(-159, 162))

	local containerSprite = Sprite:createEmpty()
	containerSprite:setTexture(self.parentTexture)
	containerSprite:addChildAt(self.body, PacmansDenLayerIndex.bodyLayer)
	containerSprite:addChildAt(self.progress, PacmansDenLayerIndex.progressLayer)
	containerSprite:addChildAt(self.glass, PacmansDenLayerIndex.glassLayer)

	self.itemSprite = containerSprite
	self.itemSprite:setPosition(ccp(-1, 2))
	self:addChildAt(self.itemSprite, 0)

	--- idleAnimation
	self:_playIdleAnimation()
	-- self:updateProgressDisplay()
end

function TilePacmansDen:_playIdleAnimation()
    self.body:stopAllActions()

    local frames = SpriteUtil:buildFrames("blocker_pacmansDen_idle_%04d", 0, 30)
	local idleAnimation = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	self.body:play(idleAnimation)
end

function TilePacmansDen:updateProgressDisplay(toProgressFrame)
	local progressFrame = self:_getProgressFrame()
	if toProgressFrame then
		progressFrame = toProgressFrame
	end

	-- printx(11, "= = = = update den progress animation. oldFrame, newFrame:", self.currProgressFrame, progressFrame)
	if self.currProgressFrame == progressFrame then
		return
	end

	local startFrame = self.currProgressFrame
	local frameLength = progressFrame - startFrame
	if frameLength <= 0 then
		startFrame = 0
		frameLength = math.max(progressFrame, 1)
	end

	-- local frames = SpriteUtil:buildFrames("blocker_pacmansDen_progress_%04d", self.currProgressFrame, progressFrame)
	local frames = SpriteUtil:buildFrames("blocker_pacmansDen_progress_%04d", startFrame, frameLength)
	-- printx(11, "= = = = build frame. startFrame, frameLength:", startFrame, frameLength)
	local progressAnimation = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	self.progress:stopAllActions()
	self.progress:play(progressAnimation, 0, 1)
	
	self.currProgressFrame = progressFrame
end

function TilePacmansDen:_getProgressFrame()
	local totalFrames = 29

	local progressPercent = PacmanLogic:getDenProduceProgress(GameBoardLogic:getCurrentLogic())
	-- printx(11, "_getProgressFrame, progressPercent:", progressPercent)
	local currFrame = math.floor(progressPercent * totalFrames)
	currFrame = math.max(currFrame, 0)
	-- printx(11, " + + + + + Curr Progress Frame:", currFrame)
	return currFrame
end

--------------------------------------------------------------------------------
--									GENERATE
--------------------------------------------------------------------------------
function TilePacmansDen:playGeneratePacmanAnimation(finishCallBack)
	self.body:stopAllActions()
	self.itemSprite:setVisible(false)
	self:updateProgressDisplay(0)

	local function onAnimationFinished()
		-- printx(11, "on Generate AnimationFinished")
		-- self.generateAnimation = nil
		self.itemSprite:setVisible(true)
		self:_playIdleAnimation()
		-- self:updateProgressDisplay()
		if type(finishCallBack) == "function" then finishCallBack() end
	end

	local generateAnimation = Sprite:createWithSpriteFrameName("blocker_pacmansDen_generate_0000")
	-- self.generateAnimation = generateAnimation
	generateAnimation:setPosition(ccp(0.5, 12))
	self:addChild(generateAnimation)

	local frames = SpriteUtil:buildFrames("blocker_pacmansDen_generate_%04d", 0, 16)
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	generateAnimation:play(animate, 0, 1, onAnimationFinished, true)
end

---generate pacman
function TilePacmansDen:playOnePacmanGenerate(direction, color, callback)
	local bodyAssetPrefix = "blocker_pacman_jump_body_"..color
	local handAssetPrefix = "blocker_pacman_jump_hand_"..color
	local ballAssetPrefix = "blocker_pacman_jump_ball_1"
	local body = Sprite:createWithSpriteFrameName(bodyAssetPrefix.."_0000")
	local hand = Sprite:createWithSpriteFrameName(handAssetPrefix.."_0000")
	local ball = Sprite:createWithSpriteFrameName(ballAssetPrefix.."_0000")
	ball:setPosition(ccp(0, 2))

	local containerSprite = Sprite:createEmpty()
	containerSprite:setTexture(self.parentTexture)
	containerSprite:addChildAt(body, 1)
	containerSprite:addChildAt(hand, 3)
	containerSprite:addChildAt(ball, 2)
	self:addChildAt(containerSprite, 10)		--层级窝自己本身高
	
	-- animation
	local moveAnimationTime = kCharacterAnimationTime * 30 / 30

	self:_playCertainAnimation(body, bodyAssetPrefix, 30, moveAnimationTime)
	self:_playCertainAnimation(hand, handAssetPrefix, 30, moveAnimationTime)
	self:_playCertainAnimation(ball, ballAssetPrefix, 30, moveAnimationTime)

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
	-- actArr:addObject(CCMoveBy:create(11 * moveAnimationTime, ccp(directionXShift, directionYShift)))
	containerSprite:setScale(0.01)
	local scaleShiftY = 20
	containerSprite:setPosition(ccp(0, 2))
	local jumpScale = CCScaleTo:create(11 * moveAnimationTime, 1)
	local jumpMove = CCMoveBy:create(11 * moveAnimationTime, ccp(directionXShift, directionYShift + scaleShiftY))
	local jump = CCSpawn:createWithTwoActions(jumpScale, jumpMove)
	actArr:addObject(jump)
	actArr:addObject(CCDelayTime:create(5 * moveAnimationTime))

	local function onJumpFinish()
		if containerSprite then
			containerSprite:removeFromParentAndCleanup(true)
			containerSprite = nil
		end
		if type(callback) == "function" then callback() end
	end

	containerSprite:runAction(CCSequence:createWithTwoActions(CCSequence:create(actArr), CCCallFunc:create(onJumpFinish)))
end

function TilePacmansDen:_playCertainAnimation(targetSprite, spritePrefix, animationFrame, animationTime)
	if targetSprite then
		targetSprite:stopAllActions()

	    local frames = SpriteUtil:buildFrames(spritePrefix.."_%04d", 0, animationFrame)
		local animation = SpriteUtil:buildAnimate(frames, animationTime)
		targetSprite:play(animation, 0, 1, nil, true)
	end
end