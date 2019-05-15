require "zoo.loader.PreloadingScene"
require "hecore.display.TextField"
require "hecore.display.ArmatureNode"
require "hecore.ui.PopoutManager"
require "hecore.ui.ProgressBar"
require "hecore.debug.AdvancedLogger"

require "zoo.config.ResourceConfig"
require "zoo.ui.InterfaceBuilder"
require "zoo.ui.ButtonBuilder"

require "zoo.net.Localhost"

require "zoo.util.FrameLoader"
require "zoo.util.HeadImageLoader"
require "zoo.util.WeChatSDK"
require "zoo.util.GameCenterSDK"
require "zoo.util.AnimationUtil"
require "zoo.util.LogicUtil"
require "zoo.util.UIUtils"

require "zoo.scenes.HomeScene"
require "zoo.scenes.PreloadingSceneUI"

require "zoo.data.LevelConfigGroupMgr"
require "zoo.data.LevelMapManager"
require "zoo.data.MetaManager"
require "zoo.data.UserManager"
require "zoo.data.LadyBugMissionManager"
require "zoo.data.UserEnergyRecoverManager"
require "zoo.util.UpdateCheckUtils"
require "zoo.data.MaintenanceManager"

require "zoo.util.FUUUManager"
require "zoo.gamePlay.userTags.UserTagManager"
require "zoo.gamePlay.LevelDifficultyAdjustManager"
require "zoo.net.LoginLogic"
require "zoo.net.SyncManager"

require "hecore.sns.SnsProxy"
require "zoo.util.SnsUtil"

-- require "zoo.panel.AnnouncementPanel"

require "zoo.gameGuide.BindPhoneGuideLogic"

require "zoo.panel.phone.LoginInfoChangePanel"
require "zoo.gamePlay.CheckPlay"
require "zoo.gamePlay.QACheckPlayManager"

require "zoo.panel.broadcast.BroadcastManager"

require "zoo.panel.ExitAlertPanel"

require 'zoo.account.PhoneLoginManager'
require "zoo.util.PackageUtil"
require "zoo.panel.loginAlert.LoginAlertModel"
require 'zoo.panel.messageCenter.QQLoginReward'--这个文件现在是各种绑定账号后给奖励的面板集合
require "zoo.util.GameSpeedManager"
require "zoo.gamePlay.config.GamePlayGlobalConfigs"
require "zoo.util.MemClass"
require "zoo.util.LocalBox"
require "zoo.gamePlay.GameBoardLogic"

require "zoo.heai.HEAICore"

if not ( GameLauncherContext and GameLauncherContext.ver and  GameLauncherContext.ver >= 2 ) then
    package.loaded["zoo/util/TimerUtil.lua"] = nil
    _G["zoo/util/TimerUtil.lua"] = nil
    package.loaded["zoo.util.TimerUtil"] = nil
    _G["zoo.util.TimerUtil"] = nil

    require "zoo.util.TimerUtil"


    package.loaded["zoo/loader/GameLauncherContext.lua"] = nil
    _G["zoo/loader/GameLauncherContext.lua"] = nil
    package.loaded["zoo.loader.GameLauncherContext"] = nil
    _G["zoo.loader.GameLauncherContext"] = nil

    require "zoo.loader.GameLauncherContext"
end

LocalBox:initByStep1()

kLoginErrorType = table.const {
    register = 1,
    changeUser = 2,
    syncData = 3,
    connect = 4,
}

local JPPreloadingScene = class(Scene)

function JPPreloadingScene:create()
    local s = JPPreloadingScene.new()
    GameLauncherContext:getInstance():onPreloadingScene()
    s:initScene()
    return s
end

function JPPreloadingScene:onInit()
    self.name = "JPPreloadingScene"
    PreloadingSceneUI:initUI(self)

    self:handleInitPermissions()
end

function JPPreloadingScene:handleInitPermissions()
    if __ANDROID then 
        if PermissionManager.getInstance():hasPermissions({PermissionsConfig.READ_PHONE_STATE, 
                                                            PermissionsConfig.READ_EXTERNAL_STORAGE, 
                                                            PermissionsConfig.SEND_SMS}) then
            self.startInit = true 
            self:initialize()
        else
            if not self.startInit then
                local initPermissionsGranted = false
                self.startInit = true
                local INIT_PERMISSIONS_ALL_GRANTED = "init_permissions_all_granted"
                AndroidEventDispatcher:getInstance():addEventListener(INIT_PERMISSIONS_ALL_GRANTED, function ()
                    initPermissionsGranted = true
                end)
                local function update()
                    if not initPermissionsGranted then return end
                    if self.schedulerId then 
                        Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedulerId)
                    end
                    self.schedulerId = nil
                    self:initialize()
                end
                self.schedulerId = Director:sharedDirector():getScheduler():scheduleScriptFunc(update, 0, false)
            end
        end
    else
        self:initialize()
    end
end

