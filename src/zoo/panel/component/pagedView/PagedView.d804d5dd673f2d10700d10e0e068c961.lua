require 'zoo.panel.component.pagedView.PageRenderer'
require 'zoo.panel.component.pagedView.Pager'

require 'zoo.scenes.component.HomeScene.WorldSceneScroller'

--------- ANIMATION DURATION --------
local SINGLE_PAGE_ANIM_DURATION = 0.25
local PAGE_BOUNCE_BACK_DURATION = 0.15

------------ THRESHOLD ----------------
local LOWEST_SWIPE_SPEED = 200 --px/sec
local SHORTEST_DISTANCE_PER_TOUCH = 35 --px


local SwipeEvents = {kLeftSwipe = 'LEFT_SWIPE', kRightSwipe = 'RIGHT_SWIPE'}


-- a swipe must meet 2 conditions:
-- 1. enough distance
-- 2. enough instant speed
local function hasLeftSwipe(speedometer, touchMoveDistanceX)

	local speed1 = speedometer[1].measuredVelocityX or 0
	local speed2 = speedometer[2].measuredVelocityX or 0
	local speed = (speed2 * 3 + speed1)/4 -- 对频率高的测速器，减弱它的影响，防止手指最后的轻微抖动影响测速
	-- print ('speed1 ', speed1, 'speed2 ', speed2, 'speed ', speed)

	if speed < -LOWEST_SWIPE_SPEED and 
		math.abs(touchMoveDistanceX) > SHORTEST_DISTANCE_PER_TOUCH
	then
		return true
	else 
		return false
	end
end

local function hasRightSwipe(speedometer, touchMoveDistanceX)

	local speed1 = speedometer[1].measuredVelocityX or 0
	local speed2 = speedometer[2].measuredVelocityX or 0
	local speed = (speed2 * 3 + speed1)/4
	-- print ('speed1 ', speed1, 'speed2 ', speed2, 'speed ', speed)

	if speed > LOWEST_SWIPE_SPEED and 
		math.abs(touchMoveDistanceX) > SHORTEST_DISTANCE_PER_TOUCH
	then
		return true
	else 
		return false
	end
end



--------------------- PAGED VIEW CLASS -------------------
PagedView = class(Layer)

function PagedView:create(width, height, numOfPages, pager, useClipping, useBlockingLayers)
	-- print("PagedView:create",debug.traceback())
	
	local pv = PagedView.new()
	pv:init(width, height, numOfPages, pager, useClipping, useBlockingLayers)
	return pv
end

function PagedView:init(width, height, numOfPages, pager, useClipping, useBlockingLayers)

	if useClipping == nil then
		useClipping = true
	end
	if useBlockingLayers == nil then
		useBlockingLayers = true
	end

	assert(width > 0)
	assert(height > 0)

	Layer.initLayer(self)	 
	-- use left upper corner as the Anchor point
	self:setAnchorPoint(ccp(0,0))

	self:addEventListener(SwipeEvents.kLeftSwipe, function(event) self:onLeftSwipe(event) end )
	self:addEventListener(SwipeEvents.kRightSwipe, function(event) self:onRightSwipe(event) end )
	


	self.width = width
	self.height = height
	self.numOfPages = numOfPages or 1
	self.pageIndex = 1

	self.pageRenderers = {}

	self.xOffset = 0

	self.leftMostOffset = 0
	self.rightMostOffset = self.width * (self.numOfPages - 1)


	self.last_x = 0
	self.last_y = 0
	self.moveStartX = 0
	self.moveStartY = 0

	------------------- SPEEDOMETER -----------------
	local function __getPosition()
		return ccp(self.last_x, self.last_y)
	end
	self.speedometer = {}
	self.speedometer[1] = VelocityMeasurer:create(2/60, __getPosition) -- take meature every x frames
	self.speedometer[2] = VelocityMeasurer:create(6/60, __getPosition)



	-- container for pages
	-- local pageLayer = LayerColor:create()
	local pageLayer = Layer:create()
	pageLayer:setAnchorPoint(ccp(0,0))
	-- pageLayer:setColor(ccc3(0,0,0))
	-- pageLayer:setOpacity(0)
	pageLayer:changeWidthAndHeight(self.width * self.numOfPages, self.height)
	pageLayer:setTouchEnabled(true, 0, false)
	pageLayer:setPosition(ccp(0, 0))
	self.pageLayer = pageLayer


	-- receive touch events
	self.touchReceiveLayer = LayerColor:create()
	-- self.touchReceiveLayer = Layer:create()
	self.touchReceiveLayer:setAnchorPoint(ccp(0,0))
	self.touchReceiveLayer:setTouchEnabled(true, 0, false)
	self.touchReceiveLayer:setColor(ccc3(255, 255, 255))
	self.touchReceiveLayer:changeWidthAndHeight(self.width, self.height)
	self.touchReceiveLayer:setOpacity(0)
	self.touchReceiveLayer:setPosition(ccp(0, 0))
	self.touchReceiveLayer.name = "touchReceiveLayer"

	------------------- BLOCKING LAYERS ---------------------
	-- swallows all touch events from the right and left
	-- allowing only the viewing area to receive touch events

