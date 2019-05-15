require "zoo.gamePlay.userTags.UserTagModel"

UserTagManager = {}


local function getCurrUid()
	return UserManager:getInstance():getUID() or "12345"
end

local function getLocalFilePath()
	return localDataKey .. "_" .. tostring(getCurrUid()) .. ".ds"
end

local function getLocalLevelDataFilePath()
	return localLevelDataKey .. "_" .. tostring(getCurrUid()) .. ".ds"
end

function UserTagManager:init()

end

--从后端返回更新本地标签系统，后端返回什么就更新什么，不返回的保持原有值不变
function UserTagManager:updateTagsByResp( resp , source )
	UserTagModel:getInstance():updateTags( resp , source )
end

--获取用户当前的某个标签,自动校验过期时间和topLevel
--nameKey in global table : UserTagNameKey 或 UserTagNameKeyFullMap
function UserTagManager:getUserTag( nameKey )
	return UserTagModel:getInstance():getUserTag( nameKey )
end

--获取用户当前标签的值，以及其附加参数，且不做任何本地校验（即返回原始后端的值）
--将根据nameKey，同时返回nameKey，nameKey+topLevelIdSuffix，nameKey+topLevelIdLengthSuffix，nameKey+endTimeSuffix
--nameKey in global table : UserTagNameKey 或 UserTagNameKeyFullMap
function UserTagManager:getUserTagBySeries( nameKey )
	return UserTagModel:getInstance():getUserTagBySeries( nameKey )
end

--主动请求后端刷新一次DifficultyTag
function UserTagManager:refreshDifficultyTag( levelId , callback , source , notSyncLoad)
	UserTagModel:getInstance():refreshDifficultyTag( levelId , callback , source , notSyncLoad )
end

function UserTagManager:getTopLevelFailCounts()
	return UserTagModel:getInstance():getTopLevelFailCounts()
end

function UserTagManager:updateTopLevelFailCounts( failCounts )
	UserTagModel:getInstance():updateTopLevelFailCounts( failCounts )
end

function UserTagManager:getTopLevelLogicalFailCounts()
	return UserTagModel:getInstance():getTopLevelLogicalFailCounts()
end

function UserTagManager:updateTopLevelLogicalFailCounts( failCounts )
	UserTagModel:getInstance():updateTopLevelLogicalFailCounts( failCounts )
end

function UserTagManager:getTopLevelPropUsedCount()
	return UserTagModel:getInstance():getTopLevelPropUsedCount()
end

function UserTagManager:updateTopLevelPropUsedCount( count )
	UserTagModel:getInstance():updateTopLevelPropUsedCount( count )
end

-- function UserTagManager:setLast60DayPayAmount( count )
-- 	UserTagModel:getInstance():setLast60DayPayAmount( count )
-- end

function UserTagManager:getLast60DayPayAmount()
	return UserTagModel:getInstance():getLast60DayPayAmount()
end

function UserTagManager:getTagLocalUpdateTime(tagGroup)
	return UserTagModel:getInstance():getTagLocalUpdateTime( tagGroup )
end

function UserTagManager:getUserTagStaticConfig( nameKey )
	return UserTagModel:getInstance():getUserTagStaticConfig( nameKey )
end

--任何原因导致的topLevel变化都算，包括过关且有星级，解锁区域，召回，跳关，好友帮忙打关等
function UserTagManager:onTopLevelChanged()
	UserTagManager:updateTopLevelFailCounts( 0 )
	UserTagManager:updateTopLevelLogicalFailCounts( 0 )
	UserTagManager:updateTopLevelPropUsedCount( 0 )

	UserTagAutomationManager:getInstance():checkTagHasChanged( UserTagDCSource.kPassLevel )
end

function UserTagManager:isReturnBackUser()
	local tag =self:getUserTag( UserTagNameKeyFullMap.kActivation )
	return tag == UserTagValueMap[UserTagNameKeyFullMap.kActivation].kReturnBack
end
