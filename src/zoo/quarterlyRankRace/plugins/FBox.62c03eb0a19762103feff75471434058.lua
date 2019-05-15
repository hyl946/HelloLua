
require 'zoo.quarterlyRankRace.plugins.BasePlugin'

require 'zoo.panel.happyCoinShop.FlowLayout'


local FBox = class(BasePlugin)

function FBox:onPluginInit( ... )

	if not BasePlugin.onPluginInit(self, ...) then return false end
	
	local sizeNode = self:getChildByPath('size')

	if not sizeNode then
		return false
	end

	local size = sizeNode:getContentSize()
	local sx, sy = sizeNode:getScaleX(), sizeNode:getScaleY()
	size = CCSizeMake(sx * size.width, sy * size.height)
	sizeNode:setVisible(false)

	self.layout = FlowLayout:create(size.width, 0, 0)
	self:addChild(self.layout)

	for i = 1, 999 do
		local item = self:getChildByPath('./item' .. i)
		if item then
			item:removeFromParentAndCleanup(false)
			item:setPosition(ccp(0, 0))
			item:setRotation(0)
			item:setScaleX(1)
			item:setScaleY(1)
			local layoutItem = ItemInLayout:create()
			layoutItem:setContent(item)
			self.layout:addItem(layoutItem)
		else
			break
		end
	end
	
	return true
end

function FBox:addItem( item )
	if self.isDisposed then return end
	local layoutItem = ItemInLayout:create()
	layoutItem:setContent(item)
	self.layout:addItem(layoutItem)
end

function FBox:refresh( ... )
	if self.isDisposed then return end
	self.layout:__layout()
end



function FBox:setItemVisible( index, bVisible )
	if self.isDisposed then return end
	local item = self.layout:getItems()[index]
	if item then
		item:setVisible(bVisible)
	end
	self.layout:__layout()
end

function FBox:getWidth( ... )
	if self.isDisposed then return end
	return self.layout:getWidth()
end

function FBox:removeItem( item, playAnim)
	if self.isDisposed then return end
	for _, v in ipairs(self.layout:getItems() or {}) do
		if v:getContent() == item then
			local index = v:getArrayIndex()
			self.layout:removeItemAt(index, playAnim)
			return
		end
	end
end

function FBox:setMargin( v, h )
	if self.isDisposed then return end
	self.layout:setMargin(v, h)
end

function FBox:setBorder( v, h )
	if self.isDisposed then return end
	self.layout:setBorder(v, h)
end

return FBox