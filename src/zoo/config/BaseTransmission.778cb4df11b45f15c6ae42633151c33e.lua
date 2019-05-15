BaseTransmission = class()

local TransType = {
	kType1 = 1, 			
	kType2 = 2,
} 

function BaseTransmission:create(value, transType)

	local ints = string.split(value, ',')
	if #ints == 1 then

		local bt = BaseTransmission.new()
		bt:init(ints[1], transType)
		return bt
	else
		local allTrans = {}
		for k, v in pairs(ints) do
			local tmp = BaseTransmission:create(v, transType)
			table.insert(allTrans, tmp)
		end
		-- 判断是否带环
		-- 如果有环，链表并不会形成一个环，而是随便选一个做头
		local hasCercle = true
		local head, tail
		local function getTransByStart(start)
			for k, v in pairs(allTrans) do
				local s = v:getStart()
				if s.x == start.x and s.y == start.y then
					return allTrans[k]
				end
			end
			return nil
		end
		for k, v in pairs(allTrans) do
			local linkItem = v:getLink()
			if linkItem.x ~= 16 or linkItem.y ~= 16 then
				hasCercle = false
			end
		end

		-- 配置保证了第一个就是head节点的配置
		head = allTrans[1]

		-- hasCercle属性同步到链表中所有节点
		for k, v in pairs(allTrans) do
			v._hasCercle = hasCercle
		end

		if _G.isLocalDevelopMode then printx(0, 'HAS CERCLE', hasCercle) end

		local next, pointer
		pointer = head
		next = getTransByStart(pointer:getEnd())
		while (next ~= nil and next ~= head) do
			if _G.isLocalDevelopMode then printx(0, 'next', next:getStart().x, next:getStart().y) end
			pointer:setNextTrans(next)
			next:setPrevTrans(pointer)
			pointer = next
			next = getTransByStart(pointer:getEnd())
		end
		head:setPrevTrans(nil)
		pointer:setNextTrans(nil)

		-- debug
		if _G.isLocalDevelopMode then printx(0, 'LINKED TRANSMISSIONS') end
		pointer = head
		while (pointer ~= nil) do
			if _G.isLocalDevelopMode then printx(0, 'start ', pointer:getStart().x, pointer:getStart().y) end
			if _G.isLocalDevelopMode then printx(0, 'end ', pointer:getEnd().x, pointer:getEnd().y) end
			if _G.isLocalDevelopMode then printx(0, 'link', pointer:getLink().x, pointer:getLink().y) end
			if _G.isLocalDevelopMode then printx(0, 'direction', pointer:getDirection()) end
			if _G.isLocalDevelopMode then printx(0, 'startType', pointer:getStartType()) end
			if _G.isLocalDevelopMode then printx(0, 'endType', pointer:getEndType()) end
			if _G.isLocalDevelopMode then printx(0, 'length', pointer:getTransLength()) end
			if _G.isLocalDevelopMode then printx(0, '') end
			pointer = pointer:getNextTrans()
		end

		return head
	end
end

function BaseTransmission:init(config, transType)
	self.prevTrans = nil
	self.nextTrans = nil
	self.transType = transType
	local value = tonumber(config)
	self:setStart(value)
	self:setStartType(value)
	self:setEnd(value)
	self:setEndType(value)
	self:setLink(value)
	self.sign = IntCoord:create(self.endItem.x - self.startItem.x, self.endItem.y - self.startItem.y)
	self.sign.x = self.sign.x == 0 and 0 or (self.sign.x > 0 and 1 or -1)
	self.sign.y = self.sign.y == 0 and 0 or (self.sign.y > 0 and 1 or -1) 

end

