require "hecore.display.Scene"
require "zoo.qr.qrmanager"

--
-- Director ---------------------------------------------------------
--

CCTOUCHBEGAN = "began"
CCTOUCHMOVED = "moved"
CCTOUCHENDED = "ended"
CCTOUCHCANCELLED = "cancelled"

-- initialize
local instance = nil;
local globalUpdateID = -1;
local sceneStack={};
Director = {resourceAnimationFPS = 30, gameFPS = 60, __runningScene = nil};

local function commonKeypadHandler()
	local runningScene = Director:sharedDirector():getRunningScene()
	if runningScene then
		local popoutPanel = PopoutManager:sharedInstance():getLastPopoutPanel()
		if QRManager:isQRScanning() == true then
			QRManager:onKeyBackClicked()
		elseif __ANDROID and PersonalCenterManager:getData(PersonalCenterManager.IS_TAKE_PHOTO) == true then
			PersonalCenterManager:onKeyBackClicked()
		elseif popoutPanel and type(popoutPanel.onKeyBackClicked) == "function" then
			popoutPanel:onKeyBackClicked()
		elseif type(runningScene.onKeyBackClicked) == "function" then
			runningScene:onKeyBackClicked()
		end
		BroadcastManager:getInstance():onBackKey()
	end
end

function Director.sharedDirector()
	if not instance then
		instance = Director;
		if _G.isLocalDevelopMode then printx(0, "=========================Startup Director============================") end;
		
		--update
		if globalUpdateID > -1 then CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(globalUpdateID) end
		local function onUpdateGlobal(dt)
			local runningScene = Director.__runningScene;
			if runningScene then runningScene:onUpdate(dt) end;
		end
		globalUpdateID = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onUpdateGlobal,0.02,false);
		
		if __ANDROID or __WP8 then
			CommonKeypadDelegate:getInstance():registerScriptKeypadHandler(commonKeypadHandler)
		end
	end
	return instance;
end

--
-- public props -------------------
--

function Director:getAnimationInterval() return CCDirector:sharedDirector():getAnimationInterval() end;
function Director:isDisplayStats() return CCDirector:sharedDirector():isDisplayStats() end;
function Director:setDisplayStats(v) CCDirector:sharedDirector():setDisplayStats(v) end;
function Director:isPaused() return CCDirector:sharedDirector():isPaused() end;
function Director:getTotalFrames() return CCDirector:sharedDirector():getTotalFrames() end;
function Director:getWinSize() return CCDirector:sharedDirector():getWinSize() end;
function Director:getWinSizeInPixels() return CCDirector:sharedDirector():getWinSizeInPixels() end;
function Director:getContentScaleFactor() return CCDirector:sharedDirector():getContentScaleFactor() end;
function Director:setContentScaleFactor(f) return CCDirector:sharedDirector():setContentScaleFactor(f) end;
function Director:getZEye() return CCDirector:sharedDirector():getZEye() end;
--CCScheduler
function Director:getScheduler() return CCDirector:sharedDirector():getScheduler() end;
--CCActionManager
function Director:getActionManager() return CCDirector:sharedDirector():getActionManager() end;
--CCTouchDispatcher
function Director:getTouchDispatcher() return CCDirector:sharedDirector():getTouchDispatcher() end;
--CCKeypadDispatcher
function Director:getKeypadDispatcher() return CCDirector:sharedDirector():getKeypadDispatcher() end;
--CCAccelerometer
function Director:getAccelerometer() return CCDirector:sharedDirector():getAccelerometer() end;
--CCNode
function Director:getNotificationNode() return CCDirector:sharedDirector():getNotificationNode() end;
--CCSize
function Director:getVisibleSize() return CCDirector:sharedDirector():getVisibleSize() end;
--CCPoint
function Director:getVisibleOrigin() return CCDirector:sharedDirector():getVisibleOrigin() end;
--CCPoint
function Director:convertToGL(v) return CCDirector:sharedDirector():convertToGL(v) end;
function Director:convertToUI(v) return CCDirector:sharedDirector():convertToUI(v) end;
--CCEGLViewProtocol
function Director:getOpenGLView() return CCDirector:sharedDirector():getOpenGLView() end;
--ccDirectorProjection
function Director:getProjection() return CCDirector:sharedDirector():getProjection() end;
function Director:setProjection(v) CCDirector:sharedDirector():setProjection(v) end;
--CCSize
function Director:ori_getVisibleSize() return CCDirector:sharedDirector():ori_getVisibleSize() end;
--CCPoint
function Director:ori_getVisibleOrigin() return CCDirector:sharedDirector():ori_getVisibleOrigin() end;

