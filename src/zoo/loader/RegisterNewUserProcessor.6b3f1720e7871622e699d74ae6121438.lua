
local Processor = class(EventDispatcher)

function Processor:start()
    if __IOS and not ReachabilityUtil.getInstance():isNetworkAvailable() then
        if _G.isLocalDevelopMode then printx(0, "Network disabled on iOS? just return error for register, need to create a new user or use local data.") end
        self:dispatchEvent(Event.new(Events.kError, nil, self))
        return
    end 

    local function onRegisterError( evt )
        if evt then evt.target:removeAllEventListeners() end
        if _G.isLocalDevelopMode then printx(0, "register error") end
        self:dispatchEvent(Event.new(Events.kError, nil, self))
    end

    local function onRegisterFinish( evt )
        evt.target:removeAllEventListeners()
        if kTransformedUserID ~= nil and kDeviceID ~= nil then
            local userId = kTransformedUserID
            local sessionKey = kDeviceID
            local platform = kDefaultSocialPlatform
            local data = evt.data
            local isNew = nil
            if data then isNew = data.isNew end

            if _G.isLocalDevelopMode then printx(0, "register finished", userId, sessionKey, platform, table.tostring(data)) end

            local loginInfo = { uid = userId, sk = sessionKey, p = platform, isNew = isNew }
            self:dispatchEvent(Event.new(Events.kComplete, loginInfo, self))
        else 
            onRegisterError() 
        end
    end 

    if _G.isLocalDevelopMode then printx(0, "register new user") end

    local http = RegisterHTTP.new()
    http:addEventListener(Events.kComplete, onRegisterFinish)
    http:addEventListener(Events.kError, onRegisterError)
    http:load()
end

return Processor
