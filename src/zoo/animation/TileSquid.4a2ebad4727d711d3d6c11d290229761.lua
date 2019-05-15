TileSquid = class(CocosObject)

SquidDirection = table.const{
	kUp = 1,
	kRight = 2,
	kDown = 3,
	kLeft = 4,
}

local SquidLayerIndex = {
	shadowLayer = 1,	--后景身体 & 影子
	targetLayer = 2,	--目标物
	progressLayer = 3,	--进度
	bodyLayer = 4,		--前景身体
}

local kCharacterAnimationTime = 1/30

function TileSquid:create(texture, direction, targetType, targetNeeded, targetCount)
	local sprite = CCSprite:create()
	sprite:setTexture(texture)
	local node = TileSquid.new(sprite)
	node.name = "squid"
	node.parentTexture = texture

	node:init(direction, targetType, targetNeeded, targetCount)

	return node
end

function TileSquid:init(direction, targetType, targetNeeded, targetCount)
    self.direction = direction
    self.targetType = targetType
    self.targetNeeded = targetNeeded
    self.targetCount = targetCount

    if self.targetCount >= self.targetNeeded then
    	self:setFullAnimation()
    else
    	self:setIdleAnimation()
    end
end

function TileSquid:removeViewPack()
	if self.body and not self.body.isDisposed then
		self.body:removeFromParentAndCleanup(true)
		self.body = nil
	end

	if self.progress and not self.progress.isDisposed then
		self.progress:removeFromParentAndCleanup(true)
		self.progress = nil
	end

	if self.targetIcon and not self.targetIcon.isDisposed then
		self.targetIcon:removeFromParentAndCleanup(true)
		self.targetIcon = nil
	end

	if self.shadow and not self.shadow.isDisposed then
		self.shadow:removeFromParentAndCleanup(true)
		self.shadow = nil
	end

	if self.itemSprite and not self.itemSprite.isDisposed then
		self.itemSprite:removeFromParentAndCleanup(true)
		self.itemSprite = nil
	end
end

function TileSquid:getRotationOfDirection()
	if self.direction == 2 then
		return 90
	elseif self.direction == 3 then
		return 180
	elseif self.direction == 4 then
		return -90
	end
	return 0
end

-- 以正向时X的偏移为准
function TileSquid:getShiftFlagOfDirectionX()
	if self.direction == 2 then
		return 0, -1
	elseif self.direction == 3 then
		return -1, 0
	elseif self.direction == 4 then
		return 0, 1
	end
	return 1, 0
end

-- 以正向时Y的偏移为准
function TileSquid:getShiftFlagOfDirectionY()
	if self.direction == 2 then
		return 1, 0
	elseif self.direction == 3 then
		return 0, -1
	elseif self.direction == 4 then
		return -1, 0
	end
	return 0, 1
end

function TileSquid:_playCertainAnimation(targetSprite, spritePrefix, animationFrame, animationTime, doubleWithReverse, onAnimationFinished, removeOnFinished)
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
			targetSprite:play(animation, 0, 1, onAnimationFinished, removeOnFinished)
		end
	end
end

function TileSquid:_shiftSpriteByDirection(targetSprite, shiftValofX, shiftValofY)
	local shiftFlagXofX, shiftFlagYofX = self:getShiftFlagOfDirectionX()
	local shiftFlagXofY, shiftFlagYofY = self:getShiftFlagOfDirectionY()
	targetSprite:setPosition(ccp(shiftValofY * shiftFlagXofY + shiftValofX * shiftFlagXofX, 
		shiftValofY * shiftFlagYofY + shiftValofX * shiftFlagYofX))
end

