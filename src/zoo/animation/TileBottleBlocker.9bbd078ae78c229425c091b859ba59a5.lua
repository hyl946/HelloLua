TileBottleBlocker = class(CocosObject)

local kCharacterAnimationTime = 1 / 26

local TileBottleZIndex = {
	kBottle_B = 1,
	kBottle_Bottom = 2,
	kAniml = 3,
	kBottle_A = 4,
}

BottleBlockerState = {
	Waiting = 1,
	HitAndChanging = 2,
	ReleaseSpirit = 3,
}

local function getIndexByColor(color)
	local aniIndex = 0
	if color == AnimalTypeConfig.kBlue then 
		aniIndex = 1
	elseif color == AnimalTypeConfig.kGreen then
		aniIndex = 2
	elseif color == AnimalTypeConfig.kOrange then
		aniIndex = 3
	elseif color == AnimalTypeConfig.kPurple then
		aniIndex = 4
	elseif color == AnimalTypeConfig.kRed then
		aniIndex = 5
	elseif color == AnimalTypeConfig.kYellow then
		aniIndex = 6
	end
	if aniIndex == 0 then 
		aniIndex = math.random(1, 6)
	end
	return aniIndex
end

function TileBottleBlocker:create(level, color, texture)
	local node = TileBottleBlocker.new(CCNode:create())
	if level < 1 then level = 1 end
	if level > 3 then level = 3 end
	node:init(level, color)
	return node
end

function TileBottleBlocker:ctor()
	self.level = 0
	self.color = AnimalTypeConfig.kNone
	self.bottleA = nil
	self.bottleB = nil
	self.animal = nil
	self.bottleBottom = nil
end

function TileBottleBlocker:init(level, color)
	self.level = level
	self.color = color
	self.aniIndex = getIndexByColor(color)

	self.bottleBottom = TileBottleBlocker:createBottleBottomSprite()
	self.animal = TileBottleBlocker:createAnimalSprite(color, self.aniIndex)
	self.bottleA, self.bottleB = TileBottleBlocker:createBottleSprite(level)

	self:addChildAt(self.bottleBottom, TileBottleZIndex.kBottle_Bottom)
	self:addChildAt(self.animal, TileBottleZIndex.kAniml)
	self:addChildAt(self.bottleA, TileBottleZIndex.kBottle_A)
	if self.bottleB then self:addChildAt(self.bottleB, TileBottleZIndex.kBottle_B) end

	self:playBottleIdle()
end

function TileBottleBlocker:playBottleHitAnimation(level, newColor, onFinish)
	assert(level >= 1 and level <= 3)
	if level < 1 then level = 1 end
	if level > 3 then level = 3 end
	self.level = level - 1

	local animationCount = 2
	local function onAllAnimationCompelete()
		animationCount = animationCount - 1
		if animationCount == 0 then
			if self.level > 0 then
				self:removeAnimal()
				self.animal = TileBottleBlocker:createAnimalSprite(self.color, self.aniIndex)
				self:addChildAt(self.animal, TileBottleZIndex.kAniml)
			end
			if onFinish then onFinish() end
		end
	end
	self:playBottleBreak(level, onAllAnimationCompelete)
	self:playAnimalAnimation(level, newColor, onAllAnimationCompelete)
end

