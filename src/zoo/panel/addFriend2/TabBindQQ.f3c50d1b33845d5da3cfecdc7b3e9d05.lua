-- local SuperCls = require("zoo.panel.addFriend2.TabShow")
-- local TabBindQQ = class(SuperCls)

-- local BTN_LOGIC = {NONE = 0, NOT_BIND = 1, HAS_BIND = 2}

-- function TabBindQQ:create(ui, context)
-- 	local tab = TabBindQQ.new()
-- 	tab.ui = ui
-- 	tab.context = context
-- 	return tab
-- end

-- function TabBindQQ:init(ui)
--     SuperCls.init(self, ui)
--     self:initOkBtn()

--     self.title = self.ui:getChildByName("title")
--     self.title:setPreferredSize(282, 48)
--     self.title:setString(localize("add_friend_title_qq"))
--     self.title:setAnchorPoint(ccp(0.5, 0.5))
--     self.title:setPositionXY(302, 34)

--     local imgPath = SpriteUtil:getRealResourceName("materials/AddFriendPanel2_Decor.png")
--     imgPath = CCFileUtils:sharedFileUtils():fullPathForFilename(imgPath)
-- 	local texture = CCTextureCache:sharedTextureCache():addImage(imgPath)
-- 	local decor = Sprite:createWithTexture(texture)
-- 	decor:setAnchorPoint(ccp(0, 0))
-- 	decor:setPositionXY(204, 160)
-- 	self.ui:getChildByName("QQTab_bg"):addChild(decor)
-- end

-- function TabBindQQ:setHasBind(hasBind)
-- 	if hasBind then
-- 		self.okBtnLogic = BTN_LOGIC.HAS_BIND
-- 	else
-- 		self.okBtnLogic = BTN_LOGIC.NOT_BIND
-- 	end
-- end

-- function TabBindQQ:dispose()
-- 	local imgPath = SpriteUtil:getRealResourceName("materials/AddFriendPanel2_Decor.png")
--     imgPath = CCFileUtils:sharedFileUtils():fullPathForFilename(imgPath)
-- 	CCTextureCache:sharedTextureCache():removeTextureForKey(imgPath)
-- end

-- function TabBindQQ:initOkBtn( ... )
-- 	self:setHasBind(self.context.bindQQBtn:getHasBind())
-- 	self.okBtn = ButtonIconsetBase:create(self.ui:getChildByName("btn"))
--     self.okBtn:setIconByFrameName("AddFriendPanel2/QQIcon_0000")
--     self.okBtn:setString(localize("add.friend.panel.tag.BindQQ.btn"))
	
-- 	local numberOfFriendsBeforeSync = FriendManager.getInstance():getFriendCount()
-- 	if _G.isLocalDevelopMode then printx(0, "numberOfFriendsBeforeSync: "..tostring(numberOfFriendsBeforeSync)) end

-- 	local function onSyncQQFriendSuccess()
-- 		if self.isDisposed then
-- 			return
-- 		end
		
-- 		self.context.bindQQBtn:setHasBind(true)--btn 会调用TabBindQQ的setHasBind函数，将logic置为 self.okBtnLogic = BTN_LOGIC.HAS_BIND
-- 		local newAddedSnsFriends = FriendManager.getInstance():getNewAddedSnsFriendIds()
-- 		if numberOfFriendsBeforeSync >= FriendManager:getInstance():getMaxFriendCount() then
-- 			newAddedSnsFriends = {}
-- 		end
-- 		if _G.isLocalDevelopMode then printx(0, "newAddedSnsFriends: "..table.serialize(newAddedSnsFriends)) end
-- 		DcUtil:UserTrack({ category='add_friend', sub_category="add_qq", friend_id = table.serialize(newAddedSnsFriends)}, true)
-- 		HomeScene:sharedInstance():updateFriends()
-- 		-- self:alignAddFriendIcons()
-- 		GlobalEventDispatcher:getInstance():removeEventListener(SyncSnsFriendEvents.kSyncSuccess, onSyncQQFriendSuccess)

