-- 测试 使用单元测试
-- 计算第N个素数

local PN



TestPrime = class(UnittestTask)

function TestPrime:ctor( ... )
	-- body
	UnittestTask.ctor(self, ...)

end

function TestPrime:run( callback )


	--测试用例
	local dataSets = {
		{1, 2},
		{2, 3},
		{100, 541}
	}

	for _, v in ipairs(dataSets) do
		if PN(v[1]) ~= v[2] then
			callback(false, 'failed on ' .. v[1] .. ' ' .. v[2] .. ' ' .. PN(v[1]))
			return
		end
	end

	callback(true, 'test prime successd!')
end




-- ============================== 后边是实现可以不看
-- ============================== 后边是实现可以不看
-- ============================== 后边是实现可以不看


local function car( l )
	if not l then
		return 
	else
		return l[1]
	end
end

local function cdr( l )
	if not l then
		return
	else
		return l[2]()
	end
end

local function empty( l )
	return not l
end

local function show( rawL )
	local ret = {}
	for _, v in ipairs(rawL) do
		table.insert(ret, tostring(v))
	end
	print(table.concat(ret, '->'))
end 

local function str( l )
	local ret = {}
	while not empty(l) do
		table.insert(ret, car(l))
		l = cdr(l)
	end
	return ret
end

local op
op = function( l1, l2, func )
	if empty(l1) or empty(l2) then
		return false
	else
		return {
			func(car(l1), car(l2)),
			function ( ... )
				return op(cdr(l1), cdr(l2), func)
			end
		}
	end
end

local headN
headN = function ( l, n )
	if empty(l) then
		return false
	elseif n <= 0 then
		return false
	else
		return {
			car(l), function ( ... )
				return headN(cdr(l), n - 1)
			end
		}
	end
end

local ones
ones = {1, function ( ... )
	return ones
end}

local naturalNumbers
naturalNumbers = {0, function ( ... )
	return op(naturalNumbers, ones, function ( a, b )
		return a + b
	end)
end}

local filter 
filter = function ( l, func )
	while not empty(l) do
		local h = car(l)
		l = cdr(l)

		-- print(h, func(h))

		if func(h) then
			return {h, function ( ... )
				return filter(l, func)
			end}
		end
	end

	return false
end

local filter2 
filter2 = function ( l, func )
	if not empty(l) then
		local h = car(l)
		l = cdr(l)

		-- print(h, func(h))

		if func(h) then
			return {h, function ( ... )
				return filter2(l, func)
			end}
		end
	end
	return false
end


local map 
map = function ( l, func )
	if not empty(l) then
		local h = car(l)
		l = cdr(l)

		return {func(h), function ( ... )
			return map(l, func)
		end}
	end

	return false
end

local primeNumbersGenerator
primeNumbersGenerator = function ( sl )

	return {
		car(sl), function ( ... )
			return primeNumbersGenerator(filter(cdr(sl), function ( kk )
				return kk % car(sl) ~= 0
			end))
		
		end
	}
end

local show2 
show2 = function ( l )
	-- body
	if not empty(l) then
		print(car(l))
		show2(cdr(l))
	end
end

local primeNumbers = primeNumbersGenerator(
	op(naturalNumbers, ones, function ( a, b )
		return a + b * 2
	end)
)

local function cNr( l, n )
	if empty(l) then
		return false
	else
		if n == 1 then
			return car(l)
		else
			return cNr(cdr(l), n - 1)
		end
	end
end



PN = function ( index )
	return cNr(primeNumbers, index)
end


-- TestPrime.new():run(function ( x, y )
-- 	printx(61, x, y)
-- end)


