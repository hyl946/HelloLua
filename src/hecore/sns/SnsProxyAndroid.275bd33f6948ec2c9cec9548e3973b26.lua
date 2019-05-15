require "hecore.sns.SnsCallbackEvent"
require "hecore.luaJavaConvert"
require "zoo.data.MetaManager"

assert(__ANDROID, "must be android platform")

SnsProxy = {profile = {}}

local authorProxy = luajava.bindClass("com.happyelements.hellolua.aps.proxy.APSAuthorizeProxy"):getInstance()
local shareProxy = luajava.bindClass("com.happyelements.hellolua.aps.proxy.APSShareProxy"):getInstance()

local function buildError(errorCode, extra)
    return { errorCode = errorCode, msg = extra }
end

local function buildCallback(callback, resultParser)
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
        if resultParser ~= nil and result ~= nil then
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

function convertToInvokeCallback(callback)
    return luajava.createProxy("com.happyelements.android.InvokeCallback", {
        onSuccess = callback.onSuccess,
        onError = callback.onError,
        onCancel = callback.onCancel
    })
end

local function reInitUnicomAndNotUsed()
    local unicomEnbale = MaintenanceManager:getInstance():isEnabled("UnicomSdk")
    if unicomEnbale then
        local num = MaintenanceManager:getInstance():getValue("UnicomSdk")
        if num == nil then num = 0 end
        num = tonumber(num)

        local uid = UserManager.getInstance().user.uid
        uid = tonumber(uid)

        unicomEnbale = uid and (uid % 100) < num
    end

    local payment = PaymentBase:getPayment(Payments.CHINA_UNICOM)

    if unicomEnbale and not payment:isEnabled() then 
        local function initSDK()
            local unicom = luajava.bindClass("com.happyelements.android.operatorpayment.uni.UniPayment")
            unicom:initSDK()
        end
        pcall(initSDK)
    end
end

--重新开启或关闭支付方式
function SnsProxy:reConfigPayments()
    if type(PlatformConfig.paymentConfig) == "table" and table.exist(PlatformConfig.paymentConfig, Payments.QQ_WALLET) then
        local payment = PaymentBase:getPayment(Payments.QQ_WALLET)
        if payment then 
            payment:setEnabled(MaintenanceManager:getInstance():isEnabled("QqWalletFeature"))
        end
    end

    --提升联通SDK启动量,并不参与支付
    -- setTimeOut(reInitUnicomAndNotUsed, 600)
end

function SnsProxy:initPlatformConfig()
    if _G.isLocalDevelopMode then printx(0, "initPlatformConfig:"..PlatformConfig.name) end

    require "hecore.sns.aps.AndroidPayment"
    require "hecore.sns.aps.AndroidAuthorize"
    require "hecore.sns.aps.AndroidShare"

    AndroidAuthorize.getInstance():initAuthorizeConfig(PlatformConfig.authConfig)
    AndroidAuthorize.getInstance():initAuthorizeConfig(PlatformConfig.mergeToAuthConfig)
    AndroidPayment.getInstance():initPaymentConfig(PlatformConfig.paymentConfig)
    AndroidShare.getInstance():initShareConfig(PlatformConfig.shareConfig)

    if PlatformConfig:isPlatform(PlatformNameEnum.kCMGame) then
        -- 移动"和"游戏基地
        local cmgamePayment = luajava.bindClass("com.happyelements.android.operatorpayment.cmgame.CMGamePayment"):getInstance()
        -- enable or disable music and sound according to CMGame setting
        local isMusicEnabled = cmgamePayment:isMusicEnabled()
        local config = CCUserDefault:sharedUserDefault()
        config:setBoolForKey("game.disable.background.music", not isMusicEnabled)
        config:setBoolForKey("game.disable.sound.effect", not isMusicEnabled)
        config:flush()
    end
    
    if AndroidPayment.getInstance():isPaymentTypeSupported(Payments.QIHOO) 
        or AndroidPayment.getInstance():isPaymentTypeSupported(Payments.QIHOO_WX) 
        or AndroidPayment.getInstance():isPaymentTypeSupported(Payments.QIHOO_ALI) then -- 设置支付回调地址，方便修改和测试。默认为线上值
        local qihooConfig = luajava.bindClass("com.happyelements.android.platform.qihoo.QihooConfig")
        qihooConfig:setRefreshPayTokenUrl(NetworkConfig.dynamicHost .. "payment/refreshQihooPayToken")
        qihooConfig:setNotifyUrl(NetworkConfig.dynamicHost .. "payment/qihoo")
        
        if StartupConfig:getInstance():isLocalDevelopMode() then
            qihooConfig:setNotifyUrl("http://well.happyelements.net/mobile/payment/qihoo")
        end
    end 

    authorProxy:setAuthorizeType(AndroidAuthorize.getInstance():getDefaultAuthorizeType())
