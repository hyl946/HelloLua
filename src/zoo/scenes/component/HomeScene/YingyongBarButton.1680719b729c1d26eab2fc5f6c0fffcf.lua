require "zoo.scenes.component.HomeScene.iconButtons.IconButtonBase"

YingyongBarButton = class(IconButtonBase)

function YingyongBarButton:init(...)
	assert(#{...} == 0)

	self.ui = ResourceManager:sharedInstance():buildGroup('yingyongbarBtn')

	IconButtonBase.init(self, self.ui)

	self.ui:setTouchEnabled(true)
	self.ui:setButtonMode(true)
end


function YingyongBarButton:create(...)
	local instance = YingyongBarButton.new()
	assert(instance)
	if instance then instance:init() end
	return instance
end