
WeeklyScoreProgressAnimation = class(ScoreProgressAnimation)

local kStarFactor = 24 * 3.1415926 / 180
local kMaskBeginWidth = 17
local kMaskEndWidth = 50

function WeeklyScoreProgressAnimation:create(scoreProgress, pos)
	local s = WeeklyScoreProgressAnimation.new()
	s:init(scoreProgress, pos)
	return s
end

function WeeklyScoreProgressAnimation:init( scoreProgress, pos )
end

function WeeklyScoreProgressAnimation:reset( delayTime )
end

function WeeklyScoreProgressAnimation:moveTo( progress )
end

function WeeklyScoreProgressAnimation:revertTo( progress )
end

function WeeklyScoreProgressAnimation:setStarsPosition( star1progress, star2progress, star3progress )	
end

function WeeklyScoreProgressAnimation:updateMaskProgress( progress )
end

function WeeklyScoreProgressAnimation:animateTo(progress, duration , ...)
end

function WeeklyScoreProgressAnimation:setStarsScore( star1score, star2score, star3score )
	self.star1score = star1score
	self.star2score = star2score
	self.star3score = star3score
end

function WeeklyScoreProgressAnimation:showStar( star, starName )
end

function WeeklyScoreProgressAnimation:updateStarProgress( progress )
end

function WeeklyScoreProgressAnimation:getBigStarPosInWorldSpace(...)
	return {ccp(0, 0), ccp(0, 0), ccp(0, 0), ccp(0, 0)}
end

function WeeklyScoreProgressAnimation:setBigStarVisible(starIndex, visible, ...)
end

function WeeklyScoreProgressAnimation:getBigStarSize(...)
	return {width=20, height=20}
end

function WeeklyScoreProgressAnimation:addScoreStar( globalPosition )
end

function WeeklyScoreProgressAnimation:playFourStarAnimation()
end