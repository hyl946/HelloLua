local CompFriendHelp = class()

local SHARE_OPTIONS = {
	NOTIFY = 1,
	TIMELINE1 = 2,
	TIMELINE2 = 3,
	LINK1 = 4,
	LINK2 = 5,
	IMAGE1 = 6,
	IMAGE2 = 7,
	LINK_N_IMAGE = 8,
}

function CompFriendHelp:create(parentPanel, ui)
	local comp = CompFriendHelp.new()
	comp:init(parentPanel, ui)
	return comp
end

local function getNpcName(index)
    if index == 1 then
        return "青蛙"
    elseif  index == 2 then
        return "小黄鸡"
    else
        return "河马"
    end
end

function CompFriendHelp:init(parentPanel, ui)
	self.askFriendUnlockSuccess = false
	self.parentPanel = parentPanel
	self.ui = ui
    self.curAreaFriendIds	= UserManager:getInstance():getUnlockFriendUidsWithNPC(self.parentPanel.lockedCloudId)
	self.friendItem1Res = self.ui:getChildByName("friendItem1")
	self.friendItem2Res = self.ui:getChildByName("friendItem2")
	self.friendItem3Res = self.ui:getChildByName("friendItem3")
	self.friendItem1 = FriendItem:create(self.friendItem1Res)
	self.friendItem2 = FriendItem:create(self.friendItem2Res)
	self.friendItem3 = FriendItem:create(self.friendItem3Res)
	self.npc1 = self.ui:getChildByName("little_frog")
    self.npc2 = self.ui:getChildByName("little_chiken")
    self.npc3 = self.ui:getChildByName("little_hippo")
    self.npc1:setVisible(false)
    self.npc2:setVisible(false)
    self.npc3:setVisible(false)
	self.friendItems = {self.friendItem1, self.friendItem2, self.friendItem3}
	for index,friendId in ipairs(self.curAreaFriendIds) do
        if self.friendItems[index] then
            if tostring(friendId) == "-1" then

                local npcname = getNpcName(index)
                self["npc" .. index]:setVisible(true)
                self.friendItems[index]:setFriend(tostring(friendId) , {name = npcname})
            else
                self.friendItems[index]:setFriend(tostring(friendId))
            end
        end
    end

	self.topFriendLabel = self.ui:getChildByName("label_top_friend")
	self.topFriendBtnRes = self.ui:getChildByName("btn_top_friend")
	self.topFriendBtn	= GroupButtonBase:create(self.topFriendBtnRes)
	local askFriendBtnLabelKey	= "unlock.cloud.desc11"
	local askFriendBtnLabelValue	= Localization:getInstance():getText(askFriendBtnLabelKey, {})
	self.topFriendBtn:setString(askFriendBtnLabelValue)
	local function onAskFriendBtnTapped()
		if PrepackageUtil:isPreNoNetWork() then
			PrepackageUtil:showInGameDialog()
		else
			self:onAskFriendBtnTapped()
		end
	end
	self.topFriendBtn:addEventListener(DisplayEvents.kTouchTap, onAskFriendBtnTapped)
	self.topFriendLabel:setString( Localization:getInstance():getText("unlock.cloud.desc10") ) 
	self.sendLinkBtn = ButtonIconsetBase:create(self.ui:getChildByName('btn_send_link'))
	self.sendImageBtn = ButtonIconsetBase:create(self.ui:getChildByName('btn_send_image'))
	self.sendLinkBtn:setString(localize('unlock.btn.send.link.wechat'))
	self.sendLinkBtn:setIconByFrameName("common_icon/sns/icon_wechat0000")
	self.sendImageBtn:setString(localize('unlock.btn.send.image.system'))
	self.sendImageBtn:setIconByFrameName("common_icon/sns/icon_timeline0000")
	self:refreshBtns()
end

