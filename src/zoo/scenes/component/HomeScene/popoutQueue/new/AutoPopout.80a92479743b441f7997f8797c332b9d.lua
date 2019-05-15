--[[
 * AutoPopout
 * @date    2018-07-31 16:42:28
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]
require "zoo.scenes.component.HomeScene.popoutQueue.new.AutoPopoutConstant"

AutoPopout = {}

local function split( str, sep )
	if not str then
		return {}
	end
	local t = {}
	for s in string.gmatch(str, "([^"..sep.."]+)") do
    	table.insert(t, tonumber(s))
	end
	return t
end

function AutoPopout:getOriConfig()
	return (require "zoo.scenes.component.HomeScene.popoutQueue.new.AutoPopoutActions")
end

function AutoPopout:init(homeScene)
	GameLauncherContext:getInstance():onStartInitPopoutQueue()
	self.homeScene = homeScene

	if homeScene and self:isDebug() then
		require "zoo.scenes.component.HomeScene.popoutQueue.new.AutoPopoutUnitTest"
		AutoPopoutUnitTest:init()
	end

	if self.isInit then return end
	self.isInit = true

	local index = 0
	local function gnext()
		index = index + 1
		return index
	end

	local config = self:getOriConfig()

	local last_action = nil
	self.actions = {}

	for _,info in ipairs(config) do
		local at = info.actionType
		local actions = info.actions
		for _,clsInfo in ipairs(actions) do
			local cls = clsInfo

			if info.actionType == AutoPopoutActionType.kFeature then
				at = clsInfo[1]
				cls = clsInfo[2]
			end

			local action = cls.new()
			action:init(at, gnext(), last_action)
			last_action = action
			cls.id = action.id

			self.actions[cls.id] = action

			if not self.action then
				self.action = action
				last_action = action
			end
		end
	end

	self.sourceCaches = {}
	self.popCounts = {}
	self.actionPopCache = nil
	self.panelCloseEntry = false
	self.waitTime = 0
	self.state = AutoPopoutState.kIdle
	self.loopId = 0
	self.nextLoopId = 0
	self.gotoPlayScene = false

	Notify:register("enterHomeScene", self.onEnterHomeScene, self)
	Notify:register("AutoPopoutEventWaitAction", self.waitAction, self)
	Notify:register("AutoPopoutEventAwakenAction", self.awakenAction, self)
	Notify:register("SceneEventEnterForeground", self.onEnterForeground, self)
	Notify:register("HomeSceneEventOpenUrl", self.checkOpenUrl, self)
	Notify:register("GuideCompleteEvent", self.onGuideComplete, self)
	Notify:register("PanelCloseEvent", self.onClosePanel, self)
	Notify:register("exitHomeSceneEvent", self.onExitHomeScene, self)
	Notify:register("QuitNextLevelModeEvent", self.onQuitNextLevelMode, self)
	Notify:register("EnterNextLevelModeEvent", self.onEnterNextLevelMode, self)
	Notify:register("WillEnterPlaySceneEvent", self.onWillEnterPlayScene, self)
	Notify:register("AutoPopoutEventStopCurAction", self.onStopCurAction, self)




end


function AutoPopout:doMaintenanceSetting()
	-- if not isLocalDevelopMode then
	-- 	return 
	-- end
	local meta = MaintenanceManager:getInstance():getMaintenanceByKey("EnterNextLevelModel")
	if meta and meta.enable then
		local valueString = tostring(meta.extra)
		local valueTable = split( valueString,"|" )
		local uid = UserManager:getInstance():getUID() or "12345"
		if table.includes( valueTable , tonumber(uid) ) then
			-- Notify:dispatch("EnterNextLevelModeEvent")
			AutoPopout:onEnterNextLevelMode()
			local str = "用户:"..uid .. " 阻止弹板子"
			CommonTip:showTip( str )
			self.defaultNextLevelModel = true
		end
	else
		-- if _G.isLocalDevelopMode then printx(100, "\n\n meta is a nil value  " ) end
	end

end

function AutoPopout:doMaintenanceSetting_Clear()
	-- if not isLocalDevelopMode then
	-- 	return 
	-- end
	if self.defaultNextLevelModel then
		AutoPopout:onQuitNextLevelModeOnlyForMaintenance()
		self.defaultNextLevelModel = false
	end
end

function AutoPopout:isDebug()
	local enable = MaintenanceManager:getInstance():isEnabled("AutoPopoutDebug", false)
	return enable
end

function AutoPopout:getAction( id )
	return self.actions[id]
end

function AutoPopout:createSchedule()
	local function update( dt )
		self:update(dt)
	end
	if not self.scheduleId then
		self.scheduleId = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(update, 0, false)
	end
end

function AutoPopout:closeSchedule()
	if self.scheduleId then
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.scheduleId)
		self.scheduleId = nil
	end
