local Http = require 'zoo.panel.RealName.Http'

local function isGuest( ... )
    if (not _G.sns_token) or (_G.sns_token.authorType == PlatformAuthEnum.kGuest) then
        return true
    else
        return false
    end

end

local OneKeyBindingPanel = class(BasePanel)

function OneKeyBindingPanel:create(successCallback, failCallback)
    local panel = OneKeyBindingPanel.new()
    panel:loadRequiredResource("ui/real_name.json")
    panel:init(successCallback, failCallback)
    return panel
end

function OneKeyBindingPanel:init(successCallback, failCallback)
    local ui = self:buildInterfaceGroup("realname/onekey")
	BasePanel.init(self, ui)

	self.successCallback = successCallback
    self.failCallback = failCallback

    self.closeBtn = self.ui:getChildByName('closeBtn')
    self.closeBtn:setTouchEnabled(true, 0, true)
    self.closeBtn:ad(DisplayEvents.kTouchTap, function () 
    	self:onCloseBtnTapped() 

    	DcUtil:UserTrack({ 
            category="ui",
            sub_category="authentication_bonding" ,
            bonding_result=-1
        })

    end)

    self.title = self.ui:getChildByName('title')
    self.title.fntFile = 'fnt/caption.fnt'
    self.title:changeFntFile('fnt/caption.fnt')
    self.titleSize = self.ui:getChildByName('titleSize')
	self.title = TextField:createWithUIAdjustment(self.titleSize, self.title)    
	self.ui:addChild(self.title)

    self.label1 = self.ui:getChildByName('label1')
    self.label2 = self.ui:getChildByName('label2')

    self.label1:setString(localize('authentication.feature.bonding.detail2'))
    self.label2:setString(localize('authentication.feature.bonding.detail3'))

    if isGuest() then
        self.title:setString(localize('authentication.feature.bonding.title'))
    else
        self.title:setString(localize('authentication.feature.bonding.title1'))
    end

    self.btn = self.ui:getChildByName('btn')
    self.btn = GroupButtonBase:create(self.btn)
    if isGuest() then
        self.btn:setString(localize('authentication.feature.bonding.button'))
    else
        self.btn:setString(localize('authentication.feature.bonding.button1'))
    end

    self.btn:ad(DisplayEvents.kTouchTap, preventContinuousClick(function () 
    	PaymentNetworkCheck.getInstance():check(function ()
    		self:onBtnTapped() 
        end, function ()
            CommonTip:showTip(localize("forcepop.tip3"))

            DcUtil:UserTrack({ 
	            category="ui",
	            sub_category="authentication_bonding" ,
	            bonding_result=0
	        })

        end)
    end, 1))
end

function OneKeyBindingPanel:_close()
	if self.isDisposed then
		return 
	end
	self.allowBackKeyTap = false    
	PopoutManager:sharedInstance():remove(self)
end

function OneKeyBindingPanel:popout()
    self:scaleAccordingToResolutionConfig()
    self:setPositionForPopoutManager()
    self:setPositionX(self:getPositionX() + 0)
	PopoutQueue:sharedInstance():push(self, true)
	self.allowBackKeyTap = true
end

function OneKeyBindingPanel:onCloseBtnTapped( ... )
    self:_close()
    if self.failCallback then
    	self.failCallback()
    end
end

function OneKeyBindingPanel:onBtnTapped( ... )
	if self.isDisposed then return end
	Http:oneKeyBind(function ( openId,phoneNumber,accessToken )
        Http:connect(openId,phoneNumber,accessToken, function ( ... )
            DcUtil:UserTrack({ 
                category="ui",
                sub_category="authentication_bonding" ,
                bonding_result=1
            })
            Localhost:writeCachePhoneListData(phoneNumber)
            if isGuest() then
                CommonTip:showTip(localize('authentication.feature.bonding.tip1'), 'positive')
            else
                CommonTip:showTip(localize('authentication.feature.bonding.tip2'), 'positive')
            end
            self:_close()
            if self.successCallback then
                self.successCallback(...)
            end
        end, function ( ... )
            CommonTip:showTip('绑定手机号失败')
        end, function ( ... )
        
        end)
	end, function ( errCode, errMsg, data )
		if type(data) == 'table' and tostring(data.ret) == '221' then
			CommonTip:showTip(localize('authentication.feature.bonding.tip'))

			DcUtil:UserTrack({ 
	            category="ui",
	            sub_category="authentication_bonding" ,
	            bonding_result=-2
	        })

			self:onCloseBtnTapped()
		else
			CommonTip:showTip('绑定手机号失败')
		end
	end)
end

return OneKeyBindingPanel
