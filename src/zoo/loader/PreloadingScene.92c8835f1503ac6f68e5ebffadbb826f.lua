-- require "hecore.debug.remote"
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
require "zoo.gamePlay.userTags.UserTagAutomationManager"
require "zoo.net.LoginLogic"
require "zoo.net.SyncManager"

require "hecore.sns.SnsProxy"
require "zoo.util.SnsUtil"
require "zoo.util.OOMManager"

require "zoo.model.AnnoucementMgr"
require "zoo.panel.AnnouncementPanel"

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

require "zoo.PersonalCenter.achi.Achievement"

require "zoo.gamePlay.config.GamePlayGlobalConfigs"
require "zoo.util.MemClass"
require "zoo.util.LocalBox"
require "zoo.gamePlay.GameBoardLogic"
require "zoo.panel.qatools.DiffAdjustQAToolManager"
require "zoo.scenes.component.HomeScene.popoutQueue.new.AutoPopout"

require "zoo.heai.HEAICore"

require "zoo.debug.GameConsole"

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

GamePlayClientVersion = 1

local PreloadingScene = class(Scene)
function PreloadingScene:onInit()
    self.name = "PreloadingScene"
    PreloadingSceneUI:initUI(self)

    self:handleInitPermissions()
end

function PreloadingScene:handleInitPermissions()
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

function PreloadingScene:initialize()
    Notify:dispatch("AutoPopoutInitEvent")

    HEAICore:init()
    LevelMapManager.getInstance():initialize()
    MetaManager.getInstance():initialize()
    
    GameCenterSDK:getInstance():authenticateLocalUser()
    PlatformConfig:loadPayementConfig()
    self:handleCMPaymentDecision()

    --bugfix: 账号登录的人可能以游客登录的方式进入游戏, 清一下lastLoginInfo以避免此问题 
    self:checkNeedClearLoginInfo()

    self:checkNeedRegister()

    RealNameManager:getLocationInfoAsync()

    self:preloadResource() 

    PhoneLoginManager.getInstance():checkPhoneLogin()

    if not PlatformConfig:isPlatform(PlatformNameEnum.kQQ) then--应用宝版本公告先不弹，检测省流量更新后再弹
        BroadcastManager:getInstance():initFromConfig()
    end
    self:loadAnnouncement()

    if __ANDROID then 
        SnsProxy:initDuokuAds() 
    end

    -- PlatformConfig.authConfig = {PlatformAuthEnum.kWDJ, PlatformAuthEnum.kPhone} --test
    -- PlatformConfig.authConfig = {PlatformAuthEnum.kPhone, PlatformAuthEnum.k360} --test   k360 
    require "zoo.ads.SplashAds"
    if SplashAds and SplashAds.showOppoVivo then
        SplashAds:showOppoVivo()
    end
end

function PreloadingScene:updateConfig()
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

function PreloadingScene:create()
    local s = PreloadingScene.new()
    GameLauncherContext:getInstance():onPreloadingScene()
    s:initScene()
    return s
end

function PreloadingScene:getPlatformNameLocalization()
    return PlatformConfig:getPlatformNameLocalization()
end

function PreloadingScene:handleCMPaymentDecision()
    local function onComplete(evt)
        if __ANDROID then SnsProxy:initPlatformConfig() end
    end

    local decisionProcessor = require("zoo.loader.CMPaymentDecisionProcessor").new()
    decisionProcessor:addEventListener(Events.kComplete, onComplete)
    decisionProcessor:addEventListener(Events.kError, onComplete)
    decisionProcessor:start()
end

function PreloadingScene:toggleLoginUIElements(enable)
    if self.antiAddictionText then
        self.antiAddictionText:setVisible(enable)
    end
    if self.startButton then
        self.startButton:setVisible(enable)
    end
    if self.blueButton then
        self.blueButton:setVisible(enable)
    end
end

function PreloadingScene:loadAnnouncement()
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

function PreloadingScene:checkNeedRegister()
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

function PreloadingScene:preloadResource()
    if PlatformConfig:isQQPlatform() then
        --应用宝省流量更新逻辑
        require "zoo.platform.YYBYsdkPlatform"
        YYBYsdkPlatform:checkUpdate()
    end
    self:doLoadResource()
end
--prePropFlag  【0】不启用前置道具 【1】选中所有的前置道具【2】随机选择前置道具（数量种类均随机）【3】加三步，刷新，爆炸直线特效【4】魔力鸟。Buff炸弹
function startMctsLevel()
    local prePropFlag = 0
    local dropStrategy = 0

    local simplejson = require("cjson")
    local resp = '{"method":"start","level":' .. (_G.launchCmds.level or 200) .. ',"seed":' .. (_G.launchCmds.seed or 1) .. '}' 
    if _G.launchCmds.domain then
        local redisClient = _G.redisClient
        if not redisClient then
            local redis = require 'zoo.util.redis'
            redisClient = redis.connect("animalmobiledev.happyelements.cn", 6379)
            redisClient:auth("animal_2017")
            _G.redisClient = redisClient
        end
        local msg = nil
        while not msg do
            msg = redisClient:brpop("cnn_tasks", 120)
        end

        local task = simplejson.decode(msg[2])
        local levelId = task.l
        local batchId = (task.b or 0)
        local levelSeed = task.s
        _G.cnnTask = task
        resp = '{"method":"start","level":' .. (levelId or 50) .. ',"seed":' .. (levelSeed or 0) .. '}' 
        local testConfStr = redisClient:get("cnn_conf_" .. batchId)
        if testConfStr then
            local testData = table.deserialize(testConfStr)
            local testConf = testData.levelCfg
            testConf.totalLevel = levelId
            prePropFlag = testData.preProp
            dropStrategy = testData.dropStrategy
            LevelMapManager:getInstance():addDevMeta(testConf)
            local levelMeta = LevelMapManager.getInstance():getMeta(levelId)
            local levelConfig = LevelConfig:create(levelId, levelMeta)
            LevelDataManager.sharedLevelData().levelDatas[levelId] = levelConfig
        end
    elseif not _G.launchCmds.mock then
        resp = StartupConfig:getInstance():receiveMsg()
    end
    --he_log_error(resp)
    local cmd = simplejson.decode(resp)
    if cmd.method == "start" then
        if cmd.snap then
            _G.__startCmd = cmd
        end
        local step = {randomSeed = cmd.seed, replaySteps = {}, level = cmd.level, selectedItemsData = {}}

        local preProp = {}
        if prePropFlag == 1 then
            table.insert( preProp , { id = 10087} )
            table.insert( preProp , { id = 10089} ) -- replace later
            table.insert( preProp , { id = 10018} )
            table.insert( preProp , { id = 10015} )
            table.insert( preProp , { id = 10007} )
            -- table.insert( preProp , { id = 10099} )
        elseif prePropFlag == 2 then
            if math.random() < 0.4 then
                if math.random() < 0.8 then table.insert(preProp , { id = 10087} ) end
                if math.random() < 0.8 then table.insert(preProp , { id = 10089} ) end -- replace later
                if math.random() < 0.8 then table.insert(preProp , { id = 10018} ) end
                if math.random() < 0.8 then table.insert(preProp , { id = 10015} ) end
                if math.random() < 0.8 then table.insert(preProp , { id = 10007} ) end
                -- if math.random() < 0.8 then table.insert(preProp , { id = 10099} ) end
            end
        elseif prePropFlag == 3 then
            table.insert( preProp , { id = 10018} )
            table.insert( preProp , { id = 10015} )
            table.insert( preProp , { id = 10007} )
        elseif prePropFlag == 4 then
            table.insert( preProp , { id = 10087} )
            table.insert( preProp , { id = 10089} ) -- replace later
            -- table.insert( preProp , { id = 10099} )
        end


        if #preProp > 0 then
            for k,v in ipairs(preProp) do
                table.insert(step.selectedItemsData , { id = v.id } )
            end
        end

        local newStartLevelLogic = NewStartLevelLogic:create( nil , step.level , step.selectedItemsData , false , {} )
        newStartLevelLogic:startWithReplay( ReplayMode.kMcts , step )
    else
        he_log_error("you must start level now!")
    end
