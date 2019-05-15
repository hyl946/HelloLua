
require "plua.simpleClass"

myActionManager = simple_class()

function myActionManager:ctor()
	self.actionList = {}
	self.uuIndex = 1
end

function myActionManager:addAction(action)
	self.actionList[self.uuIndex] = action
	self.uuIndex = self.uuIndex + 1
end

function myActionManager:update(dt)
	local clearKey = {}
	for k, v in pairs(self.actionList) do
		local finish = v:update(dt)
		if finish then
			clearKey[#clearKey + 1] = k
		end
	end
	
	for k, v in ipairs(clearKey) do
		self.actionList[clearKey[k]] = nil
	end
end

function myActionManager:removeAllActionsFromTarget(node)
	local clearKey = {}
	for k, v in pairs(self.actionList) do
		if v.node == node then
			clearKey[#clearKey + 1] = k
		end
	end
	
	for k, v in ipairs(clearKey) do
		self.actionList[clearKey[k]] = nil
	end
end

function myActionManager:stopAction(action)
	for k, v in pairs(self.actionList) do
		if v == action then
			self.actionList[k] = nil
			break
		end
	end
end

function myActionManager:removeActionByTag(tag, node)
	local clearKey = {}
	for k, v in pairs(self.actionList) do
		if v.node == node then
			clearKey[#clearKey + 1] = k
		end
	end
	
	for k, v in ipairs(clearKey) do
		if self.actionList[clearKey[k]].tag == tag then
			self.actionList[clearKey[k]] = nil
		end
	end
end

function myActionManager:getActionByTag(tag, node)
	local clearKey = {}
	for k, v in pairs(self.actionList) do
		if v.node == node then
			clearKey[#clearKey + 1] = k
		end
	end
	
	for k, v in ipairs(clearKey) do
		if self.actionList[clearKey[k]].tag == tag then
			return self.actionList[clearKey[k]]
		end
	end
end

function myActionManager:numberOfRunningActionsInTarget(node)
	local clearKey = {}
	for k, v in pairs(self.actionList) do
		if v.node == node then
			clearKey[#clearKey + 1] = k
		end
	end
	return #clearKey
end

function myActionManager.myCreate()
	local mgr = myActionManager.new()
	return mgr
end

local instance = nil
function myActionManager.getInstance()
	if not instance then
		instance = myActionManager.myCreate()
	end
	return instance
end