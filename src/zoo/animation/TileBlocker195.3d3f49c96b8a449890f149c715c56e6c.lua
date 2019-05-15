--星星瓶
TileBlocker195 = class(CocosObject)

Blocker195AnimateState = {
	kNone = 0,
	kEmpty = 1,
	kCollect = 2,
	kFull = 3,
}

local AnimationTimePerFrame = 1 / 36

function TileBlocker195:create(collect, percent, isFull)
	local node = TileBlocker195.new(CCNode:create())
	node.name = 'blocker195'
	node:_init(collect, percent, isFull)
	node:setScale(0.95)
	return node
end

function TileBlocker195:playCollectAnimation(percent)
	if self.percent ~= 1 then
		if percent and  percent > 1 then percent = 1 end
		self.percent = percent
		if self.state == Blocker195AnimateState.kEmpty then
			self:_initCollect()
		end

		self.water.updateWaterPercentTo(self.percent, true)
	end

	if self.percent == 1 then
		local function callback()
			-- printx( 1 , "TileBlocker195:playCollectAnimation  callback")
			if not self.isDisposed then
				self:playFullAnimation()
			end
		end

		setTimeOut( callback , 1 )
		-- local actSeq = CCArray:create()
		-- actSeq:addObject(CCDelayTime:create(1))
		-- actSeq:addObject(CCCallFunc:create(callback))
		-- printx( 1 , "TileBlocker195:playCollectAnimation  runAction")
		-- self:runAction(CCSequence:create(actSeq))

	end
end

function TileBlocker195:playCollectLight1Animation(deltaPos, callback)
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
	local spriteName = "blocker195_light"

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

function TileBlocker195:playCollectLight2Animation(percent)
	local animation = self:_initAnimation('blocker195_collect_light', 12, AnimationTimePerFrame, 1)
	animation:setPosition(ccp(-5, 0))
	self:addChild(animation)
end

function TileBlocker195:playFullAnimation()
	--self:removeChildren(true)
	local transitionAnimation = self:_initAnimation('blocker195_transition', 14, nil, 1)
	self:addChild(transitionAnimation)

	local function callback()
		if not self.isDisposed then
			if self.full and not self.full.isDisposed then
				self:removeChild(self.full)
			end
			self:_initFull()
		end
	end

	setTimeOut( callback , 0.2 )
	-- local actSeq = CCArray:create()
	-- actSeq:addObject(CCDelayTime:create(0.2))
	-- actSeq:addObject(CCCallFunc:create(callback))
	-- self:runAction(CCSequence:create(actSeq))
end

function TileBlocker195:playDestroyAnimation()
	local animation = self:_initAnimation('blocker195_disappear', 28, nil, 1)
	if animation then self:removeChildren(true) end
	self:addChild(animation)
end

function TileBlocker195:playJoinAnimation(startPoint, endPoint)
	local layer = Layer:create()
	local animation = self:_initAnimation('blocker195_fly', 23, AnimationTimePerFrame)
	local angle = -math.deg(math.atan2(endPoint.y - startPoint.y, endPoint.x - startPoint.x))
	local function finishCallback()
		layer:removeFromParentAndCleanup(true) 
	end

	animation:setPosition(startPoint)
	animation:setRotation(angle)
	animation:setAnchorPoint(ccp(0.8, 0.46))

	local actArr = CCArray:create()
	actArr:addObject(CCMoveTo:create( 0.4, ccp( endPoint.x , endPoint.y ) ) )
	actArr:addObject(CCDelayTime:create(0.5))
	actArr:addObject(CCCallFunc:create(finishCallback) )
	animation:runAction(CCSequence:create(actArr))

	layer:addChild(animation)

	return layer
end

function TileBlocker195:_init(collect, percent, isFull)
	--assert(collect, "TileBlocker195:init collect is nil!")
	self.collect = collect
	self.percent = percent
	self.isFull = isFull
	self:removeChildren(true)

	if self.isFull then 
		self:_initFull()
	elseif self.percent <= 0 then
		self:_initEmpty()
	else
		self:_initCollect()
		self.water.updateWaterPercentTo(self.percent)
	end
end

--空状态
function TileBlocker195:_initEmpty()
	local bgSprite = Sprite:createWithSpriteFrameName('blocker195_empty_bg')
	bgSprite:setPosition(ccp(0, -1))
	self:addChild(bgSprite)

	local collectSprite = Sprite:createWithSpriteFrameName(self.collect)
	collectSprite:setPosition(ccp(0, 2))
	self:addChild(collectSprite)

	local fgSprite = Sprite:createWithSpriteFrameName('blocker195_empty_fg')
	self:addChild(fgSprite)

	local lightAnimation = self:_initAnimation('blocker195_empty_light', 25)
	self:addChild(lightAnimation)

	self.state = Blocker195AnimateState.kEmpty
