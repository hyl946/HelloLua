TileSunflower = class(CocosObject)

local kCharacterAnimationTime = 1/30

local SelfLayerIndex = {
	flowerLayer = 1,
	numPlateLayer = 2,
	numLayer = 3,
}

local assetNamePrefix = "blocker_sunflower_"

function TileSunflower:create(countDown)
	-- printx(11, " + + + TileSunflower:create + + + ", countDown)
	local node = TileSunflower.new(CCNode:create())
	node.name = "blocker_sunflower"
	node.countDown = countDown

	node:init()
	return node
end

function TileSunflower:init( ... )
	self:setIdleAnimation()
end

function TileSunflower:removeViewPack(ignoreItemSprite)
	if self.flower and not self.flower.isDisposed then
		self.flower:removeFromParentAndCleanup(true)
		self.flower = nil
	end

	if self.numplate and not self.numplate.isDisposed then
		self.numplate:removeFromParentAndCleanup(true)
		self.numplate = nil
	end

	if self.number and not self.number.isDisposed then
		self.number:removeFromParentAndCleanup(true)
		self.number:dispose()
		self.number = nil
	end

	if not ignoreItemSprite then
		if self.itemSprite and not self.itemSprite.isDisposed then
			self.itemSprite:removeFromParentAndCleanup(true)
			self.itemSprite = nil
		end
	end
end

--------------------------------------------------------------------------------
--									IDLE
--------------------------------------------------------------------------------
function TileSunflower:setIdleAnimation()
	self:_setIdleView()

	--- idleAnimation
	self:_playCertainAnimation(self.flower, assetNamePrefix.."idle", 30, kCharacterAnimationTime, true)
	self.inIdleState = true
end

function TileSunflower:_setIdleView()
	self:removeViewPack()

	self.flower = Sprite:createWithSpriteFrameName(assetNamePrefix.."idle".."_0000")
	self.numplate = Sprite:createWithSpriteFrameName(assetNamePrefix.."numplate".."_0000")
	self.numplate:setPosition(ccp(-23, -23))

	self.number = BitmapText:create(tostring(self.countDown), "fnt/prop_name.fnt")
	self.number:setPosition(ccp(-25, -21))
	self.number:setScale(0.5)
	-- self.number:setText(self.countDown.."")

	local containerSprite = Sprite:createEmpty()
	containerSprite:addChildAt(self.flower, SelfLayerIndex.flowerLayer)
	containerSprite:addChildAt(self.numplate, SelfLayerIndex.numPlateLayer)
	containerSprite:addChildAt(self.number, SelfLayerIndex.numLayer)

	self.itemSprite = containerSprite
	self.itemSprite:setPosition(ccp(1, -3))

	self:addChildAt(self.itemSprite, 0)
end

function TileSunflower:_playCertainAnimation(targetSprite, spritePrefix, animationFrame, animationTime, doubleWithReverse, onAnimationFinished)
	if targetSprite then
		targetSprite:stopAllActions()

	    local frames = SpriteUtil:buildFrames(spritePrefix.."_%04d", 0, animationFrame)
		local animation = SpriteUtil:buildAnimate(frames, animationTime)
		if doubleWithReverse then
			local frames2 = SpriteUtil:buildFrames(spritePrefix.."_%04d", 0, animationFrame, true)
			local animation2 = SpriteUtil:buildAnimate(frames2, animationTime)

			local sequence = CCArray:create()
			-- sequence:addObject(CCDelayTime:create(0.7))
			sequence:addObject(animation)
			sequence:addObject(animation2)
			-- sequence:addObject(CCDelayTime:create(1))
			local action = CCRepeatForever:create(CCSequence:create(sequence))

			targetSprite:runAction(action)
		else
			targetSprite:play(animation, 0, 1, onAnimationFinished, true)
		end
	end
end

function TileSunflower:_updateNumberView()
	if self.number then
		self.number:setText(self.countDown.."")
	end
end

--------------------------------------------------------------------------------
--										HIT 
--------------------------------------------------------------------------------
function TileSunflower:playSunflowerAbsorbSun(startPoint, endPoint)
	local layer = Layer:create()

	local function onFlySunAnimationFinished()
		layer:removeFromParentAndCleanup(true) 

		local newNumVal = math.max(0, self.countDown - 1)
		self:playSunflowerAbsorbSunSelfPart(newNumVal)
	end

	local function onSunAppearFinished()
		local sunSprite = Sprite:createWithSpriteFrameName(assetNamePrefix.."sun_0000")
		sunSprite:setPosition(startPoint)

		function AddPartical()
	        local pop = ParticleSystemQuad:create("particle/turret.plist")  --美术说用炮塔的拖尾效果就行
	        pop:setAutoRemoveOnFinish(true)
	        local contentSize = sunSprite:getContentSize()
	        pop:setPosition(ccp(contentSize.width/2,contentSize.height/2))
	        sunSprite:addChild(pop)
	    end

		-- 移动末尾的缓动效果
		local midPointPercent = 0.8
		local midTimePercent = 0.3
		local midPoint = ccp(startPoint.x + (endPoint.x - startPoint.x) * midPointPercent, 
			startPoint.y + (endPoint.y - startPoint.y) * midPointPercent)

		local actArr = CCArray:create()
		actArr:addObject(CCCallFunc:create(AddPartical) )
		actArr:addObject(CCMoveTo:create(0.4 * midTimePercent, ccp(midPoint.x , midPoint.y)))
		actArr:addObject(CCMoveTo:create(0.4 * (1 - midTimePercent), ccp(endPoint.x , endPoint.y)))
		-- actArr:addObject(CCDelayTime:create(0.5))
		actArr:addObject(CCCallFunc:create(onFlySunAnimationFinished) )
		sunSprite:runAction(CCSequence:create(actArr))

		layer:addChild(sunSprite)
	end

	local animation = Sprite:createWithSpriteFrameName(assetNamePrefix.."sun_appear_0000")
	local frames = SpriteUtil:buildFrames(assetNamePrefix.."sun_appear_%04d", 0, 12)
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	animation:play(animate, 0, 1, onSunAppearFinished, true)
	animation:setPosition(startPoint)

	layer:addChild(animation)

	return layer
end

function TileSunflower:playSunflowerAbsorbSunSelfPart(newNumVal)
	local function onAllAnimationFinished()
		self.inHitAnimation = false
		self:setIdleAnimation()
	end

	if not self.inHitAnimation then
		self.inHitAnimation = true

		if self.flower and not self.flower.isDisposed then
			self.flower:removeFromParentAndCleanup(true)
			self.flower = nil
		end
		self.flower = Sprite:createWithSpriteFrameName(assetNamePrefix.."hit_0000")
		self.itemSprite:addChildAt(self.flower, SelfLayerIndex.flowerLayer)
		self.flower:setPosition(ccp(-6, 4))

		self:_playCertainAnimation(self.flower, assetNamePrefix.."hit", 25, kCharacterAnimationTime, false, onAllAnimationFinished)
	end

	self:setSunflowerNumView(newNumVal)
end

function TileSunflower:setSunflowerNumView(newVal)
	self.countDown = math.max(0, newVal)
	self:_updateNumberView()
end

function TileSunflower:removeSunflowerView()
	if self.flower then
		self.flower:stopAllActions()
	end
	self:removeViewPack()
end