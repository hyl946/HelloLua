UserCallBack4To6PopoutAction = class(HomeScenePopoutAction)

function UserCallBack4To6PopoutAction:ctor()
	self.name = "UserCallBack4To6PopoutAction"
	self:setSource(AutoPopoutSource.kInitEnter, AutoPopoutSource.kEnterForeground)
end

function UserCallBack4To6PopoutAction:checkCanPop()
	if self.debug then
		UserManager:getInstance().recallNotificationRewards = {rewards = {{itemId = 10001, num = 5}},viralId = "43636_1534991510973_19000"}
	end
	local rewardData = UserManager:getInstance().recallNotificationRewards

    self:onCheckPopResult(rewardData ~= nil)
end

function UserCallBack4To6PopoutAction:popout(next_action)
    require "zoo.push.PushUserCallbackManager"
	PushUserCallbackManager:checkUserCallbackRewards(next_action)
end