end

function AutoPopout:update( dt )
	if self.state == AutoPopoutState.kWaiting then
		self.waitTime = self.waitTime + dt
	else
		self:closeSchedule()
		return
	end

	local action = self.curAction
	if self.waitTime > AutoPopoutConfig.timeout
		or (action and action.waitNextFrame)
	then
		self:closeSchedule()
		self:setActionTimeout(self.curAction)
		self:check(self.curAction)
	end
end

function AutoPopout:setActionTimeout(action)
	self.timeoutActions[action.id] = true
end

function AutoPopout:changeState( state, action )
	if state == AutoPopoutState.kChecking then
		self.curAction = action
	elseif state == AutoPopoutState.kWaiting then
		if not action.isWait then
			self.waitTime = 0
			action:wait()
		end
		self:createSchedule()
	elseif state == AutoPopoutState.kWaitClosePanel then
	elseif state == AutoPopoutState.kPopCache then
		self:cache(action.atype, {canPop = true}, action)
		self:uploadLog()
	elseif state == AutoPopoutState.kFinished then
		self.checkRunning = false
		self.curAction = nil
		self.timeoutActions = {}
		self:uploadLog()
		BroadcastManager:getInstance():active()
		self:closeSchedule()
		Notify:dispatch('AutoPopoutCheckEnd')
	elseif state == AutoPopoutState.kPopout then
		if not action.ignorePopCount then
			self.popCounts[action.atype] = (self.popCounts[action.atype] or 0) + 1
		end
		self:uploadLog()
	end

	-- self:print("change state:", AutoPopoutState:name(self.state), "to", AutoPopoutState:name(state))
	self.state = state
end

function AutoPopout:onStopCurAction(cls)
	if not cls or not self.actions[cls.id] then
		self:print("Try Stop current action: but not this action!")
		return
	end

	local action = self.actions[cls.id]

	self:print("Try Stop current action:", action and action.name)

	if self.curAction == action then
		--TODO:other action stop?
		if self.curAction.atype == AutoPopoutActionType.kGuide 
			and self.state == AutoPopoutState.kPopout
		then
			if GameGuide then GameGuide:sharedInstance():forceStopGuide() end
			self:checkNextAction(self.curAction)
		end
	else
		self:print("Try Stop current action, the current action is not this action!")
	end
end

function AutoPopout:onExitHomeScene()
	
end

function AutoPopout:onWillEnterPlayScene()
	self:print("onWillEnterPlayScene...")
	self.gotoPlayScene = true
end

function AutoPopout:onEnterHomeScene(homeScene, isNewer)
	local hasInit = homeScene.isInited
	self.homeScene = homeScene

	if hasInit then
		if self.curAction and self.curAction.isPopScene then
			self:checkNextAction(self.curAction)
			return
		end
	end

	--1,check url
	if not hasInit then
		self:checkOpenUrl(_G.launchURL, true)
	end

	--2,check notify
	self:checkNotify()

	if isNewer then
		self:print("newer cant auto popout!")
		return
	end

	self:entry(hasInit and AutoPopoutSource.kSceneEnter or AutoPopoutSource.kInitEnter)
end

function AutoPopout:onClosePanel(isAct, isCommonTip)
	if not self:isHomeScene() then
		return
	end

	if self.gotoPlayScene then
		self:print("will enter play scene, cant trigger auto popout!")
		return
	end

	self:print("home scene,on close panel:",isAct, isCommonTip)
	if self.state == AutoPopoutState.kPopCache then
		if self.curAction then
			self:check(self.curAction)
		else
			--donothing.wait new loop
		end
		return
	end

	if self.state == AutoPopoutState.kPopout 
		and isCommonTip
		and self.curAction and self.curAction.atype == AutoPopoutActionType.kActivity
	then
		self.homeScene:runAction(CCCallFunc:create(function ()
			self:checkNextAction(self.curAction)
		end))
		return
	end

	if self.state == AutoPopoutState.kPopout and isAct 
		and self.curAction and self.curAction.atype == AutoPopoutActionType.kActivity 
	then
		self.homeScene:runAction(CCCallFunc:create(function ()
			self:checkNextAction(self.curAction)
		end))
		return
	end

	if self.state ~= AutoPopoutState.kWaitClosePanel then
		return
	end

	self:entry(self.tmpSource)
