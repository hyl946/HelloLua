require "zoo.scenes.component.HomeScene.iconButtons.IconButtonBase"

local WXJPGameHubButton = class(IconButtonBase)

function WXJPGameHubButton:init()
	self.ui = ResourceManager:sharedInstance():buildGroup('wxjp_icons/wxjpHubButton')

	IconButtonBase.init(self, self.ui)

	self.ui:setTouchEnabled(true)
	self.ui:setButtonMode(true)
end


function WXJPGameHubButton:create()
	local instance = WXJPGameHubButton.new()
	instance:initShowHideConfig(ManagedIconBtns.WXJP_HUB)
	if instance then instance:init() end
	return instance
end

return WXJPGameHubButton
