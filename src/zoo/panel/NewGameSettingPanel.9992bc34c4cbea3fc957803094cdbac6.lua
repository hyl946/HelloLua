require 'zoo.panel.component.common.HorizontalTileLayout'
require "zoo.baseUI.ButtonWithShadow"
require 'zoo.util.OpenUrlUtil'
require 'zoo.payment.WechatQuickPayLogic'
require 'zoo.panelBusLogic.AliQuickPayPromoLogic'
local Anchor = require 'zoo.ui.Anchor'

local WifiAutoDownloadManager = require 'zoo.data.WifiAutoDownloadManager'

local DisplayQualityManager = require 'zoo.panel.customDisplayQuality.DisplayQualityManager'

local AliUnsignConfirmPanel = require "zoo.panel.alipay.AliUnsignConfirmPanel"
local AliPaymentSignAccountPanel = require "zoo.panel.alipay.AliPaymentSignAccountPanel"

NewGameSettingPanel = class(BasePanel)

local ButtonUIType = {
    
    kNormal = "basicSettingModule" ,
    kWithWindmill = "SettingModule_Windmill" ,
    kWithWifiAutoDownload = "SettingModule_WifiAutoDownload" ,
    kWithPrepackageNetwork = "SettingModule_prepackageNetwork" ,
}

function NewGameSettingPanel:create(source)
    local newNewGameSettingPanel = NewGameSettingPanel.new()
    newNewGameSettingPanel:loadRequiredResource(PanelConfigFiles.panel_game_setting)
    newNewGameSettingPanel:init(source)
    return newNewGameSettingPanel
end

function NewGameSettingPanel:initButtons( uiType )

    for k,v in pairs(ButtonUIType) do
        if v == uiType then

            self.settingUIModule = self.ui:getChildByName( v )

            self.musicBtn       = self.settingUIModule:getChildByName("musicBtn")
            self.soundBtn       = self.settingUIModule:getChildByName("soundBtn")
            self.notificationBtn        = self.settingUIModule:getChildByName("notificationBtn")
            self.speedBtn        = self.settingUIModule:getChildByName("speedBtn")

            self.musicBtnTip    = self.settingUIModule:getChildByName("musicBtnTip")
            self.soundBtnTip    = self.settingUIModule:getChildByName("soundBtnTip")
            self.notificationBtnTip = self.settingUIModule:getChildByName("notificationBtnTip")
            self.speedBtnTip = self.settingUIModule:getChildByName("speedBtnTip")

            if v == ButtonUIType.kNormal then

            elseif v == ButtonUIType.kWithWindmill then
                self.windmillBtn        = self.settingUIModule:getChildByName("windmillBtn")
            elseif v == ButtonUIType.kWithWifiAutoDownload then
                self.wifiAutoDownloadBtn        = self.settingUIModule:getChildByName("wifiAutoDownloadBtn")
                self.wifiAutoDownlloadTip = self.wifiAutoDownloadBtn:getChildByName('tips')
            elseif v == ButtonUIType.kWithPrepackageNetwork then
                self.prepackageNetworkBtn        = self.settingUIModule:getChildByName("prepackageNetworkBtn")
            end

            self.tips = {self.soundBtnTip, self.musicBtnTip, self.notificationBtnTip, self.wifiAutoDownlloadTip , self.speedBtnTip}

            -- Set Music / Effect Pause Icon 
            if GamePlayMusicPlayer:getInstance().IsMusicOpen then
                self.soundBtn:getChildByName("disable"):setVisible(false)
                self.soundBtn:getChildByName("enable"):setVisible(true)
            end

            if GamePlayMusicPlayer:getInstance().IsBackgroundMusicOPen then
                self.musicBtn:getChildByName("disable"):setVisible(false)
                self.musicBtn:getChildByName("enable"):setVisible(true)
            end

            if CCUserDefault:sharedUserDefault():getBoolForKey("game.local.notification") then
                self.notificationBtn:getChildByName("disable"):setVisible(false)
                self.notificationBtn:getChildByName("enable"):setVisible(true)
            end

            local speedSwitch = GameSpeedManager:getGameSpeedSwitch()
            self:updateSpeedButton( speedSwitch , true )

            local function onMusicBtnTapped()
                self:onMusicBtnTapped()
            end

            local function onSoundBtnTapped()
                self:onSoundBtnTapped()
            end

            local function onNotificationBtnTapped()
                self:onNotificationBtnTapped()
            end

            local function onSpeedBtnTapped()
                self:onSpeedBtnTapped()
            end

            self.musicBtn:setButtonMode(true)
            self.musicBtn:setTouchEnabled(true)
            self.musicBtn:addEventListener(DisplayEvents.kTouchTap, onMusicBtnTapped)

            self.soundBtn:setButtonMode(true)
            self.soundBtn:setTouchEnabled(true)
            self.soundBtn:addEventListener(DisplayEvents.kTouchTap, onSoundBtnTapped)

            self.notificationBtn:setButtonMode(true)
            self.notificationBtn:setTouchEnabled(true)
            self.notificationBtn:addEventListener(DisplayEvents.kTouchTap, onNotificationBtnTapped)

            self.speedBtn:setButtonMode(true)
            self.speedBtn:setTouchEnabled(true)
            self.speedBtn:addEventListener(DisplayEvents.kTouchTap, onSpeedBtnTapped)
        else
            local uiModule = self.ui:getChildByName( v )
            if uiModule then
                uiModule:removeFromParentAndCleanup(true)
            end
        end
    end

    if uiType == ButtonUIType.kNormal then

    end
end

function NewGameSettingPanel:updateSpeedButton( level , donotShowTip )
    if type(level) ~= "number" then level = 0 end
    local uiLevel = level + 1
    for i = 1 , 3 do
        if uiLevel == i then
            self.speedBtn:getChildByName( "level_" .. tostring(i) ):setVisible(true)
        else
            self.speedBtn:getChildByName( "level_" .. tostring(i) ):setVisible(false)
        end
    end

    if not donotShowTip then
        self.speedBtnTip:setString(Localization:getInstance():getText("game.setting.panel.speed.changed." .. tostring(uiLevel) )  )
        self:playShowHideLabelAnim(self.speedBtnTip)
    end
