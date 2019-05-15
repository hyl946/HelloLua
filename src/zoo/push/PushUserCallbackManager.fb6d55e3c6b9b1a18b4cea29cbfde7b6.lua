
PushUserCallbackManager = {}

local function dc(category,sub_category,params)
    params = params or {}
    if type(params) ~="table" then
        local t = {t0 = params}
        params = t
    else
        for k,v in pairs(params) do
            if type(v) =="table" then
                for kk,vv in pairs(v) do
                    params[tostring(k) .. "_" .. tostring(kk)]=vv
                end
                params[k]=nil
            end
        end
    end

    params.category = category
    params.sub_category = sub_category

    if params.category == "newUpdate" then
        DcUtil:UserTrackWithType(params, kExpire90Days)
    else
        DcUtil:UserTrack(params)
    end

end

--  4-6天回流奖励点击领取
function PushUserCallbackManager:checkUserCallbackRewards(next_action)
    local rewardData = UserManager:getInstance().recallNotificationRewards
    print("PushUserCallbackManager:checkUser()",rewardData)
    if not rewardData then
        return
    end

    local rewards = rewardData.rewards
    local viralId = rewardData.viralId

    local function callback()
        local function onSuccess(evt)
            PushUserCallbackManager:_addRewards(rewards)
            PushUserCallbackManager:_enterTopLevel()
            local _ = next_action and next_action()
        end
        local function onFail(evt)
            return next_action and next_action()
        end
        local function onCancel(evt)
            return next_action and next_action()
        end

        local http = OpNotifyHttp.new()
        http:ad(Events.kComplete, onSuccess)
        http:ad(Events.kError, onFail)
        http:ad(Events.kCancel, onCancel) 

        http:load( 67 , viralId )

        dc("LapsedPlayerRecall","notif_gift_collect")
    end
    
    local Panel = require "zoo.push.PushUserCallbackPanel"
    local panel = Panel:create(rewards,callback,true)
    
    UserManager:getInstance().recallNotificationRewards=nil
end

function PushUserCallbackManager:_enterTopLevel()
    -- local levelId = UserManager.getInstance().user:getTopLevelId()
    -- local startGamePanel = StartGamePanel:create(levelId, GameLevelType.kMainLevel)
    -- startGamePanel:popout(false)    

    local levelId = UserManager:getInstance().user:getTopLevelId()
    local startLevelLogic = StartLevelLogic:create(nil, levelId, GameLevelType.kMainLevel, {}, false, {}, 1)
    startLevelLogic:start(true)
end

function PushUserCallbackManager:_addRewards(rewards)
    UserService:getInstance():addRewards(rewards, true)
    UserManager:getInstance():addRewards(rewards)
    GainAndConsumeMgr.getInstance():gainMultiItems(DcFeatureType.kRecall, rewards, DcSourceType.kRecallPush)

    Localhost:getInstance():flushCurrentUserData()
end

--带礼物的Notification进入游戏时加奖励
function PushUserCallbackManager:checkSystemPush(params)
    -- happyanimal3://systemPush/HuaweiPush?id=43359-1533885149044-20000&textId=0&rewards=14:1,14:2
    --print("PushUserCallbackManager:checkSystemPush",table.tostring(params))

    --RemoteDebug:uploadLogWithTag('PushUserCallbackManager:checkSystemPush()',table.tostring(params))

    if not params or not params["typeId"] then
        return
    end

    if not params["rewards"] or params["rewards"] == "" then
        return
    end

    local viralId = params["typeId"]
    local rewards = {}
    
    local list = string.split(params["rewards"],",")
    for i,v in ipairs(list) do
        local info = string.split(v,":")
        table.insert(rewards,{itemId=tonumber(info[1]),num=tonumber(info[2])})
    end

    PushUserCallbackManager:_addRewards(rewards)

    local http = OpNotifyOffline.new()
    http:load( 22 , viralId )

    dc("Notification","gift_collect")
end

--带礼物的Notification点击领取
function PushUserCallbackManager:checkSystemPushPopout(params, close_cb)
    --print("PushUserCallbackManager:checkSystemPushPopout(params, close_cb)",table.tostring(params))

    if not params or not params["typeId"] then
        return
    end

    if not params["rewards"] or params["rewards"] == "" then
        return
    end

    local viralId = params["typeId"]
    local rewards = {}
    
    local list = string.split(params["rewards"],",")
    for i,v in ipairs(list) do
        local info = string.split(v,":")
        table.insert(rewards,{itemId=tonumber(info[1]),num=tonumber(info[2])})
    end

    local function callback()
        return close_cb and close_cb()
    end

    local Panel = require "zoo.push.PushUserCallbackPanel"
    Panel:create(rewards,callback,false)
end
