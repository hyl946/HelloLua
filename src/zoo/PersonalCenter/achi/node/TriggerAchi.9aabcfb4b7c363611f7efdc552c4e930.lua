--[[
 * TriggerAchi
 * @date    2018-04-03 16:55:20
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

--主线/隐藏关分数进入全国前1000 
local ScorePassThousand = class(AchiNode)

function ScorePassThousand:ctor()
	self.id = AchiId.kScorePassThousand
	self.levelType = self:genLevelType(GameLevelType.kMainLevel, GameLevelType.kHiddenLevel)
	self.requiredDataIds = {
		AchiDataType.kOverSelfRank,
		AchiDataType.kAllScoreRank,
	}
	require "zoo.panel.share.ShareThousandOnePanel"
	self.sharePanel = ShareThousandOnePanel
end

function ScorePassThousand:requireData()
	local rankRequest = false
	local newScore = Achievement:get(AchiDataType.kNewScore)
	local oldScore = Achievement:get(AchiDataType.kOldScore)
	if oldScore < 0 or oldScore < newScore then
		rankRequest = true
	end

	if oldScore < 0 then
		oldScore = 0
	end

	if rankRequest then
		local function onCompleteSuccess( evt )
			local rankPosition = 1
			local share = false
			if evt.data and evt.data.rankPosition then
				rankPosition = evt.data.rankPosition
			end

			if evt.data and evt.data.share then
				share = evt.data.share
			end

			Achievement:onDataUpdate(AchiDataType.kOverSelfRank, share)
			Achievement:onDataUpdate(AchiDataType.kAllScoreRank, rankPosition)

			ReplayDataManager:checkNeedAutoUploadByVerifyRank( Achievement:get(AchiDataType.kLevelId) , rankPosition , share )
		end

		local shareDataHttp = GetShareRankWithPosition.new()
		shareDataHttp:addEventListener(Events.kComplete, onCompleteSuccess)
		shareDataHttp:load(Achievement:get(AchiDataType.kLevelId), oldScore)
	else
		Achievement:set(AchiDataType.kOverSelfRank, false)
		Achievement:set(AchiDataType.kAllScoreRank, 0)

		ReplayDataManager:checkNeedAutoUploadByVerifyRank( Achievement:get(AchiDataType.kLevelId) , -1 , false )
	end
end

function ScorePassThousand:onCheckReach(data)
	return data[AchiDataType.kOverSelfRank]
end

Achievement:registerNode(ScorePassThousand.new())



--一天内连续通过5个主线关 
local ContinuePassFiveLevel = class(AchiNode)

function ContinuePassFiveLevel:ctor()
	self.id = 150
	self.levelType = self:genLevelType(GameLevelType.kMainLevel, GameLevelType.kHiddenLevel)
	self.requiredDataIds = {}
	require "zoo.panel.share.SharePassFiveLevelPanel"
	self.sharePanel = SharePassFiveLevelPanel
end

function ContinuePassFiveLevel:onCheckReach(data)
	if not self:isNotRepeatLevel(data) then
		return false
	end

	local levelDataInfo = UserService.getInstance().levelDataInfo

	local maxConbo = levelDataInfo.maxConbo or 0

	local levels = {}
	for level,v in pairs(levelDataInfo.levels) do
		if LevelType:isMainLevel(tonumber(level)) then
			table.insert(levels, tonumber(level))
		end
	end

	table.sort(levels)

	if #levels < 5 then
		return false
	end

	--连续
	for i = #levels - 4, #levels-1 do
		if levels[i + 1] - levels[i] ~= 1 then
			return false
		end
	end

	return maxConbo >= 5
end


Achievement:registerNode(ContinuePassFiveLevel.new())

--	主线/隐藏关连续失败＞5次后过关 
local FailTimeGFive = class(AchiNode)

function FailTimeGFive:ctor()
	self.id = 160
	self.levelType = self:genLevelType(GameLevelType.kMainLevel, GameLevelType.kHiddenLevel)
	self.requiredDataIds = {AchiDataType.kLevelId}
	require "zoo.panel.share.ShareFinalPassLevelPanel"
	self.sharePanel = ShareFinalPassLevelPanel
end

function FailTimeGFive:onCheckReach(data)
	local levelDataInfo = UserService.getInstance().levelDataInfo
	local levelInfo = levelDataInfo:getLevelInfo(data[AchiDataType.kLevelId])

	local playTimes = levelInfo.playTimes or 0
	local failTimes = levelInfo.failTimes or 0

	return playTimes > 5 and (playTimes - failTimes) == 1
end

Achievement:registerNode(FailTimeGFive.new())

--主线/隐藏关最后一步过关 
local LastStepPass = class(AchiNode)

function LastStepPass:ctor()
	self.id = 170
	self.levelType = self:genLevelType(GameLevelType.kMainLevel, GameLevelType.kHiddenLevel)
	self.requiredDataIds = {AchiDataType.kLeftStep}
	require "zoo.panel.share.ShareLastStepPanel"
	self.sharePanel = ShareLastStepPanel
end

function LastStepPass:onCheckReach(data)
	return self:isNotRepeatLevel(data) and data[AchiDataType.kLeftStep] == 0
end

Achievement:registerNode(LastStepPass.new())

--主线/隐藏成功过关时，剩余步数≥10 
local LeftStepGETen = class(AchiNode)

function LeftStepGETen:ctor()
	self.id = 180
	self.levelType = self:genLevelType(GameLevelType.kMainLevel, GameLevelType.kHiddenLevel)
	self.requiredDataIds = {AchiDataType.kLeftStep}
	require "zoo.panel.share.ShareLeftTenStepPanel"
	self.sharePanel = ShareLeftTenStepPanel
end

function LeftStepGETen:onCheckReach(data)
	return data[AchiDataType.kLeftStep] >= 10
end

Achievement:registerNode(LeftStepGETen.new())


--领取签到最后一个宝箱 
local GetFinalMarkChest = class(AchiNode)

function GetFinalMarkChest:ctor()
	self.id = AchiId.kGetFinalMarkChest
	self.requiredDataIds = {AchiDataType.kGetFinalMarkChest}
	require "zoo.panel.share.ShareChestPanel"
	self.sharePanel = ShareChestPanel
end

function GetFinalMarkChest:onCheckReach(data)
	return data[AchiDataType.kGetFinalMarkChest] == true
end

Achievement:registerNode(GetFinalMarkChest.new())

--在游戏中绑定账号（任意一种即可）
local BindAnyAccount = class(AchiNode)

function BindAnyAccount:ctor()
	self.id = AchiId.kBindAnyAccount
	self.requiredDataIds = {AchiDataType.kBindAnyAccount}
end

function BindAnyAccount:cal()
	local isReached = false
	for k,authType in pairs(PlatformAuthEnum) do
		if authType ~= PlatformAuthEnum.kGuest then
			if UserManager:getInstance().profile:getSnsInfo(authType) ~= nil then
				isReached = true break
			end
		end
	end
	return isReached
end

function BindAnyAccount:onCheckReach(data)
	return self:cal()
end

Achievement:registerNode(BindAnyAccount.new())

--使用自定义头像、昵称
local UseCustomHeadOrNickname = class(AchiNode)

function UseCustomHeadOrNickname:ctor()
	self.id = AchiId.kUseCustomHeadOrNickname
	self.requiredDataIds = {AchiDataType.kUseCustomHeadOrNickname}
end

function UseCustomHeadOrNickname:cal()
	local profile = UserManager:getInstance().profile
	local fileId = profile.fileId or ""
	local headUrl = profile.headUrl
    local customHeadUrl = "http://animal-10001882.image.myqcloud.com/"..fileId

    local isReached = (profile:haveName() and profile:getDisplayName() ~= "消消乐玩家") or customHeadUrl == headUrl
	return isReached
end

function UseCustomHeadOrNickname:onCheckReach(data)
	return self:cal()
end

Achievement:registerNode(UseCustomHeadOrNickname.new())

--补齐自己的个人资料（性别、生日、地址）
local FillUpPersonalInfo = class(AchiNode)
function FillUpPersonalInfo:ctor()
	self.id = AchiId.kFillUpPersonalInfo
	self.requiredDataIds = {AchiDataType.kFillUpPersonalInfo}
end

function FillUpPersonalInfo:cal()
	local profile = UserManager:getInstance().profile
    local isReached = profile.age ~= 0 and profile.gender ~= 0 and profile.location ~= ''

	return isReached
end


function FillUpPersonalInfo:onCheckReach(data)
	return self:cal()
end

Achievement:registerNode(FillUpPersonalInfo.new())