local BaseAliPaymentPanel = require("zoo.panel.alipay.BaseAliPaymentPanel")
local AliQuickPayGuide = require("zoo.panel.alipay.AliQuickPayGuide")

local NewAliPaymentSignPanel = class(BaseAliPaymentPanel)

function NewAliPaymentSignPanel:create(entrance)
	local panel = NewAliPaymentSignPanel.new()
	panel:loadRequiredResource("ui/ali_payment.json")
	panel:init(entrance)

	return panel
end

function NewAliPaymentSignPanel:init(entrance)
	self.ui = self:buildInterfaceGroup("PanelAliPaymentSignNew")
    BasePanel.init(self, self.ui)

    self.entrance = entrance
    
   	local txtAgreement = self.ui:getChildByName("txtAgreement")
   	txtAgreement:setDimensions(CCSizeMake(0,0))

    self.ui:getChildByName("input_title"):setString(localize("accredit.id"))--"请输入您的支付宝账户关联的邮箱或手机")
    txtAgreement:setString(localize("accredit.id.agreement"))-- "点击保存按键，表示我已阅读并同意")

	self.txtSMSSend = self.ui:getChildByName("txtSMSSend")

    local btnAgreementLink = self:createTouchButton("linkAgreement", function()
    		PreloadingSceneUI.showAliQuickPayAgreement()
    	end)
    btnAgreementLink:setPositionX(txtAgreement:getPositionX() + txtAgreement:getContentSize().width)

    self.errorTipSMS = self.ui:getChildByName("error_tip_sms")
    self.errorTipAccount = self.ui:getChildByName("error_tip_account")
    self.errorTipAccountPosY = self.errorTipAccount:getPositionY()

    local txtLink = btnAgreementLink:getChildByName("text")
    txtLink:setString(localize("accredit.id.agreement.link")) --"支付宝协议。")

	self.btnClose = self:createTouchButton("btnClose", 
			function()
				if self.cancelCallback then
	    			self.cancelCallback()
	    			if _G.isLocalDevelopMode then printx(0, "AliPaymentSignAccountPanel cancel cancelCallback!!!!!!!!!!!!!!") end
	    		end
	    		self:onCloseBtnTapped()

	    		if self.accountValidated then
	    			DcUtil:UserTrack({ category='alipay_mianmi_accredit', sub_category = 'accredit_flow_pop2', result = 0})
	    		else
	    			DcUtil:UserTrack({ category='alipay_mianmi_accredit', sub_category = 'accredit_flow_pop1', result = 0})
	    		end
			end
		)

    self.btnSave = GroupButtonBase:create(self.ui:getChildByName('btnSave'))
    self.btnSave:setString("获取验证码")
    self.btnSave:ad(DisplayEvents.kTouchTap, 
	    	function()
	    		self:onBtnSaveTapped()
	    	end
    	)
    self.btnSave:setEnabled(false)
    
    self.input_account = self:initInput("input_account", localize("accredit.id.alipay"),--"支付宝账号", 
    										kEditBoxInputModeSingleLine, 127)

    self.input_phone = self:initInput("input_phone", localize("accredit.id.mobile"),--"绑定手机号", 
    									kEditBoxInputModePhoneNumber, 11)

    self.input_sms = self:initInput("input_sms", "短信验证码", kEditBoxInputModeNumeric, 6, true)

    self.frame_account = self.ui:getChildByName("frame_account")
    self.frame_account:setVisible(false)
    self.frame_phone = self.ui:getChildByName("frame_phone")
    self.frame_phone:setVisible(false)
    self.frame_sms = self.ui:getChildByName("frame_sms")
    self.frame_sms:setVisible(false)

    self:setInputPhoneVisible(false)

    self:addInputPhoneListeners()
    self:addInputAccountListeners()
    self:addInputSMSListeners()
    self:adaptResolution()

    self.ui:runAction(CCCallFunc:create(
    	function()
    		self.input_account:openKeyBoard()
    		if _G.isLocalDevelopMode then printx(0, "self.input_account openKeyBoard") end
    	end
    ))

    if self.entrance ~= AliQuickSignEntranceEnum.VERIFY_PANEL then
    	self.dcPopTimes = AliQuickPayGuide.getPopoutTimes()+1
    	self:DCEntrance(1, self.dcPopTimes)
    end

    if 	self.entrance ~= AliQuickSignEntranceEnum.NEW_GAME_SETTINGS_PANEL and
       	self.entrance ~= AliQuickSignEntranceEnum.VERIFY_PANEL then
			if AliQuickPayGuide.isGuideTime() then
				AliQuickPayGuide.updateGuideTimeAndPopCount()
			end
    end