end

function AutoPopout:onEnterForeground()
	self.homeScene:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.3), CCCallFunc:create(function ()
		self:checkNotify()
		self:entry(AutoPopoutSource.kEnterForeground)
	end)))
end

function AutoPopout:onReturnFromFAQ( ... )
	if self:isHomeScene() then
		self.homeScene:runAction(CCSequence:createWithTwoActions(CCDelayTime:create(0.3), CCCallFunc:create(function ()
			self:entry(AutoPopoutSource.kReturnFromFAQ)
		end)))
	end
end

function AutoPopout:onQuitNextLevelModeOnlyForMaintenance()

	for t,v in pairs(self.sourceCaches) do
		self.sourceCaches[t] = nil
	end
	self:changeState(AutoPopoutState.kIdle)
	
end

function AutoPopout:onQuitNextLevelMode(notClear, runLoop )
	if self.state == AutoPopoutState.kNextLevelMode then
		self:print("quit next level mode!")
		--clear cache
		if not notClear then
			for t,v in pairs(self.sourceCaches) do
				if v.atype == AutoPopoutActionType.kNextLevelMode then
					self.sourceCaches[t] = nil
				end
			end
		end

		self:changeState(AutoPopoutState.kIdle)

		if runLoop then
			local action = self:getAction(UnlockBlockerAndPlayPopoutAction.id)
			self:clearCache(action)

			self.subSourceDirty = true
			self:entry(self.tmpSource)
		end
	end
end

function AutoPopout:onEnterNextLevelMode()
	self:changeState(AutoPopoutState.kNextLevelMode)
end

function AutoPopout:isInNextLevelMode()
	return self.state == AutoPopoutState.kNextLevelMode
end

function AutoPopout:checkNotify()
	local id, push_type, textId, param_str
	local function getParemStr()
		if __ANDROID then
			param_str = luajava.bindClass('com.happyelements.android.MainActivityHolder').ACTIVITY:getClickedNotificationParams(true)
		elseif __IOS then
			param_str = AppController:getNotificationParams_clear(true)
		end
	end
	pcall(getParemStr)

	self:print("checkNotify :", param_str)

	if self:isDebug() then
		param_str = AutoPopoutUnitTest:cacheNotify(param_str)
	end

	if param_str and string.len(param_str) > 0 then
		local params = table.deserialize(param_str)
		if params then
			local has = false
			for k,v in pairs(params) do
				has = true
				break
			end
			if has then
				self:cache(AutoPopoutActionType.kSubFeatureNotify, params)

			    require "zoo.push.PushUserCallbackManager"
			    PushUserCallbackManager:checkSystemPush(params)
			end
		end
	end
end

function AutoPopout:cache( atype, para, action )
	self:print("cache action:", table.tostring(para), action and action.name)
	if not action and not atype then
		self:print("cache error", action and action.name, atype)
		return
	end

	if self.state ~= AutoPopoutState.kPopCache and 
		para and type(para) == "table" and para.canPop ~= nil 
	then
		self:print("cache error, cant use canPop attribute!!!")
		return
	end

	if action then
		self.sourceCaches[action] = {
				atype = atype,
				action = action,
				para = para,
			}
	else
		self.sourceCaches[atype] = {
				atype = atype,
				para = para,
			}
	end
end

function AutoPopout:checkOpenUrl(url, notEntry)
	if self:isDebug() then
		url = AutoPopoutUnitTest:cacheUrl(url)
	end

	self:print("url:",url)

	local res = UrlParser:parseUrlScheme(url or "")
	local has = false
	for k,v in pairs(res) do
		has = true
		break
	end
	if has then
		self:cache(AutoPopoutActionType.kOpenUrl, res)
	end
end

function AutoPopout:checkRecallUser()
	local now = Localhost:time()
	local lastLoginTime = UserManager:getInstance().lastLoginTime or 0
	if lastLoginTime == 0 then lastLoginTime = now end
	local time = (now - lastLoginTime)/24/3600/1000

	self.isRecallUser = (time >= 7 and UserManager:getInstance().user:getTopLevelId() > 1)

	if self.isDebug() then
		self.isRecallUser = AutoPopoutUnitTest:isRecallUser(self.isRecallUser)
	end
end

