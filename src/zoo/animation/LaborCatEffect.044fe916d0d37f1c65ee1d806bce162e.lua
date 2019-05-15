LaborCatEffect = class()


function LaborCatEffect:buildItemIcon()
    local container = Sprite:createEmpty()
    local item_grey = Sprite:createWithSpriteFrameName('cat_item_0000')
    local item_full = Sprite:createWithSpriteFrameName('cat_item_0057')
    local item_gold = Sprite:createWithSpriteFrameName('cat_item_0072')

    item_full:setAnchorPoint(ccp(0, 0))
    item_gold:setVisible(false)

    local rect = {size = {width = 140, height = 140}}
    local clipping = ClippingNode:create(rect)

    container:addChild(item_grey)
    clipping:addChild(item_full)
    local layer = Layer:create()
    layer:setContentSize(CCSizeMake(rect.size.width, rect.size.height))
    layer:ignoreAnchorPointForPosition(false)
    layer:setAnchorPoint(ccp(0.5, 0.5))
    layer:addChild(clipping)
    layer:setPosition(ccp(-10, -10))
    container:addChild(layer)
    container:addChild(item_gold)

    local anim = SpriteUtil:buildAnimate(SpriteUtil:buildFrames('cat_item_%04d', 57, 15), 1/15)
    local action = CCRepeatForever:create(CCSequence:createWithTwoActions(anim, CCDelayTime:create(2)))
    item_full:runAction(action)
    local anim = SpriteUtil:buildAnimate(SpriteUtil:buildFrames('cat_item_%04d', 72, 30), 1/20)
    item_gold:play(anim, 0, 0)

    container.clipping = clipping
    container.item_gold = item_gold
    container.item_full = item_full

    container:setScale(1)
    return container
end

local heart5Config = {
	{scale=0.40, initPos={x=-5,y=57}, finalPos={x=-98, y=64}},
	{scale=0.53, initPos={x=-7,y=58}, finalPos={x=-102, y=102}},
	{scale=0.44, initPos={x=-6,y=57}, finalPos={x=72, y=111}},
	{scale=0.53, initPos={x=-7,y=58}, finalPos={x=79, y=53}},
	{scale=0.36, initPos={x=-5,y=57}, finalPos={x=57, y=-4}},
	{scale=0.43, initPos={x=-6,y=57}, finalPos={x=-85, y=-4}},
	{scale=0.30, initPos={x=-4,y=56}, finalPos={x=-72, y=25}},
	{scale=0.22, initPos={x=-2,y=56}, finalPos={x=-69, y=115}},
	{scale=0.16, initPos={x=-1,y=55}, finalPos={x=60, y=90}},
	{scale=0.22, initPos={x=-2,y=56}, finalPos={x=60, y=29}},
	{scale=0.36, initPos={x=-5,y=57}, finalPos={x=-3, y=-24}},
	{scale=0.36, initPos={x=-5,y=57}, finalPos={x=-12, y=144}},
	{scale=0.16, initPos={x=-1,y=55}, finalPos={x=-13, y=115}},
	{scale=0.16, initPos={x=-1,y=55}, finalPos={x=-16, y=2}},
}

