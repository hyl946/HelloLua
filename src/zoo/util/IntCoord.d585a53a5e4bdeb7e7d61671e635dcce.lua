IntCoord = {}

function IntCoord:create(x, y)
	local v = { x = x, y = y}
	return v
end

function IntCoord:clone(val)
	local v = { x = val.x, y = val.y}
	return v
end