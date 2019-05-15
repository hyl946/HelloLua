local BaseAliPaymentPanel = require("zoo.panel.alipay.BaseAliPaymentPanel")
local AliQuickPayGuide = require("zoo.panel.alipay.AliQuickPayGuide")

local AliPaymentSignVerifyPanel = class(BaseAliPaymentPanel)

function AliPaymentSignVerifyPanel:create(applyID, entrance, popTimes, input_phone, input_account, isValidPhone)
	local panel = AliPaymentSignVerifyPanel.new()
	panel:loadRequiredResource("ui/ali_payment.json")
	panel:init(applyID, entrance, popTimes, input_phone, input_account, isValidPhone)

	return panel
end

function AliPaymentSignVerifyPanel:init(applyID, entrance, popTimes, input_phone, input_account, isValidPhone)
	self.ui = self:buildInterfaceGroup("PanelAliPaymentSignVerify")
    BasePanel.init(self, self.ui)

    self.applyID = applyID
	self.entrance = entrance
	self.popTimes = popTimes

    self.isValidPhone = isValidPhone
    self.input_phone = input_phone
    self.input_account = input_account

	self.txtSMSSend = self.ui:getChildByName("txtSMSSend")
	self.txtSMSSend:setString(localize('accredit.code.text'))

	self.txtVerifying = self.ui:getChildByName('txtVerifying')
	self.txtVerifying:setString('验证中...')
	self.txtVerifying:setVisible(false)

	self.txtSubtitle = self.ui:getChildByName('txtSubtitle')
	self.txtSubtitle:setString(localize('accredit.code.verify'))


    self.errorTipSMS = self.ui:getChildByName("error_tip_sms")

	self.btnClose = self:createTouchButton("btnClose", 
			function()
				if self.cancelCallback then
	    			self.cancelCallback()
	    			if _G.isLocalDevelopMode then printx(0, "AliPaymentSignAccountPanel cancel cancelCallback!!!!!!!!!!!!!!") end
	    		end
	    		self:onCloseBtnTapped()

	    		DcUtil:UserTrack({ category='alipay_mianmi_accredit', sub_category = 'accredit_flow_pop2', result = 0, t1 = self.t1, t2 = self.t2})
			end
		)

    self.btnSave = GroupButtonBase:create(self.ui:getChildByName('btnSave'))
    self.btnSave:setString("获取验证码")
    self.btnSave:ad(DisplayEvents.kTouchTap, 
	    	function()
	    		self:sendSignRequest()
	    	end
    	)
    self.btnSave:setEnabled(false)
    

    self.input_sms = self:initInput("input_sms", "短信验证码", kEditBoxInputModeNumeric, 6, true)

    self.frame_sms = self.ui:getChildByName("frame_sms")
    self.frame_sms:setVisible(false)

    self:addInputSMSListeners()
    self:adaptResolution()

    self.ui:runAction(CCCallFunc:create(
    	function()
    		self.input_sms:openKeyBoard()
    		if _G.isLocalDevelopMode then printx(0, "self.input_sms openKeyBoard") end
    	end
    ))

    if self.entrance ~= AliQuickSignEntranceEnum.VERIFY_PANEL then
    	if self.entrance == AliQuickSignEntranceEnum.BUY_IN_GAME_PANEL then -- 这种情况，提前加了
        	self.dcPopTimes = AliQuickPayGuide.getPopoutTimes()
        else
            self.dcPopTimes = AliQuickPayGuide.getPopoutTimes()+1
        end
    	self:DCEntrance(1, self.dcPopTimes) 
    end

    if 	self.entrance ~= AliQuickSignEntranceEnum.NEW_GAME_SETTINGS_PANEL and
       	self.entrance ~= AliQuickSignEntranceEnum.VERIFY_PANEL 
       	and self.entrance ~= AliQuickSignEntranceEnum.PROMO_PANEL then 
			if AliQuickPayGuide.isGuideTime() then
				AliQuickPayGuide.updateGuideTimeAndPopCount()
			end
    end


    self:resetCountDown()
	self.scheduleScriptFuncID = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function() self:updateCountDown() end, 1, false)
	self:updateCountDown()
	self:registerSMS()
end

