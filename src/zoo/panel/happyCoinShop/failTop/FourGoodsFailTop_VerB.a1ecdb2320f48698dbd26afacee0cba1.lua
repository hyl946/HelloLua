local ThreeGoodsFailTop_VerB = require 'zoo.panel.happyCoinShop.failTop.ThreeGoodsFailTop_VerB'
local BaseFailTop = require 'zoo.panel.happyCoinShop.failTop.BaseFailTop'

local FourGoodsFailTop_VerB = class(ThreeGoodsFailTop_VerB)

function FourGoodsFailTop_VerB:create(config, builder, onBuySuccess, onTimeOut)
	local instance = FourGoodsFailTop_VerB.new()
	instance:init(config, builder, onBuySuccess, onTimeOut)
	return instance
end

function FourGoodsFailTop_VerB:__initUI( ... )
	local skinName, uncommonSkin = WorldSceneShowManager:getInstance():getHomeScenePanelSkin(HomeScenePanelSkinType.kLevelFailProFour)
	self.realUI = self.builder:buildGroup(skinName)

	BaseFailTop.__initUI(self)

	self:initGold()
	self:initProps()
end



function FourGoodsFailTop_VerB:initProps( ... )
	local items = self:getGiftItems(self.config.goodsId)
	local propItems = table.filter(items, function ( v )
		return v.itemId ~= ItemType.GOLD
	end)

	self:setPropItem('item_2', propItems[1])
	self:setPropItem('item_3', propItems[2])
	self:setPropItem('item_4', propItems[3])
end

return FourGoodsFailTop_VerB