-------------------------------------------------------------------------
--  Class include: Events, Event, DisplayEvents, DisplayEvent, EventDispatcher, GlobalEventDispatcher
-------------------------------------------------------------------------


require "hecore.class"

local profiler = require("hecore/profiler")

local debugEvent =false;

--
-- Events ---------------------------------------------------------
--
-- common event name we used in library.
Events = {
	kComplete = "complete",
	kCancel = "cancel",
	kConnect = "connect",
	kConfirm = "confirm",
	kError = "error",
	kStart = "start",
	kClose = "close",
	kAddToStage = "addToStage",
	kRemoveFromStage = "removeFromStage",
	kDispose = "disposing",
	kProgress = "progress"
}

SceneEvents = {
	kEnterForeground = "enterForeground",
	kEnterBackground = "enterBackground"
}
--
-- Event ---------------------------------------------------------
--

Event = class();
function Event:ctor(name, data, target)
	self.name  = name;
	self.data = data;
	self.target = target;
	self.code = 0;
	self.context = nil;
end
function Event:dispose()
	self.name = nil;
	self.target = nil;
	self.data = nil;
	self.context = nil;
end
function Event:toString()
	return string.format("Event [%s]", self.name and self.name or "nil");
end

--
-- DisplayEvents ---------------------------------------------------------
--

DisplayEvents = {
-- touch
	kTouchBegin = "touchBegin",
	kTouchEnd = "touchEnd",
	kTouchMove = "touchMove",
	
	kTouchTap = "touchTap",

	kTouchItem = "touchItem",

	kTouchMoveIn	= "touchMoveIn",
	kTouchMoveOut	= "touchMoveOut",

	kTouchBeginOutSide	= "touchBeginoutSide"
};

EmergencyEvents = {
	kAFHNewCaller = "askSubstituteEvent",    -- has new caller
	kAFHSuccessEvent = "SubstituteSuccessEvent",
	kAchievementEvent = "achievementEvent",
};

--
-- DisplayEvent ---------------------------------------------------------
--
DisplayEvent = class(Event);

function DisplayEvent:ctor(name, target, globalPosition, id)
	self.class = DisplayEvent;

	self.name  = name;
	self.data = nil;
	self.target = target;
	self.globalPosition = globalPosition;
	self.propagation = true;

	self.id = id
end

--Prevents processing of any event listeners in nodes subsequent to the current node in the event flow.
function DisplayEvent:stopPropagation()
    self.propagation = false;
end

function DisplayEvent:toString()
	return string.format("DisplayEvent [%s]", self.name and self.name or "nil");
end

function DisplayEvent:clone()
	local evt = DisplayEvent.new(self.name, self.target);
	return evt;
end

--
-- EventDispatcher ---------------------------------------------------------
--

-- members
EventDispatcher = class();

-- initialize
function EventDispatcher:ctor()
	self.class = EventDispatcher;
	self.receivers  = {}; -- of <{function,function...}>
end

-- public methods
function EventDispatcher:toString()
	return "EventDispatcher";
end

--Dispatches an event into the event flow.
function EventDispatcher:dispatchEvent(event)
	if debugEvent then
		if _G.isLocalDevelopMode then printx(0, "EventDispatcher:dispatchEvent", event.name, event.data, event.target) end;
	end
	local eventName = event.name;
	if not eventName then return end;

	local list = self.receivers[eventName]; --of <function>

	if (not list) or type(list) ~= "table" then return end;

	-- by default, iterator throw a table is a non-atom operation,
	-- to avoid modify table while iteration (by callback), we need a atom-table or just clone the old one as I did.
	local cached = {};
	for k, v in ipairs(list) do
		cached[k] = v;
	end

	for k, v in ipairs(cached) do
	    event.context = nil;
	    if v[2] then event.context = v[2] end;

		if(profiler.enabled) then
			local t1 = os.clock()
			v[1](event);
			local cost = os.clock() - t1
			local info = debug.getinfo(v[1])
			local key = info.source .. ":" .. info.linedefined .. ":" .. k
			profiler:add(key, cost)
		else
			v[1](event);
		end

		 event.context = nil;
	end
end

