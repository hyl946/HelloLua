require "zoo.data.BitFlag"


UserTagModel = class()

UserTagDCSource = {
	
	kLaunch = 1 ,
	kHome = 2 ,
	kPassLevel = 3 ,
}

UserTagGroupKey = {
	kUserTag = "userTag" ,
	kDifficultyTag = "difficultyTag" ,
	kPayTag = "payTag" ,
	kSocialTag = "socialTag" ,
	kLevelTag = "levelTag" ,
	kPropTag = "propTag" ,
}

GetUserTagReturnType = {
	kSuccess = 0 ,
	kFailByTime = 1 ,
	kFailByTopLevel = 2 ,
}

UserTagGroupKeyIndex = {
	[1] = UserTagGroupKey.kUserTag ,
	[2] = UserTagGroupKey.kDifficultyTag ,
	[3] = UserTagGroupKey.kPayTag ,
	[4] = UserTagGroupKey.kSocialTag ,
	[5] = UserTagGroupKey.kLevelTag ,
	[6] = UserTagGroupKey.kPropTag ,
}

UserTagGroupNameToIndexMap = {}
for k,v in ipairs(UserTagGroupKeyIndex) do
	UserTagGroupNameToIndexMap[v] = k
end

UserTagNameKey = {}

UserTagNameKey[UserTagGroupKey.kUserTag] = {
	
	kActivation = "activationTag" ,--用户活跃属性
	kWorkingWeekendDay = "workingWeekendDayTag" ,--工作日or休息日活跃偏好  
	kActivePeriodOnDay = "activePeriodOnDayTag" ,--当天活跃时间段偏好
	kLoginFrequency = "loginFrequencyTag" ,--登录频次
}

UserTagNameKey[UserTagGroupKey.kDifficultyTag] = {
	
	kTopLevelDiff = "topLevelDiffTag" ,--当前toplevel的难度阶级
	kTopLevelDiffPosition = "topLevelDiffPositionTag" ,--单关难度分位
	kContinuousDiff = "continuousDiffTag" ,--连续5关实际难度
}

UserTagNameKey[UserTagGroupKey.kPayTag] = {
	
	kLastWeekPay = "lastWeekPayTag" ,--近一周内付费
	kLastMonthPay = "lastMonthPayTag" ,--近一个月内付费
	kHistoryPay = "historyPayTag" ,--历史总付费
}

UserTagNameKey[UserTagGroupKey.kSocialTag] = {
	
	kFriendCount = "friendCountTag" ,--游戏内好友数
	kFriendInteraction = "friendInteractionTag" ,--游戏内好友互动情况
}

UserTagNameKey[UserTagGroupKey.kLevelTag] = {
	
	kLevelPosition = "levelPositionTag" ,--打关进度
	kLevelUp = "levelUpTag" ,--打关升级速度
	kStarProportion = "starProportionTag" ,--星星数占比
	kPlayLevelPreference = "playLevelPreferenceTag" ,--闯关类型偏好
}

UserTagNameKey[UserTagGroupKey.kPropTag] = {
	
	kUsePropFrequency = "usePropFrequencyTag" ,--各种道具的使用频率
}

UserTagNameKeyToGroupMap = {}
UserTagNameKeyFullMap = {}

DefaultUserTagDurationTime = 3600 * 24
DefaultUserTagTopLevelIdLength = 1
DefaultUserTagUpdateDelayAtHomeScene = 3600 * 6
--DefaultUserTagUpdateDelayAtHomeScene = 60

for k,v in pairs(UserTagNameKey) do
	for k2,v2 in pairs(v) do
		UserTagNameKeyToGroupMap[v2] = tostring(k)
		UserTagNameKeyFullMap[k2] = tostring(v2)
	end
end

UserTagNameKeyToTagIdMap = {
	--UserTag
	[UserTagNameKeyFullMap.kActivation] = 10100 ,--用户活跃属性
	[UserTagNameKeyFullMap.kWorkingWeekendDay] = 10200 ,--工作日or休息日活跃偏好
	[UserTagNameKeyFullMap.kActivePeriodOnDay] = 10300 ,--当天活跃时间段偏好
	[UserTagNameKeyFullMap.kLoginFrequency] = 10400 ,--登录频次

	--DifficultyTag
	[UserTagNameKeyFullMap.kTopLevelDiff] = 20100 ,--当前toplevel的难度阶级
	[UserTagNameKeyFullMap.kTopLevelDiffPosition] = 20200 ,--单关难度分位
	[UserTagNameKeyFullMap.kContinuousDiff] = 20300 ,--连续5关实际难度

	--PayTag
	[UserTagNameKeyFullMap.kLastWeekPay] = 30100 ,--近一周内付费
	[UserTagNameKeyFullMap.kLastMonthPay] = 30200 ,--近一个月内付费
	[UserTagNameKeyFullMap.kHistoryPay] = 30300 ,--历史总付费

	--SocialTag
	[UserTagNameKeyFullMap.kFriendCount] = 40100 ,--游戏内好友数
	[UserTagNameKeyFullMap.kFriendInteraction] = 40200 ,--游戏内好友互动情况

	--LevelTag
	[UserTagNameKeyFullMap.kLevelPosition] = 50100 ,--打关进度
	[UserTagNameKeyFullMap.kLevelUp] = 50200 ,--打关升级速度
	[UserTagNameKeyFullMap.kStarProportion] = 50300 ,--星星数占比
	[UserTagNameKeyFullMap.kPlayLevelPreference] = 50400 ,--闯关类型偏好

	--PropTag
	[UserTagNameKeyFullMap.kUsePropFrequency] = 60100 ,--各种道具的使用频率
}

