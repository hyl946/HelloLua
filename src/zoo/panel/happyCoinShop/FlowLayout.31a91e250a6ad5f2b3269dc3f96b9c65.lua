---------------------------------------------------------
-- This class intends to describe a container which is able to 
-- automatically layout items vertically. Also this class is supposed
-- to be used with VerticalScrollable class which works as a clipping to show 
-- only limited view area and as a scrollable container, and VerticalTileItem which is 
-- the base class for items to add into VerticalTileLayout. Some functions of 
-- VerticalTileItem are essential for this class to process layout.
-- 

FlowLayout = class(Layer)

function FlowLayout:create(width, verticalMargin, horizontalMargin)
	local instance = FlowLayout.new()
	instance:init(width, verticalMargin, horizontalMargin)
	return instance
end

function FlowLayout:ctor()
	Layer.initLayer(self)
	self.name = 'FlowLayout'
	-- self.debugTag = 1
end

function FlowLayout:init(width, verticalMargin, horizontalMargin)

	self:ignoreAnchorPointForPosition(true)
	self:setAnchorPoint(ccp(0, 1))

	self.width = width
	self.maxHeight = 0
	self.lastY = 0
	self.mostRightX = 0

	self.itemVerticalMargin = verticalMargin
	self.itemHorizontalMargin = horizontalMargin
	self.verticalBorder = 0
	self.horizontalBorder = 0

	self.items = {}

	local container = Layer:create()
	container.name = 'FlowLayout.container'
	container.debugTag = 1

	self.container = container

	self:addChild(self.container)


end

-- to avoid multiple layout calls 
function FlowLayout:addItemBatch(itemList)
	if not itemList or type(itemList) ~= 'table' then
		itemList = {}
	end

	local arrayIndex = #self.items + 1
	-- if _G.isLocalDevelopMode then printx(0, 'arrayIndex', arrayIndex) end
	for key, item in pairs(itemList) do

		table.insert(self.items, item)
		item:setArrayIndex(arrayIndex)
		self.container:addChild(item)
		arrayIndex = arrayIndex + 1
	end

	self:__layout()
end

function FlowLayout:addItem(item)
	self:addItemAt(item, #self.items + 1)
end


function FlowLayout:addItemAt(item, arrayIndex)
	if not item then return end
	if arrayIndex > #self.items + 1 then return end

	table.insert(self.items, arrayIndex, item)

	for k, v in pairs(self.items) do
		-- assert(type(v.setArrayIndex) == 'function', 'VerticalTileLayout:addItemAt(): item must inherits ItemInLayout')
		v:setArrayIndex(k)
	end

	self.container:addChild(item)

	self:__layout()
end

function FlowLayout:removeAllItems()
	if self.items then 
		for k, v in pairs(self.items) do
			if v:getParent() then 
				v:removeFromParentAndCleanup(true)
				v = nil
			end
		end
	end
	self.items = {}
end



function FlowLayout:removeItem()
	self:removeItemAt(#self.items)
end

function FlowLayout:removeItemAt(arrayIndex)
	if arrayIndex > #self.items then return end
	local item = self.items[arrayIndex]
	local height = item:getHeight()

	table.remove(self.items, arrayIndex)

	for k, v in pairs(self.items) do 
		v:setArrayIndex(k)
	end
	local function __removeItemUI()
		if item and not item.isDisposed and item:getParent() then 
			item:removeFromParentAndCleanup(true) 
			item = nil
		end
	end

	
	__removeItemUI()

	self:__layout()
end

function FlowLayout:getItems()
	return self.items
end

-- during the animation, the height is not accurate
-- this function returns the static height
function FlowLayout:getHeight()
	if #self.items == 0 then return 0 end
	return self.maxHeight
end


function FlowLayout:__layout()
	if #self.items == 0 then return end

	self.maxHeight = 0
	self.lastY = self.verticalBorder
	self.mostRightX = 0

	for i, item in pairs(self.items) do 
		item:setAnchorPoint(ccp(0, 0))
		if self:__isNeedNewLine(item) then
			local y = self.maxHeight + self.itemVerticalMargin
			local x = 3 + self.horizontalBorder
			item:setPosition(ccp(x, -y))
			self.maxHeight = y + item:getHeight()
			self.mostRightX = x + item:getWidth()
			self.lastY = y
		else
			local x = self.mostRightX + self.itemHorizontalMargin
			if self.mostRightX == 0 then
				x = 3 + self.horizontalBorder
			end
			local y = self.lastY
			item:setPosition(ccp(x, -y))
			self.maxHeight = math.max(self.maxHeight, y + item:getHeight())
			self.mostRightX = x + item:getWidth()
		end
	end
end

function FlowLayout:__isNeedNewLine(item)
	return item:getWidth() + self.mostRightX + self.itemHorizontalMargin > self.width - self.horizontalBorder
end


function FlowLayout:dispose()
	self.items = {}
	self.width = nil
	self.itemVerticalMargin = nil
	self.itemHorizontalMargin = nil
	self.animationDuration = nil
	self.container = nil
	CocosObject.dispose(self)

end

function FlowLayout:setMargin( verticalMargin, horizontalMargin )
	-- body
	self.itemVerticalMargin = verticalMargin
	self.itemHorizontalMargin = horizontalMargin
	self:__layout()
end

function FlowLayout:setBorder( vb, hb )
	self.verticalBorder = vb
	self.horizontalBorder = hb
	self:__layout()
end

function FlowLayout:updateViewArea(visibleTop, visibleBottom)
	table.each(self.items, function(item)
		if item.isDisposed then return end
		local ui = item:getContent()
		if ui == nil or ui.isDisposed then return end
		local y = item:getPositionY()
		local height = item:getHeight()
		local areaTop, areaBottom = 230, 290
		if ui.getBuyBtnArea then
			areaTop, areaBottom = ui:getBuyBtnArea()
		end
		if -y < visibleTop - areaBottom or -y > visibleBottom - areaTop  then
			if ui.setOutSideView then
				ui:setOutSideView(true)
			end
		else
			if ui.setOutSideView then
				ui:setOutSideView(false)
			end
		end
	end)
end