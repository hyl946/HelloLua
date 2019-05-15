-------------------------------------------------------------------------
--  Class include: GroupButtonBase
-------------------------------------------------------------------------

kGroupButtonColorMode = {green=1,orange=2,blue=3,grey=4}
kColorBlueConfig = {0.622222,0,0.021,0.07}
kColorOrangeConfig = {-0.4, 0.3147, 0.1255, 0.3957}
kColorGreyConfig = {0, -1, 0, 0}
kButtonTextAlignment = {center = 1, left = 2, right = 3}

kVerticalLayout = {top = 1,center = 2,bottom = 3}

-- A文字(高64),B icon(58*58),C icon(any size)
ButtonStyleType = {
	TypeA = "A", 	-- 文字
	TypeAB = "AB", 	--  文字 + 图片
	TypeBA = "BA",	--  图片 + 文字
	TypeABA = "ABA",	--  文字1 + 图片 + 文字2
	TypeBAA = "BAA",	--  图片 + 文字1 + 文字2
	TypeACA = "ACA",	--  文字1 + 图片 + 文字2
	TypeCAA = "CAA",	--  图片 + 文字1 + 文字2
}

local ButtonLayoutParams = {
	padding = {top = 0, right = 28, bottom = 0, left = 28},
	minWidth = 270,
	textMargin = 10, imageMargin = 8,
}
local ButtonElementConst = {
	fixedIconSize = {width = 58, height = 70},
	delLineHeight = 3, delLineWidth = 70,
}
local kButtonLayoutDebug = false

local function isNewStyleButtonGroup(buttonGroup)
	return type(buttonGroup.symbolName) == "string" and string.starts(buttonGroup.symbolName,"ui_buttons_new/")
end

--
-- GroupButtonBase ---------------------------------------------------------
--
GroupButtonBase = class(EventDispatcher)
function GroupButtonBase:ctor( groupNode )
	self.groupNode = groupNode
	self:setLayoutParams(table.clone(ButtonLayoutParams))
end
function GroupButtonBase:create( buttonGroup , donotScaleOnTouch )
	if isNewStyleButtonGroup(buttonGroup) then
		return GroupButtonBase:createNewStyle( buttonGroup , donotScaleOnTouch )
	end
	local button = GroupButtonBase.new(buttonGroup)
	button:buildUI(donotScaleOnTouch)
	return button
end

function GroupButtonBase:setNewButtonStyle(buttonStyle)
	self.buttonStyle = buttonStyle
end

function GroupButtonBase:createNewStyle( buttonGroup , donotScaleOnTouch )
	-- if _G.isLocalDevelopMode then printx(101, " createNewStyle buttonGroup = " , table.tostring( buttonGroup ) ) end
	local button = GroupButtonBase.new(buttonGroup)
	button.isNewStyle = true
	button.buttonStyle = ButtonStyleType.TypeA
	button:buildUI(donotScaleOnTouch)
	return button
end

function GroupButtonBase:getContainer()
	return self.groupNode
end

function GroupButtonBase:getGroupBounds(targetCoordinateSpace)
	if self.groupNode and self.groupNode.refCocosObj then
		return self.groupNode:getGroupBounds(targetCoordinateSpace)
	end
	return nil
end

function GroupButtonBase:removeFromParentAndCleanup( cleanup )
	if self.groupNode and self.groupNode.refCocosObj then
		self.groupNode:removeFromParentAndCleanup(cleanup)
	end
end

function GroupButtonBase:setPositionX( positionX )
	if self.groupNode and self.groupNode.refCocosObj then
		self.groupNode:setPositionX(positionX)
	end
end
function GroupButtonBase:setPositionY( positionY )
	if self.groupNode and self.groupNode.refCocosObj then
		self.groupNode:setPositionY(positionY)
	end
end
function GroupButtonBase:getPositionX()
	if self.groupNode and self.groupNode.refCocosObj then
		return self.groupNode:getPositionX()
	end
end

function GroupButtonBase:getPositionY()
	if self.groupNode and self.groupNode.refCocosObj then
		return self.groupNode:getPositionY()
	end
end

function GroupButtonBase:setPosition( position )
	if self.groupNode and self.groupNode.refCocosObj then
		self.groupNode:setPosition(position)
	end
end
function GroupButtonBase:getPosition()
	if self.groupNode and self.groupNode.refCocosObj then
		return self.groupNode:getPosition()
	end
	return nil
end

function GroupButtonBase:setVisible( v )
	if self.groupNode and self.groupNode.refCocosObj then
		self.groupNode:setVisible(v)
	end
end

function GroupButtonBase:isVisible()
	if self.groupNode and self.groupNode.refCocosObj then
		return self.groupNode:isVisible()
	end
	return true
end

function GroupButtonBase:setMinWidth(minWidth)
	self.minWidth = minWidth
end

function GroupButtonBase:getMinWidth()
	return self.minWidth or self.params.minWidth
end

