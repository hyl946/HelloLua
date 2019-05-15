require "zoo.panel.seasonWeekly.mainPanel.SeasonWeeklyRewardBubble"

SeasonWeeklyRewardPart = class(BasePanel)
function SeasonWeeklyRewardPart:create(rootGroupName, resJson)
	local panel = SeasonWeeklyRewardPart.new()
    if resJson then panel:loadRequiredResource( resJson ) end
    panel:init( rootGroupName ) 
    return panel
end

function SeasonWeeklyRewardPart:init(rootGroupName)
	self.ui = self:buildInterfaceGroup( rootGroupName )
	BasePanel.init(self, self.ui)

	self.ui.onAddToStage = function ()
		self:onAddToStage()
	end

	-- zhukai
	local touchRect = self.ui:getChildByName('touchRect')
	local touchRectSize = touchRect:boundingBox().size
	self.touchRectSize = CCSizeMake(touchRectSize.width, touchRectSize.height)
	self.touchRectPos = touchRect:getPosition()
	self.touchRectPos = ccp(self.touchRectPos.x, self.touchRectPos.y)
	touchRect:removeFromParentAndCleanup(true)

	self.uiWidth = self.touchRectSize.width
	self.uiHeight = self.touchRectSize.height

	self.slideMinX = -1100
	self.slideMaxX = 0

	self:initBubble()
	self:initSlide()
	self:initBird()
end

function SeasonWeeklyRewardPart:initBird()
	self.birdPos = {}
	for i=1,5 do
		local birdPosUI = self.ui:getChildByName("birdPos"..i)
		birdPosUI:setOpacity(0)
		local pos = birdPosUI:getPosition()
		table.insert(self.birdPos, pos)
	end
	
	local bird = gAnimatedObject:createWithFilename('gaf/weekly_2018s1/main_ui_parrot/main_ui_parrot.gaf')
    bird:setLooped(true)
    bird:start()

    self.bird = bird

    local branchUI = self.ui:getChildByName("branch")
    local childIndex = self.ui:getChildIndex(branchUI)

    self.ui:addChildAt(self.bird, childIndex + 1)

    self:updateBirdPos()
end

function SeasonWeeklyRewardPart:updateBirdPos()
	if self.isDisposed then return end
	if self.bird then 
		local rewards = SeasonWeeklyRaceManager:getInstance():getNextWeeklyReward()
		local matchData = SeasonWeeklyRaceManager:getInstance().matchData
		local birdPosIndex = 5

		for i,v in ipairs(rewards) do
			if (matchData.weeklyScore < v.condition) then
				birdPosIndex = i - 1
				break
			end
		end

		if birdPosIndex <= 0 then birdPosIndex = 1 end

		local birdPos = self.birdPos[birdPosIndex]
		if birdPos then 
			self.bird:setPosition(ccp(birdPos.x - 35, birdPos.y + 170))
		end
	end
end

function SeasonWeeklyRewardPart:createBubble( idx )
	return SeasonWeeklyRewardBubble:create( idx , self.ui:getChildByName("ResBubbleReward_" .. idx) )
end

function SeasonWeeklyRewardPart:initBubble()
	local rewardViews = {}
	for i = 1 , 6 do
		local bubble = self:createBubble(i)
		table.insert(rewardViews , bubble)
	end
	
	self.rewardViews = rewardViews
end

function SeasonWeeklyRewardPart:initSlide()
	local size = self.ui
	local layer = LayerColor:createWithColor(ccc4(0,0,0,100) , self.uiWidth , self.uiHeight)
	layer:ignoreAnchorPointForPosition(false)
	layer:setAnchorPoint(ccp(0, 1))
	layer:setPosition(ccp( self.touchRectPos.x , self.touchRectPos.y ) )
	layer:setOpacity(0)
	self.ui:addChild(layer)

	layer:setTouchEnabled(true)

	layer:addEventListener(DisplayEvents.kTouchBegin, function(evt)
		self:onTouchBegin(evt)
	end)

	layer:addEventListener(DisplayEvents.kTouchMove, function(evt)
		self:onTouchMove(evt)
	end)

	layer:addEventListener(DisplayEvents.kTouchEnd, function(evt)
		self:onTouchEnd(evt)
	end)

	self.slideTouchLayer = layer

	for k,v in ipairs(self.rewardViews) do

		local bubble = v
		local bubbleView = bubble.touchRect

		bubbleView:setTouchEnabled(true)
		--bubbleView:setButtonMode(true)
		bubbleView:addEventListener(DisplayEvents.kTouchTap, function(evt)
			self:onTouchTap(evt)
		end)
	end


	local time_cd = 1.0 / GamePlayConfig_Action_FPS

	self.updateScheduler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc( 
		function (evt) self:onEnterFrame(evt) end , time_cd, false)
