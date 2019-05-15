require "zoo.panel.basePanel.BasePanel"
require 'zoo.payment.AddMinusButton'

local kButtonType = {
	kAdd = 0,
	kMinus = 1,
}


MarketBuyPanel = class(BasePanel)

function MarketBuyPanel:create(goodsId)
	local instance = MarketBuyPanel.new()
	instance:loadRequiredResource(PanelConfigFiles.market_panel)
	instance:init(goodsId)

	return instance
end

function MarketBuyPanel:init(goodsId)
	FrameLoader:loadArmature( "skeleton/tutorial_animation" )
	local ui = self:buildInterfaceGroup('market_buyPanel')
	BasePanel.init(self, ui)

	self.bubble = ui:getChildByName('bubble')
	self.bubbleWrapper = self.bubble:getChildByName('wrapper')
	self.buyButton = ui:getChildByName('buyButton')
	self.buyButton = ButtonIconNumberBase:create(self.buyButton)
	self.buyButton:setIconByFrameName('ui_images/ui_image_coin_icon_small0000')
	self.buyButton:setColorMode(kGroupButtonColorMode.blue)
	self.increaseButton = AddMinusButton:create(ui:getChildByName('increaseButton'))
	self.increaseButton:setButtonType(kButtonType.kAdd)
	self.decreaseButton = AddMinusButton:create(ui:getChildByName('decreaseButton'))
	self.decreaseButton:setButtonType(kButtonType.kMinus)

	self.amountTxt = ui:getChildByName('amountTxt')
	self.amountTxt:changeFntFile('fnt/hud.fnt')
	self.amountTxt:setAnchorPoint(ccp(0.5, 1))
	self.amountTxt:setPositionX(173)

	self.amountBg = ui:getChildByName('amountBg')
	
	self.itemNameTxt = ui:getChildByName('itemNameTxt')
	self.closeBtn = ui:getChildByName('closeBtn')
	self.helpButton = ui:getChildByName('helpButton')
	self.bg = ui:getChildByName('bgScale9')
	self.extendedPanel = ui:getChildByName('extendedPanel')

	self.limitTxt = ui:getChildByName('limitTxt')


	self.goodsData = MarketManager:sharedInstance():getGoodsById(goodsId)--MetaManager:getInstance():getGoodMeta(goodsId)
	
	self.amount = 1
	self.amountLimit = 9 -- max amount per payment
	self.goodsId = self.goodsData.id
	self.goodsName = Localization:getInstance():getText("goods.name.text"..self.goodsId)

	local iconBuilder = InterfaceBuilder:create(PanelConfigFiles.properties)
	self.icon = iconBuilder:buildGroup('Goods_'..goodsId)
	if not self.icon then
		self.icon = iconBuilder:buildGroup('Prop_wenhao')
	end
	self.icon:setScale(1.2)
	self.items = self.goodsData.items
	self.price, self.amountLimit, self.originalPrice = self.goodsData.currentPrice, self.goodsData.buyLimit, self.goodsData.originalPrice 

	if self.amountLimit ~= -1 then
		local _txt = Localization:getInstance():getText('market.buy.panel.buylimit', {num = self.amountLimit})
		self.limitTxt:setString(_txt)
		self.limitTxt:setVisible(true)
	else
		self.amountLimit = 10 
		self.limitTxt:setVisible(false)
	end


	self.originalPriceUi = ui:getChildByName("originalPrice")
	function self.originalPriceUi:setPrice( price )
		local priceLabel = self:getChildByName("price")
		priceLabel:setString(price)

		local gb = priceLabel:getGroupBounds(self)
		local width = gb.size.width + 12
		local redLine = self:getChildByName("redLine")
		redLine:setAnchorPoint(ccp(0.5, 1))
		redLine:setScaleX(width / redLine:getContentSize().width)
		redLine:setPositionX(gb.origin.x + gb.size.width / 2)
	end
	if self.originalPrice == 0 then
		self.originalPriceUi:setVisible(false)
	else
		local title = self.originalPriceUi:getChildByName("title")
		local icon = self.originalPriceUi:getChildByName("icon")
		local price = self.originalPriceUi:getChildByName("price")

		local boundingBox = icon:boundingBox()

		title:setDimensions(CCSizeMake(0,0))
		title:setAnchorPoint(ccp(1,0.5))
		title:setPositionX(boundingBox:getMinX())
		title:setPositionY(boundingBox:getMidY())

		price:setDimensions(CCSizeMake(0,0))
		price:setAnchorPoint(ccp(0,0.5))
		price:setPositionX(boundingBox:getMaxX())
		price:setPositionY(boundingBox:getMidY())

		title:setString("原价:")
		self.originalPriceUi:setPrice(self.originalPrice)
	end

	-- whether the extended animation panel is shown
	self.extended = false

	local bSize = self.bubble:getGroupBounds().size
	local iSize = self.icon:getGroupBounds().size
	self.icon:setPosition(ccp(-iSize.width / 2, iSize.height / 2))
	self.bubble:addChild(self.icon)

	self.buyButton:setString(Localization:getInstance():getText('buy.prop.panel.btn.buy.txt'))
	self.itemNameTxt:setString(Localization:getInstance():getText("goods.name.text"..self.goodsId))
		

	-- set buttons to button mode

	-- self:disableDecreaseBtn()
	-- self:enableIncreaseBtn()
	self:checkIncreaseDecreaseButtons()


	self.closeBtn:setButtonMode(true)
	self.closeBtn:setTouchEnabled(true, 0, false)

	self.helpButton:setButtonMode(true)
	self.helpButton:setTouchEnabled(true, 0, false)

	-- attach event handlers
	self.buyButton:addEventListener(DisplayEvents.kTouchTap, function(event) self:onBuyButtonClick(event) end)
	self.increaseButton:addEventListener(DisplayEvents.kTouchTap, function(event) self:increaseAmount() end)
	self.decreaseButton:addEventListener(DisplayEvents.kTouchTap, function(event) self:decreaseAmount() end)
	self.helpButton:addEventListener(DisplayEvents.kTouchTap, function(event) self:onHelpButtonClick(event) end)
	self.closeBtn:addEventListener(DisplayEvents.kTouchTap, function(event) self:onCloseBtnTapped(event) end)


	self.extendedPanel:setVisible(false)
	self.amountTxt:setText(1)
	self.buyButton:setNumber(self.price)


	-- by default, hide this button
	self:hideHelpButton()

	if _G.isLocalDevelopMode then printx(0, table.tostring(self.items)) end

	if self.items and #self.items == 1 and self.items[1].itemId ~= 2 then-- 银币不显示说明文案

		local itemId = self.items[1].itemId
		print ("itemId", itemId)
		local tutorialAnimation = CommonSkeletonAnimation:creatTutorialAnimation(itemId)
		self.tutorial = tutorialAnimation
		-- if tutorial ==  nil, then it has no tutorial
		
		self:showHelpButton()

		if tutorialAnimation then 
			tutorialAnimation:setAnchorPoint(ccp(0, 1))

			local animePlaceHolder = self.extendedPanel:getChildByName('animePlaceHolder')		
			local pos = animePlaceHolder:getPosition()
			tutorialAnimation:setPosition(ccp(pos.x, pos.y))
			local zOrder = animePlaceHolder:getZOrder()
			animePlaceHolder:getParent():addChildAt(tutorialAnimation, zOrder)
			animePlaceHolder:removeFromParentAndCleanup(true)

			-- set play button text
			local playBtn = self.extendedPanel:getChildByName('btnPlay')
			playBtn:getChildByName('text'):setString(Localization:getInstance():getText("prop.info.panel.anim.play"))
			playBtn:setTouchEnabled(true)
			playBtn:setButtonMode(true)

			local function onPlayBtnClick()
				self:playTutorial()
			end

			playBtn:addEventListener(DisplayEvents.kTouchTap, onPlayBtnClick)

			self.extendedHeight = 835
		else
			for k,v in pairs({"btnPlay","curtain","animePlaceHolder","curtainGlow"}) do
				self.extendedPanel:getChildByName(v):setVisible(false)
			end
			self.extendedHeight = 590
		end

		-- set props description
		local propsDesc = Localization:getInstance():getText("level.prop.tip."..itemId, {n = "\n"})
		self.extendedPanel:getChildByName('txt'):setString(propsDesc)

	end

	self.diamond_flag = self.ui:getChildByName('flag')
	self.diamond_num_label = self.diamond_flag:getChildByName('num')
	self.diamond_num_label:setScale(0.9)
	self.diamond_num_label:setPositionX(self.diamond_num_label:getPositionX() - 10)
	self.diamond_num_label:setPositionY(self.diamond_num_label:getPositionY() + 8)

	self.diamond_label = self.ui:getChildByName('diamond_label')
	self.diamond_label:getChildByName('label'):setString('用于关卡结束前抽取步数')

	if self.goodsId == 479 or self.goodsId == 480 then
		local meta = MetaManager:getInstance():getGoodMeta(self.goodsId)
		if meta then
			local diamond_item = table.find(meta.items, function ( v )
				return v.itemId == ItemType.DIAMONDS
			end)
			if diamond_item then
				self.diamond_num_label:setText(tostring(diamond_item.num))
			end
		end
	else
		self.diamond_flag:setVisible(false)
		self.diamond_label:setVisible(false)
	end


	self:buildBubbleAnimation()

	self.dcWindmillInfo = DCWindmillObject:create()
	self.dcWindmillInfo:setGoodsId(goodsId)
	if __ANDROID then
		PaymentDCUtil.getInstance():sendAndroidWindMillPayStart(self.dcWindmillInfo)
	end
