waxClass{"IosPaymentCallback", NSObject, protocols = {"GspPaymentDelegate"}}

function IosPaymentCallback:init_getFunc_completeFunc_errorFunc(getFunc, completeFunc, errorFunc)
	local paycb = self:init()
	paycb.getFunc = getFunc
	paycb.completeFunc = completeFunc
	paycb.errorFunc = errorFunc
	return paycb
end

function IosPaymentCallback:paymentComplete_errorInfo_userInfo(orderId, errorInfo, userInfo)
	if self.completeFunc then 
		self.completeFunc(orderId, errorInfo, userInfo)
	end
end

function IosPaymentCallback:paymentGetIapConfig(iapConfig)
	if self.getFunc then 
		self.getFunc(iapConfig);
	end
end

function IosPaymentCallback:paymentError(nsError)
	if self.errorFunc then 
		self.errorFunc(nsError)
	end
end