local Quest = require 'zoo.quest.Quest'


local QIGetNewStar = class(Quest)

function QIGetNewStar:decode( rawData )
	Quest.decode(self, rawData)
	self.data.cacheStarNum = UserManager:getInstance().user:getTotalStar() or 0
end

-- function QIGetNewStar:_isFinished( ... )
-- 	local curTotalStar 	= UserManager:getInstance().user:getTotalStar()
-- 	return curTotalStar >= self.data.target
-- end

function QIGetNewStar:registerAllListener( ... )
	self:registerListener(_G.QuestEventType.kAfterPassOrFailLevel, self.onLevelFinish)
end

function QIGetNewStar:onLevelFinish( ... )
	if UserManager:getInstance().user:getTotalStar() > self.data.cacheStarNum then

		self.data.num = self.data.num + UserManager:getInstance().user:getTotalStar() - self.data.cacheStarNum
		self.data.num = math.min(self.data.num, self.data.relTarget)
		self.data.cacheStarNum = UserManager:getInstance().user:getTotalStar()

		self:afterUpdate()
		self:checkFinish()
	end
end

function QIGetNewStar:doAction( ... )
	return require('zoo.quest.actions.PlayLevelAction'):doAction{GameLevelType.kMainLevel, GameLevelType.kHiddenLevel}
end

function QIGetNewStar:createIcon( ... )
	local UIHelper = require 'zoo.panel.UIHelper'
	local icon = UIHelper:createSpriteFrame('flash/quest-icon.json', 'quest-icon-dir/30000')
	icon:setScale(0.8)
	return icon
end

function QIGetNewStar:hasEndGameTip( levelId, levelType )
	local oldStar = GamePlayContext:getInstance().levelInfo.oldStar
	local levelMeta = LevelMapManager.getInstance():getMeta(levelId)
	local maxStar = 3
	if levelMeta and levelMeta.scoreTargets and levelMeta.scoreTargets[4] and levelMeta.scoreTargets[4] > 0 then
		maxStar = 4
	end
	return maxStar > oldStar
end

function QIGetNewStar:getEndGameTip( params )
	if params.gameBoardLogic then
		local levelId = params.gameBoardLogic.level
		local score, star = params.gameBoardLogic:getCurScoreAndStar()
		local oldScoreRef = UserManager:getInstance():getUserScore(levelId)
		local oldStar = 0
		if oldScoreRef then
			oldStar = oldScoreRef.star
		end
		if star > oldStar then
			return tostring(star - oldStar)
		end
	end
end

return QIGetNewStar