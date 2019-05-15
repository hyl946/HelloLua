local function debug_log(arg)
    if _G.isLocalDevelopMode then printx(0, arg) end
    if not _G.isLocalDevelopMode then return end
    local filename = HeResPathUtils:getUserDataPath() .. '/debug_log'
    local file = io.open(filename,"a+")
    if file then 
        file:write(arg)
        file:write('\n')
        file:close()
    end
end


local function now()
    return os.time() + __g_utcDiffSeconds or 0
end
local _config = nil
local function readConfig()
    local configPath = HeResPathUtils:getUserDataPath() .. '/message_center_helper_'..(UserManager:getInstance().uid or '0')
    if not _config then
        local file = io.open(configPath, "r")
        if file then
            local data = file:read("*a") 
            file:close()
            if data then
                _config = table.deserialize(data)
            end
        end
    end
    if not _config then
        _config = {}
        _config.surpassMessageConfig = {}
        _config.lastReceiveFriendEnergyRequestTime = 0
        _config.lastPassTopLevelId = 0
    end
    return _config
end
local function writeConfig(data)
    local configPath = HeResPathUtils:getUserDataPath() .. '/message_center_helper_'..(UserManager:getInstance().uid or '0')
    _config = data
    local file = io.open(configPath,"w")
    if file then 
        file:write(table.serialize(data or {}))
        file:close()
    end
end



DengchaoPushEnergy = {}
DengchaoPushEnergy.startTime = {year=2016, month=3, day=30, hour=0, min=0, sec=0}
DengchaoPushEnergy.endTime = {year=2016, month=4, day=5, hour=23, min=59, sec=59}

DengchaoPushEnergy.isInActTime = function ()
    return (now() >= os.time(DengchaoPushEnergy.startTime) and now() <= os.time(DengchaoPushEnergy.endTime))
end

DengchaoPushEnergy.isSupport = function ()
    debug_log('DengchaoPushEnergy.isSupport 1')
    if not DengchaoPushEnergy.isInActTime() then 
        debug_log('DengchaoPushEnergy.isSupport 2')
        return false
    end
    if UserManager:getInstance().user:getTopLevelId() < 20 then
        debug_log('DengchaoPushEnergy.isSupport 3')
        return false
    end
    local actInfo = table.find(UserManager:getInstance().actInfos or {},function(v)
            return v.actId == 50
        end)
    if actInfo and actInfo.extra and tonumber(actInfo.extra) == 0 then
        debug_log('DengchaoPushEnergy.isSupport 4')
        return true
    else
        debug_log('DengchaoPushEnergy.isSupport 5')
        return false
    end
end

PushLevelSurpassHttp = class(HttpBase)
function PushLevelSurpassHttp:load(uids, levelId)
    if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
    local context = self
    local loadCallback = function(endpoint, data, err)
        if err then
            he_log_info("PushLevelSurpassHttp error: " .. err)
            context:onLoadingError(err)
        else
            he_log_info("PushLevelSurpassHttp success !")
            context:onLoadingComplete(data)
        end
    end
    self.transponder:call("pushLevelSurpass", {uids = uids, levelId = levelId}, loadCallback, rpc.SendingPriority.kHigh, false)
end

MessageCenterPushEvents = {
    kFriendsSynced = 'friends_synced',
    kReceiveFriendEnergyRequest = 'receive_friend_energy_request',
    kPassMaxNormalLevel = 'pass_max_normal_level',
    kInitPushEnergyRequestTask = 'init_push_energy_request_task',
    kDengchaoEnergy = 'dengchao_energy',
    kGetFirstPassLevelUidComplete = 'get_first_level_uid_complete',
    kCloverAddFriendRequest = "clover_add_friend_request",
}

MessageCenterHelper = class()
local instance 
function MessageCenterHelper:getInstance()
    if not instance then
        instance = MessageCenterHelper.new()
        instance:init()
    end
    return instance
end

