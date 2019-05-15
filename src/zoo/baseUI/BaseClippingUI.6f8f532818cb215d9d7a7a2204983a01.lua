
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年10月23日 23:50:32
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

---------------------------------------------------
-------------- BaseClippingUI
---------------------------------------------------

BaseClippingUI = class(BaseUI)

function BaseClippingUI:ctor()
end

function BaseClippingUI:init(ui, ...)
	assert(ui)
	assert(#{...} == 0)

	self.ui = ui

	---------------
	-- Init Base Class
	-- ----------------
	BaseUI.init(self, self.ui)

	----------------------------------
	-- Wrap self.ui With A Clipping Node
	-- -----------------------------
	local uiSize = self.ui:getGroupBounds().size
	--if _G.isLocalDevelopMode then printx(0, "uiSize: ") end
	--if _G.isLocalDevelopMode then printx(0, "uiSize.width: " .. uiSize.width) end
	--if _G.isLocalDevelopMode then printx(0, "uiSize.height: " .. uiSize.height) end

	local stencil = CCLayerColor:create(ccc4(255,255,255,255), uiSize.width, uiSize.height)
	stencil:setPositionY(-uiSize.height)
	self.clipping = ClippingNode.new(CCClippingNode:create(stencil))
	self:addChild(self.clipping)

	--local stencil = CCLayerColor:create(ccc4(255,255,255,255), uiSize.width, uiSize.height)

	self.ui:removeFromParentAndCleanup(false)
	self.clipping:addChild(self.ui)
end

function BaseClippingUI:create(ui, ...)
	assert(ui)
	assert(#{...} == 0)

	local newBaseClippingUI = BaseClippingUI.new()
	newBaseClippingUI:init(ui)
	return newBaseClippingUI
end