end

function PreloadingScene:doLoadResource()
    local function onLoadResourceComplete(evt)
        evt.target:rma()

        if not _G.isLocalDevelopMode then
            --
--

        end
        -- self:buildAuthUI()
        GameLauncherContext:getInstance():onPreloadingSceneResLoadFinish()
        _G._UploadDebugLog = MaintenanceManager:getInstance():isEnabled("UploadDebugLog")

        -- DiffAdjustQAToolManager:addLogs( 1 , "_G.bundleVersion = " .. tostring(_G.bundleVersion) .. "  type = " .. type(_G.bundleVersion) )
        local ver = tonumber(string.split( tostring(_G.bundleVersion) , ".")[2])
        if ver and ver <= 36 then
            --禁用低版本
            local text = "由于您的游戏版本过低不能进入游戏，请更新版本后继续游戏吧！"

            local textObj = {
                             tip = text,
                             yes = "更新",
                             no = "关闭",
                            }
            local function yesCallback()
                require 'zoo.util.OpenUrlUtil'
                if OpenUrlUtil --[[and OpenUrlUtil:canOpenUrl("http://xxl.happyelements.com/")]] then
                    local platform = PlatformConfig.name
                    local url = "http://animalmobile.happyelements.cn/download.jsp?platform=" .. platform
                    RemoteDebug:uploadLogWithTag( "URL" , url )
                    OpenUrlUtil:openUrl( url )
                end
            end

            local function noCallback()
                Director.sharedDirector():exitGame()
            end

            CommonTipWithBtn:showTip( textObj , "negative" , yesCallback , noCallback , nil , false )

            return
        end

        if __WIN32 and _G.launchCmds and _G.launchCmds.qacheck then 
            QACheckPlayManager.getInstance():check()
        elseif (_G.isCheckPlayModeActive) then
             self:startReplay()
        elseif __WIN32 and _G.launchCmds and _G.launchCmds.ingame then
            if _G.launchCmds.levelshare and _G.launchCmds.levels then
                require('zoo.gameTools.GameMapSnapshot')
                local function onFinish()
                    CCDirector:sharedDirector():endToLua()
                end
                GameMapSnapshotTool:genByCmd(_G.launchCmds.path, _G.launchCmds.levels, onFinish)
            end
            if _G.launchCmds.mcts then
                StartupConfig:getInstance():initZmq("tcp://" .. (_G.launchCmds.ip or "127.0.0.1") .. ":" .. _G.launchCmds.port)
                if not _G.launchCmds.mock then
                    if not _G.launchCmds.domain then StartupConfig:getInstance():sendMsg('{"method":"ready"}') end
                else
                    _G.__root={
                        parent = nil,
                        child = nil,
                        signal = 0,
                        success = 0,
                        sum = 0
                    }
                    _G.__scores = {}
                end
                GameSpeedManager:changeSpeedForCrashResumePlay()
                print = function() end 
                printx = function() end 
                if not _G.launchCmds.visible then
                    HeGameDefault:setFpsValue(-1)
                end
                startMctsLevel()
                _G.__startTime = os.time()
            end
        else
            local function doBuildAuthUI()
                PreloadingSceneUI:hideAntiAddiction(self)
                self:buildAuthUI()
            end

            local function handleAnnouncements()
                if self.announcements then
                    AnnouncementPanel:create(AnnouncementPosType.kLoading, self.announcements):popout(doBuildAuthUI) 
                else
                    doBuildAuthUI()
                end
            end

            local function afterAcceptAgreement()
                local platformsNeedCheckUnbindAlert = {
                    PlatformNameEnum.kWDJ,
                    PlatformNameEnum.kMiTalk,
                }

                if table.exist(platformsNeedCheckUnbindAlert, PlatformConfig.name) then
                    --豌豆荚 账户自动解绑 提醒
                    local function checkWDJUnbindAlert( onFinish )
                        local function onCallback(response)
                            if response.httpCode ~= 200 then 
                                onFinish(false)
                            else
                                if 'true' == tostring(response.body):lower() then
                                    onFinish(true)
                                else
                                    onFinish(false)
                                end
                                
                            end
                        end

                        local deviceId = tostring(MetaInfo:getInstance():getUdid())
                        local version = tostring(_G.bundleVersion)

                        local url = NetworkConfig.dynamicHost .. 'action/wdj.do?method=check&deviceId=' .. deviceId .. '&_v=' .. version

                        local request = HttpRequest:createGet(url)
                        local timeout = 3
                        local connection_timeout = 2
                        request:setConnectionTimeoutMs(connection_timeout * 1000)
                        request:setTimeoutMs(timeout * 1000)
                        HttpClient:getInstance():sendRequest(onCallback, request)

                    end

                    checkWDJUnbindAlert(function ( shouldAlert )
                        if shouldAlert then

                            Localhost:getInstance():clearLastLoginUserData()
                            self:checkNeedRegister()

                            require('zoo.panel.WDJAlertPanel'):create():popout(handleAnnouncements)
                        else
                            handleAnnouncements()
                        end
                    end)

                else
                    handleAnnouncements()
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
        end
        self.isLoadResourceComplete = true

        if not __WP8 then AsyncLoader:getInstance():load() end

        _G.kResourceLoadComplete = true
    end

    if (_G.isCheckPlayModeActive) or (__WIN32 and _G.launchCmds and _G.launchCmds.qacheck) then
        
        for k , v in pairs( ResourceConfig.asyncPlist ) do
            table.insert( ResourceConfig.plist , v )
        end

        ResourceConfig.asyncPlist = {}
    end

    local loadResourceProcess = require("zoo.loader.LoadResourceProcessor").new() 
    loadResourceProcess:addEventListener(Events.kComplete, onLoadResourceComplete)
    loadResourceProcess:start(self.statusLabel, self.statusLabelShadow, self.progressBar)
end

