require 'zoo.panel.MarketPanel'
require 'zoo.panel.happyCoinShop.FlowLayout'
require 'zoo.panel.happyCoinShop.BuyHappyCoinItem'

local NewMarketPanel = class(MarketPanel)

-- function NewMarketPanel:enableIapPromotion(index)
-- 	if __IOS or __WIN32 then
-- 		local IosPayGuideProxy = HappyCoinShopFactory:getInstance():getIosPayGuide()
-- 		if index == 3 or IosPayGuideProxy:isInAppleVerification() then
-- 			self._triggerIapPromotion = true
-- 		end
-- 	end
-- end

function NewMarketPanel:refresh()
end

function NewMarketPanel:create(defaultIndex, tabConfig, coinsPageDefaultPayType)
	local instance = NewMarketPanel.new()
	instance:loadRequiredResource(PanelConfigFiles.market_panel)
	instance.builder2 = InterfaceBuilder:createWithContentsOfFile("ui/newWindShop.json")
	instance.coinsPageDefaultPayType = coinsPageDefaultPayType
	instance:init(defaultIndex, tabConfig)
	BuyObserver:sharedInstance():setMarketPanelRef(instance)
	return instance
end

function NewMarketPanel:dispose()
	InterfaceBuilder:unloadAsset("ui/newWindShop.json")
	MarketPanel.dispose(self)
end

function NewMarketPanel:adjustClippingNode(index)
	if __ANDROID or __IOS or __WIN32 then
		if not self.simpleClipping then return end
		local size = self.simpleClipping:getContentSize()
		self.simpleClipping:setContentSize(CCSizeMake(size.width, size.height + self:getOffsetY()))
		self.simpleClipping:setPositionY(self.originClippingY - self:getOffsetY())
	end
end

function MarketPanel:isGiftPackTab(index)
	for i,v in ipairs(self.config.tabs) do
		if v.pageIndex == index then
			return v.tabId == TabsIdConst.kGiftPack
		end
	end

	return false;
end

