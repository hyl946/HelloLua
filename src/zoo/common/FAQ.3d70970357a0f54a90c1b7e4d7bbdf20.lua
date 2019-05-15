FAQ = {}

FAQTabTags = {
    kSheQu = 1,
    kGongLue = 2,
    kKeFu = 3,
}

FAQTabConfigDefault = {
    [FAQTabTags.kSheQu]     = {mainUrl="http://fansclub.happyelements.com/fans/ff.php"},
    [FAQTabTags.kGongLue]   = {mainUrl="http://fansclub.happyelements.com/fans/ff.php?route=stages"},
    [FAQTabTags.kKeFu]      = {mainUrl="http://fansclub.happyelements.com/fans/faq.php"},
}

FAQTabConfigHttps = {
    [FAQTabTags.kSheQu]     = {mainUrl="https://fansclub.happyelements.com/fans/ff.php"},
    [FAQTabTags.kGongLue]   = {mainUrl="https://fansclub.happyelements.com/fans/ff.php?route=stages"},
    [FAQTabTags.kKeFu]      = {mainUrl="https://fansclub.happyelements.com/fans/faq.php"},
}

FAQViewEvents = {
    ON_VIEW_DID_APPEAR = "onViewDidAppear",
    ON_VIEW_DID_DISAPPEAR = "onViewDidDisappear",
    ON_OPEN_FC_BRIDGE = "onOpenFcBridge",
    ON_OPEN_TAB = "onOpenTab",
}

function FAQ:getParams()
    local deviceOS = "android"
    local appId = "1002"
    local secret = "andridxxl!sx0fy13d2"
    
    if __ANDROID and PlatformConfig:isQQPlatform() then -- android应用宝
        -- appId = "1002"
        -- secret = "yybxxl!1f0ft03ef"
    elseif __IOS then
        deviceOS = "ios"
        appId = "1001"
        secret = "iosxxl!23rj8945fc2d3"
    end
    
    local parameters = {}

    local metaInfo = MetaInfo:getInstance()
    parameters["app"] = appId
    parameters["os"] = deviceOS
    parameters["mac"] = metaInfo:getMacAddress()
    parameters["model"] = metaInfo:getDeviceModel()
    parameters["osver"] = metaInfo:getOsVersion()
    parameters["udid"] = metaInfo:getUdid()
    local network = "UNKNOWN"
    if __ANDROID then
        network = luajava.bindClass("com.happyelements.android.MetaInfo"):getNetworkTypeName()
    elseif __IOS then 
        network = Reachability:getNetWorkTypeName()
    end
    parameters["network"] = network

    parameters["vip"] = 0
    parameters["src"] = "client"
    parameters["lang"] = "zh-Hans"

    parameters["pf"] = StartupConfig:getInstance():getPlatformName() or ""
    parameters["uuid"] = _G.kDeviceID or ""

    local user = UserManager:getInstance().user
    local profile = UserManager.getInstance().profile
    parameters["level"] = user:getTopLevelId()
    parameters["stars"] = user:getTotalStar()
    local markData = UserManager:getInstance().mark
    local createTime = markData and markData.createTime or 0
    parameters["ct"] = tonumber(createTime) / 1000
    parameters["lt"] = PlatformConfig:getLoginTypeName()
    if __IOS then
        parameters["pt"] = "apple"
    elseif __ANDROID then
        local pt = AndroidPayment.getInstance():getDefaultSmsPayment()
        local ptName = "NOSIM"
        if pt then
            local payment = PaymentBase:getPayment(pt)
            ptName = payment.name 
        end
        parameters["pt"] = tostring(ptName)
    end
    parameters["gold"] = user:getCash()
    parameters["silver"] = user:getCoin()
    local dynamicUpdateMd5 = ResourceLoader.getCurVersion() or ""
    local levelUpdateMd5 = LevelMapManager and LevelMapManager.getInstance():getLevelUpdateVersion() or ""
    parameters["uver"] = dynamicUpdateMd5.."_"..levelUpdateMd5
    parameters["uid"] = UserManager:getInstance().uid
    local name = ""
    if profile and profile:haveName() then
        name = profile:getDisplayName()
    end
    parameters["name"] = name
    parameters["ver"] = _G.bundleVersion
    parameters["ts"] = os.time()
    parameters["ext"] = ""
    local roleId = UserManager.getInstance().inviteCode or ""
    parameters["roleid"] = tostring(roleId)
    local headUrl = "1"
    if profile and profile.headUrl then
        headUrl = profile.headUrl
    end
    parameters["roleavatar"] = headUrl

    -- parameters["test"] = 1

    local paramKeys = {}
    for k, v in pairs(parameters) do
        table.insert(paramKeys, k)
    end
    table.sort(paramKeys)
    local md5Src = ""
    for _, v in pairs(paramKeys) do
        md5Src = md5Src..tostring(parameters[v])
    end
    local sig = HeMathUtils:md5(md5Src .. secret)
    -- calc sig
    parameters["sig"] = sig
    return parameters
end

