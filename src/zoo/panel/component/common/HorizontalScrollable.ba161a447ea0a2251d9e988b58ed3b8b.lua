-------------------------------------------------------
-- This class intends to decribe a container with scrolling ability.




HorizontalScrollable = class(Layer)

function HorizontalScrollable:create(width, height, useClipping, useBlockingLayers,priority)
    local instance = HorizontalScrollable.new()
    instance:init(width, height, useClipping, useBlockingLayers,priority)
    return instance
end

function HorizontalScrollable:ctor()
    Layer.initLayer(self)
    self.name = 'HorizontalScrollable'
    -- self.debugTag = 1
end

function HorizontalScrollable:init(width, height, useClipping, useBlockingLayers,priority)
    priority = priority or 0

    if useClipping == nil then 
        useClipping = true
    end
    if useBlockingLayers == nil then 
        useBlockingLayers = true
    end


    self:ignoreAnchorPointForPosition(true)
    self:setAnchorPoint(ccp(0, 1))

    self.width = width
    self.height = height
    self.rightMostOffset = 0 -- 左边到头的情况下的offset(整个content在最右边) == 0
    self.leftMostOffset = 0 -- 右边到头的情况下（整个content在最左边） < 0
    self.xOffset = 0

    local rect = {size = {width = self.width, height = self.height}}
-- fix issue: nested or stacked clipping node doesn't work properly
    local clipping = nil
if useClipping then 
    clipping = ClippingNode:create(rect)
else
    clipping = LayerColor:create()
    clipping:setColor(ccc3(22,22,22))
    clipping:setOpacity(0)
    clipping:setContentSize(CCSizeMake(rect.size.width, rect.size.height))
end
-- end of fix
    clipping.name = 'HorizontalScrollable.clipping'
    -- clipping.debugTag = 1

    -- clipping:setAnchorPoint(ccp(0, 1))

    local leftBlocking = nil
    local rightBlocking = nil
if useBlockingLayers then
    leftBlocking = LayerColor:create()
    leftBlocking:setColor(ccc3(255, 0, 0))
    leftBlocking:setOpacity(0)
    leftBlocking.name = 'HorizontalScrollable.leftBlocking'
    -- leftBlocking.debugTag = 1

    rightBlocking = LayerColor:create()
    rightBlocking:setColor(ccc3(0, 20, 0))
    rightBlocking:setOpacity(0)
    rightBlocking.name = 'HorizontalScrollable.rightBlocking'
    -- rightBlocking.debugTag = 1
