TileCrystalStone = class(CocosObject)

CrystalStongAnimateStates = {
	kNone = 0,
	kEmpty = 1,
	kCharge = 2,
	kFull = 3,
	kWaitingBomb = 4,
}

local CrystalStoneSpriteZOrder = {
	kBody = 0,
	kWater = 10,
	kAirball = 20,
	kFaceCover = 30,
	kEyes = 40,
}

local CrystalStoneBodyHSBC = {
	[AnimalTypeConfig.kRed] = 		{-0.2711, -0.2073, -0.3457, 0.2401},
	[AnimalTypeConfig.kBlue] = 		{0.8712, -0.3273, -0.1166, 0.2952},
	[AnimalTypeConfig.kGreen] = 	{0.3568, -0.4094, -0.0744, 0.5319},
	[AnimalTypeConfig.kPurple] =	{-0.7185, -0.4040, -0.2495, 0.4346},
	[AnimalTypeConfig.kYellow] =	{0.0000, 0.0000, 0.0585, 0.2995},
	[AnimalTypeConfig.kOrange] =	{-0.0312, -0.2344, -0.2927, 0.1223},
}

local CrystalStoneEyesHSBC = {
	[AnimalTypeConfig.kRed] = {-0.2441, 0.4054, -0.1803, 0},
	[AnimalTypeConfig.kBlue] = {0.8259, 0, 0, 0},
	[AnimalTypeConfig.kGreen] = {0.2671, 0, -0.0420, 0},
	[AnimalTypeConfig.kPurple] = {-0.7661, 0.0164, -0.1014, 0},
	[AnimalTypeConfig.kYellow] = {0, 0, 0, 0},
	[AnimalTypeConfig.kOrange] = {-0.1490, -0.2819, -0.2235, 0.0200},
}

local CrystalStoneChargeEffectHSBC = {
	[AnimalTypeConfig.kRed] = {-0.3586, -0.3716, -0.1673, 0.1915},
	[AnimalTypeConfig.kBlue] = {0.7913, 0.0000, 0.0000, 0.0000},
	[AnimalTypeConfig.kGreen] = {0.2639, 0.0002, -0.0236, 0.1082},
	[AnimalTypeConfig.kPurple] = {-0.7661, 0.1320, -0.0474, 0.0358},
	[AnimalTypeConfig.kYellow] = {0, 0, 0, 0},
	[AnimalTypeConfig.kOrange] = {-0.0712, 0.0239, -0.0841, 0.0596},
}

local CrystalStoneWaterHSBC = {
	[AnimalTypeConfig.kRed] = {-0.2073, -0.2289, -0.1014, 0.1655},
	[AnimalTypeConfig.kBlue] = {0.9426, -0.0960, 0.0000, 0.0000},
	[AnimalTypeConfig.kGreen] = {0.3622, 0.0002, 0.0423, 0.1082},
	[AnimalTypeConfig.kPurple] = {-0.6710, 0.1320, -0.0528, 0.0358},
	[AnimalTypeConfig.kYellow] = {0, 0, 0, 0},
	[AnimalTypeConfig.kOrange] = {-0.0052, -0.0528, -0.0906, 0.0596},
}

local CrystalStoneWaterWaveHSBC = {
	[AnimalTypeConfig.kRed] = {-0.2235, -0.0052, -0.3565, -0.1166},
	[AnimalTypeConfig.kBlue] = {0.9750, 0.0000, -0.0582, 0.0000},
	[AnimalTypeConfig.kGreen] = {0.3784, 0.0002, -0.2019, 0.1082},
	[AnimalTypeConfig.kPurple] = {-0.6710, 0.1320, -0.2019, 0.0358},
	[AnimalTypeConfig.kYellow] = {0, 0, 0, 0},
	[AnimalTypeConfig.kOrange] = {-0.0258, 0.0002, -0.3143, -0.3197},
}

local AnimationTimePerFrame = 1 / 30
local AccFrameRate = 1/45
local kUpdateWaterPercentActionTag = 1234
local CrystalStoneColorTypeConfig = {"blue", "green", "orange", "purple", "red", "yellow"}

TileCrystalStoneAnimate = class()

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

function TileCrystalStoneAnimate:_useAdjustColor(sprite, hsbc)
	if sprite and type(hsbc) == "table" and #hsbc == 4 then
		sprite:adjustColor(hsbc[1], hsbc[2], hsbc[3], hsbc[4])
		sprite:applyAdjustColorShader()
	end
end

function TileCrystalStoneAnimate:buildEmptyStone(color)
	local node = Sprite:createEmpty()
	node.body = SpriteColorAdjust:createWithSpriteFrameName( "crystal_stone_empty_body_0000" )
	TileCrystalStoneAnimate:_useAdjustColor(node.body, getColorHSBC(CrystalStoneBodyHSBC, color))

	node.eyes = SpriteColorAdjust:createWithSpriteFrameName("crystal_stone_eyes1_0000" )
	TileCrystalStoneAnimate:_useAdjustColor(node.eyes, getColorHSBC(CrystalStoneEyesHSBC, color))
	local frames = SpriteUtil:buildFrames("crystal_stone_eyes1_%04d", 0, 12)
	local animate = SpriteUtil:buildAnimate(frames, AnimationTimePerFrame)
	local eyesAction = CCRepeatForever:create(CCSequence:createWithTwoActions(CCDelayTime:create(80 * AnimationTimePerFrame), animate))
	node.eyes:runAction(eyesAction)

	node.body:setPosition(ccp(0, -3))
	node.eyes:setPosition(ccp(0, -3))
	
	node:addChildAt(node.body, CrystalStoneSpriteZOrder.kBody)
	node:addChildAt(node.eyes, CrystalStoneSpriteZOrder.kEyes)
	return node
end