function FAQ:getUrl( url,params )
    params = params or self:getParams()

    local qs = {}
    for k,v in pairs(params) do
         table.insert(qs,k .. "=" .. HeDisplayUtil:urlEncode(tostring(v)))
    end

    if string.find(url,"%?") then
        return url .. "&" .. table.concat(qs,"&")
    else
        return url .. "?" .. table.concat(qs,"&")        
    end
end

function FAQ:openFAQClientIfLogin(defaultUrl, defaultTag)
    if kUserLogin then
        FAQ:openFAQClient(defaultUrl, defaultTag)
    else
        CommonTip:showTip(Localization:getInstance():getText("dis.connect.warning.tips", "negative"))
    end
end

function FAQ:openWechatAppReg(okCallback,failCallback)
    -- https://ffhappyelements.com/index.php/user/miniprogram_register?pt=apple&uver=5583fb3bd2f4d7a11c858d9c745f2e76&uuid=BYDT5Kf0TCAixG4YecqZO8Esjc4Vabpj
    -- &roleavatar=http://q.qlogo.cn/qqapp/100718846/FE82793848926A48FB98F9E4001A5DD1/40&roleid=6232927545&ext=&mac=020000000000&osver=12.1.2
    -- &app=1001&vip=0&ts=1545116835&ver=1.62&level=310&ct=1507737600&src=client&uid=1816637758&stars=821&model=iPhone11,6&lt=qq
    -- &udid=EDE7D908-4526-4054-845E-C91F86B8821B&os=ios&pf=apple&sig=6e5c846c6a29013f5ecd6b7685670eb4&gold=24&network=WIFI
    -- &silver=1497714&name=yyyyyyyyyyyyyyyyy&lang=zh-Hans&cb=https://ff.happyelements.com/mobile/page/index.html?app=1001
    local params = FAQ:getParams()
    params["cb"]="https://ff.happyelements.com/mobile/page/index.html?app=1001"
    local url = FAQ:getUrl("https://ff.happyelements.com/index.php/user/miniprogram_register?",params)
    print("FAQ:openWechatAppReg()",url)

    local function onOpenWechatApp(response)
        if not response or response.httpCode ~= 200 then
            print("FAQ:openWechatAppReg()onFail()",response and response.httpCode,table.tostring(response))
            local _ = failCallback and failCallback()
        else
            print("FAQ:openWechatAppReg()onSuccess()")
            local _ = okCallback and okCallback()
        end
    end

    local request = HttpRequest:createGet(url)
    request:setConnectionTimeoutMs(2 * 1000)
    request:setTimeoutMs(5 * 1000)
    HttpClient:getInstance():sendRequest(onOpenWechatApp, request)
end

function FAQ:openFAQPersonalCenter(inviteCode)
    -- https://fansclub.happyelements.com/fans/ff.php?pt=apple&uver=5d043164548a393af379bcccfa78e32e&uuid=BYDT5Kf0TCAixG4YecqZO8Esjc4Vabpj
    -- &roleavatar=http://q.qlogo.cn/qqapp/100718846/FE82793848926A48FB98F9E4001A5DD1/40&roleid=6232927545&ext=&mac=020000000000
    -- &osver=12.1&app=1001&vip=0&ts=1541488875&ver=1.61&level=274&ct=1507737600&src=client&uid=1816637758&stars=723
    -- &model=iPhone11,6&lt=qq&udid=EDE7D908-4526-4054-845E-C91F86B8821B&os=ios&pf=apple&sig=ed5b42878dbafa5157dfb7f8972f61f0&gold=18
    -- &network=WIFI&silver=998929&name=yyyyyyyyyyyyyyyyy&lang=zh-Hans&cb=http://ff.happyelements.com/mobile/page/profile.html?roleid=6232927545
    
    print("FAQ:openFAQPersonalCenter()",inviteCode)

    if kUserLogin then
        local params = {}
        if inviteCode then
            --好友
            params["cb"]="http://ff.happyelements.com/mobile/page/profile.html?roleid=" .. tostring(inviteCode)
            if _G.isLocalDevelopMode then
                params["cb"]="http://ff.happyelements.com/test/mobile/page/profile.html?roleid=" .. tostring(inviteCode)
            end
        else
            --个人中心
            params["route"]="me"
        end
        local defaultUrl = "https://fansclub.happyelements.com/fans/ff.php"
        FAQ:openFAQClient(defaultUrl, FAQTabTags.kSheQu, nil,params)
    else
        CommonTip:showTip(Localization:getInstance():getText("dis.connect.warning.tips", "negative"))
    end
end

