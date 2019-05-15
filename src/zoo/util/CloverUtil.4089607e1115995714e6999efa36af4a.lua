---------------------------------------------------------------------------------------
-- @Author: dan.liang
-- @Date:   2016-09-06 17:30:43
-- @Email:  dan.liang@happyelements.com
-- @Last Modified by:   Administrator
-- @Last Modified time: 2016-09-07 09:55:19
---------------------------------------------------------------------------------------
require 'zoo.util.OpenUrlUtil'

CloverUtil = class()

local kCloverScheme="happyclover3"
local kDownloadDirectUrl = "http://clover.happyelements.cn/xxl.jsp"

local function buildUrl( url,params )
	if type(params) ~= "table" or table.isEmpty(params) then return url end

    local qs = {}
    for k,v in pairs(params) do
         table.insert(qs,k .. "=" .. HeDisplayUtil:urlEncode(tostring(v)))
    end

    if string.find(url,"%?") then
        return url .. "&" .. table.concat(qs,"&")
    else
        return url .. "?" .. table.concat(qs,"&")        
    end
end

function CloverUtil:isAppInstall()
	return OpenUrlUtil:canOpenUrl(kCloverScheme.."://animal/isInstall")
end

function CloverUtil:openApp(action, params)
	action = action or "openApp"
	local url = kCloverScheme.."://animal/"..action
	OpenUrlUtil:openUrl(buildUrl( url,params ))
end

function CloverUtil:downloadApk(params)
	params = params or {}
	params.t = os.time()
	local url = buildUrl(kDownloadDirectUrl, params)
	if _G.isLocalDevelopMode then printx(0, ">>>downloadApk:", url) end
	OpenUrlUtil:openUrl(url)
end