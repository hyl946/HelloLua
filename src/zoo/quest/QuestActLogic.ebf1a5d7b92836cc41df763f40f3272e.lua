-- 这个功能的所有ui展示取决于活动开关

local ACT_ID = 3017
local ACT_SOURCE = 'QuestACT/Config.lua'

local QuestActLogic = {}

function QuestActLogic:getActId( ... )
	return ACT_ID
end

function QuestActLogic:isActEnabled( ... )
	local config
    for _,v in pairs(ActivityUtil:getActivitys()) do
        if v.source == ACT_SOURCE then
        	pcall(function ( ... )
	            config = require ('activity/'..v.source)
        	end)
            break
        end
    end
    local actEnabled = config and config.isSupport()
    return actEnabled
end


function QuestActLogic:addRewards(rewardItems)
	local hasItemRewards = false
	if not doNotUpdate then
		doNotUpdate = false
	end
	for _,reward in pairs(rewardItems or {}) do
        UserManager:getInstance():addReward(reward)
        UserService:getInstance():addReward(reward)
    	GainAndConsumeMgr.getInstance():gainItem(DcFeatureType.kActivity, reward.itemId, reward.num, DcSourceType.kActPre..ACT_ID, nil, ACT_ID)
		hasItemRewards = true
	end

	local onlyInfiniteBottle = table.filter(rewardItems, function ( tRewardItem )
		return tRewardItem.itemId == ItemType.INFINITE_ENERGY_BOTTLE_ONE_MINUTE
	end)

	local tInfiniteRewardItem = onlyInfiniteBottle[1]

	if tInfiniteRewardItem then
		local logic = UseEnergyBottleLogic:create(tInfiniteRewardItem.itemId)
		logic:setUsedNum(tInfiniteRewardItem.num)
		logic:setSuccessCallback(function ( ... )
			HomeScene:sharedInstance():checkDataChange()
			HomeScene:sharedInstance().energyButton:updateView()
		end)
		logic:setFailCallback(function ( evt )
		end)
		logic:start(true)
	end

	if hasItemRewards then
		Localhost:getInstance():flushCurrentUserData()
		HomeScene:sharedInstance():checkDataChange()
		local scene = HomeScene:sharedInstance()
		if scene.coinButton then scene.coinButton:updateView() end
		if scene.goldButton then scene.goldButton:updateView() end
    	scene:checkDataChange()
	end
end

function QuestActLogic:updateTipView( ... )

	if self:isActEnabled() then

		if not _G.kUserLogin then
			if not UserManager:getInstance().actInfos then
				UserManager:getInstance().actInfos = {}
			end

			local bFound = false
			for k, v in pairs(UserManager:getInstance().actInfos or {}) do
		        if v.actId == ACT_ID then
		        	bFound = true
		            break
		        end
		    end

		    if not bFound then
		    	table.insert(UserManager:getInstance().actInfos, {
		    		msgNum = 0,
		    		reward = false,
		    		see = true,
		    		actId = ACT_ID,
		    	})
		    end
		end


		local hasRewards = self:hasAnyRewards()
		if ActivityUtil.setRewardMark then
			ActivityUtil:setRewardMark(ACT_SOURCE, hasRewards)
		end

		if ActivityUtil.setMsgNum then
			local maxGroupId = _G.QuestManager:getInstance():getMaxGroupId()
			local quests = _G.QuestManager:getInstance():getUnfinishedQuestsByGroupId(maxGroupId)
			ActivityUtil:setMsgNum(ACT_SOURCE, #quests)


		end

	else

	end

end

function QuestActLogic:hasAnyRewards( ... )

	local groupIds = table.map(function ( v )
		return v:getGroupId()
	end, QuestManager:getInstance():getQuestList())



	for _, groupId in ipairs(groupIds) do
		if QuestManager:getInstance():hasRewards(groupId) then
			return true
		end
	end
	return false
end

function QuestActLogic:openMainPanel( ... )

	ActivityUtil:getActivitys(function( activitys )
        local currentScene = Director:sharedDirector():getRunningSceneLua()
        if currentScene ~= HomeScene:sharedInstance() then 
            return 
        end
        local source = ACT_SOURCE
        local version = nil
        for k,v in pairs(ActivityUtil:getActivitys() or {}) do
            if v.source == source then
                version = v.version
                break
            end
        end
        if version then
            ActivityData.new({source=source,version=version}):start(true, false, nil, nil, closeCallback)
        end
    end)

end

return QuestActLogic