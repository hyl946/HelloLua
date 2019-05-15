--=====================================================
-- DTAndroidBuyGoldItem
-- by zhijian.li
-- (c) copyright 2009 - 2016, www.happyelements.com
-- All Rights Reserved. 
--=====================================================
-- filename:  DTAndroidBuyGoldItem.lua
-- author:    zhijian.li
-- e-mail:    zhijian.li@happyelements.com
-- created:   2016/11/29
-- descrip:   2016双十二活动 商店风车币促销ui组件
--=====================================================

DTAndroidBuyGoldItem = class(BuyGoldItem)

function DTAndroidBuyGoldItem:create(itemData, successCallback, failCallback, marketPanel)
	local instance = DTAndroidBuyGoldItem.new()
	instance:loadRequiredResource(PanelConfigFiles.buy_gold_items) 
	instance:init(itemData, successCallback, failCallback, marketPanel)
	return instance
end

function DTAndroidBuyGoldItem:init(itemData, successCallback, failCallback, marketPanel)
	self.marketPanel = marketPanel
	BuyGoldItem.init(self, itemData, successCallback, failCallback)
end

function DTAndroidBuyGoldItem:afterBuySuccess()
	local context = self
	local function endCallback()
		if context.marketPanel and not context.marketPanel.isDisposed then 
			local dtPromotionBanner = context.marketPanel.dtPromotionBanner
			if dtPromotionBanner and dtPromotionBanner.goldPirce == context.itemData.iapPrice then 		
				DTPromotionManager.getInstance():resetProInfo()
				DTPromotionManager.getInstance():updateLastBuyTime()
				DTPromotionManager.getInstance():updateMarketIconShow(false)
				dtPromotionBanner:addReward()
			end
		end
	end
	DTPromotionManager.getInstance():sendServerCashBuy(self.itemData.iapPrice, endCallback)
end