function AutoPopout:reEntry()
	self:changeState(AutoPopoutState.kIdle)
	self.subSourceDirty = true
	self:entry(self.tmpSource)
end

function AutoPopout:entryPreHandler(source)
	self.gotoPlayScene = false
	self.showTipAction = false

	if self.nextLoopId == self.loopId then
		self.nextLoopId = self.loopId + 1
	end

	self.tmpSource = source

	if self.state == AutoPopoutState.kNextLevelMode then
		self:print("entry,in next level mode!")
		self:uploadLog()
		return
	end

	if self:haveWindowOnScreen() then
		self:print("entry,has window, cant auto popout!")
		if source == AutoPopoutSource.kEnterForeground then
			local action = self:getAction(OpenActivityPopoutAction.id)
			if action then
				local cache = self:getCache(action)
				if cache then
					self.source = source
					self.showTipAction = true
					self.loopId = self.nextLoopId
					self.popCounts = {}
					self.timeoutActions = {}
					self:checkOne(action)
					return
				end
			end
		end

		self:changeState(AutoPopoutState.kWaitClosePanel)
		self:uploadLog()
		return
	end

	if self.state == AutoPopoutState.kChecking or self.state == AutoPopoutState.kPopout then
		self:print("[error][error][error] entry, check is running!")
		self:uploadLog()
	end

	self:checkRecallUser()

	self.source = source

	if not self.subSourceDirty then
		self.subSource = 0
	else
		self.subSourceDirty = false
	end

	self:print("entry source:", AutoPopoutSource:name(source), AutoPopoutSource:name(self.subSource))

	self.loopId = self.nextLoopId
	self.isCheckOne = false

	self.popCounts = {}
	self.timeoutActions = {}

	self:waitSomeAction()

	BroadcastManager:getInstance():unActive()
	return true
end

function AutoPopout:entry( source )
	if self:getCache({atype = AutoPopoutActionType.kOpenUrl}) then
		if self:entryPreHandler(source) then
			self:check(self.action)
		end
	else
		local fakeURL = ClipBoardUtil.getText() or ""
		local res = UrlParser:parseUrlScheme(fakeURL)
		if res and res.urlType then
			self:checkOpenUrl(fakeURL)
			ClipBoardUtil.copyText("")
		end
		
		if self:entryPreHandler(source) then
			self:check(self.action)
		end
	end
end

function AutoPopout:onGuideComplete()
	local action = self.curAction
	if self.state == AutoPopoutState.kPopout and action and action.atype == AutoPopoutActionType.kGuide then
		action.guideFlag = false
		self.homeScene:runAction(CCCallFunc:create(function ()
			self:checkNextAction(action)
		end))
	end
end

function AutoPopout:waitSomeAction()
	self:waitAction(ActivityCenterGuidePopoutAction)

	local topLevelId = 0
	if UserManager:getInstance().user then
		topLevelId = UserManager:getInstance().user:getTopLevelId()
	end

	if topLevelId % 15 == 1 and self.subSource == AutoPopoutSource.kGamePlayQuit then
		self:waitAction(AreaTaskTriggerPopoutAction)
		self:waitAction(UnlockBlockerAndPlayPopoutAction)
	end
end

function AutoPopout:waitAction(cls, params)
	if not cls or not self.actions[cls.id] then
		self:print("wait action: but not this action!")
		return
	end

	local action = self.actions[cls.id]
	if action then
		action:wait(params)
		self:print("wait action:", action.name)
	else
		self:print("[error]want to wait action:", cls, ",but no this action!")
	end
end

