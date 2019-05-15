require "hecore.sns.SnsProxy"
require "zoo.util.WeChatSDK"

SnsUtil = {}

gShareSource = {
	WEEKLY_MATCH = 1,
}

function SnsUtil.sendInviteMessage( shareType, shareCallback, shareSource)
	if WXJPPackageUtil.getInstance():isGuestLogin() then 
		CommonTip:showTip(Localization:getInstance():getText("wxjp.guest.warning.tip"), "negative")
		if shareCallback and type(shareCallback.onCancel) == "function" then
			shareCallback.onCancel()
		end
		return 
	end

	local shareTitle = Localization:getInstance():getText("invite.friend.panel.share.title")
	local invitecode = tostring(AddFriendPanelModel:getUserInviteCode())
	-- 分享的文案
	local txtToShare = Localization:getInstance():getText("invite.friend.panel.share.desc", {yaoqingma = invitecode})
	
	local thumb = CCFileUtils:sharedFileUtils():fullPathForFilename("materials/invite_icon.png")
	local plarformName = StartupConfig:getInstance():getPlatformName()
	-- 分享的链接地址
	local link
	if shareType == PlatformShareEnum.kMiTalk then
		link = NetworkConfig.redirectURL.."?invitecode="..invitecode.."&uid="..tostring(UserManager:getInstance().uid).."&pid="..tostring(plarformName)
	else
		link = PersonalCenterManager:getLinkUrl()
	end
	-- 分享回调
	local inviteCallback = {
		onSuccess = function(result)
			if _G.isLocalDevelopMode then printx(0, "share onSuccess") end
			if shareType == PlatformShareEnum.kWechat or 
				shareType == PlatformShareEnum.kMiTalk or 
				shareType == PlatformShareEnum.kJPQQ or 
				shareType == PlatformShareEnum.kJPWX then
				CommonTip:showTip(Localization:getInstance():getText("share.feed.invite.success.tips"), "positive")
			end

			if shareCallback and type(shareCallback.onSuccess) == "function" then
				shareCallback.onSuccess(result)
			end
		end,
		onError = function(errCode, errMsg)
			if _G.isLocalDevelopMode then printx(0, "share onError") end
			if errCode and errCode == -1 then 
				if shareType == PlatformShareEnum.kJPQQ then 
					SnsUtil.addTipsItem(Localization:getInstance():getText("请安装QQ后再分享~"))
				elseif shareType == PlatformShareEnum.kJPWX then 
					SnsUtil.addTipsItem(Localization:getInstance():getText("请安装微信后再分享~"))
				end
			elseif shareType == PlatformShareEnum.kMiTalk then
--				SnsUtil.addTipsItem(Localization:getInstance():getText("share.feed.invite.code.faild.tips.mitalk"))
			elseif shareType == PlatformShareEnum.kWechat or 
					shareType == PlatformShareEnum.kJPQQ or 
					shareType == PlatformShareEnum.kJPWX then
				SnsUtil.addTipsItem(Localization:getInstance():getText("share.feed.invite.code.faild.tips"))
			end

			if shareCallback and type(shareCallback.onError) == "function" then
				shareCallback.onError(errCode, errMsg)
			end
		end,
		onCancel = function()
			if _G.isLocalDevelopMode then printx(0, "share onCancel") end
			if shareType == PlatformShareEnum.kWechat or 
			    shareType == PlatformShareEnum.kJPQQ or 
				shareType == PlatformShareEnum.kJPWX then
				SnsUtil.addTipsItem(Localization:getInstance():getText("share.feed.cancel.tips"))
			end

			if shareCallback and type(shareCallback.onCancel) == "function" then
				shareCallback.onCancel()
			end
		end
	}


	if shareType == PlatformShareEnum.kWechat then -- 微信分享
		
		WeChatSDK.new():sendLinkMessage(shareTitle, txtToShare, thumb, link, false, inviteCallback)
	elseif shareType == PlatformShareEnum.k360 then -- 360分享
		if SnsProxy:isLogin() then 
			txtToShare	= "没网也能玩儿，现在来就送168元大礼包！"
			SnsProxy:shareLink(PlatformShareEnum.k360, shareTitle, txtToShare, link, thumb, inviteCallback)
		else
			SnsUtil.addTipsItem("该功能需要360账号联网登录")
		end
	else
		SnsProxy:sendInviteMessage(shareType, nil, shareTitle, txtToShare, link, thumb, inviteCallback)
	end
