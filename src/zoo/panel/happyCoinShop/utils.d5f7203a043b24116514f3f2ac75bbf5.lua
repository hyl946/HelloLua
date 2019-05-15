local utils

utils = {}
	--ancestor是node的上层节点
	--缩放node, 使得在ancestor的坐标系这一层上, node的groupBounds.size是size那么大
	--ancestor为nil时，使得在世界坐标系这一层上, node的groupBounds.size是size那么大
function utils.scaleNodeToSize(node, size, ancestor, isUniformScale)
	local nowSize = node:getGroupBounds(ancestor).size
	local nowScaleX, nowScaleY = node:getScaleX(), node:getScaleY()
	local sx = size.width / nowSize.width * nowScaleX
	local sy = size.height / nowSize.height * nowScaleY
	node:setScaleX(sx)
	node:setScaleY(sy)

	if isUniformScale then
		node:setScale(math.min(sx, sy))
	end
end

	--使得node.groupBounds.origin = pos, pos是ancestor坐标系中的一个点
	--ancestor缺省时, pos是世界坐标系中一个点
function utils.setNodeOriginPos(node, pos, ancestor)
	local zeroPoint = ccp(0, 0)
	local onePoint = ccp(1, 1)
	local sx, sy
	local dx, dy
	if ancestor then
		local zeroPointInWorld = node:convertToWorldSpace(zeroPoint)
		local onePointInWorld = node:convertToWorldSpace(onePoint)
		local zeroPointInAncestor = ancestor:convertToNodeSpace(zeroPointInWorld)
		local onePointInAncestor = ancestor:convertToNodeSpace(onePointInWorld)
		dx = onePointInAncestor.x - zeroPointInAncestor.x
		dy = onePointInAncestor.y - zeroPointInAncestor.y
	else
		local zeroPointInWorld = node:convertToWorldSpace(zeroPoint)
		local onePointInWorld = node:convertToWorldSpace(onePoint)
		dx = onePointInWorld.x - zeroPointInWorld.x
		dy = onePointInWorld.y - zeroPointInWorld.y
	end
	sx = dx / node:getScaleX()
	sy = dy / node:getScaleY()
	local size = node:getContentSize()
	node:setPosition(ccp(0, 0))
	local origin = node:getGroupBounds(ancestor).origin
	local offsetX = pos.x - origin.x
	local offsetY = pos.y - origin.y
	local realPos = ccp(
		offsetX/sx,
		offsetY/sy
	)
	node:setPosition(realPos)
end

	-- 基本同上, 设置左上角
function utils.setNodeLeftTopPos(node, pos, ancestor)
	local size = node:getGroupBounds(ancestor).size
	utils.setNodeOriginPos(node, ccp(
		pos.x,
		pos.y - size.height
	), ancestor)
end

	-- 基本同上, 设置右上角
function utils.setNodeRightTopPos(node, pos, ancestor)
	local size = node:getGroupBounds(ancestor).size
	utils.setNodeOriginPos(node, ccp(
		pos.x - size.width,
		pos.y - size.height
	), ancestor)
end

	-- 基本同上, 设置右下角
function utils.setNodeRightBottomPos(node, pos, ancestor)
	local size = node:getGroupBounds(ancestor).size
	utils.setNodeOriginPos(node, ccp(
		pos.x - size.width,
		pos.y
	), ancestor)
end

	-- 基本同上, 设置中心
function utils.setNodeCenterPos(node, pos, ancestor)
	local size = node:getGroupBounds(ancestor).size
	utils.setNodeOriginPos(node, ccp(
		pos.x - size.width/2,
		pos.y - size.height/2
	), ancestor)
end

	
	--令node居中在ancestor中, 缺省则居中在世界坐标
function utils.centerNode(node, ancestor)
	local width
	local height

	if ancestor then
		local size = ancestor:getContentSize()
		width = size.width
		height = size.height
	else
		local director = Director:sharedDirector()
		local size = director:getVisibleSize()
		width = size.width
		height = size.height
	end

	utils.setNodeCenterPos(node, ccp(
		width/2,
		height/2
	), ancestor)

end

	--基本同上, 只是水平居中
function utils.horizontalCenterNode(node, ancestor)
	local oldPos = ccp(
		node:getPositionX(),
		node:getPositionY()
	)
	utils.centerNode(node, ancestor)
	node:setPositionY(oldPos.y)
end

	--基本同上, 只是竖直居中
function utils.verticalCenterNode(node, ancestor)
	local oldPos = ccp(
		node:getPositionX(),
		node:getPositionY()
	)
	utils.centerNode(node, ancestor)
	node:setPositionX(oldPos.x)
