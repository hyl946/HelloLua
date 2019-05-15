ItemInLayout = class(Sprite)

function ItemInLayout:create()
    local instance = ItemInLayout.new()
    instance:init()
    return instance
end

function ItemInLayout:ctor()
    self.name = 'ItemInLayout'
    self.debugTag = 1
end

function ItemInLayout:init()
    -- Layer.initLayer(self)
    self:setRefCocosObj(CCSprite:create())
    self.content = nil
    self.arrayIndex = 1
end

function ItemInLayout:setArrayIndex(arrayIndex)
    assert(arrayIndex > 0, "invalid arrayIndex: "..tostring(arrayIndex))
    self.arrayIndex = arrayIndex
end

function ItemInLayout:getArrayIndex()
    return self.arrayIndex
end

function ItemInLayout:setContent(uiContent)
    if uiContent then
        if self.content then self:removeContent() end
        self.content = uiContent
        self:addChild(uiContent)
        self:setHeight(uiContent:getGroupBounds().size.height)
    end
end

function ItemInLayout:updateContentHeight( ... )
    if self.isDisposed then return end
    if self.content then
        self:setHeight(self.content:getGroupBounds().size.height)
    end
end

function ItemInLayout:getContent()
    return self.content
end

function ItemInLayout:removeContent()
    if self.content and self.content:getParent() then
        self.content:removeFromParentAndCleanup(true)
        self.content = nil
    end
end

function ItemInLayout:setWidth(width)
    self.width = width
end

function ItemInLayout:getWidth()
    return self.width or self:getGroupBounds().size.width
end

function ItemInLayout:setHeight(height)
    self.height = height
end

function ItemInLayout:getHeight()
    return self.height or self:getGroupBounds().size.height
end

function ItemInLayout:dispose()
    self.arrayIndex = nil
    self.content = nil
    CocosObject.dispose(self)
end


ItemInClippingNode = class(ItemInLayout)

function ItemInClippingNode:create()
    local instance = ItemInClippingNode.new()
    instance:init()
    return instance
end

function ItemInClippingNode:init()
    -- init super class
    ItemInLayout.init(self)
    self.name = 'ItemInClippingNode'
    self.debugTag = 1
end

function ItemInClippingNode:setViewRect(rectInWorld)
    self.viewRect = rectInWorld
end

function ItemInClippingNode:setParentView(view)
    self.parentView = view
end

-- click events from outside the clipping node view area
-- will not trigger the script handler
function ItemInClippingNode:hitTestPoint(worldPosition, useGroupTest)
    if _G.isLocalDevelopMode then printx(0, 'ItemInClippingNode:hitTestPoint') end
    if self.viewRect then
        if worldPosition.x < self.viewRect.origin.x 
          or worldPosition.x > self.viewRect.origin.x + self.viewRect.size.width
          or worldPosition.y < self.viewRect.origin.y 
          or worldPosition.y > self.viewRect.origin.y + self.viewRect.size.height
        then 
            return false
        end
    end

    return CocosObject.hitTestPoint(self, worldPosition, useGroupTest)
end


-- override every touchable ui element's hitTestPoint function
function ItemInClippingNode:setContent(uiContent)

    local nodeSelfRef = self
    local function setHitTestPoint(ui)
        -- if _G.isLocalDevelopMode then printx(0, 'function setHitTestPoint') end
        -- if ui.isTouchEnabled and ui:isTouchEnabled() then
        if ui.isTouchEnabled then
            -- override hitTestPoint
            ui.hitTestPoint = function (uiSelfRef, worldPosition, useGroupTest)
                -- first test if the click is outside the clipping node viewRect
                -- if _G.isLocalDevelopMode then printx(0, 'ui.hitTestPoint') end
                if nodeSelfRef.parentView  and nodeSelfRef.parentView.getViewRectInWorldSpace then

                    local rect = nodeSelfRef.parentView:getViewRectInWorldSpace()
                    -- if _G.isLocalDevelopMode then printx(0, worldPosition.x, worldPosition.y) end
                    -- if _G.isLocalDevelopMode then printx(0, rect.origin.x, rect.origin.x + rect.size.width, rect.origin.y, rect.origin.y + rect.size.height) end
                    if worldPosition.x < rect.origin.x 
                      or worldPosition.x > rect.origin.x + rect.size.width
                      or worldPosition.y < rect.origin.y 
                      or worldPosition.y > rect.origin.y + rect.size.height
                    then 
                        -- if _G.isLocalDevelopMode then printx(0, 'out side') end
                        return false
                    end
                end
                -- call super
                return CocosObject.hitTestPoint(uiSelfRef, worldPosition, useGroupTest)
            end
        end

        if ui.list and type(ui.list) == 'table' then
            -- if _G.isLocalDevelopMode then printx(0, 'loop') end
            for k, v in pairs(ui.list) do
                setHitTestPoint(v)
            end
        end
    end
    -- if _G.isLocalDevelopMode then printx(0, 'enter') end
    setHitTestPoint(uiContent)
    -- call super
    ItemInLayout.setContent(self, uiContent)
end

-- check if this item is visible on the screen
function ItemInClippingNode:isInViewArea()
    local parent = self:getParent()
    if not parent then return false end
    local rect = self:getGroupBounds()
    local worldPos = parent:convertToWorldSpace(ccp(rect.origin.x, rect.origin.y))

    local rectInWorld = CCRectMake(worldPos.x, worldPos.y, rect.size.width, rect.size.height)
    return rectInWorld:intersectsRect(self.viewRect)

end

-- override this
function ItemInClippingNode:onEnterViewArea()

end

-- override this
function ItemInClippingNode:onExitViewArea()

end