function TileCrystalStoneAnimate:buildChargeStone(color)
	local node = Sprite:createEmpty()

	local body = SpriteColorAdjust:createWithSpriteFrameName( "crystal_stone_face_bg" )
	body:setScale(1.05)
	-- TileCrystalStoneAnimate:_useAdjustColor(body, CrystalStoneBodyHSBC[color])
	local faceCover = SpriteColorAdjust:createWithSpriteFrameName( "crystal_stone_body_with_mask" )
	TileCrystalStoneAnimate:_useAdjustColor(faceCover, getColorHSBC(CrystalStoneBodyHSBC, color))
	-- faceCover:setOpacity(255 * 0.3)

	local eyes = SpriteColorAdjust:createWithSpriteFrameName("crystal_stone_eyes1_0000" )
	TileCrystalStoneAnimate:_useAdjustColor(eyes, getColorHSBC(CrystalStoneEyesHSBC, color))
	local frames = SpriteUtil:buildFrames("crystal_stone_eyes1_%04d", 0, 12)
	local animate = SpriteUtil:buildAnimate(frames, AnimationTimePerFrame)
	local eyesAction = CCRepeatForever:create(CCSequence:createWithTwoActions(CCDelayTime:create(80 * AnimationTimePerFrame), animate))
	eyes:runAction(eyesAction)

	local water = TileCrystalStoneAnimate:buildWater(color)

	body:setPosition(ccp(0, -2))
	faceCover:setPosition(ccp(0.6, -4.5))
	eyes:setPosition(ccp(0, -3))
	water:setPosition(ccp(-0.4, -2))

	node.body = body
	node.water = water
	node.faceCover = faceCover
	node.eyes = eyes

	node:addChildAt(body, CrystalStoneSpriteZOrder.kBody)
	node:addChildAt(water, CrystalStoneSpriteZOrder.kWater)
	node:addChildAt(faceCover, CrystalStoneSpriteZOrder.kFaceCover)
	node:addChildAt(eyes, CrystalStoneSpriteZOrder.kEyes)

	return node
end

function TileCrystalStoneAnimate:buildFullStone(color)
	local node = Sprite:createEmpty()
	local body = SpriteColorAdjust:createWithSpriteFrameName( "crystal_stone_full_0000" )
	TileCrystalStoneAnimate:_useAdjustColor(body, getColorHSBC(CrystalStoneBodyHSBC, color))

	local frames = SpriteUtil:buildFrames("crystal_stone_full_%04d", 0, 30)
	local animate = SpriteUtil:buildAnimate(frames, AnimationTimePerFrame)
	body:runAction(CCRepeatForever:create(animate));

	local eyes = SpriteColorAdjust:createWithSpriteFrameName("crystal_stone_eyes2_0000" )
	TileCrystalStoneAnimate:_useAdjustColor(eyes, getColorHSBC(CrystalStoneEyesHSBC, color))

	local eyesFrames = SpriteUtil:buildFrames("crystal_stone_eyes2_%04d", 0, 30)
	local eyesAnimate = SpriteUtil:buildAnimate(eyesFrames, AnimationTimePerFrame)
	local eyesAction = CCRepeatForever:create(eyesAnimate)
	eyes:runAction(eyesAction)

	node.body = body
	node.eyes = eyes

	node:addChildAt(node.body, CrystalStoneSpriteZOrder.kBody)
	node:addChildAt(node.eyes, CrystalStoneSpriteZOrder.kEyes)
	node.eyes:setPositionY(2)

	return node
end

function TileCrystalStoneAnimate:buildWaitingBombStone(color)
	local node = Sprite:createEmpty()

	local body = SpriteColorAdjust:createWithSpriteFrameName( "crystal_stone_disappear_0013" )
	TileCrystalStoneAnimate:_useAdjustColor(body, getColorHSBC(CrystalStoneBodyHSBC, color))

	local frames = SpriteUtil:buildFrames("crystal_stone_disappear_%04d", 13, 8)
	local animate = SpriteUtil:buildAnimate(frames, AnimationTimePerFrame)
	body:runAction(CCRepeatForever:create(animate))
	
	body:setPosition(ccp(0, -2))
	node.body = body
	node:addChildAt(node.body, CrystalStoneSpriteZOrder.kBody)
	return node
end

function TileCrystalStoneAnimate:buildSeletedAnimate( color )
	local node = Sprite:createEmpty()

	local body = SpriteColorAdjust:createWithSpriteFrameName( "crystal_stone_empty_body_0000" )
	TileCrystalStoneAnimate:_useAdjustColor(body, getColorHSBC(CrystalStoneBodyHSBC, color))

	local frames = SpriteUtil:buildFrames("crystal_stone_empty_body_%04d", 0, 21)
	local animate = SpriteUtil:buildAnimate(frames, AnimationTimePerFrame)
	local bodyAction = CCRepeatForever:create(CCSequence:createWithTwoActions(animate, CCDelayTime:create(33 * AnimationTimePerFrame)))
	body:runAction(bodyAction)

	local eyes = SpriteColorAdjust:createWithSpriteFrameName("crystal_stone_eyes1_0000" )
	TileCrystalStoneAnimate:_useAdjustColor(eyes, getColorHSBC(CrystalStoneEyesHSBC, color))

	local frames = SpriteUtil:buildFrames("crystal_stone_eyes1_%04d", 0, 12)
	local animate = SpriteUtil:buildAnimate(frames, AnimationTimePerFrame)
	local eyesAction = CCRepeatForever:create(CCSequence:createWithTwoActions(animate, CCDelayTime:create(42 * AnimationTimePerFrame)))
	eyes:runAction(eyesAction)

	node.body = body
	node.eyes = eyes

	body:setPosition(ccp(0, -3))
	eyes:setPosition(ccp(0, -3))

	node:addChildAt(body, CrystalStoneSpriteZOrder.kBody)
	node:addChildAt(eyes, CrystalStoneSpriteZOrder.kEyes)
	return node
