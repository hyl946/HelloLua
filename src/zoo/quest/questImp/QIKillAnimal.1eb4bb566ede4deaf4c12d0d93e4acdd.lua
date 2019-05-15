local Quest = require 'zoo.quest.Quest'

local QIKillAnimal = class(Quest)

function QIKillAnimal:decode( rawData )
	Quest.decode(self, rawData)
	self.data.color = tonumber(rawData.data.color) or 1
end

function QIKillAnimal:encode( ... )
	return {
		relTarget = self.data.relTarget,
		num = self.data.num,
		data = {color = self.data.color},
	}
end

function QIKillAnimal:registerAllListener( ... )
	self:registerListener(_G.QuestEventType.kAfterPassOrFailLevel, self.onPassOrFailLevel)
	self:registerListener(_G.QuestEventType.kAskForHelpAfterPassOrFailLevel, self.onPassOrFailLevel)
end

function QIKillAnimal:onPassOrFailLevel( event )

	if event:matchLevelType{GameLevelType.kHiddenLevel, GameLevelType.kMainLevel} then

		local data = event.data or {}
		local playInfo = GamePlayContext:getInstance():getPlayInfo()
		local killedNum = table.sum{
			playInfo['killed_animal_' .. self.data.color]
		}
		if killedNum > 0 then
			self.data.num = self.data.num + killedNum
			self.data.num = math.min(self.data.num, self.data.relTarget)
			self:afterUpdate()
			self:checkFinish()
		end
	end
end


function QIKillAnimal:doAction( ... )
	return require('zoo.quest.actions.PlayLevelAction'):doAction{GameLevelType.kMainLevel, GameLevelType.kHiddenLevel}
end



function QIKillAnimal:getDesc( ... )
	return localize('quest.desc.' .. self._type, {
		relTarget = self.data.relTarget,
		animal = localize('animal.display.name.' .. self.data.color),
	})
end

function QIKillAnimal:createIcon( ... )
	
	local spFrameName = 'chicken_selected_0001'

	if self.data.color == 1 then
		spFrameName = 'horse_selected_0001'
	elseif self.data.color == 2 then
		spFrameName = 'frog_selected_0001'
	elseif self.data.color == 3 then
		spFrameName = 'bear_selected_0001'
	elseif self.data.color == 4 then
		spFrameName = 'cat_selected_0001'
	elseif self.data.color == 5 then
		spFrameName = 'fox_selected_0001'
	elseif self.data.color == 6 then
		spFrameName = 'chicken_selected_0001'
	end
	return Sprite:createWithSpriteFrameName(spFrameName)
end

return QIKillAnimal