function JPPreloadingScene:initialize()
    Notify:dispatch("AutoPopoutInitEvent")
    HEAICore:init()
    LevelMapManager.getInstance():initialize()
    MetaManager.getInstance():initialize()
    GameCenterSDK:getInstance():authenticateLocalUser()
    PlatformConfig:loadPayementConfig()
    SnsProxy:initPlatformConfig() 
    
    self:checkNeedRegister()

    RealNameManager:getLocationInfoAsync()

    
    self:preloadResource() 
    self:loadAnnouncement()

    BroadcastManager:getInstance():initFromConfig()
end

function JPPreloadingScene:updateConfig()
    local function onUpdateConfigError( evt )
        if evt then evt.target:removeAllEventListeners() end
        if _G.isLocalDevelopMode then printx(0, "onUpdateConfigFinish error") end
    end
    local function onUpdateConfigFinish( evt )
        evt.target:removeAllEventListeners()
        if _G.isLocalDevelopMode then printx(0, "onUpdateConfigFinish finished", table.tostring(evt.data)) end
        if evt.data then
            Localhost.getInstance():saveUpdatedGlobalConfig(evt.data)
        end
    end 
    local http = UpdateConfigFromServerHttp.new()
    http:addEventListener(Events.kComplete, onUpdateConfigFinish)
    http:addEventListener(Events.kError, onUpdateConfigError)
    http:load()
end

function JPPreloadingScene:toggleLoginUIElements(enable)
    if self.antiAddictionText then
        self.antiAddictionText:setVisible(enable)
    end

    if enable then
        self:showButtons()
    else
        self:hideButtons()
    end
end

function JPPreloadingScene:loadAnnouncement()
    AnnoucementMgr.getInstance():loadAnnouncement(AnnouncementPosType.kLoading, function( xml )
        if self.isDisposed then 
            return
        end
        if not xml then
            return 
        end
        local announcements = AnnoucementMgr.getInstance():parseAnnouncement(xml)
        if _G.isLocalDevelopMode then printx(0, "announcements",table.tostring(announcements)) end
        if table.size(announcements) <= 0 then 
            return 
        end

        if not self.isLoadResourceComplete then 
            self.announcements = announcements
        else
            if self.stopAutoLogin then
                self:stopAutoLogin()
            end
            self:toggleLoginUIElements(false) 
            AnnouncementPanel:create(AnnouncementPosType.kLoading, announcements):popout(function ()
                if self.startAutoLogin then
                    self:startAutoLogin()
                end
                self:toggleLoginUIElements(true)
            end) 
        end
    end)
end

function JPPreloadingScene:checkNeedRegister()
    local function onRegisterSuccess(evt)
        evt.target:rma()
        
        local loginInfo = evt.data
        local userId = loginInfo.uid
        local sessionKey = loginInfo.sk
        local platform = loginInfo.p
        if loginInfo.isNew == false then
            self.detectLocalOldUser = true
        end
        Localhost.getInstance():setLastLoginUserConfig(userId, sessionKey, platform)
    end

    local function guestLoginNewUser(evt)
        evt.target:rma()

        local registerNewUserProcessor = require("zoo.loader.RegisterNewUserProcessor").new()
        registerNewUserProcessor:ad(Events.kComplete, onRegisterSuccess)
        registerNewUserProcessor:start()
    end

    local function guestLoginOldUser(evt)
        evt.target:rma()
        self.detectLocalOldUser = true
    end

    local registerDetectProcessor = require("zoo.loader.NeedRegisterDetectProcessor").new()
    registerDetectProcessor:ad(registerDetectProcessor.events.kLocalOldUser, guestLoginOldUser)
    registerDetectProcessor:ad(registerDetectProcessor.events.kLocalNewUser, guestLoginNewUser)
    registerDetectProcessor:start()
end

function JPPreloadingScene:preloadResource()
    self:doLoadResource()
end

function JPPreloadingScene:doLoadResource()
    local function onLoadResourceComplete(evt)
        evt.target:rma()

        if not _G.isLocalDevelopMode then
            --
--

        end
        GameLauncherContext:getInstance():onPreloadingSceneResLoadFinish()
        PreloadingSceneUI:hideAntiAddiction(self)

        local function afterAcceptAgreement()
            if self.announcements then
                AnnouncementPanel:create(AnnouncementPosType.kLoading, self.announcements):popout(function ()
                    self:buildAuthUI()
                end) 
            else
                self:buildAuthUI()
            end
        end

        require "zoo.scenes.component.loadingScene.UserAgreementAlertPanel"
        if UserAgreementAlertPanel:checkNeedPopout() then
            UserAgreementAlertPanel:create():popout(function()
                UserAgreementAlertPanel:saveAcceptFlag()
                afterAcceptAgreement()
                end)
        else
            afterAcceptAgreement()
        end 
        self.isLoadResourceComplete = true

        if not __WP8 then AsyncLoader:getInstance():load() end
        _G.kResourceLoadComplete = true
    end
    local loadResourceProcess = require("zoo.loader.LoadResourceProcessor").new() 
    loadResourceProcess:addEventListener(Events.kComplete, onLoadResourceComplete)
    loadResourceProcess:start(self.statusLabel, self.statusLabelShadow, self.progressBar)
end

function JPPreloadingScene:startReplay()
end

