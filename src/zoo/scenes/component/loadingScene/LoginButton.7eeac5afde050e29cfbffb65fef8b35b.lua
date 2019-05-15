LoginButton = class(ButtonIconsetBase)

function LoginButton:create( btnType , label , colorMode )

	if type(btnType) ~= "number" then
		btnType = 1
	end
	local buttonName =  "ui_buttons_new/preloadingscene_button_login_new_".. tostring( btnType ) 
	-- if _G.isLocalDevelopMode  then printx(101 , " LoginButton:create buttonName = " , buttonName ) end
	-- buttonName = "ui_buttons_new/preloadingscene_button_login_new"
	local isIconBase = false
	if btnType == 7 or btnType == 8 then
		--7 和 8这两个用新的
		isIconBase = true
		buttonName = "ui_buttons_new/preloadingscene_button_login_new"
	end
	
	local builder = LayoutBuilder:createWithContentsOfFile("flash/loading.json")
	local button  = LoginButton.new(builder:build( buttonName ) )
	button.builder = builder
	
	button.isNewStyle = true
	if isIconBase then
		button.isNewStyle = true
		button.buttonStyle = ButtonStyleType.TypeBA
	else
		button.buttonStyle = ButtonStyleType.TypeBA
	end
	if colorMode then
		button:setColorMode( colorMode )
	end
	
	button:buildUI(btnType)

	button:setString( label )	
	if button:getIcon() then
		button:getIcon():setVisible( isIconBase )
	end
	if btnType == 7 then
		button:setIconByFrameName("wxjp_package/btn_icon_qq0000")
	elseif btnType == 8 then
		button:setIconByFrameName("wxjp_package/btn_icon_wechat0000")
	else

	end
	return button
end

-- function LoginButton:setScale( sacle )
-- 	 if _G.isLocalDevelopMode  then printx(101 , " LoginButton:create setScale = " , sacle ) end
-- 	 ButtonIconsetBase.setScale(self , sacle)
-- end

-- function LoginButton:setColorMode( colorMode )
-- 	 if _G.isLocalDevelopMode  then printx(101 , " LoginButton:create setScale = " , colorMode ) end
-- 	ButtonIconsetBase.setColorMode(self , colorMode)
-- end



function LoginButton:buildUI( btnType )
	if not self.groupNode then return end
	self.btnType = btnType
	ButtonIconsetBase.buildUI(self)
	self:stopBreathLight()
	if not self.isStaticLabel then
		-- if btnType == 1 then
		-- 	self.label:changeFntFile("fnt/loading_button.fnt")
		-- end
	end

end

function LoginButton:setLightVisible(visible)
	local ui = self.groupNode
	if not ui or ui.isDisposed then return end
	local light = ui:getChildByName("light")
	if light then
		light:stopAllActions()
		light:setOpacity(255)
		light:setScale(1)
		light:setVisible(visible)
	end
end

function LoginButton:playBreathLight()
	local ui = self.groupNode
	if not ui or ui.isDisposed then return end
	local light = ui:getChildByName("light")
	if light then
		light:stopAllActions()
		light:setOpacity(255)
		light:setScale(1)
		light:setVisible(true)
		light:setAnchorPointWhileStayOriginalPosition(ccp(0.5, 0.5))
		local actionArr = CCArray:create()
		actionArr:addObject(CCSequence:createWithTwoActions(CCScaleTo:create(0.8, 0.9), CCScaleTo:create(0.8, 1)))
		actionArr:addObject(CCSequence:createWithTwoActions(CCFadeTo:create(0.8, 255 * 0), CCFadeTo:create(0.8, 255)))
		light:runAction(CCRepeatForever:create(CCSpawn:create(actionArr)))
	end
end

function LoginButton:stopBreathLight()
	local ui = self.groupNode
	if not ui or ui.isDisposed then return end
	local light = ui:getChildByName("light")
	if light then
		light:stopAllActions()
		light:setOpacity(255)
		light:setScale(1)
		light:setVisible(false)
	end
end

