require "hecore.display.Director"

local kRad3Ang = -180/3.1415926

CardinalSpline = class()
function CardinalSpline:ctor( points, tension )
	self.points = points
	self.tension = tension
	self.deltaTime = 1 / (#points-1)
end

function CardinalSpline:getControlPointAtIndex( index )
	index = index + 1 --lua array start at 1

	if index < 1 then index = 1 end
	if index > #self.points then index = #self.points end

	return self.points[index]
end

local function ccCardinalSplineAt( p0, p1, p2, p3, tension, t )
	local t2 = t * t
	local t3 = t2 * t
	--F: s(-ttt + 2tt - t)P1 + s(-ttt + tt)P2 + (2ttt - 3tt + 1)P2 + s(ttt - 2tt + t)P3 + (-2ttt + 3tt)P3 + s(ttt - tt)P4
	local s = (1-tension) / 2

	local b1 = s * (-t3 + 2 * t2 - t) 					-- s(-t3 + 2 t2 - t)P1
	local b2 = s * (-t3 + t2) + (2 * t3 - 3 * t2 + 1) 	-- s(-t3 + t2)P2 + (2 t3 - 3 t2 + 1)P2
	local b3 = s * (t3 - 2*t2 + t) + (-2*t3 + 3 * t2) 	-- s(t3 - 2 t2 + t)P3 + (-2 t3 + 3 t2)P3
	local b4 = s * (t3 - t2) 							-- s(t3 - t2)P4

	local x = p0.x * b1 + p1.x * b2 + p2.x * b3 + p3.x * b4
	local y = p0.y * b1 + p1.y * b2 + p2.y * b3 + p3.y * b4
	return ccp(x, y)
end 

local function ccCardinalSplineTangAt( p0, p1, p2, p3, tension, t )
	local t2 = t * t
	local t3 = t2 * t
	--F: s(-ttt + 2tt - t)P1 + s(-ttt + tt)P2 + (2ttt - 3tt + 1)P2 + s(ttt - 2tt + t)P3 + (-2ttt + 3tt)P3 + s(ttt - tt)P4
	local s = (1-tension) / 2
	local b1 = s * (-3*t2 + 4 * t -1)  --s * (-t3 + 2 * t2 - t) 
	local b2 = s * (-3*t2 + 2 * t) + (6*t2 - 6*t) --s * (-t3 + t2) + (2 * t3 - 3 * t2 + 1)
	local b3 = s * (3*t2 - 4 *t + 1) + (-6*t2 + 6*t) --s * (t3 - 2*t2 + t) + (-2*t3 + 3 * t2)
	local b4 = s * (3*t2 - 2 * t) --s * (t3 - t2) 

	local x = p0.x * b1 + p1.x * b2 + p2.x * b3 + p3.x * b4
	local y = p0.y * b1 + p1.y * b2 + p2.y * b3 + p3.y * b4
	return math.atan2(y, x)
end 

function CardinalSpline:calculatePosition( time )
	local points = self.points
	local p = 0
	local lt = 0
	--p..p..p..p..p..p..p
	--1..2..3..4..5..6..7
	--want p to be 1, 2, 3, 4, 5, 6
	if time == 1 then
		p = math.floor(#points - 1)
		lt = 1
	else 
		p = math.floor(time / self.deltaTime)
		lt = (time - self.deltaTime * p)/self.deltaTime
	end

	local pp0 = self:getControlPointAtIndex(p-1)
	local pp1 = self:getControlPointAtIndex(p+0)
	local pp2 = self:getControlPointAtIndex(p+1)
	local pp3 = self:getControlPointAtIndex(p+2)

	local position = ccCardinalSplineAt(pp0, pp1, pp2, pp3, self.tension, lt)
	return position
end
function CardinalSpline:calculateAngle( time )
	local points = self.points
	local p = 0
	local lt = 0
	--p..p..p..p..p..p..p
	--1..2..3..4..5..6..7
	--want p to be 1, 2, 3, 4, 5, 6
	if time == 1 then
		p = math.floor(#points - 1)
		lt = 1
	else 
		p = math.floor(time / self.deltaTime)
		lt = (time - self.deltaTime * p)/self.deltaTime
	end

	local pp0 = self:getControlPointAtIndex(p-1)
	local pp1 = self:getControlPointAtIndex(p+0)
	local pp2 = self:getControlPointAtIndex(p+1)
	local pp3 = self:getControlPointAtIndex(p+2)

	local rad = ccCardinalSplineTangAt(pp0, pp1, pp2, pp3, self.tension, lt)
	local angle = rad * kRad3Ang
	return angle
end