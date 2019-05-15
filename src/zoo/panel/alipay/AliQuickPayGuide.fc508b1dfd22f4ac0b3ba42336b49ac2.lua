
local AliQuickPayGuide = class()

function AliQuickPayGuide.isGuideTime() -- 满足了时间间隔条件
	local popoutTimes =  CCUserDefault:sharedUserDefault():getIntegerForKey("ali.quick.pay.popout.times")
	local lastPopoutSeconds = CCUserDefault:sharedUserDefault():getIntegerForKey("ali.quick.pay.popout.seconds")

	--if the user have unsinged once, then don't guide the user again.
	if UserManager.getInstance():isAliUnSigned() then
		return false
	end

	if _G.isLocalDevelopMode then printx(0, "AliQuickPayGuide.isGuideTime, popoutTimes: "..tostring(popoutTimes).." ,lastPopoutSeconds: "..tostring(lastPopoutSeconds)..",now:"..tostring(Localhost:time() / 1000)) end
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

function AliQuickPayGuide.getPopoutTimes()
	return CCUserDefault:sharedUserDefault():getIntegerForKey("ali.quick.pay.popout.times")
end

function AliQuickPayGuide.updateOnlyGuideTime()
	CCUserDefault:sharedUserDefault():setIntegerForKey("ali.quick.pay.popout.seconds", Localhost:time() / 1000)
end

function AliQuickPayGuide.updateGuideTimeAndPopCount()
	CCUserDefault:sharedUserDefault():setIntegerForKey("ali.quick.pay.popout.seconds", Localhost:time() / 1000)

	local popoutTimes =  CCUserDefault:sharedUserDefault():getIntegerForKey("ali.quick.pay.popout.times")
	CCUserDefault:sharedUserDefault():setIntegerForKey("ali.quick.pay.popout.times", popoutTimes+1)
end

function AliQuickPayGuide.clearGuides()
	CCUserDefault:sharedUserDefault():setIntegerForKey("ali.quick.pay.popout.times", 0)
	CCUserDefault:sharedUserDefault():setIntegerForKey("ali.quick.pay.popout.seconds", 0)
end

function AliQuickPayGuide.showDebugPanel()
	local DebugPanel = require("zoo.panel.alipay.AliQuickPayDebugPanel")

	local popoutTimes =  CCUserDefault:sharedUserDefault():getIntegerForKey("ali.quick.pay.popout.times")
	local lastPopoutSeconds = CCUserDefault:sharedUserDefault():getIntegerForKey("ali.quick.pay.popout.seconds")

	local panel = DebugPanel:create(popoutTimes, lastPopoutSeconds)
	panel:popout()
end

function AliQuickPayGuide.isNetworkError(errorCode)
	return errorCode == -2 or errorCode == -6 or errorCode == -7
end

function AliQuickPayGuide.getErrorMessage(errorCode, commonMessageKey)
--"error.tip.-2" = "请求未能成功发送";
--"error.tip.-6" = "对不起，网络连接失败";
--"error.tip.-7" = "TAT信号太弱，服务正在维护中，暂时无法连接到村长啦~";
	if AliQuickPayGuide.isNetworkError(errorCode) then
		return localize("error.tip."..tostring(errorCode))
	end

	local errorMessgeKey = "ali.quick.pay.error."..tostring(errorCode)
	local errorMessge = localize(errorMessgeKey)

	if errorMessge == errorMessgeKey then
		return localize(commonMessageKey)
	else
		return errorMessge
	end
end

return AliQuickPayGuide

