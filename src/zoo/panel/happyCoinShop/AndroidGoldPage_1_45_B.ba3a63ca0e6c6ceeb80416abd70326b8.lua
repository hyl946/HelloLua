local CustomVerticalTileLayout = require 'zoo.panel.happyCoinShop.CustomVerticalTileLayout'


local AndroidGoldPage = require 'zoo.panel.happyCoinShop.AndroidGoldPage'

local AndroidGoldPage_New = class(AndroidGoldPage)

function AndroidGoldPage_New:create(androidProductInfo, builder, height, isNeedWechatFriendPay, defaultPayType, source)
	local instance = AndroidGoldPage_New.new()
	instance:setSource(source)
	instance:init(675)
	instance.isNeedWechatFriendPay = isNeedWechatFriendPay
	instance.defaultPayType = defaultPayType
	instance:__buildUI(androidProductInfo, builder, height)
	return instance
end

function AndroidGoldPage_New:__buildUI(androidProductInfo, builder, pageHeight)

	self.pageHeight = pageHeight
	self.androidProductInfo = androidProductInfo
	self:sortPayment()
	
	self.builder = builder

	self.visibleTop = 0
	self.visibleBottom = 0

	self:__buildPaymentIcon()


	if self.payIconBar:getPayIconNum() <= 1 then
		self:hidePayBar()
	else
		self:selectFirstPayIcon()
	end

	self:__layout()
end

function AndroidGoldPage_New:selectFirstPayIcon()
	if PromotionManager:getInstance():isPennyPayEnabled() then
		self.payIconBar:__onSelectItem(self.payIconBar:getPayIcon(Payments.ALIPAY))
	else
		self.payIconBar:__onSelectItem(self.payIconBar:getFirstPayIcon())
	end
end

function AndroidGoldPage_New:__buildQuickPayCheckUI(payType)

	if self.quickCheckItem and (not self.quickCheckItem.isDisposed) then return end

	local productName = self.androidProductInfo.productName
	local payment = PaymentBase:getPayment(productName)
	local ui
	if payType == Payments.WECHAT then
		if WechatQuickPayLogic:getInstance():isMaintenanceEnabled() then
			ui = self:__buildAndroidQuickPayCheckItem(Payments.WECHAT)
		end
	elseif payType == Payments.ALIPAY and 
			PaymentManager.getInstance():shouldShowAliQuickPay() and 
			(UserManager:getInstance():getAliKfDailyLimit() > 0 and UserManager:getInstance():getAliKfMonthlyLimit() > 0) then
		ui = self:__buildAndroidQuickPayCheckItem(Payments.ALIPAY)
	elseif __WIN32 then
		ui = self:__buildAndroidQuickPayCheckItem(Payments.ALIPAY)
	end


	if ui then
		local item = ItemInLayout:create()
		item:setContent(ui)
		item:setHeight(40)

		if self.hasJiFenQiang then
			self.pageContainer.customVerticalTileLayout:addItemAt(item, 2) --
		else
			self.pageContainer.customVerticalTileLayout:addItemAt(item, 1) --
		end
		self.pageContainer.scroll:updateScrollableHeight()
		self.quickCheckItem = item
		self.quickCheckItemUI = ui
	end
end