UserTagIdToNameKeyMap = {}
for k,v in pairs(UserTagNameKeyToTagIdMap) do
	UserTagIdToNameKeyMap[v] = k
end

UserTagValueMap = {
	
	[UserTagNameKeyFullMap.kActivation] = {
		kNone = 0 ,
		kWillLose = 1 ,
		kReturnBack = 2 ,
		kNewAdd = 3 ,
		kNormalActive = 4 ,
		kHighlyActive = 5 ,
	} ,

	[UserTagNameKeyFullMap.kWorkingWeekendDay] = {
		kWorkingDay = 1 ,
		kWeekendDay = 2 ,
		kIncludingBoth = 3 ,
		kNotIncludedBoth = 4 ,
	} ,

	[UserTagNameKeyFullMap.kActivePeriodOnDay] = {
		kAM = 1 ,
		kPM = 2 ,
		kNight = 3 ,
	} ,

	[UserTagNameKeyFullMap.kLoginFrequency] = {
		kHigh = 1 ,
		kNormal = 2 ,
		kLow = 3 ,
	} ,

	[UserTagNameKeyFullMap.kTopLevelDiff] = {
		kNone = 0 ,
		kHighDiff1 = 1 ,
		kHighDiff2 = 2 ,
		kHighDiff3 = 3 ,
		kHighDiff4 = 4 ,
		kHighDiff5 = 5 ,
		kLowDiff1 = 10 ,
		kNormalDiff = 11 ,
	} ,

	[UserTagNameKeyFullMap.kTopLevelDiffPosition] = {
		kPoor = 1 ,
		kNormal = 2 ,
		kGood = 3 ,
	},

	[UserTagNameKeyFullMap.kContinuousDiff] = {
		kLow = 1 ,
		kNormal = 2 ,
		kHigh = 3 ,
	},

	[UserTagNameKeyFullMap.kLastWeekPay] = {
		kNone = 0 ,
		kHigh = 1 ,
		kNormal = 2 ,
		kLow = 3 ,
		kNoPay = 4 ,
	},

	[UserTagNameKeyFullMap.kLevelUp] = {
		kNone = 0 ,
		kLow = 1 ,
		kNormal = 2,
		kHigh = 3 ,
	},
}


local __instance = nil

local localDataKey = "LDA"

local topLevelIdSuffix = "TopLevelId"
local topLevelIdLengthSuffix = "TopLevelIdLength"
local updateTimeSuffix = "UpdateTime"
local endTimeSuffix = "EndTime"
local changeTimeSuffix = "ChangeTime"
local startTimeSuffix = "StartTime"

function UserTagModel:getTopLevelIdSuffix()
	return topLevelIdSuffix
end


local function getCurrUid()
	return UserManager:getInstance():getUID() or "12345"
end

local function getLocalFilePath()
	return localDataKey .. "_" .. tostring(getCurrUid()) .. ".ds"
end

local function getLocalLevelDataFilePath()
	return localLevelDataKey .. "_" .. tostring(getCurrUid()) .. ".ds"
end

function UserTagModel:getInstance()
	if not __instance then
		__instance = UserTagModel.new()
		__instance:init()
	end
	return __instance
end

function UserTagModel:init()

	if not self.localData then
		local localData = Localhost:readFromStorage( getLocalFilePath() )
		--local localData = Localhost:readFileData( getLocalFilePath() )
		
		if not localData or localData.ver ~= 3 then
			localData = self:getDefaultData()
		end

		self.localData = localData
	end
	
	self.staticMetaConfig = {}
end


function UserTagModel:getDefaultData()
	local localData = {}

	localData.ver = 3

	localData.defaultTagEndTime = 0
	localData.defaultTagChangeTime = 0
	localData.defaultTagStartTime = 0
	localData.defaultTagTopLevelId = 0

	for k,v in pairs( UserTagNameKey ) do

		localData[tostring(k)] = {}
		local tags = v
		local currData = localData[tostring(k)]

		for k2,v2 in pairs(tags) do

			if v2 == tags.kUsePropFrequency then
				currData[tostring(v2)] = {}
			else
				currData[tostring(v2)] = 0
			end
			currData[tostring(v2) .. topLevelIdSuffix] = 0
			currData[tostring(v2) .. topLevelIdLengthSuffix] = 0
			currData[tostring(v2) .. updateTimeSuffix] = 0
		end
	end

	localData.localUpdateTimes = {}

	return localData
end

function UserTagModel:getTagLocalUpdateTime(tagGroup)
	if self.localData and self.localData.localUpdateTimes and self.localData.localUpdateTimes[tagGroup] then
		return self.localData.localUpdateTimes[tagGroup]
	end
	return 0
end

