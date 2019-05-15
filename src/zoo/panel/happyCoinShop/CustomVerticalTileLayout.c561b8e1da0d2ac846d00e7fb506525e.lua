local CustomVerticalTileLayout = class(VerticalTileLayout)

function CustomVerticalTileLayout:create( width )
	local CustomVerticalTileLayout = CustomVerticalTileLayout.new()
	CustomVerticalTileLayout:init(width)
	return CustomVerticalTileLayout
end

function CustomVerticalTileLayout:init( ... )
	VerticalTileLayout.init(self, ...)

	self.animationDuration = 0.8
	self.itemVerticalMargin = 13
end

function CustomVerticalTileLayout:getHeight()
	if #self.items == 0 then return 0 end

	local x = self.itemHorizontalMargin
	local y = 0

	for i, v in pairs(self.items) do 
		local itemHeight = v:getHeight() or v:getGroupBounds().size.height
		y = y + itemHeight + self.itemVerticalMargin
	end
	y = y -  self.itemVerticalMargin
	return y
end


function CustomVerticalTileLayout:addItemAt(item, arrayIndex, playAnimation)

	if not item then return end
	if arrayIndex > #self.items + 1 then return end

	table.insert(self.items, arrayIndex, item)

	for k, v in pairs(self.items) do
		v:setArrayIndex(k)
	end

	local actionNode
	if item.content.getActionNode then
		actionNode = item.content:getActionNode()
	end

	if playAnimation and actionNode then

		actionNode:setScale(0.01)
		actionNode:stopAllActions()
		actionNode:runAction(self:getInsertingItemAnimation())
	end

	self.container:addChild(item)
	self:__layout(playAnimation)
	self:updateViewArea(self.visibleTop, self.visibleBottom)
end

function CustomVerticalTileLayout:getInsertingItemAnimation(item)
	local fadeIn = CCFadeIn:create(self.animationDuration)

	local scaleActionArray = CCArray:create()
	scaleActionArray:addObject(CCScaleTo:create(0.00001, 0.356, 0.059))
	scaleActionArray:addObject(CCScaleTo:create(self.animationDuration * 2 / 9.0, 0.83, 0.254))
	scaleActionArray:addObject(CCScaleTo:create(self.animationDuration * 7 / 9.0, 1, 1))

	local a_actions = CCArray:create()
	a_actions:addObject(fadeIn)
	a_actions:addObject(CCSequence:create(scaleActionArray))
	local spawn = CCSpawn:create(a_actions)
	local ease = CCEaseBackOut:create(spawn)
	return ease
end	

function CustomVerticalTileLayout:getMoveToAnimation(ccp)
	local moveTo = CCMoveTo:create(self.animationDuration, ccp)
	local ease = CCEaseBackOut:create(moveTo)
	return ease
end

return CustomVerticalTileLayout