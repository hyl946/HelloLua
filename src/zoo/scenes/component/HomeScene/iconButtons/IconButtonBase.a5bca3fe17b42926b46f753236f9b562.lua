
assert(not IconButtonBase)
IconButtonBase = class(BaseUI)

local indexKeyCounter = 0
local function NewIndexKey()
	indexKeyCounter = indexKeyCounter + 1
	return 'no_name_btn_'..tostring(indexKeyCounter)
end

function IconButtonBase:ctor()
	self.playTipPriority = 10000
	self.tipState = IconTipState.kNormal
	self.homeSceneRegion = IconButtonBasePos.LEFT
	self.showPriority = 0
	self.indexKey = NewIndexKey()
	self.showHideOption = ShowHideOptions.DO_NOTHING
	self.__isGroupButtonBase__ = true
end

function IconButtonBase:initShowHideConfig(key)
	if not BtnShowHideConf[key] then
		if isLocalDevelopMode then
			assert(false, 'key is nil')
			debug.debug()
		end
		return
	end
	self.showPriority = BtnShowHideConf[key].showPriority
	self.indexKey = BtnShowHideConf[key].indexKey
	self.homeSceneRegion = BtnShowHideConf[key].homeSceneRegion
	self.showHideOption = BtnShowHideConf[key].showHideOption
end

function IconButtonBase:init(ui)
	BaseUI.init(self, ui)
	
	-- For Play The Jump Anim Which Require Anchor Point (0.5, 0) 
	self.wrapper	= self.ui:getChildByName("wrapper")
	assert(self.wrapper)

	local wrapperSize = self.ui:getChildByName("wrapperSize")
	if wrapperSize then
		self.wrapperSize = wrapperSize:getGroupBounds().size
		if not SHOWDEBUGLINE then
			wrapperSize:setVisible(false)
		end
	else
		self.wrapperSize	= self.wrapper:getGroupBounds().size
	end
	self.wrapperSize	= {width = self.wrapperSize.width, height = self.wrapperSize.height}
	self.wrapperWidth	= self.wrapperSize.width
	self.wrapperHeight	= self.wrapperSize.height

	self.wrapper.originPos = {self.wrapper:getPositionX(), self.wrapper:getPositionY()}

	-- Scale Small
	local config 	= UIConfigManager:sharedInstance():getConfig()
	local uiScale	= config.homeScene_uiScale
	--self:setScale(uiScale)

	self.iconPos			= IconButtonBasePos.RIGHT
	self.tip		= false
	self.tipOriginalWidth = 200
	self.tipOriginalHeight = 45

	self.tipLeftMarginToIconBtn	= 20
	self.tipPos			= false
	self.tipLabelTxt		= "default tip text"
	self.tipLabelSize		= false

	------------------
	-- Add Event Listener
	-- ------------------
	local function onTouch()
		self:handleTouchEventBefore()
		if self.id and not IconButtonManager:getInstance():todayIsShow(self) then 
			IconButtonManager:getInstance():writeShowTimeInQueue(self)
			IconButtonManager:getInstance().clickReplaceScene = self.clickReplaceScene
		end
		self:stopHasNotificationAnim()
		Notify:dispatch("QuitNextLevelModeEvent")
		self:handleTouchEventAfter()
	end
	self.wrapper:setTouchEnabled(true, 0, true)
	self.wrapper:setButtonMode(true)
	self.wrapper:ad(DisplayEvents.kTouchTap, onTouch)
	self.ui:setTouchEnabled(true, 0, true)
	if __ANDROID then
		local function refreshTexture()
			if self.isDisposed then
				GlobalEventDispatcher:getInstance():removeEventListener(kGlobalEvents.kEnterForeground, refreshTexture)
				return
			end
			self:runAction(CCCallFunc:create(function()
				if self.isDisposed then return end
				if self.tip then
					if self.tipLabel then
						self.tipLabel:setString(self.tipLabelTxt)
					end
				end
			end))
		end
		GlobalEventDispatcher:getInstance():addEventListener(kGlobalEvents.kEnterForeground, refreshTexture)
	end
end

function IconButtonBase:handleTouchEventBefore()
end

function IconButtonBase:handleTouchEventAfter()
end

