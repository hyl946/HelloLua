local VerticalContainer = require 'zoo.payment.repay.VerticalContainer'
local BuyItem = require 'zoo.payment.repay.BuyItem'
local SpecialBuyItem = require 'zoo.payment.repay.SpecialBuyItem'
local Common = require 'zoo.payment.repay.Common'


local function getRealOriGoodsId(oriGoodsId)
	local realOriGoodsId = oriGoodsId 
	if oriGoodsId == 280 then --这里是加五步面板打折道具的特殊处理 打折道具的名字这里不可以带打折。产品需求。
		realOriGoodsId = 278
	elseif oriGoodsId == 281 then 
		realOriGoodsId = 279
	elseif oriGoodsId == 148 then 
		realOriGoodsId = 147
	end

	return realOriGoodsId
end

local PayPanelRePay_VerB = class(BasePanel)

function PayPanelRePay_VerB:create(peDispatcher, goodsIdInfo, paymentTable, isConnectedWhenPopout, tip, notChangeBtnColor)
    local panel = PayPanelRePay_VerB.new()
    panel.peDispatcher = peDispatcher
	panel.goodsIdInfo = goodsIdInfo
	panel.paymentTable = paymentTable
	panel.tip = tip
	panel.notChangeBtnColor = notChangeBtnColor
	panel.isConnectedWhenPopout = isConnectedWhenPopout
    panel:loadRequiredResource("ui/BuyConfirmPanel.json")
    panel:init()
    return panel
end

function PayPanelRePay_VerB:init()
    local ui = self:buildInterfaceGroup("new.repay/panel")
	BasePanel.init(self, ui)

	local goodsIdForName = getRealOriGoodsId(self.goodsIdInfo:getOriginalGoodsId())
	self.goodsName = Localization:getInstance():getText("goods.name.text"..tostring(goodsIdForName))

   	self:initTitlePart()
   	self:initContent()
end

function PayPanelRePay_VerB:initTitlePart( ... )
	self.closeBtn = self.ui:getChildByName('closeBtn')
    self.closeBtn:setTouchEnabled(true, 0, true)
    self.closeBtn:ad(DisplayEvents.kTouchTap, function () self:onCloseBtnTap() end)

    local panelTitle = TextField:createWithUIAdjustment(self.ui:getChildByName("panelTitleSize"), self.ui:getChildByName("panelTitle"))
	self.ui:addChild(panelTitle)
	panelTitle:setString("重新购买 "..self.goodsName)

end

function PayPanelRePay_VerB:initContent( ... )

	self.contentHolder= self.ui:getChildByName('content')
	self.contentHolder:setVisible(false)

	self:initUpContent()
	self:initBottomContent()

	self.content = VerticalContainer:create(
		self.contentHolder:getContentSize().width*self.contentHolder:getScaleX(), 
		{}
	)

	self.content:addItem(self.upContent)
	self.content:addItem(self.bottomContent)


	local pos = self.contentHolder:getPosition()

	self.content:setPosition(ccp(pos.x, pos.y))

	self.ui:addChild(self.content)

	local height = self.content:getHeight()
	self.bg = self.ui:getChildByName('bg1')
	local size = self.bg:getPreferredSize()
	self.bg:setPreferredSize(CCSizeMake(size.width, size.height + height))
	
end

function PayPanelRePay_VerB:initUpContent( ... )
	local upPart = self:buildInterfaceGroup('new.repay/upPart')
	self.upContent = upPart
	self:initItemBubble()

	self.tipLabel = upPart:getChildByName('tipLabel') 
	self.tipLabel:setDimensions(CCSizeMake(0, 0))
	self.tipLabel:setString(self.tip)

	local bgWidth = upPart:getGroupBounds().size.width
	local tipWidth = self.tipLabel:getContentSize().width
	local deltaX = (bgWidth - tipWidth)/2
	self.tipLabel:setPositionX(deltaX)

	return self.upContent
end


