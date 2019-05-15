
ForumButton = class(IconButtonBase)

function ForumButton:init(...)
    self.ui = ResourceManager:sharedInstance():buildGroup('home_scene_icon/btns/btn_s_i_forum')

    -- Init Base
    IconButtonBase.init(self, self.ui)
end

function ForumButton:create()
    local instance = ForumButton.new()
    instance:init()
    return instance
end

QQForumButton = class(IconButtonBase)

function QQForumButton:init(...)
    self.ui = ResourceManager:sharedInstance():buildGroup('home_scene_icon/btns/btn_s_i_forum')
    -- Init Base
    IconButtonBase.init(self, self.ui)
end

function QQForumButton:create()
    local instance = QQForumButton.new()
    instance:init()
    instance:initShowHideConfig(ManagedIconBtns.QQ_FORUM)
    return instance
end

OppoForumButton = class(IconButtonBase)

function OppoForumButton:init()
    self.ui = ResourceManager:sharedInstance():buildGroup('home_scene_icon/btns/btn_i_oppo_community')

    IconButtonBase.init(self, self.ui)
    self.redDot = self:addRedDot()

    self.redDot:setVisible(false)
end

function OppoForumButton:create()
    local instance = OppoForumButton.new()
    instance:init()
    instance:initShowHideConfig(ManagedIconBtns.OPPO_FORUM)
    return instance
end