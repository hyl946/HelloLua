require 'zoo.panel.component.pagedView.PageRenderer'
require 'zoo.panel.component.pagedView.Pager'

require 'zoo.scenes.component.HomeScene.WorldSceneScroller'

--------- ANIMATION DURATION --------
local SINGLE_PAGE_ANIM_DURATION = 0.25
local PAGE_BOUNCE_BACK_DURATION = 0.15

------------ THRESHOLD ----------------
local LOWEST_SWIPE_SPEED = 200 --px/sec
local SHORTEST_DISTANCE_PER_TOUCH = 35 --px


local SwipeEvents = {kUpSwipe = 'UP_SWIPE', kDownSwipe = 'DOWN_SWIPE'}


-- a swipe must meet 2 conditions:
-- 1. enough distance
-- 2. enough instant speed
local function hasUpSwipe(speedometer, touchMoveDistanceY)

	local speed1 = speedometer[1].measuredVelocityY or 0
	local speed2 = speedometer[2].measuredVelocityY or 0
	local speed = (speed2 * 3 + speed1)/4 -- 对频率高的测速器，减弱它的影响，防止手指最后的轻微抖动影响测速
	-- print ('speed1 ', speed1, 'speed2 ', speed2, 'speed ', speed)

	if speed > LOWEST_SWIPE_SPEED and math.abs(touchMoveDistanceY) > SHORTEST_DISTANCE_PER_TOUCH then
		return true
	else 
		return false
	end
end

local function hasDownSwipe(speedometer, touchMoveDistanceY)

	local speed1 = speedometer[1].measuredVelocityY or 0
	local speed2 = speedometer[2].measuredVelocityY or 0
	local speed = (speed2 * 3 + speed1)/4
	-- print ('speed1 ', speed1, 'speed2 ', speed2, 'speed ', speed)

	if speed < -LOWEST_SWIPE_SPEED and math.abs(touchMoveDistanceY) > SHORTEST_DISTANCE_PER_TOUCH then
		return true
	else 
		return false
	end
end



--------------------- PAGED VIEW CLASS -------------------
PagedViewVertical = class(Layer)

function PagedViewVertical:create(width, height, numOfPages, pager, useClipping, useBlockingLayers)
	local pv = PagedViewVertical.new()
	pv:init(width, height, numOfPages, pager, useClipping, useBlockingLayers)
	return pv
end

function PagedViewVertical:init(width, height, numOfPages, pager, useClipping, useBlockingLayers)
	if useClipping == nil then
		useClipping = true
	end
	if useBlockingLayers == nil then
		useBlockingLayers = true
	end
	Layer.initLayer(self)	 

	self:setAnchorPoint(ccp(0,0))

	self:addEventListener(SwipeEvents.kUpSwipe, function(event) self:onUpSwipe(event) end )
	self:addEventListener(SwipeEvents.kDownSwipe, function(event) self:onDownSwipe(event) end )
	
	self.width = width
	self.height = height
	self.numOfPages = numOfPages or 1
	self.pageIndex = 1

	self.pageRenderers = {}

	self.xOffset = 0
	self.yOffset = 0

	-- self.leftMostOffset = 0
	-- self.rightMostOffset = self.width * (self.numOfPages - 1)
	self.upMostOffset = 0
	self.downMostOffset = -self.height * (self.numOfPages - 1)


	self.last_x = 0
	self.last_y = 0
	self.moveStartX = 0
	self.moveStartY = 0

	self.isBouncy = true
	------------------- SPEEDOMETER -----------------
	local function __getPosition()
		return ccp(self.last_x, self.last_y)
	end
	self.speedometer = {}
	self.speedometer[1] = VelocityMeasurer:create(2/60, __getPosition) -- take meature every x frames
	self.speedometer[2] = VelocityMeasurer:create(6/60, __getPosition)



	-- container for pages
	local pageLayer = LayerColor:create()
	-- local pageLayer = Layer:create()
	pageLayer:setAnchorPoint(ccp(0,0))
	pageLayer:setColor(ccc3(255,0,0))
	pageLayer:setOpacity(120)
	pageLayer:changeWidthAndHeight(self.width, self.height * self.numOfPages)
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
	-- swallows all touch events from the up and down
	-- allowing only the viewing area to receive touch events
	if useBlockingLayers then
		self.upBlockingLayer = LayerColor:create()
		self.upBlockingLayer:setTouchEnabled(true, 0, true)
		self.upBlockingLayer:setColor(ccc3(0, 255, 0))
		self.upBlockingLayer:changeWidthAndHeight(self.width, self.height)
		self.upBlockingLayer:setOpacity(0)
		self.upBlockingLayer:setPosition(ccp(0, self.height))

		self.downBlockingLayer = LayerColor:create()
		self.downBlockingLayer:setTouchEnabled(true, 0, true)
		self.downBlockingLayer:setColor(ccc3(0, 255, 0))
		self.downBlockingLayer:changeWidthAndHeight(self.width, self.height)
		self.downBlockingLayer:setOpacity(0)
		self.downBlockingLayer:setPosition(ccp(0, -self.height))
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
		self.clipping:addChild(self.upBlockingLayer)
		self.clipping:addChild(self.downBlockingLayer)
	end
	self.clipping:addChild(self.touchReceiveLayer)
	self:addChild(self.clipping)
	self.pager = pager
