require 'hecore.ui.Button'
local Http = require 'zoo.panel.RealName.Http'
local RealNameOfflineHttp = require 'zoo.panel.RealName.RealNameOfflineHttp'
local Input = require 'zoo.panel.RealName.input.Input'
local NameInput = require 'zoo.panel.RealName.input.NameInput'
local IdCardInput = require 'zoo.panel.RealName.input.IdCardInput'

local function setButtonLabel( label, bounds, text, scale)
    label:changeFntFile("fnt/register.fnt")
    label:setText(text)
    label:setScale(scale or 0.8)
    label:setAnchorPoint(ccp(0.5, 0.5))
    label:setPosition(ccp(bounds.size.width/2, -bounds.size.height/2))
end

local function dcChoose(value)
    RealNameManager:setDcData("choose", value)
    RealNameManager:dc()
end

--实名制基类
local RealNameBasePanel = class(BasePanel)
function RealNameBasePanel:init(child, id, outCloseCallback)
	child.id = id
    child.outCloseCallback = outCloseCallback

	local ui = child:buildInterfaceGroup("realname/panel".. child.id)
	BasePanel.init(child, ui)

	child.title_tf = child.ui:getChildByName("title_tf")
	child.info1_tf = child.ui:getChildByName("info1_tf")
	child.info2_tf = child.ui:getChildByName("info2_tf")
	child.info3_tf = child.ui:getChildByName("info3_tf")
	child.help_btn = child.ui:getChildByName("help_btn")
	child.close_btn = child.ui:getChildByName("close_btn")

	if child.title_tf then child.title_tf:setString(localize("authentication.unite.title")) end
	if child.info1_tf then child.info1_tf:setString(localize("authentication.unite.desc")) end
	if child.info2_tf then child.info2_tf:setString(localize("authentication.unite.bonus")) end
	if child.info3_tf then child.info3_tf:setString("10") end
	if child.help_btn then 
		child.help_btn:setTouchEnabled(true)
		child.help_btn:ad(DisplayEvents.kTouchTap, function()
            RealNameManager:setDcData("detail", 1)
            RealNameManager:dc()
			local panel = RealNamePanel:create(RealNamePanelType.help)
            panel:popout()
		end)
	end
	if child.close_btn then
		child.close_btn:setTouchEnabled(true)
		child.close_btn:ad(DisplayEvents.kTouchTap, function()
			if child.isDisposed then return end
            child.allowBackKeyTap = false
			if child.inCloseCallback then child.inCloseCallback() end
            if child.outCloseCallback then child.outCloseCallback() end
            if child.isExecPay and RealNameManager.payFailCallback then RealNameManager.payFailCallback() end 
            if not child.noClearDc then RealNameManager:clearDcData() end
			PopoutManager:sharedInstance():remove(child)
		end)
	end
end

function RealNameBasePanel:addRewards(rewards)
    rewards = rewards or {}
    if #rewards > 0 then
        UserManager:getInstance():addRewards(rewards, true)
        UserService:getInstance():addRewards(rewards)
        GainAndConsumeMgr.getInstance():gainMultiItems(DcFeatureType.kTrunk, rewards, DcSourceType.kAuthentication)
        if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
        else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end
    end
    
    local marketPanel = MarketPanel:getCurrentPanel()
    if marketPanel then marketPanel:updateCoinLabel() end
end

function RealNameBasePanel:popout()
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
    PopoutManager:sharedInstance():add(self, true)
    self.allowBackKeyTap = true
end

function RealNameBasePanel:close()
    if self.isDisposed then
        return
    end
    self.allowBackKeyTap = false
    PopoutManager:sharedInstance():remove(self)
end

function RealNameBasePanel:on360Click( ... )
    if __WIN32 then return end
    if self.isDisposed then return end

    RealNameManager:setCallSDK(true)
    local authorizeType = PlatformAuthEnum.k360

    local function onSNSLoginResult( status, result )
        RealNameManager:setCallSDK(false)
        RealNameManager:setAuthing(true)
        if status == SnsCallbackEvent.onSuccess and result then
            local snsInfo = {
                snsName = result.nick,
                name = result.nick,
                headUrl = result.headUrl,
            }

            local function onSuccess(evt)
                -- 实名认证成功
                local curScene = Director:sharedDirector():getRunningScene()
                if curScene then
                    curScene:runAction(CCCallFunc:create(function ( ... )
                        RealNameManager:getRealNameReward(1, true, RealNameRewardType.phone)
                    end))
                end

                -- 是否开启账号绑定
                local hasBound = (evt.data and evt.data.hasBound) or false
                if not hasBound then
                    -- 玩家使用的360账号无游戏数据，回到藤蔓弹出"使用360账号登录"面板
                    RealNameManager.skipOneKeyBind = false
                    RealNameManager:autoPopoutFollowPanel(true)
                end

                self:close()
                RealNameManager:setAuthing(false)
            end
            local function onFail()
                RealNameManager:setAuthing(false)
                -- 实名认证失败
                local errcode = evt and evt.data or nil
                if errcode then
                    -- 739004 实名账号校验失败
                    -- 739003 实名账号校验未知错误
                end
                CommonTip:showTip("实名账号校验失败, 请稍后重新登录360账号", "negative")
                self:close()
                if RealNameManager.payFailCallback then RealNameManager.payFailCallback() end
            end
            local function onCancel()
                RealNameManager:setAuthing(false)
                CommonTip:showTip(localize("authentication.feature.tip2"), "negative")
            end

            local http = (require 'zoo.panel.RealName.bind.Http').new(true)
            http:sendRealNameReq(result.openId, result.accessToken, onSuccess, onFail, onCancel)
        else
            CommonTip:showTip("登录失败，请重试~","negative")
            --if self.failCallback then self.failCallback() end
        end
    end

    -- 登录
    local oldAuthorizeType = SnsProxy:getAuthorizeType()
    SnsProxy:setAuthorizeType(authorizeType)
    SnsProxy:login(onSNSLoginResult)
    SnsProxy:setAuthorizeType(oldAuthorizeType)
