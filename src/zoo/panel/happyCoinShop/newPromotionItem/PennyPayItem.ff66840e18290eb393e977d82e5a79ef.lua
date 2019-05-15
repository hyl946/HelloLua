local BaseShopItem = require 'zoo.panel.happyCoinShop.newPromotionItem.BaseShopItem'

local PennyPayItem = class(BaseShopItem)

function PennyPayItem:create(config, builder, onBuySuccess, onTimeOut)
	local instance = PennyPayItem.new()
	instance:init(config, builder, onBuySuccess, onTimeOut)
	return instance
end

function PennyPayItem:__initUI( ... )
	self.onlyGold = true
	self.isPenny = true

	self.realUI = self.builder:buildGroup('newWindShop/1_45/promotionItem_penny_pay')

	BaseShopItem.__initUI(self)
	self:initGold()
end

function PennyPayItem:dc()
	local payResult = self.dcAndroidInfo:getResult()
	DcUtil:UserTrack({
			category = "onecent",
			sub_category = "alipay_promotion_payend",
			result = payResult,
		})
end

function PennyPayItem:buySuccess()
	self:__unregisterTimerUpdate()
	if not self.config.test then
		PromotionManager:getInstance():onBuyPennySuccess()
	end
	if self.onBuySuccess then
		self.onBuySuccess()
	end
	self:dc()
end

function PennyPayItem:onBuyFail( ... )
	self:dc()
end

function PennyPayItem:onBuyCancel( ... )
	self:dc()
end
	
function PennyPayItem:getPrice(goodsId)
	return MetaManager.getInstance():getGoodMeta(goodsId).thirdRmb * 0.001
end

function PennyPayItem:decreaseTimer()
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
		PromotionManager:getInstance():onTimeOut()
	end
end

function PennyPayItem:initDiscountUI( buyBtnUI )
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

function PennyPayItem:initTimer()
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

function PennyPayItem:__initBuyBtnUI( ... )
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

function PennyPayItem:initGold( ... )
	local items = self:getGiftItems(self.config.goodsId)
	local goldItem = table.find(items, function ( v )
		return v.itemId == ItemType.GOLD
	end)

	local cash = self.realUI:getChildByName('icon'):getChildByName('gold'):getChildByName('num')
	cash:setText(goldItem.num)
	cash:setScale(0.75)
	cash:setAnchorPoint(ccp(0.5, 0.5))
	cash:setPositionY(cash:getPositionY() - 1)
end

return PennyPayItem