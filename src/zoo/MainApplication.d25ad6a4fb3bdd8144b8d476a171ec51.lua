require "hecore.display.Director"
require "hecore.display.ArmatureNode"

require "hecore.notify.Notify"

require "zoo.util.BigInt"
require "zoo.util.UrlSchemeSDK"
require "zoo.util.ReachabilityUtil"
require "zoo.config.ResourceConfig"
require "zoo.config.NetworkConfig"
require "zoo.util.SignatureUtil"
require "zoo.util.AlertDialogImpl"
require "zoo.util.CaptureAndShareUtil"
require "zoo.data.RecallManager"
require "zoo.data.LocalNotificationManager"
require "zoo.data.WorldSceneShowManager"
require "zoo.data.NotificationGuideManager"
require "zoo.gamePlay.GamePlayMusicPlayer"
require "zoo.payment.logic.PaymentBase"
require "zoo.panel.fcm.FcmManager"
require 'zoo.panel.RealName.RealNameManager'
require "hecore.EmergencySystem"
require "zoo.data.DeviceLoginInfos"
require "zoo.panel.component.friendsRecommend.FriendRecommendManager"
require "zoo.payment.alipay.AlipaySignLogic"
require "zoo.util.WXJPPackageUtil"
require "zoo.data.SyncDataHelper"

require "zoo.permission.PermissionManager"

if __ANDROID then
	require "zoo.util.AndroidEventDispatcher"
	require "zoo.push.PushManager"
end


if _utilsLib then
	if _utilsLib.dragonUseRefCount then
		_utilsLib.dragonUseRefCount(true)
	end
	if _utilsLib.textureUseDynamicMemoryControl then
		_utilsLib.textureUseDynamicMemoryControl(true)
	end
end
if CCTexture2D.enableAnalyzeTextureChannel then
	CCTexture2D:enableAnalyzeTextureChannel(true)
end

CCDirector:sharedDirector():useNewRefreshLogic(true)


-- 解决xml解析不符合格式的内容时导致闪退的问题（第一个<前有其他字符的情况）
_G.ori_xml_eval = _G.ori_xml_eval or xml.eval
local function xml_check(xmlstr)
  if type(xmlstr) == "string" then
    return string.match(xmlstr, "^%s*<") ~= nil
  end
  return false
end
xml.eval = function(xmlstr)
  if xml_check(xmlstr) then
    return _G.ori_xml_eval(xmlstr)
  else
  	local msg = string.sub(tostring(xmlstr), 1, 100) 
  	he_log_error("xml format invalid:"..msg)
    return nil
  end
end

-- kWindowFrameRatio = table.const{
-- 	iPhone5 = {name="iPhone5", r=1136/640}, --1.775
-- 	Note2 = {name="Note2", r=1280 / 800}, --1.6
-- 	iPhone4 = {name="iPhone4", r=960/640}, --1.5
-- 	iPad = {name="iPad", r=1024/768}, --1.333333333
-- }

kGlobalEvents = table.const{
	kSyncFinished = "global.event.sync.done",
	kUserLogin = "global.event.login.done",
	kProfileUpdate = "global.event.profile.change",
	kAcceptFriends = "global.event.messagecenter.friends.accept",
	kMessageCenterUpdate = "global.event.messagecenter.update",
	kGamecenterLogin = "global.event.gc.login",
	kMaintenanceChange = "global.event.maintenance",
	kConsumeComplete = "global.event.consume.complete",
	kDefaultPaymentTypeAutoChange = "global.event.defaultpayment.auto.change",
	kEnterForeground = "global.event.enter.foreground",
	kEnterBackground = "global.event.enter.background",
	kActivityLevelShare = "global.event.activity.level.share",
	kShowReplayRecordPreview = "global.event.replay.preview.show",
	kAliSignAndPayReturn = 'global.event.ali.sign.pay.return',
	kWechatSignReturn = 'global.event.wechat.sign.return',
	kReturnFromGamePlay = 'global.event.return.from.gameplay',
	kExceptionReturnFromGamePlay = 'global.event.exception.return.from.gameplay',
	kSceneNoPanel = 'global.event.scene.no.panel',
	kEnterHomeScene = 'global.event.enter.home.scene',
	kReceiveMemoryWarning = 'global.event.receive.memory.warning',
	kScreenOffsetChanged = 'global.event.offset.changed',
	kUserTakeScreenShot = 'global.event.take.screenshot',
	kEmergency = 'global.event.emergency',
	kSectionResume = 'global.event.section.resume',
	kPassDay = 'global.passDay',
	kUserIconMoved = 'global.event.user.icon.moved',
	kUserDataInit = 'global.event.user.data.init',
}

