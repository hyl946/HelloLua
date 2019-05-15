local Container = require('zoo.panel.endGameProp.lottery.Container')

local HShrinkCon = class(Container)

function HShrinkCon:create( ... )
	local node = HShrinkCon.new(CCNode:create())
	node:initHShrinkCon()
	return node
end

function HShrinkCon:initHShrinkCon( ... )
	self:initContainer()
end

function HShrinkCon:getMinSize( ... )
	local children = self:getChildrenList()
	local w = 0
	local h = 0
	for _, child in ipairs(children) do
		w = w + child:getFinalSize().width
		h = math.max(h, child:getFinalSize().height)
	end
	return CCSizeMake(w, h)
end

function HShrinkCon:_layout( ... )

	local minSize = self:getMinSize()
	local size = self:getSize()

	if size.width ~= minSize.width or size.height ~= minSize.height then
		self:setSize(minSize)
	end

	local x = 0
	for _, child in ipairs(self:getChildrenList() or {}) do
		child:setPositionX(x)
		x = x + child:getFinalSize().width
		child:setPositionY(-(minSize.height - child:getFinalSize().height)/2)
	end
end

return HShrinkCon