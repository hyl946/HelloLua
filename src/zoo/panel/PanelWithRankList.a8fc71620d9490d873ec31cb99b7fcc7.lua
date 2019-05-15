
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年09月18日 10:45:58
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

require "zoo.panel.basePanel.BasePanel"
require "zoo.panel.component.startGamePanel.rankList.RankList"
-- require "zoo.panel.weeklyRace.WeeklyRaceRankList"
-- require "zoo.panel.rabbitWeekly.RabbitWeeklyRankList"


---------------------------------------------------
-------------- PanelWithRankList
---------------------------------------------------

local AutoAction = 
{
	AUTO_OPEN	= 1,
	AUTO_CLOSE	= 2
}

assert(not PanelWithRankList)
assert(BasePanel)
PanelWithRankList = class(BasePanel)

function PanelWithRankList:init(levelId, levelType, topPanel, panelName, posYAdjust, ...)
	assert(type(levelId) == "number")
	assert(topPanel)
	assert(#{...} == 0)

	self.visibleOrigin 	= CCDirector:sharedDirector():getVisibleOrigin()
	self.visibleSize	= CCDirector:sharedDirector():getVisibleSize()

	-------------------
	--  Init Base Class
	--------------------
	BasePanel.init(self, false, panelName)

	-----------------------
	-- Data
	-- -------------------
	self.levelId = levelId
	self.levelType = levelType
	local _posYAdjust = posYAdjust or 0
	---------------------
	-- Add A Clipping Node, To Hide The Rank List's Top
	-- ----------------------------------------
	local visibleSize = CCDirector:sharedDirector():getVisibleSize()
	
	-- -- Create Stencil
	-- local stencil = LayerColor:create()
	-- stencil:changeWidthAndHeight()
	-- stencil:setPositionXY(0, -visibleSize.height*2 - 300)

	-- Create Rank List Panel Clipping Node 
	self.rankList = self:buildRankListByLevelType(levelId, levelType)

	local height = self.rankList:getGroupBounds().size.height

	local rankListPanelClipping = SimpleClippingNode:create()
	-- local rankListPanelClipping = LayerColor:create()
	-- rankListPanelClipping:setOpacity(100)

	rankListPanelClipping:setContentSize(CCSizeMake(visibleSize.width*2, height*1.95))
	rankListPanelClipping:setPositionXY(0, -height*2 - 200 - _posYAdjust)
	-- wenkan_print(rankListPanelClipping:getPositionX(), rankListPanelClipping:getPositionY()) debug.debug()
	rankListPanelClipping:setRecalcPosition(true)
	--rankListPanelClipping:setInverted(true)
	self:addChild(rankListPanelClipping)
	self.rankListPanelClipping = rankListPanelClipping
	-- rankListPanelClipping.refCocosObj:setAlphaThreshold(1.0)

	local innerLayer = Layer:create()
	innerLayer:setPositionY(height*2 + 200 + _posYAdjust)


	--self:addChild(self.rankList)
	rankListPanelClipping:addChild(innerLayer)
	rankListPanelClipping.innerLayer = innerLayer
	innerLayer:addChild(self.rankList)

	if self.hiddenRankList then
		if self.rankList then self.rankList:setButtonsEnable(false) end
	end

	-- Craete Top Panel
	self.topPanel	= topPanel
	self:addChild(self.topPanel)

	---------------------
	----	Init UI Component
	--------------------------
	
	-- Center TopPanel RankList Horizontal
	self.topPanel:setToScreenCenterHorizontal()
	self.rankList:setToScreenCenterHorizontal()

	local manualAdjustRankListPosX	= 5
	local curRankListPosX		= self.rankList:getPositionX()
	self.rankList:setPositionX(curRankListPosX + manualAdjustRankListPosX)

	self.rankList:setVisible(false)

	--------------------------------
	----- Data Control Motion And RankList
	------------------------------
	self.rankListTouchEnabled	= false

	-- Percent Coordinate On Screen
	-- Left Below Is The Origin
	local topPanelHeight		= self.topPanel:getGroupBounds().size.height
	self.topPanelHeightPercent	= topPanelHeight / self.visibleSize.height

	-- -------------------
	-- Top Panel Position
	-- -------------------
	self.topPanelInitX	= self.topPanel:getPositionX()
	self.topPanelInitY	= 0
	self.topPanelExpanX	= self.topPanel:getPositionX()
	self.topPanelExpanY	= 0

	-- --------------------------------------------------------
	-- Rank List's Position Is Based On Top Panel's Position
	-- --------------------------------------------------------
	self.rankListInitX	= self.rankList:getPositionX()
	self.rankListInitY	= self.topPanelInitY - self.topPanel:getGroupBounds().size.height 
	self.rankListExpanX	= self.rankList:getPositionY()
	self.rankListExpanY	= self.topPanelExpanY - self.topPanel:getGroupBounds().size.height

	self.STATE_EXPANDED = 1
	self.STATE_SHRINKED = 2
	self.STATE_IN_MIDDLE = 3
	self.state	= self.STATE_SHRINKED

	--------------------------------------
	-- Data Control Automatic Open / Close
	-- ----------------------------------
	self.automaticOpenCloseSpeed = 1600
	-- stencil:dispose()
end

function PanelWithRankList:buildRankListByLevelType( levelId, levelType )
	local rankList = nil
	-- Create Rank List Panel
	if levelType == GameLevelType.kDigWeekly then
		-- rankList   = WeeklyRaceRankList:create(levelId, self)
	elseif levelType == GameLevelType.kRabbitWeekly then
		-- rankList = RabbitWeeklyRankList:create(levelId, self)
	elseif levelType == GameLevelType.kSpring2019 then
		rankList	= PigYearRankList:create(levelId, self)
	else
		rankList	= RankList:create(levelId, self)
	end
	return rankList
end

function PanelWithRankList:setRankListPanelTouchEnable(...)
	assert(#{...} == 0)

	if self.hiddenRankList then
		self.rankListTouchEnabled = false
		return
	end

	--assert(self.rankListTouchEnabled == false)
	self.rankListTouchEnabled = true

	------------------------------------
	-- Add Global Touch Event Listener
	-- -----------------------------
	--self.isSceneTouchListenerEnabled	= true

	if not self.eventListenerISAdded then
		self.eventListenerISAdded = true
		local runningScene = Director:sharedDirector():getRunningScene()
		runningScene:addEventListener(DisplayEvents.kTouchBegin, self.onSceneTouchBegan, self)
		self.runningScene = runningScene
	end
end

function PanelWithRankList.onSceneTouchBegan(event, ...)
	assert(event)
	assert(event.context)
	assert(#{...} == 0)

	local self = event.context

	if not self.rankListTouchEnabled then
		return
	end

	--he_log_warning("may cause problem in android , when multi touch !")
	--assert(not self.touched)
	if self.touched then
		return
	end

	if StarBank and StarBank.needPopPanel then
		return
	end

	-- Chekc If Click The Hit Area
	--local hitArea = self.rankList:getHitArea()
	--if hitArea:hitTestPoint(event.globalPosition) then
	local scale9Bg		= self.rankList:getScale9Bg()
	local scale9BgPos	= scale9Bg:getPosition()

	-- Convert To World Pos
	local scale9BgParent		= scale9Bg:getParent()
	local scale9BgPosInWorld	= scale9BgParent:convertToWorldSpace(ccp(scale9BgPos.x, scale9BgPos.y))

	----------------------------------------------
	-- When Touch Below The  (Scale9Bg's Pos  + 75)
	-- -----------------------------------------

	if event.globalPosition.y <= scale9BgPosInWorld.y + 75 + 600 then
		-- Touched The Hit Area
		if _G.isLocalDevelopMode then printx(0, "Touch The Hit Area !") end

		self.touched = true

		local runningScene	= Director:getRunningScene()
		runningScene:addEventListener(DisplayEvents.kTouchMove, self.onTouchMoveScene, self)
		runningScene:addEventListener(DisplayEvents.kTouchEnd, self.onTouchEndScene, self) 
		
		self:stopAutomaticAction()

		self.originalFingerY		= event.globalPosition.y
		self.preFingerPositionY		= event.globalPosition.y
		self.curFingerPositionY		= event.globalPosition.y
		self.intentMoveDirection	= nil
	else
		-- Not Touch The Hit Area
		if _G.isLocalDevelopMode then printx(0, "Not Touch The Hit Area !") end

	end
end

function PanelWithRankList:setRankListPanelTouchDisable(...)
	assert(#{...} == 0)

	--assert(self.rankListTouchEnabled == true)
	he_log_warning("assert false ??!!")

	self.rankListTouchEnabled = false
end

function PanelWithRankList:removeRankListPanelSceneListener(...)
	assert(#{...} == 0)
	
	self.rankListTouchEnabled = false
	
	--if self.eventListenerISAdded then
		local runningScene = Director:sharedDirector():getRunningScene()
		runningScene:removeEventListener(DisplayEvents.kTouchBegin, self.onSceneTouchBegan)
		runningScene:removeEventListener(DisplayEvents.kTouchMove, self.onTouchMoveScene)
		runningScene:removeEventListener(DisplayEvents.kTouchEnd, self.onTouchEndScene)
	--end
end

function PanelWithRankList:getRankList(...)
	assert(#{...} == 0)

	assert(self.rankList)
	return self.rankList
end

function PanelWithRankList:getTopPanel(...)
	assert(#{...} == 0)

	assert(self.topPanel)
	return self.topPanel
end

---------------------------------------
-------	Set TopPanel,RankList Position
----------------------------------------

function PanelWithRankList:setTopPanelInitPos(x, y, ...)
	assert(type(x) == "number")
	assert(type(y) == "number")
	assert(#{...} == 0)

	self.topPanelInitX = x
	self.topPanelInitY = y
end

function PanelWithRankList:setTopPanelExpanPos(x, y, ...)
	assert(type(x) == "number")
	assert(type(y) == "number")
	assert(#{...} == 0)

	self.topPanelExpanX = x
	self.topPanelExpanY = y
end

function PanelWithRankList:setRankListInitPos(x, y, ...)
	assert(type(x) == "number")
	assert(type(y) == "number")
	assert(#{...} == 0)

	self.rankListInitX = x
	self.rankListInitY = y
end

function PanelWithRankList:setRankListExpanPos(x, y, ...)
	assert(type(x) == "number")
	assert(type(y) == "number")
	assert(#{...} == 0)

	self.rankListExpanX = x
	self.rankListExpanY = y
end

function PanelWithRankList:reBecomeTopPanel(...)
	assert(#{...} == 0)

	if _G.isLocalDevelopMode then printx(0, "PanelWithRankList:reBecomeTopPanel Called !") end

	self:setRankListPanelTouchEnable()
end


function PanelWithRankList:becomeSecondPanel()
	if _G.isLocalDevelopMode then printx(0, "PanelWithRankList:becomeSecondPanel Called !") end
	self:setRankListPanelTouchDisable()
end


function PanelWithRankList:getTopPanelInitPos(...)
	assert(#{...} == 0)

	return ccp(self.topPanelInitX, self.topPanelInitY)
end

function PanelWithRankList:getTopPanelExpanPos(...)
	assert(#{...} == 0)

	return ccp(self.topPanelExpanX, self.topPanelExpanY)
end

function PanelWithRankList:getRankListInitPos(...)
	assert(#{...} == 0)

	return ccp(self.rankListInitX, self.rankListInitY)
end

function PanelWithRankList:getRankListExpanPos(...)
	assert(#{...} == 0)

	return ccp(self.rankListExpanX, self.rankListExpanY)
end

------------------------------------------------------------
--------	Rank List Touch Handler
---------------------------------------------------------

function PanelWithRankList.onTouchMoveScene(event, ...)
	assert(event)
	assert(event.name == DisplayEvents.kTouchMove)
	assert(event.context)
	assert(#{...} == 0)

	local self = event.context
	local globalPos = event.globalPosition
	if not self.touched then return end

	if self.isDisposed then
		return
	end

	if not self.rankListTouchEnabled then
		return
	end

	self.preFingerPositionY		= self.curFingerPositionY
	self.curFingerPositionY		= event.globalPosition.y
	local deltaPositionY		= self.curFingerPositionY - self.preFingerPositionY
	local deltaToOriginalPosY	= self.curFingerPositionY - self.originalFingerY

	----------------------------------------------------------
	--- Check If Move Rank List Panel
	-- When It's In Expanded State, And The Current Visible Rank List Talbe View ( Server Rank Or Friend Rank )
	-- Not Scrolled At Top, THen Not Move THe Panel, Move The Rank List Table Instead
	-----------------------------------------------------------

	-- Get RankList Bg
	--local rankListBg	= self.rankList:getScale9Bg()
	local rankListItemBg	=  self.rankList:getRankListItemBg()

	local rankListItemBgPos	= rankListItemBg:getPosition()

	-- Get RankList Server Rank Table View
	--local serverRankListTableView = self.rankList:getServerRankListTableView()
	local visibleRankListTableView	= self.rankList:getVisibleRankListTableView()

	if visibleRankListTableView then 
		if self.state == self.STATE_EXPANDED then

			if rankListItemBg:hitTestPoint(ccp(globalPos.x, globalPos.y), false) then
				-- CLicked Rank List Talbe View

				local firstCell = visibleRankListTableView:cellAtIndex(0)

				if firstCell then
					---- Get First Cell Position
					local firstCellPosInWorldSpace = firstCell:convertToWorldSpace(ccp(0,0))
					local firstCellPosInRankListSpace = self.rankList:convertToNodeSpace(ccp(firstCellPosInWorldSpace.x, firstCellPosInWorldSpace.y))

					-- Get First Cell Top Left Height
					local firstCellHeight = ResourceManager:sharedInstance():getGroupSize("z_new_rank/rankListItem_2").height
					local firstCellTopLeftY = firstCellPosInRankListSpace.y + firstCellHeight

					if firstCellTopLeftY < rankListItemBgPos.y then
						-- Drag Exceed The Top
						-- Move The Panel, Not Move The Rank.
						--self.rankList:setTableViewTouchEnable(false)
					else
						-- Move The Rank, Not Move The Panel
						return 
					end
				else
					-- Cell At Index 0, Not Found !
					-- Move The Rank, Not Move The Panel
					--self.rankList:setTableViewTouchEnable(false)
					return 
				end
			else
				-- Not Clicked Rank List Table View
				-- Do Nothing
			end
		end
	end

	-------------------------------------------------------------------------------------

	if math.abs(deltaToOriginalPosY) > 20 then

		if deltaPositionY > 0 then
			self.intentMoveDirection	= "up"
		elseif deltaPositionY < 0 then
			self.intentMoveDirection	= "down"
		end

		self:moveRankListPanel(deltaPositionY)
	end
end

function PanelWithRankList.onTouchEndScene(event, ...)
	assert(event)
	assert(event.name == DisplayEvents.kTouchEnd)
	assert(event.context)
	assert(#{...} == 0)

	local self		= event.context
	local runningScene	= Director:getRunningScene()

	if not self.rankListTouchEnabled then
		return
	end

	-- assert(self.touched)
	self.touched = false

	runningScene:removeEventListener(DisplayEvents.kTouchMove, self.onTouchMoveScene)
	runningScene:removeEventListener(DisplayEvents.kTouchEnd, self.onTouchEndScene)

	-- Start Automatic Open/Close Rank List Panel
	if self.intentMoveDirection == "up" then
		self:automaticOpenRanklist()
	elseif self.intentMoveDirection == "down" then
		self:automaticCloseRanklist()
	end
	self.intentMoveDirection = nil
end

----------------------------------------------------------------------------
--------- Manually Open / Close Rank List 
-------------------------------------------------------------------------

function PanelWithRankList:moveRankListPanel(deltaY, ...)
	assert(deltaY)
	assert(#{...} == 0)

	-- Move Rank List
	local curRankListY	= self.rankList:getPositionY()
	local newRankListY	= curRankListY + deltaY

	if newRankListY < self.rankListInitY then
		newRankListY = self.rankListInitY
		self:setStateToShrinked()
	elseif newRankListY > self.rankListExpanY then
		newRankListY = self.rankListExpanY
		self:setStateToExpanded()
	else
		self:setStateToMiddle()
	end

	self.rankList:setPositionY(newRankListY)

	---- Move Top Panel
	local curTopPanelY	= self.topPanel:getPositionY()
	local newTopPanelY	= curTopPanelY + deltaY

	if newTopPanelY < self.topPanelInitY then
		newTopPanelY = self.topPanelInitY
	elseif newTopPanelY > self.topPanelExpanY then
		newTopPanelY = self.topPanelExpanY
	end

	-- if _G.isLocalDevelopMode then printx(0, newTopPanelY) end
	self.topPanel:setPositionY(newTopPanelY)
end

------------------------------------------------------------------------
------------	Automatic Open / Close Rank List 
----------------------------------------------------------------------

function PanelWithRankList:stopAutomaticAction(...)
	assert(#{...} == 0)

	self.rankList:stopActionByTag(AutoAction.AUTO_OPEN)
	self.rankList:stopActionByTag(AutoAction.AUTO_CLOSE)

	self.topPanel:stopActionByTag(AutoAction.AUTO_OPEN)
	self.topPanel:stopActionByTag(AutoAction.AUTO_CLOSE)

	self.automaticOpenCloseState = nil
end

-- ----------------
-- Open Rank List
-- ------------------
function PanelWithRankList:automaticOpenRanklist(...)
	assert(#{...} == 0)

	if self.isDisposed then
		return
	end

	assert(not self.automaticOpenCloseState)
	self.automaticOpenCloseState = "open"

	local count = 2
	
	local function animFinishCallback()
		count = count - 1

		if count == 0 then
			-- All Animation Is Done
			--self.state = self.STATE_EXPANDED
			self:setStateToExpanded()
		end
	end

	-- ----------------------
	-- Rank List Auto Open
	-- --------------------
	local curRankListX	= self.rankList:getPositionX()
	local deltaY		= self.rankListExpanY - self.rankList:getPositionY()
	local neededTime	= math.abs(deltaY / self.automaticOpenCloseSpeed)
	local moveTo		= CCMoveTo:create(neededTime, ccp(curRankListX, self.rankListExpanY))

	-- Finish Callback
	local callbackFunc = CCCallFunc:create(animFinishCallback)

	-- Seq
	local seq = CCSequence:createWithTwoActions(moveTo, callbackFunc)
	seq:setTag(AutoAction.AUTO_OPEN)
	self.rankList:runAction(seq)

	-- ----------------------
	-- Top Panel Auto Open
	-- ----------------------
	local curTopPanelX	= self.topPanel:getPositionX()
	local deltaY		= self.topPanelExpanY - self.topPanel:getPositionY()
	local neededTime	= math.abs(deltaY / self.automaticOpenCloseSpeed)
	local moveTo		= CCMoveTo:create(neededTime, ccp(curTopPanelX, self.topPanelExpanY))

	-- Finish Callback
	local callbackFunc	= CCCallFunc:create(animFinishCallback)

	-- Seq
	local seq = CCSequence:createWithTwoActions(moveTo, callbackFunc)
	seq:setTag(AutoAction.AUTO_OPEN)
	self.topPanel:runAction(seq)
end

function PanelWithRankList:setStateToShrinked(...)
	assert(#{...} == 0)

	self.state = self.STATE_SHRINKED
	self.rankList:setTableViewBounceable(false)
end

function PanelWithRankList:setStateToExpanded(...)
	assert(#{...} == 0)

	self.state = self.STATE_EXPANDED
	self.rankList:setTableViewBounceable(true)
end

function PanelWithRankList:setStateToMiddle(...)
	assert(#{...} == 0)
	self.state = self.STATE_IN_MIDDLE
end

-----------------------
--- Close Rank List
-----------------------
function PanelWithRankList:automaticCloseRanklist(...)
	assert(#{...} == 0)

	if self.isDisposed then
		return
	end

	assert(not self.automaticOpenCloseState)
	self.automaticOpenCloseState = "close"

	-- Callback 
	local count = 2
	
	local function animFinishCallback()
		count = count - 1

		if count == 0 then
			-- All Animation Is Done
			--self.state = self.STATE_SHRINKED
			self:setStateToShrinked()
		end
	end

	-- --------------------
	-- Rank List Auto Close
	-- -----------------------
	local curX		= self.rankList:getPositionX()
	local deltaY		= self.rankListInitY - self.rankList:getPositionY()
	local neededTime	= math.abs(deltaY / self.automaticOpenCloseSpeed)

	local moveTo	= CCMoveTo:create(neededTime, ccp(curX, self.rankListInitY))

	-- Finish Callback
	local callbackFunc = CCCallFunc:create(animFinishCallback)

	-- Seq
	local seq = CCSequence:createWithTwoActions(moveTo, callbackFunc)

	seq:setTag(AutoAction.AUTO_CLOSE)
	self.rankList:runAction(seq)

	-- ---------------------
	-- Top Panel Auto Close
	-- -----------------------
	local curX		= self.topPanel:getPositionX()
	local deltaY		= self.topPanelInitY - self.topPanel:getPositionY()
	local neededTime	= math.abs(deltaY / self.automaticOpenCloseSpeed)
	local moveTo		= CCMoveTo:create(neededTime, ccp(curX, self.topPanelInitY))

	-- Finish Callback
	local callbackFunc	= CCCallFunc:create(animFinishCallback)

	-- Seq
	local seq = CCSequence:createWithTwoActions(moveTo, callbackFunc)

	seq:setTag(AutoAction.AUTO_CLOSE)
	self.topPanel:runAction(seq)
end

function PanelWithRankList:onEnterHandler(event, ...)
	assert(event)
	assert(#{...} == 0)
	
	BasePanel.onEnterHandler(self, event)

	if event == "enter" then
		self.topPanel:setToScreenCenterHorizontal()
		self.rankList:setToScreenCenterHorizontal()

	elseif event == "exit" then
		-- local runningScene = Director:sharedDirector():getRunningScene()

		-- if runningScene then
		-- 	runningScene:removeEventListener(DisplayEvents.kTouchBegin, PanelWithRankList.onSceneTouchBegan)
		-- end
	end
end

function PanelWithRankList:dispose()
	local runningScene = self.runningScene or Director:sharedDirector():getRunningScene()
	if runningScene then
		runningScene:removeEventListener(DisplayEvents.kTouchBegin, PanelWithRankList.onSceneTouchBegan)
	end
	BasePanel.dispose(self)
end