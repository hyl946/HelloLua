local FriendsUtils = require "zoo.panel.component.friendsPanel.FriendsUtils"

local ChoosePhoneItem = class(ItemInClippingNode)
function ChoosePhoneItem:create(itemData, onTileItemTouch)
	local instance = ChoosePhoneItem.new()
	instance:loadRequiredResource(PanelConfigFiles.friends_panel)
	instance:init(itemData, onTileItemTouch)
	return instance
end

function ChoosePhoneItem:ctor()
	self.name = 'ChoosePhoneItem'
end

function ChoosePhoneItem:loadRequiredResource(panelConfigFile)
	self.panelConfigFile = panelConfigFile
	self.builder = InterfaceBuilder:create(panelConfigFile)
end

function ChoosePhoneItem:unloadRequiredResource()
end

function ChoosePhoneItem:initUI()
	self.ui = self.builder:buildGroup('interface/ChoosePhoneItem')
end

function ChoosePhoneItem:init(itemData, onTileItemTouch)
	self:initUI()
	local ui = self.ui
	VerticalTileItem.init(self,ui)

	self.finished = false

	self.normal = ui:getChildByName('normal')

	self.levelLabel = ui:getChildByName('levelLabel')

	self.labelStar = self.ui:getChildByName("labelStar")
	self.labelDesc = self.ui:getChildByName("labelDesc")

	self.lbAlreadySend = self.ui:getChildByName("lbAlreadySend")
	if self.lbAlreadySend then
		self.lbAlreadySend:setVisible(false)
	end
	
	self.bgNormal = ui:getChildByName('bgNormal')
	self.bgSelected = ui:getChildByName('bgSelected')
	self.bgMyself = ui:getChildByName('bgMyself')

	self.avatar = ui:getChildByName('avatar')
	self.nameLabel = ui:getChildByName('labelName')
	self.labelPhoneName = ui:getChildByName('labelPhoneName')

	self.selectedIcon = ui:getChildByName('selectedIcon')
	self.selectBtn = ui:getChildByName('selectBtn')

	self:setContent(ui)

	local touchArea = self.ui:getChildByName("title_touch_area")
	touchArea:setTouchEnabled(true, 0, true)
	touchArea:ad(DisplayEvents.kTouchTap, function(event) 
			self:onItemTapped(event) 
		end)
	self.touchArea = touchArea
	self.touchAreaScaleX = self.touchArea:getScaleX()

	self:setData(itemData)
end

function ChoosePhoneItem:refresh()
	if self.isDisposed then return end

	if self.finished then
		if self.lbAlreadySend then
			self.lbAlreadySend:setVisible(true)
		end

		self.selectedIcon:setVisible(false)
		self.selectBtn:setVisible(false)
		self.selectBtn:setTouchEnabled(false)

		self.touchArea:setTouchEnabled(false)
	end
end

function ChoosePhoneItem:onItemTapped(event, notUserTap)
	if self.beforeToggleCallback then
		self.beforeToggleCallback(self, notUserTap)
	end
	
	self:onSelectBtnTap()

	if self.afterToggleCallback then
		self.afterToggleCallback(notUserTap)
	end
end

function ChoosePhoneItem:onAddFinished()
	self.finished = true
	self:refresh()
end

function ChoosePhoneItem:setAfterToggleCallback(callback)
	self.afterToggleCallback = callback
end

function ChoosePhoneItem:setBeforeToggleCallback(callback)
	self.beforeToggleCallback = callback
end

function ChoosePhoneItem:setData(data)
	self.user = data.user
	self.profile = data.profile

	self:setSelected(false)

	self:refreshUserInfo(self.user)
	self:refreshProfile(self.profile)
end

function ChoosePhoneItem:refreshUserInfo(user)
	self.canNotBeDeleted = false
	if WXJPPackageUtil.getInstance():isWXJPPackage() then
		self.canNotBeDeleted = FriendManager.getInstance():isSnsFriend(user.uid)
	end

	local level = user.topLevelId
	if not level or level == '' then 
		level = 1
	end
	local star = tonumber(user.star or 0) + tonumber(user.hideStar or 0)
	self.labelStar:setString(tostring(star))
	self.levelLabel:setString(Localization:getInstance():getText('level.number.label.txt', {level_number = level}))
end

local function GetLableWidth(fontSize, content)
	local field = TextField:create()
	field:setFontSize(fontSize)
	field:setString(content)
	local spaceWidth = field:getContentSize().width
	field:dispose()
	return spaceWidth
end

