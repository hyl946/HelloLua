local SuperCls = require('zoo.ui.edit.EditInterface')

local defaultWidth = 300
local defaultHeight = 600

local VerticalStepScroll = require('zoo.ui.edit.VerticalStep')

local ScrollEdit = class(SuperCls)

function ScrollEdit:ctor( ... )
end

function ScrollEdit:init( width, height, itemHeight, highColor, normalColor)
	if self.isDisposed then return end
	SuperCls.init(self)
	self.itemHeight = itemHeight

	local width = width or defaultWidth
	local height = height or defaultHeight

	self.width = width
	self.height = height

	local scroll = VerticalStepScroll:create(width, height, itemHeight)


	local function sign( x )
		if x >= 0 then return 1 else return -1 end
	end

	self:setColor(normalColor)

    scroll:setIgnoreHorizontalMove(false)
    local scrollLayout = VerticalTileLayout:create(width)
    scrollLayout.itemVerticalMargin = 0
    scroll:setContent(scrollLayout)
    -- scroll:ad(ScrollableEvents.kEndMoving, function ( ... )
    -- 	if self.isDisposed then return end
    -- 	local delta = scroll.yOffset - scroll.bottomMostOffset
    -- 	local newDelta = delta - delta % self.itemHeight
    -- 	if math.abs(newDelta - delta) > 2 then
    -- 		scroll:gotoPositionY(newDelta + scroll.bottomMostOffset)
    -- 	end
    -- end)


    scroll:updateScrollableHeight()
    self:addChild(scroll)
    scroll:setPositionY(height)

    self.scrollLayout = scrollLayout
    self.scroll = scroll

    self.cur = 1

    scroll.onScrollCallback = function ( offset, onlyUpdateFocus)
		if self.isDisposed then return end
		offset = offset + self.height / 2
		self.cur = math.floor(offset / self.itemHeight) + 1

		self:notifyItems()

		if onlyUpdateFocus then
			return
		end
		self:notifyValueChange()
    end

    self:setContentSize(CCSizeMake(width, height))
    self:setOpacity(255)

    local high = LayerColor:createWithColor(highColor, self.width, self.itemHeight)
    high:ignoreAnchorPointForPosition(false)
    self:addChildAt(high, 0)
    high:setPositionY(self.height/2)
    high:setAnchorPoint(ccp(0, 0.5))
    high:setOpacity(255)

    local function pointInRect( pos, rect )
    	return pos.x >= rect.left and pos.y >= rect.bottom and pos.x <= rect.right and pos.y <= rect.top
    end


    self:setTouchEnabled(true, nil, true, function ( worldPosition )
    	if self.isDisposed then return end
    	if self.subMode then
    		

    		local pos = worldPosition
	    	pos = self:convertToNodeSpace(pos)
	    	if not pointInRect(pos, {left = 0, bottom = 0, right = self.width, top = self.height}) then
	    		return false
	    	else
	    		return true
	    	end


    	else
    		return false
    	end
    end)

    

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
    	pos = self.scroll.container:convertToNodeSpace(pos)
    	local pos2 = self:convertToWorldSpace(ccp(self.width/2, self.height/2))
    	pos2 = self.scroll.container:convertToNodeSpace(pos2)
    	local deltaY = - pos.y + pos2.y 
    	self.scroll:moveY(deltaY)
    end)
end

function ScrollEdit:update( ... )
	if self.isDisposed then return end
	-- body
	self.scroll:emitScroll()
end


function ScrollEdit:getValue( ... )
	if self.isDisposed then return end
	-- body
	local items = self.scrollLayout:getItems()
	local item = items[math.max(1, math.min(#items, self.cur))]
	if item then
		return item:getContent():getValue()
	end
end

function ScrollEdit:setValue(v)
	if self.isDisposed then return end
	-- body
	local items = self.scrollLayout:getItems()
	for index, item in ipairs(items) do
		if item:getContent():getValue() == v then
			self.scroll:gotoPositionY(index * self.itemHeight - self.height/2 - self.itemHeight/2, 0)
			self:update()
			return
		end
	end
end

function ScrollEdit:setItemValue(index, v)
	if self.isDisposed then return end
	local items = self.scrollLayout:getItems()
	if items[index] then
		items[index]:getContent():setValue(v)
	end
end

function ScrollEdit:addItem( itemUI )
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
	self.scroll:updateScrollableHeight()
end

function ScrollEdit:removeItem( itemUI )
	if self.isDisposed then return end
	local items = self.scrollLayout:getItems()

	for index, v in ipairs(items) do
		if v:getContent() == itemUI then
			self.scrollLayout:removeItemAt(index)
			self.scroll:updateScrollableHeight()
			return
		end
	end
	
end

function ScrollEdit:removeItemByIndex( i )
	if self.isDisposed then return end
	local items = self.scrollLayout:getItems()

	if items[i] then
		self:removeItem(items[i]:getContent())
	end
	
end

function ScrollEdit:findItemByValue( value )
	if self.isDisposed then return end
	local items = self.scrollLayout:getItems()
	for index, v in ipairs(items) do
		if value == v:getContent():getValue() then
			return v
		end
	end
end

function ScrollEdit:removeAllItems( ... )
	if self.isDisposed then return end
	self.scrollLayout:removeAllItems()
	self.scroll:updateScrollableHeight()
end

function ScrollEdit:getItemNum( )
	if self.isDisposed then return end
	return #(self.scrollLayout:getItems())
end

function ScrollEdit:notifyItems(  )
	if self.isDisposed then return end
	local items = self.scrollLayout:getItems()
	local cur = math.max(1, math.min(#items, self.cur))
	for index, v in ipairs(items) do
		v:getContent():onFocus(cur == index)
	end
end

function ScrollEdit:create( width, height , itemHeight, highColor, normalColor)
	local i = ScrollEdit.new()
	i:init(width, height, itemHeight, highColor, normalColor)
	return i
end

return ScrollEdit