
LayoutBar = class(CocosObject)

LayoutBar.Direction = {
	TOP2BOTTOM = 1,
	BOTTOM2TOP = 2,
}

function LayoutBar:ctor()
end

function LayoutBar:init(direction)
	self.direction		= direction

	self.addedChildren	= {}
	self.childrenLayer	= self
end

function LayoutBar:create(direction)
	local newLayoutBar = LayoutBar.new(CCNode:create())
	newLayoutBar:init(direction)
	return newLayoutBar
end


function LayoutBar:addItem(child)
	self.childrenLayer:addChildAt(child, 0)
	table.insert(self.addedChildren, child)

	self:layout()
end

function LayoutBar:addItemAt(child, index)
	index = math.min(math.max(index, 1), #self.addedChildren + 1)
	self.childrenLayer:addChildAt(child, 0)
	table.insert(self.addedChildren,index,child)
	self:layout()
end

function LayoutBar:getItemAtIndex(index)
	return self.addedChildren[index]
end

function LayoutBar:getItemIndex( child )
	return table.indexOf(self.addedChildren,child)
end

function LayoutBar:containsItem(child)
	return self.childrenLayer:contains(child)
end

function LayoutBar:removeItem(child, cleanup)
	for k,v in pairs(self.addedChildren) do
		if v == child then
			table.remove(self.addedChildren, k)
			if cleanup == nil then cleanup = true end
			child:removeFromParentAndCleanup(cleanup)
			self:layout()
			return 
		end
	end
end

function LayoutBar:removeAllItems(cleanup)
	for k, v in pairs(self.addedChildren) do
		v:removeFromParentAndCleanup(cleanup)
	end
	self.addedChildren = {}
	self:layout()
end

function LayoutBar:layout()
	if self.direction == self.Direction.TOP2BOTTOM then
		for i,v in ipairs(self.addedChildren) do
			if not v.__isPlayingHomeSceneFlyAnim then
				v:setPosition(ccp(v:getHorizontalCenterOffsetX(), v:getVerticalCenterOffsetY() - (96 + 20) * (i - 1)))
			end
		end
	end

	if self.direction == self.Direction.BOTTOM2TOP then
		for i,v in ipairs(self.addedChildren) do
			if not v.__isPlayingHomeSceneFlyAnim then
				v:setPosition(ccp(v:getHorizontalCenterOffsetX(), v:getVerticalCenterOffsetY() + 96 + (96 + 20) * (i - 1)))
			end
		end
	end
end

function LayoutBar:getChildrenCount()
	return #self.addedChildren
end