local function scheduleLocalNotification()
	RecallManager.getInstance():updateRecallInfo()
	-- LocalNotificationManager.getInstance():pocessRecallNotification()
	LocalNotificationManager.getInstance():setEnergyFullNotification()
	LocalNotificationManager.getInstance():validateNotificationTime()
	LocalNotificationManager.getInstance():pushAllNotifications()
end

local function getPreloadingScene()
	if WXJPPackageUtil.getInstance():isWXJPPackage() then 
		return require("zoo.loader.JPPreloadingScene")
	else
		return require("zoo.loader.PreloadingScene")
	end
end

--[[
local function freeAudioCheckingHWND()
    if __ANDROID then
		print("free audioplayinplicit")
	    pcall(function()
	        local mainActivityHolder = luajava.bindClass("com.happyelements.android.MainActivityHolder")
	        local mainActivity = mainActivityHolder.ACTIVITY
	        local service = luajava.bindClass("com.happyelements.test.TestService")
	        local serviceClass = service:getPrimitive()
	        local intent = luajava.newInstance("android.content.Intent", mainActivity, serviceClass)
	        local codes = 
	          "local function __()\n" ..
	          "local a=luajava.bindClass(\"com.happyelements.test.TestServiceUtils\")\n" ..
	          "a:stopCheckAudioPlay()\n" ..
	          "print('audioplayinplicit, codes done')\n" ..
	          "end\n" ..
	          "pcall(__)\n"
	        intent:putExtra("intentinformation", codes);
	        print("audioplayinplicit stop intent sent")
	        mainActivity:startService(intent)

		    local applicationContext = mainActivity:getApplicationContext()
		    local filepath = applicationContext:getFilesDir():getAbsolutePath() .. '/_checkAudioPlay.txt'
		    local hFile, err = io.open(filepath, "r")
		    if hFile and not err then
				io.close(hFile)
				os.remove(filepath)
		    	he_log_error("found audioplayinplicit")
		    	print("found audioplayinplicit")
		    else
		    	print("not found audioplayinplicit")
		    end
    	end)
    end
end
local function createAudioCheckingHWND()
    if __ANDROID then
		if not _G.isLocalDevelopMode and math.random() < 0.99 then
			return
		end
		print("start audioplayinplicit")
	    pcall(function()
	        local mainActivityHolder = luajava.bindClass("com.happyelements.android.MainActivityHolder")
	        local mainActivity = mainActivityHolder.ACTIVITY
	        local service = luajava.bindClass("com.happyelements.test.TestService")
	        local serviceClass = service:getPrimitive()
	        local intent = luajava.newInstance("android.content.Intent", mainActivity, serviceClass)
	        local codes = 
	          "local function __()\n" ..
	          "local a=luajava.bindClass(\"com.happyelements.test.TestServiceUtils\")\n" ..
	          "a:startCheckAudioPlay()\n" ..
	          "print('audioplayinplicit, codes done')\n" ..
	          "end\n" ..
	          "pcall(__)\n"
	        intent:putExtra("intentinformation", codes);
	        print("audioplayinplicit start intent sent")
	        mainActivity:startService(intent)
	    end)
    end
end
]]


_G.inBackgroundElapsedSeconds = 0
local enterBackgruondStartTime = 0
local function onApplicationDidEnterBackground()
	if _G.isLocalDevelopMode then printx(0, "onApplicationDidEnterBackground") end
	local scene = Director:sharedDirector():getRunningScene()
	if scene and scene.onEnterBackground then
		scene:onEnterBackground()
	end

	if _G.kResourceLoadComplete then
		GamePlayMusicPlayer:getInstance():enterBackground()
	end

	GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(kGlobalEvents.kEnterBackground))

	--微信sdk没登录的情况下返回没回调
	-- if _G.WeChatSDK then
	-- 	WeChatSDK:removeLoading()
	-- end
	enterBackgruondStartTime = os.time()
	DcUtil:saveLogToLocal() --把打点数据写到本地
	if _G.kResourceLoadComplete then
		-- 在Meta初始化之前如果有弹框触发了该方法，会导致初始化出错
		pcall(scheduleLocalNotification)
	end

    if not freeTextureStateGroup:actived() and scene and _G.freeTextureWhileApp2Background and _G.__isLowDevice then
	    HomeScene_freeUnuseInGameTextureMinSize(512*1024)
	    scene:cacheHomeSceneGeneralMask()
	    freeTextureStateGroup:set('background', true)
    end
	-- freeTextureScenario:set('background', true)

	forceGcMemory(true)
	if __disposeTextureOnBackground then __disposeTextureOnBackground() end
    if __ANDROID then
        local disp = luajava.bindClass("com.happyelements.hellolua.share.DisplayUtil")
        if(true)then
			print("app used memory: " .. disp:getAppUsedMemory() / (1024))
            print("sys used memory: " .. disp:getSysUsedMemory() / (1024 * 1024))
            print("sys free memory: " .. disp:getSysFreeMemory() / (1024 * 1024))
        end
    end

	-- createAudioCheckingHWND()
