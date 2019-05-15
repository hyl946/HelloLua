
NetConnectPanel = class(BasePanel)

function NetConnectPanel:ctor()
	
end

function NetConnectPanel:init()
	self.ui	= self:buildInterfaceGroup("NetConnectPanel") 
	BasePanel.init(self, self.ui)

	-- local title = self.ui:getChildByName("title")
	-- title:setString(localize("payfail.choose.payment.title"))
	self.panelTitle = TextField:createWithUIAdjustment(self.ui:getChildByName("panelTitleSize"), self.ui:getChildByName("panelTitle"))
	self.ui:addChild(self.panelTitle)
	self.panelTitle:setString(Localization:getInstance():getText("payfail.choose.payment.title"))
	
	local text1 = self.ui:getChildByName("text1")
	local text_pre = self.ui:getChildByName("text_pre")
	local text_mid = self.ui:getChildByName("text_mid")
	local text_sub = self.ui:getChildByName("text_sub")

	if self.isRmbPay then 
		local defaultThirdPayType = PaymentManager.getInstance():getDefaultThirdPartPayment()
		local btnShowConfig = PaymentManager.getInstance():getPaymentShowConfig(realThirdPayment[1], self.goodsPrice)
		local payText = btnShowConfig.name
		if payText == nil or payText == localize("add.step.panel.buy.btn.txt") then
			payText = "联网支付"
		end
		--text1:setString(Localization:getInstance():getText("当前没有联网，不能使用"..payText.."哦！"))
		text_pre:setString(localize("payfail.neednet1.1"))
		text_mid:setString(localize("payfail.neednet1.2"))
		text_mid:setColor(ccc3(255, 0, 0))
		text_sub:setString(localize("payfail.neednet1.3")..payText..localize("payfail.neednet1.4"))
	else
		text_pre:setVisible(false)
		text_mid:setVisible(false)
		text_sub:setVisible(false)
		text1:setString(Localization:getInstance():getText("panel.no.net.pay.text1"))
	end
	local text2 = self.ui:getChildByName("text2")
	text2:setString(Localization:getInstance():getText("panel.no.net.pay.text2"))
	--text2:setColor(ccc3(0, 160, 233))
	text2:setVisible(false)

	-- self.connectBtn = GroupButtonBase:create(self.ui:getChildByName("connectBtn"))
	-- self.connectBtn:setString(Localization:getInstance():getText("panel.no.net.pay.botton1"))
	-- self.connectBtn:addEventListener(DisplayEvents.kTouchTap,  function ()
	-- 		self:onConnectBtnTap()
	-- 	end)

	self.closeBtn = self.ui:getChildByName("closeBtn")
	self.closeBtn:setTouchEnabled(true, 0 , true)
	self.closeBtn:setButtonMode(true)
	self.closeBtn:addEventListener(DisplayEvents.kTouchTap, function ()
		self:onCloseBtnTapped()
	end)

	local smsPayBtnUI = self.ui:getChildByName("smsPayBtn")
	if self.smsPayType then 
		text2:setVisible(true)
		self.smsPayBtn = GroupButtonBase:create(smsPayBtnUI)
		self.smsPayBtn:setColorMode(kGroupButtonColorMode.blue)
		local label1 = string.format("%s%0.2f", Localization:getInstance():getText("buy.gold.panel.money.mark"), self.goodsPrice)
		local label2 =	label1 .. Localization:getInstance():getText("panel.no.net.pay.botton2")
		self.smsPayBtn:setString(label2)
		self.smsPayBtn:addEventListener(DisplayEvents.kTouchTap,  function ()
				self:onSmsPayBtnTap()
			end)
	else
		smsPayBtnUI:setVisible(false)
	end
end

function NetConnectPanel:onConnectBtnTap()
	local alterList = 0
	if self.connectCallback then 
		self.connectCallback()
	end
	self:removePopout()
end

function NetConnectPanel:onSmsPayBtnTap()
	self:setButtonsEnabled(false)

	local alterList = 0
	if self.smsPayType then 
		local chooseTable = {self.smsPayType}
	end
	if self.handleCallback then 
		self.handleCallback()
	end
	-- if self.connectCallback then 
	-- 	self.connectCallback()
	-- end
	self:removePopout()
end

function NetConnectPanel:popout()
	PopoutManager:sharedInstance():add(self, false, false)
	local parent = self:getParent()
	if parent then
		self:setToScreenCenterHorizontal()
		self:setToScreenCenterVertical()		
	end
	self.allowBackKeyTap = true
end

function NetConnectPanel:removePopout()
	PopoutManager:sharedInstance():remove(self, true)
	self.allowBackKeyTap = false
end

function NetConnectPanel:setButtonsEnabled(isEnabled)
	if self.isDisposed then return end
	if not isEnabled then isEnabled = false end
	if self.connectBtn then 
		self.connectBtn:setEnabled(isEnabled)
	end
	if self.smsPayBtn then 
		self.smsPayBtn:setEnabled(isEnabled)
	end
end

function NetConnectPanel:onCloseBtnTapped()
	self:onConnectBtnTap()
end

function NetConnectPanel:create(smsPayType, handleCallback, goodsPrice, connectCallback, uniquePayId, isRmbPay)
	local panel = NetConnectPanel.new()
	panel.smsPayType = smsPayType
	panel.handleCallback = handleCallback
	panel.goodsPrice = goodsPrice
	panel.connectCallback = connectCallback
	panel.uniquePayId = uniquePayId
	panel.isRmbPay = isRmbPay
	panel:loadRequiredResource("ui/BuyConfirmPanel.json")
	panel:init()
	return panel
end