function PreloadingScene:startReplay()
    -- Fang Zuo Bi Mode
    if (_G.isCheckPlayModeActive) then

        -- tell agent to give me some oper

        -- CheckPlay:check( checkId , diffData , playData )
        if _G.isLocalDevelopMode then printx(0, ">>>>>>>>>>>>> FANG ZUO BI START >>>>>>>>>>>>>") end
        
        StartupConfig:getInstance():init(StartupConfig:getInstance():getCheckClientReceiveAddress(),StartupConfig:getInstance():getCheckClientSendAddress())
        StartupConfig:getInstance():receive()
        CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function() 
            CheckPlay:heardBeat()
        end,10,false)

        -- local checkId = "999"
        -- local diff = "[{\"totalLevel\":9,\"gameData\":{\"addMoveBase\":0,\"balloonFrom\":0,\"confidence\":99,\"dropRules\":[],\"gameModeName\":\"Order\",\"hasDropDownUFO\":false,\"moveLimit\":17,\"numberOfColours\":5,\"orderList\":[{\"k\":\"1_2\",\"v\":10}],\"pm25\":0,\"portals\":[],\"randomSeed\":838669,\"replaceColorMaxNum\":0,\"scoreTargets\":[200,350,480],\"specialAnimalMap\":[[0,0,0,0,0,0,0,0,0],[0,0,4,2,0,64,2,0,0],[0,32,64,16,4,32,4,4,0],[0,64,4,16,16,2,16,4,0],[0,64,4,2,4,32,4,16,0],[0,0,32,2,4,16,16,0,0],[0,0,0,4,2,16,0,0,0],[0,0,0,0,32,0,0,0,0],[0,0,0,0,0,0,0,0,0]],\"tileMap\":[[\"0\",\"0\",\"0\",\"0\",\"0\",\"0\",\"0\",\"0\",\"0\"],[\"0\",\"0\",\"18\",\"18\",\"0\",\"18\",\"18\",\"0\",\"0\"],[\"0\",\"18\",\"2\",\"2\",\"18\",\"2\",\"2\",\"18\",\"0\"],[\"0\",\"2\",\"2\",\"2\",\"2\",\"2\",\"2\",\"2\",\"0\"],[\"0\",\"2\",\"2\",\"2\",\"2\",\"2\",\"2\",\"2\",\"0\"],[\"0\",\"0\",\"2\",\"2\",\"2\",\"2\",\"2\",\"0\",\"0\"],[\"0\",\"0\",\"0\",\"2\",\"2\",\"2\",\"0\",\"0\",\"0\"],[\"0\",\"0\",\"0\",\"0\",\"2\",\"0\",\"0\",\"0\",\"0\"],[\"0\",\"0\",\"0\",\"0\",\"0\",\"0\",\"0\",\"0\",\"0\"]],\"tips\":\"1\"}}]"
        -- local data = "{\"level\":9,\"replaySteps\":[{\"x2\":4,\"x1\":3,\"y2\":5,\"y1\":5},{\"x2\":4,\"x1\":4,\"y2\":6,\"y1\":5},{\"x2\":5,\"x1\":5,\"y2\":7,\"y1\":6},{\"x2\":3,\"x1\":2,\"y2\":3,\"y1\":3}],\"hasDropBuff\":false,\"randomSeed\":1461830956,\"selectedItemsData\":{}}"
        -- -- score 36085
        -- local simplejson = require("cjson")
        -- tDiff = simplejson.decode(diff)
        -- tData = simplejson.decode(data)
        -- if _G.isLocalDevelopMode then printx(0, tData.level) end
        -- if _G.isLocalDevelopMode then printx(0, tData.replaySteps) end
        -- if _G.isLocalDevelopMode then printx(0, tData.replaySteps[1]) end
        -- if _G.isLocalDevelopMode then printx(0, tData.randomSeed) end
        -- if _G.isLocalDevelopMode then printx(0, tData.hasDropBuff) end
        -- if _G.isLocalDevelopMode then printx(0, tDiff[1].totalLevel) end
        -- if _G.isLocalDevelopMode then printx(0, tDiff[1].gameData.confidence) end

        -- --setTimeOut( function () CheckPlay:check(checkId,tDiff,tData) end , 10 )
        -- CheckPlay:check(checkId,tDiff,tData)

        if _G.isLocalDevelopMode then printx(0, ">>>>>>>>>>>>> FANG ZUO BI END >>>>>>>>>>>>>") end
    end
end

function PreloadingScene:buildAuthUI()
    local function onGuestLogin()
        GameLauncherContext:getInstance():onTouchLogin()
        self:hideButtons()
        self:guestRegisterDetect()
    end

    local function callback()
        -- PreloadingSceneUI:buildDebugButton(self, onGuestLogin)
        -- do return end
        local isGuestLogin = PlatformConfig:isAuthConfig(PlatformAuthEnum.kGuest)
        if isGuestLogin then
            if NetworkConfig.showDebugButtonInPreloading then 
                PreloadingSceneUI:buildDebugButton(self, onGuestLogin)
            else
                PreloadingSceneUI:buildGuestLoginButton(self, onGuestLogin)
            end
        else
            local authButton, guestButton = PreloadingSceneUI:buildOAuthLoginButtons(self)
            self:redefineButtonForPlatform(authButton, guestButton)
            -- BindPhoneGuideLogic:get():onShowLoginBtn(self.oauthButton)
        end

        he_log_info("auto_test_apk_start_success")
        self.requireButtons = true
    end

    PhoneLoginManager.getInstance():waitForCheckResult(callback)
end

function PreloadingScene:redefineButtonForPlatform(redButton, blueButton)
    local function onTouchGuestLogin(evt)
        GameLauncherContext:getInstance():onTouchLogin()
        self:onGuestButtonTouched()
    end

    local function onTouchOAuthLogin(evt)
        GameLauncherContext:getInstance():onTouchLogin()
        self:onOAuthButtonTouched()
    end

    if RealNameManager:isGuestLoginAlertEnable() then
        onTouchGuestLogin = RealNameManager:decorateAlertGuest(onTouchOAuthLogin, onTouchGuestLogin)
    end    

    self.redButton = redButton
    self.blueButton = blueButton
    self.blueButton:removeEventListenerByName(DisplayEvents.kTouchTap)
    self.blueButton:addEventListener(DisplayEvents.kTouchTap, onTouchGuestLogin)
    self.redButton:removeEventListenerByName(DisplayEvents.kTouchTap)
    self.redButton:addEventListener(DisplayEvents.kTouchTap, onTouchOAuthLogin)

    self:updateOAuthButtonState()
end


