--[[
 * OpenFullStarRankAction
 * @date    2018-08-07 11:31:52
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]
OpenFullStarRankAction = class(HomeScenePopoutAction)

function OpenFullStarRankAction:ctor()
    self.name = "OpenFullStarRankAction"
    self.openUrlMethod = "fullstar_wxshare"
    self.isPopScene = true
    self:setSource(AutoPopoutSource.kInitEnter, AutoPopoutSource.kEnterForeground, AutoPopoutSource.kReturnFromFAQ)
end

function OpenFullStarRankAction:checkCache(cache)
    self.para = cache.para or {}
    self.para = self.para.para or {}
    local XFLogic = require 'zoo.panel.xfRank.XFLogic'
    
    local function __check( onFinish )
        if (not (type(self.para) ~= "table" or not self.para.uid)) and XFLogic:isEnabled() then
            RequireNetworkAlert:callFuncWithLogged(function ( ... )
                onFinish(true)
            end)
        else
            onFinish(false)
        end
    end

    __check(function ( ret )
        self:onCheckCacheResult(ret)
    end)
end

function OpenFullStarRankAction:popout( next_action )
    local XFLogic = require 'zoo.panel.xfRank.XFLogic'
    XFLogic:popoutMainPanel(true, nil)
end