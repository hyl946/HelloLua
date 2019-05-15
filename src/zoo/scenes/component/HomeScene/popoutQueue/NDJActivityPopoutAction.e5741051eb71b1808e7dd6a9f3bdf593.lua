--[[
 * NDJActivityPopoutAction
 * @date    2018-08-17 10:41:29
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

NDJActivityPopoutAction = class(HomeScenePopoutAction)

function NDJActivityPopoutAction:ctor()
	self.name = "NDJActivityPopoutAction"
    self:setSource(AutoPopoutSource.kInitEnter, AutoPopoutSource.kEnterForeground)
end

function NDJActivityPopoutAction:checkCanPop()
	if self.debug then
		return self:onCheckPopResult(false)
	end
	local function needPopCb()
        self:onCheckPopResult(true)
        return false
    end

    local function onError()
        self:onCheckPopResult(false)
    end

    ActivityUtil:getActivitys(function( activitys )
        local activity = table.find(activitys,function( v )
        	local config = require("activity/" .. v.source)
            return config.isNDJ == true
        end)
        
        if activity then
            local data = ActivityData.new(activity)
            data:start(false, false, nil, onError,nil, needPopCb)
        else
            onError()
        end
    end)
end

function NDJActivityPopoutAction:popout(next_action)
	ActivityUtil:getActivitys(function( activitys )
        local activity = table.find(activitys,function( v )
        	local config = require("activity/" .. v.source)
            return config.isNDJ == true
        end)
        
        if activity then
            local data = ActivityData.new(activity)
            data:start(false, false, nil, next_action)
        else
            next_action()
        end
    end)
end