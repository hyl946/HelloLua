require 'zoo.panel.iosSalesPromotion.IosSalesItemBubble'

local DiscountUI = class(BaseUI)
function DiscountUI:ctor()
    
end

function DiscountUI:init()
    BaseUI.init(self, self.ui)  

    local discountNumUI = self.ui:getChildByName("num")
    discountNumUI:setText(self.discoutNum)
end

function DiscountUI:create(ui, discoutNum)
    local discountUI = DiscountUI.new()
    discountUI.ui = ui
    discountUI.discoutNum = discoutNum
    discountUI:init()
    return discountUI
end


AndroidSalesBasePanel = class(BasePanel)

function AndroidSalesBasePanel:ctor()
	self.countDownLabel = nil
	self.buyButtonMain = nil
	self.buyButtonOther = nil
	self.rewardsInfo = nil
	self.data = nil
	self.cdSeconds = nil
	self.salesEndCallback = nil
end

local function getRealPlistPath(path)
    local plistPath = path
    if __use_small_res then  
        plistPath = table.concat(plistPath:split("."),"@2x.")
    end

    return plistPath
end

function AndroidSalesBasePanel:init(ui)
	BasePanel.init(self, ui)

    CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(getRealPlistPath("ui/BuyConfirmPanel.plist"))

    local titleUI = self.ui:getChildByName("title")
    self.panelTitle = TextField:createWithUIAdjustment(titleUI:getChildByName("panelTitleSize"), titleUI:getChildByName("panelTitle"))
    titleUI:addChild(self.panelTitle)

	local closeBtn = self.ui:getChildByName("closeBtn")
	closeBtn:setTouchEnabled(true)
	closeBtn:setButtonMode(true)
	closeBtn:addEventListener(DisplayEvents.kTouchTap,  function ()
		self:onCloseBtnTapped()
	end)

    local goodsId = self.data.goodsId
    local oriPrice = localize("buy.gold.panel.money.mark")..self.data.oriPrice
    local oriPriceUI = self.ui:getChildByName("oriPrice")
    oriPriceUI:setString("原价："..oriPrice)
    local nowPrice = localize("buy.gold.panel.money.mark")..self.data.nowPrice
    local nowPriceUI = self.ui:getChildByName("nowPrice")
    nowPriceUI:setString("现价："..nowPrice)
    -- local formatPrice = string.format("%s%0.2f", Localization:getInstance():getText("buy.gold.panel.money.mark"), price)

    local btnShowConfig = PaymentManager.getInstance():getPaymentShowConfig(self.mainPayment, nowPrice)
    self.buyButtonMain = ButtonIconsetBase:create(self.ui:getChildByName("buyBtnMain"))
    self.buyButtonMain.paymentType = self.mainPayment
    -- self.buyButtonMain:setColorMode(kGroupButtonColorMode.blue)
    self.buyButtonMain:setString(Localization:getInstance():getText(btnShowConfig.name))
    self.buyButtonMain:setIconByFrameName(btnShowConfig.smallIcon)
    self.buyButtonMain:addEventListener(DisplayEvents.kTouchTap,  function ()
            self:onBuyBtnTap(self.mainPayment)
        end)

    local buyButtonOtherUI = self.ui:getChildByName("buyBtnOther")
    local anohterPayment = nil
    if self.otherPaymentTable and #self.otherPaymentTable>0 then
        anohterPayment = self.otherPaymentTable[1]
        local btnShowConfigOhter = PaymentManager.getInstance():getPaymentShowConfig(anohterPayment, nowPrice)
        self.buyButtonOther = ButtonIconsetBase:create(buyButtonOtherUI)
        self.buyButtonOther.paymentType = anohterPayment
        self.buyButtonOther:setColorMode(kGroupButtonColorMode.blue)
        self.buyButtonOther:setString(Localization:getInstance():getText(btnShowConfigOhter.name))
        self.buyButtonOther:setIconByFrameName(btnShowConfigOhter.smallIcon)
        self.buyButtonOther:addEventListener(DisplayEvents.kTouchTap,  function ()
                self:onBuyBtnTap(anohterPayment)
            end)
    else
        buyButtonOtherUI:setVisible(false)
        self.buyButtonMain:setPositionX(350)
    end  

    DiscountUI:create(self.ui:getChildByName("discount"), self.data.discount) 

    self.goodsIdInfo = GoodsIdInfoObject:create(goodsId)
    self.dcAndroidInfo = DCAndroidRmbObject:create()
    self.dcAndroidInfo:setGoodsId(self.goodsIdInfo:getGoodsId())
    self.dcAndroidInfo:setGoodsType(self.goodsIdInfo:getGoodsType())
    self.dcAndroidInfo:setGoodsNum(1)
    self.dcAndroidInfo:setInitialTypeList(self.mainPayment, anohterPayment)
    PaymentDCUtil.getInstance():sendAndroidRmbPayStart(self.dcAndroidInfo)

    self.countDownLabel = self.ui:getChildByName("label")
    self:startTimer()
end

function AndroidSalesBasePanel:pushSingleReward(icon, itemId, num)
	if not self.rewardsInfo then 
		self.rewardsInfo = {}
	end
	local singleReward = {}
	singleReward.icon = icon
	singleReward.itemId = itemId 
	singleReward.num = num

	table.insert(self.rewardsInfo, singleReward)
end

