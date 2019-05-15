UnlockBlockerAndPlayPanel = class(BasePanel)

function UnlockBlockerAndPlayPanel:create(areaId)
    local instance = UnlockBlockerAndPlayPanel.new()
    instance:loadRequiredResource(PanelConfigFiles.unlock_cloud_panel_new)
    instance.areaId = areaId
    instance:init()
    return instance
end

function UnlockBlockerAndPlayPanel:init()
    local name = 'area_unlock/unlock_blocker_and_play_panel'
    local ui = self.builder:buildGroup(name)
    self.panelLuaName = "UnlockBlockerAndPlayPanel"
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

    self.btn = GroupButtonBase:create(self.ui.btn)
    self.btn:setString('去闯关')
    self.btn:ad(DisplayEvents.kTouchTap, function() self:onBtnTapped() end)
end

function UnlockBlockerAndPlayPanel:onBtnTapped()
    self:removeSelf()
    HomeScene:sharedInstance().worldScene:startLevel(UserManager:getInstance().user:getTopLevelId())
end

function UnlockBlockerAndPlayPanel:removeSelf()
    PopoutManager:sharedInstance():remove(self)
end

function UnlockBlockerAndPlayPanel:popoutShowTransition()
    self:setPositionForPopoutManager()
end

function UnlockBlockerAndPlayPanel:popout()

    if AutoPopout:isInNextLevelMode() then
        PopoutManager:sharedInstance():add(self)
        self:setPositionForPopoutManager()
    else
        PopoutQueue:sharedInstance():push(self)
    end 

--    PopoutQueue:sharedInstance():push(self)
end
