
DebugBanner = class(BaseUI)

function DebugBanner:ctor()
end

function DebugBanner:dispose(...)
	if self.schedId ~= nil then 
		CCDirector:sharedDirector():getScheduler():unscheduleScriptEntry(self.schedId)
	end
	BaseUI.dispose(self)
end

function DebugBanner:create()
	local btn = DebugBanner.new()
	btn:init()
	return btn	
end

function DebugBanner:init()
	local visibleSize	= CCDirector:sharedDirector():getVisibleSize()

	self.ui	= Layer:create()
	BaseUI.init(self, self.ui)

	local bg = LayerColor:createWithColor(ccc3(0,0,255), visibleSize.width, 36)
	self.ui:addChild(bg)
	bg:setPosition(ccp(0, -36))

	local idx = 2
	local function touchListener(...)
		local mod = {0, 96, 128, 255}
		idx = idx % (#mod) + 1
		bg:setOpacity(mod[idx])
		collectgarbage("collect") 
	end

	if StartupConfig:getInstance():isLocalDevelopMode() or true then
		bg:setOpacity(96)
		bg:setTouchEnabled(true)
		bg:addEventListener(DisplayEvents.kTouchTap, touchListener)
	else
		bg:setOpacity(0)
	end

	local label = TextField:create("", nil, 24)
	label:setAnchorPoint(ccp(0, 1))
	label:setPosition(ccp(0,-2))
	self.ui:addChild(label)

	self.label = label

	local function update()
		local appUsed = 0
		local sysAvailable = 0
		local physicalMemory = 0

		if __IOS then
	    	physicalMemory = NSProcessInfo:processInfo():physicalMemory() or 0
			physicalMemory = physicalMemory / (1024 * 1024)
    		appUsed = AppController:getUsedMemory() / (1024)	-- MB
    		sysAvailable = AppController:getTotalMemory()
		elseif __ANDROID then
			local disp = luajava.bindClass("com.happyelements.hellolua.share.DisplayUtil")
	    	physicalMemory = disp:getSysMemory()
     		physicalMemory = physicalMemory / (1024 * 1024)
			appUsed = disp:getAppUsedMemory() / (1024)	-- MB

			sysAvailable = physicalMemory
		end

		local luaUsed = collectgarbage("count") / 1024
		local info = string.format("Lua/APP/可用大小/物理大小/LowEffect:%0.2f/%d/%d/%d/%s", luaUsed, appUsed, sysAvailable, physicalMemory, _G.__use_low_effect)
		self.label:setString(info)
	end
	
	self.schedId = Director:sharedDirector():getScheduler():scheduleScriptFunc(update, 3, false)
end