end


function MarketBuyPanel:reload()
	-- self.goodsData = MetaManager:getInstance():getGoodMeta(self.goodsId)
	-- self.price, self.amountLimit, self.originalPrice = self.buyLogic:getPrice()
	self.goodsData = MarketManager:getGoodsById(self.goodsId)
	self.price = self.goodsData.currentPrice
	self.amountLimit = self.goodsData.buyLimit
	self.originalPrice = self.goodsData.originalPrice
	if self.amountLimit ~= -1 then
		local _txt = Localization:getInstance():getText('market.buy.panel.buylimit', {num = self.amountLimit})
		self.limitTxt:setString(_txt)
		self.limitTxt:setVisible(true)

	else
		self.amountLimit = 10 
		self.limitTxt:setVisible(false)
	end
	self.amount = 1
	-- self:disableDecreaseBtn()
	-- self:enableIncreaseBtn()
	self.amountTxt:setText(1)
	self.buyButton:setNumber(self.price)

	if self.amountLimit == 0 then
		self.buyButton:setEnabled(false)
		self.amount = 0
		-- self:disableDecreaseBtn()
		-- self:disableIncreaseBtn()
		self.amountTxt:setText(0)
		self.buyButton:setNumber(0)
	end
	self:checkIncreaseDecreaseButtons()
