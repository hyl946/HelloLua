---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2019-03-21 11:31:51
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   dan.liang
-- @Last Modified time: 2019-03-21 15:14:24
---------------------------------------------------------------------------------------
local CommonGridPanel = class(CocosObject)

local function createTestButton(text, color, fntSize, width, height)
	color = color or ccc3(64,64,64)
	local r, g, b = color.r, color.g, color.b
	width = width or 80
	height = height or 50
	local btn = LayerColor:createWithColor(color, width, height)
	btn:setTouchEnabled(true, 0, true)
	-- btn:setOpacity(255 * 0.9)
	btn:addEventListener(DisplayEvents.kTouchBegin, function(evt)
		local action = CCTintTo:create(0.1, 0, 255, 0)
		action.tag = 11114
		btn:stopActionByTag(11115)
		btn:stopActionByTag(11114)
		btn:runAction(action)
	end)
	btn:addEventListener(DisplayEvents.kTouchEnd, function(evt)
		local action = CCTintTo:create(0.2, r, g, b)
		action.tag = 11115
		btn:stopActionByTag(11114)
		btn:stopActionByTag(11115)
		btn:runAction(action)
	end)

	fntSize = fntSize or 30
	local label = TextField:create(tostring(text), nil, fntSize)
	label:setColor(ccc3(255 - color.r, 255 - color.g, 255 - color.b))
	label:setAnchorPoint(ccp(0.5,0.5))
	label:setPositionX(width/2)
	label:setPositionY(height/2)
	btn.label = label
	btn:addChild(label)

	btn.setString = function(ctx, str)
		ctx.label:setString(str or "")
	end

	return btn
end

function CommonGridPanel:buildDebugUI(width, height)
	local ui = LayerColor:createWithColor(ccc3(255, 255, 255), width, height)
	ui:setAnchorPoint(ccp(0, 1))
	ui:ignoreAnchorPointForPosition(false)
	ui:setOpacity(255 * 0.9)
	ui:setTouchEnabled(true, 0, true)
	-- add close button
	local closeBtn = createTestButton("关闭", hex2ccc3("FF6666"), 32, 80, 40)
	closeBtn:setPosition(ccp(width-80, height-40))
	closeBtn:addEventListener(DisplayEvents.kTouchTap, function()
		ui:removeFromParentAndCleanup(true)
	end)
	ui:addChild(closeBtn)
	-- add scroll container
	local scrollView = VerticalScrollable:create(width, height - 50, true, true)
	scrollView:setPositionX(0)
	scrollView:setPositionY(height-45)
	scrollView:setScrollEnabled(true)
	ui:addChild(scrollView)

	-- add content ViewGroupLayout
	local marginLeft = 5
	local marginTop = 5
	local itemWidth = (width - marginLeft) / 4 - marginLeft
	local itemHeight = 50
	local content = self:createItemContainer(width, height-50, scrollView, self.delegate.datas)
	scrollView:setContent(content)
	self:addChild(ui)
end

function CommonGridPanel:createItemContainer(width, height, scrollable, datas)
	local marginLeft = 5
	local marginTop = 5
	local column = self.delegate.column
	local itemWidth = (width - marginLeft) / column - marginLeft
	local itemHeight = 50
	local datas = datas or {}
	local LayoutRender = class(DynamicLoadLayoutRender)
	local delegate = self.delegate
	function LayoutRender:getColumnNum()
		return column
	end
	function LayoutRender:getItemSize()
		return {width = itemWidth+marginLeft, height = itemHeight+marginTop}
	end
	function LayoutRender:getVisibleHeight()
		return height
	end
	function LayoutRender:buildItemView(itemData, index)
		local data = itemData.data
		local item = createTestButton(tostring(index), hex2ccc3("66CCFF"), 24, itemWidth, itemHeight)
		item:setAnchorPoint(ccp(0, 1))
		item:ignoreAnchorPointForPosition(false)
		item:setPositionX(5)
		if type(delegate.itemOnCreateHandler) == "function" then
			delegate.itemOnCreateHandler(item, index, data)
		end
		item:addEventListener(DisplayEvents.kTouchTap, function()
			if type(delegate.itemOnTappedHandler) == "function" then
				delegate.itemOnTappedHandler(item, index, data)
			end
		end)
		local layoutItem = ItemInClippingNode:create()
		layoutItem:setContent(item)
		layoutItem:setParentView(scrollable)
		return layoutItem
	end

  	local container = DynamicLoadLayout:create(LayoutRender.new())
  	container:initWithDatas(datas)
	return container
end

function CommonGridPanel:createPanel(delegate)
	local panel = CommonGridPanel.new(CCNode:create())
	panel.delegate = delegate
	panel:buildDebugUI(delegate.panelSize.width, delegate.panelSize.height)
	return panel
end


local CommonGridPanelDelegate = class()

function CommonGridPanelDelegate:ctor()
	self.column = 1
	self.panelSize = nil
	self.datas = nil
	self.itemOnCreateHandler = nil
	self.itemOnTappedHandler = nil
end

function CommonGridPanelDelegate:setDatas(datas)
	self.datas = datas
end

function CommonGridPanelDelegate:setColumn(column)
	self.column = column
end

function CommonGridPanelDelegate:setItemOnCreateHandler(itemOnCreateHandler)
	self.itemOnCreateHandler = itemOnCreateHandler
end

function CommonGridPanelDelegate:setItemOnTappedHandler(itemOnTappedHandler)
	self.itemOnTappedHandler = itemOnTappedHandler
end

function CommonGridPanelDelegate:createPanel(width, height)
	self.panelSize = {width = width, height = height}
	local panel = CommonGridPanel:createPanel(self)
	return panel
end

return CommonGridPanelDelegate