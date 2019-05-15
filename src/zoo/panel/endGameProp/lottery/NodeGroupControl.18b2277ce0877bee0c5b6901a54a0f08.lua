local Control = require('zoo.panel.endGameProp.lottery.Control')

local NodeGroupControl = class(Control)

function NodeGroupControl:create( nodeGroup )
	local node = NodeGroupControl.new(CCNode:create())
	node:initNodeGroupControl(nodeGroup)
	return node
end

function NodeGroupControl:initNodeGroupControl( nodeGroup )
	self:initControl()


	local parent = nodeGroup:getParent()
	local pos = nodeGroup:getPosition()
	pos = ccp(pos.x, pos.y)

	if parent then
		nodeGroup:removeFromParentAndCleanup(false)
	end

	self:addChild(nodeGroup)
	self.nodeGroup = nodeGroup
	self:_notify_content_change()
	nodeGroup:setPosition(ccp(0, 0))

	if parent then
		parent:addChild(self)
		self:setPosition(pos)
	end

	local layoutUtils =  require 'zoo.panel.happyCoinShop.utils'
	layoutUtils.setNodeLeftTopPos(nodeGroup, ccp(0, 0), self)
end

function NodeGroupControl:_notify_content_change( ... )
	local nodeGroupBounds = self.nodeGroup:getGroupBounds(self)
	self:setSize(nodeGroupBounds.size)
	self:setMinSize(nodeGroupBounds.size)
end


function NodeGroupControl:getNode( ... )
	return self.nodeGroup
end

return NodeGroupControl