require "zoo.panel.basePanel.BasePanel"

SeasonWeeklyRacePassPanel = class(BasePanel)

function SeasonWeeklyRacePassPanel:create(friendIds, surpassNationType)
	local panel = SeasonWeeklyRacePassPanel.new()
	panel:init(friendIds, surpassNationType)
	return panel
end

local assumeShareReward = {itemId = 2, num = 100}

function SeasonWeeklyRacePassPanel:init(friendIds, surpassNationType)
	self.surpassNationType = surpassNationType or false
	self:loadRequiredResource("ui/panel_summer_weekly_share.json")
	local ui = self:buildInterfaceGroup('SummerWeeklyRacePanel/PassPanel')
	BasePanel.init(self, ui)

	local realPlistPath, realPngPath = SpriteUtil:addSpriteFramesWithFile("ui/NewSharePanel.plist", "ui/NewSharePanel.png")
	SpriteUtil:removeLoadedPlist("ui/NewSharePanel.plist")
	if not __WP8 then
		CCTextureCache:sharedTextureCache():removeTextureForKey(realPngPath)
		CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile(realPlistPath)
	else
		CCTextureCache:sharedTextureCache():removeUnusedTextures()
	end

	local button = GroupButtonBase:create(ui:getChildByName("shareBtn"))
	button:setString(Localization:getInstance():getText("weeklyrace.winter.panel.button2"))
	button:addEventListener(DisplayEvents.kTouchTap, function() self:onBtnTapped(friendIds) end)
	self.button = button

	local btnTag = ui:getChildByName("btnTag")
	local shareReward = assumeShareReward
	local icon = btnTag:getChildByName("icon")
	icon:setVisible(false)
	local sprite
	if shareReward.itemId == 2 then
		sprite = ResourceManager:sharedInstance():buildGroup("itemIcon2")
	elseif shareReward.itemId == 14 then
		sprite = Sprite:createWithSpriteFrameName("wheel0000")
		sprite:setAnchorPoint(ccp(0, 1))
	else
		if ItemType:isTimeProp(shareReward.itemId) then
			ItemType:getRealIdByTimePropId(shareReward.itemId)
		end
		sprite = ResourceManager:sharedInstance():buildItemGroup(shareReward.itemId)
	end
	local size = sprite:getGroupBounds().size
	size = {width = size.width, height = size.height}
	local iSize = icon:getGroupBounds().size
	sprite:setScale(iSize.width / size.width)
	if sprite:getScale() > iSize.height / size.height then
		sprite:setScale(iSize.height / size.height)
	end
	sprite:setPositionX(icon:getPositionX() + (iSize.width - size.width * sprite:getScale()) / 2)
	sprite:setPositionY(icon:getPositionY() - (iSize.height - size.height * sprite:getScale()) / 2)
	btnTag:addChildAt(sprite, btnTag:getChildIndex(icon))
	local number = btnTag:getChildByName("number")
	number:setText('+'..tostring(shareReward.num))
	local nSize = number:getContentSize()
	number:setPositionX(icon:getPositionX() + (iSize.width - nSize.width) / 2)
	btnTag:setVisible(false)

	local shareTip = ui:getChildByName("shareTip")
	local firstShare = SeasonWeeklyRaceManager:getInstance():isDailyFirstShare()
	shareTip:setVisible(firstShare)

	self:scaleAccordingToResolutionConfig()
	self:setPositionForPopoutManager()

	local vOrigin = Director:sharedDirector():getVisibleOrigin()
	local ovSize = Director:sharedDirector():ori_getVisibleSize()
	local layer = LayerColor:create()
	layer:setAnchorPoint(ccp(0, 1))
	layer:ignoreAnchorPointForPosition(false)
	layer:changeWidthAndHeight(ovSize.width / self:getScale(), ovSize.height / self:getScale())
	layer:setColor(ccc3(0, 0, 0))
	layer:setOpacity(176)
	layer:setPositionXY(-self:getPositionX() / self:getScale(), (_G.__EDGE_INSETS.top-self:getPositionY()) / self:getScale())
	self:addChildAt(layer, 0)

	local vSize = Director:sharedDirector():getVisibleSize()
	local close = ui:getChildByName("closeBtn")
	close:setPositionX((vSize.width - self:getPositionX()) / self:getScale() - 40)
	close:setPositionY(-self:getPositionY() / self:getScale() - 40)
	close:setTouchEnabled(true)
	close:setButtonMode(true)
	close:addEventListener(DisplayEvents.kTouchTap, function() self:onCloseBtnTapped() end)
	self.close = close

	self:setAnimation(ui)
