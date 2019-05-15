local Button = require "zoo.panel.phone.Button"
local WechatQuickPayInfoPanel = class(BasePanel)

function WechatQuickPayInfoPanel:create()
    local panel = WechatQuickPayInfoPanel.new()
    panel:loadRequiredResource("ui/ali_payment.json")
    panel:init()

    return panel
end

function WechatQuickPayInfoPanel:init()

    self.ui = self:buildInterfaceGroup("AliQuickPayInfoPanel")
    BasePanel.init(self, self.ui)

    self.btnConfirm = GroupButtonBase:create(self.ui:getChildByName("btnSave"))
    self.btnConfirm:setString(Localization:getInstance():getText("fruit.tree.panel.rule.button"))
    self.btnConfirm:addEventListener(DisplayEvents.kTouchTap, function ()
        self:onCloseBtnTapped()
    end)

    self.panelTitle = TextField:createWithUIAdjustment(self.ui:getChildByName("panelTitleSize"), self.ui:getChildByName("panelTitle"))
    self.ui:addChild(self.panelTitle)
    self.panelTitle:setString(Localization:getInstance():getText("wechat.kf.help.1"))

    self.reduceIcon = self.ui:getChildByName('reduceIcon')
    self.reduceText = self.ui:getChildByName('reduceText')
    self.reduceText2 = self.ui:getChildByName('reduceText2')

    self.reduceIcon:setVisible(false)
    self.reduceText:setVisible(false)
    self.reduceText2:setVisible(false)

    self.closeBtn = self.ui:getChildByName("btnClose")
    self.closeBtn:setTouchEnabled(true, 0, true)
    self.closeBtn:setButtonMode(true)
    self.closeBtn:addEventListener(DisplayEvents.kTouchTap, 
        function() 
            self:onCloseBtnTapped()
            if _G.isLocalDevelopMode then printx(0, "btnclose tapped!!!!!!!!!!") end
        end)

    self:initText()
end

function WechatQuickPayInfoPanel:initText()
    -- self.ui:getChildByName("title"):setString(localize("panel.choosepayment.quest"))-- "什么是支付宝快付 ")
    self.ui:getChildByName("tip1"):setString(localize("wechat.kf.help.2")) -- "开通快捷支付后，每次小额支付时不再需要反复输入密码，方便安全。")
    self.ui:getChildByName("tip2"):setString(localize("wechat.kf.help.3")) -- "1.安全保障，仅限小额支付。")
    self.ui:getChildByName("tip3"):setString(localize("wechat.kf.help.4"))-- "2.此操作仅授权给开心消消乐。")
end

function WechatQuickPayInfoPanel:popout()
    self:setPositionForPopoutManager()

    PopoutManager:sharedInstance():add(self, true, false)
end

function WechatQuickPayInfoPanel:popoutShowTransition()
    self.allowBackKeyTap = true
end

function WechatQuickPayInfoPanel:onCloseBtnTapped()
    PopoutManager:sharedInstance():remove(self, true)
end

return WechatQuickPayInfoPanel

