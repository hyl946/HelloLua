
require 'zoo.quarterlyRankRace.plugins.BasePlugin'

local HScroll = class(BasePlugin)

function HScroll:onPluginInit( ... )

	if not BasePlugin.onPluginInit(self, ...) then return false end
	
	local sizeNode = self:getChildByPath('size')

	if not sizeNode then
		return false
	end

	local size = sizeNode:getContentSize()
	local sx, sy = sizeNode:getScaleX(), sizeNode:getScaleY()
	size = CCSizeMake(sx * size.width, sy * size.height)
	sizeNode:setVisible(false)

	self.scroll = HorizontalScrollable:create(size.width, size.height, true, true)
	self.scroll:setIgnoreHorizontalMove(false)

	self:addChild(self.scroll)

	self.layout = HorizontalTileLayout:create(size.height)
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

function HScroll:addItem( item, index )
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

function HScroll:getItemNum( ... )
	if self.isDisposed then return end
	return #(self.layout:getItems())
end

function HScroll:getItems( ... )
	if self.isDisposed then return end
	return self.layout:getItems()
end

function HScroll:removeItem( item, playAnim)
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

function HScroll:removeAllItems( playAnim)
	if self.isDisposed then return end
    playAnim = playAnim or false

	for _, v in ipairs(self.layout:getItems() or {}) do
		local index = v:getArrayIndex()
		self.layout:removeItemAt(index, playAnim)
		self.scroll:updateScrollableHeight()
		self.scroll:updateContentViewArea()
	end
end

function HScroll:pluginRefresh( ... )
	if self.isDisposed then return end
	self.layout:__layout()
	self.scroll:updateScrollableHeight()
	self.scroll:updateContentViewArea()
	return false
end

function HScroll:updateItemsHeight( ... )
	if self.isDisposed then return end
	for _, v in ipairs(self.layout:getItems()) do
		v:updateContentHeight()
	end
end

function HScroll:setItemVerticalMargin(gap)
	if self.isDisposed then return end
	if self.layout then self.layout:setItemVerticalMargin(gap) end
end
return HScroll