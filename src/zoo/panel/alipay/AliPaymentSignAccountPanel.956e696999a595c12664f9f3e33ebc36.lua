local Button = require "zoo.panel.phone.Button"
local Input = require "zoo.panel.phone.Input"
local BaseAliPaymentPanel = require "zoo.panel.alipay.BaseAliPaymentPanel"
local AliQuickPayGuide = require "zoo.panel.alipay.AliQuickPayGuide"

local AliPaymentSignAccountPanel = class(BaseAliPaymentPanel)

function AliPaymentSignAccountPanel:create(entrance)
	local panel = AliPaymentSignAccountPanel.new()
	panel:loadRequiredResource("ui/ali_payment.json")
	panel:init(entrance)

	return panel
end

function AliPaymentSignAccountPanel:init(entrance)
	self.ui = self:buildInterfaceGroup("PanelAliPaymentSignAccount")
    BasePanel.init(self, self.ui)

    self.entrance = entrance

    self.btnClose = self:createTouchButton("btnClose", 
            function()
                if self.cancelCallback then
                    self.cancelCallback()
                    if _G.isLocalDevelopMode then printx(0, "AliPaymentSignAccountPanel cancel cancelCallback!!!!!!!!!!!!!!") end
                end
                self:onCloseBtnTapped()

                DcUtil:UserTrack({ category='alipay_mianmi_accredit', sub_category = 'accredit_flow_pop1', result = 0, t1 = self.t1, t2 = self.t2})
            end
        )
    
   	local txtAgreement = self.ui:getChildByName("txtAgreement")
   	txtAgreement:setDimensions(CCSizeMake(0,0))

    self.ui:getChildByName("input_title"):setString(localize("accredit.id"))--"请输入您的支付宝账户关联的邮箱或手机")
    txtAgreement:setString(localize("accredit.id.agreement"))-- "点击保存按键，表示我已阅读并同意")

    local btnAgreementLink = self:createTouchButton("linkAgreement", function()
    		PreloadingSceneUI.showAliQuickPayAgreement()
    	end)
    btnAgreementLink:setPositionX(txtAgreement:getPositionX() + txtAgreement:getContentSize().width)

    if _G.isLocalDevelopMode then printx(0, "accredit.id.agreement.link: ", localize("accredit.id.agreement.link")) end

    local txtLink = btnAgreementLink:getChildByName("text")
    txtLink:setString(localize("accredit.id.agreement.link")) --"支付宝协议。")

    self.btnSave = GroupButtonBase:create(self.ui:getChildByName("btnSave"))
    self.btnSave:setString(Localization:getInstance():getText("accredit.id.button.2"))
    self.btnSave:addEventListener(DisplayEvents.kTouchTap, function ()
		self:sendSignRequest()
    end)
    self.btnSave:setEnabled(false)

    self.frame_account = self.ui:getChildByName("frame_account")
    self.frame_account:setVisible(false)
    self.frame_phone = self.ui:getChildByName("frame_phone")
    self.frame_phone:setVisible(false)

    self.input_account = self:initInput("input_account", localize("accredit.id.alipay"),--"支付宝账号", 
    										kEditBoxInputModeSingleLine, 127)
    
    self.input_phone = self:initInput("input_phone", localize("accredit.id.mobile"),--"绑定手机号", 
    									kEditBoxInputModePhoneNumber, 11)
    self:setInputPhoneVisible(false)

    if self.ui:getChildByName('reduceText') then 
        self.reduceIcon = self.ui:getChildByName('reduceIcon')
        self.reduceText = self.ui:getChildByName('reduceText')
        self.reduceIconFen = self.ui:getChildByName('reduceIconFen')
        self.reduceBg = self.ui:getChildByName('reduceBg')
        self.reduceIcon:setVisible(false)
        self.reduceText:setVisible(false)
        self.reduceIconFen:setVisible(false)
        self.reduceBg:setVisible(false)
    end

    self:setReduceShowOption(AliPaymentSignAccountPanel.hideReduce)

    self:addInputPhoneListeners()
    self:addInputAccountListeners()
    self:adaptResolution()

    self.ui:runAction(CCCallFunc:create(
        function()
            self.input_account:openKeyBoard()
        end
    ))

    if self.entrance ~= AliQuickSignEntranceEnum.VERIFY_PANEL then
        if self.entrance == AliQuickSignEntranceEnum.BUY_IN_GAME_PANEL then -- 这种情况，提前加了
        	self.dcPopTimes = AliQuickPayGuide.getPopoutTimes()
        else
            self.dcPopTimes = AliQuickPayGuide.getPopoutTimes()+1
        end
        printx( 3 , ' popTimes ', self.dcPopTimes)
    	self:DCEntrance(1, self.dcPopTimes)
    end




    if 	self.entrance ~= AliQuickSignEntranceEnum.NEW_GAME_SETTINGS_PANEL and
       	self.entrance ~= AliQuickSignEntranceEnum.VERIFY_PANEL
        and self.entrance ~= AliQuickSignEntranceEnum.PROMO_PANEL then
			if AliQuickPayGuide.isGuideTime() then
				AliQuickPayGuide.updateGuideTimeAndPopCount()
			end
    end
