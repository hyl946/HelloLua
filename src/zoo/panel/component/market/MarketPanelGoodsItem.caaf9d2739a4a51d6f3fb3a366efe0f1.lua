require 'zoo.panel.component.market.MarketBuyPanel'
require 'zoo.panel.component.common.LayoutItem'
require 'zoo.common.OneSecondTimer'

MarketPanelGoodsItem = class(ItemInClippingNode)

function MarketPanelGoodsItem:ctor()
	
end

function MarketPanelGoodsItem:loadRequiredResource(panelConfigFile)
	self.panelConfigFile = panelConfigFile
	self.builder = InterfaceBuilder:create(panelConfigFile)
end

function MarketPanelGoodsItem:init(groupName, goodsId)
	ItemInClippingNode.init(self)

	local goodsData = MetaManager:getInstance():getGoodMeta(goodsId)
	self.goodsId = goodsData.id

	assert(groupName)

	self.groupName = groupName

	-- local ui = ResourceManager:sharedInstance():buildGroup(groupName)
	local ui = self.builder:buildGroup(groupName)
	assert(ui)
	-- BaseUI.init(self, ui)

	self.ui = ui
	self.index = 0

	self.bubble = ui:getChildByName('bubble')
	self.bubbleWrapper = self.bubble:getChildByName('wrapper')
	self.coinIcon = ui:getChildByName('coinIcon')
	self.oldPriceTxt = ui:getChildByName('oldPriceTxt')
	self.oldPriceBlocker = ui:getChildByName('oldPriceBlocker')
	self.discountTag = ui:getChildByName('discountTag')
	-- self.discountPercentTxt = self.discountTag:getChildByName('txt')
	-- self.priceTxt = ui:getChildByName('priceTxt')
	self.priceTxt = TextField:createWithUIAdjustment(self.ui:getChildByName("priceTxt_fontsize"), self.ui:getChildByName("priceTxt"), true)
	self.priceTxt:removeFromParentAndCleanup(false)
	self.ui:addChild(self.priceTxt)


	self.discountPercentTxtOriginalPosition = ccp(self.discountTag:getChildByName("txt_fontsize"):getPositionX(),self.discountTag:getChildByName("txt_fontsize"):getPositionY())
	self.discountPercentTxt = TextField:createWithUIAdjustment(self.discountTag:getChildByName("txt_fontsize"), self.discountTag:getChildByName("txt"), true)
	self.discountPercentTxt:removeFromParentAndCleanup(false)
	self.discountTag:addChild(self.discountPercentTxt)


	-- fix rotated text mis-positioning
	-- self.discountPercentTxt:setPosition(ccp(self.discountPercentTxt:getPositionX()+1, self.discountPercentTxt:getPositionY()+ 0))
	self.timerSymbol = ui:getChildByName('timer')
	self.timerLabel = self.timerSymbol:getChildByName('label')
	self.limitMark = self.discountTag:getChildByName("limitzhe")
	self.zhe = self.discountTag:getChildByName("zhe")
	-- locators
	self.discountPriceLocator = ui:getChildByName('discountPriceLocator')
	self.discountIconLocator = ui:getChildByName('discountIconLocator')
	self.discountPriceLocator:setVisible(false)
	self.discountIconLocator:setVisible(false)

	self.bubbleWrapper:setAnchorPoint(ccp(0.5, 0.5))

	self.size = ui:getGroupBounds().size
	self.size = {width = self.size.width, height = self.size.height}

	local iconBuilder = InterfaceBuilder:create(PanelConfigFiles.properties)


	self.itemIcon = iconBuilder:buildGroup('Goods_'..goodsId)--ResourceManager:sharedInstance():getItemResNameFromGoodsId(goodsId)
	-- if _G.useTraditionalChineseRes then self.itemIcon = iconBuilder:buildGroup("Goods_ZH_TW_" .. goodsId) end
	if not self.itemIcon then 
		-- temp fix: use goods 1 as default icon
		self.itemIcon = iconBuilder:buildGroup('Prop_wenhao')
	end

	local bSize = self.bubble:getGroupBounds().size
	local iSize = self.itemIcon:getGroupBounds().size
	self.itemIcon:setPosition(ccp(-iSize.width / 2 , iSize.height / 2 ))
	self.bubble:addChild(self.itemIcon)

	self:buildBubbleAnimation()

	local function _onTapHandler(event)
		self:onItemTouchTap(event)
	end

	if self.bubble:hasEventListenerByName(DisplayEvents.kTouchTap) then 
		self.bubble:removeEventListenerByName(DisplayEvents.kTouchTap)
	end
	self.bubble:addEventListener(DisplayEvents.kTouchTap, _onTapHandler, self.goodsId)

	self.timer = nil


	self.isDiscounted = false
	self.isLimited = false
	self.isTimeLimited = false


	self.diamond_flag = self.ui:getChildByName('diamond_flag')
	self.diamond_flag:setVisible(false)
	self.diamond_num_label = self.diamond_flag:getChildByName('num')
	self.diamond_num_label:setScale(0.9)
	self.diamond_num_label:setPositionX(self.diamond_num_label:getPositionX() - 10)
	self.diamond_num_label:setPositionY(self.diamond_num_label:getPositionY() + 8)

	-- add ui to cocos object
	self:setContent(ui)	
	self:update()
	MarketManager:sharedInstance():observeGoodsById(self, self.goodsId)

