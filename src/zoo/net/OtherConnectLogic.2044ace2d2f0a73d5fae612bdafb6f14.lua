---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2018-01-25 19:12:37
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   Administrator
-- @Last Modified time: 2018-01-26 11:11:09
---------------------------------------------------------------------------------------
require "zoo.net.QzoneSyncLogic"

OtherConnectLogic = class()
OtherConnectPreLogic = class()
---------------------------------------------------------
---OtherConnectLogic
---------------------------------------------------------
function OtherConnectLogic:ctor(otherUid, authorType, openId, accessToken, snsName)
	self.openId = openId
	self.accessToken = accessToken
	self.snsName = snsName
	self.otherUid = otherUid
	self.authorType = authorType
end

function OtherConnectLogic:execute(onSuccess, onError)
	local function onSyncFinish()
        Localhost.getInstance():setCurrentUserOpenId(self.openId,nil,self.authorType)
        if onSuccess then onSuccess() end
    end
    local function onConnectError()
        local msg = Localization:getInstance():getText("loading.tips.register.failure."..kLoginErrorType.connect)
        CommonTip:showTip(msg, "negative")
    	if onError then onError() end
    end
    local function onSyncError()
        local msg = Localization:getInstance():getText("loading.tips.register.failure."..kLoginErrorType.changeUser)
        CommonTip:showTip(msg, "negative")
    	if onError then onError() end
    end
    local snsPlatform = PlatformConfig:getPlatformAuthName(self.authorType)
	local logic = QzoneSyncLogic.new(self.openId, self.accessToken, snsPlatform, self.snsName)
    logic:syncBind(self.otherUid, onSyncFinish, onConnectError, onSyncError)
end

---------------------------------------------------------
---OtherConnectPreLogic
---------------------------------------------------------
function OtherConnectPreLogic:ctor(otherUid, authorType)
	self.otherUid = otherUid
	self.authorType = authorType
end

function OtherConnectPreLogic:execute(onFinish, onError)
	local isNotTimeout = true
	local timeoutID = nil
	local function stopTimeout()
		if timeoutID ~= nil then CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(timeoutID) end
		timeoutID = nil
	end 
	local function onPreQzoneError( evt )
		evt.target:removeAllEventListeners()
		stopTimeout()
		if isNotTimeout then 
			if onError then onError() end
		end
	end
	local function onPreQzoneFinish( evt )	
		evt.target:removeAllEventListeners()
		stopTimeout()
		if isNotTimeout then 
			if onFinish then onFinish(evt.data) end 
		end
	end 
    local snsPlatform = PlatformConfig:getPlatformAuthName(self.authorType)

	local params = {
		otherUid = self.otherUid,
		snsPlatform = snsPlatform,
		deviceUdid = MetaInfo:getInstance():getUdid(),
	}

	local function onPreQzoneTimeout()
		stopTimeout()
		isNotTimeout = false
		if onError then onError() end
	end
	timeoutID = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onPreQzoneTimeout,10,false)

	local http = PreOtherConnectV4Http.new()
	http:addEventListener(Events.kComplete, onPreQzoneFinish)
	http:addEventListener(Events.kError, onPreQzoneError)
	http:load(params)
end
