-- 活动面板
require "zoo.ActivityCenter.ActivityCenterPanel"

ActivityCenterScene = class(Scene)

function ActivityCenterScene:create(defaultData)
	local s = ActivityCenterScene.new()
	s.defaultData = defaultData
	s:initScene()
	return s	
end

function ActivityCenterScene:ctor()

end

function ActivityCenterScene:dispose( ... )
	Scene.dispose(self)
	ActivityCenter:unloadResources()
end


function ActivityCenterScene:onInit(Scene, ...)
	local visibleOrigin = Director:sharedDirector():getVisibleOrigin()
	local visibleSize = Director:sharedDirector():getVisibleSize()
	
	self.builder = ActivityCenter:loadResources("ui/ActivityCenter/ActivityCenterPanel.json")

	local background = LayerGradient:create()
	background:changeWidthAndHeight(visibleSize.width, visibleSize.height)
	background:setStartColor(ccc3(255, 216, 119))
    background:setEndColor(ccc3(247, 187, 129))
    background:setStartOpacity(255)
    background:setEndOpacity(255)
    background:ignoreAnchorPointForPosition(false)
    background:setPositionXY(visibleOrigin.x, visibleOrigin.y - _G.__EDGE_INSETS.bottom)
    self:addChild(background)

    local ui = self.builder:buildGroup("ActivityCenterPanel")
    ui:setPositionXY(visibleOrigin.x, visibleOrigin.y + visibleSize.height)
    self:addChild(ui)

    local topUi = ui:getChildByName("topUi")

    self.topUi = topUi

    self.closeBtn = topUi:getChildByName('close')
	self.closeBtn:setTouchEnabled(true, 0, false)
	self.closeBtn:setButtonMode(true)
	self.closeBtn:addEventListener(DisplayEvents.kTouchTap, 
	                               function (event) 
	                               		self:onKeyBackClicked()
	                               end)

    local viewBg = topUi:getChildByName("viewBg")
    local size = viewBg:getPreferredSize()
    local bottomHeight = 20
    local topHeight = 240

    local title = topUi:getChildByName("title")
    title:setText("精彩活动")
    local titleSize = title:getContentSize()
    local titleScale = 70 / titleSize.height
    title:setScale(titleScale)

    local vbw = size.width
    local vbh = visibleSize.height - bottomHeight - topHeight
    local vbp = viewBg:getPosition()

    viewBg:setPreferredSize(CCSizeMake(vbw, vbh))

    --view layer clipping
    local iw = 20
    local vbc = SimpleClippingNode:create()
    vbc:setContentSize(CCSizeMake(vbw-2*iw, vbh-2*iw))
    vbc:setRecalcPosition(true)
    vbc:setAnchorPoint(ccp(0, 1))
    vbc:ignoreAnchorPointForPosition(false)
    vbc:setPosition(ccp(vbp.x+iw, vbp.y-iw))

    self.pw = vbw-2*iw
    self.ph = vbh-2*iw

    --view panel layer
    local vl = LayerColor:createWithColor(ccc3(255, 0, 0), vbw, vbh)
    vl:ignoreAnchorPointForPosition(false)
    vl:setOpacity(0)
    vl.ox = 0

    self.vl = vl

    --panel touch event
    local tl = LayerColor:createWithColor(ccc3(255, 0, 0), vbw, vbh)
    tl:ignoreAnchorPointForPosition(false)
    tl:setOpacity(0)
    tl:setAnchorPoint(ccp(0, 1))
    tl:setPosition(ccp(vbp.x, vbp.y))
    topUi:addChild(tl)

    vbc:addChild(vl)
    topUi:addChild(vbc)

    tl:setTouchEnabled(true)

    local function isRunning()
    	local m = vl.refCocosObj:getActionManager()
    	return m:numberOfRunningActionsInTarget(vl.refCocosObj) > 0
    end

    tl:ad(DisplayEvents.kTouchBegin, function ( event )
    	vl.px = nil
    	vl.bx = event.globalPosition.x
    	vl.isMove = false
    end)
    tl:ad(DisplayEvents.kTouchMove, function ( event )
    	if isRunning() then return end
    	local gp = event.globalPosition
    	if math.abs(gp.x - vl.bx) < 20 then return end

    	local dx = gp.x - (vl.px or gp.x)

    	local tx = vl:getPositionX() + dx

    	vl:setPositionX(tx)

    	vl.px = gp.x
    	vl.isMove = true
    end)
    tl:ad(DisplayEvents.kTouchEnd, function ( event )
    	if isRunning() or not vl.isMove then return end
    	local dt = event.globalPosition.x - vl.bx

    	if math.abs(dt) > 20 then
    		local curIndex = self.curItem:getIdx()
    		local nxtIndex = dt > 0 and (curIndex - 1) or (curIndex + 1)
    		if not (nxtIndex < 1 or nxtIndex > #self.items) then
    			self:onTouchItem(nxtIndex)

	    		local ox = (dt > 0) and -1 or 1
	    		vl:setPositionX(500 * ox)
    		end
    	end
    	
    	vl:runAction(CCMoveTo:create(0.2, ccp(vl.ox, vl:getPositionY())))
    end)

    local itemsPh = topUi:getChildByName("itemsPh")
    itemsPh:setVisible(false)

    local itemsSize = itemsPh:getGroupBounds().size
    local pos = itemsPh:getPosition()

    local clipping = SimpleClippingNode:create()
    clipping:setContentSize(CCSizeMake(itemsSize.width+13, itemsSize.height + 20))
    clipping:setRecalcPosition(true)
    clipping:setAnchorPoint(ccp(0, 1))
    clipping:ignoreAnchorPointForPosition(false)
    clipping:setPosition(ccp(pos.x, pos.y + 10))

    local itemsLayer = Layer:create()

    topUi:addChild(clipping)
    clipping:addChild(itemsLayer)

    self.itemsLayer = itemsLayer
    self.itemW = 132
    self.itemWA = (itemsSize.width - 4 * self.itemW) / 3 + self.itemW + 2
    self.items = {}
    self.touchCount = 0

    local function moveItemLayer( tc )
  		local m = itemsLayer.refCocosObj:getActionManager()
  		if m:numberOfRunningActionsInTarget(itemsLayer.refCocosObj) <= 0 then
	    	itemsLayer:stopAllActions()
			itemsLayer:setPositionX(-self.itemWA * self.touchCount)

			local maxCount = #self.items - 4
			if self.touchCount + tc > maxCount then
				tc = maxCount - self.touchCount
			end

			itemsLayer:runAction(CCMoveBy:create(0.2, ccp(-self.itemWA*tc, 0)))
			self.touchCount = self.touchCount + tc
		end
    end

    local www = itemsSize.width + 13
    local hhh = itemsSize.height + 20

    local function hitTestFunc(wp)
    	local np = clipping:convertToNodeSpace(ccp(wp.x, wp.y))
    	return np.x <= www and np.x >= 0 and np.y >= 10 and np.y <= hhh
    end

    itemsLayer:setTouchEnabled(true, -1, nil, hitTestFunc)
    itemsLayer:ad(DisplayEvents.kTouchBegin, function ( event )
    	itemsLayer.px = nil
    	itemsLayer.bx = itemsLayer:getPositionX()
    	itemsLayer.isMove = false
    	itemsLayer.gpx = event.globalPosition.x
    end)
    itemsLayer:ad(DisplayEvents.kTouchMove, function ( event )
    	if #self.items <= 4 then return end

    	local gp = event.globalPosition
    	local dx = gp.x - (itemsLayer.px or gp.x)
    	if math.abs(gp.x - itemsLayer.gpx) < 30 then return end

    	local tx = itemsLayer:getPositionX() + dx

    	itemsLayer:setPositionX(tx)

    	itemsLayer.px = gp.x
    	itemsLayer.isMove = true
    end)
    itemsLayer:ad(DisplayEvents.kTouchEnd, function ( event )
    	if #self.items <= 4 or not itemsLayer.isMove then return end
    	local x = itemsLayer:getPositionX()

    	local tox = 0
    	local otc = self.touchCount

    	if x > 0 and x - itemsLayer.bx > 0 then
    		tox = 0
    		self.touchCount = 0
    	elseif x < 0 and  x - itemsLayer.bx < -self.itemWA*(#self.items-4) then
    		tox = -self.itemWA*(#self.items-4)
    		self.touchCount = #self.items - 4
    	else
    		local dt = math.abs(x)
    		local index = 0
    		for i=1,#self.items-4 do
    			local tdt = math.abs(i * (-self.itemWA) - x)
    			if tdt < dt then dt = tdt index = i end
    		end
    		tox = -self.itemWA*index
    		self.touchCount = index
    	end

    	if x ~= tox then
    		if math.abs(x-tox) < 0.2 then
    			itemsLayer:setPositionX(tox)
    		else
		    	itemsLayer:runAction(CCMoveTo:create(0.2, ccp(tox, itemsLayer:getPositionY())))
	    	end
	    end

    	self:updateArrow()
    end)

    self.moveItemLayer = moveItemLayer

    self.rightArrow = topUi:getChildByName("rightArrow")
    self.rightArrow:setTouchEnabled(true, 0, true)
	self.rightArrow:addEventListener(DisplayEvents.kTouchTap,function(event)
		moveItemLayer(1)
		self:updateArrow()
	end)

	self.leftArrow = topUi:getChildByName("leftArrow")
    self.leftArrow:setTouchEnabled(true, 0, true)
	self.leftArrow:addEventListener(DisplayEvents.kTouchTap,function(event)
		moveItemLayer(-1)
		self:updateArrow()
	end)

    self:refreshItem()

    local idx = 1

    if self.defaultData then
    	local item = self:getItemById(self.defaultData.id)
	    if item then
	    	idx = item:getIdx()
	    end
	end

	self:onTouchItem(idx)
end

function ActivityCenterScene:isNetworkEnabled( ... )
	if __IOS then
		return ReachabilityUtil.getInstance():isNetworkAvailable()
	elseif __ANDROID then
		local help = luajava.bindClass("com.happyelements.android.ApplicationHelper")
		return help:isDataAvailable()
	end
	return false
end

function ActivityCenterScene:leftArrowClick(count)
	if self.leftArrow:isVisible() then
		count = count or 1
		self.moveItemLayer(-1 * count)
		self:updateArrow()
	end
end

function ActivityCenterScene:rightArrowClick(count)
	if self.rightArrow:isVisible() then
		count = count or 1
		self.moveItemLayer(1 * count)
		self:updateArrow()
	end
end

function ActivityCenterScene:updateArrow()
	if self.isDisposed then return end

	local rightEnabled = #self.items > 4 and self.touchCount < #self.items - 4
	local leftEnabled = #self.items > 4 and self.touchCount > 0

	self.rightArrow:setVisible(rightEnabled)
	self.leftArrow:setVisible(leftEnabled)

	local v = #self.items > 4

	self.topUi:getChildByName("rightArrowNo"):setVisible(not rightEnabled and v)
	self.topUi:getChildByName("leftArrowNo"):setVisible(not leftEnabled and v)
end

function ActivityCenterScene:buildItem(itemData)
	local item = self.builder:buildGroup("ActivityCenter/item")
	item.data = itemData
	item.id = itemData.id

	local size = item:getGroupBounds().size
	item:setContentSize(size)
	item:ignoreAnchorPointForPosition(false)
	item:setPositionY(9.5)
	item:setAnchorPoint(ccp(0, -1))

	item.getIdx = function ( ... )
		for idx,im in ipairs(self.items) do
			if im.id == item.id then
				return idx
			end
		end
	end

	item:setTouchEnabled(true)
	item:addEventListener(DisplayEvents.kTouchTap,function(event)
		local idx = item:getIdx()
		local c = idx - self.touchCount
		if c >= 1 and c <= 4 then
			self:onTouchItem(idx)
		end
	end)

	local function CreateIcon( isUp )
		local ph = item:getChildByName(isUp and "sph" or "nph")
		ph:setVisible(false)

		local sph_size = ph:getGroupBounds().size
		local sph_pos = ph:getPosition()

		local simg = Sprite:create(string.format("%s_%s_img.png",itemData.ciconPerfix, isUp and "selected" or "normal"))
		simg:setAnchorPoint(ccp(0.5, 1))
		simg:setPositionXY(sph_size.width/2, sph_pos.y-5)
		item:addChild(simg)

		local stxt = Sprite:create(string.format("%s_%s_txt.png",itemData.ciconPerfix, isUp and "selected" or "normal"))
		stxt:setAnchorPoint(ccp(0.5, 0))
		stxt:setPositionXY(sph_size.width/2, sph_pos.y - sph_size.height-5)
		item:addChild(stxt)
		return simg,stxt
	end

	item.simg, item.stxt = CreateIcon(true)
	item.nimg, item.ntxt = CreateIcon(false)

	item.setSelected = function (im, selected )
		if type(im) == "boolean" then selected = im end
		item:getChildByName("normal"):setVisible(not selected)
		item:getChildByName("selected"):setVisible(selected)
		
		local hasAward = ActivityCenter:hasRewardMark(item.data)
		local msgNum = ActivityCenter:getMsgNum(item.data)

		item:getChildByName("rewardIcon"):setVisible(not selected and hasAward)

		local showNum = not selected and not hasAward and msgNum > 0

		local showNew = not selected and not hasAward and not showNum and ActivityCenter:isNewFeature(item.data)

		item:getChildByName("new"):setVisible(showNew)

		item.num:setVisible(showNum)
		if showNum then
			item.num:setNum(msgNum)
		end

		item.isSelected = selected

		item.simg:setVisible(selected)
		item.stxt:setVisible(selected)

		item.nimg:setVisible(not selected)
		item.ntxt:setVisible(not selected)

		if selected == false then
			item.data.isSynced = false
		end
	end

	item.num = getRedNumTip()
	item.num:setNum(1)
	item.num:setPositionXY(110, -20)
	item:addChild(item.num)

	item:setSelected(false)

	return item
end

function ActivityCenterScene:getItemById( id )
	for _,item in ipairs(self.items) do
		if item.id == id then
			return item
		end
	end
end

function ActivityCenterScene:checkContainItem( itemOrData )
	local item = self:getItemById(itemOrData.id)
	if item then
		ActivityCenter:print(item.id, "insert item again!")
		return true
	end
	return false
end

function ActivityCenterScene:insertItem( item, index)
	if self:checkContainItem(item) then
		return
	end

	local pos = index or (#self.items + 1)

	table.insert(self.items, pos, item)

	for idx = pos,#self.items do
		self.items[idx]:setPositionX((idx - 1) * self.itemWA)
	end

	self.itemsLayer:addChild(item)
	
	self:updateArrow()
end

function ActivityCenterScene:onTouchItem( indexOrData )
	--[[
		indexOrData may be index, item data, activity config
		so use it carefully
	--]]
	local item = nil
	if type(indexOrData) == "number" then
		item = self.items[indexOrData]
	elseif type(indexOrData) == "table" then
		item = self:getItemById(indexOrData.id or indexOrData.cid)
	end

	if not item or self.curItem == item then
		return
	end

	local idx = item:getIdx()
	if idx - self.touchCount >= 4 then
		local count = idx - self.touchCount - 3
		self:rightArrowClick(count)
	elseif idx - self.touchCount <= 1 then
		self:leftArrowClick(math.abs(idx - self.touchCount - 2))
	end
	
	if self.curItem and self.curItem.panel then
		self.curItem.panel:removeFromParentAndCleanup(true)
		self.curItem.panel = nil
	end

	for _,im in ipairs(self.items) do
		im:setSelected(false)
	end

	item:setSelected(true)
	self.defaultData = item.data

	self.curItem = item
	self:showItem(item)
end

function ActivityCenterScene:showItem( item )
	local viewBg = self.topUi:getChildByName("viewBg")
    local size = {width = self.pw, height = self.ph}

    local data = item.data

    if not data.panelCls then
    	ActivityCenter:loadActRes(data)
    end

    data.itemSize = {width = size.width, height = size.height}

    --没配置syncFileName，表示不用联网操作
    if not data.syncFileName then
    	data.isSynced = true
    end

    local progress = nil

    if data.type == ActivityCenterType.kAct and ActivityUtil:needUpdate(data.actInfo.source) then
    	ActivityCenter:loadActRes(data)
    	progress = 0
    elseif data.panelCls and not data.isSynced then
    	if data.sync then data.sync() end
    	if item.panel then return end
    	progress = 99
    elseif data.panelCls and data.isSynced then
    	if item.panel then
			item.panel:removeFromParentAndCleanup(true)
			item.panel = nil
		end
    end

    local panelCls = data.panelCls or (require "zoo.ActivityCenter.ActivityCenterItemLoadingPanel")

    if progress then
    	panelCls = (require "zoo.ActivityCenter.ActivityCenterItemLoadingPanel")
    end

    if panelCls == data.panelCls then
    	data.isSynced = false
    end

    data.curScene = self
    local ui = panelCls:create(data)

    if ui then
    	local ph = ui:getChildByName("ph")
    	ph:setVisible(false)

    	local align = ui.align or ActCenterItemAlign.kCenter

    	local phSize = ph:getGroupBounds().size

    	local uisize = ui:getGroupBounds().size

    	local rh = size.height / uisize.height
    	local rw = size.width / uisize.width
    	local scale = 1

    	if rh < 1.0 or rw < 1.0 then
    		scale = (rh < rw and rh or rw) - 0.05
    		ui:setScale(scale)
    	end

    	local x = (size.width - phSize.width * scale) / 2
    	local y = (size.height + phSize.height * scale) / 2

    	if align == ActCenterItemAlign.kTop then
    		y = size.height
    	end

    	ui:setPositionXY(x, y)

    	self.vl:addChild(ui)
    	item.panel = ui

    	if progress and ui.setProgress then
    		ui:setProgress(progress)
    	end
    else
    	ActivityCenter:print("create panel failed:", data.id)
    end
end

--更新标签面板
function ActivityCenterScene:refreshPanel(data)
	local item = self:getItemById(data.id)
	if item and item == self.curItem then
		self:showItem(item)
	end
end

--更新标签页icon
function ActivityCenterScene:refreshItem()
	local datas = ActivityCenter:getVisibleDatas()

	--create item with VisibleDatas
	for _,data in pairs(datas) do
		if not self:checkContainItem(data) then
			local item = self:buildItem(data)
			local idx = self:getPriority(data)

			self:insertItem(item, idx)
		end
	end

	--remove item with VisibleDatas
	local removeT = {}

	for idx,item in ipairs(self.items) do
		local isRemove = true
		for _,data in pairs(datas) do
			if data.id == item.id then
				isRemove = false
			end
		end

		if isRemove then
			table.insert(removeT, item)
		end
	end

	for _,item in ipairs(removeT) do
		local idx = item:getIdx()
		local len = #self.items
		
		for i=idx,len-1 do
			self.items[i] = self.items[i+1]
		end

		self.items[len] = nil
		if item.panel then
			item.panel:removeFromParentAndCleanup(true)
			item.panel = nil
		end
		item:removeFromParentAndCleanup(true)

		if len <= 1 then
			ActivityCenter:removeCenterBtn()
			self:onKeyBackClicked()
		else
			for i = idx,#self.items do
				self.items[i]:setPositionX((i - 1) * self.itemWA)
			end

			if self.curItem == item then
				self:onTouchItem(idx > 1 and (idx - 1) or 2)
			end
		end
	end

	self:updateArrow()
end

function ActivityCenterScene:refreshItemStatus( data )
	local item = self:getItemById(data.id)
	if item then
		local hasAward = ActivityCenter:hasRewardMark(item.data)
		local msgNum = ActivityCenter:getMsgNum(item.data)

		local selected = item == self.curItem

		local showNum = not selected and not hasAward and msgNum > 0

		item:getChildByName("rewardIcon"):setVisible(not selected and hasAward)
		
		item.num:setVisible(showNum)
		if showNum then
			item.num:setNum(msgNum)
		end
	end
end

function ActivityCenterScene:onDownloadResProcess( data, info )
	local item = self:getItemById(data.id)
	if item and item == self.curItem then
		if item.panel and item.panel.setProgress then
			item.panel:setProgress(info.curSize / info.totalSize)
		end
	end
end

function ActivityCenterScene:getPriority( data )
	local cp = ActivityCenter:getPriority(data)
	for idx,item in ipairs(self.items) do
		local tp = ActivityCenter:getPriority(item.data)
		if cp < tp then
			return idx
		end
	end

	return nil
end

function ActivityCenterScene:onEnter(activitys)
	BroadcastManager:getInstance():onEnterScene(self)
end

function ActivityCenterScene:onKeyBackClicked()
	ActivityCenter:exitActivityCenter()
end

function ActivityCenterScene:onEnterForeGround()
	self:dp(Event.new(SceneEvents.kEnterForeground, nil, self));
end
