

FlyCoinStackAnimation = class(FlyBaseAnimation)

function FlyCoinStackAnimation:create( num )
	local coinStack = FlyCoinStackAnimation.new(CCNode:create())
	coinStack:init(num)
	return coinStack
end

function FlyCoinStackAnimation:init( num )
	FlyBaseAnimation.init(self,num)
end


function FlyCoinStackAnimation:getHomeSceneIconButton()
	return HomeScene:sharedInstance().coinButton
end

function FlyCoinStackAnimation:createAnimation( callback,reachCallback )
	local config = { updateButton = true }
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

	local animation = HomeSceneFlyToAnimation:sharedInstance():coinStackAnimation(config)
	self:addChild(animation.sprites)
	animation.sprites:setPosition(ccp(0,0))

	return animation
end


FlyLevelNodeCoinAnimation = class(FlyCoinStackAnimation)

function FlyLevelNodeCoinAnimation:create( num )
	local coin = FlyLevelNodeCoinAnimation.new(CCNode:create())
	coin:init(num)
	return coin
end

function FlyLevelNodeCoinAnimation:createAnimation( callback,reachCallback )
	
	local animation = {}

	local function onFinish( ... )
		if callback then
			callback()
		end
	end

	local function onReach( ... )
		if reachCallback then
			reachCallback()
		end
	end

	local context = self
	function animation:play( ... )
		local pos = context:convertToNodeSpace(ccp(context.worldPos.x,context.worldPos.y))

		HomeSceneFlyToAnimation:sharedInstance():levelNodeCoinAnimation(pos, onFinish,context,onReach)
	end

	return animation
end
