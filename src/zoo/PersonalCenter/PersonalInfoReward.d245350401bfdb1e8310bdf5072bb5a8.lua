local function defineHttp( name )
	local http = class(HttpBase)
	function http:load( params )
		if not kUserLogin then return self:onLoadingError(ZooErrorCode.kNotLoginError) end
		local context = self
		local loadCallback = function(endpoint, data, err)
			if err then
				he_log_info(name .. " error: " .. err)
				context:onLoadingError(err)
			else
				he_log_info(name .. " success !")
				
				context:onLoadingComplete(data)
			end
		end

		self.transponder:call(name, params or {}, loadCallback, rpc.SendingPriority.kHigh, false)
	end
	return http
end


local GetInfoHttp = defineHttp("getActivityInfo")








local ReceiveRewardHttp = class(HttpBase)
function ReceiveRewardHttp:load(rewardId)
	local params = {
		actId = 1009,
		rewardId = rewardId,
	}
	local context = self
	if NetworkConfig.useLocalServer then
		UserService.getInstance():cacheHttp('activityReward', params)

		if NetworkConfig.writeLocalDataStorage then 
			Localhost:getInstance():flushCurrentUserData()
		else 
			if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end 
		end
		context:onLoadingComplete()
		return
	end
end




local PersonalInfoReward = {}
local synced = false

PersonalInfoReward.data = {}
PersonalInfoReward.eventDispatcher = EventDispatcher.new()

PersonalInfoReward.Events = {
	kStatusChange = 'PersonalInfoReward.Events.kStatusChange',
}

local callbackList = {}

function PersonalInfoReward:canTrigger( ... )
	-- 奖励的道具类型作废，关闭此功能
	if 1 then 
		return false
	end

	if not self:hadPlayMainLevel() then
		return false
	end

	local topLevel = 1
	if UserManager.getInstance().user then
		topLevel = UserManager.getInstance().user:getTopLevelId()
	end

	if topLevel < 40 then
		return false, 1
	end

	if PersonalCenterManager:isInfoComplete() then
		return false, 2
	end

	local switch = MaintenanceManager:getInstance():getMaintenanceByKey("IdReward")
	if not switch then return false,3 end
	if not switch.enable then return false,4 end

	local extra = switch.extra or ''
	local version, rewardId, itemId, num = string.match(extra, '(%d+):(%d+):(%d+),(%d+)')

	if not version then return false,5 end
	if not rewardId then return false,6 end
	if not itemId then return false,7 end
	if not num then return false,8 end

	if self.data.curVersion and self.data.curVersion >= tonumber(version) then
		return false,9
	end

	if self.data.rewarded then
		return false,10
	end

	self.switch = {
		version = version,
		rewardId = rewardId,
		itemId = itemId,
		num = num,
	}


	return true
end

function PersonalInfoReward:trigger( onSuccess ,onFail )
	
	if not self.switch then
		return
	end	

	self.data = {
		curVersion = tonumber(self.switch.version),
		rewarded = false,
		expireTime = Localhost:time() + 24*3600*1000,
		rewardId = tonumber(self.switch.rewardId),
		itemId = tonumber(self.switch.itemId),
		num = tonumber(self.switch.num),
	}

	self:writeCache()


	local http = OpNotifyOffline.new(false)
	http:ad(Events.kComplete, function ( ... )
		self.eventDispatcher:dp(Event.new(self.Events.kStatusChange))
		if onSuccess then
			onSuccess()
		end
	end)
	local function onRequestError( )
		if onFail then
			onFail()
		end
	end 
	http:addEventListener(Events.kError, onRequestError)

    http:load(OpNotifyOfflineType.kPersonalInfoRewardTrigger, table.serialize(self.data))

end

function PersonalInfoReward:isInRewardTime( ... )
	-- 奖励的道具类型作废，关闭此功能
	return false
	-- return self.data.expireTime and Localhost:time() < self.data.expireTime and (not self.data.rewarded)
end

function PersonalInfoReward:getReward( ... )
	return {itemId=self.data.itemId, num =self.data.num}
end

local function addRewards(rewardItems)
	rewardItems = rewardItems or {}
	if #rewardItems > 0 then
		UserManager:getInstance():addRewards(rewardItems, true)
		UserService:getInstance():addRewards(rewardItems)
		GainAndConsumeMgr.getInstance():gainMultiItems(DcFeatureType.kTrunk, rewardItems, DcSourceType.kPersonalInfoReward)
		Localhost:getInstance():flushCurrentUserData()
	end
end

function PersonalInfoReward:receiveReward( onSuccess )

	local http = ReceiveRewardHttp.new(false)
	http:ad(Events.kComplete, function ( ... )
		addRewards({{itemId = self.data.itemId, num = self.data.num}})
		self.data.rewarded = true
		self:writeCache()
		if onSuccess then
			onSuccess()
		end
		local t1 = tostring(self.data.itemId) .. '_' .. tostring(self.data.num)
    	DcUtil:UserTrack({category='ui', sub_category="my_card_reward", t1 = t1}, true)
		self.eventDispatcher:dp(Event.new(self.Events.kStatusChange))
	end)
	http:load(self.data.rewardId)
end

function PersonalInfoReward:getEndTimeInSec( ... )
	return self.data.expireTime/1000 or 0
end

function PersonalInfoReward:getInfoAsync(callback)
	if synced then
		if callback then
			callback()
		end
	else
		local http = GetInfoHttp.new()
		http:ad(Events.kComplete, function ( evt )
			self.data = table.deserialize(evt.data.info) or {}
			self:writeCache()
			synced = true
			for _, v in ipairs(callbackList) do
				if v then
					v()
				end
			end
			callbackList = {}
		end)
		http:ad(Events.kError, function ( ... )
			synced = true
			for _, v in ipairs(callbackList) do
				if v then
					v()
				end
			end
			callbackList = {}
		end)
		table.insert(callbackList, callback)
		http:syncLoad({actId = 1009})
	end
end


function PersonalInfoReward:readCache( ... )
	local uid = '12345'
	if UserManager and UserManager:getInstance().user then
		uid = UserManager:getInstance().user.uid or '12345'
	end
	local key = "personal.info.edit.reward.info." .. uid
	local data_json = CCUserDefault:sharedUserDefault():getStringForKey(key)
	if data_json and data_json ~= "" then 
		local data = { }
		data = table.deserialize(data_json) or {}
		self.data = data
	end
end

function PersonalInfoReward:init( ... )
	self:readCache()

	GlobalEventDispatcher:getInstance():addEventListener(kGlobalEvents.kReturnFromGamePlay, function ( ... )
		self.played = true
	end)

end

function PersonalInfoReward:hadPlayMainLevel( ... )
	return self.played
end

function PersonalInfoReward:writeCache( ... )
	local data_json = table.serialize(self.data or {})
	local uid = '12345'
	if UserManager and UserManager:getInstance().user then
		uid = UserManager:getInstance().user.uid or '12345'
	end
	local key = "personal.info.edit.reward.info." .. uid
	CCUserDefault:sharedUserDefault():setStringForKey(key, data_json)

	CCUserDefault:sharedUserDefault():flush()
	Localhost:flushCurrentUserData()
	
end


return PersonalInfoReward