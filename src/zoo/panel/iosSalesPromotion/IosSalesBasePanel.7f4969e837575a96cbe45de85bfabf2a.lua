require 'zoo.panel.iosSalesPromotion.SalesButton'
require 'zoo.panel.iosSalesPromotion.IosSalesItemBubble'

local IosDiscountUI = class(BaseUI)
function IosDiscountUI:ctor()
    
end

function IosDiscountUI:init()
    BaseUI.init(self, self.ui)  

    local discountNumUI = self.ui:getChildByName("num")
    discountNumUI:setText(self.discoutNum)
end

function IosDiscountUI:create(ui, discoutNum)
    local discountUI = IosDiscountUI.new()
    discountUI.ui = ui
    discountUI.discoutNum = discoutNum
    discountUI:init()
    return discountUI
end


IosSalesBasePanel = class(BasePanel)

function IosSalesBasePanel:ctor()
	self.countDownLabel = nil
	self.buyButton = nil
	self.rewardsInfo = nil
	self.data = nil
	self.cdSeconds = nil
	self.promoEndCallback = nil
end

function IosSalesBasePanel:init(ui)
	BasePanel.init(self, ui)

    local titleUI = self.ui:getChildByName("title")
    self.panelTitle = TextField:createWithUIAdjustment(titleUI:getChildByName("panelTitleSize"), titleUI:getChildByName("panelTitle"))
    titleUI:addChild(self.panelTitle)

	local closeBtn = self.ui:getChildByName("closeBtn")
	closeBtn:setTouchEnabled(true)
	closeBtn:setButtonMode(true)
	closeBtn:addEventListener(DisplayEvents.kTouchTap,  function ()
		self:onCloseBtnTapped()
	end)

    self.countDownLabel = self.ui:getChildByName("label")

    self.buyButton = SalesButton:create(self.ui:getChildByName("buyBtn"))
	self.buyButton:addEventListener(DisplayEvents.kTouchTap, function (evt)
		self:onBuyBtnTap()
	end)
	self.buyButton:setString(localize("buy.gold.panel.money.mark")..self.data.price)
	self.buyButton:setOtherString(localize("buy.prop.panel.btn.buy.txt"))
	self.buyButton:setOriPrice(localize("buy.gold.panel.money.mark")..self.data.oriPrice)	

	self.resetButton = GroupButtonBase:create(ui:getChildByName('resetBtn'))
	self.resetButton:setString("重置道具")
    self.resetButton:ad(DisplayEvents.kTouchTap, function () self:onResetPanel() end)
    self.resetButton:setVisible(IosPayGuide:maintenanceEnabled() and IosPayGuide:isInAppleVerification())

    IosDiscountUI:create(self.ui:getChildByName("discount"), self.data.discount) 

    self.dcIosInfo = DCIosRmbObject:create()
    self.dcIosInfo:setGoodsId(self.data.productIdentifier)
    self.dcIosInfo:setGoodsType(1)
    self.dcIosInfo:setGoodsNum(1)
    self.dcIosInfo:setRmbPrice(self.data.iapPrice)

    self.ios_ali_link = self.ui:getChildByName('ios_ali_link')
    if self.ios_ali_link then
        self.ios_ali_link:setVisible(false)
    end

    self:startTimer()
end

function IosSalesBasePanel:pushSingleReward(icon, itemId, num)
	if not self.rewardsInfo then 
		self.rewardsInfo = {}
	end
	local singleReward = {}
	singleReward.icon = icon
	singleReward.itemId = itemId 
	singleReward.num = num

	table.insert(self.rewardsInfo, singleReward)
end

function IosSalesBasePanel:buySuccess()
    if self.isDisposed then return end
    if IosPayGuide:maintenanceEnabled() and IosPayGuide:isInAppleVerification() then
        self:playRewardAnim(self.rewardsInfo)
        self:onResetPanel()
    else
        self:setBuyBtnEnable(false)
        self:playRewardAnim(self.rewardsInfo)
        if self.promoEndCallback then
            self.promoEndCallback()
        end
    end
end

