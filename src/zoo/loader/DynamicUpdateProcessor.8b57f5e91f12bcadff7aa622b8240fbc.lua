local Processor = {}

local function startGame(afterUpdate)
    if afterUpdate then
        if Processor.successCallback and type(Processor.successCallback) == 'function' then 
            Processor.successCallback() 
        end   
    else
        if Processor.failCallback and type(Processor.failCallback) == 'function' then 
            Processor.failCallback() 
        end   
    end
end

local function parseDynamicNameValuePair( item, target )
    if item ~= nil and item ~= "" then
        local list = string.split(item, ":")
        if list and #list == 2 then
            target[list[1]] = list[2]
        end
    end
end
local function parseDynamicUserData( userdata )
    local result = {}
    if userdata ~= nil and userdata ~= "" then
        local list = string.split(userdata, ";")
        if list and #list > 0 then
            for i,v in ipairs(list) do
                parseDynamicNameValuePair( v, result )
            end
        else
            parseDynamicNameValuePair( userdata, result )
        end
    end
    return result
end

function Processor:checkDynamicLoadRes()
    if _G.isLocalDevelopMode then printx(0, "checkDynamicLoadRes") end
    local haveNetwork = false
    local kDynamicUpdateTimeout = 10

    if __IOS then
        local reachability = Reachability:reachabilityForInternetConnection()
        if reachability:currentReachabilityStatus() ~= 0 then haveNetwork = true end
    elseif __ANDROID then 
        haveNetwork = true 
    elseif __WP8 then 
        haveNetwork = true   
    end

    local kMaxDynamicResource = 1024 * 300
    local kSkipDynamicResource = 1024 * 500
    if (haveNetwork and enableSilentDynamicUpdate and not PrepackageUtil:isPreNoNetWork())
     or _G.isCheckPlayModeActive or (_G.__WIN32 and _G.launchCmds and _G.launchCmds.md5) then
        local function onResourceLoaderCallback( event, data )
            if _G.isLocalDevelopMode then printx(0, "onResourceLoaderCallback") end
            if event == ResCallbackEvent.onPrompt then 
                if _G.isLocalDevelopMode then printx(0, "event == ResCallbackEvent.onPrompt") end
                local needsize = 0
                local userdata = nil
                if data and data.status then 
                    needsize = data.status.needDownloadSize or 0 
                    userdata = data.status.userdata 
                end
                local config = parseDynamicUserData(userdata)
                local force = false
                local review = false
                if config then 
                    force = config["force"] == "1"
                    review = config["review"] == "1"
                end
                if _G.isLocalDevelopMode then printx(0, "config force ==="..config["force"]) end
                if _G.isLocalDevelopMode then printx(0, "require silent dynamic loading"..table.tostring(config)) end
                if _G.isLocalDevelopMode then printx(0, "needsize of dynamic update" .. tostring(needsize)) end
                local canUpdate = false
                if needsize > 0 then
                    if review or _G.isCheckPlayModeActive  or (_G.__WIN32 and _G.launchCmds and _G.launchCmds.md5) then
                        canUpdate = true
                    elseif needsize < kMaxDynamicResource then
                        canUpdate = true
                    elseif needsize < kSkipDynamicResource then
                        if force then canUpdate = true end
                    end
                end
                if _G.isLocalDevelopMode then printx(0, "silent dynamic update permit: " .. tostring(canUpdate)) end
                if canUpdate then
                    data.resultHandler(1)
                else
                    data.resultHandler(0)
                end
            elseif event == ResCallbackEvent.onSuccess then 
                if _G.isLocalDevelopMode then printx(0, "event == ResCallbackEvent.onSuccess") end
                if _G.isLocalDevelopMode then printx(0, "silent load res success") end
                startGame(true)
            elseif event == ResCallbackEvent.onProcess then
                if _G.isLocalDevelopMode then printx(0, "event == ResCallbackEvent.onProcess") end            
                self:updateUIOnDownloading(data.status, data.curSize, data.totalSize)
            elseif event == ResCallbackEvent.onError then 
                if _G.isLocalDevelopMode then printx(0, "event == ResCallbackEvent.onError") end
                startGame(false)
                he_log_warning("silent load res error, errorCode: " .. tostring(data.errorCode) .. ", item: " .. tostring(data.item))
            end
            if _G.isLocalDevelopMode then printx(0, "~onResourceLoaderCallback") end
        end
        if _G.isLocalDevelopMode then printx(0, "ResourceLoader.loadRequiredResWithPrompt(onResourceLoaderCallback)") end
        ResourceLoader.loadRequiredResWithPrompt(onResourceLoaderCallback, true)
        if _G.isLocalDevelopMode then printx(0, "~ResourceLoader.loadRequiredResWithPrompt(onResourceLoaderCallback)") end
    else 
        if _G.isLocalDevelopMode then printx(0, "else startGame()") end
        startGame(false) 
        if _G.isLocalDevelopMode then printx(0, "~else startGame()") end
    end

    if _G.isLocalDevelopMode then printx(0, "~checkDynamicLoadRes") end
    --DO NOT use timeout. otherwise after lua updated, require restart game.
    --setTimeOut(startGame, kDynamicUpdateTimeout) 
