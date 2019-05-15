local Container = require('zoo.panel.endGameProp.lottery.Container')

local CenterCon = class(Container)

function CenterCon:create( holder )
	local node = CenterCon.new(CCNode:create())
	node:initCenterCon(holder)
	return node
end

function CenterCon:initCenterCon( holder)
	self:initContainer()

	local w = holder:getContentSize().width * holder:getScaleX()
	local h = holder:getContentSize().height * holder:getScaleY()

	self:setSize(CCSizeMake(w, h))

	local pos = holder:getPosition()
	self:setPosition(ccp(pos.x, pos.y))

end

function CenterCon:getMinSize( ... )
	local children = self:getChildrenList()[1]
	return children:getMinSize()
end

function CenterCon:_layout( ... )
	local child = self:getChildrenList()[1]
	local childSize = child:getFinalSize()
	local size = self:getFinalSize()

	child:setPositionX((size.width - childSize.width)/2)
	child:setPositionY(-(size.height - childSize.height)/2)

end

return CenterCon