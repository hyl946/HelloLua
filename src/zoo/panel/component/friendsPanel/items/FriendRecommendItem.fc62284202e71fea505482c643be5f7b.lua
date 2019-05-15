local FriendsUtils = require "zoo.panel.component.friendsPanel.FriendsUtils"

FriendRecommendItem = class(ItemInClippingNode)
function FriendRecommendItem:create()
	local instance = FriendRecommendItem.new()
	instance:loadRequiredResource(PanelConfigFiles.friends_panel)
	instance:init()
	return instance
end

function FriendRecommendItem:ctor()
	self.name = 'FriendRecommendItem'
	self.debugTag = 0
	self.itemFoldHeight = 119
	self.itemExtendHeight = nil --之后初始化这个值
	self.starPosXOffset = 55
end

function FriendRecommendItem:loadRequiredResource(panelConfigFile)
	self.panelConfigFile = panelConfigFile
	self.builder = InterfaceBuilder:createWithContentsOfFile(panelConfigFile)
end

function FriendRecommendItem:unloadRequiredResource()
end

function FriendRecommendItem:init()
	local ui = self.builder:buildGroup('interface/friendRecommendItem')

	VerticalTileItem.init(self,ui)

	self.selected = true
	self.finished = false

	self.normal = ui:getChildByName('normal')

	self.levelLabel = ui:getChildByName('levelLabel')

	self.labelStar = self.ui:getChildByName("labelStar")
	self.labelDesc = self.ui:getChildByName("labelDesc")

	self.lbAlreadySend = self.ui:getChildByName("lbAlreadySend")
	self.lbAlreadySend:setVisible(false)
	
	self.bgNormal = ui:getChildByName('bgNormal')
	self.bgSelected = ui:getChildByName('bgSelected')
	self.bgMyself = ui:getChildByName('bgMyself')

	self.avatar = ui:getChildByName('avatar')
	-- self.avatar:getChildByName('bg'):removeFromParentAndCleanup(true)
	self.nameLabel = ui:getChildByName('labelName')

	self.selectedIcon = ui:getChildByName('selectedIcon')
	self.selectBtn = ui:getChildByName('selectBtn')

	self:setContent(ui)

	local touchArea = self.ui:getChildByName("title_touch_area")
	touchArea:setTouchEnabled(true, 0, false)
	touchArea:ad(DisplayEvents.kTouchTap, function(event) 
		require("zoo.PersonalCenter.FriendInfoPanel"):create(self.user.uid)
	    DcUtil:UserTrack({category='ui', sub_category="G_my_card_click ",t1="2",t2=1}, true)
		end)

	local touchArea = self.ui:getChildByName("select_touch_area")
	touchArea:setTouchEnabled(true, 0, true)
	touchArea:ad(DisplayEvents.kTouchTap, function(event) 
			self:onItemTapped(event) 
		end)
	self.touchArea = touchArea
	self.touchAreaScaleX = self.touchArea:getScaleX()
end

function FriendRecommendItem:refresh()
	if self.isDisposed then return end

	if self.finished then
		self.lbAlreadySend:setVisible(true)

		self.selectedIcon:setVisible(false)
		self.selectBtn:setVisible(false)
		self.selectBtn:setTouchEnabled(false)

		self.touchArea:setTouchEnabled(false)
	end
end

function FriendRecommendItem:onItemTapped(event, notUserTap)
	if self.beforeToggleCallback then
		self.beforeToggleCallback(self, notUserTap)
	end
	
	self:onSelectBtnTap()

	if self.afterToggleCallback then
		self.afterToggleCallback(notUserTap)
	end
end

function FriendRecommendItem:setFinished(finished)
	self.finished = finished
end

function FriendRecommendItem:onAddFinished()
	self.finished = true
	self:refresh()
end

function FriendRecommendItem:isFinished()
	return self.finished
end

function FriendRecommendItem:foldItem()
end

function FriendRecommendItem:setAfterToggleCallback(callback)
	self.afterToggleCallback = callback
end

function FriendRecommendItem:setBeforeToggleCallback(callback)
	self.beforeToggleCallback = callback
end

function FriendRecommendItem:setData(data)
	--print("FriendRecommendItem:setData:" ..table.tostring(data))
	self.user = data.user
	self.profile = data.profile

	self.selected = data.isSelected
	self:setSelected(self.selected)

	self.finished = data.isFinished
	self:setFinished(self.finished)

	self:refreshUserInfo(self.user)
	self:refreshProfile(self.profile)