function PreloadingScene:updateOAuthButtonState()
    self.oauthButton = self.redButton -- 默认情况下，红按钮
    if self.redButton.agreement then
        if self.redButton.agreement.touchLayer and not self.redButton.agreement.touchLayer.isDisposed then
            self.redButton.agreement.touchLayer:setTouchEnabled(true)
        end
        CCUserDefault:sharedUserDefault():setBoolForKey("game.user.agreement.checked", false)
    end

    local function checkAgreement( cb )
        if self.antiAddictionText and self.antiAddictionText:isVisible() then
            self.antiAddictionText:setVisible(false)
        end

        if self.redButton.agreement then
            if not self.redButton.agreement.isDisposed and
                self.redButton.agreement.checked then
                if self.redButton.agreement.touchLayer and not self.redButton.agreement.touchLayer.isDisposed then
                    self.redButton.agreement.touchLayer:setTouchEnabled(false)
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

    local function isCheckAgreement( ... )
        if self.redButton.agreement then
            return not self.redButton.agreement.isDisposed and self.redButton.agreement.checked
        else
            return true
        end
    end

    -- 游客登录
    local function onTouchGuestLogin(evt)
        if self.stopAutoLogin then
            self:stopAutoLogin()
        end
        checkAgreement(function( ... )
            GameLauncherContext:getInstance():onTouchLogin()
            self:onGuestButtonTouched()

            DcUtil:UserTrack({ category='login', sub_category='login_click_custom' })
        end)

    end

    -- 开始游戏
    local function onTouchOAuthLogin(evt)
        if self.stopAutoLogin then
            self:stopAutoLogin()
        end
        checkAgreement(function( ... )
            GameLauncherContext:getInstance():onTouchLogin()
            self:onOAuthButtonTouched()
        end)

    end

    if RealNameManager:isGuestLoginAlertEnable() then
        onTouchGuestLogin = RealNameManager:decorateAlertGuest(onTouchOAuthLogin, onTouchGuestLogin)
    end  

    -- 切换账号
    local function onTouchChangeAccount(evt)
        self.isChangingAccount = true
        if self.stopAutoLogin then
            self:stopAutoLogin()
        end
        checkAgreement(function( ... )
            self:onChangeAccountButtonTouched()
        end)

    end

    local lastAuthorType = PlatformConfig:getLastPlatformAuthType()
    if lastAuthorType and not PlatformConfig:hasLoginAuthConfig(lastAuthorType) then
        self:logoutWithChangeAccount()
    end

    local isLogin = false
    if SnsProxy then
        isLogin = SnsProxy:isLogin() or (SnsProxy:isPhoneLogin() and not SnsProxy:isPhoneLoginExpire())

        if SnsProxy:isPhoneLogin() and SnsProxy:isPhoneLoginExpire() then
            self:logoutWithChangeAccount()
            self.lastPhoneLoginExpire = true
        elseif not isLogin then
            -- 解决msdk覆盖安装问题，先这么解决
            -- 线上更新ios出现没有snsid 但是数据是sns的，改为只处理应用宝平台
            if PlatformConfig:isQQPlatform() then 
                local savedConfig = Localhost.getInstance():getLastLoginUserConfig()
                if savedConfig then
                    local userData = Localhost:getInstance():readUserDataByUserID(savedConfig.uid)
                    if userData and userData.openId then
                        self:logoutWithChangeAccount()
                    end
                end
            end
        end
    end

    if PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk) then
        if not isLogin or lastAuthorType == PlatformAuthEnum.kMI then
            if self.blueButton then self.blueButton:setVisible(false) end

            local platform = Localization:getInstance():getText("platform.platform")
            local platformLoginTip = Localization:getInstance():getText("loading.tips.start.btn.qq", { platform = platform })
            
            self.redButton:setString(platformLoginTip)
            self.redButton:removeEventListenerByName(DisplayEvents.kTouchTap)
            if lastAuthorType == PlatformAuthEnum.kMI then
                self.redButton:addEventListener(DisplayEvents.kTouchTap, onTouchChangeAccount)
            else
                self.redButton:addEventListener(DisplayEvents.kTouchTap, onTouchOAuthLogin)
            end
            self.redButton:setEnabled(true)
            self.redButton:setVisible(true)
            return
        end
    end

    local function displayLoginTipLabel()
        local posY = self.blueButton:getPositionY()
        local btnSize = self.blueButton:getGroupBounds().size
        if self.loginTipsLabel then
            self.loginTipsLabel:setPositionY(posY - btnSize.height / 2 - 15)
            self.loginTipsLabel:setVisible(CCUserDefault:sharedUserDefault():getBoolForKey("game.user.agreement.checked"))
        end
    end

    self.redButton:setEnabled(true)
    self.blueButton:setEnabled(true)

    self.startAutoLogin = nil
    self.stopAutoLogin = nil
    if isLogin then
        self.redButton:setString(Localization:getInstance():getText("button.start.game.loading"))
        self.blueButton:setString(Localization:getInstance():getText("loading.tips.start.btn.change.qq"))

        self.redButton:removeEventListenerByName(DisplayEvents.kTouchTap)
        self.redButton:addEventListener(DisplayEvents.kTouchTap, onTouchOAuthLogin)
        self.blueButton:removeEventListenerByName(DisplayEvents.kTouchTap)
        self.blueButton:addEventListener(DisplayEvents.kTouchTap, onTouchChangeAccount)

        self.oauthButton = self.blueButton

        local hwndTicker = nil
        local forceLoginTimer = nil
        local function freeLoginTicker()
            if(hwndTicker) then
                CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(hwndTicker)
                hwndTicker = nil
            end
            if forceLoginTimer then
                cancelTimeOut(forceLoginTimer)
                forceLoginTimer = nil
            end
        end

        function self:startAutoLogin( ... )
            if not isCheckAgreement() then
                return
            end
            -- 3秒后自动登录
            local platform = PlatformConfig:getPlatformNameLocalization(SnsProxy:getAuthorizeType())
            local winSize = CCDirector:sharedDirector():getWinSize()
            local origin = CCDirector:sharedDirector():getVisibleOrigin()

            local loginUserData = Localhost.getInstance():readLastLoginUserData().user
            local function onAutoLoginCallback()
                if self.autoLoginTimeOutId then 
                    cancelTimeOut(self.autoLoginTimeOutId) 
                    self.autoLoginTimeOutId = nil
                end
                freeLoginTicker()
                if onTouchOAuthLogin then onTouchOAuthLogin() end
            end
            local function onChangeAccountCallback()
                self:showButtons()
                if onTouchChangeAccount then onTouchChangeAccount() end
            end
            local autoLoginPanel = require("zoo.panel.accountPanel.AutoLoginPanel"):create(loginUserData, onAutoLoginCallback, onChangeAccountCallback)
            local panelSize = autoLoginPanel:getGroupBounds().size
            autoLoginPanel:setPosition(ccp(origin.x + (winSize.width - panelSize.width) / 2, origin.y + panelSize.height / 2 + 250))
            self:addChild(autoLoginPanel)


            local function delayAutoLogin()
                self.autoLoginScheduleId = nil
                if onTouchOAuthLogin then onTouchOAuthLogin() end
            end

            local function onAutoLoginTimer()
                local payment = PaymentBase:getPayment(Payments.CHINA_MOBILE)
                if(payment and payment.sdk_initialized) then
                    freeLoginTicker()
                    self.autoLoginTimeOutId = setTimeOut(delayAutoLogin, 3)
                    -- if onTouchOAuthLogin then onTouchOAuthLogin() end
                end
            end

            local function onForceAutoLoginTimer()
                freeLoginTicker()
                self.autoLoginTimeOutId = setTimeOut(delayAutoLogin, 3)
            end

            local function timoutFunc()
                local payment = PaymentBase:getPayment(Payments.CHINA_MOBILE)
                if(payment and payment:isEnabled()) then
                    hwndTicker = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onAutoLoginTimer, 0, false)
                    forceLoginTimer = setTimeOut(onForceAutoLoginTimer, 10)
                else
                    self.autoLoginTimeOutId = setTimeOut(delayAutoLogin, 3)
                end
            end
            autoLoginPanel:runAction(CCCallFunc:create(timoutFunc))
            self.autoLoginPanel = autoLoginPanel

            self.redButton:setString(platform .. "登录中……")
            -- self.redButton:runAction(CCSequence:createWithTwoActions(
            --     CCDelayTime:create(3),
            --     CCCallFunc:create(onTouchOAuthLogin)
            -- ))
            self:hideButtons()
            self.isDoingAutoLogin = true
        end

        function self:stopAutoLogin( ... )
            freeLoginTicker()
            if self.autoLoginTimeOutId then 
                cancelTimeOut(self.autoLoginTimeOutId) 
                self.autoLoginTimeOutId = nil
            end

            if self.autoLoginPanel and not self.autoLoginPanel.isDisposed then 
                self.autoLoginPanel:removeFromParentAndCleanup(true) 
                self.autoLoginPanel = nil
            end
            self.redButton:setString(Localization:getInstance():getText("button.start.game.loading"))
            -- self.redButton:stopAllActions()
            self.isDoingAutoLogin = false
            self:showButtons()
        end

        self:startAutoLogin()
    else
        local platform = Localization:getInstance():getText("platform.platform")
        local platformLoginTip = Localization:getInstance():getText("loading.tips.start.btn.qq", { platform = platform })

        self.redButton:setString(platformLoginTip)
        self.blueButton:setString(Localization:getInstance():getText("loading.tips.start.btn.guest"))

        if RealNameManager:isOpen() then
            self.blueButton:setString('快速登录')
        end


        self.redButton:removeEventListenerByName(DisplayEvents.kTouchTap)
        self.redButton:addEventListener(DisplayEvents.kTouchTap, onTouchOAuthLogin)
        self.blueButton:removeEventListenerByName(DisplayEvents.kTouchTap)
        self.blueButton:addEventListener(DisplayEvents.kTouchTap, onTouchGuestLogin)
    end

    if self.isDoingAutoLogin then return end

    if self.blueButton then 
        if PublishActUtil:isGroundPublish() then 
            self.blueButton:setVisible(false)
        else
            self.blueButton:setVisible(true)
        end
    end

    if self.redButton then 
        self.redButton:setVisible(true) 
        local lastAuthorType = PlatformConfig:getLastPlatformAuthType()
        BindPhoneBonus.hasPreloadLoginReward = false

        if not lastAuthorType and not self.isChangingAccount then

            if PlatformConfig:isPlatform(PlatformNameEnum.k360) then
                if BindQihooBonus:loginRewardEnabled(true) then  --推360绑定
                    self.redButton:removeTipLabel()
                    local itemID, num = BindQihooBonus:getBindRewards()
                    self.redButton:addRewardTipBubble(itemID, num)
                end
            else
                if BindPhoneBonus:loginRewardEnabled(true) then  --推手机绑定
                    BindPhoneBonus.hasPreloadLoginReward = true
                    self.redButton:removeTipLabel()
                    local itemID, num = BindPhoneBonus:getBindRewards()
                    self.redButton:addRewardTipBubble(itemID, num)
                elseif BindQQBonus:loginRewardEnabled(true) then  --推QQ绑定
                    self.redButton:removeTipLabel()
                    local itemID, num = BindQQBonus:getBindRewards()
                    self.redButton:addRewardTipBubble(itemID, num)
                end
            end
        end
    end
