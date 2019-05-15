require "zoo.panel.seasonWeekly.mainPanel.SeasonWeeklyRankingTitle"
require "zoo.panel.seasonWeekly.mainPanel.SeasonWeeklyRankingList"

local SeasonWeeklyRankTab = require "zoo.panel.seasonWeekly.mainPanel.SeasonWeeklyRankTab"
local SeasonWeeklyExtraDescPanel = require "zoo.panel.seasonWeekly.mainPanel.SeasonWeeklyExtraDescPanel"
local extraNumGuide = require "zoo.panel.seasonWeekly.guides.ExtraNum"

local State = {
	kNormal = 1,
	kNoNetwork = 2,
	kNoFriend = 3
}

SeasonWeeklyRankingPart = class(BasePanel)
function SeasonWeeklyRankingPart:create(rootGroupName , resJson, canvas)
	local panel = SeasonWeeklyRankingPart.new()
    if resJson then panel:loadRequiredResource( resJson ) end
    panel:init( rootGroupName, canvas ) 
    return panel
end

-- "2017SummerWeekly/interface/ResRankingPart"
function SeasonWeeklyRankingPart:init( rootGroupName, canvas )
	self.curState = nil
	self.canvas = canvas
	self.ui = self:buildInterfaceGroup( rootGroupName )
	BasePanel.init(self, self.ui)

	--self:initYYB()

	self:initRanking()

	self:setState(State.kNormal)

	local nExtra = SeasonWeeklyRaceManager:getInstance():getExtraNum()
	local nExtraPiecesNum = SeasonWeeklyRaceManager:getInstance():getExtraPiecesNum()

	local context = self
	local lbExtraNum = self.ui:getChildByName("lbExtraNum")
	lbExtraNum:setTouchEnabled(true)
	lbExtraNum:setButtonMode(true)
	lbExtraNum:addEventListener(DisplayEvents.kTouchTap, function()
		DcUtil:UserTrack({category = 'weeklyrace', sub_category = 'weeklyrace_spring_2018_click_added_icon'}, true)
		local panel = SeasonWeeklyExtraDescPanel:create( 
			"ui/panel_spring_weekly.json" , 
			"2017SummerWeekly/interface/ResExtraDesc",
			nExtra,
			nExtraPiecesNum
		)
		panel:popout()

		--[[context:playSurpassAnim(3, 0, function( ... )
			context:updateRanking(true)
		end)--]]
	end)

	local lbN99 = lbExtraNum:getChildByName("n99")
	lbN99:changeFntFile("fnt/profile2018.fnt")
    -- lbN99:setColor(hex2ccc3("FFFF99"))

	lbN99:setScale(1.1)
	lbN99:setAnchorPoint(ccp(0.5, 0))
	lbN99:setPosition(ccp(55, -22))
	lbN99:setText(tostring(nExtra))

	self.lbExtraNum = lbExtraNum
end