--local saveFile = HeResPathUtils:getUserDataPath() .. "screen.jpg"
--if _G.isLocalDevelopMode then printx(0, "saveFile:", Director:sharedDirector():saveScreenshot(saveFile)) end

function Director:saveScreenshot( saveFilePath )
	local size = CCDirector:sharedDirector():getWinSize()
	local texture = CCRenderTexture:create(size.width, size.height)
	texture:setPosition(ccp(size.width/2, size.height/2))
	texture:begin()
	CCDirector:sharedDirector():getRunningScene():visit()
	texture:endToLua()
	return texture:saveToFile(saveFilePath) --jpeg
end

function Director:exitGame()
	if __IOS then AppController:exitGame() end

	if __ANDROID then
		require "zoo.platform.VivoPlatform"
		VivoPlatform:onEnd()
	end

	if __ANDROID or __WP8 then CCDirector:sharedDirector():endToLua() end
end
--
-- public control -------------------
--

function Director:pause() CCDirector:sharedDirector():pause() end;
function Director:resume() CCDirector:sharedDirector():resume() end;
function Director:purgeCachedData() CCDirector:sharedDirector():purgeCachedData() end;

local function indexOf(scene)
	if not scene then return -1 end;
	local idx = -1;
	for i, v in ipairs(sceneStack) do
		if v == scene then
			idx = i;
			break;
		end
	end
	return idx;
end

function Director:numOfStack()
	return #sceneStack
end

function Director:getRunningScene()
	local s = CCDirector:sharedDirector():getRunningScene();
	for i, v in ipairs(sceneStack) do
		if v.refCocosObj == s then return v end;
	end
	return nil;
end

function Director:getRunningSceneLua()
	return self.__runningScene;
end

function Director:afterSceneAdded(s)
	-- 显示内存占用的一个信息条
	if MaintenanceManager:getInstance():isEnabled("DebugBanner") then
		if __IOS or __ANDROID then
			require "hecore.debug.DebugBanner"
			local debugBanner = DebugBanner:create()
			s:superAddChild(debugBanner)
			debugBanner:setPositionX(0)
			local visibleSize	= CCDirector:sharedDirector():getVisibleSize()
			local visibleOrigin	= CCDirector:sharedDirector():getVisibleOrigin()
			debugBanner:setPositionY(visibleSize.height + visibleOrigin.y)
		end
	end
end

function Director:runWithScene(s)
	local idx = indexOf(s);
	if s and idx == -1 then
		table.insert(sceneStack, s);
		CCDirector:sharedDirector():runWithScene(s.refCocosObj);
		s:onEnter();
		self.__runningScene = s;
		self:afterSceneAdded(s)
	end
end

function Director:pushScene(s,params)
	local idx = indexOf(s);
	if s and idx == -1 then
		local runningScene_ = self:getRunningScene();
		if(runningScene_ and runningScene_.onSceneLeaveFromPushScene) then
			runningScene_:onSceneLeaveFromPushScene(s);
		end

		table.insert(sceneStack, s);
		
		CCDirector:sharedDirector():pushScene(s.refCocosObj);
		s:onEnter(params);
		self.__runningScene = s;
        
		if runningScene_ then
			runningScene_.touchEnabled = false;
			s.touchEnabled = false;
			local onResetPrevSceneFunc = -1;
			local function onResetPrevScene()
				runningScene_.touchEnabled = true;
				s.touchEnabled = true;
				CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(onResetPrevSceneFunc);
			end
			onResetPrevSceneFunc = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onResetPrevScene,0.35,false);
		end
		self:afterSceneAdded(s)
	end
