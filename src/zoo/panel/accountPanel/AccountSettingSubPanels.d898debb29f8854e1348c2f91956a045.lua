

ChangePhonePromptPanel = class(BasePanel)
UnbindAccountPromptPanel = class(BasePanel)


function ChangePhonePromptPanel:create(confirmCallback, cancelCallback)
    local instance = ChangePhonePromptPanel.new()
    instance:loadRequiredResource(PanelConfigFiles.panel_game_setting)
    instance:init(confirmCallback, cancelCallback)
    return instance
end

function ChangePhonePromptPanel:popout()
    PopoutManager:sharedInstance():addWithBgFadeIn(self, true, false)
    local vs = Director:sharedDirector():getVisibleSize()
    local vo = Director:sharedDirector():getVisibleOrigin()
    self:setPositionX(vs.width / 2 - self:getGroupBounds().size.width / 2)
    self:setPositionY(-(vs.height / 2 - self:getGroupBounds().size.height / 2))
end

function ChangePhonePromptPanel:init(confirmCallback, cancelCallback)
    self.confirmCallback = confirmCallback
    self.cancelCallback = cancelCallback
    self.ui = self:buildInterfaceGroup('changePhonePromptPanel')
    BasePanel.init(self, self.ui)
    self.ui:getChildByName('desLabel'):setString(Localization:getInstance():getText('setting.alert.content.1'))
    self.cancelBtn = GroupButtonBase:create(self.ui:getChildByName('cancelBtn'))
    self.cancelBtn:setColorMode(kGroupButtonColorMode.blue)
    self.cancelBtn:setString(Localization:getInstance():getText('button.cancel'))
    self.cancelBtn:ad(DisplayEvents.kTouchTap, 
        function ()  
            PopoutManager:sharedInstance():remove(self, true)
            if self.cancelCallback then self.cancelCallback() end
        end)
    self.confirmBtn = GroupButtonBase:create(self.ui:getChildByName('confirmBtn'))
    self.confirmBtn:setColorMode(kGroupButtonColorMode.green)
    self.confirmBtn:setString(Localization:getInstance():getText('setting.panel.button.6'))
    self.confirmBtn:ad(DisplayEvents.kTouchTap, 
        function () 
            PopoutManager:sharedInstance():remove(self, true)
            if self.confirmCallback then self.confirmCallback() end
        end)
end

function UnbindAccountPromptPanel:create(confirmCallback, cancelCallback)
    local instance = UnbindAccountPromptPanel.new()
    instance:loadRequiredResource(PanelConfigFiles.panel_game_setting)
    instance:init(confirmCallback, cancelCallback)
    return instance
end

function UnbindAccountPromptPanel:popout()
    PopoutManager:sharedInstance():addWithBgFadeIn(self, true, false)
    local vs = Director:sharedDirector():getVisibleSize()
    local vo = Director:sharedDirector():getVisibleOrigin()
    self:setPositionX(vs.width / 2 - self:getGroupBounds().size.width / 2)
    self:setPositionY(-(vs.height / 2 - self:getGroupBounds().size.height / 2))
end

function UnbindAccountPromptPanel:init(confirmCallback, cancelCallback)
    self.confirmCallback = confirmCallback
    self.cancelCallback = cancelCallback
    self.ui = self:buildInterfaceGroup('unbingAccountPromtPanel')
    BasePanel.init(self, self.ui)
    self.ui:getChildByName('panelTitle'):setString(Localization:getInstance():getText('setting.panel.button.5'))
    self.ui:getChildByName('desLabel'):setString(
        Localization:getInstance():getText('setting.alert.content.4') ..'\n\n' .. Localization:getInstance():getText('setting.alert.content.5')
        )
    self.cancelBtn = GroupButtonBase:create(self.ui:getChildByName('cancelBtn'))
    self.cancelBtn:setColorMode(kGroupButtonColorMode.blue)
    self.cancelBtn:setString(Localization:getInstance():getText('button.cancel'))
    self.cancelBtn:ad(DisplayEvents.kTouchTap, 
        function ()  
            PopoutManager:sharedInstance():remove(self, true)
            if self.cancelCallback then self.cancelCallback() end
        end)
    self.confirmBtn = GroupButtonBase:create(self.ui:getChildByName('confirmBtn'))
    self.confirmBtn:setColorMode(kGroupButtonColorMode.green)
    self.confirmBtn:setString(Localization:getInstance():getText('button.ok'))
    self.confirmBtn:ad(DisplayEvents.kTouchTap, function() self:onConfirmBtnTapped() end)
end

function UnbindAccountPromptPanel:onConfirmBtnTapped()
    if not self.confirmedOnce then
        self.confirmedOnce = true
        self.ui:getChildByName('secondConfirmMessage'):setString(Localization:getInstance():getText('setting.alert.content.6'))
    else
        PopoutManager:sharedInstance():remove(self, true)
        if self.confirmCallback then
            self.confirmCallback()
        end
    end
end
