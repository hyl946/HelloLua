
DefaultPaymentChangePanel = class(BasePanel)

function DefaultPaymentChangePanel:init()
    self.ui = self:buildInterfaceGroup('DefaultPaymentChangePanel')
    BasePanel.init(self, self.ui)

    local btn = GroupButtonBase:create(self.ui:getChildByName('btn'))
    btn:setString(localize("button.ok"))
    btn:ad(DisplayEvents.kTouchTap, function () 
        self:onBtnTapped() 
    end)

    local gotoSettingBtn = self.ui:getChildByName('gotoSettingBtn')
    gotoSettingBtn:setButtonMode(true)
    gotoSettingBtn:setTouchEnabled(true, 0, true)
    gotoSettingBtn:ad(DisplayEvents.kTouchTap, function () self:onGotoSettingBtnTapped() end)

    self.ui:getChildByName('tipLabel'):setString(localize('pay.way.panel.text'))

    self:initPaymentShow()
end

function DefaultPaymentChangePanel:initPaymentShow()
	local btnShowConfig = PaymentManager.getInstance():getPaymentShowConfig(self.paymentType)
	--支付名称
	local payNameUI = self.ui:getChildByName("payName")
	payNameUI:setString(btnShowConfig.name)

	--支付大图标
	local payIconPosUI = self.ui:getChildByName("payIconPos")
	payIconPosUI:setOpacity(0)
	local payIconBig = Sprite:createWithSpriteFrameName(btnShowConfig.bigIcon)
	payIconBig:setAnchorPoint(ccp(0, 1))
	payIconPosUI:addChild(payIconBig)
end

function DefaultPaymentChangePanel:onBtnTapped()
    DcUtil:UserTrack({category = "set", sub_category = "buy_way_setting_pop", click = 0})
    self:removeSelf()
end

function DefaultPaymentChangePanel:onGotoSettingBtnTapped()
    DcUtil:UserTrack({category = "set", sub_category = "buy_way_setting_pop", click = 1})
    self:removeSelf()
    NewGameSettingPanel:create(1):popout()
end

function DefaultPaymentChangePanel:popoutShowTransition()
    self:setToScreenCenterVertical()
end

function DefaultPaymentChangePanel:popout()
    self.allowBackKeyTap = true
    PopoutQueue.sharedInstance():push(self, false)
    self:setPositionY(self:getPositionY() + 130)
    self:runAction(CCEaseElasticOut:create(CCMoveBy:create(0.8, ccp(0, -130))))
end

function DefaultPaymentChangePanel:removeSelf()
    self.allowBackKeyTap = false
    PopoutManager:sharedInstance():removeWithBgFadeOut(self, false, true)
end

function DefaultPaymentChangePanel:create(paymentType)
    local panel = DefaultPaymentChangePanel.new()
    panel.paymentType = paymentType
    panel:loadRequiredResource("ui/BuyConfirmPanel.json")
    panel:init(payment)
    return panel
end
