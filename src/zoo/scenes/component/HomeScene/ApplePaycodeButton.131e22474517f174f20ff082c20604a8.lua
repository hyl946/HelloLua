require "zoo.scenes.component.HomeScene.iconButtons.IconButtonBase"
require "zoo.panel.ApplePaycodePanel"

assert(not ApplePaycodeButton)


ApplePaycodeButton = class(IconButtonBase)

function ApplePaycodeButton:init(...)
	assert(#{...} == 0)

	self.ui = ResourceManager:sharedInstance():buildGroup('applepaycodebutton')

	IconButtonBase.init(self, self.ui)

	self.wrapper:setButtonMode(true)

	local timer = self.ui:getChildByName("timer")
	self:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCCallFunc:create(function()
			local hour, min, sec = ApplePaycodePanel:getCountDown()
			timer:setText(string.format("%02d:%02d:%02d", hour, min, sec))
			local size = timer:getContentSize()
			--timer:setScale(1.2)
			local sSize = self.wrapper:getGroupBounds(self.ui).size
			timer:setPositionX((sSize.width - size.width * timer:getScale()) / 2 - 2)
		end) , CCDelayTime:create(1))))
end

function ApplePaycodeButton:create(...)
	local instance = ApplePaycodeButton.new()
	assert(instance)
	if instance then instance:init() end
	return instance
end

function ApplePaycodeButton:getFlyToPosition()
	local pos = self:getPosition()
	return ccp(pos.x, pos.y)
end

function ApplePaycodeButton:getFlyToSize()
	local size = self:getGroupBounds().size
	size.width, size.height = size.width / 2, size.height / 2
	return size
end

function ApplePaycodeButton:playHighlightAnim()
	self:stopAllActions()
	self:runAction(CCSequence:createWithTwoActions(CCScaleTo:create(0.1, 1.5), CCScaleTo:create(0.4, 1)))
end