require 'zoo.panel.happyCoinShop.PromotionFactory'

local IOSGoldPage = class(VerticalScrollable)

function IOSGoldPage:create(iosProductInfo, builder, pageHeight)
	local instance = IOSGoldPage.new()
	instance:init(675, pageHeight - 90, true, true)
	instance:__buildUI(iosProductInfo, builder)
	return instance
end

function IOSGoldPage:ctor()
end

function IOSGoldPage:__buildUI(iosProductInfo, builder)
	self:setIgnoreHorizontalMove(false)
	self.iosProductInfo = iosProductInfo
	self.builder = builder

	local layout = FlowLayout:create(675, 8, 11)


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
		layout:addItem(item)
	end

	layout:__layout()
	self:setContent(layout)

	self:updateScrollableHeight()

	if not self:isInAppleVerification() then
		local promotionMgr = PromotionManager:getInstance()
		promotionMgr:onEnterHappyCoinShop(function()
			if self.isDisposed then return end
			if self:isInPromotion() then
				if self:shouldShowPromotion() then
					local item
					local config = self:getPromotionConfig()
					local PromotionItem = require 'zoo.panel.happyCoinShop.PromotionItem'
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
						if layout.isDisposed then 
							if self.onPaySuccess then
								self.onPaySuccess()
							end
							return 
						end


						layout:removeItemAt(item:getArrayIndex())
						layout:__layout()
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
						if layout.isDisposed then return end
						layout:removeItemAt(item:getArrayIndex())
						layout:__layout()
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
					layout:addItemAt(item, 1)
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
			local PromotionItem = require 'zoo.panel.happyCoinShop.PromotionItem'
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
				if layout.isDisposed then 
					if self.onPaySuccess then
						self.onPaySuccess()
					end
					return 
				end

				CommonTip:showTip('购买了促销礼品')
				layout:removeItemAt(item:getArrayIndex())
				layout:__layout()
				self:updateScrollableHeight()
				self:updateContentViewArea()
				
				if self.onPaySuccess then
					self.onPaySuccess()
				end
			end, function()
				if self.isDisposed then return end
				if item.isDisposed then return end
				if layout.isDisposed then return end
				CommonTip:showTip('促销过期了')
				layout:removeItemAt(item:getArrayIndex())
				layout:__layout()
				self:updateScrollableHeight()
				self:updateContentViewArea()
			end)
			ui:setSource(self.source)
			ui:setGoldPage(self)
			item = ItemInLayout:create()
			item:setContent(ui)
			layout:addItemAt(item, 1)
			self:updateScrollableHeight()
		-- end)
		end
	end
end


function IOSGoldPage:isInPromotion()
	local promotionMgr = PromotionManager:getInstance()
	return promotionMgr:isInPromotion()
end

function IOSGoldPage:shouldShowPromotion()
	return true
end

function IOSGoldPage:getPromotionConfig()
	-- return {
	-- 	time = 3600,
	-- 	goodsId = 222,
	-- 	productId = '' --IOS促销才有这个
	-- }

	local promotionMgr = PromotionManager:getInstance()
	local promotion = promotionMgr:getPromotionInfo()
	local config = {
			time = promotionMgr:getRestTime(),
			goodsId = promotionMgr:getGoodsId(),
			productId = promotionMgr:getProductId(),
			id = promotionMgr:getPromotionId()
	}
	return config
end

function IOSGoldPage:setPayCallback(onPaySuccess, onPayFail)
	self.onPaySuccess = onPaySuccess
	self.onPayFail = onPayFail
end

function IOSGoldPage:isInAppleVerification()
	return MaintenanceManager:getInstance():isEnabled('AppleVerification')
end

function IOSGoldPage:getVerificationPromotion()
	return {
		
	}
end



function IOSGoldPage:setPromotionEndCallback(callback)
	self.promotionEndCallback = callback
end

function IOSGoldPage:setSource( source )
	self.source = source
end

return IOSGoldPage