function FAQ:openFAQClient(defaultUrl, defaultTag, noPermissonRequest,otherParams)
    if not ReachabilityUtil.getInstance():isNetworkAvailable() then
        CommonTip:showTip(Localization:getInstance():getText("dis.connect.warning.tips", "negative"))
        return
    end
    
    UserManager:getInstance():updateCommunityMessageVersion()

    local params = FAQ:getParams()
    if otherParams then
        params = table.merge(params,otherParams)
    end

    local isUseNewFAQ = FAQ:useNewFAQ()
     if __IOS then 
        if isUseNewFAQ then
            defaultTag = defaultTag or FAQTabTags.kKeFu
            FAQ:openIOSNewFAQ(defaultTag, defaultUrl,otherParams)
        else
            defaultUrl = defaultUrl or "http://fansclub.happyelements.com/fans/faq.php"
            if FAQ:useSafeUrl() then
                defaultUrl = FAQ:replaceHttpWithHttps(defaultUrl)
            end
            GspEnvironment:getCustomerSupportAgent():setExtraParams(params) 
            GspEnvironment:getCustomerSupportAgent():setFAQurl(FAQ:getUrl(defaultUrl, params)) 
            GspEnvironment:getCustomerSupportAgent():ShowJiraMain() 
        end
    elseif __ANDROID then
        local onButton1Click = function()
            if isUseNewFAQ then
                defaultTag = defaultTag or FAQTabTags.kKeFu
                if PlatformConfig:isQQPlatform() and not MaintenanceManager:getInstance():isEnabled("Close_YYB_BBS", false) then
                    FAQ:openQQPlatformNewFAQ(defaultTag, defaultUrl,otherParams)
                else
                    FAQ:openAndroidNewFAQ(defaultTag, defaultUrl,otherParams)
                end
            else
                defaultUrl = defaultUrl or "http://fansclub.happyelements.com/fans/faq.php"
                if FAQ:useSafeUrl() then
                    defaultUrl = FAQ:replaceHttpWithHttps(defaultUrl)
                end
                GspProxy:setExtraParams(params)
                GspProxy:setFAQurl(FAQ:getUrl(defaultUrl, params))
                GspProxy:showCustomerDiaLog()
            end
        end

        PermissionManager.getInstance():requestEach(PermissionsConfig.WRITE_EXTERNAL_STORAGE, onButton1Click)

        -- if noPermissonRequest then
        --     onButton1Click()
        -- else
        --     CommonAlertUtil:showPrePkgAlertPanel(onButton1Click,NotRemindFlag.WRITE_EXTERNAL_STORAGE,Localization:getInstance():getText("pre.tips.photo"),nil,nil,nil,nil,nil,RequestConst.WRITE_EXTERNAL_STORAGE);
        -- end
    end
end

function FAQ:openCustomPage(url, showTopBar, listener)
    local openDefaultUrl = url
    local defaultTag = 99
    local faqConfig = {
        {
            -- title_img="drawable/faq_tab_title_1", 
            button_img="drawable/faq_tab_btn_1",
            button_focus_img="drawable/faq_tab_btn_focus_1",
            tag = defaultTag,
            url= openDefaultUrl,
        },
    }
    if __IOS then
        local uiConfig = {
            nav_bar_bg_img = "bg_color_white",
            back_btn_img = "bg_color_white",
            close_btn_img = "faq_close_btn_brown",
            nav_bar_height = showTopBar and 40 or 0,
            tab_bar_height = 0, 
            disable_back_btn = "true",
        }
        local faqDelegate = FAQ:buildIOSFAQDelegate(listener)
        FAQManager:getInstance():showWithConfig_uiConfig_delegate(faqConfig, uiConfig, faqDelegate)
    elseif __ANDROID then
        local uiConfig = {
            nav_bar_bg_img = "drawable/bg_color_white",
            back_btn_img = "drawable/bg_color_white",
            close_btn_img = "drawable/faq_close_btn_brown",
            nav_bar_height = showTopBar and 40 or 0,
            tab_bar_height = 0,
            disable_keyback = "true",
            disable_back_btn = "true",
            -- disable_close_btn = "true",
        }
        local faqConfigList = self:buildFAQConfigArrayList(faqConfig, defaultTag, openDefaultUrl)
        local faqManagerInstance = luajava.bindClass("com.happyelements.android.faq.FAQManager"):getInstance()
        local faqDelegate = self:buildAndroidFAQDelegate(listener)
        faqManagerInstance:showWithConfig(faqConfigList, luaJavaConvert.table2Map(uiConfig), faqDelegate, true)
    end
end

function FAQ:useNewFAQ()
    if self.isUseNewFAQFlag == nil then
        if __WIN32 or MaintenanceManager:getInstance():isEnabled("NewFAQAvailable", false) then
            self.isUseNewFAQFlag = true
        else
            self.isUseNewFAQFlag = false
        end
    end
    return self.isUseNewFAQFlag
end

function FAQ:isButtonVisible()
    if __ANDROID then
        return not MaintenanceManager:isInReview()
    end
    return true
end

function FAQ:isNewFAQButtonDefaultInside()
    if PlatformConfig:isQQPlatform() then
        return true
    end
    local global = MetaManager.getInstance().global
    local insidePfs = global and global.faqBtnInside or ""
    insidePfs = string.gsub(insidePfs, " ", "")
    local pfs = string.split(insidePfs, ",")
    for _, v in pairs(pfs) do
        if v == PlatformConfig.name then
            return true
        end
    end
    return false
end

