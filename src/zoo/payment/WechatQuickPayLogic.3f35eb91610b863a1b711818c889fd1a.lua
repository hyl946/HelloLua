require 'zoo.util.WeChatSDK'
-- require 'zoo.payment.PaymentManager'

local wechat_error_code_offset = -1000

local WechatQuickPayGuide = require 'zoo.panel.wechatPay.WechatQuickPayGuide'

WechatQuickPayLogic = class()

local instance = nil
function WechatQuickPayLogic:getInstance()
    if not instance then
        instance = WechatQuickPayLogic.new()
        instance:init()
    end
    return instance
end

function WechatQuickPayLogic:init()

end

function WechatQuickPayLogic:sign(successCallback, failCallback, entryType, isAutoCheck)

    -- 打点
    if not entryType then
        entryType = 0
    end
    local popoutTimes = 0
    local userType = 4

    local payType = PaymentManager:getInstance():getDefaultPayment()
    local payment = PaymentBase:getPayment(payType)
    
    if payType == Payments.ALIPAY then
        userType = 2
    elseif payType == Payments.WECHAT then
        userType = 3
    elseif payType ~= Payments.UNSUPPORT and payment.mode == PaymentMode.kSms then
        userType = 1
    end
    local paraT1 = entryType * 10 + userType

    local function localFailCallback(error_code)
        _G.use_wechat_quick_pay = false
        if failCallback then
            failCallback(error_code)
        end
    end

    local scene
    local animation
    local triedCount = 0
    local retry = 3
    local interval = 2
    local function queryContract()
        GlobalEventDispatcher:getInstance():removeEventListenerByName(kGlobalEvents.kWechatSignReturn)
        self.waitingWechatReturn = false

        local function pollingContract()

            local function queryFinish(event)
                event.target:removeAllEventListeners()
                if event.data and event.data.contractId and event.data.contractId ~= '' then
                    if animation then animation:removeFromParentAndCleanup(true) end
                    UserManager:getInstance().userExtend.wxIngameState = 1
                    UserService:getInstance().userExtend.wxIngameState = 1
                    if NetworkConfig.writeLocalDataStorage then 
                        Localhost:getInstance():flushCurrentUserData()
                    else 
                        if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end 
                    end
                    if successCallback then
                        successCallback()
                        DcUtil:UserTrack({category = 'wechat_mm_accredit', sub_category = 'accredit_result', result = 1, t1 = paraT1, t2 = popoutTimes})
                    end
                else
                    if triedCount < retry then
                        setTimeOut(pollingContract, interval)
                    else
                        if animation then animation:removeFromParentAndCleanup(true) end
                        if localFailCallback then
                            localFailCallback()
                        end
                        DcUtil:UserTrack({category = 'wechat_mm_accredit', sub_category = 'accredit_result', result = 2, t1 = paraT1, t2 = popoutTimes})
                    end
                end
            end
            local function queryFail(event)
                event.target:removeAllEventListeners()
                if triedCount < retry then
                    setTimeOut(pollingContract, interval)
                else
                    if animation then animation:removeFromParentAndCleanup(true) end
                    if localFailCallback then
                        localFailCallback()
                    end
                end
            end

            local http = WxQueryContract.new(false)
            http:addEventListener(Events.kComplete, queryFinish)
            http:addEventListener(Events.kError, queryFail)
            http:load()
            triedCount = triedCount + 1
        end
        if animation then
            animation:removeFromParentAndCleanup(true)
        end
        -- 签约结果查询中
        scene = Director:sharedDirector():getRunningScene()
        if scene then
            animation = CountDownAnimation:createNetworkAnimation(scene, nil, Localization:getInstance():getText(localize("wechat.kf.jump1")))
        end
        pollingContract()
    end

    local function onRequestFinish(event)
        local url = event.data.url
        printx( 3 , '', url)
        if __ANDROID then

            local function callSDK()
                local payment = PaymentBase:getPayment(Payments.WECHAT)
                local paymentDelegate = payment.delegate
                local error_code = paymentDelegate:openWebview(url)
                if error_code ~= 0 then
                    if animation then animation:removeFromParentAndCleanup(true) end
                    if localFailCallback then
                        localFailCallback(error_code + wechat_error_code_offset)
                    end
                    DcUtil:UserTrack({category = 'wechat_mm_accredit', sub_category = 'accredit_app', skipout = 2, t1 = paraT1, t2 = popoutTimes})
                else
                    GlobalEventDispatcher:getInstance():addEventListener(kGlobalEvents.kWechatSignReturn, 
                        function (event) 
                            DcUtil:UserTrack({category = 'wechat_mm_accredit', sub_category = 'return', t1 = paraT1, t2 = popoutTimes})
                            queryContract() 
                        end)
                    self.waitingWechatReturn = true
                    DcUtil:UserTrack({category = 'wechat_mm_accredit', sub_category = 'accredit_app', skipout = 1, t1 = paraT1, t2 = popoutTimes})
                end
            end
            if not pcall(callSDK) then
                if animation then animation:removeFromParentAndCleanup(true) end
                if localFailCallback then
                    localFailCallback()
                end
                DcUtil:UserTrack({category = 'wechat_mm_accredit', sub_category = 'accredit_app', skipout = 2, t1 = paraT1, t2 = popoutTimes})
            end

        end
    end
    local function onRequestError(event)
        if animation then animation:removeFromParentAndCleanup(true) end
        if localFailCallback then
            local error_code = tonumber(event.data) or nil
            localFailCallback(error_code)
        end
    end
    local function onRequestCancel(event)
        if animation then animation:removeFromParentAndCleanup(true) end
        if localFailCallback then
            local error_code = tonumber(event.data) or nil
            localFailCallback(error_code)
        end
    end
    local function startSign()
        local http = WxGetContractUrl.new(false)
        http:addEventListener(Events.kComplete, onRequestFinish)
        http:addEventListener(Events.kError, onRequestError)
        http:addEventListener(Events.kCancel, onRequestCancel)
        http:load()

        -- 签约跳转中
        scene = Director:sharedDirector():getRunningScene()
        if scene then
            animation = CountDownAnimation:createNetworkAnimation(scene, onRequestCancel, Localization:getInstance():getText(localize("wechat.kf.jump2")))
        end
            

        -- 设置面板进入签约不更新防打扰
        if entryType ~= 3 and WechatQuickPayGuide.isGuideTime() then
            WechatQuickPayGuide.updateGuideTimeAndPopCount()
        end        
        if isAutoCheck then
            popoutTimes = WechatQuickPayGuide.getPopoutTimes()
        else
            popoutTimes = 4
        end

        
        DcUtil:UserTrack({category = 'wechat_mm_accredit', sub_category = 'wechat_mm_enter', t1 = paraT1, t2 = popoutTimes})
    end
    local function loginFail()
        if localFailCallback then
            localFailCallback(-6)
        end
    end
    RequireNetworkAlert:callFuncWithLogged(startSign, loginFail, kRequireNetworkAlertAnimation.kSync)
