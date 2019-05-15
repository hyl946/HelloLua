CDkeyRewardPanel = class(BasePanel)

function CDkeyRewardPanel:create()
	local s = CDkeyRewardPanel.new()
	s:loadRequiredResource(PanelConfigFiles.cd_key_exchange_panel)
	s:init()
	return s
end

function CDkeyRewardPanel:init( ... )
	-- body
	self.ui	= self:buildInterfaceGroup("exchange_reward_panel")
	BasePanel.init(self, self.ui)
	self.ui:setTouchEnabled(true, 0, true)

	self.ui:getChildByName("tip"):setString(
		Localization:getInstance():getText("exchangecode.list.description1"))

	self.ui:getChildByName("time_tip"):setString(
		Localization:getInstance():getText("exchangecode.list.description2"))

	function onOkBtnTapped( ... )
		-- body
		self:onOkBtnTapped()
	end
	self.okBtn = GroupButtonBase:create(self.ui:getChildByName("okBtn"))
	self.okBtn:setString(Localization:getInstance():getText("exchangecode.button"))
	self.okBtn:addEventListener(DisplayEvents.kTouchTap, onOkBtnTapped)
	self.okBtn:useBubbleAnimation()

	self.closeBtn = self.ui:getChildByName("close_btn")
	self.closeBtn:setTouchEnabled(true, 0, false)
	self.closeBtn:setButtonMode(true)
	self.closeBtn:addEventListener(DisplayEvents.kTouchTap,  
		function(event) self:onCloseBtnTapped(event) end)

	self:initRewardList()
end

function CDkeyRewardPanel:initRewardList( ... )
	-- body
	local container = self.ui:getChildByName("rect_list")
	local bg = container:getChildByName("bg")
	bg:setVisible(false)
	local size = bg:getGroupBounds().size
	local pos = bg:getPosition()
	local layout = VerticalTileLayout:create(size.width)
	local scroll = VerticalScrollable:create(size.width, size.height, true, true)
	scroll:setPosition(ccp(pos.x, pos.y))
	container:addChild(scroll)

	local list = CDKeyManager:getInstance():getAllRewards()

	for k = #list, 1, -1 do
		local ui = self:buildInterfaceGroup("rewardCell")
		local data = list[k]
		local item = ItemInLayout:create()
		ui:getChildByName("reward_name"):setString(data:getMaterialDesc() )
		ui:getChildByName("end_time"):setString(data:getEndTimeString())
		item:setContent(ui)
		layout:addItem(item)
	end

	local fix_n = 3 - #list 
	if fix_n > 0 then
		for k = 1, fix_n do
			local ui = self:buildInterfaceGroup("rewardCell")
			local item = ItemInLayout:create()
			ui:getChildByName("reward_name"):setString("f" )
			ui:getChildByName("end_time"):setString("f")
			ui:getChildByName("reward_name"):setVisible(false)
			ui:getChildByName("end_time"):setVisible(false)
			item:setContent(ui)
			layout:addItem(item)
		end
	end

	scroll:setContent(layout)
end

function CDkeyRewardPanel:onOkBtnTapped( ... )
	-- body
	CDKeyManager:getInstance():showCollectInfoPanel()
end

function CDkeyRewardPanel:onCloseBtnTapped(event, ...)
	assert(event)
	assert(#{...} == 0)

	if not self.isOnCloseBtnTappedCalled then
		self.isOnCloseBtnTappedCalled = true
		self:remove()
	end
end

function CDkeyRewardPanel:popout()
	local function onAnimOver()
		self.allowBackKeyTap = true
	end
	PopoutManager:sharedInstance():add(self, true, false)
	self:setToScreenCenterHorizontal()
	self:setToScreenCenterVertical()
end

function CDkeyRewardPanel:remove(...)
	PopoutManager:sharedInstance():remove(self, true)

	if self.closeCallback then
		self.closeCallback()
	end
end