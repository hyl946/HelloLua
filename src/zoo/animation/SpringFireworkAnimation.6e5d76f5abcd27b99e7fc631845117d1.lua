
local function getRealPlistPath(path)
	local plistPath = path
	if __use_small_res then  
		plistPath = table.concat(plistPath:split("."),"@2x.")
	end

	return plistPath
end

--------------------------------------------------------
-------------------SpringFirework-----------------------
--------------------------------------------------------
local FireworkType = table.const{
	kPurple = 1,
	kGreen = 2,
	kBlue = 3,
	kYellow = 4,	
}
SpringFireworkNF = class(CocosObject)
function SpringFireworkNF:create(fireworkType, endCallback)
	local sp = SpringFireworkNF.new(CCNode:create())
	sp:init(fireworkType, endCallback)
	return sp
end

function SpringFireworkNF:init(fireworkType, endCallback)
	local sp = SpriteColorAdjust:createWithSpriteFrameName("a0001")
	local hue, saturation, brightness, contrast = 0, 0, 0, 0
	if fireworkType == FireworkType.kGreen then 
		hue = -0.8752
		saturation = 0.2692
	elseif fireworkType == FireworkType.kYellow then
		hue = 0.6666
		saturation = 0.8906
		brightness = 0.1871
	elseif fireworkType == FireworkType.kBlue then
		hue = -0.5758
		saturation = 0.2476
	end
	sp:adjustColor(hue, saturation, brightness, contrast)
	sp:applyAdjustColorShader()
	self:addChild(sp)
	local frames = SpriteUtil:buildFrames('a%04d', 1, 27)
	local animate = SpriteUtil:buildAnimate(frames, 1/16)
	sp:play(animate, 0, 1, function ()
		self:removeFromParentAndCleanup(true)
		if endCallback then endCallback() end
	end)
end

SpringFirework = class(Sprite)
function SpringFirework:create(fireworkInfo, endCallback)
	if not fireworkInfo then fireworkInfo = {} end
	local spriteRefName = 'frame_simple_0000'
	local s = SpringFirework.new(CCSprite:createWithSpriteFrameName(spriteRefName))
	s:init(fireworkInfo, endCallback)
	return s
end

