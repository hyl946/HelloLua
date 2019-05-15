local SelectPanel = require 'zoo.panel.RealName.bind.SelectPanel'

local AlertPanel = class(SelectPanel)

function AlertPanel:create()
    local panel = AlertPanel.new()
    panel:loadRequiredResource("ui/real_name.json")
    panel:init()
    return panel
end

function AlertPanel:init()
    local ui = self:buildInterfaceGroup("realname/alert2")
	SelectPanel.init(self, ui)

	self:setCancelBtnString('快速登录')
	self:setConfirmBtnString('账号登录')

	local text = localize('authentication.feature.account.bonding.text')
	self:setLabel(text)
end


function AlertPanel:shadowPhoneNumber( str )
	return str:gsub('(...)(....)(....)', '%1****%3')
end

function AlertPanel:onCancel( ... )
    DcUtil:UserTrack({ category='ui', sub_category="authentication_custom_alert", account_type = 0})
	SelectPanel.onCancel(self, ...)
end

function AlertPanel:onConfirm( ... )
	DcUtil:UserTrack({ category='ui', sub_category="authentication_custom_alert", account_type = 1})
	SelectPanel.onConfirm(self, ...)
end

return AlertPanel