function JPPreloadingScene:buildAuthUI()
    self.authButton1, self.authButton2, self.guestButton, self.agreement = PreloadingSceneUI:buildJPOAuthLoginButtons(self)

    local function onTouchOAuthLogin(evt)
        GameLauncherContext:getInstance():onTouchLogin()
        self:onTouchOAuthLogin(evt, true)
    end

    local function onTouchGuestLogin(evt)
        GameLauncherContext:getInstance():onTouchLogin()
        self:onTouchGuestLogin(evt)
    end

    if RealNameManager:isGuestLoginAlertEnable() then
        onTouchGuestLogin = RealNameManager:decorateAlertGuest(function ()
            -- do nothing
        end, onTouchGuestLogin)
    end

    self.authButton1:addEventListener(DisplayEvents.kTouchTap, function (evt)
        onTouchOAuthLogin(evt)
    end, self.authButton1)
    self.authButton2:addEventListener(DisplayEvents.kTouchTap, function (evt)
        onTouchOAuthLogin(evt)
    end, self.authButton2)
    -- self.guestButton:addEventListener(DisplayEvents.kTouchTap, function (evt)
    --     onTouchGuestLogin(evt)
    -- end)


    self.authButton1:setEnabled(true)
    self.authButton2:setEnabled(true)
    self.guestButton:setEnabled(false)
    self.guestButton:setVisible(false)

    if self.agreement then
        if self.agreement.touchLayer and not self.agreement.touchLayer.isDisposed then
            self.agreement.touchLayer:setTouchEnabled(true)
        end
        CCUserDefault:sharedUserDefault():setBoolForKey("game.user.agreement.checked", false)
    end

    local lastAuthorType = PlatformConfig:getLastPlatformAuthType()
    if lastAuthorType and not PlatformConfig:hasAuthConfig(lastAuthorType) then
        self:logoutWithChangeAccount()
    end

    self:tryAutoLogin()
end

function JPPreloadingScene:onTouchGuestLogin(evt)
    if self.stopAutoLogin then
        self:stopAutoLogin()
    end
    self:checkAgreement(function()
        self:onGuestButtonTouched()
        DcUtil:UserTrack({ category='login', sub_category='login_click_custom' })
    end)
end

function JPPreloadingScene:onTouchOAuthLogin(evt, fromBtnClick)
    if self.stopAutoLogin then
        self:stopAutoLogin()
    end
    self:checkAgreement(function()
        self:onOAuthButtonTouched(evt.target.btnType, fromBtnClick)
    end)
end

function JPPreloadingScene:onTouchChangeAccount(evt)
    if self.stopAutoLogin then
        self:stopAutoLogin()
    end
    self:checkAgreement(function()
        self:onChangeAccountButtonTouched()
    end)
end

function JPPreloadingScene:checkAgreement(cb)
    if self.antiAddictionText and self.antiAddictionText:isVisible() then
        self.antiAddictionText:setVisible(false)
    end

    if self.agreement then
        if not self.agreement.isDisposed and
            self.agreement.checked then
            if self.agreement.touchLayer and not self.agreement.touchLayer.isDisposed then
                self.agreement.touchLayer:setTouchEnabled(false)
            end
            cb()
            CCUserDefault:sharedUserDefault():setBoolForKey("game.user.agreement.checked", true)
        else
            CommonTip:showTip(Localization:getInstance():getText("loading.agreement.button.reject"))       
        end
    else
        cb()
    end   
end

function JPPreloadingScene:isCheckAgreement()
    if self.agreement and not self.agreement.isDisposed then
        return self.agreement.checked
    else
        return true
    end
end

function JPPreloadingScene:autoLogin()
    self.startAutoLogin = nil
    self.stopAutoLogin = nil
    local isLogin = SnsProxy:isLogin()
    
    if isLogin then
        local lastLoginUserInfo = Localhost.getInstance():readLastLoginUserData()
        if not lastLoginUserInfo then 
            SnsProxy:logout()
            return 
        end
        function self:startAutoLogin()
            if not self:isCheckAgreement() then
                return
            end
            --自动登录参数构建
            local evt = {}
            evt.target = {}
            evt.target.btnType = SnsProxy:getAuthorizeType()

            -- 3秒后自动登录
            local winSize = CCDirector:sharedDirector():getWinSize()
            local origin = CCDirector:sharedDirector():getVisibleOrigin()

            local function onAutoLoginCallback()
                if self.autoLoginTimeOutId then 
                    cancelTimeOut(self.autoLoginTimeOutId) 
                    self.autoLoginTimeOutId = nil
                end
                self:onTouchOAuthLogin(evt, false)
            end
            local function onChangeAccountCallback()
                self:showButtons()
                self:onTouchChangeAccount()
            end
            local autoLoginPanel = nil
            -- if false and WXJPPackageUtil.getInstance():checkIsLoginAutoChange() then 
            --     --sdk的异账号调用 没有走到授权部分 这里不会被调用了
            --     autoLoginPanel = require("zoo.panel.accountPanel.JPAutoLoginPanel"):create(onAutoLoginCallback, onChangeAccountCallback)
            -- else
                local loginUserData = lastLoginUserInfo.user
                autoLoginPanel = require("zoo.panel.accountPanel.AutoLoginPanel"):create(loginUserData, onAutoLoginCallback, onChangeAccountCallback)
            -- end
            local panelSize = autoLoginPanel:getGroupBounds().size
            autoLoginPanel:setPosition(ccp(origin.x + (winSize.width - panelSize.width) / 2, origin.y + panelSize.height / 2 + 250))
            self:addChild(autoLoginPanel)
            
            local function delayAutoLogin()
                self.autoLoginScheduleId = nil
                self:onTouchOAuthLogin(evt, false)
            end
            self.autoLoginTimeOutId = setTimeOut(delayAutoLogin, 3)
            self.autoLoginPanel = autoLoginPanel

            self:hideButtons()
            self.isDoingAutoLogin = true
        end

        function self:stopAutoLogin()
            if self.autoLoginTimeOutId then 
                cancelTimeOut(self.autoLoginTimeOutId) 
                self.autoLoginTimeOutId = nil
            end
            if self.autoLoginPanel and not self.autoLoginPanel.isDisposed then 
                self.autoLoginPanel:removeFromParentAndCleanup(true) 
                self.autoLoginPanel = nil
            end
            self.isDoingAutoLogin = false
            self:showButtons()
        end
        self:startAutoLogin()
    end