function AndroidSalesBasePanel:onBuyBtnTap(paymentType)
    self:setBuyBtnEnable(false)

    local function onBuySuccess()
        if self.isDisposed then 
            return 
        end
        self:playRewardAnim(self.rewardsInfo)
        if self.salesEndCallback then 
            self.salesEndCallback() 
        end
    end

    local function onBuyFail()
        if self.isDisposed then return end
        self:setBuyBtnEnable(true)
        CommonTip:showTip(localize('buy.gold.panel.err.undefined'))
    end

    local function onBuyCancel()
        if self.isDisposed then return end
        self:setBuyBtnEnable(true) 
    end

    local function rebecomeEnable()
        self:setBuyBtnEnable(true)
    end

    local function loadCompleteFunc()
        if AndroidSalesManager.getInstance():isInItemSalesPromotion() then
            local logic = IngamePaymentLogic:createWithGoodsInfo(self.goodsIdInfo, self.dcAndroidInfo)
            logic:setBuyConfirmPanel(self)
            logic:salesBuy(paymentType, onBuySuccess, onBuyFail, onBuyCancel, self.repayChooseTable)

            if paymentType == Payments.WECHAT or paymentType == Payments.QQ_WALLET or paymentType == Payments.MI_WXPAY then 
                setTimeOut(rebecomeEnable, 3)       --这里是防止微信未登录没有回调的情况
            end
        else
            if self.salesEndCallback then self.salesEndCallback() end
            self:onCloseBtnTapped()
            CommonTip:showTip(localize('您已经购买过特价道具或者活动已过期！'))
        end
    end

    local function loadFailFunc()
        CommonTip:showTip(localize("dis.connect.warning.tips"))
        self:setBuyBtnEnable(true)
    end

    local function onUserLogin()
        AndroidSalesManager.getInstance():loadSalesInfo(loadCompleteFunc, loadFailFunc, true)
    end

    local function onUserNotLogin()
      self:setBuyBtnEnable(true)
    end

    RequireNetworkAlert:callFuncWithLogged(onUserLogin, onUserNotLogin)
end

function AndroidSalesBasePanel:setButtonDelayEnable(delayTime)
	local _delayTime = delayTime or 1
	local function rebecomeEnable()
		self:setBuyBtnEnable(true)
	end
	self:setBuyBtnEnable(false)
	setTimeOut(rebecomeEnable, _delayTime)		
end

function AndroidSalesBasePanel:setBuyBtnEnable(isEnable)
	if self.isDisposed then return end
	self.buyButtonMain:setEnabled(isEnable)
    if self.buyButtonOther then 
        self.buyButtonOther:setEnabled(isEnable)
    end
end

function AndroidSalesBasePanel:startTimer()
    if self.schedId then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedId)
        self.schedId = nil
    end
    local function onTick()
        if self.isDisposed then return end
        self.cdSeconds = AndroidSalesManager.getInstance():getItemSalesLeftSeconds() 
        if self.cdSeconds >= 0 then
            self.countDownLabel:setString(localize("ios.special.offer.desc")..convertSecondToHHMMSSFormat(self.cdSeconds))
        else
            if self.schedId then
                CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedId)
                self.schedId = nil
            end
            if not self.isDisposed then 
                self:setBuyBtnEnable(false)
            end
            if self.salesEndCallback then
                self.salesEndCallback()
            end
        end
    end
    self.schedId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onTick, 1, false)
    onTick()
end

function AndroidSalesBasePanel:playRewardAnim(rewards)
    local scene = Director:sharedDirector():getRunningScene()
    if not scene then return end
    if self.isDisposed then return end

    HomeScene:sharedInstance():checkDataChange()
    for k, v in ipairs(rewards) do
        local anim = FlyItemsAnimation:create({v})
        local bounds = v.icon:getGroupBounds()
        anim:setWorldPosition(ccp(bounds:getMidX(),bounds:getMidY()))
        anim:play()
    end
end

function AndroidSalesBasePanel:popout()
	PopoutQueue:sharedInstance():push(self)
end

function AndroidSalesBasePanel:removePopout()
    self.allowBackKeyTap = false
    PopoutManager:sharedInstance():remove(self)
end

function AndroidSalesBasePanel:dispose()
    CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile(getRealPlistPath("ui/BuyConfirmPanel.plist"))

    BasePanel.dispose(self)
end

function AndroidSalesBasePanel:popoutShowTransition()
	self.allowBackKeyTap = true
	self:_calcPosition()
end

function AndroidSalesBasePanel:onCloseBtnTapped()
    local payResult = self.dcAndroidInfo:getResult()
    if payResult and payResult == AndroidRmbPayResult.kNoNet then  
        self.dcAndroidInfo:setResult(AndroidRmbPayResult.kCloseAfterNoNet)
    elseif payResult and payResult == AndroidRmbPayResult.kNoPaymentAvailable then 
        self.dcAndroidInfo:setResult(AndroidRmbPayResult.kCloseAfterNoPaymentAvailable)
    elseif payResult and payResult == AndroidRmbPayResult.kNoRealNameAuthed then 
        self.dcAndroidInfo:setResult(AndroidRmbPayResult.kCloseAfterNoRealNameAuthed)
    else
        self.dcAndroidInfo:setResult(AndroidRmbPayResult.kCloseDirectly)
    end
    PaymentDCUtil.getInstance():sendAndroidRmbPayEnd(self.dcAndroidInfo)

    self:removePopout()
end


