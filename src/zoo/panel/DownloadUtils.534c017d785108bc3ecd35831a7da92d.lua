if not __ANDROID then
	return
end

local DownloadUtils = {}

local threadId 

function DownloadUtils:__download( url, savePathname, appName, _onSuccess, _onFail, _onProcess)
	if threadId then
		return false
	end
	local downLoadCallfunc = luajava.createProxy("com.happyelements.android.utils.NewDownloadApkCallback", {
		onSuccess = function ( ... )
			threadId = nil
			if _onSuccess then
				_onSuccess()
			end
		end,
		onError = function ( code )
			threadId = nil
			if code ~= 1002 and code ~= 1000 then
				if self.tryCount > 0 then
					self.tryCount = self.tryCount - 1
					self:__download(url, savePathname, appName, _onSuccess, _onFail, _onProcess)
				else
					if _onFail then
						_onFail(code)
					end
				end
			else
				if _onFail then
					_onFail(code)
				end
			end
		end,
		onProcess = _onProcess,
		onRedirect = function ( url )
			threadId = nil
			self:__download(url, savePathname, appName, _onSuccess, _onFail, _onProcess)
		end
	})

	local HttpUtil = luajava.bindClass("com.happyelements.android.utils.HttpUtil")
	threadId = HttpUtil:newDownloadApk(url, savePathname, appName, downLoadCallfunc)
	return threadId ~= nil
end

function DownloadUtils:download( url, savePathname, appName, _onSuccess, onFail, onProcess )
	self.tryCount = 3
	return self:__download( url, savePathname, appName, _onSuccess, onFail, onProcess )
end

function DownloadUtils:cancelDownload()
	if threadId then
		local HttpUtil = luajava.bindClass("com.happyelements.android.utils.HttpUtil")
		HttpUtil:interruptDownloadThread(threadId)
		threadId = nil
	end
end

function DownloadUtils:isDownloadStarted()
	return threadId ~= nil
end

return DownloadUtils