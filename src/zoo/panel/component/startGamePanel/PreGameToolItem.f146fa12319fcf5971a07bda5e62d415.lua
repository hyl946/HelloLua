
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年09月11日 16:01:34
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

require "zoo.panel.component.common.BubbleItemPreGame"
require "zoo.common.ItemType"
---------------------------------------------------
-------------- PreGameToolItem
---------------------------------------------------
local UIHelper = require 'zoo.panel.UIHelper'

local showLabelTime24 = 24 * 60 * 60
local showLabelTime48 = 48 * 60 * 60
local totalSubtractedCoin		= 0

PreGameToolItem = class(BubbleItemPreGame)

function PreGameToolItem:init(ui, itemId, levelId, ...)
	assert(ui)
	assert(itemId)
	assert(type(itemId) == "number")
	assert(levelId)
	assert(type(levelId) == "number")
	assert(#{...} == 0)

	-- -------
	-- Data
	-- -------
	self.selected			= false
	self.itemId			= itemId
	self.levelId			= levelId
	self.locked			= false
	self.price			= false

	self.resourceManager = ResourceManager:sharedInstance()

	-- --------------
	-- Get UI Resource
	-- ---------------

	self.ui = ui
	self.priceLabel	= self.ui:getChildByName("priceLabel")
	self.unlockLabel		= self.ui:getChildByName("unlockLabel")
	self.lock				= self.ui:getChildByName("lock")
	self.checkIcon			= self.ui:getChildByName("checkIcon")
	self.coinIcon			= self.ui:getChildByName("coinIcon")
	self.happyCoinIcon		= self.ui:getChildByName("happyCoinIcon")
	self.bubbleItem			= self.ui:getChildByName("bubbleItem")
	--------bubbleItem animation wrap layer--------
	local childIndex = self.ui:getChildIndex(self.bubbleItem)
	local layer = LayerColor:create()
    layer:setOpacity(0)
    layer:setColor((ccc3(0,0,0)))
    layer:setContentSize(CCSizeMake(10, 10))
    layer:ignoreAnchorPointForPosition(false)
    layer:setAnchorPoint(ccp(0.5, 0.5))
    layer:setPosition(ccp(80, -82))
    self.ui:addChildAt(layer, childIndex)
    UIHelper:changeParentWhileStayOriPos(self.bubbleItem, layer)
    self.bubbleAniWrapLayer = layer
	-----------------------------------------------
	self._priceBg 			= self.ui:getChildByName('_priceBg')
	self.timeLimitIcon 		= self.ui:getChildByName('timeLimitIcon')
	self.timeLimitLabel 	= self.ui:getChildByName('timeLimitLabel')
	self.timeLimitIcon2 	= self.ui:getChildByName('timeLimitIcon2')
	self.privilegeIcon 		= self.ui:getChildByName("privilegeIcon")
	self.videoadBtn 		= self.ui:getChildByName("videoadBtn")

	self.videoadBtn:setVisible(false)
	self.videoadBtn:setTouchEnabled(true, 0, true)
	self.videoadBtn:addEventListener(DisplayEvents.kTouchTap, function ()
		if self.videoadBtn:isVisible() then
			self:onTapVideoAdBtn()
		end
	end)

	local videoadBtnV2Res 		= self.ui:getChildByName("videoadBtnV2")
	self.videoadBtnV2 = Layer:create()
	videoadBtnV2Res:getParent():addChild(self.videoadBtnV2)
	videoadBtnV2Res:removeFromParentAndCleanup(false)
	videoadBtnV2Res:setPositionX(22)
	self.videoadBtnV2:addChild(videoadBtnV2Res)
	-- self.videoadBtnV2 = ButtonIconsetBase:create(videoadBtnV2Res)
	-- self.videoadBtnV2:setIconByFrameName("res.video/videoIcon0000")
	-- self.videoadBtnV2:setColorMode(kGroupButtonColorMode.blue)
	-- self.videoadBtnV2:setString("免费获取")
    -- self.videoadBtnV2:setScale(0.4)
    self.videoadBtnV2:setTouchEnabled(true,0, false)
	self.videoadBtnV2:addEventListener(DisplayEvents.kTouchTap, function ()
		print("self.videoadBtnV2 touch")
		if self.videoadBtnV2:isVisible() then
			self:setSelected(true)
		end
	end)
	self.videoadBtnV2:setVisible(false)

	self.privilegeIcon:setVisible(false)
	if self.timeLimitIcon2 then
		self.timeLimitIcon2:setVisible(false)
	end
	if self.timeLimitLabel then
		self.timeLimitLabel:setVisible(false)
		self.timeLimitLabel:setContentSize(CCSizeMake(100, 60))
		self.timeLimitLabel:setAnchorPoint(ccp(0.5,0))
		self.timeLimitLabel:setPositionX( self.timeLimitLabel:getPositionX() + 5 )
		self.timelabel = self.timeLimitLabel:getChildByName('timelabel')
		if self.timelabel then
			self.timelabel:setPositionY( self.timelabel:getPositionY() - 5 )
		end
	end

	-- local timePropId = ItemType:getTimePropItemByRealId(itemId)
	-- local timePropNum = UserManager:getInstance():getUserTimePropNumber(timePropId)
	local timePropNum = UserManager:getInstance():getAllTimePropNumberWithRealItemID( itemId )
	self.timeLeft = nil
	self.isTimeProp = false
	if timePropNum > 0 then
		self.isTimeProp = true
		local timeProp = UserManager:getInstance():getTimePropsByRealItemId( itemId )
		if timeProp and timeProp[1] then
			self.itemId = timeProp[1].itemId
		end
		if timeProp[1] and timeProp[1].expireTime and timeProp[1].expireTime > 0 then -- 限时道具		
			local cdInSec = math.floor((timeProp[1].expireTime - Localhost:time()) / 1000)
			self.timeLeft = cdInSec
			self.timePropExpireTime = timeProp[1].expireTime
		end
	end
	
	self.priceLabel = TextField:createWithUIAdjustment(self.ui:getChildByName('priceSize'), self.priceLabel)
	self.ui:addChild(self.priceLabel)
	self.priceLabel.name = 'priceLabel'

	self.oldPriceTxt = ui:getChildByName('oldPriceTxt')
	self.oldPriceBlocker = ui:getChildByName('oldPriceBlocker')
	self.discountTag = ui:getChildByName('discountTag')
	if self.discountTag then
		self.discountPercentTxtOriginalPosition = ccp(self.discountTag:getChildByName("txt_fontsize"):getPositionX(),self.discountTag:getChildByName("txt_fontsize"):getPositionY())
		self.discountPercentTxt = TextField:createWithUIAdjustment(self.discountTag:getChildByName("txt_fontsize"), self.discountTag:getChildByName("txt"), true)
		self.discountPercentTxt:removeFromParentAndCleanup(false)
		self.discountTag:addChild(self.discountPercentTxt)
		self.discountPercentTxt:changeFntFile('fnt/discount2017yelw.fnt')
		self.limitMark = self.discountTag:getChildByName("limitzhe")
	end

	-- -----------------
	-- Init Base Class
	-- -------------------
	BubbleItemPreGame.init(self, self.bubbleItem, self.itemId, self.isTimeProp)
	-- BubbleItem.init(self, self.bubbleItem, itemId)

	------------------
	-- Get Data About UI
	----------------------
	local labelColor = self.priceLabel:getColor()
	self.priceLabelOriginColor = ccc3(labelColor.r, labelColor.g, labelColor.b)

	--  ------------------
	--  Init UI Resource
	--  ----------------
	self.checkIcon:setVisible(false)
	-- self:setNumberVisible(false)
	self.priceLabel:setVisible(false)
	self.unlockLabel:setVisible(false)
	
	local newAnchorPoint = ccp(0.5,0)
	self.lock:setAnchorPointWhileStayOriginalPosition(newAnchorPoint)

	--print("------------self.isVideoAdOpenV2",self.isVideoAdOpen,self.isVideoAdOpenV2,self.isVideoAdOpen and not self.isVideoAdOpenV2)
	if self.videoadBtn:isVisible() then
		self:playVideoAdAnim()
	end

	local size = self.priceLabel:getGroupBounds().size
	local position = self.priceLabel:getPosition()
	self.animLabel = LabelBMMonospaceFont:create(20, 35, 15, "fnt/target_amount.fnt")
	self.animLabel:setAnchorPoint(ccp(0, 1))
	self.animLabel:setPosition(ccp(position.x - 20, position.y))
	self.animLabel:setVisible(false)
	self:addChild(self.animLabel)
	self.iconPos = {x = self.coinIcon:getPosition().x, y = self.coinIcon:getPosition().y}

	-- Get Property Attribute
	local realPropId = ItemType:getRealIdByTimePropId(self.itemId)
	local propData = MetaManager.getInstance().prop[realPropId]
	assert(propData)

	-- Check If Locked
	local unLockLevel = propData.unlock
	assert(unLockLevel)

	if unLockLevel > self.levelId then
		self.locked = true
	else
		self.locked = false
	end

	-- Get Property Price
	self.discountActivityGoodsID = nil
	self:refreshGoodsData()

	self:initView()
	self:playBubbleNormalAnim(true)

	self.waitAdState = true
end

function PreGameToolItem:refreshGoodsData()
	local propAsGoodsData = self:getSelfGoodsData()
	if propAsGoodsData then
		self.origPrice = 0
		if propAsGoodsData.coin > 0 then
			self.price = propAsGoodsData.coin
		else
			self.price = 999
			-- self:setIsHappyCoinItem(true)
			if propAsGoodsData.qCash > 0 then
				self.price = propAsGoodsData.qCash
			end
			if propAsGoodsData.discountQCash > 0 then
				self.price = propAsGoodsData.discountQCash
				self.origPrice = propAsGoodsData.qCash
			end
		end
		assert(self.price)
	else
		self.price = 9999	-- 随便吧，应该不会走到这里..
	end

	self.realPrice = self.price
end

function PreGameToolItem:initView()
	local realPropId = ItemType:getRealIdByTimePropId(self.itemId)
	local propData = MetaManager.getInstance().prop[realPropId]
	assert(propData)

	-- Check If Locked
	local unLockLevel = propData.unlock
	assert(unLockLevel)

	if unLockLevel > self.levelId then
		self.locked = true
	else
		self.locked = false
	end
	
	self.videoadBtn:setVisible(self.isVideoAdOpen and not self.isVideoAdOpenV2)
	self.videoadBtnV2:setVisible(self.isVideoAdOpenV2)

	--------------------
	---- Update View
	--------------------
	if self.locked then
		-- Locked
		self.lock:setVisible(true)
		self.unlockLabel:setVisible(true)
		self.priceLabel:setVisible(false)

		self.coinIcon:setVisible(false)
		self:setHappyCoinAssociatedViewVisible(false)

		local stringKey		= "start.game.panel.unlock.txt"
		local stringValue 	= Localization:getInstance():getText(stringKey, {level_number = unLockLevel})
--        self.unlockLabel:changeFntFile('fnt/skip_level_word_halloween.fnt')
		self.unlockLabel:setString(stringValue)
		self.unlockLabel:setAnchorPointCenterWhileStayOrigianlPosition()
--        self.unlockLabel:setColor( hex2ccc3('9966CC') )
		self.numTip:setVisible(false)
		self.timeLimitIcon:setVisible(false)
		self.timeLimitLabel:setVisible(false)
		if self.timeLimitIcon2 then
			self.timeLimitIcon2:setVisible(false)
		end

		--lock为true时,加载蒙灰的前置道具素材
		if self.itemRes and (not self.itemRes.isDisposed) then
			local spriteFrameName = 'z_new_2017_game/mask_prop/item_'..realPropId..'0000'
			if CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(spriteFrameName) then
				local maskPropSprite = Sprite:createWithSpriteFrameName(spriteFrameName)
				maskPropSprite:setAnchorPoint(ccp(0.5, 0.5))
				local size = self.itemRes:getContentSize()
				maskPropSprite:setPosition(ccp(size.width/2, size.height/2))
				self.itemRes:addChild(maskPropSprite)
				self.itemRes:setOpacity(0)
			end
		end
	else
		-- Unlocked
		self.lock:setVisible(false)
		self.unlockLabel:setVisible(false)
		self.priceLabel:setVisible(not self.isVideoAdOpen)
		self.priceLabel:setString(self.price)
		self.animLabel:setString('-'..tostring(self.price))
		if ItemType:isHappyCoinPreProps(self.itemId) then
			self.coinIcon:setVisible(false)
			self:refreshDiscountViews()
			self._happyCoinDisplayVisible = true
		else
			self:setHappyCoinAssociatedViewVisible(false)
		end
	end

	self:updatePriceColor()

	-----------------
	-- Get Data About UI
	-- ------------------
	--self.priceLabelOriginalScaleX = self.priceLabel:getScaleX()
	--self.priceLabelOriginalScaleY = self.priceLabel:getScaleY()
	self.unlockLabelOriginalScaleX	= self.unlockLabel:getScaleX()
	self.unlockLabelOriginalScaleY	= self.unlockLabel:getScaleY()

	--------------
	-- Play Animation
	-- ----------------

	if self.itemNumber > 0 then
		self:setFreePrice()
		self:updatePriceColor()
		self:updateTimeLimitIcon()
	end

	--小于24小时 否则显示限时
	if self.isTimeProp and self.timeLeft ~= nil and self.locked == false   then
		if self.timeLeft < showLabelTime48 then
			self:updateTimeLabel( self.timeLeft )
			self.timeLimitLabel:setVisible(not self.isVideoAdOpen)
			self.scheduleScriptFuncID = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function() self:updateTimeLabel() end, 1, false)
		else
			if self.timeLimitIcon2 then
				self.timeLimitIcon2:setVisible(not self.isVideoAdOpen)
			end
		end
	end

	if self.isVideoAdOpen then
		if self.isVideoAdOpenV2 then
			self:setFreePrice()
		else
			local num = getRedNumTip()
			num:setNum(1)
			num:setPositionXY(130, -20)
		    self.videoadBtn:addChild(num)

			self.numTip:setVisible(false)
		end
		
	    DcUtil:adsIOSClick({
	    		sub_category = "level_start_adv",
				entry = EntranceType.kStartLevel,
	    	}, true)

		self.priceLabel:setVisible(false)
		self.animLabel:setVisible(false)
		self.coinIcon:setVisible(false)
		self:setHappyCoinAssociatedViewVisible(false)
		self._priceBg:setVisible(false)
		self.privilegeIcon:setVisible(false)
		self.timeLimitIcon:setVisible(false)
		self.timeLimitLabel:setVisible(false)
		if self.timeLimitIcon2 then
			self.timeLimitIcon2:setVisible(false)
		end

		local version = InciteManager:getSceneUIVersion(EntranceType.kStartLevel)
		local ONCE_TIP_KEY = "PreGameToolItem.video.ONCE_TIP_KEY"
		print("version ONCE_TIP_KEY",version,_G[ONCE_TIP_KEY])

        local bShowJumpLevelGuide = JumpLevelManager:getInstance():bCanShowJumpLevelGuide(self.levelId)
		if version == 3 and not _G[ONCE_TIP_KEY] and not bShowJumpLevelGuide then
			_G[ONCE_TIP_KEY] = true
			self.videoadBtnV2:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.8), CCCallFunc:create(function()
				self:showVideoAdTip(localize("watch_ad_startlevel_tip1", {n = '\n'}))
			end)))
		end
	end