function IconButtonBase:setTipString(str)
	assert(type(str) == "string")
	self.tipLabelTxt = str
	if self.tip then
		if self.tipLabel and self.tip:contains(self.tipLabel) then 
			self.tipLabel:removeFromParentAndCleanup(true)
			self.tipLabel = nil
		end
		self.tipLabel = TextField:create(str, nil, 20)
		self.tipLabel:setColor(ccc3(255, 255, 255))

		self.tip:addChild(self.tipLabel)

		local tipLabelSize = self.tipLabel:getContentSize()
		local tipLeftExceedTxtWidth	= 10
		local tipRightExceedTxtWidth = 10
		local newTipWidth = tipLabelSize.width + tipLeftExceedTxtWidth + tipRightExceedTxtWidth 

		self.tip:getChildByName("tipBg"):setPreferredSize(CCSizeMake(newTipWidth, self.tipOriginalHeight))
		local tipArrow = self.tip:getChildByName("tipArrow")

		if self.iconPos == IconButtonBasePos.LEFT then
			local tipArrowOriPos = ccp(170, -15)
			local tipBgOriWidth = 172

			local posXDelta = newTipWidth - tipBgOriWidth
			tipArrow:setPosition(ccp(tipArrowOriPos.x + posXDelta, tipArrowOriPos.y))
			self.tipLabel:setPosition(ccp(tipLabelSize.width/2 + tipLeftExceedTxtWidth, -self.tipOriginalHeight/2))

			self.tipPos = self:getTipPos()
			self.tip:setPosition(self.tipPos)
		elseif self.iconPos == IconButtonBasePos.RIGHT then
			local arrowDeltaX = 10

			self.tipLabel:setPosition(ccp(tipLabelSize.width/2 + tipLeftExceedTxtWidth + arrowDeltaX, -self.tipOriginalHeight/2))
		end
	end
end

function IconButtonBase:getTipPos()
	local tipSize = self.tip:getGroupBounds().size
    local scale = HomeScene:sharedInstance().iconLayerScale
	local tipPos = nil
	if self.iconPos == IconButtonBasePos.LEFT then
		tipPos = ccp(-tipSize.width * scale - self:getGroupBounds().size.width/2 - self.tipLeftMarginToIconBtn * scale, tipSize.height/2 * scale)
	elseif self.iconPos == IconButtonBasePos.RIGHT then
		tipPos = ccp(self:getGroupBounds().size.width/2 + self.tipLeftMarginToIconBtn * scale, tipSize.height/2 * scale)
	end
	return tipPos
end

function IconButtonBase:delayCreateTipRight()
	if not self.tip	then
		self.tip = ResourceManager:sharedInstance():buildGroup("home_scene_icon/tips/tipRight")
		self.ui:addChild(self.tip)

		self.tipPos	= self:getTipPos()
		self.tip:setPosition(self.tipPos)

		self:setTipString(self.tipLabelTxt)
		self.tip:setVisible(false)
	end

	return self.tip
end

function IconButtonBase:delayCreateTipLeft()
	if not self.tip	then
		self.tip = ResourceManager:sharedInstance():buildGroup("home_scene_icon/tips/tipLeft")

		self.ui:addChild(self.tip)

		self.tipPos	= self:getTipPos()
		self.tip:setPosition(self.tipPos)

		self:setTipString(self.tipLabelTxt)
		self.tip:setVisible(false)
	end

	return self.tip
end

function IconButtonBase:_createIconAction()
	local secondPerFrame	= 1 / 24

	-- Init Action
	local function initActionFunc()
		self.wrapper:setScale(1)
	end
	local initAction = CCCallFunc:create(initActionFunc)
	local a1 = CCScaleTo:create(secondPerFrame * 3, 1.05, 0.92)
	local a2 = CCScaleTo:create(secondPerFrame * 3, 1, 1)
	local scale1	= CCRotateTo:create(secondPerFrame * 3, -8)
	local scale2	= CCRotateTo:create(secondPerFrame * 3, 8)
	local scale3	= CCRotateTo:create(secondPerFrame * 3, -7)
	local scale4	= CCRotateTo:create(secondPerFrame * 3, 6.8)
	local scale5	= CCRotateTo:create(secondPerFrame * 3, -6)
	local scale6	= CCRotateTo:create(secondPerFrame * 3, 5)
	local scale7	= CCRotateTo:create(secondPerFrame * 3, -3.8)
	local scale8	= CCRotateTo:create(secondPerFrame * 3, 2.5)
	local scale9	= CCRotateTo:create(secondPerFrame * 3, -1.3)
	local scale11	= CCRotateTo:create(secondPerFrame * 3, 0)
	local a3 = CCScaleTo:create(secondPerFrame * 3, 1.05, 0.87)
	local a4 = CCScaleTo:create(secondPerFrame * 3, 1, 1)
	local delay 	= CCDelayTime:create(secondPerFrame * 107)


	local actionArray = CCArray:create()
	actionArray:addObject(a1)
	actionArray:addObject(a2)
	actionArray:addObject(scale1)
	actionArray:addObject(scale2)
	actionArray:addObject(scale3)
	actionArray:addObject(scale4)
	actionArray:addObject(scale5)
	actionArray:addObject(scale6)
	actionArray:addObject(scale7)
	actionArray:addObject(scale8)
	actionArray:addObject(scale9)
	actionArray:addObject(scale11)
	actionArray:addObject(a3)
	actionArray:addObject(a4)
	actionArray:addObject(delay)

	local seq 	= CCSequence:create(actionArray)
	local targetSeq	= CCTargetedAction:create(self.wrapper.refCocosObj, seq)
	return targetSeq
