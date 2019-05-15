local Quest = require 'zoo.quest.Quest'

local QIKillEffectInOneLevel = class(Quest)

function QIKillEffectInOneLevel:registerAllListener( ... )
	self:registerListener(_G.QuestEventType.kAfterPassOrFailLevel, self.onPassOrFailLevel)
	self:registerListener(_G.QuestEventType.kAskForHelpAfterPassOrFailLevel, self.onPassOrFailLevel)
end

function QIKillEffectInOneLevel:onPassOrFailLevel( event )

	if event:matchLevelType{GameLevelType.kHiddenLevel, GameLevelType.kMainLevel} then

		local data = event.data or {}
		local playInfo = GamePlayContext:getInstance():getPlayInfo()
		local killedNum = table.sum{
			GamePlayContext:getInstance():getPlayInfoKilledBird(),
			GamePlayContext:getInstance():getPlayInfoKilledLine(),
			GamePlayContext:getInstance():getPlayInfoKilledWrap(),
		}

		if killedNum >= self.data.relTarget then
			self.data.num = self.data.relTarget
			self:afterUpdate()
			self:checkFinish()
		end
	end
end

function QIKillEffectInOneLevel:doAction( ... )
	return false
end

function QIKillEffectInOneLevel:createIcon( ... )
	return Layer:create()
end

return QIKillEffectInOneLevel