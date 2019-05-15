
WorldSceneBranchInteractionController = class()

function WorldSceneBranchInteractionController:register()
	self.worldScene:addEventListener(DisplayEvents.kTouchBegin, self.onSceneTouchBegan, self)
	self.worldScene:addEventListener(DisplayEvents.kTouchMove, self.onSceneTouchMoved, self)
	self.worldScene:addEventListener(DisplayEvents.kTouchEnd, self.onSceneTouchEnded, self)
end

function WorldSceneBranchInteractionController.onSceneTouchBegan(event, ...)
	assert(event)
	assert(event.name == DisplayEvents.kTouchBegin)
	assert(#{...} == 0)
	local self = event.context.worldScene

	local globalPos = event.globalPosition
	self.initialTouchPos = event.globalPosition
	self.scrolled = false
	self.initialDistance = self.maskedLayer:getPositionX()

	self.touchedFriendStack = false
	self.touchedNode = false
	self.touchedBranch = nil

	local touchedNode = self:getTouchedNode(globalPos)
	local touchedReward = self:getTouchedReward(globalPos)
	local touchedBranch = self:getTouchedBranch(globalPos)
	--local touchedFloatIcon = self:getTouchedFloatIcon(globalPos)

	if touchedNode and LevelType:isHideLevel(touchedNode.levelId) then
		self.touchState = WorldSceneScrollerTouchState.SOME_THING_ABOVE_SCROLLER_TOUCHED 
		self.touchedNode = touchedNode
	elseif touchedReward then
		self.touchState = WorldSceneScrollerTouchState.SOME_THING_ABOVE_SCROLLER_TOUCHED 
		self.touchedReward = touchedReward
	elseif touchedBranch then
		self.touchState = WorldSceneScrollerTouchState.HORIZONTAL_SCROLLER_TOUCHED
		self.touchedBranch = touchedBranch
		self:dispatchEvent(Event.new(WorldSceneScrollerEvents.BRANCH_MOVING_STARTED))
	elseif touchedFloatIcon then
		self.touchState = WorldSceneScrollerTouchState.HORIZONTAL_SCROLLER_TOUCHED
		self.touchedFloatIcon = touchedFloatIcon
		self:dispatchEvent(Event.new(WorldSceneScrollerEvents.BRANCH_MOVING_STARTED))
	else
		self.touchState = WorldSceneScrollerTouchState.HORIZONTAL_SCROLLER_TOUCHED
		self:dispatchEvent(Event.new(WorldSceneScrollerEvents.BRANCH_MOVING_STARTED))
	end
	
end

function WorldSceneBranchInteractionController.onSceneTouchMoved(event, ...)
	assert(event)
	assert(event.name == DisplayEvents.kTouchMove)
	assert(#{...} == 0)

	local self = event.context.worldScene
	local globalPos = event.globalPosition

	if ccpDistance(self.initialTouchPos, globalPos) > 30 then
		self.scrolled = true
	end

	local function changeStateToScrollerTouched()
		self.touchState = WorldSceneScrollerTouchState.HORIZONTAL_SCROLLER_TOUCHED
	end

	if self.touchState == WorldSceneScrollerTouchState.SOME_THING_ABOVE_SCROLLER_TOUCHED then
		if self.touchedNode then
			local flowerRes = self.touchedNode:getFlowerRes()
			if not flowerRes:hitTestPoint(event.globalPosition, true) then
				changeStateToScrollerTouched()
			end
		elseif self.touchedReward then
			if not self.touchedReward:hitTestPoint(event.globalPosition, true) then
				changeStateToScrollerTouched()
			end
		else
			assert(false)
		end
	elseif self.touchState == WorldSceneScrollerTouchState.HORIZONTAL_SCROLLER_TOUCHED then
		local horizontalDistance = globalPos.x - self.initialTouchPos.x
		local targetOffsetX = 0

		if self.scrollHorizontalState == WorldSceneScrollerHorizontalState.STAY_IN_LEFT then
			horizontalDistance = math.min(0, horizontalDistance)
			targetOffsetX = self.initialDistance + horizontalDistance
			targetOffsetX = math.max(0, targetOffsetX)
		elseif self.scrollHorizontalState == WorldSceneScrollerHorizontalState.STAY_IN_RIGHT then
			horizontalDistance = math.max(0, horizontalDistance)
			targetOffsetX = self.initialDistance + horizontalDistance
			targetOffsetX = math.min(0, targetOffsetX)
		end
		self:horizontalScrollTo(targetOffsetX)
	end
end

function WorldSceneBranchInteractionController.onSceneTouchEnded(event, ...)
	assert(event)
	assert(event.name == DisplayEvents.kTouchEnd)
	assert(#{...} == 0)

	local self = event.context.worldScene
	if self:isAutoRollTimerRunning() then
		return
	end

	if self.touchState == WorldSceneScrollerTouchState.SOME_THING_ABOVE_SCROLLER_TOUCHED then
		if self.touchedNode then
			self.touchedNode:dispatchEvent(Event.new(DisplayEvents.kTouchTap))
		elseif self.touchedReward then
			self.touchedReward:dispatchEvent(Event.new(DisplayEvents.kTouchTap))
		else
			assert(false)
		end
	elseif self.touchState == WorldSceneScrollerTouchState.HORIZONTAL_SCROLLER_TOUCHED then
		if self.touchedBranch and not self.scrolled then
			self:scrollToOrigin()
		else
			-- if self.initialTouchPos.x < self.visibleSize.width / 4
			local directScrollOriginScreenRange = 1 / 4
			if self.scrollHorizontalState == WorldSceneScrollerHorizontalState.STAY_IN_LEFT then
				if self.initialTouchPos.x > self.visibleSize.width * (1 - directScrollOriginScreenRange) then
					self:scrollToOrigin()
				else
					self:horizontalAutoFitScroll()
				end
			elseif self.scrollHorizontalState == WorldSceneScrollerHorizontalState.STAY_IN_RIGHT then
				if self.initialTouchPos.x < self.visibleSize.width * directScrollOriginScreenRange then
					self:scrollToOrigin()
				else
					self:horizontalAutoFitScroll()
				end
			end
		end
	end
	
end


function WorldSceneBranchInteractionController:unregister()
	self.worldScene:removeEventListener(DisplayEvents.kTouchBegin, self.onSceneTouchBegan)
	self.worldScene:removeEventListener(DisplayEvents.kTouchMove, self.onSceneTouchMoved)
	self.worldScene:removeEventListener(DisplayEvents.kTouchEnd, self.onSceneTouchEnded)
end

function WorldSceneBranchInteractionController:create(worldScene)
	local v = WorldSceneBranchInteractionController.new()
	v.worldScene = worldScene
	return v
end