require "zoo.panel.component.friendsRecommend.FriendRecommendManager"

AreaTaskTriggerPopoutAction = class(HomeScenePopoutAction)

function AreaTaskTriggerPopoutAction:ctor()
    self.name = "AreaTaskTriggerPopoutAction"
    self:setSource(AutoPopoutSource.kGamePlayQuit)
end

function AreaTaskTriggerPopoutAction:checkCache(cache)
    local M = AreaTaskMgr:getInstance()
    local areaId = cache.para
    if not areaId then
        return self:onCheckCacheResult(false)
    end

    local areaBeginLevelId = (areaId - 40001) * 15 + 1
    local topLevelId = M:getModel():safeGetTopLevel()
    if topLevelId > areaBeginLevelId + 14 then
        return self:onCheckCacheResult(false)
    end

    self.areaId = areaId
    self:onCheckCacheResult(true)
end

function AreaTaskTriggerPopoutAction:popout(next_action)
    local AreaTaskInfoPanel = require 'zoo.areaTask.AreaTaskInfoPanel'
	local taskInfos = AreaTaskMgr:getInstance():getModel():getCurTaskInfos()
    if #taskInfos > 0 then
        local levelId = taskInfos[#taskInfos].levelId
        local areaId = math.floor((levelId - 1) / 15) + 40001
        local panel = AreaTaskInfoPanel:create(areaId)
        panel:popoutPush(next_action)
    else
    	next_action()
    end
end


AreaTaskNotFinishedFristPopoutAction = class(HomeScenePopoutAction)

function AreaTaskNotFinishedFristPopoutAction:ctor()
    self.name = "AreaTaskNotFinishedFristPopoutAction"
    self:setSource(AutoPopoutSource.kInitEnter, AutoPopoutSource.kSceneEnter)
end

function AreaTaskNotFinishedFristPopoutAction:checkCanPop()
    AreaTaskMgr:getInstance():checkCanPop( function ( canPop )
        self:onCheckPopResult(canPop)
    end )
end

function AreaTaskNotFinishedFristPopoutAction:popout(next_action)
    local AreaTaskInfoPanel = require 'zoo.areaTask.AreaTaskInfoPanel'
    local taskInfos = AreaTaskMgr:getInstance():getModel():getCurTaskInfos()
    if #taskInfos > 0 then
        local levelId = taskInfos[#taskInfos].levelId
        local areaId = math.floor((levelId - 1) / 15) + 40001
        local panel = AreaTaskInfoPanel:create(areaId)
        panel:popoutPush(next_action)
    else
        next_action()
    end
end