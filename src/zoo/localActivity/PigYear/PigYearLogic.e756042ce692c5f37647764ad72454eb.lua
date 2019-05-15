--add no use line

local ACT_ID = 1035
local ACT_SOURCE = 'FifthAnniversary/Config.lua'

local function parseTime( str,default )
    local pattern = "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)"
    local year, month, day, hour, min, sec = string.match(str,pattern)
    if year and month and day and hour and min and sec then
        return {
            year=tonumber(year),
            month=tonumber(month),
            day=tonumber(day),
            hour=tonumber(hour),
            min=tonumber(min),
            sec=tonumber(sec),
        }
    else
        return default
    end
end

local function Dc_log( category,subCategory,t1,t2,t3,t4, t5 )
	local params = {
		game_type = "stage",
		game_name = "5years",
		category = category,
		sub_category = subCategory,
		t1 = t1,
		t2 = t2,
		t3 = t3,
		t4 = t4,
		t5 = t5,
	}
	if _G.isLocalDevelopMode  then printx(100 , "Dc:log params= ",table.tostring(params)) end
	DcUtil:activity(params)
end


local PicYearMeta = require "zoo.localActivity.PigYear.PicYearMeta"
local PigYearLogic = {}

PigYearLogic.mainBeginTime = parseTime("2019-04-03 10:00:00")
PigYearLogic.mainEndTime = parseTime("2019-04-16 23:59:59")

function PigYearLogic:isActInMain_ClientTime( ... )
    return (Localhost:timeInSec() > os.time2(PigYearLogic.mainBeginTime) and Localhost:timeInSec() <= os.time2(PigYearLogic.mainEndTime))
end

function PigYearLogic:getActId( ... )
	return ACT_ID
end

function PigYearLogic:isActEnabled( ... )
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

function PigYearLogic:isActEnd( ... )
	local config
    for _,v in pairs(ActivityUtil:getActivitys()) do
        if v.source == ACT_SOURCE then
        	pcall(function ( ... )
	            config = require ('activity/'..v.source)
        	end)
            break
        end
    end
    local actEnd = (not config) or config.isActEnd()
    return actEnd
end

function PigYearLogic:isActInMain( ... )
	local config
    for _,v in pairs(ActivityUtil:getActivitys()) do
        if v.source == ACT_SOURCE then
        	pcall(function ( ... )
	            config = require ('activity/'..v.source)
        	end)
            break
        end
    end
    local ActInMain = config and config.isActInMain()
    return ActInMain
end

function PigYearLogic:hasInitedInServer( ... )
	return self.datas.serverInited2
end

local function second2day(ts)
	local utc8TimeOffset = 57600 -- (24 - 8) * 3600
	local oneDaySeconds = 86400 -- 24 * 3600
	local dayStart = ts - ((ts - utc8TimeOffset) % oneDaySeconds)
	return (dayStart + 8*3600)/24/3600
end

local function ms2day( ms )
	return second2day(ms/1000)
end

function PigYearLogic:__write( ... )


	local rawData = self:encode()
    -- printx(61, 'PigYearLogic:__write', 'rawData', table.tostring(rawData))
	self:writeACTData(rawData)
end

function PigYearLogic:write( ... )
	if not self._writeWorker then
		-- printx(61, 'PigYearLogic:write', 'create new write worker')
		self._writeWorker = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function ( ... )

			self:__write()
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self._writeWorker)
			self._writeWorker = nil

		end,1/60,false)
	else
		-- printx(61, 'PigYearLogic:write', 'there is already a write worker')
	end
end

function PigYearLogic:read( ... )
	self:decode(self:readACTData() or {}, true)
end

function PigYearLogic:writeACTData(data)
	Localhost:getInstance():writeToStorage(data, self:getCachePathname())
end

function PigYearLogic:readACTData()
	return Localhost:getInstance():readFromStorage( self:getCachePathname())
end

function PigYearLogic:getCachePathname( ... )

	local uid = '12345'
	if UserManager and UserManager:getInstance().user then
		uid = UserManager:getInstance().user.uid or '12345'
	end

	local cachePathname = 'Happy-New-Year-To-You-2' .. uid
	return cachePathname
end


function PigYearLogic:trySpeedUp( slotIndex, _success, failCallback, cancelCallback )

	local slotData = self:getSlotData(slotIndex)	
	if (not slotData.isSlotEmpty) and slotData.isInCDing then

		if self:howManySpeedUpCardINeed(slotIndex) <= self:getNumOfSpeedUpCard() then
	    	return PigYearLogic:speedUp(slotIndex, _success, failCallback, cancelCallback)
	    else
	    	return PigYearLogic:speedUpByMoney(slotIndex, function ( ... )
	    		if _success then _success() end
	    	end, failCallback, cancelCallback)
	    end
	end
