
PayPanelOneYuanSingle = class(BasePanel)

function PayPanelOneYuanSingle:ctor()
	
end

function PayPanelOneYuanSingle:init()
	self.ui	= self:buildInterfaceGroup("PayPanelOneYuanSingle")
	BasePanel.init(self, self.ui)

	self:initInnerPanel()

	self.animalPic = self.ui:getChildByName("npc")
end

function PayPanelOneYuanSingle:addToLayerColor(ui,anchorPoint)
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

function PayPanelOneYuanSingle:initInnerPanel()
	local innerPanelUI = self.ui:getChildByName("innerPanel")
	self.innerPanel = self:addToLayerColor(innerPanelUI, ccp(0.2, 0))

	panelTitle = TextField:createWithUIAdjustment(innerPanelUI:getChildByName("panelTitleSize"), innerPanelUI:getChildByName("panelTitle"))
	innerPanelUI:addChild(panelTitle)
	panelTitle:setString(Localization:getInstance():getText("payment_1yuan_title"))


	self.buyButton = ButtonIconsetBase:create(innerPanelUI:getChildByName("buyBtn"))
	local goodsInfoMeta = MetaManager:getInstance():getGoodMeta(self.goodsIdInfo:getGoodsId())
	local price = goodsInfoMeta.thirdRmb / 100
	local formatPrice = string.format("%s%0.2f", Localization:getInstance():getText("buy.gold.panel.money.mark"), price)
	local buyLabel = Localization:getInstance():getText("add.step.panel.buy.btn.txt")
	self.buyButton:setString(formatPrice..buyLabel)
	local btnShowConfig = PaymentManager.getInstance():getPaymentShowConfig(self.paymentType, price)
	-- self.buyButton:setColorMode(kGroupButtonColorMode.blue)
	self.buyButton:setIconByFrameName(btnShowConfig.smallIcon)
	self.buyButton:addEventListener(DisplayEvents.kTouchTap,  function ()
			self:onRmbBuyBtnTap()
		end)

	local payNameUI = innerPanelUI:getChildByName("payName")
	payNameUI:setString(btnShowConfig.name)

	local payIconPosUI = innerPanelUI:getChildByName("payIconPos")
	payIconPosUI:setOpacity(0)
	local payIconBig = Sprite:createWithSpriteFrameName(btnShowConfig.bigIcon)
	payIconBig:setAnchorPoint(ccp(0, 1))
	payIconPosUI:addChild(payIconBig)

	local discountUI = PayPanelDiscountUI:create(innerPanelUI:getChildByName("discount"), self.goodsIdInfo:getDiscountNum()) 
end

function PayPanelOneYuanSingle:onRmbBuyBtnTap()
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
		self.peDispatcher:dispatchPanelPayEvent(self.paymentType)
	end
end

function PayPanelOneYuanSingle:setBuyBtnEnabled(isEnable)
	if self.buyButton and not self.buyButton.isDisposed then 
		self.buyButton:setEnabled(isEnable)
	end
end

function PayPanelOneYuanSingle:popout()
	PopoutManager:sharedInstance():add(self, false, true)

	self:_calcPosition()
	self:playPopoutAni()
end

function PayPanelOneYuanSingle:_calcPosition()
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

function PayPanelOneYuanSingle:playPopoutAni()
	local aniPos = self.animalPic:getPosition()
	self.animalPic:setPosition(ccp(aniPos.x - 300, aniPos.y))
	self.innerPanel:setScale(0)
	self.animalPic:stopAllActions()
	self.animalPic:runAction(CCSequence:createWithTwoActions(CCMoveBy:create(0.2, ccp(300, 0)), CCCallFunc:create(function ()
		self.innerPanel:stopAllActions()
		self.innerPanel:runAction(CCEaseSineOut:create(CCScaleTo:create(0.15, 1)))
	end)))
end

function PayPanelOneYuanSingle:removePopout()
	PopoutManager:sharedInstance():remove(self)
end

function PayPanelOneYuanSingle:create(peDispatcher, goodsIdInfo, paymentType, parentPanel)
	local panel = PayPanelOneYuanSingle.new()
	panel.peDispatcher = peDispatcher
	panel.goodsIdInfo = goodsIdInfo
	panel.paymentType = paymentType
	panel.parentPanel = parentPanel
	panel:loadRequiredResource("ui/BuyConfirmPanel.json")
	panel:init()
	return panel
end