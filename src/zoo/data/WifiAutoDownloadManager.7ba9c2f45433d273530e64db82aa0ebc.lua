local WifiAutoDownloadManager = class()

WifiAutoDownloadManager.States = {
	kInvisible = 'WifiAutoDownloadManager.States.kInvisible', -- 该功能对用户不可见
	kTurnOn = 'WifiAutoDownloadManager.States.kTurnOn', -- 该功能可见 并开启
	kTurnOff = 'WifiAutoDownloadManager.States.kTurnOff', -- 该功能可见 已关闭
}


WifiAutoDownloadManager.Events = {
	kStateChange = 'WifiAutoDownloadManager.Events.kStateChange'
}

local developerIds = {
}

local function isDeveloper()
	local uid = '12345'
    if UserManager and UserManager:getInstance().user then
    	uid = UserManager:getInstance().user.uid or '12345'
    end
    return table.exist(developerIds, tostring(uid))
end

local function getUserKey( key )
    local uid = '12345'
    if UserManager and UserManager:getInstance().user then
        uid = UserManager:getInstance().user.uid or '12345'
    end
    return key .. tostring(uid) .. '.' .. '.by.Misc.getUserKey'
end

local instance

function WifiAutoDownloadManager:getInstance( ... )
	if not instance then
		instance = WifiAutoDownloadManager.new()
	end
	return instance
end

function WifiAutoDownloadManager:ctor( ... )
	self:init()
end

function WifiAutoDownloadManager:init( ... )
	--modify

	-- local state = CCUserDefault:sharedUserDefault():getStringForKey(getUserKey('WifiAutoDownloadManager.state'), '') or ''
	-- if tostring(state) == '' or tostring(state) == 'nil' then
	-- 	state = WifiAutoDownloadManager.States.kInvisible

	-- 	if __WIN32 or isDeveloper() then
	-- 		state = WifiAutoDownloadManager.States.kTurnOff
	-- 	end
	-- end

	local state

	local is_visible = UserManager:getInstance():hasBAFlag(kBAFlagsIdx.kWifiAutoDownloadSwitch_1)
	local is_turn_on = UserManager:getInstance():hasBAFlag(kBAFlagsIdx.kWifiAutoDownloadSwitch_2)

	if is_visible then
		if is_turn_on then
			state = WifiAutoDownloadManager.States.kTurnOn
		else
			state = WifiAutoDownloadManager.States.kTurnOff
		end
	else
		state = WifiAutoDownloadManager.States.kInvisible
		
		--这功能本来是记在前端，之后要改成记后端。
		--在此特殊处理，如果后端没值，前端缓存已有，把缓存 改写在后端
		local cached_state = CCUserDefault:sharedUserDefault():getStringForKey(getUserKey('WifiAutoDownloadManager.state'), '') or ''
		if cached_state == WifiAutoDownloadManager.States.kTurnOn or cached_state == WifiAutoDownloadManager.States.kTurnOff then
			state = cached_state
		end
		self:saveState2Server(state)

		if __WIN32 or isDeveloper() then
			state = WifiAutoDownloadManager.States.kTurnOff
		end
	end

	if __IOS or __WP8  then
		state = WifiAutoDownloadManager.States.kInvisible	
	end

	self.state = state

	self.eventDispacher = EventDispatcher.new()
	local funcs = {'dp', 'he', 'hn', 'ad', 'rm', 'rma'}
	for _, funcName in pairs(funcs) do
		self[funcName] = function ( _, ... )
			self.eventDispacher[funcName](self.eventDispacher, ...)
		end
	end
end

function WifiAutoDownloadManager:getState( ... )
	return self.state
end

function WifiAutoDownloadManager:isTurnOn( ... )
	if UserManager:getInstance().updateInfo and UserManager:getInstance().updateInfo.grayscale then
		return false
	end
	
	return self:getState() == WifiAutoDownloadManager.States.kTurnOn
end

function WifiAutoDownloadManager:isTurnOff( ... )
	return self:getState() == WifiAutoDownloadManager.States.kTurnOff
end

function WifiAutoDownloadManager:turnOn( ... )
	self:setState(WifiAutoDownloadManager.States.kTurnOn)
end

function WifiAutoDownloadManager:turnOff( ... )
	self:setState(WifiAutoDownloadManager.States.kTurnOff)
end

function WifiAutoDownloadManager:setState( newState )

	if self.state ~= newState then

		self.state = newState

		--modify 状态写入userLocalLogic
		-- CCUserDefault:sharedUserDefault():setStringForKey(getUserKey('WifiAutoDownloadManager.state'), self.state)

		self:saveState2Server(self.state)

		self:dp(Event.new(WifiAutoDownloadManager.Events.kStateChange))

	end
end

function WifiAutoDownloadManager:saveState2Server( state )
	local is_visible
	local is_turn_on

	if state == WifiAutoDownloadManager.States.kTurnOn then
		is_visible = true
		is_turn_on = true
	elseif state == WifiAutoDownloadManager.States.kTurnOff then
		is_visible = true
		is_turn_on = false
	elseif state == WifiAutoDownloadManager.States.kInvisible then
		is_visible = false
		is_turn_on = false
	end

	if is_visible ~= UserManager:getInstance():hasBAFlag(kBAFlagsIdx.kWifiAutoDownloadSwitch_1) then
		UserLocalLogic:setBAFlagWrapper(kBAFlagsIdx.kWifiAutoDownloadSwitch_1, is_visible)
	end

	if is_turn_on ~= UserManager:getInstance():hasBAFlag(kBAFlagsIdx.kWifiAutoDownloadSwitch_2) then
		UserLocalLogic:setBAFlagWrapper(kBAFlagsIdx.kWifiAutoDownloadSwitch_2, is_turn_on)
	end
end

function WifiAutoDownloadManager:canTrigger( ... )
	if UserManager:getInstance().updateInfo and UserManager:getInstance().updateInfo.grayscale then
		return false
	end


	local topLevel = 0
	if UserManager:getInstance().user then
		topLevel = UserManager:getInstance().user:getTopLevelId()	
	end
	return __ANDROID and (tonumber(topLevel) or 0) >= 20 and (not self:hadTriggered())
end

function WifiAutoDownloadManager:hadTriggered( ... )



	-- local key = getUserKey('WifiAutoDownloadManager.triggered')
	-- return CCUserDefault:sharedUserDefault():getBoolForKey(key) == true


	--modify 状态不是 不可见 就认为这玩家触发过了

	return self:getState() ~= WifiAutoDownloadManager.States.kInvisible
end

function WifiAutoDownloadManager:trigger( ... )

	-- local key = getUserKey('WifiAutoDownloadManager.triggered')
	-- CCUserDefault:sharedUserDefault():setBoolForKey(key, true)

	--modify

	self:setState(WifiAutoDownloadManager.States.kTurnOn)
end

function WifiAutoDownloadManager:getDcState()


	local is_visible = UserManager:getInstance():hasBAFlag(kBAFlagsIdx.kWifiAutoDownloadSwitch_1)
	local is_turn_on = UserManager:getInstance():hasBAFlag(kBAFlagsIdx.kWifiAutoDownloadSwitch_2)

	if is_visible and is_turn_on then
		return 3
	elseif is_visible and (not is_turn_on) then
		return 2
	else
		return 1
	end
end

return WifiAutoDownloadManager