end

function PigYearLogic:encode( ... )
	local data = {}
	for key, value in pairs(self.datas) do
		if string.starts(key, '_') then
		elseif type(value) == 'number' or type(value) == 'boolean' or type(value) == 'string' then
			data[key] = value
		elseif type(value) == 'table' and value.ctor == nil then
			data[key] = table.clone(value, true)
		end
	end
	return data
end

function PigYearLogic:decode( src, fromLocal)
	self:resetData()

	if not fromLocal then
		src = self:transformData(src)
	end

	for key, value in pairs(src or {}) do
		if string.starts(key, '_') then
		elseif type(value) == 'number' or type(value) == 'boolean' or type(value) == 'string' then
			self.datas[key] = value
		elseif type(value) == 'table' and value.ctor == nil then
			self.datas[key] = table.clone(value, true)
		end
	end


	if not fromLocal then
		self.datas.serverInited2 = true
	end

		
	self:formatData()

	self:_tagTS()
	self:_checkDailyData()

end

function PigYearLogic:formatData( ... )
	for _, v in pairs(self.datas.slots) do
		v.cdStartTS = tonumber(v.cdStartTS) or 0
		v.cdEndTS = tonumber(v.cdEndTS) or 0
	end

	local oldGemMap = self.datas.gemMap


	-- for _, field in ipairs({self.datas.gemMap, self.datas.luckyBags}) do

	-- 	local keys = {}

	-- 	for k, v in pairs(field) do
	-- 		table.insertIfNotExist(keys, k)
	-- 	end

	-- 	for _, k in ipairs(keys) do
	-- 		field[tonumber(k)] = field[tostring(k)]
	-- 		field[tostring(k)] = nil
	-- 	end
	-- end
end

function PigYearLogic:_tagTS( ... )
	if not self.datas.ts then
		self.datas.ts = Localhost:time()
	end
end

function PigYearLogic:initLogic( ... )
    self.logigInit = true
end

function PigYearLogic:bInitLogic( ... )
    return self.logigInit or false
end

function PigYearLogic:resetData( ... )
	self.datas = {}

	self.datas.ts = Localhost:time()

	self.datas.nextActLevelIndex = 1

	self.datas.gemMap = {}


	self.datas.numOfGoldCard = 0
	self.datas.numOfSilverCard = 0

	self.datas.luckyBags = {}
	self.datas.luckyBagLevel = 1

	self.datas.slots = {}

	for i = 1, PicYearMeta.SLOT_NUM do
		self.datas.slots[i] = {
			unlocked = false,
			cdStartTS = Localhost:time() - 10000,
			cdEndTS =   Localhost:time() + 111000000,
			multiple = 1,
		}
	end

	for i = 1, PicYearMeta.INIT_UNLOCKED_SLOT_NUM do
		self.datas.slots[i].unlocked = true
	end

	self.datas.slotLevel = 1

	self.datas.numOfSpeedCard = 0

	self.datas.allActLevelPassed = false

	self.datas.levelPlayedCount = {}

	self.datas.numOfGoldCard = 0
	self.datas.numOfSilverCard = 0


	self:_resetDailyData()

	-- self.datas.hadGotHF1 = false
	-- self.datas.hadGotHF2 = false

	self:_tagTS()
	self:_checkDailyData()

end

function PigYearLogic:_resetDailyData( ... )
	-- self.ddNumOfOpenedLuckyBag = 0
	-- self.ddActiveRewardedIds = {}
end

function PigYearLogic:_checkDailyData( ... )
	local ts = self.datas.ts
	if ts then
		local now = Localhost:time()
		local dayWhenGetData = ms2day(ts)
		local dayNow = ms2day(now)
		if dayNow > dayWhenGetData then
			self:_resetDailyData()
			self:_tagTS()
		end
	end
end


-- function PigYearLogic:getXXX( ... )
-- 	return self.datas.xxx
-- end

-- function PigYearLogic:setXXX( v)
-- 	self.datas.xxx = v
-- 	self:write()
-- end

function PigYearLogic:pullInfo( onSuccess, onFail, onCancel )
	HttpBase:syncPost('anniversary2019Info', {}, function ( evt )
		local data = evt.data or {}
		self:decode(data)
		self:write()
		if onSuccess then onSuccess() end
	end, onFail, onCancel)
end

function PigYearLogic:showErrorTip(evt)
	local errcode 
	if type(evt) == 'number' then
		errcode = evt
	elseif type(evt) == 'table' then
		errcode = evt.data or nil
	end
	if errcode then
		CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(errcode)), "negative")
	end
end

function PigYearLogic:transformData( data )
	return data
end