end
	--竖直排列一组node, 只改动y坐标, 不改动任何x坐标
function utils.verticalLayoutItems(items)
	local mostMarginBottom = 0
	local mostPaddingBottom = 0
	local function getItem(item)
		local margin = item.margin or {}
		local padding = item.padding or {}
		return {
			node = item.node,
			margin = {
				left = margin.left or 0,
				right = margin.right or 0,
				top = margin.top or 0,
				bottom = margin.bottom or 0,
			},
			padding = {
				left = padding.left or 0,
				right = padding.right or 0,
				top = padding.top or 0,
				bottom = padding.bottom or 0,
			}
		}
	end
	for index, item in ipairs(items) do
		item = getItem(item)
		local node = item.node
		local parent = node:getParent()
		local margin = item.margin
		local padding = item.padding
		local size = node:getGroupBounds(parent).size

		local nowSpacingY = mostMarginBottom - mostPaddingBottom
		local itemSpacingY = margin.top
		local realSpacingY = math.max(nowSpacingY, itemSpacingY)

		local oldPos = ccp(
			node:getPositionX(),
			node:getPositionY()
		)
		utils.setNodeLeftTopPos(node, ccp(
			oldPos.x, 
			-(mostPaddingBottom + realSpacingY + padding.top)
		), parent)
		node:setPositionX(oldPos.x)
		mostPaddingBottom = mostPaddingBottom + realSpacingY + padding.top + size.height + padding.bottom
		mostMarginBottom = mostPaddingBottom + margin.bottom
	end
end

	--水平排列一组node, 只改动x坐标, 不改动任何y坐标
function utils.horizontalLayoutItems(items)
	local mostMarginRight = 0
	local mostPaddingRight = 0
	local function getItem(item)
		local margin = item.margin or {}
		local padding = item.padding or {}
		return {
			node = item.node,
			margin = {
				left = margin.left or 0,
				right = margin.right or 0,
				top = margin.top or 0,
				bottom = margin.bottom or 0,
			},
			padding = {
				left = padding.left or 0,
				right = padding.right or 0,
				top = padding.top or 0,
				bottom = padding.bottom or 0,
			}
		}
	end
	for index, item in ipairs(items) do
		item = getItem(item)
		local node = item.node
		local parent = node:getParent()
		local margin = item.margin
		local padding = item.padding
		local size = node:getGroupBounds(parent).size

		local nowSpacingX = mostMarginRight - mostPaddingRight
		local itemSpacingX = margin.left
		local realSpacingX = math.max(nowSpacingX, itemSpacingX)

		local oldPos = ccp(
			node:getPositionX(),
			node:getPositionY()
		)
		utils.setNodeLeftTopPos(node, ccp(
			mostPaddingRight + realSpacingX + padding.left,
			oldPos.y
		), parent)
		node:setPositionY(oldPos.y)
		mostPaddingRight = mostPaddingRight + realSpacingX + padding.left + size.width + padding.right
		mostMarginRight = mostPaddingRight + margin.right
	end
end

	--取一组node整体的groupbounds
function utils.getNodesGroupBounds(nodes, ancestor)
	local groupBounds = nil
	table.each(nodes, function(node)
		local bounds = node:getGroupBounds(ancestor)
		if groupBounds == nil then
			groupBounds = bounds
		else
			local origin1 = groupBounds.origin
			local destin1 = ccp(
				groupBounds.origin.x + groupBounds.size.width,
				groupBounds.origin.y + groupBounds.size.height
			)

			local origin2 = bounds.origin
			local destin2 = ccp(
				bounds.origin.x + bounds.size.width,
				bounds.origin.y + bounds.size.height
			)

			local origin = ccp(
				math.min(origin1.x, origin2.x),
				math.min(origin1.y, origin2.y)
			)

			local destin = ccp(
				math.max(destin1.x, destin2.x),
				math.max(destin1.y, destin2.y)
			)

			groupBounds.origin = origin
			groupBounds.size = CCSizeMake(
				destin.x - origin.x,
				destin.y - origin.y
			)
		end
	end)
	return groupBounds
end

	--设置一组节点整体的左下角坐标, 类似于在flash中一次选中多个玩意儿进行移动
function utils.setNodesOriginPos(nodes, pos, ancestor)
	local nodesGroupBounds = utils.getNodesGroupBounds(nodes, ancestor)
	for k, node in ipairs(nodes) do
		local nodeBounds = node:getGroupBounds(ancestor)
		local realPos = ccp(
			pos.x + nodeBounds.origin.x - nodesGroupBounds.origin.x,
			pos.y + nodeBounds.origin.y - nodesGroupBounds.origin.y
		)
		utils.setNodeOriginPos(node, realPos, ancestor)
	end