function FAQ:showNewFAQButtonOutside()
    if self.isNewFAQButtonOutsideFlag == nil then
        local isNewFAQButtonInside = false
        if FriendRecommendManager:friendsButtonOutSide() then
            isNewFAQButtonInside = true
        else
            if FAQ:isNewFAQButtonDefaultInside() then
                isNewFAQButtonInside = MaintenanceManager:getInstance():isEnabled("NewFAQButtonInside", true)
            else
                isNewFAQButtonInside = MaintenanceManager:getInstance():isEnabled("NewFAQButtonInside", false)
            end
        end
        if isNewFAQButtonInside then
            self.isNewFAQButtonOutsideFlag = false
        else
            self.isNewFAQButtonOutsideFlag = true
        end
    end
    return self.isNewFAQButtonOutsideFlag
end

function FAQ:useSafeUrl()
    local uid = UserManager:getInstance().uid
    if MaintenanceManager:getInstance():isAvailbleForUid("FAQUseHttps", uid) then
        return true
    end
    return false
end

function FAQ:replaceHttpWithHttps(url)
    if string.starts(url, "http://") then
        return "https://"..string.sub(url, 8)
    end
    return url
end

function FAQ:formatFcBridgeData(data)
    -- printx(61, ' FAQ data', data)
    if not data then return nil end

    local function doDecode()
        local simplejson = require("cjson")
        return simplejson.decode(data)
    end
    local success, ret = pcall(doDecode)
    -- if _G.isLocalDevelopMode then printx(61, ">>>>FAQ formatFcBridgeData:", success, table.tostring(ret)) end
    if success then
        return ret
    else
        return nil
    end
end

function FAQ:isSchemeSupport(schemeUrl)
    if not schemeUrl or schemeUrl == "" then return false end

    if __ANDROID then
        return true
    elseif __IOS then
        local supports = {"tmall","taobao","wechat","weixin",
            "mqqOpensdkSSoLogin","mqqopensdkapiV2","mqqopensdkapiV3","wtloginmqq2",
            "mqq","mqqapi","sinaweibo","sinaweibohd","weibosdk","happyclover3","youku"}
        for _, v in ipairs(supports) do
            if string.starts(schemeUrl, v) then
                return true
            end
        end
    end
    return false
end

--[[
data:
name    -
param   -
action  - close: webview will be closed
]]
function FAQ:handleFcBridge(data)
    local fData = FAQ:formatFcBridgeData(data)
    if type(fData) == "table" then
        if fData.name == "updateUnread" and type(fData.param) == "table" then
            local count = tonumber(fData.param.unread)
            refreshFaqRedDot(count, nil, true)
        elseif fData.name == "addIssue" then
            local http = OpNotifyHttp.new()
            http:load(OpNotifyType.kFAQAddIssue, 0)
        elseif fData.name == "openIncite" then
            if _G.isLocalDevelopMode then printx(0, "openIncite...") end
            require "zoo.panel.incite.InciteManager"
            InciteManager:showIncitePanel(EntranceType.kFAQ)
        elseif fData.name == "share" then 
            FAQ:handleFAQShare(fData)
        elseif fData.name == "openUrl" then
            if fData.param then
                local schemeUrl = fData.param.schemeUrl
                local httpUrl = fData.param.httpUrl
                if FAQ:isSchemeSupport(schemeUrl) and OpenUrlUtil:canOpenUrl(schemeUrl) then
                    OpenUrlUtil:openUrl(schemeUrl)
                else
                    OpenUrlUtil:openUrl(httpUrl)
                end
            end
        elseif fData.name == 'sharePage' then
            -- 处理调起自身的scheme
            local url = fData.scheme
            self:handleSelfURL(url or '')
        else
            if _G.isLocalDevelopMode then
                -- printx(61, 'FAQ unhandled fc data with name: ' .. (fData.name or 'null'))
            end 
        end
    end
end

function FAQ:handleSelfURL( url )
    --printx(61, 'FAQ:handleSelfURL ' .. url)
    local url = url or ''
    if string.starts(url, 'happyanimal3://') then
        local scene = Director:sharedDirector():getRunningScene()
        if scene and scene.onApplicationHandleOpenURL then
            if _G.isLocalDevelopMode then printx(0, "scene:onApplicationHandleOpenURL()") end
            scene:onApplicationHandleOpenURL(url)
        end
    end
end

-- urlType      1链接 2大图 3复制
-- shareUrl     链接分享的页面地址或者图片分享的图片地址
-- shareType    --分享类型 根据玩家点选的传 1微信点对点 2微信朋友圈 3qq点对点 4qq朋友圈
                --ios上这个字段无意义 我们无法指定 系统自行选择可用分享app, android上qq无法分享链接
