require "hecore.display.Scene"
require "zoo.scenes.component.fruitTreeScene.FruitTree"
require "zoo.net.OnlineGetterHttp"
require "zoo.panel.FruitTreePanel"
require "zoo.scenes.component.fruitTreeScene.FruitUpgradeSharePanel"
require "zoo.scenes.component.fruitTreeScene.FruitTreeUpgradeSharePanel"

FruitTreeScene = class(Scene)

function FruitTreeScene:create()
	local scene = FruitTreeScene.new()
	scene:initScene()
	scene.instanceName = "FruitTreeScene"
	return scene
end

function FruitTreeScene:dispose()
	local scene = HomeScene:sharedInstance()
	if scene then scene:checkDataChange() end
	if scene and scene.coinButton and not scene.coinButton.isDisposed then scene.coinButton:updateView() end
	if scene and scene.energyButton and not scene.energyButton.isDisposed then scene.energyButton:updateView() end
	self.tree:endFruitTreeGuide()
	self:dispatchEvent(Event.new(kFruitTreeEvents.kExit))
--	PopoutQueue:sharedInstance():popAgain()

	Scene.dispose(self)
	
end

function FruitTreeScene:onInit()
	-- background & tree
	local wSize = Director:sharedDirector():getWinSize()
	local vSize = Director:sharedDirector():getVisibleSize()
	local vOrigin = Director:sharedDirector():getVisibleOrigin()

	local function getUid()
		local uid = '12345'
		if UserManager and UserManager:getInstance().user then
			uid = UserManager:getInstance().user.uid or '12345'
		end
		uid = tostring(uid)
		return uid
	end
	
	local uid = getUid()
	CCUserDefault:sharedUserDefault():setIntegerForKey("FruitTreeButton_IsOpened"..uid, 1)
	CCUserDefault:sharedUserDefault():flush()

	if _G.__use_small_res then
		self.bg = Sprite:create("materials/fruitTree@2x.png")
		self.treeBg = Sprite:create("materials/fruitTree2@2x.png")
	else
		self.bg = Sprite:create("materials/fruitTree.png")
		self.treeBg = Sprite:create("materials/fruitTree2.png")		
	end

	self.tree = FruitTree:create(FruitTreeSceneLogic:sharedInstance():getInfo())
	self.bg:setAnchorPoint(ccp(0.5, 0.1))
	local bgSize = self.bg:getContentSize()
	-- 1280最初的设计分辨率，1480是直接向上延长了200像素，默认使用原高度
	local scale = math.max(vSize.height / 1280, vSize.width / bgSize.width)
	scale = math.min(scale, 1)
	self.bg:setScale(scale)
	local posY = bgSize.height * 0.1  -- height * AnchorPoint.y
	self.bg:setPosition(ccp(wSize.width / 2, vOrigin.y + posY * scale - _G.__EDGE_INSETS.bottom))
	self:addChild(self.bg)
	
	self.treeBg:setPositionX(30 + self.treeBg:getContentSize().width * 0.5)
	self.treeBg:setPositionY(30 + _G.__EDGE_INSETS.bottom)
	self.treeBg:setAnchorPoint(ccp(0.5,0))
	self.bg:addChild(self.treeBg)

	self.tree:setPositionX(self.treeBg:getContentSize().width * 0.5)
	self.tree:setPositionY(posY - 30)
	self.treeBg:addChild(self.tree)

	-- 原来的位置
	-- self.tree2 = FruitTree:create(FruitTreeSceneLogic:sharedInstance():getInfo())
	-- self.tree2:setScale(vSize.height / wSize.height)
	-- self.tree2:setPosition(ccp(wSize.width / 2, vOrigin.y + 127 * vSize.height / wSize.height))
	-- self:addChild(self.tree2)

	-- close button
	local builder = InterfaceBuilder:create(PanelConfigFiles.common_ui)
	local closeBtn = builder:buildGroup("ui_buttons/ui_button_close_cloud")
	closeBtn:setPosition(ccp(vOrigin.x + vSize.width - 50, vOrigin.y + vSize.height - 50 + _G.__EDGE_INSETS.top / 2))
	self:addChild(closeBtn)


	-- for game guide
	self.guideLayer = Layer:create()
	self:addChild(self.guideLayer)

	local function onFruitClicked(evt)
		if self.titlePanel and not self.titlePanel.isDisposed then self.titlePanel:disableClick(true) end
		if self.bottomPanel and not self.bottomPanel.isDisposed then self.bottomPanel:disableClick(true) end
		closeBtn:setTouchEnabled(false)
		self.fruitClicked = true
	end
	self.tree:addEventListener(kFruitTreeEvents.kFruitClicked, onFruitClicked)
	local function onFruitReleased()
		if self.titlePanel and not self.titlePanel.isDisposed then self.titlePanel:disableClick(false) end
		if self.bottomPanel and not self.bottomPanel.isDisposed then self.bottomPanel:disableClick(false) end
		closeBtn:setTouchEnabled(true)
		self.fruitClicked = nil
	end
	self.tree:addEventListener(kFruitTreeEvents.kFruitReleased, onFruitReleased)
	local function onFruitUpdate()
		if self.upgradePanel and not self.upgradePanel.isDisposed then self.upgradePanel:refresh() end
		if self.bottomPanel and not self.bottomPanel.isDisposed then self.bottomPanel:refresh() end
	end
	self.tree:addEventListener(kFruitTreeEvents.kUpdate, onFruitUpdate)
	self.tree:addEventListener(kFruitTreeEvents.kUpdateData, onFruitUpdate)

	local function onExit()
		if not self.isDisposed then Director:sharedDirector():popScene() end
	end
	self.tree:addEventListener(kFruitTreeEvents.kExit, onExit)


	local function createRulePanel()
		if self.rulePanel or not self.titlePanel then return end
		self.rulePanel = FruitTreeRulePanel:create(self.titlePanel:getBottomY())
		if self.rulePanel then
			local function onClose()
				self.titlePanel:onRulePanelRemove()
				self.rulePanel:removeFromParentAndCleanup(true)
				closeBtn:setTouchEnabled(true)
				self.rulePanel = nil
				if self.bottomPanel and not self.bottomPanel.isDisposed then self.bottomPanel:disableClick(false) end
				self.tree:blockClick(false)
			end
			closeBtn:setTouchEnabled(false)
			self.rulePanel:addEventListener(kPanelEvents.kClose, onClose)
			local zOrder = self.titlePanel:getZOrder()
			local index = self:getChildIndex(self.titlePanel)
			self:addChildAt(self.rulePanel, index)
			self.rulePanel:playSlideInAnim()
			self.tree:endFruitTreeGuide()
		end
	end

	local function createTitlePanel()
		if self.titlePanel then return end
		self.titlePanel = FruitTreeTitlePanel:create()
		if self.titlePanel then
			local function onClose() Director:sharedDirector():popScene() end
			local function onButton()
				if not self.rulePanel then
					if self.bottomPanel and not self.bottomPanel.isDisposed then self.bottomPanel:disableClick(true) end
					self.tree:blockClick(true)
					createRulePanel()
				else self.rulePanel:remove() end
			end
			self.titlePanel:addEventListener(kPanelEvents.kClose, onClose)
			self.titlePanel:addEventListener(kPanelEvents.kButton, onButton)
			local index = self:getChildIndex(self.guideLayer)
			self:addChildAt(self.titlePanel, index)

			local touchLayer = Layer:create()
			touchLayer:setTouchEnabled(true)
			touchLayer.hitTestPoint = function (_self, worldPosition,useGroupTest )
				if self.titlePanel and self.rulePanel then
					return not self.titlePanel:hitTestPoint(worldPosition,useGroupTest) and 
						not self.rulePanel:hitTestPoint(worldPosition,useGroupTest) 
				else
					return false
				end
			end
			touchLayer:addEventListener(DisplayEvents.kTouchTap,onButton)
			self:addChild(touchLayer)
		end
	end

	local function createUpgradePanel()
		if self.upgradePanel then return end
		local level = FruitTreePanelModel:sharedInstance():getTreeLevel()
		local condition, fulfill, value, nextValue = FruitTreePanelModel:sharedInstance():getIsFinishUpgradeCondition(level + 1)
		if condition == 4 then
			--这种情况我们用老的升级面板
			self.upgradePanel = FruitTreeUpgradePanel:create()
		else
			self.upgradePanel = FruitTreeUpgradePanel_New:create()
		end
		if self.upgradePanel then
			local function onClose()
				self.upgradePanel:removeFromParentAndCleanup(true)
				self.upgradePanel = nil
				if self.titlePanel and not self.titlePanel.isDisposed then self.titlePanel:disableClick(false, true) end
				self.tree:blockClick(false)
			end
			local function onButton()
				self.upgradePanel:removeFromParentAndCleanup(true)
				self.upgradePanel = nil
				if self.bottomPanel then self.bottomPanel:refresh() end

				local level = FruitTreePanelModel:sharedInstance():getTreeLevel()
				FruitTreeUpgradeSharePanel:create(self.treeBg,level):popout()
				if self.titlePanel and not self.titlePanel.isDisposed then self.titlePanel:disableClick(false, true) end
				self.tree:blockClick(false)
				self.tree:refresh()
				if _G.isLocalDevelopMode then printx(100, "**********FruitTreeScene:onButton 1111") end

			end
			local function onPlay( ... )
				if closeBtn:isTouchEnabled() then
					Director:sharedDirector():popScene()

					local homeScene = HomeScene:sharedInstance()
					homeScene:runAction(CCCallFunc:create(function( ... )
						homeScene.worldScene:startLevel(UserManager:getInstance().user:getTopLevelId())
					end))
				end
			end
			self.upgradePanel:addEventListener(kPanelEvents.kButton, onButton)
			self.upgradePanel:addEventListener(kPanelEvents.kClose, onClose)



			self.upgradePanel:addEventListener("gotoPlayTopLevel",onPlay)
			local index = self:getChildIndex(self.guideLayer)
			self:addChildAt(self.upgradePanel, index)
			self.tree:endFruitTreeGuide()
		end
	end

	local function createBottomPanel()
		if self.bottomPanel then return end
		self.bottomPanel = FruitTreeBottomPanel:create()
		if self.bottomPanel then
			local function onButton()
				self.tree:blockClick(true)
				if self.titlePanel and not self.titlePanel.isDisposed then self.titlePanel:disableClick(true, true) end
				createUpgradePanel()
			end
			local function onShowGuide( ... )
				if self.titlePanel and self.bottomPanel then
					if self.rootLayer:getChildIndex(self.titlePanel) > self.rootLayer:getChildIndex(self.bottomPanel) then
						self.rootLayer:swapChildren(self.titlePanel,self.bottomPanel)
					end 
				end
			end
			local function onHideGuide( ... )
				if self.titlePanel and self.bottomPanel then
					if self.rootLayer:getChildIndex(self.titlePanel) < self.rootLayer:getChildIndex(self.bottomPanel) then
						self.rootLayer:swapChildren(self.titlePanel,self.bottomPanel)
					end 
				end
			end
			self.bottomPanel:addEventListener(kPanelEvents.kButton, onButton)	
			self.bottomPanel:addEventListener("hideGuide",onHideGuide)
			local index = self:getChildIndex(self.guideLayer)
			self:addChildAt(self.bottomPanel, index)
			self:runAction(CCCallFunc:create(function( ... )
				if self.bottomPanel.guide then
					onShowGuide()
				else
					self.bottomPanel:addEventListener("showGuide",onShowGuide)
				end
			end))
		end
	end

	createBottomPanel()
	createTitlePanel()

	local function onClose() Director:sharedDirector():popScene() end
	closeBtn:setTouchEnabled(true)
	closeBtn:setButtonMode(true)
	closeBtn:addEventListener(DisplayEvents.kTouchTap, onClose)

	local function onEnterHandler(event)
		self:onEnterHandler(event)
	end
	self:registerScriptHandler(onEnterHandler)


	-- 有六级果实，弹炫耀
	local newLevel6Ids = {}
	for k,v in pairs(FruitTreeSceneLogic:sharedInstance():getInfo()) do
		if _G.isLocalDevelopMode then printx(0, v.level) end
		if v.level == 6 and not Cookie:getInstance():read(CookieKey.kHasFruitLevel6ShowOff .. v.id) then
			table.insert(newLevel6Ids,v.id)
		end
	end
	if #newLevel6Ids > 0 then
		self:runAction(CCCallFunc:create(function( ... )
			for k,v in pairs(newLevel6Ids) do
				Cookie:getInstance():write(CookieKey.kHasFruitLevel6ShowOff .. v,true)
			end

			FruitUpgradeSharePanel:create(self.tree,newLevel6Ids):popout()
		end))
	end

	-- self:runAction(CCCallFunc:create(function( ... )
	-- 	FruitUpgradeSharePanel:create(self.tree,{2}):popout()
	-- end))

	-- self:runAction(CCCallFunc:create(function( ... )
	-- 	FruitTreeUpgradeSharePanel:create(self.treeBg,6):popout()
	-- end))
