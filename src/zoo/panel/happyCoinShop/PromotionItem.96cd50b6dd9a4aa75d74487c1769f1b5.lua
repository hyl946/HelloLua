local utils = require 'zoo.panel.happyCoinShop.utils'

local function wrapText(textUI)
	local label = textUI:getChildByName('label')
	local size = textUI:getChildByName('size')
	local text = TextField:createWithUIAdjustment(size, label)
	textUI:addChild(text)
	return text
end


local PropsBar = class(HorizontalTileLayoutWithAlignment)

function PropsBar:create(propItems, builder)
	local instance = PropsBar.new()
	instance:init(propItems, builder)
	return instance
end


function PropsBar:init(propItems, builder)
	HorizontalTileLayoutWithAlignment.init(self, 280, 90)

	table.each(propItems, function(item)
		local icon = ResourceManager:sharedInstance():buildItemGroup(item.itemId)
		local ui = builder:buildGroup('newWindShop/promotion/item')
		local hole = ui:getChildByName('hole')
		if item.itemId == 10013 or item.itemId == 10004 or item.itemId == 10018 then
			hole:setPositionX(hole:getPositionX() + 4)
		end
		ui:setScale(1.05)
		local iconHolder = ui:getChildByName('iconHolder')
		utils.scaleNodeToSize(icon, iconHolder:getGroupBounds().size)
		ui:addChildAt(icon, 1)
		iconHolder:removeFromParentAndCleanup(true)
		local numLabel = wrapText(ui:getChildByName('num'))
		numLabel:changeFntFile('fnt/skip_level.fnt')
		numLabel:setString('x'..tostring(item.num))
		local item = ItemInLayout:create()
		item:setContent(ui)
		self:addItem(item)
	end)

	self:__layout()
end