-- title        --分享出去的标题           
-- text         --分享出去的标题下的文案
-- extra        --预留字段~一个字符串带着所有可能的额外信息~用可用的标识符隔开
function FAQ:handleFAQShare(fData)
    local urlType = tonumber(fData.urlType)
    if not urlType then return end 
    local shareUrl = fData.shareUrl 
    if not shareUrl then return end 

    if urlType == 3 then
        ClipBoardUtil.copyText(shareUrl)
        return
    end

    local title = localize("invite.friend.panel.share.title")
    if fData.title and fData.title ~= "" then 
        title = HeDisplayUtil:urlDecode(fData.title)
    end
    local text = ""
    if fData.text and fData.text ~= "" then 
        text = HeDisplayUtil:urlDecode(fData.text)
    end
    local thumbUrl = CCFileUtils:sharedFileUtils():fullPathForFilename("materials/wechat_icon.png")

    if __ANDROID then
        local shareRigisterType 
        local shareType = tonumber(fData.shareType)
        if not shareType then return end

        if shareType == 1 or shareType == 2 then 
            shareRigisterType = 8   --微信
        elseif shareType == 3 or shareType == 4 then 
            shareRigisterType = 9   --qq
        end

        local toTimeLine = true 
        if shareType == 1 or shareType == 3 then 
            toTimeLine = false
        end
        local shareCallback = nil
        AndroidShare.getInstance():registerShare(shareRigisterType)
        if urlType == 1 then 
            ShareUtil:saveShareImgToLocal(thumbUrl, function (imgLocalPath)
                SnsUtil.sendLinkMessage(shareRigisterType, title, text, imgLocalPath, shareUrl, toTimeLine, shareCallback)
            end)
        elseif urlType == 2 then    
            ShareUtil:saveShareImgToLocal(shareUrl, function (imgLocalPath)
                SnsUtil.sendImageMessage(shareRigisterType, title, text, nil, imgLocalPath, shareCallback, toTimeLine)
            end)    
        end
    elseif __IOS then 
        if urlType == 1 then 
            ShareUtil:saveShareImgToLocal(thumbUrl, function (imgLocalPath)
                 SystemShareUtil:shareLink_subject_thumb_callback(shareUrl, title, imgLocalPath, nil)
            end)
        elseif urlType == 2 then    
            ShareUtil:saveShareImgToLocal(shareUrl, function (imgLocalPath)
                SystemShareUtil:shareImage_subject_thumb_callback(imgLocalPath, title, nil, nil)
            end)    
        end
    end
end

function FAQ:getFAQTabConfig()
    if FAQ:useSafeUrl() then
        return FAQTabConfigHttps
    end
    return FAQTabConfigDefault
end

function FAQ:freeHomeSceneMask()
    local timer = 0
    local tickHandler = nil

    local function onRestoreTexture()
        if timer < 60 then
            if timer == 30 then
                HomeScene_restoreUnuseInGameTexture(false)
            end
            timer = timer + 1
            return
        end

        if(tickHandler) then
            CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(tickHandler)
            tickHandler = nil
        end

        HomeScene:sharedInstance():freeLeaveScreenMask()
        freeTextureStateGroup:set('faq', false)
    end

    tickHandler = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onRestoreTexture, 0, false)
end

function FAQ:buildIOSFAQDelegate(listener)
    local FAQViewDelegateImpl = waxClass({"FAQViewDelegateImpl", NSObject, protocols={"FAQViewDelegate"}})
    local isBackgroundMusicOpen = GamePlayMusicPlayer:getInstance().IsBackgroundMusicOPen
    function FAQViewDelegateImpl:onViewDidAppear()
        -- if _G.isLocalDevelopMode then printx(0, ">>>>onViewDidAppear") end
        if type(listener) == "function" then
            if listener({name = FAQViewEvents.ON_VIEW_DID_APPEAR}) then return end
        end
        if isBackgroundMusicOpen then
            GamePlayMusicPlayer:getInstance().IsBackgroundMusicOPen = false
            SimpleAudioEngine:sharedEngine():pauseBackgroundMusic()
        end
        if _G.__isLowDevice and not freeTextureStateGroup:actived() then
            HomeScene_freeUnuseInGameTextureMinSize(1024*1024)
            freeTextureStateGroup:set('faq', true)
            HomeScene:sharedInstance():cacheHomeSceneGeneralMask()
        end
        _utilsLib.setEnableAutoRestorePaintingTexture(false)
        -- freeTextureScenario:set('faq', true)
    end
    function FAQViewDelegateImpl:onViewDidDisappear()
        -- if _G.isLocalDevelopMode then printx(0, ">>>>onViewDidDisappear") end
        if type(listener) == "function" then
            if listener({name = FAQViewEvents.ON_VIEW_DID_DISAPPEAR}) then return end
        end
        if isBackgroundMusicOpen then
            GamePlayMusicPlayer:getInstance().IsBackgroundMusicOPen = true
            SimpleAudioEngine:sharedEngine():resumeBackgroundMusic()
        end

        if freeTextureStateGroup:get('faq') then
            FAQ:freeHomeSceneMask()
        end
        _utilsLib.setEnableAutoRestorePaintingTexture(true)
        -- freeTextureScenario:set('faq', false)

        AutoPopout:onReturnFromFAQ()

    end
    function FAQViewDelegateImpl:onOpenFcBridge(data)
        -- if _G.isLocalDevelopMode then printx(0, ">>>>onOpenFcBridge:", data) end
        if type(listener) == "function" then
            if listener({name = FAQViewEvents.ON_OPEN_FC_BRIDGE, data = data}) then return true end
        end
        FAQ:handleFcBridge(data)
        return true
    end
    function FAQViewDelegateImpl:onOpenTab(tabTag)
        -- if _G.isLocalDevelopMode then printx(0, ">>>>onOpenTab:", tabTag) end
        if type(listener) == "function" then
            if listener({name = FAQViewEvents.ON_OPEN_TAB, data = tag}) then return end
        end
    end
    return FAQViewDelegateImpl:init()
