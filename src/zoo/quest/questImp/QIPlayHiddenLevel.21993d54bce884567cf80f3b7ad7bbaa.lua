local Quest = require 'zoo.quest.Quest'

local QIPlayHiddenLevel = class(Quest)

function QIPlayHiddenLevel:registerAllListener( ... )
	self:registerListener(_G.QuestEventType.kAfterPassOrFailLevel, self.onPassOrFailLevel)
end

function QIPlayHiddenLevel:onPassOrFailLevel( event )
	local data = event.data or {}
	if event:matchLevelType{GameLevelType.kHiddenLevel} then
		self.data.num = self.data.num + 1
		self.data.num = math.min(self.data.num, self.data.relTarget)
		
		self:afterUpdate()
		self:checkFinish()
	end
end

function QIPlayHiddenLevel:doAction( ... )
	return require('zoo.quest.actions.PlayLevelAction'):doAction{GameLevelType.kHiddenLevel}
end

function QIPlayHiddenLevel:createIcon( ... )
	local UIHelper = require 'zoo.panel.UIHelper'
	local icon = UIHelper:createSpriteFrame('flash/quest-icon.json', 'quest-icon-dir/60000')
	icon:setScale(0.8)
	return icon
end

return QIPlayHiddenLevel