function CompFriendHelp:refreshBtns()
	self.sendLinkBtn:setVisible(false)
	self.sendImageBtn:setVisible(false)
	if WXJPPackageUtil.getInstance():isWXJPPackage() then return false end

	if not (PlatformConfig:isJJPlatform() or PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk)) then
		local hasFriendsToSend = self:hasFriendsToSend()
		if not hasFriendsToSend then
			if self:getUserGroupShareOption() == SHARE_OPTIONS.LINK_N_IMAGE then
				self.topFriendBtn:setVisible(hasFriendsToSend)
				self.sendLinkBtn:setVisible(not hasFriendsToSend)
				self.sendImageBtn:setVisible(not hasFriendsToSend)
				self.sendLinkBtn:removeAllEventListeners()
				self.sendImageBtn:removeAllEventListeners()
				self.sendLinkBtn:ad(DisplayEvents.kTouchTap, function() self:shareLink(SHARE_OPTIONS.LINK_N_IMAGE) end)
				self.sendImageBtn:ad(DisplayEvents.kTouchTap, function () self:shareImage(SHARE_OPTIONS.LINK_N_IMAGE) end) 
			end
		end
	end
end

function CompFriendHelp:hasFriendsToSend()
	if PlatformConfig:isPlatform(PlatformNameEnum.kJJ) or--这三个平台不发朋友圈
       PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk) or 
       PlatformConfig:isPlatform(PlatformNameEnum.kIOS) then
       return true
   	end
   	
	local fixFriendIds = {}
	for i = 1 , #self.curAreaFriendIds do
		if tostring(self.curAreaFriendIds[i] ) ~= "-1" then
			table.insert( fixFriendIds , self.curAreaFriendIds[i] )
		end
	end
	return ChooseFriendPanel:hasFriendsToSend(self.parentPanel.lockedCloudId, fixFriendIds)
end

function CompFriendHelp:onAskFriendBtnTapped(...)

	if __IOS_FB and not SnsProxy:isShareAvailable() then 
		CommonTip:showTip(Localization:getInstance():getText("error.tip.facebook.login"), "negative",nil,2)
		return
	end

	self.parentPanel:tryRemoveGuide()
	if PlatformConfig:isJJPlatform() or PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk) or WXJPPackageUtil.getInstance():isWXJPPackage() then
		self:oldBtnLogic()
	else
		local function onGetOption(option)
			if option == SHARE_OPTIONS.NOTIFY then
				self:shareAskHelp()
			elseif option == SHARE_OPTIONS.TIMELINE1 
				or option == SHARE_OPTIONS.TIMELINE2 
				or option == SHARE_OPTIONS.LINK1
				or option == SHARE_OPTIONS.LINK2 then
				self:shareLink(option)
			elseif option == SHARE_OPTIONS.IMAGE1 
				or option == SHARE_OPTIONS.IMAGE2 then
				self:shareImage(option)
			end
		end

		if FriendManager:getInstance():getFriendCount() == 0 or not self:hasFriendsToSend() then
			self:getFinalShareOption(onGetOption)
		else
			self:oldBtnLogic(true)
		end
	end
end

function CompFriendHelp:oldBtnLogic(isNewLogic)
	DcUtil:UserTrack({category='unlock', sub_category='push_help_button', id=1})
	if #self.curAreaFriendIds >= 3 then
		if self.btnTappedState == self.BTN_TAPPED_STATE_NONE then
			self.btnTappedState = self.BTN_TAPPED_STATE_ASK_FRIEND_BTN_TAPPED
		else
			return
		end
		self:sendUnlockMsg()
	else
		if WXJPPackageUtil.getInstance():isGuestLogin() then 
			CommonTip:showTip(Localization:getInstance():getText("wxjp.guest.warning.tip"), "negative")
			return 
		end
		
		self:chooseUnlockFriend(isNewLogic)
	end
end

function CompFriendHelp:shareAskHelp()
	DcUtil:UserTrack({category='unlock', sub_category='push_help_button', id=1})
	if #self.curAreaFriendIds >= 3 then
		if self.btnTappedState == self.BTN_TAPPED_STATE_NONE then
			self.btnTappedState = self.BTN_TAPPED_STATE_ASK_FRIEND_BTN_TAPPED
		else
			return
		end

		self:sendUnlockMsg()
	else
		if WXJPPackageUtil.getInstance():isGuestLogin() then 
			CommonTip:showTip(Localization:getInstance():getText("wxjp.guest.warning.tip"), "negative")
			return 
		end
		
		self:chooseUnlockFriend()
	end
