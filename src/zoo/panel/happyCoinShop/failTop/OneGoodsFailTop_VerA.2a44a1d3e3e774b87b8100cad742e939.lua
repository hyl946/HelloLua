local BaseFailTop = require 'zoo.panel.happyCoinShop.failTop.BaseFailTop'

local OneGoodsFailTop_VerA = class(BaseFailTop)

function OneGoodsFailTop_VerA:create(config, builder, onBuySuccess, onTimeOut)
	local instance = OneGoodsFailTop_VerA.new()
	instance:init(config, builder, onBuySuccess, onTimeOut)
	return instance
end

function OneGoodsFailTop_VerA:__initUI( ... )

	self.realUI = self.builder:buildGroup('newWindShop/promotion.fail.top/A_1')

	BaseFailTop.__initUI(self)

	self:initItems()
end

function OneGoodsFailTop_VerA:initItems( ... )
	self:initGold()
end

function OneGoodsFailTop_VerA:initGold( ... )

	local items = self:getGiftItems(self.config.goodsId)
	local goldItem = table.find(items, function ( v )
		return v.itemId == ItemType.GOLD
	end)

	local cash = self.realUI:getChildByName('cash')
	cash:setText(goldItem.num)
	cash:setScale(0.75)
	cash:setAnchorPoint(ccp(0, 0.5))
	cash:setPositionY(cash:getPositionY() - 1)
end



function OneGoodsFailTop_VerA:initDiscountUI( ... )
	-- body
end

function OneGoodsFailTop_VerA:__initPriceUI( ... )
	-- body
end

function OneGoodsFailTop_VerA:stopDiscountAnim( ... )
	-- body
end



function OneGoodsFailTop_VerA:__initBuyBtnUI( ... )
	local buyBtnUI = self.realUI:getChildByName('btn')
	self.buyBtnUI = buyBtnUI
	
	self:initDiscountUI(buyBtnUI)

	self.buyBtn = GroupButtonBase:create(buyBtnUI)

	local currencySymbol, isLongSymbol = BuyHappyCoinManager:getCurrencySymbol('cny')
	if isLongSymbol then 
		self.buyBtn:setString(string.format("特惠价%s%.0f", currencySymbol, self.price/100.0))
	else
		self.buyBtn:setString(string.format("特惠价%s%.2f", currencySymbol, self.price/100.0))
	end

	self.buyBtn:addEventListener(DisplayEvents.kTouchTap, function()
		if not self.config.test then
			DcUtil:UserTrack({
				category = "shop",
				sub_category = "wm_promotion_click",
				goods_id = self.config.goodsId
			})
		end
		self:buy()
	end)

	self:playBtnAnim()

end

return OneGoodsFailTop_VerA