end

    local touchLayer = LayerColor:create()
    touchLayer:setColor(ccc3(0, 0, 255))
    touchLayer:setOpacity(0)
    touchLayer.name = 'HorizontalScrollable.touchLayer'
    -- touchLayer.debugTag = 1

    -- using a zero-sized node to simulate a cursor,
    -- so that the child will be placed at (0,0)
    -- and later the cordinates (x, y) will always
    -- be greater than zero(this is more practical, isn't it?)
    -- the cursor won't move
    local cursor = Layer:create()
    cursor.name = 'HorizontalScrollable.cursor'
    -- cursor.debugTag = 1

    -- using a zero-sized node to simalute a container with
    -- its anchor point set to (0, 1)
    -- thus later when move the container, the xOffset is equal to 
    -- this container's Y cordinate.
    local container = LayerColor:create()
    container.name = 'HorizontalScrollable.container'
    -- container.debugTag = 1

    container:setPosition(ccp(0, 0))
    container:setOpacity(0)
    cursor:addChild(container)
    cursor:setPosition(ccp(0, self.height))
    self.cursor = cursor

if useBlockingLayers then
    leftBlocking:setContentSize(CCSizeMake(500, self.height))
    leftBlocking:setPosition(ccp(-500,0))
    leftBlocking:setTouchEnabled(true, priority+1, true)
    leftBlocking:ad(DisplayEvents.kTouchTap, function() if _G.isLocalDevelopMode then printx(0, 'leftBlocking') end end)

    rightBlocking:setContentSize(CCSizeMake(500, self.height))
    rightBlocking:setPosition(ccp(0, 0))
    rightBlocking:setTouchEnabled(true, priority+1, true)
    rightBlocking:ad(DisplayEvents.kTouchTap, function() if _G.isLocalDevelopMode then printx(0, 'rightBlocking') end end)
end

    touchLayer:setContentSize(CCSizeMake(self.width, self.height))
    touchLayer:setTouchEnabled(true, priority, false)
    touchLayer:setPosition(ccp(0, -self.height))
    touchLayer:ad(DisplayEvents.kTouchBegin, function(event) self:onTouchBegin(event) end)
    touchLayer:ad(DisplayEvents.kTouchMove, function(event) self:onTouchMove(event) end)
    touchLayer:ad(DisplayEvents.kTouchEnd, function(event) self:onTouchEnd(event) end)

if useBlockingLayers then 
    clipping:addChild(leftBlocking)
    clipping:addChild(rightBlocking)
end

    clipping:addChild(cursor)
    clipping:setPosition(ccp(0, -self.height))

    self.leftBlocking = leftBlocking
    self.rightBlocking = rightBlocking
    self.touchLayer = touchLayer
    self.clipping = clipping

    -- leftBlocking.debugTag = 1
    -- rightBlocking.debugTag = 1
    -- touchLayer.debugTag = 1
    -- clipping.debugTag = 1
    -- cursor.debugTag = 1
    -- container.debugTag = 1

    self:addChild(clipping)
    self:addChild(touchLayer)

    self.clipping = clipping
    self.touchLayer = touchLayer
    self.container = container

    self.last_x = 0
    self.last_y = 0
    ------------------- SPEEDOMETER -----------------
    local function __getPosition()
        return ccp(self.last_x, self.last_y)
    end

    -- self.speedwatch = TouchMoveVelocity:create()

    self.speedometers = {}
    self.speedometers[1] = VelocityMeasurer:create(6/60, __getPosition) -- take meature every x frames
    -- self.speedometers[2] = VelocityMeasurer:create(6/60, __getPosition)
end

function HorizontalScrollable:setScrollEnabled(enabled)
    self.touchLayer:setTouchEnabled(enabled, 0, false)
end

function HorizontalScrollable:setScrollableWidth(width)
    if width - self.width > 0 then
        self.leftMostOffset = self.width - width
    else 
        self.leftMostOffset = self.rightMostOffset
    end
end

-- set to false will do:
-- if the finger start with vertical movements,
-- we'll recongnize it as a vertical gesture, and thus
-- even if there is horizontal move, we ignore any further movements
function HorizontalScrollable:setIgnoreHorizontalMove(ignore)
    self.ignoreHorizontalMove = ignore
end

-- defaultly, we ignore vertical movements
-- means: what ever the gesture is, we capture its X diffs
function HorizontalScrollable:isIgnoreHorizontalMove()
    if self.ignoreHorizontalMove ~= nil then
        return self.ignoreHorizontalMove
    else 
        return true
    end
end

function HorizontalScrollable:checkMoveStarted(x, y)
    local distance = ccpDistance(ccp(self.moveStartX, self.moveStartY), ccp(x, y))
    local threshold = 15
    -- if already started, we dont check any more
    if self.scrollDirection ~= ScrollDirection.kNone then return true end
    -- while distance is too short, return false
    if distance < threshold then return false end

    local dx = math.abs(self.moveStartX - x)
    local dy = math.abs(self.moveStartY - y)
    if dy > dx then 
        self.scrollDirection = ScrollDirection.kVertical
        return true
    else
        self.scrollDirection = ScrollDirection.kHorizontal
        return true
    end
end

function HorizontalScrollable:getScrollDirection()
    return self.scrollDirection or ScrollDirection.kNone
end

function HorizontalScrollable:onTouchBegin(event)
    -- print 'on touch begin'
    -- printx(61, 'HorizontalScrollable', 'onTouchBegin')

    self.scrollDirection = ScrollDirection.kNone
    self:stopSlide()
    self:onEndMoving()

    self.last_y = event.globalPosition.y
    self.last_x = event.globalPosition.x

    -- self.speedwatch:onTouchBegin(0, self.last_y)

    self.moveStartX = event.globalPosition.x
    self.moveStartY = event.globalPosition.y
    for k, v in pairs(self.speedometers) do
        v:setInitialPos(self.last_x, self.last_y) 
        v:startMeasure()
    end
end

function HorizontalScrollable:onTouchMove(event)

    -- printx(61, 'HorizontalScrollable', 'onTouchMove')


    local y = event.globalPosition.y
    local x = event.globalPosition.x

    if not self:isIgnoreHorizontalMove() then
        -- if move not started, or if horizontal move, then return
        if not self:checkMoveStarted(x, y) 
            or self:getScrollDirection() ~= ScrollDirection.kHorizontal 
        then 
            return 
        end
    end
    
    -- self.speedwatch:onTouchMove(0, self.last_y)
    self.speedometers[1]:setXY(x, 0)
    if self.last_x == 0 then self.last_x = x end
    local dx = x - self.last_x
    local tarOffset = self.xOffset + dx

    if tarOffset <= self.rightMostOffset and tarOffset >= self.leftMostOffset then
        self:__moveTo(tarOffset)
    elseif tarOffset < self.leftMostOffset or tarOffset > self.rightMostOffset then
        self:__moveTo(tarOffset - dx / 2)
    end
    self.last_x = x
    self:updateContentViewArea()
end

function HorizontalScrollable:onTouchEnd(event)

    -- printx(61, 'HorizontalScrollable', 'onTouchEnd')

    -- print 'on touch end'
    -- top out of border
    self.last_y = event.globalPosition.y
    self.last_x = event.globalPosition.x

    if not self:isIgnoreHorizontalMove() then
        -- if move not started, or if horizontal move, then return
        if not self:checkMoveStarted(self.last_x, self.last_y) 
            or self:getScrollDirection() ~= ScrollDirection.kHorizontal 
        then 
            return 
        end
    end

    -- self.speedwatch:onTouchEnd(0, self.last_y)
    for i, v in ipairs(self.speedometers) do
        v:stopMeasure()
    end

    self.xOffset = self.container:getPositionX()


    local speed = self:getSwipeSpeed()
    
    if self.xOffset < self.leftMostOffset then
        self:__moveTo(self.leftMostOffset, 0.3)
    --bottom out of border
    elseif self.xOffset > self.rightMostOffset then 
        self:__moveTo(self.rightMostOffset, 0.3)
    elseif speed ~= 0 then
        self:slide(speed)
    end
end

function HorizontalScrollable:getSwipeSpeed()
    -- local speedx, speedy = self.speedwatch:getVelocityXY()
    local speedx = self.speedometers[1]:getMeasuredVelocityX()
    -- print ('speedx ', speedx)

    if speedx > 30 or speedx < -30
    then
        return speedx
    else 
        return 0
    end
end

function HorizontalScrollable:stopSlide()
    -- printx(61, 'HorizontalScrollable', 'stopSlide')
    self.container:stopAllActions()
    self.xOffset = self.container:getPositionX()
    if self.schedId ~= nil then
        Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedId)
        self.schedId = nil
    end
