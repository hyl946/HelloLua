local Quest = require 'zoo.quest.Quest'

local QIPassMainLevelWithNStar = class(Quest)

function QIPassMainLevelWithNStar:decode( rawData )
	Quest.decode(self, rawData)
	self.data.star = tonumber(rawData.data.star) or 3
end


function QIPassMainLevelWithNStar:encode( ... )
	return {
		relTarget = self.data.relTarget,
		num = self.data.num,
		data = {star = self.data.star},
	}
end

function QIPassMainLevelWithNStar:registerAllListener( ... )
	self:registerListener(_G.QuestEventType.kAfterPassOrFailLevel, self.onPassOrFailLevel)
end

function QIPassMainLevelWithNStar:onPassOrFailLevel( event )
	local data = event.data or {}
	if event:isPassLevel() and event:hasNewStar() then
		if event:matchLevelType{GameLevelType.kMainLevel} then
			local star = event:getPassLevelStar()
			if star >= self.data.star then
				self.data.num = self.data.num + 1
				self.data.num = math.min(self.data.num, self.data.relTarget)

				self:afterUpdate()
				self:checkFinish()
			end
		end
	end
end

function QIPassMainLevelWithNStar:doAction( ... )
	return require('zoo.quest.actions.PlayLevelAction'):doAction{GameLevelType.kMainLevel}
end

function QIPassMainLevelWithNStar:getDesc( ... )
	return localize('quest.desc.' .. self._type, {
		relTarget = self.data.relTarget,
		nStar = self.data.star,
	})
end

function QIPassMainLevelWithNStar:createIcon( ... )
	local UIHelper = require 'zoo.panel.UIHelper'
	local icon = UIHelper:createSpriteFrame('flash/quest-icon.json', 'quest-icon-dir/80000')
	icon:setScale(0.8)
	return icon
end

function QIPassMainLevelWithNStar:hasEndGameTip( levelId, levelType )
	return levelType == GameLevelType.kMainLevel and GamePlayContext:getInstance().levelInfo.oldStar < self.data.star
end

function QIPassMainLevelWithNStar:getEndGameTip( params )
	return '1'
end

function QIPassMainLevelWithNStar:getEndGameTipText( ... )
	local _type = self._type
	return localize('quest.endgame.time.' .. _type, {nStar = self.data.star})
end

return QIPassMainLevelWithNStar