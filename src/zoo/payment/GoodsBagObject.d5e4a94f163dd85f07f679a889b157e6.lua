require "zoo.common.ItemType"

GoodsItemObject = class()

--不在goods表中配置道具 需要计算其价值的 需配置在这里 rmb以分为单位
local SpecialItemValueConfig = {
	[ItemType.COIN] = {num = 1000, coin = 1000, qCash = 4, rmb = 40},
	[ItemType.GOLD] = {num = 1, coin = 250, qCash = 1, rmb = 10},
}

function GoodsItemObject:cotr()
	self._numUnit = 1
	self._priceUnit = 0
	self.moneyType = nil
	self.totalPrice = 0
	self.itemId = nil
	self.num = 0
end

function GoodsItemObject:create(itemId, itemNum, moneyType)
	local itemObj = GoodsItemObject.new()
	itemObj:init(itemId, itemNum, moneyType)
	return itemObj
end

function GoodsItemObject:init(itemId, itemNum, moneyType)
	self.itemId = itemId
	self.num = itemNum
	self.moneyType = moneyType
	self:initItemConfig()
end

function GoodsItemObject:initItemConfig()
	local goodsMeta = MetaManager.getInstance():getGoodMetaByItemID(self.itemId)
	self._numUnit = 1
	self._priceUnit = 0
	if goodsMeta then
		self._numUnit = goodsMeta.items[1].num
		if self.moneyType == MoneyType.kCoin then
			self._priceUnit = goodsMeta.coin
		elseif self.moneyType == MoneyType.kGold then
			self._priceUnit = goodsMeta.qCash
		elseif self.moneyType == MoneyType.kRmb then
			self._priceUnit = goodsMeta.rmb
		end
	elseif SpecialItemValueConfig[itemId] then 
		local config = SpecialItemValueConfig[itemId]
		self._numUnit = config.num
		if self.moneyType == MoneyType.kCoin then
			self._priceUnit = config.coin
		elseif self.moneyType == MoneyType.kGold then
			self._priceUnit = config.qCash
		elseif self.moneyType == MoneyType.kRmb then
			self._priceUnit = config.rmb
		end	
	end
end

function GoodsItemObject:addNum(num)
	self.num = self.num + num
end

function GoodsItemObject:getTotalPrice()
	return self._priceUnit * self.num / self._numUnit
end

---------------------------------------------------------
GoodsBagObject = class()

function GoodsBagObject:ctor()
	self.sellPrice = 0
	self.goodsItemList = nil
	self.moneyType = nil
end

function GoodsBagObject:create(itemList, sellPrice, moneyType)
	local obj = GoodsBagObject.new()
	obj:init(itemList, sellPrice, moneyType)
	return obj
end

function GoodsBagObject:createWithGoodsMeta(goodsMeta, moneyType)
	local itemList = goodsMeta.items
	local sellPrice = 0
	if moneyType == MoneyType.kCoin then
		sellPrice = goodsMeta.coin
	elseif moneyType == MoneyType.kGold then
		sellPrice = goodsMeta.discountQCash
	elseif moneyType == MoneyType.kRmb then
		sellPrice = goodsMeta.discountRmb
	end
	return GoodsBagObject:create(itemList, sellPrice, moneyType)
end

function GoodsBagObject:init(itemList, sellPrice, moneyType)
	self.sellPrice = sellPrice
	self.moneyType = moneyType
	self.goodsItemList = {}
	for _, v in pairs(itemList) do
		local goodsItem = self.goodsItemList[v.itemId]
		if not goodsItem then
			goodsItem = GoodsItemObject:create(v.itemId, v.num, moneyType)
			self.goodsItemList[v.itemId] = goodsItem
		else
			goodsItem.num = goodsItem.num + v.num
		end
	end
end

function GoodsBagObject:getTotalPrice()
	local totalPrice = 0
	for _, v in pairs(self.goodsItemList) do
		totalPrice = totalPrice + v:getTotalPrice()
	end
	return totalPrice
end

function GoodsBagObject:getItemSellPrice(itemId)
	local goodsItem = self.goodsItemList[itemId]
	if goodsItem then
		local itemTotalPrice = goodsItem:getTotalPrice()
		local bagTotalPrice = self:getTotalPrice()
		if bagTotalPrice > 0 then
			local sellPrice = self.sellPrice * itemTotalPrice  / bagTotalPrice
			return tonumber(string.format("%.2f", sellPrice)) or 0
		end
	end
	return 0
end