end

function JPPreloadingScene:tryAutoLogin()
    self.loadStable = true
    local loginType = WXJPPackageUtil.getInstance():getDiffLoginType()

    local function imitateAutoLogin(loginType)
        WXJPDiffLoginUtil.getInstance():clean()
        self:onOAuthButtonTouched(loginType, false)
    end

    if loginType then 
        if WXJPDiffLoginUtil.getInstance():getDelayHandleDiff() then 
            WXJPDiffLoginUtil.getInstance():setDelayHandleDiff(false)
            WXJPDiffLoginUtil.getInstance():showDiffLoginPanel(function ()
                SnsProxy:logout()
                self:logout()
                imitateAutoLogin(loginType)
            end, function ()
                WXJPDiffLoginUtil.getInstance():clean()
                self:autoLogin()
            end)
        elseif WXJPDiffLoginUtil.getInstance():getDelayHandleAuto() then 
            WXJPDiffLoginUtil.getInstance():setDelayHandleAuto(false)
            imitateAutoLogin(loginType)
        else
            imitateAutoLogin(loginType)
        end
    else
        self:autoLogin()
    end
end

function JPPreloadingScene:updateOAuthButtonState()
end

function JPPreloadingScene:onGuestButtonTouched()
    self:alertBeforeGuestLogin()
    self:hideButtons()
end

function JPPreloadingScene:onChangeAccountButtonTouched()
    self.isChangeAccount = true
    local logoutCallback = {
        onSuccess = function(result)
            self:logoutWithChangeAccount()
        end,
        onError = function(errCode, msg) 
        end,
        onCancel = function()
        end
    }
    SnsProxy:logout(logoutCallback) 
end

function JPPreloadingScene:alertBeforeGuestLogin()
    self:guestRegisterDetect()
end

function JPPreloadingScene:onOAuthButtonTouched(authorType, fromBtnClick)
    self:hideButtons()
    if fromBtnClick then 
        --如果是从按钮点过来的登录~为了防止sdk登录异常中断造成影响~强制清理下
        SnsProxy:logout()
        self:logout()
    end
    SnsProxy:setAuthorizeType(authorType)
    local isLogin = SnsProxy:isLogin()
    if _G.isLocalDevelopMode then printx(0, "onOAuthButtonTouched==authorType==" .. authorType .. "  isLogin==" .. tostring(isLogin).."  fromBtnClick==" ..tostring(fromBtnClick)) end
    if isLogin then
        self:oauthLoginWithCache()
    else
        local subCategory = "login_account_type"
        if self.isChangeAccount then 
            subCategory = "login_switch_account_type"
            self.isChangeAccount = false
        end
        DcUtil:UserTrack({ category='login', sub_category=subCategory, object=authorType })

        self:oauthLoginWithRequest()
    end
end

function JPPreloadingScene:oauthLoginWithCache()
    local function loginWithCache(evt)
        evt.target:rma()
        self:oauthRegisterDetect()
    end

    local function loginWithRequest(evt)
        evt.target:rma()
        self:oauthLoginWithRequest()
    end

    local oauthLoginWithTokenCacheProcessor = require("zoo.loader.OAuthLoginWithCacheProcessor").new()
    oauthLoginWithTokenCacheProcessor:addEventListener(Events.kComplete, loginWithCache)
    oauthLoginWithTokenCacheProcessor:addEventListener(Events.kError, loginWithRequest)
    oauthLoginWithTokenCacheProcessor:start()
end

