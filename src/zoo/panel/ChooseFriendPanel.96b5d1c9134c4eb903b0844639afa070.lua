require "hecore.ui.PopoutManager"
require "hecore.ui.ScrollView"
require "zoo.common.DynamicLoadLayout"

require "zoo.panel.basePanel.BasePanel"
require "zoo.net.Http"
require 'zoo.panel.GoToAddFriendPanel'

-------------------------------------------------------------------------
--  Class include: ChooseFriendItem, ChooseFriendPanel
-------------------------------------------------------------------------

--
-- ChooseFriendItem ---------------------------------------------------------
--

local LIMIT = 16
ChooseFriendItem = class(CocosObject)
function ChooseFriendItem:create(inviteIconMode, onTileItemTouch, userId)
	local item = ChooseFriendItem.new(CCNode:create())
	local ui = item:getUiGroup()
	item:init(ui, inviteIconMode, userId, onTileItemTouch)
	return item
end

function ChooseFriendItem:getUiGroup()
	local builder = InterfaceBuilder:createWithContentsOfFile(PanelConfigFiles.AskForEnergyPanel) -- InterfaceBuilder:create(PanelConfigFiles.AskForEnergyPanel)
	local ui = builder:buildGroup("img/invite_friend_avatar")
	return ui
end

function ChooseFriendItem:init(ui, inviteIconMode, userId, onTileItemTouch)
	self.inviteIconMode = inviteIconMode
	self.userId = userId
	local selectedIcon = ui:getChildByName("selected_ico")
	local avatar_ico = ui:getChildByName("avatar_ico")
	avatar_ico:setOpacity(0)
	local invite_ico = ui:getChildByName("invite_ico")
	local normal = ui:getChildByName("normal")
	local selected = ui:getChildByName("selected")
	
	self.nameLabel = ui:getChildByName("name")
	self.selectedIcon = selectedIcon
	self.selectedBG = selected
	self.normalBG = normal
	self:addChild(ui)

	if inviteIconMode then
		selected:setVisible(false)
		normal:setVisible(false)
		selectedIcon:setVisible(false)
		avatar_ico:setVisible(false)
		self.nameLabel:setString(Localization:getInstance():getText("message.center.send.invite"))
		self.nameLabel:setColor(ccc3(255,255,255))
		invite_ico:setPosition(ccp(5, -5))
	else
		selected:setVisible(false)
		normal:setVisible(true)
		selectedIcon:setVisible(false)
		invite_ico:setVisible(false)
		self:select(false)

		local friendRef	= FriendManager.getInstance().friends[tostring(userId)] or {}
		local userName 
		if friendRef and friendRef.name and string.len(friendRef.name) > 0 then 
			userName = nameDecode(friendRef.name)
		else
			userName = "ID:"..tostring(userId)
		end
		local nickName = TextUtil:ensureTextWidth(userName, self.nameLabel:getFontSize(), self.nameLabel:getDimensions())
		if nickName then 
			self.nameLabel:setString(nickName) 
		else
			self.nameLabel:setString(userName) 
		end


		local frameSize = avatar_ico:getContentSize()
		local function onImageLoadFinishCallback(clipping)
			if not ui or ui.isDisposed then return end
			local clippingSize = clipping:getContentSize()
			local scale = frameSize.width/clippingSize.width
			local scaleFactor = scale*0.63;
			clipping:setScale(scaleFactor)
			clipping:setPosition(ccp(frameSize.width/2-4, frameSize.height/2+3))
			avatar_ico:addChild(clipping);
		end
		local head = HeadImageLoader:createWithFrame(userId, friendRef.headUrl or tostring((tonumber(userId) or 0) % 11))
		onImageLoadFinishCallback(head)
	end

	local function onItemTouchInside( evt )
        if onTileItemTouch ~= nil then 

        	local ret = onTileItemTouch(self, self.isSelected) 
            if self.isSelected then -- 取消选中
                self:select(not self.isSelected)
            elseif ret then -- 选中
                self:select(not self.isSelected)
            end           
        end
    end

	ui:setTouchEnabled(true)
	ui:ad(DisplayEvents.kTouchTap, onItemTouchInside)
