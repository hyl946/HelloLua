local Quest = require 'zoo.quest.Quest'

local QIPlayMainLevel = class(Quest)

function QIPlayMainLevel:registerAllListener( ... )
	self:registerListener(_G.QuestEventType.kAfterPassOrFailLevel, self.onPassOrFailLevel)
	self:registerListener(_G.QuestEventType.kAskForHelpAfterPassOrFailLevel, self.onPassOrFailLevel)
end

function QIPlayMainLevel:onPassOrFailLevel( event )
	local data = event.data or {}
	if event:matchLevelType{GameLevelType.kMainLevel} then
		self.data.num = self.data.num + 1
		self.data.num = math.min(self.data.num, self.data.relTarget)
		
		self:afterUpdate()
		self:checkFinish()
	end
end

function QIPlayMainLevel:doAction( ... )
	return require('zoo.quest.actions.PlayLevelAction'):doAction{GameLevelType.kMainLevel}
end

function QIPlayMainLevel:createIcon( ... )
	local UIHelper = require 'zoo.panel.UIHelper'
	local icon = UIHelper:createSpriteFrame('flash/quest-icon.json', 'quest-icon-dir/50000')
	icon:setScale(0.8)
	return icon
end

return QIPlayMainLevel