end

function NewGameSettingPanel:initIOS()
    self:hidePaymentIcons()
    if self:shouldShowWindmillBtn() then
        -- self:showWindmillBtn()
        self:initButtons( ButtonUIType.kWithWindmill )
    else
        -- self:hideWindmillBtn()
        self:initButtons( ButtonUIType.kNormal )
    end
end

function NewGameSettingPanel:init(source)
    self.source = source

    self.ui = self:buildInterfaceGroup("GameSettingPanelDrei")

    BasePanel.init(self, self.ui)

    self.onClosePanelBtnTappedCallback  = false

    self.panelChildren = {}
    self.ui:getVisibleChildrenList(self.panelChildren)
    
    self.panelTitle     = self.ui:getChildByName("panelTitle")
    self.closeBtn       = self.ui:getChildByName("closeBtn")

    self.panelTitle:setText(Localization:getInstance():getText("quit.panel.tittle"))
    self.bg = self.ui:getChildByName("_newBg")


    local size = self.panelTitle:getContentSize()
    local scale = 65 / size.height
    self.panelTitle:setScale(scale)
    self.panelTitle:setPositionX((self.bg:getGroupBounds().size.width - size.width * scale) / 2)
    -- self.panelTitle:setAnchor(Anchor:new(self.panelTitle, ANCHOR_ALIGN_TOP, {["parent"]=self.panelTitle.parent, ["oy"]=-50, ["parentGroup"]=true}))


    -------------------
    -- Add Event Listener
    -- ----------------
    local function onClosePanelBtnTapped(event)
        self:onCloseBtnTapped(event)
    end

    -- CLose Btn
    local function onCloseBtnTapped(event)
        self:onCloseBtnTapped(event)
    end

    self.closeBtn:setTouchEnabled(true, 0, true)
    self.closeBtn:setButtonMode(true)
    self.closeBtn:addEventListener(DisplayEvents.kTouchTap, onCloseBtnTapped)

    if __IOS or __WP8 then -- WP8怎么初始化，待定。。。
        self:initIOS()
    elseif __ANDROID or __WIN32 then
        self:initAndroid()
        -- self:initIOS()
    end

    self:updatePanelHeight()
    self:addDebugQualityBtns()
    self:addLogoutBtn()
    self:addVersionInfo()

    if _G.isLocalDevelopMode then
        self:addDebugInfos()
        -- self:addOptimizeBtn()
       -- self:addBoostBtn()
    end

    if DiffAdjustQAToolManager:getToolsEnabled() then --线上Debug功能
        local debugBtn = LayerColor:createWithColor(ccc3(64, 64, 64), 140, 60)
        local debugBtnLabel = TextField:create("QATool", nil, 30)
        debugBtnLabel:setAnchorPoint(ccp(0,0))
        debugBtnLabel:setPosition(ccp(10, 10))
        debugBtnLabel:setColor(ccc3(255, 255, 255))
        debugBtn:addChild(debugBtnLabel)
        debugBtn:setPosition(ccp(0, 0))
        self.ui:addChild(debugBtn)

        debugBtn:setTouchEnabled(true)
        debugBtn:addEventListener(DisplayEvents.kTouchTap, function() 
            DiffAdjustQAToolManager:openPanel()
            end)
    end
    

end

function NewGameSettingPanel:addLogoutBtn()
    if WXJPPackageUtil.getInstance():isWXJPPackage() then 
        -- self:hidePaymentIcons()

        local _newBg2 = self.ui:getChildByName('_newBg2')
        local newBg2width = _newBg2:getPreferredSize().width
        local newBg2Height = _newBg2:getPreferredSize().height
   
        local btnUI = self:buildInterfaceGroup("ui_buttons_new/btn_text")
        self.logoutBtn = GroupButtonBase:create(btnUI)
        self.logoutBtn:addEventListener(DisplayEvents.kTouchTap, function ()
            WXJPPackageUtil.getInstance():restartWithDataClean()
        end)
        self.logoutBtn:setString(localize("登出"))
        self.logoutBtn:setPosition(ccp( newBg2width/2 - 10 , newBg2Height * -1 - 10 ))
        self.settingUIModule:addChild(self.logoutBtn.groupNode)

        self:updatePanelHeight()
        
    end
end

function NewGameSettingPanel:addVersionInfo( ... )

    local _newBg = self.ui:getChildByName('_newBg')
    local width = _newBg:getPreferredSize().width
    local height = _newBg:getPreferredSize().height

    local container = Layer:create()
    local verLabel = TextField:create(localize('game.setting.panel.version.tip')..tostring(_G.bundleVersion), nil, 26)
    verLabel:setAnchorPoint(ccp(0.5,0.5))
    verLabel:setColor(hex2ccc3('7B4C06'))
    container:addChild(verLabel)

    container:setPositionX(width/2)
    container:setPositionY(verLabel:getContentSize().height)

    _newBg:addChild(container)

    
    _newBg:setPreferredSize(CCSizeMake(width,height + verLabel:getContentSize().height))    
end

