
local Processor = class(EventDispatcher)

function Processor:start(data)
    local userId = data.uid

    if __IOS then
        GspEnvironment:getInstance():setGameUserId(tostring(userId))
    elseif __ANDROID then 
        GspProxy:setGameUserId(tostring(userId)) 
    end

    HeGameDefault:setUserId(tostring(userId))
    -- DcUtil:dailyUser()

    local sessionKey = _G.kDeviceID
    local platform = data.p

    local function onLoginFinish( evt )
        evt.target:removeAllEventListeners()
        self:dispatchEvent(Event.new(Events.kComplete, nil, self))
    end 

    local function onLoginFail(evt)
        evt.target:removeAllEventListeners()
        self:dispatchEvent(Event.new(Events.kError, nil, self))
    end

    if _G.isLocalDevelopMode then printx(0, userId, sessionKey) end

    local logic = LoginLogic.new()
    logic:addEventListener(Events.kComplete, onLoginFinish)
    logic:addEventListener(Events.kError, onLoginFail) -- 本地账号同步失败，继续登录流程，可能导致本地的进度丢失
    logic:execute(userId, sessionKey, platform, 15)
end

return Processor