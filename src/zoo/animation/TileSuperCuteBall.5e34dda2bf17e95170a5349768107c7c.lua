TileSuperCuteBall = class(CocosObject)

SuperCuteBallJumpDirection = table.const{
	kUp = 1,
	kRight = 2,
	kDown = 3,
	kLeft = 4,
}

local kCharacterAnimationTime = 1/30

local kMaskShowTime = 12 * kCharacterAnimationTime
local kMaskHideTime = 8 * kCharacterAnimationTime

-------------------------------------------------------------------------------------
function TileSuperCuteBall:create(state)
	local s = TileSuperCuteBall.new(CCNode:create())
	s:init(state)
	return s
end

function TileSuperCuteBall:init(state)
	self.bgMaskSprite = Sprite:createWithSpriteFrameName("super_cute_bg_mask")
	self:addChild(self.bgMaskSprite)
	if state == GameItemSuperCuteBallState.kActive then
		self:playIdle(0)
	elseif state == GameItemSuperCuteBallState.kInactive then
		self:playInactive()
	else
		assert(false, "invalid super ball state:"..tostring(state))
	end
end

function TileSuperCuteBall:showBgMask(time)
	if self.bgMaskSprite then
		time = time or 0
		self.bgMaskSprite:stopAllActions()
		if time <= 0 then
			self.bgMaskSprite:setOpacity(255)
		else
			self.bgMaskSprite:runAction(CCEaseSineIn:create(CCFadeTo:create(time, 255)))
		end
	end
end

function TileSuperCuteBall:hideBgMask(time)
	if self.bgMaskSprite then
		time = time or 0
		self.bgMaskSprite:stopAllActions()
		if time <= 0 then
			self.bgMaskSprite:setOpacity(0)
		else
			self.bgMaskSprite:runAction(CCEaseSineOut:create(CCFadeTo:create(time, 0)))
		end
	end
end

function TileSuperCuteBall:playInactive()
	if self.sprite then self.sprite:removeFromParentAndCleanup(true) end
	self.sprite = Sprite:createWithSpriteFrameName("super_cute_ball_show_0000")
	self.sprite:setPosition(ccp(0, 7))
	self:addChild(self.sprite)
	self:hideBgMask(kMaskHideTime)
end

function TileSuperCuteBall:playIdle(noMaskAnime)
	if self.sprite then self.sprite:removeFromParentAndCleanup(true) end
	self.sprite = Sprite:createWithSpriteFrameName("super_cute_ball_idle_0000")
	self:addChild(self.sprite)

	local frames = SpriteUtil:buildFrames("super_cute_ball_idle_%04d", 0, 21)
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)

	self.sprite:runAction(CCRepeatForever:create(animate))
	if noMaskAnime then
		self:showBgMask(0)
	else
		self:showBgMask(kMaskShowTime)
	end
end

function TileSuperCuteBall:playJump(direction, callback)
	if self.sprite then self.sprite:removeFromParentAndCleanup(true) end
	self.sprite = Sprite:createWithSpriteFrameName("super_cute_ball_jump_0000")
	self.sprite:setPosition(ccp(0, 8))
	self:addChild(self.sprite)
	
	--移动加速
	local moveAnimationTime = kCharacterAnimationTime * 30 / 36

	local frames = SpriteUtil:buildFrames("super_cute_ball_jump_%04d", 0, 31)
	local animate = SpriteUtil:buildAnimate(frames, moveAnimationTime)

	local moveAction = nil
	local actArr = CCArray:create()
	actArr:addObject(CCDelayTime:create(5 * moveAnimationTime))

	if direction == SuperCuteBallJumpDirection.kUp then
		actArr:addObject(CCMoveBy:create(4 * moveAnimationTime, ccp(0, 70)))
	elseif direction == SuperCuteBallJumpDirection.kRight then
		actArr:addObject(CCMoveBy:create(4 * moveAnimationTime, ccp(36, 5.5)))
		actArr:addObject(CCMoveBy:create(7 * moveAnimationTime, ccp(34, -5.5)))
	elseif direction == SuperCuteBallJumpDirection.kDown then
		actArr:addObject(CCMoveBy:create(4 * moveAnimationTime, ccp(0, -43)))
		actArr:addObject(CCMoveBy:create(7 * moveAnimationTime, ccp(0, -27)))
	elseif direction == SuperCuteBallJumpDirection.kLeft then
		actArr:addObject(CCMoveBy:create(4 * moveAnimationTime, ccp(-36, 5.5)))
		actArr:addObject(CCMoveBy:create(7 * moveAnimationTime, ccp(-34, -5.5)))
	end

	local jumpAction = CCSpawn:createWithTwoActions(CCSequence:create(actArr), animate)
	local function onJumpFinish()
		if type(callback) == "function" then callback() end
	end
	self.sprite:runAction(CCSequence:createWithTwoActions(jumpAction, CCCallFunc:create(onJumpFinish)))
	self:hideBgMask(kMaskHideTime)
end

function TileSuperCuteBall:playHide(callback)
	if self.sprite then self.sprite:removeFromParentAndCleanup(true) end
	self.sprite = Sprite:createWithSpriteFrameName("super_cute_ball_hide_0037")
	self.sprite:setPosition(ccp(1.3, 0))

	self:addChild(self.sprite)

	local frames = SpriteUtil:buildFrames("super_cute_ball_hide_%04d", 0, 38)
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)

	local function onAnimeFinish()
		if type(callback) == "function" then callback() end
	end

	self.sprite:play(animate, 0, 1, onAnimeFinish, false)
	self:hideBgMask(kMaskHideTime)
end

function TileSuperCuteBall:playShow(callback, jumpToHighLevel)
	if self.sprite then self.sprite:removeFromParentAndCleanup(true) end
	self.sprite = Sprite:createWithSpriteFrameName("super_cute_ball_show_0000")
	self.sprite:setPosition(ccp(-0.4, 7))
	self:addChild(self.sprite)

	local frames = SpriteUtil:buildFrames("super_cute_ball_show_%04d", 0, 45)
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)

	local function onAnimeFinish()
		if type(callback) == "function" then callback() end
	end

	jumpToHighLevel = jumpToHighLevel or (function() end)
	local jumpAct = CCSequence:createWithTwoActions(CCDelayTime:create(19 * kCharacterAnimationTime), CCCallFunc:create(jumpToHighLevel))
	local showAnimate = CCSpawn:createWithTwoActions(animate, jumpAct)
	self.sprite:play(showAnimate, 0, 1, onAnimeFinish, false)
end