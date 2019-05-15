local BaseFailTop = require 'zoo.panel.happyCoinShop.failTop.BaseFailTop'
local OneGoodsFailTop_VerA = require 'zoo.panel.happyCoinShop.failTop.OneGoodsFailTop_VerA'

local ThreeGoodsFailTop_VerA = class(OneGoodsFailTop_VerA)

function ThreeGoodsFailTop_VerA:create(config, builder, onBuySuccess, onTimeOut)
	local instance = ThreeGoodsFailTop_VerA.new()
	instance:init(config, builder, onBuySuccess, onTimeOut)
	return instance
end

function ThreeGoodsFailTop_VerA:__initUI( ... )

	self.realUI = self.builder:buildGroup('newWindShop/promotion.fail.top/A_3')

	BaseFailTop.__initUI(self)

	self:initItems()
end

function ThreeGoodsFailTop_VerA:initItems( ... )
	self:initGold()
	self:initProps()
end


function ThreeGoodsFailTop_VerA:initProps( ... )
	local items = self:getGiftItems(self.config.goodsId)
	local propItems = table.filter(items, function ( v )
		return v.itemId ~= ItemType.GOLD
	end)

	self:setPropItem('item_1', propItems[1])
	self:setPropItem('item_2', propItems[2])

end

function ThreeGoodsFailTop_VerA:setPropItem( nodeName, propItem )
	local itemUI = self.realUI:getChildByName(nodeName)
	
	local holder = itemUI:getChildByName('iconHolder')
	local holderIndex = itemUI:getChildIndex(holder)
	holder:setVisible(false)
	holder:setAnchorPointCenterWhileStayOrigianlPosition()
	local holderPos = holder:getPosition()
	holderPos = ccp(holderPos.x, holderPos.y)


	local sp = ResourceManager:sharedInstance():buildItemSprite(propItem.itemId)
	sp:setAnchorPoint(ccp(0.5, 0.5))
	sp:setPosition(holderPos)

	if propItem.itemId == 10005 or propItem.itemId == 10010 then
		sp:setAnchorPoint(ccp(0.35, 0.62))
	end

	if ItemType:getRealIdByTimePropId(propItem.itemId) == ItemType.ADD_THREE_STEP then
		sp:setPositionY(sp:getPositionY() - 2)
	end

	local targetWidth = holder:getContentSize().width * holder:getScaleX()
	local spWidth = sp:getContentSize().width
	sp:setScale(targetWidth/spWidth*1.1)

	itemUI:addChildAt(sp, holderIndex)

	local numUI = itemUI:getChildByName('num')
	local num = TextField:createWithUIAdjustment(numUI:getChildByName('size'), numUI:getChildByName('label'))
	num:changeFntFile('fnt/skip_level.fnt')
	num:setText('x'..tostring(propItem.num))
	numUI:addChild(num)
	numUI:setScale(numUI:getScaleX()*0.85)
end


return ThreeGoodsFailTop_VerA