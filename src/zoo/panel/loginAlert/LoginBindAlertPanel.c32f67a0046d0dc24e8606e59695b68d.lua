---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2018-01-25 17:38:53
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   Administrator
-- @Last Modified time: 2018-02-02 19:53:47
---------------------------------------------------------------------------------------
LoginBindAlertPanel = class(BasePanel)

local PanelStatus = {
	kNone = 0,
	kBinding = 1,
	kLogin = 2,
}

local model = LoginAlertModel:getInstance()

function LoginBindAlertPanel:create()
	local panel = LoginBindAlertPanel.new()
	panel:loadRequiredResource("ui/LoginAlertPanel.json")
	panel:init()
	return panel
end

function LoginBindAlertPanel:init()
	self.ui = self:buildInterfaceGroup("LoginAlertPanel/LoginNewAccountAlertPanel")
	BasePanel.init(self, self.ui)

	self.panelStatus = PanelStatus.kNone

	local contentX, contentY, scale = LogicUtil.getFullScreenUIPosXYScale()
	self:setScale(scale)
	self:setPositionXY(contentX, 0)

	self.closeBtn = self.ui:getChildByName("closeBtn")
	self.closeBtn:setTouchEnabled(true)
	self.closeBtn:setButtonMode(true)
	self.closeBtn:ad(DisplayEvents.kTouchTap, function ( ... )
		self:onCloseBtnTapped()
	end)
    self.loginBtn = self.ui:getChildByName('loginBtn')
    self.loginBtn:setTouchEnabled(true, 0, true)
	self.loginBtn:addEventListener(DisplayEvents.kTouchTap, function()
		self:onClkLoginBtn()
	end)

	self.bindBtn = GroupButtonBase:create(self.ui:getChildByName('toAdviceLoginBtn'))
	self.bindBtn:setString(localize("new.account.btn1"))
	self.bindBtn:addEventListener(DisplayEvents.kTouchTap, function()
		self:onClkBindBtn()
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

	setNum('gold', tostring(model.adviceLoginInfo.cash) )
	setNum('level', tostring(model.adviceLoginInfo.topLevelId))

	local username_txt = '消消乐玩家'

	if model.adviceLoginInfo.profile and model.adviceLoginInfo.profile.name then
		username_txt = nameDecode(model.adviceLoginInfo.profile.name) or username_txt
	end

	local username = self.ui:getChildByName('username')

	username_txt = TextUtil:ensureTextWidth( username_txt, username:getFontSize(), username:getDimensions() )
	
	username:setString(tostring(username_txt))

	local curAccount = PlatformConfig:getPlatformNameLocalization( model.currentLoginInfo.loginType ) or ""
	local textLabel = self.ui:getChildByName('top_label')
	textLabel:setVisible(false)
	local width = textLabel:getDimensions().width
	local pos = textLabel:getPosition()
	local str = localize("new.account.context1", {account = curAccount, num = model.currentLoginInfo.topLevelId})
	local richText = TextUtil:buildRichText(str, width, textLabel:getFontName(), textLabel:getFontSize(), textLabel:getColor())
	richText:setPosition(ccp(pos.x, pos.y))
	self.ui:addChildAt(richText, textLabel:getZOrder())

	local uid = model.adviceLoginInfo.uid
	local headC = self.ui:getChildByName("rightHeadImg"):getChildByName("bg")
	self.ui:getChildByPath('rightHeadImg/top'):setVisible(false)
	
	local headUrl = model.adviceLoginInfo.headUrl 
	LogicUtil.loadUserHeadIcon(uid, headC, headUrl)
	self:refresh()
end

function LoginBindAlertPanel:refresh( ... )
	-- body
end

function LoginBindAlertPanel:onClkBindBtn()
	if self.panelStatus ~= PanelStatus.kNone then
		return
	end
	model:log(9)
	self.panelStatus = PanelStatus.kBinding
	local function onSuccess( ... )
		model:log(10)
		if self.isDisposed then
			return
		end
		self.panelStatus = PanelStatus.kNone
		self:_close()
		model.snsBindToExistAccount = true
		model:closeAlertPanel()
		-- HomeScenePopoutQueue:insert(UpdateProfileAlertAction.new())
		Notify:dispatch("AutoPopoutEventAwakenAction", UpdateProfileAlertAction)
	end
	local function onError( ... )
		self.panelStatus = PanelStatus.kNone
	end
	model:bindAccount(onSuccess, onError)
end

function LoginBindAlertPanel:onClkLoginBtn()
	if self.panelStatus ~= PanelStatus.kNone then
		return
	end
	self.panelStatus = PanelStatus.kLogin

	model:log(1)
	-- 通知后端跳过提醒
	local http = OpNotifyHttp.new()
	http:load(OpNotifyType.kSkipBindAccountTip)

	require('zoo.panel.loginAlert.ConfirmPanel'):create(function ( ... )
		if self.isDisposed then
			return
		end
		self.panelStatus = PanelStatus.kNone
		self:_close()
		model:closeAlertPanel()
	end, function ( ... )
		self.panelStatus = PanelStatus.kNone
	end):popout()
end

function LoginBindAlertPanel:onCloseBtnTapped( ... )
	if self.panelStatus ~= PanelStatus.kNone then
		return
	end
	model:writeLoginInfo()
	model:log(2)
	--到账号登录页面
    self:_close()
	model:backToLogin()
end

function LoginBindAlertPanel:_close()
	if self.isDisposed then return end
	PopoutManager:sharedInstance():remove(self)
end

function LoginBindAlertPanel:popout()
	PopoutManager:sharedInstance():add(self, true, false)
	self:setToScreenCenter()
	model:log(0)
end

return LoginBindAlertPanel