function ChoosePhoneItem:refreshProfile(profile)
	local username = nameDecode(profile.name or '')
	if string.isEmpty(username) then 
		username = 'ID: '.. (profile.uid or "")
	end

	local nickName = TextUtil:ensureTextWidth(username, self.nameLabel:getFontSize(), self.nameLabel:getDimensions())
	if nickName then
        username = nickName
	end
    self.nameLabel:setString(username) 

	if not string.isEmpty(profile.phoneName) and self.labelPhoneName then
		local phoneName = "(" ..profile.phoneName
		local phoneNameSecure = TextUtil:ensureTextWidth(phoneName, self.labelPhoneName:getFontSize(), self.labelPhoneName:getDimensions())
		if phoneNameSecure then 
			phoneName = phoneNameSecure
		end
		phoneName = phoneName ..")"
		self.labelPhoneName:setString(phoneName)
		self.labelPhoneName:setPositionX(self.nameLabel:getPositionX() + GetLableWidth(self.nameLabel:getFontSize(), username))
	end
	
	local headUrl = profile.headUrl
	if string.isEmpty(headUrl) then
		headUrl = 1
	end

	self:changePlayerHead(tonumber(profile.uid), headUrl, profile)
	self.levelLabel:setVisible(true)

	local info = FriendsUtils:ACGINFO(profile, true)
	if string.isEmpty(info) then
		info = localize("friends.panel.unknow.acg")
	end

	local secureAcgInfo = TextUtil:ensureTextWidth(info, self.labelDesc:getFontSize(), self.labelDesc:getDimensions())
	if secureAcgInfo then
        info = secureAcgInfo
	end
	self.labelDesc:setString(info)
end

function ChoosePhoneItem:changePlayerHead(uid, headUrl, profile)

	local head = HeadImageLoader:createWithFrame(uid, headUrl, nil, nil, profile)
	local headHolder = self.avatar:getChildByName('holder')
	local pos = headHolder:getPosition()
	local headHolderSize = headHolder:getContentSize()
	local tarWidth = headHolderSize.width * headHolder:getScaleX()
	local realWidth = head:getContentSize().width
	local scale = tarWidth / realWidth
	head:setPositionXY(pos.x + tarWidth/2, pos.y - tarWidth/2)
	head:setScale(scale)
	if self.currentHead then
		self.currentHead:removeFromParentAndCleanup(true)
		self.currentHead:dispose()
		self.currentHead = head
	end
	headHolder:setVisible(false)
	self.avatar:addChildAt(head, 0)

end

function ChoosePhoneItem:setSelectStateChangeCallback(onSelectStateChangeCallback)
	self.onSelectStateChangeCallback = onSelectStateChangeCallback
end

function ChoosePhoneItem:setSelected(selected)
	if self.isDisposed then return end
	
	self:setSelectedSlient(selected)
	if self.onSelectStateChangeCallback then
		self.onSelectStateChangeCallback(selected, self.index)
	end
end

function ChoosePhoneItem:setSelectedSlient(selected)
	if self.isDisposed then return end
	
	self.selected = selected
	self.selectedIcon:setVisible(selected)
	-- self.bgSelected:setVisible(selected)
	-- self.bgNormal:setVisible(not selected)

	self:setSelectEnable(selected)
end

function ChoosePhoneItem:isSelected()
	return self.selected
end

function ChoosePhoneItem:isPerson(uid)
	if not uid then return false end
	if self.user.uid == uid then
		return true
	else
		return false
	end
end

function ChoosePhoneItem:setSelectEnable( isEnable )
	local disableBox = self.selectBtn:getChildByName("disableBox")
	local enableBox = self.selectBtn:getChildByName("enableBox")
	if isEnable then
		disableBox:setVisible(false)
		enableBox:setVisible(true)
	else
		disableBox:setVisible(true)
		enableBox:setVisible(false)
	end
end

function ChoosePhoneItem:canSend()
	if self.user then 
		return FreegiftManager:sharedInstance():canSendTo(tonumber(self.user.uid))
	else 
		return false
	end
end

function ChoosePhoneItem:getUser()
	return self.user
end

function ChoosePhoneItem:onSelectBtnTap(event)
	if not self.selected then 
		self.selected  = true
		self:setSelected(true)
	else 
		self.selected = false
		self:setSelected(false)
	end
end

function ChoosePhoneItem:dispose()
	if self.ui ~= nil then self.ui:removeFromParentAndCleanup(true) end
	if self.synchronizer then 
		self.synchronizer:unregister(self) 
		self.synchronizer = nil
	end
	ItemInClippingNode.dispose(self)
end

function ChoosePhoneItem:isInfoVisible(profile)
	return profile.secret == true and tonumber(profile.uid) ~= tonumber(UserManager.getInstance().user.uid)
end

function ChoosePhoneItem:setView(view)
	self.view = view
end

function ChoosePhoneItem:setIndex(index)
	self.index = index
end

function ChoosePhoneItem:setPanel(panel)
	self.panel = panel
end

return ChoosePhoneItem