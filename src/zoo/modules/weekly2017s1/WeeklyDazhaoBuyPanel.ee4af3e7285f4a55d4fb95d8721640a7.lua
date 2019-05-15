local WeeklyDazhaoBuyPanel = class(BasePanel)

function WeeklyDazhaoBuyPanel:ctor()
end

function WeeklyDazhaoBuyPanel:init()
	self.ui = self:buildInterfaceGroup("PayPanelWindMill_Dazhao")
	BasePanel.init(self, self.ui)

	local tip = self.ui:getChildByName("tip")
	tip:setString(Localization:getInstance():getText("购买后大招将自动生效"))
	self.goodsId = SeasonWeeklyRaceManager:getInstance():getDazhaoGoodId()

	self:initIcon()

	local goodsData = MetaManager:getInstance():getGoodMeta(self.goodsId)
	self.buyLogic = BuyLogic:create(self.goodsId, MoneyType.kGold, DcFeatureType.kRankRace, DcSourceType.kRankRaceDaZhao)
	local price, num = self.buyLogic:getPrice()
	local intPercent = math.floor(self.percentage * 10)
	self.targetNumber = 10 - intPercent
	local percentShow = math.floor(self.percentage * 100) .. "%"

	local labelBG = self.ui:getChildByName("labelBG")
	local labelSize = labelBG:getContentSize()
	local labelPos = labelBG:getPosition()
	local percentLabel = BitmapText:create("", "fnt/target_remain2.fnt", -1, kCCTextAlignmentCenter)
	-- percentLabel:setScale(1.3)
	self.ui:addChild(percentLabel)
	percentLabel:setPosition(ccp(labelPos.x + labelSize.width/2, labelPos.y - labelSize.height/2 - 8))
	percentLabel:setText("已有"..percentShow)

	local goodsName = Localization:getInstance():getText("goods.name.text"..tostring(self.goodsId))
	local panelTitle = self.ui:getChildByName("panelTitle")
	panelTitle:setString("购买 "..goodsName)

	local closeBtn = self.ui:getChildByName("closeBtn")
	closeBtn:setTouchEnabled(true)
	closeBtn:setButtonMode(true)
	closeBtn:addEventListener(DisplayEvents.kTouchTap,  function ()
		self:onCloseBtnTap()
	end)

	self.buyBtn = ButtonIconNumberBase:create(self.ui:getChildByName("btnBuy"))
	self.buyBtn:setIconByFrameName("ui_images/ui_image_coin_icon_small0000")
	self.buyBtn:setColorMode(kGroupButtonColorMode.blue)
	self.buyBtn:setString(Localization:getInstance():getText("补满"))
	self.buyBtn:setNumber(self.targetNumber * price)
	self.buyBtn:addEventListener(DisplayEvents.kTouchTap, function ()
		self:onBuyBtnTap()
	end)
	self:showButtonLoopAnimation(self.buyBtn.groupNode)

	local goldText = self.ui:getChildByName("goldText")
	goldText:setString(Localization:getInstance():getText("buy.prop.panel.label.treasure"))

	self.gold = self.ui:getChildByName("gold")
	local money = UserManager:getInstance().user:getCash()
	self.gold:setString(money)

	self.dcWindmillInfo = DCWindmillObject:create()
	self.dcWindmillInfo:setGoodsId(self.goodsId)
	if __ANDROID then 
		PaymentDCUtil.getInstance():sendAndroidWindMillPayStart(self.dcWindmillInfo)
	end
end

function WeeklyDazhaoBuyPanel:initIcon()
	local icon = BossAnimation:buildItemIcon()
	icon:setScale(1.5)
	local iconPh = self.ui:getChildByName("iconPh")
	iconPh:addChild(icon)
	icon:setPercent(self.percentage)
end

function WeeklyDazhaoBuyPanel:onBuyBtnTap()
	self.buyBtn:setEnabled(false)

	local function successCallback(goodsNum)
		if self.buySucCallback then 
			self.buySucCallback(goodsNum) 
		end
		if not self.isDisposed then 
			self:removePopout()
		end
		if MaintenanceManager:getInstance():isEnabledInGroup('WeeklyBuyDazhaoOplog', 'A', UserManager.getInstance().uid) then
			ReplayDataManager:addUploadReplayReason("weekly_buy_dazhao")
		end
	end

	local function failCallback(errorCode)
		if self.isDisposed then return end
		self.buyBtn:setEnabled(true)
		if errorCode then
			CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(errorCode)), "negative")
		end
	end

	local function cancelCallback()
		if self.isDisposed then return end
		self.buyBtn:setEnabled(true)
	end

	local function updateGold()
		if self.isDisposed then return end
		local money = UserManager:getInstance().user:getCash()
		self.gold:setString(money)
		self.buyBtn:setEnabled(true)
	end

	local logic = WMBBuyItemLogic:create()
	logic:buy(self.goodsId, self.targetNumber, self.dcWindmillInfo, self.buyLogic, successCallback, failCallback, cancelCallback, updateGold)
end

function WeeklyDazhaoBuyPanel:popout()
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

function WeeklyDazhaoBuyPanel:onKeyBackClicked()
	self:onCloseBtnTap()
end

function WeeklyDazhaoBuyPanel:onCloseBtnTap()
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

	self:removePopout()
end

function WeeklyDazhaoBuyPanel:removePopout()
	PopoutManager:sharedInstance():remove(self, true)
	self.allowBackKeyTap = false
end

function WeeklyDazhaoBuyPanel:showButtonLoopAnimation(btn)
	local btnPos = ccp( btn:getPositionX() , btn:getPositionY() )
	local btnSize = btn:getGroupBounds().size
	local originScaleX = btn:getScaleX()
	local originScaleY = btn:getScaleY()
	local baseTime = 0.5
	local baseScale = 0.95
	local arr = CCArray:create()

	arr:addObject(CCSpawn:createWithTwoActions(
		CCEaseSineOut:create( CCMoveTo:create( baseTime , ccp(btnPos.x  , btnPos.y ) ) ), 
		CCEaseSineOut:create( CCScaleTo:create(baseTime, baseScale * originScaleX , originScaleY))) )
	arr:addObject(CCSpawn:createWithTwoActions(
		CCEaseSineIn:create( CCMoveTo:create(baseTime, ccp(btnPos.x , btnPos.y) ) ), 
		CCEaseSineIn:create( CCScaleTo:create(baseTime, originScaleX, originScaleY))) )
	arr:addObject(CCSpawn:createWithTwoActions(
		CCEaseSineOut:create( CCMoveTo:create( baseTime , ccp( btnPos.x , btnPos.y)  ) ), 
		CCEaseSineOut:create( CCScaleTo:create(baseTime, originScaleX, baseScale*originScaleY))) )
	arr:addObject(CCSpawn:createWithTwoActions(
		CCEaseSineIn:create( CCMoveTo:create(baseTime, ccp(btnPos.x , btnPos.y)) ), 
		CCEaseSineIn:create( CCScaleTo:create(baseTime, originScaleX, originScaleY))) )

	btn:runAction(CCRepeatForever:create(CCSequence:create(arr)))
end

function WeeklyDazhaoBuyPanel:create(percentage, buySucCallback)
	local panel = WeeklyDazhaoBuyPanel.new()
	panel.percentage = percentage
	panel.buySucCallback = buySucCallback
	panel:loadRequiredResource("ui/BuyConfirmPanel.json")
	panel:init()
	return panel
end

return WeeklyDazhaoBuyPanel