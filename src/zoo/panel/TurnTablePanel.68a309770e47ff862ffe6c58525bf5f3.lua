require "zoo.panel.basePanel.BasePanel"
require "zoo.panel.component.turnTable.TurnTable"

TurnTablePanel = class(BasePanel)
TURN_TYPE = {kWX = "wx",
			 kRECALL = "recall"}

function TurnTablePanel:tryCreateTurnTable(turntableIndex)
	local networkTip = Localization:getInstance():getText("wxshare.turn.table.error.network")
	local function onSuccess(evt)
		if type(evt.data["repeat"]) ~= "boolean" then
			CommonTip:showTip(networkTip, "negative", nil, 5)
			return
		end
		if evt.data["repeat"] then
			HomeScene:sharedInstance().lastTurnTableTS = Localhost:time()
			CommonTip:showTip(Localization:getInstance():getText("wxshare.turn.table.error.repeat"), "negative", nil, 5)
			return
		end
		if type(evt.data.reward) == "table" and type(evt.data.reward.itemId) == "number" and
			type(evt.data.reward.num) == "number" then
			UserManager:getInstance():addReward(evt.data.reward)
			GainAndConsumeMgr.getInstance():gainItem(DcFeatureType.kTrunk, evt.data.reward.itemId, evt.data.reward.num, DcSourceType.kWXTurntableReward)
		end
		local panel = TurnTablePanel:create(evt.data.configs, evt.data.reward, turntableIndex)
		if panel then
			panel:popout()
			HomeScene:sharedInstance().lastTurnTableTS = Localhost:time()
		else
			CommonTip:showTip(networkTip, "negative", nil, 5)
		end
	end
	local function onError(evt)
		if evt.data == -2 or evt.data == -3 or evt.data == -6 then
			CommonTip:showTip(networkTip, "negative", nil, 5)
		else
			CommonTip:showTip(Localization:getInstance():getText("error.tip."..evt.data))
		end
	end
	local function onCancel()
		CommonTip:showTip(networkTip, "negative", nil, 5)
	end
	local http = WXShareHttp.new(true)
	http:addEventListener(Events.kComplete, onSuccess)
	http:addEventListener(Events.kError, onError)
	http:addEventListener(Events.kCancel, onCancel)
	http:load(0, turntableIndex)
end

function TurnTablePanel:tryCreateRecallTurnTable(tableId, finishCallback)
	local networkTip = Localization:getInstance():getText("wxshare.turn.table.error.network")
	local function onSuccess(evt)
		if type(evt.data.reward) == "table" and type(evt.data.reward.itemId) == "number" and
			type(evt.data.reward.num) == "number" then
			UserManager:getInstance():addReward(evt.data.reward)
			GainAndConsumeMgr.getInstance():gainItem(DcFeatureType.kRecall, evt.data.reward.itemId, evt.data.reward.num, DcSourceType.kRecallTurntableReward)
		end
		--获得了奖励 重置推送召回的本地流失状态
		RecallManager.getInstance():resetRecallRewardState()

		local panel = TurnTablePanel:create(evt.data.configs, evt.data.reward, nil, TURN_TYPE.kRECALL)
		if panel then
			if tableId == 1 then
				DcUtil:UserTrack({category = "recall", sub_category = "recall_turmtable", id = 3})
			elseif tableId == 2 then
				DcUtil:UserTrack({category = "recall", sub_category = "recall_turmtable", id = 5})
			end 
			panel:popout(finishCallback)
			HomeScene:sharedInstance().lastTurnTableTS = Localhost:time()
		else
			CommonTip:showTip(networkTip, "negative", finishCallback, 5)
		end
	end
	local function onError(evt)
		if evt.data == -2 or evt.data == -3 or evt.data == -6 then
			CommonTip:showTip(networkTip, "negative", finishCallback, 5)
		else
			CommonTip:showTip(Localization:getInstance():getText("error.tip."..evt.data), 'negative', finishCallback)
		end
	end
	local function onCancel()
		CommonTip:showTip(networkTip, "negative", finishCallback, 5)
	end
	local http = TurnTableHttp.new(true)
	http:addEventListener(Events.kComplete, onSuccess)
	http:addEventListener(Events.kError, onError)
	http:addEventListener(Events.kCancel, onCancel)
	http:load(tableId)
