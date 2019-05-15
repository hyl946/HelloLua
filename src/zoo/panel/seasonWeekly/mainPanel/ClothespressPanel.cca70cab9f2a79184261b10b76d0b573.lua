local builderCache = {}

local jsonCache = {}

local function loadJson( jsonPathname )
	-- body
	if not jsonCache[jsonPathname] then
		builderCache[jsonPathname] = InterfaceBuilder:createWithContentsOfFile(jsonPathname)
		jsonCache[jsonPathname] = 0
	end

	jsonCache[jsonPathname] = jsonCache[jsonPathname] + 1
end

local function unloadJson( jsonPathname )
	if not jsonCache[jsonPathname] then 
		return 
	end

	jsonCache[jsonPathname] = jsonCache[jsonPathname] - 1

	if jsonCache[jsonPathname] <= 0 then
		InterfaceBuilder:unloadAsset(jsonPathname)
		jsonCache[jsonPathname] = nil
		builderCache[jsonPathname] = nil
	end

end


local function createMask(opacity, touchDelay, position, radius, square, width, height, oval, skipClick, onClick)
	touchDelay = touchDelay or 0
	local wSize = CCDirector:sharedDirector():getWinSize()
	local mask = LayerColor:create()
	mask:changeWidthAndHeight(wSize.width, wSize.height)
	mask:setColor(ccc3(0, 0, 0))
	mask:setOpacity(opacity)
	mask:setPosition(ccp(0, 0))


	local playFocusEffect = true
	-- 判断mask是否有挖洞
	-- 如果没有挖洞就不需要focus动画效果
	if (square or oval) and (not width or not height or width <= 0 or height<= 0) then
		playFocusEffect = false
	elseif (not square and not oval) and radius <= 0 then
		playFocusEffect = false
	end


	local node
	if square then
		node = LayerColor:create()
		width = width or 50
		height = height or 40
		node:changeWidthAndHeight(width, height)
	elseif oval then
		node = Sprite:createWithSpriteFrameName("circle0000")
		width, height = width or 1, height or 1
		node:setScaleX(width)
		node:setScaleY(height)
	else
		node = Sprite:createWithSpriteFrameName("circle0000")
		radius = radius or 1
		node:setScale(radius)
	end
	node:setPosition(ccp(position.x, position.y))
	local blend = ccBlendFunc()
	blend.src = GL_ZERO
	blend.dst = GL_ONE_MINUS_SRC_ALPHA
	node:setBlendFunc(blend)
	mask:addChild(node)

	local layer = CCRenderTexture:create(wSize.width, wSize.height)
	layer:setPosition(ccp(wSize.width / 2, wSize.height / 2))
	layer:begin()
	mask:visit()
	layer:endToLua()
	if __WP8 then layer:saveToCache() end

	mask:dispose()

	local layerSprite = layer:getSprite()
	local obj = CocosObject.new(layer)
	local trueMaskLayer = Layer:create()
	trueMaskLayer:addChild(obj)
	trueMaskLayer:setTouchEnabled(true, 0, true)
	local function onTouch() 
		if onClick then
			onClick()
		end
	end
	local function beginSetTouch() trueMaskLayer:ad(DisplayEvents.kTouchBegin, onTouch) end
	local arr = CCArray:create()
	if not skipClick then
		trueMaskLayer:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(touchDelay), CCCallFunc:create(beginSetTouch)))
	end
	trueMaskLayer.setFadeIn = function(maskDelay, maskFade)

		if playFocusEffect then

			local anchor = layerSprite:getAnchorPoint()
			local anchorPos = ccp(anchor.x*layerSprite:getContentSize().width, anchor.y*layerSprite:getContentSize().height)

			local scaleTime = 0.3
			local oScaleX, oScaleY = layerSprite:getScaleX(), layerSprite:getScaleY()
			layerSprite:setScaleX(oScaleX*10)
			layerSprite:setScaleY(oScaleY*10)

			-- 保持在当前anchor下缩放，目标坐标保持静止的补偿向量
			local function getCompensateDir(oScaleX, oScaleY, dScaleX, dScaleY, d_to_a)
				return ccp(d_to_a.x*(oScaleX-dScaleX), d_to_a.y*(oScaleY-dScaleY))
			end

			local function getCompensateMove(time, oScaleX, oScaleY, dScaleX, dScaleY, d_to_a)
				local dir = getCompensateDir(oScaleX, oScaleY, dScaleX, dScaleY, d_to_a)
				return CCMoveBy:create(time, dir)
			end

			-------------------------------------------------------
			---- 计算补偿位移需要的向量
			local d_to_o = ccp(position.x, position.y)
			local a_to_o = anchorPos
			local d_to_a = ccp(d_to_o.x - a_to_o.x, d_to_o.y - a_to_o.y)
			local action = getCompensateMove(scaleTime, layerSprite:getScaleX(), layerSprite:getScaleY(), oScaleX, oScaleY, d_to_a)
			-- if _G.isLocalDevelopMode then printx(0, d_to_o.x, d_to_o.y, d_to_a.x, d_to_a.y, layerSprite:getScaleX(), layerSprite:getScaleY(), oScaleX, oScaleY) debug.debug() end
			local compensateDir = getCompensateDir(layerSprite:getScaleX(), layerSprite:getScaleY(), oScaleX, oScaleY, d_to_a)
			-------------------------------------------------------

			-- anchor不变的情况下，将缩放中心放到目标位置
			layerSprite:setPositionX(layerSprite:getPositionX()-compensateDir.x)
			layerSprite:setPositionY(layerSprite:getPositionY()-compensateDir.y)

			local focusAction = CCSpawn:createWithTwoActions(CCScaleTo:create(scaleTime, oScaleX, oScaleY), action)
			local focusFadeIn = CCSpawn:createWithTwoActions(CCFadeIn:create(maskFade), focusAction)

			layerSprite:setOpacity(0)
			layerSprite:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(maskDelay), focusFadeIn))
		else
			layerSprite:setOpacity(0)
			layerSprite:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(maskDelay), CCFadeIn:create(maskFade)))
		end

	end	
	trueMaskLayer.layerSprite = layerSprite
	return trueMaskLayer
