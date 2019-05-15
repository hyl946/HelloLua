local BaseShopItem = require 'zoo.panel.happyCoinShop.newPromotionItem.BaseShopItem'


local BaseFailTop = class(BaseShopItem)

function BaseFailTop:create(config, builder, onBuySuccess, onTimeOut)
	local instance = BaseFailTop.new()
	instance:init(config, builder, onBuySuccess, onTimeOut)
	return instance
end

function BaseFailTop:__initUI( ... )

	--BaseShopItem:__initUI 删减版 不调用 createMask等
	self.price = self:getPrice(self.config.goodsId)
	self.cashNum = self:getGiftNum(ItemType.GOLD)

	self:__initBuyBtnUI()
	self:__initTimerUI()
	self:__initPriceUI()

	self:__decidePayType()

	DcUtil:UserTrack({category = "shop", sub_category = "wm_promotion_source", source = 4})
	self:setSource(4)
end

function BaseFailTop:__decidePayType( ... )
	
	local mainPayment = PaymentManager.getInstance():getDefaultThirdPartPayment()
	local otherThirdPartPayment = PaymentManager.getInstance():getOtherThirdPartPayment(true)
	local repayChooseTable = table.union({mainPayment}, otherThirdPartPayment)

	self:setRepayChooseTable(repayChooseTable)
	self:setPayType(mainPayment)
	
end

function BaseFailTop:__initTimerUI( ... )
	BaseShopItem.__initTimerUI(self, ...)
	self.timer:setScale(0.8)
end

function BaseFailTop:createItemMask( itemUI, delay )

	delay = delay or 0
	--将btn调整到最高层

	if not CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName('newWindShop/light0000') then
		return
	end

	local bg = itemUI:getChildByName('bg')

	local size = bg:getGroupBounds().size
	size = CCSizeMake(size.width, size.height)

	local pos = bg:getPosition()
	pos = ccp(pos.x, pos.y)

	local mask = LayerColor:createWithColor(ccc3(0, 0, 0), size.width, size.height)
	mask:ignoreAnchorPointForPosition(false)
	mask:setAnchorPoint(ccp(0, 1))

	local light = Sprite:createWithSpriteFrameName('newWindShop/light0000')
	light:setAnchorPoint(ccp(1, 1))
	light:setScale(0.3)

	local clipNode = ClippingNode.new(CCClippingNode:create(mask.refCocosObj))

	mask:dispose()
	clipNode:addChild(light)

	itemUI:addChild(clipNode)
	clipNode:setPosition(pos)

	local array = CCArray:create()
	if delay > 0 then
		array:addObject(CCDelayTime:create(delay))
	end
	array:addObject(CCMoveBy:create((20/24.0), ccp(600, 0)))
	array:addObject(CCDelayTime:create(2-delay))
	array:addObject(CCCallFunc:create(function ( ... )
		if light.isDisposed then return end
		light:setPositionX(0)
	end))
	light:runAction(CCRepeatForever:create(CCSequence:create(array)))

end


function BaseFailTop:wrapUI( ui )
	return ui
end

function BaseFailTop:timeOut( ... )
	BaseShopItem.timeOut(self, ...)

	--置灰购买按钮

	self.buyBtn:setColorMode(kGroupButtonColorMode.grey)
	self.buyBtn:removeAllEventListeners()
	self.buyBtn:ad(DisplayEvents.kTouchTap, function ( ... )
		CommonTip:showTip(localize('payment.promotion.error.tip1'))
	end)

	self:stopBtnAnim()
	self:stopDiscountAnim()
end

function BaseFailTop:isInMarketPanel( ... )
	return false
end

return BaseFailTop