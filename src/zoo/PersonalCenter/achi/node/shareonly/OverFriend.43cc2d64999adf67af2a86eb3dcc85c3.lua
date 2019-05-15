--[[
 * OverFriend
 * @date    2018-04-10 10:33:57
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]
local function HaveBindedAccount(authEnum)
	return UserManager:getInstance().profile:getSnsUsername(authEnum) ~= nil
end

local function HaveFriend()
	return FriendManager:getInstance():getFriendCount() > 0
end

local function supportPF(pf)
	return PlatformConfig:hasAuthConfig(pf)
end

local function CanSupport(data)
	return data[AchiDataType.kPassFriendNum] > 4 and (HaveFriend() or HaveBindedAccount(PlatformAuthEnum.kQQ))
end

local ScoreOverFriend = class(ShareOnly)

require "zoo.panel.share.SharePassFriendPanel"

function ScoreOverFriend:ctor()
	self.id = AchiId.kScoreOverFriend
	self.levelType = self:genLevelType(GameLevelType.kMainLevel, GameLevelType.kHiddenLevel)
	self.sharePanel = SharePassFriendPanel
	self.requiredDataIds = {
		AchiDataType.kFriendRankList,
		AchiDataType.kPassFriendNum,
	}
end

function ScoreOverFriend:getShareConfig()
	local shareConfig = AchiNode.getShareConfig(self)
	shareConfig.notifyMessage = "show_off_to_friend_point"
	shareConfig.shareType = AchiShareType.kNotify
	return shareConfig
end

function ScoreOverFriend:onCheckReach(data)
	local top_level = UserManager.getInstance().user:getTopLevelId()
	if not CanSupport(data) or top_level <= 7 then return false end

	local friend_rank_list = data[AchiDataType.kFriendRankList]
	local self_score = data[AchiDataType.kNewScore]
	local isOverFriend = false

	local over_friend_table = {}

	for i,v in ipairs(friend_rank_list) do
		if self_score > v.score then
			isOverFriend = true
			table.insert( over_friend_table, v )
		end
	end

	Achievement:set(AchiDataType.kScoreOverFriendTable, over_friend_table)

	return isOverFriend
end

Achievement:registerNode(ScoreOverFriend.new())

local LevelOverFriend = class(ShareOnly)

function LevelOverFriend:ctor()
	self.id = AchiId.kLevelOverFriend
	self.levelType = self:genLevelType(GameLevelType.kMainLevel)
	self.sharePanel = SharePassFriendPanel
	self.requiredDataIds = {
		AchiDataType.kFriendRankList,
		AchiDataType.kPassFriendNum,
	}
end

function LevelOverFriend:getShareConfig()
	local shareConfig = AchiNode.getShareConfig(self)
	shareConfig.notifyMessage = "show_off_to_friend_rank"
	shareConfig.shareType = AchiShareType.kNotify
	return shareConfig
end


function LevelOverFriend:onCheckReach(data)
	local top_level = UserManager.getInstance().user:getTopLevelId()
	local score = UserManager.getInstance():getUserScore(top_level)
	if score then
		top_level = top_level + 1
	end

	if not CanSupport(data) or top_level <= 30 then return false end

	local friend_rank_list = FriendManager:getInstance().friends

	if friend_rank_list == nil then
		return false
	end

	local isOverFriend = false

	local level_over_friend_table = {}
	local level = data[AchiDataType.kLevelId]

	for uid,friend in pairs(friend_rank_list) do
		local top_level = friend:getTopLevelId()
		if level == top_level then
			isOverFriend = true
			table.insert(level_over_friend_table, friend)
		end
	end

	Achievement:set(AchiDataType.kLevelOverFriendTable, level_over_friend_table)

	return isOverFriend
end

Achievement:registerNode(LevelOverFriend.new())


local function CanSupportNation()
	local top_level = UserManager.getInstance().user:getTopLevelId()
	local score = UserManager.getInstance():getUserScore(top_level)
	if score then
		top_level = top_level + 1
	end
	return not HaveFriend() and supportPF(PlatformAuthEnum.kQQ) and not HaveBindedAccount(PlatformAuthEnum.kQQ) and top_level > 46
end

local ScoreOverNation = class(ShareOnly)

function ScoreOverNation:ctor()
	self.id = AchiId.kScoreOverNation
	self.levelType = self:genLevelType(GameLevelType.kMainLevel, GameLevelType.kHiddenLevel)
	self.sharePanel = SharePassFriendPanel
	self.requiredDataIds = {
		AchiDataType.kNationScoreCofig
	}
end

function ScoreOverNation:getShareConfig()
	local shareConfig = AchiNode.getShareConfig(self)
	shareConfig.notifyMessage = "show_off_score_over_nation"
	shareConfig.shareType = AchiShareType.kNotify
	return shareConfig
end

function ScoreOverNation:onCheckReach(data)
	if not CanSupportNation() then return false end

	Achievement:set(AchiDataType.kScoreOverNationResult, nil)

	local score = data[AchiDataType.kNewScore]
	local nation_score_config = data[AchiDataType.kNationScoreCofig]
	local ret = false
	for k, v in pairs(nation_score_config) do
		if score >= v then
			ret = true
			Achievement:set(AchiDataType.kScoreOverNationResult, k)
		end		
	end

	return ret 
end

Achievement:registerNode(ScoreOverNation.new())

local LevelOverNation = class(ShareOnly)

function LevelOverNation:ctor()
	self.id = AchiId.kLevelOverNation
	self.levelType = self:genLevelType(GameLevelType.kMainLevel, GameLevelType.kHiddenLevel)
	self.sharePanel = SharePassFriendPanel
	self.requiredDataIds = {
		AchiDataType.kNationLevelCofig
	}
end

function LevelOverNation:getShareConfig()
	local shareConfig = AchiNode.getShareConfig(self)
	shareConfig.notifyMessage = "show_off_level_over_nation"
	shareConfig.shareType = AchiShareType.kNotify
	return shareConfig
end


function LevelOverNation:onCheckReach(data)
	if not CanSupportNation() then return false end

	Achievement:set(AchiDataType.kLevelOverNationResult, nil)

	local score = data[AchiDataType.kLevelId]
	local nation_level_config = data[AchiDataType.kNationLevelCofig]
	local ret = false
	for k, v in pairs(nation_level_config) do
		if score >= v then
			ret = true
			Achievement:set(AchiDataType.kLevelOverNationResult, k)
		end		
	end

	return ret 
end

Achievement:registerNode(LevelOverNation.new())