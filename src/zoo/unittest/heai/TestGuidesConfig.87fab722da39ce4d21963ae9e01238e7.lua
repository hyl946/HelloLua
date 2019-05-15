---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2019-01-07 15:13:34
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   dan.liang
-- @Last Modified time: 2019-01-07 16:37:41
---------------------------------------------------------------------------------------
-- 检测Guides.lua配置是否正确，以防产品配置格式错误

-- mock global func
MACRO_DEV_START = MACRO_DEV_START or function() end
MACRO_DEV_END = MACRO_DEV_END or function() end
if not Director then
	Director = class()

	function Director:sharedDirector()
		return self
	end

	function Director:getVisibleSize()
		return {width = 720, height = 1280}
	end

	function Director:getVisibleOrigin()
		return {x = 0, y = 0}
	end
end
if not ccp then
	ccp = function(x, y)
		return {x = x, y = y}
	end
end

__EDGE_INSETS = {
  top = 0,
  left = 0,
  bottom = 0,
  right = 0,
}
__SAFE_AREA = {
	x = 0,
	y = 0,
	width = 720,
	height = 1280,
}

TestGuidesConfig = class(UnittestTask)

function TestGuidesConfig:ctor()

end

function TestGuidesConfig:run(callback_success_message)
	require "zoo.gameGuide.Guides"
	if Guides then
		callback_success_message(true, 'test Guides config successd!')
	else
		callback_success_message(false, 'test Guides config error!') -- 按道理上面require会有错误输出
	end
end
