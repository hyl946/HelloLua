
require "zoo.util.ReachabilityUtil"

NetworkUtil = {}

NetworkUtil.NetworkStatus = {
	kNoNetwork = 'kNoNetwork',
	kMobileNetwork = 'kMobileNetwork',
	kWifi = 'kWifi',
}

NetworkUtil.Events = {
	kNetworkStatusChange = 'NetworkUtil.Events.kNetworkStatusChange'
}

function NetworkUtil:isEnableWIFI( ... )

	if __ANDROID then

		local MainActivityHolder = luajava.bindClass('com.happyelements.android.MainActivityHolder')
		local Context = luajava.bindClass("android.content.Context")
		local ConnectivityManager = luajava.bindClass("android.net.ConnectivityManager")

		local connectMgr = MainActivityHolder.ACTIVITY:getContext():getSystemService(Context.CONNECTIVITY_SERVICE)

		local networkInfo = connectMgr:getActiveNetworkInfo()
		if networkInfo == nil then 
			return false
		end

		return networkInfo:getType() == ConnectivityManager.TYPE_WIFI
	end

	if __IOS then

		return ReachabilityUtil.getInstance():isEnableWIFI()
	end

	if __WIN32 then

		return false
	end

	return false
end

function NetworkUtil:getNetworkInfo()
	-- 参考 MetaInfo.cpp中networktype的获取方法，android（-1,0,2），iOS（-1,0,1）
	if __ANDROID then
		local metaInfo = luajava.bindClass("com.happyelements.android.MetaInfo")
		local status = -1
		if metaInfo then
			status = metaInfo:getNetworkInfo()
		end
		if status ~= 0 and status ~= -1 then
			return 2
		else
			return status
		end
	elseif __IOS then
		local reachability = Reachability:reachabilityForInternetConnection()
		local status = reachability:currentReachabilityStatus()
		if status == 0 then
			return -1
		elseif status == 1 then
			return 1
		elseif status == 2 then
			return 0
		end
	elseif __WIN32 then
		return 0
	end
	return -1
end

function NetworkUtil:isConnected( ... )
	return ReachabilityUtil:isNetworkAvailable()
end

function NetworkUtil:isMobileNetwork( ... )
	return self:isConnected() and (not self:isEnableWIFI())
end

function NetworkUtil:getNetworkStatus( ... )
	local isForceMobile = MaintenanceManager:getInstance():isEnabledInGroup('isForceMobileTest', 'test', UserManager:getInstance().uid)
	if isForceMobile then
		do return NetworkUtil.NetworkStatus.kMobileNetwork end
	end
	
	if self:isEnableWIFI() then
		return NetworkUtil.NetworkStatus.kWifi
	elseif self:isMobileNetwork() then
		return NetworkUtil.NetworkStatus.kMobileNetwork
	else
		return NetworkUtil.NetworkStatus.kNoNetwork
	end
end


function NetworkUtil:registerNetworkChangeBroadcastReceiver( ... )

	if __ANDROID then


		if self.isReceiverRegistered then
			return
		end
		-- body
		pcall(function ( ... )
			local NSReceiver = luajava.bindClass("com.happyelements.android.receiver.NetworkStatusChangeBroadcastReceiver")
			NSReceiver:setCallback(luajava.createProxy("com.happyelements.android.InvokeCallback", {
		        onSuccess = function (result)
		        	self:onNetworkStatusChange()
		        end,
		        onError = function(errCode, errMsg) end,
		        onCancel = function() end
		    }))
			NSReceiver:register()

			self.isReceiverRegistered = true
		end)

	elseif __IOS then
		--todo
	end
	
end

function NetworkUtil:unregisterNetworkChangeBroadcastReceiver( ... )

	if __ANDROID then

		if not self.isReceiverRegistered then
			return
		end
		-- body
		pcall(function ( ... )
			local NSReceiver = luajava.bindClass("com.happyelements.android.receiver.NetworkStatusChangeBroadcastReceiver")
			NSReceiver:unregister()
			self.isReceiverRegistered = false
		end)

	elseif __IOS then
		--todo

	end
end

function NetworkUtil:onNetworkStatusChange( ... )
	local nowNetworkStatus = self:getNetworkStatus()
	if self.lastNetworkStatus ~= nowNetworkStatus then
		self.lastNetworkStatus = nowNetworkStatus
		GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(NetworkUtil.Events.kNetworkStatusChange))
	end
end