function PigYearLogic:openLuckBag( slotIndex, ... )

	self:_getReward('anniversary2019Reward', {extra = slotIndex - 1, type=7}, function ( rewards, evt )
		local data = self:transformData(evt.data)
		self.datas.luckyBags = data.luckyBags
		self.datas.slots = data.slots
		self:formatData()
		self:write()

		local rewardsMap = {}

		for _, v in ipairs(rewards) do
			rewardsMap[v.itemId] = v.num
		end

		Dc_log('other', '5years_open_cake', self:getLuckyBagLevel()
			, rewardsMap[PicYearMeta.ItemIDs.GEM_1] or 0
--			, rewardsMap[PicYearMeta.ItemIDs.GEM_2] or 0
			, rewardsMap[PicYearMeta.ItemIDs.GEM_3] or 0
			, rewardsMap[PicYearMeta.ItemIDs.GEM_4] or 0
		)

	end, ...)
end

function PigYearLogic:dc_when_try_cd( slotIndex )
	Dc_log('other', '5years_click_skip_cd', self:howManySpeedUpCardINeed(slotIndex))
end

function PigYearLogic:dc_when_cd( slotIndex, num, _speedType, scene )
	Dc_log('other', '5years_skip_cd'
		, num
		-- ,_speedType
		, scene
	)
end

function PigYearLogic:aquireSpeedUpCard( num )
	OpNotifyOffline.new(false):load(OpNotifyOfflineType.kHeadFrameUpdateShowTime, tostring(num))
end

local function table_equal(s, d)
    if type(s) ~= 'table' then
        return false
    end
    if type(d) ~= 'table' then
        return false
    end

    for k, v in pairs(d) do
        local v_ = s[k]
        if type(v) == "table" then
            return table_equal(v, v_)
        else
            if v ~= v_ then
                return false
            end
        end
    end
    for k, v in pairs(s) do
        if d[k] == nil then
            return false
        end
    end
    return true
end

function PigYearLogic:speedUp(slotIndex, successCallback, failCallback, cancelCallback)
	HttpBase:syncPost('anniversary2019Reward', {extra = slotIndex - 1, type = 8}, function ( evt )
		local data = self:transformData(evt.data)
		self.datas.luckyBags = data.luckyBags
		self.datas.slots = data.slots
		self.datas.numOfSpeedCard = data.numOfSpeedCard or 0
		self:formatData()
		self:write()
		if successCallback then successCallback() end
	end, function ( evt )
		self:showErrorTip(evt)
    	if failCallback then failCallback() end
	end, cancelCallback)
end

function PigYearLogic:_getReward( endPoint, params, successHandler, successCallback, failCallback, cancelCallback)
	HttpBase:syncPost(endPoint, params, function ( evt )
		if not evt.data then return end
		local rewards = evt.data.rewards or {}
		self:addRewards( rewards )


		local priority = {PicYearMeta.ItemIDs.GEM_2, PicYearMeta.ItemIDs.GEM_1, PicYearMeta.ItemIDs.GEM_3, PicYearMeta.ItemIDs.GEM_4}

		table.sort(rewards or {}, function ( v1, v2 )
			
			local p1 = table.indexOf(priority, v1.itemId)
			local p2 = table.indexOf(priority, v2.itemId)


			if p1 and p2 then
				return p1 < p2
			else
				return v1.itemId < v2.itemId
			end

    	end)



		if successHandler then successHandler(rewards, evt) end
		if successCallback then successCallback(rewards, evt) end
	end, function ( evt )
		self:showErrorTip(evt)
	    if failCallback then failCallback() end
	end, function ( ... )
		if cancelCallback then cancelCallback() end
	end)
end

function PigYearLogic:speedUpByMoney( slotIndex, successCallback, failCallback, cancelCallback )
	if self:isSlotUnlocked(slotIndex) and self:isInCDing(slotIndex) then
		local num = self:howManySpeedUpCardINeed(slotIndex)
		if not num then return false end

		local goodsId = PicYearMeta.speedUpGoodsId(slotIndex)
		self:_buyAndSyncInfoWithSyncErrorCheck2(goodsId, num, 'speedUp', false, successCallback, failCallback, cancelCallback)
	end
	return false
end


function PigYearLogic:buySlot( slotIndex, successCallback, failCallback, cancelCallback )

	if self:isSlotUnlocked(slotIndex) then return end

	local goodsId = PicYearMeta.GoodsId['kSlot' .. slotIndex]
	if goodsId then
		self:_buyAndSyncInfoWithSyncErrorCheck2(goodsId, 1, 'buySlot', true, function ( fakeSuccess )
			if fakeSuccess then
				CommonTip:showTip(localize('py.check.data.tip'))
				if cancelCallback then cancelCallback() end
			else
				if successCallback then successCallback() end
			end
		end, failCallback, cancelCallback, function ( ... )
			local _data = {}
			for i = 1, 8 do
				_data[i] = self.datas.slots[i].unlocked
			end
			return _data
		end)
		Dc_log('other', '5years_spread_space', slotIndex)
		return true
	end

	return false
