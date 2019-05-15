
require "zoo.panel.phone.PopoutStack"
require "zoo.net.HttpsClient"
local Input = require "zoo.panel.phone.Input"
local Title = require "zoo.panel.phone.Title"
local Button = require "zoo.panel.phone.Button"


VerifyPhoneConfirmPanel = class(BasePanel)
function VerifyPhoneConfirmPanel:create(phoneLoginInfo,phoneNumber,method,isBindToUser,source)
	local panel = VerifyPhoneConfirmPanel.new()
	panel:loadRequiredResource("ui/login.json")
	panel:init(phoneLoginInfo,phoneNumber,method,isBindToUser,source)
	return panel
end

function VerifyPhoneConfirmPanel:init(phoneLoginInfo,phoneNumber,method,isBindToUser,source)
	self.phoneLoginInfo = phoneLoginInfo
	self.phoneNumber = phoneNumber or ""
	self.method = method
	self.isBindToUser = isBindToUser
	self.source = source

	self.ui = self:buildInterfaceGroup("VerifyPhoneConfirmPanel")
	BasePanel.init(self, self.ui)

	local title = Title:create(self.ui:getChildByName("title"),self.phoneLoginInfo:isInLoading())
	title:setTextMode(self.phoneLoginInfo.mode)
	title:setCreateBackConfirmPanelFunc(function( backCallback )
		local contentKey = string.isEmpty(self.code) and "login.alert.content.4" or "login.alert.content.5" 
		local secondKey = string.isEmpty(self.code) and "login.panel.button.18" or "login.panel.button.13"
		local panel = PhoneConfirmPanel:create(localize(contentKey))
		panel:setLeftButtonText(localize("login.panel.button.12"))
		panel:setLeftButtonCallback(backCallback)
		panel:setRightButtonText(localize(secondKey))
		return panel
	end)
	title:addEventListener(Title.Events.kBackTap,function( ... )
		self:remove()
	end)

	if self.isBindToUser and self.source == AccountBindingSource.PUSH_BIND_PANEL then
		self.ui:getChildByName("tipNoBindAward"):setString(localize("login.alert.without.bind.award"))
	end

	local closeBtn = self.ui:getChildByName("closeBtn")
	closeBtn:setTouchEnabled(self.phoneLoginInfo:isInGame())
	closeBtn:setButtonMode(self.phoneLoginInfo:isInGame())
	closeBtn:setVisible(self.phoneLoginInfo:isInGame())
	closeBtn:addEventListener(DisplayEvents.kTouchTap,function( ... )
		self:remove()
	end)

	self.codeInput = Input:create(self.ui:getChildByName("code"),self)
	self.codeInput:setMaxLength(6)
	self.codeInput:setInputMode(kEditBoxInputModeNumeric)
	self.codeInput:setPlaceHolder(Localization:getInstance():getText("login.panel.intro.5"))
	self.ui:addChild(self.codeInput)

	self.btnGetCode = Button:create(self.ui:getChildByName("btnGetCode"))
	self.btnGetCode:setText(Localization:getInstance():getText("login.panel.button.16"))
	self.btnGetCode:addEventListener(DisplayEvents.kTouchTap,function( ... )
		self:requestLoginRequestCode()
	end)

	if self.phoneLoginInfo.mode == PhoneLoginMode.kBindingOldLogin then
        local phoneNumber = string.sub(self.phoneNumber,1,3) .. string.rep("*",4) .. string.sub(self.phoneNumber,-4,-1)
		self.ui:getChildByName("tipGetCode"):setString(
			Localization:getInstance():getText("login.panel.intro.22", {num = phoneNumber})
		)
	else	
		self.ui:getChildByName("tipGetCode"):setString(
			Localization:getInstance():getText("login.panel.intro.6", {num = self.phoneNumber})
		)
	end

	local button = Button:create(self.ui:getChildByName("button"))
	button:setText(Localization:getInstance():getText("login.panel.button.11"))
	button:setEnabled(false)
	button:addEventListener(DisplayEvents.kTouchTap,function( ... )
		self:requestLoginVerifyCode()
	end)
	self.button = button

	self.codeInput:addEventListener(kTextInputEvents.kChanged,function( ... )
		self.code = self.codeInput:getText()
		self.button:setEnabled(string.len(self.code) > 0)
	end)

	self:runAction(CCCallFunc:create(function( ... )
		self:requestLoginRequestCode()
	end))

	local bounds = self.ui:getChildByName("bg"):getGroupBounds()

	local visibleSize = Director.sharedDirector():getVisibleSize()
	self:setPosition(ccp(
		visibleSize.width/2 - bounds.size.width/2,
		-visibleSize.height/2 + bounds.size.height/2
	))
