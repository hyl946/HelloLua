require "zoo.panel.basePanel.BasePanel"
require "zoo.data.MetaManager"
require "zoo.panel.mark.MarkPriseBuyButton"
require "zoo.panel.mark.MarkPrisePanelModel"

PayPanelMarkPrise = class(BasePanel)

function PayPanelMarkPrise:create(index, onReleasePrise)
	local function popoutPanel(decision, paymentType, dcAndroidStatus, otherPaymentTable, repayChooseTable)
		local panel = PayPanelMarkPrise.new()
		panel.markIndex = index
		panel:loadRequiredResource("ui/MarkPrisePanel.json")
		if __ANDROID then 
			panel.adDecision = decision
			panel.adPaymentType = paymentType
			panel.dcAndroidStatus = dcAndroidStatus
			panel.adRepayChooseTable = repayChooseTable
		end

		if panel:init() then
			panel:popout() 
			if onReleasePrise then 
				panel:addEventListener(kPanelEvents.kClose, onReleasePrise)
			end
		else
			panel = nil
			if onReleasePrise then 
				onReleasePrise()
			end
		end
	end

	if __ANDROID then 
		local goodsId = MarkPrisePanelModel:getGoodsId(index)

		local uid = UserManager:getInstance().user.uid or '12345'
		local onlyRMBEnabled = MaintenanceManager:getInstance():isEnabledInGroup('BuyMarkGift', 'A1', uid)
		if onlyRMBEnabled then
			PaymentManager.getInstance():getRMBBuyItemDecision(popoutPanel, goodsId)
		else
			PaymentManager.getInstance():getBuyItemDecision(popoutPanel, goodsId)
		end
	else
		popoutPanel()
	end	
end

function PayPanelMarkPrise:init()
	self.ui = self:buildInterfaceGroup("PayPanelMarkPrise")
	BasePanel.init(self, self.ui)

	self.goodsId = MarkPrisePanelModel:getGoodsId(self.markIndex)

	DcUtil:payMarkPrisePanel(self.goodsId)

	local items = MarkPrisePanelModel:getMarkPriseInfo(self.markIndex)
	if type(items) ~= "table" or #items <= 0 then return false end

	self:initTitlePart()
	self:initItems(items)
	self:initBuyButton()

	local function onTimeout() 
		self:onCloseBtnTapped() 
	end
	MarkModel:getInstance():addEventListener(kMarkEvents.kPriseTimeOut, onTimeout)
	self.removeListeners = function(self)
		MarkModel:getInstance():removeEventListener(kMarkEvents.kPriseTimeOut, onTimeout)
	end

	return true
end

function PayPanelMarkPrise:initTitlePart()
	local titleUI = self.ui:getChildByName("title")
    self.panelTitle = TextField:createWithUIAdjustment(titleUI:getChildByName("panelTitleSize"), titleUI:getChildByName("panelTitle"))
    titleUI:addChild(self.panelTitle)
    self.panelTitle:setString(Localization:getInstance():getText("签到特权礼包"))

	local closeBtn = self.ui:getChildByName("closeBtn")
	closeBtn:setTouchEnabled(true)
	closeBtn:setButtonMode(true)
	closeBtn:addEventListener(DisplayEvents.kTouchTap,  function ()
		self:onCloseBtnTapped()
	end)
	self.closeBtn = closeBtn

	local tipLabel = self.ui:getChildByName("tipLabel")
	tipLabel:setString(Localization:getInstance():getText(Localization:getInstance():getText("mark.prise.panel.desc", {num = self.markIndex})))
end

function PayPanelMarkPrise:initItems(itemsTable)
	local itemArea = self.ui:getChildByName("itemArea")
	self.items = {}
	for k, v in ipairs(itemsTable) do
		local item = self:createItem(v.itemId, v.num)
		self.ui:addChild(item)
		table.insert(self.items, item)
	end
	self:layoutItems(itemArea)
	itemArea:removeFromParentAndCleanup(true)
end