if useBlockingLayers then
	self.leftBlockingLayer = LayerColor:create()
	self.leftBlockingLayer:setTouchEnabled(true, 0, true)
	self.leftBlockingLayer:setColor(ccc3(0, 255, 0))
	self.leftBlockingLayer:changeWidthAndHeight(self.width, self.height)
	self.leftBlockingLayer:setOpacity(0)
	self.leftBlockingLayer:setPosition(ccp(-self.width, 0))

	self.rightBlockingLayer = LayerColor:create()
	self.rightBlockingLayer:setTouchEnabled(true, 0, true)
	self.rightBlockingLayer:setColor(ccc3(0, 255, 0))
	self.rightBlockingLayer:changeWidthAndHeight(self.width, self.height)
	self.rightBlockingLayer:setOpacity(0)
	self.rightBlockingLayer:setPosition(ccp(self.width, 0))
end

	local function onReceiveLayerTouchBegin(event)
		self:onPageTouchBegin(event)
	end

	local function onReceiveLayerTouchMove(event)
		self:onPageTouchMove(event)
	end

	local function onReceiveLayerTouchEnd(event)
		self:onPageTouchEnd(event)
	end

	self.touchReceiveLayer:addEventListener(DisplayEvents.kTouchBegin, onReceiveLayerTouchBegin)
	self.touchReceiveLayer:addEventListener(DisplayEvents.kTouchMove, onReceiveLayerTouchMove)
	self.touchReceiveLayer:addEventListener(DisplayEvents.kTouchEnd, onReceiveLayerTouchEnd)


	local rect = {size={width=self.width, height=self.height}}

if useClipping then
	self.clipping = SimpleClippingNode:create() -- ClippingNode:create(rect)
  	self.clipping:setContentSize(CCSizeMake(rect.size.width, rect.size.height))
  	self.clipping:setRecalcPosition(true)
else
	self.clipping = Layer:create()
end
	self.clipping:setPosition(ccp(0,0))
	self.clipping:addChild(self.pageLayer)

if useBlockingLayers then
	self.clipping:addChild(self.leftBlockingLayer)
	self.clipping:addChild(self.rightBlockingLayer)
end

	self.clipping:addChild(self.touchReceiveLayer)

	self:addChild(self.clipping)


	self.pager = pager

end

