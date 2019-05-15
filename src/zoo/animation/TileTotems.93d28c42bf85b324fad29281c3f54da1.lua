TileTotems = class(CocosObject)

local BodyAdjustColorHSBC = {
	[AnimalTypeConfig.kBlue] 	= {-0.9044, 0.0358, 0.1331, 0.1796},
	[AnimalTypeConfig.kGreen] 	= {0.5697, 0.3514, 0.1385, 0.0585},
	[AnimalTypeConfig.kOrange] 	= {0.1655, -0.1598, 0.1018, 0.0715},
	[AnimalTypeConfig.kPurple] 	= {-0.4840, -0.0852, 0.0693, 0.1385},
	[AnimalTypeConfig.kRed] 	= {0.0272, 0.0000, 0.0002, 0.0000},
	[AnimalTypeConfig.kYellow] 	= {0.2714, 0.6929, 0.4584, 0.1018},
}

local EyesAdjustColorHSBC = {
	[AnimalTypeConfig.kBlue] = {-0.8266, 0.0358, 0.1201, 0.1796},
	[AnimalTypeConfig.kGreen] = {0.5276, 0.2639, 0.1082, 0.1677},
	[AnimalTypeConfig.kOrange] = {0.1353, -0.1501, 0.0153, 0.0899},
	[AnimalTypeConfig.kPurple] = {-0.5391, -0.1555, 0.0239, 0.2401},
	[AnimalTypeConfig.kRed] = {0, 0, 0, 0},
	[AnimalTypeConfig.kYellow] = {0.2639, 0.3601, 0.1677, 0.2282},
}

local function getColorHSBC(hbscMap, colorType)
	assert(type(hbscMap) == "table")

	if hbscMap then
		for color, hbsc in pairs(hbscMap) do
			if color == colorType then
				return hbsc
			end
		end
	end
	assert(false, "missed hbsc for color:"..table.tostring(colorType))
	return nil
end

local function _useAdjustColor(sprite, hsbc)
	if sprite and type(hsbc) == "table" and #hsbc == 4 then
		sprite:adjustColor(hsbc[1], hsbc[2], hsbc[3], hsbc[4])
		sprite:applyAdjustColorShader()
	end
end

local AnimationFrameTime = 1 / 30
local kTotemsAnimateActionTag = 1234

TileTotemsAnimation = class()

function TileTotemsAnimation:createNormalTotems(colorType)
	local node = Sprite:createEmpty()

	local body = SpriteColorAdjust:createWithSpriteFrameName("totems_body_0000")
	_useAdjustColor(body, getColorHSBC(BodyAdjustColorHSBC, colorType))

	local eyes = SpriteColorAdjust:createWithSpriteFrameName("totems_eyes_0000")
	_useAdjustColor(eyes, getColorHSBC(EyesAdjustColorHSBC, colorType))

	local face = SpriteColorAdjust:createWithSpriteFrameName("totems_face_0000")
	_useAdjustColor(face, getColorHSBC(BodyAdjustColorHSBC, colorType))

	local mouth = Sprite:createWithSpriteFrameName("totems_mouth_0000")

	node.body = body
	node.eyes = eyes
	node.face = face
	node.mouth = mouth
	-- 设置偏移位置
	node.body:setPosition(ccp(0, -2))
	node.eyes:setPosition(ccp(0, -2))
	node.face:setPosition(ccp(0, -2))
	node.mouth:setPosition(ccp(0, -2))

	node:addChild(body)
	node:addChild(eyes)
	node:addChild(face)
	node:addChild(mouth)

	node._playIdleAnimation = function(self)
		self:_stopIdleAnimation()

		local bodyAnimate = SpriteUtil:buildAnimate(SpriteUtil:buildFrames("totems_body_%04d", 0, 14), AnimationFrameTime)
		local eyesAnimate = SpriteUtil:buildAnimate(SpriteUtil:buildFrames("totems_eyes_%04d", 0, 14), AnimationFrameTime)
		local faceAnimate = SpriteUtil:buildAnimate(SpriteUtil:buildFrames("totems_face_%04d", 0, 14), AnimationFrameTime)
		local mouthAnimate = SpriteUtil:buildAnimate(SpriteUtil:buildFrames("totems_mouth_%04d", 0, 14), AnimationFrameTime)
		
		if self.body then self.body:runAction(bodyAnimate) end
		if self.eyes then self.eyes:runAction(eyesAnimate) end
		if self.face then self.face:runAction(faceAnimate) end
		if self.mouth then self.mouth:runAction(mouthAnimate) end
	end

	node._stopIdleAnimation = function(self)
		if self.body then self.body:stopAllActions() end
		if self.eyes then self.eyes:stopAllActions() end
		if self.face then self.face:stopAllActions() end
		if self.mouth then self.mouth:stopAllActions() end
	end

	node.playIdleAnimate = function(self)
		self:stopActionByTag(kTotemsAnimateActionTag)

		local animate = CCSequence:createWithTwoActions(CCDelayTime:create(10), CCCallFunc:create(function() self:_playIdleAnimation() end))
		local action = CCRepeatForever:create(animate)
		action:setTag(kTotemsAnimateActionTag)
		self:runAction(action)
	end

	node.playSelectedAnimate = function(self)
		self:stopActionByTag(kTotemsAnimateActionTag)

		local animate = CCSequence:createWithTwoActions(CCCallFunc:create(function() self:_playIdleAnimation() end), CCDelayTime:create(3))
		local action = CCRepeatForever:create(animate)
		action:setTag(kTotemsAnimateActionTag)
		self:runAction(action)
	end
	return node
