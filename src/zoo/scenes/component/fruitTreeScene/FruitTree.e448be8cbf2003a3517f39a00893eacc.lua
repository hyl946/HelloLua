require "zoo.scenes.component.fruitTreeScene.Fruit"
require "zoo.scenes.component.fruitTreeScene.VideoFruit"

kFruitTreeEvents = {
	kUpdate = "kFruitTreeEvents.kUpdate",
	kUpdateData = "kFruitTreeEvents.kUpdateData",
	kFruitClicked = "kFruitTreeEvents.kFruitClicked",
	kFruitReleased = "kFruitTreeEvents.kFruitReleased",
	kExit = "kFruitTreeEvents.kExit",
}

FruitTree = class(CocosObject)

function FruitTree:create(data)
	local tree = FruitTree.new()
	if not tree:_init(data) then tree = nil end
	return tree
end

function FruitTree:ctor()
	self:setRefCocosObj(CCNode:create())
end

function FruitTree:dispose()
	CocosObject.dispose(self)
	InterfaceBuilder:unloadAsset(PanelConfigFiles.fruitTreeScene)
end

function FruitTree:_init(data)
	-- data
	FruitTreeModel:sharedInstance():resetData()
	FruitTreeModel:sharedInstance():setFruitInfo(data)
	self.absoluteBlock = false

	-- get & create controls
	local builder = InterfaceBuilder:createWithContentsOfFile(PanelConfigFiles.fruitTreeScene)
	self.ui = builder:buildGroup("fruitTree")
	self.fruitPos, counter = {}, 1
	while true do
		local fruit = self.ui:getChildByName("fruit"..tostring(counter))
		if not fruit then break end
		local pos = fruit:getPosition()
		table.insert(self.fruitPos, {x = pos.x, y = pos.y})
		fruit:removeFromParentAndCleanup(true)
		counter = counter + 1
	end
	self:addChild(self.ui)

	--视频广告果子
	self.fruitPos[-1] = VideoFruit.POS

	-- for game guide
	local function onEnterHandler(evt) self:_onEnterHandler(evt) end
	self:registerScriptHandler(onEnterHandler)

	self:refresh("init")

	return true
end

function FruitTree:_onFruitClicked(target)
	if self.guided then return end
	local fruit = target
	local wSize = Director:sharedDirector():getWinSize()
	local scene = Director:sharedDirector():getRunningScene()
	if self.clickedFruit then
		return
	end
	if fruit:getId() == 4 then
		if self.tutorHand then
			local handPos = self.tutorHand:getPosition()
			local gHandPos = self:convertToWorldSpace(handPos)
			self.tutorHand:removeFromParentAndCleanup(true)
			self.tutorHand = nil
			-- CCUserDefault:sharedUserDefault():setIntegerForKey("fruit.tree.tutorial", 1)
			-- CCUserDefault:sharedUserDefault():flush()
			self:_clickTutor(gHandPos)
			self.guided = true
		end
	else
		-- CCUserDefault:sharedUserDefault():setIntegerForKey("fruit.tree.tutorial", 2)
		-- CCUserDefault:sharedUserDefault():flush()
	end

	if not self.absoluteBlock and not self.clickedFruit then
		local clickedFruit = fruit:createClickedFruit(self.guided, 0.1)
		if not self.maskLayer then
			self.maskLayer = LayerColor:create()
			self.maskLayer:changeWidthAndHeight(wSize.width, wSize.height)
			self.maskLayer:setColor(ccc3(0, 0, 0))
			self.maskLayer:setOpacity(0)
			self.maskLayer:runAction(CCFadeTo:create(0.1, 125))
			self.maskLayer:setPosition(ccp(0, 0))
			self.maskLayer:setTouchEnabled(true, 0, true)
			if scene.guideLayer then scene:addChildAt(self.maskLayer, scene:getChildIndex(scene.guideLayer))
			else scene:addChild(self.maskLayer) end
		end
		if not self.maskLayer:isVisible() then self.maskLayer:setVisible(true) end
		self.clickedFruit = fruit
		self.maskLayer:addChild(clickedFruit)
		self:dispatchEvent(Event.new(kFruitTreeEvents.kFruitClicked, target:getId(), self))
	else
		self.clickedFruit = nil
	end