--directions = { left=true,right=true }
function TileBottleBlocker:buildTotalBreakEffect(directions, onFinish)
	directions = directions or {DefaultDirConfig.kUp, DefaultDirConfig.kRight, DefaultDirConfig.kDown, DefaultDirConfig.kLeft}
	local anim = Sprite:createEmpty()

	local function onAnimationComplete()
		if anim and not anim.isDisposed then
			anim:removeFromParentAndCleanup(true)
		end
		if onFinish then onFinish() end
	end

	if directions then
		for _, dir in pairs(directions) do
			local fly = Sprite:createEmpty()
			fly.sprite = Sprite:createWithSpriteFrameName("bottle_total_break_fly_0000")
			fly.sprite:setPosition(ccp(-3, 56))
			fly.sprite:setAnchorPoint(ccp(0.5, 1))
			fly:addChild(fly.sprite)
			local flyFrames = SpriteUtil:buildFrames("bottle_total_break_fly_%04d", 0, 16)
			local flyAnimation = SpriteUtil:buildAnimate(flyFrames, kCharacterAnimationTime)
			local flyMoveAnim = CCMoveBy:create(kCharacterAnimationTime * 16, ccp(0, 160))
			fly.sprite:runAction(CCSpawn:createWithTwoActions(flyAnimation, CCEaseSineIn:create(flyMoveAnim)))
		
			fly:setPosition(ccp(2, -4))
			fly:setAnchorPoint(ccp(0.5, 0))
			local rotation = 0
			if dir == DefaultDirConfig.kRight then 
				rotation = 90
			elseif dir == DefaultDirConfig.kDown then
				rotation = 180
			elseif dir == DefaultDirConfig.kLeft then
				rotation = 270
			end
			fly:setRotation(rotation)
			anim:addChild(fly)
		end	
	end

	local light = Sprite:createWithSpriteFrameName("bottle_total_break_lights_0000")
	local lightFrames = SpriteUtil:buildFrames("bottle_total_break_lights_%04d", 0, 15)
	local lightAnimation = SpriteUtil:buildAnimate(lightFrames, kCharacterAnimationTime)
	light:runAction(CCSequence:createWithTwoActions(lightAnimation, CCCallFunc:create(onAnimationComplete)))
	light:setPosition(ccp(-8, 6))
	anim:addChild(light)

	return anim
end

---------------- 内部实现 --------------------------
function TileBottleBlocker:createBottleBottomSprite()
	local sprite = Sprite:createWithSpriteFrameName("bottle_bottom_0000")
	sprite:setPosition(ccp(0, -28))
	return sprite
end

function TileBottleBlocker:createAnimalSprite(color, aniIndex)
	local sprite = Sprite:createEmpty()
	local body = Sprite:createWithSpriteFrameName("bottle_animal_idle_body_"..aniIndex)
	local eyes = Sprite:createWithSpriteFrameName("bottle_idle_eyes_"..aniIndex.."_0000")
	local eyesFrames = SpriteUtil:buildFrames("bottle_idle_eyes_"..aniIndex.."_%04d", 0, 9)
	local eyesAnimation = SpriteUtil:buildAnimate(eyesFrames, kCharacterAnimationTime)
	eyes:runAction(CCRepeatForever:create(eyesAnimation))
	eyes:setPosition(ccp(1, 0))

	sprite:addChild(body)
	sprite:addChild(eyes)

	local offsetPos = ccp(0, -4)
	sprite:setPosition(offsetPos)

	sprite.body = body
	sprite.eyes = eyes

	return sprite
end

function TileBottleBlocker:createBottleSpriteA(level)
	local sprite = Sprite:createWithSpriteFrameName("bottle_break_"..tostring(level).."_0000")
	local offsetPos = nil
	if level == 1 then 
		offsetPos = ccp(1.5, 3.5)
	elseif level == 2 then 
		offsetPos = ccp(0, 9)
	elseif level == 3 then 
		offsetPos = ccp(-1, -4)
	end
	if offsetPos then
		sprite:setPosition(offsetPos)
	end
	return sprite
end

function TileBottleBlocker:createBottleSpriteB(level)
	local sprite = Sprite:createWithSpriteFrameName("bottle_side_B")
	local offsetPos = ccp(1.5, -5)
	sprite:setPosition(offsetPos)
	return sprite
end

function TileBottleBlocker:createBottleSprite(level)
	assert(type(level) == "number")
	assert(level >= 1 and level <= 3, "illegal level:"..tostring(level))
	local spriteA = TileBottleBlocker:createBottleSpriteA(level)
	local spriteB = nil
	if level == 1 then spriteB = TileBottleBlocker:createBottleSpriteB(level) end
	return spriteA, spriteB