function NewGameSettingPanel:addDebugInfos()
    if _G.isLocalDevelopMode then
        local _newBg = self.ui:getChildByName('_newBg')
        local width = _newBg:getPreferredSize().width
        local height = _newBg:getPreferredSize().height
        local container = Layer:create()
        local containerHeight = 100
        container:setContentSize(CCSizeMake(width, containerHeight))
        container:setPosition(ccp(0, -height-containerHeight))
        self.ui:addChild(container)

        local label = TextField:create("uid: "..tostring(UserManager.getInstance().uid), nil, 30)
        label:setAnchorPoint(ccp(0,0))
        label:setPosition(ccp(40, 105))
        label:setColor(ccc3(255, 0, 0))
        container:addChild(label)
        
        local label = TextField:create(os.date("%Y/%m/%d %H:%M:%S", Localhost:timeInSec()), nil, 30)
        label:setAnchorPoint(ccp(0,0))
        label:setPosition(ccp(40, 65))
        label:setColor(ccc3(255, 0, 0))
        container:addChild(label)

        local label = TextField:create("net:"..tostring(NetworkUtil:getNetworkStatus()), nil, 30)
        label:setAnchorPoint(ccp(0,0))
        label:setPosition(ccp(40, 145))
        label:setColor(ccc3(255, 0, 0))
        container:addChild(label)

        -- local debugLabel = TextField:create("DEBUG模式", nil, 24)
        -- debugLabel:setAnchorPoint(ccp(1,0))
        -- debugLabel:setColor(ccc3(122, 122, 122))
        -- debugLabel:setPosition(ccp(600, 20))
        -- container:addChild(debugLabel)
        local debugBtn = LayerColor:createWithColor(ccc3(64, 64, 64), 140, 60)
        local debugBtnLabel = TextField:create("隐藏调试", nil, 30)
        debugBtnLabel:setAnchorPoint(ccp(0,0))
        debugBtnLabel:setPosition(ccp(10, 10))
        debugBtnLabel:setColor(ccc3(255, 255, 255))
        debugBtn:addChild(debugBtnLabel)
        debugBtn:setPosition(ccp(470, 30))
        container:addChild(debugBtn)
        if _G._isShowDebugInfos == nil then _G._isShowDebugInfos = true end
        if _G._isShowDebugInfos then
            debugBtnLabel:setString("隐藏调试")
        else
            debugBtnLabel:setString("显示调试")
        end
        debugBtn:setTouchEnabled(true)
        debugBtn:addEventListener(DisplayEvents.kTouchTap, function() 
            if _G._isShowDebugInfos then
                debugBtnLabel:setString("显示调试")
                _G._isShowDebugInfos = false
            else
                debugBtnLabel:setString("隐藏调试")
                _G._isShowDebugInfos = true
            end
            CCDirector:sharedDirector():setDisplayStats(_G._isShowDebugInfos)
            GlobalEventDispatcher:getInstance():dispatchEvent(Event.new("onDebugStatusChanged", {isShowDebug=_G._isShowDebugInfos}))
            end)

        _newBg:setPreferredSize(CCSizeMake(width,height + container:getContentSize().height))
    end
end

function NewGameSettingPanel:addOptimizeBtn()
    if(not _G.isLocalDevelopMode) then
        return
    end

    local _newBg = self.ui:getChildByName('_newBg')
    local width = _newBg:getPreferredSize().width
    local height = _newBg:getPreferredSize().height
    local container = Layer:create()
    local containerHeight = 100
    container:setContentSize(CCSizeMake(width, containerHeight))
    container:setPosition(ccp(0, -height-containerHeight))
    self.ui:addChild(container)

    local debugBtn = LayerColor:createWithColor(ccc3(64, 64, 64), 140, 60)
    local debugBtnLabel = TextField:create("优化开启", nil, 30)
    debugBtnLabel:setAnchorPoint(ccp(0,0))
    debugBtnLabel:setPosition(ccp(10, 10))
    debugBtnLabel:setColor(ccc3(255, 255, 255))
    debugBtn:addChild(debugBtnLabel)
    debugBtn:setPosition(ccp(460, 30))
    container:addChild(debugBtn)

    local function refreshText()
        if _G._ENABLE_UPDATE_FIELD_LOGIC_POSSIBILITY then
            debugBtnLabel:setString("优化开启")
        else
            debugBtnLabel:setString("优化关闭")
        end
    end

    refreshText()
    debugBtn:setTouchEnabled(true)
    debugBtn:addEventListener(DisplayEvents.kTouchTap, function() 
        _G._ENABLE_UPDATE_FIELD_LOGIC_POSSIBILITY = not _G._ENABLE_UPDATE_FIELD_LOGIC_POSSIBILITY
        refreshText()
        end)


end

--[[
function NewGameSettingPanel:addBoostBtn()
    if(not _G.isLocalDevelopMode) then
        return
    end

    local _newBg = self.ui:getChildByName('_newBg')
    local width = _newBg:getPreferredSize().width
    local height = _newBg:getPreferredSize().height
    local container = Layer:create()
    local containerHeight = 100
    container:setContentSize(CCSizeMake(width, containerHeight))
    container:setPosition(ccp(0, -height-containerHeight))
    self.ui:addChild(container)

    local debugBtn = LayerColor:createWithColor(ccc3(64, 64, 64), 140, 60)
    local debugBtnLabel = TextField:create("10x开启", nil, 30)
    debugBtnLabel:setAnchorPoint(ccp(0,0))
    debugBtnLabel:setPosition(ccp(10, 10))
    debugBtnLabel:setColor(ccc3(255, 255, 255))
    debugBtn:addChild(debugBtnLabel)
    debugBtn:setPosition(ccp(460, 80))
    container:addChild(debugBtn)

    local function refreshText()
        if CCDirector:sharedDirector():isBoostMode() then
            debugBtnLabel:setString("10x开启")
        else
            debugBtnLabel:setString("10x关闭")
        end
    end

    refreshText()
    debugBtn:setTouchEnabled(true)
    debugBtn:addEventListener(DisplayEvents.kTouchTap, function() 
        if CCDirector:sharedDirector():isBoostMode() then
            CCDirector:sharedDirector():setBoostMode(1)
        else
            CCDirector:sharedDirector():setBoostMode(10)
        end
        refreshText()
        end)


end
]]

function NewGameSettingPanel:updatePanelHeight()
    local settingUIModuleHeight = self.settingUIModule:getGroupBounds().size.height
    local settingUIModuleY = self.settingUIModule:getPositionY()

    local _newBg = self.ui:getChildByName('_newBg')
    local width = _newBg:getPreferredSize().width

    local _newBg2 = self.ui:getChildByName('_newBg2')
    local bg2Height = settingUIModuleHeight + 45
    _newBg2:setPreferredSize(CCSizeMake(_newBg2:getPreferredSize().width, bg2Height ))
    _newBg:setPreferredSize(CCSizeMake( width, bg2Height + 180))
end

function NewGameSettingPanel:addDebugQualityBtns()
    if(not DisplayQualityManager:getInstance():isEnable()) then
