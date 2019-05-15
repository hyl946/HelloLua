-- require 'zoo.my.utils'
local PriorityQueue = class()

function PriorityQueue:ctor()
	self.datas = {}
end

function PriorityQueue:push(item)
	table.insert(self.datas, item)
	table.sort(self.datas, function(a, b)
		return tonumber(a:getPriority()) > tonumber(b:getPriority())
	end)
end

function PriorityQueue:popData( data )
	table.removeValue(self.datas, data)
	return data
end

function PriorityQueue:pop()
	local item = self.datas[1]
	table.remove(self.datas, 1)
	return item
end

function PriorityQueue:top()
	local item = self.datas[1]
	return item
end

function PriorityQueue:size()
	return #(self.datas)
end

function PriorityQueue:clear()
	-- self.datas = {}
	-- buyfix 不清除支付tip (protected)
	self.datas = table.filter(self.datas, function(panel) return panel.protected == true end)
end

BroadcastManager = class()

local instance = nil

function BroadcastManager:getInstance()
	if not instance then
		instance = BroadcastManager.new()
	end
	return instance
end

function BroadcastManager:ctor()
	--如果一个场景里同时有多个消息需要弹出，则按优先级放在这
	self.queue = PriorityQueue.new()
	--当前正在显示的消息，它此时已不在队列里
	self.curMsgPanel = nil  

	self.configs = {}
	self.configsDirty = false

	self.popoutCache = {} -- 临时缓存，记录一个消息弹出过没有，如果弹出过，则不再弹，除非home键了

	self.reShowIDs = self:readReShowIDs()
	self.reShowIDsDirty = true

	self.popPanelCounter = 0

	self.firstEnterHomeScene = true

	self.actived = false

	self.timerId = nil

	self.isNextFrameWillPop = false

	GlobalEventDispatcher:getInstance():addEventListener(kGlobalEvents.kEnterBackground, function()
		self:unActive()
	end)

	self.reshowPanel = nil

	Notify:register("AchiEventReachedNewAchi", self.showAchiBroadcast, self)
end

function BroadcastManager:cancelTimeOut()
	if self.timerId then
		cancelTimeOut(self.timerId)
		self.timerId = nil

		if self.isNextFrameWillPop then
			self.curMsgPanel = nil
			self.isNextFrameWillPop = false
		end
	end
end

function BroadcastManager:setTimeOut(func, time)
	self:cancelTimeOut()

	local function __onTime()
		func()
		self.timerId = nil
	end
	self.timerId = setTimeOut(__onTime, time) 
end

function BroadcastManager:onHomeKey()
	if _G.isLocalDevelopMode then printx(0, 'BroadcastManager onHomeKey') end
	if HomeScene:hasInited() then
		self.firstEnterHomeScene = true
		self:reset()
		self:clearConfig()
		self:clearPopoutCache()
		self:initFromConfig(function()
			if _G.isLocalDevelopMode then printx(0, 'BroadcastManager setTimeOut onEnterScene') end
			self:setTimeOut(function ()
				if HomeScene:sharedInstance().broadcastButton then
					HomeScene:sharedInstance().broadcastButton:update(self:getReShowIDs())
				end
				if self.curScene then
					self:onEnterScene(self.curScene, false)
				end
			end, 0)
		end)
	end
end

function BroadcastManager:active(isShouldPopout)
	if self.actived ~= true then
		self.actived = true
		if isShouldPopout then
			self:popoutNext()
		end
	end 
end

function BroadcastManager:unActive()
	self.actived = false
end

function BroadcastManager:clearConfig()
	self.configs = {}
	self.configsDirty = false
end

function BroadcastManager:clearPopoutCache()
	self.popoutCache = {}
end

function BroadcastManager:isHadPopout(msgID)
	return self.popoutCache[msgID] == true
end

function BroadcastManager:hadPopout(msgID)
	self.popoutCache[msgID] = true
end

function BroadcastManager:reset()
	self:cancelTimeOut()
	self.queue:clear()
	if self.curMsgPanel then
		self.curMsgPanel:close()
		self.curMsgPanel = nil
	end

	if self.reshowPanel then
		if not self.reshowPanel.isDisposed then
			self.reshowPanel:close()
			self.reshowPanel = nil
		end
	end
