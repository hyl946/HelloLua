PumpkinExplode = class(Layer)

local winSize = Director:sharedDirector():getVisibleSize()
local origin = Director:sharedDirector():getVisibleOrigin()

function PumpkinExplode:ctor()
	self.dropItemTable = {}
end

function PumpkinExplode:initLayer()
	Layer.initLayer(self)
	self:setTouchEnabled(true, 0, true)
	-- -----test-----
	-- self:addEventListener(DisplayEvents.kTouchTap, function ()
	-- 	self:removeFromParentAndCleanup(true)
	-- end)
	-- --------------
	local scene = Director:sharedDirector():getRunningScene()
	self:setPositionXY(origin.x, origin.y)
	scene:addChild(self)

	local greyCover = LayerColor:create()
    greyCover:setColor(ccc3(0,0,0))
    greyCover:setOpacity(0)
    greyCover:setContentSize(CCSizeMake(winSize.width, winSize.height))
    greyCover:setPosition(ccp(0, 0))
    self:addChild(greyCover)
    self.greyCover = greyCover

	local pumpkinMakerPos = HalloweenAnimation:getInstance():getPumpkinCenterWorldPos()
	local locatePos = self:convertToNodeSpace(ccp(pumpkinMakerPos.x, pumpkinMakerPos.y)) 

	self.pumpkinLight1 = Sprite:createWithSpriteFrameName("pumpkin_light_1.png")
	self.pumpkinLight1:setAnchorPoint(ccp(0.5, 0.5))
	self.pumpkinLight1:setRotation(150)
	self.pumpkinLight1:setOpacity(0)
	self.pumpkinLight2 = Sprite:createWithSpriteFrameName("pumpkin_light_2.png")
	self.pumpkinLight2:setAnchorPoint(ccp(0.5, 0.5))
	self.pumpkinLight2:setOpacity(0)
	self:addChild(self.pumpkinLight1)
	self.pumpkinLight1:setPosition(ccp(locatePos.x + 5, locatePos.y - 250))
	self:addChild(self.pumpkinLight2)
	self.pumpkinLight2:setPosition(ccp(locatePos.x + 5, locatePos.y - 250))

	self.pumpkinStar = Sprite:createWithSpriteFrameName("pumpkin_star_0000.png")
	self.pumpkinStar:setScale(2)
	local pumpkinStarFrame = SpriteUtil:buildFrames("pumpkin_star_%04d.png", 0, 11)
	self.pumpkinStarAnimate = SpriteUtil:buildAnimate(pumpkinStarFrame, 1/24)
	self.pumpkinStarAnimate:retain()
	self:addChild(self.pumpkinStar)
	self.pumpkinStar:setPosition(ccp(locatePos.x + 5, locatePos.y - 250))

    self.pumpkinSprite1 = Sprite:createWithSpriteFrameName("boss_pumpkin_die1_0000.png")
    self.pumpkinSprite1:setScale(2)
	local pumpkinFrames1 = SpriteUtil:buildFrames("boss_pumpkin_die1_%04d.png", 0, 9)
	self.pumpkinAnimate1 = SpriteUtil:buildAnimate(pumpkinFrames1, 1/24)
	self.pumpkinAnimate1:retain()
	self:addChild(self.pumpkinSprite1)
	self.pumpkinSprite1:setPosition(ccp(locatePos.x, locatePos.y + 90))

	self.pumpkinSprite2 = Sprite:createWithSpriteFrameName("boss_pumpkin_die2_0000.png")
	local size = self.pumpkinSprite2:getContentSize()
	local pumpkinFrames2 = SpriteUtil:buildFrames("boss_pumpkin_die2_%04d.png", 0, 13)
	self.pumpkinAnimate2 = SpriteUtil:buildAnimate(pumpkinFrames2, 1/24)
	self.pumpkinAnimate2:retain()

	self.pumpkinContainer = LayerColor:create()
    self.pumpkinContainer:setColor(ccc3(255,0,0))
    self.pumpkinContainer:setOpacity(0)
    self.pumpkinContainer:setAnchorPoint(ccp(0.4, 0.1))
    self.pumpkinContainer:setContentSize(CCSizeMake(size.width, size.height))
    self.pumpkinContainer:addChild(self.pumpkinSprite2)
    self.pumpkinSprite2:setPosition(ccp(size.width/2, size.height/2))
    self:addChild(self.pumpkinContainer)
    self.pumpkinContainer:setPosition(ccp(locatePos.x - size.width/2 + 40, locatePos.y - size.height/2 - 120))
	self.pumpkinContainer:setVisible(false)

	local pumpkinNum = self.targetItemCount
	local xDeltaTable = self:getXdeltaTable(pumpkinNum)
	for i=1,pumpkinNum do
		local pumpkin = nil
		-- if i == pumpkinNum then 
		-- 	pumpkin = Sprite:createWithSpriteFrameName("pumpkin_boss_icon.png")
		-- 	pumpkin.name = "pumpkin_maker"
		-- else
			pumpkin = Sprite:createWithSpriteFrameName("dig_pumpkin_0000")
			pumpkin.name = "pumpkin"

			local scaleX = math.random(1, 10)/10 + 1
			local scaleY = scaleX
			if math.random(0, 1) >= 0.5 then 
				scaleX = -scaleX
			end
			pumpkin.scaleX = scaleX
			pumpkin:setScaleX(scaleX)
			pumpkin:setScaleY(scaleY)
			pumpkin.rotation = math.random(-50, 50)
			pumpkin:setRotation(pumpkin.rotation)
		-- end
		pumpkin.oriPosX = winSize.width/2 + math.random(-30, 30)
		pumpkin.oriPosY = winSize.height/2 + (50 + math.random(-20, 20))
		
		local num = #xDeltaTable
		local xDeltaIndex = math.random(1, num)
		pumpkin.xDelta = table.remove(xDeltaTable, xDeltaIndex)
		
		pumpkin.yDelta = math.random(-200, -250)
		pumpkin.height = math.random(35,60)
		pumpkin.bounceHeight = (pumpkin.height + math.abs(pumpkin.yDelta))/5
		pumpkin.delayTime = math.random(10,20)/10
		pumpkin.time = math.random(5,10)/10
		pumpkin.flyDelayTime = (pumpkin.time + pumpkin.delayTime)/2 + 0.3

		pumpkin:setPosition(ccp(pumpkin.oriPosX, pumpkin.oriPosY))
		table.insert(self.dropItemTable, pumpkin)
		pumpkin:setOpacity(0)
		self:addChild(pumpkin)
	end