--        if isInWhiteList == nil or not(isInWhiteList()) then
            return
--        end
    end

    local settingUIModuleHeight = self.settingUIModule:getGroupBounds().size.height
    
    local additionalSettingSelectQuality = require("zoo.panel.customDisplayQuality.AdditionalSettingPanelSelectQuality"):create()
    additionalSettingSelectQuality:setPosition(ccp( 30 , (settingUIModuleHeight + 25 ) * -1 ))

    self.settingUIModule:addChild(additionalSettingSelectQuality)
    self:updatePanelHeight()
    

    --[[

    --
    local labelLayer1 = LayerColor:create()
    labelLayer1:changeWidthAndHeight(100, 34)
    labelLayer1:setPosition(ccp(50, 0))
    labelLayer1:setColor(ccc3(128, 128, 128))
    labelLayer1:setTouchEnabled(true)
    _newBg:addChild(labelLayer1)

    local labelQ1 = TextField:create("LOW", nil, 24)
--    labelQ1:setAnchorPoint(ccp(1,0))
    labelQ1:setPosition(ccp(100, 10))
    _newBg:addChild(labelQ1)

    --
    local labelLayer2 = LayerColor:create()
    labelLayer2:changeWidthAndHeight(100, 34)
    labelLayer2:setPosition(ccp(250, 0))
    labelLayer2:setColor(ccc3(128, 128, 128))
    labelLayer2:setTouchEnabled(true)
    _newBg:addChild(labelLayer2)

    local labelQ2 = TextField:create("MIDDLE", nil, 24)
--    labelQ2:setAnchorPoint(ccp(1,0))
    labelQ2:setPosition(ccp(300, 10))
    _newBg:addChild(labelQ2)

    --
    local labelLayer3 = LayerColor:create()
    labelLayer3:changeWidthAndHeight(100, 34)
    labelLayer3:setPosition(ccp(450, 0))
    labelLayer3:setColor(ccc3(128, 128, 128))
    labelLayer3:setTouchEnabled(true)
    _newBg:addChild(labelLayer3)

    local labelQ3 = TextField:create("HIGH", nil, 24)
--    labelQ3:setAnchorPoint(ccp(1,0))
    labelQ3:setPosition(ccp(500, 10))
    _newBg:addChild(labelQ3)


    --
    local function changePresetQuality(q)
        if(q == 1) then
            labelQ1:setColor(ccc3(255, 0, 0))
            labelQ2:setColor(ccc3(255, 255, 255))
            labelQ3:setColor(ccc3(255, 255, 255))
        elseif(q == 2) then
            labelQ1:setColor(ccc3(255, 255, 255))
            labelQ2:setColor(ccc3(255, 0, 0))
            labelQ3:setColor(ccc3(255, 255, 255))
        elseif(q == 3) then
            labelQ1:setColor(ccc3(255, 255, 255))
            labelQ2:setColor(ccc3(255, 255, 255))
            labelQ3:setColor(ccc3(255, 0, 0))
        end

        CCUserDefault:sharedUserDefault():setIntegerForKey("game.texture.quality", q)
    end

    changePresetQuality(quality)

    labelLayer1:addEventListener(DisplayEvents.kTouchTap, function(event)
        changePresetQuality(1)
    end)
    labelLayer2:addEventListener(DisplayEvents.kTouchTap, function(event)
        changePresetQuality(2)
    end)
    labelLayer3:addEventListener(DisplayEvents.kTouchTap, function(event)
        changePresetQuality(3)
    end)
    ]]

end

function NewGameSettingPanel:hidePaymentIcons()

    local pay_text = self.ui:getChildByName('pay_text')
    if pay_text then pay_text:removeFromParentAndCleanup(true) end

    local ph = self.ui:getChildByName('ph')
    if ph then ph:removeFromParentAndCleanup(true) end

    for i=1,2 do
        local line = self.ui:getChildByName("line"..i)
        if line then line:removeFromParentAndCleanup(true) end
    end
end



function NewGameSettingPanel:shouldShowWindmillBtn()
    local isEnabled = MaintenanceManager:getInstance():isEnabled("IosSettingUrl")
    local hasNetwork = RequireNetworkAlert:popout(nil, 2)
    -- if _G.isLocalDevelopMode then printx(0, 'isEnabled', isEnabled, 'hasNetwork', hasNetwork) end
    return isEnabled and hasNetwork
end

function NewGameSettingPanel:showIcon_1_2_4()
    self.musicBtn:setPosition(ccp(64, -83))
    self.soundBtn:setPosition(ccp(195, -83))
    self.notificationBtn:setPosition(ccp(459, -83))
    self.musicBtnTip:setPosition(ccp(-28, 0))
    self.soundBtnTip:setPosition(ccp(103, 0))
    self.notificationBtnTip:setPosition(ccp(365, 0))
end

function NewGameSettingPanel:show4Icon()
    self.musicBtn:setPosition(ccp(64, -83))
    self.soundBtn:setPosition(ccp(195, -83))
    self.notificationBtn:setPosition(ccp(328, -83))

    self.musicBtnTip:setPosition(ccp(-28, 0))
    self.soundBtnTip:setPosition(ccp(103, 0))
    self.notificationBtnTip:setPosition(ccp(234, 0))
end

function NewGameSettingPanel:show3Icon( ... )
    self.musicBtn:setPosition(ccp(92, -83))
    self.soundBtn:setPosition(ccp(259, -83))
    self.notificationBtn:setPosition(ccp(432, -83))

    self.musicBtnTip:setPosition(ccp(-2, 0))
    self.soundBtnTip:setPosition(ccp(171, 0))
    self.notificationBtnTip:setPosition(ccp(338, 0))
end

local function isAliPayment(payment)
    return payment == Payments.ALIPAY or payment == Payments.ALI_QUICK_PAY
end

--移动短代可能两种方式都被注册~导致显示两个移动图标~这里特殊处理过滤下
local function cmPaymentSpecialPocess(payType)
    local cmTable =  {Payments.CHINA_MOBILE, Payments.CHINA_MOBILE_GAME, Payments.UMPAY}
    if table.includes(cmTable, payType) then
        if AndroidPayment.getInstance():filterCMPayment() == payType then 
            return true
        else
            return false
        end
    else
        return true
    end
