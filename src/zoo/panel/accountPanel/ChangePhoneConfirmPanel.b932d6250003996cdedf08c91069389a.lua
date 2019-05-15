ChangePhoneConfirmPanel = class(BasePanel)

function ChangePhoneConfirmPanel:create()
	local panel = ChangePhoneConfirmPanel.new()
	panel:loadRequiredResource("ui/account_confirm_panels.json")
	panel:init()

	return panel
end

function ChangePhoneConfirmPanel:init( ... )
    self.ui = self:buildInterfaceGroup('ChangePhoneConfirmPanel')
    BasePanel.init(self, self.ui)

    self.ui:getChildByName("text"):setString(Localization:getInstance():getText('setting.alert.content.1'))

	local okBtn = GroupButtonBase:create(self.ui:getChildByName("okBtn"))
	okBtn:setString(Localization:getInstance():getText('setting.panel.button.6'))
	okBtn:addEventListener(DisplayEvents.kTouchTap,function( ... )
		if self.okCallback then
			self.okCallback()
		end

		self:remove()
	end)

	local cancelBtn = GroupButtonBase:create(self.ui:getChildByName("cancelBtn"))
	cancelBtn:setString(Localization:getInstance():getText('button.cancel'))
	cancelBtn:setColorMode(kGroupButtonColorMode.blue)
	cancelBtn:addEventListener(DisplayEvents.kTouchTap,function( ... )
		if self.cancelCallback then
			self.cancelCallback()
		end

		self:remove()
	end)

end

function ChangePhoneConfirmPanel:setOkCallback( okCallback )
	self.okCallback = okCallback
end

function ChangePhoneConfirmPanel:setCancelCallback( cancelCallback )
	self.cancelCallback = cancelCallback
end

local visibleSize = Director.sharedDirector():getVisibleSize()
function ChangePhoneConfirmPanel:popout( ... )
	local bounds = self.ui:getChildByName("bg"):getGroupBounds()

	self:setPosition(ccp(
		visibleSize.width/2 - bounds.size.width/2,
		-visibleSize.height/2 + bounds.size.height/2
	))

	PopoutManager:add(self, true, false)
end

function ChangePhoneConfirmPanel:remove( ... )
	PopoutManager:sharedInstance():remove(self, true)
end
