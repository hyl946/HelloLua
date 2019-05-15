CaptureAndShareUtil = class()

local function getCacheFolder()
    local path = nil
	if __ANDROID then
		path = luajava.bindClass("com.happyelements.android.utils.ScreenShotUtil"):getGamePictureExternalStorageDirectory()
	elseif __IOS then
 		path = HeResPathUtils:getResCachePath()
	end

    if not path then
        path = HeResPathUtils:getResCachePath()
    end
    return path
end

function CaptureAndShareUtil.shareDisabled()
	if WXJPPackageUtil.getInstance():isWXJPPackage() then return true end

	if PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk) 
		or PlatformConfig:isPlatform(PlatformNameEnum.kOppo)
		or PlatformConfig:isPlatform(PlatformNameEnum.kMiPad)
		or PlatformConfig:isPlatform(PlatformNameEnum.kHuaWei)
		or PlatformConfig:isPlatform(PlatformNameEnum.kJJ) then
			return true
		end
	return false
end

function CaptureAndShareUtil.setEnable(val)
	if CaptureAndShareUtil.shareDisabled() then return end

    local keyName = "CaptureAndShare"
	if not MaintenanceManager:getInstance():isEnabled(keyName, false) then
		return
	end

	if __ANDROID then
		luajava.bindClass("com.happyelements.android.share.CaptureShareManager"):setEnable(val)
	elseif __IOS then
		AppController:setCaptureAndShareEnabled(val)
	end
end

function CaptureAndShareUtil.onShareFriends(param)
	local title =  localize("captureforshare.message.friends")
	local message = title

	local imageURL = param
	local thumbUrl = imageURL

	if not HeFileUtils:exists(imageURL) then
		return setTimeOut(function ( ... ) CommonTip:showTip(localize("captureforshare.share.friends.error"), 'negative') end, 0.001)
	end

	local function resize()
		local dst = getCacheFolder() ..'/cs_friends_thumb.jpg'
		Image_resize(imageURL, dst, 0.125)
		thumbUrl = dst
	end
	pcall(resize)

	--thumbUrl = 'share/AskForHelp/thumb/avatar.jpg'
	--thumbUrl = CCFileUtils:sharedFileUtils():fullPathForFilename(thumbUrl)
	--imageURL = thumbUrl

	local shareCallback = {
		onSuccess = function()
			DcUtil:UserTrack({category = 'show', sub_category = 'show_screen_shot_success'})
			setTimeOut(function ( ... ) CommonTip:showTip(localize("captureforshare.share.friends.success"), 'positive') end, 0.001)
		end,
		onError = function(errCode, msg)
			DcUtil:UserTrack({category = 'show', sub_category = 'show_screen_shot_fail'})
			setTimeOut(function ( ... ) CommonTip:showTip(localize("captureforshare.share.friends.error"), 'negative') end, 0.001)
		end,
		onCancel = function()
			DcUtil:UserTrack({category = 'show', sub_category = 'show_screen_shot_cancel'})		
			setTimeOut(function ( ... ) CommonTip:showTip(localize("captureforshare.share.friends.cancel"), 'negative') end, 0.001)
		end
	}

	local eShareType = PlatformShareEnum.kWechat
	SnsUtil.sendImageMessage(eShareType, title, message, thumbUrl, imageURL, shareCallback, false)
end

function CaptureAndShareUtil.onShareCircleFriends(param)
	local title =  localize("captureforshare.message.circlefriends")
	local message = title

	local imageURL = param
	local thumbUrl = param

	if not HeFileUtils:exists(imageURL) then
		return setTimeOut(function ( ... ) CommonTip:showTip(localize("captureforshare.share.circlefriends.error"), 'negative') end, 0.001)
	end 

	local function resize()
		local dst = getCacheFolder() ..'/cs_cfriends_thumb.jpg'
		Image_resize(imageURL, dst, 0.125)
		thumbUrl = dst
	end
	pcall(resize)

	local shareCallback = {
		onSuccess = function()
			DcUtil:UserTrack({category = 'show', sub_category = 'show_screen_shot_success'})
			setTimeOut(function ( ... ) CommonTip:showTip(localize("captureforshare.share.circlefriends.success"), 'positive') end, 0.001)
		end,
		onError = function(errCode, msg)
			DcUtil:UserTrack({category = 'show', sub_category = 'show_screen_shot_fail'})
			setTimeOut(function ( ... ) CommonTip:showTip(localize("captureforshare.share.circlefriends.error"), 'negative') end, 0.001)
		end,
		onCancel = function()
			DcUtil:UserTrack({category = 'show', sub_category = 'show_screen_shot_cancel'})
			setTimeOut(function ( ... ) CommonTip:showTip(localize("captureforshare.share.circlefriends.cancel"), 'negative') end, 0.001)
		end
	}

	local eShareType = PlatformShareEnum.kWechat
	SnsUtil.sendImageMessage(eShareType, title, message, thumbUrl, imageURL, shareCallback, true)
end