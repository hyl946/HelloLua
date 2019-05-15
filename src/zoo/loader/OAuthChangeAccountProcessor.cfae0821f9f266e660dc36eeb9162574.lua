
local Processor = class(EventDispatcher)

Processor.Events = {
    kBeforeChangeAccount = "beforeChangeAccount"
}

function Processor:changeUserAccount( lastUserData )
    local validData = false
    if lastUserData and lastUserData.uid and lastUserData.udid then
        if MetaInfo:getInstance():getUdid() ~= lastUserData.udid then 
            validData = true 
        end
    end

    if validData then
        _G.kDeviceID = lastUserData.udid
        UdidUtil:saveUdid(lastUserData.udid)

        local loginInfo = { uid = lastUserData.uid, sk = lastUserData.udid, p = kDefaultSocialPlatform }
        self:dispatchEvent(Event.new(Events.kComplete, loginInfo, self))
    else 
        self:dispatchEvent(Event.new(Events.kComplete, nil, self))
    end
end

function Processor:onCanceled()
    self.isCanceled = true
end

function Processor:loginNewOAuthAccount(context)
    local authorType = SnsProxy:getAuthorizeType()

    local lastData = context:logoutWithChangeAccount()
    local function onAccountChange(status, loginResult)
        if self.isCanceled then
            return
        end
        context.requireButtons = false
        if status == SnsCallbackEvent.onSuccess and loginResult then
            _G.sns_token = loginResult
            _G.sns_token.authorType = authorType
            self:changeUserAccount(lastData)
        else 
            self:dispatchEvent(Event.new(Events.kError, nil, self))
        end
    end

    self:dispatchEvent(Event.new(Processor.Events.kBeforeChangeAccount,nil,self))

    _G.kPlayAsGuest = false
    SnsProxy:changeAccount(onAccountChange)
    -- if PlatformConfig:isPlatform(PlatformNameEnum.kMI) then
    --     require "zoo.panel.MiLoginSelectPanel"
    --     local function onSelect(authorType)
    --         if authorType then 
    --             SnsProxy:setAuthorizeType(authorType)
    --             SnsProxy:changeAccount(onAccountChange)
    --         else
    --             self:dispatchEvent(Event.new(Events.kCancel, nil, self))
    --         end
    --     end

    --     local function onCancel()
    --         self:dispatchEvent(Event.new(Events.kCancel, nil, self))
    --     end

    --     local selectPanel = MiLoginSelectPanel:create(onSelect, onCancel)
    --     selectPanel:popout()
    -- else
    --     SnsProxy:changeAccount(onAccountChange)
    -- end
end

function Processor:start(context)
    local logoutCallback = {
        onSuccess = function(result)
            if _G.isLocalDevelopMode then printx(0, "logout onSuccess") end
            self:loginNewOAuthAccount(context)
            self:dispatchEvent(Event.new(Events.kStart, nil, self))
        end,

        onError = function(errCode, msg) 
            if _G.isLocalDevelopMode then printx(0, "logout onError") end
            self:dispatchEvent(Event.new(Events.kError, nil, self))
        end,

        onCancel = function()
            if _G.isLocalDevelopMode then printx(0, "logout onCancel") end
            self:dispatchEvent(Event.new(Events.kCancel, nil, self))
        end
    }
    SnsProxy:logout(logoutCallback) 
end

return Processor
