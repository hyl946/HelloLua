
local UIHelper = require 'zoo.panel.UIHelper'

_G.StoreTip = class(BasePanel)


function StoreTip:initAliQuickPush( ... )

	local ui = UIHelper:createUI("ui/store.json", "com.niu2x.store/ali-sign-tip-1")
	BasePanel.init(self, ui)

	self.button = GroupButtonBase:create(self.ui:getChildByPath('btnConfirm'))
	self.button:ad(DisplayEvents.kTouchTap, preventContinuousClick(function ( ... )
		if self.confirmHandler then
			self.confirmHandler()
		end
		self:_close()
	end))
	self.button:setString(localize('accredit.push.button'))
	self.button:setColorMode(kGroupButtonColorMode.blue)
	self.closeBtn = self.ui:getChildByPath('btnClose')
	self.closeBtn:setTouchEnabled(true)
	self.closeBtn:ad(DisplayEvents.kTouchTap, function ( ... )
		if self.isDisposed then return end
		self:onCloseBtnTapped()
	end)

	self.panelTitle = TextField:createWithUIAdjustment(self.ui:getChildByName("panelTitleSize"), self.ui:getChildByName("panelTitle"))
    self.ui:addChild(self.panelTitle)
    self.panelTitle:setString(Localization:getInstance():getText("accredit.push.title"))


    self.ui:getChildByPath('tip1'):setString(localize('accredit.push.text.1'))
    self.ui:getChildByPath('tip2'):setString(localize('accredit.push.text.2'))
    self.ui:getChildByPath('tip3'):setString(localize('accredit.push.text.3'))
    self.ui:getChildByPath('tip4'):setString(localize('accredit.push.text.4'))
end


function StoreTip:initAliQuickConfirm( ... )

	local ui = UIHelper:createUI("ui/store.json", "com.niu2x.store/ali-sign-tip-2")
	BasePanel.init(self, ui)
	self.button = GroupButtonBase:create(self.ui:getChildByPath('btnConfirm'))
	self.button:ad(DisplayEvents.kTouchTap, preventContinuousClick(function ( ... )
		if self.confirmHandler then
			self.confirmHandler()
		end
		self:_close()
	end))
	self.button:setString(localize('accredit.wind.button'))
	self.button:setColorMode(kGroupButtonColorMode.blue)
	self.closeBtn = self.ui:getChildByPath('btnClose')
	self.closeBtn:setTouchEnabled(true)
	self.closeBtn:ad(DisplayEvents.kTouchTap, function ( ... )
		if self.isDisposed then return end
		self:onCloseBtnTapped()
	end)

	self.panelTitle = TextField:createWithUIAdjustment(self.ui:getChildByName("panelTitleSize"), self.ui:getChildByName("panelTitle"))
    self.ui:addChild(self.panelTitle)
    self.panelTitle:setString(Localization:getInstance():getText("accredit.wind.title"))

    self.ui:getChildByPath('tip1'):setString(localize('accredit.wind.text.2'))
    self.ui:getChildByPath('tip3'):setString(localize('accredit.wind.text.3'))
    self.ui:getChildByPath('tip4'):setString(localize('accredit.wind.text.4'))

end


function StoreTip:setConfirmHandler( h )
	if self.isDisposed then return end
	self.confirmHandler = h
end

function StoreTip:setCancelHandler( h )
	if self.isDisposed then return end
	self.cancelHandler = h
end

function StoreTip:_close()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
end

function StoreTip:popout()
    self:scaleAccordingToResolutionConfig()


    self:setPositionForPopoutManager()
	PopoutManager:sharedInstance():add(self, true, nil, nil, nil, 200)
	self.allowBackKeyTap = true

end

function StoreTip:onCloseBtnTapped( ... )

	if self.isDisposed then return end

	if self.cancelHandler then
		self.cancelHandler()
	end

    self:_close()
end

function StoreTip:popAliQuickPush(params)

	local onConfirm = params.onConfirm
	local onCancel = params.onCancel
	local tip = StoreTip.new()
	tip:setConfirmHandler(onConfirm)
	tip:setCancelHandler(onCancel)
	tip:initAliQuickPush()
	tip:popout()
end

function StoreTip:popAliQuickConfirm(params)
	local onConfirm = params.onConfirm
	local onCancel = params.onCancel
	local tip = StoreTip.new()
	tip:setConfirmHandler(onConfirm)
	tip:setCancelHandler(onCancel)
	tip:initAliQuickConfirm()
	tip:popout()
end



return StoreTip
