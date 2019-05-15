require "zoo.scenes.component.HomeScene.iconButtons.IconButtonBase"
require "zoo.util.ActivityUtil"
require "zoo.scenes.component.HomeScene.iconButtons.IconButtonManager"

ActivityButton = class(IconButtonBase)

function ActivityButton:ctor( ... )
	self.id = "ActivityButton"
	self.playTipPriority = 1000
end

function ActivityButton:playHasNotificationAnim(...)
	IconButtonManager:getInstance():addPlayTipActivityIcon(self)
end

function ActivityButton:stopHasNotificationAnim(...)
	IconButtonManager:getInstance():removePlayTipActivityIcon(self)
end


function ActivityButton:dispose( ... )
	
	for i,v in ipairs(ActivityUtil.onActivityStatusChangeCallbacks) do
		if v.obj == self and v.func == self.onActivityStatusChange then 
			table.remove(ActivityUtil.onActivityStatusChangeCallbacks,i)
			break
		end
	end
	if self.onUserLogin then
		GlobalEventDispatcher:getInstance():removeEventListener(
			kGlobalEvents.kUserLogin,
			self.onUserLogin
		)
	end


	IconButtonBase.dispose(self)
end
function ActivityButton:init()

	self.ui = ResourceManager:sharedInstance():buildGroup("activityButtonIcon")

	IconButtonBase.init(self, self.ui)

	self.ui:getChildByName("text3"):setVisible(false)

	self.numTip = getRedNumTip()
	self.numTip:setPositionXY(31, 32)
	self.wrapper:addChild(self.numTip)
	
	self.wrapper:setTouchEnabled(true)
	self.wrapper:setButtonMode(true)

	self:setTipPosition(IconButtonBasePos.LEFT)
	self.clickReplaceScene = true
	for _,v in pairs(ActivityUtil:getNoticeActivitys()) do		
		local config = require("activity/"..v.source)
		if config.tips then
			self.tips = config.tips
			self.id = "ActivityButton_" .. v.source
			if not IconButtonManager:getInstance():todayIsShow(self) then
				self:setTipString(self.tips)
			 	self:playHasNotificationAnim()
			 	break
			else
				self.id = "ActivityButton"
				self.tips = nil
			end
	 	end
	end

	self._clicked = false
	self.wrapper:addEventListener(DisplayEvents.kTouchTap, function()
		if PopoutManager:sharedInstance():haveWindowOnScreen() then return end
		-- self.wrapper:setTouchEnabled(false)
		self:runAction(CCCallFunc:create(function( ... )

			if not self._clicked then
				HomeScene:sharedInstance():onIconBtnFinishJob(self)
				self._clicked = true
			end
			Director.sharedDirector():pushScene(ActivityScene:create(),ActivityUtil:getNoticeActivitys())
			-- self.wrapper:setTouchEnabled(true)

			DcUtil:UserTrack({ category="ui",sub_category="click_activity_center_icon" })
		end))
	end)

	self.ui:getChildByName("guang"):setAnchorPoint(ccp(0.5,0.5))
	
	--self.balloon1PosY = self.wrapper:getChildByName("balloon1"):getPositionY()
	--self.balloon2PosY = self.wrapper:getChildByName("balloon2"):getPositionY()

	self:setNewStatus(false)
	self:hideRewardIcon()

	table.insert(ActivityUtil.onActivityStatusChangeCallbacks,{
		obj = self,
		func = self.onActivityStatusChange
	})

	if not _G.kUserLogin then
		self.onUserLogin = function( ... )
			self:onActivityStatusChange()
		end
		GlobalEventDispatcher:getInstance():addEventListener(
			kGlobalEvents.kUserLogin,
			self.onUserLogin
		)
	end

	self:onActivityStatusChange()
end

function ActivityButton:create(...)
	local button = ActivityButton.new()
	button:initShowHideConfig(ManagedIconBtns.ACT_CENTER)
	button:init()
	return button
end

function ActivityButton:setMsgNum( num )
	-- local msgBg = self.wrapper:getChildByName("msgBg")
	-- local msgNum = self.wrapper:getChildByName("msgNum")

	self.msgNum = num
	self.numTip:setNum(num)