function IosSalesBasePanel:onBuyBtnTap()
	self:setBuyBtnEnable(false)
	self:setResetBtnEnable(false)
	local guideModel = require("zoo.gameGuide.IosPayGuideModel"):create()

	local function onBuySuccess()
		self:buySuccess()
	end

	local function onBuyFailed(errCode, errMsg, noTip)
		if self.isDisposed then return end
        self:setBuyBtnEnable(true)
        self:setResetBtnEnable(true)
        if not noTip then 
            CommonTip:showTipWithErrCode(localize("buy.gold.panel.err.undefined"), errCode, "negative", nil, 3)
        end
	end

    local function loadCompleteFunc()
        if IosPayGuide:maintenanceEnabled() and IosPayGuide:isInAppleVerification() then
            local logic = IapBuyPropLogic:create(self.data, DcFeatureType.kActivityInner, DcSourceType.kActPre.."ios_sales", self.dcIosInfo)
            if logic then 
                logic:buy(onBuySuccess, onBuyFailed)
            end
            return
        end

        if guideModel:isInOneYuanShopPromotion() then
            local logic = IapBuyPropLogic:create(self.data, DcFeatureType.kActivityInner, DcSourceType.kActPre.."ios_sales", self.dcIosInfo)
            if logic then 
                logic:buy(onBuySuccess, onBuyFailed)
            end
        else
            if self.promoEndCallback then self.promoEndCallback() end
            self:onCloseBtnTapped()
            CommonTip:showTip(localize('您已经购买过特价道具或者活动已过期！'))
        end
    end

    local function loadFailFunc()
        CommonTip:showTip(localize("dis.connect.warning.tips"))
        self:setBuyBtnEnable(true)
        self:setResetBtnEnable(true)
    end

    local function onUserLogin()
    	guideModel:loadPromotionInfo(loadCompleteFunc, loadFailFunc, true)
    end

    local function onUserNotLogin()
    	 self:setBuyBtnEnable(true)
    	 self:setResetBtnEnable(true)
    end

    RequireNetworkAlert:callFuncWithLogged(onUserLogin, onUserNotLogin)
end

function IosSalesBasePanel:setButtonDelayEnable(delayTime)
	local _delayTime = delayTime or 1
	local function rebecomeEnable()
		self:setBuyBtnEnable(true)
		self:setResetBtnEnable(true)
	end
	self:setBuyBtnEnable(false)
	self:setResetBtnEnable(false)
	setTimeOut(rebecomeEnable, _delayTime)		
end

function IosSalesBasePanel:setBuyBtnEnable(isEnable)
	if self.isDisposed then return end
	self.buyButton:setEnabled(isEnable)
end

function IosSalesBasePanel:setResetBtnEnable(isEnable)
	if self.isDisposed then return end
	local isVisible = self.resetButton:isVisible()
	if isVisible then 
		self.resetButton:setEnabled(isEnable)
	end
end

function IosSalesBasePanel:startTimer()
    if self.schedId then
        CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedId)
        self.schedId = nil
    end
    local function onTick()
        if self.isDisposed then return end
        self.cdSeconds = self.cdSeconds - 1
        if self.cdSeconds >= 0 then
            self.countDownLabel:setString(localize("ios.special.offer.desc")..convertSecondToHHMMSSFormat(self.cdSeconds))
        else
            if self.schedId then
                CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedId)
                self.schedId = nil
            end
            if not self.isDisposed then 
                self.buyButton:setEnabled(IosPayGuide:maintenanceEnabled() and IosPayGuide:isInAppleVerification())
            end
            if self.promoEndCallback then
                self.promoEndCallback()
            end
        end
    end
    self.schedId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onTick, 1, false)
    onTick()
end

function IosSalesBasePanel:onResetPanel()
    local guideModel = require("zoo.gameGuide.IosPayGuideModel"):create()
    local function resetSuccess()
    	self:onCloseBtnTapped()
    	IosPayGuide:startOneYuanShop()
    	IosPayGuide:updateOneYuanShopIcon()
    end

    local function resetFailed()
    	CommonTip:showTip(localize("dis.connect.warning.tips"))
    	self:setResetBtnEnable(true)
    end
    guideModel:resetOneYuanShop(resetSuccess, resetFailed)

    self:setResetBtnEnable(false)
end

function IosSalesBasePanel:playRewardAnim(rewards)
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

function IosSalesBasePanel:popout()
	PopoutQueue:sharedInstance():push(self)
end

function IosSalesBasePanel:removePopout()
    self.allowBackKeyTap = false
    PopoutManager:sharedInstance():remove(self)
    IosPayGuide:setSalesPanel(nil)
end

function IosSalesBasePanel:popoutShowTransition()
	self.allowBackKeyTap = true
	self:_calcPosition()
end

function IosSalesBasePanel:onCloseBtnTapped()
    local payResult = self.dcIosInfo:getResult()
    if payResult and payResult ~= IosRmbPayResult.kSuccess then 
        if payResult == IosRmbPayResult.kSdkFail then 
            self.dcIosInfo:setResult(IosRmbPayResult.kCloseAfterSdkFail)
        elseif payResult and payResult == IosRmbPayResult.kNoRealNameAuthed then
            self.dcIosInfo:setResult(IosRmbPayResult.kCloseAfterNoRealNameAuthed)
        else
            self.dcIosInfo:setResult(IosRmbPayResult.kCloseDirectly)
        end
        PaymentIosDCUtil.getInstance():sendIosRmbPayEnd(self.dcIosInfo)  
    end
    self:removePopout()
end


