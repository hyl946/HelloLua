

-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年09月 2日 14:14:19
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

require "hecore.display.Layer"
---------------------------------------------------
-------------- RegionLayoutBar
---------------------------------------------------

assert(not LayoutBarAlign)
LayoutBarAlign = {
	LEFT			= 1,
	RIGHT			= 2,
	HORIZONTAL_CENTER	= 3,

	TOP			= 5,
	BOTTOM			= 6,
	VERTICAL_CENTER		= 7,
}

assert(not LayoutBarDirection)
LayoutBarDirection = {

	HORIZONTAL	= 1,
	VERTICAL	= 2
}

assert(not RegionLayoutBar)
assert(Layer)
RegionLayoutBar = class(Layer)

function RegionLayoutBar:ctor()
end

function RegionLayoutBar:init(width, height, alignHorizontal, alignVertical, direction, ...)
	assert(width)
	assert(height)
	assert(width > 0)
	assert(height > 0)

	assert(alignHorizontal)
	assert(
		alignHorizontal == LayoutBarAlign.LEFT or
		alignHorizontal == LayoutBarAlign.RIGHT or 
		alignHorizontal == LayoutBarAlign.HORIZONTAL_CENTER)

	assert(alignVertical)
	assert(alignVertical == LayoutBarAlign.TOP or
		alignVertical == LayoutBarAlign.BOTTOM or
		alignVertical == LayoutBarAlign.VERTICAL_CENTER)

	assert(direction)
	assert(direction == LayoutBarDirection.HORIZONTAL or
		direction == LayoutBarDirection.VERTICAL) 

	assert(#{...} == 0)


	-- Init Base Class
	Layer.initLayer(self)

	self.width	= width
	self.height	= height

	self.alignHorizontal	= alignHorizontal
	self.alignVertical	= alignVertical
	self.direction		= direction

	-- Margin
	self.horizontalMargin		= 10
	self.verticalMargin		= 10
	-- Interval
	self.verticalInterval	= 20
	self.horizontalInterval	= 20

	self.addedChildren	= {}
	self.childrenLayer	= Layer:create()
	self:addChild(self.childrenLayer)
end

function RegionLayoutBar:setVertialInterval(interval, ...)
	assert(interval)
	assert(#{...} == 0)

	self.verticalInterval	= interval
	self:layout()
end

function RegionLayoutBar:setHorizontalInvertal(interval, ...)
	assert(interval)
	assert(#{...} == 0)

	self.horizontalInterval	= interval
	self:layout()
end

function RegionLayoutBar:serHorizontalMargin(margin, ...)
	assert(margin)
	assert(#{...} == 0)

	if self.horizontalMargin == margin then return end

	self.horizontalMargin	= margin

	self:layout()
end

function RegionLayoutBar:setVerticalMargin(margin, ...)
	assert(margin)
	assert(#{...} == 0)

	if self.verticalMargin == margin then return end
	self.verticalMargin	= margin

	self:layout()
end

function RegionLayoutBar:create(width, height, alignHorizontal, alignVertical, direction, ...)
	assert(width)
	assert(width > 0)
	assert(height)
	assert(height > 0)
	assert(alignHorizontal)
	assert(
		alignHorizontal == LayoutBarAlign.LEFT or
		alignHorizontal == LayoutBarAlign.RIGHT or 
		alignHorizontal == LayoutBarAlign.HORIZONTAL_CENTER)

	assert(alignVertical)
	assert(alignVertical == LayoutBarAlign.TOP or
		alignVertical == LayoutBarAlign.BOTTOM or
		alignVertical == LayoutBarAlign.VERTICAL_CENTER)

	assert(direction)
	assert(direction == LayoutBarDirection.HORIZONTAL or
		direction == LayoutBarDirection.VERTICAL) 

	assert(#{...} == 0)

	local newLayoutBar = RegionLayoutBar.new()
	newLayoutBar:init(width, height, alignHorizontal, alignVertical, direction)
	return newLayoutBar
end

function RegionLayoutBar:layout(...)
	assert(#{...} == 0)

	-- Adjust Interval
	self:adjustInterval()

	-- Layout Children Horizontally Or Vertically
	local leftMostAvailableX	= 0
	local topMostAvailableY		= 0

	local maxWidth
	if self.direction == LayoutBarDirection.VERTICAL then
		for index,child in ipairs(self.addedChildren) do
			local childWidth = child:getGroupBounds().size.width
			if not maxWidth or childWidth > maxWidth then
				maxWidth = childWidth
			end
		end
	end

	for index,child in ipairs(self.addedChildren) do
		local marginLeft = (maxWidth - child:getGroupBounds().size.width) / 2
		if self.direction == LayoutBarDirection.VERTICAL then leftMostAvailableX = marginLeft end

		child:setPosition(ccp(leftMostAvailableX, topMostAvailableY))

		if self.direction == LayoutBarDirection.HORIZONTAL then
			local childWidth	= child:getGroupBounds().size.width
			leftMostAvailableX	= leftMostAvailableX + childWidth + self.horizontalInterval
		elseif self.direction == LayoutBarDirection.VERTICAL then
			local childHeight	= child:getGroupBounds().size.height
			-- topMostAvailableY	= topMostAvailableY - childHeight - self.verticalInterval
			topMostAvailableY = topMostAvailableY - 108
		else
			assert(false)
		end
	end

	-- childrenLayer Size
	local childrenLayerBounds	= self.childrenLayer:getGroupBounds()
	local childrenLayerOrigin	= childrenLayerBounds.origin
	-- local childrenLayerWidth	= childrenLayerBounds.size.width

	-- BUG FIX
	local childrenLayerWidth = 0 
	for k, v in pairs(self.addedChildren) do 
		if v.wrapper then
			childrenLayerWidth = math.max(childrenLayerWidth, v.wrapper:getGroupBounds().size.width)
		end
	end
	-- END OF FIX

	local childrenLayerHeight	= childrenLayerBounds.size.height

	-- ---------------------
	-- Align Horizontal
	-- ---------------------
	
	local positionX	= false

	if self.alignHorizontal == LayoutBarAlign.LEFT then

		positionX = self.horizontalMargin

	elseif self.alignHorizontal == LayoutBarAlign.RIGHT then

		-- positionX = self.width - childrenLayerWidth - self.horizontalMargin
		positionX = self.width - self.horizontalMargin - 100

	elseif self.alignHorizontal == LayoutBarAlign.HORIZONTAL_CENTER then

		local deltaWidth	= self.width - childrenLayerWidth
		positionX		= deltaWidth / 2
	else
		assert(false)
	end

	self.childrenLayer:setPositionX(positionX)

	-- ------------------
	-- Align Vertical
	-- -----------------
	
	local positionY	= false

	if self.alignVertical == LayoutBarAlign.TOP then

		positionY = -self.verticalMargin

	elseif self.alignVertical == LayoutBarAlign.BOTTOM then

		local childrenLayerPositionY	= self.childrenLayer:getPositionY()
		positionY = childrenLayerPositionY - childrenLayerOrigin.y

	elseif self.alignVertical == LayoutBarAlign.VERTICAL_CENTER then

		local deltaHeight = self.height - childrenLayerHeight
		positionY = -deltaHeight / 2
	else
		assert(false)
	end

	self.childrenLayer:setPositionY(positionY)
end

function RegionLayoutBar:addItem(child, ...)
	assert(child)
	assert(#{...} == 0)

	self.childrenLayer:addChildAt(child, 0)
	table.insert(self.addedChildren, child)

	self:layout()
end

function RegionLayoutBar:addItemAt(child,index)

	index = math.min(math.max(index,1),#self.addedChildren + 1)

	self.childrenLayer:addChildAt(child,0)
	table.insert(self.addedChildren,index,child)

	self:layout()
end

function RegionLayoutBar:getItemIndex( child )
	return table.indexOf(self.addedChildren,child)
end

function RegionLayoutBar:containsItem(child, ...)
	assert(child)
	assert(#{...} == 0)

	return self.childrenLayer:contains(child)
end

function RegionLayoutBar:removeItem(child, cleanup, ...)
	assert(child)
	assert(#{...} == 0)

	for k,v in pairs(self.addedChildren) do

		if v == child then

			table.remove(self.addedChildren, k)
			if cleanup == nil then cleanup = true end
			child:removeFromParentAndCleanup(cleanup)
			self:layout()
			return 
		end
	end
	--assert(false)
end

function RegionLayoutBar:calculateNeededWidth(...)
	assert(#{...} == 0)

	local neededWidth = 2 * self.horizontalMargin

	for index,child in ipairs(self.addedChildren) do

		local childWidth	= child:getGroupBounds().size.width
		neededWidth		= neededWidth + childWidth + self.horizontalInterval
	end

	neededWidth = neededWidth - self.horizontalInterval

	return neededWidth
end

function RegionLayoutBar:calculateNeededHeight(...)
	assert(#{...} == 0)

	local neededHeight = 2 * self.verticalMargin

	for index,child in ipairs(self.addedChildren) do

		local childHeight	= child:getGroupBounds().size.height
		neededHeight		= neededHeight + childHeight + self.verticalInterval
	end

	neededHeight = neededHeight - self.verticalInterval

	return neededHeight
end

function RegionLayoutBar:adjustInterval(...)
	assert(#{...} == 0)

	if self.direction == LayoutBarDirection.HORIZONTAL then

		local neededWidth = self:calculateNeededWidth()

		if neededWidth > self.width then

			self.horizontalInterval = 0 
			local neededWidthWithNoInterval = self:calculateNeededWidth()

			local deltaWidth = self.width - neededWidthWithNoInterval

			assert(#self.addedChildren > 1)
			self.horizontalInterval = deltaWidth / (#self.addedChildren - 1)
		end

	elseif self.direction == LayoutBarDirection.VERTICAL then

		local neededHeight = self:calculateNeededHeight()

		if neededHeight > self.height then

			self.verticalInterval = 0

			local neededHeightWithNoInterval = self:calculateNeededHeight()
			local deltaHeight = self.height - neededHeightWithNoInterval

			assert(#self.addedChildren > 1)
			self.verticalInterval  = deltaHeight / (#self.addedChildren - 1)
		end
	else
		assert(false)
	end
end
