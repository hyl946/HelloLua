--[[
	处理客服页面操作游戏
	如：打开风车币面板，打开活动等
--]]

WebviewHandler = {}

local MARKET_PANEL_INDEX = 1
local BAG_PANEL_INDEX = 2

function WebviewHandler:handle( res )
	if res.method == "webview" then
		for f,p in pairs(res.para) do
			local func =  string.lower(f)
			if self[func] then
				self[func](self,p)
			else
				if _G.isLocalDevelopMode then printx(0, "this action not support!") end
			end
		end
	end
end

function WebviewHandler:openlevel( level )
	level = tonumber(level)
	if _G.isLocalDevelopMode then printx(0, "WebviewHandler openlevel:"..level) end
end

function WebviewHandler:openactivity( ... )
	if _G.isLocalDevelopMode then printx(0, "WebviewHandler openactivity...") end
end

function WebviewHandler:openpanel( index )
	if _G.isLocalDevelopMode then printx(0, "WebviewHandler openpanel...") end
	if index == MARKET_PANEL_INDEX then
		--open market panel
	elseif index == BAG_PANEL_INDEX then
		--open bag panel
	end
end

--[[ test
local function parseUrlScheme(url)
	if type(url) ~= "string" or string.len(url) <= 0 then return {} end
	local res, parser = {}, {}
	for v in string.gmatch(url, "[^:/?&]+") do
		table.insert(parser, v)
	end
	if #parser == 0 or string.lower(parser[1]) ~= "happyanimal3" then return res end
	table.remove(parser, 1)
	if #parser == 0 then return res end
	res.method = parser[1]
	table.remove(parser, 1)
	if #parser == 0 or string.lower(parser[1]) ~= "redirect" then return res end
	table.remove(parser, 1)
	if #parser == 0 then return res end
	res.para = {}
	while #parser > 0 do
		local a, b, key, value = string.find(parser[1], "(%w+)=(%w+)")
		if key and value then res.para[key] = value end
		table.remove(parser, 1)
	end
	return res
end

WebviewHandler:handle(parseUrlScheme("happyanimal3://webview/redirect?openlevel=123"))

--]]