end


function MarketBuyPanel:setBuyAmountLimit(limit)
	self.amountLimit = limit
end

function MarketBuyPanel:playTutorial()
	if self.tutorial then
		local curtain = self.extendedPanel:getChildByName('curtain')
		local playBtn = self.extendedPanel:getChildByName('btnPlay')
		curtain:setVisible(false)
		playBtn:setVisible(false)
		self.tutorial:playAnimation()
	end
end

function MarketBuyPanel:stopTutorial()
	if self.tutorial then
		local curtain = self.extendedPanel:getChildByName('curtain')
		local playBtn = self.extendedPanel:getChildByName('btnPlay')
		self.tutorial:stopAnimation()
		curtain:setVisible(true)
		playBtn:setVisible(true)
	end
end

function MarketBuyPanel:showHelpButton()
	self.helpButton:setVisible(true)
	self.helpButton:setTouchEnabled(true, 0, false)
	self.helpButton:setButtonMode(true)
end

function MarketBuyPanel:hideHelpButton()
	self.helpButton:setVisible(false)
	self.helpButton:setTouchEnabled(false)
	self.helpButton:setButtonMode(false)
end

function MarketBuyPanel:increaseAmount()

	if self.amount < self.amountLimit then
		-- if self.amount == 1 then 
		-- 	self:enableDecreaseBtn()
		-- end
		self.amount = self.amount + 1
		self.amountTxt:setText(self.amount)

		local total = self.amount * self.price
		-- self.buyButton:setWindmillNumber(total)
		self.buyButton:setNumber(total)

		local totalOriginal = self.amount * self.originalPrice
		self.originalPriceUi:setPrice(totalOriginal)

		-- if self.amount >= self.amountLimit then 
		-- 	self:disableIncreaseBtn()
		-- end
		self:checkIncreaseDecreaseButtons()
	end
