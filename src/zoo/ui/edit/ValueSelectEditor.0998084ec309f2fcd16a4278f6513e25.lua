local SuperCls = require('zoo.ui.edit.EditInterface')

local defaultWidth = 300
local defaultHeight = 600

local VerticalStepScroll = require('zoo.ui.edit.VerticalStep')

local ValueSelectEditor = class(SuperCls)

function ValueSelectEditor:ctor( ... )
end

function ValueSelectEditor:init( width, height, itemHeight)
	if self.isDisposed then return end
	SuperCls.init(self)
	self.itemHeight = itemHeight

	local width = width or defaultWidth
	local height = height or defaultHeight

	self.width = width
	self.height = height


	self.cur = 1

	local function sign( x )
		if x >= 0 then return 1 else return -1 end
	end

    local scrollLayout = VerticalTileLayout:create(width)
    scrollLayout.itemVerticalMargin = 0

    self:addChild(scrollLayout)
    scrollLayout:setPositionY(height)

    self.scrollLayout = scrollLayout

    self:setContentSize(CCSizeMake(width, height))
    -- self:setColor(ccc3(255, 0, 0))
    -- self:setOpacity(255)
    self:setOpacity(0)




    self:setTouchEnabled(true, nil, true, function ( ... )
    	return true
    end)

    local function pointInRect( pos, rect )
    	return pos.x >= rect.left and pos.y >= rect.bottom and pos.x <= rect.right and pos.y <= rect.top
    end

    self:ad(DisplayEvents.kTouchBegin, function ( evt )
    	if self.isDisposed then return end

    	local pos = evt.globalPosition
    	pos = self:convertToNodeSpace(pos)
    	if not pointInRect(pos, {left = 0, bottom = 0, right = self.width, top = self.height}) then
    		self:hide()
    	end
    end)

    self:ad(DisplayEvents.kTouchTap, function ( evt )
    	if self.isDisposed then return end

    	local pos = evt.globalPosition
    	pos = self.scrollLayout:convertToNodeSpace(pos)


		local items = self.scrollLayout:getItems()
    	self.cur = math.floor(math.abs(pos.y) / self.itemHeight) + 1
    	self.cur = math.max(1, math.min(#items, self.cur))

    	self:notifyValueChange()
    	self:notifyItems()
    end)


end

function ValueSelectEditor:onAddToStage( ... )
	if self.isDisposed then return end
	self:notifyValueChange()
	self:notifyItems()
end


function ValueSelectEditor:setValue(v)
	if self.isDisposed then return end

	local items = self.scrollLayout:getItems()
	for index, item in ipairs(items) do
		if item:getContent():getValue() == v then
			self.cur = index
			self:notifyItems()
			return
		end
	end

	self:notifyValueChange()
	
end

function ValueSelectEditor:getValue( ... )
	-- body
	if self.isDisposed then return end
	local items = self.scrollLayout:getItems()
	local item = items[math.max(1, math.min(#items, self.cur))]
	return item:getContent():getValue()
end

function ValueSelectEditor:addItem( itemUI )
	if self.isDisposed then return end

	itemUI:setAnchorPoint(ccp(0.5, 0.5))

	itemUI:setPositionY(-self.itemHeight/2)

	local itemInLayout = ItemInLayout:create()
	itemInLayout:setContent(itemUI)
	itemInLayout:setHeight(self.itemHeight)
	itemInLayout:setContentSize(CCSizeMake(self.width, self.itemHeight))
	itemInLayout:setWidth(self.width)
	itemUI:setPositionX(self.width/2)
	itemInLayout:setAnchorPoint(ccp(0.5, 0))

	self.scrollLayout:addItem(itemInLayout)
end

function ValueSelectEditor:removeItem( itemUI )
	if self.isDisposed then return end
	local items = self.scrollLayout:getItems()

	for index, v in ipairs(items) do
		if v:getContent() == itemUI then
			self.scrollLayout:removeItemAt(index)
			return
		end
	end
	
end

function ValueSelectEditor:notifyItems(  )
	if self.isDisposed then return end
	local items = self.scrollLayout:getItems()
	local cur = math.max(1, math.min(#items, self.cur))
	for index, v in ipairs(items) do
		v:getContent():onFocus(cur == index)
	end
end

function ValueSelectEditor:create( width, height , itemHeight)
	local i = ValueSelectEditor.new()
	i:init(width, height, itemHeight)
	return i
end

return ValueSelectEditor