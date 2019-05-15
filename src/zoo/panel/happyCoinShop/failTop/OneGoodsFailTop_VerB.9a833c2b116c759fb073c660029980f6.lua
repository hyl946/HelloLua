local BaseFailTop = require 'zoo.panel.happyCoinShop.failTop.BaseFailTop'

local OneGoodsFailTop_VerB = class(BaseFailTop)

function OneGoodsFailTop_VerB:create(config, builder, onBuySuccess, onTimeOut)
	local instance = OneGoodsFailTop_VerB.new()
	instance:init(config, builder, onBuySuccess, onTimeOut)
	return instance
end

function OneGoodsFailTop_VerB:__initUI( ... )
	local skinName, uncommonSkin = WorldSceneShowManager:getInstance():getHomeScenePanelSkin(HomeScenePanelSkinType.kLevelFailProOne)
	self.realUI = self.builder:buildGroup(skinName)

	BaseFailTop.__initUI(self)

	self:initGold()
end

function OneGoodsFailTop_VerB:initGold( ... )
	local items = self:getGiftItems(self.config.goodsId)
	local goldItem = table.find(items, function ( v )
		return v.itemId == ItemType.GOLD
	end)

	local num = goldItem.num

	local numUI = self.realUI:getChildByName('icon'):getChildByName('num')
	numUI:setText(tostring(num))
	numUI:setAnchorPoint(ccp(0.5, 0.5))
	numUI:setScale(0.7)
end


function OneGoodsFailTop_VerB:__initPriceUI( ... )
	local ori_price = self.realUI:getChildByName('ori_price')
	local price = self.realUI:getChildByName('price')
	
	ori_price:setColor(hex2ccc3('663300'))
	price:setColor(hex2ccc3('663300'))

	BaseFailTop.__initPriceUI(self, ...)

end

return OneGoodsFailTop_VerB