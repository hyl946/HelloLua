require "zoo.panel.basePanel.BasePanel"

local function createStarAnim(beforeDelay, afterDelay)
	local builder = InterfaceBuilder:create(PanelConfigFiles.panel_push_activity)
	local star = builder:buildGroup("sprite/pushactivitypanel_star_sprite")
	local sprite = star:getChildByName("sprite")
	sprite:setOpacity(0)
	local arr = CCArray:create()
	if beforeDelay then arr:addObject(CCDelayTime:create(beforeDelay)) end
	arr:addObject(CCFadeIn:create(0.3))
	arr:addObject(CCDelayTime:create(0.4))
	arr:addObject(CCFadeOut:create(0.3))
	if afterDelay then arr:addObject(CCDelayTime:create(afterDelay)) end
	sprite:runAction(CCRepeatForever:create(CCSequence:create(arr)))
	star:setScale(math.random() + 0.5)
	local scale = star:getScale()
	star:setScale(scale * 0.7)
	arr = CCArray:create()
	local arr1 = CCArray:create()
	if beforeDelay then arr:addObject(CCDelayTime:create(beforeDelay)) end
	arr1:addObject(CCRotateBy:create(1, 180))
	local arr2 = CCArray:create()
	arr2:addObject(CCScaleTo:create(0.3, scale))
	arr2:addObject(CCDelayTime:create(0.4))
	arr2:addObject(CCScaleTo:create(0.3, scale * 0.7))
	arr1:addObject(CCSequence:create(arr2))
	arr:addObject(CCSpawn:create(arr1))
	if afterDelay then arr:addObject(CCDelayTime:create(afterDelay)) end
	star:runAction(CCRepeatForever:create(CCSequence:create(arr)))
	return star
end

PushActivityPanelFail = class(Layer)

function PushActivityPanelFail:create(config)
	local panel = PushActivityPanelFail.new()
	if not panel:_init(config) then panel = nil end
	return panel
end

