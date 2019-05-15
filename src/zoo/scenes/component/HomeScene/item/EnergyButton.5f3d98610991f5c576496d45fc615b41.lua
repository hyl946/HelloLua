
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年09月 1日 20:09:02
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

require "zoo.scenes.component.HomeScene.item.HomeSceneBubbleItem"
require "zoo.scenes.component.HomeScene.item.HomeSceneItemProgressBar"

---------------------------------------------------
-------------- EnergyButton
---------------------------------------------------

assert(not EnergyButton)

EnergyButton = class(BaseUI)

function EnergyButton:init( belongScene )
	-- -------------
	-- Get UI Resource
	-- ---------------
	self.ui			= ResourceManager:sharedInstance():buildGroup("newEnergyButton")

	-- ---------------
	-- Init Base Class
	-- ----------------
	--CloudButton.init(self, self.ui)
	BaseUI.init(self, self.ui)

	----------------
	---- Data
	----------------
	self.onTappedCallback	= false

	self.curEnergy		= 0
	--self.totalEnergy	= 30
	self.totalEnergy	= UserEnergyRecoverManager:sharedInstance():getMaxEnergy()

	self.sepChar		= "/"
	-- he_log_warning("Note: EnergyButton Total Energy Is Hard Coded 30 !")

	-- Displayed 
	self.displayedCurEnergy		= false
	self.displayedTotalEnergy	= false

	self.SHOW_ENERGY_STATE_INFINITE			= 1
	self.SHOW_ENERGY_STATE_COUNTDOWN_TO_RECOVER	= 2
	self.showEnergyState				= self.ENERGY_STATE_COUNTDOWN_TO_RECOVER

	--------------
	-- Get UI Resource
	-- -----------------
	self.blueBubbleItemRes	= self.ui:getChildByName("bubbleItem")
	self.progressBarRes	= self.ui:getChildByName("progressBar")
	self.leftTimeLabelPlaceholder	= self.ui:getChildByName("leftTimeLabel")
	self.numeratorPlaceholder	= self.ui:getChildByName("numerator")
	self.separatorPlaceholder	= self.ui:getChildByName("separator")
	self.denominatorPlaceholder	= self.ui:getChildByName("denominator")

	self.energyIcon			= self.blueBubbleItemRes:getChildByName("placeHolder")

	assert(self.energyIcon)

	assert(self.blueBubbleItemRes)
	assert(self.progressBarRes)
	assert(self.leftTimeLabelPlaceholder)

	assert(self.numeratorPlaceholder)
	assert(self.separatorPlaceholder)
	assert(self.denominatorPlaceholder)

	--------------------------------
	-- Get Data About UI Component
	-- ----------------------------
	self.numeratorPhPos	= self.numeratorPlaceholder:getPosition()
	self.separatorPhPos	= self.separatorPlaceholder:getPosition()
	self.denominatorPhPos	= self.denominatorPlaceholder:getPosition()

	self.numeratorPhSize	= self.numeratorPlaceholder:getPreferredSize()
	self.separatorPhSize	= self.separatorPlaceholder:getPreferredSize()
	self.denominatorPhSize	= self.denominatorPlaceholder:getPreferredSize()

	self.uiSize	= self.ui:getGroupBounds().size
	self.uiSize	= {width = self.uiSize.width, height = self.uiSize.height}
	self.uiWidth	= self.uiSize.width
	self.uiHeight	= self.uiSize.height

	----------------------
	-- Init UI Component
	-- -----------------
	--self.progressLabel:setVisible(false)
	self.leftTimeLabelPlaceholder:setVisible(false)

	self.numeratorPlaceholder:setVisible(false)
	self.separatorPlaceholder:setVisible(false)
	self.denominatorPlaceholder:setVisible(false)

	------------
	--- Init UI
	------------
	
	-- Scale Small
	local config 	= UIConfigManager:sharedInstance():getConfig()
	local uiScale	= config.homeScene_uiScale
	self:setScale(uiScale)

	-------------------
	-- Create UI Component
	-- ---------------------
	self.bubbleItem		= HomeSceneBubbleItem:create(self.blueBubbleItemRes)

	-- Clipping The Bubble
	local stencil		= LayerColor:create()
	stencil:setColor(ccc3(255,0,0))
	stencil:changeWidthAndHeight(132, 73.35 + 30)
	stencil:setPosition(ccp(0, -73.35))
	local cppClipping	= CCClippingNode:create(stencil.refCocosObj)
	local luaClipping	= ClippingNode.new(cppClipping)
	stencil:dispose()
	
	self.ui:addChild(luaClipping)
	self.bubbleItem:removeFromParentAndCleanup(false)
	luaClipping:addChild(self.bubbleItem)
	
	self.progressBar	= HomeSceneItemProgressBar:create(self.progressBarRes,
								self.curEnergy,
								self.totalEnergy)

	-- Create Monospace Label
	local numeratorCharWidth	= 35
	local numeratorCharHeight	= 35
	local numeratorCharInterval	= 18

	local separatorCharWidth	= 20
	local separatorCharHeight	= 20
	local separatorCharInterval	= 10

	local denominatorCharWidth	= 25
	local denominatorCharHeight	= 25
	local denominatorCharInterval	= 14

	local fntFile			= "fnt/hud.fnt"

	self.numerator		= LabelBMMonospaceFont:create(numeratorCharWidth, numeratorCharHeight, numeratorCharInterval, fntFile)
	self.separator		= LabelBMMonospaceFont:create(separatorCharWidth, separatorCharHeight, separatorCharInterval, fntFile)
	self.denominator	= LabelBMMonospaceFont:create(denominatorCharWidth, denominatorCharHeight, denominatorCharInterval, fntFile)

	self.separator:setString("/")

	self.numerator:setAnchorPoint(ccp(0,1))
	self.separator:setAnchorPoint(ccp(0,1))
	self.denominator:setAnchorPoint(ccp(0,1))

	self.numerator:setPosition(ccp(self.numeratorPhPos.x, self.numeratorPhPos.y))
	self.separator:setPosition(ccp(self.separatorPhPos.x, self.separatorPhPos.y))
	self.denominator:setPosition(ccp(self.denominatorPhPos.x, self.denominatorPhPos.y))

	self.ui:addChild(self.numerator)
	self.ui:addChild(self.separator)
	self.ui:addChild(self.denominator)

	-- Create Left Time Label
	-- Create Mono Space Label To Replace The monospace Label
	local charWidth		= 30 -- 15
	local charHeight	= 30
	local charInterval	= 15
	local fntFile		= "fnt/energy_cd.fnt"
	if _G.useTraditionalChineseRes then fntFile = "fnt/zh_tw/energy_cd.fnt" end
	self.leftTimeLabel	= LabelBMMonospaceFont:create(charWidth, charHeight, charInterval, fntFile)
	self.leftTimeLabel:setAnchorPoint(ccp(0,1))

	local placeholderPos	= self.leftTimeLabelPlaceholder:getPosition()

	self.leftTimeLabel:setPositionX(0)
	self.leftTimeLabel:setPositionY(placeholderPos.y)

	self.ui:addChild(self.leftTimeLabel)

	---------------
	--- Update View
	-------------
	self.userRef	= UserManager.getInstance().user
	self:setCurEnergy(self.userRef:getEnergy())
	self:updateView()

	------------
	-- Get Txt
	-- ---------
	local energyLeftTimeTxtKey 	= "energy.bubble" 
	local energyLeftTimeTxtValue	= Localization:getInstance():getText(energyLeftTimeTxtKey, {time = ""})
	self.energyLeftTimeTxtValue	= energyLeftTimeTxtValue



	--------------------------------------
	-- Add Scheduler To Check Data Change
	--------------------------------------
	local function perFrameCallback()
		self:perFrameCheckEnergyChange()
	end
	self.perFrameScheduleId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(perFrameCallback, 1/60, false)

	if belongScene then
		-- Add Event Listener Dispatched From Home Scene
		local function onHomeSceneDispatchEnergyChange()
			self:onHomeSceneDispatchEnergyChange()
		end
		belongScene:addEventListener(HomeSceneEvents.USERMANAGER_ENERGY_CHANGE, onHomeSceneDispatchEnergyChange)

		----------------------
		-- Add Event Listener For UserEnergyRecoverManager,
		-- When Count Down TIme Reached, Update The Energy Number
		-- --------------------------------------------------
		
		local function onUserRecoverManagerCountDownReached()
			if _G.isLocalDevelopMode then printx(0, "EnergyButton:onUserRecoverManagerCountDownReached Called !") end
			local curEnergy = UserManager.getInstance().user:getEnergy()
			self:setCurEnergy(curEnergy)
			self:updateView()
		end
		UserEnergyRecoverManager:sharedInstance():addEventListener(UserEnergyRecoverManagerEvents.COUNT_DOWN_TIMER_REACHED, 
							onUserRecoverManagerCountDownReached)
	end
	-- BUG fix: larger hit area while infinite energy state
	local size = self.ui:getGroupBounds().size
	size = {width = size.width, height = size.height}
	self.ui.hitTestPoint = function (uiSelfRef, worldPosition, useGroupTest)
		local position = self:getPosition()
		local wPosition = self:getParent():convertToWorldSpace(ccp(position.x, position.y))
		return worldPosition.x > wPosition.x and worldPosition.x < wPosition.x + size.width and
			worldPosition.y > wPosition.y - size.height and worldPosition.y < wPosition.y
	end

	-----------------
	-- Add Event Listener
	-- -------------------
	local function onTapped(event)
		self:onTapped(event)
	end

	self.ui:setTouchEnabled(true, 0, true)
	self.ui:addEventListener(DisplayEvents.kTouchTap, onTapped)
