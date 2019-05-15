PayPanelSingleThirdOff_VerB = class(PayPanelConfirmBase_VerB)

local PayPanelSingleThirdOff_VerB_video = class(PayPanelSingleThirdOff_VerB)


function PayPanelSingleThirdOff_VerB:ctor()
	
end

function PayPanelSingleThirdOff_VerB:getExtendedHeight()
	return 720
end

function PayPanelSingleThirdOff_VerB:getFoldedHeight()
	return 450
end

function PayPanelSingleThirdOff_VerB:init()

	if self.skinMode == "light" then
		self.ui	= self:buildInterfaceGroup("PayPanelSingleThirdOff_newLight")
	else
		self.ui	= self:buildInterfaceGroup("PayPanelSingleThirdOff_newDrak") 
	end

	PayPanelConfirmBase_VerB.init(self)

	self:initBuyButton()
end

function PayPanelSingleThirdOff_VerB:initBuyButton()
	local btnShowConfig = PaymentManager.getInstance():getPaymentShowConfig(self.paymentType, self.newPrice)
	self.buyButton = ButtonIconsetBase:create(self.ui:getChildByName("buyBtn"))
	
	--self.buyButton:setString(Localization:getInstance():getText(btnShowConfig.name))
	self:initDiscountPricePart()

	self.buyButton:setIconByFrameName(btnShowConfig.smallIcon)
	self.buyButton:setColorMode(kGroupButtonColorMode.blue)
	self.buyButton:addEventListener(DisplayEvents.kTouchTap,  function ()
			self:onRmbBuyBtnTap()
		end)

	self:showButtonLoopAnimation(self.buyButton.groupNode)
end

function PayPanelSingleThirdOff_VerB:initDiscountPricePart()
	local goodsInfoMeta = MetaManager:getInstance():getGoodMeta(self.goodsIdInfo:getGoodsId())
	local discountPartUI = self.ui:getChildByName("discountPricePart")
	local newPrice = goodsInfoMeta.thirdRmb / 100
	self.newPrice = newPrice
	local formatNewPrice = string.format("%s%0.2f", Localization:getInstance():getText("buy.gold.panel.money.mark"), newPrice)
	local newPriceLabel = "特价："..formatNewPrice
	self.buyButton:setString(tostring(formatNewPrice) .. " " .. Localization:getInstance():getText("buy.prop.panel.btn.buy.txt"))

	local oldPricePreLabelUI = discountPartUI:getChildByName("oldPricePreLabel")
	oldPricePreLabelUI:setString(Localization:getInstance():getText("原价："))
	local oldPriceLabelUI = discountPartUI:getChildByName("oldPriceLabel")
	local oldPrice = goodsInfoMeta.rmb / 100
	local formatOldPrice = string.format("%s%0.2f", Localization:getInstance():getText("buy.gold.panel.money.mark"), oldPrice)
	oldPriceLabelUI:setString(formatOldPrice)
	
	--local onlyOnceTipMC = discountPartUI:getChildByName("onlyOnceTipMC")

	local discountUI = PayPanelDiscountUI:create(discountPartUI:getChildByName("discount"), self.goodsIdInfo:getDiscountNum()) 
	discountUI:setVisible(false)
end

function PayPanelSingleThirdOff_VerB:onCloseBtnTap()
	if self.peDispatcher then 
		self.peDispatcher:dispatchPanelCloseEvent()
	end

	PayPanelConfirmBase_VerB.onCloseBtnTap(self)
end


function PayPanelSingleThirdOff_VerB:onRmbBuyBtnTap()
	local function rebecomeEnable()
		self:setBuyBtnEnabled(true)
	end
	self:setBuyBtnEnabled(false)
	setTimeOut(rebecomeEnable, 5)

	if self.peDispatcher then 
		self.peDispatcher:dispatchPanelPayEvent(self.paymentType)
	end
end

function PayPanelSingleThirdOff_VerB:setBuyBtnEnabled(isEnable)
	if self.buyButton and not self.buyButton.isDisposed then 
		self.buyButton:setEnabled(isEnable)
	end
end

function PayPanelSingleThirdOff_VerB:create(peDispatcher, goodsIdInfo, paymentType, isDarkSkin)
	local panel = nil
	if goodsIdInfo and goodsIdInfo.isFreeVideo then
		panel = PayPanelSingleThirdOff_VerB_video.new()
	else
		panel = PayPanelSingleThirdOff_VerB.new()
		if isDarkSkin then
			panel:changeSkinModeToDark(true)
		end
	end
	panel.peDispatcher = peDispatcher
	panel.goodsIdInfo = goodsIdInfo
	panel.paymentType = paymentType
	panel:loadRequiredResource("ui/BuyConfirmPanel.json")
	panel:init()
	return panel
end


-------- video ad

function PayPanelSingleThirdOff_VerB_video:init()
	self.ui	= self:buildInterfaceGroup("PayPanelSingleThirdOff_newAD")
	PayPanelConfirmBase.init(self)

	self:initDiscountPricePart()
	self:initBuyButton()

	self:initBtnVideoAD()
end

function PayPanelSingleThirdOff_VerB_video:setBuyBtnEnabled(isEnable)
	PayPanelSingleThirdOff.setBuyBtnEnabled(self,isEnable)
	local _ = self.btnVideoAD and not self.btnVideoAD.isDisposed and self.btnVideoAD:setEnabled(isEnable)
end

function PayPanelSingleThirdOff_VerB_video:getExtendedHeight()
	return self.class.super.getExtendedHeight(self)+90
end

function PayPanelSingleThirdOff_VerB_video:getFoldedHeight()
	return self.class.super.getFoldedHeight(self)+90
end
