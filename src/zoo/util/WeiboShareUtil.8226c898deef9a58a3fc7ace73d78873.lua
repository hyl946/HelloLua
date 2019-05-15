
-----------------------------------------
----------WeiboShareUtilAndroid----------
-----------------------------------------
local function buildCallbackAndroid(callback, resultParser)
    if type(callback) == "table" then
        return convertToInvokeCallback(callback)
    end
  
    local function onError(errorCode, extra)
        if callback then
            callback(SnsCallbackEvent.onError, buildError(errorCode, extra) )
        end
    end

    local function onCancel()
        if callback then
            callback(SnsCallbackEvent.onCancel)
        end
    end
      
    local function onSuccess(result)
        local tResult = nil
        if resultParser ~= nil then
            tResult = resultParser(result)
        end

        if callback then
            callback(SnsCallbackEvent.onSuccess, tResult)
        end
    end
      
    return luajava.createProxy("com.happyelements.android.InvokeCallback", {
        onSuccess = onSuccess,
        onError = onError,
        onCancel = onCancel
    })
end

WeiboShareUtilAndroid = class()
local instanceAndroid = nil
function WeiboShareUtilAndroid.getInstance()
	if not instanceAndroid then
		instanceAndroid = WeiboShareUtilAndroid.new()
		instanceAndroid:init()
	end
	return instanceAndroid
end

function WeiboShareUtilAndroid:init()
	self.sdk = luajava.bindClass("com.happyelements.android.platform.weibo.WeiboShareDelegate"):getInstance()
end

function WeiboShareUtilAndroid:wbShareImage(msg, imgPath, callback)
	if self.sdk then 
		self.sdk:wbShareImage(msg, imgPath, buildCallbackAndroid(callback))
	end
end

function WeiboShareUtilAndroid:wbShareWebpage(msg, imgPath, webUrl, webImg, webTitle, webDesc, callback)
	if self.sdk then 
		self.sdk:wbShareWebpage(msg, imgPath, webUrl, webImg, webTitle, webDesc, buildCallbackAndroid(callback)) 
	end
end

function WeiboShareUtilAndroid:wbShareVideo(msg, imgPath, videoUrl, videoImg, videoTitle, videoDesc, callback)
	if self.sdk then 
		self.sdk:wbShareVideo(msg, imgPath, videoUrl, videoImg, videoTitle, videoDesc, buildCallbackAndroid(callback)) 
	end
end

-------------------------------------
----------WeiboShareUtilIos----------
-------------------------------------
local function buildCallbackIos(callback)
	waxClass{"IosCallback",NSObject,protocols={"SimpleCallbackDelegate"}}
	function IosCallback:onSuccess(result)
		if callback.onSuccess then 
			callback.onSuccess();
		end
	end
	function IosCallback:onFailed(result)
		if callback.onError then 
			callback.onError();
		end
	end
	function IosCallback:onCancel()
		if callback.onCancel then 
			callback.onCancel();
		end
	end

	local iosCallback = IosCallback:init()
	return iosCallback;
end

WeiboShareUtilIos = class()
local instanceIos = nil
function WeiboShareUtilIos.getInstance()
	if not instanceIos then
		instanceIos = WeiboShareUtilIos.new()
		instanceIos:init()
	end
	return instanceIos
end

function WeiboShareUtilIos:init()
	
end

function WeiboShareUtilIos:wbShareImage(msg, imgPath, callback)

end

function WeiboShareUtilIos:wbShareWebpage(msg, imgPath, webUrl, webImg, webTitle, webDesc, callback)

end

function WeiboShareUtilIos:wbShareVideo(msg, imgPath, videoUrl, videoImg, videoTitle, videoDesc, callback)
   waxClass{"SimpleCallbackDelegate", "NSObject", protocols = {"SimpleCallbackDelegate"}}
   SimpleCallbackDelegate.onSuccess = callback.onSuccess
   SimpleCallbackDelegate.onFailed = callback.onError
   SimpleCallbackDelegate.onCancel = callback.onCancel
   WbShareManager:getInstance():shareMultiMedia_imgPath_videoUrl_title_description_callback(
   		msg,
   		videoImg,
   		videoUrl,
   		videoTitle,
   		videoDesc,
   		SimpleCallbackDelegate:init())
end


----------------------------------
----------WeiboShareUtil----------
----------------------------------
WeiboShareUtil = class()
function WeiboShareUtil:ctor()
	self.animation = nil
	self.listening = true
	self.shareCanceled = false

	if __IOS then
		self.sdk = WeiboShareUtilIos:getInstance()
	end
	if __ANDROID then
		self.sdk = WeiboShareUtilAndroid:getInstance()
	end
	if __WP8 then
		-- self.sdk = WeChatWP8:getInstance()
	end