end

function TileCrystalStoneAnimate:buildBgLightAnimate()
	local sprite, animate = SpriteUtil:buildAnimatedSprite(AnimationTimePerFrame, "crystal_stone_bg_light_%04d", 0, 25, false)
	sprite:runAction(CCRepeatForever:create(animate))
	return sprite
end

function TileCrystalStoneAnimate:buildChangeToWaitingBombAnimate(color)
	local node = Sprite:createEmpty()

	local body = SpriteColorAdjust:createWithSpriteFrameName( "crystal_stone_disappear_0000" )
	TileCrystalStoneAnimate:_useAdjustColor(body, getColorHSBC(CrystalStoneBodyHSBC, color))

	local frames = SpriteUtil:buildFrames("crystal_stone_disappear_%04d", 0, 21)
	local animate = SpriteUtil:buildAnimate(frames, AnimationTimePerFrame)
	local function onBodyAnimateFinished(evt)
		body:stopAllActions()
		local waitAnimate = SpriteUtil:buildAnimate(SpriteUtil:buildFrames("crystal_stone_disappear_%04d", 13, 8), AnimationTimePerFrame)
		body:runAction(CCRepeatForever:create(waitAnimate))
	end
	local bodyAction = CCSequence:createWithTwoActions(animate, CCCallFunc:create(onBodyAnimateFinished))
	body:runAction(bodyAction)

	local eyes = SpriteColorAdjust:createWithSpriteFrameName("crystal_stone_eyes3_0000" )
	TileCrystalStoneAnimate:_useAdjustColor(eyes, getColorHSBC(CrystalStoneEyesHSBC, color))

	local eyesFrames = SpriteUtil:buildFrames("crystal_stone_eyes3_%04d", 0, 13)
	local eyesAnimate = SpriteUtil:buildAnimate(eyesFrames, AnimationTimePerFrame)
	local function onEyesAnimateFinished(evt)
		eyes:removeFromParentAndCleanup(true)
	end
	local eyesAction = CCSequence:createWithTwoActions(eyesAnimate, CCCallFunc:create(onEyesAnimateFinished))
	eyes:runAction(eyesAction)

	body:setPosition(ccp(0, -2))
	eyes:setPosition(ccp(0, 0))

	node.body = body
	node.eyes = eyes

	node:addChildAt(node.body, CrystalStoneSpriteZOrder.kBody)
	node:addChildAt(node.eyes, CrystalStoneSpriteZOrder.kEyes)
	return node
end

function TileCrystalStoneAnimate:buildWaitAndDisappearAnimate(color, callback)
	local node = Sprite:createEmpty()

	local body = SpriteColorAdjust:createWithSpriteFrameName( "crystal_stone_disappear_0000" )
	TileCrystalStoneAnimate:_useAdjustColor(body, getColorHSBC(CrystalStoneBodyHSBC, color))

	local frames = SpriteUtil:buildFrames("crystal_stone_disappear_%04d", 0, 27)
	local animate = SpriteUtil:buildAnimate(frames, AccFrameRate)
	local function onBodyAnimateFinished(evt)
		node:removeFromParentAndCleanup(true)
		if callback then callback() end
	end
	local bodyAction = CCSequence:createWithTwoActions(animate, CCCallFunc:create(onBodyAnimateFinished))
	body:runAction(bodyAction)

	local eyes = SpriteColorAdjust:createWithSpriteFrameName("crystal_stone_eyes3_0000" )
	TileCrystalStoneAnimate:_useAdjustColor(eyes, getColorHSBC(CrystalStoneEyesHSBC, color))

	local eyesFrames = SpriteUtil:buildFrames("crystal_stone_eyes3_%04d", 0, 13)
	local eyesAnimate = SpriteUtil:buildAnimate(eyesFrames, AccFrameRate)
	local function onEyesAnimateFinished(evt)
		eyes:removeFromParentAndCleanup(true)
	end
	local eyesAction = CCSequence:createWithTwoActions(eyesAnimate, CCCallFunc:create(onEyesAnimateFinished))
	eyes:runAction(eyesAction)

	body:setPosition(ccp(0, -2))
	eyes:setPosition(ccp(0, 0))

	node.body = body
	node.eyes = eyes

	node:addChildAt(node.body, CrystalStoneSpriteZOrder.kBody)
	node:addChildAt(node.eyes, CrystalStoneSpriteZOrder.kEyes)
	return node
end

function TileCrystalStoneAnimate:buildOnlyDisappearAnimate(color, callback)
	local node = Sprite:createEmpty()
	local body = SpriteColorAdjust:createWithSpriteFrameName( "crystal_stone_disappear_0013" )
	TileCrystalStoneAnimate:_useAdjustColor(body, getColorHSBC(CrystalStoneBodyHSBC, color))

	local frames = SpriteUtil:buildFrames("crystal_stone_disappear_%04d", 13, 14)
	local animate = SpriteUtil:buildAnimate(frames, AnimationTimePerFrame)
	local function onBodyAnimateFinished(evt)
		node:removeFromParentAndCleanup(true)
		if callback then callback() end
	end
	local bodyAction = CCSequence:createWithTwoActions(animate, CCCallFunc:create(onBodyAnimateFinished))
	body:runAction(bodyAction)
	body:setPosition(ccp(0, -2))
	node.body = body

	node:addChildAt(node.body, CrystalStoneSpriteZOrder.kBody)
	return node
end

