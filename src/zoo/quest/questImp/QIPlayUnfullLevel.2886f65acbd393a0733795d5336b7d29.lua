local isUserFullStar = require('zoo.quest.misc.misc').isUserFullStar

local Quest = require 'zoo.quest.Quest'

local QIPlayUnfullLevel = class(Quest)

function QIPlayUnfullLevel:registerAllListener( ... )
	self:registerListener(_G.QuestEventType.kAfterPassOrFailLevel, self.onPassOrFailLevel)
end

function QIPlayUnfullLevel:onPassOrFailLevel( event )
	local data = event.data or {}
	if event:matchLevelType{GameLevelType.kMainLevel, GameLevelType.kHiddenLevel} then
		if event:hasPassed() and event:isUnfullStarBeforeThisPlay() then
			self.data.num = self.data.num + 1
			self.data.num = math.min(self.data.num, self.data.relTarget)
			self:afterUpdate()
			self:checkFinish()
		end
	end

	if (not self:isFinished()) and isUserFullStar() then
		self.data.num = self.data.relTarget
		self:afterUpdate()
		self:checkFinish()
	end

end

function QIPlayUnfullLevel:doAction( ... )
	return false
end

function QIPlayUnfullLevel:createIcon( ... )
	return Layer:create()
end

return QIPlayUnfullLevel