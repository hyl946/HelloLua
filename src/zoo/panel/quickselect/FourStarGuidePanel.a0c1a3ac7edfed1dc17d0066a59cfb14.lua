-- require "zoo.panel.quickselect.FourStarGuideLevelNode"
require "zoo.animation.FlowerNode"

FourStarGuidePanel = class(BasePanel)

function FourStarGuidePanel:create(  )
	-- body
	local s = FourStarGuidePanel.new()
	s:loadRequiredResource(PanelConfigFiles.four_star_guid)
	s:init()
	return s
end

function FourStarGuidePanel:init(  )
	-- body
	self.ui = self:buildInterfaceGroup("four_star_guide_panel")
	BasePanel.init(self, self.ui)

	local function onCloseTap( ... )
		-- body
		self:dispatchEvent(Event.new(FourStarGuideEvent.kReturnQuickSelectPanel))
		self:onCloseBtnTapped()
	end
	
	-- self:scaleAccordingToResolutionConfig()
	local visibleSize = Director:sharedDirector():getVisibleSize()
	local size = self:getGroupBounds().size
	self:setScale(visibleSize.height/size.height)
	self:setPositionForPopoutManager()
	self:initStarShowArea()

	self.fourStarDataList = FourStarManager:getInstance():getAllNotToFourStarLevels()
	if #self.fourStarDataList > 0 then
		self:initFourStarLevelArea()
	else
		self:initShareArea()
	end
	
	self:createTouchButton("close_btn", onCloseTap)
	self.shareImagePath = HeResPathUtils:getResCachePath() .. "/share_image.jpg"
end

function FourStarGuidePanel:initStarShowArea( ... )
	-- body
	local max_main_star_txt = "/"..FourStarManager:getInstance():getMaxMainStar()
	local max_main_star = self.ui:getChildByName("star_num_t_1")
	max_main_star:setText(max_main_star_txt)

	local main_star = self.ui:getChildByName("star_num_1")
	main_star:setText(FourStarManager:getInstance():getMyMainStar())
	main_star:setColor(ccc3(255, 255, 0))
	local size = main_star:getContentSize()
	local pos_x = max_main_star:getPositionX()
	local offset_x = -1
	main_star:setPositionX(pos_x - size.width - offset_x)
	self.ui:getChildByName("txt_context_1"):setString(
		Localization:getInstance():getText("mystar_common_desc_1", {n="\n\n"}))

	local max_hide_star_txt = "/"..FourStarManager:getInstance():getMaxHideStar()
	local max_hide_star = self.ui:getChildByName("star_num_t_2")
	max_hide_star:setText(max_hide_star_txt)
	local hide_star = self.ui:getChildByName("star_num_2")
	hide_star:setText(FourStarManager:getInstance():getMyHideStar())
	hide_star:setColor(ccc3(255,153,255))
	size = hide_star:getContentSize()
	pos_x = max_hide_star:getPositionX()
	hide_star:setPositionX(pos_x - size.width - offset_x)
	self.ui:getChildByName("txt_context_2"):setString(
		Localization:getInstance():getText("mystar_common_desc_2", {n="\n\n"}))
end

function FourStarGuidePanel:initShareArea( ... )
	-- body
	self.ui:getChildByName("level_rect"):setVisible(false)
	-- self.ui:getChildByName("txt_context_3"):setString(
	-- 	Localization:getInstance():getText("fourstar_desc_done"))
	local shareArea = self.ui:getChildByName("share_area")
	local shareBtn = GroupButtonBase:create(shareArea:getChildByName("btn"))
	shareBtn:setString(Localization:getInstance():getText("share.feed.button.achive"))
	local function onShareBtnTap( evt )
		-- body
		DcUtil:shareAllFourStarClick()
		self:onShareBtnTap()
	end
	shareBtn:addEventListener(DisplayEvents.kTouchTap, onShareBtnTap)
end

function FourStarGuidePanel:initFourStarLevelArea( ... )
	-- body
	self.ui:getChildByName("share_area"):setVisible(false)
	self.ui:getChildByName("txt_context_3"):setString(
		Localization:getInstance():getText("fourstar_desc"))

	local level_node_area = self.ui:getChildByName("level_rect")
	local rect_replace = level_node_area:getChildByName("level_rect")
	rect_replace:setVisible(false)
	local size = rect_replace:getGroupBounds().size
	local panelScale = self:getScale()
	local _width = size.width/panelScale
	local _height = size.height/panelScale

	local pos = rect_replace:getPosition()
	local z_orde = self.ui:getChildIndex(rect_replace)
	local level_vertical_scrollable = VerticalScrollable:create(_width, 
		_height, true, false)
	-- self.ui:addChildAt(level_vertical_scrollable, z_orde)
	level_node_area:addChild(level_vertical_scrollable)
	level_vertical_scrollable:setPosition(ccp(pos.x, pos.y))

	local layer = Layer:create()
	layer:setTouchEnabled(true, 0, false)
	local offset_x = nil
	local x_index = nil
	local cell_size = CCSizeMake(152, 185)
	local dataList = self.fourStarDataList
	local context = self
	for k = 1, #dataList do 
		local data = dataList[k]

        local flowerType = kFlowerType.kNormal
        if JumpLevelManager.getInstance():hasJumpedLevel( data.level ) then
        	flowerType = kFlowerType.kJumped
        end
		local node = FlowerNodeUtil:createWithSize(flowerType, data.level, data.star, cell_size)
		node.levelId = data.level
		node:setTouchEnabled(true, 0, true)
		
		local function onTapped( evt )	
			local pos = evt.globalPosition
			if node.scrollable and node.scrollable.touchLayer:hitTestPoint(pos) then
				local levelId = node.levelId
				if levelId <= UserManager.getInstance().user:getTopLevelId() then
					context:onShowLevelStartPanel()
					local startGamePanel = StartGamePanel:create(levelId, GameLevelType.kMainLevel)
				    startGamePanel:popout(false)
				else
					CommonTip:showTip(Localization:getInstance():getText("fourstar_tips"), 1)
				end
			else
				-- if _G.isLocalDevelopMode then printx(0, "-------------------") end
			end
		end
		node:ad(DisplayEvents.kTouchTap, onTapped)

		if not x_index then
			-- cell_size = node:getGroupBounds().size
			x_index = math.floor(_width/cell_size.width)
			offset_x = (_width - x_index*cell_size.width) / (x_index - 1)
		end
		local x_p = ((k- 1)%x_index ) * (cell_size.width + offset_x)
		node:setPositionX(x_p)
		local y_p = (-math.floor((k-1)/x_index)*cell_size.height)
		node:setPositionY(y_p)
		node.scrollable = level_vertical_scrollable
		layer:addChild(node)
	end
	layer.getHeight = function( self )
		-- body
		return self:getGroupBounds().size.height / panelScale
	end
	level_vertical_scrollable:setContent(layer)

