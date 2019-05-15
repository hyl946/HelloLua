require "zoo.payment.PayPanelConfirmBase"
require "zoo.payment.ingameBuyPropPanels.PayPanelConfirmBase_VerB"

PayPanelWindMill_VerB = class(PayPanelConfirmBase_VerB)

local PayPanelWindMill_VerB_video = class(PayPanelWindMill_VerB)

-- local WindmillPayState = table.const{
-- 	kCanNotBuyOne = 0,
-- 	kMoreThanMinLimit = 1,
-- 	kNormal = 2,
-- 	kLessThanMaxLimit = 3,
-- 	kMoreThanMaxLimit = 4,
-- }

function PayPanelWindMill_VerB:ctor()
	--风车币买道具默认数量
	self.targetNumber = 1
end

function PayPanelWindMill_VerB:setFeatureAndSource(feature, source)
	if self.buyLogic then 
		self.buyLogic:setFeatureAndSource(feature, source)
	end
end

function PayPanelWindMill_VerB:setActivityId(activityId)
	self.activityId = activityId
end

function PayPanelWindMill_VerB:init()
	-- printx( 7 , "   PayPanelWindMill_VerB:init   " , debug.traceback())

	if self.skinMode == "light" then
		printx( 1 , "   PayPanelWindMill_VerB  build with Light Skin !!!!!!!!!!!!!!!!!!!!!!!!!")
		self.ui	= self:buildInterfaceGroup("PayPanelWindMill_newLight")
	else
		printx( 1 , "   PayPanelWindMill_VerB  build with Drak Skin !!!!!!!!!!!!!!!!!!!!!!!!!")
		self.ui	= self:buildInterfaceGroup("PayPanelWindMill_newDrak")
	end
	
	printx( 1 , "     PayPanelWindMill_VerB:init -------------------- " , self.ui)
	PayPanelConfirmBase.init(self)

	self:initData()
	self:initWindMillPart("windMillPart")
end

function PayPanelWindMill_VerB:initData()
	-- 获取数据
	self.target = {}
	local goodsId = self.goodsId
	local goodsData = MetaManager:getInstance():getGoodMeta(goodsId)
	self.buyLogic = BuyLogic:create(goodsId, MoneyType.kGold)
	self.buyLogic:setActivityId(self.activityId)
	local price, num = self.buyLogic:getPrice()
	if price == 0 then return false end
	if num == -1 then 
		num = 9 
		self.noDailyLimit = true
	end
	self.targetNumber = self.initNum or 1
	if self.targetNumber < 1 then self.targetNumber = 1 end
	if num < self.targetNumber then self.targetNumber = num end
	self.target.goodsId = goodsData.id
	self.target.id = goodsData.items[1].itemId
	self.target.price = price
	self.target.maxNum = num
	if self.buyLimitPerOnce and self.buyLimitPerOnce > 0 then
		self.target.maxNum = math.min(self.target.maxNum, self.buyLimitPerOnce)
	end
end