end



local NpcTigger = require 'zoo.panel.seasonWeekly.mainPanel.NpcTigger'








local TAB_NUM = 4
local PAGE_NUM = NpcTigger:getSkinsNum()

local TabCtrl = class()

function TabCtrl:setTabSwitchCallback( callback )
	-- body
	self.callback = callback
end

function TabCtrl:ctor( tabUpUI, tabDownUI )
	self.tabUpUI = tabUpUI
	self.tabDownUI = tabDownUI

	local names = {
		'帽子',
		'围巾',
		'手套', 
		'特殊', 
	}

	self.tabs = {}

	for _, tabUI in ipairs({self.tabUpUI, self.tabDownUI}) do

		for i = 1, TAB_NUM do
			local tab = tabUI:getChildByName('tab_' .. i)
			local select_text = tab:getChildByName('select_text')
			local normal_text = tab:getChildByName('normal_text')
			select_text:changeFntFile('fnt/2017winterweek.fnt')
			normal_text:changeFntFile('fnt/2017winterweek1.fnt')

			select_text:setAnchorPoint(ccp(0.5, 1))
			normal_text:setAnchorPoint(ccp(0.5, 1))

			select_text:setPositionX(-80)
			normal_text:setPositionX(-80)

			select_text:setText(names[i])
			normal_text:setText(names[i])

			self.tabs[i] = self.tabs[i] or {}
			table.insert(self.tabs[i], tab)

			tab:setTouchEnabled(true)
			tab:ad(DisplayEvents.kTouchTap, function ( ... )
				self:turnTo(i)
			end)

		end

	end

	self.curTabIndex = nil
end

function TabCtrl:setPages( pages )
	self.pages = pages
end

function TabCtrl:getTabIndex( ... )
	return self.curTabIndex
end

function TabCtrl:turnTo( index , noRefeshPage)

	if self.tabUpUI.isDisposed then return end
	if self.tabDownUI.isDisposed then return end

	if self.curTabIndex ~= index  then
		self.curTabIndex = index

		local counter = 0

		for i = 1, self.curTabIndex - 1 do
			counter = counter + table.size(NpcTigger.SkinMeta[i] or {})
		end

		if not noRefeshPage then
			self.pages:gotoPage(counter + 1)

			if self.callback then
				self.callback()
			end
		end

		self:refeshTab()
	end
end

function TabCtrl:refeshTab( ... )

	if self.tabUpUI.isDisposed then return end
	if self.tabDownUI.isDisposed then return end
	
	-- body
	for i = 1, TAB_NUM do
		for k = 1, 2 do
			self.tabs[i][k]:getChildByName('select'):setVisible(i == self.curTabIndex)
			self.tabs[i][k]:getChildByName('select_text'):setVisible(i == self.curTabIndex)
			self.tabs[i][k]:getChildByName('normal_text'):setVisible(i ~= self.curTabIndex)
			self.tabs[i][k]:getChildByName('normal'):setVisible(i ~= self.curTabIndex)
		end

		self.tabs[i][1]:setVisible(self.curTabIndex == i)
		self.tabs[i][2]:setVisible(self.curTabIndex ~= i)
	end
end






local ClothespressPanel = class(BasePanel)

function ClothespressPanel:create()
    local panel = ClothespressPanel.new()
    panel:loadRequiredResource("ui/clothespress.json")

    loadJson('ui/puzzle_res.json')

    panel:init()
    return panel
end

function ClothespressPanel:dispose( ... )
	BasePanel.dispose(self, ...)
	unloadJson('ui/puzzle_res.json')

	SeasonWeeklyRaceManager:getInstance():getEventDispatcher():removeEventListener(
		SummerWeeklyMatchEvents.kPiecesNumChange, 
		self.onPiecesNumChanged
	)

end

