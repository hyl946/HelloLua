local Quest = require 'zoo.quest.Quest'

local QIPassTopLevelContinuously = class(Quest)

function QIPassTopLevelContinuously:registerAllListener( ... )
	self:registerListener(_G.QuestEventType.kAfterPassOrFailLevel, self.onPassOrFailLevel)
	self:registerListener(_G.QuestEventType.kAfterQuitLevel, self.afterGiveUp)
	self:registerListener(_G.QuestEventType.kAfterReplayLevel, self.afterGiveUp)
end

function QIPassTopLevelContinuously:onPassOrFailLevel( event )
	local data = event.data or {}
	if event:matchLevelType{GameLevelType.kMainLevel} then
		if event:isPassNewLevel() then
			self.data.num = self.data.num + 1
			self.data.num = math.min(self.data.num, self.data.relTarget)
			self:afterUpdate()
			self:checkFinish()
			return
		else

			if (not event:isPassLevel()) and (not event:hasPassed()) then
				self.data.num = 0
				self:afterUpdate()
			end

		end
	end

	
end

function QIPassTopLevelContinuously:afterGiveUp( ... )
	self.data.num = 0
	self:afterUpdate()
end

function QIPassTopLevelContinuously:doAction( ... )
	return require('zoo.quest.actions.PlayLevelAction'):doAction({GameLevelType.kMainLevel}, true)
end

function QIPassTopLevelContinuously:createIcon( ... )
	local UIHelper = require 'zoo.panel.UIHelper'
	local icon = UIHelper:createSpriteFrame('flash/quest-icon.json', 'quest-icon-dir/90000')
	icon:setScale(0.8)
	return icon
end

function QIPassTopLevelContinuously:hasEndGameTip( levelId, levelType )
	return levelType == GameLevelType.kMainLevel and UserManager:getInstance():hasPassedLevelEx(levelId) == false
end

function QIPassTopLevelContinuously:getEndGameTip( params )
	return '1'
end

return QIPassTopLevelContinuously