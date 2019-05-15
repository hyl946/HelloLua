-----------------------------------------------------------------
-- 2015-03-27 dan.liang
-- wiki: http://wiki.happyelements.net/pages/viewpage.action?pageId=18547354
-----------------------------------------------------------------
TileMagicStone = class(Sprite)

TileMagicStoneConst = table.const {
	kInitLevel = 0,
	kMaxLevel = 2
}

local AnimationFPS = 30
local SpriteZIndex = {
	kShadow = 0,
	kStone 	= 1,
	kCover	= 9,
}

local EffectPos_Up = {
	{x = 0, y = -2},
	{x = 0, y = -1},
	{x = -1, y = -1},
	{x = -1, y = 0},
	{x = -2, y = 0},
	{x = -1, y = 1},
	{x = 0, y = 1},
	{x = 0, y = 2}
}

local stoneOffset = {
	{x=0, y=2},
	{x=0, y=0},
	{x=0.8, y=0.5},
}

function TileMagicStone:create(level, dir)
	local tile = TileMagicStone.new(CCSprite:create())
	tile:init(level, dir)
	tile:idle()
	return tile
end

function TileMagicStone:init(level, dir)
	level = level or TileMagicStoneConst.kInitLevel
	if level > TileMagicStoneConst.kMaxLevel then level = TileMagicStoneConst.kMaxLevel end

	self.level = level
	self.direction = dir
	self.rotation = 90 * (dir - 1)

	self.stoneSpriteContainer = Sprite:createEmpty()
	self.stoneSpriteContainer:setAnchorPoint(ccp(0.5, 0.5))
	self.stoneSpriteContainer:setRotation(self.rotation)
	self:addChildAt(self.stoneSpriteContainer, SpriteZIndex.kStone)

	local shadow = Sprite:createWithSpriteFrameName("stone_shadow")
	shadow:setPosition(ccp(2, -2))
	shadow:setRotation(self.rotation)
	self:addChildAt(shadow, SpriteZIndex.kShadow)

	self:updateStoneSprite()
end

-- 坐标旋转(一次90度) inPos : IntCoord
function TileMagicStone:convertPosByRotationTimes(inPositions, rTimes)
	local outPositions = {}
	for _, inPos in pairs(inPositions) do
		local outPos = nil
		rTimes = rTimes % 4
		if rTimes == 0 then 
			outPos = IntCoord:create(inPos.x, inPos.y)
		else
			local sin, cos = 0, 0
			if rTimes == 1 then -- 90度
				sin, cos = 1, 0
			elseif rTimes == 2 then -- 180度
				sin, cos = 0, -1
			else -- 270度
				sin, cos = -1, 0
			end
			local outPosX = inPos.x * cos + inPos.y * sin
			local outPosY = inPos.y * cos - inPos.x * sin
			outPos = IntCoord:create(outPosX, outPosY)
		end
		table.insert(outPositions, outPos)
	end
	return outPositions
end

function TileMagicStone:calcEffectPositions(dir)
	local rTimes = dir - MagicStoneDirConfig.kUp
	return TileMagicStone:convertPosByRotationTimes(EffectPos_Up, rTimes)
end

function TileMagicStone:updateStoneSprite()
	if self.stoneSprite and not self.stoneSprite.isDisposed then
		self.stoneSprite:removeFromParentAndCleanup(true)
	end

	local stoneSprite = self:createStoneWithLevel(self.level)
	self.stoneSpriteContainer:addChild(stoneSprite)

	local posOffset = stoneOffset[self.level+1]
	if posOffset then
		stoneSprite:setPosition(ccp(posOffset.x, posOffset.y))
	end

	self.stoneSprite = stoneSprite
end

function TileMagicStone:removeStoneSprite()
	if self.stoneSprite and not self.stoneSprite.isDisposed then
		self.stoneSprite:removeFromParentAndCleanup(true)
	end
	self.stoneSprite = nil
end

function TileMagicStone:createStoneWithLevel(level)
	if level == TileMagicStoneConst.kMaxLevel then
		local stoneFrame = string.format("stone%d_idle_0000", level)
		local sprite = Sprite:createWithSpriteFrameName(stoneFrame)
		return sprite
	else
		local stoneFrame = string.format("stone%d_active_0000", level)
		local sprite = Sprite:createWithSpriteFrameName(stoneFrame)
		return sprite
	end
end

function TileMagicStone:idle()
	if self.isDisposed then return end

	local level = self.level or TileMagicStoneConst.kInitLevel
	if level == 2 and self.stoneSprite and not self.stoneSprite.isDisposed then
		local frames1 = SpriteUtil:buildFrames("stone"..level.."_idle_%04d", 0, 15) -- 1~15
		local animate1 = SpriteUtil:buildAnimate(frames1, 1/24)

		local frames2 = SpriteUtil:buildFrames("stone"..level.."_idle_%04d", 0, 14, true) -- 14~0
		local animate2 = SpriteUtil:buildAnimate(frames2, 1/24)

		local sequence = CCArray:create()
		sequence:addObject(CCDelayTime:create(0.7))
		sequence:addObject(animate1)
		sequence:addObject(animate2)
		sequence:addObject(CCDelayTime:create(1))
		local action = CCRepeatForever:create(CCSequence:create(sequence))

		self.stoneSprite:runAction(action)
	end
end