function ClothespressPanel:init()

	self.handAnimEnabled = true

	self.piecesUISp = {}


    local ui = self:buildInterfaceGroup("clothespress/panel")

    UIUtils:adjustUI(ui, 0)

	BasePanel.init(self, ui)


	

	local vs = Director:sharedDirector():getVisibleSize()
	local screenHeight = vs.height / (vs.width / 720)
	local extraHeight = math.max(screenHeight - 1280, 0)

	local centerContentAdjustY = extraHeight/2
	local bottomContentAdjustY = extraHeight

	local bottomContentNodeNames = {
		'tip',
		'showoffBtn',
		'tiggerPos',
		'bg'
	}

	local centerContentNodeNames = {
		'pieceNum',
		'bg4',
		'skinBtn',
		'right',
		'left',
		'tab_up',
		'tab_down',
		'bg3',
		'content'
	}

	for _, nodeName in pairs(bottomContentNodeNames) do
		local node = self.ui:getChildByName(nodeName)
		node:setPositionY(node:getPositionY() - bottomContentAdjustY - _G.__EDGE_INSETS.bottom)
	end

	for _, nodeName in pairs(centerContentNodeNames) do
		local node = self.ui:getChildByName(nodeName)
		node:setPositionY(node:getPositionY() - centerContentAdjustY)
	end


    self.closeBtn = self.ui:getChildByName('closeBtn')
    self.closeBtn:setTouchEnabled(true, 0, true)
    self.closeBtn:ad(DisplayEvents.kTouchTap, function () self:onCloseBtnTapped() end)

    local label = self.ui:getChildByName('label')
    label:setString(localize('clothespress.label'))


    if not PlatformConfig:isPlatform(PlatformNameEnum.kOppo) then
    	self.showoffBtn = 	GroupButtonBase:create(self.ui:getChildByName('showoffBtn'))
	    self.showoffBtn:setString('炫耀一下')
	    self.showoffBtn:ad(DisplayEvents.kTouchTap, function (  )
	    	self:showOff()
	    end)
    else
    	self.ui:getChildByName('showoffBtn'):setVisible(false)
    end


    self.skinBtn = GroupButtonBase:create(self.ui:getChildByName('skinBtn'))
    self.skinBtn:setString('换上装饰')
    self.skinBtn:ad(DisplayEvents.kTouchTap, function ( ... )
    	self:onSkinBtn()
    end)


    local tiggerPos = self.ui:getChildByName('tiggerPos')
    tiggerPos:setVisible(false)
    local pos = tiggerPos:getPosition()
    local tiggerIndex = self.ui:getChildIndex(tiggerPos)


    self.npcTigger = NpcTigger:create()
	self.ui:addChildAt(self.npcTigger, tiggerIndex)
	self.npcTigger:setPosition(ccp(pos.x, pos.y))
	self.npcTigger:playIdle()
	self.npcTigger:setScale(1.2)
	self.npcTigger:refreshSkin()

	self.contentHolder = self.ui:getChildByName('content')
	self.contentHolder:setVisible(false)

	local tip = self.ui:getChildByName('tip')
	-- tip:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(
		-- CCRotateBy:create(0.1, 0.3),CCRotateBy:create(0.1, -0.3)
	-- )))


	self.pageBtnsGrp = {}
	self.page = self:createPages()


	self.tab_up = self.ui:getChildByName('tab_up')
	self.tab_down = self.ui:getChildByName('tab_down')

	self.tabCtrl = TabCtrl.new(self.tab_up, self.tab_down)
	self.tabCtrl:setPages(self.page)
	self.tabCtrl:turnTo(1)
	self.tabCtrl:setTabSwitchCallback(function ( ... )
		self:onTabSwitched()
	end)


	self.pieceNum = self.ui:getChildByName('pieceNum')
	self.pieceNum:changeFntFile('fnt/real_name.fnt')
	self.pieceNum:setScale(1.3)
	self.pieceNum:setPositionY(self.pieceNum:getPositionY() + 3)
	self.pieceNum:setPositionX(self.pieceNum:getPositionX() - 3)

	self:refreshPieceNum()


	self.leftBtn = self.ui:getChildByName('left')
	self.rightBtn = self.ui:getChildByName('right')

	self.leftBtn:removeFromParentAndCleanup(false)
	self.rightBtn:removeFromParentAndCleanup(false)

	self.ui:addChild(self.leftBtn)
	self.ui:addChild(self.rightBtn)

	self.leftBtn:setTouchEnabled(true)
	self.rightBtn:setTouchEnabled(true)

	self.leftBtn:ad(DisplayEvents.kTouchTap, function ( ... )
		self:onClkLeft()
	end)

	self.rightBtn:ad(DisplayEvents.kTouchTap, function ( ... )
		self:onClkRight()
	end)


	local puzzleEffect = gAnimatedObject:createWithFilename("gaf/weekly_2017s4/puzzle.gaf")
	self.ui:addChild(puzzleEffect)
	puzzleEffect:setPosition(ccp(75+120, -205 - centerContentAdjustY))
	self.puzzleEffect = puzzleEffect


	local changeSkinEffect = gAnimatedObject:createWithFilename("gaf/weekly_2017s4/change.gaf")
	self.ui:addChild(changeSkinEffect)
	changeSkinEffect:setPosition(ccp(pos.x - 150, pos.y + 100))
	self.changeSkinEffect = changeSkinEffect

	self.onPiecesNumChanged = function ( ... )
		self:refreshPieceNum()
	end

	SeasonWeeklyRaceManager:getInstance():getEventDispatcher():ad(
		SummerWeeklyMatchEvents.kPiecesNumChange, 
		self.onPiecesNumChanged
	)

	self.descBtn = self.ui:getChildByName('desc')
	self.descBtn:setTouchEnabled(true)
	self.descBtn:ad(DisplayEvents.kTouchTap, function ( ... )
		self:onTapDescBtn()
	end)

	self.handAnim = ArmatureNode:create("2017SummerWeekly/hand/anim")
	self.ui:addChild(self.handAnim)

	self:onTabSwitched()

	-- ____AAAA = function ( ... )
	-- 	self:playPuzzleEffect()
	-- end

	-- ____BBBB = function ( ... )
	-- 	self:playChangeSkinEffect()
	-- end
	