end

function SnsUtil.sendTextMessage( shareType, title, message, toTimeLine, shareCallback, shareSource )
	if WXJPPackageUtil.getInstance():isGuestLogin() then 
		CommonTip:showTip(Localization:getInstance():getText("wxjp.guest.warning.tip"), "negative")
		if shareCallback and type(shareCallback.onCancel) == "function" then
			shareCallback.onCancel()
		end
		return 
	end

	title = title or ""
	message = message or ""

	if shareType == PlatformShareEnum.kWechat then
		
		if WeChatSDK.new():sendTextMessage( message, toTimeLine ) then
			if shareCallback and shareCallback.onSuccess then shareCallback.onSuccess({}) end
		else
			if shareCallback and shareCallback.onError then shareCallback.onError() end
		end
	else
		SnsProxy:shareText( shareType, title, message, shareCallback, toTimeLine )
	end
end

-- !!! toTimeline 朋友圈  thumb 大小不能>32k
function SnsUtil.sendImageMessage( shareType, title, message, thumb, imageURL, shareCallback, toTimeline, shareSource )
	if WXJPPackageUtil.getInstance():isGuestLogin() then 
		CommonTip:showTip(Localization:getInstance():getText("wxjp.guest.warning.tip"), "negative")
		if shareCallback and type(shareCallback.onCancel) == "function" then
			shareCallback.onCancel()
		end
		return 
	end

	title = title or ""
	message = message or ""

	if shareType == PlatformShareEnum.kWechat then
		
		if shareCallback then
			WeChatSDK.new():sendImageMessage(message, thumb, imageURL, shareCallback, toTimeline)
		end
	else
		SnsProxy:shareImage( shareType, title, message, imageURL, thumb, shareCallback, toTimeline )
	end
end

-- !!! toTimeLine = false  thumb 大小不能>32k
function SnsUtil.sendGifMessage( shareType, title, message, thumb, imageURL, shareCallback, toTimeLine, shareSource )
	title = title or ""
	message = message or ""

	if shareType == PlatformShareEnum.kWechat then
		if shareCallback then
			WeChatSDK.new():sendGifMessage(message, thumb, imageURL, shareCallback, toTimeLine)
		end
	-- else
	-- 	SnsProxy:shareImage( shareType, title, message, imageURL, thumb, shareCallback )
	end
end

function SnsUtil.sendImageLinkMessage( shareType, title, message, thumb, imageURL, shareCallback, shareSource)
	if WXJPPackageUtil.getInstance():isGuestLogin() then 
		CommonTip:showTip(Localization:getInstance():getText("wxjp.guest.warning.tip"), "negative")
		if shareCallback and type(shareCallback.onCancel) == "function" then
			shareCallback.onCancel()
		end
		return 
	end

	title = title or ""
	message = message or ""

	if shareType == PlatformShareEnum.kWechat then
		
		if _G.isLocalDevelopMode then printx(0, "WeChatSDK sendImageLinkMessage") end
		WeChatSDK.new():sendImageLinkMessage(message, thumb, imageURL, shareCallback)
	else
		SnsProxy:shareImage( shareType, title, message, imageURL, thumb, shareCallback )
	end
end

--米聊不支持这个
function SnsUtil.sendLinkMessage( shareType, title, message, thumb, webpageUrl, toTimeLine, shareCallback, shareSource)
	if WXJPPackageUtil.getInstance():isGuestLogin() then 
		CommonTip:showTip(Localization:getInstance():getText("wxjp.guest.warning.tip"), "negative")
		if shareCallback and type(shareCallback.onCancel) == "function" then
			shareCallback.onCancel()
		end
		return 
	end

	title = title or ""
	message = message or ""

	if shareType == PlatformShareEnum.kWechat then
		
		WeChatSDK.new():sendLinkMessage(title, message, thumb, webpageUrl, toTimeLine, shareCallback)
	else
		SnsProxy:shareLink( shareType, title, message, webpageUrl, thumb, shareCallback, toTimeLine)
	end
end

function SnsUtil.addTipsItem( msg )
	CommonTip:showTip(msg, 'negative', nil, 2)
end

