local kHasFocusEvent = false
if __ANDROID then
	kHasFocusEvent = true
end

local DeviceType = {
	iPad = false,
	iPad3 = false,
	iPhone = false,
}
if __IOS then
	local deviceType = MetaInfo:getInstance():getMachineType() or ""
	for k,v in pairs(DeviceType) do
		DeviceType[k] = string.find(deviceType, k) ~= nil
	end
end


local Input = class(CocosObject)

function Input:validatePhone()
	if string.isEmpty(self:getText()) then
		return false
	end

	local codeMatch = string.find(self:getText(),"^[1][3-9][0-9]%d%d%d%d%d%d%d%d$")
	if not codeMatch or codeMatch~=1 then
		CommonTip:showTip("请输入正确的手机号码！", "negative",function() self.input:openKeyBoard() end,2)
		return false	
	end
	return true
end

function Input:isValidVerifyCode()
	if string.isEmpty(self:getText()) then
		return false
	end

	local code = self:getText()
	return code:match("^%d%d%d%d%d%d$")
end

function Input:isValidPhone()
	if string.isEmpty(self:getText()) then
		return false
	end

	local codeMatch = string.find(self:getText(),"^[1][3-9][0-9]%d%d%d%d%d%d%d%d$")
	if not codeMatch or codeMatch~=1 then
		return false	
	end
	
	return true
end

function Input:isValidEmail()
	if string.isEmpty(self:getText()) then
		return false
	end

	local email = self:getText()
	return email:match("[A-Za-z0-9%.%%%+%-]+@[A-Za-z0-9%.%%%+%-]+%.%w%w%w?%w?")
end

function Input:create(labelPlaceholder,panel, hideClearButton)
	local input = Input.new(CCNode:create())
	input:init(labelPlaceholder,panel, hideClearButton)
	return input
end

function Input:setClearButtonBG(style)
	if __ANDROID then
		self.input:setClearButtonBG(style)
	else
		--not supported yet!
	end
end

function Input:hideClearButton()
	if __ANDROID then
		self.input:hideClearButton()
	else
		--not supported yet!
	end
end

function Input:setEnabled(enabled)
	if __ANDROID then
		self.input:setEnabled(enabled)
	else
		--not supported yet!
	end
end

function Input:dispose( ... )
	CocosObject.dispose(self)

	if self.panel then
		self.panel:removeEventListener(PopoutEvents.kBecomeSecondPanel,self.becomeSecondPanel)
		self.panel:removeEventListener(PopoutEvents.kReBecomeTopPanel,self.reBecomeTopPanel)
	end
end

function Input:init( labelPlaceholder,panel, hideClearButton)

	local labelSize = labelPlaceholder:getDimensions()
	local labelPosX = labelPlaceholder:getPositionX()
	local labelPosY = labelPlaceholder:getPositionY()

	self:setAnchorPoint(ccp(0,1))
	self:setPositionX(labelPosX)
	self:setPositionY(labelPosY)
	self:setContentSize(labelSize)

	
	local inputSize = labelSize
	local inputBg = Scale9Sprite.new(CCScale9Sprite:create())
	if __ANDROID then
		self.input = require("hecore.ui.AndroidEditText"):create(inputSize,inputBg)
		if not hideClearButton then self.input:showClearButton() end
	else
		self.input = TextInput:create(inputSize,inputBg)
		self.input.refCocosObj:setZoomOnTouchDown(false)
		if not hideClearButton then self.input.refCocosObj:showClearButton() end
	end

	self:setFontColor(labelPlaceholder:getColor())
	
	local inputPosition = ccp(labelSize.width/2,labelSize.height/2)
	
	if __IOS then

		if DeviceType.iPhone then
			inputPosition.x = inputPosition.x - 12
		else
			inputPosition.x = inputPosition.x - 5
		end

		if DeviceType.iPad3 then
			inputPosition.y = inputPosition.y + 12
		elseif DeviceType.iPad then
			inputPosition.y = inputPosition.y + 6 + 7
		else
			inputPosition.y = inputPosition.y + 6
		end

		if DeviceType.iPad3 then
			self.input.refCocosObj:setClearButtonOffset(ccp(0,-10))
		end
	end

	self.input:setPosition(inputPosition)

	self.input.originalPosX = inputPosition.x
	self.input.originalPosY = inputPosition.y

	self.input:runAction(CCCallFunc:create(function( ... )
		self.input:setPosition(ccp(self.input.originalPosX,self.input.originalPosY))	
	end))
	self:addChild(self.input)

	for _,v in pairs({
		"setVisible",
		"openKeyBoard",
		"closeKeyBoard",
		-- "setText",
		-- "getText",
		-- "setFontColor",
		-- "setPlaceHolder",
		-- "setPlaceholderFontColor",
		"setMaxLength",
		-- "setInputMode",
		-- "setInputFlag",

		"hasEventListener",
		"hasEventListenerByName",
		"addEventListener",
		"removeEventListener",
		"removeEventListenerByName",
		"removeAllEventListeners",
		"dp", 
		"he", 
		"hn", 
		"ad", 
		"rm", 
		"rma",
	}) do
		self[v] = function ( ... )
			local params = { ... } 
			params[1] = self.input
			return self.input[v](unpack(params))
		end
	end

	if panel then
		self.panel = panel
		self.becomeSecondPanel = function( ... )
			self:onBecomeSecondPanel()
		end
		self.reBecomeTopPanel = function( ... )
			self:onReBecomeTopPanel()
		end
		panel:addEventListener(PopoutEvents.kBecomeSecondPanel,self.becomeSecondPanel)
		panel:addEventListener(PopoutEvents.kReBecomeTopPanel,self.reBecomeTopPanel)
	end

	if __ANDROID and kHasFocusEvent and panel then
		if not panel.__inputs then
			panel.__inputs = {}
		end
		table.insert(panel.__inputs,self)
		self.input:addEventListener(kTextInputEvents.kGotFocus,function( ... )
			if self.input:getKeyboardHeight() > 0 and #panel.__inputs == 1 then
				self:onGotFocus(panel,self.input:getKeyboardHeight())
			else
				self:runAction(CCSequence:createWithTwoActions(
					CCDelayTime:create(0.15),
					CCCallFunc:create(function( ... )
						self:onGotFocus(panel,self.input:getKeyboardHeight())
					end)
				))
			end
		end)
		self.input:addEventListener(kTextInputEvents.kLostFocus,function( ... )
			self:runAction(CCSequence:createWithTwoActions(
				CCDelayTime:create(0.15),
				CCCallFunc:create(function( ... )
					self:onLostFocus(panel)
				end)
			))
		end)
	end

	if __IOS and panel then
		if not panel.__inputs then
			panel.__inputs = {}
		end
		table.insert(panel.__inputs,self)
		self.input.refCocosObj:registerScriptImeHandler(function( eventName )
			if eventName == "keyboardWillShow" then
				self:onGotFocus(panel,self.input.refCocosObj:getKeyboardHeight())
			elseif eventName == "keyboardWillHide" then
				self:onLostFocus(panel)
			end
		end)
	end

	self.input:addEventListener(kTextInputEvents.kBegan,function( ... )
			self.inputBegan = true
	end)

	self.input:addEventListener(kTextInputEvents.kEnded,function( ... )
			self.inputBegan = false
	end)

	--default font colors
	self:setFontColor(ccc3(180,94,16))
	self:setPlaceholderFontColor(ccc3(241, 208, 165))
