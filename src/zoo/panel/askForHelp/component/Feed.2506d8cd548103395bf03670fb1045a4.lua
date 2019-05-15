local debugMode = nil

local eTAShareType = table.const
{
    ASKFORHELP = 1,
    PASSLEVEL = 2
}

local eLinkType = table.const
{
    help_link = 1,
    help_ewm = 2,
    notify_link = 3,
    show_link = 4,
    show_ewm = 5,
    show_new_headframe = 6,
}

local LinkKeyPrefixs = {
    "help_link",
    "help_ewm",
    "notify_link",
    "show_link",
    "show_ewm",
    "show_new_headframe",
}

local LinkNames = {
    "FriendLevel_help_link",
    "FriendLevel_help_ewm",
    "FriendLevel_notify_link",
    "FriendLevel_show_link",
    "FriendLevel_show_ewm",
    "FriendLevel_new_headframe",
}

-- Url配置
local Feed = class()
function Feed:getUrlParam(linkType, levelId)
    local params = {}
    table.insert(params, "tlink=" .. tostring(linkType))
    table.insert(params, "aaf=" .. tostring(7))
    table.insert(params, "uid=" .. tostring(UserManager.getInstance().uid or 0))
    table.insert(params, "pid=" .. PlatformConfig.name)
    table.insert(params, "invitecode=" .. UserManager:getInstance().inviteCode or '')
    table.insert(params, "ts=" .. tostring(Localhost:time()))
    table.insert(params, "game_name=" .. LinkNames[linkType])
    table.insert(params, "levelId=" ..tostring(levelId or UserManager:getInstance().user:getTopLevelId()))

    if linkType <= eLinkType.help_ewm then
        table.insert(params,"ask=1")
    end
    return params
end

function Feed:shareDisabled()
    return AskForHelpManager:getInstance():shareDisabled()
end

function Feed:getLinkMsgUrl(linkType, params, levelId, wxzEnable)
    local parameters = table.merge(self:getUrlParam(linkType, levelId), params or {})
    local finalUrl = NetworkConfig:getShareHost()

    if wxzEnable then
        -- 自动检测微下载
        if PlatformConfig:isQQPlatform() then
            finalUrl = NetworkConfig.wxzQQDowanloadURL
        elseif PlatformConfig:isPlatform(PlatformNameEnum.kIOS) or
            PlatformConfig:isPlatform(PlatformNameEnum.kHE) or
            PlatformConfig:isPlatform(PlatformNameEnum.kTF) then
            finalUrl = NetworkConfig.wxzHEDowanloadURL
        else
            finalUrl = NetworkConfig:getShareHost() .. "substitute.html?" ..table.concat(parameters,"&")
        end
    else
        finalUrl = NetworkConfig:getShareHost() .. "substitute.html?" ..table.concat(parameters,"&")
    end
    return finalUrl 
end

function Feed:getQRMsgUrl(eType, params, levelId, wxzEnable)
    return self:getLinkMsgUrl(eType, params, levelId, wxzEnable)
end

local function setIndex(ui, rhs, idx)
    for i=1, rhs do
        ui:getChildByName(tostring(i)):setVisible(i==idx)
    end
end

function Feed:getResPath()
    local path = nil
	if __ANDROID then
		path = luajava.bindClass("com.happyelements.android.utils.ScreenShotUtil"):getGamePictureExternalStorageDirectory()
	elseif __IOS then
 		path = HeResPathUtils:getResCachePath()
	end

    if not path then
        path = HeResPathUtils:getResCachePath()
    end
    return path
end

local function headIconLoader(headIcon, profile, callback)
	if not profile then
		profile = UserManager:getInstance().profile
	end
	
    local headHolder = headIcon:getChildByName('holder')
	local headHolderSize = headHolder:getContentSize()
	headHolder:setAnchorPointCenterWhileStayOrigianlPosition()

    local head = headHolder:getChildByName("head")
	if head then
		head:removeFromParentAndCleanup(true)
	end

	HeadImageLoader:create(profile.uid, profile.headUrl, function ( head )
		if headHolder.isDisposed then
			head:dispose()
			return
		end
		if head.isDisposed then
			return
		end

		head.name = "head"
		head:setPositionX(headHolder:getContentSize().height/2)
		head:setPositionY(headHolder:getContentSize().width/2)
		head:setScaleX(headHolder:getContentSize().width/100)
		head:setScaleY(headHolder:getContentSize().height/100)
		headHolder:addChild(head)

		if callback then
			callback()
		end
	end)
