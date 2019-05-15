
local Processor = class(EventDispatcher)

function Processor:start()
    local savedConfig = Localhost.getInstance():getLastLoginUserConfig()
    local userData = Localhost:getInstance():readUserDataByUserID(savedConfig.uid)
    local token = {openId = userData.openId }
    if userData.accessToken then --合并QQ没走完sync
        token.accessToken = userData.accessToken
    end 
    token.authorType = userData.authorType
    _G.sns_token = token

    -- 360平台sns cache登录后, 360的好友邀请功能有bug, cache过后登录需要重新sns登录, 离线时SnsLogin走360的离线登录逻辑
    if (PlatformConfig:isPlatform(PlatformNameEnum.k360) and SnsProxy:getAuthorizeType() == PlatformAuthEnum.k360) or 
        (PlatformConfig:isQQPlatform() and SnsProxy:getAuthorizeType() == PlatformAuthEnum.kQQ) then
        PaymentNetworkCheck.getInstance():check(function ()
        	self:dispatchEvent(Event.new(Events.kError, nil, self))
        end, function ()
        	self:dispatchEvent(Event.new(Events.kComplete, nil, self))
        end)
    else 
        self:dispatchEvent(Event.new(Events.kComplete, nil, self))
    end
end

return Processor
