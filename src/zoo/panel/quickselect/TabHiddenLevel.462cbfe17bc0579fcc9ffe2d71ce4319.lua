require "zoo.animation.FlowerNode"

---------------------------------------------------
---------------------------------------------------
-------------- TabHiddenLevel
---------------------------------------------------
---------------------------------------------------

assert(not TabHiddenLevel)
assert(BaseUI)
TabHiddenLevel = class(BaseUI)

function TabHiddenLevel:create(ui,hostPanel)
	local panel = TabHiddenLevel.new()
	panel:init(ui,hostPanel)
	return panel
end

function TabHiddenLevel:init(ui,hostPanel)
	self.hostPanel = hostPanel
	BaseUI.init(self, ui)

	self:initData()

	self:initUI()
end

function TabHiddenLevel:initData()
end

function TabHiddenLevel:initUI()
	-- local visibleSize = Director:sharedDirector():getVisibleSize()
	-- local size = self:getGroupBounds().size
	-- self:setScale(visibleSize.height/size.height)
	self.ui:getChildByName("content"):setAlpha(0)

	self.contentSize = self.ui:getGroupBounds().size
	self.contentSize = CCSizeMake(self.contentSize.width, self.contentSize.height)
end

function TabHiddenLevel:setVisible(value)
	BaseUI.setVisible(self,value)

	if (value == true) then 
		self:initContent()
	else
		self:removeContent()
	end
end

function TabHiddenLevel:initContent()
	self.ui:removeChildren()
	self.hostPanel.title_full_four_star:setVisible(false)
	self.hostPanel.title_full_hidden:setVisible(false)

	self.contentUI = self.hostPanel:buildInterfaceGroup("tabHiddenLevelContent")
	-- self.contentUI = ResourceManager:sharedInstance():buildGroup("tabFourStarLevelContent") -- right
	self.ui:addChild(self.contentUI)

	self.hiddenLevelDataList = FourStarManager:getInstance():getAllHiddenLevels()
	if #FourStarManager:getInstance():getAllNotPerfectHiddenLevels() > 0 then
		self:initHiddenLevelArea()
	else
		self.hostPanel.title_full_hidden:setVisible(true)
		self.hostPanel.txtDesc:setString("")
		self.hostPanel.txtDesc4:setString( " " )
		self:initShareArea()
	end
	
	self.shareImagePath = HeResPathUtils:getResCachePath() .. "/share_image.jpg"

	DcUtil:UserTrack({
		category = "ui",
		sub_category = "click_hidden_chooselevel",
	},true)

end

function TabHiddenLevel:removeContent()
 	self.ui:removeChildren()
end

-- =======================================

function TabHiddenLevel:initShareArea( ... )
	-- body
	self.contentUI:getChildByName("level_rect"):setVisible(false)

	local shareArea = self.contentUI:getChildByName("share_area")
	local shareBtn = GroupButtonBase:create(shareArea:getChildByName("btn"))
	shareBtn:setString(Localization:getInstance():getText("share.feed.button.achive"))
	local function onShareBtnTap( evt )
		-- body
		DcUtil:shareAllFourStarClick()
		self:onShareBtnTap()
	end
	shareBtn:addEventListener(DisplayEvents.kTouchTap, onShareBtnTap)
end

