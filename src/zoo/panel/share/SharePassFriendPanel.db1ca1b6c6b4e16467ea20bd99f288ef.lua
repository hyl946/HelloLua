require 'zoo.panel.share.ArmatureShareBasePanel'

SharePassFriendPanel = class(ArmatureShareBasePanel)

function SharePassFriendPanel:ctor()

end

function SharePassFriendPanel:init(armatureSource, skeletonName, textureName, armatureName, playPaperGroup)

	--初始化文案内容
	ArmatureShareBasePanel.init(self, armatureSource, skeletonName, textureName, armatureName, playPaperGroup)
	local shareNotiKey = self.config.notifyMessage
	self.isScoreOverFri = self.shareId == AchiId.kScoreOverFriend
	self.isLevelOverFri = self.shareId == AchiId.kLevelOverFriend
	self.isScoreOverNation = self.shareId == AchiId.kScoreOverNation
	self.isLevelOverNation = self.shareId == AchiId.kLevelOverNation


	if self.isScoreOverFri then
		local currentLevel = self.achiManager:get(AchiDataType.kLevelId)
		self.currentLevel = currentLevel
		local userName = UserManager.getInstance().profile.name
		local levelName = tostring(LevelMapManager.getInstance():getLevelDisplayName(currentLevel))
		-- levelName = string.gsub(levelName, "+", "%%2B")
		levelName = HeDisplayUtil:urlEncode(levelName)
		self.notyMessage = Localization:getInstance():getText(shareNotiKey,{friend = userName,num = levelName})
	elseif self.isLevelOverFri then
		self.currentLevel = self.achiManager:get(AchiDataType.kLevelId)
		local userName = UserManager.getInstance().profile.name
		self.notyMessage = Localization:getInstance():getText(shareNotiKey,{friend = userName})
	elseif self.isScoreOverNation or self.isLevelOverNation then
		local over_nation_level = 1
		if self.isScoreOverNation then
			over_nation_level = tostring(self.achiManager:get(AchiDataType.kScoreOverNationResult))
		else
			over_nation_level = tostring(self.achiManager:get(AchiDataType.kLevelOverNationResult))
		end
		self.currentLevel = self.achiManager:get(AchiDataType.kLevelId)
		local userName = UserManager.getInstance().profile.name
		shareNotiKey = shareNotiKey .. '_' .. over_nation_level
		self.notyMessage = Localization:getInstance():getText(shareNotiKey,{friend = userName})
		if self.isScoreOverNation then
			local currentLevel = self.achiManager:get(AchiDataType.kLevelId)
			self.currentLevel = currentLevel
			local levelName = tostring(LevelMapManager.getInstance():getLevelDisplayName(currentLevel))
			self.notyMessage = Localization:getInstance():getText(shareNotiKey,{friend = userName, num = levelName})
		end
		self.shareTitleKey = self.shareTitleKey .. '_' ..over_nation_level
	end

	local friendInfos = nil
	if self.isScoreOverFri then 
		friendInfos = self.achiManager:get(AchiDataType.kScoreOverFriendTable)
	elseif self.isLevelOverFri then 
		friendInfos = self.achiManager:get(AchiDataType.kLevelOverFriendTable)
	end

	self.passedFriendIds = friendInfos
	self:initShareTitle(self:getShareTitleName())

end

function SharePassFriendPanel:initUI()
    self:initBg()

    -- self.ui:runAction(CCCallFunc:create(function() self:initBg() end))

    self.paperGroup1 = self.ui:getChildByName('paperGroup1')
    self.paperGroup2 = self.ui:getChildByName('paperGroup2')

    if not self.playPaperGroup then
        self.paperGroup1:setVisible(false)
        self.paperGroup2:setVisible(false)
    end

    local ph = self.ui:getChildByName('ph')
    ph:setVisible(false)
    self.node = ArmatureNode:create(self.armatureName, true)
    self.node:setScale(1.15)
    self.ui:addChildAt(self.node, ph:getZOrder())
    self.node:setPosition(ccp(ph:getPositionX(), ph:getPositionY()))

    self:initShareTitle(self:getShareTitleName())
    self:initShareBtn(self.shareType)
    self.shareImagePath = HeResPathUtils:getResCachePath() .. "/share_image.jpg"

end

function SharePassFriendPanel:getShareTitleName()
	return Localization:getInstance():getText(self.shareTitleKey)
end

local function getDayStartTimeByTS(ts)
	local utc8TimeOffset = 57600 -- (24 - 8) * 3600
	local oneDaySeconds = 86400 -- 24 * 3600
	return ts - ((ts - utc8TimeOffset) % oneDaySeconds)
end

local function now()
	return os.time() + (__g_utcDiffSeconds or 0)
end

function SharePassFriendPanel:onShareBtnTapped()
	if self.isScoreOverNation or self.isLevelOverNation then
		self:onShareBtnTapped_BindQQ()
	else
		self:onShareBtnTapped_normal()
	end
end

