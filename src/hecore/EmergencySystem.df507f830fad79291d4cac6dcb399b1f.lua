
kEmergencyEvents = {
	kAFHNewCaller = "1",
    kAFHSuccessEvent = "2",
	kNeedForceUploadReplay = "3",
    kAchievementEvent = "achievementEvent",
}

-----------------------------------------------------------------
local PriorityQueue = class()

function PriorityQueue:ctor()
	self.datas = {}
end

function PriorityQueue:push(item)
	table.insert(self.datas, item)
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
	self.datas = {}
end
------------------------------------------------------------------------------------------
local instance = nil
EmergencySystem = class(EventDispatcher)
function EmergencySystem:getInstance()
	if instance == nil then 
        instance = EmergencySystem.new() 
        instance:init()
    end
	return instance
end

function EmergencySystem:init()
    self.isEnable = false
    self.queue = PriorityQueue.new()
    GlobalEventDispatcher:getInstance():addEventListener(kGlobalEvents.kEmergency, self.onEmergencyEvent)
end

function EmergencySystem:enable(isEnable)
    self.isEnable = isEnable
    if self.isEnable then
        for i=1, self.queue:size() do
            local resp = self.queue:pop()
            self.execute(resp)
        end
    end
end

function EmergencySystem.onEmergencyEvent(evt)
    local response = evt.data
    if response.endpoint and response.data then
        if instance.isEnable then
            instance.execute(response)
        else
            response.data._isCached = true
            instance.queue:push(response)
        end
    end
end

function EmergencySystem.execute(resp)
    local etype = resp.data.type or 0
    if etype > 0 and resp.endpoint == "commonEvent" then
        local data =  table.deserialize(resp.data.params) or {}
        EventDispatcher.dispatchEvent(instance, Event.new(tostring(etype), data))
    else
        if resp.endpoint and resp.data then
	        EventDispatcher.dispatchEvent(instance, Event.new(resp.endpoint, resp.data))
        end
    end
end