end

function PigYearLogic:upgradeSlot(successCallback, failCallback, cancelCallback )

	if self:getSlotLevel() >= PicYearMeta.MAX_SLOT_LEVEL then return end

	local goodsId = PicYearMeta.GoodsId['kUpgradeSlot' .. self:getSlotLevel()]
	if goodsId then
		self:_buyAndSyncInfoWithSyncErrorCheck2(goodsId, 1, 'upgradeSlot', true, function ( fakeSuccess )
			if fakeSuccess then
				CommonTip:showTip(localize('py.check.data.tip'))
				if cancelCallback then cancelCallback() end
			else
				if successCallback then successCallback() end
			end
		end, failCallback, cancelCallback, function ( ... )
			return {
				self.datas.slotLevel,
			}
		end)
		return true
	end
	return false
end

-- function PigYearLogic:_buyAndSyncInfoWithSyncErrorCheck( goodsId, key, successCallback, failCallback, cancelCallback )
-- 	local function _do( ... )
-- 		local dcWindmillInfo = DCWindmillObject:create()
--         dcWindmillInfo:setGoodsId(goodsId)
--         local logic = WMBBuyItemLogic:create()
--         local buyLogic = BuyLogic:create(goodsId, MoneyType.kGold, DcFeatureType.kActivity, DcSourceType.kActPre .. ACT_ID)
--         logic:buy(
--         	goodsId, 
--         	1, 
--         	dcWindmillInfo, 
--         	buyLogic, 
--         	function ( ... )
--         		self:pullInfo(successCallback, function ( evt )
--         			self['lastBuySyncError:' .. key] = true
--         			self:showErrorTip(evt)
--         			if failCallback then failCallback() end
--         		end, function ( ... )
--         			self['lastBuySyncError:' .. key] = true
--         			if cancelCallback then cancelCallback() end
--         		end)
--         end, function ( evt )
--         	self:showErrorTip(evt)
--         	if failCallback then failCallback() end
--         end, cancelCallback, cancelCallback)

-- 	end

-- 	local function getImportantData( ... )
-- 		return {
-- 			table.clone(self.datas.slots),
-- 			table.clone(self.datas.luckyBags),
-- 			self.datas.slotLevel,
-- 			self.datas.luckyBagLevel,
-- 		}
-- 	end

-- 	if self['lastBuySyncError:' .. key] then
-- 		local oldImportantData = getImportantData()
-- 		self:pullInfo(function ( ... )
-- 			self['lastBuySyncError:' .. key] = true
	
-- 			local newImportantData = getImportantData()
-- 			if table_equal(oldImportantData, newImportantData) then
-- 				_do()
-- 			else
-- 				if successCallback then successCallback(true) end
-- 			end
-- 		end, function ( evt )
-- 			self:showErrorTip(evt)
-- 		end, cancelCallback)
-- 	else
-- 		_do()
-- 	end
-- end

-- local debug_counter = 1

function PigYearLogic:_buyAndSyncInfoWithSyncErrorCheck2( goodsId, num, key, needPreSync, successCallback, failCallback, cancelCallback , pGetImportantData)
	local function _do( ... )
		local dcWindmillInfo = DCWindmillObject:create()
        dcWindmillInfo:setGoodsId(goodsId)
        local logic = WMBBuyItemLogic:create()
        local buyLogic = BuyLogic:create(goodsId, MoneyType.kGold, DcFeatureType.kActivity, DcSourceType.kActPre .. ACT_ID)
        logic:buy(
        	goodsId, 
        	num, 
        	dcWindmillInfo, 
        	buyLogic, 
        	function ( ... )
        		self:pullInfo(successCallback, function ( evt )
        			self['lastBuySyncError:' .. key] = true
        			self:showErrorTip(evt)
        			if failCallback then failCallback() end
        		end, function ( ... )
        			self['lastBuySyncError:' .. key] = true
        			if cancelCallback then cancelCallback() end
        		end)
        end, function ( evt )
        	self:showErrorTip(evt)
        	if failCallback then failCallback() end
        end, cancelCallback, cancelCallback)

	end

	local function _getImportantData( ... )
		return {
			table.clone(self.datas.slots),
			table.clone(self.datas.luckyBags),
			self.datas.slotLevel,
			self.datas.luckyBagLevel,
			self.datas.numOfSpeedCard,
		}
	end

	local getImportantData = pGetImportantData or _getImportantData


	if self['lastBuySyncError:' .. key] or needPreSync then
		local oldImportantData = getImportantData()
		self:pullInfo(function ( ... )
			self['lastBuySyncError:' .. key] = true
			local newImportantData = getImportantData()
			-- debug_counter = debug_counter + 1
			-- if debug_counter % 2 == 0 then
			if table_equal(oldImportantData, newImportantData) then
				-- printx(61, 'table_equal', true)
				_do()
			else
				-- printx(61, 'table_equal', false, table.tostring(oldImportantData), table.tostring(newImportantData))
				-- printx(61, 'successCallback(true) ')
				if successCallback then successCallback(true) end
			end
		end, function ( evt )
			self:showErrorTip(evt)
		end, cancelCallback)
	else
		_do()
	end
