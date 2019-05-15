--帮闯关说明
AskForHelpExplain = class(BasePanel)

function AskForHelpExplain:create()
	local panel = AskForHelpExplain.new()
    panel:loadRequiredResource(PanelConfigFiles.request_message_panel)
    panel:init()
    return panel
end

function AskForHelpExplain:init()
	local ui = self:buildInterfaceGroup("ask_for_help_explain")
	BasePanel.init(self, ui)

	self.title_tf = self.ui:getChildByName("title_tf")
	self.info1_tf = self.ui:getChildByName("info1_tf")
	self.info2_tf = self.ui:getChildByName("info2_tf")
	self.info3_tf = self.ui:getChildByName("info3_tf")
	self.close_btn = self.ui:getChildByName("close_btn")

	self.title_tf:setString(localize("message.panel.askforhelp.explain.title"))
	self.info1_tf:setString(localize("message.panel.askforhelp.explain.info1"))
	self.info2_tf:setString(localize("message.panel.askforhelp.explain.info2"))
	self.info3_tf:setString(localize("message.panel.askforhelp.explain.info3"))
	self.close_btn:setTouchEnabled(true)
	self.close_btn:ad(DisplayEvents.kTouchTap, function()
		self:onCloseBtnTapped()
	end)
end

function AskForHelpExplain:onCloseBtnTapped()
	if self.isDisposed then return end
    self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
end

function AskForHelpExplain:popout()
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
    PopoutManager:sharedInstance():add(self, true)
    self.allowBackKeyTap = true
end

--帮闯关记录
AskForHelpRecord = class(BasePanel)

function AskForHelpRecord:create()
	local panel = AskForHelpRecord.new()
    panel:loadRequiredResource(PanelConfigFiles.request_message_panel)
    panel:init()
    return panel
end

function AskForHelpRecord:init()
	local ui = self:buildInterfaceGroup("ask_for_help_record")
	BasePanel.init(self, ui)

	--self.title_tf = self.ui:getChildByName("title_tf")
	self.info1_tf = self.ui:getChildByName("info1_tf")
	self.info2_tf = self.ui:getChildByName("info2_tf")
	self.info3_tf = self.ui:getChildByName("info3_tf")
	self.no1_tf = self.ui:getChildByName("no1_tf")
	self.no2_tf = self.ui:getChildByName("no2_tf")
	self.close_btn = self.ui:getChildByName("close_btn")

	--self.title_tf:setString(localize("message.panel.askforhelp.record.title"))
	self.info2_tf:setString(localize("message.panel.askforhelp.record.info2"))
	self.no1_tf:setString(localize("message.panel.askforhelp.record.no"))
	self.no2_tf:setString(localize("message.panel.askforhelp.record.no"))

	self.close_btn:setTouchEnabled(true)
	self.close_btn:ad(DisplayEvents.kTouchTap, function()
		self:onCloseBtnTapped()
	end)

	self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()

    self.dailyScrollable = VerticalScrollable:create(530, 185, true, false)
    self.dailyScrollable.name = "dailyScrollable"
    self.dailyScrollable:setIgnoreHorizontalMove(false)
    self.dailyScrollable:setPosition(ccp(70, -170))
    self:addChild(self.dailyScrollable)
    self.dailyPage = VerticalTileLayout:create(530)
    self.dailyScrollable:setContent(self.dailyPage)
    self.dailyPage:setItemVerticalMargin(15)

    self.weekScrollable = VerticalScrollable:create(530, 185, true, false)
    self.weekScrollable.name = "weekScrollable"
    self.weekScrollable:setIgnoreHorizontalMove(false)
    self.weekScrollable:setPosition(ccp(70, -440))
    self:addChild(self.weekScrollable)
    self.weekPage = VerticalTileLayout:create(530)
    self.weekScrollable:setContent(self.weekPage)
end

function AskForHelpRecord:setData(data)
	local dailyHelpCount = 0
	local totalHelpCount = 0
	local dailyHelps = {}
	local weekHelps = {}
	if data.dailyHelpOtherCount then dailyHelpCount = data.dailyHelpOtherCount end
	if data.totalHelpOtherCount then totalHelpCount = data.totalHelpOtherCount end
	if data.recentHelpOtherRecords then 
		for _, record in pairs(data.recentHelpOtherRecords) do
			if record.day == math.floor((Localhost:timeInSec() + 8 * 3600) / (24 * 3600)) then 
				table.insert(dailyHelps, record)
			else
				table.insert(weekHelps, record)
			end
		end
	end

	local totalCount = AskForHelpManager.getInstance():getConfig():getMaxDailyHelpOtherCount()
	self.info1_tf:setString(localize("message.panel.askforhelp.record.info1", {n1 = dailyHelpCount, n2 = (totalCount - dailyHelpCount)}))
	self.info3_tf:setString(localize("message.panel.askforhelp.record.info3", {n = totalHelpCount}))
	if #dailyHelps > 0 then 
		self.dailyPage:setVisible(true)
		self.no1_tf:setVisible(false)
		for _, record in pairs(dailyHelps) do
			local render = self:getRender(record)
			self.dailyPage:addItem(render)
			self.dailyScrollable:updateScrollableHeight()
		end
	else
		self.dailyPage:setVisible(false)
		self.no1_tf:setVisible(true)
	end

	if #weekHelps > 0 then 
		self.weekPage:setVisible(true)
		self.no2_tf:setVisible(false)
		for _, record in pairs(weekHelps) do
			local render = self:getRender(record)
			self.weekPage:addItem(render)
			self.weekScrollable:updateScrollableHeight()
		end
	else
		self.weekPage:setVisible(false)
		self.no2_tf:setVisible(true)
	end
end

function AskForHelpRecord:onCloseBtnTapped()
	if self.isDisposed then return end
    self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
end

function AskForHelpRecord:popout()
    PopoutManager:sharedInstance():add(self, true)
    self.allowBackKeyTap = true
end

function AskForHelpRecord:getRender(record, isShowDate)
    local ui = self:buildInterfaceGroup("ask_for_help_record_item")
    local item = ItemInLayout:create()
    local info1_tf = ui:getChildByName('info1_tf')
    --local info2_tf = ui:getChildByName('info2_tf')
    item:setContent(ui)

    local key
	if record.success then
		key = "message.panel.askforhelp.record.success"
	else
		key = "message.panel.askforhelp.record.fail"
	end
	local helpName = FriendManager.getInstance():getFriendName(record.uid)
	if string.find(helpName, "ID:") then helpName = "消消乐玩家" end
	helpName = TextUtil:ensureTextWidth(helpName, info1_tf:getFontSize(), CCSizeMake(145, 0))
	info1_tf:setString(localize(key, {name = helpName, level = record.levelId, count = record.failCount}))
	--local helpDate = os.date("%y/%m/%d", record.day * 24 * 60 *60)
	--if isShowDate then info2_tf:setString(helpDate) end

	return item
end