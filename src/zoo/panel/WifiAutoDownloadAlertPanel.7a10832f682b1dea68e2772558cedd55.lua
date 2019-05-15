local WifiAutoDownloadAlertPanel = class(BasePanel)


function WifiAutoDownloadAlertPanel:create()
    local panel = WifiAutoDownloadAlertPanel.new()
    panel:loadRequiredResource("ui/wifi_auto_download.json")
    panel:init()
    return panel
end

function WifiAutoDownloadAlertPanel:init()
    local ui = self:buildInterfaceGroup("auto.wifi/panel")
    BasePanel.init(self, ui)
    self.closeBtn = self.ui:getChildByName('closeBtn')
    self.closeBtn:setTouchEnabled(true, 0, true)
    self.closeBtn:ad(DisplayEvents.kTouchTap, function () self:onCloseBtnTapped() end)

    self.label1 = self.ui:getChildByName('label1')
    self.label2 = self.ui:getChildByName('label2')

    self.label1:setString(localize('wifi.update.feature.desc1'))
    self.label2:setString(localize('wifi.update.feature.desc2')..localize('wifi.update.feature.desc3'))

    self.btn =  GroupButtonBase:create(self.ui:getChildByName('btn'))
    self.btn:setString(localize('wifi.update.feature.btn'))
    self.btn:ad(DisplayEvents.kTouchTap, function ( ... )
        self:_close()
    end)
end

function WifiAutoDownloadAlertPanel:_close()
    if self.isDisposed then return end
    self.allowBackKeyTap = false
    PopoutManager:sharedInstance():remove(self)
    if self.callback then
        self.callback()
    end
end

function WifiAutoDownloadAlertPanel:popout(callback)
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
    self:setPositionX(self:getPositionX() + 0)
    PopoutQueue:sharedInstance():push(self)
    self.allowBackKeyTap = true
    self.callback = callback
end

function WifiAutoDownloadAlertPanel:popoutNoQueue(callback)
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
    self:setPositionX(self:getPositionX() + 0)
    PopoutManager:sharedInstance():add(self, true)
    self.allowBackKeyTap = true
    self.callback = callback
end

function WifiAutoDownloadAlertPanel:onCloseBtnTapped( ... )
    self:_close()
end

return WifiAutoDownloadAlertPanel