end

function ChooseFriendItem:select( val )
	if self.inviteIconMode then return end

	self.isSelected = val
	if val then
		self.selectedBG:setVisible(true)
		self.selectedIcon:setVisible(true)
		self.normalBG:setVisible(false)
	else
		self.selectedIcon:setVisible(false)
		self.selectedBG:setVisible(false)
		self.normalBG:setVisible(true)
	end
end

function ChooseFriendItem:setUserName( name )
	self.nameLabel:setString(tostring(name))
end

--
-- ChooseFriendPanel ---------------------------------------------------------
--
ChooseFriendPanel = class(BasePanel)

function ChooseFriendPanel:create(onConfirmCallback, exceptIds, dontShowAddFriendPanel)
	local panel = ChooseFriendPanel.new()
	panel:loadRequiredResource(PanelConfigFiles.AskForEnergyPanel)
	panel:setSelectAllLimit(LIMIT)
	if panel:init(onConfirmCallback, exceptIds, dontShowAddFriendPanel) then
		if _G.isLocalDevelopMode then printx(0, "return true, panel should been shown") end
		return panel
	else
		if _G.isLocalDevelopMode then printx(0, "return false, panel's been destroyed") end
		panel = nil
		return nil
	end
end

function ChooseFriendPanel:setSelectAllLimit(limit)
	self.selectAllLimit = limit
end

function ChooseFriendPanel:getFriendList(exceptIds, shareNotilist)
	local friend = FriendManager.getInstance().friends
	if shareNotilist then 
		friend = shareNotilist
	end

	--if _G.isLocalDevelopMode then printx(0, "friends", table.tostring(friend)) end
	local friendList = {}
	local function have(id) for k, v in ipairs(exceptIds) do if v == id then return true end end end
	for i,v in pairs(friend) do
		if __IOS_FB then -- facebook必须要有snsId来向好友发送request
			if v.snsId and not have(v.uid) then table.insert(friendList, {uid=v.uid, invite=false}) end
		else
			if not have(v.uid) then table.insert(friendList, {uid=v.uid, invite=false}) end
		end
		-- table.insert(friendList, {uid=v.uid, invite=false})
	end
	return friendList
end

function ChooseFriendPanel:createItemList(onTileItemTouch, minWidth, minHeight, view, friendList,completeCallback)
	local friendList = friendList or {}

	local LayoutRender = class(DynamicLoadLayoutRender)
	function LayoutRender:getColumnNum()
		return 4
	end
	function LayoutRender:getItemSize()
		return {width = 155, height = 170}
	end
	function LayoutRender:getVisibleHeight()
		return minHeight
	end
	function LayoutRender:buildItemView(itemData, index)
		local data = itemData.data
  			local function onTapItem(item, isSelected)
  				if isSelected then
  					itemData.isSelected = not isSelected
  					return true
  				else
  					if onTileItemTouch and onTileItemTouch(item) then 
  						itemData.isSelected = not isSelected
  						return true
  					end
  				end
  				return false
  			end
	    	local askItem = ChooseFriendItem:create(data.invite, onTapItem, data.uid)
			askItem:select(itemData.isSelected)

			local layoutItem = ItemInClippingNode:create()
			layoutItem:setContent(askItem)
			layoutItem:setParentView(view)
			return layoutItem
	end

  	local container = DynamicLoadLayout:create(LayoutRender.new())
  	container:setPosition(ccp(10, 0))
  	container:initWithDatas(friendList)
	container.getSelectedFriendID = function ( self )
		local result = {}
		local dataList = self.dataList
		for k, v in ipairs(dataList) do
			if v.isSelected then
				table.insert(result, v.data.uid)
			end
		end
		return result
	end
	return container
end