end

function NewAliPaymentSignPanel:isCountingDown()
	local cd = self.countDown or 0
	if _G.isLocalDevelopMode then printx(0, "countdown : "..tostring(cd)) end
	return cd > 0 and cd < 60
end

function NewAliPaymentSignPanel:resetCountDown()
	if self.isDisposed then
		return
	end
	self.countDown = 60
	if self.scheduleScriptFuncID ~= nil then 
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduleScriptFuncID) 
		self.scheduleScriptFuncID = nil
	end
	self.btnSave:setString(localize("login.panel.button.16"))
	self.btnSave:setEnabled(true)
end

function NewAliPaymentSignPanel:updateCountDown()
	if self.isDisposed then
		return
	end
	if _G.inBackgroundElapsedSeconds>0 then
		self.countDown = self.countDown - _G.inBackgroundElapsedSeconds
		_G.inBackgroundElapsedSeconds = 0
	end
	if self.countDown >= 0 then
		self.btnSave:setString(localize("login.panel.button.17", {num = string.format("%02d", self.countDown)}))
		self.btnSave:setEnabled(false)
		self.countDown = self.countDown - 1
	else
		self:resetCountDown()
	end
end

function NewAliPaymentSignPanel:onBtnSaveTapped()

	local function onSuccess()
		self.input_sms:openKeyBoard()
		self.txtSMSSend:setString(localize("accredit.code.text"))
		self.frame_account:setVisible(false)
		self.frame_phone:setVisible(false)

		self:resetCountDown()
		self.scheduleScriptFuncID = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function() self:updateCountDown() end, 1, false)
		self:updateCountDown()
		self:registerSMS()
		self.accountValidated = true
	end

	local function onFailed(errCode)
		if errCode == 730245 then
			self.frame_phone:setVisible(true)
		--elseif errCode == 730244 then
		else
			self.frame_account:setVisible(true)
		end
		self.accountValidated = false
	end

	local function onCanceled()
		self.accountValidated = false
	end

	self:sendSignRequest(onSuccess, onFailed, onCanceled)
end

function NewAliPaymentSignPanel:onKeyBackClicked(...)
	BasePanel.onKeyBackClicked(self)
	if self.cancelCallback then
		self.cancelCallback()
	end
end

function NewAliPaymentSignPanel:setButtonEnabled(enable)
	if self.isDisposed then return end
	self.btnSave:setEnabled(enable)
end

function NewAliPaymentSignPanel:setInputPhoneVisible(visible)
	self.ui:getChildByName("input_phone_bg"):setVisible(visible)

	--self.ui:getChildByName("clear_icon_phone"):setVisible(visible)
	
	if visible then
		--if not self.input_phone:getParent() then self.ui:addChild(self.input_phone) end
		self.input_phone:setEnabled(true)
		self.input_phone:setVisible(true)
		self.input_phone.placeHolderLabel:setVisible(string.isEmpty(self.input_phone:getText()))
	else
		self.input_phone:setText("")
		self.input_phone:setEnabled(false)
		--self.input_phone:removeFromParentAndCleanup(false)
		self.input_phone:setVisible(false)
		self.input_phone.placeHolderLabel:setVisible(false)
		self.frame_phone:setVisible(false)
	end
end