function PushActivityPanelFail:_init(config)
	if type(config) ~= "table" then return false end
	if type(config.rewards) ~= "table" or #config.rewards < 1 then return false end
	for k, v in ipairs(config.rewards) do
		if type(v.itemId) ~= "number" or type(v.num) ~= "number" then return false end
	end

	self:initLayer()
	local builder = InterfaceBuilder:createWithContentsOfFile(PanelConfigFiles.panel_push_activity)
	local panel = builder:buildGroup("PushActivityPanelFail")
	self:addChild(panel)
	self.panel = panel

	local text = panel:getChildByName("text")
	local bubbles, number, bubblePos = {}, {}, {}
	for i = 1, 4 do
		bubbles[i] = panel:getChildByName("bubble"..tostring(i))
		bubbles[i]:setVisible(false)
		number[i] = panel:getChildByName("number"..tostring(i))
		number[i]:setVisible(false)
		for j = 1, i do bubblePos[(i - 1) * 4 + j] = panel:getChildByName("bubble_"..tostring(i)..tostring(j)) end
	end
	local stars = {}
	for i = 1, 9 do stars[i] = panel:getChildByName("star"..tostring(i)) end
	local button = panel:getChildByName("button")
	button = GroupButtonBase:create(button)
	local rText = panel:getChildByName("rewardText")

	text:setString(config.pushText1)
	button:setString(config.pushButton1)
	rText:setString(Localization:getInstance():getText("activity.scene.push.reward.text"))
	rText:setAnchorPointCenterWhileStayOrigianlPosition()
	local pos = rText:getPosition()
	pos = ccp(pos.x, pos.y)
	rText:setDimensions(CCSizeMake(0, 0))
	rText:setString(Localization:getInstance():getText("activity.scene.push.reward.text"))
	rText:setPosition(pos)

	for k, v in pairs(bubblePos) do v:setVisible(false) end
	local length = math.min(#config.rewards, 4)
	local bubbleScale = 1
	if length > 3 then bubbleScale = 0.85 end
	for i = 1, length do
		bubbles[i]:setPositionX(bubblePos[(length - 1) * 4 + i]:getPositionX())
		bubbles[i]:setPositionY(bubblePos[(length - 1) * 4 + i]:getPositionY())
		if length > 3 then bubbles[i]:setScale(bubbleScale) end
		bubbles[i]:setVisible(true)
		local itemId = config.rewards[i].itemId
		local sprite
		-- if itemId == 2 then
			-- sprite = ResourceManager:sharedInstance():buildGroup("stackIcon")
			-- sprite:setScale(0.8 * bubbleScale)
		-- elseif itemId == 14 then
			-- sprite = Sprite:createWithSpriteFrameName("wheel0000")
			-- sprite:setScale(1.5 * bubbleScale)
			-- sprite:setAnchorPoint(ccp(-0.1, 1.1))
		-- else
			sprite = ResourceManager:sharedInstance():buildItemGroup(itemId)
			sprite:setScale(1.1 * bubbleScale)
		-- end
		local size = sprite:getGroupBounds().size
		sprite:setPositionXY(bubbles[i]:getPositionX() - size.width / 2,
			bubbles[i]:getPositionY() + size.height / 2)
		number[i]:setText('x'..tostring(config.rewards[i].num))
		number[i]:setScale(1.2)
		if config.rewards[i].num > 1000 then number[i]:setScale(1.06) end
		local size = number[i]:getGroupBounds().size
		local bSize = bubbles[i]:getGroupBounds().size
		number[i]:setPositionX(bubbles[i]:getPositionX() - size.width / 2 + 35)
		number[i]:setPositionY(bubbles[i]:getPositionY() - bSize.height / 2 + size.height + 20 * bubbleScale - 15)
		number[i]:setVisible(true)
		panel:addChildAt(sprite, panel:getChildIndex(number[i]))
		for j = 1, 6 do
			local star = createStarAnim(math.random() * 3, math.random() * 3)
			local angle = math.random() * 360
			star:setPositionX(bubbles[i]:getPositionX() + math.random(bSize.width / 2) * math.sin(angle * math.pi / 180))
			star:setPositionY(bubbles[i]:getPositionY() + math.random(bSize.width / 2) * math.cos(angle * math.pi / 180))
			panel:addChild(star)
		end
		local arr = CCArray:create()
		arr:addObject(CCScaleTo:create(0.4, bubbleScale * 1.1, bubbleScale * 1.2))
		arr:addObject(CCScaleTo:create(0.4, bubbleScale * 1.2, bubbleScale * 1.1))
		arr:addObject(CCScaleTo:create(0.2, bubbleScale * 1.2))
		bubbles[i]:runAction(CCRepeatForever:create(CCSequence:create(arr)))
	end

	local function onButton()
		DcUtil:UserTrack({category = "energy", sub_category = "energy_banner_activity"}, true)
		DcUtil:pushActivityClick(1)

		DcUtil:UserTrack({category = "clover_push", sub_category = "clover_push_level_fail_click"})

		local data = ActivityData.new(config)
		data:start(true)
	end
	button:addEventListener(DisplayEvents.kTouchTap, onButton)



	DcUtil:UserTrack({category = "clover_push", sub_category = "clover_push_level_fail_push"})

	return true
end

function PushActivityPanelFail:popout(parent, callback)
	local parent = self.energyPanel or parent
 	local box = self.panel:getGroupBounds().size
 	box = {width = box.width, height = box.height}
 	-- self.panel:setPositionY(box.height)
 	self.panel:setPositionX(self.panel:getPositionX() - 83 + 75 * parent:getScale())
 	self.panel:setPositionY(620)
 	FrameLoader:loadArmature("skeleton/chicken_fly_animation")
 	local chicken1 = ArmatureNode:create("chickenzs_happy")
 	chicken1:stop()
 	chicken1:setPositionXY(60, 0)
 	self:addChild(chicken1)
 	local expand = 0
 	local function panelPopinFinish()
 		local config = StartGamePanelConfig:create(parent)
 		local topPanelInitX = config:topPanelInitX()
		local topPanelInitY = config:topPanelInitY()
		local topPanelExpanX	= config:topPanelExpanX()
		local topPanelExpanY	= config:topPanelExpanY()
 		local rankListInitX	= config:rankListInitX()
		local rankListInitY	= config:rankListInitY()
		local rankListExpanX	= config:rankListExpanX()
		local rankListExpanY	= config:rankListExpanY()

		local topPanelHeight = parent:getTopPanel():getGroupBounds().size.height
		local rankListHeight = parent:getRankList():getGroupBounds().size.height


		-- parent:setTopPanelExpanPos(topPanelExpanX, topPanelExpanY)
		-- parent:setRankListExpanPos(rankListExpanX, rankListExpanY)

		parent.topPanelExpanY = parent.topPanelExpanY + 250
		parent.rankListExpanY = parent.rankListExpanY + 250

		-- parent:setTopPanelExpanPos(topPanelExpanX, topPanelExpanY)
		-- parent:setTopPanelExpanPos(topPanelExpanX, topPanelExpanY)


		-- local stencil = parent.rankListPanelClipping:getStencil()
		-- stencil:changeHeight(stencil:getContentSize().height + 300)
		-- local size = self.rankListPanelClipping:getContentSize()
		-- self.rankListPanelClipping:setContentSize(CCSizeMake(size.width, size.height + 300))

 		local chicken2 = ArmatureNode:create("chickenzs2")
 		chicken2:setPositionXY(chicken1:getPositionX(), chicken1:getPositionY())
 		chicken2:setAnimationScale(1.25)
 		chicken2:playByIndex(0)
 		self:addChild(chicken2)
 		chicken1:removeFromParentAndCleanup(true)
 		if callback then callback() end
 	end
 	local function chickenAnimFinish()
 		local arr = CCArray:create()
 		arr:addObject(CCMoveBy:create(0.2, ccp(0, -320)))
 		arr:addObject(CCMoveBy:create(0.12, ccp(0, -20)))
 		arr:addObject(CCMoveBy:create(0.08, ccp(0, 20)))
 		self.panel:runAction(CCSequence:create(arr))
 		local arr2 = CCArray:create()
 		arr2:addObject(CCMoveBy:create(0.16, ccp(0, -260)))
 		arr2:addObject(CCCallFunc:create(panelPopinFinish))
 		arr2:addObject(CCMoveBy:create(0.12, ccp(0, -20)))
 		arr2:addObject(CCMoveBy:create(0.08, ccp(0, 20)))
 		arr2:addObject(CCMoveBy:create(0.08, ccp(0, -10)))
 		arr2:addObject(CCMoveBy:create(0.08, ccp(0, 10)))
 		parent:runAction(CCSequence:create(arr2))
 	end
 	local function chickenMoveFinish()
 		chicken1:setAnimationScale(1.25)
 		chicken1:playByIndex(0)
 		local arr = CCArray:create()
 		arr:addObject(CCDelayTime:create(1.3))
 		arr:addObject(CCMoveBy:create(0.16, ccp(0, 100)))
 		arr:addObject(CCMoveBy:create(0.16, ccp(0, -100)))
 		arr:addObject(CCCallFunc:create(chickenAnimFinish))
 		arr:addObject(CCDelayTime:create(0.2))
 		arr:addObject(CCRotateTo:create(0.08, 15))
 		arr:addObject(CCRotateTo:create(0.08, 0))
 		arr:addObject(CCRotateTo:create(0.08, -7.7))
 		arr:addObject(CCRotateTo:create(0.08, 0))
 		chicken1:runAction(CCSequence:create(arr))
 	end
 	local arr = CCArray:create()
 	arr:addObject(CCMoveBy:create(0.16, ccp(0, -300)))
 	arr:addObject(CCSpawn:createWithTwoActions(CCMoveBy:create(0.08, ccp(0, 40)), CCRotateTo:create(0.08, 11.2)))
 	arr:addObject(CCSpawn:createWithTwoActions(CCMoveBy:create(0.08, ccp(0, -40)), CCRotateTo:create(0.08, 0)))
 	arr:addObject(CCScaleTo:create(0.08, 1.05, 0.94))
 	arr:addObject(CCScaleTo:create(0, 1))
 	arr:addObject(CCDelayTime:create(0.1))
 	arr:addObject(CCCallFunc:create(chickenMoveFinish))
 	chicken1:runAction(CCSequence:create(arr))
 	local arr2 = CCArray:create()
 	arr2:addObject(CCDelayTime:create(0.25))
 	arr2:addObject(CCMoveBy:create(0, ccp(0, -10)))
 	arr2:addObject(CCMoveBy:create(0.08, ccp(0, 10)))
 	parent:runAction(CCSequence:create(arr2))
end

PushActivityPanelEnergy = class()

function PushActivityPanelEnergy:create(energyPanel, config)

	--2017/7/25 消二推广 改动此处逻辑 不再处理rewards字段 并修复ui bug

	-- debug.debug()
	-- if type(config.rewards) == "table" and #config.rewards >= 1 then
		-- return PushActivityPanelEnergyR:create(energyPanel, config)
	-- else

	return PushActivityPanelEnergyN:create(energyPanel, config)

	-- end
end

PushActivityPanelEnergyR = class(BaseUI)

function PushActivityPanelEnergyR:create(energyPanel, config)
	local panel = PushActivityPanelEnergyR.new()
	panel:_init(energyPanel, config)
	return panel
end

function PushActivityPanelEnergyR:_init(energyPanel, config)
	if type(config) ~= "table" then return false end
	if type(config.rewards) ~= "table" or #config.rewards < 1 then return false end
	for k, v in ipairs(config.rewards) do
		if type(v.itemId) ~= "number" or type(v.num) ~= "number" then return false end
	end
	self.energyPanel = energyPanel

	local builder = InterfaceBuilder:createWithContentsOfFile(PanelConfigFiles.panel_push_activity)
	self.panel = builder:buildGroup("PushActivityPanelEnergyReward")
	BaseUI.init(self, self.panel)
	self.anim = builder:buildGroup("PushActivityPanelEnergyRewardAnim")

	local button = self.panel:getChildByName("button")
	button = GroupButtonBase:create(button)
	self.button = button
	local text = self.panel:getChildByName("text")
	self.box = self.anim:getChildByName("box")
	self.placeHolder = self.anim:getChildByName("phstart")
	self.placeHolder:setVisible(false)
	local bubblePos = {}
	for i = 1, 4 do
		for j = 1, i do
			bubblePos[(i - 1) * 4 + j] = self.anim:getChildByName("bubble_"..tostring(i)..tostring(j))
			bubblePos[(i - 1) * 4 + j]:setVisible(false)
		end
	end
	self.bubbles = {}
	local scales = {
		{1.23},
		{1.23, 1.02},
		{1.11, 1.02, 0.77},
		{1.11, 0.85, 0.8, 0.75},
	}
	local length = math.min(#config.rewards, 4)
	for i = 1, 4 do
		local bubble = self.anim:getChildByName("bubble"..tostring(i))
		if i <= length then
			local itemId = config.rewards[i].itemId
			if itemId == 2 then
				local sprite = ResourceManager:sharedInstance():buildGroup("stackIcon")
				sprite:setScale(0.7)
				sprite:setPositionXY(-50, 50)
				bubble:addChild(sprite)
			elseif itemId == 14 then
				local sprite = Sprite:createWithSpriteFrameName("wheel0000")
				sprite:setScale(1.5)
				bubble:addChild(sprite)
			else
				local sprite = ResourceManager:sharedInstance():buildItemGroup(itemId)
				sprite:setScale(0.9)
				sprite:setPositionXY(-50, 50)
				bubble:addChild(sprite)
			end
			local text = bubble:getChildByName("text")
			text:setText("x"..tostring(config.rewards[i].num))
			text:removeFromParentAndCleanup(false)
			bubble:addChild(text)
			local size = text:getContentSize()
			if config.rewards[i].num < 1000 then
				text:setPositionX(-size.width / 2)
			else
				text:setScale(0.7)
				text:setPositionX(-size.width * 0.7 / 2)
			end

			bubble.scaleRec = scales[length][i]
			bubble.positionXRec = bubblePos[(length - 1) * 4 + i]:getPositionX()
			bubble.positionYRec = bubblePos[(length - 1) * 4 + i]:getPositionY()
			table.insert(self.bubbles, bubble)
		else bubble:setVisible(false) end
	end

	text:setString(config.pushText2)
	button:setString(config.pushButton2)

	local function onButton()
		DcUtil:UserTrack({category = "energy", sub_category = "energy_banner_activity"}, true)
		DcUtil:pushActivityClick(2)
		local data = ActivityData.new(config)
		data:start(true)
	end
	button:addEventListener(DisplayEvents.kTouchTap, onButton)

	self:popout()
end

function PushActivityPanelEnergyR:popout()
	local scene = Director:sharedDirector():getRunningScene()
	local wSize = Director:sharedDirector():getWinSize()
	local vSize = Director:sharedDirector():getVisibleSize()
	local vOrigin = Director:sharedDirector():getVisibleOrigin()
	self.box:setPositionY(-200)
	local animWidth = 0
	for k, v in ipairs(self.bubbles) do
		local bSize = v:getGroupBounds().size
		animWidth = math.max(animWidth, v.positionXRec + bSize.width * v.scaleRec / 2)
		v:setPositionXY(self.placeHolder:getPositionX(), self.placeHolder:getPositionY())
		v:setScale(0)
	end
	local boxTop = self.box:getChildByName("top")
	boxTop:setAnchorPointWhileStayOriginalPosition(ccp(0, 0))
	boxTop:setRotation(0)
	local boxLight = self.box:getChildByName("light")
	boxLight:setVisible(false)

	local arr1 = CCArray:create()
	arr1:addObject(CCMoveBy:create(0.25, ccp(0, 420)))
	arr1:addObject(CCDelayTime:create(0.125))
	arr1:addObject(CCSpawn:createWithTwoActions(CCMoveBy:create(0.125, ccp(0, -200)), CCScaleTo:create(0.125, 1.3, 0.85)))
	arr1:addObject(CCSpawn:createWithTwoActions(CCMoveBy:create(0.08, ccp(0, 20)), CCScaleTo:create(0.08, 1)))
	arr1:addObject(CCMoveBy:create(0.08, ccp(0, -20)))
	arr1:addObject(CCDelayTime:create(0.08))
	arr1:addObject(CCScaleTo:create(0.125, 1, 0.75))
	arr1:addObject(CCDelayTime:create(0.25))
	arr1:addObject(CCScaleTo:create(0, 1))
	self.box:stopAllActions()
	self.box:runAction(CCSequence:create(arr1))
	local arr2 = CCArray:create()
	arr2:addObject(CCDelayTime:create(1.25))
	arr2:addObject(CCToggleVisibility:create())
	boxLight:stopAllActions()
	boxLight:runAction(CCSequence:create(arr2))
	local arr3 = CCArray:create()
	arr3:addObject(CCDelayTime:create(1))
	arr3:addObject(CCRotateTo:create(0.08, 14.2))
	arr3:addObject(CCRotateTo:create(0.08, -32.1))
	arr3:addObject(CCRotateTo:create(0.08, -14.7))
	for i = 1, #self.bubbles - 1 do
		arr3:addObject(CCDelayTime:create(0.2))
		arr3:addObject(CCRotateTo:create(0, -24.4))
		arr3:addObject(CCRotateTo:create(0.08, -14.7))
	end
	boxTop:stopAllActions()
	boxTop:runAction(CCSequence:create(arr3))

	for k, v in ipairs(self.bubbles) do
		local arr1 = CCArray:create()
		arr1:addObject(CCDelayTime:create(k * 0.25 + 0.9))
		arr1:addObject(HeBezierTo:create(0.29 - k * 0.02, ccp(v.positionXRec, v.positionYRec), false, -70))
		local function changeAnchorPoint() v:setAnchorPointWhileStayOriginalPosition(ccp(1, 0.5)) end
		arr1:addObject(CCCallFunc:create(changeAnchorPoint))
		arr1:addObject(CCRotateTo:create(0.08, -7.7))
		arr1:addObject(CCRotateTo:create(0.08, 0))
		local function restoreAnchorPoint() v:setAnchorPointWhileStayOriginalPosition(ccp(0.5, 0.5)) end
		arr1:addObject(CCCallFunc:create(restoreAnchorPoint))
		local function createStars()
			for j = 1, 6 do
			local star = createStarAnim(math.random() * 3, math.random() * 3)
			local angle = math.random() * 360
			local bSize = v:getGroupBounds().size
			star:setPositionX(math.random(bSize.width / 2) * math.sin(angle * math.pi / 180))
			star:setPositionY(math.random(bSize.width / 2) * math.cos(angle * math.pi / 180))
			v:addChild(star)
		end
		end
		arr1:addObject(CCCallFunc:create(createStars))
		local arr2 = CCArray:create()
		arr2:addObject(CCDelayTime:create(k * 0.25 + 0.9))
		arr2:addObject(CCScaleTo:create(0.29 - k * 0.02, v.scaleRec))
		local arr3 = CCArray:create()
		arr3:addObject(CCScaleTo:create(0.4, 0.95 * v.scaleRec, v.scaleRec))
		arr3:addObject(CCScaleTo:create(0.4, v.scaleRec, 0.95 * v.scaleRec))
		arr3:addObject(CCScaleTo:create(0.2, v.scaleRec, v.scaleRec))
		arr1:addObject(CCRepeatForever:create(CCSequence:create(arr3)))
		v:stopAllActions()
		v:runAction(CCSpawn:createWithTwoActions(CCSequence:create(arr1), CCSequence:create(arr2)))
	end

	local config 		= UIConfigManager:sharedInstance():getConfig()
	local panelScale	= config.panelScale
	self.anim:setScale(panelScale)
	local size = self.anim:getGroupBounds().size
	self.anim:setPositionY(-300)
	-- self.anim:setPositionX(vOrigin.x + (vSize.width - size.width) / 2)
	self.anim:setPositionX(29)
	self:addChild(self.anim)
end

function PushActivityPanelEnergyR:remove()
	local list = {}
	self.anim:getVisibleChildrenList(list)
	for k, v in ipairs(list) do v:runAction(CCFadeOut:create(0.3)) end
	list = {}
	self.button:setEnabled(false)
	self.panel:getVisibleChildrenList(list)
	for k, v in ipairs(list) do v:runAction(CCFadeOut:create(0.3)) end
	local function removeSelf() PopoutManager:sharedInstance():remove(self) end
	self:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.3), CCCallFunc:create(removeSelf)))
