local LevelConfigCheckLogic = require 'zoo.quest.misc.LevelConfigCheckLogic'
local QuestActLogic = require 'zoo.quest.QuestActLogic'

local function allLevel3Star( ... )

	local localMaxLevel = kMaxLevels
	if NewAreaOpenMgr then
		localMaxLevel = NewAreaOpenMgr.getInstance():getLocalTopLevel()
	end

	for levelId = localMaxLevel, 1, -1 do
		local scoreRef = UserManager:getInstance():getUserScore(levelId)
		local star = 0
		if scoreRef then
			star = scoreRef.star or 0
		end

		if star < 3 then
			return false
		end
	end
	return true
end


local branchDataList 
function hasUnpassedHiddenLevel( ... )
	if not branchDataList then
		branchDataList = MetaModel:sharedInstance():getHiddenBranchDataList()
	end
	for index, v in ipairs(branchDataList) do
		if MetaModel:sharedInstance():isHiddenBranchCanOpen(index) then
			for levelId = branchDataList[index].startHiddenLevel, branchDataList[index].endHiddenLevel do
				if not UserManager:getInstance():hasPassedLevelEx(levelId) then
					return true
				end
			end
		end
	end
	return false
end


local QuestHttp = {}

function QuestHttp:calcTriggerQuestParams( ... )

	local animalColor = LevelConfigCheckLogic:randQuestColor()

	local myTopLevel = UserManager:getInstance().user:getTopLevelId()
	local localMaxLevel = kMaxLevels
	if NewAreaOpenMgr then
		localMaxLevel = NewAreaOpenMgr.getInstance():getLocalTopLevel()
	end
	local isFullLevel = myTopLevel >= localMaxLevel

	local localTotalStar = 0
    pcall(function ( ... )
	    local maxLevel = NewAreaOpenMgr.getInstance():getLocalTopLevel()
	    local totalStar = LevelMapManager.getInstance():getTotalStar(maxLevel)
	    local totalHiddenStar = MetaModel.sharedInstance():getFullStarInHiddenRegion(true)
	    localTotalStar = totalStar + totalHiddenStar
    end)

	-- local userTotalStar = UserManager.getInstance().user:getHideStar() + UserManager.getInstance().user:getStar()
 --    local isFullStar = userTotalStar >= localTotalStar

	local onlyLack4Star = false
	if (not isFullStar) and allLevel3Star() then
		onlyLack4Star = true
	end

	return {
		animalColor, 
		localMaxLevel,
		localTotalStar,
		onlyLack4Star,
		hasUnpassedHiddenLevel(),
	}
end

function QuestHttp:getReward( groupId, successCallback, failCallback, cancelCallback )
	HttpBase:syncPost('activityReward', {
		actId = QuestActLogic:getActId(),
		rewardId = groupId,
	}, function ( evt )
		local rewards = evt.data.rewards or evt.data.rewardItems
		QuestActLogic:addRewards(rewards)
		QuestManager:getInstance():afterGotReward(groupId)
		if successCallback then successCallback(rewards) end
	end, failCallback, cancelCallback)
end

function QuestHttp:triggerQuest( successCallback, failCallback, cancelCallback )
	local params = self:calcTriggerQuestParams()
	HttpBase:syncPost('questSystemInfo', {
		needTrigger = true,
		color = params[1],
		maxLevel = params[2],
		maxStar = params[3],
		needReplace4StarLevel = params[4],
		hasPlayableHideLevel = params[5],
	}, function ( evt )
		local info = {}
		if evt and evt.data then
			info = evt.data.info or {}
		end

		if successCallback then successCallback(info) end

		
	end, failCallback, cancelCallback)
end

return QuestHttp