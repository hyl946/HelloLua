local SuperCls = require("zoo.panel.addFriend2.TabShow")
local TabShake = class(SuperCls)

function TabShake:create(ui, context)
	local tab = TabShake.new()
	tab.ui = ui
	tab.context = context
	return tab
end

function TabShake:init(ui)
    SuperCls.init(self, ui)

    self.addFriendPanelLogic = AddFriendPanelLogic:create()
    self.addFriendPanelLogic:startUpdateLocation()

    self.title = self.ui:getChildByName("title")
    self.title:setPreferredSize(371, 48)
    self.title:setString(localize("add.friend.panel.tag.shake"))
    self.title:setAnchorPoint(ccp(0.5, 0.5))
    self.title:setPositionXY(302, 34)

    self:initContent()
end

function TabShake:__toActive(byDefault)
	SuperCls.__toActive(self, byDefault)
	self.tabShake:expand()
end

function TabShake:__toDeActive()
	SuperCls.__toDeActive(self)
	self.tabShake:hide()
end

function TabShake:initContent()
	--local content = self.ui:getChildByName("content")
	--if _G.isLocalDevelopMode then printx(0, "desc: ", tostring(content:getChildByName("lbl_desc"))) end

	self:_tabShake_init(self.ui:getChildByName("content"))
end

------------------------------------------
-- TabShake
------------------------------------------
function TabShake:_tabShake_init(ui)
	-- get & create controls
	self.tabShake = {}
	self.tabShake.ui = ui
	ui:getChildByName("_bg"):setVisible(false)
	self.tabShake.phUnit = ui:getChildByName("ph_unit")
	self.tabShake.retry = ui:getChildByName("btn_retry")
	self.tabShake.desc = ui:getChildByName("lbl_desc")
	self.tabShake.loadLabel = ui:getChildByName("lbl_loading")
	self.tabShake.desc:setVisible(true)
	self.tabShake.tip = ui:getChildByName("lbl_tip")
	self.tabShake.tip:setVisible(true)
	self.tabShake.bearNpc = ui:getChildByName("bearNpc")
	self.tabShake.tipBg = ui:getChildByName("tipBg")
	self.tabShake.animLeft = ui:getChildByName("img_left")
	self.tabShake.animLeft:setAnchorPointWhileStayOriginalPosition(ccp(0.2, -0.8))
	self.tabShake.animLeft:setRotation(-15.4)
	self.tabShake.animRight = ui:getChildByName("img_right")
	self.tabShake.animRight:setAnchorPointWhileStayOriginalPosition(ccp(0.8, -0.8))
	self.tabShake.animRight:setRotation(15.4)
	self.tabShake.signal1 = ui:getChildByName("img_signal1")
	self.tabShake.signal2 = ui:getChildByName("img_signal2")
	self.tabShake.signal3 = ui:getChildByName("img_signal3")
	self.tabShake.retry = GroupButtonBase:create(self.tabShake.retry)

	-- set strings
	self.tabShake.retry:setString(Localization:getInstance():getText("add.friend.panel.shake.retry"))
	self.tabShake.desc:setString(Localization:getInstance():getText("add_friend_dialog_peng"))
	self.tabShake.loadLabel:setString(Localization:getInstance():getText("add.friend.panel.shake.load"))
	self.tabShake.tip:setString(Localization:getInstance():getText("add.friend.panel.shake.tip"))

	-- save info
	local pos = self.tabShake.phUnit:getPosition()
	self.tabShake.phPosition = {x = pos.x, y = pos.y}
	local size = self.tabShake.phUnit:getGroupBounds().size
	self.tabShake.phSize = {width = size.width, height = size.height}
	self.tabShake.phUnit:removeFromParentAndCleanup(true)

	-- add event listeners
	local function onRetryTapped()
		self.addFriendPanelLogic:resetWaitingState()
		self.tabShake.contentList = self.tabShake.contentList or {}
		for k, v in ipairs(self.tabShake.contentList) do
			v:removeFromParentAndCleanup(true)
		end
		self.tabShake.friendSearchComplete = nil
		self:_tabShake_waitForShake()

		--
		DcUtil:addFriendShakeCancel()
	end
	self.tabShake.retry:addEventListener(DisplayEvents.kTouchTap, onRetryTapped)
	self.tabShake.hide = function()
		self.tabShake.ui:setVisible(false)
		self.tabShake.retry:setEnabled(false)
		if not self.tabShake.friendSearchComplete then
			self.tabShake.contentList = self.tabShake.contentList or {}
			for k, v in ipairs(self.tabShake.contentList) do v:removeFromParentAndCleanup(true) end
			for i = 1, #self.tabShake.contentList do table.remove(self.tabShake.contentList, 1) end
		end
		self.addFriendPanelLogic:stopWaitForShake()
	end
	self.tabShake.expand = function()
		if not self.tabShake.friendSearchComplete then
			if not self.addFriendPanelLogic:isWaitingState() then
				self.addFriendPanelLogic:resetWaitingState()
				self:_tabShake_waitForShake()
			end
		end
		self.tabShake.retry:setEnabled(true)
		self.tabShake.ui:setVisible(true)
	end
