--=====================================================
-- EndGameUseButton  EndGameBuyButton
-- by zhijian.li
-- (c) copyright 2009 - 2016, www.happyelements.com
-- All Rights Reserved. 
--=====================================================
-- filename:  EndGameComponent.lua
-- author:    zhijian.li
-- e-mail:    zhijian.li@happyelements.com
-- created:   2016/09/29
-- descrip:   最终加五步面板用的组件
--=====================================================

local UIHelper = require 'zoo.panel.UIHelper'

local function buildButtonPropIcon(propId , groupNode)

	--道具图标
	local iconRect = groupNode:getChildByName("propIcon")

	if not iconRect then return end

	local builder = InterfaceBuilder:create(PanelConfigFiles.properties)
	local sprite = UIHelper:replaceLayer2LayerColor(builder:buildGroup("Prop_"..tostring(propId)))

	local groupScale = groupNode:getScale()
	local iSize = iconRect:getGroupBounds().size
	local sSize = sprite:getGroupBounds().size
	sprite:setScale( (iSize.height / sSize.height) / groupScale )
	local offsetX = 0
	local offsetY = 0
	if EndGamePropManager.getInstance():isReviveProp(itemId) then
		sprite:setScale(sprite:getScale()*0.9)
	elseif propId == ItemType.THIRD_ANNIVERSARY_ADD_FIVE then
		offsetX = 10
		offsetY = 35
		sprite:setScale(sprite:getScale()*1.2)
	end
	sprite:setPositionXY(iconRect:getPositionX()+offsetX, iconRect:getPositionY()+offsetY)
	iconRect:getParent():addChild(sprite)
	--self.propIconSprite = sprite
	iconRect:removeFromParentAndCleanup(true)

end

EndGameUseButton = class(GroupButtonBase)


function EndGameUseButton:create( buttonGroup ,propId ,donotScaleOnTouch)
	-- if _G.isLocalDevelopMode then printx(101, " createNewStyle buttonGroup = " , table.tostring( buttonGroup ) ) end
	local button = EndGameUseButton.new(buttonGroup)
	button.isNewStyle = true
	button.buttonStyle = ButtonStyleType.TypeA
	button:buildUI( donotScaleOnTouch ,propId)
	return button
end

function EndGameUseButton:buildUI(  donotScaleOnTouch ,propId  )

	GroupButtonBase.buildUI( self , donotScaleOnTouch )

	self.numberLabel = getRedNumTip()
	self.numberLabel.setString = function(context, str)
		local num = tonumber(str) or 0
		self.numberLabel:setNum(num)
	end
	self.numberLabel:setNum(0)
	local defalutScale = 1.3
	defalutScale = defalutScale * ( 0.7/0.9 ) 
	self.numberLabel:setScale( defalutScale )
	self.numberLabel:setPositionXY(370, -30)

	if self.groupNode:getChildByName("propIcon") then
	--	self.numberLabel:setScale(2)
		defalutScale = 2
		defalutScale = defalutScale * ( 0.7/0.9 ) 
		self.numberLabel:setScale( defalutScale )
		self.numberLabel:setPositionXY(197, 50)
	end

	self.groupNode:addChild(self.numberLabel)

	buildButtonPropIcon( propId , self.groupNode )

	local groupBoundsSize = self:getGroupBounds().size
	
	-- if _G.isLocalDevelopMode then printx(101, " EndGameUseButton setNumber =  " , groupBoundsSize.width  ) end

	self.numberLabel:setPositionX( groupBoundsSize.width/2 + 12  )
end



-- function EndGameUseButton:create(groupNode, propId)
-- 	local button = EndGameUseButton.new(groupNode)
-- 	button:buildUI()
-- 	button.numberLabel = getRedNumTip()
-- 	button.numberLabel.setString = function(context, str)
-- 		local num = tonumber(str) or 0
-- 		button.numberLabel:setNum(num)
-- 	end
-- 	button.numberLabel:setNum(0)
-- 	button.numberLabel:setScale(1.3)
-- 	button.numberLabel:setPositionXY(370, -32)

