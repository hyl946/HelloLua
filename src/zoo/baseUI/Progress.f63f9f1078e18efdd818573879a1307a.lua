
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年10月 7日 18:41:56
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

------------------------------------------------------
----- This Is A Progress Bar , For Not Conflict With The
--	Name Of An Already Exist Progress Bar
--	That's Class Name Is Progress
--	-------------------------------------------------

---------------------------------------------------
-------------- Progress
---------------------------------------------------

assert(not Progress)
assert(BaseUI)
Progress = class(BaseUI)

function Progress:ctor()
end

function Progress:init(ui, ...)
	assert(ui)
	assert(#{...} == 0)

	self.ui = ui

	-- ---------
	-- Init Base
	-- ---------
	BaseUI.init(self, self.ui)

	--------------------
	-- Get Data About UI
	-- -----------------
	self.uiWidth = self.ui:getGroupBounds().size.width

	-- Create The Clipping Node
	local clippingNode = ClippingNode.new(CCClippingNode:create(self.ui.refCocosObj))
	self:addChild(clippingNode)
	-- Add self.ui To The Clipping Node
	self.ui:removeFromParentAndCleanup(false)
	clippingNode:addChild(self.ui)

	--------------
	--- Data
	-------------
	self.ratio = 0.5
	self:setProgress(self.ratio)
end

function Progress:setProgress(ratio, ...)
	assert(ratio)
	assert(type(ratio) == "number")
	assert(ratio >= 0 and ratio <= 1)
	assert(#{...} == 0)

	self.ratio = ratio

	local unvisibleWidth = self.uiWidth * (1 - ratio)
	self.ui:setPositionX(-unvisibleWidth)
end

function Progress:getProgress(...)
	assert(#{...} == 0)

	return self.ratio
end

function Progress:create(ui, ...)
	assert(ui)
	assert(#{...} == 0)

	local newProgress = Progress.new()
	newProgress:init(ui)
	return newProgress
end