end

function ActivityButton:showRewardIcon( ... )
	local rewardIcon = self.wrapper:getChildByName("rewardIcon")

	self.numTip:setVisible(false)

	rewardIcon:setVisible(true)
end

function ActivityButton:hideRewardIcon( ... )

	local rewardIcon = self.wrapper:getChildByName("rewardIcon")

	self:setMsgNum(self.msgNum or 0)
	rewardIcon:setVisible(false)
end

function ActivityButton:setNewStatus(isNew)	
	if self.isNew == isNew then
		return 
	end
	self.isNew = isNew

	local guang = self.ui:getChildByName("guang")
	--local balloon1 = self.wrapper:getChildByName("balloon1")
	--local balloon2 = self.wrapper:getChildByName("balloon2")

	guang:stopAllActions()
	--balloon1:stopAllActions()
	--balloon2:stopAllActions()

	--balloon1:setPositionY(self.balloon1PosY)
	--balloon2:setPositionY(self.balloon2PosY)

	guang:setVisible(false)
	self.ui:getChildByName("text1"):setVisible(false)
	self.ui:getChildByName("text2"):setVisible(true)

	if isNew then 
		-- guang:setScale(1)
		-- guang:runAction(CCRepeatForever:create(CCRotateBy:create(90.0/24.0,360)))

		-- local arr1 = CCArray:createWithCapacity(4)
		-- arr1:addObject(CCDelayTime:create(5.0/24.0))
		-- arr1:addObject(CCMoveBy:create(0,ccp(0,5)))
		-- arr1:addObject(CCDelayTime:create(5.0/24.0))
		-- arr1:addObject(CCMoveBy:create(0,ccp(0,-5)))

		-- balloon1:runAction(CCRepeatForever:create(CCSequence:create(arr1)))

		-- local arr2 = CCArray:createWithCapacity(4)
		-- arr2:addObject(CCDelayTime:create(5.0/24.0))
		-- arr2:addObject(CCMoveBy:create(0,ccp(0,-5)))
		-- arr2:addObject(CCDelayTime:create(5.0/24.0))
		-- arr2:addObject(CCMoveBy:create(0,ccp(0,5)))

		-- balloon2:runAction(CCRepeatForever:create(CCSequence:create(arr2)))

		self:playOnlyIconAnim()
	else
		self:stopOnlyIconAnim()
		-- guang:setScale(0)
	end
end


function ActivityButton:onActivityStatusChange( ... )

	local function getMsgNum( ... )
		local msgNum = 0
		for _,v in pairs(ActivityUtil:getNoticeActivitys()) do
			msgNum = msgNum + ActivityUtil:getMsgNum(v.source)
		end
		return msgNum
	end

	local function hasRewardAcitviy( ... )
		for _,v in pairs(ActivityUtil:getNoticeActivitys()) do
			if ActivityUtil:hasRewardMark(v.source) then 
				return true
			end
		end
		return false
	end

	local function needPlayIconAnim( ... )
		if self.tip then --有tip动画
			return true
		end
		for _,v in pairs(ActivityUtil:getNoticeActivitys()) do
			local config = require("activity/"..v.source)
			if not _G.kUserLogin and config.notLoginPlayIconAnim then
				return true
			elseif ActivityUtil:getMsgNum(v.source) > 0 and v.playIconAnim then
				return true
			elseif ActivityUtil:hasRewardMark(v.source) and v.playIconAnim then
				return true
			end
		end
		return false
	end

	self:setMsgNum(getMsgNum())
	if hasRewardAcitviy() then 
		self:showRewardIcon()
	else
		self:hideRewardIcon()
	end

	if needPlayIconAnim() then
		self:playOnlyIconAnim()
	else
		self:stopOnlyIconAnim()
	end

	-- 
	local function hasNewActivity( ... )
		for _,v in pairs(ActivityUtil:getNoticeActivitys()) do
			if ActivityUtil:getCacheVersion(v.source) == "" then 
				return true
			end
		end
		return false
	end

	self:setNewStatus(hasNewActivity())
end