end
	--类似上一个
function utils.setNodesLeftTopPos(nodes, pos, ancestor)
	local nodesGroupBounds = utils.getNodesGroupBounds(nodes, ancestor)
	for k, node in ipairs(nodes) do
		local nodeBounds = node:getGroupBounds(ancestor)
		local realPos = ccp(
			pos.x + nodeBounds.origin.x - nodesGroupBounds.origin.x,
			pos.y - ((nodesGroupBounds.origin.y + nodesGroupBounds.size.height) - (nodeBounds.origin.y + nodeBounds.size.height))
		)
		utils.setNodeLeftTopPos(node, realPos, ancestor)
	end
end
	--类似上一个
function utils.setNodesRightTopPos(nodes, pos, ancestor)
	local nodesGroupBounds = utils.getNodesGroupBounds(nodes, ancestor)
	for k, node in ipairs(nodes) do
		local nodeBounds = node:getGroupBounds(ancestor)
		local realPos = ccp(
			pos.x - ((nodesGroupBounds.origin.x + nodesGroupBounds.size.width) - (nodeBounds.origin.x + nodeBounds.size.width)),
			pos.y - ((nodesGroupBounds.origin.y + nodesGroupBounds.size.height) - (nodeBounds.origin.y + nodeBounds.size.height))
		)
		utils.setNodeRightTopPos(node, realPos, ancestor)
	end
end
	--类似上一个
function utils.setNodesRightBottomPos(nodes, pos, ancestor)
	local nodesGroupBounds = utils.getNodesGroupBounds(nodes, ancestor)
	for k, node in ipairs(nodes) do
		local nodeBounds = node:getGroupBounds(ancestor)
		local realPos = ccp(
			pos.x - ((nodesGroupBounds.origin.x + nodesGroupBounds.size.width) - (nodeBounds.origin.x + nodeBounds.size.width)),
			pos.y + nodeBounds.origin.y - nodesGroupBounds.origin.y
		)
		utils.setNodeRightBottomPos(node, realPos, ancestor)
	end
end
	--类似上一个
function utils.setNodesCenterPos(nodes, pos, ancestor)
	local nodesGroupBounds = utils.getNodesGroupBounds(nodes, ancestor)
	for k, node in ipairs(nodes) do
		local nodeBounds = node:getGroupBounds(ancestor)
		local realPos = ccp(
			pos.x - ((nodesGroupBounds.origin.x + nodesGroupBounds.size.width/2) - (nodeBounds.origin.x + nodeBounds.size.width/2)),
			pos.y - ((nodesGroupBounds.origin.y + nodesGroupBounds.size.height/2) - (nodeBounds.origin.y + nodeBounds.size.height/2))
		)
		utils.setNodeCenterPos(node, realPos, ancestor)
	end
end

	
	--令一组node居中在ancestor中, 缺省则居中在世界坐标
function utils.centerNodes(nodes, ancestor)
	local width
	local height

	if ancestor then
		local size = ancestor:getContentSize()
		width = size.width
		height = size.height
	else
		local director = Director:sharedDirector()
		local size = director:getVisibleSize()
		width = size.width
		height = size.height
	end

	utils.setNodesCenterPos(nodes, ccp(
		width/2,
		height/2
	), ancestor)

end
	--水平居中一组node
function utils.horizontalCenterNodes(nodes, ancestor)
	for k, node in ipairs(nodes) do
		node.__oldPos = ccp(
			node:getPositionX(),
			node:getPositionY()
		)
	end
	utils.centerNodes(nodes, ancestor)
	for k, node in ipairs(nodes) do
		node:setPositionY(node.__oldPos.y)
		node.__oldPos = nil
	end
end

	--基本同上, 只是竖直居中
function utils.verticalCenterNodes(nodes, ancestor)
	for k, node in ipairs(nodes) do
		node.__oldPos = ccp(
			node:getPositionX(),
			node:getPositionY()
		)
	end
	utils.centerNodes(nodes, ancestor)
	for k, node in ipairs(nodes) do
		node:setPositionX(node.__oldPos.x)
		node.__oldPos = nil
	end
end

	--从外观上将一组nodes的左边界和node的左边界对齐
	--nodes和node、nodes中的每一个node互相之间可以在不同的层次上