function SnsUtil.sendLevelMessage( shareType, levelType, levelId, shareCallback, noTips, shareSource )
	if WXJPPackageUtil.getInstance():isGuestLogin() then 
		CommonTip:showTip(Localization:getInstance():getText("wxjp.guest.warning.tip"), "negative")
		if shareCallback and type(shareCallback.onCancel) == "function" then
			shareCallback.onCancel()
		end
		return 
	end

	local timer = os.time() or 0
	local datetime = tostring(os.date("%y%m%d%H", timer))
	local levelId = levelId or 1
	local txtToShare = ""
	local shareTitle = Localization:getInstance():getText("share.feed.title")
	local thumb = CCFileUtils:sharedFileUtils():fullPathForFilename("materials/thumb_main.png")
	local imageURL = nil
	if levelType == GameLevelType.kMainLevel then
		txtToShare = Localization:getInstance():getText("share.feed.text", {level=levelId})
		imageURL = string.format("http://static.manimal.happyelements.cn/level/jt0001%04d.jpg?v="..datetime, levelId)
	elseif levelType == GameLevelType.kHiddenLevel then
		local hidenLevelId = levelId - LevelConstans.HIDE_LEVEL_ID_START
		txtToShare = Localization:getInstance():getText("share.feed.text", {level="+"..hidenLevelId})
		imageURL = string.format("http://static.manimal.happyelements.cn/level/hide%04d.jpg?v="..datetime, levelId - LevelConstans.HIDE_LEVEL_ID_START)
	end

	local successFunc = nil

	local passLevelShareCallBack = {
		onSuccess = function(result)
			if not noTips then
				SnsUtil.showShareSuccessTip(shareType)
			end

			if shareCallback and type(shareCallback.onSuccess) == "function" then
				shareCallback.onSuccess(result)
			end

			if successFunc then
				successFunc()
			end
		end,
		onError = function(errCode, errMsg)
			if not noTips then
				SnsUtil.showShareFailTip(shareType)
			end

			if shareCallback and type(shareCallback.onError) == "function" then
				shareCallback.onError(errCode, errMsg)
			end
		end,
		onCancel = function()
			if shareCallback and type(shareCallback.onCancel) == "function" then
				shareCallback.onCancel()
			end
		end
	}

	if shareType == PlatformShareEnum.kWechat or 
		shareType == PlatformShareEnum.kJPQQ or 
		shareType == PlatformShareEnum.kJPWX then
		local thumb = CCFileUtils:sharedFileUtils():fullPathForFilename("materials/wechat_icon.png")
		local params = {}
		params["level"] = tostring(LevelMapManager.getInstance():getLevelDisplayName(levelId))
		local profile = UserManager.getInstance().profile
		params["headImage"] = ShareUtil:toHeadUrl(profile.headUrl)
		params["nickName"] = profile:getDisplayName()

	ShareUtil:shareByShareId(100000,passLevelShareCallBack,params,thumb,shareTitle,txtToShare, shareSource)
		DcUtil:UserTrack({
			category = "show", 
			sub_category = "show_off_guoguan_button", 
		})
		successFunc = function( ... )
			DcUtil:UserTrack({
				category = "show", 
				sub_category = "show_off_guoguan_success", 
			})
		end
	else
		SnsProxy:shareImage( shareType, shareTitle, txtToShare, imageURL, thumb, passLevelShareCallBack)
	end
end

function SnsUtil.shareAchivment( shareType, achivmentId, onSnapShootFinish, shareCallback, shareSource )
	if WXJPPackageUtil.getInstance():isGuestLogin() then 
		CommonTip:showTip(Localization:getInstance():getText("wxjp.guest.warning.tip"), "negative")
		if shareCallback and type(shareCallback.onCancel) == "function" then
			shareCallback.onCancel()
		end
		return 
	end

	local sdk = WeChatSDK.new()
	local saveFilePath = HeResPathUtils:getUserDataPath() .. "/screen_shoot_"..achivmentId..".png"
	local thumFilePath = HeResPathUtils:getUserDataPath() .. "/screen_shoot_thumb_"..achivmentId..".png"

	if shareType ~= PlatformShareEnum.kWechat then -- 非微信分享，将截图存储到外部存储中，以防第三方app无法直接读取图片
		local exStorageDir = luajava.bindClass("com.happyelements.android.utils.ScreenShotUtil"):getGamePictureExternalStorageDirectory()
		if exStorageDir then
			saveFilePath = exStorageDir .. "/screen_shoot_"..achivmentId..".png"
			thumFilePath = exStorageDir .. "/screen_shoot_thumb_"..achivmentId..".png"
		end
	else
		
	end

	local function onSnapShoot( status )
		if onSnapShootFinish then onSnapShootFinish() end
		
		local succeed = false
		if status == 1 then
			if shareType == PlatformShareEnum.kWechat then
				sdk:sendImageMessage(message, thumFilePath, saveFilePath)
			else
				local shareTitle = Localization:getInstance():getText("share.feed.title"..achivmentId)
				local shareText = Localization:getInstance():getText("share.feed.text"..achivmentId)
				SnsProxy:shareImage( shareType, shareTitle, shareText, saveFilePath, thumFilePath, shareCallback )
			end
		else
			if shareCallback and type(shareCallback.onError) == "function" then
				shareCallback.onError(0, "snap shoot faild!")
			end
		end
	end
	sdk:screenShots(saveFilePath, thumFilePath, onSnapShoot)	
