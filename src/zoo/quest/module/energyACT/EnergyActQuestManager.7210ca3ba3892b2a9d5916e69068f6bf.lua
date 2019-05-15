require 'zoo.quest.QuestEvent'
require 'zoo.quest.QuestEventDispatcher'

local Quest = require 'zoo.quest.Quest'
local QuestFactory = require 'zoo.quest.QuestFactory'
local SaveDataServer = require 'zoo.quest.SaveDataServer'



require 'zoo.quest.QuestChangeContext'

local function deferFunc( func )
	return function ( ... )
		local params = {...}
		setTimeOut(function (  )
			func(unpack(params))
		end, 0.0001)
	end
end

local function bind( func, p )
	return function (...)
		return func(p, ...)
	end
end

local EnergyActQuestManager = class()

local ThisModuleId = 2
function EnergyActQuestManager:ctor( ... )
	self:registerListeners()
	self:reset()
    GlobalEventDispatcher:getInstance():addEventListener(kGlobalEvents.kPassDay, self.passDayListener)
end

function EnergyActQuestManager:passDayListener( ... )
	EnergyActQuestManager:getInstance():readFromUserData()
end

local instance 
function EnergyActQuestManager:getInstance( ... )
	if not instance then
		instance = EnergyActQuestManager.new()
	end
	return instance
end

function EnergyActQuestManager:registerListeners( ... )
	_G.questEvtDp:ad(QuestEventType.kFinish, self.onQuestFinish, self)
	_G.questEvtDp:ad(QuestEventType.kQuestUpdate, self.onQuestUpdate, self)
end

function EnergyActQuestManager:getQuestList( ... )
	return table.simpleClone(self.questList or {}) or {}
end

function EnergyActQuestManager:reset( ... )
	for _, quest in pairs(self:getQuestList()) do
		quest:dispose()
	end
	self.questList = {}
	self.updateTime = 0
	self.rewarded = false
	self.minutes = 0
	self.init = 0
end

function EnergyActQuestManager:hasQuests( ... )
	return #(self.questList) > 0
end

function EnergyActQuestManager:hasRewards( ... )
	return self:hasQuests() and self:isAllFinished() and (not self:hadGotRewards())
end

function EnergyActQuestManager:hadGotRewards( ... )
	return self.rewarded
end

function EnergyActQuestManager:getMinutes( ... )
	return self.minutes
end

-- local DATA = {
-- 	_type = 12,
-- 	relTarget = 100,
-- 	num = 0,
-- 	updateTime = ms,
-- 	rewarded = false,
-- 	minutes = 10,
-- }

local function time2day(ts)
	ts = ts or Localhost:timeInSec()
	local utc8TimeOffset = 57600 -- (24 - 8) * 3600
	local oneDaySeconds = 86400 -- 24 * 3600
	local dayStart = ts - ((ts - utc8TimeOffset) % oneDaySeconds)
	return (dayStart + 8*3600)/24/3600
end


function EnergyActQuestManager:readFromUserData(  )
	self:reset()

	local questInfo = SaveDataServer:read(SaveDataServer.DataKey.kEnergyActQuest) or {}

--	printx(61, 'questInfo', table.tostring(questInfo))

	local validDayIndex = time2day((questInfo.updateTime or 0) / 1000)
	local todayIndex = time2day()

	if todayIndex <= validDayIndex then
		self:addQuest(questInfo)
	end

	self.updateTime = questInfo.updateTime or 0
	self.rewarded = questInfo.rewarded or false
	self.minutes = questInfo.minutes or 0
	self.init = questInfo.init or 0
end

function EnergyActQuestManager:writeToUserData(  )
	if self:hasQuests() then
		local quest = self.questList[1]
		local questInfo = QuestFactory:encodeQuest(quest)
		questInfo.updateTime = self.updateTime
		questInfo.rewarded = self.rewarded
		questInfo.minutes = self.minutes
		questInfo.init = self.init
		SaveDataServer:write(SaveDataServer.DataKey.kEnergyActQuest, questInfo)
	end
end


function EnergyActQuestManager:addQuest(rawData)

--	printx(61, 'rawData', table.tostring(rawData))

	local quest =  QuestFactory:createQuestByRawData(rawData, 0, ThisModuleId)
	if quest then
		table.insert(self.questList, quest)
		_G.questEvtDp:dp(_G.QuestEvent.new(_G.QuestEventType.kTrigger, quest))
		quest:active()

--		printx(61, 'quest:isFinished()', quest:isFinished())
	end
end

function EnergyActQuestManager:removeQuest( quest )
	quest:dispose()
	table.removeValue(self.questList, quest)
end

function EnergyActQuestManager:updateQuest( quest, rawData )
	quest:dispose()
	quest:setQuestData(rawData)
	quest:active()
end

function EnergyActQuestManager:onQuestFinish( evt )
	local quest = evt.data
	if quest and quest.getModuleId and quest:getModuleId() == ThisModuleId then
		self:writeToUserData()
		self:tryUpdateTipView()
	end
end

function EnergyActQuestManager:onQuestUpdate( evt )
	local quest = evt and evt.data and evt.data.quest
	if quest and quest.getModuleId and quest:getModuleId() == ThisModuleId then
		self:writeToUserData()
	end
end

function EnergyActQuestManager:isAllFinished( ... )
	for _, v in ipairs(self:getQuestList()) do
		if not v:isFinished() then
			return false
		end
	end
	return true
