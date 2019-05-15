
local ConfirmPanel = class(BasePanel)

function ConfirmPanel:create(yesCallback, noCallback)
    local panel = ConfirmPanel.new()
    panel:loadRequiredResource("ui/LoginAlertPanel.json")
    panel:init(yesCallback, noCallback)
    return panel
end

function ConfirmPanel:init(yesCallback, noCallback)
    local ui = self:buildInterfaceGroup("LoginAlertPanel/confirm")
	BasePanel.init(self, ui)

	self.label = self.ui:getChildByName('label')
	self.label:setString(localize('login.alert.confirm.label'))

	self.yesBtn = 	GroupButtonBase:create(self.ui:getChildByName('yes'))
	self.noBtn = 	GroupButtonBase:create(self.ui:getChildByName('no'))
	self.noBtn:setColorMode(kGroupButtonColorMode.blue)

	self.yesBtn:ad(DisplayEvents.kTouchTap, function ( ... )
		self:_close()
		if yesCallback then
			yesCallback()
		end
	end)

	self.noBtn:ad(DisplayEvents.kTouchTap, function ( ... )
		self:onCloseBtnTapped()
		
	end)

	self.noCallback = noCallback

	self.yesBtn:setString('是')
	self.noBtn:setString('否')
end

function ConfirmPanel:_close()
	if self.isDisposed then return end
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)


end

function ConfirmPanel:popout()
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
	PopoutManager:sharedInstance():add(self, true)
	self.allowBackKeyTap = true
end

function ConfirmPanel:onCloseBtnTapped( ... )
    self:_close()

    if self.noCallback then
		self.noCallback()
	end
	
end

return ConfirmPanel
