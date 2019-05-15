

-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年09月 1日 21:42:12
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com


---------------------------------------------------
-------------- AlignToScreenEdge
---------------------------------------------------

AlignToScreenEdge = class()

function AlignToScreenEdge:ctor()
end

function AlignToScreenEdge:init(ui, ...)
	assert(ui)
	assert(#{...} == 0)

	self.ui	= ui

	self.director		= CCDirector:sharedDirector()
	self.visibleOrigin	= self.director:getVisibleOrigin()
	self.visibleSize	= self.director:getVisibleSize()
end

function AlignToScreenEdge:alignToLeft(interval, ...)
	assert(interval)
	assert(#{...} == 0)

	-- UI Parent
	local uiParent	= self.ui:getParent()
	assert(uiParent)

	-- UI Current Position Y
	local positionY	= self.ui:getPositionY()

	-- Get World Left Most Position In UI's Parent
	-- Only Care Position X , So Y Is Not Matter
	local worldLeftPositionToNode	= uiParent:convertToNodeSpace(ccp(0,0))

	-- Move To It
	local moveToAction	= CCMoveTo:create(interval, ccp(worldLeftPositionToNode.x, positionY))
	self.ui:stopAllActions()
	self.ui:runAction(moveToAction)
end

function AlignToScreenEdge:alignToRight(interval, ...)
	assert(interval)
	assert(#{...} == 0)

	-- UI Parent
	local uiParent = self.ui:getParent()
	assert(uiParent)

	-- UI Current Position Y
	local positionY	= self.ui:getPositionY()

	-- World Right Most Position In UI's Parent Coordiante Space
	local worldRightPositionX	= self.visibleOrigin.x + self.visibleSize.width
	local worldRightPositionToNode	= uiParent:convertToNodeSpace(ccp(worldRightPositionX, 0))

	-- Move To Position
	-- Sub UI Width
	local uiWidth		= self.ui:getGroupBounds().size.width
	local moveToPositionX	= worldRightPositionToNode.x - uiWidth

	-- Move To It
	local moveToAction	= CCMoveTo:create(interval, ccp(moveToPositionX, positionY))
	local easeOutAction	= CCEaseOut:create(moveToAction, 1)
	self.ui:stopAllActions()
	self.ui:runAction(moveToAction)
end

function AlignToScreenEdge:create(ui, ...)
	assert(ui)
	assert(#{...} == 0)

	local newAlignToScreenEdge = AlignToScreenEdge.new()
	newAlignToScreenEdge:init(ui)
	return newAlignToScreenEdge
end