function JPPreloadingScene:oauthLoginWithRequest()
    if _G.isLocalDevelopMode then printx(0, "oauthLoginWithRequest") end
    local isCancel = false
    self:hideButtons()

    local function onLoginSuccess(evt)
        if _G.isLocalDevelopMode then printx(0, "oauthLoginProcessor " .. "onLoginSuccess") end
        evt.target:rma()
        self:oauthRegisterDetect()
        -- self:clearStatus()
    end

    local function onLoginFail(evt)
        if _G.isLocalDevelopMode then printx(0, "oauthLoginProcessor " .. "onLoginFail") end
        --1001：qq登录取消      2002：微信登录取消
        if evt.data and evt.data.errorCode and (evt.data.errorCode == 1001 or evt.data.errorCode == 2002) then 
            CommonTip:showTip(localize("wxjp.loading.agreement.layer.text"), "negative")
        else
            CommonTip:showTip(localize("wxjp.loading.tips.fail"), "negative")
        end
        evt.target:rma()
        self:showButtons()
        self:clearStatus()
    end

    local function onLoginCancel(evt)
        if _G.isLocalDevelopMode then printx(0, "oauthLoginProcessor " .. "onLoginCancel") end
        evt.target:rma()
        isCancel = true
        self:showButtons()
        self:clearStatus()
    end

    local oauthLoginProcessor = require("zoo.loader.OAuthLoginWithRequestProcessor").new()
    oauthLoginProcessor:addEventListener(Events.kComplete, onLoginSuccess)
    oauthLoginProcessor:addEventListener(Events.kError, onLoginFail)
    oauthLoginProcessor:addEventListener(Events.kCancel, onLoginCancel)
    oauthLoginProcessor:start(self)

    local function cancelLoginCallback()
        oauthLoginProcessor:rma()
    end

    if not isCancel then
        self:changeUIOnSNSLogin(cancelLoginCallback)
    end
end

function JPPreloadingScene:oauthRegisterDetect()
    WXJPPackageUtil.getInstance():tryShowMarketAd()

    local function guestLoginOldUser(evt)
        evt.target:rma()
        local loginInfo = Localhost.getInstance():getLastLoginUserConfig()
        self:doLogin(loginInfo, true)
    end

    local function guestLoginNewUser(evt)
        evt.target:rma()
        self:registerOAuthUser()
    end

    local registerDetectProcessor = require("zoo.loader.NeedRegisterDetectProcessor").new()
    registerDetectProcessor:ad(registerDetectProcessor.events.kLocalOldUser, guestLoginOldUser)
    registerDetectProcessor:ad(registerDetectProcessor.events.kLocalNewUser, guestLoginNewUser)
    registerDetectProcessor:start()
    GameLauncherContext:getInstance():onStartLogin()
end


function JPPreloadingScene:guestRegisterDetect()
    local function guestLoginOldUser(evt)
        evt.target:rma()
        local loginInfo = Localhost.getInstance():getLastLoginUserConfig()
        self:doLogin(loginInfo, false)
    end

    local function guestLoginNewUser(evt)
        evt.target:rma()
        self:registerGuestUser()
    end

    local registerDetectProcessor = require("zoo.loader.NeedRegisterDetectProcessor").new()
    registerDetectProcessor:ad(registerDetectProcessor.events.kLocalOldUser, guestLoginOldUser)
    registerDetectProcessor:ad(registerDetectProcessor.events.kLocalNewUser, guestLoginNewUser)
    registerDetectProcessor:start()
    GameLauncherContext:getInstance():onStartLogin()
end

function JPPreloadingScene:doLogin(loginInfo, isOAuth)
    if isOAuth then 
        self.loginType = SnsProxy:getAuthorizeType()
    else 
        WXJPPackageUtil.getInstance():setGuestLogin()
        self.loginType = PlatformAuthEnum.kGuest 
    end
    _G.tryLoginType = self.loginType

    local function setGuestCreateTime()
        local createTime = Localhost.getInstance():getGuestCreateTime()
        if not createTime then
            Localhost.getInstance():saveGuestCreateTime(os.time())
        end
    end

    local function onLoginFinish(evt)
        evt.target:rma()
        self:clearStatus()
        _G.kLoginType = self.loginType
        self:onLoadLoginFinish()
        if not isOAuth then setGuestCreateTime() end
        MissionModel:getInstance():updateDataOnLogin(true , isOAuth , loginInfo)
    end

    local function onLoginFail(evt)
        evt.target:rma()
        self.loginType = nil
        _G.kLoginType = nil
        -- login请求失败:游客登录时直接进入游戏; OAuth登录时如果openId对应的用户有本地数据记录则直接进入游戏,否则需要刷新按钮
        if isOAuth then
            local localUserConfig = Localhost.getInstance():getLastLoginUserConfig()
            local userData = nil
            if localUserConfig then 
                userData = Localhost.getInstance():readUserDataByUserID(localUserConfig.uid)
            end

            if userData and _G.sns_token and userData.openId == _G.sns_token.openId then 
                self:clearStatus()
                self:onLoadLoginFinish()
                MissionModel:getInstance():updateDataOnLogin(false , isOAuth , loginInfo)
            else
                local msg = Localization:getInstance():getText("loading.tips.register.failure."..kLoginErrorType.register)
                --CommonTip:showTip(msg, "negative")

                self:clearStatus()
                self:logout()
                self:showButtons()
            end
        else
            self:clearStatus()
            self:onLoadLoginFinish()
            setGuestCreateTime() 
            MissionModel:getInstance():updateDataOnLogin(false , isOAuth , loginInfo)
        end
    end

    local loginProcessor = require("zoo.loader.LoginServerProcessor").new() 
    loginProcessor:ad(Events.kComplete, onLoginFinish)
    loginProcessor:ad(Events.kError, onLoginFail)
    loginProcessor:start(loginInfo)

    self:changeUIOnGuestLogin()

    -- MaintenanceManager.getInstance():initialize() -- require uid. initialize here
