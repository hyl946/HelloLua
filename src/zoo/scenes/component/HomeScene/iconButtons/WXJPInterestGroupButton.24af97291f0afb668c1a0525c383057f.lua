require "zoo.scenes.component.HomeScene.iconButtons.IconButtonBase"

local WXJPInterestGroupButton = class(IconButtonBase)

function WXJPInterestGroupButton:init()
	self.ui = ResourceManager:sharedInstance():buildGroup('wxjp_icons/wxjpGroupButton')

	IconButtonBase.init(self, self.ui)

	self.ui:setTouchEnabled(true)
	self.ui:setButtonMode(true)
end


function WXJPInterestGroupButton:create()
	local instance = WXJPInterestGroupButton.new()
	instance:initShowHideConfig(ManagedIconBtns.WXJP_GROUP)
	if instance then instance:init() end
	return instance
end

return WXJPInterestGroupButton