function NewMarketPanel:gotoTabPage(index)

	local function buildProductPage()
		if self.isDisposed then return end
		self.happyCoinNetworkTip:setVisible(false)
		if __ANDROID then 
			self:buildAndroidGoldPage()
			self:adjust()
		elseif __WP8 then 
			self:buildWP8GoldPage()
		elseif __IOS then 
			self:buildIOSGoldPage() 
		elseif __WIN32 then
			self:buildIOSGoldPage()
		end
	end

	local isHappyCoinsTab = self:isHappyCoinsTab(index);

	self.linkBtnHistory:setVisible(isHappyCoinsTab and MaintenanceManager:getInstance():isEnabled("ConsumeDetailPanel"));

	self.needHuaWeiGuide = false
	if isHappyCoinsTab and IosAliGuideUtils:shouldShowIOSAliGuide() and (not self:haveRmbConsumeHistory()) then
		self.ios_ali_link:setVisible(true)
		self.linkBtnHistory:setVisible(false)		
	elseif isHappyCoinsTab and self:needHuaWeiShowGuide()  then
		self.needHuaWeiGuide = true
		self.linkBtnHistory:setVisible(false)	
		self.ios_ali_link:setVisible(true)
		DcUtil:UserTrack({ category='huaweipayguide', sub_category='push_guide'})
	else
		self.ios_ali_link:setVisible(false)
	end

	if isHappyCoinsTab and IosAliGuideUtils:shouldShowIOSAliGuide() and (not CCUserDefault:sharedUserDefault():getBoolForKey("market.ios.ali.guide.anim.showed")) then
		CCUserDefault:sharedUserDefault():setBoolForKey("market.ios.ali.guide.anim.showed", true)
		local MarketPanelIosAliGuidePanel = require 'zoo.panel.MarketPanelIosAliGuidePanel'
		local animPanel = MarketPanelIosAliGuidePanel:create(1)
		local visibleSize	= CCDirector:sharedDirector():getVisibleSize()
		animPanel:setPosition(ccp(140, 240 - visibleSize.height))
		animPanel:popout()
		animPanel:runAction(CCSequence:createWithTwoActions(
    		CCDelayTime:create(4),
    		CCCallFunc:create(function()
   				animPanel:close()
    		end)
    	))
	end



	self.buyGoldButton:setVisible(not isHappyCoinsTab);

	PlatformConfig:setCurrentPayType()
	if isHappyCoinsTab then

		if HappyCoinShopFactory:getInstance():shouldUse_1_45() and PromotionManager:getInstance():isInPromotion() and self.source then
			DcUtil:UserTrack({category = "shop", sub_category = "wm_promotion_source", source=self.source})
		end

		if not self.isDcHappyCoin then
			DcUtil:UserTrack({category = "shop", sub_category = "happy_coin", star_bank_state = StarBank.state or -1})
			self.isDcHappyCoin = true
		end

		self:updateCashPartPosition(false)
		self:setPromotionFlagVisible(false)
		self:setPennyFlagVisible(false)
		self:setGoldFreeVisible(false)
		if __WP8 then --WP8走原来逻辑
			self.happyCoinNetworkTip:setVisible(true)
			MarketManager:sharedInstance():getGoldProductInfo(buildProductPage)
		elseif not self.goldPageBuilt and __IOS then
			self.happyCoinNetworkTip:setVisible(true)
			MarketManager:sharedInstance():getGoldProductInfo(buildProductPage)
		elseif not self.goldPageBuilt and __ANDROID then
			if not MarketManager:sharedInstance().productItems then
				MarketManager:sharedInstance():getGoldProductInfo(buildProductPage)
			elseif not MarketManager:sharedInstance().gotRemoteList then
				MarketManager:sharedInstance():getGoldProductInfo(buildProductPage)
			else
				buildProductPage()
			end
		elseif __WIN32 then
			buildProductPage()
		end

		if __ANDROID then
			self:adjust()
		end
		self:setFlagVisible(TabsIdConst.kHappyeCoin, 'couponflag', false)
		self:setFlagVisible(TabsIdConst.kHappyeCoin, 'starbankflag', false)

	else
		if StarBank:isShowCoinItem() then
			self:setFlagVisible(TabsIdConst.kHappyeCoin, 'starbankflag', true)
		elseif PromotionManager:getInstance():isPennyPayEnabled() then
			self:setPennyFlagVisible(true)
		elseif PromotionManager:getInstance():isInPromotion() then
			self:setPromotionFlagVisible(true)
		end
		self:updateCashPartPosition(true)
		self:setHappyCoinCountDownVisible(true)
		if self.androidGoldPage and not self.androidGoldPage.isDisposed then
			self.androidGoldPage:selectFirstPayIcon()
		end

		if __ANDROID then
			self:revertAdjust()
		end
	end

	local isGiftPackTab = self:isGiftPackTab(index)

	if GiftPack:isEnabledNewerPackOne() then
		local flag = self:setFlagVisible(TabsIdConst.kGiftPack, 'giftpackflag', true)
		if not self.gfx then
			self.gfx = flag:getPositionX()
			self.gfy = flag:getPositionY()
		end
		local x,y = 0,0
		if isGiftPackTab then
			x = 14
			y = 10
		end
		local isPackOneAllReward = GiftPack:isPackOneAllReward()
		flag:getChildByName('reward'):setVisible(isPackOneAllReward)
		flag:getChildByName('discount'):setVisible(not isPackOneAllReward and GiftPack:hasActNewerPackOne())
		flag:setPosition(ccp(self.gfx + x, self.gfy + y))
		self:setDiscount(GiftPack:getMinDiscountPackOne())
	end
	-- self.giftPackBg:setVisible(isGiftPackTab)
	self.newViewBg:setVisible(not isGiftPackTab)
end

