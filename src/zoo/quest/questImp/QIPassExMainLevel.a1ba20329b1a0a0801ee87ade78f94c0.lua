local Quest = require 'zoo.quest.Quest'

local QIPassExMainLevel = class(Quest)

function QIPassExMainLevel:registerAllListener( ... )
	self:registerListener(_G.QuestEventType.kAfterPassOrFailLevel, self.onLevelUp)
	self:registerListener(_G.QuestEventType.kAfterLevelUp, self.onLevelUp)
end

function QIPassExMainLevel:decode( rawData )
	Quest.decode(self, rawData)
	self.data.cacheTopLevel = self:getPassedExTopestLevel() or 0
	self.data.init = rawData.init or 0
end

function QIPassExMainLevel:encode( ... )
	return {
		relTarget = self.data.relTarget,
		num = self.data.num,
		init = self.data.init,
	}
end

function QIPassExMainLevel:getDesc( ... )
	-- body
	if self.moduleId > 0 then
		return localize('quest.desc.' .. self._type .. ':' .. self.moduleId, {
			relTarget = self.data.relTarget + self.data.init,
		})
	end

	return localize('quest.desc.' .. self._type, {
		relTarget = self.data.relTarget + self.data.init,
	})
end


function QIPassExMainLevel:onLevelUp( event )
	if self:getPassedExTopestLevel() > self.data.cacheTopLevel then
		self.data.num = self.data.num + self:getPassedExTopestLevel() - self.data.cacheTopLevel
		self.data.num = math.min(self.data.num, self.data.relTarget)
		self.data.cacheTopLevel = self:getPassedExTopestLevel()
		self:afterUpdate()
		self:checkFinish()
	end
end

function QIPassExMainLevel:getPassedExTopestLevel( ... )
	-- body
	local toplevel = UserManager:getInstance().user:getTopLevelId()
	if UserManager:getInstance():hasPassedLevelEx(toplevel) then
		return toplevel
	else
		return toplevel - 1
	end
end

function QIPassExMainLevel:doAction( ... )
	return false
end

function QIPassExMainLevel:createIcon( ... )
	return LayerColor:create()
end

return QIPassExMainLevel