end


local function addSpriteFramesWithFile( plistFilename, textureFileName )
    local prefix = string.split(plistFilename, ".")[1]
    local realPlistPath = plistFilename
    local realPngPath = textureFileName
    if __use_small_res then  
        realPlistPath = prefix .. "@2x.plist"
        realPngPath = prefix .. "@2x.png"
    end
    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(realPlistPath, realPngPath)
    return realPngPath, realPlistPath
end

function Processor:addForCuccwo(parent)
    if StartupConfig:getInstance():getPlatformName() == "cuccwo" then 
        self.cuccwoPng = addSpriteFramesWithFile( "materials/cuccwo.plist", "materials/cuccwo.png" )
        local cuccwo = CCSprite:createWithSpriteFrameName("cuccwo10000")
        cuccwo:setPosition(ccp(720,920))
        parent:addChild(cuccwo)
    end
end

local function getSysMemInfo()
    local msg = ""
    if __ANDROID then
        msg = luajava.bindClass("com.happyelements.hellolua.MainActivity"):getMemoryInfo()
    elseif __IOS then 

    end
    return msg
end

local function isNight()
    -- local nowTime = os.time() + (__g_utcDiffSeconds or 0)
    -- local utc8TimeOffset = 57600 -- (24 - 8) * 3600
    -- local oneDaySeconds = 86400 -- 24 * 3600
    -- local dayStartTime = nowTime - ((nowTime - utc8TimeOffset) % oneDaySeconds)
    -- local morningStartTime = dayStartTime + 6 * 3600 
    -- local evenigStartTime = dayStartTime + 18 * 3600
    -- if nowTime >= evenigStartTime or nowTime < morningStartTime then
    --     return true
    -- end
    return false
end

function Processor:getLogo()
    local logoPng = "materials/logo.jpg"
    if isNight() then
        logoPng = "materials/logo_night.jpg"
    end
    if __use_small_res then  
        logoPng = "materials/logo@2x.jpg"
    end

    ------------loading图轮播 START
    local isPlayOpenKey = "logo.isAutoPlay"
    local value = CCUserDefault:sharedUserDefault():getIntegerForKey(isPlayOpenKey, 0)
    local isPlayOpen = value>0
    -- print("Processor:getLogo() isPlayOpen",isPlayOpen,value)
    local TOTAL_INTRO_IMG_COUNT = 9

    if not _G.__currentLogoIndex then
        -- 首次动更后的loading时调用，或者之后的刚启动时动更逻辑调用
        local key = "logo.index"
        local index = CCUserDefault:sharedUserDefault():getIntegerForKey(key, 0)
        if index>TOTAL_INTRO_IMG_COUNT then
            index = 1
        end
        _G.__currentLogoIndex = index

        if index==0 then
            CCUserDefault:sharedUserDefault():setIntegerForKey(key, 1)
            CCUserDefault:sharedUserDefault():flush()

        elseif isPlayOpen then
            logoPng = "materials/intros/logo_".. index .. ".jpg"
            CCUserDefault:sharedUserDefault():setIntegerForKey(key, index+1)
            CCUserDefault:sharedUserDefault():flush()
        end

    elseif isPlayOpen and _G.__currentLogoIndex>0 then
        -- loading 时候，已经经过第一次的检测
        logoPng = "materials/intros/logo_".. _G.__currentLogoIndex  .. ".jpg"
    else
        -- _G.__currentLogoIndex == 0 是首次动更
    end
    if _G.isLocalDevelopMode then printx(0, "Processor:getLogo() __currentLogoIndex",isPlayOpen,_G.__currentLogoIndex) end
    ------------loading图轮播 END

    local texture = CCTextureCache:sharedTextureCache():addImage(CCFileUtils:sharedFileUtils():fullPathForFilename(logoPng))
    local logo = CCSprite:createWithTexture(texture)
    return logoPng, logo
end

