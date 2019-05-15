---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2019-04-22 14:14:21
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   dan.liang
-- @Last Modified time: 2019-04-24 14:36:56
---------------------------------------------------------------------------------------
TrunkScrollEvents = {
	kScrollTo = "trunk_scroll_to",
}

local TrunkScrollView = class(CocosObject)

function TrunkScrollView:create(min, max, current)
	local view = TrunkScrollView.new(CCNode:create())
	view.className = "TrunkScrollView"
	view:init(min, max, current)
	return view
end

function TrunkScrollView:setRange(min, max)
	self.min = min or 0
	self.max = max or self.min
end

function TrunkScrollView:setCurrent(current)
	self.current = current or self.min
	self:updateView()
end

function TrunkScrollView:setCurrentByPercent(percent)
	local current = math.ceil(self.min + (self.max - self.min) * percent)
	if current < self.min then current = self.min end
	if current > self.max then current = self.max end
	self:setCurrent(current)
end

function TrunkScrollView:setCurrentByPos(pos)
	self:setCurrentByPercent(pos.y / self.viewHeight)
end

function TrunkScrollView:init(min, max, current)
	self.viewWidth = 60
	self.viewHeight = 400

	local displayNode = CocosObject:create(CCNode:create())
	self:addChild(displayNode)

	local touchLayer = LayerColor:createWithColor(ccc3(255, 255, 255), self.viewWidth, self.viewHeight)
	touchLayer:setOpacity(60)
	touchLayer:setTouchEnabled(true, 0, true)
	displayNode:addChild(touchLayer)
	self.touchLayer = touchLayer

	self.currentPosIcon = LayerColor:createWithColor(ccc3(255, 255, 0), self.viewWidth, 4)
	self.currentPosIcon:setPosition(ccp(0, 0))
	displayNode:addChild(self.currentPosIcon)
	local textField = TextField:create("", nil, 30)
	textField:setAnchorPoint(ccp(1, 0.5))
	textField:ignoreAnchorPointForPosition(false)
	textField:setColor(ccc3(255, 255, 0))
	textField:setPosition(ccp(-5, 2))
	self.currentPosIcon:addChild(textField)
	self.currentPosLabel = textField

	self:updateScrollData(min, max, current)

	local toggleLayer = LayerColor:createWithColor(ccc3(0, 255, 0), 20, self.viewHeight)
	toggleLayer:setOpacity(80)
	toggleLayer:setPosition(ccp(60, 0))
	toggleLayer:setTouchEnabled(true, 0, true)
	self:addChild(toggleLayer)
	self.toggleLayer = toggleLayer
	self.isToggleOn = true
	self.toggleLayer:addEventListener(DisplayEvents.kTouchTap, function()
		if self.isToggleOn then
			self.isToggleOn = false
			toggleLayer:setOpacity(0)
			displayNode:stopAllActions()
			displayNode:runAction(CCMoveTo:create(0.2, ccp(800, 0)))
		else
			self.isToggleOn = true
			toggleLayer:setOpacity(80)
			displayNode:stopAllActions()
			displayNode:runAction(CCMoveTo:create(0.2, ccp(0, 0)))
		end
	end)
end

function TrunkScrollView:updateScrollData(min, max, current)
	self:setRange(min, max)
	self:setCurrent(current or self.current)
end

function TrunkScrollView:updateAnchorPos()
	local percent = 0
	if self.max > self.min and self.current > self.min then
		percent = (self.current - self.min) / (self.max - self.min)
		if percent > 1 then percent = 1 end
	end
	self.currentPosIcon:setPositionY(self.viewHeight*percent-2)
	self.currentPosLabel:setString(tostring(self.current))
end

function TrunkScrollView:updateView()
	self:updateAnchorPos()
end

---------------------TrunkScrollInteractionController---------------------------
TrunkScrollInteractionController = class(EventDispatcher)

