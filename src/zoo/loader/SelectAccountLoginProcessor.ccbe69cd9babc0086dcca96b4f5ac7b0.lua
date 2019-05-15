require "zoo.panel.phone.SelectLoginPanel"
require "zoo.panel.phone.PhoneLoginPanel"
require "zoo.panel.phone.PopoutStack"
require "zoo.panel.phone.PhoneLoginInfo"

local Processor = class(EventDispatcher)
Processor.Events = {
	kSnsLogin = "snslogin",
	kPhoneLoginComplete = "phoneLogin",
	kCancel = "cancel",
}

function Processor:onCancel( ... )
    self:dispatchEvent(Event.new(self.Events.kCancel,nil,self))
end

function Processor:onPhoneLoginComplete( openId,phoneNumber,accessToken )
    if SnsProxy:getAuthorizeType() == PlatformAuthEnum.kPhone then
        _G.sns_token = { openId=openId,accessToken=accessToken,authorType=PlatformAuthEnum.kPhone }
        Localhost:writeCachePhoneListData(phoneNumber)
        
        self:dispatchEvent(Event.new(self.Events.kPhoneLoginComplete,nil,self))
    else
        SnsProxy:logout({
            onSuccess = function( ... )
                _G.sns_token = { openId=openId,accessToken=accessToken, authorType=PlatformAuthEnum.kPhone }
                Localhost:writeCachePhoneListData(phoneNumber)
                SnsProxy:setAuthorizeType(PlatformAuthEnum.kPhone)
        
                self:dispatchEvent(Event.new(self.Events.kPhoneLoginComplete,nil,self))
            end,
            onError = function( ... )
                self:dispatchEvent(Event.new(self.Events.kError, nil, self))
            end,
            onCancel = function( ... )
                self:dispatchEvent(Event.new(self.Events.kCancel, nil, self))
            end
        })
    end
end

function Processor:onSelectSnsLogin( authEnum )
    self:dispatchEvent(Event.new(self.Events.kSnsLogin,authEnum,self))

    -- if SnsProxy:getAuthorizeType() == PlatformAuthEnum.kPhone then
    --     SnsProxy:setAuthorizeType(authEnum)
    --     self:dispatchEvent(Event.new(self.Events.kSnsLogin,authEnum,self))
    -- else
    --     SnsProxy:logout({
    --         onSuccess = function( ... )
    --             SnsProxy:setAuthorizeType(authEnum)
    --             self:dispatchEvent(Event.new(self.Events.kSnsLogin,authEnum,self))
    --         end,
    --         onError = function( ... )
    --             self:dispatchEvent(Event.new(self.Events.kError, nil, self))
    --         end,
    --         onCancel = function( ... )
    --             self:dispatchEvent(Event.new(self.Events.kCancel, nil, self))
    --         end
    --     })
    -- end
end

function Processor:start(context,isChangeAccount,lastPhoneLoginExpire)
    
    local function dcAccountType( object )
        if isChangeAccount then
            DcUtil:UserTrack({ category='login', sub_category='login_switch_account_type', object=object })
        else
            DcUtil:UserTrack({ category='login', sub_category='login_account_type', object=object })
        end
    end
    if isChangeAccount then
        DcUtil:UserTrack({ category='login', sub_category='login_click_switch_account' })
    else
        DcUtil:UserTrack({ category='login', sub_category='login_click_account' })
    end

    local loginInfo = PhoneLoginInfo.new()
    if not isChangeAccount then
        loginInfo:setMode(PhoneLoginMode.kDirectLogin)
    else
        loginInfo:setMode(PhoneLoginMode.kChangeLogin)        
    end

    if lastPhoneLoginExpire then
        local panel = PhoneLoginPanel:create(loginInfo, AccountBindingSource.FROM_LOGIN)
        panel:setPhoneLoginCompleteCallback(function( openId,phoneNumber,accessToken )
            self:onPhoneLoginComplete(openId,phoneNumber,accessToken)
            dcAccountType(PlatformAuthEnum.kPhone)
        end)
        panel:setBackCallback(function( ... )
            self:onCancel()
        end)
        -- panel:setPhoneNumber(Localhost:getLastLoginPhoneNumber())
        -- panel:showCloseButton()
        panel:popout()

    elseif PlatformConfig:isMultipleLoginAuthConfig() then
        local panel = SelectLoginPanel:create(loginInfo, context)
        panel:setPhoneLoginCompleteCallback(function( openId,phoneNumber,accessToken )
            self:onPhoneLoginComplete(openId,phoneNumber,accessToken)
            dcAccountType(PlatformAuthEnum.kPhone)
        end)
        panel:setSelectSnsCallback(function( authEnum )
            self:onSelectSnsLogin(authEnum)
            dcAccountType(authEnum)
        end)
        panel:setBackCallback(function( ... )
            self:onCancel()
        end)
        panel:popout()

    elseif PlatformConfig:hasLoginAuthConfig(PlatformAuthEnum.kPhone) then
        object = PlatformAuthEnum.kPhone

        local panel = PhoneLoginPanel:create(loginInfo, AccountBindingSource.FROM_LOGIN)
        panel:setPhoneLoginCompleteCallback(function( openId,phoneNumber,accessToken )
            self:onPhoneLoginComplete(openId,phoneNumber,accessToken)
            dcAccountType(PlatformAuthEnum.kPhone)
        end)
        panel:setBackCallback(function( ... )
            self:onCancel()
        end)
        panel:popout()

    else--直接登录
        local authEnum = SnsProxy:getAuthorizeType()
        self:dispatchEvent(Event.new(self.Events.kSnsLogin,authEnum,self))

        dcAccountType(authEnum)
    end

end

return Processor