function SpringFirework:init(fireworkInfo, endCallback)
	local anchorPointX = 0.5
	local anchorPointY = 0.7
	local speed = 1500

	self.fireworkType = fireworkInfo.fireworkType
	self.fireworkScale = fireworkInfo.fireworkScale or 1
	self.fromPos = fireworkInfo.fromPos or ccp(0, 0)
	self.endPos = fireworkInfo.endPos or ccp(0, 0)
	self.mid_name = fireworkInfo.mid_name

	local contentSize = self:getContentSize()
	local spriteRefName = 'frame_'..self.mid_name..'_0000'
	local framName = 'frame_'..self.mid_name..'_%04d'
	local hue, saturation, brightness, contrast = 0, 0, 0, 0
	if fireworkInfo.fireworkType == FireworkType.kPurple then 

	elseif fireworkInfo.fireworkType == FireworkType.kGreen then 
		hue = -0.8752
		saturation = 0.2692

	elseif fireworkInfo.fireworkType == FireworkType.kYellow then
		hue = 0.6666
		saturation = 0.8906
		brightness = 0.1871
	elseif fireworkInfo.fireworkType == FireworkType.kBlue then
		hue = -0.5758
		saturation = 0.2476
	end

	saturation = saturation + 0.5

	self.firework = SpriteColorAdjust:createWithSpriteFrameName(spriteRefName)
	self.firework:adjustColor(hue, saturation, brightness, contrast)
	self.firework:applyAdjustColorShader()
	-- local blendFunc = ccBlendFunc()
	-- blendFunc.src = GL_SRC_ALPHA
	-- -- -- blendFunc.dst = GL_ONE -- 增强
	-- -- blendFunc.dst = GL_ONE_MINUS_SRC_COLOR -- 略微增强
	-- blendFunc.dst = GL_ONE_MINUS_SRC_ALPHA -- 基本混合
	-- self.firework.refCocosObj:setBlendFunc(blendFunc)

	self:addChild(self.firework)
	self.firework:setVisible(false)
	self.firework:setPosition(ccp(contentSize.width*anchorPointX, contentSize.height*anchorPointY))

	self:setScale(0.4)
	self:setAnchorPoint(ccp(anchorPointX, anchorPointY))

	--转向
	if self.fromPos.x ~= self.endPos.x then
		local rotation = math.atan((self.endPos.x - self.fromPos.x) / math.abs(self.endPos.y - self.fromPos.y)) * 180 / 3.14
		self:setRotation(rotation)
	end

	local flyX = self.endPos.x - self.fromPos.x
	local flyY = self.endPos.y - self.fromPos.y
	local flyDistance = math.sqrt(flyX*flyX + flyY*flyY)
	local flyTime = flyDistance/speed

	local seqArr = CCArray:create()
	local spawnArr = CCArray:create()
	spawnArr:addObject(CCMoveBy:create(flyTime, ccp(flyX, flyY)))
	spawnArr:addObject(CCScaleTo:create(flyTime, self.fireworkScale))
	seqArr:addObject(CCSpawn:create(spawnArr))
	seqArr:addObject(CCFadeTo:create(0.1, 0))
	seqArr:addObject(CCCallFunc:create(function ()
		if self.isDisposed then return end
		local framecount = 46
		if self.mid_name == 'simple' then
			framecount = 25
		end
		local frames = SpriteUtil:buildFrames(framName, 0, framecount)
		local animate = SpriteUtil:buildAnimate(frames, 1/60)
		self.firework:setVisible(true)
		self.firework:play(animate, 0, 1, function ()
			self:removeFromParentAndCleanup(true)
			if endCallback then 
				endCallback()
			end
		end)
	end))
	self:runAction(CCSequence:create(seqArr))
end

--------------------------------------------------------
---------------SpringFireworkAnimation------------------
--------------------------------------------------------
SpringFireworkAnimation = class(CocosObject)
local visibleSize = Director.sharedDirector():getVisibleSize()
local visibleOrigin = Director.sharedDirector():getVisibleOrigin()

function SpringFireworkAnimation:playMarkPanelAnim(crackerIndex, fromPos, finishCallback)
	local vs = Director:sharedDirector():getVisibleSize()
	local vo = Director:sharedDirector():getVisibleOrigin()
	local config = 
	{
		{'simple', 'simple'},
		{'simple', 'simple', 'chick'},
		{'simple', 'chick', 'simple', 'chick'},
		{'simple', 'chick', 'simple', 'chick', 'chick'},
	}
	crackerIndex = crackerIndex or 1
	local _config = config[crackerIndex]
	local counter = 0
	local total = #_config
	local function callback()
		counter = counter + 1
		if counter >= total then
			if finishCallback then
				finishCallback()
			end
		end
	end

	local function stopTimer()
		if self.markpanel_schedule then 
			Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.markpanel_schedule)
		end
		self.markpanel_schedule = nil
	end

	local index = 1
	local function timerFunc()
		if index > #_config then
			stopTimer()
			return
		end
		if self.isDisposed then return end
		local runningScene = Director:sharedDirector():getRunningScene()
		if runningScene == HomeScene:sharedInstance() then
			local fireworkInfo = {}
			fireworkInfo.fireworkType = math.floor(math.random(1, 4))
			fireworkInfo.mid_name = _config[index]
			fireworkInfo.fromPos = fromPos
			fireworkInfo.endPos = ccp(fromPos.x+math.random(-100,100), fromPos.y + 100*crackerIndex)
			fireworkInfo.fireworkScale = 1
			local firework = SpringFirework:create(fireworkInfo, callback)
			self.mainSprite:addChild(firework)
			firework:setPosition(fromPos)

			local fireworkIndex = math.floor(math.random(1, 5))
			GamePlayMusicPlayer:playEffect(GameMusicType["kSpringFirework"..fireworkIndex])
			index = index + 1
		end
	end

	if not self.markpanel_schedule then 
		self.markpanel_schedule = Director:sharedDirector():getScheduler():scheduleScriptFunc(timerFunc, 0.5, false)
	end