end

function MarketPanelGoodsItem:update()
	self:getGoods(self.goodsId)
	self:updateDisplay()
end

function MarketPanelGoodsItem:isLimitedItem()
	return self.isLimited
end
	
function MarketPanelGoodsItem:getGoods(goodsId)
	local goodsData = MarketManager:sharedInstance():getGoodsById(goodsId)
	self.currentPrice = goodsData.currentPrice
	self.limitedAmount = goodsData.buyLimit
	-- if _G.isLocalDevelopMode then printx(0, 'goodsData.buyLimit', goodsId,  goodsData.buyLimit) end
	self.oldPrice = goodsData.originalPrice

	if goodsData.beginDate ~= nil and goodsData.endDate ~= nil then
		self.beginDate = parseDateStringToTimestamp(goodsData.beginDate)
		self.endDate = parseDateStringToTimestamp(goodsData.endDate)
	end
end


function MarketPanelGoodsItem:updateDisplay()

	self.isLimited = ( -1 ~= self.limitedAmount )
	self.isTimeLimited = (self.beginDate ~= nil and self.endDate ~= nil)
	self.isDiscounted = (self.oldPrice ~= 0)

	self.isDiamond = false

	if self.goodsId == 479 or self.goodsId == 480 then
		self.isDiamond = true
		self.isLimited = false
		self.isTimeLimited = false
		self.isDiscounted = false
	end


	if self.isLimited then
		if MarketManager:sharedInstance():shouldUseNewLogic() then 
			self.discountPercentTxt:changeFntFile('fnt/discount2017yelw.fnt')
		end
		local canBuy = self.limitedAmount > 0
		self:setEnabled(canBuy)
		self.limitMark:setVisible(canBuy)
		self.zhe:setVisible(canBuy)
		if (canBuy == true) then
			self.zhe:setVisible(false)
		end
		self.discountPercentTxt:setVisible(canBuy)
	else
		if MarketManager:sharedInstance():shouldUseNewLogic() then 
			self.discountPercentTxt:changeFntFile('fnt/discount2017pnk.fnt')
		end
		self.limitMark:setVisible(false)
		self.zhe:setVisible(true)
		self:setEnabled(true)
	end

	if self.isTimeLimited then
		self.timerSymbol:setVisible(true)
		if self:isOnSale() then
			self:setEnabled(true)
		else 
			self:setEnabled(false)
		end
		if not self:hasSaleOver() then
			if self.timer == nil then 
				self:updateTimerLabel()
				self:startTimer()
			end
		else
			self.timerLabel:setString(Localization:getInstance():getText("market.item.label.over"))
		end
	else
		self.timerSymbol:setVisible(false)
	end

	if self.isDiscounted then
		self.oldPriceTxt:setVisible(true)
		self.oldPriceBlocker:setVisible(true)
		self.discountTag:setVisible(true)

		self.priceTxt:setString(self.currentPrice)
		self.oldPriceTxt:setString(self.oldPrice)
		-- set an offset
		if (tonumber(self.currentPrice) < 100) then
			self.priceTxt:setPositionX(self.discountPriceLocator:getPositionX() +7)
		else
			self.priceTxt:setPositionX(self.discountPriceLocator:getPositionX() )
		end
		self.coinIcon:setPositionX(self.discountIconLocator:getPositionX())

		local discountPercent = BuyLogic:getDiscountPercentageForDisplay(self.oldPrice, self.currentPrice)

		if MarketManager:sharedInstance():shouldUseNewLogic() then
			if (self.limitMark:isVisible()) then
				self.discountPercentTxt:setString(tostring(discountPercent))
			else
				self.discountPercentTxt:setString(tostring(discountPercent))
			end
		else
			if (self.limitMark:isVisible()) then
				self.discountPercentTxt:setString("限量"..tostring(discountPercent).."折")
			else
				self.discountPercentTxt:setString(""..tostring(discountPercent).."折")
				self.discountPercentTxt:setPosition(ccp(self.discountPercentTxtOriginalPosition.x + 20,self.discountPercentTxtOriginalPosition.y+10))
			end
			self.discountPercentTxt:setRotation(-30)
		end
		
	else 
		self.oldPriceTxt:setVisible(false)
		self.oldPriceBlocker:setVisible(false)
		self.discountTag:setVisible(false)

		self.priceTxt:setString(self.currentPrice)

		self.priceTxt:setPositionX(self.discountPriceLocator:getPositionX() - 25)
	end

	if self.isDiamond then
		local meta = MetaManager:getInstance():getGoodMeta(self.goodsId)
		if meta then
			local diamond_item = table.find(meta.items, function ( v )
				return v.itemId == ItemType.DIAMONDS
			end)
			if diamond_item then
				self.diamond_num_label:setText(tostring(diamond_item.num))
			end
		end


		self.diamond_flag:setVisible(true)
	else
		self.diamond_flag:setVisible(false)
	end

