-- local defaultGiftData = {
-- 	sender = {
-- 		profile = ProfileRef.new(),
-- 	},
-- 	rewards = {
-- 		{itemId = 10086, num = 1},
-- 		{itemId = 10086, num = 1},
-- 		{itemId = 10086, num = 1},
-- 		{itemId = 10086, num = 1},
-- 	}
-- id = 1,
-- }


local debugFlag = false

local FLGLogic = {}

local disabled_send = false
local disabled_recv = false

function FLGLogic:disableSend( ... )
	disabled_send = true
end

function FLGLogic:disableRecv( ... )
	disabled_recv = true
end

function FLGLogic:isDisabledSend( ... )
	return disabled_send
end

function FLGLogic:isDisabledRecv( ... )
	return disabled_recv
end

function FLGLogic:sendGift(rewardCfg, successCallback, failCallback, cancelCallback)
	local function __afterSuccess( evt )
		self:writeLastSentLevel(self:getGlobalMaxLevel())
		if successCallback then successCallback() end
	end
	if debugFlag then

		if math.random() < 0.5 then
			if failCallback then failCallback() end
			return
		end

		__afterSuccess()
		return
	end


	local itemId = rewardCfg.itemId
	local num = rewardCfg.num

	if not (itemId and num) then
		if failCallback then failCallback() end
		return
	end

	HttpBase:post('sendFullLevelGift', {
		itemId = itemId,
		num = num,
		levelId = self:getGlobalMaxLevel(),
	}, __afterSuccess, failCallback, cancelCallback)
end

function FLGLogic:hasGift( ... )
	return self:getNextAvaiableGift() ~= nil or debugFlag
end

function FLGLogic:recvGift( giftData, successCallback, failCallback, cancelCallback )

	local function __afterSuccess( evt )

		self:addRewards(giftData.rewards)
		self:afterRecvGift(giftData)

		if successCallback then successCallback() end
	end
	if debugFlag then
		if math.random() < 0.5 then
			if failCallback then failCallback() end
			return
		end

		__afterSuccess()
		return
	end

	HttpBase:post('getFullLevelReward', {
		id = tonumber(giftData.id) or 0,
	}, __afterSuccess, function ( evt )
		local errcode = evt and evt.data or nil
		if tostring(errcode) == '731032' then
			self:afterRecvGift(giftData)
			if failCallback then failCallback(evt, true) end
			return
		end
		if failCallback then failCallback(evt) end
	end, cancelCallback)
end


function FLGLogic:addRewards(rewardItems)
	rewardItems = rewardItems or {}
	if #rewardItems > 0 then
		UserManager:getInstance():addRewards(rewardItems, true)
        UserService:getInstance():addRewards(rewardItems)
	 	GainAndConsumeMgr.getInstance():gainMultiItems(DcFeatureType.kStarAndLevel, rewardItems, DcSourceType.kFullLevelGift)
	 	Localhost:getInstance():flushCurrentUserData()
	end
end

function FLGLogic:getNextAvaiableGift( ... )

	if self:isDisabledRecv() then
		return
	end

	local Misc = require 'zoo.quarterlyRankRace.utils.Misc'

	local jsonSZ = UserManager:getInstance():getFullLevelGiftData()
	local rawData = table.deserialize(jsonSZ) or {}
	local gifts = rawData.gifts or {}

	local _ , rawGiftData = next(gifts)

	--printx(61, table.tostring(gifts))

	if rawGiftData then
		return {
			id = rawGiftData.id,
			sender = {
				profile = ProfileRef.new(FriendManager.getInstance():getFriendInfo(rawGiftData.uid) or {}),
			},
			rewards = {{
				itemId = tonumber(rawGiftData.itemId) or 2,
				num = tonumber(rawGiftData.num) or 1,
			}}
		}
	end
end

function FLGLogic:afterRecvGift( giftData )
	local jsonSZ = UserManager:getInstance():getFullLevelGiftData()
	local rawData = table.deserialize(jsonSZ) or {}
	local gifts = rawData.gifts or {}
	gifts = table.filter(gifts, function (v)
		return tostring(v.id) ~= tostring(giftData.id)
	end)
	rawData.gifts = gifts

	jsonSZ = table.serialize(rawData)
	UserManager:getInstance():setFullLevelGiftData(jsonSZ)