end

function TabShake:_tabShake_waitForShake()
	self.tabShake.retry:setVisible(false)
	self.tabShake.desc:setVisible(true)
	self.tabShake.loadLabel:setVisible(false)
	self.tabShake.tip:setVisible(true)
	self:_tabShake_playTipAnim()
	local function onCallback(data, context)
		if self.ui.isDisposed then return end
		self:_tabShake_playLoadAnim()
		self:_tabShake_searchFriend(context)
	end
	self.addFriendPanelLogic:waitForShake(onCallback, self.tabStatus)
end

function TabShake:_tabShake_searchFriend(tabStatus)
	local function reShake()
		if self.ui.isDisposed then return end
		self.addFriendPanelLogic:resetWaitingState()
		self:_tabShake_waitForShake()
	end
	local function onSuccess(data, context)
		if self.ui.isDisposed then return end
		if data and #data > 0 then
			self.tabShake.friendSearchComplete = true
			self:_tabShake_updateFriendInfo(data)
		else
			CommonTip:showTip(Localization:getInstance():getText("add.friend.panel.shake.no.user"), "negative", reShake)
		end
	end
	local function onFail(err, context)
		if self.ui.isDisposed then return end
		CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(err)), "negative", reShake)
		if __WP8 and err == 1016 then
			LocationManager:GetInstance():GotoSettingIfNecessary()
		end
	end
	self.tabShake.loadLabel:setVisible(true)
	self.tabShake.tip:setVisible(false)
	self.addFriendPanelLogic:sendPositionMessage(onSuccess, onFail, tabStatus)
	--[[
	onSuccess({{userName="12", userLevel = 12,  uid = 11335, hearUrl = "1"},
			   {userName="12", userLevel = 12,  uid = 11335, hearUrl = "1"},
			   {userName="12", userLevel = 12,  uid = 11335, hearUrl = "1"},
			   {userName="12", userLevel = 12,  uid = 11335, hearUrl = "1"},
			   {userName="12", userLevel = 12,  uid = 11335, hearUrl = "1"},
			   {userName="12", userLevel = 12,  uid = 11335, hearUrl = "1"},
			   {userName="12", userLevel = 12,  uid = 11335, hearUrl = "1"},
			   {userName="12", userLevel = 12,  uid = 11335, hearUrl = "1"},
			   {userName="12", userLevel = 12,  uid = 11335, hearUrl = "1"}
					  }, tabStatus)
]]
end