end

function SeasonWeeklyRacePassPanel:getAnimTitleStr()
	if self.surpassNationType then
		return localize('push.binding.season.weekly.over.nation.'..self.surpassNationType)
	else
		return localize("show_off_desc_130")
	end
end

function SeasonWeeklyRacePassPanel:onBtnTapped(friendIds)
	DcUtil:UserTrack({category = "show", sub_category = "push_show_off", action = 'button', id = 270, t1=270})
	if self.surpassNationType then
		self:onBtnTappedPassNation()
	else
		self:onBtnTappedPassFriend(friendIds)
	end
end

function SeasonWeeklyRacePassPanel:onBtnTappedPassNation()
	-- local function onConnectFinish()
	-- 	if self.isDisposed then return end
		-- local function onSyncQQFriendSuccess()
		-- 	if self.isDisposed then return end
			
		-- 	self:unregSyncListeners()
			local numberOfFriendsAfterSync = FriendManager.getInstance():getFriendCount()
			if numberOfFriendsAfterSync <= 0 then
				CommonTip:showTip('还没有好友哦', 'positive')
			else
				local friendIds = {}
				for k, v in pairs(FriendManager:getInstance().friends) do
					table.insert(friendIds, k)
				end

				local function onSuccess(event)
					DcUtil:UserTrack({category = "show", sub_category = "push_show_off", action = 'success', id = 270, t1=270})
			        if self.isDisposed then return end
					CommonTip:showTip(Localization:getInstance():getText("show_off_to_friend_success"), "positive")
					self:onCloseBtnTapped()
				end
				local function onFail()
					if self.isDisposed then return end
					CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(evt.data)), "negative")
					self.button:setEnabled(true)
				end
				local function onCancel()
					if self.isDisposed then return end
					self.button:setEnabled(true)
				end
				self.button:setEnabled(false)
				SeasonWeeklyRaceManager:getInstance():sendPassNationNotify(friendIds, onSuccess, onFail, onCancel)
			end
	-- 	end

	-- 	local function onSyncQQFriendFailed()
	-- 		self:unregSyncListeners()
	-- 	end
	-- 	self:regSyncListeners(onSyncQQFriendSuccess, onSyncQQFriendFailed)
	-- end
	-- local function onConnectError()
	-- 	if self.isDisposed then return end
	-- 	-- CommonTip:showTip('绑定出错', 'negative')
	-- end
	-- local function onConnectCancel()
	-- 	if self.isDisposed then return end
	-- 	-- CommonTip:showTip('已取消', 'positive')
	-- end
	-- AccountBindingLogic:bindNewSns(PlatformAuthEnum.kQQ, onConnectFinish, onConnectError, onConnectCancel, AccountBindingSource.SEASON_WEEK_PASS_PANEL, hasReward)
end

function SeasonWeeklyRacePassPanel:regSyncListeners(onSuccess, onFail)
	self.onSyncSuccessListener = onSuccess
	self.onSyncFailedListener = onFail
	if self.onSyncSuccessListener then
		GlobalEventDispatcher:getInstance():addEventListener(SyncSnsFriendEvents.kSyncSuccess, self.onSyncSuccessListener)
	end
	if self.onSyncFailedListener then
		GlobalEventDispatcher:getInstance():addEventListener(SyncSnsFriendEvents.kSyncFailed, self.onSyncFailedListener)
	end