end

function WechatQuickPayLogic:isWaitingWechatApp()
    return self.waitingWechatReturn
end

function WechatQuickPayLogic:isMaintenanceEnabled()
    -- if isLocalDevelopMode then return true end
    local maintenacenOk = MaintenanceManager:getInstance():isEnabled('WechatKfEnabled')    
    if _G.isLocalDevelopMode then printx(0, string.format('wenkan isMaintenanceEnabled %s', tostring(maintenacenOk))) end

    local limitOk = (UserManager:getInstance():getDailyData():getWxPayRmb() < 500) and (UserManager:getInstance():getDailyData():getWxPayCount() < 5) 
    if _G.isLocalDevelopMode then printx(0, string.format('wenkan wxPayRmb %s wxPayCount %s', tostring(UserManager:getInstance():getDailyData():getWxPayRmb()), tostring(UserManager:getInstance():getDailyData():getWxPayCount()))) end
    return maintenacenOk and limitOk and _G.wxmmGlobalEnabled 
end

function WechatQuickPayLogic:isAutoCheckEnabled()
    -- if isLocalDevelopMode then return true end
    local maintenacenOk = MaintenanceManager:getInstance():isEnabled('WechatKfAutoCheck')
    if _G.isLocalDevelopMode then printx(0, string.format('wenkan isAutoCheckEnabled %s', tostring(maintenacenOk))) end
    return maintenacenOk and _G.wxmmGlobalEnabled 
end