end

--实名认证入口面板
local IdcardSelectPanel = class(RealNameBasePanel)
function IdcardSelectPanel:create(id, outCloseCallback)
    local panel = IdcardSelectPanel.new()
    panel:loadRequiredResource("ui/real_name.json")
    panel:init(id, outCloseCallback)
    return panel
end

function IdcardSelectPanel:init(id, outCloseCallback)
    RealNameBasePanel:init(self, id, outCloseCallback)
    self.isExecPay = true
    self.is360 = PlatformConfig:isPlatform(PlatformNameEnum.k360)

	self.other_tf = self.ui:getChildByName("other_tf")
	self.phone_tf = self.ui:getChildByName("phone_tf")
	self.idcard_tf = self.ui:getChildByName("idcard_tf")
	self.alipays_btn = self.ui:getChildByName("alipays_btn")
    self.phone_btn = self.ui:getChildByName("phone_btn")
	self.phone360_btn = self.ui:getChildByName("360_btn")
	self.idcard_btn = self.ui:getChildByName("idcard_btn")

	self.other_tf:setString(localize("authentication.unite.method.other"))
	self.idcard_tf:setString(localize("authentication.unite.method2"))
    if self.is360 then 
        if self.phone_btn then self.phone_btn:setVisible(false) end
        if self.phone_tf then self.phone_tf:setString(localize("authentication.360.button")) end
    else
        if self.phone360_btn then self.phone360_btn:setVisible(false) end
        if self.phone_tf then self.phone_tf:setString(localize("authentication.unite.method3")) end
    end
	
	if self.alipays_btn then 
		self.alipays_btn:setTouchEnabled(true)
        self.alipays_btn:ad(DisplayEvents.kTouchTap, preventContinuousClick(function ()
            dcChoose(0)
            PaymentNetworkCheck.getInstance():check(function ()
                Http:requestZhimaCertifyUrl(function(evt)
                    if evt and evt.data and evt.data.url then 
                        RealNameManager:setCallSDK(true)
                        self:close()
                        local params = HeDisplayUtil:urlEncode(evt.data.url)
                        OpenUrlUtil:openUrl("alipays://platformapi/startapp?appId=20000067&url="..params)
                    end
                end, function (errorCode, errMsg, data)
                    CommonTip:showTip(localize("forcepop.tip3"), "negative")
                end)
            end, function ()
                CommonTip:showTip(localize("forcepop.tip3"), "negative", function ()
                    if self.isDisposed then return end  
                end)
            end)
        end, 1))
	end
	if self.phone_btn then 
		self.phone_btn:setTouchEnabled(true)
		self.phone_btn:ad(DisplayEvents.kTouchTap, function()
            self:close()
			local panel = RealNamePanel:create(RealNamePanelType.phone1)
            panel:popout()
		end)
	end
    if self.phone360_btn then 
        self.phone360_btn:setTouchEnabled(true)
        self.phone360_btn:ad(DisplayEvents.kTouchTap, preventContinuousClick(function ( ... )
            PaymentNetworkCheck.getInstance():check(
                function ()
                    self:on360Click()
                    self:close()
                end,
                function ()
                    return
                end)
            end)
        , 1)
    end
	self.idcard_btn:setTouchEnabled(true)
	self.idcard_btn:ad(DisplayEvents.kTouchTap, function()
        self:close()
		local panel = RealNamePanel:create(RealNamePanelType.idcard4)
        panel:popout()
	end)

    self.inCloseCallback = function()
        dcChoose(-1)
    end
end

local IdcardPanel = class(RealNameBasePanel)
function IdcardPanel:create(id, outCloseCallback)
    local panel = IdcardPanel.new()
    panel:loadRequiredResource("ui/real_name.json")
    panel:init(id, outCloseCallback)
    return panel
end