end

function PreloadingScene:onGuestButtonTouched()
    self:alertBeforeGuestLogin()
    self:hideButtons()
end

function PreloadingScene:onChangeAccountButtonTouched( ... )

    local function onSelectSnsLogin( evt )
        self:updateOAuthButtonState()
        if self.stopAutoLogin then
            self:stopAutoLogin()
        end
        SnsProxy:setAuthorizeType(evt.data)

        self:changeAccount()
    end

    local function onSelectPhoneLoginComplete( evt )
        -- local loginInfo = evt.data
        -- self:doLogin(loginInfo, true)

        self:oauthRegisterDetect(true)
    end

    local function onCancel( ... )
        self:updateOAuthButtonState()
        self:clearStatus()
    end
    
    self:hideButtons()

    local processor = require("zoo.loader.SelectAccountLoginProcessor").new()
    processor:addEventListener(processor.Events.kSnsLogin, onSelectSnsLogin)
    processor:addEventListener(processor.Events.kPhoneLoginComplete,onSelectPhoneLoginComplete)
    processor:addEventListener(processor.Events.kCancel,onCancel)
    processor:start(self,true)

end

function PreloadingScene:changeAccount()
    self.oauthChangeAccountProcessor = require("zoo.loader.OAuthChangeAccountProcessor").new()

    local function onChangeAccountComplete(evt)
        evt.target:rma()
        self:hideButtons()
        if evt.data then
            local loginInfo = evt.data
            self:doLogin(loginInfo, true, true)
        else
            self:oauthRegisterDetect()
        end
    end

    local function onChangeAccountError(evt)
        evt.target:rma()
        CommonTip:showTip(Localization:getInstance():getText("error.tip.-2"),'negative',nil,1)
        self:updateOAuthButtonState()
    end

    local function onChangeAccountCancel(evt)
        evt.target:rma()
        self:updateOAuthButtonState()
    end

    local function onChangeAccountReady(evt)
        -- do not remove event listener here, just logout ready
        local function cancelLoginCallback()
            self.oauthChangeAccountProcessor:rma()
            self.oauthChangeAccountProcessor:onCanceled()
            self:updateOAuthButtonState()
            self.oauthChangeAccountProcessor = nil
        end

        self:changeUIOnSNSLogin(cancelLoginCallback)
    end

    self.oauthChangeAccountProcessor:addEventListener(Events.kComplete, onChangeAccountComplete)
    self.oauthChangeAccountProcessor:addEventListener(Events.kError, onChangeAccountError)
    self.oauthChangeAccountProcessor:addEventListener(Events.kCancel, onChangeAccountCancel)
    self.oauthChangeAccountProcessor:addEventListener(Events.kStart, onChangeAccountReady)
    self.oauthChangeAccountProcessor:start(self)
    GameLauncherContext:getInstance():onStartLogin()
end

function PreloadingScene:alertBeforeGuestLogin()
    self:guestRegisterDetect()
end

function PreloadingScene:onOAuthButtonTouched()
    local isLogin = SnsProxy:isLogin() or SnsProxy:isPhoneLogin()
    if _G.isLocalDevelopMode then printx(0, "onOAuthButtonTouched " .. tostring(isLogin)) end
    if isLogin then
        -- login with cached OAuth info
        self:oauthLoginWithCache()
        self:hideButtons()
    else
        self:hideButtons()
        self:selectAccountLogin()
    end
end

function PreloadingScene:selectAccountLogin( ... )

    local function onSelectSnsLogin( evt )
        self:updateOAuthButtonState()
        if self.stopAutoLogin then
            self:stopAutoLogin()
        end
        SnsProxy:setAuthorizeType(evt.data)

        self:oauthLoginWithRequest()
    end

    local function onSelectPhoneLoginComplete( evt )
        -- local loginInfo = evt.data
        -- self:doLogin(loginInfo, true)
        self:oauthRegisterDetect()
    end

    local function onCancel( ... )
        self:updateOAuthButtonState()
        self:clearStatus()
    end

    local processor = require("zoo.loader.SelectAccountLoginProcessor").new()
    processor:addEventListener(processor.Events.kSnsLogin, onSelectSnsLogin)
    processor:addEventListener(processor.Events.kPhoneLoginComplete,onSelectPhoneLoginComplete)
    processor:addEventListener(processor.Events.kCancel,onCancel)
    processor:start(self,false,self.lastPhoneLoginExpire)
    GameLauncherContext:getInstance():onStartLogin()
end

function PreloadingScene:oauthLoginWithCache()
    local function loginWithCache(evt)
        evt.target:rma()
        self:oauthRegisterDetect()
    end

    local function loginWithRequest(evt)
        evt.target:rma()
        self:oauthLoginWithRequest()
    end

    if PlatformConfig:isPlatform(PlatformNameEnum.k360) and SnsProxy:getAuthorizeType() == PlatformAuthEnum.k360 then
        self:changeUIOnGuestLogin()
    end

    local oauthLoginWithTokenCacheProcessor = require("zoo.loader.OAuthLoginWithCacheProcessor").new()
    oauthLoginWithTokenCacheProcessor:addEventListener(Events.kComplete, loginWithCache)
    oauthLoginWithTokenCacheProcessor:addEventListener(Events.kError, loginWithRequest)
    oauthLoginWithTokenCacheProcessor:start()
    GameLauncherContext:getInstance():onStartLogin()
end

function PreloadingScene:oauthLoginWithRequest()
    if _G.isLocalDevelopMode then printx(0, "oauthLoginWithRequest") end
    local isCancel = false

    local function onLoginSuccess(evt)
        if _G.isLocalDevelopMode then printx(0, "oauthLoginProcessor " .. "onLoginSuccess") end
        evt.target:rma()
        self.requireButtons = false
        self:hideButtons()
        self:oauthRegisterDetect()
        self:clearStatus()
    end

    local function onLoginFail(evt)
        if _G.isLocalDevelopMode then printx(0, "oauthLoginProcessor " .. "onLoginFail") end
        evt.target:rma()
        isCancel = true
        self.requireButtons = false
        self:updateOAuthButtonState()
        self:clearStatus()
    end

    local function onLoginCancel(evt)
        if _G.isLocalDevelopMode then printx(0, "oauthLoginProcessor " .. "onLoginCancel") end
        evt.target:rma()
        isCancel = true
        self:updateOAuthButtonState()
        self:clearStatus()
    end

    local oauthLoginProcessor = require("zoo.loader.OAuthLoginWithRequestProcessor").new()
    oauthLoginProcessor:addEventListener(Events.kComplete, onLoginSuccess)
    oauthLoginProcessor:addEventListener(Events.kError, onLoginFail)
    oauthLoginProcessor:addEventListener(Events.kCancel, onLoginCancel)
    oauthLoginProcessor:start(self)
    GameLauncherContext:getInstance():onStartLogin()

    local function cancelLoginCallback()
        oauthLoginProcessor:rma()
        self:updateOAuthButtonState()
    end

    if not isCancel then
        self:changeUIOnSNSLogin(cancelLoginCallback)
    end
end

