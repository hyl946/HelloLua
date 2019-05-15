local Button = require "zoo.panel.phone.Button"

local AliUnsignConfirmPanel = class(BasePanel)

function AliUnsignConfirmPanel:create()
	local panel = AliUnsignConfirmPanel.new()
	panel:loadRequiredResource("ui/ali_payment.json")
	panel:init()

	return panel
end

function AliUnsignConfirmPanel:init()
	self.ui = self:buildInterfaceGroup("AliUnSignPanel")
    BasePanel.init(self, self.ui)

    self:initButtons()
    self:initCloseButton()
    self:initText()
end

function AliUnsignConfirmPanel:initButtons()
    self.btnConfirm = GroupButtonBase:create(self.ui:getChildByName("btnConfirm"))
    self.btnConfirm:setString(Localization:getInstance():getText("accredit.unwind.button.2"))
    self.btnConfirm:setColorMode(kGroupButtonColorMode.orange)
    self.btnConfirm:addEventListener(DisplayEvents.kTouchTap, function ()
		self:sendUnSignRequest()
		DcUtil:UserTrack({category='new_store', sub_category='easy_pay_cancel', type = 1})
    end)

    self.btnCancel = GroupButtonBase:create(self.ui:getChildByName("btnCancel"))
    self.btnCancel:setString(Localization:getInstance():getText("accredit.unwind.button.1"))
    self.btnCancel:addEventListener(DisplayEvents.kTouchTap, function ()
	    self:onCloseBtnTapped()
		DcUtil:UserTrack({ category='alipay_mianmi_accredit', sub_category = 'accredit_cancel_set_pop_click', result = "2"})
		DcUtil:UserTrack({category='new_store', sub_category='easy_pay_cancel', type = 2})
    end)

    self.panelTitle = TextField:createWithUIAdjustment(self.ui:getChildByName("panelTitleSize"), self.ui:getChildByName("panelTitle"))
    self.ui:addChild(self.panelTitle)
    self.panelTitle:setString(Localization:getInstance():getText("accredit.unwind.title"))-- "解约支付宝快付 "
end

function AliUnsignConfirmPanel:initCloseButton()
	self.closeBtn = self.ui:getChildByName("btnClose")
    self.closeBtn:setTouchEnabled(true, 0, true)
    self.closeBtn:setButtonMode(true)
    self.closeBtn:addEventListener(DisplayEvents.kTouchTap, 
        function() 
            self:onCloseBtnTapped()
			DcUtil:UserTrack({category='new_store', sub_category='easy_pay_cancel', type = 2})
            DcUtil:UserTrack({ category='alipay_mianmi_accredit', sub_category = 'accredit_cancel_set_pop_click', result = "2"})
            if _G.isLocalDevelopMode then printx(0, "btnclose tapped!!!!!!!!!!") end
        end)
end

function AliUnsignConfirmPanel:onKeyBackClicked(...)
	DcUtil:UserTrack({category='new_store', sub_category='easy_pay_cancel', type = 2})
	DcUtil:UserTrack({ category='alipay_mianmi_accredit', sub_category = 'accredit_cancel_set_pop_click', result = "2"})
	BasePanel.onKeyBackClicked(self)
end

function AliUnsignConfirmPanel:initText()
    self.ui:getChildByName("tip1"):setString(localize("accredit.unwind.text.1"))-- "确定要解除支付宝快付的授权吗？")
    self.ui:getChildByName("tip2"):setString(localize("accredit.unwind.text.2")) -- "支付宝快付为您提供的是一种快捷的支付方式。")
    self.ui:getChildByName("tip3"):setString(localize("accredit.unwind.text.3")) -- "1.安全保障，仅限小额支付。")
    self.ui:getChildByName("tip4"):setString(localize("accredit.unwind.text.4")) -- "2.此操作仅授权给开心消消乐。")
end

function AliUnsignConfirmPanel:sendUnSignRequest()
	if self.isRequesting then
		return
	end

	local function onSuccess(event)
		self.isRequesting = false
		if self.successCallback then
			self.successCallback()
		end

		UserManager.getInstance().userExtend.aliIngameState = 2
		UserService.getInstance().userExtend.aliIngameState = 2
		if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
		else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end

		CommonTip:showTip(localize("accredit.unwind.result.1").."\n"..localize("accredit.unwind.result.1.1"), --"解除成功!在设置中可以重新开启支付宝快付噢！", 
												"positive", nil, 3)
		self:onCloseBtnTapped()
		DcUtil:UserTrack({ category='alipay_mianmi_accredit', sub_category = 'accredit_cancel_set_pop_click', result = "0"})

    	require('zoo.panel.store.AliQuickPushLogic'):reset()
	end

	local function onError(event)
		self.isRequesting = false
		CommonTip:showTip(localize("accredit.unwind.result.2")..'\n'..localize("accredit.unwind.result.2.1"), "negative", nil, 3)
		self:onCloseBtnTapped()
		DcUtil:UserTrack({ category='alipay_mianmi_accredit', sub_category = 'accredit_cancel_set_pop_click', result = "1_"..tostring(event.data)})
	end

	local function onCancel()
		self.isRequesting = false
		self:onCloseBtnTapped()
		DcUtil:UserTrack({ category='alipay_mianmi_accredit', sub_category = 'accredit_cancel_set_pop_click', result = "2"})
	end

	local http = GetAliPaymentUnsign.new(true)
	http:addEventListener(Events.kComplete, onSuccess)
	http:addEventListener(Events.kError, onError)
	http:addEventListener(Events.kCancel, onCancel)
	
	local function doSend()
		http:syncLoad()
	end

	RequireNetworkAlert:callFuncWithLogged(function()
						doSend()
					end, 
					function() 
						self.isRequesting = false
						self:onCloseBtnTapped()
					end, 
					kRequireNetworkAlertAnimation.kDefault)

	self.isRequesting = true
	if _G.isLocalDevelopMode then printx(0, "to send the unsign panel!!!!!!!!!!!!!!!!!") end
end

function AliUnsignConfirmPanel:popout(successCallback)
	self:setPositionForPopoutManager()

	self.allowBackKeyTap = true
	self.successCallback = successCallback
	PopoutManager:sharedInstance():add(self, true, false)
end

function AliUnsignConfirmPanel:popoutShowTransition()
	self.allowBackKeyTap = true
end

function AliUnsignConfirmPanel:onCloseBtnTapped()
	PopoutManager:sharedInstance():remove(self, true)
end

return AliUnsignConfirmPanel