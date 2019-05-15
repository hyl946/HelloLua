
require "zoo.util.MemClassSimple"


function memory_class()
	local class_type = {}
	class_type.new = function(...)
		local obj, _t = {}, {}

		setmetatable(obj, { 
        	__index = function( table, key )    
        		if key == "decryptionFunc" or key == "encryptionFunc" then return class_type[key] end

        		local decryptionFunc = table.decryptionFunc
        		local result = nil
        		if decryptionFunc ~= nil then result = decryptionFunc(table, key) end
        		
        		if result == nil then result = _t[key] end --1st: get data from self.
        		if result == nil then result = class_type[key] end --then find in class def
        		
        		--if type(result) ~= "function" then if _G.isLocalDevelopMode then printx(0, "__index::", tostring(key)) end end
        		return result
        	end,
        	__newindex = function(table, key, value)
        		if type(value) ~= "function" then
					--if _G.isLocalDevelopMode then printx(0, "access __newindex:", key, value) end
					local encryptionFunc = table.encryptionFunc
					local succeed = false
					if encryptionFunc ~= nil then
						succeed = encryptionFunc(table, key, value)
					end					
					if false == succeed then _t[key] = value end
				else _t[key] = value end
			end	
        })
		if obj.ctor then obj:ctor(...) end
		return obj
	end
	return class_type
end

local kFastEncryptInteger = {}
function encrypt_integer_f(k, v)
	--if _G.isLocalDevelopMode then printx(0, "encrypt_integer_fast:", k, v) end
	if v == nil then v = 0 end
	local encrypted = v * 3 + 2
	kFastEncryptInteger[k] = encrypted
end
function decrypt_integer_f(k)
	local encrypted = kFastEncryptInteger[k] or 0
	return (encrypted - 2)/3
end
function mem_deleteByKey(key)
	kFastEncryptInteger[key] = nil
end

function encrypt_integer(k, v)
	--if _G.isLocalDevelopMode then printx(0, "HeMemDataHolder::encrypt_integer", k, v) end
	if v == nil then v = 0 end
	HeMemDataHolder:setInteger(k, v)
end
function encrypt_number(k, v)
	--if _G.isLocalDevelopMode then printx(0, "HeMemDataHolder::encrypt_number", k, v) end
	if v == nil then v = 0 end
	HeMemDataHolder:setNumber(k, v)
end
function encrypt_string(k, v)
	--if _G.isLocalDevelopMode then printx(0, "HeMemDataHolder::encrypt_string", k, v) end
	if v == nil then v = "" end
	HeMemDataHolder:setString(k, v)
end
function decrypt_integer(k)
	local result = HeMemDataHolder:getInteger(k)
	--if _G.isLocalDevelopMode then printx(0, "HeMemDataHolder::decrypt_integer", k, result) end
	return result
end
function decrypt_number(k)
	local result = HeMemDataHolder:getNumber(k)
	--if _G.isLocalDevelopMode then printx(0, "HeMemDataHolder::decrypt_number", k, result) end
	return result
end
function decrypt_string(k)
	local result = HeMemDataHolder:getString(k)
	--if _G.isLocalDevelopMode then printx(0, "HeMemDataHolder::decrypt_string", k, result) end
	return result
end

function create_encrypt_const_integer_table(prefix, t)
	local result = {}
	setmetatable(result, { 
    	__index = function( table, key )    
    		local encryptKey = prefix .. "_" .. key
    		result = decrypt_integer(encryptKey)
    		return result
    	end,
    	__newindex = function(table, key, value)
    		if type(value) ~= "function" then
	    		local encryptKey = prefix .. "_" .. key
				encrypt_integer(encryptKey, value)
			else _t[key] = value end
		end	
    })

	for k, v in pairs(t) do
		result[k] = v
	end

	return result
end