end

function EnergyButton:dispose( ... )
 	CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.perFrameScheduleId)
	
	BaseUI.dispose(self)
end

function EnergyButton:onHomeSceneDispatchEnergyChange(...)
	assert(#{...} == 0)
	if _G.isLocalDevelopMode then printx(0, "EnergyButton:onHomeSceneDispatchEnergyChange Called !") end

	self.userRef	= UserManager.getInstance().user
	self:setCurEnergy(self.userRef:getEnergy())
	--self:updateView()
end

function EnergyButton:perFrameCheckEnergyChange(...)
	assert(#{...} == 0)

	-- Check Energy State
	local energyState = UserEnergyRecoverManager:sharedInstance():getEnergyState()
	if self.showTempEnergyState then
		energyState = self.showTempEnergyState
	end

	if energyState == UserEnergyState.INFINITE then
		self:changeToShowEnergyStateInfinite()

		local secondToWait = UserEnergyRecoverManager:sharedInstance():getCountdownSecondRemain()
		self:setInfiniteEnergyStateRemainTime(secondToWait)

	elseif energyState == UserEnergyState.COUNT_DOWN_TO_RECOVER then

		self:changeToShowEnergyStateCountdownToRecover()

		self:setCurEnergy(UserManager.getInstance().user:getEnergy())

		-- Get Max Energy
		local maxEnergy = UserEnergyRecoverManager:sharedInstance():getMaxEnergy()
		self:setTotalEnergy(maxEnergy)

		local secondToWait = UserEnergyRecoverManager:sharedInstance():getCountdownSecondRemain()

		--self:updateView()
		if 1 == secondToWait then
			self:updateView()
		end

		self:setLeftSecondToRecover(secondToWait)
	else
		if _G.isLocalDevelopMode then printx(0, "energyState: " .. energyState) end
		assert(false)
	end
end

function EnergyButton:positionLabel(...)
	assert(#{...} == 0)

	local numeratorSize = self.numerator:getContentSize()

	self.numerator:setPositionX(self.numeratorPhPos.x +  self.numeratorPhSize.width - numeratorSize.width)
	self.numerator:setPositionY(self.numeratorPhPos.y)

	self.separator:setPositionX(self.separatorPhPos.x) 
	self.separator:setPositionY(self.separatorPhPos.y)

	self.denominator:setPositionX(self.denominatorPhPos.x)
	self.denominator:setPositionY(self.denominatorPhPos.y)


	-- Manual Adjust Pos
	local manualAdjustNumeratorPosX = -2
	local manualAdjustNumeratorPosY = -4

	local manualAdjustSeparatorPosX = -14	-- Change This
	local manualAdjustSeparatorPosY = -16
	local manualAdjustDenominatorPosX = -16
	local manualAdjustDenominatorPosY = -13	-- Change This

	local curNumeratorPos 	= self.numerator:getPosition()
	local curSeparatorPos 	= self.separator:getPosition()
	local curDenominatorPos	= self.denominator:getPosition()

	self.numerator:setPosition(ccp(curNumeratorPos.x + manualAdjustNumeratorPosX, curNumeratorPos.y + manualAdjustNumeratorPosY))
	self.separator:setPosition(ccp(curSeparatorPos.x + manualAdjustSeparatorPosX, curSeparatorPos.y + manualAdjustSeparatorPosY))
	self.denominator:setPosition(ccp(curDenominatorPos.x + manualAdjustDenominatorPosX, curDenominatorPos.y + manualAdjustDenominatorPosY))
end

function EnergyButton:getIconRes(...)
	assert(#{...} == 0)

	return self.bubbleItem:getItemRes()
end

function EnergyButton:onTapped(event, ...)
	assert(#{...} == 0)

	-- dispose the tip first
	self:disposeTip()

	if self.onTappedCallback then
		self.onTappedCallback()
	end
end

function EnergyButton:setOnTappedCallback(onTappedCallback, ...)
	assert(type(onTappedCallback) == "function")
	assert(#{...} == 0)

	self.onTappedCallback = onTappedCallback
end

function EnergyButton:setLeftSecondToRecover(leftSecond, ...)
	assert(type(leftSecond) == "number")
	assert(#{...} == 0)

	if leftSecond == 0 then
		-- Energy Is Full
		self.leftTimeLabel:setString("")
	else
		-- Energy Is Not Full
		-- Seconds To Recover
		local minuteFormat = self:convertSecondToMinuteFormat(leftSecond)

		if self.displayedMinute ~= minuteFormat then
			self.displayedMinute = minuteFormat
			local minuteTxt = tostring(minuteFormat) 
			
			if leftSecond < 0 then

				-- Bug
			else
				self.leftTimeLabel:setString( minuteTxt .. self.energyLeftTimeTxtValue)
				self:positionLeftTimeLabel()
			end
		end
	end
end

function EnergyButton:setInfiniteEnergyStateRemainTime(leftSecond, ...)
	assert(type(leftSecond) == "number")
	assert(#{...} == 0)

	if leftSecond == 0 then
		self.leftTimeLabel:setString("")
	else
		local hourFormat	= self:convertSecondToHourFormat(leftSecond)

		if self.displayedMinute ~= hourFormat then
			self.displayedMinute = hourFormat

			local minuteTxt = tostring(hourFormat)

			if leftSecond < 0 then

			else
				self.leftTimeLabel:setString(minuteTxt)
				self:positionLeftTimeLabel()
			end
		end
	end
end

function EnergyButton:positionLeftTimeLabel(...)
	assert(#{...} == 0)

	local labelSize = self.leftTimeLabel:getContentSize()

	--local deltaWidth = self.uiSize.width - labelSize.width
	local deltaWidth	= self.uiWidth - labelSize.width
	local halfDeltaWidth = deltaWidth / 2

	local manualAdjustPosX		= 0

	self.leftTimeLabel:setPositionX(halfDeltaWidth + manualAdjustPosX)
end

function EnergyButton:convertSecondToMinuteFormat(second, ...)
	assert(type(second) == "number")
	assert(#{...} == 0)

	local separator = ":"
	local minute		= math.floor(second / 60)
	local remainSecond	= second - minute * 60

	--local hour 		= math.floor(minute / 60)
	--local remainMinute	= minute - hour * 60

	
	local secondString = false
	if remainSecond < 10 then
		secondString = "0" .. tostring(remainSecond)
	else
		secondString = tostring(remainSecond)
	end

	local minuteString = false
	if minute < 10 then
		minuteString = "0" .. tostring(minute)
	else
		minuteString = tostring(minute)
	end

	local result = minuteString .. separator ..
			secondString 
	return result
end

function EnergyButton:convertSecondToHourFormat(second, ...)
	assert(type(second) == "number")
	assert(#{...} == 0)

	local separator = ":"
	local minute		= math.floor(second / 60)
	local remainSecond	= second - minute * 60

	local hour 		= math.floor(minute / 60)
	local remainMinute	= minute - hour * 60

	
	local secondString = false
	if remainSecond < 10 then
		secondString = "0" .. tostring(remainSecond)
	else
		secondString = tostring(remainSecond)
	end

	local minuteString = false
	if remainMinute < 10 then
		minuteString = "0" .. tostring(remainMinute)
	else
		minuteString = tostring(remainMinute)
	end

	local hourString = false
	if hour < 10 then
		hourString = "0" .. tostring(hour)
	else
		hourString = tostring(hour)
	end

	local result = hourString .. separator .. 
			minuteString .. separator ..
			secondString 
	return result

		
end

function EnergyButton:setCurEnergy(curEnergy, ...)
	assert(curEnergy)
	assert(#{...} == 0)

	self.curEnergy = curEnergy
	--self:updateView()
end

function EnergyButton:setTotalEnergy(totalEnergy, ...)
	assert(totalEnergy)
	assert(#{...} == 0)

	self.totalEnergy = totalEnergy

	if self.isDisposed then return end
	
	self:updateView()
end

function EnergyButton:updateView(...)
	assert(#{...} == 0)

	if self.displayedCurEnergy == self.curEnergy and
		self.displayedTotalEnergy == self.totalEnergy then

		return
	end

	self.displayedCurEnergy 	= self.curEnergy
	self.displayedTotalEnergy 	= self.totalEnergy

	local str = tostring(self.curEnergy) .. self.sepChar .. tostring(self.totalEnergy)
	
	self.numerator:setString(tostring(self.curEnergy))
	self.denominator:setString(tostring(self.totalEnergy))

	self.progressBar:setCurNumber(self.curEnergy)
	self.progressBar:setTotalNumber(self.totalEnergy)

	self:positionLabel()
end

function EnergyButton:changeToShowEnergyStateInfinite(...)
	assert(#{...} == 0)

	if self.showEnergyState ~= self.SHOW_ENERGY_STATE_INFINITE then
		self.showEnergyState = self.SHOW_ENERGY_STATE_INFINITE

		local animation = MaxEnergyAnimation:create()
		self.infiniteAnim	= animation

		local manualAdjustAnimPosX	= -5
		local manualAdjustAnimPosY	= 25 - 12
		self.infiniteAnim:setPosition(ccp(manualAdjustAnimPosX, manualAdjustAnimPosY))

		self.ui:addChild(self.infiniteAnim)
	end
end

function EnergyButton:changeToShowEnergyStateCountdownToRecover(...)
	assert(#{...} == 0)

	if self.showEnergyState ~= self.SHOW_ENERGY_STATE_COUNTDOWN_TO_RECOVER then
		self.showEnergyState = self.SHOW_ENERGY_STATE_COUNTDOWN_TO_RECOVER

		if self.infiniteAnim then
			self.infiniteAnim:removeFromParentAndCleanup(true)
			self.infiniteAnim = false
		end
	end
end

function EnergyButton:playBubbleSkewAnim(...)
	assert(#{...} == 0)

	self.bubbleItem:playBubbleSkewAnim()
end

function EnergyButton:playHighlightAnim(...)
	assert(#{...} == 0)

	local itemRes	= ResourceManager:sharedInstance():buildSprite("energyHighlightWrapper")
	self.bubbleItem:playHighlightAnim(itemRes)
end

function EnergyButton:create( belongScene )
	local newEnergyButton = EnergyButton.new()
	newEnergyButton:init(belongScene)
	return newEnergyButton
end

function EnergyButton:showTip()
	if self.tip then self:disposeTip() end
	if not self:getParent() then return end 

	self.tip = ResourceManager:sharedInstance():buildGroup('homeScene_infiniteEnergyTip')
	self.tip:getChildByName('txt'):setString(Localization:getInstance():getText('energy.button.tip'))
	-- local size = self.ui:getGroupBounds().size
	local size = CCSizeMake(140, 140)
	if _G.isLocalDevelopMode then printx(0, size.width, size.height) end
	local pos = self:getParent():convertToWorldSpace(ccp(self:getPositionX(), self:getPositionY()))
	-- local pos = ccp(self:getPositionX(), self:getPositionY())
	local destPosX = pos.x + size.width - 10
	local destPosY = pos.y - 40
	self.tip:setPosition(ccp(destPosX, destPosY))

	HomeScene:sharedInstance():addChild(self.tip)

	local action = CCRepeatForever:create(
	                CCSequence:createWithTwoActions(
	                 CCEaseSineOut:create(CCMoveBy:create(0.5, ccp(10, 0))),
	                 CCEaseSineIn:create(CCMoveBy:create(0.5, ccp(-10, 0)))
	                                                )
	                                      )
	self.tip:runAction(action)

	local delay = 15 -- sec
	local function __disposeTip()
		self:disposeTip()
	end
	self.schedId = Director:sharedDirector():getScheduler():scheduleScriptFunc(__disposeTip, delay, false)

end

function EnergyButton:disposeTip()
	if self.tip then
		self.tip:stopAllActions()
		self.tip:removeFromParentAndCleanup(true)
		self.tip = nil
	end
	if self.schedId then
		Director:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedId)
		self.schedId = nil
	end
end

function EnergyButton:getFlyToPosition()
	local pos = self.energyIcon:getPosition()
	local size = self.energyIcon:getGroupBounds().size
	return self.blueBubbleItemRes:convertToWorldSpace(ccp(pos.x + size.width / 2, pos.y - size.height / 2))
end

function EnergyButton:getFlyToSize()
	local size = self.energyIcon:getGroupBounds().size
	size.width, size.height = size.width, size.height
	return size
end

function EnergyButton:getBubbleItemRes( ... )
	return self.blueBubbleItemRes
end


-- 播放动画时候先显示正常状态，播放完再改回来
function EnergyButton:setTempEnergyState( state )
	self.showTempEnergyState = state
	-- self.energyState = UserEnergyState.COUNT_DOWN_TO_RECOVER
end