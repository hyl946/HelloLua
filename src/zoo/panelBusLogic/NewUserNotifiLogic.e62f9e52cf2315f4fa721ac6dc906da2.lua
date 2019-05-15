require 'zoo.data.LocalNotificationManager'

NewUserNotifiLogic = class()

local typeId = LocalNotificationType.kNewUser
local filename = 'new_user_notifi.ds'

local function cancelAll()
    local noties = LocalNotificationManager:getInstance():getNotiByType(typeId)
    if noties and #noties then
        for i=1, #noties do
            local vo = noties[i]
            LocalNotificationManager:getInstance():deleteNotify(vo)
            LocalNotificationManager:getInstance():flushToStorage()
        end
    end
end
local function setSingle(ts, index)
    -- print(ts)
    -- LocalNotificationManager:getInstance():addNotifyFromConfig(typeId, ts)
    LocalNotificationManager:getInstance():addNotify(typeId, ts, 
        localize('new.user.notifi.body.'..tostring(index)), 
        localize('new.user.notifi.action'), 
        index)
end

function NewUserNotifiLogic:refreshNotifications(config)
    cancelAll()

    local day = 3600 * 24
    local end_ts = config.time + 7 * day
    local ts = 0
    local now = Localhost:timeInSec()
    for i=1, 7 do
        ts = config.time + day * i
        -- 从明天起推
        if Localhost:getDayStartTimeByTS(now) < Localhost:getDayStartTimeByTS(ts) then
            setSingle(ts + 30 * 60, i) -- 登陆时间之后的半小时
        end
    end
end

function NewUserNotifiLogic:readFile()
    return Localhost:readFromStorage(filename)
end

function NewUserNotifiLogic:onLogin()
    local config = self:readFile()
    if config then
        self:refreshNotifications(table.deserialize(config))
    end
end

function NewUserNotifiLogic:onCreateNew()
    local config = self:readFile()
    if not config then 
        config = {time = Localhost:timeInSec()}
        Localhost:writeToStorage(table.serialize(config), filename)
    end
end