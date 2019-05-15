local SelectPanel = require 'zoo.panel.RealName.bind.SelectPanel'

local AdviceBindPanel = class(SelectPanel)

function AdviceBindPanel:create()
    local panel = AdviceBindPanel.new()
    panel:loadRequiredResource("ui/real_name.json")
    panel:init()
    return panel
end

function AdviceBindPanel:init()
    local ui = self:buildInterfaceGroup("realname/alert1")
	SelectPanel.init(self, ui)

	self:setCancelBtnString('换个号码')
	self:setConfirmBtnString('直接使用')

	self:setLabel('')
end

function AdviceBindPanel:setPhoneNumber( phoneNumber )
	if self.isDisposed then return end
	local shadowedPhoneNumber = self:shadowPhoneNumber(tostring(phoneNumber))
	local text = localize('authentication.feature.phone.bonding.text', {num = shadowedPhoneNumber}) 
	self:setLabel(text)
end

function AdviceBindPanel:shadowPhoneNumber( str )
	return str:gsub('(...)(....)(....)', '%1****%3')
end

function AdviceBindPanel:onCancel( ... )
    DcUtil:UserTrack({ category='ui', sub_category="authentication_bonding_alert", direct = 0})
	SelectPanel.onCancel(self, ...)
end

function AdviceBindPanel:onConfirm( ... )
	DcUtil:UserTrack({ category='ui', sub_category="authentication_bonding_alert", direct = 1})
	SelectPanel.onConfirm(self, ...)
end

return AdviceBindPanel
