
PayPanelSingleSms = class(PayPanelConfirmBase)

function PayPanelSingleSms:ctor()
	
end

function PayPanelSingleSms:getExtendedHeight()
	return 666
end

function PayPanelSingleSms:getFoldedHeight()
	return 400
end

function PayPanelSingleSms:init()
	self.ui	= self:buildInterfaceGroup("PayPanelSingleSms") 
	PayPanelConfirmBase.init(self)

	--这个面板上永远显示原价
	self.goodsName = Localization:getInstance():getText("goods.name.text"..tostring(self.goodsIdInfo:getOriginalGoodsId()))
	self.panelTitle:setString("购买 "..self.goodsName)

	self.buyButton = GroupButtonBase:create(self.ui:getChildByName("buyBtn"))
	local price = PaymentManager:getPriceByPaymentType(self.goodsIdInfo:getGoodsId(), self.goodsIdInfo:getGoodsType(), self.paymentType)
	local formatPrice = string.format("%s%0.2f", Localization:getInstance():getText("buy.gold.panel.money.mark"), price)
	local buyLabel = Localization:getInstance():getText("add.step.panel.buy.btn.txt")
	self.buyButton:setString(formatPrice..buyLabel)
	self.buyButton:setColorMode(kGroupButtonColorMode.blue)
	self.buyButton:addEventListener(DisplayEvents.kTouchTap,  function ()
			self:onRmbBuyBtnTap()
		end)
	self:showButtonLoopAnimation(self.buyButton.groupNode)
end

function PayPanelSingleSms:onCloseBtnTap()
	if self.peDispatcher then 
		self.peDispatcher:dispatchPanelCloseEvent()
	end

	PayPanelConfirmBase.onCloseBtnTap(self)
end

function PayPanelSingleSms:onRmbBuyBtnTap()
	local function rebecomeEnable()
		self:setBuyBtnEnabled(true)
		if self.oneYuanPanel and not self.oneYuanPanel.isDisposed and self.oneYuanPanel.setBuyBtnEnabled then 
			self.oneYuanPanel:setBuyBtnEnabled(true)
		end
	end

	self:setBuyBtnEnabled(false)
	if self.oneYuanPanel and not self.oneYuanPanel.isDisposed and self.oneYuanPanel.setBuyBtnEnabled then 
		self.oneYuanPanel:setBuyBtnEnabled(false)
	end
	setTimeOut(rebecomeEnable, 5)
	--这里注意 玩家调起的是短代支付 短代没有一元特价 要把id改回正常的
	self.goodsIdInfo:setGoodsIdChange(GoodsIdChangeType.kNormal)

	if self.peDispatcher then 
		self.peDispatcher:dispatchPanelPayEvent(self.paymentType)
	end
end

function PayPanelSingleSms:setBuyBtnEnabled(isEnable)
	if self.buyButton and not self.buyButton.isDisposed then 
		self.buyButton:setEnabled(isEnable)
	end
end

function PayPanelSingleSms:popout()
	PayPanelConfirmBase.popout(self)

	--弹出一元限购面板时 这个值不为空 
	if self.otherPaymentTable and #self.otherPaymentTable>0 then 
		self.moveHeight = 170
		self:showOneYuanPanel()
	end
end

function PayPanelSingleSms:removePopout()
	if self.oneYuanPanel and not self.oneYuanPanel.isDisposed then 
		self.oneYuanPanel:removePopout()
		self.oneYuanPanel = nil
	end
	PayPanelConfirmBase.removePopout(self)
end

function PayPanelSingleSms:showOneYuanPanel()
	if #self.otherPaymentTable == 1 then 
		self.oneYuanPanel = PayPanelOneYuanSingle:create(self.peDispatcher, self.goodsIdInfo, self.otherPaymentTable[1], self)
	else
		self.oneYuanPanel = PayPanelOneYuanMulti:create(self.peDispatcher, self.goodsIdInfo, self.otherPaymentTable, self)
	end
	if self.oneYuanPanel then self.oneYuanPanel:popout() end
end

function PayPanelSingleSms:create(peDispatcher, goodsIdInfo, paymentType, otherPaymentTable)
	local panel = PayPanelSingleSms.new()
	panel.peDispatcher = peDispatcher
	panel.goodsIdInfo = goodsIdInfo
	panel.paymentType = paymentType
	panel.otherPaymentTable = otherPaymentTable
	panel:loadRequiredResource("ui/BuyConfirmPanel.json")
	panel:init()
	return panel
end