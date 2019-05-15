-- RandomFactory = class()

-- local kCheckModifyInterval = 100

-- function RandomFactory:create()
-- 	local randomFactory = RandomFactory.new()
-- 	randomFactory:init()
-- 	return randomFactory
-- end

-- function RandomFactory:init()
-- 	self.CCPObject = HERandomObject()
-- 	self.randomIndex = 0
-- 	self.checkModifyInterval = kCheckModifyInterval
-- 	self.hasModifyAct = false
-- end

-- function RandomFactory:rand(a,b)
-- 	local r = 0 
	
-- 	if self.CCPObject then
-- 		if a and b then
-- 			-- self.randomIndex = self.randomIndex + 1
-- 			r = self.CCPObject:rand(a,b)
-- 			-- self:ModifyCheck()
-- 		else
-- 			-- self.randomIndex = self.randomIndex + 1
-- 			r = self.CCPObject:rand()
-- 		end
-- 	end

-- 	return r
-- end

-- function RandomFactory:ModifyCheck()
-- 	if self.hasModifyAct then return end
-- 	self.checkModifyInterval = self.checkModifyInterval - 1
-- 	if self.checkModifyInterval <= 0 then
-- 		self.checkModifyInterval = kCheckModifyInterval
-- 		local r = self.CCPObject:rand(4,9)
-- 		if r < 4 or r > 9 then self.hasModifyAct = true end
-- 	end
-- end

-- function RandomFactory:randSeed(seed)
-- 	if self.CCPObject and seed then
-- 		self.randomIndex = 0
-- 		return self.CCPObject:randSeed(seed)
-- 	end
-- 	return nil
-- end

RandomFactory = class()

local bit = require("bit")

function RandomFactory:create(name)
	local randObj = RandomFactory.new()
	randObj:init(name)
	return randObj
end

function RandomFactory:init(name)
	self.holdrand = 0
	self.__name = name
end

local function convertNumberToInt32(num)
	if num > 4294967295 or num < -2147483648 then
		num = bit.band(num, 0xffffffff)
	end
	if num > 2147483648 then
		num = num - 4294967296
	end
	return num
end

function RandomFactory:_rand()
	self.holdrand = convertNumberToInt32(self.holdrand * 214013 + 2531011)
	return bit.band(bit.rshift(self.holdrand, 16), 0x7fff)
end

function RandomFactory:rand(a,b)
	if a > b then a, b = b, a end
	return self:_rand()%(b-a+1)+a
end

function RandomFactory:randSeed(seed)
	self.holdrand = seed
end

function RandomFactory:getCurrHoldrand()
	return self.holdrand
end