function MessageCenterHelper:init()
    if not GlobalEventDispatcher:getInstance():hasEventListenerByName(MessageCenterPushEvents.kFriendsSynced) then
        GlobalEventDispatcher:getInstance():addEventListener(MessageCenterPushEvents.kFriendsSynced, 
            function ()
                 MessageCenterHelper:getInstance():sendFriendSurpassMessage()
            end)
    end
    if not GlobalEventDispatcher:getInstance():hasEventListenerByName(MessageCenterPushEvents.kReceiveFriendEnergyRequest) then
        GlobalEventDispatcher:getInstance():addEventListener(MessageCenterPushEvents.kReceiveFriendEnergyRequest, 
            function ()
                 MessageCenterHelper:getInstance():onReceiveFriendEnergyRequest()
            end)
    end
    if not GlobalEventDispatcher:getInstance():hasEventListenerByName(MessageCenterPushEvents.kPassMaxNormalLevel) then
        GlobalEventDispatcher:getInstance():addEventListener(MessageCenterPushEvents.kPassMaxNormalLevel, 
            function ()
                 MessageCenterHelper:getInstance():sendPassMaxNormalLevel()
            end)
    end
    if not GlobalEventDispatcher:getInstance():hasEventListenerByName(MessageCenterPushEvents.kInitPushEnergyRequestTask) then
        GlobalEventDispatcher:getInstance():addEventListener(MessageCenterPushEvents.kInitPushEnergyRequestTask, 
            function ()
                 MessageCenterHelper:getInstance():initPushEnergyRequestTask()
            end)
    end
    if not GlobalEventDispatcher:getInstance():hasEventListenerByName(MessageCenterPushEvents.kDengchaoEnergy) then
        GlobalEventDispatcher:getInstance():addEventListener(MessageCenterPushEvents.kDengchaoEnergy, 
            function ()
                MessageCenterHelper:getInstance():showDengchaoEnergyAnim()
            end)
    end
    if not GlobalEventDispatcher:getInstance():hasEventListenerByName(MessageCenterPushEvents.kCloverAddFriendRequest) then
        GlobalEventDispatcher:getInstance():addEventListener(MessageCenterPushEvents.kCloverAddFriendRequest, 
            function (evt)
                MessageCenterHelper:getInstance():showCloverAddFriendAnim(evt)
            end)
    end
end

function MessageCenterHelper:showCloverAddFriendAnim(evt)
    local data = evt and evt.data or {}
    if data and type(data.num)=="number" then
        if data.num > 0 then
            HomeScene:sharedInstance():showMessageIconBear()
        else
            HomeScene:sharedInstance():hideMessageIconBear()
        end
    end
end

function MessageCenterHelper:showDengchaoEnergyAnim()
    
    local today = os.date('*t', now())
    local key = string.format('dengchao.energy.play.anim.%d.%d.%d', today.year, today.month, today.day)
    if CCUserDefault:sharedUserDefault():getBoolForKey(key, false) then
        HomeScene:sharedInstance():showDengchaoEnerygy()
    else
        CCUserDefault:sharedUserDefault():setBoolForKey(key, true)
        HomeScene:sharedInstance():playDengchaoEnergyAnim()
    end
    DcUtil:UserTrack({category = 'message', sub_category = 'message_center_see_chenkun'})
end