-- 	if groupNode:getChildByName("propIcon") then
-- 		button.numberLabel:setScale(2)
-- 		button.numberLabel:setPositionXY(190, 65)
-- 	end

-- 	groupNode:addChild(button.numberLabel)

-- 	buildButtonPropIcon( propId , groupNode )
	
-- 	return button
-- end
function EndGameUseButton:setNumber(number)
	self.numberLabel:setString(number)

end


EndGameBuyButton = class(ButtonIconNumberBase)
function EndGameBuyButton:create(groupNode , propId )
	local button = EndGameBuyButton.new(groupNode)
	button:init(groupNode)
	buildButtonPropIcon( propId , groupNode )
	button.isNewStyle = true

	button.buttonStyle = ButtonStyleType.TypeABA

	local params = button:getLayoutParams()
	params.verticalLayout = kVerticalLayout.bottom
	params.iconFixWidth = -20
	button:setLayoutParams(params)

	return button
end

function EndGameBuyButton:recalcLayout(layoutType, elements, rects)
	local isNumEx = self:isDelNumberLabelNotEmpty() or self.numberLabel:getString() ~= "" 
	if isNumEx then
		local params = self:getLayoutParams()
		params.leftPosXFix = 10
		params.textMargin = 4

		params.elements = {}
		params.elements[1] = {}
		params.elements[1].marginLeft = 14
		params.elements[3] = {}
		params.elements[3].marginLeft = 4
		params.elements[3].fixWidth = -6
		self:setLayoutParams(params)
	end
	ButtonIconNumberBase.recalcLayout(self,layoutType, elements, rects)
end

function EndGameBuyButton:recalcLayout____(layoutType, elements, rects)
	local ButtonLayoutParams = {
		padding = {top = 0, right = 28, bottom = 0, left = 28},
		minWidth = 270,
		textMargin = 10, imageMargin = 8,
	}
	local ButtonElementConst = {
		fixedIconSize = {width = 58, height = 70},
		delLineHeight = 3, delLineWidth = 70,
	}

	local contentWidth = 0
	local eleCount = #layoutType
	local eleDataList = {}
	local eleSize = nil

	local preShowEleData = nil
	local iconCenterFixWidth = 30

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
				if self:isDelNumberLabelNotEmpty() or self.numberLabel:getString() ~= "" then
					eleData.marginLeft = 40
				end

			elseif eleData.eleType == 'B' then
				eleData.rect.width = spRect.width or ButtonElementConst.fixedIconSize.width
				eleData.rect.height = spRect.height or ButtonElementConst.fixedIconSize.height
				-- eleData.rect.x = (eleData.rect.width - contentSize.width*ele:getScaleX()) / 2
				-- eleData.rect.y = (eleData.rect.height - contentSize.height*ele:getScaleY()) / 2 - 1

				if self.buttonStyle == ButtonStyleType.TypeABA or self.buttonStyle == ButtonStyleType.TypeACA then
					eleData.rect.width = eleData.rect.width - iconCenterFixWidth
				end

			elseif eleData.eleType == 'C' then
				eleData.rect.width = spRect.width or eleData.contentSize.width
				eleData.rect.height = spRect.height or eleData.contentSize.height
				-- eleData.rect.x = 0
				-- eleData.rect.y = -1
				
				
				if self.buttonStyle == ButtonStyleType.TypeABA or self.buttonStyle == ButtonStyleType.TypeACA then
					eleData.rect.width = eleData.rect.width - iconCenterFixWidth
				end
			end

			if eleData.rect.width > 0 then
				if preShowEleData then
					if string.find("BC", preShowEleData.eleType) or string.find("BC", eleData.eleType) then
						eleData.marginLeft = ButtonLayoutParams.imageMargin
					else
						eleData.marginLeft = ButtonLayoutParams.textMargin
					end
				end
				preShowEleData = eleData
			end
			contentWidth = contentWidth + eleData.marginLeft + eleData.rect.width
		end

		eleDataList[i] = eleData
	end
	preShowEleData = nil

	local btnWidth = contentWidth + ButtonLayoutParams.padding.left + ButtonLayoutParams.padding.right
	self:resizeBackground(btnWidth)
	local leftPosX = -contentWidth / 2
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

			--底对齐
			if not baseY then
				baseY = eleData.contentSize.height / 2 + eleData.rect.y
				baseH = eleData.contentSize.height
			end
			eleData.ui:setPositionY(baseY-(baseH-eleData.contentSize.height))

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

