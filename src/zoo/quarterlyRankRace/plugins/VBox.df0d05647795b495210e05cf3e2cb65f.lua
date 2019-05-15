
require 'zoo.quarterlyRankRace.plugins.BasePlugin'

local VBox = class(BasePlugin)

function VBox:onPluginInit( ... )

	if not BasePlugin.onPluginInit(self, ...) then return false end
	
	local sizeNode = self:getChildByPath('size')

	if not sizeNode then
		return false
	end

	local size = sizeNode:getContentSize()
	local sx, sy = sizeNode:getScaleX(), sizeNode:getScaleY()
	size = CCSizeMake(sx * size.width, sy * size.height)
	sizeNode:setVisible(false)
	self.layout = VerticalTileLayout:create(size.width)
	self.layout:setCareItemVisible(true)
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
			layoutItem:setContent(item, true)
			self.layout:addItem(layoutItem)
		else
			break
		end
	end

	return true
end

function VBox:addItem( item )
	local layoutItem = ItemInLayout:create()
	layoutItem:setContent(item, true)
	self.layout:addItem(layoutItem)
end

function VBox:refresh( ... )
	if self.isDisposed then return end
	self.layout:__layout()
end

function VBox:updateItemsHeight( ... )
	if self.isDisposed then return end
	for _, v in ipairs(self.layout:getItems()) do
		v:updateContentHeight()
	end
end



function VBox:setItemVisible( index, bVisible )
	if self.isDisposed then return end
	local item = self.layout:getItems()[index]
	if item then
		item:getContent():setVisible(bVisible)
	end
	self.layout:__layout()
end

function VBox:getItem( index )
	if self.isDisposed then return end
	local item = self.layout:getItems()[index]
	return item:getContent()
end

return VBox