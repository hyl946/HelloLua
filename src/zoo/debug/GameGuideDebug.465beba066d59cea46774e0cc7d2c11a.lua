---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2018-01-10 11:10:14
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   Administrator
-- @Last Modified time: 2018-01-12 14:05:53
---------------------------------------------------------------------------------------
require "zoo.panel.component.common.VerticalScrollable"
require "zoo.baseUI.ViewGroupLayout"
require 'zoo.panel.component.common.VerticalTileLayout'
require 'zoo.panel.component.common.VerticalTileItem'
require "zoo.common.DynamicLoadLayout"

local GameGuideDebug = {}

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

	return btn
end

function GameGuideDebug:buildDebugUI(width, height)
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

	local levelIds = GameGuideDebug:getGuideLevels2()
	-- add content ViewGroupLayout
	local marginLeft = 5
	local marginTop = 5
	local itemWidth = (width - marginLeft) / 4 - marginLeft
	local itemHeight = 50
	local content = GameGuideDebug:createItemContainer(width, height-50, scrollView, levelIds)
	scrollView:setContent(content)
	return ui
end

function GameGuideDebug:createItemContainer(width, height, scrollable, levelIds)
	local marginLeft = 5
	local marginTop = 5
	local column = 4
	local itemWidth = (width - marginLeft) / column - marginLeft
	local itemHeight = 50
	local levelIds = levelIds or {}
	local LayoutRender = class(DynamicLoadLayoutRender)
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
		local levelId = itemData.data
		local item = createTestButton("Lv."..tostring(levelId), hex2ccc3("66CCFF"), 24, itemWidth, itemHeight)
		item:addEventListener(DisplayEvents.kTouchTap, function()
			GameGuideDebug:startLevel(levelId)
		end)
		item:setAnchorPoint(ccp(0, 1))
		item:ignoreAnchorPointForPosition(false)
		item:setPositionX(5)
		local layoutItem = ItemInClippingNode:create()
		layoutItem:setContent(item)
		layoutItem:setParentView(scrollable)
		return layoutItem
	end

  	local container = DynamicLoadLayout:create(LayoutRender.new())
  	container:initWithDatas(levelIds)
	return container
end

function GameGuideDebug:startLevel(levelId)
	if GameGuideDebug.loadingGamePlay then
		CommonTip:showTip("正在启动关卡，淡定~~~", "positive")
		return
	end
	setTimeOut(function() GameGuideDebug.loadingGamePlay = false end, 6)
	GameGuideDebug.loadingGamePlay = true
	GameGuide:sharedInstance():setRepeatGuide(true)
	require "zoo.panelBusLogic.NewStartLevelLogic"
	local delegate = {}
	delegate.onDidEnterPlayScene = function(ctx, gamePlayScene)
		gamePlayScene.isGameGuideDebugMode = true
	end
	local newStartLevelLogic = NewStartLevelLogic:create(delegate, levelId, {}, false, {})
	newStartLevelLogic:startGamePlayScene()
end

function GameGuideDebug:getGuideLevels()
	local levelIds = {}
	for k, v in pairs(GuideSeeds) do
		if k < 10000 then
			table.insert(levelIds, k)
		end
	end
	table.sort(levelIds)
	return levelIds
end

function GameGuideDebug:getGuideLevels2()
	local levelIds = {}
	local function filter(guideData)
		local appear = guideData.appear
		local isGameScene = false
		local levelId = nil
		local numMoves = nil
		if appear then
			for i, condition in ipairs(appear) do
				if condition.type == "scene" and condition.scene == "game" then
					isGameScene = true
				elseif condition.type == "numMoves" then
					numMoves = condition.para
				elseif condition.type == "topLevel" then
					levelId = condition.para
				end
			end
		end
		if levelId and isGameScene and numMoves == 0 then
			return levelId
		end
		return nil
	end
	for k, v in pairs(Guides) do
		local levelId = filter(v)
		if levelId then
			table.insert(levelIds, levelId)
		end
	end
	table.sort(levelIds)
	return levelIds
end

return GameGuideDebug