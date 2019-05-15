local Thanksgiving2018CollectAddFivePart = class(BaseUI)



function Thanksgiving2018CollectAddFivePart:init(ui, actCollectionNum)
	BaseUI.init(self, ui)

	local bubblePartUI = self.ui:getChildByName("bubblePart")
	local bear = self.ui:getChildByName("bear")

	local collectIcon1 = bubblePartUI:getChildByName("collect1")
	local iconSize = collectIcon1:getContentSize()
	local pos1 = collectIcon1:getPosition()
	local numToShow1 = actCollectionNum * 10
	local numLabel1 = BitmapText:create("", "tempFunctionRes/CountdownParty/fnt/2018newyeareve_5.fnt")
	bubblePartUI:addChild(numLabel1)
	numLabel1:setAnchorPoint(ccp(0, 0.5))
	numLabel1:setText(numToShow1)
	local labelSize1 = numLabel1:getGroupBounds().size
	numLabel1:setPosition(ccp(pos1.x, pos1.y - iconSize.height/2 - 2))
	collectIcon1:setPositionX(pos1.x + labelSize1.width)

	local collectIcon2 = bubblePartUI:getChildByName("collect2")
	local pos2 = collectIcon2:getPosition()
	local numToShow2 = actCollectionNum 
	local numLabel2 = BitmapText:create("", "tempFunctionRes/CountdownParty/fnt/2018newyeareve_5.fnt")
	bubblePartUI:addChild(numLabel2)
	numLabel2:setAnchorPoint(ccp(0, 0.5))
	numLabel2:setText(numToShow2)
	local labelSize2 = numLabel2:getGroupBounds().size
	numLabel2:setPosition(ccp(pos2.x, pos2.y - iconSize.height/2 - 2))
	collectIcon2:setPositionX(pos2.x + labelSize2.width)

	bubblePartUI:setScale(0)
	bear:setScaleY(0)

	bubblePartUI:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.5), CCEaseElasticOut:create(CCScaleTo:create(0.5, 1))))
	bear:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.5), CCScaleTo:create(0.1, 1, 1)))
end

function Thanksgiving2018CollectAddFivePart:create(ui, actCollectionNum)
	local addFivePart = Thanksgiving2018CollectAddFivePart.new()
	addFivePart:init(ui, actCollectionNum)
	return addFivePart
end

return Thanksgiving2018CollectAddFivePart