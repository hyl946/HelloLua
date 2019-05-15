--[[
 * OpenWeekMatchAction
 * @date    2018-08-07 11:31:52
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]
OpenWeekMatchAction = class(HomeScenePopoutAction)

function OpenWeekMatchAction:ctor()
    self.name = "OpenWeekMatchAction"
    self.openUrlMethod = "week_match_v2"
    self:setSource(AutoPopoutSource.kInitEnter, AutoPopoutSource.kEnterForeground, AutoPopoutSource.kReturnFromFAQ)
end

function OpenWeekMatchAction:checkCache(cache)
    local topLevelId = UserManager:getInstance().user:getTopLevelId() or 0
    if not RankRaceMgr:getInstance():isEnabled() and topLevelId > 30 then
        return self:onCheckCacheResult(false)
    end

    self.shareKey = nil
    if cache.para.para and cache.para.para.shareKey then
        self.shareKey = cache.para.para.shareKey
    end

    self:onCheckCacheResult(self.shareKey ~= nil)
end

function OpenWeekMatchAction:popout( next_action )
    require 'zoo.quarterlyRankRace.RankRaceMgr'

    local shareKey = self.shareKey


    local bEnabled, errCode = RankRaceMgr:getInstance():isEnabled()
    local topLevelId = UserManager:getInstance().user:getTopLevelId() or 0

    if not bEnabled and topLevelId <= 30 then
        AutoPopout:showNotifyPanel('rank.race.link.reward.error.level', next_action)
        return
    end

	local function startLogic()
		RankRaceMgr:getInstance():handleShareData(self.shareKey, next_action)
	end

    local function fail()
        AutoPopout:showNotifyPanel("领周赛宝石需要联网哦~", next_action)
    end

	RequireNetworkAlert:callFuncWithLogged(startLogic, fail, kRequireNetworkAlertAnimation.kNoAnimation)
end