function TileCrystalStoneAnimate:buildChargeEffect(color)
	local node = SpriteColorAdjust:createWithSpriteFrameName( "crystal_stone_charge_effect" )
	TileCrystalStoneAnimate:_useAdjustColor(node, getColorHSBC(CrystalStoneChargeEffectHSBC, color))

	node.play = function()
		node:setVisible(true)
		node:stopAllActions()
		node:setScale(1)
		node:setOpacity(255)

		local actionSeq = CCArray:create()
		actionSeq:addObject(CCScaleBy:create(7 * AnimationTimePerFrame, 1.11))
		actionSeq:addObject(CCSpawn:createWithTwoActions(CCScaleBy:create(7 * AnimationTimePerFrame, 1.16), CCFadeTo:create(7 * AnimationTimePerFrame, 255 * 0.1)))
		actionSeq:addObject(CCCallFunc:create(function() node:setVisible(false) end))

		node:runAction(CCSequence:create(actionSeq))
	end

	node.stop = function()
		node:stopAllActions()
		node:setVisible(false)
	end

	node.stop()
	return node
end

function TileCrystalStoneAnimate:_buildExplodeEffectLight()
	local node = Sprite:createEmpty()
	local sprite = Sprite:createWithSpriteFrameName("crystal_stone_effect_light1")
	sprite:setScale( 0.6)
	local actionSeq = CCArray:create()
	actionSeq:addObject(CCSpawn:createWithTwoActions(CCScaleBy:create(14 * AnimationTimePerFrame, 5/12), CCMoveBy:create(14 * AnimationTimePerFrame, ccp(0, 35))))
	actionSeq:addObject(CCFadeTo:create(AnimationTimePerFrame, 0))
	sprite:runAction(CCSequence:create(actionSeq))
	sprite:setPosition(ccp(0, 40))

	node:addChild(sprite)
	node:setTexture(sprite.refCocosObj:getTexture())
	return node
end

function TileCrystalStoneAnimate:_buildFlyStar()
	local sprite = Sprite:createWithSpriteFrameName("crystal_stone_fly_star")
	sprite:runAction(CCRepeatForever:create(CCRotateBy:create(20*AnimationTimePerFrame, 79.8)))
	return sprite
end

function TileCrystalStoneAnimate:buildFlyEffect(color)
	local node = Sprite:createEmpty()

	local colorIndex = AnimalTypeConfig.convertColorTypeToIndex(color)
	if not colorIndex then colorIndex = 1 end
	local colorType = CrystalStoneColorTypeConfig[colorIndex]

	local flySprite = SpriteColorAdjust:createWithSpriteFrameName("crystal_stone_fly_light_"..tostring(colorType))
	flySprite:setAnchorPoint(ccp(1, 0.5))
	flySprite:ignoreAnchorPointForPosition(false)
	flySprite:setPosition(ccp(0, -2.2))
	flySprite:setScale(1/24, 1)

	local starDelay = {1, 1, 3, 2, 4, 4, 5, 6, 8}
	local starScale = {0.629, 1, 0.629, 0.629, 1, 0.629, 0.81, 1, 0.81}
	local starPosition = {ccp(122.7, -0.85), ccp(125.6, 16.65), ccp(145, 12.45), ccp(182.2, 10.25), ccp(201.1, -0.3), ccp(219.35, 14.8), ccp(271.2, -0.6), ccp(285.4, 12.4), ccp(325.35, 12.7)}

	local stars = Sprite:createEmpty()
	local posOffset = starPosition[1]
	for i = 1, #starPosition do
		local scale = starScale[i] or 1
		local delay = starDelay[i] or 0
		local position = starPosition[i]
		local function addStar()
			local star = TileCrystalStoneAnimate:_buildFlyStar()
			star:setScale(scale*1.077*0.5)
			star:setPosition(ccp(position.x-posOffset.x, position.y-posOffset.y-7))
			star:runAction(CCSpawn:createWithTwoActions(CCScaleBy:create(13*AnimationTimePerFrame, 0.31), CCFadeTo:create(13*AnimationTimePerFrame, 25.5)))
			stars:addChild(star)
		end
		stars:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(delay*AnimationTimePerFrame), CCCallFunc:create(addStar)))
	end
	stars:setPosition(ccp(-40, 0))
	stars:runAction(CCEaseSineOut:create(CCMoveBy:create(20*AnimationTimePerFrame, ccp(-190, 0))))

	local act1 = CCScaleTo:create(10*AnimationTimePerFrame, 1, 1)
	local actionSeq = CCArray:create()
	actionSeq:addObject(act1)
	actionSeq:addObject(CCScaleTo:create(7*AnimationTimePerFrame, 2/24, 1))
	flySprite:runAction(CCSequence:create(actionSeq))
	node:addChild(flySprite)
	node:addChild(stars)

	node:setTexture(flySprite.refCocosObj:getTexture())
	return node
end

function TileCrystalStoneAnimate:buildChangeColorAnimate(color, deltaPos, callback)
	if not color or not deltaPos then 
		if callback then callback() end
		return
	end

	local animate = Sprite:createEmpty()

	local function onAnimateFinished()
		animate:removeFromParentAndCleanup(true)
		if callback then callback() end
	end

	local flyAnimate = TileCrystalStoneAnimate:buildFlyEffect(color)
	flyAnimate:setRotation(angleFromPoint(ccp(0, 0), deltaPos))
	local scale = math.sqrt(deltaPos.x*deltaPos.x+deltaPos.y*deltaPos.y) / 280
	if scale > 1 then scale = 1 end
	flyAnimate:setScaleX(scale * 0.9)

	local function onFlyAnimateFinished()
		flyAnimate:removeFromParentAndCleanup(true)
		local explode = TileCrystalStoneAnimate:_buildFlyExplodeAnimate(onAnimateFinished)
		explode:setPosition(deltaPos)
		animate:addChild(explode)
	end

	local flySeq = CCArray:create()
	flySeq:addObject(CCMoveBy:create(14*AnimationTimePerFrame, deltaPos))
	flySeq:addObject(CCCallFunc:create(onFlyAnimateFinished))
	flyAnimate:runAction(CCSequence:create(flySeq))

	animate:addChild(flyAnimate)

	animate:setTexture(flyAnimate.refCocosObj:getTexture())
	return animate