function PayPanelMarkPrise:createItem(itemId, num)
	if type(itemId) ~= "number" or type(num) ~= "number" then return nil end
	local item = self:buildInterfaceGroup("MarkPriseItem")
	local itemPh = item:getChildByName("itemPh")
	local number = item:getChildByName("number")
	local bubble = item:getChildByName("bubble")

	local builder = InterfaceBuilder:create(PanelConfigFiles.properties)
	local sprite = builder:buildGroup("Prop_"..tostring(itemId))
	local position = itemPh:getPosition()
	sprite:setPosition(ccp(position.x, position.y))
	item:addChild(sprite)
	item.sprite = sprite
	itemPh:removeFromParentAndCleanup(true)
	number:setText("x"..tostring(num))
	number:setScale(1.8)
	local size = number:getContentSize()
	local bound = item:getChildByName("bubble"):getContentSize()
	number:setPositionX((bound.width - size.width - 20))

	item.itemId, item.num = itemId, num
	return item
end

function PayPanelMarkPrise:layoutItems(bounding)
	local posBase = {x = bounding:getPositionX(), y = bounding:getPositionY()}
	local sizeBase = bounding:getGroupBounds().size
	local width = self.items[1]:getGroupBounds().size.width
	local totalWidth = width * #self.items + 5 * (#self.items - 1)
	local posBaseAdd = (sizeBase.width - totalWidth) / 2
	for k, v in ipairs(self.items) do
		v:setPositionX(posBase.x + posBaseAdd + (k - 1) * (width + 5))
		v:setPositionY(posBase.y)
	end
end

function PayPanelMarkPrise:initBuyButton()
	self.buyButton = MarkPriseBuyButton:create(self.ui:getChildByName("buyBtn"))
	self.buyButton:setColorMode(kGroupButtonColorMode.blue)
	self.buyButton:setString(Localization:getInstance():getText("add.step.panel.buy.btn.txt"))
	local function onBuyBtnTapped(evt)
		self:onBuyBtnTapped()
	end
	self.buyButton:addEventListener(DisplayEvents.kTouchTap, onBuyBtnTapped)

	local function showWindmillPay()
		local oriPrice, nowPrice, discount = MarkPrisePanelModel:getWindMillPriceAndDiscount(self.markIndex)
		self.buyButton:setIconByFrameName("common_icon/item/icon_coin_small0000")
		self.buyButton:setOriNumber(oriPrice)
		self.buyButton:setNumber(nowPrice)
		self.buyButton:setDiscount(discount, Localization:getInstance():getText("buy.gold.panel.discount"))
	end

	local function showAndroidRmbPay()
		self.androidRmbBuy = true
		local oriPrice, nowPrice, discount = MarkPrisePanelModel:getRmbPriceAndDiscount(self.markIndex)
		oriPrice = tonumber(oriPrice)
		self.buyButton:setOriNumber(string.format("%s%0.2f", Localization:getInstance():getText("buy.gold.panel.money.mark"),  oriPrice))
		self.buyButton:setNumber(string.format("%s%0.2f", Localization:getInstance():getText("buy.gold.panel.money.mark"), nowPrice))
		self.buyButton:setDiscount(discount, Localization:getInstance():getText("buy.gold.panel.discount"))
		self.buyButton:rmbPosAdjust()
	end

	if __ANDROID then 
		if self.adDecision == IngamePaymentDecisionType.kPayWithWindMill then
			showWindmillPay()
		else
			showAndroidRmbPay()
		end
	else
		showWindmillPay()
	end
end