--------------------------------------------------------------------------------
--									IDLE
--------------------------------------------------------------------------------
function TileSquid:setIdleAnimation()
	self:removeViewPack()

	local bodyAssetPrefix = "squid_fg_idle"
	local shadowAssetPrefix = "squid_bg_idle"
	local targetAssetPrefix = "targetIcon/squid_target_"..self.targetType
	self.body = Sprite:createWithSpriteFrameName(bodyAssetPrefix.."_0000")
	self.shadow = Sprite:createWithSpriteFrameName(shadowAssetPrefix.."_0000")
	self.targetIcon = Sprite:createWithSpriteFrameName(targetAssetPrefix)
	-- self.targetIcon = Sprite:createWithSpriteFrameName(targetAssetPrefix.."_0000")

	local progressFrame = self:_getProgressFrame()
	local progressSuffix = ""..progressFrame
	if progressFrame < 10 then progressSuffix = "0"..progressSuffix end
	self.progress = Sprite:createWithSpriteFrameName("squid_ball_00"..progressSuffix)
	self.currProgressFrame = progressFrame

	-- adjust positions
	self.body:setPosition(ccp(0, 23 + 28))
	self.shadow:setPosition(ccp(0, 28))
	self.progress:setPosition(ccp(0, -9))
	self.targetIcon:setPosition(ccp(0, -9))
	-- self.targetIcon:setPosition(ccp(1, -7))

	local containerSprite = Sprite:createEmpty()
	containerSprite:setTexture(self.parentTexture)
	containerSprite:addChildAt(self.body, SquidLayerIndex.bodyLayer)
	containerSprite:addChildAt(self.progress, SquidLayerIndex.progressLayer)
	containerSprite:addChildAt(self.targetIcon, SquidLayerIndex.targetLayer)
	containerSprite:addChildAt(self.shadow, SquidLayerIndex.shadowLayer)

	self.itemSprite = containerSprite
	-- self.itemSprite:setPosition(ccp(0, -3))
	local rotation = self:getRotationOfDirection()
	if rotation ~= 0 then
		self.itemSprite:setRotation(rotation)
		self.progress:setRotation(-rotation)
		self.targetIcon:setRotation(-rotation)
		-- self.targetIcon:setPosition(ccp(self.targetIcon:getPositionX(), self.targetIcon:getPositionY() + 2))
	end
	self:addChildAt(self.itemSprite, 0)

	--- idleAnimation
	self:_playCertainAnimation(self.body, bodyAssetPrefix, 30, kCharacterAnimationTime, true)
	self:_playCertainAnimation(self.shadow, shadowAssetPrefix, 30, kCharacterAnimationTime, true)
end

function TileSquid:_getProgressFrame()
	local totalFrames = 59

	-- printx(11, " + + + + + targetCount, targetNeeded", self.targetCount, self.targetNeeded)
	local currFrame = math.floor(math.min(self.targetCount / self.targetNeeded, 1) * totalFrames)
	currFrame = math.max(currFrame, 0)
	-- printx(11, " + + + + + Curr Progress Frame:", currFrame)
	return currFrame
end

--------------------------------------------------------------------------------
--								Charging
--------------------------------------------------------------------------------
function TileSquid:playSquidAbsorbTarget(startPoint, endPoint, newTargetAmount)
	local layer

	local function onChargeSquid()
		self:playChargeAnimation(newTargetAmount)
	end

	if not startPoint then
		-- 锤子敲的，没有飞行动画
		onChargeSquid()
	else
		layer = Layer:create()

		local animation = Sprite:createWithSpriteFrameName("squid_bullet_line_0000")
		local frames = SpriteUtil:buildFrames("squid_bullet_line_%04d", 0, 19)
		local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
		-- animation:play(animate, 0, 1, nil, true)
		animation:play(animate, 0, 1)

		-- printx(11, "startPoint:", startPoint.x, startPoint.y)
		-- printx(11, "endPoint:", endPoint.x, endPoint.y)

		local angle = -math.deg(math.atan2(endPoint.y - startPoint.y, endPoint.x - startPoint.x))
		animation:setPosition(startPoint)
		animation:setRotation(angle)
		-- animation:setAnchorPoint(ccp(0.8, 0.46))
		animation:setAnchorPoint(ccp(0.9, 0.5))

		local function onFlyAnimationFinished()
			-- printx(11, "remove....")
			if animation then
				-- printx(11, "...yes.")
				animation:removeFromParentAndCleanup(true)
				animation = nil
			end
			layer:removeFromParentAndCleanup(true)
		end

		local actArr = CCArray:create()
		actArr:addObject(CCMoveTo:create(0.4, ccp(endPoint.x , endPoint.y)))
		actArr:addObject(CCCallFunc:create(onChargeSquid) )
		actArr:addObject(CCDelayTime:create(0.3))
		actArr:addObject(CCCallFunc:create(onFlyAnimationFinished) )
		animation:runAction(CCSequence:create(actArr))

		layer:addChild(animation)
	end

	return layer
end

