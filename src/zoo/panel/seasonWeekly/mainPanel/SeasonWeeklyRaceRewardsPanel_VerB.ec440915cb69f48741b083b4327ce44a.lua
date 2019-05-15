SeasonWeeklyRaceRewardsPanel_VerB = class(BasePanel)

function SeasonWeeklyRaceRewardsPanel_VerB:create(rewards, levelId)
	local panel = SeasonWeeklyRaceRewardsPanel_VerB.new()
	panel:init(rewards, levelId)
	return panel
end

function SeasonWeeklyRaceRewardsPanel_VerB:init(rewards, levelId)
	assert(type(rewards) == "table")
	assert(#rewards > 0)
	self.levelId = levelId
	self:loadRequiredResource("ui/panel_spring_weekly.json")
	local ui = self:buildInterfaceGroup('2017SummerWeekly/interface/LastWeekRewardsPanel')
	BasePanel.init(self, ui)

	
	local rewardsDisplay = self.ui:getChildByName("rewards")
	rewardsDisplay:removeFromParentAndCleanup(false)
	local rewardsDisplayPos = rewardsDisplay:getPosition()
	local rewardsDisplaySize = rewardsDisplay:getGroupBounds().size
	local rewardsDisplayClipping = ClippingNode:create(CCRectMake(0,0, rewardsDisplaySize.width, rewardsDisplaySize.height))
	local touchLayer = Layer:create()
	touchLayer:setContentSize(CCSizeMake(rewardsDisplaySize.width, rewardsDisplaySize.height))
	rewardsDisplayClipping:addChild(touchLayer)
	self.touchLayer = touchLayer
	printx( 1 , "   rewardsDisplayPos " , rewardsDisplayPos.x, rewardsDisplayPos.y - rewardsDisplaySize.height)
	rewardsDisplayClipping:setPosition(ccp(rewardsDisplayPos.x, rewardsDisplayPos.y - rewardsDisplaySize.height))
	rewardsDisplay:setPosition(ccp(0, rewardsDisplaySize.height / 1))
	rewardsDisplayClipping:addChild(rewardsDisplay)
	self.ui:addChild(rewardsDisplayClipping)

	local fixScale = 0.9
	local rewardsBegX = 0
	local itemGap = 1

	local rewardsW = 0

	-- 配置奖励的显示
	if type(rewards) == "table" then
		for i, v in ipairs(rewards) do
			local resIndex = tonumber(v.id)
			local bubbleRes = self:buildInterfaceGroup('2017SummerWeekly/interface/rewards/last_' ..  resIndex)
			bubbleRes:setScale(fixScale)
			local size = bubbleRes:getGroupBounds().size

			local itemRealSize = CCSizeMake(size.width, size.height)
			rewardsW = rewardsW + size.width + itemGap

			rewardsDisplay:addChild(bubbleRes)
			bubbleRes:setPosition(ccp(rewardsBegX + itemRealSize.width/2,  -(rewardsDisplaySize.height)/2 - 5))
			rewardsBegX = rewardsBegX + itemRealSize.width + itemGap
			bubbleRes:setTouchEnabled(true)

			local rewards = {rewards = v.items }

			if tonumber(v.id) == 6 then
				rewards = table.copyValues(rewards)
				table.insert(rewards.rewards, {itemId = 10072, num = 1})
			end

			bubbleRes:ad(DisplayEvents.kTouchTap, function ( ... )
				local tipPanel = BoxRewardTipPanel:create(rewards)
				tipPanel:setTipString("")
				local scene = Director:sharedDirector():getRunningScene()
				scene:addChild(tipPanel , SceneLayerShowKey.TOP_LAYER)
				local bounds = bubbleRes:getGroupBounds()
				tipPanel:scaleAccordingToResolutionConfig()
				tipPanel:setArrowPointPositionInWorldSpace( 80 , bounds:getMidX() , bounds:getMidY())
			end)

		end
	end
	rewardsBegX = rewardsBegX - itemGap


	rewardsDisplay:setPositionX(0)
	local maxX = 0
	local minX = (rewardsW - rewardsDisplaySize.width) * -1
	--minX = minX + itemGap

	touchLayer.preTouchPos = nil
	touchLayer:setTouchEnabled(true)

	local function onTouchBegin(evt)
		touchLayer.preTouchPos = evt.globalPosition
	end

	local function onTouchMove( evt )
		local oldPos = rewardsDisplay:getPosition()
		local moveX = evt.globalPosition.x - touchLayer.preTouchPos.x
		local newPosX = oldPos.x + moveX
		if (moveX < 0 and newPosX > minX) or (moveX > 0 and newPosX < maxX) then
			rewardsDisplay:setPositionX(newPosX)
		end
		touchLayer.preTouchPos = evt.globalPosition
	end

	if rewardsBegX > rewardsDisplaySize.width then
		touchLayer:addEventListener(DisplayEvents.kTouchBegin, onTouchBegin)
		touchLayer:addEventListener(DisplayEvents.kTouchMove, onTouchMove)
	else
		local itemStartX = (rewardsDisplaySize.width - rewardsW)/2
		rewardsDisplay:setPositionX(itemStartX + rewardsDisplay:getPositionX())
	end

	self.okBtn = GroupButtonBase:create(ui:getChildByName("okBtn"))
	self.okBtn:setColorMode(kGroupButtonColorMode.green)
	self.okBtn:setString(Localization:getInstance():getText("weekly.race.panel.rabbit.button4"))
	self.okBtn:addEventListener(DisplayEvents.kTouchTap, function() self:receiveRewards() end)

	local closeBtn = ui:getChildByName('closeBtn')
	closeBtn:setTouchEnabled(true, 0, true)
	closeBtn:setButtonMode(true)
   	closeBtn:ad(DisplayEvents.kTouchTap, function () self:onCloseBtnTapped() end)

   	self:scaleAccordingToResolutionConfig()
	self:setPositionForPopoutManager(true)
end

function SeasonWeeklyRaceRewardsPanel_VerB:receiveRewards()
	self.okBtn:setEnabled(false)
	local function onSuccess()
		CommonTip:showTip(Localization:getInstance():getText("weeklyrace.winter.panel.tip7"), "positive")
		HomeScene:sharedInstance():updateCoin()
		self:onCloseBtnTapped()
	end

	local function onFail(event)

		if event and event.data then
			if tostring(event.data) == '731080' or tostring(event.data) == '731079' then
				self:onCloseBtnTapped()
				return
			end
		end

		if self.okBtn and not self.okBtn.isDisposed then
			self.okBtn:setEnabled(true)
		end
		-- self:onCloseBtnTapped()
	end
	SeasonWeeklyRaceManager:getInstance():receiveLastWeekRewards(self.levelId, onSuccess, onFail)
end

-- function SeasonWeeklyRaceRewardsPanel_VerB:buildRewardBubble(reward)
-- 	local rewardId = reward.id
-- 	local itemList = reward.items

-- 	local bubble = self:buildInterfaceGroup('lastWeekRewardsPanel/rewardsPanel_reward')
-- 	local icons = bubble:getChildByName("icon")
-- 	for i = 1, 6 do
-- 		if rewardId == i then
-- 			icons:getChildByName(tostring(i)):setVisible(true)
-- 		else
-- 			icons:getChildByName(tostring(i)):setVisible(false)
-- 		end
-- 	end
-- 	local tag = bubble:getChildByName("tag")
-- 	tag:setVisible(rewardId == 6)

-- 	local ipt = {}
-- 	for k, v in ipairs(itemList) do
-- 		local itemId = v.itemId
-- 		if ItemType:isTimeProp(itemId) then
-- 			itemId = ItemType:getRealIdByTimePropId(itemId)
-- 		end
-- 		table.insert(ipt, {itemId = itemId, num = v.num})
-- 	end

-- 	local function onIconTouched(evt)
-- 		if self.touchLayer and not self.touchLayer:hitTestPoint(evt.globalPosition, true) then
-- 			return
-- 		end
-- 		local tipPanel = BoxRewardTipPanel:create({ rewards=ipt })
-- 		tipPanel:setTipString(Localization:getInstance():getText("weeklyrace.winter.panel.tip2"))
-- 		self.ui:addChild(tipPanel)
-- 		local bounds = bubble:getGroupBounds()
-- 		tipPanel:setArrowPointPositionInWorldSpace(bounds.size.width/2,bounds:getMidX(),bounds:getMidY())
-- 	end
-- 	icons:setTouchEnabled(true)
-- 	icons:addEventListener(DisplayEvents.kTouchTap, onIconTouched)

-- 	return bubble
-- end

function SeasonWeeklyRaceRewardsPanel_VerB:dispose()
	-- if type(self.unloadRequiredResource) == "function" then self:unloadRequiredResource() end
	BaseUI.dispose(self)
end

function SeasonWeeklyRaceRewardsPanel_VerB:popout()
	PopoutManager:sharedInstance():add(self, true)
	self.allowBackKeyTap = true
	self.onClosedCallback = onClosed

end

function SeasonWeeklyRaceRewardsPanel_VerB:onCloseBtnTapped()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
	if self.onClosedCallback then self.onClosedCallback() end
end