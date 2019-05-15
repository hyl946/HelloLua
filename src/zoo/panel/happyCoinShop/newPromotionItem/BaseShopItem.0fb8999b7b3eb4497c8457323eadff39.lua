local BaseShopItem = class(BaseUI)

function BaseShopItem:ctor()
	self.isOutSide = false
end

function BaseShopItem:create(config, builder, onBuySuccess, onTimeOut)
	local instance = BaseShopItem.new()
	instance:init(config, builder, onBuySuccess, onTimeOut)
	return instance
end

function BaseShopItem:init(config, builder, onBuySuccess, onTimeOut)
	self.busy = false
	BaseUI.init(self, self:__buildUI(config, builder, onBuySuccess, onTimeOut))
end

function BaseShopItem:__buildUI(config, builder, onBuySuccess, onTimeOut)
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

	


	self:__initUI()

	return self:wrapUI(self.realUI)
end

--把ui包两层，为了后面播放一个动画的时候锚点是居中的
function BaseShopItem:wrapUI( ui )

	local x = ui:getGroupBounds().size.width/2

	local centerNode = CocosObject:create()
	centerNode:addChild(ui)
	ui:setPositionX(-x)

	centerNode:setPositionX(x + 3)

	self.actionNode = centerNode

	local container = CocosObject:create()
	container:addChild(centerNode)

	return container
end

function BaseShopItem:getActionNode( ... )
	return self.actionNode
end

function BaseShopItem:__initUI( ... )


	self:createMask()

	self.realUI:setScale(0.982)


	self.price = self:getPrice(self.config.goodsId)
	self.cashNum = self:getGiftNum(ItemType.GOLD)

	self:__initBuyBtnUI()
	self:__initTimerUI()
	self:__initPriceUI()

end

function BaseShopItem:createMask( ... )
	--将btn调整到最高层

	

	if not CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName('newWindShop/light0000') then
		return
	end

	local size = self.realUI:getGroupBounds().size
	size = CCSizeMake(size.width, size.height)

	local mask = LayerColor:createWithColor(ccc3(0, 0, 0), size.width, size.height)
	mask:ignoreAnchorPointForPosition(false)
	mask:setAnchorPoint(ccp(0, 1))

	local light = Sprite:createWithSpriteFrameName('newWindShop/light0000')
	light:setAnchorPoint(ccp(1, 1))


	local clipNode = ClippingNode.new(CCClippingNode:create(mask.refCocosObj))

	mask:dispose()
	clipNode:addChild(light)

	self.realUI:addChild(clipNode)

	local array = CCArray:create()
	array:addObject(CCMoveBy:create((20/24.0), ccp(1200, 0)))
	array:addObject(CCDelayTime:create(4))
	array:addObject(CCCallFunc:create(function ( ... )
		if light.isDisposed then return end
		light:setPositionX(0)
	end))
	-- light:runAction(CCRepeatForever:create(CCSequence:create(array)))
	light:runAction(CCSequence:create(array))


	local btnUI = self.realUI:getChildByName('btn')
	btnUI:removeFromParentAndCleanup(false)
	self.realUI:addChild(btnUI)

end

function BaseShopItem:__initBuyBtnUI( ... )
	local buyBtnUI = self.realUI:getChildByName('btn')
	self.buyBtnUI = buyBtnUI
	
	self:initDiscountUI(buyBtnUI)

	self.buyBtn = GroupButtonBase:create(buyBtnUI)

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

	self:playBtnAnim()

end

function BaseShopItem:initDiscountUI( buyBtnUI )
	local discountContainerUI = buyBtnUI:getChildByName('discount')
	local pos = discountContainerUI:getPosition()
	pos = ccp(pos.x, pos.y)
	pos = buyBtnUI:convertToWorldSpace(pos)
	pos = self.realUI:convertToNodeSpace(pos)
	discountContainerUI:setPosition(pos)

	discountContainerUI:removeFromParentAndCleanup(false)
	self.realUI:addChild(discountContainerUI)


	local discountUI = discountContainerUI:getChildByName('discount')
	local discountNum = self:getDiscountNum(self.config.goodsId)

	
	self.discountUI = discountUI
	self.discountContainerUI = discountContainerUI

	if discountNum == 10 then
		discountUI:setVisible(false)
	else
		require "zoo.payment.PayPanelDiscountUI"
		PayPanelDiscountUI:create(discountUI, discountNum) 

		self.discountUI:runAction(CCSequence:createWithTwoActions(
			CCDelayTime:create(48/24.0),
			CCCallFunc:create(function ( ... )
				self:playDiscountAnim()
			end)
		))
	end
