
local Title = class(EventDispatcher)

Title.Events = {
	kBackTap = "backTap"
}

function Title:create( ui,hasBackLink )
	local title = Title.new()
	title:init(ui,hasBackLink)
	return title
end

function Title:init( ui,hasBackLink )
	self.ui = ui
	self.titleText = self.ui:getChildByName("text")
	self.titleText:setVerticalAlignment(kCCVerticalTextAlignmentCenter)

	self:setHasBackLink(hasBackLink)

	ui:addEventListener(Events.kDispose,function( ... )
		self:removeAllEventListeners()
	end)
end

function Title:setTextMode( mode,isSelectLoginPanel )
	if mode == PhoneLoginMode.kDirectLogin then
		if isSelectLoginPanel then
			self.ui:getChildByName("text"):setString(Localization:getInstance():getText("login.panel.title.1"))
		else
			self.ui:getChildByName("text"):setString("手机号登录")
		end
	elseif mode == PhoneLoginMode.kChangeLogin then
		self.ui:getChildByName("text"):setString(Localization:getInstance():getText("login.panel.title.2"))					
	elseif mode == PhoneLoginMode.kBindingOldLogin or 
		mode == PhoneLoginMode.kBindingNewLogin then
		self.ui:getChildByName("text"):setString(Localization:getInstance():getText("login.panel.title.5"))
	elseif mode == PhoneLoginMode.kAddBindingLogin then
		if isSelectLoginPanel then
			self.ui:getChildByName("text"):setString(Localization:getInstance():getText("login.panel.title.1"))
		else
			self.ui:getChildByName("text"):setString("手机号登录")
		end
	end
end

function Title:setHasBackLink( hasBackLink )
	local backLink = self.ui:getChildByName("back")

	backLink:setTouchEnabled(true)
	backLink:setButtonMode(true)
	backLink:addEventListener(DisplayEvents.kTouchTap, function( ... )
		if not backLink:isVisible() then
			return
		end
		if self.createBackConfirmPanelFunc then
			local panel = self.createBackConfirmPanelFunc(function( ... )
				self:dispatchEvent(Event.new(Title.Events.kBackTap, nil, self))
			end)
			panel:popout()
		else 
			self:dispatchEvent(Event.new(Title.Events.kBackTap, nil, self))
		end
	end)

	if hasBackLink then
		backLink:setVisible(true)
		backLink:setChildrenVisible(true,false)

		local backLinkText = backLink:getChildByName("text")
		backLinkText:setVerticalAlignment(kCCVerticalTextAlignmentCenter)
		backLinkText:setString("<" .. Localization:getInstance():getText("login.panel.button.4")) --返回
	else
		backLink:setVisible(false)
		backLink:setChildrenVisible(false,false)
	end

end

function Title:setCreateBackConfirmPanelFunc( createBackConfirmPanelFunc )
	self.createBackConfirmPanelFunc = createBackConfirmPanelFunc
end

return Title