end

function EnergyActQuestManager:updateDataByACT( questInfo )
	SaveDataServer:write(SaveDataServer.DataKey.kEnergyActQuest, questInfo)

--	printx(61, 'updateDataByACT', table.tostring(questInfo))

	self:readFromUserData()

	self._canHideRewardMark = nil
end

function EnergyActQuestManager:receiveTaskRewards( ... )
	self:_getReward('weekendEnergyReward', {
		type = 5,
	}, function ( rewards ) 
		self.rewarded = true
		self:writeToUserData()
		self:tryUpdateTipView()
	end, ...)
end


function EnergyActQuestManager:_getReward( endPoint, params, successHandler, successCallback, failCallback, cancelCallback)
	HttpBase:syncPost(endPoint, params, function ( evt )
		if not evt.data then return end
		local rewards = evt.data.rewards or {}
		self:addRewards(rewards)
		if successHandler then successHandler(rewards, evt) end
		if successCallback then successCallback(rewards, evt) end
	end, function ( evt )
		local errcode = evt and evt.data or nil
		if errcode then
			CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(errcode)), "negative")
		end
	    if failCallback then failCallback(evt) end
	end, function ( ... )
		if cancelCallback then cancelCallback() end
	end)
end

local Meta = {}
Meta.ACT_ENERGY = 50019
Meta.OTHER_ENERGY = 50018
EnergyActQuestManager.Meta = Meta

-- local model

local ACT_ID = 1028 
local ACT_SOURCE = 'EnergyACT/Config.lua'

function EnergyActQuestManager:addRewards(rewardItems)
	local hasItemRewards = false
	for _,reward in pairs(rewardItems or {}) do

		if reward.itemId == Meta.ACT_ENERGY then
			local oldBuff = UserManager:getInstance().userExtend:getNotConsumeEnergyBuff()
			local newBuff = 0
			if oldBuff < Localhost:time() then
				newBuff = Localhost:time() + 60 * 1000 * reward.num
			else
				newBuff = oldBuff + 60 * 1000 * reward.num
			end
			UserManager:getInstance().userExtend:setNotConsumeEnergyBuff(newBuff)
			UserService:getInstance().userExtend:setNotConsumeEnergyBuff(newBuff)

			if GainAndConsumeMgr then
				GainAndConsumeMgr.getInstance():gainItem(DcFeatureType.kActivity, Meta.ACT_ENERGY, reward.num, DcSourceType.kActPre.."energy", nil, ACT_ID)
			end
		elseif reward.itemId == Meta.OTHER_ENERGY then
			-- if GainAndConsumeMgr then
				-- GainAndConsumeMgr.getInstance():gainItem(DcFeatureType.kActivity, Meta.OTHER_ENERGY, 1, DcSourceType.kActPre.."energy", nil, ACT_ID)
			-- end
		else
			if UserManager.addRewardsWithDc and type(UserManager.addRewardsWithDc) == "function" then
	            UserManager:getInstance():addRewardsWithDc({reward}, {source = "activity", activityId = ACT_ID})
	            UserService:getInstance():addRewards({reward})
	        else
	            UserManager:getInstance():addReward(reward)
	            UserService:getInstance():addReward(reward)
	            if GainAndConsumeMgr then
	            	GainAndConsumeMgr.getInstance():gainItem(DcFeatureType.kActivity, reward.itemId, reward.num, DcSourceType.kActPre..ACT_ID, nil, ACT_ID)
	            end
	        end
			hasItemRewards = true
		end

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

function EnergyActQuestManager:getQuest( ... )
	if self:hasQuests() then
		return self.questList[1]
	end
end


function EnergyActQuestManager:isActEnabled( ... )
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

function EnergyActQuestManager:tryUpdateTipView( ... )
	if self:isActEnabled() then
		if self:hasRewards() then
			self._canHideRewardMark = not ActivityUtil:hasRewardMark(ACT_SOURCE)
			ActivityUtil:setRewardMark(ACT_SOURCE, true)
		else
			if self._canHideRewardMark then
				ActivityUtil:setRewardMark(ACT_SOURCE, false)
				self._canHideRewardMark = nil
			end
		end
	end
end

function EnergyActQuestManager:popRewardsPanel( onFinish )
	-- body
	local EnergyActUI = require 'zoo.quest.module.energyACT.EnergyActUI'
	local panel = EnergyActUI.EnergyRewardsPanel:create(self:getMinutes())
	panel:setFinishCallback(onFinish)
	panel:popout()

	local uid = UserManager:getInstance().uid
	CCUserDefault:sharedUserDefault():setIntegerForKey('energy1.act.quest.reward.panel.show.day' .. tostring(uid), time2day(Localhost:timeInSec()))
end

function EnergyActQuestManager:needShowRewardsPanel( ... )
	local uid = UserManager:getInstance().uid
	return time2day(Localhost:timeInSec()) > (CCUserDefault:sharedUserDefault():getIntegerForKey('energy1.act.quest.reward.panel.show.day' .. tostring(uid), 0) or 0)
end

function EnergyActQuestManager:getActivityIcon( ... )
	for k,v in pairs(HomeScene:sharedInstance().activityIconButtons or {}) do
		if v.source == ACT_SOURCE then
			return v
		end
	end
end


return EnergyActQuestManager