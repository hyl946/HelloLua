

FlyStarAnimation = class(FlyBaseAnimation)

function FlyStarAnimation:create( num )
	local coinStack = FlyStarAnimation.new(CCNode:create())
	coinStack:init(num)
	return coinStack
end

function FlyStarAnimation:init( num )
	self.stars = {}
	FlyBaseAnimation.init(self,num)
end

function FlyStarAnimation:getHomeSceneIconButton( ... )
	return HomeScene:sharedInstance().starButton
end

function FlyStarAnimation:createAnimation( callback,reachCallback )
	local icon = HomeScene:sharedInstance().starButton:getBubbleItemRes():getChildByName("placeHolder")

	for i=1,self.num do
		local star = Sprite:createWithSpriteFrame(icon:getChildAt(0):displayFrame())
		star:setAnchorPoint(ccp(0.5,0.5))
		star:setVisible(false)
		self:addChild(star)
		table.insert(self.stars,star)
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

	local bounds = icon:getGroupBounds()

	local flyToConfig = {
		duration = 0.3,
		sprites = self.stars,
		dstPosition = ccp(bounds:getMidX(),bounds:getMidY()),
		dstSize = bounds.size,
		direction = false,
		delayTime = 0.1,
		startCallback = onStart,
		reachCallback = onReach,
		finishCallback = onFinish,
	}

	local animation = {}
	local context = self
	function animation:play( ... )
		if self.isDisposed then
			return
		end
		context:runAction(CCSequence:createWithTwoActions(
			CCDelayTime:create(0.4),
			CCCallFunc:create(function( ... )
				BezierFlyToAnimation:create(flyToConfig)
			end)
		))
	end
	return animation
end