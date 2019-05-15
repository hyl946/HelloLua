
NotificationEnterPopoutAction = class(HomeScenePopoutAction)

local NotifyTypeId = {
    kFriendUnlockArea = 5,-- 好友帮助解锁区域：打开区域解锁面板
    kFriendSendEnergy = 55,-- 收到好友赠送精力：打开消息中心【求精力】页签
    kNPCSendEnergy = 29,-- NPC送精力：打开消息中心【求精力】页签
    kWantEnergy = 19,-- 被索要精力：打开消息中心【求精力】页签
    kOpenMessageUnlock = 4,-- 打开消息中心【帮解锁】页签
    kFriendDaiDa = 57,-- 收到代打请求
    kPromtion38 = 38,-- 安卓IOS破冰促销
    kPromtion39 = 39,-- 安卓IOS破冰促销
    kPromtion40 = 40,-- 安卓IOS破冰促销
    kPromtion41 = 41,-- 安卓IOS破冰促销
    kRecall43 = 43,-- 召回活动
    kRecall44 = 44,-- 召回活动
    kRecall45 = 45,-- 召回活动
	kFullLevelGift = 73, --满级红包
    kServerToolNotiMin = 20000,--后端工具推送奖励
    kGiftPack1 = 63,
    kGiftPack2 = 64,
}

function NotificationEnterPopoutAction:ctor()
    self.name = "NotificationEnterPopoutAction"
    self:setSource(AutoPopoutSource.kInitEnter, AutoPopoutSource.kEnterForeground)
end

function NotificationEnterPopoutAction:checkCanPop()
    self:onCheckPopResult(false)
end

function NotificationEnterPopoutAction:checkCache(cache)
    local params = cache.para

    local typeId = params["typeId"]
    local push_type = params['type']

    if not typeId or not push_type then
        return self:onCheckCacheResult(false)
    end

    if push_type == 'server' then
        if type(typeId) == "string" then
            local parts = string.split(typeId, '-')
            typeId = tonumber(parts[3])
        end
        params.typeId = typeId
    else
        typeId = tonumber(params["typeId"])
    end

    if not typeId then
        return self:onCheckCacheResult(false)
    end

    local ret = false
    if params["rewards"] and typeId >= NotifyTypeId.kServerToolNotiMin then
        ret = true
    end

    for k,v in pairs(NotifyTypeId) do
        if v == typeId then
            ret = true
            break
        end
    end

    if ret then
        self.params = params
    end
    self:onCheckCacheResult(ret)
end

function NotificationEnterPopoutAction:popout_kFriendUnlockArea(next_action)
    local worldScene = HomeScene:sharedInstance().worldScene
    local function callback()
        -- 好友帮助解锁区域：打开区域解锁面板
        local levelAreaDataArray = MetaModel:sharedInstance():getLevelAreaDataArray()
        for i, v in ipairs(levelAreaDataArray) do
            local id = tonumber(v.id)
            local logic = IsLockedCloudCanWaitToOpenLogic:create(id)
            local isWaitToOpen = logic:start()
            if isWaitToOpen then
                local clouds = HomeScene:sharedInstance().worldScene.lockedClouds
                for k1, v1 in pairs(clouds) do
                    if tonumber(v1.id) == tonumber(id) then
                        AreaUnlockPanelPopoutLogic:checkPopoutPanel(v1, next_action, next_action)
                        break
                    end
                end
                break
            end
        end
    end
    if #HomeScene:sharedInstance().worldScene.lockedClouds > 0 then
        -- clouds都已经初始化
        callback()
    else
        -- 还未初始化
        worldScene:removeEventListener(WorldSceneScrollerEvents.GAME_INIT_ANIME_FIN, callback)
        worldScene:addEventListener(WorldSceneScrollerEvents.GAME_INIT_ANIME_FIN, callback, worldScene)
    end
end

function NotificationEnterPopoutAction:popout(next_action)
    local typeId = tonumber(self.params.typeId) or 0
    if typeId >= NotifyTypeId.kServerToolNotiMin and self.params["rewards"] then
        require "zoo.push.PushUserCallbackManager"
        PushUserCallbackManager:checkSystemPushPopout(self.params, next_action)
    elseif typeId == NotifyTypeId.kFriendUnlockArea then
        self:popout_kFriendUnlockArea(next_action)
    elseif typeId == NotifyTypeId.kFriendSendEnergy
        or typeId == NotifyTypeId.kNPCSendEnergy
        or typeId == NotifyTypeId.kWantEnergy
    then
        HomeScene:sharedInstance():onMessageBtnTapped('energy', next_action)
    elseif typeId == NotifyTypeId.kOpenMessageUnlock then 
        HomeScene:sharedInstance():onMessageBtnTapped('unlock', next_action)
    elseif typeId == NotifyTypeId.kFriendDaiDa then
        HomeScene:sharedInstance():onMessageBtnTapped('askforhelp', next_action)
    elseif typeId == NotifyTypeId.kPromtion38 
        or typeId == NotifyTypeId.kPromtion39 
        or typeId == NotifyTypeId.kPromtion40 
        or typeId == NotifyTypeId.kPromtion41
    then
        local index = MarketManager:sharedInstance():getHappyCoinPageIndex()
        HomeScene:sharedInstance():popoutMarketPanelByIndex(index, nil, 2, next_action)
    elseif typeId == NotifyTypeId.kRecall43 
        or typeId == NotifyTypeId.kRecall44
        or typeId == NotifyTypeId.kRecall45
    then
        local actInfo 
        for k, v in pairs(UserManager:getInstance().actInfos or {}) do
            if v.actId == 81 or v.actId == 3009 then
                actInfo = v
                break
            end
        end
        -- actInfo.popped: 是否在notification处强弹
        if actInfo ~= nil and actInfo.see and not actInfo.popped then
            ActivityUtil:getNetworkActivitys(function(activitys)--getActivitys
                local source = ""
                if actInfo.actId == 3009 then
                    source = "UserCallBackTest/Config.lua"
                elseif  actInfo.actId == 81  then
                    source = "UserCallBack/Config.lua"
                end

                local version = nil
                for k,v in pairs(ActivityUtil:getActivitys() or {}) do
                    if v.source == source then 
                        version = v.version
                        break
                    end
                end
                if version then 
                    local function onSucess( ... )
                    end
                    
                    actInfo.popped = true
                    ActivityData.new({source=source,version=version}):start(false, false, onSucess, next_action, next_action)
                else
                    next_action()
                end
            end, true)
        else
            next_action()
        end
	
	elseif typeId == NotifyTypeId.kFullLevelGift then
        local FLGLogic = require 'zoo.panel.fullLevelGift.FLGLogic'
        FLGLogic:popoutGifts(next_action)
    elseif typeId == NotifyTypeId.kGiftPack1 or typeId == NotifyTypeId.kGiftPack2 then
        MarketManager:sharedInstance():loadConfig()
        local index = MarketManager:sharedInstance():getGiftPackPageIndex()
        if index ~= 0 then
            local panel =  createMarketPanel(index, nil)
            if panel then
                GiftPack:dc('canyu', 'shop_push', {t1 = 1})
                panel:popout()
            end
        end
    else
        next_action()
    end
end