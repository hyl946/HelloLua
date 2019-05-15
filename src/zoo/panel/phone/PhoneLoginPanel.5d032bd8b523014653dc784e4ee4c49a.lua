require "zoo.panel.phone.SendCodeConfirmPanel"
require "zoo.panel.phone.VerifyPhoneConfirmPanel"
require "zoo.panel.phone.PhoneConfirmPanel"
require "zoo.net.HttpsClient"
require "zoo.panel.phone.PhoneLoginDropDownPanel"

local Input = require "zoo.panel.phone.Input"
local Title = require "zoo.panel.phone.Title"
local Button = require "zoo.panel.phone.Button"

PhoneLoginPanel = class(BasePanel)

function PhoneLoginPanel:create(phoneLoginInfo, source)
	local panel = PhoneLoginPanel.new()
	panel:loadRequiredResource("ui/login.json")	
	panel:init(phoneLoginInfo, source)
	return panel
end

function PhoneLoginPanel:init(phoneLoginInfo, source)
	self.phoneLoginInfo = phoneLoginInfo
	self.ui = self:buildInterfaceGroup("NewPhoneLoginPanel")
	self.source = source
	BasePanel.init(self, self.ui)

	local title = Title:create(self.ui:getChildByName("title"),self.phoneLoginInfo:isInLoading())
	title:setTextMode(self.phoneLoginInfo.mode)
	title:setCreateBackConfirmPanelFunc(function( backCallback )
		local panel = PhoneConfirmPanel:create(Localization:getInstance():getText("login.alert.content.7"))
		panel:setLeftButtonText(Localization:getInstance():getText("login.panel.button.12"))
		panel:setLeftButtonCallback(backCallback)
		panel:setRightButtonText(Localization:getInstance():getText("login.panel.button.22"))
		panel:setRightButtonCallback(function( ... )
			if string.len(self.phoneInput:getText()) < 11 then
				self.phoneInput:openKeyBoard()
			end
		end)
		return panel
	end)			
	title:addEventListener(Title.Events.kBackTap,function( ... )
		self:remove()
	end)

	local closeBtn = self.ui:getChildByName("closeBtn")
	closeBtn:setTouchEnabled(self.phoneLoginInfo:isInGame())
	closeBtn:setButtonMode(self.phoneLoginInfo:isInGame())
	closeBtn:setVisible(self.phoneLoginInfo:isInGame())
	closeBtn:addEventListener(DisplayEvents.kTouchTap,function( ... )
		self:remove()
	end)

	self.dropDownPos = self.ui:getChildByName("dropDownPos")
	self.dropDownPos:setVisible(false)
	self.dropDownButton = self.ui:getChildByName("dropDownButton")
	self.phone = self.ui:getChildByName("phone")

	local phoneList = Localhost:readCachePhoneListData()
	if #phoneList == 0 then
		self.dropDownButton:setVisible(false)
		self.phone:setDimensions(CCSizeMake(
			self.phone:getDimensions().width + 50,
			self.phone:getDimensions().height	
		))
	else
		self.dropDownButton:setTouchEnabled(true)
		self.dropDownButtonArrow = self.dropDownButton:getChildByName("arrow")

		self.dropDownButtonArrow:setRotation(180)
		self.dropDownButton:addEventListener(DisplayEvents.kTouchTap,function( ... )
			if self.phoneInput.inputBegan then
				return
			end

			self.dropDownButtonArrow:setRotation(0)
			local pos = self.ui:convertToWorldSpace(self.dropDownPos:getPosition())
			self.drowDownPanel = PhoneLoginDropDownPanel:create(self.phoneNumber or "",pos)
			self.drowDownPanel:setSelectCompleteCallback(function ( phoneNumber )
				self.dropDownButtonArrow:setRotation(180)
				if phoneNumber then
					self.phoneInput:setText(phoneNumber)
					self.phoneNumber = phoneNumber
					self.button:setEnabled(string.len(self.phoneNumber or "") > 0)
				end
				self.drowDownPanel = nil
			end)
			self.drowDownPanel:popout()
		end)
	end

	self:createInput()
	self.ui:runAction(CCCallFunc:create(function() self.phoneInput:openKeyBoard() end))

	local linkContract = self.ui:getChildByName("linkContract")
	linkContract:setTouchEnabled(true)
	linkContract:getChildByName("text"):setString(Localization:getInstance():getText("login.panel.intro.new3"))
	linkContract:addEventListener(DisplayEvents.kTouchTap,PreloadingSceneUI.showUserAgreement)
	self.ui:getChildByName("tipConcact"):setString(Localization:getInstance():getText("login.panel.intro.new2"))

	local userAgreementUnderLine = LayerColor:create()
	userAgreementUnderLine:changeWidthAndHeight(120, 2)
	userAgreementUnderLine:setColor(ccc3(255, 126, 0))
	userAgreementUnderLine:setPositionXY(linkContract:getPositionX() - 25,linkContract:getPositionY() - 20)
	self.ui:addChild(userAgreementUnderLine)

	local errorTip = self.ui:getChildByName("errorTip")
	errorTip:setString(Localization:getInstance():getText("login.panel.intro.4"))
	errorTip:setVisible(false)

	local checkBox = self.ui:getChildByName("checkBox")
	checkBox:setVisible(false)
	-- function checkBox:isCheck( ... )
	-- 	return self:getChildByName("iconCheck"):isVisible()
	-- end
	-- checkBox:getChildByName("iconCheck"):setVisible(true)
	-- checkBox:setTouchEnabled(true)
	-- checkBox:addEventListener(DisplayEvents.kTouchTap,function( ... )
	-- 	if not checkBox:isCheck() then
	-- 		errorTip:setVisible(false)
	-- 	end
	-- 	checkBox:getChildByName("iconCheck"):setVisible(not checkBox:isCheck())
	-- end)

	local button = Button:create(self.ui:getChildByName("button"))
	button:setText(Localization:getInstance():getText("login.panel.button.19"))--登录
	button:setTouchEnabled(true)
	button:addEventListener(DisplayEvents.kTouchTap,function( ... )


		if self.phoneInput:validatePhone() then
			self:onLoginTapped()
		end
		 


		-- if not checkBox:isCheck() then 
		-- 	local tip = Localization:getInstance():getText("login.tips.content.2")
		-- 	CommonTip:showTip(tip, "negative",function() end,2)
		-- 	errorTip:setVisible(true)
		-- elseif self.phoneInput:validatePhone() then
		-- 	self:onLoginTapped()
		-- end




	end)
	self.button = button
	self.button:setEnabled(string.len(self.phoneNumber or "") > 0)

	local bounds = self.ui:getChildByName("bg"):getGroupBounds()
	local visibleSize = Director.sharedDirector():getVisibleSize()
	self:setPosition(ccp(
		visibleSize.width/2 - bounds.size.width/2,
		-visibleSize.height/2 + bounds.size.height/2
	))