end

function TileCrystalStoneAnimate:buildAddEnergyAnimate(color, deltaPos, callback)
	local animate = Sprite:createEmpty()
	local distanceScale = math.sqrt(deltaPos.x*deltaPos.x+deltaPos.y*deltaPos.y) / 200
	local timeScale = 1
	if distanceScale < 1 then
		timeScale = math.max(distanceScale, 0.5)
	end

	local actionLeft = 0
	local function onAnimateFinished()
		actionLeft = actionLeft - 1
		if actionLeft <= 0 then
			animate:removeFromParentAndCleanup(true)
			if callback then callback() end
		end
	end

	local positions = {ccp(0, 0), ccp(25, 2), ccp(50, 1), ccp(75, -2), ccp(100, 1)}
	local scales = {1, 0.668, 0.794, 0.668, 0.794}
	local delays = {0, 3, 7, 12, 15}
	local moveDistance = {50, 50, 50, 70, 85}

	local colorIndex = AnimalTypeConfig.convertColorTypeToIndex(color)
	if not colorIndex then colorIndex = 1 end
	local colorType = CrystalStoneColorTypeConfig[colorIndex]
	local spriteName = "crystal_stone_energy_light_"..tostring(colorType)

	for i = 1, #positions do
		local pos = positions[i]
		local scale = scales[i] or 1
		local delay = delays[i] or 0
		local move = moveDistance[i] or 0

		local light = Sprite:createWithSpriteFrameName(spriteName)
		light:setPosition(ccp(pos.x*distanceScale, pos.y))
		light:setScale(scale*0.8)
		light:setOpacity(0)
		local actSeq = CCArray:create()
		actSeq:addObject(CCDelayTime:create(delay*AnimationTimePerFrame*timeScale))
		actSeq:addObject(CCFadeTo:create(AnimationTimePerFrame*timeScale, 255))
		actSeq:addObject(CCSpawn:createWithTwoActions(CCFadeTo:create(18*AnimationTimePerFrame*timeScale, 25.5), CCMoveBy:create(18*AnimationTimePerFrame*timeScale, ccp(move*distanceScale, 0))))
		local function onFinishCallback()
			light:removeFromParentAndCleanup(true)
			onAnimateFinished()
		end
		actSeq:addObject(CCCallFunc:create(onFinishCallback))
		light:runAction(CCSequence:create(actSeq))
		animate:addChild(light)
		actionLeft = actionLeft + 1
	end

	local light = Sprite:createWithSpriteFrameName(spriteName)
	light:setScale(1.3)
	local function onFinishCallback()
		light:removeFromParentAndCleanup(true)
		onAnimateFinished()
	end
	local actSeq = CCArray:create()
	actSeq:addObject(CCSpawn:createWithTwoActions(CCMoveBy:create(25*AnimationTimePerFrame*timeScale, ccp(200*distanceScale, 0)), CCScaleBy:create(25*AnimationTimePerFrame*timeScale, 121.3/202.9)))
	actSeq:addObject(CCCallFunc:create(onFinishCallback))
	light:runAction(CCSequence:create(actSeq))
	animate:addChild(light)
	actionLeft = actionLeft + 1

	animate:setTexture(light.refCocosObj:getTexture())
	animate:setRotation(angleFromPoint(ccp(0, 0), deltaPos))
	return animate
end

function TileCrystalStoneAnimate:_buildFlyExplodeAnimate(callback)
	local sprite = Sprite:createWithSpriteFrameName("crystal_stone_white_point")
	sprite:setScale(9/56)
	sprite:setOpacity(255*0.7)
	local function onAnimateFinished()
		if callback then callback() end
	end

	local actSeq = CCArray:create()
	actSeq:addObject(CCSpawn:createWithTwoActions(CCFadeTo:create(7*AnimationTimePerFrame, 0), CCScaleTo:create(7*AnimationTimePerFrame, 1)))
	actSeq:addObject(CCCallFunc:create(onAnimateFinished))

	sprite:runAction(CCSequence:create(actSeq))
	return sprite
end

function TileCrystalStoneAnimate:_buildWaterBall(color, scale, delayTime)
	delayTime = delayTime or 0
	scale = scale or 1
	local ball = SpriteColorAdjust:createWithSpriteFrameName("crystal_stone_water_ball")
	TileCrystalStoneAnimate:_useAdjustColor(ball, getColorHSBC(CrystalStoneBodyHSBC, color))
	ball:setOpacity(0)
	ball:setScale(scale/3)

	local dx1, dy1 = 0*scale, 8*scale
	local dx2, dy2 = -2.8*scale, 25.5*scale

	local function resetBall()
		local curPos = ball:getPosition()
		ball:setPosition(ccp(curPos.x-dx1-dx2, curPos.y-dy1-dy2))
		ball:setOpacity(0)
	end

	local function runBallAnimate()
		local ballSeq = CCArray:create()
		local act1 = CCSpawn:createWithTwoActions(CCFadeTo:create(8*AnimationTimePerFrame, 255), CCMoveBy:create(8*AnimationTimePerFrame, ccp(dx1, dy1)))
		ballSeq:addObject(act1)
		ballSeq:addObject(CCMoveBy:create(22*AnimationTimePerFrame, ccp(dx2, dy2)))
		ballSeq:addObject(CCCallFunc:create(resetBall))
		local ballAnimate = CCRepeatForever:create(CCSequence:create(ballSeq))
		ball:runAction(ballAnimate)
	end
	ball:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(delayTime), CCCallFunc:create(runBallAnimate)))
	return ball
end