end

function SpringFireworkAnimation:create()
	local s = SpringFireworkAnimation.new(CCNode:create())
	s:init()
	return s
end

function SpringFireworkAnimation:init()
	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(getRealPlistPath("flash/scenes/flowers/spring/firework.plist"))
	self.mainSprite = Sprite:createEmpty()
	self:addChild(self.mainSprite)
end

function SpringFireworkAnimation:playPassLevelFirework(fireworkInfo)
	if self.isDisposed then return end
	
	local child = SpringFirework:create(fireworkInfo)
	self.mainSprite:addChild(child)
	child:setPosition(fireworkInfo.fromPos)
end

function SpringFireworkAnimation:playLongTimeFirework()
	if self.isDisposed then return end

	-- debug.debug()
	local function timerFunc()
		if self.isDisposed then return end

		local runningScene = Director:sharedDirector():getRunningScene()
		if runningScene == HomeScene:sharedInstance() then

			local fireworkInfo = {}
			--音效
			local fireworkIndex = math.floor(math.random(1, 5))
			local midNames = {'simple', 'chick'}
			fireworkInfo.mid_name = midNames[(fireworkIndex%2+1)]

			fireworkInfo.fireworkType = math.floor(math.random(1, 4))
			fireworkInfo.fireworkScale = math.random(1, 2)
			local randomStartX = math.random(-400, 400)
			if randomStartX < 0 and randomStartX > -100 then 
				randomStartX = randomStartX - 100
			elseif randomStartX >= 0 and randomStartX < 100 then
				randomStartX = randomStartX + 100
			end
			startPosX = 360 + randomStartX
			local endPosX = math.random(startPosX*0.8, startPosX*1.2)
			while(endPosX > 260 and endPosX < 460) do 
				endPosX = math.random(startPosX*0.8, startPosX*1.2)
			end
			fireworkInfo.fromPos = ccp(startPosX, math.random(0, 400))
			fireworkInfo.endPos = ccp(endPosX, math.random(700, 1150))

			local child = SpringFirework:create(fireworkInfo)
			self.mainSprite:addChild(child)
			child:setPosition(fireworkInfo.fromPos)
			GamePlayMusicPlayer:playEffect(GameMusicType["kSpringFirework"..fireworkIndex])
		end
	end

	if not self.schedule then 
		self.schedule = Director:sharedDirector():getScheduler():scheduleScriptFunc(timerFunc, 30, false)
	end
end

function SpringFireworkAnimation:stopLongTimeFirework()
	if self.schedule then 
		Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedule)
	end
	self.schedule = nil
end

function SpringFireworkAnimation:playLongTimeFireworkNF()
	if self.isDisposed then return end
	local waitTime = 0
	local function timerFunc()
		if self.isDisposed then return end
		if waitTime > 0 then 
			waitTime = waitTime - 1
			return 
		end
		waitTime = math.random(2, 5)
		local fireworkType = math.floor(math.random(1, 4))
		local scale = 0.9 + math.random(1, 10) * 0.04
		local rotation = math.random(-30, 30)

		local halfTrunkWidth = 200
		local endPosX = math.random(50, visibleSize.width - 50)
		if endPosX < visibleSize.width/2 and endPosX > visibleSize.width/2 - halfTrunkWidth then
			endPosX = math.max(endPosX - halfTrunkWidth, 50)
		elseif endPosX > visibleSize.width/2 and endPosX < visibleSize.width/2 + halfTrunkWidth then
			endPosX = math.min(endPosX + halfTrunkWidth, visibleSize.width - 50)
		end
		local endPosY = math.random(visibleSize.height - 650, visibleSize.height - 200)

		local child = SpringFireworkNF:create(fireworkType)
		child:setScale(scale)
		child:setRotation(rotation)
		self.mainSprite:addChild(child)
		child:setPosition(ccp(endPosX, endPosY))
	end
	if not self.scheduleNF then 
		self.scheduleNF = Director:sharedDirector():getScheduler():scheduleScriptFunc(timerFunc, 1, false)
	end