function TabShake:_tabShake_updateFriendInfo(data)
	self.tabShake.bearNpc:setVisible(false)
	self.tabShake.tipBg:setVisible(false)
	self.tabShake.animLeft:stopAllActions()
	self.tabShake.animLeft:setVisible(false)
	self.tabShake.animRight:stopAllActions()
	self.tabShake.animRight:setVisible(false)
	self.tabShake.ui:stopAllActions()
	self.tabShake.signal1:setVisible(false)
	self.tabShake.signal2:setVisible(false)
	self.tabShake.signal3:setVisible(false)
	self.tabShake.desc:setVisible(false)
	self.tabShake.loadLabel:setVisible(false)
	self.tabShake.tip:setVisible(false)
	self.tabShake.retry:setVisible(true)

	self.tabShake.contentList = self.tabShake.contentList or {}
	local numCount = 0
	for k, v in ipairs(data) do
		local elem = self:_tabShake_createResultUnit(v)
		if elem then
			elem:setPosition(ccp(self.tabShake.phPosition.x, self.tabShake.phPosition.y - 29 - self.tabShake.phSize.height * (k - 1)))
			self.tabShake.ui:addChild(elem)
			table.insert(self.tabShake.contentList, elem)
			numCount = numCount + 1
			if numCount >= 3 then break end
		end
	end

	DcUtil:addFriendShake(#data)
end

function TabShake:_tabShake_createResultUnit(data)
	-- init and create control
	local elem = self.context:buildInterfaceGroup("AddFriendPanel2/ShakeResultItem")
	elem.backGround = elem:getChildByName("_bg")
	elem.userHead = elem:getChildByName("img_userImage")
	elem.userName = elem:getChildByName("lbl_userName")
	elem.userLevel = elem:getChildByName("lbl_userLevel")
	elem.status = elem:getChildByName("lbl_status")
	elem.lblWaiting = elem:getChildByName("lbl_waiting")
	elem.imgAdd = elem:getChildByName("img_add")
	elem.imgComplete = elem:getChildByName("img_complete")

	-- define methods
	elem.add = function()
		elem:stopAllActions()
		elem.status:setString(Localization:getInstance():getText("add.friend.panel.shake.add"))
		elem.lblWaiting:setVisible(false)
		elem.imgAdd:setVisible(true)
		elem.imgComplete:setVisible(false)
	end
	elem.waiting = function()
		elem:stopAllActions()
		elem.status:setString(Localization:getInstance():getText("add.friend.panel.shake.waiting"))
		elem.lblWaiting:setVisible(true)
		elem.imgAdd:setVisible(false)
		elem.imgComplete:setVisible(false)
		local function setString()
			local len = string.len(elem.lblWaiting:getString()) + 1
			if len > 3 then len = 0 end
			local str = ""
			for i = 1, len do str = str..'.' end
			elem.lblWaiting:setString(str)
		end
		elem:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCCallFunc:create(setString), CCDelayTime:create(0.5))))
	end
	elem.complete = function()
		elem:stopAllActions()
		elem.status:setString(Localization:getInstance():getText("add.friend.panel.shake.complete"))
		elem.lblWaiting:setVisible(false)
		elem.imgAdd:setVisible(false)
		elem.imgComplete:setVisible(true)
		elem:setAnchorPoint(ccp(0.5, 0.5))
		
	end
	elem.bounce = function()
		elem.imgComplete:setAnchorPointWhileStayOriginalPosition(ccp(0.5, 0.5))
		elem.imgComplete:setScale(0.01)
		elem.imgComplete:runAction(CCEaseBackOut:create(CCScaleTo:create(0.1, 1)))
		local function scaleDown() if elem and not elem.isDisposed then elem:setScale(1.02) end end
		local function scaleUp() if elem and not elem.isDisposed then elem:setScale(1) end end
		local arr = CCArray:create()
		arr:addObject(CCDelayTime:create(0.1))
		arr:addObject(CCCallFunc:create(scaleDown))
		arr:addObject(CCDelayTime:create(0.1))
		arr:addObject(CCCallFunc:create(scaleUp))
		arr:addObject(CCDelayTime:create(0.1))
		arr:addObject(CCCallFunc:create(scaleDown))
		arr:addObject(CCDelayTime:create(0.1))
		arr:addObject(CCCallFunc:create(scaleUp))
		elem:runAction(CCSequence:create(arr))
	end

	-- set control
	local name = nameDecode(data.userName)
	if name and string.len(name) > 0 then 
		elem.userName:setString(name) 
	end
	if data.userLevel then
		elem.userLevel:setString(Localization:getInstance():getText("add.friend.panel.user.info.level", {n = data.userLevel}))
	end
	local userHead = HeadImageLoader:create(data.uid, data.headUrl, function ( headImg )

	end)
	if userHead then
		local position = elem.userHead:getPosition()
		userHead:setAnchorPoint(ccp(-0.5, 0.5))
		userHead:setPosition(ccp(position.x, position.y))
		userHead:setScale(0.8)
		elem.userHead:getParent():addChild(userHead)
		elem.userHead:removeFromParentAndCleanup(true)
	end
	if data.isFriend then elem.complete()
	else elem.add()
		if not elem or elem.isDisposed then return end
		-- add event listener
		local function onTouched()
			if RequireNetworkAlert:popout() then
				elem:setTouchEnabled(false)
				elem.waiting()
				self:_tabShake_sendAddMessage(data.uid, elem)
			end
		end
		elem:setTouchEnabled(true)
		elem:addEventListener(DisplayEvents.kTouchTap, onTouched)
	end
	
	return elem
end

function TabShake:_tabShake_sendAddMessage(uid, target)
	local function onSuccess(data, context)
		DcUtil:addFriendShakeNear()
		if self.ui.isDisposed then return end
		self:_tabShake_requestConfirm(uid, context)
	end
	local function onFail(err, context)
		if self.ui.isDisposed then return end
		if context.target and not context.target.isDisposed then
			context.target.add()
			context.target:setTouchEnabled(true)
		end
		if err then
			CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(err)), "negative")
		end
	end
	self.addFriendPanelLogic:sendShakeAddMessage(uid, onSuccess, onFail, {target = target, status = self.tabStatus})
end