function TileCrystalStoneAnimate:buildWater(color)
	local node = Sprite:createEmpty()

	local waterClippingNode = SimpleClippingNode:create()
	node:addChild(waterClippingNode)
	waterClippingNode:setAnchorPoint(ccp(0.5, 0))
	waterClippingNode:ignoreAnchorPointForPosition(false)
	waterClippingNode:setRecalcPosition(true)

	local waterSprite = SpriteColorAdjust:createWithSpriteFrameName( "crystal_stone_water" )
	local waterSize = waterSprite:getGroupBounds().size
	local waterH = waterSize.height
	local clippingW = waterSize.width
	local clippingH = waterSize.height+2
	waterSprite:setPosition(ccp(clippingW/2 + 0.5, clippingH/2 - 3))

	TileCrystalStoneAnimate:_useAdjustColor(waterSprite, getColorHSBC(CrystalStoneWaterHSBC, color))
	waterClippingNode:addChild(waterSprite)

	waterClippingNode:setContentSize(CCSizeMake(clippingW, 0))
	waterClippingNode:setPosition(ccp(0, -clippingH/2))

	local ballDelay = {25, 10, 15, 0, 0, 0}
	local ballScale = {1, 4.1/6.15, 1, 4.1/6.15, 3.1/6.15, 1}
	for i=1,#ballDelay do
		local delay = ballDelay[i] or 0
		local scale = ballScale[i] or 1
		local ball = TileCrystalStoneAnimate:_buildWaterBall(color, scale, delay*AnimationTimePerFrame)
		ball:setPosition(ccp(clippingW/2 + 5 * (i-3.5), clippingH/2-10))
		waterClippingNode:addChild(ball)
	end


	-- Wave
	local waveClippingNode = SimpleClippingNode:create()
	node:addChild(waveClippingNode)
	
	waveClippingNode:setAnchorPoint(ccp(0.5, 0))
	waveClippingNode:ignoreAnchorPointForPosition(false)
	waveClippingNode:setContentSize(CCSizeMake(clippingW, clippingH))
	waveClippingNode:setPosition(ccp(-1, -clippingH/2))
	waveClippingNode:setRecalcPosition(true)

	local waveSprite = SpriteColorAdjust:createWithSpriteFrameName( "crystal_stone_water_wave" )
	TileCrystalStoneAnimate:_useAdjustColor(waveSprite, getColorHSBC(CrystalStoneWaterWaveHSBC, color))
	waveSprite:setPosition(ccp(clippingW/2-31, 10))
	local waveSeq = CCArray:create()
	waveSeq:addObject(CCCallFunc:create(function() waveSprite:setPositionX(clippingW/2-31) end))
	waveSeq:addObject(CCMoveBy:create(40*AnimationTimePerFrame, ccp(56, 0)))
	waveSprite:runAction(CCRepeatForever:create(CCSequence:create(waveSeq)))
	waveClippingNode:addChild(waveSprite)

    local function calcWaveClippingWidth(height)
        local r = clippingH / 2
        local a = r - height
        local width = 0
        if a >= -r and a <= r then
            width = math.sqrt(r * r - a * a) * 2
        end
        return width * 1.3
    end 

	node.updateWaterPercentTo = function(percent, hasAnimate)
		percent = percent or 0
		if percent > 1 then percent = 1 end
		-- 调整波浪的位置
		local targetPosY = waterH*percent+1
		local targetHeight = waterH*percent+1
		node:unscheduleUpdate()
		if not hasAnimate then
			waterClippingNode:setContentSize(CCSizeMake(clippingW, targetHeight))
			waveSprite:setPositionY(targetPosY)
			waveClippingNode:setContentSize(CCSizeMake(calcWaveClippingWidth(targetPosY), clippingH))
			if percent <= 0 or percent >= 1 then
				waveSprite:setVisible(false)
			else
				waveSprite:setVisible(true)
			end
		else
			waveSprite:setVisible(true)
			local totalTime = 0
			local animateTime = 5 * AnimationTimePerFrame
			local oriHeight = waterClippingNode:getContentSize().height
			local oriWavePosY = waveSprite:getPosition().y

			local function onAnimateFinished()
				if percent <= 0 or percent >= 1 then
					waveSprite:setVisible(false)
				else
					waveSprite:setVisible(true)
				end
			end

			local function updateFunc(dt)
				totalTime = totalTime + dt
				local posY = 0
				local contentHeight = 0
				local finished = false
				if totalTime >= animateTime then
					posY = targetPosY
					contentHeight = targetHeight
					finished = true
				else
					posY = oriWavePosY + totalTime / animateTime * (targetPosY - oriWavePosY)
					contentHeight = oriHeight + totalTime / animateTime * (targetHeight - oriHeight)
				end
				waterClippingNode:setContentSize(CCSizeMake(clippingW, contentHeight+1))
				local wavePos = waveSprite:getPosition()
				waveSprite:setPosition(ccp(wavePos.x, posY))
				waveClippingNode:setContentSize(CCSizeMake(calcWaveClippingWidth(posY), clippingH))

				if finished then
					node:unscheduleUpdate()
					onAnimateFinished()
				end
			end
			node:scheduleUpdateWithPriority(updateFunc, 0)
		end
	end

	node.updateWaterPercentTo(0)

	return node
end

