require "zoo.panel.OutGameTipPanel"
require "zoo.panel.QQLoginSuccessPanel"
require "zoo.net.QzoneSyncLogic" 

local Processor = class(EventDispatcher)
Processor.events = {
    kSyncSuccess = "syncSuccess",
    kSyncCancel = "syncCancel",
    kSyncCancelLogout = "syncCancelLogout",
}

function Processor:start(openId, accessToken, authorType, hasReward)
    local function onSyncFinish()
        if _G.isLocalDevelopMode then printx(0, "sync qzone done. get user profile") end
        _G.kUserSNSLogin = true -- 平台账号登录

        if hasReward and authorType == PlatformAuthEnum.kQQ then
            if BindQQBonus:loginRewardEnabled() then
                BindQQBonus:setShouldGetReward(true)
            end
        end

        if hasReward and authorType == PlatformAuthEnum.k360 then
            if BindQihooBonus:loginRewardEnabled() then
                BindQihooBonus:setShouldGetReward(true)
            end
        end

        Localhost.getInstance():setCurrentUserOpenId(openId,nil,authorType)

        local function onSuccessCallback(result)
            self:dispatchEvent(Event.new(self.events.kSyncSuccess, nil, self))
        end

        local function onErrorCallback(err,msg)
            self:dispatchEvent(Event.new(self.events.kSyncSuccess, nil, self))
        end

        local function onCancelCallback()
            self:dispatchEvent(Event.new(self.events.kSyncSuccess, nil, self))
        end

        if SnsProxy:getAuthorizeType() == PlatformAuthEnum.kPhone then 
            onSuccessCallback()
        else
            SnsProxy:getUserProfile(onSuccessCallback,onErrorCallback,onCancelCallback)
        end
        -- if PlatformConfig:isPlatform(PlatformNameEnum.kWDJ) 
        --     or PlatformConfig:isPlatform(PlatformNameEnum.k360) 
        --     or PlatformConfig:isPlatform(PlatformNameEnum.kMI) 
        --     or __IOS_FB 
        --     or __IOS_QQ 
        --     then
        --     SnsProxy:syncSnsFriend()
        -- end
    end

    local function onSyncCancel()
        local logoutCallback = {
            onSuccess = function(result)
                self:dispatchEvent(Event.new(self.events.kSyncCancelLogout, nil, self))
            end,
            onError = function(errCode, msg) 
                self:dispatchEvent(Event.new(self.events.kSyncCancel, nil, self))
            end,
            onCancel = function()
                self:dispatchEvent(Event.new(self.events.kSyncCancel, nil, self))
            end
        }

        if SnsProxy:getAuthorizeType() == PlatformAuthEnum.kPhone then
            self:dispatchEvent(Event.new(self.events.kSyncCancelLogout, nil, self))
        else
            SnsProxy:logout(logoutCallback)
        end 
    end

    local function onSyncError()
        local savedConfig = Localhost.getInstance():getLastLoginUserConfig()
        if savedConfig then
            local lastUser = Localhost.getInstance():readUserDataByUserID(savedConfig.uid)
            if openId and lastUser and openId == lastUser.openId then -- 本地已登录过的账号
                -- 同步数据异常
                local msg = Localization:getInstance():getText("loading.tips.register.failure."..kLoginErrorType.syncData)
                CommonTip:showTip(msg, "negative")

                onSyncFinish()
                return
            end
        end
        local msg = Localization:getInstance():getText("loading.tips.register.failure."..kLoginErrorType.changeUser)
        CommonTip:showTip(msg, "negative")
        onSyncCancel()
    end

    local snsPlatform = PlatformConfig:getPlatformAuthName(authorType)

    local snsName = nil
    if authorType == PlatformAuthEnum.kPhone then
        snsName = Localhost:getLastLoginPhoneNumber()
    end

    if __ANDROID and NetworkConfig.mockQzoneSk ~= nil then
        local function onUserInputSK( input )
            NetworkConfig.mockQzoneSk = input
            local logic = QzoneSyncLogic.new(openId, accessToken,snsPlatform)
            logic:sync(onSyncFinish, onSyncCancel, onSyncError)
        end
        AlertDialogImpl:input( "Test SK", "Session key:", NetworkConfig.mockQzoneSk, "OK", "Cancel", onUserInputSK, nil)
    else
        local logic = QzoneSyncLogic.new(openId, accessToken,snsPlatform,snsName)
        logic:sync(onSyncFinish, onSyncCancel, onSyncError)
    end
end

return Processor
