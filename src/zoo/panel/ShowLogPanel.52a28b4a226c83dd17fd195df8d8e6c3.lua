
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年11月27日 15:39:51
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

require "zoo.panel.basePanel.BasePanel"

---------------------------------------------------
-------------- ShowLogPanel
---------------------------------------------------

assert(not ShowLogPanel)
assert(BasePanel)
ShowLogPanel = class(BasePanel)

function ShowLogPanel:init(...)
	assert(#{...} == 0)

	----------------------
	-- Init Base Panel
	-- -----------------
	BasePanel.init(self, false)

	----------------
	-- Create UI
	-- -------------
	local visibleSize	= CCDirector:sharedDirector():getVisibleSize()
	
	-- Close Panel Btn
	local closeBtn = self:createClosePanelBtn()
	closeBtn:setPosition(ccp(0, -visibleSize.height))
	self:addChild(closeBtn)

	-- Create Multi Line Text Field
	self.assertFalseLogTableView = MultiLineTextField:create(visibleSize.width, visibleSize.height, 30, 30)
	self.assertFalseLogTableView:setPosition(ccp(0, -visibleSize.height))
	self:addChild(self.assertFalseLogTableView)


	---------------------------
	-- Add Event Listener
	-- ------------------
	local function onCloseBtnTapped()
		self:hide()
	end
	closeBtn:setTouchEnabled(true)
	closeBtn:addEventListener(DisplayEvents.kTouchTap, onCloseBtnTapped)
end

function ShowLogPanel:createClosePanelBtn(...)
	assert(#{...} == 0)

	local colorBg = LayerColor:create()
	colorBg:setColor(ccc3(255, 0, 0))
	colorBg:changeWidthAndHeight(200, 100)

	local closeLabel = TextField:create("Close Panel", "Helvetica", 40)
	closeLabel:setAnchorPoint(ccp(0,0))
	colorBg:addChild(closeLabel)

	return colorBg
end

function ShowLogPanel:setString(str, ...)
	assert(type(str) == "string")
	assert(#{...} == 0)

	self.assertFalseLogTableView:setString(str)
end

function ShowLogPanel:show(...)
	assert(#{...} == 0)

	PopoutManager:sharedInstance():add(self, true, false)
end

function ShowLogPanel:hide(...)
	assert(#{...} == 0)

	PopoutManager:sharedInstance():remove(self, true)
end

function ShowLogPanel:create(...)
	assert(#{...} == 0)

	local newShowLogPanel = ShowLogPanel.new()
	newShowLogPanel:init()
	return newShowLogPanel
end
