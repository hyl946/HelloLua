
require 'zoo.quarterlyRankRace.plugins.BasePlugin'

local VScroll = class(BasePlugin)

function VScroll:onPluginInit( ... )

	if not BasePlugin.onPluginInit(self, ...) then return false end
	
	local sizeNode = self:getChildByPath('size')

	if not sizeNode then
		return false
	end

	local size = sizeNode:getContentSize()
	local sx, sy = sizeNode:getScaleX(), sizeNode:getScaleY()
	size = CCSizeMake(sx * size.width, sy * size.height)
	sizeNode:setVisible(false)

	self.scroll = VerticalScrollable:create(size.width, size.height, true, true)
	self.scroll:setIgnoreHorizontalMove(false)

	self:addChild(self.scroll)

	self.layout = VerticalTileLayout:create(size.width)
	self.scroll:setContent(self.layout)

	for i = 1, 999 do
		local item = self:getChildByPath('./item' .. i)
		if item then
			item:removeFromParentAndCleanup(false)
			item:setPosition(ccp(0, 0))
			item:setRotation(0)
			item:setScaleX(1)
			item:setScaleY(1)
			local layoutItem = ItemInClippingNode:create()
			layoutItem:setContent(item)
			layoutItem:setParentView(self.scroll)
			self.layout:addItem(layoutItem)
		else
			break
		end
	end

	return true
end

function VScroll:addItem( item, index )
	if self.isDisposed then return end
	local layoutItem = ItemInClippingNode:create()
	layoutItem:setContent(item)
	layoutItem:setParentView(self.scroll)
	if index then
		self.layout:addItemAt(layoutItem, index)
	else
		self.layout:addItem(layoutItem)
	end
	self.scroll:updateScrollableHeight()
	self.scroll:updateContentViewArea()
end

function VScroll:getItemNum( ... )
	if self.isDisposed then return end
	return #(self.layout:getItems())
end

function VScroll:getItems( ... )
	if self.isDisposed then return end
	return self.layout:getItems()
end

function VScroll:removeItem( item, playAnim)
	if self.isDisposed then return end

	for _, v in ipairs(self.layout:getItems() or {}) do
		if v:getContent() == item then
			local index = v:getArrayIndex()
			self.layout:removeItemAt(index, playAnim)
			self.scroll:updateScrollableHeight()
			self.scroll:updateContentViewArea()
			return
		end
	end
end

function VScroll:removeAllItems( playAnim)
	if self.isDisposed then return end
    playAnim = playAnim or false

	for _, v in ipairs(self.layout:getItems() or {}) do
		local index = v:getArrayIndex()
		self.layout:removeItemAt(index, playAnim)
		self.scroll:updateScrollableHeight()
		self.scroll:updateContentViewArea()
	end
end

function VScroll:pluginRefresh( ... )
	if self.isDisposed then return end
	self.layout:__layout()
	self.scroll:updateScrollableHeight()
	self.scroll:updateContentViewArea()
	return false
end

function VScroll:updateItemsHeight( ... )
	if self.isDisposed then return end
	for _, v in ipairs(self.layout:getItems()) do
		v:updateContentHeight()
	end
end

function VScroll:setItemVerticalMargin(gap)
	if self.isDisposed then return end
	if self.layout then self.layout:setItemVerticalMargin(gap) end
end
return VScroll