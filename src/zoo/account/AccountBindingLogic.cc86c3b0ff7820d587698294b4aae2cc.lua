require "zoo.panel.phone.PhoneLoginInfo"
require "zoo.panel.phone.PhoneConfirmPanel"
require "zoo.panel.phone.SendCodeConfirmPanel"
require "zoo.panel.phone.VerifyPhoneConfirmPanel"
require "zoo.panel.phone.PhoneLoginPanel"
require "zoo.panel.accountPanel.ChangePhoneConfirmPanel"

AccountBindingSource = table.const{
    DEFAULT  = 1,
    ADD_FRIEND = 2, --添加好友
    PUSH_BIND_PANEL = 3, --推荐绑定  PushBinding
    FROM_LOGIN = 4, --登录界面
    MESSAGE_CENTER = 5, --消息中心
    ACCOUNT_SETTING = 6, --账号设置面板
    REAL_NAME = 7, --实名制
    AREA_UNLOCK = 8,--区域解锁
    FRUIT_TREE = 9,--金银果树
    PUSH_BINDING_LOGIC = 10,--不清楚
    SEASON_WEEK_PASS_PANEL = 11,--周赛
    SHARE_PASS_FRIEND = 12,--分享
    ASK_ENERGY = 13, --索要精力
    WDJ_REMOVE = 14--豌豆荚SDK下线
}

AccountBindingMergeSource = table.const {
    [AccountBindingSource.DEFAULT] = 1,
    [AccountBindingSource.PUSH_BIND_PANEL] = 1,
    [AccountBindingSource.FROM_LOGIN] = 1,
    [AccountBindingSource.MESSAGE_CENTER] = 1,
    [AccountBindingSource.ACCOUNT_SETTING] = 1,
    [AccountBindingSource.REAL_NAME] = 1,
    [AccountBindingSource.AREA_UNLOCK] = 1,
    [AccountBindingSource.FRUIT_TREE] = 1,
    [AccountBindingSource.PUSH_BINDING_LOGIC] = 1,
    [AccountBindingSource.SEASON_WEEK_PASS_PANEL] = 1,
    [AccountBindingSource.SHARE_PASS_FRIEND] = 1,
    [AccountBindingSource.ADD_FRIEND] = 2,
    [AccountBindingSource.ASK_ENERGY] = 1,
    [AccountBindingSource.WDJ_REMOVE] = 1,
}

-- 0:当前是游客,请走游客绑定流程,1:不弹板，直接调用extraConnectV4绑定,2:弹板,玩家确认后绑定,3:已经绑定过此种3方,4:账号有数据无法绑定
PreExtraConnectErrorCode = {
    kGuest = 0,
    kBindDirectly = 1,
    kNeedConfirm = 2,
    kBindSameSns = 3,
    kDataConflict = 4,
}

AccountBindingLogic = {}

function AccountBindingLogic:onBindAccountSuccess()
end

function AccountBindingLogic:isGuest()
    if UserManager.getInstance().profile:isPhoneBound() or UserManager.getInstance().profile:isSNSBound() then
        return false
    end
    return true
end

function AccountBindingLogic:isQQNotRecommand()
    return true
end

function AccountBindingLogic:bindNewPhone(onReturnCallback, onBindSuccessCallback, source)
    --print("AccountBindingLogic:bindNewPhone()",onReturnCallback, onBindSuccessCallback, source,debug.traceback())

    local function onPhoneLoginComplete( openId,phoneNumber,accessToken )
        local profile = UserManager.getInstance().profile
        local sns_token = {openId=openId,accessToken=accessToken, authorType=PlatformAuthEnum.kPhone}
        local snsInfo = { snsName=phoneNumber }
        -- if not _G.sns_token then
        snsInfo.name = profile:getDisplayName()
        snsInfo.headUrl = profile.headUrl
        -- end
        local function localBindSuccessCallback()
            AccountBindingLogic:onBindAccountSuccess()
            if onBindSuccessCallback then
                onBindSuccessCallback()
            end
        end
        AccountBindingLogic:bindConnect(PlatformAuthEnum.kPhone,snsInfo,sns_token, localBindSuccessCallback, nil, nil, source)
    end
        

    local function onCancelBindPhone()
        if onReturnCallback then
            onReturnCallback()
        end

        CommonTip:showTip("您已取消绑定手机号~")
    end

    local phoneLoginInfo = PhoneLoginInfo.new(PhoneLoginMode.kAddBindingLogin)
    if AccountBindingLogic:isGuest() then
        phoneLoginInfo:setGuestAddBinding(true)
    end

    --传统方式 手动输入手机号验证码
    local function __bindNewPhoneWithCode( )
        local panel = PhoneLoginPanel:create(phoneLoginInfo, source)
        panel:setBackCallback(onCancelBindPhone)
        panel:setPhoneLoginCompleteCallback(onPhoneLoginComplete)
        panel:popout()
    end

    AccountBindingLogic._isJustShanyanSuccess = false
    local function onShanyanSuccess( openId,phone,accessToken,isPhoneBind )
        onPhoneLoginComplete(openId,phone,accessToken)
        AccountBindingLogic._isJustShanyanSuccess = true
    end

    local function __bindNewPhone( ... )
        --尝试闪验一键获取手机号，否则使用传统方式
        local shanyan = require('zoo.util.ShanYanCtrl')
        shanyan:start(source,onShanyanSuccess,__bindNewPhoneWithCode,nil)
    end

    --是否可绑定
    if RealNameManager:isAdviceBindEnabled() then
        --是否有实名号码信息
        RealNameManager:havePhoneAuthedCanUseToBind(function ( phoneNum )
            RealNameManager:popoutAdviceBindPanel(phoneNum, function ( ... )
                --继续使用
                RealNameManager:bindAuthedPhoneNum(phoneNum, source, onPhoneLoginComplete, onReturnCallback)
            end, function ( ... )
                --换个号码
                __bindNewPhone()
            end)

        end, function ( ... )
            --没有实名号码信息
            __bindNewPhone()
        end)
    else
        --没有实名建议
        __bindNewPhone()
    end


    DcUtil:UserTrack({ category="setting",sub_category="setting_click_binding" ,object=PlatformAuthEnum.kPhone })
