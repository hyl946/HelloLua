require "zoo.qr.qrmanager"

QRCodePostPanel = class(BasePanel)

-- static function
function QRCodePostPanel:getQRCodeURL()
	local uid = UserManager:getInstance().uid
	local inviteCode = UserManager:getInstance().inviteCode
	local platformName = StartupConfig:getInstance():getPlatformName()
	local link = NetworkConfig:getShareHost() .."qrcode.jsp?uid="..tostring(uid).."&invitecode="..tostring(inviteCode)..
		"&pid="..tostring(platformName)
	if PlatformConfig:isPlatform(PlatformNameEnum.k360) then
		link = link.."&package=android_360"
	end
	if PlatformConfig:isQQPlatform() then
		link = link.."&isyyb=1"
	else
		link = link.."&isyyb=0"
	end
	return link
end

-- TEST BEFORE USE!!!!
function QRCodePostPanel:saveQRCodeImage(path, width, height, border)
	local sprite = CocosObject.new(QRManager:generatorQRNode(QRCodePostPanel:getQRCodeURL(), size.width, border))
	local sSize = sprite:getContentSize()
	sprite:setScaleX(width / sSize.width)
	sprite:setScaleY(height / sSize.height)
	sprite:setPositionY(-sSize.height * math.abs(sprite:getScaleY()))

	local texture = CCRenderTexture:create(width, height)
	texture:beginWithClear(255, 255, 255, 0)
	sprite:visit()
	texture:endToLoa()
	texture:saveToFile(path)
end

function QRCodePostPanel:create()
	local panel = QRCodePostPanel.new()
	panel:init()
	return panel
end

function QRCodePostPanel:init()
	self:loadRequiredResource(PanelConfigFiles.qr_code_panel)
	local ui = self:buildInterfaceGroup("QRCodePanel/postpanel")
	BasePanel.init(self, ui)

	local title = ui:getChildByName("title")
	title:setText(Localization:getInstance():getText("qrcode.panel.title"))
	local bg1 = ui:getChildByName("bg")
	title:setPositionX((bg1:getGroupBounds().size.width - title:getContentSize().width) / 2)
	local code = ui:getChildByName("code")
	code:setVisible(false)

	local size = code:getGroupBounds().size
	local sprite = CocosObject.new(QRManager:generatorQRNode(QRCodePostPanel:getQRCodeURL(), size.width, 1))
	local sSize = sprite:getContentSize()
	sprite:setAnchorPoint(ccp(0, 1))
	sprite:setScaleX(size.width / sSize.width)
	sprite:setScaleY(-size.height / sSize.height) -- original and correct scaleY of image is smaller than zero.
	sprite:setPositionXY(code:getPositionX(), code:getPositionY() - sSize.height * math.abs(sprite:getScaleY()))
	ui:addChild(sprite)

	local close = ui:getChildByName("close")
	close:setTouchEnabled(true)
	close:setButtonMode(true)
	close:addEventListener(DisplayEvents.kTouchTap, function() self:onCloseBtnTapped() end)
	local text = ui:getChildByName("text")
	text:setString(Localization:getInstance():getText("qrcode.panel.desc"))
	local btn = ButtonIconsetBase:create(ui:getChildByName("btn"))
	local shareType = SnsUtil.getShareType()
	local icon = ShareShowUtil.getInstance():getBtnIconByType(shareType)
	icon:setAnchorPoint(ccp(0, 1))
	btn:setIcon(icon)
	if PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk) or PlatformConfig:isJJPlatform() then
		btn:setVisible(false)
		sprite:setPositionY(sprite:getPositionY() - 30)
		local glow = ui:getChildByName("glow")
		glow:setPositionY(glow:getPositionY() - 30)
	else
		btn:setString(Localization:getInstance():getText("add.friend.panel.qrcode.send.wechat"))
		btn:addEventListener(DisplayEvents.kTouchTap, function()
				RequireNetworkAlert:callFuncWithLogged(function() self:onShareTapped() end)
			end)
	end

	self:scaleAccordingToResolutionConfig()
	self:setPositionForPopoutManager()