function AndroidGoldPage_New:__buildGoldItemsNewVersion(payType)
	if self.goldPageBuilt then
		self.hasJiFenQiang = false
		self:removeItemAt(1)
	end


	self.goldPageBuilt = true

	local pageWidth = 675
	local pageHeight = self.pageHeight - self:getPayBarHeight()

	
	local pageContainer = Scale9SpriteColorAdjust:createWithSpriteFrameName('newWindShop/scaleBG30000')
	pageContainer:setPreferredSize(CCSizeMake(pageWidth - 10, pageHeight + 10))
	pageContainer:setAnchorPoint(ccp(0, 1))
	pageContainer.layoutContainer = VerticalTileLayout:create(pageWidth - 10)
	pageContainer:addChild(pageContainer.layoutContainer)
	pageContainer.layoutContainer:setPosition(ccp(12, pageHeight - 4))
	pageContainer.layoutContainer:updateViewArea(0, 1280)
	local item = ItemInLayout:create()
	item:setContent(pageContainer)
	self:addItemAt(item, 1)
	self.pageContainer = pageContainer

	self.pageContainer.customVerticalTileLayout = CustomVerticalTileLayout:create(pageWidth)




	pageContainer.customVerticalTileLayout.oldLayout = pageContainer.customVerticalTileLayout.__layout
	pageContainer.customVerticalTileLayout.__layout = function(...)
		pageContainer.customVerticalTileLayout.oldLayout(...)
		if self.quickCheckItem and (not self.quickCheckItem.isDisposed ) then
			if self:isInPromotion() then
				self.quickCheckItem:setPositionY(self.quickCheckItem:getPositionY() - 5)
			else
				self.quickCheckItem:setPositionY(self.quickCheckItem:getPositionY() - 2)
			end
		end
	end

	self.goldItems = {}
	local config = self:__findConfig(payType)
	local scroll = VerticalScrollable:create(pageWidth, pageHeight - 15-4, true, true)
	pageContainer.scroll = scroll

	scroll:setIgnoreHorizontalMove(false)





	local layout = FlowLayout:create(pageWidth, 1, 8)
	local function __enableAllBuyBtn()
		table.each(self.goldItems, function(item)
			if self.isDisposed then return end
			if item.isDisposed then return end
			item:setBuyBtnEnabled(true)
		end)
	end

	local function __disableAllBuyBtn()
		table.each(self.goldItems, function(item)
			if self.isDisposed then return end
			if item.isDisposed then return end
			item:setBuyBtnEnabled(false)
		end)
	end

	for _, itemData in ipairs(config.productInfo) do
		local ui = self.builder:buildGroup('newWindShop/Item')
		local uiItem = BuyHappyCoinItem:create(itemData, ui, self.isNeedWechatFriendPay)
		uiItem:setBuyCallback(
			__enableAllBuyBtn,
			__disableAllBuyBtn, 
			function(payType)
				if payType == Payments.ALIPAY and (UserManager:getInstance():getAliKfDailyLimit() <= 0 or UserManager:getInstance():getAliKfMonthlyLimit() <= 0) then
					if self.isDisposed then return end
					self:__removeAndroidQuickPayCheckItem()
				end
				if self.onPaySuccess then
					self.onPaySuccess(payType)
				end
			end,
			function(data, goldItem, errCode)
				if self.onPayFail then
					self.onPayFail(data, goldItem, errCode)
				end
			end
		)
		uiItem:setQuickSignCallback(function()
			if self.quickCheckItemUI and (not self.quickCheckItemUI.isDisposed) then
				self.quickCheckItemUI:runAction(CCCallFunc:create(function()
					if self.quickCheckItemUI and self.quickCheckItemUI.refresh then
						self.quickCheckItemUI:refresh()
					end
				end))
			end
		end)

		local item = ItemInLayout:create()
		item:setContent(uiItem)
		item:setWidth(315)
		item:setHeight(318)
		table.insert(self.goldItems, uiItem)
		layout:addItem(item)
	end
	layout:__layout()

	local flowLayoutItem = ItemInLayout:create()
	flowLayoutItem:setContent(layout)
	flowLayoutItem:setHeight(layout:getHeight())

	self.pageContainer.customVerticalTileLayout:addItem(flowLayoutItem)

	scroll:setContent(self.pageContainer.customVerticalTileLayout)
	self.pageContainer.scroll:updateScrollableHeight()


	local scrollItem = ItemInLayout:create()
	scrollItem:setContent(scroll)

	RealNameManager:addConsumptionLabelToVerticalPage(scroll, ccp(-15, 0))

	self.pageContainer.layoutContainer:addItem(scrollItem)


	self:__tryBuildJiFenQiang()


	self:__removeAndroidQuickPayCheckItem()
	self:__buildQuickPayCheckUI(payType)

	Notify:dispatch("StarBankEventCreateCoinItem", function ( ui )
		local item = ItemInLayout:create()
		item:setContent(ui)
		self.pageContainer.customVerticalTileLayout:addItemAt(item, 1)
		self.pageContainer.scroll:updateScrollableHeight()
		--return removeItem function
		return function ( ... )
			if self.isDisposed then return end
			if item.isDisposed then return end
			if self.pageContainer.customVerticalTileLayout.isDisposed then return end
			self.pageContainer.customVerticalTileLayout:removeItemAt(item:getArrayIndex())
			self.pageContainer.scroll:updateScrollableHeight()
		end
	end, payType)

	self:__buildPromotionItem()
