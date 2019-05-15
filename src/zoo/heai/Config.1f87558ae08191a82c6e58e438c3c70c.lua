---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2018-05-17 19:51:58
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   dan.liang
-- @Last Modified time: 2019-02-22 11:04:00
---------------------------------------------------------------------------------------
local Config = {
	debug_mode = false,
	sdk_version = "0.3",
	request_url = "http://loe.happyelements.cn/recommend.do",
	request_level_count = 5,
}

if _G.isLocalDevelopMode then
	-- "http://10.130.144.140:8080/recommend.do" 柴智
	Config.request_url = "http://loetest.happyelements.cn/recommend.do"
end

return Config