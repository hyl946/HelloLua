local BaseFailTop = require 'zoo.panel.happyCoinShop.failTop.BaseFailTop'
local ThreeGoodsFailTop_VerA = require 'zoo.panel.happyCoinShop.failTop.ThreeGoodsFailTop_VerA'

local FourGoodsFailTop_VerA = class(ThreeGoodsFailTop_VerA)

function FourGoodsFailTop_VerA:create(config, builder, onBuySuccess, onTimeOut)
	local instance = FourGoodsFailTop_VerA.new()
	instance:init(config, builder, onBuySuccess, onTimeOut)
	return instance
end

function FourGoodsFailTop_VerA:__initUI( ... )

	self.realUI = self.builder:buildGroup('newWindShop/promotion.fail.top/A_4')

	BaseFailTop.__initUI(self)

	self:initItems()
end

function FourGoodsFailTop_VerA:initProps( ... )
	local items = self:getGiftItems(self.config.goodsId)
	local propItems = table.filter(items, function ( v )
		return v.itemId ~= ItemType.GOLD
	end)

	self:setPropItem('item_1', propItems[1])
	self:setPropItem('item_2', propItems[2])
	self:setPropItem('item_3', propItems[3])

end


return FourGoodsFailTop_VerA