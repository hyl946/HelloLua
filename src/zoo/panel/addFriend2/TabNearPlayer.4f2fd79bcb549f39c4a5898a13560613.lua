local SuperCls = require("zoo.panel.addFriend2.TabShow")
local TabNearPlayer = class(SuperCls)

function TabNearPlayer:create(ui, context)
	local tab = TabNearPlayer.new()
	tab.ui = ui
	tab.context = context
	return tab
end

function TabNearPlayer:init(ui)
    SuperCls.init(self, ui)

    self.addFriendPanelLogic = AddFriendPanelLogic:create()
    self.addFriendPanelLogic:startUpdateLocation()
    
    self.title = self.ui:getChildByName("title")
    self.title:setPreferredSize(282, 48)
    self.title:setString(localize("add.friend.panel.tag.recommend"))
    self.title:setAnchorPoint(ccp(0.5, 0.5))
    self.title:setPositionXY(302, 34)

    self.loadFriendID = 0
    self:initContent()
end

function TabNearPlayer:initContent()
	self:_tabRecommend_init(self.ui:getChildByName("content"))
end

function TabNearPlayer:__toActive(byDefault)
	SuperCls.__toActive(self, byDefault)
	self.tabRecommend:expand()
end

function TabNearPlayer:__toDeActive()
	SuperCls.__toDeActive(self)
	self.tabRecommend:hide()
end

------------------------------------------
-- TabRecommend
------------------------------------------
function TabNearPlayer:_tabRecommend_init(ui)
	-- get & create controls
	self.tabRecommend = {}
	self.tabRecommend.ui = ui
	self.tabRecommend.load = ui:getChildByName("img_load")
	ui:getChildByName("_bg"):setVisible(false)
	local pos = self.tabRecommend.load:getPosition()
	local size = self.tabRecommend.load:getGroupBounds().size
	self.tabRecommend.load:setAnchorPoint(ccp(0.48, 0.52))
	self.tabRecommend.load:setPosition(ccp(pos.x + size.width / 2, pos.y - size.height / 2))
	self.tabRecommend.load:runAction(CCRepeatForever:create(CCRotateBy:create(1, 360)))
	self.tabRecommend.noUser = ui:getChildByName("lbl_noUser")
	self.tabRecommend.noUser:setString(Localization:getInstance():getText("add.friend.panel.recommend.no.user"))
	self.tabRecommend.noUser:setVisible(false)
	self.tabRecommend.refresh = ui:getChildByName("btn_refresh")
	self.tabRecommend.refresh:setVisible(false)
	self.tabRecommend.refresh.text = self.tabRecommend.refresh:getChildByName("lbl_text")
	local fullWidth = ui:getChildByName("_bg"):getGroupBounds().size.width
	size = {width = 272, height = 98}
	self.tabRecommend.listBasePos = {x = (fullWidth - size.width * 2) / 3, y = self.tabRecommend.refresh:getPosition().y + 7}
	self.tabRecommend.listIndexPos = {x = self.tabRecommend.listBasePos.x + size.width, y = size.height + 2}
	self.tabRecommend.listContent = {}

	-- set strings
	self.tabRecommend.refresh.text:setString(Localization:getInstance():getText("add.friend.panel.recommend.refresh"))

	-- add event listeners
	local function onRefreshTapped()
		if RequireNetworkAlert:popout() then
			self.tabRecommend.load:setVisible(true)
			self:removeCurDataView()
			self:_tabRecommend_loadList()
		end
	end
	self.tabRecommend.refresh:setTouchEnabled(true)
	self.tabRecommend.refresh:addEventListener(DisplayEvents.kTouchTap, onRefreshTapped)

	self.tabRecommend.hide = function()
		self.tabRecommend.ui:setVisible(false)
		for i = 1, #self.tabRecommend.listContent do
			self.tabRecommend.listContent[1]:removeFromParentAndCleanup(true)
			table.remove(self.tabRecommend.listContent, 1)
		end
		self.tabRecommend.refresh:setVisible(false)
	end
	self.tabRecommend.expand = function()
		self:_tabRecommend_loadList()
		self.tabRecommend.ui:setVisible(true)
	end
