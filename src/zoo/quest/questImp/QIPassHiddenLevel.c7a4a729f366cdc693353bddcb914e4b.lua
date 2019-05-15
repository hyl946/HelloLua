local Quest = require 'zoo.quest.Quest'

local QIPassHiddenLevel = class(Quest)

function QIPassHiddenLevel:registerAllListener( ... )
	self:registerListener(_G.QuestEventType.kAfterPassOrFailLevel, self.onPassOrFailLevel)
end

function QIPassHiddenLevel:onPassOrFailLevel( event )
	local data = event.data or {}
	if event:isPassLevel() then
		if event:matchLevelType{GameLevelType.kHiddenLevel} then
			self.data.num = self.data.num + 1
			self.data.num = math.min(self.data.num, self.data.relTarget)

			self:afterUpdate()
			self:checkFinish()
		end
	end
end

function QIPassHiddenLevel:doAction( ... )
	return require('zoo.quest.actions.PlayLevelAction'):doAction{GameLevelType.kHiddenLevel}
end

function QIPassHiddenLevel:createIcon( ... )
	local UIHelper = require 'zoo.panel.UIHelper'
	local icon = UIHelper:createSpriteFrame('flash/quest-icon.json', 'quest-icon-dir/20000')
	icon:setScale(0.8)
	return icon
end

function QIPassHiddenLevel:hasEndGameTip( levelId, levelType )
	return levelType == GameLevelType.kHiddenLevel
end

function QIPassHiddenLevel:getEndGameTip( params )
	return '1'
end

return QIPassHiddenLevel