function PayPanelWindMill_VerB:initWindMillPart(partName)
	self.windMillPart = self.ui:getChildByName(partName)
	
	--local bg = self.windMillPart:getChildByName("bg")
	--bg:setVisible(false)

	self.warningTip = self.windMillPart:getChildByName("warningTip")

	local buyBtnRes = self.windMillPart:getChildByName("btnBuy")
	self.btnBuyWindMill = ButtonIconNumberBase:create(buyBtnRes)
	self.btnBuyWindMill:setIconByFrameName("ui_images/ui_image_coin_icon_small0000")
	self.btnBuyWindMill:setColorMode(kGroupButtonColorMode.blue)
	self.btnBuyWindMill:setString(Localization:getInstance():getText("buy.prop.panel.btn.buy.txt"))
	self.btnBuyWindMill:setNumber(self.targetNumber * self.target.price)
	self.btnBuyWindMill:addEventListener(DisplayEvents.kTouchTap, function ()
		self:onWindMillBuyBtnTap()
	end)
	self:showButtonLoopAnimation(self.btnBuyWindMill.groupNode)

	local goldText = self.windMillPart:getChildByName("goldText")
	goldText:setString(Localization:getInstance():getText("buy.prop.panel.label.treasure"))

	self.gold = self.windMillPart:getChildByName("gold")
	local money = UserManager:getInstance().user:getCash()
	self.gold:setString(money)
	--self.gold:setVisible(false)

	local numContrlRes = self.windMillPart:getChildByName("numContrl")
	self.leftNumBtn = numContrlRes:getChildByName("minus")
	self.leftNumBtn.bg = self.leftNumBtn:getChildByName("bg")
	self.leftNumBtn:setButtonMode(true)
	self.leftNumBtn:setTouchEnabled(true)
	self.leftNumBtn:addEventListener(DisplayEvents.kTouchTap,  function ()
		self:onMinusBtnTap()
	end)
	self.rightNumBtn = numContrlRes:getChildByName("plus")
	self.rightNumBtn.bg = self.rightNumBtn:getChildByName("bg")
	self.rightNumBtn:setButtonMode(true)
	self.rightNumBtn:setTouchEnabled(true)
	self.rightNumBtn:addEventListener(DisplayEvents.kTouchTap,  function ()
		self:onPlusBtnTap()
	end)
	self.itemNum = numContrlRes:getChildByName("num")
	self.itemNum:changeFntFile('fnt/hud.fnt')
	self.itemNum:setText(self.targetNumber)
	self.itemNum:setAnchorPoint(ccp(0.5, 1))
	self.itemNum:setPositionX(105)

	self:updateNumBtnShow()

	self.dcWindmillInfo = DCWindmillObject:create()
	self.dcWindmillInfo:setGoodsId(self.goodsId)
	if __ANDROID then 
		PaymentDCUtil.getInstance():sendAndroidWindMillPayStart(self.dcWindmillInfo)
	end
end

function PayPanelWindMill_VerB:onCloseBtnTap()
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

	if self.callbackClose then 
		self.callbackClose()
	end
	PayPanelConfirmBase_VerB.onCloseBtnTap(self)
end

function PayPanelWindMill_VerB:onMinusBtnTap()
	self.targetNumber = self.targetNumber - 1
	if self.targetNumber <= 1 then self.targetNumber = 1 end
	self:updateNumBtnShow()
	self.itemNum:setText(self.targetNumber)
	self.btnBuyWindMill:setNumber(self.targetNumber * self.target.price)
end

function PayPanelWindMill_VerB:onPlusBtnTap()
	self.targetNumber = self.targetNumber + 1
	if self.targetNumber >= self.target.maxNum then self.targetNumber = self.target.maxNum end
	self:updateNumBtnShow()
	self.itemNum:setText(self.targetNumber)
	self.btnBuyWindMill:setNumber(self.targetNumber * self.target.price)
end

function PayPanelWindMill_VerB:updateNumBtnShow()
	local leftEnable, rightEnable = self:getWindmillPayState()
	self:setNumBtnEnable(self.leftNumBtn, leftEnable)
	self:setNumBtnEnable(self.rightNumBtn, rightEnable) 
end

function PayPanelWindMill_VerB:getWindmillPayState()
	local currentCash = UserManager:getInstance().user:getCash()
	local singlePrice = self.target.price
	local maxNum = self.target.maxNum

	local leftEnable = false
	local rightEnable = false

	if self.targetNumber > 1 then
		leftEnable = true
	end

	if self.targetNumber < maxNum then
		if currentCash >= singlePrice * (self.targetNumber + 1) then 
			rightEnable = true
		end
	end

	return leftEnable, rightEnable
end

-- function PayPanelWindMill_VerB:updateNumBtnShow()
-- 	local leftEnable = false
-- 	local rightEnable = false
-- 	local windmillPayState = self:getWindmillPayState()
-- 	if windmillPayState == WindmillPayState.kCanNotBuyOne then 
-- 		leftEnable = false
-- 		rightEnable = false
-- 	elseif windmillPayState == WindmillPayState.kMoreThanMinLimit then 
-- 		leftEnable = false
-- 		rightEnable = true
-- 	elseif windmillPayState == WindmillPayState.kNormal then 
-- 		leftEnable = true
-- 		rightEnable = true
-- 	elseif windmillPayState == WindmillPayState.kLessThanMaxLimit then 
-- 		leftEnable = true
-- 		rightEnable = false
-- 	elseif windmillPayState == WindmillPayState.kMoreThanMaxLimit then 
-- 		leftEnable = true
-- 		rightEnable = false
-- 	end

-- 	self:setNumBtnEnable(self.leftNumBtn, leftEnable)
-- 	self:setNumBtnEnable(self.rightNumBtn, rightEnable) 
-- end