function NewMarketPanel:setDiscount(discountNum)
	local pageIndex = 0

	local pageType = TabsIdConst.kGiftPack
	for i,v in ipairs(self.config.tabs) do
		if v.tabId == pageType then
			pageIndex = v.pageIndex
		end
	end

	local t = self.tabs.tabs[pageIndex]

	if not t then return end

	local dis = t['giftpackflag']

	if not dis then return end

	if discountNum > 10 then
		--show reward
	end

	if not self.discountUI then
		local discountContainerUI = dis
		local discountUI = discountContainerUI:getChildByName('discount')

		self.discountUI = discountUI
		self.discountContainerUI = discountContainerUI
	end

	if discountNum == 10 then
		self.discountUI:setVisible(false)
	else
		local discountNumUI = self.discountUI:getChildByName("num")
		discountNumUI:setText(discountNum)
		if not self.dx then
			self.dx = discountNumUI:getPositionX()
			self.dy = discountNumUI:getPositionY()
		end
		discountNumUI:setRotation(35)
		discountNumUI:setPositionX(self.dx +15)
		discountNumUI:setPositionY(self.dy -8)

		if discountNum == 1 then
			discountNumUI:setPositionX(self.dx +18)
			discountNumUI:setPositionY(self.dy -10)
		end

		discountNumUI:setScale(2)
		local discountTextUI = self.discountUI:getChildByName("text")
		if not self.dxx then
			self.dxx = discountTextUI:getPositionX()
			self.dyy = discountTextUI:getPositionY()
		end
		discountTextUI:setPosition(ccp(self.dxx + 5, self.dyy - 5))

		discountTextUI:setRotation(35)
		discountTextUI:setScale(1.7)
		discountTextUI:setText(Localization:getInstance():getText("buy.gold.panel.discount"))
	end
end

function NewMarketPanel:beforeGotoPage(index)
	local isHappyCoinsTab = self:isHappyCoinsTab(index);

	if isHappyCoinsTab then
		if __ANDROID then
			self:adjust()
		end
	else
		if __ANDROID then
			self:revertAdjust()
		end
	end

	local isGiftPackTab = self:isGiftPackTab(index)
	self.giftPackBg:setVisible(isGiftPackTab)
	if GiftPack:isEnabledNewerPackOne() and not isGiftPackTab and self.newViewBg then
		self.newViewBg:setVisible(true)
	end
end


function NewMarketPanel:buildIOSGoldPage()
	if self.isDisposed then return end
	self:convertProcuctInfo()
	self:__buildIOSGoldPage()
end

function NewMarketPanel:buildAndroidGoldPage()
	if self.isDisposed then return end
	self:convertProcuctInfo()
	self:__buildAndroidGoldPage()
end

function NewMarketPanel:buildAndroidOneYuanItem(paramTable)
end

function NewMarketPanel:convertProcuctInfo()
	self.iosProductInfo = {
		[1] = {id = 5, cash = 62, extraCash = 2, priceInCent = 600, productId='com.happyelements.animal.gold.cn.5', priceLocale='jyp', iconType=2, flag = '最热门'},
		[2] = {id = 123, cash = 5180, extraCash = 6368, priceInCent = 51800, productId='com.happyelements.animal.gold.cn.105', priceLocale='jyp', iconType=6, flag = '送最多'},
		[3] = {id = 40, cash = 3168, extraCash = 588, priceInCent = 25800, productId='com.happyelements.animal.gold.cn.40', priceLocale='jyp', iconType=7, flag = '送最多'},
		[4] = {id = 2, cash = 188, extraCash = 8, priceInCent = 1800, productId='com.happyelements.animal.gold.cn.4', priceLocale='jyp', iconType = 1},
		[5] = {id = 6, cash = 340, extraCash = 40, priceInCent = 3000, productId='com.happyelements.animal.gold.cn.6', priceLocale='jyp', iconType=3},
		[6] = {id = 7, cash = 1568, extraCash = 288, priceInCent = 12800, productId='com.happyelements.animal.gold.cn.7', priceLocale='jyp', iconType=4},
	}

	self.androidProductInfo = {
		[1] = {
			productName = 'ingame',
			productInfo = {
				[1] = {id = 1, cash = 60, extraCash = 0, priceInCent = 600, iconType = 1, flag = '送最多'},
				[2] = {id = 2, cash = 125, extraCash = 5, priceInCent = 1200, iconType = 1, flag = '送最多'},
				[3] = {id = 3, cash = 300, extraCash = 20, priceInCent = 2800, iconType = 1, flag = '送最多'},
				[4] = {id = 4, cash = 600, extraCash = 80, priceInCent = 6000, iconType = 1, flag = '送最多'},
				[5] = {id = 5, cash = 1380, extraCash = 180, priceInCent = 12000, iconType = 1, flag = '送最多'},
			},
			sort = 100
		},
		[2] = {
			productName = 'wechat_2',
			productInfo = {
				[1] = {id = 35, cash = 66, extraCash = 6, priceInCent = 600, iconType = 1, flag = '送最多'},
				[2] = {id = 36, cash = 140, extraCash = 20, priceInCent = 1200, iconType = 1, flag = '送最多'},
				[3] = {id = 37, cash = 340, extraCash = 60, priceInCent = 2800, iconType = 1, flag = '送最多'},
				[4] = {id = 38, cash = 750, extraCash = 150, priceInCent = 6000, iconType = 1, flag = '送最多'},
				[5] = {id = 39, cash = 1560, extraCash = 360, priceInCent = 12000, iconType = 1, flag = '送最多'},
			},
			sort = 2
		}
	}
	

	if __ANDROID then
		self:__convertAndroidProductInfo()
	end

	if __IOS then
		self:__convertIOSProductInfo()
	end
