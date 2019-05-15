local Http = require 'zoo.panel.RealName.Http'

local function isGuest( ... )
    if (not _G.sns_token) or (_G.sns_token.authorType == PlatformAuthEnum.kGuest) then
        return true
    else
        return false
    end
end

local OneKeyBinding360Panel = class(BasePanel)
function OneKeyBinding360Panel:create(successCallback, failCallback)
    local panel = OneKeyBinding360Panel.new()
    panel:loadRequiredResource("ui/real_name.json")
    panel:init(successCallback, failCallback)
    return panel
end

function OneKeyBinding360Panel:init(successCallback, failCallback)
    local ui = self:buildInterfaceGroup("realname/onekey360")
	BasePanel.init(self, ui)

	self.successCallback = successCallback
    self.failCallback = failCallback

    self.closeBtn = self.ui:getChildByName('closeBtn')
    self.closeBtn:setTouchEnabled(true, 0, true)
    self.closeBtn:ad(DisplayEvents.kTouchTap, function () 
    	self:onCloseBtnTapped() 
    end)

    self.title = self.ui:getChildByName('title')
    self.title.fntFile = 'fnt/caption.fnt'
    self.title:changeFntFile('fnt/caption.fnt')
    self.titleSize = self.ui:getChildByName('titleSize')
	self.title = TextField:createWithUIAdjustment(self.titleSize, self.title)    
	self.ui:addChild(self.title)

    self.title:setString(localize('authentication.360.bonding.title'))

    self.label1 = self.ui:getChildByName('label1')
    self.label1:setString(localize('authentication.360.bonding.detail'))

    self.btn = self.ui:getChildByName('btn')
    self.btn = GroupButtonBase:create(self.btn)
    self.btn:setString(localize('authentication.feature.bonding.button1'))

    self.btn:ad(DisplayEvents.kTouchTap, preventContinuousClick(function () 
    	PaymentNetworkCheck.getInstance():check(function ()
    		self:onBtnTapped() 
        end, function ()
            CommonTip:showTip(localize("forcepop.tip3"))
        end)
    end, 1))
end

function OneKeyBinding360Panel:_close()
	if self.isDisposed then
		return 
	end
	self.allowBackKeyTap = false    
	PopoutManager:sharedInstance():remove(self)
end

function OneKeyBinding360Panel:popout()
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
    self:setPositionX(self:getPositionX() + 0)
	PopoutQueue:sharedInstance():push(self, true)
	self.allowBackKeyTap = true
end

function OneKeyBinding360Panel:onCloseBtnTapped( ... )
    self:_close()
    if self.failCallback then
    	self.failCallback()
    end
end

function OneKeyBinding360Panel:onBtnTapped( ... )
	if self.isDisposed then return end

    local authorizeType = PlatformAuthEnum.k360

    local function onSNSLoginResult( status, result )
        if status == SnsCallbackEvent.onSuccess and result then
            local snsInfo = {
                snsName = result.nick,
                name = result.nick,
                headUrl = result.headUrl,
            }
            self:bindConnect(authorizeType, snsInfo, result)
        else
            CommonTip:showTip("360绑定账号登录失败！","negative")
            if self.failCallback then
                self.failCallback()
            end
        end
    end

    -- 登录
    local oldAuthorizeType = SnsProxy:getAuthorizeType()
    SnsProxy:setAuthorizeType(authorizeType)
    SnsProxy:login(onSNSLoginResult)
    SnsProxy:setAuthorizeType(oldAuthorizeType)
end

function OneKeyBinding360Panel:bindConnect(authorizeType, snsInfo, sns_token)
    if not snsInfo then
        snsInfo = { snsName = Localization:getInstance():getText("game.setting.panel.use.device.name.default") }
    end
    local function callback(success)
        if self.isDisposed then return end
        if success then
            self:_close()
            if self.successCallback then self.successCallback() end
        else
            if self.failCallback then self.failCallback() end
        end
    end
    
    local function onConnectFinish()
        callback(true)
    end
    local function onConnectError()
        callback(false)
    end
    local function onConnectCancel()
        callback(false)
    end
    AccountBindingLogic:bindConnect(authorizeType, snsInfo, sns_token, onConnectFinish, onConnectError, onConnectCancel, AccountBindingSource.ACCOUNT_SETTING)
end

return OneKeyBinding360Panel
