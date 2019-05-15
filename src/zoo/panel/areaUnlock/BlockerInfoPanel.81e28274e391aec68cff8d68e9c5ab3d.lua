BlockerInfoPanel = class(BasePanel)

function BlockerInfoPanel:create(areaId)
    local instance = BlockerInfoPanel.new()
    instance:loadRequiredResource(PanelConfigFiles.unlock_cloud_panel_new)
    instance.areaId = areaId
    instance:init()
    return instance
end

function BlockerInfoPanel:init()
    local name = 'area_unlock/show_new_blocker_panel'
    local ui = self.builder:buildGroup(name)
    BasePanel.init(self, ui)
    UIUtils:autoProperty(ui)

    local str = "area_icon_" .. self.areaId .. "0000"
    if CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(str) then
        self.blockerIcon = Sprite:createWithSpriteFrameName(str)
        self.blockerIcon:setAnchorPoint(ccp(0, 1))
        UIUtils:fitIconToPh(self.ui.ph:getParent(), self.ui.ph, self.blockerIcon)
        self.ui.blocker:setString(localize("area.blockerShow.clkTip.otherInfo.area" .. self.areaId))
        self.ui.name:setString(localize("area.blockerShow.clkTip.otherInfo.area.title" .. self.areaId))
    end

    self.ui.closeBtn:setTouchEnabled(true, 0, true)
    self.ui.closeBtn:setButtonMode(true)
    self.ui.closeBtn:ad(DisplayEvents.kTouchTap, function() self:onCloseBtnTapped() end)
end


function BlockerInfoPanel:popout()
    self.allowBackKeyTap = true
    self:setPositionForPopoutManager()
    PopoutManager:sharedInstance():add(self, true, false)
end

function BlockerInfoPanel:onCloseBtnTapped()
    self.allowBackKeyTap = false
    PopoutManager:sharedInstance():remove(self)
end