end

function NewMarketPanel:__convertAndroidProductInfo()
	local productItems = MarketManager:sharedInstance().productItems
	
	-- 数据格式小转换
	self.androidProductInfo = {}
	table.each(productItems, function(item)
		if item.enabled then
			local newItem = {}
			newItem.productName = item.name
			newItem.sort = 10000
			newItem.productInfo = {}
			for i = 1, #item do

				--克隆一下原来所有的字段，
				--因为购买逻辑还是原来的，所以要保留原来的字段
				local newPayItem = {}
				for key, value in pairs(item[i]) do
					newPayItem[key] = value
				end

				--以下是所有新界面需要的字段，单独写了一遍，即便有重复的
				newPayItem.id = item[i].id
				newPayItem.cash = item[i].cash
				newPayItem.extraCash = item[i].extraCash
				newPayItem.priceInCent = item[i].rmb
				newPayItem.priceLocale = 'CNY'

				local iconTypeMap = {
					[400] = 1,
					[600] = 1,
					[1200] = 2,
					[2800] = 7,
					[6000] = 4,
					[18000] = 5,
					[36000] = 6 
				}
				if iconTypeMap[newPayItem.priceInCent] then
					newPayItem.iconType = iconTypeMap[newPayItem.priceInCent]
				else
					newPayItem.iconType = 1
				end

				if newPayItem.priceInCent == 2800 then
					newPayItem.flag = '最热门'
				end

				if newPayItem.priceInCent == 36000 then
					newPayItem.flag = '送最多'
				end

				table.insert(newItem.productInfo, newPayItem)

				newItem.sort = item[i].newSort
			end
			table.insert(self.androidProductInfo, newItem)
		end
	end)

	--T1支付方式里 加入特殊的最新一级别的风车币
	-- table.each(self.androidProductInfo, function(item)
	-- 	local payment = PaymentBase:getPayment(item.productName)
	-- 	if payment:getPaymentLevel() == PaymentLevel.kLvOne and payment.mode == PaymentMode.kThirdParty and payment.type ~= Payments.WO3PAY and payment.type ~= Payments.TELECOM3PAY then
	-- 		local payment = PaymentBase:getPayment(item.productName)
	-- 		table.insert(item.productInfo, {
	-- 			id = 102,
	-- 			cash = 3128,
	-- 			extraCash = 728,
	-- 			priceInCent = 24000,
	-- 			iconType = 6,
	-- 			priceLocale = 'CNY',
	-- 			flag = '送最多',
	-- 			discount = 10,
	-- 			iapPrice = 240,
	-- 			rmb = 24000,
	-- 			payType = payment.type
	-- 		})
	-- 	end
	-- end)

	table.each(self.androidProductInfo, function(item)
		table.sort(item.productInfo, function(a, b)
			local priority = {
				2800,
				36000,
				400,
				600,
				1200,
				6000,
				18000
			}
			local aPriority = table.indexOf(priority, a.priceInCent) or 100
			local bPriority = table.indexOf(priority, b.priceInCent) or 100
			return aPriority < bPriority
		end)
	end)