end


function AndroidGoldPage_New:__removeAndroidQuickPayCheckItem(payType)

	if self.quickCheckItem and self.pageContainer then
		if self.quickCheckItem.isDisposed then return end
		self.pageContainer.customVerticalTileLayout:removeItemAt(self.quickCheckItem:getArrayIndex()) --
		self.pageContainer.scroll:updateScrollableHeight()

		self.quickCheckItem = nil
	end
end

function AndroidGoldPage_New:__tryBuildJiFenQiang( ... )
	if not self:isInPromotion() then
		if SupperAppManager and SupperAppManager:checkEntry() == true and SupperAppManager:isInitSucceeded() == true then
			HomeScene:sharedInstance():showJiFenEntry()

			local gradient = Layer:create()
			gradient:setPosition(ccp(0, -200))
			local sprite = Sprite:createWithSpriteFrameName("supperapp_banner instance 10000")
			local scale = 648/sprite:getContentSize().width
			sprite:setAnchorPoint(ccp(0,0))
			sprite:setPositionX(5)
			sprite:setPositionY(-10)
			sprite:setScale(scale)
			gradient:addChild(sprite)
			local onTouchTap = function ( evt )
				DcUtil:UserTrack({ category='activity', sub_category='push_2'})
				SupperAppManager:showJiFenView()
			end
			gradient:addEventListener(DisplayEvents.kTouchTap, onTouchTap, self)
			gradient:setTouchEnabled(true)

			local item = ItemInLayout:create()
			item:setContent(gradient)
			self.pageContainer.customVerticalTileLayout:addItemAt(item, 1) --
			self.pageContainer.scroll:updateScrollableHeight()

			self.hasJiFenQiang = true
		else
			HomeScene:sharedInstance():shutdownJiFenEntry()
		end
	else
		HomeScene:sharedInstance():shutdownJiFenEntry()
	end
end

function AndroidGoldPage_New:closeJiFenQiang()
	if self.isDisposed then return end
	if self.hasJiFenQiang == true then
		self.pageContainer.customVerticalTileLayout:removeItemAt(1) --
		self.pageContainer.scroll:updateScrollableHeight()

		HomeScene:sharedInstance():shutdownJiFenEntry()
		self.hasJiFenQiang = false		
		self:selectFirstPayIcon()
	end
end