function TileMagicStone:buildFlySpriteAnim(targetPos, onAnimFinish)
	local flySprite = Sprite:createWithSpriteFrameName("stone_active_fly_0000")
	local flyFrames = SpriteUtil:buildFrames("stone_active_fly_%04d", 0, 9)
	local flyAnim = SpriteUtil:buildAnimate(flyFrames, 1/AnimationFPS)
	flySprite:runAction(CCRepeatForever:create(flyAnim))

	flySprite:setAnchorPoint(ccp(0.5, 0.5))
	flySprite:ignoreAnchorPointForPosition(false)

	local flyX, flyY = -3, 3
	if targetPos.x > 0 then flyY = -10 elseif targetPos.x < 0 then flyY = 10 end
	if targetPos.y > 0 then flyX = 10 elseif targetPos.y < 0 then flyX = -10 end
	flySprite:setPosition(ccp(flyX, flyY))
	flySprite:setScaleX(0.86)
	flySprite:setScaleY(1.08)
	-- flySprite:setScaleX(1)
	-- flySprite:setScaleY(1.25)
	local dr, dc = targetPos.x, targetPos.y
	local rotation = 0
	if dc == 0 then
		rotation = 90
	elseif dr == 0 and dc > 0 then
		rotation = 180
	else
		rotation = math.atan(dr / dc) * 59.72 -- 180 / 3.14
		if rotation < 0 then rotation = 180 + rotation end
	end
	flySprite:setRotation(rotation)
	if rotation >= 90 then
		flySprite:setFlipY(true)
	end

	local sequence = CCArray:create()

	if dr == 0 or dc == 0 then
		local moveBy = CCMoveBy:create(16 / AnimationFPS, ccp(dc * 70, -dr * 70))
		-- sequence:addObject(CCDelayTime:create(5 / AnimationFPS))
		sequence:addObject(moveBy)
		-- local scaleTo = CCScaleTo:create(9 / AnimationFPS, 0.46, 0.47)
		local scaleTo = CCScaleTo:create(8 / AnimationFPS, 0.49, 0.50)
		sequence:addObject(scaleTo)
	else
		local moveBy = CCMoveBy:create(13 / AnimationFPS, ccp(dc * 70, -dr * 70))
		local scaleTo = CCScaleTo:create(6 / AnimationFPS, 0.49, 0.50)
		sequence:addObject(moveBy)
		sequence:addObject(scaleTo)
	end

	local function flyAnimCompleted()
		if flySprite and not flySprite.isDisposed then
			flySprite:removeFromParentAndCleanup(true)
		end
		if onAnimFinish then onAnimFinish() end
	end
	sequence:addObject(CCCallFunc:create(flyAnimCompleted))
	flySprite:runAction(CCSequence:create(sequence))
	return flySprite
end

function TileMagicStone:createActiveAnim(texture, level, direction, onAnimFinish, targetPos)
	if level > TileMagicStoneConst.kMaxLevel then level = TileMagicStoneConst.kMaxLevel end

	local animSprite = Sprite:createEmpty()
	if texture then
		animSprite:setTexture(texture)
	end

	local stoneSprite = TileMagicStone:createStoneWithLevel(level)
	animSprite:addChildAt(stoneSprite, SpriteZIndex.kStone)
	animSprite.stoneSprite = stoneSprite
	local posOffset = stoneOffset[level+1]
	if posOffset then
		stoneSprite:setPosition(ccp(posOffset.x, posOffset.y))
	end

	local function onAnimFinishCallback()
		if animSprite and not animSprite.isDisposed then
			animSprite:removeFromParentAndCleanup(true)
		end
		if onAnimFinish then onAnimFinish() end
	end

	local fps = 24

	if level == 0 then
		local anim = SpriteUtil:buildAnimate(SpriteUtil:buildFrames("stone0_active_%04d", 0, 29), 1/fps)
		local actions = CCSequence:createWithTwoActions(anim, CCCallFunc:create(onAnimFinishCallback))
		stoneSprite:runAction(actions)
	elseif level == 1 then
		local anim = SpriteUtil:buildAnimate(SpriteUtil:buildFrames("stone1_active_%04d", 0, 14), 1/fps)
		local actions = CCSequence:createWithTwoActions(anim, CCCallFunc:create(onAnimFinishCallback))
		stoneSprite:runAction(actions)
	elseif level == 2 then
		stoneSprite:setScale(0.98)
		stoneSprite:setPosition(ccp(-0.2, -0.3))
		local animCD = 0
		local function onAnimCountDown()
			animCD = animCD - 1
			if animCD < 1 then
				onAnimFinishCallback()
			end
		end

		local anim1 = SpriteUtil:buildAnimate(SpriteUtil:buildFrames("stone2_active_%04d", 0, 12), 1/fps)
		local anim2 = SpriteUtil:buildAnimate(SpriteUtil:buildFrames("stone2_active_%04d", 12, 14), 1/fps)
		local anim3 = SpriteUtil:buildAnimate(SpriteUtil:buildFrames("stone2_active_%04d", 12, 14, true), 1/fps)
		local function onStoneAnimationFinish()
			onAnimCountDown()
		end
		local animArr = CCArray:create()
		animArr:addObject(anim1)
		animArr:addObject(anim2)
		animArr:addObject(anim3)
		animArr:addObject(CCCallFunc:create(onStoneAnimationFinish))
		stoneSprite:runAction(CCSequence:create(animArr))
		animCD = animCD + 1

		if targetPos and #targetPos > 0 then
			local targetPosByUp = nil
			if direction == MagicStoneDirConfig.kUp then
				targetPosByUp = targetPos
			else
				targetPosByUp = TileMagicStone:convertPosByRotationTimes(targetPos, 5 - direction)
			end
			local level = 0
			for _, v in pairs(targetPosByUp) do
				local flySprite = TileMagicStone:buildFlySpriteAnim(v, function() onAnimCountDown() end)
				level = level + 1
				animSprite:addChildAt(flySprite, SpriteZIndex.kCover + level)
				animCD = animCD + 1
			end
		end
	end
	animSprite:setRotation(90 * (direction - 1))
	return animSprite
end