end

function ClothespressPanel:playPuzzleEffect( ... )
	if self.isDisposed then return end
	-- body
	-- self.puzzleEffect:setVisible(false)
	self.puzzleEffect:start()
end

function ClothespressPanel:playChangeSkinEffect( ... )
	if self.isDisposed then return end
	-- body
	-- self.puzzleEffect:setVisible(false)
	self.changeSkinEffect:stop()
	self.changeSkinEffect:start()
end

function ClothespressPanel:refreshPieceNum( ... )
	if self.isDisposed then return end
	self.pieceNum:setText('x' .. tostring(SeasonWeeklyRaceManager:getInstance():getPieceNum()))
end

function ClothespressPanel:createPages( ... )
	if self.isDisposed then return end

	self.pageIndex2PieceSize = {}

	local size = self.contentHolder:getContentSize()
	size = CCSizeMake(size.width, size.height)
	local scaleX = self.contentHolder:getScaleX()
	local scaleY = self.contentHolder:getScaleY()
	size.width = size.width * scaleX
	size.height = size.height * scaleY

	local pos = self.contentHolder:getPosition()
	pos = ccp(pos.x, pos.y)


	local pagedView = PagedView:create(size.width, size.height, PAGE_NUM, nil, true, true)
    pagedView:setIgnoreVerticalMove(false) 
    pagedView:setPosition(ccp(pos.x+5, pos.y - size.height - 15.5))

    local function switchCallback() end
    local function switchFinishCallback() 
    	self:onPageSwitched()
    end

    pagedView:setSwitchPageCallback(switchCallback)
    pagedView:setSwitchPageFinishCallback(switchFinishCallback)

    self.ui:addChild(pagedView)

    local page_index = 1

	for skinType = 1, TAB_NUM do
		for group, pieceSize in ipairs(NpcTigger.SkinMeta[skinType]) do
	    	pagedView:addPageAt(self:createPictures(skinType, group), page_index)
	    	self.pageIndex2PieceSize[page_index] = pieceSize
	    	page_index = page_index + 1
		end
	end


	for index = 1, TAB_NUM do 

		local pageBtns = {}
		local items = {}

		for i = 1, 2 do -- 每页两个 以后如果每页不一样，这需要大大的改 
			local btn = self:createPageBtn(i)
			table.insert(pageBtns, btn)
			pagedView:addChild(btn)
			table.insert(items, {node = btn, margin = {left = 4, right = 4}})
		end

		local layoutUtils = require 'zoo.panel.happyCoinShop.utils'
		layoutUtils.horizontalLayoutItems(items)
		layoutUtils.setNodesRightBottomPos(pageBtns, ccp(size.width - 15, 30), pagedView)

		self.pageBtnsGrp[index] = pageBtns

	end

    return pagedView
end

-- function ClothespressPanel:createTabPage( index )
-- 	if self.isDisposed then return end

-- 	local size = self.contentHolder:getContentSize()
-- 	size = CCSizeMake(size.width, size.height)
-- 	local scaleX = self.contentHolder:getScaleX()
-- 	local scaleY = self.contentHolder:getScaleY()
-- 	size.width = size.width * scaleX
-- 	size.height = size.height * scaleY

-- 	local pos = self.contentHolder:getPosition()
-- 	pos = ccp(pos.x, pos.y)


-- 	local pagedView = PagedView:create(size.width, size.height, PAGE_NUM, nil, true, true)
--     pagedView:setIgnoreVerticalMove(false) 
--     pagedView:setPosition(ccp(pos.x+1.5, pos.y - size.height - 15.5))

--     local function switchCallback() end
--     local function switchFinishCallback() 
--     	self:onPageSwitched()
--     end

--     pagedView:setSwitchPageCallback(switchCallback)
--     pagedView:setSwitchPageFinishCallback(switchFinishCallback)

--     self.ui:addChild(pagedView)

--     local index2SkinType = {
--     	[1] = 1,
--     	[2] = 2,
--     	[3] = 3,
--     	[4] = 4,
-- 	}

-- 	for i = 1, PAGE_NUM do

-- 	    pagedView:addPageAt(self:createPictures(index2SkinType[index], i), i)

-- 	end

-- 	local pageBtns = {}
-- 	local items = {}

-- 	for i = 1, PAGE_NUM do
-- 		local btn = self:createPageBtn(i)
-- 		table.insert(pageBtns, btn)
-- 		pagedView:addChild(btn)

-- 		table.insert(items, {node = btn, margin = {left = 4, right = 4}})
-- 	end


-- 	local layoutUtils = require 'zoo.panel.happyCoinShop.utils'
-- 	layoutUtils.horizontalLayoutItems(items)
-- 	layoutUtils.setNodesRightBottomPos(pageBtns, ccp(size.width - 15, 30), pagedView)


