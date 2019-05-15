local Quest = require 'zoo.quest.Quest'

local QIBegEnergyFromFriends = class(Quest)

function QIBegEnergyFromFriends:registerAllListener( ... )
	self:registerListener(_G.QuestEventType.kAfterEnergyRequest, self.afterEnergyRequest)
end

function QIBegEnergyFromFriends:afterEnergyRequest( event )
	self.data.num = self.data.num + 1
	self.data.num = math.min(self.data.num, self.data.relTarget)	
	self:afterUpdate()
	self:checkFinish()
end

function QIBegEnergyFromFriends:doAction( ... )
	return false
end

function QIBegEnergyFromFriends:createIcon( ... )
	return Layer:create()
end

return QIBegEnergyFromFriends