end

function PigYearLogic:bagLevelUp( ... )
	self.datas.luckyBagLevel = self.datas.luckyBagLevel + 1
	self.datas.luckyBagLevel = math.min(self.datas.luckyBagLevel, PicYearMeta.MAX_BAG_LEVEL)
	self:write()

	Dc_log('reward', 'SpringFestival2019_bag_update', self.datas.luckyBagLevel)
end

function PigYearLogic:addGem( itemId, num )
	if not self.datas.gemMap[tostring(itemId)] then
		self.datas.gemMap[tostring(itemId)] = 0
	end
	self.datas.gemMap[tostring(itemId)] = self.datas.gemMap[tostring(itemId)] + num
	self.datas.gemMap[tostring(itemId)] = math.max(self.datas.gemMap[tostring(itemId)], 0)

	self:write()
end

function PigYearLogic:addGemByIndex( index, num )
	-- body
	local itemId = PicYearMeta.ItemIDs['GEM_' .. index]
	self:addGem(itemId, num)
end

function PigYearLogic:addSpeedUpCard(num)
	self.datas.numOfSpeedCard = self.datas.numOfSpeedCard + num
	self.datas.numOfSpeedCard = math.max(0, self.datas.numOfSpeedCard)
	self:write()
end

function PigYearLogic:addRewards( rewardItems, model )
	local hasItemRewards = false
	for _,reward in pairs(rewardItems or {}) do
		if reward.itemId == PicYearMeta.ItemIDs.GEM_1 then
			self:addGem(reward.itemId, reward.num)
			if model then
				model:notify(model.Events.kGemChange)
			end
		elseif reward.itemId == PicYearMeta.ItemIDs.GEM_2 then
			self:addGem(reward.itemId, reward.num)
			if model then
				model:notify(model.Events.kGemChange)
			end
		elseif reward.itemId == PicYearMeta.ItemIDs.GEM_3 then
			self:addGem(reward.itemId, reward.num)
			if model then
				model:notify(model.Events.kGemChange)
			end
		elseif reward.itemId == PicYearMeta.ItemIDs.GEM_4 then
			self:addGem(reward.itemId, reward.num)
			if model then
				model:notify(model.Events.kGemChange)
			end
		elseif reward.itemId == PicYearMeta.ItemIDs.SPEEDUP_CARD then
			self:addSpeedUpCard(reward.num)
		elseif reward.itemId == PicYearMeta.ItemIDs.BAG_LEVELUP then
			self:bagLevelUp()
			if model then
				model:notify(model.Events.kBagLevelUp)
			end
		elseif reward.itemId == PicYearMeta.ItemIDs.GOLD then
			self.datas.numOfGoldCard = self.datas.numOfGoldCard + reward.num
			self:write()

		elseif reward.itemId == PicYearMeta.ItemIDs.SILVER then
			self.datas.numOfSilverCard = self.datas.numOfSilverCard + reward.num
			self:write()
		elseif reward.itemId == PicYearMeta.ItemIDs.LUCKY_BAG_M_1 then
			self:addLuckyBag(1, reward.num)
		elseif reward.itemId == PicYearMeta.ItemIDs.LUCKY_BAG_M_2 then
			self:addLuckyBag(2, reward.num)
		elseif reward.itemId == PicYearMeta.ItemIDs.LUCKY_BAG_M_3 then
			self:addLuckyBag(3, reward.num)
		elseif reward.itemId == PicYearMeta.ItemIDs.LUCKY_BAG_M_4 then
			self:addLuckyBag(4, reward.num)
		else --普通道具
			if UserManager.addRewardsWithDc and type(UserManager.addRewardsWithDc) == "function" then
				UserManager:getInstance():addRewardsWithDc({reward}, { source = "activity", activityId = self:getActId() })
				hasItemRewards = true
			else
				GainAndConsumeMgr.getInstance():gainItem(DcFeatureType.kActivity, reward.itemId, reward.num, DcSourceType.kActPre..self:getActId(), nil, self:getActId())
				UserManager:getInstance():addReward(reward, true)
				Localhost:getInstance():flushCurrentUserData()
			end
			UserService:getInstance():addRewards({reward})
		end
	end


	local rewards = table.clone(rewardItems, true)
	local onlyInfiniteBottle = table.filter(rewards, function ( tRewardItem )
		return tRewardItem.itemId == ItemType.INFINITE_ENERGY_BOTTLE_ONE_MINUTE
	end)

	local tInfiniteRewardItem = onlyInfiniteBottle[1] --如果有 那么应该仅有一项
	if tInfiniteRewardItem then
		local logic = UseEnergyBottleLogic:create(tInfiniteRewardItem.itemId, DcFeatureType.kActivity, DcSourceType.kActPre..self:getActId())
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


	self:updateIcon()