function ChooseFriendPanel:init(onConfirmCallback, exceptIds, dontShowAddFriendPanel)
	self.exceptIds = exceptIds
	-- 初始化视图
	self.ui = self:buildInterfaceGroup("ChooseFriendPanel")
	BasePanel.init(self, self.ui)
	local vSize = CCDirector:sharedDirector():getVisibleSize()
	local panelSize = self.ui:getGroupBounds().size
	local scaleX = vSize.width / panelSize.width
	local scaleY = vSize.height / panelSize.height
	if scaleX > scaleY then scaleX = scaleY end
	if _G.isLocalDevelopMode then printx(0, "panelSize",scaleX) end
	self.ui:setScale(scaleX)
	-- self:setPosition(ccp(self:getHCenterInScreenX(), 0))
	self:setPositionForPopoutManager()

	-- 获取控件
	self.closeBtn = self.ui:getChildByName("closeBtn")
	self.captain = self.ui:getChildByName("captain")
	self.btnAdd = self.ui:getChildByName("btnAdd")
	self.btnAdd = ButtonIconsetBase:create(self.btnAdd) 
	
	self.btnAdd:setString(Localization:getInstance():getText("message.center.send.request"))
	self.ui:getChildByName("avatar"):removeFromParentAndCleanup(true)

	-- 替换标题
	local charWidth = 65
	local charHeight = 65
	local charInterval = 57
	local fntFile = "fnt/caption.fnt"
	if _G.useTraditionalChineseRes then fntFile = "fnt/zh_tw/caption.fnt" end
	local position = self.captain:getPosition()
	self.newCaptain = LabelBMMonospaceFont:create(charWidth, charHeight, charInterval, fntFile)
	self.newCaptain:setAnchorPoint(ccp(0,1))
	self.newCaptain:setString(Localization:getInstance():getText("message.center.select.friends"))
	self.newCaptain:setPosition(ccp(position.x, position.y))
	self:addChild(self.newCaptain)
	self.newCaptain:setToParentCenterHorizontal()
	self.captain:removeFromParentAndCleanup(true)

	local listBg = self.ui:getChildByName("Layer 2")
	local listSize = listBg:getContentSize()
	local listPos = listBg:getPosition()
	local listHeight = listSize.height - 30

	self.listBg = listBg
	self.listSize = listSize
	self.listPos = listPos
	self.listHeight = listHeight	

	self:buildGridLayout()

	-- 添加事件监听
	local function onCloseTapped()
		self:onKeyBackClicked()
	end
	self.closeBtn:setTouchEnabled(true)
	self.closeBtn:setButtonMode(true)
	self.closeBtn:ad(DisplayEvents.kTouchTap, onCloseTapped)

	local function onBtnAddTapped()
		local selectedFriendsID = self.content:getSelectedFriendID()
		if #selectedFriendsID == 0 then 
			CommonTip:showTip(Localization:getInstance():getText('unlock.cloud.panel.request.friend.noselect'), 'negative', nil)
		else
			if #selectedFriendsID == self.numberOfFriends then
				if self.allSentCallback then
					self.allSentCallback()
				end
				self:onKeyBackClicked()
				if not dontShowAddFriendPanel then
					self:onAllFriendsSent()
				end
			end
			if onConfirmCallback ~= nil then onConfirmCallback(selectedFriendsID) end
		end
	end
	self.btnAdd:addEventListener(DisplayEvents.kTouchTap, onBtnAddTapped)

	self:selectAll()

	return true
end

function ChooseFriendPanel:onAllFriendsSent()
	if FriendManager:getInstance():isFriendCountReachedMax() then
		local panel = GoToAddFriendPanel:create({GoToAddFriendPanel.FUNC_TYPE.UNLOCK, GoToAddFriendPanel.ACTION_TYPE.SEND})
		panel:popout()
	else
		local panel = GoToAddFriendPanel:create({GoToAddFriendPanel.FUNC_TYPE.UNLOCK, GoToAddFriendPanel.ACTION_TYPE.ADD})
		panel:popout()
	end