--Checks whether the EventDispatcher object has any listeners registered for a specific type of event.
function EventDispatcher:hasEventListener(eventName, listener)
	if not eventName then
		return false;
	end

	if self.receivers then
		local list = self.receivers[eventName]; --of <function>
		if not list then return false end;

		for i, v in ipairs(list) do
			if v[1] == listener then return true, i end;
		end
	end

	return false;
end

--Checks whether the EventDispatcher object has any listeners registered for a specific type of event.
function EventDispatcher:hasEventListenerByName(eventName)
	if not eventName then
		return false;
	end

	if self.receivers then
		local list = self.receivers[eventName]; --of <function>
		if list and table.getn(list) > 0 then
			return true;
		end
	end

	return false;
end


--Registers an event listener object with an EventDispatcher object so that the listener receives notification of an event.
function EventDispatcher:addEventListener(eventName, listener, context)
	assert(eventName, "EventDispatcher:addEventListener : parameter event name is nil !")
	assert(listener, "EventDispatcher:addEventListener : parameter listener is nil !")

	if debugEvent then
		if _G.isLocalDevelopMode then printx(0, "EventDispatcher:addEventListener", eventName, listener) end;
	end

	if (not eventName) or (not listener) or (not self.receivers) then 
		assert(false)
		return 
	end;

	local bool = self:hasEventListener(eventName, listener);
	if bool then
		if debugEvent then
			if _G.isLocalDevelopMode then printx(0, "EventDispatcher:addEventListener event already add") end;
		end
	else
		local list = self.receivers[eventName]; --of <function>
		if (not list) or type(list) ~= "table" then
			list = {};
			self.receivers[eventName] = list;
		end
		table.insert(list, {listener, context});
	end
end


--Removes a listener from the EventDispatcher object.
function EventDispatcher:removeEventListener(eventName, listener, ...)
	assert(eventName)
	assert(listener)
	assert(#{...})

	if debugEvent then
		if _G.isLocalDevelopMode then printx(0, "EventDispatcher:removeEventListener", eventName, listener) end;
	end

	if (not eventName) or (not listener) or (not self.receivers) then 
		assert(false)
		return 
	end;

	local bool, i = self:hasEventListener(eventName, listener);
	--assert(bool)
	if bool then
		local list = self.receivers[eventName]; --of <function>
		table.remove(list, i);
	end
end


--Removes a listener from the EventDispatcher object.
function EventDispatcher:removeEventListenerByName(eventName)
	if debugEvent then
		if _G.isLocalDevelopMode then printx(0, "EventDispatcher:removeEventListenerByName", eventName) end;
	end
	if (not eventName) or (not self.receivers) then return end;
	self.receivers[eventName] = nil;
end

function EventDispatcher:removeAllEventListeners()
	local list = self.receivers;
	for k, v in pairs(list) do
		self.receivers[k] = nil;
	end
end

--atlis
EventDispatcher.dp = EventDispatcher.dispatchEvent
EventDispatcher.he = EventDispatcher.hasEventListener
EventDispatcher.hn = EventDispatcher.hasEventListenerByName
EventDispatcher.ad = EventDispatcher.addEventListener
EventDispatcher.rm = EventDispatcher.removeEventListener
EventDispatcher.rma = EventDispatcher.removeAllEventListeners

--
-- GlobalEventDispatcher ---------------------------------------------------------
--
local instance = nil
GlobalEventDispatcher = class(EventDispatcher)
function GlobalEventDispatcher:getInstance()
	if instance == nil then instance = GlobalEventDispatcher.new() end
	return instance
end

local pendingCallbackMap = {} --category, list

function GlobalEventDispatcher:flush(category)
	local pendingCallbackList = pendingCallbackMap[category]
	pendingCallbackMap[category] = {}

	if(pendingCallbackList) then
		for i = 1, #pendingCallbackList do
			local event = pendingCallbackList[i]
			EventDispatcher.dispatchEvent(self, event)
		end
	end
end

function GlobalEventDispatcher:dispatchEvent(event)
	EventDispatcher.dispatchEvent(self, event)
end


function GlobalEventDispatcher:dispatchEventDeferral(event, category)
	local pendingCallbackList = pendingCallbackMap[category]
	if(pendingCallbackList == nil) then
		pendingCallbackList = {}
		pendingCallbackMap[category] = pendingCallbackList
	end
	pendingCallbackList[#pendingCallbackList + 1] = event
end