end


-- 当进入一个Scene时，此函数被调用，尝试去弹出一些消息
function BroadcastManager:onEnterScene(scene, isClearPanelPopCount)
	if _G.isLocalDevelopMode then printx(0, 'BroadcastManager onEnterScene') end
	if self:isNeedProcess(scene) then
		self:reset()

		self:listenForGuide(scene)

		if self.curScene and self:isNeedProcess(self.curScene) then
			self:clearPopoutCache()
		end

		local sceneType = self:getSceneType(scene)
		self:prepare(sceneType)

		self:checkFuncMessage(sceneType)

		if sceneType == 1 then -- 1代表HomeScene
			if self.firstEnterHomeScene then
				self.firstEnterHomeScene = false

				if self.actived or (self.queue:top() and self.queue:top():isCareHomeQueue()==false) then
					self:setTimeOut(function() self:popoutNext() end, 0.3)
				end
			else
				HomeScene:sharedInstance().broadcastButton:playAnimation()
				self:popoutNext()
			end
		else
			if _G.isLocalDevelopMode then printx(0, 'BroadcastManager onEnterScene popoutNext') end
			self:popoutNext()
		end

		self.curScene = scene
	end

	if isClearPanelPopCount ~= false then
		self.popPanelCounter = 0
	end
end

function BroadcastManager:listenForGuide(scene)
	if scene.guideLayer then
		local guideLayer = scene.guideLayer
		if not guideLayer.__addChild then
			guideLayer.__addChild = guideLayer.addChild
			scene.guideLayer.addChild = function(...)
				guideLayer.__addChild(...)
				self:reset()
			end
		end
	end
end

function BroadcastManager:onEnterIgnoreScene(scene)
	if not self:isNeedProcess(scene) then
		self.curScene = scene
	end
end

function BroadcastManager:prepare(sceneType)
	if self.configsDirty then
		self.configs = self:filterConfig(self.configs)
		self.configsDirty = false
	end

	for k, v in pairs(self.configs) do
		if type(v.scenes) == 'string' then
			if v.scenes == 'default' or 
				table.exist(v.scenes:split(','), tostring(sceneType)) then

				if self:isNeedPopout(v.id) then

					require 'zoo.panel.broadcast.CommonMessagePanel'

					local panel = CommonMessagePanel:createWithConfig(v, function()
						self:onCurClose()
						HomeScene:sharedInstance().broadcastButton:playAnimation()
					end)

					self.queue:push(panel)
				end

			end
		end
	end
end

function BroadcastManager:popoutNext()
	if self.curMsgPanel then
		return
	end

	if self.queue:top() and self.queue:top():isCarePanel() then
		if self:isHadOtherPanel() then
			self:reset()
			return
		end
	end

	if self.queue:top() and self.queue:top():isCareGuide() then
		if self:isHadGuide() then
			self:reset()
			return
		end
	end

	local curScene = Director:sharedDirector():getRunningScene()
	local isHomeScene = curScene == HomeScene:sharedInstance()

	if isHomeScene then
		if not self.actived then
			if self.queue:top() and self.queue:top():isCareHomeQueue() then
				self:reset()
				return
			end
		end
	end

	if self.queue:size() > 0 then
		local panel = self.queue:top()
		self:setTimeOut(function ()
			local curScene = Director:sharedDirector():getRunningScene()
			if curScene then
				self.isNextFrameWillPop = false
				self.queue:popData(panel)
				panel:popout()
				if panel:getID() then
					self:hadPopout(panel:getID())
					self:incPopoutCount(panel:getID())
					if self:isNeedReShow(panel:getID()) then
						self:saveForReShow(panel:getID())
					end
				end
			else
				self.curMsgPanel = nil
				self.isNextFrameWillPop = false
			end
		end, 0)
		self.curMsgPanel = panel
		self.isNextFrameWillPop = true
	end
end