end

function SnsProxy:setAuthorizeType( authorType )
    authorProxy:setAuthorizeType(authorType)
end

function SnsProxy:getAuthorizeType()
    return authorProxy:getAuthorizeType()
end

-- called
function SnsProxy:isLogin()
    if _G.isLocalDevelopMode then printx(0, "SnsProxy:isLogin") end
    if PrepackageUtil:isPreNoNetWork() then return false end
    
    local lastLoginUser = Localhost.getInstance():getLastLoginUserConfig()
    if _G.isLocalDevelopMode then printx(0, "lastLoginUser. " .. table.tostring(lastLoginUser)) end
    if not lastLoginUser then
        return false
    end

    local userData = Localhost.getInstance():readUserDataByUserID(lastLoginUser.uid)
    -- if _G.isLocalDevelopMode then printx(0, "userData:"..table.tostring(userData)) end
    if userData and userData.openId then
        if _G.isLocalDevelopMode then printx(0, "userData.snsType:"..table.tostring(userData.authorType)) end
        local authorType = WXJPPackageUtil.getInstance():getLastLoginPF()
        if authorType then 
            self:setAuthorizeType(authorType)
        else
            if not userData.authorType then return false end
            self:setAuthorizeType(userData.authorType) -- 使用上次登陆的平台进行判断
        end
        return authorProxy:isLogin()
    end

    return false
end

function SnsProxy:getAccountInfo()
    local loginCacheTable = {}
    local loginCacheMap = authorProxy:getAccountInfo()
    if loginCacheMap then 
        loginCacheTable = luaJavaConvert.map2Table(loginCacheMap)
    end
    return loginCacheTable
end

function SnsProxy:silentLogin()
    if PlatformConfig:isPlatform(PlatformNameEnum.k360) then
        local function safe_silent_login_360()
            local delegate = authorProxy:getAuthorizeDelegate()
            delegate:silentLogin()
        end
        pcall(safe_silent_login_360)
    end
end

-- login
function SnsProxy:login(callback)
    if self:getAuthorizeType() == PlatformAuthEnum.kWechat and not SnsProxy:isWXAppInstalled() then
        if type(callback) == "function" then 
            callback(SnsCallbackEvent.onCancel)
        elseif type(callback) == "table" then
            if callback.onCancel then callback.onCancel() end
        end
        CommonTip:showTip(localize("error.no.wechat1"),"negative")
        return
    end
    local authorDelegate = authorProxy:getAuthorizeDelegate()
    if _G.isLocalDevelopMode then printx(0, "authorDelegate:") end
    if _G.isLocalDevelopMode then printx(0, authorDelegate) end
    local resultParser = function(result)
        local tResult = luaJavaConvert.map2Table(result)
        return tResult
    end
    authorProxy:login(buildCallback(callback, resultParser))
end

function SnsProxy:changeAccount( callback )
    local resultParser = function(result)
        local tResult = luaJavaConvert.map2Table(result)
        return tResult
    end
    if authorProxy:getAuthorizeType() == PlatformAuthEnum.k360 then
        local function safe_change_360()
            local delegate = authorProxy:getAuthorizeDelegate()
            delegate:changeAccount(buildCallback(callback, resultParser))
        end
        pcall(safe_change_360)
    else
        authorProxy:login(buildCallback(callback, resultParser))
    end
end

-- called
function SnsProxy:inviteFriends(callback)
    authorProxy:inviteFriends(convertToInvokeCallback(callback))
end

function SnsProxy:getAllFriends(callback)
    authorProxy:getFriends(0, 999, convertToInvokeCallback(callback))
end
-- logout    
function SnsProxy:logout(callback) 
    authorProxy:logout(buildCallback(callback, nil))
end

function SnsProxy:sendInviteMessage(shareType, friendIds, title, text, imageUrl, thumbUrl, callback) 
    local params = {title=title, text=text, image=imageUrl, thumb=thumbUrl, link = imageUrl}
    shareProxy:setShareType(tonumber(shareType))
    shareProxy:sendInviteMessage(friendIds, luaJavaConvert.table2Map(params), buildCallback(callback, nil))
end

