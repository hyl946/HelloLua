
UFOAnimation = class(CocosObject)
UFOType = table.const{
	kNormal = 1, 
	kRabbit = 2, 
}
UFOStatus = {
	kNormal = 1, -- 正常状态
	kWakeUp = 2, -- 解除眩晕状态
	kStun	= 3, -- 眩晕中
}
local kCharacterAnimationTime = 1/30
local UFOAnimationType = {kFlyInto = 1, kReflyInto = 2, kPull = 3, kFlyOut = 4, kHitByRocket = 5, kRecover = 6}
local BASE_SCALE = 1.1
local kUFOHoverActionTag = 1110
local function createUFOBody( ... )
	-- body
	local sprite = Sprite:createWithSpriteFrameName("UFO_body_0000")
	local frame = SpriteUtil:buildFrames("UFO_body_%04d", 0, 8)
	local animate = SpriteUtil:buildAnimate(frame, kCharacterAnimationTime)
  	sprite:play(animate)
  	return sprite
end

local function createLightning( ... )
	-- body
	local container = Sprite:createEmpty()
	local index = -1
	for k = 1, 2 do 
		local sprite = Sprite:createWithSpriteFrameName("UFO_lightning_0000")
		local frame = SpriteUtil:buildFrames("UFO_lightning_%04d", 0, 10)
		local animate = SpriteUtil:buildAnimate(frame, kCharacterAnimationTime)
	  	sprite:play(animate)
	  	index = index * -1
	  	sprite:setPosition(ccp(index *  30, 0))
	  	sprite:setVisible(false)
	  	if k == 2 then sprite:setRotation(180) end
	  	local function changeVisible( ... )
	  		-- body
	  		sprite:setVisible(not sprite:isVisible())
	  	end 
	  	local action = CCRepeatForever:create(CCSequence:createWithTwoActions(CCDelayTime:create(k), CCCallFunc:create(changeVisible)))
	  	sprite:runAction(action)
	  	container:addChild(sprite)
	end

	local function callback( ... )
		-- body
		if container then container:removeFromParentAndCleanup(true) end
	end 

  	return container
end

local function addHoverEffect( sprite )
	-- body
	if sprite then
		-- sprite:stopAllActions()
		local time = 1 
		local action_move_up = CCMoveBy:create(time/2, ccp(0, 10))
		local action_move_down = CCMoveBy:create(time/2, ccp(0, -10))
		local action = CCRepeatForever:create(CCSequence:createWithTwoActions(action_move_up, action_move_down))
		sprite:runAction(action)
	end 
end

function UFOAnimation:create( ufoType, ufoStatus )
	-- body
	local node = UFOAnimation.new(CCNode:create())
	node.name = "UFO"

	-- node.body = createUFOBody()
	node.body = self:createActiveUFO()
	node:addChild(node.body)
	
	node.ufoType = ufoType or UFOType.kNormal
	node.stayPositionInBoard = nil

	ufoStatus = ufoStatus or UFOStatus.kNormal
 	node:forceUpdateUFOStatus(ufoStatus)
 
	node.currentAnimation = nil
	return node
end

function UFOAnimation:createActiveUFO()
	local sprite = Sprite:createWithSpriteFrameName("ufo_active_0000")
	local frame = SpriteUtil:buildFrames("ufo_active_%04d", 0, 10)
	local animate = SpriteUtil:buildAnimate(frame, kCharacterAnimationTime)
	sprite:setScale(BASE_SCALE)
  	sprite:play(animate)
  	return sprite
end

function UFOAnimation:createInactiveUFO()
	local ufoBody = Sprite:createWithSpriteFrameName("ufo_inactive_0000")
	local frame = SpriteUtil:buildFrames("ufo_inactive_%04d", 0, 10)
	local animate = SpriteUtil:buildAnimate(frame, kCharacterAnimationTime)
	ufoBody:setScale(BASE_SCALE)
  	ufoBody:play(animate)
  	return ufoBody
end

function UFOAnimation:createStunCircle()
	local stunCircle = Sprite:createWithSpriteFrameName("ufo_stun_circle_0000")
	local stunFrames = SpriteUtil:buildFrames("ufo_stun_circle_%04d", 0, 40)
	local stunAnimate = SpriteUtil:buildAnimate(stunFrames, kCharacterAnimationTime)
  	stunCircle:play(stunAnimate)
  	stunCircle:setRotation(-9.5)
	stunCircle:setScale(BASE_SCALE)
	stunCircle:setPosition(ccp(-17, 7))
  	return stunCircle