end

AliPaymentSignAccountPanel.showOneFen = 1
AliPaymentSignAccountPanel.showNormalReduce = 2
AliPaymentSignAccountPanel.hideReduce = 0

function AliPaymentSignAccountPanel:setReduceShowOption(option)
    if option == AliPaymentSignAccountPanel.showOneFen then
        self.reduceIcon:setVisible(false)
        self.reduceText:setVisible(true)
        self.reduceBg:setVisible(true)
        self.reduceIconFen:setVisible(true)
        self.reduceText:setString(localize('alipay.kf.accredit.1fen'))
    elseif option == AliPaymentSignAccountPanel.showNormalReduce then
        self.reduceIcon:setVisible(true)
        self.reduceText:setVisible(true)
        self.reduceBg:setVisible(false)
        self.reduceIconFen:setVisible(false)
        self.reduceText:setString(localize('alipay.kf.accredit.2.99'))
    elseif option == AliPaymentSignAccountPanel.hideReduce then
        self.reduceIcon:setVisible(false)
        self.reduceText:setVisible(false)
        self.reduceBg:setVisible(false)
        self.reduceIconFen:setVisible(false)
    end
end

function AliPaymentSignAccountPanel:onKeyBackClicked(...)
	BasePanel.onKeyBackClicked(self)
	if self.cancelCallback then
		self.cancelCallback()
	end
end

function AliPaymentSignAccountPanel:setButtonEnabled(enable)
	if self.isDisposed then return end
	self.btnSave:setEnabled(enable)
	-- self.btnCancel:setEnabled(enable)
end

function AliPaymentSignAccountPanel:setInputPhoneVisible(visible)
	self.ui:getChildByName("input_phone_bg"):setVisible(visible)

	--self.ui:getChildByName("clear_icon_phone"):setVisible(visible)
	
	if visible then
		--if not self.input_phone:getParent() then self.ui:addChild(self.input_phone) end
		self.input_phone:setEnabled(true)
		self.input_phone:setVisible(true)
		-- self.input_phone:openKeyBoard()
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

function AliPaymentSignAccountPanel:sendSignRequest()
    local accountType = self.input_account:isValidPhone() and 0 or 1
	local function onRequestSuccess(event)
		if self.isDisposed then return end

        local input_phone, input_account, isValidPhone = self.input_phone:getText(), self.input_account:getText(), self.input_account:isValidPhone()
    	self:onCloseBtnTapped()


    	local AliPaymentSignVerifyPanel = require "zoo.panel.alipay.AliPaymentSignVerifyPanel"
    	if _G.isLocalDevelopMode then printx(0, "applyid: "..tostring(event.data.applyId)) end
    	local panel = AliPaymentSignVerifyPanel:create(event.data.applyId, self.entrance, self.dcPopTimes, input_phone, input_account, isValidPhone)
    	panel:popout(self.cancelCallback, self.signSuccessCallback)
    	DcUtil:UserTrack({ category='alipay_mianmi_accredit', sub_category = 'accredit_flow_pop1', result = "1_0", t1 = self.t1, t2 = self.t2})
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
		elseif tonumber(event.data) == 730245 then
            self.frame_phone:setVisible(true)
            self:setButtonEnabled(true)
        else
			if _G.isLocalDevelopMode then printx(0, "request error:　"..tostring(event.data)) end
            self.frame_account:setVisible(true)
			self:setButtonEnabled(true)
		end

		DcUtil:UserTrack({ category='alipay_mianmi_accredit', sub_category = 'accredit_flow_pop1', result = "1_1_"..tostring(event.data), t1 = self.t1, t2 = self.t2 })
	end

	local function onRequestCancel(event)
		if self.isDisposed then return end
		
		self:setButtonEnabled(true)
		DcUtil:UserTrack({ category='alipay_mianmi_accredit', sub_category = 'accredit_flow_pop1', result = 0, t1 = self.t1, t2 = self.t2})
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

