SeasonWeeklyRaceRulePanel = class(BasePanel)

function SeasonWeeklyRaceRulePanel:create()
	local panel = SeasonWeeklyRaceRulePanel.new()
	panel:init()
	return panel
end

function SeasonWeeklyRaceRulePanel:init()
	self:loadRequiredResource("ui/summer_weekly_rule_panel.json")
	local ui = self:buildInterfaceGroup("SummerWeeklyRaceRulePanel/RulePanel")
	BasePanel.init(self, ui)

	local close = ui:getChildByName("close")
	close:setTouchEnabled(true)
	close:setButtonMode(true)
	close:addEventListener(DisplayEvents.kTouchTap, function() self:onCloseBtnTapped() end)

	local size = ui:getChildByName("size")
	size:setVisible(false)
	local sSize = size:getGroupBounds().size
	sSize = {width = sSize.width, height = sSize.height}

	self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()

	local pager = self:createPager(ui:getChildByName("pager"))

	local pagedView = PagedView:create(sSize.width, sSize.height, 2, pager, true, false)
    pagedView:setIgnoreVerticalMove(false)
    pagedView:setPositionXY(size:getPositionX(), size:getPositionY() - sSize.height)
    ui:addChildAt(pagedView, ui:getChildIndex(size))
    self.pagedView = pagedView

    local rule1 = ui:getChildByName("rule1")
    rule1:getChildByName("title"):setString(Localization:getInstance():getText("weeklyrace.winter.panel.detail.title1"))
    rule1:getChildByName("text1"):setString(Localization:getInstance():getText("weeklyrace.winter.panel.detail1"))
    rule1:getChildByName("text2"):setString(Localization:getInstance():getText("weeklyrace.winter.panel.detail2"))
    rule1:getChildByName("text3"):setString(Localization:getInstance():getText("weeklyrace.winter.panel.detail3"))
    local rSize = rule1:getGroupBounds().size
    rule1:setPositionXY(sSize.width - rSize.width / self:getScale(), 0)
    rule1:removeFromParentAndCleanup(false)
    pagedView:addPageAt(rule1, 1)

    local rule2 = ui:getChildByName("rule2")
    rule2:setPositionXY(0, 0)
    rule2:removeFromParentAndCleanup(false)
    rule2:getChildByName("title"):setString(Localization:getInstance():getText("weeklyrace.winter.panel.detail.title2"))
    local icon = rule2:getChildByName("icon")
	icon:setVisible(false)
	local text = rule2:getChildByName("text")
	text:setVisible(false)
	local delta = text:getPositionY() - icon:getPositionY()
	local dimensions = text:getDimensions()
	local totalHeight = text:getPositionY()
	local idx = {4, 5, 6, 7, 8, 9}
	for i = 1, #idx do
		local field = TextField:create(nil, nil, 24)
		field:setColor(text:getColor())
		field:setDimensions(CCSizeMake(dimensions.width, 0))
		field:setAnchorPoint(ccp(0, 1))
		field:setPositionXY(text:getPositionX(), totalHeight)

		field:setString(Localization:getInstance():getText("weeklyrace.winter.panel.detail"..tostring(idx[i]),
			{num = SeasonWeeklyRaceManager:getInstance():getRankMinScore(), n="\n"}))

		rule2:addChild(field)
		local sprite = Sprite:createWithSpriteFrameName("SummerWeeklyRaceRulePanel/img/watermelon_img0000")
		sprite:setAnchorPoint(ccp(0, 1))
		sprite:setPositionXY(icon:getPositionX(), totalHeight - delta)
		rule2:addChild(sprite)
		local height = sprite:getGroupBounds().size.height - delta
		if height < field:getContentSize().height then
			height = field:getContentSize().height
		end
		totalHeight = totalHeight - height - 30
	end
	if -totalHeight > sSize.height then
		local scroll = VerticalScrollable:create(sSize.width, sSize.height, false)
		scroll:setIgnoreHorizontalMove(false)
		local layout = ItemInLayout:create()
		layout:setContent(rule2)
		layout:setHeight(-totalHeight)
		scroll:setContent(layout)
		scroll:updateScrollableHeight()
		local rSize = scroll:getGroupBounds().size
    	scroll:setPositionXY(sSize.width - rSize.width / self:getScale(), 0)
		pagedView:addPageAt(scroll, 2)
	else
		local rSize = rule2:getGroupBounds().size
    	rule2:setPositionXY(sSize.width - rSize.width / self:getScale(), 0)
		pagedView:addPageAt(rule2, 2)
	end

	pagedView:gotoPage(1)
end

function SeasonWeeklyRaceRulePanel:createPager(ui)
	local count, items = 1, {}
	while true do
		local item = ui:getChildByName("item"..tostring(count))
		if not item then break end
		local numi = item:getChildByName("numi")
		numi:setString(tostring(count))
		local numa = item:getChildByName("numa")
		numa:setString(tostring(count))
		local bgi = item:getChildByName("bgi")
		local bga = item:getChildByName("bga")

		item.setActive = function(self, active)
			bga:setVisible(active)
			bgi:setVisible(not active)
			numa:setVisible(active)
			numi:setVisible(not active)
		end
		item.setEnabled = function(self, value)
			bgi:setTouchEnabled(true)
		end

		bgi:addEventListener(DisplayEvents.kTouchTap, function() ui:setActive(true) end)

		table.insert(items, item)
		count = count + 1
	end

	local context = self
	ui.addPage = function(self) end
	ui.next = function(self) self:goto() end
	ui.prev = function(self) self:goto() end
	ui.goto = function(self)
		for i, v in ipairs(items) do
			v:setActive(i == context.pagedView:getPageIndex())
		end
	end
	ui.setEnabled = function(self, enabled)
		for i, v in ipairs(items) do
			v:setEnabled(enabled)
		end
	end
	
	return ui
end

function SeasonWeeklyRaceRulePanel:popout()
	PopoutManager:sharedInstance():add(self, true)
	self.allowBackKeyTap = true
end

function SeasonWeeklyRaceRulePanel:onCloseBtnTapped()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
end