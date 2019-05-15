require 'zoo.panel.iosSalesPromotion.LightMoveAnimation'

IosOneYuanBuyGoldItem = class(ItemInClippingNode)
function IosOneYuanBuyGoldItem:create(itemData, countdownTime, buySuccessCallback, timeupCallback, marketDelegate)
	local instance = IosOneYuanBuyGoldItem.new()
	instance:loadRequiredResource(PanelConfigFiles.buy_gold_items)
	instance:init(itemData, countdownTime, buySuccessCallback, timeupCallback, marketDelegate)
	return instance
end

function IosOneYuanBuyGoldItem:loadRequiredResource(panelConfigFile)
	self.panelConfigFile = panelConfigFile
	self.builder = InterfaceBuilder:createWithContentsOfFile(panelConfigFile)
end

function IosOneYuanBuyGoldItem:init(itemData, countdownTime, buySuccessCallback, timeupCallback, marketDelegate)
	ItemInClippingNode.init(self)
	local ui = self.builder:buildGroup("goldItemSpecial_Ios")
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

	-- ui:getChildByName('hit_bg'):setVisible(false)

	self.text = ui:getChildByName('text')
	self.text:setString(localize('ios.tuiguang.desc1'))

	self.itemData = itemData
	self.buyLogic = BuyGoldLogic:create();
	self.buyLogic:getMeta();
	self.procClick = true

	local buyNumLabel = TextField:createWithUIAdjustment(self.buyNum_size, self.buyNum)
	buyNumLabel:setString(itemData.cash)
	ui:addChild(buyNumLabel)

	self.goodsId = goodsId

	local function onBuyTapped(evt) 
		self:buyGold(evt.context) 
	end
	self.btnBuy:setString(string.format("%s%0.2f", localize('buy.gold.panel.money.mark'), itemData.iapPrice))
	-- self.btnBuy:setColorMode(kGroupButtonColorMode.blue)
	self.btnBuy:ad(DisplayEvents.kTouchTap, onBuyTapped, {index = itemData.id, data = itemData})
	self.btnBuyOriScale = self.btnBuy:getScale()

	self.buySuccessCallback = buySuccessCallback
	self.timeupCallback = timeupCallback
	if countdownTime > 0 then
		self:startTimer(countdownTime)
	end

	self:createHappyCoinCountdown()
end

function IosOneYuanBuyGoldItem:buyGold(context)
	local function onOver()
		--nothing todo;
		if self.procClick and not self.btnBuy.isDisposed then self.btnBuy:setEnabled(true) end
		PlatformConfig:setCurrentPayType()
	end
	local function onCancel()
		if self.procClick and not self.btnBuy.isDisposed then self.btnBuy:setEnabled(true) end
		PlatformConfig:setCurrentPayType()
	end
	local function onFail(errCode, errMsg, noTip)
		if self.procClick and not self.btnBuy.isDisposed then self.btnBuy:setEnabled(true) end
		if not noTip then 
			CommonTip:showTipWithErrCode(localize("buy.gold.panel.err.undefined"), errCode, "negative")
		end
		PlatformConfig:setCurrentPayType()
	end

	local function updateItemView()
		local scene = HomeScene:sharedInstance()
		local button
		if scene then button = scene.goldButton end
		if button then button:updateView() end
		if self.buySuccessCallback then self.buySuccessCallback() end
	end

	local function onSuccess()
		updateItemView()
		CommonTip:showTip(localize("buy.gold.panel.success"), "positive", onOver)
	end

	if __IOS then -- IOS
		self:stopBtnAnimation()
		self.btnBuy:setEnabled(false)
		local function startBuyLogic()
			if not self.btnBuy.isDisposed then self.btnBuy:setEnabled(false) end

            local guideModel = require("zoo.gameGuide.IosPayGuideModel"):create() 
            guideModel:loadPromotionInfo(
                    function() --complete callback
                        if guideModel:isInFCashPromotion() then
                            self.buyLogic:buy(context.index, context.data, onSuccess, onFail, onCancel)
                        else
                        	updateItemView()
                            CommonTip:showTip(localize('您已经购买过了一元道具！'))
                        end
                    end,
                    function() --error callback
                        CommonTip:showTip(Localization:getInstance():getText("dis.connect.warning.tips"))
                        self.btnBuy:setEnabled(true)
                    end
                )
		end
		local function onFailLogin()
			self.btnBuy:setEnabled(true)
		end
		RequireNetworkAlert:callFuncWithLogged(startBuyLogic, onFailLogin)
	else -- on ANDROID and PC we don't need to check for network
		onSuccess()
	end
end

function IosOneYuanBuyGoldItem:startTimer(countdownTime)
	local function onTick()
		if self.isDisposed then
			return
		end

		if self.countdownTime > 0 then
			self.countdown:setText(convertSecondToHHMMSSFormat(self.countdownTime))
			self.countdownTime = IosPayGuide:getOneYuanFCashLeftSeconds()
		else
			if self.timer.started == true then
				self.countdown:setText(convertSecondToHHMMSSFormat(0))
				self.timer:stop()
				self:removeFromLayout()
			end
		end
	end
	self.countdownTime = countdownTime
	self.timer = OneSecondTimer:create()
	self.timer:setOneSecondCallback(onTick)
	self.timer:start()
	onTick()
	if self.timeupCallback then
		setTimeOut(self.timeupCallback, countdownTime)
	end
end

function IosOneYuanBuyGoldItem:removeFromLayout()
	if self.isDisposed then return end
	if self.parentView and not self.parentView.isDisposed then
		local layout = self.parentView.content
		if layout and not layout.isDisposed then
			layout:removeItemAt(self:getArrayIndex(), true)
		end
	end
end

function IosOneYuanBuyGoldItem:disableClick()
	self.procClick = false
	if not self.btnBuy.isDisposed then self.btnBuy:setEnabled(false) end
end

function IosOneYuanBuyGoldItem:enableClick()
	self.procClick = true
	if not self.btnBuy.isDisposed then self.btnBuy:setEnabled(true) end
end

function IosOneYuanBuyGoldItem:setOtherGoodsItemTable(otherGoodsItemTable)
	self.otherGoodsItemTable = otherGoodsItemTable
end

function IosOneYuanBuyGoldItem:playAnimation()
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

function IosOneYuanBuyGoldItem:showBtnAnimation()
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

function IosOneYuanBuyGoldItem:stopBtnAnimation()
	if self.btnBuy and self.btnBuy.groupNode then 
		self.btnBuy.groupNode:stopAllActions()
		self.btnBuy:setScale(1*self.btnBuyOriScale)
		self.btnBuy.background:clearAdjustColorShader()
	end	
end

function IosOneYuanBuyGoldItem:createHappyCoinCountdown()
	if self.isDisposed then return end
	if self.marketDelegate and self.marketDelegate.createHappyCoinCountDown then 
		self.marketDelegate:createHappyCoinCountDown()
	end
end