end

function NewMarketPanel:__buildIOSGoldPage()
	if self.goldPageBuilt then return end
	self.goldPageBuilt = true

	local IOSGoldPage = HappyCoinShopFactory:getInstance():getIosGoldPage()
	
	local iosGoldPage = IOSGoldPage:create(self.iosProductInfo, self.builder2, self:_getGoldPageHeight())
	iosGoldPage:setPayCallback(function()


		if self.buyHappyCoinCallback then
			self.buyHappyCoinCallback()
		end


		if self.isDisposed then return end
		self.cashAmountTxt:setString(UserManager:getInstance().user:getCash())
		if self.buyGoldSuccessFunc then self.buyGoldSuccessFunc() end 

	end)
	
	iosGoldPage:setPositionX(14)
	iosGoldPage:setPositionY(iosGoldPage:getPositionY() + self:getOffsetY() - 15)

	iosGoldPage:setSource(self.source)

	self.happycoinsPage:addChild(iosGoldPage)

	RealNameManager:addConsumptionLabelToVerticalPage(iosGoldPage, ccp(-16, 0))
end

function NewMarketPanel:__buildAndroidGoldPage()
	if self.goldPageBuilt then
		return 
	end
	self.goldPageBuilt = true

	local AndroidGoldPage = HappyCoinShopFactory:getInstance():getAndroidGoldPage()

	WechatPaymentSpecialManager:checkHasWechatPayment(self.androidProductInfo)
	
	local page = AndroidGoldPage:create(self.androidProductInfo, self.builder2, self:_getGoldPageHeight(), self:isNeedWechatFriendPay(), self.coinsPageDefaultPayType, self.source)
	

	page:setSource(self.source)
	

	local function updateCashLabel()

		if self.buyHappyCoinCallback then
			self.buyHappyCoinCallback()
		end

		if self.isDisposed then return end
		self.cashAmountTxt:setString(UserManager:getInstance().user:getCash())
		WechatFriendPanel:clearCount()

        if self.buyGoldSuccessFunc then self.buyGoldSuccessFunc() end
	end

	local failCallback = nil
	if self:isNeedWechatFriendPay() then
		failCallback = function (itemData, lastFailedItem, errCode)
			self:tryPopReBuyPanel(itemData, lastFailedItem, errCode)
		end
	end

	page:setPayCallback(updateCashLabel, failCallback)
	self.goldPagePosY = page:getPositionY()

	page:setPositionY(page:getPositionY() + self:getOffsetY())
	self.happycoinsPage:addChild(page)

	self.androidGoldPage = page

end

function NewMarketPanel:onPageViewSwitchFinish( pageIndex )
end

function NewMarketPanel:_getGoldPageHeight()
	local y1 = self.linkBtnHistory:getGroupBounds().origin.y
	local y2 = self.tabs:getGroupBounds().origin.y


	return y2 - y1
end

function NewMarketPanel:__convertIOSProductInfo()
	local productItems = MarketManager:sharedInstance().productItems

	self.iosProductInfo = {}
	table.each(productItems, function(item)
		local newItem = {}

		newItem.show = item.show
		newItem.price = item.price
		newItem.grade = item.grade
		newItem.discount = item.discount
		newItem.iapPrice = item.iapPrice
		newItem.productIdentifier = item.productIdentifier
		newItem.id = item.id
		newItem.cash = item.cash
		newItem.extraCash = item.extraCash
		newItem.productId = item.productId
		newItem.priceInCent = item.price*100
		newItem.priceLocale = item.priceLocale 

		local iconTypeMap = {
			[600] = 1,
			[1800] = 2,
			[3000] = 7,
			[12800] = 4,
			[25800] = 5,
			[51800] = 6,
		}
		if iconTypeMap[newItem.priceInCent] then
			newItem.iconType = iconTypeMap[newItem.priceInCent]
		else
			newItem.iconType = 1
		end
		if newItem.priceInCent == 3000 then
			newItem.flag = '最热门'
		end
		if newItem.priceInCent == 25800 then
			-- newItem.flag = '送最多'
		end
		if newItem.priceInCent == 51800 then
			newItem.flag = '送最多'
		end
		table.insert(self.iosProductInfo, newItem)
	end)


	table.sort(self.iosProductInfo, function(a, b)
		local priority = {
			3000,
			51800,
			600,
			1800,
			12800,
			25800,
		}
		local aPriority = table.indexOf(priority, a.priceInCent) or 100
		local bPriority = table.indexOf(priority, b.priceInCent) or 100
		return aPriority < bPriority
	end)
