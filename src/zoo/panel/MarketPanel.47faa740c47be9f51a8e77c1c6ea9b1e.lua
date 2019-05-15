require 'zoo.data.MarketManager'
require 'zoo.panel.component.market.MarketPanelGoodsItem'
require 'zoo.panel.component.pagedView.PagedView'
require 'zoo.panel.component.common.GridLayout'
require 'zoo.panel.component.common.LayoutItem'
require 'zoo.panel.buygold.BuyGoldItem'
require 'zoo.panel.buygold.AndroidOneYuanBuyGoldItem'
require 'zoo.panel.buygold.AndroidQuickPayCheckItem'
require 'zoo.panel.iosSalesPromotion.IosOneYuanBuyGoldItem'
require 'zoo.supperapp.supperappmanager'
require 'zoo.panel.iosSalesPromotion.HappyCoinCountdown'
require 'zoo.panel.WechatFriendPanel'
require "zoo.panel.broadcast.BroadcastManager"
local PropPage = require 'zoo.panel.happyCoinShop.PropPage'


if __IOS or __WIN32 then
	require 'zoo.gameGuide.IosPayGuide'
end

require 'zoo.panel.IosAliCartoonPanel'


local CustomizedPV = class(PagedView)
function CustomizedPV:create(width, height, numOfPages, pager, useClipping, useBlockingLayers)
    local instance = CustomizedPV.new()
    instance:init(width, height, numOfPages, pager, useClipping, useBlockingLayers)
    return instance
end
function CustomizedPV:onPageTouchBegin(event)
	if self.ignore then return end
    PagedView.onPageTouchBegin(self, event)
end
function CustomizedPV:onPageTouchMove(event)
    if self.ignore then return end
    PagedView.onPageTouchMove(self, event)
end
function CustomizedPV:onPageTouchEnd(event)
    if self.ignore then return end
    PagedView.onPageTouchEnd(self, event)
end


-- 所有旧版功能对IosPayGuide、AndroidSalesManager的引用不变
-- 所有新旧功能需要的对上述类的引用，替换成通过工厂方法获取相应类

----------------- GLOBAL FUNCTIONS ------------------
local panel = nil
function createMarketPanel(defaultIndex,tabConfig, closeCallback, coinsPageDefaultPayType)

	if StoreManager:getInstance():isEnabled() then
		return StoreManager:createStorePanel()
	end

	local IosPayGuideProxy = HappyCoinShopFactory:getInstance():getIosPayGuide()
	local MarketPanelProxy = HappyCoinShopFactory:getInstance():getMarketPanel()

	if panel and not panel.isDisposed then
		if __IOS or __WIN32 then
			if defaultIndex == 3 or IosPayGuideProxy:isInAppleVerification() then
				panel._triggerIapPromotion = true
			end
		end
		if __ANDROID and defaultIndex == 2 then
			panel.coinsPageDefaultPayType = coinsPageDefaultPayType
		end

		if defaultIndex then
			panel:slideToPage(defaultIndex)
		end
		panel.closeCallback = closeCallback
		return panel 
	end

	panel = MarketPanelProxy:create(defaultIndex, tabConfig, coinsPageDefaultPayType)
	panel.closeCallback = closeCallback
	if __IOS or __WIN32 then
		if defaultIndex == 3 or IosPayGuideProxy:isInAppleVerification() then
			panel._triggerIapPromotion = true
		end
	end



	return panel
end


MarketPanel = class(BasePanel)

function MarketPanel:getCurrentPanel()
	return panel
end

function MarketPanel:enableIapPromotion(index)
	if __IOS or __WIN32 then
		local IosPayGuideProxy = HappyCoinShopFactory:getInstance():getIosPayGuide()
		if index == 3 or IosPayGuideProxy:isInAppleVerification() then
			self._triggerIapPromotion = true
		end
	end
end

function MarketPanel:refresh()
	for i,v in ipairs(self.scrollLists) do
	 	for _,item in ipairs(v.items) do
	 		if item.refresh then
	 			item:refresh()
	 		end
	 	end
	 end 
end

function MarketPanel:create(defaultIndex, tabConfig)
	local instance = MarketPanel.new()
	instance:loadRequiredResource(PanelConfigFiles.market_panel)
	instance:init(defaultIndex, tabConfig)

	BuyObserver:sharedInstance():setMarketPanelRef(instance)

	return instance
end

function MarketPanel:dispose()
	PlatformConfig:setCurrentPayType()
	BasePanel.dispose(self)
	_G.use_ali_quick_pay = false
	_G.use_wechat_quick_pay = false
	panel = false
end

function MarketPanel:getViewBgInfo()
	local bgSize = self.viewBg:getGroupBounds().size
	local worldPos = self.viewBg:convertToWorldSpace(ccp(0,0))
	return worldPos, bgSize
end

function MarketPanel:setBuyGoldEnterFunc(func)
	self.buyGoldEnterFunc = func
end

function MarketPanel:setBuyGoldSuccessFunc(func)
	self.buyGoldSuccessFunc = func
end

