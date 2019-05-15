--寄居蟹
require "zoo.common.view.AnimationNumberText" 
TileBlocker211 = class(CocosObject)

local AnimationTimePerFrame = 1 / 30

function TileBlocker211:create(data)
	local node = TileBlocker211.new(CCNode:create())
	node.name = "blocker211"
	node:init(data)
	return node
end

function TileBlocker211:init(data)
	self.data = data
	self.colorIndex = AnimalTypeConfig.convertColorTypeToIndex(self.data._encrypt.ItemColorType)
	self:initIdleAnimation()
end

function TileBlocker211:initIdleAnimation()
	-- printx(5, 'TileBlocker211:initIdleAnimation')
	self.shellBG = Sprite:createWithSpriteFrameName('crab.shellBG')
	self:addChild(self.shellBG)

	self.shellLight = self:_initAnimation('crab.shellLight', 26)
	self.shellLight:setPosition(ccp(0, 4))
	self:addChild(self.shellLight)

	self.water = self:_initWater()
	self.water:setPosition(ccp(0, 4))
	self:addChild(self.water)

	self.idle = self:_initAnimation('crab.crabBody.idle.' .. self.colorIndex, 26, nil, nil, nil, 3)
	self.idle:setPosition(ccp(8, -12))
	self:addChild(self.idle)

	self.numberPlate = Sprite:createWithSpriteFrameName('crab.numberPlate.' .. self.colorIndex)
	self.numberPlate:setPosition(ccp(-20, -24))
	self:addChild(self.numberPlate)

	self.number = BitmapText:create(tostring(num), "fnt/prop_name.fnt")
	self.number:setPosition(ccp(-22, -22))
	self.number:setScale(0.5)
	self:addChild(self.number)
	self:_changeNumber(false)
end

function TileBlocker211:initFullAnimation()
	-- printx(5, 'TileBlocker211:initFullAnimation')
	if not self.shellReady then 
		self.shellReady = self:_initAnimation('crab.shell.ready.' .. self.colorIndex, 26)
		self.shellReady:setPosition(ccp(0, 4))
	end

	if not self.ready then
		self.ready = self:_initAnimation('crab.crabBody.ready.' .. self.colorIndex, 26)
		self.ready:setPosition(ccp(8, -12))
	end

	self:removeChildren(false)
	self:addChild(self.shellBG)
	self:addChild(self.shellLight)
	self:addChild(self.shellReady)
	self:addChild(self.ready)
	self:addChild(self.numberPlate)
	self:addChild(self.number)
end

function TileBlocker211:renewIdleAnimation(data)--恢复idle状态
	-- printx(5, 'TileBlocker211:renewIdleAnimation')
	if data then self.data = data end
	self:removeChildren(false)
	self:addChild(self.shellBG)
	self:addChild(self.shellLight)
	self:addChild(self.water)
	self:addChild(self.idle)
	self:addChild(self.numberPlate)
	self:addChild(self.number)

	self:_changeNumber(false)
end

function TileBlocker211:playCollectAnimation(data)--播放收集状态
	-- printx(5, 'TileBlocker211:playCollectAnimation')
	if data then self.data = data end
	self:removeChildren(false)
	if not self.charging then 
		self.charging = self:_initAnimation('crab.crabBody.charging.' .. self.colorIndex, 14)
		self.charging:setPosition(ccp(8, -12))
	end

	self:addChild(self.shellBG)
	self:addChild(self.shellLight)
	self:addChild(self.water)
	self:addChild(self.charging)
	self:addChild(self.numberPlate)
	self:addChild(self.number)

	self:_changeNumber(true)
end

function TileBlocker211:playExplodeAnimation(callback)
	-- printx(5, 'TileBlocker211:playExplodeAnimation')
	self.shellBlow = self:_initAnimation('crab.shell.blow.' .. self.colorIndex, 26, 1, 24, function()
		if self.shellBlow then
			self.shellBlow:removeFromParentAndCleanup(true)
			self.shellBlow = nil
		end
		if self.blow then
			self.blow:removeFromParentAndCleanup(true)
			self.blow = nil
		end
		if callback then callback() end
	end)
	self.shellBlow:setPosition(ccp(0, 4))

	self.blow = self:_initAnimation('crab.crabBody.blow.' .. self.colorIndex, 25, 1)
	self.blow:setPosition(ccp(8, 0))

	self:removeChildren(false)
	--self:addChild(self.shellBG)
	--self:addChild(self.shellLight)
	self:addChild(self.shellBlow)
	self:addChild(self.blow)
	self:addChild(self.numberPlate)
	self:addChild(self.number)
end

function TileBlocker211:playEmptyAnimation()
	-- printx(5, 'TileBlocker211:playEmptyAnimation')
	if not self.empty then
		self.empty = Sprite:createWithSpriteFrameName('crab.crabBody.revive.1_0000')
		self.empty:setPosition(ccp(8, -8))
	end

	self:removeChildren(false)
	self:addChild(self.shellBG)
	self:addChild(self.shellLight)
	--self:addChild(self.water)
	self:addChild(self.empty)
	self:addChild(self.numberPlate)
	self:addChild(self.number)
end

function TileBlocker211:playReinitAnimation()
	-- printx(5, 'TileBlocker211:playReinitAnimation')
	self.revive = self:_initAnimation('crab.crabBody.revive.' .. self.colorIndex, 10 , 1, 24, function()
		self:renewIdleAnimation() 
	end)
	self.revive:setPosition(ccp(8, -12))
	
	self:removeChildren(false)
	self:addChild(self.shellBG)
	self:addChild(self.shellLight)
	self:addChild(self.water)
	self:addChild(self.revive)
	self:addChild(self.numberPlate)
	self:addChild(self.number)

	self:_changeNumber(false)
