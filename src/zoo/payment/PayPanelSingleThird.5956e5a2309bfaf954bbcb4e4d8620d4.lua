require 'zoo.panelBusLogic.AliQuickPayPromoLogic'

PayPanelSingleThird = class(PayPanelConfirmBase)
local AliQuickPayGuide = require "zoo.panel.alipay.AliQuickPayGuide"
local WechatQuickPayGuide = require "zoo.panel.wechatPay.WechatQuickPayGuide"

function PayPanelSingleThird:ctor()

end

function PayPanelSingleThird:getExtendedHeight()
	return 695
end

function PayPanelSingleThird:getFoldedHeight()
	return 415
end

function PayPanelSingleThird:init()
	self.ui	= self:buildInterfaceGroup("PayPanelSingleThird") 
	PayPanelConfirmBase.init(self)

	self:initQuickPayChoose()
	self:initQuickPayDescPanel()
	local priceLabelUI = self.ui:getChildByName("priceLabel")
	local price = PaymentManager:getPriceByPaymentType(self.goodsIdInfo:getGoodsId(), self.goodsIdInfo:getGoodsType(), self.paymentType)
	local formatPrice = string.format("%s%0.2f", Localization:getInstance():getText("buy.gold.panel.money.mark"), price)
	priceLabelUI:setString(formatPrice)

	local btnShowConfig = PaymentManager.getInstance():getPaymentShowConfig(self.paymentType, price)
	self.buyButton = ButtonIconsetBase:create(self.ui:getChildByName("buyBtn"))
	self.buyButton.paymentType = self.paymentType
	self.buyButton:setColorMode(kGroupButtonColorMode.blue)
	self.buyButton:setString(Localization:getInstance():getText(btnShowConfig.name))
	self.buyButton:setIconByFrameName(btnShowConfig.smallIcon)
	self.buyButton:addEventListener(DisplayEvents.kTouchTap,  function ()
			self:onRmbBuyBtnTap()
		end)
	self:showButtonLoopAnimation(self.buyButton.groupNode)
end

function PayPanelSingleThird:initQuickPayChoose()
	local aliQuickChooseUI = self.ui:getChildByName("aliQuickChoose")
	local aliQuestionBtnUI = self.ui:getChildByName("aliQuestionBtn")
	self.ui:getChildByName('aliQuickChoose_reduce'):setVisible(false)
	self.chooseIcon = aliQuickChooseUI:getChildByName("checkIcon")
	if self.paymentType == Payments.ALIPAY and not UserManager.getInstance():isAliSigned() and AliQuickPayGuide.isGuideTime() then
		if AliQuickPayPromoLogic:isEntryEnabled() then
			aliQuickChooseUI:setVisible(false)
			aliQuickChooseUI = self.ui:getChildByName('aliQuickChoose_reduce')
			aliQuickChooseUI:setVisible(true)
			self.chooseIcon = aliQuickChooseUI:getChildByName("checkIcon")
			aliQuickChooseUI:setTouchEnabled(true, 0, true)
			aliQuickChooseUI:ad(DisplayEvents.kTouchTap, function() 
					local value = not self.chooseIcon:isVisible()
					self.chooseIcon:setVisible(value)
					_G.use_ali_quick_pay = value
				end)
			local chooseLabel = aliQuickChooseUI:getChildByName("text")
			chooseLabel:setString(localize("alipay.kf.game.2.99"))
			self.chooseIcon:setVisible(true)
			_G.use_ali_quick_pay = true
		else
			aliQuickChooseUI:setTouchEnabled(true, 0, true)
			aliQuickChooseUI:ad(DisplayEvents.kTouchTap, function() 
					local value = not self.chooseIcon:isVisible()
					self.chooseIcon:setVisible(value)
					_G.use_ali_quick_pay = value
				end)
			local chooseLabel = aliQuickChooseUI:getChildByName("text")
			chooseLabel:setString(localize("panel.choosepayment.alipay.kuaifu"))

			-- 默认是勾上的
			self.chooseIcon:setVisible(true)
			_G.use_ali_quick_pay = true
		end

		self.aliQuestionBtnLight = aliQuestionBtnUI:getChildByName("light")
		self.aliQuestionBtnLight:setVisible(false)
		self.aliQuestionBtnDark = aliQuestionBtnUI:getChildByName("dark")
		aliQuestionBtnUI:setTouchEnabled(true, 0, true)
		aliQuestionBtnUI:ad(DisplayEvents.kTouchTap, function() 
				self:onAliQuestionButtonClick()
			end)
	elseif self.paymentType == Payments.WECHAT and 
		not UserManager.getInstance():isWechatSigned() and 
		WechatQuickPayGuide.isGuideTime() and 
		WechatQuickPayLogic:getInstance():isMaintenanceEnabled() then
		self.chooseIcon = aliQuickChooseUI:getChildByName("checkIcon")
		aliQuickChooseUI:setTouchEnabled(true, 0, true)
		aliQuickChooseUI:ad(DisplayEvents.kTouchTap, function() 
				local value = not self.chooseIcon:isVisible()
				self.chooseIcon:setVisible(value)
			end)
		local chooseLabel = aliQuickChooseUI:getChildByName("text")
		chooseLabel:setString(localize("wechat.kf.enter2"))

		self.aliQuestionBtnLight = aliQuestionBtnUI:getChildByName("light")
		self.aliQuestionBtnLight:setVisible(false)
		self.aliQuestionBtnDark = aliQuestionBtnUI:getChildByName("dark")
		aliQuestionBtnUI:setTouchEnabled(true, 0, true)
		aliQuestionBtnUI:ad(DisplayEvents.kTouchTap, function() 
				self:onAliQuestionButtonClick()
			end)

		if not WechatQuickPayLogic:isAutoCheckEnabled() then
			self.chooseIcon:setVisible(false)
		end
	else
		aliQuickChooseUI:setVisible(false)
		aliQuestionBtnUI:setVisible(false)
	end

	local uiVisible = aliQuickChooseUI:isVisible()
	if not uiVisible and self.chooseIcon then 
		self.chooseIcon:setVisible(false)
	end
