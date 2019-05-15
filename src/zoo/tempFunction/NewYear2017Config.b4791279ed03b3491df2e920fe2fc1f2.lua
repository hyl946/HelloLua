local config = {
	topLevelId = 20,
}

local beginTime = {year=2016, month=12, day=30, hour=10, min=0, sec=0}
local endTime =   {year=2017, month=1, day=3, hour=23, min=59, sec=59}

function config.isActBegin()
	return Localhost:timeInSec() > os.time(beginTime)
end

function config.isActEnd()
	return Localhost:timeInSec() >= os.time(endTime)
end

function config.isShowMsgNum()
	return true
end

--189store、jinli_pre、lenovo_pre、coolpad_pre、zte_mini_pre、asus_pre、mitalk
function config.isUnSupportPkg()
	if _G.isPrePackage or __WP8 or
       PlatformConfig:isPlatform(PlatformNameEnum.k189Store) or
       PlatformConfig:isPlatform(PlatformNameEnum.kJinliPre) or
       PlatformConfig:isPlatform(PlatformNameEnum.kLenovoPre) or
       PlatformConfig:isPlatform(PlatformNameEnum.kCoolpadPre) or
       PlatformConfig:isPlatform(PlatformNameEnum.kZTEMINIPre) or
       PlatformConfig:isPlatform(PlatformNameEnum.kZTEPre) or
       PlatformConfig:isPlatform(PlatformNameEnum.kAsusPre) or
	   PlatformConfig:isPlatform(PlatformNameEnum.kJJ) or
       PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk) then
		return true
	end

	return false
end

function config.isVersionSupport()
	local ver = tonumber(string.split(_G.bundleVersion, ".")[2])
	return ver >= 40
end

function config.isUserLevelSupport()
	local userTopLevel = UserManager:getInstance():getUserRef():getTopLevelId() or 0
	if userTopLevel >= 20 then 
		return true 
	end

	return false
end

function config.isOpen()
	if __WIN32 then return true end

	return table.find(ActivityUtil:getActivitys() or {},function( v )
		return v.source == "NewYear2017/Config.lua"
	end)
end

return config