end

local oneFrameTime = 1/24
function PreGameToolItem:showFreeBubbleAni()
	if self.bubbleAniWrapLayer then
		local arr = CCArray:create()
		local arr1 = CCArray:create()
		local arr2 = CCArray:create()
		arr1:addObject(CCRotateTo:create(oneFrameTime * 4, -10))
		arr1:addObject(CCRotateTo:create(oneFrameTime * 4, 10))
		arr1:addObject(CCRotateTo:create(oneFrameTime * 4, -10))
		arr1:addObject(CCRotateTo:create(oneFrameTime * 4, 10))
		arr1:addObject(CCRotateTo:create(oneFrameTime * 8, 0))
		arr1:addObject(CCDelayTime:create(oneFrameTime * 35))

		arr2:addObject(CCScaleTo:create(oneFrameTime * 4, 1.1))
		arr2:addObject(CCDelayTime:create(oneFrameTime * 12))
		arr2:addObject(CCScaleTo:create(oneFrameTime * 8, 1))

		arr:addObject(CCSequence:create(arr1))
		arr:addObject(CCSequence:create(arr2))
		self.bubbleAniWrapLayer:runAction(CCRepeatForever:create(CCSpawn:create(arr)))
	end
end

function PreGameToolItem:stopFreeBubbleAni()
	if self.bubbleAniWrapLayer then
		self.bubbleAniWrapLayer:stopAllActions() 
		self.bubbleAniWrapLayer:setRotation(0)
		self.bubbleAniWrapLayer:setScale(1)
	end