end

function BaseShopItem:__initTimerUI( ... )
	self.timer = self.realUI:getChildByName('flag'):getChildByName('text')
	self.timer:changeFntFile('fnt/prop_name.fnt')
	self.timer:setScale(0.69)
	self:initTimer()
	self.timer:setText(string.format('%02d:%02d:%02d', self.hour, self.min, self.sec))
	self:__registerTimerUpdate()

end

local function createBitmapText( label )
	local text = BitmapText:create("", "fnt/tutorial_white.fnt")

	local anchor = label:getAnchorPoint()
	local pos = label:getPosition()
	local color = label:getColor()
	local parent = label:getParent()
	local index = parent:getChildIndex(label)

	text:setAnchorPoint(ccp(anchor.x, anchor.y))
	text:setPosition(ccp(pos.x, pos.y))
	text:setColor(color)
	parent:addChildAt(text, index)

	text:setScale(25.0/35)

	label:removeFromParentAndCleanup(true)

	return text
end

function BaseShopItem:__initPriceUI( ... )

	local ori_price = createBitmapText(self.realUI:getChildByName('ori_price'))
	local price = createBitmapText(self.realUI:getChildByName('price'))
	local delete_line = self.realUI:getChildByName('delete_line')

	local currencySymbol = BuyHappyCoinManager:getCurrencySymbol(self.config.priceLocale or 'cny')

	ori_price:setText('原价：')


	if self.config.iapPrice then
		local discountP = self.config.iapPrice * 10 / self:getDiscountNum(self.config.goodsId)
		price:setText(string.format('%s%.2f', currencySymbol, discountP))
	else
		price:setText(string.format('%s%.2f', currencySymbol, self:getOriPrice(self.config.goodsId) / 100.0 ))
	end

	ori_price:setAnchorPointWhileStayOriginalPosition(ccp(1, 0.5))
	price:setAnchorPointWhileStayOriginalPosition(ccp(0, 0.5))

	ori_price:setScale(ori_price:getScale() * 0.95)
	price:setScale(price:getScale() * 1.05)
end

function BaseShopItem:getDiscountNum( goodsId )
	return math.floor(10 * self:getPrice(goodsId) / self:getOriPrice(goodsId))
end

function BaseShopItem:getGiftItems(goodsId)
	return MetaManager.getInstance():getGoodMeta(goodsId).items
end

function BaseShopItem:getPrice(goodsId)
	return MetaManager.getInstance():getGoodMeta(goodsId).thirdRmb
end

function BaseShopItem:getOriPrice(goodsId)
	return MetaManager.getInstance():getGoodMeta(goodsId).rmb
end


function BaseShopItem:getGiftNum(itemId)
	local num = 0
	table.each(self.giftItems, function(item)
		if item.itemId == itemId then
			num = item.num
		end
	end)
	return num
end

function BaseShopItem:initTimer()
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

function BaseShopItem:decreaseTimer()
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
		self.timer:setText(string.format('%02d:%02d:%02d', self.hour, self.min, self.sec))
		if self.timer.x then
			self.timer:setPositionX(self.timer.x)
		end
	else
		self.timer:setText('00:00:00')
		self:timeOut()
	end
end

function BaseShopItem:__registerTimerUpdate()
	if not self.timerUpdateId then
		local scheduler = CCDirector:sharedDirector():getScheduler()
		self.timerUpdateId = scheduler:scheduleScriptFunc(function()
			self:decreaseTimer()
		end, 1, false)
	end
end

