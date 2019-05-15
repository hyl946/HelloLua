local BaseFailTop = require 'zoo.panel.happyCoinShop.failTop.BaseFailTop'

local ThreeGoodsFailTop_VerB = class(BaseFailTop)

function ThreeGoodsFailTop_VerB:create(config, builder, onBuySuccess, onTimeOut)
	local instance = ThreeGoodsFailTop_VerB.new()
	instance:init(config, builder, onBuySuccess, onTimeOut)
	return instance
end

function ThreeGoodsFailTop_VerB:__initUI( ... )
	local skinName, uncommonSkin = WorldSceneShowManager:getInstance():getHomeScenePanelSkin(HomeScenePanelSkinType.kLevelFailProThree)
	self.realUI = self.builder:buildGroup(skinName)

	BaseFailTop.__initUI(self)

	self:initGold()
	self:initProps()
end



function ThreeGoodsFailTop_VerB:initGold( ... )
	local items = self:getGiftItems(self.config.goodsId)
	local goldItem = table.find(items, function ( v )
		return v.itemId == ItemType.GOLD
	end)

	local num = goldItem.num

	local itemUI = self.realUI:getChildByName('item_1')
	itemUI:getChildByName('bg'):setVisible(false)
	self.numUI = itemUI:getChildByName('num')
	self.numUI:setScale(0.7)
	self.numUI:setText(tostring(num))

	local star = itemUI:getChildByName('star')
	self:playStarAnim(star, 9, 1, 5, 2, 15)

	self:createItemMask(itemUI)
end

function ThreeGoodsFailTop_VerB:playStarAnim( starLayer, ... )
	local FPS = 24
	local startFrames = {...}

	local stars = {}

	for i = 1, #startFrames do
		stars[i] = starLayer:getChildByName('star_'..i)
		stars[i]:setVisible(false)

		stars[i]:getChildByName('图层 1'):setOpacity(0.75*255)

		local scale = stars[i]:getScale()

		stars[i]:runAction(CCSequence:createWithTwoActions(CCDelayTime:create((15-startFrames[i])/FPS), CCCallFunc:create(function ( ... )
			if stars[i].isDisposed then return end
			stars[i]:setRotation(-69.2)
			stars[i]:setVisible(true)


			local array = CCArray:create()
			array:addObject(CCCallFunc:create(function ( ... )
				if stars[i].isDisposed then return end
				stars[i]:setScale(scale)
				stars[i]:getChildByName('图层 1'):setVisible(true)
			end))
			array:addObject(CCRotateBy:create(1/FPS, 17.3))
			array:addObject(CCSpawn:createWithTwoActions(CCRotateBy:create(4/FPS, 51.9), CCScaleTo:create(6/FPS, 0.998*scale)))
			array:addObject(CCSpawn:createWithTwoActions(CCRotateBy:create(6/FPS, 75.5), CCScaleTo:create(6/FPS, 0.613*scale)))
			array:addObject(CCCallFunc:create(function ( ... )
				if stars[i].isDisposed then return end
				stars[i]:getChildByName('图层 1'):setVisible(false)
			end))
			array:addObject(CCDelayTime:create(15/FPS))
			local action = CCRepeatForever:create(CCSequence:create(array))
			stars[i]:runAction(action)

		end)))
	end
end

function ThreeGoodsFailTop_VerB:initProps( ... )
	local items = self:getGiftItems(self.config.goodsId)
	local propItems = table.filter(items, function ( v )
		return v.itemId ~= ItemType.GOLD
	end)

	self:setPropItem('item_2', propItems[1])
	self:setPropItem('item_3', propItems[2])

end

function ThreeGoodsFailTop_VerB:setPropItem( nodeName, propItem )
	local itemUI = self.realUI:getChildByName(nodeName)
	itemUI:getChildByName('bg'):setVisible(false)

	itemUI:getChildByName('star_B'):setVisible(false)
	itemUI:getChildByName('star_C'):setVisible(false)
	itemUI:getChildByName('star_D'):setVisible(false)

	
	local holder = itemUI:getChildByName('holder')
	local holderIndex = itemUI:getChildIndex(holder)
	holder:setVisible(false)
	holder:setAnchorPointCenterWhileStayOrigianlPosition()
	local holderPos = holder:getPosition()
	holderPos = ccp(holderPos.x, holderPos.y)

	local numUI = itemUI:getChildByName('num')

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

	numUI:changeFntFile('fnt/skip_level.fnt')
	numUI:setText('x'..tostring(propItem.num))
	numUI:setScale(0.9)
	itemUI:addChildAt(sp, holderIndex)

	local nodeNameMap = {
		['item_2'] = 'star_B',
		['item_3'] = 'star_C',
		['item_4'] = 'star_D',
	}

	local animParamsMap = {
		['item_2'] = {1},
		['item_3'] = {5, 9},
		['item_4'] = {12, 1},
	}

	local lightAnimDelay = {
		['item_2'] = 0.5,
		['item_3'] = 0.8,
		['item_4'] = 1.1,
	}

	local starNodeName = nodeNameMap[nodeName]
	local animParam = animParamsMap[nodeName]
	if (not starNodeName) or (not animParam) then
		return 
	end
	local starLayer = itemUI:getChildByName(starNodeName)
	starLayer:setVisible(true)
	self:playStarAnim(starLayer, unpack(animParam))

	self:createItemMask(itemUI, lightAnimDelay[nodeName])
end

function ThreeGoodsFailTop_VerB:__initPriceUI( ... )
	local ori_price = self.realUI:getChildByName('ori_price')
	local price = self.realUI:getChildByName('price')
	
	ori_price:setColor(hex2ccc3('663300'))
	price:setColor(hex2ccc3('663300'))

	BaseFailTop.__initPriceUI(self, ...)

end

return ThreeGoodsFailTop_VerB