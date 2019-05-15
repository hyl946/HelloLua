--[[
 * OpenUnlockAreaAction
 * @date    2018-08-07 11:18:18
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

OpenUnlockAreaAction = class(HomeScenePopoutAction)

function OpenUnlockAreaAction:ctor()
    self.name = "OpenUnlockAreaAction"
    self.openUrlMethod = "unlock_area"
    self:setSource(AutoPopoutSource.kInitEnter, AutoPopoutSource.kEnterForeground, AutoPopoutSource.kReturnFromFAQ)
end

function OpenUnlockAreaAction:checkCache(cache)
    local res = cache.para
    local ret = false

    local para = res.para
    if type(para) == "table" then
        self.para = para
        ret = true
    end

    self:onCheckCacheResult(ret)
end

function OpenUnlockAreaAction:popout( next_action )
    local function startLogic()
		UnlockMessageLogic:start(self.para, next_action)
	end
	RequireNetworkAlert:callFuncWithLogged(startLogic, nil, kRequireNetworkAlertAnimation.kNoAnimation)
end