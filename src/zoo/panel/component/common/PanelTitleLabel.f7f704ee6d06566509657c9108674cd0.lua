
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年12月 9日 13:05:09
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

---------------------------------------------------
-------------- PanelTitleLabel
---------------------------------------------------

assert(not PanelTitleLabel)
PanelTitleLabel = class(Layer)

function PanelTitleLabel:init(levelNumber, diguanW, diguanH, levelNumberW, levelNumberH, manualAdjustInter, fntFile, ...)
	assert(#{...} == 0)
	
	-------------
	-- Init Base Class
	-- --------------
	Layer.initLayer(self)

	----------
	-- Data 
	-----------
	self.levelNumber = levelNumber

	local diguanWidth 	= diguanW or 58
	local diguanHeight	= diguanH or 58

	self.diguanWidth = diguanWidth
	self.diguanHeight = diguanHeight

	local diguanFntFile	= "fnt/titles.fnt" 
	if fntFile then
	    diguanFntFile = fntFile
	end
	if _G.useTraditionalChineseRes then diguanFntFile = "fnt/zh_tw/titles.fnt" end
	local diguanAlignment	= kCCTextAlignmentCenter

	local levelNumberWidth		= levelNumberW or 205.52
	local levelNumberHeight 	= levelNumberH or 68.5
	local levelNumberFntFile	= "fnt/titles.fnt"
	if fntFile then
	 	levelNumberFntFile = fntFile
	end
	local levelNumberAlignment	= kCCTextAlignmentCenter

	local manualAdjustInterval	= manualAdjustInter or 0

	self.manualAdjustInterval = manualAdjustInterval

	---------------------
	-- Create Label Char
	-- -----------------
	local chars = {}
	local diChar = BitmapText:create("", diguanFntFile, -1, diguanAlignment)
	diChar:setPreferredSize(diguanWidth, diguanHeight)
	self.diChar = diChar

	local diCharKey		= "start.game.panel.title_di"
	local diCharValue 	= Localization:getInstance():getText(diCharKey, {})
	diChar:setString(diCharValue)
	table.insert(chars, diChar)
	self:addChild(diChar)

	local levelNumberLabel = BitmapText:create("", levelNumberFntFile, -1, levelNumberAlignment)
	levelNumberLabel:setPreferredSize(levelNumberWidth, levelNumberHeight)
	levelNumberLabel:setString(tostring(self.levelNumber))
	table.insert(chars, levelNumberLabel)
	self:addChild(levelNumberLabel)
	self.levelNumberLabel = levelNumberLabel
	
	local guanChar = BitmapText:create("", diguanFntFile, -1, diguanAlignment)
	guanChar:setPreferredSize(diguanWidth, diguanHeight)

	local guanCharKey	= "start.game.panel.title_guan"
	local guanCharValue	= Localization:getInstance():getText(guanCharKey, {})
	guanChar:setString(guanCharValue)
	table.insert(chars, guanChar)
	self:addChild(guanChar)
	self.guanChar = guanChar
	
	local numberAdjustY = 0
	if fntFile == "fnt/guanqiatitle.fnt" then
		local oriScale = self.diChar:getScale()
		local diguanScale = oriScale * 0.8
		local numberScale = self.levelNumberLabel:getScale() * 1.2
		self.diChar:setScale(diguanScale)
		self.guanChar:setScale(diguanScale)
		self.levelNumberLabel:setScale(numberScale)
		numberAdjustY = 4 * numberScale
	end

	self:layout(numberAdjustY)
end

function PanelTitleLabel:layout(numberAdjustY)
	local _numberAdjustY = numberAdjustY or 0
	-- body
	-------------------
	-- Layout Chars
	-- ---------------
	local diContentWidth			= self.diChar:getGroupBounds().size.width
	local levelNumberLabelContentWidth	= self.levelNumberLabel:getGroupBounds().size.width
	local guanContentWidth			= self.guanChar:getGroupBounds().size.width
	
	-- di Char
	local startX = diContentWidth / 2


	local startY =  self.diguanHeight / 2

	self.diChar:setPosition(ccp(startX, startY))
	
	-- Level Number
	startX = startX + diContentWidth/2 + levelNumberLabelContentWidth/2 + self.manualAdjustInterval
	self.levelNumberLabel:setPosition(ccp(startX, startY + _numberAdjustY))

	-- Guan Char
	startX = startX + levelNumberLabelContentWidth/2 + guanContentWidth/2 + self.manualAdjustInterval
	self.guanChar:setPosition(ccp(startX, startY))

	------------------
	-- Update Content Size
	-- -----------------
	self:setContentSize(CCSizeMake(1, 1))
	local contentSize = self:getGroupBounds().size


	self:setContentSize(CCSizeMake(contentSize.width, self.diguanHeight))
end

function PanelTitleLabel:create(levelNumber, diguanWidth, diguanHeight, levelNumberWidth, levelNumberHeight, manualAdjustInterval, fntFile, ...)
	assert(#{...} == 0)

	local newPanelTitleLabel = PanelTitleLabel.new()
	newPanelTitleLabel:init(levelNumber,diguanWidth, diguanHeight, levelNumberWidth, levelNumberHeight, manualAdjustInterval, fntFile)
	return newPanelTitleLabel
end


function PanelTitleLabel:createWithString(string, length , fntName)
	local newPanelTitleLabel = PanelTitleLabel.new()
	newPanelTitleLabel:initWithString(string, length , fntName)
	return newPanelTitleLabel
end

function PanelTitleLabel:initWithString(text, length , fntName)

	-------------
	-- Init Base Class
	-- --------------
	Layer.initLayer(self)

	----------
	-- Data 
	-----------
	self.string = tostring(text)

	local fntFile	= "fnt/titles.fnt" 

	if fntName then
		fntFile = fntName
	end

	local stringAlignment	= kCCTextAlignmentCenter

	local manualAdjustInterval	= manualAdjustInter or 0

	---------------------
	-- Create Label Char
	-- -----------------

	local charWidth = 58
	local stringLabel = BitmapText:create("", fntFile, -1, stringAlignment)
	stringLabel:setPreferredSize(charWidth*length, charWidth)
	stringLabel:setString(tostring(self.string))
	self:addChild(stringLabel)
	

	-------------------
	-- Layout Chars
	-- ---------------
	local stringLabelContentWidth	= stringLabel:getGroupBounds().size.width
	startX = stringLabelContentWidth/2 + manualAdjustInterval
	stringLabel:setPosition(ccp(startX,  -29))

	------------------
	-- Update Content Size
	-- -----------------

	local contentSize = self:getGroupBounds().size
	self:setContentSize(CCSizeMake(contentSize.width, height))
end
--通常 
-- sz1 = 第 
-- sz2 = N 
-- sz3 = 关
function PanelTitleLabel:setLevelTitle( sz1, sz2, sz3 )
	if self.isDisposed then return end

	sz1 = sz1 or ''
	sz2 = sz2 or ''
	sz3 = sz3 or ''

	if self.stringLabel then
		self.stringLabel:setString(sz1 .. sz2 .. sz3)
		return
	end

	if self.diChar then
		self.diChar:setString(sz1, true)
	end

	if self.guanChar then
		self.guanChar:setString(sz3, true)
	end

	if self.levelNumberLabel then
		self.levelNumberLabel:setString(sz2, true)
		self:layout()
	end
end