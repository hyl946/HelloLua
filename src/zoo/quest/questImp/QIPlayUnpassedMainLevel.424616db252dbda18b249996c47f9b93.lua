local Quest = require 'zoo.quest.Quest'

local QIPlayUnpassedMainLevel = class(Quest)

function QIPlayUnpassedMainLevel:registerAllListener( ... )
	self:registerListener(_G.QuestEventType.kAfterPassOrFailLevel, self.onPassOrFailLevel)

	
	-- self:registerListener(_G.QuestEventType.kAskForHelpAfterPassOrFailLevel, self.onPassOrFailLevel)
	self:registerListener(_G.QuestEventType.kAfterAFHSuccess, self.afterAFHSucess)
end

function QIPlayUnpassedMainLevel:onPassOrFailLevel( event )
	local data = event.data or {}
	if event:matchLevelType{GameLevelType.kMainLevel} then
		if not event:hasPassed() then
			self.data.num = self.data.num + 1
			self.data.num = math.min(self.data.num, self.data.relTarget)
			self:afterUpdate()
			self:checkFinish()
		end
	end

	if (not self:isFinished()) and self:isUserFullLevel() then
		self.data.num = self.data.relTarget
		self:afterUpdate()
		self:checkFinish()
	end

end

function QIPlayUnpassedMainLevel:afterAFHSucess( ... )
	if (not self:isFinished()) and self:isUserFullLevel() then
		self.data.num = self.data.relTarget
		self:afterUpdate()
		self:checkFinish()
	end
end

function QIPlayUnpassedMainLevel:isUserFullLevel( ... )
	return UserManager:getInstance():isGlobalFullLevel()
end

function QIPlayUnpassedMainLevel:doAction( ... )
	return require('zoo.quest.actions.PlayLevelAction'):doAction{GameLevelType.kMainLevel}
end

function QIPlayUnpassedMainLevel:createIcon( ... )
	local UIHelper = require 'zoo.panel.UIHelper'
	local icon = UIHelper:createSpriteFrame('flash/quest-icon.json', 'quest-icon-dir/50000')
	icon:setScale(0.8)
	return icon
end

return QIPlayUnpassedMainLevel