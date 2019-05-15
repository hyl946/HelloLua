TabFourStarNone = class(Layer)

FourStarType = {
	kStar3 = 1 ,
	kStar4 = 2 ,
}

function TabFourStarNone:ctor()
	
end

function TabFourStarNone:initLayer()
	Layer.initLayer(self)

	--分享部分
	local sharePartUI = self.hostPanel:buildInterfaceGroup("tabFourStarNone")
	-- sharePartUI:getChildByName("level_rect"):setVisible(false)
	-- local sharePartSize = sharePartUI:getGroupBounds().size
	-- local _width = sharePartSize.width
	-- local _height = sharePartSize.height
	-- local shareArea = sharePartUI:getChildByName("share_area")
	-- shareArea:getChildByName("btn"):setVisible(false)
	-- shareArea:getChildByName("label"):setVisible(false)
	-- shareArea:getChildByName("label2"):setString(Localization:getInstance():getText("听说有些关卡可以获得四星哦~"))

	self:addChild(sharePartUI)
end

function TabFourStarNone:create(hostPanel  )
	local layer = TabFourStarNone.new()
	layer.hostPanel = hostPanel
	layer:initLayer()
	return layer
end

----------------------------TabFourStarSome----------------------------
TabFourStarSome = class(Layer)
function TabFourStarSome:create(hostPanel , dataList ,isStar3 ,isFull )
	local layer = TabFourStarSome.new()
	layer.hostPanel = hostPanel
	layer.dataList = dataList
	layer.isStar3 = isStar3
	layer.isFull = isFull
	layer:initLayer()
	return layer
end
function TabFourStarSome:ctor()
	
end

function TabFourStarSome:initLayer()
	Layer.initLayer(self)

	--容器layer
	local layer = Layer:create()
	layer:setTouchEnabled(true, 0, false)

	local sharePartUI = self.hostPanel:buildInterfaceGroup("tabFourStarLevelContent")
	sharePartUI:getChildByName("level_rect"):setVisible(false)
	local sharePartSize = sharePartUI:getGroupBounds().size
	local _width = sharePartSize.width
	local _height = sharePartSize.height
	sharePartUI:dispose()

	

	if self.isStar3 then
		local mainBG = Scale9Sprite:createWithSpriteFrameName( "ui_yellow_withoutborder_scale90000" ,CCRectMake(24,24,24,24) )
		
		mainBG:setAnchorPoint(ccp( 0 , 0 ))
		local animaWidth = 570
		local animaHeight = 320
		_height = 240 
		if self.isFull then
			animaHeight = 590
			_height = 500 
		end

		mainBG:setPreferredSize(CCSizeMake(animaWidth, animaHeight))
		self:addChild( mainBG )
		
		mainBG:setPosition(ccp( 15 , -animaHeight + 70 ))


		local mainTitle = Sprite:createWithSpriteFrameName( "title_30000" )
		mainTitle:setAnchorPoint(ccp( 0.5 , 1 ))
		mainTitle:setPosition(ccp( animaWidth/2 , animaHeight-20 ))
		mainBG:addChild( mainTitle )

	else

		local mainBG = Scale9Sprite:createWithSpriteFrameName( "ui_yellow_withoutborder_scale90000" ,CCRectMake(24,24,24,24) )

		mainBG:setAnchorPoint(ccp( 0 , 0 ))
		local animaWidth = 570
		local animaHeight = 240
		_height = 150 
		if self.isFull then
			animaHeight = 590
			_height = 500 
		end
		mainBG:setPreferredSize(CCSizeMake(animaWidth, animaHeight))
		self:addChild( mainBG )
		mainBG:setPosition(ccp( 15 , -animaHeight + 70 ))
		
		local mainTitle = Sprite:createWithSpriteFrameName( "title_40000" )
		mainTitle:setAnchorPoint(ccp( 0.5 , 1 ))
		mainTitle:setPosition(ccp( animaWidth/2 , animaHeight-20 ))
		mainBG:addChild( mainTitle )

	end


	--滚动部分
	local level_vertical_scrollable = VerticalScrollable:create(_width, _height, true, false)

	local posY2NodeMap = {}

	--关卡花部分
	if self.dataList == nil  then
		self.dataList = FourStarManager:getInstance():getAllCompleteFourStarLevels()
	end
--	local dataList = FourStarManager:getInstance():getAllCompleteFourStarLevels()

--	local dataList_3 ,dataList_4 = FourStarManager:getInstance():getAllUnlockStar4Levels()

	local dataList = self.dataList

	-- if FourStarType.kStar3 then
	-- 	dataList = dataList_3
	-- else
	-- 	dataList = dataList_4
	-- end

	local offset_Y = 20

	local offset_x = nil
	local x_index = nil
	local cell_size = CCSizeMake(150, 160)
	local context = self
	for i=1,#dataList do
		local data = dataList[i]
        local flowerType = kFlowerType.kFourStar
        if JumpLevelManager.getInstance():hasJumpedLevel( data.level ) then
        	flowerType = kFlowerType.kJumped
        end
		local node = FlowerNodeUtil:createWithSize(flowerType, data.level, data.star, cell_size,true)
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
			x_index = math.floor(_width/cell_size.width)
			offset_x = (_width - x_index*cell_size.width) / (x_index - 1)
		end
		local x_p = ((i- 1)%x_index ) * (cell_size.width + offset_x) - 0
		node:setPositionX(x_p)
		local y_p = (-math.floor((i-1)/x_index)*cell_size.height)

		local y_index = math.floor(y_p + 0.5)
		posY2NodeMap[y_index] = posY2NodeMap[y_index] or {}
		table.insert(posY2NodeMap[y_index], node)

		node:setPositionY( y_p + offset_Y )
		node.scrollable = level_vertical_scrollable
		layer:addChild(node)
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
	self:addChild(level_vertical_scrollable)



end

function TabFourStarSome:onShowLevelStartPanel()
	self:dispatchEvent(Event.new(FourStarGuideEvent.kCloseAllStarGuidePanel))
	self.hostPanel:onCloseBtnTapped()
end