function UserTagModel:updateTags( resp , source )

	local userData = UserManager:getInstance():getUserRef()
	local topLevel = userData:getTopLevelId()

	local userTag = resp.userTag
	local difficultyTag = resp.difficultyTag
	local payTag = resp.payTag
	local socialTag = resp.socialTag
	local levelTag = resp.levelTag
	local propTag = resp.propTag

	if source == UserTagDCSource.kLaunch then
		if resp.defaultTagStartTime then
			self.localData.defaultTagStartTime = math.floor( tonumber( resp.defaultTagStartTime ) / 1000 )
		else
			self.localData.defaultTagStartTime = 0
		end
		self.localData.defaultTagEndTime = self.localData.defaultTagStartTime + DefaultUserTagDurationTime
		self.localData.defaultTagTopLevelId = resp.defaultTagTopLevelId or 0
	end

	if userTag then self:updateTag( UserTagGroupKey.kUserTag , userTag , source ) end
	if difficultyTag then self:updateTag( UserTagGroupKey.kDifficultyTag , difficultyTag , source ) end
	if payTag then self:updateTag( UserTagGroupKey.kPayTag , payTag , source ) end
	if socialTag then self:updateTag( UserTagGroupKey.kSocialTag , socialTag , source ) end
	if levelTag then self:updateTag( UserTagGroupKey.kLevelTag , levelTag , source ) end
	if propTag then self:updateTag( UserTagGroupKey.kPropTag , propTag , source ) end

	self:flushDcLog( source , self.localData.defaultTagTopLevelId or 0 )

	self:flushLocalData()
end

function UserTagModel:flushLocalData()
	if self.localData then
		Localhost:writeToStorage(self.localData, getLocalFilePath() )
		--Localhost:writeToFile( getLocalFilePath() , self.localData )
	end
end

function UserTagModel:__updateTagsByTagBean( typeGroup , nameKey , tagBean , defaultDataType )

	local localData = self.localData

	if defaultDataType == "table" then
		localData[typeGroup][nameKey] = tagBean[nameKey] or {}
	elseif defaultDataType == "number" then
		localData[typeGroup][nameKey] = tonumber(tagBean[nameKey] or 0)
	else
		localData[typeGroup][nameKey] = tonumber(tagBean[nameKey] or 0)
	end
	

	local tagtopLevelId = tagBean[nameKey .. topLevelIdSuffix]
	if tagtopLevelId and tonumber(tagtopLevelId) ~= 0 then
		localData[typeGroup][nameKey .. topLevelIdSuffix] = tonumber(tagtopLevelId)
	else
		localData[typeGroup][nameKey .. topLevelIdSuffix] = tonumber( self.localData.defaultTagTopLevelId )
	end

	local tagchangeTime = tagBean[nameKey .. changeTimeSuffix]
	if tagchangeTime and tonumber(tagchangeTime) ~= 0 then
		localData[typeGroup][nameKey .. changeTimeSuffix] = tonumber(tagchangeTime)
	else
		localData[typeGroup][nameKey .. changeTimeSuffix] = 0
	end

	local tagstartTime = tagBean[nameKey .. startTimeSuffix]
	if tagstartTime and tonumber(tagstartTime) ~= 0 then
		localData[typeGroup][nameKey .. startTimeSuffix] = tonumber(tagstartTime)
	else
		localData[typeGroup][nameKey .. startTimeSuffix] = 0
	end

	
	

	local updateTime = 0
	if localData.localUpdateTimes and localData.localUpdateTimes[typeGroup] then
		updateTime = localData.localUpdateTimes[typeGroup]
	end


	if updateTime and tonumber(updateTime) ~= 0 then
		localData[typeGroup][nameKey .. updateTimeSuffix] = updateTime
	else
		localData[typeGroup][nameKey .. updateTimeSuffix] = Localhost:timeInSec()
	end


	local tagValue = localData[typeGroup][nameKey]
	if type(tagValue) ~= "number" then tagValue = 0 end

	local staticMetaConfig = self:getUserTagStaticConfig(nameKey)

	-- if nameKey == UserTagNameKeyFullMap.kActivation then
	-- 	printx( 1 , "UserTagModel:__updateTagsByTagBean  nameKey = " , nameKey , "staticMetaConfig =" , table.tostring(staticMetaConfig) )
	-- end
	

	if staticMetaConfig then

		if staticMetaConfig.topLevelLength then
			local topLevelLength = 0
			if type( staticMetaConfig.topLevelLength ) == "number" or type( staticMetaConfig.topLevelLength ) == "string"  then
				topLevelLength = tonumber(staticMetaConfig.topLevelLength)
			elseif type( staticMetaConfig.topLevelLength ) == "table" then
				topLevelLength = tonumber(staticMetaConfig.topLevelLength[tostring(tagValue)])
			end

			if not topLevelLength then topLevelLength = 0 end

			if topLevelLength == 0 then
				localData[typeGroup][nameKey .. topLevelIdLengthSuffix] = tonumber( DefaultUserTagTopLevelIdLength )
			elseif topLevelLength > 0 then
				localData[typeGroup][nameKey .. topLevelIdLengthSuffix] = tonumber(topLevelLength)
			else
				localData[typeGroup][nameKey .. topLevelIdLengthSuffix] = -1
			end
		end

		if staticMetaConfig.durationTime then
			local durationTime = 0
			if type( staticMetaConfig.durationTime ) == "number" or type( staticMetaConfig.durationTime ) == "string" then
				durationTime = tonumber(staticMetaConfig.durationTime)
			elseif type( staticMetaConfig.durationTime ) == "table" then
				durationTime = tonumber(staticMetaConfig.durationTime[tostring(tagValue)])
			end

			if not durationTime then durationTime = 0 end

			if durationTime == 0 then
				localData[typeGroup][nameKey .. endTimeSuffix] = localData[typeGroup][nameKey .. updateTimeSuffix] + tonumber( DefaultUserTagDurationTime )
			elseif durationTime > 0 then
				localData[typeGroup][nameKey .. endTimeSuffix] = localData[typeGroup][nameKey .. updateTimeSuffix] + tonumber(durationTime)
			else
				localData[typeGroup][nameKey .. endTimeSuffix] = -1
			end
		end
	else
		localData[typeGroup][nameKey .. topLevelIdLengthSuffix] = tonumber( DefaultUserTagTopLevelIdLength )
		localData[typeGroup][nameKey .. endTimeSuffix] = tonumber( self.localData.defaultTagEndTime )
	end

	--[[
	local topLevelIdLength = tagBean[nameKey .. topLevelIdLengthSuffix]
	if topLevelIdLength and tonumber(topLevelIdLength) ~= 0 then
		localData[typeGroup][nameKey .. topLevelIdLengthSuffix] = tonumber(topLevelIdLength)
	else
		localData[typeGroup][nameKey .. topLevelIdLengthSuffix] = tonumber( self.localData.defaultTagTopLevelIdLength )
	end
	]]

	--[[
	local endTime = tagBean[nameKey .. updateTimeSuffix]
	if endTime and tonumber(endTime) ~= 0 then
		localData[typeGroup][nameKey .. updateTimeSuffix] = math.floor( tonumber(endTime) / 1000 )
	else
		localData[typeGroup][nameKey .. updateTimeSuffix] = tonumber( self.localData.defaultTagEndTime )
	end
	]]