end

function FruitTree:endFruitTreeGuide()
	local function endGuide()
        UserLocalLogic:setGuideFlag( kGuideFlags.FruitTreePick )
	end

	if self.tutorHand then
		self.tutorHand:removeFromParentAndCleanup(true)
		self.tutorHand = nil
		-- CCUserDefault:sharedUserDefault():setIntegerForKey("fruit.tree.tutorial", 2)
		-- CCUserDefault:sharedUserDefault():flush()
		endGuide()
	elseif self.tutorLayer then
		self.tutorLayer:removeFromParentAndCleanup(true)
		self.tutorLayer = nil
		-- CCUserDefault:sharedUserDefault():setIntegerForKey("fruit.tree.tutorial", 2)
		-- CCUserDefault:sharedUserDefault():flush()
		endGuide()
	end
	if self.clickedFruit then
		self:_onFruitCanceled(self.clickedFruit)
	end
	self.guided = false
end

function FruitTree:_onFruitCanceled(target)
	local fruit = target
	if self.clickedFruit and self.clickedFruit == fruit then
		self.clickedFruit:removeClickedFruit(0.1)
		local function onAnimFinish()
			self.clickedFruit = nil
			if self.maskLayer.isDisposed then return end
			self.maskLayer:removeFromParentAndCleanup(true)
			self.maskLayer = nil
			self:dispatchEvent(Event.new(kFruitTreeEvents.kFruitReleased, nil, self))
		end
		self.maskLayer:runAction(CCSequence:createWithTwoActions(CCFadeTo:create(0.1, 0), CCCallFunc:create(onAnimFinish)))
	end
end

function FruitTree:_onFruitUpdate(target)
	local function onSuccess()
		self:refresh("update", target)
		self:dispatchEvent(Event.new(kFruitTreeEvents.kUpdate, nil, self))
	end
	local function onFail(err)
		local function exit() self:dispatchEvent(Event.new(kFruitTreeEvents.kExit, nil, self)) end
		CommonTip:showTip(Localization:getInstance():getText("error.tip."..tostring(err)), "negative", exit)
	end
	local logic = FruitTreeLogic:create()
	logic:updateTreeInfo(onSuccess, onFail)
end

function FruitTree:updateSeed5()

	-- local level = FruitTreePanelModel:sharedInstance():getTreeLevel()
	-- local fruit = self.fruits[5] 
	-- if fruit then
	-- 	fruit:setVisible( level >= 5 )
	-- end

end