end

function TileTotemsAnimation:createSuperTotemsBgLight()
	local totemsBg = Sprite:createWithSpriteFrameName("super_totems_bg_light_0000")
	local totemsBgAnimate = SpriteUtil:buildAnimate(SpriteUtil:buildFrames("super_totems_bg_light_%04d", 0, 20), AnimationFrameTime)
	totemsBg:runAction(CCRepeatForever:create(totemsBgAnimate))
	return totemsBg
end

function TileTotemsAnimation:createSuperTotems()
	local superTotems = Sprite:createWithSpriteFrameName("super_totems_idle_0000")
	local animate = SpriteUtil:buildAnimate(SpriteUtil:buildFrames("super_totems_idle_%04d", 0, 20), AnimationFrameTime)

	superTotems.playIdleAnimate = function(self)
		self:stopActionByTag(kTotemsAnimateActionTag)
		local action = CCRepeatForever:create(CCSequence:createWithTwoActions(animate, CCDelayTime:create(10)))
		action:setTag(kTotemsAnimateActionTag)
		self:runAction(action)
	end
	return superTotems
end

function TileTotemsAnimation:createTileLight()
	local node = Sprite:createEmpty()

	local sprite = Sprite:createWithSpriteFrameName("totems_effect_tile_light_0000")
	local spriteAnimate = SpriteUtil:buildAnimate(SpriteUtil:buildFrames("totems_effect_tile_light_%04d", 0, 5), AnimationFrameTime*2)
	sprite:runAction(CCRepeatForever:create(spriteAnimate))
	sprite:setPosition(ccp(0, -1))

	node:addChild(sprite)
	return node
end

function TileTotemsAnimation:buildTotemsChangeAnimate(colorType, callback)
	local animate = Sprite:createEmpty()

	local sprite1 = SpriteColorAdjust:createWithSpriteFrameName("change_animate_a_0000")
	local bodyHsbc = getColorHSBC(BodyAdjustColorHSBC, colorType)
	_useAdjustColor(sprite1, bodyHsbc)
	local sprite1Animate = SpriteUtil:buildAnimate(SpriteUtil:buildFrames("change_animate_a_%04d", 0, 10), AnimationFrameTime)
	local function removeSprite1()
		sprite1:removeFromParentAndCleanup(true)
	end
	local action1 = CCSequence:createWithTwoActions(sprite1Animate, CCCallFunc:create(removeSprite1))
	local function addAnimate2()
		local sprite2 = Sprite:createWithSpriteFrameName("change_animate_b_0000")
		local action3 = SpriteUtil:buildAnimate(SpriteUtil:buildFrames("change_animate_b_%04d", 0, 10), AnimationFrameTime)
		local function onAnimationFinish()
			animate:removeFromParentAndCleanup(true)
			if callback then callback() end
		end
		sprite2:runAction(CCSequence:createWithTwoActions(action3, CCCallFunc:create(onAnimationFinish)))
		sprite2:setPosition(ccp(0, 2))
		animate:addChild(sprite2)
	end
	local action2 = CCSequence:createWithTwoActions(CCDelayTime:create(AnimationFrameTime*6), CCCallFunc:create(addAnimate2))
	sprite1:runAction(CCSpawn:createWithTwoActions(action1, action2))

	sprite1:setPosition(ccp(0, -3))
	animate:addChild(sprite1)

	return animate
end

