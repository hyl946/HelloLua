--[[
 * OpenAskForHelpAction
 * @date    2018-08-06 18:24:54
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]
OpenAskForHelpAction = class(HomeScenePopoutAction)

function OpenAskForHelpAction:ctor()
    self.name = "OpenAskForHelpAction"
    self.openUrlMethod = "askforhelp"
    self:setSource(AutoPopoutSource.kInitEnter, AutoPopoutSource.kEnterForeground, AutoPopoutSource.kReturnFromFAQ)
end

function OpenAskForHelpAction:checkCache(cache)
    local res = cache.para
    local ret = false

    local para = res.para
    if type(para) == "table" then
        self.para = para
        ret = true
    end

    self:onCheckCacheResult(ret)
end

function OpenAskForHelpAction:popout( next_action )
    local function startLogic()
		local AskForHelpUrlLogic = require "zoo.panel.askForHelp.logic.AskForHelpUrlLogic"
		AskForHelpUrlLogic:startWithConfig(self.para, next_action)
	end
	RequireNetworkAlert:callFuncWithLogged(startLogic, nil, kRequireNetworkAlertAnimation.kNoAnimation)
end