function FruitTree:refresh(source, target)
	self.fruits = self.fruits or {}

	-- if _G.isLocalDevelopMode  then printx(100 , "FruitTree refresh getFruitInfo= " , table.tostring( FruitTreeModel:sharedInstance():getFruitInfo() ) ) end

	local function createFruit(id,info)

		local fruit
		if id<0 then
			fruit = VideoFruit:create(id,info)
		else
			fruit = Fruit:create(id,info)
		end
		local pos = self.fruitPos[id]
		fruit:setPosition(ccp(pos.x, pos.y))
		self.ui:addChild(fruit)
		self.fruits[id] = fruit
		local function onFruitClicked(evt)
			self:_onFruitClicked(evt.target)
		end
		fruit:addEventListener(kFruitEvents.kNormClicked, onFruitClicked)
		local function onClickedFruitCanceled(evt)
			self:_onFruitCanceled(evt.target)
		end
		fruit:addEventListener(kFruitEvents.kSelectedCancel, onClickedFruitCanceled)
		local function onPick(evt)
			self:endFruitTreeGuide()
			self:dispatchEvent(Event.new(kFruitTreeEvents.kUpdateData, nil, self))
		end
		fruit:addEventListener(kFruitEvents.kPick, onPick)
		local function onRegenerate(evt)
			self:endFruitTreeGuide()
			self:dispatchEvent(Event.new(kFruitTreeEvents.kUpdateData, nil, self))
		end
		fruit:addEventListener(kFruitEvents.kRegenerate, onRegenerate)
		local function onUpdate(evt)
			self:_onFruitUpdate(evt.target)
		end
		fruit:addEventListener(kFruitEvents.kUpdate, onUpdate)

		if id==-1 then
			DcUtil:adsIOSClick({
					sub_category = "fruittree_adv"
				},true)
		end
	end
	
	local fruitInfo = FruitTreeModel:sharedInstance():getFruitInfo()
	for k, v in pairs(fruitInfo) do
		if not self.fruits[v.id] then
			createFruit(v.id,v)
		else
			if self.fruits[v.id] == target then
				self.fruits[v.id]:refresh(v, source)
			else
				self.fruits[v.id]:refresh(v, "still")
			end
		end
	end

	print("FruitTree:refresh()incite:Tutor:",self:isNeedTutor(),".Enabled&sdk",InciteManager:isEntryEnable(EntranceType.kTree),InciteManager:getReadySdk(),InciteManager:getCount(EntranceType.kTree))
	-- RemoteDebug:uploadLogWithTag("FruitTree_AD",self:isNeedTutor(),".Enabled&sdk",InciteManager:isEntryEnable(EntranceType.kTree),InciteManager:getReadySdk(),InciteManager:getCount(EntranceType.kTree))

	if not self:isNeedTutor() and InciteManager:isEntryEnable(EntranceType.kTree) and InciteManager:getReadySdk(nil, EntranceType.kTree) then
		if not self.fruits[-1] then
			createFruit(-1,nil)
		end
	end

	if source=="update" and target==self.fruits[-1] then
		if self.fruits[-1] and not fruitInfo[-1] then
			self.fruits[-1]:removeFromParentAndCleanup(true)
			self.fruits[-1] = nil
		end
	end

	self:updateSeed5()

end

function FruitTree:addFruitRelease()
	if self.clickedFruit and not self.clickedFruit.isDisposed then
		self.clickedFruit:setClickedFruitReleaseEnabled(true)
	end
end

function FruitTree:onKeyBackClicked()
	if self.guided then return end
	self:_onFruitCanceled(self.clickedFruit)
end

function FruitTree:isBlockClick()
	return self.absoluteBlock
end

function FruitTree:blockClick(isBlock)
	self.absoluteBlock = isBlock
end

function FruitTree:getGuideInfo()
	if _G.isLocalDevelopMode then printx(0, "**********FruitTree:getGuideInfo") end
	local info = FruitTreeModel:sharedInstance():getGuideInfo()
	for k, v in pairs(info) do
		local position = self.fruits[k]:getPosition()
		local wPosition = self.ui:convertToWorldSpace(ccp(position.x, position.y))
		v.position = {x = wPosition.x, y = wPosition.y}
	end
	return info
end

function FruitTree:isNeedTutor()
	local bHasGuideFlag = UserManager.getInstance():hasGuideFlag( kGuideFlags.FruitTreePick )
	if not bHasGuideFlag then
		local index = CCUserDefault:sharedUserDefault():getIntegerForKey("fruit.tree.tutorial")
		--print("FruitTree:_onEnterHandler(evt) index",index)
		if index >= 2 then
	        UserLocalLogic:setGuideFlag( kGuideFlags.FruitTreePick )
	        return false
		end
	end
	return not bHasGuideFlag
end

function FruitTree:_onEnterHandler(evt)
	if evt == "enterTransitionFinish" then
		if self:isNeedTutor() then
			self:_enterTutor()
		else
			local bHasGuideFlag = UserManager.getInstance():hasGuideFlag( VideoFruit.GUIDE_FLAG )
			if not bHasGuideFlag then
				self:_enterADTutor()
			end
		end
	end
end

function FruitTree:_enterTutor()
	local info = FruitTreeModel:sharedInstance():getFruitInfo()[4]
	if not info or info.growCount < 5 then
		-- CCUserDefault:sharedUserDefault():setIntegerForKey("fruit.tree.tutorial", 2)
		-- CCUserDefault:sharedUserDefault():flush()
        UserLocalLogic:setGuideFlag( kGuideFlags.FruitTreePick )
		return
	end

	local hand = GameGuideAnims:handclickAnim(0.5)
	local position = self.fruits[4]:getPosition()
	hand:setAnchorPoint(ccp(0, 1))
	hand:setPosition(ccp(position.x, position.y + 20))
	self:addChild(hand)
	self.tutorHand = hand
