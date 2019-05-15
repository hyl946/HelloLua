require "zoo.panel.basePanel.BasePanel"
require "zoo.net.OnlineGetterHttp"

local SelectShareWay = require "zoo.panel.share.sharePanelVerB.components.SelectShareWay"

--目前不测试是否可以单独使用，请考虑使用ArmatureShareBasePanel(_B)

ShareBasePanel_B = class(BasePanel)

function ShareBasePanel_B:init()

	BasePanel.init(self,self.ui)
    
    self.achiManager = Achievement
    
    local achi = self.achiManager:getAchi(self.shareId)
	local config = achi:getShareConfig()
	self.achi = achi
	self.config = config
	self.sharePriority = config.priority
	self.shareTitleKey = config.shareTitle

	-- 打点 http://wiki.happyelements.net/pages/viewpage.action?pageId=36700449
	self.t1 = self.config.id
	self.t2 = nil
	self.t3 = nil

	self:initUI()

	DcUtil:UserTrack({
		category = "show", 
		sub_category = "show_off_trigger", 
		t1 = self.t1,
    })
    
end

function ShareBasePanel_B:initUI()
    self:initBg()
    self:initCloseBtn()
	self:initShareBtn()
	--self.shareImagePath = HeResPathUtils:getResCachePath() .. "/share_image.jpg"
end

function ShareBasePanel_B:initBg()
    -- local wSize = Director:sharedDirector():getWinSize()
    -- self.bg = LayerColor:createWithColor(ccc3(0, 0, 255), wSize.width, wSize.height)
    -- self.ui:addChild(self.bg)

    -- local gradient = LayerGradient:create()
    -- gradient:setStartColor(ccc3(0, 0, 0))
    -- gradient:setEndColor(ccc3(0, 0, 0))
    -- gradient:setStartOpacity(200)
    -- gradient:setEndOpacity(200)
    -- gradient:ignoreAnchorPointForPosition(false)
    -- gradient:setAnchorPoint(ccp(0, 1))
    -- gradient:setScale(1)
    -- gradient:setContentSize(CCSizeMake(wSize.width, wSize.height))
    -- gradient:setPosition(ccp(0, 0))
    -- self.bgGradient = gradient
    -- self.bg:addChild(self.bgGradient)
end

function ShareBasePanel_B:initCloseBtn()
	local closeBtn = self.ui:getChildByName("closeBtn")
	if not closeBtn then 
		-- printx(0, "There is no closeBtn!!!!")
		-- assert(nil)
		return
	end

	local size = Director:sharedDirector():getVisibleSize()
	local origin = Director:sharedDirector():getVisibleOrigin()
	local pos = self.ui:convertToNodeSpace(ccp(origin.x, origin.y))
	local btnSize = closeBtn:getGroupBounds().size
	closeBtn:setPosition(ccp(pos.x + size.width - btnSize.width / 2, pos.y + size.height - btnSize.height / 2))
	
	local function onCloseBtnTapped()
        self:removePopout()
    end
    closeBtn:setTouchEnabled(true)
    closeBtn:setButtonMode(true)
	closeBtn:addEventListener(DisplayEvents.kTouchTap, onCloseBtnTapped)
	
	self.closeBtn = closeBtn
end

function ShareBasePanel_B:initShareBtn()
	self.shareBtnPanel = SelectShareWay:create()
	self.ui:addChild(self.shareBtnPanel.ui)

	local visibleSize = CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin = CCDirector:sharedDirector():getVisibleOrigin()

	local panelSize = self.shareBtnPanel.ui:getGroupBounds().size
	local panelWidth = panelSize.width
	local panelHeight = panelSize.height

	self.shareBtnPanel.ui:setPositionX(visibleOrigin.x + (visibleSize.width - panelWidth)/2)
	self.shareBtnPanel.ui:setPositionY(panelHeight - visibleSize.height + 60)

	SelectShareWay:setSaveBtnAction(self.shareBtnPanel, function () printx("0","ShareBasePanel_B:initShareBtn:  NotImplemented") end)--todo
	SelectShareWay:setWeixinBtnAction(self.shareBtnPanel, function () printx("0","ShareBasePanel_B:initShareBtn:  NotImplemented") end)--todo
	SelectShareWay:setFriendCircleBtnAction(self.shareBtnPanel, function () printx("0","ShareBasePanel_B:initShareBtn:  NotImplemented") end)--todo