-- implementation obliged: items use this function to 
-- test click Hit Point
function PagedView:getViewRectInWorldSpace()
	-- DO NOT use getGroupBounds() on clipping nodes, it does not work on clipping nodes
	-- use touchLayer instead to present the view area
	local size = self.touchReceiveLayer:getGroupBounds().size
	local origin = self.touchReceiveLayer:getPosition()
	local pos = self.touchReceiveLayer:getParent():convertToWorldSpace(ccp(origin.x, origin.y))
	self.clippingRect = CCRectMake(pos.x, pos.y, size.width, size.height)
	return self.clippingRect
end

function PagedView:getViewSize()

	return CCSizeMake(self.width, self.height)
end




--------------- TOUCH EVENT HANDLERS ------------------

-- set to false will do:
-- if the finger start with vertical movements,
-- we'll recongnize it as a vertical gesture, and thus
-- even if there is horizontal move, we ignore any further movements
function PagedView:setIgnoreVerticalMove(ignore)
	self.ignoreVerticalMove = ignore
end

-- defaultly, we ignore vertical movements
-- means: what ever the gesture is, we capture its X diffs
function PagedView:isIgnoreVerticalMove()
	if self.ignoreVerticalMove ~= nil then
		return self.ignoreVerticalMove
	else 
		return true
	end
end

function PagedView:getScrollDirection()
	return self.scrollDirection or ScrollDirection.kNone
end

-- from touch begin to touch end, the scrollDirection will not change
-- until we trigger another touch begin event
function PagedView:checkMoveStarted(x, y)
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
		if self.scrollDirection == ScrollDirection.kNone then
			if self.startSwitchPageCallback then self.startSwitchPageCallback() end
		end
		self.scrollDirection = ScrollDirection.kHorizontal
		return true
	end
end

function PagedView:setSwitchPageCallback(callback)
	self.startSwitchPageCallback = callback
end

function PagedView:setSwitchPageFinishCallback(callback)
	self.finishSwitchPageCallback = callback
end

function PagedView:onPageTouchBegin(event)

	self.scrollDirection = ScrollDirection.kNone

	self.last_x = event.globalPosition.x
	self.last_y = event.globalPosition.y
	self.moveStartX = event.globalPosition.x
	self.moveStartY = event.globalPosition.y
	for i, v in ipairs(self.speedometer) do
		v:setInitialPos(self.last_x, self.last_y) 
		v:startMeasure()
	end
	-- self.speedometer:startMeasure()

end

function PagedView:onPageTouchMove(event)

	local x = event.globalPosition.x
	local y = event.globalPosition.y
	if self.last_x == 0 then self.last_x = x end

	-- if we dont care about vertical movements
	if not self:isIgnoreVerticalMove() then
		-- if move not started, or if horizontal move, then return
		if not self:checkMoveStarted(x, y) 
			or self:getScrollDirection() ~= ScrollDirection.kHorizontal 
		then
			return 
		end
	end

	local dx = x - self.last_x
	local tarOffset = self.xOffset - dx

	tarOffset = math.max(tarOffset,(self.pageIndex - 2) * self.width)
	tarOffset = math.min(tarOffset,(self.pageIndex - 0) * self.width)
	-- print("onPageTouchMove()ii",self.pageIndex,self.width,self.xOffset,math.max(tarOffset,(self.pageIndex - 1 - 1/2) * self.width))

	if tarOffset >= self.leftMostOffset and tarOffset <= self.rightMostOffset then
		self:__moveTo(tarOffset)
	elseif tarOffset < self.leftMostOffset or tarOffset > self.rightMostOffset then
		self:__moveTo(tarOffset + dx / 2)
	end
	self.last_x = x

	self.last_y = y

end

