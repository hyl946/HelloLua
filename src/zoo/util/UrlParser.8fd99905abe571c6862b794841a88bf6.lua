
UrlParser = class()

--SchemaSdk("happyanimal3://week_match/redirect?key=val")
--UniversalLink("http://xxl.happyelements.com/?method=week_match")
function UrlParser:parseUrlScheme(url)
	if type(url) ~= "string" or string.len(url) <= 0 then return {} end
	local res, parser = {}, {}
	for v in string.gmatch(url, "[^:/?&]+") do
		table.insert(parser, v)
	end

	-- check protocal length
	if #parser < 2 then return res end

	if string.lower(parser[1]) == "happyanimal3" then 
		return self:parseUrlForScheme(url) 
	end

	if string.lower(parser[2]) == "xxl.happyelements.com" then
		return self:parseUrlForUniversalLink(url)
	end

	return res
end

-- parse string to table for UrlSchemeSDK
function UrlParser:parseUrlForScheme(url)
	if type(url) ~= "string" or string.len(url) <= 0 then return {} end
	local res, parser = {}, {}
	res.urlType = "Scheme"
	
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
		local a, b, key, value = string.find(parser[1], "([%w_]+)=([%w-_%%.,]+)")
		if key and value then
			if string.find(value, ',') then
				res.para[key] = string.split(value, ',')
			else
				res.para[key] = value
			end
		end
		table.remove(parser, 1)
	end
	return res
end

-- parse string to table for UniversalLink("http://xxl.happyelements.com/?method=week_match")
function UrlParser:parseUrlForUniversalLink(url)
	if type(url) ~= "string" or string.len(url) <= 0 then return {} end
	local res, parser = {}, {}
	res.urlType = "UniversalLink"

	for v in string.gmatch(url, "[^:/?&]+") do
		table.insert(parser, v)
	end
  
    -- protocal check
	if #parser < 3 then return res end
  
  	-- schema
	table.remove(parser, 1)
  
  	-- domain
	if string.lower(parser[1]) ~= "xxl.happyelements.com" then return res end
	table.remove(parser, 1)
  
  	-- params
	res.para = {}
	while #parser > 0 do
		local a, b, key, value = string.find(parser[1], "([%w_]+)=([%w-_%%.,]+)")
		if key and value then
			if string.find(value, ',') then
				res.para[key] = string.split(value, ',')
			else
				res.para[key] = value
			end
		end
		table.remove(parser, 1)
	end
  
  	res.method = res.para.method
  	res.para.method = nil
  	return res
end

local sameUrl = {
	"http://animalmobile.happyelements.cn/",
	"http://mobile.app100718846.twsapp.com/",
	"http://animaltgz.happyelements.cn/",
}
if not table.exist(sameUrl, NetworkConfig.dynamicHost) then
	table.insert(sameUrl, NetworkConfig.dynamicHost)
end
function UrlParser:parseQRCodeAddFriendUrl(url)
	if type(url) ~= "string" or string.len(url) <= 0 then return {} end
	local res, parser = {}, {}
	for v in string.gmatch(url, "[^:/?&]+") do
		table.insert(parser, v)
	end

	local function checkUrl(parser, host)
		if #parser < 1 or string.lower(parser[1]) ~= string.lower(host[1]) then return false, res end
		if #parser < 2 or string.lower(parser[2]) ~= string.lower(host[2]) then return false, res end
		if #parser < 3 or string.lower(parser[3]) ~= "qrcode.jsp" then return false, res end
		for i = 4, #parser do
			local a, b, key, value = string.find(parser[i], "(%w+)=(%w+)")
			if key and value then res[key] = value end
		end
		return true, res
	end

	for k, v in ipairs(sameUrl) do
		local elem = {}
		for i in string.gmatch(v, "[^:/?&]+") do
			table.insert(elem, i)
		end
		local success, res = checkUrl(parser, elem)
		if success then return res end
	end
	return {}
end

function UrlParser:parseParams(url)
	if type(url) ~= "string" or string.len(url) <= 0 then return {} end
	local params, parser = {}, {}
	for v in string.gmatch(url, "[^?&]+") do
		table.insert(parser, v)
	end
	local shceme = parser[1]
	local params = {}
	for i = 2, #parser do
		local a, b, key, value = string.find(parser[i], "(.+)=(.+)")
		if key and value then params[key] = string.urldecode(value) end
		printx(0, key, "=",params[key])
	end
	return {shceme = shceme, para = params}
end