end

function SnsUtil.weeklyRaceShareNo1( shareType, levelId, shareCallback, shareSource)
	local datetime = tostring(os.date("%y%m%d", timer))
	local thumb = CCFileUtils:sharedFileUtils():fullPathForFilename("materials/thumb_main.png")
	local imageURL = string.format("http://static.manimal.happyelements.cn/feed/week_first.jpg?v="..datetime)

	if not shareCallback then -- default callback
		shareCallback = {
			onSuccess = function(result)
				SnsUtil.showShareSuccessTip(shareType)
			end,
			onError = function(errCode, errMsg)
				SnsUtil.showShareFailTip(shareType)
			end,
			onCancel = function()
			end
		}
	end
	SnsUtil.sendImageLinkMessage( shareType, nil, nil, thumb, imageURL, shareCallback, shareSource)
end

function SnsUtil.weeklyRaceShareSurpass( shareType, levelId, shareCallback, shareSource)
	local datetime = tostring(os.date("%y%m%d", timer))
	local thumb = CCFileUtils:sharedFileUtils():fullPathForFilename("materials/thumb_main.png")
	local imageURL = string.format("http://static.manimal.happyelements.cn/feed/week_pass.jpg?v="..datetime)

	if not shareCallback then -- default callback
		shareCallback = {
			onSuccess = function(result)
				SnsUtil.showShareSuccessTip(shareType)
			end,
			onError = function(errCode, errMsg)
				SnsUtil.showShareFailTip(shareType)
			end,
			onCancel = function()
			end
		}
	end
	SnsUtil.sendImageLinkMessage( shareType, nil, nil, thumb, imageURL, shareCallback, shareSource)
end

function SnsUtil.isWeeklyMatchSendToFeeds( ... )
	-- return PlatformConfig:isPlatform(PlatformNameEnum.kIOS) or
	-- 	PlatformConfig:isPlatform(PlatformNameEnum.kHE) or
	-- 	PlatformConfig:isPlatform(PlatformNameEnum.kTF) or 
	-- 	PlatformConfig:isQQPlatform()
	return false
end

