
WorldSceneTrunkInteractionController = class()

function WorldSceneTrunkInteractionController:register()
	self.worldScene:addEventListener(DisplayEvents.kTouchBegin, self.onSceneTouchBegan, self)
	self.worldScene:addEventListener(DisplayEvents.kTouchMove, self.onSceneTouchMoved, self)
	self.worldScene:addEventListener(DisplayEvents.kTouchEnd, self.onSceneTouchEnded, self)
end

function WorldSceneTrunkInteractionController.onSceneTouchBegan(event, ...)
	assert(event)
	assert(event.name == DisplayEvents.kTouchBegin)
	assert(#{...} == 0)
	local self = event.context.worldScene

	local globalPos = event.globalPosition
	self.initialTouchPos = event.globalPosition
	self.scrolled = false

	self.touchedFriendStack = false
	self.touchedLockedCloud = false
	self.touchedNode = false
	self.touchedBranch = nil
	self.touchedFloatIcon = nil

	--local touchedFriendStack = self:getTouchedFriendStack(globalPos)
	self.touchedFriendStack = self:getTouchedFriendStack(globalPos)

	-- Hide Friend Stacks, Except The Tapepd Stack
	for k,v in pairs(self.levelFriendPicStacks) do
		if v.stack:getShowState() == FriendPicStackState.FRIEND_PIC_SHOW_STATE_EXPANDED and
			v.stack ~= self.touchedFriendStack then
			v.stack:onTapped()
		end
	end

	if self.userIcon and self.userIcon.state == UserPictureState.EXPANDED then
		self.userIcon:onTapped()
	end 

	local touchedLockedCloud = self:getTouchedLockedCloud(globalPos)
	local canHandleTouchEvt = touchedLockedCloud and (touchedLockedCloud.state == LockedCloudState.WAIT_TO_OPEN or touchedLockedCloud.state == LockedCloudState.STATIC)
	local touchedNode = self:getTouchedNode(globalPos)
	local touchedBranch = self:getTouchedBranch(globalPos)
	--local touchedFloatIcon = self:getTouchedFloatIcon(globalPos)

	if touchedLockedCloud and not canHandleTouchEvt then
		if touchedLockedCloud:checkTouchedBlocker(globalPos) then
			touchedLockedCloud:doTouchedBlocker()
		end
	end
	
	--printx( 1, "WorldSceneTrunkInteractionController.onSceneTouchBegan 1 = " ,touchedLockedCloud , canHandleTouchEvt)
	if touchedLockedCloud and canHandleTouchEvt then

		if touchedLockedCloud:checkTouchedBlocker(globalPos) then
			--printx( 1, "WorldSceneTrunkInteractionController.onSceneTouchBegan 2 = " ,touchedLockedCloud , canHandleTouchEvt)
			touchedLockedCloud:doTouchedBlocker()
			--self.touchedLockedCloud = touchedLockedCloud
			self.touchState = WorldSceneScrollerTouchState.VERTICAL_SCROLLER_TOUCHED
			local displayEvent = DisplayEvent.new(DisplayEvents.kTouchBegin, nil, globalPos)
			self:onScrollerTouchBegin(displayEvent)
		else
			--printx( 1, "WorldSceneTrunkInteractionController.onSceneTouchBegan 3 = " ,touchedLockedCloud , canHandleTouchEvt)

			--[[
			if touchedLockedCloud:checkTouchedLock(globalPos) then
				printx( 1 , "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
				touchedLockedCloud:onLockedCloudTapped()
			else

			end
			]]
			
			self.touchState = WorldSceneScrollerTouchState.SOME_THING_ABOVE_SCROLLER_TOUCHED
			self.touchedLockedCloud = touchedLockedCloud
		end

	elseif touchedNode and LevelType:isMainLevel(touchedNode.levelId) then
		self.touchState = WorldSceneScrollerTouchState.SOME_THING_ABOVE_SCROLLER_TOUCHED 
		self.touchedNode = touchedNode
	elseif touchedBranch then
		self.touchState = WorldSceneScrollerTouchState.HORIZONTAL_SCROLLER_TOUCHED
		self.touchedBranch = touchedBranch
		self:dispatchEvent(Event.new(WorldSceneScrollerEvents.BRANCH_MOVING_STARTED))
	elseif touchedFloatIcon then
		self.touchState = WorldSceneScrollerTouchState.HORIZONTAL_SCROLLER_TOUCHED
		self.touchedFloatIcon = touchedFloatIcon
		self:dispatchEvent(Event.new(WorldSceneScrollerEvents.BRANCH_MOVING_STARTED))
	else
		self.touchState = WorldSceneScrollerTouchState.VERTICAL_SCROLLER_TOUCHED
		local displayEvent = DisplayEvent.new(DisplayEvents.kTouchBegin, nil, globalPos)
		self:onScrollerTouchBegin(displayEvent)
	end
end

function WorldSceneTrunkInteractionController.onSceneTouchMoved(event, ...)
	assert(event)
	assert(event.name == DisplayEvents.kTouchMove)
	assert(#{...} == 0)

	local self = event.context.worldScene
	local globalPos = event.globalPosition

	if ccpDistance(self.initialTouchPos, globalPos) > 30 then
		self.scrolled = true
		if self.touchedFriendStack and 
			self.touchedFriendStack:getShowState() == FriendPicStackState.FRIEND_PIC_SHOW_STATE_EXPANDED then
			self.touchedFriendStack:onTapped()
		end
	end

	local function changeStateToScrollerTouched()
		self.touchState = WorldSceneScrollerTouchState.VERTICAL_SCROLLER_TOUCHED
		local displayEvent = DisplayEvent.new(DisplayEvents.kTouchBegin, nil, globalPos)
		self:onScrollerTouchBegin(displayEvent)
	end

	if self.touchState == WorldSceneScrollerTouchState.SOME_THING_ABOVE_SCROLLER_TOUCHED then
		if self.touchedLockedCloud then
			if not self.touchedLockedCloud:hitTestPoint(event.globalPosition, true) then
				changeStateToScrollerTouched()
			end
		elseif self.touchedNode then
			local flowerRes = self.touchedNode:getFlowerRes()
			if flowerRes and not flowerRes:hitTestPoint(event.globalPosition, true) then
				changeStateToScrollerTouched()
			end
		else
			assert(false)
		end
	elseif self.touchState == WorldSceneScrollerTouchState.HORIZONTAL_SCROLLER_TOUCHED then
		local self = event.context.worldScene
		if self:isAutoRollTimerRunning() then
			return
		end
		if self.touchedBranch then
			local horizontalDistance = globalPos.x - self.initialTouchPos.x
			local direction = self.touchedBranch:getDirection()

			if direction == HiddenBranchDirection.LEFT then
				horizontalDistance = math.max(0, horizontalDistance)
				horizontalDistance = math.min(self:getHorizontalScrollRange(), horizontalDistance)
			elseif direction == HiddenBranchDirection.RIGHT then
				horizontalDistance = math.min(0, horizontalDistance)
				horizontalDistance = math.max(-self:getHorizontalScrollRange(), horizontalDistance)
			end
			self:horizontalScrollTo(horizontalDistance)
		elseif self.touchedFloatIcon then
			local horizontalDistance = globalPos.x - self.initialTouchPos.x
			if self.touchedFloatIcon:getFloatType() == FloatIconType.kLeft then
				horizontalDistance = math.max(0, horizontalDistance)
				horizontalDistance = math.min(self:getHorizontalScrollRange(), horizontalDistance)
			elseif self.touchedFloatIcon:getFloatType() == FloatIconType.kRight then
				horizontalDistance = math.min(0, horizontalDistance)
				horizontalDistance = math.max(-self:getHorizontalScrollRange(), horizontalDistance)
			end
			self:horizontalScrollTo(horizontalDistance)
		end
	end
end

function WorldSceneTrunkInteractionController.onSceneTouchEnded(event, ...)
	assert(event)
	assert(event.name == DisplayEvents.kTouchEnd)
	assert(#{...} == 0)

	local self = event.context.worldScene
	if self:isAutoRollTimerRunning() then
		return
	end

	if not self.scrolled and self.touchedFriendStack then
		self.touchedFriendStack:onTapped()
	end
	
	if self.touchState == WorldSceneScrollerTouchState.SOME_THING_ABOVE_SCROLLER_TOUCHED then
		if self.touchedLockedCloud then
			self.touchedLockedCloud:dispatchEvent(Event.new(DisplayEvents.kTouchTap))
		elseif self.touchedNode then
			self.touchedNode:dispatchEvent(Event.new(DisplayEvents.kTouchTap))
		else
			assert(false)
		end
	elseif self.touchState == WorldSceneScrollerTouchState.HORIZONTAL_SCROLLER_TOUCHED then
		if self.touchedBranch then
			self.touchedBranch:dispatchEvent(Event.new(DisplayEvents.kTouchTap))
		elseif self.touchedFloatIcon then
			self.touchedFloatIcon:dispatchEvent(Event.new(DisplayEvents.kTouchTap))
		end
	end
end

function WorldSceneTrunkInteractionController:unregister()
	self.worldScene:removeEventListener(DisplayEvents.kTouchBegin, self.onSceneTouchBegan)
	self.worldScene:removeEventListener(DisplayEvents.kTouchMove, self.onSceneTouchMoved)
	self.worldScene:removeEventListener(DisplayEvents.kTouchEnd, self.onSceneTouchEnded)
end

function WorldSceneTrunkInteractionController:create(worldScene)
	local v = WorldSceneTrunkInteractionController.new()
	v.worldScene = worldScene
	return v
end