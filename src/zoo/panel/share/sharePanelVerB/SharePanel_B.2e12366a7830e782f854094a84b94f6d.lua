require "zoo.panel.share.sharePanelVerB.ArmatureShareBasePanel_B"
require "zoo.panel.share.sharePanelVerB.SharePanelConfig_B"

SharePanel_B = class(ArmatureShareBasePanel_B)

function SharePanel_B:ctor(...)
end

function SharePanel_B:create(shareId)
    printx(0,"施工中，面板可能有问题") --todo
    assert(type(shareId) == "number")
    local config = SharePanelConfig_B[shareId]
    if not config then
        printx(0,"No config in SharePanel_B!! Panel failed to create!")
        assert(config)
        return nil
    end

    local panel = SharePanel_B.new()
    --panel:loadRequiredResource("ui/NewSharePanelEx.json")
    panel.shareId = shareId
    panel.config = config
    panel:init(shareId, config.armatureName, config.specifyFunc, config.specifyFuncParams)
    return panel
end

function SharePanel_B:init(shareId, armatureName, specifyFunc, specifyFuncParams)
    assert(type(shareId) == "number")
    assert(type(armatureName) == "string")

    ArmatureShareBasePanel_B.init(
        self,
        "skeleton/share_animations_B/share_" .. tostring(shareId) .. "_animation",
        "share_" .. tostring(shareId) .. "_animation",
        "share_" .. tostring(shareId) .. "_animation",
        armatureName
    )
    if specifyFunc then
        specifyFunc(self, specifyFuncParams)
    end
end