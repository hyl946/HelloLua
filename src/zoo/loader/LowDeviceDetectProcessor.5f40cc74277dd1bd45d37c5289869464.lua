require "zoo.loader.ETCConfig.lua"
require "zoo.util.KeyChainUtil"


local Processor = {}

local WHITE_LIST1 = {
-- "176D8D15-8483-4FB7-9DCA-66FAC0D34AF2",--479014671, --xiaodong

}

local function getWhitelist()
    local config = CCUserDefault:sharedUserDefault()
    if config:getBoolForKey("ios.use.low.quality.enable", false) == true then
        return 1
    end
    local metaInfo = MetaInfo:getInstance()
    if(metaInfo) then
        local code = metaInfo:getUdid()
        for i = 1, #WHITE_LIST1 do
            if code == WHITE_LIST1[i] then
                return 1
            end
        end
    end
    return 0
end

local _isInWhiteList = nil;
local function isInQualityWhiteList()
    if(_isInWhiteList == nil) then
        _isInWhiteList = getWhitelist() > 0
    end
    return _isInWhiteList
end


local function isIOSLowDevice()
    -- if string.find(deviceType, "iPhone3") ~= nil then isLowDevice = true end

    local result = false
    local frame = CCDirector:sharedDirector():getOpenGLView():getFrameSize()
    local deviceType = MetaInfo:getInstance():getMachineType() or ""
    local physicalMemory = NSProcessInfo:processInfo():physicalMemory() or 0
    local freeMemory = AppController:getFreeMemory()
    local totalMemory = AppController:getTotalMemory()
    if _G.isLocalDevelopMode then printx(0, "freeMemory.."..freeMemory.."/"..totalMemory) end
    physicalMemory = physicalMemory / (1024 * 1024)
    if physicalMemory < 1100 then result = true end
    if physicalMemory < 600 or frame.width < 400 then result = true end
    local systemVersion = AppController:getSystemVersion() or 7
    if _G.isLocalDevelopMode then printx(0, string.format("physicalMemory:%f systemVersion:%f", physicalMemory, systemVersion)) end

    -- 40版本后，增加了一批音效，发现这部分机型在加载完音效后也会崩，故把所有内存低于600的ios都判定为低端机
    -- if systemVersion < 7.0 then
    --     if string.find(deviceType, "iPhone4") ~= nil or string.find(deviceType, "iPad2") ~= nil or string.find(deviceType, "iPod5")~= nil then
    --         result = false
    --     end
    -- end

    if result then
        local isUserDefaultSet = CCUserDefault:sharedUserDefault():getStringForKey("game.userdef.texture")
        if _G.isLocalDevelopMode then printx(0, "isUserDefaultSet:"..tostring(isUserDefaultSet)) end
        if isUserDefaultSet ~= "1" then
            --setting is nil
            AppController:registerDefaultsFromSettingsBundle(false) --not use default setting(default is YES)
            local falseVal = NSNumber:numberWithBool(false)
            local userDefault = NSUserDefaults:standardUserDefaults()
            userDefault:setValue_forKey(falseVal, "textures_preference")
            CCUserDefault:sharedUserDefault():setStringForKey("game.userdef.texture", "1")
            CCUserDefault:sharedUserDefault():flush()           
        else
            AppController:registerDefaultsFromSettingsBundle(true) --read user default.
        end 

--[[
        local userDefault = NSUserDefaults:standardUserDefaults()
        local userPref = userDefault:objectForKey("textures_preference")
        if tonumber(userPref) == 0 then
            --use low device
            if _G.isLocalDevelopMode then printx(0, "NSUserDefaults:"..tostring(userPref)) end
        else
            result = false
        end
]]

    end

    -- local boo = true

    -- if result and not boo then
    --     CCTexture2D:setLowDevice(result)
    -- end

    -- if boo and result then
    --     result = true
    -- else
    --     result = false
    -- end

    return result
end


-- local function isAndroidLowDeviceJudge()
--     -- android 
--     local result = false
--     local physicalMemory = luajava.bindClass("com.happyelements.hellolua.share.DisplayUtil"):getSysMemory()
--     local frame = CCDirector:sharedDirector():getOpenGLView():getFrameSize()
--     physicalMemory = physicalMemory / (1024 * 1024)
--     if _G.isLocalDevelopMode then printx(0, string.format("physicalMemory:%f ", physicalMemory)) end
--     if physicalMemory < 600 or frame.width < 400 then result = true end
--     if physicalMemory < 0 then result = false end

--     return result
-- end


local function isAndroidLowDevice()
    local result = false

    local disp = luajava.bindClass("com.happyelements.hellolua.share.DisplayUtil")
    local physicalMemory = disp:getSysMemory()
    physicalMemory = physicalMemory / (1024 * 1024)

    if physicalMemory < 2100 then result = true end
    
    local frame = CCDirector:sharedDirector():getOpenGLView():getFrameSize()
    if physicalMemory < 600 or frame.width < 400 then result = true end

    -- android 全部判断为非低端机，抛弃android 600内存以下低端机型