function LaborCatEffect:createHeartAnim(onAnimFinishCallback)
	local heartAnim = Sprite:createEmpty()

	local totalAnim = 5

	local function onHeartAnimPartFinish()
		totalAnim = totalAnim - 1
		if totalAnim <= 0 then
			if onAnimFinishCallback then onAnimFinishCallback() end
		end
	end

	local heartFps = 24

	local function addHeart5Anim()
		local heart5Scale = 1.5
		local heart5Anim = Sprite:createEmpty()
		local heart5AnimCount = 0
		for _, v in pairs(heart5Config) do
			local moveX = (v.finalPos.x - v.initPos.x) * 2
			local moveY = (v.finalPos.y - v.initPos.y) * 2
			local heart5 = Sprite:createWithSpriteFrameName("cat_item_use_heart5")
			heart5:setAnchorPoint(ccp(0.5, 0.5))
			heart5:setScale(heart5Scale * v.scale)
			heart5Anim:addChild(heart5)

			local heart5Arr = CCArray:create()
			heart5Arr:addObject(CCSpawn:createWithTwoActions(CCScaleBy:create(10/heartFps, 2), CCMoveBy:create(10/heartFps, ccp(moveX * 0.8, moveY * 0.8))))
			heart5Arr:addObject(CCSpawn:createWithTwoActions(CCFadeOut:create(15/heartFps), CCMoveBy:create(15/heartFps, ccp(moveX * 0.2, moveY * 0.2))))
			
			local function onHeart5AnimFinish()
				if heart5 and not heart5.isDisposed then heart5:removeFromParentAndCleanup(true) end
				heart5AnimCount = heart5AnimCount - 1
				if heart5AnimCount <= 0 then
					onHeartAnimPartFinish()
				end
			end
			heart5Arr:addObject(CCCallFunc:create(onHeart5AnimFinish))
			heart5:runAction(CCSequence:create(heart5Arr))
			heart5AnimCount = heart5AnimCount + 1
		end
		heart5Anim:setPosition(ccp(0, 300))
		heartAnim:addChildAt(heart5Anim, 2)
	end

	local function addHeart4Anim()
		local heart4Scale = 2
		local heart4 = Sprite:createWithSpriteFrameName("cat_item_use_heart4")
		heartAnim:addChildAt(heart4, 4)
		heart4:setAnchorPoint(ccp(0.5, 0.5))
		heart4:setScale(heart4Scale)
		heart4:setPosition(ccp(0, 300))

		local heart4Arr = CCArray:create()
		local function heart4Change()
			heart4:setOpacity(0.3 * 255)
			heart4:setScale(heart4Scale * 1.21)
		end

		local function heart4AnimFinish()
			if heart4 and not heart4.isDisposed then heart4:removeFromParentAndCleanup(true) end
			onHeartAnimPartFinish()
		end
		heart4Arr:addObject(CCDelayTime:create(1 / heartFps))
		heart4Arr:addObject(CCCallFunc:create(heart4Change))
		heart4Arr:addObject(CCDelayTime:create(1 / heartFps))
		heart4Arr:addObject(CCCallFunc:create(heart4AnimFinish))
		heart4:runAction(CCSequence:create(heart4Arr))
	end

	local function addHeart3Anim()
		local heart3Scale = 0.6
		local heart3 = Sprite:createWithSpriteFrameName("cat_item_use_heart3")
		heartAnim:addChildAt(heart3, 1)
		heart3:setAnchorPoint(ccp(0.5, 0.5))
		heart3:setScale(heart3Scale * 1.53)
		heart3:setPosition(ccp(0, 190))

		local function onHeart3AnimFinish()
			if heart3 and not heart3.isDisposed then heart3:removeFromParentAndCleanup(true) end
			onHeartAnimPartFinish()
		end

		local heart3Arr = CCArray:create()

		heart3Arr:addObject(CCSpawn:createWithTwoActions(CCMoveBy:create(7 / heartFps, ccp(0, 40)), CCScaleTo:create(7 / heartFps, heart3Scale * 1.75)))
		heart3Arr:addObject(CCSpawn:createWithTwoActions(CCFadeTo:create(9 / heartFps, 0.1 * 255), CCScaleTo:create(9 / heartFps, heart3Scale * 3.06)))
		heart3Arr:addObject(CCCallFunc:create(onHeart3AnimFinish))
		heart3:runAction(CCSequence:create(heart3Arr))
	end

	local function addHeart2Anim()
		local heart2 = Sprite:createWithSpriteFrameName("cat_item_use_heart2")
		heartAnim:addChildAt(heart2, 3)
		local heart2Scale = 0.95
		heart2:setAnchorPoint(ccp(0.5, 0.5))
		heart2:setPosition(ccp(0, 20))
		heart2:setRotation(-1.5)
		heart2:setOpacity(0.5 * 255)
		heart2:setScale(heart2Scale * 0.7)
		local heart2Arr1 = CCArray:create()
		heart2Arr1:addObject(CCMoveBy:create(6 / heartFps, ccp(-10, 115)))
		heart2Arr1:addObject(CCFadeIn:create(6/heartFps))
		heart2Arr1:addObject(CCScaleTo:create(6/heartFps, heart2Scale * 1.28))
		heart2Arr1:addObject(CCRotateTo:create(6/heartFps, -7.2))

		local heart2Arr2 = CCArray:create()
		heart2Arr2:addObject(CCMoveBy:create(4 / heartFps, ccp(20, 95)))
		heart2Arr2:addObject(CCScaleTo:create(4 / heartFps, heart2Scale * 1.92))
		heart2Arr2:addObject(CCRotateTo:create(4 / heartFps, 7.0))

		local heart2Arr3 = CCArray:create()
		heart2Arr3:addObject(CCMoveBy:create(4 / heartFps, ccp(-10, 50)))
		heart2Arr3:addObject(CCRotateTo:create(4 / heartFps, 0))

		local function onHeart2AnimFinish()
			addHeart4Anim()
			addHeart5Anim()
			if heart2 and not heart2.isDisposed then heart2:removeFromParentAndCleanup(true) end
			onHeartAnimPartFinish()
		end
		local heart2AnimArr = CCArray:create()
		heart2AnimArr:addObject(CCSpawn:create(heart2Arr1))
		heart2AnimArr:addObject(CCSpawn:create(heart2Arr2))
		heart2AnimArr:addObject(CCSpawn:create(heart2Arr3))
		heart2AnimArr:addObject(CCCallFunc:create(onHeart2AnimFinish))

		heart2:runAction(CCSequence:create(heart2AnimArr))
	end

	local heart1Scale = 0.8
	local heart1 = Sprite:createWithSpriteFrameName("cat_item_use_heart1")
	heartAnim:addChildAt(heart1, 3)
	heart1:setAnchorPoint(ccp(0.5, 0.5))
	heart1:setOpacity(0.17 * 255)
	heart1:setScale(heart1Scale * 0.37)
	local hert1Anim1 = CCSpawn:createWithTwoActions(CCFadeIn:create(6 / heartFps), CCScaleTo:create(6 / heartFps, heart1Scale * 0.96))
	local heart1Arr = CCArray:create()
	heart1Arr:addObject(hert1Anim1)
	heart1Arr:addObject(CCDelayTime:create(3 / heartFps))
	local function onHeart1AnimFinish()
		addHeart2Anim()
		if heart1 and not heart1.isDisposed then heart1:removeFromParentAndCleanup(true) end
		onHeartAnimPartFinish()
	end
	heart1Arr:addObject(CCCallFunc:create(onHeart1AnimFinish))
	heart1:runAction(CCSequence:create(heart1Arr))

	setTimeOut(addHeart3Anim, 17 / heartFps)

	return heartAnim