end

local function freeHomeSceneMask(scene)
    local timer = 0
    local tickHandler = nil

    local function onRestoreTexture()
        if timer < 60 then
            if timer == 30 then
				if(scene:is(GamePlaySceneUI) or scene:is(NewGamePlaySceneUI)) then
	                HomeScene_restoreUnuseInGameTexture(false, _G.homescene_last_freetexture_list)
				else
                	HomeScene_restoreUnuseInGameTexture(false)
				end
            end
            timer = timer + 1
            return
        end

        if(tickHandler) then
            CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(tickHandler)
            tickHandler = nil
        end

        scene:freeLeaveScreenMask()
	    freeTextureStateGroup:set('background', false)
	    -- _G.freeTextureWhileApp2Background = true
    end

    -- _G.freeTextureWhileApp2Background = false
    tickHandler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onRestoreTexture, 0, false)
end

local function updateAppActiveTime()
	if __ANDROID then
		local AndroidKeyChainUtils = luajava.bindClass("com.happyelements.android.AndroidKeyChainUtils")
		AndroidKeyChainUtils:setKeyChain("animal", "last_active_time", tostring(Localhost:timeInSec()))
	end
end

local function onApplicationWillEnterForeground()
	if _G.isLocalDevelopMode then printx(0, "wenkan onApplicationWillEnterForeground") end
	local scene = Director:sharedDirector():getRunningScene()

	if scene then 
		local popoutPanel = PopoutManager:sharedInstance():getLastPopoutPanel()
		if popoutPanel and type(popoutPanel.onEnterForeGround) == "function" then
			popoutPanel:onEnterForeGround()
		end
	end

	if scene and scene.onEnterForeGround then
		if _G.isLocalDevelopMode then printx(0, "scene:onEnterForeGround()") end
		scene:onEnterForeGround()
	end

	if scene then 
		PaymentCheckManager.getInstance():startPaymentCheck()
	end

	if _G.kResourceLoadComplete then
		GamePlayMusicPlayer:getInstance():enterForeground()
	end

	if _G.kUserLogin then
		DcUtil:dailyUser()
		DcUtil:logLocation()
		DcUtil:logInGame()
	end

	if scene and (scene.name == 'PreloadingScene' or scene.name == 'JPPreloadingScene') then
		return
	end

	if _G.kResourceLoadComplete then
		-- 参考onApplicationDidEnterBackground
		LocalNotificationManager.getInstance():cancelAllAndroidNotification()
		LocalNotificationManager.getInstance():validateNotificationTime()
	end
	_G.inBackgroundElapsedSeconds = os.time() - enterBackgruondStartTime

	GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(kGlobalEvents.kEnterForeground))

	SupperAppManager:checkData()

	-- 1秒之内收不到openUrl事件，才认为支付取消
	local function onAppPaymentReturn()
		if __ANDROID then
			GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(kGlobalEvents.kAliSignAndPayReturn, {url = 'happyanimal3://aliapp_return/redirect'}))
		end
		if __ANDROID and WechatQuickPayLogic then
			if WechatQuickPayLogic:getInstance():isWaitingWechatApp() then
				GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(kGlobalEvents.kWechatSignReturn))
			end
		end

		if RealNameManager.isCallSDK and RealNameManager.payFailCallback then 
          	RealNameManager.payFailCallback()
        end
	end
	setTimeOut(onAppPaymentReturn, 1)

	if _G.isLocalDevelopMode then printx(0, "onApplicationWillEnterForeground: "..tostring(inBackgroundElapsedSeconds)) end

	require 'zoo.panel.broadcast.BroadcastManager'
	BroadcastManager:getInstance():onHomeKey()

	require "zoo.panel.incite.InciteManager"
	InciteManager:onEnterForground()

	updateAppActiveTime()
	FcmManager:start()

	if __disposeTextureOnForeground then __disposeTextureOnForeground() end
	if scene and freeTextureStateGroup:get('background') then
		freeHomeSceneMask(scene)
	end
	-- freeTextureScenario:set('background', false)

	-- freeAudioCheckingHWND()
