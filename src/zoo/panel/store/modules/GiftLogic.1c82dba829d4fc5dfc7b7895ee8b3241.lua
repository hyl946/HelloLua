local StoreItemData = require('zoo.panel.store.StoreItemData')

local GiftLogic = {}

function GiftLogic:loadData( onSuccess, onFail)
	local ret = {}
	local stMgr = StoreManager:getInstance()
	for _, goodsId in ipairs(_G.StoreConfig.GiftGoodsIds) do

		local data = StoreItemData.new(_G.StoreConfig.SGType.kGift)
		if __IOS then
			local iapConfig = stMgr:getIosProductInfoByGoodsId(goodsId)
			if iapConfig then
				data:setGiftData(goodsId, iapConfig)
			end
		else
			data:setGiftData(goodsId)
		end
		table.insert(ret, data)
	end
	if onSuccess then onSuccess(ret) end
end

return GiftLogic