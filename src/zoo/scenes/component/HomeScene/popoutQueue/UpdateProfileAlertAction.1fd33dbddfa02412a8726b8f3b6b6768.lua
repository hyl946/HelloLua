---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2018-01-26 15:34:52
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   Administrator
-- @Last Modified time: 2018-01-30 15:16:16
---------------------------------------------------------------------------------------
UpdateProfileAlertAction = class(HomeScenePopoutAction)

function UpdateProfileAlertAction:ctor()
	self.name = "UpdateProfileAlertAction"
    self:setSource(AutoPopoutSource.kInitEnter, AutoPopoutSource.kEnterForeground)
end

function UpdateProfileAlertAction:checkCache(cache)
	local snsProfile = SnsProxy.profile
	local profile = UserManager:getInstance().profile

	local canPop = SnsProxy:getAuthorizeType() == PlatformAuthEnum.kWechat 
					and LoginAlertModel:getInstance().snsBindToExistAccount
					and snsProfile and snsProfile.nick and snsProfile.nick ~= ""
					and (snsProfile.nick ~= profile:getDisplayName() or snsProfile.headUrl ~= profile.headUrl)

	if self.debug then
		canPop = true
	end

    self:onCheckCacheResult(canPop)
end

function UpdateProfileAlertAction:popout(next_action)
	local snsProfile = SnsProxy.profile
	local profile = UserManager:getInstance().profile or {}

	if self.debug then
		snsProfile = {nick = "nick", headUrl = "1", uid = 1, authorType = 1}
	end

	require "zoo.panel.loginAlert.UpdateProfileAlertPanel"

	local uid = UserManager.getInstance().uid
	local oldProfile = {name = profile:getDisplayName(), headUrl = profile.headUrl, uid = uid}
	local newProfile = {name = snsProfile.nick, headUrl = snsProfile.headUrl, uid = uid, authorType = SnsProxy:getAuthorizeType()}
	
	local panel = UpdateProfileAlertPanel:create(oldProfile, newProfile)
	panel:popout(next_action)

	LoginAlertModel:getInstance().snsBindToExistAccount = false
end