function TileTotemsAnimation:buildTotemsWattingExplodeAnimate()
	local animate = Sprite:createEmpty()

	local totems = Sprite:createWithSpriteFrameName("super_totems_watting_explode_0000")
	local action = SpriteUtil:buildAnimate(SpriteUtil:buildFrames("super_totems_watting_explode_%04d", 0, 2), AnimationFrameTime)
	totems:runAction(CCRepeatForever:create(action))

	animate:addChild(totems)

	local coverCircle = Sprite:createWithSpriteFrameName("super_totems_cover_light_0000")
	local action2 = SpriteUtil:buildAnimate(SpriteUtil:buildFrames("super_totems_cover_light_%04d", 0, 20), AnimationFrameTime)
	local function coverCircleAnimateFinish( ... )
		coverCircle:removeFromParentAndCleanup(true)
	end
	coverCircle:runAction(CCSequence:createWithTwoActions(action2, CCCallFunc:create(coverCircleAnimateFinish)))
	coverCircle:setPosition(ccp(0, -4))
	animate:addChild(coverCircle)

	return animate
end

local TotemsExplodeLightningLength = 800
local TotemsExplodeLightningScaleY = 1
local TotemsExplodeLightningSpeed = 3000
local TotemsExplodeLightningMaxTime = AnimationFrameTime*8
local TotemsExplodeLightningMinTime = AnimationFrameTime*3
function TileTotemsAnimation:buildTotemsExplodeLightning(startPos, endPos)
	local animate = Sprite:createEmpty()

	local lightning = Sprite:createWithSpriteFrameName("totems_link_light_0000")
	local action1 = SpriteUtil:buildAnimate(SpriteUtil:buildFrames("totems_link_light_%04d", 0, 5), AnimationFrameTime)
	local action2 = SpriteUtil:buildAnimate(SpriteUtil:buildFrames("totems_link_light_%04d", 0, 5), AnimationFrameTime, true)
	lightning:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(action1, action2)))

	lightning:setFlipX(true)
	lightning:setAnchorPoint(ccp(0, 0.5))
	lightning:ignoreAnchorPointForPosition(false)
	lightning:setScaleY(TotemsExplodeLightningScaleY)
	lightning:setScaleX(0.1)
	if startPos and endPos then
		animate:setPosition(ccp(startPos.x, startPos.y))
		animate:setRotation(angleFromPoint(startPos, endPos))

		local distance = ccpDistance(startPos, endPos) 
		local time = distance / TotemsExplodeLightningSpeed
		if time > TotemsExplodeLightningMaxTime then time = TotemsExplodeLightningMaxTime end
		if time < TotemsExplodeLightningMinTime then time = TotemsExplodeLightningMinTime end
		local scaleX = distance / TotemsExplodeLightningLength
		lightning:runAction(CCScaleTo:create(time, scaleX, TotemsExplodeLightningScaleY))
	end
	animate:addChild(lightning)

	return animate
end

-------------------------------------
-- TileTotems
-------------------------------------
function TileTotems:ctor()

end

function TileTotems:create(colorType, isActived)
	local node = TileTotems.new(CCNode:create())
	node:init(colorType, isActived)
	return node
end

function TileTotems:init(colorType, isActived)
	self.colorType = colorType
	self.isActived = isActived
	if isActived then
		self:initSuperTotems()
	else
		self:initNormalTotems(colorType)
	end
end

function TileTotems:initNormalTotems(colorType)
	local totems = TileTotemsAnimation:createNormalTotems(colorType)
	self.totems = totems
	self:addChild(totems)
	self.totems:playIdleAnimate()
end

function TileTotems:initSuperTotems()
	local totemsBg = TileTotemsAnimation:createSuperTotemsBgLight()
	self:addChild(totemsBg)

	local totems = TileTotemsAnimation:createSuperTotems()
	totems:setPosition(ccp(0, 2))
	self.totems = totems
	self:addChild(totems)
	self.totems:playIdleAnimate()
end

function TileTotems:playChangeAnimate( callback )
	if self.colorType and not self.isActived then
		if self.totems then 
			self.totems:removeFromParentAndCleanup(true)
			self.totems = nil 
		end
		local function onChangeFinished()
			self:initSuperTotems()
			if callback then callback() end
		end
		local changeAnimate = TileTotemsAnimation:buildTotemsChangeAnimate(self.colorType, onChangeFinished)
		self:addChild(changeAnimate)
		self.isActived = true
	end
end

function TileTotems:playSelectedAnimate()
	if not self.isActived and self.totems then
		self.totems:playSelectedAnimate()
	end
end

function TileTotems:stopSelectedAnimate()
	if not self.isActived and self.totems then
		self.totems:playIdleAnimate()
	end
end

function TileTotems:hideTotems()
	if self.totems then
		self.totems:setVisible(false)
	end
end