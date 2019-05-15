local WDJRemoveManager = class()

local function getDayStartTimeByTS(ts)
	if ts ~= nil then
		local utc8TimeOffset = 57600
		local dayInSec = 86400
		ts = ts - ((ts - utc8TimeOffset) % dayInSec)
		ts = ts * 1000
		return ts
	end

	return 0
end

local function getKey()
	return "wdj.remove.sdk." .. (UserManager:getInstance().user.uid or '12345')
end

local function getPopoutTypeKey()
	return getKey()..".popout.type"
end

local function getPopoutDateKey()
	return getKey()..".popout.day"
end

local function setPopoutType(data)
	CCUserDefault:sharedUserDefault():setIntegerForKey(getPopoutTypeKey(), tostring(data))
end

local function setPopoutDay()
	local now = Localhost:timeInSec()
	local today = getDayStartTimeByTS(now)
	CCUserDefault:sharedUserDefault():setStringForKey(getPopoutDateKey(), tostring(today))
end 

local function isWdjBound()--是否绑定豌豆荚账号
	if __WIN32 then
		--return true
	end
	local snsMap = UserManager:getInstance().profile.snsMap
	for k,v in pairs(snsMap) do
		if v.snsPlatform == PlatformAuthDetail[PlatformAuthEnum.kWDJ].name then
			return true
		end
	end

	return false
end

local function isPhoneLogin()--是否手机号登录
	if _G.sns_token then 
		if _G.sns_token.authorType == PlatformAuthEnum.kPhone then 
			return true
		else
			return false
		end
	end
	return false
end

local function isTodayForcePopout()
	local now = Localhost:timeInSec()
	local today = getDayStartTimeByTS(now)

	return (tonumber(CCUserDefault:sharedUserDefault():getStringForKey(getPopoutDateKey(), '0')) or 0) >= tonumber(tostring(today))
end

local function isMatchVersion()
	return tonumber(string.split(_G.bundleVersion, ".")[2]) >= 47
end

local function createIconInHomeScene()
	local function callback()
        local homeScene = HomeScene:sharedInstance()
        if not homeScene.wdjRemoveIcon then
        	local WDJRemoveButton = require("zoo.panel.wdjremove.WDJRemoveButton")
			local icon = WDJRemoveButton:create(true)

        	if isMatchVersion() then
        		homeScene:addIcon(icon)
        	else
	        	homeScene.leftRegionLayoutBar:addItem(icon)
	        end

	        homeScene.wdjRemoveIcon = icon

        end
    end
    HomeScene:sharedInstance():runAction(CCCallFunc:create(callback))
end


local function removeIconInHomeScene()
	local homeScene = HomeScene:sharedInstance()
    if homeScene.wdjRemoveIcon and not homeScene.wdjRemoveIcon.isDisposed then
    	if isMatchVersion() then
    		homeScene:removeIcon(homeScene.wdjRemoveIcon, true)
    	else
    		homeScene.leftRegionLayoutBar:removeItem(homeScene.wdjRemoveIcon)
        end
    end
    homeScene.wdjRemoveIcon = nil

end

function WDJRemoveManager:onEnterHomeScene()
	local popoutType, isPop = self:getPopoutType()
	if popoutType == 1 and not isPop then 
		createIconInHomeScene()
	else
		removeIconInHomeScene()
	end
end

function WDJRemoveManager:getPopoutType()--获得弹窗的弹出方式
	local isPop = false
	local popoutType = CCUserDefault:sharedUserDefault():getIntegerForKey(getPopoutTypeKey(), 0)

	if popoutType == 0 then 
		if isWdjBound() then
			if UserManager:getInstance().profile:isPhoneBound() then
				if isPhoneLogin() then 
					popoutType = 3
				else
					popoutType = 2
				end 
			else
				popoutType = 1
			end
		else
			popoutType = -1
		end
	end

	if popoutType == 1 then 
		if UserManager:getInstance().profile:isPhoneBound() then
			popoutType = -1
		else
			if isTodayForcePopout() then 
				isPop = false
			else
				isPop = true
			end
		end
	end
	if popoutType == 2 then 
		if isTodayForcePopout() then 
			isPop = false
		else
			isPop = true
		end
	end
	if popoutType == 3 then 
		isPop = true
	end

	--print("WDJRemoveManager popoutType = ", popoutType, " isPop = ", isPop)
	return popoutType, isPop
end

function WDJRemoveManager:popout(popoutType, isPop, callback)
	local WDJRemovePanel = require("zoo.panel.wdjremove.WDJRemovePanel")
	if popoutType == 1 and isPop then 
		setPopoutType(1)
		setPopoutDay()
		local function successCallback( ... )
			if callback then callback() end
			removeIconInHomeScene()
			setPopoutType(-1)
		end
		local function failCallback( ... )
			if callback then callback() end
			createIconInHomeScene()
		end
		WDJRemovePanel:create(1):popout(successCallback, failCallback)
	elseif popoutType == 2 and isPop then
		setPopoutType(2)
		setPopoutDay() 
		local function noPopCallback( ... )
			removeIconInHomeScene()
			setPopoutType(-1)
		end
		WDJRemovePanel:create(2):popout(callback, noPopCallback)
	elseif popoutType == 3 then
		setPopoutType(-1)
		WDJRemovePanel:create(3):popout(callback) 
	else
		--printx(5, " WDJRemoveManager.popout.popoutType = ", popoutType)
	end
end

return WDJRemoveManager