local QQAccountConfirmPanel = class(BasePanel)

function QQAccountConfirmPanel:create()
	local panel = QQAccountConfirmPanel.new()
	panel:loadRequiredResource("ui/account_confirm_panels.json")
	panel:init()

	return panel
end

function QQAccountConfirmPanel:init()
	self.ui = self:buildInterfaceGroup("QQAccountConfirmPanel")
    BasePanel.init(self, self.ui)

    self:initCloseButton()
    self:initContent()
end

function QQAccountConfirmPanel:initContent()

	local labelContent = self.ui:getChildByName("content")
	labelContent:setString(localize("login.panel.warning.new5"))

	local btnAccountSetting = GroupButtonBase:create(self.ui:getChildByName("btnAccountSetting"))
    btnAccountSetting:setString("查看账号")
    btnAccountSetting:ad(DisplayEvents.kTouchTap, function() 
    		self:onCloseBtnTapped()
            --goto popout the account settings panel.
            local panel = AccountSettingPanel:create()
            panel:popout()
    	end)

	local btnLogin = GroupButtonBase:create(self.ui:getChildByName("btnLogin"))
    btnLogin:setString("重新登录")
    btnLogin:ad(DisplayEvents.kTouchTap, function()
            self:onCloseBtnTapped()

    		if self.reloginCallback then
                self.reloginCallback()
            end
    	end)
end

function QQAccountConfirmPanel:setReloginCallback(reloginCallback)
    self.reloginCallback = reloginCallback
end

function QQAccountConfirmPanel:setCancelCallback(cancelCallback)
    self.cancelCallback = cancelCallback
end

function QQAccountConfirmPanel:initCloseButton()
	self.closeBtn = self.ui:getChildByName("btnClose")
    self.closeBtn:setTouchEnabled(true, 0, true)
    self.closeBtn:setButtonMode(true)
    self.closeBtn:addEventListener(DisplayEvents.kTouchTap, 
        function() 
            self:onCloseBtnTapped()
        end)
end

function QQAccountConfirmPanel:onKeyBackClicked(...)
	BasePanel.onKeyBackClicked(self)
end

function QQAccountConfirmPanel:popout()
	self:setPositionForPopoutManager()
	self.allowBackKeyTap = true
	PopoutManager:sharedInstance():add(self, true, false)
end

function QQAccountConfirmPanel:popoutShowTransition()
	self.allowBackKeyTap = true
end

function QQAccountConfirmPanel:onCloseBtnTapped()
	PopoutManager:sharedInstance():remove(self, true)
    if self.cancelCallback then
        self.cancelCallback()
    end
end


return QQAccountConfirmPanel