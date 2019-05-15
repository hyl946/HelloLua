require "zoo.panelBusLogic.BuyLogic"
-- require "zoo.payment.ThirdPayDiscountLabel"
require 'zoo.panel.ChoosePaymentPanel'
require "zoo.payment.GoldlNotEnoughPanel"
require "zoo.payment.PayPanelDiscountUI"

PayPanelConfirmBase_VerB = class(BasePanel)


function PayPanelConfirmBase_VerB:ctor()
	self.moveHeight = 100

	local skinMode , showLeftGold = self:checkTestGroup()
	self.skinMode = skinMode
	self.showLeftGold = showLeftGold
end

function PayPanelConfirmBase_VerB:checkTestGroup()
	return "light" , false
end

function PayPanelConfirmBase_VerB:changeSkinModeToDark(isDark)
	if isDark then
		self.skinMode = "drak"
	else
		self.skinMode = "light"
	end
end

function PayPanelConfirmBase_VerB:getExtendedHeight()
	return 720
end

function PayPanelConfirmBase_VerB:getFoldedHeight()
	return 446
end

function PayPanelConfirmBase_VerB:init()
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

function PayPanelConfirmBase_VerB:initTitlePart()
	self.panelTitle = self.ui:getChildByName("panelTitle")
	self.panelTitle:setString("购买 "..self.goodsName)

	self.propDescLabel = self.ui:getChildByName("propDescLabel")

	local closeBtn = self.ui:getChildByName("closeBtn")
	closeBtn:setTouchEnabled(true)
	closeBtn:setButtonMode(true)
	closeBtn:addEventListener(DisplayEvents.kTouchTap,  function ()
		self:onCloseBtnTap()
	end)
end

function PayPanelConfirmBase_VerB:showButtonLoopAnimation(btn)

	local btnPos = ccp( btn:getPositionX() , btn:getPositionY() )
	local btnSize = btn:getGroupBounds().size
	local originScaleX = btn:getScaleX()
	local originScaleY = btn:getScaleY()

	printx( 1 , "  WTFFFFFFFFFFFFFFFFFFFFFFFFFFFF    originScaleX " , originScaleX , "  originScaleY " , originScaleY)

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


	--[[
	arr:addObject(CCSpawn:createWithTwoActions(
		CCEaseSineOut:create( CCMoveTo:create( baseTime , ccp(btnPos.x + btnSize.width*(1-baseScale)*0.5 , btnPos.y ) ) ), 
		CCEaseSineOut:create( CCScaleTo:create(baseTime, baseScale, 1))) )
	arr:addObject(CCSpawn:createWithTwoActions(
		CCEaseSineIn:create( CCMoveTo:create(baseTime, ccp(btnPos.x , btnPos.y)) ), 
		CCEaseSineIn:create( CCScaleTo:create(baseTime, 1, 1))) )
	arr:addObject(CCSpawn:createWithTwoActions(
		CCEaseSineOut:create( CCMoveTo:create( baseTime , ccp( btnPos.x , btnPos.y - btnSize.height*(1-baseScale)*0.5 ) ) ), 
		CCEaseSineOut:create( CCScaleTo:create(baseTime, 1, baseScale))) )
	arr:addObject(CCSpawn:createWithTwoActions(
		CCEaseSineIn:create( CCMoveTo:create(baseTime, ccp(btnPos.x , btnPos.y)) ), 
		CCEaseSineIn:create( CCScaleTo:create(baseTime, 1, 1))) )

		]]

	printx( 1 , "   "  ,btnPos.x , btnPos.y , btnSize.width , btnSize.height  )
	btn:runAction(CCRepeatForever:create(CCSequence:create(arr)))
end

function PayPanelConfirmBase_VerB:onCloseBtnTap()
	self:removePopout()
end