function PagedView:onPageTouchEnd(event)
	-- print 'touch end'

	for i, v in ipairs(self.speedometer) do
		v:stopMeasure()
	end

	local x = event.globalPosition.x
	local y = event.globalPosition.y

	-- if we dont care about vertical movements
	if not self:isIgnoreVerticalMove() then
		-- if move not started, or if horizontal move, then return
		if not self:checkMoveStarted(x, y) 
			or self:getScrollDirection() ~= ScrollDirection.kHorizontal 
		then 
			return 
		end
	end


	-- self.speedometer:stopMeasure()
	local touchMoveDistanceX = event.globalPosition.x - self.moveStartX
	-- print ('distance = ', touchMoveDistanceX)
	local touchMoveDistanceY = event.globalPosition.y - self.moveStartY

	-- if user swipes, dispatch a swipe event
		-- if _G.isLocalDevelopMode then printx(0, 'speed :', self.speedometer:getMeasuredVelocityX()) end
	if hasLeftSwipe(self.speedometer, touchMoveDistanceX) 
		then
		self:dispatchEvent(Event.new(SwipeEvents.kLeftSwipe, nil, nil))

	elseif hasRightSwipe(self.speedometer, touchMoveDistanceX) 
		then
		self:dispatchEvent(Event.new(SwipeEvents.kRightSwipe, nil, nil))
	else 
		-- no swipe, then go to next page OR return to current page
		if self.xOffset > (self.pageIndex - 1 + 1/2) * self.width  then
			-- if _G.isLocalDevelopMode then printx(0, 'xOffset = ', self.xOffset, 'next') end 
			self:nextPage()
		elseif self.xOffset < (self.pageIndex - 1 - 1/2) * self.width
		then
			self:prevPage()
		elseif self.xOffset <= (self.pageIndex - 1 + 1/2) * self.width
			or self.xOffset >= (self.pageIndex - 1 - 1/2) * self.width
		then
			-- if _G.isLocalDevelopMode then printx(0, 'xOffset = ', self.xOffset, 'stay') end 
			self:gotoPage(self.pageIndex)
		end
	end
	



	------------------ Bounce Back Logic -------------------
	-- when there is no more next/ prev page, but user is still dragging the page
	-- do bounce back once the user release the drag
	local function cb() if self.finishSwitchPageCallback then self.finishSwitchPageCallback() end end
	if self.xOffset < self.leftMostOffset then  -- left out of bound
		self:__moveTo(0, PAGE_BOUNCE_BACK_DURATION, cb)
	elseif self.xOffset > self.rightMostOffset then -- right out of bound
		self:__moveTo(self.rightMostOffset, PAGE_BOUNCE_BACK_DURATION, cb)
	elseif false then
	end
end

function PagedView:onLeftSwipe(event)
	-- print 'LEFT swipe detected'
	self:nextPage()
end

function PagedView:onRightSwipe(event)
	-- print 'RIGHT swipe detected'
	self:prevPage()
end



----------------- PAGING FUNCTIONS -------------------
function  PagedView:canNextPage()
	if self.pageIndex < self.numOfPages then 
		return true
	end
	return false
end

function PagedView:canPrevPage()
	if self.pageIndex > 1 then
		return true
	end
	return false
end

function PagedView:canGotoPage(index)
	if index >= 1  and index <= self.numOfPages then
		return true
	end
	return false
end

function PagedView:nextPage()
	local function cb() 
		if self.pager then self.pager:next()  end
		-- self.pageIndex = self.pageIndex + 1 -- test
		if self.finishSwitchPageCallback then self.finishSwitchPageCallback() end
	end
	if self:canNextPage() then 
		local targetOffset = self.width * self.pageIndex
		-- if _G.isLocalDevelopMode then printx(0, self.xOffset, targetOffset) end
		self.pageIndex = self.pageIndex + 1
		self:__moveTo(targetOffset, SINGLE_PAGE_ANIM_DURATION, cb)
	else 
		self:gotoPage(self.numOfPages)
	end
end

function PagedView:prevPage()
	local function cb()
	-- print 'prev page callback'	
		if self.pager then self.pager:prev() end
		-- self.pageIndex = self.pageIndex - 1 -- test
		if self.finishSwitchPageCallback then self.finishSwitchPageCallback() end
	end

	if self:canPrevPage() then
		local targetOffset = (self.pageIndex - 2) * self.width
		self.pageIndex = self.pageIndex - 1 -- test
		self:__moveTo(targetOffset, SINGLE_PAGE_ANIM_DURATION, cb)
	else
		self:gotoPage(1)
	end