end

-- function ShareBasePanel_B:initShareTitle(titleName)
--     if _G.isLocalDevelopMode then printx(0, "ShareBasePanel_B:initShareTitle(titleName): titleName = " .. titleName) end
--     local slot = self.armatureNode:getSlot('txt')
--     if slot then
--         local text = BitmapText:create(titleName, 'fnt/share.fnt', 0)
--         text:setAnchorPoint(ccp(0.5, 0.5))
--         -- text.refCocosObj:release()
--         local sprite = Sprite:createEmpty()
--         -- sprite:setCascadeOpacityEnabled(true)
--         -- sprite:retain()
--         sprite:addChild(text)
--         slot:setDisplayImage(sprite.refCocosObj)
--     else
--         if _G.isLocalDevelopMode then printx(0, "ShareBasePanel_B:initShareTitle(titleName): not found slot'txt'") end
--     end
-- end

-- function ShareBasePanel_B:onShareBtnTapped()
-- 	if ShareUtil:getConfig(self.config.id) ~= nil then
-- 		self:sendShareLinkByConfig(self.config.id)
-- 	else
-- 		self:screenshotShareImage()
-- 	end
-- end

-- function ShareBasePanel_B:sendShareLinkByConfig( ... )
-- 	-- -- 只管微信
-- 	-- if PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk) then
-- 	-- 	self:onShareFailed()
-- 	-- 	return
-- 	-- end

-- 	DcUtil:UserTrack({
-- 		category = "show", 
-- 		sub_category = "push_show_off", 
-- 		action = 'button', 
-- 		id = self.sharePriority,
-- 		t1 = self.t1,
-- 		t2 = self.t2,
-- 		t3 = self.t3,
-- 	})