function PayPanelConfirmBase_VerB:initExtendPanel()
	self.bg = self.ui:getChildByName("bg")
	self.bottom = self.ui:getChildByName("bottom")
	self.extended = false
	self.animComplete = true
	self.extendedPanel = self.ui:getChildByName('extendedPanel')
	self.extendedPanel:setVisible(false)

	self.curtain = self.extendedPanel:getChildByName("curtain")
	self.btnPlay = self.extendedPanel:getChildByName("btnPlay")
	self.btnPlay:getChildByName('text'):setString(Localization:getInstance():getText("prop.info.panel.anim.play"))
end

function PayPanelConfirmBase_VerB:initExtraTip()
	self.extraTip = self.ui:getChildByName("extraTip")
	--[[local oriGoodsId = self.goodsIdInfo:getOriginalGoodsId()
	if oriGoodsId == 18 then 
		self.extraTip:setString(localize("level.prop.tip.10014.1")..localize("level.prop.tip.10014.2"))
	else]]
		self.extraTip:setVisible(false)
	--end
end

function PayPanelConfirmBase_VerB:updatePropDesc(items, goodsType)
	if not items or goodsType ~= 1 then return end

	local itemId = items[1].itemId
	if #items == 1 or itemId == 50027 then
		self.propDescLabel:setString(Localization:getInstance():getText("level.prop.tip."..itemId))
	end
end

function PayPanelConfirmBase_VerB:initItemBubble()
	self.itemBubbleRes = self.ui:getChildByName("itemBubble")

	self.helpButton = self.itemBubbleRes:getChildByName("questionMark")
	self.helpButton_light = self.helpButton:getChildByName("light")
	self.helpButton_dark = self.helpButton:getChildByName("dark")
	self.helpButton:setVisible(false)
	local goodsId = self.goodsIdInfo:getGoodsId()
	local goodsData = MetaManager:getInstance():getGoodMeta(goodsId)
	local items = goodsData.items
	local goodsType = self.goodsIdInfo:getGoodsType()

	self:updatePropDesc(items, goodsType)

	if items and #items == 1 and goodsType == 1 then
		local itemId = items[1].itemId
		local tutorialAnimation = CommonSkeletonAnimation:creatTutorialAnimation(itemId)
		
		if tutorialAnimation then 
			self.helpButton_light:setVisible(false)
			self.helpButton:setVisible(true)
			self.helpButton:setTouchEnabled(true)
			self.helpButton:addEventListener(DisplayEvents.kTouchTap, function ()
				self:onHelpButtonClick()
			end)
			self.tutorial = tutorialAnimation
			tutorialAnimation:setAnchorPoint(ccp(0, 1))
			--local animePlaceHolder = self.extendedPanel:getChildByName('animePlaceHolder')
			local animePlaceHolder = self.curtain

			local pos = animePlaceHolder:getPosition()
			tutorialAnimation:setPosition(ccp(pos.x, pos.y))
			local zOrder = animePlaceHolder:getZOrder()
			animePlaceHolder:getParent():addChildAt(tutorialAnimation, zOrder)
			--animePlaceHolder:removeFromParentAndCleanup(true)
			self.extendedPanel:getChildByName('animePlaceHolder'):removeFromParentAndCleanup(true)

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
			itemIcon = iconBuilder:buildGroup('Goods_'..gid)
		end
	end

	self:setItemBubbleIcon(itemIcon)
end

function PayPanelConfirmBase_VerB:setItemBubbleIcon(itemIcon)
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

