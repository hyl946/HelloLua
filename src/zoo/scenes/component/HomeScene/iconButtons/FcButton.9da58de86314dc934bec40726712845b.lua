
FcButton = class(IconButtonBase)

function FcButton:init()
    self.ui = ResourceManager:sharedInstance():buildGroup('home_scene_icon/btns/btn_s_i_fc')
    -- Init Base
    IconButtonBase.init(self, self.ui)

    self.numTip = self:addRedDotNum()

    self:refresh()
end

function FcButton:create()
    local instance = FcButton.new()
    instance:init()
    return instance
end

function FcButton:refresh()
    local num = FAQ:readFaqReplayCount()
    if self.numTip and not self.numTip.isDisposed then self.numTip:setNum(num) end
    HomeScene:sharedInstance().settingButton:updateDotTipStatus()
end
