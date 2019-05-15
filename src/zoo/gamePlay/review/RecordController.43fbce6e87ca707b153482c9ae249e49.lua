local RecordController = class()

local instance

RecordController.STATE = {
	kStoped = 1,
	kRequestingStart = 2,
	kStarted = 3,
	kRequestingStop = 4,
}

function RecordController:getInstance( ... )
	-- body
	if not instance then
		instance = RecordController.new()
		instance:reset()
	end
	return instance
end

function RecordController:reset( ... )
	self.startCallback = {}
	self.stopCallback = {}
	self.state = RecordController.STATE.kStoped
end

function RecordController:setStartRecordCallback( onSuccess, onFail )
	self.startCallback = {
		onSuccess = onSuccess,
		onFail = onFail,
	}
end

function RecordController:setStopRecordCallback( onSuccess, onFail )
	self.stopCallback = {
		onSuccess = onSuccess,
		onFail = onFail,
	}
end

function RecordController:afterStartSuccess( ... )
	if self.state ~= RecordController.STATE.kStarted then
		self.state = RecordController.STATE.kStarted
		if self.startCallback.onSuccess then
			self.startCallback.onSuccess()
		end
	end
	self:removeLoadingAnim()
	if self.timeOutTimer then
		cancelTimeOut(self.timeOutTimer)
		self.timeOutTimer = nil
	end
end

function RecordController:removeLoadingAnim( ... )
	if self.loadingAnimation then
		self.loadingAnimation:removeFromParentAndCleanup(true)
		self.loadingAnimation = nil
	end
end

function RecordController:showLoadingAnim( ... )
	if self.loadingAnimation then
		return
	end
	self.loadingAnimation = CountDownAnimation:createNetworkAnimation(
		Director:sharedDirector():getRunningScene(), 
		nil,
		localize("")
	)
end

function RecordController:afterStartFail( err, errMsg )
	if self.state ~= RecordController.STATE.kStoped then
		self.state = RecordController.STATE.kStoped
		if self.startCallback.onFail then
			self.startCallback.onFail(err, errMsg)
		end
	end
	self:removeLoadingAnim()
	if self.timeOutTimer then
		cancelTimeOut(self.timeOutTimer)
		self.timeOutTimer = nil
	end
end

function RecordController:afterStopSuccess( savedPath )


	if self.state ~= RecordController.STATE.kStoped then
		self.state = RecordController.STATE.kStoped

		if self.stopCallback.onSuccess then
			self.stopCallback.onSuccess(savedPath)
		end
	end
	self:removeLoadingAnim()
	if self.timeOutTimer then
		cancelTimeOut(self.timeOutTimer)
		self.timeOutTimer = nil
	end
end

function RecordController:afterStopFail( ... )
	if self.state ~= RecordController.STATE.kStoped then
		self.state = RecordController.STATE.kStoped
		if self.stopCallback.onFail then
			self.stopCallback.onFail()
		end
	end
	self:removeLoadingAnim()
	if self.timeOutTimer then
		cancelTimeOut(self.timeOutTimer)
		self.timeOutTimer = nil
	end
end

