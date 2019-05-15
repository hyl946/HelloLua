require "zoo.payment.PayPanelConfirmBase"
require "zoo.payment.ingameBuyPropPanels.PayPanelConfirmBase_VerB"
require "zoo.scenes.component.HomeSceneFlyToAnimation"

PayPanelCoin = class(PayPanelConfirmBase_VerB)

BuyCoinReasonType = {
    kPregameProp = 1,
    kFruitTreeUpdate = 2
}

function PayPanelCoin:create(coinTarget, buyCoinReasonType, okCallBack, closeCallBack, isDarkSkin) --coinTarget是购买目标的金额；PayPanelCoin内部自动计算差价

    local curCoin = UserManager.getInstance().user:getCoin()
    local diff = coinTarget - curCoin
    if diff <= 0 then
        if okCallback then
            okCallback()
        end
        return nil
    end

    local panel = PayPanelCoin.new()
    -- 以10000银币为单位购买
    local goodsId = 569 --10000银币  --goods用的资源的编号是642
    local diffCount = math.ceil(diff / 10000) --10000银币

    panel:init(goodsId, diffCount, buyCoinReasonType, okCallBack, closeCallBack, isDarkSkin)
    panel:show()
    return panel
end

function PayPanelCoin:setFeatureAndSource(feature, source)
    if self.buyLogic then
        self.buyLogic:setFeatureAndSource(feature, source)
    end
end

function PayPanelCoin:setActivityId(activityId)
    self.activityId = activityId
end

function PayPanelCoin:onCloseBtnTap()
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

    if self.closeCallBack then
        self.closeCallBack()
    end
    PayPanelConfirmBase_VerB.onCloseBtnTap(self)
end

function PayPanelCoin:onMinusBtnTap()
    self.targetNumber = self.targetNumber - 1
    if self.targetNumber <= 1 then
        self.targetNumber = 1
    end
    self:updateNumBtnShow()
    self.itemNum:setText(self.targetNumber)
    self.btnBuyWindMill:setNumber(self.targetNumber * self.buyTarget.price)
end

function PayPanelCoin:onPlusBtnTap()
    self.targetNumber = self.targetNumber + 1
    if self.targetNumber >= self.buyTarget.maxNum then
        self.targetNumber = self.buyTarget.maxNum
    end
    self:updateNumBtnShow()
    self.itemNum:setText(self.targetNumber)
    self.btnBuyWindMill:setNumber(self.targetNumber * self.buyTarget.price)
end

function PayPanelCoin:updateNumBtnShow()
    local leftEnable, rightEnable = self:getWindmillPayState()
    self:setNumBtnEnable(self.leftNumBtn, leftEnable)
    self:setNumBtnEnable(self.rightNumBtn, rightEnable)
end

function PayPanelCoin:getWindmillPayState()
    -- local currentCash = UserManager:getInstance().user:getCash()
    -- local singlePrice = self.buyTarget.price
    local maxNum = self.buyTarget.maxNum

    local leftEnable = false
    local rightEnable = false

    if self.targetNumber > 1 then
        leftEnable = true
    end

    if self.targetNumber < maxNum then
        -- if currentCash >= singlePrice * (self.targetNumber + 1) then
        --     rightEnable = true
        -- end
        rightEnable = true
    end

    return leftEnable, rightEnable
end

function PayPanelCoin:setNumBtnEnable(numBtn, isEnable, justChangeColor)
    if not isEnable then
        isEnable = false
    end
    if numBtn and numBtn.refCocosObj then
        numBtn.bg:applyAdjustColorShader()
        if isEnable then
            numBtn.bg:clearAdjustColorShader()
        else
            numBtn.bg:adjustColor(0, -1, 0, 0)
        end
        if not justChangeColor then
            numBtn:setTouchEnabled(isEnable)
        end
    end
end

