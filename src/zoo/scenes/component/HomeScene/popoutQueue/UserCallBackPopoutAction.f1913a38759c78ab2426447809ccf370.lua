-- local UserCallBackPanel = require "zoo.localActivity.UserCallBackTest.Start"
UserCallBackPopoutAction = class(HomeScenePopoutAction)

function UserCallBackPopoutAction:ctor()
	self.name = "UserCallBackPopoutAction"
	self.hasPop = false
	self.info = {
		[3009] = "UserCallBackTest/Config.lua",
		[81] = "UserCallBack/Config.lua",
	}
	self:setSource(AutoPopoutSource.kInitEnter, AutoPopoutSource.kEnterForeground, AutoPopoutSource.kSceneEnter)
end

function UserCallBackPopoutAction:resetPopFlag()
	self.hasPop = false 
end

function UserCallBackPopoutAction:getActInfo()
	local actInfo 
	for k, v in pairs(UserManager:getInstance().actInfos or {}) do
	    if self.info[v.actId] then
	        actInfo = v
	        break
	    end
	end

	return actInfo
end

function UserCallBackPopoutAction:checkCanPop()
	local ret = false


	local lastLoginTime = UserManager:getInstance().lastLoginTime
	if self.debug then
		lastLoginTime = 1530434280000
	end

	local userCallbackActInfo = UserManager:getInstance().userCallbackActInfo
	if userCallbackActInfo then
		ret = userCallbackActInfo.see 
	end
    if _G.isLocalDevelopMode then printx(101, "UserCallBackPopoutAction checkCanPop actInfo = " , table.tostring( userCallbackActInfo ) ) end
    ret = ret and not self.hasPop and lastLoginTime ~= nil and lastLoginTime >= 0
    ret = ret and (Localhost:getDayStartTimeByTS(lastLoginTime/1000) ~= Localhost:getDayStartTimeByTS(Localhost:timeInSec()))
    if not ret then
    	return self:onCheckPopResult(false)
    end
    self:onCheckPopResult(true)

end

function UserCallBackPopoutAction:popout(next_action)
    self.hasPop = true
	require("zoo.localActivity.UserCallBackTest.src.Start")(false,next_action)

end
