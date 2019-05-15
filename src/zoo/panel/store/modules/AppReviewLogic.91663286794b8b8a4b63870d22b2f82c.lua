local StoreItemData = require('zoo.panel.store.StoreItemData')

local AppReviewLogic = {}

function AppReviewLogic:loadData( onSuccess, onFail, source)
	local ret = {}
	local stMgr = StoreManager:getInstance()


	local ret = {}


	local appReviewConfig = self:getAppReviewConfig()

	for _, item in ipairs(appReviewConfig) do
		local config = {
			goodsId = item.goodsId,
			productId = item.productId,
			id = item.id
		}

		local stMgr = _G.StoreManager:getInstance()
		iapConfig = stMgr:getIosProductInfoByGoodsId(config.goodsId)
		local data = StoreItemData.new(_G.StoreConfig.SGType.kGift)
		data:setGiftData(config.goodsId, iapConfig)
		table.insert(ret, data)
	end

	if onSuccess then onSuccess(ret) end
end


function AppReviewLogic:getAppReviewConfig( ... )

	if (not __IOS) and (not __WIN32) then
		return {}
	end

	if MaintenanceManager:getInstance():isInReview() then
		return {
			-- {test = true, id = 127,time = 3600, goodsId = 635, productId = "com.happyelements.animal.gold.cn.108" },
			-- {test = true, id = 127,time = 3600, goodsId = 635, productId = "com.happyelements.animal.gold.cn.108" },
			-- {test = true, id = 127,time = 3600, goodsId = 635, productId = "com.happyelements.animal.gold.cn.108" },
		}
	else
		return {}
	end
end

return AppReviewLogic