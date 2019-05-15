
local Processor = class(EventDispatcher)

Processor.events = {
    kLocalOldUser = "localOldUser",
    kLocalNewUser = "localNewUser"
}

function Processor:start()
    local function isLocalOldUser()
        local localUserConfig = Localhost.getInstance():getLastLoginUserConfig()
        if localUserConfig and localUserConfig.uid ~= 0 and localUserConfig.uid ~= localUserConfig.sk then 
            return true
        end
        return false 
    end

    if isLocalOldUser() then 
        if _G.isLocalDevelopMode then printx(0, "Local old user") end
        self:dp(Event.new(self.events.kLocalOldUser, nil, self))
    else 
        if _G.isLocalDevelopMode then printx(0, "Local new user") end
        self:dp(Event.new(self.events.kLocalNewUser, nil, self))
    end
end

return Processor