-- function PayPanelWindMill_VerB:updateNumBtnShow()
-- 	local leftEnable = false
-- 	local rightEnable = false
-- 	local warningTip = ""
-- 	local windmillPayState = self:getWindmillPayState()
-- 	if windmillPayState == WindmillPayState.kCanNotBuyOne then 
-- 		leftEnable = false
-- 		rightEnable = false
-- 		warningTip = ""
-- 	elseif windmillPayState == WindmillPayState.kMoreThanMinLimit then 
-- 		leftEnable = false
-- 		rightEnable = true
-- 		warningTip = ""
-- 	elseif windmillPayState == WindmillPayState.kNormal then 
-- 		leftEnable = true
-- 		rightEnable = true
-- 		warningTip = ""
-- 	elseif windmillPayState == WindmillPayState.kLessThanMaxLimit then 
-- 		leftEnable = true
-- 		rightEnable = false
-- 		warningTip = Localization:getInstance():getText("buy.prop.panel.coin.tip3")
-- 	elseif windmillPayState == WindmillPayState.kMoreThanMaxLimit then 
-- 		if self.noDailyLimit then 
-- 			warningTip = Localization:getInstance():getText("buy.prop.panel.coin.tip1", {num = self.target.maxNum})
-- 		else
-- 			warningTip = Localization:getInstance():getText("buy.prop.panel.coin.tip2", {num = self.target.maxNum})
-- 		end
-- 		leftEnable = true
-- 		rightEnable = false
-- 	end

-- 	self:setNumBtnEnable(self.leftNumBtn, leftEnable)
-- 	self:setNumBtnEnable(self.rightNumBtn, rightEnable) 

-- 	self.warningTip:setString(warningTip)	
-- 	if warningTip ~= "" then 
-- 		local seqArr = CCArray:create()
-- 		seqArr:addObject(CCFadeTo:create(0, 255))
-- 		seqArr:addObject(CCDelayTime:create(2, 0))
-- 		seqArr:addObject(CCFadeTo:create(1, 0))
-- 		self.warningTip:stopAllActions()
-- 		self.warningTip:runAction(CCSequence:create(seqArr))
-- 	end
-- end

-- function PayPanelWindMill_VerB:getWindmillPayState()
-- 	local currentCash = UserManager:getInstance().user:getCash()
-- 	local singlePrice = self.target.price
-- 	local maxNum = self.target.maxNum

-- 	if self.targetNumber == 1 then 
-- 		if currentCash > singlePrice then 
-- 			if currentCash < singlePrice * (self.targetNumber + 1) then 
-- 				return WindmillPayState.kLessThanMaxLimit
-- 			else
-- 				return WindmillPayState.kMoreThanMinLimit
-- 			end
-- 		else
-- 			return WindmillPayState.kCanNotBuyOne
-- 		end
-- 	elseif self.targetNumber > 1 and self.targetNumber < maxNum then 
-- 		if currentCash < singlePrice * (self.targetNumber + 1) then 
-- 			return WindmillPayState.kLessThanMaxLimit
-- 		else
-- 			return WindmillPayState.kNormal
-- 		end
-- 	elseif self.targetNumber == maxNum then 
-- 		return WindmillPayState.kMoreThanMaxLimit
-- 	end
-- end
 
function PayPanelWindMill_VerB:setNumBtnEnable(numBtn, isEnable, justChangeColor)
	if not isEnable then isEnable = false end
	if numBtn and numBtn.refCocosObj then 
		numBtn.bg:applyAdjustColorShader()
		if isEnable then 
			numBtn.bg:clearAdjustColorShader()
		else
			numBtn.bg:adjustColor(0,-1, 0, 0)
		end
		if not justChangeColor then 
			numBtn:setTouchEnabled(isEnable)
		end
	end
end

function PayPanelWindMill_VerB:onWindMillBuyBtnTap()
	self.btnBuyWindMill:setEnabled(false)

	local function successCallback(goodsNum)
		if self.callbackSucc then 
			self.callbackSucc(goodsNum, self:getIconPos()) 
		end
		if not self.isDisposed then 
			self.btnBuyWindMill:setEnabled(true)
			self:removePopout()
		end
	end

	local function failCallback(errorCode)
		if self.isDisposed then return end
		self.btnBuyWindMill:setEnabled(true)
		if errorCode then
			CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(errorCode)), "negative")
		end
	end

	local function cancelCallback()
		if self.isDisposed then return end
		self.btnBuyWindMill:setEnabled(true)
	end

	local function updateGold()
		if self.isDisposed then return end
		local money = UserManager:getInstance().user:getCash()
		self.gold:setString(money)
		self.btnBuyWindMill:setEnabled(true)
	end

	local logic = WMBBuyItemLogic:create()
	logic:buy(self.goodsId, self.targetNumber, self.dcWindmillInfo, self.buyLogic, successCallback, failCallback, cancelCallback, updateGold)
