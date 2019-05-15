
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年08月27日 12:33:57
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

require "hecore.display.CocosObject"
require "zoo.ResourceManager"
require "zoo.scenes.component.HomeScene.NewLockedCloud"
require "zoo.scenes.component.HomeScene.hiddenBranch.HiddenBranch"
require "zoo.scenes.component.HomeScene.hiddenBranch.HiddenBranchBox"
require "zoo.scenes.component.HomeScene.hiddenBranch.ExploreCloud"
require "zoo.scenes.component.HomeScene.WorldMapOptimizer"
require "zoo.UIConfigManager"
require "zoo.panel.StartGamePanel"
require "zoo.common.CallbackChain"

local REGION_CLOUD_CHECK_OFFSET = 200

local function sinFunction(Y, deltaX, ...)
	assert(type(Y) == "number")
	assert(type(deltaX) == "number")
	assert(#{...} == 0)

	local A = 150
	local B = 800

	if Y > A then Y = A end

	local X = 2 * B / math.pi * math.asin( Y / A)

	X = X + deltaX

	if X > B then X = B end

	local newY = A * math.sin(math.pi / ( 2 * B) * X)

	if tostring(newY) == "nan" then
		debug.debug()
	end

	return newY
end

---------------------------------------------------
-------------- ScrollDirection
---------------------------------------------------

ScrollDirection = {kNone = 0, kVertical = 1, kHorizontal = 2}


---------------------------------------------------
-------------- VelocityMeasurer
---------------------------------------------------

assert(not VelocityMeasurer)
VelocityMeasurer = class()

function VelocityMeasurer:init(measureInterval, getCurPosCallback, ...)
	assert(type(measureInterval) == "number")
	assert(type(getCurPosCallback) == "function")
	
	assert(#{...} == 0)

	self.prePosX = false
	self.prePosY = false
	self.curPosX = false
	self.curPosY = false

	self.curSpeedY = 0
	self.lastSpeedY = 0
	self.curSpeedX = 0
	self.lastSpeedX = 0

	self.measureInterval	= measureInterval
	self.getCurPosCallback	= getCurPosCallback

	self.measuredVelocityX = false
	self.measuredvelocityY = false

	self.scheduledFunc = false

	self.preSpeed = 0
	self.curSpeed = 0
end

function VelocityMeasurer:setInitialPos(x, y, ...)
	assert(type(x) == "number")
	assert(type(y) == "number")
	assert(#{...} == 0)

	self.prePosX = x
	self.prePosY = y
	self.curPosX = x
	self.curPosY = y

	self.preSpeed = 0
	self.curSpeed = 0
	
	self.measuredVelocityX = false
	self.measuredvelocityY = false
end

function VelocityMeasurer:startMeasure(...)
	assert(#{...} == 0)

	local assertFalseMsg = "Call setInitialPos First !"
	assert(self.prePosX, assertFalseMsg)
	assert(self.prePosY, assertFalseMsg)
	assert(self.curPosX, assertFalseMsg)
	assert(self.curPosY, assertFalseMsg)

	local scheduler = CCDirector:sharedDirector():getScheduler()

	local function scheduledFunc()

		local curPos = self.getCurPosCallback()
		assert(curPos.x)
		assert(curPos.y)

		self.prePosX = self.curPosX
		self.prePosY = self.curPosY
		self.curPosX = curPos.x
		self.curPosY = curPos.y

		self.measuredVelocityX = (self.curPosX - self.prePosX) / self.measureInterval
		self.measuredVelocityY = (self.curPosY - self.prePosY) / self.measureInterval
		self.lastSpeedY = self.curSpeedY
		self.curSpeedY = self.measuredVelocityY
	end
	
	scheduledFunc()
	if not self.scheduledFunc then
		self.scheduledFunc = scheduler:scheduleScriptFunc(scheduledFunc, self.measureInterval, false)
	end
end

function VelocityMeasurer:stopMeasure(...)
	assert(#{...} == 0)

	--assert(self.scheduledFunc)
	if self.scheduledFunc then
		local scheduler = CCDirector:sharedDirector():getScheduler()
		scheduler:unscheduleScriptEntry(self.scheduledFunc)
		self.scheduledFunc = false
	end
end

function VelocityMeasurer:getMeasuredVelocityX(...)
	assert(#{...} == 0)

	return self.measuredVelocityX
end

function VelocityMeasurer:getMeasuredVelocityY(...)
	assert(#{...} == 0)

	return self.measuredVelocityY
end

function VelocityMeasurer:create(measureInterval, getCurPosCallback, ...)
	assert(type(measureInterval) == "number")
	assert(type(getCurPosCallback) == "function")
	assert(#{...} == 0)

	local newVelocityMeasurer = VelocityMeasurer.new()
	newVelocityMeasurer:init(measureInterval, getCurPosCallback)
	return newVelocityMeasurer
end

function VelocityMeasurer:getSpeedY()
	return (self.lastSpeedY + self.curSpeedY) / 2
end

function VelocityMeasurer:getSpeedX()
	return (self.lastSpeedX + self.curSpeedX) / 2
end

function VelocityMeasurer:setXY(x, y)

	self.prePosX = self.curPosX
	self.prePosY = self.curPosY
	self.curPosX = x
	self.curPosY = y

	self.measuredVelocityX = (self.curPosX - self.prePosX) / self.measureInterval
	self.measuredVelocityY = (self.curPosY - self.prePosY) / self.measureInterval

	self.lastSpeedY = self.curSpeedY
	self.lastSpeedX = self.curSpeedX
	self.curSpeedY = self.measuredVelocityY
	self.curSpeedX = self.measuredVelocityX
end

VelocityMeasurerWorldScene = class(VelocityMeasurer)

function VelocityMeasurerWorldScene:create(measureInterval, getCurPosCallback, ...)
	assert(type(measureInterval) == "number")
	assert(type(getCurPosCallback) == "function")
	assert(#{...} == 0)

	local newVelocityMeasurer = VelocityMeasurerWorldScene.new()
	newVelocityMeasurer:init(measureInterval, getCurPosCallback)
	return newVelocityMeasurer
end

function VelocityMeasurerWorldScene:startMeasure(...)
	assert(#{...} == 0)

	local assertFalseMsg = "Call setInitialPos First !"
	assert(self.prePosX, assertFalseMsg)
	assert(self.prePosY, assertFalseMsg)
	assert(self.curPosX, assertFalseMsg)
	assert(self.curPosY, assertFalseMsg)

	local scheduler = CCDirector:sharedDirector():getScheduler()

	local function scheduledFunc()

		local curPos = self.getCurPosCallback()
		assert(curPos.x)
		assert(curPos.y)

		self.prePosX = self.curPosX
		self.prePosY = self.curPosY
		self.curPosX = curPos.x
		self.curPosY = curPos.y

		if __IOS then 
			--渣机防抖
			if math.abs(self.curPosY - self.prePosY) < 60 then return end
		end

		self.measuredVelocityX = (self.curPosX - self.prePosX) / self.measureInterval
		self.measuredVelocityY = (self.curPosY - self.prePosY) / self.measureInterval

		if __IOS then 
			--渣机限速
			if self.measuredVelocityY > 12500 then 
				self.measuredVelocityY = 12500
			elseif self.measuredVelocityY < -12500 then 
				self.measuredVelocityY = -12500
			end
		end

		self.lastSpeedY = self.curSpeedY
		self.curSpeedY = self.measuredVelocityY
	end
	
	scheduledFunc()
	if not self.scheduledFunc then
		self.scheduledFunc = scheduler:scheduleScriptFunc(scheduledFunc, self.measureInterval, false)
	end
end

function VelocityMeasurerWorldScene:stopMeasure(...)
	local function scheduledFunc()

		local curPos = self.getCurPosCallback()
		assert(curPos.x)
		assert(curPos.y)

		self.prePosX = self.curPosX
		self.prePosY = self.curPosY
		self.curPosX = curPos.x
		self.curPosY = curPos.y

		self.measuredVelocityX = (self.curPosX - self.prePosX) / self.measureInterval
		self.measuredVelocityY = (self.curPosY - self.prePosY) / self.measureInterval

		self.lastSpeedY = self.curSpeedY
		self.curSpeedY = self.measuredVelocityY
	end

	-- IOS上面防止滑动过度灵敏
	-- if not __IOS then
		scheduledFunc()
	-- end

	if self.scheduledFunc then
		local scheduler = CCDirector:sharedDirector():getScheduler()
		scheduler:unscheduleScriptEntry(self.scheduledFunc)
		self.scheduledFunc = false
	end
end

---------------------------------------------------
-------------- WorldSceneScroller
---------------------------------------------------
--
assert(not WorldSceneScrollerEvents)
WorldSceneScrollerEvents = 
{
	MOVE_TO_PERCENTAGE	= "WorldSceneScrollerEvents.MOVE_TO_PERCENTAGE",

	--
	MOVING_STARTED		= "WorldSceneScrollerEvents.MOVING_STARTED",
	MOVING_STOPPED		= "WorldSceneScrollerEvents.MOVING_STOPPED",

	BRANCH_MOVING_STARTED		= "WorldSceneScrollerEvents.BRANCH_MOVING_STARTED",
	BRANCH_MOVING_STOPPED		= "WorldSceneScrollerEvents.BRANCH_MOVING_STOPPED",

	--
	SCROLLED_TO_RIGHT	= "WorldSceneScrollerEvents.SCROLLED_TO_RIGHT",
	SCROLLED_TO_LEFT	= "WorldSceneScrollerEvents.SCROLLED_TO_LEFT",
	SCROLLED_TO_ORIGIN	= "WorldSceneScrollerEvents.SCROLLED_TO_ORIGIN",
	SCROLLED_FOR_TUTOR  = "WorldSceneScrollerEvents.SCROLLED_FOR_TUTOR",

	START_SCROLLED_TO_RIGHT	= "WorldSceneScrollerEvents.START_SCROLLED_TO_RIGHT",
	START_SCROLLED_TO_LEFT	= "WorldSceneScrollerEvents.START_SCROLLED_TO_LEFT",
	START_SCROLLED_TO_ORIGIN	= "WorldSceneScrollerEvents.START_SCROLLED_TO_ORIGIN",

	GAME_INIT_ANIME_FIN	= "WorldSceneScrollerEvents.GAME_INIT_ANIME_FIN",
	HIT_REGION_CLOUD	= 'WorldSceneScrollerEvents.HIT_REGION_CLOUD',
}

assert(not CheckSceneOutRangeConstant)
CheckSceneOutRangeConstant = 
{
	IN_RANGE			= 1,
	TOP_OUT_OF_RANGE	= 2,
	BOTTOM_OUT_OF_RANGE	= 3,
	HIT_REGION_CLOUD   	= 4,
}


WorldSceneScrollerActionTag = {
	AUTO_ROLL_ACTION		= 1,
	DELAY_STOP_SCROLL_ACTION	= 2
}

WorldSceneScrollerHorizontalState = {
	
	SCROLLING_TO_RIGHT	= 1,
	STAY_IN_RIGHT		= 2,
	SCROLLING_TO_LEFT	= 3,
	STAY_IN_LEFT		= 4,
	SCROLLING_TO_ORIGIN	= 5,
	STAY_IN_ORIGIN		= 6
}

WorldSceneScrollerTouchState = {
	SOME_THING_ABOVE_SCROLLER_TOUCHED = 1, -- flower, cloud, friendStack
	VERTICAL_SCROLLER_TOUCHED = 2, -- on touch scroll vertical
	HORIZONTAL_SCROLLER_TOUCHED = 3, -- on touch branch scroll horizontal
}

assert(not WorldSceneScroller)
WorldSceneScroller = class(Layer)

function WorldSceneScroller:init(...)
	assert(#{...} == 0)

	-- Init Base
	Layer.initLayer(self)

	---------------------------
	---- Data Control Scroll Horizontal
	---------------------------------
	self.scrollHorizontalState = WorldSceneScrollerHorizontalState.STAY_IN_ORIGIN

	----------------------------
	------- Other Data
	--------------------------
	self.scrollable	= true
	local animInterval = CCDirector:sharedDirector():getAnimationInterval()

	-- -------------
	-- Scroll Effect
	-- ----------------
	self.movingStartedFlag = false
	
	local config 				= UIConfigManager:sharedInstance():getConfig()
	self.autoScrollTimerInterval		= config.worldSceneScroller_autoScrollTimerInterval

	-- Slow Down Based On Ratio
	self.velocitySlowdownRatio		= config.worldSceneScroller_velocitySlowdownRatio
	self.velocityThreshold			= config.worldSceneScroller_velocityThreshold

	-- self.screenHeight = Director:sharedDirector():getVisibleSize().width /720 * 1280
	-- if _G.isLocalDevelopMode then printx(0, self.screenHeight) end debug.debug()

	assert(self.autoScrollTimerInterval)
	assert(self.velocitySlowdownRatio)
	assert(self.velocityThreshold)

	----------------------------
	---- Measure Finger Speed
	--------------------------
	
	-- Data Control Measure Finger Speed
	self.fingerPreviousPositionY 	= false
	self.fingerPositionY		= false

	local function getCurFingerPos()
		return ccp(0, self.fingerPositionY)
	end

	self.velocityMeasurerArray = {}
	local measurer = VelocityMeasurerWorldScene:create(animInterval * 1, getCurFingerPos)
	table.insert(self.velocityMeasurerArray, measurer)

	local measurer = VelocityMeasurerWorldScene:create(animInterval * 2, getCurFingerPos)
	table.insert(self.velocityMeasurerArray, measurer)

	local measurer = VelocityMeasurerWorldScene:create(animInterval * 4, getCurFingerPos)
	table.insert(self.velocityMeasurerArray, measurer)

	local config = UIConfigManager:sharedInstance():getConfig()
	self.fingerVelocityRatio = config.worldSceneScroller_fingerVelocityRatio
	assert(self.fingerVelocityRatio)


	-- -------------------
	-- Scrollable Range
	-- ------------------
	self.topScrollRangeY	= 100
	self.belowScrollRangeY	= 150
	self.horizontalScrollMaxTime = 0.4

	-------------------
	-- Event Listener
	-- -----------------
	-- Scroll Horizontal Event Listener

    local function showRewardTipPanel( ... )
        local branch = self.hiddenBranchArray[self.currentStayBranchIndex]

        if branch and branch.branchBox then
		    branch.branchBox:showRewardTipPanel(true)
        end
	end

	local function onScrolledToLeftOrRight(event)
		self:onScrolledToLeftOrRight(event)

       showRewardTipPanel()
	end
	self:addEventListener(WorldSceneScrollerEvents.SCROLLED_TO_LEFT, onScrolledToLeftOrRight)
	self:addEventListener(WorldSceneScrollerEvents.SCROLLED_TO_RIGHT, onScrolledToLeftOrRight)

	local function onScrolledToOrigin(event)
		self:onScrolledToOrigin(event)
	end
	self:addEventListener(WorldSceneScrollerEvents.SCROLLED_TO_ORIGIN, onScrolledToOrigin)
end

function WorldSceneScroller:stopAllScheduler()
	self:stopAutoRollTimer()
	for k,measurer in ipairs(self.velocityMeasurerArray) do
		measurer:stopMeasure()
	end
end
------------------------------------
-------- Event Listener
------------------------------------

local function onScrollerTouchMove(event, ...)
	assert(event)
	assert(event.name == DisplayEvents.kTouchMove)
	assert(event.context)
	assert(#{...} == 0)


	local self = event.context
	--if _G.isLocalDevelopMode then printx(0, self._isStoppedForAnimation) end
	if self:isStoppedForAnimation() then
		return
	end

	self.ignoreHitCloudCheck = false

	local visibleOrigin = CCDirector:sharedDirector():ori_getVisibleOrigin()

	--if self.clickOffset then
	if self.clicked then

		---------------------------
		-- Stop "Delay To Stop Auto Scroll Action"
		-- -----------------------------------------
		self:stopDelayStopAutoScroll()
		------------------------
		-- Manually Stop Auto Scroll Action
		-- ---------------------------------
		if self:isAutoRollTimerRunning() then
			if __WP8 then self.stopRollByTouchMove = true end
			self:stopAutoRollTimer()
		end

		-- First Move 
		if not self.movingStartedFlag then
			self.movingStartedFlag = true
			self:dispatchEvent(Event.new(WorldSceneScrollerEvents.MOVING_STARTED))
			local maskedLayerY	= self.maskedLayer:getPositionY()
			self.clickOffset	= event.globalPosition.y - maskedLayerY
		end

		self.fingerPreviousPositionY	= self.fingerPositionY
		self.fingerPositionY 		= event.globalPosition.y
		local newPositionY		= false

		-- -----------------------------
		-- Check Current Scene Position
		-- Whether Out Of Range
		-- -------------------------------------------------------
		self.isScrollingUp = (self.fingerPositionY < self.fingerPreviousPositionY)
		-- if _G.isLocalDevelopMode then printx(0, self.isScrollingUp) end
		local scenePositionState	= self:checkSceneOutRange()
		-- if _G.isLocalDevelopMode then printx(0, scenePositionState) end

		if CheckSceneOutRangeConstant.IN_RANGE == scenePositionState then

			newPositionY	= event.globalPosition.y - self.clickOffset

		elseif CheckSceneOutRangeConstant.TOP_OUT_OF_RANGE == scenePositionState then 

			-- he_log_warning("self.maskedLayer is defined in child class !! Separate is not complete !")
			local positionY = self.maskedLayer:getPositionY()

			local maskedLayerPositionY	= self.maskedLayer:getPositionY()
			local virtualPositionY		= maskedLayerPositionY + self.belowScrollRangeY - visibleOrigin.y
			local deltaX	= self.fingerPositionY - self.fingerPreviousPositionY

			local newVirtualPositionY = sinFunction(virtualPositionY, deltaX)

			newPositionY	= newVirtualPositionY - self.belowScrollRangeY + visibleOrigin.y

		elseif CheckSceneOutRangeConstant.BOTTOM_OUT_OF_RANGE == scenePositionState then

			-- local visibleOrigin = CCDirector:sharedDirector():getVisibleOrigin()

			local positionY = self.maskedLayer:getPositionY()
			local deltaBlackEdge	= visibleOrigin.y + self.visibleSize.height - (positionY + self.topScrollRangeY)
			local deltaX	= -(self.fingerPositionY - self.fingerPreviousPositionY)

			local newDeltaBlackEdge = sinFunction(deltaBlackEdge, deltaX)

			newPositionY = visibleOrigin.y + self.visibleSize.height - newDeltaBlackEdge - self.topScrollRangeY
			-- if _G.isLocalDevelopMode then printx(0, self.topScrollRangeY) end
		elseif CheckSceneOutRangeConstant.HIT_REGION_CLOUD == scenePositionState then

			if not self.openRegionCloudStartFingerPos then
				self.openRegionCloudStartFingerPos = self.fingerPositionY
			end

			-- 拖拽阈值
			if self.openRegionCloudStartFingerPos - self.fingerPositionY > 250 then
				self:playRegionCloudAnimation()
				return
			end

			local positionY = self.maskedLayer:getPositionY()
			local deltaBlackEdge	= -(positionY + self:getRegionCloudCheckPosition(self.regionCloudY) - visibleOrigin.y)
			local deltaX	= -(self.fingerPositionY - self.fingerPreviousPositionY)
			local newDeltaBlackEdge = sinFunction(deltaBlackEdge, deltaX)
			newPositionY = -newDeltaBlackEdge - self:getRegionCloudCheckPosition(self.regionCloudY) + visibleOrigin.y
		else 
			assert(false)
		end

		self.maskedLayer:setPositionY(newPositionY)

		-- Treated As A ScrollBar
		-- Calculate The Percentage
		self:dispatchMoveToPercentageEvent()
	else
		-- Do Nothing
	end
end

local function onScrollerTouchEnd(event, ...)

	assert(event)
	assert(event.name == DisplayEvents.kTouchEnd)
	assert(event.context)
	assert(#{...} == 0)

	local self = event.context
	if self:isStoppedForAnimation() then
		return 
	end

	self.clickOffset = nil
	self.clicked	= false

	self.openRegionCloudStartFingerPos = nil

	---------------------------
	-- Stop "Delay To Stop Auto Scroll Action"
	-- -----------------------------------------
	self:stopActionByTag(WorldSceneScrollerActionTag.DELAY_STOP_SCROLL_ACTION)
	-- First Move 
	if not self.movingStartedFlag then
		self.movingStartedFlag = true
		self:dispatchEvent(Event.new(WorldSceneScrollerEvents.MOVING_STARTED))
	end

	self.fingerPositionY 		= event.globalPosition.y
	-- ---------------------
	-- Stop Calculate Speed
	-- -------------------
	for k,measurer in ipairs(self.velocityMeasurerArray) do
		measurer:stopMeasure()
	end

	self.velocity = false

	for k,measurer in ipairs(self.velocityMeasurerArray) do

		local velocity = measurer:getMeasuredVelocityY()
		if velocity and velocity ~= 0 then
			if not self.velocity then
				self.velocity = velocity
			elseif math.abs(velocity) > math.abs(self.velocity) then 
				self.velocity = velocity
			end
		end
	end

	if not self.velocity then 
		self.velocity = 0
	end

	self.velocity = self.velocity * self.fingerVelocityRatio

	-- if __WIN32 then
	-- 	self.velocity = 0
	-- end

	self.isScrollingUp = (self.velocity < 0)
	-- if _G.isLocalDevelopMode then printx(0, self.isScrollingUp) end


	-- --------------------
	-- Remove Event Listener
	-- --------------------
	self:removeEventListener(DisplayEvents.kTouchMove, onScrollerTouchMove)
	self:removeEventListener(DisplayEvents.kTouchEnd, onScrollerTouchEnd)

	-- ---------------
	-- Start Auto Roll
	-- -----------------
	if not self.autoRollTimerId then
		self:startAutoRollTimer()
	end
	WorldMapOptimizer:getInstance():update()
end

-----------------------------------------------
----- Function About "Delay Stop Auto Scroll"
-----------------------------------------------

function WorldSceneScroller:startDelayStopAutoScroll(...)
	assert(#{...} == 0)

	-- -------------------------------
	-- Delay To Stop Previous Possile Auto Roll
	-- ----------------------------
	local animInterval = CCDirector:sharedDirector():getAnimationInterval()

	-- Delay
	local delay = CCDelayTime:create(animInterval * 3)

	-- Call Stop
	local function delayStopAutoScroll()

		if self:isAutoRollTimerRunning() then
			self:stopAutoRollTimer()
		end
	end
	local stopAutoScrollAction = CCCallFunc:create(delayStopAutoScroll)

	-- Seq
	local seq = CCSequence:createWithTwoActions(delay, stopAutoScrollAction)
	seq:setTag(WorldSceneScrollerActionTag.DELAY_STOP_SCROLL_ACTION)
	self:runAction(seq)
end

function WorldSceneScroller:stopDelayStopAutoScroll(...)
	assert(#{...} == 0)

	---------------------------
	-- Stop "Delay To Stop Auto Scroll Action"
	-- -----------------------------------------
	self:stopActionByTag(WorldSceneScrollerActionTag.DELAY_STOP_SCROLL_ACTION)
end
----------------------------------------------------

function WorldSceneScroller:onScrollerTouchBegin(event, ...)

	assert(event)
	assert(event.name == DisplayEvents.kTouchBegin)
	assert(#{...} == 0)

	--if _G.isLocalDevelopMode then printx(0, 'onScrollerTouchBegin	',self._isStoppedForAnimation) end
	self:startDelayStopAutoScroll()

	-- Check If Scrollable
	if self.scrollable == false then
		--if _G.isLocalDevelopMode then printx(0, '111111111111111') end
		return 
	end
	
	if self:isStoppedForAnimation() then
		--if _G.isLocalDevelopMode then printx(0, '2222222222222') end
		return
	end

	self.ignoreHitCloudCheck = true

	self.clicked	= true

	-- Init Variable For
	-- Recording Finger Position When Touch,Move
	self.fingerPreviousPositionY	= event.globalPosition.y
	self.fingerPositionY		= event.globalPosition.y

	-- Add Event Listener
	self:addEventListener(DisplayEvents.kTouchMove, onScrollerTouchMove, self)
	self:addEventListener(DisplayEvents.kTouchEnd, onScrollerTouchEnd, self)

	---- ------------------------------
	---- Calculate Velocity
	---- ------------------------------
	for k,measurer in ipairs(self.velocityMeasurerArray) do
		measurer:setInitialPos(0, self.fingerPositionY)
		measurer:startMeasure()
	end

	self:updateAllRegionCloudState()
	self.regionCloudY, self.regionCloudIndex = self:getNearestRegionCloudPosAndId(math.abs(self.maskedLayer:getPositionY()))
	self:setRegionCloudPosition()
	-- if _G.isLocalDevelopMode then printx(0, 'self.regionCloudY', self.regionCloudY) end
end

function WorldSceneScroller:getMaxMaskedLayerY(...)
	assert(#{...} == 0)

	local visibleOrigin = CCDirector:sharedDirector():getVisibleOrigin()
	return visibleOrigin.y - self.belowScrollRangeY
end

function WorldSceneScroller:getMinMaskedLayerY(...)
	assert(#{...} == 0)

	local visibleOrigin = CCDirector:sharedDirector():getVisibleOrigin()
	return -(self.topScrollRangeY - self.visibleSize.height - visibleOrigin.y)
end

function WorldSceneScroller:checkSceneOutRange(testMaskedLayerY, ...)
	assert(#{...} == 0)

	local visibleOrigin = CCDirector:sharedDirector():getVisibleOrigin()

	local maskedLayerY = false

	if testMaskedLayerY then
		maskedLayerY	= testMaskedLayerY
	else
		maskedLayerY	= self.maskedLayer:getPositionY()
	end


	if self:checkHitRegionCloud(maskedLayerY) then
		return CheckSceneOutRangeConstant.HIT_REGION_CLOUD
	end
	if maskedLayerY < visibleOrigin.y - self.belowScrollRangeY and maskedLayerY > visibleOrigin.y -(self.topScrollRangeY - self.visibleSize.height) then
		return CheckSceneOutRangeConstant.IN_RANGE
	end

	if maskedLayerY > visibleOrigin.y -self.belowScrollRangeY then
		return CheckSceneOutRangeConstant.TOP_OUT_OF_RANGE

	elseif maskedLayerY < visibleOrigin.y -(self.topScrollRangeY - self.visibleSize.height) then

		return CheckSceneOutRangeConstant.BOTTOM_OUT_OF_RANGE
	end

	return CheckSceneOutRangeConstant.IN_RANGE
end

function WorldSceneScroller:setCurrentRegionCloud(index)
	self.regionCloudIndex = index
end

function WorldSceneScroller:getRegionCloudCheckPosition(positionY)
	-- if _G.isLocalDevelopMode then printx(0, 'self.screenHeight', self.screenHeight) end
	return positionY - self.visibleSize.height + REGION_CLOUD_CHECK_OFFSET
end

function WorldSceneScroller:playRegionCloudAnimation()
	self:stopForAnimation()
	if self.movingStartedFlag then
		self.movingStartedFlag	= false
		self:dispatchEvent(Event.new(WorldSceneScrollerEvents.MOVING_STOPPED))
		self:onVerticalScrollStop()
	end
	local function callback()
		self:dispatchEvent(Event.new(WorldSceneScrollerEvents.HIT_REGION_CLOUD, {y = self.regionCloudY, index = self.regionCloudIndex}))
	end
	local action = CCSequence:createWithTwoActions(
			CCSequence:createWithTwoActions(CCMoveBy:create(0.2, ccp(0, -200)), CCMoveBy:create(0.2, ccp(0, 200))),
			CCCallFunc:create(callback)
		)
	self.maskedLayer:runAction(action)
end

function WorldSceneScroller:stopForAnimation()
	self._isStoppedForAnimation = true
end

function WorldSceneScroller:isStoppedForAnimation()
	return self._isStoppedForAnimation
end

function WorldSceneScroller:resumeFromAnimation()
	self._isStoppedForAnimation = false
end

function WorldSceneScroller:getRegionCloudUiOffset()
	return -200
end

function WorldSceneScroller:setRegionCloudPosition()
	if self.regionCloudIndex == -1 then
		self.regionCloud:setVisible(false)
		return
	else
		self.regionCloud:setVisible(true)
	end

	local pos = (self.regionCloudY or 0) + self:getRegionCloudUiOffset()

	self.regionCloud:setPositionY(pos)
	self.regionCloud:setPositionX(300)
	self.regionCloud:setVisible(true)
end

function WorldSceneScroller:getRegionCloudYByIndex(index)
	local cloudPos = self.regionCloudYValues[index]
	if not cloudPos then
		return 0
	end
	return cloudPos.y
end

function WorldSceneScroller:updateAllRegionCloudState()
	local vs = Director:sharedDirector():getVisibleSize()
	local topLevelId = tonumber(UserManager:getInstance().user.topLevelId)
	local firstCloudId = math.ceil(topLevelId / 120)
	local maskedLayerY = self.maskedLayer:getPositionY()
	for k, v in pairs(self.regionCloudYValues) do
		if k >= firstCloudId then
			local pos = -v.y
			-- if maskedLayerY < pos - 800 then
			-- 	v.played = false
			-- end
			-- if _G.isLocalDevelopMode then printx(0, k, maskedLayerY, vs.height, pos) end
			-- if _G.isLocalDevelopMode then printx(0, k, pos, maskedLayerY - (vs.height)) end
			if maskedLayerY - (vs.height + 800) > pos then
				-- if _G.isLocalDevelopMode then printx(0, v) end
				v.played = false
			end
		else
			v.played = true
		end
	end
end


-- 藤蔓自动滑动的时候，更新所有云的played字段
-- 自动滑动必须要更新云的状态，否则会数据错误
function WorldSceneScroller:onMaskedLayerAutoScrollTo(maskedLayerY)
	local topLevelId = tonumber(UserManager:getInstance().user.topLevelId)
	local firstCloudId = math.ceil(topLevelId / 120)
	local vs = Director:sharedDirector():getVisibleSize()
	local scrollToCloudId = nil
	for i = 1, #self.regionCloudYValues do
		local v = self.regionCloudYValues[i]
		local pos = -v.y
		-- if _G.isLocalDevelopMode then printx(0, i, pos, maskedLayerY - (vs.height + 800)) end
		if maskedLayerY - (vs.height + 800) > pos then
			-- if _G.isLocalDevelopMode then printx(0, v) end
			-- v.played = false
			scrollToCloudId = i
			break
		end
	end
	-- if _G.isLocalDevelopMode then printx(0, 'xxxxxxxxxxxxxxx scrollToCloudId xxxxxxxxxxxxxxx') end
	-- if _G.isLocalDevelopMode then printx(0, scrollToCloudId) end
	-- 如果滑到最顶端，所有云都标记为已打开
	if scrollToCloudId == nil then
		-- if _G.isLocalDevelopMode then printx(0, 'xxxxxxxxxx return xxxxxxxxxxxxxxx') end
		for k, v in pairs(self.regionCloudYValues) do
			v.played = true
		end
		return
	end
	-- 如果滑到第一朵云下方，应该以第一朵云为准
	-- 如果滑到上方，应该以实际滑到的云为准
	local destCloudId = scrollToCloudId
	if scrollToCloudId >= firstCloudId then
		destCloudId = scrollToCloudId
	else 
		destCloudId = firstCloudId
	end
	for i=1, destCloudId - 1 do
		if self.regionCloudYValues[i] then
			self.regionCloudYValues[i].played = true
		end
	end
	for i=destCloudId, #self.regionCloudYValues do
		if self.regionCloudYValues[i] then
			self.regionCloudYValues[i].played = false
		end
	end
	-- if _G.isLocalDevelopMode then printx(0, 'xxxxxxxxxxxxxxxx regionCloudYValues xxxxxxxxxxxxxxxxxxx') end
	-- if _G.isLocalDevelopMode then printx(0, destCloudId) end
	-- for k, v in pairs(self.regionCloudYValues) do
	-- 	if _G.isLocalDevelopMode then printx(0, k, v.played) end
	-- end
	-- self:updateAllRegionCloudState()
end

function WorldSceneScroller:checkHitRegionCloud(newMaskedLayerY)
	-- if __WIN32 then return false end
	--if _G.isLocalDevelopMode then printx(0, 'self.regionCloudIndex', self.regionCloudIndex) end
	if self.ignoreHitCloudCheck == true then
		-- if _G.isLocalDevelopMode then printx(0, 'checkHitRegionCloud AUTO Scroll') end
		-- if _G.isLocalDevelopMode then printx(0, debug.traceback()) end
		return false
	end
	if self.regionCloudIndex == -1 then
		return false
	end
	local userTopLevel = UserManager:getInstance().user:getTopLevelId()
	if userTopLevel > self.regionCloudIndex * 120 - 30 then
		return false
	end
	local vs = Director:sharedDirector():getVisibleOrigin()
	local maskedLayerY = math.abs(self.maskedLayer:getPositionY())
	if newMaskedLayerY then
		maskedLayerY = math.abs(newMaskedLayerY)
	end
	-- if _G.isLocalDevelopMode then printx(0, 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx') end
	-- if _G.isLocalDevelopMode then printx(0, self.regionCloudY, self.regionCloudIndex) end
	local deltaY = maskedLayerY - (self:getRegionCloudCheckPosition(self.regionCloudY or 0) - vs.y)
	if self.regionCloudY ~= 0 and deltaY >= 0
	and self.regionCloudYValues[self.regionCloudIndex or 1].played == false 
	then
		-- if _G.isLocalDevelopMode then printx(0, 'hit cloud') end
		return true
	end
	-- if _G.isLocalDevelopMode then printx(0, 'not hit') end
	return false
end

function WorldSceneScroller:getNearestRegionCloudPosAndId(maskedLayerY)
	maskedLayerY = maskedLayerY or 0
	local value = 0
	for i = 1, #self.regionCloudYValues do
		if maskedLayerY < self.regionCloudYValues[i].y 
		and self.regionCloudYValues[i].played == false 
		then
			return self.regionCloudYValues[i].y, i
		end
	end
	return -1, -1
end

---------------------------------------------------
-------  Auto Roll
--------------------------------------------------

function WorldSceneScroller:startAutoRollTimer(...)
	assert(#{...} == 0)
	local scheduler = CCDirector:sharedDirector():getScheduler()

	local function autoRollTimer()
		self:autoRollTimer()
	end
	-- Initially Call autoRollTimer Manually
	-- After self.autoScrollTimerInterval The Scheduler Then Call It
	assert(not self.autoRollTimerId)
	self.autoRollTimerId = scheduler:scheduleScriptFunc(autoRollTimer, self.autoScrollTimerInterval, false)
	autoRollTimer()
end

function WorldSceneScroller:setTopScrollRange(topScrollRangeY, topAdjustY, ...)
	assert(type(topScrollRangeY) == "number")
	assert(#{...} == 0)

	self.topScrollRangeY = topScrollRangeY
	self.topScrollRangeYAdjust = topAdjustY
end

function WorldSceneScroller:setQuickScrollRange(quickScrollRangeY, quickScrollRangeYAdjust)
	self.quickScrollRangeY = quickScrollRangeY
	self.quickScrollRangeYAdjust = quickScrollRangeYAdjust or 0
end

if __WP8 then -- wp8不能显示所有好友

function WorldSceneScroller:checkFriendVisible()
	if self.friendPictureLayer and self.maskedLayer then
		local maskedLayerPositionY = self.maskedLayer:getPositionY()
		local _childs = self.friendPictureLayer:getChildrenList()
		if _childs then
			if not self.visibleSize then
				self.visibleSize = CCDirector:sharedDirector():getVisibleSize()
			end
			if not self.visibleOrigin then
				self.visibleOrigin = CCDirector:sharedDirector():getVisibleOrigin()
			end
			for i, v in ipairs(_childs) do
				if v then
					local childPositionY = maskedLayerPositionY + v:getPositionY()
					local canShow = childPositionY > self.visibleOrigin.y and childPositionY < self.visibleOrigin.y + self.visibleSize.height
					if canShow and not v:isVisible() then
						v:setVisible(true)
					elseif not canShow and v:isVisible() then
						v:setVisible(false)
					end
				end
			end
		end
	end
end

end

function WorldSceneScroller:stopAutoRollTimer(...)
	assert(#{...} == 0)
	-- Stop
	local scheduler = CCDirector:sharedDirector():getScheduler()

	if self.autoRollTimerId then
		-- Stop All AUTO_ROLL_ACTION
		--if _G.isLocalDevelopMode then printx(0, 'xxxxxxxxxxxxxxxxxxxxxxx') end
		local autoRollAction = self.maskedLayer:getActionByTag(WorldSceneScrollerActionTag.AUTO_ROLL_ACTION)
		while autoRollAction ~= nil do
			self.maskedLayer:stopAction(autoRollAction)
			autoRollAction = self.maskedLayer:getActionByTag(WorldSceneScrollerActionTag.AUTO_ROLL_ACTION)
		end

		scheduler:unscheduleScriptEntry(self.autoRollTimerId)
		self.autoRollTimerId = nil

		if __WP8 and not self.stopRollByTouchMove then self:checkFriendVisible() end
	end

	-- Dispatch Event
	if self.movingStartedFlag then
		self.movingStartedFlag	= false
		self:dispatchEvent(Event.new(WorldSceneScrollerEvents.MOVING_STOPPED))
		self:onVerticalScrollStop()
	end
	--if _G.isLocalDevelopMode then printx(0, 'yyyyyyyyyyyyyyyyyyyyyyyyyy') end

	if __WP8 then self.stopRollByTouchMove = false end
end

function WorldSceneScroller:isAutoRollTimerRunning(...)
	assert(#{...} == 0)

	if self.autoRollTimerId then
		return true
	end

	return false
end

function WorldSceneScroller:autoRollTimer(...)
	assert(#{...} == 0)

	local scenePositionState = self:checkSceneOutRange()

	if CheckSceneOutRangeConstant.IN_RANGE == scenePositionState then

		if self.scrollable == false then
			self:stopAutoRollTimer()
			return
		end

		-- If Velocity == 0, Stop Auto Roll
		if self.velocity == 0 then
			self:stopAutoRollTimer()
			return
		end

		-- Slow Down self.velocity 
		-- Until To Zero
		--local deltaVelocity = self.velocitySlowdownAcceleration * self.autoScrollTimerInterval
		local nextVelocity = math.abs(self.velocity) * self.velocitySlowdownRatio

		if nextVelocity < self.velocityThreshold then
			nextVelocity = 0
		end

		if self.velocity < 0 then
			self.velocity = -nextVelocity
		else
			self.velocity = nextVelocity
		end

		local deltaY	= self.velocity * self.autoScrollTimerInterval

		local maskedLayerPosition	= self.maskedLayer:getPosition()
		local maskedLayerPositionX	= maskedLayerPosition.x
		local maskedLayerPositionY	= maskedLayerPosition.y

		local newPositionY = maskedLayerPositionY + deltaY

		------------------------------------------------------------------
		-- Below Ensure Not Exceed The Region, When Auto Scroll Is Too Fast
		-- -----------------------------------------------------------------

		local visibleOrigin = CCDirector:sharedDirector():ori_getVisibleOrigin()
		if newPositionY > visibleOrigin.y then
			newPositionY = visibleOrigin.y
		end


		-- Note this Constance From sinFunction !!, Reform Needed
		local sinFunctionA = 150

		if newPositionY < visibleOrigin.y - self.topScrollRangeY - sinFunctionA  then
			newPositionY = visibleOrigin.y - self.topScrollRangeY - sinFunctionA
		end

		local previousAction = self.maskedLayer:getActionByTag(WorldSceneScrollerActionTag.AUTO_ROLL_ACTION)
		if previousAction then
			self.maskedLayer:stopAction(previousAction)
		end

		self:dispatchMoveToPercentageEvent()

		-- Move To Action
		local moveToAction	= CCMoveTo:create(self.autoScrollTimerInterval, ccp(maskedLayerPositionX, newPositionY))

		-- Dispatch Event Action
		local function moveToCallback()
			self:dispatchMoveToPercentageEvent()
		end
		local callFunc		= CCCallFunc:create(moveToCallback)

		local sequenceAction	= CCSequence:createWithTwoActions(callFunc, moveToAction)

		sequenceAction:setTag(WorldSceneScrollerActionTag.AUTO_ROLL_ACTION)
		self.maskedLayer:runAction(sequenceAction)
		WorldMapOptimizer:getInstance():update()

	elseif CheckSceneOutRangeConstant.HIT_REGION_CLOUD == scenePositionState then
		self:stopAutoRollTimer()
		self:outRangeRestore()
		WorldMapOptimizer:getInstance():update()
		-- self:playRegionCloudAnimation()

	elseif CheckSceneOutRangeConstant.TOP_OUT_OF_RANGE == scenePositionState or
		CheckSceneOutRangeConstant.BOTTOM_OUT_OF_RANGE == scenePositionState then
		self:stopAutoRollTimer()
		-- Start Restore
		self:outRangeRestore()
		WorldMapOptimizer:getInstance():update()
	else 
		assert(false)
	end
end


-----------------------------------------------------------
------------ When Out Of Range Restore
------------------------------------------------------
function WorldSceneScroller:outRangeRestore(...)
	assert(#{...} == 0)

	local newPositionY 	= false
	local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()

	local scenePositionState = self:checkSceneOutRange()
	if scenePositionState == CheckSceneOutRangeConstant.TOP_OUT_OF_RANGE then

		newPositionY = visibleOrigin.y - self.belowScrollRangeY

	elseif scenePositionState == CheckSceneOutRangeConstant.BOTTOM_OUT_OF_RANGE then

		newPositionY = visibleOrigin.y - (self.topScrollRangeY - self.visibleSize.height)

	elseif scenePositionState == CheckSceneOutRangeConstant.HIT_REGION_CLOUD then
		newPositionY = visibleOrigin.y - self:getRegionCloudCheckPosition(self.regionCloudY)
	else 
		assert(false, "Call WorldSceneScroller:outRangeRestore In Proper Situation !")
	end

	self.maskedLayer:stopAllActions()
	local moveToAction	= CCMoveTo:create(0.2, ccp(0,newPositionY))
	local easeOutAction	= CCEaseOut:create(moveToAction, 1)

	local function callBack()
		self:dispatchMoveToPercentageEvent()
		WorldMapOptimizer:getInstance():update()
	end
	local callFuncAction	= CCCallFunc:create(callBack)

	local sequenceAction	= CCSequence:createWithTwoActions(easeOutAction, callFuncAction)
	self.maskedLayer:runAction(sequenceAction)
end

---------------------------------------
------- About MOVE_TO_PERCENTAGE Event
-------------------------------------------

function WorldSceneScroller:dispatchMoveToPercentageEvent(...)
	assert(#{...} == 0)

	local positionY		= self.maskedLayer:getPositionY()

	local scrollHeight	= (self.topScrollRangeY - self.topScrollRangeYAdjust) - self.belowScrollRangeY - self.visibleSize.height / 2
	local deltaHeight	= positionY - (self.visibleOrigin.y - self.belowScrollRangeY) -- 初始化位置

	local percentage	= -deltaHeight / scrollHeight

	if self.trunkScrollInteractionController then
		local scrollRangeHeight = (self.quickScrollRangeY + self.quickScrollRangeYAdjust) - self.belowScrollRangeY - self.visibleSize.height / 2
		self.trunkScrollInteractionController:getScrollView():setCurrentByPercent(-deltaHeight / scrollRangeHeight)
	end
	-- printx(0, "dispatchMoveToPercentageEvent",  positionY, scrollHeight, deltaHeight, percentage)
	self:dispatchEvent(Event.new(WorldSceneScrollerEvents.MOVE_TO_PERCENTAGE, percentage, self))
end

-----------------------------------------------------
--------------- Scrollable
---------------------------------------------------


function WorldSceneScroller:setScrollable(scrollable, ...)
	assert(scrollable ~= nil)
	assert(type(scrollable) == "boolean")
	assert(#{...} == 0)

	--if _G.isLocalDevelopMode then printx(0, 'setScrollable', scrollable) end
	--if scrollable == false then
	--	if _G.isLocalDevelopMode then printx(0, debug.traceback()) end
	--end
	self.scrollable = scrollable
end

function WorldSceneScroller:isScrollable(...)
	assert(#{...} == 0)

	return self.scrollable
end

function WorldSceneScroller:verticalScrollTo(newPositionY, callback)
	local visibleOrigin = CCDirector:sharedDirector():getVisibleOrigin()
	local visibleSize = CCDirector:sharedDirector():getVisibleSize()
	local centerYInScreen = visibleOrigin.y + visibleSize.height / 2

	local config = UIConfigManager:sharedInstance():getConfig()
	local topLevelBelowScreenCenter = config.worldScene_topLevelBelowScreenCenter

	local newMaskedLayerPosY = centerYInScreen - topLevelBelowScreenCenter - newPositionY
	local newMaskedLayerPosX = self.maskedLayer:getPositionX()

	local startPosY = self.maskedLayer:getPositionY()
	local destPosY = newMaskedLayerPosY

	local max = self:getMinMaskedLayerY()
	local deltaLength = -(destPosY - startPosY)
	local percent = math.abs(deltaLength/max)
	--local percent = self.testPercent or 0
	local time = 12 * percent  --deltaLength / linearVelocity

	local minTime = 0.3
	if time > 1.8 then time = 1.8 end
	if time < minTime then time = minTime end

	local moveTo = CCMoveTo:create(time, ccp(newMaskedLayerPosX, newMaskedLayerPosY))
	local ease = moveTo
	if time <= minTime then
		ease = CCEaseSineOut:create(moveTo)
	elseif time > minTime and time < 0.65 then
		ease = CCEaseOut:create(moveTo, 2)
	else
		ease = CCEaseExponentialOut:create(moveTo)
	end

	if __WP8 then
		local oldcallback = callback
		callback = function()
			if oldcallback then oldcallback() end
			self:checkFriendVisible()
		end
	end

	local array = CCArray:create()
	array:addObject(ease)
	array:addObject(CCCallFunc:create(function( ... )
		WorldMapOptimizer:getInstance():update()
		callback()
	end))
	self.maskedLayer:stopAllActions()
	self.maskedLayer:runAction(CCSequence:create(array))
end

--------------------------------------------
--------- Scroll Left Right
-----------------------------------------

------------------------------------------
-- offsetX : offset from origin x
------------------------------------------
function WorldSceneScroller:horizontalScrollTo(offsetX)
	self.maskedLayer:setPositionX(self.visibleOrigin.x + offsetX)
end

function WorldSceneScroller:horizontalAutoFitScroll()
	if self.scrollHorizontalState == WorldSceneScrollerHorizontalState.STAY_IN_LEFT then
		if self.maskedLayer:getPositionX() < (self.visibleOrigin.x + self:getHorizontalScrollRange()) * 4 / 5 then
			self:scrollToOrigin()
		else
			self:scrollToLeft()
		end
	elseif self.scrollHorizontalState == WorldSceneScrollerHorizontalState.STAY_IN_RIGHT then
		if self.maskedLayer:getPositionX() > (self.visibleOrigin.x - self:getHorizontalScrollRange()) * 4 / 5 then
			self:scrollToOrigin()
		else
			self:scrollToRight()
		end
	end
end

function WorldSceneScroller:getHorizontalScrollRange()
	if not self.scrollHorizontalRange then
		self.scrollHorizontalRange = self.visibleSize.width / 2
	end
	return self.scrollHorizontalRange
end

function WorldSceneScroller:scrollToRight(...)
	assert(#{...} == 0)

    --add by zhigang.niu
    local branchIndex = self.currentStayBranchIndex
	local branch = self.hiddenBranchArray[branchIndex]
    if branch and branch.branchBox then
        branch.branchBox:setRewardArrowShow( false )
    end

	self.scrollHorizontalState = WorldSceneScrollerHorizontalState.SCROLLING_TO_RIGHT

	self:setScrollable(false)

	local newPositionX	= self.visibleOrigin.x - self:getHorizontalScrollRange()
	local newPositionY	= self.maskedLayer:getPositionY()
	local time = math.abs(math.abs(self.maskedLayer:getPositionX()) - math.abs(newPositionX)) / math.abs(newPositionX) * self.horizontalScrollMaxTime

	local moveTo	= CCMoveTo:create(time, ccp(newPositionX, newPositionY))

	-- Call BackUp , Dispatch Event
	local function onScrolledToRight()
		assert(self.scrollHorizontalState == WorldSceneScrollerHorizontalState.SCROLLING_TO_RIGHT)
		self.scrollHorizontalState = WorldSceneScrollerHorizontalState.STAY_IN_RIGHT
		self:setTouchEnabled(true)

		self:dispatchEvent(Event.new(WorldSceneScrollerEvents.SCROLLED_TO_RIGHT))
	end
	local callFunc	= CCCallFunc:create(onScrolledToRight)

	-- Sequence
	local sequence	= CCSequence:createWithTwoActions(moveTo, callFunc)
	self:setTouchEnabled(false)

	self.maskedLayer:runAction(sequence)
	self:dispatchEvent(Event.new(WorldSceneScrollerEvents.START_SCROLLED_TO_RIGHT))
end


function WorldSceneScroller:scrollToLeft(...)
	assert(#{...} == 0)

    --add by zhigang.niu
    local branchIndex = self.currentStayBranchIndex
	local branch = self.hiddenBranchArray[branchIndex]
    if branch and branch.branchBox then
        branch.branchBox:setRewardArrowShow( false )
    end

	self.scrollHorizontalState = WorldSceneScrollerHorizontalState.SCROLLING_TO_LEFT

	self:setScrollable(false)

	local newPositionX	= self.visibleOrigin.x + self:getHorizontalScrollRange()
	local newPositionY	= self.maskedLayer:getPositionY()

	-- Move To
	local time = math.abs(math.abs(self.maskedLayer:getPositionX()) - math.abs(newPositionX)) / math.abs(newPositionX) * self.horizontalScrollMaxTime
	local moveTo	= CCMoveTo:create(time, ccp(newPositionX, newPositionY))

	-- Call BackUp , Dispatch Event
	local function onScrolledToLeft()
		assert(self.scrollHorizontalState == WorldSceneScrollerHorizontalState.SCROLLING_TO_LEFT)
		self.scrollHorizontalState = WorldSceneScrollerHorizontalState.STAY_IN_LEFT
		self:setTouchEnabled(true)
		self:dispatchEvent(Event.new(WorldSceneScrollerEvents.SCROLLED_TO_LEFT))
	end
	local callFunc	= CCCallFunc:create(onScrolledToLeft)

	-- Sequence
	local sequence	= CCSequence:createWithTwoActions(moveTo, callFunc)

	self.maskedLayer:runAction(sequence)
	self:dispatchEvent(Event.new(WorldSceneScrollerEvents.START_SCROLLED_TO_LEFT))
	self:setTouchEnabled(false)
end

function WorldSceneScroller:scrollToOrigin(...)
	assert(#{...} == 0)

    --add by zhigang.niu
    local branchIndex = self.currentStayBranchIndex
	local branch = self.hiddenBranchArray[branchIndex]
    if branch and branch.branchBox then
        branch.branchBox:setRewardArrowShow( true )
    end

	assert(self.scrollHorizontalState == WorldSceneScrollerHorizontalState.STAY_IN_LEFT or
		self.scrollHorizontalState == WorldSceneScrollerHorizontalState.STAY_IN_RIGHT)

	self.scrollHorizontalState = WorldSceneScrollerHorizontalState.SCROLLING_TO_ORIGIN

	local newPositionX	= self.visibleOrigin.x
	local newPositionY	= self.maskedLayer:getPositionY()

	local time = math.abs(self.maskedLayer:getPositionX()) / math.abs(self.visibleSize.width / 2) * self.horizontalScrollMaxTime
	local moveTo	= CCMoveTo:create(time, ccp(newPositionX, newPositionY))

	-- Call BackUp , Dispatch Event , Set self.scrollable True
	local function onScrolledToOrigin()
		assert(self.scrollHorizontalState == WorldSceneScrollerHorizontalState.SCROLLING_TO_ORIGIN)
		self.scrollHorizontalState = WorldSceneScrollerHorizontalState.STAY_IN_ORIGIN
		self:setScrollable(true)
		self:setTouchEnabled(true)
		self:dispatchEvent(Event.new(WorldSceneScrollerEvents.SCROLLED_TO_ORIGIN))
		self:dispatchEvent(Event.new(WorldSceneScrollerEvents.SCROLLED_FOR_TUTOR))

		if __WP8 then self:checkFriendVisible() end
	end
	local callFunc	= CCCallFunc:create(onScrolledToOrigin)

	-- Sequence
	local sequence	= CCSequence:createWithTwoActions(moveTo, callFunc)
	self.maskedLayer:runAction(sequence)
	self:dispatchEvent(Event.new(WorldSceneScrollerEvents.START_SCROLLED_TO_ORIGIN))
	self:setTouchEnabled(false)
end

---------------------------------
---- Evnet Handler
----------------------------------

he_log_warning("??")

--Abstract method, implements in concrete class - WorldScene
function WorldSceneScroller:onScrolledToLeftOrRight(event, ...)
end

function WorldSceneScroller:onScrolledToOrigin(event, ...)
end

function WorldSceneScroller:onVerticalScrollStop()
	-- body
end