function PreloadingScene:oauthRegisterDetect(isSyncAfterChangeAccount)
    local function guestLoginOldUser(evt)
        evt.target:rma()
        local loginInfo = Localhost.getInstance():getLastLoginUserConfig()
        self:doLogin(loginInfo, true, isSyncAfterChangeAccount)
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


function PreloadingScene:guestRegisterDetect()
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

function PreloadingScene:doLogin(loginInfo, isOAuth, isSyncAfterChangeAccount)


    
    _G.tryLoginType = nil
    _G.inSyncUserDataByChangeAccount = nil
    if isSyncAfterChangeAccount then
        _G.inSyncUserDataByChangeAccount = true
    else
        _G.inSyncUserDataByChangeAccount = false
        if isOAuth then self.loginType = SnsProxy:getAuthorizeType()
        else self.loginType = PlatformAuthEnum.kGuest end
        _G.tryLoginType = self.loginType
    end

    local function setGuestCreateTime()
        --360包游客登录时特殊处理 
        --20170508 360方要求去掉此接口调用
        -- if __ANDROID then 
        --     SnsProxy:silentLogin()
        -- end

        local createTime = Localhost.getInstance():getGuestCreateTime()
        if not createTime then
            Localhost.getInstance():saveGuestCreateTime(os.time())
        end
    end

    local function onLoginFinish(evt)
        _G.inSyncUserDataByChangeAccount = false
        evt.target:rma()
        if isSyncAfterChangeAccount then
            if isOAuth then self.loginType = SnsProxy:getAuthorizeType()
            else self.loginType = PlatformAuthEnum.kGuest end
        end
        _G.kLoginType = self.loginType
        
        self:clearStatus()
        self:onLoadLoginFinish()
        if not isOAuth then setGuestCreateTime() end
        MissionModel:getInstance():updateDataOnLogin(true , isOAuth , loginInfo)

        if __ANDROID then
            local platformName = StartupConfig:getInstance():getPlatformName()
            if platformName == "he_ad_tt" then
                local method = _getPlatformAuthName(self.loginType)
                pcall(function ( ... )
                    local disp = luajava.bindClass("com.happyelements.hellolua.MainActivity_he_ad_tt")
                    m = disp:post2tt_login(method)
                end)
            end
        end

    end

    local function onLoginFail(evt)
        _G.inSyncUserDataByChangeAccount = false
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

            if userData 
                and _G.sns_token
                and userData.openId == _G.sns_token.openId
                then 
                self:clearStatus()
                self:onLoadLoginFinish()
                MissionModel:getInstance():updateDataOnLogin(false , isOAuth , loginInfo)
            else
                local msg = Localization:getInstance():getText("loading.tips.register.failure."..kLoginErrorType.register)
                CommonTip:showTip(msg, "negative")

                self:clearStatus()
                self.requireButtons = false
                -- 
                self:logout()
                self:updateOAuthButtonState()
            end
        else
            self:clearStatus()
            self:onLoadLoginFinish()
            if not isOAuth then setGuestCreateTime() end
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

function PreloadingScene:registerOAuthUser()
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
        -- 
        self:logout()
        self:updateOAuthButtonState()
    end

    local registerNewUserProcessor = require("zoo.loader.RegisterNewUserProcessor").new()
    registerNewUserProcessor:ad(Events.kComplete, onRegisterSuccess)
    registerNewUserProcessor:ad(Events.kError, onRegisterError)
    registerNewUserProcessor:start()

    self:changeUIOnRegister()
    GameLauncherContext:getInstance():onStartLogin()
end


function PreloadingScene:registerGuestUser()
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

function PreloadingScene:updateStatusLabel(text)
    if self.statusLabel and self.statusLabel.refCocosObj then
        self.statusLabel:stopAllActions()

        self.statusLabel:setVisible(true)
        self.statusLabel:setString(text)

        self.statusLabelShadow:setVisible(true)
        self.statusLabelShadow:setString(text)

        self.preventWallowLabel:setVisible(true)
    end
end

function PreloadingScene:changeUIOnGuestLogin()
    if self.statusLabel and self.statusLabel.refCocosObj then
        self.statusLabel:setVisible(true)
        self.statusLabel:setString("小浣熊努力登录中，请稍候~")
        self.statusLabelShadow:setVisible(true)
        self.statusLabelShadow:setString("小浣熊努力登录中，请稍候~")
        self.preventWallowLabel:setVisible(true)
    end
end

function PreloadingScene:changeUIOnRegister()
    if self.statusLabel and self.statusLabel.refCocosObj then
        self.statusLabel:setVisible(true)
        self.statusLabel:setString("小浣熊正在为您创建账号...")
        self.statusLabelShadow:setVisible(true)
        self.statusLabelShadow:setString("小浣熊正在为您创建账号...")
        self.preventWallowLabel:setVisible(true)
    end
end

function PreloadingScene:changeUIOnSNSLogin(cancelLoginCallback)
    if self.loginTipsLabel then self.loginTipsLabel:setVisible(false) end

    local loadingTip = "正在登录中"
    local cancelTip = "取消"
    local function onTouchCancel(evt)
        if cancelLoginCallback and type(cancelLoginCallback) == "function" then
            cancelLoginCallback()
        end
    end
    self.redButton:setString(loadingTip)
    self.blueButton:setString(cancelTip)
    self.redButton:setEnabled(false)
    self.blueButton:removeEventListenerByName(DisplayEvents.kTouchTap)
    self.blueButton:addEventListener(DisplayEvents.kTouchTap, onTouchCancel)
end

function PreloadingScene:changeUIOnConnect()
    if self.statusLabel and self.statusLabel.refCocosObj then
        self.statusLabel:setVisible(true)
        self.statusLabel:setString("数据合并中，请稍候~")
        self.statusLabelShadow:setVisible(true)
        self.statusLabelShadow:setString("数据合并中，请稍候~")
        self.preventWallowLabel:setVisible(true)
    end
end

function PreloadingScene:hideButtons()
    if self.startButton then self.startButton:setVisible(false) end
    if self.redButton then self.redButton:setVisible(false) end
    if self.blueButton then self.blueButton:setVisible(false) end
    if self.loginTipsLabel then self.loginTipsLabel:setVisible(false) end
end

function PreloadingScene:showButtons()
    if self.startButton then self.startButton:setVisible(true) end
    if self.redButton then self.redButton:setVisible(true) end
    if self.blueButton then self.blueButton:setVisible(true) end
    if self.loginTipsLabel then self.loginTipsLabel:setVisible(true) end
end

function PreloadingScene:clearStatus()
    if self.statusLabel and self.statusLabel.refCocosObj then
        self.statusLabel:setString("")
        self.statusLabel:setVisible(false)
        self.statusLabel:stopAllActions()
        self.statusLabelShadow:setString("")
        self.statusLabelShadow:setVisible(false)
        self.statusLabelShadow:stopAllActions()
    end
end

local function _triggerWkWebView()
    if __IOS then
        local blacklist = {
            833481925,
            837191221,
        }

        local uid = UserManager:getInstance().uid
        local enable = table.indexOf(blacklist, uid) == nil
        if AppController.setUseWKWebView then
            AppController:setUseWKWebView(enable)
        end
    end
end

local function gotoHome()
    --马俊松修改 跟着账号走了 不存了
    -- Localhost:saveCgPlayed(1)
    LevelDifficultyAdjustManager:loadAndInitConfig()
    
    UserEnergyRecoverManager:sharedInstance():startCheckEnergy()
    ExitAlertPanel:removeExitAlert(true)

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
    
    -- if _triggerWkWebView then pcall(_triggerWkWebView) end

end

