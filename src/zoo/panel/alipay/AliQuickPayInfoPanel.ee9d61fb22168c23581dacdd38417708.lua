local Button = require "zoo.panel.phone.Button"
require 'zoo.panelBusLogic.AliQuickPayPromoLogic'

local AliQuickPayInfoPanel = class(BasePanel)

function AliQuickPayInfoPanel:create()
	local panel = AliQuickPayInfoPanel.new()
	panel:loadRequiredResource("ui/ali_payment.json")
	panel:init()

	return panel
end

function AliQuickPayInfoPanel:init()

	self.ui = self:buildInterfaceGroup("AliQuickPayInfoPanel")
    BasePanel.init(self, self.ui)

	self.btnConfirm = GroupButtonBase:create(self.ui:getChildByName("btnSave"))
	self.btnConfirm:setString(Localization:getInstance():getText("fruit.tree.panel.rule.button"))
	self.btnConfirm:addEventListener(DisplayEvents.kTouchTap, function ()
		self:onCloseBtnTapped()
	end)

	self.panelTitle = TextField:createWithUIAdjustment(self.ui:getChildByName("panelTitleSize"), self.ui:getChildByName("panelTitle"))
	self.ui:addChild(self.panelTitle)
	self.panelTitle:setString(Localization:getInstance():getText("panel.choosepayment.quest"))

    self.reduceIcon = self.ui:getChildByName('reduceIcon')
    self.reduceText = self.ui:getChildByName('reduceText')
    self.reduceText2 = self.ui:getChildByName('reduceText2')

    self.reduceIcon:setVisible(false)
    self.reduceText:setVisible(false)
    self.reduceText2:setVisible(false)
    self.reduceText:setString(localize('alipay1fenpay.help1'))
    self.reduceText2:setString(localize('alipay1fenpay.help2'))

	self.closeBtn = self.ui:getChildByName("btnClose")
    self.closeBtn:setTouchEnabled(true, 0, true)
    self.closeBtn:setButtonMode(true)
    self.closeBtn:addEventListener(DisplayEvents.kTouchTap, 
        function() 
            self:onCloseBtnTapped()
            if _G.isLocalDevelopMode then printx(0, "btnclose tapped!!!!!!!!!!") end
        end)

	self:initText()

    self:showReduce(AliQuickPayPromoLogic:isEntryEnabled())
end

function AliQuickPayInfoPanel:showReduce(value)
    self.reduceIcon:setVisible(value)
    self.reduceText:setVisible(value)
    self.reduceText2:setVisible(value)
end

function AliQuickPayInfoPanel:initText()
	-- self.ui:getChildByName("title"):setString(localize("panel.choosepayment.quest"))-- "什么是支付宝快付 ")
    self.ui:getChildByName("tip1"):setString(localize("panel.choosepayment.answer.0")) -- "开通快捷支付后，每次小额支付时不再需要反复输入密码，方便安全。")
    self.ui:getChildByName("tip2"):setString(localize("panel.choosepayment.answer.1")) -- "1.安全保障，仅限小额支付。")
    self.ui:getChildByName("tip3"):setString(localize("panel.choosepayment.answer.2"))-- "2.此操作仅授权给开心消消乐。")
end

function AliQuickPayInfoPanel:popout()
	self:setPositionForPopoutManager()

	PopoutManager:sharedInstance():add(self, true, false)

    if AliQuickPayPromoLogic:isEntryEnabled() then
        DcUtil:UserTrack({category = 'alipay_mm_299_event', sub_category = '299_help'})
    else
        DcUtil:UserTrack({category='alipay_mianmi_accredit', sub_category = 'help'})
    end
end

function AliQuickPayInfoPanel:popoutShowTransition()
	self.allowBackKeyTap = true
end

function AliQuickPayInfoPanel:onCloseBtnTapped()
	PopoutManager:sharedInstance():remove(self, true)
end

return AliQuickPayInfoPanel

