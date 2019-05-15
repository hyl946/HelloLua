local Quest = require 'zoo.quest.Quest'

local QIKillAnimalInOneLevel = class(Quest)

function QIKillAnimalInOneLevel:registerAllListener( ... )
	self:registerListener(_G.QuestEventType.kAfterPassOrFailLevel, self.onPassOrFailLevel)
	self:registerListener(_G.QuestEventType.kAskForHelpAfterPassOrFailLevel, self.onPassOrFailLevel)
end

function QIKillAnimalInOneLevel:onPassOrFailLevel( event )

	if event:matchLevelType{GameLevelType.kHiddenLevel, GameLevelType.kMainLevel} then

		local data = event.data or {}
		local playInfo = GamePlayContext:getInstance():getPlayInfo()
		local killedNum = table.sum{
			playInfo['killed_animal_' .. 1],
			playInfo['killed_animal_' .. 2],
			playInfo['killed_animal_' .. 3],
			playInfo['killed_animal_' .. 4],
			playInfo['killed_animal_' .. 5],
			playInfo['killed_animal_' .. 6],
		}
		if killedNum >= self.data.relTarget then
			self.data.num = self.data.relTarget
			self:afterUpdate()
			self:checkFinish()
		end
	end
end


function QIKillAnimalInOneLevel:doAction( ... )
	return false
end

function QIKillAnimalInOneLevel:createIcon( ... )
	return Layer:create()
end

return QIKillAnimalInOneLevel