function IdcardPanel:init(id, outCloseCallback)
    RealNameBasePanel:init(self, id, outCloseCallback)
    self.isExecPay = true

	self.card_tf = self.ui:getChildByName('card_tf')
    self.card_bg1 = self.ui:getChildByName('card_bg1')
    self.card_bg2 = self.ui:getChildByName('card_bg2')
    self.card_sign1 = self.ui:getChildByName('card_sign1')
    self.card_sign2 = self.ui:getChildByName('card_sign2')
    self.card_error_tf = self.ui:getChildByName('card_error_tf')
    self.name_tf = self.ui:getChildByName('name_tf')
    self.name_bg1 = self.ui:getChildByName('name_bg1')
    self.name_bg2 = self.ui:getChildByName('name_bg2')
    self.name_sign1 = self.ui:getChildByName('name_sign1')
    self.name_sign2 = self.ui:getChildByName('name_sign2')
    self.name_error_tf = self.ui:getChildByName('name_error_tf')

    self.name_tf:setString(localize('authentication.feature.id.bonding.content1', {s = ' '}))
    self.card_tf:setString(localize('authentication.feature.id.bonding.content2'))

    self.name_bg2:setVisible(false)
    self.name_sign2:setVisible(false)
    self.card_bg2:setVisible(false)
    self.card_sign2:setVisible(false)

    self.name_input_tf = NameInput:create(self.ui:getChildByName('name_input_tf'), self)
    self.name_input_tf:setPlaceHolder(
        Localization:getInstance():getText("authentication.feature.id.bonding.content3")
    )
    self.name_input_tf:setInputMode(kEditBoxInputModeSingleLine)
    self.name_input_tf:addEventListener(kTextInputEvents.kChanged,function()
        self.name = self.name_input_tf:getText()
        if self.isDisposed then
            return
        end
    end)
      self.name_input_tf:addEventListener(kTextInputEvents.kGotFocus,function()
        if self.isDisposed then
            return
        end
        self.name_error_tf:setString('')
        self.name_bg1:setVisible(true)
        self.name_bg2:setVisible(false)
        self.name_sign1:setVisible(true)
        self.name_sign2:setVisible(false)
        self.name_input_tf:setPlaceHolder('')
    end)
    self.name_input_tf:addEventListener(kTextInputEvents.kLostFocus,function()
        if self.isDisposed then
            return
        end

        if string.isEmpty(self.name_input_tf:getText()) then
            self.name_error_tf:setString('')
            self.name_bg1:setVisible(true)
            self.name_bg2:setVisible(false)
            self.name_sign1:setVisible(true)
            self.name_sign2:setVisible(false)
        elseif self.name_input_tf:verify() then
            self.name_error_tf:setString('')
            self.name_bg1:setVisible(true)
            self.name_bg2:setVisible(false)
            self.name_sign1:setVisible(false)
            self.name_sign2:setVisible(true)
        else
            self.name_error_tf:setString(localize('authentication.feature.id.bonding.warn1'))
            self.name_bg1:setVisible(false)
            self.name_bg2:setVisible(true)
            self.name_sign1:setVisible(true)
            self.name_sign2:setVisible(false)
        end
        self.name_input_tf:setPlaceHolder(
            #self.name_input_tf:getText() == 0 and Localization:getInstance():getText("authentication.feature.id.bonding.content3") or ''
        )
        self:setButtonEnable(self.name_input_tf:verify() and self.card_input_tf:verify())
    end)
    self.ui:addChild(self.name_input_tf)

    self.card_input_tf = IdCardInput:create(self.ui:getChildByName('card_input_tf'), self)
    self.card_input_tf:setPlaceHolder(
        Localization:getInstance():getText("authentication.feature.id.bonding.content4")
    )
    self.card_input_tf:setMaxLength(18)
    self.card_input_tf:setInputMode(kEditBoxInputModeSingleLine)
    self.card_input_tf:addEventListener(kTextInputEvents.kChanged,function()
        self.idCard = self.card_input_tf:getText()
        if #self.idCard == 18 then
            if self.idCard:sub(18, 18) == "x" then
                local prefix = self.idCard:sub(1, 17)
                self.idCard = prefix .. "X"
                self.card_input_tf:setText(self.idCard)
            end
            if self.card_input_tf:verify() then
                self.card_error_tf:setString('')
                self.card_bg1:setVisible(true)
                self.card_bg2:setVisible(false)
                self.card_sign1:setVisible(false)
                self.card_sign2:setVisible(true)
            else
                self.card_error_tf:setString(localize('authentication.feature.id.bonding.warn3'))
                self.card_bg1:setVisible(false)
                self.card_bg2:setVisible(true)
                self.card_sign1:setVisible(true)
                self.card_sign2:setVisible(false)
            end
            self:setButtonEnable(self.name_input_tf:verify() and self.card_input_tf:verify())
        end
        if self.isDisposed then
            return
        end
    end)
    self.card_input_tf:addEventListener(kTextInputEvents.kGotFocus,function()
        if self.isDisposed then
            return
        end
        self.card_error_tf:setString('')
        self.card_bg1:setVisible(true)
        self.card_bg2:setVisible(false)
        self.card_sign1:setVisible(true)
        self.card_sign2:setVisible(false)
        self.card_input_tf:setPlaceHolder('')
    end)
    self.card_input_tf:addEventListener(kTextInputEvents.kLostFocus,function()
        if self.isDisposed then
            return
        end
        if string.isEmpty(self.card_input_tf:getText()) then
            self.card_error_tf:setString('')
            self.card_bg1:setVisible(true)
            self.card_bg2:setVisible(false)
            self.card_sign1:setVisible(true)
            self.card_sign2:setVisible(false)
        elseif self.card_input_tf:verify() then
            self.card_error_tf:setString('')
            self.card_bg1:setVisible(true)
            self.card_bg2:setVisible(false)
            self.card_sign1:setVisible(false)
            self.card_sign2:setVisible(true)
        else
            self.card_error_tf:setString(localize('authentication.feature.id.bonding.warn3'))
            self.card_bg1:setVisible(false)
            self.card_bg2:setVisible(true)
            self.card_sign1:setVisible(true)
            self.card_sign2:setVisible(false)
        end
        self.card_input_tf:setPlaceHolder(
            #self.card_input_tf:getText() == 0 and Localization:getInstance():getText("authentication.feature.id.bonding.content4") or ''
        )
        self:setButtonEnable(self.name_input_tf:verify() and self.card_input_tf:verify())
    end)
    self.ui:addChild(self.card_input_tf)

    self.private_tf = self.ui:getChildByName("private_tf")
    self.private_tf:setString(localize('authentication.feature.id.bonding.warn4'))
    self.private_tf:setVisible(false)

    self.okButtonUI = self.ui:getChildByName('ok_btn')
    self.okButtonUI:setTouchEnabled(true)
    local buttonBounds = self.okButtonUI:getGroupBounds(self.ui)
    local buttonLabel = self.okButtonUI:getChildByName('label')
    setButtonLabel(buttonLabel, buttonBounds, localize('authentication.feature.id.bonding.btn8'))

    self.ok_btn = Button:create(self.okButtonUI, true)
    self:setButtonEnable(false)
    self.ok_btn:ad(Events.kStart, preventContinuousClick(function()
            if not self.name_input_tf:verify() or not self.card_input_tf:verify() then
                self:setButtonEnable(false)
                return
            end

            PaymentNetworkCheck.getInstance():check(function ()
                self:onOkBtnClick()
            end, function ()
                self.noNetwork = true
                CommonTip:showTip(localize("forcepop.tip3"), 'negative', function ( ... )
                    if self.isDisposed then return end  
                end)
            end)
        end, 1)
    )

    self.inCloseCallback = function()
        local code = nil
        if self.noNetwork then
            code = -1
        else
            code = 0
        end
        
        RealNameManager:setDcData("choose", -1)
        RealNameManager:setDcData("id_result", code)
        RealNameManager:dc()
    end
    dcChoose(1)
