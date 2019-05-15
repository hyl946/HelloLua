
local StoreItemData = class()

function StoreItemData:ctor( type )
	-- self.iapConfig = iapConfig
	-- self.goodsId = goodsId
	self.type = type
end

function StoreItemData:setGiftData( goodsId, iapConfig )
	self.goodsId = goodsId
	self.iapConfig = iapConfig
end

function StoreItemData:setServerConfigGiftIdAndIcon( id, icon )
	self.serverConfigGiftId = id
	self.serverConfigGiftIcon = icon
end

function StoreItemData:setGoldData( productMeta )
	self.productMeta = {}
	self.productMeta.cash = tonumber(productMeta.cash)
	self.productMeta.discount = tonumber(productMeta.discount)
	self.productMeta.extraCash = tonumber(productMeta.extraCash)
	self.productMeta.grade = tonumber(productMeta.grade)
	self.productMeta.price = tonumber(productMeta.price)
	self.productMeta.productId = productMeta.productId
	self.productMeta.id = productMeta.id

	if productMeta.rmb then
		self.productMeta.price = (tonumber(productMeta.rmb) or 0) / 100
	end
end

function StoreItemData:setEndTime( endTime, needShowEndTime )
	self.endTime = endTime
	self.needShowEndTime = needShowEndTime
end

function StoreItemData:setBuyLimit( buyLimit, buyCount )
	self.buyLimit = buyLimit
	self.buyCount = buyCount
end



return StoreItemData