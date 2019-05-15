IosSalesItemBubble = class(LayerColor)

function IosSalesItemBubble:ctor()
	self.isSpecial = nil
	self.itemId = nil
	self.itemNum = nil
end

function IosSalesItemBubble:init()
	LayerColor.initLayer(self)	
	local builder = InterfaceBuilder:createWithContentsOfFile("ui/IosSalesPromotion.json")
	if not self.isSpecial then 
		self.ui = builder:buildGroup("ItemBubbleOne")
	else
		self.ui = builder:buildGroup("ItemBubbleTwo")
	end

	local spriteRect = self.ui:getGroupBounds()
	self.uiSize = {width = spriteRect.size.width, height = spriteRect.size.height}
	self:changeWidthAndHeight(self.uiSize.width, self.uiSize.height)
	self:setAnchorPoint(ccp(0.5, 0.5))
	self:addChild(self.ui)
	self.ui:setPosition(ccp(0, self.uiSize.height))
	self:setOpacity(0)

	self.bubble = self.ui:getChildByName("bubble")
	self.bubble:setAnchorPointWhileStayOriginalPosition(ccp(0.5,0.5))

	self.flag = self.ui:getChildByName("flag")
	if self.flag then 
		self.flag:setAnchorPointWhileStayOriginalPosition(ccp(0.5, 0.5))
		self.flag:setVisible(false)
	end
	self.numLabel = self.ui:getChildByName("num")
	self.numLabel:setText('x'..self.itemNum)
	self.numLabel:setScale(1.3)

	local ph = self.ui:getChildByName('item1')
    local iconBuilder = InterfaceBuilder:create(PanelConfigFiles.properties)
    local icon = iconBuilder:buildGroup('Prop_'..self.itemId)
    ph:setVisible(false)
    ph:getParent():addChildAt(icon, ph:getZOrder())
    icon:setPositionX(ph:getPositionX())
    icon:setPositionY(ph:getPositionY())
    icon:setScale(ph:getContentSize().width * ph:getScaleX() / icon:getGroupBounds().size.width)
    self.icon = icon
end

function IosSalesItemBubble:play()
	local oriScale = self:getScale()
	local oriScaleStar 
	self:setScale(0)
	if self.flag then 
		oriScaleStar = self.flag:getScale()
		self.flag:setScale(0) 
		self.flag:setVisible(true)
	end
	local arr = CCArray:create()
	arr:addObject(CCDelayTime:create(self.delayTime))
	arr:addObject(CCScaleTo:create(1/6, 1.2 * oriScale))
	arr:addObject(CCScaleTo:create(1/12, 0.9 * oriScale))
	if self.flag then 
		arr:addObject(CCCallFunc:create(function ()
			local arrStar = CCArray:create()
			local sArrOne = CCArray:create()
			local sArrTwo = CCArray:create()
			sArrOne:addObject(CCScaleTo:create(1/6, 1.5 * oriScaleStar))
			sArrOne:addObject(CCRotateTo:create(1/6, 15))
			arrStar:addObject(CCSpawn:create(sArrOne))
			sArrTwo:addObject(CCScaleTo:create(1/12, 1 * oriScaleStar))
			sArrTwo:addObject(CCRotateTo:create(1/12, 0))
			arrStar:addObject(CCSpawn:create(sArrTwo))
			self.flag:runAction(CCSequence:create(arrStar))
		end))
	end
	arr:addObject(CCScaleTo:create(1/12, 1 * oriScale))
	arr:addObject(CCCallFunc:create(function ()
		local bubbleOriScale = self.bubble:getScale()
		local actArr = CCArray:create()
		actArr:addObject(CCEaseSineOut:create(CCScaleTo:create(0.9 * bubbleOriScale, 0.95 * bubbleOriScale, 1)))
		actArr:addObject(CCEaseSineIn:create(CCScaleTo:create(0.9 * bubbleOriScale, 1 * bubbleOriScale, 0.95)))
		actArr:addObject(CCEaseSineOut:create(CCScaleTo:create(0.6 * bubbleOriScale, 1 * bubbleOriScale, 1)))
		self.bubble:runAction(CCRepeatForever:create(CCSequence:create(actArr)))
	end))
	self:runAction(CCSequence:create(arr))
end

function IosSalesItemBubble:getIcon()
	return self.icon	
end

function IosSalesItemBubble:create(itemId, itemNum, delayTime, isSpecial)
	local bubble = IosSalesItemBubble.new()
	bubble.itemId = itemId
	bubble.itemNum = itemNum
	bubble.delayTime = delayTime or 0
	bubble.isSpecial = isSpecial
	bubble:init()
	return bubble
end


--------------------------------------
-----------IosSalesItemCoin-----------
--------------------------------------
IosSalesItemCoin = class(LayerColor)

function IosSalesItemCoin:ctor()
	self.itemNum = nil
end

function IosSalesItemCoin:init()
	LayerColor.initLayer(self)	
	local builder = InterfaceBuilder:createWithContentsOfFile("ui/IosSalesPromotion.json")
	self.ui = builder:buildGroup("ItemGoldCoin")

	self.icon = self.ui:getChildByName("coin")
	local spriteRect = self.ui:getGroupBounds()
	self.uiSize = {width = spriteRect.size.width, height = spriteRect.size.height}
	self:changeWidthAndHeight(self.uiSize.width, self.uiSize.height)
	self:setAnchorPoint(ccp(0.5, 0.5))
	self:addChild(self.ui)
	self.ui:setPosition(ccp(0, self.uiSize.height))
	self:setOpacity(0)

	self.star = self.ui:getChildByName("star")
	self.star:setAnchorPointWhileStayOriginalPosition(ccp(0.5, 0.5))
	self.star:setVisible(false)

	self.numLabel = self.ui:getChildByName("num")
	self.numLabel:setText('x'..self.itemNum)
	self.numLabel:setScale(1.3)
end

function IosSalesItemCoin:getIcon()
	return self.icon	
end

function IosSalesItemCoin:play()
	local oriScale = self:getScale()
	local oriScaleStar = self.star:getScale()
	self:setScale(0)
	self.star:setScale(0)
	self.star:setVisible(true)
	local arr = CCArray:create()
	arr:addObject(CCDelayTime:create(self.delayTime))
	arr:addObject(CCScaleTo:create(1/6, 1.2 * oriScale))
	arr:addObject(CCScaleTo:create(1/8, 0.9 * oriScale))
	arr:addObject(CCCallFunc:create(function ()
		local arrStar = CCArray:create()
		local sArrOne = CCArray:create()
		local sArrTwo = CCArray:create()
		sArrOne:addObject(CCScaleTo:create(1/6, 1.5 * oriScaleStar))
		sArrOne:addObject(CCRotateTo:create(1/6, 15))
		arrStar:addObject(CCSpawn:create(sArrOne))
		sArrTwo:addObject(CCScaleTo:create(1/12, 1 * oriScaleStar))
		sArrTwo:addObject(CCRotateTo:create(1/12, 0))
		arrStar:addObject(CCSpawn:create(sArrTwo))
		self.star:runAction(CCSequence:create(arrStar))
	end))
	arr:addObject(CCScaleTo:create(1/12, 1 * oriScale))
	self:runAction(CCSequence:create(arr))
end

function IosSalesItemCoin:create(itemNum, delayTime)
	local coin = IosSalesItemCoin.new()
	coin.itemNum = itemNum
	coin.delayTime = delayTime or 0
	coin:init()
	return coin
end
