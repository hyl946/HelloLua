local Quest = require 'zoo.quest.Quest'

local QIKillLine = class(Quest)

function QIKillLine:registerAllListener( ... )
	self:registerListener(_G.QuestEventType.kAfterPassOrFailLevel, self.onPassOrFailLevel)
	self:registerListener(_G.QuestEventType.kAskForHelpAfterPassOrFailLevel, self.onPassOrFailLevel)
end

function QIKillLine:onPassOrFailLevel( event )
	local data = event.data or {}

	if event:matchLevelType{GameLevelType.kHiddenLevel, GameLevelType.kMainLevel} then

		local killedNum = GamePlayContext:getInstance():getPlayInfoKilledLine()

		if killedNum > 0 then
			self.data.num = self.data.num + killedNum
			self.data.num = math.min(self.data.num, self.data.relTarget)
			self:afterUpdate()
			self:checkFinish()
		end
	end

end

function QIKillLine:doAction( ... )
	return require('zoo.quest.actions.PlayLevelAction'):doAction{GameLevelType.kMainLevel, GameLevelType.kHiddenLevel}
end



function QIKillLine:createIcon( ... )
	-- body
	local sp = ResourceManager:sharedInstance():buildItemSpriteWithDecorate(ItemType.PRE_LINE_BOMB)
	sp:setScale(0.8)
	return sp

end

return QIKillLine