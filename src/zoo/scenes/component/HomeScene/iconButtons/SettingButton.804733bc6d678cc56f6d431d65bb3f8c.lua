local DisplayQualityManager = require "zoo.panel.customDisplayQuality.DisplayQualityManager"

SettingButton = class(IconButtonBase)

function SettingButton:init(...)
    self.ui = ResourceManager:sharedInstance():buildGroup('home_scene_icon/btns/btn_s_i_set')
    self.reddot = self:addRedDot()

    -- Init Base
    IconButtonBase.init(self, self.ui)

    if(DisplayQualityManager:showRedDot()) then
        self.reddot:setVisible(true)
    else
        self.reddot:setVisible(false)
    end
end

function SettingButton:create()
    local instance = SettingButton.new()
    instance:init()
    return instance
end
