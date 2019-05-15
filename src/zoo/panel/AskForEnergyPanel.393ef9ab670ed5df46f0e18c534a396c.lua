require "hecore.ui.PopoutManager"
require "hecore.ui.ScrollView"

require "zoo.panel.basePanel.BasePanel"
require "zoo.net.Http"
require 'zoo.panel.GoToAddFriendPanel'

-------------------------------------------------------------------------
--  Class include: AskForEnergyItem, AskForEnergyPanel
-------------------------------------------------------------------------

-- AskForEnergyItem ---------------------------------------------------------
AskForEnergyItem = class(ChooseFriendItem)

function AskForEnergyItem:getUiGroup()
	local builder = InterfaceBuilder:create(PanelConfigFiles.AskForEnergyPanel)
	local ui = builder:buildGroup("img/invite_friend_avatar")
	return ui
end

--
-- AskForEnergyPanel ---------------------------------------------------------
--

local LIMIT = 12

AskForEnergyPanel = class(ChooseFriendPanel)
local rewardItemId = 10013
function AskForEnergyPanel:create(onConfirmCallback, askFriendsList)
	local panel = AskForEnergyPanel.new()
	panel:loadRequiredResource(PanelConfigFiles.AskForEnergyPanel)
	panel:setSelectAllLimit(LIMIT)
	if panel:init(onConfirmCallback, askFriendsList) then
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

function AskForEnergyPanel:init(onConfirmCallback, askFriendsList)
	-- 初始化视图



	self.askFriendsList = askFriendsList
	local wSize = CCDirector:sharedDirector():getWinSize()
	local winSize = CCDirector:sharedDirector():getVisibleSize()
	self.ui = self:buildInterfaceGroup("AskForEnergyPanel") 
	self.ui.name = 'ui'
	BasePanel.init(self, self.ui)
	self.panelName = 'AskForEnergyPanel'
	
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
	self.sentIcon:setVisible(false)
	self.sentIcon = askItemIcon
	self.btnAdd:setString(localize("message.center.panel.ask.energy.btn"))
	self.ui:getChildByName("avatar"):removeFromParentAndCleanup(true)
	self.selectText:setString(localize("message.center.panel.ask.energy.desc"))

	local function setRichText(textLabel, str)
		textLabel:setVisible(false)
		local width = textLabel:getDimensions().width
		local pos = textLabel:getPosition()
		local richText = TextUtil:buildRichText(str, width, textLabel:getFontName(), textLabel:getFontSize(), textLabel:getColor())
		richText:setPosition(ccp(pos.x+350, pos.y))
		self.ui:addChildAt(richText, textLabel:getZOrder())
		return richText
	end

	self.commentText:setString(localize("message.center.panel.ask.energy.comment"))

	self.sentText:setString(localize("message.center.panel.ask.energy.count"))

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
	self.exceptIds = {}

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
	self.newCaptain:setString(localize("message.center.panel.ask.energy.captain"))
	self.newCaptain:setPosition(ccp(position.x, position.y))
	self:addChild(self.newCaptain)
	self.newCaptain:setToParentCenterHorizontal()
	self.captain:setVisible(false)

	if Achievement:getRightsExtra( "SendReceiveEnergyNum" ) > 0 then
		local dailyMaxReceiveGiftCount = MetaManager:getInstance():getDailyMaxReceiveGiftCount()
		setRichText(self.commentText, "您每天最多可收取" .. string.format("[#FF6600]%d[/#]",dailyMaxReceiveGiftCount) .."份礼物")
	end

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
			CommonTip:showTip(localize('unlock.cloud.panel.request.friend.noselect'), 'negative', nil)
		else
			if #selectedFriendsID == self.numberOfFriends then
				self:onKeyBackClicked()
				if onConfirmCallback ~= nil then onConfirmCallback(selectedFriendsID, 0, true) end
			else
				if onConfirmCallback ~= nil then onConfirmCallback(selectedFriendsID) end
			end
		end
	end
	self.btnAdd:ad(DisplayEvents.kTouchTap, onBtnAddTapped)
	self:selectAll()
	self:updateBtnAddShow()

	self:initEnergyACT()

	return true
end

local actSource = 'EnergyACT/Config.lua'

function AskForEnergyPanel.openEnergyACT( ... )
	ActivityUtil:getActivitys(function( activitys )
	    local currentScene = Director:sharedDirector():getRunningSceneLua()
	    if currentScene ~= HomeScene:sharedInstance() then 
	        return 
	    end
	    local source = actSource
	    local version = nil
	    for k,v in pairs(ActivityUtil:getActivitys() or {}) do
	        if v.source == source then
	            version = v.version
	            break
	        end
	    end
	    if version then
	        ActivityData.new({source=source,version=version}):start(true, false, nil, nil, function ( ... )
	        	-- body
	        end)
	    end
	end)
end

function AskForEnergyPanel.isEnergyACTEnabled( ... )


	local function isWeekend( ... )
		local wday = os.date('!%w', Localhost:timeInSec() + 8*3600)
		if wday == '0' or wday == '6' then
			return true
		else
			return false
		end
	end

	if isWeekend() then
		return false
	end


	local config
    for _,v in pairs(ActivityUtil:getActivitys()) do
        if v.source == actSource then
            config = require ('activity/'..v.source)
        end
    end
    local actEnabled = config and config.isSupport()


    return actEnabled
end

