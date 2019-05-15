require "zoo.panel.basePanel.BasePanel"

TwoYearsEnergyPanel = class(BasePanel)

function TwoYearsEnergyPanel:create(energyPanel, posY , onGetRewardTapped , toPos)
	local panel = TwoYearsEnergyPanel.new()
	panel:_init(energyPanel, posY , onGetRewardTapped , toPos)
	return panel
end

function TwoYearsEnergyPanel:_init(energyPanel, posY , onGetRewardTapped , toPos )
	local vSize = Director:sharedDirector():getVisibleSize()
	local vOrigin = Director:sharedDirector():getVisibleOrigin()
	self.energyPanel = energyPanel

	self:loadRequiredResource(PanelConfigFiles.two_years_gift_enegy)

	self.panel = self:buildInterfaceGroup("2years/energypanel")
	self:init(self.panel)
	self.onGetRewardTapped = onGetRewardTapped

	self.toPos = toPos

	local bg = self.panel:getChildByName("bg")
	--[[
	local itemBg = self.panel:getChildByName("itemBg")
	local title = self.panel:getChildByName("title")
	local itemTitle = self.panel:getChildByName("itemTitle")
	local item = self.panel:getChildByName("item")
	local num = self.panel:getChildByName("num")
	local desc = self.panel:getChildByName("desc")
	self.button = self.panel:getChildByName("button")

	local sSize = bg:getGroupBounds().size
	local pSize = energyPanel:getGroupBounds().size
	local pScale = energyPanel:getScaleX()
	self:setPositionX(self:getHCenterInScreenX())
	self:setPositionY(posY + 100 - vSize.height - vOrigin.y)

	local builder = InterfaceBuilder:create("flash/gameguide/guideelem.json")
	local group = builder:buildGroup("guide_info_panelS")
	local newBg = group:getChildByName("_bg")
	local newBg2 = group:getChildByName("_bg2")
	newBg:removeFromParentAndCleanup(false)
	newBg2:removeFromParentAndCleanup(false)
	group:dispose()
	local index = self.panel:getChildIndex(bg)
	local size = bg:getGroupBounds().size
	newBg:setPreferredSize(CCSizeMake(size.width, size.height))
	newBg2:setPreferredSize(CCSizeMake(size.width - 34, size.height - 34))
	self.panel:addChildAt(newBg2, index)
	self.panel:addChildAt(newBg, index)
	bg:removeFromParentAndCleanup(true)
	
	title:setString(Localization:getInstance():getText("energy.panel.remind.asking.title",
		{max = MetaManager:getInstance():getDailyMaxReceiveGiftCount()}))
	itemTitle:setString(Localization:getInstance():getText("energy.panel.remind.asking.itemdesc"))
	desc:setString(Localization:getInstance():getText("energy.panel.remind.asking.desc",
		{friend = FriendManager:getInstance():getFriendCount(), n = '\n'}))
	self.button:getChildByName("text"):setString(Localization:getInstance():getText("energy.panel.remind.asking.button"))

	num:setText('x'..tostring(MetaManager:getInstance():getDailyMaxReceiveGiftCount() -
		UserManager:getInstance():getDailyData():getReceiveGiftCount()))
	local nSize = num:getContentSize()
	num:setPositionX(itemBg:getPositionX() + itemBg:getGroupBounds().size.width - nSize.width - 20)
	builder = InterfaceBuilder:create("flash/common/properties.json")
	local icon = builder:buildGroup("Prop_10012")
	icon:setPositionXY(item:getPositionX(), item:getPositionY())
	index = self.panel:getChildIndex(item)
	self.panel:addChildAt(icon, index)
	item:removeFromParentAndCleanup(true)
	]]

	self:setPositionX(self:getHCenterInScreenX())
	self:setPositionY(posY + 100 - vSize.height - vOrigin.y - 10)

	local function onClick()
		createAddFriendPanel("recommend")
	end
	--self.button:setTouchEnabled(true)
	--self.button:addEventListener(DisplayEvents.kTouchTap, onClick)

	self.anim = CommonSkeletonAnimation:createTutorialMoveIn2()
	self.anim:stop()
	--self:addChild(self.anim)
	self.removeDirection = "remove"
	self:scaleAccordingToResolutionConfig()
	self:setPositionX(self:getHCenterInScreenX())


	local getBtn = self.ui:getChildByName("btn")
	self.getBtn = GroupButtonBase:create(getBtn)
	self.getBtn:setString("领取")

	--getBtn:setTouchEnabled(true,0,true)
	--getBtn:setButtonMode(true)
	self.getBtn:addEventListener(DisplayEvents.kTouchTap, function() self:getBtnClick() end)
	self.isLocked = false
end

function TwoYearsEnergyPanel:getBtnClick()
	if self.isLocked then return end

	if self.onGetRewardTapped then
		self.isLocked = true
		self.onGetRewardTapped(self)
	end
end

