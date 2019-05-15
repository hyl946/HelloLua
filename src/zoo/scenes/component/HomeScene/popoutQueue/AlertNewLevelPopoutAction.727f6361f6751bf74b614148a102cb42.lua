require "zoo.common.FAQ"
require 'zoo.panel.AlertNewLevelPanel'
require "zoo.panel.CommonTip"
AlertNewLevelPopoutAction = class(HomeScenePopoutAction)

function AlertNewLevelPopoutAction:ctor(url)
	self.name = "AlertNewLevelPopoutAction"
	self.recallUserNotPop = true
    self:setSource(AutoPopoutSource.kInitEnter, AutoPopoutSource.kEnterForeground)
end

function AlertNewLevelPopoutAction:checkCanPop()
	if self.debug then
		AlertNewLevelPanel.isNeedPopout = function ()return true end
	end
    self:onCheckPopResult(AlertNewLevelPanel.canForcePop())
end

function AlertNewLevelPopoutAction:popout( next_action )
	if AlertNewLevelPanel.isNeedPopout() then
		AlertNewLevelPanel:create():tryPopout(next_action)
	else
		next_action()
	end
end
