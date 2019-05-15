--[[
 * IncitePanelPopoutAction
 * @Author  zhou.ding 
 * @Date    2017-04-14 11:12:27
 * @Email 	zhou.ding@happyelements.com
--]]

IncitePanelPopoutAction = class(HomeScenePopoutAction)

function IncitePanelPopoutAction:ctor()
    self.name = "IncitePanelPopoutAction"
    self.recallUserNotPop = true
    self:setSource(AutoPopoutSource.kInitEnter, AutoPopoutSource.kEnterForeground)
end

function IncitePanelPopoutAction:checkCache( cache )
    local readySdkId = cache.para
    self:onCheckPopResult(readySdkId and InciteManager:canForcePop())
end

function IncitePanelPopoutAction:popout( next_action )
    InciteManager:tryPopoutIncitePanel( false, next_action )
end