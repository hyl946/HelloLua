require "plua.simpleClass"

mySchedule = simple_class()

function mySchedule:ctor(func, time)
	self.startTime = 0
	self.func = func
	self.time = time or 0
end

function mySchedule:update(dt)
	self.startTime = self.startTime + dt
	if self.startTime >= self.time then
		--if self.node then
		--	self.func(self.node, dt)
		--else
			self.func(dt)
		--end
		self.startTime = 0
	end
end

OpenGLView = simple_class()
function OpenGLView:getFrameSize()
	return CCSizeMake(480, 720)
end

openGlView = OpenGLView.new()

                                                                                              

myCCDirect = simple_class()

function myCCDirect:ctor()
	self.scheduleList = {}
	self.m_pobScenesStack = {}
	self.m_pRunningScene = nil
    self.m_pNextScene = nil
	self.uuScriptFuncIndex = 1
	--self.uuUpdateForTargetIndex = 1
end

function myCCDirect:getOpenGLView()
	return openGlView
end

function myCCDirect:purgeCachedData()
end

function myCCDirect:scheduleScriptFunc(func, time)
	local curIndex = self.uuScriptFuncIndex
	local schedule = mySchedule.new(func, time)
	self.scheduleList[curIndex] = schedule
	self.uuScriptFuncIndex = self.uuScriptFuncIndex + 1
	return curIndex
end

function myCCDirect:unscheduleScriptEntry(index)
	if index then
		self.scheduleList[index] = nil
	end
end

function myCCDirect:scheduleUpdateForTarget(node, func, time)
	local curIndex = self.uuScriptFuncIndex
	local schedule = mySchedule.new(func, time)
	schedule.node = node
	self.scheduleList[curIndex] = schedule
	self.uuScriptFuncIndex = self.uuScriptFuncIndex + 1
	return curIndex
end

function myCCDirect:unscheduleUpdateForTarget(target)
	if not target then return end
	local sList = self.scheduleList
	for k, s in pairs(sList) do
		if s.node == target then
			self.scheduleList[k] = nil
			return
		end
	end
end

function myCCDirect:setNotificationNode(node)
end


function myCCDirect:update(dt)
	local sList = self.scheduleList
	for k, s in pairs(sList) do
		s:update(dt)
	end
	
	if self.m_pNextScene then
		if self.m_pRunningScene ~= nil then
			self.m_pRunningScene:onExitTransitionDidStart()
			self.m_pRunningScene:onExit()
		end
		
		self.m_pRunningScene = self.m_pNextScene
		self.m_pNextScene = nil
		
		self.m_pRunningScene:onEnter()
		self.m_pRunningScene:onEnterTransitionDidFinish()
	end

end

function myCCDirect:getRunningScene()
	return self.m_pRunningScene
end

function myCCDirect:runWithScene(scene)
	self:pushScene(scene);
end

function myCCDirect:pushScene(scene)
	self.m_pobScenesStack[#self.m_pobScenesStack + 1] = scene
	self.m_pNextScene = scene
end

function myCCDirect:popScene()
	local scene = self.m_pobScenesStack[#self.m_pobScenesStack]
	self.m_pobScenesStack[#self.m_pobScenesStack] = nil
	self.m_pNextScene = scene
end

function myCCDirect:replaceScene(scene)
	self.m_pobScenesStack[#self.m_pobScenesStack] = scene
	self.m_pNextScene = scene
end


function myCCDirect.myCreate()
	local mgr = myCCDirect.new()
	return mgr
end

local instance = nil
function myCCDirect.sharedDirector()
	if not instance then
		instance = myCCDirect.myCreate()
	end
	return instance
end

function myCCDirect:getScheduler()
	return instance
end

function myCCDirect:getWinSize()
	return CCSizeMake(480, 720)
end

function myCCDirect:getVisibleSize()
	return CCSizeMake(480, 720)
end

function myCCDirect:getVisibleOrigin()
	return ccp(480, 720)
end

function myCCDirect:setContentScaleFactor(v) end

function myCCDirect:ori_getVisibleSize()
	return CCSizeMake(10, 10)
end

function myCCDirect:ori_getVisibleOrigin()
	return ccp(10, 10)
end

function myCCDirect:getAnimationInterval()
	return 1/60
end

function myCCDirect:getContentScaleFactor()
	return self.ContentScaleFactor or 1
end

function myCCDirect:setContentScaleFactor(v)
	self.ContentScaleFactor = v
end

CCDirector_bak = CCDirector
CCDirector = myCCDirect