local Button = require "zoo.panel.phone.Button"

PhoneConfirmPanel = class(BasePanel)

kColorBlueConfig2 = {0.5546,0.1072,0.0531,0.3406}

function PhoneConfirmPanel:create(content)
	local panel = PhoneConfirmPanel.new()
	panel:loadRequiredResource("ui/login.json")
	panel:init(content)

	return panel
end

function PhoneConfirmPanel:ctor()
end

function PhoneConfirmPanel:init(content)
	self.ui	= self:buildInterfaceGroup("PhoneConfirmPanel")

	BasePanel.init(self, self.ui)

	self.ui:getChildByName("content"):setString(content)

	self.leftButton = Button:create(self:findChild("leftButton"))
	self.leftButton:setColor(kColorBlueConfig2)
	self.leftButton:addEventListener(DisplayEvents.kTouchTap,function( ... )
		self:remove()
		if self.leftButtonCallback then
			self.leftButtonCallback()
		end
	end)

	self.rightButton = Button:create(self:findChild("rightButton"))
	self.rightButton:setColorMode(kGroupButtonColorMode.green)
	self.rightButton:addEventListener(DisplayEvents.kTouchTap,function( ... )
		self:remove()
		if self.rightButtonCallback then
			self.rightButtonCallback()
		end
	end)
end

function PhoneConfirmPanel:remove( ... )
	PopoutManager:sharedInstance():remove(self, true)
end

function PhoneConfirmPanel:popout()
	PopoutManager:sharedInstance():add(self, true, false)
	self:setToScreenCenter()
end


function PhoneConfirmPanel:setLeftButtonText( leftButtonText )
	self.leftButton:setText(leftButtonText)
end
function PhoneConfirmPanel:setRightButtonText( rightButtonText )
	self.rightButton:setText(rightButtonText)
end
function PhoneConfirmPanel:setLeftButtonCallback( leftButtonCallback )
	self.leftButtonCallback = leftButtonCallback
end
function PhoneConfirmPanel:setRightButtonCallback( rightButtonCallback )
	self.rightButtonCallback = rightButtonCallback
end