end


function FLGLogic:writeCache( ... )
	local data_json = table.serialize(self.cache_data or {})
	local uid = '12345'
	if UserManager and UserManager:getInstance().user then
		uid = UserManager:getInstance().user.uid or '12345'
	end
	local key = "flg.logic.cache.data.2018.09.20." .. uid
	CCUserDefault:sharedUserDefault():setStringForKey(key, data_json)
	CCUserDefault:sharedUserDefault():flush()
end


function FLGLogic:readCache( ... )
	local uid = '12345'
	if UserManager and UserManager:getInstance().user then
		uid = UserManager:getInstance().user.uid or '12345'
	end
	local key = "flg.logic.cache.data.2018.09.20." .. uid
	local data_json = CCUserDefault:sharedUserDefault():getStringForKey(key)
	if data_json and data_json ~= "" then 
		local data = { }
		data = table.deserialize(data_json) or {}
		self.cache_data = data
	end

end

function FLGLogic:getCacheData(key)
	self:readCache()
	local cache_data = self.cache_data or {}
	return cache_data[key]
end

function FLGLogic:setCacheData( key, value )
	self.cache_data = self.cache_data or {}
	self.cache_data[key] = value
	self:writeCache()
end

function FLGLogic:popoutGifts( nextAction )
		
	local function __popoutOneGift( giftData, yesCallback, noCallback)
		local FLGRewardPanel = require 'zoo.panel.fullLevelGift.FLGRewardPanel'
		FLGRewardPanel:create(giftData):setCallback(yesCallback, noCallback):popoutPush()
	end

	local __popout
	__popout = function ( ... )

		local giftData = self:getNextAvaiableGift()
		if giftData or debugFlag then
			__popoutOneGift(giftData, __popout, nextAction)
		else
			if nextAction then nextAction() end
		end

	end

	__popout()
end

function FLGLogic:popoutOutbox( onFinish )
	local FLGSendPanel = require 'zoo.panel.fullLevelGift.FLGSendPanel'
	local panel = FLGSendPanel:create()
	panel:ad(PopoutEvents.kRemoveOnce, function ( ... )
		if onFinish then onFinish() end
	end)
	panel:popoutPush()
end


function FLGLogic:isEnabled( ... )
	return true
end

function FLGLogic:canSend( ... )
	

	if not self:isEnabled() then 
		return false
	end

	if self:isDisabledSend() then
		return false
	end

	if not UserManager:getInstance():isGlobalFullLevel() then
		return false
	end

	if self:getLastSentLevel() >= self:getGlobalMaxLevel() then
		return false
	end

	if FriendManager.getInstance():getFriendCount() <= 0 then
		return false
	end

	if self:getOutBoxPopoutCount() >= 2 then 
		return false
	end

	return true
end

function FLGLogic:onPopoutOutBox( ... )
	local count, key = self:getOutBoxPopoutCount()
	self:setCacheData(key, count + 1)
end

function FLGLogic:getOutBoxPopoutCount( ... )
	local key = 'level ..' .. self:getGlobalMaxLevel()
	local count = self:getCacheData(key) or 0
	count = tonumber(count) or 0
	return count, key
end

function FLGLogic:getLastSentLevel( ... )
	local jsonSZ = UserManager:getInstance():getFullLevelGiftData()
	local rawData = table.deserialize(jsonSZ) or {}
	return tonumber(rawData.lastMaxLevel or 0x7FFFFFFF) or 0x7FFFFFFF
end

function FLGLogic:writeLastSentLevel( sendLevel )
	local jsonSZ = UserManager:getInstance():getFullLevelGiftData()
	local rawData = table.deserialize(jsonSZ) or {}
	rawData.lastMaxLevel = sendLevel
	jsonSZ = table.serialize(rawData)
	UserManager:getInstance():setFullLevelGiftData(jsonSZ)
end

function FLGLogic:getGlobalMaxLevel( ... )
	return UserManager:getInstance():getGlobalMaxLevel() or 0x7FFFFFFF
end


return FLGLogic