end

function PumpkinExplode:playBgLightAnimation()
	local spwanArr = CCArray:create()
	spwanArr:addObject(CCFadeTo:create(0.2, 255))
	spwanArr:addObject(CCScaleTo:create(0.2, 2.2))
	self.pumpkinLight1:runAction(CCSpawn:create(spwanArr))
	self.pumpkinLight1:runAction(CCRepeatForever:create(CCRotateBy:create(0.1, 10)))

	local spwanArr1 = CCArray:create()
	spwanArr1:addObject(CCFadeTo:create(0.4, 255))
	spwanArr1:addObject(CCScaleTo:create(0.4, 2.4))
	local spwanArr2 = CCArray:create()
	spwanArr2:addObject(CCFadeTo:create(0.4, 100))
	spwanArr2:addObject(CCScaleTo:create(0.4, 2))
	local seqArr = CCArray:create()
	seqArr:addObject(CCSpawn:create(spwanArr1))
	seqArr:addObject(CCSpawn:create(spwanArr2))
	self.pumpkinLight2:runAction(CCRepeatForever:create(CCSequence:create(seqArr)))
end

function PumpkinExplode:stopBgLightAnimation()
	self.pumpkinLight1:stopAllActions()
	self.pumpkinLight2:stopAllActions()
	self.pumpkinLight1:setVisible(false)
	self.pumpkinLight2:setVisible(false)
end

function PumpkinExplode:getXdeltaTable(pumpkinNum)
	local dis = math.floor(600/pumpkinNum)
	local xDeltaTable = {}
	for i=1,pumpkinNum do
		local min = (i-1)*dis
		local max = i*dis
		local delta = math.random(min+5, max-5) - 300
		table.insert(xDeltaTable, delta)
	end
	return xDeltaTable
end

local function createAdd5StepProp()
	local add5step_prop = Sprite:createWithSpriteFrameName("add5step_prop0000.png")
	add5step_prop:setAnchorPoint(ccp(0.5, 1))
	local add5step_prop_frames = SpriteUtil:buildFrames("add5step_prop%04d.png", 0, 15)
	local add5step_prop_animate = SpriteUtil:buildAnimate(add5step_prop_frames, 1/30)
	add5step_prop:play(add5step_prop_animate, 0, 0, nil, false)

	return add5step_prop
end