end

function PushActivityPanelEnergyR:onKeyBackClicked()
	if self.energyPanel then self.energyPanel:onCloseBtnTapped() end
end

PushActivityPanelEnergyN = class(BaseUI)

function PushActivityPanelEnergyN:create(energyPanel, config)
	local panel = PushActivityPanelEnergyN.new()
	
	panel:_init(energyPanel, config)
	panel.panelPluginType = "Pendant"

	return panel
end

function PushActivityPanelEnergyN:_init(energyPanel, config)
	if type(config) ~= "table" then if _G.isLocalDevelopMode then printx(0, "false") end return false end
	self.energyPanel = energyPanel

	self.panel = ResourceManager:sharedInstance():buildGroup("WeeklyRacePromotionPanel/rankRace")
	BaseUI.init(self, self.panel)
	local notice = self.panel:getChildByName("pic")
	notice:setVisible(false)

	local size = notice:getContentSize()
	local sx, sy = notice:getScaleX(), notice:getScaleY()
	local dark = LayerColor:createWithColor(ccc3(0, 0, 0), size.width*sx, size.height*sy)
	dark:setOpacity(0.7*255)
	local pos = notice:getPosition()
	dark:ignoreAnchorPointForPosition(false)
	dark:setAnchorPoint(ccp(0, 1))
	self.panel:addChild(dark)
	dark:setPosition(ccp(pos.x, pos.y))

	local animation = self:_buildLoadingAnimation()
	local size = self.panel:getGroupBounds().size
	animation:setPositionXY(size.width / 2, -size.height / 2 - 30)
	self.panel:addChild(animation)

	local function onNotice(path)
		if self.isDisposed then return end
		if not path then
			return
		end

		animation:removeFromParentAndCleanup(true)
		dark:removeFromParentAndCleanup(true)

		local pic = self.panel:getChildByName('pic')
		pic:setAnchorPointCenterWhileStayOrigianlPosition()
		local pos = pic:getPosition()

		local targetWidth = pic:getScaleX() * pic:getContentSize().width
		local targetHeight = pic:getScaleY() * pic:getContentSize().height

		local sprite = Sprite:create(path)
		local layer = Layer:create()
		layer:ignoreAnchorPointForPosition(false)
		layer:setAnchorPoint(ccp(0, 0))
		layer:setPosition(ccp(pos.x, pos.y))

		if sprite then
			layer:addChild(sprite)
			local sx = targetWidth/sprite:getContentSize().width
			local sy = targetHeight/sprite:getContentSize().height
			sprite:setScale(math.min(sx, sy))
			pic:setVisible(false)
		else
			pic:setVisible(true)
		end

		self.panel:addChild(layer)

		if string.find(path or '', 'notice2') then
			DcUtil:UserTrack({category = "clover_push", sub_category = "clover_push_energy_push2"})
		else
			DcUtil:UserTrack({category = "clover_push", sub_category = "clover_push_energy_push"})
		end

		local function onClick()
			DcUtil:UserTrack({category = "energy", sub_category = "energy_banner_activity"}, true)
			DcUtil:pushActivityClick(3)

    		if string.find(path or '', 'notice2') then
				DcUtil:UserTrack({category = "clover_push", sub_category = "clover_push_energy_click2"})
			else
				DcUtil:UserTrack({category = "clover_push", sub_category = "clover_push_energy_click"})
			end


			local data = ActivityData.new(config)

			pcall(function ( ... )

				local source = config.source
				local config = require("activity/" .. source)
				if config.setStartFrom then
					config.setStartFrom('energyPanel')
				end

			end)

			data:start(true)
		end
		layer:setTouchEnabled(true, 0, true)
		layer:addEventListener(DisplayEvents.kTouchTap, onClick)
	end
	local data = ActivityData.new(config)

	data:getNoticeImage(onNotice)

	self:popout()
