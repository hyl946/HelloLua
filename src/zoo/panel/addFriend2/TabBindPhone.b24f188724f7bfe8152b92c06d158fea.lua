local SuperCls = require("zoo.panel.addFriend2.TabShow")
local TabBindPhone = class(SuperCls)

function TabBindPhone:create(ui, context)
	local tab = TabBindPhone.new()
	tab.ui = ui
	tab.context = context
	return tab
end

function TabBindPhone:init(ui)
	SuperCls.init(self, ui)

	self.title = self.ui:getChildByName("title")
    self.title:setPreferredSize(282, 48)
    self.title:setString(localize("add.friend.panel.tag.BindPhone.btn"))
    self.title:setAnchorPoint(ccp(0.5, 0.5))
    self.title:setPositionXY(302, 34)
    
	local tip = self.ui:getChildByName("tip")
	tip:setAnchorPoint(ccp(0.5, 0.5))
	tip:setString(localize("add_friend_dialog_tel"))
	tip:setPositionXY(313, -59)
	self.okBtn = GroupButtonBase:create(self.ui:getChildByName("btn"))
	self.okBtn:setString(localize("add_friend_title_tel"))
	self.okBtn:addEventListener(DisplayEvents.kTouchTap,function() self:openPhone() end)

	-- self:test()
end
--[[
	data.name
	data.phoneName
	data.uid, data.headUrl
]]

local testData = {{name = "1", phoneName = "2", uid = 11335, headUrl = 1}}
function TabBindPhone:test()
	setTimeOut(function()
		local panel = require("zoo.panel.addFriend2.ChoosePhoneUserPanel"):create(testData)
		panel:popout()
		if #testData < 19 then
			testData[#testData + 1] = {name = "1", phoneName = "2", uid = 11335, headUrl = 1}
			self:test()
		end
	end, 1)
end

function TabBindPhone:openPhone()
	if UserManager.getInstance().profile:isPhoneBound() then
		if _G.isLocalDevelopMode then printx(0, "goto get the phone's contact list!!!!!!!!!!!") end
		self:loadFriendsByContact()
	else
		if _G.isLocalDevelopMode then printx(0, "goto bind phone number!!!!!!!!!!!!") end
		AccountBindingLogic:bindNewPhone(nil, function()  self:loadFriendsByContact() end, AccountBindingSource.ADD_FRIEND)
	end
end

function TabBindPhone:loadFriendsByContact()
	if self.isDisposed or self.isRequestingPhoneFriends then
		return
	end
	local loadFriendsLogic = require("zoo.panel.addFriend2.LoadFriendsLogic"):create()

	local function onLoadSuccess(items4Show, remainingUids)
		if #items4Show == 0 then
			CommonTip:showTip(localize("add.friend.panel.add.phone.tip1"), "negative",nil, 2)
		else
			local panel = require("zoo.panel.addFriend2.ChoosePhoneUserPanel"):create(items4Show)
			panel:popout()
		end

		self.isRequestingPhoneFriends = false
	end

	local function isNetworkError(errorCode)
		return errorCode == -2 or errorCode == -6 or errorCode == -7
	end

	local function onLoadError(errCode)
		if errCode == 600 then
			CommonTip:showTip(Localization:getInstance():getText("add.friend.panel.add.qq.tip6"), "negative", nil, 3)
		elseif errCode == 200 then
			--require network, nothing to do;
			CommonTip:showTip(Localization:getInstance():getText("dis.connect.warning.tips"))
		elseif errCode == 100 then
			CommonTip:showTip("读取联系人信息失败！", "negative",nil, 2)
		elseif isNetworkError(errCode) then
			CommonTip:showTip(localize("dis.connect.warning.tips"), "negative",nil, 2)
		else
			CommonTip:showTip("无法获取您的手机好友的信息！", "negative",nil, 2)
		end
		self.isRequestingPhoneFriends = false
	end

	local function onloadCancel()
		self.isRequestingPhoneFriends = false
	end

	self.isRequestingPhoneFriends = true
	loadFriendsLogic:loadFriendsInContacts(onLoadSuccess, onLoadError, onloadCancel)
end


return TabBindPhone