end

function PigYearLogic:getLuckyBagLevel( ... )
	return self.datas.luckyBagLevel or 1
end

function PigYearLogic:getSlotLevel( ... )
	return self.datas.slotLevel or 1
end

function PigYearLogic:getLuckyBagNum( multiple, bAddCDNum )

    if bAddCDNum == nil then bAddCDNum = false end

	local numInWait = 0
	for k, v in pairs(self.datas.luckyBags) do
		if (not multiple) or multiple == tonumber(k) then
			numInWait = numInWait + v
		end
	end

	local numInCd = 0

    if bAddCDNum then
        for i = 1, PicYearMeta.SLOT_NUM do
	        if not self:isSlotEmpty(i) then
	 	        if (not multiple) or multiple == self:getSlotData(i).multiple then
	 		        numInCd = numInCd + 1
	 	        end
	        end
	    end	
    end

	return numInCd + numInWait
end

function PigYearLogic:isSlotUnlocked( slotIndex )
	return self.datas.slots[slotIndex].unlocked
end

function PigYearLogic:isSlotEmpty( slotIndex )
	return self.datas.slots[slotIndex].cdStartTS <= 0
end

function PigYearLogic:isInCDing( slotIndex )
	return (not self:isSlotEmpty(slotIndex)) and self.datas.slots[slotIndex].cdEndTS > Localhost:time()
end

function PigYearLogic:isCDFinished( slotIndex )
	return (not self:isSlotEmpty(slotIndex)) and (not self:isInCDing(slotIndex))
end

function PigYearLogic:getGemNums( ... )
	return {
		self.datas.gemMap[tostring(PicYearMeta.ItemIDs.GEM_1)] or 0,
		self.datas.gemMap[tostring(PicYearMeta.ItemIDs.GEM_2)] or 0,
		self.datas.gemMap[tostring(PicYearMeta.ItemIDs.GEM_3)] or 0,
		self.datas.gemMap[tostring(PicYearMeta.ItemIDs.GEM_4)] or 0,
	}
end

function PigYearLogic:getSlotData( slotIndex )
	return {
		unlocked = self.datas.slots[slotIndex].unlocked,
		cdStartTS = self.datas.slots[slotIndex].cdStartTS,
		cdEndTS = self.datas.slots[slotIndex].cdEndTS,
		multiple = self.datas.slots[slotIndex].multiple,
		isSlotEmpty = self:isSlotEmpty(slotIndex),
		isCDFinished = self:isCDFinished(slotIndex),
		isInCDing = self:isInCDing(slotIndex),
	}
end

function PigYearLogic:getUnlockedSlotNum( ... )
	for i = 1, PicYearMeta.SLOT_NUM do
		if not self:isSlotUnlocked(i) then
			return i - 1
		end
	end
	return PicYearMeta.SLOT_NUM
end

function PigYearLogic:isAllActLevelPassed()
	return self.datas.allActLevelPassed
end

function PigYearLogic:getNextActLevelIndex( ... )
	return self.datas.nextActLevelIndex
end

function PigYearLogic:incNextActLevelIndex( ... )
	self.datas.nextActLevelIndex = self.datas.nextActLevelIndex + 1
	if self.datas.nextActLevelIndex >= PicYearMeta.ACT_LEVEL_NUM + 1 then
		self.datas.nextActLevelIndex = 1
		self.datas.allActLevelPassed = true
	end

    --打完一轮改推荐关卡的时候把新推荐的打关次数清0
    if self.datas.allActLevelPassed then
        local levelID = self.datas.nextActLevelIndex + LevelConstans.SPRINGFESTIVAL2019_LEVEL_ID_START - 1
        self.datas.levelPlayedCount[tostring(levelID)] = 0
    end
			
    self:write()
end

function PigYearLogic:howManySpeedUpCardINeed( slotIndex )

	if self:isSlotUnlocked(slotIndex) and self:isInCDing(slotIndex) then

		local unit = PicYearMeta.SPEED_UP_UNIT
		local goodsId = PicYearMeta.GoodsId.kSpeedUp
		local slotData = self.datas.slots[slotIndex]
		local restTime = slotData.cdEndTS - Localhost:time()

		-- printx(61, 'restTime', restTime)
		-- printx(61, 'unit', unit)
		
		local num = 0
		local accTime = 0
		while accTime < restTime do
			accTime = accTime + unit
			num = num + 1
		end

		return num
	else
		return 0
	end
