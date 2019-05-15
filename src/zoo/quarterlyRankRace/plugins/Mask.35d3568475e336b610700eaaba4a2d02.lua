
require 'zoo.quarterlyRankRace.plugins.BasePlugin'

local Mask = class(BasePlugin)

function Mask:onPluginInit( ... )

	if not BasePlugin.onPluginInit(self, ...) then return false end
	
	local sizeNode = self:getChildByPath('size')

	if not sizeNode then
		return false
	end

	local size = sizeNode:getContentSize()
	local sx, sy = sizeNode:getScaleX(), sizeNode:getScaleY()
	size = CCSizeMake(sx * size.width, sy * size.height)
	sizeNode:setVisible(false)


	local clipping = SimpleClippingNode:create()
	clipping:setContentSize(CCSizeMake(size.width, size.height))
	clipping:setRecalcPosition(true)
    clipping:setAnchorPoint(ccp(0, 1))
    clipping:ignoreAnchorPointForPosition(false)
	self.clippingNode = clipping

	local contentNode = self:getChildByPath('content')
	if not contentNode then
		return false
	end

	contentNode:removeFromParentAndCleanup(false)
	self.clippingNode:addChild(contentNode)
	contentNode:setTag(HeDisplayUtil.kIgnoreGroupBounds)

    self.contentNode = contentNode
    self.contentNodePosY = contentNode:getPositionY()
    self.contentNodePosX = contentNode:getPositionX()

	self:addChild(self.clippingNode)

	self:setMaskAnchorPoint(ccp(0, 1))
	self:setMaskSize(size)

	return true
end

function Mask:getContentContainer( ... )
	return self.contentNode
end

function Mask:setMaskSize( size )
	if self.isDisposed then return end

	local oriSize = self:getOriMaskSize()
	if not oriSize then return end

	self.clippingNode:setContentSize(CCSizeMake(size.width, size.height))
	self.contentNode:setPositionY(self.contentNodePosY + oriSize.height + (oriSize.height -  size.height) * (0 - self.anchorPoint.y) )
	self.contentNode:setPositionX(self.contentNodePosX + (oriSize.width -  size.width) * (0 - self.anchorPoint.x) )
end

function Mask:getMaskSize( ... )
	if self.isDisposed then return end
	return self.clippingNode:getContentSize()
end

function Mask:getOriMaskSize( ... )
	if self.isDisposed then return end

	local sizeNode = self:getChildByPath('size')
	if not sizeNode then
		return false
	end
	local size = sizeNode:getContentSize()
	local sx, sy = sizeNode:getScaleX(), sizeNode:getScaleY()
	size = CCSizeMake(sx * size.width, sy * size.height)

	return size
end

function Mask:setMaskAnchorPoint( pos )
	if self.isDisposed then return end
	self.anchorPoint = pos
	self.clippingNode:setAnchorPointWhileStayOriginalPosition(pos)
end

function Mask:setMaskValue( percentageX,  percentageY)
	local size = self:getOriMaskSize()
	if not size then
		return
	end

	local newSize = CCSizeMake(percentageX * size.width, percentageY * size.height)
	self:setMaskSize(newSize)
end

function Mask:getScarphPos( ... )
	if self.isDisposed then return end
	
	local cp = self.clippingNode:getParent()

	local pos = self.clippingNode:getPosition()
	local anchorPoint = self.clippingNode:getAnchorPoint()


	local size = self.clippingNode:getContentSize()
	local scaleX = self.clippingNode:getScaleX()
	local scaleY = self.clippingNode:getScaleY()
	local w = size.width * scaleX
	local h = size.height * scaleY

	local center = ccp(pos.x + (0.5 -anchorPoint.x) *size.width , pos.y  + (0.5 - anchorPoint.y) * size.height)

	return table.map(function ( p )
		return cp:convertToWorldSpace(p)
	end, {
		ccp(center.x, center.y + h/2),
		ccp(center.x, center.y - h/2),
		ccp(center.x - w/2, center.y),
		ccp(center.x + w/2, center.y),
	})

end


return Mask