end

function Feed:createTemplate(data, decorator_func)
    local resPanelJson = 'share/AskForHelp/Feed.json'
    local builder = InterfaceBuilder:createWithContentsOfFile(resPanelJson)
    local ui = builder:buildGroup(data.groupName)

    -- headIcon
	local profile = UserManager:getInstance().profile
    local headIcon = ui:getChildByName("headIcon")
    if headIcon then
        headIconLoader(headIcon, profile)
    end

    local nameLabel = ui:getChildByName("lbName")
    if nameLabel then
        local userName = HeDisplayUtil:urlDecode(profile.name).. " "
        nameLabel:setString(userName)
    end

    decorator_func(ui)

    -- QR
    local ph = ui:getChildByName('code')
    if ph then
        local qrNode = CocosObject.new(QRManager:generatorQRNode(data.qrUrl or "", 128, 1))
        qrNode:setAnchorPoint(ccp(0, 1))
        qrNode:setScale(ph:getContentSize().width*ph:getScaleX()/qrNode:getGroupBounds().size.width)
        ui:addChildAt(qrNode, ph:getZOrder(ph))
        qrNode:setPositionX(ph:getPositionX())
        qrNode:setPositionY(ph:getPositionY())
        qrNode:setRotationX(ph:getRotationX())
        qrNode:setRotationY(ph:getRotationY())
        ph:setVisible(false)
    end

    local sz = ui:getGroupBounds().size
    local bg = ui:getChildByName("bg")
    if bg then sz = bg:getGroupBounds().size end
    local imageFilePath = self:getResPath() .. "/FeedCache_AskForHelp.png"
    if debugMode then
        if not g_counter then
            g_counter = 0
        end
        g_counter = g_counter + 1
        imageFilePath = self:getResPath() .."/FeedCache_AskForHelp" ..tostring(g_counter) ..".png"
    end
    self:screenShot(ui, imageFilePath, sz)

    local thumbFilePath = self:getResPath() .. "/FeedCache_FeedCache_AskForHelp_thumb.jpg"
    if debugMode then
        thumbFilePath = self:getResPath() .. "/FeedCache_AskForHelp_thumb" .. tostring(g_counter) ..".jpg"
    end

    local scale = 256 / math.max(sz.width, sz.height)
    ui:setScale(scale)
    self:screenShot(ui, thumbFilePath, CCSizeMake(256, 256))

    if ui.bgUrl then
        CCTextureCache:sharedTextureCache():removeTextureForKey(
            CCFileUtils:sharedFileUtils():fullPathForFilename(ui.bgUrl)
        )
        ui.bgUrl = nil
    end

    ui:dispose()
    InterfaceBuilder:unloadAsset(resPanelJson)
    return imageFilePath, thumbFilePath
end

-- 过关炫耀
-- 安卓平台使用系统分享，可发送炫耀图至朋友圈，ios平台使用游戏内分享，可分享微下载链接至点对点好友
function Feed:sharePassLevel(levelId, successCallback, failCallback, cancelCallback)
    local data = {}
    data.groupName = 'AsKForHelplFeed/interface/passLevel'
    data.qrUrl = self:getQRMsgUrl(eLinkType.show_ewm, {}, levelId, true)

    local function decorator(ui)
        function ui:getGroupBounds()
            local sz = ui:getChildByName("bg"):getGroupBounds().size
            return CCRectMake(
                0,
                -sz.height,
                sz.width,
                sz.height
            )
        end
    end
    local title = ""
    local msg = ""
    local imageURL, thumbUrl = self:createTemplate(data, decorator)
    self:share2FriendCircle(eLinkType.show_link, title, msg, imageURL, thumbUrl, successCallback, failCallback, cancelCallback)
end

