---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2018-10-18 11:14:28
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   dan.liang
-- @Last Modified time: 2018-12-07 16:58:46
---------------------------------------------------------------------------------------
local BaseShopItem = require 'zoo.panel.happyCoinShop.newPromotionItem.BaseShopItem'
local ThreeGoodsShopItem = require 'zoo.panel.happyCoinShop.newPromotionItem.ThreeGoodsShopItem'

local FiveGoodsShopItem = class(ThreeGoodsShopItem)

function FiveGoodsShopItem:create(config, builder, onBuySuccess, onTimeOut)
	local instance = FiveGoodsShopItem.new()
	instance:init(config, builder, onBuySuccess, onTimeOut)
	return instance
end

function FiveGoodsShopItem:__initUI( ... )
	self.onlyGold = false

	self.realUI = self.builder:buildGroup('newWindShop/1_45/promotionItem_1_45_5_items')
	

	BaseShopItem.__initUI(self)
	self:initGold()
	self:initProps()
end


function FiveGoodsShopItem:initProps( ... )
	local items = self:getGiftItems(self.config.goodsId)
	local propItems = table.filter(items, function ( v )
		return v.itemId ~= ItemType.GOLD
	end)

	self:setPropItem('item_2', propItems[1])
	self:setPropItem('item_3', propItems[2])
	self:setPropItem('item_4', propItems[3])
	self:setPropItem('item_5', propItems[4])
end

return FiveGoodsShopItem