end

function LaborCatEffect:playItemUseAnimation(callback)
	local winSize = Director:sharedDirector():getWinSize()
	local scene = Director:sharedDirector():getRunningScene()
	local container = Layer:create()
	container:setPosition(ccp(winSize.width / 2, winSize.height / 2))
    container:setTouchEnabled(true, 0, true)
	scene:addChild(container)

    local greyCover = LayerColor:create()
    greyCover:setColor(ccc3(0,0,0))
    greyCover:setOpacity(150)
    greyCover:setContentSize(CCSizeMake(winSize.width, winSize.height))
    greyCover:setPosition(ccp(-winSize.width / 2, -winSize.height / 2))
    container:addChild(greyCover)

    local totalAnimCount = 2
	local function onAnimFinished()
		totalAnimCount = totalAnimCount - 1
		if totalAnimCount <= 0 then
			if container and not container.isDisposed then container:removeFromParentAndCleanup(true) end
			if callback then callback() end
		end
	end
	local catAnimFps = 12
	local catSprite = Sprite:createWithSpriteFrameName("cat_item_use_cat_0000")
	catSprite:setAnchorPoint(ccp(0.5, 0.5))
	catSprite:setPosition(ccp(-16, -40))
	local catAnim = SpriteUtil:buildAnimate(SpriteUtil:buildFrames('cat_item_use_cat_%04d', 0, 49), 1/catAnimFps)
	catSprite:play(catAnim, 0, 1, onAnimFinished, true)
	container:addChild(catSprite)

	local function playHeartAnim()
		local heartAnim = self:createHeartAnim(onAnimFinished)
		heartAnim:setPosition(ccp(0, -75))
		container:addChild(heartAnim)
	end
	setTimeOut(playHeartAnim, 26 / catAnimFps)
end
