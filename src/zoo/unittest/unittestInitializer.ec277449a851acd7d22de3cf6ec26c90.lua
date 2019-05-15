
require 'zoo.unittest.unittestFramework'
-- require 'zoo.unittest.heai.caseHEAI'

local tasks = {
	"caseHEAI",
	"HardLogicTestFrame",
	"caseObstacleFootprint",
	"TestPrime",
    "TestGetLength",
    "AutoPopoutTest",
    "MaintenanceGroupTest",
	"caseFontResource",
	"TestGuidesConfig",
	"MetaClientTest",
	"UserContextTest",
    "MoleWeekBoxUICheck",
	"dcTest",
	-- "caseCommonMultipleHitting", --没测试过，为避免出现惨剧先注释掉，以后打开
}

-- print('================================================================')
-- print('initialize tasks #' .. tostring(_G._isUnittestMode_))

local index = tonumber(_G._isUnittestMode_)
if index <= 0 then
	print('wrong case index = ' .. _G._isUnittestMode_)
	CCDirector:sharedDirector():endToLua()
elseif index > #tasks then
	print('no_more_unit_test_case')
	CCDirector:sharedDirector():endToLua()
else
	p = tasks[_G._isUnittestMode_]
	local framework = UnittestFramework:getInstance()
	-- framework:addTask(p)
	framework:run(p)
end

-- for i = 1, #tasks do
-- 	p = tasks[i]
-- 	-- t = p.new()
-- 	framework:addTask(p)

-- 	print('	init task = ' .. p)
-- end

-- print('================================================================')
-- print('running tasks')
-- framework:run()