function AutoPopout:awakenAction(cls, params)
	if not self.homeScene then
		if not cls or not self.actions[cls.id] then
			self:print("awaken action: but not this action!")
			return
		end

		local action = self.actions[cls.id]
		self:print("awaken action:",action.name, AutoPopoutState:name(self.state))
		action:awaken()
		self:cache(action.atype, params, action)
	else
		self.homeScene:runAction(CCCallFunc:create(function ()
			if not cls or not self.actions[cls.id] then
				self:print("awaken action: but not this action!")
				return
			end

			local action = self.actions[cls.id]

			action:awaken()
			self:cache(action.atype, params, action)

			if self:isInNextLevelMode() then
				self:print("awaken action:",action.name, "but in next level mode!")
				return
			end

			if not self:isHomeScene() then
				self:print("awaken action: not in home scene！")
				return
			end

			if self:haveWindowOnScreen() then
				self:print("awaken action:has window, wait the window close!")
				return
			end

			self:print("awaken action:",action.name, AutoPopoutState:name(self.state))

			if self.state == AutoPopoutState.kFinished then
				self:checkOne(action)
			elseif self.state == AutoPopoutState.kChecking
				or self.state == AutoPopoutState.kPopout
				or self.state == AutoPopoutState.kWaitClosePanel
				or self.state == AutoPopoutState.kNextLevelMode
				or self.state == AutoPopoutState.kIdle
				or self.state == AutoPopoutState.kPopCache
			then
				--do nothing
				--if popout or checking,
				--and current action priority less then this action,
				--do nothing,and wait for next loop
				self:print("awaken action: cur state,",self.curAction and self.curAction.name, AutoPopoutState:name(self.state), "can`t check!")
			elseif self.state == AutoPopoutState.kWaiting then
				if self.curAction == action then
					self:check(action)
				elseif self.curAction then
					self:print("wait action:", self.curAction.name)
				else
					self:print("wait action: nothing, may be error!")
				end
			end
		end))
	end
end

function AutoPopout:checkPopCache()
	local action = self.actionPopCache
	self.actionPopCache = nil
	self:popoutAction(action)
end

function AutoPopout:isHomeScene()
	local scene = Director:sharedDirector():getRunningScene()
	return scene and scene:is(HomeScene)
end

function AutoPopout:checkGuideFlag( cls )
	local action = self.actions[cls.id]
	return action and action.guideFlag
end

function AutoPopout:checkNextAction( action )
	if self.nextLoopId ~= self.loopId then
		--need run new loop
		self:print("need run new loop", action.name)
		-- self:reEntry()
		return
	end

	if action ~= self.curAction then
		self:print("may be another loop!")
		return
	end

	if self:isHomeScene() and action then
		self.homeScene:runAction(CCCallFunc:create(function ()
			local isCheckOne = self.isCheckOne
			action:next()
			--trigger autopopout,need restore state
			if self.showTipAction then
				self:changeState(AutoPopoutState.kWaitClosePanel)
			elseif isCheckOne then
				self:checkFinished(true)
			end
		end))
	else
		--quit loop
		self:checkFinished(true)
	end
end

function AutoPopout:popoutAction( action )
	if self:haveWindowOnScreen() and not self.showTipAction then
		self:print("has window, wait the window close!")
		self:changeState(AutoPopoutState.kPopCache, action)
		return false
	else
		self:print("popout action:", action.name, "ignorePopCount:", action.ignorePopCount)

		self:changeState(AutoPopoutState.kPopout, action)
		local funcAction = CCCallFunc:create(function ()
			local function next_action()
				if action.isPopScene then
					self:print("need popout other scene, and cant run next action!")
					return
				end
				if action.isPop or action.atype == AutoPopoutActionType.kActivity then
					action.isPop = false
					self:checkNextAction(action)
				else
					self:print("had callback, cant run next action!")
				end
			end
			action.isPop = true
			action:popout(next_action)
		end)
		funcAction:setTag(AutoPopoutConfig.popActionTag)

		self.homeScene:stopActionByTag(AutoPopoutConfig.popActionTag)
		self.homeScene:runAction(funcAction)
		return true
	end
end

function AutoPopout:checkResult( action, canPop )
	local ret = true
	if self.timeoutActions[action.id] then
		self:print("check action:", action.name, " timeout!")
		ret = false
	end

	if ret and action ~= self.curAction then
		self:print("may be another loop! loop id:", self.loopId)
		ret = false
	end

	if ret and not self:isHomeScene() then
		self:print("not home scene, loop id:", self.loopId)
		ret = false
		self:checkFinished(true)
	end

	if ret and self.state ~= AutoPopoutState.kWaiting then
		self:print("[warning] check result callback again:", action.name)
		ret = false
	end

	if canPop and not ret then
		--TODO:cache???
	end

	return ret
end

function AutoPopout:checkPopResult( action, canPop )
	action:awaken()

	if not self:checkResult(action, canPop) then
		return
	end

	if canPop then
		self:popoutAction(action)
	else
		self:checkNextAction(action)
	end
end

function AutoPopout:checkCacheResult( action, cacheCanPop, needClearCache )
	action:awaken()

	if not self:checkResult(action) then
		return
	end

	if cacheCanPop and not action.checkRuntime then
		needClearCache = needClearCache and self:popoutAction(action)
	else
		self:changeState(AutoPopoutState.kWaiting, action)
		action:checkCanPop()
	end

	if needClearCache then
		self:clearCache(action)
	end