function BroadcastManager:forceShow(msgID) --强行在当前场景显示一条消息, 不计算轮播次数, 不考虑任何限制条件
	if self.configsDirty then
		self.configs = self:filterConfig(self.configs)
		self.configsDirty = false
	end

	local config = self.configs[msgID]
	if config then
		require 'zoo.panel.broadcast.CommonMessagePanel'
		local panel = CommonMessagePanel:createWithConfig(config, function()
			self.reshowPanel = nil
		end)
		self.reshowPanel = panel
		panel:popout()
	end
end

function BroadcastManager:reShowOne()
	if #(self:getReShowIDs()) > 0 then
		local msgID = self.reShowIDs[1]
		table.remove(self.reShowIDs, 1)
		self:writeReShowIDs(self.reShowIDs)

		self:forceShow(msgID)
		require 'zoo.panel.broadcast.BroadcastButton'
		HomeScene:sharedInstance().broadcastButton:update(self.reShowIDs)
	end
end

function BroadcastManager:isNeedReShow(msgID)
	if self.configsDirty then
		self.configs = self:filterConfig(self.configs)
		self.configsDirty = false
	end
	return self.configs[msgID] and tostring(self.configs[msgID].type) == '1' -- 1代表警示类消息
end

function BroadcastManager:saveForReShow(msgID)
	if self.configsDirty then
		self.configs = self:filterConfig(self.configs)
		self.configsDirty = false
	end

	if not table.exist(self.reShowIDs, msgID) then
		table.insert(self.reShowIDs, msgID)
		table.sort(self.reShowIDs, function(a, b)
			local ca = self.configs[a]
			local cb = self.configs[b]
			return ca ~= nil and cb ~=nil and tonumber(ca.priority) > tonumber(cb.priority)
		end)
		self:writeReShowIDs(self.reShowIDs)

		require 'zoo.panel.broadcast.BroadcastButton'
		HomeScene:sharedInstance().broadcastButton:update(self.reShowIDs)
	end
end

local reShowIDsKey = 'reShowIDsKey'

function BroadcastManager:writeReShowIDs(ids)
	CCUserDefault:sharedUserDefault():setStringForKey(
		reShowIDsKey..tostring(UserManager.getInstance().uid), 
		table.serialize(ids)
	)
end


function BroadcastManager:onAreaTaskRewarded( taskInfo, rewards )
	require 'zoo.panel.broadcast.AreaTaskBroadcastPanel'
	local panel = AreaTaskBroadcastPanel:create(
		taskInfo,
		rewards, 
		function()
			self:onCurClose()
		end
	)
	if _G.isLocalDevelopMode then printx(0, 'BroadcastManager setTimeOut onBuy') end
	panel.protected = true
	self:add(panel)
end

function BroadcastManager:readReShowIDs()
	local jsonStr = CCUserDefault:sharedUserDefault():getStringForKey(
		reShowIDsKey..tostring(UserManager.getInstance().uid)
	) 

	if jsonStr then
		return table.deserialize(jsonStr) or {}
	else
		return {}
	end
end

function BroadcastManager:getReShowIDs()
	if self.configsDirty then
		self.configs = self:filterConfig(self.configs)
		self.configsDirty = false
	end

	if self.reShowIDsDirty then
		self.reShowIDs = table.filter(self.reShowIDs, function(v)
			return self.configs[tostring(v)] ~= nil
		end)
		self.reShowIDsDirty = false
	end
	return self.reShowIDs
end

function BroadcastManager:isNeedPopout(msgID)
	if self.configsDirty then
		self.configs = self:filterConfig(self.configs)
		self.configsDirty = false
	end

	local popoutLimit = self.configs[msgID].times
	if popoutLimit ~= 'default' and tonumber(popoutLimit) <= self:getPopoutCount(msgID) then
		return false
	end
	return not self:isHadPopout(msgID)
end


local popoutCountKey = 'BroadcastPopoutCount_'

function BroadcastManager:getPopoutCount(msgID)
	return CCUserDefault:sharedUserDefault():getIntegerForKey(
		tostring(UserManager.getInstance().uid)..popoutCountKey..msgID
	) or 0
end

