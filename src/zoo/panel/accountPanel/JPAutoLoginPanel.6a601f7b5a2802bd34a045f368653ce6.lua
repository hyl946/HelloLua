--=====================================================
-- JPAutoLoginPanel  
-- by zhijian.li
-- (c) copyright 2009 - 2017, www.happyelements.com
-- All Rights Reserved. 
--=====================================================
-- filename:  JPAutoLoginPanel.lua 
-- author:    zhijian.li
-- e-mail:    zhijian.li@happyelements.com
-- created:   2017/2/7
-- descrip:   微信精品包 异账号登录时 不能使用缓存的登录账号信息
--=====================================================
local Panel = class(BasePanel)

function Panel:ctor()

end

function Panel:create(onAutoLoginCallback, onChangeAccountCallback)
	local panel = Panel.new()
	panel:loadRequiredResource("ui/login.json")	
	panel:init(onAutoLoginCallback, onChangeAccountCallback)
	return panel
end

function Panel:init(onAutoLoginCallback, onChangeAccountCallback)
	self.ui = self:buildInterfaceGroup("preloadingscene_auto_login_panel_jp")
	BasePanel.init(self, self.ui)

	self.onAutoLoginCallback = onAutoLoginCallback
	self.onChangeAccountCallback = onChangeAccountCallback

	local loginPanel = self.ui:getChildByName("loginPanel")
	local switchBtn = self.ui:getChildByName("switchBtn")

	self:initLoginPanel(loginPanel)

	local function onAutoLoginTapped(evt)
		self:onAutoLoginTapped(evt)
	end
	loginPanel:setTouchEnabled(true)
	loginPanel:ad(DisplayEvents.kTouchTap, onAutoLoginTapped)

	local function onSwitchBtnTapped(evt)
		self:onSwitchBtnTapped(evt)
	end

	switchBtn:setButtonMode(true)
	switchBtn:setTouchEnabled(true)
	switchBtn:ad(DisplayEvents.kTouchTap, onSwitchBtnTapped)
end

function Panel:initLoginPanel(panelUi)
	local loadingAnim = panelUi:getChildByName("animation")
	local count = 0
	local function playAnimate()
		loadingAnim:setChildrenVisible(false, true)
		if count > 0 then
			loadingAnim:getChildByName("a"..tostring(count)):setVisible(true)
		end
		count = count + 1
		if count > 3 then count = 0 end
	end
	local animate = CCSequence:createWithTwoActions(CCCallFunc:create(playAnimate), CCDelayTime:create(0.3))
	loadingAnim:runAction(CCRepeatForever:create(animate))

	local statusLabel_qq = panelUi:getChildByName("status_qq")
	local statusLabel_wx = panelUi:getChildByName("status_wx")
	local authorizeType = SnsProxy:getAuthorizeType()
	if authorizeType == PlatformAuthEnum.kJPQQ then
		statusLabel_qq:setVisible(true)
		statusLabel_wx:setVisible(false)
	elseif authorizeType == PlatformAuthEnum.kJPWX then 
		statusLabel_qq:setVisible(false)
		statusLabel_wx:setVisible(true)
	else
		assert(false, "impossible")
	end
end

function Panel:onAutoLoginTapped(evt)
	if self.onAutoLoginCallback then self.onAutoLoginCallback() end
end

function Panel:onSwitchBtnTapped(evt)
	if self.onChangeAccountCallback then self.onChangeAccountCallback() end
end

function Panel:onCloseBtnTapped()

end

function Panel:unloadRequiredResource()

end

return Panel