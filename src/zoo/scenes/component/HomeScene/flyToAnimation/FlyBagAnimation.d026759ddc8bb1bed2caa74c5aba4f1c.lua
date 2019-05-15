FlyBagAnimation = class(CocosObject)

function FlyBagAnimation:create( items ,flyDuration, delayTime)
	local bag = FlyBagAnimation.new(CCNode:create())
	bag:init(items,nil,nil,flyDuration, delayTime)
	return bag
end

function FlyBagAnimation:createWithGoodsId( goodsId,goodsNumber )
	local bag = FlyBagAnimation.new(CCNode:create())
	bag:init(nil,goodsId,goodsNumber)
	return bag	
end

function FlyBagAnimation:createWithSprites( sprites,callback )
	local bag = FlyBagAnimation.new(CCNode:create())

	bag._createAnimation = function(node,onFinish,flyDuration)
		local config={}
		config.sprites=sprites
		config.finishCallback=handler(bag,bag.onFinish)
		config.delayTime=math.min(0.7/#sprites,0.25)
		local animation = HomeSceneFlyToAnimation:sharedInstance():spritesJumpToBagAnimation(config)
		for k,v in pairs(animation.sprites) do
			if not v:getParent() then
				v:setPosition(ccp(0,0))
				v:setAnchorPoint(ccp(0.5,0.5))
				node:addChild(v)
			end
		end

		return animation
	end

	bag:init(nil,goodsId,goodsNumber)

	return bag	
end

function FlyBagAnimation:init( items,goodsId,goodsNumber ,flyDuration, delayTime)
	self.scene = Director.sharedDirector():getRunningScene()
	self.items = items
	self.goodsId = goodsId
	self.goodsNumber = goodsNumber or 1

	local function onFinish()
		self:onFinish()
	end

	self.animation = self:_createAnimation(onFinish,flyDuration, delayTime)
end

function FlyBagAnimation:_createAnimation( callback,flyDuration, delayTime )
	local config = {}

	if self.items then
		for k,v in pairs(self.items) do
			if ItemType:isTimeProp(v.itemId) then
				v.itemId = ItemType:getRealIdByTimePropId(v.itemId)
			end
		end
		config.items = self.items
	else
		config.goodsId = self.goodsId
		config.number = self.goodsNumber
	end

	if flyDuration then config.flyDuration = flyDuration end
	if delayTime then config.delayTime = delayTime end

	function config.finishCallback( ... )
		if callback then
			callback()
		end
	end
	local animation = HomeSceneFlyToAnimation:sharedInstance():jumpToBagAnimation(config)
	for k,v in pairs(animation.sprites) do
		v:setPosition(ccp(0,0))
		v:setAnchorPoint(ccp(0.5,0.5))
		self:addChild(v)
	end

	return animation
end

function FlyBagAnimation:setFinishCallback( finishCallback )
	self.finishCallback = finishCallback
end

function FlyBagAnimation:onFinish()
	if self.finishCallback then
		self.finishCallback()
	end

	if self.isPopout then
		if self.scene and not self.scene.isDisposed then
			self.scene:superRemoveChild(self)
		end
	end
end

function FlyBagAnimation:setWorldPosition( worldPos )
	self.worldPos = worldPos
end 


function FlyBagAnimation:play()
	if not self.scene or self.scene.isDisposed then
		if self.finishCallback then
			self.finishCallback()
		end
		self:dispose()
		return
	end

	if not self:getParent() then
		self.scene:superAddChild(self)
		self.isPopout = true
	end
	if self.worldPos then
		self:setPosition(self:getParent():convertToNodeSpace(self.worldPos))
	end
	self.animation:play()
end