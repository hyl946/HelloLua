UpdatePackagePopoutNewAction = class(HomeScenePopoutAction)

function UpdatePackagePopoutNewAction:ctor()
	self.name = "UpdatePackagePopoutNewAction"
    self:setSource(AutoPopoutSource.kInitEnter, AutoPopoutSource.kEnterForeground)
end

function UpdatePackagePopoutNewAction:checkCanPop()
    self:onCheckPopResult(UpdatePackageManager:enabled() and UpdatePackageManager:getInstance():canForcePop())
end

function UpdatePackagePopoutNewAction:popout( next_action )
	UpdatePackageManager:getInstance():onEnter(next_action)
end