end

function FruitTreeScene:onEnterHandler(event)
	if _G.isLocalDevelopMode then printx(0, "FruitTreeScene:onEnterHandler", event) end
	if event == "enter" then
		-- activity
		local list = ActivityUtil:getActivitys()
		for k, v in ipairs(list) do
			local config = require("activity/"..tostring(v.source))
			if type(config.fruitTreeScene) == "boolean" and config.fruitTreeScene then
				local activity = ActivityData.new(v)
				activity:start(false)
			end
		end
	end
end

function FruitTreeScene:shouldNewBtnDisabled()
	return self.fruitClicked or self.tree:isBlockClick()
end

function FruitTreeScene:refresh()
	if self.bottomPanel then self.bottomPanel:refresh() end
	if self.upgradePanel then self.upgradePanel:refresh() end
end

function FruitTreeScene:onKeyBackClicked()
	if self.rulePanel then
		self.rulePanel:onKeyBackClicked()
	elseif self.upgradePanel then
		self.upgradePanel:onKeyBackClicked()
	elseif self.fruitClicked then self.tree:onKeyBackClicked()
	else Director:sharedDirector():popScene() end
end

FruitTreeSceneLogic = {}
local instance = nil
function FruitTreeSceneLogic:sharedInstance()
	if not instance then instance = FruitTreeSceneLogic end
	return instance