function PreloadingScene:startGame()
    --这里刷新下默认支付方式 服务端和本地的记录可能已经无效
    PaymentManager.getInstance():initUserDefaultPaymentType()
    PaymentManager.getInstance():resetDefaultPaymentIfDisabled()
    PaymentManager.getInstance():refreshDefaultThirdPartyPayment()
    if __ANDROID and AndroidPayment.getInstance():isCMThirdPartOptimal() 
            and not PaymentManager.getInstance():checkDefaultPaymentValid() then
        PaymentManager.getInstance():setThirdPartPaymentAsDefault()
    end
    PaymentManager.getInstance():refreshDefaultPayment()

    local function onStartupAnimationFinish()
        self:updateUserNickname()
        gotoHome()
        if UserManager:getInstance():hasGuideFlag( kGuideFlags.FinishCartoon ) == false then
            UserLocalLogic:setGuideFlag( kGuideFlags.FinishCartoon )
        end
    end
    local isFinish = UserManager:getInstance():hasGuideFlag(kGuideFlags.FinishCartoon)
    local config = Localhost:getDefaultConfig()
    if config.pl==0 and not isFinish   then
        local StartupAnimation = require("zoo.animation.StartupAnimation")
        StartupAnimation:play(onStartupAnimationFinish)
    else 
        onStartupAnimationFinish()
    end

    if not _G.sns_token then -- Guest
        local profile = UserManager.getInstance().profile
        if profile and not table.isEmpty(profile.snsMap) then
            pcall(function() 
                DcUtil:UserTrack({category="sns_error", sub_category="sns_error", sns_map=table.serialize(profile.snsMap)})
            end)
        end
    end

    if PlatformConfig:isPlatform(PlatformNameEnum.kWDJ) 
        or PlatformConfig:isPlatform(PlatformNameEnum.k360) 
        or PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk) 
        or __IOS_FB 
        or (__IOS_QQ and SnsProxy:isQQLogin()) -- ios平台下只有qq登录时才会同步第三方好友
        or (_G.kUserSNSLogin and SnsProxy:getAuthorizeType() == PlatformAuthEnum.kQQ)
    then --只有sns账号登录时才会去同步sns好友。
        if _G.kUserSNSLogin and not PlatformConfig:isQQPlatform() then
            SnsProxy:syncSnsFriend()
        end
    end
end

function PreloadingScene:updateUserNickname()
    local updateUserNicknameProcessor = require("zoo.loader.UpdateUserNicknameProcessor")
    updateUserNicknameProcessor:start()
end

function PreloadingScene:loginOffline()
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

function PreloadingScene:onLoadLoginFinish()
    self:loadLevelConfigDynamicUpdate()
    local openId, accessToken,authorType
    if kUserLogin and sns_token then 
        openId = sns_token.openId
        accessToken = sns_token.accessToken
        authorType = sns_token.authorType
    end

    if openId and accessToken then 
        self:syncOAuthData(openId, accessToken,authorType) 
    else
        self:detectXiBaoAlert()
    end

    -- try2StartTencentoom()
end


function PreloadingScene:detectXiBaoAlert()
    local function continue(evt)
        evt.target:rma()
        self:startGame()
        LoginAlertModel:getInstance():writeLoginInfo()
    end

    local function backToLogin(evt)
        evt.target:rma()
        self:logout()
        self:showButtons()
        self:updateOAuthButtonState()
        if self.oauthChangeAccountProcessor ~= nil then
            self.oauthChangeAccountProcessor:rma()
            self.oauthChangeAccountProcessor = nil
        end
    end

    local function toAccountBindLogin(evt)
        evt.target:rma()
        self:logout()
        self:showButtons()
        self:updateOAuthButtonState()

        if self.redButton ~= nil then
            if not (PlatformConfig:isPlatform(PlatformNameEnum.k360) or PlatformConfig:isQQPlatform()) then
                setTimeOut(function( ... )
                    self.redButton:dispatchEvent(Event.new(DisplayEvents.kTouchTap, nil, self))
                end, 0.05)
            end
        end
    end

    local loginAlertModel = LoginAlertModel:getInstance()
    loginAlertModel:addEventListener(LoginAlertModel.EVENT_TYPE.kContinue, continue)
    loginAlertModel:addEventListener(LoginAlertModel.EVENT_TYPE.kBackToLogin, backToLogin)
    loginAlertModel:addEventListener(LoginAlertModel.EVENT_TYPE.kToAccountBindLogin, toAccountBindLogin)
    loginAlertModel:checkAlert(self.loginType)
end

function PreloadingScene:loadLevelConfigDynamicUpdate()
    -- local levelConfigUpdateProcessor = require("zoo.loader.LevelConfigUpdateProcessor").new()
    -- levelConfigUpdateProcessor:start()
    -- 拉取关卡难度调整配置
    local levelDifficultyUpdateProcessor = require("zoo.loader.LevelDifficultyUpdateProcessor").new()
    levelDifficultyUpdateProcessor:start()  
end

function PreloadingScene:isNeedChangeToMiAccount()
    return __ANDROID and PlatformConfig:isPlatform(PlatformNameEnum.kMI) 
            and SnsProxy:getAuthorizeType() == PlatformAuthEnum.kWeibo
            and sns_token 
end


function PreloadingScene:syncOAuthData(openId,accessToken,authorType)
    local function onSyncSuccess(evt)
        evt.target:rma()
        self:detectXiBaoAlert()
        self:clearStatus()
    end

    local function onSyncCancel(evt)
        evt.target:rma()
        self:updateOAuthButtonState()
        self:clearStatus()
    end

    local function onSyncCancelLogout(evt)
        evt.target:rma()
        self:logout()
        self:updateOAuthButtonState()
        self:clearStatus()
    end

    local hasReward = Localhost.getInstance():canShowLoginRewardTip()

    local syncProcessor = require("zoo.loader.SyncOAuthDataProcessor").new()
    syncProcessor:addEventListener(syncProcessor.events.kSyncSuccess, onSyncSuccess)
    syncProcessor:addEventListener(syncProcessor.events.kSyncCancel, onSyncCancel)
    syncProcessor:addEventListener(syncProcessor.events.kSyncCancelLogout, onSyncCancelLogout)
    syncProcessor:start(openId, accessToken,authorType,hasReward)

    self:changeUIOnConnect()
end

function PreloadingScene:logout()
    return self:_logout(true)
end

function PreloadingScene:logoutWithChangeAccount()
    return self:_logout(false)
end

function PreloadingScene:_logout(deleteUserData)
    local result = {}
    local uid = UserManager.getInstance().uid
    if deleteUserData then
        if uid then 
            if _G.isLocalDevelopMode then printx(0, "delete user data in PreloadingScene:logout() uid " .. uid) end
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

    he_log_info('wenkan PreloadingScene:_logout')
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