function AskForEnergyPanel:initEnergyACT( ... )
	if self.isDisposed then return end

	local btnRes = self.ui:getChildByPath('energyACT/btn')
	local btn = GroupButtonBase:create(btnRes)
	btn:setString('免费获得')
	btn:setColorMode(kGroupButtonColorMode.blue)
	btn:ad(DisplayEvents.kTouchTap, preventContinuousClick(function ( ... )
		if self.isDisposed then return end
		AskForEnergyPanel.openEnergyACT()
	end))

    
    local scene = Director:sharedDirector():run()
	local isHomeScene = scene and scene:is(HomeScene)


	local popoutQueueBusy = PopoutQueue:sharedInstance():getQueueSize() > 0 

	--printx(61, self.isEnergyACTEnabled(), isHomeScene, popoutQueueBusy)

    btn:setVisible(self.isEnergyACTEnabled() and isHomeScene and (not popoutQueueBusy))
    self.ui:getChildByName('energyACT'):setVisible(self.isEnergyACTEnabled() and isHomeScene and (not popoutQueueBusy))
end


function AskForEnergyPanel:getFriendList(exceptIds, shareNotilist)
	local friendList = {}
	local function have(id) for k, v in ipairs(exceptIds) do if v == id then return true end end end
	for i,v in ipairs(self.askFriendsList) do
		if not have(v) then table.insert(friendList, {uid=v, invite=false}) end
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
		end
	else
		if self.btnAdd then 
			if self.btnAdd.icon then 
				self.btnAdd.icon:setVisible(false)
			end
		end
	end
	self.btnAdd:setString(localize("message.center.panel.ask.energy.btn"))
end

function AskForEnergyPanel:buildGridLayout()
	local function onTileItemTouch(item)
		if item and item.inviteIconMode then
			if __IOS_FB then
				if ReachabilityUtil.getInstance():isNetworkAvailable() then 
					SnsProxy:inviteFriends(nil)
				else
					CommonTip:showTip(localize("dis.connect.warning.tips"))
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
		group:getChildByName("text1"):setString(localize("request.message.panel.zero.friend.tip2"))
		group:getChildByName("text2"):setString(localize("request.message.panel.zero.friend.text"))
		group:getChildByName("dscText1"):setString(localize("request.message.panel.zero.friend.dsc1"))
		group:getChildByName("dscText2"):setString(localize("request.message.panel.zero.friend.dsc2"))
		local btn = group:getChildByName("btn")
		btn = GroupButtonBase:create(btn)
		btn:setString(localize("request.message.panel.zero.friend.button"))
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
function AskForEnergyPanel:popoutPanel(onRequestSuccess, onRequestFail, withAskFriendList)
	if WXJPPackageUtil.getInstance():isGuestLogin() then 
		CommonTip:showTip(localize("wxjp.guest.warning.tip"), "negative")
		return 
	end

	local level = UserManager:getInstance().user:getTopLevelId()
    local meta = MetaManager:getInstance():getFreegift(level)
    local function onGetSendListSuccess(isSuccess, askFriendsList, errcode)
    	if not isSuccess then return end
    	
    	if askFriendsList == nil or #askFriendsList < 1 then
    		if _G.sns_token then
    			GoToAddFriendPanel:create({GoToAddFriendPanel.FUNC_TYPE.ENERGY, GoToAddFriendPanel.ACTION_TYPE.SEND}):popout()
        		return
    		else
    			-- if PlatformConfig:hasAuthConfig(PlatformAuthEnum.kQQ, true) then
       --  			AccountBindingLogic:bindNewSns(PlatformAuthEnum.kQQ, onSuccess, onFail, onCancel, AccountBindingSource.ASK_ENERGY)
    			-- else
        			GoToAddFriendPanel:create({GoToAddFriendPanel.FUNC_TYPE.ENERGY, GoToAddFriendPanel.ACTION_TYPE.SEND}):popout()
        		-- end
        		return
        	end
    	end
    	local panel = nil
        local function confirmAskFriend(selectedFriendsID, numberOfFriends, sendAllFlag)
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
                    
                    if onRequestSuccess then onRequestSuccess(selectedFriendsID) end
                    if sendAllFlag then
                    	if _G.sns_token then
							local panel = GoToAddFriendPanel:create({GoToAddFriendPanel.FUNC_TYPE.ENERGY, GoToAddFriendPanel.ACTION_TYPE.SEND})
							panel:popout()
						end
                	end

                	CommonTip:showTip(localize("energy.panel.ask.energy.success"), "positive")
                	
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

				        for i=1, #selectedFriendsID do
				        	panel.exceptIds[#panel.exceptIds + 1] = selectedFriendsID[i]
				    	end

                    	panel:refreshFriendItems()
                    	panel:selectAll()
                    	panel:updateBtnAddShow()
                    	panel.btnAdd:setEnabled(true)
                    end
                end
                local function onFail(evt)
                	local errcode = evt and evt.data or nil
			        if errcode then
			            local scene = Director:sharedDirector():run()
			            if scene ~= nil and scene:is(HomeScene) then
			               CommonTip:showTip(localize("error.tip.".. errcode), "negative")
			            end
			        end
                    if onRequestFail then onRequestFail(evt) end
                end
                FreegiftManager:sharedInstance():requestGift(selectedFriendsID, meta.itemId, onSuccess, onFail)
            elseif numberOfFriends == 0 then
            	assert(false, "impossible==AskForEnergyPanel:popoutPanel()")
            end
        end
        panel = AskForEnergyPanel:create(confirmAskFriend, askFriendsList)
        if panel then panel:popout() end
    end

    if withAskFriendList ~= nil and #withAskFriendList > 0 then
    	onGetSendListSuccess(true, withAskFriendList)
	else
    	if not FreegiftManager:sharedInstance():getSendGiftList(onGetSendListSuccess) then
			CommonTip:showTip(localize("freegift.ask.gift.inhandle.warning"), "positive")
    	end
    end
end