end

-- 动画
function TileBottleBlocker:playBottleIdle()
	if self.animal and not self.animal.isDisposed then
		self.animal:stopAllActions()
		if self.animal.eyes and not self.animal.eyes.isDisposed then
			self.animal.eyes:stopAllActions()
			local eyesAnim1Frames = SpriteUtil:buildFrames("bottle_idle_eyes_"..self.aniIndex.."_%04d", 0, 9)
			local eyesAnim1 = SpriteUtil:buildAnimate(eyesAnim1Frames, kCharacterAnimationTime)

			local eyesAnim2Frames = SpriteUtil:buildFrames("bottle_blink_eyes_"..self.aniIndex.."_%04d", 0, 43)
			local eyesAnim2 = SpriteUtil:buildAnimate(eyesAnim2Frames, kCharacterAnimationTime)
			local animation = CCSequence:createWithTwoActions(CCRepeat:create(eyesAnim1, 20), eyesAnim2)
			self.animal.eyes:runAction(CCRepeatForever:create(animation))
		end

		local animalAnim1 = CCSpawn:createWithTwoActions(CCMoveBy:create(kCharacterAnimationTime * 20, ccp(0, 2)), CCScaleTo:create(kCharacterAnimationTime * 20, 1, 1.01))
		local animalAnim2 = CCSpawn:createWithTwoActions(CCMoveBy:create(kCharacterAnimationTime * 20, ccp(0, -2)), CCScaleTo:create(kCharacterAnimationTime * 20, 1, 1))
		local animalAnimation = CCSequence:createWithTwoActions(animalAnim1, animalAnim2)
		self.animal:runAction(CCRepeatForever:create(animalAnimation))
	end
end

function TileBottleBlocker:addBottleB(level)
	self:removeBottleB()
	self.bottleB = TileBottleBlocker:createBottleSpriteB(level)
	self:addChildAt(self.bottleB, TileBottleZIndex.kBottle_B)
end

function TileBottleBlocker:removeBottleB()
	if self.bottleB and not self.bottleB.isDisposed then
		self.bottleB:removeFromParentAndCleanup(true) 
		self.bottleB = nil
	end
end

function TileBottleBlocker:removeBottleBottom()
	if self.bottleBottom and not self.bottleBottom.isDisposed then 
		self.bottleBottom:removeFromParentAndCleanup(true) 
		self.bottleBottom = nil
	end
end

function TileBottleBlocker:removeAnimal( ... )
	if self.animal and not self.animal.isDisposed then
		self.animal:removeFromParentAndCleanup(true)
		self.animal = nil
	end
end

local breakFrameNumbers = {17, 18, 17}
function TileBottleBlocker:playBottleBreak(level, onFinish)
	if not self.bottleA or self.bottleA.isDisposed then
		assert(false, "bottleA not exist!"..tostring(level))
		if onFinish then onFinish() end
		return
	end

	self.bottleA:removeFromParentAndCleanup(true)
	if self.bottleB then self.bottleB:removeFromParentAndCleanup(true) end
	
	self.bottleA, self.bottleB = TileBottleBlocker:createBottleSprite(level)
	self:addChildAt(self.bottleA, TileBottleZIndex.kBottle_A)
	if self.bottleB then self:addChildAt(self.bottleB, TileBottleZIndex.kBottle_B) end

	local breakFrames = SpriteUtil:buildFrames("bottle_break_"..tostring(level).."_%04d", 0, breakFrameNumbers[level])
	local breakAnim = SpriteUtil:buildAnimate(breakFrames, kCharacterAnimationTime)
	local function onAnimationComplete()
		if self.bottleA and not self.bottleA.isDisposed then
			self.bottleA:removeFromParentAndCleanup(true)
			self.bottleA = nil
		end
		if self.level > 0 then
			self.bottleA = TileBottleBlocker:createBottleSpriteA(self.level)
			self:addChildAt(self.bottleA, TileBottleZIndex.kBottle_A)
		end
		if onFinish then onFinish() end
	end
	local action1 = CCSequence:createWithTwoActions(breakAnim, CCCallFunc:create(onAnimationComplete))

	if level > 2 then
		self.bottleA:runAction(action1)
	elseif level == 2 then
		local function addBottleB()
			self:addBottleB(self.level)
		end
		local action2 = CCSequence:createWithTwoActions(CCDelayTime:create(kCharacterAnimationTime * 8), CCCallFunc:create(addBottleB))
		self.bottleA:runAction(CCSpawn:createWithTwoActions(action1, action2))
	elseif level == 1 then
		local function removeBottleB()
			self:removeBottleB()
			self:removeBottleBottom()
		end
		local action2 = CCSequence:createWithTwoActions(CCDelayTime:create(kCharacterAnimationTime * 6), CCCallFunc:create(removeBottleB))
		self.bottleA:runAction(CCSpawn:createWithTwoActions(action1, action2))
	end 
