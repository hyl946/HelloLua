require "zoo.panel.component.friendsRecommend.FriendRecommendManager"

FriendRecommendPopoutAction = class(HomeScenePopoutAction)

function FriendRecommendPopoutAction:ctor()
    self.name = "FriendRecommendPopoutAction"
    self.recallUserNotPop = true
    self:setSource(AutoPopoutSource.kGamePlayQuit)
end

function FriendRecommendPopoutAction:checkCanPop()
	local function onSuccess(data)
		self.data = data
		self:onCheckPopResult(true)
	end

	local function onFail(errCode, errMsg)
		self:onCheckPopResult(false)
	end

	if self.debug then
		FriendRecommendManager.getInstance().shouldAskRecommendInfo = function () return true end
	end

    if FriendRecommendManager.getInstance():shouldAskRecommendInfo() then 
	    local curEnergy = UserManager.getInstance().user:getEnergy() or 30
		if curEnergy <= 25 then 
			FriendRecommendManager.getInstance():getRecommendInfo(onSuccess, onFail)
		else
			self:onCheckPopResult(false)
		end
	else
		self:onCheckPopResult(false)
	end
end

function FriendRecommendPopoutAction:popout(next_action)
	local panel = FriendRecommendPanel:create(self.data)
	panel:popout()

	panel:ad(PopoutEvents.kRemoveOnce, next_action)
end