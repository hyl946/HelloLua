TileMoveDirConfig = table.const {
	kUndefined = 0,
	kUp = 1,
	kRight = 2,
	kDown = 3,
	kLeft = 4
}

TileMoveRouteMeta = class()

function TileMoveRouteMeta:ctor()
	self.startPos = nil
	self.endPos = nil
	self.next = nil
	self.pre = nil
end

function TileMoveRouteMeta:fromMeta(posData, gameMode)
	local posInNum = tonumber(posData)
	local bit = require "bit"

	local bitNum = 4
    local bitBand = 0xf

    if isDigGameMode(gameMode) then 
        bitNum = 6
        bitBand = 0x3f
    end

	local startPosC = bit.band(bit.rshift(posInNum, bitNum*3), bitBand) + 1
	local startPosR = bit.band(bit.rshift(posInNum, bitNum*2), bitBand) + 1
	local endPosC = bit.band(bit.rshift(posInNum, bitNum*1), bitBand) + 1
	local endPosR = bit.band(posInNum, bitBand) + 1

	self.startPos = IntCoord:create(startPosR, startPosC)
	self.endPos = IntCoord:create(endPosR, endPosC)
end

function TileMoveRouteMeta:moveWithStep(r, c, step, isReverse)
	local leftStep = step
	local retR, retC = r, c
	local dir = TileMoveDirConfig.kUndefined
	if isReverse then
		dir = TileMoveRouteMeta:calcDirection(self.endPos, self.startPos)
	else
		dir = TileMoveRouteMeta:calcDirection(self.startPos, self.endPos)
	end

	local endPos = self.endPos
	if isReverse then endPos = self.startPos end -- 反向移动

	if dir == TileMoveDirConfig.kUp then
		retR = r - step
		if retR < endPos.x then  retR = endPos.x end
	elseif dir == TileMoveDirConfig.kRight then
		retC = c + step
		if retC > endPos.y then retC = endPos.y end
	elseif dir == TileMoveDirConfig.kDown then
		retR = r + step
		if retR > endPos.x  then retR = endPos.x end
	elseif dir == TileMoveDirConfig.kLeft then
		retC = c - step
		if retC < endPos.y then retC = endPos.y end
	end
	leftStep = leftStep - (math.abs(r - retR) + math.abs(c - retC))
	return retR, retC, leftStep
end

function TileMoveRouteMeta:getDirection(isReverse)
	if isReverse then
		return self:calcDirection(self.endPos, self.startPos)
	else
		return self:calcDirection(self.startPos, self.endPos)
	end
end

function TileMoveRouteMeta:calcDirection(startPos, endPos)
	local dr = endPos.x - startPos.x
	local dc = endPos.y - startPos.y
	if dr == 0 and dc < 0 then
		return TileMoveDirConfig.kLeft
	elseif dr == 0 and dc > 0 then
		return TileMoveDirConfig.kRight
	elseif dc == 0 and dr < 0 then
		return TileMoveDirConfig.kUp
	elseif dc == 0 and dr > 0 then
		return TileMoveDirConfig.kDown
	end
	return TileMoveDirConfig.kUndefined
end

function TileMoveRouteMeta:isStartPos(r, c)
	return self.startPos.x == r and self.startPos.y == c
end

function TileMoveRouteMeta:isEndPos(r, c)
	return self.endPos.x == r and self.endPos.y == c
end

function TileMoveRouteMeta:isFinalPos(r, c, isReverse)
	if isReverse then
		return not self.pre and self:isStartPos(r, c)
	else
		return not self.next and self:isEndPos(r, c)
	end
end

TileMoveMeta = class()

function TileMoveMeta:ctor()
	self.step = 0
	self.routes = {}
	self.moveCountDown = 1 -- default 1
end

function TileMoveMeta:create(meta, gameMode)
	assert(type(meta) == "string")
	-- if _G.isLocalDevelopMode then printx(0, "TileMoveMeta:create ", meta) end
	local tmMeta = TileMoveMeta.new()
	tmMeta.meta = meta
	tmMeta.gameMode = gameMode
	if meta and gameMode then
		tmMeta:fromMeta(meta, gameMode)
	end
	return tmMeta
end

function TileMoveMeta:encodeForSectionData()
	return { meta = self.meta , gameMode = self.gameMode }
end

function TileMoveMeta:fromMeta(meta, gameMode)
	local stepAndRoutes = string.split(meta, ":")
	self.step = 0
	self.routes = {}

	if #stepAndRoutes >= 2  then
		self.step = tonumber(stepAndRoutes[1])

		local routesInNumber = string.split(stepAndRoutes[2], ",")
		if routesInNumber and #routesInNumber > 0 then
			for _, v in pairs(routesInNumber) do
				local route = TileMoveRouteMeta.new()
				route:fromMeta(v, gameMode)
				table.insert(self.routes, route)
			end

			local function findNextRouteByStartPos(pos)
				for _, v in pairs(self.routes) do
					if v.startPos.x == pos.x and v.startPos.y == pos.y then
						return v
					end
				end
			end
			-- 创建双向链表
			for _, route in pairs(self.routes) do
				local nextRoute = findNextRouteByStartPos(route.endPos)
				if nextRoute then
					route.next = nextRoute
					if not nextRoute.pre then nextRoute.pre = route end
				end
			end
		end
	end
end

function TileMoveMeta:findRouteByPos(r, c, isReverse)
	if isReverse then
		for _, v in pairs(self.routes) do
			if r == v.endPos.x and c == v.endPos.y then -- 在终点中找
				return v
			end
		end
	else
		for _, v in pairs(self.routes) do
			if r == v.startPos.x and c == v.startPos.y then -- 在起点中找
				return v
			end
		end
	end
	
	for _, v in pairs(self.routes) do
		if r == v.startPos.x and r == v.endPos.x and ((c - v.startPos.y) * (c - v.endPos.y) <= 0) then -- 是否在行中间
			return v
		end
		if c == v.startPos.y and c == v.endPos.y and ((r - v.startPos.x) * (r - v.endPos.x) <= 0) then -- 是否在列中间
			return v
		end
	end
	return nil
end

TileMoveConfig = class()

function TileMoveConfig:ctor()
	self.tileMoveCfgs = {}
end

function TileMoveConfig:create(config, gameMode)
	if not config then return nil end
	
	local ret = TileMoveConfig.new()
	ret:fromConfig(config, gameMode)
	return ret
end

function TileMoveConfig:fromConfig(config, gameMode)
	self.tileMoveCfgs = {}

	if type(config) == "table" and #config > 0 then
		for _, meta in pairs(config) do
			local tmMeta = TileMoveMeta:create(meta, gameMode)
			if tmMeta.step > 0 and #tmMeta.routes > 0 then
				local initPos = tmMeta.routes[1].startPos
				self.tileMoveCfgs[initPos.x.."_"..initPos.y] = tmMeta
			end
		end
	end
end

-- function TileMoveConfig:findTileMoveMetaByPos(r, c)
-- 	return self.tileMoveCfgs[r.."_"..c]
-- end

-- 因为挖地滚屏后会直接改meta数据中的行数，所以需要返回副本
function TileMoveConfig:findCopiedTileMoveMetaByPos(r, c)
	local origData = self.tileMoveCfgs[r.."_"..c]
	local copiedData
	if origData then
		copiedData = TileMoveMeta:create(origData.meta, origData.gameMode)
	end
	return copiedData
end