function SnsProxy:shareImage( shareType, title, text, imageUrl, thumbUrl, callback, toTimeline )
    local params = {title=title, text=text, image=imageUrl, thumb=thumbUrl}
    shareProxy:setShareType(tonumber(shareType))
    if toTimeline ~= false then toTimeline = true end
    if shareType == PlatformShareEnum.kJPWX and MaintenanceManager:getInstance():isEnabled("WechatAndroidShare") then 
        toTimeline = true 
    end
    shareProxy:shareImage(toTimeline, luaJavaConvert.table2Map(params), buildCallback(callback, nil))
end

function SnsProxy:shareText( shareType, title, text, callback, toTimeline )
    local params = {title=title, text=text}
    shareProxy:setShareType(tonumber(shareType))
    if toTimeline ~= false then toTimeline = true end
    shareProxy:shareText(toTimeline, luaJavaConvert.table2Map(params), buildCallback(callback, nil))
end

--360的全部分享也走这个
function SnsProxy:shareLink( shareType, title, text, linkUrl, thumbUrl, callback, toTimeline )
    local params = {title=title, text=text, link=linkUrl, thumb=thumbUrl}
    if _G.isLocalDevelopMode then printx(0, "SnsProxy:shareLink-"..table.tostring(params)) end
    shareProxy:setShareType(tonumber(shareType))
    if toTimeline ~= false then toTimeline = true end
    if shareType == PlatformShareEnum.kJPWX and MaintenanceManager:getInstance():isEnabled("WechatAndroidShare") then 
        toTimeline = true 
    end
    shareProxy:shareLink(toTimeline, luaJavaConvert.table2Map(params), buildCallback(callback, nil))
end

-- called
function SnsProxy:getOperatorOne()
    return AndroidPayment.getInstance():getOperator()
end
-- called
function SnsProxy:submitScore( leaderBoardId, level )
    if authorProxy:isLogin() then
        authorProxy:submitUserScore(leaderBoardId, level, buildCallback(nil))
    end
end

function SnsProxy:showPlatformLeaderbord( )
    if authorProxy:isLogin() then
        authorProxy:showLeaderBoard()
    else
        local callback = {
            onSuccess=function( result )
                authorProxy:showLeaderBoard()
            end,
            onError=function(errorCode, msg)
            end,
            onCancel=function()
            end
        }
        authorProxy:login(convertToInvokeCallback(callback))
    end
end
-- called
function SnsProxy:purchaseItem(goodsType, itemId, itemAmount, realAmount, callback)
end


-- called
function SnsProxy:syncSnsFriend(sns_token)
    if not sns_token then 
        sns_token = _G.sns_token
    end
    if _G.isLocalDevelopMode then printx(0, "SnsProxy:syncSnsFriend") end
    if authorProxy:isLogin() then
        local authorType = authorProxy:getAuthorizeType()
        local callback = {
            onSuccess=function( result )
                local userList = luaJavaConvert.list2Table(result)
                local friendOpenIds = {}
                local count = 0
                for i, v in ipairs(userList) do
                    table.insert(friendOpenIds, v.openId)
                    if _G.isLocalDevelopMode then printx(0, tostring(i)..":uid="..tostring(v.openId)) end
                    count = i
                end
                if count > 0 then
                    local function onRequestError( evt )
                        evt.target:removeAllEventListeners()
                        --GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(SyncSnsFriendEvents.kSyncFailed))
                        
                        if _G.isLocalDevelopMode then printx(0, "onPreQzoneError callback") end
                    end
                    local function onRequestFinish( evt )
                        evt.target:removeAllEventListeners()
                        --GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(SyncSnsFriendEvents.kSyncSuccess))
                        if _G.isLocalDevelopMode then printx(0, "onRequestFinish callback") end
                    end 

                    local http = SyncSnsFriendHttp.new()
                    http:addEventListener(Events.kComplete, onRequestFinish)
                    http:addEventListener(Events.kError, onRequestError)

                    http:load(friendOpenIds,nil,nil,authorType)
                else
                    --即使没获取到也得切换好友
                    SyncSnsFriendHttp.new():load({},nil,nil,authorType)           
                end
            end,
            onError = function( err, msg )
                if _G.isLocalDevelopMode then printx(0, "err:"..tostring(err)..",msg:"..tostring(msg)) end
            end,
            onCancel = function()
            end
        }

        local function qqSyncSnsFriend( ... )
            local function onRequestError(evt)
                if _G.isLocalDevelopMode then printx(0, "syncSnsFriend onPreQzoneError callback") end
                GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(SyncSnsFriendEvents.kSyncFailed))
            end

            local function onRequestFinish(evt)
                FriendManager.getInstance().lastSyncTime = os.time()
                FriendManager.getInstance():setQQFriendsSynced()
                if HomeScene:hasInited() then
                    HomeScene:sharedInstance().worldScene:buildFriendPicture()
                else
                    HomeScene.needBuildFriendPicture = true
                end

                GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(SyncSnsFriendEvents.kSyncSuccess))
                if _G.isLocalDevelopMode then printx(0, "syncSnsFriend onRequestFinish callback") end
            end

            local http = SyncSnsFriendHttp.new()
            http:addEventListener(Events.kComplete, onRequestFinish)
            http:addEventListener(Events.kError, onRequestError)
            if sns_token and sns_token.openId and sns_token.accessToken then
                http:load(nil, sns_token.openId, sns_token.accessToken,authorType)
            end
        end

        if authorProxy:getAuthorizeType() == PlatformAuthEnum.kQQ or 
            authorProxy:getAuthorizeType() == PlatformAuthEnum.kJPQQ or 
            authorProxy:getAuthorizeType() == PlatformAuthEnum.kJPWX then --服务端获取好友关系链
            qqSyncSnsFriend()
        else
            if authorProxy:getAuthorizeType() == PlatformAuthEnum.k360 then
                -- 360 的这个接口，新版SDK已经不支持了
            else
                authorProxy:getFriends(0, 999, convertToInvokeCallback(callback))
            end
        end
    end
