
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年09月 1日 20:11:06
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

require "zoo.scenes.component.HomeScene.iconButtons.IconButtonBase"

---------------------------------------------------
-------------- GoldButton
---------------------------------------------------

assert(not GoldButton)
assert(IconButtonBase)

GoldButton = class(IconButtonBase)

function GoldButton:ctor()
	self.idPre = "GoldButton"
    self.playTipPriority = 20
end

function GoldButton:init(belongScene)
	self.clickReplaceScene = true

	self.id = self.idPre .. self.tipState
	self["tip"..IconTipState.kNormal] = Localization:getInstance():getText("buy.gold.icon.tip")
	-- Get UI Resource
	self.ui	= ResourceManager:sharedInstance():buildGroup("newGoldButton")
	assert(self.ui)

	-- ---------
	-- Init Base
	-- ---------
	IconButtonBase.init(self, self.ui)

	-- -------------
	-- Get UI Resource
	-- -------------
	self.promotionFlag = self.ui:getChildByName('promotionFlag')
	self.promotionFlag:setVisible(false)

	self.pennyFlag = self.ui:getChildByName('pennyFlag')
	self.pennyFlag:setVisible(false)

	self.oneYuanFlag = self.ui:getChildByName("oneYuanFlag")
	self.oneYuanFlag:setVisible(false)
	self.flagChildIndex = self.ui:getChildIndex(self.oneYuanFlag)

	self.redDot = self.ui:getChildByName('redDot')
	self.redDot:setVisible(false)

	self.glow = self.ui:getChildByName("glow");
	self.numberLabelPlaceholder	= self.wrapper:getChildByName("numberLabel")
	self.bubbleItemRes	= self.wrapper:getChildByName("bubbleItem")
	self.goldIcon = self.bubbleItemRes:getChildByName("placeHolder")
	if not self.goldIcon then debug.debug() end

	self.iconPos = IconButtonBasePos.LEFT

	assert(self.numberLabelPlaceholder)
	assert(self.bubbleItemRes)
	assert(self.glow);

	-----------------
	-- Init UI Component
	-- ------------------
	self.numberLabelPlaceholder:setVisible(false)
	self.glow:setVisible(false);
	-- Scale Small
	local config 	= UIConfigManager:sharedInstance():getConfig()
	local uiScale	= config.homeScene_uiScale
	self:setScale(uiScale)


	-------------------
	-- Get Data About UI 
	-- -----------------
	self.onTappedCallback	= false
	local placeholderPos 		= self.numberLabelPlaceholder:getPosition()
	local placeholderPreferredSize	= self.numberLabelPlaceholder:getPreferredSize()

	self.placeholderPreferredSize	= placeholderPreferredSize
	self.placeholderPos		= placeholderPos

	--------------------
	-- Craete UI Componenet
	-- --------------------
	self.bubbleItem = HomeSceneBubbleItem:create(self.bubbleItemRes)

	-- Clipping The Bubble
	local stencil		= LayerColor:create()
	stencil:setColor(ccc3(255,0,0))
	stencil:changeWidthAndHeight(132, 72.95 + 30)
	stencil:setPosition(ccp(0, -72.95))
	local cppClipping	= CCClippingNode:create(stencil.refCocosObj)
	local luaClipping	= ClippingNode.new(cppClipping)
	stencil:dispose()
	
	self.ui:addChildAt(luaClipping, self.flagChildIndex)
	self.bubbleItem:removeFromParentAndCleanup(false)
	luaClipping:addChild(self.bubbleItem)

	-- Monospace Label
	local charWidth		= 35
	local charHeight	= 35
	local charInterval	= 16
	local fntFile		= "fnt/hud.fnt"
	self.numberLabel	= LabelBMMonospaceFont:create(charWidth, charHeight, charInterval, fntFile)
	self.numberLabel:setAnchorPoint(ccp(0,1))
	self.ui:addChild(self.numberLabel)

	self.numberLabel:setPosition(ccp(placeholderPos.x, placeholderPos.y))

	-- -------------
	-- Data
	-- ------------
	he_log_warning("mock gold number !")
	self.goldNumber	= UserManager:getInstance().user:getCash()

	----------------
	---- Update View
	--------------
	self:updateView()

	-- ----------------------------------
	-- Add Scheduler To Check Data Change
	-- -----------------------------------
	local function perFrameCallback()
		self.userRef	= UserManager.getInstance().user
		self:setGoldNumber(self.userRef:getCash())
	end
	CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(perFrameCallback, 1/60, false)

	-- ---------------------------------
	-- Add Event Listener
	-- ---------------------------------
	local function onTapped(event)
		self:onTapped(event)
	end

	self.wrapper:setTouchEnabled(true,0,true)
	self.wrapper:addEventListener(DisplayEvents.kTouchTap, onTapped)
	self:registerScriptHandler(function(event)
			if event == "enter" and not self.wrapper.isDisposed then
				self.wrapper.isTouched = false
			end
		end)

	if belongScene then
		self.belongScene	= belongScene
		self.belongScene:addEventListener(HomeSceneEvents.USERMANAGER_CASH_CHANGE, self.onCashDataChange, self)
	end
