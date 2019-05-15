local function getTmpPath( url )
	local prefix = HeResPathUtils:getTmpDataPath()
	local filename = string.match(url or '', '([^/]+)$')
	if (not filename) or filename == '' then
		return false
	end

	HeFileUtils:mkdirs(prefix .. '/skin')
	return prefix .. '/skin/' .. filename
end

local function getResFromUrls(urls , onSuccess, onFail)
	-- local function loadThirdPartyResCallback(eventName, data)
	-- 	if eventName == ResCallbackEvent.onError then
	-- 		onFail(data)
	-- 	elseif eventName == ResCallbackEvent.onSuccess then
	-- 		onSuccess(data)
	-- 	end
	-- end
	-- ResourceLoader.loadThirdPartyRes(urls, loadThirdPartyResCallback)

	for _, url in pairs(urls) do
		local request = HttpRequest:createGet(url)
		local timeout = 8
	  	local connection_timeout = 2
	  	if __WP8 then 
	    	timeout = 30
	    	connection_timeout = 5
	  	end
	    request:setConnectionTimeoutMs(connection_timeout * 1000)
	    request:setTimeoutMs(timeout * 1000)

	    local __url = url

	    if not PrepackageUtil:isPreNoNetWork() then 
	   		HttpClient:getInstance():sendRequest(function ( response )
	   			if response.httpCode ~= 200 then 
					onFail({url=__url})
				else
					local content = response.body
					local realPath = getTmpPath(__url)

					if not realPath then
						onFail({url=__url})
						return
					end

					local file = io.open(realPath, 'wb')

					if not file then
						onFail({url=__url})
						return
					end

					local success = file:write(content)
					if success then
						file:flush()
						file:close()
						onSuccess({
							url = __url,
							realPath = realPath
						})
					else
						file:close()
						onFail({url=__url})
					end

				end
	   		end, request)
	   	else
		    onFail({url=url})
	   	end
	end

end

local downloadedMap = {}
local readed = false

local AsyncDownloadTask = class(EventDispatcher)

AsyncDownloadTask.Events = {
	kFinish = 'AsyncDownloadTask.Events.kFinish',
	kProgress = 'AsyncDownloadTask.Events.kProgress',
	kFail = 'AsyncDownloadTask.Events.kProgress.kFail'
}

function AsyncDownloadTask:ctor( ... )

	AsyncDownloadTask:read()


	self.urls = {}
	self.datas = downloadedMap
	self.counter = 0

	self.failed = false

	local defaultTimeOut = 8
	self.timeOut = defaultTimeOut
end

function AsyncDownloadTask:addResUrls( urls )
	for _, url in ipairs(urls) do
		if not downloadedMap[url] then
			table.insertIfNotExist(self.urls, url)
		end
	end
end

function AsyncDownloadTask:setTimeOut( timeOut )
	self.timeOut = timeOut
end

function AsyncDownloadTask:run( ... )

	if #self.urls <= 0 then
		self:onFinish()
		return
	end

	getResFromUrls(self.urls, function ( data )
		local url = data['url']
		local virtualPath = data['virtualPath']
		local realPath = data['realPath']
		
		local item = {
			url = url,
			virtualPath = virtualPath,
			realPath = realPath,
		}

		downloadedMap[url] = {realPath = realPath,}

		self.datas[url] = item

		local percent = (#self.datas) / (#self.urls)

		self:onProgress(percent, item)

		self.counter = self.counter + 1

		if self.counter >= #self.urls then
			self:onFinish()
		end

	end, function ( data )
		self:onFail()
	end)

	if self.timeOut then
		self:startTimeOutTimer()
	end

end

function AsyncDownloadTask:startTimeOutTimer( ... )

	if not self.scheduleScriptFuncID then
		self.scheduleScriptFuncID = setTimeOut(function ( ... )
			self:onTimeOut()
		end, self.timeOut)
	end

end

function AsyncDownloadTask:onTimeOut( ... )
	self:onFail()
end

function AsyncDownloadTask:stopTimeOutTimer( ... )
	if self.scheduleScriptFuncID then
		cancelTimeOut(self.scheduleScriptFuncID)
		self.scheduleScriptFuncID = nil
	end
end

function AsyncDownloadTask:read( ... )

	if readed then return end
	readed = true

	local tmp = Localhost:readFileData('cache_downloaded.ds')

	for url, data in pairs(tmp) do
		local path = CCFileUtils:sharedFileUtils():fullPathForFilename(data.realPath)
		if HeFileUtils:exists(path) then
			downloadedMap[url] = data
		end
	end
end

function AsyncDownloadTask:write( ... )
	Localhost:writeToFile('cache_downloaded.ds', downloadedMap)
end

function AsyncDownloadTask:onFinish( ... )
	self:write()

	if self.failed then 
		return 
	end

	if self.__ended then
		return
	end

	self:stopTimeOutTimer()

	self.__ended = true
	self:dp(Event.new(AsyncDownloadTask.Events.kFinish))
end

function AsyncDownloadTask:onProgress(percent, item )
	if self.failed then 
		return 
	end

	self:dp(Event.new(AsyncDownloadTask.Events.kProgress, {
		percent = percent,
		data = item	
	}))
end

function AsyncDownloadTask:getUrls( ... )
	return self.urls
end

function AsyncDownloadTask:getDatas( ... )
	return self.datas
end

function AsyncDownloadTask:onFail( ... )
	if self.failed then 
		return 
	end
	if self.__ended then
		return
	end

	self:stopTimeOutTimer()

	self.failed = true
	self.__ended = true
	self:dp(Event.new(AsyncDownloadTask.Events.kFail))
end


return AsyncDownloadTask