-- corner只会是length == 1的item
function BaseTransmission:getCornerType()
	local prevTrans
	if self == self:getHeadTrans() then
		prevTrans = self:getEndTrans()
	else
		prevTrans = self:getPrevTrans()
	end
	local prevDirection = prevTrans:getDirection()
	local thisDirection = self:getDirection()

	if prevDirection == TransmissionDirection.kUp then
		if thisDirection == TransmissionDirection.kLeft then
			return TransmissionType.kCorner_UL
		elseif thisDirection == TransmissionDirection.kRight then
			return TransmissionType.kCorner_UR
		elseif thisDirection == TransmissionDirection.kUp then
			return TransmissionType.kRoad
		elseif thisDirection == TransmissionDirection.kDown then
			assert(false, 'TRANSMISSION DIRECTION IS WRONG')
			return nil
		end

	elseif prevDirection == TransmissionDirection.kDown then
		if thisDirection == TransmissionDirection.kLeft then
			return TransmissionType.kCorner_DL
		elseif thisDirection == TransmissionDirection.kRight then
			return TransmissionType.kCorner_DR
		elseif thisDirection == TransmissionDirection.kDown then
			return TransmissionType.kRoad
		elseif thisDirection == TransmissionDirection.kUp then
			assert(false, 'TRANSMISSION DIRECTION IS WRONG')
			return nil
		end

	elseif prevDirection == TransmissionDirection.kLeft then
		if thisDirection == TransmissionDirection.kUp then
			return TransmissionType.kCorner_LU
		elseif thisDirection == TransmissionDirection.kDown then
			return TransmissionType.kCorner_LD
		elseif thisDirection == TransmissionDirection.kLeft then
			return TransmissionType.kRoad
		elseif thisDirection == TransmissionDirection.kRight then
			assert(false, 'TRANSMISSION DIRECTION IS WRONG')
			return nil
		end

	elseif prevDirection == TransmissionDirection.kRight then
		if thisDirection == TransmissionDirection.kUp then
			return TransmissionType.kCorner_RU
		elseif thisDirection == TransmissionDirection.kDown then
			return TransmissionType.kCorner_RD
		elseif thisDirection == TransmissionDirection.kRight then
			return TransmissionType.kRoad
		elseif thisDirection == TransmissionDirection.kLeft then
			assert(false, 'TRANSMISSION DIRECTION IS WRONG')
			return nil
		end

	end

end

function BaseTransmission:getTransTypeByIndex(index)
	if self:isSingleTilePath() then 
		return TransmissionType.kSingleTile
	end
	-- if _G.isLocalDevelopMode then printx(0, 'index', index, 'hasCercle', self:hasCercle(), 'hasCorner', self:hasCorner(), 'isHead', self:getHeadTrans() == self, 'is End', self:getEndTrans() == self) end
	local type_trans = TransmissionType.kRoad
	if self:hasCercle() then
		if index == 1 then
			type_trans = self:getCornerType()
		end
	elseif self:hasCorner() then
		if self:getHeadTrans() == self then
			if index == 1 then
				type_trans = TransmissionType.kStart
			end
		elseif self:getEndTrans() == self then
			if index == 1 then
				type_trans = self:getCornerType()
			elseif index == self:getTransLength() then
				type_trans = TransmissionType.kEnd
			end
		else
			if index == 1 then
				type_trans = self:getCornerType()
			end
		end
	else
		if index == 1 then
			type_trans = TransmissionType.kStart
		elseif index == self:getTransLength() then
			type_trans = TransmissionType.kEnd
		end
	end
	return type_trans
end

function BaseTransmission:getLinkPositionByIndex(index)
	local direction = self:getDirection()
	local dx, dy = 0, 0
	if direction == TransmissionDirection.kLeft then
		dy = -1
	elseif direction == TransmissionDirection.kRight then 
		dy = 1
	elseif direction == TransmissionDirection.kUp then
		dx = -1
	else
		dx = 1
	end 

	local start = self:getStart()
	local pos
	local nextItemPos = {x = start.x + dx*index, y = start.y + dy*index}
	local linkItemPos = self:getLink()

	if self:hasCercle() then
		pos = nextItemPos
	elseif self:hasCorner() then
		if self == self:getEndTrans() then
			if index == self:getTransLength() then
				pos = linkItemPos
			else
				pos = nextItemPos
			end
		else
			pos = nextItemPos
		end
	else
		if index == self:getTransLength() then
			pos = linkItemPos
		else
			pos = nextItemPos
		end
	end
	return pos

end

function BaseTransmission:hasCorner()
	return (self:getHeadTrans() ~= self:getEndTrans())
end

function BaseTransmission:hasCercle()
	return self._hasCercle
end

function BaseTransmission:getNextTrans()
	return self.nextTrans
end

function BaseTransmission:getPrevTrans()
	return self.prevTrans
end

function BaseTransmission:setPrevTrans(prev)
	self.prevTrans = prev
end