end

function HorizontalScrollable:slide(speed)

    -- printx(61, 'HorizontalScrollable', 'slide')


    local scheduler = Director:sharedDirector():getScheduler()
    local resistance = 500
    local duration = math.abs(speed / resistance)
    local distance = speed / resistance * 1500

    local function __unschdule()
        print ('__unschdule')
        if self.schedId ~= nil then
            scheduler:unscheduleScriptEntry(self.schedId)
            self.schedId = nil
        end
    end

    local action = CCSequence:createWithTwoActions(
                    CCEaseExponentialOut:create(
                     CCMoveBy:create(duration, ccp(distance, 0))
                     ),
                    CCCallFunc:create(__unschdule)
                    )

    self.container:runAction(action)

    local function __check()
        if _G.isLocalDevelopMode then printx(0, '__check') end
        if not self.isDisposed then 
            self.xOffset = self.container:getPositionX()
            if self.xOffset < self.leftMostOffset then

                self.container:stopAllActions()
                self:__moveTo(self.leftMostOffset, 0.3)
                __unschdule()
            elseif self.xOffset > self.rightMostOffset then

                self.container:stopAllActions()
                self:__moveTo(self.rightMostOffset, 0.3)
                __unschdule()
            end
            self:updateContentViewArea()
        else 
            __unschdule()
        end
    end
    __unschdule()
    if self.schedId == nil then 
        self.schedId = scheduler:scheduleScriptFunc(__check, 1/60, false)
    end
end

function HorizontalScrollable:setScrollStopCallback(func)
    self.scrollStopCallback = func
end

function HorizontalScrollable:__moveTo( X_Position, duration )

    -- printx(61, 'HorizontalScrollable', '__moveTo')


    if not duration then
        duration = 0
    end

    local dY = X_Position - self.xOffset

    if duration == 0 then 
        self.container:setPositionX(X_Position)
        if self.scrollStopCallback then
            self.scrollStopCallback()
        end
    else
        self:onStartMoving()
        local moveAction = CCSequence:createWithTwoActions(
                            CCEaseSineOut:create(CCMoveTo:create(duration, ccp(X_Position, 0))),
                            CCCallFunc:create(function() 
                                    if self.scrollStopCallback then
                                        self.scrollStopCallback()
                                    end
                                    self:onEndMoving() 
                                end)
                            )
        local TAG = 601
        moveAction:setTag(TAG)
        self.container:stopActionByTag(TAG)
        self.container:runAction(moveAction)
    end

    self.xOffset = X_Position
end

function HorizontalScrollable:getContent()
    return self.content
end

function HorizontalScrollable:setContent(uiComponent)
    if not uiComponent then return end
    self:removeContent()
    self.content = uiComponent
    self.container:addChild(uiComponent)
    local width
    if type(uiComponent.getWidth) == "function" then
        width = uiComponent:getWidth()
    else
        width = uiComponent:getGroupBounds().size.width
    end
    -- if _G.isLocalDevelopMode then printx(0, 'content hei/\ght', width) end
    self:setScrollableWidth(width)
    self:updateContentViewArea()