end


function VerifyPhoneConfirmPanel:registerSMS()
	if __ANDROID and not PlatformConfig:isCUCCWOPlatform() then

		local mainActivity = luajava.bindClass("com.happyelements.hellolua.MainActivity")

		local function onSuccess(result)
			-- mainActivity:unRegisterSMSObserver()
			local startIndex, endIndex= string.find(result, "验证码为")
			if startIndex then
				local smsCode = string.sub(result, endIndex+1, endIndex+6)
				self.codeInput:setText(smsCode)

				self.code = self.codeInput:getText()
				self.button:setEnabled(string.len(self.code) > 0)
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

function VerifyPhoneConfirmPanel:unRegisterSMS()
	if __ANDROID and not PlatformConfig:isCUCCWOPlatform() then
		local mainActivity = luajava.bindClass("com.happyelements.hellolua.MainActivity")
		mainActivity:unRegisterSMSObserver()
	end
end

function VerifyPhoneConfirmPanel:startCountDown( ... )
	local function updateCountDown( ... )
		local leftSecond = self.countDownTime - os.time()

		if leftSecond <= 0 then
			self:resetCountDown()
			return
		end

		local second = leftSecond % 60
		local minute = math.floor(leftSecond / 60) % 60
		local hour = math.floor(leftSecond / 3600)

		local timeString
		if hour>0 then
			timeString = string.format("%02d:%02d:%02d", hour, minute, second)
	  	elseif minute>0 then
			timeString = string.format("%02d:%02d", minute, second)
		else
			timeString = string.format("%02d", second)
		end
		self.btnGetCode:setText(Localization:getInstance():getText("login.panel.button.17",{num=timeString}))
	end

	self.btnGetCode:setEnabled(false)
	self:stopAllActions()	
	updateCountDown()

	self:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(
		CCCallFunc:create(updateCountDown),
		CCDelayTime:create(1)
	)))
end

function VerifyPhoneConfirmPanel:resetCountDown( ... )
	self.btnGetCode:setEnabled(true)
	self:stopAllActions()
	self.btnGetCode:setText(Localization:getInstance():getText("login.panel.button.16"))
end

function VerifyPhoneConfirmPanel:requestLoginRequestCode( ... )

	local function onSuccess( data )
		if self.isDisposed then
			return
		end

		self.countDownTime = os.time() + data.countDown
		self:startCountDown()
		self:registerSMS()
	end
	local function onError( errorCode, errorMsg, data )
		if self.isDisposed then
			return
		end

		local function callback( ... )
			if self.isDisposed then
				return
			end
			if errorCode == 206 then --发送验证码达上限
				self:remove()
			end
		end

		self:resetCountDown()
		CommonTip:showTip(localize("phone.register.error.tip."..errorCode),"negative",callback,3)
	end

	self:unRegisterSMS()

	local data = { method = self.method, deviceUdid = MetaInfo:getInstance():getUdid() }
	if self.phoneLoginInfo:isInGame() then
		data.inGame = "true"
	end
	local httpsClient = HttpsClient:create("requestCodeV2",data,onSuccess,onError)
	httpsClient:send()
