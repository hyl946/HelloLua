ElephantAnimation = class()

function ElephantAnimation:createJuiceBottle(step)
	local winSize = CCDirector:sharedDirector():getWinSize()
	local builder = InterfaceBuilder:createWithContentsOfFile("flash/animation/juice/juice_bottle.json")
	local bottle = builder:buildGroup("bottle"..step)

	local bottle_wrapper = Layer:create()
	bottle_wrapper:changeWidthAndHeight(bottle:getGroupBounds().size.width, bottle:getGroupBounds().size.height)
	bottle_wrapper:addChild(bottle)
	bottle_wrapper:setAnchorPoint(ccp(0, -0.3))

	local function getChildByName(self, child)
		return self:getChildAt(0):getChildByName(child) 
	end

	bottle_wrapper.getChildByName = getChildByName
	return bottle_wrapper
end

local function getRealPlistPath(path)
	local plistPath = path
	if __use_small_res then  
		plistPath = table.concat(plistPath:split("."),"@2x.")
	end

	return plistPath
end

function ElephantAnimation:juiceChangeAnimation(container, bottleStart, to)
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(getRealPlistPath("flash/animation/juice/juice_animation.plist"))

	local juice_shake_start = bottleStart:getChildByName("juice_shake")
	if juice_shake_start then
		juice_shake_start:setVisible(false)
	end

	local glow_start = bottleStart:getChildByName("glow")
	glow_start:setAlpha(0.2)
	glow_start:runAction(CCFadeTo:create(8/30, 255))

	local bottleEnd = ElephantAnimation:createJuiceBottle(to)
	local glow_end = bottleEnd:getChildByName("glow")
	if to ==5 then
		glow_end:setVisible(false)
		glow_end = bottleEnd:getChildByName("glow_strong")
	end

	local actions = CCArray:create()
	actions:addObject(CCScaleTo:create(4/30, 1.13, 0.84))
	if juice_shake_start then
		actions:addObject(CCCallFunc:create(function() 
				local juice_surface_start = bottleStart:getChildByName("surface")
				if juice_surface_start and not juice_surface_start.isDisposed and not juice_shake_start.isDisposed then
					juice_surface_start:setVisible(false)
					juice_shake_start:setVisible(true)

					local juice_frames = SpriteUtil:buildFrames("juice_shake_%04d.png", 0, 27)
					local juice_animate = SpriteUtil:buildAnimate(juice_frames, 1/25)
					juice_shake_start:play(juice_animate, 0, 1, nil, false)
				end
			end))
	end
	actions:addObject(CCSpawn:createWithTwoActions(CCScaleTo:create(4/30, 1, 1.10), CCMoveBy:create(4/30, ccp(0,8))))
	actions:addObject(CCCallFunc:create(function() 

		bottleEnd:setPositionXY(bottleStart:getPositionX(), bottleStart:getPositionY())
		bottleEnd:setScaleX(bottleStart:getScaleX())
		bottleEnd:setScaleY(1.2)
		container:addChildAt(bottleEnd, container:getChildIndex(container))
		bottleStart:removeFromParentAndCleanup(false)

		local juice_surface = bottleEnd:getChildByName("surface")
		juice_surface:setVisible(false)

		local newJuice_shake = bottleEnd:getChildByName("juice_shake")
		newJuice_shake:setVisible(true)

		local juice_frames = SpriteUtil:buildFrames("juice_shake_%04d.png", 0, 27)
		local juice_animate = SpriteUtil:buildAnimate(juice_frames, 1/25)
		newJuice_shake:play(juice_animate, 0, 1, function()
				juice_surface:setVisible(true)
			end, true)

		local juice_splash = Sprite:createWithSpriteFrameName("juice_splash_0000.png")
		juice_splash:setPositionXY(bottleEnd:getPositionX(), bottleEnd:getPositionY() + juice_splash:getContentSize().height/2)
		container:addChild(juice_splash)

		local splash_frames = SpriteUtil:buildFrames("juice_splash_%04d.png", 0, 8)
		local splash_animate = SpriteUtil:buildAnimate(splash_frames, 1/30)
		juice_splash:play(splash_animate, 0, 1, nil, true)

		local bubble =  Sprite:createWithSpriteFrameName("juice_bubble_0000.png")
		bubble:setPositionXY(bottleEnd:getPositionX(), bottleEnd:getPositionY() + bubble:getContentSize().height/2)

		local bubble_frames = SpriteUtil:buildFrames("juice_bubble_%04d.png", 0, 10)
		local bubble_animate = SpriteUtil:buildAnimate(bubble_frames, 1/20)
		bubble:play(bubble_animate, 0, 2, nil, true)
		container:addChild(bubble)

		local actions2 = CCArray:create()
		actions2:addObject(CCScaleTo:create(3/30, 1,1))
		actions2:addObject(CCMoveBy:create(5/30, ccp(0, -8)))

		if to == 5 then
			actions2:addObject(
				CCCallFunc:create(function()
						--[[bottleEnd:removeFromParentAndCleanup(false)
						
						local bottle_wrapper = Layer:create()
		 				bottle_wrapper:changeWidthAndHeight(bottleEnd:getGroupBounds().size.width, bottleEnd:getGroupBounds().size.height)
		 				bottle_wrapper:addChild(bottleEnd)
		 				bottle_wrapper:setAnchorPoint(ccp(0, 0.3))
		 				bottle_wrapper:setPositionXY(bottleEnd:getPositionX(), bottleEnd:getPositionY())
		 				bottleEnd:setPositionXY(0, 0)]]--

		 				bottleEnd:setAnchorPoint(ccp(0, 0.3))
		 				local rotate =  CCRepeatForever:create(CCSequence:createWithTwoActions(CCRotateTo:create(2/15, 5), CCRotateTo:create(2/15, -5)))
						bottleEnd:runAction(rotate)
					end))
		end

		bottleEnd:runAction(CCSequence:create(actions2))

		if to == 5 then
			glow_end:runAction(CCRepeatForever:create(
				 CCSequence:createWithTwoActions(CCFadeTo:create(1, 255), CCFadeTo:create(1, 0))))
		else
			glow_end:runAction(  CCFadeTo:create(8/30, 255 * 0.2))
		end
	end))

	bottleStart:runAction(CCSequence:create(actions))

	return bottleEnd