-- 	self.pageBtnsGrp[index] = pageBtns


--     return pagedView



-- end

function ClothespressPanel:onPageSwitched( ... )
	if self.isDisposed then return end
	-- body


	local pageIndex = self.page:getPageIndex()

	local tabIndex = math.floor((pageIndex - 1)/2) + 1
	self.tabCtrl:turnTo(tabIndex, true)
	

	self.leftBtn:setVisible(pageIndex > 1)

	self.rightBtn:setVisible(pageIndex < PAGE_NUM)

	for tabI = 1, TAB_NUM do
		for i, pageBtn in ipairs(self.pageBtnsGrp[tabI] or {}) do
			pageBtn:select(i == (pageIndex - 1) % 2 + 1)
			pageBtn:setVisible(tabI == tabIndex)
			pageBtn:setVisible(false)
		end
	end

	self:refreshBtns()

	-- local pieceSize = self.pageIndex2PieceSize[pageIndex]

	-- self.ui:getChildByName('pieceBG4'):setVisible(pieceSize == 4)
	-- self.ui:getChildByName('pieceBG9'):setVisible(pieceSize == 9)
	-- self.ui:getChildByName('pieceBG16'):setVisible(pieceSize == 16)

	self:refreshHand()

end

function ClothespressPanel:refreshHand( ... )
	-- body
	if self.isDisposed then return end
	if not self.handAnimEnabled then return end

	self.handAnim:setVisible(false)
	self.handAnim:stop()

	if SeasonWeeklyRaceManager:getInstance():getPieceNum() <= 0 then
		return
	end

	local tabIndex = self.tabCtrl:getTabIndex()
	local pageIndex = self.page:getPageIndex()
	local groupIndex = (pageIndex - 1) % 2 + 1

	local piecesUI = self.piecesUISp[tabIndex][groupIndex]

	local total = NpcTigger.SkinMeta[tabIndex][groupIndex]
	local n = math.sqrt(total)

	for i = 1, n do
		for j = 1, n do
			local posIndex = (i - 1) * n + j
			if not SeasonWeeklyRaceManager:getInstance():isSkinGroupPositionSetted(tabIndex, groupIndex, posIndex) then

				if piecesUI and piecesUI[i] and piecesUI[i][j] then
					self.handAnim:setVisible(true)
					local pic = piecesUI[i][j]
					local bounds = pic:getGroupBounds()
					local pos = ccp(bounds:getMidX(), bounds:getMidY())
					pos = self.ui:convertToNodeSpace(pos)
					self.handAnim:setPosition(pos)
					self.handAnim:playByIndex(0, 0)
					break
				end
			end
		end
	end

end

function ClothespressPanel:hideHandAnim( ... )
	if self.isDisposed then return end
	self.handAnim:setPositionX(-4000)
	self.handAnimEnabled = false
end
function ClothespressPanel:showHandAnim( ... )
	if self.isDisposed then return end
	self.handAnimEnabled = true
	self:refreshHand()
end


function ClothespressPanel:refreshBtns( ... )
	-- body
	if self.isDisposed then return end

	local tabIndex = self.tabCtrl:getTabIndex()
	local pageIndex = self.page:getPageIndex()
	local groupIndex = (pageIndex - 1) % 2 + 1

	-- self.skinBtn:setEnabled(NpcTigger:isComplete(tabIndex, groupIndex)) 

	local curSkins = SeasonWeeklyRaceManager:getInstance():getCurSkin() or {}
	if curSkins[tabIndex] and curSkins[tabIndex] == groupIndex then
		self.skinBtn:setString('脱下装饰')
	else
		self.skinBtn:setString('换上装饰')
	end

end

function ClothespressPanel:onTabSwitched( ... )
	if self.isDisposed then return end
	-- body
	self:onPageSwitched()
end

function ClothespressPanel:onClkLeft( ... )
	if self.isDisposed then return end

	local tabIndex = self.tabCtrl:getTabIndex()
	local pageIndex = self.page:getPageIndex()

	if pageIndex > 1 then
		self.page:prevPage()
	end
end

function ClothespressPanel:onClkRight( ... )
	if self.isDisposed then return end
	-- body
	local tabIndex = self.tabCtrl:getTabIndex()
	local pageIndex = self.page:getPageIndex()

	if pageIndex < PAGE_NUM then
		self.page:nextPage()
	end
end

