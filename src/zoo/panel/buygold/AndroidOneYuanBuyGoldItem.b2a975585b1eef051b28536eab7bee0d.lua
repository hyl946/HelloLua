AndroidOneYuanBuyGoldItem = class(ItemInClippingNode)
function AndroidOneYuanBuyGoldItem:create(countdownTime, buyNum, giveNumber, goodsId, payment, buySuccessCallback, marketDelegate)
	local instance = AndroidOneYuanBuyGoldItem.new()
	instance:loadRequiredResource(PanelConfigFiles.buy_gold_items)
	instance:init(countdownTime, buyNum, giveNumber, goodsId, payment, buySuccessCallback, marketDelegate)
	return instance
end

function AndroidOneYuanBuyGoldItem:loadRequiredResource(panelConfigFile)
	self.panelConfigFile = panelConfigFile
	self.builder = InterfaceBuilder:createWithContentsOfFile(panelConfigFile)
end

function AndroidOneYuanBuyGoldItem:init(countdownTime, buyNum, giveNumber, goodsId, payment, buySuccessCallback, marketDelegate)
	ItemInClippingNode.init(self)
	local ui = self.builder:buildGroup("goldItemSpecial_Android")
	self.marketDelegate = marketDelegate
	self.lightPos = ui:getChildByName("lightPos")
	self.lightPos:setOpacity(0)
	local itemBg = ui:getChildByName("bg")
	local bgSize = itemBg:getContentSize()
	self.bgSizeWidth = bgSize.width - 6
	self.bgSizeHeight = bgSize.height - 6
	local layerWrapperOne = Layer:create()
	local layerWrapperAction = LayerColor:create()
	local spriteRect = ui:getGroupBounds()
	local uiSize = {width = spriteRect.size.width, height = spriteRect.size.height}
	layerWrapperAction:changeWidthAndHeight(uiSize.width, uiSize.height)
	layerWrapperAction:setOpacity(0)
	layerWrapperAction:ignoreAnchorPointForPosition(false)
	layerWrapperAction:setAnchorPoint(ccp(0.5, 0.8))
	layerWrapperAction:setPosition(ccp(uiSize.width/2 , -uiSize.height/5))
	layerWrapperAction:addChild(ui)
	ui:setPosition(ccp(0, uiSize.height))
	self.layerWrapperAction = layerWrapperAction

	layerWrapperOne:addChild(layerWrapperAction)
	self:setContent(layerWrapperOne)
	self.countdown = ui:getChildByName('countdown')
	self.countdown:setScale(0.8)
	self.buyNum = ui:getChildByName('goldNum')
	self.buyNum_size = ui:getChildByName('goldNum_size')
	self.btnBuy = GroupButtonBase:create(ui:getChildByName('buyBtn'))

	self.text = ui:getChildByName('desc')
	self.text:setString(localize('market.panel.buy.gold.text.1'))

	local buyNumLabel = TextField:createWithUIAdjustment(self.buyNum_size, self.buyNum)
	buyNumLabel:setString(buyNum + giveNumber)
	ui:addChild(buyNumLabel)


	self.goodsId = goodsId
	local meta = MetaManager:getInstance():getProductAndroidMeta(goodsId)
	local price = tonumber(meta.rmb) / 100

	self.price = price
	self.cash = buyNum + giveNumber

	self.btnBuy:setString(string.format("%s%0.2f", localize('buy.gold.panel.money.mark'), price))
	self.btnBuy:setColorMode(kGroupButtonColorMode.green)
	self.btnBuy:ad(DisplayEvents.kTouchTap, function () self:onBuyBtnTapped() end)
	self.btnBuyOriScale = self.btnBuy:getScale()

	

	self.payment = payment
	self.buyLogic = BuyGoldLogic:create()
	self.buyLogic:getMeta()
	self.buySuccessCallback = buySuccessCallback
	if countdownTime > 0 then
		self:startTimer(countdownTime)
	end
	self:createHappyCoinCountdown()
end

function AndroidOneYuanBuyGoldItem:setItemAction( action )
	self.action = action
end

function AndroidOneYuanBuyGoldItem:runItemAction()
	if self.action and type(self.action) == "function" then
		self.action()
	end
end

function AndroidOneYuanBuyGoldItem:refrashTime(noMangerFrash)
	if self.manager then
		if not noMangerFrash then
			self.manager:refrashTime()
		end
		self.countdownTime = self.manager:getLeftTime()
	end
end