end

function PayPanelWindMill_VerB:create(goodsId, callbackSucc, callbackClose, initNum, isDarkSkin, buyLimitPerOnce,isFreeVideo)
	local panel
	if isFreeVideo then
		panel = PayPanelWindMill_VerB_video.new()
	else
		panel = PayPanelWindMill_VerB.new()
		if isDarkSkin then
			panel:changeSkinModeToDark(true)
		end
	end
	if type(goodsId) == "number" then 
		panel.goodsId = goodsId
		panel.goodsIdInfo = GoodsIdInfoObject:create(goodsId)
	elseif type(goodsId) == "table" then 
		panel.goodsIdInfo = goodsId
		panel.goodsId = goodsId:getGoodsId()
	else
		assert(false, "wrong param for goodsId")
	end
	panel.callbackSucc = callbackSucc
	panel.callbackClose = callbackClose
	panel.initNum = initNum
	panel.buyLimitPerOnce = buyLimitPerOnce

	panel:loadRequiredResource("ui/BuyConfirmPanel.json")
	panel:init()
	return panel
end

------  PayPanelWindMill_VerB_video -----------

function PayPanelWindMill_VerB_video:init()
	self.ui	= self:buildInterfaceGroup("PayPanelWindMill_newAD")

	PayPanelConfirmBase.init(self)

	self.itemId = self.goodsIdInfo.trueItemId
	if not self.itemId then
		local meta = MetaManager:getInstance():getGoodMeta(self.goodsId)
		local items = meta.items
		self.itemId = items[1].itemId
	end

	self.itemCount = UserManager:getInstance():getUserPropNumber(self.itemId)
	self.isUseMode = self.itemCount>0

	self:initData()
	self:initWindMillPart("windMillPartAD")
	self:initWindMillPartOther()
end

function PayPanelWindMill_VerB_video:initWindMillPartOther()
	local buyBtnRes = self.windMillPart:getChildByName("btnAD")
	self.btnFirst = ButtonIconsetBase:create(buyBtnRes)
	self:showButtonLoopAnimation(self.btnFirst.groupNode)

	local txtItemNum = buyBtnRes:getChildByName("txtItemNum")
	local itemNumBg = buyBtnRes:getChildByName("itemNumBg")
	if self.isUseMode then
		txtItemNum:setString(self.itemCount)

		self.btnFirst:setIcon()
		self.btnFirst:setString("使用魔力鸟")
		self.btnFirst:addEventListener(DisplayEvents.kTouchTap, function ()
			if self.callbackSucc then 
				self.callbackSucc(0, self:getIconPos()) 
			end
			self:onCloseBtnTap()
		end)

		self.btnBuyWindMill:setString("免费获取")
		self.btnBuyWindMill:setIconByFrameName("res.video/videoIcon0000")
		self.btnBuyWindMill:setNumber("")
		self.btnBuyWindMill:recalcLayout(self.btnBuyWindMill.buttonStyle, {self.btnBuyWindMill.icon,  self.btnBuyWindMill.label})

		self.btnBuyWindMill:removeAllEventListeners()
		self.btnBuyWindMill:addEventListener(DisplayEvents.kTouchTap, function ()
			self:showAD()
		end)

		self.windMillPart:getChildByName("goldText"):setVisible(false)
		self.windMillPart:getChildByName("_coin"):setVisible(false)
		self.windMillPart:getChildByName("gold"):setVisible(false)
	else
		itemNumBg:setVisible(false)

		self.btnFirst:setString("免费获取")
		self.btnFirst:setIconByFrameName("res.video/videoIcon0000")
		self.btnFirst:addEventListener(DisplayEvents.kTouchTap, function ()
			self:showAD()
		end)
	end
end


function PayPanelWindMill_VerB_video:getExtendedHeight()
	return self.class.super.getExtendedHeight(self)+50
end

function PayPanelWindMill_VerB_video:getFoldedHeight()
	return self.class.super.getFoldedHeight(self)+50
end