
require "hecore.ui.PopoutManager"
RankRacePanelPopoutAction = class(HomeScenePopoutAction)

function RankRacePanelPopoutAction:ctor()
    self.name = "RankRacePanelPopoutAction"
    self.recallUserNotPop = true
    self:setSource(AutoPopoutSource.kInitEnter, AutoPopoutSource.kEnterForeground)
end

function RankRacePanelPopoutAction:checkCanPop()
	if self.debug then
		RankRaceMgr.getInstance().canForcePop = function () return true end
	end
    self:onCheckPopResult(RankRaceMgr.getInstance():canForcePop())
end

function RankRacePanelPopoutAction:popout(next_action)
    --TODO:close panel to next action
    RankRaceMgr.getInstance():tryForcePopout(nil, next_action, next_action)
end