end

function PigYearLogic:getNumOfSpeedUpCard( ... )
	return self.datas.numOfSpeedCard
end

function PigYearLogic:isFullLevel( ... )
	return UserManager:getInstance():hasPassedLevelEx(PicYearMeta.FULL_LEVEL)
end

function PigYearLogic:isFullStar( ... )
    local ret = false
    pcall(function ( ... )
	    local maxLevel = NewAreaOpenMgr.getInstance():getLocalTopLevel()

	    printx(61, 'maxLevel', maxLevel)

	    local totalStar = LevelMapManager.getInstance():getTotalStar(maxLevel)
	    local totalHiddenStar = MetaModel.sharedInstance():getFullStarInHiddenRegionByMainLevelId(maxLevel-1)

	    local curStar = UserManager:getInstance().user:getStar()
	    local curHiddenStar = UserManager:getInstance().user:getHideStar()
	    ret = curStar + curHiddenStar >= totalStar + totalHiddenStar

	    printx(61, 'curStar + curHiddenStar', curStar , curHiddenStar, totalStar , totalHiddenStar)

    end)
    return ret
end

function PigYearLogic:hasAllActLevelPassed( ... )
	return self.datas.allActLevelPassed
end

function PigYearLogic:afterStartLevel( levelId )
    local count = self.datas.levelPlayedCount[tostring(levelId)] or 0
	count = count + 1
	self.datas.levelPlayedCount[tostring(levelId)] = count

     self:write()
end

--这个函数没用了。
function PigYearLogic:afterPassLevel( levelId, passed )

	local count = self.datas.levelPlayedCount[tostring(levelId)] or 0
	count = count + 1
	self.datas.levelPlayedCount[tostring(levelId)] = count

	if passed then
	    local levelType = LevelType:getLevelTypeByLevelId(levelId)
	    if levelType == GameLevelType.kMainLevel or levelType == GameLevelType.kHiddenLevel then

	    else
	    	-- if levelId == self:actLevelIndex2Id(self.datas.nextActLevelIndex) then
		    -- 	self.datas.nextActLevelIndex = self.datas.nextActLevelIndex + 1
		    -- 	if self.datas.nextActLevelIndex > PicYearMeta.ACT_LEVEL_NUM then
		    -- 		self.datas.nextActLevelIndex = 1
		    -- 		self.datas.allActLevelPassed = true
		    -- 	end
		    -- end
	    end
	end

    self:write()
end
 
function PigYearLogic:getLevelPlayedCount( levelId )
	return self.datas.levelPlayedCount[tostring(levelId)] or 0
end

function PigYearLogic:addGold( num )
	self.datas.numOfGoldCard = self.datas.numOfGoldCard + num
end

function PigYearLogic:addSilver( num )
	self.datas.numOfSilverCard = self.datas.numOfSilverCard + num
end

function PigYearLogic:actLevelIndex2Id( index )
	return PicYearMeta.ACT_LEVEL_RANGE[1] + index - 1
end


--过关之后加奖励
-- local rewards = {
-- 	{itemId = PicYearMeta.ItemIDs.LUCKY_BAG_M_1, num = 3}	,  --1 倍福袋
-- 	{itemId = PicYearMeta.ItemIDs.LUCKY_BAG_M_2, num = 3}	,  --2 倍福袋
-- 	{itemId = PicYearMeta.ItemIDs.LUCKY_BAG_M_3, num = 3}	,  --3 倍福袋
-- 	{itemId = PicYearMeta.ItemIDs.LUCKY_BAG_M_4, num = 3}	,  --4 倍福袋
-- 	{itemId = PicYearMeta.ItemIDs.GOLD, num = 3}	,  --4 倍福袋
-- 	{itemId = PicYearMeta.ItemIDs.SILVER, num = 3}	,  --4 倍福袋
-- 	{itemId = PicYearMeta.ItemIDs.SPEEDUP_CARD, num = 3}	,  --4 倍福袋
-- }

function PigYearLogic:addPassLevelRewards(rewards)

	-- printx(61, 'addPassLevelRewards', table.tostring(rewards))
	-- body
	self:addRewards(rewards)

	
	-- self.changeContext = {
	-- 	rewards = table.clone(rewards, true)
	-- }
end

function PigYearLogic:getChangeContext( ... )
	local ret = self.changeContext
	self.changeContext = nil
	return ret
end