end

function PreGameToolItem:setHappyCoinAssociatedViewOpacity(opacity)
	-- printx(11, "= = = set happy coin opacity:", opacity)
	self.happyCoinIcon:setOpacity(opacity)

	if self.oldPriceTxt then self.oldPriceTxt:setOpacity(opacity) end
	if self.oldPriceBlocker then self.oldPriceBlocker:setOpacity(opacity) end
	if self.discountTag then 
		-- self.discountTag:setOpacity(opacity)
		self.discountPercentTxt:setOpacity(opacity)
		self.limitMark:setOpacity(opacity)
	end
end

function PreGameToolItem:setHappyCoinAssociatedViewVisible(visibleFlag)
	-- printx(11, "= = = set happy coin visible:", visibleFlag)
	self.happyCoinIcon:setVisible(visibleFlag)

	if self.showDiscountContent and visibleFlag then
		if self.oldPriceTxt then self.oldPriceTxt:setVisible(true) end
		if self.oldPriceBlocker then self.oldPriceBlocker:setVisible(true) end
		if self.discountTag then self.discountTag:setVisible(true) end
	else
		if self.oldPriceTxt then self.oldPriceTxt:setVisible(false) end
		if self.oldPriceBlocker then self.oldPriceBlocker:setVisible(false) end
		if self.discountTag then self.discountTag:setVisible(false) end
	end

	self._happyCoinDisplayVisible = visibleFlag
end

function PreGameToolItem:isHappyCoinDisplayVisible()
	return self._happyCoinDisplayVisible
end

function PreGameToolItem:getSelfGoodsData()
	local propAsGoodsData = false

	local goodsID = self.discountActivityGoodsID or ItemType:getGoodsIDOfPreProps(self.itemId)
	if goodsID then
		propAsGoodsData = MetaManager.getInstance():getGoodMeta(goodsID)
	else
		local realPropId = ItemType:getRealIdByTimePropId(self.itemId)
		-- Get Property Price
	
		local goodsDataTable = MetaManager.getInstance().goods
		assert(goodsDataTable)
		for k,v in pairs(goodsDataTable) do
			if v.items[1].itemId == realPropId then
				propAsGoodsData = v
			end
		end
	end

	assert(propAsGoodsData)
	return propAsGoodsData
end

function PreGameToolItem:showLightFlash(...)
	if self.itemNumber<=0 then
		return
	end

	local center = Sprite:createWithSpriteFrameName('shining0001')
	local size = center:getContentSize()
	center:setPosition(ccp(size.width*0.5-8,size.height*0.5-4))
	local animate = SpriteUtil:buildAnimate(SpriteUtil:buildFrames("shining%04d", 1, 22), 1/26)
	local arr = CCArray:create()
	arr:addObject(CCFadeIn:create(0.2))
	arr:addObject(animate)
	arr:addObject(CCFadeOut:create(0.4))
	arr:addObject(CCDelayTime:create(0.6))
	local seq = CCSequence:create(arr)
	local repeatAction = CCRepeatForever:create(seq)
    center:runAction(repeatAction)
	self.bubble:addChildAt(center,99)