function RecordController:startRecord()
	if self.state ~= RecordController.STATE.kStoped and self.state ~= RecordController.STATE.kRequestingStop then
		return
	end

	self.state = RecordController.STATE.kRequestingStart

	self:showLoadingAnim()

	self.hadTimeOut = false
	
	self.timeOutTimer = setTimeOut(function ( ... )
		self.timeOutTimer = nil
		self.hadTimeOut = true
		self:afterStartFail()
	end, 20)

	if __IOS then
		local callback = WaxSimpleCallback:createSimpleCallbackDelegate(function ( ... )
			if self.hadTimeOut then
				ReplayManager:getInstance():stopRecord(WaxSimpleCallback:createSimpleCallbackDelegate(function ( ... )end, function ( ... )end))
			else
				self:afterStartSuccess()	
			end
		end, function ( ... )
			self:afterStartFail()	
		end)
		ReplayManager:getInstance():startRecord(callback)

	elseif __ANDROID then
		local ScreenRecorder = luajava.bindClass('com.happyelements.android.screen.ScreenRecorder'):get()
		local size = CCDirector:sharedDirector():getWinSizeInPixels()
		local codenames = luaJavaConvert.array2Table(ScreenRecorder:getSupportVideoEncodeName())
		local codename = codenames[1]
		if table.includes(codenames, 'OMX.google.h264.encoder') then
			codename = 'OMX.google.h264.encoder'
		end
		local mbitrate = ScreenRecorder:getVideoMaxBitrate(codename)
		local bitrate = 6*1024*1024
		if bitrate > mbitrate then
			bitrate = mbitrate
		end
		local framerate = 30
		local iframeInterval = 1
		ScreenRecorder:setVideoEncodeConfig(size.width, size.height, bitrate, framerate, iframeInterval, codename)
		local codenames = luaJavaConvert.array2Table(ScreenRecorder:getSupportAudioEncodeName())
		local codename = codenames[1]
		local mbitrate = ScreenRecorder:getAudioMaxBitrate(codename)
		local bitrate = 80000
		if bitrate > mbitrate then
			bitrate = mbitrate
		end
		local smaplerates = luaJavaConvert.array2Table(ScreenRecorder:getAudioSampleRates(codename))
		local channeCount = 1
		local profile = 1
		local max = #smaplerates
		local index = math.ceil(max/2)
		index = math.clamp(index, 1, #smaplerates)
		local smaplerate = smaplerates[index]
		-- ScreenRecorder:setAudioEncodeConfig(codename, bitrate, tonumber(smaplerate), channeCount, profile)
		local callback = luajava.createProxy("com.happyelements.android.InvokeCallback", {
	        onSuccess = function (message)
	        	local command, extra = string.match(message, '(.-):(.*)')
	        	if command == 'start' then
	        		self:afterStartSuccess()
	        	else
	        		self:afterStopSuccess(extra)
	        	end
	        end,
	        onError = function (code, errMsg)
	        	if self.state == RecordController.STATE.kRequestingStart then
	        		self:afterStartFail(code, errMsg)
	        	else
	        		self:afterStopSuccess()
	        	end
	        end,
	        onCancel = function ()
	        end
	    })
		ScreenRecorder:startRecord(callback)
	elseif __WIN32 then
		self:afterStartSuccess()	
	end

end

function RecordController:stopRecord( ... )
	-- body

	if self.state ~= RecordController.STATE.kStarted then
		return
	end

	self.state = RecordController.STATE.kRequestingStop
	if __IOS then

		local waiting = true
		local timerId = nil

		local callback = WaxSimpleCallback:createSimpleCallbackDelegate(function ( ... )
			local winSize 	= CCDirector:sharedDirector():getWinSize()
			local rect = ReplayManager:createCGRect_y_width_height(winSize.width / 2 + 195, winSize.height / 2 - 140, 0, 0)

			local function onSuccess(data)
				if timerId then 
					cancelTimeOut(timerId) 
					timerId = nil
					self:afterStopSuccess()
				end
			end

			local function onFailed(err)
				if timerId then 
					cancelTimeOut(timerId) 
					timerId = nil
					self:afterStopSuccess()
				end
			end

			local onFinishCallback = WaxSimpleCallback:createSimpleCallbackDelegate(onSuccess, onFailed)

			local function onShowSuccess(data)
			end

			local function onShowFailed(err)
				if timerId then 
					cancelTimeOut(timerId) 
					timerId = nil
					self:afterStopSuccess()
				end
			end

			local onShowCallback = WaxSimpleCallback:createSimpleCallbackDelegate(onShowSuccess, onShowFailed)
			ReplayManager:getInstance():showPreviewRect_completion_withCloseHandler(rect, onShowCallback, onFinishCallback)
		end, function ( ... )

			if timerId then 
				cancelTimeOut(timerId) 
				timerId = nil
				self:afterStopSuccess()
			end

		end)
		ReplayManager:getInstance():stopRecord(callback)

		timerId = setTimeOut(function ( ... )
			timerId = nil
			self:afterStopSuccess()
		end, 3)


	elseif __ANDROID then
		local ScreenRecorder = luajava.bindClass('com.happyelements.android.screen.ScreenRecorder'):get()
		ScreenRecorder:stopRecord()
	elseif __WIN32 then
		self:afterStopSuccess()	
	end
end

return RecordController