end

function NewGameSettingPanel:initAndroid()
    -- self:hideWindmillBtn()
    if PrepackageUtil:isPreNoNetWork() then
        self:initButtons( ButtonUIType.kWithPrepackageNetwork )
        self.prepackageNetworkBtn:setTouchEnabled(true, 0, true)
        self.prepackageNetworkBtn:ad(DisplayEvents.kTouchTap, function () self:onPrepackageNetworkBtnTapped() end)
    elseif WifiAutoDownloadManager:getInstance():getState() ~= WifiAutoDownloadManager.States.kInvisible and not UpdatePackageManager:enabled() then
        
        self:initButtons( ButtonUIType.kWithWifiAutoDownload )
        local wadMgr = WifiAutoDownloadManager:getInstance()
        self.wifiAutoDownloadBtn:setTouchEnabled(true, 0, true)
        self.wifiAutoDownloadBtn:ad(DisplayEvents.kTouchTap, function () 
            if wadMgr:isTurnOn() then
                wadMgr:turnOff()
            else
                wadMgr:turnOn()
            end

            if wadMgr:isTurnOn() then
                self.wifiAutoDownlloadTip:setString(Localization:getInstance():getText("game.setting.panel.wifi.open.tip"))
            else
                self.wifiAutoDownlloadTip:setString(Localization:getInstance():getText("game.setting.panel.wifi.close.tip"))
            end
            self:playShowHideLabelAnim(self.wifiAutoDownlloadTip)
            
        end)

        self.wifiAutoDownloadBtn.refreshUI = function ( ... )
            if self.isDisposed then return end
            if (not self.wifiAutoDownloadBtn) or self.wifiAutoDownloadBtn.isDisposed then return end
            self.wifiAutoDownloadBtn:getChildByName('enable'):setVisible(wadMgr:isTurnOn())
            self.wifiAutoDownloadBtn:getChildByName('disable'):setVisible(wadMgr:isTurnOff())
        end

        self.wifiAutoDownloadBtn:refreshUI()

        wadMgr:ad(WifiAutoDownloadManager.Events.kStateChange, function ( ... )
            if self.isDisposed then return end
            if (not self.wifiAutoDownloadBtn) or self.wifiAutoDownloadBtn.isDisposed then return end
            self.wifiAutoDownloadBtn:refreshUI()
        end)

    else
        self:initButtons( ButtonUIType.kNormal )
    end

    if WXJPPackageUtil.getInstance():isWXJPPackage() then 
        self:hidePaymentIcons()
        return 
    end

    if _G.isLocalDevelopMode then printx(0, 'PlatformConfig ', table.tostring(PlatformConfig.paymentConfig)) end
    local payments = {}

    for payType,payment in pairs(PaymentBase:getPayments()) do
        if payment:isEnabled() and 
            cmPaymentSpecialPocess(payType) and 
            payment:getPaymentLevel() == PaymentLevel.kLvOne and
            payType ~= Payments.UMPAY
        then
            table.insert(payments, payType)
        end
    end

    if _G.isLocalDevelopMode then printx(0, 'payments: ', table.tostring(payments)) end

    local ph = self.ui:getChildByName('ph')
    local height = 85
    local iconCount = #payments
    if iconCount == 0 then
        self:hidePaymentIcons()
        return
    end

    ph:setVisible(false)
    local phSize = ph:getGroupBounds().size
    local layout = VerticalTileLayout:create(phSize.width)
    self.layout = layout

    local function buildItem(payment)
        local icon, icon_height = self:getPaymentIcon(payment)
        if not icon then return nil end
        icon:setScale(height/icon_height)
        local itemName = 'normal_pay_setting_item'
        if (payment == Payments.ALIPAY and not MaintenanceManager:getInstance():isEnabled("AliSignInGame2")) or 
            (payment == Payments.WECHAT and _G.wxmmGlobalEnabled and WechatQuickPayLogic:getInstance():isMaintenanceEnabled()) then
            itemName = 'quick_pay_setting_item'
        end
        local item = self.builder:buildGroup(itemName)
        local itemHeight = item:getGroupBounds().size.height
        local ph = item:getChildByName('ph')
        ph:setVisible(false)
        ph:getParent():addChild(icon)
        icon:setPositionX(ph:getPositionX())
        icon:setPositionY(ph:getPositionY())
        item:setTouchEnabled(true, 0, true)

        if payment == Payments.ALIPAY and not MaintenanceManager:getInstance():isEnabled("AliSignInGame2") then
            item:getChildByName('bigText'):setString(localize('panel.choosepayment.alipay'))
            item:getChildByName('text'):setString(localize('wechat.kf.set.ali.mm'))
        elseif payment == Payments.WECHAT then
            if _G.wxmmGlobalEnabled and WechatQuickPayLogic:getInstance():isMaintenanceEnabled() then
                item:getChildByName('bigText'):setString(localize('wechat.kf.pay2.wc'))
                item:getChildByName('text'):setString(localize('wechat.kf.set.wc.mm'))
            else
                item:getChildByName('text'):setString(localize('wechat.kf.pay2.wc'))
            end
        else
            local config = PaymentManager:getPaymentShowConfig(payment)
            item:getChildByName('text'):setString(config.name or '')
        end
        return item, itemHeight
    end

    local currentDefaultPayment = PaymentManager:getInstance():getDefaultPayment()
    if _G.isLocalDevelopMode then printx(0, 'currentDefaultPayment', currentDefaultPayment) end

    if not table.includes(payments, currentDefaultPayment) then
        currentDefaultPayment = PaymentManager:getInstance():getDefaultPayment(true)
    end


    -- 微信第一，支付宝第二，三方其次，短代最后
    local function sortPayments(payments)
        local wechat = nil
        local ali = nil
        local third = {}
        local others = {}
        for k, v in pairs(payments) do
            local payment = PaymentBase:getPayment(v)
            if v == Payments.WECHAT then
                wechat = Payments.WECHAT
            elseif v == Payments.ALIPAY then
                ali = Payments.ALIPAY
            elseif payment.mode == PaymentMode.kThirdParty and payment:getPaymentLevel() == PaymentLevel.kLvOne then
                table.insert(third, v)
            elseif payment.mode == PaymentMode.kSms then 
                table.insert(others, v)
            end
        end
        table.sort(third, function (v1, v2) return v1 < v2 end)
        table.sort(others, function (v1, v2) return v1 < v2 end)
        local ret = {}
        if wechat then
            table.insert(ret, wechat)
        end
        if ali then
            table.insert(ret, ali)
        end
        for k, v in pairs(third) do
            table.insert(ret, v)
        end
        for k, v in pairs(others) do
            table.insert(ret, v)
        end
        return ret
    end
    payments = sortPayments(payments)

    self.paymentIcons = {}
    for k, v in pairs(payments) do
        local item, item_height = buildItem(v)
        self.item_height = item_height
        if item then
            local wrapper = ItemInLayout:create()
            wrapper:setContent(item)
            wrapper:setHeight(item_height)
            item:ad(DisplayEvents.kTouchTap, function () self:onPaymentIconTapped(v) end)
            if (v == Payments.ALIPAY and not MaintenanceManager:getInstance():isEnabled("AliSignInGame2"))
            or (v == Payments.WECHAT and _G.wxmmGlobalEnabled and WechatQuickPayLogic:getInstance():isMaintenanceEnabled()) then
                local check_box = item:getChildByName('check_box')
                check_box:setTouchEnabled(true, 0, true)
                check_box:ad(DisplayEvents.kTouchTap, function () self:onQuickPaySwitchTapped(v) end)
            end
            layout:addItem(wrapper)
            self.paymentIcons[v] = wrapper
        end
    end

    local settingUIModuleHeight = self.settingUIModule:getGroupBounds().size.height
    local settingUIModuleY = self.settingUIModule:getPositionY()

    self.settingUIModule:addChild( layout )
    layout:setPosition( ccp( 50 , (settingUIModuleHeight + 85 ) * -1 )  )
    self:updatePanelHeight()

    local pay_text = self.ui:getChildByName("pay_text")
    local line1 = self.ui:getChildByName("line1")
    local line2 = self.ui:getChildByName("line2")

    pay_text:setPositionY( ( settingUIModuleY + ( settingUIModuleHeight + 10 ) * -1 ) )
    line1:setPositionY( ( settingUIModuleY + ( settingUIModuleHeight + 25 ) * -1 ) )
    line2:setPositionY( ( settingUIModuleY + ( settingUIModuleHeight + 25 ) * -1 ) )

    local payment = PaymentManager:getInstance():getDefaultPayment()
    self:setPaymentTip(payment)

    if not MaintenanceManager:getInstance():isEnabled("AliSignInGame2") then 
        self:setQuickPayCheckBox(Payments.ALIPAY, UserManager.getInstance():isAliSigned())
    end
    if _G.wxmmGlobalEnabled and WechatQuickPayLogic:getInstance():isMaintenanceEnabled() then
        self:setQuickPayCheckBox(Payments.WECHAT, UserManager.getInstance():isWechatSigned())
    end

    self:onPaymentIconTapped(currentDefaultPayment, true)
    self.previousPayment = currentDefaultPayment --打点数据 