end

function TileBottleBlocker:playAnimalAnimation(level, newColor, onFinish)
	local anim = Sprite:createEmpty()
	local function onAnimationComplete()
		self:removeAnimal()
		if self.level > 0 then
			self:changeColor(newColor, onFinish)
		end
	end

	if anim.body then
		anim.body:stopAllActions()
	end

	if level > 1 then
		local body = Sprite:createWithSpriteFrameName("bottle_animal_hit_"..self.aniIndex.."_0000")
		local bodyFrames = SpriteUtil:buildFrames("bottle_animal_hit_"..self.aniIndex.."_%04d", 0, 18)
		local bodyAnimation1 = SpriteUtil:buildAnimate(bodyFrames, kCharacterAnimationTime)
		body:runAction(CCSequence:createWithTwoActions(bodyAnimation1, CCCallFunc:create(onAnimationComplete)))
		anim:addChild(body)
		anim.body = body
		anim:setPosition(ccp(0, 2))
	elseif level == 1 then
		local body = Sprite:createWithSpriteFrameName("bottle_animal_disappear_"..self.aniIndex.."_0000")
		local bodyFrames = SpriteUtil:buildFrames("bottle_animal_disappear_"..self.aniIndex.."_%04d", 0, 12)

		local bodyAnimation = CCSequence:createWithTwoActions(SpriteUtil:buildAnimate(bodyFrames, kCharacterAnimationTime), CCCallFunc:create(onAnimationComplete))
		body:runAction(bodyAnimation)
		anim:addChild(body)
		anim.body = body
		anim:setPosition(ccp(0, 17))
	end
	if self.animal then
		self.animal:removeFromParentAndCleanup(true)
		self.animal = anim
		self:addChildAt(self.animal, TileBottleZIndex.kAniml)
	end
end

function TileBottleBlocker:changeColor(newColor, onFinish)
	self.color = newColor
	self.aniIndex = getIndexByColor(newColor)
	if self.animal and self.animal.body then
		self.animal.body:stopAllActions()
	end
	local function onAnimationComplete()
		self:removeAnimal()
		if onFinish then onFinish() end
	end
	local anim = Sprite:createEmpty()
	anim.body = Sprite:createWithSpriteFrameName("bottle_item_change_"..self.aniIndex.."_0000")
	anim.body:setPosition(ccp(0, -3.5))
	anim:addChild(anim.body)

	local bodyFrames = SpriteUtil:buildFrames("bottle_item_change_"..self.aniIndex.."_%04d", 0, 7)
	local bodyAnimation = SpriteUtil:buildAnimate(bodyFrames, kCharacterAnimationTime)
	anim.body:runAction(CCSequence:createWithTwoActions(bodyAnimation, CCCallFunc:create(onAnimationComplete)))

	self.animal = anim
	self:addChildAt(self.animal, TileBottleZIndex.kAniml)
end