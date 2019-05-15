

FlyGoldToAnimation = class(CocosObject)

function FlyGoldToAnimation:create( num,toWorldPos )
	local gold = FlyGoldToAnimation.new(CCNode:create())
	gold:init(num,toWorldPos)
	return gold
end

function FlyGoldToAnimation:init( num,toWorldPos )
	self.scene = Director:sharedDirector():getRunningScene()
	self.golds = {}
	self.num = num
	self.toWorldPos = toWorldPos

	local function onFinish( ... )
		self:onFinish()
	end

	local function onReach( ... )

	end

	self.animation = self:createAnimation(onFinish,onReach)
end

function FlyGoldToAnimation:setFinishCallback( finishCallback )
	self.finishCallback = finishCallback
end

function FlyGoldToAnimation:onFinish( ... )
	if self.scene and not self.scene.isDisposed then
		self.scene:superRemoveChild(self)
	end
	if self.finishCallback then
		self.finishCallback()
	end
end

function FlyGoldToAnimation:setWorldPosition( worldPos )
	self.worldPos = worldPos
end

function FlyGoldToAnimation:play( ... )

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

function FlyGoldToAnimation:createAnimation( callback,reachCallback )

	for i=1,math.min(self.num,10) do
		local gold = Sprite:createWithSpriteFrameName("wheel0000")
		gold:setAnchorPoint(ccp(0.5,0.5))
		self:addChild(gold)
		gold:setVisible(false)
		table.insert(self.golds,gold)
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

	local flyToConfig = {
		duration = 0.4,
		sprites = self.golds,
		dstPosition = self.toWorldPos,
		dstSize = CCSizeMake(45,45),
		direction = true,
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