function TabHiddenLevel:initHiddenLevelArea( ... )
	self.contentUI:getChildByName("share_area"):setVisible(false)
	self.hostPanel.txtDesc:setString(Localization:getInstance():getText("mystar_tag_1.3"))
	if self.hostPanel.txtDesc4 then
		self.hostPanel.txtDesc4:setString(" ")
	end
	local level_node_area = self.contentUI:getChildByName("level_rect")
	local rect_replace = level_node_area:getChildByName("level_rect")
	rect_replace:setVisible(false)
	local size = rect_replace:getGroupBounds().size

	-- if _G.isLocalDevelopMode then printx(0, "=====================>>>>>>>>>>>>",size.width,size.height) end
	-- local panelScale = self.hostPanel:getScale()
	local panelScale = self.hostPanel:getScale()
	local _width = size.width/panelScale	-- 缩放前，原始的宽高
	local _height = size.height/panelScale


	---星星面板换素材
	_width = self.contentSize.width / panelScale / level_node_area:getScaleX()
	_height = self.contentSize.height / panelScale / level_node_area:getScaleY()
	---星星面板换素材

	local pos = rect_replace:getPosition()
	local z_orde = self.contentUI:getChildIndex(rect_replace)
	local level_vertical_scrollable = VerticalScrollable:create(_width, 
		_height, true, false)
	-- local level_vertical_scrollable = VerticalScrollable:create(_width, 580, true, false)

	-- self.contentUI:addChildAt(level_vertical_scrollable, z_orde)
	level_node_area:addChild(level_vertical_scrollable)
	level_vertical_scrollable:setPosition(ccp(pos.x, pos.y))

	if _G.isLocalDevelopMode then printx(0, "~~VerticalScrollable~~",size.width,size.height,_width,_height,panelScale) end
	if _G.isLocalDevelopMode then printx(0, "VerticalScrollable pos",pos.x,pos.y,panelScale) end

	local layer = Layer:create()
	layer:setTouchEnabled(true, 0, false)
	local offset_x = nil
	local x_index = 3
	local cell_size = CCSizeMake(120, 135)
	local dataList = self.hiddenLevelDataList
	local context = self

	local borderX = 40
	local manualAdjustX = 10

	offset_x = (_width - x_index*cell_size.width - borderX*2) / (x_index - 1)

	local posY2NodeMap = {}

	-- 摆放节点
	for k = 1, #dataList do 
		local data = dataList[k]

        local flowerType = kFlowerType.kHidden
        if JumpLevelManager.getInstance():hasJumpedLevel( data.level ) then
        	flowerType = kFlowerType.kJumped
        end
		-- local ui = self.builder:buildGroup("more_star_flower_item")
		-- FourStarGuideLevelNode:create(ui, data.level, data.star, self)
		local node = FlowerNodeUtil:createWithSize(flowerType, data.level, data.star, cell_size,true)
		node.levelId = data.level
		node:setTouchEnabled(true, 0, true)

		--QA非说没有居中，只好手动调一下

		local flowerNode = node.flowerNode
		if flowerNode and flowerNode.label and (not flowerNode.label.isDisposed) then
			flowerNode.label:setPositionX(flowerNode.label:getPositionX() - 4)
		end
		
		local function onTapped( evt )	
			local pos = evt.globalPosition
			if node.scrollable and node.scrollable.touchLayer:hitTestPoint(pos) then
				local levelId = node.levelId

				local canPlay,isFirstFlowerInHiddenBranch = UserManager:getInstance():isHiddenLevelCanPlay(levelId)
				local isOnlineCheckHideLevel, areaId = NewAreaOpenMgr.getInstance():isOnlineCheckHideAreaLevel(levelId)
				if _G.isLocalDevelopMode then printx(0, "hiddenlevelId",levelId,isFirstFlowerInHiddenBranch) end
				if canPlay then
					local function onUnlockSuccess()
						context:onShowLevelStartPanel()
						local startGamePanel = StartGamePanel:create(levelId, GameLevelType.kHiddenLevel)
					    startGamePanel:popout(false)
					end

					if isOnlineCheckHideLevel then 
						NewAreaOpenMgr.getInstance():hideAreaUnlockCheck(areaId, onUnlockSuccess, nil)
					else
						onUnlockSuccess()
					end
				else
					if MetaModel:sharedInstance():isAllLevelsTreeStarForHideArea(areaId) and 
						NewAreaOpenMgr.getInstance():isHideAreaCountdownIng(areaId) then 
						CommonTip:showTip(localize('当前隐藏关未到解锁时间哦~请稍后再试吧~'), 'negative')
					elseif isFirstFlowerInHiddenBranch then
						 local hideAreaMeta = MetaManager.getInstance():getHideAreaByHideLevelId(levelId)
						 local areaRangeStr = ""
						 if hideAreaMeta ~= nil then
						 	areaRangeStr = hideAreaMeta.continueLevels[1] .. "-" .. hideAreaMeta.continueLevels[#hideAreaMeta.continueLevels]
						 end
						CommonTip:showTip(Localization:getInstance():getText("hidlevel_tips1", {n = areaRangeStr}), 1)
					else
						CommonTip:showTip(Localization:getInstance():getText("hidlevel_tips2"), 1)
					end
				end
				DcUtil:UserTrack({
					category = "ui",
					sub_category = "click_see_hidden",
				},true)
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
		local x_p = ((k- 1)%x_index ) * (cell_size.width + offset_x) -0
		node:setPositionX(manualAdjustX + borderX + x_p)
		local y_p = (-math.floor((k-1)/x_index)*cell_size.height)
		node:setPositionY(y_p)

		local y_index = math.floor(y_p + 0.5)
		posY2NodeMap[y_index] = posY2NodeMap[y_index] or {}
		table.insert(posY2NodeMap[y_index], node)

		node.scrollable = level_vertical_scrollable
		layer:addChild(node)

	end
	layer.getHeight = function( self )
		return self:getGroupBounds().size.height / panelScale - #dataList
	end
	layer.updateViewArea = function ( _, top, bottom )
		
		for y_index, nodeGrp in pairs(posY2NodeMap) do
			local v = true
			if -y_index >= top - cell_size.height - 20 and -y_index <= bottom + cell_size.height + 20 then
				v = true
			else
				v = false
			end

			for _, node in pairs(nodeGrp) do
				if node.isDisposed then return end
				node:setVisible(v)
			end
		end

	end
	level_vertical_scrollable:setContent(layer)

end

-- function TabHiddenLevel:popout( ... )
-- 	-- body
-- 	self.allowBackKeyTap = true
-- 	local curScene = Director:sharedDirector():getRunningScene()
-- 	local vSize = Director:sharedDirector():getVisibleSize()
-- 	local visibleOrigin = Director:sharedDirector():getVisibleOrigin()
-- 	local layer = LayerColor:create()
-- 	layer:setContentSize(vSize)
-- 	layer:setColor(ccc3(0,0,0))
-- 	layer:setOpacity(200)
-- 	layer:setPosition(visibleOrigin)
-- 	curScene:addChild(layer, SceneLayerShowKey.POP_OUT_LAYER)
-- 	self.bgLayer = layer
-- 	PopoutManager:sharedInstance():add(self, false, false)
-- end

function TabHiddenLevel:onShowLevelStartPanel( ... )
	-- body
	self:dispatchEvent(Event.new(FourStarGuideEvent.kCloseAllStarGuidePanel))
	self:onCloseBtnTapped()
end

function TabHiddenLevel:onCloseBtnTapped( ... )
	-- -- body
	-- PopoutManager:sharedInstance():remove(self, true)
	-- if self.bgLayer then 
	-- 	self.bgLayer:removeFromParentAndCleanup(true)
	-- end
	-- self.allowBackKeyTap = false
	self.hostPanel:onCloseBtnTapped()
end

function TabHiddenLevel:onShareBtnTap( ... )
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

function TabHiddenLevel:screenShotShareImage( ... )
	-- body
	local ui = self.contentUI:getChildByName("share_area")
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
	local branch = ui:getChildByName("branch")
	-- branch:setVisible(false)

	self.share_background:setAnchorPoint(ccp(0,0))
	self.share_background:setPosition(ccp(0, 0))
	ui:addChildAt(self.share_background, 0)

	local bg_2d = ShareUtil:getQRCodePath()
	self.share_background_2d = Sprite:create(bg_2d)
	ui:addChild(self.share_background_2d)
	local size_2d = self.share_background_2d:getContentSize()
	self.share_background_2d:setPosition(
		ccp(size.width - size_2d.width/2 - 5, size.height - size_2d.height/2 - 5))

	local pic = ui:getChildByName("pc")
	-- local pos_o = pic:getPosition()
	local pos_o =  ccp(pic:getPositionX(), pic:getPositionY())
	local pos_branch_o = ccp(branch:getPositionX(),branch:getPositionY())

	local size_pic = pic:getGroupBounds(pic:getParent()).size
	local x = size.width - size_pic.width
	local y = size.height - size_pic.height
	pic:setPosition(ccp(x/2, size.height -y/2 - 90))
	-- pic:setPosition(ccp(x/2, 150))

	branch:setPosition(ccp(0,pic:getPositionY()+220))


	local ui_o_pos = ccp(ui:getPositionX(), ui:getPositionY())
	-- if _G.isLocalDevelopMode then printx(0, ">>>>>>>>> save >>>>>>>>>>>>>>>",ui_o_pos.x,ui_o_pos.y,pos_o.x,pos_o.y,ui.anchorX,ui.anchorY,pic.anchorX,pic.anchorY) end
	ui:setPosition(ccp(0, 0))
	local renderTexture = CCRenderTexture:create(size.width, size.height)
	renderTexture:begin()
	ui:visit()
	renderTexture:endToLua()
	renderTexture:saveToFile(self.shareImagePath)
	--复原
	-- if _G.isLocalDevelopMode then printx(0, ">>>>>>>>> load >>>>>>>>>>>>>>>",ui_o_pos.x,ui_o_pos.y,pos_o.x,pos_o.y,ui.anchorX,ui.anchorY,pic.anchorX,pic.anchorY) end
	ui:setPosition(ui_o_pos)
	pic:setPosition(pos_o)
	branch:setPosition(pos_branch_o)

	self.share_background:setVisible(false)
	self.share_background_2d:setVisible(false)
	
	btn:setVisible(true)
	branch:setVisible(true)
end

function TabHiddenLevel:onShareFailed( ... )
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

function TabHiddenLevel:onShareSucceed( ... )
	-- body
	if PlatformConfig:isPlatform(PlatformNameEnum.kMiTalk) then
 		SnsUtil.showShareSuccessTip(PlatformShareEnum.kMiTalk) 
 	else
 		SnsUtil.showShareSuccessTip(PlatformShareEnum.kWechat)
 	end
end