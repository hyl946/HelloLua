require "hecore.ui.PopoutManager"
require "hecore.ui.ScrollView"

require "zoo.panel.basePanel.BasePanel"
require "zoo.net.Http"
require 'zoo.panel.GoToAddFriendPanel'

-------------------------------------------------------------------------
--  Class include: AskForEnergyItem, AskForEnergyPanel
-------------------------------------------------------------------------

--
-- AskForEnergyItem ---------------------------------------------------------
--

local LIMIT = 12

AskForEnergyItem = class(ChooseFriendItem)

function AskForEnergyItem:getUiGroup()
	local builder = InterfaceBuilder:create(PanelConfigFiles.AskForEnergyPanel)
	local ui = builder:buildGroup("img/invite_friend_avatar")
	return ui
end


--
-- AskForEnergyPanel ---------------------------------------------------------
--
AskForEnergyPanel = class(ChooseFriendPanel)
local rewardItemId = 10013
function AskForEnergyPanel:create(onConfirmCallback)
	local panel = AskForEnergyPanel.new()
	panel:loadRequiredResource(PanelConfigFiles.AskForEnergyPanel)
	panel:setSelectAllLimit(LIMIT)
	if panel:init(onConfirmCallback) then
		if _G.isLocalDevelopMode then printx(0, "return true, panel should been shown") end
		return panel
	else
		if _G.isLocalDevelopMode then printx(0, "return false, panel's been destroyed") end
		panel = nil
		return nil
	end
end

function AskForEnergyPanel:loadRequiredResource( panelConfigFile )
	self.panelConfigFile = panelConfigFile
	self.builder = InterfaceBuilder:createWithContentsOfFile(panelConfigFile)
end

function AskForEnergyPanel:init(onConfirmCallback)
	-- 初始化视图
	local wSize = CCDirector:sharedDirector():getWinSize()
	local winSize = CCDirector:sharedDirector():getVisibleSize()
	self.ui = self:buildInterfaceGroup("AskForEnergyPanel") 
	BasePanel.init(self, self.ui)
	
	self:setPositionForPopoutManager()

	-- 获取控件
	self.closeBtn = self.ui:getChildByName("closeBtn")
	self.captain = self.ui:getChildByName("captain")
	self.selectText = self.ui:getChildByName("select")
	self.commentText = self.ui:getChildByName("comment")
	self.sentText = self.ui:getChildByName("sent")
	self.btnAdd = self.ui:getChildByName("btnAdd")
	self.otherBtnPos = self.ui:getChildByName("otherBtnPos")
	self.sentIcon = self.ui:getChildByName("sentIcon")
	self.btnAdd = ButtonIconsetBase:create(self.btnAdd) 
	-- local askItemIcon = ResourceManager:sharedInstance():getItemResNameFromGoodsId(12)
	local iconBuilder = InterfaceBuilder:create(PanelConfigFiles.properties)
	local askItemIcon1 = iconBuilder:buildGroup('Prop_'..rewardItemId)
	local askItemIcon1Sprite = askItemIcon1:getChildByName('sprite')
	askItemIcon1Sprite:removeFromParentAndCleanup(false)
	askItemIcon1:dispose()
	self.btnAdd:setIcon(askItemIcon1Sprite)
	local askItemIcon = ResourceManager:sharedInstance():buildItemSprite(rewardItemId)
	local pos = self.sentIcon:getPosition()
	askItemIcon:setPosition(ccp(pos.x, pos.y))
	self.ui:addChild(askItemIcon)
	-- self.sentIcon:removeFromParentAndCleanup(true)
	self.sentIcon:setVisible(false)
	self.sentIcon = askItemIcon
	
	self.btnAdd:setString(Localization:getInstance():getText("message.center.panel.ask.energy.btn"))
	self.ui:getChildByName("avatar"):removeFromParentAndCleanup(true)
	-- self.ui:getChildByName("avatar"):setVisible(false)
	self.selectText:setString(Localization:getInstance():getText("message.center.panel.ask.energy.desc"))
	self.commentText:setString(Localization:getInstance():getText("message.center.panel.ask.energy.comment"))
	self.sentText:setString(Localization:getInstance():getText("message.center.panel.ask.energy.count"))


	-- 全选功能不再有
	self.all_select_txt = self.ui:getChildByName('all_select_txt')
	self.select_mark = self.ui:getChildByName('select_mark')
	self.select_mark:setVisible(false)
	self.allSelected = false
	self.select_all_btn = self.ui:getChildByName('select_all_btn')
	self.select_all_btn:getChildByName('hit_area'):setVisible(false)
	self.select_all_btn:setTouchEnabled(false)
	self.select_all_btn:setVisible(false)
	self.all_select_txt:setVisible(false)


	local tab = UserManager:getInstance():getWantIds()
	local count = #tab
	if __IOS_FB or count > 0 then -- facebook没有额外的奖励
		self.sentIcon:setVisible(false)
		self.sentText:setVisible(false)
	else
		local pos = self.otherBtnPos:getPosition()
		self.btnAdd:setPosition(ccp(pos.x, pos.y))
	end
	-- self.otherBtnPos:removeFromParentAndCleanup(true)
	self.otherBtnPos:setVisible(false)

	-- 替换标题
	local charWidth = 65
	local charHeight = 65
	local charInterval = 57
	local fntFile = "fnt/caption.fnt"
	if _G.useTraditionalChineseRes then fntFile = "fnt/zh_tw/caption.fnt" end
	local position = self.captain:getPosition()
	self.newCaptain = LabelBMMonospaceFont:create(charWidth, charHeight, charInterval, fntFile)
	self.newCaptain:setAnchorPoint(ccp(0,1))
	self.newCaptain:setString(Localization:getInstance():getText("message.center.panel.ask.energy.captain"))
	self.newCaptain:setPosition(ccp(position.x, position.y))
	self:addChild(self.newCaptain)
	self.newCaptain:setToParentCenterHorizontal()
	self.captain:setVisible(false)

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
		--if _G.isLocalDevelopMode then printx(0, "selectedFriendsID", table.tostring(selectedFriendsID)) end
		
		if #selectedFriendsID == 0 then 
			CommonTip:showTip(Localization:getInstance():getText('unlock.cloud.panel.request.friend.noselect'), 'negative', nil)
		else
			if #selectedFriendsID == self.numberOfFriends then
				if FriendManager:getInstance():isFriendCountReachedMax() then
					self:onKeyBackClicked()
					local panel = GoToAddFriendPanel:create({GoToAddFriendPanel.FUNC_TYPE.ENERGY, GoToAddFriendPanel.ACTION_TYPE.SEND})
					panel:popout()
				else
					self:onKeyBackClicked()
					local panel = GoToAddFriendPanel:create({GoToAddFriendPanel.FUNC_TYPE.ENERGY, GoToAddFriendPanel.ACTION_TYPE.ADD})
					panel:popout()
				end
			end
			if onConfirmCallback ~= nil then onConfirmCallback(selectedFriendsID) end
		end
	end
	self.btnAdd:ad(DisplayEvents.kTouchTap, onBtnAddTapped)

	if not PlatformConfig:isPlatform(PlatformNameEnum.kJinliPre) then
		self:selectAll()
	end

	self:updateBtnAddShow()
	return true
