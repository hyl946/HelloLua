require "zoo.animation.FlowerNode"

assert(not TabAskForHelp)
assert(BaseUI)
TabAskForHelp = class(BaseUI)

function TabAskForHelp:create(ui,hostPanel)
	local panel = TabAskForHelp.new()
	panel:init(ui,hostPanel)
	return panel
end

function TabAskForHelp:init(ui,hostPanel)
	self.hostPanel = hostPanel
	BaseUI.init(self, ui)

	self:initUI()
end

function TabAskForHelp:initUI()
	self.ui:getChildByName("content"):setAlpha(0)

	self.contentSize = self.ui:getGroupBounds().size
	self.contentSize = CCSizeMake(self.contentSize.width, self.contentSize.height)
end

function TabAskForHelp:setVisible(value)
	BaseUI.setVisible(self,value)

	if (value == true) then 
		self:initContent()
	else
		self:removeContent()
	end
end

function TabAskForHelp:removeContent()
	self.ui:removeChildren()
end

function TabAskForHelp:initContent()
	self.ui:removeChildren()
	self.hostPanel.title_full_four_star:setVisible(false)
	self.hostPanel.title_full_hidden:setVisible(false)

	self.contentUI = self.hostPanel:buildInterfaceGroup("tabHiddenLevelContent")
	self.ui:addChild(self.contentUI)

	local info = UserManager.getInstance():getAskForHelpInfo()
	if (not info) or table.size(info) == 0 then
		return assert(0)
	end

	self.dataList = info
	self:initLevelInfo()
end

function TabAskForHelp:initLevelInfo( ... )
	self.contentUI:getChildByName("share_area"):setVisible(false)
	self.hostPanel.txtDesc:setString(Localization:getInstance():getText("askforhelp.StarAchievenmentPanel.askforhelpTab.desc"))
	self.hostPanel.txtDesc4:setString( " " )

	
	local level_node_area = self.contentUI:getChildByName("level_rect")
	local rect_replace = level_node_area:getChildByName("level_rect")
	rect_replace:setVisible(false)
	local size = rect_replace:getGroupBounds().size

	local panelScale = self.hostPanel:getScale()
	-- local _width = size.width/panelScale	-- 缩放前，原始的宽高
	-- local _height = size.height/panelScale

	-- _width = self.contentSize.width / panelScale / level_node_area:getScaleX()
	-- _height = self.contentSize.height / panelScale / level_node_area:getScaleY()

	local sharePartUI = self.hostPanel:buildInterfaceGroup("tabFourStarLevelContent")
	sharePartUI:getChildByName("level_rect"):setVisible(false)
	local sharePartSize = sharePartUI:getGroupBounds().size
	local _width = sharePartSize.width
	local _height = sharePartSize.height
	_height = 450 
	local pos = rect_replace:getPosition()
	local z_orde = self.contentUI:getChildIndex(rect_replace)
	local level_vertical_scrollable = VerticalScrollable:create(_width, _height, true, false)

	level_node_area:addChild(level_vertical_scrollable)
	level_vertical_scrollable:setPosition(ccp(pos.x, pos.y))

	local layer = Layer:create()
	layer:setTouchEnabled(true, 0, false)

	local MAX_ROW_ITEMS = 3
	local cell_size = CCSizeMake(150, 160)
--	local cell_size = CCSizeMake(150, 160)
	local dataList = self.dataList
	local context = self

	local borderX = 40
	local manualAdjustX = 10

	local X_STRIDE = (_width - MAX_ROW_ITEMS * cell_size.width - borderX*2) / (MAX_ROW_ITEMS - 1)

	local posY2NodeMap = {}

	-- -- 摆放节点
	-- for k = 1, #dataList do 
	-- 	local data = dataList[k]
	-- 	if data and data.levelId then
			-- local flowerType = kFlowerType.kAskForHelp
			-- local levelId = data.levelId
			-- local star = 0
	-- 		local node = FlowerNodeUtil:createWithSize(flowerType, levelId, star, cell_size,true)
	-- 		node.levelId = data.levelId
	-- 		node:setTouchEnabled(true, 0, true)

			-- local flowerNode = node.flowerNode
			-- if flowerNode and flowerNode.label and (not flowerNode.label.isDisposed) then
			-- 	flowerNode.label:setPositionX(flowerNode.label:getPositionX()-1)
			-- 	flowerNode.label:setPositionY(flowerNode.label:getPositionY()-6)
			-- end

	-- 		local function onTapped( evt )	
	-- 			local pos = evt.globalPosition
	-- 			if node.scrollable and node.scrollable.touchLayer:hitTestPoint(pos) then
	-- 				context:onShowLevelStartPanel()
	-- 				local levelId = node.levelId
	-- 				local startGamePanel = StartGamePanel:create(levelId, GameLevelType.kMainLevel)
	-- 				startGamePanel:popout(false)
	-- 			end
	-- 		end
	-- 		node:ad(DisplayEvents.kTouchTap, onTapped)

	-- 		local x_p = ((k- 1)%MAX_ROW_ITEMS ) * (cell_size.width + X_STRIDE)
	-- 		node:setPositionX(manualAdjustX + borderX + x_p)
	-- 		local y_p = (-math.floor((k-1)/MAX_ROW_ITEMS)*cell_size.height)
	-- 		node:setPositionY(y_p)

	-- 		local y_index = math.floor(y_p + 0.5)
	-- 		posY2NodeMap[y_index] = posY2NodeMap[y_index] or {}
	-- 		table.insert(posY2NodeMap[y_index], node)

	-- 		node.scrollable = level_vertical_scrollable
	-- 		layer:addChild(node)
	-- 	end
	-- end

	local offset_Y = 20

	-- for i=1,30 do
	-- 	table.insert(dataList  , {levelId = 200 + i})
	-- end

	for i=1,#dataList do
		local data = dataList[i]
		local flowerType = kFlowerType.kAskForHelp
		local levelId = data.levelId
		local star = 0
		local node = FlowerNodeUtil:createWithSize(flowerType, levelId, star, cell_size,true)
		node.levelId = data.levelId
		node:setTouchEnabled(true, 0, true)
		local flowerNode = node.flowerNode
		if flowerNode and flowerNode.label and (not flowerNode.label.isDisposed) then
			flowerNode.label:setPositionX(flowerNode.label:getPositionX()-1)
			flowerNode.label:setPositionY(flowerNode.label:getPositionY()-6)
		end
		local function onTapped( evt )	
			local pos = evt.globalPosition
			if node.scrollable and node.scrollable.touchLayer:hitTestPoint(pos) then
				context:onShowLevelStartPanel()
				local levelId = node.levelId
				local startGamePanel = StartGamePanel:create(levelId, GameLevelType.kMainLevel)
				startGamePanel:popout(false)
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
	-- layer.getHeight = function( self )
	-- 	return self:getGroupBounds().size.height / panelScale - #dataList
	-- end

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

function TabAskForHelp:onShowLevelStartPanel( ... )
	self:dispatchEvent(Event.new(FourStarGuideEvent.kCloseAllStarGuidePanel))
	self:onCloseBtnTapped()
end

function TabAskForHelp:onCloseBtnTapped( ... )
	self.hostPanel:onCloseBtnTapped()
end