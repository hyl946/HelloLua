local BuyItem = class(BaseUI)

BuyItem.resName = 'new.repay/buyItem'
BuyItem.colorMode = kGroupButtonColorMode.blue

function BuyItem:create(builder)
	local buyItem = BuyItem.new()
	buyItem:init(builder)
	return buyItem
end

function BuyItem:init(builder)

	local ui = builder:buildGroup(self.resName)

	BaseUI.init(self, ui)

	self.btnUI = self.ui:getChildByName('btn')
	self.btn = ButtonIconsetBase:create(self.btnUI)
	self.btn:setColorMode(self.colorMode)

	self.payName = self.ui:getChildByName('payName')
	self.discount = self.ui:getChildByName('discount')
	self.iconHolder = self.ui:getChildByName('iconHolder')

	self.__enabled = true

end

function BuyItem:setData( goodsIdInfo, payType )
	self.goodsIdInfo = goodsIdInfo
	self.payType = payType

	local goodsId = self.goodsIdInfo:getGoodsId()
	local goodsType = self.goodsIdInfo:getGoodsType()

	if PaymentManager.getInstance():checkIsNoThirdPayPromotion(self.payType) then 
		goodsId = self.goodsIdInfo:getOriginalGoodsId()
	end

	--价格
	local price = PaymentManager:getPriceByPaymentType(goodsId, goodsType, self.payType)
	local formatPrice = nil
	if price ~= math.floor(price) then
		formatPrice = string.format("%s%0.2f", Localization:getInstance():getText("buy.gold.panel.money.mark"), price)
	else
		formatPrice = string.format("%s%d ", Localization:getInstance():getText("buy.gold.panel.money.mark"), price)
	end
	local buyLabel = Localization:getInstance():getText("add.step.panel.buy.btn.txt")
	self.btn:setString(formatPrice..buyLabel)

	--按钮上的支付图标
	local btnShowConfig = PaymentManager.getInstance():getPaymentShowConfig(self.payType, price)
	-- self.btn:setIconByFrameName(btnShowConfig.smallIcon)

	--支付名称
	self:setPayName(btnShowConfig.name)
	--支付图标
	self.iconHolder:setOpacity(0)
	local payIconBig = Sprite:createWithSpriteFrameName(btnShowConfig.bigIcon)
	payIconBig:setAnchorPoint(ccp(0, 1))
	local iconPos = self.iconHolder:getPosition()
	local iconIndex = self.ui:getChildIndex(self.iconHolder)
	self.ui:addChildAt(payIconBig, iconIndex)
	payIconBig:setPosition(ccp(iconPos.x, iconPos.y))


	--打折显示
	local discountNum = self.goodsIdInfo:getDiscountNum()
	if goodsId == 280 or goodsId == 281 then 
		discountNum = 7
		PayPanelDiscountUI:create(self.discount, discountNum) 
	else
		if PaymentManager.getInstance():checkIsNoThirdPayPromotion(self.payType) or discountNum == 10 then 
			self.discount:setVisible(false)
		else
			PayPanelDiscountUI:create(self.discount, discountNum) 
		end
	end

	if goodsId == 615 then
		-- self.btnUI:setScale(0.7)
	end

	self:createBtnAnimation()

	self.btn:addEventListener(DisplayEvents.kTouchTap, function ()
		self:onBuyBtnTap()
	end)

	self.hasNet = true

end

function BuyItem:getPayType( ... )
	return self.payType
end

function BuyItem:setPayName( payName )
	self.payName:setString(payName)
end

function BuyItem:createBtnAnimation()
	local oriScaleX = self.btnUI:getScaleX()
	local oriScaleY = self.btnUI:getScaleY() 
	local deltaTime = 0.9
	local animations = CCArray:create()
	animations:addObject(CCScaleTo:create(deltaTime, 0.98*oriScaleX, 1.03*oriScaleY))
	animations:addObject(CCScaleTo:create(deltaTime, 1.01*oriScaleX, 0.96*oriScaleY))
	animations:addObject(CCScaleTo:create(deltaTime, 0.98*oriScaleX,1.03*oriScaleY))
	animations:addObject(CCScaleTo:create(deltaTime, oriScaleX, oriScaleY))
	self.btnUI:runAction(CCRepeatForever:create(CCSequence:create(animations)))

	local backgroundUI = self.btnUI:getChildByName("background")
	local function __onButtonTouchBegin( evt )
		if backgroundUI and not backgroundUI.isDisposed then
			backgroundUI:setOpacity(200)
		end
	end
	local function __onButtonTouchEnd( evt )
		if backgroundUI and not backgroundUI.isDisposed then
			backgroundUI:setOpacity(255)
		end
	end
	self.btnUI:addEventListener(DisplayEvents.kTouchBegin, __onButtonTouchBegin)
	self.btnUI:addEventListener(DisplayEvents.kTouchEnd, __onButtonTouchEnd)
end

function BuyItem:onBuyBtnTap()
	if self.__enabled then
		if self.btnTapCallback then 
			self.btnTapCallback(self.payType)
		end
	end
end

function BuyItem:setBtnHasNet(isHasNet, notChangeColor)

	if self.hasNet ~= isHasNet then
		self.hasNet = isHasNet

		if self.btn then 
			if self.hasNet or notChangeColor then
				self.btn:setColorMode(self.colorMode)
			else
				self.btn:setColorMode(kGroupButtonColorMode.grey)
			end
		end
	end
end

function BuyItem:isBtnHasNet( ... )
	return self.hasNet
end

function BuyItem:setBtnCallback( btnTapCallback )
	self.btnTapCallback = btnTapCallback
end

function BuyItem:setEnabled( b )
	self.__enabled = b
end

return BuyItem