end

function UFOAnimation:setStayPositionInBoard(pos)
	self.stayPositionInBoard = pos
end

function UFOAnimation:getStayPositionInBoard()
	return self.stayPositionInBoard
end

function UFOAnimation:forceUpdateUFOStatus(ufoStatus)
	assert(type(ufoStatus) == "number", "but get "..type(ufoStatus))
	self.ufoStatus = ufoStatus
	if self.ufoStatus == UFOStatus.kNormal then
		self:setUFONormal()
	elseif self.ufoStatus == UFOStatus.kWakeUp then
		self:setUFOWakeUp()
	elseif self.ufoStatus == UFOStatus.kStun then
		self:setUFOStun()
	end
end

function UFOAnimation:setUFONormal()
	self:stopUFOAnimations()
	if self.body then self.body:removeFromParentAndCleanup(true) end
	if self.stun then self.stun:removeFromParentAndCleanup(true) end

	local body = self:createActiveUFO()
	self.body = body
	self:addChild(self.body)
	-- 上下浮动
	self:playUFOHoverEffect()
end

function UFOAnimation:setUFOWakeUp()
	self:setUFOStun()
	self.stun:setOpacity(0)
end

function UFOAnimation:setUFOStun()
	self:stopUFOAnimations()
	if self.body then self.body:removeFromParentAndCleanup(true) end
	if self.stun then self.stun:removeFromParentAndCleanup(true) end

	local stun = self:createStunCircle()
	self.stun = stun
	self:addChild(self.stun)

	local body = self:createInactiveUFO()
	self.body = body
	self.body:setPosition(ccp(-5, -25))
	self.body:setRotation(-7.3)
	self:addChild(self.body)
end

function UFOAnimation:playHitByRocket(callback)
	if self.currentAnimation == UFOAnimationType.kHitByRocket then
		if callback then callback() end
	else
		self.currentAnimation = UFOAnimationType.kHitByRocket
		local function onFinished()
			self.currentAnimation = nil
			if callback then callback() end
		end
		if self.ufoStatus == UFOStatus.kNormal then
			self:playUFONormalOnHit(onFinished)
		elseif self.ufoStatus == UFOStatus.kWakeUp then
			self:playUFOWakeUpOnHit(onFinished)
		elseif self.ufoStatus == UFOStatus.kStun then
			self:playUFOStunOnHit(onFinished)
		else
			onFinished()
		end
		GamePlayMusicPlayer:playEffect( GameMusicType.kPlayUfoOnhit )
	end
end

function UFOAnimation:playUFORecover(callback)
	self.currentAnimation = UFOAnimationType.kRecover
	if self.ufoStatus == UFOStatus.kStun then
		self:playUFOStunOnRecover(callback)
	elseif self.ufoStatus == UFOStatus.kWakeUp then
		GamePlayMusicPlayer:playEffect( GameMusicType.kPlayUfoWakeup )
		self:playUFOWakeUpOnRecover(callback)
	else
		if callback then callback() end
	end
end

function UFOAnimation:playUFOHoverEffect()
	if self.ufoStatus == UFOStatus.kNormal and self.body then
		local time = 1 
		local action_move_up = CCMoveBy:create(time/2, ccp(0, 10/BASE_SCALE))
		local action_move_down = CCMoveBy:create(time/2, ccp(0, -10/BASE_SCALE))
		local action = CCRepeatForever:create(CCSequence:createWithTwoActions(action_move_up, action_move_down))
		action:setTag(kUFOHoverActionTag)
		self.body:runAction(action)
	end
end

function UFOAnimation:stopUFOAnimations()
	self:stopAllActions()
	if self.body then self.body:stopActionByTag(kUFOHoverActionTag) end
end

