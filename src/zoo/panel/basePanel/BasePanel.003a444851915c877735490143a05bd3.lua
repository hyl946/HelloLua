

-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年09月17日 10:03:11
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

require "zoo.baseUI.BaseUI"

require "zoo.gameGuide.GameGuide"
-- require "zoo.panel.broadcast.BroadcastManager"

---------------------------------------------------
-------------- BasePanel
---------------------------------------------------

assert(not BasePanel)
assert(BaseUI)
BasePanel = class(BaseUI)

kPanelEvents = {
	kClose = "kPanelEvents.kClose",
	kButton = "kPanelEvents.kButton",
	kUpdate = "kPanelEvents.kUpdate",
}

function BasePanel:init(ui, panelName, ...)
    if(forceGcMemory) then forceGcMemory() end

	assert(ui ~= nil)
	--assert(panelName == false or type(panelName) == "string")
	assert(#{...} == 0)

	self.panelName		= "noName"
	self.allowBackKeyTap	= false		-- Flag To Indicate Panel Showed And Fixed

	if panelName then
		self.panelName = panelName
	end

	-- Init Base
	BaseUI.init(self, ui)

	---- OnEnter Event
	local function onEnterHandler(event, ...)
		assert(event)
		assert(#{...} == 0)

		self:onEnterHandler(event)
	end
	self:registerScriptHandler(onEnterHandler)

	if(panelName) then
		--[[
		local performanceLog = require("hecore.debug.PerformanceLog")
		if(performanceLog.enabled) then
			self._performanceLog = performanceLog:new(self.panelName)
		end
		]]
	end
end

function BasePanel:dispose()
	if(self._performanceLog) then
		self._performanceLog:uploadLog()
		self._performanceLog:free()
	end
	
	if type(self.unloadRequiredResource) == "function" then self:unloadRequiredResource() end
	BaseUI.dispose(self)
end

function BasePanel:loadRequiredResource( panelConfigFile )
	--
--

	self.panelConfigFile = panelConfigFile
	self.builder = InterfaceBuilder:createWithContentsOfFile(panelConfigFile)
end
function BasePanel:loadRequiredJson( panelConfigFile )
	--
--
 
	self.panelConfigFile = panelConfigFile
	self.builder = InterfaceBuilder:create(panelConfigFile)
end
function BasePanel:unloadRequiredResource()
	if self.panelConfigFile then
		InterfaceBuilder:unloadAsset(self.panelConfigFile)
	end
end

function BasePanel:buildInterfaceGroup( groupName )
	if self.builder then
		--
--
 
		return self.builder:buildGroup(groupName)
	else 
		if _G.isLocalDevelopMode  then printx(103,"can't find group, name = " .. groupName) end
		
		return nil 
	end
end

function BasePanel:scaleAccordingToResolutionConfig(...)
	assert(#{...} == 0)

	-- Config
	local config 		= UIConfigManager:sharedInstance():getConfig()
	local panelScale	= config.panelScale

	self:setScale(panelScale)
end

function BasePanel:onKeyBackClicked(...)
	assert(#{...} == 0)

	if _G.isLocalDevelopMode then printx(0, "BasePanel:onKeyBackClicked !", self.allowBackKeyTap, self.onCloseBtnTapped) end
	if self.allowBackKeyTap then

		if self.onCloseBtnTapped then
			self:onCloseBtnTapped()
		end
	end
end

function BasePanel:onEnterHandler(event, ...)
	assert(event)
	assert(#{...} == 0)

	if event == "enter" then
		if GameGuide and GameGuide.isInited then
			printx( 1 , "    BasePanel:onEnterHandler   GameGuide   enter")
			GameGuide:sharedInstance():onPopup(self)
		end
		-- BroadcastManager:getInstance():onPopup(self)
	elseif event == "exit" then
		if GameGuide and GameGuide.isInited then
			printx( 1 , "    BasePanel:onEnterHandler   GameGuide   exit")
			GameGuide:sharedInstance():onPopdown(self)
		end
		-- BroadcastManager:getInstance():onPopdown(self)
	end
end

function BasePanel:setPositionForPopoutManager()
	local vSize = CCDirector:sharedDirector():getVisibleSize()
	-- local wSize = CCDirector:sharedDirector():getWinSize()
	local vOrigin = CCDirector:sharedDirector():getVisibleOrigin()
	-- local posAdd = wSize.height - vSize.height - vOrigin.y
    local posAdd = _G.__EDGE_INSETS.top

	-- if _G.isLocalDevelopMode then printx(0, "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~") end
	-- if _G.isLocalDevelopMode then printx(0, "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~") end
	-- if _G.isLocalDevelopMode then printx(0, "vSize:",vSize.width,vSize.height) end	--  visible size after scale
	-- if _G.isLocalDevelopMode then printx(0, "wSize:",wSize.width,wSize.height) end	--	design size
	-- if _G.isLocalDevelopMode then printx(0, "vOrigin:",vOrigin.x,vOrigin.y) end		-- origin point in visible screen
	-- if _G.isLocalDevelopMode then printx(0, "posAdd",posAdd) end
	-- if _G.isLocalDevelopMode then printx(0, "self:getVCenterInScreenY()",self:getVCenterInScreenY()) end
	-- if _G.isLocalDevelopMode then printx(0, self:getHCenterInScreenX(), -(vSize.height - self:getVCenterInScreenY() + posAdd)) end
	-- if _G.isLocalDevelopMode then printx(0, "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~") end
	-- if _G.isLocalDevelopMode then printx(0, "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~") end

	self:setPosition(ccp(self:getHCenterInScreenX(), -(vOrigin.y + vSize.height - self:getVCenterInScreenY())))
end

function BasePanel:popoutShowTransition()
end

function BasePanel:findChild(name)
	return self.ui:getChildByName(name)
end

function BasePanel:createTouchButton(name, onTapped)
	local btn = self.ui:getChildByName(name)
	btn:setTouchEnabled(true)
	btn:setButtonMode(true)
	btn:ad(DisplayEvents.kTouchTap, onTapped)

	return btn
end


function BasePanel:createTouchButtonBySprite(sp, onTapped)

	sp:setTouchEnabled(true)
	sp:setButtonMode(true)
	sp:ad(DisplayEvents.kTouchTap, onTapped)
	return btn
end