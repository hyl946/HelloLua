
PayPanelOneYuanMulti = class(BasePanel)

function PayPanelOneYuanMulti:ctor()
	
end

function PayPanelOneYuanMulti:init()
	self.ui	= self:buildInterfaceGroup("PayPanelOneYuanMulti")
	BasePanel.init(self, self.ui)

	self:initInnerPanel()
	self.animalPic = self.ui:getChildByName("npc")
end

function PayPanelOneYuanMulti:addToLayerColor(ui,anchorPoint)
	local size = ui:getGroupBounds().size
	local pos = ui:getPosition()
	local layer = LayerColor:create()
    layer:setColor(ccc3(0,0,0))
    layer:setOpacity(0)
    layer:setContentSize(CCSizeMake(size.width, size.height))
    layer:setAnchorPoint(anchorPoint)
    layer:setPosition(ccp(pos.x, pos.y-size.height))
    
    local uiParent = ui:getParent()
    local index = uiParent:getChildIndex(ui)
    ui:removeFromParentAndCleanup(false)
    ui:setPosition(ccp(0,size.height))
    layer:addChild(ui)
    uiParent:addChildAt(layer, index)

    return layer
end

function PayPanelOneYuanMulti:initInnerPanel()
	local innerPanelUI = self.ui:getChildByName("innerPanel")
	self.innerPanel = self:addToLayerColor(innerPanelUI, ccp(0.2, 0))

	panelTitle = TextField:createWithUIAdjustment(innerPanelUI:getChildByName("panelTitleSize"), innerPanelUI:getChildByName("panelTitle"))
	innerPanelUI:addChild(panelTitle)
	panelTitle:setString(Localization:getInstance():getText("payment_1yuan_title"))

	local goodsInfoMeta = MetaManager:getInstance():getGoodMeta(self.goodsIdInfo:getGoodsId())
	local price = goodsInfoMeta.thirdRmb / 100
	local formatPrice = string.format("%s%0.2f", Localization:getInstance():getText("buy.gold.panel.money.mark"), price)
	local buyLabel = Localization:getInstance():getText("add.step.panel.buy.btn.txt")

	local btnShowConfig1 = PaymentManager.getInstance():getPaymentShowConfig(self.paymentTable[1], price)
	self.buyButton1 = ButtonIconsetBase:create(innerPanelUI:getChildByName("buyBtn1"))
	self.buyButton1.paymentType = self.paymentTable[1]
	self.buyButton1:setString(formatPrice..buyLabel)
	self.buyButton1:setIconByFrameName(btnShowConfig1.smallIcon)
	self.buyButton1:addEventListener(DisplayEvents.kTouchTap,  function (evt)
			self:onRmbBuyBtnTap(evt)
		end)

	local discountUI1 = PayPanelDiscountUI:create(innerPanelUI:getChildByName("discount1"), self.goodsIdInfo:getDiscountNum()) 

	local btnShowConfig2 = PaymentManager.getInstance():getPaymentShowConfig(self.paymentTable[2], price)
	self.buyButton2 = ButtonIconsetBase:create(innerPanelUI:getChildByName("buyBtn2"))
	self.buyButton2.paymentType = self.paymentTable[2]
	self.buyButton2:setString(formatPrice..buyLabel)
	self.buyButton2:setColorMode(kGroupButtonColorMode.blue)
	self.buyButton2:setIconByFrameName(btnShowConfig2.smallIcon)
	self.buyButton2:addEventListener(DisplayEvents.kTouchTap,  function (evt)
			self:onRmbBuyBtnTap(evt)
		end)

	local discountUI2 = PayPanelDiscountUI:create(innerPanelUI:getChildByName("discount2"), self.goodsIdInfo:getDiscountNum()) 
end

function PayPanelOneYuanMulti:onRmbBuyBtnTap(evt)
	local paymentType = evt.target.paymentType
	local function rebecomeEnable()
		self:setBuyBtnEnabled(true)
		if self.parentPanel and not self.parentPanel.isDisposed and self.parentPanel.setBuyBtnEnabled then 
			self.parentPanel:setBuyBtnEnabled(true)
		end
	end

	self:setBuyBtnEnabled(false)
	if self.parentPanel and not self.parentPanel.isDisposed and self.parentPanel.setBuyBtnEnabled then 
		self.parentPanel:setBuyBtnEnabled(false)
	end
	setTimeOut(rebecomeEnable, 5)

	if self.peDispatcher then 
		self.peDispatcher:dispatchPanelPayEvent(paymentType)
	end
end

function PayPanelOneYuanMulti:setBuyBtnEnabled(isEnable)
	if self.buyButton1 and not self.buyButton1.isDisposed then 
		self.buyButton1:setEnabled(isEnable)
	end
	if self.buyButton2 and not self.buyButton2.isDisposed then 
		self.buyButton2:setEnabled(isEnable)
	end
end

function PayPanelOneYuanMulti:popout()
	PopoutManager:sharedInstance():add(self, false, true)

	self:_calcPosition()
	self:playPopoutAni()
end

function PayPanelOneYuanMulti:_calcPosition()
	local selfSize = self:getGroupBounds().size
	local vOrigin = CCDirector:sharedDirector():getVisibleOrigin()
	local vSize = CCDirector:sharedDirector():getVisibleSize()
	local deltaWidth = vSize.width - selfSize.width
	local selfParent = self:getParent()

	if selfParent then
		local pos = selfParent:convertToNodeSpace(ccp(vOrigin.x + deltaWidth / 2, vOrigin.y + selfSize.height))
		self:setPosition(ccp(pos.x, pos.y))
	end
end

function PayPanelOneYuanMulti:playPopoutAni()
	local aniPos = self.animalPic:getPosition()
	self.animalPic:setPosition(ccp(aniPos.x - 300, aniPos.y))
	self.innerPanel:setScale(0)
	self.animalPic:stopAllActions()
	self.animalPic:runAction(CCSequence:createWithTwoActions(CCMoveBy:create(0.2, ccp(300, 0)), CCCallFunc:create(function ()
		self.innerPanel:stopAllActions()
		self.innerPanel:runAction(CCEaseSineOut:create(CCScaleTo:create(0.15, 1)))
	end)))
end

function PayPanelOneYuanMulti:removePopout()
	PopoutManager:sharedInstance():remove(self)
end

function PayPanelOneYuanMulti:create(peDispatcher, goodsIdInfo, paymentTable, parentPanel)
	local panel = PayPanelOneYuanMulti.new()
	panel.peDispatcher = peDispatcher
	panel.goodsIdInfo = goodsIdInfo
	panel.paymentTable = paymentTable
	panel.parentPanel = parentPanel
	panel:loadRequiredResource("ui/BuyConfirmPanel.json")
	panel:init()
	return panel
end