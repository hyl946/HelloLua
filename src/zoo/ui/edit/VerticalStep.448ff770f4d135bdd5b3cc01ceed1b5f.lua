require 'zoo.scenes.component.HomeScene.WorldSceneScroller'

local ScrollableEvents = {
	kEndMoving = "endMoving",
	kStartMoving = "startMoving" 
}


local function sign( x )
	if x >= 0 then return 1 else return -1 end
end

local VerticalStepScroll = class(Layer)

function VerticalStepScroll:create(width, height, itemHeight)
	local instance = VerticalStepScroll.new()
	instance:init(width, height, itemHeight)
	return instance
end

function VerticalStepScroll:ctor()
	self.name = 'VerticalStepScroll'
end

function VerticalStepScroll:init(width, height, itemHeight)

	Layer.initLayer(self)

	local useClipping
	local useBlockingLayers

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
	self.itemHeight = itemHeight
	self.bottomMostOffset = 0
	self.topMostOffset = 0
	self.yOffset = 0

	local rect = {size = {width = self.width, height = self.height}}
-- fix issue: nested or stacked clipping node doesn't work properly
	local clipping = nil
if useClipping then 
	clipping = SimpleClippingNode:create() -- ClippingNode:create(rect)
  	clipping:setContentSize(CCSizeMake(rect.size.width, rect.size.height))
  	clipping:setRecalcPosition(true)
else
	clipping = LayerColor:create()
	clipping:setColor(ccc3(22,22,22))
	clipping:setOpacity(0)
	clipping:setContentSize(CCSizeMake(rect.size.width, rect.size.height))
end
-- end of fix
	clipping.name = 'VerticalStepScroll.clipping'
	-- clipping.debugTag = 1

	-- clipping:setAnchorPoint(ccp(0, 1))

	local topBlocking = nil
	local bottomBlocking = nil
if useBlockingLayers then
	topBlocking = LayerColor:create()
	topBlocking:setColor(ccc3(255, 0, 0))
	topBlocking:setOpacity(0)
	topBlocking.name = 'VerticalStepScroll.topBlocking'
	-- topBlocking.debugTag = 1

	bottomBlocking = LayerColor:create()
	bottomBlocking:setColor(ccc3(0, 20, 0))
	bottomBlocking:setOpacity(0)
	bottomBlocking.name = 'VerticalStepScroll.bottomBlocking'
	-- bottomBlocking.debugTag = 1
