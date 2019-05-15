

-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年09月 5日 11:46:44
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

require "zoo.baseUI.RegionLayoutBar"
---------------------------------------------------
-------------- ScreenLayoutBar
---------------------------------------------------

ScreenLayoutBar = class(RegionLayoutBar)

function ScreenLayoutBar:ctor()
end

function ScreenLayoutBar:init(alignHorizontal, alignVertical, direction, ...)

	assert(alignHorizontal)
	assert(
		alignHorizontal == LayoutBarAlign.LEFT or
		alignHorizontal == LayoutBarAlign.RIGHT or 
		alignHorizontal == LayoutBarAlign.HORIZONTAL_CENTER)

	assert(alignVertical)
	assert(alignVertical == LayoutBarAlign.TOP or
		alignVertical == LayoutBarAlign.BOTTOM or
		alignVertical == LayoutBarAlign.VERTICAL_CENTER)

	assert(direction)
	assert(direction == LayoutBarDirection.HORIZONTAL or
		direction == LayoutBarDirection.VERTICAL) 

	assert(#{...} == 0)

	-- Get Screen Size
	self.visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
	self.visibleSize	= CCDirector:sharedDirector():getVisibleSize()

	-- Init Base
	RegionLayoutBar.init(self, self.visibleSize.width, self.visibleSize.height, alignHorizontal, alignVertical, direction)

	-- Position
	self:setPosition(ccp(self.visibleOrigin.x , self.visibleOrigin.y + self.visibleSize.height))
end

function ScreenLayoutBar:create(alignHorizontal, alignVertical, direction, ...)

	assert(alignHorizontal)
	assert(
		alignHorizontal == LayoutBarAlign.LEFT or
		alignHorizontal == LayoutBarAlign.RIGHT or 
		alignHorizontal == LayoutBarAlign.HORIZONTAL_CENTER)

	assert(alignVertical)
	assert(alignVertical == LayoutBarAlign.TOP or
		alignVertical == LayoutBarAlign.BOTTOM or
		alignVertical == LayoutBarAlign.VERTICAL_CENTER)

	assert(direction)
	assert(direction == LayoutBarDirection.HORIZONTAL or
		direction == LayoutBarDirection.VERTICAL) 
	assert(#{...} == 0)

	local newScreenLayoutBar = ScreenLayoutBar.new()
	newScreenLayoutBar:init(alignHorizontal, alignVertical, direction)
	return newScreenLayoutBar
end