end

function SpringFireworkAnimation:stopLongTimeFireworkNF()
	if self.scheduleNF then 
		Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduleNF)
	end
	self.scheduleNF = nil
end

-- function SpringFireworkAnimation:playClickedFireworkSmall(oriPos)
-- 	if oriPos then 
-- 		local posYMax = visibleOrigin.y + visibleSize.height
-- 		local fireworkInfo = {}
-- 		fireworkInfo.fireworkType = math.floor(math.random(1, 4))
-- 		fireworkInfo.fireworkScale = 2
-- 		fireworkInfo.fromPos = ccp(oriPos.x, oriPos.y)
-- 		fireworkInfo.endPos = ccp(oriPos.x, math.random(posYMax - 200, posYMax - 100))

-- 		local child = SpringFirework:create(fireworkInfo)
-- 		self.mainSprite:addChild(child)
-- 		child:setPosition(fireworkInfo.fromPos)

-- 		local fireworkIndex = math.floor(math.random(1, 5))
-- 		GamePlayMusicPlayer:playEffect(GameMusicType["kSpringFirework"..fireworkIndex])
-- 	end
-- end

function SpringFireworkAnimation:playClickedFireworkSmall(oriPos)
	local posYMax = visibleOrigin.y + visibleSize.height

	local function stopTimer()
		if self.clickedSmallSchedule then 
			Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.clickedSmallSchedule)
		end
		self.clickedSmallSchedule = nil
	end

	local fIndex = 1
	local function clickedTimerFunc()
		if self.isDisposed then return end

		local runningScene = Director:sharedDirector():getRunningScene()
		if runningScene == HomeScene:sharedInstance() then
			local fireworkInfo = {}
			fireworkInfo.fireworkType = math.floor(math.random(1, 4))
			local endPos = ccp(oriPos.x, posYMax - 150)
			local chick_name = 'chick'
			local simple_name = 'simple'
			if fIndex == 1 then 
				fireworkInfo.fireworkType = 1
				fireworkInfo.fireworkScale = 1.5
				fireworkInfo.mid_name = chick_name
			elseif fIndex == 2 then 
				fireworkInfo.fireworkType = 2
				fireworkInfo.fireworkScale = 1.5
				fireworkInfo.mid_name = simple_name
				endPos = ccp(endPos.x + 120, endPos.y - 75)
			elseif fIndex == 3 then 
				fireworkInfo.fireworkType = 3
				fireworkInfo.fireworkScale = 1.5
				fireworkInfo.mid_name = simple_name
				endPos = ccp(endPos.x - 150, endPos.y - 100)
			elseif fIndex == 4 then 
				fireworkInfo.fireworkType = 4
				fireworkInfo.fireworkScale = 2
				fireworkInfo.mid_name = chick_name
				endPos = ccp(endPos.x + 100, endPos.y)
			end
			fireworkInfo.fromPos = ccp(oriPos.x, oriPos.y)
			fireworkInfo.endPos = ccp(endPos.x, endPos.y)

			local child = SpringFirework:create(fireworkInfo)
			self.mainSprite:addChild(child)
			child:setPosition(fireworkInfo.fromPos)

			local fireworkIndex = math.floor(math.random(1, 5))
			GamePlayMusicPlayer:playEffect(GameMusicType["kSpringFirework"..fireworkIndex])
		else
			stopTimer()
		end

		fIndex = fIndex + 1
		if fIndex > 4 then 
			stopTimer()
		end
	end

	if oriPos and not self.clickedSmallSchedule then 
		self.clickedSmallSchedule = Director:sharedDirector():getScheduler():scheduleScriptFunc(clickedTimerFunc, 0.25, false)
		clickedTimerFunc()
	end
end

