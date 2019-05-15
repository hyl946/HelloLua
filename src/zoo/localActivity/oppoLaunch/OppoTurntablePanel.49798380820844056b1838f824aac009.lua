
OppoTurntablePanel = class(BasePanel)

function OppoTurntablePanel:ctor()
end

function OppoTurntablePanel:init(closeCallback)
	self.ui = self:buildInterfaceGroup("oppo_launch/OppoTurntable")
    BasePanel.init(self, self.ui)

    self.isVivo = OppoLaunchManager:isVivo()
    self.isMi = OppoLaunchManager:isMi()

    self.closeBtn = self.ui:getChildByName('closeBtn')	
	self.closeBtn:setTouchEnabled(true, 0, false)
	self.closeBtn:setButtonMode(true)
	self.closeBtn:addEventListener(DisplayEvents.kTouchTap, function ()
		self:onCloseBtnTapped()
		if closeCallback then closeCallback() end
	end)

	self.bg = self.ui:getChildByName("bg")
	self.bg:setOpacity(0)

	self:initTurntable()
	self:initTitlePart()
	self:initRewardPart()
	self:update()

	local npc = self.ui:getChildByName("npcPart")
	npc:getChildByName("label1"):setVisible(not self.isVivo and not self.isMi)
	npc:getChildByName("vivoLabel1"):setVisible(self.isVivo)
	npc:getChildByName("miLabel1"):setVisible(self.isMi)
end

function OppoTurntablePanel:initTurntable()
	self.turnTableUI = self.ui:getChildByName("mainPart")
	local rewardPool = OppoLaunchManager.getInstance():getRewardPool()

	for i, v in ipairs(rewardPool) do
		if i > 8 then break end
		local sprite = self.turnTableUI:getChildByName("item"..tostring(i))
		local icon = sprite:getChildByName("icon")
		local iSize = icon:getContentSize()
		local iScale = icon:getScale()
		iSize = {width = iSize.width * iScale, height = iSize.height * iScale}
		icon:setVisible(false)
		local num = sprite:getChildByName("number")

		if v.itemId == 2 then
			local image = ResourceManager:sharedInstance():buildGroup("stackIcon")
			local size = image:getGroupBounds().size
			local scale = iSize.width / size.width
			if scale > iSize.height / size.height then
				scale = iSize.height / size.height
			end
			image:setScale(scale)
			image:setPositionX(icon:getPositionX() + (iSize.width - size.width * scale) / 2)
			image:setPositionY(icon:getPositionY() - (iSize.height - size.height * scale) / 2)
			sprite:addChildAt(image, sprite:getChildIndex(icon))
		else
			local image
			if ItemType:isTimeProp(v.itemId) then
				image = ResourceManager:sharedInstance():buildItemGroup(ItemType:getRealIdByTimePropId(v.itemId))
			else
				image = ResourceManager:sharedInstance():buildItemGroup(v.itemId)
			end
			local size = image:getGroupBounds().size
			local scale = iSize.width / size.width
			if scale > iSize.height / size.height then
				scale = iSize.height / size.height
			end
			image:setScale(scale)
			image:setPositionX(icon:getPositionX() + (iSize.width - size.width * scale) / 2)
			image:setPositionY(icon:getPositionY() - (iSize.height - size.height * scale) / 2)
			sprite:addChildAt(image, sprite:getChildIndex(icon))
		end
		num:setText('x'..tostring(v.num))
		num:setScale(1.2)
		num:setPositionX(icon:getPositionX() + (iSize.width - num:getContentSize().width * 1.2) / 2)
	end
    self.turnTableUI:setRotation(22.5)
end