end

function CompFriendHelp:getFinalShareOption(callback)
	local groupOption = self:getUserGroupShareOption()
	if groupOption == SHARE_OPTIONS.TIMELINE1 or groupOption == SHARE_OPTIONS.TIMELINE2 then
		local function onSuccess(evt)
			if callback then
				local canShareMoments = evt.data.canShareMoments or false
				if canShareMoments then
					callback(groupOption)
				else
					callback(SHARE_OPTIONS.NOTIFY)
				end
			end
		end
		local function onFailCancel(evt)
			callback(groupOption)
		end
		local http = ShareMomentsSwitchHttp.new(true)
		http:ad(Events.kComplete, onSuccess)
	    http:ad(Events.kError, onFailCancel)
	    http:ad(Events.kCancel, onFailCancel)
	    http:load(self:getAppId(), 2)
	else
		callback(groupOption)
	end
end

function CompFriendHelp:sendUnlockMsg()
	local function onSendUnlockMsgSuccess(event)
		if _G.isLocalDevelopMode then printx(0, "onSendUnlockMsgSuccess Called !") end

		local function onRemoveSelfFinish()
			self.parentPanel.unlockCloudSucessCallBack()
			if _G.isLocalDevelopMode then printx(0, "onRemoveSelfFinish Called !") end
		end
		self.parentPanel.isUnlockSuccess = true
		self.parentPanel:remove(onRemoveSelfFinish)
	end

	local function onSendUnlockMsgFailed(errorCode)
		self.parentPanel.btnTappedState = self.parentPanel.BTN_TAPPED_STATE_NONE
		CommonTip:showTip(Localization:getInstance():getText("error.tip."..errorCode), "negative")
	end

	local function onSendUnlockMsgCanceled(event)
		self.parentPanel.btnTappedState = self.parentPanel.BTN_TAPPED_STATE_NONE
	end

	local fixIds = {}
	local npcNum = 0
	for i = 1 , #self.curAreaFriendIds do
		if tostring(self.curAreaFriendIds[i]) ~= "-1" then
			table.insert( fixIds , tonumber(self.curAreaFriendIds[i]) )
		elseif tostring(self.curAreaFriendIds[i]) ~= "-1" then
			npcNum = npcNum + 1
		end
	end

	local useType = nil
	local datas = nil
	if #fixIds < 3 then
		useType = UnlockLevelAreaLogicUnlockType.USE_SIM_FRIEND
		datas = {}
		datas.npc = npcNum
	else
		useType = UnlockLevelAreaLogicUnlockType.USE_FRIEND
	end

	local logic = UnlockLevelAreaLogic:create(self.parentPanel.lockedCloudId)
	logic:setOnSuccessCallback(onSendUnlockMsgSuccess)
	logic:setOnFailCallback(onSendUnlockMsgFailed)
	logic:setOnCancelCallback(onSendUnlockMsgCanceled)
	logic:start( useType , fixIds , nil , datas)
end

function CompFriendHelp:getUserGroupShareOption()
	local uid = UserManager:getInstance().user.uid or '12345'
	local defaultOption = SHARE_OPTIONS.NOTIFY
	for k, v in pairs(SHARE_OPTIONS) do
		if MaintenanceManager:getInstance():isEnabledInGroup('UnlockGroupConfig', string.lower(k), uid) then
			defaultOption = v
			break
		end
	end
	return defaultOption
end

function CompFriendHelp:chooseUnlockFriend(isNewLogic)
	local function chooseFriendFunc()
		local function onSuccess(friendIds)
			if not self.friendIdsSent then
				self.friendIdsSent = {}
			end
			if friendIds then
				for k, v in pairs(friendIds) do
					table.insert(self.friendIdsSent, v)
				end
			end
			if isNewLogic then
				self:refreshBtns()
			end
			self.askFriendUnlockSuccess = true
		end
		local function onFail(evt) end
		local function allSentCallback()
			local option = self:getUserGroupShareOption()
			local dcId = math.floor(option/2)+1
			DcUtil:UserTrack({category='unlock', sub_category='push_help_all', id=dcId})
		end
		local fixFriendIds = {}
		for i = 1 , #self.curAreaFriendIds do
			if tostring(self.curAreaFriendIds[i] ) ~= "-1" then
				table.insert( fixFriendIds , self.curAreaFriendIds[i] )
			end
		end
		ChooseFriendPanel:popoutPanel(self.parentPanel.lockedCloudId, fixFriendIds , onSuccess, onFail, isNewLogic, allSentCallback)
	end
	PushBindingLogic:runChooseFriendLogic(chooseFriendFunc, 6)
