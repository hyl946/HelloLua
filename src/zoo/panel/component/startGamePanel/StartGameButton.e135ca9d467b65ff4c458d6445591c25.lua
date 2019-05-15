
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年12月11日 21:21:31
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

---------------------------------------------------
-------------- StartGameButton
---------------------------------------------------

assert(not StartGameButton)
StartGameButton = class(ButtonIconNumberBase)

function StartGameButton:create(buttonGroup, isInterfaceBuilder, buttonStyle)
	local button = StartGameButton.new(buttonGroup)
	button.isNewStyle = true
	button.buttonStyle = buttonStyle or ButtonStyleType.TypeBAA
	button:buildUI()
	return button
end

function StartGameButton:getPosOffset()
	if self.costType == StartLevelCostEnergyType.kEnergy then
		return ccp(5,-5)
	elseif self.costType == StartLevelCostEnergyType.kEnergyBottleMiddle then
		return ccp(7,-7)
	elseif self.costType == StartLevelCostEnergyType.kEnergyBottleSmall then
		return ccp(5,-7)
	end
	return ccp(0,0)
end

function StartGameButton:getPositionInScreen()
	local parent = self:getParent()
	assert(parent)

	local selfPos = self:getPosition()
	local posInScreen = parent:convertToWorldSpace(ccp(selfPos.x, selfPos.y))
	return posInScreen
end

function StartGameButton:setEnergyIconVisible(visible)
	local stringKey		= "start.game.panel.start.btn.txt"
	local stringValue	= Localization:getInstance():getText(stringKey, {})
	-- if _G.isLocalDevelopMode then printx(101, "StartGameButton  setEnergyIconVisible:self.costType = " , self.costType , debug.traceback() ) end
	self:setNumber( "-5" )
	if self.costType == StartLevelCostEnergyType.kEnergy then
		--开始 -5
		self.buttonStyle = ButtonStyleType.TypeACA
		self:setIconByFrameName("common_icon/item/icon_energy0000")
		self.numberLabel:setVisible(true)
	elseif self.costType == StartLevelCostEnergyType.kInfiniteEnergy then --无限精力模式
		--infiniteEnergy
		self.buttonStyle = ButtonStyleType.TypeBAA
		self:setIconByFrameName("common_icon/item/icon_infinite_energy0000")
		self.numberLabel:setVisible(false)
	elseif self.costType == StartLevelCostEnergyType.kEnergyBottleSmall then
		self.buttonStyle = ButtonStyleType.TypeACA
		self:setIconByFrameName("common_icon/item/icon_energy_small0000")
		self.numberLabel:setVisible(true)
		self:setNumber( "-5" )
	elseif self.costType == StartLevelCostEnergyType.kEnergyBottleMiddle then
		self.buttonStyle = ButtonStyleType.TypeACA
		self:setIconByFrameName("common_icon/item/icon_energy_mid0000")
		self.numberLabel:setVisible(true)
		self:setNumber( "-1" )
	end
	self:setString( stringValue )
end

function StartGameButton:buildUI()
	ButtonIconNumberBase.buildUI(self)
	self.isHandlingAct = false
	self.BUTTON_ENERGY_STATE_INFINITE 	= 1
	self.BUTTON_ENERGY_STATE_USE_ENERGY	= 2
	if MaintenanceManager:getInstance():isEnabledInGroup( "useEnergyOptimization_new" , "autoUseEnergyToStartLevel2" , UserManager:getInstance().uid) then
		self.costType = NewStartLevelLogic:getStartLevelCostEnergyType()
		if self.costType == StartLevelCostEnergyType.kEnergyBottleSmall then
			DcUtil:showAutoUseEnergyBottle(self.costType)
		elseif self.costType == StartLevelCostEnergyType.kEnergyBottleMiddle then
			DcUtil:showAutoUseEnergyBottle(self.costType)
		else

		end
	else
		self.costType = StartLevelCostEnergyType.kEnergy
	end

	local function callFun( ... )
		self:perFrameCheckEnergyChange()
	end 

	self:perFrameCheckEnergyChange()

	local seq = CCSequence:createWithTwoActions( CCCallFunc:create( callFun ) ,CCDelayTime:create( 1/60 ))
	self.groupNode:runAction( CCRepeatForever:create( seq ) )

	self:useBubbleAnimation()
end

function StartGameButton:perFrameCheckEnergyChange()
	if self.isHandlingAct then return end

	local energyState = UserEnergyRecoverManager:sharedInstance():getEnergyState()

	if energyState == UserEnergyState.INFINITE then
		self:changeToEnergyInfiniteState()
	elseif energyState == UserEnergyState.COUNT_DOWN_TO_RECOVER then
		self:changeToEnergyCountdownState()
	else
		assert(false)
	end
end

function StartGameButton:changeToEnergyInfiniteState()
	if self.buttonEnergyState ~= self.BUTTON_ENERGY_STATE_INFINITE then
		self.buttonEnergyState = self.BUTTON_ENERGY_STATE_INFINITE
		
		self.oldCostType = self.costType
		self.costType = StartLevelCostEnergyType.kInfiniteEnergy
		self:setEnergyIconVisible(true)
	end
end

function StartGameButton:changeToEnergyCountdownState()
	if self.buttonEnergyState ~= self.BUTTON_ENERGY_STATE_USE_ENERGY then
		self.buttonEnergyState = self.BUTTON_ENERGY_STATE_USE_ENERGY	
		if self.oldCostType then
			self.costType = self.oldCostType
		end
		self:setEnergyIconVisible(true)
	end
end

function StartGameButton:showActInfiniteEnergy(shouldShow)
	if shouldShow then
		if not self.isHandlingAct then 
			self.buttonEnergyState = nil
			self.isHandlingAct = true
			local stringKey		= "start.game.panel.start.btn.txt"
			local stringValue	= Localization:getInstance():getText(stringKey, {})
			self.buttonStyle = ButtonStyleType.TypeACA
			self:setIconByFrameName("yellowEnergy/csye_icon0000")
			self.numberLabel:setVisible(true)
			self:setNumber( "-1" )
		end
	else
		if self.isHandlingAct then 
			self.isHandlingAct = false
		end
	end
end