--    result = true
    return result
end

local function isWP8LowDevice()
    local frameSize = CCDirector:sharedDirector():getOpenGLView():getFrameSize()
    local result = frameSize.width < 500 and Wp8Utils:isLowMemoryDevice()
    _G.kUseSmallResource = result
    _G.__use_small_res = result
    return result
end


local function getPhysicalMemory(  )
    if __IOS then
        local physicalMemory = NSProcessInfo:processInfo():physicalMemory() or 0
        return physicalMemory / (1024 * 1024)
    elseif __ANDROID then
        local disp = luajava.bindClass("com.happyelements.hellolua.share.DisplayUtil")
        local physicalMemory = disp:getSysMemory()

        --[[
        if(true)then
			print("app used memory: " .. disp:getAppUsedMemory() / (1024))
            print("sys used memory: " .. disp:getSysUsedMemory() / (1024 * 1024))
            print("sys free memory: " .. disp:getSysFreeMemory() / (1024 * 1024))
        end
        ]]

        return physicalMemory / (1024 * 1024)
    else
        return 0
    end
end



function isSystemLowMemory()
    pcall(function ( ... )
        if __IOS then
            local usedMemory = AppController:getUsedMemory() / (1024)
            if(usedMemory >= 1024) then
                return true
            end
            if(_G._devicePhysicalMemory) then
                local rate = usedMemory / _G._devicePhysicalMemory
                if(rate > 0.75) then
                    return true
                end
            end
        elseif __ANDROID then
            local disp = luajava.bindClass("com.happyelements.hellolua.share.DisplayUtil")
            if(disp) then
                return disp:getSysLowMemory(0.5, 64)
            end
        end
        
        return false
    end)
    
    return false
end


-----------------------------------------------------------------

