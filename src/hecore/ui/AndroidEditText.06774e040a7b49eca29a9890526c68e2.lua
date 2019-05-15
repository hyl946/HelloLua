if not __ANDROID then
	return
end

local AnimalEditTextHelper = luajava.bindClass("com.happyelements.AndroidAnimal.AnimalEditTextHelper")

kTextInputEvents.kGotFocus = "gotFocus"
kTextInputEvents.kLostFocus = "lostFocus"


local EditBox = class(CocosObject)

function EditBox:create( size,normal9SpriteBg )
	local editBox = EditBox.new(CCLayer:create())
	editBox:init(size,normal9SpriteBg)
	return editBox
end

function EditBox:init( size,normal9SpriteBg )
	self.viewTag = AnimalEditTextHelper:createEditText()
	self.size = size
	self.text = ""

	self:ignoreAnchorPointForPosition(false)
	self:setContentSize(size)
	self:setAnchorPoint(ccp(0.5,0.5))
	
	normal9SpriteBg:setAnchorPoint(ccp(0,0))
	normal9SpriteBg:setPosition(ccp(0,0))
	normal9SpriteBg:setPreferredSize(size)
	self:addChild(normal9SpriteBg)

	-- self.label = TextField.new(CCLabelTTF:create("123","",12))
	-- self.label:setAnchorPoint(ccp(0,0.5))
	-- self.label:setPosition(ccp(0,size.height/2))
	-- self:addChild(self.label)
	-- kReturn 
	local function beforeTextChanged()
		if _G.isLocalDevelopMode then printx(0, "beforeTextChanged") end
		self:dispatchEvent(Event.new(kTextInputEvents.kBegan, nil, self))
	end
	local function onTextChanged( s )
		if _G.isLocalDevelopMode then printx(0, "onTextChanged") end
		self.text = s
		self:dispatchEvent(Event.new(kTextInputEvents.kChanged, nil, self))
	end
	local function afterTextChanged()
		if _G.isLocalDevelopMode then printx(0, "afterTextChanged") end
		self:dispatchEvent(Event.new(kTextInputEvents.kEnded, nil, self))
	end
	local function onFocusChange( hasFocus )
		if hasFocus then
			self:dispatchEvent(Event.new(kTextInputEvents.kGotFocus,nil,self))
		else
			self:dispatchEvent(Event.new(kTextInputEvents.kLostFocus,nil,self))			
		end
	end

	local textWatcher = luajava.createProxy("com.happyelements.AndroidAnimal.AnimalEditText$TextWatcher", {
		beforeTextChanged = beforeTextChanged,
		onTextChanged = onTextChanged,
		afterTextChanged = afterTextChanged,
		onFocusChange = onFocusChange,
	})
	AnimalEditTextHelper:registerScriptEditBoxHandler(self.viewTag,textWatcher)

	local function onTouch( eventType, x, y )
		if eventType == "began" then
			if not self:isTouhIn(ccp(x,y)) then
	 			self:closeKeyBoard()
			end
		end
		return false
	end
	self.refCocosObj:registerScriptTouchHandler(onTouch,false,-99999,false)
	self.refCocosObj:setTouchEnabled(true)

	self.originOffsetY = 0
	local posYAdjust = 0
	self.onSizeChanged = function(evt)
		local parentNode = self:getParent()
		if parentNode and not parentNode.isDisposed then
			local gPos = parentNode:convertToWorldSpace(self:getPosition())
			local posYAdjust = posYAdjust + (self.originOffsetY - _G.clickOffsetY)
			local adjustPos = parentNode:convertToNodeSpace(ccp(gPos.x, gPos.y + posYAdjust))
			self:setPositionY(adjustPos.y)
			self.originOffsetY = _G.clickOffsetY
		end
	end
	GlobalEventDispatcher:getInstance():ad(kGlobalEvents.kScreenOffsetChanged, self.onSizeChanged, self)
end

local lastKeyboardHeight = nil
function EditBox:getKeyboardHeight( ... )
	local keyboardHeight = AnimalEditTextHelper:getKeyboardHeight()

	if keyboardHeight <= 0 and lastKeyboardHeight then
		keyboardHeight = lastKeyboardHeight 
	end

	lastKeyboardHeight = keyboardHeight

	local scaleY = CCDirector:sharedDirector():getOpenGLView():getScaleY()
	
	return keyboardHeight / scaleY
