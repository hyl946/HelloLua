require "zoo.panelBusLogic.BuyLogic"
-- require "zoo.payment.ThirdPayDiscountLabel"
require 'zoo.panel.ChoosePaymentPanel'
require "zoo.payment.GoldlNotEnoughPanel"
require "zoo.payment.PayPanelDiscountUI"

PayPanelConfirmBase = class(BasePanel)

function PayPanelConfirmBase:ctor()
	self.moveHeight = 100
end

function PayPanelConfirmBase:getExtendedHeight()
	return 710
end

function PayPanelConfirmBase:getFoldedHeight()
	return 446
end

function PayPanelConfirmBase:init()
	BasePanel.init(self, self.ui)

	FrameLoader:loadArmature( "skeleton/tutorial_animation" )

	self.goodsName = Localization:getInstance():getText("goods.name.text"..tostring(self.goodsIdInfo:getGoodsNameId()))
	self:initTitlePart()
	self:initExtraTip()
	self:initExtendPanel()
	self:initItemBubble()

	local size = self.bg:getGroupBounds().size
	self.bg:setPreferredSize(CCSizeMake(size.width, self:getFoldedHeight()))
	if self.bottom then
		self.bottom:setPositionY(-(self:getFoldedHeight() + 24))
	end
end

function PayPanelConfirmBase:initTitlePart()
	self.panelTitle = self.ui:getChildByName("panelTitle")
	self.panelTitle:setString("购买 "..self.goodsName)

	local closeBtn = self.ui:getChildByName("closeBtn")
	closeBtn:setTouchEnabled(true)
	closeBtn:setButtonMode(true)
	closeBtn:addEventListener(DisplayEvents.kTouchTap,  function ()
		self:onCloseBtnTap()
	end)
end

function PayPanelConfirmBase:onCloseBtnTap()
	self:removePopout()
end

function PayPanelConfirmBase:initExtendPanel()
	self.bg = self.ui:getChildByName("bg")
	self.bottom = self.ui:getChildByName("bottom")
	self.extended = false
	self.animComplete = true
	self.extendedPanel = self.ui:getChildByName('extendedPanel')
	self.extendedPanel:setVisible(false)

	self.curtain = self.extendedPanel:getChildByName("curtain")
	self.itemDesc = self.extendedPanel:getChildByName("desc")
	self.btnPlay = self.extendedPanel:getChildByName("btnPlay")
	self.btnPlay:getChildByName('text'):setString(Localization:getInstance():getText("prop.info.panel.anim.play"))
end

function PayPanelConfirmBase:initExtraTip()
	self.extraTip = self.ui:getChildByName("extraTip")
	local oriGoodsId = self.goodsIdInfo:getOriginalGoodsId()
	if oriGoodsId == 18 then 
		self.extraTip:setString(localize("level.prop.tip.10014.1")..localize("level.prop.tip.10014.2"))
	else
		self.extraTip:setVisible(false)
	end
end

function PayPanelConfirmBase:initItemBubble()
	self.itemBubbleRes = self.ui:getChildByName("itemBubble")

	self.helpButton = self.itemBubbleRes:getChildByName("questionMark")
	self.helpButton_light = self.helpButton:getChildByName("light")
	self.helpButton_dark = self.helpButton:getChildByName("dark")
	self.helpButton:setVisible(false)
	local goodsId = self.goodsIdInfo:getGoodsId()
	local goodsData = MetaManager:getInstance():getGoodMeta(goodsId)
	local items = goodsData.items
	local goodsType = self.goodsIdInfo:getGoodsType()
	if items and #items == 1 and goodsType == 1 then
		local itemId = items[1].itemId
		local tutorialAnimation = CommonSkeletonAnimation:creatTutorialAnimation(itemId)
		if tutorialAnimation then 
			self.itemDesc:setString(Localization:getInstance():getText("level.prop.tip."..itemId))
			self.helpButton_light:setVisible(false)
			self.helpButton:setVisible(true)
			self.helpButton:setTouchEnabled(true)
			self.helpButton:addEventListener(DisplayEvents.kTouchTap, function ()
				self:onHelpButtonClick()
			end)
			self.tutorial = tutorialAnimation
			tutorialAnimation:setAnchorPoint(ccp(0, 1))
			local animePlaceHolder = self.extendedPanel:getChildByName('animePlaceHolder')
			local pos = animePlaceHolder:getPosition()
			tutorialAnimation:setPosition(ccp(pos.x, pos.y))
			local zOrder = animePlaceHolder:getZOrder()
			animePlaceHolder:getParent():addChildAt(tutorialAnimation, zOrder)
			animePlaceHolder:removeFromParentAndCleanup(true)

			self.btnPlay:setTouchEnabled(true)
			self.btnPlay:setButtonMode(true)
			self.btnPlay:addEventListener(DisplayEvents.kTouchTap, function ()
				self:playTutorial()
			end)		
		end	
	end

	local iconBuilder = InterfaceBuilder:create(PanelConfigFiles.properties)
	local itemIcon = nil
	if goodsType == 2 then -- 购买金币
		itemIcon = iconBuilder:buildGroup("Prop_14")
	elseif goodsType == 1 then
		if string.find(self.goodsName, "新区域解锁") then
			itemIcon = Sprite:createWithSpriteFrameName("buy_confirm_panel/cells/unlockIcon0000")
			itemIcon:setAnchorPoint(ccp(0,1))
		elseif string.find(self.goodsName, "签到礼包") then
			itemIcon = Sprite:createWithSpriteFrameName("buy_confirm_panel/cells/checkinIcon0000")
			itemIcon:setAnchorPoint(ccp(0,1))
		else
			local gid = self.goodsIdInfo:getOriginalGoodsId()
			if string.find(self.goodsName, "加5步") then
				gid = 4
			elseif string.find(self.goodsName, "追踪导弹") then
				gid = 45
			end

			if gid >= 513 and gid <= 536 then
				gid = 362
			end

			if gid >= 559 and gid <= 566 then
				gid = 362
			end

			if gid == 494 or gid == 495 then
				gid = 362
			end

			itemIcon = iconBuilder:buildGroup('Goods_'..gid)
		end
	end

	self:setItemBubbleIcon(itemIcon)
