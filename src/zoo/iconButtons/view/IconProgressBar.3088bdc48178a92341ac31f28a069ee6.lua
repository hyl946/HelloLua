
local IconProgressBar = class(BaseUI)

function IconProgressBar:ctor()
end

function IconProgressBar:init(ui, curNum, totalNum, minPercent)
	BaseUI.init(self, ui)

	self.curNum = curNum
	self.totalNum = totalNum
	self.minLimitPercent = minPercent

	self.bar	= self.ui:getChildByName("bar")
	local clippingMask	= self.ui:getChildByName("c_mask")

	self.barInitialPosX 	= self.bar:getPositionX()
	self.barInitialPosY 	= self.bar:getPositionY()
	self.barWidth		= self.bar:getGroupBounds().size.width
	self.barZeroPercentX	= self.barInitialPosX - self.barWidth

	clippingMask:removeFromParentAndCleanup(false)
	self.bar:removeFromParentAndCleanup(false)

	local clipping		= ClippingNode.new(CCClippingNode:create(clippingMask.refCocosObj))
	clipping:setAlphaThreshold(0.1)
	clipping:addChild(self.bar)

	local childIndex = self.ui:getChildIndex(self.ui:getChildByName("mask"))
	self.ui:addChildAt(clipping, childIndex)

	local manualAdjustClippingPosX	= 1
	local manualAdjustClippingPosY	= 0

	local curClippingPos	= clipping:getPosition()
	clipping:setPosition(ccp(curClippingPos.x + manualAdjustClippingPosX, curClippingPos.y + manualAdjustClippingPosY))
	
	self:setCurNumber(curNum, true)
	self:setTotalNumber(totalNum)

	clippingMask:dispose()
end

function IconProgressBar:_setPercentage(percentage)
	if percentage <= 0 then
		percentage = 0
	elseif percentage >= 1 then
		percentage = 1
	elseif self.minLimitPercent then
		if percentage < self.minLimitPercent then
			percentage = self.minLimitPercent 
		end
	end

	local width = self.barWidth * percentage
	local newPosX = self.barZeroPercentX + width
	self.bar:setPositionX(newPosX)
end

function IconProgressBar:setCurNumber(curNum, delayChange)
	self.curNum = curNum

	if not delayChange then 
		local percentage = self.curNum / self.totalNum
		self:_setPercentage(percentage)
	end
end

function IconProgressBar:setTotalNumber(totalNum, delayChange)
	self.totalNum = totalNum

	if not delayChange then 
		local percentage = self.curNum / self.totalNum
		self:_setPercentage(percentage)
	end
end

function IconProgressBar:create(ui, curNum, totalNum, minPercent)
	local bar = IconProgressBar.new()
	bar:init(ui, curNum, totalNum, minPercent)
	return bar
end

return IconProgressBar