function UFOAnimation:playUFONormalOnHit(callback)
	self:stopUFOAnimations()

	if self.body then self.body:removeFromParentAndCleanup(true) end
	if self.stun then self.stun:removeFromParentAndCleanup(true) end

	local function onFinished()
		self.ufoStatus = UFOStatus.kStun
		if callback then callback() end
	end

	local stun = self:createStunCircle()
	self.stun = stun
	self.stun:setOpacity(0)
	self:addChild(self.stun)
	local stunSeq = CCArray:create()
	stunSeq:addObject(CCDelayTime:create(10*kCharacterAnimationTime))
	stunSeq:addObject(CCFadeIn:create(10*kCharacterAnimationTime))
	self.stun:runAction(CCSequence:create(stunSeq))

	local body = self:createInactiveUFO()
	self.body = body
	self:addChild(self.body)
	self.body:runAction(CCSequence:createWithTwoActions(self:createUFODropAnimation(), CCCallFunc:create(onFinished)))
end

function UFOAnimation:playUFOWakeUpOnHit(callback)
	self:stopUFOAnimations()

	local function onFinished()
		self.ufoStatus = UFOStatus.kStun
		if callback then callback() end
	end
	self.body:runAction(CCSequence:createWithTwoActions(CCRotateBy:create(4*kCharacterAnimationTime, 8), CCRotateBy:create(3*kCharacterAnimationTime, -8)))
	self.stun:runAction(CCSequence:createWithTwoActions(CCFadeIn:create(10*kCharacterAnimationTime), CCCallFunc:create(onFinished)))
end

function UFOAnimation:playUFOWakeUpOnRecover(callback)
	self:stopUFOAnimations()

	if self.stun then self.stun:setOpacity(0) end
	local function onFinished()
		if self.stun then self.stun:removeFromParentAndCleanup(true) end
		self.ufoStatus = UFOStatus.kNormal
		self:setUFONormal()
		if callback then callback() end
	end
	self.body:runAction(CCSequence:createWithTwoActions(self:createUFOWakeAnimation(), CCCallFunc:create(onFinished)))
end

function UFOAnimation:playUFOStunOnHit(callback)
	self:stopUFOAnimations()

	local function onFinished()
		self.ufoStatus = UFOStatus.kStun
		if callback then callback() end
	end
	local seq = CCArray:create()
	seq:addObject(CCRotateBy:create(4*kCharacterAnimationTime, 8))
	seq:addObject(CCRotateBy:create(3*kCharacterAnimationTime, -8))
	seq:addObject(CCCallFunc:create(onFinished))
	self.body:runAction(CCSequence:create(seq))
end

function UFOAnimation:playUFOStunOnRecover(callback)
	self:stopUFOAnimations()

	local function onFinished()
		self.ufoStatus = UFOStatus.kWakeUp
		if callback then callback() end
	end
	self.stun:runAction(CCSequence:createWithTwoActions(CCFadeOut:create(10*kCharacterAnimationTime), CCCallFunc:create(onFinished)))
end

function UFOAnimation:createUFOWakeAnimation()
	local seq = CCArray:create()
	seq:addObject(CCMoveBy:create(2*kCharacterAnimationTime, ccp(0, 6)))
	seq:addObject(CCMoveBy:create(2*kCharacterAnimationTime, ccp(0, -6)))
	seq:addObject(CCSpawn:createWithTwoActions(CCRotateTo:create(4*kCharacterAnimationTime, 8.5), CCMoveTo:create(3*kCharacterAnimationTime, ccp(-5, -5))))
	seq:addObject(CCSpawn:createWithTwoActions(CCRotateTo:create(3*kCharacterAnimationTime, 16.4), CCMoveTo:create(3*kCharacterAnimationTime, ccp(0, 8))))
	seq:addObject(CCSpawn:createWithTwoActions(CCRotateTo:create(2*kCharacterAnimationTime, 9.2), CCMoveTo:create(2*kCharacterAnimationTime, ccp(0, 0))))
	seq:addObject(CCRotateTo:create(2*kCharacterAnimationTime, 0.8))
	return CCSequence:create(seq)
end