end

function FourStarGuidePanel:popout( ... )
	-- body
	self.allowBackKeyTap = true
	local curScene = Director:sharedDirector():getRunningScene()
	local vSize = Director:sharedDirector():getVisibleSize()
	local visibleOrigin = Director:sharedDirector():getVisibleOrigin()
	local layer = LayerColor:create()
	layer:setContentSize(vSize)
	layer:setColor(ccc3(0,0,0))
	layer:setOpacity(200)
	layer:setPosition(visibleOrigin)
	curScene:addChild(layer, SceneLayerShowKey.POP_OUT_LAYER)
	self.bgLayer = layer
	PopoutManager:sharedInstance():add(self, false, false)
end

function FourStarGuidePanel:onShowLevelStartPanel( ... )
	-- body
	self:dispatchEvent(Event.new(FourStarGuideEvent.kCloseAllStarGuidePanel))
	self:onCloseBtnTapped()
end

function FourStarGuidePanel:onCloseBtnTapped( ... )
	-- body
	PopoutManager:sharedInstance():remove(self, true)
	if self.bgLayer then 
		self.bgLayer:removeFromParentAndCleanup(true)
	end
	self.allowBackKeyTap = false
end

function FourStarGuidePanel:onShareBtnTap( ... )
	-- body
	self:screenShotShareImage()
	local thumb = CCFileUtils:sharedFileUtils():fullPathForFilename("materials/wechat_icon.png")
	local shareCallback = {
		onSuccess = function(result)
			self:onShareSucceed()
		end,
		onError = function(errCode, errMsg)
			self:onShareFailed()
		end,
		onCancel = function()
			self:onShareFailed()
		end,
	}

	local shareType, delayResume = SnsUtil.getShareType()
	SnsUtil.sendImageMessage( shareType, nil, nil, thumb, self.shareImagePath, shareCallback )
end

function FourStarGuidePanel:screenShotShareImage( ... )
	-- body
	local ui = self.ui:getChildByName("share_area")
	if self.share_background ~= nil then
		return 
	end

	self.share_background = Sprite:create("share/share_background.png")
	local size = self.share_background:getContentSize()

	if _G.__use_small_res == true then
		self.share_background:setScale(0.625)
		size.width = size.width * 0.625
		size.height = size.height * 0.625
	end

	local btn = ui:getChildByName("btn")
	btn:setVisible(false)
	self.share_background:setAnchorPoint(ccp(0,0))
	self.share_background:setPosition(ccp(0, 0))
	ui:addChildAt(self.share_background, 0)

	local bg_2d = ShareUtil:getQRCodePath()
	self.share_background_2d = Sprite:create(bg_2d)
	ui:addChild(self.share_background_2d)
	local size_2d = self.share_background_2d:getContentSize()
	self.share_background_2d:setPosition(
		ccp(size.width - size_2d.width/2 - 5, size.height - size_2d.height/2 - 5))

	local pic = ui:getChildByName("pic")
	local pos_o = pic:getPosition()

	local size_pic = pic:getGroupBounds().size
	local x = size.width - size_pic.width
	local y = size.height - size_pic.height
	pic:setPosition(ccp(x/2, size.height -y/2))

	local ui_o_pos = ccp(ui:getPositionX(), ui:getPositionY())
	ui:setPosition(ccp(0, 0))
	local renderTexture = CCRenderTexture:create(size.width, size.height)
	renderTexture:begin()
	ui:visit()
	renderTexture:endToLua()
	renderTexture:saveToFile(self.shareImagePath)
	--复原
	ui:setPosition(ui_o_pos)
	pic:setPosition(pos_o)
	self.share_background:setVisible(false)
	self.share_background_2d:setVisible(false)
	btn:setVisible(true)
end

function FourStarGuidePanel:onShareFailed( ... )
	-- body
	local scene = Director:sharedDirector():getRunningScene()
	if scene then
		local shareFailedLocalKey = "share.feed.faild.tips"
		if PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk) then
	 		shareFailedLocalKey = "share.feed.faild.tips.mitalk" 
	 	end
		CommonTip:showTip(Localization:getInstance():getText(shareFailedLocalKey), 'negative', nil, 2)
	end
end

function FourStarGuidePanel:onShareSucceed( ... )
	-- body
	if PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk) then
 		SnsUtil.showShareSuccessTip(PlatformShareEnum.kMiTalk) 
 	else
 		SnsUtil.showShareSuccessTip(PlatformShareEnum.kWechat)
 	end
end

function FourStarGuidePanel:unloadRequiredResource()
end