end

function IdcardPanel:onOkBtnClick( ... )
    if self.isDisposed then return end
    RealNameManager:setDcData("id_result", 1)
    RealNameManager:dc()

    Http:saveZhimaCertify(self.name, self.idCard, function (evt)
        if evt and evt.data and evt.data.result then 
            if evt.data.result == 0 then 
                self:close()
                RealNameManager:getRealNameReward(1, true, RealNameRewardType.idcard)
            elseif evt.data.result == 1 then 
                RealNameManager:getRealNameReward(2, true, RealNameRewardType.idcard)
            elseif evt.data.result == -1 then
                RealNameManager:writeAuthSuccess(RealNameRewardType.idcard)
                RealNameManager:onAuthSuccess()
                self:close()
                CommonTip:showTip(localize('authentication.feature.tip3'), 'positive', function()
                    if RealNameManager.payFailCallback then RealNameManager.payFailCallback() end
                end)
            else
                CommonTip:showTip(localize('error.tip.-1000061'), 'negative', function()
                    if RealNameManager.payFailCallback then RealNameManager.payFailCallback() end
                end)
            end
        end
    end, function (errorCode, errMsg, data)
        CommonTip:showTip(localize('error.tip.-1000061'), 'negative', function ( ... )
            if self.isDisposed then return end
        end)
    end)
end

function IdcardPanel:setButtonEnable(bEnable)
    self.ok_btn:setEnable(bEnable)
    self.private_tf:setVisible(bEnable)
end

--输入手机号面板
local PhoneOnePanel = class(RealNameBasePanel)
function PhoneOnePanel:create(id, outCloseCallback)
    local panel = PhoneOnePanel.new()
    panel:loadRequiredResource("ui/real_name.json")
    panel:init(id, outCloseCallback)
    return panel
end

function PhoneOnePanel:init(id, outCloseCallback)
    RealNameBasePanel:init(self, id, outCloseCallback)
    self.isExecPay = true
    self.noNetwork = false

    self.okButtonUI = self.ui:getChildByName("ok_btn")
    self.okButtonUI:setTouchEnabled(true)
    local buttonBounds = self.okButtonUI:getGroupBounds(self.ui)
    local buttonLabel = self.okButtonUI:getChildByName("label")
    buttonLabel:changeFntFile("fnt/register.fnt")
    buttonLabel:setText('下一步')
    buttonLabel:setScale(0.8)
    buttonLabel:setAnchorPoint(ccp(0.5, 0.5))
    buttonLabel:setPosition(ccp(buttonBounds.size.width/2, -buttonBounds.size.height/2))

    self.ok_btn = Button:create(self.okButtonUI, true)
    self.ok_btn:setEnable(false)
    self.ok_btn:ad(
        Events.kStart, 
        preventContinuousClick(function ( ... )
            PaymentNetworkCheck.getInstance():check(function ()
                self:onClick()
            end, function ()
                self.noNetwork = true

                if (not self.phone_input) or (self.phone_input.isDisposed) then
                    return
                end 

                CommonTip:showTip(localize("forcepop.tip3"), 'negative', function ( ... )
                    if self.isDisposed then return end

                    if (not self.phone_input) or (self.phone_input.isDisposed) then
                        return
                    end 
                end)

            end)
        end, 1)
    )

    self:createInput(self.ui:getChildByName('input_tf'))
    self.inCloseCallback = function()
        RealNameManager:setDcData("choose", -1)
        RealNameManager:setDcData("phone_result", -2)
        RealNameManager:dc()
    end
    dcChoose(2)