function OppoTurntablePanel:initTitlePart()
	local titlePartUI = self.ui:getChildByName("titlePart")

	titlePartUI:getChildByName("vivoTitle"):setVisible(self.isVivo)
	titlePartUI:getChildByName("title"):setVisible(not self.isVivo and not self.isMi)
	titlePartUI:getChildByName("miTitle"):setVisible(self.isMi)

	local label = titlePartUI:getChildByName("label")
	local num = OppoLaunchManager.getInstance():getContinueDayNum()
	label:setRichText(string.format("连续登录[#5EE1FF]%d[/#]天", num), "FFFFFF")
	label:setScale(0.8)
	label:setPositionX(label:getPositionX() + 10)

	local redDotUI = titlePartUI:getChildByName("redDot")
	self.redDotNum = redDotUI:getChildByName("label")

	self.btn = titlePartUI:getChildByName("btn")
	self.btn:setTouchEnabled(true, 0, false)
	self.btn:setButtonMode(true)
	self.btn:addEventListener(DisplayEvents.kTouchTap, function ()
		self.btn:setTouchEnabled(false)
		OppoLaunchManager:dc("oppoact_lottery_draw")
		local curReward = OppoLaunchManager.getInstance():getCurrentReward()
		if curReward then 
			self:turnToTarget(curReward)
		else
			CommonTip:showTip(localize("奖励信息获取失败~"),"negative")
		end
	end)
end

function OppoTurntablePanel:initRewardPart()
	local rewardPartUI = self.ui:getChildByName("rewardPart")	
	local label = rewardPartUI:getChildByName("label")
	label:setText(localize("恭喜您获得奖励:"))

	self.rewardLight = rewardPartUI:getChildByName("light")
	self.rewardLight:setAnchorPointCenterWhileStayOrigianlPosition()
	self.rewardLight:setScale(3.0)
	
	self.rewardBtn = GroupButtonBase:create(rewardPartUI:getChildByName("btn"))
    self.rewardBtn:addEventListener(DisplayEvents.kTouchTap, function ()
    	-- self.rewardBtn:setTouchEnabled(false)
    	self:hideReward()
    end)
    self.rewardBtn:setString("确定")
    self.rewardBtn:useBubbleAnimation()

	self.rewardPartUI = rewardPartUI
	self.rewardPartUI:setVisible(false)
end

function OppoTurntablePanel:turnToTarget(reward)
	local index = nil
	local rewardPool = OppoLaunchManager.getInstance():getRewardPool()
	for i, v in ipairs(rewardPool) do
		if v.itemId == reward.itemId and v.num == reward.num then
			index = i
			break
		end
	end

	if index then
		local r = 45 * (9 - index)
		local maxR = r + 5
		local minR = r - 5
		local rotate = math.random(minR, maxR)

		local function onFinished()
			if reward and reward.itemId and reward.num then 
				OppoLaunchManager:dc("oppoact_lottery_drawend", reward.itemId, reward.num)
			end
			if self.isDisposed then return end
			OppoLaunchManager.getInstance():addReward(reward)
			self:showReward(reward)
			self:update()
		end

		self.turnTableUI:stopAllActions()

		local rotated = self.turnTableUI:getRotation() % 360
		self.turnTableUI:setRotation(rotated)

		local targetR = rotate + 720 - rotated
		local time = 0.5*(targetR-rotated)/360 + 1.5

		if _G.isLocalDevelopMode then printx(0, "[OppoTurntablePanel] had turn rotate ", rotated) end
		if _G.isLocalDevelopMode then printx(0, "[OppoTurntablePanel] need turn rotate ", targetR) end

		self.turnTableUI:runAction(CCSequence:createWithTwoActions(CCEaseExponentialOut:create(CCRotateBy:create(time, targetR)), CCCallFunc:create(onFinished)))
	end
end

