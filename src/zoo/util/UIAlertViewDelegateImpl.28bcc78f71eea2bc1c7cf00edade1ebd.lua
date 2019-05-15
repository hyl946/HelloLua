if __IOS then 
	if not UIAlertViewDelegateImpl then
		waxClass{"UIAlertViewDelegateImpl", NSObject, protocols = {"UIAlertViewDelegate"}}
		function UIAlertViewDelegateImpl:alertView_clickedButtonAtIndex (alertView, buttonIndex) 
			if not LUA_WAX_ENABLE then
				if self.callback ~= nil then self.callback(self.alertView, buttonIndex) end
				if self.alertView then
		          	self.alertView:release()
		          	self.alertView = nil
	          	end
          	else	
				if self.callback ~= nil then self.callback(alertView, buttonIndex) end
				self.alertView = nil
				self.callback = nil
	        end
		end
	end

	local UIAlertViewStatic = {}
	function UIAlertViewStatic:buildUI( title, message, cancelButtonTitle, callback )
		local delegate = UIAlertViewDelegateImpl:init()
		local alert = UIAlertView:initWithTitle_message_delegate_cancelButtonTitle_otherButtonTitles(title, message, delegate, cancelButtonTitle, nil)
		delegate.alertView = alert
		delegate.callback = callback
		return alert
	end
	return UIAlertViewStatic
end
return nil