end

function FAQ:openIOSNewFAQ(defaultTag, defaultUrl,otherParams)
    local params = FAQ:getParams()
    local faqConfig = {
        {
            -- title_img="faq_tab_title_1", 
            button_img="faq_tab_btn_1",
            button_focus_img="faq_tab_btn_focus_1",
            tag = FAQTabTags.kSheQu,
            url=FAQ:buildUrlByTag(FAQTabTags.kSheQu, params),
        },
        {
            -- title_img="faq_tab_title_2", 
            button_img="faq_tab_btn_2", 
            button_focus_img="faq_tab_btn_focus_2",
            tag = FAQTabTags.kGongLue,
            url=FAQ:buildUrlByTag(FAQTabTags.kGongLue, params),
        },
        {
            -- title_img="faq_tab_title_3", 
            button_img="faq_tab_btn_3", 
            button_focus_img="faq_tab_btn_focus_3",
            tag = FAQTabTags.kKeFu,
            url=FAQ:buildUrlByTag(FAQTabTags.kKeFu, params),
        }
    }

    local openDefaultUrl = nil

    local tempParams = params
    if otherParams then
        tempParams = table.merge(params,otherParams)
    end
    if defaultUrl then
        openDefaultUrl = FAQ:getUrl(defaultUrl, tempParams)
    end
    
    for i, cfg in ipairs(faqConfig) do
        if cfg.tag == FAQTabTags.kKeFu then
            local repayCount = FAQ:readFaqReplayCount()
            local kefuBadgeValue = nil
            if repayCount and repayCount > 0 then kefuBadgeValue = tostring(repayCount) end
            cfg.badgeValue = kefuBadgeValue
        end
        if cfg.tag == defaultTag then
            cfg.default = 1
            cfg.openUrl = openDefaultUrl
        end
    end
    local uiConfig = {
        nav_bar_bg_img = "bg_color_white",
        back_btn_img = "faq_back_btn_brown",
        close_btn_img = "faq_close_btn_brown",
        nav_bar_height = 40, -- iOS only
        tab_bar_height = 40, -- iOS only
    }
    
    local deviceType = MetaInfo:getInstance():getMachineType() or ""
    if string.find(deviceType, "iPad") then 
        uiConfig.nav_bar_height = 55
        uiConfig.tab_bar_height = 55
    end
    local function faqListener(event)
        if event then
            if event.name == FAQViewEvents.ON_VIEW_DID_APPEAR then
                require "zoo.panel.incite.InciteManager"
                InciteManager:onEnterFQA()
            elseif event.name == FAQViewEvents.ON_VIEW_DID_DISAPPEAR then
                HomeScene:sharedInstance().settingButton:updateDotTipStatus()
                HomeScene:sharedInstance():tryRefreshFcButton()

                require "zoo.panel.incite.InciteManager"
                InciteManager:onExitFAQ()
            end
        end
    end
    local faqDelegate = FAQ:buildIOSFAQDelegate(faqListener)
    FAQManager:getInstance():showWithConfig_uiConfig_delegate(faqConfig, uiConfig, faqDelegate)
end

function FAQ:buildAndroidFAQDelegate(listener)
    local isBackgroundMusicOpen = GamePlayMusicPlayer:getInstance().IsBackgroundMusicOPen
    local function onViewDidAppear()
        -- if _G.isLocalDevelopMode then printx(0, ">>>>onViewDidAppear") end
        if type(listener) == "function" then
            if listener({name = FAQViewEvents.ON_VIEW_DID_APPEAR}) then return end
        end
        if isBackgroundMusicOpen then
            GamePlayMusicPlayer:getInstance().IsBackgroundMusicOPen = false
            SimpleAudioEngine:sharedEngine():pauseBackgroundMusic()
        end
        if _G.__isLowDevice and not freeTextureStateGroup:actived() then
            HomeScene_freeUnuseInGameTextureMinSize(1024*1024)
            freeTextureStateGroup:set('faq', true)
            HomeScene:sharedInstance():cacheHomeSceneGeneralMask()
        end
        _utilsLib.setEnableAutoRestorePaintingTexture(false)
        -- freeTextureScenario:set('faq', true)
    end
    local function onViewDidDisappear()
        -- if _G.isLocalDevelopMode then printx(0, ">>>>onViewDidDisappear") end
        if type(listener) == "function" then
            if listener({name = FAQViewEvents.ON_VIEW_DID_DISAPPEAR}) then return end
        end
        if isBackgroundMusicOpen then
            GamePlayMusicPlayer:getInstance().IsBackgroundMusicOPen = true
            SimpleAudioEngine:sharedEngine():resumeBackgroundMusic()
        end

        if freeTextureStateGroup:get('faq') then
            FAQ:freeHomeSceneMask()
        end
        _utilsLib.setEnableAutoRestorePaintingTexture(true)
        -- freeTextureScenario:set('faq', false)

        AutoPopout:onReturnFromFAQ()
    end
    local function onOpenFcBridge(data)
        if type(listener) == "function" then
            if listener({name = FAQViewEvents.ON_OPEN_FC_BRIDGE, data = data}) then return true end
        end
        -- printx(61, 'FAQ', data)
        FAQ:handleFcBridge(data)
        return true
    end
    local function onOpenTab(tag)
        if type(listener) == "function" then
            if listener({name = FAQViewEvents.ON_OPEN_TAB, data = tag}) then return end
        end
        -- if _G.isLocalDevelopMode then printx(0, ">>>>onOpenTab:", tag) end
    end
    local viewDelegate = luajava.createProxy("com.happyelements.android.faq.FAQViewDelegate", {
        onViewDidAppear = onViewDidAppear,
        onViewDidDisappear = onViewDidDisappear,
        onOpenFcBridge = onOpenFcBridge,
        onOpenTab = onOpenTab
        })
    return viewDelegate
