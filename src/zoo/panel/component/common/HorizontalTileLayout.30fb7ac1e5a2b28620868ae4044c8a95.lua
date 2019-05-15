HorizontalAlignments = {kLeft = 1, kCenter = 2, kRight = 3, kJustified = 4}

LayoutEvents = {
    kLayoutComplete = "LayoutComplete",
}

HorizontalTileLayout = class(Layer)

function HorizontalTileLayout:create(height)
    local instance = HorizontalTileLayout.new()
    instance:init(height)
    return instance
end

function HorizontalTileLayout:ctor()
    Layer.initLayer(self)
    self.name = 'HorizontalTileLayout'
    -- self.debugTag = 1
end

function HorizontalTileLayout:init(height)
    -- assert(height, 'HorizontalTileLayout:init(): height is not set.')

    self:ignoreAnchorPointForPosition(true)
    self:setAnchorPoint(ccp(0, 1))

    self.height = height

    self.itemVerticalMargin = 0
    self.itemHorizontalMargin = 0

    self.animationDuration = 0.4

    self.items = {}

    local container = Layer:create()
    container.name = 'HorizontalTileLayout.container'
    container.debugTag = 1

    self.container = container

    self:addChild(self.container)


end

function HorizontalTileLayout:setAnimationDuration(duration)
    self.animationDuration = duration
end

function HorizontalTileLayout:setItemVerticalMargin(margin)
    self.itemVerticalMargin = margin
end

function HorizontalTileLayout:setItemHorizontalMargin(margin)
    self.itemHorizontalMargin = margin
end

-- to avoid multiple layout calls 
function HorizontalTileLayout:addItemBatch(itemList)
    if not itemList or type(itemList) ~= 'table' then
        itemList = {}
    end

    local arrayIndex = #self.items + 1
    if _G.isLocalDevelopMode then printx(0, 'arrayIndex', arrayIndex) end
    for key, item in pairs(itemList) do

        table.insert(self.items, item)
        item:setArrayIndex(arrayIndex)
        self.container:addChild(item)
        arrayIndex = arrayIndex + 1
    end

    self:__layout()

    self:updateViewArea(self.visibleTop, self.visibleBottom)

end

