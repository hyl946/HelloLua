require 'zoo.util.FUUUManager'
require 'zoo.scenes.component.HomeScene.OneYuanShopButton'
require 'zoo.panel.iosSalesPromotion.IosNormalSalesPanel'
require 'zoo.panel.iosSalesPromotion.IosSpecialSalesPanel'
require 'zoo.panel.IosPayGuidePanels'

local PROMO_DURATION = 24 * 60 * 60
-- local PROMO_DURATION = 10
local FAIL_COUNT_THRESHOLD = 5
local ENERGY_THRESHOLD = 5
local TIP_TIME = 3 * 60 * 60

IosOneYuanPromotionType = {
    OneYuanProp = 1,
    OneYuanFCash = 2,   
    OneYuanAlphaProp = 3,
}

local function now()
    return os.time() + __g_utcDiffSeconds or 0
end

local guideModel = nil
local salesPanel = nil

IosPayGuide = class()

function IosPayGuide:init()
    local function onComplete()
       if IosPayGuide:maintenanceEnabled() and IosPayGuide:isInAppleVerification() then -- 苹果审核阶段
            if IosPayGuide:shouldTriggerOneYuanShop() then 
                guideModel:triggerPromotion(IosOneYuanPromotionType.OneYuanAlphaProp,
                        function()
                            IosPayGuide:startOneYuanShop()
                        end
                    )
            end
       else
            if IosPayGuide:isInOneYuanShopPromotion() then
                IosPayGuide:buildOneYuanShopIcon()
                --加推送
                IosPayGuide:pocessNotification(IosOneYuanPromotionType.OneYuanProp)
                --加强弹
                if guideModel:getNeedSecondDayPop() then
                    local function callback() -- 防止出现点击击穿
                        IosPayGuide:popoutOneYuanShopPanel()
                    end
                    HomeScene:sharedInstance():runAction(CCCallFunc:create(callback))                   
                end
            end
            if IosPayGuide:isInFCashPromotion() then
                IosPayGuide:showGoldButtonFlag()
                --加推送
                IosPayGuide:pocessNotification(IosOneYuanPromotionType.OneYuanFCash)
            end
       end
    end
    guideModel = require("zoo.gameGuide.IosPayGuideModel"):create()
    local function onFinished()
        onComplete()
    end
    
    guideModel:loadPromotionInfo(onFinished)
    LocalNotificationManager.getInstance():cancelAllIosSalesPromotion()
end

function IosPayGuide:pocessNotification(promotionType)
    local endTime 
    if promotionType == IosOneYuanPromotionType.OneYuanFCash then 
        endTime = guideModel:getFCashEndTime()/1000
    else
        endTime = guideModel:getOneYuanShopEndTime()/1000
    end
    if endTime and endTime > 0 then 
        local notiTime = endTime - 3600
        if now() < notiTime then 
            LocalNotificationManager.getInstance():setIosSalesPromotionNoti(promotionType, notiTime)
        end
    end
end

function IosPayGuide:onSuccessiveLevelFailure(levelId)
    if __ANDROID then return end
    if not IosPayGuide:shouldTriggerOneYuanShop(levelId) then
        return
    end

    guideModel:triggerPromotion(
        IosOneYuanPromotionType.OneYuanAlphaProp, 
        function()
             IosPayGuide:startOneYuanShop()
        end)
end

function IosPayGuide:startOneYuanShop()
    IosPayGuide:oneYuanShopStart()
    IosPayGuide:buildOneYuanShopIcon() 
    local function callback() -- 防止出现点击击穿
        IosPayGuide:popoutOneYuanShopPanel()
    end
    HomeScene:sharedInstance():runAction(CCCallFunc:create(callback)) 
end