function MessageCenterHelper:sendFriendSurpassMessage()
    local friends = FriendManager:getInstance().friends
    local needNotifyList = {}
    local config = readConfig()
    local surpassMessageConfig = config.surpassMessageConfig
    local myLevel = UserManager:getInstance().user:getTopLevelId()
    if myLevel >= 60 then
        for k, v in pairs(friends) do
            local uid = tostring(v.uid)
            local topLevelId = tostring(v:getTopLevelId())
            if v:getTopLevelId() == myLevel + 1 then
                if surpassMessageConfig[uid] and surpassMessageConfig[uid][topLevelId] and surpassMessageConfig[uid][topLevelId].hasSent == true then

                else
                    table.insert(needNotifyList, uid)
                    surpassMessageConfig[uid] = {[topLevelId] = {hasSent = true}}
                end
            end
        end
        writeConfig(config)
    end

    if __WIN32 then
        for k, v in pairs(friends) do
            table.insert(needNotifyList, v.uid)
        end
    end
    -- debug_log('needNotifyList')
    -- debug_log(table.tostring(needNotifyList))

    local function opSuccess()
        debug_log('PushLevelSurpassHttp success')
        local function onGetRequestNumSuccess(evt)
            UserManager:getInstance().requestNum = evt.data.requestNum
            GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(kGlobalEvents.kMessageCenterUpdate))

			HomeScene:sharedInstance():processAskForHelpData(evt)
        end
        local http = GetRequestNumHttp.new(false)
        http:ad(Events.kComplete, onGetRequestNumSuccess)
        http:load()
    end
    local function opFail()
        debug_log('PushLevelSurpassHttp fail')
    end
    if #needNotifyList > 0 then
        local http = PushLevelSurpassHttp.new()
        http:ad(Events.kComplete, opSuccess)
        http:ad(Events.kError, opFail)
        http:load(needNotifyList, myLevel + 1)
    end
end

function MessageCenterHelper:onReceiveFriendEnergyRequest()
    local config = readConfig()
    config.lastReceiveFriendEnergyRequestTime = now()
    writeConfig(config)
end

function MessageCenterHelper:initDengchaoEnergyRequestTask()
    debug_log('initDengchaoEnergyRequestTask 9')
    local myUid = UserManager:getInstance().user.uid or "12345"
    local config = readConfig()
    if tostring(config.lastNotificDengchaoationUid) ~= myUid then
        MessageCenterHelper:cancelNotification(LocalNotificationType.kDengchaoEnergy)
    end

    local today = os.date('*t', now())
    local tomorrow = os.date('*t', now() + 24 * 3600)
    local todayTime = {year = today.year, month = today.month, day = today.day, hour = 11, min = 30, sec = 0}
    local tomorrowTime = {year = tomorrow.year, month = tomorrow.month, day = tomorrow.day, hour = 11, min = 30, sec = 0}

    local notifiTime
    if now() < os.time(todayTime) then
        debug_log('initDengchaoEnergyRequestTask 1')
        notifiTime = os.time(todayTime) + math.random(3600)
    else
        debug_log('initDengchaoEnergyRequestTask 2')
        notifiTime = os.time(tomorrowTime) + math.random(3600)
    end
    MessageCenterHelper:addNotification(notifiTime, LocalNotificationType.kDengchaoEnergy)
    config.lastDengchaoNotificationUid = myUid
    writeConfig(config)

    local function start()
        local key = string.format('dengchao.energy.%d.%d.%d', today.year, today.month, today.day)
        local function readFlag()
            return CCUserDefault:sharedUserDefault():getBoolForKey(key, false)
        end
        local function writeFlag(value)
            CCUserDefault:sharedUserDefault():setBoolForKey(key, value)
        end
        local function opSuccess(event)
            debug_log('OpNotifyHttp success dengchao')
            writeFlag(true)
            if tostring(event.data.extra) ~= '1' then
                return
            end

            local function onGetRequestNumSuccess(evt)
                UserManager:getInstance().requestNum = evt.data.requestNum
                GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(kGlobalEvents.kMessageCenterUpdate))
            end
            local http = GetRequestNumHttp.new(false)
            http:ad(Events.kComplete, onGetRequestNumSuccess)
            http:load()

            FreegiftManager:sharedInstance():update(false, nil)
        end
        local function opFail()
            debug_log('OpNotifyHttp fail dengchao')
        end
        if not readFlag() or __WIN32 then
            debug_log('initDengchaoEnergyRequestTask 4')
            local http = OpNotifyHttp.new()
            http:ad(Events.kComplete, opSuccess)
            http:ad(Events.kError, opFail)
            http:load(OpNotifyType.kDengchaoEnergy)
        end
    end

    if now() > os.time(todayTime) then
        debug_log('initDengchaoEnergyRequestTask 3')
        start()
    end
    debug_log('initDengchaoEnergyRequestTask 8')