end

function TileBlocker211:playEffect1Animation(startPoint, endPoint, callback)
	-- printx(5, 'TileBlocker211:playEffect1Animation')
	local layer = Sprite:createEmpty()
	local tempSprite = Sprite:createWithSpriteFrameName("crab.effect.1_0000")
	local texture = tempSprite:getTexture()
  	layer:setTexture(texture)
  	tempSprite:dispose()
	local animation = self:_initAnimation('crab.effect.1', 9, 1, 45, function()
		layer:removeFromParentAndCleanup(true) 
		if callback then callback() end
	end)
	local angle = - math.deg(math.atan2(endPoint.y - startPoint.y, endPoint.x - startPoint.x))
	animation:setPosition(startPoint)
	animation:setRotation(angle)
	animation:setAnchorPoint(ccp(0, 0.5))
	layer:addChild(animation)

	return layer
end

function TileBlocker211:playEffect2Animation(startPoint)
	-- printx(5, 'TileBlocker211:playEffect2Animation')
	local layer = Sprite:createEmpty()
	local tempSprite = Sprite:createWithSpriteFrameName("crab.effect.2_0000")
	local texture = tempSprite:getTexture()
  	layer:setTexture(texture)
  	tempSprite:dispose()
	local animation = self:_initAnimation('crab.effect.2', 14, 1, 45, function()
		layer:removeFromParentAndCleanup(true) 
	end)
	animation:setPosition(startPoint)
	layer:addChild(animation)

	return layer
end

function TileBlocker211:dispose()
	if self.shellBG then self.shellBG:dispose() end
	if self.shellLight then self.shellLight:dispose() end
	if self.water then self.water:dispose() end
	if self.idle then self.idle:dispose() end
	if self.numberPlate then self.numberPlate:dispose() end
	if self.number then self.number:dispose() end
	if self.shellReady then self.shellReady:dispose() end
	if self.ready then self.ready:dispose() end
	if self.charging then self.charging:dispose() end
	if self.shellBlow then self.shellBlow:dispose() end
	if self.blow then self.blow:dispose() end
	if self.empty then self.empty:dispose() end
	if self.revive then self.revive:dispose() end
	CocosObject.dispose(self)
end

function TileBlocker211:_changeNumber(hasAnimate)--更新收集量
	local num = self.data.subtype - self.data.level
	self.number:setText(num)
	self.water.updateWaterPercentTo(self.data.level / self.data.subtype, hasAnimate)
end

function TileBlocker211:_initAnimation(prefix, frame, playCount, framerate, callback, delay)
	local resName = prefix .. '_0000'
	local sp = Sprite:createWithSpriteFrameName(resName)
	local frames, animate
	local aniName = prefix .. '_%04d'
	if framerate == nil then framerate = 24 end
	if not playCount then playCount = 0 end

	frames = SpriteUtil:buildFrames(aniName, 0, frame)
	animate = SpriteUtil:buildAnimate(frames, 1 / framerate)
	if delay then 
		sp:play(CCSequence:createWithTwoActions(CCDelayTime:create(delay), animate), 0, playCount, function () if callback then callback() end end)
	else
		sp:play(animate, 0, playCount, function () if callback then callback() end end)
	end

	return sp
end

function TileBlocker211:_initWater()
	local node = Sprite:createEmpty()

	local waterClippingNode = SimpleClippingNode:create()
	node:addChild(waterClippingNode)
	waterClippingNode:setAnchorPoint(ccp(0.5, 0))
	waterClippingNode:ignoreAnchorPointForPosition(false)
	waterClippingNode:setRecalcPosition(true)

	local waterSprite = Sprite:createWithSpriteFrameName('crab.shellProgress.' .. self.colorIndex)
	local waterSize = waterSprite:getGroupBounds().size
	local waterH = waterSize.height
	local clippingW = waterSize.width
	local clippingH = waterSize.height+2
	waterSprite:setPosition(ccp(clippingW/2, clippingH/2))

	waterClippingNode:addChild(waterSprite)

	waterClippingNode:setContentSize(CCSizeMake(clippingW, 0))
	waterClippingNode:setPosition(ccp(0, -clippingH/2))

	-- Wave
	local waveMask = Sprite:createWithSpriteFrameName('crab.shellProgress.' .. self.colorIndex)
	waveMask:setPosition(ccp(0, -1))
  	local waveClippingNode = ClippingNode.new(CCClippingNode:create(waveMask.refCocosObj))
  	if _G.board_snapshot_mode then -- 截图出现的鬼畜情况
	  	waveMask:setVisible(false)
	end
  	waveMask:dispose()
	node:addChild(waveClippingNode)
	
	waveClippingNode:setInverted(false)
	waveClippingNode:setAnchorPoint(ccp(0.5, 0))
	waveClippingNode:ignoreAnchorPointForPosition(false)
	waveClippingNode:setAlphaThreshold(0.5)

	local waveSprite = Sprite:createWithSpriteFrameName('crab.shellProgress.line')
	waveSprite:setPosition(ccp(clippingW / 2 - 31, 0))
	--[[local waveSeq = CCArray:create()
	waveSeq:addObject(CCCallFunc:create(function() waveSprite:setPositionX(clippingW/2-50) end))
	waveSeq:addObject(CCMoveBy:create(50*AnimationTimePerFrame, ccp(50, 0)))
	waveSprite:runAction(CCRepeatForever:create(CCSequence:create(waveSeq)))]]
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
					if percent >= 1 then self:initFullAnimation() end
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