function ClothespressPanel:createPictures( skinType, groupIndex)

	self.piecesUISp[skinType] = self.piecesUISp[skinType] or {}
	self.piecesUISp[skinType][groupIndex] = self.piecesUISp[skinType][groupIndex] or {}

	local function buildDefaultPics( ... )
		local total = NpcTigger.SkinMeta[skinType][groupIndex]
		local n = math.sqrt(total)

		local pic = Layer:create()
		pic:ignoreAnchorPointForPosition(false)

		local w = 216 * 2 / n

		local function lightOff( ctx )
			if self.isDisposed then return end
			ctx:setColor(ccc3(128, 128, 128))
		end

		local function lightOn( ctx )
			if self.isDisposed then return end
			ctx:setColor(ccc3(255, 0, 0))
		end

		for i = 1, n do

			self.piecesUISp[skinType][groupIndex][i] = {}
			for j = 1, n do


				local p = LayerColor:createWithColor(ccc3(255, 0, 0), w, w)
				p:setPositionX( i*w - w )
				p:setPositionY( w - j*w )
				p:ignoreAnchorPointForPosition(false)
				pic:addChild(p)
				p:setAnchorPoint(ccp(0, 1))

				p:setTouchEnabled(true)
				p:ad(DisplayEvents.kTouchTap, function ( ... )
					self:onPicTap(skinType, groupIndex, (i - 1)* n + j, p)
				end)

				p.lightOn = lightOn 
				p.lightOff = lightOff 

				p:lightOff()

				if SeasonWeeklyRaceManager:getInstance():isSkinGroupPositionSetted(skinType, groupIndex, (i - 1)* n + j) then
					p:lightOn()
				end

				self.piecesUISp[skinType][groupIndex][i][j] = p

			end
		end
		return pic

	end

	local res_prefix = {
		[NpcTigger.SkinType.kHat] = 'puzzle_res/hat_',
		[NpcTigger.SkinType.kScarf] = 'puzzle_res/scarf_',
		[NpcTigger.SkinType.kHand] = 'puzzle_res/hand_',
		[NpcTigger.SkinType.kDecorate] = 'puzzle_res/decorate_',
	}

	local groupName = res_prefix[skinType] .. groupIndex .. '/res'


	local bgAdjust = {
		[4] = {x = 1, y = 0},
		[9] = {x = 0, y = 0},
		[16] = {x = 0, y = 2},
	}

	local function buildPics( ... )
		local pics = nil
		pics = builderCache['ui/puzzle_res.json']:buildGroup(groupName)
		if pics then


			local total = NpcTigger.SkinMeta[skinType][groupIndex]
			local n = math.sqrt(total)

			local w = 216 * 2 / n

			local function lightOn( ctx )
				ctx:setVisible(true)
			end

			local function lightOff( ctx )
				ctx:setVisible(false)
			end


			for i = 1, n do
				self.piecesUISp[skinType][groupIndex][i] = {}

				for j = 1, n do

					local posIndex = (i - 1)* n + j

					local p = pics:getChildByName(tostring(posIndex))

					p:removeFromParentAndCleanup(false)
					local pos = p:getPosition()
					pos = ccp(pos.x, pos.y)

					local touchLayer = LayerColor:createWithColor(ccc3(255, 0, 0), 1, 1)
					pics:addChild(touchLayer)

					touchLayer:setTouchEnabled(true, nil, nil, function ( worldPosition )
						 return touchLayer:hitTestPoint(worldPosition, false)
					end)
					touchLayer:ad(DisplayEvents.kTouchTap, function ( ... )
						self:onPicTap(skinType, groupIndex, posIndex, p)
					end)
					touchLayer:ignoreAnchorPointForPosition(false)
					touchLayer:changeWidthAndHeight(w, w)
					touchLayer:setAnchorPoint(ccp(0, 1))
					touchLayer:setPositionX((j-1)*w)
					touchLayer:setPositionY((i-1)*(-w))
					touchLayer:addChild(p)

					touchLayer:setOpacity(0)

					pos = pics:convertToWorldSpace(pos)
					pos = touchLayer:convertToNodeSpace(pos)

					p:setPosition(pos)

					p.lightOn = lightOn 
					p.lightOff = lightOff 

					p:lightOff()

					if SeasonWeeklyRaceManager:getInstance():isSkinGroupPositionSetted(skinType, groupIndex, posIndex) then
						p:lightOn()
					end



					local bg = Sprite:createWithSpriteFrameName('clothespress/bg/'..total .. '0000')
					pics:addChildAt(bg, 1)
					bg:setAnchorPoint(ccp(0, 1))
					bg:setPositionX(bgAdjust[total].x)
					bg:setPositionY(bgAdjust[total].y)

					self.piecesUISp[skinType][groupIndex][i][j] = p

				end
			end

		end

		return pics
	end

	return buildPics() or buildDefaultPics()

end

function ClothespressPanel:onPicTap( skinType, groupIndex, picPosition, p )

	if self.isDisposed then return end


	SeasonWeeklyRaceManager:getInstance():usePiece(skinType, groupIndex, picPosition, function ( ... )
		if self.isDisposed then return end

		local data = SeasonWeeklyRaceManager:getInstance():getSkins()

		p:lightOn()
		self:refreshBtns()

		if NpcTigger:isComplete(skinType, groupIndex) then
			self:playPuzzleEffect()
			CommonTip:showTip(localize('weekly.complete.a.picture'), 'positive')
		end

		self:refreshHand()

		DcUtil:UserTrack({category='weeklyrace', sub_category='weeklyrace_winter_2017_click_puzzle', t1=1})


	end, function ( ... )
		-- body
		CommonTip:showTip(localize('weekly.usePiece.fail'))

		DcUtil:UserTrack({category='weeklyrace', sub_category='weeklyrace_winter_2017_click_puzzle', t1=2})

	end, function ( ... )
		-- CommonTip:showTip('拼图取消')
		-- body
	end)
end

