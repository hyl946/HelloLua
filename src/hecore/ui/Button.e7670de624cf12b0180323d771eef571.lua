require "hecore.display.Director"
require "hecore.display.TextField"

Button = class(EventDispatcher)

local function onButtonTouchBegin( evt )
	local button = evt.context
	if not button.enable then return end

	if button.useDefaultAnimation then
		local animationObject = button.getColorAnimationFunc(button)
		if  animationObject and animationObject.setColor then
			animationObject:setColor(button.colorOverlay)
		end
		if button.display and button.positionX ~= nil and button.positionY ~= nil then
			button.display:setPosition(ccp(button.positionX+1, button.positionY-1))		
		end
	end
	
	button:setButtonState(1)
end

local function onButtonTouchEnd( evt )
	local button = evt.context
	if not button.enable then return end

	if button.useDefaultAnimation then
		local animationObject = button.getColorAnimationFunc(button)
		if animationObject and animationObject.setColor then
			animationObject:setColor(ccc3(255,255,255))
		end
		if button.display and button.positionX ~= nil and button.positionY ~= nil then
			button.display:setPosition(ccp(button.positionX, button.positionY))
		end
	end
	
	button:setButtonState(0)
end

local function onButtonTouchTap( evt )
	local button = evt.context
	if not button.enable then return end
	if button and button:hasEventListenerByName(Events.kStart) then
		button:dispatchEvent(Event.new(Events.kStart, nil, button))
	end
end

local function getButtonColorAnimationObject( button )
	return button.display
end

function Button:ctor( display, useLayerFrame )
	self.display = display
	self.scaleX = 1
	self.scaleY = 1
	self.touchEnabled = false

	self.useDefaultAnimation = true
	self.useLayerFrame = useLayerFrame

	self.enable = true
	self.colorOverlay = ccc3(200,200,200)
	self.getColorAnimationFunc = getButtonColorAnimationObject
	if self.useLayerFrame and display and #display.list > 1 then
		self.normalBackground = display:getChildByName("normal")
		self.overBackground = display:getChildByName("over")
		self.disabledBackground = display:getChildByName("disabled")

		if not self.overBackground then self.overBackground = self.normalBackground end
		if not self.disabledBackground then self.disabledBackground = self.normalBackground end

		if not self.normalBackground then self.useLayerFrame = false end

		self:setButtonState(0)
	else
		self.useLayerFrame = false
	end
	
end
function Button:initButton()
	local  display = self.display
	if display then
		self.positionX = display:getPositionX()
		self.positionY = display:getPositionY()

		display:addEventListener(DisplayEvents.kTouchBegin, onButtonTouchBegin, self)
		display:addEventListener(DisplayEvents.kTouchEnd, onButtonTouchEnd, self)
		display:addEventListener(DisplayEvents.kTouchTap, onButtonTouchTap, self)
	else if _G.isLocalDevelopMode then printx(0, "no display assign to button") end end
end

function Button:setButtonState( state )
	if not self.useLayerFrame then return end

	state = state or 0
	self.normalBackground:setVisible(false)
	self.disabledBackground:setVisible(false)
	self.overBackground:setVisible(false)

	if state == 0 then
		self.normalBackground:setVisible(true)
	elseif state == 1 then
		self.overBackground:setVisible(true)
	else
		self.disabledBackground:setVisible(true)
	end
end

function Button:dispose()
	local  display = self.display
	if display then
		display:removeAllEventListeners()
		self.display = nil
	end
	self.getColorAnimationFunc = nil
	self.colorOverlay = nil
end

function Button:setEnable( v )
	self.enable = v
	if self.enable then self:setButtonState(0)
	else self:setButtonState(2) end
end

function Button:setVisible( v )
	local  display = self.display
	if display then display:setVisible(v) end
end

function Button:create(display, useLayerFrame)
	local button = Button.new(display, useLayerFrame)
	button:initButton()
	return button
end