function BaseShopItem:__unregisterTimerUpdate()
	if self.timerUpdateId then
		local scheduler = CCDirector:sharedDirector():getScheduler()
		scheduler:unscheduleScriptEntry(self.timerUpdateId)
		self.timerUpdateId = nil
	end
end

function BaseShopItem:dispose()
	self:__unregisterTimerUpdate()
	BaseUI.dispose(self)
end

function BaseShopItem:timeOut()
	self:__unregisterTimerUpdate()
	if self.onTimeOut then
		self.onTimeOut()
	end
end

function BaseShopItem:buySuccess()
	self:__unregisterTimerUpdate()
	if not self.config.test then
		DcUtil:UserTrack({
			category = "shop",
			sub_category = "wm_promotion_buy_success",
			goods_id = self.config.goodsId,
			source = self.goldPage and self.goldPage.source or self.source
		})
		PromotionManager:getInstance():onBuySuccess()
	end
	if self.onBuySuccess then
		self.onBuySuccess()
	end
end

function BaseShopItem:setPayType(payType)
	self.payType = payType
end

function BaseShopItem:buy()
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

		local items = self:getGiftItems(self.config.goodsId)

		local pos = nil
		local iconNode = self.realUI:getChildByName('icon')
		if iconNode then
			local bounds = iconNode:getGroupBounds()
			pos = {x = bounds:getMidX(), y = bounds:getMidY()}
		else
			-- 提审才用到，随便写了~
			local bounds = self.realUI:getChildByName('bg'):getGroupBounds()
			pos = {x = bounds.origin.x + bounds.size.width / 4, y = bounds:getMidY()}
		end

		if self:isInMarketPanel() then
			items = table.filter(items, function(item) 
				return item.itemId ~= 14 
			end)
		end

		if #items > 0 then


			local onlyInfiniteBottle = table.filter(items, function ( tRewardItem )
				return tRewardItem.itemId == ItemType.INFINITE_ENERGY_BOTTLE_ONE_MINUTE
			end)

			local withoutInfiniteBottle = table.filter(items, function ( tRewardItem )
				return tRewardItem.itemId ~= ItemType.INFINITE_ENERGY_BOTTLE_ONE_MINUTE
			end)



			local anim = FlyItemsAnimation:create(withoutInfiniteBottle)
			anim:setWorldPosition(ccp(pos.x, pos.y))
			anim:setFinishCallback(function() 
				
				if not self:isInMarketPanel() then
					self:buySuccess()
				end

			end)
			anim:play()

			if #onlyInfiniteBottle > 0 then
				local tInfiniteRewardItem = onlyInfiniteBottle[1]
				if tInfiniteRewardItem then
					local logic = UseEnergyBottleLogic:create(tInfiniteRewardItem.itemId, DcFeatureType.kStore, DcSourceType.kStoreBuySales)
					logic:setUsedNum(tInfiniteRewardItem.num)
					logic:setSuccessCallback(function ( ... )
						HomeScene:sharedInstance():checkDataChange()
						HomeScene:sharedInstance().energyButton:updateView()
					end)
					logic:setFailCallback(function ( evt )
					end)
					logic:start(true)

					local ngEnergyAnim = FlyTopEnergyBottleAni:create(ItemType.INFINITE_ENERGY_BOTTLE)
					ngEnergyAnim:setWorldPosition(ccp(pos.x, pos.y))
					ngEnergyAnim:play()
				end
			end

		end

		local visibleOrigin = Director:sharedDirector():getVisibleOrigin()
		local num = self:getGiftNum(ItemType.GOLD)
		local toWorldPosX = 190 + visibleOrigin.x
		local toWorldPosY = 40 + visibleOrigin.y

		if self:isInMarketPanel() then

			if num ~= nil and num > 0 then
				local anim = FlyGoldToAnimation:create(num, ccp(toWorldPosX,toWorldPosY))
				anim:setWorldPosition(ccp(pos.x, pos.y))
				anim:setFinishCallback(function()
					self:buySuccess()
				end)
				anim:play()
			end
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

    	if self.onBuyFail then self:onBuyFail() end

    	self.busy = false
		if self.isDisposed then return end
		self:stopAllActions()

		if self.buyBtn and (not self.buyBtn.isDisposed) then
			self.buyBtn:setEnabled(true)
		end
    end
    local function cancel()

    	--不出重买的时候 再弹 tip
    	if self.repayChooseTable == nil then
    		CommonTip:showTip('购买取消')
    	end

    	if self.onBuyCancel then self:onBuyCancel() end

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

        local PromotionFactory = require 'zoo.panel.happyCoinShop.PromotionFactory'
        
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
				        end, self.repayChooseTable)
					end

					local PromotionQuickPayConfirmPanel = PromotionFactory:getQuickPayConfirmPanel()
					local cp = PromotionQuickPayConfirmPanel:create(self.giftItems, self.price/100, self.payType)
					cp:popout(onConfirm, cancel)
					return
				end
			end 
		elseif self.payType == Payments.ALIPAY and (not self.isPenny) then
			if PaymentManager.getInstance():checkCanAliQuickPay(self.price/100) and canQuickPay then 
				if UserManager.getInstance():isAliSigned() then
					local function onConfirm()
						self.buyLogic:salesBuy(self.payType, function()
				        	success()
				        end, function(...)
				        	fail(...)
				        end, function()
				        	cancel()
				        end, self.repayChooseTable)
					end
					local PromotionQuickPayConfirmPanel = PromotionFactory:getQuickPayConfirmPanel()
					local cp = PromotionQuickPayConfirmPanel:create(self.giftItems, self.price/100, self.payType)
					cp:popout(onConfirm, cancel)
					return
				end
			end
		end

		if self.isPenny then
			self.repayChooseTable = nil
		end

        self.buyLogic:salesBuy(self.payType, function()
        	success()
        end, function(...)
        	fail(...)
        end, function()
        	cancel()
        end, self.repayChooseTable)
	elseif __IOS then
    	local logic = IapBuyPropLogic:create(self.config.goodsId, DcFeatureType.kStore, DcSourceType.kStoreBuySales)
		if logic then 
			logic:setPriceLocale(self.config.priceLocale or 'cny')
			logic:buy(success, fail)
		end
	end