end

function PhoneOnePanel:popout()
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
    self:setPositionX(self:getPositionX() + 0)
    PopoutManager:sharedInstance():add(self, true)
    self.allowBackKeyTap = true
end

function PhoneOnePanel:createInput( ui )
    self.phone_input = Input:create(ui, self)
    self.phone_input:setPlaceHolder(
        Localization:getInstance():getText("login.panel.intro.13")
    )
    self.phone_input:setMaxLength(11)
    self.phone_input:setInputMode(kEditBoxInputModePhoneNumber)
    self.phone_input:addEventListener(kTextInputEvents.kChanged,function( ... )
        self.phoneNumber = self.phone_input:getText()
        if self.isDisposed then
            return
        end
        self.ok_btn:setEnable(string.len(self.phoneNumber) > 0)
    end)
    self.ui:addChild(self.phone_input)
end

function PhoneOnePanel:onClick( ... )
    if self.isDisposed then return end

    if not self.phone_input:isValidPhone() then
        -- self.phone_input:setVisible(false)
        CommonTip:showTip('请输入正确的手机号码', 'negative', function ( ... )
            if self.isDisposed then
                return
            end
            -- self.phone_input:setVisible(true)
        end)
        return
    end


    Http:sendPhoneNumber(self.phoneNumber, function ( ... )
        self:close()
        RealNamePanel:create(RealNamePanelType.phone2):popout()
        RealNameManager:setDcData("phone_result", 0)
        RealNameManager:dc()
    end, function ( errorCode, errMsg, data )
        if (not self.phone_input) or (self.phone_input.isDisposed) then
            return
        end 
        -- self.phone_input:setVisible(false)
        CommonTip:showTip(localize("phone.register.error.tip."..errorCode), 'negative', function ( ... )
            if self.isDisposed then return end

            if (not self.phone_input) or (self.phone_input.isDisposed) then
                return
            end 
            -- self.phone_input:setVisible(true)
        end)
    end)
end

--输入验证码面板
local PhoneTwoPanel = class(RealNameBasePanel)
function PhoneTwoPanel:create(id, outCloseCallback)
    local panel = PhoneTwoPanel.new()
    panel:loadRequiredResource("ui/real_name.json")
    panel:init(id, outCloseCallback)
    return panel
end

function PhoneTwoPanel:init(id, outCloseCallback)
    RealNameBasePanel:init(self, id, outCloseCallback)
    self.isExecPay = true

    self.okButtonUI = self.ui:getChildByName('ok_btn')
    self.okButtonUI:setTouchEnabled(true)
    local buttonBounds = self.okButtonUI:getGroupBounds(self.ui)
    local buttonLabel = self.okButtonUI:getChildByName('label')
    setButtonLabel(buttonLabel, buttonBounds, localize('authentication.feature.id.bonding.btn8'))

    self.ok_btn = Button:create(self.okButtonUI, true)
    self.ok_btn:setEnable(false)
    self.ok_btn:ad(
    	Events.kStart, 
    	preventContinuousClick(function ( ... )
    		self:onOkButtonClick()
    	end, 1)
    )

    self.codeButtonUI = self.ui:getChildByName('code_btn')
    self.codeButtonUI:setTouchEnabled(true)
    local buttonBounds = self.codeButtonUI:getGroupBounds(self.ui)
    local buttonLabel = self.codeButtonUI:getChildByName('label')
    self.getCodeBtnLabel = buttonLabel
    self.getCodeBtnBounds = buttonBounds
    setButtonLabel(self.getCodeBtnLabel, self.getCodeBtnBounds, '获取验证码', 0.4)

    self.code_btn = Button:create(self.codeButtonUI, true)
    self.code_btn:ad(Events.kStart, preventContinuousClick(function ( ... )
    	self:getCode()
    end, 1))

   	self:createInput(self.ui:getChildByName('input_tf'))
   	self:getCode()

    self.inCloseCallback = function()
        self:unRegisterSMS()
        RealNameManager:setDcData("phone_result", -1)
        RealNameManager:dc()
    end

    self.bottom = self.ui:getChildByName('bottom')
    local userArgumentLink = self.bottom:getChildByName('label2')
    userArgumentLink:setTouchEnabled(true)
    userArgumentLink:ad(DisplayEvents.kTouchTap, function ( ... )
        PreloadingSceneUI.showUserAgreement()
    end)
end

function PhoneTwoPanel:registerSMS()
    if self.__registerSMS then return end
    self.__registerSMS = true 

    if __ANDROID and not PlatformConfig:isCUCCWOPlatform() then
        local mainActivity = luajava.bindClass("com.happyelements.hellolua.MainActivity")
        local function onSuccess(result)
            -- mainActivity:unRegisterSMSObserver()
            local startIndex, endIndex= string.find(result, "验证码为")
            if startIndex then
                local smsCode = string.sub(result, endIndex+1, endIndex+6)
                self.code_input:setText(smsCode)

                self.codeNumber = self.code_input:getText()
                self.ok_btn:setEnable(string.len(self.codeNumber) > 0)
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

function PhoneTwoPanel:unRegisterSMS()

    if not self.__registerSMS then return end
    self.__registerSMS = false 

    if __ANDROID and not PlatformConfig:isCUCCWOPlatform() then
        local mainActivity = luajava.bindClass("com.happyelements.hellolua.MainActivity")
        mainActivity:unRegisterSMSObserver()
    end
