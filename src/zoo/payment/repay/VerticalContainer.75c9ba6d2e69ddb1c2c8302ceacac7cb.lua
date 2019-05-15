local layoutUtils =  require 'zoo.panel.happyCoinShop.utils'

local VerticalContainer = class(Layer)

function VerticalContainer:create(width, padding, bgSpriteFrameName)
	local container = VerticalContainer.new()
	container:initLayer()
	container:init(width, padding, bgSpriteFrameName)
	container.items = {}
	return container
end

function VerticalContainer:addItem( node , margin)

	self:addChild(node)

	local x = (self.width - node:getGroupBounds(self).size.width)/2

	layoutUtils.setNodeOriginPos(node, ccp(x, 0), self)

	table.insert(self.items, {
		node = node,
		margin = margin or {
			top = 6,
		}
	})

	layoutUtils.verticalLayoutItems(self.items)

	self:refreshBG()
end

function VerticalContainer:getHeight( ... )
	local height = 0

	for index, item in ipairs(self.items) do
		if item.node and (not item.node.isDisposed) then 
			height = height + item.node:getGroupBounds(self).size.height
			local padding = item.padding or {}
			local margin = item.margin or {}

			height = height + (padding.top or 0)
			height = height + (padding.bottom or 0)

			

			if self.items[index-1] then
				local prevMargin = self.items[index-1].margin or {}
				height = height + math.max(margin.top or 0, prevMargin.bottom or 0)
			end

			if index == #self.items then
				height = height + (margin.bottom or 0)
			end

			if index == 1 then
				height = height + (margin.top or 0)
			end

		end
	end



	return height
end

function VerticalContainer:init(width, padding, bgSpriteFrameName)
	self.width = width
	self.bgSpriteFrameName = bgSpriteFrameName
	self.padding = padding or {}

	if self.bgSpriteFrameName and CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(self.bgSpriteFrameName) then
		self.bg = Scale9SpriteColorAdjust:createWithSpriteFrameName(self.bgSpriteFrameName)
		self:addChild(self.bg)
		self.bg:setAnchorPoint(ccp(0, 1))
		self.bg:setPositionX(-(self.padding.left or 0))
		self.bg:setPositionY((self.padding.top or 0))
	end
end

function VerticalContainer:refreshBG( ... )
	if self.bg and (not self.bg.isDisposed) then
		self.bg:setPreferredSize(CCSizeMake(
			self.width + (self.padding.left or 0) + (self.padding.right or 0), 
			self:getHeight() + (self.padding.top or 0) + (self.padding.bottom or 0)
		))
	end
end

return VerticalContainer