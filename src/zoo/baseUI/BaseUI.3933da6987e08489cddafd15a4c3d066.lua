
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年09月 2日 18:57:47
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

require "hecore.display.Layer"

---------------------------------------------------
-------------- BaseUI
---------------------------------------------------

if _G.isLocalDevelopMode then printx(0, "Note: Problem:BaseUI Class Will Required Multi Time ! Not Fixed Yet !") end
--assert(not BaseUI)
--assert(Layer)

--BaseUI = class(Layer)
BaseUI = class(Sprite)

function BaseUI:ctor()
end

function BaseUI:init(ui, ...)
	assert(ui ~= nil, "ui Can't Be nil !")
	assert(#{...} == 0)

	-- Init Base
	--Layer.initLayer(self)
	
	local sprite = CCSprite:create()
	self:setRefCocosObj(sprite);

	self.ui = ui

	if self.ui then
		-- --------------------------------------
		-- Check If ui Already Added To A Parent
		-- -----------------------------------
		local uiParent = ui:getParent()

		--self.ui:setCascadeOpacityEnabled(true)
		self:setCascadeOpacityEnabled(true)

		if uiParent then
			-- Have Parent
			-- Means Already Added
			-- Then Replace ui, With Self
			--
			local uiPosition = ui:getPosition()
			local uiPositionX = uiPosition.x
			local uiPositionY = uiPosition.y

			-- Remove ui From It's Parent
			local zOrder = ui:getZOrder()
			ui:removeFromParentAndCleanup(false)

			-- Add ui To Self
			ui:setPosition(ccp(0,0))
			self:addChild(ui)

			-- Add Self To ui Previous Parent
			self:setPosition(ccp(uiPositionX, uiPositionY))
			uiParent:addChildAt(self, zOrder)
		else
			self:addChild(ui)
		end
	end -- end if self.ui
end

function BaseUI:getUI(...)
	assert(#{...} == 0)

	assert(self.ui)
	return self.ui
end

function BaseUI:setPositionXToScreenPercentage(percentage, ...)
	assert(percentage)
	assert(#{...} == 0)

	local parent		= self:getParent()
	assert(parent)

	local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
	local visibleSize	= CCDirector:sharedDirector():getVisibleSize()

	local screenPositionX	= visibleOrigin.x + visibleSize.width * percentage
	local positionX		= parent:convertToNodeSpace(ccp(screenPositionX, 0)).x

	self:setPositionX(positionX)
end

function BaseUI:setPositionYToScreenPercentage(percentage, ...)
	assert(percentage)
	assert(#{...} == 0)

	local parent		= self:getParent()
	assert(parent)

	local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
	local visibleSize	= CCDirector:sharedDirector():getVisibleSize()

	local screenPositionY	= visibleOrigin.y + visibleSize.height * percentage
	local positionY		= parent:convertToNodeSpace(ccp(0, screenPositionY)).y
	self:setPositionY(positionY)
end

------------------------------------------------------------
---------	About Move Self To Center In Screen
------------------------------------------------------------

------ Horizontal Center -------------

function BaseUI:getHCenterInScreenX(...)
	assert(#{...} == 0)

	local visibleSize	= CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
	local selfWidth		= self:getGroupBounds().size.width

	local deltaWidth	= visibleSize.width - selfWidth
	local halfDeltaWidth	= deltaWidth / 2

	return visibleOrigin.x + halfDeltaWidth
end

function BaseUI:getHCenterInParentX(...)
	assert(#{...} == 0)

	local hCenterXInScreen	= self:getHCenterInScreenX()

	local parent		= self:getParent()
	assert(parent)

	local posInParent	= parent:convertToNodeSpace(ccp(hCenterXInScreen, 0))

	return posInParent.x
end

function BaseUI:setToScreenCenterHorizontal(...)
	assert(#{...} == 0)

	local posXInParent = self:getHCenterInParentX()
	self:setPositionX(posXInParent)
end

function BaseUI:setToParentCenterHorizontal(...)
	assert(#{...} == 0)

	-- Get Parent Size
	he_log_warning("this method to get group bounds, is the size in parent space !")
	local parent = self:getParent()
	assert(parent)
	local parentSize = parent:getGroupBounds().size

	-- Get Self Size
	local selfSize = self:getGroupBounds().size

	-- Center Pos
	local deltaWidth = parentSize.width - selfSize.width
	local halfDeltaWidth = deltaWidth / 2

	-- Set Self Posiiton
	local oldAnchorPoint = self:getAnchorPoint()
	self:setAnchorPointWhileStayOriginalPosition(ccp(0,0))
	self:setPositionX(halfDeltaWidth)
	self:setAnchorPointWhileStayOriginalPosition(ccp(oldAnchorPoint.x, oldAnchorPoint.y))
end

------------ Vertical Center -------------

function BaseUI:getVCenterInScreenY(...)
	assert(#{...} == 0) 

	local visibleSize	= CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
	local selfHeight	= self:getGroupBounds().size.height

	local deltaHeight	= visibleSize.height - selfHeight
	local halfDeltaHeight	= deltaHeight / 2

	return visibleOrigin.y + halfDeltaHeight + selfHeight
end

function BaseUI:getVCenterInParentY(...)
	assert(#{...} == 0)

	local vCenterYInScreen	= self:getVCenterInScreenY()

	local parent		= self:getParent()
	assert(parent)

	local posInParent	= parent:convertToNodeSpace(ccp(0, vCenterYInScreen))

	return posInParent.y
end


function BaseUI:setToScreenCenterVertical(...)
	assert(#{...} == 0)

	local posInParentY = self:getVCenterInParentY()

	self:setPositionY(posInParentY)
end

---- Horizontal And Vertical -----

function BaseUI:setToScreenCenter(...)
	assert(#{...} == 0)

	self:setToScreenCenterHorizontal()
	self:setToScreenCenterVertical()
end

-----------------------------------------------------------------
--------	About Move Self Out Of Screen
----------------------------------------------------------------


function BaseUI:getTopOutOfScreenInScreenY(...)
	assert(#{...} == 0)

	local visibleSize	= CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
	local selfHeight	= self:getGroupBounds().size.height

	return visibleOrigin.y + visibleSize.height + selfHeight
end

function BaseUI:setToTopOutOfScreen(...)
	assert(#{...} == 0)

	local topOutScreenInScreenY	= self:getTopOutOfScreenInScreenY()

	local parent = self:getParent()
	assert(parent)

	local posInParent	= parent:convertToNodeSpace(ccp(0, topOutScreenInScreenY))

	self:setPositionY(posInParent.y)
end

-------------------------------------------
---- Alight To Screen Left / Right
-------------------------------------------

function BaseUI:getAlignToScreenLeftPosXInScreen(...)
	assert(#{...} == 0)
	assert(self.ui)

	local parent	= self:getParent()
	assert(parent)

	local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
	local posXInScreen	= visibleOrigin.x

	-- Convert To Parent Space
	local posInParent = parent:convertToNodeSpace(ccp(posXInScreen, 0))
	return posInParent.x
end

function BaseUI:setAlignToScreenLeft(...)
	assert(#{...} == 0)

	local posXInParent = self:getAlignToScreenLeftPosXInScreen()
	self:setPositionX(posXInParent)
end

function BaseUI:getAlignToScreenRightPosXInScreen(...)
	assert(#{...} == 0)
	assert(self.ui)

	local parent	= self:getParent()
	assert(parent)

	local visibleSize	= CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
	local selfWidth		= self.ui:getGroupBounds().size.width

	local posXInScreen = visibleOrigin.x + visibleSize.width - selfWidth

	-- Convert Screen Pos To Self's Parent Space
	local posInParent = parent:convertToNodeSpace(ccp(posXInScreen, 0))
	return  posInParent.x
end

function BaseUI:setAlignToScreenRight(...)
	assert(#{...} == 0)

	local posXInParent = self:getAlignToScreenRightPosXInScreen()
	self:setPositionX(posXInParent)
end

-----------------------------------------------------
--- Get Set Self Position In Screen Space
--=-------------------------------------------------

function BaseUI:getPositionInScreen(...)
	assert(#{...} == 0)

	local parent = self:getParent()
	assert(parent)

	local selfPos = self:getPosition()
	local posInScreen = parent:convertToWorldSpace(ccp(selfPos.x, selfPos.y))
	return posInScreen
end

function BaseUI:setPositionInScreen(posInScreen, ...)
	assert(posInScreen)
	assert(#{...} == 0)

	local parent = self:getParent()
	assert(parent)

	local posInParent = parent:convertToNodeSpace(ccp(posInScreen.x, posInScreen.y))
	self:setPosition(ccp(posInParent.x, posInParent.y))
end

function BaseUI:create(...)
	assert(#{...} == 0)

	local ui = BaseUI.new()
	ui:init(false)

	return ui
end