end

function HorizontalScrollable:updateScrollableHeight()
    self:setScrollableWidth(self.content:getWidth())
end

function HorizontalScrollable:removeContent()
    if self.content and self.content:getParent() then 
        self.content:removeFromParentAndCleanup(true)
        self.content = nil
    end
    self:setScrollableWidth(0)
end

-- implementation obliged: items use this function to 
-- test click Hit Point
function HorizontalScrollable:getViewRectInWorldSpace()
    -- DO NOT use getGroupBounds() on clipping nodes, it does not work on clipping nodes
    -- use touchLayer instead to present the view area
    local size = self.touchLayer:getGroupBounds().size
    local origin = self.touchLayer:getPosition()
    local pos = self.touchLayer:getParent():convertToWorldSpace(ccp(origin.x, origin.y))
    self.clippingRect = CCRectMake(pos.x, pos.y, size.width, size.height)
    return self.clippingRect
end

-- To improve performance, the self.content property must implement
-- "updateViewArea" function, letting only items between the top and bottom 
-- be visible.
function HorizontalScrollable:updateContentViewArea()
    if self.content and self.content.updateViewArea then
        local leftPosX = self.xOffset
        local rightPosX = leftPosX + self.width
        self.content:updateViewArea(leftPosX, rightPosX)
    end
end

function HorizontalScrollable:onStartMoving()
    -- if _G.isLocalDevelopMode then printx(0, 'HorizontalScrollable:onStartMoving') end
    local function __update()
        -- if _G.isLocalDevelopMode then printx(0, '__update') end
        self:updateContentViewArea()
    end
    if not self.updateSchedId then
        self.updateSchedId = Director:sharedDirector():getScheduler():scheduleScriptFunc(__update, 1/60, false)
    end
end

function HorizontalScrollable:onEndMoving()
    -- if _G.isLocalDevelopMode then printx(0, 'HorizontalScrollable:onEndMoving') end
    if self.updateSchedId then 
        Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.updateSchedId)
        self.updateSchedId = nil
    end

end

function HorizontalScrollable:dispose()
    -- if _G.isLocalDevelopMode then printx(0, 'HorizontalScrollable:dispose()') end
    if self.schedId ~= nil then
        -- if _G.isLocalDevelopMode then printx(0, 'unschedule1') end
        Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedId)
        self.schedId = nil
    end
    if self.updateSchedId ~= nil then 
        -- if _G.isLocalDevelopMode then printx(0, 'unschedule2') end
        Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.updateSchedId)
        self.updateSchedId = nil
    end
    Layer.dispose(self)
end

function HorizontalScrollable:scrollToLeftEnd(duration)
    self:stopSlide()
    duration = duration or 0.3
    self:__moveTo(self.rightMostOffset, duration)
end

function HorizontalScrollable:scrollToRightEnd(duration)
    self:stopSlide()
    duration = duration or 0.3
    self:__moveTo(self.leftMostOffset, duration)
end

function HorizontalScrollable:scrollToRightOffset(duration, offset)
    self:stopSlide()
    duration = duration or 0.3
    self:__moveTo(self.leftMostOffset - offset, duration)
end

function HorizontalScrollable:isAtLeftEnd()
    return self.xOffset <= self.leftMostOffset
end

function HorizontalScrollable:isAtRightEnd()
    return self.xOffset >= self.rightMostOffset
end

--指定offset，使它在中间
function HorizontalScrollable:scrollOffsetToCenter(offset)

    -- printx(61, 'HorizontalScrollable', 'scrollOffsetToCenter')


    if offset < 0 then offset = 0 end
    local contentWidth
    if type(self.content.getWidth) == "function" then
        contentWidth = self.content:getWidth()
    else
        contentWidth = self.content:getGroupBounds().size.width
    end
    self:stopSlide()
    if offset <= self.width / 2 then
        -- if not self:isAtLeftEnd() then
            self:scrollToLeftEnd()
        -- end
    elseif contentWidth - offset <= self.width / 2 then
        -- if not self:isAtRightEnd() then
            self:scrollToRightEnd()
        -- end
    else 
        self:__moveTo(self.width / 2 - offset, 0.3)
    end
end

-- 指定offset，使它在最左边
function HorizontalScrollable:scrollToOffset(offset)
    if offset < 0 then offset = 0 end
    local contentWidth
    if type(self.content.getWidth) == "function" then
        contentWidth = self.content:getWidth()
    else
        contentWidth = self.content:getGroupBounds().size.width
    end
    self:stopSlide()
    if offset > contentWidth - self.width then
        self:scrollToRightEnd()
    else
        self:__moveTo(0 - offset, 0.3)
    end
end