end

function PayPanelConfirmBase:onAliQuestionButtonClick()
	if not self.animComplete then return end
	if self.extended then 
		self:foldWithoutAnimation()
	end
	self.animComplete = false
	if self.aliDescExtended then 
		self.aliQuestionBtnLight:setVisible(false)
		self.aliQuestionBtnDark:setVisible(true)
		self.aliDescExtendedPanel:setVisible(false)
		self.aliDescExtended = false
		local size = self.bg:getGroupBounds().size
		self.bg:setPreferredSize(CCSizeMake(size.width, self:getFoldedHeight()))
		self.bottom:setPositionY(-(self:getFoldedHeight() + 24))
		self:runAction(CCSequence:createWithTwoActions(
		               CCEaseSineOut:create(CCMoveBy:create(0.2, ccp(0, -100))),
		               CCCallFunc:create(function()
		               		self.animComplete = true
                    	end )
		               ))
	else 
		if self.paymentType == Payments.ALIPAY then
			if AliQuickPayPromoLogic:isEntryEnabled() then
		        DcUtil:UserTrack({category = 'alipay_mm_299_event', sub_category = '299_help'})
		    else
		        DcUtil:UserTrack({category='alipay_mianmi_accredit', sub_category = 'help'})
		    end
		elseif self.paymentType == Payments.WECHAT then
			DcUtil:UserTrack({ category='wechat_mm_accredit', sub_category = 'help'})
		end
		self.aliQuestionBtnLight:setVisible(true)
		self.aliQuestionBtnDark:setVisible(false)
		local size = self.bg:getGroupBounds().size
		size = {width = size.width, height = size.height}
		self:runAction(CCSequence:createWithTwoActions(
		               CCEaseSineOut:create(CCMoveBy:create(0.2, ccp(0, 100))),
		               CCCallFunc:create(function()
	                     	self.aliDescExtendedPanel:setVisible(true)
							self.aliDescExtended = true
							self.animComplete = true
							if self.bg and not self.bg.isDisposed then
			                	self.bg:setPreferredSize(CCSizeMake(size.width, self:getExtendedHeight()))
			                end
			                self.bottom:setPositionY(-(self:getExtendedHeight() + 24))
		                end)
		               ))
	end
end

