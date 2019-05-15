---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2016-12-26 16:05:41
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   Administrator
-- @Last Modified time: 2016-12-26 16:44:11
---------------------------------------------------------------------------------------
SpringScoreProgressAnimation = class(ScoreProgressAnimation)

local kStarFactor = 24 * 3.1415926 / 180
local kMaskBeginWidth = 17
local kMaskEndWidth = 50

function SpringScoreProgressAnimation:create(scoreProgress, pos)
	-- body
	local s = SpringScoreProgressAnimation.new()
	s:init(scoreProgress, pos)
	return s
end

function SpringScoreProgressAnimation:init( scoreProgress, pos )
	-- ScoreProgressAnimation.init(self, scoreProgress, pos)
	-- self.animal:setVisible(false)
end

function SpringScoreProgressAnimation:reset( delayTime )
end

function SpringScoreProgressAnimation:moveTo( progress )
end

function SpringScoreProgressAnimation:revertTo( progress )
end

function SpringScoreProgressAnimation:setStarsPosition( star1progress, star2progress, star3progress )	
end

function SpringScoreProgressAnimation:updateMaskProgress( progress )
end

function SpringScoreProgressAnimation:animateTo(progress, duration , ...)
end

function SpringScoreProgressAnimation:setStarsScore( star1score, star2score, star3score ,star3score)
	self.star1score = star1score
	self.star2score = star2score
	self.star3score = star3score
	self.star4score = star4score
end

function SpringScoreProgressAnimation:showStar( star, starName )
end

function SpringScoreProgressAnimation:updateStarProgress( progress )
end

function SpringScoreProgressAnimation:getBigStarPosInWorldSpace(...)
	return {ccp(0, 0), ccp(0, 0), ccp(0, 0), ccp(0, 0)}
end

function SpringScoreProgressAnimation:setBigStarVisible(starIndex, visible, ...)
end

function SpringScoreProgressAnimation:getBigStarSize(...)
	return {width=20, height=20}
end

function SpringScoreProgressAnimation:addScoreStar( globalPosition )
end

function SpringScoreProgressAnimation:playFourStarAnimation()
end