function NewAliPaymentSignPanel:sendSignRequest(successCallback, failedCallback, cancelCallback)
	--1: 账号注册
	--0：手机号注册
	local accountType = self.input_account:isValidPhone() and 0 or 1
	if _G.isLocalDevelopMode then printx(0, "accountType: "..tostring(accountType)) end
	local function onRequestSuccess(event)
		if self.isDisposed then return end

		self.applyID = event.data.applyId
		if successCallback then successCallback() end
    	DcUtil:UserTrack({ category='alipay_mianmi_accredit', sub_category = 'accredit_flow_pop1', result = "1_0", t1 = accountType})
	end

	local function onRequestFail(event)
		if self.isDisposed then return end

		local errMessage = AliQuickPayGuide.getErrorMessage(event.data, "ali.quick.pay.sign.error")
		CommonTip:showTip(errMessage, "negative", nil, 3)

		if tonumber(event.data) == 730242 then --已经签过约

			UserManager.getInstance().userExtend.aliIngameState = 1
			UserService.getInstance().userExtend.aliIngameState = 1
			if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
			else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end

			self:onCloseBtnTapped()

			--按照签约成功来处理
			if self.signSuccessCallback then
				self.signSuccessCallback()
			end
		else
			if _G.isLocalDevelopMode then printx(0, "request error:　"..tostring(event.data)) end
			self:setButtonEnabled(true)
			if failedCallback then failedCallback(event.data) end
		end

		DcUtil:UserTrack({ category='alipay_mianmi_accredit', sub_category = 'accredit_flow_pop1', result = "1_1_"..tostring(event.data), t1 = accountType})
	end

	local function onRequestCancel(event)
		if self.isDisposed then return end

		if cancelCallback then cancelCallback() end
		self:setButtonEnabled(true)
		DcUtil:UserTrack({ category='alipay_mianmi_accredit', sub_category = 'accredit_flow_pop1', result = 0, t1 = accountType})
	end

	local http = GetAliPaymentSign.new(true)
	http:addEventListener(Events.kComplete, onRequestSuccess)
	http:addEventListener(Events.kError, onRequestFail)
	http:addEventListener(Events.kCancel, onRequestCancel)

	local function doSend()
		if self.input_account:isValidPhone() then
			http:syncLoad( self.input_account:getText(), self.input_account:getText())
			--onRequestFail({data = 730242})
		else
			http:syncLoad( self.input_phone:getText(), self.input_account:getText())
		end
	end

	RequireNetworkAlert:callFuncWithLogged(function()
						doSend()
					end, 
					function() 
						self:setButtonEnabled(true)
					end, 
					kRequireNetworkAlertAnimation.kDefault)

	self:setButtonEnabled(false)
end

function NewAliPaymentSignPanel:setErrorTip(errorStr, isAccountError)
	self.errorTipAccount:setString(errorStr)
	local posY = isAccountError and self.errorTipAccountPosY + 80 or self.errorTipAccountPosY
	self.errorTipAccount:setPositionY(posY)
end

function NewAliPaymentSignPanel:isErrorTipEmpty()
	local txt = self.errorTipAccount:getString()
	return string.isEmpty(txt)
end

function NewAliPaymentSignPanel:updatePhoneError()
	local text = self.input_phone:getText() or ""
	if not self.input_phone:isValidPhone() then
		if _G.isLocalDevelopMode then printx(0, "phone number invalid!!!!!!!!!!") end
		self:setErrorTip("请输入正确的手机号码！", false)
	else
		self:setErrorTip("")
	end
end

function NewAliPaymentSignPanel:addInputPhoneListeners()
	
	local function onTextBegin()
		if _G.isLocalDevelopMode then printx(0, "onTextBegin!!!!!!!!!!!!!!!") end
		self:setErrorTip("")
		self.frame_phone:setVisible(false)
	end

	local function onTextEnd()
		if self.input_phone then
			self:updatePhoneError()
			self.txtSMSSend:setString("")
		end
	end

	local function onTextChanged()
		if self.input_phone then
			self.accountValidated = false
			local text = self.input_phone:getText() or ""
			if not self.input_phone:isValidPhone() then
				if _G.isLocalDevelopMode then printx(0, "phone number invalid!!!!!!!!!!") end
				self.btnSave:setEnabled(false)
			else
				self.btnSave:setEnabled(not self:isCountingDown())
			end
		end
	end

	self.input_phone:ad(kTextInputEvents.kGotFocus, onTextBegin)
	if __WIN32 then
		self.input_phone:ad(kTextInputEvents.kEnded, onTextEnd)
	else
		self.input_phone:ad(kTextInputEvents.kLostFocus, onTextEnd)
	end
	self.input_phone:ad(kTextInputEvents.kChanged, onTextChanged)