function AliPaymentSignVerifyPanel:sendSignRequest()
	local function onRequestSuccess(event)
		if self.isDisposed then return end
		self:resetCountDown()
		self.scheduleScriptFuncID = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function() self:updateCountDown() end, 1, false)
		self:updateCountDown()
		self:registerSMS()
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
		end

	end

	local function onRequestCancel(event)
		if self.isDisposed then return end
	end

	local http = GetAliPaymentSign.new(true)
	http:addEventListener(Events.kComplete, onRequestSuccess)
	http:addEventListener(Events.kError, onRequestFail)
	http:addEventListener(Events.kCancel, onRequestCancel)


	if self.isValidPhone then
		http:syncLoad( self.input_account, self.input_account)
	else
		http:syncLoad( self.input_phone, self.input_account)
	end

end

function AliPaymentSignVerifyPanel:isCountingDown()
	local cd = self.countDown or 0
	if _G.isLocalDevelopMode then printx(0, "countdown : "..tostring(cd)) end
	return cd > 0 and cd < 60
end

function AliPaymentSignVerifyPanel:resetCountDown()
	if self.isDisposed then
		return
	end
	self.countDown = 60
	-- if __WIN32 then
	-- 	self.countDown = 10
	-- end
	if self.scheduleScriptFuncID ~= nil then 
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduleScriptFuncID) 
		self.scheduleScriptFuncID = nil
	end
	self.btnSave:setString(localize("login.panel.button.16"))
	self.btnSave:setEnabled(true)
end

function AliPaymentSignVerifyPanel:updateCountDown()
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

function AliPaymentSignVerifyPanel:onKeyBackClicked(...)
	BasePanel.onKeyBackClicked(self)
	if self.cancelCallback then
		self.cancelCallback()
	end
end

function AliPaymentSignVerifyPanel:setButtonEnabled(enable)
	if self.isDisposed then return end
	self.btnSave:setEnabled(enable)
end

function AliPaymentSignVerifyPanel:setInputPhoneVisible(visible)
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

function AliPaymentSignVerifyPanel:addInputSMSListeners()
	
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

			if self.input_sms:isValidVerifyCode() then
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

function AliPaymentSignVerifyPanel:registerSMS()
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

function AliPaymentSignVerifyPanel:unRegisterSMS()
	if __ANDROID and not PlatformConfig:isCUCCWOPlatform() then
		local mainActivity = luajava.bindClass("com.happyelements.hellolua.MainActivity")
		mainActivity:unRegisterSMSObserver()
	end
end

function AliPaymentSignVerifyPanel:onCloseBtnTapped()
	self:unRegisterSMS()
	BaseAliPaymentPanel.onCloseBtnTapped(self)
end

function AliPaymentSignVerifyPanel:sendVerify()
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
		self.txtVerifying:setVisible(false)

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

		DcUtil:UserTrack({ category='alipay_mianmi_accredit', sub_category = 'accredit_flow_pop2', result = "1_0", t1 = self.t1, t2 = self.t2})
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
		self.txtVerifying:setVisible(false)

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
		
		DcUtil:UserTrack({ category='alipay_mianmi_accredit', sub_category = 'accredit_flow_pop2', result = "1_1_"..tostring(event.data), t1 = self.t1, t2 = self.t2})
	end

	local function onCancel()
		self.isVerifying = false
		if self.isDisposed then return end
		self.txtVerifying:setVisible(false)
		DcUtil:UserTrack({ category='alipay_mianmi_accredit', sub_category = 'accredit_flow_pop2', result = 0, t1 = self.t1, t2 = self.t2})
	end

	if self.isVerifying then
		return
	end

	self.txtVerifying:setVisible(true)
	local http = GetAliPaymentVerify.new(true)
	http:addEventListener(Events.kComplete, onSuccess)
	http:addEventListener(Events.kError, onError)
	http:addEventListener(Events.kCancel, onCancel)
	http:load( self.applyID , self.input_sms:getText())
	self.isVerifying = true
	DcUtil:UserTrack({ category='alipay_mianmi_accredit', sub_category = 'accredit_flow_pop2', result = 1, t1 = self.t1, t2 = self.t2})
end

return AliPaymentSignVerifyPanel