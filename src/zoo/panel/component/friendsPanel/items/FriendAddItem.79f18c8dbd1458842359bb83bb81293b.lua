require 'zoo.util.CloverUtil'
local DataTracking = require "zoo.panel.component.friendsPanel.misc.DataTracking"
local PrivateStrategy = require 'zoo.data.PrivateStrategy'
FriendAddItem = class(ItemInClippingNode)
function FriendAddItem:loadRequiredResource(panelConfigFile)
    self.panelConfigFile = panelConfigFile
    self.builder = InterfaceBuilder:createWithContentsOfFile(panelConfigFile)
end

function FriendAddItem:buildUi()
    return self.builder:buildGroup("interface/add_friend_item")
end

-- call in subclasses
function FriendAddItem:init()
    self.type = 0

    self._isInRequest = false
    self._hasCompleted = false

    local ui = self:buildUi()
    ItemInClippingNode.init(self)
    self:setContent(ui)
    self.ui = ui

    self.icons = ui:getChildByName("icons")

    self.confirm = GroupButtonBase:create(ui:getChildByName("confirm_button"))
    self.confirm:setColorMode(kGroupButtonColorMode.green)

    self.descTxt = ui:getChildByName('descTxt')
    self.descTxt:setVisible(false)

    local size = self.ui:getGroupBounds().size
    self:setHeight(size.height) 

    local function onTouchConfirm(event)
        local isFull,noZombie = FriendsFullPanel:checkFullZombieShow()
        if isFull then
            if noZombie then
                self.panel:gotoPageIndex(1)
            end
            return
        end

        if self.type == 2 then
            local SearchIDPanel = require "zoo.panel.component.friendsPanel.func.SearchIDPanel"
            SearchIDPanel:create():popout()
            DataTracking:addFriendByXXLId()
        elseif self.type == 1 then
            local function onPermissionGranted()
                self:loadFriendsByContact()
            end
            local function checkPrivateStrategy()
                PermissionManager.getInstance():requestEach(PermissionsConfig.READ_CONTACTS, onPermissionGranted)
            end
            PrivateStrategy:sharedInstance():Alert_Friends( checkPrivateStrategy )
        end
    end


        
    


    self.confirm:ad(DisplayEvents.kTouchTap, onTouchConfirm)

    self.ui:getChildByName('ph'):setVisible(false)
    self.ui:getChildByName('ph2'):setVisible(false)

    local touchArea = self.ui:getChildByName("touchArea")
	touchArea:setTouchEnabled(true, 0, true)
	touchArea:ad(DisplayEvents.kTouchTap, function(event) 
	    end)
	self.touchArea = touchArea
end

function FriendAddItem:loadFriendsByContact()
	if self.isDisposed or self.isRequestingPhoneFriends then
		return
	end
	local loadFriendsLogic = require("zoo.panel.addFriend2.LoadFriendsLogic"):create()

	local function onLoadSuccess(items4Show, dataProvider)
		if #items4Show == 0 then
			CommonTip:showTip(localize("add.friend.panel.add.phone.tip1"), "negative",nil, 2)
        else
            local function onCloseCallback()
                if not UserManager.getInstance().profile:isPhoneBound() then
                    PushBindingLogic:tryPopout(function () end)
                end
            end
			local panel = require("zoo.panel.component.friendsPanel.func.ChoosePhoneUserPanel"):create(items4Show, dataProvider, onCloseCallback)
			panel:popout()
		end
		self.isRequestingPhoneFriends = false
	end

	local function isNetworkError(errorCode)
		return errorCode == -2 or errorCode == -6 or errorCode == -7
	end

	local function onLoadError(errCode)
		if errCode == 600 then
			CommonTip:showTip(Localization:getInstance():getText("add.friend.panel.add.qq.tip6"), "negative", nil, 3)
		elseif errCode == 200 then
			CommonTip:showTip(Localization:getInstance():getText("dis.connect.warning.tips"))
		elseif errCode == 100 then
			CommonTip:showTip("读取联系人信息失败！", "negative",nil, 2)
		elseif isNetworkError(errCode) then
			CommonTip:showTip(localize("dis.connect.warning.tips"), "negative",nil, 2)
		else
			CommonTip:showTip("无法获取您的手机好友的信息！", "negative",nil, 2)
		end
		self.isRequestingPhoneFriends = false
	end

	local function onloadCancel()
		self.isRequestingPhoneFriends = false
	end

	self.isRequestingPhoneFriends = true
	loadFriendsLogic:loadFriendsInContacts(onLoadSuccess, onLoadError, onloadCancel)
end

function FriendAddItem:setPageIndex(index)
    self.pageIndex = index
end

function FriendAddItem:setParentLayout( layout )
    self.parentLayout = layout
end

function FriendAddItem:showDescText(text)
    if self.descTxt then
        self.descTxt:setVisible(true)
        self.descTxt:setOpacity(255)
        self.descTxt:setString(text)
    end
end

function FriendAddItem:setPanelRef(ref)
    self.panel = ref
end

function FriendAddItem:enableAcceptButton(enable)
    if self.isDisposed then return end
    if enable ~= true and enable ~= false then enable = false end
    self.enabled = enable
    self.confirm:setEnabled(enable)
end

function FriendAddItem:updateSelf()
end

function FriendAddItem:dispose()
    CocosObject.dispose(self)
end

function FriendAddItem:setData(data)
    self.type = data

    local function setIcon(canvas, state, maxStates)
        for i=1, maxStates do
            canvas:getChildByName(tostring(i)):setVisible(i==state)
        end
    end

    local MAX_STATES = 2
    setIcon(self.icons, self.type, MAX_STATES)

    local descKey = "friends.panel.addFriends.item.desc." ..tostring(data)
    self:showDescText(Localization:getInstance():getText(descKey))
    self.confirm:setString(Localization:getInstance():getText("friends.panel.addFriends.item.btn"))
end