end

function SeasonWeeklyRewardPart:slideTo( duration, newTargetX , onFinish)
	if self.isDisposed then return end

	self.oldTargetX = self.targetX
	self.newTargetX = newTargetX
	self.duration = duration
	self.timer = 0
	self.onFinish = onFinish
	self:scheduleUpdateWithPriority(function ( ... )
		self:update(...)
	end, 0)
end

function SeasonWeeklyRewardPart:update( t )

	if self.isDisposed then return end


	self.timer = self.timer + t
	self.targetX = self.oldTargetX + (self.newTargetX - self.oldTargetX)/self.duration*self.timer
	if self.timer >= self.duration then
		self:unscheduleUpdate()
		if self.onFinish then
			self.onFinish()
		end
	end
end

function SeasonWeeklyRewardPart:showTipPanel( bubbleIndex )
	printx( 1 , "   SeasonWeeklyRewardPart:showTipPanel  " , bubbleIndex)

	local bubble = self.rewardViews[bubbleIndex]
	bubble:showTipPanel(true)
end

function SeasonWeeklyRewardPart:onEnterFrame(evt)
	if self.isDisposed then return end
	if not self.targetX then return end
	local oldPosX = self.ui:getPositionX()
	local deltaX = self.targetX - oldPosX
	self.ui:setPositionX( self.targetX )

	if self.scrollHCallback then self.scrollHCallback(deltaX) end
end

function SeasonWeeklyRewardPart:setScollHCallback(callback)
	self.scrollHCallback = callback
end

function SeasonWeeklyRewardPart:onAddToStage()
	if self.isDisposed then return end
	--特殊需求
	--雪橇要跟屏幕左侧对齐

	if not self.slideRangeInited then
		self.slideRangeInited = true
		local vo = Director:sharedDirector():getVisibleOrigin()
		local vs = Director:sharedDirector():getVisibleSize()
		local pos = self.ui:convertToNodeSpace(ccp(vo.x, vo.y))
		local pos2 = self.ui:convertToNodeSpace(ccp(vo.x + vs.width, vo.y))

		self.slideMaxX = pos.x + 4
		self.slideMinX = self.slideMaxX - (1475 - (pos2.x - pos.x))
	end

	local function getUserKey( key )
	    local uid = '12345'
	    if UserManager and UserManager:getInstance().user then
	        uid = UserManager:getInstance().user.uid or '12345'
	    end
	    return key .. tostring(uid) .. '.' .. '.by.Misc.getUserKey'
	end

	local function needPlayAnim( ... )
		local ret = CCUserDefault:sharedUserDefault():getBoolForKey(getUserKey('trunk.anim.2017.s3'), false)
		CCUserDefault:sharedUserDefault():setBoolForKey(getUserKey('trunk.anim.2017.s3'), true)
		return ret == false
	end

	if needPlayAnim() then
		self.slideTouchLayer:setTouchEnabled(false)
		self.targetX = self.slideMinX
		self:slideTo(3, self.slideMaxX, function ( ... )

			if self.isDisposed then return end

			self.slideTouchLayer:setTouchEnabled(true)
		end)
	else
		self.targetX = self.slideMaxX
		self:onEnterFrame()
		self:updateAllRewards(true)
	end
end

function SeasonWeeklyRewardPart:onTouchTap(evt)	
	local bubbleName = evt.target:getParent().name
	local si , ei = string.find( bubbleName , "ResBubbleReward_")

	local idx = tonumber(string.sub( bubbleName , ei + 1 ))
	local evt = Event.new( SeasonWeeklyEvents.kBubbleTapped , idx , self )

	self:dispatchEvent(evt)
end