end

function Input:hide( ... )
	self.isHide = true

	self.input:setPositionX(-100000)

	if self.label then
		self.label:setVisible(false)
	end
end
function Input:show( ... )
	self.isHide = false
	-- self.input:setPositionX(self.input.originalPosX)

	self:runAction(CCCallFunc:create(function( ... )
		self.input:setPositionX(self.input.originalPosX)
	end))
	
	if self.label then
		self.label:setVisible(false)
	end
end

function Input:getText( ... )
	return self.input:getText() or ""
end

function Input:setText( text )
	self.input:setText(text)

	if self.placeHolderLabel then
		self.placeHolderLabel:setVisible(string.isEmpty(self:getText()))
	end
end
function Input:setFontColor( color )
	self.fontColor = color
	self.input:setFontColor(color)
end
function Input:getFontColor( ... )
	return self.fontColor or ccc3(0,0,0)
end
function Input:setPlaceHolder( text )
	self.placeHolderText = text

	if not self.placeHolderLabel then 
		local height = self:getContentSize().height
		local size = height - 12
		if __ANDROID then 
			size = height - 20 + 0.5			
		end

		if __IOS then
			size = (height + 10)/2 + 0.5
		end

		self.placeHolderLabel = TextField.new(CCLabelTTF:create("","",size))
		if __ANDROID then 
			self.placeHolderLabel:setAnchorPoint(ccp(0,0.5))
			self.placeHolderLabel:setPosition(ccp(0,self:getContentSize().height/2 + 3))
		elseif __IOS then
			self.placeHolderLabel:setAnchorPoint(ccp(0,0.5))
			self.placeHolderLabel:setPosition(ccp(0,self:getContentSize().height/2))

			if DeviceType.iPad3 then
				self.placeHolderLabel:setPosition(ccp(7,self:getContentSize().height/2))
			elseif DeviceType.iPad then
				self.placeHolderLabel:setPosition(ccp(7,self:getContentSize().height/2))
			end
			
		else
			self.placeHolderLabel:setAnchorPoint(ccp(0,0.5))
			self.placeHolderLabel:setPosition(ccp(0,self:getContentSize().height/2))
		end
		self:addChild(self.placeHolderLabel)

		self.input:addEventListener(kTextInputEvents.kChanged,function( ... )
			self.placeHolderLabel:setVisible(string.isEmpty(self:getText()))
		end)
	end
	self.placeHolderLabel:setColor(self:getPlaceholderFontColor())
	self.placeHolderLabel:setString(text)
	self.placeHolderLabel:setVisible(string.isEmpty(self:getText()))
end
function Input:getPlaceHolder( ... )
	return self.placeHolderText or ""