function SeasonWeeklyRankingPart:initRanking()

	self.topUI = self.ui:getChildByName('top')
	self.tabUI = self.ui:getChildByName('tab')

	self.tabCtrl = SeasonWeeklyRankTab.new(self.tabUI)
	self.tabCtrl:setState(SeasonWeeklyRankTab.STATE.kLeft)

	self.rankingTitle = SeasonWeeklyRankingTitle:create(self.topUI)

	self.rankingListRect = self.ui:getChildByName("rankingListRect")
	local boundingBox = self.rankingListRect:boundingBox()
	self.rankingListRect:setVisible(false)
	local subZOrder = self.rankingListRect:getZOrder()

	local frameSize = CCDirector:sharedDirector():getOpenGLView():getFrameSize()
	local adjustHeight = frameSize.height/frameSize.width * 720 - 1440 - 20
	local minAdjustHeight = 1280 - 1440 - 20

	if adjustHeight < minAdjustHeight then
		adjustHeight = minAdjustHeight
	end

	local tableViewWidth = boundingBox.size.width
	local tableViewHeight = boundingBox.size.height - 35 + adjustHeight
	local tableViewPos = ccp( boundingBox:getMidX() + 6 , boundingBox:getMidY() - adjustHeight/2 + 15)

	local listSize = {width = tableViewWidth , height = tableViewHeight}

	self.allDayRankList = SeasonWeeklyRankingList:create()
	local render = SeasonWeeklyRankingListRender:create(SeasonWeeklyRankingListRender.RankTypeEnum.kAllRank)
	render:setResBuilder( self , "2017SummerWeekly/interface/ResRankingUnitRender" )
	render:setListSize( listSize )
	
	self.allDayRankList:initList( listSize , render)
	self.allDayRankList:getTableView():setPositionXY( tableViewPos.x , tableViewPos.y )
	self.ui:addChildAt( self.allDayRankList:getTableView(), subZOrder)
	self.ui:runAction(CCCallFunc:create(function()
		local wPos = self.ui:convertToWorldSpace(ccp(self.rankingListRect:getPositionX(), self.rankingListRect:getPositionY() - 25))
		self.allDayRankList:setWY(wPos.y)
    end))

	self.onceTimeRankList = SeasonWeeklyRankingList:create()
	local render = SeasonWeeklyRankingListRender:create(SeasonWeeklyRankingListRender.RankTypeEnum.kOnceRank)
	render:setResBuilder( self , "2017SummerWeekly/interface/ResRankingUnitRender" )
	render:setListSize( listSize )
	
	self.onceTimeRankList:initList( listSize , render)
	self.onceTimeRankList:getTableView():setPositionXY( tableViewPos.x , tableViewPos.y )
	self.ui:addChildAt( self.onceTimeRankList:getTableView(), subZOrder)

	self.addFriend = self.ui:getChildByName("addFriend")
	self.rankTip = self.ui:getChildByName("rankTip")

	self:initAddFriendBlock(self.addFriend)

	self.addFriend:setVisible(false)
	self.rankTip:setVisible(false)
end

function SeasonWeeklyRankingPart:initAddFriendBlock(ui)
	local btn = GroupButtonBase:create(ui:getChildByName('btn'))
	btn:setString(localize('friend.ranking.panel.button.add'))
	btn:ad(DisplayEvents.kTouchTap, function () 
		PushBindingLogic:runPopAddFriendPanelLogic(3)
	end)
	self.addFriendButton = btn
end

function SeasonWeeklyRankingPart:updateRanking(keepOffset)
	if self.isDisposed then return end

	self.allDayRankList:getTableView():setVisible(false)
	self.onceTimeRankList:getTableView():setVisible(false)

	self.addFriend:setVisible(false)
	self.rankTip:setVisible(false)

	local function onRankDataLoadSuccess()
		if self.isDisposed then 
			return
		end
		self.rankTip:setVisible(false)

		self.onceRankData = SeasonWeeklyRaceManager:getInstance().onceRankData
		self.allRankData = SeasonWeeklyRaceManager:getInstance().allRankData

		self.rankingTitle:updateSelf()

		local friendCount = FriendManager:getInstance():getFriendCount()

		if friendCount == 0 then
			self:setState(State.kNoFriend)
		else
			self:setState(State.kNormal, keepOffset)
		end
	end

	local function onRankDataLoadFail()
		if self.isDisposed then
			return 
		end
		self:setState(State.kNoNetwork)
	end

	--self.rankTip:setVisible(false)
	SeasonWeeklyRaceManager:getInstance():getRankData( onRankDataLoadSuccess , onRankDataLoadFail )

	self.rankingTitle:updateSelf()
end

function SeasonWeeklyRankingPart:showSnow( ... )
	if self.isDisposed then return end
	self.canvas:showSnow( ... )
end