function SeasonWeeklyRewardPart:onTouchBegin(evt)
	self.oldViewPos = ccp( self.ui:getPosition().x , self.ui:getPosition().y )
	self.oldTouchPos = ccp( evt.globalPosition.x , evt.globalPosition.y )
end

function SeasonWeeklyRewardPart:onTouchMove(evt)
	local nx = self.oldViewPos.x + ( evt.globalPosition.x - self.oldTouchPos.x )

	if nx > self.slideMaxX then nx = self.slideMaxX end
	if nx < self.slideMinX then nx = self.slideMinX end

	local ny = self.oldViewPos.y + ( evt.globalPosition.y - self.oldTouchPos.y )
	self.targetX = nx
end

function SeasonWeeklyRewardPart:onTouchEnd(evt)
	--printx( 1 , "  SeasonWeeklyRewardPart:onTouchEnd  ")
	--printx( 1 , "   " , self.ui:getPositionX())
end

function SeasonWeeklyRewardPart:updateAllRewards(isInit)
	if self.isDisposed then return end
	
	self:updateBirdPos() 

	local rewards = SeasonWeeklyRaceManager:getInstance():getNextWeeklyReward()
	local matchData = SeasonWeeklyRaceManager:getInstance().matchData
	local nearestRewardIndex = 0

	for i,v in ipairs(rewards) do
		if (matchData.weeklyScore < v.condition) and (not v.hasReceived) then
			nearestRewardIndex = i
			break
		end
	end

	local posBubble = self.rewardViews[nearestRewardIndex]
	if not posBubble and isInit then 
		posBubble = self.rewardViews[#rewards]
	end

	for k,v in ipairs(rewards) do
		local bubble = self.rewardViews[k]

		if bubble then
			--bubble:setState( SeasonWeeklyRewardBubbleState.kProcessing , { curr = matchData.weeklyScore , total = v.condition} )
			----[[
			if v.hasReceived then
				bubble:setState( SeasonWeeklyRewardBubbleState.kRewarded )
			elseif matchData.weeklyScore >= v.condition then
				bubble:setState( SeasonWeeklyRewardBubbleState.kWaitingForReward )

				-- if not posBubble then
				-- 	posBubble = bubble
				-- end
				
			else
				if k == nearestRewardIndex then
					bubble:setState( SeasonWeeklyRewardBubbleState.kProcessing , { curr = matchData.weeklyScore , total = v.condition} )
				else
					bubble:setState( SeasonWeeklyRewardBubbleState.kNormal )
				end

				-- if not posBubble then
				-- 	posBubble = bubble
				-- end

			end
			--]]
		end
	end

	local function clamp(n)
		return math.min(math.max(self.slideMinX, n), self.slideMaxX)
	end

	if posBubble then
		if (not posBubble.ui) or posBubble.ui.isDisposed then 
			return 
		end 
		
		local bounds = posBubble.ui:getGroupBounds()
		local left = bounds.origin.x
		local right = bounds.origin.x + bounds.size.width/2 - 30

		local visibleSize = CCDirector:sharedDirector():getVisibleSize()
		local visibleOrigin = CCDirector:sharedDirector():getVisibleOrigin()

		local scale = 1
		local node = self.ui

		scale = node:getScaleX()

		while node:getParent() do
			node = node:getParent()
			scale = scale * node:getScaleX()
		end

		if left < visibleOrigin.x then
			self.targetX = clamp((self.targetX or 0) + (visibleOrigin.x - left)/scale)
		end

		if right > visibleOrigin.x + visibleSize.width/2 then
			self.targetX = clamp((self.targetX or 0) - (right - (visibleOrigin.x + visibleSize.width/2))/scale)
		end
	end
end

function SeasonWeeklyRewardPart:fouceSetState(state)
	local rewards = SeasonWeeklyRaceManager:getInstance():getNextWeeklyReward()
	for k,v in ipairs(rewards) do
		local bubble = self.rewardViews[k]

		if bubble then
			bubble:setState( state )
		end
	end
end

function SeasonWeeklyRewardPart:dispose()
	Director:getScheduler():unscheduleScriptEntry(self.updateScheduler)
	self.slideTouchLayer:removeAllEventListeners()
	BasePanel.dispose(self)
end