function SpringFireworkAnimation:playClickedFireworkBig(oriPos)
	-- debug.debug()
	local posYMax = visibleOrigin.y + visibleSize.height

	local function stopTimer()
		if self.clickedBigSchedule then 
			Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.clickedBigSchedule)
		end
		self.clickedBigSchedule = nil
	end

	local fIndex = 1
	local counter = 1
	local function clickedTimerFunc()
		if self.isDisposed then return end

		local runningScene = Director:sharedDirector():getRunningScene()
		if runningScene == HomeScene:sharedInstance() then
			local fireworkInfo = {}
			-- fireworkInfo.fireworkType = math.floor(math.random(1, 4))
			local index = counter % 4
			if index == 0 then index = 4 end
			fireworkInfo.fireworkType = index
			counter = counter + 1
			local endPos = ccp(oriPos.x, posYMax - 200)
			local chick_name = 'chick'
			local simple_name = 'simple'
			if fIndex == 1 then 
				fireworkInfo.fireworkType = FireworkType.kPurple
				fireworkInfo.fireworkScale = 1.3
				fireworkInfo.mid_name = chick_name
				endPos = ccp(endPos.x + 150, endPos.y)
			elseif fIndex == 2 then 
				fireworkInfo.fireworkType = FireworkType.kYellow
				fireworkInfo.fireworkScale = 0.7
				endPos = ccp(endPos.x , endPos.y + 100)
				fireworkInfo.mid_name = simple_name
			elseif fIndex == 3 then 
				fireworkInfo.fireworkType = FireworkType.kBlue
				fireworkInfo.fireworkScale = 1.3
				endPos = ccp(endPos.x - 200, endPos.y + 100)
				fireworkInfo.mid_name = chick_name
			elseif fIndex == 4 then 
				fireworkInfo.fireworkType = FireworkType.kGreen
				fireworkInfo.fireworkScale = 0.7
				endPos = ccp(endPos.x + 150, endPos.y - 100)
				fireworkInfo.mid_name = simple_name
			elseif fIndex == 5 then 
				fireworkInfo.fireworkType = FireworkType.kPurple
				fireworkInfo.fireworkScale = 0.7
				endPos = ccp(endPos.x - 200, endPos.y - 100)
				fireworkInfo.mid_name = simple_name
			elseif fIndex == 6 then 
				fireworkInfo.fireworkType = FireworkType.kYellow
				fireworkInfo.fireworkScale = 2
				endPos = ccp(endPos.x, endPos.y + 50)
				fireworkInfo.mid_name = chick_name
			end
			fireworkInfo.fromPos = ccp(oriPos.x, oriPos.y)
			fireworkInfo.endPos = ccp(endPos.x, endPos.y)

			local child = SpringFirework:create(fireworkInfo)
			self.mainSprite:addChild(child)
			child:setPosition(fireworkInfo.fromPos)

			local fireworkIndex = math.floor(math.random(1, 5))
			GamePlayMusicPlayer:playEffect(GameMusicType["kSpringFirework"..fireworkIndex])
		else
			stopTimer()
		end

		fIndex = fIndex + 1
		if fIndex > 6 then 
			stopTimer()
		end
	end

	if oriPos and not self.clickedBigSchedule then 
		self.clickedBigSchedule = Director:sharedDirector():getScheduler():scheduleScriptFunc(clickedTimerFunc, 0.25, false)
		clickedTimerFunc()
	end
end

--------------------------------------------------------
---------------ClickedFireworkAnimation------------------
--------------------------------------------------------
ClickedFireworkAnimation = class(CocosObject)

function ClickedFireworkAnimation:create()
	local s = ClickedFireworkAnimation.new(CCNode:create())
	s:init()
	return s
end

