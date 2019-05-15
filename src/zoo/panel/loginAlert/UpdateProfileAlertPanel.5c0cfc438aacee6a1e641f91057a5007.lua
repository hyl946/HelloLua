---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2018-01-26 14:11:15
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   Administrator
-- @Last Modified time: 2018-02-06 18:27:59
---------------------------------------------------------------------------------------
UpdateProfileAlertPanel = class(BasePanel)

function UpdateProfileAlertPanel:create(oldProfile, newProfile)
	local panel = UpdateProfileAlertPanel.new()
	panel:loadRequiredResource("ui/LoginAlertPanel.json")
	panel:init(oldProfile, newProfile)
	return panel
end

function UpdateProfileAlertPanel:init(oldProfile, newProfile)
	self.newProfile = newProfile
	self.oldProfile = oldProfile

	self.ui = self:buildInterfaceGroup("LoginAlertPanel/UpdateProfileAlertPanel")
	BasePanel.init(self, self.ui)

	local contentX, contentY, scale = LogicUtil.getFullScreenUIPosXYScale()
	self:setScale(scale)
	self:setPositionXY(contentX, 0)

	self.ui:getChildByName('top_label'):setString(localize("new.photo.context"))

	self.cancelBtn = GroupButtonBase:create(self.ui:getChildByName('cancel_btn'))
	self.cancelBtn:setString(localize("new.photo.btn2"))
	self.cancelBtn:setColorMode(kGroupButtonColorMode.blue)
	self.cancelBtn:addEventListener(DisplayEvents.kTouchTap, function()
		self:onCancelBtnTapped()
	end)
	self.confirmBtn = GroupButtonBase:create(self.ui:getChildByName('confirm_btn'))
	self.confirmBtn:setString(localize("new.photo.btn1"))
	self.confirmBtn:addEventListener(DisplayEvents.kTouchTap, function()
		self:onConfirmBtnTapped()
	end)

	local oldProfileUI = self.ui:getChildByName('old_profile')
	self:buidUserProfileItem(oldProfileUI, oldProfile, false)
	local newProfileUI = self.ui:getChildByName('new_profile')
	self:buidUserProfileItem(newProfileUI, newProfile, true)
end

function UpdateProfileAlertPanel:buidUserProfileItem(ui, profile, isNew)
	if isNew then
		ui:getChildByName("flag_old"):setVisible(false)
	else
		ui:getChildByName("flag_new"):setVisible(false)
	end
	ui:getChildByName("username"):setString(profile.name)
	local headC = ui:getChildByName("head"):getChildByName("bg")
	LogicUtil.loadUserHeadIcon(profile.uid, headC, profile.headUrl)
end

function UpdateProfileAlertPanel:onCancelBtnTapped()
	self:_close()
end

function UpdateProfileAlertPanel:onConfirmBtnTapped()
	local authorizeType = self.newProfile.authorType
	local snsName = self.newProfile.name
	local snsHeadUrl = self.newProfile.headUrl
	local snsPlatform = PlatformConfig:getPlatformAuthName(authorizeType)

	local profile = UserManager:getInstance().profile
	profile:setDisplayName(userInput)
	profile:setSnsInfo(authorizeType, snsName, snsHeadUrl, snsName, snsHeadUrl)

	local snsPlatform = PlatformConfig:getPlatformAuthName(authorizeType)
	local http = UpdateProfileHttp.new()
	http:load(HeDisplayUtil:urlEncode(snsName), snsHeadUrl, snsPlatform, HeDisplayUtil:urlEncode(snsName), true)
	
	self:_close()
end

function UpdateProfileAlertPanel:popout(onCloseCallback)
	PopoutManager:sharedInstance():add(self, true, false)
	self:setToScreenCenter()
	self.onCloseCallback = onCloseCallback
end

function UpdateProfileAlertPanel:_close()
	if self.isDisposed then return end
	PopoutManager:sharedInstance():remove(self)

	if self.onCloseCallback then self.onCloseCallback() end
end

function UpdateProfileAlertPanel:onCloseBtnTapped()
	self:_close()
end