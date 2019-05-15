local IOSGoldPage = require 'zoo.panel.happyCoinShop.IOSGoldPage'
local CustomVerticalTileLayout = require 'zoo.panel.happyCoinShop.CustomVerticalTileLayout'

local IOSGoldPage_NEW = class(IOSGoldPage)


function IOSGoldPage_NEW:create(iosProductInfo, builder, pageHeight)
	local instance = IOSGoldPage_NEW.new()
	instance:init(675, pageHeight - 90, true, true)
	instance:__buildUI(iosProductInfo, builder)
	return instance
end


function IOSGoldPage_NEW:__buildUI(iosProductInfo, builder)
	self:setIgnoreHorizontalMove(false)
	self.iosProductInfo = iosProductInfo
	self.builder = builder

	local verticallayout = CustomVerticalTileLayout:create(675)

	local flowLayout = FlowLayout:create(675, 8, 11)

	self.goldItems = {}

	local function __enableAllBuyBtn()
		table.each(self.goldItems, function(item)
			item:setBuyBtnEnabled(true)
		end)
	end

	local function __disableAllBuyBtn()
		table.each(self.goldItems, function(item)
			item:setBuyBtnEnabled(false)
		end)
	end

	for _, itemData in ipairs(self.iosProductInfo) do
		local ui = self.builder:buildGroup('newWindShop/Item')
		local uiItem = BuyHappyCoinItem:create(itemData, ui)
		table.insert(self.goldItems, uiItem)
		uiItem:setBuyCallback(
			__enableAllBuyBtn,
			__disableAllBuyBtn, 
			function()
				if self.onPaySuccess then
					self.onPaySuccess()
				end
			end,
			function(data, goldItem, errCode)
				if self.onPayFail then
					self.onPayFail(data, goldItem, errCode)
				end
			end
		)
		local item = ItemInLayout:create()
		item:setContent(uiItem)
		item:setWidth(315)
		item:setHeight(315)
		flowLayout:addItem(item)
	end

	flowLayout:__layout()


	local layoutItem = ItemInLayout:create()
	layoutItem:setContent(flowLayout)
	layoutItem:setHeight(flowLayout:getHeight())

	verticallayout:addItem(layoutItem)
	self:setContent(verticallayout)




	self:updateScrollableHeight()

	if not self:isInAppleVerification() then
		Notify:dispatch("StarBankEventCreateCoinItem", function ( ui )
			local item = ItemInLayout:create()
			item:setContent(ui)
			verticallayout:addItemAt(item, 1)
			self:updateScrollableHeight()
			--return removeItem function
			return function ( ... )
				if self.isDisposed then return end
				if item.isDisposed then return end
				if verticallayout.isDisposed then return end
				verticallayout:removeItemAt(item:getArrayIndex())
				verticallayout:__layout()
				self:updateScrollableHeight()
			end
		end)
		
		local promotionMgr = PromotionManager:getInstance()
		promotionMgr:onEnterHappyCoinShop(function(needDC)

			

			if self.isDisposed then return end
			if self:isInPromotion() then
				if self:shouldShowPromotion() then

					if needDC and self.source then
						DcUtil:UserTrack({category = "shop", sub_category = "wm_promotion_source", source = self.source})
					end

					local item
					local config = self:getPromotionConfig()
					local PromotionShopItemFactory = require 'zoo.panel.happyCoinShop.newPromotionItem.PromotionShopItemFactory'
					local PromotionItem = PromotionShopItemFactory:getInstance():getPromotionShopItem(config)

					local ui = PromotionItem:create(config, self.builder, function()
						if self.isDisposed then 
							if self.onPaySuccess then
								self.onPaySuccess()
							end
							return 
						end
						if item.isDisposed then 
							if self.onPaySuccess then
								self.onPaySuccess()
							end
							return 
						end
						if verticallayout.isDisposed then 
							if self.onPaySuccess then
								self.onPaySuccess()
							end
							return 
						end

						verticallayout:removeItemAt(item:getArrayIndex())
						verticallayout:__layout()
						self:updateScrollableHeight()
						self:updateContentViewArea()
						if self.promotionEndCallback then
							self.promotionEndCallback()
						end

						if self.onPaySuccess then
							self.onPaySuccess()
						end
					end, function()
						if self.isDisposed then return end
						if item.isDisposed then return end
						if verticallayout.isDisposed then return end
						verticallayout:removeItemAt(item:getArrayIndex())
						verticallayout:__layout()
						self:updateScrollableHeight()
						self:updateContentViewArea()
						if self.promotionEndCallback then
							self.promotionEndCallback()
						end
					end)

					ui:setSource(self.source)
					ui:setGoldPage(self)
					item = ItemInLayout:create()
					item:setContent(ui)

					if self:hadShowAnim() then
						verticallayout:addItemAt(item, 1)
					else
						verticallayout:addItemAt(item, 1, true)
						self:writeShowAnimTime()
					end

					self:updateScrollableHeight()
				end
			end
		end)
	end

	if self:isInAppleVerification() then
		local config = self:getVerificationPromotion()
		-- table.each(config, function(data)
		for _, data in ipairs(config) do
			local item

			local PromotionShopItemFactory = require 'zoo.panel.happyCoinShop.newPromotionItem.PromotionShopItemFactory'
			local PromotionItem = PromotionShopItemFactory:getInstance():getPromotionShopItem(data)

			local ui = PromotionItem:create(data, self.builder, function()
				if self.isDisposed then 
					if self.onPaySuccess then
						self.onPaySuccess()
					end
					return 
				end
				if item.isDisposed then 
					if self.onPaySuccess then
						self.onPaySuccess()
					end
					return 
				end
				if verticallayout.isDisposed then 
					if self.onPaySuccess then
						self.onPaySuccess()
					end
					return 
				end

						
				CommonTip:showTip('购买了促销礼品')
				verticallayout:removeItemAt(item:getArrayIndex())
				verticallayout:__layout()
				self:updateScrollableHeight()
				self:updateContentViewArea()
				if self.onPaySuccess then
					self.onPaySuccess()
				end
			end, function()
				if self.isDisposed then return end
				if item.isDisposed then return end
				if verticallayout.isDisposed then return end
				CommonTip:showTip('促销过期了')
				verticallayout:removeItemAt(item:getArrayIndex())
				verticallayout:__layout()
				self:updateScrollableHeight()
				self:updateContentViewArea()
			end)
			ui:setSource(self.source)
			ui:setGoldPage(self)
			item = ItemInLayout:create()
			item:setContent(ui)
			verticallayout:addItemAt(item, 1, true)
			self:updateScrollableHeight()
		-- end)
		end
	end