end

function AccountBindingLogic:updateSnsUserProfile( authorizeType,snsName,name,headUrl )
    local profile = UserManager.getInstance().profile
    local function isProfileCustomized()
        return profile.customProfile == true
    end

    -- 如果自定义了头像或昵称，就不再拿sns信息去覆盖

    local snsHeadUrl = headUrl
    if isProfileCustomized() or not shouldOverwriteHeadUrl(profile.headUrl, headUrl) then
        headUrl = UserManager:getInstance().profile.headUrl
    end
    if isProfileCustomized() then
        name = UserManager:getInstance().profile:getDisplayName()
    end


    local http = UpdateProfileHttp.new()
    
    local profile = UserManager.getInstance().profile
    profile:setSnsInfo(authorizeType, snsName, snsHeadUrl, name, headUrl)

    UserService.getInstance().profile:setSnsInfo(authorizeType, snsName, snsHeadUrl, name, headUrl)
    Localhost.getInstance():flushCurrentUserData()

    local snsPlatform = PlatformConfig:getPlatformAuthName(authorizeType)
    snsName = HeDisplayUtil:urlEncode(snsName)
    if name then
        name = HeDisplayUtil:urlEncode(name)
    end

    http:load(name, snsHeadUrl,snsPlatform,snsName, false)
end

function AccountBindingLogic:bindConnect(authorizeType,snsInfo,sns_token, onConnectFinish, onConnectError, onConnectCancel, source, hasReward)
    if not snsInfo then
        snsInfo = { snsName = Localization:getInstance():getText("game.setting.panel.use.device.name.default") }
    end
    if not AccountBindingLogic:isGuest() then 
        local saveUserID = UserManager:getInstance().user.uid
        SVIPGetPhoneManager.getInstance():setMergeID( saveUserID )
        AccountBindingLogic:preSnsBindConnect(authorizeType,snsInfo,sns_token, onConnectFinish, onConnectError, onConnectCancel, source, hasReward)
    else
        AccountBindingLogic:guestBindConnect(authorizeType,snsInfo,sns_token, onConnectFinish, onConnectError, onConnectCancel, source, hasReward)
    end
end

function AccountBindingLogic:preSnsBindConnect(authorizeType,snsInfo,sns_token, onConnectFinish, onConnectError, onConnectCancel, source, hasReward)
    local snsName = snsInfo.snsName
    local name = snsInfo.name
    local headUrl = snsInfo.headUrl
    
    local function onPreConnectFinish(evt)
        local resultCode = nil
        if evt and evt.data then 
            resultCode = evt.data.resultCode
        end
        if resultCode == PreExtraConnectErrorCode.kNeedConfirm then
            require "zoo.panel.loginAlert.BindNewAccountAlertPanel"
            local user = UserManager.getInstance().user
            local profile = evt.data.profile or {}
            local data = {
                loginType = authorizeType,
                uid     = profile.uid,
                name    = nameDecode(profile.name),
                headUrl = profile.headUrl,
                topLevelId = evt.data.topLevel,
            }
            local function onBindClk()
                local function snsBindConnect()
                    AccountBindingLogic:snsBindConnect(authorizeType,snsInfo,sns_token, onConnectFinish, onConnectError, source, hasReward)
                end
                setTimeOut(snsBindConnect, 0.01)
            end
            local function onCancelClk()
                if onConnectCancel then onConnectCancel() end
            end
            local panel = BindNewAccountAlertPanel:create(data, onBindClk, onCancelClk)
            panel:popout()
        elseif resultCode == PreExtraConnectErrorCode.kBindDirectly then
            AccountBindingLogic:snsBindConnect(authorizeType,snsInfo,sns_token, onConnectFinish, onConnectError, source, hasReward)
        elseif resultCode == PreExtraConnectErrorCode.kBindSameSns then
            local accountName = PlatformConfig:getPlatformNameLocalization(authorizeType)
            CommonTip:showTip(localize("error.tip.account.bonding1", {account = accountName}),"negative")
            if onConnectError then onConnectError() end
        elseif resultCode == PreExtraConnectErrorCode.kDataConflict then
            local accountName = PlatformConfig:getPlatformNameLocalization(authorizeType)
            CommonTip:showTip(localize("error.tip.account.bonding2", {account = accountName}),"negative")
            if onConnectError then onConnectError() end
        else
            CommonTip:showTip(localize("error.tip.account.bonding3"),"negative")
            if onConnectError then onConnectError() end
        end
    end
    local function onPreConnectError(evt)
        CommonTip:showTip(localize("error.tip.account.bonding3"),"negative")
        if onConnectError then onConnectError() end
    end
    local params = {
        openId = sns_token.openId,
        accessToken = sns_token.accessToken,
        snsName = HeDisplayUtil:urlEncode(snsName),
        deviceUdid = deviceUdid,
        snsPlatform = PlatformConfig:getPlatformAuthName(authorizeType),
    }
    local http = PreExtraConnectV4Http.new()
    http:addEventListener(Events.kComplete, onPreConnectFinish)
    http:addEventListener(Events.kError, onPreConnectError)
    http:syncLoad(params)
