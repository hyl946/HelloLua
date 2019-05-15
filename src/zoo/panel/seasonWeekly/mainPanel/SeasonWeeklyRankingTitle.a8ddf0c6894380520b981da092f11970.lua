local OnceRankDataSource = {}
function OnceRankDataSource:getRankData()
	return SeasonWeeklyRaceManager:getInstance().onceRankData
end
function OnceRankDataSource:needNumToGetSurpassReward()
	return SeasonWeeklyRaceManager:getInstance():needNumToGetSurpassReward()
end
function OnceRankDataSource:canGetSurpassReward()
	return SeasonWeeklyRaceManager:getInstance():canGetSurpassReward()
end
function OnceRankDataSource:getRankMinScore()
	return SeasonWeeklyRaceManager:getInstance():getRankMinScore()
end
function OnceRankDataSource:getItemId( ... )

	return SeasonWeeklyRaceConfig:getInstance():getSurpassRewardItemId()

end


local AllRankDataSource = {}
function AllRankDataSource:getRankData()
	return SeasonWeeklyRaceManager:getInstance().allRankData
end
function AllRankDataSource:needNumToGetSurpassReward()
	return SeasonWeeklyRaceManager:getInstance():needNumToGetTotalSurpassReward()
end
function AllRankDataSource:canGetSurpassReward()
	return SeasonWeeklyRaceManager:getInstance():canGetTotalSurpassReward()
end
function AllRankDataSource:getRankMinScore()
	return SeasonWeeklyRaceManager:getInstance():getTotalRankMinScore()
end
function AllRankDataSource:getItemId( ... )

	return SeasonWeeklyRaceConfig:getInstance():getTotalSurpassRewardItemId()
	
end


SeasonWeeklyRankingTitle = class()

SeasonWeeklyRankingTitle.RankTypeEnum = {
	kAllRank = 1,
	kOnceRank = 2,
}

function SeasonWeeklyRankingTitle:create( ui )
	local panel = SeasonWeeklyRankingTitle.new()
    panel:init( ui ) 
    return panel
end

function SeasonWeeklyRankingTitle:init( ui )

	self.curType = nil
	self.dataSource = nil


	self.ui = ui

	self.label_des_1 = self.ui:getChildByName("label_des_1")
	self.label_des_2 = self.ui:getChildByName("label_des_2")
	self.label_des_3 = self.ui:getChildByName("label_des_3")

	self.label_myRank = self.ui:getChildByName("label_myRank")
	self.label_myScore = self.ui:getChildByName("label_myScore")
	
	self.button_rankGift = self.ui:getChildByName("button_rankGift")
	self.icon_target = self.ui:getChildByName("icon_target")


	self.giftTip = self.ui:getChildByName("giftTip")
	self.giftTipLabel = self.giftTip:getChildByName("label_1")
	self.giftTipNum = self.giftTip:getChildByName("label_2")
	self.giftTipIconHolder = self.giftTip:getChildByName('icon')
	self.giftTipIconHolder:setOpacity(0)

	self.giftTipNum:setString("x1")
	self.giftTip:setVisible(false)

	self.button_rankGift:setTouchEnabled(true)
	self.button_rankGift:setButtonMode(true)
	self.button_rankGift:addEventListener(DisplayEvents.kTouchTap, function()
		self:onRankGiftTapped()
	end)

	self.red_icon = self.button_rankGift:getChildByName('icon')
	self.blue_icon = self.button_rankGift:getChildByName('icon2')


	self.label_des_1:setString("我的排名:")
	self.label_des_2:setString("奖励:")
	self.label_des_3:setString("分数:")

	self:setType(SeasonWeeklyRankingTitle.RankTypeEnum.kAllRank)

	-- self.newScoreTip:setVisible(false)

end

function SeasonWeeklyRankingTitle:onRankGiftTapped()
	self:showNumberTip()
end

-- function SeasonWeeklyRankingTitle:playNewScoreAnime()
-- 	self.newScoreTip:setVisible(true)
-- 	self.newScoreTip:setOpacity(0)

