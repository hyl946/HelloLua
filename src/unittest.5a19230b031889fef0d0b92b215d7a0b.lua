print('package.path')
print(package.path)
print('\n')

print('package.cpath')
print(package.cpath)
print('\n')

function he_log_warning( ... )
	-- body
end

require "hecore.utils"

-- local baseModules = {}

-- function _unrequireAllLoadFile()
--     for m, _ in pairs(package.loaded) do
--     	if not baseModules[m] then
-- 		    package.loaded[m] = nil
-- 		    _G[m] = nil
-- 		end
-- 	end
-- end

-- local s = table.tostring(_G)
-- for i = 1, #s, 1000 do
-- 	local s1 = string.sub(s, i, i + 1000)
-- 	print(s1)
-- end
-- debug.debug()


--[[
if __WIN32 then
	local path = 'dashboard.txt'
	local file = io.open(path, 'w')
	file:write( "\n" )
	file:close()
end
]]

local _print = print
print = function ( s )
	_print(s)
	local path = 'dashboard.txt'
	local file = io.open(path, 'a')
	file:write( tostring(s) )
	file:write( "\n" )
	file:close()
end


_G.create_scene = CCScene.create
CCScene.create = function ( ... )
	assert(false, 'CCScene.create was been protected by unittest framework')
end


if __WIN32 then
  print('running as unit test mode = ' .. tostring(_G._isUnittestMode_))
  -- print('_G.EXIT_AFTER_TEST = ' .. tostring(_G.EXIT_AFTER_TEST))
  if _G._isUnittestMode_ then
    require 'zoo.unittest.unittestInitializer' 
 --    for m, _ in pairs(package.loaded) do
	--     baseModules[m] = true
	-- end
  end
end