function PayPanelRePay_VerB:initBottomContent( ... )
	self.bottomContent = VerticalContainer:create(
		self.contentHolder:getContentSize().width*self.contentHolder:getScaleX(), 
		{left=9, right=11, top=9, bottom=9}, 
		'ui_scale9/ui_yellow_withoutborder_scale90000'
	)

	self.buyItems = {}

	for index = 1, #self.paymentTable do
		self.paymentTable[index] = Common:getOriPayment(self.paymentTable[index])
	end

	self:sortPaymentTable()

	for index = 1, #self.paymentTable do	
		local payType = self.paymentTable[index]

		payType = self:adjustPaymentType(payType)

		local buyItem

		local bottom = 6
		local top = 6

		if index == 1 and self.isConnectedWhenPopout and Common:isThirdParty(payType) then
			buyItem = SpecialBuyItem:create(self.builder)
			bottom = 10
			top = 8
		else
			buyItem = BuyItem:create(self.builder)
		end
		buyItem:setData(self.goodsIdInfo, payType)
		buyItem:setBtnCallback(function ( payType )
			self:onBuyItemTap(payType)
		end)

		if Common:isThirdParty(payType) then
			buyItem:setBtnHasNet(self.isConnectedWhenPopout, self.notChangeBtnColor) 
		end
		self.bottomContent:addItem(buyItem, {top = top, bottom = bottom})

		table.insert(self.buyItems, buyItem)
	end

	return self.bottomContent
end

function PayPanelRePay_VerB:sortPaymentTable( ... )
	table.sort(self.paymentTable, function ( a, b )

		local a_is_third = Common:isThirdParty(a)
		local b_is_third = Common:isThirdParty(b)

		if a_is_third and b_is_third then
			local a_is_t1 = Common:isT1(a)
			local b_is_t1 = Common:isT1(b)

			if a_is_t1 and b_is_t1 then
				if a == Payments.WECHAT then
					return true	
				elseif b == Payments.WECHAT then
					return false
				elseif a == Payments.ALIPAY then
					return true
				elseif b == Payments.ALIPAY then
					return false
				end
			elseif a_is_t1 then
				return true
			elseif b_is_t1 then
				return false
			else
			end

		elseif a_is_third then
			return self.isConnectedWhenPopout
		elseif b_is_third then
			return not self.isConnectedWhenPopout
		else
		end

	end)
end

function PayPanelRePay_VerB:refreshBuyItems( isConnected )
	for index, buyItem in ipairs(self.buyItems or {}) do
		if not buyItem.isDisposed then 
			if Common:isThirdParty(buyItem:getPayType()) then
				buyItem:setBtnHasNet(isConnected, self.notChangeBtnColor)
			end
		end
	end
end

function PayPanelRePay_VerB:_close()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
end

function PayPanelRePay_VerB:popout()
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
    self:setPositionX(self:getPositionX() + 0)
	PopoutManager:sharedInstance():add(self, true)
	-- self.allowBackKeyTap = true

	RealNameManager:addConsumptionLabelToPanel(self, false)

	self.popouted = true
end

function PayPanelRePay_VerB:onCloseBtnTap()
	if self.peDispatcher then 
		self.peDispatcher:dispatchPanelCloseEvent()
	end
	self:removePopout()	
end

function PayPanelRePay_VerB:removePopout()
	PopoutManager:sharedInstance():remove(self)
end


