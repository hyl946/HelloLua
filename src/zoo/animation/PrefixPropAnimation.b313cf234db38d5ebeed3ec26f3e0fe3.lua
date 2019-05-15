require "hecore.display.Director"

PrefixPropAnimation = class()

local function dropAndShiningAnimate_addMove( icon, parent, onAnimationFinished, iconSpawn)
	local iconInTime = 0.4
	local winSize = CCDirector:sharedDirector():getVisibleSize()

	local showTime = 1
	
	iconSpawn = iconSpawn or CCSpawn:createWithTwoActions(CCFadeOut:create(0.3), CCEaseSineOut:create(CCScaleTo:create(0.3, 1.5)))
	icon:setAnchorPoint(ccp(0.5, 0.5))
	icon:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.1), iconSpawn))
	icon:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.9), CCCallFunc:create(onAnimationFinished)) )

	parent:addChild(icon)
end

local function dropAndShiningAnimate( icon, halo, parent, onAnimationFinished, iconSpawn, isPre )
	local iconInTime = 0.4
	local winSize = CCDirector:sharedDirector():getVisibleSize()

	local showTime = 1
	
	iconSpawn = iconSpawn or CCSpawn:createWithTwoActions(CCFadeOut:create(0.3), CCEaseSineOut:create(CCScaleTo:create(0.3, 1.5)))
	icon:setAnchorPoint(ccp(0.5, 0.5))
	icon:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(showTime), iconSpawn))

	local haloOut = CCArray:create()
	haloOut:addObject(CCFadeOut:create(0.3))
	haloOut:addObject(CCScaleTo:create(0.3, 1.5))
	haloOut:addObject(CCRotateBy:create(0.5, 100))

	local haloArray = CCArray:create()
	haloArray:addObject(CCDelayTime:create(showTime - 0.3))
	haloArray:addObject(CCFadeIn:create(0.1))
	haloArray:addObject(CCSpawn:createWithTwoActions(CCEaseSineOut:create(CCRotateBy:create(0.5, 140)), CCScaleTo:create(0.5, 1)))
	haloArray:addObject(CCSpawn:create(haloOut))
	haloArray:addObject(CCCallFunc:create(onAnimationFinished))
	
	halo:setAnchorPoint(ccp(0.5, 0.5))
	halo:setScale(0)
	halo:setOpacity(0)
	halo:runAction(CCSequence:create(haloArray))

	if not isPre then
		local animationTimeA, animationTimeB = 0.05, 0.02
	  	local array = CCArray:create()
		array:addObject(CCMoveBy:create(animationTimeA, ccp(-6, 0)))
		array:addObject(CCMoveBy:create(animationTimeA*2, ccp(12, 0)))
		array:addObject(CCMoveBy:create(animationTimeA, ccp(-6, 0)))
		array:addObject(CCMoveBy:create(animationTimeB, ccp(-4, 0)))
		array:addObject(CCMoveBy:create(animationTimeB, ccp(4, 0)))
		parent:runAction(CCSequence:create(array))
	end

	parent:addChild(icon)
	parent:addChild(halo)
end

function PrefixPropAnimation:createPropAnimation( icon, positionSrc, animationCallbackFunc,isPre)
	local layer = CocosObject:create()	
	local sprite = Sprite:createWithSpriteFrameName("prefix_halo0000")	

	layer:setPosition(positionSrc)
	layer:setScale(1.4)
	dropAndShiningAnimate(icon, sprite, layer, animationCallbackFunc,nil,isPre)
	return layer
end

function PrefixPropAnimation:createAddTimeAnimation(icon, delay, flyFinishedCallback, animationCallbackFunc, positionSrc )
	return PrefixPropAnimation:createAddMoveAnimation(icon, delay, flyFinishedCallback, animationCallbackFunc, positionSrc )
end