end


local function dcAutoAddFriend( launchURL )
	--个人名片分享出去的

	if launchURL and string.starts(launchURL,"happyanimal3://add_friend/redirect") then

	end
end
-- 炫耀点回打点
local function dcShowOff( launchURL )
	if launchURL and string.starts(launchURL,"happyanimal3://show_off/redirect") then
		require "zoo.util.UrlParser"
		local res = UrlParser:parseUrlScheme(launchURL)
		if res and type(res.para) == "table" and res.para.textid then
			DcUtil:UserTrack({
				category = "show", 
				sub_category = "show_off_into_text", 
				t1 = res.para.textid
			})
		end
	end
end

-- dc for share back to game
local function dcShareBack( launchURL )
	if type(launchURL) == "string" and string.len(launchURL) > 0 then
		require "zoo.util.UrlParser"
		local res = UrlParser:parseUrlScheme(launchURL)
		if res and not res.method then return end
		--dc
		if res.method == "wxshare_dc" and res.para and type(res.para) == "table" then
			DcUtil:activity( res.para )
		end
	end
end

local function dcOpenUrl( launchURL )
	if type(launchURL) ~= "string" or string.len(launchURL) == 0 then
		return
	end

	require "zoo.util.UrlParser"
	local urlSp = {}
	-- "happyanimal3://week_match/redirect?key=val&k2=1"
	for v in string.gmatch(launchURL, "[^?]+") do
		table.insert(urlSp, v)
	end
	local params = {}
	params.category = "scheme"
	params.sub_category = "open"
	params.url_type = "" 		-- Scheme | UniversalLink
	params.url_host = urlSp[1] 	-- "happyanimal3://week_match/redirect"
	params.raw_para = urlSp[2] 	-- "key=val&k2=1"

	local res = UrlParser:parseUrlScheme(launchURL)
	if res and res.urlType then
		params.url_type = res.urlType
		if type(res.para) == "table" then
			for k, v in pairs(res.para) do
				params[k] = v
			end
		end
	end
	
	if res and type(res.para) == "table" then
		__launch_para = res.para
	end

	DcUtil:activity(params)
end

_G.launchURL = UrlSchemeSDK.new():getCurrentURL()
dcOpenUrl(_G.launchURL)
dcShowOff(_G.launchURL)
dcShareBack(_G.launchURL)
dcAutoAddFriend(_G.launchURL)