-- 获得新的头像框
-- 安卓平台使用系统分享，可发送炫耀图至朋友圈，ios平台使用游戏内分享，可分享微下载链接至点对点好友
function Feed:shareNewHeadFrame(levelId, successCallback, failCallback, cancelCallback)
    local data = {}
    data.groupName = 'AsKForHelplFeed/interface/getNewHeadFrame'
    data.qrUrl = self:getQRMsgUrl(eLinkType.show_ewm, {}, levelId, true)

    local function decorator(ui)
        function ui:getGroupBounds()
            local sz = ui:getChildByName("bg"):getGroupBounds().size
            return CCRectMake(
                0,
                -sz.height,
                sz.width,
                sz.height
            )
        end
    end
    local title = ""
    local msg = ""
    local imageURL, thumbUrl = self:createTemplate(data, decorator)
    self:share2FriendCircle(eLinkType.show_new_headframe, title, msg, imageURL, thumbUrl, successCallback, failCallback, cancelCallback)
end

-- SNS消息求助
function Feed:askForHelpFromSNS(eSNSType, level, title, message, successCallback, failCallback, cancelCallback)
    local tKey = "askforhelp.share.askForHelpFromWxMsg.title"
    local mKey = "askforhelp.share.askForHelpFromWxMsg.msg"
    if title then tKey = title end
    if message then mKey = message end
    
    local title = Localization:getInstance():getText(tKey, {num=level})
    local message = Localization:getInstance():getText(mKey, {num=level})
    local thumbUrl = 'share/AskForHelp/thumb/avatar.jpg'
    thumbUrl = CCFileUtils:sharedFileUtils():fullPathForFilename(thumbUrl)

    local wxzEnable = true
    local eShareType = PlatformShareEnum.kWechat
    if eSNSType == kAskForHelpSnsEnum.EQQ then
        wxzEnable = false
        eShareType = PlatformShareEnum.kQQ
    end

    local webpageUrl = self:getLinkMsgUrl(eLinkType.help_link, params, level, wxzEnable)
    Feed:NotifyBySns(eShareType, eLinkType.help_link, title, message, thumbUrl, webpageUrl, successCallback, failCallback, cancelCallback)
end

-- 微信好友求助
function Feed:askForHelpFromWxFriend(level, title, message, successCallback, failCallback, cancelCallback)
    local tKey = "askforhelp.share.askForHelpFromWxMsg.title"
    local mKey = "askforhelp.share.askForHelpFromWxMsg.msg"
    if title then tKey = title end
    if message then mKey = message end
    
    local title = Localization:getInstance():getText(tKey, {num=level})
    local message = Localization:getInstance():getText(mKey, {num=level})
    local thumbUrl = 'share/AskForHelp/thumb/avatar.jpg'
    thumbUrl = CCFileUtils:sharedFileUtils():fullPathForFilename(thumbUrl)

    local params = {}
    table.insert(params, "wx=" .. tostring(1))
    local webpageUrl = self:getLinkMsgUrl(eLinkType.help_link, params, level, false)

    local eShareType = PlatformShareEnum.kWechat
    Feed:NotifyBySns(eShareType, eLinkType.help_link, title, message, thumbUrl, webpageUrl, successCallback, failCallback, cancelCallback)
end

-- 微信朋友圈求助
function Feed:askForHelpFromWxCircle(doneeUid, level, successCallback, failCallback, cancelCallback)
    local params = {}
    table.insert(params, "wx=" .. tostring(2))

    local data = {}
    data.groupName = 'AsKForHelplFeed/interface/askForHelp'
    data.qrUrl = self:getQRMsgUrl(eLinkType.help_ewm, params, level, false)

    local function decorator(ui)
        function ui:getGroupBounds()
            local sz = ui:getChildByName("bg"):getGroupBounds().size
            return CCRectMake(
                0,
                -sz.height,
                sz.width,
                sz.height
            )
        end
    end

    local title = ""
    local webPageUrl = self:getQRMsgUrl(eLinkType.help_ewm, params, level, false)
    local msg = Localization:getInstance():getText("askforhelp.share.askForHelpFromWxCircle.msg", {endl='\n', url=webPageUrl})
    local imageURL, thumbUrl = self:createTemplate(data, decorator)
    self:share2FriendCircle(eLinkType.help_link, title, msg, imageURL, thumbUrl, successCallback, failCallback, cancelCallback)
end