end

function SeasonWeeklyRacePassPanel:unregSyncListeners()
	if self.onSyncSuccessListener then
		GlobalEventDispatcher:getInstance():removeEventListener(SyncSnsFriendEvents.kSyncSuccess, self.onSyncSuccessListener)
		self.onSyncSuccessListener = nil
	end
	if self.onSyncFailedListener then
		GlobalEventDispatcher:getInstance():removeEventListener(SyncSnsFriendEvents.kSyncFailed, self.onSyncFailedListener)
		self.onSyncFailedListener = nil
	end
end

function SeasonWeeklyRacePassPanel:onBtnTappedPassFriend(friendIds)
	local function onSuccess(isAddCount)
		DcUtil:UserTrack({category = "show", sub_category = "push_show_off", action = 'success', id = 270, t1=270})
		if self.isDisposed then return end
		if isAddCount then
			CommonTip:showTip(Localization:getInstance():getText("weeklyrace.winter.panel.tip4"), "positive")
		else
			CommonTip:showTip(Localization:getInstance():getText("show_off_to_friend_success"), "positive")
		end
		self:onCloseBtnTapped()
	end
	local function onFail(evt)
		if self.isDisposed then return end
		CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(evt.data)), "negative")
		self.button:setEnabled(true)
	end
	local function onCancel()
		if self.isDisposed then return end
		self.button:setEnabled(true)
	end

	local function onChooseFriend(friendIds)
		if self.isDisposed then return end
		if #friendIds > 0 then
			self.button:setEnabled(false)
			SeasonWeeklyRaceManager:getInstance():sendPassNotify(friendIds, onSuccess, onFail, onCancel)
		else
			CommonTip:showTip(Localization:getInstance():getText("unlock.cloud.panel.request.friend.noselect"), "positive")
		end
	end
	
	local friends = {}
	for i, v in ipairs(friendIds) do
		table.insert(friends, tostring(v))
	end
	onChooseFriend(friends)
end

function SeasonWeeklyRacePassPanel:setAnimation(ui)
	FrameLoader:loadArmature('skeleton/share_120_animation', 'share_120_animation', 'share_120_animation')
	self.animNode = ArmatureNode:create('SharePassFriend', true)
	self.animNode:setScale(1.2)
	self.ui:addChildAt(self.animNode, 0)
	self.animNode:setPositionXY(300, -825)
	local slot = self.animNode:getSlot('txt')
    local text = BitmapText:create(self:getAnimTitleStr(), 'fnt/share.fnt', 0)
    text:setAnchorPoint(ccp(0.5, 0.5))
    local sprite = Sprite:createEmpty()
    sprite:addChild(text)
    slot:setDisplayImage(sprite.refCocosObj)
    self.animNode:playByIndex(0, 1)
end

function SeasonWeeklyRacePassPanel:popout(onCloseCallback)
	PopoutManager:sharedInstance():add(self)
	self.allowBackKeyTap = true
	self.onCloseCallback = onCloseCallback
end

function SeasonWeeklyRacePassPanel:onCloseBtnTapped()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
	if type(self.onCloseCallback) == "function" then self.onCloseCallback() end
end

function SeasonWeeklyRacePassPanel:playAnim()
	local scene = HomeScene:sharedInstance()
	if not scene then return end
	scene:checkDataChange()
	for i, v in ipairs(self.items) do
		local anim = FlyItemsAnimation:create({v})
        local bounds = v.item:getGroupBounds()
        anim:setWorldPosition(ccp(bounds:getMidX(),bounds:getMidY()))
        anim:play()
	end
end

function SeasonWeeklyRacePassPanel:dispose()
	self:unregSyncListeners()
	BasePanel.dispose(self)
end