function MarketPanel:init(defaultIndex, tabConfig)

	self.defaultIndex = defaultIndex or 1;
	self.goldPageBuilt = false
	local visibleOrigin = Director:sharedDirector():getVisibleOrigin()
	local visibleSize = Director:sharedDirector():getVisibleSize()

	local ui = self:buildInterfaceGroup('MarketPanel')
	assert(ui)
	self.ui = ui
	BasePanel.init(self, ui, 'MarketPanel')
	local topOffsetY = 0
	local titleAndCloseOffsetY = 0
	if _G.__EDGE_INSETS.top > 0 then
		topOffsetY = 20
		-- titleAndCloseOffsetY = 6
	end

	local viewBg = ui:getChildByName('viewBg')
	self.viewBg = viewBg
	viewBg:setOpacity(255*0.6)
	local bottomBlock = ui:getChildByName('bottomBlock')
	local viewRect = ui:getChildByName('viewRect')

	self.buyGoldButton = bottomBlock:getChildByName('buyGoldBtn')
	self.buyGoldButton:setButtonMode(true)
	self.buyGoldButton:setTouchEnabled(true, 0, true)
	self.buyGoldButton:ad(DisplayEvents.kTouchTap, function() self:onBuyGoldButtonTap() end)

	-- positions
	-- first: bottom alignement
	local bottomBlockPos = ccp(bottomBlock:getPositionX(), -(visibleSize.height - bottomBlock:getGroupBounds().size.height))
	bottomBlock:setPosition(bottomBlockPos)
	bottomBlock:getChildByName('size'):setVisible(false)

	-- second: viewHeight fits to screen
	local viewBgHeight = math.abs(viewBg:getPositionY() - bottomBlock:getPositionY())
	local viewHeight = math.abs(viewRect:getPositionY() - bottomBlock:getPositionY() - 20) -- 20 margin
	self.viewHeight = viewHeight


	local bg = ui:getChildByName('bg')
	local gradient = LayerGradient:create()
	gradient:setStartColor(ccc3(255, 216, 119))
	gradient:setEndColor(ccc3(247, 187, 129))
	gradient:setStartOpacity(255)
	gradient:setEndOpacity(255)
	-- if _G.isLocalDevelopMode then printx(0, 'visibleSize.width', visibleSize.width, 'visibleSize.height', visibleSize.height) end
	gradient:setContentSize(CCSizeMake(visibleSize.width, visibleSize.height+_G.__EDGE_INSETS.top+_G.__EDGE_INSETS.bottom))
	gradient:setPosition(ccp(visibleOrigin.x, -visibleSize.height-_G.__EDGE_INSETS.bottom))
	bg:getParent():addChildAt(gradient, bg:getZOrder())
	bg:removeFromParentAndCleanup(true) -- bg now is useless
	local size = viewBg:getGroupBounds().size
	viewBg:setPreferredSize(CCSizeMake(size.width, viewBgHeight))

	local giftPackBg = ui:getChildByName('giftPackBg')
	local offset = viewRect:getPositionY() - viewBg:getPositionY()
	local innerbg = giftPackBg:getChildByName('bg')
	innerbg:setPositionY(offset)
	innerbg:setPreferredSize(CCSizeMake(size.width, viewBgHeight - math.abs(offset)))
	giftPackBg:setVisible(false)
	self.giftPackBg = giftPackBg

	local title = ui:getChildByName('title')
	local cashPartUI = bottomBlock:getChildByName("cashPart")
	cashPartUI:getChildByName('size'):setVisible(false)
	-- local myCashStatic = cashPartUI:getChildByName('staticTxt')
	-- self.cashAmountTxt = cashPartUI:getChildByName('amountTxt') -- @modify

	self.cashAmountTxt = TextField:createWithUIAdjustment(cashPartUI:getChildByName("amountTxt_fontsize"), cashPartUI:getChildByName("amountTxt"))
	self.cashAmountTxt:removeFromParentAndCleanup(false)
	cashPartUI:addChild(self.cashAmountTxt)

	self.cashPartUI = cashPartUI
	title:setText(Localization:getInstance():getText('market.panel.title'))
	-- local rect = {x = title:getPositionX(), y = title:getPositionY(),
	-- 				width = 371.1, height = 65}
	-- InterfaceBuilder:centerInterfaceInbox(title, rect)
	local titleSize = title:getContentSize()
	local titleScale = 65 / titleSize.height
	title:setScale(titleScale)
	title:setPositionX((visibleSize.width - titleSize.width * titleScale) / 2)
	title:setPositionY(title:getPositionY() + titleAndCloseOffsetY)
	-- myCashStatic:setString(Localization:getInstance():getText('market.panel.mycash'))
	self.cashAmountTxt:setString(UserManager:getInstance():getUserRef():getCash())

	self.linkBtnHistory = bottomBlock:getChildByName("linkBtnHistory");
	self.linkBtnHistory:getChildByName("hit_area"):setVisible(false)
	local linkLabel = self.linkBtnHistory:getChildByName("label") 
	linkLabel:setString(Localization:getInstance():getText('consume.history.panel.title.rmb'))
	
	self.linkBtnHistory:setButtonMode(true)
	self.linkBtnHistory:ad(DisplayEvents.kTouchTap, function() self:showConsumeHistory() end)

	self.linkBtnHistory:setVisible(false);
	self.linkBtnHistory:setTouchEnabled(true, 0, true)

	self.ios_ali_link = bottomBlock:getChildByName('ios_ali_link')
	self.ios_ali_link:setTouchEnabled(true)
	self.ios_ali_link:ad(DisplayEvents.kTouchTap, function() 
		if self.needHuaWeiGuide == true then
			require 'zoo.panel.HuaWeiGuidePanel'
			HuaWeiGuidePanel:create():popout()
			DcUtil:UserTrack({ category='huaweipayguide', sub_category='click_guide' })
		else
			IosAliCartoonPanel:create():popout() 
		end
	end)
	self.ios_ali_link:setVisible(false)
	local headBand = ui:getChildByName("headBand")
	headBand:setPositionY(headBand:getPositionY() + topOffsetY)
	-- ensure that close button is at the TOP of all layers
	local closeBtn = ui:getChildByName('btnClose')
	closeBtn:setTouchEnabled(true, 0, true)
	closeBtn:setPositionY(closeBtn:getPositionY() + titleAndCloseOffsetY)
	local function __onClose(event)
		self:onCloseBtnTapped(event)
	end
	closeBtn:addEventListener(DisplayEvents.kTouchTap, __onClose)

	----------------------------------------------------------------
	-- Creating PagedView and VerticalScrollable views
	----------------------------------------------------------------
	local tabsPlaceholder = ui:getChildByName('tabRect')
	local tabsRect = tabsPlaceholder:getGroupBounds()
	local tabsZOrder = tabsPlaceholder:getZOrder()

	----------------------------------------
	-- build tabs and pages, insert items
	--
	self.config = MarketManager:sharedInstance():loadConfig(tabConfig)
	-- if _G.isLocalDevelopMode then printx(0, table.tostring(self.config)) end

	local viewPlaceholder = ui:getChildByName('viewRect')
	local viewRect = viewPlaceholder:getGroupBounds()
	self.viewRect = viewRect
	local function afterGotoPage(index)
		self:gotoTabPage(index);
	end

	local tabs = MarketPanelTab:create(self.config.tabs, function(...)
		if self.beforeGotoPage then
			self:beforeGotoPage(...)
		end
	end, afterGotoPage);

	tabs:setPosition(ccp(tabsPlaceholder:getPositionX(), tabsPlaceholder:getPositionY()))
	tabsPlaceholder:getParent():addChildAt(tabs, tabsZOrder) 
	self.tabs = tabs

	self.pages = {}

	local viewZOrder = viewPlaceholder:getZOrder()
	local numOfPages = #(self.config.tabs)

	local pagedView = CustomizedPV:create(viewRect.size.width, viewHeight, numOfPages, self.tabs, false, false)
	self.view = pagedView
	pagedView.pageMargin = 35
	pagedView:setIgnoreVerticalMove(false) -- important!
	self.tabs:setView(pagedView)

	for k_tab, v_tab in pairs(self.config.tabs) do 
		local page
		if v_tab.tabId == TabsIdConst.kHappyeCoin then
			page = Layer:create()
			page:setContentSize(CCSizeMake(viewRect.size.width, viewHeight))
			local text = TextField:create(Localization:getInstance():getText("dis.connect.warning.tips"),
				nil, 28, CCSizeMake(viewRect.size.width - 80, 0), kTextAlignment.kCCTextAlignmentCenter)
			local tSize = text:getContentSize()
			text:setColor(ccc3(157, 116, 75))
			text:setPositionXY(viewRect.size.width / 2, -viewHeight / 2)
			text:setVisible(false)
			page:addChild(text)
			self.happycoinsPage = page
			self.happyCoinNetworkTip = text
		else
			page = VerticalScrollable:create(viewRect.size.width, viewHeight, false, false)
			local itemContainer = self:buildPageByTabId(v_tab.tabId)
			page:setContent(itemContainer)
			page:setIgnoreHorizontalMove(false)

			RealNameManager:addConsumptionLabelToVerticalPage(page)
		end
		pagedView:addPageAt(page, v_tab.pageIndex)
		table.insert(self.pages, page)
	end
	local simpleClipping = SimpleClippingNode:create()
	simpleClipping:setContentSize(CCSizeMake(viewRect.size.width, viewHeight))
	simpleClipping:addChild(pagedView)
	simpleClipping:setPosition(ccp(viewPlaceholder:getPositionX(), viewPlaceholder:getPositionY() - viewHeight))
	viewPlaceholder:getParent():addChildAt(simpleClipping, viewZOrder)
	self.pagedView = pagedView
	self.tabs:onTabClicked(self.defaultIndex, 0);

	tabsPlaceholder:removeFromParentAndCleanup(true)
	viewPlaceholder:removeFromParentAndCleanup(true)

	self.simpleClipping = simpleClipping