end

function FriendRecommendItem:isPerson(uid)
	if not uid then return false end
	if self.user.uid == uid then
		return true
	else
		return false
	end
end

function FriendRecommendItem:refreshUserInfo(user)
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

function FriendRecommendItem:refreshProfile(profile)
	local username = nameDecode(profile.name or '')
	if string.isEmpty(username) then 
		username = 'ID: '..profile.uid
	end

	local nickName = TextUtil:ensureTextWidth(username, self.nameLabel:getFontSize(), self.nameLabel:getDimensions())
	if nickName then 
		self.nameLabel:setString(nickName) 
	else
		self.nameLabel:setString(username) 
	end
	
	local headUrl = profile.headUrl
	if string.isEmpty(headUrl) then
		headUrl = 1
	end

	self:changePlayerHead(tonumber(profile.uid), headUrl, profile)
	self.levelLabel:setVisible(true)

	local info = FriendsUtils:ACGINFO(profile)
	if info == "" then
		info = localize("friends.panel.unknow.acg")
	end
	local secureInfo = TextUtil:ensureTextWidth(info, self.labelDesc:getFontSize(), self.labelDesc:getDimensions())
	if secureInfo then
		info = secureInfo
	end
	self.labelDesc:setString(info) 
end

function FriendRecommendItem:changePlayerHead(uid, headUrl, profile)
	local function onImageLoadFinishCallback(head)
		if self.isDisposed then return end ---  prevent from crashes
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
	local head = HeadImageLoader:createWithFrame(uid, headUrl, nil, nil, profile)
	onImageLoadFinishCallback(head)
end

function FriendRecommendItem:setSelectStateChangeCallback(onSelectStateChangeCallback)
	self.onSelectStateChangeCallback = onSelectStateChangeCallback
end

function FriendRecommendItem:setSelected(selected)
	if self.isDisposed then return end
	
	self.selected = selected
	self.selectedIcon:setVisible(selected)
	-- self.bgSelected:setVisible(selected)
	-- self.bgNormal:setVisible(not selected)
	self.bgNormal:setVisible(true)
	if self.onSelectStateChangeCallback then
		self.onSelectStateChangeCallback(selected, self.idx)
	end
end

function FriendRecommendItem:setSelectedSlient(selected)
	if self.isDisposed then return end
	
	self.selected = selected
	self.selectedIcon:setVisible(selected)
	-- self.bgSelected:setVisible(selected)
	-- self.bgNormal:setVisible(not selected)
	self.bgNormal:setVisible(true)
end

function FriendRecommendItem:setSelectEnable( isEnable )
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

function FriendRecommendItem:enterSelectingMode()
	if self.isDisposed then return end
end

function FriendRecommendItem:exitSelectingMode()
	if self.isDisposed then return end
end

function FriendRecommendItem:canSend()
	if self.user then 
		return FreegiftManager:sharedInstance():canSendTo(tonumber(self.user.uid))
	else 
		return false
	end
end

function FriendRecommendItem:canRequestFrom(friendId)
	local wantIds = UserManager:getInstance():getWantIds()
	return (not table.includes(wantIds, friendId))
end

function FriendRecommendItem:getUser()
	return self.user
end

function FriendRecommendItem:onSelectBtnTap(event)
	if not self.selected then 
		self.selected  = true
		self:setSelected(true)
	else 
		self.selected = false
		self:setSelected(false)
	end
end

function FriendRecommendItem:dispose()
	if self.ui ~= nil then self.ui:removeFromParentAndCleanup(true) end
	if self.synchronizer then 
		self.synchronizer:unregister(self) 
		self.synchronizer = nil
	end
	ItemInClippingNode.dispose(self)
end

function FriendRecommendItem:isInfoVisible(profile)
	return profile.secret == true and tonumber(profile.uid) ~= tonumber(UserManager.getInstance().user.uid)
end

function FriendRecommendItem:setView(view)
	self.view = view
end

function FriendRecommendItem:setIndex(index)
	self.idx = index
end

function FriendRecommendItem:setPanel(panel)
	self.panel = panel
end

function FriendRecommendItem:setFriendRankingPanel(panel)
	self.friendRankingPanel = panel
end