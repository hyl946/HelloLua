--luajit table.insert 与原生lua 有细微区别，这里模拟luajit的行为
local old_insert = table.insert

table.insert = function ( t, pos, v )
	if v == nil then
		old_insert(t, pos)
	else
		if #t < pos then
			for i=1,pos do
				if t[i] == nil then
					t[i] = "__he_insert_pos__"
				end 
			end
		end

		old_insert(t, pos, v)

		for k,v in pairs(t) do
			if t[k] == "__he_insert_pos__" then
				t[k] = nil
			end
		end
	end
end

--luajit math.random 与原生lua 有细微区别，这里模拟luajit的行为
--原生math.random(low, up) 必须有low <= up
local old_random = math.random

math.random = function ( low, up )
	if up == nil and low ~= nil then
		return old_random(low)
	elseif low == nil and up == nil then
		return old_random()
	elseif low ~= nil and up ~= nil then
		if low > up then
			return old_random(up, low)
		end	
		return old_random(low, up)
	else
		return nil
	end
end