TileRocket = class(CocosObject)

local RocketBodyAdjustColorHSBC = {
	[AnimalTypeConfig.kRed] = {0, 0, 0, 0},
	[AnimalTypeConfig.kBlue] = {-0.754, 0.156, 0.167, 0.215},
	[AnimalTypeConfig.kGreen] = {0.504, 0.216, 0.132, 0.071},
	[AnimalTypeConfig.kPurple] = {-0.45, 0.20, 0, 0.14},
	[AnimalTypeConfig.kYellow] = {0.275, 0.252, 0.371, 0.203},
	[AnimalTypeConfig.kOrange] = {0.240, -0.107, 0.167, 0.287},
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

function TileRocket:ctor()

end

function TileRocket:create(color)
	local rocket = TileRocket.new(CCNode:create())
	rocket:init(color)
	return rocket

end

function TileRocket:init(color)
	local shadow = Sprite:createWithSpriteFrameName("rocket_shadow")
	self:addChild(shadow)
	-- shadow:setPosition(ccp(0,-1.3))
	self.shadow = shadow

	local light = Sprite:createWithSpriteFrameName("rocket_light")
	self:addChild(light)
	self.light = light

	local body = SpriteColorAdjust:createWithSpriteFrameName("rocket_body")
	self:addChild(body)
	self.body = body

	self.color = color
	-- AdjustColor
	local bodyAdjustColor = getColorHSBC(RocketBodyAdjustColorHSBC, color)
	body:adjustColor(bodyAdjustColor[1], bodyAdjustColor[2], bodyAdjustColor[3], bodyAdjustColor[4])
	body:applyAdjustColorShader()

	self:setLightState(false)
end

function TileRocket:setLightState(v)
	if self.shadow then self.shadow:setVisible(not v) end
	if self.light then self.light:setVisible(v) end
end

function TileRocket:buildRocketSmokeAnimation()
	local smokeSprite = Sprite:createWithSpriteFrameName("rocket_fly_smoke_0000")
	local smokeFrames = SpriteUtil:buildFrames("rocket_fly_smoke_%04d", 0, 15)
	local smokeAnimation = SpriteUtil:buildAnimate(smokeFrames, 1/ 30)
	local function onFinished()
		smokeSprite:removeFromParentAndCleanup(true)
	end
	smokeSprite:runAction(CCSequence:createWithTwoActions(smokeAnimation, CCCallFunc:create(onFinished)))
	return smokeSprite
end

function TileRocket:buildRocketFlyAnimation( color )
	local animation = Sprite:createEmpty()

	local fireSprite = Sprite:createWithSpriteFrameName("rocket_fly_fire_0000")
	local fireFrames = SpriteUtil:buildFrames("rocket_fly_fire_%04d", 0, 20)
	local fireAnimation = SpriteUtil:buildAnimate(fireFrames, 1/ 30)
	fireSprite:setPosition(ccp(0, -35))
	local fireSeq = CCArray:create()
	fireSeq:addObject(CCDelayTime:create(7/30))
	fireSeq:addObject(CCRepeat:create(fireAnimation, 99))
	local function onFinished()
		animation:removeFromParentAndCleanup(true)
	end
	fireSeq:addObject(CCCallFunc:create(onFinished))
	fireSprite:runAction(CCSequence:create(fireSeq))
	animation:addChild(fireSprite)

	local rocket = TileRocket:create(color)
	rocket:setLightState(true)
	rocket:setAnchorPoint(ccp(0.5, 0))
	local rocketSeq = CCArray:create()
	rocketSeq:addObject(CCScaleTo:create(5/30, 1.087, 0.893))
	rocketSeq:addObject(CCScaleTo:create(5/30, 1, 1))
	rocket:runAction(CCSequence:create(rocketSeq))
	animation:addChild(rocket)

	return animation
end

function TileRocket:buildRocketExplodeAnimation()
	local explodeSprite = Sprite:createWithSpriteFrameName("rocket_explode_0000")
	local explodeFrames = SpriteUtil:buildFrames("rocket_explode_%04d", 0, 20)
	local explodeAnimation = SpriteUtil:buildAnimate(explodeFrames, 1/ 30)
	local function onFinished()
		explodeSprite:removeFromParentAndCleanup(true)
	end
	explodeSprite:runAction(CCSequence:createWithTwoActions(explodeAnimation, CCCallFunc:create(onFinished)))
	return explodeSprite
end

local kRocketSpeed = 500
function TileRocket:buildRocketAnimation(color, posList, callback)
	assert(posList)
	if #posList < 2 then
		return nil
	else
		local ani = Sprite:createEmpty()

		local smoke = TileRocket:buildRocketSmokeAnimation()
		smoke:setPosition(ccp(0, -35))
		ani:addChild(smoke)

		local rocket = TileRocket:buildRocketFlyAnimation(color)
		ani:addChild(rocket)

		local rocketSeq = CCArray:create()
		rocketSeq:addObject(CCDelayTime:create(0.2))
		local pos1 = posList[1]
		local pos2 = posList[2]
		local pos3 = posList[3]

		local distance1 = ccpDistance(pos2, pos1)
		if distance1 > 0 then
			local moveBy = CCMoveBy:create(distance1/kRocketSpeed, ccp(pos2.x - pos1.x, pos2.y - pos1.y))
			rocketSeq:addObject(CCEaseSineOut:create(moveBy))
		end

		if pos3 then
			local distance2 = ccpDistance(pos3, pos2)
			if distance2 > 0 then -- 是否需要拐弯
				if pos3.x > pos2.x then
					rocketSeq:addObject(CCRotateBy:create(0.2, 90))
				elseif pos3.x < pos2.x then
					rocketSeq:addObject(CCRotateBy:create(0.2, -90))
				end
				local moveBy = CCMoveBy:create(distance2/kRocketSpeed, ccp(pos3.x - pos2.x, pos3.y - pos2.y))
				rocketSeq:addObject(CCEaseSineOut:create(moveBy))
			end
		end

		local function onFinished()
			ani:removeFromParentAndCleanup(true)
			if callback then callback() end
		end
		rocketSeq:addObject(CCCallFunc:create(onFinished))
		rocket:runAction(CCSequence:create(rocketSeq))

		return ani
	end
end