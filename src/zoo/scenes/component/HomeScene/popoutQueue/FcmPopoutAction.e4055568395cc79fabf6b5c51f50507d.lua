--防沉迷强弹
FcmPopoutAction = class(HomeScenePopoutAction)

function FcmPopoutAction:ctor()
	self.name = "FcmPopoutAction"
	self:setSource(AutoPopoutSource.kInitEnter, AutoPopoutSource.kEnterForeground)
end

function FcmPopoutAction:checkCanPop()
	local timeScale = FcmManager:getTimeScale()
	local leftTime = FcmManager:getLeftTime()
	self:onCheckPopResult(timeScale == FcmConst.max and leftTime > 0)
end

function FcmPopoutAction:popout(next_action)
	FcmManager:showTip(next_action)
end