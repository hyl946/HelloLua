require "zoo.panel.basePanel.BasePanel"
require "zoo.panel.seasonWeekly.SeasonWeeklyRaceManager"

SeasonWeeklyRaceRewardsPanel = class(BasePanel)

function SeasonWeeklyRaceRewardsPanel:ctor()

end

function SeasonWeeklyRaceRewardsPanel:create(rewards, levelId)
	local panel = SeasonWeeklyRaceRewardsPanel.new()
	panel:init(rewards, levelId)
	return panel
end

function SeasonWeeklyRaceRewardsPanel:init(rewards, levelId)
	assert(type(rewards) == "table")
	assert(#rewards > 0)
	self.levelId = levelId
	self:loadRequiredResource("ui/panel_winter_weekly.json")
	local ui = self:buildInterfaceGroup('lastWeekRewardsPanel/lastWeekRewardsPanel')
	BasePanel.init(self, ui)

	local desc = self.ui:getChildByName("desc")
	desc:setString(Localization:getInstance():getText("weeklyrace.winter.panel.tip6"))

	local rewardsDisplay = self.ui:getChildByName("rewards")
	rewardsDisplay:removeFromParentAndCleanup(false)
	local rewardsDisplayPos = rewardsDisplay:getPosition()
	local rewardsDisplaySize = rewardsDisplay:getGroupBounds().size
	local rewardsDisplayClipping = ClippingNode:create(CCRectMake(0,0, rewardsDisplaySize.width, rewardsDisplaySize.height))
	local touchLayer = Layer:create()
	touchLayer:setContentSize(CCSizeMake(rewardsDisplaySize.width, rewardsDisplaySize.height))
	rewardsDisplayClipping:addChild(touchLayer)
	self.touchLayer = touchLayer

	rewardsDisplayClipping:setPosition(ccp(rewardsDisplayPos.x, rewardsDisplayPos.y - rewardsDisplaySize.height))
	rewardsDisplay:setPosition(ccp(0, rewardsDisplaySize.height))
	rewardsDisplayClipping:addChild(rewardsDisplay)
	self.ui:addChild(rewardsDisplayClipping)

	local rewardBox = rewardsDisplay:getChildByName("reward")
	local rewardBoxSize = rewardBox:getGroupBounds().size
	local rewardsDisplayWidth = 0
	rewardBox:removeFromParentAndCleanup(true)

	if type(rewards) == "table" then
		for i, v in ipairs(rewards) do
			local bubble = self:buildRewardBubble(v)
			rewardsDisplay:addChild(bubble)
			bubble:setPosition(ccp(i * rewardBoxSize.width + rewardBoxSize.width / 2, 0))
		end
		rewardsDisplayWidth = rewardBoxSize.width * #rewards
	end
	rewardsDisplay:setPositionX(-rewardsDisplayWidth/2)
	local maxX = -rewardsDisplaySize.width / 2 + 15
	local minX = -rewardsDisplayWidth + rewardsDisplaySize.width / 2 - 15

	touchLayer.preTouchPos = nil
	touchLayer:setTouchEnabled(true)
	touchLayer:addEventListener(DisplayEvents.kTouchBegin, function(evt)
		touchLayer.preTouchPos = evt.globalPosition
		end)

	local function onTouchMove( evt )
		if rewardsDisplayWidth > rewardsDisplaySize.width then
			local oldPos = rewardsDisplay:getPosition()
			local moveX = evt.globalPosition.x - touchLayer.preTouchPos.x
			local newPosX = oldPos.x + moveX
			if (moveX < 0 and newPosX > minX) or (moveX > 0 and newPosX < maxX) then
				rewardsDisplay:setPositionX(newPosX)
			end
			touchLayer.preTouchPos = evt.globalPosition
		end
	end
	touchLayer:addEventListener(DisplayEvents.kTouchMove, onTouchMove)

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

function SeasonWeeklyRaceRewardsPanel:receiveRewards()
	self.okBtn:setEnabled(false)
	local function onSuccess()
		CommonTip:showTip(Localization:getInstance():getText("weeklyrace.winter.panel.tip7"), "positive")
		HomeScene:sharedInstance():updateCoin()
		self:onCloseBtnTapped()
	end

	local function onFail()
		if self.okBtn and not self.okBtn.isDisposed then
			self.okBtn:setEnabled(true)
		end
		-- self:onCloseBtnTapped()
	end
	SeasonWeeklyRaceManager:getInstance():receiveLastWeekRewards(self.levelId, onSuccess, onFail)
end

function SeasonWeeklyRaceRewardsPanel:buildRewardBubble(reward)
	local rewardId = reward.id
	local itemList = reward.items

	local bubble = self:buildInterfaceGroup('lastWeekRewardsPanel/rewardsPanel_reward')
	local icons = bubble:getChildByName("icon")
	for i = 1, 6 do
		if rewardId == i then
			icons:getChildByName(tostring(i)):setVisible(true)
		else
			icons:getChildByName(tostring(i)):setVisible(false)
		end
	end
	local tag = bubble:getChildByName("tag")
	tag:setVisible(rewardId == 6)

	local ipt = {}
	for k, v in ipairs(itemList) do
		local itemId = v.itemId
		if ItemType:isTimeProp(itemId) then
			itemId = ItemType:getRealIdByTimePropId(itemId)
		end
		table.insert(ipt, {itemId = itemId, num = v.num})
	end

	local function onIconTouched(evt)
		if self.touchLayer and not self.touchLayer:hitTestPoint(evt.globalPosition, true) then
			return
		end
		local tipPanel = BoxRewardTipPanel:create({ rewards=ipt })
		tipPanel:setTipString(Localization:getInstance():getText("weeklyrace.winter.panel.tip2"))
		self.ui:addChild(tipPanel)
		local bounds = bubble:getGroupBounds()
		tipPanel:setArrowPointPositionInWorldSpace(bounds.size.width/2,bounds:getMidX(),bounds:getMidY())
	end
	icons:setTouchEnabled(true)
	icons:addEventListener(DisplayEvents.kTouchTap, onIconTouched)

	return bubble
end

function SeasonWeeklyRaceRewardsPanel:dispose()
	-- if type(self.unloadRequiredResource) == "function" then self:unloadRequiredResource() end
	BaseUI.dispose(self)
end

function SeasonWeeklyRaceRewardsPanel:popout()
	PopoutManager:sharedInstance():add(self)
	self.allowBackKeyTap = true
	self.onClosedCallback = onClosed
end

function SeasonWeeklyRaceRewardsPanel:onCloseBtnTapped()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
	if self.onClosedCallback then self.onClosedCallback() end
end