end

function ChooseFriendPanel:buildGridLayout()

	local function onTileItemTouch(item)
		if item and item.inviteIconMode then
			if __IOS_FB then
				if ReachabilityUtil.getInstance():isNetworkAvailable() then 
					SnsProxy:inviteFriends(nil)
				else
					CommonTip:showTip(Localization:getInstance():getText("dis.connect.warning.tips"))
				end
			else
				createAddFriendPanel("recommend")
			end
		end
		return self:onItemSelectChange()
	end

	self.scrollable = VerticalScrollable:create(630, self.listHeight, true, false)
	local friendList = self:getFriendList(self.exceptIds, self.shareNotilist)
	local content = self:createItemList(onTileItemTouch, 630, self.listHeight, self.scrollable, friendList,function() 

			local height
			if type(self.content.getHeight) == "function" then
				height = self.content:getHeight()
			else
				height = self.content:getGroupBounds().size.height
			end
			self.scrollable:setScrollableHeight(height)
			self.scrollable:updateContentViewArea()

			self:selectAll()
		end)

	local numberOfFriends = #friendList

	self.content = content
	self.numberOfFriends = numberOfFriends
	if numberOfFriends > 0 then
		self.scrollable:setContent(self.content)
		self.scrollable:setPositionXY(self.listPos.x, self.listPos.y - 15)
		self.ui:addChild(self.scrollable)
	else
		self.scrollable:dispose()
		self.content:dispose()
		self.listBg:removeFromParentAndCleanup(true)
		self.btnAdd:setVisible(false)
		local group = self.builder:buildGroup("AskForEnergyPanel_zero_friend")
		local bg = group:getChildByName("bg")
		local size = bg:getGroupBounds().size
		size = {width = size.width, height = size.height}
		local panelSize = self.ui:getGroupBounds().size
		group:setPositionXY((panelSize.width - size.width) / 2 - 1, -(panelSize.height - size.height) / 2 + 40)
		self.ui:addChild(group)
		group:getChildByName("text1"):setString(Localization:getInstance():getText("request.message.panel.zero.unlock.tip"))
		group:getChildByName("text2"):setString(Localization:getInstance():getText("request.message.panel.zero.friend.text"))
		group:getChildByName("dscText1"):setString(Localization:getInstance():getText("request.message.panel.zero.friend.dsc1"))
		group:getChildByName("dscText2"):setString(Localization:getInstance():getText("request.message.panel.zero.friend.dsc2"))
		local btn = group:getChildByName("btn")
		btn = GroupButtonBase:create(btn)
		btn:setString(Localization:getInstance():getText("request.message.panel.zero.friend.button"))
		local function onButton()
			createAddFriendPanel("recommend")
		end
		btn:addEventListener(DisplayEvents.kTouchTap, onButton)
	end
end

function ChooseFriendPanel:onKeyBackClicked()
	-- if (not self.canClosePanel ) then
	-- 	return 
	-- end

	--[[if self.sendAskSuccess then 
		self.sendAskSuccess = false
		NotificationGuideManager.getInstance():popoutIfNecessary(NotiGuideTriggerType.kFriendUnlock)
	end--]]
	PopoutManager:sharedInstance():remove(self, true)
end

function ChooseFriendPanel:popout()
	PopoutManager:sharedInstance():add(self, true, false)
end