end

function UserTagModel:updateTagsByTagBean( tagGroup , tagBean )

	local localData = self.localData
	if not localData or not UserTagNameKey[tagGroup] or not localData[tagGroup] then return end

	local topLevelFailCountsUpdateFlag = false
	local topLevelLogicalFailCountsUpdateFlag = false
	local topLevelPropUsedCountsUpdateFlag = false

	for k,v in pairs(UserTagNameKey[tagGroup]) do
		
		local doupdate = false

		if tagBean.onlyUpdateThisTag and tagBean.onlyUpdateThisTag == tostring(v) then
			doupdate = true
		else
			doupdate = true
		end

		if doupdate then
			if tagGroup == UserTagGroupKey.kPropTag then

				if tostring(v) == UserTagNameKeyFullMap.kUsePropFrequency then
					self:__updateTagsByTagBean( tagGroup , tostring(v) , tagBean , "table")
				else
					self:__updateTagsByTagBean( tagGroup , tostring(v) , tagBean , "number")
				end

				if not topLevelPropUsedCountsUpdateFlag and tagBean.topLevelPropUsedCount and tagBean.topLevelPropUsedCount > 0 then
					topLevelPropUsedCountsUpdateFlag = true
					self:updateTopLevelPropUsedCount( tagBean.topLevelPropUsedCount )
				end

				
			elseif tagGroup == UserTagGroupKey.kDifficultyTag then
				self:__updateTagsByTagBean( tagGroup , tostring(v) , tagBean , "number")

				if not topLevelLogicalFailCountsUpdateFlag and tagBean.logicalFailCounts and #tagBean.logicalFailCounts > 0 then

					topLevelLogicalFailCountsUpdateFlag = true

					local userData = UserManager:getInstance():getUserRef()
					local topLevel = userData:getTopLevelId()

					if not self.localData.difficultyTag.topLevelLogicalFailCounts then
						self.localData.difficultyTag.topLevelLogicalFailCounts = self.localData.difficultyTag.topLevelFailCounts or 0
					end

					for i = 1 , #tagBean.logicalFailCounts do
						local d = tagBean.logicalFailCounts[i]
						if d.first == topLevel then
							--self.localData.difficultyTag.topLevelLogicalFailCounts = d.second or 0
							self:updateTopLevelLogicalFailCounts( d.second or 0 )
							break
						end
					end
				end

				--注意，顺序敏感，opLevelFailCounts的解析必须在topLevelLogicalFailCounts之后
				if not topLevelFailCountsUpdateFlag and tagBean.failCounts and #tagBean.failCounts > 0 then

					topLevelFailCountsUpdateFlag = true

					local userData = UserManager:getInstance():getUserRef()
					local topLevel = userData:getTopLevelId()

					if not self.localData.difficultyTag.topLevelFailCounts then
						self.localData.difficultyTag.topLevelFailCounts = 0
					end

					for i = 1 , #tagBean.failCounts do
						local d = tagBean.failCounts[i]
						if d.first == topLevel then
							--self.localData.difficultyTag.topLevelFailCounts = d.second or 0
							self:updateTopLevelFailCounts( d.second or 0 )
							break
						end
					end
				end
				
			elseif tagGroup == UserTagGroupKey.kPayTag then
				self:__updateTagsByTagBean( tagGroup , tostring(v) , tagBean , "number")
				if tagBean.last60DayAmount then
					self:setLast60DayPayAmount( tonumber(tagBean.last60DayAmount) )
				else
					self:setLast60DayPayAmount( 0 )
				end
			else
				self:__updateTagsByTagBean( tagGroup , tostring(v) , tagBean , "number")
			end
		end
	end