local function createAdd5StepFly()
	local add5step_fly = Sprite:createWithSpriteFrameName("add5step_fly0000.png")
	add5step_fly:setAnchorPoint(ccp(0.5, 1))

	local add5step_fly_frames = SpriteUtil:buildFrames("add5step_fly%04d.png", 0, 15)
	local add5step_fly_animate = SpriteUtil:buildAnimate(add5step_fly_frames, 1/30)
	add5step_fly:play(add5step_fly_animate, 0, 0, nil, false)
	return add5step_fly
end

function PumpkinExplode:addTimeProp(callback)
	local timePropNum = 1
	local seqArr = CCArray:create()
 	local propAddFiveStep = createAdd5StepProp()
 	propAddFiveStep.name = "prop"
 	local targetPos = ccp(winSize.width/2 + math.random(-30, 30), winSize.height/2 + math.random(-150, -200))
 	propAddFiveStep:setPositionXY(targetPos.x, targetPos.y)
 	propAddFiveStep:setScale(1)
 	propAddFiveStep:setVisible(false)
 	self:addChild(propAddFiveStep)

 	local points = CCPointArray:create(4)
 	points:addControlPoint(ccp(targetPos.x , targetPos.y + 100))
 	points:addControlPoint(ccp(targetPos.x, targetPos.y))
 	local move_action = CCEaseBounceOut:create(CCEaseSineIn:create(CCCardinalSplineTo:create(1, points, 0)))
 	seqArr:addObject(CCDelayTime:create(1.5))
 	seqArr:addObject(CCCallFunc:create(function ()
 		propAddFiveStep:setVisible(true)
 	end))
 	seqArr:addObject(move_action)
 	propAddFiveStep:runAction(CCSequence:create(seqArr))
 	table.insert(self.dropItemTable, propAddFiveStep)

 	return timePropNum
end

function PumpkinExplode:playItemFly(endCallback)

	local flyCompleteCount = 0
	local function flyProp(prop, targetPos)
		local seqArr = CCArray:create()
		seqArr:addObject(CCDelayTime:create(2.5))
		seqArr:addObject(CCCallFunc:create(function()
					local fly = createAdd5StepFly()
					fly:setPositionXY(prop:getPositionX(), prop:getPositionY())

					local rad =  math.atan2(targetPos.y- fly:getPositionY(), targetPos.x - fly:getPositionX())
					local endRotation = 90 - rad*180 / math.pi

					fly:setRotation(endRotation)
					self:addChild(fly)

					local move_action = CCMoveTo:create(0.3, targetPos)
					local complete = CCCallFunc:create(function()
								if endCallback then
									endCallback(true)
								end

								flyCompleteCount = flyCompleteCount + 1
								if flyCompleteCount == #self.dropItemTable then
									self:removeFromParentAndCleanup(true)	
								end
								fly:removeFromParentAndCleanup(true)
						end)
					fly:runAction(CCSequence:createWithTwoActions(move_action, complete))
					prop:removeFromParentAndCleanup(true)
			end))
		prop:runAction(CCSequence:create(seqArr))
	end

	local function flyToTarget()
		for i,v in ipairs(self.dropItemTable) do
			local targetPos = nil
			if v.name == "pumpkin" then 
				targetPos = self.itemEndPos
			-- elseif v.name == "pumpkin_maker" then 
			-- 	targetPos = ccp(self.itemEndPos.x + 112, self.itemEndPos.y)
			else
				targetPos = self.propEndPos
			end
			targetPos = self:convertToNodeSpace(ccp(targetPos.x, targetPos.y)) 
			if v.name == "prop" then
				flyProp(v, targetPos)
			else
				local seqArr = CCArray:create()
				local spwanArr = CCArray:create()
				seqArr:addObject(CCDelayTime:create(v.flyDelayTime))
				spwanArr:addObject(CCMoveTo:create(0.3, targetPos))
				if v.scaleX then 
					if v.scaleX > 0 then 
						spwanArr:addObject(CCScaleTo:create(0.3, 1, 1))
					else
						spwanArr:addObject(CCScaleTo:create(0.3, -1, 1))
					end
				end
				seqArr:addObject(CCSpawn:create(spwanArr))
				seqArr:addObject(CCCallFunc:create(function() 
						if endCallback then
							endCallback(false)
						end
						flyCompleteCount = flyCompleteCount + 1
						if flyCompleteCount == #self.dropItemTable then
							self:removeFromParentAndCleanup(true)
						end
						v:removeFromParentAndCleanup(true)
					end))

				v:runAction(CCSequence:create(seqArr))
			end
		end
	end

	local dropNum = #self.dropItemTable
	local timePropNum = self:addTimeProp()
	for i,v in ipairs(self.dropItemTable) do
		local v = self.dropItemTable[i]
		local sequenceArr = CCArray:create()
		if v.name ~= "prop" then 
			local spwanArr1 = CCArray:create()
			local spwanArr2 = CCArray:create()

			local bezierConfig = ccBezierConfig:new()
			bezierConfig.controlPoint_1 = ccp(v.oriPosX +  v.xDelta/4, v.oriPosY +  v.height*8)
			bezierConfig.controlPoint_2 = ccp(v.oriPosX +  v.xDelta/2, v.oriPosY +  v.height*5)
			bezierConfig.endPosition = ccp(v.oriPosX + v.xDelta, v.oriPosY + v.yDelta)
			local bezierAction_1 = CCBezierTo:create(v.time, bezierConfig)

			spwanArr1:addObject(bezierAction_1)
			sequenceArr:addObject(CCDelayTime:create(v.delayTime - 0.6))
			sequenceArr:addObject(CCFadeTo:create(0, 255))
			sequenceArr:addObject(CCSpawn:create(spwanArr1))
			
			spwanArr2:addObject(CCMoveBy:create(0.1, ccp(0, v.bounceHeight)))
			if v.rotation then 
				spwanArr2:addObject(CCRotateBy:create(0.1, -v.rotation))
			end
			sequenceArr:addObject(CCSpawn:create(spwanArr2))
			sequenceArr:addObject(CCMoveBy:create(0.05, ccp(0, -v.bounceHeight)))

			if i == dropNum-timePropNum then
				sequenceArr:addObject(CCCallFunc:create(flyToTarget))
			end
			v:stopAllActions()
			v:runAction(CCSequence:create(sequenceArr))
		end
	end