local function onApplicationHandleOpenURL()
	local sdk = UrlSchemeSDK.new()
	local launchURL = sdk:getCurrentURL()

	dcOpenUrl(launchURL)
	-- before handle launchURL
	AlipaySignLogic.getInstance():beforeApplicationHandleOpenURL(launchURL)

	-- handle launchURL
	local res = UrlParser:parseUrlScheme(launchURL)

	if type(res.para) == "table" then
		__launch_para = res.para
	end

	if type(res.para) == "table" and res.para.aaf and res.para.uid and res.para.invitecode and res.para.pid then
		if res.para.pid ~= "wechat_android" and not WXJPPackageUtil.getInstance():isWXJPPackage() then 
			local invitecode = tonumber(res.para.invitecode) or 0
			if UserManager:getInstance():isSameInviteCodePlatform(invitecode) then
				local failCallback
				if _G.isLocalDevelopMode then 
					failCallback = function (errCode)
						local err = errCode or -1
						DcUtil:autoAddFriendFailReason(err)
					end
				end
				if tonumber(res.para.aaf) == ADD_FRIEND_SOURCE.AUTOADDFRIEND then
					
				else
					require "zoo.panelBusLogic.AutoAddFriendLogic"
					local logic = AutoAddFriendLogic:create()
					logic:start(res.para.uid, res.para.aaf, nil, failCallback)
				end
				
			else
				if _G.isLocalDevelopMode then DcUtil:autoAddFriendFailReason(10120) end
			end
		else
			if _G.isLocalDevelopMode then DcUtil:autoAddFriendFailReason(10121) end
		end
	else
		if _G.isLocalDevelopMode then DcUtil:autoAddFriendFailReason(10122) end
	end

	if _G.isLocalDevelopMode then printx(0, "onApplicationHandleOpenURL:"..tostring(launchURL)) end
	if launchURL and string.starts(launchURL, 'happyanimal3://aliapp_return/redirect') then
		GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(kGlobalEvents.kAliSignAndPayReturn, {url = launchURL}))
		return
	end

	if launchURL and AlipaySignLogic.getInstance():onApplicationHandleOpenURL(launchURL) then
		return
	end

	if launchURL and string.starts(launchURL, "happyanimal3://zhima/redirect") then
		local function zhimaCallback()
			RealNameManager:setCallSDK(false)
			RealNameManager:setAuthing(true)

			local zhima = UrlParser:parseUrlScheme(launchURL)
			if zhima and zhima.para and type(zhima.para) == "table" and zhima.para.params and zhima.para.sign then
				PaymentNetworkCheck.getInstance():check(function ()
	                local Http = require 'zoo.panel.RealName.Http'
	               	Http:sendZhimaCertifyResult(zhima.para.params, zhima.para.sign, function(evt)
	                	if evt and evt.data and evt.data.passed then
	                		RealNameManager:getRealNameReward(1, true, RealNameRewardType.idcard)
	                	else
	                		RealNameManager:getRealNameReward(2, true, RealNameRewardType.idcard)
	                	end
	                	RealNameManager:setAuthing(false)
	                end, function (errorCode, errMsg, data)
	                	RealNameManager:setAuthing(false)
	       				CommonTip:showTip(localize('error.tip.-1000061'), 'negative')
	    			end)
	            end, function ()
	            	RealNameManager:setAuthing(false)
	            	RealNameManager:setDcData("verify", -2)
	            	RealNameManager:dc()
	                CommonTip:showTip(localize("authentication.feature.id.fail2"), 'negative')
	            end)
			end
		end
		local scene = Director:sharedDirector():getRunningScene()
		if scene then
			scene:runAction(CCCallFunc:create(zhimaCallback))
		end
	end

	-- 炫耀点回打点
	dcShowOff(launchURL)
	dcShareBack(launchURL)

	local scene = Director:sharedDirector():getRunningScene()
	if scene and scene.onApplicationHandleOpenURL then
		if _G.isLocalDevelopMode then printx(0, "scene:onApplicationHandleOpenURL()") end
		scene:onApplicationHandleOpenURL(launchURL)
	end
end

local function onApplicationHandleFBOpenURL()
	local dict = AppController:getOpenURLDict()
	if dict and dict.type and dict.fb_action_ids and dict.fb_action_types then 
		DcUtil:logViralActivate(dict.type,dict.fb_action_ids,dict.fb_action_types)
	else 
		if _G.isLocalDevelopMode then printx(0, "onApplicationHandleFBOpenURL false") end 
	end
end

local function onUserLogin( event )

	local profile = UserManager.getInstance().profile

	local displayName = CCUserDefault:sharedUserDefault():getStringForKey(getDeviceNameUserInput())
	if profile and displayName and displayName ~= "" and not profile:haveName() then
		local http = UpdateProfileHttp.new()
		profile:setDisplayName(displayName)

        local snsPlatform = nil
        local snsName = nil
        local authorizeType = SnsProxy:getAuthorizeType()
        if _G.sns_token then
            snsPlatform = PlatformConfig:getPlatformAuthName(authorizeType)
            if authorizeType ~= PlatformAuthEnum.kPhone then
                snsName = profile:getDisplayName()
            else
                snsName = Localhost:getLastLoginPhoneNumber()
            end

           	profile:setSnsInfo(authorizeType,snsName,profile.headUrl,profile:getDisplayName(),profile.headUrl)
        end

		http:load(profile.name, profile.headUrl,snsPlatform,HeDisplayUtil:urlEncode(snsName), false)
	end
end

