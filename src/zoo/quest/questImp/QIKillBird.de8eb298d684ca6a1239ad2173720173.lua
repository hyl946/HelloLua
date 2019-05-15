local Quest = require 'zoo.quest.Quest'

local QIKillBird = class(Quest)

function QIKillBird:registerAllListener( ... )
	self:registerListener(_G.QuestEventType.kAfterPassOrFailLevel, self.onPassOrFailLevel)
	self:registerListener(_G.QuestEventType.kAskForHelpAfterPassOrFailLevel, self.onPassOrFailLevel)
end

function QIKillBird:onPassOrFailLevel( event )
	local data = event.data or {}

	if event:matchLevelType{GameLevelType.kHiddenLevel, GameLevelType.kMainLevel} then
		local killedNum = GamePlayContext:getInstance():getPlayInfoKilledBird()

		if killedNum > 0 then
			self.data.num = self.data.num + killedNum
			self.data.num = math.min(self.data.num, self.data.relTarget)

			self:afterUpdate()
			self:checkFinish()
		end
	end

end

function QIKillBird:doAction( ... )
	return require('zoo.quest.actions.PlayLevelAction'):doAction{GameLevelType.kMainLevel, GameLevelType.kHiddenLevel}
end

function QIKillBird:createIcon( ... )
	-- body
	local sp = ResourceManager:sharedInstance():buildItemSpriteWithDecorate(ItemType.PRE_RANDOM_BIRD)
	sp:setScale(0.8)
	return sp

end

return QIKillBird