function PayPanelRePay_VerB:initItemBubble()
	local goodsId = getRealOriGoodsId(self.goodsIdInfo:getOriginalGoodsId())
	local goodsType = self.goodsIdInfo:getGoodsType()
	local iconBuilder = InterfaceBuilder:create(PanelConfigFiles.properties)
	local itemIcon = nil
	if goodsType == 2 then -- 购买金币
		itemIcon = iconBuilder:buildGroup("Prop_14")
	elseif goodsType == 1 then
		if string.find(self.goodsName, "新区域解锁") then
			itemIcon = Sprite:createWithSpriteFrameName("buy_confirm_panel/cells/unlockIcon0000")
			itemIcon:setAnchorPoint(ccp(0,1))
		elseif string.find(self.goodsName, "签到礼包") then
			itemIcon = Sprite:createWithSpriteFrameName("buy_confirm_panel/cells/checkinIcon0000")
			itemIcon:setAnchorPoint(ccp(0,1))
		else
			if string.find(self.goodsName, "加5步") then
				if goodsId == 588 then
					-- 加五步礼包，里面有五个加五步，可不能写死变成别的物品
					-- 你能写死我也只有写死了！
				else
					goodsId = 4
				end
			elseif string.find(self.goodsName, "追踪导弹") then
				goodsId = 45
			end

			if (goodsId >= 451 and goodsId <= 468) or (goodsId >= 497 and goodsId <= 502) then
				itemIcon = iconBuilder:buildGroup('Goods_'..294)
			elseif goodsId == 493 or goodsId == 494 or (goodsId >= 513 and goodsId <= 536) or (goodsId >= 559 and goodsId <= 566) then
				itemIcon = iconBuilder:buildGroup('Goods_362')
			elseif goodsId == 614 then
				itemIcon = iconBuilder:buildGroup('Goods_484')
			elseif goodsId == 615 then
				itemIcon = iconBuilder:buildGroup('Goods_510')
			else
				itemIcon = iconBuilder:buildGroup('Goods_'..goodsId)
			end
		end
	end

	local holder = self.upContent:getChildByName("icon")
	local holderIndex = self.upContent:getChildIndex(holder)
	local bSize = holder:getGroupBounds().size
	if itemIcon then 
		local iSize = itemIcon:getGroupBounds().size
		itemIcon:setPositionXY(holder:getPositionX() + (bSize.width - iSize.width) / 2, holder:getPositionY() - (bSize.height - iSize.height) / 2)
		self.upContent:addChildAt(itemIcon, holderIndex)
		self.itemIcon = itemIcon
	end
	holder:removeFromParentAndCleanup(true)

	local label = self.upContent:getChildByName("label")
	local price = self.upContent:getChildByName("price")

	local goodsInfoMeta = MetaManager:getInstance():getGoodMeta(goodsId)
	local oldPrice = goodsInfoMeta.rmb / 100
	local oldPricePre = Localization:getInstance():getText("payment_normal_price")
	local formatOldPrice = string.format("%s%0.2f", Localization:getInstance():getText("buy.gold.panel.money.mark"), oldPrice)
	label:setString(oldPricePre)
	price:setString(formatOldPrice)


	if goodsId == 480 or goodsId == 479 then
		self:buildSpecialItemBubble()
	end
end


-- goodsid 479 480 的商品 显示特殊的气泡

function PayPanelRePay_VerB:buildSpecialItemBubble( ... )
	if not self.isDisposed then

		self.itemIcon:setVisible(false)
		local bubble = self.upContent:getChildByName('bubble')
		if bubble then
			bubble:setVisible(false)
		end
				
		local goodsId = self.goodsIdInfo:getOriginalGoodsId()

		local itemBubble = self:buildInterfaceGroup('new.repay/specialbutton.20171704/market_propsItem_new')
		itemBubble:getChildByName('bubble'):getChildByName('wrapper'):setAnchorPoint(ccp(0.5, 0.5))

		local diamond_flag = itemBubble:getChildByName('diamond_flag')		
		diamond_flag_num = diamond_flag:getChildByName('num')
		diamond_flag_num:setScale(0.9)
		diamond_flag_num:setPositionX(diamond_flag_num:getPositionX() - 10)
		diamond_flag_num:setPositionY(diamond_flag_num:getPositionY() + 8)
		local meta = MetaManager:getInstance():getGoodMeta(self.goodsIdInfo:getOriginalGoodsId())
		if meta then
			local diamond_item = table.find(meta.items, function ( v )
				return v.itemId == ItemType.DIAMONDS
			end)
			if diamond_item then
				diamond_flag_num:setText(tostring(diamond_item.num))
			end
		end

		local iconBuilder = InterfaceBuilder:create(PanelConfigFiles.properties)
		local specialItemIcon = iconBuilder:buildGroup('Goods_'..goodsId)
		if not specialItemIcon then 
			specialItemIcon = iconBuilder:buildGroup('Prop_wenhao')
		end

		local bSize = itemBubble:getGroupBounds().size
		local iSize = specialItemIcon:getGroupBounds().size
		specialItemIcon:setPosition(ccp(-iSize.width / 2 , iSize.height / 2 ))
		itemBubble:getChildByName('bubble'):addChild(specialItemIcon)

		self.upContent:addChild(itemBubble)
		itemBubble:setPosition(ccp(364, -118))

	end
