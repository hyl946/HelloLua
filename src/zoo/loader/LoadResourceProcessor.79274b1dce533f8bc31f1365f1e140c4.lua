require "zoo.loader.AudioFrameLoader"

local Processor = class(EventDispatcher)

function Processor:checkFreeDiskSpace()
    local freeDiskSpace = getDiskFreeSpace()
    local warning = freeDiskSpace < 16
    if warning then
        he_log_error("not_enough_disk_space: " .. tostring(freeDiskSpace))
    end
end

function Processor:start(statusLabel, statusLabelShadow, progressBar)
    touchRegionsCollectStart()
    self:checkFreeDiskSpace()

    if __ANDROID and PlatformConfig:isPlatform(PlatformNameEnum.kWDJ) then
        table.insert(ResourceConfig.plist , "materials/wjd_head/head_images.plist")
    else 
        table.insert(ResourceConfig.plist , "materials/head_images.plist")
    end

    local loader = FrameLoader.new()

    MetaManager.getInstance():addToLoader( loader )
    LevelMapManager.getInstance():addToLoader( loader )

    for i, v in ipairs(ResourceConfig.skeleton) do loader:addRandom(v, kFrameLoaderType.skeleton) end
    for i,v in ipairs(ResourceConfig.json) do loader:addRandom(v, kFrameLoaderType.json) end
    for i,v in ipairs(ResourceConfig.plist) do loader:addRandom(v, kFrameLoaderType.plist) end

    if(AudioFrameLoader:needLoadEffect() and _G.__isLowDevice) then
--        SimpleAudioEngine doesn't cache preload music actually
--        for i, v in ipairs(ResourceConfig.mp3) do loader:add(v, kFrameLoaderType.mp3) end
        
        if _G.__use_low_audio then
            for i, v in ipairs(ResourceConfig.sfx_for_low_device) do loader:addRandom(v, kFrameLoaderType.sfx) end
        else
            for i, v in ipairs(ResourceConfig.sfx) do loader:addRandom(v, kFrameLoaderType.sfx) end
        end
    end



    if __WP8 then
        for i, v in ipairs(ResourceConfig.asyncPlist) do loader:add(v, kFrameLoaderType.plist) end
    end
    local startTime = os.clock()
    DcUtil:up(120)
    local function onLoadingDc()
        DcUtil:up(122)
    end
    local funcId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onLoadingDc, 30, false)
    local function onFrameLoadComplete( evt )
        loader:removeAllEventListeners()
        local endTime = os.clock()
        if _G.isLocalDevelopMode then printx(0, "load resource done, total time:", endTime - startTime) end

        ResourceManager:sharedInstance():loadNeededJsonFiles()

        -- if WorldSceneShowManager:isInAcitivtyTime() then 
        --     if not WorldSceneShowManager:getHasPlaySpringMusic() then 
        --         GamePlayMusicPlayer:getInstance():playSpringBgMusic()
        --         setTimeOut(function ()
        --             WorldSceneShowManager:setHasPlaySpringMusic(true)
        --             GamePlayMusicPlayer:getInstance():playWorldSceneBgMusic()
        --         end, 9)
        --     else
        --         GamePlayMusicPlayer:getInstance():playWorldSceneBgMusic()
        --     end
        -- else
            GamePlayMusicPlayer:getInstance():playWorldSceneBgMusic()
        -- end
        
        statusLabel:setVisible(false)
        statusLabelShadow:setVisible(false)
        if funcId ~= nil then CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(funcId) end
        DcUtil:up(130)

        progressBar:removeFromParentAndCleanup(true)

        self:dispatchEvent(Event.new(Events.kComplete, nil, self))

        AudioFrameLoader:startLoadEffect()

        if (false) then require('zoo.test.TestDragonLoad').loadAll() end

    end 
    local function onFrameLoadProgress( evt )
        local progress = loader.loaded / loader:getLength()
        progressBar:setPercentage(progress)
    end 
    loader:addEventListener(Events.kComplete, onFrameLoadComplete)
    loader:addEventListener(Events.kProgress, onFrameLoadProgress)
    loader:load()

    local tipIndex = math.floor(math.random() * 12)
    local tipKey = tostring(tipIndex)
    if tipIndex < 10 then tipKey = "0" .. tipKey end
    statusLabel:setString(Localization:getInstance():getText("loading.tips.text"..tipKey))
    statusLabelShadow:setString(Localization:getInstance():getText("loading.tips.text"..tipKey))

    if __IOS_QQ then
        -- get maintenance config
        local function onRequestFinish()
            if _G.isLocalDevelopMode then printx(0, "MaintenanceManager:initialize - onRequestFinish") end
            local ad = AdvertiseSDK:presentFishbowlAD()
            local scene = Director:sharedDirector():getRunningScene()
            if ad and scene then scene:addChild(ad) end
            if MaintenanceManager:getInstance():isInReview() then
                table.removeValue(PlatformConfig.authConfig, PlatformAuthEnum.kWechat)
            end
        end
        MaintenanceManager.getInstance():initialize(onRequestFinish)
    elseif not PlatformConfig:hasAuthConfig(PlatformAuthEnum.kPhone) then
        MaintenanceManager.getInstance():initialize() --取手机登录配置
    else
        MaintenanceManager.getInstance():initialize()
    end
end


--[[
    local mainActivityHolder = luajava.bindClass("com.happyelements.android.MainActivityHolder")
    local mainActivity = mainActivityHolder.ACTIVITY
    local applicationContext = mainActivity:getApplicationContext()
    local dataPath = applicationContext:getFilesDir():getAbsolutePath()
            print("arts __mytestfile.txt path " .. tostring(dataPath))
          local hFile, err = io.open(dataPath .. "/__mytestfile.txt", "w")
          if hFile and not err then
            print("arts __mytestfile.txt")
            datastr = hFile:write("hello file system")
            io.close(hFile)
            print("arts __mytestfile.txt done")
          end

            local mainActivityHolder = luajava.bindClass("com.happyelements.android.MainActivityHolder")
            local mainActivity = mainActivityHolder.ACTIVITY
            local service = luajava.bindClass("com.happyelements.test.TestService")
            local serviceClass = service:getPrimitive()
            local intent = luajava.newInstance("android.content.Intent", mainActivity, serviceClass)
            intent:putExtra("intentinformation", "print('I am come from mainactivity')");
            print("arts intent sent")
            mainActivity:startService(intent)
]]


return Processor