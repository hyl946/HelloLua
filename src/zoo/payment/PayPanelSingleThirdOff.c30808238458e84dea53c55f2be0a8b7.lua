
PayPanelSingleThirdOff = class(PayPanelConfirmBase)

function PayPanelSingleThirdOff:ctor()
	
end

function PayPanelSingleThirdOff:getExtendedHeight()
	return 695
end

function PayPanelSingleThirdOff:getFoldedHeight()
	return 415
end

function PayPanelSingleThirdOff:init()
	self.ui	= self:buildInterfaceGroup("PayPanelSingleThirdOff") 
	PayPanelConfirmBase.init(self)

	self:initDiscountPricePart()

	local btnShowConfig = PaymentManager.getInstance():getPaymentShowConfig(self.paymentType, self.newPrice)
	self.buyButton = ButtonIconsetBase:create(self.ui:getChildByName("buyBtn"))
	self.buyButton:setString(Localization:getInstance():getText(btnShowConfig.name))
	self.buyButton:setIconByFrameName(btnShowConfig.smallIcon)
	self.buyButton:setColorMode(kGroupButtonColorMode.blue)
	self.buyButton:addEventListener(DisplayEvents.kTouchTap,  function ()
			self:onRmbBuyBtnTap()
		end)
	self:showButtonLoopAnimation(self.buyButton.groupNode)
end

function PayPanelSingleThirdOff:initDiscountPricePart()
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

function PayPanelSingleThirdOff:onCloseBtnTap()
	if self.peDispatcher then 
		self.peDispatcher:dispatchPanelCloseEvent()
	end

	PayPanelConfirmBase.onCloseBtnTap(self)
end


function PayPanelSingleThirdOff:onRmbBuyBtnTap()
	local function rebecomeEnable()
		self:setBuyBtnEnabled(true)
	end
	self:setBuyBtnEnabled(false)
	setTimeOut(rebecomeEnable, 5)

	if self.peDispatcher then 
		self.peDispatcher:dispatchPanelPayEvent(self.paymentType)
	end
end

function PayPanelSingleThirdOff:setBuyBtnEnabled(isEnable)
	if self.buyButton and not self.buyButton.isDisposed then 
		self.buyButton:setEnabled(isEnable)
	end
end

function PayPanelSingleThirdOff:create(peDispatcher, goodsIdInfo, paymentType)
	local panel = PayPanelSingleThirdOff.new()
	panel.peDispatcher = peDispatcher
	panel.goodsIdInfo = goodsIdInfo
	panel.paymentType = paymentType
	panel:loadRequiredResource("ui/BuyConfirmPanel.json")
	panel:init()
	return panel
end