function TrunkScrollInteractionController:create(worldScene, min, max, current)
	local ctr = TrunkScrollInteractionController.new()
	ctr:init()
	ctr:addController(worldScene, ccp(720 - 80, 300))
	ctr:addEventListener(TrunkScrollEvents.kScrollTo, function(event)
		worldScene:moveNodeToCenter(event.data, function() end)
	end)
	return ctr
end

function TrunkScrollInteractionController:init(min, max, current)
	min = min or 1
	max = max or NewAreaOpenMgr.getInstance():getCanPlayTopLevel()
	current = current or max
	self.scrollView = TrunkScrollView:create(min, max, current)
	self:register()
end

function TrunkScrollInteractionController:updateScrollData(min, max, current)
	self.scrollView:updateScrollData(min, max, current)
end

function TrunkScrollInteractionController:register()
	local function onTouchBegin(event)
		self:onTouchBegin(event)
	end
	local function onTouchMove(event)
		self:onTouchMove(event)
	end
	local function onTouchEnd(event)
		self:onTouchEnd(event)
	end
	self.scrollView.touchLayer:addEventListener(DisplayEvents.kTouchBegin, onTouchBegin, self)
	self.scrollView.touchLayer:addEventListener(DisplayEvents.kTouchMove, onTouchMove, self)
	self.scrollView.touchLayer:addEventListener(DisplayEvents.kTouchEnd, onTouchEnd, self)
end

function TrunkScrollInteractionController:getScrollView()
	return self.scrollView
end

function TrunkScrollInteractionController:onScrollTo(index)
	self:dispatchEvent(Event.new(TrunkScrollEvents.kScrollTo, index))
end

function TrunkScrollInteractionController:moveType()

end

function TrunkScrollInteractionController:onTouchMove(event, ...)
	if not self.scrollStarted then return end
	local sp = self.scrollView:convertToNodeSpace(event.globalPosition)
	local deltaY = event.globalPosition.y - self.lastPosY
	-- if math.abs(deltaY) > 10 then
		self.scrollView:setCurrentByPos(sp)
	-- else
	-- 	if deltaY > 0 then
	-- 		self.scrollView:setCurrent(self.scrollView.current + 1 )
	-- 	elseif deltaY < 0 then
	-- 		self.scrollView:setCurrent(self.scrollView.current - 1 )
	-- 	end
	-- ends
	self.lastPosY = event.globalPosition.y

	if self.scheduleId then
		cancelTimeOut(self.scheduleId)
		self.scheduleId = nil
	end
	self.scheduleId = setTimeOut(function()
		self:onScrollTo(self.scrollView.current)
		self.scrollStarted = false
	end, 0.3)
	if _G.isLocalDevelopMode then printx(0, "====onTouchMove===", sp.y, self.scrollView.current) end
	-- self:onScrollTo(self.scrollView.current)
end

function TrunkScrollInteractionController:onTouchBegin(event, ...)
	local sp = self.scrollView:convertToNodeSpace(event.globalPosition)
	self.scrollView:setCurrentByPos(sp)
	
	self.scrollStarted = true
	self.lastPosY = event.globalPosition.y
	if _G.isLocalDevelopMode then printx(0, "====onTouchBegin===") end
end

function TrunkScrollInteractionController:onTouchEnd(event, ...)
	if not self.scrollStarted then return end

	if self.scheduleId then
		cancelTimeOut(self.scheduleId)
		self.scheduleId = nil
	end
	self.scrollStarted = false
	local sp = self.scrollView:convertToNodeSpace(event.globalPosition)
	self.scrollView:setCurrentByPos(sp)
	self:onScrollTo(self.scrollView.current)
	if _G.isLocalDevelopMode then printx(0, "====onTouchEnd===", sp.y, self.scrollView.current) end
end

function TrunkScrollInteractionController:addController(parent, pos, index)
	if type(index) == "number" then
		parent:addChildAt(self.scrollView, index)
	else
		parent:addChild(self.scrollView)
	end
	if pos then self.scrollView:setPosition(pos) end
end