end

function FruitTree:_clickTutor(gHandPos)
	local scene = Director:sharedDirector():getRunningScene()
	if not scene then return end
	local layer = Layer:create()
	local action = {type = "fruitButton", text = "tutorial.game.text1601",
		panType = "up", panAlign = "viewY", panPosY = 400, maskDelay = 0.3,
		maskFade = 0.4, panDelay = 0.5, touchDelay = 1.1
	}
	-- local panel = GameGuideUI:panelS(nil, action)

	local panel = GameGuideUI:dialogue(nil, { panelName="guide_dialogue_zhc_guoshu_3" }, false)
	panel:setPositionX(550)
	if gHandPos then
		panel:setPositionY(gHandPos.y + 50)
	else
		panel:setPositionY(700)
	end

	local skip = GameGuideUI:skipButton(Localization:getInstance():getText("tutorial.skip.step"), action, true)
	skip:removeAllEventListeners()
	local function onTouch()
		self:endFruitTreeGuide()
	end
	skip:ad(DisplayEvents.kTouchTap, onTouch)
	layer:addChild(skip)
	layer:addChild(panel)
	if scene.guideLayer then
		scene.guideLayer:addChild(layer)
		released = false
		self.tutorLayer = layer
	else
		layer:dispose()
	end
end

function FruitTree:_enterADTutor()
	local function onEnd()
        UserLocalLogic:setGuideFlag( VideoFruit.GUIDE_FLAG )

		if self.tutorLayer then
			self.tutorLayer:removeFromParentAndCleanup(true)
			self.tutorLayer=nil
		end
	end

	local info = self.fruits[-1]
	if not info then
		return
	end

	local scene = Director:sharedDirector():getRunningScene()
	if not scene then return end
	local layer = LayerColor:create()
	local action = {type = "fruitButton", text = "tutorial.game.text1601",
		panType = "up", panAlign = "viewY", panPosY = 400, maskDelay = 0,
		maskFade = 0.3, panDelay = 0.5, touchDelay = 1.1
	}

	local pos = self.fruits[-1]:getPosition()
	pos = ccp(pos.x-2,pos.y+15)
	pos = self.fruits[-1]:getParent():convertToWorldSpace(pos)
	local trueMask = GameGuideUI:mask(200, 0, pos,1.7)

	trueMask:setTouchEnabled(false)
	trueMask.setFadeIn(action.maskDelay, action.maskFade)
	layer:addChild(trueMask)

	local skip = GameGuideUI:skipButton(Localization:getInstance():getText("tutorial.skip.step"), action, true)
	skip:removeAllEventListeners()
	local function onTouch()
		onEnd()
	end
	skip:ad(DisplayEvents.kTouchTap, onTouch)
	layer:addChildAt(skip,999)

	local fruit = self.fruits[-1]
	fruit:setVisible(true)
	local clickedFruit = nil

	local panel = GameGuideUI:dialogue(nil, { panelName="guide_dialogue_fruittreead_1" }, true)
	panel:setPosition(ccp(180,410))
	layer:addChild(panel)

	local panelY = 410
	if __isWildScreen then
		panelY = 770
	end

	-- print("__frame_ratio",__frame_ratio,panelY)

	local function onTouchLayer()
		if not layer.step then
			layer.step=1
			panel:removeFromParentAndCleanup(true)
			trueMask:removeFromParentAndCleanup()

			clickedFruit = fruit:createClickedFruit(false, 0.4)
			fruit:refresh(nil,"guide")
			layer:addChildAt(clickedFruit,0)

			pos.y = pos.y-150

			local trueMask = GameGuideUI:mask(200, 0, pos,1.7)
			trueMask:setTouchEnabled(false)
			layer:addChild(trueMask)
			-- trueMask.setFadeIn(0.3,0.3)

			local layerSprite = trueMask.layerSprite
			layerSprite:setOpacity(0)
			layerSprite:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.3), CCFadeIn:create(0.3)))

			panel = GameGuideUI:dialogue(nil, { panelName="guide_dialogue_fruittreead_2" }, true)
			panel:setPosition(ccp(180,-3410))
			layer:addChild(panel)

			panel:runAction(CCSequence:createWithTwoActions(
	            CCDelayTime:create(0.7),
	            CCMoveTo:create(0.01,ccp(180,panelY))
            ))

		elseif layer.step==1 then
			layer.step=2
			panel:removeFromParentAndCleanup(true)

			panel = GameGuideUI:dialogue(nil, { panelName="guide_dialogue_fruittreead_3" }, true)
			panel:setPosition(ccp(180,panelY))
			layer:addChild(panel)

		else
			fruit:refresh()
			onEnd()
		end
	end
	layer:setTouchEnabled(true, 0, true)
    layer:setButtonMode(true)
    layer:addEventListener(DisplayEvents.kTouchTap, onTouchLayer)
	layer:ad(DisplayEvents.kTouchTap, onTouchLayer)


	if scene.guideLayer then
		scene.guideLayer:addChild(layer)
		self.tutorLayer = layer
	else
		layer:dispose()
	end
