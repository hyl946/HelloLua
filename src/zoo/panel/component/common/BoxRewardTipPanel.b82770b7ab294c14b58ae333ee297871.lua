
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2014年01月 3日 17:32:02
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

---------------------------------------------------
-------------- BoxRewardTipPanel
---------------------------------------------------

assert(not BoxRewardTipPanel)
BoxRewardTipPanel = class(BasePanel)

function BoxRewardTipPanel:init(option, bottom, preferredHeight, showTimeLimitFlag, ...)
	assert(option)
	assert(#{...} == 0)

	self.showTimeLimitFlag = showTimeLimitFlag == nil and true or showTimeLimitFlag
	-- Get UI
	-- self.ui = ResourceManager:sharedInstance():buildGroup("MarkTip")
	self.ui = self:buildInterfaceGroup("MarkTip")

	---------------
	-- Init Base Class
	-- ---------------
	BasePanel.init(self, self.ui)

	----------------
	-- Get UI Componenet
	-- -----------------
	self.desLabel	= self.ui:getChildByName("text")
	self.bg		= self.ui:getChildByName("bg")
	self.bottomLabel = self.ui:getChildByName("bottom")
	--self.arrow	= self.ui:getChildByName("arrow")

	self.arrowLeft	= self.ui:getChildByName("arrowLeft")
	self.arrowRight	= self.ui:getChildByName("arrowRight")
	self.arrowUp	= self.ui:getChildByName("arrowUp")
	self.arrowDown	= self.ui:getChildByName("arrowDown")

	self.arrows		= {self.arrowLeft, self.arrowRight, self.arrowUp, self.arrowDown}
	self.arrowUsedFlag	= {}

	assert(self.arrowLeft)
	assert(self.arrowRight)
	assert(self.arrowUp)
	assert(self.arrowDown)

	assert(self.desLabel)
	assert(self.bg)

	-------------------
	-- Init UI Compoenent
	-- ----------------
	--self.arrow:removeFromParentAndCleanup(false)
	self.arrowLeft:removeFromParentAndCleanup(false)
	self.arrowRight:removeFromParentAndCleanup(false)
	self.arrowUp:removeFromParentAndCleanup(false)
	self.arrowDown:removeFromParentAndCleanup(false)

	--------------------
	-- Create Tip Content
	-- -----------------
	if not preferredHeight then preferredHeight = -120 end
	--if _G.isLocalDevelopMode then printx(0, panel:getPosition().x, panel:getPosition().y) end

	for __, v in ipairs(option.rewards) do
		local item, height = self:_createTipItem(v)
		item:setPosition(ccp(40, preferredHeight + 50*0.9))
		self:addChild(item)
		preferredHeight = preferredHeight - height
	end

	----------------
	-- Update View
	-- ---------------
	local desLabelDimension = self.desLabel:getDimensions()
	self.desLabel:setDimensions(CCSizeMake(desLabelDimension.width, 0))
	self.desLabel:setString("")
	if type(bottom) == "string" then
		self.bottomLabel:setPositionY(preferredHeight + 40)
		local dimension = self.bottomLabel:getDimensions()
		self.bottomLabel:setDimensions(CCSizeMake(dimension.width, 0))
		self.bottomLabel:setString(bottom)
		local size = self.bottomLabel:getContentSize()
		preferredHeight = preferredHeight - size.height
	end

	local size = self:getGroupBounds().size
	self.bg:setPreferredSize(CCSizeMake(size.width, -preferredHeight))

	--self.arrow:setPosition(ccp(self.arrow:getPosition().x, preferredHeight + 19))


	-----------------
	-- Add Event Listener
	-- ------------------

	local function onVanquish()
		self:removeTipPanel()
	end
	self:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(5), CCCallFunc:create(onVanquish)))

	local function onPanelTapped()
		if _G.isLocalDevelopMode then printx(0, "InvitedFriendItem:createTip , onPanelTapped Called !") end
		self:removeTipPanel()
	end

	self.ui:setTouchEnabledWithMoveInOut(true, 0, false)
	self.ui:addEventListener(DisplayEvents.kTouchBeginOutSide, onPanelTapped)
	self.ui:addEventListener(DisplayEvents.kTouchBegin, onPanelTapped)
