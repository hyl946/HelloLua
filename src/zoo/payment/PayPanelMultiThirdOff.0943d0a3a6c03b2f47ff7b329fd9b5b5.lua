
PayPanelMultiThirdOff = class(PayPanelConfirmBase)

local PayPanelMultiThirdOff_video = class(PayPanelMultiThirdOff)

function PayPanelMultiThirdOff:ctor()
	
end

function PayPanelMultiThirdOff:getExtendedHeight()
	return 750
end

function PayPanelMultiThirdOff:getFoldedHeight()
	return 470
end

function PayPanelMultiThirdOff:init()
	self.ui	= self:buildInterfaceGroup("PayPanelMultiThirdOff") 
	PayPanelConfirmBase.init(self)

	self:initDiscountPricePart()
	self:initBaseUI()
end

function PayPanelMultiThirdOff:initBaseUI()
	local btnShowConfig1 = PaymentManager.getInstance():getPaymentShowConfig(self.paymentType, self.newPrice)
	self.buyButton1 = ButtonIconsetBase:create(self.ui:getChildByName("buyBtn1"))
	self.buyButton1.paymentType = self.paymentType1
	self.buyButton1:setString(Localization:getInstance():getText(btnShowConfig1.name))
	self.buyButton1:setIconByFrameName(btnShowConfig1.smallIcon)
	self.buyButton1:addEventListener(DisplayEvents.kTouchTap,  function (evt)
			self:onRmbBuyBtnTap(evt)
		end)

	local btnShowConfig2 = PaymentManager.getInstance():getPaymentShowConfig(self.otherPaymentTable[1], self.newPrice)
	self.buyButton2 = ButtonIconsetBase:create(self.ui:getChildByName("buyBtn2"))
	self.buyButton2.paymentType = self.otherPaymentTable[1]
	self.buyButton2:setString(Localization:getInstance():getText(btnShowConfig2.name))
	self.buyButton2:setIconByFrameName(btnShowConfig2.smallIcon)
	self.buyButton2:setColorMode(kGroupButtonColorMode.blue)
	self.buyButton2:addEventListener(DisplayEvents.kTouchTap,  function (evt)
			self:onRmbBuyBtnTap(evt)
		end)
end

function PayPanelMultiThirdOff:initDiscountPricePart()
	local goodsInfoMeta = MetaManager:getInstance():getGoodMeta(self.goodsIdInfo:getGoodsId())
	local discountPartUI = self.ui:getChildByName("discountPricePart")
	local newPriceLabelUI = discountPartUI:getChildByName("newPriceLabel")
	local newPrice = goodsInfoMeta.thirdRmb / 100
	self.newPrice = newPrice
	local formatNewPrice = string.format("%s%0.2f", Localization:getInstance():getText("buy.gold.panel.money.mark"), newPrice)
	local newPriceLabel = "特价："..formatNewPrice
	newPriceLabelUI:setString(newPriceLabel)

	local oldPricePreLabelUI = discountPartUI:getChildByName("oldPricePreLabel")
	oldPricePreLabelUI:setString(Localization:getInstance():getText("原价："))
	local oldPriceLabelUI = discountPartUI:getChildByName("oldPriceLabel")
	local oldPrice = goodsInfoMeta.rmb / 100
	local formatOldPrice = string.format("%s%0.2f", Localization:getInstance():getText("buy.gold.panel.money.mark"), oldPrice)
	oldPriceLabelUI:setString(formatOldPrice)
	
	local discountUI = PayPanelDiscountUI:create(discountPartUI:getChildByName("discount"), self.goodsIdInfo:getDiscountNum()) 
end

function PayPanelMultiThirdOff:onCloseBtnTap()
	if self.peDispatcher then 
		self.peDispatcher:dispatchPanelCloseEvent()
	end

	PayPanelConfirmBase.onCloseBtnTap(self)
end


function PayPanelMultiThirdOff:onRmbBuyBtnTap(evt)
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

function PayPanelMultiThirdOff:setBuyBtnEnabled(isEnable)
	if self.buyButton1 and not self.buyButton1.isDisposed then 
		self.buyButton1:setEnabled(isEnable)
	end
	if self.buyButton2 and not self.buyButton2.isDisposed then 
		self.buyButton2:setEnabled(isEnable)
	end
end

function PayPanelMultiThirdOff:create(peDispatcher, goodsIdInfo, paymentType, otherPaymentTable)
	local panel = PayPanelMultiThirdOff.new()
	panel.peDispatcher = peDispatcher
	panel.goodsIdInfo = goodsIdInfo
	panel.paymentType = paymentType
	panel.otherPaymentTable = otherPaymentTable
	panel:loadRequiredResource("ui/BuyConfirmPanel.json")
	panel:init()
	return panel
end

-------- video ad

function PayPanelMultiThirdOff_video:init()
	self.ui	= self:buildInterfaceGroup("PayPanelMultiThirdOff_AD")
	PayPanelConfirmBase.init(self)

	self:initDiscountPricePart()
	self:initBaseUI()

	self:initBtnVideoAD()
end

function PayPanelMultiThirdOff_video:setBuyBtnEnabled(isEnable)
	PayPanelSingleThirdOff.setBuyBtnEnabled(self,isEnable)
	local _ = self.btnVideoAD and not self.btnVideoAD.isDisposed and self.btnVideoAD:setEnabled(isEnable)
end

function PayPanelMultiThirdOff_video:getExtendedHeight()
	return self.class.super.getExtendedHeight(self)+50
end

function PayPanelMultiThirdOff_video:getFoldedHeight()
	return self.class.super.getFoldedHeight(self)+50
end