end

function PayPanelConfirmBase:setItemBubbleIcon(itemIcon)
	if not itemIcon then return end
	local itemBubbleRes = self.ui:getChildByName("itemBubble")
	local holder = itemBubbleRes:getChildByName("targetIconPlaceHolder")
	local holderIndex = 0
	if holder then holderIndex = itemBubbleRes:getChildIndex(holder)
	else holder = self.iconHolder end
	local bSize = holder:getGroupBounds().size
	if itemIcon then 
		local iSize = itemIcon:getGroupBounds().size
		itemIcon:setPositionXY(holder:getPositionX() + (bSize.width - iSize.width) / 2, holder:getPositionY() - (bSize.height - iSize.height) / 2)
		itemBubbleRes:addChildAt(itemIcon, holderIndex)
		self.itemIcon = itemIcon
		self.iconHolder = itemIcon
	end
	holder:removeFromParentAndCleanup(true)
end

function PayPanelConfirmBase:onHelpButtonClick()
	if not self.animComplete then return end
	self.animComplete = false
	if self.extended then 
		self.helpButton_light:setVisible(false)
		self.helpButton_dark:setVisible(true)
		self.extendedPanel:setVisible(false)
		self.extended = false
		self:stopTutorial()
		local size = self.bg:getGroupBounds().size
		self.bg:setPreferredSize(CCSizeMake(size.width, self:getFoldedHeight()))
		if self.bottom then
			self.bottom:setPositionY(-(self:getFoldedHeight() + 24))
		end
		self:runAction(CCSequence:createWithTwoActions(
		               CCEaseSineOut:create(CCMoveBy:create(0.2, ccp(0, -self.moveHeight))),
		               CCCallFunc:create(function()
		               		self.animComplete = true
                    	end )
		               ))
	else 
		self.helpButton_light:setVisible(true)
		self.helpButton_dark:setVisible(false)
		local size = self.bg:getGroupBounds().size
		size = {width = size.width, height = size.height}
		self:runAction(CCSequence:createWithTwoActions(
		               CCEaseSineOut:create(CCMoveBy:create(0.2, ccp(0, self.moveHeight))),
		               CCCallFunc:create(function()
	                     	self.extendedPanel:setVisible(true)
							self.extended = true
							self.animComplete = true
							if self.bg and not self.bg.isDisposed then
			                	self.bg:setPreferredSize(CCSizeMake(size.width, self:getExtendedHeight()))
			                end
			                if self.bottom then
				                self.bottom:setPositionY(-(self:getExtendedHeight() + 24))
				            end
		                end)
		               ))
	end
end

function PayPanelConfirmBase:playTutorial()
	if self.tutorial then
		self.curtain:setVisible(false)
		self.btnPlay:setVisible(false)
		self.tutorial:playAnimation()
	end
end

function PayPanelConfirmBase:stopTutorial()
	if self.tutorial then
		self.tutorial:stopAnimation()
		self.curtain:setVisible(true)
		self.btnPlay:setVisible(true)
	end
end