function AndroidOneYuanBuyGoldItem:onBuyBtnTapped()
	-- if PaymentManager:getInstance():getHasFirstThirdPay() then -- 防止重复购买
	-- 	return 
	-- end

	local function onCancel()
		if _G.isLocalDevelopMode then printx(0, 'AndroidOneYuanBuyGoldItem onCancel') end
		if self.isDisposed then return end
		if self.procClick then self:setButtonEnable(true) end
		PlatformConfig:setCurrentPayType()
		PaymentManager.getInstance():setGoldOneYuanThirdPay(false) 
		self:refrashTime()
	end
	local function onFail(errCode, errMsg, noTip)
		if _G.isLocalDevelopMode then printx(0, 'AndroidOneYuanBuyGoldItem onFail') end
		if self.isDisposed then return end
		if self.procClick then self:setButtonEnable(true) end
		if not noTip then 
			if errCode == 730241 or errCode == 731307 then
				self:runAction(CCCallFunc:create(function () CommonTip:showTipWithErrCode(errMsg, errCode, "negative") end))
				--refresh the panel after sign successfully
				local mp = MarketPanel:getCurrentPanel()
				if not mp.isDisposed then
					mp:refresh()
				end
			else
				self:runAction(CCCallFunc:create(function () CommonTip:showTipWithErrCode(localize("buy.gold.panel.err.undefined"), errCode, "negative", nil, 3) end))		
			end
		end
		PlatformConfig:setCurrentPayType()
		PaymentManager.getInstance():setGoldOneYuanThirdPay(false) 
		self:refrashTime()
	end
	local function onSuccess()
		if _G.isLocalDevelopMode then printx(0, 'AndroidOneYuanBuyGoldItem onSuccess') end
		if self.isDisposed then return end
		if self.procClick then self:setButtonEnable(true) end
		local scene = HomeScene:sharedInstance()
		local button
		if scene then button = scene.goldButton end
		if button then button:updateView() end
		CommonTip:showTip(Localization:getInstance():getText("buy.gold.panel.success"), "positive")
		PaymentManager.getInstance():setGoldOneYuanThirdPay(false) 
		if self.buySuccessCallback then
			self.buySuccessCallback()
		end
		self:refrashTime()
	end
	self:setButtonEnable(false)
	self:stopBtnAnimation()
	if self.payment == Payments.WECHAT then
		PlatformConfig:setCurrentPayType(Payments.WECHAT)
		local function enableButton()
			if not self.isDisposed then
				if self.procClick then self:setButtonEnable(true) end
			end
		end
		setTimeOut(enableButton, 3)
	elseif self.payment == Payments.ALIPAY then
		PlatformConfig:setCurrentPayType(Payments.ALIPAY)
		if UserManager.getInstance():isAliSigned() then
			local function onConfirm()
				if self.isDisposed then return end
				self:setButtonEnable(false)
				self.buyLogic:buy(self.goodsId, nil, onSuccess, onFail, onCancel)
			end
			local function onCancel()
				if self.isDisposed then return end
				self:setButtonEnable(true)
			end

			local AliQuickPayConfirmPanel = require "zoo.panel.alipay.AliQuickPayConfirmPanel"
			local cp = AliQuickPayConfirmPanel:create(self.cash, self.price)
			cp:popout(onConfirm, onCancel)
			return
		end	 
	elseif self.payment == Payments.QIHOO or self.payment == Payments.QIHOO_WX or self.payment == Payments.QIHOO_ALI then
		local function enableButton()
			if not self.isDisposed then
				if self.procClick then self:setButtonEnable(true) end
			end
		end
		setTimeOut(enableButton, 3)
	end

	local payment = PaymentBase:getPayment(self.payment)
	--若是在默认风车币栏里 则置一下这个标识 
	if payment.mode ~= PaymentMode.kThirdParty then
		PaymentManager.getInstance():setGoldOneYuanThirdPay(true)
	end

	PlatformConfig:setCurrentPayType(self.payment)
	self.buyLogic:buy(self.goodsId, nil, onSuccess, onFail, onCancel)
end

function AndroidOneYuanBuyGoldItem:startTimer(countdownTime)
	local function onTick()
		if self.isDisposed then
			return
		end

		if self.countdownTime > 0 then
			self.countdown:setText(convertSecondToHHMMSSFormat(self.countdownTime))
			self.countdownTime = AndroidSalesManager.getInstance():getGoldSalesLeftSeconds() 
			if self.manager then
				self.manager:setLeftTime(self.countdownTime)
			end
		else
			if self.timer.started == true then
				self.countdown:setText(convertSecondToHHMMSSFormat(0))
				self.timer:stop()
				self:removeFromLayout()
				if self.stopAction then
					self.stopAction()
				end
			end
		end
	end
	self.countdownTime = countdownTime
	self.timer = OneSecondTimer:create()
	self.timer:setOneSecondCallback(onTick)
	self.timer:start()
	onTick()