end

function ElephantAnimation:playUseAnimation(callback)

	local winSize = Director:sharedDirector():getWinSize()
	local scene = Director:sharedDirector():getRunningScene()
	local container = Layer:create()
    container:setTouchEnabled(true, 0, true)
	scene:addChild(container)

    local greyCover = LayerColor:create()
    greyCover:setColor(ccc3(0,0,0))
    greyCover:setOpacity(150)
    greyCover:setContentSize(CCSizeMake(winSize.width, winSize.height))
    greyCover:setPosition(ccp(0 , 0))
    container:addChild(greyCover)

	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(getRealPlistPath("flash/animation/elephant/boss_elephant_use.plist"))
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(getRealPlistPath("flash/animation/water_splash.plist"))

	local boss = Sprite:createWithSpriteFrameName("boss_elephant_use_0000.png")
	boss:setScale(0.1)
	boss:setPosition(ccp(winSize.width/2, winSize.height /2 - boss:getContentSize().height/2))
	container:addChild(boss)

	local function playCloudAnimation()
		local cloud = Sprite:createWithSpriteFrameName("boss_elephant_cloud_0000.png")
		cloud:setScale(10/7)
		cloud:setPositionXY(boss:getPositionX(), boss:getPositionY())
		container:addChild(cloud)

		local cloud_frames = SpriteUtil:buildFrames("boss_elephant_cloud_%04d.png", 0, 13)
		local cloud_animate = SpriteUtil:buildAnimate(cloud_frames, 1/30)
		cloud:play(cloud_animate, 0, 1, nil, true)
	end

	local function createWaterSplash()
		local water_splash = Sprite:createWithSpriteFrameName("water_splash_0000.png")
		water_splash:setScale(3.2)
		water_splash:setPosition(ccp(winSize.width/2, (winSize.height) /2))
		container:addChild(water_splash)

		local water_frames = SpriteUtil:buildFrames("water_splash_%04d.png", 0, 7)
		local water_animate = SpriteUtil:buildAnimate(water_frames, 1/30)
		water_splash:play(water_animate, 0, 1, function() 
				water_splash:removeFromParentAndCleanup(true)
			end)
	end

	local function playWaterAnimation()
		local water = Sprite:createWithSpriteFrameName("waterSplash.png")
		water:setPosition(ccp(winSize.width/2, winSize.height/2))
		water:setScale(0.1 * 1.25)
		container:addChild(water)

		local scale = CCScaleTo:create(3/30, 1.25, 1.25)
		local complete = CCCallFunc:create(function()
				createWaterSplash()

				water:setScale(2*1.25)
				water:runAction(CCCallFunc:create(
					function()
						water:setScale(1.6 * 1.25)
						water:runAction(CCSequence:createWithTwoActions(
							CCFadeOut:create(12/30),
							CCCallFunc:create(function() water:removeFromParentAndCleanup(true) end)
						))
					end
					))
			end)

		water:runAction(CCSequence:createWithTwoActions(scale, complete))
	end

	local function animateComplete()
		if container and not container.isDisposed then 
			container:removeFromParentAndCleanup(true) 
			CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile(getRealPlistPath("flash/animation/elephant/boss_elephant_use.plist"))
			CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile(getRealPlistPath("flash/animation/water_splash.plist"))
		end
		if callback then callback() end
	end

	local delay = CCDelayTime:create(60/30)
	boss:setAnchorPoint(ccp(0.5, 0.1))
	
	local actions = CCArray:create()
	actions:addObject(CCScaleTo:create(5/30, 10/6, 10/6))
	actions:addObject(	
		CCCallFunc:create(
			function()
				local frames = SpriteUtil:buildFrames("boss_elephant_use_%04d.png", 0, 76)
				local animate = SpriteUtil:buildAnimate(frames, 1/30)
				boss:play(animate, 0, 1, animateComplete, true)
			end
		))
	actions:addObject(delay)
	actions:addObject(CCCallFunc:create(function() playWaterAnimation() end ))
	boss:runAction(CCSequence:create(actions))
	playCloudAnimation()

	container:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(78/30), CCCallFunc:create(
			function()
				playCloudAnimation()
			end
		)))
end