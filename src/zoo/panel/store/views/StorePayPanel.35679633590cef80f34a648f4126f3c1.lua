
local UIHelper = require 'zoo.panel.UIHelper'

if __IOS then
	return 
end

local PayItem = require 'zoo.panel.store.views.PayItem'

_G.StorePayPanel = class(BasePanel)

StorePayPanel.Mode = {
	kNoPayType = 1,
	kOnlyOnePayType = 2,
	kNormal = 3,
	kHuaWeiYYB = 4, --华为yyb 当有短代、
}

function StorePayPanel:create()

    local panel = StorePayPanel.new()
    panel:init()
    return panel
end

function StorePayPanel:init()
    local ui = UIHelper:createUI("ui/store.json", "com.niu2x.store/pay")
	BasePanel.init(self, ui)

	UIHelper:setCenterText(self.ui:getChildByPath('title') , '支付', 'fnt/register.fnt')
	self.ui:getChildByPath('title'):setColor(hex2ccc3('7B4C06'))

	-- self:setGoodsIdInfo(GoodsIdInfoObject:create(1, GoodsType.kCurrency))

	self.buttonUI = self.ui:getChildByPath('button')

	self.button = GroupButtonBase:create(self.buttonUI)
	self.button:ad(DisplayEvents.kTouchTap, preventContinuousClick(function ( ... )
		self:onTapButton()
	end))

	self.button:setString('确认支付')


	self.buttonUI.oriPosY = self.buttonUI:getPositionY()

	self.bg = self.ui:getChildByPath('bg')
	self.bg2 = self.ui:getChildByPath('bg2')

	local function cloneSize( size )
		return {width = size.width, height = size.height}
	end

	self.bg.oriSize = cloneSize(self.bg:getPreferredSize())
	self.bg2.oriSize = cloneSize(self.bg2:getPreferredSize())


	self.vbox = self.ui:getChildByPath('vbox')
	self.vboxWidth = self.vbox.layout.width
	self.vbox.oriHeight = self.vbox.layout:getHeight()


	-- local payItem = PayItem:create(self.goodsIdInfo)
	-- payItem:setPayType(Payments.QQ)
	-- self:addPayItem(payItem)

	self:setErrorTipVisible(false)

end

function StorePayPanel:setErrorTipVisible( bVisible )
	if self.isDisposed then return end
	self.errorTipVisible = bVisible
	self.vbox:setItemVisible(1, bVisible)
	local item = self.vbox:getItem(1)




	self:refreshLayout()

	if bVisible then
		-- self.needPlayErrorTipAnim = true
		self:playErrorTipAnim()
	end
end

function StorePayPanel:createPayLogic( ... )
	if not self.payLogic then 
		self.payLogic = IngamePaymentLogic:createWithGoodsInfo(self.goodsIdInfo, nil, DcFeatureType.kNewStore, DcSourceType.kNewStore)
	end
end

function StorePayPanel:playErrorTipAnim( ... )
	if self.isDisposed then return end
	-- body

	local _play

	_play = function( ... )
		if self.isDisposed then return end
		local item = self.vbox:getItem(1)
		local FPS = 30
		local sp = item:findChildByName('sp')
		sp:setAnchorPointCenterWhileStayOrigianlPosition()
		sp:runAction(UIHelper:sequence{
			CCScaleTo:create(5/FPS, 1.2, 1.2),
			CCRotateTo:create(2/FPS, 2),
			CCRotateTo:create(2/FPS, -2),
			UIHelper:spawn{
				CCScaleTo:create(7/FPS, 1, 1),
				CCRotateTo:create(7/FPS, 0)
			}
		})



		self:removeEventListener(PopoutEvents.kReBecomeTopPanel, _play)
	end

	if PopoutManager:sharedInstance():getLastPopoutPanel() == self then
		_play()
	else
		self:ad(PopoutEvents.kReBecomeTopPanel, _play)
	end

	
end



function StorePayPanel:dcAfterPayResult( ... )
	if self.payLogic then


		if self.errorTipVisible and self.type_last_choose then
			DcUtil:UserTrack({category = 'new_store', sub_category = 'buy_second', pay_id = self.payLogic.dcAndroidInfo:getUniquePayId(), ali_easy_pay = UserManager:getInstance():getAliSignState(), type_last_choose = self.type_last_choose})
		else
			DcUtil:UserTrack({category = 'new_store', sub_category = 'buy', pay_id = self.payLogic.dcAndroidInfo:getUniquePayId(), ali_easy_pay = UserManager:getInstance():getAliSignState()})
		end
		self.type_last_choose = self.curPayType

	end
end

function StorePayPanel:onNotifyCheckAliQuickPay( ... )
	if self.isDisposed then return end
	self:onTapButton()
end

