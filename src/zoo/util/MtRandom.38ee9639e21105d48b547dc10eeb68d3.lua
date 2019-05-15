
local N, M, MATRIX_A, UPPER_MASK, LOWER_MASK = 624, 397, 2.56748e+009, 2.14748e+009, 2147483647
local mag01 = {0, MATRIX_A}

local function init_genrand(self, value)
	local a, b = 0, 0
end

local function genrand_int32(self)
	return math.random(0, UPPER_MASK)
end

local function next(self, value)
	return genrand_int32(self)
end

MtRandom = class()

function MtRandom:ctor()
	self.mt = {}
end

function MtRandom:dispose()
	self.mt = nil
end

------------------------------------------------------------------------------

function MtRandom:setSeed(seed)
  math.randomseed(seed)
  
	self.seed = seed

	init_genrand(self, seed)
end

function MtRandom:getSeed()
	return self.seed
end

-- random a int with area [1, m]
function MtRandom:nextInt(max)
	if type(max) == "number" and tonumber(max) > 0 then
		return math.random(max);
	else
		he_log_info(string.format("MtRandom:nextInt() max value [%s] is not a positive int value", max))
		return 0
	end

end

function MtRandom:nextDecimal()
	return math.random()
end

function MtRandom:nextFloat()
	return math.random() * 2147483647
end

function MtRandom:nextIntInRange(from, to)
	return math.random(from, to)
end

-------------------------------------------------------------------------------

function MtRandom.create(seed)
	local r = MtRandom.new()
	if seed and type(seed) == "number" then
		r:setSeed(seed)
	end
	return r
end