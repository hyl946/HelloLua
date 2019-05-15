

-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年09月 2日 17:51:45
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

require "zoo.scenes.component.HomeScene.animation.AlignToScreenEdge"
require "zoo.baseUI.BaseUI"

---------------------------------------------------
-------------- CloudButton
---------------------------------------------------

he_log_warning("Class CloudButton Is Used To Move To Screen Side / Restore To Origianl Pos When Trunk Is Scrolling !")
he_log_warning("This Function Is Cutted Now !")

assert(not CloudButton)
assert(BaseUI)

CloudButton = class(BaseUI)

function CloudButton:init(ui, ...)
	assert(ui)
	assert(#{...} == 0)

	-- Init Base Class
	BaseUI.init(self, ui)

	-- Bind Animation
	self.alignToScreenEdge = AlignToScreenEdge:create(self)
end

-- ----------------------
-- Align Animation
-- ------------------------
function CloudButton:alignToScreenRight(...)
	assert(#{...} == 0)

	if not self.originalPositionX then
		self.originalPositionX	= self:getPositionX()
		self.originalPositionY	= self:getPositionY()
	end

	self.alignToScreenEdge:alignToRight(0.2)
end

function CloudButton:alignToScreenLeft(...)
	assert(#{...} == 0)

	if not self.originalPositionX then
		self.originalPositionX	= self:getPositionX()
		self.originalPositionY	= self:getPositionY()
	end

	self.alignToScreenEdge:alignToLeft(0.2)
end

function CloudButton:restoreToOriginalPosition(...)
	assert(#{...} == 0)

	assert(self.originalPositionX)
	assert(self.originalPositionY)

	local moveToAction	= CCMoveTo:create(0.5, ccp(self.originalPositionX, self.originalPositionY))
	self:stopAllActions()
	self:runAction(moveToAction)
end
