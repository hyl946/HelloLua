require "plua.simpleClass"

myAction = simple_class()

function myAction:ctor()
	
end

function myAction:update(dt)
	
	if self.curFrame > 0 then
		if self.onFnished ~= nil then
			self.onFnished(self.node)
		end
		return true
	end
	self.curFrame = self.curFrame + 1
	return false
end

function myAction.myCreate(node, onFnished)
	local act = myAction.new()
	act.curFrame = 0
	act.node = node
	act.onFnished = onFnished
	return act
end