end

function EditBox:isTouhIn( worldPoint )
	local x = worldPoint.x
	local y = worldPoint.y
	local leftBottom = self:convertToWorldSpace(ccp(0,0))
	local rightTop = self:convertToWorldSpace(ccp(self.size.width,self.size.height))

	return x > leftBottom.x and x < rightTop.x and y > leftBottom.y and y < rightTop.y
end

function EditBox:dispose( ... )
	CocosObject.dispose(self)
	self:closeKeyBoard()
	if self.onSizeChanged then
		GlobalEventDispatcher:getInstance():rm(kGlobalEvents.kScreenOffsetChanged, self.onSizeChanged)
		self.onSizeChanged = nil
	end
	AnimalEditTextHelper:removeEditText(self.viewTag)
end

function EditBox:setPositionX( x )
	self:setPosition(ccp(x,self:getPositionY()))
end

function EditBox:setPositionY( y )
	self:setPosition(ccp(self:getPositionX(),y))
end

function EditBox:setPosition( pos )
	
	CocosObject.setPosition(self,pos)

	local leftBottom = self:convertToWorldSpace(ccp(0,0))
	local rightTop = self:convertToWorldSpace(ccp(self.size.width,self.size.height))

	local winSize = CCDirector:sharedDirector():getWinSize()
	local frameSize = CCDirector:sharedDirector():getOpenGLView():getFrameSize()
	local scaleX = CCDirector:sharedDirector():getOpenGLView():getScaleX()
	local scaleY = CCDirector:sharedDirector():getOpenGLView():getScaleY()

	local uiLeft = frameSize.width/2 - (winSize.width/2 - leftBottom.x) * scaleX
	local uiTop = frameSize.height/2 + (winSize.height/2 - rightTop.y) * scaleY
	local uiWidth = (rightTop.x - leftBottom.x) * scaleX

	local uiHeight = (rightTop.y - leftBottom.y) * scaleY
	local textSize = (rightTop.y - leftBottom.y - 20) * scaleY

	AnimalEditTextHelper:setEditTextRect(self.viewTag,uiLeft,uiTop,uiWidth,uiHeight,textSize)
end

function EditBox:setVisible(v)

	CocosObject.setVisible(self,v)

	AnimalEditTextHelper:setVisible(self.viewTag,v)
end

function EditBox:openKeyBoard( ... )
	AnimalEditTextHelper:openKeyboard(self.viewTag)
end
function EditBox:closeKeyBoard( ... )
	AnimalEditTextHelper:closeKeyboard(self.viewTag)
end

function EditBox:setText( text )
	self.text = text
	AnimalEditTextHelper:setText(self.viewTag,text)
end
function EditBox:getText( ... )
	return self.text
end
function EditBox:setFontColor( color )
	AnimalEditTextHelper:setFontColor(self.viewTag,HeDisplayUtil:uintFromCCC3(color))
end
function EditBox:setPlaceHolder( text )
	AnimalEditTextHelper:setPlaceHolder(self.viewTag,text)
end
function EditBox:setPlaceholderFontColor( color )
	AnimalEditTextHelper:setPlaceholderFontColor(self.viewTag,HeDisplayUtil:uintFromCCC3(color))
end

function EditBox:setMaxLength( maxLength )
	self.maxLength = maxLength
	AnimalEditTextHelper:setMaxLength(self.viewTag,maxLength)
end

function EditBox:setInputMode( mode )
	self.inputMode = mode
	AnimalEditTextHelper:setInputMode(self.viewTag,mode)
end

function EditBox:setInputFlag( flag )
	self.inputFlag = flag
	AnimalEditTextHelper:setInputFlag(self.viewTag,flag)
end

function EditBox:showClearButton( ... )
	AnimalEditTextHelper:showClearButton(self.viewTag)
end

function EditBox:hideClearButton( ... )
	AnimalEditTextHelper:hideClearButton(self.viewTag)
end

function EditBox:setClearButtonBG(style)
	AnimalEditTextHelper:setClearButtonBG(self.viewTag, style)
end

function EditBox:setEnabled(enabled)
	AnimalEditTextHelper:setInputEnabled(self.viewTag, enabled)
end

return EditBox