-- 	local arr = CCArray:create()
-- 	arr:addObject( CCFadeTo:create( 1 , 255 ) )
-- 	arr:addObject( CCDelayTime:create( 8 ) )
-- 	arr:addObject( CCFadeTo:create( 1 , 0 ) )
-- 	self.newScoreTip:runAction( CCSequence:create( arr ) )
-- end

function SeasonWeeklyRankingTitle:updateSelf()

	if self.isDisposed then return end

	local rankData = self.dataSource:getRankData()
	local matchData = SeasonWeeklyRaceManager:getInstance().matchData

	self.label_myScore:setString(tostring(rankData and rankData:getMyScore() or '0'))

	if matchData.oldLevelMax and matchData.levelMax > matchData.oldLevelMax then
		matchData.oldLevelMax = matchData.levelMax
		-- self:playNewScoreAnime()
	end

	local rank = rankData and rankData:getMyRank()
	if rank == 0 or rank == nil then
		self.label_des_1:setVisible(true)
		self.label_des_2:setVisible(true)
		self.label_myRank:setVisible(true)
		self.button_rankGift:setVisible(true)
		self.label_myRank:setString('未上榜')
	else
		self.label_des_1:setVisible(true)
		self.label_des_2:setVisible(true)
		self.label_myRank:setVisible(true)
		self.label_myRank:setString( tostring(rank) )
		self.button_rankGift:setVisible(true)

	end
end

function SeasonWeeklyRankingTitle:showRankrewardTipPanel( tarView )

	if self.timerId then
		return
	end


	local needMore = self.dataSource:needNumToGetSurpassReward()
	local text = ""
	if self.dataSource:canGetSurpassReward() then
		text = Localization:getInstance():getText("2016_weeklyrace.summer.panel.desc22" ,{n="\n"})
	else
		local minnum = self.dataSource:getRankMinScore()
		text = Localization:getInstance():getText("2016_weeklyrace.summer.panel.desc21" ,{num=needMore , n="\n"})
	end
	
	self.giftTipLabel:setString( text )
	self.giftTip:setVisible(true)


	local itemId = self.dataSource:getItemId()
	local icon = ResourceManager:sharedInstance():buildItemSprite(itemId)

	self.giftTipIconHolder:removeChildren()
	self.giftTipIconHolder:addChild(icon)
	icon:setAnchorPoint(ccp(0, 0))
	icon:setScale(
		self.giftTipIconHolder:getContentSize().width / icon:getContentSize().width
	)
	icon:setPosition(ccp(-5, 7))

	self.timerId = setTimeOut( function () 
		self.timerId = nil
		if self.isDisposed then return end 
		self.giftTip:setVisible(false)
	end , 3)
	

end

function SeasonWeeklyRankingTitle:showNumberTip()
	local rankData = self.dataSource:getRankData()

	if not rankData then 
		return
	end
	
	self:showRankrewardTipPanel( self.button_rankGift )
end

function SeasonWeeklyRankingTitle:setVisible( bVisible )
	self.ui:setVisible(bVisible)
end

function SeasonWeeklyRankingTitle:setType( newType )
	if self.curType ~= newType then

		self:closeTipPanel()

		self.curType = newType
		if self.curType == SeasonWeeklyRankingTitle.RankTypeEnum.kOnceRank then
			self.dataSource = OnceRankDataSource

			if not (self.isDisposed) then
				self.blue_icon:setVisible(false)
				self.red_icon:setVisible(true)

				self.label_des_3:setString('单次:')
			end
		else
			self.dataSource = AllRankDataSource

			if not (self.isDisposed) then

				self.blue_icon:setVisible(true)
				self.red_icon:setVisible(false)

				self.label_des_3:setString('累计:')

			end
		end
	end
end

function SeasonWeeklyRankingTitle:closeTipPanel( ... )
	if self.isDisposed then
		return
	end
	if not self.timerId then
		return
	end

	cancelTimeOut(self.timerId)
	self.timerId = nil
	self.giftTip:setVisible(false)
end