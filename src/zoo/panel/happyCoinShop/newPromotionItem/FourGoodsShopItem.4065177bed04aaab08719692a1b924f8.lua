local BaseShopItem = require 'zoo.panel.happyCoinShop.newPromotionItem.BaseShopItem'
local ThreeGoodsShopItem = require 'zoo.panel.happyCoinShop.newPromotionItem.ThreeGoodsShopItem'

local FourGoodsShopItem = class(ThreeGoodsShopItem)

function FourGoodsShopItem:create(config, builder, onBuySuccess, onTimeOut)
	local instance = FourGoodsShopItem.new()
	instance:init(config, builder, onBuySuccess, onTimeOut)
	return instance
end

function FourGoodsShopItem:__initUI( ... )
	self.onlyGold = false

	self.realUI = self.builder:buildGroup('newWindShop/1_45/promotionItem_1_45_4_items')
	

	BaseShopItem.__initUI(self)
	self:initGold()
	self:initProps()
end


function FourGoodsShopItem:initProps( ... )
	local items = self:getGiftItems(self.config.goodsId)
	local propItems = table.filter(items, function ( v )
		return v.itemId ~= ItemType.GOLD
	end)

	self:setPropItem('item_2', propItems[1])
	self:setPropItem('item_3', propItems[2])
	self:setPropItem('item_4', propItems[3])
end

return FourGoodsShopItem