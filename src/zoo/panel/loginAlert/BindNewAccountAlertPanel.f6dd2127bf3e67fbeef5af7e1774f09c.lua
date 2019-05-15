---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2018-01-26 17:05:09
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   Administrator
-- @Last Modified time: 2018-02-02 20:12:32
---------------------------------------------------------------------------------------
BindNewAccountAlertPanel = class(BasePanel)

local PanelStatus = {
	kNone = 0,
	kBinding = 1,
}

function BindNewAccountAlertPanel:create(userData, bindCallback, cancelCallback)
	local panel = BindNewAccountAlertPanel.new()
	panel:loadRequiredResource("ui/LoginAlertPanel.json")
	panel:init(userData, bindCallback, cancelCallback)
	return panel
end

function BindNewAccountAlertPanel:init(userData, bindCallback, cancelCallback)
	self.ui = self:buildInterfaceGroup("LoginAlertPanel/BindNewAccountAlertPanel")
	BasePanel.init(self, self.ui)

	self.bindCallback = bindCallback
	self.cancelCallback = cancelCallback

	self.panelStatus = PanelStatus.kNone

	local contentX, contentY, scale = LogicUtil.getFullScreenUIPosXYScale()
	self:setScale(scale)
	self:setPositionXY(contentX, 0)

	self.cancelBtn = GroupButtonBase:create(self.ui:getChildByName('cancel_btn'))
	self.cancelBtn:setString(localize("new.photo.btn2"))
	self.cancelBtn:setColorMode(kGroupButtonColorMode.blue)
	self.cancelBtn:addEventListener(DisplayEvents.kTouchTap, function()
		self:onCancelBtnTapped()
	end)
	self.confirmBtn = GroupButtonBase:create(self.ui:getChildByName('confirm_btn'))
	self.confirmBtn:setString(localize("new.account.btn1"))
	self.confirmBtn:addEventListener(DisplayEvents.kTouchTap, function()
		self:onConfirmBtnTapped()
	end)

	local function setNum( nodeName, num )
		local numUI = self.ui:getChildByName(nodeName)
		numUI:changeFntFile('fnt/level_seq_n_energy_cd.fnt')
		numUI:setText(num)
		numUI:setAnchorPoint(ccp(1, 0.5))
		numUI:setPositionX(410)
		numUI:setPositionY(numUI:getPositionY() - 46.25/2)
		numUI:setScale(1.8)

		if #tostring(num) > 5 then
			numUI:setScale(numUI:getScaleX() * 5 / (#tostring(num)) )
		end 
	end

	-- setNum('gold', tostring(model.adviceLoginInfo.cash) )
	setNum('level', tostring(userData.topLevelId))

	local username = self.ui:getChildByName('username')
	local username_txt = TextUtil:ensureTextWidth( userData.name, username:getFontSize(), username:getDimensions() )
	username:setString(tostring(username_txt))

	local curAccount = PlatformConfig:getPlatformNameLocalization( userData.loginType ) or ""
	local str = localize("new.account.context2", {account = curAccount})
	-- self.ui:getChildByName('top_label'):setString(localize("new.account.context2"))
	local textLabel = self.ui:getChildByName('top_label')
	textLabel:setVisible(false)
	local width = textLabel:getDimensions().width
	local pos = textLabel:getPosition()
	local richText = TextUtil:buildRichText(str, width, textLabel:getFontName(), textLabel:getFontSize(), textLabel:getColor())
	richText:setPosition(ccp(pos.x, pos.y))
	self.ui:addChildAt(richText, textLabel:getZOrder())

	local headC = self.ui:getChildByName("rightHeadImg"):getChildByName("bg")
	self.ui:getChildByPath('rightHeadImg/top'):setVisible(false)
	LogicUtil.loadUserHeadIcon( userData.uid, headC, userData.headUrl)
end

function BindNewAccountAlertPanel:onConfirmBtnTapped()
	self:_close()
	if self.bindCallback then self.bindCallback() end
end

function BindNewAccountAlertPanel:onCancelBtnTapped()
	self:_close()
	if self.cancelCallback then self.cancelCallback() end
end

function BindNewAccountAlertPanel:popout()
	PopoutManager:sharedInstance():add(self, true, false)
	self:setToScreenCenter()
end

function BindNewAccountAlertPanel:_close()
	if self.isDisposed then return end
	PopoutManager:sharedInstance():remove(self)
end

function BindNewAccountAlertPanel:onCloseBtnTapped()
	self:_close()
end