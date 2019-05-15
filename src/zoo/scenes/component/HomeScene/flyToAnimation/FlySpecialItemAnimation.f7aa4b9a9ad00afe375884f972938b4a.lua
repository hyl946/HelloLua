FlySpecialItemAnimation = class(CocosObject)

function FlySpecialItemAnimation:create(reward, spriteFrameName, targetPos, direction)
	local anim = FlySpecialItemAnimation.new(CCNode:create())
	anim:setFlyDirection(direction)
	anim:init(reward, spriteFrameName, targetPos)
	return anim
end

function FlySpecialItemAnimation:init(reward, spriteFrameName, targetPos)
	self.scene = Director:sharedDirector():getRunningScene()
	self.icons = {}
	self.reward = reward
	self.itemId = reward.itemId
	self.num = reward.num
	self.toWorldPos = targetPos
	self.spriteFrameName = spriteFrameName


	local function onFinish( ... )
		self:onFinish()
	end

	local function onReach( ... )
		if self.reachCallback then
			self.reachCallback()
		end
	end

	self.animation = self:createAnimation(onFinish, onReach)
end

function FlySpecialItemAnimation:setFinishCallback( finishCallback )
	self.finishCallback = finishCallback
end

function FlySpecialItemAnimation:setReachCallback( reachCallback )
	self.reachCallback = reachCallback
end

function FlySpecialItemAnimation:onFinish( ... )
	if self.scene and not self.scene.isDisposed then
		self.scene:superRemoveChild(self)
	end
	if self.finishCallback then
		self.finishCallback()
	end
end

function FlySpecialItemAnimation:setWorldPosition( worldPos )
	self.worldPos = worldPos
end

function FlySpecialItemAnimation:play( ... )

	if not self.scene or self.scene.isDisposed then
		if self.finishCallback then
			self.finishCallback()
		end
		self:dispose()
		return
	end
	self.scene:superAddChild(self)
	if self.worldPos then
		self:setPosition(self:getParent():convertToNodeSpace(self.worldPos))
	end

	self.animation:play()
end

function FlySpecialItemAnimation:createAnimation( callback,reachCallback )

	for i=1,math.min(self.num, 10) do
		local icon
		if self.spriteFrameName then
			icon = Sprite:createWithSpriteFrameName(self.spriteFrameName)
		else
			icon = ResourceManager:sharedInstance():buildItemSprite(self.itemId)
		end
		icon:setAnchorPoint(ccp(0.5,0.5))
		self:addChild(icon)
		icon:setVisible(false)
		table.insert(self.icons, icon)
	end

	local function onStart( target )
		if self.isDisposed then
			return
		end
		target:setVisible(true)
	end

	local function onReach( target )
		if self.isDisposed then
			return
		end
		target:setVisible(false)

		if reachCallback then
			reachCallback()
		end
	end

	local function onFinish( ... )
		if self.isDisposed then
			return
		end
		if callback then
			callback()
		end
	end

	local direction = true

	if self.direction ~= nil then
		direction = self.direction
	end

	local flyToConfig = {
		duration = 0.4,
		sprites = self.icons,
		dstPosition = self.toWorldPos,
		dstSize = CCSizeMake(45,45),
		direction = direction,
		delayTime = 0.1,
		startCallback = onStart,
		reachCallback = onReach,
		finishCallback = onFinish,
	}

	local animation = {}
	function animation:play( ... )
		if self.isDisposed then
			return
		end
		BezierFlyToAnimation:create(flyToConfig)
	end
	return animation
end

function FlySpecialItemAnimation:setScale( scale )
	for _, icon in pairs(self.icons) do
		icon:setScale(scale)
	end
end


function FlySpecialItemAnimation:setFlyDirection(direction)
	self.direction = direction
end