end

function AccountBindingLogic:snsBindConnect( authorizeType,snsInfo,sns_token, connectFinishCallback, connectErrorCallback , source, hasReward)
    local oldAuthorizeType = SnsProxy:getAuthorizeType()

    local snsName = snsInfo.snsName
    local name = snsInfo.name
    local headUrl = snsInfo.headUrl

    local function onConnectFinish( ... )
        AccountBindingLogic:updateSnsUserProfile(authorizeType,snsName,name,headUrl)

        if authorizeType ~= PlatformAuthEnum.kPhone then
            if not PlatformConfig:isQQPlatform() then
                SnsProxy:setAuthorizeType(authorizeType)
                SnsProxy:syncSnsFriend(sns_token)
                SnsProxy:setAuthorizeType(oldAuthorizeType)
            end
            
        end
        CCUserDefault:sharedUserDefault():setIntegerForKey('login.success.source.'..tostring(authorizeType), 3)
        if _G.isLocalDevelopMode then printx(0, "bindSns:connect success") end
        DcUtil:UserTrack({ category='setting', sub_category="setting_click_binding_success", object = authorizeType})        

        if hasReward and (source == AccountBindingSource.FROM_LOGIN or source == AccountBindingSource.ACCOUNT_SETTING) then
            if authorizeType == PlatformAuthEnum.k360 and BindQihooBonus:loginRewardEnabled() then
                BindQihooBonus:setShouldGetReward(true)
            elseif authorizeType == PlatformAuthEnum.kQQ and BindQQBonus:loginRewardEnabled() then
                BindQQBonus:setShouldGetReward(true)
            end
        end

        if connectFinishCallback then 
            connectFinishCallback() 
        end
    end

    local function onConnectError ( event )

        if tonumber(event.data) == 730764 then
            local tipStr = localize("setting.alert.content.2", 
                                    {account = PlatformConfig:getPlatformNameLocalization(authorizeType), 
                                     account1 = PlatformConfig:getPlatformNameLocalization(authorizeType),
                                     account2 =  PlatformConfig:getPlatformNameLocalization(authorizeType)
                                    })
                local txt = {tip = tipStr, 
                             yes = "知道了",
                             no = ""}

                CommonTipWithBtn:showTip(txt, 2, nil, nil, nil, true)
        else
            CommonTip:showTip("绑定账号失败！","negative")
        end
        if _G.isLocalDevelopMode then printx(0, "bindSns:snsBindConnect error") end
        if connectErrorCallback then
            connectErrorCallback()
        end
    end

    local params = {
        openId = sns_token.openId,
        accessToken = sns_token.accessToken,
        snsPlatform = PlatformConfig:getPlatformAuthName(authorizeType),
        snsName = HeDisplayUtil:urlEncode(snsName),
        deviceUdid = MetaInfo:getInstance():getUdid()
    }
    local http = ExtraConnectV4Http.new(true)    
    http:addEventListener(Events.kComplete, onConnectFinish)
    http:addEventListener(Events.kError, onConnectError)
    http:syncLoad(params)
end

