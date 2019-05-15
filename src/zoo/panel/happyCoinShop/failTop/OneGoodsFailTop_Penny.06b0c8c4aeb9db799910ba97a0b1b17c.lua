--[[
 * OneGoodsFailTop_Penny
 * @date    2017-11-23 16:08:49
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

local BaseFailTop = require 'zoo.panel.happyCoinShop.failTop.BaseFailTop'

local OneGoodsFailTop_Penny = class(BaseFailTop)

function OneGoodsFailTop_Penny:create(config, builder, onBuySuccess, onTimeOut)
	local instance = OneGoodsFailTop_Penny.new()
	instance:init(config, builder, onBuySuccess, onTimeOut)
	return instance
end

function OneGoodsFailTop_Penny:__initUI( ... )
	self.isPenny = true
	local skinName, uncommonSkin = WorldSceneShowManager:getInstance():getHomeScenePanelSkin(HomeScenePanelSkinType.kLevelFailProPenny)

	self.realUI = self.builder:buildGroup(skinName)

	BaseFailTop.__initUI(self)

	self:initGold()

	DcUtil:UserTrack({
			category = "onecent",
			sub_category = "alipay_promotion_source",
			source = 4,
		})
end

function OneGoodsFailTop_Penny:__decidePayType( ... )
	
	local mainPayment = Payments.ALIPAY
	local otherThirdPartPayment = PaymentManager.getInstance():getOtherThirdPartPayment(true)
	local repayChooseTable = table.union({mainPayment}, otherThirdPartPayment)

	self:setRepayChooseTable(repayChooseTable)
	self:setPayType(mainPayment)
end

function OneGoodsFailTop_Penny:initDiscountUI( buyBtnUI )
	local discountContainerUI = buyBtnUI:getChildByName('discount')
	local pos = discountContainerUI:getPosition()
	pos = ccp(pos.x, pos.y)
	pos = buyBtnUI:convertToWorldSpace(pos)
	pos = self.realUI:convertToNodeSpace(pos)
	discountContainerUI:setPosition(pos)

	discountContainerUI:removeFromParentAndCleanup(false)
	self.realUI:addChild(discountContainerUI)
	self.discountContainerUI = discountContainerUI
	discountContainerUI:setAnchorPointWhileStayOriginalPosition(ccp(0, 0))

	self.discountContainerUI:runAction(CCSequence:createWithTwoActions(
		CCDelayTime:create(48/24.0),
		CCCallFunc:create(function ( ... )
			self:playDiscountAnim()
		end)
	))
end

function OneGoodsFailTop_Penny:decreaseTimer()
	if self.isDisposed then return end
	local sec 
	if self.config.test then
		sec = 3600
	else
		sec = PromotionManager:getInstance():getPennyPayRestTime()
	end

	if sec > 0 then
		self.hour = math.floor(sec / 3600)
		self.min = math.floor(sec / 60) % 60
		self.sec = sec % 60
		self.timer:setText(string.format('%02d:%02d:%02d', self.hour, self.min, self.sec))
		if self.timer.x then
			self.timer:setPositionX(self.timer.x)
		end
	else
		self.timer:setText('00:00:00')
		self:timeOut()
	end
end

function OneGoodsFailTop_Penny:initTimer()
	local sec 
	if self.config.test then
		sec = 3600
	else
		sec = PromotionManager:getInstance():getPennyPayRestTime()
	end
	self.hour = math.floor(sec / 3600)
	self.min = math.floor(sec / 60) % 60
	self.sec = sec % 60
end

function OneGoodsFailTop_Penny:__initBuyBtnUI( ... )
	local buyBtnUI = self.realUI:getChildByName('btn')
	self.buyBtnUI = buyBtnUI
	self:initDiscountUI(buyBtnUI)
	self.buyBtn = ButtonIconsetBase:create(buyBtnUI)
	
	local currencySymbol, isLongSymbol = BuyHappyCoinManager:getCurrencySymbol(self.config.priceLocale or 'cny')
	local showPrice = self.config.iapPrice or self.price/100

	if isLongSymbol then 
		self.buyBtn:setString(string.format("%s%.0f", currencySymbol, showPrice))
	else
		self.buyBtn:setString(string.format("%s%.2f", currencySymbol, showPrice))
	end
	self.buyBtn:setIconByFrameName("common_icon/pay/icon_ali_small0000")
	self.buyBtn:addEventListener(DisplayEvents.kTouchTap, function()
		if not self.config.test then
			DcUtil:UserTrack({
				category = "onecent",
				sub_category = "alipay_promotion_click",
			})
		end
		self:buy()
	end)

	self:playBtnAnim()

end

function OneGoodsFailTop_Penny:dc()
	local payResult = self.dcAndroidInfo:getResult()
	DcUtil:UserTrack({
			category = "onecent",
			sub_category = "alipay_promotion_payend",
			result = payResult,
		})
end

function OneGoodsFailTop_Penny:getPrice(goodsId)
	return MetaManager.getInstance():getGoodMeta(goodsId).thirdRmb * 0.001
end

function OneGoodsFailTop_Penny:buySuccess()
	self:__unregisterTimerUpdate()
	if not self.config.test then
		PromotionManager:getInstance():onBuyPennySuccess()
	end
	if self.onBuySuccess then
		self.onBuySuccess()
	end
	self:dc()
end

function OneGoodsFailTop_Penny:onBuyFail( ... )
	self:dc()
end

function OneGoodsFailTop_Penny:onBuyCancel( ... )
	self:dc()
end

function OneGoodsFailTop_Penny:initGold( ... )
	local items = self:getGiftItems(self.config.goodsId)
	local goldItem = table.find(items, function ( v )
		return v.itemId == ItemType.GOLD
	end)

	local num = goldItem.num

	local numUI = self.realUI:getChildByName('icon'):getChildByName('num')
	numUI:setText(tostring(num))
	numUI:setAnchorPoint(ccp(0.5, 0.5))
	numUI:setScale(0.7)
end


function OneGoodsFailTop_Penny:__initPriceUI( ... )
	local ori_price = self.realUI:getChildByName('ori_price')
	local price = self.realUI:getChildByName('price')
	
	ori_price:setColor(hex2ccc3('663300'))
	price:setColor(hex2ccc3('663300'))

	BaseFailTop.__initPriceUI(self, ...)

end

return OneGoodsFailTop_Penny