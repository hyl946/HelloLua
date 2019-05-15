local Timer = class()

function Timer:create()
    local instance = Timer.new()
    instance:init()
    return instance
end

function Timer:init()
    self.eventCallbacks = {}
end

local timerCbCounter = 0
function Timer:addTimeEventCallback(timestamp, func)
    timerCbCounter = timerCbCounter + 1
    self.eventCallbacks[timerCbCounter] = {ts = timestamp, func = func}
end


function Timer:dispose()

    if self.timerId then
        Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.timerId)
        self.timerId = nil
    end
    self.eventCallbacks = nil
end

function Timer:startTimer()
    if not self.timerId then
        local function onTick()
            local ts = Localhost:timeInSec()
            for k, v in pairs(self.eventCallbacks) do
                if ts == v.ts then
                    if v.func then
                        v.func()
                    end
                    -- print('exe')
                    self.eventCallbacks[k] = nil
                end
                -- print('onTick ', self.name, math.abs(ts - v.ts))
            end
        end
        self.timerId = Director:sharedDirector():getScheduler():scheduleScriptFunc(onTick, 1, false)
    end
end

function Timer:stop()
    if self.timerId then
        Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.timerId)
        self.timerId = nil
    end
    self.eventCallbacks = {}
end

function Timer:started()
    return self.timerId ~= nil
end

return Timer