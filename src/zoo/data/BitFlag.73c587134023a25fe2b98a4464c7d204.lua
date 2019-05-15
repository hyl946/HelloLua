BitFlag = class()

function BitFlag:create()
	local bf = BitFlag.new()
	bf.flag = 0
	return bf
end

function BitFlag:isFlagBitSet(bitIndex)
	self.flag = self.flag or 0
	if bitIndex < 1 then bitIndex = 1 end
	local mask = math.pow(2, bitIndex - 1) -- e.g.: mask: 0010

	local bit = require("bit")
	return mask == bit.band(self.flag, mask) -- e.g.:1111 & 0010 = 0010
end

function BitFlag:setFlagBit(bitIndex, setToTrue)
	self.flag = self.flag or 0
	if bitIndex < 1 then bitIndex = 1 end
	local mask = math.pow(2, bitIndex - 1) -- e.g.: maks: 0010
	local bit = require("bit")
	if setToTrue == true or setToTrue == 1 then 
		self.flag = bit.bor(self.flag, mask) -- e.g. 1100 | 0010 = 1110
	else
		if mask == bit.band(self.flag, mask) then 
			self.flag = self.flag - mask -- e.g.: 1110 - 0010 = 1100
		end
	end
	return self.flag
end

function BitFlag:getFlagValue()
	return self.flag
end