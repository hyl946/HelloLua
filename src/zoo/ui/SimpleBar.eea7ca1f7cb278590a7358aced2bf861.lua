local SimpleBar = class()
local BAR_DIRECTION = {HORIZONTAL = 1, VERTICAL_FROM_BOTTOM = 2, VERTICAL_FROM_TOP = 3}


--------------------------------------------------------------
-- SimpleBar 分水平方向从左至右，竖直方向从下到上，竖直方向从上到下 【最外层的bar anchorUI素材不支持旋转 anchor未调试】
-- ui  CocosObject  
-- direction 方向
-- barUI
-- anchorUI
--------------------------------------------------------------
function SimpleBar:create(barUI, barMask, anchorUI, direction)
	local targetBar = SimpleBar.new()
	targetBar:init(barUI, barMask, anchorUI, direction)
	return targetBar
end

function SimpleBar:init(barUI, barMask, anchorUI, direction)
	self.barUI = barUI
	self.anchorUI = anchorUI
	self.direction = direction
	self.barMask = barMask
	self.widthMargin = 0
	self.heightMargin = 0
	local barParent = self.barUI:getParent()
	local barBounds = self.barUI:getGroupBounds(barParent)
	self.barSize = CCSizeMake(barBounds.size.width, barBounds.size.height)

	local idx = barParent:getChildIndex(self.barUI)
	self.barUI:removeFromParentAndCleanup(false)
	self.barMask:removeFromParentAndCleanup(false)
	self.barClippingNode =  ClippingNode.new(CCClippingNode:create(self.barMask.refCocosObj))
	self.barClippingNode:addChild(self.barUI)
	self.barClippingNode:setAlphaThreshold(0.01)
	barParent:addChildAt(self.barClippingNode, idx)
	self.barMask:dispose()
end

function SimpleBar:setWidthMargin(v)
	self.widthMargin = v
end

function SimpleBar:setHeightMargin(v)
	self.heightMargin = v
end

function SimpleBar:setRate(v)
	if v <= 0 then v = 0
	elseif v > 1 then v = 1 end

	local anchorStopX, anchorStopY = self:getAnchorStopPosXY(v)
	local  scale = 1
	if self.direction == BAR_DIRECTION.HORIZONTAL then
		self.barUI:setPositionX(anchorStopX - self.barSize.width)
		if self.anchorUI ~= nil then self.anchorUI:setPositionX(anchorStopX) end
	elseif self.direction == BAR_DIRECTION.VERTICAL_FROM_BOTTOM then --未调试
		self.barUI:setPositionY(anchorStopY - self.barSize.height)
		if self.anchorUI ~= nil then self.anchorUI:setPositionY(anchorStopY) end
	elseif self.direction == BAR_DIRECTION.VERTICAL_FROM_TOP then --未调试
		self.barUI:setPositionY(anchorStopY - self.barSize.height)
		if self.anchorUI ~= nil then self.anchorUI:setPositionY(anchorStopY) end
	end
end

function SimpleBar:getAnchorStopPosXY(v)
	local anchorStopX, anchorStopY
	if self.direction == BAR_DIRECTION.HORIZONTAL then
		anchorStopX = (self.barSize.width - self.widthMargin) * v + self.widthMargin
		anchorStopY = self.barSize.height * 0.5
	elseif self.direction == BAR_DIRECTION.VERTICAL_FROM_BOTTOM then --未调试
		anchorStopX = self.barSize.width * 0.5
		anchorStopY = (self.barSize.width - self.heightMargin) * 0.5 + self.heightMargin
	elseif self.direction == BAR_DIRECTION.VERTICAL_FROM_TOP then --未调试
		anchorStopX = self.barSize.width * 0.5
		anchorStopY = (self.barSize.width - self.heightMargin) * 0.5 + self.heightMargin
	end

	return anchorStopX, anchorStopY
end

return SimpleBar