end

function IOSGoldPage_NEW:getVerificationPromotion()
	if MaintenanceManager:getInstance():isInReview() then
		return {
			-- {test = true, id = 140,time = 3600, goodsId = 645, productId = "com.happyelements.animal.gold.cn.114" },
			-- {test = true, id = 141,time = 3600, goodsId = 646, productId = "com.happyelements.animal.gold.cn.115" },
			-- -- {test = true, id = 142,time = 3600, goodsId = 647, productId = "com.happyelements.animal.gold.cn.116" },
			-- {test = true, id = 143,time = 3600, goodsId = 648, productId = "com.happyelements.animal.gold.cn.117" },
			-- {test = true, id = 144,time = 3600, goodsId = 649, productId = "com.happyelements.animal.gold.cn.118" },
			-- -- {test = true, id = 145,time = 3600, goodsId = 650, productId = "com.happyelements.animal.gold.cn.119" },

			-- {test = true, id = 146,time = 3600, goodsId = 651, productId = "com.happyelements.animal.gold.cn.120" },
			-- {test = true, id = 147,time = 3600, goodsId = 652, productId = "com.happyelements.animal.gold.cn.121" },
			-- -- {test = true, id = 148,time = 3600, goodsId = 653, productId = "com.happyelements.animal.gold.cn.122" },
			-- {test = true, id = 149,time = 3600, goodsId = 654, productId = "com.happyelements.animal.gold.cn.123" },
			-- {test = true, id = 150,time = 3600, goodsId = 655, productId = "com.happyelements.animal.gold.cn.124" },
			-- -- {test = true, id = 151,time = 3600, goodsId = 656, productId = "com.happyelements.animal.gold.cn.125" },
			-- {test = true, id = 152,time = 3600, goodsId = 657, productId = "com.happyelements.animal.gold.cn.126" },
			-- {test = true, id = 153,time = 3600, goodsId = 658, productId = "com.happyelements.animal.gold.cn.127" },
			-- -- {test = true, id = 154,time = 3600, goodsId = 659, productId = "com.happyelements.animal.gold.cn.128" },
			-- {test = true, id = 155,time = 3600, goodsId = 660, productId = "com.happyelements.animal.gold.cn.129" },

			-- {test = true, id = 156,time = 3600, goodsId = 661, productId = "com.happyelements.animal.gold.cn.130" },
			-- -- {test = true, id = 157,time = 3600, goodsId = 662, productId = "com.happyelements.animal.gold.cn.131" },
			-- {test = true, id = 158,time = 3600, goodsId = 663, productId = "com.happyelements.animal.gold.cn.132" },
			-- {test = true, id = 159,time = 3600, goodsId = 664, productId = "com.happyelements.animal.gold.cn.133" },
			-- -- {test = true, id = 160,time = 3600, goodsId = 665, productId = "com.happyelements.animal.gold.cn.134" },
			-- {test = true, id = 161,time = 3600, goodsId = 666, productId = "com.happyelements.animal.gold.cn.135" },
			-- {test = true, id = 162,time = 3600, goodsId = 667, productId = "com.happyelements.animal.gold.cn.136" },
		}
	else
		return {}
	end