end

function NewGameSettingPanel:onQuickPaySwitchTapped(payment)
    if payment == nil or payment == Payments.UNSUPPORT then return end
    local wrapper = self.paymentIcons[payment]
    if not wrapper then if _G.isLocalDevelopMode then printx(0, 'onPaymentIconTapped ERROR ', payment) end return end

    if payment == Payments.ALIPAY then
        if UserManager.getInstance():isAliSigned() then
            local panel = AliUnsignConfirmPanel:create()
            panel:popout(function() 
                    if self.isDisposed then return end
                    self:setQuickPayCheckBox(Payments.ALIPAY, false)
                end)
        else 
            -- local panel = AliPaymentSignAccountPanel:create(AliQuickSignEntranceEnum.NEW_GAME_SETTINGS_PANEL)
            -- panel:popout(nil, function() 
            --         if self.isDisposed then return end
            --         self:setQuickPayCheckBox(Payments.ALIPAY, true)
            --     end)
            local function onSignCallback(ret, data)
                if ret == AlipaySignRet.Success then
                    if self.isDisposed then return end
                    self:setQuickPayCheckBox(Payments.ALIPAY, true)
                elseif ret == AlipaySignRet.Cancel then
                elseif ret == AlipaySignRet.Fail then
                end
            end
            AlipaySignLogic.getInstance():startSign(AliQuickSignEntranceEnum.NEW_GAME_SETTINGS_PANEL, onSignCallback)
        end
    elseif payment == Payments.WECHAT then
        
        if UserManager.getInstance():isWechatSigned() then
            local WechatUnsignConfirmPanel = require 'zoo.panel.wechatPay.WechatUnsignConfirmPanel'
            local panel = WechatUnsignConfirmPanel:create()
            panel:popout(function() 
                    if self.isDisposed then return end
                    self:setQuickPayCheckBox(Payments.WECHAT, false)
                end)
        else
            local function onSuccess()
                CommonTip:showTip(localize('wechat.kf.sign.ok'), 'positive', nil, 3, false)
                if self.isDisposed then return end
                self:setQuickPayCheckBox(Payments.WECHAT, true)
            end
            local function onFail(error_code)
                if error_code == -1002 then
                    CommonTip:showTip(localize('wechat.kf.sign.fail.title')..'\n'..localize('wechat.kf.sign.fail.1'), 'negative', nil, 3)
                elseif error_code then
                    CommonTip:showTip(localize('wechat.kf.sign.fail.title')..'\n'..localize('error.tip.'..error_code), 'negative', nil, 3)
                else
                    CommonTip:showTip(localize('wechat.kf.sign.fail.title')..'\n'..localize('wechat.kf.sign.fail.2'), 'negative', nil, 3)
                end
                if self.isDisposed then return end
                self:setQuickPayCheckBox(Payments.WECHAT, false)
            end
            WechatQuickPayLogic:getInstance():sign(onSuccess, onFail, 3)
        end
    end
