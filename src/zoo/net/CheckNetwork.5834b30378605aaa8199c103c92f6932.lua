
local isChecking = false

local compareUrl = "http://m.baidu.com/"

local dynamicIp = nil
if NetworkConfig.dynamicHost == "http://animalmobile.happyelements.cn/" then 
	dynamicIp = "http://182.254.189.181/"
elseif NetworkConfig.dynamicHost == "http://mobile.app100718846.twsapp.com/" then 
	-- dynamicIp = ""
end


local function request( url,callback )

    local function onCallback(response)
    	callback(response.httpCode)
    end

	local request = HttpRequest:createGet(url)
    request:setConnectionTimeoutMs(30 * 1000)
    request:setTimeoutMs(30 * 1000)

    HttpClient:getInstance():sendRequest(onCallback, request)

end

local function log( text )
	local oldTraceback = debug.traceback
	debug.traceback = function( ... ) return "CheckNetwork " .. text end
	he_log_error(text)
	debug.traceback = oldTraceback
end

function checkNetwork( ... )


	if isChecking then 
		return 
	end
	if _G.isLocalDevelopMode then printx(0, "checkNetwork ...") end

	local requestUrlList
	if dynamicIp then 
	 	requestUrlList = {
			{
				url = compareUrl,
				successLog="",failLog="",
				successContinue=true,failContinue=false
			},
			{
				url = NetworkConfig.dynamicHost,
				successLog="The client bug",failLog="",
				successContinue=false ,failContinue=true
			},
			{
				url = dynamicIp,
				successLog="DNS error",failLog="Failed to connect to the server",
				successContinue=false,failContinue=false
			},
		}
	else
	 	requestUrlList = {
			{
				url = compareUrl,
				successLog="",failLog="",
				successContinue=true,failContinue=false
			},
			{
				url = NetworkConfig.dynamicHost,
				successLog="The client bug",failLog="DNS error",
				successContinue=false ,failContinue=false
			},
		}
	end

	local requestList = {}
	for _,data in pairs(requestUrlList) do
		local url = data.url
		if url and string.len(url) > 0 then 
			local curRequestIdx = #requestList + 1

			-- if _G.isLocalDevelopMode then printx(0, curRequestIdx,url) end

			requestList[curRequestIdx] = function()
				
				if _G.isLocalDevelopMode then printx(0, url) end
				request(url,function ( code )
					if code == 200 then 
						if data.successContinue and #requestList > curRequestIdx then 
							requestList[curRequestIdx + 1]()
						else
							if string.len(data.successLog) > 0 then 
								log(data.successLog)
							end
							isChecking = false
						end
					else
						if data.failContinue and #requestList > curRequestIdx then 
							requestList[curRequestIdx + 1]()
						else
							if string.len(data.failLog) > 0 then 
								log(data.failLog)
							end
					 		isChecking = false
						end
					end

					-- if #requestList >= curRequestIdx then 
					-- 	isChecking = false
					-- end
				end)
			end

		end

	end

	requestList[1]()
end