function TabShake:_tabShake_requestConfirm(uid, iptPara)
	local function onSuccess(data, context)
		DcUtil:addFriendShakeConfirm()
		if self.ui.isDisposed or context.target.isDisposed then return end
		context.target.bounce()
		context.target.complete()
	end
	local function onFail(err, context)
		if self.ui.isDisposed then return end
		CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(err)), "negative")
	end
	-- self.addFriendPanelLogic:askForShakeAddResult(uid, onSuccess, onFail, iptPara)
	self.addFriendPanelLogic:askForShakeAddResult(uid, onSuccess, nil, iptPara)
end

function TabShake:_tabShake_playTipAnim()
	self.tabShake.bearNpc:setVisible(true)
	self.tabShake.tipBg:setVisible(true)
	local arr1 = CCArray:create()
	arr1:addObject(CCRotateTo:create(0.25, -15.4))
	arr1:addObject(CCRotateTo:create(0.1, 0))
	arr1:addObject(CCDelayTime:create(2))
	self.tabShake.animLeft:stopAllActions()
	self.tabShake.animLeft:setRotation(-15.4)
	self.tabShake.animLeft:setVisible(true)
	self.tabShake.animLeft:runAction(CCRepeatForever:create(CCSequence:create(arr1)))
	local arr2 = CCArray:create()
	arr2:addObject(CCRotateTo:create(0.25, 15.4))
	arr2:addObject(CCRotateTo:create(0.1, 0))
	arr2:addObject(CCDelayTime:create(2))
	self.tabShake.animRight:stopAllActions()
	self.tabShake.animRight:setRotation(15.4)
	self.tabShake.animRight:setVisible(true)
	self.tabShake.animRight:runAction(CCRepeatForever:create(CCSequence:create(arr2)))
	local arr3 = CCArray:create()
	arr3:addObject(CCDelayTime:create(0.35))
	local function onFadeIn()
		self.tabShake.signal1:setVisible(true)
		self.tabShake.signal2:setVisible(true)
		self.tabShake.signal3:setVisible(true)
	end
	arr3:addObject(CCCallFunc:create(onFadeIn))
	arr3:addObject(CCDelayTime:create(2))
	local function onFadeOut()
		self.tabShake.signal1:setVisible(false)
		self.tabShake.signal2:setVisible(false)
		self.tabShake.signal3:setVisible(false)
	end
	arr3:addObject(CCCallFunc:create(onFadeOut))
	self.tabShake.signal1:setOpacity(83)
	self.tabShake.signal1:setVisible(false)
	self.tabShake.signal2:setOpacity(83)
	self.tabShake.signal2:setVisible(false)
	self.tabShake.signal3:setOpacity(83)
	self.tabShake.signal3:setVisible(false)
	self.tabShake.ui:stopAllActions()
	self.tabShake.ui:runAction(CCRepeatForever:create(CCSequence:create(arr3)))
end

function TabShake:_tabShake_playLoadAnim()
	self.tabShake.animLeft:stopAllActions()
	self.tabShake.animRight:stopAllActions()
	self.tabShake.animLeft:runAction(CCRotateTo:create(0.1, -15))
	self.tabShake.animRight:runAction(CCRotateTo:create(0.1, 15))
	local function playConnectAnim()
		local arr = CCArray:create()
		local function signal1()
			self.tabShake.signal1:setOpacity(255)
			self.tabShake.signal2:setOpacity(83)
			self.tabShake.signal3:setOpacity(83)
		end
		arr:addObject(CCCallFunc:create(signal1))
		arr:addObject(CCDelayTime:create(0.5))
		local function signal2()
			self.tabShake.signal1:setOpacity(83)
			self.tabShake.signal2:setOpacity(255)
			self.tabShake.signal3:setOpacity(83)
		end
		arr:addObject(CCCallFunc:create(signal2))
		arr:addObject(CCDelayTime:create(0.5))
		local function signal3()
			self.tabShake.signal1:setOpacity(83)
			self.tabShake.signal2:setOpacity(83)
			self.tabShake.signal3:setOpacity(255)
		end
		arr:addObject(CCCallFunc:create(signal3))
		arr:addObject(CCDelayTime:create(0.5))
		self.tabShake.signal1:setVisible(true)
		self.tabShake.signal2:setVisible(true)
		self.tabShake.signal3:setVisible(true)
		self.tabShake.ui:stopAllActions()
		self.tabShake.ui:runAction(CCRepeatForever:create(CCSequence:create(arr)))
	end
	self.tabShake.ui:stopAllActions()
	self.tabShake.ui:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.1), CCCallFunc:create(playConnectAnim)))
end

return TabShake