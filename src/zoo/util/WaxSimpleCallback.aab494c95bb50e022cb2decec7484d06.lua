WaxSimpleCallback = {}

function WaxSimpleCallback:createSimpleCallbackDelegate(onSuccess, onFailed, onCancel)
	waxClass{"CommonWaxSimpleCallback",NSObject,protocols={"SimpleCallbackDelegate"}}

	function CommonWaxSimpleCallback:onSuccess(result)
		if self.onSuccessCallback then 
			self.onSuccessCallback(result)
		end
	end

	function CommonWaxSimpleCallback:onFailed(result)
		if self.onFailedCallback then 
			self.onFailedCallback(result)
		end
	end

	function CommonWaxSimpleCallback:onCancel()
		if self.onCancelCallback then 
			self.onCancelCallback()
		end
	end

	local iosCallback = CommonWaxSimpleCallback:init()
	iosCallback.onSuccessCallback = onSuccess
	iosCallback.onFailedCallback = onFailed
	iosCallback.onCancelCallback = onCancel
	return iosCallback
end

return WaxSimpleCallback