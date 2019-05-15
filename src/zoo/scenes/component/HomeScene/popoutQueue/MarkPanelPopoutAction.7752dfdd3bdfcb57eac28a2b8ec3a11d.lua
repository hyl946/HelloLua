
require "hecore.ui.PopoutManager"
MarkPanelPopoutAction = class(HomeScenePopoutAction)

function MarkPanelPopoutAction:ctor()
    self.name = "MarkPanelPopoutAction"
    self:setSource(AutoPopoutSource.kInitEnter, AutoPopoutSource.kEnterForeground)
end

function MarkPanelPopoutAction:checkCanPop()
	local markButton = AutoPopout.homeScene.markButton
	local canPop = markButton 
					and not markButton.isDisposed
					and RequireNetworkAlert:popout(nil, kRequireNetworkAlertAnimation.kNoAnimation)

    local dayTime = 3600 * 24 * 1000
	local curDay = math.floor(Localhost:time() / dayTime)
	local lastMark = AutoPopout.homeScene.lastMark or 0

	local markModel = MarkModel:getInstance()
	markModel:calculateSignInfo()

    if not UserManager:getInstance().markV2Active then
	    canPop = canPop and lastMark < curDay and markModel.canSign
    else
        canPop = canPop and lastMark < curDay and not UserManager:getInstance().markV2TodayIsMark
    end

    self:onCheckPopResult(canPop)
end

function MarkPanelPopoutAction:popout( next_action )
    local panel = HomeScene:sharedInstance():tryPopoutMarkPanel(false, next_action, 0)

    if not panel then
        next_action()
    end
end