end

function BoxRewardTipPanel:setRemoveCallback(removeCallback)
	self.removeCallback = removeCallback
end

function BoxRewardTipPanel:removeTipPanel( ... )
	if self.removeCallback ~= nil then
		self.removeCallback()
	end
	self:removeFromParentAndCleanup(true)
end

function BoxRewardTipPanel:setArrowPointPositionInWorldSpace(distanceToArrowPoint, worldSpaceX, worldSpaceY, ...)
	assert(type(distanceToArrowPoint) == "number")
	assert(type(worldSpaceX) == "number")
	assert(type(worldSpaceY) == "number")
	assert(#{...} == 0)

	self.ARROW_VERTICAL_POS_TOP	= 1
	self.ARROW_VERTICAL_POS_MIDDLE	= 2
	self.ARROW_VERTICAL_POS_BOTTOM	= 3

	self.ARROW_HORIZONTAL_POS_LEFT		= 4
	self.ARROW_HORIZONTAL_POS_MIDDLE	= 5
	self.ARROW_HORIZONTAL_POS_RIGHT		= 6

	self.arrowHorizontalPos = false
	self.arrowVerticalPos	= false

	-- Get Self Size
	local selfSize 		= self:getGroupBounds().size
	local visibleOrigin 	= CCDirector:sharedDirector():getVisibleOrigin()
	local visibleSize	= CCDirector:sharedDirector():getVisibleSize()

	-- ------------------------------------------
	-- Check Arrow Vertical Position In Panel
	-- ----------------------------------------

	-- First Try Arrow At The Bottom Of Tip Panel
	if worldSpaceY + selfSize.height + distanceToArrowPoint <= visibleOrigin.y +  visibleSize.height then
		self.arrowVerticalPos = self.ARROW_VERTICAL_POS_BOTTOM

	elseif worldSpaceY - selfSize.height - distanceToArrowPoint >= visibleOrigin.y then
		-- Try Arrow At The Top Of Tip Panel
		self.arrowVerticalPos = self.ARROW_VERTICAL_POS_TOP
	else
		-- Try Arrow At The Middle Of Tip Panel
		self.arrowVerticalPos = self.ARROW_VERTICAL_POS_MIDDLE
	end

	--------------------------------------
	-- Check Arrow Horizontal Position In Panel
	-- -------------------------------------
	
	if self.arrowVerticalPos == self.ARROW_VERTICAL_POS_TOP or
		self.arrowVerticalPos == self.ARROW_VERTICAL_POS_BOTTOM then
		-- Check If Center

		if worldSpaceX + selfSize.width / 2 < visibleOrigin.x + visibleSize.width  and
			worldSpaceX - selfSize.width / 2 > visibleOrigin.x then

			self.arrowHorizontalPos = self.ARROW_HORIZONTAL_POS_MIDDLE
		end
	end

	if not self.arrowHorizontalPos then

		-- Check If Can Postion Arrow Left
		if worldSpaceX + selfSize.width < visibleOrigin.x + visibleSize.width then
			self.arrowHorizontalPos = self.ARROW_HORIZONTAL_POS_LEFT

		-- Check If Can Position Arrow Right
		elseif worldSpaceX - selfSize.width > visibleOrigin.x then
			self.arrowHorizontalPos = self.ARROW_HORIZONTAL_POS_RIGHT
		end
	end

	---------------------------
	-- Get Self Pos In World Space
	-- -------------------------
	local selfWorldPosX = false
	local selfWorldPosY = false

	if self.arrowVerticalPos == self.ARROW_VERTICAL_POS_TOP then
		selfWorldPosY = worldSpaceY + 60

	elseif self.arrowVerticalPos == self.ARROW_VERTICAL_POS_MIDDLE then
		selfWorldPosY =  worldSpaceY + selfSize.height / 2

	elseif self.arrowVerticalPos == self.ARROW_VERTICAL_POS_BOTTOM then
		selfWorldPosY = worldSpaceY + selfSize.height - 60
	end

	if self.arrowHorizontalPos == self.ARROW_HORIZONTAL_POS_LEFT then
		selfWorldPosX	= worldSpaceX + distanceToArrowPoint

	elseif self.arrowHorizontalPos == self.ARROW_HORIZONTAL_POS_RIGHT then
		selfWorldPosX 	= worldSpaceX - selfSize.width - distanceToArrowPoint+8

	elseif self.arrowHorizontalPos == self.ARROW_HORIZONTAL_POS_MIDDLE then
		selfWorldPosX = worldSpaceX - selfSize.width / 2

		if self.arrowVerticalPos == self.ARROW_VERTICAL_POS_TOP then
			selfWorldPosY	= worldSpaceY - distanceToArrowPoint 

		elseif self.arrowVerticalPos == self.ARROW_VERTICAL_POS_BOTTOM then
			selfWorldPosY = worldSpaceY + selfSize.height + distanceToArrowPoint
		end
	end

	------------------------
	-- Position The Panel
	-- --------------------
	local selfParent 	= self:getParent()
	local selfPosInParent	= selfParent:convertToNodeSpace(ccp(selfWorldPosX, selfWorldPosY))
	self:setPosition(selfPosInParent)


	-----------------------
	-- Which Arrow To Use
	-- -------------------

	local arrowToUse = false

	if self.arrowHorizontalPos == self.ARROW_HORIZONTAL_POS_LEFT then
		arrowToUse = self.arrowLeft
		self.arrowUsedFlag[1] = true
		
	elseif self.arrowHorizontalPos == self.ARROW_HORIZONTAL_POS_RIGHT then
		arrowToUse = self.arrowRight
		self.arrowUsedFlag[2] = true

	else
		if self.arrowVerticalPos == self.ARROW_VERTICAL_POS_TOP then
			arrowToUse = self.arrowUp
			self.arrowUsedFlag[3] = true
		else
			arrowToUse = self.arrowDown
			self.arrowUsedFlag[4] = true
		end
	end

	for index,v in ipairs(self.arrows) do
		if not self.arrowUsedFlag[index] then
			v:dispose()
			--v:removeFromParentAndCleanup(true)
		end
	end

	--------------------------
	-- Posiiton Arrow To Use
	-- -----------------------
	local arrowPosX		= false
	local arrowPosY		= false

	self.ui:addChild(arrowToUse)
	local arrowSize = arrowToUse:getGroupBounds().size


	if self.arrowHorizontalPos == self.ARROW_HORIZONTAL_POS_LEFT then

		arrowPosX = worldSpaceX + distanceToArrowPoint + 1
		arrowPosY = worldSpaceY 


		--if self.arrowVerticalPos = self.ARROW_VERTICAL_POS_TOP then
		--	arrowPosY = worldSpaceY 
		--elseif self.arrowVerticalPos == self.ARROW_VERTICAL_POS_MIDDLE then
		--	arrowPosY = worldSpaceY 
		--elseif self.arrowVerticalPos == self.ARROW_VERTICAL_POS_BOTTOM then
		--	arrowPosY = worldSpaceY 
		--end

	elseif self.arrowHorizontalPos == self.ARROW_HORIZONTAL_POS_RIGHT then
		arrowPosX = worldSpaceX - distanceToArrowPoint - 1
		arrowPosY = worldSpaceY

	else
		-- Middle
		arrowPosX = worldSpaceX

		if self.arrowVerticalPos == self.ARROW_VERTICAL_POS_TOP then
			arrowPosY = worldSpaceY - distanceToArrowPoint - 1

		elseif self.arrowVerticalPos == self.ARROW_VERTICAL_POS_MIDDLE then

		elseif self.arrowVerticalPos == self.ARROW_VERTICAL_POS_BOTTOM then
			arrowPosY = worldSpaceY + distanceToArrowPoint + 17
			self:setPositionY(self:getPositionY() + 15)
		end
	end

	local arrowPosInParent = self.ui:convertToNodeSpace(ccp(arrowPosX, arrowPosY))
	--self.ui:addChild(arrowToUse)
	arrowToUse:setPosition(arrowPosInParent)

end

function BoxRewardTipPanel:setTipString(str, ...)
	assert(#{...} == 0)
	
	self.desLabel:setString(str)
end

function BoxRewardTipPanel:_createTipItem(option, ...)
	assert(#{...} == 0)

	local function normalizeNum(num)
		if num >= 10000 then
			return tostring(num/10000)..'万'
		else
			return tostring(num)
		end
	end

	local panel = BasePanel.new()
	-- panel.ui = ResourceManager:sharedInstance():buildGroup("MarkTipItem")
	panel.ui = self:buildInterfaceGroup("MarkTipItem")
	BasePanel.init(panel, panel.ui)
	local itemId = option.itemId
	if ItemType:isTimeProp(itemId) then
		itemId = ItemType:getRealIdByTimePropId(itemId)
	end
	local icon = ResourceManager:sharedInstance():buildItemSpriteWithDecorate(itemId, option.num)
	local iconPlaceholder = panel.ui:getChildByName("iconPlaceholder")
	local pos = iconPlaceholder:getPosition()
	local phSize = iconPlaceholder:getGroupBounds().size
	icon:ignoreAnchorPointForPosition(false)
	icon:setAnchorPoint(ccp(0.5, 0.5))
	icon:setPosition(ccp(pos.x+phSize.width/2-6, pos.y-phSize.height/2))
	icon:setScale(0.7)

	if self.showTimeLimitFlag and ItemType:isTimeProp(option.itemId) then


		local time_prop_flag = ResourceManager:sharedInstance():createTimeLimitFlag(option.itemId)
		icon:addChild(time_prop_flag)
		local size = icon:getContentSize()
		time_prop_flag:setPosition(ccp(size.width/2, size.height/5))
		time_prop_flag:setScale(1 / math.max(icon:getScaleY(), icon:getScaleX()))

	end

	local nNumForDisplay = option.num

	if ItemType:isMergableItem(option.itemId) then
		nNumForDisplay = 1
	end

	iconPlaceholder:getParent():addChild(icon)
	iconPlaceholder:removeFromParentAndCleanup(true)
	local label = TextField:createWithUIAdjustment(panel.ui:getChildByName('countSize'), panel.ui:getChildByName('count'))
	label:setString("x"..nNumForDisplay)
	panel.ui:addChild(label)

	local charWidth = 45
	local charHeight = 45
	local charInterval = 24
	local fntFile = option.color and "fnt/mark_tip_white.fnt" or "fnt/mark_tip.fnt"
	local position = label:getPosition()
	-- local newLabel = LabelBMMonospaceFont:create(charWidth, charHeight, charInterval, fntFile)
	local newLabel = BitmapText:create('', fntFile)
	newLabel:setAnchorPoint(ccp(0,1))
	-- newLabel:setString("x"..normalizeNum(nNumForDisplay))
	
	if option.color then
		newLabel:setColor(option.color)
	end
	newLabel:setText("x"..normalizeNum(nNumForDisplay))
	newLabel:setPosition(ccp(position.x - 20, position.y))
	newLabel:setScale(1.0)
	panel.ui:addChild(newLabel)
	label:removeFromParentAndCleanup(true)
	panel:setScale(0.9)

	return panel, panel.ui:getGroupBounds().size.height
end

function BoxRewardTipPanel:create(option, bottom, preferredHeight , showTimeLimitFlag, ...)
	assert(option)
	assert(#{...} == 0)

	local newBoxRewardTipPanel = BoxRewardTipPanel.new()
	newBoxRewardTipPanel:loadRequiredResource(PanelConfigFiles.invite_friend_reward_panel)
	newBoxRewardTipPanel:init(option, bottom , preferredHeight, showTimeLimitFlag)
	return newBoxRewardTipPanel
end

function BoxRewardTipPanel:dispose()
	BaseUI.dispose(self)
end