function Processor:buildStartupUI()
    if _G.isLocalDevelopMode then printx(0, "buildStartupUI") end
    local scene = CCScene:create()
    local winSize = CCDirector:sharedDirector():getVisibleSize()
    local origin = CCDirector:sharedDirector():getVisibleOrigin()
    local logoPng, logo = self:getLogo()
    -- local logoTexture = CCTextureCache:sharedTextureCache():textureForKey(logoPng)
    -- if not logoTexture then
    --     he_log_error(getSysMemInfo() .. " cache logo not found...")
    -- end
    -- self:addForCuccwo(logo)
    local realvSize = CCDirector:sharedDirector():ori_getVisibleSize()
    local realvOrigin = CCDirector:sharedDirector():ori_getVisibleOrigin()

    local scale = realvSize.height/1280
    if winSize.height / winSize.width > 1.8 then
        scale = realvSize.height/1440
    end
    if winSize.height < realvSize.height then
        local logoSize = logo:getContentSize()
        scale = realvSize.height/logoSize.height
    end
    scale = math.max(scale, realvSize.width/960)

    logo:setScale(scale)
    logo:setPosition(ccp(realvSize.width/2, realvSize.height/2 + realvOrigin.y))
    scene:addChild(logo)


    local offsetY = 0

    local antiAddictionSp
    if __use_small_res then
        antiAddictionSp = CCSprite:create("materials/anti_addiction@2x.png")
    else
        antiAddictionSp = CCSprite:create("materials/anti_addiction.png")
    end

    if antiAddictionSp then
        antiAddictionSp:setAnchorPoint(ccp(0.5, 0))
        antiAddictionSp:setPosition(ccp(winSize.width/2, origin.y))
        local antiSpSize = antiAddictionSp:getContentSize()
        antiAddictionSp:setScale(math.min(math.min(winSize.width/antiSpSize.width, 1), scale))
        scene.antiAddictionSp = antiAddictionSp
        scene:addChild(antiAddictionSp)
        offsetY = antiAddictionSp:getContentSize().height * antiAddictionSp:getScaleY()
    end


    local statusLabel = CCLabelTTF:create("", "Helvetica", 26, CCSizeMake(winSize.width - 100, 120), kCCTextAlignmentCenter, kCCVerticalTextAlignmentTop)
    statusLabel:setColor(ccc3(255, 255, 255))
    statusLabel:setPosition(ccp(winSize.width/2, origin.y + offsetY))
	if not __PURE_LUA__ then
		HeDisplayUtil:enableShadow(statusLabel, CCSizeMake(2, -2), 1, 1, true)
	end
    scene:addChild(statusLabel)
    self.statusLabel = statusLabel

    CCDirector:sharedDirector():runWithScene(scene)
    Processor.scene = scene

    if _G.isLocalDevelopMode then printx(0, "~buildStartupUI") end
end

function Processor:updateUIOnDownloading(status, curSize, totalSize)
    if _G.isLocalDevelopMode then printx(0, "dynamic onProcess") end
    if _G.isLocalDevelopMode then printx(0, "status: " .. status .. " progress: " .. curSize .. " / " .. totalSize) end
    if status and type(status) == "number" then
        -- status define @see also ResLoadStatus.h
        if status == 1 then
            self.statusLabel:setString("正在检查版本信息")
        elseif status >= 2 then
            if curSize and totalSize and type(curSize) == "number" and type(totalSize) == "number" and totalSize > 0 then
                local percentage = 100 * curSize / totalSize
                local formatPercentage = string.format("%d", percentage) .. "%"
                if _G.isLocalDevelopMode then printx(0, formatPercentage) end
                self.statusLabel:setString("少量配置更新中：" .. tostring(formatPercentage))
            end
        end
    end
end

local kTestLevelConfig = "level_test_update"
function Processor:getTestLevelConfig()
    local url = NetworkConfig.dynamicHost .. "testLevelConfig"
    local request = HttpRequest:createGet(url)
    local connection_timeout = 2
    if __WP8 then 
        connection_timeout = 5
    end
    request:setConnectionTimeoutMs(connection_timeout * 1000)
    request:setTimeoutMs(30 * 1000)
   
    os.remove(HeResPathUtils:getUserDataPath() .. "/" .. kTestLevelConfig)
    local function onRequestFinished( response )
        if response.httpCode ~= 200 then 
            if _G.isLocalDevelopMode then printx(0, "get config error") end   
        else
            local config = response.body
            if config then
                if string.sub(config, 1, 1) ~= "[" then
                    config = "["..config.."]" -- 转为数组
                end
                local levelCfg = nil
                pcall(function() levelCfg = table.deserialize(config) end)
                if levelCfg then
                    -- if _G.isLocalDevelopMode then printx(0, "test level config:", table.tostring(levelCfg)) end
                    local filePath = HeResPathUtils:getUserDataPath() .. "/" .. kTestLevelConfig
                    local file, err = io.open(filePath, "wb")
                    if file and not err then
                        local success = file:write(config)
                        if success then
                            file:flush()
                            file:close()
                        end
                    end
                end
            end
        end
        if onFinish then onFinish() end
    end
    HttpClient:getInstance():sendRequest(onRequestFinished, request)
end

function Processor:start(successCallback, failCallback)
    self.successCallback = successCallback
    self.failCallback = failCallback 
    self:buildStartupUI()

    local function checkDynamicLoadRes()
        self:checkDynamicLoadRes()

        if isLocalDevelopMode then
            self:getTestLevelConfig()
        end
    end
    Processor.scene:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.02), CCCallFunc:create(checkDynamicLoadRes)))
end

return Processor
