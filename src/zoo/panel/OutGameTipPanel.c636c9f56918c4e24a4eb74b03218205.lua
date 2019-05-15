---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2016-06-08 17:06:21
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   Administrator
-- @Last Modified time: 2016-06-15 10:27:12
---------------------------------------------------------------------------------------
require "zoo.util.TextUtil"
local PanelButton = require("zoo.panel.phone.Button")

OutGameTipPanel = class(BasePanel)

function OutGameTipPanel:ctor()
	self.buttonList = {}
end

function OutGameTipPanel:create(title, contentText)
	local panel = OutGameTipPanel.new()
	panel:loadRequiredResource("ui/login.json")
	panel:init(title, contentText)
	return panel
end

function OutGameTipPanel:init(title, contentText)
	local ui = self.builder:buildGroup("loginPanels/panel_style1")
	BasePanel.init(self, ui)

	self.bg = self.ui:getChildByName("bg")
	local size = self.bg:getGroupBounds(self).size
	self._width = size.width
	self._height = size.height

	self.closeBtnCallback = nil

	self.closeBtn = self.ui:getChildByName("close_btn")
	self.closeBtn:setTouchEnabled(true)
	self.closeBtn:setButtonMode(true)
	local function onCloseBtnTapped()
		if self.closeBtnCallback then self.closeBtnCallback() end
		self:onCloseBtnTapped()
	end
	self.closeBtn:ad(DisplayEvents.kTouchTap, onCloseBtnTapped)

	if title then
		self:setTitle(title)
	end
	if contentText then
		self:setContentText(contentText, {left=45, right=45})
	end

	self:updateCloseBtnPos()
end

function OutGameTipPanel:setTitle(title)
	local titleLabel = self.ui:getChildByName("title")
	if titleLabel then
		titleLabel:setString(title)
		self:updateTitlePos()
		self.title = titleLabel
	end
end

function OutGameTipPanel:updateTitlePos()
	if self.title then
		self.title:setAnchorPoint(ccp(0.5, 1))
		self.title:ignoreAnchorPointForPosition(false)
		self.title:setPositionX(self._width / 2)
	end
end

function OutGameTipPanel:updateCloseBtnPos()
	if self.closeBtn then
		self.closeBtn:setPosition(ccp(self._width - 60, -50))
	end
end

function OutGameTipPanel:setContentText(texts, margin)
	local content = self.ui:getChildByName("content")
	content:setVisible(false)

	if self.contentContainer then
		self.contentContainer:removeFromParentAndCleanup(true)
		self.contentContainer = nil
	end

	if texts and content then
		local textWidth = content:getPreferredSize().width
		local posX, posY = content:getPositionX(), content:getPositionY()
		if margin then
			local left = margin.left or content:getPositionX()
			local right = margin.right or (self._width - content:getPositionX() - content:getPreferredSize().width)
			local top = margin.top or -content:getPositionY()
			local bottom = margin.bottom or 0
			posX = left
			posY = -top
			textWidth = self._width - left - right
		end

		if type(texts) ~= "table" then
			texts = {tostring(texts)}
		end

		local fontName, fontSize, fontColor = content:getFontName(), content:getFontSize(), content:getColor()
		local textHeight = 0
		local textMargin = 30

		local container = Layer:create()
		local textLabels = {}
		for i, text in ipairs(texts) do
			if textHeight > 0 then
				textHeight = textHeight + textMargin
			end
			local richText = TextUtil:buildRichText(tostring(text), textWidth, fontName, fontSize, fontColor)
			richText:setAnchorPoint(ccp(0, 1))
			richText:ignoreAnchorPointForPosition(false)
			richText:setPositionXY(0, -textHeight)
			textHeight = textHeight + richText:getContentSize().height
			container:addChild(richText)
			table.insert(textLabels, richText)
		end
		-- reset texts positions
		for _, label in ipairs(textLabels) do
			label:setPositionY(label:getPositionY() + textHeight)
		end 
		container:setContentSize(CCSizeMake(textWidth, textHeight))
		container:setAnchorPoint(ccp(0, 1))
		container:ignoreAnchorPointForPosition(false)
		container:setPositionXY(posX, posY)
		self.contentContainer = container
		self.ui:addChildAt(container, content:getZOrder())
	end
end

function OutGameTipPanel:resizePanel(width, height)
	local originSize = self.bg:getGroupBounds(self).size
	local width = width or originSize.width
	local height = height or originSize.height
	self.bg:setPreferredSize(CCSizeMake(width, height))
	self._width = width
	self._height = height

	self:updateComponentsPos()
end

function OutGameTipPanel:resizePanelWrapContent()
	local title = self.ui:getChildByName("title")
	-- local content = self.ui:getChildByName("content")
	local totalHeight = 0
	if title then
		local gb = title:getGroupBounds(self.ui)
		totalHeight = totalHeight + gb.size.height
	end
	if self.contentContainer then
		local gb = self.contentContainer:getGroupBounds(self.ui)
		totalHeight = totalHeight + gb.size.height + 50
	end
	if #self.buttonList > 0 then
		local maxHeight = 0
		for _, button in ipairs(self.buttonList) do
			local gb = button:getGroupBounds(self.ui)
			if maxHeight < gb.size.height then
				maxHeight = gb.size.height
			end
		end
		totalHeight = totalHeight + maxHeight + 50
	end
	totalHeight = totalHeight + 80
	self:resizePanel(self._width, totalHeight)
