require "zoo.panel.loginAlert.LoginAlertModel"
require "zoo.panel.NickNamePanel"
local function isProfileCustomized()
    return UserManager:getInstance().profile.customProfile == true
end

local Processor = class(EventDispatcher)

local function updateUserName( userInput, isUserModify)
    local profile = UserManager:getInstance().profile

    local authorizeType = SnsProxy:getAuthorizeType()
    local needConfirm = (authorizeType == PlatformAuthEnum.kWechat and LoginAlertModel:getInstance().snsBindToExistAccount)
    -- RemoteDebug:uploadLogWithTag("updateUserName", authorizeType, profile.name, profile.headUrl, LoginAlertModel:getInstance().snsBindToExistAccount)
    local snsHeadUrl = profile.headUrl
    if SnsProxy.profile.headUrl and not needConfirm then 
        snsHeadUrl = SnsProxy.profile.headUrl
    end
    if not isProfileCustomized() and not needConfirm then -- 如果有自定义头像或昵称，就不再覆盖
        if SnsProxy.profile.headUrl then 
            profile.headUrl = SnsProxy.profile.headUrl
        end
    end
    if not isProfileCustomized() and not needConfirm then
        if SnsProxy.profile.nick then 
            profile.name = SnsProxy.profile.nick
        end
    end

    if kUserLogin and profile then                          
        local http = UpdateProfileHttp.new()
        if not needConfirm then
            profile:setDisplayName(userInput)
        end

        local snsPlatform = nil
        local snsName = nil
        if _G.sns_token then
            snsPlatform = PlatformConfig:getPlatformAuthName(authorizeType)
            if authorizeType ~= PlatformAuthEnum.kPhone then
                local nickname = SnsProxy.profile.nick or ""
                snsName = nickname
                -- snsName = profile:getDisplayName()
            else
                snsName = Localhost:getLastLoginPhoneNumber()
            end
            profile:setSnsInfo(authorizeType,snsName,snsHeadUrl,profile:getDisplayName(),profile.headUrl)
        end

        http:load(profile.name, snsHeadUrl,snsPlatform,HeDisplayUtil:urlEncode(snsName), isUserModify)
    end

end

local function updateUserDisplayNameBySNS()
    local nickname = SnsProxy.profile.nick or "";
    if nickname and nickname ~= "" then
        if isProfileCustomized() then -- 如果有自定义头像或昵称，就不再覆盖
            nickname = UserManager:getInstance().profile:getDisplayName()
        end
        updateUserName(nickname, false)
        CCUserDefault:sharedUserDefault():setStringForKey(getDeviceNameUserInput(), nickname)
        CCUserDefault:sharedUserDefault():flush()
    end
end

local isShow = false
local requestUserNameTimes = 0
local function requestUserDisplayName()
    requestUserNameTimes = requestUserNameTimes + 1
    local profile = UserManager.getInstance().profile
    if __IOS then
        local nickname = SnsProxy.profile.nick or "";
        if _G.isLocalDevelopMode then printx(0, "requestUserDisplayName nickname:" .. nickname) end
        if nickname and nickname ~= "" then
            updateUserDisplayNameBySNS()
        else
            if profile and not profile:haveName() then
                if kUserLogin then updateUserName("User"..tostring(profile.uid), false) end
            end
        end
    end

    if __ANDROID or __WIN32 then
        local nickname = SnsProxy.profile.nick or "";
        if nickname and nickname ~= "" then
            printx( 3 , ' 55555555555')
            updateUserDisplayNameBySNS()
        elseif not isShow then
            printx( 3 , ' 6666666666')
            if kUserLogin then 
                isShow = true
                if profile and not (profile:haveName() or PrepackageUtil:isPreNoNetWork()) then
                    local userName = Localization:getInstance():getText("game.setting.panel.use.device.name.default")
                    updateUserName(userName, false)
                end
            end
        end
    end
    
    if __WP8 then
        local profile = UserManager.getInstance().profile
        if profile and profile:haveName() then
            return
        end
        local uname = CCUserDefault:sharedUserDefault():getStringForKey(getDeviceNameUserInput())
        if uname and uname ~= "" then
            return
        end
        local function inputCallback(result, userInput)
            if result then
                local isUserModify = true
                if not userInput or userInput == "" then
                    userInput = Localization:getInstance():getText("game.setting.panel.use.device.name.default")
                    if not _G.kUserSNSLogin then -- 游客不算更改昵称
                        isUserModify = false
                    end
                end

                if userInput and userInput~="" then
                    updateUserName(userInput, isUserModify)
                    CCUserDefault:sharedUserDefault():setStringForKey(getDeviceNameUserInput(), userInput)
                    CCUserDefault:sharedUserDefault():flush()                           
                -- else
                --  if requestUserNameTimes < 3 then requestUserDisplayName() end
                end
            else
                if _G.isLocalDevelopMode then printx(0, "Info - Keypad Callback: user input cancel") end
                if kUserLogin and UserManager:getInstance():isPlayerRegistered() and UserManager:getInstance().uid then
                    updateUserName("User"..tostring(UserManager:getInstance().uid), false)
                end
            end
        end
        Wp8Utils:OpenEditBox(Localization:getInstance():getText("game.setting.panel.use.device.name.notice"), "", -1, 0, -1, inputCallback) 
    end
    
end

function Processor:start()
    if _G.kUserSNSLogin and SnsProxy:getAuthorizeType() ~= PlatformAuthEnum.kPhone then
        updateUserDisplayNameBySNS()
    else
        requestUserDisplayName()
    end
end

return Processor