end

function MarketBuyPanel:decreaseAmount()
	
	if self.amount > 1 then 
		-- if self.amount == self.amountLimit then
		-- 	self:enableIncreaseBtn()
		-- end
		self.amount = self.amount - 1
		self.amountTxt:setText(self.amount)

		local total = self.amount * self.price
		-- self.buyButton:setWindmillNumber(total)
		self.buyButton:setNumber(total)

		local totalOriginal = self.amount * self.originalPrice
		self.originalPriceUi:setPrice(totalOriginal)

		-- if self.amount <= 1 then
		-- 	self:disableDecreaseBtn()
		-- end
		self:checkIncreaseDecreaseButtons()
	end
end

function MarketBuyPanel:checkIncreaseDecreaseButtons()
	self:enableIncreaseBtn()
	self:enableDecreaseBtn()
	if self.amount >= self.amountLimit then
		self:disableIncreaseBtn()
	end
	if self.amount <= 1 then 
		self:disableDecreaseBtn()
	end
end

function MarketBuyPanel:disableDecreaseBtn()
	self.decreaseButton:setEnabled(false)
end

function MarketBuyPanel:enableDecreaseBtn()
	self.decreaseButton:setEnabled(true)
end

function MarketBuyPanel:disableIncreaseBtn()
	self.increaseButton:setEnabled(false)
end

function MarketBuyPanel:enableIncreaseBtn()
	self.increaseButton:setEnabled(true)
end

