local Vector = class()

function Vector:ctor(x, y)
	self.x = x or 0
	self.y = y or 0
end

function Vector:clone()
	return Vector.new(self.x, self.y)
end

function Vector:normalized()
	local len = self.x*self.x + self.y*self.y
	if len > 0 then
		len = math.sqrt(len)
		self.x = self.x / len
		self.y = self.y / len
	end
end

function Vector:normalize()
	local v = self:clone()
	v:normalized()
	return v
end

function Vector:length()
	return math.sqrt(self.x*self.x + self.y*self.y)
end

function Vector:lengthSquared()
	return self.x*self.x + self.y*self.y
end

function Vector:distanceTo(v)
	local dx = v.x - self.x
	local dy = v.y - self.y
	local distance = dx*dx + dy*dy
	return math.sqrt(distance)
end

function Vector:distanceSquaredTo(v)
	local dx = v.x - self.x
	local dy = v.y - self.y
	local distance = dx*dx + dy*dy
	return distance
end

function Vector:angle()
	return math.atan2(self.y, self.x)
end

function Vector:tangent()
	return Vector.new(-self.y, self.x)
end

function Vector:angleTo(v)
	return math.atan2(self:tangent():dot(v), self:dot(v))
end

function Vector:angleToPoint(v)
	return math.atan2(v.y-self.y, v.x-self.x)
end

function Vector:dot(v)
	return self.x*v.x + self.y*v.y
end

function Vector:cross(v)
	return self.x*v.y - self.y*v.x
end

--useful when self is unit vector
function Vector:project(v)
	local scale = v:dot(self) / self:dot(self)
	return self:mul(scale)
end

--useful when self is unit vector
function Vector:plane_project(d, v)
	return v:sub(self:mul(v:dot(self)-d))
end

function Vector:add(v)
	return Vector.new(self.x+v.x, self.y+v.y)
end

function Vector:sub(v)
	return Vector.new(self.x-v.x, self.y-v.y)
end

function Vector:mul(k)
	return Vector.new(self.x*k, self.y*k)
end

function Vector:div(k)
	return Vector.new(self.x/k, self.y/k)
end

function Vector:inversed()
	self.x = -self.x
	self.y = -self.y
end

function Vector:inverse()
	local v = self:clone()
	v:inversed()
	return v
end

function Vector:clamped(maxLen)
	local len = self:length()
	local lenClamped = math.clamp(len, 0, maxLen)

	if len > lenClamped then
		local scale = lenClamped / len
		self.x = self.x * scale
		self.y = self.y * scale
	end
end

function Vector:clamp(maxLen)
	local v = self:clone()
	v:clamped(maxLen)
	return v
end

function Vector:linearInterpolate(v, t)
	local a = self
	local b = v
	return a:mul(1-t):add(b:mul(t))
end

-- useful when self is unit vector

function Vector:slide(v)
	return v:sub(self:mul(v:dot(self)))
end

-- useful when self is unit vector

function Vector:reflect(v)
	return v:sub(self:mul(v:dot(self)*2))
end

function Vector:tostring()
	return string.format('(%.2f, %.2f)', self.x, self.y)
end

function Vector:setAngle(angle)
	local len = self:length()
	self.x = math.cos(angle) * len
	self.y = math.sin(angle) * len
end

function Vector:rotated(angle)
	local curAngle = self:angle()
	local newAngle = curAngle + angle
	self:setAngle(newAngle)
end

function Vector:rotate(angle)
	local v = self:clone()
	v:rotated(angle)
	return v
end

return Vector