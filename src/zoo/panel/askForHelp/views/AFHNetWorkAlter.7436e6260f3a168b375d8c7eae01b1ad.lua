
local AFHNetWorkAlter = class(BasePanel)

function AFHNetWorkAlter:create(selectCallBack)
	local panel = AFHNetWorkAlter.new()
	panel:loadRequiredResource("ui/AskForHelp/panel_ask_for_help.json")
	panel:init(selectCallBack)
	return panel
end

function AFHNetWorkAlter:unloadRequiredResource( ... )
end

function AFHNetWorkAlter:init(selectCallBack)
	self.ui = self:buildInterfaceGroup("AskForHelp/interface/NetWorkAlter")
	BasePanel.init(self, self.ui)

	assert(type(selectCallBack) == "function")
	self.selectCallBack = selectCallBack

	self.cnt = 2

	local content = self.ui:getChildByName("tips")
	content:setString(Localization:getInstance():getText("askforhelp.panels.networkalter.content", {endl = "\n"}))

	self.btnRetry = GroupButtonBase:create(self.ui:getChildByName("btnRetry"))
	self.btnRetry:addEventListener(DisplayEvents.kTouchTap,function( ... ) self:onRetry() end)
	self.btnRetry:setString("重新联网")

	self.btnCancel = GroupButtonBase:create(self.ui:getChildByName("btnCancel"))
	self.btnCancel:addEventListener(DisplayEvents.kTouchTap,function( ... ) self:onCancel() end)
	self.btnCancel:setString("忽略")

	self:refresh()
end

function AFHNetWorkAlter:refresh( ... )
end

function AFHNetWorkAlter:onRetry()
	self.cnt = self.cnt - 1
	self.btnRetry:setEnabled(false)

	if self.cnt >= 0 then
		local function onNetCheckSuccess()
			self.selectCallBack(true)
			return self:_close()
		end

		local function onNetCheckFail()
			if self.cnt <= 0 then
				local function onFinished()
					self.selectCallBack(false)
					self:_close()
				end
				return CommonTip:showTip(Localization:getInstance():getText('askforhelp.panels.networkalter.retryfailed'), 'negative', onFinished)
			else
				local function onFinished()
					self.btnRetry:setEnabled(true)
				end
				return CommonTip:showTip(Localization:getInstance():getText('askforhelp.panels.networkalter.retryagain'), 'negative', onFinished)
			end
		end
		PaymentNetworkCheck:getInstance():check(onNetCheckSuccess, onNetCheckFail)
	else
		local function onFinished()
			self.selectCallBack(false)
			self:_close()
		end
		return CommonTip:showTip(Localization:getInstance():getText('askforhelp.panels.networkalter.retryfailed'), 'negative', onFinished)
	end
end

function AFHNetWorkAlter:onCancel( ... )
	self.selectCallBack(false)
	return self:_close()
end

function AFHNetWorkAlter:popout()
	PopoutManager:sharedInstance():addWithBgFadeIn(self, true, false, false)
	self.allowBackKeyTap = true

	local visibleSize = Director.sharedDirector():getVisibleSize()
	local visibleOrigin = Director:sharedDirector():getVisibleOrigin()

	local bounds = self.ui:getChildByName("_bg"):getGroupBounds()

	self:setPositionX((visibleSize.width - bounds.size.width) / 2)
	self:setPositionY(-visibleSize.height/2 + bounds.size.height/2)
end

function AFHNetWorkAlter:onKeyBackClicked()
	self:_close()
	return self.selectCallBack(false)
end

function AFHNetWorkAlter:_close()
	PopoutManager:sharedInstance():remove(self)
	self.allowBackKeyTap = false
end

function AFHNetWorkAlter:dispose( ... )
	BasePanel.dispose(self)
end

return AFHNetWorkAlter