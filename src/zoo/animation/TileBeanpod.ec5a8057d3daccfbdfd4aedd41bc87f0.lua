TileBeanpod = class(CocosObject)

local kDangerousActionTag = 1200

function TileBeanpod:create(itemShowType)
	local sprite
	if itemShowType and itemShowType == IngredientShowType.kAcorn then 
		sprite = Sprite:createWithSpriteFrameName("acorn.png")
	else
		sprite = Sprite:createWithSpriteFrameName("beanpod.png");
	end

	local node = TileBeanpod.new(sprite.refCocosObj)
	sprite:dispose()
	node:init(itemShowType)
	return node
end

function TileBeanpod:init(itemShowType)
	local star1 = Sprite:createWithSpriteFrameName("beanpod_star.png")
	local star2 = Sprite:createWithSpriteFrameName("beanpod_star.png")

	star1:setOpacity(0)
	star2:setOpacity(0)
	star1:setPosition(ccp(14, 15))
	star2:setPosition(ccp(50, 35))
	star1:setScale(0.3)
	star2:setScale(0.2)

	local arr1 = CCArray:create()
	local function star1Finish() star1:setPosition(ccp(14, 15)) star1:setRotation(0) end
	arr1:addObject(CCSequence:createWithTwoActions(CCScaleTo:create(0.5, 0.8), CCScaleTo:create(0.5, 0.3)))
	arr1:addObject(CCSequence:createWithTwoActions(CCFadeIn:create(0.5), CCFadeOut:create(0.5)))
	arr1:addObject(CCSequence:createWithTwoActions(CCRotateBy:create(1, 180), CCCallFunc:create(star1Finish)))
	arr1:addObject(CCMoveBy:create(1, ccp(10, 5)))
	star1:runAction(CCRepeatForever:create(CCSpawn:create(arr1)))

	local function onTimeOut()
		if star2.isDisposed then return end
		star2:stopAllActions()
		local arr2 = CCArray:create()
		local function star2Finish() star2:setPosition(ccp(50, 35)) star2:setRotation(0) end
		arr2:addObject(CCSequence:createWithTwoActions(CCScaleTo:create(0.5, 0.6), CCScaleTo:create(0.5, 0.2)))
		arr2:addObject(CCSequence:createWithTwoActions(CCFadeIn:create(0.5), CCFadeOut:create(0.5)))
		arr2:addObject(CCSequence:createWithTwoActions(CCRotateBy:create(1, -180), CCCallFunc:create(star2Finish)))
		arr2:addObject(CCMoveBy:create(1, ccp(-6, -3)))
	 	star2:runAction(CCRepeatForever:create(CCSpawn:create(arr2)))
	end
	star2:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.2), CCCallFunc:create(onTimeOut)))
	
	self:addChild(star1)
	self:addChild(star2)
end

function TileBeanpod:playInDangerAnimation( ... )
	self:stopActionByTag(kDangerousActionTag)

	local action_zoom = CCScaleTo:create(0.4, 1.1)
	local action_narrow = CCScaleTo:create(0.2, 0.9)
	local action = CCRepeatForever:create(CCSequence:createWithTwoActions(action_zoom, action_narrow))
	action:setTag(kDangerousActionTag)
	self:runAction(action)
end

function TileBeanpod:stopInDangerAnimation()
	self:stopActionByTag(kDangerousActionTag)
	self:setScale(1)
end