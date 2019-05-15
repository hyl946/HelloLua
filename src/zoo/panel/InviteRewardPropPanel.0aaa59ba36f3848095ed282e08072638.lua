require "zoo.panel.basePanel.BasePanel"

InviteRewardPropPanel = class(BasePanel)

function InviteRewardPropPanel:getReward()
	local function onSuccess(evt)
		if type(evt.data) ~= "table" or type(evt.data.rewardItems) ~= "table" then return end
		local itemId, num = evt.data.rewardItems[1].itemId, evt.data.rewardItems[1].num
		UserManager:getInstance():addRewards(evt.data.rewardItems)
		GainAndConsumeMgr.getInstance():gainMultiItems(DcFeatureType.kFriend, evt.data.rewardItems, DcSourceType.kInviteReward)
		UserManager:getInstance():setUserRewardBit(3, true)
		if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
		else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end
		panel = InviteRewardPropPanel:create(itemId, num)
		panel:popout()
	end
	local http = GetRewardsHttp.new(true)
	http:addEventListener(Events.kComplete, onSuccess)
	http:load(3)
end

function InviteRewardPropPanel:create(propId, num)
	if type(propId) ~= "number" or type(num) ~= "number" then return end
	local panel = InviteRewardPropPanel.new()
	panel:_init(propId, num)
	return panel
end

function InviteRewardPropPanel:_init(propId, num)
	self:loadRequiredResource(PanelConfigFiles.invite_friend_reward_panel)
	local ui = self.builder:buildGroup("InviteRewardPropPanel")
	self:init(ui)
	self:scaleAccordingToResolutionConfig()
	self:setPositionForPopoutManager()

	local text = ui:getChildByName("text")
	local button = ui:getChildByName("button")
	local propBg = ui:getChildByName("propBg")
	local propNum = ui:getChildByName("propNum")
	local propPh = ui:getChildByName("propPh")
	button = GroupButtonBase:create(button)

	text:setString(Localization:getInstance():getText("恭喜您首次成功邀请好友，获得20风车币奖励！")) -- TODO: localization
	button:setString(Localization:getInstance():getText("确认")) -- TODO: localization
	propPh:setVisible(false)
	local sprite
	if propId == 2 then
		sprite = ResourceManager:sharedInstance():buildGroup("stackIcon")
		sprite:setScale(0.6)
	elseif propId == 14 then
		sprite = Sprite:createWithSpriteFrameName("wheel0000")
		sprite:setAnchorPoint(ccp(0, 1))
		sprite:setScale(1.5)
	else
		sprite = ResourceManager:sharedInstance():buildItemGroup(propId)
	end
	if type(sprite) ~= "nil" then
		sprite:setPositionXY(propPh:getPositionX(), propPh:getPositionY())
		local index = ui:getChildIndex(propPh)
		ui:addChildAt(sprite, index)
	end

	local charWidth = 40
	local charHeight = 40
	local charInterval = 20
	local fntFile = "fnt/target_amount.fnt"
	local position = propNum:getPosition()
	local newLabel = LabelBMMonospaceFont:create(charWidth, charHeight, charInterval, fntFile)
	newLabel:setAnchorPoint(ccp(0,1))
	newLabel:setString("x"..tostring(num))
	local size = newLabel:getContentSize()
	local rcSize = propBg:getGroupBounds().size
	newLabel:setPositionX(propBg:getPositionX() + rcSize.width - size.width + 10)
	newLabel:setPositionY(propNum:getPositionY())
	ui:addChild(newLabel)
	propNum:removeFromParentAndCleanup(true)

	local function onButton()
		local scene = HomeScene:sharedInstance()
		if not scene then return end
		scene:checkDataChange()

        local anim = FlyItemsAnimation:create({{itemId = propId, num = num}})
        local bounds = sprite:getGroupBounds()
        anim:setWorldPosition(ccp(bounds:getMidX(),bounds:getMidY()))
        anim:play()

		PopoutManager:sharedInstance():remove(self)
	end
	button:addEventListener(DisplayEvents.kTouchTap, onButton)
end

function InviteRewardPropPanel:popout()
	PopoutManager:sharedInstance():add(self, true, false)
end