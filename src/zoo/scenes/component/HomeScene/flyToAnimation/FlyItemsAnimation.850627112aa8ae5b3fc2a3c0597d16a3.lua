require "zoo.scenes.component.HomeScene.flyToAnimation.FlyBaseAnimation"
require "zoo.scenes.component.HomeScene.flyToAnimation.FlyCoinStackAnimation"
require "zoo.scenes.component.HomeScene.flyToAnimation.FlyGoldAnimation"
require "zoo.scenes.component.HomeScene.flyToAnimation.FlyBagAnimation"
require "zoo.scenes.component.HomeScene.flyToAnimation.OpenBoxAnimation"

require "zoo.scenes.component.HomeScene.flyToAnimation.FlyEnergyAnimation"
require "zoo.scenes.component.HomeScene.flyToAnimation.FlyStarAnimation"

require "zoo.scenes.component.HomeScene.flyToAnimation.FlyGoldToAnimation"

require "zoo.iconButtons.animation.FlyTopEnergyAni"
require "zoo.iconButtons.animation.FlyTopEnergyBottleAni"
require "zoo.iconButtons.animation.FlyTopCoinAni"
require "zoo.iconButtons.animation.FlyTopGoldAni"
require "zoo.iconButtons.animation.FlyTopStarAni"


FlyItemsAnimation = class(CocosObject)

function FlyItemsAnimation:create(rewards, otherParams)
	local flyItems = FlyItemsAnimation.new(CCNode:create())
	flyItems:init(rewards, otherParams)
	return flyItems
end

function FlyItemsAnimation:init(rewards, otherParams)
	self.scene = Director.sharedDirector():getRunningScene()

	local coinNum = 0
	local goldNum = 0
	local bagItems = {}
	local hasInfiniteEnergy = nil

	for k,v in pairs(rewards) do
		if v.itemId == ItemType.COIN then
			coinNum = coinNum + v.num
		elseif v.itemId == ItemType.GOLD then
			goldNum = goldNum + v.num
		elseif v.itemId == ItemType.INFINITE_ENERGY_BOTTLE then
			hasInfiniteEnergy = true
		elseif v.itemId == ItemType.INFINITE_ENERGY_BOTTLE_ONE_MINUTE then
			hasInfiniteEnergy = true
		elseif v.itemId == ItemType.STAR_BANK_GOLD then
			goldNum = goldNum + v.num
		else
			table.insert(bagItems,v)
		end
	end

	local animCount = 0
	local finishCount = 0

	local function finishCallback( ... )
		finishCount = finishCount + 1
		if finishCount >= animCount then
			self:onFinish()
		end
	end

	if coinNum > 0 then
		self.flyCoin = FlyTopCoinAni:create(coinNum)

		self.flyCoin:setFinishCallback(finishCallback)
		self:addChild(self.flyCoin)
		animCount = animCount + 1
	end

	if goldNum > 0 then
		self.flyGold = FlyTopGoldAni:create(goldNum)

		self.flyGold:setFinishCallback(finishCallback)
		self:addChild(self.flyGold)
		animCount = animCount + 1
	end

	if #bagItems > 0 then
		local flyDuration = nil
		local delayTime = nil
		if otherParams then flyDuration = otherParams.flyDuration end
		if otherParams then delayTime = otherParams.delayTime end

		self.flyBag = FlyBagAnimation:create(bagItems, flyDuration, delayTime)
		self.flyBag:setFinishCallback(finishCallback)
		self:addChild(self.flyBag)
		animCount = animCount + 1
	end

	if hasInfiniteEnergy then
		self.flyInfiniteEnergy = FlyTopEnergyBottleAni:create(ItemType.INFINITE_ENERGY_BOTTLE)

		self.flyInfiniteEnergy:setFinishCallback(finishCallback)
		self:addChild(self.flyInfiniteEnergy)
		animCount = animCount + 1
	end
end

function FlyItemsAnimation:setFinishCallback( finishCallback )
	self.finishCallback = finishCallback
end

function FlyItemsAnimation:onFinish( ... )
	-- PopoutManager:remove(self)
	if self.scene and not self.scene.isDisposed then
		self.scene:superRemoveChild(self)
	end
	if self.finishCallback then
		self.finishCallback()
	end
end

function FlyItemsAnimation:setWorldPosition( worldPos )
	self.worldPos = worldPos

	if self.flyInfiniteEnergy then
		self.flyInfiniteEnergy:setWorldPosition(worldPos)
	end
end

function FlyItemsAnimation:play( ... )

	if not self.scene or self.scene.isDisposed then
		if self.finishCallback then
			self.finishCallback()
		end
		self:dispose()
		return
	end
	-- PopoutManager:add(self,false,true)
	self.scene:superAddChild(self)


	if self.worldPos then
		self:setPosition(self:getParent():convertToNodeSpace(self.worldPos))
	end

	if self.flyCoin then
		self.flyCoin:play()
	end
	if self.flyGold then
		self.flyGold:play()
	end
	if self.flyBag then
		self.flyBag:play()
	end
	if self.flyInfiniteEnergy then
		self.flyInfiniteEnergy:play()
	end
end

function FlyItemsAnimation:playWithDelay( delay )

	if not self.scene or self.scene.isDisposed then
		if self.finishCallback then
			self.finishCallback()
		end
		self:dispose()
		return
	end
	-- PopoutManager:add(self,false,true)
	self.scene:superAddChild(self)
    if self.worldPos then
		self:setPosition(self:getParent():convertToNodeSpace(self.worldPos))
	end

    local function fly()

	    if self.flyCoin then
		    self.flyCoin:play()
	    end
	    if self.flyGold then
		    self.flyGold:play()
	    end
	    if self.flyBag then
		    self.flyBag:play()
	    end
	    if self.flyInfiniteEnergy then
		    self.flyInfiniteEnergy:play()
	    end
    end

    setTimeOut( fly, delay )

end

function FlyItemsAnimation:setScale( scale )
	if self.flyBag then
		self.flyBag:setScale(scale)
	end
	if self.flyGold then
		self.flyGold:setScale(scale)
	end
end

function FlyItemsAnimation:setScaleX( scaleX )
	if self.flyBag then
		self.flyBag:setScaleX(scaleX)
	end
	if self.flyGold then
		self.flyGold:setScaleX(scaleX)
	end
end

function FlyItemsAnimation:setScaleY( scaleY )
	if self.flyBag then
		self.flyBag:setScaleY(scaleY)
	end
	if self.flyGold then
		self.flyGold:setScaleY(scaleY)
	end
end