function MarketBuyPanel:onBuyButtonClick()
	-- print 'on buy goods'

	local logic = self.buyLogic
	local total = self.amount * self.price

	local userCash = UserManager:getInstance():getUserRef():getCash()

	local function onSuccess(data)
		local scene = HomeScene:sharedInstance()
		local items = {}
		local amounts = {}
		local anim = nil

		local bounds = self.icon:getGroupBounds()	

		if self['fly_'..self.goodsData.id] then
			self['fly_'..self.goodsData.id](self, self.items, ccp(bounds:getMidX(),bounds:getMidY()), 1.8)
		else
			if #self.items == 1 then
				local anim = FlyItemsAnimation:create({self.items[1]})
				anim:setScale(1.8)
				anim:setWorldPosition(ccp(bounds:getMidX(),bounds:getMidY()))
				anim:play()			
			else 	
				local anim = FlyBagAnimation:createWithGoodsId(self.goodsData.id,self.amount)
				anim:setScale(1.8)
				anim:setWorldPosition(ccp(bounds:getMidX(),bounds:getMidY()))
				anim:play()
			end
		end

		local scene = Director.sharedDirector():getRunningScene()

		if scene then
			local visibleOrigin = Director:sharedDirector():getVisibleOrigin()
			local toWorldPosX = 360 + visibleOrigin.x
			local toWorldPosY = 40 + visibleOrigin.y

			local animLabel = TextField:create("-" .. total,"",30)
			animLabel:setAnchorPoint(ccp(0.5,0.5))
			animLabel:setPositionXY(toWorldPosX - 200,toWorldPosY)
			animLabel:setColor(ccc3(0x35,0x11,0x19))
			scene:addChild(animLabel, SceneLayerShowKey.TOP_LAYER)

			local actions = CCArray:create()
			actions:addObject(CCMoveBy:create(0.8,ccp(0,42)))
			actions:addObject(CCCallFunc:create(function( ... )
				animLabel:removeFromParentAndCleanup(true)
			end))
			animLabel:runAction(CCSequence:create(actions))

			actions = CCArray:create()
			actions:addObject(CCDelayTime:create(0.4))
			actions:addObject(CCFadeOut:create(0.4))
			animLabel:runAction(CCSequence:create(actions))
		end


		BuyObserver:sharedInstance():onBuySuccess()
		self.paySuccess = true
		self.dcWindmillInfo:setResult(DCWindmillPayResult.kSuccess)
		if __ANDROID then 
			PaymentDCUtil.getInstance():sendAndroidWindmillPayEnd(self.dcWindmillInfo)
		elseif __IOS then 
			PaymentIosDCUtil.getInstance():sendIosWindmillPayEnd(self.dcWindmillInfo)
		end
		CommonTip:showTip(Localization:getInstance():getText('buy.prop.panel.success'), 'positive', nil)
		self:reload()
	end

	local function onFailure(errorCode)
		if _G.isLocalDevelopMode then printx(0, table.tostring(event)) end
		if not errorCode then errorCode = 730632 end

		local txt = Localization:getInstance():getText('error.tip.'..errorCode)



		CommonTip:showTip(txt, 'negative', nil)

		self.dcWindmillInfo:setResult(DCWindmillPayResult.kFail, errorCode)
		if __ANDROID then 
			PaymentDCUtil.getInstance():sendAndroidWindmillPayEnd(self.dcWindmillInfo)
		elseif __IOS then 
			PaymentIosDCUtil.getInstance():sendIosWindmillPayEnd(self.dcWindmillInfo)
		end
	end

	if self.price == 0 then 
		return 
	end

	self.dcWindmillInfo:setGoodsNum(self.amount)
	self.dcWindmillInfo:setWindMillPrice(total)

	if userCash < total then 
		self.dcWindmillInfo:setResult(DCWindmillPayResult.kNoWindmill)
		if __ANDROID then 
			PaymentDCUtil.getInstance():sendAndroidWindmillPayEnd(self.dcWindmillInfo)
		elseif __IOS then 
			PaymentIosDCUtil.getInstance():sendIosWindmillPayEnd(self.dcWindmillInfo)
		end
		self:goldNotEnough()
		return
	end
	MarketManager:sharedInstance():buy(self.goodsId, self.amount, self.price, onSuccess, onFailure)
end

function MarketBuyPanel:goldNotEnough()
	local function updateGold()
		BuyObserver:sharedInstance():onBuySuccess()
	end
	local function createGoldPanel()
		local index = MarketManager:sharedInstance():getHappyCoinPageIndex()
		if index ~= 0 then
			local panel = createMarketPanel(index)
			self:onCloseBtnTapped()
		end
	end
	local function askForGoldPanel()
		GoldlNotEnoughPanel:createWithTipOnly(createGoldPanel)
	end
	askForGoldPanel()
end



function MarketBuyPanel:onHelpButtonClick()
	local hideHeight = 452
	local yMoveBy = (self.extendedHeight-hideHeight)/2 - 30

	if self.extended then 
		self.extendedPanel:setVisible(false)
		self.extended = false
		self:stopTutorial()
		local size = self.bg:getGroupBounds().size
		self.bg:setPreferredSize(CCSizeMake(size.width, hideHeight))
		self:runAction(CCEaseSineOut:create(CCMoveBy:create(0.2, ccp(0, -yMoveBy))))
	else 
		
		local size = self.bg:getGroupBounds().size
		size = {width = size.width, height = size.height}
		
		self:runAction(CCSequence:createWithTwoActions(
		               CCEaseSineOut:create(CCMoveBy:create(0.2, ccp(0, yMoveBy))),
		               CCCallFunc:create(function()
                     	self.extendedPanel:setVisible(true)
						self.extended = true
		                self.bg:setPreferredSize(CCSizeMake(size.width, self.extendedHeight)) end )
		               ))
	end