end

--收集状态
function TileBlocker195:_initCollect()
	local bgSprite = Sprite:createWithSpriteFrameName('blocker195_empty_bg')
	bgSprite:setPosition(ccp(0, -1))
	self:addChild(bgSprite)

	local collectSprite = Sprite:createWithSpriteFrameName(self.collect)
	collectSprite:setPosition(ccp(0, 2))
	self:addChild(collectSprite)

	self.water = self:_initWater()
	self:addChild(self.water)

	local fg2Sprite = Sprite:createWithSpriteFrameName('blocker195_empty_fg')
	self:addChild(fg2Sprite)

	local lightAnimation = self:_initAnimation('blocker195_empty_light', 25, AnimationTimePerFrame)
	self:addChild(lightAnimation)

	self.state = Blocker195AnimateState.kCollect
end

--满状态
function TileBlocker195:_initFull()
	local animation = self:_initAnimation('blocker195_full', 60)
	self.full = animation
	self:addChild(animation)

	self.state = Blocker195AnimateState.kFull
end

function TileBlocker195:_initAnimation(prefix, frame, framerate, playCount, callback)
	local resName = prefix .. '_0000'
	local sp = Sprite:createWithSpriteFrameName(resName)
	local frames, animate
	local aniName = prefix .. '_%04d'
	if not playCount then playCount = 0 end
	if not framerate then framerate = 1/24 end

	frames = SpriteUtil:buildFrames(aniName, 0, frame)
	animate = SpriteUtil:buildAnimate(frames, framerate)
	sp:play(animate, 0, playCount, function () if callback then callback() end end)

	return sp
end

function TileBlocker195:_initWater()
	local node = Sprite:createEmpty()

	local waterClippingNode = SimpleClippingNode:create()
	node:addChild(waterClippingNode)
	waterClippingNode:setAnchorPoint(ccp(0.5, 0))
	waterClippingNode:ignoreAnchorPointForPosition(false)
	waterClippingNode:setRecalcPosition(true)

	local waterSprite = Sprite:createWithSpriteFrameName('blocker195_collect_fg1')
	local waterSize = waterSprite:getGroupBounds().size
	local waterH = waterSize.height
	local clippingW = waterSize.width
	local clippingH = waterSize.height+2
	waterSprite:setPosition(ccp(clippingW/2, clippingH/2))

	waterClippingNode:addChild(waterSprite)

	waterClippingNode:setContentSize(CCSizeMake(clippingW, 0))
	waterClippingNode:setPosition(ccp(0, -clippingH/2))

	local riseAnimation = self:_initAnimation('blocker195_collect_rise', 30)
	riseAnimation:setPosition(ccp(30, 30))
	waterClippingNode:addChild(riseAnimation)

	-- Wave
	local waveMask = Sprite:createWithSpriteFrameName('blocker195_empty_bg')
	waveMask:setPosition(ccp(0, -1))
  	local waveClippingNode = ClippingNode.new(CCClippingNode:create(waveMask.refCocosObj))
  	waveMask:dispose()
	node:addChild(waveClippingNode)
	
	waveClippingNode:setInverted(false)
	waveClippingNode:setAnchorPoint(ccp(0.5, 0))
	waveClippingNode:ignoreAnchorPointForPosition(false)
	waveClippingNode:setAlphaThreshold(0.5)

	local waveSprite = Sprite:createWithSpriteFrameName('blocker195_collect_wave')
	waveSprite:setPosition(ccp(clippingW/2-50, 0))
	local waveSeq = CCArray:create()
	waveSeq:addObject(CCCallFunc:create(function() waveSprite:setPositionX(clippingW/2-50) end))
	waveSeq:addObject(CCMoveBy:create(50*AnimationTimePerFrame, ccp(50, 0)))
	waveSprite:runAction(CCRepeatForever:create(CCSequence:create(waveSeq)))
	waveClippingNode:addChild(waveSprite)

	node.updateWaterPercentTo = function(percent, hasAnimate)
		percent = percent or 0
		if percent > 1 then percent = 1 end
		-- 调整波浪的位置
		local targetPosY = -clippingH/2 + waterH*percent+1
		local targetHeight = waterH*percent+1
		node:unscheduleUpdate()
		if not hasAnimate then
			waterClippingNode:setContentSize(CCSizeMake(clippingW, targetHeight))
			waveSprite:setPositionY(targetPosY)
			if percent <= 0 or percent >= 1 then
				waveSprite:setVisible(false)
			else
				waveSprite:setVisible(true)
			end
		else
			waveSprite:setVisible(true)
			local totalTime = 0
			local animateTime = 20 * AnimationTimePerFrame
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