end

function AskForEnergyPanel:getFriendList(exceptIds, shareNotilist)
	local friend = FreegiftManager:sharedInstance():getCanGiveFriends()
	-- if _G.isLocalDevelopMode then printx(0, #friend) end
	local friendList = {}
	if __IOS_FB then -- facebook版只需要有snsId的好友，否则无法指定好友发送request
		local appFriends = FriendManager.getInstance().friends or {}
		local appFriend = nil
		for i,v in pairs(friend) do
			appFriend = appFriends[v.friendUid]
			if appFriend and appFriend.snsId then
				table.insert(friendList, {uid=v.friendUid, invite=false})
			end
		end
	else
		for i,v in pairs(friend) do
			table.insert(friendList, {uid=v.friendUid, invite=false})
		end
	end
	return friendList
end

function AskForEnergyPanel:updateBtnAddShow()
	local tab = UserManager:getInstance():getWantIds()
	if #tab < 1 then 
		if self.btnAdd then 
			if self.btnAdd.icon then 
				self.btnAdd.icon:setVisible(true)
			end
			if self.btnAdd.label then 
				self.btnAdd.label:setPosition(ccp(-58.52, 45.2))
			end
		end
	else
		if self.btnAdd then 
			if self.btnAdd.icon then 
				self.btnAdd.icon:setVisible(false)
			end
			if self.btnAdd.label then 
				self.btnAdd.label:setPosition(ccp(-101.52, 45.2))
			end
		end
	end
end

function AskForEnergyPanel:buildGridLayout()
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
	local content = self:createItemList(onTileItemTouch, 630, self.listHeight, self.scrollable, friendList)--Sprite:create("materials/logo.png")
	local numberOfFriends = #friendList
	content:setPositionX(5)
	self.content = content
	self.numberOfFriends = numberOfFriends
	if numberOfFriends > 0 then
		self.scrollable:setContent(content)
		self.scrollable:setPositionXY(self.listPos.x + 18, self.listPos.y - 15)
		self.ui:addChild(self.scrollable)
	else
		self.scrollable:dispose()
		self.content:dispose()
		self.listBg:removeFromParentAndCleanup(true)
		self.selectText:setVisible(false)
		self.commentText:setVisible(false)
		self.sentIcon:setVisible(false)
		self.sentText:setVisible(false)
		self.btnAdd:setVisible(false)
		local group = self.builder:buildGroup("AskForEnergyPanel_zero_friend")
		local bg = group:getChildByName("bg")
		local size = bg:getGroupBounds().size
		size = {width = size.width, height = size.height}
		local panelSize = self.ui:getGroupBounds().size
		group:setPositionXY((panelSize.width - size.width) / 2 - 1, -(panelSize.height - size.height) / 2 + 20)
		self.ui:addChild(group)
		group:getChildByName("text1"):setString(Localization:getInstance():getText("request.message.panel.zero.friend.tip2"))
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

function AskForEnergyPanel:refreshFriendItems()
	if self.scrollable and not self.scrollable.isDisposed then
		self.scrollable:removeFromParentAndCleanup(true)
	end
	self:buildGridLayout(self.listHeight)
end

function AskForEnergyPanel:onKeyBackClicked()
	--[[if self.sendAskSuccess then 
		self.sendAskSuccess = false
		NotificationGuideManager.getInstance():popoutIfNecessary(NotiGuideTriggerType.kFriendEnergy)
	end--]]
	PopoutManager:sharedInstance():remove(self, true)
end

function AskForEnergyPanel:popout()
	PopoutManager:sharedInstance():add(self, true, false)
end


-- 新方法：减少一些代码冗余
function AskForEnergyPanel:popoutPanel(onRequestSuccess, onRequestFail)
	if WXJPPackageUtil.getInstance():isGuestLogin() then 
		CommonTip:showTip(Localization:getInstance():getText("wxjp.guest.warning.tip"), "negative")
		return 
	end

	local level = UserManager:getInstance().user:getTopLevelId()
    local meta = MetaManager:getInstance():getFreegift(level)
    local function onUpdateFriend(result, evt)
        if result == "success" then
        	local canGiveFriends = FreegiftManager:sharedInstance():getCanGiveFriends()
        	if #canGiveFriends <= 0 then
        		if FriendManager:getInstance():isFriendCountReachedMax() then
        			GoToAddFriendPanel:create({GoToAddFriendPanel.FUNC_TYPE.ENERGY, GoToAddFriendPanel.ACTION_TYPE.SEND}):popout()
	        		return
        		else
	        		GoToAddFriendPanel:create({GoToAddFriendPanel.FUNC_TYPE.ENERGY, GoToAddFriendPanel.ACTION_TYPE.ADD}):popout()
	        		return
	        	end
        	end

        	local panel = nil
            local function confirmAskFriend(selectedFriendsID, numberOfFriends)
            	DcUtil:UserTrack({category = 'friend', sub_category = 'push_button_energy'})
	            local todayWants = UserManager:getInstance():getWantIds()
			    local todayWantsCount = #todayWants
			    if panel and not panel.isDisposed then
			    	panel.btnAdd:setEnabled(false)
			    end
                if #selectedFriendsID > 0 then
                    local function onSuccess()
                    	panel.sendAskSuccess = true
                        DcUtil:requestEnergy(#selectedFriendsID,level)
                        CommonTip:showTip(Localization:getInstance():getText("energy.panel.ask.energy.success"), "positive")
                        if onRequestSuccess then onRequestSuccess(selectedFriendsID) end
                        if panel and not panel.isDisposed then
                        	if todayWants and todayWantsCount < 1 then
	                    		panel.sentIcon:setVisible(false)
					            panel.sentText:setVisible(false)
					            todayWantsCount = #todayWants
					            local reward = {itemId = rewardItemId, num = 1}
								local anim = FlyItemsAnimation:create({reward})
								local bounds = panel.sentIcon:getGroupBounds()
								anim:setWorldPosition(ccp(bounds:getMidX(),bounds:getMidY()))
								anim:play()
					        end

                        	panel:refreshFriendItems()
                        	panel:selectAll()
                        	panel:updateBtnAddShow()
                        	panel.btnAdd:setEnabled(true)
                        end
                    end
                    local function onFail(evt)
                        CommonTip:showTip(Localization:getInstance():getText("error.tip."..evt.data), "negative")
                        if onRequestFail then onRequestFail(evt) end
                    end
                    FreegiftManager:sharedInstance():requestGift(selectedFriendsID, meta.itemId, onSuccess, onFail)
                elseif numberOfFriends == 0 then
                	assert(false, "impossible==AskForEnergyPanel:popoutPanel()")
                end
            end
            panel = AskForEnergyPanel:create(confirmAskFriend)
            if panel then panel:popout() end
        else
            local message = ''
            local err_code = tonumber(evt.data)
            if err_code then message = Localization:getInstance():getText("error.tip."..err_code) end
            CommonTip:showTip(message, "negative")
        end
    end
    FreegiftManager:sharedInstance():updateFriendInfos(true, onUpdateFriend)
end