function TwoYearsEnergyPanel:flyEnergy()

	local energy = Layer:create()
	local energyRes = Sprite:createWithSpriteFrameName("homeSceneEner_j34i0000")
	local energyText = BitmapText:create( "x10" , getGlobalDynamicFontMap("微软雅黑") , -1, kCCTextAlignmentCenter)
	energyText:setPosition( ccp( 25 , -15) )
	energyText:setScale(0.5)

	local eff = CommonEffect:buildGetPropLightAnimWithoutBg()

	energy:addChild(eff)
	energy:addChild(energyRes)
	energy:addChild(energyText)
	--convertToNodeSpace

	local startPos =self:convertToWorldSpace( ccp( 550 , - 100 ) )
	energy:setPosition(ccp(startPos.x + 0 , startPos.y - 0))
	energy:setScale(0.5)

	local actArr1 = CCArray:create()
	actArr1:addObject( CCDelayTime:create( 1 ) )
	actArr1:addObject( CCEaseSineOut:create( CCScaleTo:create( 0.3 , 2.7 , 2.7  ) ) )
	actArr1:addObject( CCEaseSineOut:create( CCMoveTo:create( 1 , ccp( self.toPos.x , self.toPos.y ) ) ) )
	actArr1:addObject( CCCallFunc:create( function ()  
				
				energy:removeFromParentAndCleanup(true)

			end ) )

	energy:runAction( CCSequence:create(actArr1) )

	local scene = Director:sharedDirector():getRunningScene()
	scene:addChild(energy, SceneLayerShowKey.TOP_LAYER)
end

function TwoYearsEnergyPanel:onRewardSuccess()
	printx( 1 , "   TwoYearsEnergyPanel:onRewardSuccess()  ")
	self.isLocked = true

	self:flyEnergy()

	setTimeOut( function () 
			self:remove()
		end , 1.6)
end

function TwoYearsEnergyPanel:onRewardFail(type)
	printx( 1 , "   TwoYearsEnergyPanel:onRewardFail()  ")
	self.isLocked = false
	if type == 1 then
		CommonTip:showTip(Localization:getInstance():getText("请联网后领取精力"))
	elseif type == 2 then
		CommonTip:showTip(Localization:getInstance():getText("您今日已领取过精力！"))
	end

	--[[
	self:flyEnergy()

	setTimeOut( function () 
			self:remove()
		end , 1.6)
		--]]
end

function TwoYearsEnergyPanel:popout(position)
	PopoutManager:sharedInstance():add(self, false, true)
	--[[
	if position then
		local pos = self.panel:convertToNodeSpace(ccp(position.x, position.y))
		self.anim:setScaleX(-1)
		self.anim:setPositionXY(pos.x - 50, pos.y + 125)
		self.removeDirection = "left"
	else
		local pos1 = self.button:getPosition()
		local size = self.button:getGroupBounds().size
		pos1.x, pos1.y = pos1.x + size.width * 0.8, pos1.y - size.height
		local pos2 = self.panel:convertToWorldSpace(ccp(pos1.x, pos1.y))
		local pos = self:convertToNodeSpace(ccp(pos2.x, pos2.y))
		self.anim:setPositionXY(pos.x + 50, pos.y + 125)
		self.removeDirection = "right"
	end
	]]
	local posX, posY = self.panel:getPositionX(), self.panel:getPositionY()
	self.panel:setPositionX(-1300)

	local arr = CCArray:create()
	arr:addObject(CCDelayTime:create(0.2))
	arr:addObject(CCEaseBackOut:create(CCMoveTo:create(0.3, ccp(posX, posY))))

	local function enableClose() self.allowBackKeyTap = true end

	arr:addObject(CCCallFunc:create(enableClose))

	self.panel:stopAllActions()
	self.panel:runAction(CCSequence:create(arr))
	self.anim:playByIndex(0)

	local arr2 = CCArray:create()
	arr2:addObject(CCDelayTime:create(2.2))
	local function onStop() self.anim:stop() end
	arr2:addObject(CCCallFunc:create(onStop))
	self.anim:stopAllActions()
	self.anim:runAction(CCSequence:create(arr2))
end

function TwoYearsEnergyPanel:remove()

	if not self:getParent() then return end

	local function onAllOver() PopoutManager:sharedInstance():remove(self) end
	if self.removeDirection == "remove" then
		self.anim:removeFromParentAndCleanup(true)
	elseif self.removeDirection == "left" then
		self.anim:runAction(CCMoveBy:create(0.2, ccp(-1000, 0)))
	elseif self.removeDirection == "right" then
		self.anim:runAction(CCMoveBy:create(0.2, ccp(1000, 0)))
	end
	local arr = CCArray:create()
	arr:addObject(CCEaseBackIn:create(CCMoveBy:create(0.1, ccp(-1000, 0))))
	arr:addObject(CCCallFunc:create(onAllOver))
	self.panel:stopAllActions()
	self.panel:runAction(CCSequence:create(arr))
end

function TwoYearsEnergyPanel:onCloseBtnTapped()
	self.allowBackKeyTap = false
	if self.energyPanel then self.energyPanel:onCloseBtnTapped() end
end