end

function QRCodePostPanel:popout(closeCallback)
	PopoutManager:sharedInstance():add(self)
	self.allowBackKeyTap = true
	self.closeCallback = closeCallback
end

function QRCodePostPanel:onCloseBtnTapped()
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
	if self.closeCallback then
		self.closeCallback() 
	end
end

function QRCodePostPanel:onShareTapped()
	local thumb = CCFileUtils:sharedFileUtils():fullPathForFilename("materials/wechat_icon.png")
	local title = Localization:getInstance():getText("invite.friend.panel.share.title")
	local text = Localization:getInstance():getText("add.friend.panel.qrcode.share.desc")
	local uid = UserManager:getInstance().uid
	local inviteCode = UserManager:getInstance().inviteCode
	local platformName = StartupConfig:getInstance():getPlatformName()
	local link = QRCodePostPanel:getQRCodeURL()
	local shareCallback = {
        onSuccess=function(result)
        	if PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk) then
        		CommonTip:showTip(Localization:getInstance():getText("share.feed.success.tips.mitalk"), "positive")
        	else
        		CommonTip:showTip(Localization:getInstance():getText("share.feed.success.tips"), "positive")
        	end
        	DcUtil:qrCodeSendToWechatTapped()
        end,
        onError=function(errCode, msg)
        	if PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk) then
        		CommonTip:showTip(Localization:getInstance():getText("share.feed.faild.tips.mitalk"), "negative")
        	else
        		CommonTip:showTip(Localization:getInstance():getText("share.feed.faild.tips"), "negative")
        	end
        end,
        onCancel=function()
        	if PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk) then
        		CommonTip:showTip(Localization:getInstance():getText("share.feed.cancel.tips.mitalk"), "positive")
        	else
        		CommonTip:showTip(Localization:getInstance():getText("share.feed.cancel.tips"), "positive")
        	end
    	end
    }

	local shareType, delayResume = SnsUtil.getShareType()
	if shareType == PlatformShareEnum.kMiTalk then
    	SnsUtil.sendInviteMessage(PlatformShareEnum.kMiTalk, shareCallback)
    else
    	SnsUtil.sendLinkMessage( shareType, title, text, thumb, link, false, shareCallback)
	end
end

QRCodeReceivePanel = class(BasePanel)

local QRCodeReceivePanelState = {
	kScaning = "scaning",
	kRequestInfo = "info",
	kShowInfo = "show",
	kAddFriend = "add",
	kFinishAddFriend = "finish",
}

function QRCodeReceivePanel:create(logic, successCallback, failCallback)
	local function onFail()
		if failCallback then failCallback() end
	end
	local function onCancel()
		if failCallback then failCallback() end
	end
	local function onInfoSuccess(code, userData)
		local panel = QRCodeReceivePanel.new()
		panel:init(code, logic, userData, successCallback, failCallback)
		if successCallback then successCallback(panel) end
	end
	local function onScanSuccess(code)
		QRCodeReceivePanel:requireFriendInfo(logic, code, onInfoSuccess, onFail, onCancel)
	end
	QRCodeReceivePanel:scanQRCode(onScanSuccess, onFail, onCancel)
end