end

	local touchLayer = LayerColor:create()
	touchLayer:setColor(ccc3(0, 0, 255))
	touchLayer:setOpacity(0)
	touchLayer.name = 'VerticalStepScroll.touchLayer'
	-- touchLayer.debugTag = 1

	-- using a zero-sized node to simulate a cursor,
	-- so that the child will be placed at (0,0)
	-- and later the cordinates (x, y) will always
	-- be greater than zero(this is more practical, isn't it?)
	-- the cursor won't move
	local cursor = Layer:create()
	cursor.name = 'VerticalStepScroll.cursor'
	-- cursor.debugTag = 1

	-- using a zero-sized node to simalute a container with
	-- its anchor point set to (0, 1)
	-- thus later when move the container, the yOffset is equal to 
	-- this container's Y cordinate.
	local container = LayerColor:create()
	container.name = 'VerticalStepScroll.container'
	-- container.debugTag = 1

	container:setPosition(ccp(0, 0))
	container:setOpacity(0)
	cursor:addChild(container)
	cursor:setPosition(ccp(0, self.height))
	self.cursor = cursor

if useBlockingLayers then
	topBlocking:setContentSize(CCSizeMake(self.width, 500))
	topBlocking:setPosition(ccp(0,self.height))
	topBlocking:setTouchEnabled(true, 1, true)
	topBlocking:ad(DisplayEvents.kTouchTap, function() if _G.isLocalDevelopMode then printx(0, 'topBlocking') end end)

	bottomBlocking:setContentSize(CCSizeMake(self.width, 500))
	bottomBlocking:setPosition(ccp(0, -(500)))
	bottomBlocking:setTouchEnabled(true, 1, true)
	bottomBlocking:ad(DisplayEvents.kTouchTap, function() if _G.isLocalDevelopMode then printx(0, 'bottomBlocking') end end)
end

	touchLayer:setContentSize(CCSizeMake(self.width, self.height))
	touchLayer:setTouchEnabled(true, 0, false)
	touchLayer:setPosition(ccp(0, -self.height))
	touchLayer:ad(DisplayEvents.kTouchBegin, function(event) self:onTouchBegin(event) end)
	touchLayer:ad(DisplayEvents.kTouchMove, function(event) self:onTouchMove(event) end)
	touchLayer:ad(DisplayEvents.kTouchEnd, function(event) self:onTouchEnd(event) end)

if useBlockingLayers then 
	clipping:addChild(topBlocking)
	clipping:addChild(bottomBlocking)
end

	clipping:addChild(cursor)
	clipping:setPosition(ccp(0, -self.height))

	self.topBlocking = topBlocking
	self.bottomBlocking = bottomBlocking
	self.touchLayer = touchLayer
	self.clipping = clipping

	-- topBlocking.debugTag = 1
	-- bottomBlocking.debugTag = 1
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

	local lastEmitY
	self.isScrollDirty = false
	self:scheduleUpdateWithPriority(function ( 	 )
		if self.isDisposed then return end
		if self.block then return end
		if lastEmitY ~= self.yOffset or self.isScrollDirty then
			self.isScrollDirty = false
			self:emitScroll()
			lastEmitY = self.yOffset
		end
	end, 1/24)


end

function VerticalStepScroll:emitScroll( ... )
	if self.isDisposed then return end
	if self.onScrollCallback then
		self.onScrollCallback(self.yOffset, ...)
	end
end

function VerticalStepScroll:setScrollEnabled(enabled)
	if self.isDisposed then return end
	self.touchLayer:setTouchEnabled(enabled, 0, false)
end

function VerticalStepScroll:setScrollableHeight(_height)
	local minTopOffset =  -self.itemHeight
	local maxTopOffset =  _height - 2* self.itemHeight
	self.topMostOffset = maxTopOffset
	self.bottomMostOffset = minTopOffset

end

-- set to false will do:
-- if the finger start with vertical movements,
-- we'll recongnize it as a vertical gesture, and thus
-- even if there is horizontal move, we ignore any further movements
function VerticalStepScroll:setIgnoreHorizontalMove(ignore)
	self.ignoreHorizontalMove = ignore
end

-- defaultly, we ignore vertical movements
-- means: what ever the gesture is, we capture its X diffs
function VerticalStepScroll:isIgnoreHorizontalMove()
	if self.ignoreHorizontalMove ~= nil then
		return self.ignoreHorizontalMove
	else 
		return true
	end
end

function VerticalStepScroll:checkMoveStarted(x, y)
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

function VerticalStepScroll:getScrollDirection()
	return self.scrollDirection or ScrollDirection.kNone
end

function VerticalStepScroll:onTouchBegin(event)

	self.block = true

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

function VerticalStepScroll:onTouchMove(event)
	local y = event.globalPosition.y
	local x = event.globalPosition.x

	if not self:isIgnoreHorizontalMove() then
		-- if move not started, or if horizontal move, then return
		if not self:checkMoveStarted(x, y) 
			or self:getScrollDirection() ~= ScrollDirection.kVertical 
		then 
			return 
		end
	end
	
	-- self.speedwatch:onTouchMove(0, self.last_y)
	self.speedometers[1]:setXY(0, y)
	if self.last_y == 0 then self.last_y = y end
	local dy = y - self.last_y

	-- if math.abs(dy) < self.itemHeight/2 then
	-- 	return
	-- end

	

	-- dy = sign(dy) * math.ceil(math.floor(math.abs(dy) / (self.itemHeight/2)) / 2) * self.itemHeight 

	local tarOffset = self.yOffset + dy

	self.upDir = dy > 0 

	if tarOffset >= self.bottomMostOffset and tarOffset <= self.topMostOffset then
		self:__moveTo(tarOffset, 0)
	elseif tarOffset > self.topMostOffset or tarOffset < self.bottomMostOffset then
		if self.onOutOfRange then
			self.onOutOfRange(tarOffset < self.bottomMostOffset)
		end
	end

	self.last_y = y
	self:updateContentViewArea()

	self:emitScroll(true)

end

function VerticalStepScroll:onTouchEnd(event)

	self.block = false

	self.last_y = event.globalPosition.y
	self.last_x = event.globalPosition.x

	if not self:isIgnoreHorizontalMove() then
		-- if move not started, or if horizontal move, then return
		if not self:checkMoveStarted(self.last_x, self.last_y) 
			or self:getScrollDirection() ~= ScrollDirection.kVertical 
		then 
			return 
		end
	end
	-- self.speedwatch:onTouchEnd(0, self.last_y)
	for i, v in ipairs(self.speedometers) do
		v:stopMeasure()
	end

	self.yOffset = self.container:getPositionY()

	local speed = self:getSwipeSpeed()
	if self.yOffset > self.topMostOffset then
		self:__moveTo(self.topMostOffset, 0.3)
	--bottom out of border
	elseif self.yOffset < self.bottomMostOffset then 
		self:__moveTo(self.bottomMostOffset, 0.3)
	elseif speed ~= 0 then
		self:slide(speed)
	else
		local k = math.floor((self.yOffset + self.height / 2 - self.itemHeight / 2) / self.itemHeight + 0.5) * self.itemHeight + self.itemHeight/2 - self.height/2
		self:gotoPositionY(k)
	end
	self:updateContentViewArea()
end

function VerticalStepScroll:getSwipeSpeed()
	-- local speedx, speedy = self.speedwatch:getVelocityXY()
	local speedy = self.speedometers[1]:getSpeedY()

	if speedy > 1 or speedy < -1
	then
		return speedy
	else 
		return 0
	end
end

function VerticalStepScroll:stopSlide()
	if self.isDisposed then return end
	self.container:stopAllActions()
	if self.schedId ~= nil then
		Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedId)
		self.schedId = nil
	end
