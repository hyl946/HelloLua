
OpenActivityPopoutAction = class(HomeScenePopoutAction)

function OpenActivityPopoutAction:ctor()
    self.name = "OpenActivityPopoutAction"
    self.openUrlMethod = "activity_wxshare"
    self:setSource(AutoPopoutSource.kInitEnter, AutoPopoutSource.kEnterForeground, AutoPopoutSource.kReturnFromFAQ, AutoPopoutSource.kGamePlayQuit)
end

function OpenActivityPopoutAction:checkOpenUrlMethod(cache)
    local res = cache.para
    return res.method == "open_activity" or res.method == "activity_wxshare"
end

function OpenActivityPopoutAction:checkCache(cache)
    local res = cache.para

    local paraData = {}
    for k, v in pairs(res.para) do
        paraData[k] = v
    end

    local actId = tonumber(paraData.actId)
    if actId then
        self.para = paraData
    else
        return self:onCheckCacheResult(false)
    end

    local function needPopCb()
        self:onCheckCacheResult(true)
        return false
    end

    local function onError()
        self:onCheckCacheResult(false)
    end

    ActivityUtil:getActivitys(function( activitys )
        local activity = table.find(activitys,function( v )
            local c = require("activity/" .. v.source)
            return tostring(c.actId) == tostring(actId) 
        end)
        
        if activity then
            local c = require("activity/" .. activity.source)
            if c.showDynamicPanel and c.canShowDynamicPanel and c.canShowDynamicPanel() then
                needPopCb()
            else
                local data = ActivityData.new(activity)
                data:start(false, false, nil, onError,nil, needPopCb)
            end
        else
            --虽然没有此活动，但是需要弹出一些提示面板
            needPopCb()
        end
    end)
end

function OpenActivityPopoutAction:isFunc( func )
    return type(func) == "function"
end

function OpenActivityPopoutAction:getPopActId()
    return self.popActId
end

function OpenActivityPopoutAction:popout( next_action )
    local function needPopCb()
        return AutoPopout:isHomeScene()
    end

    ActivityUtil:getAllActivitys( function ( all_activitys, filter_activitys, loadFromNetwork )
        local activity = table.find(all_activitys,function( v )
            local c = require("activity/" .. v.source)
            return tostring(c.actId) == tostring(self.para.actId) 
        end)
        
        if activity then
            local config = require("activity/" .. activity.source)
            print("OpenActivityPopoutAction:popout()activity.source",config.actId,activity.source)

            if config.showDynamicPanel and config.canShowDynamicPanel and config.canShowDynamicPanel() then
                config.showDynamicPanel(self.para, next_action)
                return
            end

            if tonumber(_G.bundleVersion:split(".")[2]) < (config.minVer or 2.0) then
                AutoPopout:showNotifyPanel("您的游戏版本不是最新版，快去更新吧~", next_action)
                return
            end

            if UserManager:getInstance():getUserRef():getTopLevelId() < (config.topLevelId or 1) then
                AutoPopout:showNotifyPanel(string.format("通过第%d关才可参加活动~快去闯关吧~", config.topLevelId), next_action)
                return
            end
            
            if self:isFunc(config.isActBegin) and not config.isActBegin() then
                if self:isFunc(config.isUnSupportPkg) and not config.isUnSupportPkg() then -- 不支持的平台不提示
                    AutoPopout:showNotifyPanel("活动尚未开启", next_action)
                else
                    next_action()
                end
                return
            end

            if self:isFunc(config.isActEnd) and config.isActEnd() then
                AutoPopout:showNotifyPanel("活动已经结束~", next_action)
                return
            end

            if self:isFunc(config.isUnSupportPkg) and config.isUnSupportPkg() then
                AutoPopout:showNotifyPanel("您所在的平台没有活动哦~", next_action)
                return
            end

            
            if not config.ignoreSelf and tostring(self.para.uid) == tostring(UserManager:getInstance():getUserRef().uid) then
                AutoPopout:showNotifyPanel("这是自己的分享哟~", next_action)
                return
            end

            local activity = table.find(filter_activitys,function( v ) 
                local c = require("activity/" .. v.source)
                return tostring(c.actId) == tostring(self.para.actId)  
            end)

            if activity then
                local data = ActivityData.new(activity)
                config.shareData = self.para
                self.popActId = tonumber(self.para.actId)
                if self:isFunc(config.writeShareData) then
                    config.writeShareData(config.shareData)
                end

                data:start(true,false,nil, next_action, next_action, needPopCb)
            else
                AutoPopout:showNotifyPanel( "forcepop.tip1", next_action)
            end
        else
            AutoPopout:showNotifyPanel( "活动已结束!", next_action)
        end
    end )
end