end

function JPPreloadingScene:registerOAuthUser()
    local function onRegisterSuccess(evt)
        evt.target:rma()
        local loginInfo = evt.data
        self:doLogin(loginInfo, true)
    end

    local function onRegisterError(evt)
        evt.target:rma()
        local msg = Localization:getInstance():getText("loading.tips.register.failure."..kLoginErrorType.register)
        CommonTip:showTip(msg, "negative")
        self:clearStatus()
        self:logout()
        self:showButtons()
    end

    local registerNewUserProcessor = require("zoo.loader.RegisterNewUserProcessor").new()
    registerNewUserProcessor:ad(Events.kComplete, onRegisterSuccess)
    registerNewUserProcessor:ad(Events.kError, onRegisterError)
    registerNewUserProcessor:start()

    self:changeUIOnRegister()
    GameLauncherContext:getInstance():onStartLogin()
end

function JPPreloadingScene:registerGuestUser()
    local function onRegisterSuccess(evt)
        evt.target:rma()
        local loginInfo = evt.data
        self:doLogin(loginInfo, false)
    end

    local function onRegisterError(evt)
        evt.target:rma()
        self:loginOffline()
        -- MaintenanceManager.getInstance():initialize() -- require uid. initialize here
    end

    local registerNewUserProcessor = require("zoo.loader.RegisterNewUserProcessor").new()
    registerNewUserProcessor:ad(Events.kComplete, onRegisterSuccess)
    registerNewUserProcessor:ad(Events.kError, onRegisterError)
    registerNewUserProcessor:start()

    self:changeUIOnRegister()
    GameLauncherContext:getInstance():onStartLogin()
end

function JPPreloadingScene:updateStatusLabel(text)
    if self.statusLabel and self.statusLabel.refCocosObj then
        self.statusLabel:stopAllActions()

        self.statusLabel:setVisible(true)
        self.statusLabel:setString(text)

        self.statusLabelShadow:setVisible(true)
        self.statusLabelShadow:setString(text)

        self.preventWallowLabel:setVisible(true)
    end
end

function JPPreloadingScene:changeUIOnGuestLogin()
    if self.statusLabel and self.statusLabel.refCocosObj then
        self.statusLabel:setVisible(true)
        self.statusLabel:setString("小浣熊努力登录中，请稍候~")
        self.statusLabelShadow:setVisible(true)
        self.statusLabelShadow:setString("小浣熊努力登录中，请稍候~")
        self.preventWallowLabel:setVisible(true)
    end
end

function JPPreloadingScene:changeUIOnRegister()
    if self.statusLabel and self.statusLabel.refCocosObj then
        self.statusLabel:setVisible(true)
        self.statusLabel:setString("小浣熊正在为您创建账号...")
        self.statusLabelShadow:setVisible(true)
        self.statusLabelShadow:setString("小浣熊正在为您创建账号...")
        self.preventWallowLabel:setVisible(true)
    end
end

function JPPreloadingScene:changeUIOnSNSLogin(cancelLoginCallback)
    if self.loginTipsLabel then self.loginTipsLabel:setVisible(false) end

    if self.statusLabel and self.statusLabel.refCocosObj then
        self.statusLabel:setVisible(true)
        self.statusLabel:setString("小浣熊努力登录中，请稍候~")
        self.statusLabelShadow:setVisible(true)
        self.statusLabelShadow:setString("小浣熊努力登录中，请稍候~")
        self.preventWallowLabel:setVisible(true)
    end
end

function JPPreloadingScene:changeUIOnConnect()
    if self.statusLabel and self.statusLabel.refCocosObj then
        self.statusLabel:setVisible(true)
        self.statusLabel:setString("数据合并中，请稍候~")
        self.statusLabelShadow:setVisible(true)
        self.statusLabelShadow:setString("数据合并中，请稍候~")
        self.preventWallowLabel:setVisible(true)
    end
end

function JPPreloadingScene:hideButtons()
    if self.authButton1 then self.authButton1:setVisible(false) end
    if self.authButton2 then self.authButton2:setVisible(false) end
    -- if self.guestButton then self.guestButton:setVisible(false) end
    if self.loginTipsLabel then self.loginTipsLabel:setVisible(false) end
end

function JPPreloadingScene:showButtons()
    if self.authButton1 then self.authButton1:setVisible(true) end
    if self.authButton2 then self.authButton2:setVisible(true) end
    -- if self.guestButton then self.guestButton:setVisible(true) end
    if self.loginTipsLabel then self.loginTipsLabel:setVisible(true) end
