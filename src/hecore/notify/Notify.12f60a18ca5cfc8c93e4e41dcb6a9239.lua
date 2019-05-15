--[[
 * @Author  zhou.ding 
 * @Date    2017-02-22 10:47:28
 * @Email 	zhou.ding@happyelements.com
--]]

--[[
* usage:
  在NotifyEvent中配置事件：TEST_EVENT
  一，注册单个函数
  1,注册事件
  	local cb = function (p1, p2)
  		if _G.isLocalDevelopMode then printx(0, p1 + p2) end 
  	end
  	Notify:register( Notify.TEST_EVENT, cb )
  2,派发事件
  	Notify:dispatchOnce( Notify.TEST_EVENT,10, 98 )

  二，注册对象函数
  1,注册事件
  	local object = {}
  	function object:print(p1, p2)
  		if self.debug then
	  		if _G.isLocalDevelopMode then printx(0, p1 + p2) end 
	  	end
  	end
  	Notify:register( Notify.TEST_EVENT, object.print, object)
  2,派发事件
  	Notify:dispatch( Notify.TEST_EVENT,10, 98 )

--]]

Notify = {
	Observer = {}
}

--[[
* 注册一个事件监听
* event:参照NotifyEvent,配置后自动生成的值(reuired)
* callback:事件触发后的回调(reuired)
* target:callback所属的对象(option)
--]]
function Notify:register( event, callback, target )
	if event == nil or callback == nil then
		return
	end

	local events = self.Observer[event]

	if events == nil then
		events = {}
		self.Observer[event] = events
	end

	if events[callback] == nil then
		events[callback] = target or 1
	end
end

--[[
* 取消一个事件的监听
* event:参照NotifyEvent,配置后自动生成的值(reuired)
* targetOrCallback:回调所属的对象或者callback
* 1,targetOrCallback == callback 取消callback的单个监听函数
* 2,targetOrCallback == target 取消target的单个监听函数
* 3,targetOrCallback == nil 取消所有event事件的监听函数
--]]

function Notify:unregister( event, targetOrCallback )
	if event == nil then return end

	if type(targetOrCallback) == "table" then
		local events = self.Observer[event]
		if events then
			for callback,t in pairs(events) do
				if t == targetOrCallback then
					events[callback] = nil
				end
			end
		end
	elseif event ~= nil and type(targetOrCallback) == "function" then
		local events = self.Observer[event]
		if events then
			events[targetOrCallback] = nil
		end
	elseif event ~= nil and targetOrCallback == nil then
		self.Observer[event] = nil
	end
	
end

function Notify:debugPrint( event )
	if _G.__DEBUG then
		local info = debug.getinfo(3, "Sln")
		local name = event

		if type(name) ~= "string" then
			for n,e in pairs(self.events) do
				if e == event then
			        name = n
					break
				end
			end
		end

		name = tostring(name)

		if info then
        	print(string.format("[Event] dispatch %s from %s function:%s line:%d", 
        										name, info.short_src, info.name, info.currentline))
        end
	end
end

--[[
* 派发一个事件
* 可带0个或多个参数
--]]
function Notify:dispatch( event,... )
	if event == nil then
		return
	end

	self:debugPrint(event)

	local events = self.Observer[event]
	if not events then return end

	for callback,target in pairs(events) do
		if type(target) ~= "number" then
			callback(target, ...)
		else
			callback(...)
		end
	end
end

--[[
* 派发一个事件,派发之后自动取消事件监听
* 可带0个或多个参数
--]]
function Notify:dispatchOnce( event, ... )
	self:dispatch(event, ...)
	self:unregister(event)
end

function Notify:__init__()
	local config = (require "hecore.notify.NotifyEvent")
	local events = config.events

	self.getNext = config.getNext
	self.events = events

	events.__index = events
	setmetatable(self, events)
end

function Notify:getNextEvent()
	return self:getNext()
end

Notify:__init__()