function SeasonWeeklyRankingPart:updateRankingWithSurpassAnim()
	if self.isDisposed then return end

	--self.allDayRankList:getTableView():setVisible(false)
	self.onceTimeRankList:getTableView():setVisible(false)

	self.addFriend:setVisible(false)
	self.rankTip:setVisible(false)

	local function onRankRefresh()
		if self.isDisposed then return end
		local friendCount = FriendManager:getInstance():getFriendCount()
		if friendCount == 0 then
			self:setState(State.kNoFriend)
		else
			self:setState(State.kNormal, true)
		end

		if not SeasonWeeklyRaceManager:isFlagSet("ExtraNum") then

			SeasonWeeklyRaceManager:setFlag("ExtraNum", true)
			local guide = extraNumGuide:create()
			self.ui:addChildAt(guide, self.lbExtraNum:getZOrder())
			guide:setCloseCallback(function ( ... )
				self:showSnow(true)
				self.extraNumGuide = nil
			end)
			self:showSnow(false)

			self.extraNumGuide = guide

		-- elseif (not SeasonWeeklyRaceManager:isFlagSet("piecesGuide")) and (not self.extraNumGuide) then

		-- 	SeasonWeeklyRaceManager:setFlag("piecesGuide", true)
		-- 	if not self.canvas then return end
		-- 	if self.canvas.isDisposed then return end
		-- 	self.canvas:playPiecesGuide()

		end
	end

	local lhsRank = -1
	if SeasonWeeklyRaceManager:getInstance().allRankData then
		lhsRank = SeasonWeeklyRaceManager:getInstance().allRankData:getMyRank()
	end

	local function onRankDataLoadSuccess()
		if self.isDisposed then return end
		self.rankTip:setVisible(false)

		self.onceRankData = SeasonWeeklyRaceManager:getInstance().onceRankData
		self.allRankData = SeasonWeeklyRaceManager:getInstance().allRankData

		self.rankingTitle:updateSelf()

		local rhsRank = -1
		if SeasonWeeklyRaceManager:getInstance().allRankData then
			rhsRank = SeasonWeeklyRaceManager:getInstance().allRankData:getMyRank()
		end

		-- 播放超越动画
		self:playSurpassAnim(lhsRank, rhsRank, onRankRefresh)
	end

	local function onRankDataLoadFail()
		if self.isDisposed then
			return 
		end
		self:setState(State.kNoNetwork)
	end

	--self.rankTip:setVisible(false)
	SeasonWeeklyRaceManager:getInstance():getRankData( onRankDataLoadSuccess , onRankDataLoadFail )

	self.rankingTitle:updateSelf()
end

function SeasonWeeklyRankingPart:playSurpassAnim(lhsRank, rhsRank, onFinished)
	local function invokeCbk()
		if self.isDisposed then return end
		self.canvas:lockUI(false)
		if type(onFinished) == "function" then
			onFinished()
		end
	end

	local friendCount = FriendManager:getInstance():getFriendCount()
	if not (rhsRank > 0 and 
			rhsRank < lhsRank and 
			friendCount > 0 and
			self.curState == State.kNormal) then
		return invokeCbk()
	end

	self.canvas:lockUI(true)
	self.tabCtrl:setState(SeasonWeeklyRankTab.STATE.kLeft)

	-- cloneSelf
	local selfItem = self.allDayRankList:cloneItem(lhsRank, rhsRank)
	local wraper = Layer:create()
	wraper:setCascadeOpacityEnabled()
	wraper:addChild(selfItem)
	local sz = selfItem:getGroupBounds().size
	selfItem:setPosition(-sz.width/2, -sz.height/2)
	self:addChild(wraper)

	-- checkLhsView
	self.allDayRankList:makeItemInView(lhsRank)

	-- ori
	local itemOri = self.allDayRankList:getCellItem(lhsRank, true)
	itemOri:setVisible(false)
	local parentL = itemOri:getCocosRefParent()
	if not parentL then return invokeCbk() end
	
	local itemOriPos = parentL:convertToWorldSpace(ccp(itemOri:getPositionX(), itemOri:getPositionY()))
	itemOriPos = self.ui:convertToNodeSpace(itemOriPos)
	wraper:setPosition(ccp(itemOriPos.x + sz.width/2, itemOriPos.y))

	-- dst
	local wTarPos = self.allDayRankList:getWPos(rhsRank)
	local lTarPos = self.ui:convertToNodeSpace(wTarPos)

	local offsetY = self.allDayRankList:getOffsetForItemInView(rhsRank)

	local animDur = 0.6
	local moveTo = CCMoveTo:create(animDur, ccp(lTarPos.x + sz.width/2, lTarPos.y + offsetY + 102 + 10))
	local startMove = CCCallFunc:create(
		function()
			self.allDayRankList:makeItemInViewInDuration(rhsRank, animDur)
		end
	)
	local finish = CCCallFunc:create(
		function()
			wraper:removeFromParentAndCleanup()
			invokeCbk()
		end
	)
	local array = CCArray:create()
	array:addObject(CCScaleTo:create(6/24, 1.3,1.3))
	array:addObject(CCScaleTo:create(5/24, 1.05,1.05))

	array:addObject(CCSpawn:createWithTwoActions(
     	moveTo,
     	startMove
    ))
	array:addObject(CCScaleTo:create(3/24, 1.3, 1.3))
	array:addObject(CCScaleTo:create(3/24, 1, 1))

	array:addObject(CCSpawn:createWithTwoActions(
     	CCCallFunc:create(function()
			selfItem:playEffect()
		end),
     	CCFadeOut:create(23/24)
    ))

	array:addObject(finish)
	local seq = CCSequence:create(array)
	wraper:runAction(seq)