end

function UserTagModel:getTagValueString( tagValue )
	if type(tagValue) == "table" then

		local tagStr = ""
		for k,v in pairs(tagValue) do
			tagStr = tagStr .. tostring(v.first) .. "_" .. tostring(v.second) .. ";"
		end
		return tagStr
	else
		return tostring(tagValue)
	end
end

function UserTagModel:updateTag( tagGroup , tagBean , source )

	local localData = self.localData

	if tagGroup and tagBean then

		if not localData.localUpdateTimes then localData.localUpdateTimes = {} end
		localData.localUpdateTimes[tagGroup] = Localhost:timeInSec()

		local oldTagValueMap = {}

		for k,v in pairs(UserTagNameKey[tagGroup]) do
			oldTagValueMap[tostring(v)] = self:getTagValueString( localData[tagGroup][tostring(v)] )
		end

		self:updateTagsByTagBean( tagGroup , tagBean )

		for k,v in pairs(UserTagNameKey[tagGroup]) do

			local nameKey = tostring(v)
			local staticMetaConfig = self:getUserTagStaticConfig( nameKey )

			if staticMetaConfig and staticMetaConfig.dcStrategy then
				if tonumber(staticMetaConfig.dcStrategy[ tostring(source) ]) == 1 then
					--不需要数据有变化才打点
					self:addDcDatas( nameKey , self:getTagValueString( localData[tagGroup][nameKey] ) )
				elseif tonumber(staticMetaConfig.dcStrategy[ tostring(source) ]) == 2 then
					--需要数据变化就打点
					local currTagValue = self:getTagValueString( localData[tagGroup][nameKey] )
					if currTagValue ~= oldTagValueMap[nameKey] then
						self:addDcDatas( nameKey , currTagValue , oldTagValueMap[nameKey] )
					end
				end
			end
		end
	end
end

function UserTagModel:encodeTagToString(bySeries)
	local str = nil
	if self.localData then
		str = ""
		for k,v in pairs( UserTagNameKeyToTagIdMap ) do
			local namekey = k
			local tagId = v

			local tag = "nil"
			if bySeries then
				tag = self:getTagValueString( self:getUserTagBySeries(namekey) )
			else
				tag = self:getTagValueString( self:getUserTag(namekey) )
			end

			if str == "" then
				str = tostring(tagId) .. "-" .. tostring(tag)
			else
				str = str .. "~" .. tostring(tagId) .. "-" .. tostring(tag)
			end
		end
	end

	return str
end

--[[
function UserTagModel:updateUserTag( userTag , source )

	local localData = self.localData

	if userTag then

		local oldActivationTag = localData.userTag.activationTag
		local oldWorkingWeekendDayTag = localData.userTag.workingWeekendDayTag
		local oldActivePeriodOnDayTag = localData.userTag.activePeriodOnDayTag
		local oldLoginFrequencyTag = localData.userTag.loginFrequencyTag

		self:updateTagsByTagBean( UserTagGroupKey.kUserTag , userTag )

		local needDCLog = true
		if source == UserTagDCSource.kHome then
			needDCLog = false
		end

		local staticMetaConfig = self:getUserTagStaticConfig( UserTagGroupKey.kUserTag )
		if staticMetaConfig.needDcLog then
			if tonumber(staticMetaConfig.needDcLog[ source ]) == 1 then
				--需要数据有变化才打点
			elseif tonumber(staticMetaConfig.needDcLog[ source ]) == 2 then
				--不需要数据变化就打点
			end
		end

		if needDCLog 
			or oldActivationTag ~= tonumber(userTag.activationTag) 
			or oldWorkingWeekendDayTag ~= tonumber(userTag.workingWeekendDayTag)
			or oldActivePeriodOnDayTag ~= tonumber(userTag.activePeriodOnDayTag)
			or oldLoginFrequencyTag ~= tonumber(userTag.loginFrequencyTag) then

			DcUtil:UseTagLog( 
				source,
				localData.userTag.activationTag , 
				localData.userTag.activationTagTopLevelId , 
				localData.userTag.activationTagEndTime , 
				tostring(oldActivationTag) .. "_" .. tostring(localData.userTag.activationTag) )
		end
	end
end
]]

--[[
function UserTagModel:updatePayTag( payTag , source )

	if payTag then

		self:updateTagsByTagBean( UserTagGroupKey.kPayTag , payTag )

	end

	local needDCLog = true
	if source ~= UserTagDCSource.kLaunch then
		needDCLog = false
	end

	if needDCLog then
			
	end
end
]]

--[[
function UserTagModel:updateSocialTag( socialTag , source )

	if socialTag then
		self:updateTagsByTagBean( UserTagGroupKey.kSocialTag , socialTag )
	end

	local needDCLog = true
	if source ~= UserTagDCSource.kLaunch then
		needDCLog = false
	end

	if needDCLog then
	end
end
]]

