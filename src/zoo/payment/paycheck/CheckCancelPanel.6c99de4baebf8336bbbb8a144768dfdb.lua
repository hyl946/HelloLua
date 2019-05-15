local CheckCancelPanel = class(BasePanel)

function CheckCancelPanel:ctor()
end

function CheckCancelPanel:init()
	self.ui = self:buildInterfaceGroup("manual_order_check/CheckCancelPanel")
    BasePanel.init(self, self.ui)

    self.tip = self.ui:getChildByName("tip")

    self.btnConfirm = GroupButtonBase:create(self.ui:getChildByName('btnConfirm'))
	self.btnConfirm:setString('确定')
	self.btnConfirm:addEventListener(DisplayEvents.kTouchTap, function ()
		self:onConfirmBtnTap()
	end)

    self.btnCancel = GroupButtonBase:create(self.ui:getChildByName('btnCancel'))
    self.btnCancel:setColorMode(kGroupButtonColorMode.grey)
	self.btnCancel:setString('取消')
	self.btnCancel:addEventListener(DisplayEvents.kTouchTap, function ()
		self:onCancelBtnTap()
	end)
end

function CheckCancelPanel:onConfirmBtnTap()
	self:remove()
	if self.confirmCallback then self.confirmCallback() end
end

function CheckCancelPanel:onCancelBtnTap()
	self:remove()
	if self.cancelCallback then self.cancelCallback() end
end

function CheckCancelPanel:popout()
	PopoutManager:sharedInstance():add(self, true, false)
	local parent = self:getParent()
	if parent then
		self:setToScreenCenterHorizontal()
		self:setToScreenCenterVertical()		
	end
end

function CheckCancelPanel:remove()
	PopoutManager:sharedInstance():remove(self, true)
end

function CheckCancelPanel:setTipShow(tipStr)
	if self.tip then self.tip:setString(tipStr) end
end

function CheckCancelPanel:setConfirmCallback(confirmCallback)
	self.confirmCallback = confirmCallback
end

function CheckCancelPanel:setCancelCallback(cancelCallback)
	self.cancelCallback = cancelCallback
end

function CheckCancelPanel:create()
	local panel = CheckCancelPanel.new()
	panel:loadRequiredResource("ui/ManualOrderCheck.json")
	panel:init()
	return panel
end

return CheckCancelPanel