-- 成功过关发送通知
function Feed:notify(eSnsType, doneeUid, level, successCallback, failCallback, cancelCallback)
    if eSnsType == 1 then
        -- system notification
        local function onSuccess()
            CommonTip:showTip(Localization:getInstance():getText("askforhelp.share.notify.success"), "positive")
            successCallback()
        end
	    local http = PushNotifyHttp.new()
	    http:load({doneeUid}, nil, LocalNotificationType.KAskForHelpSuccess, Localhost:time(), level)
	    http:ad(Events.kComplete, onSuccess)
        http:ad(Events.kError, failCallback)
	    http:ad(Events.kComplete, cancelCallback)
    else
        local wxzEnable = true
        local eShareType = PlatformShareEnum.kWechat
        if eSnsType == kAskForHelpSnsEnum.EQQ then
            wxzEnable = false
            eShareType = PlatformShareEnum.kQQ
        end

        local title = Localization:getInstance():getText("askforhelp.share.notifybyqq.title", {num=level})
        local message = Localization:getInstance():getText("askforhelp.share.notifybyqq.msg")
        local thumbUrl = 'share/AskForHelp/thumb/passlevel.jpg'
        thumbUrl = CCFileUtils:sharedFileUtils():fullPathForFilename(thumbUrl)

        local webpageUrl = self:getLinkMsgUrl(eLinkType.notify_link, {}, level, wxzEnable)
        Feed:NotifyBySns(eShareType, eLinkType.notify_link, title, message, thumbUrl, webpageUrl, successCallback, failCallback, cancelCallback)

        local function dummy()
        end
        local http = PushNotifyHttp.new()
	    http:load({doneeUid}, nil, LocalNotificationType.KAskForHelpSuccess, Localhost:time(), level)
	    http:ad(Events.kComplete, dummy)
        http:ad(Events.kError, dummy)
	    http:ad(Events.kComplete, dummy)
    end
end

function Feed:getTipsKey(eType, status)
    local key = "askforhelp.notify." ..LinkKeyPrefixs[eType] .."." ..tostring(status)
    return Localization:getInstance():getText(key)
end

-- 通知好友
function Feed:NotifyBySns(eSnsType, eLinkType, title, message, thumbUrl, webPageUrl, successCallback, failCallback, cancelCallback)
    local function noShareJustReturn()
        if __WIN32 and successCallback then return successCallback() end
        if failCallback then failCallback() end return
    end
	if self:shareDisabled() then return noShareJustReturn() end

    local function showTips(status)
        local text = self:getTipsKey(eLinkType, status)
        local type = "negative"
        if status == 0 then
            type = "positive"
        end
        setTimeOut(function ( ... ) CommonTip:showTip(text, type) end, 0.001)
    end

	local shareCallback = {
		onSuccess = function(result)
			showTips(0)
			if successCallback then successCallback(0) end
		end,
		onError = function(errCode, msg)
			showTips(1)
			if failCallback then failCallback(1) end
		end,
		onCancel = function()		
			showTips(2)
			if cancelCallback then cancelCallback(2) end
		end
	}

    if eSnsType == PlatformShareEnum.kQQ then
        if __ANDROID then
			luajava.bindClass("com.happyelements.android.share.SystemShareUtil"):getInstance():shareTextToQQ(false, webPageUrl, nil, convertToInvokeCallback(shareCallback))
		else
			SystemShareUtil:shareLink_subject_thumb_callback(webPageUrl, title, thumbUrl, nil)
            if successCallback then successCallback(0) end -- 系统不会给callback，这里直接调一下且不显示tips
		end
    else
        SnsUtil.sendLinkMessage(eSnsType, title, message, thumbUrl, webPageUrl, false, shareCallback)
    end
end

