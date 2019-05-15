require "zoo.scenes.component.HomeScene.iconButtons.IconButtonBase"

FishPromotionButton = class(IconButtonBase)

function FishPromotionButton:init(...)
    assert(#{...} == 0)

    self.ui = ResourceManager:sharedInstance():buildGroup('fish_button')

    IconButtonBase.init(self, self.ui)

    self.ui:setTouchEnabled(true)
    self.ui:setButtonMode(true)

end


function FishPromotionButton:create(...)
    local instance = FishPromotionButton.new()
    assert(instance)
    if instance then instance:init() end
    return instance
end