local function calculateFrameRatio()
	local frame = CCDirector:sharedDirector():getOpenGLView():getFrameSize()
	local currentRatio = frame.height/frame.width
	-- local selectedRatio = 1.6
	-- local selectedRatioKey = "Note2"
	-- for k,v in pairs(kWindowFrameRatio) do
	-- 	local curDiff = math.abs(v.r - currentRatio)
	-- 	local selDiff = math.abs(v.r - selectedRatio)
	-- 	if curDiff < selDiff then 
	-- 		selectedRatio = v.r
	-- 		selectedRatioKey = v.name
	-- 	end
	-- end
	_G.__frame_key = ""

	_G.__frame_ratio = currentRatio

	-- 是否为宽屏，暂定__frame_ratio<1.49 。目前最窄的pad为pad pro：1.43 再窄的就是 iphone4：1.5
	_G.__isWildScreen = currentRatio < 1.49
	-- 是否大尺寸设备，大屏幕有时需要单独缩小一些UI
	_G.__isLargeScreen = _G.__isWildScreen

	if _G.isLocalDevelopMode then printx(0, "Frame Ratio: "..tostring(_G.__frame_key).." small res:"..tostring(_G.__use_small_res)) end

	-- RemoteDebug:uploadLogWithTag('FrameRatio()'.. tostring(__frame_ratio) ,selectedRatioKey,currentRatio,frame.height,frame.width)
end

local function popoutInvalidSignatrueAlert()
	local function onTouchRedirectButton()
		local openUrl = "http://xxl.happyelements.com/"
		if __ANDROID and PlatformConfig:isQQPlatform() then 
			openUrl = NetworkConfig.qqDownloadURL
		end
		luajava.bindClass("com.happyelements.android.utils.HttpUtil"):openUri(openUrl)
		Director.sharedDirector():exitGame()
	end
	AlertDialogImpl:alert( "ERROR!", Localization:getInstance():getText("update.panel.unsigned.apk"), 
		Localization:getInstance():getText("button.ok"), nil, onTouchRedirectButton, nil, onTouchRedirectButton)
end

local function isAndroidDeviceLocked()
	local deviceStateChecker = luajava.bindClass("com.happyelements.android.utils.DeviceStateChecker"):getInstance()
	return deviceStateChecker:isScreenLocked()
end

local function resumeGameMusic()
	local canResumeMusic = true
	if __ANDROID and _G.needCheckMusicCanPlay then
		local status, locked = pcall(isAndroidDeviceLocked)
		-- if _G.isLocalDevelopMode then printx(0, ">>>>>>>>>>>>>>>> resumeGameMusic:", status, ",", locked) end
		if status and locked then canResumeMusic = false end
	end
	if canResumeMusic then GamePlayMusicPlayer:getInstance():appResume() end
end


local _leaveScreenMaskLayer = nil
local function freeLeaveScreenMask()
	if(_leaveScreenMaskLayer) then
		_leaveScreenMaskLayer:removeFromParentAndCleanup(true)
		_leaveScreenMaskLayer = nil
	end
end
local function addCacheMaskToScene(sprite)
    freeLeaveScreenMask()

	local visibleSize = CCDirector:sharedDirector():getVisibleSize()

	_leaveScreenMaskLayer = Layer:create()
	Director:getRunningSceneLua():addChild(_leaveScreenMaskLayer, SceneLayerShowKey.TOP_LAYER)
	_leaveScreenMaskLayer:setTouchEnabled(true, 0, true)
	_leaveScreenMaskLayer.hitTestPoint = function(self, worldPosition, useGroupTest)
		return true
	end

	_leaveScreenMaskLayer:addChild(sprite)
end
local function cacheHomeScene()
	print("cache home scene")

	local visibleSize = CCDirector:sharedDirector():getVisibleSize()
	local GL_DEPTH24_STENCIL8 = 0x88F0  --c++中定义的
	local renderTexture = CCRenderTexture:create(visibleSize.width, visibleSize.height, kCCTexture2DPixelFormat_RGBA8888, GL_DEPTH24_STENCIL8)
	renderTexture:setPosition(ccp(visibleSize.width/2, visibleSize.height/2))
--	renderTexture:beginWithClear(255, 255, 255, 0)
	renderTexture:begin()
	Director:getRunningSceneLua():visit()
	renderTexture:endToLua()

	if(__WIN32 and true) then
		local filePath = HeResPathUtils:getUserDataPath() .. "/_screenShot.png"
		renderTexture:saveToFile(filePath)
	end

	local texture = renderTexture:getSprite():getTexture()
	local sprite = Sprite:createWithTexture(texture)
