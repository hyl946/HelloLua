--[[
 * FristRankFriend
 * @date    2018-04-09 19:44:10
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

local FristRankFriend = class(ShareOnly)

function FristRankFriend:ctor()
	self.id = AchiId.kFristRankFriend
	self.levelType = self:genLevelType(GameLevelType.kMainLevel, GameLevelType.kHiddenLevel)
	require "zoo.panel.share.ShareFirstInFriendsPanel"
	self.sharePanel = ShareFirstInFriendsPanel
	self.requiredDataIds = {
		AchiDataType.kFriendRank,
		AchiDataType.kPassFriendNum,
	}
end

function FristRankFriend:onCheckReach(data)
	return data[AchiDataType.kFriendRank] == 1 and data[AchiDataType.kPassFriendNum] > 4
end

Achievement:registerNode(FristRankFriend.new())