end

function MessageCenterHelper:initPushEnergyRequestTask()
    if DengchaoPushEnergy.isSupport() then
        MessageCenterHelper:initDengchaoEnergyRequestTask()
        return 
    end
    local function meetConditions()
        if __WIN32 then return true end
        if FriendManager:getInstance():getFriendCount() <= 10
        and UserManager:getInstance().user:getTopLevelId() >= 15 then
            return true
        end
        if FriendManager:getInstance():getFriendCount() > 10
        and now() - readConfig().lastReceiveFriendEnergyRequestTime > 3 * 24 * 3600 then
            return true
        end
        return false
    end

    if not meetConditions() then
        return 
    end

    local today = os.date('*t', now())
    local tomorrow = os.date('*t', now() + 24 * 3600)
    local todayTime = {year = today.year, month = today.month, day = today.day, hour = 12, min = 0, sec = 0}

    local function start()
        local key = string.format('push.energy.%d.%d.%d', today.year, today.month, today.day)
        if Localhost:timeInSec() < os.time(todayTime) then
            key = key..'.morning'
        else
            key = key..'.afternoon'
        end
        local function readFlag()
            return CCUserDefault:sharedUserDefault():getBoolForKey(key, false)
        end
        local function writeFlag(value)
            CCUserDefault:sharedUserDefault():setBoolForKey(key, value)
        end
        local function opSuccess()
            writeFlag(true)
            local function onGetRequestNumSuccess(evt)
                UserManager:getInstance().requestNum = evt.data.requestNum
                UserManager:getInstance():changeRequestNum()

                GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(kGlobalEvents.kMessageCenterUpdate))
            end
            local http = GetRequestNumHttp.new(false)
            http:ad(Events.kComplete, onGetRequestNumSuccess)
            http:load()
        end
        local function opFail()
        end
        if not readFlag() or __WIN32 then
            -- RemoteDebug:uploadLog(key)
            local http = OpNotifyHttp.new()
            http:ad(Events.kComplete, opSuccess)
            http:ad(Events.kError, opFail)
            http:load(OpNotifyType.kRequestPushEnergy)
        end
    end
    start()
end

function MessageCenterHelper:addNotification(notifiTime, notifiType)
    MessageCenterHelper:cancelNotification(notifiType)
    LocalNotificationManager:getInstance():addNotifyFromConfig(notifiType, notifiTime)
end

function MessageCenterHelper:cancelNotification(notifiType)
    local vo = LocalNotificationManager:getInstance():getNotiByType(notifiType)
    for k, v in pairs(vo) do
        LocalNotificationManager:getInstance():deleteNotify(v)
        LocalNotificationManager:getInstance():flushToStorage()
    end
end

function MessageCenterHelper:sendPassMaxNormalLevel()
    local myLevel = UserManager:getInstance().user:getTopLevelId()
    if myLevel < 60 then return end

    local config = readConfig()

    if config.lastPassTopLevelId and config.lastPassTopLevelId >= myLevel then
        return
    end
    config.lastPassTopLevelId = myLevel

    writeConfig(config)

    local function opSuccess()
        debug_log('OpNotifyHttp success 最高关卡')
    end
    local function opFail()
        debug_log('OpNotifyHttp fail 最高关卡')
    end
    -- local http = OpNotifyHttp.new()
    local http = OpNotifyOffineHttp.new()
    http:ad(Events.kComplete, opSuccess)
    http:ad(Events.kError, opFail)
    http:load(OpNotifyType.kPassMaxNormalLevel, tostring(MetaManager:getInstance():getMaxNormalLevelByLevelArea()))
    SyncManager.getInstance():sync(nil, nil, kRequireNetworkAlertAnimation.kNone)

end


MessageCenterHelper:getInstance()
