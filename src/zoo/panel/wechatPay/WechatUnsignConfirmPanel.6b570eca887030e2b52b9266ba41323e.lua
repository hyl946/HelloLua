local Button = require "zoo.panel.phone.Button"

local WechatUnsignConfirmPanel = class(BasePanel)

function WechatUnsignConfirmPanel:create()
    local panel = WechatUnsignConfirmPanel.new()
    panel:loadRequiredResource("ui/ali_payment.json")
    panel:init()

    return panel
end

function WechatUnsignConfirmPanel:init()
    self.ui = self:buildInterfaceGroup("AliUnSignPanel")
    BasePanel.init(self, self.ui)

    self:initButtons()
    self:initCloseButton()
    self:initText()
end

function WechatUnsignConfirmPanel:initButtons()
    self.btnConfirm = GroupButtonBase:create(self.ui:getChildByName("btnConfirm"))
    self.btnConfirm:setString(Localization:getInstance():getText("accredit.unwind.button.2"))
    self.btnConfirm:setColorMode(kGroupButtonColorMode.orange)
    self.btnConfirm:addEventListener(DisplayEvents.kTouchTap, function ()
        self:sendUnSignRequest()
        DcUtil:UserTrack({ category='wechat_mm_accredit', sub_category = 'wechat_mm_cancel', t1 = "1"})
    end)

    self.btnCancel = GroupButtonBase:create(self.ui:getChildByName("btnCancel"))
    self.btnCancel:setString(Localization:getInstance():getText("accredit.unwind.button.1"))
    self.btnCancel:addEventListener(DisplayEvents.kTouchTap, function ()
        self:onCloseBtnTapped()
        DcUtil:UserTrack({ category='wechat_mm_accredit', sub_category = 'wechat_mm_cancel', t1 = "2"})
    end)

    self.panelTitle = TextField:createWithUIAdjustment(self.ui:getChildByName("panelTitleSize"), self.ui:getChildByName("panelTitle"))
    self.ui:addChild(self.panelTitle)
    self.panelTitle:setString(Localization:getInstance():getText("wechat.kf.off.confirm.0"))-- "解约支付宝快付 "
end

function WechatUnsignConfirmPanel:initCloseButton()
    self.closeBtn = self.ui:getChildByName("btnClose")
    self.closeBtn:setTouchEnabled(true, 0, true)
    self.closeBtn:setButtonMode(true)
    self.closeBtn:addEventListener(DisplayEvents.kTouchTap, 
        function() 
            self:onCloseBtnTapped()
            DcUtil:UserTrack({ category='wechat_mm_accredit', sub_category = 'wechat_mm_cancel', t1 = "2"})
            if _G.isLocalDevelopMode then printx(0, "btnclose tapped!!!!!!!!!!") end
        end)
end

function WechatUnsignConfirmPanel:onKeyBackClicked(...)
    DcUtil:UserTrack({ category='wechat_mm_accredit', sub_category = 'wechat_mm_cancel', t1 = "2"})
    BasePanel.onKeyBackClicked(self)
end

function WechatUnsignConfirmPanel:initText()
    self.ui:getChildByName("tip1"):setString(localize("wechat.kf.off.confirm.1"))-- "确定要解除支付宝快付的授权吗？")
    self.ui:getChildByName("tip2"):setString(localize("wechat.kf.off.confirm.2")) -- "支付宝快付为您提供的是一种快捷的支付方式。")
    self.ui:getChildByName("tip3"):setString(localize("wechat.kf.off.confirm.3")) -- "1.安全保障，仅限小额支付。")
    self.ui:getChildByName("tip4"):setString(localize("wechat.kf.off.confirm.4")) -- "2.此操作仅授权给开心消消乐。")
end

function WechatUnsignConfirmPanel:sendUnSignRequest()
    if self.isRequesting then
        return
    end
    local function onSuccess(event)
        self.isRequesting = false
        if self.successCallback then
            self.successCallback()
        end

        UserManager.getInstance().userExtend.wxIngameState = 2
        UserService.getInstance().userExtend.wxIngameState = 2
        if NetworkConfig.writeLocalDataStorage then Localhost:getInstance():flushCurrentUserData()
        else if _G.isLocalDevelopMode then printx(0, "Did not write user data to the device.") end end

        CommonTip:showTip(localize("wechat.kf.off.ok").."\n"..localize("wechat.kf.off.ok.text"), --"解除成功!在设置中可以重新开启支付宝快付噢！", 
                                                "positive", nil, 3)
        self:onCloseBtnTapped()
        DcUtil:UserTrack({ category='wechat_mm_accredit', sub_category = 'wechat_mm_cancel', t2 = "1"})
    end

    local function onError(event)
        self.isRequesting = false
        CommonTip:showTip(localize("wechat.kf.off.fail")..'\n'..localize("wechat.kf.off.fail.text"), "negative", nil, 3)
        self:onCloseBtnTapped()
        DcUtil:UserTrack({ category='wechat_mm_accredit', sub_category = 'wechat_mm_cancel', t2 = "2"})
    end

    local function onCancel()
        self.isRequesting = false
        self:onCloseBtnTapped()
        DcUtil:UserTrack({ category='wechat_mm_accredit', sub_category = 'wechat_mm_cancel', t2 = "2"})
    end

    local http = WxDeleteContract.new(true)
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
                        DcUtil:UserTrack({ category='wechat_mm_accredit', sub_category = 'wechat_mm_cancel', result = "2"})
                    end, 
                    kRequireNetworkAlertAnimation.kDefault)

    self.isRequesting = true
    if _G.isLocalDevelopMode then printx(0, "to send the unsign panel!!!!!!!!!!!!!!!!!") end
end

function WechatUnsignConfirmPanel:popout(successCallback)
    self:setPositionForPopoutManager()

    self.allowBackKeyTap = true
    self.successCallback = successCallback
    PopoutManager:sharedInstance():add(self, true, false)
end

function WechatUnsignConfirmPanel:popoutShowTransition()
    self.allowBackKeyTap = true
end

function WechatUnsignConfirmPanel:onCloseBtnTapped()
    PopoutManager:sharedInstance():remove(self, true)
end

return WechatUnsignConfirmPanel