end

function TurnTablePanel:create(items, result, turnTable, turnType)
	local panel = TurnTablePanel.new()
	if not panel:_init(items, result, turnTable, turnType) then panel = nil end
	return panel
end

function TurnTablePanel:_init(items, result, turnTable, turnType)
	if type(items) ~= "table" or #items < 8 then return false end
	if type(result) ~= "table" or type(result.itemId) ~= "number" or
		type(result.num) ~= "number" then return false end
	local turnRes
	for k, v in ipairs(items) do
		if v.itemId == result.itemId and v.num == result.num then turnRes = k end
	end
	if _G.isLocalDevelopMode then printx(0, turnRes) end
	if type(turnRes) ~= "number" then return false end

	self:loadRequiredResource(PanelConfigFiles.panel_turntable)
	local panel = self:buildInterfaceGroup("turntablepanel")
	self:init(panel)
	self.panel = panel
	self.panelName = "turnTablePanel"
	

	local panelContent = panel:getChildByName("panelContent")
	local panelTip = panel:getChildByName("panelTip")

	local disk = panelContent:getChildByName("disk")
	local close = panelContent:getChildByName("close")
	local block = panelContent:getChildByName("block")
	local reward = panelContent:getChildByName("reward")
	local shine = panelContent:getChildByName("shine")
	local button = panelContent:getChildByName("button")
	local number = panelContent:getChildByName("number")
	button = GroupButtonBase:create(button)

	for i = 1, 8 do
		local width, height = 125, 125
		local item = disk:getChildByName("item"..tostring(i))
		if item then
			if i == 1 then
				local size = item:getGroupBounds().size
				width, height = size.width, size.height
			end
			local icon = item:getChildByName("icon")
			if icon then
				local sprite
				if items[i].itemId == 2 then
					sprite = ResourceManager:sharedInstance():buildGroup("stackIcon")
				elseif items[i].itemId == 14 then
					sprite = Sprite:createWithSpriteFrameName("Prop_14wrapper0000")
				else
					sprite = ResourceManager:sharedInstance():buildItemGroup(items[i].itemId)
				end
				local size = sprite:getGroupBounds().size
				local scale = width / size.width
				if scale > height / size.height then scale = height / size.height end
				sprite:setScale(scale)
				if items[i].itemId == 14 then
					sprite:setPositionX(0)
					sprite:setPositionY(-height / 2 + icon:getPositionY())
				else
					sprite:setPositionX(icon:getPositionX() + (width - size.width * scale) / 2)
					sprite:setPositionY(icon:getPositionY() + (height - size.height * scale) / 2)
				end
				item:addChildAt(sprite, 1)
				icon:removeFromParentAndCleanup(true)
			end
			local number = item:getChildByName("number")
			if number then
				number:setText('x'..tostring(items[i].num))
				if items[i].num >= 1000 then number:setScale(1.2)
				else number:setScale(1.5) end
				local size = number:getContentSize()
				number:setPositionX(-size.width * number:getScale() / 2)
			end
		end
	end
	self.turnTable = TurnTable:create(disk)
	self.turnTable:setTargetAngle(45 * (turnRes - 1), 40)
	local list = {}
	block:getVisibleChildrenList(list)
	for k, v in ipairs(list) do v:setOpacity(0) end
	local sprite
	if result.itemId == 2 then
		sprite = ResourceManager:sharedInstance():buildGroup("stackIcon")
	elseif result.itemId == 14 then
		sprite = Sprite:createWithSpriteFrameName("Prop_14wrapper0000")
	else
		sprite = ResourceManager:sharedInstance():buildItemGroup(result.itemId)
	end
	local size = sprite:getGroupBounds().size
	local recSize = reward:getGroupBounds().size
	local scale = recSize.width / size.width
	sprite:setAnchorPointCenterWhileStayOrigianlPosition()
	if scale > recSize.height / size.height then scale = recSize.height / size.height end
	sprite:setScale(scale)
	sprite.recScale = scale
	if result.itemId == 14 then
		sprite:setPositionX(disk:getPositionX())
		sprite:setPositionY(disk:getPositionY())
	else
		sprite:setPositionX(disk:getPositionX() - size.width * scale / 2)
		sprite:setPositionY(disk:getPositionY() + size.height * scale / 2)
	end
	sprite:setScale(0)
	local index = panelContent:getChildIndex(reward)
	panelContent:addChildAt(sprite, index)
	reward:removeFromParentAndCleanup(true)
	self.reward = sprite
	shine:setAnchorPointCenterWhileStayOrigianlPosition()
	shine:setScale(0)
	number:setText('x'..tostring(result.num))
	number:setScale(1.5)
	number:setOpacity(0)
	button:setString(Localization:getInstance():getText("beginner.panel.btn.get.text"))
	button:setVisible(false)
	close:setVisible(false)

	self.animation = Layer:create()
	local anim1 = ArmatureNode:create("huanxiong_anime")
	local anim2 = ArmatureNode:create("thre_anime")
	local leaf = self:buildInterfaceGroup("turntablepanel_animbg")
	anim1:setPositionXY(-50, 50)
	anim1:playByIndex(0)
	anim1:setScale(1.2)
	local function stopAnim1() anim1:stop() end
	anim1:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.1), CCCallFunc:create(stopAnim1)))
	anim2:setPositionXY(-270, 58)
	anim2:playByIndex(0)
	anim2:setScale(1.2)
	local function stopAnim2() anim2:stop() end
	anim2:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.1), CCCallFunc:create(stopAnim2)))
	leaf:setPositionXY(-40, 85)
	self.animation:addChild(leaf)
	self.animation:addChild(anim2)
	self.animation:addChild(anim1)
	self.animation:setScale(1.2 * UIConfigManager:sharedInstance():getConfig().panelScale)

	local function onClose() self:onCloseBtnTapped() end
	close:setTouchEnabled(true)
	close:setButtonMode(true)
	close:addEventListener(DisplayEvents.kTouchTap, onClose)
	local function onAnimFinish()
		local list = {}
		block:getVisibleChildrenList(list)
		for k, v in ipairs(list) do v:runAction(CCFadeIn:create(0.3)) end
		local function onFinish() button:setVisible(true) end
		sprite:runAction(CCSequence:createWithTwoActions(CCEaseBackIn:create(CCScaleTo:create(0.3, sprite.recScale)),
			CCCallFunc:create(onFinish)))
		shine:runAction(CCRepeatForever:create(CCRotateBy:create(1, 60)))
		shine:runAction(CCEaseBackIn:create(CCScaleTo:create(0.3, 1)))
		number:runAction(CCFadeIn:create(0.3))
	end
	local function onTouchEnd(evt)
		self.turnTable:setEnabled(false)
		self.turnTable:calcStopping(evt.data.speed)
	end
	local function onTouchSlow()

	end
	self.turnTable:setEnabled(true)
	self.turnTable:addEventListener(TurnTableEvents.kTouchEnd, onTouchEnd)
	self.turnTable:addEventListener(TurnTableEvents.kAnimFinish, onAnimFinish)

	local function onReward()
		self:_getReward(result)
		self.reward:setVisible(false)
		self:onCloseBtnTapped()
	end
	button:setEnabled(true)
	button:addEventListener(DisplayEvents.kTouchTap, onReward)

	self:scaleAccordingToResolutionConfig()
	self:setPositionForPopoutManager()
	-- self:setPositionY(self:getGroupBounds().size.height)
	-- self:setPositionY(0)

	if not turnType then 
		turnType = TURN_TYPE.kWX
	end
	if turnType == TURN_TYPE.kRECALL then 
		self.turnTable:setEnabled(false)
		self:showRecallTip(panelTip)
	else
		panelTip:setVisible(false)
		DcUtil:UserTrack({category = "wx_share", sub_category = "get_wx_reward", reward_id = turnRes, turn_table = turnTable})
	end

	return true