function SnsUtil.shareSummerWeeklyMatchFeed( shareType, shareCallback, shareSource)
	local datetime = tostring(os.date("%y%m%d", timer))
	local imageURL = string.format("http://static.manimal.happyelements.cn/feed/spring_weekly_2017_feed.jpg?v="..datetime)
	local index = CCUserDefault:sharedUserDefault():getIntegerForKey("weekly.match.thumb.index")
	-- local pool = {1, 2, 3, 4, 5, 6}
	-- pool = table.filter(pool, function(v) return v ~= index end)
	-- local finIndex = pool[math.random(#pool)]
	-- CCUserDefault:sharedUserDefault():setIntegerForKey("weekly.match.thumb.index", finIndex)
	local thumb
	if shareType == PlatformShareEnum.kMiTalk then
		thumb = CCFileUtils:sharedFileUtils():fullPathForFilename("materials/wechat_icon.png")
	else
		thumb = CCFileUtils:sharedFileUtils():fullPathForFilename("materials/sharethumb_weekly.png")
	end
	if _G.isLocalDevelopMode then printx(0, "thumb", thumb) end
	local uid = UserManager:getInstance().uid
	local inviteCode = UserManager:getInstance().inviteCode
	local platformName = StartupConfig:getInstance():getPlatformName()

	local params = "uid="..tostring(uid)..
		"&invitecode="..tostring(inviteCode).."&pid="..tostring(platformName).."&action=0&ts="..
		tostring(Localhost:time())

	-- local webpageUrl = NetworkConfig:getShareHost() .."autumn_week_match_2016_share.html?uid="..tostring(uid)..
	-- 	"&invitecode="..tostring(inviteCode).."&pid="..tostring(platformName).."&action=0&index="..finIndex.."&ts="..
	-- 	tostring(Localhost:time())
	local title = Localization:getInstance():getText("invite.friend.panel.share.title")
	local message = Localization:getInstance():getText("weekly.race.winter.get.chance.share")

	local webpageUrl
	local toTimeLine
	-- 这些平台用微下载页面 
	if SnsUtil.isWeeklyMatchSendToFeeds() then
		toTimeLine = true
	else
		toTimeLine = false
	end

	if PlatformConfig:isQQPlatform() then
		webpageUrl = NetworkConfig.wxzQQDowanloadURL
		thumb = CCFileUtils:sharedFileUtils():fullPathForFilename("materials/wechat_icon.png")
		
		if toTimeLine then
			title = Localization:getInstance():getText("weekly.race.winter.get.chance.share.wxz")
		else
			message = Localization:getInstance():getText("weekly.race.winter.get.chance.share.wxz")
		end
	elseif PlatformConfig:isPlatform(PlatformNameEnum.kIOS) or
		PlatformConfig:isPlatform(PlatformNameEnum.kHE) or
		PlatformConfig:isPlatform(PlatformNameEnum.kTF) then
		
		webpageUrl = NetworkConfig.wxzHEDowanloadURL
		thumb = CCFileUtils:sharedFileUtils():fullPathForFilename("materials/wechat_icon.png")

		if toTimeLine then
			title = Localization:getInstance():getText("weekly.race.winter.get.chance.share.wxz")
		else
			message = Localization:getInstance():getText("weekly.race.winter.get.chance.share.wxz")
		end
	else
		webpageUrl = NetworkConfig:getShareHost() .."winter_week_match_2016_share.html?" .. params
	end 

	if _G.isLocalDevelopMode then printx(0, webpageUrl) end
	if not shareCallback then -- default callback
		shareCallback = {
			onSuccess = function(result)
				SnsUtil.showShareSuccessTip(shareType)
			end,
			onError = function(errCode, errMsg)
				SnsUtil.showShareFailTip(shareType)
			end,
			onCancel = function()
			end
		}
	end
	if shareType == PlatformShareEnum.kMiTalk then
		SnsUtil.sendImageLinkMessage( shareType, nil, nil, thumb, imageURL, shareCallback, gShareSource.WEEKLY_MATCH)
	else
		SnsUtil.sendLinkMessage( shareType, title, message, thumb, webpageUrl, toTimeLine, shareCallback, gShareSource.WEEKLY_MATCH)
	end
end

function SnsUtil.qixiShare( shareType, levelId, shareCallback)
	local datetime = tostring(os.date("%y%m%d", timer))
	local thumb = CCFileUtils:sharedFileUtils():fullPathForFilename("materials/thumb_main.png")
	local imageURL = string.format("http://static.manimal.happyelements.cn/feed/qixi_success.jpg?v="..datetime)
	
	if not shareCallback then -- default callback
		shareCallback = {
			onSuccess = function(result)
				SnsUtil.showShareSuccessTip(shareType)
			end,
			onError = function(errCode, errMsg)
				SnsUtil.showShareFailTip(shareType)
			end,
			onCancel = function()
			end
		}
	end
	SnsUtil.sendImageLinkMessage( shareType, nil, nil, thumb, imageURL, shareCallback)
end

function SnsUtil.showShareSuccessTip(shareType, text)
	if not text then
		if shareType == PlatformShareEnum.kMiTalk then
			text = Localization:getInstance():getText("share.feed.success.tips.mitalk")
		elseif shareType == PlatformShareEnum.kWechat then
			text = Localization:getInstance():getText("share.feed.success.tips")
		end
	end
	if text then CommonTip:showTip(text, "positive") end
end

function SnsUtil.showShareFailTip(shareType, text)
	if not text then
		if shareType == PlatformShareEnum.kMiTalk then
			text = Localization:getInstance():getText("share.feed.faild.tips.mitalk")
		elseif shareType == PlatformShareEnum.kWechat then
			text = Localization:getInstance():getText("share.feed.faild.tips")
		end
	end
	if text then SnsUtil.addTipsItem(text) end
end

function SnsUtil.showShareCancelTip(shareType, text)
	if not text then
		if shareType == PlatformShareEnum.kMiTalk then
			text = Localization:getInstance():getText("share.feed.cancel.tips.mitalk")
		elseif shareType == PlatformShareEnum.kWechat then
			text = Localization:getInstance():getText("share.feed.cancel.tips")
		end
	end
	if text then SnsUtil.addTipsItem(text) end
end

function SnsUtil.getShareType()
	local shareType = nil
	local delayResume = false
	if PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk) then
		shareType = PlatformShareEnum.kMiTalk
	elseif WXJPPackageUtil.getInstance():isWXJPPackage() then 
		if WXJPPackageUtil.getInstance():isGuestLogin() then 
			shareType = PlatformShareEnum.kJPQQ
		else
			local authorType = SnsProxy:getAuthorizeType()
			if authorType == PlatformAuthEnum.kJPQQ then 
				shareType = PlatformShareEnum.kJPQQ
			elseif authorType == PlatformAuthEnum.kJPWX then 
				shareType = PlatformShareEnum.kJPWX
			end
		end
		delayResume = true
	else
		shareType = PlatformShareEnum.kWechat
		delayResume = true
	end
	return shareType, delayResume
end

--这里是以分享的形式拉起微信小程序
function SnsUtil:launchMiniApp(title, message, thumbPath, appName, appPath, defaultPage, miniType)
	-- body
	-- nprint = nprint or function ( ... )
		-- body
	-- end

	defaultPage = defaultPage or 'http://xxl.happyelements.com/'
	thumbPath = thumbPath or CCFileUtils:sharedFileUtils():fullPathForFilename("materials/xf_thumb.jpg")

	title = title or '【开心消消乐】'
	message = message or '开心消消乐'

	appName = appName or 'gh_c91493f1b28b'
	appPath = appPath or 'pages/index/index?str=eeeeddd'
	-- appPath = appPath or 'pages/wheels/wheels?xxlId=' .. UserManager:getInstance():getInviteCode()

	miniType = miniType or 2

	local ret = false

	if __IOS then
		-- nprint('WeChatProxyBridge begin')
		-- nprint('WeChatProxyBridge view', WeChatProxyBridge.sendMiniAppShare)
		ret = WeChatProxyBridge:sendMiniAppShare(appName, appPath, title, message, thumbPath, defaultPage, miniType)
		-- nprint('WeChatProxyBridge end')
	end
	if __ANDROID then
		local weChatUtil = luajava.bindClass("com.happyelements.hellolua.share.WeChatUtil").INSTANCE
		ret = weChatUtil:launchMiniApp(appName, appPath, title, message, thumbPath, defaultPage, miniType)
	end
	-- nprint('SnsUtil:launchMiniApp', 'ret', ret)
	return ret
end

--这里是真正的拉起微信小程序,  path 拉起小程序页面的可带参路径，不填默认拉起小程序首页
function SnsUtil:launchMiniProgram(path,appName,miniprogramType)
	print('SnsUtil:launchMiniProgram', path,appName,miniprogramType)
	local ret = false

	-- path = path or "pages/index/index"
	appName = appName or 'gh_c91493f1b28b'
	-- 0 是正式版  2是 体验版
	miniprogramType = miniprogramType or 0

	if _G.isLocalDevelopMode then
		miniprogramType = 2
	end

	if __IOS then
		ret = WeChatProxyBridge:launchMiniProgram(path,appName,miniprogramType)
	end
	if __ANDROID then
		local weChatUtil = luajava.bindClass("com.happyelements.hellolua.share.WeChatUtil").INSTANCE
		ret = weChatUtil:launchMiniProgram(path,appName,miniprogramType)
	end
	print('SnsUtil:launchMiniProgram', 'ret:', ret)
	return ret
end

--包是否支持拉起微信小程序
function SnsUtil:isSupportLaunchMiniProgram()
    -- do return false end
    local pf = {
        PlatformNameEnum.kMiTalk,   
        PlatformNameEnum.kDoovPre,   
        PlatformNameEnum.k189Store,   
    }
    for i,v in ipairs(pf) do
        if PlatformConfig:isPlatform(v) then
            return false
        end
    end

    if WXJPPackageUtil and WXJPPackageUtil.getInstance():isWXJPPackage() then 
        -- local authorType = SnsProxy:getAuthorizeType()
        -- if authorType == PlatformAuthEnum.kJPQQ then 
            return false
        -- end
    end

    return true
end