end

function JPPreloadingScene:clearStatus()
    if self.statusLabel and self.statusLabel.refCocosObj then
        self.statusLabel:setString("")
        self.statusLabel:setVisible(false)
        self.statusLabel:stopAllActions()
        self.statusLabelShadow:setString("")
        self.statusLabelShadow:setVisible(false)
        self.statusLabelShadow:stopAllActions()
    end
end

local function gotoHome()
    Localhost:saveCgPlayed(1)
    UserEnergyRecoverManager:sharedInstance():startCheckEnergy()
    ExitAlertPanel:removeExitAlert(true)

    LevelDifficultyAdjustManager:loadAndInitConfig()

    Director:sharedDirector():replaceScene(HomeScene:create())

    setTimeOut(function() 
        -- local resName1 = "materials/logo.plist"
        local resName2 = "flash/loading.plist"
        if __use_small_res then  
            -- resName1 = "materials/logo@2x.plist"
            resName2 = "flash/loading@2x.plist"
        end
        -- CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile(resName1)
        CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile(resName2)
        CCTextureCache:sharedTextureCache():removeUnusedTextures()
    end, 0.1)
end

function JPPreloadingScene:startGame()
    --这里刷新下默认支付方式 服务端和本地的记录可能已经无效
    PaymentManager.getInstance():refreshDefaultThirdPartyPayment()
    if __ANDROID and AndroidPayment.getInstance():isCMThirdPartOptimal() 
            and not PaymentManager.getInstance():checkDefaultPaymentValid() then
        PaymentManager.getInstance():setThirdPartPaymentAsDefault()
    end
    PaymentManager.getInstance():refreshDefaultPayment()

    local config = Localhost:getDefaultConfig()
    if config.pl == 0 then
        local function onStartupAnimationFinish()
            self:updateUserNickname()
            gotoHome()
        end
        local StartupAnimation = require("zoo.animation.StartupAnimation")
        StartupAnimation:play(onStartupAnimationFinish)
    else 
        self:updateUserNickname()
        gotoHome() 
    end

    if not _G.sns_token then -- Guest
        local profile = UserManager.getInstance().profile
        if profile and not table.isEmpty(profile.snsMap) then
            pcall(function() 
                DcUtil:UserTrack({category="sns_error", sub_category="sns_error", sns_map=table.serialize(profile.snsMap)})
            end)
        end
    end

    -- 只有sns账号登录时才会去同步sns好友。
    if _G.kUserSNSLogin then
        SnsProxy:syncSnsFriend()
    end
end


function JPPreloadingScene:updateUserNickname()
    local updateUserNicknameProcessor = require("zoo.loader.UpdateUserNicknameProcessor")
    updateUserNicknameProcessor:start()
end

function JPPreloadingScene:loginOffline()
    if _G.isLocalDevelopMode then printx(0, "login offline") end
    local function onLoginFinish( evt )
        evt.target:removeAllEventListeners()

        if not self.refCocosObj then return end

        self.statusLabel:setString("")
        self.statusLabel:setVisible(false)
        self.statusLabel:stopAllActions()
        self.statusLabelShadow:setString("")
        self.statusLabelShadow:setVisible(false)
        self.statusLabelShadow:stopAllActions()

        self.preventWallowLabel:setString("");
        self.preventWallowLabel:setVisible(false);
        
        self:onLoadLoginFinish()
    end 

    local logic = LoginLogic.new()
    logic:addEventListener(Events.kComplete, onLoginFinish)
    logic:addEventListener(Events.kError, onLoginFinish)
    logic:execute()
end

function JPPreloadingScene:onLoadLoginFinish()
    self:loadLevelConfigDynamicUpdate()
    local openId, accessToken, authorType
    if kUserLogin and sns_token then 
        openId = sns_token.openId
        accessToken = sns_token.accessToken
        authorType = sns_token.authorType
    end

    if openId and accessToken then 
        self:syncOAuthData(openId, accessToken, authorType) 
    else
        self:detectXiBaoAlert()
    end
end

function JPPreloadingScene:detectXiBaoAlert()
    local function continue(evt)
        evt.target:rma()
        self:startGame()
        LoginAlertModel:getInstance():writeLoginInfo()
    end

    local function backToLogin(evt)
        evt.target:rma()
        self:logout()
        SnsProxy:logout()
        self:showButtons()
        self:updateOAuthButtonState()
    end

    local function toAccountBindLogin(evt)
        evt.target:rma()
        self:logout()
        SnsProxy:logout()
        self:showButtons()
        self:updateOAuthButtonState()
        if self.redButton ~= nil then
            setTimeOut(function( ... )
                self.redButton:dispatchEvent(Event.new(DisplayEvents.kTouchTap, nil, self))
            end, 0.05)
        end
    end

    local loginAlertModel = LoginAlertModel:getInstance()
    loginAlertModel:addEventListener(LoginAlertModel.EVENT_TYPE.kContinue, continue)
    loginAlertModel:addEventListener(LoginAlertModel.EVENT_TYPE.kBackToLogin, backToLogin)
    loginAlertModel:addEventListener(LoginAlertModel.EVENT_TYPE.kToAccountBindLogin, toAccountBindLogin)
    loginAlertModel:checkAlert(self.loginType)