end

function NewMarketPanel:setPromotionFlagVisible( visible )
	local goldIndex = 3
	for i,v in ipairs(self.config.tabs) do
		if v.tabId == TabsIdConst.kHappyeCoin then
			goldIndex = v.pageIndex
		end
	end

	if self.tabs.tabs[goldIndex] then
		self.tabs.tabs[goldIndex].promotionFlag:setVisible(visible)

		if HappyCoinShopFactory:getInstance():shouldUse_1_45() then

			if visible then
				self:playPromotionFlagAnim(self.tabs.tabs[goldIndex].promotionFlag)
			else
				self:stopPromotionFlagAnim(self.tabs.tabs[goldIndex].promotionFlag)
			end

		end

	end
end

function NewMarketPanel:playPromotionFlagAnim( flag )
	if self.promotionFlagAnimPlaying then return end
	self.promotionFlagAnimPlaying = true

	local FPS = 24.0
	local array = CCArray:create()
	array:addObject(CCDelayTime:create(25/FPS))
	array:addObject(CCRotateTo:create(2/FPS, -9.2))
	array:addObject(CCRotateTo:create(3/FPS, 14.7))
	array:addObject(CCRotateTo:create(2/FPS, -11.2))
	array:addObject(CCRotateTo:create(2/FPS, 0))
	array:addObject(CCDelayTime:create(30/FPS))
	local action = CCSequence:create(array)
	flag:runAction(CCRepeatForever:create(action))
end

function NewMarketPanel:setPennyFlagVisible( visible )
	local goldIndex = 3
	for i,v in ipairs(self.config.tabs) do
		if v.tabId == TabsIdConst.kHappyeCoin then
			goldIndex = v.pageIndex
		end
	end

	if self.tabs.tabs[goldIndex] then
		self.tabs.tabs[goldIndex].pennyFlag:setVisible(visible)

		if HappyCoinShopFactory:getInstance():shouldUse_1_45() then

			if visible then
				self:playFlagAnim(self.tabs.tabs[goldIndex].pennyFlag)
			else
				self:stopFlagAnim(self.tabs.tabs[goldIndex].pennyFlag)
			end

		end

	end
end

function NewMarketPanel:playFlagAnim( flag )
	if flag.flagAnimPlaying then return end
	flag.flagAnimPlaying = true
	local FPS = 24.0
	local array = CCArray:create()
	array:addObject(CCDelayTime:create(25/FPS))
	array:addObject(CCRotateTo:create(2/FPS, -9.2))
	array:addObject(CCRotateTo:create(3/FPS, 14.7))
	array:addObject(CCRotateTo:create(2/FPS, -11.2))
	array:addObject(CCRotateTo:create(2/FPS, 0))
	array:addObject(CCDelayTime:create(30/FPS))
	local action = CCSequence:create(array)
	flag:runAction(CCRepeatForever:create(action))
end

function NewMarketPanel:stopFlagAnim( flag )
	if not flag.flagAnimPlaying then return end
	flag.flagAnimPlaying = false
	flag:stopAllActions()
end

