--[[
 * TotalCountAchi
 * @date    2018-04-04 14:23:49
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

local TotalCountAchi = class(AchiNode)

function TotalCountAchi:ctor( id, levelType, sharePanel, quitMode )
	self.id = id

	self.levelType = levelType
	self.sharePanel = sharePanel
	self.requiredDataIds = {id}
	self.quitLevelMode = quitMode or self.quitLevelMode
end

function TotalCountAchi:addCount( count )
	UserManager:getInstance().userExtend:addAchievementValue(self.id, count)
	UserService:getInstance().userExtend:addAchievementValue(self.id, count)
	self.reachCount = self:getTargetValue()
	return self.reachCount
end

function TotalCountAchi:onCheckReach(data)
	local newCount = data[self.id]
	if newCount <= 0 then
		return false
	end
	return self:isReachLadder( self:addCount(newCount) )
end

function TotalCountAchi:getTargetValue()
	return UserManager:getInstance().userExtend:getAchievementValue(self.id) or 0
end

local function registerNode( id, levelType, sharePanel, quitMode )
	Achievement:registerNode(TotalCountAchi.new(id, levelType, sharePanel, quitMode))
end

local levelType = TotalCountAchi:genLevelType(GameLevelType.kMainLevel, GameLevelType.kHiddenLevel)
--闯关次数
registerNode(AchiId.kTotalEntryLevelTime, levelType, nil, "all")
--直线特效
registerNode(AchiId.kTotalLineEffectCount, 0, nil, "all")
--爆炸特效
registerNode(AchiId.kTotalBombEffectCount, 0, nil, "all")
--魔力鸟
registerNode(AchiId.kTotalMagicBirdCount, 0, nil, "all")
--交换特效
registerNode(AchiId.kTotalChangeEffectCount, 0, nil, "all")
--使用道具
registerNode(AchiId.kTotalUsePropCount)
--送出初级精力瓶
registerNode(AchiId.kTotalSendPrimaryEnergyCount)
--获得初级精力瓶
registerNode(AchiId.kTotalGetPrimaryEnergyCount)
--使用精力瓶
registerNode(AchiId.kTotalUseEnergyCount)
--帮助好友解锁
registerNode(AchiId.kTotalHelpFriendUnlockCount)
--帮助好友过关
registerNode(AchiId.kTotalHelpFriendPassCount)
--使用风车币
registerNode(AchiId.kTotalUseWindmillCount)
--使用银币
registerNode(AchiId.kTotalUseCoinCount)
--收到点赞
require "zoo.panel.share.SharePopularityPanel" 
registerNode(AchiId.kTotalGetLikeCount, nil, SharePopularityPanel)
--发出点赞
registerNode(AchiId.kTotalSendLikeCount)

--签到
registerNode(AchiId.kTotalMarkCount)

--闯周赛关,see TotalEntryWeeklyAchi

--采集果实
require "zoo.panel.share.ShareCollectedNFruit"
registerNode(AchiId.kTotalGetFruitCount, nil, ShareCollectedNFruit)
--重生果实
registerNode(AchiId.kTotalRebirthFruitCount)
--为果实加速
registerNode(AchiId.kTotalSpeedUpFruitCount)