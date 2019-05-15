require "zoo.localActivity.mauNumberOne.MauNumberOneManager"

MauNumberOnePopoutAction = class(HomeScenePopoutAction)

function MauNumberOnePopoutAction:ctor()
    self.name = "MauNumberOnePopoutAction"
	self:setSource(AutoPopoutSource.kInitEnter, AutoPopoutSource.kEnterForeground, AutoPopoutSource.kSceneEnter)
end

function MauNumberOnePopoutAction:checkCanPop()
	self:onCheckPopResult(MauNumberOneManager.getInstance():checkPanelCanPop())
end

function MauNumberOnePopoutAction:popout(next_action)
	DcUtil:activity({category='energy', sub_category='push_icon', t1=0})
    MauNumberOneManager.getInstance():popoutPanel(next_action)
end