end

function OutGameTipPanel:updateComponentsPos()
	self:updateCloseBtnPos()
	self:updateTitlePos()
	self:updateButtonsPos()
end

function OutGameTipPanel:updateButtonsPos()
	-- local content = self.ui:getChildByName("content")
	local content = self.contentContainer
	if content and #self.buttonList > 0 then
		local bounds = content:getGroupBounds(self.ui)
		local maxHeight = 0
		local totalWidth = 0
		local widthList = {}
		for _, button in ipairs(self.buttonList) do
			if button:isVisible() then
				local btnBounds = button:getGroupBounds(self.ui)
				if maxHeight < btnBounds.size.height then
					maxHeight = btnBounds.size.height
				end
				table.insert(widthList, btnBounds.size.width)
				totalWidth = totalWidth + btnBounds.size.width
			end
		end
		local btnMargin = 50
		local posToLeft = (self._width - totalWidth - btnMargin * (#self.buttonList - 1)) / 2
		for i, button in ipairs(self.buttonList) do
			if button:isVisible() then
				button:setPositionY(bounds.origin.y - 50 - maxHeight / 2 )
				button:setPositionX(posToLeft + widthList[i] / 2)
				posToLeft = posToLeft + btnMargin + widthList[i]
			end
		end
	end
end

function OutGameTipPanel:setCloseBtnEnable(enable, closeBtnCallback)
	if not self.closeBtn then return end
	if enable then
		self.closeBtn:setTouchEnabled(true)
		self.closeBtn:setVisible(true)
		self.closeBtnCallback = closeBtnCallback
		self:setBackKeyCallback(closeBtnCallback)
	else
		self.closeBtn:setTouchEnabled(false)
		self.closeBtn:setVisible(false)
		self.closeBtnCallback = nil
	end
end

function OutGameTipPanel:setBackKeyCallback(backKeyCallback)
	self.backKeyCallback = backKeyCallback
end

function OutGameTipPanel:addButtonAt(button, index, onClick)
	self.ui:addChild(button)
	button:setTouchEnabled(true)
	button:setButtonMode(true)
	if type(onClick) == "function" then
		button:ad(DisplayEvents.kTouchTap, onClick)
	end
	table.insert(self.buttonList, index, button)
	self:updateButtonsPos()
end

function OutGameTipPanel:addButton(button, onClick)
	local len = #self.buttonList
	self:addButtonAt(button, len+1, onClick)
end

function OutGameTipPanel:removeButton(button, cleanup)
	if not button then return end
	if cleanup ~= false then cleanup = true end
	for _, v in pairs(self.buttonList) do
		if v == button then
			table.removeValue(v)
			if not v.isDisposed and v:getParent() then
				v:removeFromParentAndCleanup(cleanup)
			end
		end
	end
end

function OutGameTipPanel:addCancelButton(text, onClick)
	self:setBackKeyCallback(onClick)
	local btnUi = self.builder:buildGroup("loginPanels/button_blue")
	local function onClickCallback(evt)
		if onClick then onClick() end
		self:onCloseBtnTapped()
	end
	btnUi:setScale(0.8)
	PanelButton:create(btnUi, text, onClickCallback)
	self:addButtonAt(btnUi, 1)
end

function OutGameTipPanel:addConfirmButton(text, onClick)
	local btnUi = self.builder:buildGroup("loginPanels/button_green")
	local function onClickCallback(evt)
		if onClick then onClick() end
		self:onCloseBtnTapped()
	end
	PanelButton:create(btnUi, text, onClickCallback)
	self:addButton(btnUi)
end

function OutGameTipPanel:onCloseBtnTapped()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self, true)
end

function OutGameTipPanel:popout(...)
	assert(#{...} == 0)
	self:resizePanelWrapContent()

	PopoutManager:sharedInstance():add(self, true, false)
	self:setToScreenCenterHorizontal()
	self:setToScreenCenterVertical()
	self.allowBackKeyTap = true
end

function OutGameTipPanel:buildGreenButton(scale)
	scale = scale or 1
	local btn = self.builder:buildGroup("loginPanels/button_green")
	btn:setScale(scale)
	PanelButton:create(btnUi, text, onClickCallback)
	return btn
end

function OutGameTipPanel:buildBlueButton(scale)
	scale = scale or 1
	local btn = self.builder:buildGroup("loginPanels/button_blue")
	btn:setScale(scale)
	PanelButton:create(btnUi, text, onClickCallback)
	return btn
end

function OutGameTipPanel:onKeyBackClicked( ... )
	if self.backKeyCallback then self.backKeyCallback() end
	self:onCloseBtnTapped()
end