function UFOAnimation:createUFODropAnimation()
	local seq = CCArray:create()
	seq:addObject(CCRotateTo:create(2*kCharacterAnimationTime, 9.2))
	seq:addObject(CCSpawn:createWithTwoActions(CCRotateTo:create(2*kCharacterAnimationTime, 16.4), CCMoveTo:create(2*kCharacterAnimationTime, ccp(0, 8))))
	seq:addObject(CCSpawn:createWithTwoActions(CCRotateTo:create(3*kCharacterAnimationTime, 8.5), CCMoveTo:create(3*kCharacterAnimationTime, ccp(-5, -5))))
	seq:addObject(CCSpawn:createWithTwoActions(CCRotateTo:create(4*kCharacterAnimationTime, -7.3), CCMoveTo:create(3*kCharacterAnimationTime, ccp(-5, -25))))
	seq:addObject(CCMoveBy:create(2*kCharacterAnimationTime, ccp(0, 6)))
	seq:addObject(CCMoveBy:create(2*kCharacterAnimationTime, ccp(0, -6)))
	return CCSequence:create(seq)
end

function UFOAnimation:resetUFO( ... )
	-- body
	self:stopUFOAnimations()
	self:setScale(BASE_SCALE)
	self:setVisible(true)
	self:setRotation(0)
	if self.shadow then self.shadow:removeFromParentAndCleanup(true) self.shadow = nil end
	if self.body then self.body:setPosition(ccp(0,0)) self.body:setRotation(0) end
	if self.carrot then 
		self.carrot:stopAllActions() 
		self.carrot:removeFromParentAndCleanup(true) 
		self.carrot = nil 
	end
end

--first flying in
function UFOAnimation:playAnimation_firstFlyin( toPosition , callback)
	-- body
	self:resetUFO()
	self.currentAnimation = UFOAnimationType.kFlyInto
	local time = 1
	local visibleSize = CCDirector:sharedDirector():getVisibleSize()
	toPosition = toPosition or ccp(visibleSize.width / 2, visibleSize.height / 2)
	local fromPostion = ccp(0, visibleSize.height / 2)
	self:setPosition(fromPostion)

	local bezierConfig = ccBezierConfig:new()
	bezierConfig.controlPoint_1 = fromPostion
	bezierConfig.controlPoint_2 = ccp((toPosition.x - fromPostion.x)/ 2, (toPosition.y - fromPostion.y)/2)
	bezierConfig.endPosition = toPosition
	-- local bezierAction = CCBezierTo:create(time, bezierConfig)
	local bezierAction = CCEaseOut:create(CCBezierTo:create(time, bezierConfig),2) 

	local action_zoom   = CCScaleTo:create(time/4, 1.5)
	local action_rotation = CCRotateTo:create(time/4, -15)
	local action_back = CCRotateTo:create(time/4, 0)
	local action_narrow = CCScaleTo:create(time/4, BASE_SCALE)
	local array_scale = CCArray:create()
	array_scale:addObject(action_zoom)
	array_scale:addObject(action_rotation)
	array_scale:addObject(action_back)
	array_scale:addObject(action_narrow)
	local action_scale = CCSequence:create(array_scale)
	local action_flayin = CCSpawn:createWithTwoActions(bezierAction, action_scale)

	local function completeCallback( ... )
		-- body
		self:playUFOHoverEffect()
		if callback and type(callback) == "function" then 
			callback()
		end
	end
	local array = CCArray:create()
	array:addObject(action_flayin)
	array:addObject(CCCallFunc:create(completeCallback))

	self:runAction(CCSequence:create(array))
	GamePlayMusicPlayer:playEffect( GameMusicType.kPlayUfoIn )
end

function UFOAnimation:playAnimation_reFlyin( toPosition, callback )
	-- body
	self:resetUFO()
	self.currentAnimation = UFOAnimationType.kReflyInto
	local time = 4
	local visibleSize = CCDirector:sharedDirector():getVisibleSize()
	toPosition = toPosition or ccp(visibleSize.width / 2, visibleSize.height /2 )

	local fromPostion = ccp(toPosition.x, visibleSize.height + self:getGroupBounds().size.height/2)
	self:setPosition(fromPostion)

	local move_action = CCEaseElasticOut:create(CCMoveTo:create(time, toPosition))

	local function completeCallback( ... )
		-- body
		self:playUFOHoverEffect()
		if not self.lightning then 
			self.lightning = createLightning()
			self:addChild(self.lightning)
		end
		if callback and type(callback) == "function" then 
			callback()
		end
	end

	local array = CCArray:create()
	array:addObject(move_action)
	array:addObject(CCCallFunc:create(completeCallback))
	self:runAction(CCSequence:create(array))
	GamePlayMusicPlayer:playEffect( GameMusicType.kPlayUfoIn )