end

function NewGameSettingPanel:setQuickPayCheckBox(payment, value)
    if payment == nil or payment == Payments.UNSUPPORT then return end
    local wrapper = self.paymentIcons[payment]
    if not wrapper then if _G.isLocalDevelopMode then printx(0, 'onPaymentIconTapped ERROR ', payment) end return end

    local check_icon = wrapper:getContent():getChildByName('check_box'):getChildByName('icon')
    check_icon:setVisible(value)
end

function NewGameSettingPanel:onPaymentIconTapped(payment, isInit)
    if payment == nil or payment == Payments.UNSUPPORT then return end
    local wrapper = self.paymentIcons[payment]
    if not wrapper then if _G.isLocalDevelopMode then printx(0, 'onPaymentIconTapped ERROR ', payment) end return end

    if _G.isLocalDevelopMode then printx(0, "selected payment: ", payment) end

    for k, v in pairs(self.paymentIcons) do
        local isTapped = (v == wrapper)
        if _G.isLocalDevelopMode then printx(0, 'isTapped', isTapped) end
        local ui = v:getContent()
        ui:getChildByName('bg_disabled'):setVisible(not isTapped)
        ui:getChildByName('bg_enabled'):setVisible(isTapped)
    end

    if not isInit then
        self:setPaymentTip(payment)
        self:setPriorityPayment(payment)
    end
end

function NewGameSettingPanel:setPriorityPayment(payType)
    self.manualSetPayment = true
    -- 如果是移动短代，就要判断具体是哪一种
    if PaymentBase:isChinaMobile(payType) then
        payType = PaymentManager:getInstance():getDefaultSmsPayment()
        if _G.isLocalDevelopMode then printx(0, 'setPriorityPayment sms ', payType) end
    end

    if payType ~= Payments.UNSUPPORT and payType ~= nil then
        -- 设置真实的默认支付
        PaymentManager:getInstance():setDefaultPayment(payType)
    end

    if _G.isLocalDevelopMode then printx(0, 'setPriorityPayment', PaymentManager:getInstance():getDefaultPayment()) end
end

function NewGameSettingPanel:onMusicBtnTapped()    
    if GamePlayMusicPlayer:getInstance().IsBackgroundMusicOPen then
        GamePlayMusicPlayer:getInstance():pauseBackgroundMusic()
        self.musicBtn:getChildByName("disable"):setVisible(true)
        self.musicBtn:getChildByName("enable"):setVisible(false)

        self.musicBtnTip:setString(Localization:getInstance():getText("game.setting.panel.music.close.tip"))
    else
        GamePlayMusicPlayer:getInstance():resumeBackgroundMusic()
        self.musicBtn:getChildByName("disable"):setVisible(false)
        self.musicBtn:getChildByName("enable"):setVisible(true)

        self.musicBtnTip:setString(Localization:getInstance():getText("game.setting.panel.music.open.tip"))
    end

    self:playShowHideLabelAnim(self.musicBtnTip)
end


function NewGameSettingPanel:onSoundBtnTapped(...)
    if GamePlayMusicPlayer:getInstance().IsMusicOpen then
        GamePlayMusicPlayer:getInstance():pauseSoundEffects()
        self.soundBtn:getChildByName("disable"):setVisible(true)
        self.soundBtn:getChildByName("enable"):setVisible(false)

        self.soundBtnTip:setString(Localization:getInstance():getText("game.setting.panel.sound.close.tip"))
    else
        GamePlayMusicPlayer:getInstance():resumeSoundEffects()
        self.soundBtn:getChildByName("disable"):setVisible(false)
        self.soundBtn:getChildByName("enable"):setVisible(true)

        self.soundBtnTip:setString(Localization:getInstance():getText("game.setting.panel.sound.open.tip"))
    end

    self:playShowHideLabelAnim(self.soundBtnTip)
end

function NewGameSettingPanel:onNotificationBtnTapped(...)

    if _G.isLocalDevelopMode then printx(0, "GameSettingPanel:onNotificationBtnTapped Called !") end
    if not CCUserDefault:sharedUserDefault():getBoolForKey("game.local.notification") then
        CCUserDefault:sharedUserDefault():setBoolForKey("game.local.notification", true)
        self.notificationBtnTip:setString(Localization:getInstance():getText("game.setting.panel.notification.open.tip"))
        self.notificationBtn:getChildByName("disable"):setVisible(false)
        self.notificationBtn:getChildByName("enable"):setVisible(true)
    else
        CCUserDefault:sharedUserDefault():setBoolForKey("game.local.notification", false)
        self.notificationBtnTip:setString(Localization:getInstance():getText("game.setting.panel.notification.close.tip"))
        self.notificationBtn:getChildByName("disable"):setVisible(true)
        self.notificationBtn:getChildByName("enable"):setVisible(false)
    end
    self:playShowHideLabelAnim(self.notificationBtnTip)
    CCUserDefault:sharedUserDefault():flush()
end

function NewGameSettingPanel:onSpeedBtnTapped(...)
    local speedSwitch = GameSpeedManager:getGameSpeedSwitch()
    local fpsWarning = GameSpeedManager:getFPSWarningTipFlag()

    
    local function doChange()
        if type(speedSwitch) ~= "number" then speedSwitch = 0 end
        speedSwitch = speedSwitch + 1
        if speedSwitch > 2 then speedSwitch = 0 end
        GameSpeedManager:setGameSpeedSwitch( speedSwitch )
        self:updateSpeedButton( speedSwitch )
    end

    if fpsWarning then
        local text = {
            tip = Localization:getInstance():getText("game.speed.manager.fpsWarning.tipText"),
            yes = Localization:getInstance():getText("game.speed.manager.fpsWarning.tipbtn.yes"),
            no = Localization:getInstance():getText("game.speed.manager.fpsWarning.tipbtn.no"),
        }

        CommonTipWithBtn:showTip( text , "negative" , doChange , nil )
    else
        doChange()
    end
end