function NewMarketPanel:setFlagVisible(pageType, flagName, visible )

	if self.isDisposed then return end

	local pageIndex = 0

	for i,v in ipairs(self.config.tabs) do
		if v.tabId == pageType then
			pageIndex = v.pageIndex
		end
	end

	if self.tabs.tabs[pageIndex] then
		self.tabs.tabs[pageIndex][flagName]:setVisible(visible)
		if visible then
			self:playFlagAnim(self.tabs.tabs[pageIndex][flagName])
		else
			self:stopFlagAnim(self.tabs.tabs[pageIndex][flagName])
		end
		return self.tabs.tabs[pageIndex][flagName]
	end
end


function NewMarketPanel:stopPromotionFlagAnim( flag )

	if not self.promotionFlagAnimPlaying then return end
	self.promotionFlagAnimPlaying = false

	flag:stopAllActions()
end

function NewMarketPanel:init(...)

	self.layouts = {}
	self.adjusted = false

	MarketPanel.init(self, ...)

	-- self.viewBg
	self.newViewBg = Scale9SpriteColorAdjust:createWithSpriteFrameName('newWindShop/scaleBG40000')

	local size = self.viewBg:getPreferredSize()
	local anchorPoint = self.viewBg:getAnchorPoint()
	local position = self.viewBg:getPosition()
	local parent = self.viewBg:getParent()
	local index = parent:getChildIndex(self.viewBg)
	self.viewBg:setVisible(false)

	self.newViewBg:setPreferredSize(CCSizeMake(size.width, size.height))
	self.newViewBg:setAnchorPoint(ccp(anchorPoint.x, anchorPoint.y))
	self.newViewBg:setPosition(ccp(position.x, position.y))
	parent:addChildAt(self.newViewBg, index)

	-- if __ANDROID then
		self.originClippingSize = self.simpleClipping:getContentSize()
		self.originClippingY = self.simpleClipping:getPositionY()
	-- end

	self:adjustClippingNode()

	if not PromotionManager then
		require 'zoo.panel.happyCoinShop.PromotionFactory'
	end


	PromotionManager:getInstance():setPromotionEndCallback(function(isPennyPay)
		if self.isDisposed then return end
		if isPennyPay then
			self:setPennyFlagVisible(false)
		else
			self:setPromotionFlagVisible(false)
		end
		self.coinsPageDefaultPayType = nil
	end)
end


function NewMarketPanel:buildPageByTabId(tabId)
	local layout = MarketPanel.buildPageByTabId(self, tabId)
	if layout then
		layout.__oldPosY__ = layout:getPositionY()
		layout:setPositionY(layout:getPositionY() + self:getOffsetY())
		table.insert(self.layouts, layout)
	end
	return layout
end

function NewMarketPanel:getOffsetY()
	if __ANDROID then
		return 6
	else
		return 0
	end
end

function NewMarketPanel:adjust()
	if not self.adjusted then
		self.adjusted = true

		if (not self.simpleClipping) or (self.simpleClipping.isDisposed) then return end
		local size = self.originClippingSize
		self.simpleClipping:setContentSize(CCSizeMake(size.width, size.height + self:getOffsetY()))
		self.simpleClipping:setPositionY(self.originClippingY - self:getOffsetY())


		if (not self.androidGoldPage) or (self.androidGoldPage.isDisposed) then return end
		self.androidGoldPage:setPositionY(self.goldPagePosY + self:getOffsetY())

		table.each(self.layouts, function(layout)
			if layout.isDisposed then return end
			layout:setPositionY(layout.__oldPosY__ + self:getOffsetY())
		end)
	end
end

function NewMarketPanel:revertAdjust()
	if self.adjusted then
		self.adjusted = false
		
		
		table.each(self.layouts, function(layout)
			if layout.isDisposed then return end
			layout:setPositionY(layout.__oldPosY__)
		end)

		if (not self.androidGoldPage) or (self.androidGoldPage.isDisposed) then return end
		self.androidGoldPage:setPositionY(self.goldPagePosY)

		if (not self.simpleClipping) or (self.simpleClipping.isDisposed) then return end
		local size = self.originClippingSize
		self.simpleClipping:setContentSize(CCSizeMake(size.width, size.height))
		self.simpleClipping:setPositionY(self.originClippingY)
	end
end

return NewMarketPanel