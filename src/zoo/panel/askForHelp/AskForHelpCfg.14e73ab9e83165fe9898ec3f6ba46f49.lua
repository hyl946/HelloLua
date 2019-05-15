local AskForHelpCfg = class()

function AskForHelpCfg:ctor()
    self.minVersion = 47
    self.minPlayerLevel = 40
    self.maxDailyHelpOtherCount = 5
    self.maxUrlValidDays = 7
    self.headFrameThreshold = 10
    self.headFrameValidDays = 7
    self.failureThreshold = 3
    self.popoutThreshold = 6
    self.isEnabled = false

    local keyName = "AskForHelpFeature2"
	if MaintenanceManager:getInstance():isEnabled(keyName) then
		local maintenance = MaintenanceManager:getInstance():getMaintenanceByKey(keyName)
        self.allUserEnable = (maintenance.extra or "") == "1"
        self.isEnabled = true
	end

    local substitute_limit = MetaManager.getInstance().global.substitute_limit
    local count = 5
    if substitute_limit then
        local limit = substitute_limit:split(":")
        if limit and #limit > 1 then
            count = tonumber(limit[2])
        end
    end

    self.maxDailyFriendHelpCount = count or 5
end

function AskForHelpCfg:getMaxDailyHelpOtherCount()
    return self.maxDailyHelpOtherCount
end

function AskForHelpCfg:getMaxDailyFriendHelpCount()
    return self.maxDailyFriendHelpCount + Achievement:getRightsExtra( "FriendLevelCount" )
end

function AskForHelpCfg:shareDisabled()   -- JJ、mitalk不能微信求助
    if PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk) 
	or PlatformConfig:isPlatform(PlatformNameEnum.kMiPad)
    or __WIN32
    or PlatformConfig:isPlatform(PlatformNameEnum.kJJ) then
        return true
    end
    return false
end

return AskForHelpCfg