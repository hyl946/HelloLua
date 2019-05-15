--=====================================================
-- DTActivityManager
-- by zhijian.li
-- (c) copyright 2009 - 2016, www.happyelements.com
-- All Rights Reserved. 
--=====================================================
-- filename:  DTActivityManager.lua
-- author:    zhijian.li
-- e-mail:    zhijian.li@happyelements.com
-- created:   2016/11/21
-- descrip:   2016双十二活动 获得宝箱管理类
--=====================================================

require "zoo.localActivity.doubleTwelve.DTHttp"
require "zoo.localActivity.doubleTwelve.DTAnimation"

DTActivityManager = class()

local kStorageFileName = "dt_activity"
local instance = nil
function DTActivityManager.getInstance()
	if not instance then
		instance = DTActivityManager.new()
		instance:init()
	end
	return instance
end

function DTActivityManager:init()
	local localData = Localhost:readFromStorage(kStorageFileName) or {}
	self.chestGoldNum = localData.goldNum or 0
	self.chestSilverNum = localData.silverNum or 0
	self.triggerGoldChest = false
	self.triggerSilverChest = false
end

function DTActivityManager:saveLocalData()
	local localData = {goldNum = self.chestGoldNum, silverNum = self.chestSilverNum}
	Localhost:writeToStorage(localData, kStorageFileName)
end


function DTActivityManager:isSupport()
	-- return table.find(ActivityUtil:getActivitys() or {},function( v )
	-- 	return v.source == "Double12/Config.lua"
	-- end)

	return false
end

function DTActivityManager:getGoldChestNum()
	return self.chestGoldNum
end

function DTActivityManager:addGoldChestNum(num, reset)
	num = tonumber(num) or 0
	if reset then 
		self.chestGoldNum = num
	else
		self.chestGoldNum = self.chestGoldNum + num
	end
	if self.chestGoldNum < 0 then
		self.chestGoldNum = 0 
	end

	self:saveLocalData()
end

function DTActivityManager:getSilverChestNum()
	return self.chestSilverNum
end

function DTActivityManager:addSilverChestNum(num, reset)
	num = tonumber(num) or 0
	if reset then 
		self.chestSilverNum = num
	else
		self.chestSilverNum = self.chestSilverNum + num
	end
	if self.chestSilverNum < 0 then
		self.chestSilverNum = 0 
	end

	self:saveLocalData()
end

function DTActivityManager:getGoldChestChance()
	local random = math.random(1,100)
	if self.chestGoldNum < 6 then 
		return random <= 50
	else
		return random <= 20
	end
end

function DTActivityManager:getSilverChestChance()
	local random = math.random(1,100)
	if self.chestSilverNum < 12 then 
		return random <= 100
	else
		return random <= 40
	end
end

function DTActivityManager:getTriggerGoldChest()
	return self.triggerGoldChest
end

function DTActivityManager:getTriggerSilverChest()
	return self.triggerSilverChest
end

function DTActivityManager:completeLevel(levelId)
	self.triggerGoldChest = false
	self.triggerSilverChest = false
	if not self:isSupport() then return end
	if not LevelType:isMainLevel(levelId) and not LevelType:isHideLevel(levelId) then return end

	self.triggerGoldChest = self:getGoldChestChance()
	if self.triggerGoldChest then 
		DcUtil:activity{game_type = "share", game_name = "DoubleTwelve", category = "other", sub_category = "DoubleTwelve2016_get_box", t2=1}
		self:addGoldChestNum(1)
	else
		self.triggerSilverChest = self:getSilverChestChance()
		if self.triggerSilverChest then
			DcUtil:activity{game_type = "share", game_name = "DoubleTwelve", category = "other", sub_category = "DoubleTwelve2016_get_box", t2=2}
			self:addSilverChestNum(1)
		end
	end
end

function DTActivityManager:reset()
	self.triggerGoldChest = false
	self.triggerSilverChest = false
end