end

function Director:popToRootScene(paramsToRootScene)
  local s = self:getRunningScene();
  local rootScene = sceneStack[1];
  if (not s) or (not rootScene) or (s == rootScene) then return end;
  
  for i = #sceneStack, 2, -1 do
    local current = sceneStack[i];
    CCDirector:sharedDirector():popScene();
    current:onExit();
    current:dispose();
    table.remove(sceneStack, i);
  end
  
  rootScene:onEnter(paramsToRootScene);
end
function Director:popScene(cleanup, paramsToPrevScene, temporary)
	local OnlinePerformanceLog = require("hecore.debug.OnlinePerformanceLog")
	if(OnlinePerformanceLog:enabled()) then
		local msg = OnlinePerformanceLog:getCpuInfo()
		if msg ~= '' then
        	he_log_error(msg)
		end
	end


	local s = self:getRunningScene();
	if s then
		local idx = indexOf(s);
		if idx ~= -1 then table.remove(sceneStack, idx) end;
		CCDirector:sharedDirector():popScene();
		s:onExit();
		local isCleanup = true;
		if cleanup ~= nil then isCleanup = cleanup end;
		if isCleanup then s:dispose() end;
    
		local length = table.getn(sceneStack); 
		if length > 0 then
		    self.__runningScene = sceneStack[length];
		    self.__runningScene:onEnter(paramsToPrevScene);
		    --[[
		    if(self.__runningScene.onSceneBackFromPopScene == nil) then
			    self.__runningScene:onEnter(paramsToPrevScene);
		    end
		    ]]
		else
		    self.__runningScene = nil;
		end
    
		local runningScene_ = self.__runningScene;
		if runningScene_ then 
			runningScene_.touchEnabled = false 
			if(not(temporary) and runningScene_.onSceneBackFromPopScene) then
				runningScene_:onSceneBackFromPopScene(paramsToPrevScene);
			end
		end;
		s.touchEnabled = false;
		local onResetPrevSceneFunc = -1;
		local function onResetPrevScene()
		  if runningScene_ then 
		  	runningScene_.touchEnabled = true 
		  end;
		  s.touchEnabled = true;
		  CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(onResetPrevSceneFunc);
		end
		onResetPrevSceneFunc = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onResetPrevScene,0.35,false);
	end
end

function Director:replaceScene(s)
	local currentRunningScene = nil;
	local currentRunningIndex = -1;
	--if _G.isLocalDevelopMode then printx(0, "replaceScene", table.getn(sceneStack)) end;
	
	local ccRunning = CCDirector:sharedDirector():getRunningScene();
	for i, v in ipairs(sceneStack) do
		if v.refCocosObj == ccRunning then
			currentRunningScene = v;
			currentRunningIndex = i;
			break;
		end
	end

	local idx = indexOf(s);
	if idx == -1 then
		table.insert(sceneStack, s);
		CCDirector:sharedDirector():replaceScene(s.refCocosObj);
		s:onEnter();
		self.__runningScene = s;

		if currentRunningScene then 
		  currentRunningScene:onExit();
		  currentRunningScene:dispose();
		  if currentRunningIndex ~= -1 then table.remove(sceneStack, currentRunningIndex) end;
		end
	end

	local runningScene_ = currentRunningScene;
	if runningScene_ then runningScene_.touchEnabled = false end;
	s.touchEnabled = false;
	local onResetPrevSceneFunc = -1;
	local function onResetPrevScene()
    if runningScene_ then runningScene_.touchEnabled = true end;
		s.touchEnabled = true;
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(onResetPrevSceneFunc);
	end
	onResetPrevSceneFunc = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onResetPrevScene,0.35,false);
	self:afterSceneAdded(s)
end

--short name
Director.mgr = Director.sharedDirector
Director.run = Director.getRunningScene
Director.push = Director.pushScene
Director.pop = Director.popScene
Director.rep = Director.replaceScene

if __PURE_LUA__ then
	require "plua.myDirect"
end