function PreloadingScene:onKeyBackClicked(...)
    assert(#{...} == 0)
    if _G.isLocalDevelopMode then printx(0, "HomeScene:onKeyBackClicked Called !") end
    if _G.__CMGAME_TISHEN then
        return self:onKeyBackClicked_Cmgame_tishen()
    end

    if __WP8 then
        if self.exitDialog then return end
        self.exitDialog = true
        local function msgCallback(r)
            if r then 
                Director.sharedDirector():exitGame()
            else
                self.exitDialog = false
            end
        end
        Wp8Utils:ShowMessageBox(Localization:getInstance():getText("game.exit.tip"), "", msgCallback)
        return
    end

    local function CmgameExit()
        if __ANDROID and
            PaymentBase:getPayment(Payments.CHINA_MOBILE_GAME):isEnabled() and 
            not PlatformConfig:isPlatform(PlatformNameEnum.kCMGame) 
            and _G.needCallCmgameExit
        then
            local function exit()
                local cmgamePayment = luajava.bindClass("com.happyelements.android.operatorpayment.cmgame.CMGamePayment")
                cmgamePayment:exitGame()
            end
            pcall(exit)
        end
    end

    local function callPaymentExit(paymentClass)
        if paymentClass then
            local function buildCallback(onExit, onCancel)
                return luajava.createProxy("com.happyelements.android.InvokeCallback", {
                    onSuccess = onExit or function(result) end,
                    onError = onError or function(errCode, msg) end,
                    onCancel = onCancel or function() end
                })
            end
            local exitCallback = buildCallback(
                function(obj)
                    CmgameExit()
                    Director.sharedDirector():exitGame()
                end,
                function()
                    self.exitDialog = false
                end
            )
            self.exitDialog = true
            paymentClass:exitGame(exitCallback)
        end
    end

    local pfName = StartupConfig:getInstance():getPlatformName()
    if PlatformConfig:isBaiduPlatform() and (__ANDROID and SnsProxy:getDuokuAdsOpen()) then
        local dUOKUProxy = luajava.bindClass("com.happyelements.hellolua.duoku.DUOKUProxy"):getInstance()
        if dUOKUProxy then
            dUOKUProxy:detectDKGameExit()
        end
    elseif PlatformConfig:isPlatform(PlatformNameEnum.kCMGame) then
        local cmgamePayment = luajava.bindClass("com.happyelements.android.operatorpayment.cmgame.CMGamePayment")
        callPaymentExit(cmgamePayment)
    elseif PlatformConfig:isPlatform(PlatformNameEnum.k189Store) then
        local telecomPayment = luajava.bindClass("com.happyelements.android.operatorpayment.telecom.TelecomPayment")
        callPaymentExit(telecomPayment)
    elseif PlatformConfig:isPlatform(PlatformNameEnum.kOppo) then
        local oppoProxy = luajava.bindClass("com.happyelements.android.platform.oppo.OppoProxy")
        callPaymentExit(oppoProxy)
    elseif PlatformConfig:isPlatform(PlatformNameEnum.kBBK) then
        local vivoProxy = luajava.bindClass("com.happyelements.android.platform.vivo.VivoProxy")
        callPaymentExit(vivoProxy)
    elseif PlatformConfig:isPlatform(PlatformNameEnum.k360) then
        local oppoProxy = luajava.bindClass("com.happyelements.android.platform.qihoo.QihooUserAgent")
        callPaymentExit(oppoProxy)
    else
        if self.exitDialog then return end
   
        local function onExit()
            if _G.isLocalDevelopMode then printx(0, "Info - Keypad Callback: sns onSuccess") end
            DcUtil:UserTrack({category="UI", sub_category="exit_game",t1 = 4, t2=1}, true)
            DcUtil:saveLogToLocal()
            CmgameExit()
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

end

function PreloadingScene:onKeyBackClicked_Cmgame_tishen(...)
    assert(#{...} == 0)
    local function CmgameExit()
        if __ANDROID and
            PaymentBase:getPayment(Payments.CHINA_MOBILE_GAME):isEnabled() and 
            not PlatformConfig:isPlatform(PlatformNameEnum.kCMGame)
        then
            local function exit()
                local cmgamePayment = luajava.bindClass("com.happyelements.android.operatorpayment.cmgame.CMGamePayment")
                cmgamePayment:exitGame()
            end
            pcall(exit)
        end
    end

    local function buildCallback(onExit, onCancel)
        return luajava.createProxy("com.happyelements.android.InvokeCallback", {
            onSuccess = onExit or function(result) end,
            onError = onError or function(errCode, msg) end,
            onCancel = onCancel or function() end
        })
    end

    local function CmgameExitWithParm( onExit, onCancel )
        if __ANDROID and
            PaymentBase:getPayment(Payments.CHINA_MOBILE_GAME):isEnabled() and 
            not PlatformConfig:isPlatform(PlatformNameEnum.kCMGame)
        then
            local exitCallback = buildCallback(
                function(obj)
                    if onExit then 
                        onExit() 
                    else
                        scheduleLocalNotification()
                        Director.sharedDirector():exitGame()
                    end
                end,
                function()
                    self.exitDialog = false
                    if onCancel then onCancel() end
                end
            )
            local function exit()
                local cmgamePayment = luajava.bindClass("com.happyelements.android.operatorpayment.cmgame.CMGamePayment")
                cmgamePayment:exitGame(exitCallback)
            end
            pcall(exit)
        else
            if onExit then onExit() end
        end
    end

    local function callPaymentExit(paymentClass)
        if paymentClass then
            local exitCallback = buildCallback(
                function(obj)
                    scheduleLocalNotification()
                    Director.sharedDirector():exitGame()
                end,
                function()
                    self.exitDialog = false
                end
            )
            self.exitDialog = true
            paymentClass:exitGame(exitCallback)
        end
    end

    local pfName = StartupConfig:getInstance():getPlatformName()
    if PlatformConfig:isBaiduPlatform() then
        local function onExit()
            local dUOKUProxy = luajava.bindClass("com.happyelements.hellolua.duoku.DUOKUProxy"):getInstance()
            if dUOKUProxy then
                dUOKUProxy:detectDKGameExit()
            end
        end
        
        CmgameExitWithParm(onExit)

    elseif PlatformConfig:isPlatform(PlatformNameEnum.kCMGame) then
        local function onExit()
            local cmgamePayment = luajava.bindClass("com.happyelements.android.operatorpayment.cmgame.CMGamePayment")
            callPaymentExit(cmgamePayment)
        end
        CmgameExitWithParm(onExit)
    elseif PlatformConfig:isPlatform(PlatformNameEnum.k189Store) then
        local function onExit()
            local telecomPayment = luajava.bindClass("com.happyelements.android.operatorpayment.telecom.TelecomPayment")
            callPaymentExit(telecomPayment)
        end
        CmgameExitWithParm(onExit)
    elseif PlatformConfig:isPlatform(PlatformNameEnum.kOppo) then
        local function onExit()
            local oppoProxy = luajava.bindClass("com.happyelements.android.platform.oppo.OppoProxy")
            callPaymentExit(oppoProxy)
        end
        CmgameExitWithParm(onExit)
    else
        if self.exitDialog then return end

        local function onExit1( ... )
            local function onExit(dcT1Record)
                print("Info - Keypad Callback: sns onSuccess")
                scheduleLocalNotification()
                DcUtil:UserTrack({category="UI", sub_category="exit_game",t1=dcT1Record,t2=1}, true)
                DcUtil:saveLogToLocal()
                if __ANDROID then
                    require "zoo.platform.VivoPlatform"
                    VivoPlatform:onEnd()
                end
                CCDirector:sharedDirector():endToLua()
            end
                
            local function onCancelExit(dcT1Record) 
                print("Info - Keypad Callback: sns onCancel")
                self.exitDialog = false
                PushActivity:sharedInstance():setPushActivityEnabled(true)
                DcUtil:UserTrack({category="UI", sub_category="exit_game",t1=dcT1Record,t2=2},true)
            end
            
            PushActivity:sharedInstance():setPushActivityEnabled(false)
            self.exitDialog = true
            ExitAlertPanel:create(onExit, onCancelExit):popout()
        end

        CmgameExitWithParm(onExit1)
    end
end

function PreloadingScene:onEnterBackground()
    ExitAlertPanel:removeExitAlert()
end

function PreloadingScene:onEnterForeGround()
    local function onEnterForeGroundStatusUpdate()
        local isLogin = false
        if __ANDROID then isLogin = SnsProxy:isLogin() end
        if self.requireButtons and not isLogin then self:updateOAuthButtonState() end
    end
end

function PreloadingScene:checkNeedClearLoginInfo( ... )
    local userConfig = Localhost:getInstance():getLastLoginUserConfig()
    if userConfig and userConfig.uid and tonumber(userConfig.uid) ~= nil then --uid 不是数字的不处理
        if not Localhost:getInstance():readLastLoginUserData() then
            Localhost:getInstance():deleteLastLoginUserConfig()
            _G.kDeviceID = UdidUtil:revertUdid()
        end
    end
end


return PreloadingScene