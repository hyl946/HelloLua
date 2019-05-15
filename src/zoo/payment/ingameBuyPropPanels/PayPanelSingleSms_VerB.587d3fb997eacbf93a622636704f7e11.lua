PayPanelSingleSms_VerB = class(PayPanelConfirmBase_VerB)

local PayPanelSingleSms_VerB_video = class(PayPanelSingleSms_VerB)


function PayPanelSingleSms_VerB:getExtendedHeight()
	return 720
end

function PayPanelSingleSms_VerB:getFoldedHeight()
	return 450
end

function PayPanelSingleSms_VerB:init()
	if self.skinMode == "light" then
		self.ui	= self:buildInterfaceGroup("PayPanelSingleSms_newLight") 
	else
		self.ui	= self:buildInterfaceGroup("PayPanelSingleSms_newDrak") 
	end
	PayPanelConfirmBase_VerB.init(self)
	self:initBaseUI()
end

function PayPanelSingleSms_VerB:initBaseUI()
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

function PayPanelSingleSms_VerB:onCloseBtnTap()
	if self.peDispatcher then 
		self.peDispatcher:dispatchPanelCloseEvent()
	end

	PayPanelConfirmBase_VerB.onCloseBtnTap(self)
end

function PayPanelSingleSms_VerB:onRmbBuyBtnTap()
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

function PayPanelSingleSms_VerB:setBuyBtnEnabled(isEnable)
	if self.buyButton and not self.buyButton.isDisposed then 
		self.buyButton:setEnabled(isEnable)
	end
end

function PayPanelSingleSms_VerB:popout()
	PayPanelConfirmBase_VerB.popout(self)

	--弹出一元限购面板时 这个值不为空 
	if self.otherPaymentTable and #self.otherPaymentTable>0 then 
		self.moveHeight = 170
		self:showOneYuanPanel()
	end
end

function PayPanelSingleSms_VerB:removePopout()
	if self.oneYuanPanel and not self.oneYuanPanel.isDisposed then 
		self.oneYuanPanel:removePopout()
		self.oneYuanPanel = nil
	end
	PayPanelConfirmBase_VerB.removePopout(self)
end

function PayPanelSingleSms_VerB:showOneYuanPanel()
	if #self.otherPaymentTable == 1 then 
		self.oneYuanPanel = PayPanelOneYuanSingle:create(self.peDispatcher, self.goodsIdInfo, self.otherPaymentTable[1], self)
	else
		self.oneYuanPanel = PayPanelOneYuanMulti:create(self.peDispatcher, self.goodsIdInfo, self.otherPaymentTable, self)
	end
	if self.oneYuanPanel then self.oneYuanPanel:popout() end
end

function PayPanelSingleSms_VerB:create(peDispatcher, goodsIdInfo, paymentType, otherPaymentTable, isDarkSkin)
	local panel = nil
	if goodsIdInfo and goodsIdInfo.isFreeVideo then
		panel = PayPanelSingleSms_VerB_video.new()
	else
		panel = PayPanelSingleSms_VerB.new()
		if isDarkSkin then
			panel:changeSkinModeToDark(true)
		end
	end
	
	panel.peDispatcher = peDispatcher
	panel.goodsIdInfo = goodsIdInfo
	printx( 1 , "   PayPanelSingleSms_VerB:create   goodsIdInfo = " , goodsIdInfo)
	panel.paymentType = paymentType
	panel.otherPaymentTable = otherPaymentTable
	panel:loadRequiredResource("ui/BuyConfirmPanel.json")
	panel:init()
	return panel
end


-------- video ad

function PayPanelSingleSms_VerB_video:init()
	self.ui	= self:buildInterfaceGroup("PayPanelSingleSms_newAD")
	PayPanelConfirmBase_VerB.init(self)

	self:initBaseUI()

	self:initBtnVideoAD()
end

function PayPanelSingleSms_VerB_video:setBuyBtnEnabled(isEnable)
	self.class.super.setBuyBtnEnabled(self,isEnable)
	local _ = self.btnVideoAD and not self.btnVideoAD.isDisposed and self.btnVideoAD:setEnabled(isEnable)
end

function PayPanelSingleSms_VerB_video:getExtendedHeight()
	return self.class.super.getExtendedHeight(self)+50
end

function PayPanelSingleSms_VerB_video:getFoldedHeight()
	return self.class.super.getFoldedHeight(self)+50
end