end

function TurnTablePanel:showRecallTip(tipUi)
	local tipBg = tipUi:getChildByName("bg")	
	local tip = tipUi:getChildByName("tip")
	tip:setString(Localization:getInstance():getText("recall_text_16"))

	local array = CCArray:create()
	array:addObject(CCDelayTime:create(5))
	local function fadeOut()
		if tipUi then
			local childrenList = {}
			tipUi:getVisibleChildrenList(childrenList)
			for __, v in pairs(childrenList) do
				v:runAction(CCFadeOut:create(0.5))
			end
		end
	end
	array:addObject(CCCallFunc:create(fadeOut))
	array:addObject(CCDelayTime:create(0.5))
	local function onComplete() 
		tipUi:setVisible(false)
		self.turnTable:setEnabled(true)
	end
	array:addObject(CCCallFunc:create(onComplete))
	tipUi:runAction(CCSequence:create(array))
end

function TurnTablePanel:popout(closeCallback)
	self.closeCallback = closeCallback
	-- PopoutManager:sharedInstance():addWithBgFadeIn(self, true, false, false, 0.5)
	-- local x = self:getPositionX()
	-- self:runAction(CCEaseBackOut:create(CCMoveTo:create(0.5, ccp(x, 0))))
	-- local scene = Director:sharedDirector():getRunningScene()
	local wSize = Director:sharedDirector():getWinSize()
	local vSize = Director:sharedDirector():getVisibleSize()
	local vOrigin = Director:sharedDirector():getVisibleOrigin()
	-- self.animation:stopAllActions()
	-- self.animation:setPositionXY(vOrigin.x + vSize.width, vOrigin.y * 2 - 300 - wSize.height)
	-- self.animation:runAction(CCMoveTo:create(0.3, ccp(vOrigin.x + vSize.width, vOrigin.y * 2 - 100 - wSize.height)))
	-- local container = PopoutManager:sharedInstance():getChildContainer(self)
	-- container:addChild(self.animation)

	local position = ccp(vOrigin.x + vSize.width, vOrigin.y * 2 - 85 - wSize.height)
	local nPosition = self:convertToNodeSpace(ccp(position.x, position.y))
	self.animation:setPositionXY(nPosition.x, nPosition.y)
	self:addChild(self.animation)

	PopoutQueue:sharedInstance():push(self)
