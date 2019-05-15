require "zoo.panel.basePanel.BasePanel"
require "zoo.ui.ButtonBuilder"
require "zoo.scenes.component.HomeSceneFlyToAnimation"

InnerNotiPanel = class(BasePanel)

function InnerNotiPanel:create(config)
	local panel = InnerNotiPanel.new()
	panel:loadRequiredJson(PanelConfigFiles.panel_give_back)
	if not panel:_init(config) then panel = nil end
	return panel
end

function InnerNotiPanel:_init(config)
	-- data
	local descText, btnText = config.text, config.btnText
	if type(descText) ~= "string" or string.len(descText) <= 0 then return false end
	local compenData = config.itemData or {}
	local vOrigin = Director:sharedDirector():getVisibleOrigin()
	self.enterPos, self.exitPos = config.enterPos or vOrigin, config.exitPos or vOrigin

	-- panel
	self.panel = self:buildInterfaceGroup("GiveBackPanel")
	BasePanel.init(self, self.panel)

	-- control
	local bg = self.panel:getChildByName("bg")
	local bg2 = self.panel:getChildByName("bg2")
	local desc = self.panel:getChildByName("desc")
	local itemArea = self.panel:getChildByName("itemArea")
	local button = self.panel:getChildByName("button")
	local title = self.panel:getChildByName("title")
	local close = self.panel:getChildByName("close")
	button = GroupButtonBase:create(button)
	self.button = button

	-- strings
	local compenTitle = config.title
	if type(compenTitle) == string and string.len(compenTitle) > 0 then
		title:setString(compenTitle)
	else
		desc:setPositionY(desc:getPositionY() + 40)
	end
	local dimension = desc:getDimensions()
    desc:setDimensions(CCSizeMake(dimension.width, 0))
    desc:setFontSize(28)
	desc:setString(descText)
	button:setString(btnText)

	-- create items
	items = {}
	for k, v in ipairs(compenData) do
		local item = self:_buildItem(v.itemId, v.num)
		item.itemId = v.itemId
		item.num = v.num
		table.insert(items, item)
	end
	self.items = items

	-- layout
	local verticalMargin, borderMargin = 30, 40
	local numInRow, margin = 3, 15
	local fullWidth = 0
	local height = -desc:getPositionY()
	height = height + desc:getContentSize().height + verticalMargin
	itemArea:setPositionY(-height)
	if #items > 0 then
		local margin = 15
		local size = items[1]:getGroupBounds().size
		size = {width = size.width, height = size.height}
		local lastRow = math.ceil(#items / numInRow)
		for k, v in ipairs(items) do
			local curRow = math.ceil(k / numInRow)
			local itemPosX, itemPosY = 0, 0
			if curRow < lastRow then
				itemPosX = (size.width + margin) * ((k - 1) % numInRow)
			else -- lastRow: get total width and then position with addPos
				local itemNum = (#items - 1) % 3 + 1
				local totalWidth = itemNum * size.width + (itemNum - 1) * margin
				fullWidth = numInRow * size.width + (numInRow - 1) * margin
				local baseX = (fullWidth - totalWidth) / 2
				itemPosX = (size.width + margin) * ((k - 1) % numInRow) + baseX
			end
			itemPosY = -(size.height + margin) * (curRow - 1)
			v:setPosition(ccp(itemPosX, itemPosY))
		end
		local layer = Layer:create()
		for k, v in ipairs(items) do layer:addChild(v) end
		local size = layer:getGroupBounds().size
		size = {width = size.width, height = size.height}
		local scale = itemArea:getGroupBounds().size.width / fullWidth
		layer:setScale(scale)
		local pos = itemArea:getPosition()
		layer:setPosition(ccp(pos.x, pos.y))
		self.panel:addChild(layer)
		height = height + size.height * scale + verticalMargin
	end
	itemArea:removeFromParentAndCleanup(true)
	button:setPositionY(-height - borderMargin - verticalMargin)
	height = height + button:getGroupBounds().size.height + borderMargin
	local size = bg:getPreferredSize()
	local size2 = bg2:getPreferredSize()
	bg:setPreferredSize(CCSizeMake(size.width, height + 34))
	bg2:setPreferredSize(CCSizeMake(size2.width, height))

	-- positioning
	self:scaleAccordingToResolutionConfig()
	self:setPositionForPopoutManager()

	-- event listeners
	close:setVisible(false)
	-- local function onClose() self:onCloseBtnTapped() end
	-- close:setTouchEnabled(true)
	-- close:setButtonMode(true)
	-- close:addEventListener(DisplayEvents.kTouchTap, onClose)
	local function onBtn() self:onCloseBtnTapped() end
	button:addEventListener(DisplayEvents.kTouchTap, onBtn)
	local function onEnterHandler(evt) self:_onEnterHandler(evt, config.enterPos, config.exitPos) end
	self:registerScriptHandler(onEnterHandler)

	return true
end

function InnerNotiPanel:_buildItem(itemId, itemNum)
	local ui = self:buildInterfaceGroup("InnerNotiPanel_RewardItem")
	local item = ui:getChildByName("item")
	local rect = ui:getChildByName("rect")
	local num = ui:getChildByName("num")

	local charWidth = 45
	local charHeight = 45
	local charInterval = 24
	local fntFile = "fnt/target_amount.fnt"
	local position = num:getPosition()
	local newLabel = LabelBMMonospaceFont:create(charWidth, charHeight, charInterval, fntFile)
	newLabel:setAnchorPoint(ccp(0,1))
	newLabel:setString("x"..tostring(itemNum))
	local size = newLabel:getContentSize()
	local rcSize = rect:getGroupBounds().size
	local rcPositionX = rect:getPositionX()
	newLabel:setPosition(ccp(rcPositionX + rcSize.width - size.width, position.y))
	ui:addChild(newLabel)
	rect:removeFromParentAndCleanup(true)
	num:removeFromParentAndCleanup(true)

	local position = item:getPosition()
	local sprite
	if itemId == 2 then
		sprite = ResourceManager:sharedInstance():buildGroup("stackIcon")
		sprite:setPositionX(sprite:getPositionX() + 25)
		sprite:setPositionY(sprite:getPositionY() - 15)
	elseif itemId == 14 then
		sprite = Sprite:createWithSpriteFrameName("wheel0000")
		sprite:setScale(1.5)
		local size = ui:getGroupBounds().size
		sprite:setPosition(ccp(size.width / 2 + 10, -size.height / 2))
	else
		sprite = ResourceManager:sharedInstance():buildItemGroup(itemId)
		sprite:setScale(1.2)
		sprite:setPosition(ccp(position.x, position.y))
	end
	item:removeFromParentAndCleanup(true)
	ui.item = sprite
	ui:addChildAt(sprite, 1)

	return ui
end

function InnerNotiPanel:popout()
	PopoutQueue.sharedInstance():push(self)
end

local animTime = 0.2
function InnerNotiPanel:onCloseBtnTapped()
	if self.isDisposed then return end
	local vSize = Director:sharedDirector():getVisibleSize()
	self:stopAllActions()
	self:runAction(CCSpawn:createWithTwoActions(CCMoveTo:create(animTime, ccp(self.exitPos.x, self.exitPos.y - vSize.height)), CCScaleTo:create(animTime, 0)))
	local function onTimeOut()
		if self.isDisposed or self.exitDisposed then return end
		self.exitDisposed = true
		PopoutManager:sharedInstance():remove(self, true)
	end
	setTimeOut(onTimeOut, animTime)
end

function InnerNotiPanel:_onEnterHandler(evt)
	self:onEnterHandler(evt)
	if evt == "enter" then
		local vSize = Director:sharedDirector():getVisibleSize()
		local position, scaleX, scaleY = self:getPosition(), self:getScaleX(), self:getScaleY()
		position = {x = position.x, y = position.y}
		self:stopAllActions()
		self:setPosition(ccp(self.enterPos.x, self.enterPos.y - vSize.height))
		self:setScale(0)
		self:runAction(CCSpawn:createWithTwoActions(CCMoveTo:create(animTime, ccp(position.x, position.y)), CCScaleTo:create(animTime, scaleX, scaleY)))
	elseif evt == "exit" then
		if self.isDisposed or self.exitDisposed then return end
		self.exitDisposed = true
		PopoutManager:sharedInstance():remove(self, true)
	end
end