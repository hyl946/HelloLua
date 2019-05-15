require 'zoo.panel.buygold.AndroidQuickPayCheckItem'
require 'zoo.panel.happyCoinShop.PromotionFactory'
require 'zoo.panel.happyCoinShop.WechatPaymentSpecialManager'

local utils = require 'zoo.panel.happyCoinShop.utils'


local PayIcon = class(Layer)

function PayIcon:ctor()
end

function PayIcon:create(...)
	local instance = PayIcon.new()
	instance:init(...)
	return instance
end

function PayIcon:init(payment, builder, onClick)
	self:initLayer()
	local ui = builder:buildGroup('newWindShop/pay_icon/icon')
	self:addChild(ui)

	self.isWechatSpecial = false

	self.payType = payment.type

	local payment = PaymentBase:getPayment(self.payType)
	if payment:getPaymentLevel() == PaymentLevel.kLvOne and payment.mode == PaymentMode.kThirdParty and self.payType ~= Payments.WO3PAY and self.payType ~= Payments.TELECOM3PAY then
		self.isT1Pay = true        --T1/T2是产品口中的一种支付分类
	else
		self.isT1Pay = false
	end

	local iconHolder = ui:getChildByName('iconHolder')
	local realIcon = self:getRealIcon(payment)

	if realIcon then
		realIcon:setAnchorPoint(ccp(0, 0))
		iconHolder:addChild(realIcon)
	end


	self.pointer = ui:getChildByName('pointer')
	self.tip = ui:getChildByName('bubble') --多送字样
	self.checkUI = ui:getChildByName('checked')
	self.wxnbFlag = ui:getChildByName('wxnbFlag')
	self.wxnbFlag:setVisible(false)
	self.monthFlag = ui:getChildByName('monthFlag')
	self.monthFlag:setVisible(false)
	self.couponFlag = ui:getChildByName('coupon')
	self.couponFlag:setVisible(false)
	self:showTip(false)
	self:showMonthFlag(false)
	self:select(false)

	self:setTouchEnabled(true, -1, true)
	self:addEventListener(DisplayEvents.kTouchTap,function ()
		if self.isDisposed then return end
	   	if onClick then
	   		onClick(self)
	   	end
	end)

	if WechatPaymentSpecialManager:isEnableForBubbleShow() then 
		if WechatPaymentSpecialManager:isWechatLike(self.payType) then 
			self.wxnbFlag:setOpacity(255)
			self.wxnbFlag:setVisible(true)

			self.isWechatSpecial = true
		else
			self.wxnbFlag:setOpacity(0)
		end
		self.tip:setOpacity(0)
	end

	self.wxnbFlag:setVisible(self.isWechatSpecial or false)
end

function PayIcon:showTip(bShow)
	self.tip:setVisible(bShow)
end

function PayIcon:showMonthFlag( bShow )
	bShow = true
	if self.isDisposed then return end
	self.wxnbFlag:setVisible(self.isWechatSpecial or false)
end

function PayIcon:showPointer(bShow)
	self.pointer:setVisible(bShow)
end

function PayIcon:check(bCheck)
	self.checkUI:setVisible(bCheck)
end

function PayIcon:select(bSelect, isT1Selected)
	self:showPointer(bSelect)
	self:check(bSelect)
	self:showMonthFlag(not bSelect)

	if isT1Selected == false then
		if self.isT1Pay then
			self:showTip(true)
		end
	else
		self:showTip(false)
	end
end

function PayIcon:isT1Icon()
	return self.isT1Pay
end

function PayIcon:getPayType()
	return self.payType
end


function PayIcon:getRealIcon(payment)
	local payType = payment.type
	local payShowConfig = PaymentManager.getInstance():getPaymentShowConfig(payType, 1)
	local frameName = payShowConfig.bigIcon
	return Sprite:createWithSpriteFrameName(frameName)
end


local PayIconBar = class(HorizontalTileLayoutWithAlignment)

function PayIconBar:create(androidProductInfo, builder, onClick)
	local instance = PayIconBar.new()
	instance:init(androidProductInfo, builder, onClick)
	return instance
end

function PayIconBar:hide( ... )
	self:setVisible(false)
end


