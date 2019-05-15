require "zoo.panel.seasonWeekly.mainPanel.SeasonWeeklyRaceSimpleRulePanel"
require "zoo.gamePlay.GamePlayContext"

SeasonWeeklyTopInfoPart = class(BasePanel)
function SeasonWeeklyTopInfoPart:create(rootGroupName , resJson)
	local panel = SeasonWeeklyTopInfoPart.new()
    if resJson then panel:loadRequiredResource( resJson ) end
    panel:init( rootGroupName ) 
    return panel
end

function SeasonWeeklyTopInfoPart:init( rootGroupName )
	self.ui = self:buildInterfaceGroup( rootGroupName )
	BasePanel.init(self, self.ui)

	self:initTopInfo()
end

function SeasonWeeklyTopInfoPart:initTopInfo(  )
	local descIcon = self.ui:getChildByName("wenhaoIcon")
	descIcon:setTouchEnabled(true)
	descIcon:setButtonMode(true)
	descIcon:addEventListener(DisplayEvents.kTouchTap, function()
		DcUtil:UserTrack({category = 'weeklyrace', sub_category = 'weeklyrace_spring_2018_click_info'}, true)
		local panel = SeasonWeeklyRaceSimpleRulePanel:create( 
			"ui/panel_spring_weekly.json" , 
			"2017SummerWeekly/interface/ResRulePanel"
		)
		panel:popout()
	end)

	self.descLabel = self.ui:getChildByName("topInfo_label")

end

function SeasonWeeklyTopInfoPart:autoRefreshTopInfoLabel()

	if self.timerId then
		TimerUtil.removeAlarm(self.timerId)
		self.timerId = nil
	end

	if self.isDisposed then 
		return 
	end

	local function leftTimeEqual(t1,t2)
		if not t1 or not t2 then 
			return false
		end

		return t1.leftDay == t2.leftDay 
			and t1.leftHour == t2.leftHour 
			and t1.leftMinute == t2.leftMinute
	end

	--self.descLabel:stopAllActions()

	local function onTimer()
		if self.isDisposed then 
			if self.timerId then
				TimerUtil.removeAlarm(self.timerId)
				self.timerId = nil
			end
			return 
		end

		local leftTimeData = SeasonWeeklyRaceManager:getInstance():getLeftTime()

		if self.leftTimeData and self.leftTimeData.leftDay ~= leftTimeData.leftDay then 
			
			local hasWeekChanged = (self.leftTimeData.leftDay == 0)
			self.leftTimeData = nil

			--_self.refreshAll(hasWeekChanged)
			if GamePlayContext:getInstance().levelInfo 
				and GamePlayContext:getInstance().levelInfo.levelId 
				and GamePlayContext:getInstance().levelInfo.levelId == 0 then
				--GamePlayContext的重置逻辑已改，这里或许会有问题
				SeasonWeeklyRaceManager:getInstance():onDataChanged( {top = true , button = true , rewards = true} )

				if hasWeekChanged then
					SeasonWeeklyRaceManager:getInstance():onDataChanged( {ranking = true} )
				end
			end
		
			return
		end

		if not leftTimeEqual( leftTimeData ,self.leftTimeData ) then
			self.descLabel:setString(Localization:getInstance():getText("2016_weeklyrace.summer.panel.desc1",{
				num = leftTimeData.leftDay,
				num1 = leftTimeData.leftHour,
				num2 = leftTimeData.leftMinute
			}))
			self.leftTimeData = leftTimeData
		end
	end


	self.timerId = TimerUtil.addAlarm( onTimer , 1 , 0 )

	onTimer()
end