end

function FruitTreeSceneLogic:updateInfo(successCallback, failCallback)
	local function onSuccess(evt)
		if evt.data and evt.data.fruitInfos then
			self.info = evt.data.fruitInfos
			self:onFruitDataUpdate()
			if successCallback then successCallback() end
		else
			if failCallback then failCallback(-2) end
		end
	end
	local function onFail(evt)
		if failCallback then failCallback(evt.data) end
	end
	if self:_updateNeeded() then
		local http = GetFruitsInfoHttp.new(true)
		http:addEventListener(Events.kComplete, onSuccess)
		http:addEventListener(Events.kError, onFail)
		http:load()
	end
end

function FruitTreeSceneLogic:updateFruit(data,id)
	if not data and not id then return end

	self.info = self.info or {}
	for i,v in pairs(self.info) do
		if v.id == id then
			self.info[i]=data
			break
		end
	end
	self:onFruitDataUpdate()
end

function FruitTreeSceneLogic:onFruitDataUpdate()
	FruitTreeModel:sharedInstance():resetData()
	FruitTreeModel:sharedInstance():setFruitInfo(self.info)
	
	local kFruitType_kGold = 2
	local nextGold = nil
	for i,v in pairs(self.info) do
		if v.type == kFruitType_kGold then
			if not nextGold then
				nextGold = v
			elseif nextGold.updateTime>v.updateTime then
				nextGold = v
			end
		end
	end
	
	local timeToNext = nil
	if nextGold and nextGold.updateTime then
		--果子最大能升6级，检查到6的倒计时
		timeToNext = math.ceil(nextGold.updateTime*0.001)+(6-nextGold.level)*30*60
	end
	LocalNotificationManager:getInstance():checkGoldFruit(timeToNext)
end

function FruitTreeSceneLogic:getInfo()
	return self.info
end

function FruitTreeSceneLogic:_updateNeeded()
	return true
end