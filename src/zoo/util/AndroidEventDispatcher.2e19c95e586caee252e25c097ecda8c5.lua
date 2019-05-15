AndroidEventDispatcher = class(EventDispatcher)

local _instance = nil
function AndroidEventDispatcher:getInstance()
	if not _instance then 
		_instance = AndroidEventDispatcher.new()
	end
	return _instance
end

function AndroidEventDispatcher:initDispatcher()
	if self.hasInited then return end
	self.hasInited = true
	local context = self
	local delegate = luajava.createProxy("com.happyelements.android.utils.EventDispatchCenterImpl", {
		dispatchEvent = function(eventName, dataMap)
			if context then
				local data = nil
				if dataMap then data = luaJavaConvert.map2Table(dataMap) end
				-- if _G.isLocalDevelopMode then printx(0, ">>>>>>>>>>>>>>AndroidEventDispatcher dispatchEvent:", eventName, table.tostring(data)) end
				context:dispatchEvent(DisplayEvent.new(eventName, data))
			end
		end
		})
	local eventDispatchCenter = luajava.bindClass("com.happyelements.android.utils.EventDispatchCenter"):getInstance()
	eventDispatchCenter:initWithImpl(delegate)
end