end

function JPPreloadingScene:loadLevelConfigDynamicUpdate()
    -- local levelConfigUpdateProcessor = require("zoo.loader.LevelConfigUpdateProcessor").new()
    -- levelConfigUpdateProcessor:start()
    local levelDifficultyUpdateProcessor = require("zoo.loader.LevelDifficultyUpdateProcessor").new()
    levelDifficultyUpdateProcessor:start() 
end

function JPPreloadingScene:syncOAuthData(openId, accessToken, authorType)
    local function onSyncSuccess(evt)
        evt.target:rma()
        self:detectXiBaoAlert()
        self:clearStatus()
    end

    local function onSyncCancel(evt)
        evt.target:rma()
        self:showButtons()
        self:clearStatus()
    end

    local function onSyncCancelLogout(evt)
        evt.target:rma()
        self:logout()
        self:showButtons()
        self:clearStatus()
    end

    local hasReward = Localhost.getInstance():canShowLoginRewardTip()

    local syncProcessor = require("zoo.loader.SyncOAuthDataProcessor").new()
    syncProcessor:addEventListener(syncProcessor.events.kSyncSuccess, onSyncSuccess)
    syncProcessor:addEventListener(syncProcessor.events.kSyncCancel, onSyncCancel)
    syncProcessor:addEventListener(syncProcessor.events.kSyncCancelLogout, onSyncCancelLogout)
    syncProcessor:start(openId, accessToken, authorType, hasReward)

    self:changeUIOnConnect()
end

function JPPreloadingScene:logout()
    return self:_logout(true)
end

function JPPreloadingScene:logoutWithChangeAccount()
    return self:_logout(false)
end

function JPPreloadingScene:_logout(deleteUserData)
    local result = {}
    local uid = UserManager.getInstance().uid
    if deleteUserData then
        if uid then 
            if _G.isLocalDevelopMode then printx(0, "delete user data in JPPreloadingScene:logout() uid " .. uid) end
            Localhost.getInstance():deleteUserDataByUserID(uid) 
        end
    end
    result.uid = uid
    result.udid = _G.kDeviceID
    local savedConfig = Localhost.getInstance():getLastLoginUserConfig()
    if savedConfig then
        local savedUid = tostring(savedConfig.uid)
        if savedUid then 
            if deleteUserData then
                Localhost.getInstance():deleteUserDataByUserID(savedUid) 
            end
            result.uid = savedUid
            result.udid = savedConfig.sk
        end
    end
    Localhost.getInstance():deleteLastLoginUserConfig()
    --Localhost.getInstance():deleteGuideRecord()
    Localhost.getInstance():deleteMarkPriseRecord()
    Localhost.getInstance():deletePushRecord()
    Localhost.getInstance():deleteWeeklyMatchData()
    Localhost.getInstance():deleteRankRaceData()
    
    Localhost.getInstance():deleteUserMissionData()
    Localhost.getInstance():deleteLocalExtraData()
    LocalNotificationManager.getInstance():cancelAllAndroidNotification()

    he_log_info('wenkan JPPreloadingScene:_logout')
    CCUserDefault:sharedUserDefault():setStringForKey(getDeviceNameUserInput(), "")
    -- CCUserDefault:sharedUserDefault():setIntegerForKey("thisWeekNoSelectAccount",0)
    CCUserDefault:sharedUserDefault():flush()

    UserManager.getInstance():reset()
    UserService.getInstance():reset()

    _G.kDeviceID = UdidUtil:revertUdid()
    _G.sns_token = nil
    _G.kUserSNSLogin = false
    _G.kLoginType = nil

    if SnsProxy then SnsProxy.profile = {} end

    return result 
end

function JPPreloadingScene:onKeyBackClicked()
    if _G.isLocalDevelopMode then printx(0, "JPPreloadingScene:onKeyBackClicked Called !") end
    if self.exitDialog then return end

    local function onExit()
        if _G.isLocalDevelopMode then printx(0, "Info - Keypad Callback: sns onSuccess") end
        DcUtil:UserTrack({category="UI", sub_category="exit_game",t1 = 4, t2=1}, true)
        DcUtil:saveLogToLocal()
        Director.sharedDirector():exitGame()
    end
        
    local function onCancelExit() 
        if _G.isLocalDevelopMode then printx(0, "Info - Keypad Callback: sns onCancel") end
        self.exitDialog = false
        DcUtil:UserTrack({category="UI", sub_category="exit_game",t1=4, t2=2},true)
    end

    if self.isLoadResourceComplete then
        self.exitDialog = true
        ExitAlertPanel:create(onExit, onCancelExit):popout()
    end
end

function JPPreloadingScene:onEnterBackground()
    ExitAlertPanel:removeExitAlert()
end

function JPPreloadingScene:onEnterForeGround()
    ExitAlertPanel:removeExitAlertOnEnterForeground()
end

return JPPreloadingScene