function BaseTransmission:setNextTrans(next)
	self.nextTrans = next
end

function BaseTransmission:getEndTrans()
	if self.nextTrans then
		return self.nextTrans:getEndTrans()
	else
		return self
	end
end

function BaseTransmission:isHeadTrans()
	return self.prevTrans == nil
end

function BaseTransmission:isEndTrans()
	return self.nextTrans == nil
end

function BaseTransmission:getHeadTrans()
	if self.prevTrans then
		return self.prevTrans:getHeadTrans()
	else
		return self
	end
end

function BaseTransmission:setStart(value)
	local bitStartX = 18
	local bitStartY = 22
	local limitStart = 15
	if self.transType and self.transType == TransType.kType2 then 
		bitStartX = 20
		bitStartY = 24
	end
	local r = bit.band(bit.rshift(value, bitStartY), limitStart) + 1
	local c = bit.band(bit.rshift(value, bitStartX), limitStart) + 1
	self.startItem = IntCoord:create(r, c)
end

function BaseTransmission:setStartType(value)
	local bitStartType = 26
	local limitStartType = 3
	if self.transType and self.transType == TransType.kType2 then 
		bitStartType = 28
		limitStartType = 15
	end
	self.startType =  bit.band(bit.rshift(value, bitStartType), limitStartType)
end

function BaseTransmission:setEnd(value)
	local bitEndX = 8
    local bitEndY = 12
    local limitEnd = 15
	local r = bit.band(bit.rshift(value, bitEndY), limitEnd) + 1
	local c = bit.band(bit.rshift(value, bitEndX), limitEnd) + 1
	self.endItem = IntCoord:create(r, c)
end

function BaseTransmission:setEndType(value)
	local bitEndType = 16
	local limitEndType = 3
	if self.transType and self.transType == TransType.kType2 then 
		limitEndType = 15
	end
	self.endType = bit.band(bit.rshift(value, bitEndType), limitEndType)
end

function BaseTransmission:setLink(value)
	local bitToY = 4
	local limitTo = 15
	local r = bit.band(bit.rshift(value, bitToY), limitTo) + 1
	local c = bit.band(value, limitTo) + 1
	self.toItem = IntCoord:create(r, c)
end

function BaseTransmission:getStart()
	return self.startItem
end

function BaseTransmission:getEnd()
	return self.endItem
end

function BaseTransmission:getSign()
	return self.sign
end

function BaseTransmission:getLink()
	return self.toItem
end

function BaseTransmission:getTransLength()
	-- 不带环的最后一节，长度包括最后一个item
	if self:getEndTrans() == self and not self:hasCercle() then
		if self.sign.x == 0 then
			return math.abs(self.startItem.y - self.endItem.y) + 1
		else
			return math.abs(self.startItem.x - self.endItem.x) + 1
		end
	else -- 带环的每一节，长度都不包括最后一个item
		if self.sign.x == 0 then
			return math.abs(self.startItem.y - self.endItem.y)
		else
			return math.abs(self.startItem.x - self.endItem.x)
		end
	end
end

function BaseTransmission:getDirection()
	local sign
	if self:isSingleTilePath() then 
		sign = IntCoord:create(self.toItem.x - self.startItem.x, self.toItem.y - self.startItem.y)
		sign.x = sign.x == 0 and 0 or (sign.x > 0 and 1 or -1)
		sign.y = sign.y == 0 and 0 or (sign.y > 0 and 1 or -1) 
		
		if sign.y < 0 then
			return TransmissionDirection.kLeft
		elseif sign.y > 0 then
			return TransmissionDirection.kRight
		elseif sign.x > 0 then
			return TransmissionDirection.kDown
		else
			return TransmissionDirection.kUp
		end
	else
		sign = self.sign
		if sign.x < 0 then
			return TransmissionDirection.kUp
		elseif sign.y > 0 then
			return TransmissionDirection.kRight
		elseif sign.y < 0 then
			return TransmissionDirection.kLeft
		else
			return TransmissionDirection.kDown
		end
	end
end

function BaseTransmission:getStartType()
	return self.startType
end

function BaseTransmission:getEndType()
	return self.endType
end

function BaseTransmission:isSingleTilePath()
	return  not self:hasCercle() and 
			self.startItem.x == self.endItem.x and 
			self.startItem.y == self.endItem.y 
end