function PayPanelMarkPrise:onBuyBtnTapped()
	if self.isDisposed then return end 
	self:setButtonEnable(false)
	local function successWithoutBtnAni()
       	HomeScene:sharedInstance():checkDataChange()
        HomeScene:sharedInstance().goldButton:updateView()
		if not self.isDisposed then
			for k, v in ipairs(self.items) do
				local anim = FlyItemsAnimation:create({v})
				local bounds = v:getGroupBounds()
				anim:setWorldPosition(ccp(bounds:getMidX(),bounds:getMidY()))
				anim:setScaleX(v.sprite:getScaleX())
				anim:setScaleY(v.sprite:getScaleY())
				anim:play()
			end
		end
		MarkModel:getInstance():removeIndex(self.markIndex)
		if not self.isDisposed then self:removePopout() end
	end

	local function onWindMillBuySuccess()
		self.buyButton:playFloatAnimation('-'..tostring(self.buyButton:getNumber()), successWithoutBtnAni)
	end

	local function onSuccess()
		if self.isDisposed then return end
		if self.androidRmbBuy then 
			successWithoutBtnAni()
		else
			onWindMillBuySuccess()
		end
	end

	local function onFail(errCode, errMsg)
		if self.isDisposed then return end
		if not errCode then
			CommonTip:showTip(Localization:getInstance():getText("buy.gold.panel.err.undefined"), "negative")
		else 
			if __ANDROID then 
				if errCode == 730241 or errCode == 730247 then
					CommonTip:showTip(errMsg, "negative")
				elseif errCode == 730402 then 
					CommonTip:showTip(Localization:getInstance():getText("已购买过该签到特惠礼包"), "negative")
					MarkModel:getInstance():removeIndex(self.markIndex)
					if not self.isDisposed then self:removePopout() end
				elseif errCode == -1000061 then
					CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(errCode)), "negative")
				else
					CommonTip:showTip(Localization:getInstance():getText("buy.gold.panel.err.undefined"), "negative")
				end
			else
				CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(errCode)), "negative") 
			end
		end
		self:setButtonEnable(true)
	end

	local function onCancel()
		if self.isDisposed then return end
		self:setButtonEnable(true)
	end

	local function updateFunc()
		if self.isDisposed then return end
		self:setButtonEnable(true)
	end

	if self.androidRmbBuy then 
		if self.adPaymentType == Payments.WECHAT or self.adPaymentType == Payments.QQ or self.adPaymentType == Payments.MI_WXPAY then 
			setTimeOut(function ()
				if self.isDisposed then return end
				self:setButtonEnable(true)
			end, 3)
		end
		local logic = IngamePaymentLogic:create(self.goodsId, GoodsType.kItem, DcFeatureType.kSignIn, DcSourceType.kSignBuyReward)
		logic:specialBuy(self.adDecision ,self.adPaymentType, onSuccess, onFail, onCancel, self.adRepayChooseTable, self)
	else
		self.dcWindmillInfo = DCWindmillObject:create()
		self.dcWindmillInfo:setGoodsId(self.goodsId)

	   	local logic = WMBBuyItemLogic:create()
        local buyLogic = BuyLogic:create(self.goodsId, MoneyType.kGold, DcFeatureType.kSignIn, DcSourceType.kSignBuyReward)
        logic:buy(self.goodsId, 1, self.dcWindmillInfo, buyLogic, onSuccess, onFail, onCancel, updateFunc)
	end
end

function PayPanelMarkPrise:setButtonEnable(isEnable)
	if self.buyButton and not self.buyButton.isDisposed then 
		self.buyButton:setEnabled(isEnable)
	end
	if self.closeBtn and not self.closeBtn.isDisposed then 
		self.closeBtn:setTouchEnabled(isEnable)
	end
end

function PayPanelMarkPrise:popout()
	PopoutManager:sharedInstance():add(self, true, false)
	self:popoutShowTransition()
end

function PayPanelMarkPrise:popoutShowTransition()
	self.allowBackKeyTap = true
	self:_calcPosition()

	RealNameManager:addConsumptionLabelToPanel(self, true)
end

function PayPanelMarkPrise:_calcPosition()
	local selfSizeWidth = 688
	local selfSizeHeight = 726
	local vOrigin = CCDirector:sharedDirector():getVisibleOrigin()
	local vSize = CCDirector:sharedDirector():getVisibleSize()
	local deltaWidth = vSize.width - selfSizeWidth
	local deltaHeight = vSize.height - selfSizeHeight
	local selfParent = self:getParent()

	if selfParent then
		local pos = selfParent:convertToNodeSpace(ccp(vOrigin.x + deltaWidth / 2, vOrigin.y + selfSizeHeight + deltaHeight / 2))
		self:setPosition(ccp(pos.x, pos.y))
	end
end

function PayPanelMarkPrise:onCloseBtnTapped()
	if self.isDisposed then return end
	self:removePopout()
end

function PayPanelMarkPrise:removePopout()
	self.allowBackKeyTap = false
	self:dispatchEvent(Event.new(kPanelEvents.kClose, nil, self))
	PopoutManager:sharedInstance():remove(self, true)
end

function PayPanelMarkPrise:dispose()
	self:removeListeners()
	BasePanel.dispose(self)
end