end



function PayPanelRePay_VerB:onEnterForeGround(event, ...)
	if not self.popouted then return end

	local function __onEnterForeGround( ... )
		local found = false

		for index, buyItem in ipairs(self.buyItems) do
			if Common:isThirdParty(buyItem:getPayType()) then
				found = true
			end
		end
		if found then
			self:checkNetwork(function ( isConnected )
				self:refreshBuyItems(isConnected)
			end)
		end

	end

	self:runAction(CCCallFunc:create(__onEnterForeGround))
	
end

function PayPanelRePay_VerB:checkNetwork( callback )
	PaymentNetworkCheck.getInstance():check(function( ... )
		callback(true)
    end, function ()
    	callback(false)
    end)
end

function PayPanelRePay_VerB:getBuyItem( payType )
	for index, buyItem in ipairs(self.buyItems or {}) do
		if not buyItem.isDisposed then 
			if buyItem:getPayType() == payType then
				return buyItem
			end
		end
	end
end

function PayPanelRePay_VerB:onBuyItemTap( payType )
	local buyItem = self:getBuyItem(payType)
	if (not buyItem) or buyItem.isDisposed then return end
	if buyItem:isBtnHasNet() then
		self:onRmbBuyBtnTap(payType)
	else
		self:checkNetwork(function ( isConnected )
			self:refreshBuyItems(isConnected)

			if isConnected then
				self:onRmbBuyBtnTap(payType)
			else
				CommonTip:showNetworkAlert()
			end
		end)
	end
end

function PayPanelRePay_VerB:setBuyBtnEnabled( isEnable )
	if self.isDisposed then return end

	for i,v in ipairs(self.buyItems or {}) do
		if not v.isDisposed then
			v:setEnabled(isEnable)
		end
	end

end

function PayPanelRePay_VerB:onRmbBuyBtnTap(paymentType)
	local function rebecomeEnable()
		self:setBuyBtnEnabled(true)
	end

	self:setBuyBtnEnabled(false)
	if paymentType == Payments.WECHAT or paymentType == Payments.QQ_WALLET or paymentType == Payments.MI_WXPAY or
		paymentType == Payments.QIHOO or paymentType == Payments.QIHOO_WX or paymentType == Payments.QIHOO_ALI then 
		setTimeOut(rebecomeEnable, 3)		--这里是防止微信未登录没有回调的情况
	end

	if PaymentManager.getInstance():checkIsNoThirdPayPromotion(paymentType) then
		self.goodsIdInfo:setGoodsIdChange(GoodsIdChangeType.kNormal)
	end

	if self.peDispatcher then 
		self.peDispatcher:dispatchPanelPayEvent(paymentType)
	end
end

function PayPanelRePay_VerB:adjustPaymentType(paymentType)
	if paymentType == Payments.ALI_QUICK_PAY then 
		paymentType = Payments.ALIPAY
	elseif paymentType == Payments.ALI_SIGN_PAY then 
		paymentType = Payments.ALIPAY
	elseif paymentType == Payments.WECHAT_QUICK_PAY then 
		paymentType = Payments.WECHAT
	end
	return paymentType
end

return PayPanelRePay_VerB
