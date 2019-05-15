
local Button = class(EventDispatcher)

function Button:ctor( ... )
	self.colorMode = kGroupButtonColorMode.green 
end

function Button:create(buttonUi, labelString, onTapped, isStaticLabel) 
	local button = Button.new()
	button:init(buttonUi, labelString, onTapped, isStaticLabel)
	return button
end 

function Button:init( buttonUi , labelString, onTapped, isStaticLabel)
	self.ui = buttonUi

	self.text = self.ui:getChildByName("text")
	self.bg = self.ui:getChildByName("bg")
	self.isStaticLabel = isStaticLabel

	self.ui:addEventListener(DisplayEvents.kTouchTap, function( ... )
		self:dispatchEvent(Event.new(DisplayEvents.kTouchTap, nil, self))
		if onTapped then onTapped() end
	end)

	self.ui:addEventListener(Events.kDispose,function( ... )
		self:removeAllEventListeners()
	end)

	self.ui:setButtonMode(true)
	self:setTouchEnabled(true)
	-- self:setColorMode()

    if not self.isStaticLabel then
		local size = self.text:getDimensions()
		local position = self.text:getPosition()
		local scaleX = self.text:getScaleX()
		local scaleY = self.text:getScaleY()
		self.labelRect = {x=position.x, y=position.y, width=size.width*scaleX, height=size.height*scaleY}

		if _G.isLocalDevelopMode then printx(0, "size: ", size.width, size.height) end
		if _G.isLocalDevelopMode then printx(0, "scale: ", scaleX, scaleY) end
		if _G.isLocalDevelopMode then printx(0, "position: ", position.x, position.y) end

		self.bmpText = BitmapText:create("", "fnt/register.fnt", -1, kCCTextAlignmentCenter)
		self.bmpText:setPosition(ccp(position.x, position.y))
		self.bmpText:setAnchorPoint(ccp(0, 1))
		self.ui:addChild(self.bmpText)
	end
	
	self:setText(labelString)
end

function Button:setText( labelString )
	if self.isStaticLabel then
		self.text:setString(labelString)
	else
		self.bmpText:setText(labelString)
		InterfaceBuilder:centerInterfaceInbox( self.bmpText, self.labelRect )
	end
end

function Button:setVisible( visible )
	self.ui:setVisible(visible)
end

function Button:setTouchEnabled( enabled )
	self.ui:setTouchEnabled(enabled)
end

function Button:setEnabled(enabled)
	self.ui:setTouchEnabled(enabled)
	--todo: setColorMode to gray
	if not enabled then
		--self:setColorMode(kGroupButtonColorMode.grey)
		self.bg:adjustColor(kColorGreyConfig[1],kColorGreyConfig[2],kColorGreyConfig[3],kColorGreyConfig[4])
		self.bg:applyAdjustColorShader()
	else
		self.bg:clearAdjustColorShader()
		--self:setColorMode(self.colorMode)
	end
end

function Button:setColor( color )
	self.bg:adjustColor(color[1],color[2],color[3],color[4])
	self.bg:applyAdjustColorShader()
end

function Button:setColorMode( colorMode )
	if not colorMode then
		self.bg:clearAdjustColorShader()
		self.colorMode = colorMode
		return
	end

	if self.colorMode ~= colorMode then
		self.colorMode = colorMode
		local background = self.bg
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

return Button