end

function FAQ:buildFAQConfigArrayList(faqConfig, defaultTag, openDefaultUrl)
    local validDefaultTag = nil
    for i, cfg in ipairs(faqConfig) do
        if not validDefaultTag or cfg.tag == defaultTag then 
            validDefaultTag = cfg.tag 
        end
    end
    for i, cfg in ipairs(faqConfig) do
        if cfg.tag == FAQTabTags.kKeFu then
            local repayCount = FAQ:readFaqReplayCount()
            local kefuBadgeValue = nil
            if repayCount and repayCount > 0 then kefuBadgeValue = tostring(repayCount) end
            cfg.badgeValue = kefuBadgeValue
        end
        if cfg.tag == validDefaultTag then
            cfg.default = 1
            if openDefaultUrl then
                cfg.openUrl = openDefaultUrl
            end
        end
    end

    local faqConfigList = luajava.newInstance("java.util.ArrayList")
    for _, t in ipairs(faqConfig) do
        faqConfigList:add(luaJavaConvert.table2Map(t))
    end
    return faqConfigList
end

function FAQ:buildUrlByTag(tag, params)
    local tabConfig = FAQ:getFAQTabConfig() or FAQTabConfigDefault
    local config = tabConfig[tag]
    return FAQ:getUrl(config.mainUrl, params)
end

function FAQ:openQQPlatformNewFAQ(defaultTag, defaultUrl,otherParams)
    local params = FAQ:getParams()

    local faqConfig = {
        {
            -- title_img="drawable/faq_tab_title_3", 
            button_img="drawable/faq_tab_btn_3", 
            button_focus_img="drawable/faq_tab_btn_focus_3",
            tag = FAQTabTags.kKeFu,
            url= FAQ:buildUrlByTag(FAQTabTags.kKeFu, params),
        }
    }
    local uiConfig = {
        nav_bar_bg_img = "drawable/bg_color_white",
        back_btn_img = "drawable/faq_back_btn_brown",
        close_btn_img = "drawable/faq_close_btn_brown",
    }
    local function faqListener(event)
        if event then
            if event.name == FAQViewEvents.ON_VIEW_DID_APPEAR then
            elseif event.name == FAQViewEvents.ON_VIEW_DID_DISAPPEAR then
                HomeScene:sharedInstance().settingButton:updateDotTipStatus()
                HomeScene:sharedInstance():tryRefreshFcButton()
            end
        end
    end

    local openDefaultUrl = nil

    local tempParams = params
    if otherParams then
        tempParams = table.merge(params,otherParams)
    end
    if defaultUrl then
        openDefaultUrl = FAQ:getUrl(defaultUrl, tempParams)
    end

    local faqConfigList = self:buildFAQConfigArrayList(faqConfig, defaultTag, openDefaultUrl)
    local faqManagerInstance = luajava.bindClass("com.happyelements.android.faq.FAQManager"):getInstance()
    local faqDelegate = self:buildAndroidFAQDelegate(faqListener)
    faqManagerInstance:showWithConfig(faqConfigList, luaJavaConvert.table2Map(uiConfig), faqDelegate, true)
end

