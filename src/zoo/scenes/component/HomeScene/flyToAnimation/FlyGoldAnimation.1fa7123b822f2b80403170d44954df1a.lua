

FlyGoldAnimation = class(FlyBaseAnimation)

function FlyGoldAnimation:create( num )
	local gold = FlyGoldAnimation.new(CCNode:create())
	gold:init(num)
	return gold
end

function FlyGoldAnimation:createWithSprites( sprites, callback )
	local gold = FlyGoldAnimation.new(CCNode:create())

    local GoldNum = sprites.num
	gold.createAnimation = function(node,onFinish,flyDuration)
		local config={}
		config.sprites=sprites
		config.finishCallback=handler(gold, gold.onFinish)
		local animation = HomeSceneFlyToAnimation:sharedInstance():spritesJumpToGoldAnimation(config)
		for k,v in pairs(animation.sprites) do
			if not v:getParent() then
				v:setPosition(ccp(0,0))
				v:setAnchorPoint(ccp(0.5,0.5))
				node:addChild(v)
			end
		end

		return animation
	end

	gold:init( GoldNum )

	return gold	
end


function FlyGoldAnimation:init( num )
	FlyBaseAnimation.init(self,num)
end

function FlyGoldAnimation:getHomeSceneIconButton( ... )
	return HomeScene:sharedInstance().goldButton
end

function FlyGoldAnimation:createAnimation( callback,reachCallback )
	local config = {  updateButton = true,number = math.max(math.min(self.num,10), 1) }
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

	self.container = CocosObject:create()
	self:addChild(self.container)

	local animation = HomeSceneFlyToAnimation:sharedInstance():goldFlyToAnimation(config)
	for k,v in pairs(animation.sprites) do
		v:setPosition(ccp(-v:getContentSize().width/2,v:getContentSize().height/2))
		self.container:addChild(v)
	end

	return animation
end

function FlyGoldAnimation:setScale( scale )
	self.container:setScale(scale)
end

function FlyGoldAnimation:setScaleX( scaleX )
	self.container:setScaleX(scaleX)
end

function FlyGoldAnimation:setScaleY( scaleY )
	self.container:setScaleY(scaleY)
end