end

function AutoPopout:checkFinished(isMidQuit)
	self:print("check all action finished, isMidQuit:",isMidQuit)
	self:changeState(AutoPopoutState.kFinished)
	GameLauncherContext:getInstance():onInitPopoutQueueDone()
end

function AutoPopout:checkOne( action )
	self.isCheckOne = true
	self:check(action)
end

function AutoPopout:setSubSource(source)
	self.subSource = source
	self.subSourceDirty = true
end

function AutoPopout:matchSource(action)
	local match = action:matchSource(self.source)
	if not match then
		return action:matchSource(self.subSource)
	end
	return match
end

function AutoPopout:check( action )
	if not action then
		self:checkFinished()
		return
	end

	if self.gotoPlayScene then
		self:print("check action:", action.name, "will goto Play Scene, cant popout!")
		return
	end
	
	self:changeState(AutoPopoutState.kChecking, action)

	self:print("check action priority:", action.id, "loop id:",self.loopId, "name:", action.name)

	if self.isRecallUser and (action.recallUserNotPop or action.atype == AutoPopoutActionType.kGuide) then
		self:print("check action:", action.name, "but is recall user, cant pop!")
		self:checkNextAction(action)
		return
	end

	if self.timeoutActions[action.id] then
		self:print("check action:", action.name, " timeout run next action!")
		self:checkNextAction(action)
		return
	end

	if not self:matchSource(action) then
		self:print("check action:", action.name, "cant match entry source!")
		self:checkNextAction(action)
		return
	end

	if action.isWait then
		self:print("check action:", action.name, ",need wait!")
		self:changeState(AutoPopoutState.kWaiting, action)
		return
	end

	local popCount = self.popCounts[action.atype] or 0
	local limit = AutoPopoutConfig.limit[action.atype]

	if limit >= 0 and not action.ignorePopCount and popCount >= limit then
		self:print("check action:", action.name, "pop count is limit!")
		self:checkNextAction(action)
		return
	end

	local cache = self:getCache(action)

	if cache then
		if cache.para and type(cache.para) == "table" and cache.para.canPop then
			self:changeState(AutoPopoutState.kWaiting, action)
			action:onCheckCacheResult(true)
		elseif action.atype == AutoPopoutActionType.kOpenUrl and not action:checkOpenUrlMethod(cache) then
			self:checkNextAction(action)
		else
			self:changeState(AutoPopoutState.kWaiting, action)
			action:checkCache(cache)
		end
	else
		self:changeState(AutoPopoutState.kWaiting, action)
		action:checkCanPop()
	end
end

function AutoPopout:haveWindowOnScreen()
	return PopoutManager:sharedInstance():haveWindowOnScreenWithoutCommonTip()
			or (GameGuide:sharedInstance():getHasCurrentGuide()
				or BindPhoneGuideLogic:get().isGuideOnScreen == true)
end

--for activity
function AutoPopout:canPopAction( action )
	return not self:isTimeout(action) and self:isHomeScene() and self:haveWindowOnScreen()
end

function AutoPopout:isTimeout(action)
	return self.timeoutActions[action.id]
end

function AutoPopout:getCache( action )
	if action.debug then
		return {}
	end
	return self.sourceCaches[action] or self.sourceCaches[action.atype]
end

function AutoPopout:clearCache(action)
	self:print("clear cache:", action.name)
	if self.sourceCaches[action] then
		self.sourceCaches[action] = nil
	elseif self.sourceCaches[action.atype] then
		self.sourceCaches[action.atype] = nil
	end
end

function AutoPopout:showNotifyPanel( txt_key, close_cb)
	--TODO:create panel
	local AutoPopNoticePanel = require "zoo.scenes.component.HomeScene.popoutQueue.new.AutoPopNoticePanel"

	if not close_cb then
		close_cb = function ()
			if self.state == AutoPopoutState.kPopout then
				self:checkNextAction(self.curAction)
			end
		end
	end

	local panel = AutoPopNoticePanel:create(txt_key, close_cb)
	panel:popout()
end

function AutoPopout:uploadLog(...)
	if self:isDebug() then
		RemoteDebug:uploadLog()
	end
end

function AutoPopout:print( ... )
	if self:isDebug() then
		printx(10, "[AutoPopout]", ...)
		-- require "hecore.debug.remote"
		RemoteDebug:log(...)
	end
end

Notify:register("AutoPopoutInitEvent", AutoPopout.init, AutoPopout)