end

function MarketPanel:updateCashPartPosition(isMiddle)
	if not self.cashPartUI or self.cashPartUI.isDisposed then return end
	-- if isMiddle then 
	-- 	self.cashPartUI:setPositionX(195)
	-- else
	-- 	self.cashPartUI:setPositionX(0)
	-- end	
end


function MarketPanel:setSource( source )
	self.source = source
end

function MarketPanel:createHappyCoinCountDown()
	local function createCountDown()
		local pos = self.tabs:getTabTitlePosByTabId(TabsIdConst.kHappyeCoin) 
		if pos and not self.happyCoinCountdown then  
			self.happyCoinCountdown = HappyCoinCountdown:create()
		    self.tabs.ui:addChild(self.happyCoinCountdown)
		    local size = self.happyCoinCountdown:getSize()
		    self.happyCoinCountdown:setPosition(ccp(pos.x - size.width/2, pos.y + size.height/2))
		    self.happyCoinCountdown:setVisible(false)
		end
	end
	if  __IOS or __WIN32 then
		local IosPayGuideProxy = HappyCoinShopFactory:getInstance():getIosPayGuide()
		if IosPayGuideProxy:isInFCashPromotion() then
			createCountDown()
		end
	elseif __ANDROID then
		local AndroidSalesMgrProxy = HappyCoinShopFactory:getInstance():getAndroidSalesManager()
		if AndroidSalesMgrProxy.getInstance():isInGoldSalesPromotion() then 
			createCountDown()
		end
	end
end

function MarketPanel:setHappyCoinCountDownVisible(isVisible)
	if self.isDisposed then return end
	if self.happyCoinCountdown and not self.happyCoinCountdown.isDisposed then 
		if  __IOS or __WIN32 then
			local IosPayGuideProxy = HappyCoinShopFactory:getInstance():getIosPayGuide()
			if IosPayGuideProxy:isInFCashPromotion() then
				self.happyCoinCountdown:setVisible(isVisible)
			else
				self.happyCoinCountdown:setVisible(false)
			end
		elseif __ANDROID then
			local AndroidSalesMgrProxy = HappyCoinShopFactory:getInstance():getAndroidSalesManager()
			if AndroidSalesMgrProxy.getInstance():isInGoldSalesPromotion() then
				self.happyCoinCountdown:setVisible(isVisible)
			else
				self.happyCoinCountdown:setVisible(false)
			end
		end
	end
end

function MarketPanel:showConsumeHistory()
	ConsumeHistoryPanel:create():popout()
end

function MarketPanel:isHappyCoinsTab(index)
	for i,v in ipairs(self.config.tabs) do
		if v.pageIndex == index then
			return v.tabId == TabsIdConst.kHappyeCoin;
		end
	end

	return false;
end


function MarketPanel:needHuaWeiShowGuide()
	if PlatformConfig:isPlatform(PlatformNameEnum.kHuaWei) then 
 		return not UserManager:getInstance().userExtend.payUser 
	end
	return false
end



function MarketPanel:gotoTabPage(index)
	self:setHappyCoinCountDownVisible(false)
	local function buildProductPage()
		if self.isDisposed then return end
		self.happyCoinNetworkTip:setVisible(false)
		if __ANDROID then 
			self:buildAndroidGoldPage()
		elseif __WP8 then 
			self:buildWP8GoldPage()
		else 
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
		self:updateCashPartPosition(false)
		self:setGoldFreeVisible(false)
		if (__IOS and not self.goldPageBuilt) or __WIN32 or __WP8 or not MarketManager:sharedInstance().productItems or
			not MarketManager:sharedInstance().gotRemoteList then
			self.happyCoinNetworkTip:setVisible(true)
			MarketManager:sharedInstance():getGoldProductInfo(buildProductPage);
		elseif not self.goldPageBuilt then
			buildProductPage()
		end
	else
		self:updateCashPartPosition(true)
		self:setHappyCoinCountDownVisible(true)
	end


end

function MarketPanel:slideToPage(index)
	if self.view then self.view:gotoPage(index) end
end