--	sprite:adjustColor(0, -0.5, 0, 0)
--	sprite:applyAdjustColorShader()
	sprite:setScaleY(-1)
	sprite:setPosition(ccp(visibleSize.width/2, visibleSize.height/2))

	addCacheMaskToScene(sprite)

	local mask = LayerColor:create()
	mask:changeWidthAndHeight(visibleSize.width, visibleSize.height)
	mask:setColor(ccc3(0, 0, 0))
	mask:setOpacity(200)
	mask:setPosition(ccp(0, 0))
	_leaveScreenMaskLayer:addChild(mask)

--	local loading = CountDownAnimation:createNetworkAnimation(nil)
--	_leaveScreenMaskLayer:addChild(loading)

end


local function onAppResume()
--[[
	local tickHandler = nil
	local function onRestoreTexture()
		_textureLib.rollback_pause_resume()
		freeLeaveScreenMask()

	    if __ANDROID then
	        local disp = luajava.bindClass("com.happyelements.hellolua.share.DisplayUtil")
	        if(true)then
				print("app used memory: " .. disp:getAppUsedMemory() / (1024))
	            print("sys used memory: " .. disp:getSysUsedMemory() / (1024 * 1024))
	            print("sys free memory: " .. disp:getSysFreeMemory() / (1024 * 1024))
	        end
	    end

		if(tickHandler) then
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(tickHandler)
			tickHandler = nil
		end

	end
	tickHandler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onRestoreTexture, 0, false)
]]

	if _G.isLocalDevelopMode then printx(0, "onAppResume") end
	
	if _G.kResourceLoadComplete then
		resumeGameMusic()
		SupperAppManager:checkData()
	end

end

_G._allowFreeTextureOnPauseApp = true
local function onAppPause()

--[[
	if(_G._allowFreeTextureOnPauseApp 
		and (__ANDROID or __WIN32)
		and isSystemLowMemory() 
		and MaintenanceManager:getInstance():isEnabled("allowFreeTextureOnPauseApp", false)
		) then
		print("memory: free memory while app pause")
--		cacheHomeScene()
		_textureLib.hide_pause_resume()
	end
]]
	forceGcMemory(true)

    if __ANDROID then
        local disp = luajava.bindClass("com.happyelements.hellolua.share.DisplayUtil")
        if(true)then
			print("app used memory: " .. disp:getAppUsedMemory() / (1024))
            print("sys used memory: " .. disp:getSysUsedMemory() / (1024 * 1024))
            print("sys free memory: " .. disp:getSysFreeMemory() / (1024 * 1024))
        end
    end

	if _G.isLocalDevelopMode then printx(0, "onAppPause") end
	
	if _G.kResourceLoadComplete then
		GamePlayMusicPlayer:getInstance():appPause()
	end

end

local function onReceiveMemoryWarning()
	if _G.isLocalDevelopMode then printx(0, "onReceiveMemoryWarning") end
	GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(kGlobalEvents.kReceiveMemoryWarning))

	-- DcUtil:memoryWarning(true)
end

local function onUserDidTakeScreenshot()
	if _G.isLocalDevelopMode then printx(0, "onUserDidTakeScreenshot") end
	GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(kGlobalEvents.kUserTakeScreenShot))
end

local function registerNotificationHandler()
	local function handleNotificationCenter( eventType, param )
		if eventType == "APP_ENTER_BACKGROUND" then onApplicationDidEnterBackground()
		elseif eventType == "APP_ENTER_FOREGROUND" then onApplicationWillEnterForeground()
		elseif eventType == "APP_OPEN_URL" then onApplicationHandleOpenURL()
		elseif eventType == "FB_OPEN_URL" then onApplicationHandleFBOpenURL()
		elseif eventType == "APP_RESUMED" then onAppResume()
		elseif eventType == "APP_PAUSE" then onAppPause()
		elseif eventType == "DID_RECEIVE_MEMORY_WARNING" then onReceiveMemoryWarning() --IOS
		elseif eventType == "DID_TAKE_SCREENSHOT" then onUserDidTakeScreenshot()
		elseif eventType == "CAPTURE_AND_SHARE_FRIENDS" then CaptureAndShareUtil.onShareFriends(param)
		elseif eventType == "CAPTURE_AND_SHARE_CIRCLEFRIENDS" then CaptureAndShareUtil.onShareCircleFriends(param)
		else
			if _G.isLocalDevelopMode then printx(0, "Warning: Unhandled Notification, event type:", eventType) end
		end
	end
	CCNotificationCenter:sharedNotificationCenter():registerScriptObserver(handleNotificationCenter)