end

function PreGameToolItem:createShakeLockAction(...)
	assert(#{...} == 0)

	local rotateAngle 	= 10
	local rotateTime	= 0.05

	local actionArray = CCArray:create()
	
	-- Rotate
	local rotateLeft 	= CCRotateTo:create(rotateTime, -rotateAngle)
	local rotateRight	= CCRotateTo:create(rotateTime*2, rotateAngle)
	-- Seq
	local rotate 		= CCSequence:createWithTwoActions(rotateLeft, rotateRight)
	local repeat3Time	= CCRepeat:create(rotate, 3)
	
	-- Rotate To Original
	local rotateOrigin	= CCRotateTo:create(rotateTime, 0)

	actionArray:addObject(repeat3Time)
	actionArray:addObject(rotateOrigin)
	local seq = CCSequence:create(actionArray)
	local targetedSeq = CCTargetedAction:create(self.lock.refCocosObj, seq)

	return targetedSeq
end

function PreGameToolItem:createEnlargeShrinkLabelAction(...)
	assert(#{...} == 0)

	local enlargeScale	= 1.2
	local enlargeDuration	= 0.2
	local restoreDuration	= 0.1

	--local anchorPoint = self.priceLabel:getAnchorPoint()
	--assert(anchorPoint.x == 0.5 and
	--	anchorPoint.y == 0.5)

	--local origScaleX	= self.priceLabel:getScaleX()
	--local origScaleY	= self.priceLabel:getScaleY()
	--local origScaleX	= self.priceLabelOriginalScaleX
	--local origScaleY	= self.priceLabelOriginalScaleY
	local origScaleX	= self.unlockLabelOriginalScaleX
	local origScaleY	= self.unlockLabelOriginalScaleY

	local newScalX	= origScaleX * enlargeScale
	local newScalY	= origScaleY * enlargeScale

	-- Enlarge Action
	local enlarge	= CCScaleTo:create(enlargeDuration, enlargeScale)
	-- Restore To Original
	local restore	= CCScaleTo:create(restoreDuration, origScaleX, origScaleY)
	-- Sequence
	local sequence	= CCSequence:createWithTwoActions(enlarge, restore)
	local targetSeq	= CCTargetedAction:create(self.unlockLabel.refCocosObj, sequence)

	--return sequence
	return targetSeq
end

function PreGameToolItem:playVideoAdAnim()
	local btn = self.videoadBtn:getChildByName("s")
	btn:setAnchorPointCenterWhileStayOrigianlPosition()
	local deltaTime = 0.9
	local factor = 0
	local scaleX = btn:getScaleX()
	local scaleY = btn:getScaleY()
	local animations = CCArray:create()
	animations:addObject(CCScaleTo:create(deltaTime, scaleX * 0.98 * (1 - factor), scaleY * 1.03 * (1 - factor)))
	animations:addObject(CCScaleTo:create(deltaTime, scaleX * 1.01 * (1 + factor), scaleY * 0.96 * (1 + factor)))
	animations:addObject(CCScaleTo:create(deltaTime, scaleX * 0.98 * (1 - factor), scaleY * 1.03 * (1 - factor)))
	animations:addObject(CCScaleTo:create(deltaTime, scaleX * 1, scaleY * 1))
	local action = CCRepeatForever:create(CCSequence:create(animations))
	btn:runAction(action)
	-- btn:setButtonMode(false)
end

function PreGameToolItem:playShakeLockAndLabelAnim(animFinishCallback, ...)
	assert(animFinishCallback == false or type(animFinishCallback) == "function")
	assert(#{...} == 0)

	local shakeLockAct 	= self:createShakeLockAction()
	local labelAction	= self:createEnlargeShrinkLabelAction()
	-- Spawn
	local spawn		= CCSpawn:createWithTwoActions(shakeLockAct, labelAction)

	-- Callback 
	local function animFinish()
		if animFinishCallback then
			animFinishCallback()
		end
	end
	local animFinishAction = CCCallFunc:create(animFinish)

	-- Seq
	local actionArray = CCArray:create()
	--actionArray:addObject(shakeLockAct)
	--actionArray:addObject(labelAction)
	actionArray:addObject(spawn)
	actionArray:addObject(animFinishAction)

	--local seq = CCSequence:createWithTwoActions(shakeLockAct, animFinishAction)
	local seq = CCSequence:create(actionArray)
	self:runAction(seq)
end

function PreGameToolItem:getPrice(...)
	assert(#{...} == 0)

	return self.price
end

function PreGameToolItem:getRealPrice(...)
	assert(#{...} == 0)

	return self.realPrice
end


function PreGameToolItem:updatePriceColor(...)
	assert(#{...} == 0)
	if self.isDisposed then return end
	if self.isTimeProp then
		if not self:isSelected() then
			self.priceLabel:setVisible(false)
			self.coinIcon:setVisible(false)
			self:setHappyCoinAssociatedViewVisible(false)
			self._priceBg:setVisible(false)
		else
			self.priceLabel:setVisible(true)
			if ItemType:isHappyCoinPreProps(self.itemId) then
				self:setHappyCoinAssociatedViewVisible(true)
			else
				self.coinIcon:setVisible(true)
			end
			self._priceBg:setVisible(true)
		end
	else
		self.timeLimitIcon:setVisible(false)
		self.timeLimitLabel:setVisible(false)
		local curCoin = UserManager.getInstance().user:getCoin()
		
		if type(self.price) == 'number' then -- qixi
			if ItemType:isHappyCoinPreProps(self.itemId) or self.price <= curCoin then
				self.priceLabel:changeFntFile('fnt/skip_level_word.fnt')
				--self.priceLabel:setString(self.price)
			else
				if not self:isSelected() and 
					not self:isLocked() then
					if _G.isLocalDevelopMode then printx(0, 'updatePriceColor setColor') end
					self.priceLabel:changeFntFile('fnt/skip_level_word2.fnt')
					--self.priceLabel:setString(self.price)
				end
			end
		else
			self.priceLabel:changeFntFile('fnt/skip_level_word.fnt')
			--self.priceLabel:setString(self.price)
		end
	end
	self:updateTimeLimitIcon()
end



function PreGameToolItem:getItemId(...)
	assert(#{...} == 0)

	return self.itemId
end

------------------------------------------
---- About Selected
--------------------------------------

function PreGameToolItem:isSelected(...)
	assert(#{...} == 0)

	return self.selected
end

function PreGameToolItem:setSelected(selected, ...)
	print("PreGameToolItem:setSelected",selected)
	assert(selected ~= nil)
	assert(#{...} == 0)

	local t = os.time()
	if self.lastSet~=nil and self.lastSet==selected and self.lastSetTimer and t-self.lastSetTimer<2 then
		return
	end
	self.lastSet = selected
	self.lastSetTimer = t

	local __CostMoneyType = GamePreStartContext:getCostMoneyTypeConfig()
	if self.isVideoAdOpen then
		if self.isVideoAdOpenV2 then
			if selected then
				if self.videoAdPlayed then
					self:onPlayVideoFinsihed()
				else
					local count = UserManager:getInstance():getUserPropNumber(self.itemId)
					if count>0 then
						--数量大于0，有数据，则显示 广告or直接使用 面板
						local goodsID = ItemType:getGoodsIDOfPreProps(self.itemId)
						if not goodsID then
							--如果是限时魔力鸟，改为取普通魔力鸟的购物信息
							local mockGoodsID = ItemType:getGoodsIDOfPreProps(ItemType.PRE_RANDOM_BIRD)
							goodsID = GoodsIdInfoObject:create(mockGoodsID)
							goodsID.trueItemId = self.itemId
						end
						self:showPayPanelWindMill(selected,goodsID)
					else
						--没有则触发购买
						self:onBuyPropsByHappyCoins(selected)
					end
					
					DcUtil:adsIOSClick({
								sub_category = "click_level_start_adv",
							})
				end
			else
				self:updateSelectStatus(selected)
				self:updateCornerNumber()
			end
		else
			--show tip
			local str = localize("watch_ad_startlevel_tip1", {n = '\n'})
			if self.videoAdPlayed then
				str = localize("watch_ad_startlevel_tip2", {n = '\n'})
			end
			self:showVideoAdTip(str)
		end
	elseif selected and self.itemNumber == 0 and ItemType:isHappyCoinPreProps(self.itemId) then
		GamePreStartContext:getInstance():selectPreProps( selected , self , self:getRealPrice() , __CostMoneyType.kGold , false )
		self:onBuyPropsByHappyCoins(selected)
	else

		if ItemType:isHappyCoinPreProps(self.itemId) then
			if self.itemNumber > 0 then
				GamePreStartContext:getInstance():selectPreProps( selected , self , 0 , __CostMoneyType.kInBag , true )
			end
		else
			if self.itemNumber > 0 then
				GamePreStartContext:getInstance():selectPreProps( selected , self , 0 , __CostMoneyType.kInBag , true )
			else
				GamePreStartContext:getInstance():selectPreProps( selected , self , self:getRealPrice() , __CostMoneyType.kCoin , true )
			end
		end

		self:updateSelectStatus(selected)
	end
end

function PreGameToolItem:showVideoAdTip( tipstr )
	if self.isDisposed then return end

	local function autoHide()
		if self.isDisposed then return end
		if not self.videoadBtnV2 then return end
		self.videoadBtnV2:stopAllActions()
		self.videoadBtnV2:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(3), CCCallFunc:create(function()
			self:hideVideoAdTip()
		end)))
	end

	if self.videoAdTip then
		autoHide()
		-- cancelTimeOut(self.videoAdTip.timeId)
		return
	end


	self.videoAdTip = ResourceManager:sharedInstance():buildGroup("ui_groups/new_tip_bg")
	local desc = BitmapText:create(tipstr, 'fnt/register2.fnt')
	desc:setColor(ccc3(152, 94, 65))
	desc:setScale(0.7)
	desc:setPosition(ccp(20, 40))
	self.videoAdTip:addChild(desc)


	self.videoAdTip:setTouchEnabled(true, 0, true)
	local function __onTouchDelegate(event)
		autoHide()
	end
	self.videoAdTip:addEventListener(DisplayEvents.kTouchTap, __onTouchDelegate)

	local touchLayer = Layer:create()
	local visibleSize = Director:sharedDirector():getVisibleSize()
	local visibleOrigin = Director:sharedDirector():getVisibleOrigin()
	touchLayer:setAnchorPoint(ccp(0,0))
	touchLayer:setPosition(ccp(visibleOrigin.x, visibleOrigin.y))
	touchLayer:changeWidthAndHeight(visibleSize.width, visibleSize.height)
	touchLayer:setTouchEnabled(true, 0, false)
	Director:sharedDirector():getRunningScene():addChild(touchLayer, SceneLayerShowKey.POP_OUT_LAYER)

	touchLayer:addEventListener(DisplayEvents.kTouchBegin, autoHide, nil)

	self.videoAdTip.touchLayer = touchLayer

	local scene = Director:sharedDirector():getRunningScene()
	-- local pos = self.ui:convertToWorldSpace(ccp(0, 0))
	-- self.videoAdTip:setPosition(ccp(pos.x + 70, pos.y - 10))
	-- scene:addChild(self.videoAdTip, SceneLayerShowKey.POP_OUT_LAYER)

	local function findTarget(n)
		local node = n:getParent()
		if not node then return end
		if node.panelLuaName == "LevelInfoPanel" then
			return node
		else
			return findTarget(node)
		end
	end

	local levelInfoPanel = findTarget(self)
	if levelInfoPanel then
		levelInfoPanel:addChild(self.videoAdTip)
		self.videoAdTip:setPosition(ccp(150, -620))
	end

	self.videoAdTip:setScale(0)

	local t1 = CCScaleTo:create(0.2, 1.11)
	local t2 = CCScaleTo:create(0.1, 0.9)
	local t3 = CCScaleTo:create(0.1, 1.0)

	local actionArray = CCArray:create()
	actionArray:addObject(t1)
	actionArray:addObject(t2)
	actionArray:addObject(t3)

	self.videoAdTip:runAction(CCSequence:create(actionArray))

	autoHide()
	-- self.videoAdTip.timeId = setTimeOut(hide, 3)
end

function PreGameToolItem:hideVideoAdTip()
	if not self.videoAdTip then return end
	if self.isDisposed then return end
	if not self:getParent() or self:getParent().isDisposed then return end

	self.videoadBtnV2:stopAllActions()

	if self.videoAdTip.touchLayer then
		self.videoAdTip.touchLayer:removeFromParentAndCleanup(true)
	end

	self.videoAdTip:removeFromParentAndCleanup(true)
	self.videoAdTip.touchLayer:removeFromParentAndCleanup(true)
	-- cancelTimeOut(self.videoAdTip.timeId)
	self.videoAdTip = nil

end

function PreGameToolItem:isFromFreeVideo()
	if self.isVideoAdOpenV2 then
		return self.videoAdPlayed
	end
	return self.isVideoAdOpen
end

function PreGameToolItem:onPlayVideoFinsihed()
	print("PreGameToolItem:onPlayVideoFinsihed()")
	if self.ui.isDisposed then return end

	self.videoadBtnV2:setVisible(false)

	BubbleItem.updateItemNumber(self)
	if self.itemNumber > 0 then
		self:setFreePrice()
		self:updatePriceColor()
	else
		--本局开始就有1个免费{n}魔力鸟
		self:showVideoAdTip(localize("watch_ad_startlevel_tip2", {n = '\n'}))
	end
	self.priceLabel:setVisible(true)
	self:updateSelectStatus(true)
	self.videoadBtn:setVisible(false)
	self.videoAdPlayed = true

	local data = 
	{
		sub_category = "show_reward",
		entry = EntranceType.kStartLevel,
		reward_id1 = self.itemId,
	}
	DcUtil:adsIOSReward(data)

	local __CostMoneyType = GamePreStartContext:getCostMoneyTypeConfig()
	GamePreStartContext:getInstance():selectPreProps( true , self , 0 , __CostMoneyType.kPlayVideo , true )
end

function PreGameToolItem:onTapVideoAdBtn()
	if self.isVideoAdOpen then
		local function onPlayFinsihed(ads, placementId, state)
			if state == AdsFinishState.kCompleted then
				self:onPlayVideoFinsihed()
			end
		end

		local function onPlayError( ads, code, msg )
			
		end

		InciteManager:showAds(EntranceType.kStartLevel, onPlayFinsihed, onPlayError)
	end
end

function PreGameToolItem:onBoughtCallback(selected)
	-- if _G.isLocalDevelopMode then printx(0, "onBoughtCallback", propId, propNum) end
	-- self:onBoughtCallback(propId, propNum)
	-- self.propList:setItemTouchEnabled(true)
	-- self.gamePlayScene:setGameRemuse()
	-- self._isBuyPropPause = false

	BubbleItem.updateItemNumber(self)
	if self.itemNumber > 0 then
		-- 不显示折扣了，换回来……
		if self.priceLabelRelocatedByDiscountView then
			self.priceLabelRelocatedByDiscountView = false

			if self.oldPriceTxt then
				self.priceLabel:setRectPositionX(self.oldPriceTxt:getPositionX() + 5)
			end
		end

		self:setFreePrice()
		self:updatePriceColor()
	end
	self:updateSelectStatus(selected)

	local __CostMoneyType = GamePreStartContext:getCostMoneyTypeConfig()
	GamePreStartContext:getInstance():selectPreProps( selected , self , self:getRealPrice() , __CostMoneyType.kGold , true )
end

function PreGameToolItem:onBuyPropsByHappyCoins(selected)
	-- if self.inBuyPropsProcess then return end
	local propId = self.itemId
	-- 参与打折活动时，取活动中的GoodsID
	-- 能看视频时不开放活动
	local goodsID = self.discountActivityGoodsID or ItemType:getGoodsIDOfPreProps(propId)
	if not goodsID then return end

	local isFreeVideo = self.isVideoAdOpenV2

	if __ANDROID then -- ANDROID
		self.androidPaymentLogic = IngamePaymentLogic:create(goodsID, GoodsType.kItem, DcFeatureType.kStageStart, DcSourceType.kPreProp)
		self.androidPaymentLogic:setSourceFlag("buyPrePropsByInfoPanel")
		local function onAndroidSuccess(buyNum, startPos)
			-- print("onOtherSuccess()",buyNum, startPos)
			self.androidPaymentLogic = nil
			if buyNum == -1 then
				self:onPlayVideoFinsihed()
			else
				self:onBoughtCallback(selected)
			end
		end
		-- self.propList:setItemTouchEnabled(false)
		-- self.androidPaymentLogic:setRepayPanelPopFunc(function ()
		-- 	self.gamePlayScene:setGameStop()
		-- 	self._isBuyPropPause = true	
		-- end)
		self.androidPaymentLogic:buy(onAndroidSuccess, onExitCallbackFail, onExitCallbackCancel,nil,nil,isFreeVideo)
	else -- else, on IOS and PC we use gold!
		-- self.propList:setItemTouchEnabled(false)
		self:showPayPanelWindMill(selected,goodsID)
	end
end

function PreGameToolItem:showPayPanelWindMill(selected,goodsID)
	local function onOtherSuccess(buyNum, startPos)
		-- print("PreGameToolItem:showPayPanelWindMill()onOtherSuccess()",buyNum, startPos)
		if buyNum == 0 then
			--直接使用已有道具
			self:updateSelectStatus(true)
		elseif buyNum == -1 then
			--看视频免费道具
			self:onPlayVideoFinsihed()
		else
			self:onBoughtCallback(selected)
		end
	end

	local onExitCallbackCancel = nil
	local isFreeVideo = self.isVideoAdOpenV2
	goodsID = goodsID or ItemType:getGoodsIDOfPreProps(self.itemId)	--非看视频情况下必然有goodsID
	local panel = PayPanelWindMill_VerB:create(goodsID, onOtherSuccess, onExitCallbackCancel, nil, true, 1,isFreeVideo)	-- 一次只许买一个

	-- self.androidPaymentLogic = IngamePaymentLogic:create(goodsID, GoodsType.kItem, DcFeatureType.kStageStart, DcSourceType.kPreProp)
	-- self.androidPaymentLogic:setSourceFlag("buyPrePropsByInfoPanel")
	-- local peDispatcher = self.androidPaymentLogic:getPaymentEventDispatcher()
	-- self.androidPaymentLogic.goodsIdInfo.isFreeVideo = true
	-- self.androidPaymentLogic.goodsIdInfo.videoCallback = onOtherSuccess
	-- local panel = PayPanelSingleSms_VerB:create(peDispatcher, self.androidPaymentLogic.goodsIdInfo, paymentType, nil, useDarkSkin)

	if panel then 
		local _ = panel.setFeatureAndSource and panel:setFeatureAndSource(DcFeatureType.kStageStart, DcSourceType.kPreProp)
		panel:popout() 
	end
end

function PreGameToolItem:updateSelectStatus(selected)
	--print("PreGameToolItem:updateSelectStatus()",selected,debug.traceback())
	if selected then
		-- Select It
		self.selected = true
		self:playBubbleExplodedAnim(false)

		self.videoadBtnV2:setVisible(false)


		if not self:isFreeItem() then
			GamePlayMusicPlayer:playEffect( GameMusicType.kPlayCoinCollect )
		end
	else
		-- UnSelect It
		self.selected = false
		self:playBubbleNormalAnim(true)

		self.videoadBtnV2:setVisible(self.isVideoAdOpenV2 and not self.videoAdPlayed)
	end
	self:updateCornerNumber()
	self:updateTimeLimitIcon()
end

function PreGameToolItem:updateCornerNumber()
	if self.selected then
		self.numTip:setVisible(false)
	else
		if self.itemNumber > 0 then
			self.numTip:setVisible(true)
		else
			self.numTip:setVisible(false)
		end
	end
end

function PreGameToolItem:playBubbleExplodedAnim(finishCallback)
	if self.isDisposed then return end
	self:stopAllActions()
	self:stopBubbleAnim()
	BubbleItem.playBubbleExplodedAnim(self, finishCallback)
	self.priceLabel:setString(Localization:getInstance():getText("start.game.panel.preprop.item.selected"))
	local position = self.priceLabel:getPosition()
	if not self:isFreeItem() and not self:isPrivilegeFree() and not self.isVideoAdOpen then
		self.animLabel:stopAllActions()
		self.animLabel:setPosition(ccp(position.x - 20, position.y + 32))
		self.animLabel:setVisible(true)
		self.animLabel:delayFadeOut(0, 1.2)
		self.animLabel:runAction(CCMoveBy:create(1.2, ccp(0, 50)))
	end
	local array = CCArray:create()
	array:addObject(CCFadeOut:create(0.3))
	array:addObject(CCMoveBy:create(0.3, ccp(-20, -50)))
	array:addObject(CCScaleTo:create(0.3, 1.2))
	self.coinIcon:stopAllActions()
	self.coinIcon:runAction(CCSpawn:create(array))
	-- self.happyCoinIcon:setOpacity(0)	--不会出现花风车币后选中的情况，能选中必然是背包中有，故无需动画
	self:setHappyCoinAssociatedViewOpacity(0)
	self.checkIcon:stopAllActions()
	self.checkIcon:setAnchorPointCenterWhileStayOrigianlPosition()
	self.checkIcon:setScale(2)
	self.checkIcon:setOpacity(0)
	self.checkIcon:setVisible(true)
	self.checkIcon:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.3), CCSpawn:createWithTwoActions(CCFadeIn:create(0.2), CCScaleTo:create(0.2, 1))))
end

function PreGameToolItem:playBubbleNormalAnim(repeatForever)
	if self.isDisposed then return end
	self:stopAllActions()
	self:stopBubbleAnim()
	BubbleItem.playBubbleNormalAnim(self, repeatForever)
	self.priceLabel:setString(tostring(self.price))
	self.animLabel:stopAllActions()
	self.animLabel:setVisible(false)
	if ItemType:isHappyCoinPreProps(self.itemId) then
		-- self.happyCoinIcon:setOpacity(255)
		self:setHappyCoinAssociatedViewOpacity(255)
	else
		self.coinIcon:stopAllActions()
		self.coinIcon:setPosition(ccp(self.iconPos.x, self.iconPos.y))
		self.coinIcon:setScale(1)
		self.coinIcon:setOpacity(255)
	end
	self.checkIcon:stopAllActions()
	self.checkIcon:setVisible(false)
end

----------------------------------------
------ About Locked
----------------------------------

function PreGameToolItem:isLocked(...)
	assert(#{...} == 0)

	return self.locked
end

function PreGameToolItem:setLocked(lock, ...)
	assert(lock ~= nil)
	assert(#{...} == 0)

	if lock ~= nil then
		assert(type(lock) == "boolean")
	end

	self.locked = lock

	if self.locked then
		self.lock:setVisible(true)
	else 
		self.lock:setVisible(false)
	end
end

--特权功能限时免费使用指定前置道具 使用走buff功能 这里用于显示和屏蔽点击等
function PreGameToolItem:setIsPrivilegeFree(isPriFree)
	if not self.locked then 
		self._isPrivilegeFree = isPriFree
	else
		self._isPrivilegeFree = false
	end

	if self._isPrivilegeFree then 
		self.priceLabel:setVisible(false)
		self.animLabel:setVisible(false)
		self.coinIcon:setVisible(false)
		self:setHappyCoinAssociatedViewVisible(false)
		self._priceBg:setVisible(false)
		self.privilegeIcon:setVisible(true)
		self:playBubbleExplodedAnim(false)
		self.numTip:setVisible(false)
		self.timeLimitIcon:setVisible(false)
		self.timeLimitLabel:setVisible(false)
		if self.timeLimitIcon2 then
			self.timeLimitIcon2:setVisible(false)
		end
	end
end

function PreGameToolItem:isPrivilegeFree()
	return self._isPrivilegeFree
end

function PreGameToolItem:isBuyWithHappyCoin()
	return ItemType:isHappyCoinPreProps(self.itemId)
end

function PreGameToolItem:create(ui, itemId, levelId, ...)
	assert(ui)
	assert(itemId)
	assert(type(itemId) == "number")
	assert(levelId)
	assert(type(levelId) == "number")
	assert(#{...} == 0)

	
	local newPreGameToolItem = PreGameToolItem.new()
	newPreGameToolItem:init(ui, itemId, levelId)
	return newPreGameToolItem
end

-- qixi
function PreGameToolItem:setFreePrice(forceFree)
	self.price = '免费'
	-- self.priceLabel:setString('免费')
	-- self.animLabel:setString('免费')
	self.priceLabel:setVisible(false)
	self.animLabel:setVisible(false)
	self.coinIcon:setVisible(false)
	self:setHappyCoinAssociatedViewVisible(false)
	self._priceBg:setVisible(false)
	if not forceFree and self.timeLeft ~= nil then
		self.timeLimitIcon:setVisible(false)
		if self.timeLeft < showLabelTime48 then
			self.timeLimitLabel:setVisible(true)
			if self.timeLimitIcon2 then
				self.timeLimitIcon2:setVisible(false)
			end
		else
			self.timeLimitLabel:setVisible(false)
			if self.timeLimitIcon2 then
				self.timeLimitIcon2:setVisible(true)
			end
		end

	else
		self.timeLimitIcon:setVisible(true)
		if self.timeLimitIcon2 then
			self.timeLimitIcon2:setVisible(false)
		end
		self.timeLimitLabel:setVisible(false)
	end
	self._isFreeItem = true
end

function PreGameToolItem:isFreeItem()
	return self._isFreeItem == true
end

--引导时会免费送一个 这里临时加一下 兼容可购买时弹购买面板的判定
function PreGameToolItem:fakeIncreaseItemNumber()
	self.itemNumber = self.itemNumber + 1
end

function PreGameToolItem:dispose()
	if self.scheduleScriptFuncID ~= nil then 
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduleScriptFuncID) 
		self.scheduleScriptFuncID = nil
	end

	-- tip改为和在 levelInfoPanel 上，不再需要额外销毁
	-- self:hideVideoAdTip()

	if self.videoAdTip and self.videoAdTip.touchLayer then
		self.videoAdTip.touchLayer:removeFromParentAndCleanup(true)
	end

	BubbleItemPreGame.dispose(self)
end

function PreGameToolItem:updateTimeLabel( timeLeft )

	if self.isDisposed then return end
		
	if self.scheduleScriptFuncID ~= nil then 
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduleScriptFuncID) 
		self.scheduleScriptFuncID = nil
	end

	if timeLeft then
		self.timeLeft = timeLeft
	else
		if self.timePropExpireTime then
			self.timeLeft = math.floor(( self.timePropExpireTime  - Localhost:time()) / 1000)
		else
			self.timeLeft = self.timeLeft -1
		end
	end
	local cdInSec = self.timeLeft

	-- if _G.isLocalDevelopMode  then printx(100 , "PreGameToolItem:create cdInSec =" , cdInSec ) end

	if self.timelabel then
		local strTime = getTimeFormatString(cdInSec, 1)
		self.timelabel:setString( strTime )
	end

	--换背景 
	local cIdx = 100
	local timeFlag = self.timeLimitLabel:getChildByName("timerLabelbg")
	if cdInSec < showLabelTime24  then
		cIdx = 101
		self.timelabel:setColor(ccc3(255,255,0))
	else
		cIdx = 100
		self.timelabel:setColor(ccc3(255,255,255))
	end
	if timeFlag then
		timeFlag:adjustColor  ( _G.LvlFlagColor[cIdx][1] ,_G.LvlFlagColor[cIdx][2] ,_G.LvlFlagColor[cIdx][3] ,_G.LvlFlagColor[cIdx][4] )
		timeFlag:applyAdjustColorShader()
	end


	if cdInSec <= 0 then

		if self.timeLimitLabel then

			local sequence = CCArray:create()
			local animationTime = 0.55
			local normalScale = self.timeLimitLabel:getScaleX()
			sequence:addObject(CCScaleTo:create(animationTime,1.07*normalScale))
			sequence:addObject(CCScaleTo:create(animationTime,normalScale))
			local action = CCRepeatForever:create(CCSequence:create(sequence))
			self.timeLimitLabel:runAction( action ) 
		end
		return
	end
	if self.scheduleScriptFuncID == nil and timeLeft == nil  then
		self.scheduleScriptFuncID = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(function() self:updateTimeLabel() end, 1, false)
	end
end

function PreGameToolItem:updateTimeLimitIcon()
	if self:isFreeItem() and not self.locked and not self:isPrivilegeFree() then
		if self.selected then
			self.timeLimitIcon:setVisible(false)
			self.timeLimitLabel:setVisible(false)
			if self.timeLimitIcon2 then
				self.timeLimitIcon2:setVisible(false)
			end
			self.priceLabel:setVisible(true)
			self._priceBg:setVisible(true)
			self.coinIcon:setVisible(false)
			self:setHappyCoinAssociatedViewVisible(false)
		else
			if self.timeLeft ~= nil then
				self.timeLimitIcon:setVisible(false)
				

				if self.timeLeft < showLabelTime48 then
					self.timeLimitLabel:setVisible(true)
					if self.timeLimitIcon2 then
						self.timeLimitIcon2:setVisible(false)
					end
				else
					self.timeLimitLabel:setVisible(false)
					if self.timeLimitIcon2 then
						self.timeLimitIcon2:setVisible(true)
					end
				end

			else
				self.timeLimitIcon:setVisible(true)
				self.timeLimitLabel:setVisible(false)
				if self.timeLimitIcon2 then
					self.timeLimitIcon2:setVisible(false)
				end
			end

			self.priceLabel:setVisible(false)
			self._priceBg:setVisible(false)
		end
	else
		self.timeLimitIcon:setVisible(false)
		self.timeLimitLabel:setVisible(false)
		if self.timeLimitIcon2 then
			self.timeLimitIcon2:setVisible(false)
		end
		if self.locked  then
			self._priceBg:setVisible(true)
		end
	end
end

function PreGameToolItem:isTimeFreeItem()
	return self._isFreeItem and self.timeLeft ~= nil
end

local PreItemPriority = {
	[ItemType.PRE_RANDOM_BIRD] = 1, 
	[ItemType.PRE_FIRECRACKER] = 5, 
	[ItemType.INITIAL_2_SPECIAL_EFFECT] = 10, 
	[ItemType.ADD_THREE_STEP] = 15, 
}

function PreGameToolItem:getFreeItemAniPriority()
	local realItemId = ItemType:getRealIdByTimePropId(self.itemId)
	return PreItemPriority[realItemId] or 100
end

function PreGameToolItem:isFreeItemAniEffective()
	return not self:isLocked() and not self:isPrivilegeFree() and not self.isVideoAdOpenV2
end

----------------------------- Discount Goods Activity -----------------------------------
function PreGameToolItem:setDiscountStatus(discountActivityGoodsID)
	self.discountActivityGoodsID = discountActivityGoodsID -- 活动中的GoodsID，替代默认GoodsID

	self:refreshGoodsData()
	self:refreshDiscountViews()
	self:setHappyCoinAssociatedViewVisible(true)
end

function PreGameToolItem:refreshDiscountViews()
	if self.oldPriceTxt and not self.oldPriceTxt.isDisposed 
		and self.oldPriceBlocker and not self.oldPriceBlocker.isDisposed 
		and self.discountTag and not self.discountTag.isDisposed 
		and self.priceLabel and not self.priceLabel.isDisposed 
		then
		if self.origPrice and self.origPrice > 0 and self.itemNumber <= 0 then
			self.showDiscountContent = true

			self.oldPriceTxt:setVisible(true)
			self.oldPriceBlocker:setVisible(true)
			self.discountTag:setVisible(true)

			self.oldPriceTxt:setString(self.origPrice)
			self.priceLabel:setRectPositionX(self.oldPriceTxt:getPositionX() + 45)	--设置位置后，需要setString才会根据位置刷新显示
			self.priceLabelRelocatedByDiscountView = true
			self.priceLabel:setString(self.price) --为了刷新位置显示

			if self.discountPercentTxt and not self.discountPercentTxt.isDisposed then
				local discountPercent = BuyLogic:getDiscountPercentageForDisplay(self.origPrice, self.price)
				self.discountPercentTxt:setString(tostring(discountPercent))
			end
		else
			self.showDiscountContent = false

			self.oldPriceTxt:setVisible(false)
			self.oldPriceBlocker:setVisible(false)
			self.discountTag:setVisible(false)

			if self.priceLabelRelocatedByDiscountView then
				self.priceLabelRelocatedByDiscountView = false

				if self.oldPriceTxt then
					self.priceLabel:setRectPositionX(self.oldPriceTxt:getPositionX() + 5)
				end
			end
			self.priceLabel:setString(self.price)
		end
	end
end
