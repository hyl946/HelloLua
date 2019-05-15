TileRabbit = class(CocosObject)

local kCharacterAnimationTime = 1/30
kColorOrangeConfig = {-0.4, 0.3147, 0.1255, 0.3957}
function TileRabbit:create(color, level)
	local node = TileRabbit.new(CCNode:create()) 
	node.color = color or AnimalTypeConfig.kBlue
	node.level = level or 1
	node:init()
	node.name = "TileBlocker"
	return node
end

function TileRabbit:init()
	
	self.body =  Sprite:createWithSpriteFrameName("rabbit_click_body_0000")
	
	if self.color == AnimalTypeConfig.kYellow then
		self.eye = SpriteColorAdjust:createWithSpriteFrameName("rabbit_click_eye_yellow_0000")
		self:changeColorEyes(self.eye)
	else
		self.eye = SpriteColorAdjust:createWithSpriteFrameName("rabbit_click_eye_0000")
		self:changeColorEyes(self.eye)
	end
	self.scarf = SpriteColorAdjust:createWithSpriteFrameName("rabbit_click_scarf_0000")
	self:changeColorScarf(self.scarf)
	self.levelShow = Sprite:createWithSpriteFrameName("rabbit_level_show")
	self.levelShow:setPosition(ccp(-GamePlayConfig_Tile_Width/4, -20))

	self:addChild(self.body)
	self:addChild(self.eye)
	self:addChild(self.scarf)
	self:addChild(self.levelShow)

	self:playNormalAnimation()
end

function TileRabbit:playNormalAnimation(callback)

	self.body:stopAllActions()
	self.eye:stopAllActions()
	self.scarf:stopAllActions()
	self.body:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("rabbit_click_body_0000"))

	local eye_name = self.color == AnimalTypeConfig.kYellow and "rabbit_click_eye_yellow_0000" or "rabbit_click_eye_0000"
	self.eye:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(eye_name))
	self.scarf:setDisplayFrame(CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("rabbit_click_scarf_0000"))
	if self.eye_heart then self.eye_heart:removeFromParentAndCleanup(true) self.eye_heart = nil end
	if self.bodyExt then self.bodyExt:removeFromParentAndCleanup(true) self.bodyExt = nil end
	self.eye:setVisible(true)
	self:setInitPosition()
	if self.level > 1 then 
		self.levelShow:setVisible(true)
	else
		self.levelShow:setVisible(false)
	end
end

function TileRabbit:setInitPosition()
	self.body:setAnchorPoint(ccp(0.5, 0.5))
	self.eye:setAnchorPoint(ccp(0.5, 0.6))
	self.scarf:setAnchorPoint(ccp(0.47, 1.5))
end

function TileRabbit:playUpAnimation(callback, isFromNest)
	self:playNormalAnimation()
	local function animationCallback( ... )
		-- body
		self:playNormalAnimation()
		if callback then callback() end
	end
	local function createAnimation(sprite, animation_name, finishCallback)
		local frames = SpriteUtil:buildFrames("rabbit_up_"..animation_name .. "_%04d", 0, 30)
		local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
		sprite:play(animate, 0, 1, finishCallback)
	end
	createAnimation(self.body, "body")
	self.body:setAnchorPoint(ccp(0.5, 0.45))

	local eye_name = self.color == AnimalTypeConfig.kYellow and "eye_yellow" or "eye"
	createAnimation(self.eye, eye_name)
	self.eye:setAnchorPoint(ccp(0.5, 0.35))

	createAnimation(self.scarf, "scarf", animationCallback)
	self.scarf:setAnchorPoint(ccp(0.48, 0.7))

	local arr = CCArray:create()
	arr:addObject(CCDelayTime:create(0.5))
	arr:addObject(CCMoveBy:create(0.1, ccp(0, 20)))
	arr:addObject(CCMoveBy:create(0.1, ccp(0, -20)))
	self.levelShow:runAction(CCSequence:create(arr))

	if isFromNest then 
		self.bodyExt= Sprite:createWithSpriteFrameName("rabbit_up_body_ext_0000")
		self:addChildAt(self.bodyExt, 0)
		createAnimation(self.bodyExt, "body_ext")
		self.bodyExt:setAnchorPoint(ccp(0.5, 0.95))

		local jump_arr = CCArray:create()
		jump_arr:addObject(CCDelayTime:create(0.33))
		jump_arr:addObject(CCMoveBy:create(0.17, ccp(0, 20)))
		jump_arr:addObject(CCMoveBy:create(0.1, ccp(0, -20)))
		self:runAction(CCSequence:create(jump_arr))
	end
end


function TileRabbit:playDestroyAnimation(callback)
	local function animationCallback()
		local time = 0.5
		local action_move = CCMoveBy:create(time, ccp(0, -500))--CCEaseSineIn:create(CCMoveBy:create(time, ccp(0, -500))) 
		local action_fadeOut = CCFadeOut:create(time)
		local action_callFunc = CCCallFunc:create(callback)
		local action_spawn = CCSpawn:createWithTwoActions(action_move, action_fadeOut)
		self:stopAllActions()
		self:runAction(CCSequence:createWithTwoActions(action_spawn, action_callFunc))
	end
	self.levelShow:setVisible(false)
	self:playRunAnimation(animationCallback, true)
	self:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.5), CCMoveBy:create(0.5, ccp(0, 50))))