function OppoTurntablePanel:showReward(reward)
	if not self.rewardMaskLayer then 
		local size = CCDirector:sharedDirector():getWinSize()
		self.rewardMaskLayer = LayerColor:createWithColor(ccc3(0, 0, 0), size.width*2, size.height*2)
		self.rewardMaskLayer:setAnchorPoint(ccp(0,0))
		self.rewardMaskLayer:ignoreAnchorPointForPosition(false)
		self.rewardMaskLayer:setOpacity(200)
		self.rewardMaskLayer:setPosition(self.ui:convertToNodeSpace(ccp(0, 0)))
		self.rewardMaskLayer:setTouchEnabled(true, 0, true)
		self.ui:addChildAt(self.rewardMaskLayer, self.ui:getChildIndex(self.rewardPartUI))
	else
		self.rewardMaskLayer:setVisible(true)
	end
	self.rewardPartUI:setVisible(true)

	FrameLoader:loadArmature('skeleton/incite_show_reward')

	local animNode = ArmatureNode:create("incite/showReward")

	local slot = animNode:getSlot("item")

	local image = nil
	if reward.itemId == 2 then
		image = ResourceManager:sharedInstance():buildGroup("stackIcon")
	else
		if ItemType:isTimeProp(reward.itemId) then
			image = ResourceManager:sharedInstance():buildItemGroup(ItemType:getRealIdByTimePropId(reward.itemId))
		else
			image = ResourceManager:sharedInstance():buildItemGroup(reward.itemId)
		end
	end

	local sprite = Sprite:createEmpty()
	local size = image:getGroupBounds().size
	image:setPosition(ccp(size.width/2, -size.height/2))

	if reward.itemId == 2 then
		image:setPosition(ccp(size.width/2 - 40, -size.height/2 + 30))
	end

	sprite:addChild(image)

	local numLabel = BitmapText:create("x" .. reward.num, "fnt/event_default_digits.fnt")
	numLabel:setAnchorPoint(ccp(1,0))
	numLabel:setPositionX(size.width)
	numLabel:setPositionY(-size.height - 10)

	image:addChild(numLabel)

	slot:setDisplayImage(sprite.refCocosObj)

    animNode:setPosition(ccp(110, -310))
    self.ui:addChild(animNode)
    animNode:playByIndex(0)

    if self.rewardLight then 
	    self.rewardLight:setVisible(true)
	    self.rewardLight:runAction(CCRepeatForever:create(CCRotateBy:create(5, 360)))
	end

    self.animNode = animNode
end

function OppoTurntablePanel:hideReward()
	if self.rewardMaskLayer then self.rewardMaskLayer:setVisible(false) end
	if self.animNode then 
		self.animNode:removeFromParentAndCleanup(true) 
		self.animNode = nil
	end
	if self.rewardLight then self.rewardLight:stopAllActions() end
	if self.rewardPartUI then self.rewardPartUI:setVisible(false) end

	local leftRewardsNum = OppoLaunchManager.getInstance():getLeftRewardsNum()
	if leftRewardsNum == 0 then self:onCloseBtnTapped() end
end

function OppoTurntablePanel:update()
	local leftRewardsNum = OppoLaunchManager.getInstance():getLeftRewardsNum()
	if leftRewardsNum == 0 then 
		self.redDotNum:setString("0")
		self.btn:setTouchEnabled(false)
	else
		if leftRewardsNum > 9 then
			self.redDotNum:setString("9+")
		else
			self.redDotNum:setString(leftRewardsNum)
		end 
		self.btn:setTouchEnabled(true)
	end
end

function OppoTurntablePanel:getGroupBounds()
	return self.bg:getGroupBounds()
end

function OppoTurntablePanel:popout()
	self.allowBackKeyTap = true
    PopoutManager:sharedInstance():add(self, true, false)

    local uisize = self:getGroupBounds().size
	local director = Director:sharedDirector()
    local origin = director:getVisibleOrigin()
    local size = director:getVisibleSize()
    local hr = size.height / uisize.height
    local wr = size.width / uisize.width
    if hr < 1 then
    	self:setScale((hr < wr) and hr or wr)
    end

    local centerPosX = self:getHCenterInParentX()
    local centerPosY = self:getVCenterInParentY()
        
    self:setPosition(ccp(centerPosX, centerPosY))

    OppoLaunchManager:dc("oppoact_lottery_show")
end

function OppoTurntablePanel:onCloseBtnTapped()
	PopoutManager:sharedInstance():remove(self, true)
	self.allowBackKeyTap = false

	OppoLaunchManager.getInstance():updateBtnLastShowTime()
	
	-- if __WIN32 then
	-- 	OppoTurntableDesc:create():popout()
	-- end
end

function OppoTurntablePanel:create(closeCallback)
	local panel = OppoTurntablePanel.new()
    panel:loadRequiredResource(PanelConfigFiles.oppo_turntable)
    panel:init(closeCallback)
    return panel
end