function HorizontalTileLayout:addItem(item, playAnimation)
    self:addItemAt(item, #self.items + 1, playAnimation)
end


function HorizontalTileLayout:addItemAt(item, arrayIndex, playAnimation)
    if not item then return end
    if arrayIndex > #self.items + 1 then return end

    table.insert(self.items, arrayIndex, item)

    for k, v in pairs(self.items) do 
        -- assert(type(v.setArrayIndex) == 'function', 'HorizontalTileLayout:addItemAt(): item must inherits ItemInLayout')
        v:setArrayIndex(k)
    end

    self.container:addChild(item)

    self:__layout(playAnimation)
    self:updateViewArea(self.visibleTop, self.visibleBottom)
end

function HorizontalTileLayout:removeAllItems()
    if self.items then 
        for k, v in pairs(self.items) do
            if v:getParent() then 
                v:removeFromParentAndCleanup(true)
                v = nil
            end
        end
    end
    self.items = {}
    self:updateViewArea(self.visibleTop, self.visibleBottom)
end

function HorizontalTileLayout:getItemIndex(item)
    for i,v in ipairs(self.items) do
        if v == item then
            return i
        end
    end

    return -1
end

function HorizontalTileLayout:removeItem(playAnimation)
    self:removeItemAt(#self.items, playAnimation)
end

function HorizontalTileLayout:removeItemAt(arrayIndex, playAnimation, noCleanup)
    if arrayIndex > #self.items or arrayIndex < 1 then return end
    local item = self.items[arrayIndex]
    local height = item:getHeight()

    table.remove(self.items, arrayIndex)

    for k, v in pairs(self.items) do 
        v:setArrayIndex(k)
    end
    local function __removeItemUI()
        if item and not item.isDisposed and item:getParent() then 
            item:removeFromParentAndCleanup(not noCleanup) 
            item = nil
        end
    end

    if playAnimation then 
        local shrink = self:getRemovingItemAnimation(item)
        local cb = CCCallFunc:create(__removeItemUI)
        local se = CCSequence:createWithTwoActions(shrink, cb)
        item:runAction(se)
    else
        __removeItemUI()
    end

    self:__layout(playAnimation)

    --self:updateViewArea(self.visibleTop, self.visibleBottom + height)
end

function HorizontalTileLayout:getItems()
    return self.items
end

-- during the animation, the height is not accurate
-- this function returns the static height
function HorizontalTileLayout:getHeight()
    if #self.items == 0 then return 0 end

    local x = self.itemHorizontalMargin
    local y = self.itemVerticalMargin

    for i, v in pairs(self.items) do 
        local itemHeight = v:getHeight() or v:getGroupBounds().size.height
        y = y + itemHeight + self.itemVerticalMargin
    end
    return y

end


function HorizontalTileLayout:getWidth()
    if #self.items == 0 then return 0 end

    local x = self.itemHorizontalMargin
    local y = self.itemVerticalMargin

    for i, v in pairs(self.items) do 
        local itemHeight = v:getWidth() or v:getGroupBounds().size.height
        y = y + itemHeight + self.itemHorizontalMargin
    end
    return y
end


function HorizontalTileLayout:__layout(playAnimation)


    if #self.items == 0 then return end

    local x = self.itemHorizontalMargin
    local y = self.itemVerticalMargin

    for i, v in pairs(self.items) do 
        v:setAnchorPoint(ccp(0, 0))
        local point = ccp(x, -y)
        if playAnimation then 
            v:stopAllActions()
            v:runAction(self:getMoveToAnimation(point))
        else
            v:setPosition(point)
        end
        local itemWidth = v:getWidth() or v:getGroupBounds().size.width
        x = x + itemWidth + self.itemHorizontalMargin
    end
end

function HorizontalTileLayout:getMoveToAnimation(ccp)
    local moveTo = CCMoveTo:create(self.animationDuration, ccp)
    local ease = CCEaseSineOut:create(moveTo)
    return ease
end

function HorizontalTileLayout:getRemovingItemAnimation(item)
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

function HorizontalTileLayout:getInsertingItemAnimation(item)
    local fadeIn = CCFadeIn:create(self.animationDuration)
    local scaleTo = CCScaleTo:create(self.animationDuration, 1)
    local a_actions = CCArray:create()
    a_actions:addObject(fadeIn)
    a_actions:addObject(scaleTo)
    local spawn = CCSpawn:create(a_actions)
    local ease = CCEaseSineInOut:create(spawn)

    return ease
end 


function HorizontalTileLayout:dispose()
    self.items = {}
    self.width = nil
    self.itemVerticalMargin = nil
    self.itemHorizontalMargin = nil
    self.animationDuration = nil
    self.container = nil
    CocosObject.dispose(self)

end


function HorizontalTileLayout:updateViewArea(visibleTop, visibleBottom)
    -- if _G.isLocalDevelopMode then printx(0, 'visibleTop, visibleBottom', visibleTop, visibleBottom) end
    if true then return end ------ for testing purpose

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


HorizontalTileLayoutWithAlignment = class(HorizontalTileLayout)

-- override
function HorizontalTileLayoutWithAlignment:create(width, height)
    local instance = HorizontalTileLayoutWithAlignment.new()
    instance:init(width, height)
    return instance
end

-- override
function HorizontalTileLayoutWithAlignment:init(width, height)
    HorizontalTileLayout.init(self, height)
    self.width = width
end

function HorizontalTileLayoutWithAlignment:setAlignment(alignment)
    self.alignment = alignment
    self:__layout()
end

-- override
function HorizontalTileLayoutWithAlignment:__layout(playAnimation)
    if #self.items == 0 then return end

    local contentWidth = 0
    if self.alignment == HorizontalAlignments.kJustified then
        contentWidth = self.width
    else
        for k, v in pairs(self.items) do
            local itemWidth = v:getWidth() or v:getGroupBounds().size.width
            contentWidth = contentWidth + itemWidth + self.itemHorizontalMargin
        end
    end

    -- assert(contentWidth <= self.width, 'HorizontalTileLayoutWithAlignment:__layout(playAnimation): your content width is too wide. contentWidth: '..tostring(contentWidth)..",self.width: "..tostring(self.width))

    local offsetX = 0 
    if self.alignment == HorizontalAlignments.kLeft then
        offsetX = 0
    elseif self.alignment == HorizontalAlignments.kRight then
        offsetX = self.width - contentWidth
    else
        offsetX = (self.width - contentWidth) / 2
    end

    local x = self.itemHorizontalMargin + offsetX
    local y = self.itemVerticalMargin

    for i, v in pairs(self.items) do 
        v:setAnchorPoint(ccp(0, 0))
        local point = ccp(x, -y)
        if playAnimation then 
            v:stopAllActions()
            v:runAction(self:getMoveToAnimation(point))
        else
            v:setPosition(point)
        end

        local itemWidth = v:getWidth() or v:getGroupBounds().size.width
        if self.alignment == HorizontalAlignments.kJustified then
            itemWidth = self.width / #self.items
        end
        x = x + itemWidth + self.itemHorizontalMargin
    end
end