function IosPayGuide:popoutOneYuanShopPanel()
    local function promoEndCallback()
        IosPayGuide:oneYuanShopEnd()
    end
    
    local promotionRef = guideModel:getOneYuanShopProductInfo()
    if promotionRef then 
        local oneYuanShopType = guideModel:getOneYuanShopType()
        if oneYuanShopType == IosOneYuanPromotionType.OneYuanAlphaProp or oneYuanShopType == IosOneYuanPromotionType.OneYuanProp then 
            if promotionRef.pLevel == 5 then 
                salesPanel = IosSpecialSalesPanel:create(promotionRef, IosPayGuide:getOneYuanShopLeftSeconds(), promoEndCallback)
            else
                salesPanel = IosNormalSalesPanel:create(promotionRef, IosPayGuide:getOneYuanShopLeftSeconds(), promoEndCallback)
            end
        end
        if salesPanel then salesPanel:popout() end
    else
        salesPanel = nil
    end
end

function IosPayGuide:updateOneYuanShopIcon()
    local homeScene = HomeScene:sharedInstance()
    if not homeScene.oneYuanShopButton or homeScene.oneYuanShopButton.isDisposed then -- 防止添加多个按钮
        return 
    end

    homeScene.oneYuanShopButton:setCdTime(IosPayGuide:getOneYuanShopLeftSeconds())
end

function IosPayGuide:buildOneYuanShopIcon()
    local button
    local function onTap()
        if not button._clicked then
            HomeScene:sharedInstance():onIconBtnFinishJob(button)
            button._clicked = true
        end
        IosPayGuide:popoutOneYuanShopPanel()
    end
    local function callback()
        local homeScene = HomeScene:sharedInstance()
        if homeScene.oneYuanShopButton and not homeScene.oneYuanShopButton.isDisposed then 
            if IosPayGuide:maintenanceEnabled() and IosPayGuide:isInAppleVerification() then -- 苹果审核阶段
                homeScene.leftRegionLayoutBar:removeItem(homeScene.oneYuanShopButton)
                homeScene.oneYuanShopButton = nil
            else
                return 
            end
        end
        local oneYuanShopType = guideModel:getOneYuanShopType()
        button = OneYuanShopButton:create(IosPayGuide:getOneYuanShopLeftSeconds(), oneYuanShopType)
        button._clicked = false
        homeScene:addIcon(button)
        homeScene.oneYuanShopButton = button
        button.wrapper:ad(DisplayEvents.kTouchTap, onTap)
    end
    HomeScene:sharedInstance():runAction(CCCallFunc:create(callback))
end

function IosPayGuide:oneYuanShopStart()
    DcUtil:UserTrack({ category='activity', sub_category='ios_promotion', num = 1})

    local oneYuanShopLeftSeconds = guideModel:getOneYuanShopLeftSeconds()
    local shopSchedId
    local function endPromotion()
        if shopSchedId then
            CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(shopSchedId)
            shopSchedId = nil
        end
        IosPayGuide:oneYuanShopEnd()
    end
    shopSchedId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(endPromotion, oneYuanShopLeftSeconds, false)
end

function IosPayGuide:oneYuanShopEnd()
    local homeScene = HomeScene:sharedInstance()
    if homeScene.oneYuanShopButton and not homeScene.oneYuanShopButton.isDisposed then
        homeScene.leftRegionLayoutBar:removeItem(homeScene.oneYuanShopButton)
        homeScene.oneYuanShopButton = nil
    end
    if salesPanel and not salesPanel.isDisposed and salesPanel:getParent() then 
        salesPanel:removePopout()
    end
    guideModel:oneYuanPropBought()
end

function IosPayGuide:setSalesPanel(panelRef)
    salesPanel = panelRef
end

function IosPayGuide:oneYuanFCashStart(successCallback)
    DcUtil:UserTrack({ category='activity', sub_category='ios_promotion', num = 2})

    guideModel:triggerPromotion(
        IosOneYuanPromotionType.OneYuanFCash, 
        function()
            IosPayGuide:showGoldButtonFlag()
            if successCallback then successCallback() end
        end)
end

