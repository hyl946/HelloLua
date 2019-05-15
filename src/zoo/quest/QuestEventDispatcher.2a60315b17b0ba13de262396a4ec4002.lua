require "hecore.EventDispatcher"

local QuestEventDispatcher = class(EventDispatcher)

function QuestEventDispatcher:ctor( ... )
	self.class = QuestEventDispatcher
end

function QuestEventDispatcher:toString( ... )
	return "QuestEventDispatcher"
end

function QuestEventDispatcher:dispatchEvent( event )
	EventDispatcher.dispatchEvent(self, event)
	local adapter = _G.QuestEvent.offlineHttpAdapterMap[event.name]
	if adapter then
		local endPoint, params = adapter(event)
		HttpBase:offlinePost(endPoint, params)
	end
end

local function bind( func, p )
	return function (...)
		return func(p, ...)
	end
end

function QuestEventDispatcher:addEventListener( eventName, listener, context )
	local l = bind(listener, context)
	EventDispatcher.addEventListener(self, eventName, l)	
	return l
end

QuestEventDispatcher.dp = QuestEventDispatcher.dispatchEvent
QuestEventDispatcher.ad = QuestEventDispatcher.addEventListener

_G.questEvtDp = QuestEventDispatcher.new()