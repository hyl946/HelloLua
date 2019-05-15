require "zoo.localActivity.oppoLaunch.OppoLaunchManager"

OGCPopoutAction = class(HomeScenePopoutAction)

function OGCPopoutAction:ctor()
	self.ignorePopCount = true
    self.name = "OGCPopoutAction"
	self:setSource(AutoPopoutSource.kInitEnter)
end

function OGCPopoutAction:checkCanPop()
	self:onCheckPopResult(OppoLaunchManager.getInstance():canPop())
end

function OGCPopoutAction:popout(next_action)
    OppoLaunchManager.getInstance():tryOppoLaunchReward(next_action)
end