function IosPayGuide:showGoldButtonFlag()
    local function localCallback()
        local button = HomeScene:sharedInstance().goldButton
        if button then
            button:setOneYuanCashFlagVisible(true)
        end   
    end
    HomeScene:sharedInstance():runAction(CCCallFunc:create(localCallback))
end

function IosPayGuide:removeOneYuanFCashFlag()
    local function localCallback()
        local button = HomeScene:sharedInstance().goldButton
        if button then
            button:setOneYuanCashFlagVisible(false)
        end   
    end
    HomeScene:sharedInstance():runAction(CCCallFunc:create(localCallback))
end

function IosPayGuide:oneYuanFCashEnd()
    guideModel:oneYuanFCashBought()
end

function IosPayGuide:isInFCashPromotion()
    return guideModel:isInFCashPromotion()
end

function IosPayGuide:isInOneYuanShopPromotion()
    return guideModel:isInOneYuanShopPromotion()
end

function IosPayGuide:isPayUserForShop()
    local lastPayFromNow = Localhost:time() - UserManager:getInstance():getUserExtendRef():getLastPayTime()
    local last60DaysPayedEnable =  IosPayGuide:last60DaysPayedEnabled()
    if _G.isLocalDevelopMode then printx(0, "now2: "..tostring(Localhost:time())) end
    
    if _G.isLocalDevelopMode then printx(0, "getLastPayTime: "..tostring(UserManager:getInstance():getUserExtendRef():getLastPayTime())) end
    if _G.isLocalDevelopMode then printx(0, "last60DaysPayedEnable:"..tostring(last60DaysPayedEnable)) end
    if _G.isLocalDevelopMode then printx(0, "payUser:"..tostring(UserManager:getInstance().userExtend.payUser)) end
    if last60DaysPayedEnable then
        return UserManager:getInstance().userExtend.payUser and lastPayFromNow < 30 * 24 * 3600 * 1000
    else
        return UserManager:getInstance().userExtend.payUser     
    end
end

function IosPayGuide:isPayUserForCash()
    if UserManager:getInstance().userExtend.payUser then 
        if guideModel:getPromotionLevel() == 5 then
            return false 
        end
        return true
    end
    return false
end

function IosPayGuide:isNonActiveUser() --exclude the new user.
    if _G.isLocalDevelopMode then printx(0, "getLeaveDay: "..tostring(RecallManager:getInstance():getLeaveDay())) end
    return RecallManager:getInstance():getLastLeaveTime() and RecallManager:getInstance():getLeaveDay() > 7
end

function IosPayGuide:shouldShowMarketOneYuanFCash()
    if __IOS and AppController:getSystemVersion() < 7 then -- 7.0以下不支持
        return false
    else
        if IosPayGuide:maintenanceEnabled() and IosPayGuide:isInAppleVerification() then -- 苹果审核阶段
            if _G.isLocalDevelopMode then printx(0, "##########################shouldShowMarketOneYuanFCash: step0") end
            return true
        end

        if not IosPayGuide:maintenanceEnabled() then
            if _G.isLocalDevelopMode then printx(0, "##########################shouldShowMarketOneYuanFCash: step1") end
            return false
        end

        if IosPayGuide:isInOneYuanShopPromotion() then 
            if _G.isLocalDevelopMode then printx(0, "##########################shouldShowMarketOneYuanFCash: step2") end
            return false
        end

        if UserManager:getInstance().user.topLevelId < 40 then
            if _G.isLocalDevelopMode then printx(0, "##########################shouldShowMarketOneYuanFCash: step3") end
            return false
        end

        if IosPayGuide:isPayUserForCash() then
            if _G.isLocalDevelopMode then printx(0, "##########################shouldShowMarketOneYuanFCash: step5") end
            return false
        end

        if IosPayGuide:hasTriggeredFCash() then
            if _G.isLocalDevelopMode then printx(0, "##########################shouldShowMarketOneYuanFCash: step6") end
            return false
        end

        if _G.isLocalDevelopMode then printx(0, "##########################shouldShowMarketOneYuanFCash: step0") end
        return true
    end