end

function PhoneTwoPanel:onOkButtonClick( ... )
    if self.isDisposed then return end
    Http:vertifyCode(self.codeNumber, function ( canBind )
        RealNameManager:setDcData("phone_result", 1)
        RealNameManager:dc()
        RealNameManager:autoPopoutFollowPanel(canBind)

        self:close()
        RealNameManager:getRealNameReward(1, true, RealNameRewardType.phone)
    end, function ( errorCode, errMsg, data )

        if self.isDisposed then
            return
        end
        self.ok_btn:setEnable(false)
        local function callback( ... )
            if self.isDisposed then
                return
            end
            self.ok_btn:setEnable(true)
            if errorCode == 209 then--验证码输入错误，请重新输入~
                self.code_input:openKeyBoard()
            elseif errorCode == 210 then --验证码输入错误，将为您重置验证码，请稍后重新获取验证码~
                self.code_input:setText("")
                self.codeNumber = self.code_input:getText()
                self.ok_btn:setEnable(string.len(self.codeNumber) > 0)
                self:resetCountDown()
            elseif errorCode == 208 then --验证码已过期，请稍后重新获取验证码~
                self.code_input:setText("")
                self.codeNumber = self.code_input:getText()
                self.ok_btn:setEnable(string.len(self.codeNumber) > 0)
                self:resetCountDown()
            end
        end
        --RealNameManager:getRealNameReward(2, true, RealNameRewardType.phone, callback)
        CommonTip:showTip(localize("phone.register.error.tip."..errorCode),"negative",callback,3)
    end, function ( ... )
        CommonTip:showTip(localize('验证码错误'), 'negative')
    end)
end

function PhoneTwoPanel:createInput( ui )
	self.code_input = Input:create(ui, self)
	self.code_input:setPlaceHolder(
		Localization:getInstance():getText("login.panel.intro.5")
	)
	self.code_input:setMaxLength(6)
	self.code_input:setInputMode(kEditBoxInputModePhoneNumber)
	self.code_input:addEventListener(kTextInputEvents.kChanged,function( ... )
		self.codeNumber = self.code_input:getText()
		if self.isDisposed then
			return
		end
		self.ok_btn:setEnable(string.len(self.codeNumber) > 0)
	end)
	self.ui:addChild(self.code_input)

end

function PhoneTwoPanel:getCode( ... )
    if self.isDisposed then return end
    self:unRegisterSMS()
	self.code_btn:setEnable(true)
	Http:requestCode(function ( cdTime )
        self.code_btn:setEnable(false)
        self:registerSMS()
        cdTime = tonumber(cdTime) or 60
        self.codeButtonUI:runAction(
            CCSequence:createWithTwoActions(
                CCRepeat:create(
                    CCSequence:createWithTwoActions(
                        CCCallFunc:create(function ( ... )
                            if self.isDisposed then return end
                            setButtonLabel(self.getCodeBtnLabel, self.getCodeBtnBounds, string.format('重新发送(%s)', cdTime), 0.4)
                            cdTime = cdTime - 1
                        end),
                        CCDelayTime:create(1)
                    ), 
                cdTime
                ),

                CCCallFunc:create(function ( ... )
                    if self.isDisposed then return end
                    setButtonLabel(self.getCodeBtnLabel, self.getCodeBtnBounds, '获取验证码', 0.4)
                    self.code_btn:setEnable(true)
                end)
            )
        )   
    end, function( errorCode, errorMsg, data )
        if self.isDisposed then
            return
        end
        local function callback( ... )
            if self.isDisposed then
                return
            end

            if errorCode == 206 then
                self:close()
                if RealNameManager.payFailCallback then
                    RealNameManager.payFailCallback()
                end
            end
        end
        self:resetCountDown()
        CommonTip:showTip(localize("phone.register.error.tip."..errorCode),"negative",callback,3)
    end)
end

function PhoneTwoPanel:resetCountDown( ... )
    if self.isDisposed then return end
    self.codeButtonUI:stopAllActions()
    setButtonLabel(self.getCodeBtnLabel, self.getCodeBtnBounds, '获取验证码', 0.4)
    self.code_btn:setEnable(true)
end

--360认证
local Phone360Panel = class(RealNameBasePanel)
function Phone360Panel:create(id, outCloseCallback)
    local panel = Phone360Panel.new()
    panel:loadRequiredResource("ui/real_name.json")
    panel:init(id, outCloseCallback)
    return panel
end

function Phone360Panel:init(id, outCloseCallback)
    RealNameBasePanel:init(self, id, outCloseCallback)
    self.isExecPay = true
    self.noNetwork = false

    self.buttonUI = self.ui:getChildByName('360_btn')
    self.buttonUI:setTouchEnabled(true)
    self.phone360_btn = Button:create(self.buttonUI, true)
    self.phone360_btn:ad(
        Events.kStart, 
        preventContinuousClick(function ( ... )
            PaymentNetworkCheck.getInstance():check(
                function ()
                    self:on360Click()
                    self:close()
                end,
                function ()
                    return
                end)
            end)
        , 1)

    self.phone360_tf = self.ui:getChildByName("360_tf")
    self.phone360_tf:setString(localize("authentication.360.button"))
    dcChoose(2)
end

