local PassDayTimer = {}

local dayPassCallbackList = {}
local dayPassTimer = nil
local nextDayTime = nil

function PassDayTimer:registerDayPassCallback( callback )
    dayPassCallbackList[callback] = true
end

function PassDayTimer:unregisterDayPassCallback( callback )
    dayPassCallbackList[callback] = nil
end

function PassDayTimer:unregisterAllDayPassCallback( ... )
    dayPassCallbackList = {}
end

function PassDayTimer:startDayPassTimer( ... )
    if not nextDayTime then
        nextDayTime = Localhost:getDayStartTimeByTS(Localhost:timeInSec()) + 3600 * 24
    end
    if not dayPassTimer then
        local one_second_timer = OneSecondTimer:create()
        dayPassTimer = one_second_timer
        dayPassTimer:setOneSecondCallback(function ( ... )
            local now = Localhost:timeInSec()
            if now >= nextDayTime then
                for k, v in pairs(dayPassCallbackList) do
                    if type(k) == "function" then k() end
                end
                nextDayTime = nextDayTime + 24 * 3600
            end
        end)
        dayPassTimer:start()
    end
end

function PassDayTimer:stopDayPassTimer( ... )
    if dayPassTimer then
        dayPassTimer:stop()
        dayPassTimer = nil
        nextDayTime = nil
    end
end

_G.globalPassDayTimer = PassDayTimer