-- 		local numberOfFriendsAfterSync = FriendManager.getInstance():getFriendCount()
-- 		if _G.isLocalDevelopMode then printx(0, "numberOfFriendsAfterSync: "..tostring(numberOfFriendsAfterSync)) end
-- 		local newSyncFriendsNumber = numberOfFriendsAfterSync - numberOfFriendsBeforeSync

-- 		if numberOfFriendsAfterSync == 0 then
-- 			CommonTip:showTip(localize("add.friend.panel.add.qq.tip4"), "positive", nil, 2)
-- 			return
-- 		end

-- 		if numberOfFriendsBeforeSync >= FriendManager:getInstance():getMaxFriendCount() then
-- 			CommonTip:showTip(localize("add.friend.panel.add.qq.tip1", {num = numberOfFriendsAfterSync}), "positive", nil, 2)
-- 			return
-- 		end

-- 		if numberOfFriendsAfterSync >= FriendManager:getInstance():getMaxFriendCount() then
-- 			CommonTip:showTip(localize("add.friend.panel.add.qq.tip3", {num = numberOfFriendsAfterSync}), "positive", nil, 2)
-- 		else
-- 			CommonTip:showTip(localize("add.friend.panel.add.qq.tip2", {num = numberOfFriendsAfterSync}), "positive", nil, 2)
-- 		end
-- 	end

-- 	local function onSyncQQFriendFailed()
-- 		self.okBtnLogic = BTN_LOGIC.HAS_BIND
-- 		CommonTip:showTip("同步QQ好友失败！", "negative",nil, 2)
-- 		GlobalEventDispatcher:getInstance():removeEventListener(SyncSnsFriendEvents.kSyncFailed, onSyncQQFriendFailed)
-- 	end

-- 	local function addSyncFriendsListeners()
-- 		if self.isDisposed then
-- 			return
-- 		end
-- 		self.okBtnLogic = BTN_LOGIC.HAS_BIND
-- 		GlobalEventDispatcher:getInstance():addEventListener(SyncSnsFriendEvents.kSyncSuccess, onSyncQQFriendSuccess)
-- 		GlobalEventDispatcher:getInstance():addEventListener(SyncSnsFriendEvents.kSyncFailed, onSyncQQFriendFailed)
-- 	end

-- 	self.okBtn:addEventListener(DisplayEvents.kTouchTap, function()
-- 		if self.okBtnLogic == BTN_LOGIC.NONE then
-- 			return
-- 		elseif self.okBtnLogic == HAS_BIND then
-- 			CommonTip:showTip(localize("add.friend.panel.add.qq.tip5"), "negative",nil, 2)
-- 		else
-- 			self.okBtnLogic = BTN_LOGIC.NONE
-- 			local function onError()
-- 				self.okBtnLogic = BTN_LOGIC.NOT_BIND
-- 			end

-- 			local function onCancel()
-- 				self.okBtnLogic = BTN_LOGIC.NOT_BIND
-- 			end
			
-- 			friends = FriendManager.getInstance().friends
-- 			if UserManager.getInstance().profile:isQQBound() then --goto login with QQ account.
-- 				--AccountBindingLogic:bindNewSns(PlatformAuthEnum.kQQ, bindQQSuccess, nil, nil, AccountBindingSource.ADD_FRIEND)
-- 				local syncFriendLogic = require("zoo.panel.addFriend2.SyncQQFriendsLogic")
-- 				syncFriendLogic:syncQQFriends(nil, onError, onCancel)
-- 				addSyncFriendsListeners()
-- 			else --goto bind new QQ account
-- 				AccountBindingLogic:bindNewSns(PlatformAuthEnum.kQQ, addSyncFriendsListeners, onError, onCancel, AccountBindingSource.ADD_FRIEND)
-- 			end

-- 			DcUtil:UserTrack({ category='add_friend', sub_category="add_qq_click"}, true)
-- 		end
-- 	end)
-- end



-- return TabBindQQ