--帮助面板
local HelpPanel = class(RealNameBasePanel)
function HelpPanel:create(id, outCloseCallback)
    local panel = HelpPanel.new()
    panel:loadRequiredResource("ui/real_name.json")
    panel:init(id, outCloseCallback)
    return panel
end

function HelpPanel:init(id, outCloseCallback)
    RealNameBasePanel:init(self, id, outCloseCallback)

	self.detail1_tf = self.ui:getChildByName("detail1_tf")
	self.detail2_tf = self.ui:getChildByName("detail2_tf")

	self.detail1_tf:setString('　　'..localize('authentication.feature.desc.context1'))
    self.detail2_tf:setString('　　'..localize('authentication.feature.desc.context2'))
    self.noClearDc = true
end

--离线领奖面板
local OfflineSuccessPanel = class(RealNameBasePanel)
function OfflineSuccessPanel:create(id, outCloseCallback)
    local panel = OfflineSuccessPanel.new()
    panel:loadRequiredResource("ui/real_name.json")
    panel:init(id, outCloseCallback)
    return panel
end

function OfflineSuccessPanel:init(id, outCloseCallback)
    RealNameBasePanel:init(self, id, outCloseCallback)

    self.close_btn:setVisible(false)
    self.info_tf = self.ui:getChildByName("info_tf")
    self.info_tf:setString('获得如下奖励:')

    self.okButtonUI = self.ui:getChildByName('ok_btn')
    self.okButtonUI:setTouchEnabled(true)
    local buttonBounds = self.okButtonUI:getGroupBounds(self.ui)
    local buttonLabel = self.okButtonUI:getChildByName('label')
    setButtonLabel(buttonLabel, buttonBounds, '领取')

    self.ok_btn = Button:create(self.okButtonUI, true)
    self.ok_btn:ad(Events.kStart, function()
        self:onBtnClick()
    end)

    local rewardUI = self.ui:getChildByName('reward')
    self.rewardIndex = self.ui:getChildIndex(rewardUI)
    local rewardBounds = rewardUI:getGroupBounds(self.ui)
    self.rewardCenterPos = ccp(rewardBounds:getMidX(), rewardBounds:getMidY())
    rewardUI:removeFromParentAndCleanup(true)
end

function OfflineSuccessPanel:onBtnClick( ... )
    if self.isDisposed then
        return
    end
    self:getReward(function (rewardItems)

        self:addRewards(rewardItems)

        local visibleOrigin = Director:sharedDirector():getVisibleOrigin()
        local visibleSize =  Director:sharedDirector():getVisibleSize()

        local worldCenterPos = ccp(
            visibleOrigin.x + visibleSize.width/2,
            visibleOrigin.y + visibleSize.height/2
        )

        local flyAnim = FlyItemsAnimation:create(self.rewards)
        flyAnim:setWorldPosition(worldCenterPos)
        flyAnim:setFinishCallback(function ( ... )
            self:close()
        end)
        flyAnim:play()

        self:setVisible(false)

    end, function ()
        self:close()
    end)
    if self.outCloseCallback then self.outCloseCallback() end
end

function OfflineSuccessPanel:getReward( onSuccess, onFail )
    RealNameOfflineHttp:getReward(self.rewardId, function ( evt )
        -- local data = evt.data or {}
        local rewardItems = self.rewards or {}
        if #rewardItems <= 0 then
            if onFail then onFail() end
        else
            if onSuccess then onSuccess(rewardItems) end
        end
    end, function ( ... )
        if onFail then onFail(...) end
    end, function ( ... )
        if onFail then onFail(...) end
    end)
end

function OfflineSuccessPanel:setRewards(rewardId, rewards )

    if self.isDisposed then
        return
    end

    self.rewardId = rewardId
    self.rewards = rewards

    if self.rewardLayer then
        self.rewardLayer:removeFromParentAndCleanup(true)
        self.rewardLayer = nil
    end

    self.rewardLayer = Layer:create()
    local items = {}

    for index, rewardItem in ipairs(rewards) do
        local itemUI = self:buildItem(rewardItem)
        table.insert(items, {node = itemUI})
        self.rewardLayer:addChild(itemUI)
    end

    local layoutUtils =  require 'zoo.panel.happyCoinShop.utils'
    layoutUtils.horizontalLayoutItems(items)

    self.ui:addChildAt(self.rewardLayer, self.rewardIndex)
    layoutUtils.setNodeCenterPos(self.rewardLayer, self.rewardCenterPos, self.ui)
    self.rewardLayer:setPositionX(self.rewardLayer:getPositionX() + 20)
end

function OfflineSuccessPanel:buildItem( rewardItem )

    self:loadRequiredResource("ui/real_name.json")
    local itemUI = self:buildInterfaceGroup('realname/reward')
    local holder = itemUI:getChildByName('holder')
    holder:setAnchorPointCenterWhileStayOrigianlPosition()
    local holderPos = holder:getPosition()
    local holderIndex = itemUI:getChildIndex(holder)
    holder:setVisible(false)

    local num = itemUI:getChildByName('num')
    num:changeFntFile('fnt/target_amount.fnt')
    num:setScale(1.5)

    num:setPositionY(num:getPositionY()-12)
    num:setPositionX(num:getPositionX()-12)

    local rewardIcon = ResourceManager:sharedInstance():buildItemSprite(rewardItem.itemId)
    rewardIcon:setScale(1.3)
    rewardIcon:setAnchorPoint(ccp(0.5, 0.5))
    rewardIcon:setPosition(ccp(holderPos.x, holderPos.y))

    itemUI:addChildAt(rewardIcon, holderIndex)

    num:setText('x'..tostring(rewardItem.num))

    return itemUI