function AndroidGoldPage_New:__buildPromotionItem( checkPromotionEndCb )
	local function onPromotionEnd()
		self.pageContainer.customVerticalTileLayout:removeItemAt(1) --
		self.pageContainer.scroll:updateScrollableHeight()
	end

	local promotionMgr = PromotionManager:getInstance()

	local function createPromotionItem()
		if self:shouldShowPromotion() then
			if needDC and self.source then
				DcUtil:UserTrack({category = "shop", sub_category = "wm_promotion_source", source = self.source})
			end

			if self.hasJiFenQiang then
				self:closeJiFenQiang()
				return
			end
			if self.pageContainer.layoutContainer.isDisposed then return end
			local config = self:getPromotionConfig()
			local PromotionShopItemFactory = require 'zoo.panel.happyCoinShop.newPromotionItem.PromotionShopItemFactory'
			local PromotionItem = PromotionShopItemFactory:getInstance():getPromotionShopItem(config)
			local ui
			local item
			ui = PromotionItem:create(config, self.builder, function()
				if ui.isDisposed then 
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
				if self.pageContainer.layoutContainer.isDisposed then 
					if self.onPaySuccess then
						self.onPaySuccess()
					end
					return 
				end

				
				onPromotionEnd()
				if self.promotionEndCallback then
					self.promotionEndCallback()
				end
				if self.onPaySuccess then
					self.onPaySuccess()
				end
			end, function()
				if ui.isDisposed then return end
				if item.isDisposed then return end
				if self.pageContainer.isDisposed then return end

				onPromotionEnd()
				if self.promotionEndCallback then
					self.promotionEndCallback()
				end
			end)
			ui:setSource(self.source)
			ui:setGoldPage(self)
			ui:setPayType(self.curPayType)
			item = ItemInLayout:create()
			item:setContent(ui)

			if self:hadShowAnim() then
				self.pageContainer.customVerticalTileLayout:addItemAt(item, 1) --
			else
				self.pageContainer.customVerticalTileLayout:addItemAt(item, 1, true) --
				self:writeShowAnimTime()
			end
			self.pageContainer.scroll:updateScrollableHeight()
		end
	end

	local function createPennyPayItem( ... )
		if self.pageContainer.layoutContainer.isDisposed then return end
		local config = self:getPennyPayConfig()
		local PromotionItem = require 'zoo.panel.happyCoinShop.newPromotionItem.PennyPayItem'
		local ui
		local item
		ui = PromotionItem:create(config, self.builder, function()
			if ui.isDisposed then 
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
			if self.pageContainer.layoutContainer.isDisposed then 
				if self.onPaySuccess then
					self.onPaySuccess()
				end
				return 
			end

			
			onPromotionEnd()
			if self.promotionEndCallback then
				self.promotionEndCallback()
			end
			if self.onPaySuccess then
				self.onPaySuccess()
			end
		end, function()
			if ui.isDisposed then return end
			if item.isDisposed then return end
			if self.pageContainer.isDisposed then return end

			onPromotionEnd()
			if self.promotionEndCallback then
				self.promotionEndCallback()
			end
		end)
		ui:setSource(self.source)
		ui:setGoldPage(self)
		ui:setPayType(self.curPayType)
		item = ItemInLayout:create()
		item:setContent(ui)

		DcUtil:UserTrack({
			category = "onecent",
			sub_category = "alipay_promotion_source",
			source = self.source,
		})

		if self:hadShowAnim() then
			self.pageContainer.customVerticalTileLayout:addItemAt(item, 1) --
		else
			self.pageContainer.customVerticalTileLayout:addItemAt(item, 1, true) --
			self:writeShowAnimTime()
		end
		self.pageContainer.scroll:updateScrollableHeight()
	end

	promotionMgr:onEnterHappyCoinShop(function(needDC)
		if self.isDisposed then return end
		if self.pageContainer.layoutContainer.isDisposed then return end

		if self:isPennyPayEnabled() then
			createPennyPayItem()
		elseif self:isInPromotion() then
			createPromotionItem()
		end
		if checkPromotionEndCb then checkPromotionEndCb() end
	end)
end

function AndroidGoldPage_New:getAnimKey( ... )
	local uid = '12345'
    if UserManager and UserManager:getInstance().user then
    	uid = UserManager:getInstance().user.uid or '12345'
    end

    local key = 'promotion.1.45.b.anim.lasttime.'..uid
    return key
end

function AndroidGoldPage_New:hadShowAnim( ... )
	local key = self:getAnimKey()

	local lastAnimTime = CCUserDefault:sharedUserDefault():getStringForKey(key) or ''
	lastAnimTime = tonumber(lastAnimTime) or 0

	local thisTriggerTime = PromotionManager:getInstance():getLastTriggerTime()
	thisTriggerTime = tonumber(thisTriggerTime) or 0

	return lastAnimTime >= thisTriggerTime
end

function AndroidGoldPage_New:writeShowAnimTime( ... )
	local key = self:getAnimKey()
	local thisTriggerTime = PromotionManager:getInstance():getLastTriggerTime()
	CCUserDefault:sharedUserDefault():setStringForKey(key, tostring(thisTriggerTime))
end

return AndroidGoldPage_New