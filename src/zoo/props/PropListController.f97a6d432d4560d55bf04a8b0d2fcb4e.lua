PropListController = class()

function PropListController:ctor()
	self.propList = nil
end

function PropListController:init(propList)
	self.propList = propList
end