function PrefixPropAnimation:createAddMoveAnimation(icon, delay, flyFinishedCallback, animationCallbackFunc, positionSrc ,isPre, endPosDelta)
	local endPosDeltaX = 0
	local endPosDeltaY = 0
	if endPosDelta and type(endPosDelta) == "table" then 
		endPosDeltaX = endPosDelta[1] or 0
		endPosDeltaY = endPosDelta[2] or 0
	end

	delay = delay or 0
	
	local origin = Director:sharedDirector():getVisibleOrigin()
	local winSize = CCDirector:sharedDirector():getVisibleSize()
	local layer = CocosObject:create()	
	local x, y = positionSrc.x, positionSrc.y - 100

	layer:setPosition(ccp(origin.x, origin.y))

	local function onStarAnimationFinished()
		layer:removeFromParentAndCleanup(true)
		if animationCallbackFunc ~= nil then animationCallbackFunc() end
	end
	local function onIconAnimationFinished()
		local winSize = CCDirector:sharedDirector():getVisibleSize()
		local star = BezierFallingStar:create(ccp(x, y), ccp(winSize.width - 100 + endPosDeltaX, winSize.height - 100 + endPosDeltaY), onStarAnimationFinished, flyFinishedCallback)
		layer:addChild(star)
	end 

	local container = CocosObject:create()
	container:setScale(1.4)
	container:setPosition(ccp(x, y))
	layer:addChild(container)
	local realSize = CCDirector:sharedDirector():getWinSize()
	local topright = layer:convertToWorldSpace(ccp(winSize.width - 100 + endPosDeltaX, winSize.height - 100 + endPosDeltaY))

	topright = container:convertToNodeSpace(topright)
	local dx = winSize.width - 100 - x
  	local dy = winSize.height - 100 - y
  	local distance = dx * dx + dy * dy
  	local visibleSize	= CCDirector:sharedDirector():getVisibleSize()
  	local visibleHeight = visibleSize.height
  	local time = 1.5*math.sqrt(distance)/visibleHeight
  	time = time * 0.7

	local fadeout = CCArray:create()
	if not isPre then
		fadeout:addObject(CCScaleTo:create(0.5, 0.3))
	end

	local startPos = icon:getPosition()
	local bezierConfig = ccBezierConfig:new() 
	local controlPoint = ccp(
		(startPos.x + topright.x)/2+(topright.y-startPos.y)/4, 
		(startPos.y + topright.y)/2+(-topright.x+startPos.x)/4
	)
	bezierConfig.controlPoint_1 = controlPoint
	bezierConfig.controlPoint_2 = controlPoint
	bezierConfig.endPosition = topright

	fadeout:addObject(CCEaseSineInOut:create(CCBezierTo:create(time, bezierConfig)))

	fadeout:addObject(CCSequence:createWithTwoActions(CCDelayTime:create(0.2), CCFadeOut:create(0.2)) )
	
	local array = CCArray:create()
	if not isPre then
		local action_move = CCEaseElasticOut:create(CCMoveBy:create(0.8, ccp(0, 30)))
		icon:setScale(0.1)
		local action_scale = CCEaseOut:create( CCScaleTo:create(0.4, 1), 1.1)
		array:addObject( CCSpawn:createWithTwoActions(action_scale, action_move))
	else
		array:addObject(CCDelayTime:create(0.8))
	end

	array:addObject(CCSpawn:create(fadeout))

	if not isPre then
		dropAndShiningAnimate_addMove(icon, container, onIconAnimationFinished, CCSequence:create(array))
	else
		local sprite = Sprite:createWithSpriteFrameName("prefix_halo0000")	
		dropAndShiningAnimate(icon,sprite, container, onIconAnimationFinished, CCSequence:create(array), isPre)
	end
  	
	return layer
end

function PrefixPropAnimation:createChangePropAnimation( icon, delay, positionA, positionB, flyFinishedCallback, animationCallbackFunc, positionSrc,isPre )
	delay = delay or 0

	local origin = Director:sharedDirector():getVisibleOrigin()
	local winSize = CCDirector:sharedDirector():getVisibleSize()
	local layer = CocosObject:create()	
	local sprite = Sprite:createWithSpriteFrameName("prefix_halo0000")	
	local x, y = positionSrc.x, positionSrc.y - 100


	layer:setPosition(ccp(origin.x, origin.y))

	local function onStarAnimationFinished()
		layer:removeFromParentAndCleanup(true)
		if animationCallbackFunc ~= nil then animationCallbackFunc() end
	end

	local function onIconAnimationFinished()
		local starA = FallingStar:create(ccp(x, y), positionA)
		layer:addChild(starA)
		local starB = FallingStar:create(ccp(x, y), positionB, onStarAnimationFinished, flyFinishedCallback)
		layer:addChild(starB)
	end 

	local container = CocosObject:create()
	container:setScale(1.3)
	container:setPosition(ccp(x, y))
	layer:addChild(container)
	dropAndShiningAnimate(icon, sprite, container, onIconAnimationFinished,nil,isPre)

	return layer
