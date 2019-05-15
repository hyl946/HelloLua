local CheckCancelPanel = require "zoo.payment.paycheck.CheckCancelPanel"

local CheckMainPanel = class(BasePanel)

function CheckMainPanel:ctor()
end

function CheckMainPanel:init()
	self.ui = self:buildInterfaceGroup("manual_order_check/CheckMainPanel")
    BasePanel.init(self, self.ui)

    self.tip = self.ui:getChildByName("tip")

    self.btnCheck = GroupButtonBase:create(self.ui:getChildByName('btnCheck'))
	self.btnCheck:setString('刷新')
	self.btnCheck:addEventListener(DisplayEvents.kTouchTap, function ()
		self:onCheckBtnTap()
	end)

	self.btnCancel = self.ui:getChildByName("btnCancel")
	self.btnCancel:setTouchEnabled(true)
	self.btnCancel:setButtonMode(true)
	self.btnCancel:addEventListener(DisplayEvents.kTouchTap,  function ()
		self:onCancelBtnTap()
	end)
end

function CheckMainPanel:setButtonsEnable(isEnable)
	if self.btnCheck then self.btnCheck:setEnabled(isEnable)	end
	if self.btnCancel then self.btnCancel:setTouchEnabled(isEnable) end
end

function CheckMainPanel:onCheckBtnTap()
	self:setButtonsEnable(false)
	setTimeOut(function ()
		if self.isDisposed then return false end
		self:setButtonsEnable(true)
	end, 3)
	if self.checkCallback then self.checkCallback() end
end

function CheckMainPanel:onCancelBtnTap()
	local context = self
	local cancelPanel = CheckCancelPanel:create()
	cancelPanel:setTipShow(localize("payment.delay.optimization.cancel"))
	cancelPanel:setConfirmCallback(function ()
		context:remove()
		if context.cancelCallback then context.cancelCallback() end
	end)
	cancelPanel:setCancelCallback(function ()
	end)
	cancelPanel:popout()
end

function CheckMainPanel:popout()
	PopoutManager:sharedInstance():add(self, true, false)
	local parent = self:getParent()
	if parent then
		self:setToScreenCenterHorizontal()
		self:setToScreenCenterVertical()		
	end
end

function CheckMainPanel:remove()
	PopoutManager:sharedInstance():remove(self, true)
end

function CheckMainPanel:setTipShow(tipStr)
	if self.tip then self.tip:setString(tipStr) end
end

function CheckMainPanel:setCheckCallback(checkCallback)
	self.checkCallback = checkCallback
end

function CheckMainPanel:setCancelCallback(cancelCallback)
	self.cancelCallback = cancelCallback
end

function CheckMainPanel:create()
	local panel = CheckMainPanel.new()
	panel:loadRequiredResource("ui/ManualOrderCheck.json")
	panel:init()
	return panel
end

return CheckMainPanel