-- function PigYearLogic:tryEnterAllSlot( ... )
-- 	-- body
-- 	local safeCounter = 8
-- 	while self:tryEnterSlot() and safeCounter > 0 do 
-- 		safeCounter = safeCounter - 1
-- 	end

-- end


function PigYearLogic:getActivityIcon( ... )
	for k,v in pairs(HomeScene:sharedInstance().activityIconButtons or {}) do
		if v.source == ACT_SOURCE then
			return v
		end
	end
end

function PigYearLogic:addLuckyBag( multiple, num )
	-- body
	local oldNum = self:getLuckyBagNum(multiple)
	self.datas.luckyBags[tostring(multiple)] = math.max(0, oldNum + num)
	self:write()
end


function PigYearLogic:_tryEnterSlot( ... )
	-- body
	local multiple

	for i = PicYearMeta.MAX_BAG_MULTIPLE, 1, -1 do
		if self:getLuckyBagNum(i) > 0 then
			multiple = i
			break
		end
	end

	if multiple then
		for i = 1, PicYearMeta.SLOT_NUM do
			if self:isSlotUnlocked(i) and self:isSlotEmpty(i) then
				self:addLuckyBag(multiple, -1)
				self.datas.slots[i].cdStartTS = Localhost:time()
				self.datas.slots[i].cdEndTS = self.datas.slots[i].cdStartTS + PicYearMeta.SLOT_CD[math.clamp(self:getSlotLevel(), 1, 4)]
				self.datas.slots[i].multiple = multiple
				self:write()
				return i
			end
		end
	end

	return false
end

function PigYearLogic:tryEnterSlot( ... )
	-- body
	local lastRet = self:_tryEnterSlot()

	while lastRet ~= false do
		local ret = self:_tryEnterSlot()
		if ret == false then
			break
		end
		lastRet = ret
	end

	return lastRet
end

function PigYearLogic:tryEnterSlotOne( ... )
	-- body
	local lastRet = self:_tryEnterSlot()
	return lastRet
end

function PigYearLogic:getTicketDoubleNum( levelID )

    --这里不包含刷星关 只计算主线top 活动 关卡

    local ticketNum = 0
    local doubleNum = 0

    if LevelType:isMainLevel(levelID) or LevelType:isHideLevel(levelID) then
        if levelID >=0 and levelID <= 199 then
            doubleNum = 2
            ticketNum = 1
        elseif levelID >=200 and levelID <= 799 then
            doubleNum = 3
            ticketNum = 2
        elseif levelID >=800 then
            doubleNum = 4
            ticketNum = 3
        end
    elseif LevelType:isSpringFestival2019Level(levelID) then
        doubleNum = 4
        ticketNum = 3
    end

    -- printx(61, 'levelID', levelID, doubleNum)

    return doubleNum, ticketNum
end

function PigYearLogic:hasRewards()
	local t1 = self:hasAnyLuckDrawNum()  --转盘次数
	local t4 = self:hasAnyLuckyBagCDFinished()
	return t1 or t4
end
function PigYearLogic:hasAnyLuckDrawNum()
	local leftNum = math.modf( self.datas.numOfSilverCard / 5 )  + math.modf( self.datas.numOfGoldCard / 3 ) 
	return leftNum > 0 
end
function PigYearLogic:hasAnyLuckyBagCDFinished( ... )


	for i = 1, PicYearMeta.SLOT_NUM do
		local slotData = self:getSlotData(i)
		if slotData.unlocked and (not slotData.isSlotEmpty) and slotData.isCDFinished then
			return true
		end
	end	

end

function PigYearLogic:updateIcon()
	-- if self:isActivitySupport() then
	-- HomeScene:sharedInstance():buildActivityButton()
	-- end
	if self:isActEnabled() then
		local hasRewards = self:hasRewards()
		if ActivityUtil and ActivityUtil.setRewardMark and hasRewards then
			ActivityUtil:setRewardMark(ACT_SOURCE, hasRewards)
		end

	end


end

function PigYearLogic:getGuideAnimPathname( ... )
	local uid = '12345'
	if UserManager and UserManager:getInstance().user then
		uid = UserManager:getInstance().user.uid or '12345'
	end

	local cachePathname = 'spring2019' .. uid
	return cachePathname
end

function PigYearLogic:getShowSkillGuideType()
    local key = self:getGuideAnimPathname()
    return CCUserDefault:sharedUserDefault():getBoolForKey(key, false)
end

function PigYearLogic:setShowSkillGuideType()
    local key = self:getGuideAnimPathname()
    CCUserDefault:sharedUserDefault():setBoolForKey(key, true)
end

function PigYearLogic:setNeedShowNextLevel( bShow )
    self.bNeedShowNextLevel = bShow
end

function PigYearLogic:getNeedShowNextLevel( )
    return self.bNeedShowNextLevel
end

return PigYearLogic