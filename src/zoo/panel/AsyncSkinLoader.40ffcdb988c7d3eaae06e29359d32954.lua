local AsyncDownloadTask = require 'zoo.panel.AsyncDownloadTask'

local prefix = 'http://static.manimal.happyelements.cn/updateRes/'

local AsyncSkinLoader = class()

AsyncSkinLoader.downloadResults = {
}

AsyncSkinLoader.Events = {
	kPanelClose = 'SkinLoader.Events.PanelClose'
}

function AsyncSkinLoader:setResult( PanelClass, result )
	AsyncSkinLoader.downloadResults[PanelClass] = result
end

function AsyncSkinLoader:create(PanelClass, params, skinGetter, callback, cancel)
	
	local loader = AsyncSkinLoader.new()
	loader:init(PanelClass, params, skinGetter, callback, cancel)
	return loader

end

function AsyncSkinLoader:init( PanelClass, params, skinGetter, onFinishCallback, onCancelCallback )
	self.PanelClass = PanelClass
	self.params = params
	self.skinGetter = skinGetter
	self.onFinishCallback = onFinishCallback
	self.onCancelCallback = onCancelCallback
	self.skinUrl = self.skinGetter()

	if not self.skinUrl then
		self:onFinish()
		return
	end

	self:buildSkinUrl()


	local function __startDownload( ... )
		self.downloader = AsyncDownloadTask.new()
		self.downloader:addResUrls({
			self.textureUrl,
			self.plistUrl
		})

		self.downloader:ad(self.downloader.Events.kFinish, function ( ... )
			self:onResFinish()
		end)
		self.downloader:ad(self.downloader.Events.kFail, function ( ... )
			self:onResFail()
		end)

		self:createLoadingAnim()
		
		self.downloader:run()

	end

	if self.downloadResults[self.PanelClass] ~= nil then
		if self.downloadResults[self.PanelClass] then
			__startDownload()
		else
			self:onResFail()
		end
	else
		__startDownload()
	end
end

function AsyncSkinLoader:onResFinish( ... )
	if self.__manualCanceled then return end

	self:closeLoadingAnim()
	self:onFinish(true)

end

function AsyncSkinLoader:onResFail( ... )
	if self.__manualCanceled then return end

	self:closeLoadingAnim()
	self:onFinish(false)
	
end

function AsyncSkinLoader:getSkinUrls( skinUrl )
	local small_suffix = ''
	if __use_small_res then
		small_suffix = '@2x'
	end
	local textureUrl = prefix .. skinUrl .. '/' .. 'skin' .. small_suffix .. '.pkmz'
	local plistUrl = prefix .. skinUrl .. '/' .. 'skin' .. small_suffix .. '.plist'
	return textureUrl, plistUrl
end


function AsyncSkinLoader:buildSkinUrl( ... )
	self.textureUrl, self.plistUrl = self:getSkinUrls(self.skinUrl)
end

function AsyncSkinLoader:onFinish( success )
	if self.__finished then return end
	self.__finished = true
	if self.onFinishCallback then
		if success then
			self:loadRes()
		end
		local panel = self.PanelClass:create(unpack(self.params))
		panel:ad(AsyncSkinLoader.Events.kPanelClose, function ( ... )
			self:unloadRes()
		end)
		self.onFinishCallback(panel)
	end
end

function AsyncSkinLoader:createLoadingAnim( ... )
	if self.loadAnim then return end
	local runningScene = Director:sharedDirector():getRunningScene()
	self.loadAnim = CountDownAnimation:createBindAnimation(runningScene, function ( ... )
		self:closeLoadingAnim()
		self:manualCancel()
	end)
end

function AsyncSkinLoader:manualCancel( ... )
	if self.__manualCanceled then
		return
	end

	self.__manualCanceled = true

	if self.onCancelCallback then
		self.onCancelCallback()
	end

end

function AsyncSkinLoader:closeLoadingAnim( ... )
	if not self.loadAnim then return end
	if not (self.loadAnim.isDisposed) then
		self.loadAnim:removeFromParentAndCleanup(true)
	end
	self.loadAnim = nil
end

function AsyncSkinLoader:loadRes( ... )
	if self:hadNetworkRes() and (not self.loadedRes) then
		local datas = self.downloader:getDatas() or {}
		local texture = datas[self.textureUrl] or {}
		texture = texture.realPath

		local plist = datas[self.plistUrl] or {}
		plist = plist.realPath

		if plist and texture then
			pcall(function ( ... )
				CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(plist, texture)
				self.loadedRes = true
				self.plist = plist
				self.texture = texture
			end)
		end
	end
end

function AsyncSkinLoader:unloadRes( ... )
	if self.loadedRes and (not self.unloadedRes) then
		self.unloadedRes = true
		if self.plist and self.texture then
			CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile(self.plist)
			CCTextureCache:sharedTextureCache():removeTextureForKey(self.texture)
		end
		self.plist = nil
		self.texture = nil
	end
end

function AsyncSkinLoader:hadNetworkRes( ... )
	return self.textureUrl ~= nil and self.plistUrl ~= nil
end

return AsyncSkinLoader