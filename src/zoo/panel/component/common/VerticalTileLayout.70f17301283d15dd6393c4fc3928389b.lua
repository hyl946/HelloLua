---------------------------------------------------------
-- This class intends to describe a container which is able to 
-- automatically layout items vertically. Also this class is supposed
-- to be used with VerticalScrollable class which works as a clipping to show 
-- only limited view area and as a scrollable container, and VerticalTileItem which is 
-- the base class for items to add into VerticalTileLayout. Some functions of 
-- VerticalTileItem are essential for this class to process layout.
-- 

VerticalAlignment = {kTop = 1, kCenter = 2, kBottom = 3}

VerticalTileLayout = class(Layer)

function VerticalTileLayout:create(width)
	local instance = VerticalTileLayout.new()
	instance:init(width)
	return instance
end

function VerticalTileLayout:setCareItemVisible( bCare )
	-- body
	self.careItemVisible = bCare
end

function VerticalTileLayout:ctor()
	Layer.initLayer(self)
	self.name = 'VerticalTileLayout'
	-- self.debugTag = 1
end

function VerticalTileLayout:init(width)
	assert(width)

	self:ignoreAnchorPointForPosition(true)
	self:setAnchorPoint(ccp(0, 1))

	self.width = width

	self.itemVerticalMargin = 5
	self.itemHorizontalMargin = 0

	self.animationDuration = 0.4

	self.items = {}

	local container = Layer:create()
	container.name = 'VerticalTileLayout.container'
	container.debugTag = 1

	self.container = container

	self:addChild(self.container)


end

function VerticalTileLayout:setAnimationDuration(duration)
	self.animationDuration = duration
end

function VerticalTileLayout:setItemVerticalMargin(margin)
	self.itemVerticalMargin = margin
end

function VerticalTileLayout:setItemHorizontalMargin(margin)
	self.itemHorizontalMargin = margin
end

-- to avoid multiple layout calls 
function VerticalTileLayout:addItemBatch(itemList)
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

	self:updateViewArea(self.visibleTop, self.visibleBottom)

end