function TileCrystalStoneAnimate:buildExplodeEffect(onFinishCallback)
	local node = Sprite:createEmpty()

	local circle1 = Sprite:createWithSpriteFrameName("crystal_stone_effect_circle1")
	local circle2 = Sprite:createWithSpriteFrameName("crystal_stone_effect_circle2")
	local circle3 = Sprite:createWithSpriteFrameName("crystal_stone_effect_circle3")
	node:addChild(circle3)
	node:addChild(circle2)
	node:addChild(circle1)
	node:setTexture(circle1.refCocosObj:getTexture())

	local function onAnimateFinished()
		node:removeFromParentAndCleanup(true)
		if onFinishCallback then onFinishCallback() end
	end

	local function addCircle3()
		local circle2Scale = 1/3.6
		circle1:setOpacity(0)
		circle3:setOpacity(0)
		circle2:setOpacity(255)
		circle2:setScale(circle2Scale)
		local circle3Seq = CCArray:create()
		circle3Seq:addObject(CCScaleTo:create(7*AccFrameRate, 761/206*circle2Scale))
		circle3Seq:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(7*AccFrameRate, 1316/206*circle2Scale), CCFadeTo:create(7*AccFrameRate, 25.5)))
		circle3Seq:addObject(CCCallFunc:create(onAnimateFinished))
		circle2:runAction(CCSequence:create(circle3Seq))

		for i = 1, 8 do
			local effectLight = TileCrystalStoneAnimate:_buildExplodeEffectLight()
			effectLight:setRotation(45*i+math.random(1000, 1300) / 100) -- 45*i(+-)10~13
			effectLight:setScale(math.random(90, 100)/100) -- scale 0.90 ~ 1.00
			node:addChild(effectLight)
		end
	end

	circle1:setScale(1/2.06)
	circle1:setOpacity(255 * 0.1)
	local circle1Seq = CCArray:create()
	circle1Seq:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(3*AccFrameRate, 1), CCFadeTo:create(3*AccFrameRate, 255)))
	local circle1_1_1 = CCSpawn:createWithTwoActions(CCScaleTo:create(2*AccFrameRate, 0.9), CCFadeTo:create(2*AccFrameRate, 0))
	local circle1_1_2 = CCSpawn:createWithTwoActions(CCScaleTo:create(2*AccFrameRate, 1), CCFadeTo:create(2*AccFrameRate, 255))
	local circle1_1 = CCSequence:createWithTwoActions(circle1_1_1, circle1_1_2)
	circle1Seq:addObject(CCRepeat:create(circle1_1, 4))
	circle1Seq:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(2*AccFrameRate, 0.9), CCFadeTo:create(2*AccFrameRate, 0)))
	circle1Seq:addObject(CCFadeTo:create(AccFrameRate, 255))
	circle1Seq:addObject(CCScaleTo:create(5*AccFrameRate, 1))
	circle1Seq:addObject(CCCallFunc:create(addCircle3))
	circle1:runAction(CCSequence:create(circle1Seq))

	circle2:setOpacity(0)
	circle2:setScale(1/4)

	circle3:setOpacity(0)
	circle3:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(3*AccFrameRate), CCFadeTo:create(AccFrameRate, 255 * 0.5)))

	return node
end

------------------------------------------------
-- TileCrystalStone
------------------------------------------------

function TileCrystalStone:ctor()
	self.energy = 0
	self.color = 0
	self.animateState = CrystalStongAnimateStates.kNone
end

function TileCrystalStone:create(color, energyPercent, bombType)
	local node = TileCrystalStone.new(CCNode:create())
	node:init(color, energyPercent, bombType)
	return node
end

function TileCrystalStone:init(color, energyPercent, bombType)
	self.energyPercent = energyPercent or 0
	self.color = color

	self.bgLight = TileCrystalStoneAnimate:buildBgLightAnimate()
	self.bgLight:setPosition(ccp(0, -2))
	self:addChild(self.bgLight)

	if bombType == GameItemCrystalStoneBombType.kSpecial then
		self:initWaitingBombStone()
	else
		if energyPercent <= 0 then
			self:initEmptyStone()
		elseif energyPercent >= 1 then
			self:initFullStone()
		else
			self:initChargeStone(energyPercent)
		end
	end

	if __WIN32 and StartupConfig:getInstance():isLocalDevelopMode() and not _G.disable_item_debug_info then
		self:addDebugInfo()
	end
end

function TileCrystalStone:initEmptyStone()
	if self.stone then self.stone:removeFromParentAndCleanup(true) self.stone = nil end
	if self.chargeAnimate then self.chargeAnimate:removeFromParentAndCleanup(true) self.chargeAnimate = nil end
	if self.bgLight then self.bgLight:setVisible(false) end

	self.stone = TileCrystalStoneAnimate:buildEmptyStone(self.color)
	self:addChild(self.stone)

	self.animateState = CrystalStongAnimateStates.kEmpty
end

function TileCrystalStone:initChargeStone(energyPercent)
	if self.stone then self.stone:removeFromParentAndCleanup(true) self.stone = nil end
	if self.bgLight then self.bgLight:setVisible(true) end

	self.stone = TileCrystalStoneAnimate:buildChargeStone(self.color)
	self:addChild(self.stone)

	if self.chargeAnimate then
		self.chargeAnimate.stop()
	else
		self.chargeAnimate = TileCrystalStoneAnimate:buildChargeEffect(self.color)
		self:addChild(self.chargeAnimate)
		self.chargeAnimate:setPositionX(-1)
	end

	energyPercent = energyPercent or 0
	self.stone.water.updateWaterPercentTo(energyPercent)

	self.animateState = CrystalStongAnimateStates.kCharge
end

function TileCrystalStone:initFullStone()
	if self.stone then self.stone:removeFromParentAndCleanup(true) self.stone = nil end
	if self.chargeAnimate then self.chargeAnimate:removeFromParentAndCleanup(true) self.chargeAnimate = nil end
	if self.bgLight then self.bgLight:setVisible(true) end

	self.stone = TileCrystalStoneAnimate:buildFullStone(self.color)
	self:addChild(self.stone)

	self.animateState = CrystalStongAnimateStates.kFull

	self.musicTimerId = TimerUtil.addAlarm( function ()
			if not self.isDisposed and self:getParent() then
				GamePlayMusicPlayer:playEffect( GameMusicType.kPlayCrystalActive )
			else
				self:stopSound()
			end
		 end , 20 , 0 )
	
