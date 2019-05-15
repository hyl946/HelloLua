local StoreItemData = require('zoo.panel.store.StoreItemData')

local PromotionLogic = {}

function PromotionLogic:loadData( onSuccess, onFail, source)
	local ret = {}
	local stMgr = StoreManager:getInstance()
	

	local promotionMgr = PromotionManager:getInstance()
	promotionMgr:onEnterHappyCoinShop(function(needDC)

		local ret = {}


		local promotionMgr = PromotionManager:getInstance()
		if promotionMgr:isInPromotion() then

			if needDC and source then
				DcUtil:UserTrack({category = "shop", sub_category = "wm_promotion_source", source = self.source})
			end

			local config
			local iapConfig

			if __IOS then
				config = {
					time = promotionMgr:getRestTime(),
					goodsId = promotionMgr:getGoodsId(),
					productId = promotionMgr:getProductId(),
					id = promotionMgr:getPromotionId()
				}

				local stMgr = _G.StoreManager:getInstance()
				iapConfig = stMgr:getIosProductInfoByGoodsId(config.goodsId)

			elseif __ANDROID then
				local promotion = promotionMgr:getPromotionInfo()
				config = {
					time = promotionMgr:getRestTime(),
					goodsId = promotionMgr:getGoodsId()
				}
			end


			if config then
				local data = StoreItemData.new(_G.StoreConfig.SGType.kPromotion)
				data:setGiftData(config.goodsId, iapConfig)
				data:setEndTime(promotionMgr:getDeadline())
				table.insert(ret, data)
			end
		end

		if onSuccess then onSuccess(ret) end
	end)
end

return PromotionLogic