function TileSquid:playChargeAnimation(newTargetAmount)
	if self.targetCount >= self.targetNeeded then
		return
	end

	if self.targetCount >= newTargetAmount then
		return
	end

	if self.body and not self.body.isDisposed and self.shadow and not self.shadow.isDisposed then
		local bodyAnimationFinished = false
		local progressAnimationFinished = false

		local function onAnimationFinished()
			if bodyAnimationFinished and progressAnimationFinished then
				if self.targetCount >= self.targetNeeded then
			    	-- self:setFullAnimation()
			    	self:playChangeToFullAnimation()
			    else
			    	self:setIdleAnimation()
			    end
			end
		end

		local function onBodyAnimationFinished()
			bodyAnimationFinished = true
			onAnimationFinished()
		end

		local function onProgressAnimationFinished()
			progressAnimationFinished = true
			onAnimationFinished()
		end

		self.body:removeFromParentAndCleanup(true)
		self.body = nil
		self.shadow:removeFromParentAndCleanup(true)
		self.shadow = nil

		local bodyAssetPrefix = "squid_fg_stimu"
		local shadowAssetPrefix = "squid_bg_stimu"
		self.body = Sprite:createWithSpriteFrameName(bodyAssetPrefix.."_0000")
		self.shadow = Sprite:createWithSpriteFrameName(shadowAssetPrefix.."_0000")
		self.body:setPosition(ccp(2, 16))
		self.shadow:setPosition(ccp(0, 28))

		self.itemSprite:addChildAt(self.body, SquidLayerIndex.bodyLayer)
		self.itemSprite:addChildAt(self.shadow, SquidLayerIndex.shadowLayer)

		self:_playCertainAnimation(self.body, bodyAssetPrefix, 20, kCharacterAnimationTime, false, nil, false)
		self:_playCertainAnimation(self.shadow, shadowAssetPrefix, 20, kCharacterAnimationTime, false, onBodyAnimationFinished, false)

		self:updateProgressDisplay(newTargetAmount, onProgressAnimationFinished)
	end
end

function TileSquid:updateProgressDisplay(newTargetAmount, onAnimationFinished)
	if self.progress and not self.progress.isDisposed then 

		self.targetCount = newTargetAmount

		local progressFrame = self:_getProgressFrame()
		if toProgressFrame then
			progressFrame = toProgressFrame
		end

		-- printx(11, "= = = = update squid progress animation. oldFrame, newFrame:", self.currProgressFrame, progressFrame)
		if self.currProgressFrame == progressFrame then
			return
		end

		local startFrame = self.currProgressFrame
		local frameLength = progressFrame - startFrame
		if frameLength <= 0 then
			startFrame = 0
			frameLength = math.max(progressFrame, 1)
		end

		local animationTime = kCharacterAnimationTime
		if frameLength > 29 then
			animationTime = animationTime / 2	--涨进度条的动画太长了就加一下速
		end
		local frames = SpriteUtil:buildFrames("squid_ball_%04d", startFrame, frameLength + 1)
		-- printx(11, "= = = = build frame. startFrame, frameLength:", startFrame, frameLength)
		local progressAnimation = SpriteUtil:buildAnimate(frames, animationTime)
		self.progress:stopAllActions()
		self.progress:play(progressAnimation, 0, 1, onAnimationFinished)
		
		self.currProgressFrame = progressFrame
	end
end

--------------------------------------------------------------------------------
--									FULL
--------------------------------------------------------------------------------
function TileSquid:playChangeToFullAnimation()
	self:removeViewPack()

	local function onChangeAnimationEnded()
		self:setFullAnimation()
	end

	local assetPrefix = "squid_active"
	self.itemSprite = Sprite:createWithSpriteFrameName(assetPrefix.."_0000")
	self:addChild(self.itemSprite)
	local rotation = self:getRotationOfDirection()
	if rotation ~= 0 then
		self.itemSprite:setRotation(rotation)
	end
	self:_shiftSpriteByDirection(self.itemSprite, 0, 33.5)

	self:_playCertainAnimation(self.itemSprite, assetPrefix, 15, kCharacterAnimationTime, false, onChangeAnimationEnded, true)
end

function TileSquid:setFullAnimation()
	self:removeViewPack()

	local assetPrefix = "squid_waiting"
	self.itemSprite = Sprite:createWithSpriteFrameName(assetPrefix.."_0000")
	self:addChild(self.itemSprite)
	local rotation = self:getRotationOfDirection()
	if rotation ~= 0 then
		self.itemSprite:setRotation(rotation)
	end
	self:_shiftSpriteByDirection(self.itemSprite, 0, 28)

	self:_playCertainAnimation(self.itemSprite, assetPrefix, 20, kCharacterAnimationTime, true)
end

