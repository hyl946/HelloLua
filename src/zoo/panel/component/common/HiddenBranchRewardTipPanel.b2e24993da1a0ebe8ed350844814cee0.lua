
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2018年09月27日 14:30:00
-- Author:	zhigang.niu
-- Email:	zhigang.niu@happyelements.com

---------------------------------------------------
-------------- HiddenBranchRewardTipPanel
---------------------------------------------------

assert(not HiddenBranchRewardTipPanel)
local HiddenBranchRewardTipPanel = class(BasePanel)

function HiddenBranchRewardTipPanel:init(option, bottom, preferredHeight, showTimeLimitFlag, bAutoClose, ...)
	assert(option)
	assert(#{...} == 0)

    if bAutoClose == nil then
        bAutoClose = true
    end

	self.showTimeLimitFlag = showTimeLimitFlag == nil and true or showTimeLimitFlag
	-- Get UI
	-- self.ui = ResourceManager:sharedInstance():buildGroup("MarkTip")
	self.ui = self:buildInterfaceGroup("HiddenBranchRewardTipPanel/MarkTip")

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

--	self.arrows	= {self.arrow}
--	self.arrowUsedFlag	= {}


	-------------------
	-- Init UI Compoenent
	-- ----------------
--	self.arrow:removeFromParentAndCleanup(false)

	--------------------
	-- Create Tip Content
	-- -----------------
	if not preferredHeight then preferredHeight = -100 end
	--if _G.isLocalDevelopMode then printx(0, panel:getPosition().x, panel:getPosition().y) end

	for i, v in ipairs(option.rewards) do

        local posx = 30
        if i == 2 or i== 4 then
		    posx = 30 + 120
        end

		local item, height = self:_createTipItem(v)
		item:setPosition(ccp(posx, preferredHeight + 50*0.9))
		self:addChild(item)

        if i == 2 or i== 4 then
		    preferredHeight = preferredHeight - height
        end
	end

	----------------
	-- Update View
	-- ---------------
	local desLabelDimension = self.desLabel:getDimensions()
    self.desLabel:setVerticalAlignment(kCCVerticalTextAlignmentCenter)
	self.desLabel:setDimensions(CCSizeMake(300, 0))
    self.desLabel:setPositionX( self.desLabel:getPositionX()+13/0.7)
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
	self.bg:setPreferredSize(CCSizeMake(size.width-20, -preferredHeight -30 ))

	--self.arrow:setPosition(ccp(self.arrow:getPosition().x, preferredHeight + 19))


	-----------------
	-- Add Event Listener
	-- ------------------
    if bAutoClose then
	    local function onVanquish()
		    self:removeTipPanel()
	    end
	    self:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(5), CCCallFunc:create(onVanquish)))
    end

--	local function onPanelTapped()
--		if _G.isLocalDevelopMode then printx(0, "InvitedFriendItem:createTip , onPanelTapped Called !") end
--		self:removeTipPanel()
--	end

--	self.ui:setTouchEnabledWithMoveInOut(true, 0, false)
--	self.ui:addEventListener(DisplayEvents.kTouchBeginOutSide, onPanelTapped)
--	self.ui:addEventListener(DisplayEvents.kTouchBegin, onPanelTapped)
end

function HiddenBranchRewardTipPanel:setRemoveCallback(removeCallback)
	self.removeCallback = removeCallback
end

function HiddenBranchRewardTipPanel:removeTipPanel( ... )
	if self.removeCallback ~= nil then
		self.removeCallback()
	end
	self:removeFromParentAndCleanup(true)
end

function HiddenBranchRewardTipPanel:setArrowPointPositionInWorldSpace( LeftOrRight, arrowPosX, worldSpaceX, worldSpaceY, ...)

	-- Get Self Size
	local selfSize 		= self:getGroupBounds().size
	local visibleOrigin 	= CCDirector:sharedDirector():getVisibleOrigin()
	local visibleSize	= CCDirector:sharedDirector():getVisibleSize()

	------------------------
	-- Position The Panel
	-- --------------------

	local selfParent 	= self:getParent()
	local selfPosInParent	= selfParent:convertToNodeSpace(ccp(worldSpaceX, worldSpaceY))
	self:setPosition(selfPosInParent)


	-----------------------
	-- Which Arrow To Use
	-- -------------------
    local selfSize 		= self:getGroupBounds().size

    local arrowToUse =  self.arrow
    if LeftOrRight then
        self.arrowLeft:setVisible(true)
        self.arrowRight:setVisible(false)
        arrowToUse =  self.arrowLeft
    else
        self.arrowLeft:setVisible(false)
        self.arrowRight:setVisible(true)
        arrowToUse =  self.arrowRight
    end

	arrowToUse:setPositionX(arrowPosX)
    arrowToUse:setPositionY(-selfSize.height + 62 )

    
end

function HiddenBranchRewardTipPanel:setTipString(str, ...)
	assert(#{...} == 0)
	
	self.desLabel:setString(str)
end

function HiddenBranchRewardTipPanel:_createTipItem(option, ...)
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
	panel.ui = self:buildInterfaceGroup("HiddenBranchRewardTipPanel/MarkTipItem")
	BasePanel.init(panel, panel.ui)
	local itemId = option.itemId
	if ItemType:isTimeProp(itemId) then
		itemId = ItemType:getRealIdByTimePropId(itemId)
	end
	local icon = ResourceManager:sharedInstance():buildItemSprite(itemId)
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

	iconPlaceholder:getParent():addChild(icon)
	iconPlaceholder:removeFromParentAndCleanup(true)
	local label = TextField:createWithUIAdjustment(panel.ui:getChildByName('countSize'), panel.ui:getChildByName('count'))
	label:setString("x"..option.num)
	panel.ui:addChild(label)

	local charWidth = 45
	local charHeight = 45
	local charInterval = 24
	local fntFile = option.color and "fnt/mark_tip_white.fnt" or "fnt/mark_tip.fnt"
	local position = label:getPosition()
	-- local newLabel = LabelBMMonospaceFont:create(charWidth, charHeight, charInterval, fntFile)
	local newLabel = BitmapText:create('', fntFile)
	newLabel:setAnchorPoint(ccp(0,1))
	-- newLabel:setString("x"..normalizeNum(option.num))
	
	if option.color then
		newLabel:setColor(option.color)
	end
	newLabel:setText("x"..normalizeNum(option.num))
	newLabel:setPosition(ccp(position.x - 20, position.y))
	newLabel:setScale(1.0)
	panel.ui:addChild(newLabel)
	label:removeFromParentAndCleanup(true)
	panel:setScale(0.9)

	return panel, panel.ui:getGroupBounds().size.height
end

function HiddenBranchRewardTipPanel:create(option, bottom, preferredHeight , showTimeLimitFlag, bAutoClose, ...)
	assert(option)
	assert(#{...} == 0)

	local newHiddenBranchRewardTipPanel = HiddenBranchRewardTipPanel.new()
	newHiddenBranchRewardTipPanel:loadRequiredResource("ui/HiddenBranchRewardTipPanel/HiddenBranchRewardTipPanel.json")
	newHiddenBranchRewardTipPanel:init(option, bottom , preferredHeight, showTimeLimitFlag, bAutoClose)
	return newHiddenBranchRewardTipPanel
end

function HiddenBranchRewardTipPanel:dispose()
	BaseUI.dispose(self)
end


return HiddenBranchRewardTipPanel