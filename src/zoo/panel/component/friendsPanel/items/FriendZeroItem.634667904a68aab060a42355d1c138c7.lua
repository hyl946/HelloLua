
RequestMessageZeroItem = class(Layer)
RequestMessageZeroFriend = class(RequestMessageZeroItem)

function RequestMessageZeroItem:create(width, height)
    local ret = self.new()
    ret:initLayer()
    ret:init(width, height)
    return ret
end

function RequestMessageZeroItem:init(width, height)
    local builder = InterfaceBuilder:create(PanelConfigFiles.friends_panel)
    local text = TextField:create("", nil, 36, CCSizeMake(600,400))
    text:setColor(ccc3(144, 89, 2))
    text:setAnchorPoint(ccp(0, 1))
    self.text = text
    self:addChild(text)
end

function RequestMessageZeroItem:showBottomCloseButton()
    return true
end

------------------------------------------------------------------------
function RequestMessageZeroFriend:create(width, height)
    local ret = RequestMessageZeroFriend.new()
    ret:initLayer()
    ret:init(width, height)
    return ret
end

function RequestMessageZeroFriend:init(width, height)
    local builder = InterfaceBuilder:create(PanelConfigFiles.friends_panel)
    local ui = builder:buildGroup("interface/request_message_panel_zero_friend")
    self:addChild(ui)
    
    local bg = ui:getChildByName("bg")


    local size = {width = bg:getContentSize().width*bg:getScaleX(), height = bg:getContentSize().height*bg:getScaleY()}
    local scale = width / (size.width + 40)
    if scale > height / (size.height + 40) then scale = height / (size.height + 40) end
    if scale < 1 then self:setScale(scale)
    else 
        scale = 1 
    end
    self:setPositionX((width - size.width * scale) / 2)
    self:setPositionY(-(height - size.height * scale) / 2)
end

function RequestMessageZeroFriend:setVisible(visible)
    RequestMessageZeroItem.setVisible(self, visible)

end