--[[
function UserTagModel:updateLevelTag( levelTag , source )

	local localData = self.localData

	if levelTag then

		local oldLevelPositionTag = localData.userTag.levelPositionTag
		local oldLevelUpTag = localData.userTag.levelUpTag

		self:updateTagsByTagBean( UserTagGroupKey.kLevelTag , levelTag )

		local needDCLog = true
		if source ~= UserTagDCSource.kLaunch then
			needDCLog = false
		end
		
		if needDCLog or oldLevelPositionTag ~= tonumber(userTag.levelPositionTag) then
			DcUtil:LevelPositionTagLog( 
				source,
				localData.userTag.levelPositionTag,
				localData.userTag.levelPositionTagEndTime )
		end
		
		if needDCLog or oldLevelUpTag ~= tonumber(userTag.levelUpTag) then
			DcUtil:LevelUpTagLog( 
				source,
				localData.userTag.levelUpTag ,
				tostring(oldLevelUpTag) .. "_" .. tostring(localData.userTag.levelUpTag) ,
				localData.userTag.levelUpTagEndTime )
		end
		
	end

end
]]

--[[
function UserTagModel:updatePropTag( propTag , source )

	local localData = self.localData

	if propTag then

		self:updateTagsByTagBean( UserTagGroupKey.kPropTag , propTag )

		local needDCLog = true
		if source ~= UserTagDCSource.kLaunch then
			needDCLog = false
		end
		
		if needDCLog then
			DcUtil:ItemTagLog( 
				source,
				localData.userTag.propTag )
		end
		
	end
end
]]

----------------------------------------------------------------------------------------

--获取用户当前的某个标签,自动校验过期时间和topLevel
--nameKey in global table : UserTagNameKey
function UserTagModel:getUserTag( nameKey )
	-- RemoteDebug:uploadLog("getUserTag", "UserTagModel:getUserTag" , nameKey)

	if not nameKey or type(nameKey) ~= "string" then return nil end

	local resultValue = nil

	if self.localData then
		local tagGroup = UserTagNameKeyToGroupMap[nameKey]

		if tagGroup and self.localData[tagGroup] and self.localData[tagGroup][nameKey] then
			local tagBean = self.localData[tagGroup]
			local tagValue = tagBean[nameKey]
			local tagTopLevelId = tonumber( tagBean[nameKey .. topLevelIdSuffix] )
			local tagTopLevelIdLength = tonumber( tagBean[nameKey .. topLevelIdLengthSuffix] )
			local tagEndTime = tonumber( tagBean[nameKey .. endTimeSuffix] )


			-- RemoteDebug:uploadLog("getUserTag", "tagValue" , tagValue , "tagTopLevelId" , tagTopLevelId , "tagTopLevelIdLength" , tagTopLevelIdLength , "tagEndTime" , tagEndTime )

			--判断topLevel是否合法
			if tagTopLevelId and tagTopLevelIdLength and tonumber(tagTopLevelId) ~= 0 and tonumber(tagTopLevelIdLength) ~= 0 then
				local userData = UserManager:getInstance():getUserRef()
				local topLevel = userData:getTopLevelId()

				if topLevel < tagTopLevelId or topLevel > tonumber(tagTopLevelId + tagTopLevelIdLength - 1) then
					if type(tagValue) == "table" then
						-- RemoteDebug:uploadLog("getUserTag", "return 1" , nameKey)
						return nil , GetUserTagReturnType.kFailByTopLevel
					else
						-- RemoteDebug:uploadLog("getUserTag", "return 2" , nameKey)
						return 0 , GetUserTagReturnType.kFailByTopLevel
					end
				end
			end

			--判断过期时间是否合法
			if tagEndTime and tonumber(tagEndTime) ~= 0 then
				if tagEndTime < Localhost:timeInSec() then
					if type(tagValue) == "table" then
						-- RemoteDebug:uploadLog("getUserTag", "return 3" , nameKey)
						return nil , GetUserTagReturnType.kFailByTime
					else
						-- RemoteDebug:uploadLog("getUserTag", "return 4" , nameKey)
						return 0 , GetUserTagReturnType.kFailByTime
					end
				end
			end

			resultValue = tagValue
		end
	end
	-- RemoteDebug:uploadLog("getUserTag", "return kSuccess  resultValue " , resultValue , "nameKey" , nameKey)
	return resultValue , GetUserTagReturnType.kSuccess
end


--获取用户当前标签的值，以及其附加参数，且不做任何本地校验（即返回原始后端的值）
--将根据nameKey，同时返回nameKey，nameKey+topLevelIdSuffix，nameKey+topLevelIdLengthSuffix，nameKey+updateTimeSuffix
--nameKey in global table : UserTagNameKey
function UserTagModel:getUserTagBySeries( nameKey )

	if not nameKey or type(nameKey) ~= "string" then return nil end

	if self.localData then
		local tagGroup = UserTagNameKeyToGroupMap[nameKey]

		if tagGroup and self.localData[tagGroup] and self.localData[tagGroup][nameKey] then
			local tagBean = self.localData[tagGroup]
			local tagValue = tagBean[nameKey]
			local tagTopLevelId = tonumber( tagBean[nameKey .. topLevelIdSuffix] )
			local tagTopLevelIdLength = tonumber( tagBean[nameKey .. topLevelIdLengthSuffix] )
			local tagEndTime = tonumber( tagBean[nameKey .. endTimeSuffix] )
			local tagUpdateTime = tonumber( tagBean[nameKey .. updateTimeSuffix] )
			local tagChangeTime = tonumber( tagBean[nameKey .. changeTimeSuffix] )
			local tagStartTime = tonumber( tagBean[nameKey .. startTimeSuffix] )

			return tagValue , tagTopLevelId , tagTopLevelIdLength , tagEndTime , tagUpdateTime , tagStartTime , tagChangeTime
		end
	end