end

function MarketPanelGoodsItem:startTimer()
	self:stopTimer()

	local function __onTick()
		if not self.isDisposed then
			self:updateTimerLabel()
		end
	end
	self.timer = OneSecondTimer:create()
	self.timer:setOneSecondCallback(__onTick)
	self.timer:start()
end

function MarketPanelGoodsItem:stopTimer()
	if self.timer ~= nil then 
		self.timer:stop()
		self.timer = nil
	end
end

function MarketPanelGoodsItem:isOnSale()
	local time = os.time()
	return time > self.beginDate and time < self.endDate
end

function MarketPanelGoodsItem:hasSaleOver()
	local time = os.time()
	return time > self.endDate
end


function MarketPanelGoodsItem:updateTimerLabel()
	local time = os.time()
	local timeLeft = 0
	if time <= self.beginDate then
		timeLeft = self.beginDate - time
	else
		timeLeft = self.endDate - time
	end

	if timeLeft < 0 then -- prevent the timer stops at the last second
		timeLeft = 0
		self:stopTimer()
		self:updateDisplay()
	else

		local day = math.floor(timeLeft / (24 * 3600))
		timeLeft = timeLeft - day * 24 * 3600
		local hour = math.floor(timeLeft / 3600)
		timeLeft = timeLeft - hour * 3600
		local minute = math.floor(timeLeft / 60)
		local second = timeLeft - minute * 60
		local txt
		if day > 0 then 
			txt = Localization:getInstance():getText('market.item.label.dayhour', {day = day, hour = hour})
		elseif hour > 0 then 
			txt = Localization:getInstance():getText('market.item.label.hourminute', {hour = hour, minute = minute})
		else 
			txt = Localization:getInstance():getText('market.item.label.minutesecond', {minute = minute, second = second})
		end
		self.timerLabel:setString(txt)
	end
end

function MarketPanelGoodsItem:buildBubbleAnimation()

	local scale1 = CCScaleTo:create(10/24, 1.0, 1.041)
	local scale2 = CCScaleTo:create(10/24, 1.041, 1.0)
	local scale3 = CCScaleTo:create(5/24, 1.0, 1.0)
	-- local scale4 = CCScaleTo:create(5/24, 1.089, 1.089)
	local a_action = CCArray:create()
	a_action:addObject(scale1)
	a_action:addObject(scale2)
	a_action:addObject(scale3)
	-- a_action:addObject(scale4)

	local anim = CCRepeatForever:create(CCSequence:create(a_action))
	self.bubbleWrapper:setScale(1.0, 1.0)

	local p = self.bubble:getPosition()
	local s = self.bubble:getGroupBounds().size
	self.bubbleWrapper:setPosition(ccp(0, 0))
	self.bubbleWrapper:runAction(anim)
end


function MarketPanelGoodsItem:onItemTouchTap(event)
	-- print 'item click'
	if self.enabled == true then
		local goodsId = event.context
		local panel = MarketBuyPanel:create(goodsId)
		local origin = Director:sharedDirector():getVisibleOrigin()
		local size = Director:sharedDirector():getVisibleSize()
		local x = origin.x
		-- if _G.isLocalDevelopMode then printx(0, panel:getGroupBounds().size.height) end
		local y = -(size.height - panel:getGroupBounds().size.height ) / 2
		panel:setPosition(ccp(x, y))
		panel:popout()
	elseif self.enabled == false then
		self:playWobblingAnimation()
		CommonTip:showTip(Localization:getInstance():getText('market.panel.goods.soldout'), 'negative', nil)
	end
end

function MarketPanelGoodsItem:setEnabled(enable)
	if not self.itemIcon then return end
	local iconSprite = self.itemIcon:getChildByName('sprite')
	if not iconSprite then return end
	if enable == true then
		iconSprite:clearAdjustColorShader()
		self.bubble:setTouchEnabled(true, 0, true)
		self.enabled = true
	else
		-- set icon the grey scale
		iconSprite:applyAdjustColorShader()
		iconSprite:adjustColor(0,-1, 0, 0)
		-- self.bubble:setTouchEnabled(false)
		self.bubble:setTouchEnabled(true, 0, true)
		self.enabled = false
	end
