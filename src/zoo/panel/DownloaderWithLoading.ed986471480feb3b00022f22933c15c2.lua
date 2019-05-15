local AsyncDownloadTask = require 'zoo.panel.AsyncDownloadTask'

local DownloaderWithLoading = class()

function DownloaderWithLoading:create(urls, callback, cancel)
	
	local loader = DownloaderWithLoading.new()
	loader:init(urls, callback, cancel)
	return loader

end

function DownloaderWithLoading:init( urls, callback, cancel )
	self.urls = urls
	self.onFinishCallback = callback
	self.onCancelCallback = cancel

	if (not self.urls) or #(self.urls) <= 0 then
		self:onFinish(true)
		return
	end

	self.downloader = AsyncDownloadTask.new()
	self.downloader:addResUrls(self.urls)

	self.downloader:ad(self.downloader.Events.kFinish, function ( ... )
		self:onResFinish()
	end)
	self.downloader:ad(self.downloader.Events.kFail, function ( ... )
		self:onResFail()
	end)

	self:createLoadingAnim()
	
	self.downloader:run()
end

function DownloaderWithLoading:onResFinish( ... )
	if self.__manualCanceled then return end
	self:closeLoadingAnim()
	self:onFinish(true)
end

function DownloaderWithLoading:onResFail( ... )
	if self.__manualCanceled then return end
	self:closeLoadingAnim()
	self:onFinish(false)
end

function DownloaderWithLoading:onFinish( ret )

	if self.__finished then return end
	self.__finished = true

	if self.onFinishCallback then
		self.onFinishCallback(ret)
	end
end


function DownloaderWithLoading:createLoadingAnim( ... )
	if self.loadAnim then return end
	local runningScene = Director:sharedDirector():getRunningScene()
	self.loadAnim = CountDownAnimation:createBindAnimation(runningScene, function ( ... )
		self:closeLoadingAnim()
		self:manualCancel()
	end)
end

function DownloaderWithLoading:manualCancel( ... )
	if self.__manualCanceled then
		return
	end

	self.__manualCanceled = true

	if self.onCancelCallback then
		self.onCancelCallback()
	end

end

function DownloaderWithLoading:closeLoadingAnim( ... )
	if not self.loadAnim then return end
	if not (self.loadAnim.isDisposed) then
		self.loadAnim:removeFromParentAndCleanup(true)
	end
	self.loadAnim = nil
end

return DownloaderWithLoading