end

function IconButtonBase:_createShiftingTipActionRight()
	local secondPerFrame 	= 1 / 60
	local tip		= self:delayCreateTipRight()

	-- Init Action
	local function initActionFunc()
		tip:setVisible(true)
		tip:setPosition(ccp(self.tipPos.x, self.tipPos.y))
	end
	local initAction	= CCCallFunc:create(initActionFunc)

	-- Shifting Action
	local moveTo1	= CCMoveTo:create(secondPerFrame * (12-1), 	ccp(self.tipPos.x + 7.15 - 3.15, self.tipPos.y))
	local moveTo2	= CCMoveTo:create(secondPerFrame * (22 - 12),	ccp(self.tipPos.x - 8.85 - 3.15, self.tipPos.y))
	local moveTo3	= CCMoveTo:create(secondPerFrame * (32 - 22),	ccp(self.tipPos.x - 6.75 - 3.15, self.tipPos.y))
	local moveTo4	= CCMoveTo:create(secondPerFrame * (50 - 32),	ccp(self.tipPos.x + 3.15 - 3.15, self.tipPos.y))
	
	-- Action Array
	local actionArray = CCArray:create()
	actionArray:addObject(initAction)
	actionArray:addObject(moveTo1)
	actionArray:addObject(moveTo2)
	actionArray:addObject(moveTo3)
	actionArray:addObject(moveTo4)

	local seq = CCSequence:create(actionArray)
	local targetSeq	= CCTargetedAction:create(tip.refCocosObj, seq)

	return targetSeq
end

function IconButtonBase:_createShiftingTipActionLeft()
	if _G.isLocalDevelopMode then printx(0, "IconButtonBase:_createShiftingTipActionLeft Called !") end

	local secondPerFrame 	= 1 / 60
	local tip		= self:delayCreateTipLeft()

	-- Init Action
	local function initActionFunc()
		tip:setVisible(true)
		tip:setPosition(ccp(self.tipPos.x, self.tipPos.y))
	end
	local initAction	= CCCallFunc:create(initActionFunc)

	-- Shifting Action
	local moveTo1	= CCMoveTo:create(secondPerFrame * (12-1), 	ccp(self.tipPos.x - (7.15 - 3.15	), self.tipPos.y))
	local moveTo2	= CCMoveTo:create(secondPerFrame * (22 - 12),	ccp(self.tipPos.x + (8.85 + 3.15	), self.tipPos.y))
	local moveTo3	= CCMoveTo:create(secondPerFrame * (32 - 22),	ccp(self.tipPos.x + (6.75 + 3.15	), self.tipPos.y))
	local moveTo4	= CCMoveTo:create(secondPerFrame * (50 - 32),	ccp(self.tipPos.x - (3.15 - 3.15	), self.tipPos.y))
	
	-- Action Array
	local actionArray = CCArray:create()
	actionArray:addObject(initAction)
	actionArray:addObject(moveTo1)
	actionArray:addObject(moveTo2)
	actionArray:addObject(moveTo3)
	actionArray:addObject(moveTo4)

	local seq = CCSequence:create(actionArray)
	local targetSeq	= CCTargetedAction:create(tip.refCocosObj, seq)

	return targetSeq
end

function IconButtonBase:disableTip()
	self.tipDisabled = true
end

function IconButtonBase:enableTip()
	self.tipDisabled = false
end

function IconButtonBase:setTipPosition(pos)
	self.iconPos = pos