function PayPanelConfirmBase:getNeedDarkBgGoods()
	local darkBgGoodsIds = {18, 29, 150}
	local oriGoodsId = self.goodsIdInfo:getOriginalGoodsId() 
	if table.includes(darkBgGoodsIds, oriGoodsId) then 
		return true
	end
	return false	
end

function PayPanelConfirmBase:popout()
	local needDarkBg = self:getNeedDarkBgGoods()
	PopoutManager:sharedInstance():add(self, needDarkBg, false)
	local parent = self:getParent()
	if parent then
		self:setToScreenCenterHorizontal()
		self:setToScreenCenterVertical()		
	end
	self:setPositionY(self:getPositionY() + 130)
	self:runAction(CCEaseElasticOut:create(CCMoveBy:create(0.8, ccp(0, -130))))
	self.allowBackKeyTap = true

	RealNameManager:addConsumptionLabelToPanel(self, self:getNeedDarkBgGoods(), ccp(0, 130), true)
end

function PayPanelConfirmBase:removePopout()
	CCTextureCache:sharedTextureCache():removeTextureForKey(CCFileUtils:sharedFileUtils():fullPathForFilename("skeleton/tutorial_animation/texture.png"))
	PopoutManager:sharedInstance():remove(self, true)
	self.allowBackKeyTap = false
end

function PayPanelConfirmBase:onKeyBackClicked()
	self:onCloseBtnTap()
end

function PayPanelConfirmBase:getIconPos()
	if not self.isDisposed and self.itemIcon then 
		return self.itemIcon:convertToWorldSpace(ccp(0,0))
	end
end

function PayPanelConfirmBase:showButtonLoopAnimation(btn)
	local btnPos = ccp( btn:getPositionX() , btn:getPositionY() )
	local btnSize = btn:getGroupBounds().size
	local originScaleX = btn:getScaleX()
	local originScaleY = btn:getScaleY()
	local baseTime = 0.5
	local baseScale = 0.95
	local arr = CCArray:create()

	arr:addObject(CCSpawn:createWithTwoActions(
		CCEaseSineOut:create( CCMoveTo:create( baseTime , ccp(btnPos.x  , btnPos.y ) ) ), 
		CCEaseSineOut:create( CCScaleTo:create(baseTime, baseScale * originScaleX , originScaleY))) )
	arr:addObject(CCSpawn:createWithTwoActions(
		CCEaseSineIn:create( CCMoveTo:create(baseTime, ccp(btnPos.x , btnPos.y) ) ), 
		CCEaseSineIn:create( CCScaleTo:create(baseTime, originScaleX, originScaleY))) )
	arr:addObject(CCSpawn:createWithTwoActions(
		CCEaseSineOut:create( CCMoveTo:create( baseTime , ccp( btnPos.x , btnPos.y)  ) ), 
		CCEaseSineOut:create( CCScaleTo:create(baseTime, originScaleX, baseScale*originScaleY))) )
	arr:addObject(CCSpawn:createWithTwoActions(
		CCEaseSineIn:create( CCMoveTo:create(baseTime, ccp(btnPos.x , btnPos.y)) ), 
		CCEaseSineIn:create( CCScaleTo:create(baseTime, originScaleX, originScaleY))) )

	btn:runAction(CCRepeatForever:create(CCSequence:create(arr)))
end

----------- video ad

function PayPanelConfirmBase:initBtnVideoAD()
	local buyBtnRes = self.windMillPart and self.windMillPart:getChildByName("btnAD") or self.ui:getChildByName("btnAD")
	self.btnVideoAD = ButtonIconsetBase:create(buyBtnRes)
	self:showButtonLoopAnimation(self.btnVideoAD.groupNode)
	self.btnVideoAD:setString("免费获取")
	self.btnVideoAD:setIconByFrameName("res.video/videoIcon0000")
	self.btnVideoAD:addEventListener(DisplayEvents.kTouchTap, function ()
		self:showAD()
	end)

	self.btnVideoAD.txtItemNum = buyBtnRes:getChildByName("txtItemNum")
	self.btnVideoAD.itemNumBg = buyBtnRes:getChildByName("itemNumBg")
	self.btnVideoAD.itemNumBg:setVisible(false)
end

function PayPanelConfirmBase:showAD()
	local function onPlayFinsihed(ads, placementId, state)
		if state == AdsFinishState.kCompleted then
			if self.isDisposed then return end
			local fn = self.callbackSucc or (self.goodsIdInfo and self.goodsIdInfo.videoCallback)
			local _ = fn and fn(-1, self:getIconPos())
			self:onCloseBtnTap()
		end
	end

	local function onPlayError( ads, code, msg )
		
	end

	InciteManager:showAds(EntranceType.kStartLevel, onPlayFinsihed, onPlayError)
end

----------- video ad END

