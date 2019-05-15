UnlockTipPanel = class(BasePanel)

function UnlockTipPanel:create(areaId, blocker)
    local instance = UnlockTipPanel.new()
    instance:loadRequiredResource(PanelConfigFiles.unlock_cloud_panel_new)
    instance.areaId = areaId
    instance.blocker = blocker
    instance:init()
    return instance
end

function UnlockTipPanel:init()
    local name = 'area_unlock/unlock_tip_panel'
    if self.blocker then
        name = 'area_unlock/unlock_tip_panel_with_blocker'
    end
    local ui = self.builder:buildGroup(name)
    BasePanel.init(self, ui)
    UIUtils:autoProperty(ui)
    local notice_level = (self.areaId - 1) * 15
    self.ui:getChildByName('level'):setString(localize('unlock.tip.panel.level', {num = notice_level, n='\n'}))

    if self.blocker then
        local str = "area_icon_" .. self.areaId .. "0000"
        if CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(str) then
            self.blockerIcon = Sprite:createWithSpriteFrameName(str)
            self.blockerIcon:setAnchorPoint(ccp(0, 1))
            UIUtils:fitIconToPh(self.ui.ph:getParent(), self.ui.ph, self.blockerIcon)
            self.ui.blocker:setString(localize("area.blockerShow.clkTip.otherInfo.area" .. self.areaId))
            self.ui.name:setString(localize("area.blockerShow.clkTip.otherInfo.area.title" .. self.areaId))
        end
    end

    self.ui.closeBtn:setTouchEnabled(true, 0, true)
    self.ui.closeBtn:setButtonMode(true)
    self.ui.closeBtn:ad(DisplayEvents.kTouchTap, function() self:onCloseBtnTapped() end)
end

function UnlockTipPanel:popout()
    self.allowBackKeyTap = true
    self:setPositionForPopoutManager()
    PopoutManager:sharedInstance():add(self, true, false)
end

function UnlockTipPanel:onCloseBtnTapped()
    self.allowBackKeyTap = false
    PopoutManager:sharedInstance():remove(self)
end