-- 朋友圈分享(安卓平台使用系统分享，可发送炫耀图至朋友圈，ios平台使用游戏内分享)
function Feed:share2FriendCircle(linkType, title, message, imageURL, thumbUrl, successCallback, failCallback, cancelCallback)
    local function noShareJustReturn()
        if __WIN32 and successCallback then return successCallback() end
        if successCallback then successCallback() end return
    end
	if self:shareDisabled() then return noShareJustReturn() end

    local function showTips(status)
        local text = self:getTipsKey(linkType, status)
        local type = "negative"
        if status == 0 then
            type = "positive"
        end
        setTimeOut(function ( ... ) CommonTip:showTip(text, type) end, 0.001)
    end

    title = title or ""
    message = message or ""
    imageURL = imageURL or ""

	local shareCallback = {
		onSuccess = function(result)
			showTips(0)
			if successCallback then successCallback(0) end
		end,
		onError = function(errCode, msg)
			showTips(1)
			if failCallback then failCallback(1) end
		end,
		onCancel = function()		
			showTips(2)
			if cancelCallback then cancelCallback(2) end
		end
	}

    local eShareType = PlatformShareEnum.kWechat

    local function shareToAndroid(title, message, thumbUrl, imageURL, shareCallback)
    	local androidShareType = 8
		AndroidShare.getInstance():registerShare(androidShareType)

        -- eShareType
        eShareType = androidShareType
        SnsUtil.sendImageMessage(androidShareType, title, message, thumbUrl, imageURL, shareCallback, true)
    end

    local function shareToiOS(title, message, thumbUrl, imageURL, shareCallback)
        SnsUtil.sendImageMessage(eShareType, title, message, thumbUrl, imageURL, shareCallback, true)
    end

    if __ANDROID then
        shareToAndroid(title, message, thumbUrl, imageURL, shareCallback)
    elseif __IOS then
        shareToiOS(title, message, thumbUrl, imageURL, shareCallback)
    else
        noShareJustReturn()
    end
end

function Feed:screenShot(cocosObject, filePath, size, isContainClippingNode)
	local self = cocosObject
	local groupBounds = self:getGroupBounds()
	if groupBounds.size.width <= 0 or groupBounds.size.height <= 0 then
		return 
	end
	--限制size的最大，最小值
	local min_size = 32
	local max_size = 1024
	
	--设置
	local o_scaleX = self:getScaleX()
	local o_scaleY = self:getScaleX()

	if groupBounds.size.width > max_size or groupBounds.size.height > max_size then
		print("scale small "..groupBounds.size.width, groupBounds.size.height)
		local scale_1 = max_size/groupBounds.size.width
		local scale_2 = max_size/groupBounds.size.height
		local scale_factor = scale_1 <= scale_2 and scale_1 or scale_2
		self:setScaleX(scale_factor * o_scaleX)
		self:setScaleY(scale_factor * o_scaleY)
	elseif groupBounds.size.width < min_size or groupBounds.size.height < min_size then
		print("scale big "..groupBounds.size.width, groupBounds.size.height)
		local scale_1 = min_size/groupBounds.size.width
		local scale_2 = min_size/groupBounds.size.height
		local scale_factor = scale_1 >= scale_2 and scale_1 or scale_2
		self:setScaleX(scale_factor * o_scaleX)
		self:setScaleY(scale_factor * o_scaleY)
	end
	
	local groupBounds = self:getGroupBounds()
	local gSize = groupBounds.size
	local gOrigin = groupBounds.origin
	if self:getParent() then
		gOrigin = self:getParent():convertToNodeSpace(ccp(gOrigin.x, gOrigin.y))
	end
	size = size or gSize

	if size.width < min_size then
		size.width = min_size
	elseif size.width > max_size then
		size.width = max_size
	end

	if size.height < min_size then
		size.height = min_size
	elseif size.height > max_size then
		size.height = max_size
	end

	local o_x, o_y = self:getPositionX(), self:getPositionY()
	self:setPositionXY(o_x - gOrigin.x, o_y - gOrigin.y)
	--截图
	local renderTexture
	if isContainClippingNode then
		local GL_DEPTH24_STENCIL8 = 0x88F0  --c++中定义的
		renderTexture = CCRenderTexture:create(size.width, size.height, kCCTexture2DPixelFormat_RGBA8888)
		renderTexture:beginWithClear(0, 0, 0, 0, 0)
	else
		renderTexture = CCRenderTexture:create(size.width, size.height)
		renderTexture:begin()
	end
	self:visit()
	renderTexture:endToLua()
	renderTexture:saveToFile(filePath)

	print("save texture to "..filePath)
	--恢复
	self:setPositionXY(o_x, o_y)
	self:setScaleX(o_scaleX)
	self:setScaleY(o_scaleY)
end

return Feed