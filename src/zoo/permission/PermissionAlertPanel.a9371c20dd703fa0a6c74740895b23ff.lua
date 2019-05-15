
local PermissionAlertPanel = class(BasePanel)

function PermissionAlertPanel:create(permissionKey, onGotoSetting, onClose)
    local panel = PermissionAlertPanel.new()
    panel:loadRequiredResource("ui/PermissionAlertPanel.json")
    panel:init(permissionKey, onGotoSetting, onClose)
    return panel
end

function PermissionAlertPanel:init(permissionKey, onGotoSetting, onClose)
    local ui = self:buildInterfaceGroup("permission_alert_panel/Panel")
	BasePanel.init(self, ui)
    self.closeBtn = self.ui:getChildByName('closeBtn')
    self.closeBtn:setTouchEnabled(true, 0, true)
    self.closeBtn:ad(DisplayEvents.kTouchTap, function () 
    	if onClose then onClose() end
    	self:onCloseBtnTapped() 
    end)

    self.ui:getChildByName('label'):setString(localize("permission.desc." .. permissionKey))

    local btn = self.ui:getChildByName('btn')
    btn = GroupButtonBase:create(btn)
    btn:setString('去设置')
    btn:ad(DisplayEvents.kTouchTap, function ()
    	if onGotoSetting then onGotoSetting() end
    	self:onCloseBtnTapped() 
    end)
end

function PermissionAlertPanel:popout()
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
	PopoutManager:sharedInstance():add(self, true)
	self.allowBackKeyTap = true
end

function PermissionAlertPanel:onCloseBtnTapped()
   	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
end

return PermissionAlertPanel
