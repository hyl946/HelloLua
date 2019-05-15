if __IOS then 
	waxClass{"GameCenterManagerDelegateSDK", NSObject, protocols = {"GameCenterManagerDelegate"}}

	function processGameCenterAuth(self, err)
		local authenticateDone = 1
		if err ~= nil then authenticateDone = 0 end
		Localhost:saveGmeCenterEnable(authenticateDone)
		if _G.isLocalDevelopMode then printx(0, "GameCenterManagerDelegateSDK processGameCenterAuth", authenticateDone) end
		--GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(kGlobalEvents.kGamecenterLogin)) --disabled.
	end
end