end

function PagedViewVertical:setScrollEnable(isEnable)
	if isEnable then 
		self.touchReceiveLayer:setTouchEnabled(true, 0, false)
	else
		self.touchReceiveLayer:setTouchEnabled(false)
	end
end

-- implementation obliged: items use this function to 
-- test click Hit Point
function PagedViewVertical:getViewRectInWorldSpace()
	-- DO NOT use getGroupBounds() on clipping nodes, it does not work on clipping nodes
	-- use touchLayer instead to present the view area
	local size = self.touchReceiveLayer:getGroupBounds().size
	local origin = self.touchReceiveLayer:getPosition()
	local pos = self.touchReceiveLayer:getParent():convertToWorldSpace(ccp(origin.x, origin.y))
	self.clippingRect = CCRectMake(pos.x, pos.y, size.width, size.height)
	return self.clippingRect
end

function PagedViewVertical:getViewSize()
	return CCSizeMake(self.width, self.height)
end

--------------- TOUCH EVENT HANDLERS ------------------

-- set to false will do:
-- if the finger start with horizontal movements,
-- we'll recongnize it as a horizontal gesture, and thus
-- even if there is vertical move, we ignore any further movements
function PagedViewVertical:setIgnoreHorizontalMove(ignore)
	self.ignoreHorizontalMove = ignore
end

-- defaultly, we ignore horizontal movements
-- means: what ever the gesture is, we capture its Y diffs
function PagedViewVertical:isIgnoreHorizontalMove()
	if self.ignoreHorizontalMove ~= nil then
		return self.ignoreHorizontalMove
	else 
		return true
	end
end

function PagedViewVertical:getScrollDirection()
	return self.scrollDirection or ScrollDirection.kNone
end

-- from touch begin to touch end, the scrollDirection will not change
-- until we trigger another touch begin event
function PagedViewVertical:checkMoveStarted(x, y)
	local distance = ccpDistance(ccp(self.moveStartX, self.moveStartY), ccp(x, y))
	local threshold = 15
	-- if already started, we dont check any more
	if self.scrollDirection ~= ScrollDirection.kNone then return true end
	-- while distance is too short, return false
	if distance < threshold then return false end

	local dx = math.abs(self.moveStartX - x)
	local dy = math.abs(self.moveStartY - y)
	if dx > dy then 
		self.scrollDirection = ScrollDirection.kHorizontal
		return true
	else
		if self.scrollDirection == ScrollDirection.kNone then
			if self.startSwitchPageCallback then self.startSwitchPageCallback() end
		end
		self.scrollDirection = ScrollDirection.kVertical
		return true
	end
end

function PagedViewVertical:setTouchBeginCallback(callback)
	self.pageTouchBeginCallback = callback
end

function PagedViewVertical:setSwitchPageCallback(callback)
	self.startSwitchPageCallback = callback
end

function PagedViewVertical:setSwitchPageFinishCallback(callback)
	self.finishSwitchPageCallback = callback
end

function PagedViewVertical:onPageTouchBegin(event)
	self.scrollDirection = ScrollDirection.kNone

	self.last_x = event.globalPosition.x
	self.last_y = event.globalPosition.y
	self.moveStartX = event.globalPosition.x
	self.moveStartY = event.globalPosition.y
	for i, v in ipairs(self.speedometer) do
		v:setInitialPos(self.last_x, self.last_y) 
		v:startMeasure()
	end
	if self.pageTouchBeginCallback then 
		self.pageTouchBeginCallback()
	end
	-- self.speedometer:startMeasure()
end

