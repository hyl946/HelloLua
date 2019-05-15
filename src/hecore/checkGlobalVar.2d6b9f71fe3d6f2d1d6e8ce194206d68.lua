
-- Copyright C2009-2013 www.happyelements.com, all rights reserved.
-- Create Date:	2013年10月25日 17:07:06
-- Author:	ZhangWan(diff)
-- Email:	wanwan.zhang@happyelements.com

-- ---------------------------------
-- Check Global Variable's Creation
-- ---------------------------------
assert(not trueGlobalTable)
trueGlobalTable = {}

setmetatable(_G, {

	__newindex = function(t, k, v)
		if rawget(trueGlobalTable, k) then
			assert(false, "Global Variable \"" .. tostring(k) .. "\" Already Defined Before !")
		end
		trueGlobalTable[k] = v
	end,

	__index = function(t, k)
		return trueGlobalTable[k]
	end
})

---------------------------------------
----	Test Global Variable Creation
----	-------------------------------
--
--if _G.isLocalDevelopMode then printx(0, "Start Global Variabel Creation Test :") end
--debug.debug()
--
--a = 100
--if _G.isLocalDevelopMode then printx(0, "a: " .. a) end
--
--b = 200
--b = 200
--
--if _G.isLocalDevelopMode then printx(0, "End Global Variable Creation Test !") end
--debug.debug()