function AccountBindingLogic:guestBindConnect( authorizeType,snsInfo,sns_token, finishCallback, errorCallback, cancelCallback, source, hasReward)

    local snsName = snsInfo.snsName
    local name = snsInfo.name
    local headUrl = snsInfo.headUrl
    source = source or AccountBindingSource.DEFAULT

    local function onFinish( mustExit )

        AccountBindingLogic.preconnectting = false

        if hasReward and (source == AccountBindingSource.FROM_LOGIN or source == AccountBindingSource.ACCOUNT_SETTING) then
            if authorizeType == PlatformAuthEnum.k360 and BindQihooBonus:loginRewardEnabled() then
                BindQihooBonus:setShouldGetReward(true)
            elseif authorizeType == PlatformAuthEnum.kQQ and BindQQBonus:loginRewardEnabled() then
                BindQQBonus:setShouldGetReward(true)
            end
        end


        CCUserDefault:sharedUserDefault():setIntegerForKey('login.success.source.'..tostring(authorizeType), 3)
        DcUtil:UserTrack({ category='setting', sub_category="setting_click_binding_success", object = authorizeType})

        local needUpdateProfile = true
        if authorizeType == PlatformAuthEnum.kPhone then
            local snsInfo = UserManager.getInstance().profile:getSnsInfo(authorizeType)
            if snsInfo then needUpdateProfile = false end
        end
        
        if mustExit then
            if needUpdateProfile then
                AccountBindingLogic:updateSnsUserProfile(authorizeType,snsName,name,headUrl)  -- TODO
            end
            if finishCallback then
                finishCallback(mustExit)
            end            
            if __ANDROID then PrepackageUtil:restart()
            else Director.sharedDirector():exitGame() end        
        else
            _G.sns_token = sns_token
            if needUpdateProfile then
                AccountBindingLogic:updateSnsUserProfile(authorizeType,snsName,name,headUrl)  -- TODO
            end
            if authorizeType ~= PlatformAuthEnum.kPhone then
                SnsProxy:syncSnsFriend()
            end

            HomeScene:sharedInstance().settingButton:updateDotTipStatus()
            if finishCallback then
                finishCallback(mustExit)
            end    
        end
    end

    local function onCancel( ... )
        AccountBindingLogic.preconnectting = false

        if cancelCallback then
            cancelCallback()
        end
    end

    local function onError(  )
        AccountBindingLogic.preconnectting = false

        if errorCallback then
            errorCallback()
        end

        CommonTip:showTip("绑定账号失败！","negative")
        if _G.isLocalDevelopMode then printx(0, "bindSns:guestBindConnect connect error") end
    end



    local openId = sns_token.openId
    local accessToken = sns_token.accessToken
    local snsPlatform = PlatformConfig:getPlatformAuthName(authorizeType)
    local oldSnsPlatform =  nil

    local function preconnect( onGetPreConnect )

        local function onError( evt )
            onGetPreConnect(nil)
        end
        local function onFinish( evt )  
             --svip 记录合并的账号ID
            SVIPGetPhoneManager.getInstance():setMergeID( evt.data.uid )

            onGetPreConnect(evt.data)

        end

        local cachedHttpList = UserService.getInstance():getCachedHttpData()
        local hasCache = cachedHttpList and #cachedHttpList > 0

        local http = PreQQConnectHttp.new(true)
        http:addEventListener(Events.kComplete, onFinish)
        http:addEventListener(Events.kError, onError)
        http:syncLoad(openId,accessToken,hasCache,snsPlatform,HeDisplayUtil:urlEncode(snsName))

        --这个请求会改变sessionKey，请求响应之前，不应发出别的请求，
        AccountBindingLogic.preconnectting = true
    end

    local function connect( onGetConnect )

        local function onError( evt )
            onGetConnect(nil)
        end

        local function onFinish( evt )
            onGetConnect(evt.data)
        end

        local http = QQConnectHttp.new(true)
        http:addEventListener(Events.kComplete, onFinish)
        http:addEventListener(Events.kError, onError)
        http:syncLoad(openId,accessToken,snsPlatform,HeDisplayUtil:urlEncode(snsName))
    end

    
    local function onGetConnect( result )
        if result and result.uid and result.uuid then
            local serverNewUid = result.uid
            local serverNewUDID = result.uuid
            local localOldUid = UserManager.getInstance().uid

            UdidUtil:saveUdid(serverNewUDID)
            Localhost.getInstance():setLastLoginUserConfig(serverNewUid, serverNewUDID, _G.kDefaultSocialPlatform)
            if tostring(serverNewUid) ~= tostring(localOldUid) then
                DcUtil:newUser(true)
                Localhost.getInstance():deleteUserDataByUserID(localOldUid)
                local tempData = {}
                local function onRegisterFinish( ... ) 
                    SnsProxy:setAuthorizeType(authorizeType)
                    Localhost:setCurrentUserOpenId(sns_token.openId,sns_token.accessToken,authorizeType)

                    onFinish(true)
                end
                local function onRegisterError( ... )
                    UdidUtil:revertUdid()
                    Localhost.getInstance():setLastLoginUserConfig(0, nil, _G.kDefaultSocialPlatform) 
                    if tempData.countDownAnim ~= nil and not tempData.countDownAnim.isDisposed then
                        tempData.countDownAnim:removeFromParentAndCleanup(true)
                        tempData.countDownAnim = nil
                    end
                    onFinish(true)
                end

                local scene = Director:sharedDirector():getRunningScene()
                if scene then 
                    tempData.countDownAnim = CountDownAnimation:createNetworkAnimation(scene, onRegisterError) 
                end

                kDeviceID = serverNewUDID            
                local logic = PostLoginLogic.new()
                logic:addEventListener(PostLoginLogicEvents.kComplete, onRegisterFinish)
                logic:addEventListener(PostLoginLogicEvents.kError, onRegisterError)
                logic:load()
            else
                kDeviceID = serverNewUDID
                UserManager.getInstance().sessionKey = kDeviceID
                Localhost.getInstance():flushCurrentUserData()

                ConnectionManager:invalidateSessionKey()

                SnsProxy:setAuthorizeType(authorizeType)
                Localhost:setCurrentUserOpenId(sns_token.openId,nil,authorizeType)

                onFinish(false)
            end
        else
            onError()
            return
        end

    end

    local function onGetPreConnect( result )
        if not result then 
            onError()
            return
        end

        local errorCode = result.errorCode or 0
        local alertCode = result.alertCode or 0
        if errorCode > 0 then
            onError()
            return
        end

        if alertCode > 0 then 
                local function onTouchPositiveButton()

                    --svip领奖标记
                    local saveUserID = UserManager:getInstance().user.uid
                    local MergeID = SVIPGetPhoneManager.getInstance():getMergeID()
                    if MergeID and MergeID == saveUserID then
                    else
                        --领奖记录报给主ID
                        local function onRequestSuccess()
                        end  

                        local function onRequestFail()
                        end  

                        local function onRequestCancel()
                        end  

                        SVIPGetPhoneManager.getInstance():newOpNotifyHttp( onRequestSuccess, onRequestFail, onRequestCancel, MergeID )
                    end

                    connect(onGetConnect)
                end
                local function onTouchNegativeButton()
                    onCancel()
                    if source == AccountBindingSource.ADD_FRIEND then
                        if authorizeType == PlatformAuthEnum.kPhone then
                            CommonTip:showTip(localize("add.friend.panel.cancel.phonebook"), "negative")
                        else
                            --todo:
                        end
                    end
                end

            local entrance = authorizeType == PlatformAuthEnum.kPhone and AccountBindingSource.DEFAULT or AccountBindingMergeSource[source]
            if _G.isLocalDevelopMode then printx(0, "alert code: "..tostring(alertCode)) end

            local function showMergeAlert()
                local platform = PlatformConfig:getPlatformNameLocalization(authorizeType)
                local formated = QzoneSyncLogic:formatLevelInfoMessage(result.mergeLevelInfo or 1, tonumber(result.mergeUpdateTimeInfo))
                local accMode = Localization:getInstance():getText("loading.tips.preloading.warnning.mode1")

                local infoStr = "loading.tips.preloading.warnning.new7"
                local bindReward = PushBindingLogic:getAwardTimeLeft()>0
                print("showMergeAlert() ShanYan:",AccountBindingLogic._isJustShanyanSuccess,
                    "-reward:",bindReward,hasReward,
                    "-isPhone:",authorizeType == PlatformAuthEnum.kPhone,
                    PushBindingLogic:getAwardTimeLeft())

                if AccountBindingLogic._isJustShanyanSuccess then
                    if authorizeType == PlatformAuthEnum.kPhone and (bindReward or hasReward) then
                        infoStr = "loading.tips.preloading.warnning.new8"
                    end
                    AccountBindingLogic._isJustShanyanSuccess = false
                end

                local mergePanel = require("zoo.panel.accountPanel.NewQQMergePanel"):create(
                    entrance, 
                    localize("loading.tips.start.btn.qq", {platform=platform}),
                    localize(infoStr, {platform = platform, user=formated, n="\n"}))
                mergePanel:setOkCallback(onTouchPositiveButton)
                mergePanel:setCancelCallback(onTouchNegativeButton)
                mergePanel:popout()
            end

            if alertCode == QzoneSyncLogic.AlertCode.MERGE then
                showMergeAlert()
            elseif alertCode == QzoneSyncLogic.AlertCode.DIFF_PLATFORM then
                local oldPlatform = PlatformConfig:getDevicePlatformLocalizeById(result.lastPlatform)
                local panel = require("zoo.panel.accountPanel.NewCrossDevicePanel"):create(entrance, oldPlatform)
                panel:setOkCallback(onTouchPositiveButton)
                panel:setCancelCallback(onTouchNegativeButton)
                panel:popout() 

            elseif alertCode == QzoneSyncLogic.AlertCode.NEED_SYNC then
                local platform = PlatformConfig:getPlatformNameLocalization(authorizeType)
                local cachedHttpList = UserService.getInstance():getCachedHttpData()
                local hasCache =  cachedHttpList and #cachedHttpList > 0

                if hasCache then
                    local syncPanel = require("zoo.panel.accountPanel.NewQQSyncPanel"):create( 
                        entrance,
                        Localization:getInstance():getText("loading.tips.start.btn.qq", {platform=platform}),
                        Localization:getInstance():getText("loading.tips.preloading.warnning.new6", {platform=platform, n="\n"}))
                    syncPanel:setOkCallback(onTouchPositiveButton)
                    syncPanel:setCancelCallback(onTouchNegativeButton)
                    syncPanel:popout()
                else
                    --hacCache 为空的时候再弹一次merge面板
                    showMergeAlert()

