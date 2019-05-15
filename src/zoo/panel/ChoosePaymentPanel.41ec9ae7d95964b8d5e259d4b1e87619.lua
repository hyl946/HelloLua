require 'zoo.panel.component.common.GridLayout'
require 'zoo.panel.component.common.LayoutItem'

if __WP8 then
	require 'zoo.panelBusLogic.Wp8Payment'
end

ChoosePaymentPanelButton = class(ItemInLayout)

ChoosePaymentPanel = class(BasePanel)

function ChoosePaymentPanel:create(paymentsToShow, title, specialDiscount, goodsId)
    if _G.isLocalDevelopMode then printx(0, 'ChoosePaymentPanel:create') end
    local panel = ChoosePaymentPanel.new()
    panel.specialDiscount = specialDiscount
    panel.goodsId = goodsId
    panel:loadRequiredResource(PanelConfigFiles.choose_payment_panel)
    panel:init(paymentsToShow, title)
    return panel
end

function ChoosePaymentPanel:init(paymentsToShow,title)
    title = title or Localization:getInstance():getText('panel.choosepayment.title')

    local ui = self:buildInterfaceGroup('ChoosePaymentPanel')
    BasePanel.init(self, ui)

    self.bg = ui:getChildByName('bg')
    self.bg2 = ui:getChildByName('bg2')
    self.closeBtn = ui:getChildByName('closeBtn')
    self.closeBtn:ad(DisplayEvents.kTouchTap, function() self:onCloseBtnTapped() end)
    self.closeBtn:setTouchEnabled(true)
    self.title = ui:getChildByName('title')
    self.title:setString(title)

    local titleOriginalHeight = self.title:getContentSize().height
    self.title:setDimensions(CCSizeMake(self.title:getDimensions().width,0))
    local diffTitleHeight = math.max(0,self.title:getContentSize().height - titleOriginalHeight)

    -- sequence define
    local paymentsSequence = {
        Payments.WECHAT,
        Payments.ALIPAY,
        Payments.WDJ,
        Payments.QQ,
        Payments.QIHOO,
        Payments.QIHOO_WX,
        Payments.QIHOO_ALI,
        Payments.DUOKU,
        Payments.MDO,
        Payments.MI,
        Payments.CHINA_MOBILE,       -- 移动mm
        Payments.CHINA_MOBILE_GAME,  -- 移动游戏基地
        Payments.CHINA_UNICOM,
        Payments.CHINA_TELECOM,
    }

    -- sort
    local sortedPayments = {}
    
    local sortedPayments = {}
    if __WP8 then
        for k,v in pairs(Payments) do
            if paymentsToShow[v] == true then
                table.insert(sortedPayments, v)
            end
        end
    else
        for i, v in ipairs(paymentsSequence) do
            if paymentsToShow[v] == true then
                table.insert(sortedPayments, v)
            end
        end
    end

    self.buttons = {}

    for _, k in pairs(sortedPayments) do
        local btn = ChoosePaymentPanelButton:create()
		if __WP8 then
			if k == Payments.CHINA_MOBILE then
				btn:setContent(self.builder:buildGroup('ChinaMobile'))
			elseif k == Payments.IAPPPAY then
				local res = self.builder:buildGroup('OtherPaymentButton')
				local alipay_pic = 'Assets/iapppay.png'
				if _G.__use_small_res then
					alipay_pic = 'Assets/iapppay@2x.png'
				end
				local alipay_sprite = Sprite:create(alipay_pic)
				alipay_sprite:setAnchorPoint(ccp(0.5, 0.5))
				local asize = res:getGroupBounds().size
				alipay_sprite:setPosition(ccp(asize.width / 2, - asize.height / 2))
				res:addChild(alipay_sprite)
				btn:setContent(res)
            elseif k == Payments.ALIPAY then
                btn:setContent(self.builder:buildGroup("choosePayment/alipay"))
			end
		else
			if k == Payments.CHINA_MOBILE or k == Payments.CHINA_MOBILE_GAME then
				btn:setContent(self.builder:buildGroup('ChinaMobile'))
			elseif k == Payments.CHINA_UNICOM then
				btn:setContent(self.builder:buildGroup('ChinaUnicom'))
			elseif k == Payments.CHINA_TELECOM then
				btn:setContent(self.builder:buildGroup('ChinaTelecom'))
			elseif k == Payments.WDJ then
				btn:setContent(self.builder:buildGroup('WDJ'))
                btn.discount = true
			elseif k == Payments.QIHOO then
				btn:setContent(self.builder:buildGroup('Qihoo'))
                btn.discount = true
            elseif k == Payments.QIHOO_WX then
                btn:setContent(self.builder:buildGroup("choosePayment/wechat"))
                btn.discount = true
            elseif k == Payments.QIHOO_ALI then
                btn:setContent(self.builder:buildGroup("choosePayment/alipay"))
                btn.discount = true
			elseif k == Payments.MDO then
				btn:setContent(self.builder:buildGroup('MDO'))
			elseif k == Payments.QQ then
				btn:setContent(self.builder:buildGroup('QQ'))
                btn.discount = true
            elseif k == Payments.CHINA_MOBILE_GAME then -- cmgame uses ChinaMobile icon
                btn:setContent(self.builder:buildGroup('ChinaMobile'))
            elseif k == Payments.WECHAT then 
                btn:setContent(self.builder:buildGroup("choosePayment/wechat"))
                btn.discount = true
            elseif k == Payments.ALIPAY then 
                btn:setContent(self.builder:buildGroup("choosePayment/alipay"))
                btn.discount = true
            elseif k == Payments.DUOKU then 
                btn:setContent(self.builder:buildGroup("choosePayment/duoku"))
            elseif k == Payments.MI then 
                btn:setContent(self.builder:buildGroup("choosePayment/mipay"))
                btn.discount = true
			else
				local res = self.builder:buildGroup('OtherPaymentButton')
				-- if k == Payments.QQ then
				-- 	res:getChildByName('txt'):setString(Localization:getInstance():getText('panel.choosepayment.payments.qq'))
				-- -- elseif k == Payments.WDJ then
				-- --     res:getChildByName('txt'):setString(Localization:getInstance():getText('panel.choosepayment.payments.wdj'))
				-- elseif k == Payments.MI then
				-- 	res:getChildByName('txt'):setString(Localization:getInstance():getText('panel.choosepayment.payments.mi'))
				-- end
				btn:setContent(res)
			end
		end
        btn.content:ad(DisplayEvents.kTouchTap, function () self:selectPayment(k) end)
        btn.content:setTouchEnabled(true, 0, true)
        btn.content:setButtonMode(true)
        table.insert(self.buttons, btn)
    end

    local placeholder = ui:getChildByName('placeholder')
    local phPos = placeholder:getPosition()
    phPos.y = phPos.y - diffTitleHeight
    local phSize = placeholder:getGroupBounds().size

    self.container = GridLayout:create()
    self.container:setColumn(3)
    self.container:setWidth(phSize.width)
    self.container:setItemSize(CCSizeMake(0, 185))
    self.container:setRowMargin(20)
    self.container:setPositionXY(phPos.x + 10, phPos.y)
    placeholder:getParent():addChild(self.container)


    for i=1, #self.buttons do
        self.container:addItem(self.buttons[i])
    end

    local noDiscount = false
    if self.goodsId then 
        local goodsName = Localization:getInstance():getText("goods.name.text"..tostring(self.goodsId))
        if goodsName then
            if string.find(goodsName, "新区域解锁") or string.find(goodsName, "签到礼包") then
                noDiscount = true
            end
        end
    end

    if not noDiscount then 
        for i,v in ipairs(self.buttons) do
            if v.discount then 
                local discountSign = self.builder:buildGroup("discount")
                local sign1 = discountSign:getChildByName("bg")
                local sign2 = discountSign:getChildByName("bg1")
                if self.specialDiscount then
                     sign1:setVisible(false)
                end
                v:addChild(discountSign)
                discountSign:setPosition(ccp(105, 14))
            end
        end
    end
    
    local size = self.bg:getGroupBounds().size
    local size2 = self.bg2:getGroupBounds().size
    self.bg:setPreferredSize(CCSizeMake(size.width, self.container:getHeight() + 200 + diffTitleHeight))
    self.bg2:setPreferredSize(CCSizeMake(size2.width, self.container:getHeight() + 166 + diffTitleHeight))
    -- placeholder:removeFromParentAndCleanup(true)
    placeholder:setVisible(false)
end

function ChoosePaymentPanel:selectPayment(payment)
    self.selectedPayment = payment
    self:onCloseBtnTapped()
end

function ChoosePaymentPanel:enableButton(refButton, boolEnable)
    if refButton and not refButton.isDisposed then
        refButton:setButtonMode(boolEnable)
        refButton:setTouchEnabled(boolEnable)
        refButton:setVisible(boolEnable)
    end
end 

function ChoosePaymentPanel:popout(onCloseCallback)
    self:setPositionForPopoutManager()
    if _G.isLocalDevelopMode then printx(0, 'ChoosePaymentPanel:popout') end
    self.doneCallback = onCloseCallback

    local function onFinish()
        PopoutManager:sharedInstance():addWithBgFadeIn(self, true, false, false)
        self.allowBackKeyTap = true
    end
    onFinish()
    -- self.showHideAnim:playShowAnim(onFinish)
end


function ChoosePaymentPanel:onCloseBtnTapped()
    if self.doneCallback then self.doneCallback(self.selectedPayment) end

    local function onFinish()
        PopoutManager:sharedInstance():removeWithBgFadeOut(self, false)
        self.allowBackKeyTap = false
    end
    onFinish()
    -- self.showHideAnim:playHideAnim(onFinish)
end