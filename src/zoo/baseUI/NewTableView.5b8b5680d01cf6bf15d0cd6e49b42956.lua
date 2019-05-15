

-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2014年01月18日 12:35:10
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com


---------------------------------------------------
-------------- NewTableView
---------------------------------------------------

assert(not NewTableView)
NewTableView = class(Layer)

function NewTableView:init(tableViewRender, width, height, ...)
	assert(#{...} == 0)

	-- Init Base
	Layer.initLayer(self)

	-- Get Data
	local availableTopY	= 0

	self.width 	= width
	self.height	= height

	-- -----------------
	-- Create Each Item
	-- -----------------
	local wholeLayer	= Layer:create()
	wholeLayer:setPosition(ccp(0, height))

	self.wholeLayer = wholeLayer

	--self:addChild(wholeLayer)
	--self.items	= {}


	-- Create Each Item
	local numberOfItems = tableViewRender:numberOfCells()

	-- if _G.isLocalDevelopMode then printx(0, "numberOfCells: " .. numberOfItems) end

	for index = 1, numberOfItems do
		-- Create Item
		local itemContainer = Layer:create()
		local newItem		= tableViewRender:buildCell(itemContainer, index)

		wholeLayer:addChild(itemContainer)
		itemContainer:setPosition(ccp(0, availableTopY))


		-- Get Item Size
		local itemContentSize	= tableViewRender:getContentSize(self, index)
		availableTopY		= availableTopY - itemContentSize.height
	end

	self.listHeight = availableTopY


	-----------------
	-- Create CLipping
	-- -----------------

	-- Stencil
	local stencil	= LayerColor:create()
	stencil:setColor(ccc3(255,0,0))
	stencil:changeWidthAndHeight(width, height)
	stencil:setPosition(ccp(0, 0))
	
	-- Clipping
	local cppClipping = CCClippingNode:create(stencil.refCocosObj)
	local luaClipping = ClippingNode.new(cppClipping)
	luaClipping:setPosition(ccp(0, -height))
	self:addChild(luaClipping)
	luaClipping:addChild(wholeLayer)

	-------------------
	-- Create Layer To Accept Touch
	-- -------------------------
	local touchReceiveLayer = LayerColor:create()
	touchReceiveLayer:setColor(ccc3(255, 0, 0))
	touchReceiveLayer:changeWidthAndHeight(width, height)
	touchReceiveLayer:setAlpha(0)
	touchReceiveLayer:setPosition(ccp(0, 0))

	touchReceiveLayer:setTouchEnabled(true, 0 , false)

	touchReceiveLayer.name = "touchReceiveLayer "


	luaClipping:addChild(touchReceiveLayer)

	
	local function onReceiveLayerTouchBegin(event)
		self:onReceiveLayerTouchBegin(event)
	end

	local function onReceiveLayerTouchMove(event)
		self:onReceiveLayerTouchMove(event)
	end

	local function onReceiveLayerTouchEnd(event)
		self:onReceiveLayerTouchEnd(event)
	end

	touchReceiveLayer:addEventListener(DisplayEvents.kTouchBegin, onReceiveLayerTouchBegin)
	touchReceiveLayer:addEventListener(DisplayEvents.kTouchMove, onReceiveLayerTouchMove)
	touchReceiveLayer:addEventListener(DisplayEvents.kTouchEnd, onReceiveLayerTouchEnd)


	-----------------------
	-- Create Layer TO Block Touch Above And Below Clipping
	-- -----------------------------
	local blockTouchAboveLayer	= LayerColor:create()
	blockTouchAboveLayer:setColor(ccc3(255, 0, 0))
	blockTouchAboveLayer:changeWidthAndHeight(width, height)
	blockTouchAboveLayer:setAlpha(0)
	blockTouchAboveLayer:setPosition(ccp(0, height))
	blockTouchAboveLayer:setTouchEnabled(true, 0, true)
	luaClipping:addChild(blockTouchAboveLayer)

	local blockTouchBelowLayer	= LayerColor:create()
	blockTouchBelowLayer:setColor(ccc3(255, 0, 0))
	blockTouchBelowLayer:changeWidthAndHeight(width, height)
	blockTouchBelowLayer:setAlpha(0)
	blockTouchBelowLayer:setPosition(ccp(0, -height))
	blockTouchBelowLayer:setTouchEnabled(true, 0, true)
	luaClipping:addChild(blockTouchBelowLayer)

	stencil:dispose()
end

function NewTableView:onReceiveLayerTouchBegin(event, ...)
	assert(#{...} == 0)
	--if _G.isLocalDevelopMode then printx(0, "touch begin !") end

	self.wholeLayer:stopAllActions()
	self.lastY	= event.globalPosition.y
end

function NewTableView:onReceiveLayerTouchMove(event, ...)
	assert(#{...} == 0)

	--if _G.isLocalDevelopMode then printx(0, "touch move !") end

	local newPos	= self.wholeLayer:getPosition().y
	local deltaY	= event.globalPosition.y - self.lastY

	if newPos < self.height  then

		if math.abs(self.height - newPos) > 10 then
			deltaY = deltaY / ((self.height - newPos) / 10)
		end

	elseif newPos + self.listHeight > 0 then
		if math.abs(newPos + self.listHeight) > 10 then
			deltaY = deltaY / ((newPos + self.listHeight) / 10)
		end
	end

	self.wholeLayer:runAction(CCMoveBy:create(0, ccp(0, deltaY)))
	self.lastY	= event.globalPosition.y
end

function NewTableView:onReceiveLayerTouchEnd(event, ...)
	assert(#{...} == 0)
	--if _G.isLocalDevelopMode then printx(0, "touch end !") end

	self.wholeLayer:stopAllActions()

	local newPos = self.wholeLayer:getPosition().y

	if newPos < self.height then
		self.wholeLayer:runAction(CCMoveTo:create(0.2, ccp(0, self.height)))
	elseif newPos + self.listHeight > 0 then

		self.wholeLayer:runAction(CCMoveTo:create(0.2, ccp(0, -self.listHeight)))
	end

	self.lastY = nil
end

function NewTableView:create(tableViewRender, width, height, ...)
	assert(#{...} == 0)

	local newNewTableView = NewTableView.new()
	newNewTableView:init(tableViewRender, width, height)
	return newNewTableView
end