function PagedViewVertical:onPageTouchMove(event)
	local x = event.globalPosition.x
	local y = event.globalPosition.y

	if self.last_y == 0 then self.last_y = y end

	-- if we dont care about horizontal movements
	if not self:isIgnoreHorizontalMove() then
		-- if move not started, or if horizontal move, then return
		if not self:checkMoveStarted(x, y) or self:getScrollDirection() ~= ScrollDirection.kVertical then
			return 
		end
	end

	local dy = y - self.last_y
	local tarOffset = self.yOffset + dy
	local pos = self.pageLayer:getPosition()

	if tarOffset <= self.upMostOffset and tarOffset >= self.downMostOffset then
		self:__moveTo(tarOffset)
	elseif tarOffset > self.upMostOffset then
		if not self.isBouncy then 
			self:__moveTo(self.upMostOffset)
		elseif self.bouncyMaxUp then 
			local moveUpD 
			if self.bouncyMaxUp == 0 then 
				moveUpD = self.upMostOffset
			else
				moveUpD = math.min(tarOffset + dy / 2, self.upMostOffset + self.bouncyMaxUp)
			end
			self:__moveTo(moveUpD)
		else
			self:__moveTo(tarOffset + dy / 2)
		end 
	elseif tarOffset < self.downMostOffset then
		if not self.isBouncy then 
			self:__moveTo(self.downMostOffset)
		elseif self.bouncyMaxDown then 
			local moveDownD 
			if self.bouncyMaxDown == 0 then 
				moveDownD = self.downMostOffset
			else
				moveDownD = math.max(tarOffset + dy / 2, self.downMostOffset - self.bouncyMaxDown)
			end
			self:__moveTo(moveDownD)
		else
			self:__moveTo(tarOffset + dy / 2)
		end 
	end
	self.last_y = y

	self.last_x = x
end

function PagedViewVertical:setIsBouncy(isBouncy)
	self.isBouncy = isBouncy
end

function PagedViewVertical:setBouncyMaxDelta(bouncyMaxUp, bouncyMaxDown)
	self.bouncyMaxUp = bouncyMaxUp
	self.bouncyMaxDown = bouncyMaxDown
end

function PagedViewVertical:onPageTouchEnd(event)
	for i, v in ipairs(self.speedometer) do
		v:stopMeasure()
	end

	local x = event.globalPosition.x
	local y = event.globalPosition.y

	-- if we dont care about horizontal movements
	if not self:isIgnoreHorizontalMove() then
		-- if move not started, or if vertical move, then return
		if not self:checkMoveStarted(x, y) or self:getScrollDirection() ~= ScrollDirection.kVertical then 
			return 
		end
	end

	-- self.speedometer:stopMeasure()
	local touchMoveDistanceX = event.globalPosition.x - self.moveStartX
	-- print ('distance = ', touchMoveDistanceX)
	local touchMoveDistanceY = event.globalPosition.y - self.moveStartY

	-- if user swipes, dispatch a swipe event
		-- if _G.isLocalDevelopMode then printx(0, 'speed :', self.speedometer:getMeasuredVelocityX()) end
	if hasUpSwipe(self.speedometer, touchMoveDistanceY) then
		self:dispatchEvent(Event.new(SwipeEvents.kUpSwipe, nil, nil))
	elseif hasDownSwipe(self.speedometer, touchMoveDistanceY) then
		self:dispatchEvent(Event.new(SwipeEvents.kDownSwipe, nil, nil))
	else 
		-- no swipe, then go to next page OR return to current page
		if self.yOffset < -(self.pageIndex - 1 + 1/2) * self.height  then
			-- if _G.isLocalDevelopMode then printx(0, 'xOffset = ', self.xOffset, 'next') end 
			self:nextPage()
		elseif self.yOffset > -(self.pageIndex - 1 - 1/2) * self.height then
			self:prevPage()
		elseif self.yOffset >= -(self.pageIndex - 1 + 1/2) * self.height or self.yOffset <= -(self.pageIndex - 1 - 1/2) * self.height then
			-- if _G.isLocalDevelopMode then printx(0, 'xOffset = ', self.xOffset, 'stay') end 
			self:gotoPage(self.pageIndex)
		end
	end

	------------------ Bounce Back Logic -------------------
	-- when there is no more next/ prev page, but user is still dragging the page
	-- do bounce back once the user release the drag
	local function cb() if self.finishSwitchPageCallback then self.finishSwitchPageCallback() end end
	if self.yOffset > self.upMostOffset then  -- up out of bound
		self:__moveTo(self.upMostOffset, PAGE_BOUNCE_BACK_DURATION, cb)
	elseif self.yOffset < self.downMostOffset then -- down out of bound
		self:__moveTo(self.downMostOffset, PAGE_BOUNCE_BACK_DURATION, cb)
	elseif false then
	end
end

function PagedViewVertical:onUpSwipe(event)
	-- print 'UP swipe detected'
	self:prevPage()
end

function PagedViewVertical:onDownSwipe(event)
	-- print 'DOWN swipe detected'
	self:nextPage()