end

function IconButtonBase:playHasNotificationAnim()
	if not self.isDisposed then
		self:playOnlyIconAnim()
		self:playOnlyTipAnim()
	end
end

function IconButtonBase:stopHasNotificationAnim()
	if not self.isDisposed then
		self:stopOnlyIconAnim()
		self:stopOnlyTipAnim()
	end
end

function IconButtonBase:playOnlyIconAnim()
end

function IconButtonBase:playOnlyTipAnim()
	self:stopOnlyTipAnim()

	if self.tipDisabled then
		return
	end

	local tipAnim = nil
	if self.iconPos == IconButtonBasePos.LEFT then
		tipAnim	= self:_createShiftingTipActionLeft()
	elseif self.iconPos == IconButtonBasePos.RIGHT then
		tipAnim	= self:_createShiftingTipActionRight()
	end

	local action	= CCRepeatForever:create(tipAnim)
	action:setTag(200)
	self:runAction(action)
end

function IconButtonBase:stopOnlyIconAnim()
end

function IconButtonBase:stopOnlyTipAnim()
	self:stopActionByTag(200)

	if self.tip and not self.tip.isDisposed then
		if self.tip then
			self.tip:removeFromParentAndCleanup(true)
			self.tip = nil
		end
	end
end

function IconButtonBase:getHorizontalCenterOffsetX()
	return 0 
end

function IconButtonBase:getVerticalCenterOffsetY()
	return -self.wrapperSize.height / 2
end

function IconButtonBase:getGroupBounds()
	local wrapperSize = self.ui:getChildByName("wrapperSize")

	if wrapperSize then
		return wrapperSize:getGroupBounds()
	else
		return self.wrapper:getChildByName("bg"):getGroupBounds()
	end
end

-----------------20181213 icon优化-----------------
local kAnimationTime = 1/24
function IconButtonBase:addRedDot()
	local redDot = ResourceManager:sharedInstance():buildGroup('home_scene_icon/common_res/icon_reddot_small')
	self.ui:addChild(redDot)
	redDot:setPosition(ccp(35, 30))

	return redDot
end

function IconButtonBase:addRedDotNum()
	local numTip = getRedNumTip()
	self.ui:addChild(numTip)
	numTip:setPosition(ccp(36, 33))

	return numTip 
end

function IconButtonBase:addRedDotReward()
	local redDotReward = ResourceManager:sharedInstance():buildGroup('home_scene_icon/common_res/icon_reddot_reward')
	self.ui:addChild(redDotReward)
	local oriPos = {x = 35, y = 15}
	redDotReward:setPosition(ccp(oriPos.x, oriPos.y))
	redDotReward.oriPos = oriPos

	return redDotReward
end

function IconButtonBase:addRedDotDiscount()
	local redDotDiscount = ResourceManager:sharedInstance():buildGroup('home_scene_icon/common_res/icon_reddot_discount')
	self.ui:addChild(redDotDiscount)
	local oriPos = {x = 35, y = 15}
	redDotDiscount:setPosition(ccp(oriPos.x, oriPos.y))
	redDotDiscount.oriPos = oriPos

	return redDotDiscount
end

function IconButtonBase:addBubbleAniStrong()
	local ani = ArmatureNode:create("home_top_bar_s_ani/bubble_award")
	ani:update(0.001)
	ani:stop()
	self.wrapper:addChild(ani)
	ani:setPosition(ccp(-52, 51))
	ani:play("p", 0)

	return ani
end

function IconButtonBase:addBubbleAniWeak()
	local ani = ArmatureNode:create("home_top_bar_s_ani/bubble_number")
	ani:update(0.001)
	ani:stop()
	self.wrapper:addChild(ani)
	ani:setPosition(ccp(-51, 50))
	ani:play("p", 0)

	return ani
end