function PayPanelConfirmBase_VerB:showBubbleLoopAnimation( tarRes )
	local secondPerFrame	= 1 / 24

	-- Init Action
	local function initActionFunc()
		tarRes:setScale(1)
	end
	local initAction = CCCallFunc:create(initActionFunc)
	local a1 = CCSpawn:createWithTwoActions(CCMoveBy:create(secondPerFrame * 3, ccp(0, -8)), CCScaleTo:create(secondPerFrame * 3, 1.05, 0.92))
	local a2 = CCSpawn:createWithTwoActions(CCMoveBy:create(secondPerFrame * 3, ccp(0, 10)), CCScaleTo:create(secondPerFrame * 3, 1, 1))
	local scale1	= CCRotateTo:create(secondPerFrame * 3, -8)
	local scale2	= CCRotateTo:create(secondPerFrame * 3, 8)
	local scale3	= CCRotateTo:create(secondPerFrame * 3, -7)
	local scale4	= CCRotateTo:create(secondPerFrame * 3, 6.8)
	local scale5	= CCRotateTo:create(secondPerFrame * 3, -6)
	local scale6	= CCRotateTo:create(secondPerFrame * 3, 5)
	local scale7	= CCRotateTo:create(secondPerFrame * 3, -3.8)
	local scale8	= CCRotateTo:create(secondPerFrame * 3, 3)
	local scale9	= CCRotateTo:create(secondPerFrame * 3, -2)
	local scale10	= CCRotateTo:create(secondPerFrame * 3, 1.3)
	local scale11	= CCRotateTo:create(secondPerFrame * 3, 0)
	local a3 = CCSpawn:createWithTwoActions(CCMoveBy:create(secondPerFrame * 3, ccp(0, -10)), CCScaleTo:create(secondPerFrame * 3, 1.05, 0.92))
	local a4 = CCSpawn:createWithTwoActions(CCMoveBy:create(secondPerFrame * 3, ccp(0, 8)), CCScaleTo:create(secondPerFrame * 3, 1, 1))
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
	actionArray:addObject(scale10)
	actionArray:addObject(scale11)
	actionArray:addObject(a3)
	actionArray:addObject(a4)
	actionArray:addObject(delay)

	local seq 	= CCSequence:create(actionArray)
	local targetSeq	= CCTargetedAction:create(tarRes.refCocosObj, seq)

	local action = CCRepeatForever:create(targetSeq)
	action:setTag(100)
	tarRes:runAction(action)
	--return targetSeq
end


function PayPanelConfirmBase_VerB:onHelpButtonClick()
	if not self.animComplete then return end
	self.animComplete = false
	if self.extended then 
		self.helpButton_light:setVisible(false)
		self.helpButton_dark:setVisible(true)
		self.extendedPanel:setVisible(false)
		self.extended = false
		self:stopTutorial()
		local size = self.bg:getGroupBounds().size
		--self.bg:setPreferredSize(CCSizeMake(size.width, self:getFoldedHeight()))
		self.bg:runAction( CCScaleTo:create(0.2 , 1 ,  1 ) )
		if self.bottom then
			self.bottom:runAction(CCMoveTo:create(0.2, ccp(self.bottom:getPositionX(), -(self:getFoldedHeight() + 24))))
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

		self.bg:runAction( CCScaleTo:create(0.2 , 1 , self:getExtendedHeight() / self:getFoldedHeight() ) )
		if self.bottom then
			self.bottom:runAction(CCMoveTo:create(0.2, ccp(self.bottom:getPositionX(), -(self:getExtendedHeight() + 24))))
		end
		self:runAction(CCSequence:createWithTwoActions(
		               CCEaseSineOut:create(CCMoveBy:create(0.2, ccp(0, self.moveHeight))),
		               CCCallFunc:create(function()
	                     	self.extendedPanel:setVisible(true)
							self.extended = true
							self.animComplete = true
							if self.bg and not self.bg.isDisposed then
			                	--self.bg:setPreferredSize(CCSizeMake(size.width, self:getExtendedHeight()))
			                end

			                self:playTutorial()
		                end)
		               ))
	end
end

function PayPanelConfirmBase_VerB:playTutorial()
	if self.tutorial then
		self.curtain:setVisible(false)
		self.btnPlay:setVisible(false)
		self.tutorial:playAnimation()
	end
end

function PayPanelConfirmBase_VerB:stopTutorial()
	if self.tutorial then
		self.tutorial:stopAnimation()
		self.curtain:setVisible(true)
		self.btnPlay:setVisible(true)
	end
end

function PayPanelConfirmBase_VerB:getNeedDarkBgGoods()
	--[[
	local darkBgGoodsIds = {18, 29}
	local oriGoodsId = self.goodsIdInfo:getOriginalGoodsId() 
	if table.includes(darkBgGoodsIds, oriGoodsId) then 
		return true
	end
	return false	
	]]
