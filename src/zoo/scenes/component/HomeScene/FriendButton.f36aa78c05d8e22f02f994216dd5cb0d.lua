require "zoo.scenes.component.HomeScene.iconButtons.IconButtonBase"

assert(not FriendButton)


FriendButton = class(IconButtonBase)

function FriendButton:init()
    self.ui = ResourceManager:sharedInstance():buildGroup('home_scene_icon/btns/btn_i_friend')
	IconButtonBase.init(self, self.ui)
    self.redDot = self:addRedDot()
    self:update()
end

function FriendButton:create()
	local instance = FriendButton.new()
    instance:initShowHideConfig(ManagedIconBtns.FRIENDS)
    instance:init() 

	return instance
end

function FriendButton:update()
    if FAQ:isPersonalCenterEnabled() then
        self.redDot:setVisible(UserManager:getInstance():isNewCommunityMessageVersion())
    else
        self.redDot:setVisible(false)
    end
end