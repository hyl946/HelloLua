function waxClass(param)
	local className = param[1]
	local protocols = param[3]
	local classT = {}
	classT.init = function()
		local cbHolder = CallbackHolder:create()
		for funcName, func in pairs(classT) do
			local wrapFunc = function(...)
				return classT[funcName](cbHolder, ...)
			end
			cbHolder:addFunc(funcName, wrapFunc)
		end
		return cbHolder
	end

	_G[className] = classT
	return classT
end

-- Bridges
AppController = AppControllerBridge
AnimalIosUtil = AnimalIosUtilBridge
ContactReader = ContactReaderBridge
FAQManager = FAQManagerBridge
IosAds = IosAdsBridge
LocationManager = LocationManagerBridge
LocationManager.getInstance = function( ... )
	return LocationManager
end
ReplayManager = ReplayManagerBridge
ReplayManager.getInstance = function()
	return ReplayManager
end
GspManager = GspManagerBridge
GameCenterManager = GameCenterManagerBridge
WeChatProxy = WeChatProxyBridge
TencentOpenApiManager = TencentOpenApiManagerBridge
SensorManager = SensorManagerBridge
QRCodeReader = QRCodeReaderBridge
OpenUrlHandleManager = OpenUrlHandleManagerBridge
PhotoController = PhotoControllerBridge
LHVideoPlayer = LHVideoPlayerBridge
UIAlertView = UIAlertViewBridge
UITextField = UITextFieldBridge

GspEnvironment = GspEnvironmentBridge
GspEnvironment.getInstance = function ( ... )
	return GspEnvironment
end
GspEnvironment.getCustomerSupportAgent = function()
	return GspEnvironment
end

NSProcessInfo = NSProcessInfoBridge
NSProcessInfo.processInfo = function ( ... )
	return NSProcessInfo
end

Reachability = ReachabilityBridge

TencentOpenApiManager = TencentOpenApiManagerBridge
TencentOpenApiManager.getInstance = function ( ... )
	return TencentOpenApiManager
end

WechatOpenApiManager = WechatOpenApiManagerBridge
WechatOpenApiManager.getInstance = function ( ... )
	return WechatOpenApiManager
end

ShowPayment = ShowPaymentBridge
ShowPayment.instance = function ( ... )
	return ShowPayment
end

UIApplication = UIApplicationBridge
UIApplication.sharedApplication = function ( ... )
	return UIApplication
end
NSURL = NSURLBridge

UIPasteboard = UIPasteboardBridge
SystemShareUtil = SystemShareUtilBridge
NSNumber = NSValueWrapperBridge
NSUserDefaults = NSUserDefaultsBridge
NSUserDefaults.standardUserDefaults = function ( ... )
	return NSUserDefaults
end
