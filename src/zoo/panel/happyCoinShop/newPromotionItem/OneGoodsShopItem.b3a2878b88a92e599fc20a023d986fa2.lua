local BaseShopItem = require 'zoo.panel.happyCoinShop.newPromotionItem.BaseShopItem'

local OneGoodsShopItem = class(BaseShopItem)

function OneGoodsShopItem:create(config, builder, onBuySuccess, onTimeOut)
	local instance = OneGoodsShopItem.new()
	instance:init(config, builder, onBuySuccess, onTimeOut)
	return instance
end

function OneGoodsShopItem:__initUI( ... )
	self.onlyGold = true

	self.realUI = self.builder:buildGroup('newWindShop/1_45/promotionItem_1_45_1_items')

	BaseShopItem.__initUI(self)
	self:initGold()
end


function OneGoodsShopItem:initGold( ... )
	local items = self:getGiftItems(self.config.goodsId)
	local goldItem = table.find(items, function ( v )
		return v.itemId == ItemType.GOLD or v.itemId == ItemType.STAR_BANK_GOLD
	end)

	local cash = self.realUI:getChildByName('icon'):getChildByName('gold'):getChildByName('num')
	cash:setText(goldItem.num)
	cash:setScale(0.75)
	cash:setAnchorPoint(ccp(0.5, 0.5))
	cash:setPositionY(cash:getPositionY() - 1)
end

return OneGoodsShopItem