end


function PhoneLoginPanel:createInput( ... )
	self.phoneInput = Input:create(self.ui:getChildByName("phone"),self)

	if self.phoneLoginInfo.mode == PhoneLoginMode.kBindingNewLogin then
		self.phoneInput:setPlaceHolder(
			Localization:getInstance():getText("login.panel.intro.23")
		)--"请输入您的新手机号"		
	else
		self.phoneInput:setPlaceHolder(
			Localization:getInstance():getText("login.panel.intro.13")
		)--"请输入您的手机号"
	end
	self.phoneInput:setMaxLength(11)
	self.phoneInput:setInputMode(kEditBoxInputModePhoneNumber)
	self.phoneInput:addEventListener(kTextInputEvents.kChanged,function( ... )
		self.phoneNumber = self.phoneInput:getText()
		self.button:setEnabled(string.len(self.phoneNumber) > 0)
	end)
	self.ui:addChild(self.phoneInput)
end

function PhoneLoginPanel:reBecomeTopStack( ... )
	self.phoneInput:show()
end

function PhoneLoginPanel:becomeSecondStack( ... )
	self.phoneInput:hide()
end


function PhoneLoginPanel:setPosition( pos )
	BasePanel.setPosition(self,pos)
	if self.drowDownPanel then
		local pos = self.ui:convertToWorldSpace(self.dropDownPos:getPosition())
		self.drowDownPanel:updatePostion(pos)
	end
end