end

function VerifyPhoneConfirmPanel:requestLoginVerifyCode()
	local function onSuccess( data )
		if self.source ~= AccountBindingSource.PUSH_BIND_PANEL then				
				PushBindingLogic:checkRemovePanelAndIcon(PlatformAuthEnum.kPhone)
				if ((self.source == AccountBindingSource.FROM_LOGIN and BindPhoneBonus.hasPreloadLoginReward) or
				   self.source == AccountBindingSource.ACCOUNT_SETTING) and self.isNewBind and 
				   BindPhoneBonus:loginRewardEnabled() then
            		BindPhoneBonus:setShouldGetReward(true)
				end
		else
			if self.isBindToUser then 
--				PushBindingLogic:cancelPushBindAward() 
--				PushBindingLogic:checkRemovePanelAndIcon(PlatformAuthEnum.kPhone)
			end
		end

		if self.isDisposed then
			return
		end

        Localhost:writeCachePhoneListData(self.phoneNumber)

		self.button:setEnabled(true)

		PopoutStack:clear()
		if self.phoneLoginCompleteCallback then
			self.phoneLoginCompleteCallback(data.openId,self.phoneNumber,data.accessToken or "")
		end

        DcUtil:UserTrack({ 
        	category='login', 
        	sub_category='login_account_phone', 
        	step=2, 
        	place=self.phoneLoginInfo:getDcPlace(),
        	where=self.phoneLoginInfo:getDcWhere(),
        	custom=self.phoneLoginInfo:getDcCustom(),
        })

        if self.isNewBind then
        	local dcData = {}
        	dcData.category = "bound_mobile"
        	dcData.sub_category = "bound_mobile_ok"
        	DcUtil:log(AcType.kUserTrack, dcData, true)
        end
	end

	local function onError( errorCode, errorMsg, data )
		if self.isDisposed then
			return
		end

		self.button:setEnabled(false)

		local function callback( ... )
			if self.isDisposed then
				return
			end

			self.button:setEnabled(true)

			if errorCode == 209 then--验证码输入错误，请重新输入~
				self.codeInput:openKeyBoard()
			elseif errorCode == 210 then --验证码输入错误，将为您重置验证码，请稍后重新获取验证码~
				self.codeInput:setText("")
				self.code = self.codeInput:getText()
				self.button:setEnabled(string.len(self.code) > 0)
				self:resetCountDown()
			elseif errorCode == 208 then --验证码已过期，请稍后重新获取验证码~
				self.codeInput:setText("")
				self.code = self.codeInput:getText()
				self.button:setEnabled(string.len(self.code) > 0)
				self:resetCountDown()
			end
		end

		CommonTip:showTip(localize("phone.register.error.tip."..errorCode),"negative",callback,3)
	end

	local data = { vertifyCode = self.code, appId = "app201508061236", deviceUdid = MetaInfo:getInstance():getUdid() }
	local httpsClient = HttpsClient:create("verifyCodeV2",data,onSuccess,onError)
	httpsClient:send()
end


function VerifyPhoneConfirmPanel:popout( replace )
	PopoutStack:push(self,true,false)
end

function VerifyPhoneConfirmPanel:popoutReplace( ... )
	PopoutStack:replace(self,true,false)
end

function VerifyPhoneConfirmPanel:remove( ... )
	self:unRegisterSMS()

	if self.backCallback then
		PopoutStack:clear()
		self.backCallback()
	else
		PopoutStack:pop()
	end
end

function VerifyPhoneConfirmPanel:onKeyBackClicked()
	self:remove()
end


function VerifyPhoneConfirmPanel:setPhoneLoginCompleteCallback( phoneLoginCompleteCallback )
	self.phoneLoginCompleteCallback = phoneLoginCompleteCallback
end 
function VerifyPhoneConfirmPanel:setBackCallback( backCallback )
	self.backCallback = backCallback
end