end

function SeasonWeeklyRankingPart:dispose()
	self.allDayRankList:dispose()
	self.onceTimeRankList:dispose()
	BasePanel.dispose(self)
end

function SeasonWeeklyRankingPart:setState(newState, keepOffset)
	self.curState = newState
	if self.curState == State.kNormal then
		self.tabUI:setVisible(true)
		self.topUI:setVisible(true)
		self.addFriend:setVisible(false)
		self.rankTip:setVisible(false)
		self.allDayRankList:getTableView():setVisible(true)
		self.onceTimeRankList:getTableView():setVisible(true)
		self.allDayRankList:updateSelf(keepOffset)
		self.onceTimeRankList:updateSelf()
		self.tabCtrl:rma()
		self.tabCtrl:ad(SeasonWeeklyRankTab.EVENT.kTurnLeft, function ( ... )
			self:turnLeft()
		end)
		self.tabCtrl:ad(SeasonWeeklyRankTab.EVENT.kTurnRight, function ( ... )
			self:turnRight()
		end)
		self.tabCtrl:setState(SeasonWeeklyRankTab.STATE.kLeft)
		self:turnLeft(true, true)
		self.addFriendButton:setEnabled(false)

	elseif self.curState == State.kNoNetwork then
		self.tabUI:setVisible(true)
		self.topUI:setVisible(true)
		self.addFriend:setVisible(false)
		self.rankTip:setVisible(true)
		self.allDayRankList:getTableView():setVisible(false)
		self.onceTimeRankList:getTableView():setVisible(false)
		self.allDayRankList:updateSelf()
		self.onceTimeRankList:updateSelf()
		self.tabCtrl:rma()
		self.tabCtrl:ad(SeasonWeeklyRankTab.EVENT.kTurnLeft, function ( ... )
			self:turnLeft(false)
		end)
		self.tabCtrl:ad(SeasonWeeklyRankTab.EVENT.kTurnRight, function ( ... )
			self:turnRight(false)
		end)
		self.tabCtrl:setState(SeasonWeeklyRankTab.STATE.kLeft)
		self:turnLeft(false)
		self.addFriendButton:setEnabled(false)
	elseif self.curState == State.kNoFriend then
		self.tabUI:setVisible(true)
		self.topUI:setVisible(true)
		self.addFriend:setVisible(true)
		self.rankTip:setVisible(false)
		self.allDayRankList:getTableView():setVisible(false)
		self.onceTimeRankList:getTableView():setVisible(false)
		self.allDayRankList:updateSelf()
		self.onceTimeRankList:updateSelf()
		self.tabCtrl:rma()
		self.tabCtrl:ad(SeasonWeeklyRankTab.EVENT.kTurnLeft, function ( ... )
			self:turnLeft(false)
		end)
		self.tabCtrl:ad(SeasonWeeklyRankTab.EVENT.kTurnRight, function ( ... )
			self:turnRight(false)
		end)
		self.tabCtrl:setState(SeasonWeeklyRankTab.STATE.kLeft)
		self:turnLeft(false)
		self.addFriendButton:setEnabled(true)
	end
end

function SeasonWeeklyRankingPart:turnLeft(showRank, keepOffset)
	if showRank == nil then showRank = true end
	if self.isDisposed then return end

	self.allDayRankList:getTableView():setVisible(true and showRank)
	self.onceTimeRankList:getTableView():setVisible(false and showRank)
	self.rankingTitle:setType(SeasonWeeklyRankingTitle.RankTypeEnum.kAllRank)
	self.rankingTitle:updateSelf()

	if not keepOffset then
		self.allDayRankList:setContentTop()
	end
end

function SeasonWeeklyRankingPart:turnRight( showRank )
	if showRank == nil then showRank = true end
	if self.isDisposed then return end

	self.allDayRankList:getTableView():setVisible(false and showRank)
	self.onceTimeRankList:getTableView():setVisible(true and showRank)
	self.onceTimeRankList:setContentTop()
	self.rankingTitle:setType(SeasonWeeklyRankingTitle.RankTypeEnum.kOnceRank)
	self.rankingTitle:updateSelf()
end