function utils.leftAlignNodes(nodes, targetNode, ancestor)
	if targetNode == nil then
		targetNode = nodes[1]
	end
	local targetOrigin = targetNode:getGroupBounds(ancestor).origin
	table.each(nodes, function(node)
		local oldPosY = node:getPositionY() 
		utils.setNodeOriginPos(node, ccp(targetOrigin.x, 0), ancestor)
		node:setPositionY(oldPosY)
	end)
end

function utils.rightAlignNodes(nodes, targetNode, ancestor)
	if targetNode == nil then
		targetNode = nodes[1]
	end
	local targetBounds = targetNode:getGroupBounds(ancestor)
	local targetOrigin = targetBounds.origin
	local targetRightX = targetOrigin.x + targetBounds.size.width
	table.each(nodes, function(node)
		local oldPosY = node:getPositionY() 
		utils.setNodeRightTopPos(node, ccp(targetRightX, 0), ancestor)
		node:setPositionY(oldPosY)
	end)
end

function utils.verticalCenterAlignNodes(nodes, targetNode, ancestor)
	if targetNode == nil then
		targetNode = nodes[1]
	end
	local targetBounds = targetNode:getGroupBounds(ancestor)
	local targetOrigin = targetBounds.origin
	local targetX = targetOrigin.x + targetBounds.size.width/2
	table.each(nodes, function(node)
		local oldPosY = node:getPositionY() 
		utils.setNodeCenterPos(node, ccp(targetX, 0), ancestor)
		node:setPositionY(oldPosY)
	end)
end

function utils.topAlignNodes(nodes, targetNode, ancestor)
	if targetNode == nil then
		targetNode = nodes[1]
	end
	local targetBounds = targetNode:getGroupBounds(ancestor)
	local targetOrigin = targetBounds.origin
	local targetY = targetOrigin.y + targetBounds.size.height
	table.each(nodes, function(node)
		local oldPosX = node:getPositionX() 
		utils.setNodeLeftTopPos(node, ccp(0, targetY), ancestor)
		node:setPositionX(oldPosX)
	end)
end
	
function utils.bottomAlignNodes(nodes, targetNode, ancestor)
	if targetNode == nil then
		targetNode = nodes[1]
	end
	local targetBounds = targetNode:getGroupBounds(ancestor)
	local targetOrigin = targetBounds.origin
	local targetY = targetOrigin.y
	table.each(nodes, function(node)
		local oldPosX = node:getPositionX() 
		utils.setNodeRightBottomPos(node, ccp(0, targetY), ancestor)
		node:setPositionX(oldPosX)
	end)
end
	
function utils.horizontalCenterAlignNodes(nodes, targetNode, ancestor)
	if targetNode == nil then
		targetNode = nodes[1]
	end
	local targetBounds = targetNode:getGroupBounds(ancestor)
	local targetOrigin = targetBounds.origin
	local targetY = targetOrigin.y + targetBounds.size.height/2
	table.each(nodes, function(node)
		local oldPosX = node:getPositionX() 
		utils.setNodeCenterPos(node, ccp(0, targetY), ancestor)
		node:setPositionX(oldPosX)
	end)
end

local MarginType = {
	kLEFT = 1,
	kRIGHT = 2,
	kTOP = 3,
	kBOTTOM = 4
}

utils.MarginType = MarginType

function utils.setNodeRelativePos( node, marginType, distance, ancestor )
	local posX = node:getPositionX()
	local posY = node:getPositionY()

	local left = 0
	local right = 0
	local top = 0
	local bottom = 0

	if ancestor then
		local size = ancestor:getContentSize()
		right = size.width
		top = size.height
	else
		local vo = Director:sharedDirector():getVisibleOrigin()
		local vs = Director:sharedDirector():getVisibleSize()

		left = vo.x
		right = vo.x + vs.width

		bottom = vo.y
		top = vo.y + vs.height

	end

	if marginType == MarginType.kLEFT then
		utils.setNodeLeftTopPos(node, ccp(distance + left, 0), ancestor)
		node:setPositionY(posY)
	end

	if marginType == MarginType.kRIGHT then
		utils.setNodeRightTopPos(node, ccp(right - distance, 0), ancestor)
		node:setPositionY(posY)
	end

	if marginType == MarginType.kTOP then
		utils.setNodeLeftTopPos(node, ccp(0, top - distance), ancestor)
		node:setPositionX(posX)
	end

	if marginType == MarginType.kBOTTOM then
		utils.setNodeRightBottomPos(node, ccp(0, bottom + distance), ancestor)
		node:setPositionX(posX)
	end

end

return utils