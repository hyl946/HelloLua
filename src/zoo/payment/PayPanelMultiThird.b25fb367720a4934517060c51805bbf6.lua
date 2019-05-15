
PayPanelMultiThird = class(PayPanelConfirmBase)

local PayPanelMultiThird_video = class(PayPanelMultiThird)

function PayPanelMultiThird:ctor()
	
end

function PayPanelMultiThird:getExtendedHeight()
	return 750
end

function PayPanelMultiThird:getFoldedHeight()
	return 470
end


function PayPanelMultiThird:init()
	self.ui	= self:buildInterfaceGroup("PayPanelMultiThird") 
	PayPanelConfirmBase.init(self)

	self:initBaseUI()
end

function PayPanelMultiThird:initBaseUI()
	local priceLabelUI = self.ui:getChildByName("priceLabel")
	local goodsInfoMeta = MetaManager:getInstance():getGoodMeta(self.goodsIdInfo:getGoodsId())
	local price = goodsInfoMeta.rmb / 100
	if goodsInfoMeta.discountRmb ~= 0 and goodsInfoMeta.discountRmb ~= "0" then
		price = goodsInfoMeta.discountRmb / 100
	end
	local formatPrice = string.format("%s%0.2f", Localization:getInstance():getText("buy.gold.panel.money.mark"), price)
	priceLabelUI:setString(formatPrice)

	local btnShowConfig1 = PaymentManager.getInstance():getPaymentShowConfig(self.paymentType, price)
	self.buyButton1 = ButtonIconsetBase:create(self.ui:getChildByName("buyBtn1"))
	self.buyButton1.paymentType = self.paymentType
	self.buyButton1:setString(Localization:getInstance():getText(btnShowConfig1.name))
	self.buyButton1:setIconByFrameName(btnShowConfig1.smallIcon)
	self.buyButton1:addEventListener(DisplayEvents.kTouchTap,  function (evt)
			self:onRmbBuyBtnTap(evt)
		end)

	local btnShowConfig2 = PaymentManager.getInstance():getPaymentShowConfig(self.otherPaymentTable[1], price)
	self.buyButton2 = ButtonIconsetBase:create(self.ui:getChildByName("buyBtn2"))
	self.buyButton2.paymentType = self.otherPaymentTable[1]
	self.buyButton2:setString(Localization:getInstance():getText(btnShowConfig2.name))
	self.buyButton2:setIconByFrameName(btnShowConfig2.smallIcon)
	self.buyButton2:setColorMode(kGroupButtonColorMode.blue)
	self.buyButton2:addEventListener(DisplayEvents.kTouchTap,  function (evt)
			self:onRmbBuyBtnTap(evt)
		end)
end

function PayPanelMultiThird:onCloseBtnTap()
	if self.peDispatcher then 
		self.peDispatcher:dispatchPanelCloseEvent()
	end

	PayPanelConfirmBase.onCloseBtnTap(self)
end


function PayPanelMultiThird:onRmbBuyBtnTap(evt)
	local paymentType = evt.target.paymentType
	local function rebecomeEnable()
		self:setBuyBtnEnabled(true)
	end
	self:setBuyBtnEnabled(false)
	setTimeOut(rebecomeEnable, 5)

	if self.peDispatcher then 
		self.peDispatcher:dispatchPanelPayEvent(paymentType)
	end
end

function PayPanelMultiThird:setBuyBtnEnabled(isEnable)
	if self.buyButton1 and not self.buyButton1.isDisposed then 
		self.buyButton1:setEnabled(isEnable)
	end
	if self.buyButton2 and not self.buyButton2.isDisposed then 
		self.buyButton2:setEnabled(isEnable)
	end
end

function PayPanelMultiThird:create(peDispatcher, goodsIdInfo, paymentType, otherPaymentTable)
	local panel = nil
	if goodsIdInfo and goodsIdInfo.isFreeVideo then
		panel = PayPanelMultiThird_video.new()
	else
		panel = PayPanelMultiThird.new()
		if isDarkSkin then
			panel:changeSkinModeToDark(true)
		end
	end
	
	panel.peDispatcher = peDispatcher
	panel.goodsIdInfo = goodsIdInfo
	panel.paymentType = paymentType
	panel.otherPaymentTable = otherPaymentTable
	panel:loadRequiredResource("ui/BuyConfirmPanel.json")
	panel:init()
	return panel
end


-------- video ad

function PayPanelMultiThird_video:init()
	self.ui	= self:buildInterfaceGroup("PayPanelMultiThird_AD")
	PayPanelConfirmBase.init(self)

	self:initBaseUI()

	self:initBtnVideoAD()
end

function PayPanelMultiThird_video:setBuyBtnEnabled(isEnable)
	PayPanelSingleThirdOff.setBuyBtnEnabled(self,isEnable)
	local _ = self.btnVideoAD and not self.btnVideoAD.isDisposed and self.btnVideoAD:setEnabled(isEnable)
end

function PayPanelMultiThird_video:getExtendedHeight()
	return self.class.super.getExtendedHeight(self)+50
end

function PayPanelMultiThird_video:getFoldedHeight()
	return self.class.super.getFoldedHeight(self)+50
end
