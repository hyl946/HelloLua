--[[
 * ShareConfig
 * @date    2018-04-09 18:31:41
 * @authors zhou.ding
 * @email 	zhou.ding@happyelements.com
--]]

local config = {10,20,30,220,40,50,60,70,80,90,280,100,110,120,130,140,150,160,170,180,230,240,190,290,200,210,250,260,270,}
local SharePriority = {}
for priority, id in ipairs(config) do
	SharePriority[id] = priority
end

return SharePriority