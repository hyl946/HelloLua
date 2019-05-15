require "zoo.scenes.component.HomeScene.iconButtons.IconButtonBase"

CDKeyButton = class(IconButtonBase)

function CDKeyButton:create()
	local newCDKeyButton = CDKeyButton.new()
    newCDKeyButton:initShowHideConfig(ManagedIconBtns.CDKEY)
	newCDKeyButton:init()
	return newCDKeyButton
end

function CDKeyButton:init()
    self.ui = ResourceManager:sharedInstance():buildGroup('home_scene_icon/btns/btn_i_exchange')

	IconButtonBase.init(self, self.ui)
end