function BroadcastManager:incPopoutCount(msgID)
	local count = self:getPopoutCount(msgID)
	CCUserDefault:sharedUserDefault():setIntegerForKey(
		tostring(UserManager.getInstance().uid)..popoutCountKey..msgID, 
		count + 1
	)
end

function BroadcastManager:isNeedProcess(scene)
	return self:getSceneType(scene) ~= nil
end

function BroadcastManager:getSceneType(scene)
	local sceneConfig = require 'zoo.panel.broadcast.config'
	local sceneType = sceneConfig:getSceneType(scene)
	return sceneType
end


function BroadcastManager:pullConfig(callback)
	local function onCallback(response)
		if response.httpCode ~= 200 then 
			callback(nil)
		else
			callback(response.body)
		end
	end

	local url = NetworkConfig.maintenanceURL
	local uid = UserManager.getInstance().uid

	local params = string.format("?name=broadcast_message&_v=%s", _G.bundleVersion)
	url = url .. params
	if _G.isLocalDevelopMode then printx(0, url) end

	local request = HttpRequest:createGet(url)

	local timeout = 3
  	local connection_timeout = 2

  	if __WP8 then 
    	timeout = 30
    	connection_timeout = 5
  	end

    request:setConnectionTimeoutMs(connection_timeout * 1000)
    request:setTimeoutMs(timeout * 1000)

    if not PrepackageUtil:isPreNoNetWork() then 
   		HttpClient:getInstance():sendRequest(onCallback, request)
   	end
end

function BroadcastManager:initFromConfig(callback)
	if _G.isLocalDevelopMode then printx(0, 'BroadcastManager initFromConfig') end
	self:pullConfig(
		function(config)
			self.configs = config or '<?xml version="1.0" encoding="UTF-8"?><broadcast_message></broadcast_message>'
			self.configsDirty = true
			self.reShowIDsDirty = true
			if callback then
				callback()
			end
		end
	)
end

