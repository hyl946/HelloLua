require "zoo.scenes.component.HomeScene.iconButtons.IconButtonBase"
require "zoo.common.OneSecondTimer"

local NewLadybugButton = class(IconButtonBase)

function NewLadybugButton:create()
	local button = NewLadybugButton.new()
	button:init()
	button:initShowHideConfig(ManagedIconBtns.NEW_LADYBUG)
	return button
end

function NewLadybugButton:ctor( ... )
end

function NewLadybugButton:playHasNotificationAnim(...)
	IconButtonManager:getInstance():addPlayTipNormalIcon(self)
end
function NewLadybugButton:stopHasNotificationAnim(...)
	IconButtonManager:getInstance():removePlayTipNormalIcon(self)
end

function NewLadybugButton:dispose( ... )
	self:stopClock()
	IconButtonBase.dispose(self)
end

function NewLadybugButton:init( )
	self.idPre = "NewLadybugButton_"
	self.id = self.idPre .. self.tipState

	--self["tip"..IconTipState.kNormal] = ''
	self["tip"..IconTipState.kExtend] = ''
	self["tip"..IconTipState.kReward] = '任务完成，领奖啦~'

	self.leftRegionLayoutBar = true
	self.playTipPriority = 30

    self.ui = ResourceManager:sharedInstance():buildGroup('home_scene_icon/btns/btn_i_ladybug')

	IconButtonBase.init(self, self.ui)

	self:setTipPosition(IconButtonBasePos.RIGHT)

	self.wrapper:addEventListener(DisplayEvents.kTouchTap,function( ... )
		DcUtil:UserTrack({
			category="ladybug",
			sub_category="click_icon" ,
			t1 = 1
		})

		printx(10, "DisplayEvents.kTouchTap  1")

		if PopoutManager:sharedInstance():haveWindowOnScreen() then 
			return 
		end
		printx(10, "DisplayEvents.kTouchTap  2")
		local LadybugDataManager = require 'zoo.panel.newLadybug.LadybugDataManager'
		LadybugDataManager:getInstance():popoutPanel()
	end)

	self.rewardIcon = self:addRedDotReward()
	self.clock = OneSecondTimer:create()
	self.clock:setOneSecondCallback(function ()
		self:refreshState()
	end)
	self:refreshState()

	self.clockStarted = false
	self.rewardIconVisible = true
end

function NewLadybugButton:addToUi()
	local homeScene = HomeScene:sharedInstance()
	homeScene.newLadybugButton = self
	homeScene:addIcon(self)
end

function NewLadybugButton:removeFromUi()
	local homeScene = HomeScene:sharedInstance()
	homeScene:removeIcon(self, true)
end

function NewLadybugButton:setRewarcIconVisible( b )
	self.rewardIconVisible = b
	if b then
		self:refreshState()
	end
end

function NewLadybugButton:refreshState()
	if self.isDisposed then return end
	local LadybugDataManager = require 'zoo.panel.newLadybug.LadybugDataManager'
	local ladybugMgr = LadybugDataManager:getInstance()
	local taskInfo = ladybugMgr:getTaskInfo()

    self:stopHasRewardAni()
    self:stopRedDotJumpAni(self.rewardIcon)

	if ladybugMgr:hadFinishWithoutGetReward(taskInfo) then
		self:setOriLabelVisible(true)
		self:setCustomizedLabel("")
		if ladybugMgr:canGetReward(taskInfo) then
			local hasReward = self.rewardIconVisible == true or self.rewardIcon:isVisible()
			if hasReward then
	            self:playRedDotJumpAni(self.rewardIcon)
	            self:playHasRewardAni()
	        end
	        self.rewardIcon:setVisible(hasReward)
			self.tipState = IconTipState.kReward
			self:setTipString(self["tip"..self.tipState])

			self:playHasNotificationAnim()
			self:stopClock()
		else
			self.rewardIconVisible = false
			self.rewardIcon:setVisible(false)

			self:stopHasNotificationAnim()
			self:startClock()
		end
	else
		self.rewardIconVisible = false
		self.rewardIcon:setVisible(false)

		if ladybugMgr:isValidExtraReward(taskInfo) then
			self:setOriLabelVisible(false)
			local restTime = ladybugMgr:getExtraRewardRestTime(taskInfo)
			--整整24小时的时候，换算玩会成为 00:00:00
			if restTime >= 24*3600*1000 then
				restTime = restTime - 1000
			end
			self:setCustomizedLabel(os.date('%H:%M:%S',  math.floor(restTime/1000) +16*3600))

			self:stopHasNotificationAnim()
			self:startClock()
		else
			self:setOriLabelVisible(true)
			self:setCustomizedLabel('')

			self:stopHasNotificationAnim()
			self:stopClock()
		end
	end
end

function NewLadybugButton:_refreshState()
	if self.isDisposed then return end

	local LadybugDataManager = require 'zoo.panel.newLadybug.LadybugDataManager'
	local ladybugMgr = LadybugDataManager:getInstance()
	local taskInfo = ladybugMgr:getTaskInfo()
	if ladybugMgr:hadFinishWithoutGetReward(taskInfo) then
		if ladybugMgr:canGetReward(taskInfo) then

			self.rewardIcon:setVisible(
				true and (
					self.rewardIconVisible == true or self.rewardIcon:isVisible()
					)
			)

			self.text:setVisible(true)
			self.time:setText('')
			self.tipState = IconTipState.kReward
			self:setTipString(self["tip"..self.tipState])
			self:playHasNotificationAnim()
			self:stopClock()
		else
			self.rewardIconVisible = false
			self.rewardIcon:setVisible(false)
			self.text:setVisible(true)
			self.time:setText('')
			self:stopHasNotificationAnim()
			self:startClock()
		end
	else
		self.rewardIconVisible = false
		self.rewardIcon:setVisible(false)
		if ladybugMgr:isValidExtraReward(taskInfo) then
			self.text:setVisible(false)
			local restTime = ladybugMgr:getExtraRewardRestTime(taskInfo)

			--整整24小时的时候，换算玩会成为 00:00:00
			if restTime >= 24*3600*1000 then
				restTime = restTime - 1000
			end

			self.time:setText(os.date('%H:%M:%S',  math.floor(restTime/1000) +16*3600))
			self:stopHasNotificationAnim()
			self:startClock()
		else
			self.text:setVisible(true)
			self.time:setText('')
			self:stopHasNotificationAnim()
			self:stopClock()
		end
	end
end

function NewLadybugButton:startClock()
	if not self.clockStarted then 
		self.clockStarted = true
		self.clock:start()
	end
end

function NewLadybugButton:stopClock()
	if self.clockStarted then 
		self.clockStarted = false
		self.clock:stop()
	end
end

return NewLadybugButton