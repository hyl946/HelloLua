local StoreItemData = require('zoo.panel.store.StoreItemData')

local ServerConfigGiftManager = class()

local instance

function ServerConfigGiftManager:getInstance( ... )
	if not instance then
		instance = ServerConfigGiftManager.new()
	end
	return instance
end

function ServerConfigGiftManager:loadData( onSuccess, onFail )
	self:pull(function ( ... )
		self:tryTriggerNewGift(function ( ... )
			local ret = {}

			for _, v in ipairs(self:getValidGifts() or {}) do
				local data = StoreItemData.new(_G.StoreConfig.SGType.kServerConfig)

				local iapConfig

				if __IOS then
					local stMgr = _G.StoreManager:getInstance()
					iapConfig = stMgr:getIosProductInfoByGoodsId(v.goodsId)
				end

				data:setGiftData(v.goodsId, iapConfig)
				if v.endTime > 0 then
					data:setEndTime(v.endTime/1000, v.needShowEndTime)
				end

				if v.buyLimit > 0 then
					data:setBuyLimit(v.buyLimit, v.buyCount)
				end

				data:setServerConfigGiftIdAndIcon(v.id, v.icon)

				table.insert(ret, data)

			end
			onSuccess(ret)
		end)
	end)
end

function ServerConfigGiftManager:pull( callback )
	if self._pulled then
		callback()
		return
	end

	HttpBase:syncPost('cashStorePromotionInfo', {}, function ( evt )
		
		local data = evt.data	

		local giftConfig = data.configs
		self:setGiftConfig(giftConfig)

		local rawGiftInfo = data.promotionMap or {}
		self:setGiftInfo(self:parseGiftInfo(rawGiftInfo))

		self._pulled = true

		callback()		

	end, callback, callback)
end

function ServerConfigGiftManager:tryTriggerNewGift( callback )

	if not self.cache then
		self.cache = {}
	end


	local allIds = {}

	for _, v in ipairs(self.giftConfig or {}) do
		table.insert(allIds, v.id)
	end

	allIds = table.filter(allIds, function ( id )
		return not table.find(self:getValidGifts(), function ( v )
			return v.id == id
		end)
	end)

	local now = Localhost:time()

	allIds = table.filter(allIds, function ( id )

		local configItem = table.find(self.giftConfig or {}, function ( v )
			return id == v.id
		end)

		local giftItem = table.find(self.giftInfo or {}, function ( v )
			return id == v.id
		end)

		if not configItem then return false end

		if configItem.endTime > 0 and configItem.endTime <= Localhost:time() then
			return false 
		end

		if configItem.minLevelId > UserManager:getInstance().user:getTopLevelId() then
			return false
		end

		if configItem.repeatPeriodDay > 0 then
			if giftItem and giftItem.endTime + configItem.repeatPeriodDay * 24 * 3600 * 1000 > now then
				return false
			end
		end

		return true
	end)

	allIds = table.filter(allIds, function ( id )
		return (not self.cache[id]) or self.cache[id] < now
	end)

	if #allIds > 0 then

		for _, id in ipairs(allIds) do
			if  _G.isLocalDevelopMode then
				self.cache[id] = now + 2 * 60 * 1000
			else
				self.cache[id] = now + 30 * 60 * 1000
			end
		end

		HttpBase:syncPost('triggerCashStorePromotion', {ids = allIds}, function ( evt )
			local data = evt.data
			local rawGiftInfo = data.successPromotions

			self:setGiftInfo(table.union(self.giftInfo or {}, self:parseGiftInfo(rawGiftInfo)))
			callback()
		end, callback, callback)
	else
		callback()
	end

end


function ServerConfigGiftManager:setGiftConfig( rawGiftConfig )
	self.giftConfig = rawGiftConfig
	for _, configItem in ipairs(self.giftConfig) do
		configItem.endTime = tonumber(configItem.endTime) or 0
		configItem.beginTime = tonumber(configItem.beginTime) or 0
		configItem.buyTimeoutHours = tonumber(configItem.buyTimeoutHours) or 0
	end
end


function ServerConfigGiftManager:setGiftInfo( giftInfo )
	self.giftInfo = giftInfo
end



function ServerConfigGiftManager:parseGiftInfo( rawGiftInfo )
	local giftInfo = {}
	for id, v in pairs(rawGiftInfo or {}) do
		table.insert(giftInfo, {
			id = tonumber(id),
			endTime = tonumber(v.occurEndTime),
			beginTime = tonumber(v.occurBeginTime),
			buyCount = tonumber(v.boughtCount),
		})
	end
	return giftInfo
end

function ServerConfigGiftManager:getValidGifts( ... )
	local ret = {}

	for _, giftItem in ipairs(self.giftInfo or {}) do
		local configItem = table.find(self.giftConfig or {}, function ( vv )
			return vv.id == giftItem.id
		end) 

		if configItem then
			local timeValid = (Localhost:time() < giftItem.endTime or giftItem.endTime <= 0) and Localhost:time() >= giftItem.beginTime
			local buyCountValid = configItem.buyLimit <= 0 or configItem.buyLimit > giftItem.buyCount
			if timeValid and buyCountValid then
				local goodsMeta = MetaManager:getInstance():getGoodMeta(configItem.goodsId)
				if goodsMeta then
					table.insert(ret, {
						id = giftItem.id,
						goodsId = configItem.goodsId,
						beginTime = giftItem.beginTime,
						endTime = giftItem.endTime,
						buyCount = giftItem.buyCount,
						buyLimit = configItem.buyLimit,
						icon = tonumber(configItem.icon) or 1,
						needShowEndTime = configItem.buyTimeoutHours > 0
					})
				end
			end
		end
	end
	return ret
end

function ServerConfigGiftManager:onBuySuccess( id )
	local giftItem = table.find(self.giftInfo or {}, function ( v )
		return v.id == id
	end)
	if giftItem then
		giftItem.buyCount = giftItem.buyCount + 1
		if not table.find(self:getValidGifts(), function ( v )
			return v.id == id
		end) then
			giftItem.endTime = Localhost:time()
			return true
		end
	end
end

return ServerConfigGiftManager