end
-- called
function SnsProxy:getUserProfile(successCallback,errorCallback,cancelCallback)
    if authorProxy:isLogin() then
        if _G.isLocalDevelopMode then printx(0, "SnsProxy:getUserProfile") end
        local callback = {
            onSuccess=function(result)
                SnsProxy.profile = luaJavaConvert.map2Table(result)
                if _G._UploadDebugLog then RemoteDebug:uploadLogWithTag("getUserProfile", table.tostring(SnsProxy.profile)) end
                successCallback(result)
            end,
            onError=function(err,msg)
                if _G._UploadDebugLog then RemoteDebug:uploadLogWithTag("getUserProfile", "onError", msg) end
                errorCallback(err,msg)
            end,
            onCancel=function()
                cancelCallback()
            end
        }
        authorProxy:getUserProfile(convertToInvokeCallback(callback))
    else
        cancelCallback()
    end
end

function SnsProxy:huaweiIngameLogin(successCallback, errorCallback, cancelCallback)
    if not PlatformConfig:isPlatform(PlatformNameEnum.kHuaWei) then
        if cancelCallback then cancelCallback() end
        return 
    end
    local callback = {
        onSuccess=function(result)
            successCallback()
        end,
        onError=function(err,msg)
            if _G.isLocalDevelopMode then printx(0, "huawei login onError=", msg) end
            errorCallback(err,msg)
        end,
        onCancel=function()
            cancelCallback()
        end
    }

    local onTokenCbk = {
        onSuccess=function(result)
            if result then
                local http = OpNotifyOffline.new(false)
                http:load(14, tostring(result))
            end
        end,
        onError=function(err,msg)
        end,
        onCancel=function()
        end
    }
    -- 正常初始化并非拉起式登录
    local huaweiProxy = luajava.bindClass("com.happyelements.android.platform.huawei.HuaweiProxy"):getInstance()
    huaweiProxy:setTokenCbk(convertToInvokeCallback(onTokenCbk))
    huaweiProxy:initSDK(convertToInvokeCallback(callback), 0)
end

