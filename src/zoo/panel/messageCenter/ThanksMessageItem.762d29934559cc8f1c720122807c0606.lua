
local function jsmaLog( ... )
	-- if _G.isLocalDevelopMode  then printx(103 ,...) end
end 
local ThanksMessageSubItem = class(RequestMessageItemBase)

function ThanksMessageSubItem:init( ... )
    local ui = self.builder:buildGroup("request_message_panel/ThanksCellItem")
    ItemInClippingNode.init(self)
    self:setContent(ui)

	self.avatar_ico = ui:getChildByName("avatar_ico")
	self.name_text = ui:getChildByName("name_text")
	self.msg_text = ui:getChildByName("msg_text")
	self.line = ui:getChildByName("line")

	local dummy = { 
		setString=function( ... )end,
		setVisible=function( ... )end,
		setEnabled=function( ... )end,
	}
	self.ignoredTxt = dummy
	self.confirm = dummy
	self.cancel = dummy

	self:buildSyncAnimation()
end

function ThanksMessageSubItem:setData( requestInfo,last )
	RequestMessageItemBase.setData(self,requestInfo)

	if last then
		self.line:setVisible(false)
	end

	local textKeys = {}
	for i=4,9 do
		table.insert(textKeys,"message_desc_" .. i)
	end
	local friend = FriendManager.getInstance().friends[requestInfo.senderUid]
	if friend and friend.topLevelId == kMaxLevels then 
		table.insert(textKeys,"message_desc_3")
	end

	self.msg_text:setString(Localization:getInstance():getText(textKeys[math.random(1,#textKeys)]))
end

function ThanksMessageSubItem:onSendIgnoreSuccess(event, isBatch, triggerByPanel)
	RequestMessageItemBase.onSendIgnoreSuccess(self,event,isBatch, triggerByPanel)

	if self.sendIgnoreSuccessCallback then
		self.sendIgnoreSuccessCallback()
	end
end
function ThanksMessageSubItem:onSendIgnoreFail(event, isBatch)
	RequestMessageItemBase.onSendIgnoreFail(self,event,isBatch)

	if self.sendIgnoreFailCallback then
		self.sendIgnoreFailCallback()
	end
end

function ThanksMessageSubItem:setSendIgnoreSuccessCallback(sendIgnoreSuccessCallback)
	self.sendIgnoreSuccessCallback = sendIgnoreSuccessCallback
end

function ThanksMessageSubItem:setSendIgnoreFailCallback( sendIgnoreFailCallback )
	self.sendIgnoreFailCallback = sendIgnoreFailCallback
end

function ThanksMessageItem:init( ... )
    local ui = self.builder:buildGroup("request_message_panel/ThanksCell")
    ItemInClippingNode.init(self)
    self:setContent(ui)

    self.msgText = ui:getChildByName("msg_text")
    
    self.cancel = ui:getChildByName("cancel")
    self.cancel:setButtonMode(true)
    self.cancel:setTouchEnabled(true)
    self.cancel.setEnabled = self.cancel.setTouchEnabled
    self.confirm = GroupButtonBase:create(ui:getChildByName("confirm_button"))
    self.confirm:setColorMode(kGroupButtonColorMode.green)
	self.confirm:setString("答谢")

    self.selected = ui:getChildByName("selected")
    self.selected:setVisible(false)

    self.ignoredTxt = ui:getChildByName('ignoredTxt')
    self.ignoredTxt:setString(Localization:getInstance():getText('message.center.disagree.already.text'))
    self.ignoredTxt:setVisible(false)

    local function onTouchCancel(event) 
    	self:sendIgnore(false)
    end
    local function onTouchConfirm(event) 
    	self:sendAccept(false)
   	end
    self.cancel:ad(DisplayEvents.kTouchTap, onTouchCancel)
    self.confirm:ad(DisplayEvents.kTouchTap, onTouchConfirm)

	self:buildSyncAnimation()
	-- 
	self.ui = ui
	self.bg = ui:getChildByName("bg")
	self.bg2 = ui:getChildByName("bg2")

end


function ThanksMessageItem:isThanksCell()
	return true
end

function ThanksMessageItem:setData(requestInfo)
	self.requestInfo = requestInfo

    self.msgText:setRichText("[#D67721]".. #requestInfo .."[/#]位好友\n恭贺你通关啦","603D2B")

	local layout = VerticalTileLayout:create(100)
	layout:setItemVerticalMargin(0)

	self.cells = {}
	for i=1,#self.requestInfo do
		local cell = ThanksMessageSubItem.new()
		cell:loadRequiredResource(PanelConfigFiles.request_message_panel)
		cell:init()
		cell:setData(self.requestInfo[i],i==#self.requestInfo)
		cell:setPanelRef(self.panel)
		
		local item = VerticalTileItem.new(CCNode:create())
		item:setContent(cell)
		item:setHeight(150)

		layout:addItem(item)

		table.insert(self.cells,cell)
	end

	self.bg2:setPreferredSize(CCSizeMake(
		self.bg2:getPreferredSize().width,
		layout:getHeight() + 15
	))
	layout:setPositionY(layout:getHeight() + 20)
	self.bg2:addChild(layout)

	self:setHeight(173 + layout:getHeight() + 2)

	self.ui:setTouchEnabled(true)
	self.ui:ad(DisplayEvents.kTouchTap, function( ... )
		if self.bg2:isVisible() then
			self.bg2:setVisible(false)
			self:setHeight(170)
		else
			self.bg2:setVisible(true)
			self:setHeight(173 + layout:getHeight() + 2)
		end

		self.parentLayout:addItemBatch({})
		self.parentView:setScrollableHeight(self.parentLayout:getHeight())
	end)
	self.ui.hitTestPoint = function ( s, worldPosition, useGroupTest )
		for k,v in pairs({self.confirm.groupNode,self.cancel}) do
			if v:isVisible() and v:hitTestPoint(worldPosition, useGroupTest) then
				return false
			end
		end
		if not self.bg2:isVisible() then
			return self.bg:hitTestPoint(worldPosition, useGroupTest)
		else
			return Layer.hitTestPoint(s,worldPosition, useGroupTest)
		end
	end
	
end


-- function ThanksMessageItem:onSendIgnoreSuccess(event, isBatch)
--     GlobalEventDispatcher:getInstance():dispatchEvent(Event.new(kGlobalEvents.kMessageCenterUpdate))
--     -- TODO: remove

-- end
function ThanksMessageItem:onSendIgnoreSuccess( event, isBatch )
	RequestMessageItemBase.onSendAcceptSuccess(self,event,isBatch, triggerByPanel)
end

function ThanksMessageItem:sendAccept(isBatch, triggerByPanel)
	
	-- jsmaLog(" ThanksMessageItem:sendAccept ")
	if self:isInRequest() then return end
    if self:hasCompleted() then return end

    self:showSyncAnimation(true)
    self:showButtons(false)
	if not triggerByPanel then
		self.panel:cancelAllThanksItem()
    	self.ignoredTxt:setString("已答谢")
    else
    	RequestMessageItemBase.sendIgnore(self, isBatch, triggerByPanel)
	end
end
function ThanksMessageItem:sendIgnore(isBatch, triggerByPanel)
	
	jsmaLog(" ThanksMessageItem:sendIgnore ")

	if self:isInRequest() then return end
    if self:hasCompleted() then return end

    self:showSyncAnimation(true)
    self:showButtons(false)

    local count = 0
	local function sendIgnoreSuccessCallback( event )
		-- count = count + 1
		-- if count >= #self.cells then
		-- 	jsmaLog(" ThanksMessageItem:sendIgnoreSuccessCallback ")
		-- 	self:onSendIgnoreSuccess(event, isBatch, triggerByPanel)
		-- end	

		self:onSendIgnoreSuccess(event, isBatch, triggerByPanel)
		jsmaLog(" ThanksMessageItem:sendIgnoreSuccessCallback 5")
	end

	local function sendIgnoreFailCallback( ... )
		jsmaLog(" ThanksMessageItem:sendIgnoreFailCallback ")
		self:onSendAcceptFail(event, isBatch)
	end

	if not triggerByPanel then
		if not isBatch then
			ConnectionManager:block()
		end
    	for k,v in pairs(self.cells) do
    		v:setSendIgnoreSuccessCallback(sendIgnoreSuccessCallback)
    		v:setSendIgnoreFailCallback(sendIgnoreFailCallback)
    		RequestMessageItemBase.sendIgnore(self, v,true)
    	end
    	if not isBatch then
    		ConnectionManager:flush()
    	end
    else
    	RequestMessageItemBase.sendIgnore(self, isBatch, triggerByPanel)
	end
end

function ThanksMessageItem:onMessageLifeFinished()
	-- for k,v in pairs(self.cells) do
	-- 	RequestMessageItemBase.onMessageLifeFinished(self)
	-- end
	RequestMessageItemBase.onMessageLifeFinished(self)
end


-- 只有一条感谢
function OneThanksMessageItem:setData( requestInfo )
	RequestMessageItemBase.setData(self,requestInfo)

	local textKeys = {}
	for i=4,9 do
		table.insert(textKeys,"message_desc_" .. i)
	end
	local friend = FriendManager.getInstance().friends[requestInfo.senderUid]
	if friend and friend.topLevelId == kMaxLevels then 
		table.insert(textKeys,"message_desc_3")
	end

	self.msg_text:setString(Localization:getInstance():getText(textKeys[math.random(1,#textKeys)]))

	self:setHeight(173)

	self.confirm:setString("答谢")
end

function OneThanksMessageItem:sendAccept(isBatch, triggerByPanel)
	function self:onSendIgnoreSuccess( event, isBatch )
		RequestMessageItemBase.onSendAcceptSuccess(self,event,isBatch, triggerByPanel)
	end
	RequestMessageItemBase.sendIgnore(self, isBatch, triggerByPanel)
end

function OneThanksMessageItem:sendIgnore(isBatch, triggerByPanel)
	function self:onSendIgnoreSuccess( event, isBatch )
		RequestMessageItemBase.onSendIgnoreSuccess(self, event,isBatch, triggerByPanel)
	end
	RequestMessageItemBase.sendIgnore(self, isBatch, triggerByPanel)
end