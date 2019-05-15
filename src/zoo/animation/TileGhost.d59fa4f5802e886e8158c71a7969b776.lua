TileGhost = class(CocosObject)

local kCharacterAnimationTime = 1/30

local assetPrefix = "blocker_ghost_"
local assetShiftY = 5
local assetActiveShiftY = 9

-------------------------------------------------------------------------------------
function TileGhost:create(isActive)
	local node = TileGhost.new(CCNode:create())
	node.name = "ghostBlocker"
	
	if isActive then
		node:switchToActiveView()
	else
		node:playIdleAnimation()
	end

	-- printx(11, "TileGhost sprite created", debug.traceback())
	return node
end

function TileGhost:_cleanSprite()
	if self.sprite then 
		self.sprite:removeFromParentAndCleanup(true)
	end
end

function TileGhost:playIdleAnimation()
	self:_cleanSprite()

	self.sprite = Sprite:createWithSpriteFrameName(assetPrefix.."idle_0000")
	self:addChild(self.sprite)

	local frames = SpriteUtil:buildFrames(assetPrefix.."idle_%04d", 0, 64)
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	self.sprite:runAction(CCRepeatForever:create(animate))

	self.isActiveView = false

	self.sprite:setPosition(ccp(0, assetShiftY))
end

function TileGhost:playGhostAppear()
	local function onAnimationFinished()
		self:playIdleAnimation()
		self.sprite:setVisible(true)
	end

	self.sprite:stopAllActions()
	self.sprite:setVisible(false)

	local generateAnimation = Sprite:createWithSpriteFrameName(assetPrefix.."appear_0000")
	-- self.generateAnimation = generateAnimation
	-- generateAnimation:setPosition(ccp(0.5, 12))
	self:addChild(generateAnimation)

	local frames = SpriteUtil:buildFrames(assetPrefix.."appear_%04d", 0, 16)
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	generateAnimation:play(animate, 0, 1, onAnimationFinished, true)

	GamePlayMusicPlayer:playEffect(GameMusicType.kGhostAppear)
end

function TileGhost:switchToActiveView()
	if not self.isActiveView then
		self:_cleanSprite()

		self.sprite = Sprite:createWithSpriteFrameName(assetPrefix.."active_0000")
		self:addChild(self.sprite)

		local frames = SpriteUtil:buildFrames(assetPrefix.."active_%04d", 0, 20)
		local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
		self.sprite:runAction(CCRepeatForever:create(animate))
		self.sprite:setPosition(ccp(0, assetShiftY + assetActiveShiftY))

		self.isActiveView = true
	end
end

function TileGhost:playFlyAnimation(pace)
	-- printx(11, "pace, moveSpeed:", pace, moveSpeed)
	local function onAnimationFinished()
		-- self:playIdleAnimation()
	end

	self:_cleanSprite()

	local framesLength
	local nameLable = "move_"
	if pace <-5 then
		nameLable = nameLable.."2"
		framesLength = 41
	else
		nameLable = nameLable.."1"
		framesLength = 35
	end

	self.sprite = Sprite:createWithSpriteFrameName(assetPrefix..nameLable.."_0000")
	self:addChild(self.sprite)

	local frames = SpriteUtil:buildFrames(assetPrefix..nameLable.."_%04d", 0, framesLength)
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	-- self.sprite:play(animate, 0, 1, onAnimationFinished, true)
	self.sprite:play(animate, 0, 1, onAnimationFinished)

	self.isActiveView = false

	--- move
	local moveAnimationTime = kCharacterAnimationTime * 30 / 45

	local actArr = CCArray:create()
	actArr:addObject(CCDelayTime:create(8 * moveAnimationTime))
	actArr:addObject(CCMoveBy:create(15 * moveAnimationTime, ccp(0, -70 * pace + assetActiveShiftY)))
	actArr:addObject(CCDelayTime:create(11 * moveAnimationTime))
	-- local jumpAction = CCSpawn:createWithTwoActions(CCSequence:create(actArr), animate)

	local function onClimbFinished()
		-- if type(callback) == "function" then callback() end
	end
	-- self.sprite:runAction(CCSequence:createWithTwoActions(jumpAction, CCCallFunc:create(onClimbFinished)))
	self.sprite:runAction(CCSequence:createWithTwoActions(CCSequence:create(actArr), CCCallFunc:create(onClimbFinished)))

	GamePlayMusicPlayer:playEffect(GameMusicType.kGhostMove)
end

function TileGhost:playDisappearAnimation()
	self:_cleanSprite()

	self.sprite = Sprite:createWithSpriteFrameName(assetPrefix.."vanish_0000")
	self:addChild(self.sprite)

	local frames = SpriteUtil:buildFrames(assetPrefix.."vanish_%04d", 0, 22)
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	self.sprite:play(animate, 0, 1, onAnimationFinished, true)

	self.sprite:setPosition(ccp(-243, 70))

	GamePlayMusicPlayer:playEffect(GameMusicType.kGhostDisappear)
end
