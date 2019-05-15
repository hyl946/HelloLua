local Icon = class(ActivityIconButton)
local actIcon

function Icon:create( source, version ,configPath)
    if _G.isLocalDevelopMode then printx(100, "Icon 11111111 "  ) end
    actIcon = Icon.new()
    if _G.isLocalDevelopMode then printx(100, "Icon 22222222 source = ",source ,version ) end
    actIcon:init( source, version ,configPath )
    if _G.isLocalDevelopMode then printx(100, "Icon 33333333 "  ) end
    return actIcon
end

function Icon:getTheIcon( ... )
    return actIcon
end

function Icon:buildIcon( ... )
    local config = require("zoo/localActivity/UserCallBackTest/Config.lua")
    local image = Sprite:create(config.icon.resource[1])
    local ver = tonumber(string.split(_G.bundleVersion, ".")[2])
    if ver < 47 then
        image:setAnchorPoint(ccp(0.5,0))
    else 
        image:setAnchorPoint(ccp(0.5,0.5))
    end
    return image
end

function Icon:init(source,version,configPath)
    ActivityIconButton.init(self, source, version,configPath)
    self:buildText()
end

function Icon:buildText()
    local config = require("zoo/localActivity/UserCallBackTest/Config.lua")
    local text = Sprite:create(config.icon.resource[2])
    text:setAnchorPoint(ccp(0.5,0.5))
    self.ui:addChild(text)
    text:setPositionX(47)
    text:setPositionY(-81)
end

-- 包里面通关这个去获取icon的大小，有tip的时候会有问题，这么处理下
function Icon:getGroupBounds( ... )
    if self.icon then
        return self.icon:getGroupBounds()
    else
        return self:getGroupBounds()
    end
end

return Icon