function GroupButtonBase:setString( str )
	local label = self.label
	self.isTwoChar = false
	self.labelDefString = str
	if label and label.refCocosObj then
		if self.isStaticLabel then label:setString(str)
		else
			if self.isNewStyle then
				local charTab = {}
				local labelStr = str
				if self:isLabelNeedSpaceWhenTwoChar() then
					for uchar in string.gfind(str, "[%z\1-\127\194-\244][\128-\191]*") do
						charTab[#charTab + 1] = uchar
					end
					if #charTab == 2 then
						labelStr = charTab[1] .. " " .. charTab[2]
						self.isTwoChar = true
					end
				end
				label:setText(labelStr)

				InterfaceBuilder:centerInterfaceInbox( label, self.labelRect, true )
				-- 经调试后的偏移值
				-- label:setPositionX(label:getPositionX() - 1)
				-- label:setPositionY(label:getPositionY() - 7)
				self:autoRelayoutElements()
			else
				label:setText(str)
				InterfaceBuilder:centerInterfaceInbox( label, self.labelRect )
			end
			--self:showDebugBounds()
		end
	end
end

-- label文案只有2个字符时是否需要补空格
function GroupButtonBase:isLabelNeedSpaceWhenTwoChar()
	return true
end

function GroupButtonBase:autoRelayoutElements()
	self:recalcLayout(ButtonStyleType.TypeA, {self.label})
end

function GroupButtonBase:resizeBackground(width)
	width = math.max(width, self:getMinWidth())
	local bgSize = self.background:getContentSize()
	self.background:setPreferredSize(CCSizeMake(width, bgSize.height))
	self.background:setPositionX(-width / 2)

	local shadow = self.groupNode:getChildByName("_shadow")
	if shadow then
		local shadowSize = shadow:getContentSize()
		shadow:setPreferredSize(CCSizeMake(width - 6, shadowSize.height))
		shadow:setPositionX(-(width - 6) / 2)
	end


	local hitNode = self.groupNode:getChildByName("hit_area")
	if hitNode then
		local hitNodeSize = hitNode:getContentSize()
		hitNode:setScaleX(width/hitNodeSize.width)
		hitNode:setPositionX(-width / 2)
	end

	if self._offsetFlag then
		if self.params.padding.left ~= self.params.padding.right then
			local offsetX = (self.params.padding.left - self.params.padding.right) / 2
			self.background:setPositionX(self.background:getPositionX() - offsetX)
			if shadow then
				shadow:setPositionX(shadow:getPositionX() - offsetX)
			end
			if hitNode then
				hitNode:setPositionX(hitNode:getPositionX() - offsetX)
			end
		end
	end
end

function GroupButtonBase:getString()
	if self.label and self.label.refCocosObj then
		return self.label:getString()
	end
end

function GroupButtonBase:setTextAlignment(label, labelRect, alignment, isStatic)
	if label and labelRect and label.refCocosObj then
		if isStatic then
			if alignment == kButtonTextAlignment.left then
				label:setHorizontalAlignment(kCCTextAlignmentLeft)
			elseif alignment == kButtonTextAlignment.right then
				label:setHorizontalAlignment(kCCTextAlignmentRight)
			else
				label:setHorizontalAlignment(kCCTextAlignmentCenter)
			end
		else
			if alignment == kButtonTextAlignment.left then
				InterfaceBuilder:leftAligneInterfaceInbox(label, labelRect)
			elseif alignment == kButtonTextAlignment.right then
				InterfaceBuilder:rightAligneInterfaceInbox(label, labelRect)
			else
				InterfaceBuilder:centerInterfaceInbox( label, labelRect )
			end
		end
	end
end

function GroupButtonBase:setStringAlignment(alignment)
	self:setTextAlignment(self.label, self.labelRect, alignment, self.isStaticLabel)
end

function GroupButtonBase:setScale( scale )
	if self.groupNode and self.groupNode.refCocosObj then
		self.groupNode:setScale(scale)
		self.groupNode.transformData = nil
		self.groupNode:setButtonMode(true)
	end
end

function GroupButtonBase:getScale()
	if self.groupNode and self.groupNode.refCocosObj then
		return self.groupNode:getScale()
	end
	return 1
end

function GroupButtonBase:setColorMode( colorMode, force )
	if self.colorMode ~= colorMode or force then
		self.colorMode = colorMode
		local background = self.background
		if background and background.refCocosObj then
			if colorMode == kGroupButtonColorMode.green then background:clearAdjustColorShader()
			elseif colorMode == kGroupButtonColorMode.orange then
				--background:setHsv(301.42, 1.2336, 1.4941)
				background:adjustColor(kColorOrangeConfig[1],kColorOrangeConfig[2],kColorOrangeConfig[3],kColorOrangeConfig[4])
				background:applyAdjustColorShader()
			elseif colorMode == kGroupButtonColorMode.blue then
				--background:setHsv(103.968, 0.97315, 1.23361)
				background:adjustColor(kColorBlueConfig[1],kColorBlueConfig[2],kColorBlueConfig[3],kColorBlueConfig[4])
				background:applyAdjustColorShader()
			elseif colorMode == kGroupButtonColorMode.grey then
				background:adjustColor(kColorGreyConfig[1],kColorGreyConfig[2],kColorGreyConfig[3],kColorGreyConfig[4])
				background:applyAdjustColorShader()
			end
		end
	end
end
function GroupButtonBase:getColorMode()
	return self.colorMode
end

function GroupButtonBase:setEnabled( isEnabled, notChangeColor)
	if self.isEnabled ~= isEnabled then
		self.isEnabled = isEnabled

		if self.groupNode and self.groupNode.refCocosObj then
			self.groupNode:setTouchEnabled(isEnabled, 0, true,nil,true)
			if not notChangeColor then 
				if isEnabled then
					self:setColorMode(self.colorMode, true)
				else
					local background = self.background
					if background and background.refCocosObj then
						background:applyAdjustColorShader()
						background:adjustColor(0,-1, 0, 0)
					end
				end
			end
		end		
	end
end

function GroupButtonBase:getEnabled()
	return self.isEnabled
end

-- 设置成灰色，但是仍可点击
-- 原因：需求中常常要求置灰，但可点击
function GroupButtonBase:setEnabledForColorOnly(enable)
	if self.groupNode and self.groupNode.refCocosObj then
		if enable then
			self:setColorMode(self.colorMode, true)
		else
			local background = self.background
			if background and background.refCocosObj then
				background:applyAdjustColorShader()
				background:adjustColor(0,-1, 0, 0)
			end
		end
	end
end


function GroupButtonBase:getParent()
	if self.groupNode and self.groupNode.refCocosObj then
		return self.groupNode:getParent()
	end
end

function GroupButtonBase:showDebugBounds()
	local label = self.label
	local labelSize = label:getContentSize()
	local labelPosi = label:getPosition()
	local boundsLayer = LayerColor:create()
	boundsLayer:setColor(ccc3(128,55,144))
	boundsLayer:setOpacity(80)
	boundsLayer:changeWidthAndHeight(labelSize.width, labelSize.height)
	boundsLayer:setAnchorPoint(ccp(0,0))
	boundsLayer:setPosition(ccp(labelPosi.x, labelPosi.y-labelSize.height))

	local parentLayer = label:getParent()
	if parentLayer then parentLayer:addChild(boundsLayer) end
end

function GroupButtonBase:useStaticLabel(fontSize, fontName, fontColor)
	self.isStaticLabel = true
	local rect = self.labelRect
	local label = TextField:create("",fontName, fontSize, CCSizeMake(rect.width, rect.height), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
	label:setString(self:getString())
	label:setPosition(ccp(rect.x, rect.y))
	label:setAnchorPoint(ccp(0, 1))
	if fontColor ~= nil then label:setColor(fontColor) end

	local parent = self.label:getParent()
	if parent then
		self.label:removeFromParentAndCleanup(true)
		parent:addChild(label)
		self.label = label
	end
end

function GroupButtonBase:buildUI(donotScaleOnTouch)
	if not self.groupNode then return end

	local groupNode = self.groupNode
	local label = groupNode:getChildByName("label")
	local labelSize = groupNode:getChildByName("labelSize")
	local background = groupNode:getChildByName("background")
	local size = labelSize:getContentSize() --labelSize:getGroupBounds() --
	local position = labelSize:getPosition()
	local scaleX = labelSize:getScaleX()
	local scaleY = labelSize:getScaleY()
	self.labelRect = {x=position.x, y=position.y, width=size.width*scaleX, height=size.height*scaleY}
	self.label = label
	self.background = background
	
	local buttonGroupSymbolName = self.groupNode.symbolName or ""
	if string.find( buttonGroupSymbolName , '@type_bule') then
		self:setColorMode(kGroupButtonColorMode.blue)
	elseif string.find( buttonGroupSymbolName , '@type_orange') then
		self:setColorMode(kGroupButtonColorMode.orange)
	else
		self:setColorMode(kGroupButtonColorMode.green)
	end
	self:setEnabled(true)
	groupNode:setButtonMode(true , donotScaleOnTouch)
	labelSize:removeFromParentAndCleanup(true)

	local function onTouchTap( evt )
		self:dispatchEvent(DisplayEvent.new(DisplayEvents.kTouchTap, self, evt.globalPosition))
		GamePlayMusicPlayer:playEffect(GameMusicType.kClickCommonButton)
	end
	groupNode:addEventListener(DisplayEvents.kTouchTap, onTouchTap)
end

function GroupButtonBase:useBubbleAnimation(factor)
	factor = factor or 0
	local startButton = self.groupNode
	local deltaTime = 0.9
	local scaleX = startButton:getScaleX()
	local scaleY = startButton:getScaleY()
	local animations = CCArray:create()
	animations:addObject(CCScaleTo:create(deltaTime, scaleX * 0.98 * (1 - factor), scaleY * 1.03 * (1 - factor)))
	animations:addObject(CCScaleTo:create(deltaTime, scaleX * 1.01 * (1 + factor), scaleY * 0.96 * (1 + factor)))
	animations:addObject(CCScaleTo:create(deltaTime, scaleX * 0.98 * (1 - factor), scaleY * 1.03 * (1 - factor)))
	animations:addObject(CCScaleTo:create(deltaTime, scaleX * 1, scaleY * 1))
	local action = CCRepeatForever:create(CCSequence:create(animations))
	startButton:runAction(action)
	startButton:setButtonMode(false)

	local btnWithoutShadow = self.background
	local function __onButtonTouchBegin( evt )
		if btnWithoutShadow and not btnWithoutShadow.isDisposed then
			btnWithoutShadow:setOpacity(200)
		end
	end
	local function __onButtonTouchEnd( evt )
		if btnWithoutShadow and not btnWithoutShadow.isDisposed then
			btnWithoutShadow:setOpacity(255)
		end
	end
	startButton:addEventListener(DisplayEvents.kTouchBegin, __onButtonTouchBegin)
	startButton:addEventListener(DisplayEvents.kTouchEnd, __onButtonTouchEnd)

	local ret = {}
	ret.cancelBubbleAnimation = function(self)
		startButton:setScaleX(scaleX)
		startButton:setScaleY(scaleY)
		startButton:stopAction(action)
		startButton:removeEventListener(DisplayEvents.kTouchBegin, __onButtonTouchBegin)
		startButton:removeEventListener(DisplayEvents.kTouchEnd, __onButtonTouchEnd)
	end

	return ret
end

function GroupButtonBase:playFloatAnimation(text, callback)
	local label = self.label
	local floatText = nil

	if label.class == BitmapText then--使用位图字体的按钮
		local fntFile = label:getFntFile()
		fntFile = string.gsub(fntFile, '@2x', '')
		floatText = BitmapText:create('', fntFile, -1, kCCTextAlignmentCenter)
		floatText:setPreferredSize(1024, self.labelRect.height)
	end
	if label.class == TextField then
		floatText = TextField:createCopy(label)
		floatText:setHorizontalAlignment(kCCTextAlignmentCenter)
		floatText:setAnchorPoint(ccp(0.5, 0.5))
	end

	if floatText then
		floatText:setString(text)
		local parent = self.groupNode:getParent()
		if parent then
			parent:addChild(floatText)
			floatText:setScaleX(self.groupNode:getScaleX()*floatText:getScaleX())
			floatText:setScaleY(self.groupNode:getScaleY()*floatText:getScaleY())
			local startPos = ccp(
				self.groupNode:getGroupBounds():getMidX(),
				self.groupNode:getGroupBounds():getMidY()
			)
			startPos = parent:convertToNodeSpace(startPos)
			local endPos = ccp(
				startPos.x,
				startPos.y + self.labelRect.height
			)
			floatText:setPositionXY(startPos.x, startPos.y)
			local moveTo = CCMoveTo:create(1.2, endPos)
			local delay = CCDelayTime:create(0.8)
			local fadeOut = CCFadeOut:create(0.4)

			local seq = CCSequence:createWithTwoActions(delay, fadeOut)
			local spawn = CCSpawn:createWithTwoActions(seq, moveTo)

			local finish = CCCallFunc:create(
					function()
						floatText:removeFromParentAndCleanup(true)
						if callback then
							callback()
						end
					end
				)
			local action = CCSequence:createWithTwoActions(spawn, finish)
			floatText:runAction(action)
		end
	else
		if callback then
			callback()
		end
	end
end

function GroupButtonBase:setLayoutParams(params)
	-- print("GroupButtonBase:setLayoutParams",params,debug.traceback())
	assert(params and params.padding,"need .padding")
	self.params = params
end

function GroupButtonBase:getLayoutParams(params)
	return self.params
end

function GroupButtonBase:recalcLayout(layoutType, elements, rects)
	local contentWidth = 0
	local eleCount = #layoutType
	local eleDataList = {}
	local eleSize = nil

	local preShowEleData = nil
	for i = 1, eleCount do
		local elementType = string.sub(layoutType, i, i)

		local eleData = {}
		eleData.ui = elements[i]
		eleData.rect = {x = 0, y = 0, width = 0, height = 0}
		eleData.eleType = elementType
		eleData.marginLeft = 0
		eleData.contentSize = {width = 0, height = 0}
		if eleData.ui and eleData.ui:isVisible() then
			local spRect = rects and rects[i] or {}
			local ele = eleData.ui
			local contentSize = ele:getContentSize()
			eleData.contentSize = {width = contentSize.width * ele:getScaleX(), height = contentSize.height * ele:getScaleY()}

			if eleData.eleType == 'A' then
				-- 休整一下字体宽高
				if eleData.ui:getString() == "" then
					eleData.contentSize = {width = 0, height = 0}
				else
					eleData.contentSize = {width = (contentSize.width - 10) * ele:getScaleX(), height = (contentSize.height - 10) * ele:getScaleY()}
				end
				eleData.rect.width = spRect.width or eleData.contentSize.width
				eleData.rect.height = spRect.height or eleData.contentSize.height
				eleData.rect.x = -6 * ele:getScaleX()
				-- eleData.rect.y = -5 * ele:getScaleY()

				local currentParams = self.params.elements and self.params.elements[i]
				if currentParams then
					if currentParams.fixWidth then
						eleData.rect.width = eleData.rect.width + currentParams.fixWidth
					end
					if currentParams.marginLeft then
						eleData.marginLeft = currentParams.marginLeft
					end
				end
			else
				if eleData.eleType == 'B' then
					eleData.rect.width = spRect.width or ButtonElementConst.fixedIconSize.width
					eleData.rect.height = spRect.height or ButtonElementConst.fixedIconSize.height
					-- eleData.rect.x = (eleData.rect.width - contentSize.width*ele:getScaleX()) / 2
					-- eleData.rect.y = (eleData.rect.height - contentSize.height*ele:getScaleY()) / 2 - 1
				elseif eleData.eleType == 'C' then
					eleData.rect.width = spRect.width or eleData.contentSize.width
					eleData.rect.height = spRect.height or eleData.contentSize.height
					-- eleData.rect.x = 0
					-- eleData.rect.y = -1
				end

				if self.params and self.params.iconFixWidth then
					eleData.rect.width = eleData.rect.width + self.params.iconFixWidth
				end
			end

			if eleData.rect.width > 0 then
				if preShowEleData then
					if string.find("BC", preShowEleData.eleType) or string.find("BC", eleData.eleType) then
						eleData.marginLeft = self.params.imageMargin
					else
						eleData.marginLeft = self.params.textMargin
					end
				end
				preShowEleData = eleData
			end

			contentWidth = contentWidth + eleData.marginLeft + eleData.rect.width
		end

		eleDataList[i] = eleData
	end
	preShowEleData = nil

	local btnWidth = contentWidth + self.params.padding.left + self.params.padding.right
	self:resizeBackground(btnWidth)
	local leftPosX = -contentWidth / 2 + (self.params.leftPosXFix or 0)
	local btnHeight = self.background:getContentSize().height
	-- 位置布局测试
	if kButtonLayoutDebug then
		if self.buttonElementBounds then
			for _, v in ipairs(self.buttonElementBounds) do v:removeFromParentAndCleanup(true) end
		end
		self.buttonElementBounds = {}
	end

	local baseY = nil
	local baseH = nil

	for i,v in ipairs(eleDataList) do
		local eleData = eleDataList[i]
		if eleData.ui then
			leftPosX = leftPosX + eleData.marginLeft
			local posY = eleData.ui:getPositionY()
			-- printx(0, "recalcLayout", eleData.rect.x, eleData.rect.y, eleData.rect.width, eleData.rect.height, eleData.marginLeft)
			eleData.ui:setPositionX(leftPosX+eleData.rect.x + (eleData.rect.width - eleData.contentSize.width) / 2)
			eleData.ui:setPositionY(eleData.contentSize.height / 2 + eleData.rect.y)

			if self.params and self.params.verticalLayout == kVerticalLayout.bottom then
				--底对齐
				if not baseY then
					baseY = eleData.contentSize.height / 2 + eleData.rect.y
					baseH = eleData.contentSize.height
				end
				eleData.ui:setPositionY(baseY-(baseH-eleData.contentSize.height))
			end

			if kButtonLayoutDebug then
				local labelPh = LayerColor:createWithColor(ccc3(255, 0, 0), eleData.rect.width, eleData.rect.height ) 
				table.insert(self.buttonElementBounds, labelPh)
				labelPh:setAnchorPoint(ccp(0, 1))
				labelPh:ignoreAnchorPointForPosition(false)
				labelPh:setOpacity(122)
				labelPh:setPositionX(leftPosX)
				labelPh:setPositionY(eleData.rect.height / 2)
				self.groupNode:addChild(labelPh)
			end

			leftPosX = leftPosX + eleData.rect.width
		end
	end
end

--
-- ButtonNumberBase ---------------------------------------------------------
--
ButtonNumberBase = class(GroupButtonBase)
function ButtonNumberBase:create( buttonGroup )
	if isNewStyleButtonGroup(buttonGroup) then
		return ButtonNumberBase:createNewStyle( buttonGroup , donotScaleOnTouch )
	end

	local button = ButtonNumberBase.new(buttonGroup)
	button:buildUI()
	return button
end

function ButtonNumberBase:createNewStyle( buttonGroup )
	local button = ButtonNumberBase.new(buttonGroup)
	button.isNewStyle = true
	button.buttonStyle = ButtonStyleType.TypeCAA
	button:buildUI()
	-- remove icon rect
	buttonGroup:getChildByName("iconSize"):removeFromParentAndCleanup(true)
	return button
end

function ButtonNumberBase:autoRelayoutElements()
	self:recalcLayout(ButtonStyleType.TypeCAA, {nil, self.numberLabel, self.label})
end

function ButtonNumberBase:buildUI()
	if not self.groupNode then return end

	GroupButtonBase.buildUI(self)
	local groupNode = self.groupNode
	local numberSize = groupNode:getChildByName("numberSize")
	local size = numberSize:getContentSize()
	local position = numberSize:getPosition()
	local scaleX = numberSize:getScaleX()
	local scaleY = numberSize:getScaleY()
	self.numberRect = {x=position.x, y=position.y, width=size.width*scaleX, height=size.height*scaleY}
	numberSize:removeFromParentAndCleanup(true)

	self.numberLabel = groupNode:getChildByName("number")
end

function ButtonNumberBase:isLabelNeedSpaceWhenTwoChar()
	if self.numberLabel and self.numberLabel:isVisible() and self.numberLabel:getString() ~= "" then
		return false
	end
	return true
end

function ButtonNumberBase:setNumber( str )
	local numberLabel = self.numberLabel
	if numberLabel and numberLabel.refCocosObj then
		if self.isStaticNumberLabel then numberLabel:setString(str)
		else
			numberLabel:setText(str)
			if self.isNewStyle then
				InterfaceBuilder:centerInterfaceInbox( numberLabel, self.numberRect, true )
				if self.isTwoChar then
					self:setString( self.labelDefString )
				else
					self:autoRelayoutElements()
				end
			else
				InterfaceBuilder:centerInterfaceInbox( numberLabel, self.numberRect )
			end
		end
	end
end
function ButtonNumberBase:getNumber()
	if self.numberLabel and self.numberLabel.refCocosObj then
		return self.numberLabel:getString()
	end
end
function ButtonNumberBase:setNumberAlignment(alignment)
	self:setTextAlignment(self.numberLabel, self.numberRect, alignment, self.isStaticNumberLabel)
end
function ButtonNumberBase:useStaticNumberLabel(fontSize, fontName, fontColor)
	self.isStaticNumberLabel = true
	local rect = self.numberRect
	local label = TextField:create("",fontName, fontSize, CCSizeMake(rect.width, rect.height), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
	label:setString(self:getString())
	label:setPosition(ccp(rect.x, rect.y))
	label:setAnchorPoint(ccp(0, 1))
	if fontColor ~= nil then label:setColor(fontColor) end

	local parent = self.numberLabel:getParent()
	if parent then
		self.numberLabel:removeFromParentAndCleanup(true)
		parent:addChild(label)
		self.numberLabel = label
	end
end

--
-- ButtonIconsetBase ---------------------------------------------------------
--
ButtonIconsetBase = class(GroupButtonBase)

function ButtonIconsetBase:ctor()
	self.isIconButtonType = true
end

function ButtonIconsetBase:create( buttonGroup )
	if isNewStyleButtonGroup(buttonGroup) then
		return ButtonIconsetBase:createNewStyle( buttonGroup )
	end
	local button = ButtonIconsetBase.new(buttonGroup)
	button:buildUI()
	return button
end

function ButtonIconsetBase:createNewStyle( buttonGroup, buttonStyle )
	local button = ButtonIconsetBase.new(buttonGroup)
	button.isNewStyle = true
	button.buttonStyle = buttonStyle or ButtonStyleType.TypeBA
	button:buildUI()
	return button
end

function ButtonIconsetBase:isIconNeedScale()
	if type(self.buttonStyle) == "string" and string.find(self.buttonStyle, "C") then
		return false
	end
	return true
end

function ButtonIconsetBase:setIconByFrameName( frameName, forceScale )
	local image = assert(SpriteColorAdjust:createWithSpriteFrameName(frameName))
	image:setAnchorPoint(ccp(0, 1))
	self:setIcon(image, forceScale)
end

function ButtonIconsetBase:setIcon( icon, forceScale )
	if self.icon ~= icon then
		if self.icon then self.icon:removeFromParentAndCleanup(true) end
		self.icon = icon
		if icon and self.groupNode and self.groupNode.refCocosObj then
			self.groupNode:addChild(icon)
			if self.isNewStyle then
				if forceScale == nil then forceScale = self:isIconNeedScale() end
				InterfaceBuilder:alignInterfaceInbox( icon, self.iconRect, forceScale )
			else
				InterfaceBuilder:centerInterfaceInbox( icon, self.iconRect, forceScale )
			end
		end
		if self.isNewStyle then
			if self.isTwoChar then
				self:setString( self.labelDefString )
			else
				self:autoRelayoutElements()
			end
		end
	end
end
function ButtonIconsetBase:getIcon()
	return self.icon
end

function ButtonIconsetBase:isLabelNeedSpaceWhenTwoChar()
	if self.icon and self.icon:isVisible() then
		return false
	end
	return true
end

function ButtonIconsetBase:autoRelayoutElements()
	if self.buttonStyle == ButtonStyleType.TypeAB then
		self:recalcLayout(ButtonStyleType.TypeAB, {self.label, self.icon})
	elseif self.buttonStyle == ButtonStyleType.TypeBA then
		self:recalcLayout(ButtonStyleType.TypeBA, {self.icon, self.label})
	end
end

function ButtonIconsetBase:buildUI()
	if not self.groupNode then return end

	GroupButtonBase.buildUI(self)
	local groupNode = self.groupNode
	if self.isNewStyle then
		self.icon = groupNode:getChildByName("icon")
	end
	local iconSize = groupNode:getChildByName("iconSize")
	if iconSize then
		local size = iconSize:getContentSize()
		local position = iconSize:getPosition()
		local scaleX = iconSize:getScaleX()
		local scaleY = iconSize:getScaleY()
		self.iconRect = {x=position.x, y=position.y, width=size.width*scaleX, height=size.height*scaleY}
		iconSize:removeFromParentAndCleanup(true)
	end
end

function ButtonIconsetBase:setIconEnabled( isEnabled )
	if self.icon and self.icon.refCocosObj then
		if isEnabled then self.icon:clearAdjustColorShader()
		else 
			self.icon:applyAdjustColorShader()
			self.icon:adjustColor(0,-1, 0, 0)
		end
	end
end

function ButtonIconsetBase:setEnabled( isEnabled ,notChangeColor)
	GroupButtonBase.setEnabled(self, isEnabled, notChangeColor)
	if not notChangeColor then 
		self:setIconEnabled(isEnabled)
	end
end

--
-- ButtonIconNumberBase ---------------------------------------------------------
--
ButtonIconNumberBase = class(ButtonIconsetBase)
function ButtonIconNumberBase:create( buttonGroup )
	if isNewStyleButtonGroup(buttonGroup) then
		return ButtonIconNumberBase:createNewStyle( buttonGroup )
	end
	local button = ButtonIconNumberBase.new(buttonGroup)
	button:buildUI()
	return button
end

function ButtonIconNumberBase:createNewStyle( buttonGroup, buttonStyle )
	local button = ButtonIconNumberBase.new(buttonGroup)
	button.isNewStyle = true
	button.buttonStyle = buttonStyle or ButtonStyleType.TypeBAA
	button:buildUI()
	return button
end

function ButtonIconNumberBase:buildUI()
	if not self.groupNode then return end

	ButtonIconsetBase.buildUI(self)
	local groupNode = self.groupNode
	local numberSize = groupNode:getChildByName("numberSize")
	local size = numberSize:getContentSize()
	local position = numberSize:getPosition()
	local scaleX = numberSize:getScaleX()
	local scaleY = numberSize:getScaleY()
	self.numberRect = {x=position.x, y=position.y, width=size.width*scaleX, height=size.height*scaleY}
	numberSize:removeFromParentAndCleanup(true)

	self.numberLabel = groupNode:getChildByName("number")

	self.delNumberLabel = groupNode:getChildByName("delNumber")
	if self.delNumberLabel then
		self.delNumberLabel:changeFntFile("fnt/prop_name.fnt")
		self.delNumberLine = nil
		local numberSize = groupNode:getChildByName("delNumberSize")
		local size = numberSize:getContentSize()
		local position = numberSize:getPosition()
		local scaleX = numberSize:getScaleX()
		local scaleY = numberSize:getScaleY()
		self.delNumberRect = {x=position.x, y=position.y, width=size.width*scaleX, height=size.height*scaleY}
		numberSize:removeFromParentAndCleanup(true)
	end
end

---------------------------
-- numColor
-- delStyle none(0) line(1) slash(2 default)
-- delColor
---------------------------
function ButtonIconNumberBase:setDelNumber(str, numColor, delStyle, delColor)
	local numberLabel = self.delNumberLabel
	if numberLabel and numberLabel.refCocosObj then
		if not str then
			numberLabel:setString("")
			self:autoRelayoutElements()
			return
		end
		if useStatic then numberLabel:setString(str)
		else
			numberLabel:setText(str)
			if self.isNewStyle then
				delStyle = delStyle or 2
				delColor = delColor or hex2ccc3("D31D0E")
				numColor = numColor or hex2ccc3("0458D7")
				if numColor then numberLabel:setColor(numColor) end
				InterfaceBuilder:centerInterfaceInbox( numberLabel, self.delNumberRect, true )
				local lineWidth = numberLabel:getContentSize().width * numberLabel:getScaleX()
				if self.delNumberLine then 
					self.delNumberLine:removeFromParentAndCleanup(true)
					self.delNumberLine = nil
				end
				if delStyle == 1 then
					self.delNumberLine = Sprite:createWithSpriteFrameName("common.flag/del_line0000") -- LayerColor:createWithColor(delColor, 4, ButtonElementConst.delLineHeight)
				elseif delStyle == 2 then
					self.delNumberLine = Sprite:createWithSpriteFrameName("common.flag/del_slash0000") -- LayerColor:createWithColor(delColor, 4, ButtonElementConst.delLineHeight)
				end
				if self.delNumberLine then
					self.groupNode:addChild(self.delNumberLine)
					self.delNumberLine:setAnchorPoint(ccp(0.5, 0.5))
					self.delNumberLine:ignoreAnchorPointForPosition(false)
					self.delNumberLine:setOpacityModifyRGB(true)
					self.delNumberLine:setColor(delColor)
				end
				self:autoRelayoutElements()
			end
		end
	end
end

function ButtonIconNumberBase:setNumber( str )
	local numberLabel = self.numberLabel
	if numberLabel and numberLabel.refCocosObj then
		if not str then
			numberLabel:setString("")
			self:autoRelayoutElements()
			return
		end
		if self.isStaticNumberLabel then numberLabel:setString(str)
		else
			numberLabel:setText(str)
			if self.isNewStyle then
				InterfaceBuilder:centerInterfaceInbox( numberLabel, self.numberRect, true )
				if self.isTwoChar then
					self:setString( self.labelDefString )
				else
					self:autoRelayoutElements()
				end
			else
				InterfaceBuilder:centerInterfaceInbox( numberLabel, self.numberRect )
			end
		end
	end
end
function ButtonIconNumberBase:getNumber()
	if self.numberLabel and self.numberLabel.refCocosObj then
		return self.numberLabel:getString()
	end
end
function ButtonIconNumberBase:setNumberAlignment(alignment)
	self:setTextAlignment(self.numberLabel, self.numberRect, alignment, self.isStaticNumberLabel)
end

function ButtonIconNumberBase:isLabelNeedSpaceWhenTwoChar()
	if self.icon and self.icon:isVisible() then
		return false
	end
	if self.numberLabel and self.numberLabel:isVisible() and self.numberLabel:getString() ~= "" then
		return false
	end
	return true
end

function ButtonIconNumberBase:useStaticNumberLabel(fontSize, fontName, fontColor)
	self.isStaticNumberLabel = true
	local rect = self.numberRect
	local label = TextField:create("",fontName, fontSize, CCSizeMake(rect.width, rect.height), kCCTextAlignmentCenter, kCCVerticalTextAlignmentCenter)
	label:setString(self:getString())
	label:setPosition(ccp(rect.x, rect.y))
	label:setAnchorPoint(ccp(0, 1))
	if fontColor ~= nil then label:setColor(fontColor) end

	local parent = self.numberLabel:getParent()
	if parent then
		self.numberLabel:removeFromParentAndCleanup(true)
		parent:addChild(label)
		self.numberLabel = label
	end
end

function ButtonIconNumberBase:isDelNumberLabelNotEmpty()
	return self.delNumberLabel and self.delNumberLabel:getString() ~= ""
end

function ButtonIconNumberBase:autoRelayoutElements()
	local numberLabelRect = nil
	if self:isDelNumberLabelNotEmpty() then
		local delNumberSize = self.delNumberLabel:getGroupBounds(self.groupNode).size
		local numberSize = self.numberLabel:getGroupBounds(self.groupNode).size
		numberLabelRect = {width = math.max(delNumberSize.width, numberSize.width)}
	end
	if self.buttonStyle == ButtonStyleType.TypeBAA or self.buttonStyle == ButtonStyleType.TypeCAA then
		self:recalcLayout(self.buttonStyle, {self.icon, self.numberLabel, self.label}, {nil, numberLabelRect, nil})
	elseif self.buttonStyle == ButtonStyleType.TypeABA or self.buttonStyle == ButtonStyleType.TypeACA then
		self:recalcLayout(self.buttonStyle, {self.label, self.icon, self.numberLabel}, {nil, nil, numberLabelRect})
	end
	self:autoRelayoutDelNumber()
end

function ButtonIconNumberBase:autoRelayoutDelNumber()
	if self.delNumberLabel then
		if self:isDelNumberLabelNotEmpty() then
			self.numberLabel:setPositionY(self.numberRect.y)

			self.delNumberLabel:setVisible(true)
			local numberGb = self.numberLabel:getGroupBounds(self.groupNode)
			local delNumberSize = self.delNumberLabel:getGroupBounds(self.groupNode).size
			self.delNumberLabel:setPositionX(numberGb.origin.x + (numberGb.size.width - delNumberSize.width) / 2)

			if self.delNumberLine then
				local delNumberPos = self.delNumberLabel:getGroupBounds(self.groupNode).origin
				
				self.delNumberLine:setVisible(true)
				self.delNumberLine:setScaleX((delNumberSize.width + 12) / ButtonElementConst.delLineWidth) --changeWidthAndHeight(delNumberSize.width + 12, self.delNumberLine:getContentSize().height)
				self.delNumberLine:setPositionX(delNumberPos.x + delNumberSize.width / 2 + 1)
				self.delNumberLine:setPositionY(delNumberPos.y + delNumberSize.height / 2)
			end
		else
			self.delNumberLabel:setVisible(false)
			if self.delNumberLine then
				self.delNumberLine:setVisible(false)
			end
		end
	end
end

--
-- ButtonStartGame ---------------------------------------------------------
--
ButtonStartGame = class(ButtonIconNumberBase)
function ButtonStartGame:ctor( groupNode )
	self.groupNode = groupNode
	self.isMaxEnergyMode = false
end
function ButtonStartGame:create()
	local builder = InterfaceBuilder:createWithContentsOfFile("ui/common_ui.json")
	local buttonGroup = builder:buildGroup("ui_buttons/ui_start_button")
	local button = ButtonStartGame.new(buttonGroup)
	button:buildUI()
	return button
end
function ButtonStartGame:buildUI()
	if not self.groupNode then return end

	ButtonIconNumberBase.buildUI(self)
	local groupNode = self.groupNode
	self.infiniteEnergyIcon = groupNode:getChildByName("energy_icon")
	self.energyIcon = groupNode:getChildByName("icon")
	
	local labelRect = self.labelRect
	self.labelRectNormal = {x=labelRect.x, y=labelRect.y,width=labelRect.width,height=labelRect.height}
	self.labelRectInfinite = {x=labelRect.x + 60, y=labelRect.y,width=labelRect.width,height=labelRect.height}

	self:enableInfiniteEnergy(false)
end

function ButtonStartGame:enableInfiniteEnergy( enable )
	self.isMaxEnergyMode = enable
	if enable then
		self.infiniteEnergyIcon:setVisible(true)
		self.energyIcon:setVisible(false)
		self.numberLabel:setVisible(false)
		self.labelRect = self.labelRectInfinite
	else
		self.infiniteEnergyIcon:setVisible(false)
		self.labelRect = self.labelRectNormal
	end
	local str = self:getString() or ""
	self:setString(str)
end





--
-- SelectableButton ---------------------------------------------------------
--
SelectableButton = class(GroupButtonBase)
function SelectableButton:create( buttonGroup )
	local button = SelectableButton.new(buttonGroup)
	button:buildUI()
	return button
end

function SelectableButton:buildUI()
	if not self.groupNode then return end

	-- GroupButtonBase.buildUI(self)

	local groupNode = self.groupNode
	local label = groupNode:getChildByName("label")
	local labelSize = groupNode:getChildByName("labelSize")
	local background = groupNode:getChildByName("background")
	local size = labelSize:getContentSize() --labelSize:getGroupBounds() --
	local position = labelSize:getPosition()
	local scaleX = labelSize:getScaleX()
	local scaleY = labelSize:getScaleY()
	self.labelRect = {x=position.x, y=position.y, width=size.width*scaleX, height=size.height*scaleY}
	self.label = label
	self.background = background
	
	-- self:setColorMode(kGroupButtonColorMode.green)
	self:setEnabled(true)
	groupNode:setButtonMode(true)
	labelSize:removeFromParentAndCleanup(true)

	local function onTouchTap( evt )
		self:dispatchEvent(DisplayEvent.new(DisplayEvents.kTouchTap, self, evt.globalPosition))
		GamePlayMusicPlayer:playEffect(GameMusicType.kClickCommonButton)
	end
	groupNode:addEventListener(DisplayEvents.kTouchTap, onTouchTap)

	-- ------------------ inhiret end -----------------------
	local groupNode = self.groupNode
	self.backgroundSelected = groupNode:getChildByName("backgroundSelected")

	self:setSelect(false)
end

function SelectableButton:setSelect(value)
	self.select = value

	if (value) then 
		self.background:setVisible(false)
		self.backgroundSelected:setVisible(true)
	else
		self.background:setVisible(true)
		self.backgroundSelected:setVisible(false)
	end

end