function StorePayPanel:onTapButton( ... )
	if self.isDisposed then return end

	if self._busy then return end
	self._busy = true

	self:createPayLogic()

	local function _buy(onSuccess, onFail, onCancel)

		if __WIN32 then
			setTimeOut(function ( ... )

				
				if self.mode == self.Mode.kHuaWeiYYB then
					PopoutManager:sharedInstance():remove(self, false)
					self.mode = self.Mode.kNormal
					self:popout()
				end

				if onFail then onFail() end
				if self.AfterFail then
					self.AfterFail()
				end

				if self.mode == self.Mode.kOnlyOnePayType then
					self:_close()
				end

				self:setErrorTipVisible(true)

				self._busy = false
				

 			end, 1)
			return
		end

	

		self.payLogic:storeBuy(self.curPayType, function ( ... )
			if self.isDisposed then return end

			if self.goodsIdInfo:getGoodsType() == GoodsType.kCurrency then
				local user = UserManager:getInstance().user
				local serv = UserService:getInstance().user
				local oldCash = user:getCash()

				local goodsId = self.goodsIdInfo:getGoodsId()
				local productMeta = MetaManager:getInstance():getProductAndroidMeta(goodsId)

				local newCash = oldCash + productMeta.cash;
				user:setCash(newCash)
				serv:setCash(newCash)
				local userExtend = UserManager:getInstance().userExtend
				if type(userExtend) == "table" then userExtend.payUser = true end

				local priceInFen = 0
				priceInFen = productMeta.rmb

				local level = nil
				if GameBoardLogic:getInstance() then
					level = GameBoardLogic:getInstance().level
				end
				GainAndConsumeMgr.getInstance():gainItem(DcFeatureType.kNewStore, ItemType.GOLD, productMeta.cash, self.dcSource or DcSourceType.kStoreBuyGold, level, nil, DcPayType.kRmb, priceInFen, goodsId)
				if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData() end
			end


			if onSuccess then onSuccess() end

			self:_close()		
			if self.AfterSuccess then
				self.AfterSuccess()
			end

			if self.curPayType == Payments.ALIPAY then
				local price = _G.StoreManager:getInstance():getAndroidGoodsPrice(self.goodsIdInfo)
				if PaymentManager.getInstance():checkCanAliQuickPay(price) then 
        			require('zoo.panel.store.AliQuickPushLogic'):tryPopout()
        		end
        	end

			PaymentManager.getInstance():setLastSuccessfulPayment(self.curPayType)

			self._busy = false


			self:dcAfterPayResult()
		end, function ( ... )
			if self.isDisposed then return end

			if self.mode == self.Mode.kHuaWeiYYB then
				PopoutManager:sharedInstance():remove(self, false)
				self.mode = self.Mode.kNormal
				self:popout()
			end


			if onFail then onFail() end
			if self.AfterFail then
				self.AfterFail(...)
			end

			if self.mode == self.Mode.kOnlyOnePayType then
				self:_close()
			end



			self:dcAfterPayResult()

			self:setErrorTipVisible(true)

			self._busy = false



		end, function ( ... )
			if self.isDisposed then return end


			if self.mode == self.Mode.kHuaWeiYYB then
				PopoutManager:sharedInstance():remove(self, false)
				self.mode = self.Mode.kNormal
				self:popout()
			end

			if onCancel then onCancel() end

			if self.mode == self.Mode.kOnlyOnePayType then
				self:_close()

				if self.AfterCancel then
					self.AfterCancel()
				end

				CommonTip:showTip(localize('buy.gold.panel.err.undefined'))
			end

			self:setErrorTipVisible(true)

			self:dcAfterPayResult()

			self._busy = false

		end)
	end

	if self.curPayType == Payments.ALIPAY then
			-- nothing
		local price = _G.StoreManager:getInstance():getAndroidGoodsPrice(self.goodsIdInfo)
		if PaymentManager.getInstance():checkCanAliQuickPay(price) then 
			if UserManager.getInstance():isAliSigned() then
				local function onConfirm()
					_buy()
				end
				-- local AliQuickPayConfirmPanel = require "zoo.panel.alipay.AliQuickPayConfirmPanel"
				-- local cp = AliQuickPayConfirmPanel:create(self.data.cash, self.data.iapPrice)
				-- cp:popout(onConfirm)
				onConfirm()
				return
			else
				if _G.use_ali_quick_pay then
					if PaymentBase:getPayment(Payments.ALI_SIGN_PAY):isEnabled() then
						local function localSuccess()
							if self.isDisposed then return end
							self:afterAliSignSuccess()
						end
						local function localFail(errCode, errMsg, noTip)
							if self.isDisposed then return end
							self:afterAliSignFail()
						end
						_buy(localSuccess, localFail, localFail)
						return
					else
						local function onSignSuccess()
							if self.isDisposed then return end
							self:afterAliSignSuccess()
							_buy()
						end
						local function onSignFail()
							if self.isDisposed then return end
							self:afterAliSignFail()
							self._busy = false
						end
			            local function onSignCallback(ret, data)
			                if self.isDisposed then return end
			                if ret == AlipaySignRet.Success then
			                    if self.isDisposed then return end
			                    onSignSuccess()
		                    elseif ret == AlipaySignRet.Cancel then
		                    	onSignFail()
	                    	elseif ret == AlipaySignRet.Fail then
		                    	onSignFail()
			                end
			            end
			            AlipaySignLogic.getInstance():startSign(AliQuickSignEntranceEnum.MARKET_PANEL, onSignCallback)
						return
					end
				end
			end
		end
	elseif self.curPayType == Payments.QQ or self.curPayType == Payments.QQ_WALLET then
		--目前QQ相关平台三方支付用MSDK 直接会调起其中的微信支付 这里是解决微信未登录无回调的问题
		local function enableButton()
    		BuyGoodsLogic:getInstance():reset()

			if self.isDisposed then return end
			self._busy = false
		end
		setTimeOut(enableButton, 5)
	end	

	_buy()