--                    onTouchPositiveButton()
                end
            else
                if _G.isLocalDevelopMode then printx(0, "unhandled alert code!!!!!!!!!") end
                onError()
                return
            end
        else
            onGetConnect(result)
        end
    end

    RequireNetworkAlert:callFuncWithLogged(function( ... )
        preconnect(onGetPreConnect)
        
    end,function( ... )
        onError()

    end,kRequireNetworkAlertAnimation.kSync)
end


function AccountBindingLogic:changePhoneBinding(onConfirmCallback, onReturnCallback)
    local function onCancel()
        if onReturnCallback then
            onReturnCallback()
        end
        CommonTip:showTip("您已取消更换手机号~")
    end

    local function requestRebindingHttp( openId,phoneNumber,accessToken )
        local function onRebindingFinish(event)
            UserManager:getInstance().userExtend:setFlagBit(8, true)

            local snsName = phoneNumber
            UserManager:getInstance().profile:setSnsInfo(PlatformAuthEnum.kPhone, snsName)

            CommonTip:showTip(Localization:getInstance():getText("setting.alert.content.8"),"positive",nil,4)

            DcUtil:UserTrack({ category="setting", sub_category="setting_click_switch_success" })
        end

        local function onRebindingError(evt)
            CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(evt.data)), "negative")
        end

        local http = RebindingHttp.new()
        http:addEventListener(Events.kComplete, onRebindingFinish)
        http:addEventListener(Events.kError, onRebindingError)
        http:load(phoneNumber,openId,accessToken)
    end

    local function popoutNewPhonePanel( ... )
        local phoneNumber = UserManager:getInstance().profile:getSnsUsername(PlatformAuthEnum.kPhone) or ''

        local phoneLoginInfo = PhoneLoginInfo.new(PhoneLoginMode.kBindingNewLogin)
        phoneLoginInfo:setOldPhone(phoneNumber)

        local panel = PhoneLoginPanel:create(phoneLoginInfo)
        panel:setBackCallback(onCancel)
        panel:setPhoneLoginCompleteCallback(requestRebindingHttp)
        panel:popout()
    end

    local function popoutOldPhonePanel( ... )
        local phoneLoginInfo = PhoneLoginInfo.new(PhoneLoginMode.kBindingOldLogin)
        local phoneNumber = UserManager:getInstance().profile:getSnsUsername(PlatformAuthEnum.kPhone) or ''

        local panel = VerifyPhoneConfirmPanel:create(phoneLoginInfo,phoneNumber,"changeBindingVerifyOldV2")
        panel:setBackCallback(onCancel)
        panel:setPhoneLoginCompleteCallback(popoutNewPhonePanel)
        panel:popout()
    end

    local function popoutSendCodeConfirmPanel( ... )
        -- if onConfirmCallback then
        --    onConfirmCallback()
        -- end        
        local phoneNumber = UserManager:getInstance().profile:getSnsUsername(PlatformAuthEnum.kPhone) or ''
        phoneNumber = string.sub(phoneNumber,1,3) .. string.rep("*",4) .. string.sub(phoneNumber,-4,-1)
        local panel = SendCodeConfirmPanel:create(phoneNumber,true,PhoneLoginMode.kBindingOldLogin)
        panel:setCancelCallback(onCancel)
        panel:setOkCallback(popoutOldPhonePanel)
        panel:popout()
    end

    local function verifyOldPhone( ... )
        local phoneLoginInfo = PhoneLoginInfo.new(PhoneLoginMode.kBindingOldLogin)

        local phoneNumber = UserManager:getInstance().profile:getSnsUsername(PlatformAuthEnum.kPhone) or ''
        local function onSuccess( data )
            HttpsClient.setSessionId(data.sessionId)
            popoutSendCodeConfirmPanel()

            DcUtil:UserTrack({ 
                category='login', 
                sub_category='login_account_phone', 
                step=1, 
                place=phoneLoginInfo:getDcPlace(),
                where=phoneLoginInfo:getDcWhere(),
                custom=phoneLoginInfo:getDcCustom(),
            })
        end
        local function onError( errorCode, errorMsg, data )
            CommonTip:showTip(localize("phone.register.error.tip."..errorCode))
        end
        
        local data = { phoneNumber = phoneNumber, deviceUdid = MetaInfo:getInstance():getUdid() }
        local httpsClient = HttpsClient:create("changeBindingVerifyOldPhoneNumber",data,onSuccess,onError)
        httpsClient:send()
    end

    local function popoutConfirmPanel( ... )
        local panel = ChangePhoneConfirmPanel:create()
        panel:setCancelCallback(onCancel)
        panel:setOkCallback(verifyOldPhone)
        panel:popout()
    end

    popoutConfirmPanel()

    DcUtil:UserTrack({ category='setting', sub_category="setting_click_switch" })