function PropsBar:__layout()
    if #self.items == 0 then return end

    local totalWidth = 0
    table.each(self.items, function(item)
    	totalWidth = totalWidth + item:getWidth()
    end)

    local pageWidth = self.width
    local spacingX = (pageWidth - totalWidth)/(#self.items + 1)

    local x = spacingX

    for _, item in ipairs(self.items) do
    	item:setPositionX(x)
    	x = x + item:getWidth() + spacingX
    end
end

local PromotionItem = class(BaseUI)

function PromotionItem:ctor()
	self.isOutSide = false
end

function PromotionItem:create(config, builder, onBuySuccess, onTimeOut)
	local instance = PromotionItem.new()
	instance:init(config, builder, onBuySuccess, onTimeOut)
	return instance
end

function PromotionItem:init(config, builder, onBuySuccess, onTimeOut)
	self.busy = false
	BaseUI.init(self, self:__buildUI(config, builder, onBuySuccess, onTimeOut))
end

function PromotionItem:__buildUI(config, builder, onBuySuccess, onTimeOut)
	self.config = config
	self.builder = builder
	self.onBuySuccess = onBuySuccess
	self.onTimeOut = onTimeOut
	self.giftItems = self:getGiftItems(self.config.goodsId)



	if __IOS then
		local metaMgr = MetaManager:getInstance()
		local productMeta = metaMgr:getProductMetaByID(self.config.id)
		self.config.iapPrice = PromotionManager:getInstance():getLocalePriceByProductId(productMeta.productId)
		self.config.priceLocale = PromotionManager:getInstance():getLocaleByProductId(productMeta.productId)
		
	end

	--两种样式的UI
	if #self.giftItems == 1 then --只有金币
		self.ui = self:__buildUiOnlyGold()
		self.onlyGold = true
	else --除了金币还有别的道具
		self.ui = self:__buildUiWithProp()
		self.onlyGold = false
	end

	return self.ui
end

function PromotionItem:__buildUiOnlyGold()
	local ui = self.builder:buildGroup('newWindShop/promotion/promotion_100')

	self.price = self:getPrice(self.config.goodsId)
	self.cashNum = self:getGiftNum(ItemType.GOLD)

	self.timer = wrapText(ui:getChildByName('timer'))
	self.timer:changeFntFile('fnt/prop_name.fnt')
	self.timer:setColor(ccc3(246, 94, 64))
	self:initTimer()
	self.timer:setString(string.format('%02d:%02d:%02d', self.hour, self.min, self.sec))
	self:__registerTimerUpdate()

	self.cash = wrapText(ui:getChildByName('cash'))
	self.cash:setString(tostring(self.cashNum))

	self.buyBtn = GroupButtonBase:create(ui:getChildByName('button'))
	local currencySymbol, isLongSymbol = BuyHappyCoinManager:getCurrencySymbol(self.config.priceLocale or 'cny')

	local showPrice = self.config.iapPrice or self.price/100

	if isLongSymbol then 
		self.buyBtn:setString(string.format("%s%.0f", currencySymbol, showPrice))
	else
		self.buyBtn:setString(string.format("%s%.2f", currencySymbol, showPrice))
	end
	self.buyBtn:addEventListener(DisplayEvents.kTouchTap, function()
		if not self.config.test then
			DcUtil:UserTrack({
				category = "shop",
				sub_category = "wm_promotion_click",
				goods_id = self.config.goodsId
			})
		end
		self:buy()
	end)

	return ui
end

function PromotionItem:__buildUiWithProp()
	local ui = self.builder:buildGroup('newWindShop/promotion/promotion_gift')

	self.price = self:getPrice(self.config.goodsId)
	self.cashNum = self:getGiftNum(ItemType.GOLD)

	self.timer = wrapText(ui:getChildByName('timer'))
	self.timer:changeFntFile('fnt/prop_name.fnt')
	self.timer:setColor(ccc3(246, 94, 64))
	self:initTimer()
	self.timer:setString(string.format('%02d:%02d:%02d', self.hour, self.min, self.sec))
	self:__registerTimerUpdate()

	self.cash = wrapText(ui:getChildByName('cash'))
	self.cash:setString(tostring(self.cashNum))

	self.goldIcon = ui:getChildByName('goldIcon')

	self.cash:setPositionY(self.cash:getPositionY() - 10)
	self.goldIcon:setPositionY(self.goldIcon:getPositionY() - 10)

	local offsetX = 0
	
	if self.cashNum < 100 then
		offsetX = offsetX + 28
	elseif self.cashNum < 200 then
		offsetX = offsetX + 20
	elseif self.cashNum < 1000 then
		offsetX = offsetX + 12
	else
		offsetX = offsetX - 4
	end

	self.cash:setPositionX(self.cash:getPositionX() + offsetX)
	self.goldIcon:setPositionX(self.goldIcon:getPositionX() + offsetX)

	self.timer.x = self.timer:getPositionX() - 10
	self.timer:setPositionX(self.timer.x)

	self.buyBtn = GroupButtonBase:create(ui:getChildByName('button'))
	
	local currencySymbol, isLongSymbol = BuyHappyCoinManager:getCurrencySymbol(self.config.priceLocale or 'cny')
	local showPrice = self.config.iapPrice or self.price/100

	if isLongSymbol then 
		self.buyBtn:setString(string.format("特惠价 %s%.2f", currencySymbol, showPrice))
	else
		self.buyBtn:setString(string.format("特惠价 %s%.2f", currencySymbol, showPrice))
	end
	self.buyBtn:addEventListener(DisplayEvents.kTouchTap, function()
		if not self.config.test then
			DcUtil:UserTrack({
				category = "shop",
				sub_category = "wm_promotion_click",
				goods_id = self.config.goodsId
			})
		end
		self:buy()
	end)

	local propItems = table.filter(self.giftItems, function(item) 
		return item.itemId ~= ItemType.GOLD
	end)

	local propsBar = PropsBar:create(propItems, self.builder)

	self.bg2 = ui:getChildByName('bg2')
	self.bg2:setOpacity(0.6 * 255)
	self.bg2:addChild(propsBar)
	utils.setNodeOriginPos(propsBar, ccp(30, 5), self.bg2)
	-- propsBar:setPosition(ccp(0, 0))
	return ui
end

function PromotionItem:getGiftItems(goodsId)
	return MetaManager.getInstance():getGoodMeta(goodsId).items
end

function PromotionItem:getPrice(goodsId)
	return MetaManager.getInstance():getGoodMeta(goodsId).thirdRmb
end

function PromotionItem:getGiftNum(itemId)
	local num = 0
	table.each(self.giftItems, function(item)
		if item.itemId == itemId then
			num = item.num
		end
	end)
	return num
end

function PromotionItem:initTimer()
	local sec 
	if self.config.test then
		sec = 3600
	else
		sec = PromotionManager:getInstance():getRestTime()
	end
	self.hour = math.floor(sec / 3600)
	self.min = math.floor(sec / 60) % 60
	self.sec = sec % 60
end

function PromotionItem:decreaseTimer()
	if self.isDisposed then return end
	local sec 
	if self.config.test then
		sec = 3600
	else
		sec = PromotionManager:getInstance():getRestTime()
	end
	if sec > 0 then
		self.hour = math.floor(sec / 3600)
		self.min = math.floor(sec / 60) % 60
		self.sec = sec % 60
		self.timer:setString(string.format('%02d:%02d:%02d', self.hour, self.min, self.sec))
		if self.timer.x then
			self.timer:setPositionX(self.timer.x)
		end
	else
		self:timeOut()
	end
end

function PromotionItem:__registerTimerUpdate()
	if not self.timerUpdateId then
		local scheduler = CCDirector:sharedDirector():getScheduler()
		self.timerUpdateId = scheduler:scheduleScriptFunc(function()
			self:decreaseTimer()
		end, 1, false)
	end
end

function PromotionItem:__unregisterTimerUpdate()
	if self.timerUpdateId then
		local scheduler = CCDirector:sharedDirector():getScheduler()
		scheduler:unscheduleScriptEntry(self.timerUpdateId)
		self.timerUpdateId = nil
	end
end

function PromotionItem:dispose()
	self:__unregisterTimerUpdate()
	BaseUI.dispose(self)
end

function PromotionItem:timeOut()
	self:__unregisterTimerUpdate()
	if self.onTimeOut then
		self.onTimeOut()
	end
end

function PromotionItem:buySuccess()
	self:__unregisterTimerUpdate()
	if not self.config.test then

		if HappyCoinShopFactory:getInstance():shouldUse_1_45() then
			DcUtil:UserTrack({
				category = "shop",
				sub_category = "wm_promotion_buy_success",
				goods_id = self.config.goodsId,
				source = self.goldPage and self.goldPage.source or self.source
			})
		else
			DcUtil:UserTrack({
				category = "shop",
				sub_category = "wm_promotion_buy_success",
				goods_id = self.config.goodsId
			})
		end

		PromotionManager:getInstance():onBuySuccess()
	end
	if self.onBuySuccess then
		self.onBuySuccess()
	end
end

function PromotionItem:setPayType(payType)
	self.payType = payType
end

function PromotionItem:buy()
	if self.__hadBuySuccess then
		return
	end

	if self.busy then
		return
	end

	if self.buyBtn and (not self.buyBtn.isDisposed) then
		self.buyBtn:setEnabled(false)
	end

	self.busy = true

	self:runAction(CCSequence:createWithTwoActions(
		CCDelayTime:create(5), 
		CCCallFunc:create(function ( ... )
			self.busy = false
			if self.buyBtn and (not self.buyBtn.isDisposed) then
				self.buyBtn:setEnabled(true)
			end
		end)
	))

	local function success()

		self.__hadBuySuccess = true

		CommonTip:showTip('购买成功')
		if self.isDisposed then 
			self:buySuccess()
			return 
		end

		self.busy = false
		self:stopAllActions()

		if self.buyBtn and (not self.buyBtn.isDisposed) then
			self.buyBtn:setEnabled(true)
		end



		local bounds = self.ui:getChildByName('box'):getGroupBounds()
		local pos = ccp(bounds:getMidX(), bounds:getMidY())

		local items = table.filter(self:getGiftItems(self.config.goodsId), function(item) return item.itemId ~= 14 end)

		if #items > 0 then
			local anim = FlyItemsAnimation:create(items)
			anim:setWorldPosition(ccp(pos.x, pos.y))
			anim:setFinishCallback(function() end)
			anim:play()
		end

		local visibleOrigin = Director:sharedDirector():getVisibleOrigin()
		local num = self:getGiftNum(ItemType.GOLD)
		local toWorldPosX = 190 + visibleOrigin.x
		local toWorldPosY = 40 + visibleOrigin.y
		if num ~= nil and num > 0 then
			local anim = FlyGoldToAnimation:create(num, ccp(toWorldPosX,toWorldPosY))
			anim:setWorldPosition(ccp(pos.x, pos.y))
			anim:setFinishCallback(function()
				self:buySuccess()
			end)
			anim:play()
		end
 
    end
    local function fail(errCode, errMsg, noTip)
    	if not noTip then 
	    	if type(errCode)=='number' and errCode == -1000061 then
				CommonTip:showTipWithErrCode(localize("error.tip.-1000061"), errCode, "negative", nil, 3)	
			else
	    		CommonTip:showTipWithErrCode(localize("buy.gold.panel.err.undefined"), errCode, "negative", nil, 3)
	    	end
	    end

    	self.busy = false
		if self.isDisposed then return end
		self:stopAllActions()

		if self.buyBtn and (not self.buyBtn.isDisposed) then
			self.buyBtn:setEnabled(true)
		end
    end
    local function cancel()

    	CommonTip:showTip('购买取消')

		self.busy = false
		if self.isDisposed then return end
		self:stopAllActions()

		if self.buyBtn and (not self.buyBtn.isDisposed) then
			self.buyBtn:setEnabled(true)
		end

    end

	if __ANDROID then
		PlatformConfig:setCurrentPayType(self.payType)
		local goodsId = self.config.goodsId
		local goodsType = 1 --礼包
		self.goodsIdInfo = GoodsIdInfoObject:create(goodsId)
    	self.dcAndroidInfo = DCAndroidRmbObject:create()
    	self.dcAndroidInfo:setGoodsId(self.goodsIdInfo:getGoodsId())
	    self.dcAndroidInfo:setGoodsType(self.goodsIdInfo:getGoodsType())
	    self.dcAndroidInfo:setGoodsNum(1)
	    self.dcAndroidInfo:setInitialTypeList(self.payType, self.payType)
	    PaymentDCUtil.getInstance():sendAndroidRmbPayStart(self.dcAndroidInfo)
        self.buyLogic = IngamePaymentLogic:create(goodsId, goodsType, DcFeatureType.kStore, DcSourceType.kStoreBuySales, self.dcAndroidInfo)

        if self.payType == Payments.WECHAT then
			if PaymentManager.getInstance():checkCanWechatQuickPay(self.price/100) then
				if UserManager.getInstance():isWechatSigned() then
					local function onConfirm()
						self.buyLogic:salesBuy(self.payType, function()
				        	success()
				        end, function(...)
				        	fail(...)
				        end, function()
				        	cancel()
				        end)
					end

					local PromotionQuickPayConfirmPanel = require "zoo.panel.happyCoinShop.PromotionQuickPayConfirmPanel"
					local cp = PromotionQuickPayConfirmPanel:create(self.giftItems, self.price/100, self.payType)
					cp:popout(onConfirm)
					return
				end
			end 
		elseif self.payType == Payments.ALIPAY then
			if PaymentManager.getInstance():checkCanAliQuickPay(self.price/100) then 
				if UserManager.getInstance():isAliSigned() then
					local function onConfirm()
						self.buyLogic:salesBuy(self.payType, function()
				        	success()
				        end, function(...)
				        	fail(...)
				        end, function()
				        	cancel()
				        end)
					end
					local PromotionQuickPayConfirmPanel = require "zoo.panel.happyCoinShop.PromotionQuickPayConfirmPanel"
					local cp = PromotionQuickPayConfirmPanel:create(self.giftItems, self.price/100, self.payType)
					cp:popout(onConfirm)
					return
				end
			end
		end

        self.buyLogic:salesBuy(self.payType, function()
        	success()
        end, function(...)
        	fail(...)
        end, function()
        	cancel()
        end)
	elseif __IOS then
  		local logic = IapBuyPropLogic:create(self.config.goodsId, DcFeatureType.kStore, DcSourceType.kStoreBuySales)
		if logic then 
			logic:setPriceLocale(self.config.priceLocale or 'cny')
			logic:buy(success, fail)
		end
	end
end

function PromotionItem:setOutSideView(isOutSide)
	if self.isDisposed then
		return 
	end
	if isOutSide ~= self.isOutSide then
		self.isOutSide = isOutSide
		if self.isOutSide then
			self.buyBtn:setEnabled(false)
		else
			self.buyBtn:setEnabled(true)
		end
	end
end

function PromotionItem:getBuyBtnArea()
	if self.onlyGold then
		return 65, 65 + 79
	else
		return 120, 120 + 74
	end
end

function PromotionItem:setSource( source )
	self.source = source
end

function PromotionItem:setGoldPage( goldPage )
	self.goldPage = goldPage
end

return PromotionItem