end

function BaseShopItem:setOutSideView(isOutSide)
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

function BaseShopItem:getBuyBtnArea()
	return 230, 230 + 90
end

function BaseShopItem:playBtnAnim( ... )
	if self.isDisposed then return end
	local sx = self.buyBtnUI:getScaleX()
	local sy = self.buyBtnUI:getScaleY()

	

	self.buyBtnUI:runAction(CCRepeatForever:create(
		CCSequence:createWithTwoActions(
			CCScaleTo:create(20/24.0, 0.819/0.773*sx, sy),
			CCScaleTo:create(20/24.0, sx, sy)
		)
	))
end

function BaseShopItem:stopBtnAnim( ... )
	if self.isDisposed then return end
	self.buyBtnUI:stopAllActions()
end

function BaseShopItem:playDiscountAnim( ... )
	if self.isDisposed then return end
	local array = CCArray:create()
	array:addObject(CCRotateTo:create(2/24.0, -9.2))
	array:addObject(CCRotateTo:create(3/24.0, 14.7))
	array:addObject(CCRotateTo:create(2/24.0, -11.2))
	array:addObject(CCRotateTo:create(2/24.0, 0))
	array:addObject(CCDelayTime:create(65/24.0))
	local scaleAction = CCSequence:create(array)
	self.discountContainerUI:runAction(CCRepeatForever:create(scaleAction))
end

function BaseShopItem:stopDiscountAnim( ... )
	if self.isDisposed then return end
	self.discountContainerUI:stopAllActions()
end

function BaseShopItem:setRepayChooseTable( repayChooseTable )
	self.repayChooseTable = repayChooseTable
end


function BaseShopItem:setSource( source )
	self.source = source
end

function BaseShopItem:setGoldPage( goldPage )
	self.goldPage = goldPage
end

function BaseShopItem:isInMarketPanel( ... )
	return true
end

return BaseShopItem