function SharePassFriendPanel:onShareBtnTapped_BindQQ()
	local isScoreOverNation = self.isScoreOverNation
	local isLevelOverNation = self.isLevelOverNation
	local notyMessage = self.notyMessage
	local currentLevel = self.currentLevel

	local function sharePassFriend()
		local numberOfFriendsAfterSync = FriendManager.getInstance():getFriendCount()
		if numberOfFriendsAfterSync <= 0 then
			CommonTip:showTip('还没有好友哦', 'positive')
		else
			local friendIds = {}
			for k, v in pairs(FriendManager:getInstance().friends) do
				table.insert(friendIds, k)
			end

			local notiTypeId
			if isScoreOverNation then
				notiTypeId = LocalNotificationType.kSharePassNationScore 
			elseif isLevelOverNation then
				notiTypeId = LocalNotificationType.kSharePassNationLevel
			end

			local function onPushSuccess(event)
				if not self.isDisposed then
			        CommonTip:showTip(Localization:getInstance():getText("show_off_to_friend_success"), "positive")
			    end
			    if isScoreOverNation then
					DcUtil:UserTrack({category = "show", sub_category = "push_show_off", action = 'button', id = 250, t1=250 })
				elseif isLevelOverNation then
					DcUtil:UserTrack({category = "show", sub_category = "push_show_off", action = 'button', id = 260, t1=260})
				end
				--记录炫耀次数
				ShareManager:increaseShareAllTime()
			end
			local function onPushFail()
				CommonTip:showTip(Localization:getInstance():getText("show_off_to_friend_fail"), 'negative', nil, 2)
			end

			local http = PushNotifyHttp.new()
			http:load(friendIds, notyMessage, notiTypeId, now() * 1000, currentLevel)
			http:ad(Events.kComplete, onPushSuccess)
		    http:ad(Events.kError, onPushFail)
		end
	end
	
	local function onSyncQQFriendSuccess()
		GlobalEventDispatcher:getInstance():removeEventListener(SyncSnsFriendEvents.kSyncSuccess, onSyncQQFriendSuccess)
		sharePassFriend()
	end

	local function onSyncQQFriendFailed()
		GlobalEventDispatcher:getInstance():removeEventListener(SyncSnsFriendEvents.kSyncSuccess, onSyncQQFriendFailed)
	end

	local function onConnectFinish()
		if self.isDisposed then return end
		GlobalEventDispatcher:getInstance():addEventListener(SyncSnsFriendEvents.kSyncSuccess, onSyncQQFriendSuccess)
		GlobalEventDispatcher:getInstance():addEventListener(SyncSnsFriendEvents.kSyncFailed, onSyncQQFriendFailed)
		self:removePopout()
	end
	local function onConnectError()
		if self.isDisposed then return end
		-- CommonTip:showTip('绑定出错', 'negative')
	end
	local function onConnectCancel()
		if self.isDisposed then return end
		-- CommonTip:showTip('已取消绑定', 'negative')
	end
	if isScoreOverNation then
		DcUtil:UserTrack({category = "show", sub_category = "push_show_off", action = 'button', id = 250, t1=250 })
	elseif isLevelOverNation then
		DcUtil:UserTrack({category = "show", sub_category = "push_show_off", action = 'button', id = 260, t1=260})
	end

	-- if PlatformConfig:hasAuthConfig(PlatformAuthEnum.kQQ, true) then 
	-- 	AccountBindingLogic:bindNewSns(PlatformAuthEnum.kQQ, onConnectFinish, onConnectError, onConnectCancel, AccountBindingSource.SHARE_PASS_FRIEND, hasReward)
	-- else
		sharePassFriend()
	-- end
end

--override
function SharePassFriendPanel:onShareBtnTapped_normal()
	--ShareBasePanel.onShareBtnTapped(self,self.shareId)
	if not __IOS_FB then 
		local notiTypeId = LocalNotificationType.kSharePassFriendScore 
		if self.isScoreOverFri then
			DcUtil:UserTrack({category = "show", sub_category = "push_show_off", action = 'button', id = 110, t1=self.t1 })
		elseif self.isLevelOverFri then
			notiTypeId = LocalNotificationType.kSharePassFriendLevel
			DcUtil:UserTrack({category = "show", sub_category = "push_show_off", action = 'button', id = 120, t1=self.t1})
		end
		
		local function onPushSuccess(event)
			if not self.isDisposed then
		        CommonTip:showTip(Localization:getInstance():getText("show_off_to_friend_success"), "positive")
		        --关闭
		        self:removePopout()
		    end
    		if self.isScoreOverFri then
				DcUtil:UserTrack({category = "show", sub_category = "push_show_off", action = 'success', id = 110, t1=self.t1 })
			elseif self.isLevelOverFri then
				DcUtil:UserTrack({category = "show", sub_category = "push_show_off", action = 'success', id = 120, t1=self.t1})
			end
			--记录炫耀次数
			ShareManager:increaseShareAllTime()
		end
		local function onPushFail()
			if self.isDisposed then return end
			self:showFaildTip("show_off_to_friend_fail")
		end

		local targetTime = now()
		local friendIds = {}
		for k, v in pairs(self.passedFriendIds) do
			table.insert(friendIds, v.uid)
		end
		if #friendIds == 0 then 
			CommonTip:showTip('还没有好友哦', 'positive')
		end

		local http = PushNotifyHttp.new()
		http:load(friendIds, self.notyMessage, notiTypeId, targetTime * 1000, self.currentLevel)
		http:ad(Events.kComplete, onPushSuccess)
	    http:ad(Events.kError, onPushFail)
	end
end

function SharePassFriendPanel:showFaildTip(strKey)
	CommonTip:showTip(Localization:getInstance():getText(strKey), 'negative', nil, 2)
end

function SharePassFriendPanel:create(shareId)
	local panel = SharePassFriendPanel.new()
	panel:loadRequiredResource("ui/NewSharePanelEx.json")
	panel.shareId = shareId
	panel:init('skeleton/share_120_animation', 'share_120_animation', 'share_120_animation', 'SharePassFriend', false)
	return panel
end