end

function AccountBindingLogic:bindNewSns(authorizeType, onConnectFinish, onConnectError, onConnectCancel, source, hasReward)

    local scene = Director:sharedDirector():getRunningScene()
    if not scene then
        return
    end
    local isCancel = false
    local autoCancelTimeOutId = nil
    local animation = nil
    local autoTimeOutOnEnterForground = 0.5

    local function cancelAutoRemoveAnimation()
        if autoCancelTimeOutId then
            cancelTimeOut(autoCancelTimeOutId)
            autoCancelTimeOutId = nil
        end
    end
    local function removeAnimation()
        cancelAutoRemoveAnimation()
        if animation then
            animation:removeFromParentAndCleanup(true)
            CountDownAnimation:removeEnterForegroundListener(animation)
            animation = nil
        end
    end
    local function onCloseBtnTapped()
        isCancel = true
        removeAnimation()
        if onConnectCancel then
            onConnectCancel()
        end
    end

    local function startAutoRemoveAnimation(timeout)
        if animation then
            local function autoCancel()
                if animation and not animation.isDisposed then onCloseBtnTapped() end
            end
            if autoCancelTimeOutId then cancelAutoRemoveAnimation() end
            autoCancelTimeOutId = setTimeOut(autoCancel, timeout or 0.5)
        end
    end

    animation = CountDownAnimation:createBindAnimation(scene, onCloseBtnTapped)
    local function onEnterForeground()
        startAutoRemoveAnimation(autoTimeOutOnEnterForground or 0.5)
    end
    if __IOS then
        CountDownAnimation:addEnterForegroundListener(animation, onEnterForeground)
    end

    local function onBindNewSnsSuccess(mustExit)
        if source == AccountBindingSource.FROM_LOGIN or 
           source == AccountBindingSource.ACCOUNT_SETTING then
            if not mustExit then
                local function popQQPanel()
                    if QQLoginReward:shouldGetReward() then QQLoginReward:receiveReward() end
                end

                if authorizeType == PlatformAuthEnum.kQQ and QQLoginReward:shouldGetReward() then
                    HomeScene:sharedInstance():runAction(CCCallFunc:create(popQQPanel))
                end
            end
        end
        if source ~= AccountBindingSource.PUSH_BIND_PANEL then
           PushBindingLogic:checkRemovePanelAndIcon(authorizeType)
        end

        AccountBindingLogic:onBindAccountSuccess()
        if onConnectFinish then onConnectFinish(mustExit) end
    end
    
    local oldAuthorizeType = SnsProxy:getAuthorizeType()
    local logoutCallback = {
        onSuccess = function(result)
            local function onSNSLoginResult( status, result )
                cancelAutoRemoveAnimation()
                if status == SnsCallbackEvent.onSuccess and result then
                    local sns_token = result
                    sns_token.authorType = authorizeType

                    if _G.isLocalDevelopMode then printx(0, "login Sns account success:" .. table.tostring(sns_token)) end

                    local function successCallback( ... )
                        if not isCancel then
                            if _G.isLocalDevelopMode then printx(0, "going to bind new sns account!!!!!!!!!") end
                            local snsInfo = {
                                snsName = SnsProxy.profile.nick,
                                name = SnsProxy.profile.nick,
                                headUrl = SnsProxy.profile.headUrl,
                            }

                            AccountBindingLogic:bindConnect(authorizeType,snsInfo,sns_token, onBindNewSnsSuccess, onConnectError, onConnectCancel, source, hasReward)

                            removeAnimation()
                        end

                        if _G.isLocalDevelopMode then printx(0, "bindSns: successCallback") end
                    end
                    local function errorCallback( ... )
                        if not isCancel then
                            AccountBindingLogic:bindConnect(authorizeType,nil,sns_token, onBindNewSnsSuccess, onConnectError, onConnectCancel, source, hasReward)
                            removeAnimation()
                        end

                        if _G.isLocalDevelopMode then printx(0, "~~~~~~~~~~~bindSns: errorCallback") end
                    end
                    local function cancelCallback( ... )
                       if not isCancel then
                            AccountBindingLogic:bindConnect(authorizeType,nil,sns_token, onBindNewSnsSuccess, onConnectError, onConnectCancel, source, hasReward)
                            removeAnimation()
                        end

                        if _G.isLocalDevelopMode then printx(0, "~~~~~~~~~~~~bindSns: cancelCallback") end
                    end
                   if authorizeType == PlatformAuthEnum.kWechat then
                        -- 获取profile 10s超时
                        cancelAutoRemoveAnimation()
                        startAutoRemoveAnimation(10)
                        SnsProxy:setWechatUserInfoTimeOut(10)
                    end
                    SnsProxy:setAuthorizeType(authorizeType)
                    SnsProxy:getUserProfile(successCallback,errorCallback,cancelCallback)
                    SnsProxy:setAuthorizeType(oldAuthorizeType)
                -- elseif status == SnsCallbackEvent.onCancel then
                --     local platform = PlatformConfig:getPlatformNameLocalization(authorizeType)
                --     CommonTip:showTip(localize("add.friend.panel.cancel.login.qq", {platform = platform}))
                --     removeAnimation()
                --     if onConnectCancel then
                --         onConnectCancel()
                --     end
                else
                    if not isCancel then
                        if source == AccountBindingSource.ADD_FRIEND then
                            --CommonTip:showTip("绑定账号失败！","negative")
                            if _G.isLocalDevelopMode then printx(0, "sync sns friends canceled!!!!!!!") end
                        else
                            CommonTip:showTip("绑定账号失败！","negative")
                        end
                        
                        removeAnimation()
                        if onConnectError then
                            onConnectError()
                        end
                    end

                    if _G.isLocalDevelopMode then printx(0, "bindSns:login error " .. tostring(status)) end
                end
            end
            if authorizeType == PlatformAuthEnum.kWechat then
                --获取token 5s 超时
                SnsProxy:setWechatLoginTimeOut(6)
                autoTimeOutOnEnterForground = 6
            end
            SnsProxy:setAuthorizeType(authorizeType)
            SnsProxy:login(onSNSLoginResult)
            SnsProxy:setAuthorizeType(oldAuthorizeType)
        end,
        onError = function(errCode, msg) 
            if not isCancel then
                CommonTip:showTip("绑定账号失败！","negative")
                removeAnimation()
                if onConnectError then
                    onConnectError()
                end
            end

            if _G.isLocalDevelopMode then printx(0, "bindSns:",errCode,msg) end
        end,
        onCancel = function()
            if not isCancel then
                CommonTip:showTip("绑定账号失败！","negative")
                removeAnimation()
                if onConnectCancel then
                    onConnectCancel()
                end
            end

            if _G.isLocalDevelopMode then printx(0, "bindSns: cancel") end
        end
    }

    SnsProxy:setAuthorizeType(authorizeType)
    SnsProxy:logout(logoutCallback)
    SnsProxy:setAuthorizeType(oldAuthorizeType)

    DcUtil:UserTrack({ category='setting', sub_category="setting_click_binding", object = authorizeType})