end

function WeiboShareUtil:buildProxy(shareCallback)
	local callbackProxy = {
		onSuccess=function(result)
			self:removeLoading()
			if not self.shareCanceled and shareCallback and shareCallback.onSuccess then
				shareCallback.onSuccess(result)
			end
		end,
		onError=function(errCode, msg) 
			self:removeLoading()
			if errCode == 1000 then --手动取消
				--CommonTip:showTip(Localization:getInstance():getText("share.feed.cancel.tips1"), "negative")
			elseif errCode == 1001 and not self.shareCanceled then --超时取消
				--CommonTip:showTip(Localization:getInstance():getText("share.feed.time.out.tips"), "negative")
			end

			if not self.shareCanceled and shareCallback and shareCallback.onError then
				shareCallback.onError(errCode, msg)
			end
		end,
		onCancel=function()
			self:removeLoading()
			if not self.shareCanceled and shareCallback and shareCallback.onCancel then
				shareCallback.onCancel()
			end
		end
	}

	return callbackProxy
end

function WeiboShareUtil:removeLoading()
	if _G.isLocalDevelopMode then printx(0, "WeiboShareUtil:removeLoading") end
	if self.animation then
        self.listening = false
        self.animation:removeFromParentAndCleanup(true)
        self.animation = nil
    end
end

function WeiboShareUtil:showLoading(shareCallback)
	if _G.isLocalDevelopMode then printx(0, "WeiboShareUtil:showLoading") end
	self.listening = true
	self.shareCanceled = false
    local function onCloseButtonTap()
    	self.shareCanceled = true
        self:removeLoading()

        if shareCallback and shareCallback.onError then
			shareCallback.onError(1000, "cancel share")
        end
    end
    local scene = Director:sharedDirector():getRunningScene()
    local tips = Localization:getInstance():getText("share.feed.loading.tips")
    self.animation = CountDownAnimation:createNetworkAnimation(scene, onCloseButtonTap, tips)
end

function WeiboShareUtil:wbShareImage(msg, imgPath, shareCallback)
	if self.sdk then 
		local callBackProxy = self:buildProxy(shareCallback)
		self:showLoading(callBackProxy)
		return self.sdk:wbShareImage(msg, imgPath, callBackProxy) 
	end
end

function WeiboShareUtil:wbShareWebpage(msg, imgPath, webUrl, webImg, webTitle, webDesc, shareCallback)
	if self.sdk then 
		local callBackProxy = self:buildProxy(shareCallback)
		self:showLoading(callBackProxy)
		return self.sdk:wbShareWebpage(msg, imgPath, webUrl, webImg, webTitle, webDesc, callBackProxy) 
	end
end

--msg 分享时默认的文案 玩家可编辑
--imgPath 分享图（如果这里加了分享图 下面的videoImg会显示不出 具体效果可试下 根据需求定）
--videoUrl 视频地址
--videoImg 视频缩略图
--videoTitle 视频栏标题
--videoDesc 视频描述
--shareCallback 回调
function WeiboShareUtil:wbShareVideo(msg, imgPath, videoUrl, videoImg, videoTitle, videoDesc, shareCallback)
	if self.sdk then 
		local callBackProxy = self:buildProxy(shareCallback)
		self:showLoading(callBackProxy)
		return self.sdk:wbShareVideo(msg, imgPath, videoUrl, videoImg, videoTitle, videoDesc, callBackProxy) 
	end
end


function WeiboShareUtil:isWeiboInstalled()
	if __IOS then
		return WbShareManager:getInstance():isWeiboInstalled()
	end
	if __ANDROID then
		return true
	end
	if __WP8 then
		return true
	end
	
	return true
end
--[[
	if WbShareManager:getInstance():isWeiboInstalled() then
	else
		
	end
]]

-- -- 我是调用示例
-- local function exampleInvoke()
-- 	local callback = {onSuccess = function ()
-- 		if _G.isLocalDevelopMode then printx(0, "success") end
-- 	end, onError = function ()
-- 		if _G.isLocalDevelopMode then printx(0, "error") end
-- 	end, onCancel = function ()
-- 		if _G.isLocalDevelopMode then printx(0, "cancel") end
-- 	end}
-- 	local thumb = CCFileUtils:sharedFileUtils():fullPathForFilename("materials/wechat_icon.png")
-- 	WeiboShareUtil.new():wbShareVideo("i wanna grow grow grow", nil, "http://video.sina.com.cn/p/sports/cba/v/2013-10-22/144463050817.html", 
-- 	 									thumb, "i am title", "i am desc", callback)
-- end