end

function PayPanelConfirmBase_VerB:getNeedDarkBgGroup()

end

function PayPanelConfirmBase_VerB:popout()

	local needDarkBg = false
	if self.skinMode == "light" then
		needDarkBg = true
	end
	--local needDarkBg = self:getNeedDarkBgGoods()
	PopoutManager:sharedInstance():add(self, needDarkBg, false)
	local parent = self:getParent()
	if parent then
		self:setToScreenCenterHorizontal()
		self:setToScreenCenterVertical()		
	end
	--self:setPositionY(self:getPositionY() + 130)
	local panelPos = ccp( self:getPosition().x , self:getPosition().y )
	local panelSize = self:getGroupBounds().size
	local animScale = 0.1
	self:setScale(animScale)
	self:setPositionXY( panelPos.x + (panelSize.width*(1-animScale)/2) , panelPos.y - (panelSize.height*(1-animScale)/2) )

	local scale1 = 1.05
	local scale2 = 0.975

	local actionArray = CCArray:create()
							--actionArray:addObject( CCDelayTime:create(0.5) )
							actionArray:addObject( CCEaseSineOut:create( CCScaleTo:create(0.2 , scale1 ,  scale1) ) )
							--actionArray:addObject( CCEaseSineOut:create( CCScaleTo:create(0.05 , scale2 ,  scale2 ) ) )
							actionArray:addObject( CCEaseSineOut:create( CCScaleTo:create(0.05 , 1 ,  1 ) ) )

	local seq 	= CCSequence:create(actionArray)
	self:runAction(seq)

	local actionArray2 = CCArray:create()
							actionArray2:addObject( CCEaseSineOut:create( CCMoveTo:create(0.2, ccp(panelPos.x + (panelSize.width*(1-scale1)/2) , panelPos.y - (panelSize.height*(1-scale1)/2)) ) ) )
							--actionArray2:addObject( CCEaseSineOut:create( CCMoveTo:create(0.05, ccp(panelPos.x + (panelSize.width*(1-scale2)/2) , panelPos.y - (panelSize.height*(1-scale2)/2)) ) ) )
							actionArray2:addObject( CCEaseSineOut:create( CCMoveTo:create(0.05, ccp(panelPos.x , panelPos.y) ) ) )
							actionArray2:addObject( CCCallFunc:create(function()
														RealNameManager:addConsumptionLabelToPanel(self, needDarkBg , nil , true )
							                    	end ) )

	local seq2 	= CCSequence:create(actionArray2)
	self:runAction(seq2)


	--self:runAction(CCEaseSineOut:create(CCMoveTo:create(0.3, ccp(panelPos.x , panelPos.y) )))
	--self:runAction(CCEaseElasticOut:create(CCMoveBy:create(0.8, ccp(0, -130))))
	--self:runAction(CCEaseElasticOut:create(CCMoveBy:create(0.8, ccp(0, -130))))

	self.allowBackKeyTap = true
end

function PayPanelConfirmBase_VerB:removePopout()
	CCTextureCache:sharedTextureCache():removeTextureForKey(CCFileUtils:sharedFileUtils():fullPathForFilename("skeleton/tutorial_animation/texture.png"))
	PopoutManager:sharedInstance():remove(self, true)
	self.allowBackKeyTap = false
end

function PayPanelConfirmBase_VerB:onKeyBackClicked()
	self:onCloseBtnTap()
end

function PayPanelConfirmBase_VerB:getIconPos()
	if not self.isDisposed and self.itemIcon then 
		return self.itemIcon:convertToWorldSpace(ccp(0,0))
	end
end

----------- video ad

function PayPanelConfirmBase_VerB:showAD()
	PayPanelConfirmBase.showAD(self)
end
function PayPanelConfirmBase_VerB:initBtnVideoAD()
	PayPanelConfirmBase.initBtnVideoAD(self)
end

----------- video ad END