function EndGameBuyButton:init(groupNode)
	ButtonIconNumberBase.buildUI(self)
	self.discount = groupNode:getChildByName("discount")
	if self.discount then
		self.dcNumber = self.discount:getChildByName("num")
		self.dcText = self.discount:getChildByName("text")
	end
end
-- function EndGameBuyButton:create(groupNode, propId)
-- 	local button = EndGameBuyButton.new(groupNode)
-- 	button:buildUI()
-- 	button.discount = groupNode:getChildByName("discount")
-- 	button.dcNumber = button.discount:getChildByName("num")
-- 	button.dcText = button.discount:getChildByName("text")

-- 	button:initOriNumber(groupNode)

-- 	buildButtonPropIcon( propId , groupNode )

-- 	return button
-- end

function EndGameBuyButton:initOriNumber(groupNode)
	-- self.oriNumber = groupNode:getChildByName("oriNumber")
	-- self.redLine = groupNode:getChildByName("redLine")
	-- if not self.oriNumber or not self.redLine then return end
	-- self.oriNumber:setVisible(false)
	-- self.redLine:setVisible(false)

	-- self.oriNumberLabel = self.oriNumber:getChildByName("number")
	-- local numberSize = self.oriNumber:getChildByName("numberSize")
	-- local size = numberSize:getContentSize()
	-- local position = numberSize:getPosition()
	-- local scaleX = numberSize:getScaleX()
	-- local scaleY = numberSize:getScaleY()
	-- self.oriNumberRect = {x=position.x, y=position.y, width=size.width*scaleX, height=size.height*scaleY}
	-- numberSize:removeFromParentAndCleanup(true)
end

function EndGameBuyButton:setOriNumber(str)
	self:setDelNumber(str )

	-- if not self.oriNumber or not self.redLine then return end
	-- self.oriNumber:setVisible(true)
	-- self.redLine:setVisible(true)
	-- local oriNumberLabel = self.oriNumberLabel
	-- if oriNumberLabel and oriNumberLabel.refCocosObj then
	-- 	if self.isStaticNumberLabel then oriNumberLabel:setString(str)
	-- 	else
	-- 		oriNumberLabel:setText(str)
	-- 		InterfaceBuilder:centerInterfaceInbox( oriNumberLabel, self.oriNumberRect )
	-- 	end
	-- end




end

function EndGameBuyButton:setOriNumberAlignment(alignment)
	-- if not self.oriNumber then return end
	-- self:setTextAlignment(self.oriNumberLabel, self.oriNumberRect, alignment, self.isStaticNumberLabel)
end

function EndGameBuyButton:setDiscount(number, text)
	if number <= 0 or number == 10 then
		self.dcNumber:setVisible(false)
		self.dcText:setVisible(false)
		self.discount:setVisible(false)
		self.dcNumber:setText(number)
	else
		self.dcNumber:setVisible(true)
		self.dcText:setVisible(true)
		self.dcNumber:setText(number)
		self.discount:setVisible(true)
		self.dcText:setText(text)
		self.dcNumber:setScale(2.5)
		self.dcText:setScale(1.7)

		--[[
		local scaleBase = self.discount:getScale()
		local actArray = CCArray:create()
		actArray:addObject(CCDelayTime:create(5))
		actArray:addObject(CCScaleTo:create(0.1, scaleBase * 0.95))
		actArray:addObject(CCScaleTo:create(0.1, scaleBase * 1.1))
		actArray:addObject(CCScaleTo:create(0.2, scaleBase * 1))
		self.discount:runAction(CCRepeatForever:create(CCSequence:create(actArray)))
		]]
	end
end

function EndGameBuyButton:getDiscount(number)
	return self.dcNumber:getString(), self.dcText:getString()
end