end

function VerticalStepScroll:slide(speed)


	if self.isDisposed then return end

	local scheduler = Director:sharedDirector():getScheduler()
	local resistance = 666 * sign(speed)
	local duration = math.abs(speed / resistance)
	local distance = speed * speed / (resistance * 2)


	if distance + self.yOffset < self.bottomMostOffset then
		distance = self.bottomMostOffset - self.yOffset
	end

	if distance + self.yOffset > self.topMostOffset then
		distance = self.topMostOffset - self.yOffset
	end


	local target = distance + self.yOffset
	local k = math.floor((target + self.height / 2 - self.itemHeight / 2) / self.itemHeight + 0.5) * self.itemHeight + self.itemHeight/2 - self.height/2
	distance = target - self.yOffset

	if distance + self.yOffset < self.bottomMostOffset then
		distance = self.bottomMostOffset - self.yOffset
	end

	if distance + self.yOffset > self.topMostOffset then
		distance = self.topMostOffset - self.yOffset
	end



	local function __unschdule()
		if self.schedId ~= nil then
			scheduler:unscheduleScriptEntry(self.schedId)
			self.schedId = nil
		end
	end

	local action = CCSequence:createWithTwoActions(
	                CCEaseSineOut:create(
	                 CCMoveBy:create(duration, ccp(0, distance))
	                 ),
	                CCCallFunc:create(function ( ... )
	                	__unschdule()

	                	if self.isDisposed then return end
	                	
	                	local k = math.floor((self.yOffset + self.height / 2 - self.itemHeight / 2) / self.itemHeight + 0.5) * self.itemHeight + self.itemHeight/2 - self.height/2
						self:gotoPositionY(k)
	                end)
	              	)

	local function wrap( a )
		local array = CCArray:create()
		array:addObject(CCCallFunc:create(function ( ... )
			-- body
			self.block = true
		end))

		array:addObject(a)

		array:addObject(CCCallFunc:create(function ( ... )
			-- body
			self.block = false
		end))

		return CCSequence:create(array)
	end

	self.container:runAction(wrap(action))

	local function __check()
		if not self.isDisposed then 
			self.yOffset = self.container:getPositionY()
			if self.yOffset > self.topMostOffset then

				self.container:stopAllActions()
				self:__moveTo(self.topMostOffset, 0.3)
				__unschdule()
			elseif self.yOffset < self.bottomMostOffset then

				self.container:stopAllActions()
				self:__moveTo(self.bottomMostOffset, 0.3)
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