function LoginButton:addTipLabel( text )
	if not text then return end
	self:removeTipLabel()

	local btnSize = self:getGroupBounds(self.groupNode).size
	local flagContainer = self.builder:build("preloadingscene_button_flag")
	flagContainer:setPosition(ccp(-btnSize.width / 2 - 1, 9))
	local flagNode = flagContainer:getChildByName("flag")
	flagNode:getChildByName("label"):removeFromParentAndCleanup(true)
	local textLabel = BitmapText:create(tostring(text), "fnt/register2.fnt", -1, kCCTextAlignmentCenter)
	flagNode:addChild(textLabel)
	textLabel:setAnchorPoint(ccp(0.5, 0.5))
	textLabel:ignoreAnchorPointForPosition(false)

	local textHolder = flagNode:getChildByName("size")
	local thGb = textHolder:getGroupBounds(flagNode)
	local labelSize = textLabel:getContentSize()
	local scale = math.min(thGb.size.width / labelSize.width,  thGb.size.height / labelSize.height)
	if scale < 1 then 
		textLabel:setScale(scale)
	end
	textLabel:setPosition(ccp(thGb.origin.x + thGb.size.width/2, thGb.origin.y + thGb.size.height / 2))
	textHolder:removeFromParentAndCleanup(true)
	self.groupNode:addChild(flagContainer)
	self.tipLabel = flagContainer
end

function LoginButton:removeTipLabel()
	if self.tipLabel then
		self.tipLabel:removeFromParentAndCleanup(true)
		self.tipLabel = nil
	end
end

function LoginButton:addRewardTipBubble(rewardId, num)
	if not rewardId then return end

	self:removeRewardTipBubble()

	local tipBubble = self.builder:build("preloadingscene_reward_tip")
	local iconHolder = tipBubble:getChildByName("icon")
	local zOrder = iconHolder:getZOrder()
	local iconSize = iconHolder:getGroupBounds().size
	local iconPos = iconHolder:getPosition()

	local itemIcon = ResourceManager:sharedInstance():buildItemGroup(rewardId)
	local itemHeight = itemIcon:getGroupBounds().size.height
	itemIcon:setAnchorPoint(ccp(0.5, 0.5))
	itemIcon:ignoreAnchorPointForPosition(false)
	itemIcon:setScale(iconSize.height / itemHeight)
	itemIcon:setPosition(ccp(iconPos.x, iconPos.y))

	local fntFile = "fnt/target_amount.fnt"
    local numTf = BitmapText:create('', fntFile)
    numTf:setAnchorPoint(ccp(0.5, 0.5))
    numTf:setPreferredSize(90, 28)
    numTf:setPositionXY(76, 15)
    numTf:setText('x' .. num)

	tipBubble:addChildAt(itemIcon, zOrder)
	tipBubble:addChildAt(numTf, zOrder)
	tipBubble.name = "icon"
	iconHolder:removeFromParentAndCleanup(true)

	local btnSize = self:getGroupBounds(self.groupNode).size
	tipBubble:setPosition(ccp(btnSize.width * 0.4, - btnSize.height * 0.1))
	self.tipBubble = tipBubble
	self.groupNode:addChild(tipBubble)
end

function LoginButton:removeRewardTipBubble()
	if self.tipBubble then
		self.tipBubble:removeFromParentAndCleanup(true)
		self.tipBubble = nil
	end
end

function LoginButton:setColorMode( colorMode, force, enable)
	-- if enable then 
	-- 	ButtonIconsetBase.setColorMode(self, colorMode, force)
	-- else
	-- 	return
	-- end
	ButtonIconsetBase.setColorMode(self, colorMode, force)
end

function LoginButton:setEnabled( isEnabled )
	if self.isEnabled ~= isEnabled then
		self.isEnabled = isEnabled

		if self.groupNode and self.groupNode.refCocosObj then
			self.groupNode:setTouchEnabled(isEnabled, 0, true)
		end		
	end
end

-- function LoginButton:create(btnType, label)
-- 	if type(btnType) ~= "number" then
-- 		btnType = 1
-- 	end
-- 	local button = LoginButton:create(btnType)
-- 	button:setString(label)
-- 	return button
-- end