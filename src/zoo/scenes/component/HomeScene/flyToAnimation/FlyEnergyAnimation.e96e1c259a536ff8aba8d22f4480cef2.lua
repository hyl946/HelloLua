

FlyEnergyAnimation = class(FlyBaseAnimation)

function FlyEnergyAnimation:create( num )
	local energy = FlyEnergyAnimation.new(CCNode:create())
	energy:init(num)
	return energy
end

function FlyEnergyAnimation:init( num )
	-- 无限精力
	if UserManager:getInstance():getUserExtendRef():getNotConsumeEnergyBuff() > Localhost:time() then
		num = 0
	end
	FlyBaseAnimation.init(self,num)
end

function FlyEnergyAnimation:getHomeSceneIconButton( ... )
	return HomeScene:sharedInstance().energyButton
end

function FlyEnergyAnimation:createAnimation( callback,reachCallback )
	local config = {  updateButton = true,number = math.max(1,math.min(self.num,10)) }
	function config.finishCallback( ... )
		if callback then
			callback()
		end
	end
	function config.reachCallback( ... )
		if reachCallback then
			reachCallback()
		end
	end

	local animation = HomeSceneFlyToAnimation:sharedInstance():energyFlyToAnimation(config)
	for k,v in pairs(animation.sprites) do
		self:addChild(v)
		v:setPosition(ccp(0,0))
	end
	return animation
end

FlyLevelNodeEnergyAnimation = class(FlyEnergyAnimation)

function FlyLevelNodeEnergyAnimation:create( num )
	local energy = FlyLevelNodeEnergyAnimation.new(CCNode:create())
	energy:init(num)
	return energy
end

function FlyLevelNodeEnergyAnimation:createAnimation( callback,reachCallback )
	local animation = {}

	local energy = Sprite:createWithSpriteFrameName("homeSceneEner_j34i0000")
	energy:setAnchorPoint(ccp(0.5, 0.5))
	self:addChild(energy)

	local function onFinish( ... )
		if self.isDisposed then
			return
		end
		energy:setVisible(false)

		GamePlayMusicPlayer:playEffect(GameMusicType.kAddEnergy)

		if reachCallback then
			reachCallback()
		end	
		if callback then
			callback()
		end

	end

	local flyToConfig = {
		duration = 0.3,
		sprites = {energy},
		dstPosition = HomeScene:sharedInstance().energyButton:getFlyToPosition(),
		dstSize = HomeScene:sharedInstance().energyButton:getFlyToSize(),
		direction = false,
		delayTime = 0.1,
		finishCallback = onFinish,
	}

	local context = self
	function animation:play( ... )

		local actions = CCArray:create()
		actions:addObject(CCSpawn:createWithTwoActions(
			CCFadeIn:create(0.2), 
			CCEaseBackOut:create(CCMoveBy:create(0.4, ccp(0, -30)))
		))
		actions:addObject(CCCallFunc:create(function() 
			BezierFlyToAnimation:create(flyToConfig) 
		end))

		energy:runAction(CCSequence:create(actions))
	end

	return animation
end


FlyInfiniteEnergyAnimation = class(FlyEnergyAnimation)
function FlyInfiniteEnergyAnimation:create()
	local energy = FlyInfiniteEnergyAnimation.new(CCNode:create())
	energy:init()
	return energy
end
function FlyInfiniteEnergyAnimation:init( ... )
	FlyEnergyAnimation.init(self,-1)
end

function FlyInfiniteEnergyAnimation:createAnimation( callback,reachCallback )
	local animation = {}

	local energy = ResourceManager:sharedInstance():buildItemSprite(ItemType.INFINITE_ENERGY_BOTTLE)
	energy:setAnchorPoint(ccp(0.5,0.5))
	self:addChild(energy)

	local function onFinish( ... )
		if self.isDisposed then
			return
		end

		energy:setVisible(false)

		if reachCallback then
			reachCallback()
		end
		self:runAction(CCSequence:createWithTwoActions(
			CCDelayTime:create(0.5),
			CCCallFunc:create(function( ... )
				self.iconButton:setTempEnergyState(nil)

				if callback then
					callback()
				end
			end)
		))
	end

	local flyToConfig = {
		duration = 0.8,
		sprites = {energy},
		dstPosition = HomeScene:sharedInstance().energyButton:getFlyToPosition(),
		dstSize = HomeScene:sharedInstance().energyButton:getFlyToSize(),
		direction = true,
		delayTime = 0.1,
		finishCallback = onFinish,
	}

	function animation:play( ... )
		BezierFlyToAnimation:create(flyToConfig)
	end

	return animation
end

-- 精力瓶
FlyGoodsEnergyAnimation = class(FlyEnergyAnimation)
function FlyGoodsEnergyAnimation:create( num,itemType )
	local energy = FlyGoodsEnergyAnimation.new(CCNode:create())
	energy:init(num,itemType)
	return energy
end

function FlyGoodsEnergyAnimation:init( num,itemType )
	self.itemType = itemType

	FlyEnergyAnimation.init(self,num)
end

function FlyGoodsEnergyAnimation:createAnimation( callback,reachCallback )
	local animation = {}

	local energy = nil

	local function onFinish( ... )
		if self.isDisposed then
			return
		end

		if energy then
			energy:setVisible(false)
		end

		if reachCallback then
			reachCallback()
		end	
		if callback then
			callback()
		end
	end

	if self.itemType == ItemType.SMALL_ENERGY_BOTTLE then
		energy = ResourceManager:sharedInstance():getItemResNameFromGoodsId(12)
	elseif self.itemType == ItemType.MIDDLE_ENERGY_BOTTLE then
		energy = ResourceManager:sharedInstance():getItemResNameFromGoodsId(17)
	elseif self.itemType == ItemType.LARGE_ENERGY_BOTTLE then
		energy = ResourceManager:sharedInstance():getItemResNameFromGoodsId(18)
	else 
		function animation:play( ... )
			onFinish()
		end 
		return animation
	end

	energy:setAnchorPoint(ccp(0.5,0.5))
	self:addChild(energy)

	local flyToConfig = {
		duration = 0.3,
		sprites = {energy},
		dstPosition = HomeScene:sharedInstance().energyButton:getFlyToPosition(),
		dstSize = HomeScene:sharedInstance().energyButton:getFlyToSize(),
		direction = true,
		delayTime = 0.1,
		finishCallback = onFinish,
	}

	function animation:play( ... )
		BezierFlyToAnimation:create(flyToConfig) 
	end

	return animation
end