
local __next_class_index = 0;

function memory_class_simple(encryptionTable)
	local class_type = {}
	--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--
--


	class_type.new = function(...)
		local obj = {}

		setmetatable(obj, { 
        	__index = function( table, key )    
        		if encryptionTable[key] then
        			return class_type.decryptionFunc(table, key) 
        		end

        		return class_type[key]
        	end,

        	__newindex = function(table, key, value)
        		if encryptionTable[key] then
        			--
--
--
--
--
--
--
--
--
--
--
--
--
--

        			class_type.encryptionFunc(table, key, value)
        		else
        			rawset(table, key, value)
        		end

			end	
        })

		obj.__class_id = __next_class_index
		__next_class_index = __next_class_index + 1

		if obj.ctor then obj:ctor(...) end
		return obj
	end
	return class_type
end



function memory_class_simple_allnumber()
	local encryptionTable = {}

	local class_type = {}
	class_type.new = function(...)
		local obj = {}

		setmetatable(obj, { 
        	__index = function( table, key )    
        		if encryptionTable[key] then
        			return class_type.decryptionFunc(table, key) 
        		end

        		return class_type[key]
        	end,

        	__newindex = function(table, key, value)
				if encryptionTable[key] then
        			class_type.encryptionFunc(table, key, value)
				elseif type(value) == "number" and key ~= "__class_id" then
					encryptionTable[key] = true
        			class_type.encryptionFunc(table, key, value)
        		else
        			rawset(table, key, value)
        		end

			end	
        })

		obj.__class_id = __next_class_index
		__next_class_index = __next_class_index + 1

		if obj.ctor then obj:ctor(...) end
		return obj
	end
	return class_type
end
