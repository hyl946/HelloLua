GridLayout = class(Layer)

-- support auto layout
-- put items in rows and columns
-- wrap contents to a new row when the current row is full
function GridLayout:create()
    local instance = GridLayout.new()
    instance:init()
    return instance
end

function GridLayout:ctor()
    self.name = 'GridLayout'
    self.debugTag = 1
end

function GridLayout:init()
    Layer.initLayer(self)
    self.numOfRows = 0
    self.numOfColumns = 0
    self.animationDuration = 0.4
    self.columnMargin = 0
    self.rowMargin = 0
    self.items = {}

end

function GridLayout:setColumn(numOfColumns)
    self.numOfColumns = numOfColumns
end

-- assumes that all items are of the same size
function GridLayout:setItemSize(size)
    self.itemHeight = size.height
    self.itemWidth = size.width
end

function GridLayout:setColumnMargin(margin)
    self.columnMargin = margin
end

function GridLayout:setRowMargin(margin)
    self.rowMargin = margin
end

-- use this to override width when getGroupBounds can not solve the problem
function GridLayout:setWidth(width)
    self.width = width
end

-- use this to override height when getGroupBounds can not solve the problem
function GridLayout:setHeight(height)
    self.height = height
end

function GridLayout:getHeight()
    return self.height or self:getGroupBounds().size.height
end

function GridLayout:getWidth()
    return self.width or self:getGroupBounds().size.width
end

function GridLayout:addItem(item, playAnimation)
    self:addItemAt(item, #self.items + 1, playAnimation)
end

function GridLayout:addItemAt(item, index, playAnimation)
    if index < 1 then return end
    if not item then return end

    local count = #self.items
    table.insert(self.items, index, item)
    for k, v in pairs(self.items) do 
        if v.setArrayIndex and type(v.setArrayIndex) == 'function' then 
            v:setArrayIndex(k)
        end
    end
    self:addChild(item)
    self:layout(playAnimation)
end

function GridLayout:removeItemAt(index)
    if _G.isLocalDevelopMode then printx(0, 'not implemented') end
    debug.debug()
end

function GridLayout:setIsUsingClippingNode(isUsingClipping)
    self.isUsingClippingNode = isUsingClipping
end

function GridLayout:isUsingClippingNode()
    return self.isUsingClippingNode
end

function GridLayout:layout(playAnimation)

    local itemsPerRow = self.numOfColumns
    local rowHeight = self.itemHeight
    local itemWidth = self.itemWidth

    if #self.items == 0 then 
        self:setHeight(0) 
        return 
    end

    -- override the itemWidth so that items fit into the row width
    if self.width then itemWidth = (self.width - self.columnMargin) / itemsPerRow end

    for index, item in pairs(self.items) do
    
        local row = math.ceil(index / itemsPerRow)
        local col = index - itemsPerRow * (row - 1)

        local x =  (col - 1) * (itemWidth + self.columnMargin)
        local y =  (row - 1) * rowHeight + row * self.rowMargin
        -- if _G.isLocalDevelopMode then printx(0, 'GridLayout:layout', x, y) end
        local dest = ccp(x, -y)

        if playAnimation then 
            item:stopAllActions()
            item:runAction(self:getMoveToAnimation(dest))
        else
            item:setPosition(dest)
        end
    end

    local rowCount = math.ceil(#self.items / itemsPerRow )
    local bgHeight = (self.rowMargin + rowHeight) * rowCount -- margin 10 px
    self:setHeight(bgHeight)
end

function GridLayout:getRemovingItemAnim(item)
    item:setCascadeOpacityEnabled(true)
    local pos = item:getPosition()
    local size = item:getGroupBounds().size
    local destX = pos.x + size.width / 2
    local destY = pos.y - size.height / 2
    local moveTo = CCMoveTo:create(self.animationDuration - 0.05, ccp(destX, destY))
    local scaleTo = CCScaleTo:create(self.animationDuration - 0.05, 0)
    local a_actions = CCArray:create()
    a_actions:addObject(moveTo)
    a_actions:addObject(scaleTo)
    local spawn = CCSpawn:create(a_actions)
    local ease = CCEaseSineIn:create(spawn)

    return ease
end

function GridLayout:getInsertingItemAnim(item)
    local fadeIn = CCFadeIn:create(self.animationDuration)
    local scaleTo = CCScaleTo:create(self.animationDuration, 1)
    local a_actions = CCArray:create()
    a_actions:addObject(fadeIn)
    a_actions:addObject(scaleTo)
    local spawn = CCSpawn:create(a_actions)
    local ease = CCEaseSineInOut:create(spawn)

    return ease
end

function GridLayout:getMoveToAnimation(ccp)
    local moveTo = CCMoveTo:create(self.animationDuration, ccp)
    local ease = CCEaseSineOut:create(moveTo)
    return ease
end


-- To work with VerticalScrollable class, this function is important.
-- given a top and bottom value, set only items within this area to visible 
-- and set other items outside the view area to invisible.
-- This improves the performance.
function GridLayout:updateViewArea(visibleTop, visibleBottom)
    -- if _G.isLocalDevelopMode then printx(0, 'visibleTop, visibleBottom', visibleTop, visibleBottom) end
    if not self.items then return end
    if not visibleTop or not visibleBottom then return end
    self.visibleTop = visibleTop
    self.visibleBottom = visibleBottom

    for k, v in pairs(self.items) do
        local y = v:getPositionY()
        local height = v:getHeight()
        if v and not v.isDisposed then
            if -y < visibleTop - height - 20 or -y > visibleBottom + height + 20  then
                v:setVisible(false)
            else
                v:setVisible(true)
            end
        end
    end


end

function GridLayout:getItems()
    return self.items
end