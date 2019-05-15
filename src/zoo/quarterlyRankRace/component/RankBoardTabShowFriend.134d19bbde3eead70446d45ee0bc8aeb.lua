local RankBoardTabShow = require "zoo.quarterlyRankRace.component.RankBoardTabShow"
local RankRaceRankItemFriend = require "zoo.quarterlyRankRace.component.RankRaceRankItemFriend"

local RankBoardTabShowFriend = class(RankBoardTabShow)

function RankBoardTabShowFriend:ctor()
	self.className = "RankBoardTabShowFriend"
end

function RankBoardTabShowFriend:init(ui, showWidth, showHeight)
	RankBoardTabShow.init(self, ui, showWidth, showHeight)

	self.addFriendUI = ui:getChildByName("addFriend")
    self.addFriendUI:setVisible(false)

    local btn = GroupButtonBase:create(self.addFriendUI:getChildByName('btn'))
	btn:setString(localize('friend.ranking.panel.button.add'))
	btn:ad(DisplayEvents.kTouchTap, function () 
		PushBindingLogic:runPopAddFriendPanelLogic(3)
	end)
	self.addFriendButton = btn
end

function RankBoardTabShowFriend:buildItemContainer(viewWidth, viewHeight)
	local context = self

	local LayoutRender = class(DynamicLoadLayoutRender)
	function LayoutRender:getColumnNum()
		return 1
	end
	function LayoutRender:getItemSize()
		return RankRaceRankItemFriend:getItemOriSize()
	end
	function LayoutRender:getVisibleHeight()
		return viewHeight
	end
	function LayoutRender:buildItemView(itemData, index)
		local item = nil
		item = RankRaceRankItemFriend:create(itemData)
		item:setParentView(context.rankView)
		item:setRankIndex(index)
		
		return item
	end

	function LayoutRender:onItemViewDidAdd(itemView, itemData)
		itemView:update()
	end

	local layout = DynamicLoadLayout:create(LayoutRender.new())
  	layout:setPosition(ccp(0, 0))
  	return layout
end

function RankBoardTabShowFriend:setSelect(isSelected)
	RankBoardTabShow.setSelect(self, isSelected)
	if isSelected then 
		if FriendManager.getInstance():getFriendCount() == 0 then 
			self.addFriendButton:setEnabled(true)
		end
	else
		self.addFriendButton:setEnabled(false)
	end
end

--override
function RankBoardTabShowFriend:getItemRender(index, isSpecial)
	local function frameCacheCheck()
		if not CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName("2018_s1_rank_race/rank_item/cells/rankListBg10000") then
			SpriteUtil:removeLoadedPlist("ui/RankRace/MainPanel.plist")
			return false
		end
		return true
	end
	if not frameCacheCheck() or not self.builder then 
		self.builder = InterfaceBuilder:createWithContentsOfFile("ui/RankRace/MainPanel.json")
	end
	return self.builder:buildGroup("2018_s1_rank_race/rank_item/rankItemRenderFriend")
end

--override
function RankBoardTabShowFriend:requestRankData(considerCD, callback)
	self.itemContainer:removeAllItems()

	if FriendManager.getInstance():getFriendCount() == 0 then 
		self.addFriendUI:setVisible(true)
		self.addFriendButton:setEnabled(true)

		if callback then callback() end
	else
		self.addFriendUI:setVisible(false)
		self.addFriendButton:setEnabled(false)

		local function onSuccess(rankData, myRank)
			if self.isDisposed or self.ui.isDisposed then return end
	        self.rankData = rankData or {}
	        -- self:refresh()
	        if callback then callback() end
		end

		local function onFail(errorCode)
			if self.isDisposed or self.ui.isDisposed then return end
			if errorCode and errorCode == -1012 then 
				CommonTip:showTip(localize("rank.race.main.3"), "negative")
			else
		        local scene = Director:sharedDirector():getRunningScene()
		        if scene ~= nil and scene:is(HomeScene) then
		            if errorCode and type(errorCode) == "number" then
		                CommonTip:showTip(localize("error.tip." .. errorCode), "negative")
		            else
		                CommonTip:showTip(localize("rank.race.weak.netconnect"), "negative")
		            end
		        end
		        local targetCount = RankRaceMgr.getInstance():getData():getTC0()
		        local userMgr = UserManager:getInstance()
		        self.rankData = {{score = targetCount, uid = userMgr.uid, name = userMgr.profile.name, headUrl = userMgr.profile.headUrl}}
		        -- self:refresh()
			end
			if callback then callback() end
		end

		local function onCancel()
			if self.isDisposed or self.ui.isDisposed then return end
		end
		RankRaceMgr.getInstance():getRankListFriend(considerCD, onSuccess, onFail, onCancel)
	end
end

function RankBoardTabShowFriend:create(ui, showWidth, showHeight)
	local show = RankBoardTabShowFriend.new()
	show:init(ui, showWidth, showHeight)
	return show
end

return RankBoardTabShowFriend