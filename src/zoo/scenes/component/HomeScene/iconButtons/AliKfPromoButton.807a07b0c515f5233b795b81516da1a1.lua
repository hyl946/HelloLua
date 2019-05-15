require "zoo.scenes.component.HomeScene.iconButtons.IconButtonBase"

AliKfPromoButton = class(IconButtonBase)

function AliKfPromoButton:ctor()
    self.idPre = "AliKfPromoButton"
    self.playTipPriority = 1010
end

function AliKfPromoButton:init()
    self.ui = ResourceManager:sharedInstance():buildGroup("ali_kf_promo_icon")
    IconButtonBase.init(self, self.ui)

    self.ui:setTouchEnabled(true)
    self.ui:setButtonMode(true)
    self:update()
    self:playOnlyIconAnim()
end

function AliKfPromoButton:update()

end

function AliKfPromoButton:create(...)
    local btn = AliKfPromoButton.new()
    btn:init()
    return btn
end
