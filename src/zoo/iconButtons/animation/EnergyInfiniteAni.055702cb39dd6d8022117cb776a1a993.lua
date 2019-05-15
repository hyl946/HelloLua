local EnergyInfiniteAni = class(BaseUI)

function EnergyInfiniteAni:ctor()
end

function EnergyInfiniteAni:init()
	self.ui = ResourceManager:sharedInstance():buildGroup("home_top_bar/icon_btn_energy_infinite")
	BaseUI.init(self, self.ui)

	local clippingMask = self.ui:getChildByName("c_mask")
	local bar1 = self.ui:getChildByName("bar1")
	local bar2 = self.ui:getChildByName("bar2")

	clippingMask:removeFromParentAndCleanup(false)
	bar1:removeFromParentAndCleanup(false)
	bar2:removeFromParentAndCleanup(false)

	local clipping		= ClippingNode.new(CCClippingNode:create(clippingMask.refCocosObj))
	clippingMask:dispose()
	clipping:setAlphaThreshold(0.1)
	clipping:addChild(bar1)
	clipping:addChild(bar2)
	local childIndex = self.ui:getChildIndex(self.ui:getChildByName("mask"))
	self.ui:addChildAt(clipping, childIndex)

	local bar1Pos = bar1:getPosition()
	local arr1 = CCArray:create()
	arr1:addObject(CCMoveTo:create(2.6, ccp(125, bar1Pos.y)))
	arr1:addObject(CCMoveTo:create(0, ccp(-115, bar1Pos.y)))
	bar1:runAction(CCRepeatForever:create(CCSequence:create(arr1)))

	local bar2Pos = bar2:getPosition()
	local arr2 = CCArray:create()
	arr2:addObject(CCMoveTo:create(1.3, ccp(100, bar2Pos.y)))
	arr2:addObject(CCMoveTo:create(0, ccp(-140, bar2Pos.y)))
	arr2:addObject(CCMoveTo:create(1.3, ccp(-20, bar2Pos.y)))
	bar2:runAction(CCRepeatForever:create(CCSequence:create(arr2)))
end

function EnergyInfiniteAni:create()
	local ani = EnergyInfiniteAni.new()
	ani:init()
	return ani
end

return EnergyInfiniteAni