local ChoosePhoneItem = class(ItemInClippingNode)

function ChoosePhoneItem:create(itemData, onTapCallback)
	local instance = ChoosePhoneItem.new()
	instance:loadRequiredResource("ui/AddFriendPanel2.json")
	instance:init(itemData, onTapCallback)
	return instance
end

function ChoosePhoneItem:loadRequiredResource(panelConfigFile)
	self.panelConfigFile = panelConfigFile
	self.builder = InterfaceBuilder:createWithContentsOfFile(panelConfigFile)
end

function ChoosePhoneItem:init(itemData, onTapCallback)
	ItemInClippingNode.init(self)
	self.ui = self.builder:buildGroup("AddFriendPanel2/AddFriendPanelRecommendItem")
	self:setContent(self.ui)

	self.addFriendPanelLogic = AddFriendPanelLogic:create()
	self.itemData = itemData
	self:initContent(self.ui, itemData)
end

function ChoosePhoneItem:initContent(elem,data)
	elem.bgNormal = elem:getChildByName("bg_normal")
	elem.bgSent = elem:getChildByName("bg_sent")
	elem.bgSent:setVisible(false)
	elem.labelSent = elem:getChildByName("lbl_sent")
	elem.labelSent:setString(Localization:getInstance():getText("add.friend.panel.message.sent"))
	elem.labelSent:setVisible(false)
	elem.iconAdd = elem:getChildByName("icn_add")
	elem.userLevel = elem:getChildByName("lbl_userLevel")
	elem.userName = elem:getChildByName("lbl_userName")
	elem.userHead = elem:getChildByName("img_userImg")
	elem.imgLoad = elem:getChildByName("img_load")
	local pos = elem.imgLoad:getPosition()
	local size = elem.imgLoad:getGroupBounds().size
	elem.imgLoad:setAnchorPoint(ccp(0.5, 0.5))
	elem.imgLoad:setPosition(ccp(pos.x + size.width / 2, pos.y - size.height / 2))
	elem.imgLoad:runAction(CCRepeatForever:create(CCRotateBy:create(1, 360)))
	elem.imgLoad:setVisible(false)

	local name = nameDecode(data.name)
	if name and string.len(name) > 0 then 
		elem.userName:setString(name)
	else 
		elem.userName:setString(Localization:getInstance():getText("add.friend.panel.no.user.name"))
	end

	if not string.isEmpty(data.phoneName) then
		elem.userLevel:setString(data.phoneName)
	else
		elem.userLevel:setString(Localization:getInstance():getText("add.friend.panel.no.user.name"))
	end

	local userHead = HeadImageLoader:create(data.uid, data.headUrl, function ( headImg )

	end)

	if userHead then
		local position = elem.userHead:getPosition()
		userHead:setAnchorPoint(ccp(-0.5, 0.5))
		userHead:setScale(0.65)
		userHead:setPosition(ccp(position.x, position.y))
		elem.userHead:getParent():addChild(userHead)
		elem.userHead:removeFromParentAndCleanup(true)
	end

	elem:setTouchEnabled(true, 0, true)
	local function onTouched()
		if RequireNetworkAlert:popout() then
			elem.imgLoad:setVisible(true)
			elem.iconAdd:setVisible(false)
			self:addFriend(data.uid, elem)
		end
	end
	elem:addEventListener(DisplayEvents.kTouchTap, onTouched)
end

function ChoosePhoneItem:addFriend(uid, target)
	local function onSuccess(data, context)
		DcUtil:UserTrack({ category='add_friend', sub_category="add_phone_send", friend_id = uid}, true)
		if self.isDisposed then return end
		local target = context.target
		if not target or target.isDisposed then return end
		target.imgLoad:setVisible(false)
		target.labelSent:setVisible(true)
		target.bgSent:setVisible(true)
		target.bgNormal:setVisible(false)
	end
	local function onFail(err, context)
		if self.isDisposed  then return end
		local target = context.target
		if target and not target.isDisposed then
			target:setTouchEnabled(true)
			target.iconAdd:setVisible(true)
			target.imgLoad:setVisible(false)
		end
		CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(err)), "negative")
	end

	local function onCancel()
		if self.isDisposed  then return end
		CommonTip:showTip(localize("add.friend.panel.cancel.phonebook"), "negative")
	end
	target:setTouchEnabled(false)
	self.addFriendPanelLogic:sendAddPhoneMessage(uid, onSuccess, onFail, onCancel, {target = target})
end

return ChoosePhoneItem