end

function NewAliPaymentSignPanel:addInputAccountListeners()
	
	local function onTextBegin()
		if _G.isLocalDevelopMode then printx(0, "onTextBegin!!!!!!!!!!!!!!!") end
		self:setErrorTip("")
		self.frame_account:setVisible(false)
	end

	local function onTextEnd()
		if self.input_account then
			local text = self.input_account:getText() or ""
			if self.input_account:isValidEmail() then
				self:setErrorTip("")
			elseif self.input_account:isValidPhone() then
				self:setErrorTip("")
			else
				if _G.isLocalDevelopMode then printx(0, "invalid ali_payment account: "..text) end
				if not string.isEmpty(text) then
					self:setErrorTip("请输入正确的支付宝账户！", true)
				else
					self:setErrorTip("")
				end
			end

			if self.ui:getChildByName("input_phone_bg"):isVisible() and self:isErrorTipEmpty() then
				self:updatePhoneError()
			end
			self.txtSMSSend:setString("")
		end
	end

	local function onTextChanged()
		if self.input_account then
			self.accountValidated = false
			local text = self.input_account:getText() or ""
			if self.input_account:isValidEmail() then
				self:setInputPhoneVisible(true)
				self.btnSave:setEnabled(self.input_phone:isValidPhone() and not self:isCountingDown())
			elseif self.input_account:isValidPhone() then
				self.btnSave:setEnabled(not self:isCountingDown())
				self:setInputPhoneVisible(false)
			else
				self.btnSave:setEnabled(false)
				self:setInputPhoneVisible(false)
			end
		end
	end

	self.input_account:ad(kTextInputEvents.kGotFocus, onTextBegin)
	if __WIN32 then
		self.input_account:ad(kTextInputEvents.kEnded, onTextEnd)
	else
		self.input_account:ad(kTextInputEvents.kLostFocus, onTextEnd)
	end
	self.input_account:ad(kTextInputEvents.kChanged, onTextChanged)
end

function NewAliPaymentSignPanel:addInputSMSListeners()
	
	local function onTextBegin()
		if _G.isLocalDevelopMode then printx(0, "onTextBegin!!!!!!!!!!!!!!!") end
		self.frame_sms:setVisible(false)
		self.errorTipSMS:setString("")
	end

	local function onTextEnd()
		if self.input_sms then
			local text = self.input_sms:getText() or ""
			if _G.isLocalDevelopMode then printx(0, "!!!!!!!!!!inputtext: ", text, ",result:", self.input_sms:isValidVerifyCode()) end
		end
	end

	local function onTextChanged()
		if self.input_sms then
			local text = self.input_sms:getText() or ""
			he_log_info("sms text changed: "..tostring(text))

			if self.input_sms:isValidVerifyCode() and self.accountValidated then
				--self.input_sms:closeKeyBoard()
				he_log_info("sms text before sent verify!!!!!!!!")
				self.input_sms:closeKeyBoard()
				self:sendVerify()
				he_log_info("sms text end sent verify!!!!!!!!")
			else
				he_log_info("sms text invalid!!!!!!!!")
			end
		end
	end

	self.input_sms:ad(kTextInputEvents.kGotFocus, onTextBegin)
	if __WIN32 then
		self.input_sms:ad(kTextInputEvents.kEnded, onTextEnd)
	else
		self.input_sms:ad(kTextInputEvents.kLostFocus, onTextEnd)
	end
	self.input_sms:ad(kTextInputEvents.kChanged, onTextChanged)
end