end

function PushActivityPanelEnergyN:_buildLoadingAnimation()
	local container	= Layer:create()

	local batch = SpriteBatchNode:createWithTexture(CCSprite:createWithSpriteFrameName("loading_ico_1 instance 10000"):getTexture())
	container:addChild(batch)

	local currentPosition = 0
	for i = 1, 6 do
		local animal = Sprite:createWithSpriteFrameName("loading_ico_"..i.." instance 10000")
		local contentSize = animal:getContentSize()
		animal:setPosition(ccp(currentPosition, 8))
		animal.oriX = currentPosition
		animal.oriY	= 8
		animal.move = function( self, delay )
			self:stopAllActions()
			self:setPosition(ccp(self.oriX, self.oriY))
			self:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(delay), CCSequence:createWithTwoActions(CCMoveTo:create(0.25, ccp(self.oriX, self.oriY + 25)), CCMoveTo:create(0.25, ccp(self.oriX, self.oriY)))))
		end
		currentPosition = currentPosition + contentSize.width + 5
		batch:addChild(animal)
		if i == 6 then currentPosition = currentPosition - contentSize.width - 5 end
	end
	local function onStartAnimation()
		for i = 0, 5 do
			local animal = batch:getChildAt(i)
			if animal then animal:move(i * 0.2) end
		end
	end
	batch:runAction(CCRepeatForever:create(CCSequence:createWithTwoActions(CCCallFunc:create(onStartAnimation), CCDelayTime:create(1.5))))
	batch:setPositionX(-currentPosition/2)

	--
	local labelText = Localization:getInstance():getText('activity.scene.loading.text')
	local label = TextField:create(labelText, nil, 24)
	label:setPositionY(-44)
	container:addChild(label)

	return container
end

function PushActivityPanelEnergyN:popout()
	self:stopAllActions()
end

function PushActivityPanelEnergyN:remove(parent, callback)
	self:stopAllActions()
	local sSize = self.bg:getGroupBounds().size
	local arr = CCArray:create()
	arr:addObject(CCMoveBy:create(0.3, ccp(0, sSize.height * 2)))
	if type(callback) == "function" then
		arr:addObject(CCCallFunc:create(callback))
	end
	self.panel:runAction(CCSequence:create(arr))
end

function PushActivityPanelEnergyN:onKeyBackClicked()
	if self.energyPanel then self.energyPanel:onCloseBtnTapped() end
end