end

--离线失败面板
local OfflineFailPanel = class(RealNameBasePanel)
function OfflineFailPanel:create(id, outCloseCallback)
    local panel = OfflineFailPanel.new()
    panel:loadRequiredResource("ui/real_name.json")
    panel:init(id, outCloseCallback)
    return panel
end

function OfflineFailPanel:init(id, outCloseCallback)
    RealNameBasePanel:init(self, id, outCloseCallback)

	self.info_tf = self.ui:getChildByName("info_tf")
	self.info_tf:setString(localize("authentication.feature.id.fail"))

    self.okButtonUI = self.ui:getChildByName('ok_btn')
    self.okButtonUI:setTouchEnabled(true)
    local buttonBounds = self.okButtonUI:getGroupBounds(self.ui)
    local buttonLabel = self.okButtonUI:getChildByName('label')
    setButtonLabel(buttonLabel, buttonBounds, '关闭')

    self.ok_btn = Button:create(self.okButtonUI, true)
    self.ok_btn:ad(Events.kStart, function()
        if self.outCloseCallback then self.outCloseCallback() end
        PopoutManager:sharedInstance():remove(self)
    end)
end

--实时领奖面板
local OnlinePanel = class(RealNameBasePanel)
function OnlinePanel:create(id, outCloseCallback)
    local panel = OnlinePanel.new()
    panel:loadRequiredResource("ui/real_name.json")
    panel:init(id, outCloseCallback)
    return panel
end

function OnlinePanel:init(id, outCloseCallback)
	self.id = id
    self.outCloseCallback = outCloseCallback
	local ui = self:buildInterfaceGroup("realname/panel11")
	BasePanel.init(self, ui)

	self.detail_tf = self.ui:getChildByName("detail_tf")
	if self.id == RealNamePanelType.onlineSuccess then 
		self.detail_tf:setString(localize("authentication.unite.tip1"))
	else
		self.detail_tf:setString(localize("authentication.unite.tip2"))
	end

    local function onTimeout()
        if self.schedule then CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedule) end
        self.schedule = nil
        self:close()
        if self.outCloseCallback then self.outCloseCallback() end
    end
	self.schedule = Director:sharedDirector():getScheduler():scheduleScriptFunc(onTimeout, 3, false)
end

function OnlinePanel:setRewards(rewardId, rewards)
    self.rewardId = rewardId
    self.rewards = rewards

    if self.rewardId and self.rewards then 
        --[[
        RealNameOfflineHttp:getReward(self.rewardId, function() 
            end, function()
            end, function()
            end)]]
        self:addRewards(self.rewards)
    end

    local visibleOrigin = Director:sharedDirector():getVisibleOrigin()
    local visibleSize =  Director:sharedDirector():getVisibleSize()
    local worldCenterPos = ccp(
        visibleOrigin.x + visibleSize.width/2,
        visibleOrigin.y + visibleSize.height/2
    )

    local flyAnim = FlyItemsAnimation:create(self.rewards)
    flyAnim:setWorldPosition(worldCenterPos)
    flyAnim:play()
end

RealNamePanel = class()
function RealNamePanel:create(id, outCloseCallback)
	local panel
	if RealNamePanelType.idcard1 == id then 
		panel = IdcardSelectPanel:create(RealNamePanelType.idcard1, outCloseCallback)
	elseif RealNamePanelType.idcard2 == id then
		panel = IdcardSelectPanel:create(RealNamePanelType.idcard2, outCloseCallback)
	elseif RealNamePanelType.idcard3 == id then
		panel = IdcardSelectPanel:create(RealNamePanelType.idcard3, outCloseCallback)
	elseif RealNamePanelType.idcard4 == id then
		panel = IdcardPanel:create(RealNamePanelType.idcard4, outCloseCallback)
	elseif RealNamePanelType.phone1 == id then
		panel = PhoneOnePanel:create(RealNamePanelType.phone1, outCloseCallback)
	elseif RealNamePanelType.phone2 == id then
		panel = PhoneTwoPanel:create(RealNamePanelType.phone2, outCloseCallback)
	elseif RealNamePanelType.phone360 == id then
		panel = Phone360Panel:create(RealNamePanelType.phone360, outCloseCallback)
	elseif RealNamePanelType.help == id then
		panel = HelpPanel:create(RealNamePanelType.help, outCloseCallback)
	elseif RealNamePanelType.offlineSuccess == id then
		panel = OfflineSuccessPanel:create(RealNamePanelType.offlineSuccess, outCloseCallback)
	elseif RealNamePanelType.offlineFail == id then
		panel = OfflineFailPanel:create(RealNamePanelType.offlineFail, outCloseCallback)
	elseif RealNamePanelType.onlineSuccess == id then
		panel = OnlinePanel:create(RealNamePanelType.onlineSuccess, outCloseCallback)
	elseif RealNamePanelType.onlineFail == id then
		panel = OnlinePanel:create(RealNamePanelType.onlineFail, outCloseCallback)
	end
	return panel
end