function NewAliPaymentSignPanel:registerSMS()
	if __ANDROID and not PlatformConfig:isCUCCWOPlatform() then

		local mainActivity = luajava.bindClass("com.happyelements.hellolua.MainActivity")

		local function onSuccess(result)
			mainActivity:unRegisterSMSObserver()
			if _G.isLocalDevelopMode then printx(0, "sms coming in lua: "..tostring(result)) end
			local startIndex, endIndex = string.find(result, "输入校验码")
			if _G.isLocalDevelopMode then printx(0, "sms coming in lua, startIndex: "..tostring(startIndex)) end
			if startIndex then
				local smsCode = string.sub(result, endIndex+1, endIndex+6)
				if self.input_sms then
					self.input_sms:setText(smsCode)
					self:sendVerify()
				end
			end
	    end

	    local callback = luajava.createProxy("com.happyelements.android.InvokeCallback", {
	        onSuccess = onSuccess,
	        onError = nil,
	        onCancel = nil
	    })

	  	mainActivity:registerSMSObserver(callback)
	end
end

function NewAliPaymentSignPanel:unRegisterSMS()
	if __ANDROID and not PlatformConfig:isCUCCWOPlatform() then
		local mainActivity = luajava.bindClass("com.happyelements.hellolua.MainActivity")
		mainActivity:unRegisterSMSObserver()
	end
end

function NewAliPaymentSignPanel:onCloseBtnTapped()
	self:unRegisterSMS()
	BaseAliPaymentPanel.onCloseBtnTapped(self)
end

function NewAliPaymentSignPanel:sendVerify()
	--todo: send the verify request:
	local function doSuccess()
		UserManager.getInstance().userExtend.aliIngameState = 1
		UserService.getInstance().userExtend.aliIngameState = 1
		if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
		else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end

		AliQuickPayGuide.clearGuides()

		if self.signSuccessCallback then
			self.signSuccessCallback()
		end
	end

	local function onSuccess(event)
		self.isVerifying = false
		if self.isDisposed then return end

		doSuccess()

		self.ui:runAction(CCCallFunc:create(
			function()
				local resultPanel = require("zoo.panel.alipay.PanelSignResult"):create(true)
				resultPanel:popout(
					function() 
						self:onCloseBtnTapped()
					end
				)
			end
			))

		DcUtil:UserTrack({ category='alipay_mianmi_accredit', sub_category = 'accredit_flow_pop2', result = "1_0"})
	end

	local function doError(errorCode)

		local errMessage = AliQuickPayGuide.getErrorMessage(errorCode, "ali.quick.pay.verify.error")
		self.ui:getChildByName("error_tip_sms"):setString(errMessage)

		if AliQuickPayGuide.isNetworkError(errorCode) then
			self.frame_sms:setVisible(false)
			self.input_sms:setText("")
			CommonTip:showTip(errMessage, "negative", nil, 3)
		else
			self.frame_sms:setVisible(true)
			self.ui:runAction(CCCallFunc:create(
				function()
					local resultPanel = require("zoo.panel.alipay.PanelSignResult"):create(false)
					resultPanel:popout(
						function()
							if errorCode == 730250 then --验证码过期
								self:resetCountDown()
							end
						end)
				end
			))
		end

	end

	local function onError(event)
		self.isVerifying = false
		if self.isDisposed then return end

		if tonumber(event.data) == 730242 then
			local errMessage = AliQuickPayGuide.getErrorMessage(tonumber(event.data), "ali.quick.pay.verify.error")
			CommonTip:showTip(errMessage, "negative", 
				function()
					doSuccess()
					self:onCloseBtnTapped()
				end, 3)
		else
			doError(tonumber(event.data))
		end
		
		DcUtil:UserTrack({ category='alipay_mianmi_accredit', sub_category = 'accredit_flow_pop2', result = "1_1_"..tostring(event.data)})
	end

	local function onCancel()
		self.isVerifying = false
		if self.isDisposed then return end
		DcUtil:UserTrack({ category='alipay_mianmi_accredit', sub_category = 'accredit_flow_pop2', result = 0})
	end

	if self.isVerifying then
		return
	end

	local http = GetAliPaymentVerify.new(true)
	http:addEventListener(Events.kComplete, onSuccess)
	http:addEventListener(Events.kError, onError)
	http:addEventListener(Events.kCancel, onCancel)
	http:load( self.applyID , self.input_sms:getText())
	self.isVerifying = true
end

return NewAliPaymentSignPanel