end

function TabNearPlayer:removeCurDataView()
	-- if _G.isLocalDevelopMode then printx(0, "====================remove all render") end
	for i = 1, #self.tabRecommend.listContent do
		self.tabRecommend.listContent[1]:removeFromParentAndCleanup(true)
		table.remove(self.tabRecommend.listContent, 1)
	end
	self.tabRecommend.refresh:setVisible(false)
	self.tabRecommend.noUser:setVisible(false)
end

function TabNearPlayer:_tabRecommend_loadList()
	self:removeCurDataView()
	self.loadFriendID = self.loadFriendID + 1
	local  curLoadID = self.loadFriendID
	local function onSuccess(data, context)
		if self.ui.isDisposed then return end
		if curLoadID ~= self.loadFriendID then return end

		if data.num == 0 then
			self.tabRecommend.noUser:setVisible(true)
		else self:_tabRecommend_showList(data.data, data.num) end
		self.tabRecommend.load:setVisible(false)

		--
		DcUtil:addFriendSearch(data.num)
	end
	local function onFail(err, context)
		if self.ui.isDisposed  then return end
		CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(err)), "negative")
		self.tabRecommend.load:setVisible(false)
		if __WP8 and err == 1016 then
			LocationManager:GetInstance():GotoSettingIfNecessary()
		end
	end
	self.tabRecommend.noUser:setVisible(false)
	self.tabRecommend.load:setVisible(true)
	self.addFriendPanelLogic:getRecommendFriend(onSuccess, onFail, self.tabStatus)

	-- if not __testFlag then
	-- 	-- __testFlag = true
	-- 	setTimeOut(function( ... )
	-- 		onSuccess({data = {{userName="12", userLevel = 12,  uid = 11335, hearUrl = "1"},
	-- 	{userName="12", userLevel = 12,  uid = 11335, hearUrl = "1"},
	-- 	{userName="12", userLevel = 12,  uid = 11335, hearUrl = "1"},
	-- 	{userName="12", userLevel = 12,  uid = 11335, hearUrl = "1"},
	-- 	{userName="12", userLevel = 12,  uid = 11335, hearUrl = "1"},
	-- 	{userName="12", userLevel = 12,  uid = 11335, hearUrl = "1"},
	-- 	{userName="12", userLevel = 12,  uid = 11335, hearUrl = "1"},
	-- 	{userName="12", userLevel = 12,  uid = 11335, hearUrl = "1"}
	-- 				  } , 
	-- 	       num = 8}, self.tabStatus)
	-- 	end, 2)
	-- else
	-- 	onSuccess({data = {{userName="13", userLevel = 12,  uid = 11335, hearUrl = "1"},
	-- 	{userName="13", userLevel = 12,  uid = 11335, hearUrl = "1"},
	-- 	{userName="13", userLevel = 12,  uid = 11335, hearUrl = "1"},
	-- 	{userName="13", userLevel = 12,  uid = 11335, hearUrl = "1"},
	-- 	{userName="13", userLevel = 12,  uid = 11335, hearUrl = "1"},
	-- 	{userName="13", userLevel = 12,  uid = 11335, hearUrl = "1"},
	-- 	{userName="13", userLevel = 12,  uid = 11335, hearUrl = "1"},
	-- 	{userName="13", userLevel = 12,  uid = 11335, hearUrl = "1"}
	-- 				  } , 
	-- 	       num = 8}, self.tabStatus)
	-- end
end