end


function IOSGoldPage_NEW:getAnimKey( ... )
	local uid = '12345'
    if UserManager and UserManager:getInstance().user then
    	uid = UserManager:getInstance().user.uid or '12345'
    end

    local key = 'promotion.1.45.b.anim.ios.lasttime.'..uid
    return key
end

function IOSGoldPage_NEW:hadShowAnim( ... )
	local key = self:getAnimKey()

	local lastAnimTime = CCUserDefault:sharedUserDefault():getStringForKey(key) or ''
	lastAnimTime = tonumber(lastAnimTime) or 0

	local thisTriggerTime = PromotionManager:getInstance():getLastTriggerTime()
	thisTriggerTime = tonumber(thisTriggerTime) or 0

	return lastAnimTime >= thisTriggerTime
end

function IOSGoldPage_NEW:writeShowAnimTime( ... )
	local key = self:getAnimKey()
	local thisTriggerTime = PromotionManager:getInstance():getLastTriggerTime()
	CCUserDefault:sharedUserDefault():setStringForKey(key, tostring(thisTriggerTime))
end


-- function IOSGoldPage_NEW:getVerificationPromotion()
-- 	return {
-- 		-- [6] = {test = true, id = 56, time = 3600, goodsId = 445, productId = 'com.happyelements.animal.gold.cn.52'},
-- 		-- [5] = {test = true, id = 57, time = 3600, goodsId = 446, productId = 'com.happyelements.animal.gold.cn.53'},
-- 		-- [4] = {test = true, id = 58, time = 3600, goodsId = 447, productId = 'com.happyelements.animal.gold.cn.54'},
-- 		-- [3] = {test = true, id = 59, time = 3600, goodsId = 448, productId = 'com.happyelements.animal.gold.cn.55'},
-- 		-- [2] = {test = true, id = 60, time = 3600, goodsId = 449, productId = 'com.happyelements.animal.gold.cn.56'},
-- 		-- [1] = {test = true, id = 61, time = 3600, goodsId = 450, productId = 'com.happyelements.animal.gold.cn.57'},
		
-- 		-- [7] = {test = true, id = 62, time = 3600, goodsId = 451, productId = 'com.happyelements.animal.gold.cn.58', noGold=true},
-- 		-- [8] = {test = true, id = 63, time = 3600, goodsId = 452, productId = 'com.happyelements.animal.gold.cn.59', noGold=true},
-- 		-- [9] = {test = true, id = 64, time = 3600, goodsId = 453, productId = 'com.happyelements.animal.gold.cn.60', noGold=true},
-- 		-- [10] = {test = true, id = 65, time = 3600, goodsId = 454, productId = 'com.happyelements.animal.gold.cn.61', noGold=true},
-- 		-- [11] = {test = true, id = 66, time = 3600, goodsId = 455, productId = 'com.happyelements.animal.gold.cn.62', noGold=true},
-- 		-- [12] = {test = true, id = 67, time = 3600, goodsId = 456, productId = 'com.happyelements.animal.gold.cn.63', noGold=true},
-- 		-- [13] = {test = true, id = 68, time = 3600, goodsId = 457, productId = 'com.happyelements.animal.gold.cn.64', noGold=true},
-- 		-- [14] = {test = true, id = 69, time = 3600, goodsId = 458, productId = 'com.happyelements.animal.gold.cn.65', noGold=true},
-- 		-- [15] = {test = true, id = 70, time = 3600, goodsId = 459, productId = 'com.happyelements.animal.gold.cn.66', noGold=true},
-- 	}
-- end

return IOSGoldPage_NEW