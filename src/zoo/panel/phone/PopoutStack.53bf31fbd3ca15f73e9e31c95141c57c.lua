
local Input = require "zoo.panel.phone.Input"

PopoutStack = {}

local stack = {}
function PopoutStack:push( child, dark, enableTouchBehind )
	if #stack > 0 then
		if type(stack[#stack].child.becomeSecondStack) == "function" then
			stack[#stack].child:becomeSecondStack()
		end
		PopoutManager:remove(stack[#stack].child, false)
	end
	
	table.insert(stack,{ child = child, dark = dark, enableTouchBehind = enableTouchBehind })
	PopoutManager:add(child, dark, enableTouchBehind)
end

function PopoutStack:pop( ... )
	if #stack > 0 then
		PopoutManager:remove(stack[#stack].child,true)
		table.remove(stack,#stack)
	end
	if #stack > 0 then
		PopoutManager:add(stack[#stack].child, stack[#stack].dark, stack[#stack].enableTouchBehind)
		if type(stack[#stack].child.reBecomeTopStack) == "function" then
			stack[#stack].child:reBecomeTopStack()
		end
	end
end

function PopoutStack:replace( child, dark, enableTouchBehind )
	if #stack > 0 then
		PopoutManager:remove(stack[#stack].child,true)
		table.remove(stack,#stack)
	end

	table.insert(stack,{ child = child, dark = dark, enableTouchBehind = enableTouchBehind })
	PopoutManager:add(child, dark, enableTouchBehind)
end


function PopoutStack:clear( ... )
	if #stack > 0 then
		PopoutManager:remove(stack[#stack].child,true)
		table.remove(stack,#stack)
	end

	for k,v in pairs(stack) do
		v.child:dispose()
	end
	stack = {}
end

