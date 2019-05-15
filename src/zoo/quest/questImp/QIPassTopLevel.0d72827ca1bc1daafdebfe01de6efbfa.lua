local Quest = require 'zoo.quest.Quest'

local QIPassTopLevel = class(Quest)

function QIPassTopLevel:registerAllListener( ... )
	self:registerListener(_G.QuestEventType.kAfterPassOrFailLevel, self.onPassOrFailLevel)
end

function QIPassTopLevel:onPassOrFailLevel( event )
	local data = event.data or {}
	if event:matchLevelType{GameLevelType.kMainLevel} then
		if event:isPassNewLevel() then
			self.data.num = self.data.num + 1
			self.data.num = math.min(self.data.num, self.data.relTarget)

			self:afterUpdate()
			self:checkFinish()
		end
	end
end

function QIPassTopLevel:doAction( ... )
	return require('zoo.quest.actions.PlayLevelAction'):doAction({GameLevelType.kMainLevel}, true)
end


function QIPassTopLevel:createIcon( ... )
	local UIHelper = require 'zoo.panel.UIHelper'
	local icon = UIHelper:createSpriteFrame('flash/quest-icon.json', 'quest-icon-dir/10000')
	icon:setScale(0.8)
	return icon
end

function QIPassTopLevel:hasEndGameTip( levelId, levelType )
	return levelType == GameLevelType.kMainLevel and UserManager:getInstance():hasPassedLevelEx(levelId) == false
end

function QIPassTopLevel:getEndGameTip( params )
	return '1'
end

return QIPassTopLevel