end


FruitTreeLogic = class()

function FruitTreeLogic:create()
	local logic = FruitTreeLogic.new()
	return logic
end

function FruitTreeLogic:updateTreeInfo(successCallback, failCallback)
	local function onSuccess(evt)
		if evt.data and evt.data.fruitInfos then
			self.info = evt.data.fruitInfos
			FruitTreeModel:sharedInstance():setFruitInfo(evt.data.fruitInfos)
			if successCallback then successCallback() end
		else
			if failCallback then failCallback(-2) end
		end
	end
	local function onFail(evt)
		if failCallback then failCallback(evt.data) end
	end
	local http = GetFruitsInfoHttp.new(true)
	http:addEventListener(Events.kComplete, onSuccess)
	http:addEventListener(Events.kError, onFail)
	http:syncLoad()
end

FruitTreeModel = class()

local instance = nil
function FruitTreeModel:sharedInstance()
	if not instance then
		instance = FruitTreeModel.new()
		instance:_init()
	end
	return instance
end

function FruitTreeModel:_init()
	self.upgradeInfo = {}
	local meta = MetaManager:getInstance().fruits_upgrade
	
	for k, v in ipairs(meta) do
		self.upgradeInfo[v.level] = {lock = v.lock, pickCount = v.pickCount,
		plus = v.plus, upgradeCondition = v.upgradeCondition}
	end
	self.pickedFruitCount = UserManager:getInstance():getDailyData().pickFruitCount
	self.fruitTreeLevel = UserManager:getInstance().userExtend.fruitTreeLevel
end

function FruitTreeModel:getFruitCount()
	if not self.upgradeInfo or not self.fruitTreeLevel or
		not self.upgradeInfo[self.fruitTreeLevel] then return 0 end
	return self.upgradeInfo[self.fruitTreeLevel].pickCount
end

function FruitTreeModel:getFruitInfo()
	self.fruitInfo = self.fruitInfo or {}
	return self.fruitInfo
end

function FruitTreeModel:resetData()
	self.fruitInfo = nil
end

function FruitTreeModel:setFruitInfo(data)
	self.fruitInfo = self.fruitInfo or {}

	if _G.isLocalDevelopMode  then printx(100 , "FruitTreeModel setFruitInfo = " , table.tostring( data ) ) end

	for k, v in ipairs(data) do
		-- if v.id >= 1 and v.id <= 5 then
			self.fruitInfo[v.id] = {id = v.id, growCount = v.growCount, level = v.level,
			updateTime = v.updateTime, type = v.type}
		-- end
	end
end

function FruitTreeModel:getGuideInfo()
	local res = {}
	for k, v in pairs(self.fruitInfo) do
		res[k] = {growCount = v.growCount, level = v.level, type = v.type}
	end
	return res
end