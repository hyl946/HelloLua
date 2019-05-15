require 'zoo.quarterlyRankRace.RankRaceMgr'

WeeklyRacePromotionPanel = class(BasePanel)

function WeeklyRacePromotionPanel:create(okPressCallback)
	local panel = WeeklyRacePromotionPanel.new()
	panel:init(okPressCallback)
	panel.panelPluginType = "Pendant"
	return panel
end

function WeeklyRacePromotionPanel:init(okPressCallback)

	local resName = 'WeeklyRacePromotionPanel/weeklyrace'

	if (RankRaceMgr:getInstance():isPreHeat() and RankRaceMgr:getInstance():hadLowLevelTag()) or RankRaceMgr:getInstance():isEnabled() then
		resName = 'WeeklyRacePromotionPanel/rankRace'
	end

	self.ui	= ResourceManager:sharedInstance():buildGroup(resName)
	BasePanel.init(self, self.ui)

	local pic = self.ui:getChildByName("pic")
	local touch = Layer:create()
	touch:ignoreAnchorPointForPosition(false)
	touch:setAnchorPoint(ccp(0, 1))
	touch:setContentSize(pic:getContentSize())
	touch:setPositionXY(pic:getPositionX(), pic:getPositionY())
	touch:setTouchEnabled(true)
	touch:addEventListener(DisplayEvents.kTouchTap, function()
		DcUtil:UserTrack({category = "energy", sub_category = "energy_banner_weeklyrace"}, true)

		if RankRaceMgr:getInstance():isEnabled() then
			DcUtil:UserTrack({category = 'weeklyrace2018', sub_category = 'weeklyrace2018_click_energybanner'})
		end

		if okPressCallback then okPressCallback() end
	end)
	self.ui:addChild(touch)
end
