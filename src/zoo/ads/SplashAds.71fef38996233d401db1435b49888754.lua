--[[
 * SplashAds
 * @date    2018-06-20 15:38:16
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]
require 'hecore.class'
require "zoo.net.Localhost"

local config = {
	['oppo'] = {
		class_name = "com.happyelements.android.platform.oppo.ads.SplashActivity",
		maintenance_name = "oppo_ad",
	},
	['bbk'] = {
		class_name = "com.happyelements.android.platform.vivo.ads.SplashActivity",
		maintenance_name = "vivo_ad",
	}
}

SplashAds = {}

function SplashAds:bindClass()
	if not self.splashRef then
		local function bind()
			self.splashRef = luajava.bindClass(self.config.class_name)
		end
		pcall(bind)
	end
end

function SplashAds:print( ... )
    printx(10, "[SplashAds]", ...)
    if self:isTestSigmob() then
        require "hecore.debug.remote"
        RemoteDebug:uploadLog("[SplashAds]", ...)
    end
end

function SplashAds:checkOfflinePath()
    local savedConfig = Localhost.getInstance():getLastLoginUserConfig()
    local uid = 0
    if savedConfig then uid = savedConfig.uid end

    if self.uid ~= uid then
        self.uid = uid
        self.dataPath = HeResPathUtils:getUserDataPath() .. '/splash_ad_'..(uid or '0')
    end
end

function SplashAds:checkOnlinePath()
    local uid = 0
    if UserManager and UserManager:getInstance().user then
        uid = UserManager:getInstance().user.uid or 0
    end

    if uid == 0 then
        self:checkOfflinePath()
    else
        self.dataPath = HeResPathUtils:getUserDataPath() .. '/splash_ad_'..(uid or '0')
    end
end

function SplashAds:writeCache(data, useOfflinePath)
    if useOfflinePath then
        self:checkOfflinePath()
    else
        self:checkOnlinePath()
    end

    local file = io.open(self.dataPath,"w")
    if file then
        file:write(table.serialize(data or {}))
        file:close()
    else
        self:print("write cache failed,", self.dataPath)
    end

    if _G.isLocalDevelopMode then
        local file = io.open(self.dataPath..".DEBUG","w")
        if file then 
            file:write(table.tostring(data or {}))
            file:close()
        end
    end
end

function SplashAds:readCache(useOfflinePath)
    if useOfflinePath then
        self:checkOfflinePath()
    else
        self:checkOnlinePath()
    end

    local file = io.open(self.dataPath, "r")
    if file then
        local content = file:read("*a") 
        file:close()
        if content then
            return table.deserialize(content) or {}
        end
    else
        self:print("read error:", self.dataPath)
    end
    return {}
end

function SplashAds:isTestSigmob()
    return false
end

function SplashAds:isSigmobEnabled( data )
    local showTime = data.showTime or 0
    local cd = (data.cd or 60)*60
    local now = Localhost:timeInSec()

    if not data.enabled then
        self:print('disabled, ask xiaoqiang please,',table.tostring(data))
        return false
    end

    if not data.enable4G and NetworkUtil:isMobileNetwork() then
        self:print('disabled 4G, ask xiaoqiang please!')
        return false
    end

    local ret = now > (showTime + cd)
    if not ret then
        self:print('disabled, is cool, after ', showTime + cd-now, 'second can show')
    end
    return ret
end

function SplashAds:createCallback(data)
    local context = self
    
    local function dc( sub_category, errorCode, msg )
        pcall(function ()
            DcUtil:UserTrack({
                category = "ad_screen",
                sub_category = sub_category,
                platform = context.pf,
                errorCode = errorCode,
                msg = msg
            })

        end)
    end

    local callback

    if __ANDROID then

        callback = luajava.createProxy("com.happyelements.AndroidAnimal.ads.SplashAd$SplashAdCallback", {
            onSplashAdSuccessPresentScreen = function ()
                data.showTime = Localhost:timeInSec()
                context:writeCache(data, true)
                dc('show_success')
            end,
            onSplashAdFailToPresent = function (code, msg)
                dc('loadError', code, msg)
            end,
            onSplashAdClicked = function ()
                dc('click')
            end,
            onSplashClosed = function ()
                dc('dismissed')
            end
        })
    end

    if __IOS then
        waxClass{"IosSplashCallbackImp", NSObject, protocols = {"IosGenericCallback"}}
        function IosSplashCallbackImp:onNotify( message, ... )
            if message == 'onSplashSuccess' then
                data.showTime = Localhost:timeInSec()
                context:writeCache(data, true)
                dc('show_success')

            elseif message == 'onSplashFailed' then
                local params = {...}
                local code = params[1] or 0
                local msg = params[2] or 'no error message'
                dc('loadError', code, msg)
            elseif message == 'onSplashClicked' then
                dc('click')
            elseif message == 'onSplashClosed' then
                dc('dismissed')
            end
        end
        callback = IosSplashCallbackImp:init()
    end

    return callback
end

local test_data = {
    appId = '1282',
    appKey = '27531c7c64157934',
    placementId = 'e04d1ac9231',
}

function SplashAds:showOppoVivo()
    local function showSplashAd()
        if self.splashRef then
            self.splashRef:showAds()
        end
    end

    self.pf = StartupConfig:getInstance():getPlatformName()
    self.config = config[self.pf]

    if self.config then
        self:bindClass()
        pcall(showSplashAd)
    end
end

function SplashAds:showAds()
	local function showSplashAd()
		if self.splashRef then
	    	self.splashRef:showAds()
	    end
	end

    self.pf = StartupConfig:getInstance():getPlatformName()
    self.config = config[self.pf]

    if false then
    	self:bindClass()
    	pcall(showSplashAd)
    elseif __ANDROID or __IOS then
        --maybe show sigmob
        local data = self:readCache(true)

        if self:isTestSigmob() then
            for k,v in pairs(test_data) do
                data[k] = v
            end
        end

        self:print(table.tostring(data))

        local appKey = data.appKey
        local appId = data.appId
        local placementId = data.placementId
        local appTitle = '开心消消乐'
        local appDesc = '你的快乐由我负责'

        if __ANDROID then
            if appId and appKey and placementId then
                local function bind()
                    self.splashRef = luajava.bindClass('com.happyelements.AndroidAnimal.ads.SplashAd').INSTANCE
                    if self:isSigmobEnabled(data) and self.splashRef then
                        self.splashRef:showAds(
                            appId,
                            appKey,
                            placementId,
                            appTitle,
                            appDesc,
                            self:createCallback(data))
                    end
                end
                pcall(bind)
            end
        end

        if __IOS then
            -- 只有还没进入HomeScene才会创建广告
            if placementId then
                if (not HomeScene) or (not HomeScene:hasInited()) then
                    if self:isSigmobEnabled(data) then
                        IosAds:showSplashAd_title_desc_callback(placementId, appTitle, appDesc, self:createCallback(data))
                    end
                end
            end
        end
    end
end

function SplashAds:checkAds()
	if self.config then
        if self.splashRef then
            local r = pcall(self.setAdsState)
            if not r then
                print('SplashActivity, error')
            end
        end
    else
        local info = UserManager:getInstance().splashAd
        local data = self:readCache()
        
        if info then
            data.appKey = info.appKey
            data.appId = info.appId
            data.placementId = info.placementId
            data.cd = info.frequency
            data.enable4G = info.enable4G
            data.enabled = true
        else
            data.enabled = false
        end

        self:writeCache(data)
    end
end

function SplashAds.setAdsState()
	local self = SplashAds
    local isInWhitelist = MaintenanceManager:isInWhitelist( self.config.maintenance_name )


    if PlatformConfig:isPlatform(PlatformNameEnum.kBBK) then
        local isNew = false
        local r = pcall(function ()
             isNew = self.splashRef:isNew()
        end)

        if not isNew then
            self.splashRef:setAdEnabled(false)
            return
        end
    end

    if isInWhitelist then
    	self.splashRef:setAdEnabled(true)
    	self.splashRef:setDisplayFrequence(1)
    	return
    end

    local info = UserManager:getInstance().splashAd
    if info then
        if info.extra ~= 'true' then
            self.splashRef:setAdEnabled(false)
            return
        end
    else
        self.splashRef:setAdEnabled(false)
        return
    end

    local maintenance = MaintenanceManager:getInstance():getMaintenanceByKey(self.config.maintenance_name)
    if maintenance == nil or not maintenance.enable then
    	self.splashRef:setAdEnabled(false)
    	return
    end

    local extra = tostring(maintenance.extra) or ""

    local t = extra:split(",")
    if #t < 3 then
    	self.splashRef:setAdEnabled(false)
		return
	end

    local minlevel = tonumber(t[1]) or 0
    local uidpis = t[2]:split("-")

    local start_uid = tonumber(uidpis[1]) or -1
    local end_uid = tonumber(uidpis[2]) or -1

    local uid = tonumber(UserManager:getInstance().uid) or 0
    uid = uid % 10000

	if uid < start_uid or uid > end_uid then
    	self.splashRef:setAdEnabled(false)
		return
	end

    local toplevel = UserManager.getInstance().user:getTopLevelId()
    if toplevel < minlevel then
    	self.splashRef:setAdEnabled(false)
    	return
    end

	local time = tonumber(t[3]) or 999999999
	self.splashRef:setAdEnabled(true)
    self.splashRef:setDisplayFrequence(time * 60)
end

Notify:register("SplashAdShowEvent", SplashAds.showAds, SplashAds)
Notify:register("SplashAdCheckEvent", SplashAds.checkAds, SplashAds)