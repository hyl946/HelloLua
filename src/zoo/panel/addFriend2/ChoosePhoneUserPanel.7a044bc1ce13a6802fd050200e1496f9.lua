

local ChoosePhoneUserPanel = class(BasePanel)

function ChoosePhoneUserPanel:create(profiles, closeCallback)
	local panel = ChoosePhoneUserPanel.new()
	panel:loadRequiredResource("ui/AddFriendPanel2.json")
	panel:init(profiles, closeCallback)

	return panel
end

function ChoosePhoneUserPanel:init(profiles, closeCallback)
	self.ui = self:buildInterfaceGroup("AddFriendPanel2/ChoosePhoneUserPanel")
    BasePanel.init(self, self.ui)

    self.title = self.ui:getChildByName("title")
    self.title:setAnchorPoint(ccp(0.5, 0.5))
    self.title:setPreferredSize(286, 48)
    self.title:setString(localize("add.friend.panel.tag.BindPhone.btn"))

	self.closeCallback = closeCallback

    self.profiles = profiles
    self:initCloseButton()
    self:initContent()
end

function ChoosePhoneUserPanel:initContent()
	self.listBg = self.ui:getChildByName("content")
	self.listSize = self.listBg:getGroupBounds().size
	self.listPos = ccp(self.listBg:getPositionX(), self.listBg:getPositionY())
	self.listHeight = self.listSize.height
	self.listWidth = self.listSize.width

	self.listBg:removeFromParentAndCleanup(true)

	self:buildGridLayout()
end

local function createChooseFriendList(onTileItemTouch, minWidth, minHeight, view, profiles)

	local container = GridLayout:create()
	container:setWidth(minWidth)
	container:setColumn(2)
	container:setItemSize(CCSizeMake(275, 95))
	container:setColumnMargin(25)
	container:setRowMargin(11.8)

	for _, v in ipairs(profiles) do
		local layoutItem = require("zoo.panel.addFriend2.ChoosePhoneItem"):create(v, onTileItemTouch)
		layoutItem:setParentView(view)
		container:addItem(layoutItem, false)
	end

	return container
end

function ChoosePhoneUserPanel:buildGridLayout()

	local function onTileItemTouch(item)
		if item then
		end
	end

	self.numberOfFriends = #self.profiles
	if self.numberOfFriends > 10 then --need to be scrollable
		self.scrollable = VerticalScrollable:create(self.listWidth, self.listHeight, true, false)
		self.content = createChooseFriendList(onTileItemTouch, self.listWidth, self.listHeight, self.scrollable, self.profiles)

		self.scrollable:setContent(self.content)
		self.scrollable:setPositionXY(self.listPos.x + 2, self.listPos.y + 3)
		self.ui:addChild(self.scrollable)
		self.title:setPositionXY(324, -49)
	else
		self.content = createChooseFriendList(onTileItemTouch, self.listWidth, self.listHeight, self.ui, self.profiles)
		self.content:setPositionXY(self.listPos.x + 3, self.listPos.y + 6.5)
		self.ui:addChild(self.content)

		self:updateBGSize(self.numberOfFriends)
		self.title:setPositionXY(324, -49)
	end
end

function ChoosePhoneUserPanel:appendItems(items4Append)
	for _, v in ipairs(items4Append) do
		local layoutItem = require("zoo.panel.addFriend2.ChoosePhoneItem"):create(v, nil)
		layoutItem:setParentView(self.scrollable)
		self.content:addItem(layoutItem, false)
	end

	if self.scrollable.content then
		self.scrollable:updateScrollableHeight()
	end
end

local baseHeight = 235
local heightList = {baseHeight, baseHeight, baseHeight + 107, baseHeight + 107 *2, baseHeight + 107 *3}
function ChoosePhoneUserPanel:updateBGSize(profileCount)

	local rows = math.floor((profileCount+1)/2)
	local curHeight = heightList[rows]

	local bg1 = self.ui:getChildByName("bg1")
	local bg2 = self.ui:getChildByName("bg2")

	local size = bg1:getGroupBounds().size
	bg1:setPreferredSize(CCSizeMake(size.width, curHeight + 102))

	local size2 = bg2:getGroupBounds().size
	bg2:setPreferredSize(CCSizeMake(size2.width, curHeight))

end

function ChoosePhoneUserPanel:initCloseButton()
	self.closeBtn = self.ui:getChildByName("closeBtn")
    self.closeBtn:setTouchEnabled(true, 0, true)
    self.closeBtn:setButtonMode(true)
    self.closeBtn:addEventListener(DisplayEvents.kTouchTap, 
        function() 
            self:onCloseBtnTapped()
        end)
end

function ChoosePhoneUserPanel:onKeyBackClicked(...)
	if type(self.closeCallback) == "function" then self.closeCallback() end
	BasePanel.onKeyBackClicked(self)
end

local loadFriendsLogic = require("zoo.panel.addFriend2.LoadFriendsLogic"):create()

function ChoosePhoneUserPanel:loadRemaining()
	local remainingUids = loadFriendsLogic:getRemainingUids()
	local function onSuccess(items4Append)
		self.isLoadingRemaining = false
		if self.isDisposed or #remainingUids == 0  then
			return
		end

		self:appendItems(items4Append)
	end

	local function onCancel()
		self.isLoadingRemaining = false
	end

	local function onError()
		self.isLoadingRemaining = false
	end
	
	if not self.isDisposed and #remainingUids > 0 and not self.isLoadingRemaining then
		loadFriendsLogic:loadProfilesByUids(remainingUids, onSuccess)
		self.isLoadingRemaining = true
	end
end

function ChoosePhoneUserPanel:popout()
	self:setPositionForPopoutManager()
	self.allowBackKeyTap = true
	PopoutManager:sharedInstance():add(self, true, false)

	if self.scrollable then
		self.scrollable:addEventListener(ScrollableEvents.kEndMoving, function()
				if _G.isLocalDevelopMode then printx(0, "on scroll end!!!!!!!!!!!!!") end
				self:loadRemaining()
			end)
	end
end

function ChoosePhoneUserPanel:popoutShowTransition()
	self.allowBackKeyTap = true
end

function ChoosePhoneUserPanel:onCloseBtnTapped()
	if type(self.closeCallback) == "function" then self.closeCallback() end
	PopoutManager:sharedInstance():remove(self, true)
end

function ChoosePhoneUserPanel:unloadRequiredResource()

end

return ChoosePhoneUserPanel