end
function Input:setPlaceholderFontColor( color )
	self.placeholderFontColor = color
	self.input:setPlaceholderFontColor(color)

	if self.placeHolderLabel then
		self.placeHolderLabel:setColor(color)
	end
end
function Input:setInputMode( inputMode )
	self.inputMode = inputMode
	self.input:setInputMode(inputMode)
end

function Input:getInputMode( ... )
	return self.inputMode or -1
end

function Input:setInputFlag( inputFlag )
	self.inputFlag = inputFlag
	self.input:setInputFlag(inputFlag)
end

function Input:getInputFlag( ... )
	return self.inputFlag or -1
end

function Input:getPlaceholderFontColor( ... )
	return self.placeholderFontColor or ccc3(166,166,166)
end

function Input:onBecomeSecondPanel( ... )

	if self.isHide then
		return
	end

	if _G.isLocalDevelopMode then printx(0, "onBecomeSecondPanel") end
	self:runAction(CCCallFunc:create(function ( ... )
		self.input:setPositionX(-100000)
	end))

	if not self.label then
		local height = self:getContentSize().height

		local size = height - 12
		if __ANDROID then 
			size = height - 20 + 0.5			
		end

		if __IOS then
			size = (height + 10)/2 + 0.5

			if DeviceType.iPad3 then
				size = size + 7
			elseif DeviceType.iPad then
				size = size + 7
			end
		end

		self.label = TextField.new(CCLabelTTF:create("","",size))
		self.label:setDimensions(self:getContentSize())
		if __ANDROID then 
			self.label:setAnchorPoint(ccp(0,0.5))
			self.label:setPosition(ccp(0,self:getContentSize().height/2 + 3))
		elseif __IOS then
			self.label:setAnchorPoint(ccp(0,0.5))
			self.label:setPosition(ccp(0,self:getContentSize().height/2))

			if DeviceType.iPad3 then
				self.label:setPosition(ccp(7,self:getContentSize().height/2))
			elseif DeviceType.iPad then
				self.label:setPosition(ccp(7,self:getContentSize().height/2))
			end
		else
			self.label:setAnchorPoint(ccp(0,0.5))
			self.label:setPosition(ccp(0,self:getContentSize().height/2))
		end
		self.label:setHorizontalAlignment(kCCTextAlignmentLeft)
		self.label:setVerticalAlignment(kCCVerticalTextAlignmentCenter)

		self.label:setVisible(false)
		self:addChild(self.label)
	end

	if not string.isEmpty(self:getText()) then
		if self:getInputFlag() == kEditBoxInputFlagPassword then
			self.label:setString(string.rep("●",#self:getText()))
		else
			self.label:setString(self:getText())
		end

		--[[setTimeOut( function(...) 
			if  not self.isDisposed then
				self.label:setColor(self:getFontColor())
				self.label:setVisible(true)
			end
		end, 1/30 )]]--

		self:runAction(CCCallFunc:create(function( ... )
			self.label:setColor(self:getFontColor())
			self.label:setVisible(true)
		end))
	end
end

function Input:onReBecomeTopPanel( ... )

	if self.isHide then
		return
	end
	if _G.isLocalDevelopMode then printx(0, "onReBecomeTopPanel") end
	self:runAction(CCCallFunc:create(function( ... )
		self.input:setPositionX(self.input.originalPosX)
	end))

	if self.label then
		self.label:setVisible(false)
	end

end

function Input:onGotFocus( panel,keyboardHeight )

	local visibleSize = Director.sharedDirector():getVisibleSize()
	local bounds = panel.ui:getChildByName("bg"):getGroupBounds()

	if not keyboardHeight or keyboardHeight <= 0 then
		keyboardHeight = visibleSize.height * 0.4
	end

	visibleSize.height = math.max(visibleSize.height - keyboardHeight,bounds.size.height)

	panel.__panelMovePos = ccp(
		visibleSize.width/2 - bounds.size.width/2,
		-visibleSize.height/2 + bounds.size.height/2
	)

	self:runAction(CCSequence:createWithTwoActions(
		CCDelayTime:create(0.05),
		CCCallFunc:create(function( ... )
			panel:setPosition(panel.__panelMovePos)

			for _,v in pairs(panel.__inputs) do
				v.input:setPosition(ccp(v.input:getPositionX(),v.input:getPositionY()))
			end
		end)
	))

end

function Input:onLostFocus( panel )

	local visibleSize = Director.sharedDirector():getVisibleSize()
	local bounds = panel.ui:getChildByName("bg"):getGroupBounds()

	panel.__panelMovePos = ccp(
		visibleSize.width/2 - bounds.size.width/2,
		-visibleSize.height/2 + bounds.size.height/2
	)

	self:runAction(CCSequence:createWithTwoActions(
		CCDelayTime:create(0.05),
		CCCallFunc:create(function( ... )
			panel:setPosition(panel.__panelMovePos)
			
			for _,v in pairs(panel.__inputs) do
				v.input:setPosition(ccp(v.input:getPositionX(),v.input:getPositionY()))
			end
		end)
	))

end

return Input