end

function UserTagModel:getTopLevelFailCounts()
	if self.localData and self.localData.difficultyTag then
		return self.localData.difficultyTag.topLevelFailCounts or 0
	end
end

function UserTagModel:updateTopLevelFailCounts( failCounts )
	if self.localData and self.localData.difficultyTag then

		if not self.localData.difficultyTag.topLevelFailCounts then
			self.localData.difficultyTag.topLevelFailCounts = 0
		end 
		
		if tonumber(failCounts) ~= 0 then
			if tonumber( self.localData.difficultyTag.topLevelFailCounts ) < tonumber(failCounts) then
				self.localData.difficultyTag.topLevelFailCounts = failCounts
			end
		else
			self.localData.difficultyTag.topLevelFailCounts = 0
		end
		
		self:flushLocalData()
	end
end

function UserTagModel:getTopLevelLogicalFailCounts()
	if self.localData and self.localData.difficultyTag then
		return self.localData.difficultyTag.topLevelLogicalFailCounts or 0
	end
end

function UserTagModel:updateTopLevelLogicalFailCounts( failCounts )
	if self.localData and self.localData.difficultyTag then

		if not self.localData.difficultyTag.topLevelLogicalFailCounts then
			self.localData.difficultyTag.topLevelLogicalFailCounts = 0
		end 

		-- RemoteDebug:uploadLogWithTag( "TTT" , "UserTagModel:updateTopLevelLogicalFailCounts  new" , failCounts , "old" ,  self.localData.difficultyTag.topLevelLogicalFailCounts )
		-- RemoteDebug:uploadLogWithTag( "TTT" , "UserTagModel:updateTopLevelLogicalFailCounts  at" , debug.traceback() )
		if tonumber(failCounts) ~= 0 then
			if tonumber( self.localData.difficultyTag.topLevelLogicalFailCounts ) < tonumber(failCounts) then
				self.localData.difficultyTag.topLevelLogicalFailCounts = failCounts
			end
		else
			self.localData.difficultyTag.topLevelLogicalFailCounts = 0
		end
		
		self:flushLocalData()
	end
end

--[[
function UserTagModel:localRebuildTags( nameKey )
	if not nameKey or type(nameKey) ~= "string" then return nil end

	if self.localData then
		local tagGroup = UserTagNameKeyToGroupMap[nameKey]
		if tagGroup and self.localData[tagGroup] and self.localData[tagGroup][nameKey] then

			local tagBean = self.localData[tagGroup]
			local oldTagVaule = tagBean[nameKey]
			--local tagTopLevelId = tonumber( tagBean[nameKey .. topLevelIdSuffix] )
			--local tagTopLevelIdLength = tonumber( tagBean[nameKey .. topLevelIdLengthSuffix] )
			--local tagEndTime = tonumber( tagBean[nameKey .. updateTimeSuffix] )
			UserTagAutomationManager:checkTagHasChanged( UserTagNameKeyToTagIdMap[nameKey] , oldTagVaule )

		end
	end
end
]]


function UserTagModel:getTopLevelPropUsedCount()

	local tagkey = UserTagGroupKey.kLevelTag

	if self.localData and self.localData[tagkey] then
		return self.localData[tagkey].topLevelPropUsedCount or 0
	end

	return 0
end

function UserTagModel:updateTopLevelPropUsedCount( count )

	local tagkey = UserTagGroupKey.kLevelTag
	if self.localData and self.localData[tagkey] then

		if not self.localData[tagkey].topLevelPropUsedCount then
			self.localData[tagkey].topLevelPropUsedCount = 0
		end 
		
		if tonumber(count) ~= 0 then
			if tonumber( self.localData[tagkey].topLevelPropUsedCount ) < tonumber(count) then
				self.localData[tagkey].topLevelPropUsedCount = count
			end
		else
			self.localData[tagkey].topLevelPropUsedCount = 0
		end
		
		self:flushLocalData()
	end
end


function UserTagModel:setLast60DayPayAmount( count )
	local tagkey = UserTagGroupKey.kPayTag
	if self.localData and self.localData[tagkey] then
		self.localData[tagkey].last60DayPayAmount = count or 0
		self:flushLocalData()
	end
end

function UserTagModel:getLast60DayPayAmount()
	local tagkey = UserTagGroupKey.kPayTag
	if self.localData and self.localData[tagkey] then
		return self.localData[tagkey].last60DayPayAmount or 0
	end
	return 0
end
----------------------------------------------------------------------------------------