function PayIconBar:init(androidProductInfo, builder, onClick)

	HorizontalTileLayoutWithAlignment.init(self, 675, 134)

	self.onClick = onClick

	FrameLoader:loadImageWithPlist('ui/BuyConfirmPanel.plist')

	local function __onSelectItem(...)
		self:__onSelectItem(...)
	end

	self.payIcons = {}
	self.payTypes = {}

	for _, item in ipairs(androidProductInfo) do
		local productName = item.productName
		local payment = PaymentBase:getPayment(productName)
		if ((payment:isEnabled() and payment:isWindMillEnabled()) or __WIN32 or #androidProductInfo == 1) and payment.type ~= Payments.UMPAY then
			local payIcon = PayIcon:create(payment, builder, __onSelectItem)
			local item = ItemInLayout:create()
			item:setContent(payIcon)
			self:addItem(item)
			table.insert(self.payIcons, payIcon)
			table.insert(self.payTypes, payment.type)
		end
	end

	self:__layout()
end

function PayIconBar:getPayIconNum( ... )
	return #(self.payIcons or {})
end

function PayIconBar:getFirstPayType()
	if self.payTypes and self.payTypes[1] then
		return self.payTypes[1]
	end
end

function PayIconBar:hasPayType( payType )
	return self.payTypes and table.indexOf(self.payTypes, payType)
end

function PayIconBar:getPayIcon( payType )
	for _,payIcon in ipairs(self.payIcons) do
		if payIcon:getPayType() == payType then
			return payIcon
		end
	end
	return nil
end

function PayIconBar:getFirstPayIcon()
	if self.payIcons and self.payIcons[1] then
		return self.payIcons[1]
	end
end

function PayIconBar:dispose()
	FrameLoader:unloadImageWithPlists({'ui/BuyConfirmPanel.plist'})
	HorizontalTileLayoutWithAlignment.dispose(self)
end

function PayIconBar:__onSelectItem(selectedIcon)
	table.each(self.payIcons, function(payIcon)
		if payIcon == selectedIcon then
			payIcon:select(true, selectedIcon:isT1Icon())
			if self.onClick then
				self.onClick(payIcon:getPayType())
			end
		else
			payIcon:select(false, selectedIcon:isT1Icon())
		end
	end)
end

function PayIconBar:__layout()
    if #self.items == 0 then return end

    local totalWidth = 0
    table.each(self.items, function(item)
    	totalWidth = totalWidth + item:getWidth()
    end)

    local pageWidth = 675
    local spacingX = (pageWidth - totalWidth)/(#self.items + 1)

    local x = spacingX

    for _, item in ipairs(self.items) do
    	item:setPositionX(x)
    	x = x + item:getWidth() + spacingX
	end

end


local AndroidGoldPage = class(VerticalTileLayout)

function AndroidGoldPage:create(androidProductInfo, builder, height, isNeedWechatFriendPay, defaultPayType, source)
	local instance = AndroidGoldPage.new()
	instance:setSource(source)
	instance:init(675)
	instance.isNeedWechatFriendPay = isNeedWechatFriendPay
	instance.defaultPayType = defaultPayType
	instance:__buildUI(androidProductInfo, builder, height)
	return instance
end

function AndroidGoldPage:ctor()
end

function AndroidGoldPage:__buildUI(androidProductInfo, builder, pageHeight)
	self.pageHeight = pageHeight
	self.androidProductInfo = androidProductInfo
	self:sortPayment()
	
	self.builder = builder

	self.visibleTop = 0
	self.visibleBottom = 0

	if not self:isInPromotion() then
		self:__tryBuildJiFenQiang()
	end

	self:__buildPaymentIcon()


	if self.payIconBar:getPayIconNum() <= 1 then
		self:hidePayBar()
	else
		self:selectFirstPayIcon()
	end

	self:__layout()
end

function AndroidGoldPage:selectFirstPayIcon()
	-- self:__onSelect(self.payIconBar:getFirstPayType())
	if PromotionManager:getInstance():isPennyPayEnabled() then
		self.payIconBar:__onSelectItem(self.payIconBar:getPayIcon(Payments.ALIPAY))
	else
		self.payIconBar:__onSelectItem(self.payIconBar:getFirstPayIcon())
	end
end

function AndroidGoldPage:getDefaultPayment()
	return Payments.WECHAT
end

function AndroidGoldPage:__buildQuickPayCheckUI(payType)

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
		self.pageContainer.layoutContainer:addItemAt(item, 1)
		self.quickCheckItem = item
		self.quickCheckItemUI = ui
	end
end

function AndroidGoldPage:__buildPaymentIcon()
	local ui = PayIconBar:create(
		self.androidProductInfo, 
		self.builder, 
		function(payType)
			if self.isDisposed then return end
			self:__onSelect(payType)
		end
	)

	self.payIconBar = ui

	local item = ItemInLayout:create()
	item:setContent(ui)
	self:addItem(item)

	self.payIconBarItem = item

end

function AndroidGoldPage:__onSelect(payType)
	if payType then
		self.curPayType = payType
		self:__buildGoldItemsNewVersion(payType)
	end
end

function AndroidGoldPage:getPayBarHeight( ... )
	if not self.payBarHeight then
		return 225
	end
	return self.payBarHeight
end

function AndroidGoldPage:hidePayBar( ... )
	self.payBarHeight = 80
	self:selectFirstPayIcon()

	if self.payIconBar then
		self.payIconBar:hide()
	end

end

function AndroidGoldPage:__buildGoldItemsNewVersion(payType)
	self.itemIndex = 1

	if self.hasJiFenQiang then
		self.itemIndex = self.itemIndex + 1
	end
		
	if self.goldPageBuilt then
		self:removeItemAt(self.itemIndex)
	end

	self.goldPageBuilt = true

	local pageWidth = 675
	local pageHeight = self.pageHeight - self:getPayBarHeight()

	if self.hasJiFenQiang then
		pageHeight = pageHeight - 216
	end

	
	local pageContainer = Scale9SpriteColorAdjust:createWithSpriteFrameName('newWindShop/scaleBG30000')
	pageContainer:setPreferredSize(CCSizeMake(pageWidth - 10, pageHeight + 10))
	pageContainer:setAnchorPoint(ccp(0, 1))
	pageContainer.layoutContainer = VerticalTileLayout:create(pageWidth - 10)
	pageContainer:addChild(pageContainer.layoutContainer)
	pageContainer.layoutContainer:setPosition(ccp(12, pageHeight - 4))
	pageContainer.layoutContainer:updateViewArea(0, 1280)
	local item = ItemInLayout:create()
	item:setContent(pageContainer)
	self:addItemAt(item, self.itemIndex)
	self.pageContainer = pageContainer


	pageContainer.layoutContainer.oldLayout = pageContainer.layoutContainer.__layout
	pageContainer.layoutContainer.__layout = function()
		pageContainer.layoutContainer.oldLayout(pageContainer.layoutContainer)
		if self.quickCheckItem and (not self.quickCheckItem.isDisposed ) then
			if self:isInPromotion() then
				self.quickCheckItem:setPositionY(self.quickCheckItem:getPositionY() + 2)
			end
		end
	end


	self:__removeAndroidQuickPayCheckItem()
	self:__buildQuickPayCheckUI(payType)


	if self.quickCheckItem and (not self.quickCheckItem.isDisposed) then
		pageHeight = pageHeight - 45
	end


	self.goldItems = {}
	local config = self:__findConfig(payType)
	local scroll = VerticalScrollable:create(pageWidth, pageHeight - 15-4, true, true)
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
		item:setHeight(315)
		table.insert(self.goldItems, uiItem)
		layout:addItem(item)
	end
	layout:__layout()
	scroll:setContent(layout)
	local scrollItem = ItemInLayout:create()
	scrollItem:setContent(scroll)

	RealNameManager:addConsumptionLabelToVerticalPage(scroll, ccp(-15, 0))

	self.pageContainer.layoutContainer:addItem(scrollItem)

	local function onPromotionEnd()
		layout:removeFromParentAndCleanup(false)
		local goldsIndex = 1
		if self.quickCheckItem and (not self.quickCheckItem.isDisposed) then
			goldsIndex = 2
		end
		pageContainer.layoutContainer:removeItemAt(goldsIndex)
		local newScroll = VerticalScrollable:create(pageWidth, pageHeight - 15 - 4, true, true)
		newScroll:setIgnoreHorizontalMove(false)
		newScroll:setContent(layout)
		local newScrollItem = ItemInLayout:create()
		newScrollItem:setContent(newScroll)
		RealNameManager:addConsumptionLabelToVerticalPage(newScroll, ccp(-15, 0))
		pageContainer.layoutContainer:addItem(newScrollItem)
	end

	local function createPromotionItem( ... )
		if self:shouldShowPromotion() then
			if self.hasJiFenQiang then
				self:closeJiFenQiang()
				return
			end

			if pageContainer.layoutContainer.isDisposed then return end
			local config = self:getPromotionConfig()
			local PromotionItem = require 'zoo.panel.happyCoinShop.PromotionItem'
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
				if pageContainer.layoutContainer.isDisposed then 
					if self.onPaySuccess then
						self.onPaySuccess()
					end
					return
				end

				pageContainer.layoutContainer:removeItemAt(1)
				pageContainer.layoutContainer:__layout()
				-- self:restartJiFen()
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
				if pageContainer.isDisposed then return end
				pageContainer.layoutContainer:removeItemAt(1)
				pageContainer.layoutContainer:__layout()
				-- self:restartJiFen()
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
			pageContainer.layoutContainer:addItemAt(item, 1)
			layout:removeFromParentAndCleanup(false)
			local goldsIndex = 2
			if self.quickCheckItem and (not self.quickCheckItem.isDisposed) then
				goldsIndex = 3
			end
			pageContainer.layoutContainer:removeItemAt(goldsIndex)
			local newScroll = VerticalScrollable:create(pageWidth, pageHeight - 230-11-4, true, true)
			newScroll:setIgnoreHorizontalMove(false)
			newScroll:setContent(layout)
			local newScrollItem = ItemInLayout:create()
			newScrollItem:setContent(newScroll)
			RealNameManager:addConsumptionLabelToVerticalPage(newScroll, ccp(-15, 0))
			pageContainer.layoutContainer:addItem(newScrollItem)
		end
	end

	local function createPennyPayItem( ... )
		if pageContainer.layoutContainer.isDisposed then return end
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
			if pageContainer.layoutContainer.isDisposed then 
				if self.onPaySuccess then
					self.onPaySuccess()
				end
				return
			end

			pageContainer.layoutContainer:removeItemAt(1)
			pageContainer.layoutContainer:__layout()
			-- self:restartJiFen()
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
			if pageContainer.isDisposed then return end
			pageContainer.layoutContainer:removeItemAt(1)
			pageContainer.layoutContainer:__layout()
			-- self:restartJiFen()
			onPromotionEnd()
			if self.promotionEndCallback then
				self.promotionEndCallback(true)
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

		pageContainer.layoutContainer:addItemAt(item, 1)
		layout:removeFromParentAndCleanup(false)
		local goldsIndex = 2
		if self.quickCheckItem and (not self.quickCheckItem.isDisposed) then
			goldsIndex = 3
		end
		pageContainer.layoutContainer:removeItemAt(goldsIndex)
		local newScroll = VerticalScrollable:create(pageWidth, pageHeight - 230-11-4, true, true)
		newScroll:setIgnoreHorizontalMove(false)
		newScroll:setContent(layout)
		local newScrollItem = ItemInLayout:create()
		newScrollItem:setContent(newScroll)
		RealNameManager:addConsumptionLabelToVerticalPage(newScroll, ccp(-15, 0))
		pageContainer.layoutContainer:addItem(newScrollItem)
	end

	local promotionMgr = PromotionManager:getInstance()
	promotionMgr:onEnterHappyCoinShop(function()
		
		if self.isDisposed then return end
		if pageContainer.layoutContainer.isDisposed then return end
		if self:isPennyPayEnabled() then
			if self.hasJiFenQiang then
				self:closeJiFenQiang()
				return
			end
			createPennyPayItem()
		elseif self:isInPromotion() then
			createPromotionItem()
		end
	end)

	Notify:dispatch("StarBankEventCreateCoinItem", function ( ui )
			local item = ItemInLayout:create()
			item:setContent(ui)
			pageContainer.layoutContainer:addItemAt(item, 1)
			--self:updateScrollableHeight()
			--return removeItem function
			return function ( ... )
				if self.isDisposed then return end
				if item.isDisposed then return end
				if pageContainer.layoutContainer.isDisposed then return end
				pageContainer.layoutContainer:removeItemAt(item:getArrayIndex())
				pageContainer.layoutContainer:__layout()
			end
		end, payType)

end

function AndroidGoldPage:isPennyPayEnabled()
	local promotionMgr = PromotionManager:getInstance()
	return promotionMgr:isPennyPayEnabled() and self.curPayType == Payments.ALIPAY
end

function AndroidGoldPage:isInPromotion()
	local promotionMgr = PromotionManager:getInstance()
	return promotionMgr:isInPromotion()
end

function AndroidGoldPage:shouldShowPromotion()
	local payment = PaymentBase:getPayment(self.curPayType)
	if payment:getPaymentLevel() == PaymentLevel.kLvOne and payment.mode == PaymentMode.kThirdParty and self.curPayType ~= Payments.WO3PAY and self.curPayType ~= Payments.TELECOM3PAY then
		return true
	else
		return false
	end
end

function AndroidGoldPage:getPromotionConfig()
	-- return {
	-- 	time = 3600,
	-- 	goodsId = 222,
	-- 	-- productId = '' --IOS促销才有这个,
	-- 	test = true
	-- }
	local promotionMgr = PromotionManager:getInstance()
	local promotion = promotionMgr:getPromotionInfo()
	local config = {
			time = promotionMgr:getRestTime(),
			goodsId = promotionMgr:getGoodsId()
	}
	return config
end

function AndroidGoldPage:getPennyPayConfig()
	local promotionMgr = PromotionManager:getInstance()
	local promotion = promotionMgr:getPromotionInfo()
	local config = {
			time = promotionMgr:getPennyPayRestTime(),
			goodsId = promotionMgr:getPennyPayGoodsId()
	}
	return config
end

function AndroidGoldPage:__findConfig(payType)
	local foundConfig
	table.each(self.androidProductInfo, function(config)
		local payment = PaymentBase:getPayment(config.productName)
		if payment.type == payType then
			foundConfig = config
		end
	end)
	return foundConfig
end

function AndroidGoldPage:updateViewArea()
end

function AndroidGoldPage:hideAndroidQuickPayCheckItem()
end


-- function AndroidGoldPage:tryPopReBuyPanel(itemData, lastFailedItem, errCode)
-- 	if self:isNeedWechatFriendPay() then
-- 		local wechatFriendPanel = WechatFriendPanel:create(itemData, lastFailedItem, errCode)
-- 		wechatFriendPanel:popout()
-- 	end
-- end

-- function AndroidGoldPage:isNeedWechatFriendPay()
-- 	if self.__isNeedWechatFriendPay ~= nil then
-- 		return self.__isNeedWechatFriendPay
-- 	end
-- 	if __ANDROID and MaintenanceManager:getInstance():isEnabled("WeChatFri") == true then
-- 		local percentAllowed = MaintenanceManager:getInstance():getValue("WeChatFri") or "0"
-- 		percentAllowed = tonumber(percentAllowed) or 0
-- 		local userId = UserManager.getInstance().uid or "0"
-- 		userId = tonumber(userId) % 100
-- 		if userId < percentAllowed then
-- 			self.__isNeedWechatFriendPay = true
-- 			return self.__isNeedWechatFriendPay
-- 		end
-- 	end
-- 	self.__isNeedWechatFriendPay = false
-- 	return self.__isNeedWechatFriendPay
-- end




function AndroidGoldPage:__buildAndroidQuickPayCheckItem(payType)
	local AliQuickPayGuide = require "zoo.panel.alipay.AliQuickPayGuide"
	local WechatQuickPayGuide = require "zoo.panel.wechatPay.WechatQuickPayGuide"
	local function clickCallback(value)
		if payType == Payments.ALIPAY then
			_G.use_ali_quick_pay = value
			if value == false then 
                if AliQuickPayGuide.isGuideTime() then
                    AliQuickPayGuide.updateGuideTimeAndPopCount()
                else
                    AliQuickPayGuide.updateOnlyGuideTime()
                end
            end
		elseif payType == Payments.WECHAT then
			_G.use_wechat_quick_pay = value
			if value == false then
				printx( 3 , ' WechatQuickPayGuide.isGuideTime() ', WechatQuickPayGuide.isGuideTime())
				if WechatQuickPayGuide.isGuideTime() then
                    WechatQuickPayGuide.updateGuideTimeAndPopCount()
                else
                    WechatQuickPayGuide.updateOnlyGuideTime()
                end
            end
		end
	end
	local NewAndroidQuickPayCheckItem = require 'zoo.panel.happyCoinShop.NewAndroidQuickPayCheckItem'
	local quickPayCheckItem = NewAndroidQuickPayCheckItem:create(payType, clickCallback, self.builder)
	if payType == Payments.ALIPAY then
		if AliQuickPayGuide.isGuideTime() then 
			quickPayCheckItem:setCheck(true)
			_G.use_ali_quick_pay = true
		else
			quickPayCheckItem:setCheck(false)
			_G.use_ali_quick_pay = false
		end
	elseif payType == Payments.WECHAT then
		if WechatQuickPayGuide.isGuideTime() then 
			if not WechatQuickPayLogic:isAutoCheckEnabled() then
				quickPayCheckItem:setCheck(false)
				_G.use_wechat_quick_pay = false
			else
				quickPayCheckItem:setCheck(true)
				_G.use_wechat_quick_pay = true
			end
		else
			quickPayCheckItem:setCheck(false)
			_G.use_wechat_quick_pay = false
		end
	end
	return quickPayCheckItem
end


function AndroidGoldPage:__removeAndroidQuickPayCheckItem(payType)
	if self.quickCheckItem and self.pageContainer then
		if self.quickCheckItem.isDisposed then return end
		self.pageContainer.layoutContainer:removeItemAt(self.quickCheckItem:getArrayIndex())
		self.quickCheckItem = nil
	end
end

function AndroidGoldPage:setPayCallback(onPaySuccess, onPayFail)
	self.onPaySuccess = onPaySuccess
	self.onPayFail = onPayFail
end

function AndroidGoldPage:__tryBuildJiFenQiang( ... )
	if not self:isInPromotion() then
		if SupperAppManager and SupperAppManager:checkEntry() == true and SupperAppManager:isInitSucceeded() == true then
			HomeScene:sharedInstance():showJiFenEntry()

			local gradient = Layer:create()
			gradient:setPosition(ccp(0, -200))
			local sprite = Sprite:createWithSpriteFrameName("supperapp_banner instance 10000")
			local scale = 648/sprite:getContentSize().width
			sprite:setAnchorPoint(ccp(0,0))
			sprite:setPositionX(10)
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
			self:addItemAt(item, 1)
			self.hasJiFenQiang = true
		else
			HomeScene:sharedInstance():shutdownJiFenEntry()
		end
	else
		HomeScene:sharedInstance():shutdownJiFenEntry()
	end
end

function AndroidGoldPage:closeJiFenQiang()
	if self.isDisposed then return end
	if self.hasJiFenQiang == true then
		self:removeItemAt(1) -- 删除积分墙在风车商店的视图
		HomeScene:sharedInstance():shutdownJiFenEntry()
		self.hasJiFenQiang = false		
		self:selectFirstPayIcon()
	end
end

function AndroidGoldPage:restartJiFen()
	if self.isDisposed then return end
	if self.hasJiFenQiang == false then
		if not self:isInPromotion() then
			self:__tryBuildJiFenQiang()
			self:selectFirstPayIcon()
		end
	end
end

function AndroidGoldPage:sortPayment()
	local uid = tonumber(UserManager.getInstance().uid) or 0
	local function sortFunc(item1,item2)
		if item1 and item1.sort and item2 and item2.sort then
			if WechatPaymentSpecialManager:isEnable() then 
				if WechatPaymentSpecialManager:isWechatLike(item1.productName) then 
					return true
				elseif WechatPaymentSpecialManager:isWechatLike(item2.productName) then 
					return false
				else
					return item1.sort < item2.sort
				end
			else
				if  (PaymentManager:getInstance():getDefaultPayment() == Payments.ALIPAY or 
					PaymentManager:getInstance():getDefaultPayment() ~= Payments.WECHAT and uid%2 ~= 0)
					or PaymentManager:getInstance():checkHaveAliAPP() then

					if item1.productName == "wechat_2" and item2.productName == "alipay_2" then
						return false
					end

					if item1.productName == "alipay_2" and item2.productName == "wechat_2" then
						return true
					end

					return item1.sort < item2.sort
				else
					return item1.sort < item2.sort
				end
			end
		else
			return false 
		end
	end
	table.sort(self.androidProductInfo, sortFunc)
end

function AndroidGoldPage:__layout(...)
	VerticalTileLayout.__layout(self, ...)
	if self.payIconBarItem then
		self.payIconBarItem:setPositionY(self.payIconBarItem:getPositionY() + 8)
	end
end

function AndroidGoldPage:setPromotionEndCallback(callback)
	self.promotionEndCallback = callback
end

function AndroidGoldPage:setSource( source )
	self.source = source
end

return AndroidGoldPage, PayIconBar