function PhoneLoginPanel:onLoginTapped( ... )

	local method = nil
	local function popoutVerifyPhoneConfirmPanel(newBindFlag, isBindToUser)
		local panel = VerifyPhoneConfirmPanel:create(self.phoneLoginInfo,self.phoneNumber,method,isBindToUser,self.source)
		if newBindFlag then 
			panel.isNewBind = true
		end
		panel:setPhoneLoginCompleteCallback(self.phoneLoginCompleteCallback)
		if self.phoneLoginInfo:isInGame() then
			panel:setBackCallback(self.backCallback)
			panel:popoutReplace()
		else
			panel:popout()
		end
	end

	local isVerifyPhoneNumberMethod = false
	local function onSuccess( data )
		if self.isDisposed then
			return
		end

		if (not PlatformConfig:hasAuthConfig(PlatformAuthEnum.kPhone)) and (not data.isPhoneBound) then
			CommonTip:showTip(localize('phone.login.deny.new.user'))
			return
		end
	
		HttpsClient.setSessionId(data.sessionId)

		if isVerifyPhoneNumberMethod then
			if data.isPhoneBound then
				self.phoneLoginInfo:setDcCustom(2)
			else
				self.phoneLoginInfo:setDcCustom(1)
			end
		end

		if data.method then
			method = data.method
		end

		if not isVerifyPhoneNumberMethod then
			local panel = SendCodeConfirmPanel:create(self.phoneNumber,data.isPhoneBound,self.phoneLoginInfo.mode, self.source)
			panel:setOkCallback(function( ... )
				local dcData = {}
        		dcData.category = "bound_mobile"
        		dcData.sub_category = "bound_mobile_sms"
        		DcUtil:log(AcType.kUserTrack, dcData, true)
				popoutVerifyPhoneConfirmPanel(true, data.isPhoneBound)
			end)
			panel:setCancelCallback(function( ... )
				if self.phoneLoginInfo.mode == PhoneLoginMode.kBindingNewLogin then
					self:remove()
				end
			end)
			panel:popout()			
		else
			local isPhoneBound = false
			if data == nil or type(data) ~= "table" or data.isPhoneBound == nil then
				isPhoneBound = false
			else
				isPhoneBound = data.isPhoneBound
			end

			if data.isNewDevice or not data.isPhoneBound then
				local panel = SendCodeConfirmPanel:create(self.phoneNumber,data.isPhoneBound,self.phoneLoginInfo.mode, self.source)
				local dcData = {}
        		dcData.category = "bound_mobile"
        		dcData.sub_category = "bound_mobile_sms"
        		DcUtil:log(AcType.kUserTrack, dcData, true)
				panel:setOkCallback(function( ... )
					popoutVerifyPhoneConfirmPanel(true, isPhoneBound)
				end)
				panel:popout()
			else
				popoutVerifyPhoneConfirmPanel(nil, isPhoneBound)
			end
		end

        DcUtil:UserTrack({ 
        	category='login', 
        	sub_category='login_account_phone', 
        	step=1, 
        	place=self.phoneLoginInfo:getDcPlace(),
        	where=self.phoneLoginInfo:getDcWhere(),
        	custom=self.phoneLoginInfo:getDcCustom(),
        })
	end
	local function onError( errorCode, errorMsg, data )
		if self.isDisposed then
			return
		end
		CommonTip:showTip(localize("phone.register.error.tip."..errorCode))
	end

	local data = { phoneNumber = self.phoneNumber,deviceUdid = MetaInfo:getInstance():getUdid() }
	if self.phoneLoginInfo.mode == PhoneLoginMode.kDirectLogin or
		self.phoneLoginInfo.mode == PhoneLoginMode.kChangeLogin then
		local httpsClient = HttpsClient:create("verifyPhoneNumberV2",data,onSuccess,onError)
		httpsClient:send()
		isVerifyPhoneNumberMethod = true
	elseif self.phoneLoginInfo.mode == PhoneLoginMode.kBindingNewLogin then
		if tostring(self.phoneLoginInfo:getOldPhone()) == tostring(self.phoneNumber) then
			CommonTip:showTip(localize("login.alert.content.14"))
		else
			local httpsClient = HttpsClient:create("changeBindingVerifyNewPhoneNumber",data,onSuccess,onError)
			httpsClient:send()		
			method = "changeBindingVerifyNewV2"
		end
	elseif self.phoneLoginInfo.mode == PhoneLoginMode.kAddBindingLogin then
		if self.phoneLoginInfo:isGuestAddBinding() then
			local httpsClient = HttpsClient:create("verifyPhoneNumberV2",data,onSuccess,onError)
			httpsClient:send()
			isVerifyPhoneNumberMethod = true
		else
			local httpsClient = HttpsClient:create("addBindingVerifyPhoneNumber",data,onSuccess,onError)
			httpsClient:send()
			method = "registerV2"
		end
	end
end

function PhoneLoginPanel:popout( ... )
	PopoutStack:push(self,true,false)
end

function PhoneLoginPanel:remove( ... )
	if self.backCallback then
		PopoutStack:clear()
		self.backCallback()
	else
		PopoutStack:pop()
	end
end

function PhoneLoginPanel:onKeyBackClicked()
	self:remove()
end


function PhoneLoginPanel:setPhoneLoginCompleteCallback( phoneLoginCompleteCallback )
	self.phoneLoginCompleteCallback = phoneLoginCompleteCallback
end

function PhoneLoginPanel:setBackCallback( backCallback )
	self.backCallback = backCallback
end