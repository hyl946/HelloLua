require "zoo.scenes.component.HomeScene.iconButtons.IconButtonBase"
require "zoo.util.ActivityUtil"
require "zoo.scenes.component.HomeScene.iconButtons.IconButtonManager"

ActivityCenterButton = class(IconButtonBase)

function ActivityCenterButton:ctor()
	self.id = "ActivityCenterButton"
	self.playTipPriority = 1000
end

function ActivityCenterButton:playHasNotificationAnim()
	IconButtonManager:getInstance():addPlayTipActivityIcon(self)
end

function ActivityCenterButton:stopHasNotificationAnim()
	IconButtonManager:getInstance():removePlayTipActivityIcon(self)
end

function ActivityCenterButton:dispose()
	if self.onUserLogin then
		GlobalEventDispatcher:getInstance():removeEventListener(
			kGlobalEvents.kUserLogin,
			self.onUserLogin
		)
	end
	IconButtonBase.dispose(self)
	Notify:unregister("ActivityIconShowTipEvent", self)
end
function ActivityCenterButton:init()
    self.ui = ResourceManager:sharedInstance():buildGroup('home_scene_icon/btns/btn_i_activity_center')
	IconButtonBase.init(self, self.ui)
	self.numTip = self:addRedDotNum()
	self.rewardIcon = self:addRedDotReward()

	self:setNewStatus(false)
	self:setTipPosition(IconButtonBasePos.LEFT)
	self.clickReplaceScene = true
	self._clicked = false
	self:hideRewardIcon()

	if not _G.kUserLogin then
		self.onUserLogin = function()
			self:onIconStatusChange()
		end
		GlobalEventDispatcher:getInstance():addEventListener(
			kGlobalEvents.kUserLogin,
			self.onUserLogin
		)
	end
	Notify:register("ActivityIconShowTipEvent", self.onShowTip, self)
end

function ActivityCenterButton:handleTouchEventBefore()
	self.targetActId = self.tipId
	self.tipId = nil
end

function ActivityCenterButton:handleTouchEventAfter()
	local targetActId = self.targetActId
	self.targetActId = nil
	if PopoutManager:sharedInstance():haveWindowOnScreen() then return end
	self:runAction(CCCallFunc:create(function( ... )
		if not self._clicked then
			HomeScene:sharedInstance():onIconBtnFinishJob(self)
			self._clicked = true
		end
		ActivityCenter.isForcePop = false
		ActivityCenter:showActivityCenter(targetActId)

		DcUtil:UserTrack({ category="ui",sub_category="click_activity_center_icon" })
	end))
end

function ActivityCenterButton:onShowTip()
	if self.isDisposed then
		Notify:unregister("ActivityIconShowTipEvent", self)
		return
	end
	if self.tipDisabled then
		return
	end

	if self.tipsDataQueue then
		local data = nil

		for id,d in pairs(self.tipsDataQueue) do
			if data == nil
			or (data.hasReward and d.hasReward and data.priority > d.priority)
			or (not data.hasReward and d.hasReward)
			or (not data.hasReward and not d.hasReward and data.msgNum > 0 and d.msgNum > 0 and data.priority > d.priority)
			or (not data.hasReward and not d.hasReward and data.msgNum <= 0 and d.msgNum > 0)
			or (not data.hasReward and not d.hasReward and data.msgNum <= 0 and d.msgNum <= 0 and data.priority > d.priority)
			then
				data = d
			end
		end

		local msgNum = 0
		local hasReward = false
		local datas = ActivityCenter:getVisibleDatas()
		for _,ad in pairs(datas) do
			if ad.icon == nil then
				local hr = ActivityCenter:hasRewardMark(ad)
				local num = ActivityCenter:getMsgNum(ad)
				msgNum = msgNum + num
				if hr then hasReward = true end
			end
		end

		if data then
			if (hasReward and not data.hasReward)
			or (not hasReward and msgNum > 0 and data.msgNum <= 0)
			then
				return
			end

			self.id = data.id
			self.tips = nil
			self.tipId = nil
			if data.hasReward then
				self.tips = data.tipsReward
				self.id = self.id .. "x"
			else
				self.tips = data.tips
			end

			if self.tips then
				self.tipId = data.actName
				self:setTipString(self.tips)
				self.tipsDataQueue[data.id] = nil
				self:playHasNotificationAnim()
				return true
			end
		end
	end
end

function ActivityCenterButton:create()
	local button = ActivityCenterButton.new()
	button:initShowHideConfig(ManagedIconBtns.ACT_CENTER)
	button:init()
	return button
end

function ActivityCenterButton:setMsgNum(num)
	self.msgNum = num
	self.numTip:setNum(num)
end

function ActivityCenterButton:showRewardIcon()
	self.numTip:setVisible(false)
	self.rewardIcon:setVisible(true)
end

function ActivityCenterButton:hideRewardIcon()
	self:setMsgNum(self.msgNum or 0)
	self.rewardIcon:setVisible(false)
end

function ActivityCenterButton:setNewStatus(isNew)	
end


function ActivityCenterButton:onIconStatusChange()
	if self.isDisposed then return end
	local datas = ActivityCenter:getVisibleDatas()

	self.tipsDataQueue = self.tipsDataQueue or {}

	local hasReward = false
	local tips = nil
	local priority = 1000000
	local id = "ActivityCenterButton"

	local function IsShow()
		return IconButtonManager:getInstance():todayIsShow(self)
	end

	local msgNum = 0
	for _,data in pairs(datas) do
		local hr = ActivityCenter:hasRewardMark(data)
		local p = ActivityCenter:getPriority(data)
		local num = ActivityCenter:getMsgNum(data)

		if data.icon == nil then
			if hr then hasReward = true end

			msgNum = msgNum + num
			self.id = "ActivityCenterButton_" .. (data.id or "unkown")

			if ((hasReward and data.tipsReward) or data.tips) and not IsShow() then
				local tipsData = self.tipsDataQueue[self.id]
				if not tipsData 
				or (hr and not tipsData.hasReward)
				or (num > 0 and tipsData.msgNum <= 0)
				then
					self.tipsDataQueue[self.id] = {
						tipsReward = data.tipsReward,
						tips = data.tips,
						hasReward = hr,
						msgNum = num,
						priority = p,
						id = self.id,
						actName = data.id,
					}
				end
			end
		end
	end

	self.id = "ActivityCenterButton"

    self:stopHasNumberAni()
    self:stopHasRewardAni()
    self:stopRedDotJumpAni(self.rewardIcon)

	if hasReward then
		self:showRewardIcon()
		self.numTip:setVisible(false)
        self:playRedDotJumpAni(self.rewardIcon)
        self:playHasRewardAni()
	else
		self:hideRewardIcon()
		self.numTip:setVisible(msgNum > 0)
		if msgNum > 0 then
            self:playHasNumberAni()
        end
	end

	self:setMsgNum(msgNum)

	if (hasReward or msgNum > 0) then
		self:playOnlyIconAnim()
	else
		self:stopOnlyIconAnim()
	end
end