end

function TileCrystalStone:stopSound()
	if self.musicTimerId then
		TimerUtil.removeAlarm( self.musicTimerId )
		self.musicTimerId = nil
	end
end

function TileCrystalStone:initWaitingBombStone()
	if self.stone then self.stone:removeFromParentAndCleanup(true) self.stone = nil end
	if self.chargeAnimate then self.chargeAnimate:removeFromParentAndCleanup(true) self.chargeAnimate = nil end
	if self.bgLight then self.bgLight:setVisible(true) end

	self.stone = TileCrystalStoneAnimate:buildWaitingBombStone(self.color)
	self:addChild(self.stone)

	self.animateState = CrystalStongAnimateStates.kWaitingBomb
end

function TileCrystalStone:playSelectedAnimate()
	if self.animateState == CrystalStongAnimateStates.kEmpty and not self.seletedAnimate then
		if self.stone then self.stone:setVisible(false) end
		self.seletedAnimate = TileCrystalStoneAnimate:buildSeletedAnimate(self.color)
		self:addChild(self.seletedAnimate)
	end
end

function TileCrystalStone:hideStoneAnimate()
	if self.stone then
		self.stone:setVisible(false)
	end
end

function TileCrystalStone:stopSelectedAnimate()
	if self.seletedAnimate then 
		self.seletedAnimate:removeFromParentAndCleanup(true) 
		self.seletedAnimate = nil
		if self.stone then self.stone:setVisible(true) end
	end
end

function TileCrystalStone:updateEnergyPercent(energyPercent, withAnimate)
	if self.animateState == CrystalStongAnimateStates.kEmpty then
		self:initChargeStone()
	end

	if energyPercent then
		if energyPercent > 1 then energyPercent = 1 end

		if energyPercent > self.energyPercent then
			self.energyPercent = energyPercent

			if self.stone and self.stone.water then
				self.stone.water.updateWaterPercentTo(energyPercent, withAnimate)
			end
		end
	end

	self:updateEnergy()
end

function TileCrystalStone:playChargeEffect()
	if self.chargeAnimate then 
		self.chargeAnimate.play()
	end
end

function TileCrystalStone:playChangeToWaitingBomb()
	if self.stone then self.stone:removeFromParentAndCleanup(true) self.stone = nil end
	if self.chargeAnimate then self.chargeAnimate:removeFromParentAndCleanup(true) self.chargeAnimate = nil end
	if self.bgLight then self.bgLight:setVisible(true) end

	self.stone = TileCrystalStoneAnimate:buildChangeToWaitingBombAnimate(self.color)
	self:addChild(self.stone)

	self.animateState = CrystalStongAnimateStates.kWaitingBomb
end

function TileCrystalStone:playDisappearAnimate(callback)
	if self.stone then self.stone:removeFromParentAndCleanup(true) self.stone = nil end
	if self.chargeAnimate then self.chargeAnimate:removeFromParentAndCleanup(true) self.chargeAnimate = nil end
	if self.bgLight then self.bgLight:setVisible(true) end

	if self.animateState == CrystalStongAnimateStates.kWaitingBomb then
		self.stone = TileCrystalStoneAnimate:buildOnlyDisappearAnimate(self.color, callback)
		self:addChild(self.stone)
	else
		self.stone = TileCrystalStoneAnimate:buildWaitAndDisappearAnimate(self.color, callback)
		self:addChild(self.stone)
	end
	self:stopSound()
end

function TileCrystalStone:playChargeAnimate(energyPercent)
	if self.animateState == CrystalStongAnimateStates.kEmpty then
		self:initChargeStone()
	end

	if self.animateState ~= CrystalStongAnimateStates.kCharge then return end

	if energyPercent and energyPercent > self.energyPercent and self.energyPercent < 1 then
		if energyPercent > 1 then energyPercent = 1 end
		self.energyPercent = energyPercent

		if self.stone and self.stone.water then
			self.stone.water.updateWaterPercentTo(energyPercent, true)
		end
	end

	if self.chargeAnimate then 
		self.chargeAnimate.play()
	end

	self:updateEnergy()
end

function TileCrystalStone:addDebugInfo()
	local progressBar = LayerColor:create()
	progressBar:setColor(ccc3(250, 250, 250))
	progressBar:changeWidthAndHeight(60, 5)
	progressBar:setPosition(ccp(-30, -35))
	progressBar:setOpacity(200)

	local p = LayerColor:create()
	p:setColor(ccc3(255, 0, 0))
	p:changeWidthAndHeight(60, 5)
	progressBar:addChild(p)
	self:addChildAt(progressBar, 999)

	local label = TextField:create("", nil, 20)
	label:setColor(ccc3(255, 255, 255))
	label:setPosition(ccp(30, 0))
	progressBar:addChild(label)

	self.updateDebugInfo = function()
		local percent = self.energyPercent
		if percent > 1 then percent = 1 end
		if p and not p.isDisposed then p:setScaleX(percent) end
		if label and not label.isDisposed then label:setString(tostring(self.energyPercent*GamePlayConfig_CrystalStone_Energy)) end
	end
	self.updateDebugInfo()
end

function TileCrystalStone:updateEnergy()
	-- debug
	if self.updateDebugInfo then self.updateDebugInfo() end
end

function TileCrystalStone:updateState(state, energyPercent)
	if state == CrystalStongAnimateStates.kEmpty then
		self:initEmptyStone()
	elseif state == CrystalStongAnimateStates.kCharge then
		energyPercent = energyPercent or 0
		self:initChargeStone(energyPercent)
	elseif state == CrystalStongAnimateStates.kFull then
		self:initFullStone()
	elseif state == CrystalStongAnimateStates.kWaitingBomb then
		self:initWaitingBombStone()
	end
end
