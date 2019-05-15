-------------------------------------------------------------------------
--  Class include: ReachabilityUtil
-------------------------------------------------------------------------

require "hecore.class"

local instance = nil
ReachabilityUtil = {reachability=nil}

function ReachabilityUtil.getInstance()
	if not instance then
		instance = ReachabilityUtil
	end
	return instance;
end

function ReachabilityUtil:available()
	if __IOS then return true 
	else return false end
end

function ReachabilityUtil:isNetworkAvailable()
	if NetworkConfig.noNetworkMode then return false end

	if __IOS then
		local reachability = Reachability:reachabilityForInternetConnection()
		local status = reachability:currentReachabilityStatus()
		if _G.isLocalDevelopMode then printx(0, "currentReachabilityStatus", status) end
		return status ~= 0
	elseif __ANDROID then -- since 1.39
		local NetworkUtils = luajava.bindClass("com.happyelements.gsp.android.utils.NetworkUtils")
		local MainActivityHolder = luajava.bindClass('com.happyelements.android.MainActivityHolder')
   		local context = MainActivityHolder.ACTIVITY:getContext()
   		return NetworkUtils:isConnect(context)
	end
	
	return true
end

function ReachabilityUtil:isEnableWIFI()
	local isForceMobile = MaintenanceManager and MaintenanceManager:getInstance():isEnabled('isForceMobileTest')
	if isForceMobile then
		return false
	end
	
	return Reachability:reachabilityForLocalWiFi():currentReachabilityStatus() ~= 0
end

function ReachabilityUtil:isEnable3G()
	return Reachability:reachabilityForInternetConnection():currentReachabilityStatus() ~= 0
end

local androidReachability = nil
function ReachabilityUtil:isNetworkReachable()
	if __IOS then
		local reachability = Reachability:reachabilityWithHostName("www.apple.com")
		local status = reachability:currentReachabilityStatus()
		if _G.isLocalDevelopMode then RemoteDebug:uploadLogWithTag("isNetworkReachable", "currentReachabilityStatus:" .. tostring(status == 1 or status == 2)) end
		return status == 1 or status == 2
	else
		-- if not androidReachability then
		-- 	androidReachability = luajava.bindClass("com.happyelements.android.utils.ReachabilityUtil")
		-- end
		-- if androidReachability then
		-- 	return androidReachability:reachabilityWithHostName("www.baidu.com")
		-- end
		return true
	end
end