end

function StorePayPanel:afterAliSignSuccess( ... )
	if self.isDisposed then return end
	_G.use_ali_quick_pay = false
	for _, v in ipairs(self.payItems) do
		v:refresh()
	end
end

function StorePayPanel:afterAliSignFail( ... )
	if self.isDisposed then return end
	_G.use_ali_quick_pay = false
	for _, v in ipairs(self.payItems) do
		v:refresh()
	end
end

function StorePayPanel:addPayItem( payItem )
	if self.isDisposed then return end
	-- self.ui:addChild(payItem)

	local offsetX = (self.vboxWidth - payItem:getGroupBounds().size.width) * 0.5
	payItem:setPositionX(offsetX)
	self.vbox:addItem(payItem)

	self:refreshLayout()
end

function StorePayPanel:refreshLayout( ... )
	if self.isDisposed then return end
	local addedHeight = self.vbox.layout:getHeight() - self.vbox.oriHeight
	self.buttonUI:setPositionY(self.buttonUI.oriPosY - addedHeight)
	self.bg:setPreferredSize(CCSizeMake(self.bg.oriSize.width, self.bg.oriSize.height + addedHeight))
	self.bg2:setPreferredSize(CCSizeMake(self.bg2.oriSize.width, self.bg2.oriSize.height + addedHeight))
end

function StorePayPanel:setGoodsIdInfo( goodsIdInfo )
	if self.isDisposed then return end
	self.goodsIdInfo = goodsIdInfo


	local goodsName = Localization:getInstance():getText("goods.name.text"..tostring(self.goodsIdInfo:getGoodsNameId()))
	self:setGoodsName(goodsName)

	local price = _G.StoreManager:getInstance():getAndroidGoodsPrice(self.goodsIdInfo)
	self:setPrice(price)

	self.payItems = {}

	local lastSuccessfulPayType = PaymentManager.getInstance():getLastSuccessfulPayment()
	local payTypes = __ANDROID and PaymentManager.getInstance():getAvailablePayType(self.goodsIdInfo)


	if __WIN32 then
		payTypes = {Payments.ALIPAY, Payments.QQ}
	end


	if self.paymentFilter then
		payTypes = table.filter(payTypes, self.paymentFilter)
	end




	local Common = require 'zoo.payment.repay.Common'
	table.sort(payTypes, function ( a, b )
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
			return true
		elseif b_is_third then
			return false
		else
		end
	end)




	self.curPayType = 0

	for _, payType in ipairs(payTypes) do
		local payItem = PayItem:create(self.goodsIdInfo)
		payItem:setPayType(payType)
		self:addPayItem(payItem)

		if lastSuccessfulPayType == payType then
			payItem:setSelected(true)
			self.curPayType = payType
		end

		table.insert(self.payItems, payItem)

		payItem:ad('onPayItemSelected', function ( evt )
			if self.isDisposed then return end
			self:onPayItemSelected(evt)
		end)

	end

	if self.curPayType == 0 and #payTypes > 0 then
		self.curPayType = payTypes[1]
		self.payItems[1]:setSelected(true)
	end

	self:refreshButton()
	self:refreshLayout()

	if #payTypes <= 0 then
		self.mode = self.Mode.kNoPayType
	elseif #payTypes == 1 then
		self.mode = self.Mode.kOnlyOnePayType
	else
		if PlatformConfig:isPlatform(PlatformNameEnum.kHuaWei) or PlatformConfig:isQQPlatform()  then
			self.mode = self.Mode.kHuaWeiYYB
		else
			self.mode = self.Mode.kNormal
		end
	end

	self:createPayLogic()

	if self.mode ~= self.Mode.kNoPayType then
		self.payLogic.dcAndroidInfo:setInitialTypeList(payTypes)
		PaymentDCUtil.getInstance():sendAndroidRmbPayStart(self.payLogic.dcAndroidInfo)
	end