end

function TurnTablePanel:onCloseBtnTapped()
	-- -- self.allowBackKeyTap = false
	-- self.turnTable:setEnabled(false)
	-- local x, y = self:getPositionX(), self:getGroupBounds().size.height
	-- self:runAction(CCEaseBackIn:create(CCMoveTo:create(0.5, ccp(x, y))))
	-- local function onFinish() self.animation:removeFromParentAndCleanup(true) end
	-- local wSize = Director:sharedDirector():getWinSize()
	-- local vOrigin = Director:sharedDirector():getVisibleOrigin()
	-- local vSize = Director:sharedDirector():getVisibleSize()
	-- self.animation:stopAllActions()
	-- self.animation:runAction(CCSequence:createWithTwoActions(CCMoveTo:create(0.3,
	-- 	ccp(vOrigin.x + vSize.width, vOrigin.y * 2 - 300 - wSize.height)), CCCallFunc:create(onFinish)))
	-- PopoutManager:sharedInstance():removeWithBgFadeOut(self, false, nil, 0.5)
	PopoutManager:sharedInstance():remove(self)
	if self.closeCallback then
		self.closeCallback() 
	end
end

function TurnTablePanel:_getReward(reward)
	local scene = HomeScene:sharedInstance()
	if not scene then return end
	scene:checkDataChange()

	local anim = FlyItemsAnimation:create({reward})
	local bounds = self.reward:getGroupBounds()
	anim:setWorldPosition(ccp(bounds:getMidX(),bounds:getMidY()))
	anim:setScaleX(self.reward:getScaleX())
	anim:setScaleY(self.reward:getScaleY())
	anim:play()
end