function UserTagModel:getUserTagStaticConfig( nameKey )

	if self.staticMetaConfig[tostring(nameKey)] then
		return self.staticMetaConfig[tostring(nameKey)]
	end

	local metaConfig = MetaManager.getInstance():getUserTagConfig( nameKey )
	self.staticMetaConfig[tostring(nameKey)] = metaConfig

	-- printx( 1 , "UserTagModel:getUserTagStaticConfig  nameKey = " , nameKey , "metaConfig.tagName =" , metaConfig.tagName )
	
	if nameKey == UserTagNameKeyFullMap.kActivation then -- for group test

		local function activityEnabled()

			local activityData = LocalBox:getData( LocalBoxKeys.Activity_UserCallBackTest )
			local now = Localhost:timeInSec()

			if activityData then

				local activityEndTime = activityData.realEndTime or now
				if activityData.realEndTime then
					if type(activityData.realEndTime) == "number" then
						activityEndTime = activityData.realEndTime
					elseif type(activityData.realEndTime) == "string" then
						activityEndTime = tonumber(activityData.realEndTime)
					elseif type(activityData.realEndTime) == "table" then
						activityEndTime = os.time(activityData.realEndTime)
					end
				end

				local testEndTime = activityData.endTime or now
				if activityData.endTime then
					if type(activityData.endTime) == "number" then
						testEndTime = activityData.endTime
					elseif type(activityData.endTime) == "string" then
						testEndTime = tonumber(activityData.endTime)
					elseif type(activityData.endTime) == "table" then
						testEndTime = os.time(activityData.endTime)
					end
				end
				--[[
				
				local nowDate = os.date( "*t" , now )
				local hs = ( 23 - tonumber(nowDate.hour) ) * 3600
				local ms = ( 59 - tonumber(nowDate.min) ) * 60
				local ss = ( 59 - tonumber(nowDate.sec) )

				local fixDurationTime = ( 86400 * 7 ) + hs + ms + ss
				]]

				DiffAdjustQAToolManager:print( 1 , "UserTagModel:getUserTagStaticConfig" , 
					"flag=" .. tostring(activityData.flag) 
					.. " now=" .. tostring(now) 
					.. " activityEndTime=" .. tostring(activityEndTime) 
					.. " testEndTime=" .. tostring(testEndTime) 
					)
				if activityData.flag and now < activityEndTime and now < testEndTime then
					return true
				end
			end

			return false
		end

		local uid = UserManager:getInstance():getUID() or "12345"
		local tagValue = UserTagValueMap[UserTagNameKeyFullMap.kActivation]


		if MaintenanceManager:getInstance():isEnabledInGroup("ReturnUsersRetentionTest" , "N51" , uid)
			or MaintenanceManager:getInstance():isEnabledInGroup("ReturnUsersRetentionTest" , "N52" , uid) then

			if activityEnabled() and type(metaConfig.topLevelLength) == "table" then
				metaConfig.topLevelLength[tostring(tagValue.kReturnBack)] = 9999
			end

			-- if type(metaConfig.durationTime) == "table" then
			-- 	metaConfig.durationTime[tostring(tagValue.kReturnBack)] = fixDurationTime
			-- end

		elseif MaintenanceManager:getInstance():isEnabledInGroup("ReturnUsersRetentionTest" , "N61" , uid)
			or MaintenanceManager:getInstance():isEnabledInGroup("ReturnUsersRetentionTest" , "N62" , uid) then
			
			if activityEnabled() and type(metaConfig.topLevelLength) == "table" then
				metaConfig.topLevelLength[tostring(tagValue.kReturnBack)] = 25
			end

			-- if type(metaConfig.durationTime) == "table" then
			-- 	metaConfig.durationTime[tostring(tagValue.kReturnBack)] = fixDurationTime
			-- end
		end
	end

	return metaConfig
end

function UserTagModel:refreshDifficultyTag( levelId , callback , source , notSyncLoad)

	notSyncLoad = true --已废弃，使用SyncManager.getInstance():addAfterSyncHttp来控制

	if not self.localData or not self.localData.difficultyTag or not self.localData.difficultyTag.topLevelDiffTagTopLevelId then 
		if callback then callback(false) end
		return
	end

	if tonumber(levelId) < tonumber(self.localData.difficultyTag.topLevelDiffTagTopLevelId) then
		if callback then callback(false) end
		return
	end

	local function afterSyncHttpCallback( result , datas )
		if result then
			local resp = datas

			local difficultyTag = resp.difficultyTag

			if difficultyTag then
				self:updateTag( UserTagGroupKey.kDifficultyTag , difficultyTag , source )
				self:flushDcLog()
				self:flushLocalData()
			end
		end
	end

	SyncManager.getInstance():addAfterSyncHttp( "getDifficultyTag" , {} , afterSyncHttpCallback , {allowMergers = true} )
end

function UserTagModel:getTagIdByNameKey( nameKey )
	return UserTagNameKeyToTagIdMap[nameKey]
end

function UserTagModel:getTagGroupByNameKey( nameKey )

end

function UserTagModel:addDcDatas( nameKey , newTagValue , oldTagValue )
	if not self.dcDatas then
		self.dcDatas = {}
	end

	local tagId = self:getTagIdByNameKey(nameKey)

	self.dcDatas["t" .. tostring(tagId)] = newTagValue

	if oldTagValue then
		self.dcDatas["t" .. tostring(tonumber(tagId + 1))] = oldTagValue
	end
end

function UserTagModel:flushDcLog( source , tagTopLevelId )
	if self.dcDatas then

		DcUtil:UpdateUseTag( source , tagTopLevelId , self.dcDatas )

		self.dcDatas = nil
	end
end