function ClickedFireworkAnimation:init()
	local bigFireworkPos = ccp(500, 380)
	local smallFireworkPos = ccp(380, 380)

	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(getRealPlistPath("flash/scenes/homeScene/home_night/clicked_firework.plist"))


	local function onLayerColorTouch(evt)
		local touchLayer = evt.context
		if touchLayer then 
			touchLayer:setTouchEnabled(false)
			if touchLayer.lIndex == 1 then 
				if self.clickedFireworkBig then
					local animate = SpriteUtil:buildAnimate(SpriteUtil:buildFrames('clicked_firework_one_%04d', 16, 17), 1/24)
					self.clickedFireworkBig:stopAllActions()
    				self.clickedFireworkBig:play(animate, 0, 1, function ()
    					if self.clickedFireworkBig then 
    						self.clickedFireworkBig:removeFromParentAndCleanup(true)
    						self.clickedFireworkBig = nil
    					end
    					local scene = HomeScene:sharedInstance()
    					if scene and scene.homeSceneFireworkLayer then 
    						local worldPos = self:convertToWorldSpace(ccp(bigFireworkPos.x, bigFireworkPos.y))
    						scene.homeSceneFireworkLayer:playClickedFireworkBig(worldPos)
    					end
    				end)
				end
			elseif touchLayer.lIndex == 2 then 
				if self.clickedFireworkSmall then 
					local animate = SpriteUtil:buildAnimate(SpriteUtil:buildFrames('clicked_firework_two_%04d', 16, 16), 1/24)
					self.clickedFireworkSmall:stopAllActions()
    				self.clickedFireworkSmall:play(animate, 0, 1, function ()
    					if self.clickedFireworkSmall then 
    						self.clickedFireworkSmall:removeFromParentAndCleanup(true)
    					end
    					local scene = HomeScene:sharedInstance()
    					if scene and scene.homeSceneFireworkLayer then 
    						local worldPos = self:convertToWorldSpace(ccp(smallFireworkPos.x, smallFireworkPos.y))
    						scene.homeSceneFireworkLayer:playClickedFireworkSmall(worldPos)
    					end
    				end)
				end
			end
		end
	end

	if not self.clickedFireworkBig then 
		self.clickedFireworkBig = Sprite:createWithSpriteFrameName('clicked_firework_one_0000')
		self:addChild(self.clickedFireworkBig)
		self.clickedFireworkBig:setPosition(ccp(bigFireworkPos.x, bigFireworkPos.y))

		local animate = SpriteUtil:buildAnimate(SpriteUtil:buildFrames('clicked_firework_one_%04d', 0, 16), 1/24)
    	self.clickedFireworkBig:play(animate)

    	local touchLayer = LayerColor:create()
    	touchLayer.lIndex = 1
	    touchLayer:setAnchorPoint(ccp(0, 0))
	    touchLayer:setColor(ccc3(255,0,0))
	    touchLayer:changeWidthAndHeight(60, 60)
	  	touchLayer:setOpacity(0)
	  	self.clickedFireworkBig:addChild(touchLayer)
	  	touchLayer:setPosition(ccp(12,10))
	  	touchLayer:setTouchEnabled(true, 0, true)
		touchLayer:addEventListener(DisplayEvents.kTouchTap, onLayerColorTouch, touchLayer)
	end

	if not self.clickedFireworkSmall then 
		self.clickedFireworkSmall = Sprite:createWithSpriteFrameName('clicked_firework_two_0000')
		self:addChild(self.clickedFireworkSmall)
		self.clickedFireworkSmall:setPosition(ccp(smallFireworkPos.x, smallFireworkPos.y))

		local animate = SpriteUtil:buildAnimate(SpriteUtil:buildFrames('clicked_firework_two_%04d', 0, 16), 1/24)
    	self.clickedFireworkSmall:play(animate)

    	touchLayer = LayerColor:create()
    	touchLayer.lIndex = 2
	    touchLayer:setAnchorPoint(ccp(0, 0))
	    touchLayer:setColor(ccc3(255,0,0))
	    touchLayer:changeWidthAndHeight(50, 50)
	  	touchLayer:setOpacity(0)
	  	self.clickedFireworkSmall:addChild(touchLayer)
	  	touchLayer:setPosition(ccp(0,0))
	  	touchLayer:setTouchEnabled(true, 0, true)
	  	touchLayer:addEventListener(DisplayEvents.kTouchTap, onLayerColorTouch, touchLayer)
	end
end