end

function GoldButton.onCashDataChange(event, ...)
	assert(event)
	assert(event.name == HomeSceneEvents.USERMANAGER_CASH_CHANGE)
	assert(event.context)
	assert(#{...} == 0)

	local self = event.context

	local newCash = UserManager.getInstance().user:getCash()
	self:setGoldNumber(newCash)

	if _G.isLocalDevelopMode then printx(0, "GoldButton:onCashDataChange Called !") end
	if _G.isLocalDevelopMode then printx(0, "New Cash: " .. newCash) end
	--debug.debug()
end

function GoldButton:playHighlightAnim()
	local highlightRes = ResourceManager:sharedInstance():buildSprite("goldHighlightWrapper")
	self.bubbleItem:playHighlightAnim(highlightRes)
end

function GoldButton:centerLabel()
	local curLabelPos 	= self.numberLabel:getPosition()
	local curLabelSize	= self.numberLabel:getContentSize()

	local deltaWidth	= self.placeholderPreferredSize.width - curLabelSize.width
	self.numberLabel:setPositionX(self.placeholderPos.x + deltaWidth/2)
	

	local deltaHeight	= self.placeholderPreferredSize.height - curLabelSize.height
	self.numberLabel:setPositionY(self.placeholderPos.y - deltaHeight/2)
end

function GoldButton:onTapped(event)
	if self.onTappedCallback then
		self.onTappedCallback()
	end
end

function GoldButton:setOnTappedCallback(onTappedCallback)
	assert(type(onTappedCallback) == "function")

	self.onTappedCallback = onTappedCallback
end

function GoldButton:setGoldNumber(number)
	assert(number)

	if self.goldNumber == number then
		return
	else
		self.goldNumber = number
	end
end

function GoldButton:updateView()
	local delay = CCDelayTime:create(2/30)

	local function callFunc()
		self.numberLabel:setString(tostring(self.goldNumber))
		self:centerLabel()
	end
	local callFuncAction = CCCallFunc:create(callFunc)

	local seq = CCSequence:createWithTwoActions(delay, callFuncAction)
	self:runAction(seq)
end

function GoldButton:create(belongScene)
	local newGoldButton = GoldButton.new()
	newGoldButton:init(belongScene)
	
	return newGoldButton
end

function GoldButton:getTipPos()
	local tipSize = self.tip:getGroupBounds().size
	self.wrapperSize	= self.wrapper:getGroupBounds().size
	self.wrapperSize	= {width = self.wrapperSize.width, height = self.wrapperSize.height}
	local deltaHeight	= self.wrapperSize.height - tipSize.height
	local tipPos = ccp(-tipSize.width - self.tipLeftMarginToIconBtn -40 , -deltaHeight / 2)

    local scale = HomeScene:sharedInstance().iconLayerScale
    if scale~=1 then
    	tipPos.x = tipPos.x-30
    end

	return tipPos
end

function GoldButton:delayCreateTipLeft()
	if not self.tip	then
		self.tip = ResourceManager:sharedInstance():buildGroup("tip/tipLeft")
		self.tip:setScale(self.tip:getScale()/self:getScale())
		self.ui:addChild(self.tip)

		self.tipPos = self:getTipPos()
		self.tip:setPosition(self.tipPos)
		self:setTipString(self["tip"..IconTipState.kNormal]);
		-- self.tip:setVisible(false)
	end
	return self.tip
end

function GoldButton:_createShiftingTipActionLeft()
	local secondPerFrame = 1 / 60
	local tip = self:delayCreateTipLeft()

	local function initActionFunc()
		-- tip:setVisible(true)
		tip:setPosition(ccp(self.tipPos.x, self.tipPos.y))
	end
	local initAction	= CCCallFunc:create(initActionFunc)
	local scaleDelta = self:getScale()
	-- Shifting Action
	-- local moveTo1	= CCMoveTo:create(secondPerFrame * 11, 	ccp(self.tipPos.x - 4, self.tipPos.y))
	local moveTo2	= CCMoveTo:create(secondPerFrame * 10,	ccp(self.tipPos.x + 12/scaleDelta, self.tipPos.y))
	local moveTo3	= CCMoveTo:create(secondPerFrame * 10,	ccp(self.tipPos.x + 10/scaleDelta, self.tipPos.y))
	local moveTo4	= CCMoveTo:create(secondPerFrame * 29,	ccp(self.tipPos.x - 0, self.tipPos.y))
	
	-- Action Array
	local actionArray = CCArray:create()
	actionArray:addObject(initAction)
	-- actionArray:addObject(moveTo1)
	actionArray:addObject(moveTo2)
	actionArray:addObject(moveTo3)
	actionArray:addObject(moveTo4)

	local seq = CCSequence:create(actionArray)
	local targetSeq	= CCTargetedAction:create(tip.refCocosObj, seq)

	return targetSeq
end

function GoldButton:getFlyToPosition()
	local pos = self.goldIcon:getPosition()
	local size = self.goldIcon:getGroupBounds().size
	return self.bubbleItemRes:convertToWorldSpace(ccp(pos.x, pos.y))
end

function GoldButton:getFlyToSize()
	local size = self.goldIcon:getGroupBounds().size
	size.width, size.height = size.width, size.height
	return size
end

function GoldButton:getBubbleItemRes( ... )
	return self.bubbleItemRes
end

function GoldButton:playHasNotificationAnim()
    IconButtonManager:getInstance():addPlayTipNormalIcon(self)
end
function GoldButton:stopHasNotificationAnim()
    IconButtonManager:getInstance():removePlayTipNormalIcon(self)
end

function GoldButton:stopOnlyTipAnim()
	IconButtonBase.stopOnlyTipAnim(self);
	self.glow:stopAllActions();
	self.glow:setVisible(false);

	-- if self.onTappedCallback then
	-- 	self.onTappedCallback()
	-- end
	if _G.isLocalDevelopMode then printx(0, "stopHasNotificationAnim in goldbutton called!") end;
end

function GoldButton:playOnlyTipAnim()
	IconButtonBase.playOnlyTipAnim(self);
	self.glow:setVisible(true);

	local animationTime = 0.5;
	local fadeIn = CCEaseSineInOut:create(CCFadeIn:create(animationTime))
	local fadeOut = CCEaseSineInOut:create(CCFadeOut:create(animationTime))
	local seq = CCSequence:createWithTwoActions(fadeIn, fadeOut)
	assert(self.glow);
	self.glow:runAction(CCRepeatForever:create(seq))
end

function GoldButton:playOnlyIconAnim()
end

function GoldButton:stopOnlyIconAnim()
end

function GoldButton:playTip(text, seconds)
	if _G.isLocalDevelopMode then printx(0, 'GoldButton:playTip', seconds) end
	local function _playTip()
		IconButtonBase.playOnlyTipAnim(self);
		self.glow:setVisible(true);

		local animationTime = 0.5;
		local fadeIn = CCEaseSineInOut:create(CCFadeIn:create(animationTime))
		local fadeOut = CCEaseSineInOut:create(CCFadeOut:create(animationTime))
		local seq = CCSequence:createWithTwoActions(fadeIn, fadeOut)
		assert(self.glow);
		self.glow:runAction(CCRepeatForever:create(seq))

		self.tipState = IconTipState.kReward
		self.id = self.idPre .. self.tipState
		self:setTipString(text);
	end
	IconButtonBase.stopHasNotificationAnim(self);
	self.glow:stopAllActions();
	self.glow:setVisible(false);
	local function onTick()
		if self.isDisposed then return end
		_playTip()
		if self.schedId then
			CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedId)
			self.schedId = nil
		end
	end
	if self.schedId then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedId)
		self.schedId = nil
	end		
	if seconds > 0 then
		self.schedId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onTick, seconds, false)
	else
		_playTip()
	end