function ClothespressPanel:showOff( ... )
	if self.isDisposed then return end

	local t1 = NpcTigger:getSkinCompletedNum()

	DcUtil:UserTrack({
		category='weeklyrace', 
		sub_category='weeklyrace_winter_2017_click_share_boss', 
		t1=t1
	})

	
	loadJson('ui/panel_summer_weekly_share2.json')

	local feedUI = builderCache['ui/panel_summer_weekly_share2.json']:buildGroup('SummerWeeklyRacePanel/npc/share_panel')

	local slotNames = {
		'hat', 'decorate', 'hand1', 'hand2', 'scarf'
	}

	for _, slotName in ipairs(slotNames) do
		for i = 1, 99 do
			local skin = feedUI:getChildByName(slotName .. '_' .. i)
			if skin then
				skin:setVisible(false)
			else
				break
			end
		end
	end

	local skinResData = self.npcTigger:getSkinResData()


	for slotName, resIndex in pairs(skinResData) do
		local skin = feedUI:getChildByName(slotName .. '_' .. resIndex)
		if skin then
			skin:setVisible(true)
		end
	end

	local thumbPath = HeResPathUtils:getResCachePath() .. "/thumb_image.jpg"
	local path = HeResPathUtils:getResCachePath() .. "/share_image.jpg"

	feedUI:screenShot(path, CCSizeMake(720, 720))
	feedUI:setScale(256/720)
	feedUI:screenShot(thumbPath, CCSizeMake(256, 256))


	feedUI:dispose()

	unloadJson('ui/panel_summer_weekly_share2.json')

	local title = ''
	local message = ''

	local shareCallback = {
		onSuccess = function(result)

			DcUtil:UserTrack({
				category='weeklyrace', 
				sub_category='weeklyrace_winter_2017_share_boss_success', 
				t1=t1
			})

			CommonTip:showTip('分享成功', 'positive')
		end,
		onError = function(errCode, errMsg)
			CommonTip:showTip('分享失败')
		end,
		onCancel = function()
			CommonTip:showTip('分享取消')
		end,
	}

	local shareType, delayResume = SnsUtil.getShareType()
	SnsUtil.sendImageMessage(shareType, title, message, thumbPath, path, shareCallback, true)

end

function ClothespressPanel:onSkinBtn( ... )
	if self.isDisposed then return end
	-- body

	local tabIndex = self.tabCtrl:getTabIndex()
	local pageIndex = self.page:getPageIndex()

	local groupIndex = (pageIndex - 1) % 2 + 1


	if not NpcTigger:isComplete(tabIndex, groupIndex) then
		local key = 'week.clothespress.picture.not.finish'
		CommonTip:showTip(localize(key), 'positive')

		DcUtil:UserTrack({category='weeklyrace', sub_category='weeklyrace_winter_2017_click_ware', t1=2}, true)
		return 
	end


	



	local curSkins = SeasonWeeklyRaceManager:getInstance():getCurSkin() or {}
	if curSkins[tabIndex] and curSkins[tabIndex] == groupIndex then
		groupIndex = -1
		DcUtil:UserTrack({category='weeklyrace', sub_category='weeklyrace_winter_2017_click_off'}, true)
	else
		DcUtil:UserTrack({category='weeklyrace', sub_category='weeklyrace_winter_2017_click_ware', t1=1}, true)
	end


	SeasonWeeklyRaceManager:getInstance():setSkin(tabIndex, groupIndex, function ( ... )
		-- body
		if self.isDisposed then return end

		self.npcTigger:refreshSkin()

		if groupIndex ~= -1 then
			CommonTip:showTip(localize('weekly.dressing.tip'), 'positive')
			self:playChangeSkinEffect()

		else
			CommonTip:showTip(localize('weekly.strip.tip'), 'positive')
		end



		self:refreshBtns()

	end, function ( ... )
		-- body
		CommonTip:showTip('换衣失败')
	end, function ( ... )
		CommonTip:showTip('换衣取消')
		-- body
	end)

end

function ClothespressPanel:_close()
	if self.isDisposed then return end
	self.allowBackKeyTap = false
	PopoutManager:sharedInstance():remove(self)
end

function ClothespressPanel:popout()

	local vs = Director:sharedDirector():getVisibleSize()

	-- self:setScale(math.min(vs.height / 1280,))

    -- self:setPositionForPopoutManager()

	PopoutManager:sharedInstance():add(self, true)
	self.allowBackKeyTap = true

	self:popoutShowTransition()
end

function ClothespressPanel:onCloseBtnTapped( ... )
    self:_close()
end

function ClothespressPanel:onKeyBackClicked( ... )
	if self.isDisposed then return end
	
	if self.guideMask and (not self.guideMask.isDisposed) then
		return 
	end

	BasePanel.onKeyBackClicked(self, ...)
end

function ClothespressPanel:popoutShowTransition( ... )
	if self.isDisposed then return end

	local key = 'ClothespressPanel:popGuide_1'

	-- if true then
	if (not SeasonWeeklyRaceManager:getInstance():isFlagSet(key)) and (not NpcTigger:isCompleteAnyone()) then
		self:popGuide_1()
		SeasonWeeklyRaceManager:getInstance():setFlag(key, true)
	end
end

