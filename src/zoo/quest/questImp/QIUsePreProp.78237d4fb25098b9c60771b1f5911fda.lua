local Quest = require 'zoo.quest.Quest'

local QIUsePreProp = class(Quest)

function QIUsePreProp:registerAllListener( ... )
	self:registerListener(_G.QuestEventType.kUsePreProps, self.afterUsePreProps)

end

function QIUsePreProp:afterUsePreProps( event )

	local deltaNum = #(event.data.itemList or {})
	if deltaNum > 0 then
		self.data.num = self.data.num + deltaNum
		self.data.num = math.min(self.data.num, self.data.relTarget)
		self:afterUpdate()
		self:checkFinish()
	end
end

function QIUsePreProp:doAction( ... )
	return require('zoo.quest.actions.PlayLevelAction'):doAction{GameLevelType.kMainLevel, GameLevelType.kHiddenLevel}
end

function QIUsePreProp:createIcon( ... )
	-- body
	local sp = ResourceManager:sharedInstance():buildItemSpriteWithDecorate(10018)
	sp:setScale(0.8)
	return sp

end

return QIUsePreProp