end

function PagedView:gotoPage(index, duration)
	-- if _G.isLocalDevelopMode then printx(0, 'PagedView:gotoPage', index) end
	if index > self.numOfPages then 
		index = self.numOfPages
	elseif index < 0 then
		index = 1
	end
	if self:canGotoPage(index) then 

		local targetOffset = (index - 1) * self.width
		local function cb()
			-- print 'goto page callback'
			if self.pager then self.pager:goto(index) end
			-- self.pageIndex = index -- test
			if self.finishSwitchPageCallback then self.finishSwitchPageCallback() end
		end
		if self:canGotoPage(index) then
			if index ~= self.pageIndex then
				if type(self.startSwitchPageCallback) == "function" then self.startSwitchPageCallback() end
			end
			self.pageIndex = index
			if duration then 
				self:__moveTo(targetOffset, duration, cb)
			else
				self:__moveTo(targetOffset, SINGLE_PAGE_ANIM_DURATION, cb)
			end
		end
	end
end

function PagedView:addPageAt(pageRenderer, index)
	assert(pageRenderer)
	assert(index)
	assert(index > 0)

	if self.pageRenderers[index] ~= nil 
	then return false end

	local prSize = pageRenderer:getGroupBounds().size
	local x = self.width * (index - 1) + (self.width - prSize.width)/2
	-- if _G.isLocalDevelopMode then printx(0, 'PagedView:addPageAt()page', index, 'x', x) end
	-- if _G.isLocalDevelopMode then printx(0, 'add page at: ', x) end
	pageRenderer:setPosition(ccp(x, self.height))
	self.pageLayer:addChild(pageRenderer)
	self.pageRenderers[index] = pageRenderer

	return true
end

function PagedView:appendPage(pageRenderer)
	assert(pageRenderer)

	self.numOfPages = self.numOfPages + 1
	self.pageLayer:changeWidthAndHeight(self.width * self.numOfPages, self.height)

	self:addPageAt(pageRenderer, self.numOfPages)

	self.rightMostOffset = self.width * (self.numOfPages - 1)

	self.rightBlockingLayer:removeFromParentAndCleanup(false)
	self.pageRenderers[self.numOfPages]:removeFromParentAndCleanup(false)
	self.pageLayer:addChild(self.pageRenderers[self.numOfPages])
	self.clipping:addChild(self.rightBlockingLayer)

	if self.pager then self.pager:addPage() end
end

function PagedView:getPageIndex()
	return self.pageIndex
end

----------------- PRIVATE FUNCTIONS ------------------
function PagedView:__moveTo( X_Position, duration, callback )
	if not duration or duration < 0 then duration = 0 end
	local dX = self.xOffset - X_Position
	local moveAction = CCMoveBy:create(duration, ccp(dX, 0))
	-- local moveAction = CCMoveTo:create(duration, ccp(-X_Position, 0))
	local _cb = function() 
		for i = 1, self.numOfPages do
			if self.pageRenderers[i] then
				self.pageRenderers[i]:setVisible(self:__shouldShowPage(i))
			end
		end
		callback()
	end

	for i = 1, self.numOfPages do
		if self.pageRenderers[i] then
			self.pageRenderers[i]:setVisible(true)
		end
	end

	if callback then
		local cb = CCCallFunc:create(_cb)
		local easeAction = CCEaseSineOut:create(moveAction)
		self.pageLayer:runAction(CCSequence:createWithTwoActions(easeAction, cb))
	else 
		self.pageLayer:runAction(moveAction)
	end

	self.xOffset = X_Position
end

function PagedView:__shouldShowPage( pageIndex )
	return pageIndex == self.pageIndex
end