function IconButtonBase:playRedDotJumpAni(redDotRes)
	if not redDotRes.isPlayingJumpAni then 
		redDotRes.isPlayingJumpAni = true
		local arr = CCArray:create()
		arr:addObject(CCScaleTo:create(kAnimationTime*3, 1, 0.867))
		arr:addObject(CCSpawn:createWithTwoActions(CCMoveBy:create(kAnimationTime*4, ccp(0, 10)), CCScaleTo:create(kAnimationTime*4, 0.968, 1.028)))
		arr:addObject(CCSpawn:createWithTwoActions(CCMoveBy:create(kAnimationTime*2, ccp(0, 5)), CCScaleTo:create(kAnimationTime*2, 1, 0.916)))
		arr:addObject(CCSpawn:createWithTwoActions(CCMoveBy:create(kAnimationTime*4, ccp(0, -15)), CCScaleTo:create(kAnimationTime*4, 1, 1.056)))
		arr:addObject(CCScaleTo:create(kAnimationTime*2, 1, 0.708))
		arr:addObject(CCScaleTo:create(kAnimationTime*2, 0.957, 1.093))
		arr:addObject(CCScaleTo:create(kAnimationTime*3, 1, 1))
		arr:addObject(CCDelayTime:create(kAnimationTime*40))
		redDotRes:runAction(CCRepeatForever:create(CCSequence:create(arr)))
	end
end

function IconButtonBase:stopRedDotJumpAni(redDotRes)
	if redDotRes and redDotRes.isPlayingJumpAni then
		redDotRes.isPlayingJumpAni = false 
		redDotRes:stopAllActions()
		redDotRes:setScale(1)
		if redDotRes.oriPos then 
			redDotRes:setPosition(ccp(redDotRes.oriPos.x, redDotRes.oriPos.y))
		end
	end
end

function IconButtonBase:playHasRewardAni()
	if not self.bubbleAniStrong then 
		self:setOriMaskVisible(false)
		self.bubbleAniStrong = self:addBubbleAniStrong()
	end
end

function IconButtonBase:stopHasRewardAni()
	if self.bubbleAniStrong then
		self:setOriMaskVisible(true)
		self.bubbleAniStrong:removeFromParentAndCleanup(true) 
	end
	self.bubbleAniStrong = nil
end

function IconButtonBase:playHasNumberAni()
	if not self.bubbleAniWeak then 
		self:setOriMaskVisible(false)
		self.bubbleAniWeak = self:addBubbleAniWeak()
	end
end

function IconButtonBase:stopHasNumberAni()
	if self.bubbleAniWeak then
		self:setOriMaskVisible(true)
		self.bubbleAniWeak:removeFromParentAndCleanup(true) 
	end
	self.bubbleAniWeak = nil
end

function IconButtonBase:setOriMaskVisible(isVisible)
	if not self.oriMask then
		local oriMask = self.wrapper:getChildByName("mask")
		if not oriMask then 
			return 
		else
			self.oriMask = oriMask
		end
	end
	self.oriMask:setVisible(isVisible)
end

function IconButtonBase:setOriLabelVisible(isVisible)
	if not self.oriLabel then
		local oriLabel = self.ui:getChildByName("label")
		if not oriLabel then 
			return 
		else
			self.oriLabel = oriLabel
		end
	end
	self.oriLabel:setVisible(isVisible)
end

function IconButtonBase:startCountdown(endTime, endTimeStr, endCallback)
	local function onTick()
		if self.isDisposed then return end
		local leftSeconds = endTime - Localhost:timeInSec()
		if leftSeconds >= 0 then
			self:setCustomizedLabel(self:getCountdownStr(leftSeconds))
		else
			self:stopCountdown()
			if endTimeStr then 
				self:setCustomizedLabel(endTimeStr)
			else
				self:setCustomizedLabel("")
				self:setOriLabelVisible(true)
			end
			if endCallback then endCallback() end
		end
	end

	if not self.oneSecondTimer then
		self:setOriLabelVisible(false)

		self.oneSecondTimer = OneSecondTimer:create()
		self.oneSecondTimer:setOneSecondCallback(onTick)
		self.oneSecondTimer:start()
		onTick()
	end
end

function IconButtonBase:stopCountdown()
	if self.oneSecondTimer then 
		self.oneSecondTimer:stop()
	end
	self.oneSecondTimer = nil
end

function IconButtonBase:setCustomizedLabel(str)
	if not self.customizedLabel	then 
		self.customizedLabel = BitmapText:create('', 'fnt/discount_icon_new.fnt')
		self.customizedLabel:setAnchorPoint(ccp(0.5, 0))
		self.ui:addChild(self.customizedLabel)
		self.customizedLabel:setPosition(ccp(0, -56))
	end
	self.customizedLabel:setText(str)
end

--overrided if necessary
function IconButtonBase:getCountdownStr(leftSeconds)
	return convertSecondToHHMMSSFormat(leftSeconds)
end

function IconButtonBase:dispose()
	self:stopCountdown()
	BaseUI.dispose(self)
end