
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年09月12日 16:11:48
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

require "zoo.panel.component.startGamePanel.rankList.RankListItem"
require "zoo.panel.component.startGamePanel.rankList.RankListCache"
require "hecore.ui.TableView"
require "zoo.panel.component.startGamePanel.rankList.RankListButton"
require "zoo.panel.component.startGamePanel.rankList.GetMoreButton"

local FriendScoreMgr = require "zoo.data.FriendScoreMgr"
------------------------------------------------------
------	Rank List Table View Render
------	
------  When Table View Need To Show A Cell, This Class Will Be Called !
------  Then This Class Will Call RankListCache's Function To Get The Data.
------
------  When Requested Data Is In The Cache, Return Imemedately.
------  When Requested Data Is Not In The Cache, Return Nil, And Send Message To The Server.
------		After A While, When The Data Return From Server, A Call Back Function Will Called.
------		This Callback Then Call Table View's reloadData Function
---------------------------------------------

-- -------------------
-- Need Information: 
-- 	Rank Index
-- 	User Name
-- 	User Score
-- 	User Picture
-----------------------

--------------------------------------------
-----	Rank List Table View Render
---------------------------------------------

assert(not RankListTableViewRender)
RankListTableViewRender = class(TableViewRenderer)

function RankListTableViewRender:init(rankListDataCache, cacheRankType, levelFlag, ...)
	assert(rankListDataCache)
	assert(cacheRankType)
	RankListCacheRankType.checkRankType(cacheRankType)
	assert(#{...} == 0)

	self.levelFlag = levelFlag
	self.rankListDataCache	= rankListDataCache
	self.cacheRankType	= cacheRankType

	self.rankListItems = {}

end
function RankListTableViewRender:dispose(  )
	if not self.isDisposed then
		for k,v in pairs(self.rankListItems) do
			v:dispose()
		end
		self.isDisposed = true
	end
end


function RankListTableViewRender:create(rankListDataCache, cacheRankType, width, height, levelFlag ,...)
	assert(rankListDataCache)
	assert(cacheRankType)
	RankListCacheRankType.checkRankType(cacheRankType)
	assert(type(width) == "number")
	assert(type(height) == "number")
	assert(#{...} == 0)

	local render = RankListTableViewRender.new(width, height)
	render:init(rankListDataCache, cacheRankType , levelFlag )
	return render
end

function RankListTableViewRender:buildCell(cell, index, ...)
	assert(cell)
	assert(type(index) == "number")
	assert(#{...} == 0)

	local numberOfCells	= self:numberOfCells()
	local skinName, uncommonSkin = WorldSceneShowManager:getInstance():getHomeScenePanelSkin(HomeScenePanelSkinType.kLevelRankListItem)
	local rankListItemRes	= ResourceManager:sharedInstance():buildGroup(skinName)
	local rankListItem	= RankListItem:create(rankListItemRes , self.levelFlag )
	rankListItem.owner = self.owner
	self.rankListItems[index + 1] = rankListItem

	if self.cacheRankType == RankListCacheRankType.SERVER then
		rankListItem:setShowFourStarFlag(false)
	end

	-- TODO: check for wrong in getGroupBounds
	local rankListItemHeight = 80
	-- local rankListItemHeight = rankListItem:getGroupBounds().size.height
	rankListItem:setPosition(ccp(0, rankListItemHeight))
	cell.refCocosObj:addChild(rankListItem.refCocosObj)

	rankListItem:releaseCocosObj()
end

function RankListTableViewRender:getContentSize(tableView, index, ...)
	assert(tableView)
	assert(type(index) == "number")
	assert(#{...} == 0)

	local numberOfCells = self:numberOfCells()
	return CCSizeMake(self.width, self.height)
end

function RankListTableViewRender:setData(rawCocosObj, index, ...)
	assert(rawCocosObj)
	assert(index)
	assert(#{...} == 0)
	if self.isDisposed then return end

	index = index + 1

	-- Get RankListItem To Set Data
	local rankListItemToControl = self.rankListItems[index]
	assert(rankListItemToControl)

	-- Get Data, And Update View
	local data = self.rankListDataCache:getCurCachedRankList(self.cacheRankType, index)
	assert(data)
	local userName = data.name
	if userName == nil or data.name == "" then userName = tostring(data.uid) end
	local uid = UserManager:getInstance():getUserRef().uid
	rankListItemToControl:setData(index, userName, data.score, data.headUrl, uid == data.uid, data.star, data.uid, data)
end

function RankListTableViewRender:numberOfCells(...)
	assert(#{...} == 0)

	local cachedDataLength = self.rankListDataCache:getCurCachedRankListLength(self.cacheRankType)
	return cachedDataLength
end


---------------------------------------------------
-------------- RankList
---------------------------------------------------

assert(not RankList)
assert(BaseUI)
RankList = class(BaseUI)

local function getRealPlistPath(path)
    local plistPath = path
    if __use_small_res then  
        plistPath = table.concat(plistPath:split("."),"@2x.")
    end

    return plistPath
end

function RankList:init(levelId, panelWithRank, ...)
	assert(levelId)
	assert(#{...} == 0)

	CCSpriteFrameCache:sharedSpriteFrameCache():addSpriteFramesWithFile(getRealPlistPath("flash/four_star_shine.plist"))

	self.visibleSize		= CCDirector:sharedDirector():getVisibleSize()

	-- ----------------
	-- Get UI Resource
	-- ----------------
	local skinName, uncommonSkin = WorldSceneShowManager:getInstance():getHomeScenePanelSkin(HomeScenePanelSkinType.kLevelRankList)
	self.uncommonSkin = uncommonSkin
	self.ui = ResourceManager:sharedInstance():buildGroup(skinName)
	BaseUI.init(self, self.ui)

	if self.uncommonSkin then
		self.levelFlag = LevelDiffcultFlag.kNormal 
	else
		self.levelFlag = MetaManager:getInstance():getLevelDifficultFlag_ForStartPanel(levelId )
	end
	-- ----------------
	-- Init Base
	-- ----------------

	---------------
	-- Data
	-- ------------
	self.levelId 		= levelId
	self.panelWithRank	= panelWithRank
	self.popouted = false
	self.serverRankInitialDataReady = false

	-- ----------------
	-- Get UI Resource
	-- ----------------
	
	self.rankLabelWrapper	= self.ui:getChildByName("rankLabelWrapper")

	self.myRankLabel		= self.rankLabelWrapper:getChildByName("myRankLabel")
	self.rankNumLabel		= self.rankLabelWrapper:getChildByName("rankNumLabel")
	--self.notHaveRankLabel		= self.rankLabelWrapper:getChildByName("notHaveRankLabel")

	self.rankListItemPh	= self.ui:getChildByName("rankListItemPh")
	self.friendRankBtnRes	= self.ui:getChildByName("friendRankBtn")
	self.serverRankBtnRes	= self.ui:getChildByName("serverRankBtn")
	self.strategyBtnRes = self.ui:getChildByName("strategyBtn")
	self.scale9Bg		= self.ui:getChildByName("scale9Bg")
	self.rankListItemBg	= self.ui:getChildByName("rankListItemBg")

	self.noNetworkLabel	= self.ui:getChildByName("noNetworkLabel")

	----------------------
	---- Init UI Resource
	----------------------
	self.rankListItemPh:setVisible(false)

	self.myRankLabel:setVisible(false)
	self.rankNumLabel:setVisible(false)
	--self.notHaveRankLabel:setVisible(false)
	self.rankLabelWrapper:setScale(1)

	-- Hide No Network Label
	self.noNetworkLabel:setVisible(false)

	--- Update UI
	self.noNetworkLabel:setString(localize("rank.list.no.network"))

	-- ----------------- 
	-- -- Get Data About UI
	-- ------------------
	local rankListItemPhPos		= self.rankListItemPh:getPosition()
	local rankListItemWidth		= ResourceManager:sharedInstance():getGroupWidth("z_new_rank/rankListItem_2")
	-- TODO: check for wrong in getGroupBounds
	local rankListItemHeight	= 80
	-- local rankListItemHeight	= ResourceManager:sharedInstance():getGroupHeight("rankListItem")

	local rankLabelKey	= "rank.list.my.rank"
	local rankLabelValue	= Localization:getInstance():getText(rankLabelKey, {})
	--self.rankLabelValue	= rankLabelValue
	-- Mocke
	--self.rankLabelValue	= "我的排名："
    rankLabelValue = rankLabelValue:gsub("：", ":  ")
	self.myRankLabel:setString(rankLabelValue)


	local notHaveRankLabelKey	= ""
	local notHaveRankLabelValue	= Localization:getInstance():getText(notHaveRankLabelKey, {})
	-- Mock
	he_log_warning("use mock data !")
	local notHaveRankLabelValue	= "没有获得排名"
	--self.notHaveRankLabel:setString(notHaveRankLabelValue)

	--------------
	-- Data
	-- -------
	--self.isFriendRankHasData = false
	--self.isServerRankHasData = false
	self.isFriendRankHasData = true
	self.isServerRankHasData = true
	self.isStrategyHasData = false 

	-- --------------------
	-- Create Component
	-- -----------------
	local function onServerBtnTapped()
		self:onServerBtnTapped()
	end

	local function onFriendBtnTapped()
		self:onFriendBtnTapped()
	end

	self.serverRankBtn	= RankListButton:create(self.serverRankBtnRes, onServerBtnTapped , self.levelFlag )
	self.friendRankBtn	= RankListButton:create(self.friendRankBtnRes, onFriendBtnTapped , self.levelFlag  )
	self:initFriendRankRefreshBtn(self.friendRankBtn.ui:getChildByName("btnRefresh"))

	self.tabBtnY = self.serverRankBtn:getPositionY()

	-- self.strategyBtn = RankListButton:create(self.strategyBtnRes, function ()
	-- 	self:onStrategyBtnTapped()
	-- end , self.levelFlag )

	if self.serverRankBtn.notTappedBg then
		self.serverRankBtn.notTappedBg:setOpacity(255)
	end

	if self.friendRankBtn.notTappedBg then
		self.friendRankBtn.notTappedBg:setOpacity(255)
	end

	-- if self.strategyBtn.notTappedBg then
	-- 	self.strategyBtn.notTappedBg:setOpacity(255)
	-- end

	-- if not LevelStrategyManager.getInstance():shouldShowStrategy(self.levelId) or self.panelWithRank.panelName == "levelSuccessPanel" then 
	-- 	self.strategyBtn.ui:setVisible(false)
	-- else
	-- 	LevelStrategyLogic:setReplayBtnEnable(true)
	-- 	self.strategyBtn.notTappedBg:runAction(CCRepeat:create(CCSequence:createWithTwoActions(CCFadeTo:create(0.4, 150), CCFadeTo:create(0.4, 255)), 4))
	-- end

	-- Init Button State
	local serverRankBtnKey		= "rank.list.server.rank"
	local serverRankBtnValue	= Localization:getInstance():getText(serverRankBtnKey, {})
	self.serverRankBtn:setString(serverRankBtnValue)

	self.serverRankBtn:setToUntappedState()

	local friendRankBtnKey		= "rank.list.friend.rank"
	local friendRankBtnValue	= Localization:getInstance():getText(friendRankBtnKey, {})
	self.friendRankBtn:setString(friendRankBtnValue, true)

	-- self.strategyBtn:setString(localize("过关回放"))
	-- self.strategyBtn:setToUntappedState()
	-- --------------------
	-- Create Rank List Data Cache
	-- ------------------------
	-- Rank List Data Cache Is The Data Source For Server/Friend Rank List
	

	-- On Cache Data Change Callback
	-- To Reload Data And Keep The Scroll Position Not Changed
	local function onRankListCachedDataChange(rankType, ...)
		RankListCacheRankType.checkRankType(rankType)
		assert(#{...} == 0)

		--he_log_warning("check if disposed")
		if self.serverRankListTableView.isDisposed then
			return
		end

		if rankType == RankListCacheRankType.SERVER then

			self.isServerRankHasData = true
			self.serverRankListTableView:reloadData()
			self:updateWhenDataChange()

		elseif rankType == RankListCacheRankType.FRIEND then

			local curFriendRank = UserManager:getInstance().selfNumberInFriendRank[self.levelId]
			if self.panelWithRank.panelName == "levelSuccessPanel" then

				Notify:dispatch("AchiEventDataUpdate", AchiDataType.kFriendRank, curFriendRank)

				if self.rankListCache and self.rankListCache.friendRankList then
					Notify:dispatch("AchiEventDataUpdate", AchiDataType.kFriendRankList, self.rankListCache.friendRankList)
					Notify:dispatch("AchiEventDataUpdate", AchiDataType.kPassFriendNum, #self.rankListCache.friendRankList - 1)
				end
			end

			self.isFriendRankHasData = true
			self.friendRankListTableView:reloadData()
			self:updateWhenDataChange()
		else 
			assert(false)
		end
	end

	-- On Get Server Rank List Failed
	local function onGetServerRankFailed()
		if _G.isLocalDevelopMode then printx(0, "onGetServerRankFailed Called !") end

		if self.isDisposed then
			return
		end

		self.isServerRankHasData = false
		--self.noNetworkLabel:setVisible(true)
		self:updateNoNetWorkLabel()
	end

	-- On Get Friend Rank List Failed
	local function onGetFriendRankFailed()
		if _G.isLocalDevelopMode then printx(0, "onGetFriendRankFailed Called !") end

		self.isFriendRankHasData = false
		self:updateNoNetWorkLabel()
		--self.noNetworkLabel:setVisible(true)
	end

	local hiddenRankList = self.panelWithRank.hiddenRankList
	self.rankListCache = RankListCache:create(self.levelId, onRankListCachedDataChange, hiddenRankList)
	self.rankListCache:setGetFriendRankFailedCallback(onGetFriendRankFailed)
	self.rankListCache:setGetServerRankFailedCallback(onGetServerRankFailed)

	-- ------------------------
	-- Create Server Rank List
	--------------------------
	
	local function onServerRankListItemTouched(event)
		self:onServerRankListItemTouched(event)
	end
	
	local listSizeHeightDelta = 40
	if uncommonSkin then
		listSizeHeightDelta = 60 
	end
	local size = self.rankListItemBg:getGroupBounds().size
	self.serverRankListTableViewRender	= RankListTableViewRender:create(self.rankListCache, RankListCacheRankType.SERVER,
		rankListItemWidth, rankListItemHeight, self.levelFlag )
	self.serverRankListTableViewRender.owner = self
	-- self.serverRankListTableView		= TableView:create(self.serverRankListTableViewRender, rankListItemWidth, rankListItemHeight * 6.8)
	self.serverRankListTableView		= TableView:create(self.serverRankListTableViewRender, rankListItemWidth, size.height - listSizeHeightDelta)
	--self.serverRankListTableView:setTouchEnabled(false)

	--------------------
	-- Craete Friend Rank List
	-- -----------------
	self.friendRankListTableViewRender	= RankListTableViewRender:create(self.rankListCache, RankListCacheRankType.FRIEND,
		rankListItemWidth, rankListItemHeight, self.levelFlag )
	self.friendRankListTableViewRender.owner = self
	-- self.friendRankListTableView		= TableView:create(self.friendRankListTableViewRender, rankListItemWidth, rankListItemHeight * 6.8)
	self.friendRankListTableView		= TableView:create(self.friendRankListTableViewRender, rankListItemWidth, size.height - listSizeHeightDelta)
	--elf.friendRankListTableView:setTouchEnabled(false)
	
	--------------------
	--- Cache Load Initial Data
	---------------------------
	--self.rankListCache:loadInitialData()
	self.rankListCache:loadInitialFriendRank()

	----------------------
	--- Set Rank List Position
	----------------------------
	local rankListTableViewPosX = rankListItemPhPos.x
	local rankListTableViewPosY = rankListItemPhPos.y - self.serverRankListTableView:getViewSize().height
	
	self.serverRankListTableView.basePos = ccp(rankListTableViewPosX - 6, rankListTableViewPosY+3)
	self.serverRankListTableView:setPosition(self.serverRankListTableView.basePos)
	self.ui:addChild(self.serverRankListTableView)

	self.friendRankListTableView.basePos = ccp(rankListTableViewPosX - 6, rankListTableViewPosY +3)
	self.friendRankListTableView:setPosition(self.friendRankListTableView.basePos)

	self.ui:addChild(self.friendRankListTableView)

	-----------------
	-- Initial State
	-- -----------
	self.serverRankListTableView:setVisible(false)

	self:setTableViewTouchEnable(false)

	self.mask_top_right = self.ui:getChildByName('mask_top_right')
	self.mask_top_left = self.ui:getChildByName('mask_top_left')
	self.mask_bottom = self.ui:getChildByName('mask_bottom')
	self.mask_top_right:removeFromParentAndCleanup(false)
	self.ui:addChild(self.mask_top_right)
	self.mask_top_left:removeFromParentAndCleanup(false)
	self.ui:addChild(self.mask_top_left)
	self.mask_bottom:removeFromParentAndCleanup(false)
	self.ui:addChild(self.mask_bottom)

	---------------
	-- Add Event Listener
	-- ------------------
	if self.levelFlag == LevelDiffcultFlag.kExceedinglyDifficult then
		self:setMainBGColorWithData_Purple()
	elseif self.levelFlag == LevelDiffcultFlag.kDiffcult then 
		self:setMainBGColorWithData_Green()
	end
end

function RankList:initFriendRankRefreshBtn(ui)
	local btn = FriendScoreMgr.getInstance():createRefreshButton(ui)
	btn:ad(DisplayEvents.kTouchTap, function ()
		btn:setEnabled(false)
		setTimeOut(function ()
			if self.isDisposed then return end
			btn:setEnabled(true)
		end, 10)
		self.rankListCache:sendGetLevelTopMessage(true)
	end)
	self.friendRankRefreshBtn = btn
end

-- function RankList:showStrategyGuide()
	-- self.ui:runAction(CCCallFunc:create(function ()
	-- 	LevelStrategyManager.getInstance():setGuideShow()
	-- 	local posInWorld = self.strategyBtnRes:getPositionInWorldSpace()
	-- 	local pos = self.panelWithRank.topPanel:convertToNodeSpace(ccp(posInWorld.x, posInWorld.y))
	-- 	local guideTip = ResourceManager:sharedInstance():buildGroup("z_strategy/guideTip")
	-- 	local tip = guideTip:getChildByName("text")
	-- 	tip:setOpacity(0)
	-- 	tip:setPosition(ccp(-240, 195))
	-- 	tip:setString(localize("strategy.playback8", {n = '\n'}))
	-- 	local bg = guideTip:getChildByName("bg")
	-- 	bg:setOpacity(0)
	-- 	self.panelWithRank.topPanel:addChild(guideTip)
	-- 	guideTip:setPosition(ccp(pos.x, pos.y))

	-- 	local arr1 = CCArray:create()
	-- 	arr1:addObject(CCFadeTo:create(0.3, 255))
	-- 	arr1:addObject(CCDelayTime:create(4))
	-- 	arr1:addObject(CCFadeTo:create(0.3, 0))
	-- 	tip:runAction(CCSequence:create(arr1))

	-- 	local arr2 = CCArray:create()
	-- 	arr2:addObject(CCFadeTo:create(0.3, 255))
	-- 	arr2:addObject(CCDelayTime:create(4))
	-- 	arr2:addObject(CCFadeTo:create(0.3, 0))
	-- 	arr2:addObject(CCCallFunc:create(function ()
	-- 		guideTip:removeFromParentAndCleanup(true)
	-- 	end))
	-- 	bg:runAction(CCSequence:create(arr2))
	-- end))
-- end

function RankList:setButtonsEnable(enable)
end

-- Called By PanelWithRankExchangeAnim / PanelWithRankPopRemoveAnim, When This Rank List Is 
-- About To Poping Out
function RankList:prePopoutCallback(...)
	assert(#{...} == 0)

	--self.popouted = true

	--if self.serverRankInitialDataReady then
	--	local oldContentHeight = self.serverRankListTableView:getContentSize().height
	--	local oldContentOffsetX	= self.serverRankListTableView:getContentOffset().x
	--	local oldContentOffsetY = self.serverRankListTableView:getContentOffset().y
	--	self.serverRankListTableView:reloadData()
	--	local newContentHeight = self.serverRankListTableView:getContentSize().height
	--	if newContentHeight == oldContentHeight then
	--		self.serverRankListTableView:setContentOffset(ccp(oldContentOffsetX, oldContentOffsetY))
	--	else
	--		local offset = ccp(oldContentOffsetX, oldContentOffsetY - (newContentHeight - oldContentHeight))
	--		self.serverRankListTableView:setContentOffset(ccp(offset.x, offset.y))
	--	end
	--end
end

function RankList:postPopoutCallback()
	self:setTableViewTouchEnable(true)
	self.popouted = true

	-- local panelId = self:getPanelWithRankId()
	-- local showGuide = false 
	-- if panelId and panelId == 1 then 
	-- 	if LevelStrategyManager.getInstance():shouldShowForceGuide(self.levelId) then
	-- 		showGuide = true 
	-- 		--切到攻略tab
	-- 		self.strategyBtn:onButtonTapped({name = DisplayEvents.kTouchTap, globalPosition = true})

	-- 		--显示引导
	-- 		local posYDelta = self.panelWithRank.rankListExpanY - self.panelWithRank.rankList:getPositionY()

	-- 		local size1 = self.strategyBtn.ui:getGroupBounds().size
	-- 		local parent = self.strategyBtnRes:getParent()
	-- 		local oriPos = self.strategyBtnRes:getPosition()
	-- 		local pos1 = parent:convertToWorldSpace(ccp(oriPos.x, oriPos.y + posYDelta))
	-- 		pos1 = ccp(pos1.x, pos1.y - size1.height)
	-- 		local panPosY1 = pos1.y + 322 + 55

	-- 		local size2 = self.replayStrategyItem.ui:getGroupBounds().size
	-- 		parent = self.replayStrategyItem:getParent()
	-- 		oriPos = self.replayStrategyItem:getPosition()
	-- 		local pos2 = parent:convertToWorldSpace(ccp(oriPos.x, oriPos.y + posYDelta))
	-- 		pos2 = ccp(pos2.x, pos2.y - size2.height + 10)
	-- 		local panPosY2 = pos2.y + 322 + 100

	-- 		GameGuide:sharedInstance():tryLevelStrategyGuide(pos1, size1, panPosY1, pos2, size2, panPosY2)

	-- 		--滚上去
	-- 		self.guideCheckTimer = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function ()
	-- 			self.panelWithRank.allowBackKeyTap = false
	-- 			local data = GameGuideData:sharedInstance()
	-- 			if data:getRunningGuide() then 
	-- 				self.panelWithRank:setRankListPanelTouchDisable()
	-- 			elseif not data:getRunningGuide() then 
	-- 				self.panelWithRank.allowBackKeyTap = true
	-- 				self.panelWithRank:setRankListPanelTouchEnable()
	-- 				if self.guideCheckTimer then 
	-- 					CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.guideCheckTimer)
	-- 					self.guideCheckTimer = nil
	-- 				end
	-- 			end
	-- 		end, 0, false)
	-- 		self.panelWithRank:automaticOpenRanklist()
	-- 	elseif LevelStrategyManager.getInstance():shouldShowGuide(self.levelId) then
	-- 		showGuide = true 
	-- 		self:showStrategyGuide()
	-- 	end
	-- end
	-- if LevelStrategyManager.getInstance():shouldShowStrategy(self.levelId) then 
	-- 	LevelStrategyManager:dcShowStrategyTab(panelId, showGuide, self.levelId)
	-- end
end

function RankList:getPanelWithRankId()
	local panelId 
	if self.panelWithRank and self.panelWithRank.panelName then 
		if self.panelWithRank.panelName == "startGamePanel" then 
			panelId = 0
		elseif self.panelWithRank.panelName == "levelFailPanel" then 
			panelId = 1
		elseif self.panelWithRank.panelName == "levelSuccessPanel" then 
			panelId = 2
		end
	end
	return panelId
end

function RankList:updateNoNetWorkLabel()
	if self.isDisposed then
		return
	end

	if self.serverRankListTableView:isVisible() then
		if self.isServerRankHasData then
			self.noNetworkLabel:setVisible(false)
		else
			self.noNetworkLabel:setString(localize("rank.list.no.network"))
			self.noNetworkLabel:setVisible(true)
		end

		return 
	end

	if self.friendRankListTableView:isVisible() then
		if self.isFriendRankHasData then
			self.noNetworkLabel:setVisible(false)
		else
			self.noNetworkLabel:setString(localize("rank.list.no.network"))
			self.noNetworkLabel:setVisible(true)
		end

		return 
	end

	self.noNetworkLabel:setVisible(false)
end


function RankList:updateWhenDataChange(...)
	assert(#{...} == 0)

	if self.isDisposed then
		return
	end

	-- When Server Rank Is Visible
	if self.serverRankListTableView:isVisible() then
		self:changeLabelToServerRank(true)
	end

	-- Or Friend Rank Is Visibel
	if self.friendRankListTableView:isVisible() then
		self:changeLabelToFriendRank(true)
	end

	self:updateNoNetWorkLabel()
end

function RankList:createLineStar(width, height)
	local textureSprite = Sprite:createWithSpriteFrameName("win_star_shine0000")
	local container = SpriteBatchNode:createWithTexture(textureSprite:getTexture())
	for i = 1, 15 do
		local sprite = Sprite:createWithSpriteFrameName("win_star_shine0000")
		sprite:setPosition(ccp(width*math.random(), height*math.random()))
		sprite:setOpacity(0)
		sprite:setScale(0)
		sprite:runAction(CCRepeatForever:create(CCRotateBy:create(0.1 + math.random()*0.3, 150)))
		local scaleTo = 0.3 + math.random() * 0.8
		local fadeInTime, fadeOutTime = 0.4, 0.4
		local array = CCArray:create()
		array:addObject(CCDelayTime:create(math.random()*0.5))
		array:addObject(CCSpawn:createWithTwoActions(CCFadeIn:create(fadeInTime), CCScaleTo:create(fadeInTime, scaleTo)))
		array:addObject(CCSpawn:createWithTwoActions(CCFadeOut:create(fadeOutTime), CCScaleTo:create(fadeOutTime, 0)))
		sprite:runAction(CCSequence:create(array))
		container:addChild(sprite)
	end
	local function onAnimationFinished() container:removeFromParentAndCleanup(true) end
	container:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(1.3), CCCallFunc:create(onAnimationFinished)))
	textureSprite:dispose()
	return container
end

function RankList:playChangeRankAnim(oldNumber, newNumber, animFinishCallback, playScaleAnim, ...)
	--assert(type(oldNumber) == "number")
	--assert(type(newNumber) == "number")
	assert(false == animFinishCallback or type(animFinishCallback) == "function")
	assert(#{...} == 0)


	if playScaleAnim ~= true then
		playScaleAnim = false
	end

	-- Cur Rank 
	--local oldRank	= UserManager:getInstance().selfOldNumberInFriendRank[self.levelId]
	--local curRank	= UserManager:getInstance().selfNumberInFriendRank[self.levelId]
	
	local oldRank	= oldNumber
	local curRank	= newNumber

	if _G.isLocalDevelopMode then printx(0, "type(oldRank): " .. type(oldRank)) end
	if _G.isLocalDevelopMode then printx(0, "type(curRank): " .. type(curRank)) end
	if _G.isLocalDevelopMode then printx(0, "oldRank: " .. tostring(oldRank)) end
	if _G.isLocalDevelopMode then printx(0, "curRank: " .. tostring(curRank)) end

	self.myRankLabel:setVisible(false)
	self.rankNumLabel:setVisible(false)
	--self.notHaveRankLabel:setVisible(false)
	if self.rankLabelWrapper:numberOfRunningActions() ~= 0 then
		self.rankLabelWrapper:stopAllActions()
	end
	self.rankLabelWrapper:setScale(1)

	-- New Rank Reached
	if curRank ~= oldRank then

		if not oldRank then
			oldRank = curRank
		end

		----------------------------------
		-- Get A New Rank, Create And Play The Anim
		-- -------------------------------------------
		local actionArray 	= CCArray:create()

		-- Enlarge Label
		local enlargeAction

		if playScaleAnim then
			local scaleActionArray = CCArray:create()
			if self.popouted == false then
				scaleActionArray:addObject(CCDelayTime:create(0.6))
			end
			scaleActionArray:addObject(CCScaleTo:create(0.3, 1.5))
			scaleActionArray:addObject(CCScaleTo:create(0.3, 1))
			enlargeAction = CCSequence:create(scaleActionArray)
		else
			--空Action 啥都不做
			enlargeAction = CCDelayTime:create(0.01)
		end

		local easeLargeAction	= CCEaseSineIn:create(enlargeAction)
		local targetEaseLarge	= CCTargetedAction:create(self.rankLabelWrapper.refCocosObj, easeLargeAction)
		actionArray:addObject(targetEaseLarge)

		self.rankNumLabel:setString(tostring(oldRank))

		if curRank < oldRank then
			-- Advance In Rank Play The Anim
			-- Change Rank Label Number
			self.myRankLabel:setVisible(true)
			self.rankNumLabel:setVisible(true)

			for index = oldRank,curRank,-1 do
				-- Delay A Little
				local delay = CCDelayTime:create(0.08)

				-- Change The Rank Number
				local function changeRank()
					self.rankNumLabel:setString(tostring(index))
				end
				local changeRankAction = CCCallFunc:create(changeRank)

				local seq = CCSequence:createWithTwoActions(delay, changeRankAction)
				actionArray:addObject(seq)
			end

			local seq = CCSequence:create(actionArray)

			---------------------------------------
			--- Shining Anim
			---------------------------------------

			local rankLabelWrapperPos	= self.rankLabelWrapper:getPosition()
			local shining = self:createLineStar(274, 55)
			
			shining:setPosition(ccp(rankLabelWrapperPos.x, rankLabelWrapperPos.y))
			self.ui:addChild(shining)

			self.rankLabelWrapper:runAction(seq)
		else
			-- Not Advance In Rank
			if not curRank then
				-- Not Get A Rank
				he_log_warning("hard coded not have a rank text!")
				--self.notHaveRankLabel:setVisible(true)
			else
				self.myRankLabel:setVisible(true)
				self.rankNumLabel:setVisible(true)
				self.rankNumLabel:setString(curRank)
			end
		end
	else
		-- -------------------
		-- Not Get A New Rank
		-- --------------------

		if not curRank then
			-- Not Get A Rank
			--self.notHaveRankLabel:setVisible(true)
		else
			self.myRankLabel:setVisible(true)
			self.rankNumLabel:setVisible(true)
			self.rankNumLabel:setString(curRank)
		end
	end
end

function RankList:onServerBtnTapped()
	--if self.isServerRankHasData then
	if not self.isOnServerBtnTappedCalled then
		self.isOnServerBtnTappedCalled = true

		self.rankListCache:loadInitialServerRank()
	else
	end

	self.serverRankListTableView:setVisible(true)
	self.serverRankListTableView:setPosition(self.serverRankListTableView.basePos)
	self.friendRankListTableView:setVisible(false)
	self.friendRankListTableView:setPositionX(9000)
	self.friendRankRefreshBtn:setVisible(false)

	if self.replayStrategyItem then self.replayStrategyItem:setVisible(false) end

	-- Reset Friend Rank Btn State
	self.friendRankBtn:setToUntappedState()
	-- self.strategyBtn:setToUntappedState()

	-- Show Self Rank
	self:changeLabelToServerRank()

	-- Show Or Hide "Has No NetWork Label"
	self:updateNoNetWorkLabel()
end

function RankList:onFriendBtnTapped()
	self.serverRankListTableView:setVisible(false)
	self.serverRankListTableView:setPositionX(9000)
	self.friendRankListTableView:setVisible(true)
	self.friendRankListTableView:setPosition(self.friendRankListTableView.basePos)
	self.friendRankRefreshBtn:setVisible(true)

	if self.replayStrategyItem then self.replayStrategyItem:setVisible(false) end

	-- Reset Server Rank Btn State
	self.serverRankBtn:setToUntappedState()
	-- self.strategyBtn:setToUntappedState()

	-- Show Self Rank
	self:changeLabelToFriendRank()

	-- Show Or Hide "Has No NetWork Label"
	self:updateNoNetWorkLabel()
end

function RankList:onStrategyBtnTapped()
	self.strategyBtn.notTappedBg:stopAllActions()
	self.strategyBtn.notTappedBg:setOpacity(255)

	self.serverRankListTableView:setVisible(false)
	self.friendRankListTableView:setVisible(false)

	self.friendRankBtn:setToUntappedState()
	self.serverRankBtn:setToUntappedState()

	local panelId = self:getPanelWithRankId()
	LevelStrategyManager:dcClickStrategyTab(panelId, self.levelId)

	LevelStrategyManager.getInstance():getReplayData(self.levelId, function (replayInfo)
		if replayInfo then 
			self.isStrategyHasData = true
			if not self.replayStrategyItem then 
				local StrategyItem = require "zoo.gamePlay.levelStrategy.LevelStrategyListItem"
				self.replayStrategyItem	= StrategyItem:create(ResourceManager:sharedInstance():buildGroup("z_strategy/replay_strategy_item"))
				self.replayStrategyItem:update(replayInfo.name, 0, function ()
					if not LevelStrategyLogic:getReplayBtnEnable() then return end
					self.panelWithRank:remove(function ()
						LevelStrategyManager:dcClickStrategyPlay(panelId, self.levelId)
						LevelStrategyLogic:playReplay(replayInfo.data, function ()

							GamePlayContext:getInstance():endLevel()
							
							local levelType = LevelType:getLevelTypeByLevelId(self.levelId)
							if levelType == GameLevelType.kMainLevel or levelType == GameLevelType.kHiddenLevel then	
								HomeScene:sharedInstance().worldScene:setEnterFromGamePlay(self.levelId, ReplayMode.kStrategy)	
							end
							Director:sharedDirector():popScene()
							ProductItemDiffChangeLogic:endLevel()
							GameInitDiffChangeLogic:endLevel()
							GameInitBuffLogic:endLevel()
							
						end)
						LevelStrategyLogic:setSourcePanelId(panelId)
					end)
				end)

				self.ui:addChild(self.replayStrategyItem)
				self.replayStrategyItem:setPosition(ccp(90, -290))
			else
				self.replayStrategyItem:setVisible(true)
			end
		else
			self.isStrategyHasData = false
		end
		self:updateNoNetWorkLabel()
	end)
end

function RankList:changeLabelToServerRank(playScaleAnim, ...)
	assert(#{...} == 0)
	-- Cur Server Rank
	local oldServerRank = UserManager:getInstance().selfOldNumberInServerRank[self.levelId]
	local curServerRank = UserManager:getInstance().selfNumberInServerRank[self.levelId]

	if _G.isLocalDevelopMode then printx(0, "RankList:changeLabelToServerRank Called !") end

	self:playChangeRankAnim(oldServerRank, curServerRank, false, playScaleAnim)
end

function RankList:changeLabelToFriendRank(playScaleAnim, ...)
	assert(#{...} == 0)

	-- Cur Self Rank In Friend 
	local oldFriendRank = UserManager:getInstance().selfOldNumberInFriendRank[self.levelId]
	local curFriendRank = UserManager:getInstance().selfNumberInFriendRank[self.levelId]

	if _G.isLocalDevelopMode then printx(0, "RankList:changeLabelToFriendRank Called !") end
	if _G.isLocalDevelopMode then printx(0, "oldFriendRank: " .. tostring(oldFriendRank)) end
	if _G.isLocalDevelopMode then printx(0, "curFriendRank: " .. tostring(curFriendRank)) end

	self:playChangeRankAnim(oldFriendRank, curFriendRank, false, playScaleAnim)
end

function RankList:setTableViewTouchEnable(bool, ...)
	assert(type(bool) == "boolean")
	assert(#{...} == 0)

	self.serverRankListTableView:setTouchEnabled(bool)
	self.friendRankListTableView:setTouchEnabled(bool)
end

function RankList:setTableViewBounceable(bounceable, ...)
	assert(type(bounceable) == "boolean")
	assert(#{...} == 0)

	self.serverRankListTableView:setBounceable(bounceable)
	self.friendRankListTableView:setBounceable(bounceable)
end

function RankList:getVisibleRankListTableView(...)
	assert(#{...} == 0)

	local result = false

	if self.friendRankListTableView:isVisible() then
		result = self.friendRankListTableView
	elseif self.serverRankListTableView:isVisible() then
		result = self.serverRankListTableView
	end

	return result
end

function RankList:getScale9Bg(...)
	assert(#{...} == 0)

	return self.scale9Bg
end

function RankList:getRankListItemBg(...)
	assert(#{...} == 0)

	return self.rankListItemBg
end

function RankList:create(levelId, panelWithRank, ...)
	assert(levelId)
	assert(panelWithRank)
	assert(#{...} == 0)

	local newRankList = RankList.new()
	newRankList:init(levelId, panelWithRank)
	return newRankList
end


function RankList:dispose()
	if self.guideCheckTimer then 
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.guideCheckTimer)
		self.guideCheckTimer = nil
	end
	CCSpriteFrameCache:sharedSpriteFrameCache():removeSpriteFramesFromFile(getRealPlistPath("flash/four_star_shine.plist"))
	self.serverRankListTableViewRender:dispose()
	self.friendRankListTableViewRender:dispose()
	BasePanel.dispose(self)
end

function RankList:setMainBGColorWithData_Purple()

	--色度 
	--饱和度
	--亮度
	--对比度

	local p1 = 1
	local p2 = 0
	local p3 = -0.125196
	local p4 = 0.1828137

	local cIdx = 1

	local mainBG = self.ui:getChildByName("scale9Bg"):getChildByName("图层 999")
	if mainBG then
	--	mainBG:adjustColor(1 , 0 , -0.125196 ,0.1828137 )
	--	mainBG:adjustColor(p1,p2,p3,p4)
		cIdx = 1
		mainBG:adjustColor ( _G.LvlFlagColor[cIdx][1] ,_G.LvlFlagColor[cIdx][2] ,_G.LvlFlagColor[cIdx][3] ,_G.LvlFlagColor[cIdx][4] )
		mainBG:applyAdjustColorShader()
	end

	for i = 1 , 12 do
		local line = self.ui:getChildByName("scale9Bg"):getChildByName("图层 "..i)
		if line then
			-- line:adjustColor( 0.8788 , -0.3532 , -0.067917 , -0.067817)
			cIdx = 2
			line:adjustColor  ( _G.LvlFlagColor[cIdx][1] ,_G.LvlFlagColor[cIdx][2] ,_G.LvlFlagColor[cIdx][3] ,_G.LvlFlagColor[cIdx][4] )
			line:applyAdjustColorShader()
		end
	end

	local rankListItemBg = self.ui:getChildByName("rankListItemBg")
	if rankListItemBg then
	--	rankListItemBg:adjustColor( 0.9468 , 0 , -0.1371 , -0.1147)
	--	rankListItemBg:adjustColor(p1,p2,p3,p4)
		cIdx = 1
		rankListItemBg:adjustColor ( _G.LvlFlagColor[cIdx][1] ,_G.LvlFlagColor[cIdx][2] ,_G.LvlFlagColor[cIdx][3] ,_G.LvlFlagColor[cIdx][4] )
		rankListItemBg:applyAdjustColorShader()
	end

	if self.mask_bottom then
	--	self.mask_bottom:adjustColor(1 , 0 , 0.1828137 , -0.125196))
	--	self.mask_bottom:adjustColor(p1,p2,p3,p4)
		cIdx = 1
		self.mask_bottom:adjustColor ( _G.LvlFlagColor[cIdx][1] ,_G.LvlFlagColor[cIdx][2] ,_G.LvlFlagColor[cIdx][3] ,_G.LvlFlagColor[cIdx][4] )
		self.mask_bottom:applyAdjustColorShader()
	--	self.mask_bottom:setOpacity(0)
	end

	if self.mask_top_left then
	--	self.mask_top_left:adjustColor(1 , 0 , 0.1828137 , -0.125196)
	--	self.mask_top_left:adjustColor(p1,p2,p3,p4)
		cIdx = 1
		self.mask_top_left:adjustColor ( _G.LvlFlagColor[cIdx][1] ,_G.LvlFlagColor[cIdx][2] ,_G.LvlFlagColor[cIdx][3] ,_G.LvlFlagColor[cIdx][4] )
		self.mask_top_left:applyAdjustColorShader()
	--	self.mask_top_left:setOpacity(0)
	end

	if self.mask_top_right then
	--	self.mask_top_right:adjustColor(1 , 0 , 0.1828137 , -0.125196)
	--	self.mask_top_right:adjustColor(p1,p2,p3,p4)
		cIdx = 1
		self.mask_top_right:adjustColor ( _G.LvlFlagColor[cIdx][1] ,_G.LvlFlagColor[cIdx][2] ,_G.LvlFlagColor[cIdx][3] ,_G.LvlFlagColor[cIdx][4] )
		self.mask_top_right:applyAdjustColorShader()
	--	self.mask_top_right:setOpacity(0)
		
	end


	if self.friendRankBtn and self.serverRankBtn then

		self.friendRankBtn.notTappedBg:adjustColor( 0.936 , 0.0228 , -0.0117 ,0.0121 )
		self.serverRankBtn.notTappedBg:adjustColor( 0.936 , 0.0228 , -0.0117 ,0.0121 )
		cIdx = 8
		self.friendRankBtn.notTappedBg:adjustColor ( _G.LvlFlagColor[cIdx][1] ,_G.LvlFlagColor[cIdx][2] ,_G.LvlFlagColor[cIdx][3] ,_G.LvlFlagColor[cIdx][4] )
		self.serverRankBtn.notTappedBg:adjustColor ( _G.LvlFlagColor[cIdx][1] ,_G.LvlFlagColor[cIdx][2] ,_G.LvlFlagColor[cIdx][3] ,_G.LvlFlagColor[cIdx][4] )
		

		self.serverRankBtn.tappedBg:adjustColor( 1 , 0 , -0.125196 ,0.1828137 )
		self.friendRankBtn.tappedBg:adjustColor( 1 , 0 , -0.125196 ,0.1828137 )
		cIdx = 9
		self.friendRankBtn.tappedBg:adjustColor ( _G.LvlFlagColor[cIdx][1] ,_G.LvlFlagColor[cIdx][2] ,_G.LvlFlagColor[cIdx][3] ,_G.LvlFlagColor[cIdx][4] )
		self.serverRankBtn.tappedBg:adjustColor ( _G.LvlFlagColor[cIdx][1] ,_G.LvlFlagColor[cIdx][2] ,_G.LvlFlagColor[cIdx][3] ,_G.LvlFlagColor[cIdx][4] )


		self.friendRankBtn.notTappedBg:applyAdjustColorShader()
		self.friendRankBtn.tappedBg:applyAdjustColorShader()
		self.serverRankBtn.notTappedBg:applyAdjustColorShader()
		self.serverRankBtn.tappedBg:applyAdjustColorShader()
	end



	local rankLabelWrapper = self.ui:getChildByName("rankLabelWrapper")
	if rankLabelWrapper then
		local rankNumLabel = rankLabelWrapper:getChildByName("rankNumLabel")
		if rankNumLabel then
			rankNumLabel:setColor((ccc3(93,64,168)))
		end
		local myRankLabel = rankLabelWrapper:getChildByName("myRankLabel")
		if myRankLabel then
			myRankLabel:setColor((ccc3(93,64,168)))
		end
		local notHaveRankLabel = rankLabelWrapper:getChildByName("notHaveRankLabel")
		if notHaveRankLabel then
			notHaveRankLabel:setColor((ccc3(93,64,168)))
		end
	end

end
function RankList:setMainBGColorWithData_Green()

	--色度 
	--饱和度
	--亮度
	--对比度
	--	LevelDiffcultFlag.kExceedinglyDifficult
	local cIdx = 60

	for i = 1 , 12 do
		local line = self.ui:getChildByName("scale9Bg"):getChildByName("图层 "..i)
		if line then
		--	line:adjustColor( 0.4 , 0.2055 , -0.1025 , -0.2624)
			cIdx = 52
			line:adjustColor  ( _G.LvlFlagColor[cIdx][1] ,_G.LvlFlagColor[cIdx][2] ,_G.LvlFlagColor[cIdx][3] ,_G.LvlFlagColor[cIdx][4] )
			line:applyAdjustColorShader()
		end
	end


	local rankLabelWrapper = self.ui:getChildByName("rankLabelWrapper")
	if rankLabelWrapper then
		local rankNumLabel = rankLabelWrapper:getChildByName("rankNumLabel")
		if rankNumLabel then
			rankNumLabel:setColor((ccc3(126,174,82)))
		end
		local myRankLabel = rankLabelWrapper:getChildByName("myRankLabel")
		if myRankLabel then
			myRankLabel:setColor((ccc3(126,174,82)))
		end
		local notHaveRankLabel = rankLabelWrapper:getChildByName("notHaveRankLabel")
		if notHaveRankLabel then
			notHaveRankLabel:setColor((ccc3(126,174,82)))
		end
	end


end