end

function CompFriendHelp:getShareUrl(option)
	-- local urls = {
	-- 	[0] = "unlock_help_button.html", -- 中转页1
	-- 	[1] = "unlock_help_no_button.html", -- 中转页2
	-- }
	local tail = option % 2
	local sender = tostring(UserManager:getInstance().user.uid or '12345')
	local pf = PlatformConfig.name
	local cloudId = tostring(self.parentPanel.lockedCloudId)
	local plan = math.floor(option/2)
	local actId = '10009'
	local game_name = 'unlock_help_'..tostring(plan)..'_'..tostring(tail+1)
	local baseUrl = NetworkConfig:getShareHost() ..'unlock_help_button.html'
	local url = string.format("%s?sender=%s&pf=%s&cloudId=%s&plan=%s&actId=%s&game_name=%s", baseUrl, sender, pf, cloudId, plan, actId, game_name)
	return url
end

function CompFriendHelp:getAppId( ... )
	local ret = ''
	local function getId()
		local MainActivityHolder = luajava.bindClass("com.happyelements.android.MainActivityHolder")
		ret = MainActivityHolder:getWXShareAppId()
	end
	pcall(getId)
	return ret
end

function CompFriendHelp:shareLink(option)
	if self.waitingShare then return end
	local dcId = math.floor(option/2)+1
	if dcId == 5 then
		dcId = 5.1
	end
	DcUtil:UserTrack({category='unlock', sub_category='push_help_button', id=dcId})
	local thumb = CCFileUtils:sharedFileUtils():fullPathForFilename("materials/unlock_share_icon.png")
	local title = localize('unlock.share.link.title')
	local message = localize('unlock.share.link.message')
	local shareUrl = self:getShareUrl(option)
	local isSendToFeeds = (option == SHARE_OPTIONS.TIMELINE1 or option == SHARE_OPTIONS.TIMELINE2)
	if isSendToFeeds then
		title = localize('unlock.share.link.title.timeline')
		message = localize('unlock.share.link.message.timeline')
	end
	local shareCallback = {
		onSuccess = function(result)
			DcUtil:UserTrack({category='unlock', sub_category='push_help_success', id=dcId})
			if isSendToFeeds then
				local http = ShareMomentsSuccHttp.new(false)
    			http:load(self:getAppId(), 2)
			end
			CommonTip:showTip(localize('share.feed.success.tips'), 'positive')
		end,
		onError = function(errCode, errMsg)
			CommonTip:showTip(localize('share.feed.faild.tips'), 'negative')
		end,
		onCancel = function()
			CommonTip:showTip(localize('share.feed.cancel.tips'), 'negative')
		end
	}
	local function notifySuccess()
		if self.isDisposed or (self.ui and self.ui.isDisposed) then return end

		self.ui:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(3), CCCallFunc:create(function() self.waitingShare = false end)))
		if __WIN32 then
			shareCallback.onSuccess()
			return
		end
		local shareType = SnsUtil.getShareType()
		SnsUtil.sendLinkMessage( shareType, title, message, thumb, shareUrl, isSendToFeeds, shareCallback)
	end
	local function failOrCancelCallback()
		self.waitingShare = false
	end
	self.waitingShare = true
	self:opNotify(notifySuccess, failOrCancelCallback)
end

