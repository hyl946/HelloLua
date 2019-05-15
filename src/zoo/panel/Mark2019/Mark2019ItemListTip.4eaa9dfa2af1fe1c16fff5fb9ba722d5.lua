
local UIHelper = require 'zoo.panel.UIHelper'

local Mark2019ItemListTip = class(BoxRewardTipPanel)


function Mark2019ItemListTip:init(option, bottom, preferredHeight, showTimeLimitFlag, ...)
	assert(option)
	assert(#{...} == 0)

	self.showTimeLimitFlag = showTimeLimitFlag == nil and true or showTimeLimitFlag
	-- Get UI
	-- self.ui = ResourceManager:sharedInstance():buildGroup("MarkTip")
    local ui = UIHelper:createUI("flash/Mark2019/mark2019.json", "Mark2019/MarkTip")
    BasePanel.init(self, ui)

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

function Mark2019ItemListTip:_createTipItem(option, ...)
	assert(#{...} == 0)

	local function normalizeNum(num)
		if num >= 10000 then
			return tostring(num/10000)..'万'
		else
			return tostring(num)
		end
	end

	local panel = BasePanel.new()

    panel.ui = UIHelper:createUI("flash/Mark2019/mark2019.json", "Mark2019/MarkTipItem")
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

function Mark2019ItemListTip:create(option, bottom, preferredHeight , showTimeLimitFlag, ...)
	assert(option)
	assert(#{...} == 0)

	local newBoxRewardTipPanel = Mark2019ItemListTip.new()
	newBoxRewardTipPanel:init(option, bottom , preferredHeight, showTimeLimitFlag)
	return newBoxRewardTipPanel
end

function Mark2019ItemListTip:dispose()
	BaseUI.dispose(self)
end


return Mark2019ItemListTip