end

function AccountBindingLogic:getOtherAccountDatas()
    local otherAccounts = {}
    local authConfig = PlatformConfig.authConfig
    if type(authConfig) == "table" then
        for _, v in pairs(authConfig) do
            if v ~= PlatformAuthEnum.kGuest then
                table.insert(otherAccounts, v)
            end
        end
    else
        if authConfig ~= PlatformAuthEnum.kGuest then
            table.insert(otherAccounts, authConfig)
        end
    end

    local accDatas = {}
    if #otherAccounts > 0 then
        table.sort(otherAccounts,function(a,b) return PlatformAuthPriority[a] < PlatformAuthPriority[b] end)
        for _, v in ipairs(otherAccounts) do
            local data = {authType = v}
            data.nickName = UserManager:getInstance().profile:getSnsUsername(v)
            data.isBinded = data.nickName and true or false
            table.insert(accDatas, data)
        end
    end
    return accDatas
end

function AccountBindingLogic:getPlatformAuthRcmds()
    local ret = {}
    local maintenance = MaintenanceManager:getInstance():getMaintenanceByKey("BindPhoneOrQQBonus")
    local cfgStr = nil
    if maintenance ~= nil then
        if maintenance.enable then
            cfgStr = maintenance.extra or ""
         else
            return ret
         end
    else
        cfgStr = ""
    end

    local cfgAry = string.split(cfgStr, "|")
    if cfgAry[1] == "qq" then
        ret = {
                  PlatformAuthEnum.k360,
                  PlatformAuthEnum.kQQ,
                  PlatformAuthEnum.kWechat,
                  PlatformAuthEnum.kPhone,
              }
    else
        ret = {
                  PlatformAuthEnum.k360,
                  PlatformAuthEnum.kPhone,
                  PlatformAuthEnum.kQQ,
                  PlatformAuthEnum.kWechat,
              }
    end
    if AccountBindingLogic:isQQNotRecommand() then
        table.removeValue(ret, PlatformAuthEnum.kQQ)
    end
    return ret
end

function AccountBindingLogic:getRcmdAccountType()
    local authRcmdsConfig = AccountBindingLogic:getPlatformAuthRcmds()
    for i, v in ipairs(authRcmdsConfig) do
        if PlatformConfig:hasAuthConfig(v) and not UserManager.getInstance().profile:getSnsInfo(v) then
            return v
        end
    end
    return nil
end