function PayPanelSingleThird:initQuickPayDescPanel()
	self.aliDescExtendedPanel = self.ui:getChildByName("aliDescPanel")
	self.aliDescExtendedPanel:setVisible(false)
	if self.paymentType == Payments.ALIPAY and UserManager.getInstance():isAliNeverSigned() and AliQuickPayGuide.isGuideTime() then 
		self.aliDescExtended = false
		self.aliDescExtendedPanel:getChildByName("tip1"):setText(localize("alipay.pay.kf.confirm"))--"什么是支付宝快捷支付？")
		self.aliDescExtendedPanel:getChildByName("tip1"):setColor(ccc3(0, 102, 51))
		self.aliDescExtendedPanel:getChildByName("tip2"):setString(localize("alipay.kf.desc.1"))-- "开通快捷支付后，每次小额支付时不再需要反复输入密码，方便安全。")
		self.aliDescExtendedPanel:getChildByName("tip3"):setString(localize("alipay.kf.desc.2"))--"1.安全保障，仅限小额支付。")
		self.aliDescExtendedPanel:getChildByName("tip4"):setString(localize("alipay.kf.desc.3"))--"2.此操作仅授权给开心消消乐。")
		if AliQuickPayPromoLogic:isEntryEnabled() then
			self.aliDescExtendedPanel:getChildByName('reduceIcon'):setVisible(true)
			self.aliDescExtendedPanel:getChildByName('reduceText'):setVisible(true)
			self.aliDescExtendedPanel:getChildByName('reduceText'):setString(localize('alipay.kf.game.2.99'))
		else
			self.aliDescExtendedPanel:getChildByName('reduceIcon'):setVisible(false)
			self.aliDescExtendedPanel:getChildByName('reduceText'):setVisible(false)
		end
	elseif self.paymentType == Payments.WECHAT and UserManager.getInstance():isWechatNeverSigned() and WechatQuickPayGuide.isGuideTime() 
	and WechatQuickPayLogic:getInstance():isMaintenanceEnabled() then 
		self.aliDescExtended = false
		self.aliDescExtendedPanel:getChildByName("tip1"):setText(localize("wechat.kf.help.1"))
		self.aliDescExtendedPanel:getChildByName("tip1"):setColor(ccc3(0, 102, 51))
		self.aliDescExtendedPanel:getChildByName("tip2"):setString(localize("wechat.kf.help.2"))
		self.aliDescExtendedPanel:getChildByName("tip3"):setString(localize("wechat.kf.help.3"))
		self.aliDescExtendedPanel:getChildByName("tip4"):setString(localize("wechat.kf.help.4"))
		self.aliDescExtendedPanel:getChildByName('reduceIcon'):setVisible(false)
		self.aliDescExtendedPanel:getChildByName('reduceText'):setVisible(false)
	else
		return
	end
	
end

function PayPanelSingleThird:foldWithoutAnimation()
	if self.isDisposed then return end
	self.extended = false
	self.aliDescExtended = false
	self.animComplete = true

	self:stopTutorial()
	local size = self.bg:getGroupBounds().size
	self.bg:setPreferredSize(CCSizeMake(size.width, self:getFoldedHeight()))
	self:setPositionY(self:getPositionY() - 100)

	self.extendedPanel:setVisible(false)
	self.aliDescExtendedPanel:setVisible(false)

	self.helpButton_light:setVisible(false)
	self.helpButton_dark:setVisible(true)

	self.aliQuestionBtnLight:setVisible(false)
	self.aliQuestionBtnDark:setVisible(true)
end

function PayPanelSingleThird:onHelpButtonClick()
	if self.aliDescExtended then 
		self:foldWithoutAnimation()
	end

	PayPanelConfirmBase.onHelpButtonClick(self)
end

function PayPanelSingleThird:onCloseBtnTap()
	if self.peDispatcher then 
		self.peDispatcher:dispatchBeforePanelCloseEvent(self.chooseIcon:isVisible(), self.paymentType)
		self.peDispatcher:dispatchPanelCloseEvent()
	end
	
	_G.use_ali_quick_pay = false

	PayPanelConfirmBase.onCloseBtnTap(self)
end