function CompFriendHelp:shareImage(option)
	if self.waitingShare then return end
	local dcId = math.floor(option/2)+1
	if dcId == 5 then
		dcId = 5.2
	end
	DcUtil:UserTrack({category='unlock', sub_category='push_help_button', id=dcId})
	local thumb = CCFileUtils:sharedFileUtils():fullPathForFilename("materials/unlock_share_icon.png")
	local title = localize('unlock.share.link.title')
	local message = localize('unlock.share.link.message')
	local shareUrl = self:getShareUrl(option)
	local dirBase = HeResPathUtils:getResCachePath()
	if __ANDROID then
		dirBase = luajava.bindClass("com.happyelements.android.utils.ScreenShotUtil"):getGamePictureExternalStorageDirectory()
	end
	local shareImagePath = dirBase .. "/share_image.jpg"
	local function renderImage()
		local bgPath = 'share/unlock_share.jpg'
		local bg = Sprite:create(bgPath)
		if _G.__use_small_res then
			bg:setScale(0.625)
		end
		local builder = InterfaceBuilder:create('ui/share_unlock.json')
		local group = builder:buildGroup('unlock_share_group')
		local codePh = group:getChildByName('codePh')
		local width = codePh:getContentSize().width*codePh:getScaleX() -- 正方形的
		local code = CocosObject.new(QRManager:generatorQRNode(shareUrl, width))
		local iconPath = 'materials/wechat_icon.png'
		local icon = Sprite:create(iconPath)
		local codeSize = code:getContentSize()
		icon:setScale(30/icon:getContentSize().width)
		code:addChild(icon)
		icon:setPositionXY(codeSize.width/2, codeSize.height/2)
		code:setAnchorPoint(ccp(0, 1))
		group:addChild(bg)
		bg:setAnchorPoint(ccp(0, 1))
		bg:setPosition(ccp(0, 0))
		code:setScaleX(width / codeSize.width)
		code:setScaleY(width / codeSize.height) 
		code:setRotation(codePh:getRotation())
		group:addChild(code)
		code:setPositionX(codePh:getPositionX())
		code:setPositionY(codePh:getPositionY())
		group:setPositionXY(0, 720)
		local renderTexture = CCRenderTexture:create(720, 720)
		renderTexture:begin()
		group:visit()
		renderTexture:endToLua()
		renderTexture:saveToFile(shareImagePath)
		group:dispose()
		CCTextureCache:sharedTextureCache():removeTextureForKey(CCFileUtils:sharedFileUtils():fullPathForFilename(bgPath))
		CCTextureCache:sharedTextureCache():removeTextureForKey(CCFileUtils:sharedFileUtils():fullPathForFilename(iconPath))
	end
	local shareCallback = {
		onSuccess = function(result)
			DcUtil:UserTrack({category='unlock', sub_category='push_help_success', id=dcId})
			-- CommonTip:showTip(localize('share.feed.success.tips'), 'positive')
		end,
		onError = function(errCode, errMsg)
			-- CommonTip:showTip(localize('share.feed.faild.tips'), 'negative')
		end,
		onCancel = function()
			-- CommonTip:showTip(localize('share.feed.cancel.tips'), 'negative')
		end
	}
	local function notifySuccess()
		if self.isDisposed or (self.ui and self.ui.isDisposed) then return end

		self.ui:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(3), CCCallFunc:create(function() self.waitingShare = false end)))
		if __WIN32 then
			shareCallback.onSuccess()
			return
		end
		local shareType = PlatformShareEnum.kSYS_WECHAT
		AndroidShare.getInstance():registerShare(shareType)
		SnsUtil.sendImageMessage( shareType, title, message, thumb, shareImagePath, shareCallback )
	end
	local function failOrCancelCallback()
		self.waitingShare = false
	end
	self.waitingShare = true
	renderImage()
	self:opNotify(notifySuccess, failOrCancelCallback)
end

function CompFriendHelp:opNotify(successCallback, failOrCancelCallback)
	local function onFailCancel(evt)
		if evt and evt.data then
			CommonTip:showTip(localize('error.tip.'..tostring(evt.data or -6)), 'negative')
		end
		if failOrCancelCallback then
			failOrCancelCallback()
		end
	end
	local function doHttp()
		local http = OpNotifyHttp.new(true)
		http:load(38, self.parentPanel.lockedCloudId)
		http:ad(Events.kComplete, successCallback)
		http:ad(Events.kError, onFailCancel)
		http:ad(Events.kCancel, onFailCancel)
	end
	RequireNetworkAlert:callFuncWithLogged(doHttp, onFailCancel)
end

return CompFriendHelp