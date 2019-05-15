local UIHelper = require 'zoo.panel.UIHelper'

TabFourStarNone_New = class(Layer)

FourStarType = {
	kStar3 = 1 ,
	kStar4 = 2 ,
}

function TabFourStarNone_New:ctor()
	
end

function TabFourStarNone_New:initLayer()
	Layer.initLayer(self)

	--分享部分
	-- local sharePartUI = self.hostPanel:buildInterfaceGroup("TabFourStarNone_New")
	-- -- sharePartUI:getChildByName("level_rect"):setVisible(false)
	-- -- local sharePartSize = sharePartUI:getGroupBounds().size
	-- -- local _width = sharePartSize.width
	-- -- local _height = sharePartSize.height
	-- -- local shareArea = sharePartUI:getChildByName("share_area")
	-- -- shareArea:getChildByName("btn"):setVisible(false)
	-- -- shareArea:getChildByName("label"):setVisible(false)
	-- -- shareArea:getChildByName("label2"):setString(Localization:getInstance():getText("听说有些关卡可以获得四星哦~"))
	-- self:addChild(sharePartUI)

	local ui = UIHelper:createUI('ui/StarAchievenmentPanel/StarAchievenmentPanel_New.json', 'StarAchievenmentPanel_New/tabFourStarNone_New')

	if self.showType == 1 then
		ui:getChildByPath("tabFourStarNone_title3"):setVisible(false)
		ui:getChildByPath("tabFourStarNone_title4"):setVisible(false)
		ui:getChildByPath("sharebtn"):setVisible(false)
	else	
		ui:getChildByPath("tabFourStarNone_title1"):setVisible(false)
		ui:getChildByPath("tabFourStarNone_title2"):setVisible(false)
	end 

	self:addChild( ui )
end

function TabFourStarNone_New:create( showType ,height )
	local layer = TabFourStarNone_New.new()
	layer.showType = showType
	layer:initLayer( height )
	return layer
end

----------------------------TabFourStarSome_New----------------------------
TabFourStarSome_New = class(Layer)
function TabFourStarSome_New:create( hostPanel , dataList ,isStar3 ,isFull , heightNode , partPro ,isFindAll)
	local layer = TabFourStarSome_New.new()
	layer.hostPanel = hostPanel
	layer.dataList = dataList
	layer.isStar3 = isStar3
	layer.isFull = isFull
	layer.heightNode = heightNode
	layer.partPro = partPro
	layer.isFindAll = isFindAll

	layer:initLayer()
	return layer
end

function TabFourStarSome_New:ctor()
	
end

function TabFourStarSome_New:initLayer(  )
	Layer.initLayer(self)

	--容器layer
	local layer = Layer:create()
	layer:setTouchEnabled(true, 0, false)

	-- local sharePartUI = self.hostPanel:buildInterfaceGroup("tabFourStarLevelContent")
	-- sharePartUI:getChildByName("level_rect"):setVisible(false)
	-- local sharePartSize = sharePartUI:getGroupBounds().size
	-- local _width = sharePartSize.width
	-- local _height = sharePartSize.height
	-- sharePartUI:dispose()
	local _width =  650 
	local _height = self.heightNode
	
	local part1Pro = self.partPro
	local part2Pro = 1 - part1Pro
	if not self.isStar3 then
		part2Pro = self.partPro
		part1Pro = 1 - part2Pro
	end


	if self.isStar3 then
		local mainBG = Scale9Sprite:createWithSpriteFrameName( "StarAchievenmentPanel_New/ui_fourstarbg0000" ,CCRectMake(24,24,24,24) )
		
		mainBG:setAnchorPoint(ccp( 0 , 0 ))
		local animaWidth = _width - 30 
		local animaHeight = self.heightNode * part1Pro
		_height = self.heightNode * part1Pro - 100
		if self.isFull then
			animaHeight = self.heightNode -50
			_height = self.heightNode - 150
		end

		mainBG:setPreferredSize(CCSizeMake(_width, animaHeight))
		self:addChild( mainBG )
		
		mainBG:setPosition(ccp( 0 , -animaHeight + 70 ))

		local mainTitle = Sprite:createWithSpriteFrameName( "StarAchievenmentPanel_New/title30000" )
		mainTitle:setAnchorPoint(ccp( 0.5 , 1 ))
		mainTitle:setPosition(ccp( animaWidth/2 , animaHeight-20 ))
		mainBG:addChild( mainTitle )

	else

		local mainBG = Scale9Sprite:createWithSpriteFrameName( "StarAchievenmentPanel_New/ui_fourstarbg0000" ,CCRectMake(24,24,24,24) )

		mainBG:setAnchorPoint(ccp( 0 , 0 ))
		local animaWidth = _width - 30

		local offset_Y = -20
		if not self.isFindAll then
			offset_Y = - 40
		end

		local animaHeight = self.heightNode * part2Pro + offset_Y
		_height = self.heightNode * part2Pro - 100 + offset_Y
		local posOffset_Y = 0
		if self.isFull then
			animaHeight = self.heightNode -50
			_height = self.heightNode - 150
		else
			posOffset_Y = - 0
		end
		mainBG:setPreferredSize(CCSizeMake(_width, animaHeight))
		self:addChild( mainBG )
		mainBG:setPosition(ccp( 0 , -animaHeight + 70 + posOffset_Y ))
		
		local mainTitle = Sprite:createWithSpriteFrameName( "StarAchievenmentPanel_New/title40000" )
		mainTitle:setAnchorPoint(ccp( 0.5 , 1 ))
		mainTitle:setPosition(ccp( animaWidth/2 , animaHeight-20 ))
		mainBG:addChild( mainTitle )

	end


	--滚动部分
	local level_vertical_scrollable = VerticalScrollable:create( _width , _height , true, false)

	local posY2NodeMap = {}

	--关卡花部分
	if self.dataList == nil  then
		self.dataList = FourStarManager:getInstance():getAllCompleteFourStarLevels()
	end

	local dataList = self.dataList

	local offset_Y = 0

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
					DcUtil:clickFlowerNodeInStarAch( 2 , levelId)
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

function TabFourStarSome_New:onShowLevelStartPanel()
	self:dispatchEvent(Event.new(FourStarGuideEvent.kCloseAllStarGuidePanel))
	self.hostPanel:onCloseBtnTapped()
end

