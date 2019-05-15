

-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年09月 8日 19:29:33
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

require "zoo.scenes.component.HomeScene.FlipButton"

---------------------------------------------------
-------------- ToolButton
---------------------------------------------------

assert(not ToolButtonToolType)

ToolButtonToolType = 
{
	EXCHANGE	= 1,
	HAMMER		= 2,
	REFRESH		= 3,
	BACK		= 4,
	BRUSH		= 5
}

local function checkToolType(toolType, ...)
	assert(toolType)
	assert(#{...} == 0)

	assert(toolType == ToolButtonToolType.EXCHANGE or 
		toolType == ToolButtonToolType.HAMMER or
		toolType == ToolButtonToolType.REFRESH or
		toolType == ToolButtonToolType.BACK or
		toolType == ToolButtonToolType.BRUSH)
end


assert(not ToolButton)
assert(FlipButton)
ToolButton = class(FlipButton)

function ToolButton:ctor()
end

function ToolButton:init(toolType, ...)
	assert(toolType)
	checkToolType(toolType)
	assert(#{...} == 0)

	-- Get UI Resource
	self.ui = ResourceManager.sharedInstance():buildGroup("toolButton")
	assert(self.ui)

	-- Init Base
	FlipButton.init(self, self.ui)

	-- Get UI Resource
	self.toolIconPlaceHolder = self.ui:getChildByName("toolIconPlaceHolder")
	assert(self.toolIconPlaceHolder)
end

function ToolButton:create(toolType, ...)
	assert(toolType)
	checkToolType(toolType)
	assert(#{...} == 0)

	local newToolButton = ToolButton.new()
	newToolButton:init(toolType)
	return newToolButton
end