end

function UFOAnimation:buildLightAnimation(callback)
	local lightAnimation = Sprite:createEmpty()
	local circleNum = 4
	local circleAniCD = circleNum
	local function onCircleAnimationFinished()
		circleAniCD = circleAniCD - 1
		if circleAniCD < 1 then
			if lightAnimation then lightAnimation:removeFromParentAndCleanup(true) end
			if callback then callback() end
		end
	end

	local function buildLightCirlce(delay)
		delay = delay or 0
		-- body
		local sprite = Sprite:createWithSpriteFrameName("UFO_light_circle")
		sprite:setPosition(ccp(0, -100))
		sprite:setScale(2.5)
		sprite:setScaleY(0.9)
		sprite:setOpacity(0)
		
		local upTime = 0.5
		local actionSeq = CCArray:create()
		actionSeq:addObject(CCScaleTo:create(upTime, 0.3))
		actionSeq:addObject(CCMoveTo:create(upTime, ccp(0, -30)))
		actionSeq:addObject(CCFadeIn:create(upTime))
		local action_up = CCSpawn:create(actionSeq)

		local function circleCallback( ... )
			if sprite then sprite:removeFromParentAndCleanup(true) end
			onCircleAnimationFinished()
		end

		local seq2 = CCArray:create()
		seq2:addObject(CCDelayTime:create(delay))
		seq2:addObject(action_up)
		seq2:addObject(CCCallFunc:create(circleCallback))

		sprite:runAction(CCSequence:create(seq2))
		return sprite
	end

	for k = 1, circleNum do 
		lightAnimation:addChild(buildLightCirlce(0.2 * (k-1)))
	end

	local upLight = Sprite:createWithSpriteFrameName("ufo_uplight")
	upLight:setPosition(ccp(0, -25))
	upLight:setAnchorPoint(ccp(0.5, 1))
	local lightSeq = CCArray:create()
	lightSeq:addObject(CCDelayTime:create(0.1))
	lightSeq:addObject(CCSpawn:createWithTwoActions(CCFadeTo:create(0.3, 255 * 0.4), CCScaleTo:create(0.3, 1, 0.4)))
	lightSeq:addObject(CCSpawn:createWithTwoActions(CCFadeTo:create(0.3, 255), CCScaleTo:create(0.3, 1, 1)))
	upLight:runAction(CCRepeatForever:create(CCSequence:create(lightSeq)))
	lightAnimation:addChild(upLight)

	return lightAnimation
end

function UFOAnimation:addCarrot()
	local carrot = Sprite:createWithSpriteFrameName("UFO_carrot")
	carrot:setAnchorPoint(ccp(0.5, 1))
	carrot:setPosition(ccp(0, -self.body:getGroupBounds().size.height / 2))
	self:addChild(carrot)

	local function animationCallback()
		if self.carrot then self.carrot:removeFromParentAndCleanup(true) self.carrot = nil end
	end

	local arr = CCArray:create()
	arr:addObject(CCOrbitCamera:create(0.7, 1, 0, 270, 180, 0, 0))
	arr:addObject(CCOrbitCamera:create(0.7, 1, 0, 450, -180, 0, 0))
	arr:addObject(CCCallFunc:create(animationCallback))
	carrot:runAction(CCSequence:create(arr))
	self.carrot = carrot
end

function UFOAnimation:playAnimation_pull( callback )
	-- body
	if self.currentAnimation and self.currentAnimation == UFOAnimationType.kPull then 
		if callback then callback() end
		return 
	end

	self:resetUFO()
	self.currentAnimation = UFOAnimationType.kPull

	local function completeCallback( ... )
		self:playUFOHoverEffect()
		if callback and type(callback) == "function" then callback() end
		self.body:setRotation(0)
		self.currentAnimation = nil
	end

	--add lights
	local lightAni = self:buildLightAnimation(completeCallback)
	self:addChild(lightAni)
	--add carrot
	if self.ufoType == UFOType.kRabbit then 
		self:addCarrot()
	end

	GamePlayMusicPlayer:playEffect( GameMusicType.kPlayUfoDown )
end

