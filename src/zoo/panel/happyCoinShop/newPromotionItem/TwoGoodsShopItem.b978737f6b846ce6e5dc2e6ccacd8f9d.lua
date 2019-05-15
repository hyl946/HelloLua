---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2018-10-18 10:33:14
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   dan.liang
-- @Last Modified time: 2018-10-18 11:45:56
---------------------------------------------------------------------------------------
local BaseShopItem = require 'zoo.panel.happyCoinShop.newPromotionItem.BaseShopItem'
local ThreeGoodsShopItem = require 'zoo.panel.happyCoinShop.newPromotionItem.ThreeGoodsShopItem'

local TwoGoodsShopItem = class(ThreeGoodsShopItem)

function TwoGoodsShopItem:create(config, builder, onBuySuccess, onTimeOut)
	local instance = TwoGoodsShopItem.new()
	instance:init(config, builder, onBuySuccess, onTimeOut)
	return instance
end

function TwoGoodsShopItem:__initUI( ... )
	self.onlyGold = false

	self.realUI = self.builder:buildGroup('newWindShop/1_45/promotionItem_1_45_2_items')

	BaseShopItem.__initUI(self)

	self:initGold()
	self:initProps()

end

function TwoGoodsShopItem:initProps( ... )
	local items = self:getGiftItems(self.config.goodsId)
	local propItems = table.filter(items, function ( v )
		return v.itemId ~= ItemType.GOLD
	end)

	self:setPropItem('item_2', propItems[1])
end

return TwoGoodsShopItem