end

local function queryDevicesLoginInfo()
	local function callback(success, data)
		if success then
			DeviceLoginInfos:setCurrentServerLoginInfos(data)
		end
	end
	DeviceLoginInfos:requestDeviceLoginInfo(NetworkConfig.dynamicHost, callback)
end

__IS_TOTAY_FIRST_LOGIN = false;

local function runGame()
	if _G.isLocalDevelopMode then printx(0, "runGame()") end
	
	_G.kDeviceID = UdidUtil:getUdid()

	-- if PlatformConfig:isPlatform(PlatformNameEnum.kJinliPre) then
	-- 	_G.needCheckMusicCanPlay = true
	-- end
	_G.needCheckMusicCanPlay = true
	
	if not PrepackageUtil:isPreNoNetWork() then
		queryDevicesLoginInfo()
	end
	calculateFrameRatio()
	if __ANDROID then
		GspProxy:init()
		
		local function initAndroidEventDispatchCenter()
			AndroidEventDispatcher:getInstance():initDispatcher()
			if _G.needCheckMusicCanPlay then
				local SCREEN_ON = "ScreenStateChangeBroadcastReceiver.SCREEN_ON"
				local SCREEN_OFF = "ScreenStateChangeBroadcastReceiver.SCREEN_OFF"
				local USER_PRESENT = "ScreenStateChangeBroadcastReceiver.USER_PRESENT"
				local DID_RECEIVE_MEMORY_WARNING = "DID_RECEIVE_MEMORY_WARNING"
				AndroidEventDispatcher:getInstance():addEventListener(SCREEN_ON, resumeGameMusic)
				AndroidEventDispatcher:getInstance():addEventListener(USER_PRESENT, resumeGameMusic)
				AndroidEventDispatcher:getInstance():addEventListener(DID_RECEIVE_MEMORY_WARNING, onReceiveMemoryWarning)
			end
		end
		pcall(initAndroidEventDispatchCenter)
		pcall(function() 
			_G.__CMGAME_TISHEN = luajava.bindClass("com.happyelements.hellolua.StartupConfig"):isCmgameTiShen()
			end)

		PushManager:initSDK()
	end

	RealNameManager:init()
	local PreloadingScene = getPreloadingScene()
	Director:sharedDirector():replaceScene(PreloadingScene:create())
	FcmManager:showLoadingTip() 
	
	registerNotificationHandler()
	
	GlobalEventDispatcher:getInstance():addEventListener(kGlobalEvents.kUserLogin, onUserLogin)

	if __IOS then
		require "zoo.util.IosPayment"
		IosPayment:registerCallback();
	end

	local function dcOnline()
		DcUtil:online()
	end
	CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(dcOnline, 300, false)

	local date = os.date('*t', Localhost:time() / 1000)
    local dateKey = string.format('%d.%d.%d', date.year, date.month, date.day)
    __IS_TOTAY_FIRST_LOGIN = not CCUserDefault:sharedUserDefault():getBoolForKey(dateKey);
    if __IS_TOTAY_FIRST_LOGIN then
    	CCUserDefault:sharedUserDefault():setBoolForKey(dateKey, true)
    	CCUserDefault:sharedUserDefault():flush();
    end
    if _G.isLocalDevelopMode then printx(0, "__IS_TOTAY_FIRST_LOGIN: ", __IS_TOTAY_FIRST_LOGIN) end;
end

if PlatformConfig:isPlatform(PlatformNameEnum.kCUCCWO) then
	local panel = (require "zoo.panel.CuccwoPanel"):create(runGame)
	panel:popout()
else
	runGame()
end

if __WP8 then 
  Wp8Utils:AskForLockScreenSet(1)
  Wp8Utils:TryCreateHomeLink(2)
end

if __ANDROID then 
    local function startGcnAlarm()
        local MainActivity = luajava.bindClass("com.happyelements.hellolua.MainActivity")
        if not PushManager:isSystemPushOpen() then 
        	MainActivity:startGcnAlarm()
        end
        MainActivity:initX5Environment()
    end
    if not PrepackageUtil:isPreNoNetWork() then
        pcall(startGcnAlarm)
    end
    _G.needCallCmgameExit = true -- (_G.kDefaultCmPayment == 9) -- 基地签名包
end
return true