end

function AndroidOneYuanBuyGoldItem:removeFromLayout()
	if self.isDisposed then return end
	if self.parentView and not self.parentView.isDisposed then
		local layout = self.parentView.content
		if layout and not layout.isDisposed then
			layout:removeItemAt(self:getArrayIndex(), true)
		end
	end
end

function AndroidOneYuanBuyGoldItem:setButtonEnable(isEnable)
	if self.btnBuy and not self.btnBuy.isDisposed then 
		if __ANDROID then 
			local scene = Director:sharedDirector():getRunningScene()
			if isEnable == true then 
				if scene and scene.goldItemMaskLayer and not scene.goldItemMaskLayer.isDisposed then 
					scene.goldItemMaskLayer:setTouchEnabled(false)
				end
			else
				if scene and scene.goldItemMaskLayer and not scene.goldItemMaskLayer.isDisposed then 
					scene.goldItemMaskLayer:setTouchEnabled(true, 0 ,true)
				end
			end
		end
		self.btnBuy:setEnabled(isEnable)
	end
end

function AndroidOneYuanBuyGoldItem:disableClick()
	self.procClick = false
	self:setButtonEnable(false)
end

function AndroidOneYuanBuyGoldItem:enableClick()
	self.procClick = true
	self:setButtonEnable(true)
end

function AndroidOneYuanBuyGoldItem:playAnimation()
	local actionTime1 = 1/6 *1.2
	local actionTime2 = 1/8 *1.2
	local actionTime3 = 1/8	*1.2
	self.layerWrapperAction:setScale(0)
	local actionArray = CCArray:create()
	actionArray:addObject(CCScaleTo:create(actionTime1, 1.05))
	actionArray:addObject(CCScaleTo:create(actionTime2, 0.95))
	actionArray:addObject(CCCallFunc:create(function ()
		if self.isDisposed then return end
		local lightMoveAni = LightMoveAnimation:create(self.bgSizeWidth, self.bgSizeHeight)
		self.lightPos:addChild(lightMoveAni)
		lightMoveAni:setPosition(ccp(self.bgSizeWidth/2, self.bgSizeHeight/2))
		lightMoveAni:play(function ()
			if self.isDisposed then return end 
			lightMoveAni:removeFromParentAndCleanup(true)
			self:showBtnAnimation()
		end)
	end))
	actionArray:addObject(CCScaleTo:create(actionTime3, 1))
	self.layerWrapperAction:runAction(CCSequence:create(actionArray))

	if self.otherGoodsItemTable and #self.otherGoodsItemTable > 0 then 
		for k,v in pairs(self.otherGoodsItemTable) do
			local arr = CCArray:create()
			arr:addObject(CCMoveBy:create(0, ccp(0, 184)))
			arr:addObject(CCMoveBy:create(actionTime1, ccp(0, -194)))
			arr:addObject(CCMoveBy:create(actionTime2, ccp(0, 20)))
			arr:addObject(CCMoveBy:create(actionTime3, ccp(0, -10)))
			v:runAction(CCSequence:create(arr))
		end
	end
end

function AndroidOneYuanBuyGoldItem:showBtnAnimation()
    local arr = CCArray:create()
    arr:addObject(CCCallFunc:create(function ()
    	self.btnBuy.background:adjustColor(0, 0, 0.1, 0)
    	self.btnBuy.background:applyAdjustColorShader()
    end))
    arr:addObject(CCScaleTo:create(0.3, self.btnBuyOriScale * 1.05))
    arr:addObject(CCCallFunc:create(function ()
    	self.btnBuy.background:clearAdjustColorShader()
    end))
    arr:addObject(CCScaleTo:create(0.3, self.btnBuyOriScale * 1))
    arr:addObject(CCDelayTime:create(0.2))
    self.btnBuy.groupNode:runAction(CCRepeat:create(CCSequence:create(arr), 2))
end

function AndroidOneYuanBuyGoldItem:stopBtnAnimation()
	if self.btnBuy and self.btnBuy.groupNode then 
		self.btnBuy.groupNode:stopAllActions()
		self.btnBuy:setScale(1*self.btnBuyOriScale)
		self.btnBuy.background:clearAdjustColorShader()
	end	
end

function AndroidOneYuanBuyGoldItem:createHappyCoinCountdown()
	if self.isDisposed then return end
	if self.marketDelegate and self.marketDelegate.createHappyCoinCountDown then 
		self.marketDelegate:createHappyCoinCountDown()
	end
end