function FAQ:openAndroidNewFAQ(defaultTag, defaultUrl,otherParams)
    local params = FAQ:getParams()

    -- RemoteDebug:uploadLogWithTag('openAndroidNewFAQ()',defaultUrl, tostring(openDefaultUrl) )

    local faqConfig = {
        {
            -- title_img="drawable/faq_tab_title_1", 
            button_img="drawable/faq_tab_btn_1",
            button_focus_img="drawable/faq_tab_btn_focus_1",
            tag = FAQTabTags.kSheQu,
            url= FAQ:buildUrlByTag(FAQTabTags.kSheQu, params),
        },
        {
            -- title_img="drawable/faq_tab_title_2", 
            button_img="drawable/faq_tab_btn_2", 
            button_focus_img="drawable/faq_tab_btn_focus_2",
            tag = FAQTabTags.kGongLue,
            url= FAQ:buildUrlByTag(FAQTabTags.kGongLue, params),
        },
        {
            -- title_img="drawable/faq_tab_title_3", 
            button_img="drawable/faq_tab_btn_3", 
            button_focus_img="drawable/faq_tab_btn_focus_3",
            tag = FAQTabTags.kKeFu,
            url= FAQ:buildUrlByTag(FAQTabTags.kKeFu, params),
        }
    }
    local uiConfig = {
        nav_bar_bg_img = "drawable/bg_color_white",
        back_btn_img = "drawable/faq_back_btn_brown",
        close_btn_img = "drawable/faq_close_btn_brown",
    }
    local function faqListener(event)
        if event then
            if event.name == FAQViewEvents.ON_VIEW_DID_APPEAR then
            elseif event.name == FAQViewEvents.ON_VIEW_DID_DISAPPEAR then
                HomeScene:sharedInstance().settingButton:updateDotTipStatus()
                HomeScene:sharedInstance():tryRefreshFcButton()
            end
        end
    end

    local openDefaultUrl = nil

    local tempParams = params
    if otherParams then
        tempParams = table.merge(params,otherParams)
    end
    if defaultUrl then
        openDefaultUrl = FAQ:getUrl(defaultUrl, tempParams)
    end

    local faqConfigList = self:buildFAQConfigArrayList(faqConfig, defaultTag, openDefaultUrl)
    local faqManagerInstance = luajava.bindClass("com.happyelements.android.faq.FAQManager"):getInstance()
    local faqDelegate = self:buildAndroidFAQDelegate(faqListener)
    faqManagerInstance:showWithConfig(faqConfigList, luaJavaConvert.table2Map(uiConfig), faqDelegate, true)
end

function FAQ:tryRequestFaqReplayCount(isForce)
    if PrepackageUtil:isPreNoNetWork() then return end

    local latestAddIssueTime = UserManager:getInstance().userExtend.latestAddIssueTime
    latestAddIssueTime = tonumber(latestAddIssueTime) or 0
    local timeInSec = Localhost:timeInSec() - latestAddIssueTime
    if timeInSec > 0 and timeInSec < 2592000 then -- 30天内有过提问的玩家才需要获取消息数量
        local count = FAQ:getFaqReplayCountFromCookie()
        local lastFaqPingTime = tonumber(FAQ:getLastFaqPingTimeFromCookie()) or 0
        if isForce or not count or (os.time() - lastFaqPingTime > 1800) then
            requestFaqReplayCount()
        end
    end
end

function FAQ:getFaqReplayCountFromCookie()
    local uid = UserManager:getInstance().uid
    return Cookie.getInstance():read("faqRepayCount"..tostring(uid))
end

function FAQ:getLastFaqPingTimeFromCookie()
    local uid = UserManager:getInstance().uid
    return Cookie.getInstance():read("lastFaqPingTime"..tostring(uid))
end

function FAQ:setFaqReplayCountInCookie(count)
    local uid = UserManager:getInstance().uid
    Cookie.getInstance():write("faqRepayCount"..tostring(uid),count)
    Cookie.getInstance():write("lastFaqPingTime"..tostring(uid),os.time())
end

function FAQ:readFaqReplayCount()
    local num = FAQ:getFaqReplayCountFromCookie()
    if num then
        num = tonumber(num)
    else
        num = 0
    end
    return num
end

function FAQ:isPersonalCenterEnabled()
    -- do return true end
    -- local r = not MaintenanceManager:isInReview() and MaintenanceManager:isEnabled("CommunityMessage")
    -- RemoteDebug:uploadLogWithTag('faq:home()'..tostring(r),MaintenanceManager:isInReview() , MaintenanceManager:isEnabled("CommunityMessage"))

    return not MaintenanceManager:isInReview() and MaintenanceManager:isEnabled("CommunityMessage")
end

-- 请求客服系统提问的回复数
function requestFaqReplayCount()
    local userId = UserManager:getInstance().user.uid
    local url = "http://fansclub.happyelements.com/kefu/api/v1/updates.php"
    local lastFaqPingTime = "0"

    if __ANDROID then
        if kUserLogin then
            GspProxy:getFaqRepayCount(userId,lastFaqPingTime,url)
        end
    elseif __IOS then
        GspEnvironment:getCustomerSupportAgent():getFaqRepayCount_pingTime_urlStr(userId,lastFaqPingTime,url)
    end
end

-- 刷新客户端小红点
function refreshFaqRedDot(count,pingTime,onlyData)
    if count then
        FAQ:setFaqReplayCountInCookie(count)
    end
    if not onlyData then
        HomeScene:sharedInstance().settingButton:updateDotTipStatus()
        HomeScene:sharedInstance():tryRefreshFcButton()
    end
end

-- 点击后重置小红点显示逻辑
function resetRedDotRefresh()
    local repayCount = FAQ:getFaqReplayCountFromCookie()
    if repayCount then
        local count = tonumber(repayCount)
        if count > 0 then
            refreshFaqRedDot(0)
            HomeScene:sharedInstance().settingButton:updateDotTipStatus()
        end
    end
end
