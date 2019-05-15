local _Util = {}

function _Util:scaleArmature(panel, scaleX, scaleY)
    panel.armatureNode:setScaleX(scaleX * panel.ui:getScaleX())
    panel.armatureNode:setScaleY(scaleY * panel.ui:getScaleY())
end

function _Util:moveArmature(panel, offsetX, offsetY)
    local position = panel.ui:getPosition()
    panel.armatureNode:setPositionXY(position.x + offsetX, position.y + offsetY)
end

function _Util:hideSlot(armature, slotName)
    local slot = armature:getSlot(slotName)
    if slot then
        local sprite = Sprite:createEmpty()
        slot:setDisplayImage(sprite.refCocosObj)
    end
end

SharePanelConfig_B = {
    [30] = {
        armatureName = "2019_share_30/share_30_animation",
        specifyFunc = function(panel)
            _Util:scaleArmature(panel, 1.15, 1.15)
            _Util:moveArmature(panel, 20, -60)
        end,
        specifyFuncParams = {},
    },
    [150] = {
        armatureName = "2019_share_150/share_150_animation",
        specifyFunc = function(panel)
            _Util:scaleArmature(panel, 1.15, 1.15)
            _Util:moveArmature(panel, 15, -60)
            -- _Util:hideSlot(panel.armatureNode, "closeBtn")
        end,
        specifyFuncParams = {},
    },
    [160] = {
        armatureName = "2019_share_160/share_160_animation",
        specifyFunc = function(panel)
            _Util:scaleArmature(panel, 1.15, 1.15)
            _Util:moveArmature(panel, -27, -60)
        end,
        specifyFuncParams = {},
    },
    [180] = {
        armatureName = "2019_share_180/share_180_animation",
        specifyFunc = function(panel)
            _Util:scaleArmature(panel, 1.15, 1.15)
            _Util:moveArmature(panel, -27, -60)
        end,
        specifyFuncParams = {},
    },
}