function MarketPanel:buildPageByTabId(tabId)
	local layout = nil
	local v_tab = nil
	for k, v in pairs(self.config.tabs) do 
		if v.tabId == tabId then
			v_tab = v
			break
		end
	end

	local function getHappyCoinsItem(goodID)
		local productItems = MarketManager:sharedInstance().productItems;
		for i,v in ipairs(productItems) do
			if v.productId == goodID then
				return v;
			end
		end

		return nil;
	end

	local marketGoods = {}
	if _G.isLocalDevelopMode then printx(0, "v_tab.goodsIds: ", #v_tab.goodsIds) end;	

	for k_goods, v_goods in pairs(v_tab.goodsIds) do
		local item = MetaManager:getInstance():getGoodMeta(v_goods)
		if not item then 
			item = getHappyCoinsItem(v_goods)
		end
		--if _G.isLocalDevelopMode then printx(0, table.tostring(item)) end
		if item and ( (not __IOS_FB) or (__IOS_FB and item.platform ~= 1) ) then -- 非PC独有的商品
			table.insert(marketGoods, item)
		end
	end

	if tabId == TabsIdConst.kHappyeCoin then --this is the tab for buying happycoinsbuildtab
		-- do nothing.
	elseif MarketManager:sharedInstance():shouldUseNewLogic() and tabId == 1 then
		
		layout = PropPage:create(self.config, self)
	elseif tabId == TabsIdConst.kGiftPack then
		local GiftPackPage = require 'zoo.panel.happyCoinShop.GiftPackPage'
		layout = GiftPackPage:create(self.config, self)
	elseif (not __IOS_FB and tabId == 0) or (__IOS_FB and tabId == 3) then -- special treatment
		layout = VerticalTileLayout:create(self.viewRect.size.width)
		layout:setItemHorizontalMargin(8) -- hard coded margin
		for k, v in pairs(marketGoods) do 
			local item = MarketPackItem:create(v.id)
			item:setParentView(self.view)
			layout:addItem(item)
			-- if _G.isLocalDevelopMode then printx(0, 'bounds', item:getGroupBounds()) end
		end

	else -- default 
		layout = GridLayout:create()
		
		layout:setColumn(4)
		layout:setWidth(self.viewRect.size.width)
		layout:setItemSize(CCSizeMake(0, 220))
		layout:setColumnMargin(0)
		layout:setRowMargin(20)
		layout:setPosition(12,0)

		for k, v in pairs(marketGoods) do 
			local item = MarketPropsItem:create(v.id)
			item:setParentView(self.view)
			layout:addItem(item)
			item:setScale(0.92)
		end
	end
	return layout
end

function MarketPanel:buildIOSGoldPage()
	if self.goldPageBuilt then return end
	self.goldPageBuilt = true

	local config = MarketManager:sharedInstance():getCoinsTab()
	local scroll = VerticalScrollable:create(self.viewRect.size.width, self.viewHeight, false, false)
	local layout = VerticalTileLayout:create(self.viewRect.size.width)
	layout:setItemHorizontalMargin(4)

	local d = 0	
	local otherGoodsItemTable = {}
	for k, v in pairs(config.goodsIds) do
		local function updateCashLabel()
			if self.isDisposed then return end
			self.cashAmountTxt:setString(UserManager:getInstance().user:getCash());

			if self.buyGoldSuccessFunc then self.buyGoldSuccessFunc() end 
		end

		local item = BuyGoldItem:create(v, updateCashLabel)

		item:setParentView(scroll)
		table.insert(otherGoodsItemTable, item)
		layout:addItem(item)
	end

	local function createOneYuanItem()
		local function buySuccessCallback()
            if self.isDisposed then return end
            if not layout.iosOneYuanItem or layout.iosOneYuanItem.isDisposed then return end 
            self.cashAmountTxt:setString(UserManager:getInstance().user:getCash())
            layout:removeItemAt(layout.iosOneYuanItem:getArrayIndex(), true)
            if IosPayGuide:isInFCashPromotion() then
                IosPayGuide:oneYuanFCashEnd()
                IosPayGuide:removeOneYuanFCashFlag()
            end

            if self.buyGoldSuccessFunc then self.buyGoldSuccessFunc() end
        end

        local function timeupCallback()
        	IosPayGuide:removeOneYuanFCashFlag()
        end

        if self.isDisposed then return end
        local iosOneYuanItem = IosOneYuanBuyGoldItem:create(IosPayGuide:getOneYuanFCashConfig(), IosPayGuide:getOneYuanFCashLeftSeconds(), buySuccessCallback, timeupCallback, self)
        iosOneYuanItem:setParentView(scroll)
        iosOneYuanItem:setOtherGoodsItemTable(otherGoodsItemTable)
        layout:addItemAt(iosOneYuanItem, 1)
        if scroll.content then
        	scroll:updateScrollableHeight()
        end
        iosOneYuanItem:playAnimation()
        layout.iosOneYuanItem = iosOneYuanItem

        self:createHappyCoinCountDown()
	end

	if IosPayGuide:isInFCashPromotion() then
		if not layout.iosOneYuanItem then
			createOneYuanItem()
		end
	elseif IosPayGuide:shouldShowMarketOneYuanFCash() and self._triggerIapPromotion then
		IosPayGuide:oneYuanFCashStart(
				function() 
					createOneYuanItem()
				end
			)
	end

	scroll:setContent(layout)
	scroll:setIgnoreHorizontalMove(false)
	self.happycoinsPage:addChild(scroll)

	RealNameManager:addConsumptionLabelToVerticalPage(scroll)
end

function MarketPanel:buildWP8GoldPage()
	if self.goldPageBuilt then return end
	self.goldPageBuilt = true

	local config = MarketManager:sharedInstance():getCoinsTab()
	local scroll = VerticalScrollable:create(self.viewRect.size.width, self.viewHeight, false, false)
	local layout = VerticalTileLayout:create(self.viewRect.size.width)
	layout:setItemHorizontalMargin(4)

	local function isSupport( id )
		for _,v in pairs(Wp8SupportedPayments) do
			if v then
				for _, sid in ipairs(v) do
					if id == sid then
						return true
					end
				end
			end
		end
	end

	local d = 0	
	for k, v in pairs(config.goodsIds) do
		local function updateCashLabel()
			if self.isDisposed then return end
			self.cashAmountTxt:setString(UserManager:getInstance().user:getCash());
		end
		if isSupport(v.id) then
			local item = BuyGoldItem:create(v, updateCashLabel)
			item:setParentView(scroll)
			layout:addItem(item)
		end
	end
	scroll:setContent(layout)
	scroll:setIgnoreHorizontalMove(false)
	self.happycoinsPage:addChild(scroll)

	RealNameManager:addConsumptionLabelToVerticalPage(scroll)
end

function MarketPanel:sortGoldBarIndex(tables)
	local uid = tonumber(UserManager.getInstance().uid) or 0

	local function sortFunc(item1,item2)
		if item1 and item1[1] and item1[1].newSort and item2 and item2[1] and item2[1].newSort then

			if  (PaymentManager:getInstance():getDefaultPayment() == Payments.ALIPAY or 
				PaymentManager:getInstance():getDefaultPayment() ~= Payments.WECHAT and uid%2 ~= 0)
				or PaymentManager:getInstance():checkHaveAliAPP() then

				if item1.name == "wechat_2" and item2.name == "alipay_2" then
					return false
				end

				if item1.name == "alipay_2" and item2.name == "wechat_2" then
					return true
				end

				return item1[1].newSort < item2[1].newSort
			else
				return item1[1].newSort < item2[1].newSort
			end
		else
			return false 
		end
	end

	if tables then 
		table.sort(tables, sortFunc)
	end

	printx( 3 , ' getDefaultPayment()', PaymentManager:getInstance():getDefaultPayment())

	return tables
end

function MarketPanel:setGoldFreeVisible( visible )
	local goldIndex = 3
	for i,v in ipairs(self.config.tabs) do
		if v.tabId == TabsIdConst.kHappyeCoin then
			goldIndex = v.pageIndex
		end
	end

	if self.tabs.tabs[goldIndex] then
		self.tabs.tabs[goldIndex].free:setVisible(visible)
	end
end

function MarketPanel:getJiFenHight( ... )
	return self.jifenHight or 0
end

function MarketPanel:buildJifenUI( ... )
	if SupperAppManager and SupperAppManager:checkEntry() == true and SupperAppManager:isInitSucceeded() == true then
		HomeScene:sharedInstance():showJiFenEntry()

		local gradient = Layer:create()
		gradient:setPosition(ccp(0, -200))

		local sprite = Sprite:createWithSpriteFrameName("supperapp_banner instance 10000")
		local scale = sprite:getContentSize().width / self.viewRect.size.width
		sprite:setAnchorPoint(ccp(0,0))
		sprite:setPositionX(10)
		sprite:setPositionY(-10)
		sprite:setScale(scale)
		gradient:addChild(sprite)

		self.jifenHight = scale * sprite:getContentSize().height

		local onTouchTap = function ( evt )
			DcUtil:UserTrack({ category='activity', sub_category='push_2'})
			SupperAppManager:showJiFenView()
		end

		gradient:addEventListener(DisplayEvents.kTouchTap, onTouchTap, self)
		gradient:setTouchEnabled(true)
		self.happycoinsPage:addChild(gradient)
	else
		self.jifenHight = nil
		HomeScene:sharedInstance():shutdownJiFenEntry()
	end
end

function MarketPanel:checkAndroidDiscount()
	return true
end

function MarketPanel:buildAndroidGoldPage()
	if self.goldPageBuilt then return end
	self.goldPageBuilt = true

	--积分墙ui
	self:buildJifenUI()

	local tables = MarketManager:sharedInstance().productItems
	tables = self:sortGoldBarIndex(tables)
	local num = #tables
	for k, v in ipairs(tables) do
		if not v.enabled then num = num - 1 end
	end

	local oneYuanItemParamTable = {}
	local function getOneYuanItemParam(paymentType, layout, items, scroll, title, titles)
		local paramTable = {}
		paramTable.paymentType = paymentType
		paramTable.layout = layout
		paramTable.items = items
		paramTable.scroll = scroll
		paramTable.title = title
		paramTable.titles = titles
		return paramTable
	end

	local titles, lists, posIndex = {}, {}, 1
	self.scrollLists = lists
	for k, config in ipairs(tables) do
		if _G.isLocalDevelopMode then printx(0, "got list", config.payType, config.name, config.enabled, #config) end
		if config.enabled then
			self.builder = InterfaceBuilder:createWithContentsOfFile(PanelConfigFiles.market_panel)
			local title = self.builder:buildGroup("marketpanel_buygoldpagetitle")
			local titleSize = title:getGroupBounds().size
			local text = title:getChildByName("text")
			if config.name == "ingame" and PlatformConfig:isPlatform(PlatformNameEnum.kMiPad) then
				text:setString(Localization:getInstance():getText("market.panel.buy.gold.title.mi"))
			elseif PlatformConfig:isPlatform(PlatformNameEnum.kWechatAndroid) then 
				text:setString(Localization:getInstance():getText("market.panel.buy.gold.title.jp_msdk"))
			else
				text:setString(Localization:getInstance():getText("market.panel.buy.gold.title."..tostring(config.name)))
			end
			title.textName = config.name
			local arrr = title:getChildByName("arrr")
			arrr:setVisible(false)
			title.arrr = arrr
			local arrd = title:getChildByName("arrd")
			arrd:setVisible(false)
			title.arrd = arrd

			local titleTip = title:getChildByName('thirdPayGiveMore')
			local titleTipNum = titleTip:getChildByName("num")

			local payment = PaymentBase:getPayment(config.payType)
			if payment.mode == PaymentMode.kThirdParty then
				if payment:getPaymentLevel() == PaymentLevel.kLvOne then 
					local maxExtra = 0
					for m,n in ipairs(config) do
						local tempExtra = n.extraCash or 0
						if maxExtra < tempExtra then
							maxExtra = tempExtra
						end
					end
					if titleTipNum then 
						titleTipNum:setString(maxExtra)
					end
				else
					titleTip:setVisible(false)
					title:getChildByName('thirdPayDiscount'):setVisible(false)
				end
			else
				title.sign = "smsGoldPage"
				titleTip:setVisible(false)
				title:getChildByName('thirdPayDiscount'):setVisible(false)
			end

			title:setPositionX((self.viewRect.size.width - titleSize.width) / 2)
			title.expandY = (posIndex - 1) * (-titleSize.height) - self:getJiFenHight()
			title:setPositionY(title.expandY)
			title.hideY = (num - posIndex + 1) * titleSize.height - self.viewHeight
			self.happycoinsPage:addChild(title)
			table.insert(titles, title)
			title.name = #titles
			local scroll = VerticalScrollable:create(self.viewRect.size.width, self.viewHeight - self:getJiFenHight() - num * titleSize.height - 10, true, false)
			local layout = VerticalTileLayout:create(self.viewRect.size.width)
			layout:setItemHorizontalMargin(4)

			local items = {}

			if config.name ~= "ingame" and payment:getPaymentLevel() == PaymentLevel.kLvOne then
				table.insert(oneYuanItemParamTable, getOneYuanItemParam(config.payType, layout, items, scroll, title, titles))
			end

			if config.payType == Payments.WECHAT then
				if WechatQuickPayLogic:getInstance():isMaintenanceEnabled() then
					self:buildAndroidQuickPayCheckItem(Payments.WECHAT, layout, items, scroll)
				end
			elseif config.payType == Payments.ALIPAY and 
					PaymentManager.getInstance():shouldShowAliQuickPay() and 
					(UserManager:getInstance():getAliKfDailyLimit() > 0 and UserManager:getInstance():getAliKfMonthlyLimit() > 0) then
				self:buildAndroidQuickPayCheckItem(Payments.ALIPAY, layout, items, scroll)
			end

			for k, v in ipairs(config) do
				local function updateCashLabel(payType)
					if self.isDisposed then return end
					self.cashAmountTxt:setString(UserManager:getInstance().user:getCash())
					local payment = PaymentBase:getPayment(payType)
					if payment.mode == PaymentMode.kThirdParty then
						self:removeAndroidOneYuanItems(titles)
					end
					WechatFriendPanel:clearCount()
					if payType == Payments.ALIPAY and (UserManager:getInstance():getAliKfDailyLimit() <= 0 or UserManager:getInstance():getAliKfMonthlyLimit() <= 0) then
						self:removeAndroidQuickPayCheckItem(layout, items, Payments.ALIPAY)
					end
				end

				local failCallback = nil

				if self:isNeedWechatFriendPay() then
					failCallback = function (itemData, lastFailedItem, errCode)
						self:tryPopReBuyPanel(itemData, lastFailedItem, errCode)
					end
				end

				local item = BuyGoldItem:create(v, updateCashLabel, failCallback)

				item:setParentView(scroll)
				layout:addItem(item)
				table.insert(items, item)
			end
			scroll:setContent(layout)
			scroll:setIgnoreHorizontalMove(false)
			scroll:setPositionY(title.expandY - titleSize.height - 5)
			self.happycoinsPage:addChild(scroll)
			scroll.items = items
			table.insert(lists, scroll)
			scroll.name = #lists
			posIndex = posIndex + 1

			RealNameManager:addConsumptionLabelToVerticalPage(scroll)
		end
	end

	self:buildAndroidOneYuanItem(oneYuanItemParamTable)

	local function onTitleTapped(evt)
		if not evt.target then return end
		local index = tonumber(evt.target.name)
		if _G.isLocalDevelopMode then printx(0, "onTitleTapped", index) end
		if #lists[index].items <= 0 then
			CommonTip:showTip(Localization:getInstance():getText("market.panel.buy.gold.no.network"))
			return
		end
		for k, v in ipairs(titles) do
			if k == index then
				v:setPositionY(v.expandY)
				v.arrr:setVisible(false)
				v.arrd:setVisible(true)
				v:setTouchEnabled(false)
			elseif k < index then
				v:setPositionY(v.expandY)
				v.arrr:setVisible(true)
				v.arrd:setVisible(false)
				v:setTouchEnabled(true)
			elseif k > index then
				v:setPositionY(v.hideY)
				v.arrr:setVisible(true)
				v.arrd:setVisible(false)
				v:setTouchEnabled(true)
			end
		end
		for k, v in ipairs(lists) do
			if k == index then
				v:setVisible(true)
				for k, v in ipairs(v.items) do v:enableClick() end
			else
				v:setVisible(false)
				for k, v in ipairs(v.items) do v:disableClick() end
			end
		end

		local scene = Director:sharedDirector():getRunningScene()
		if scene and scene.goldItemMaskLayer and not scene.goldItemMaskLayer.isDisposed then 
			scene.goldItemMaskLayer:setTouchEnabled(false)
		end
	end
	for k, v in ipairs(titles) do
		v:setTouchEnabled(true)
		if not v:hasEventListener(DisplayEvents.kTouchTap, onTileTapped) then
			v:addEventListener(DisplayEvents.kTouchTap, onTitleTapped)
		end
	end
	if _G.isLocalDevelopMode then printx(0, "title length", #titles) end
	onTitleTapped({target = titles[1]})
	PaymentNetworkCheck.getInstance():check(function ()
		-- do nothing 
	end, function ()
		if self.isDisposed then return end
		for i,v in ipairs(titles) do
			if v.sign == "smsGoldPage" then 
				onTitleTapped({target = v})
				return
			end
		end
	end)


	

end

function MarketPanel:buildAndroidOneYuanItem(paramTable)
	if not paramTable or #paramTable <= 0 then return end
	local function getAnimAction(ui)
		ui:setAnchorPointCenterWhileStayOrigianlPosition()
		local deltaTime = 0.9
		local scaleX = ui:getScaleX()
		local scaleY = ui:getScaleY()
		local animations = CCArray:create()
		animations:addObject(CCScaleTo:create(deltaTime, scaleX * 0.78, scaleY * 0.93))
		animations:addObject(CCScaleTo:create(deltaTime, scaleX * 0.91, scaleY * 0.86))
		animations:addObject(CCScaleTo:create(deltaTime, scaleX * 0.78, scaleY * 0.93))
		animations:addObject(CCScaleTo:create(deltaTime, scaleX * 0.91, scaleY * 0.86))
		return CCRepeatForever:create(CCSequence:create(animations))
	end

	local function createOneYuanItem()
		for i,v in ipairs(paramTable) do
			local payment = v.paymentType
			local layout = v.layout
			local items = v.items
			local scroll = v.scroll
			local title = v.title
			local titles = v.titles

			local titleTip = title:getChildByName('thirdPayGiveMore')
			local discountImage = title:getChildByName('thirdPayDiscount')
			discountImage:setPositionX(322)
			discountImage:runAction(getAnimAction(discountImage))
			titleTip:setVisible(false)

			local function buySuccessCallback()
				-- AndroidSalesManager.getInstance():sendSeverGoldSalesBuyed()
				if self.isDisposed then return end
				AndroidSalesManager.getInstance():goldSalesEnd()
				self:removeAndroidOneYuanItems(titles)
				self.cashAmountTxt:setString(UserManager:getInstance().user:getCash())
			end
			local secondsLeft = AndroidSalesManager.getInstance():getGoldSalesLeftSeconds()
			local oneYuanItem = AndroidOneYuanBuyGoldItem:create(secondsLeft, 10, 90, 18, payment, buySuccessCallback, self)
			oneYuanItem.stopAction = function ()
				titleTip:setVisible(true)
				discountImage:setVisible(false)
			end

			oneYuanItem:setParentView(scroll)
			layout:addItemAt(oneYuanItem, 1)
	        if scroll.content then
	        	scroll:updateScrollableHeight()
	        end
			table.insert(items, oneYuanItem)
			oneYuanItem:setPositionX(oneYuanItem:getPositionX() + 10)
			title.discountBuyGoldItem = oneYuanItem
			title.layout = layout

			if AndroidSalesManager.getInstance():getShowOneYuanItemAni() then 
				oneYuanItem:playAnimation()
				AndroidSalesManager.getInstance():setShowOneYuanItemAni(false)
			end
		end

		self:createHappyCoinCountDown()
	end

	local function triggerSucc()
		createOneYuanItem()
		AndroidSalesManager.getInstance():showAndroidSalesPromotion()
	end

	if AndroidSalesManager.getInstance():isInGoldSalesPromotion() then 
		createOneYuanItem()
	elseif AndroidSalesManager.getInstance():shouldTriggerAndroidSales() then 
		AndroidSalesManager.getInstance():triggerSalesPromotion(AndroidSalesPromotionLocation.kSpecial, triggerSucc)
	end
end

-- 三方买完之后，及时删除打折item
function MarketPanel:removeAndroidOneYuanItems(titles)
	if not titles then return end
	for k, v in pairs(titles) do
		if v.discountBuyGoldItem and not v.discountBuyGoldItem.isDisposed and v.layout then
			if v.discountBuyGoldItem.stopAction and type(v.discountBuyGoldItem.stopAction) == "function" then
				v.discountBuyGoldItem.stopAction()
			end
			v.layout:removeItemAt(v.discountBuyGoldItem:getArrayIndex(), true)
			v.discountBuyGoldItem = nil
		end
	end
end

function MarketPanel:removeAndroidQuickPayCheckItem(layout, items, payment)
	if payment == Payments.ALIPAY then
		if layout and not layout.isDisposed and self.aliQuickPayCheckItem and not self.aliQuickPayCheckItem.isDisposed then
			if items then
				for k, v in pairs(items) do
					if v == self.aliQuickPayCheckItem then
						table.remove(items, k)
						break
					end
				end
			end
			layout:removeItemAt(self.aliQuickPayCheckItem:getArrayIndex(), true)
			self.aliQuickPayCheckItem = nil
		end
	elseif payment == Payments.WECHAT then
		if layout and not layout.isDisposed and self.wechatQuickPayCheckItem and not self.wechatQuickPayCheckItem.isDisposed then
			if items then
				for k, v in pairs(items) do
					if v == self.wechatQuickPayCheckItem then
						table.remove(items, k)
						break
					end
				end
			end
			layout:removeItemAt(self.wechatQuickPayCheckItem:getArrayIndex(), true)
			self.wechatQuickPayCheckItem = nil
		end
	end
end

function MarketPanel:buildAndroidQuickPayCheckItem(payment, layout, items, scroll)
	local AliQuickPayGuide = require "zoo.panel.alipay.AliQuickPayGuide"
	local WechatQuickPayGuide = require "zoo.panel.wechatPay.WechatQuickPayGuide"
	
	local function clickCallback(value)
		if payment == Payments.ALIPAY then
			_G.use_ali_quick_pay = value
			if value == false then 
                if AliQuickPayGuide.isGuideTime() then
                    AliQuickPayGuide.updateGuideTimeAndPopCount()
                else
                    AliQuickPayGuide.updateOnlyGuideTime()
                end
            end
		elseif payment == Payments.WECHAT then
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
	local quickPayCheckItem = AndroidQuickPayCheckItem:create(payment, clickCallback)
	if payment == Payments.ALIPAY then
		if AliQuickPayGuide.isGuideTime() then 
			quickPayCheckItem:setCheck(true)
			_G.use_ali_quick_pay = true
		else
			quickPayCheckItem:setCheck(false)
			_G.use_ali_quick_pay = false
		end
		self.aliQuickPayCheckItem = quickPayCheckItem
	elseif payment == Payments.WECHAT then
		printx( 3 , ' WechatQuickPayGuide.isGuideTime() ', WechatQuickPayGuide.isGuideTime())
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
		self.wechatQuickPayCheckItem = quickPayCheckItem
	end
	quickPayCheckItem:setParentView(scroll)
	layout:addItem(quickPayCheckItem)
	table.insert(items, quickPayCheckItem)
end

--这里待修改
function MarketPanel:buildAndroidHelpLinkItem(payment, layout, items, scroll)
	local function clickCallback()
		if payment == Payments.WECHAT then
			DcUtil:UserTrack({category = "pay", sub_category = "wechat_pay_help"}, true)
		elseif payment == Payments.ALIPAY then
			DcUtil:UserTrack({category = "pay", sub_category = "alipay_pay_help"}, true)
		end
	end
	local thirdPayLinkItem = ThirdPayLinkItem:create(localize('market.panel.buy.gold.help'), ThirdPayGuideLogic:getHelpAddress(payment), clickCallback)
	thirdPayLinkItem:setParentView(scroll)
	layout:addItem(thirdPayLinkItem)
	-- table.insert(items, thirdPayLinkItem)
end

function MarketPanel:updateCoinLabel()
	self.cashAmountTxt:setString(UserManager:getInstance():getUserRef():getCash())
	self:dispatchEvent(Event.new(kPanelEvents.kUpdate, nil, self))
end

function MarketPanel:onBuyGoldButtonTap()
	self.tabs:onTabClicked(MarketManager:sharedInstance():getHappyCoinPageIndex() or 1);
end

function MarketPanel:onEnterHandler(event)
	BasePanel.onEnterHandler(self, event)
	if event == "enter" then
		if self.buyGoldEnterFunc then 
			self.buyGoldEnterFunc()
		end
	elseif event == "exit" then
	end
	self.buyGoldEnterFunc = nil
end

function MarketPanel:popout()
	if not self.privateScene then
		self.privateScene = Scene:create()
		self.privateScene.onKeyBackClicked = function ()
			-- if _G.isLocalDevelopMode then printx(0, 'onKeyBackClicked') end
			if not self.isDisposed then
				self:onCloseBtnTapped()
			end
		end
		self.privateScene.onEnter = function ()
			BroadcastManager:getInstance():onEnterScene(self)
		end
	end

	local drt = Director:sharedDirector()
	drt:pushScene(self.privateScene)

	local vo = drt:getVisibleOrigin()
	local vs = drt:getVisibleSize()
	self:setPosition(ccp(vo.x, vo.y + vs.height))
	self.privateScene:addChild(self)

	if __ANDROID then 
		local touchLayerPos, touchLayerSize = self:getViewBgInfo()
		local touchLayer = LayerColor:create()
	    touchLayer:setOpacity(0)
	    touchLayer:changeWidthAndHeight(touchLayerSize.width, touchLayerSize.height)
	    touchLayer:setPosition(touchLayerPos)
	    touchLayer:setTouchEnabled(false)
	    self.privateScene.goldItemMaskLayer = touchLayer
		self.privateScene:addChild(touchLayer)
	end
	self.allowBackKeyTap = true
end

function MarketPanel:onCloseBtnTapped()
	self.buyGoldEnterFunc = nil
	self.buyGoldSuccessFunc = nil

	-- if _G.isLocalDevelopMode then printx(0, 'onCloseBtnTapped') end
	if self.privateScene then
		self:dispatchEvent(Event.new(kPanelEvents.kClose, nil, self))
		Director:sharedDirector():popScene()
		self.allowBackKeyTap = false
		self.privateScene = nil
	end

	if self.closeCallback then
		self.closeCallback()
	end


	local home = HomeScene:sharedInstance()
	if home then home:updateFriends() end
end

function MarketPanel:tryPopReBuyPanel(itemData, lastFailedItem, errCode)
	if self:isNeedWechatFriendPay() then
		local wechatFriendPanel = WechatFriendPanel:create(itemData, lastFailedItem, errCode)
		wechatFriendPanel:popout()
	end
end

function MarketPanel:isNeedWechatFriendPay()
	if self.__isNeedWechatFriendPay ~= nil then
		return self.__isNeedWechatFriendPay
	end

	if _G.isLocalDevelopMode then printx(0, 'niu2x isNeedWechatFriendPay enable: ', MaintenanceManager:getInstance():isEnabled("WeChatFri")) end
	if _G.isLocalDevelopMode then printx(0, 'niu2x isNeedWechatFriendPay value: ', MaintenanceManager:getInstance():getValue("WeChatFri")) end
	if _G.isLocalDevelopMode then printx(0, 'niu2x isNeedWechatFriendPay uid: ', UserManager.getInstance().uid) end

	if __ANDROID and MaintenanceManager:getInstance():isEnabled("WeChatFri") == true then
		local percentAllowed = MaintenanceManager:getInstance():getValue("WeChatFri") or "0"
		percentAllowed = tonumber(percentAllowed) or 0
		local userId = UserManager.getInstance().uid or "0"
		userId = tonumber(userId) % 100
		if _G.isLocalDevelopMode then printx(0, 'niu2x userId ', userId) end
		if _G.isLocalDevelopMode then printx(0, 'niu2x percentAllowed ', userId) end
		if userId < percentAllowed then
			if _G.isLocalDevelopMode then printx(0, 'niu2x isNeedWechatFriendPay true') end
			self.__isNeedWechatFriendPay = true
			return self.__isNeedWechatFriendPay
		end
	end
	if _G.isLocalDevelopMode then printx(0, 'niu2x isNeedWechatFriendPay false') end
	self.__isNeedWechatFriendPay = false
	return self.__isNeedWechatFriendPay
end

function MarketPanel:haveRmbConsumeHistory()
	-- 这个函数本来是查询 玩家有没有cashlog
	-- 但后来觉得cashlog不好查 所以改为 查询玩家是不是非付费用户
	return UserManager:getInstance().userExtend.payUser
end


BuyObserver = class()
local _buyObserver = nil

function BuyObserver:sharedInstance()
	if not _buyObserver then
		_buyObserver = BuyObserver:create()
	end
	return _buyObserver
end

function BuyObserver:create()
	local instance = BuyObserver.new()
	return instance
end

function BuyObserver:setMarketPanelRef(ref)
	self.marketPanelRef = ref
end

function BuyObserver:onBuySuccess()
	if self.marketPanelRef and not self.marketPanelRef.isDisposed then
		self.marketPanelRef:updateCoinLabel()
	end
	local scene = HomeScene:sharedInstance()
	local button = scene.goldButton
	button:updateView()
end


-------------------------------------------------------------------------
-- Class MarketPanelTab
-------------------------------------------------------------------------

MarketPanelTab = class(BaseUI)

function MarketPanelTab:create(config, beforeGotoPage, afterGotoPage)
	local instance = MarketPanelTab.new()
	instance:loadRequiredResource(PanelConfigFiles.market_panel)
	instance:init(config,beforeGotoPage,afterGotoPage)
	return instance
end

function MarketPanelTab:loadRequiredResource(config)
	self.builder = InterfaceBuilder:create(config)
end

function MarketPanelTab:init(config, beforeGotoPage, afterGotoPage)
	local ui = self.builder:buildGroup('market_tabs')
	-- if _G.isLocalDevelopMode then printx(0, ui) end
	BaseUI.init(self, ui)
	-- if _G.isLocalDevelopMode then printx(0, table.tostring(config)) end
	-- local config = {
	-- 	{tabId = 1, pageIndex = 1, key = '礼包'},
	-- 	{tabId = 1, pageIndex = 1, key = '礼包'},
	-- 	{tabId = 1, pageIndex = 1, key = '礼包'},
	-- }

	self.animDuration = 0.25

	self.beforeGotoPage = beforeGotoPage;
	self.afterGotoPage = afterGotoPage;
	self.config = config
	self.colorConfig = {
		normal = ccc3(157, 116, 75),
		focus = ccc3(243, 93, 99)
	}

	self.curIndex = 1

	self.tabs = {}
	local count = #config

	local function _tapHandler(event)
		local index = tonumber(event.context)
		self:onTabClicked(index)
	end

	for i=1, count do
		local tab = ui:getChildByName('market_tabButton'..i)
		tab.txt = tab:getChildByName('txt')
		tab.locator = tab:getChildByName('arrowLocator')
		tab.locator:setVisible(false)
		tab.rect = tab:getChildByName('rect')
		tab.rect:setVisible(false)
		tab.txt:setString(Localization:getInstance():getText(config[i].key))
		tab:ad(DisplayEvents.kTouchTap, _tapHandler, config[i].pageIndex)
		tab:setTouchEnabled(true, 0, true)
		tab:setButtonMode(false)
		tab.normalPos = ccp(tab.txt:getPositionX(), tab.txt:getPositionY())
		tab.focusPos = ccp(tab.txt:getPositionX() , tab.txt:getPositionY() + 15)
		tab.iconLimit = tab:getChildByName('iconLimit');
		local textLimit = tab.iconLimit:getChildByName("tfLimit"):getChildByName("text");
		textLimit:setString(Localization:getInstance():getText("market.panel.timeLimited"));
		tab.iconLimit:setVisible(config[i].isTimeLimited);
		tab.free = tab:getChildByName('free');
		tab.free:setVisible(false)
		tab.promotionFlag = tab:getChildByName('promotion')
		tab.promotionFlag:setVisible(false)
		tab.tabId = config[i].tabId
		tab.monthPayFlag = tab:getChildByName("monthPay")
		tab.monthPayFlag:setVisible(false)

		tab.pennyFlag = tab:getChildByName('penny')
		tab.pennyFlag:setVisible(false)

		tab.renewFlag = tab:getChildByName("xuding")
		tab.renewFlag:setVisible(false)
		tab.couponflag = tab:getChildByName("coupon")
		tab.couponflag:setVisible(false)

		tab.starbankflag = tab:getChildByName("starbank")
		tab.starbankflag:setVisible(false)

		tab.giftpackflag = tab:getChildByName("giftpack")
		tab.giftpackflag:setVisible(false)


		table.insert(self.tabs, tab)
	end

	-------------------------------------------
	-- center tabs positions
	--
	local length = ui:getGroupBounds().size.width
	for k, v in pairs(self.tabs) do
		v:setPositionX(length * k / (count + 1))
	end

	for i=count+1, 5 do
		local tab = ui:getChildByName('market_tabButton'..i)
		tab:removeFromParentAndCleanup(true)
		-- tab:setVisible(false)
	end

	self.arrow = ui:getChildByName('market_tabArrow')
	local x, y = self:getTabPosition(1)
	self.arrow:setPositionXY(x, y)

	--self:goto(1)
end

function MarketPanelTab:getTabPosition(index)
	local tab = self.tabs[index]
	if tab then 
		local pos = tab.locator:getPosition()
		local worldPos = tab:convertToWorldSpace(ccp(pos.x, pos.y))
		local realPos = tab:getParent():convertToNodeSpace(ccp(worldPos.x, worldPos.y))
		return realPos.x, realPos.y
	end
	return 0, 0
end

function MarketPanelTab:setView(view)
	self.view = view
end

function MarketPanelTab:next()
	if self.curIndex == #self.config then return end
	self:goto(self.curIndex + 1)
end

function MarketPanelTab:prev()
	if self.curIndex == 1 then return end
	self:goto(self.curIndex - 1)
end

function MarketPanelTab:goto(index)
	local count = #self.config
	if not index or type(index) ~= 'number' or index > count or index < 1 then
		return 
	end
	local curTab = self.tabs[self.curIndex]
	local nextTab = self.tabs[index]
	if curTab then
		curTab.txt:stopAllActions()
		curTab.txt:runAction(self:_getTabLooseFocusAnim(curTab))
	end
	local function onAnimationFinish()
		if self.afterGotoPage then
			self.afterGotoPage(index);
			--to make sure that the afterGotoPage can only be called once.
			--self.afterGotoPage = nil;
		end
	end

	if nextTab then 
		nextTab.txt:stopAllActions()
		local actions = CCSequence:createWithTwoActions(self:_getTabOnFocusAnim(nextTab), CCCallFunc:create(onAnimationFinish))
		nextTab.txt:runAction(actions);
	end
	if self.arrow then
		self.arrow:stopAllActions()
		self.arrow:runAction(self:_getArrowAnim(index))
	end
	self.curIndex = index
end

function MarketPanelTab:onTabClicked(index, duration)
	local panel = MarketPanel:getCurrentPanel()

	if index == MarketManager:sharedInstance():getHappyCoinPageIndex()  
	   and PromotionManager
	   and PromotionManager:getInstance():isPennyPayEnabled()
 	   and panel 
	then
		panel.coinsPageDefaultPayType = Payments.ALIPAY
	end

	if self.beforeGotoPage then
		self.beforeGotoPage(index);
	end

	if panel then 
		panel:enableIapPromotion(index) 
	end

	if self.view then self.view:gotoPage(index, duration) end
	--[[if self.afterGotoPage then
		self.afterGotoPage(index);
	end]]--
end

function MarketPanelTab:_getArrowAnim(index)
	local tab = self.tabs[index]
	if tab then 
		local pos = tab.locator:getPosition()
		local worldPos = tab:convertToWorldSpace(ccp(pos.x, pos.y))
		local realPos = tab:getParent():convertToNodeSpace(ccp(worldPos.x, worldPos.y))
		local move = CCMoveTo:create(self.animDuration, ccp(realPos.x, realPos.y))
		local ease = CCEaseSineOut:create(move)
		return ease
	end
	return nil
end

function MarketPanelTab:_getTabOnFocusAnim(tab)
	if not tab then return nil end
	local tint = CCTintTo:create(self.animDuration, self.colorConfig.focus.r, self.colorConfig.focus.g, self.colorConfig.focus.b)
	local scale = CCScaleTo:create(self.animDuration, 34/28)
	local move = CCMoveTo:create(self.animDuration, tab.focusPos)
	local array = CCArray:create()
	array:addObject(tint)
	array:addObject(scale)
	array:addObject(move)
	local spawn = CCEaseSineOut:create(CCSpawn:create(
	                  array
	                             ))
	return spawn
end

function MarketPanelTab:_getTabLooseFocusAnim(tab)
	if not tab then return nil end
	local tint = CCTintTo:create(self.animDuration, self.colorConfig.normal.r, self.colorConfig.normal.g, self.colorConfig.normal.b)
	local scale = CCScaleTo:create(self.animDuration, 1)
	local move = CCMoveTo:create(self.animDuration, tab.normalPos)
	local array = CCArray:create()
	array:addObject(tint)
	array:addObject(scale)
	array:addObject(move)
	local spawn = CCEaseSineOut:create(CCSpawn:create(
	                  array
	                             ))
	return spawn
end

function MarketPanelTab:getTabTitlePosByTabId(tabId)
	for k,v in pairs(self.tabs) do
		if v.tabId == tabId then 
			return v:getPosition()
		end
	end
end