function BroadcastManager:filterConfig(config)
	local xmlContent = xml.eval(config)
	local broadcast = xml.find(xmlContent, "broadcast_message") or {}
	broadcast = table.filter(broadcast, function(v) return type(v) == type({}) end)
	broadcast = table.filter(broadcast, function(v)

		-- if _G.isLocalDevelopMode then printx(0, 'broadcastConfig'print('broadcastConfig', table.tostring(broadcast)) end


		local requiredKey = {
			'version', 'platform', 'deadline', 'enable', 'minLevel', 'maxLevel',
			'type', 'scenes', 'times', 'text', 'priority'
		}

		for _, key in pairs(requiredKey) do
			if type(v[key]) ~= 'string' then
				if _G.isLocalDevelopMode then printx(0, 'BroadcastManager:filterConfig', key, 'is not string') end
				return false
			end
		end

		if v.enable ~= 'true' then
			if _G.isLocalDevelopMode then printx(0, 'BroadcastManager:filterConfig', 'enable false') end
			return false
		end

		if v.version ~= 'default' and (not table.exist(v.version:split(","), _G.bundleVersion)) then
			if _G.isLocalDevelopMode then printx(0, 'BroadcastManager:filterConfig', 'version error') end
			return false
		end

		local platformName = StartupConfig:getInstance():getPlatformName()

		if v.platform ~= 'default' and (not table.exist(v.platform:split(","), platformName)) then
			if _G.isLocalDevelopMode then printx(0, 'BroadcastManager:filterConfig', 'platform error') end
			return false
		end

		local userTopLevel = UserManager:getInstance().user:getTopLevelId()
		if _G.isLocalDevelopMode then printx(0, userTopLevel) end
		if v.minLevel ~= 'default' and (tonumber(v.minLevel) > userTopLevel) then
			if _G.isLocalDevelopMode then printx(0, 'BroadcastManager:filterConfig', 'minLevel error') end
			return false
		end

		if v.maxLevel ~= 'default' and (tonumber(v.maxLevel) < userTopLevel) then
			if _G.isLocalDevelopMode then printx(0, 'BroadcastManager:filterConfig', 'maxLevel error') end
			return false
		end

		local dlYear, dlMonth, dlDay, dlHour, dlMin, dlSec = v.deadline:match('(%d+).(%d+).(%d+) (%d+):(%d+):(%d+)')
		if dlYear == nil or dlMonth == nil or dlDay == nil then
			if _G.isLocalDevelopMode then printx(0, 'BroadcastManager:filterConfig', 'year month day') end
			return false
		end
		if dlHour == nil or dlMin == nil or dlSec == nil then
			if _G.isLocalDevelopMode then printx(0, 'BroadcastManager:filterConfig', 'hour min sec') end
			return false
		end

		local nowTime = Localhost:timeInSec()
		local deadline = os.time({
			year = dlYear,
			month = dlMonth,
			day = dlDay,
			hour = dlHour,
			min = dlMin,
			sec = dlSec
		})
		
		if nowTime > deadline then
			if _G.isLocalDevelopMode then printx(0, 'BroadcastManager:filterConfig', 'deadine') end
			return false
		end

		return true
	end)

	local broadcastConfig = {}
	for k, v in pairs(broadcast) do
		if v.id then
			v.platform = nil
			v.version = nil
			v.deadline = nil
			v[0] = nil
			broadcastConfig[v.id] = v
		end
	end

	broadcast = broadcastConfig

	-- if _G.isLocalDevelopMode then printx(0, 'broadcastConfig'print('broadcastConfig', table.tostring(broadcast)) end
	return broadcast
end

-- 中途额外添加一个消息进队列
function BroadcastManager:add(panel)
	self.queue:push(panel)
	self:popoutNext()
end

function BroadcastManager:onBuy(data)
	require 'zoo.panel.broadcast.BuyTipPanel'
	local panel = BuyTipPanel:create(
		GoodsIdInfoObject:create(tonumber(data.goodsId), tonumber(data.goodsType)), 
		data.props, 
		function()
			self:onCurClose()
		end
	)
	if _G.isLocalDevelopMode then printx(0, 'BroadcastManager setTimeOut onBuy') end

	panel.protected = true -- reset的时候，不清除有这个标志的panel
	self:add(panel)
end

function BroadcastManager:checkFuncMessage(sceneType)--mark lhl
	require 'zoo.panel.broadcast.TimeLimitPropPanel'
	if TimeLimitPropPanel:isNeedShow(sceneType) then
		local panel = TimeLimitPropPanel:create(function()
			self:onCurClose()
		end)
		self:add(panel)
	end

	require "zoo.panel.WechatFriendPanel"
	local WechatFriendLogicID = -1000
	if not self:isHadPopout(WechatFriendLogicID) and sceneType == 1 then
		-- WechatFriendLogic:sharedInstance():checkNewResult()
		self:hadPopout(WechatFriendLogicID)
	end

	require "zoo.panel.broadcast.GetShareFreeGiftPanel"
	if GetShareFreeGiftPanel:isNeedShow() then
		self:add(GetShareFreeGiftPanel:create(function()
			self:onCurClose()
		end))
	end

	require "zoo.panel.broadcast.AchiBroadcastPanel"
	if sceneType == 1 then
		if AchiBroadcastPanel:isNeedShow() then
			self:add(AchiBroadcastPanel:create(function()
				self:onCurClose()
			end))
		end
	end
end

function BroadcastManager:showAchiBroadcast( achiIds )
	require "zoo.panel.broadcast.AchiBroadcastPanel"
	AchiBroadcastPanel:showBroadcast(achiIds[1])
	if self:getSceneType(Director:sharedDirector():getRunningSceneLua()) == 1 then
		if AchiBroadcastPanel:isNeedShow() then
			self:add(AchiBroadcastPanel:create(function()
				self:onCurClose()
			end))
		end
	end
end

function BroadcastManager:onCurClose()
	self.curMsgPanel = nil
	self:setTimeOut(function() self:popoutNext() end, 0)
end

function BroadcastManager:isIgnorePanels(panel)
	require 'zoo.panel.MarketPanel'
	local ignorePanels = {
		MarketPanel
	}
	return table.exist(ignorePanels, panel.class)
end

function BroadcastManager:onPopup(panel)
	if not self:isIgnorePanels(panel) then
		self.popPanelCounter = self.popPanelCounter + 1
	end
end

function BroadcastManager:onPopdown(panel)
	if not self:isIgnorePanels(panel) then
		self.popPanelCounter = self.popPanelCounter - 1
	end
end

function BroadcastManager:isHadOtherPanel() --是否当前有其他面板弹出
	-- return self.popPanelCounter > 0
	return PopoutManager:haveWindowOnScreenWithoutCommonTip()
end

function BroadcastManager:isHadGuide() --是否当前有引导弹出
	local curScene = Director:sharedDirector():getRunningScene()

	if curScene then
		local guideLayer = curScene.guideLayer
		if guideLayer and (not guideLayer.isDisposed) then
			local children = guideLayer:getChildrenList() or {}
			return table.size(children) > 0
		end
	end
end

function BroadcastManager:onBackKey()
	if self.curMsgPanel then
		self.curMsgPanel:onAutoClose()
	end
end

function BroadcastManager:interrupt()
	if self.curMsgPanel then
		if self.curMsgPanel:isCareGuide() or self.curMsgPanel:isCarePanel() or self.curMsgPanel:isCareHomeQueue() then
			self:reset()
		end
	end
end

function BroadcastManager:showTip(text)
	require 'zoo.panel.broadcast.CommonMessagePanel'
	local panel = CommonMessagePanel:createWithConfig(
		{
			id = 9999,
			type = 2,
			text = text,
			priority = 1001
		}, 
		function()
			self:onCurClose()
		end
	)

	panel.popout = function ()
		local curScene = Director:sharedDirector():getRunningScene()
		if not curScene then return end

	    local visibleSize = Director:sharedDirector():getVisibleSize()
	    local visibleOrigin = Director:sharedDirector():getVisibleOrigin()
	    local panelSize = panel:getGroupBounds().size
	    panel:setPositionY(panelSize.height + visibleOrigin.y + visibleSize.height)
	    panel:setPositionX((visibleSize.width - panelSize.width) /2 + visibleOrigin.x)

		curScene:addChild(panel , SceneLayerShowKey.TOP_LAYER)

	    -- PopoutQueue:sharedInstance():push(panel, false, true)

	    local arr = CCArray:create()
	    arr:addObject(CCMoveBy:create(0.2, ccp(0, - 32 - panelSize.height)))
	    arr:addObject(CCDelayTime:create(5))
	    arr:addObject(CCMoveBy:create(0.2, ccp(0,  32 + panelSize.height)))
	    arr:addObject(CCCallFunc:create(function()
	        panel:close()
	    end))
	    panel:runAction(CCSequence:create(arr))
	end

	function panel:isCarePanel()
		return false
	end
	function panel:isCareGuide() 
		return false
	end
	function panel:isCareHomeQueue()
		return false
	end

	panel.protected = true
	self:add(panel)
end

function BroadcastManager:showTestTip(text)
	require 'zoo.panel.broadcast.CommonMessagePanel'
	local panel = CommonMessagePanel:createWithConfig(
		{
			id = 9999,
			type = 1,
			text = text,
			priority = 1
		}, 
		function()
		end
	)

	panel.popout = function ()
	    local visibleSize = Director:sharedDirector():getVisibleSize()
	    local visibleOrigin = Director:sharedDirector():getVisibleOrigin()
	    local panelSize = panel:getGroupBounds().size
	    panel:setPositionY(panelSize.height + visibleOrigin.y + visibleSize.height)
	    panel:setPositionX((visibleSize.width - panelSize.width) /2 + visibleOrigin.x)
	    Director:sharedDirector():getRunningScene():addChild(panel , SceneLayerShowKey.TOP_LAYER)

	    -- PopoutQueue:sharedInstance():push(panel, false, true)

	    local arr = CCArray:create()
	    arr:addObject(CCMoveBy:create(0.5, ccp(0, - 32 - panelSize.height)))
	    arr:addObject(CCDelayTime:create(4))
	    arr:addObject(CCMoveBy:create(0.2, ccp(0,  32 + panelSize.height)))
	    arr:addObject(CCCallFunc:create(function()
	        panel:close()
	    end))
	    panel:runAction(CCSequence:create(arr))
	end


	panel:popout()
end