--------------------------------------------------------------------------------
--									Run
--------------------------------------------------------------------------------
function TileSquid:playSquidRun(gridLength, startPos)
	self:removeViewPack()

	self.itemSprite = Sprite:createWithSpriteFrameName("squid_run_0000")
	self:addChild(self.itemSprite)
	self.itemSprite:setVisible(false)

	local layer = Layer:create()

	local animation = Sprite:createWithSpriteFrameName("squid_run_0000")
	local frames = SpriteUtil:buildFrames("squid_run_%04d", 0, 35)
	local animate = SpriteUtil:buildAnimate(frames, kCharacterAnimationTime)
	animation:play(animate, 0, 1)

	local rotation = self:getRotationOfDirection()
	if rotation ~= 0 then
		animation:setRotation(rotation)
	end
	-- self:_shiftSpriteByDirection(animation, -172, 50)
	local shiftValofX = - 173
	local shiftFlagXofX, shiftFlagYofX = self:getShiftFlagOfDirectionX()
	local shiftValofY = 50
	local shiftFlagXofY, shiftFlagYofY = self:getShiftFlagOfDirectionY()
	local startX = startPos.x + shiftValofY * shiftFlagXofY + shiftValofX * shiftFlagXofX
	local startY = startPos.y + shiftValofY * shiftFlagYofY + shiftValofX * shiftFlagYofX
	animation:setPosition(ccp(startX, startY))

	local flyDuration = 0.4

	local inkIndex = 0
	local function releaseInkOfGrid()
		local assetPrefix = "squid_ink"
		local inkFrameAmount = 24
		shiftValofX = 0
		shiftValofY = -35
		if inkIndex == 0 then
			assetPrefix = assetPrefix.."_big"
			inkFrameAmount = 20
			shiftValofX = -175
			shiftValofY = 115
		end
		local inkAnimation = Sprite:createWithSpriteFrameName(assetPrefix.."_0000")
		local inkFrames = SpriteUtil:buildFrames(assetPrefix.."_%04d", 0, inkFrameAmount)
		local inkAnimate = SpriteUtil:buildAnimate(inkFrames, kCharacterAnimationTime)
		inkAnimation:play(inkAnimate, 0, 1, nil, true)

		-- printx(11, ". . . relase ink. index:", inkIndex, rotation)
		if rotation ~= 0 then
			inkAnimation:setRotation(rotation)
		end
		local upShiftVal = 70 * inkIndex
		-- self:_shiftSpriteByDirection(inkAnimation, shiftValofX, shiftValofY + upShiftVal)
		local startXink = startPos.x + shiftValofY * shiftFlagXofY + shiftValofX * shiftFlagXofX
		local startYink = startPos.y + shiftValofY * shiftFlagYofY + shiftValofX * shiftFlagYofX
		inkAnimation:setPosition(ccp(startXink + upShiftVal * shiftFlagXofY, startYink + upShiftVal * shiftFlagYofY))

		if layer and not layer.isDisposed then
			layer:addChildAt(inkAnimation, 0)
		end

		inkIndex = inkIndex + 1
	end

	local function startReleaseInk()
		-- printx(11, "= = = startReleaseInk = = =")
		local inkActArr = CCArray:create()
		local index
		for index = 1, gridLength + 1 do
			inkActArr:addObject(CCCallFunc:create(releaseInkOfGrid))
			inkActArr:addObject(CCDelayTime:create(flyDuration / (gridLength + 1)))
		end
		self.itemSprite:runAction(CCSequence:create(inkActArr))
	end

	local function onFlyAnimationFinished()
		-- printx(11, "remove....")
		if animation then
			-- printx(11, "...yes.")
			animation:removeFromParentAndCleanup(true)
			animation = nil
		end
		layer:removeFromParentAndCleanup(true)
	end

	local flyShift = 70 * gridLength + 70
	local actArr = CCArray:create()
	actArr:addObject(CCDelayTime:create(0.6))
	actArr:addObject(CCCallFunc:create(startReleaseInk))
	actArr:addObject(CCDelayTime:create(0.1))
	actArr:addObject(CCMoveTo:create(flyDuration, ccp(startX + flyShift * shiftFlagXofY, startY + flyShift * shiftFlagYofY)))
	actArr:addObject(CCDelayTime:create(0.5))
	actArr:addObject(CCCallFunc:create(onFlyAnimationFinished) )
	animation:runAction(CCSequence:create(actArr))

	layer:addChildAt(animation, 1)

	return layer
end