end

function StorePayPanel:refreshButton( ... )
	if self.isDisposed then return end
	self.button:setEnabled(self.curPayType ~= 0)
end

function StorePayPanel:onPayItemSelected( evt )
	if self.isDisposed then return end

	for _, payItem in ipairs(self.payItems) do
		if payItem ~= evt.target then
			payItem:setSelected(false)
		end
	end

	self.curPayType = evt.target:getPayType()

	self.vbox:refresh()
	self:refreshButton()
	self:refreshLayout()
end



function StorePayPanel:setGoodsName( goodsName )
	if self.isDisposed then return end
	UIHelper:setCenterText(self.ui:getChildByPath('goodsName') , goodsName .. ' x1', 'fnt/register2.fnt')
	self.ui:getChildByPath('goodsName'):setColor(hex2ccc3('7B4C06'))
end

function StorePayPanel:setPrice( price )
	if self.isDisposed then return end
	UIHelper:setCenterText(self.ui:getChildByPath('price') , string.format('%s %.2f', BuyHappyCoinManager:getCurrencySymbol  ('cny'), price), 'fnt/libao4.fnt')
	self.ui:getChildByPath('price'):setColor(hex2ccc3('7B4C06'))
end

function StorePayPanel:_close()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
	self:dcAfterPayResult()

end

function StorePayPanel:popout()

	if self.mode == self.Mode.kOnlyOnePayType then
	    self:setPositionX(self:getPositionX() + 10000)
		PopoutManager:sharedInstance():add(self, false)
		self:onTapButton()

	elseif self.mode == self.Mode.kNoPayType then
		if self.AfterFail then
			self.AfterFail()
		end
		self:dispose()
	elseif self.mode == self.Mode.kHuaWeiYYB then
		self:setPositionX(self:getPositionX() + 10000)
		PopoutManager:sharedInstance():add(self, false)
		self:onTapButton()
	else
		self:scaleAccordingToResolutionConfig()
	    self:setPositionForPopoutManager()
	    self:setPositionX(self:getPositionX() + 0)
		PopoutManager:sharedInstance():add(self, true, nil, nil, nil, 200)
		self.allowBackKeyTap = true
		RealNameManager:addConsumptionLabelToPanel(self, true)
	end
end

function StorePayPanel:onCloseBtnTapped( ... )
	if PaymentManager.getInstance():getIsCheckingPayResult() then return end 

	if self.mode ~= self.Mode.kNoPayType then  
		local payResult = self.payLogic.dcAndroidInfo:getResult()
		local noDC = false 
		if payResult and payResult == AndroidRmbPayResult.kNoNet then  
			self.payLogic.dcAndroidInfo:setResult(AndroidRmbPayResult.kCloseAfterNoNet)
		elseif payResult and payResult == AndroidRmbPayResult.kNoPaymentAvailable then 
			self.payLogic.dcAndroidInfo:setResult(AndroidRmbPayResult.kCloseAfterNoPaymentAvailable)
		elseif payResult and payResult == AndroidRmbPayResult.kNoRealNameAuthed then 
    		self.payLogic.dcAndroidInfo:setResult(AndroidRmbPayResult.kCloseAfterNoRealNameAuthed)
		else
			local typeChoose = self.payLogic.dcAndroidInfo.typeChoose
			if typeChoose then 
				if payResult and payResult == AndroidRmbPayResult.kSuccess then 
					he_log_error("zhijiancheck----11")
					noDC = true
				else
				end
			end
			if not noDC then 
				self.payLogic.dcAndroidInfo:setResult(AndroidRmbPayResult.kCloseDirectly)
			end
		end
		if not noDC then 
			PaymentDCUtil.getInstance():sendAndroidRmbPayEnd(self.payLogic.dcAndroidInfo)
		end
	end

	CommonTip:showTip(localize('buy.gold.panel.err.undefined'))

    self:_close()

    if self.AfterCancel then
    	self.AfterCancel()
    end

end

function StorePayPanel:getDcObj( ... )
	if self.payLogic then
		return self.payLogic.dcAndroidInfo
	end
end


function StorePayPanel:buyGoods( goodsIdInfo, AfterSuccess, AfterFail, AfterCancel, paymentFilter)
	local panel = StorePayPanel:create()
	panel.paymentFilter = paymentFilter
	panel:setGoodsIdInfo(goodsIdInfo)
	panel.AfterSuccess = AfterSuccess
	panel.AfterFail = AfterFail
	panel.AfterCancel = AfterCancel
	panel:popout()
	return panel:getDcObj()
end


return StorePayPanel