function PayPanelCoin:onWindMillBuyBtnTap()
    self.btnBuyWindMill:setEnabled(false)

    local function successCallback(goodsNum)
        if self.okCallBack then
            self.okCallBack(goodsNum, self:getIconPos())
        end
        local anim = FlyTopCoinAni:create(goodsNum*10000) --10000银币为单位
        local animPosition = self:convertToWorldSpace(self.btnBuyWindMill:getPosition())
        anim:setWorldPosition(animPosition)
        anim:play()
        if not self.isDisposed then
            self.btnBuyWindMill:setEnabled(true)
            self:removePopout()
        end
    end

    local function failCallback(errorCode)
        if self.isDisposed then
            return
        end
        self.btnBuyWindMill:setEnabled(true)
        if errorCode then
            CommonTip:showTip(Localization:getInstance():getText("error.tip." .. tostring(errorCode)), "negative")
        end
    end

    local function cancelCallback()
        if self.isDisposed then
            return
        end
        self.btnBuyWindMill:setEnabled(true)
    end

    local function updateGold()
        if self.isDisposed then
            return
        end
        local money = UserManager:getInstance().user:getCash()
        self.gold:setString(money)
		self.btnBuyWindMill:setEnabled(true)

		local curCoin = UserManager.getInstance().user:getCoin()
		if curCoin~=self.curCoin then
			self:refreshPayData()
		end
    end

    if __ANDROID then
        PaymentDCUtil.getInstance():sendAndroidWindMillPayStart(self.dcWindmillInfo)
    elseif __IOS then
        -- PaymentIosDCUtil.getInstance():sendIosWindmillPayStart(self.dcWindmillInfo) --这个函数似乎不存在...
    end

    local logic = WMBBuyItemLogic:create()
    logic:buy(self.goodsId, self.targetNumber, self.dcWindmillInfo, self.buyLogic, successCallback, failCallback, cancelCallback, updateGold)

	if self.buyCoinReasonType == BuyCoinReasonType.kPregameProp then
		local params = {}
		params.category = "canyu"
		params.sub_category = "click_buy"
		params.name = "preppropCoin"
		params.game_type = "stage"
		params.t1 = UserManager.getInstance().user:getCash() >= self.cash and 1 or 2
		DcUtil:UserTrack(params)
	end
end

function PayPanelCoin:show()
    PopoutManager:sharedInstance():add(self, true, false)
    local parent = self:getParent()
    if parent then
        self:setToScreenCenterHorizontal()
        self:setToScreenCenterVertical()
    end
    self:setPositionY(self:getPositionY() + 130)
    self:runAction(CCEaseElasticOut:create(CCMoveBy:create(0.8, ccp(0, -130))))
    self.allowBackKeyTap = true
end

function PayPanelCoin:onKeyBackClicked()
    self:onCloseBtnTap()
end

function PayPanelCoin:refreshPayData()
    self.curCoin = UserManager.getInstance().user:getCoin()
	-- local goodsMeta = MetaManager:getInstance():getGoodMeta(self.goodsId)
	self.dcWindmillInfo = DCWindmillObject:create()
	self.dcWindmillInfo:setGoodsId(goodsId)
	print("PayPanelCoin:refreshPayData()",self.coinTarget,curCoin,diffCount,self.goodsId)
	if self.buyCoinReasonType == BuyCoinReasonType.kPregameProp then
		if not self.dc then
			self.dc = true
			local params = {}
			params.category = "canyu"
			params.sub_category = "click"
			params.name = "preppropCoin"
			params.game_type = "stage"
			params.t1 = UserManager.getInstance().user:getCoin()
			params.t2 = UserManager.getInstance().user:getCash() >= self.cash and 1 or 2
			DcUtil:UserTrack(params)
		end
	end
end