end

-- function GoldButton:removeOneYuanFCashTip()
-- 	IconButtonBase.stopHasNotificationAnim(self)
-- 	if self.schedId then
-- 		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedId)
-- 		self.schedId = nil
-- 	end
-- end

function GoldButton:setOneYuanCashFlagVisible(isVisible)
	if self.isDisposed then return end


	if isVisible then
		self:setRedDotVisible(false)
	end

	if self.oneYuanFlag then 
		self.oneYuanFlag:setVisible(isVisible)
	end

	
end

function GoldButton:setPromotionFlagVisible(isVisible)
	if self.isDisposed then return end

	if isVisible then
		self:setRedDotVisible(false)
	end

	if self.promotionFlag then 
		self.promotionFlag:setVisible(isVisible)
	end
end

function GoldButton:setPennyFlagVisible( isVisible )
	if self.isDisposed then return end

	if isVisible then
		self:setRedDotVisible(false)
		self:setPromotionFlagVisible(false)
	end

	if self.pennyFlag then
		if isVisible then
			self["tip"..IconTipState.kNormal] = localize("buy.gold.icon.penny.pay.tip")
			self:playHasNotificationAnim()
		else
			self:stopHasNotificationAnim()
		end
		self.pennyFlag:setVisible(isVisible)
	end
end

function GoldButton:setRedDotVisible(isVisible)

	if self.isDisposed then return end
	if self.redDot and not self.promotionFlag:isVisible() and not self.oneYuanFlag:isVisible() and not self.pennyFlag:isVisible() then 
		self.redDot:setVisible(isVisible)
		if isVisible then
			self["tip"..IconTipState.kNormal] = localize("mc.test.icon.tip")
			self:playHasNotificationAnim()
			HomeScene:sharedInstance():shutdownJiFenEntry()
		else
			self["tip"..IconTipState.kNormal] = localize("buy.gold.icon.tip")
			self:playHasNotificationAnim()
		end
	else
		self.redDot:setVisible(false)
		self["tip"..IconTipState.kNormal] = localize("buy.gold.icon.tip")
		self:playHasNotificationAnim()
		
	end
end

function GoldButton:changeIdForIosAliGuide()
	self.id = self.idPre .. IconTipState.kExtend
	self["tip"..IconTipState.kNormal] = '支付宝、微信简单买'
end