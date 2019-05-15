
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年12月 4日 20:38:05
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

---------------------------------------------------
-------------- FriendItem
---------------------------------------------------

assert(not FriendItem)
assert(BaseUI)

FriendItem = class(BaseUI)

function FriendItem:init(ui, ...)
	assert(ui)
	assert(#{...} == 0)

	self.ui = ui
	-- ---------------
	--  Init Base Class
	--  ------------
	BaseUI.init(self, ui)

	--------------
	-- Get UI Component
	-- ---------------
	self.bg = self.ui:getChildByName("_bg");
	self.label		= self.ui:getChildByName("nameLabel")
	self.nameLabelBg = self.ui:getChildByName("_nameBg")
	self.nobody = self.ui:getChildByName("icon_nobody")

	assert(self.label)

	---------------
	-- Get Data About UI
	-- ----------------

	self.defaultImageWidth	= 96;
	self.defaultImageHeight	= 96;

	-----------------
	-- Init UI Componenet
	-- ------------------
	local defaultFriendNameKey  	= "unlock.cloud.panel.default.friend.name"
	local defaultFriendNameValue	= Localization:getInstance():getText(defaultFriendNameKey, {})
	self.label:setString(defaultFriendNameValue)
	self.noBodyHere = true
	self._currVisible = true
	if self.nobody then
		self:setNobody(self.noBodyHere)
	end
	
end

function FriendItem:setNobody(noBodyHere)
	self.noBodyHere = noBodyHere
	if not self._currVisible then return end

	if self.noBodyHere then
		self.nobody:setVisible(true)
		self:setNameVisible(false)
		if self.bg then
			self.bg:setOpacity(255)
		end
	else
		self.nobody:setVisible(false)
		self:setNameVisible(true)
		if self.bg then
			self.bg:setOpacity(0)
		end
	end 
end

function FriendItem:setFriend(friendId, datas)
	assert(type(friendId) == "string")
	--assert(#{...} == 0)

	if self.isDisposed then
		return
	end

	local friendRef	= FriendManager.getInstance().friends[friendId]

	if friendId == "-1" then
		self.label:setString( datas.name )

		if self.nobody then
			self:setNobody(false)
		end
		return
	end
	local function onImageLoadFinishCallback(image)
		if self.isDisposed then return end
		local newImageSize = image:getContentSize()
		local manualAdjustDefaultImageWidth 	= 0
		local manualAdjustDefaultImageHeight	= 0
		local neededScaleX = (self.defaultImageWidth + manualAdjustDefaultImageWidth) / newImageSize.width
		local neededScaleY = (self.defaultImageHeight + manualAdjustDefaultImageHeight) / newImageSize.height
		image:setScaleX(neededScaleX)
		image:setScaleY(neededScaleY)
		local bgSize = self.bg:getContentSize();
		image:setPosition(ccp(bgSize.width/2-4, bgSize.height/2+2))
		self.bg:addChild(image)

	end

	if friendRef then
		local head = HeadImageLoader:createWithFrame(friendRef.uid, friendRef.headUrl)
		onImageLoadFinishCallback(head)
		if friendRef.name and string.len(friendRef.name) > 0 then
			self.label:setString(nameDecode(tostring(friendRef.name)))
		else
			self.label:setString(tostring(friendId))
		end

	else
		self.label:setString('消消乐玩家')
		local imageId = tostring(friendId%10)
		local head = HeadImageLoader:createWithFrame(friendId, imageId)
		onImageLoadFinishCallback(head)
	end
	if self.nobody then
		self:setNobody(false)
	end
end

function FriendItem:setVisible(isVisible)
	self._currVisible = isVisible
	self.label:setVisible(isVisible)
	self.bg:setVisible(isVisible)
	self.nameLabelBg:setVisible(isVisible)
	if self.nobody then
		if isVisible then
			self:setNobody(self.noBodyHere)
		else
			self.nobody:setVisible(false)
		end
	end


end

function FriendItem:setNameVisible(isVisible)
	self.label:setVisible(isVisible)
	self.nameLabelBg:setVisible(isVisible)
end

function FriendItem:setName(friendName)
	local name = friendName or "unlock.cloud.panel.default.friend.name"
	local nameValue	= Localization:getInstance():getText(name, {})
	self.label:setString(nameValue)
end

function FriendItem:setNameColor()
	-- body
end

function FriendItem:create(ui, ...)
	assert(ui)
	assert(#{...} == 0)

	local newFriendItem = FriendItem.new()
	newFriendItem:init(ui)
	return newFriendItem
end
