function touchRegionsCollectStart()
	if not isLocalDevelopMode then
		return
	end

	local token = "_TEST_"
	local success, ret = pcall(function()
		local build = luajava.bindClass("android.os.Build")
		token = build.SERIAL
	end)
	print('touch service token = ' .. tostring(token))

	local function _createRequest(host, command)
	  local url = host .. '/?request=' .. command .. "&token=" .. tostring(token)
	  local request = HttpRequest:createPost(url)
	  request:setConnectionTimeoutMs(3 * 1000)
	  request:setTimeoutMs(30 * 1000)
	  request:addHeader("Content-Type: application/json")
	  return request
	end

	local function _sendRequest(request, body, callback)
	  local stream = table.serialize(body)
	  request:setPostData(stream, string.len(stream))
	  HttpClient:getInstance():sendRequest3(callback, request)
	end

	local __request_host = '10.130.136.193:1122'

	local function config(callback)
      local request = _createRequest(__request_host, "config")
      local body = {
        command='config', 
      }
      _sendRequest(request, body, callback)
	end

	local function clean()
      local request = _createRequest(__request_host, "clear")
      local body = {
        command='clear', 
      }
      _sendRequest(request, body, function(...)end)
	end

	-- local frameSize = CCDirector:sharedDirector():getOpenGLView():getFrameSize()
	-- local screenWidth = frameSize.width--MetaInfo:getInstance():getResolutionWidth()
	-- local screenHeight = frameSize.height--MetaInfo:getInstance():getResolutionHeight()
	-- local winSize = Director:sharedDirector():getWinSize()
	-- local winWidth = winSize.width
	-- local winHeight = winSize.height
	-- print('size, screenWidth:' .. tostring(screenWidth))
	-- print('size, screenHeight:' .. tostring(screenHeight))
	-- print('size, winWidth:' .. tostring(winWidth))
	-- print('size, winHeight:' .. tostring(winHeight))
	-- local function convert2DeviceCoord(x, y)
	-- 	x = x / winWidth * screenWidth
	-- 	y = y / winHeight * screenHeight
	-- 	return x, y
	-- end

	local function collectRegions()
		local collectNodes = {}

		local scene = Director:sharedDirector():getRunningSceneLua()
		local function collectChildren(root)
			local children = root:getChildrenList()
			if not children then return end
			for _,node in pairs(children) do
				if node and node:isVisible() then
					if node.__isGroupButtonBase__ then
						collectNodes[#collectNodes + 1] = node
					else
						collectChildren(node)
					end
				end
			end
		end

		-- 找到弹出的面板
		if scene.__popoutList then
			for _, v in ipairs(scene.__popoutList) do
				if v:getParent() then
					collectChildren(v)
					-- break 
				end
			end
		end
		if #collectNodes < 1 then
			collectChildren(scene)
		end

		local regions = {}
		local function convert2regions()
			printx(-8, '====================================')
			for i = 1, #collectNodes do
				local node = collectNodes[i]
				-- local p = node:convertToWorldSpace(ccp(0, 0))
				local b = node:getGroupBounds()
				local x = math.floor(b.origin.x)
				local y = math.floor(b.origin.y)
				local w = math.floor(b.size.width)
				local h = math.floor(b.size.height)
				-- x, y = convert2DeviceCoord(x, y)
				-- w, h = convert2DeviceCoord(w, h)
				printx(-8, "#" .. tostring(i) .. "\t" .. tostring(node) .. '\t' .. tostring(x) .. '\t' .. tostring(y) .. '\t' .. tostring(w) .. '\t' .. tostring(h))
				local uniqName = ""
				if node.getUniqNameCascade then
					uniqName = node:getUniqNameCascade()
				end
				regions[#regions + 1] = {x, y, w, h, uniqName}
			end
		end

		convert2regions()
		return regions
	end

	local function onUpdate()
		local regions = {}
		local status = {
				running='normal',
				reason='',
		}
		if not _G.__GAME_CRASHED__ then
			regions = collectRegions()
		else
			status = {
				running='crash',
				reason=_G.__GAME_CRASH_MSG__,
			}
		end

		-- x, y = convert2DeviceCoord(_G.__SAFE_AREA.x, _G.__SAFE_AREA.y)
		-- w, h = convert2DeviceCoord(_G.__SAFE_AREA.width, _G.__SAFE_AREA.height)

		local request = _createRequest(__request_host, "update")
		local body = {
			command='update', 
			regions=regions,
			screen={
				x=_G.__SAFE_AREA.x,
				y=_G.__SAFE_AREA.y,
				width=_G.__SAFE_AREA.width,
				height=_G.__SAFE_AREA.height,
			},
			resolution={
				width=CCDirector:sharedDirector():getWinSize().width,
				height=CCDirector:sharedDirector():getWinSize().height,
				},
			status=status,
		}
		_sendRequest(request, body, function(...)end)
	end

	local function onConfig(response)
		local enable = false
		if response.httpCode == 200 then 
			enable = response.body == "TRUE"
		end

		if enable or false then
			_G.RegionsCollectEnable = true
			clean()
			local hwnd = CCDirector:sharedDirector():getScheduler():scheduleScriptFunc(onUpdate, 0.5, false)
		end
	end
	config(onConfig)

end