function VerticalStepScroll:__moveTo( Y_Position, duration )
	if self.isDisposed then return end
	if not duration then
		duration = 0
	end

	local dY = Y_Position - self.yOffset

	if duration == 0 then 
		self.container:setPositionY(Y_Position)
	else
		self:onStartMoving()
		local moveAction = CCSequence:createWithTwoActions(
		                    CCEaseSineOut:create(CCMoveTo:create(duration, ccp(0, Y_Position))),
		                    CCCallFunc:create(function() self:onEndMoving()

		                    local k = math.floor((self.yOffset + self.height / 2 - self.itemHeight / 2) / self.itemHeight + 0.5) * self.itemHeight + self.itemHeight/2 - self.height/2
							self:gotoPositionY(k)
						 end)
		                    )
		self.container:stopAllActions()

		local function wrap( a )
			local array = CCArray:create()
			array:addObject(CCCallFunc:create(function ( ... )
				-- body
				self.block = true
			end))

			array:addObject(a)

			array:addObject(CCCallFunc:create(function ( ... )
				-- body
				self.block = false
			end))

			return CCSequence:create(array)
		end

		self.container:runAction(wrap(moveAction))
	end

	self.yOffset = Y_Position
end

function VerticalStepScroll:gotoPositionY(position, duration)
	if self.isDisposed then return end
	self.container:stopAllActions()

	if position < self.bottomMostOffset then
		position = self.bottomMostOffset
	end

	if position > self.topMostOffset then
		position = self.topMostOffset
	end

	self:__moveTo(position, duration or 0.3)
end

function VerticalStepScroll:moveY(deltaY)
	if self.isDisposed then return end
	self.container:stopAllActions()
	deltaY = sign(deltaY) * math.ceil(math.floor(math.abs(deltaY) / (self.itemHeight/2)) / 2) * self.itemHeight

	local position = deltaY + self.yOffset
	if position < self.bottomMostOffset then
		position = self.bottomMostOffset
	end

	if position > self.topMostOffset then
		position = self.topMostOffset
	end

	self:__moveTo(position, 0.3)
end

function VerticalStepScroll:getContent()
	return self.content
end

function VerticalStepScroll:setContent(uiComponent)
	if self.isDisposed then return end
	if not uiComponent then return end
	self:removeContent()
	self.content = uiComponent
	self.container:addChild(uiComponent)
	local height
	if type(uiComponent.getHeight) == "function" then
		height = uiComponent:getHeight()
	else
		height = uiComponent:getGroupBounds().size.height
	end
	self:setScrollableHeight(height)
	self:updateContentViewArea()
end

function VerticalStepScroll:updateScrollableHeight()
	if self.isDisposed then return end

	self.isScrollDirty = true
	self:setScrollableHeight(self.content:getHeight())

	if self.yOffset < self.bottomMostOffset then
		self:gotoPositionY(self.bottomMostOffset)
	end

	if self.yOffset > self.topMostOffset then
		self:gotoPositionY(self.topMostOffset)
	end

end

function VerticalStepScroll:removeContent()
	if self.isDisposed then return end

	if self.content and self.content:getParent() then 
		self.content:removeFromParentAndCleanup(true)
		self.content = nil
	end
	self:setScrollableHeight(0)
end

-- implementation obliged: items use this function to 
-- test click Hit Point
function VerticalStepScroll:getViewRectInWorldSpace()
	if self.isDisposed then return end
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
function VerticalStepScroll:updateContentViewArea()
	if self.isDisposed then return end

	if self.content and self.content.updateViewArea then
		local top = self.yOffset
		local bottom = self.yOffset + self.height
		self.content:updateViewArea(top, bottom)
	end
end

function VerticalStepScroll:onStartMoving()
	local function __update()
		self:updateContentViewArea()
	end
	if not self.updateSchedId then
		self.updateSchedId = Director:sharedDirector():getScheduler():scheduleScriptFunc(__update, 1/60, false)
	end
end

function VerticalStepScroll:onEndMoving()
	self:dispatchEvent(Event.new(ScrollableEvents.kEndMoving, nil, self))
	if self.updateSchedId then 
		Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.updateSchedId)
		self.updateSchedId = nil
	end
end

function VerticalStepScroll:scrollToTop()
	if self.isDisposed then return end
	if self.content and self.content.__layout then
		self.content:__layout()
	end
    self:stopSlide()
    self:__moveTo(self.bottomMostOffset, 0.3)
end

function VerticalStepScroll:scrollToBottom()
	if self.isDisposed then return end
	if self.content and self.content.__layout then
		self.content:__layout()
	end
	self:stopSlide()
    self:__moveTo(self.topMostOffset, 0.3)
end

function VerticalStepScroll:dispose()
	if self.schedId ~= nil then
		Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedId)
		self.schedId = nil
	end
	if self.updateSchedId ~= nil then 
		Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.updateSchedId)
		self.updateSchedId = nil
	end
	self:unscheduleUpdate()
	Layer.dispose(self)
end

return VerticalStepScroll