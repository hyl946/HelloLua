local StoreSwitch = class()

local cachedEnabled = nil

function StoreSwitch:isEnabled( ... )

	-- 苹果提审期间，只显示旧商店
	local appleVerification = (__IOS and MaintenanceManager:getInstance():isEnabled('AppleVerification'))
	if appleVerification then
		return false
	end



	if cachedEnabled == nil then
		local uid = UserManager:getInstance():getUID() or "12345"
		local ret = MaintenanceManager:getInstance():isEnabledInGroup('NewCoinStore', 'ON1', uid)
		cachedEnabled = ret
	end

	return cachedEnabled or __WIN32
end

return StoreSwitch