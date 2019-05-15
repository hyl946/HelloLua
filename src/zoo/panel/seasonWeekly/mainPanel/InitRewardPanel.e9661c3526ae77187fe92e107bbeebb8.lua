local InitRewardPanel = class(BasePanel)

function InitRewardPanel:create(rewards, onCloseCallback)

    local panel = InitRewardPanel.new()
    panel:loadRequiredResource( 'ui/panel_spring_weekly.json' )
    panel:init(rewards, onCloseCallback) 
    return panel
end

function InitRewardPanel:init(rewards, onCloseCallback)

	self.onCloseCallback = onCloseCallback

	self.ui = self:buildInterfaceGroup( '2017s4.weekly.dir/init_reward_panel' )
	BasePanel.init(self, self.ui)

	self:initCloseButton()
	self.closeBtn:setTouchEnabled(true)
	self.closeBtn:addEventListener(DisplayEvents.kTouchTap, function() self:closePanel() end)

	self:initLabel()

	self.rewards = rewards

	self.btn = 	GroupButtonBase:create(self.ui:getChildByName('btn')) 
	self.btn:ad(DisplayEvents.kTouchTap, function ( ... )
		self:fly()
		self:closePanel()
	end)
	self.btn:setString('领取')

	if rewards and rewards[1] then
		local itemId = rewards[1].itemId or 0
		local num = rewards[1].num or 0

		local rewardUI = self.ui:getChildByName('reward')
		local iconHolder = rewardUI:getChildByName('icon')
		iconHolderIndex = rewardUI:getChildIndex(iconHolder)
		local numUI = rewardUI:getChildByName('x1')

		numUI:changeFntFile('fnt/video.fnt')
		numUI:setText('x' .. num)
		numUI:setScale(2)
		numUI:setPositionY(numUI:getPositionY() - 15)

		local icon = ResourceManager:sharedInstance():buildItemSprite(itemId)

		local w = iconHolder:getContentSize().width * iconHolder:getScaleX()
		iconHolder:setAnchorPointCenterWhileStayOrigianlPosition()
		local pos = iconHolder:getPosition()
		pos = ccp(pos.x, pos.y)

		if icon then
			icon:setScale(w / icon:getContentSize().width)
			icon:setAnchorPoint(ccp(0.5, 0.5))
			icon:setPosition(pos)
			rewardUI:addChildAt(icon, iconHolderIndex)

			iconHolder:setVisible(false)
		end

	end

end

function InitRewardPanel:fly( onFinish )

	local rewardUI = self.ui:getChildByName('reward')
	local iconHolder = rewardUI:getChildByName('icon')
	local bounds = iconHolder:getGroupBounds()
	local startPos = ccp(bounds:getMidX(), bounds:getMidY())

	local anim = FlyItemsAnimation:create(self.rewards)
	anim:setScale(1.8)
	anim:setWorldPosition(startPos)
	anim:play()

end

function InitRewardPanel:initLabel()

	self.labels = {}
	self.icons = self.ui:getChildByName('icons')

	for i = 1, 3 do
		self.labels[i] = self.ui:getChildByName('label_'..i)
		self.labels[i]:setDimensions(CCSizeMake(self.labels[i]:getDimensions().width, 0))
		self.labels[i]:setString( Localization:getInstance():getText("weekly.s4.init.tip."..i) )
	end

	local posY = self.labels[1]:getPositionY()
	local firstLabelPosY = posY

	local spacingY = 40
	local firstIconPosY = self.icons:getChildByName('icon1'):getPositionY()

	for i = 1, 3 do
		self.labels[i]:setPositionY(posY)
		local icon = self.icons:getChildByName('icon'..i)
		if icon then
			icon:setPositionY(posY - firstLabelPosY + firstIconPosY + 10)
		end
		posY = posY - self.labels[i]:getContentSize().height - spacingY
	end

end


function InitRewardPanel:initCloseButton()
	self.closeBtn = self.ui:getChildByName("closeBtn")
end

function InitRewardPanel:popout()
    self:scaleAccordingToResolutionConfig()
	self:setPositionForPopoutManager()
	PopoutManager:sharedInstance():add(self , true)
	self.allowBackKeyTap = true
end

function InitRewardPanel:closePanel()
	if self.isDisposed then
		return
	end
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
	if self.onCloseCallback then
		self.onCloseCallback()
	end
end

function InitRewardPanel:onCloseBtnTapped( ... )
    self:closePanel()
end

function InitRewardPanel:unloadRequiredResource()

end

return InitRewardPanel