function TabNearPlayer:_tabRecommend_showList(data, num)
	if self.ui.isDisposed then return end
	local count = 1
	if data ~= nil and data[10] ~= nil then data[10] = nil end --最多只显示9个人
	while data[count] do
		local elem = self:_tabRecommend_createFriend(data[count])
		local posX, posY = self.tabRecommend.listBasePos.x, self.tabRecommend.listBasePos.y - self.tabRecommend.listIndexPos.y * (count - 1) / 2
		elem:setPosition(ccp(posX, posY))
		self.tabRecommend.ui:addChild(elem)
		table.insert(self.tabRecommend.listContent, elem)
		if data[count + 1] then
			local elem = self:_tabRecommend_createFriend(data[count + 1])
			elem:setPosition(ccp(posX + self.tabRecommend.listIndexPos.x, posY))
			self.tabRecommend.ui:addChild(elem)
			table.insert(self.tabRecommend.listContent, elem)
		else
			count = count - 1
		end
		count = count + 2
	end
	
	local posX = 0
	if count / 2 ~= math.floor(count / 2) then posX = self.tabRecommend.listBasePos.x
	else posX = self.tabRecommend.listBasePos.x + self.tabRecommend.listIndexPos.x end
	local posY = self.tabRecommend.listBasePos.y - self.tabRecommend.listIndexPos.y * math.floor((count - 1) / 2)
	self.tabRecommend.refresh:setPosition(ccp(posX, posY))
	self.tabRecommend.refresh:setVisible(true)
end

local baseHeight = 235
local heightList = {baseHeight, baseHeight, baseHeight + 107, baseHeight + 107 *2, baseHeight + 107 *3}
function TabNearPlayer:updateBGSize(profileCount)

	local rows = math.floor((profileCount+1)/2)
	local curHeight = heightList[rows]

	local bg1 = self.ui:getChildByName("bg1")
	local bg2 = self.ui:getChildByName("bg2")

	local size = bg1:getGroupBounds().size
	bg1:setPreferredSize(CCSizeMake(size.width, curHeight + 102))

	local size2 = bg2:getGroupBounds().size
	bg2:setPreferredSize(CCSizeMake(size2.width, curHeight))

	self.ui:setPositionY(self.ui:getPositionY() - (649 - (curHeight + 102))/2)
end

function TabNearPlayer:_tabRecommend_addFriend(uid, target)
	local function onSuccess(data, context)
		local status = context.status
		DcUtil:addFiendNear()
		if self.ui.isDisposed then return end
		local target = context.target
		if not target or target.isDisposed then return end
		target.imgLoad:setVisible(false)
		target.labelSent:setVisible(true)
		target.bgSent:setVisible(true)
		target.bgNormal:setVisible(false)
	end
	local function onFail(err, context)
		local status = context.status
		if self.ui.isDisposed  then return end
		local target = context.target
		if target and not target.isDisposed then
			target:setTouchEnabled(true)
			target.iconAdd:setVisible(true)
			target.imgLoad:setVisible(false)
		end
		if err then
			CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(err)), "negative")
		end
	end
	target:setTouchEnabled(false)
	self.addFriendPanelLogic:sendRecommendFriendMessage(uid, onSuccess, onFail, {target = target, status = self.tabStatus})
end

function TabNearPlayer:_tabRecommend_createFriend(data)
	local elem = self.context:buildInterfaceGroup("AddFriendPanel2/AddFriendPanelRecommendItem")
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

	local name = nameDecode(data.userName)
	if name and string.len(name) > 0 then elem.userName:setString(name)
	else elem.userName:setString(Localization:getInstance():getText("add.friend.panel.no.user.name"))end
	if data.userLevel then
		elem.userLevel:setString(Localization:getInstance():getText("add.friend.panel.user.info.level", {n = data.userLevel}))
	end
	local userHead = HeadImageLoader:create(data.uid, data.headUrl)
	if userHead then
		local position = elem.userHead:getPosition()
		userHead:setAnchorPoint(ccp(-0.5, 0.5))
		userHead:setScale(0.65)
		userHead:setPosition(ccp(position.x, position.y))
		elem.userHead:getParent():addChild(userHead)
		elem.userHead:removeFromParentAndCleanup(true)
	end

	elem:setTouchEnabled(true)
	local function onTouched()
		if RequireNetworkAlert:popout() then
			elem.imgLoad:setVisible(true)
			elem.iconAdd:setVisible(false)
			self:_tabRecommend_addFriend(data.uid, elem)
		end
	end
	elem:addEventListener(DisplayEvents.kTouchTap, onTouched)

	return elem
end

return TabNearPlayer