function ChooseFriendPanel:onItemSelectChange()
    if self.content and not self.content.isDisposed then
        local selectedFriendsID = self.content:getSelectedFriendID()
        
        if _G.isLocalDevelopMode then printx(0, '#selectedFriendsID', #selectedFriendsID) end
        if #selectedFriendsID >= self.selectAllLimit then
            CommonTip:showTip(localize('ask.friend.limit'), 'negative')
            return false
        end
    end
    return true
end

function ChooseFriendPanel:selectAll()
	if self.isDisposed  then return end
	local dataList = self.content.dataList
	local viewList = self.content.viewList
	local count = #dataList
	local maxIndex
	if count >= self.selectAllLimit then
		maxIndex = self.selectAllLimit
	else
		maxIndex = count
	end
	for index = 1, maxIndex do
		dataList[index].isSelected = true
		local view = viewList[index]
		if view and not view.isDisposed then
			view.content:select(true)
		end
	end
end

function ChooseFriendPanel:refreshFriendItems()
	if self.scrollable and not self.scrollable.isDisposed then
		self.scrollable:removeFromParentAndCleanup(true)
	end
	self:buildGridLayout()
end

function ChooseFriendPanel:getDateKey()
	local time = os.date('*t', Localhost:timeInSec())
	local year, month, day = time.year, time.month, time.day
	return string.format('%s.%s.%s', tostring(year), tostring(month), tostring(day))
end

function ChooseFriendPanel:readSentFriendIdsData()
	local uid = UserManager:getInstance().user.uid or '12345'
	local path = HeResPathUtils:getUserDataPath()..'/unlock_sent_'..uid
	local file, err = io.open(path,"r")
    if file and not err then 
        local content = file:read('*a')
        file:close()
        local data = table.deserialize(content)
        if not data then return {} end
        return data
    end
    return {}
end

function ChooseFriendPanel:writeSendFriendIdsData(data)
local uid = UserManager:getInstance().user.uid or '12345'
	local path = HeResPathUtils:getUserDataPath()..'/unlock_sent_'..uid
	local file, err = io.open(path, 'w')
	if file and not err then
		local str = table.serialize(data)
		file:write(str)
		file:close()
	end
end

function ChooseFriendPanel:getSentFriendIdsByCloudId(cloudId)
	local data = self:readSentFriendIdsData()
	if not cloudId then return {} end
	cloudId = tostring(cloudId)

	local dateKey = self:getDateKey()
	if data[dateKey] and data[dateKey][cloudId] then
		return data[dateKey][cloudId]
	else
		return {}
	end
end

function ChooseFriendPanel:mergeIds(ids1, ids2)
	local ret = {}
	local check = {}
	for k, v in pairs(ids1) do
		if not check[v] then
			table.insert(ret, v)
			check[v] = true
		end
	end
	for k, v in pairs(ids2) do
		if not check[v] then
			table.insert(ret, v)
			check[v] = true
		end
	end
	return ret
end

function ChooseFriendPanel:addSentFriendIds(cloudId, ids)
	cloudId = tostring(cloudId)
	local dateKey = self:getDateKey()
	local data = self:readSentFriendIdsData()
	if not data[dateKey] then
		data[dateKey] = {}
	end
	if not data[dateKey][cloudId] then
		data[dateKey][cloudId] = {}
	end
	local newIds = self:mergeIds(data[dateKey][cloudId], ids)
	data[dateKey][cloudId] = newIds
	self:writeSendFriendIdsData(data)
end

function ChooseFriendPanel:popoutPanel(cloudId, curAreaFriendIds, onRequestSuccess, onRequestFail, dontShowAddFriendPanel, allSentCallback)

	local panel = nil
	-- On Friend Choosed
	local function onFriendChoose(friendIds)
		DcUtil:UserTrack({category = 'friend', sub_category = 'push_button_unlock'})

		local function onSuccess(evt)
			panel.sendAskSuccess = true
			DcUtil:requestUnLockCloud(cloudId ,#friendIds)
			self:addSentFriendIds(cloudId, friendIds)
			local tipKey	= "unlock.cloud.panel.request.friend.success"
			local tipValue	= Localization:getInstance():getText(tipKey)
			CommonTip:showTip(tipValue, "positive")

			if panel and not panel.isDisposed then
				if friendIds then
					for k, v in pairs(friendIds) do
						table.insert(panel.exceptIds, v)
					end
				end
				panel:refreshFriendItems()
				panel:selectAll()
			end
			if onRequestSuccess then onRequestSuccess(friendIds) end
		end

		local function onFail(errCode)
			local tipKey	= "error.tip."..tostring(errCode)
			local tipValue	= Localization:getInstance():getText(tipKey)
			CommonTip:showTip(tipValue, "negative")
			if onRequestFail then onRequestFail(errCode) end
		end

		if not friendIds or #friendIds == 0 then
			CommonTip:showTip(Localization:getInstance():getText("unlock.cloud.panel.request.friend.noselect"), "negative")
			return
		end

		if __WIN32 then
			return onSuccess()
		end

		local logic = UnlockLevelAreaLogic:create(cloudId)
		logic:setOnSuccessCallback(onSuccess)
		logic:setOnFailCallback(onFail)
		if __IOS_FB then
			if SnsProxy:isShareAvailable() then
				local callback = {
					onSuccess = function(result)
						logic:start(UnlockLevelAreaLogicUnlockType.REQUEST_FRIEND_TO_HELP, friendIds)
						DcUtil:logSendRequest("request",result.id,"request_uplock_area_help")
					end,
					onError = function(err)
						if _G.isLocalDevelopMode then printx(0, "failed") end
					end
				}

				local profile = UserManager.getInstance().profile
				local userName = ""
				if profile and profile:haveName() then
					userName = profile:getDisplayName()
				end
				
				local reqTitle = Localization:getInstance():getText("facebook.request.unlock.title", {user=userName})
				local reqMessage = Localization:getInstance():getText("facebook.request.unlock.message", {user=userName})
				
				local snsIds = FriendManager.getInstance():getFriendsSnsIdByUid(friendIds)
				SnsProxy:sendRequest(snsIds, reqTitle, reqMessage, false, FBRequestObject.ULOCK_AREA_HELP, callback)
			end
		else
			if WXJPPackageUtil.getInstance():isWXJPLoginWX() then 
				local WXJPConfirmPanel = require "zoo.panel.WXJPConfirmPanel"
				local panel = WXJPConfirmPanel:create("请求已发送，是否微信告诉TA？", function ()
					logic:start(UnlockLevelAreaLogicUnlockType.REQUEST_FRIEND_TO_HELP, friendIds, nil, nil, true)
				end, function ()
					logic:start(UnlockLevelAreaLogicUnlockType.REQUEST_FRIEND_TO_HELP, friendIds)
				end)
				panel:popout()
			else
				logic:start(UnlockLevelAreaLogicUnlockType.REQUEST_FRIEND_TO_HELP, friendIds)
			end
		end	
	end

	local exceptIds
	if curAreaFriendIds then
		exceptIds = table.clone(curAreaFriendIds, true)
	else
		exceptIds = {}
	end
	local sentFriendIds = self:getSentFriendIdsByCloudId(cloudId)
	local newExceptIds = self:mergeIds(exceptIds, sentFriendIds)

	local filteredIds = ChooseFriendPanel:getFriendList(newExceptIds, nil)
	if #filteredIds == 0 and not dontShowAddFriendPanel then
		ChooseFriendPanel:onAllFriendsSent()
		return
	else
		panel = ChooseFriendPanel:create(onFriendChoose, newExceptIds, dontShowAddFriendPanel)
		panel:setAllSentCallback(allSentCallback)
		panel:popout()
		return panel
	end
end

function ChooseFriendPanel:hasFriendsToSend(cloudId, curAreaFriendIds)
	
	local exceptIds
	if curAreaFriendIds then
		exceptIds = table.clone(curAreaFriendIds, true)
	else
		exceptIds = {}
	end
	local sentFriendIds = self:getSentFriendIdsByCloudId(cloudId)
	local newExceptIds = self:mergeIds(exceptIds, sentFriendIds)

	local filteredIds = ChooseFriendPanel:getFriendList(newExceptIds, nil)
	return #filteredIds > 0
end

function ChooseFriendPanel:setAllSentCallback(callback)
	self.allSentCallback = callback
end