function PayPanelSingleThird:onRmbBuyBtnTap()
	local function rebecomeEnable()
		self:setBuyBtnEnabled(true)
	end
	self:setBuyBtnEnabled(false)
	setTimeOut(rebecomeEnable, 5)

	local function cancelCallback()
		--可以给个tip什么的
	end

	local isChooseIconVisible = self.chooseIcon:isVisible()
	local function successCallback()
		if self.peDispatcher then 
			self.peDispatcher:dispatchBeforePanelPayEvent(isChooseIconVisible, self.paymentType)
			self.peDispatcher:dispatchPanelPayEvent(self.paymentType)
		end
	end
	printx( 3 , ' ', self.paymentType == Payments.ALIPAY, UserManager.getInstance():isAliSigned())
	if self.paymentType == Payments.ALIPAY and not UserManager.getInstance():isAliSigned() and isChooseIconVisible then
		-- AliAppSignAndPayLogic:getInstance():setUserChoice(isChooseIconVisible)
		_G.use_ali_quick_pay = isChooseIconVisible
		if not PaymentBase:getPayment(Payments.ALI_SIGN_PAY):isEnabled() then
			-- local AliSignAccountPanel = require "zoo.panel.alipay.AliPaymentSignAccountPanel"
			-- local panel = AliSignAccountPanel:create(AliQuickSignEntranceEnum.BUY_IN_GAME_PANEL)
			-- if AliQuickPayPromoLogic:isEntryEnabled() then
			-- 	panel:setReduceShowOption(AliSignAccountPanel.showNormalReduce)
			-- end
			-- panel:popout(cancelCallback, successCallback)
			local function onSignCallback(ret, data)
            	if self.isDisposed then return end
                if ret == AlipaySignRet.Success then
                    successCallback()
                elseif ret == AlipaySignRet.Cancel then
                	cancelCallback()
                elseif ret == AlipaySignRet.Fail then
                end
            end
            AlipaySignLogic.getInstance():startSign(AliQuickSignEntranceEnum.BUY_IN_GAME_PANEL, onSignCallback)
		else
			-- 去aliapp签约并支付
			successCallback()
		end
	elseif self.paymentType == Payments.WECHAT and not UserManager.getInstance():isWechatSigned() and isChooseIconVisible then
		if WechatQuickPayLogic:getInstance():isMaintenanceEnabled() then
			local function wechatSignSuccess()
				if self.peDispatcher then 
					self.peDispatcher:dispatchPanelPayEvent(self.paymentType)
				end				
			end
			local function wechatSignFail(error_code)
				if error_code == -1002 then
	                CommonTip:showTip(localize('wechat.kf.sign.fail.title')..'\n'..localize('wechat.kf.sign.fail.1'), 'negative', nil, 3)
	            elseif error_code then
	            	CommonTip:showTip(localize('wechat.kf.sign.fail.title')..'\n'..localize('error.tip.'..error_code), 'negative', nil, 3)
	            else
	            	CommonTip:showTip(localize('wechat.kf.sign.fail.title')..'\n'..localize('wechat.kf.sign.fail.2'), 'negative', nil, 3)
	            end
				if self.isDisposed then return end
				rebecomeEnable()
				if self.chooseIcon then
					self.chooseIcon:setVisible(false)
					self.signFailed = true
				end
			end
			local entry = 4
			local scene = Director:sharedDirector():getRunningScene()
			if scene and scene:is(GamePlaySceneUI) then
				entry = 2
			end
			-- 进来默认情况是自动勾选的
			local isAutoCheck = true
			if self.signFailed then -- 如果签约失败了，再进来就是主动勾选的
				isAutoCheck = false
			end
			WechatQuickPayLogic:getInstance():sign(successCallback, wechatSignFail, entry, isAutoCheck)
		else
			successCallback()
		end
	else
		successCallback()
	end
end

function PayPanelSingleThird:setBuyBtnEnabled(isEnable)
	if self.buyButton and not self.buyButton.isDisposed then 
		self.buyButton:setEnabled(isEnable)
	end
end

function PayPanelSingleThird:create(peDispatcher, goodsIdInfo, paymentType)
	local panel = PayPanelSingleThird.new()
	panel.peDispatcher = peDispatcher
	panel.goodsIdInfo = goodsIdInfo
	panel.paymentType = paymentType
	panel:loadRequiredResource("ui/BuyConfirmPanel.json")
	panel:init()
	return panel
end