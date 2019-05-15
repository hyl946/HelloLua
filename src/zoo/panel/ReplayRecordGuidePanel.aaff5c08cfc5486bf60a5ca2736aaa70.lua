ReplayRecordGuidePanel = class(BasePanel)

function ReplayRecordGuidePanel:create( showInDescPanel )
	local panel = ReplayRecordGuidePanel.new()
	panel:init(showInDescPanel)
	return panel
end

function ReplayRecordGuidePanel:init(showInDescPanel)
	self:loadRequiredResource("ui/replay_record_guide.json")
    self.ui = self:buildInterfaceGroup("recordGuidePanel")
    BasePanel.init(self, self.ui)

    local function onCloseButtonTapped()
        if type(self.onCloseCallback) == "function" then
            self.onCloseCallback()
        end
    	self:closePanel()
    end

    local closeBtn = self.ui:getChildByName("closeBtn")
	closeBtn:setTouchEnabled(true)
	closeBtn:setButtonMode(true)
    closeBtn:addEventListener(DisplayEvents.kTouchTap, onCloseButtonTapped)

    local function onOkButtonTapped()
        if type(self.onConfirmCallback) == "function" then
            self.onConfirmCallback()
        end
        self:closePanel()
    end
    local okBtn = GroupButtonBase:create( self.ui:getChildByName("okBtn") )

    if showInDescPanel then
        okBtn:setString(Localization:getInstance():getText("give.back.panel.button.notification"))
    else
        okBtn:setString(Localization:getInstance():getText("record.panel.button"))
    end
    okBtn:addEventListener(DisplayEvents.kTouchTap, onOkButtonTapped)

    local content = self.ui:getChildByName("content")
    local contentBounds = content:getGroupBounds()
    local vScrollable = VerticalScrollable:create(contentBounds.size.width, contentBounds.size.height, true)
    vScrollable:setPosition(ccp(contentBounds.origin.x, contentBounds.origin.y + contentBounds.size.height))
    self.ui:addChildAt(vScrollable, content:getZOrder())

    local recordGuideContent = self:buildInterfaceGroup("recordGuideContent")
    vScrollable:setContent(recordGuideContent)

    recordGuideContent:getChildByName("guide1"):getChildByName("desc"):setString(Localization:getInstance():getText("record.panel.description1"))
    recordGuideContent:getChildByName("guide2"):getChildByName("desc"):setString(Localization:getInstance():getText("record.panel.description2"))
    recordGuideContent:getChildByName("guide3"):getChildByName("desc"):setString(Localization:getInstance():getText("record.panel.description3"))

    self:scaleAccordingToResolutionConfig()

    content:removeFromParentAndCleanup(true)
    content = nil
end

function ReplayRecordGuidePanel:popout(onCloseCallback, onConfirmCallback)
	self:setPositionForPopoutManager()
	PopoutManager:sharedInstance():add(self, true, false)
	self.allowBackKeyTap = true

    self.onCloseCallback = onCloseCallback
    self.onConfirmCallback = onConfirmCallback
end

function ReplayRecordGuidePanel:closePanel()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
    self.onCloseCallback = nil
    self.onConfirmCallback = nil
end