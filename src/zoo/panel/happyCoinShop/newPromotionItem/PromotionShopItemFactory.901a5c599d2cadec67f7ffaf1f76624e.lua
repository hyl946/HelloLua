local PromotionShopItemFactory = class()

local instance

function PromotionShopItemFactory:getInstance( ... )
	if not instance then 
		instance = PromotionShopItemFactory.new()
		instance:init()
	end
	return instance
end

function PromotionShopItemFactory:init( ... )
	self.oneGoodsShopItem = require 'zoo.panel.happyCoinShop.newPromotionItem.OneGoodsShopItem'
	self.twoGoodsShopItem = require 'zoo.panel.happyCoinShop.newPromotionItem.TwoGoodsShopItem'
	self.threeGoodsShopItem = require 'zoo.panel.happyCoinShop.newPromotionItem.ThreeGoodsShopItem'
	self.fourGoodsShopItem = require 'zoo.panel.happyCoinShop.newPromotionItem.FourGoodsShopItem'
	self.fiveGoodsShopItem = require 'zoo.panel.happyCoinShop.newPromotionItem.FiveGoodsShopItem'
	self.fourGoodsShopItemNoGold = require 'zoo.panel.happyCoinShop.newPromotionItem.FourGoodsShopItemNoGold'
end

function PromotionShopItemFactory:getPromotionShopItem( config )
	local items, hasGold = self:getGiftItems(config.goodsId)
	if not hasGold then
		return self.fourGoodsShopItemNoGold
	end
	if #items == 3 then
		return self.threeGoodsShopItem
	elseif #items == 4 then
		return self.fourGoodsShopItem
	elseif #items >= 5 then
		return self.fiveGoodsShopItem
	elseif #items == 2 then
		return self.twoGoodsShopItem
	else
		return self.oneGoodsShopItem
	end
end

function PromotionShopItemFactory:getGiftItems(goodsId)
	local items = MetaManager.getInstance():getGoodMeta(goodsId).items
	local hasGold = false
	for _, v in ipairs(items) do
		if v.itemId == ItemType.GOLD or v.itemId == ItemType.STAR_BANK_GOLD then
			hasGold = true
			break
		end
	end
	return items, hasGold
end

return PromotionShopItemFactory