end

function IosPayGuide:getOneYuanFCashConfig()
    local config = MetaManager:getInstance().product[19]
    config.productIdentifier = config.productId --"com.happyelements.animal.gold.cn.19"
    config.iapPrice = 1
    return config
end

function IosPayGuide:shouldTriggerOneYuanShop(levelId)
    if not _G.kUserLogin then return false end
    if __IOS and AppController:getSystemVersion() < 7 then -- 7.0以下不支持
        return false
    else
        if IosPayGuide:maintenanceEnabled() and IosPayGuide:isInAppleVerification() then -- 苹果审核阶段
            if _G.isLocalDevelopMode then printx(0, "##########################shouldTriggerOneYuanShop: step0") end
            return true
        end

        if not IosPayGuide:maintenanceEnabled() then
            if _G.isLocalDevelopMode then printx(0, "##########################shouldTriggerOneYuanShop: step1") end
            return false
        end

        if IosPayGuide:isInFCashPromotion() then 
            if _G.isLocalDevelopMode then printx(0, "##########################shouldTriggerOneYuanShop: step2") end
            return false
        end

        if UserManager:getInstance().user.topLevelId < 40 then
            if _G.isLocalDevelopMode then printx(0, "##########################shouldTriggerOneYuanShop: step3") end
            return false
        end

        if IosPayGuide:isPayUserForShop() then
            if _G.isLocalDevelopMode then printx(0, "##########################shouldTriggerOneYuanShop: step5") end
            return false
        end

        local energyCount = UserManager:getInstance().user:getEnergy()
        if energyCount > ENERGY_THRESHOLD then
            if _G.isLocalDevelopMode then printx(0, "##########################shouldTriggerOneYuanShop: step7") end
            return false
        end

        if IosPayGuide:hasTriggeredOneYuanShop() then
            if _G.isLocalDevelopMode then printx(0, "##########################shouldTriggerOneYuanShop: step8") end
            return false
        end

        if _G.isLocalDevelopMode then printx(0, "##########################shouldTriggerOneYuanShop: step9") end
        return true
    end
end

function IosPayGuide:getOneYuanFCashLeftSeconds()
    return guideModel:getOneYuanFCashLeftSeconds()
end

function IosPayGuide:getOneYuanShopLeftSeconds()
    return guideModel:getOneYuanShopLeftSeconds()
end

function IosPayGuide:tryPopFailGuidePanel(cartoonCloseCallback)
    if not IosAliGuideUtils:isIOSAliGuideEnable() then
        return false
    end
    if guideModel:getFailGuidePopped() then
        return false
    end
    if UserManager:getInstance().userExtend.payUser then
        return false
    end
    
    if _G.StoreManager and _G.StoreManager:safeIsEnabled() then
        return false
    end


    IosPayFailGuidePanel:create(cartoonCloseCallback):popout()
    guideModel:setFailGuidePopped()
    return true
end

function IosPayGuide:maintenanceEnabled()
    return MaintenanceManager:getInstance():isEnabled("IosOneYuanPay") 
end

function IosPayGuide:last60DaysPayedEnabled()
    return MaintenanceManager:getInstance():isEnabled("last60DaysPayed")
end

function IosPayGuide:isInAppleVerification()
    if _G.isLocalDevelopMode then printx(0, 'isInAppleVerification', MaintenanceManager:getInstance():isEnabled("AppleVerification")) end
    return MaintenanceManager:getInstance():isEnabled("AppleVerification")
end

-- --为true时审核期间可无限次买
-- function IosPayGuide:isNoLimitBuy()
--     return MaintenanceManager:getInstance():isEnabled("IosOneYuanPayServer")  
-- end

function IosPayGuide:hasTriggeredFCash()
    return guideModel:hasTriggeredFCash()
end

function IosPayGuide:hasTriggeredOneYuanShop()
    return guideModel:hasTriggeredOneYuanShop()
end