local _gc_costs = {}
local function _add_gc_cost(c)
    -- if true then return end
    -- print(c)
    -- print(table.tostring(_gc_costs))
    if #_gc_costs == 0 then
        table.insert(_gc_costs, c)
    else
        if c <= _gc_costs[#_gc_costs] then
            table.insert(_gc_costs, c)
        else
            for i = 1, #_gc_costs do
                if c > _gc_costs[i] then
                    table.insert(_gc_costs, i, c)
                    break
                end
            end
        end
    end

    while #_gc_costs > 10 do
        table.remove(_gc_costs, 11)
    end
    -- print(table.tostring(_gc_costs))
    -- debug.debug()
end
local function _dump_gc_cost()
    local c = "gc_costs: "
    for i = 1, math.min(10, #_gc_costs) do
        c = c .. _gc_costs[i] .. ', '
    end

    local most = 0
    if #_gc_costs > 0 then
        most = _gc_costs[1]
    end

    return c, most
end
function _clear_gc_cost(log)
    if log then
        local c, most = _dump_gc_cost()
        print('dump gc costs: ' .. c)
        if most > 2 then
            he_log_error(c)
        end
    end

    _gc_costs = {}
end


local _lastGcTime = 0
function forceGcMemory(force, logImmediate)
    --[[
    if(not isInWhiteList()) then
        return
    end
    ]]

--[[
    if(__ANDROID) then
        if(_G.isLocalDevelopMode)then
            --myPcall(function ( ... )
                local disp = luajava.bindClass("com.happyelements.hellolua.share.DisplayUtil")
                if(disp) then
                    print("app used memory: " .. disp:getAppUsedMemory() / (1024))
                    print("sys used memory: " .. disp:getSysUsedMemory() / (1024 * 1024))
                    print("sys free memory: " .. disp:getSysFreeMemory() / (1024 * 1024))
                end
            --end)
            
        end

--        if not _G.__use_low_effect then
--            return
--        end
    end
]]

    local time = os.clock()
    if(time - _lastGcTime < 3) then
        return
    end
    _lastGcTime = time

    if(not force) then
        force = isSystemLowMemory()
    end

-- force = true
    if(force) then
        if(_G.isLocalDevelopMode) then 
            print("! lua collect garbage 333")
            -- print("__IOS =" , __IOS , "__ANDROID =" , __ANDROID , "isSystemLowMemory =" , isSystemLowMemory())
            -- print("forceGcMemory  at " , debug.traceback())
        end
        collectgarbage("collect")
        -- print("collectgarbage  done !")

        local elapsed = os.clock() - time
        _add_gc_cost(elapsed)

        if logImmediate then
            he_log_error('gc_costs_' .. tostring(elapsed))
        end
    end

end


local function isLowDevice()


    if __IOS then
        return isIOSLowDevice() or isInQualityWhiteList()
    elseif __ANDROID then
        return isAndroidLowDevice()
    elseif __WP8 then
        return isWP8LowDevice()
    else
        return true
    end  
    -- return true
end


function _logAppMemory(msg)
    local appUsed = 0
    local sysUsed = 0
    local sysFree = 0

    if(__ANDROID) then
        local disp = luajava.bindClass("com.happyelements.hellolua.share.DisplayUtil")
        if(disp) then
            appUsed = disp:getAppUsedMemory() / (1024)
            sysUsed = disp:getSysUsedMemory() / (1024 * 1024)
            sysFree = disp:getSysFreeMemory() / (1024 * 1024)
        end
    elseif(_IOS) then
    end

    msg = msg .. ", appUsed=" .. tostring(appUsed)
    msg = msg .. ", sysUsed=" .. tostring(sysUsed)
    msg = msg .. ", sysFree=" .. tostring(sysFree)
    he_log_error(msg)
    return appUsed, sysUsed, sysFree
end


function Processor:start(completeCallback)
    local function safeReadConfig()
        _G.useSmallResConfig = StartupConfig:getInstance():getSmallRes() 
    end
    pcall(safeReadConfig)

    local quality = CCUserDefault:sharedUserDefault():getIntegerForKey("game.texture.quality")
    if(not quality or quality == 0) then
        quality = 3
        CCUserDefault:sharedUserDefault():setIntegerForKey("game.texture.quality", quality)
        CCUserDefault:sharedUserDefault():flush()
    end
    _G._graphicQuality = quality
    _G._devicePhysicalMemory = getPhysicalMemory()

    local isLow = isLowDevice()
    _G.__isLowDevice = isLow
    if _G.isPlayDemo then _G.__isLowDevice = false end

    if isLow == true then
        if __IOS then
            if(_G._devicePhysicalMemory < 600 or isInQualityWhiteList()) then
                _G.__use_low_effect = true
                _G.__use_low_audio = false
            end
        elseif __ANDROID then
            if(_G._devicePhysicalMemory < 1100) then
                _G.__use_low_effect = true
                _G.__use_low_audio = false
            end
        elseif __WIN32 then
            _G.__use_low_effect = false
            _G.__use_low_audio = false
        else
            _G.__use_low_effect = true
            _G.__use_low_audio = true
        end  

    end

    if __IOS and isLow then
        CCTexture2D:enableScaleFeature(true)
        _G._scaleTexture = true

        local physicalMemory = getPhysicalMemory()
        if(physicalMemory > 600) then
            local sx = 0.7 + (quality - 3) * 0.1
            local sy = 0.7 + (quality - 3) * 0.1
            CCTexture2D:setScaledBounds(sx, sy)
        else
            local sx = 0.5 + (quality - 3) * 0.1
            local sy = 0.5 + (quality - 3) * 0.1
            CCTexture2D:setScaledBounds(sx, sy)
        end

        local items = {"flash/mapBaseItem", "flash/venom"}
        for k, v in ipairs(items) do
            CCTexture2D:addSensitiveRes(v)
        end

        -- iOS没有小资源了
        isLow = false
        _G.useSmallResConfig = false
    end

    if __ANDROID and isLow and true then

        local physicalMemory = getPhysicalMemory()
        if(physicalMemory > 1100) then
        elseif(physicalMemory > 600) then
            CCTexture2D:enableScaleFeature(true)
            _G._scaleTexture = true

            local sx = 1 + (quality - 3) * 0.1
            local sy = 1 + (quality - 3) * 0.1
            CCTexture2D:setScaledBounds(sx, sy)
        else
            CCTexture2D:enableScaleFeature(true)
            _G._scaleTexture = true

            local sx = 0.7 + (quality - 3) * 0.1
            local sy = 0.7 + (quality - 3) * 0.1
            CCTexture2D:setScaledBounds(sx, sy)
        end
    end

    if __WIN32 and isLow then
        CCTexture2D:enableScaleFeature(true)
        _G._scaleTexture = true

        local sx = 1 + (quality - 3) * 0.3
        local sy = 1 + (quality - 3) * 0.3
        CCTexture2D:setScaledBounds(sx, sy)
    end

    print("_G._graphicQuality = " .. tostring(_G._graphicQuality))
    print("_G._devicePhysicalMemory = " .. tostring(_G._devicePhysicalMemory))
    print("_G.__isLowDevice = " .. tostring(_G.__isLowDevice))
    print("_G.__use_low_effect = " .. tostring(_G.__use_low_effect))
    print("_G.__use_low_audio = " .. tostring(_G.__use_low_audio))
    print("_G._scaleTexture = " .. tostring(_G._scaleTexture))


    if _G.useSmallResConfig == true then isLow = true end
    _G.__use_small_res = false -- 没有小素材了,全部不使用
    -- if kUseSmallResource and isLow then
    --     CCDirector:sharedDirector():setContentScaleFactor(0.625)
    --     _G.__use_small_res = true
    -- end

    completeCallback()
end

 
function getDiskFreeSpace()
    local m = 65536

    local function disk()
        if __IOS then
            m = AppController:getFreeDiskSpace()
        elseif __ANDROID then
            local disp = luajava.bindClass("com.happyelements.hellolua.share.DisplayUtil")
            m = disp:getFreeDiskSpace()
        end
    end

    -- pcall(disk)
    disk()

    -- print('disk free space = ' .. tostring(m))
    return m
end



return Processor
