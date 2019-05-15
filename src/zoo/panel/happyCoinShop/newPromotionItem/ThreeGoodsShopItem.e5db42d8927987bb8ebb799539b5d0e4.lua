local BaseShopItem = require 'zoo.panel.happyCoinShop.newPromotionItem.BaseShopItem'

local ThreeGoodsShopItem = class(BaseShopItem)

function ThreeGoodsShopItem:create(config, builder, onBuySuccess, onTimeOut)
	local instance = ThreeGoodsShopItem.new()
	instance:init(config, builder, onBuySuccess, onTimeOut)
	return instance
end

function ThreeGoodsShopItem:__initUI( ... )
	self.onlyGold = false

	self.realUI = self.builder:buildGroup('newWindShop/1_45/promotionItem_1_45_3_items')

	BaseShopItem.__initUI(self)

	self:initGold()
	self:initProps()

end

function ThreeGoodsShopItem:initGold( ... )
	local items = self:getGiftItems(self.config.goodsId)
	local goldItem = table.find(items, function ( v )
		return v.itemId == ItemType.GOLD
	end)

	local num = goldItem.num

	local itemUI = self.realUI:getChildByName('item_1')
	itemUI:getChildByName('bg_light'):setVisible(false)
	itemUI:getChildByName('star'):setVisible(false)
	self.numUI = itemUI:getChildByName('num')
	self.numUI:setScale(0.7)
	self.numUI:setText(tostring(num))

end

function ThreeGoodsShopItem:initProps( ... )
	local items = self:getGiftItems(self.config.goodsId)
	local propItems = table.filter(items, function ( v )
		return v.itemId ~= ItemType.GOLD
	end)

	self:setPropItem('item_2', propItems[1])
	self:setPropItem('item_3', propItems[2])
end

function ThreeGoodsShopItem:setPropItem( nodeName, propItem )
	local itemUI = self.realUI:getChildByName(nodeName)
	if not propItem then
		itemUI:removeFromParentAndCleanup(true)
		return
	end
	itemUI:getChildByName('bg_light'):setVisible(false)
	itemUI:getChildByName('star_B'):setVisible(false)
	itemUI:getChildByName('star_C'):setVisible(false)
	itemUI:getChildByName('star_D'):setVisible(false)
	
	local holder = itemUI:getChildByName('holder')
	holder:setVisible(false)
	holder:setAnchorPointCenterWhileStayOrigianlPosition()
	local holderPos = holder:getPosition()
	holderPos = ccp(holderPos.x, holderPos.y)

	local numUI = itemUI:getChildByName('num')
	local numRect = nil
	if itemUI:getChildByName('numSize') then
		numRect = itemUI:getChildByName('numSize'):getGroupBounds(itemUI)
		itemUI:getChildByName('numSize'):removeFromParentAndCleanup(true)
	end

	local itemNum = propItem.num
	if propItem.itemId == ItemType.INFINITE_ENERGY_BOTTLE_ONE_MINUTE then
		itemNum = 1
	end

	local sp = ResourceManager:sharedInstance():buildItemSpriteWithDecorate(propItem.itemId, propItem.num)
	sp:setAnchorPoint(ccp(0.5, 0.5))
	sp:setPosition(holderPos)

	if propItem.itemId == 10005 or propItem.itemId == 10010 then
		sp:setAnchorPoint(ccp(0.35, 0.62))
	end

	local targetWidth = holder:getContentSize().width * holder:getScaleX()
	local spWidth = sp:getContentSize().width
	sp:setScale(targetWidth/spWidth*1.1)

	numUI:changeFntFile('fnt/skip_level.fnt')
	numUI:setText('x'..tostring(itemNum))
	numUI:setScale(0.8)
	itemUI:addChild(sp)

	-- if numRect then
	-- 	numUI:removeFromParentAndCleanup(false)
	-- 	local numSize = numUI:getContentSize()
	-- 	if numSize.width > numRect.size.width then
	-- 		local numScale = numRect.size.width / numSize.width
	-- 		numUI:setScale(numScale)
	-- 		numUI:setPositionX(numRect.origin.x + (numRect.size.width - numSize.width * numScale) / 2)
	-- 		numUI:setPositionY(numRect.origin.y + (numRect.size.height + numSize.height * numScale) / 2)
	-- 	end
	-- 	itemUI:addChild(numUI)
	-- end
end

return ThreeGoodsShopItem