end

function MarketPanelGoodsItem:setIndex(index)
	assert(index > 0)
	self.index = index
end

function MarketPanelGoodsItem:getIndex()
	return index
end

function MarketPanelGoodsItem:setItemById(id)
	local index = self.index
	self.ui:removeFromParentAndCleanup(true)
	self:init(self.groupName, id)
	self.index = index
end

function MarketPanelGoodsItem:playWobblingAnimation()
	-- if _G.isLocalDevelopMode then printx(0, 'playWobblingAnimation') end
	if self.isPlayingWobbling then return end
	self.isPlayingWobbling = true
	self.bubble:stopAllActions()
	local curPos = self.bubble:getPosition()
	local left = CCMoveBy:create(0.03, ccp(-20, 0))
	local right = CCMoveBy:create(0.06, ccp(40, 0))
	local middle = CCMoveTo:create(0.03, ccp(curPos.x, curPos.y))
	local actions = CCArray:create()
	local callback = CCCallFunc:create(
	    function () 
	    	self.isPlayingWobbling = false 
	    	self:buildBubbleAnimation() 
	    end)

	actions:addObject(left)
	actions:addObject(right)
	actions:addObject(middle)
	actions:addObject(callback)
	local sq = CCSequence:create(actions)
	self.bubble:runAction(sq)

end

function MarketPanelGoodsItem:dispose()
	self:stopTimer()
	MarketManager:sharedInstance():removeObserverByGoodsId(self, self.goodsId)
	CocosObject.dispose(self)
end


MarketPropsItem = class(MarketPanelGoodsItem)

function MarketPropsItem:create(itemSaleInfo)
	local instance = MarketPropsItem.new()
	instance:loadRequiredResource(PanelConfigFiles.market_panel)
	local groupName
	if MarketManager:sharedInstance():shouldUseNewLogic() then
		groupName = 'market_propsItem_new'
	else
		groupName = 'market_propsItem'
	end

	instance:init(groupName, itemSaleInfo)
	return instance
end


MarketPackItem = class(ItemInClippingNode)

function MarketPackItem:create(goodsId)
	local instance = MarketPackItem.new()
	instance:loadRequiredResource(PanelConfigFiles.market_panel)
	instance:init(goodsId)
	return instance
end

function MarketPackItem:loadRequiredResource(panelConfigFile)
	self.panelConfigFile = panelConfigFile
	self.builder = InterfaceBuilder:create(panelConfigFile)
end

function MarketPackItem:init(goodsId)
	ItemInClippingNode.init(self)
	local ui = nil
	if __IOS_FB then
		if _G.useTraditionalChineseRes then ui = self.builder:buildGroup("market_pack_ZH_TW_" .. goodsId) end
	else
		if MarketManager:sharedInstance():shouldUseNewLogic() then
			ui = self.builder:buildGroup('market_panel_pack_item_'..goodsId)
			local goodsMeta = MetaManager.getInstance():getGoodMeta(tonumber(goodsId)) 
			if ui:getChildByName("btn") and goodsMeta then
				local btn = ButtonIconsetBase:create(ui:getChildByName("btn"))
				btn:setColorMode(kGroupButtonColorMode.blue)
				btn:setIconByFrameName("common_icon/item/icon_coin_small0000")
				btn:setString(tostring(goodsMeta.discountQCash))
			    btn:ad(DisplayEvents.kTouchTap, function ( event )
			    	self:onItemTouchTap(event)
			    end)
			end
		else
			ui = self.builder:buildGroup('market_pack_'..goodsId)
		end
	end
	self.goodsId = goodsId
	self:setContent(ui)
	local function _onTapHandler(event) self:onItemTouchTap(event) end
	ui:addEventListener(DisplayEvents.kTouchTap, _onTapHandler)
	ui:addEventListener(DisplayEvents.kTouchBegin, function() end)
	ui:addEventListener(DisplayEvents.kTouchMove, function()  end)
	ui:addEventListener(DisplayEvents.kTouchEnd, function()  end)
	ui:setTouchEnabled(true)
	MarketManager:sharedInstance():observeGoodsById(self, self.goodsId)
end

function MarketPackItem:onItemTouchTap(event)
	-- print 'item click'
	local panel = MarketBuyPanel:create(self.goodsId)
	local origin = Director:sharedDirector():getVisibleOrigin()
	local size = Director:sharedDirector():getVisibleSize()
	local x = origin.x
	-- if _G.isLocalDevelopMode then printx(0, panel:getGroupBounds().size.height) end
	local y = -(size.height - panel:getGroupBounds().size.height ) / 2
	panel:setPosition(ccp(x, y))
	panel:popout()

end

function MarketPackItem:update()

end
