
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013Äê12ÔÂ25ÈÕ 14:23:47
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

require "zoo.panel.component.ladyBugPanel.LadyBugTaskItem"
require "zoo.baseUI.NewTableView"

---------------------------------------------------
-------------- LadyBugTaskItemRender
---------------------------------------------------

assert(not LadyBugTaskItemRender)
assert(TableViewRenderer)
LadyBugTaskItemRender = class(TableViewRenderer)

function LadyBugTaskItemRender:init(...)
	assert(#{...} == 0)

	self.items	= {}
	self.panelLuaName = "LadyBugTaskItemRender"
	local function oneSecondCallback()
		self:oneSecondCallback()
	end

	self.oneSecondTimer	= OneSecondTimer:create()
	self.oneSecondTimer:setOneSecondCallback(oneSecondCallback)
end
function LadyBugTaskItemRender:dispose(  )
	--if not self.isDisposed then
	--	for k,v in pairs(self.items) do
	--		v:dispose()
	--	end
	--	self.isDisposed = true
	--end
end

function LadyBugTaskItemRender:oneSecondCallback(...)
	assert(#{...} == 0)
	if self.isDisposed then return end

	for k,v in pairs(self.items) do
		v:update()
	end
end

function LadyBugTaskItemRender:startOneSecondTimer(...)
	assert(#{...} == 0)

	self.oneSecondTimer:start()
end

function LadyBugTaskItemRender:stopOneSecondTimer(...)
	assert(#{...} == 0)

	self.oneSecondTimer:stop()
end

function LadyBugTaskItemRender:loadRequiredResource(panelConfigFile)
	self.panelConfigFile = panelConfigFile
	self.builder = InterfaceBuilder:create(panelConfigFile)
end


function LadyBugTaskItemRender:create(...)
	assert(#{...} == 0)

	local newLadyBugTaskItemRender = LadyBugTaskItemRender.new()
	newLadyBugTaskItemRender:loadRequiredResource(PanelConfigFiles.lady_bug_panel)
	newLadyBugTaskItemRender:init()
	return newLadyBugTaskItemRender
end


function LadyBugTaskItemRender:buildCell(cell, index, ...)
	assert(cell)
	assert(type(index) == "number")
	assert(#{...} == 0)

	--index = index + 1

	if self.items[index] then
		self.items[index]:removeFromParentAndCleanup(true)
		self.items[index] = nil
	end

	he_log_warning("can reuse ?")

	--else
		local ladyBugTaskItem = LadyBugTaskItem:create(index)
		self.items[index] = ladyBugTaskItem

		local ladyBugTaskItemHeight	= ladyBugTaskItem:getGroupBounds().size.height
		--ladyBugTaskItem:setPosition(ccp(0, ladyBugTaskItemHeight))

		cell:addChild(ladyBugTaskItem)
		--cell.refCocosObj:addChild(ladyBugTaskItem.refCocosObj)
		--ladyBugTaskItem:releaseCocosObj()
	--end
end

function LadyBugTaskItemRender:getContentSize(tableView, index, ...)
	assert(#{...} == 0)

	local ladyBugRewardItem = self.builder:buildGroup("ladyBugRewardItem")

	local size = ladyBugRewardItem:getGroupBounds().size

	size = {width = size.width, height = size.height}
	 --ResourceManager:sharedInstance():getGroupSize("ladyBugRewardItem")

	ladyBugRewardItem:dispose()

	return size
end

function LadyBugTaskItemRender:setData(refCocosObj, index, ...)
	assert(#{...} == 0)

	--local index = index + 1

	local ladyBugTaskItem = self.items[index]
	assert(ladyBugTaskItem)

	--ladyBugTaskItem
	
end

function LadyBugTaskItemRender:numberOfCells(...)
	assert(#{...} == 0)

	he_log_warning("hard coded number of lady bug sub tasks = 7 !")
	return 7
end

---------------------------------------------------
-------------- LadyBugPanel
---------------------------------------------------

assert(not LadyBugPanel)
assert(BasePanel)

LadyBugPanel = class(BasePanel)

function LadyBugPanel:init(scaleOriginPosInWorldSpace, ...)
	assert(scaleOriginPosInWorldSpace)
	assert(#{...} == 0)

	---------------
	-- Get UI Resource
	-- ---------------
	self.ui	=  self:buildInterfaceGroup("ladyBugPanel") --ResourceManager:sharedInstance():buildGroup("ladyBugPanel")
	assert(self.ui)
	self.panelLuaName = "LadyBugPanel"
	------------------
	-- Init Base Class
	-- ----------------
	BasePanel.init(self, self.ui)

	------------------
	-- Get UI Resource
	-- ----------------
	self.panelTitle 	= self.ui:getChildByName("panelTitle")
	self.closePanelBtn	= self.ui:getChildByName("closePanelBtn")
	self.taskItemPh		= self.ui:getChildByName("taskItemPh")

	self._greenScale9	= self.ui:getChildByName("_greenScale9")
	self.maskBg		= self.ui:getChildByName("maskBg")

	-- self.smallBubble1	= self.ui:getChildByName("smallBubble1")
	-- self.smallBubble2	= self.ui:getChildByName("smallBubble2")
	-- self.smallBubble3	= self.ui:getChildByName("smallBubble3")
	-- self.smallBubble4	= self.ui:getChildByName("smallBubble4")

	-- self.smallBubbles	= {self.smallBubble1, self.smallBubble2, self.smallBubble3, self.smallBubble4}

	assert(self.panelTitle)
	assert(self.closePanelBtn)
	assert(self.taskItemPh)

	assert(self._greenScale9)
	assert(self.maskBg)

	-- assert(self.smallBubble1)
	-- assert(self.smallBubble2)
	-- assert(self.smallBubble3)
	-- assert(self.smallBubble4)

	---------
	-- Data
	-- ------
	self.scaleOriginPosInWorldSpace = scaleOriginPosInWorldSpace

	---------
	-- Data About UI
	-- -------------
	
	self._greenScale9Pos	= self._greenScale9:getPosition()
	self.panelTitlePhPos = self.panelTitle:getPosition()

	---------------------
	-- Init UI Component
	-- ----------------
	self.taskItemPh:setVisible(false)

	local greenScale9Size	= self._greenScale9:getGroupBounds().size
	local maskBgSize	= self.maskBg:getGroupBounds().size

	------------------------------------------------
	-- Adjust Panel Bg According To Screen Reolution 
	-- ----------------------------------------------
	local panelScalePolicy2	= self:getPanelScalePolicy()

	local newGreenScale9Size	= CCSizeMake(greenScale9Size.width, 
							greenScale9Size.height * panelScalePolicy2)

	local newMaskBgSize		= CCSizeMake(maskBgSize.width, 
							maskBgSize.height * panelScalePolicy2)

	self.newMaskBgSize		= newMaskBgSize

	self._greenScale9:setPreferredSize(newGreenScale9Size)
	self.maskBg:setPreferredSize(newMaskBgSize)



	-- for k,v in ipairs(self.smallBubbles) do

	-- 	local curSmallBubblePos		= v:getPosition()
	-- 	local distanceToPanelTop	= -curSmallBubblePos.y + self._greenScale9Pos.y
	-- 	local newDistance		= distanceToPanelTop * panelScalePolicy2
	-- 	local newSmallBubblePosY	= self._greenScale9Pos.y - newDistance

	-- 	v:setPositionY(newSmallBubblePosY)
	-- end

	-------------------
	-- Get Data About UI
	-- ----------------
	self.taskItemPhPos	= self.taskItemPh:getPosition()

	----------------------
	-- Craete UI Component
	-- -------------------
	-- local taskItemSize	= ResourceManager:sharedInstance():getGroupSize("ladyBugRewardItem")

	local ladyBugRewardItem = self:buildInterfaceGroup("ladyBugRewardItem")
	local taskItemSize	= ladyBugRewardItem:getGroupBounds().size
	ladyBugRewardItem:dispose()

	local taskItemRender 	= LadyBugTaskItemRender:create()
	self.taskItemRender	= taskItemRender
	--self.taskTableView	= TableView:create(taskItemRender, taskItemSize.width, taskItemSize.height * 5.5)
	--self.taskTableView	= TableView:create(taskItemRender, taskItemSize.width + 3, self.newMaskBgSize.height)
	self.taskTableView	= NewTableView:create(taskItemRender, taskItemSize.width+3, self.newMaskBgSize.height - 10)



	local taskTableViewX	= self.taskItemPhPos.x
	--local taskTableVIewY	= self.taskItemPhPos.y - (taskItemSize.height * 5.5)
	--local taskTableVIewY	= self.taskItemPhPos.y - self.newMaskBgSize.height
	local taskTableVIewY	= self.taskItemPhPos.y 

	self.taskTableView:setPosition(ccp(taskTableViewX, taskTableVIewY))
	self.ui:addChild(self.taskTableView)

	-----------------
	-- Add Event Listener
	-- ----------------
	local function onCloseBtnTapped()
		self:onCloseBtnTapped()
	end

	self.closePanelBtn:setTouchEnabled(true, 0, false)
	self.closePanelBtn:setButtonMode(true)
	self.closePanelBtn:addEventListener(DisplayEvents.kTouchTap, onCloseBtnTapped)

	self.closePanelBtn:removeFromParentAndCleanup(false)
	self.ui:addChild(self.closePanelBtn)


	local charWidth		= 65
	local charHeight	= 65
	local charInterval	= 57
	local fntFile		= "fnt/caption.fnt"
	if _G.useTraditionalChineseRes then fntFile = "fnt/zh_tw/caption.fnt" end
	self.panelTitle		= LabelBMMonospaceFont:create(charWidth, charHeight, charInterval, fntFile)
	self.panelTitle:setAnchorPoint(ccp(0, 1))
	self.panelTitle:setPosition(ccp(self.panelTitlePhPos.x, self.panelTitlePhPos.y))
	self.ui:addChild(self.panelTitle)

	-- Set Panel Title
	local titleKey			= "lady.bug.panel.title"
	local titleValue		= Localization:getInstance():getText(titleKey)
	self.panelTitle:setString(titleValue)
	self.panelTitle:setToParentCenterHorizontal()

	------------------------
	-- Create Show Hide Anim
	-- --------------------
	self.showHideAnim	= IconPanelShowHideAnim:create(self, self.scaleOriginPosInWorldSpace)

	LadyBugMissionManager:sharedInstance():setMissionRewardCallback(function() self:showRemindGuide() end)
end


function LadyBugPanel:onCloseBtnTapped(...)
	assert(#{...} == 0)
	self:remove()
end

function LadyBugPanel:remove(...)
	assert(#{...} == 0)

	local function onPanelHideAnimFinishFunc()
		PopoutManager:sharedInstance():removeWithBgFadeOut(self, false, true)
	end

	self:hideOneTimeTip()
	self.showHideAnim:playHideAnim(onPanelHideAnimFinishFunc)
	if self.closeCallback then
		self.closeCallback()
	end
end

function LadyBugPanel:popout(showTip, panelCloseCallback)

	self.closeCallback = panelCloseCallback
	local function onShowAnimFinished()
		-- if _G.isLocalDevelopMode then printx(0, 'popout(showTip)', showTip) end
		self.allowBackKeyTap = true
		if showTip then
			self:showOneTimeTip()
		end
	end

	PopoutManager:sharedInstance():addWithBgFadeIn(self, true, false, false)
	--self.showHideAnim:playShowAnim(false)
	self.showHideAnim:playShowAnim(onShowAnimFinished)
end

function LadyBugPanel:getPanelScalePolicy()
	local config = UIConfigManager:sharedInstance():getConfig()
	local panelScalePolicy2	= config.panelScalePolicy2
	-- return panelScalePolicy2
	-- 针对高/宽比过高的分辨率，设置一个上限
	return math.min(panelScalePolicy2, 1.2)
end

function LadyBugPanel:getVCenterInScreenY(...)
	assert(#{...} == 0)

	local visibleSize	= CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
	--local selfHeight	= self:getGroupBounds().size.height

	local panelScalePolicy2	= self:getPanelScalePolicy()
	local selfHeight	= 843 * panelScalePolicy2

	local deltaHeight	= visibleSize.height - selfHeight
	local halfDeltaHeight	= deltaHeight / 2

	return visibleOrigin.y + halfDeltaHeight + selfHeight
	
end

function LadyBugPanel:onEnterHandler(event, ...)
	assert(#{...} == 0)
	BasePanel.onEnterHandler(self, event)

	if event == "enter" then
		--self:playShowAnim(false)
		self:setToScreenCenter()
		self.taskItemRender:startOneSecondTimer()

	elseif event == "exit" then
		self.taskItemRender:stopOneSecondTimer()
	end
end

function LadyBugPanel:playShowAnim(...)
	--assert(#{...} == 0)
	
end

function LadyBugPanel:create(scaleOriginPosInWorldSpace, ...)
	assert(scaleOriginPosInWorldSpace)
	assert(#{...} == 0)

	local newLadyBugPanel = LadyBugPanel.new()
	newLadyBugPanel:loadRequiredResource(PanelConfigFiles.lady_bug_panel)
	newLadyBugPanel:init(scaleOriginPosInWorldSpace)
	return newLadyBugPanel
end

function LadyBugPanel:getHCenterInParentX(...)
	assert(#{...} == 0)

	-- Vertical Center In Screen Y
	local visibleSize	= CCDirector:sharedDirector():getVisibleSize()
	local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
	-- local selfHeight	= self:getGroupBounds().size.height
	local selfWidth = 688

	local deltaWidth	= visibleSize.width - selfWidth
	local halfDeltaWidth	= deltaWidth / 2

	local vCenterInScreenX	= visibleOrigin.x + halfDeltaWidth

	-- Vertical Center In Parent Y
	local parent 		= self:getParent()
	local posInParent	= parent:convertToNodeSpace(ccp(vCenterInScreenX, 0))

	return posInParent.x
end

function LadyBugPanel:dispose()
	self.taskItemRender:dispose()
	BasePanel.dispose(self)

    ModuleNoticeButton:tryPopoutStartGamePanel()
	
end

function LadyBugPanel:showOneTimeTip()
	local config = CCUserDefault:sharedUserDefault()
	-- config:setBoolForKey("ladybug.tip.showed", false)
	-- config:flush()
	local uid = UserManager:getInstance().uid
	local hasShowed = config:getBoolForKey("ladybug.tip.showed."..uid)
	if _G.isLocalDevelopMode then printx(0, 'showOneTimeTip', hasShowed) end
	if not hasShowed then
		local vs = Director:sharedDirector():getVisibleSize()
		local vo = Director:sharedDirector():getVisibleOrigin()
		local height = 135 -- from flash file
		local content = self.builder:buildGroup('ladybug_panel_tip')

		local contentSize = content:getGroupBounds().size
		local layer = LayerColor:create()
		layer:setColor(ccc3(0,0,0))
		layer:setOpacity(0)
		layer:setContentSize(CCSizeMake(vs.width, height))
		layer:ignoreAnchorPointForPosition(false)
		layer:setAnchorPoint(ccp(0,1))
		local x = (vs.width - contentSize.width) / 2
		local y = height - (height - contentSize.height) / 2
		content:setPosition(ccp(x, y))
		layer:addChild(content)

		local tipY = self:convertToWorldSpace(ccp(0, -81)).y
		if _G.isLocalDevelopMode then printx(0, 'tipY', tipY) end
		local tipX = vo.x
		layer:setPosition(ccp(tipX, tipY))
		
		
		local btn = GroupButtonBase:create(content:getChildByName('btn'))
		btn:ad(DisplayEvents.kTouchTap, function () layer.hide() end)
		btn:setString(Localization:getInstance():getText("lady.bug.panel.tip.button.continue"))

		local hoursLeft = 24
		for i, v in ipairs(self.taskItemRender.items) do 
			local timeInSec = LadyBugMissionManager:sharedInstance():getTaskTime(v.taskId)
			if timeInSec ~= nil and timeInSec ~= false then
				hoursLeft = math.floor(timeInSec / 3600)
				break
			end
		end
		-- if _G.isLocalDevelopMode then printx(0, 'LadyBugPanel:showOneTimeTip()', hoursLeft) end
		content:getChildByName('txt'):setString(Localization:getInstance():getText("lady.bug.panel.tip.button.text", {n = hoursLeft}))
		layer.show = function () 
			local in_action = CCEaseSineOut:create(
		                CCSpawn:createWithTwoActions(
		                    CCFadeTo:create(0.4, 210),
		              		CCMoveBy:create(0.4, ccp(0, -height))
		                                             )
		                                    )
			layer:runAction(in_action) 
			local function onTimeOut() 
				if layer and not layer.isDisposed then 
					layer.hide() 
				end  
			end
			setTimeOut(onTimeOut , 5)
		end
		layer.hide = function () 
			if not layer.isDisposed then 
				local out_action = CCEaseSineOut:create(
		                CCSpawn:createWithTwoActions(
		                    CCFadeOut:create(0.2),
		              		CCMoveBy:create(0.2, ccp(0, height))
		                                             )
		                                    )
				local callfunc = CCCallFunc:create(function() 
		                                              	if layer and not layer.isDisposed then
			                                              	layer:removeFromParentAndCleanup(true)
			                                              	layer = nil
			                                            end
		                                            end)
				layer:runAction(CCSequence:createWithTwoActions(
				                out_action, callfunc
				                )) 
			end 
		end
		self.oneTimeTip = layer
		HomeScene:sharedInstance():addChild(layer)
		layer.show()


		config:setBoolForKey("ladybug.tip.showed."..uid, true)
		config:flush()
	end

end

function LadyBugPanel:hideOneTimeTip()
	if self.oneTimeTip then
		self.oneTimeTip:removeFromParentAndCleanup(true)
		self.oneTimeTip = nil
	end
end

-- 看看一起提交的文件，这是个大坑！
function LadyBugPanel:showRemindGuide()
	local showed = CCUserDefault:sharedUserDefault():getBoolForKey("LadybugMissionSecondRemindGuide")
	if showed then return end

	local action = 
    {	
    	panAlign = "viewY", panPosY = -360,
        panelName = 'guide_dialogue_ladyBugRemind',
        panDelay = 0.8,
    }

    local panel = GameGuideUI:panelS(nil, action, false)
	panel:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(5.5), CCCallFunc:create(function()
			panel:removeFromParentAndCleanup()
		end)))
	panel:setPositionXY(0, -360)
	self.ui:addChild(panel)
	CCUserDefault:sharedUserDefault():setBoolForKey("LadybugMissionSecondRemindGuide", true)
end