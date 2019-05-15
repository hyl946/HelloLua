local Panel = class(VerticalTileLayout)

function Panel:create( width )
	local panel = Panel.new()
	panel:init(width)
	return panel
end

function Panel:init( width )
	VerticalTileLayout.init(self, width)

	for i = 1, 10 do
		setTimeOut(function ( ... )
			local item = LayerColor:createWithColor(ccc3(0, 0, 0), self.width, 100)
			local itemContainer = ItemInLayout:create()
			item:ignoreAnchorPointForPosition(false)
			item:setAnchorPoint(ccp(0.5, 1))
			itemContainer:setContent(item)
			itemContainer.content:setScale(0.1)
			self:addItemAt(itemContainer, 1, true)
		end, i)
		
	end
end

function Panel:popout( ... )
	self:setPositionY(self:getPositionY() - 200)
	self:setPositionX(400)
	PopoutManager:sharedInstance():add(self, true)
end

return Panel