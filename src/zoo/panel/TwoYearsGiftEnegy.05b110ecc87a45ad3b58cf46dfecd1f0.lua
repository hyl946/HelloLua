TwoYearsGiftEnegy = class(BasePanel)

function TwoYearsGiftEnegy:create(closeCallback , rewardCallback , toPos)

	local panel = TwoYearsGiftEnegy.new()
	panel:loadRequiredResource(PanelConfigFiles.two_years_gift_enegy)
	panel:init(closeCallback , rewardCallback , toPos)
	return panel
end

function TwoYearsGiftEnegy:init(closeCallback , rewardCallback , toPos)

	self.closeCallback = closeCallback
	self.rewardCallback = rewardCallback
	self.ui = self:buildInterfaceGroup("2years/2yearsGiftPanel")
	BasePanel.init(self, self.ui)

	self.isLocked = false
	self.toPos = toPos
	
	
	--local anime_in = ArmatureNode:create("TwoYearsCelebrationAnimation_in" )
	
	local getBtn = self.ui:getChildByName("getBtn")
	self.getBtn = GroupButtonBase:create(getBtn)
	self.getBtn:setString("领取奖励")

	--getBtn:setTouchEnabled(true,0,true)
	--getBtn:setButtonMode(true)
	self.getBtn:addEventListener(DisplayEvents.kTouchTap, function() self:getBtnClick() end)

	local closeBtn = self.ui:getChildByName("closeBtn")
	closeBtn:setTouchEnabled(true,0,true)
	closeBtn:setButtonMode(true)
	closeBtn:addEventListener(DisplayEvents.kTouchTap, function() self:onKeyBackClicked() end)

	local visibleSize = CCDirector:sharedDirector():getVisibleSize()
    local origin = CCDirector:sharedDirector():getVisibleOrigin()
    local uiWidth = self.ui:getGroupBounds().size.width
    local uiHeight = self.ui:getGroupBounds().size.height
    local fixScale = visibleSize.height / uiHeight
    self.fixScale = fixScale


    FrameLoader:loadArmature("skeleton/TwoYearsCelebrationAnimation")
	
	local anime_in = ArmatureNode:create("TwoYearsCelebrationAnimation_in" )
	--local animePos = ccp(  (uiWidth * fixScale * 0.7) / 2 , (uiHeight * fixScale * 0.9) / -2  )
	local animePos = ccp(  (uiWidth * 1 * 0.6) / 2 , (uiHeight * 1 * 0.9) / -2  )

	anime_in:playByIndex(0)
	anime_in:update(0.001) --此处的参数含义为时间
	anime_in:stop()
	anime_in:setPosition( animePos )
	anime_in:setScale(0.7)

	self:addChild(anime_in)
	anime_in:playByIndex(0)


	local anime_wait = ArmatureNode:create("TwoYearsCelebrationAnimation_wait" )

	anime_wait:playByIndex(0)
	anime_wait:update(0.001) --此处的参数含义为时间
	anime_wait:stop()
	anime_wait:setPosition( animePos )
	anime_wait:setScale(0.7)



	setTimeOut( function () 
			if self:getParent() then
				self:addChild(anime_wait)
				anime_wait:playByIndex(0)

				anime_in:stop()
				anime_in:removeFromParentAndCleanup(true)
			end
			
		end , 2 )


	
	self:setScale(  fixScale  )
	local fixX = (visibleSize.width - (uiWidth * fixScale)) / 2
	self:setPositionX(fixX)
	
	self.boxPos = anime_in:convertToWorldSpace( ccp(50 , 20) )
end

function TwoYearsGiftEnegy:popout()
	PopoutManager:sharedInstance():add(self, true, false)

	DcUtil:timeMachineShowEnergy()
end

function TwoYearsGiftEnegy:getBtnClick()
	if self.isLocked then return end
	--if _G.isLocalDevelopMode then printx(0, "todo") end
	--[[
	RequireNetworkAlert:callFuncWithLogged(
		function ()
			if self.rewardCallback then
				self.rewardCallback()
			end
		end, 
		function () end, 
		kRequireNetworkAlertAnimation.kDefault,
		kRequireNetworkAlertTipType.kDefault
	)
	]]

	if self.rewardCallback then
		self.isLocked = true
		self.rewardCallback(self)
	end
end

function TwoYearsGiftEnegy:onKeyBackClicked()
	printx( 1 , "   TwoYearsGiftEnegy:onKeyBackClicked()  ")
	if self.isLocked then return end
	self.isLocked = true

	if self.closeCallback  then self.closeCallback() end
	PopoutManager:sharedInstance():remove(self)
end

function TwoYearsGiftEnegy:flyEnergy()
	local energy = Layer:create()
	local energyRes = Sprite:createWithSpriteFrameName("homeSceneEner_j34i0000")
	local energyText = BitmapText:create( "x10" , getGlobalDynamicFontMap("微软雅黑") , -1, kCCTextAlignmentCenter)
	energyText:setPosition( ccp( 25 , -15) )
	energyText:setScale(0.5)

	--local eff = CommonEffect:buildGetPropLightAnim()
	local eff = CommonEffect:buildGetPropLightAnimWithoutBg()


	energy:addChild(eff)
	energy:addChild(energyRes)
	energy:addChild(energyText)

	--convertToNodeSpace

	--local startPos =self:convertToWorldSpace( self.boxPos )
	local startPos = self:convertToWorldSpace( ccp( 340 , -660 ) )
	energy:setPosition(ccp(startPos.x , startPos.y))
	energy:setScale(0.5)

	local actArr1 = CCArray:create()
	--actArr1:addObject( CCDelayTime:create( 0.2 * (#textContainer.partList - i) ) )
	actArr1:addObject( CCEaseSineOut:create( CCScaleTo:create( 0.3 , 2.7 , 2.7  ) ) )
	actArr1:addObject( CCEaseSineOut:create( CCMoveTo:create( 1 , ccp( self.toPos.x , self.toPos.y ) ) ) )
	actArr1:addObject( CCCallFunc:create( function ()  
				
				energy:removeFromParentAndCleanup(true)

			end ) )

	energy:runAction( CCSequence:create(actArr1) )


	local scene = Director:sharedDirector():getRunningScene()
	scene:addChild(energy,SceneLayerShowKey.TOP_LAYER)
end

function TwoYearsGiftEnegy:onRewardSuccess()
	printx( 1 , "   TwoYearsGiftEnegy:onRewardSuccess()  ")
	self.isLocked = true

	self:flyEnergy()

	setTimeOut( function () 
			PopoutManager:sharedInstance():remove(self)
		end , 0.6)
end

function TwoYearsGiftEnegy:onRewardFail(type)
	printx( 1 , "   TwoYearsGiftEnegy:onRewardFail()  ")
	self.isLocked = false
	if type == 1 then
		CommonTip:showTip(Localization:getInstance():getText("请联网后领取精力"))
	elseif type == 2 then
		CommonTip:showTip(Localization:getInstance():getText("您今日已领取过精力！"))
	end
end