end



----------------- PAGING FUNCTIONS -------------------
function  PagedViewVertical:canNextPage()
	if self.pageIndex < self.numOfPages then 
		return true
	end
	return false
end

function PagedViewVertical:canPrevPage()
	if self.pageIndex > 1 then
		return true
	end
	return false
end

function PagedViewVertical:canGotoPage(index)
	if index >= 1  and index <= self.numOfPages then
		return true
	end
	return false
end

function PagedViewVertical:nextPage()
	local function cb() 
		-- print 'next page callback'
		if self.pager then self.pager:next()  end
		-- self.pageIndex = self.pageIndex + 1 -- test
		if self.finishSwitchPageCallback then self.finishSwitchPageCallback() end
	end
	if self:canNextPage() then 
		local targetOffset = -self.height * self.pageIndex
		if _G.isLocalDevelopMode then printx(0, self.yOffset, targetOffset) end
		self.pageIndex = self.pageIndex + 1
		self:__moveTo(targetOffset, SINGLE_PAGE_ANIM_DURATION, cb)
	else 
		self:gotoPage(self.numOfPages)
	end
end

function PagedViewVertical:prevPage()
	local function cb()
	-- print 'prev page callback'	
		if self.pager then self.pager:prev() end
		-- self.pageIndex = self.pageIndex - 1 -- test
		if self.finishSwitchPageCallback then self.finishSwitchPageCallback() end
	end

	if self:canPrevPage() then
		local targetOffset = -(self.pageIndex - 2) * self.height
		self.pageIndex = self.pageIndex - 1 -- test
		self:__moveTo(targetOffset, SINGLE_PAGE_ANIM_DURATION, cb)
	else
		self:gotoPage(1)
	end
end

function PagedViewVertical:gotoPage(index, duration)
	-- if _G.isLocalDevelopMode then printx(0, 'PagedViewVertical:gotoPage', index) end
	if index > self.numOfPages then 
		index = self.numOfPages
	elseif index < 0 then
		index = 1
	end
	if self:canGotoPage(index) then 
		local targetOffset = -(index - 1) * self.height
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

function PagedViewVertical:addPageAt(pageRenderer, index)
	assert(pageRenderer)
	assert(index)
	assert(index > 0)

	if self.pageRenderers[index] ~= nil 
	then return false end

	local prSize = pageRenderer:getGroupBounds().size
	local x = (self.width - prSize.width)/2
	local y = self.height * index - (self.height - prSize.height)/2
	if _G.isLocalDevelopMode then printx(0, 'page', index, 'x', x) end
	-- if _G.isLocalDevelopMode then printx(0, 'add page at: ', x) end
	pageRenderer:setPosition(ccp(x, y))
	self.pageLayer:addChild(pageRenderer)
	self.pageRenderers[index] = pageRenderer

	return true
end

function PagedViewVertical:appendPage(pageRenderer)
	assert(pageRenderer)

	self.numOfPages = self.numOfPages + 1
	self.pageLayer:changeWidthAndHeight(self.width, self.height * self.numOfPages)

	self:addPageAt(pageRenderer, self.numOfPages)

	self.downMostOffset = self.height * (self.numOfPages - 1)

	self.downBlockingLayer:removeFromParentAndCleanup(false)
	self.pageRenderers[self.numOfPages]:removeFromParentAndCleanup(false)
	self.pageLayer:addChild(self.pageRenderers[self.numOfPages])
	self.clipping:addChild(self.downBlockingLayer)

	if self.pager then self.pager:addPage() end
end

function PagedViewVertical:getPageIndex()
	return self.pageIndex
end

----------------- PRIVATE FUNCTIONS ------------------
function PagedViewVertical:__moveTo( Y_Position, duration, callback )
	if not duration or duration < 0 then duration = 0 end
	local dY =  Y_Position - self.yOffset
	local moveAction = CCMoveBy:create(duration, ccp(0, dY))
	-- local moveAction = CCMoveTo:create(duration, ccp(0, Y_Position))
	local _cb = function() 
		for i = 1, self.numOfPages do
			self.pageRenderers[i]:setVisible(i == self.pageIndex)
		end
		callback()
	end

	for i = 1, self.numOfPages do
		self.pageRenderers[i]:setVisible(true)
	end

	if callback then
		local cb = CCCallFunc:create(_cb)
		local easeAction = CCEaseSineOut:create(moveAction)
		self.pageLayer:runAction(CCSequence:createWithTwoActions(easeAction, cb))
	else 
		self.pageLayer:runAction(moveAction)
	end

	self.yOffset = Y_Position
end