function UFOAnimation:playAnimation_flyOut( callback )
	-- body
	if self.currentAnimation and self.currentAnimation == UFOAnimationType.kFlyOut then 
		if callback then callback() end
		return  
	end

	self:resetUFO()
	self.currentAnimation = UFOAnimationType.kFlyOut
	local time = 1
	local visibleSize = CCDirector:sharedDirector():getVisibleSize()
	local toPosition = ccp(visibleSize.width/2, visibleSize.height/2)
	local fromPosition = self:getPosition()

	local function completeCallback( ... )
		-- body
		self:playUFOHoverEffect()
		self.currentAnimation = nil
		if callback then callback() end
	end

	local bezierConfig = ccBezierConfig:new()
	bezierConfig.controlPoint_1 = ccp(fromPosition.x, fromPosition.y)
	bezierConfig.controlPoint_2 = ccp(0, toPosition.y / 2)
	bezierConfig.endPosition = toPosition
	local bezierAction = CCBezierTo:create(time, bezierConfig)
	local scaleAction = CCScaleTo:create(time, 2.5)

	local bezierConfig_2 = ccBezierConfig:new()
	bezierConfig_2.controlPoint_1 = ccp(0, toPosition.y / 2)
	bezierConfig_2.controlPoint_2 = ccp(visibleSize.width / 2,(visibleSize.height - toPosition.y / 2) / 2)
	bezierConfig_2.endPosition = ccp(visibleSize.width, visibleSize.height)
	local bezierAction_2 = CCBezierTo:create(time, bezierConfig_2)
	local scaleAction_2 = CCScaleTo:create(time, 0.1)

	
	local callfuncAction = CCCallFunc:create(completeCallback)

	local array_action = CCArray:create()
	array_action:addObject(CCSpawn:createWithTwoActions(bezierAction, scaleAction))
	array_action:addObject(CCDelayTime:create(0.75 * time))
	array_action:addObject(CCSpawn:createWithTwoActions(bezierAction_2,scaleAction_2 ))
	array_action:addObject(callfuncAction)
	local ufo_action = CCSequence:create(array_action)
	self:runAction(ufo_action)

	----外星人
	local ufo_man = Sprite:createWithSpriteFrameName("ufo_alien")
	ufo_man:setAnchorPoint(ccp(0, 0.5))
	local size = self:getGroupBounds().size
	local pos = ccp(15, 30)
	-- local pos = ccp(0, size.height/4)
	ufo_man:setPosition(pos)
	self:addChild(ufo_man)
	ufo_man:setScale(0)
	local scaleFactor = 0.7
	local action_fadeIn  = CCSpawn:createWithTwoActions(CCFadeIn:create(time/4),CCScaleTo:create(time/4, 1*scaleFactor)) 
	local action_fadeout = CCSpawn:createWithTwoActions(CCFadeOut:create(time/4),CCScaleTo:create(time/4, 0.1*scaleFactor)) 
	local function ufomanCallback( ... )
		-- body
		if ufo_man then ufo_man:removeFromParentAndCleanup(true) end
	end 
	local array_man = CCArray:create()
	array_man:addObject(CCDelayTime:create(time))
	array_man:addObject(CCSpawn:createWithTwoActions(CCFadeIn:create(time/8),CCScaleTo:create(time/8, 1*scaleFactor)) )
	array_man:addObject(CCSequence:createWithTwoActions(CCRotateTo:create(time/4, -15), CCRotateTo:create(time/4, 0)))
	array_man:addObject(CCSpawn:createWithTwoActions(CCFadeOut:create(time/8),CCScaleTo:create(time/8, 0.1*scaleFactor)) )
	array_man:addObject(CCCallFunc:create(ufomanCallback))
	local action = CCSequence:create(array_man)
	ufo_man:runAction(action)
	---body

	local body_action_array	= CCArray:create()
	body_action_array:addObject(CCRotateTo:create(time/3 * 2, -15)) 
	body_action_array:addObject(CCRotateTo:create(time/3, 0)) 
	body_action_array:addObject(CCDelayTime:create(time/2))
	body_action_array:addObject(CCRotateTo:create(time/3 *2, 15))
	body_action_array:addObject(CCRotateTo:create(time/3, 0))
	self.body:runAction(CCSequence:create(body_action_array))

	GamePlayMusicPlayer:playEffect( GameMusicType.kPlayUfoWin )
end



