local Button = require "zoo.panel.phone.Button"

local AliQuickPayConfirmPanel = class(BasePanel)

function AliQuickPayConfirmPanel:create(goldNum, price)
	local panel = AliQuickPayConfirmPanel.new()
	panel:loadRequiredResource("ui/ali_payment.json")
	panel:init(goldNum, price)

	return panel
end

function AliQuickPayConfirmPanel:init(goldNum, price)
	self.ui = self:buildInterfaceGroup("AliQuickPayConfirmPanel")
    BasePanel.init(self, self.ui)

    self.btnSave = GroupButtonBase:create(self.ui:getChildByName("btnOK"))
    self.btnSave:setString(Localization:getInstance():getText("确定"))
    self.btnSave:addEventListener(DisplayEvents.kTouchTap, function ()
        if self.confirmCallback then
            self.confirmCallback()
        end
        self:removeSelf()
    end)

    self.panelTitle = TextField:createWithUIAdjustment(self.ui:getChildByName("panelTitleSize"), self.ui:getChildByName("panelTitle"))
    self.ui:addChild(self.panelTitle)
    self.panelTitle:setString(Localization:getInstance():getText("alipay.pay.kf.confirm1"))

    self.closeBtn = self.ui:getChildByName("btnClose")
    self.closeBtn:setTouchEnabled(true, 0, true)
    self.closeBtn:setButtonMode(true)
    self.closeBtn:addEventListener(DisplayEvents.kTouchTap, 
        function() 
            self:onCloseBtnTapped()
            if _G.isLocalDevelopMode then printx(0, "btnclose tapped!!!!!!!!!!") end
        end)

    local price = string.format("%.2f", price)
    self.ui:getChildByName("tip_price"):setString(localize("alipay.pay.kf.confirm")..":¥"..price)

    local label, size = self.ui:getChildByName("labelPrice"), self.ui:getChildByName("labelPrice_size")
    label = TextField:createWithUIAdjustment(size, label)
    label:setString(goldNum)
    self.ui:addChild(label)
end

function AliQuickPayConfirmPanel:popout(confirmCallback, cancelCallback)
    self:setPositionForPopoutManager()

    self.confirmCallback = confirmCallback
    self.cancelCallback = cancelCallback
    PopoutManager:sharedInstance():add(self, true, false)
end

function AliQuickPayConfirmPanel:removeSelf()
    PopoutManager:sharedInstance():remove(self, true)
end

function AliQuickPayConfirmPanel:onCloseBtnTapped()
    self:removeSelf()
    if self.cancelCallback then
        self.cancelCallback()
    end
end

return AliQuickPayConfirmPanel