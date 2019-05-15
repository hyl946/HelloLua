local WechatQuickPayGuide = class()

local popout_times_key = "wechat.quick.pay.popout.times"
local popout_times_key_in_verification = popout_times_key..'.verification'

local popout_seconds_key = "wechat.quick.pay.popout.seconds"
local popout_seconds_key_in_verification = popout_seconds_key..'..verification'

function WechatQuickPayGuide.getPopoutTimesKey()
    local timesKey = popout_times_key
    if not WechatQuickPayLogic:isAutoCheckEnabled() then
        timesKey = popout_times_key_in_verification
    end
    return timesKey
end

function WechatQuickPayGuide.getPopoutSecondsKey()
    local secondsKey = popout_seconds_key
    if not WechatQuickPayLogic:isAutoCheckEnabled() then
        secondsKey = popout_seconds_key_in_verification
    end
    return secondsKey
end

function WechatQuickPayGuide.isGuideTime() -- 满足了时间间隔条件
    if not _G.wxmmGlobalEnabled then return false end
    local popoutTimes =  CCUserDefault:sharedUserDefault():getIntegerForKey(WechatQuickPayGuide.getPopoutTimesKey())
    local lastPopoutSeconds = CCUserDefault:sharedUserDefault():getIntegerForKey(WechatQuickPayGuide.getPopoutSecondsKey())

    --if the user have unsinged once, then don't guide the user again.
    if UserManager.getInstance():isWechatUnSigned() then
        return false
    end

    if _G.isLocalDevelopMode then printx(0, "wenkan WechatQuickPayGuide.isGuideTime, popoutTimes: "..tostring(popoutTimes).." ,lastPopoutSeconds: "..tostring(lastPopoutSeconds)..",now:"..tostring(Localhost:time() / 1000)) end
    if popoutTimes == 0 then
        return true
    elseif popoutTimes == 1 then
        return Localhost:time() / 1000 - lastPopoutSeconds > 24 * 3600
    elseif popoutTimes == 2 then
        return Localhost:time() / 1000 - lastPopoutSeconds > 5 * 24 * 3600
    else
        return false
    end
end

function WechatQuickPayGuide.getPopoutTimes()
    return CCUserDefault:sharedUserDefault():getIntegerForKey(WechatQuickPayGuide.getPopoutTimesKey())
end

function WechatQuickPayGuide.updateOnlyGuideTime()
    CCUserDefault:sharedUserDefault():setIntegerForKey(WechatQuickPayGuide.getPopoutSecondsKey(), Localhost:time() / 1000)
end

function WechatQuickPayGuide.updateGuideTimeAndPopCount()
    CCUserDefault:sharedUserDefault():setIntegerForKey(WechatQuickPayGuide.getPopoutSecondsKey(), Localhost:time() / 1000)

    local popoutTimes =  CCUserDefault:sharedUserDefault():getIntegerForKey(WechatQuickPayGuide.getPopoutTimesKey())
    CCUserDefault:sharedUserDefault():setIntegerForKey(WechatQuickPayGuide.getPopoutTimesKey(), popoutTimes+1)
end

function WechatQuickPayGuide.clearGuides()
    CCUserDefault:sharedUserDefault():setIntegerForKey(WechatQuickPayGuide.getPopoutTimesKey(), 0)
    CCUserDefault:sharedUserDefault():setIntegerForKey(WechatQuickPayGuide.getPopoutSecondsKey(), 0)
end

function WechatQuickPayGuide.showDebugPanel()
    local DebugPanel = require("zoo.panel.alipay.AliQuickPayDebugPanel")

    local popoutTimes =  CCUserDefault:sharedUserDefault():getIntegerForKey(WechatQuickPayGuide.getPopoutTimesKey())
    local lastPopoutSeconds = CCUserDefault:sharedUserDefault():getIntegerForKey(WechatQuickPayGuide.getPopoutSecondsKey())

    local panel = DebugPanel:create(popoutTimes, lastPopoutSeconds)
    panel:popout()
end

function WechatQuickPayGuide.isNetworkError(errorCode)
    return errorCode == -2 or errorCode == -6 or errorCode == -7
end

function WechatQuickPayGuide.getErrorMessage(errorCode, commonMessageKey)
--"error.tip.-2" = "请求未能成功发送";
--"error.tip.-6" = "对不起，网络连接失败";
--"error.tip.-7" = "TAT信号太弱，服务正在维护中，暂时无法连接到村长啦~";
    if WechatQuickPayGuide.isNetworkError(errorCode) then
        return localize("error.tip."..tostring(errorCode))
    end

    local errorMessgeKey = "wechat.quick.pay.error."..tostring(errorCode)
    local errorMessge = localize(errorMessgeKey)

    if errorMessge == errorMessgeKey then
        return localize(commonMessageKey)
    else
        return errorMessge
    end
end

return WechatQuickPayGuide

