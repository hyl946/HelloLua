require "zoo.scenes.component.HomeScene.iconButtons.IconButtonBase"
OppoLaunchButton = class(IconButtonBase)

function OppoLaunchButton:init()
	if OppoLaunchManager:isVivo() then
		self.ui = ResourceManager:sharedInstance():buildGroup('home_scene_icon/btns/btn_i_vivo')
	elseif OppoLaunchManager:isMi() then
		self.ui = ResourceManager:sharedInstance():buildGroup('home_scene_icon/btns/btn_i_mi')
	else
		self.ui = ResourceManager:sharedInstance():buildGroup('home_scene_icon/btns/btn_i_oppo')
	end

	IconButtonBase.init(self, self.ui)
	self.redDot = self:addRedDot()
	self:upadteRedDotShow()
end

function OppoLaunchButton:upadteRedDotShow()
	if OppoLaunchManager.getInstance():shouldShowRedDot() then
        self.redDot:setVisible(true)
    else
        self.redDot:setVisible(false)
    end
end

function OppoLaunchButton:create()
	local instance = OppoLaunchButton.new()
	instance:initShowHideConfig(ManagedIconBtns.OPPO_LAUNCH)
	if instance then instance:init() end
	return instance
end