function AliPaymentSignAccountPanel:setErrorTip(errorStr)
	self.ui:getChildByName("error_tip"):setString(errorStr)
end

function AliPaymentSignAccountPanel:isErrorTipEmpty()
	local txt = self.ui:getChildByName("error_tip"):getString()
	return string.isEmpty(txt)
end

function AliPaymentSignAccountPanel:updatePhoneError()
	local text = self.input_phone:getText() or ""
	if not self.input_phone:isValidPhone() then
		if _G.isLocalDevelopMode then printx(0, "phone number invalid!!!!!!!!!!") end
		self:setErrorTip("请输入正确的手机号码！")
        self.frame_phone:setVisible(true)
	else
        self.frame_phone:setVisible(false)
		self:setErrorTip("")
	end
end

function AliPaymentSignAccountPanel:addInputPhoneListeners()
	
	local function onTextBegin()
		if _G.isLocalDevelopMode then printx(0, "onTextBegin!!!!!!!!!!!!!!!") end
		self:setErrorTip("")
	end

	local function onTextEnd()
		if self.input_phone then
			self:updatePhoneError()
		end
	end

	local function onTextChanged()
		if self.input_phone then
            if self.input_phone:isValidPhone() then
                self.frame_phone:setVisible(false)
                self.btnSave:setEnabled(true)
            end
		end
	end

	self.input_phone:ad(kTextInputEvents.kBegan, onTextBegin)
	if __WIN32 then
		self.input_phone:ad(kTextInputEvents.kEnded, onTextEnd)
	else
		self.input_phone:ad(kTextInputEvents.kLostFocus, onTextEnd)
	end
	self.input_phone:ad(kTextInputEvents.kChanged, onTextChanged)
end

function AliPaymentSignAccountPanel:addInputAccountListeners()
	
	local function onTextBegin()
		if _G.isLocalDevelopMode then printx(0, "onTextBegin!!!!!!!!!!!!!!!") end
		self:setErrorTip("")
	end

	local function onTextEnd()
		if self.input_account then
			local text = self.input_account:getText() or ""
			if self.input_account:isValidEmail() then
				self:setErrorTip("")
                self.frame_account:setVisible(false)
			elseif self.input_account:isValidPhone() then
				self:setErrorTip("")
                self.frame_account:setVisible(false)
			else
				if _G.isLocalDevelopMode then printx(0, "invalid ali_payment account: "..text) end
				if not string.isEmpty(text) then
                    self.frame_account:setVisible(true)
					self:setErrorTip("请输入正确的支付宝账户！")
				else
                    self.frame_account:setVisible(false)
					self:setErrorTip("")
				end
			end
		end
	end

	local function onTextChanged()
		if self.input_account then
			local text = self.input_account:getText() or ""
			if self.input_account:isValidEmail() then
				self:setInputPhoneVisible(true)
				self.btnSave:setEnabled(self.input_phone:isValidPhone())
			elseif self.input_account:isValidPhone() then
				self.btnSave:setEnabled(true)
				self:setInputPhoneVisible(false)
			else
				self.btnSave:setEnabled(false)
				self:setInputPhoneVisible(false)
			end
		end
	end

	self.input_account:ad(kTextInputEvents.kBegan, onTextBegin)
	if __WIN32 then
		self.input_account:ad(kTextInputEvents.kEnded, onTextEnd)
	else
		self.input_account:ad(kTextInputEvents.kLostFocus, onTextEnd)
	end
	self.input_account:ad(kTextInputEvents.kChanged, onTextChanged)
end

return AliPaymentSignAccountPanel