-- 	local textid,title,message,btn
-- 	local uid = tonumber(UserManager:getInstance().uid) or 0
-- 	if uid % 100 < 50 then
-- 		textid = self.config.id 
-- 		title,message = self:getShareLinkTitleMessage()
-- 		btn = "btn1"
-- 	else
-- 		local dailyData = Localhost:readLocalDailyData()
-- 		if type(dailyData.shareTextRandoms) ~= "table" or #dailyData.shareTextRandoms == 0 then
-- 			dailyData.shareTextRandoms = {}
-- 			for i=1,10 do
-- 				table.insert(dailyData.shareTextRandoms,i)
-- 			end
-- 		end
-- 		-- 每天每种文案只出现一次
-- 		local randomIndex = dailyData.shareTextRandoms[math.random(1,#dailyData.shareTextRandoms)]
-- 		table.removeValue(dailyData.shareTextRandoms,randomIndex)

-- 		Localhost:writeLocalDailyData(nil,dailyData)

-- 		textid = -randomIndex
-- 		title = Localization:getInstance():getText("show_new_title" .. textid)
-- 		message = Localization:getInstance():getText("show_new_text" .. textid)
-- 		btn = "btn2"
-- 	end

-- 	local shareCallback = {
-- 		onSuccess = function(result)
-- 			self:onShareSucceed()

-- 			DcUtil:UserTrack({
-- 				category = "show", 
-- 				sub_category = "show_off_success_text", 
-- 				t1 = textid
-- 			})	
-- 		end,
-- 		onError = function(errCode, errMsg)
-- 			self:onShareFailed()
-- 		end,
-- 		onCancel = function()
-- 			self:onShareFailed()
-- 		end,
-- 	}

-- 	local thumb = nil
-- 	local path = "share/icon/" .. self:getShareImgName()
-- 	local fullPath = CCFileUtils:sharedFileUtils():fullPathForFilename(path)
-- 	if  fullPath ~= path then
-- 		thumb = fullPath
-- 	end

-- 	local profile = UserManager.getInstance().profile
-- 	local params = self:getShareParam(message, textid, btn, ShareUtil:toHeadUrl(profile.headUrl), profile:getDisplayName())
	
-- 	if self.level then
-- 		if LevelType:isHideLevel( self.level ) then
-- 			local levelId = '+'..tostring( self.level % LevelConstans.HIDE_LEVEL_ID_START )
-- 			params['level'] = levelId
-- 		else
-- 			params['level'] = tostring(self.level)
-- 		end
-- 	end

-- 	ShareUtil:shareByShareId(self.config.id,shareCallback,params,thumb,title,message)
-- end

-- function ShareBasePanel_B:getShareLinkTitleMessage( ... )	
-- 	local title = Localization:getInstance():getText("show_new_title" .. self.config.id)
-- 	local message = Localization:getInstance():getText("show_new_text" .. self.config.id)

-- 	return title,message
-- end

-- function ShareBasePanel_B:getShareParam(msg, txtID, btn, headImage, nickName)
-- 	local params = {}
-- 	params["text"] = msg
-- 	params["textid"] = txtID
-- 	params["btn"] = btn

-- 	params["headImage"] = headImage
-- 	params["nickName"] = nickName
-- 	return params
-- end

-- function ShareBasePanel_B:getShareImgName()
-- 	return self.config.id .. ".jpg"
-- end

-- function ShareBasePanel_B:screenshotShareImage( ... )
-- 	local function srnShot()
-- 		self:srnShot()
-- 	end
-- 	local function afterSrnShot()
-- 		self:afterSrnShot()
-- 		self:sendShareImage()
-- 	end
-- 	self:beforeSrnShot(srnShot, afterSrnShot)
-- end

-- function ShareBasePanel_B:beforeSrnShot(srnShot, afterSrnShot)
-- 	if self.share_background ~= nil then
-- 		return
-- 	end
-- 	if not self.shareTitle then
-- 		assert(false, "no shareTitle")
-- 		self:removePopout()
-- 		return 
-- 	end
-- 	self.share_background = Sprite:create("share/share_background.png")
-- 	local y = self.shareTitle:getPositionY() - 45
-- 	self.offsetY = y
-- 	self.share_background:setAnchorPoint(ccp(0,0))

-- 	local size = self.share_background:getContentSize()

-- 	if _G.__use_small_res == true then
-- 		self.share_background:setScale(0.625)
-- 		size.width = size.width * 0.625
-- 		size.height = size.height * 0.625
-- 	end

-- 	local children = self.ui:getChildrenList()

-- 	for k,child in pairs(children) do
-- 		local pos = child:getPosition()
-- 		child:setPosition(ccp(pos.x, pos.y - y))
-- 	end

-- 	local btn = self.ui:getChildByName("closeBtn")
-- 	btn:setVisible(false)

-- 	self.ui:addChildAt(self.share_background, 1)

-- 	local bg_2d = ShareUtil:getQRCodePath()
-- 	self.share_background_2d = Sprite:create(bg_2d)

-- 	self.ui:addChild(self.share_background_2d)

-- 	local size_2d = self.share_background_2d:getContentSize()
-- 	self.share_background_2d:setPosition(ccp(size.width - size_2d.width / 2 - 5, size.height - size_2d.height / 2 - 15))

--     local head_frame_pathname = 'share/share_background_head_frame.png'
-- 	self.head_frame = Sprite:create(head_frame_pathname)
-- 	local head_frame_size = self.head_frame:getContentSize()
-- 	self.head_frame:setPositionXY(head_frame_size.width / 2 + 25, size.height - head_frame_size.height / 2 - 10)

-- 	if _G.__use_small_res == true then
-- 		self.head_frame:setScale(0.625)
-- 		head_frame_size.width = head_frame_size.width * 0.625
-- 		head_frame_size.height = head_frame_size.height * 0.625
-- 	end

-- 	local function onImageLoadFinishCallback(headImage)
--         local pos = self.head_frame:getPosition()
--         self.headImage = headImage
--         self.headImage:setPositionXY(pos.x, pos.y)
--         self.headImage:setScale(0.65)
--         if _G.__use_small_res == true then
-- 			--self.headImage:setScale(0.625*0.65)
-- 		end
--         self.ui:addChild(self.headImage)
--         self.ui:addChild(self.head_frame)

-- 	    local pos = self.headImage:getPosition()
-- 	    local username = UserManager.getInstance().profile:getDisplayName()
-- 	    if _G.isLocalDevelopMode then printx(0, '----------', username, '---------------') end
-- 	    self.username = TextField:create(username, "微软雅黑", 24, CCSizeMake(24*6, 24), kCCTextAlignmentCenter)
-- 	    self.username:setAnchorPoint(ccp(0.5, 0))
-- 	    self.username:setPositionXY(self.head_frame:getPositionX() + 2, pos.y - 65)
-- 	    if _G.__use_small_res == true then
-- 			--self.username:setScale(0.625)
-- 		end
-- 	    self.ui:addChild(self.username)

-- 	    if srnShot then
-- 			srnShot()
-- 		end
-- 		if afterSrnShot then
-- 	   		afterSrnShot()
-- 	   	end
-- 	end

--     local uid = UserManager:getInstance().uid
--     local headUrl = UserManager:getInstance().profile.headUrl
--     HeadImageLoader:create(userId, headUrl, onImageLoadFinishCallback)
-- end

-- function ShareBasePanel_B:srnShot()
-- 	local size = self.share_background:getContentSize()
-- 	if _G.__use_small_res == true then
-- 		size.width = size.width*0.625
-- 		size.height = size.height*0.625
-- 	end
-- 	local renderTexture = CCRenderTexture:create(size.width, size.height)
-- 	renderTexture:begin()
-- 	self.ui:visit()
-- 	renderTexture:endToLua()
-- 	renderTexture:saveToFile(self.shareImagePath)
-- end

-- function ShareBasePanel_B:afterSrnShot()
-- 	self.username:removeFromParentAndCleanup(true)
-- 	self.headImage:removeFromParentAndCleanup(true)
-- 	self.head_frame:removeFromParentAndCleanup(true)
-- 	self.share_background:removeFromParentAndCleanup(true)
-- 	self.share_background_2d:removeFromParentAndCleanup(true)
-- 	for k,child in pairs(self.ui:getChildrenList()) do
-- 		local pos = child:getPosition()
-- 		child:setPosition(ccp(pos.x, pos.y + self.offsetY))
-- 	end
-- 	self.ui:getChildByName("closeBtn"):setVisible(true)
-- 	self.share_background = nil
-- end

-- function ShareBasePanel_B:sendShareImage()
-- 	DcUtil:UserTrack({
-- 		category = "show", 
-- 		sub_category = "push_show_off", 
-- 		action = 'button', 
-- 		id = self.sharePriority,
-- 		t1 = self.t1,
-- 		t2 = self.t2,
-- 		t3 = self.t3,
-- 	})

-- 	local thumb = CCFileUtils:sharedFileUtils():fullPathForFilename("materials/wechat_icon.png")
-- 	local shareCallback = {
-- 		onSuccess = function(result)
-- 			self:onShareSucceed()
-- 		end,
-- 		onError = function(errCode, errMsg)
-- 			self:onShareFailed()
-- 		end,
-- 		onCancel = function()
-- 			self:onShareFailed()
-- 		end,
-- 	}
	
-- 	local shareType, delayResume = SnsUtil.getShareType()
-- 	SnsUtil.sendImageMessage( shareType, self.shareTitleName, self.shareTitleName, thumb, self.shareImagePath, shareCallback )
-- end

-- function ShareBasePanel_B:onShareSucceed()
-- 	--向后端同步
-- 	local function onSuccess(event)
-- 		if PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk) then
-- 	 		SnsUtil.showShareSuccessTip(PlatformShareEnum.kMiTalk) 
-- 	 	else
-- 	 		SnsUtil.showShareSuccessTip(PlatformShareEnum.kWechat)
-- 	 	end
--         --打点
--         DcUtil:UserTrack({
--         	category = "show", 
--         	sub_category = "push_show_off", 
--         	action = 'success', 
--         	id = self.sharePriority,
--         	t1 = self.t1,
--         	t2 = self.t2,
--         	t3 = self.t3,
--         })

--         --关闭
--         self:removePopout()

--         --记录炫耀次数
--         ShareManager:increaseShareAllTime()
--     end

--     local function onFail(event)
--        	--关闭
--         self:removePopout()
--     end
    
-- 	onSuccess()
-- end

-- function ShareBasePanel_B:onShareFailed()
-- 	local scene = Director:sharedDirector():getRunningScene()
-- 	if scene then
-- 		local shareFailedLocalKey = "share.feed.faild.tips"
-- 		CommonTip:showTip(Localization:getInstance():getText(shareFailedLocalKey), 'negative', nil, 2)
-- 	end
-- end

function ShareBasePanel_B:removePopout()
	PopoutManager:sharedInstance():removeWithBgFadeOut(self, false, true)
end

function ShareBasePanel_B:popoutShowTransition()
	self:setToScreenCenterVertical()
	self:setToScreenCenterHorizontal()
end

function ShareBasePanel_B:popout()
	PopoutManager:sharedInstance():add(self, true)
end

-- function ShareBasePanel_B:onKeyBackClicked(...)
-- 	self:closeCallback()
-- 	BasePanel.onKeyBackClicked(self)
-- end

-- function ShareBasePanel_B:closeCallback()
-- 	PopoutManager:sharedInstance():remove(self, true)
-- end

-- function ShareBasePanel_B:addToLayerColor(ui,anchorPoint)
-- 	local size = ui:getGroupBounds().size
-- 	local pos = ui:getPosition()
-- 	local layer = LayerColor:create()
--     layer:setColor(ccc3(0,0,0))
--     layer:setOpacity(0)
--     layer:setContentSize(CCSizeMake(size.width, size.height))
--     layer:setAnchorPoint(anchorPoint)
--     layer:setPosition(ccp(pos.x, pos.y-size.height))
    
--     local uiParent = ui:getParent()
--     local index = uiParent:getChildIndex(ui)
--     ui:removeFromParentAndCleanup(false)
--     ui:setPosition(ccp(0,size.height))
--     layer:addChild(ui)
--     uiParent:addChild(layer)

--     return layer
-- end

-- ---新障碍 和 隐藏关 子类使用
-- function ShareBasePanel_B:unloadSpecialBackground()
-- 	self.animal:removeFromParentAndCleanup(true)
-- 	table.each(
-- 		self.oldChildren,
-- 		function(child)
-- 			local visible = false
-- 			if self.childrenVisibility and self.childrenVisibility[child] ~= nil then
-- 				visible = self.childrenVisibility[child]
-- 			end
-- 			child:setVisible(visible)
-- 		end
-- 	)
-- 	self.shareTitle:setPositionXY(self.titleOldPos.x, self.titleOldPos.y)
-- 	ShareBasePanel_B.afterSrnShot(self)
-- end

-- ---新障碍 和 隐藏关 子类使用
-- function ShareBasePanel_B:loadSpecialBackground()
-- 	local children = self.ui:getChildrenList()
-- 	self.oldChildren = children
-- 	self.childrenVisibility = {}
-- 	table.each(
-- 		children,
-- 		function(child)
-- 			self.childrenVisibility[child] = child:isVisible()
-- 			child:setVisible(false)
-- 		end
-- 	)

-- 	self.shareTitle:setVisible(true)
-- 	local titleOldPos = self.shareTitle:getPosition()
-- 	self.titleOldPos = ccp(titleOldPos.x, titleOldPos.y)

-- 	self.shareTitle:setPositionXY(
-- 		self.share_background:getGroupBounds().size.width/2 - self.shareTitle:getGroupBounds().size.width/2,
-- 		60
-- 	)

-- 	self.animal = Sprite:create("share/share_"..self.shareId..".png")
-- 	self.animal:setAnchorPoint(ccp(0,0))
-- 	self.ui:addChildAt(self.animal, 2)
-- 	if _G.__use_small_res == true then
-- 	   	self.animal:setScale(0.625)
-- 	end
	
-- 	self.username:setVisible(true)
-- 	self.headImage:setVisible(true)
-- 	self.head_frame:setVisible(true)
-- 	self.share_background:setVisible(true)
-- 	self.share_background_2d:setVisible(true)
-- end