function VerticalTileLayout:addItem(item, playAnimation)
	self:addItemAt(item, #self.items + 1, playAnimation)
end


function VerticalTileLayout:addItemAt(item, arrayIndex, playAnimation)
	if not item then return end
	if arrayIndex > #self.items + 1 then return end

	table.insert(self.items, arrayIndex, item)

	for k, v in pairs(self.items) do
		-- assert(type(v.setArrayIndex) == 'function', 'VerticalTileLayout:addItemAt(): item must inherits ItemInLayout')
		v:setArrayIndex(k)
	end

	self.container:addChild(item)

	self:__layout(playAnimation)
	self:updateViewArea(self.visibleTop, self.visibleBottom)
end

function VerticalTileLayout:removeAllItems()
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



function VerticalTileLayout:removeItem(playAnimation)
	self:removeItemAt(#self.items, playAnimation)
end

function VerticalTileLayout:removeItemAt(arrayIndex, playAnimation)
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

	if playAnimation then 
		local shrink = self:getRemovingItemAnimation(item)
		local cb = CCCallFunc:create(__removeItemUI)
		local se = CCSequence:createWithTwoActions(shrink, cb)
		item:runAction(se)
	else
		__removeItemUI()
	end

	self:__layout(playAnimation)

	self:updateViewArea(self.visibleTop, self.visibleBottom + height)
end

function VerticalTileLayout:getItems()
	return self.items
end

-- during the animation, the height is not accurate
-- this function returns the static height
function VerticalTileLayout:getHeight()
	if #self.items == 0 then return 0 end

	local x = self.itemHorizontalMargin
	local y = self.itemVerticalMargin

	for i, v in pairs(self.items) do 
		local itemHeight = v:getHeight() or v:getGroupBounds().size.height

		if self.careItemVisible and (not v:getContent():isVisible()) then
			itemHeight = 0
		end

		y = y + itemHeight + self.itemVerticalMargin
	end
	return y

end


function VerticalTileLayout:__layout(playAnimation)
	if #self.items == 0 then return end

	local x = self.itemHorizontalMargin
	-- local y = self.itemVerticalMargin
	local y = 0

	for i, v in pairs(self.items) do
		v:setAnchorPoint(ccp(0, 0))
		local point = ccp(x, -y)
		if playAnimation then 
			v:stopAllActions()
			v:runAction(self:getMoveToAnimation(point))
		else
			v:setPosition(point)
		end

		local itemHeight = v:getHeight() or v:getGroupBounds().size.height

		if self.careItemVisible and (not v:getContent():isVisible()) then
			itemHeight = 0
		end


		y = y + itemHeight + self.itemVerticalMargin
	end
end

function VerticalTileLayout:getMoveToAnimation(ccp)
	local moveTo = CCMoveTo:create(self.animationDuration, ccp)
	local ease = CCEaseSineOut:create(moveTo)
	return ease
end

function VerticalTileLayout:getRemovingItemAnimation(item)
	item:setCascadeOpacityEnabled(true)
	local pos = item:getPosition()
	local size = item:getGroupBounds().size
	local destX = pos.x + size.width / 2
	local destY = pos.y
	local moveTo = CCMoveTo:create(self.animationDuration - 0.05, ccp(destX, destY))
	local scaleTo = CCScaleTo:create(self.animationDuration - 0.05, 0)
	local a_actions = CCArray:create()
	a_actions:addObject(moveTo)
	a_actions:addObject(scaleTo)
	local spawn = CCSpawn:create(a_actions)
	local ease = CCEaseSineIn:create(spawn)

	return ease
end

function VerticalTileLayout:getInsertingItemAnimation(item)
	local fadeIn = CCFadeIn:create(self.animationDuration)
	local scaleTo = CCScaleTo:create(self.animationDuration, 1)
	local a_actions = CCArray:create()
	a_actions:addObject(fadeIn)
	a_actions:addObject(scaleTo)
	local spawn = CCSpawn:create(a_actions)
	local ease = CCEaseSineInOut:create(spawn)

	return ease
end	


function VerticalTileLayout:dispose()
	self.items = {}
	self.width = nil
	self.itemVerticalMargin = nil
	self.itemHorizontalMargin = nil
	self.animationDuration = nil
	self.container = nil
	CocosObject.dispose(self)

end

-- To work with VerticalScrollable class, this function is important.
-- given a top and bottom value, set only items within this area to visible 
-- and set other items outside the view area to invisible.
-- This improves the performance.
function VerticalTileLayout:updateViewArea(visibleTop, visibleBottom)
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


VerticalTileLayoutWithAlignment = class(VerticalTileLayout)

-- override
function VerticalTileLayoutWithAlignment:create(width, height)
    local instance = VerticalTileLayoutWithAlignment.new()
    instance:init(width, height)
    return instance
end

-- override
function VerticalTileLayoutWithAlignment:init(width, height)
    VerticalTileLayout.init(self, width)
    self.height = height
end

function VerticalTileLayoutWithAlignment:setAlignment(alignment)
    self.alignment = alignment
    self:__layout()
end

-- override
function VerticalTileLayoutWithAlignment:__layout(playAnimation)
    if #self.items == 0 then return end

    local contentHeight = 0
    for k, v in pairs(self.items) do
        local itemHeight = v:getHeight() or v:getGroupBounds().size.height

        if self.careItemVisible and (not v:getContent():isVisible()) then
			itemHeight = 0
		end

        contentHeight = contentHeight + itemHeight + self.itemVerticalMargin
    end

    -- assert(contentHeight < self.height, 'VerticalTileLayoutWithAlignment:__layout(playAnimation): your content height is too high.')

    local offsetY = 0 
    if self.alignment == VerticalAlignments.kTop then
        offsetY = 0
    elseif self.alignment == VerticalAlignments.kBottom then
        offsetY = self.height - contentHeight
    else
        offsetY = (self.height - contentHeight) / 2
    end

    local x = self.itemHorizontalMargin
    local y = self.itemVerticalMargin + offsetY

    for i, v in pairs(self.items) do 
        v:setAnchorPoint(ccp(0, 0))
        local point = ccp(x, -y)
        if playAnimation then 
            v:stopAllActions()
            v:runAction(self:getMoveToAnimation(point))
        else
            v:setPosition(point)
        end

        local itemHeight = v:getHeight() or v:getGroupBounds().size.height

        if self.careItemVisible and (not v:getContent():isVisible()) then
			itemHeight = 0
		end

        y = y + itemHeight + self.itemVerticalMargin
    end
end