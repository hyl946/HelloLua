local RankRaceRankItemBase = require "zoo.quarterlyRankRace.component.RankRaceRankItemBase"
local CardPanelGroup = require "zoo.quarterlyRankRace.view.CardPanelGroup"
local RankRaceRankItemGroup = class(RankRaceRankItemBase)

function RankRaceRankItemGroup:init(itemData)
	RankRaceRankItemBase.init(self, itemData)

	local proFlagUI = self.ui:getChildByName("proFlag")
	self.proFlag1 = proFlagUI:getChildByName("1")
	self.proFlag1:setVisible(false)
	self.proFlag2 = proFlagUI:getChildByName("2")
	self.proFlag2:setVisible(false)
end

function RankRaceRankItemGroup:setRankIndex(rankIndex)
	RankRaceRankItemBase.setRankIndex(self, rankIndex)
	local renderState = RankRaceMgr.getInstance():getRankRenderState(1, rankIndex)
	if renderState == 1 then 
		self.proFlag2:setVisible(true)
	elseif renderState == 2 then 
		self.proFlag1:setVisible(true)
	end
end

function RankRaceRankItemGroup:showCardPanel()
	local data = self.itemData.data
	local uid = tostring(data.uid)

	local function showPanel(cardInfo)
		if self.isDisposed then return end
		local panel = CardPanelGroup:create(cardInfo)
	    panel:popout()
	end

	local function onQuerySuccess()
		if self.isDisposed then return end
		local cardInfo = RankRaceMgr.getInstance():getRankCardInfo(1, uid)
		showPanel(cardInfo)
	end

	local function onQueryFail(evt)
		if self.isDisposed then return end
		local errCode = evt.data
		if errCode then
			CommonTip:showTip(localize('error.tip.' .. errCode))
		end
	end
	local cardInfo = RankRaceMgr.getInstance():getRankCardInfo(1, uid)
	if cardInfo then
		showPanel(cardInfo)
	else
		RankRaceMgr.getInstance():queryRankCardInfo(1, uid, onQuerySuccess, onQueryFail)
	end
end

function RankRaceRankItemGroup:showInfoPanel()
	-- if not self.infoPanel then 
	-- 	local data = self.itemData.data
	-- 	local uid = tostring(data.uid)
	-- 	if uid == tostring(UserManager.getInstance().uid) then return end

	-- 	local function showPanel(userInfo)
	-- 		self.infoPanel = self.builder:buildGroup("2018_s1_rank_race/rank_item/rankItemInfo")
	-- 		local levelNum = userInfo.topLevelId
	-- 		if levelNum then 
	-- 			local levelLabel = BitmapText:create('', 'fnt/tutorial_white.fnt')
	-- 	   	 	levelLabel:setRichText("第[#CB6601]"..levelNum.."[/#]关", "934800")
	-- 	   	 	levelLabel:setScale(0.8)
	-- 		    levelLabel:setAnchorPoint(ccp(0, 0))
	-- 		    levelLabel:setPosition(ccp(70, -90))
	-- 		    self.infoPanel:addChild(levelLabel)
	-- 	    end

	-- 	    local starNum = userInfo.star	
	-- 	    local starLabel = BitmapText:create(starNum..'', 'fnt/tutorial_white.fnt')
	-- 	    starLabel:setScale(0.8)
	--    	 	starLabel:setColor(ccc3(203, 102, 1))
	-- 	    starLabel:setAnchorPoint(ccp(0, 0))
	-- 	    starLabel:setPosition(ccp(265, -90))
	-- 	    self.infoPanel:addChild(starLabel)

	-- 	    local achiLevel = Achievement:getLevelByScore(userInfo.achiScore)
	-- 	    local achiLevelStr = localize("achievement.medal.title"..achiLevel)
	-- 	    local achiLabel = BitmapText:create('', 'fnt/tutorial_white.fnt')
	--    	 	achiLabel:setRichText("成就等级:[#CB6601]"..achiLevelStr.."[/#]", "934800")
	--    	 	achiLabel:setScale(0.8)
	-- 	    achiLabel:setAnchorPoint(ccp(1, 0))
	-- 	    achiLabel:setPosition(ccp(585, -90))
	-- 	    self.infoPanel:addChild(achiLabel)

	-- 	    local achiGroupUI = self.infoPanel:getChildByName("achi")
	-- 	    if achiLevel == 1 then
	-- 	    	achiGroupUI:setVisible(false)
	-- 	    	achiLabel:setPosition(ccp(645, -90))
	-- 	    else
	-- 		    for i=1,5 do
	-- 		    	local achiUI = achiGroupUI:getChildByName("lv"..i)
	-- 		    	achiUI:setVisible(achiLevel == i + 1)
	-- 		    end
	-- 		end
	-- 		self.ui:addChildAt(self.infoPanel, 1)
	-- 		self.infoPanel:setPosition(ccp(0, -80))
	-- 		self:setHeight(self:getExpandSize().height)
	-- 		self.parentView.content:onItemHeightChange(self.itemData, self:getExpandSize().height)

	-- 		if self.afterInfoShowCallback then self.afterInfoShowCallback() end
	-- 	end

	-- 	local function onQuerySuccess()
	-- 		if self.isDisposed then return end
	-- 		local userInfo = RankRaceMgr.getInstance():getRankUserInfo(uid)
	-- 		showPanel(userInfo)
	-- 	end

	-- 	local function onQueryFail(evt)
	-- 		if self.isDisposed then return end
	-- 		local errCode = evt.data
	-- 		if errCode then
	-- 			CommonTip:showTip(localize('error.tip.' .. errCode))
	-- 		end
	-- 	end
	-- 	local userInfo = RankRaceMgr.getInstance():getRankUserInfo(uid)
	-- 	if userInfo then
	-- 		showPanel(userInfo)
	-- 	else
	-- 		RankRaceMgr.getInstance():queryRankUserInfo(uid, onQuerySuccess, onQueryFail)
	-- 	end
	-- end
end

function RankRaceRankItemGroup:hideInfoPanel()
	-- if self.infoPanel then
	-- 	self.infoPanel:removeFromParentAndCleanup(true)
	-- 	self.infoPanel = nil
	-- 	self:setHeight(self:getItemOriSize().height)
	-- 	self.parentView.content:onItemHeightChange(self.itemData, self:getItemOriSize().height)

	-- 	if self.afterInfoShowCallback then self.afterInfoShowCallback() end
	-- end
end

function RankRaceRankItemGroup:getExpandSize()
	return {width = 720, height = 200}
end

function RankRaceRankItemGroup:setBeforeInfoShowCallback(callback)
	self.beforeInfoShowCallback = callback
end

function RankRaceRankItemGroup:setAfterInfoShowCallback(callback)
	self.afterInfoShowCallback = callback
end

function RankRaceRankItemGroup:getItemGroupName()
	return "2018_s1_rank_race/rank_item/rankItemRenderGroup"
end

function RankRaceRankItemGroup:dispose()
	RankRaceRankItemBase.dispose(self)
end

function RankRaceRankItemGroup:create(itemData)
	local item = RankRaceRankItemGroup.new()
	item:init(itemData)
	return item
end

return RankRaceRankItemGroup