function ClothespressPanel:popGuide_1( ... )

	if self.isDisposed then return end

	self:hideHandAnim()
	-- body
	local bounds = self.ui:getChildByName('bg4'):getGroupBounds()
	local position = ccp(bounds.origin.x, bounds.origin.y)

	local radius = 0
	local square = true
	local width = bounds.size.width
	local height = bounds.size.height
	local oval = false

	local curScene = Director:sharedDirector():run()

	local mask
	mask = createMask(200, 0.5, position, radius, square, width, height, oval, nil, function ( ... )
		if (not mask) or mask.isDisposed then return end
		mask:removeFromParentAndCleanup(true)
		if self.isDisposed then return end
		self:popGuide_2()
	end)
	curScene:addChild(mask, SceneLayerShowKey.TOP_LAYER)
	local wSize = CCDirector:sharedDirector():getWinSize()


	local action = 
    {
        opacity = 0xCC, 
        panelName = 'guide_dialogue_winter_1',
        panDelay = 0
    }

    
    local panel = GameGuideUI:panelS(nil, action, '点击任意处继续')
    mask:addChild(panel)

    panel:setScale(self.ui:getScaleX())

    panel:setPosition(ccp(position.x - height/2, position.y + height/4*3))

    self.guideMask = mask
end

function ClothespressPanel:popGuide_2( ... )

	if self.isDisposed then return end
	-- body
	local bounds = self.ui:getChildByName('bg3'):getChildByName('bg3'):getGroupBounds()
	local position = ccp(bounds.origin.x, bounds.origin.y)

	local radius = 0
	local square = true
	local width = bounds.size.width
	local height = bounds.size.height - 5
	local oval = false

	local curScene = Director:sharedDirector():run()

	local mask
	mask = createMask(200, 0.5, position, radius, square, width, height, oval, nil, function ( ... )
		if (not mask) or mask.isDisposed then return end
		mask:removeFromParentAndCleanup(true)
		if self.isDisposed then return end
		self:popGuide_3()
	end)
	curScene:addChild(mask, SceneLayerShowKey.TOP_LAYER)
	local wSize = CCDirector:sharedDirector():getWinSize()




	local action = 
    {
    	
        opacity = 0xCC, 
        panelName = 'guide_dialogue_winter_2',
       panDelay = 0
    }

    
    local panel = GameGuideUI:panelS(nil, action, '点击任意处继续')
    mask:addChild(panel)

    panel:setScale(self.ui:getScaleX())


    panel:setPosition(ccp(position.x + width/4, position.y + height/2))

    self.guideMask = mask

end

function ClothespressPanel:popGuide_3( ... )

	if self.isDisposed then return end
	-- body
	local bounds = self.ui:getChildByName('skinBtn'):getGroupBounds()
	local position = ccp(bounds.origin.x, bounds.origin.y + 4)

	local radius = 0
	local square = true
	local width = bounds.size.width
	local height = bounds.size.height
	local oval = false

	local curScene = Director:sharedDirector():run()

	local mask
	mask = createMask(200, 0.5, position, radius, square, width, height, oval, nil, function ( ... )
		if (not mask) or mask.isDisposed then return end
		mask:removeFromParentAndCleanup(true)
		if self.isDisposed then return end
		self:showHandAnim()
	end)

	curScene:addChild(mask, SceneLayerShowKey.TOP_LAYER)
	local wSize = CCDirector:sharedDirector():getWinSize()


	local action = 
    {
        opacity = 0xCC, 
        panelName = 'guide_dialogue_winter_3',
       	panDelay = 0
    }
    
    local panel = GameGuideUI:panelS(nil, action, '点击任意处继续')
    mask:addChild(panel)

    panel:setScale(self.ui:getScaleX())
    
    panel:setPosition(ccp(position.x , position.y + height/2))

    self.guideMask = mask
end

function ClothespressPanel:onTapDescBtn( ... )
	if self.isDisposed then return end

	require('zoo.panel.seasonWeekly.mainPanel.ClothesRulePanel'):create():popout()

	DcUtil:UserTrack({category='weeklyrace', sub_category='weeklyrace_winter_2017_click_puzzle_info'}, true)

end

function ClothespressPanel:createPageBtn( pageNum )

	self:loadRequiredResource("ui/clothespress.json")
	local pageBtn = self:buildInterfaceGroup('clothespress/pageBtn')

	local num_1 = BitmapText:create(tostring(pageNum), 'fnt/tutorial_white.fnt')
	num_1:setColor(ccc3(255, 255, 255))
	num_1:setAnchorPoint(ccp(0.5, 0.5))
	num_1:setScale(0.8)


	local num_2 = BitmapText:create(tostring(pageNum), 'fnt/tutorial_white.fnt')
	num_2:setColor(ccc3(0x99, 0x33, 0x00))
	num_2:setAnchorPoint(ccp(0.5, 0.5))

	local big = pageBtn:getChildByName('big')
	local small = pageBtn:getChildByName('small')

	big:addChild(num_2)
	small:addChild(num_1)

	num_2:setPositionX(big:getContentSize().width/2 - 1)
	num_2:setPositionY(big:getContentSize().height/2)

	num_1:setPositionX(small:getContentSize().width/2 -3)
	num_1:setPositionY(small:getContentSize().height/2)

	function pageBtn:select(b)
		if self.isDisposed then return end
		big:setVisible(b)
		small:setVisible(not b)
	end

	return pageBtn
end

return ClothespressPanel