end

------------------------
--创建复活导弹动画
------------------------
function PrefixPropAnimation:createReviveMissileAnimation( icon, animationCallbackFunc )
	-- body
	local timeTotal = 1
	local sprite = Sprite:createEmpty()
	sprite:addChild(icon)


	local origin = CCDirector:sharedDirector():getVisibleSize()
	fromPostion = fromPostion or ccp(origin.width/2, origin.height/2)
	toPosition = toPosition or ccp(origin.width, origin.height)

	sprite:setPosition(fromPostion)
	local distanceX = toPosition.x - fromPostion.x
	local distanceY = toPosition.y - fromPostion.y

	local pos_to_1 = ccp(fromPostion.x + distanceX / 2, fromPostion.y)
	local bezierConfig_1 = ccBezierConfig:new()
	bezierConfig_1.controlPoint_1 = ccp(fromPostion.x +  distanceX / 8, fromPostion.y +  distanceX / 4)
	bezierConfig_1.controlPoint_2 = ccp(fromPostion.x +  3 * distanceX / 8, fromPostion.y + distanceX / 4)
	bezierConfig_1.endPosition = pos_to_1
	local bezierAction_1 = CCBezierTo:create(timeTotal/3, bezierConfig_1)
	local rotation_1 = CCRotateTo:create(timeTotal/3, 180)
	local action_1 = CCSpawn:createWithTwoActions(bezierAction_1, rotation_1)

	local pos_to_2 = ccp(fromPostion.x, fromPostion.y)
	local bezierConfig_2 = ccBezierConfig:new()
	bezierConfig_2.controlPoint_1 = ccp(fromPostion.x + 3 * distanceX / 8, fromPostion.y - distanceX / 4)
	bezierConfig_2.controlPoint_2 = ccp(fromPostion.x + distanceX / 8, fromPostion.y - distanceX / 4)
	bezierConfig_2.endPosition = pos_to_2
	local bezierAction_2 = CCBezierTo:create(timeTotal/3, bezierConfig_2)
	local rotation_2 = CCRotateTo:create(timeTotal/3, 360)
	local action_2 = CCSpawn:createWithTwoActions(bezierAction_2, rotation_2)


	-- local bezierConfig_3 = ccBezierConfig:new()
	-- bezierConfig_3.controlPoint_1 = ccp(fromPostion.x +  distanceX/3, fromPostion.y + distanceY /2)
	-- bezierConfig_3.controlPoint_2 = ccp(fromPostion.x + 2*  distanceX/3, fromPostion.y + 4 * distanceY /5)
	-- bezierConfig_3.endPosition = toPosition
	-- local bezierAction_3 = CCBezierTo:create(timeTotal/3, bezierConfig_3)
	local bezierAction_3 = CCMoveTo:create(timeTotal/3, ccp(origin.width/2, origin.height))
	local array_3 = CCArray:create()
	array_3:addObject(bezierAction_3)
	-- array_3:addObject(CCRotateTo:create(timeTotal/3, 45))
	array_3:addObject(CCScaleTo:create(timeTotal/3, 0.2))
	local action_3 = CCSpawn:create(array_3)

	local function completeCallback( ... )
		-- body
		if sprite then sprite:removeFromParentAndCleanup(true) end
		if animationCallbackFunc and type(animationCallbackFunc) == "function" then animationCallbackFunc() end
	end

	local action_callback = CCCallFunc:create(completeCallback)


	local array_action = CCArray:create()
	array_action:addObject(action_1)
	array_action:addObject(action_2)
	array_action:addObject(action_3)
	array_action:addObject(action_callback)
	sprite:runAction(CCSequence:create(array_action))
	return sprite
end


-- 道具后面发光动画
function PrefixPropAnimation:createShineAnimation( )
	local container = CocosObject:create()

	local shine = Sprite:createWithSpriteFrameName("Prop_shine_inner0000")
	shine:ignoreAnchorPointForPosition(false)
	shine:setAnchorPoint(ccp(0.5,0.5))
	container:addChild(shine)
	shine:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(
		CCFadeTo:create(0.5,0.5 * 255),
		CCFadeTo:create(0.5,1.0 * 255)
	)))

	return container
end