function QRCodeReceivePanel:init(code, logic, userData, successCallback, failCallback)
	self:loadRequiredResource(PanelConfigFiles.qr_code_panel)
	local ui = self:buildInterfaceGroup("QRCodePanel/receivepanel")
	BasePanel.init(self, ui)
	self.logic = logic

	local head = ui:getChildByName("head")
	head:setVisible(false)
	local function updateHead(sprite)
		if self.isDisposed then return end
		local size = head:getGroupBounds().size
		local sSize = sprite:getContentSize()
		sprite:setScaleX(size.width / sSize.width)
		sprite:setScaleY(size.height / sSize.height)
		sprite:setPositionX(head:getPositionX() + sSize.width * sprite:getScaleX() / 2)
		sprite:setPositionY(head:getPositionY() - sSize.height * sprite:getScaleY() / 2)
		ui:addChild(sprite)
	end
	HeadImageLoader:create(userData.uid, userData.headUrl, updateHead)
	local level = ui:getChildByName("level")
	level:setString(Localization:getInstance():getText("add.friend.panel.user.info.level", {n = userData.userLevel}))
	local name = ui:getChildByName("name")
	local userName = nameDecode(userData.userName or "")
	if string.len(userName) > 0 then
		local field = TextField:create()
		field:setFontSize(name:getFontSize())
		local dimension = name:getDimensions()
		local charTab = {}
		for uchar in string.gfind(userName, "[%z\1-\127\194-\244][\128-\191]*") do
			charTab[#charTab + 1] = uchar
		end
		for i = 1, #charTab do
			local ipt = {}
			for j = 1, i do table.insert(ipt, charTab[j]) end
			if i < #charTab then table.insert(ipt, "...") end
			field:setString(table.concat(ipt))
			if field:getContentSize().width > dimension.width then
				break
			end
			name:setString(table.concat(ipt))
		end
		field:dispose()
	else
		name:setString("ID: "..tostring(userData.uid))
	end
	local bg4 = ui:getChildByName("bg4")
	local title = ui:getChildByName("title")
	local bg = ui:getChildByName("bg")
	title:setText(Localization:getInstance():getText("add.friend.panel.qrcode.title.scan"))
	title:setPositionX((bg:getGroupBounds().size.width - title:getContentSize().width) / 2)
	local close = ui:getChildByName("close")
	close:setTouchEnabled(true)
	close:setButtonMode(true)
	local function onClose() self:onCloseBtnTapped() end
	close:addEventListener(DisplayEvents.kTouchTap, onClose)
	self.btn1 = GroupButtonBase:create(ui:getChildByName("btn1"))
	self.btn1:setString(Localization:getInstance():getText("add.friend.panel.btn.add.text"))
	local function onBtn1Tapped()
		self:addFriend(code)
	end
	self.btn1:addEventListener(DisplayEvents.kTouchTap, onBtn1Tapped)
	self.btn2 = GroupButtonBase:create(ui:getChildByName("btn2"))
	self.btn2:setString(Localization:getInstance():getText("add.friend.panel.qrcode.continue"))
	local function onBtn2Tapped()
		PopoutManager:sharedInstance():remove(self)
		local panel = QRCodeReceivePanel:create(logic, successCallback, failCallback)
	end
	self.btn2:addEventListener(DisplayEvents.kTouchTap, onBtn2Tapped)
	self.btn2:setVisible(false)
	self.text2 = ui:getChildByName("text2")
	self.text2:setString(Localization:getInstance():getText("add.friend.panel.message.sent"))
	self.text2:setVisible(false)
	local text1 = ui:getChildByName("text1")
	text1:setString(Localization:getInstance():getText("add.friend.panel.qrcode.desc.add"))
	local bg3 = ui:getChildByName("bg3")

	self:scaleAccordingToResolutionConfig()
	self:setPositionForPopoutManager()
end


function QRCodeReceivePanel:scanQRCode(successCallback, failCallback, cancelCallback)
	local function onSuccess(url)
		if _G.isLocalDevelopMode then printx(0, "url:", url) end
		local res = UrlParser:parseQRCodeAddFriendUrl(url)
		if _G.isLocalDevelopMode then printx(0, table.tostring(res)) end
		if type(res) ~= "table" or not res.uid or not res.invitecode or not res.isyyb then
			CommonTip:showTip(Localization:getInstance():getText("add.friend.panel.qrcode.not.anipop"), "positive", nil, 2.5) -- TODO
			if failCallback then failCallback() end
		elseif PlatformConfig:isQQPlatform() then
			if res.isyyb == '0' then
				CommonTip:showTip(Localization:getInstance():getText("add.friend.panel.qrcode.desc.yyb2"), "positive", nil, 2.5)
				if failCallback then failCallback() end
			else
				if successCallback then successCallback(res.invitecode) end
			end
		elseif res.isyyb == '1' then
			CommonTip:showTip(Localization:getInstance():getText("add.friend.panel.qrcode.desc.yyb1"), "positive", nil, 2.5)
			if failCallback then failCallback() end
		else
			if successCallback then successCallback(res.invitecode) end
		end
	end
	local function onFail()
		CommonTip:showTip(Localization:getInstance():getText("add.friend.panel.qrcode.check.camera"), "negative")
		if failCallback then failCallback() end
	end
	local function onCancel()
		if cancelCallback then cancelCallback() end
	end

	local callbacks = {onSuccess = onSuccess, onFail = onFail, onCancel = onCancel}
	if PlatformConfig:isQQPlatform() then
		QRManager:startQRScanning(callbacks, Localization:getInstance():getText("add.friend.panel.qrcode.desc.scan"),
			Localization:getInstance():getText("add.friend.panel.qrcode.desc.yyb2"))
	else
		QRManager:startQRScanning(callbacks, Localization:getInstance():getText("add.friend.panel.qrcode.desc.scan"),
			Localization:getInstance():getText("add.friend.panel.qrcode.desc.yyb1"))
	end
end

function QRCodeReceivePanel:requireFriendInfo(logic, code, successCallback, failCallback, cancelCallback)
	local loadAnim, keyBackLayer = nil, nil
	local function onCloseButtonTap()
		if loadAnim then
			loadAnim:removeFromParentAndCleanup(true)
			loadAnim = nil
		end
		if keyBackLayer then
			PopoutManager:sharedInstance():remove(keyBackLayer)
			keyBackLayer = nil
		end
	end

	local function onSuccess(evt)
		onCloseButtonTap()
		if type(evt.data.user) ~= "table" or type(evt.data.profile) ~= "table" then
			CommonTip:showTip(Localization:getInstance():getText("error.tip.730320"), "negative")
			if failCallback then failCallback() end
			return
		end
		local input = {userLevel = evt.data.user.topLevelId, userName = evt.data.profile.name, uid = evt.data.user.uid, headUrl = evt.data.profile.headUrl or evt.data.user.image}
		if successCallback then successCallback(code, input) end
	end
	local function onFail(evt)
		onCloseButtonTap()
		CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(evt.data)), "negative")
		if failCallback then failCallback() end
	end
	local function onCancel()
		onCloseButtonTap()
		if cancelCallback then cancelCallback() end
	end

	local scene = Director:sharedDirector():getRunningScene()
	loadAnim = CountDownAnimation:createNetworkAnimation(scene, onCloseButtonTap)
	keyBackLayer = Layer:create()
	keyBackLayer.onKeyBackClicked = function()
		onCloseButtonTap()
	end
	PopoutManager:sharedInstance():add(keyBackLayer)

	local http = QueryUserHttp.new()
	http:addEventListener(Events.kComplete, onSuccess)
	http:addEventListener(Events.kError, onFail)
	http:addEventListener(Events.kCancel, onCancel)
	http:load(code)
end

function QRCodeReceivePanel:addFriend(code)
	local function onSuccess(data)
		if self.isDisposed then return end
		self.text2:setVisible(true)
		self.btn1:setVisible(false)
		self.btn2:setVisible(true)
		CommonTip:showTip(Localization:getInstance():getText("add.friend.panel.add.success"), "positive")
		DcUtil:addFriendQRCode(1)
	end
	local function onFail(err)
		if self.isDisposed then return end
		CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(err)), "negative")
	end
	local function onCancel()
		if self.isDisposed then return end
	end
	self.logic:sendAddMessage(code, onSuccess, onFail, onCancel, nil, ADD_FRIEND_SOURCE.QR_CODE)
end

function QRCodeReceivePanel:popout()
	PopoutManager:sharedInstance():add(self)
	self.allowBackKeyTap = true
end

function QRCodeReceivePanel:onCloseBtnTapped()
	self.allowBackKeyTap = false
	self:dispatchEvent(Event.new(kPanelEvents.kClose, nil, self))
	PopoutManager:sharedInstance():remove(self)
end