function SnsProxy:HuaweiUpdateInspire()
    if not PlatformConfig:isPlatform(PlatformNameEnum.kHuaWei) then
        return 
    end

    function needUpdate()
        local function version()
	    	local huaweiProxy = luajava.bindClass("com.happyelements.android.platform.huawei.HuaweiProxy"):getInstance()
            if huaweiProxy:getVersionCode("com.huawei.gamebox") < 70101301 then
                return true
            end
            return false
	    end

        local function switcher()
	        local keyName = 'HuaweiUpdateInspire'
	        if not MaintenanceManager:getInstance():isEnabled(keyName) then return false end

            local beginTime, endTime = 0, 0
	        local maintenance =  MaintenanceManager:getInstance():getMaintenanceByKey(keyName)
		    if maintenance.beginDate then
		    	beginTime = parseDateStringToTimestamp(maintenance.beginDate)
		    end
		    if maintenance.endDate then
		    	endTime = parseDateStringToTimestamp(maintenance.endDate)
		    end

	        local nowTime = Localhost:timeInSec()
	        if nowTime < beginTime or nowTime > endTime then
	        	return false
	        end
            return true
        end

        local entryFunc = {}
        table.insert(entryFunc, switcher)
        table.insert(entryFunc, version)

	    for _,func in ipairs(entryFunc) do
	    	if func() == false then
	    		return false
	    	end
	    end
	    return true
    end

    local function needAlter()
        local dailyData = Localhost:readLocalDailyData()
		if not dailyData.HuaweiUpdateInspire then
            return true
		end
        return false
    end

    local uid = tostring(UserManager:getInstance().user.uid or 0)
    local imei = MetaInfo:getInstance():getImei()
    DcUtil:UserTrack({category='huaweiupdateinspire', sub_category='login', t1=uid, t2=imei}, false)

    if needUpdate() then
        if not needAlter() then return false end  -- 不能再初始化了
        -- 今天不再提示
        local dailyData = Localhost:readLocalDailyData()
		dailyData.HuaweiUpdateInspire = 1
		Localhost:writeLocalDailyData(nil, dailyData)

        -- 确认之后才调起SDK初始化
        local callback = {
            onSuccess=function(result)
                local huaweiId = tostring(result or 0)
                DcUtil:UserTrack({category='huaweiupdateinspire', sub_category='upgraded', t1 = uid, t2 = imei, t3 = huaweiId}, false)
            end,
            onError=function(err, msg)
            end,
            onCancel=function()
            end
        }

        local strTitle = Localization:getInstance():getText("huawei.panel.title")
        local strTip = Localization:getInstance():getText("huawei.panel.context")
        local strYes = Localization:getInstance():getText("huawei.button.update")
        local strNo = Localization:getInstance():getText("huawei.button.cancel")

        local huaweiProxy = luajava.bindClass("com.happyelements.android.platform.huawei.HuaweiProxy"):getInstance()
        huaweiProxy:initSDKWithUpdateInspire(
            convertToInvokeCallback(callback), 1, strTitle, strTip, strNo, strYes)
        DcUtil:UserTrack({category='huaweiupdateinspire', sub_category='upgradeinspire', t1 = uid, t2 = imei}, false)
    else
        local callback = {
            onSuccess=function(result)
                local huaweiId = tostring(result or 0)
                DcUtil:UserTrack({category='huaweiupdateinspire', sub_category='loginsuccess', t1 = uid, t2 = imei, t3 = huaweiId}, false)
            end,
            onError=function(err,msg)
                DcUtil:UserTrack({category='huaweiupdateinspire', sub_category='loginfail', t1 = uid, t2 = imei, t3 = err, t4 = msg}, false)
            end,
            onCancel=function()
            end
        }

        local onTokenCbk = {
            onSuccess=function(result)
                if result then
                    local http = OpNotifyOffline.new(false)
                    http:load(OpNotifyOfflineType.kHuaweiPushUpateToken, tostring(result))
                end
            end,
            onError=function(err,msg)
            end,
            onCancel=function()
            end
        }
        -- 正常初始化并非拉起式登录
        local huaweiProxy = luajava.bindClass("com.happyelements.android.platform.huawei.HuaweiProxy"):getInstance()
        huaweiProxy:setTokenCbk(convertToInvokeCallback(onTokenCbk))
        huaweiProxy:initSDK(convertToInvokeCallback(callback), 0)
    end
end

local duokuAdsOpen = true
function SnsProxy:initDuokuAds()
    if PlatformConfig:isBaiduPlatform() then 
        local proId, proName = RealNameManager:getLocationInfoCached()
        if (proId == 0 or proName == "北京" or proName == "福建") and 
            MaintenanceManager:getInstance():isEnabled("baidu_ad") then
            local checkID = nil
            local checkIndex = 1
            local duokuProxy = luajava.bindClass("com.happyelements.hellolua.duoku.DUOKUProxy"):getInstance()

            local function cancelCheck()
                CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(checkID)
                checkID = nil
            end

            local function onCheck(dt)
                if checkIndex > 10 then 
                    cancelCheck()
                end
                if duokuProxy and duokuProxy:getIsSdkInit() then 
                    cancelCheck()
                    duokuProxy:initDuokuAds()
                end
                checkIndex = checkIndex + 1
            end
            checkID = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onCheck, 2, false)
            onCheck()
        else
            duokuAdsOpen = false
        end
    end
end

function SnsProxy:getDuokuAdsOpen()
   return duokuAdsOpen
end