end

function MarketBuyPanel:buildBubbleAnimation()
	local scale1 = CCScaleTo:create(10/24, 1.041, 1.089)
	local scale2 = CCScaleTo:create(10/24, 1.089, 1.054)
	local scale3 = CCScaleTo:create(5/24, 1.089, 1.089)
	-- local scale4 = CCScaleTo:create(5/24, 1.089, 1.089)
	local a_action = CCArray:create()
	a_action:addObject(scale1)
	a_action:addObject(scale2)
	a_action:addObject(scale3)
	-- a_action:addObject(scale4)

	local anim = CCRepeatForever:create(CCSequence:create(a_action))
	self.bubbleWrapper:setScale(1.089, 1.089)

	local p = self.bubble:getPosition()
	local s = self.bubble:getGroupBounds().size
	self.bubbleWrapper:setPosition(ccp(0, 0))
	self.bubbleWrapper:setAnchorPoint(ccp(0.5, 0.5))
	self.bubbleWrapper:runAction(anim)
end

function MarketBuyPanel:popout()
	PopoutManager:sharedInstance():add(self, false, false)
	self:runAction(CCEaseElasticOut:create(CCMoveBy:create(0.8, ccp(0, -130))))
	self.allowBackKeyTap = true
end

function MarketBuyPanel:onCloseBtnTapped()
	if not self.paySuccess then 
		local payResult = self.dcWindmillInfo:getResult()
		if payResult and payResult == DCWindmillPayResult.kNoWindmill then 
			self.dcWindmillInfo:setResult(DCWindmillPayResult.kCloseAfterNoWindmill)
		elseif payResult and payResult == DCWindmillPayResult.kFail then
			self.dcWindmillInfo:setResult(DCWindmillPayResult.kCloseAfterFail)
		elseif payResult and payResult == DCWindmillPayResult.kNoRealNameAuthed then 
			self.dcWindmillInfo:setResult(DCWindmillPayResult.kCloseAfterNoRealNameAuthed)
		else
			self.dcWindmillInfo:setResult(DCWindmillPayResult.kCloseDirectly)
		end

		if __ANDROID then 
			PaymentDCUtil.getInstance():sendAndroidWindmillPayEnd(self.dcWindmillInfo)
		elseif __IOS then 
			PaymentIosDCUtil.getInstance():sendIosWindmillPayEnd(self.dcWindmillInfo)
		end
	end
	CCTextureCache:sharedTextureCache():removeTextureForKey(CCFileUtils:sharedFileUtils():fullPathForFilename("skeleton/tutorial_animation/texture.png"))
	PopoutManager:sharedInstance():remove(self, true)
	self.allowBackKeyTap = false

end

function MarketBuyPanel:fly_480( ... )
	self:flyGoodsItems(...)
end

function MarketBuyPanel:fly_479( ... )
	self:flyGoodsItems(...)
end

function MarketBuyPanel:flyGoodsItems( items, worldPos, scale )
	
	local function copyItems( tbl )
		local ret = {}
		for index, v in ipairs(tbl) do
			ret[index] = {itemId = v.itemId, num = v.num}

			if ret[index].itemId == ItemType.DIAMONDS then
				ret[index].num = 1 
			end
		end

		return ret
	end

	local flyItems = copyItems(items)

	local anim = FlyItemsAnimation:create(flyItems)
	anim:setWorldPosition(worldPos)
	anim:setScale(scale)
	anim:play()
end