end


function PumpkinExplode:playAnimation(endCallback)
	local context = self
	self:bgFadeIn()

	local function callback()
		self.pumpkinStar:play(context.pumpkinStarAnimate, 0, 1, function ()
			self.pumpkinStar:removeFromParentAndCleanup(true)
		end,true)
		self:playBgLightAnimation()

		local seqArr = CCArray:create()
		seqArr:addObject(CCScaleTo:create(0.4,1.05))
		seqArr:addObject(CCScaleTo:create(0.4,1))
		seqArr:addObject(CCScaleTo:create(0.4,1.05))
		seqArr:addObject(CCScaleTo:create(0.4,1))
		seqArr:addObject(CCCallFunc:create(function ()
			self:stopBgLightAnimation()

			local pumpkinFrames2 = SpriteUtil:buildFrames("boss_pumpkin_die2_%04d.png", 14, 16)
			pumpkinAnimate2 = SpriteUtil:buildAnimate(pumpkinFrames2, 1/24)
			context.pumpkinSprite2:play(pumpkinAnimate2, 0, 1, nil, true)
			context:playItemFly(endCallback)
		end))
		self.pumpkinContainer:runAction(CCSequence:create(seqArr))
	end

	self.pumpkinSprite1:play(self.pumpkinAnimate1, 0, 1, function ()
		if context.isDisposed then return end
			context.pumpkinContainer:setVisible(true)
			context.pumpkinSprite2:play(context.pumpkinAnimate2, 0, 1, callback, false)

			context:shakeScene()
	end, true)
end

function PumpkinExplode:bgFadeIn()
	self.greyCover:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.3),CCFadeTo:create(0.3, 150)))
end

function PumpkinExplode:shakeScene()
	local scene = Director:sharedDirector():getRunningScene()
	local seqArr = CCArray:create()
	seqArr:addObject(CCMoveBy:create(0.1, ccp(0, -10)))
	seqArr:addObject(CCMoveBy:create(0.15, ccp(0, 15)))
	seqArr:addObject(CCMoveBy:create(0.05, ccp(0, -5)))
	scene:runAction(CCSequence:create(seqArr))
end

function PumpkinExplode:show(endCallback)
	self:playAnimation(endCallback)
end

function PumpkinExplode:dispose()
	if self.pumpkinAnimate1 then 
		self.pumpkinAnimate1:release()
	end
	if self.pumpkinAnimate2 then 
		self.pumpkinAnimate2:release()
	end
	if self.pumpkinStarAnimate then 
		self.pumpkinStarAnimate:release()
	end
end

function PumpkinExplode:create(targetItemCount, itemEndPos, propCount, propEndPos)
	local layer = PumpkinExplode.new()
	layer.targetItemCount = targetItemCount or 15
	layer.itemEndPos = itemEndPos or ccp(winSize.width/2, winSize.height)
	layer.propCount = propCount or 1
	layer.propEndPos = propEndPos or ccp(0, 0)
	layer:initLayer()
	return layer
end