end

function TileRabbit:playRunAnimation(callback, isDestroy)
	local function animationCallback( ... )
		-- body
		if callback then callback() end
	end

	local function createAnimation(sprite, animation_name, finishCallback)
		local frameCount = isDestroy and 13 or 20
		local startIndex = isDestroy and 14 or 0
		local frames = SpriteUtil:buildFrames("rabbit_run_"..animation_name .. "_%04d", startIndex, frameCount)
		local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
		sprite:play(animate, 0, 1, finishCallback)
	end
	self:playNormalAnimation()
	createAnimation(self.body, "body")
	self.body:setAnchorPoint(ccp(0.5, 0.2))

	local eye_name = self.color == AnimalTypeConfig.kYellow and "eye_yellow" or "eye"
	createAnimation(self.eye, eye_name)
	self.eye:setAnchorPoint(ccp(0.5, 0.1))

	createAnimation(self.scarf, "scarf", animationCallback)
	self.scarf:setAnchorPoint(ccp(0.47, 0.22))

end

function TileRabbit:playSelectedAnimate(isDangerous, callback)
	local function animationCallback( ... )
		-- body
		if callback then callback() end
	end

	local function createAnimation(sprite, animation_name, finishCallback)
		local frames = SpriteUtil:buildFrames("rabbit_"..animation_name .. "_%04d", 0, 28)
		local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
		if isDangerous then
			sprite:play(animate)
		else
			sprite:play(animate, 0, 1, finishCallback)
		end
	end

	self:playNormalAnimation()

	createAnimation(self.body, "click_body")
	self.body:setAnchorPoint(ccp(0.5, 0.5))

	if isDangerous then 
		if self.eye_heart then 
			self.eye_heart:removeFromParentAndCleanup(true)
			self.eye_heart = nil
		end
		self.eye_heart = Sprite:createWithSpriteFrameName("rabbit_scare_eye_0000")
		self.eye_heart:setAnchorPoint(ccp(0.5, 0.5))
		createAnimation(self.eye_heart, "scare_eye")
		self:addChild(self.eye_heart)
		self.eye_heart:setVisible(true)
		self.eye:setVisible(false)
	else
		local eye_name = self.color == AnimalTypeConfig.kYellow and "click_eye_yellow" or "click_eye"
		createAnimation(self.eye, eye_name)
		self.eye:setAnchorPoint(ccp(0.5, 0.6))
	end

	-- local eye_name = isDangerous and "scare_eye" or "click_eye"
	-- createAnimation(self.eye, eye_name)
	-- self.eye:setAnchorPoint(isDangerous and ccp(0.5, 0.5) or ccp(0.5, 0.6))

	createAnimation(self.scarf, "click_scarf", animationCallback)
	self.scarf:setAnchorPoint(ccp(0.47, 1.5))
end


function TileRabbit:changeColorScarf(spriteColorAdjust)
	local value = "";
	local color = self.color
	if color == AnimalTypeConfig.kBlue then value = {0,0,0,0}
	elseif color == AnimalTypeConfig.kGreen then value = {-0.598, 0.108, 0.059, 1}	
	elseif color == AnimalTypeConfig.kOrange then value = {1, -0.64, 0.035, 1}	
	elseif color == AnimalTypeConfig.kPurple then value = {0.407, 0.024, -0.131, 0.167}
	elseif color == AnimalTypeConfig.kRed then value = {0.923, 0, -0.15, 0.25}
	elseif color == AnimalTypeConfig.kYellow then value = {-0.874, 0.179, 0.275, 1}
	else
		if _G.isLocalDevelopMode then printx(0, "not find the color, the color is :", self.color) end
	end
	spriteColorAdjust:adjustColor(value[1],value[2],value[3],value[4])
	spriteColorAdjust:applyAdjustColorShader()
end

function TileRabbit:changeColorEyes(spriteColorAdjust)
	local value = "";
	local color = self.color
	if color == AnimalTypeConfig.kBlue then value = {0,0,0,0}
	elseif color == AnimalTypeConfig.kGreen then value = {-0.598, 0.108, 0.059, 1}	
	elseif color == AnimalTypeConfig.kOrange then value = {1, -0.335, 0, 0.1}	
	elseif color == AnimalTypeConfig.kPurple then value = {0.407, 0.024, -0.084, 0.167}
	elseif color == AnimalTypeConfig.kRed then value = {0.923, 0.047, -0.071, 0.26}
	elseif color == AnimalTypeConfig.kYellow then value = {0,0,0,0}
	else
		if _G.isLocalDevelopMode then printx(0, "not find the color, the color is :", self.color) end
	end
	spriteColorAdjust:adjustColor(value[1],value[2],value[3],value[4])
	spriteColorAdjust:applyAdjustColorShader()
end

function TileRabbit:playInDangerAnimation( ... )
	self:playSelectedAnimate(true)
end

function TileRabbit:stopInDangerAnimation()
	self:playNormalAnimation()
end