function PayPanelCoin:init(coinGoodsId, initNum, buyCoinReasonType, okCallBack, closeCallBack, isDarkSkin, goodsIcon, goodsTitleName, goodsDesc, ...)
    assert(coinGoodsId~=nil and type(coinGoodsId)=="number")
    assert(initNum~=nil and type(initNum)=="number")
    assert(buyCoinReasonType~=nil)
    assert(#{...}==0)

    self:loadRequiredResource("ui/BuyConfirmPanel.json")

    self.goodsId = coinGoodsId
    self.goodsIdInfo = GoodsIdInfoObject:create(coinGoodsId)
    self.initNum = initNum
    self.targetNumber = initNum
    self.okCallBack = okCallBack
    self.closeCallBack = closeCallBack
	self.buyCoinReasonType = buyCoinReasonType
	self.activityId = nil
	
    if isDarkSkin then
        PayPanelConfirmBase_VerB.changeSkinModeToDark(self, true)
        self.ui = self:buildInterfaceGroup("PayPanelWindMill_newDrak")
    else
        PayPanelConfirmBase_VerB.changeSkinModeToDark(self, false)
        self.ui = self:buildInterfaceGroup("PayPanelWindMill_newLight")
    end

	self.curCoin = UserManager.getInstance().user:getCoin()

    PayPanelConfirmBase_VerB.init(self)

    -- local printUi
    -- printUi = function (node, space)
    --     printx(0,string.rep(" ",space).."name:"..(node.name or(node.getName and node:getName()) or ""))
    --     for _,v in pairs(node:getChildrenList()) do
    --         printUi(v,space+1)
    --     end
    -- end
    -- printUi(self.ui,0)
    
    local iconBuilder = InterfaceBuilder:create(PanelConfigFiles.properties)
    goodsIcon = goodsIcon or iconBuilder:buildGroup("Goods_642")
    goodsTitleName = goodsTitleName or localize("goods.name.text642")
    goodsDesc = goodsDesc or localize("buy.coin.panel.text")
    PayPanelConfirmBase_VerB.setItemBubbleIcon(self, goodsIcon)
    self.panelTitle:setString("购买 "..goodsTitleName)
    self.propDescLabel:setString(goodsDesc)

    self.buyLogic = nil
    self.buyTarget = {
        goodsId = nil,
        id = nil,
        price = nil,
        maxNum = nil
    }
    self:initBuyLogic(coinGoodsId, buyCoinReasonType or BuyCoinReasonType.kPregameProp)

    self:initWindMillPart("windMillPart")
end

function PayPanelCoin:initBuyLogic(goodsId, buyCoinReasonType)
    if (buyCoinReasonType == BuyCoinReasonType.kPregameProp) then
        self.buyLogic = BuyLogic:create(goodsId, MoneyType.kGold, DcFeatureType.kStageStart, DcSourceType.kPrePropCoin)
    else
        self.buyLogic = BuyLogic:create(goodsId, MoneyType.kGold, DcFeatureType.kFruitTree, DcSourceType.kFruitTreeUpdate)
    end
    self.buyLogic:setActivityId(self.activityId)
    local price, maxNum = self.buyLogic:getPrice()
    if price == 0 then
        return false
    end
    if maxNum == -1 then
        maxNum = 99
    end
    self.targetNumber = self.initNum or 1
    if self.targetNumber < 1 then
        self.targetNumber = 1
    end
    if maxNum < self.targetNumber then
        self.targetNumber = maxNum
    end
    local goodsData = MetaManager:getInstance():getGoodMeta(goodsId)
    self.buyTarget.goodsId = goodsData.id
    self.buyTarget.id = goodsData.items[1].itemId
    self.buyTarget.price = price
    self.buyTarget.maxNum = maxNum
	
	self.dcWindmillInfo = DCWindmillObject:create()
	self.dcWindmillInfo:setGoodsId(self.goodsId)
	
	self.cash = UserManager.getInstance().user:getCash()
end

function PayPanelCoin:initWindMillPart(partName)
    self.windMillPart = self.ui:getChildByName(partName)

    --local bg = self.windMillPart:getChildByName("bg")
    --bg:setVisible(false)

    self.warningTip = self.windMillPart:getChildByName("warningTip")

    local buyBtnRes = self.windMillPart:getChildByName("btnBuy")
    self.btnBuyWindMill = ButtonIconNumberBase:create(buyBtnRes)
    self.btnBuyWindMill:setIconByFrameName("ui_images/ui_image_coin_icon_small0000")
    self.btnBuyWindMill:setColorMode(kGroupButtonColorMode.blue)
    self.btnBuyWindMill:setString(Localization:getInstance():getText("buy.prop.panel.btn.buy.txt"))
    self.btnBuyWindMill:setNumber(self.targetNumber * self.buyTarget.price)
    self.btnBuyWindMill:addEventListener(
        DisplayEvents.kTouchTap,
        function()
            self:onWindMillBuyBtnTap()
        end
    )
    self:showButtonLoopAnimation(self.btnBuyWindMill.groupNode)

    local goldText = self.windMillPart:getChildByName("goldText")
    goldText:setString(Localization:getInstance():getText("buy.prop.panel.label.treasure"))

    self.gold = self.windMillPart:getChildByName("gold")
    local cash = UserManager:getInstance().user:getCash()
    self.gold:setString(cash)
    --self.gold:setVisible(false)

    local numContrlRes = self.windMillPart:getChildByName("numContrl")
    self.leftNumBtn = numContrlRes:getChildByName("minus")
    self.leftNumBtn.bg = self.leftNumBtn:getChildByName("bg")
    self.leftNumBtn:setButtonMode(true)
    self.leftNumBtn:setTouchEnabled(true)
    self.leftNumBtn:addEventListener(
        DisplayEvents.kTouchTap,
        function()
            self:onMinusBtnTap()
        end
    )
    self.rightNumBtn = numContrlRes:getChildByName("plus")
    self.rightNumBtn.bg = self.rightNumBtn:getChildByName("bg")
    self.rightNumBtn:setButtonMode(true)
    self.rightNumBtn:setTouchEnabled(true)
    self.rightNumBtn:addEventListener(
        DisplayEvents.kTouchTap,
        function()
            self:onPlusBtnTap()
        end
    )
    self.itemNum = numContrlRes:getChildByName("num")
    self.itemNum:changeFntFile("fnt/hud.fnt")
    self.itemNum:setText(self.targetNumber)
    self.itemNum:setAnchorPoint(ccp(0.5, 1))
    self.itemNum:setPositionX(105)

    self:updateNumBtnShow()
end
