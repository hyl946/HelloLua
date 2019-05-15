require "zoo.mission.panels.MissionPanelLogic"

MissionButton = class(IconButtonBase)

function MissionButton:ctor()
	self.idPre = "MissionButton"
    self.playTipPriority = 40
end

function MissionButton:playHasNotificationAnim(...)
    IconButtonManager:getInstance():addPlayTipNormalIcon(self)
end
function MissionButton:stopHasNotificationAnim(...)
    IconButtonManager:getInstance():removePlayTipNormalIcon(self)
end

function MissionButton:init(iconMode)
	self.tipState = IconTipState.kNormal
	self.id = self.idPre .. self.tipState
	self["tip"..IconTipState.kNormal] = Localization:getInstance():getText("mission.homescene.missionButton.defaultTips")
	self["tip"..IconTipState.kReward] = Localization:getInstance():getText("mission.homescene.missionButton.tips")

	self.ui	= ResourceManager:sharedInstance():buildGroup("missionIcon")

	-- Init Base Class
	IconButtonBase.init(self, self.ui)
	self.isIconMode = iconMode or false
	local userDefault = CCUserDefault:sharedUserDefault()
	local configKey_today = "mission.userconfig.showButtonDefaultTip.today"
	local configKey_isClicked = "mission.userconfig.showButtonDefaultTip.isClicked"
	local today = tostring( os.date("%x", Localhost:timeInSec() ) )

	if not userDefault:getStringForKey(configKey_today) then
		userDefault:setStringForKey(configKey_today, today) 
		userDefault:setBoolForKey(configKey_isClicked, false) 
		userDefault:flush()
	end

	local function onClick()

		if not MissionPanelLogic:checkManga() then
			--MissionPanelLogic:openPanel()
			MissionPanelLogic:tryCreateMission( nil , function () 
				CommonTip:showTip(Localization:getInstance():getText("dis.connect.warning.tips")) 
				end , true )

			DcUtil:missionIconTapped()
		end
		self.rewardIcon:setVisible(false)

		userDefault:setStringForKey(configKey_today, today) 
		userDefault:setBoolForKey(configKey_isClicked, true) 
		userDefault:flush()
	end

	self.wrapper:setTouchEnabled(true, 0, true)
	self.wrapper:addEventListener(DisplayEvents.kTouchTap, onClick)
	self.rewardIcon	= self.wrapper:getChildByName("rewardIcon")
	self.time_text	= self.wrapper:getChildByName("time_text")
	self.button_name	= self.wrapper:getChildByName("button_name")

	local charWidth 	= 35
	local charHeight	= 35
	local charInterval	= 13
	local fntFile		= "fnt/energy_cd.fnt"
	if _G.useTraditionalChineseRes then fntFile = "fnt/zh_tw/energy_cd.fnt" end
	self.time_text = LabelBMMonospaceFont:create(charWidth, charHeight, charInterval, fntFile)
	self:addChild(self.time_text)
	self.time_text:setPositionXY( -8 , -115 )

	if _G.__use_small_res then
		local timeTextPosition = self.time_text:getPosition()
		self.time_text:setPosition( ccp( timeTextPosition.x + 3 , timeTextPosition.y - 5 ) )
		local buttonNamePosition = self.button_name:getPosition()
		self.button_name:setPosition( ccp( buttonNamePosition.x + 5 , buttonNamePosition.y - 10 ) )
	end

	self.time_text:setString("")

	self:tryShowTime( MissionLogic:getInstance():getExpireTime(4) )
	--self:tryShowTime( os.time() + 3600*8 )

	self.rewardIcon:setVisible(false)
	--self:showTip(Localization:getInstance():getText("weeklyrace.summer.panel.tip8"))
	
	if MissionPanelLogic:checkHasFinishedMission() then
		self:showTip(2)
	else
		--if not( userDefault:getStringForKey(configKey_today) == today and userDefault:getBoolForKey(configKey_isClicked) ) then
			
		--end
		self:showTip(1)
	end

	if self.isIconMode then
		--setTimeOut( function () self.wrapper:setPosition(ccp(0,-10)) end , 0.1 )
	end
end

function MissionButton:showTip(tipeType)
	if self.isIconMode then
		return 
	end

	if tipeType == 1 then
		self.tipState = IconTipState.kNormal
		self.rewardIcon:setVisible(false)
	elseif tipeType == 2 then
		self.tipState = IconTipState.kReward
		self.rewardIcon:setVisible(true)
	end

	self.id = self.idPre .. self.tipState
	IconButtonBase.setTipString(self, self["tip"..self.tipState])
    self:setTipPosition(IconButtonBasePos.RIGHT)
    self:playHasNotificationAnim()
    
end

function MissionButton:hideTip()
	self:stopHasNotificationAnim()
	self.rewardIcon:setVisible(false)
end

function MissionButton:tryShowTime(expireTime)
	if self.isIconMode then
		return 
	end

	if expireTime > 9999999999 then
		expireTime = math.floor( expireTime / 1000 )
	end

	if self.timerId then
		TimerUtil.removeAlarm(self.timerId)
		self.timerId = nil
	end

	self.expireTime = expireTime

	self.button_name:setVisible(false)

	self.timerId = TimerUtil.addAlarm(function () self:onTimer() end , 1 , 0 )
	self:onTimer()
end

function MissionButton:onTimer()

	local time = self.expireTime - Localhost:timeInSec()

	if time > 0 then
		self.time_text:setVisible(true)
		self.button_name:setVisible(false)
		self.time_text:setString( convertSecondToHHMMSSFormat( time ) )
	else
		self:hideTime()
	end
end

function MissionButton:hideTime()
	self.time_text:setString("")
	self.time_text:setVisible(false)
	self.button_name:setVisible(true)
	self.expireTime = 0

	if self.timerId then
		TimerUtil.removeAlarm(self.timerId)
		self.timerId = nil
	end
end

function MissionButton:create(iconMode)

	local button = MissionButton.new()
	button:init(iconMode)
	return button
end