function NewGameSettingPanel:playShowHideLabelAnim(labelToControl, ...)

    local delayTime = 3

    labelToControl:stopAllActions()

    local function showFunc()
        -- Hide All Tip
        for k,v in pairs(self.tips) do
            v:setVisible(false)
        end

        labelToControl:setVisible(true)
    end
    local showAction = CCCallFunc:create(showFunc)


    local delay = CCDelayTime:create(delayTime)


    local function hideFunc()
        labelToControl:setVisible(false)
    end
    local hideAction = CCCallFunc:create(hideFunc)

    local actionArray = CCArray:create()
    actionArray:addObject(showAction)
    actionArray:addObject(delay)
    actionArray:addObject(hideAction)

    local seq = CCSequence:create(actionArray)
    --return seq
    
    labelToControl:runAction(seq)
end

function NewGameSettingPanel:onCloseBtnTapped(event, ...)
    assert(#{...} == 0)

    he_log_warning("this kind of panel pop remove anim can reused.")
    he_log_warning("reform needed !")

    AdvertiseSDK:dismissDomobAD()

    local function animFinished()
        self.allowBackKeyTap = false
        PopoutManager:sharedInstance():remove(self, true)

        if self.onClosePanelBtnTappedCallback then
            self.onClosePanelBtnTappedCallback()
        end
    end

    self:playHideAnim(animFinished)
    if __ANDROID and self.manualSetPayment then
        PaymentDCUtil.getInstance():sendDefaultPaymentChange(self.source, self.previousPayment, PaymentManager:getInstance():getDefaultPayment(), 0)
    end
end


function NewGameSettingPanel:onEnterHandler(event, ...)
    assert(#{...} == 0)
    if event == "enter" then
        self.allowBackKeyTap = true
        self:playShowAnim(false)
    end
end

function NewGameSettingPanel:createShowAnim(...)
    assert(#{...} == 0)

    he_log_warning("this show Anim is common to a type of panel !!!")
    he_log_warning("reform needed !")


    local centerPosX    = self:getHCenterInParentX()
    local centerPosY    = self:getVCenterInParentY()

    local function initActionFunc()

        local initPosX  = centerPosX
        local initPosY  = centerPosY + 100
        self:setPosition(ccp(initPosX, initPosY))
    end
    local initAction = CCCallFunc:create(initActionFunc)

    -- Move To Center Anim
    local moveToCenter      = CCMoveTo:create(0.5, ccp(centerPosX, centerPosY))
    local backOut           = CCEaseQuarticBackOut:create(moveToCenter, 33, -106, 126, -67, 15)
    local targetedMoveToCenter  = CCTargetedAction:create(self.refCocosObj, backOut)

    -- Action Array
    local actionArray = CCArray:create()
    actionArray:addObject(initAction)
    actionArray:addObject(targetedMoveToCenter)

    -- Seq
    local seq = CCSequence:create(actionArray)
    return seq
end

function NewGameSettingPanel:playShowAnim(animFinishCallback, ...)
    assert(animFinishCallback == false or type(animFinishCallback) == "function")
    assert(#{...} == 0)

    local showAnim  = self:createShowAnim()

    local function finishCallback()
        if animFinishCallback then
            animFinishCallback()
        end
        he_log_info("auto_test_quit_panel_open")
    end
    local callbackAction = CCCallFunc:create(finishCallback)

    local seq = CCSequence:createWithTwoActions(showAnim, callbackAction)
    self:runAction(seq)
end

function NewGameSettingPanel:playHideAnim(animFinishCallback, ...)
    animFinishCallback()
end

function NewGameSettingPanel:setOnClosePanelBtnTapped(onClosePanelBtnTappedCallback, ...)
    assert(type(onClosePanelBtnTappedCallback) == "function")
    assert(#{...} == 0)

    self.onClosePanelBtnTappedCallback = onClosePanelBtnTappedCallback
end

function NewGameSettingPanel:onWindmillBtnTapped()
    if self:shouldShowWindmillBtn() then
        local url = UserManager:getInstance().iosSettingUrl
        if url ~= nil and #url > 0 then
            OpenUrlUtil:openUrl(url)
        end
    else
        return
    end
end

function NewGameSettingPanel:popout()
    PopoutQueue.sharedInstance():push(self, true)
    self.allowBackKeyTap = true
end


function NewGameSettingPanel:getPaymentIcon(payType)
    if payType == Payments.UNSUPPORT then return nil end
    local icon = nil
    local payment = PaymentBase:getPayment(payType)
    if not payment then 
        assert(false, "NewGameSettingPanel:getPaymentIcon: no payment for payType ".. payType)
    end
    local iconName = payment.iconName
    if iconName and iconName ~= "" then 
        icon = self.builder:buildGroup(iconName)
    else
        assert(false, "NewGameSettingPanel:getPaymentIcon: no icon for payType ".. payType)
    end

    if not (_G.StoreManager and _G.StoreManager:safeIsEnabled()) then
        if payment.mode == PaymentMode.kThirdParty
            and payType ~= Payments.WO3PAY 
            and payType ~= Payments.TELECOM3PAY then
            local size = icon:getGroupBounds().size
            local cut5 = self.builder:buildGroup("5cut")
            cut5:setPosition(ccp(size.width - 39, size.height - 38))
            cut5:setScale(0.75)
            icon:addChild(cut5)
            return icon, size.height
        end
    end

    return icon, icon:getGroupBounds().size.height
end

function NewGameSettingPanel:setPaymentTip(payType)
    local tipString = ''
    local payment = PaymentBase:getPayment(payType)
    if not payment then 
        assert(false, "NewGameSettingPanel:setPaymentTip: no payment for payType ".. payType)
    end
    local iconTip = payment.iconTip
    if iconTip then
        tipString = localize(iconTip)
    end
    local pay_text = self.ui:getChildByName('pay_text')
    pay_text:setString(tipString)
end

function NewGameSettingPanel:onPrepackageNetworkBtnTapped()
    if _G.isLocalDevelopMode then printx(0, 'NewGameSettingPanel:onPrepackageNetworkBtnTapped') end
    PrepackageUtil:showSettingNetWorkDialog()
end