local Button = require "zoo.panel.phone.Button"

local WechatQuickPayConfirmPanel = class(BasePanel)

function WechatQuickPayConfirmPanel:create(goldNum, price)
    local panel = WechatQuickPayConfirmPanel.new()
    panel:loadRequiredResource("ui/ali_payment.json")
    panel:init(goldNum, price)

    return panel
end

function WechatQuickPayConfirmPanel:init(goldNum, price)
    self.ui = self:buildInterfaceGroup("AliQuickPayConfirmPanel")
    BasePanel.init(self, self.ui)

    self.btnSave = GroupButtonBase:create(self.ui:getChildByName("btnOK"))
    self.btnSave:setString(Localization:getInstance():getText("确定"))
    self.btnSave:addEventListener(DisplayEvents.kTouchTap, function ()
        if self.confirmCallback then
            self.confirmCallback()
        end
        self:onCloseBtnTapped()
    end)

    self.panelTitle = TextField:createWithUIAdjustment(self.ui:getChildByName("panelTitleSize"), self.ui:getChildByName("panelTitle"))
    self.ui:addChild(self.panelTitle)
    self.panelTitle:setString(Localization:getInstance():getText("wechat.kf.pay2.wc"))

    self.closeBtn = self.ui:getChildByName("btnClose")
    self.closeBtn:setTouchEnabled(true, 0, true)
    self.closeBtn:setButtonMode(true)
    self.closeBtn:addEventListener(DisplayEvents.kTouchTap, 
        function() 
            self:onCloseBtnTapped()
            if _G.isLocalDevelopMode then printx(0, "btnclose tapped!!!!!!!!!!") end
        end)

    local price = string.format("%.2f", price)
    self.ui:getChildByName("tip_price"):setString(localize("wechat.kf.pay2.text")..":¥"..price)

    local label, size = self.ui:getChildByName("labelPrice"), self.ui:getChildByName("labelPrice_size")
    label = TextField:createWithUIAdjustment(size, label)
    label:setString(goldNum)
    self.ui:addChild(label)
end

function WechatQuickPayConfirmPanel:popout(confirmCallback, cancelCallback)
    self:setPositionForPopoutManager()

    self.confirmCallback = confirmCallback
    self.cancelCallback = cancelCallback
    PopoutManager:sharedInstance():add(self, true, false)
end

function WechatQuickPayConfirmPanel:onCloseBtnTapped()
    PopoutManager:sharedInstance():remove(self, true)
end

return WechatQuickPayConfirmPanel