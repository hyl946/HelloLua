--[[
 * SVIPGetRewardAction
 * @date    2018-08-08 11:02:37
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

SVIPGetRewardAction = class(HomeScenePopoutAction)

function SVIPGetRewardAction:ctor(url)
	self.name = "SVIPGetRewardAction"
	self:setSource(AutoPopoutSource.kInitEnter, AutoPopoutSource.kSceneEnter)
end

function SVIPGetRewardAction:checkCanPop()
	if self.debug then
		UserManager:getInstance().baFlags[kBAFlagsIdx.kSVIPGetPhoneReward] = true
		UserManager:getInstance():setUserRewardBit(19)
	end
	
	local bHaveFlag = UserManager:getInstance():hasBAFlag(kBAFlagsIdx.kSVIPGetPhoneReward)
    local rewardId = 19
	self:onCheckPopResult(bHaveFlag and not UserManager:getInstance():isUserRewardBitSet(rewardId))
end

function SVIPGetRewardAction:popout( next_action )
    local newSVIPGetRewardPanel = SVIPGetRewardPanel:create()
    newSVIPGetRewardPanel:popout(next_action)
end